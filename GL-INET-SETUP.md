# GL.iNet MT300N-V2 für SMGW - Komplette Anleitung

## 🎯 Ziel
GL.iNet Router als Bridge zwischen Heimnetzwerk und SMGW einrichten.

**Setup-Typ:** Ethernet-WAN (ideal für Zählerschrank ohne gutes WLAN)  
**Schwierigkeitsgrad:** Einfach  
**Zeit:** 20-30 Minuten  
**Technische Kenntnisse:** Grundlegend

---

## 📦 Was Sie brauchen

### Hardware (mitgeliefert):
- ✅ GL.iNet MT300N-V2 Router
- ✅ USB-Netzteil (5V)
- ✅ Micro-USB-Kabel

### Hardware (selbst besorgen):
- ✅ **2× Ethernet-Kabel (Cat5e oder besser)**
  - 1× vom Heimnetzwerk-Switch/Router bis zum Zählerschrank (z.B. 10-30m je nach Entfernung)
  - 1× vom GL.iNet zum SMGW (kurz, 0,5-2m)
- ✅ Laptop/PC mit WLAN (für Erstkonfiguration)

### Zugangsdaten:
- ✅ SMGW-Username (vom Netzbetreiber)
- ✅ SMGW-Passwort (vom Netzbetreiber)
- ✅ Ihr Heimnetzwerk-IP-Bereich (z.B. 192.168.0.x oder 192.168.1.x)

---

## � Technischer Hintergrund (BSI TR-03109-1)

### Netzwerk-Terminologie
Das SMGW hat gemäß **BSI TR-03109-1** (Technische Richtlinie für Smart Meter Gateways) drei getrennte Netzwerke:

- **WAN** (Wide Area Network): Internet-Verbindung des SMGW zum Gateway-Administrator (GWA) - meist über Mobilfunk
- **HAN** (Home Area Network): Lokale Schnittstelle für Heimnetzwerk-Zugriff (hier greifen wir zu!)
- **LMN** (Local Metrological Network): Verbindung zu Zählern/Sensoren

**⚠️ Wichtig zu verstehen:**
- Der **SMGW-HAN-Port** ist die Schnittstelle für lokale Nutzer (z.B. Sie mit Home Assistant)
- Der **GL.iNet "WAN-Port"** verbindet sich mit Ihrem Heimnetzwerk (nicht mit SMGW-WAN!)
- Der **GL.iNet "LAN-Port"** verbindet sich mit dem **SMGW-HAN-Port**
- Das SMGW hat seinen eigenen Internet-Zugang (SMGW-WAN) - unabhängig von Ihrem Setup!

### Sicherheitsaspekte
Gemäß TR-03109-1:
- ✅ Das SMGW fungiert als Firewall und trennt die Netze
- ✅ Das SMGW akzeptiert **keine** eingehenden Verbindungen aus dem Internet
- ✅ Lokaler Zugriff auf den HAN-Port ist vorgesehen und sicher
- ✅ IPv4 ist ausreichend (IPv6 ist optional)

**Ihr GL.iNet übernimmt die Rolle der physischen Netzwerktrennung zwischen Ihrem Heimnetzwerk und dem SMGW-HAN-Netzwerk.**

---

## �🔌 Physische Topologie

```
[Fritzbox/Heimnetzwerk-Router im Haus]
            | Heimnetzwerk (192.168.0.x)
            | Ethernet-Kabel (10-30m)
            ↓
    ╔═══════════════════════════════════════════════╗
    ║  Zählerschrank                                ║
    ║                                               ║
    ║  ┌──[WAN-Port]─────────────────────────────┐ ║
    ║  │  GL.iNet MT300N-V2                      │ ║
    ║  │  WAN: z.B. 192.168.0.119 (Heimnetzwerk) │ ║
    ║  │  LAN: 10.11.120.1 (SMGW-HAN-Netz)      │ ║
    ║  └──[LAN-Port]─────────────────────────────┘ ║
    ║            | 10.11.120.0/24 Netzwerk          ║
    ║            | Kurzes Kabel                     ║
    ║            ↓                                   ║
    ║  ┌───[HAN-Port]─────────────────────────────┐ ║
    ║  │  SMGW (Smart Meter Gateway)             │ ║
    ║  │  HAN: 10.11.120.2                       │ ║
    ║  │  WAN: Mobilfunk → GWA (unabhängig!)     │ ║
    ║  │  LMN: Zähler/Sensoren                   │ ║
    ║  └─────────────────────────────────────────┘ ║
    ╚═══════════════════════════════════════════════╝
```

**WICHTIG:** 
- **GL.iNet WAN-Port** → Verbindung zu Ihrem Heimnetzwerk (z.B. 192.168.0.x)
- **GL.iNet LAN-Port** → Verbindung zum SMGW-HAN-Port (10.11.120.x)
- **SMGW-HAN-Port** → Lokale Schnittstelle für Heimnetzwerk-Zugriff
- **SMGW-WAN** → Eigene Internet-Verbindung (Mobilfunk) zum GWA - **nicht über Ihr Heimnetzwerk!**

---

## 📦 A Inbetriebnahme

### 1 Auspacken
1. GL.iNet MT300N-V2 aus der Verpackung nehmen
2. USB-Netzteil (5V) und Micro-USB-Kabel bereitlegen
3. Ethernet-Kabel bereitlegen:
   - **Kabel** für Heimnetzwerk → GL.iNet
   - **Kabel** für GL.iNet → SMGW

### 2 Gerät kennenlernen

**Vorderseite des GL.iNet MT300N-V2:**
```
┌─────────────────────────┐
│  [LED]    [Reset-Knopf] │
│                         │
│   GL.iNet MT300N-V2     │
└─────────────────────────┘
```

**Rückseite - Ports:**
```
[Micro-USB]  [WAN]          [LAN]
   Power      Heimnetz      SMGW
```

**Port-Erklärung:**
- **Micro-USB:** Stromversorgung (Netzteil anschließen)
- **WAN-Port:** Verbindung zum Heimnetzwerk
- **LAN-Port:** Verbindung zum SMGW

### 3 Mit Router-WLAN verbinden

1. **Warten Sie ca. 30-60 Sekunden** nach dem Einschalten
2. Öffnen Sie die **WLAN-Liste** auf Ihrem Laptop/PC
3. Suchen Sie nach einem Netzwerk namens: **GL-MT300N-xxx** (xxx = Zahlen/Buchstaben)
4. **Verbinden** Sie sich damit
   - Beim ersten Mal: **Passwort auf Rückseite GL-MT300N-xxx ablesen (z.B. "goodlife")!**

### 4 Router-Oberfläche öffnen & Passwort setzen

1. **Browser öffnen** (Chrome, Firefox, Edge, etc.)
2. Adresse eingeben: **`http://192.168.8.1`**
3. **Willkommens-Seite erscheint:**
   - Sprache: **Deutsch** wählen
   - **Weiter** klicken

4. **Admin-Passwort festlegen:**
   ```
   Neues Passwort: [Ihr sicheres Passwort]
   Passwort bestätigen: [Nochmal eingeben]
   ```
   - ⚠️ **WICHTIG:** Dieses Passwort UNBEDINGT notieren!
   - **Übernehmen** klicken

5. **Login:** Jetzt mit dem neuen Passwort anmelden

**✓ Checkpoint:** Sie sind jetzt im GL.iNet Admin-Interface

### 5 Ethernet-Verbindung herstellen

**WICHTIG:** Wir konfigurieren ALLES am Arbeitsplatz, bevor wir zum Zählerschrank gehen!

1. **Im GL.iNet Interface:**
   - **"Internet"** sollte bereits im linken Menü ausgewählt sein
   - Sie sehen die Optionen: Ethernet, Repeater, Tethering, Mobilfunknetz

2. **Ethernet ist bereits vorausgewählt:**
   - Sie sehen die Meldung: **"Kein Kabel mit WAN Anschluss erkannt"**
   - Das ist normal - das Kabel ist noch nicht eingesteckt
   - **NICHT** auf "Repeater" klicken!

3. **Ethernet-Kabel JETZT anschließen:**
   - Nehmen Sie ein **Ethernet-Kabel**
   - Stecken Sie es in den **WAN-Port** des GL.iNet
   - Als WAN konfiguriert lassen!
   - Andere Ende: In einen **LAN-Port der Fritzbox** oder einem **Switch**
   - Falls Ihre Fritzbox nicht in Reichweite ist: Verwenden Sie ein langes Kabel oder einen Switch

4. **Warten Sie 10-20 Sekunden:**
   - Die Seite aktualisiert sich automatisch
   - Es erscheint: **"Verbunden"** ✓
   - Sie sehen jetzt Ihre Netzwerkdaten:
     ```
     IP-Adresse: 192.168.0.119  (Beispiel - Ihre kann anders sein!)
     Gateway:    192.168.0.1
     Protokoll:  DHCP
     ```

**✓ Checkpoint:** Ethernet-Verbindung steht, GL.iNet hat Internet und eine IP-Adresse

### 6 LuCI installieren (ZWINGEND ERFORDERLICH!)

**⚠️ WICHTIG:** Wir brauchen LuCI für die Firewall-Konfiguration! LuCI ist **NICHT vorinstalliert** und braucht Internet zur Installation!

**Deshalb installieren wir LuCI JETZT (solange Internet vorhanden ist):**

**Im GL.iNet Interface:**

1. **"Mehr Einstellungen"** öffnen (links im Menü)

2. **Klicken Sie auf "Erweiterte Einstellungen"** oder **"LuCI Admin Panel"**

3. **Sie sehen eine Meldung:**
   ```
   "Erweiterte Einstellungen mit LuCI anpassen"
   "LuCI-Pakete sind unbedingt erforderlich..."
   ```
   
4. **Klicken Sie auf den blauen Button: "Jetzt installieren"**

5. **Warten Sie ca. 5-10 Minuten:**
   - Der Router lädt LuCI aus dem Internet herunter
   - Ein Fortschrittsbalken erscheint

6. **Nach der Installation:**
   - Die Seite lädt neu oder zeigt "Installation erfolgreich"
   - Sie können jetzt LuCI nutzen
   - **Klicken Sie erneut auf "LuCI Admin Panel"**
   - Ein neues Browser-Tab öffnet sich mit dem LuCI-Interface

7.  Firewall-Regel erstellen für Admin-Zugriff erstellen für den Zugriff vom Heimnetzwerk auf das die Admin-Oberfläche
   - In LuCI: "Network" → "Firewall" → "Traffic Rules"
   - Name: Allow-Web-WAN
     - Protocol: TCP
     - Source zone: wan
     - Destination zone: Device (input)
     - Destination port: 80
     - Action: accept

### 7 IP-Adresse im Heimnetz einrichten

**⚠️ KRITISCH:** Die IP-Adresse muss fest sein, sonst funktioniert Home Assistant nach einem Neustart nicht mehr!

Sie sehen aktuell im GL.iNet Interface:
```
IP-Adresse: 192.168.0.119  (Beispiel - Ihre kann anders sein!)
Gateway:    192.168.0.1
Protokoll:  DHCP
```

**Notieren Sie diese IP jetzt - Sie brauchen sie später!**
```
GL.iNet WAN-IP: _______________ (z.B. 192.168.0.119)
```

**Alternativ: DHCP-Reservation in der Fritzbox einrichten:**

1. **Neuen Browser-Tab öffnen:**
   - URL: `http://fritz.box` oder `http://192.168.0.1`
   - Mit Fritzbox-Passwort anmelden

2. **Netzwerkgeräte finden:**
   - **Heimnetz** → **Netzwerk** → **Netzwerkverbindungen**
   - Suchen Sie nach **"GL-MT300N-V2"** oder **"GL.iNet"**
   - Sie sehen die aktuelle IP (z.B. 192.168.0.119)

3. **Statische IP-Zuweisung aktivieren:**
   - Klicken Sie auf das **Bearbeiten-Symbol** (Bleistift) ✏️ neben dem Gerät
   - Haken setzen: ✅ **"Diesem Netzwerkgerät immer die gleiche IPv4-Adresse zuweisen"**
   - **OK** oder **Übernehmen** klicken

4. **Fertig! ✅**
   - Der GL.iNet bekommt jetzt bei jedem Neustart die gleiche IP
   - Schließen Sie das Fritzbox-Tab

### 8 LAN-IP des GL.iNet ändern (für SMGW-Netzwerk)

**Im GL.iNet Luci-Interface (http://192.168.0.119):**

1. **"Mehr Einstellungen"** → **"LAN IP"**
2. **Ändern:**
   ```
   Router LAN IP:  10.11.120.1
   Subnetzmaske:   255.255.255.0
   ```
3. **"Speichern und Übernehmen"** klicken
4. **Router startet neu - Warten: 3-5 Minuten** ☕
5. **Nach Neustart:** Öffnen Sie `http://192.168.0.119` und melden Sie sich an

**✓ Checkpoint:** GL.iNet LAN hat jetzt die IP 10.11.120.1. Hier kann man einen PING von Luci (Diagnostics) auf das SMGW probieren


### 8 Firewall mit LuCI konfigurieren

1. **Network** → **Firewall** → Tab **"General Settings"**
2. **Zeile "wan" finden** → **"Edit"** klicken
3. **Runterscrollen zu "Allow forward to destination zones"**
4. **Haken setzen bei: "lan"** ✅
5. **"Save & Apply"** klicken (unten rechts)
6. **Warten: 10-20 Sekunden**

**✓ Checkpoint:** Firewall ist konfiguriert

### 9 Masquerading und Routing für SMGW-Zugriff (KRITISCH!)

**Schritt 1: Masquerading in Zone-Settings aktivieren**

1. **Network** → **Firewall** → **General Settings**
2. **Zeile "wan → lan"** → **"Edit"** klicken
3. **Haken setzen bei "Masquerading"** ✅
4. **"Save"** klicken
5. **Zurück zur Hauptseite, dann "Save & Apply"** klicken (unten rechts)

**Schritt 2: Statische Route hinzufügen**

1. **Network** → **Routing** → **Static IPv4 Routes**
2. **"Add"** klicken
3. **Konfigurieren:**
   - **Interface:** `lan` (wichtig!)
   - **Target:** `10.11.120.0/24`
   - **Gateway:** `0.0.0.0` ODER leer lassen
   - **Metric:** leer lassen oder `0`
4. **"Save"** klicken
5. **"Save & Apply"** klicken (unten rechts)
6. **Warten: 10-20 Sekunden**

**✓ Checkpoint:** Masquerading und Routing sind konfiguriert - das SMGW ist jetzt vom Heimnetzwerk aus erreichbar!


**🎉 PHASE ABGESCHLOSSEN!**

Ihr GL.iNet ist jetzt komplett konfiguriert:
- ✅ Passwort gesetzt
- ✅ Ethernet-WAN verbunden
- ✅ **LuCI installiert** (wichtig!)
- ✅ Feste IP-Adresse (z.B. 192.168.0.119)
- ✅ **Firewall konfiguriert** (Forward-Regeln WAN↔LAN)
- ✅ **Masquerading aktiviert** (`wan → lan` Zone)
- ✅ **Statische Route hinzugefügt** (10.11.120.0/24 über LAN)
- ✅ LAN-IP geändert (10.11.120.1)
- ✅ **WAN-Zugriff aktiviert** (Firewall-Regel "Allow-Web-WAN")

---

## 🔌 Phase 5: SMGW-Zugriff mit Home Assistant Addon testen

**Mit dem SMGW Route Manager Addon entfällt die manuelle Routen-Konfiguration!**

### 5.1 SMGW Route Manager Addon installieren

Siehe die [Hauptanleitung im README](README.md#-installation) für die Installation des Addons.

**Das Addon fügt automatisch die statische Route hinzu:**
```
10.11.120.0/24 via 192.168.0.119
```

### 5.2 SMGW anpingen

Nach Installation des Addons können Sie von Home Assistant aus das SMGW direkt erreichen:

```bash
# Auf Home Assistant OS (via SSH oder Terminal):
ping 10.11.120.2
```

**Erwartetes Ergebnis (ERFOLG):**
```
PING 10.11.120.2 (10.11.120.2): 56 data bytes
64 bytes from 10.11.120.2: seq=0 ttl=64 time=5.123 ms
64 bytes from 10.11.120.2: seq=1 ttl=64 time=4.567 ms
```

**✓ Checkpoint:** SMGW ist von Home Assistant aus erreichbar!

---

## 🏠 Home Assistant Integration einrichten

### 6.1 PPC SMGW Integration nutzen

Nach erfolgreicher Installation des Addons können Sie die [PPC SMGW Integration](https://github.com/klacol/ha-ppc-smgw) verwenden:

```yaml
# configuration.yaml
sensor:
  - platform: ppc_smgw
    host: "10.11.120.2"  # Direkt das SMGW im Router-Netzwerk
    username: "dein_username"
    password: "dein_password"
```

Die Route sorgt dafür, dass Home Assistant das SMGW über den GL.iNet Router erreicht!

### 6.2 SSL-Zertifikatsvalidierung ohne Warnungen (optional)

**Problem:** Das SMGW verwendet ein SSL-Zertifikat mit einem spezifischen Hostnamen (SAN). Bei Zugriff über die IP-Adresse erscheint eine Zertifikatswarnung.

**Lösung:** DNS-Eintrag für den SMGW-Hostnamen konfigurieren.

**Beispiel:** Ihr SMGW hat den Hostnamen `ethe0300186023.sm` im Zertifikat.

#### Option A: Nur für Home Assistant (einfach)

Fügen Sie einen Eintrag zur `/etc/hosts` in Home Assistant OS hinzu:

```bash
# Via SSH oder Terminal
echo "10.11.120.2    ethe0300186023.sm" >> /etc/hosts
```

**Dann in der Integration verwenden:**
```yaml
host: "ethe0300186023.sm"  # statt 10.11.120.2
```

#### Option B: Netzwerkweite Lösung (empfohlen)

Konfigurieren Sie DNS-Einträge für alle Geräte:

→ **[Vollständige DNS-Setup Anleitung](DNS-SETUP.md)** mit allen Optionen:
- Windows Hosts-Datei
- Router DNS-Konfiguration
- GL.iNet als DNS-Server
- Pi-hole Integration

**✓ FERTIG!** Ihr SMGW ist in Home Assistant integriert! 🎉

---

