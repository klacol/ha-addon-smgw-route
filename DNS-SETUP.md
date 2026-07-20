# DNS-Konfiguration für SMGW SSL-Zertifikatsvalidierung

## 🎯 Übersicht

Das SMGW (z.B. Theben Smart Energy Conexa) verwendet ein SSL-Zertifikat mit einem **Subject Alternative Name (SAN)**, der als Hostname im Zertifikat hinterlegt ist. Um die SSL-Zertifikatsvalidierung erfolgreich durchzuführen, muss dieser Hostname aufgelöst werden können.

## 📋 Ihre SMGW-Daten

Basierend auf dem Zertifikat des Theben Conexa SMGW:

- **Hostname (SAN-Name):** `ethe0300186023.sm`
- **IP-Adresse:** `10.11.120.2`
- **Netzwerk:** `10.11.120.0/24`

**⚠️ WICHTIG:** Ihr SMGW hat möglicherweise einen anderen Hostnamen! Den SAN-Namen können Sie im Zertifikat des SMGW nachsehen.

## 🔍 Warum ist das wichtig?

### Mit Hostname (empfohlen):
```
✅ https://ethe0300186023.sm
   → SSL-Zertifikat wird korrekt validiert
   → Keine Zertifikatswarnungen
   → Sicherer Zugriff
```

### Ohne Hostname (nur IP):
```
⚠️ https://10.11.120.2
   → Zertifikatswarnung (Hostname stimmt nicht überein)
   → Manuelles Akzeptieren erforderlich
   → Browser-Warnungen
```

## 🔧 Konfigurationsmöglichkeiten

Sie haben zwei Möglichkeiten, den Hostnamen aufzulösen:

### Option 1: Windows Hosts-Datei (empfohlen für einzelne PCs)

**Vorteile:**
- ✅ Schnell und einfach
- ✅ Keine zusätzliche Hardware/Software nötig
- ✅ Funktioniert sofort

**Nachteile:**
- ❌ Muss auf jedem PC einzeln konfiguriert werden
- ❌ Nicht für mobile Geräte geeignet

→ **[Anleitung: Windows Hosts-Datei](#windows-hosts-datei)**

### Option 2: DNS-Server (empfohlen für Netzwerk)

**Vorteile:**
- ✅ Zentrale Konfiguration
- ✅ Funktioniert für alle Geräte im Netzwerk
- ✅ Auch für Smartphones/Tablets

**Nachteile:**
- ❌ Erfordert Zugriff auf Router/DNS-Server
- ❌ Etwas komplexer

→ **[Anleitung: DNS-Server](#dns-server-konfiguration)**

---

## 🖥️ Windows Hosts-Datei

### Schritt 1: Notepad als Administrator öffnen

1. **Start-Menü** öffnen
2. **"Notepad"** eingeben
3. **Rechtsklick** auf "Notepad"
4. **"Als Administrator ausführen"** wählen
5. Bei UAC-Abfrage **"Ja"** klicken

### Schritt 2: Hosts-Datei öffnen

1. In Notepad: **Datei** → **Öffnen**
2. Pfad eingeben: `C:\Windows\System32\drivers\etc\hosts`
3. Dateityp auf **"Alle Dateien (*.*)"** ändern (unten rechts)
4. Datei **öffnen**

### Schritt 3: SMGW-Eintrag hinzufügen

Fügen Sie am **Ende der Datei** folgende Zeile hinzu:

```
10.11.120.2    ethe0300186023.sm
```

**⚠️ WICHTIG:** Ersetzen Sie `ethe0300186023.sm` durch den tatsächlichen Hostnamen aus Ihrem SMGW-Zertifikat und die IP Adresse auf die IP Ihres SMGW!

### Schritt 4: Speichern und testen

1. **Datei** → **Speichern**
2. Notepad **schließen**

### Test durchführen:

```powershell
# DNS-Auflösung testen
ping ethe0300186023.sm
```

**Erwartete Ausgabe:**
```
Antwort von 10.11.120.2: Bytes=32 Zeit=1ms TTL=63
```

---

## 🌐 DNS-Server Konfiguration

**⚠️ Hinweis:** Die Fritzbox unterstützt **keine benutzerdefinierten DNS-Einträge** direkt. Sie müssen einen separaten DNS-Server verwenden (siehe Option B oder C).

---

## 🐧 Home Assistant DNS (optional)

Falls Sie Home Assistant OS verwenden und auch dort den Hostnamen nutzen möchten:

### Variante 1: Über Hosts-Datei

```bash
# SSH ins Home Assistant OS
# /etc/hosts bearbeiten

echo "10.11.120.2    ethe0300186023.sm" >> /etc/hosts
```

**⚠️ Hinweis:** Diese Änderung geht bei Updates verloren!

### Variante 2: Über Add-on (persistent)

Verwenden Sie das **"Home Assistant OS Agent"** oder **"SSH & Web Terminal"** Add-on:

1. **Einstellungen** → **Add-ons** → **SSH & Web Terminal**
2. **Terminal öffnen**
3. Befehl ausführen:

```bash
ha dns options --servers dns://192.168.0.119
```

Dies setzt den GL.iNet als DNS-Server für Home Assistant.

