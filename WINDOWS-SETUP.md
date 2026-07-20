# SMGW Route Installation für Windows PC

## 🎯 Übersicht

Diese Anleitung zeigt, wie Sie die statische Route zum SMGW auf Ihrem **Windows PC** einrichten, sodass Sie direkt vom PC auf das SMGW zugreifen können (z.B. über Browser unter `https://10.11.120.2`).

## ⚠️ Wichtig

Diese Anleitung ist **NUR für Windows PCs** gedacht, **NICHT für Home Assistant**!

- **Für Home Assistant**: Verwenden Sie das [SMGW Route Manager Addon](README.md)
- **Für Windows PC**: Folgen Sie dieser Anleitung

## 📋 Voraussetzungen

1. ✅ GL.iNet Router ist eingerichtet und läuft (siehe [GL-INET-SETUP.md](GL-INET-SETUP.md))
2. ✅ SMGW ist mit dem GL.iNet verbunden
3. ✅ Sie kennen die WAN-IP des GL.iNet Routers (z.B. `192.168.0.119`)
4. ✅ Windows PC mit Administrator-Rechten

## 🚀 Installation

### Option 1: Automatisch mit PowerShell-Skript (empfohlen)

#### Schritt 1: PowerShell als Administrator öffnen

1. **Start-Menü** öffnen
2. **"PowerShell"** eingeben
3. **Rechtsklick** auf "Windows PowerShell"
4. **"Als Administrator ausführen"** wählen
5. Bei UAC-Abfrage **"Ja"** klicken

#### Schritt 2: Zum Projekt-Ordner navigieren

```powershell
cd C:\Git\klacol\ha-addon-smgw-route
```

#### Schritt 3: Skript-Ausführung erlauben (einmalig)

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

#### Schritt 4: Route installieren

```powershell
.\install-windows-route.ps1
```

**Das Skript wird:**
- ✅ Prüfen, ob Sie Administrator-Rechte haben
- ✅ Prüfen, ob der GL.iNet Router erreichbar ist
- ✅ Die Route zum SMGW-Netzwerk hinzufügen
- ✅ Die Route persistent machen (bleibt nach Neustart bestehen)
- ✅ Testen, ob das SMGW erreichbar ist

#### Erwartete Ausgabe:

```
========================================
SMGW Route Installation für Windows
========================================

Konfiguration:
  SMGW-Netzwerk: 10.11.120.0/255.255.255.0
  Gateway (GL.iNet): 192.168.0.119

✅ Administrator-Rechte vorhanden

Teste Verbindung zum Gateway 192.168.0.119...
✅ Gateway 192.168.0.119 ist erreichbar

Prüfe vorhandene Routen...

Füge persistente Route hinzu...
Befehl: route add 10.11.120.0 mask 255.255.255.0 192.168.0.119 -p
✅ Route erfolgreich hinzugefügt!

Die Route ist jetzt aktiv und bleibt nach einem Neustart bestehen.

Teste Verbindung zum SMGW (10.11.120.2)...
✅ SMGW ist erreichbar!
   Sie können jetzt von diesem PC auf das SMGW zugreifen.

========================================
Installation abgeschlossen!
========================================
```

### Option 2: Manuell mit Befehl

Falls Sie das Skript nicht verwenden möchten:

1. **PowerShell als Administrator öffnen** (siehe Schritt 1 oben)
2. **Route hinzufügen:**

```powershell
route add 10.11.120.0 mask 255.255.255.0 192.168.0.119 -p
```

**Parameter erklärt:**
- `10.11.120.0` = SMGW-Netzwerk
- `mask 255.255.255.0` = Subnetzmaske für /24
- `192.168.0.119` = Gateway (WAN-IP des GL.iNet Routers)
- `-p` = Persistent (bleibt nach Neustart bestehen)

## ✅ Testen

### Test 1: Route prüfen

```powershell
route print | Select-String "10.11.120"
```

**Erwartete Ausgabe:**
```
     10.11.120.0    255.255.255.0   192.168.0.119     192.168.0.xxx     36
```

### Test 2: GL.iNet Router erreichen

```powershell
ping 192.168.0.119
```

**Erwartete Ausgabe:**
```
Antwort von 192.168.0.119: Bytes=32 Zeit<1ms TTL=64
```

### Test 3: SMGW erreichen

```powershell
ping 10.11.120.2
```

**Erwartete Ausgabe:**
```
Antwort von 10.11.120.2: Bytes=32 Zeit=1ms TTL=63
```

### Test 4: SMGW Web-Interface öffnen

1. **Browser öffnen** (Chrome, Firefox, Edge)
2. **URL eingeben:** `https://10.11.120.2`
3. **Zertifikatswarnung** akzeptieren (selbstsigniertes Zertifikat)
4. **SMGW-Login** sollte erscheinen

**💡 Tipp:** Um die Zertifikatswarnung zu vermeiden, können Sie einen DNS-Eintrag für den Hostnamen des SMGW hinzufügen. Siehe **[DNS-Setup Anleitung](DNS-SETUP.md)** für Details.

## 🗑️ Deinstallation

### Option 1: Mit PowerShell-Skript

```powershell
.\remove-windows-route.ps1
```

### Option 2: Manuell

```powershell
route delete 10.11.120.0
```

## 🔧 Konfiguration anpassen

Falls Ihre Netzwerk-Konfiguration anders ist:

### Im PowerShell-Skript

Öffnen Sie `install-windows-route.ps1` und passen Sie diese Zeilen an:

```powershell
$smgwNetwork = "10.11.120.0"           # SMGW-Netzwerk
$subnetMask = "255.255.255.0"          # Subnetzmaske
$gatewayIP = "192.168.0.119"           # WAN-IP des GL.iNet Routers
```

### Für manuellen Befehl

Passen Sie den Befehl entsprechend an:

```powershell
route add <SMGW-Netzwerk> mask <Subnetzmaske> <Gateway-IP> -p
```

## 🔒 SSL-Zertifikat ohne Warnung (optional)

Das SMGW verwendet ein SSL-Zertifikat mit einem spezifischen Hostnamen (SAN). Um die Zertifikatswarnung beim Zugriff zu vermeiden, können Sie einen DNS-Eintrag hinzufügen.

### Windows Hosts-Datei bearbeiten

1. **Notepad als Administrator** öffnen
2. **Datei öffnen:** `C:\Windows\System32\drivers\etc\hosts`
3. **Am Ende hinzufügen:**
   ```
   10.11.120.2    ethe0300186023.sm
   ```
4. **Speichern** und Notepad schließen

**⚠️ WICHTIG:** Ersetzen Sie `ethe0300186023.sm` durch den tatsächlichen Hostnamen aus Ihrem SMGW-Zertifikat!

**Den Hostnamen finden:**
1. `https://10.11.120.2` im Browser öffnen
2. Zertifikatswarnung akzeptieren
3. **Schloss-Symbol** in Adressleiste → **Zertifikat anzeigen**
4. Unter **"Subject Alternative Name"** finden Sie den Hostnamen

### Zugriff mit Hostname

Nach dem Hosts-Eintrag können Sie das SMGW über den Hostnamen erreichen:

```
https://ethe0300186023.sm
```

**✅ Vorteil:** Keine Zertifikatswarnung mehr!

→ **[Vollständige DNS-Setup Anleitung](DNS-SETUP.md)** mit allen Optionen (Windows Hosts, DNS-Server, etc.)

---

## ❓ Problembehandlung

### Problem: "Route bereits vorhanden"

**Lösung:** Entfernen Sie die alte Route zuerst:

```powershell
route delete 10.11.120.0
route add 10.11.120.0 mask 255.255.255.0 192.168.0.119 -p
```

### Problem: "Zugriff verweigert"

**Lösung:** PowerShell als Administrator ausführen (siehe Schritt 1)

### Problem: Gateway nicht erreichbar

**Prüfen Sie:**
- ✅ Ist der GL.iNet Router eingeschaltet?
- ✅ Ist das Ethernet-Kabel vom GL.iNet zum Heimnetzwerk verbunden?
- ✅ Stimmt die Gateway-IP (192.168.0.119)?

```powershell
# Gateway-IP im Heimnetzwerk finden
arp -a | Select-String "192.168.0"
```

### Problem: SMGW nicht erreichbar

**Prüfen Sie:**
- ✅ Ist das Gateway erreichbar? (`ping 192.168.0.119`)
- ✅ Ist die Route aktiv? (`route print | Select-String "10.11.120"`)
- ✅ Ist das SMGW mit dem GL.iNet verbunden?
- ✅ Ist die Firewall-Regel im GL.iNet konfiguriert? (siehe [GL-INET-SETUP.md](GL-INET-SETUP.md))

```powershell
# Trace-Route zum SMGW
tracert -d 10.11.120.2
```

**Erwartete Ausgabe:**
```
  1    <1 ms    <1 ms    <1 ms  192.168.0.119   # GL.iNet
  2     1 ms     1 ms     1 ms  10.11.120.2     # SMGW
```

### Problem: Route verschwindet nach Neustart

**Ursache:** Parameter `-p` vergessen

**Lösung:** Route mit `-p` Parameter hinzufügen:

```powershell
route add 10.11.120.0 mask 255.255.255.0 192.168.0.119 -p
```

## 📊 Befehls-Übersicht

| Aktion | Befehl |
|--------|--------|
| Route hinzufügen | `route add 10.11.120.0 mask 255.255.255.0 192.168.0.119 -p` |
| Route entfernen | `route delete 10.11.120.0` |
| Routen anzeigen | `route print` |
| Route prüfen | `route print \| Select-String "10.11.120"` |
| Gateway testen | `ping 192.168.0.119` |
| SMGW testen | `ping 10.11.120.2` |
| Trace-Route | `tracert -d 10.11.120.2` |

## 🔄 Weitere PCs einrichten

Um weitere Windows PCs einzurichten:

1. Kopieren Sie `install-windows-route.ps1` auf den anderen PC
2. Führen Sie das Skript als Administrator aus
3. Oder verwenden Sie den manuellen Befehl auf jedem PC

**Tipp:** Sie können das Skript auch über eine Netzwerkfreigabe ausführen.

## 📝 Hinweise

### Persistenz

Die Route mit `-p` Parameter bleibt **permanent** bestehen:
- ✅ Nach Windows-Neustart
- ✅ Nach Netzwerkwechsel
- ✅ Nach Adapter-Aktivierung/-Deaktivierung

### Sicherheit

Die Route ermöglicht **nur Zugriff auf das SMGW-Netzwerk** (10.11.120.x):
- ✅ Ihr PC kann das SMGW erreichen
- ✅ Das SMGW kann Ihren PC erreichen (wenn Firewall erlaubt)
- ❌ Andere Geräte im Heimnetzwerk haben **keinen** automatischen Zugriff

### Performance

Die Route hat **keine spürbare Auswirkung** auf:
- Internet-Geschwindigkeit
- Netzwerk-Performance
- CPU-Auslastung

## 🔗 Weiterführende Links

- [GL.iNet Router Setup](GL-INET-SETUP.md)
- [Home Assistant Addon](README.md)
- [Installation für Home Assistant](INSTALLATION.md)
