# DNS-Konfiguration für SMGW SSL-Zertifikatsvalidierung

## 🎯 Übersicht

Das SMGW (z.B. Theben Smart Energy Conexa) verwendet ein SSL-Zertifikat mit einem **Subject Alternative Name (SAN)**, der als Hostname im Zertifikat hinterlegt ist. Um die SSL-Zertifikatsvalidierung erfolgreich durchzuführen, muss dieser Hostname aufgelöst werden können.

## ✨ Neu: Automatische DNS-Konfiguration (empfohlen!)

**Ab Version 1.1.0** kann das SMGW Route Manager Addon die DNS-Konfiguration automatisch vornehmen!

### Schnellstart - Automatische Konfiguration

1. **Hostname aus SMGW-Zertifikat ermitteln** (siehe unten)
2. **Addon-Konfiguration erweitern:**
   ```yaml
   smgw_hostname: "ethe0300186023.sm"  # Ihr SMGW-Hostname
   dns_enabled: true                    # DNS-Funktion aktivieren
   ```
3. **Addon neu starten**
4. **Fertig!** ✅

**Vorteile der automatischen Konfiguration:**
- ✅ Keine manuelle Hosts-Datei-Bearbeitung
- ✅ Funktioniert für alle Geräte, die über Home Assistant auf das SMGW zugreifen
- ✅ Automatische Wartung und Wiederherstellung des DNS-Eintrags
- ✅ SSL-Zertifikatsvalidierung ohne Warnungen

→ **Das ist die empfohlene Methode!**

---

## 📋 Alternative: Manuelle Konfiguration

Wenn Sie die DNS-Konfiguration nicht über das Addon vornehmen möchten, können Sie sie auch manuell einrichten.

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

Sie haben drei Möglichkeiten, den Hostnamen aufzulösen:

### Option 1: SMGW Route Manager Addon (✨ NEU - empfohlen!)

**Vorteile:**
- ✅ Vollständig automatisch
- ✅ Keine manuelle Konfiguration nötig
- ✅ Automatische Wartung des DNS-Eintrags
- ✅ Funktioniert für alle Geräte über Home Assistant

**Nachteile:**
- ❌ Erfordert Addon Version 1.1.0 oder höher

→ **[Anleitung: Automatische Konfiguration](#-neu-automatische-dns-konfiguration-empfohlen)**

### Option 2: Windows Hosts-Datei (für einzelne PCs)

**Vorteile:**
- ✅ Schnell und einfach
- ✅ Keine zusätzliche Hardware/Software nötig
- ✅ Funktioniert sofort

**Nachteile:**
- ❌ Muss auf jedem PC einzeln konfiguriert werden
- ❌ Nicht für mobile Geräte geeignet

→ **[Anleitung: Windows Hosts-Datei](#windows-hosts-datei)**

### Option 3: DNS-Server (für Netzwerk)

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

