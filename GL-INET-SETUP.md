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

## 🔌 Physische Topologie

```
[Fritzbox/Heimnetzwerk-Router im Haus]
            |
            | Ethernet-Kabel (10-30m)
            ↓
    ╔═══════════════════════════════╗
    ║  Zählerschrank                ║
    ║                               ║
    ║  ┌──[WAN-Port]──────────────┐ ║
    ║  │  GL.iNet MT300N-V2       │ ║
    ║  │  (10.11.120.1)           │ ║
    ║  └──[LAN-Port]──────────────┘ ║
    ║            |                  ║
    ║            | Kurzes Kabel     ║
    ║            ↓                  ║
    ║  ┌───[HAN-Port]─────────────┐ ║
    ║  │  SMGW                    │ ║
    ║  │  (10.11.120.2)           │ ║
    ║  └──────────────────────────┘ ║
    ╚═══════════════════════════════╝
```

**WICHTIG:** 
- **WAN-Port** → Heimnetzwerk
- **LAN-Port** → SMGW

---

## ⚡ Schnellstart (5 Phasen)

```
Phase 1: Auspacken & Hardware vorbereiten          [5 Min]
Phase 2: Komplettkonfiguration am Arbeitsplatz     [30 Min]
        (inkl. LuCI-Installation + 5 Min Wartezeit beim Neustart!)
Phase 3: Installation am Zählerschrank             [5 Min]
Phase 4: Erreichbarkeit testen                     [3 Min]
Phase 5: SMGW-Zugriff testen                       [5 Min]
```

**WICHTIG:** 
- Phase 2 wird komplett am Arbeitsplatz durchgeführt, bevor Sie zum Zählerschrank gehen!
- ⚠️ **LuCI muss installiert werden** - dafür brauchen Sie Internet!
- ⏰ Der Router braucht nach Neustarts **3-5 Minuten** - Geduld ist wichtig!

---

## 📦 Phase 1: Auspacken & Hardware vorbereiten (5 Min)

### 1.1 Auspacken
1. GL.iNet MT300N-V2 aus der Verpackung nehmen
2. USB-Netzteil (5V) und Micro-USB-Kabel bereitlegen
3. Ethernet-Kabel bereitlegen:
   - **Kabel** für Heimnetzwerk → GL.iNet
   - **Kabel** für GL.iNet → SMGW

### 1.2 Gerät kennenlernen

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

### 1.3 Arbeitsplatz vorbereiten

**Für die Erstkonfiguration (am Schreibtisch, nicht im Keller!):**
1. GL.iNet Router auf den Tisch stellen
2. Micro-USB-Kabel anschließen (Netzteil → Steckdose)
3. **NOCH KEINE** Ethernet-Kabel anschließen!
4. Laptop/PC mit WLAN bereitlegen

**✓ Checkpoint:** Router ist eingeschaltet, LED leuchtet

---

## 🔧 Phase 2: Komplettkonfiguration am Arbeitsplatz (30 Min)

**⏰ Diese Phase dauert länger wegen:**
- **LuCI-Installation** (ca. 2 Min)
- **Neustart** nach LAN-IP-Änderung (3-5 Min Wartezeit!)

**📋 Was wir hier machen:**
Wir konfigurieren hier ALLES am Arbeitsplatz, bevor wir zum Zählerschrank gehen - das ist viel bequemer und Sie haben Internet für die LuCI-Installation!

### 2.1 Mit Router-WLAN verbinden

1. **Warten Sie ca. 30-60 Sekunden** nach dem Einschalten
2. Öffnen Sie die **WLAN-Liste** auf Ihrem Laptop/PC
3. Suchen Sie nach einem Netzwerk namens: **GL-MT300N-xxx** (xxx = Zahlen/Buchstaben)
4. **Verbinden** Sie sich damit
   - Beim ersten Mal: **Passwort auf Rückseite GL-MT300N-xxx ablesen (z.B. "goodlife")!**

**Hinweis:** Ihr Internet funktioniert jetzt noch nicht - das ist normal!

### 2.2 Router-Oberfläche öffnen & Passwort setzen

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

### 2.3 Ethernet-Verbindung herstellen

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

### 2.4 LuCI installieren (ZWINGEND ERFORDERLICH!)

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

**✓ Checkpoint:** LuCI ist installiert und funktioniert!

**💡 Warum JETZT?**
- LuCI braucht Internet zur Installation
- Nach der LAN-IP-Änderung (später) funktioniert Internet möglicherweise nicht mehr
- Deshalb: **ZUERST** LuCI installieren, **DANN** weiter konfigurieren!

### 2.5 Feste IP-Adresse einrichten

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

**DHCP-Reservation in der Fritzbox einrichten:**

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

**✓ Checkpoint:** GL.iNet hat eine **feste** IP-Adresse!

### 2.6 Firewall mit LuCI konfigurieren

**⚠️ WICHTIG:** Diese Konfiguration muss JETZT erfolgen (solange LuCI funktioniert)!

**Diese Einstellung ermöglicht den Zugriff vom Heimnetzwerk auf das die Admin-Oberfläche und das SMGW!**

**Im GL.iNet Interface:**

1. **LuCI Admin Panel öffnen:**
   - **"Mehr Einstellungen"** → **"LuCI Admin Panel"**
   - Ein neues Browser-Tab öffnet sich mit dem LuCI-Interface
   - (Falls Anmeldung gefordert: Nutzen Sie Ihr Admin-Passwort von 2.2)

2. **In LuCI:**
   - **"Network"** → **"Firewall"**
   - Sie sehen eine Tabelle mit Firewall-Zonen (wan, lan, etc.)

3. **Firewall-Zone "lan" bearbeiten:**
   - Suchen Sie die Zeile mit der Zone **"lan"**
   - Klicken Sie auf **"Edit"** (Bearbeiten)

4. **Folgende Einstellungen prüfen:**
   
   **Grundeinstellungen (sollten bereits korrekt sein):**
   ```
   Name:    lan
   Input:   accept
   Output:  accept
   Forward: accept
   
   Covered networks: lan
   ```

   **Wichtig - Forward-Regeln:**
   ```
   Allow forward to destination zones:
   - WAN (sollte bereits vorhanden sein)
   
   Allow forward from source zones:
   - unspecified (Standard)
   ```

   **⚠️ WICHTIG:** 
   - Die Forward-Regel "Allow forward to destination zones: WAN" ist entscheidend für den SMGW-Zugriff

5. **WAN-Zone für eingehenden Traffic konfigurieren:**
   - Gehen Sie zurück zur Firewall-Übersicht
   - Klicken Sie auf **"Edit"** bei der Zone **"wan"**
   - Scrollen Sie zu **"Allow forward to destination zones:"**
   - Aktivieren Sie: **"lan"** ✅
   - Dies erlaubt Traffic vom Heimnetzwerk zum SMGW-Netzwerk

6. **"Save & Apply"** klicken
   - Warten Sie ca. 10-20 Sekunden
   - Die Einstellungen werden übernommen

**Was macht das?**
- **LAN → WAN Forward:** Erlaubt Weiterleitung von LAN (SMGW) → WAN (Heimnetzwerk) für ausgehenden Traffic
- **WAN → LAN Forward:** Erlaubt Weiterleitung von WAN (Heimnetzwerk) → LAN (SMGW) für eingehenden Traffic von Home Assistant
- **accept/accept/accept auf LAN:** Erlaubt alle Verbindungen innerhalb der LAN-Zone
- **Reines Routing:** Keine Adressübersetzung, alle Pakete behalten ihre Original-IP-Adressen

**✓ Checkpoint:** Firewall ist konfiguriert!

**💡 Warum JETZT?**
- Wir haben LuCI gerade installiert
- Nach der LAN-IP-Änderung (nächster Schritt) könnte der Zugriff komplizierter werden
- Deshalb: **Firewall JETZT konfigurieren!**

### 2.7 LAN-IP des GL.iNet ändern (für SMGW-Netzwerk)

**JETZT KOMMT DER WICHTIGE TEIL!**

Das SMGW hat ein eigenes Netzwerk (10.11.120.x). Der GL.iNet muss als Bridge zwischen Ihrem Heimnetzwerk und dem SMGW-Netzwerk fungieren.

**Zurück im GL.iNet Interface (http://192.168.8.1 oder http://192.168.0.119):**

1. **Mehr Einstellungen öffnen:**
   - Klicken Sie links auf **"Mehr Einstellungen"** oder **"More Settings"**
   - Dann auf **"LAN IP"** oder **"LAN"**

2. **Sie sehen die aktuelle LAN-Konfiguration:**
   ```
   Router LAN IP: 192.168.8.1
   Subnetzmaske: 255.255.255.0
   ```

3. **ÄNDERN Sie dies zu:**
   ```
   Router LAN IP:  10.11.120.1
   Subnetzmaske:   255.255.255.0
   ```

4. **Speichern und Übernehmen klicken**

5. **⚠️ Router startet neu** - **GEDULD IST GEFRAGT!**
   - Der Neustart dauert **3-5 Minuten** (nicht nur 1 Minute!)
   - **LED blinkt** → Neustart läuft
   - **LED leuchtet dauerhaft** → Neustart fertig
   - ☕ **Tipp:** Holen Sie sich einen Kaffee, das dauert wirklich!

6. **Nach dem Neustart (nach ca. 3-5 Minuten!):**
   - Sie sind möglicherweise nicht mehr im GL.iNet Interface
   - Das ist normal! Der Router hat jetzt eine neue LAN-IP (10.11.120.1)
   - Sie erreichen ihn weiterhin über die **WAN-IP**: `http://192.168.0.119`
   - Öffnen Sie: **`http://192.168.0.119`** und melden Sie sich an
   - **Falls nicht erreichbar:** Warten Sie weitere 2 Minuten und versuchen es erneut!

**✓ Checkpoint:** GL.iNet LAN hat jetzt die IP 10.11.120.1

### 2.8 WAN-Zugriff auf Admin-Interface aktivieren (WICHTIG!)

**⚠️ Standardmäßig ist der Zugriff von der WAN-Seite (http://192.168.0.119) BLOCKIERT!**

Wir müssen das aktivieren, damit Sie später vom Haus aus auf den Router zugreifen können:

**⚠️ HINWEIS:** Im GL.iNet Interface gibt es KEINE Option für WAN-Zugriff! Sie **müssen** LuCI verwenden!

**In LuCI (EINZIGE funktionierende Methode):**

1. **LuCI Admin Panel öffnen:**
   - Im GL.iNet Interface: **"Mehr Einstellungen"** → **"LuCI Admin Panel"**
   - Falls Anmeldung gefordert: Nutzen Sie Ihr Admin-Passwort

2. **Firewall-Regel erstellen:**
   - Gehen Sie zu: **"Network"** → **"Firewall"** → **"Traffic Rules"**
   - Klicken Sie unten auf **"Add"** (Neue Regel hinzufügen)

3. **Regel konfigurieren:**
   ```
   Name: Allow-Web-WAN
   Protocol: TCP
   Source zone: wan
   Destination zone: Device (input)
   Destination port: 80
   Action: accept
   ```
   
   **Schritt für Schritt:**
   - **Name:** Geben Sie ein: `Allow-Web-WAN`
   - **Protocol:** Wählen Sie: `TCP`
   - **Source zone:** Wählen Sie: `wan`
   - **Destination zone:** Wählen Sie: `Device (input)` oder `input`
   - **Destination port:** Geben Sie ein: `80`
   - **Action:** Wählen Sie: `accept` (sollte Standard sein)

4. **⚠️ WICHTIG: Speichern Sie die Änderungen!**
   - Klicken Sie auf **"Save & Apply"** (unten rechts)
   - **Warten Sie 10-20 Sekunden** bis die Änderungen übernommen werden
   - Oben rechts sollte "UNSAVED CHANGES" verschwinden

**Was macht diese Regel?**
- Erlaubt eingehende TCP-Verbindungen auf Port 80 von der WAN-Seite (Heimnetzwerk)
- So können Sie vom Heimnetzwerk aus auf das Admin-Interface zugreifen

**⚠️ Sicherheitshinweis:**
- Diese Einstellung erlaubt den Zugriff auf das Admin-Interface vom Heimnetzwerk
- Nutzen Sie ein **starkes Passwort** (haben Sie in 2.2 gesetzt!)
- Die Fritzbox schützt den Router vor dem Internet

**✓ Checkpoint:** WAN-Zugriff ist aktiviert - Sie können jetzt von überall im Heimnetzwerk auf http://192.168.0.119 zugreifen!

### 2.9 DHCP für SMGW-Netzwerk anpassen

**WICHTIG:** Das SMGW hat eine feste IP (**10.11.120.2**). Der DHCP-Server darf diese IP nicht vergeben!

**Im GL.iNet Interface (http://192.168.0.119):**

1. **"Mehr Einstellungen"** → **"LAN IP"** → **"DHCP Server"**

2. **DHCP-Bereich einschränken:**
   ```
   DHCP aktiviert:    ✓ Ja
   Start-IP:          10.11.120.10
   End-IP:            10.11.120.50
   Lease-Zeit:        12h (Standard)
   ```
   - **Wichtig:** Die SMGW-IP **10.11.120.2** liegt NICHT in diesem Bereich!
   - **Speichern** klicken

**Warum?** Die SMGW-IP **10.11.120.2** ist fest vorgegeben und darf nicht durch DHCP blockiert werden!

**✓ Checkpoint:** DHCP ist korrekt konfiguriert

---

**🎉 PHASE 2 ABGESCHLOSSEN!**

Ihr GL.iNet ist jetzt komplett konfiguriert:
- ✅ Passwort gesetzt
- ✅ Ethernet-WAN verbunden
- ✅ **LuCI installiert** (wichtig!)
- ✅ Feste IP-Adresse (z.B. 192.168.0.119)
- ✅ **Firewall konfiguriert** (mit LuCI)
- ✅ LAN-IP geändert (10.11.120.1)
- ✅ **WAN-Zugriff aktiviert** (Firewall-Regel "Allow-Web-WAN" in LuCI erstellt)
- ✅ DHCP konfiguriert

**Sie können das Ethernet-Kabel nun abstecken** und zum Zählerschrank gehen!

---

## 🏠 Phase 3: Installation am Zählerschrank (5 Min)

### 3.1 Was Sie zum Zählerschrank mitnehmen

**Nehmen Sie mit:**
- ✅ GL.iNet Router (vom Arbeitsplatz abstecken)
- ✅ Micro-USB-Kabel + Netzteil  
- ✅ **Langes Ethernet-Kabel** (10-30m) - von Fritzbox zum Zählerschrank
  - Falls noch nicht verlegt: Jetzt verlegen!
  - Falls bereits verlegt: Super, weiter geht's!
- ✅ **Kurzes Ethernet-Kabel** (0,5-2m) - für GL.iNet → SMGW
- ✅ Optional: Ihr Smartphone (um die IP später zu finden)

### 3.2 Am Zählerschrank verkabeln

**WICHTIG: Achten Sie auf die richtigen Ports!**

```
Fritzbox ─[Langes Kabel]─ [WAN/blau] GL.iNet [LAN/gelb] ─[Kurzes Kabel]─ SMGW
```

**Schritt-für-Schritt:**

1. **Stromversorgung:**
   - GL.iNet mit Micro-USB-Kabel am Netzteil verbinden
   - Netzteil in Steckdose im/am Zählerschrank stecken
   - Warten bis **LED leuchtet** (ca. 30 Sekunden)

2. **WAN-Verbindung (Internet vom Heimnetzwerk):**
   - **Langes Ethernet-Kabel** vom Heimnetzwerk nehmen
   - In den **WAN-Port (blau)** des GL.iNet stecken
   - Das andere Ende sollte in der Fritzbox stecken

3. **LAN-Verbindung (zum SMGW):**
   - **Kurzes Ethernet-Kabel** nehmen
   - Eine Seite: **LAN-Port (gelb)** des GL.iNet
   - Andere Seite: **HAN-Port** des SMGW
     - Der HAN-Port ist meist beschriftet
     - Bei Theben SMGW: Meist der rechte Ethernet-Port

**✓ Checkpoint:** Alle 3 Kabel verbunden (Strom + WAN + LAN), LED leuchtet

**🎉 PHASE 3 ABGESCHLOSSEN!**

Ihr GL.iNet ist jetzt physisch im Zählerschrank installiert und mit dem SMGW verbunden!

---

## ✅ Phase 4: Erreichbarkeit testen (3 Min)

**Jetzt testen wir, ob der GL.iNet aus Ihrem Heimnetzwerk erreichbar ist.**

### 4.1 GL.iNet aus der Ferne erreichen

**An Ihrem PC (im Haus):**

1. **Mit Ihrem normalen Heim-WLAN verbinden** (Ihr übliches WLAN, nicht GL.iNet!)

2. **Browser öffnen**

3. **Adresse eingeben:** 
   - `http://[Ihre notierte IP]`
   - Beispiel: **`http://192.168.0.119`**
   - (Die IP, die Sie in Phase 2.5 notiert haben!)

4. **Mit Admin-Passwort anmelden**

**Erwartetes Ergebnis:**
- ✅ Sie sehen das GL.iNet Interface
- ✅ Sie sind eingeloggt
- ✅ Alles wie vorher am Arbeitsplatz

**Funktioniert es nicht?** 

Prüfen Sie:
- ❌ **WAN-Zugriff aktiviert?** (Phase 2.8: Firewall-Regel "Allow-Web-WAN" erstellt und gespeichert?)
- ❌ Ist GL.iNet eingeschaltet (LED an)?
- ❌ Ist das lange Ethernet-Kabel richtig eingesteckt (WAN-Port = blau)?
- ❌ Ist das Kabel in der Fritzbox eingesteckt?
- ❌ Warten Sie 1-2 Minuten und versuchen es erneut

**→ Falls WAN-Zugriff nicht funktioniert:** Siehe **Problem 4** im Troubleshooting-Bereich!

**Alternative: Fritzbox-Interface prüfen**
1. Öffnen Sie: `http://fritz.box`
2. **Heimnetz** → **Netzwerk** → **Netzwerkverbindungen**
3. Ist der **GL-MT300N-V2** in der Liste?
4. Hat er die erwartete IP?

**✓ Checkpoint:** GL.iNet ist aus Ihrem Heimnetzwerk erreichbar!

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

**✓ FERTIG!** Ihr SMGW ist in Home Assistant integriert! 🎉

---

## 🔧 Häufige Probleme & Lösungen

### Problem 1: "Router reagiert nicht nach Neustart / Neustart dauert ewig"

**⏰ Das ist NORMAL!**

Der GL.iNet MT300N-V2 braucht nach einem Neustart **3-5 Minuten**, bis er vollständig erreichbar ist!

**Symptome:**
- LED blinkt lange
- Interface nicht erreichbar
- Sie denken, etwas ist kaputt

**Lösung:**
- ☕ **Geduld!** Warten Sie wirklich 5 Minuten
- Holen Sie sich einen Kaffee
- **NICHT** den Stecker ziehen oder Reset drücken!
- Nach 3-5 Minuten sollte die LED dauerhaft leuchten
- Dann ist der Router erreichbar

**Typische Neustarts:**
- Nach LAN-IP Änderung (Phase 2.7): **3-5 Minuten**
- Nach Firewall-Änderungen: **3-5 Minuten**
- Nach Stromausfall: **3-5 Minuten**

### Problem 2: "LuCI-Installation fehlgeschlagen oder LuCI nicht verfügbar"

**⚠️ KRITISCH:** Ohne LuCI können Sie die Firewall nicht konfigurieren!

**Symptome:**
- Button "Jetzt installieren" reagiert nicht
- Installation bricht ab
- "LuCI Admin Panel" öffnet sich nicht
- Fehler: "Package download failed"

**Ursachen & Lösungen:**

**1. Keine Internet-Verbindung:**
- ❌ **Häufigster Fehler!** GL.iNet hat kein Internet
- Prüfen Sie: Ist Ethernet-Kabel am **WAN-Port (blau)** eingesteckt?
- Prüfen Sie: Im GL.iNet Interface unter "Internet" → Status "Verbunden"?
- **Lösung:** Ethernet-Verbindung prüfen (Phase 2.3 wiederholen)

**2. Download-Server nicht erreichbar:**
- GL.iNet Download-Server temporär überlastet
- **Lösung:** 5-10 Minuten warten und erneut versuchen

**3. Firewall im Heimnetzwerk blockiert:**
- Fritzbox oder Firewall blockiert Downloads
- **Lösung:** Temporär Firewall-Einstellungen prüfen

**4. LuCI wurde bereits installiert:**
- Klicken Sie auf "LuCI Admin Panel"
- Wenn es sich öffnet → **LuCI ist bereits da!** ✅
- Weiter mit Phase 2.6 (Firewall-Konfiguration)

**Alternative (falls LuCI absolut nicht installierbar):**
- ⚠️ **Ohne LuCI wird es sehr kompliziert!**
- Sie müssten die Firewall per SSH konfigurieren (für Experten)
- **Empfehlung:** Firewall-Problem im Heimnetzwerk beheben und LuCI installieren

**💡 Tipp:** LuCI MUSS funktionieren! Ohne LuCI funktioniert die SMGW-Integration nicht!

### Problem 3: "Ping funktioniert nicht - Zeitüberschreitung"

**Mögliche Ursachen:**

1. **Addon nicht gestartet:**
   - Prüfen Sie das Addon-Log in Home Assistant
   - Suchen Sie nach "✅ Route is active and working!"

2. **Falsche Gateway-IP im Addon:**
   - Prüfen Sie die Addon-Konfiguration
   - Gateway-IP muss mit der GL.iNet WAN-IP übereinstimmen

3. **Firewall auf GL.iNet nicht korrekt konfiguriert:**
   - Wiederholen Sie Phase 2.6 (Firewall-Einstellungen)

### Problem 4: "GL.iNet Admin-Interface über WAN-IP nicht erreichbar"

**Symptome:**
- `http://192.168.0.119` (WAN-IP) funktioniert **nicht**
- Timeout oder "Verbindung fehlgeschlagen"
- `http://10.11.120.1` (LAN-IP) funktioniert aber (wenn direkt verbunden)

**Ursache:**
- ❌ **WAN-Zugriff ist nicht aktiviert!** (Phase 2.8 vergessen)

**Lösung:**

1. **Verbinden Sie sich mit dem GL.iNet:**
   - **Option A:** Per WiFi mit dem GL.iNet WLAN verbinden (GL-MT300N-xxx)
   - **Option B:** PC per Ethernet-Kabel an **LAN-Port (gelb)** anschließen
     - PC-IP manuell setzen: `10.11.120.50` / `255.255.255.0` / Gateway: `10.11.120.1`
   - Browser öffnen: `http://10.11.120.1`

2. **LuCI öffnen:**
   - Im GL.iNet Interface: **"Mehr Einstellungen"** → **"LuCI Admin Panel"**
   - Ein neues Tab öffnet sich mit LuCI

3. **Firewall-Regel für WAN-Zugriff erstellen:**
   - In LuCI: **"Network"** → **"Firewall"** → **"Traffic Rules"**
   - Klicken Sie auf **"Add"** (unten)
   - Konfigurieren Sie:
     ```
     Name: Allow-Web-WAN
     Protocol: TCP
     Source zone: wan
     Destination zone: Device (input)
     Destination port: 80
     Action: accept
     ```
   - ⚠️ **WICHTIG:** Klicken Sie auf **"Save & Apply"** und warten Sie 10-20 Sekunden!

4. **Jetzt sollte `http://192.168.0.119` funktionieren!**

### Problem 5: "Home Assistant kann SMGW nicht erreichen"

**Checkliste:**

1. **Addon läuft?**
   ```
   # Addon-Log prüfen
   [INFO] ✅ Route is active and working!
   ```

2. **Von HA-Server aus Ping möglich?**
   ```bash
   ping -c 4 10.11.120.2
   ```

3. **Route aktiv?**
   ```bash
   ip route | grep 10.11.120
   # Sollte zeigen: 10.11.120.0/24 via 192.168.0.119
   ```

4. **Integration neu hinzufügen:**
   - Alte Integration löschen
   - Neu hinzufügen mit korrekter URL: `https://10.11.120.2`

---

## 📋 Zusammenfassung - Was Sie erreicht haben

```
✓ GL.iNet MT300N-V2 ausgepackt und eingerichtet
✓ Ethernet-WAN-Verbindung konfiguriert (kein WLAN nötig!)
✓ Feste IP-Adresse eingerichtet (DHCP-Reservation oder statisch)
✓ GL.iNet am Zählerschrank installiert
✓ SMGW-Netzwerk (10.11.120.x) konfiguriert
✓ Firewall für SMGW-Zugriff eingerichtet
✓ SMGW Route Manager Addon installiert
✓ SMGW erfolgreich angepingt
✓ Home Assistant Integration hinzugefügt
✓ Stromverbrauch in Home Assistant sichtbar!
```

**Ihre Netzwerk-Topologie:**

```
┌─────────────────────────────────┐
│  Home Assistant Server          │
│  (z.B. 192.168.0.100)           │
│  + SMGW Route Manager Addon     │
│    (Route: 10.11.120.0/24       │
│     via 192.168.0.119)          │
└────────────┬────────────────────┘
             │
        ┌────┴─────┐
        │ Heim-    │
        │ Router   │
        └────┬─────┘
             │
      ╔══════╧═══════════╗ Ethernet (10-20m)
      ║     Keller       ║
      ╚═════════╤════════╝
                │
      ┌─────────┴──────────┐
      │ GL.iNet MT300N-V2  │
      │ WAN: 192.168.0.119 │
      │ LAN: 10.11.120.1   │
      └─────────┬──────────┘
                │ Ethernet (0,5-2m)
      ┌─────────┴──────────┐
      │ SMGW               │
      │ IP: 10.11.120.2    │
      └────────────────────┘
```

---

## 🎯 Nächste Schritte

### Home Assistant Automationen

Jetzt können Sie Automationen erstellen, z.B.:

**Beispiel: Benachrichtigung bei hohem Verbrauch**
```yaml
automation:
  - alias: "Hoher Stromverbrauch"
    trigger:
      - platform: numeric_state
        entity_id: sensor.smgw_current_power
        above: 3000  # 3000 Watt
    action:
      - service: notify.mobile_app
        data:
          message: "Achtung! Stromverbrauch über 3 kW!"
```

**Beispiel: Tägliche Verbrauchsstatistik**
```yaml
sensor:
  - platform: template
    sensors:
      daily_energy_cost:
        friendly_name: "Tägliche Stromkosten"
        unit_of_measurement: "€"
        value_template: >
          {{ (states('sensor.smgw_total_energy') | float * 0.30) | round(2) }}
```

### Energy Dashboard

1. **Einstellungen** → **Dashboards** → **Energie**
2. **Stromverbrauch hinzufügen**
3. Sensor auswählen: `sensor.smgw_total_energy`
4. Strompreis eingeben (z.B. 0,30 €/kWh)

---

## 📞 Support & Weitere Hilfe

- **GitHub Issues:** https://github.com/klacol/ha-addon-smgw-route/issues
- **Home Assistant Community:** https://community.home-assistant.io/
- **GL.iNet Forum:** https://forum.gl-inet.com/

**Viel Erfolg mit Ihrem Smart Meter Gateway! 🎉**
