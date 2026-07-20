# SMGW Route Manager - Komplette Installation

## 📋 Übersicht

Diese Lösung besteht aus **zwei Teilen**:

1. **GL.iNet Router Setup** (Hardware-Bridge zum SMGW)
2. **Home Assistant Addon** (Automatische Routen-Konfiguration)

## ⚡ Quick Start (Gesamtablauf)

### Phase 1: GL.iNet Router einrichten (40 Min)

**→ Folgen Sie der [detaillierten GL.iNet-Anleitung](GL-INET-SETUP.md)**

Das Setup umfasst:
- Router-Erstkonfiguration am Arbeitsplatz
- LuCI-Installation
- Netzwerk-Konfiguration (LAN-IP: 10.11.120.1, WAN-IP: 192.168.0.119)
- Firewall-Setup
- Installation im Zählerschrank
- Verbindung mit SMGW

**✅ Ergebnis:** GL.iNet Router ist betriebsbereit und SMGW ist erreichbar

### Phase 2: Home Assistant Addon installieren (5 Min)

#### 1. Repository hinzufügen

1. Home Assistant öffnen
2. **Einstellungen** → **Add-ons** → **Add-on Store**
3. **⋮** (drei Punkte oben rechts) → **Repositories**
4. URL hinzufügen:
   ```
   https://github.com/klacol/ha-addon-smgw-route
   ```
5. **Hinzufügen** klicken

#### 2. Addon installieren

1. Im Add-on Store nach **"SMGW Route Manager"** suchen
2. Auf das Addon klicken
3. **INSTALLIEREN** klicken
4. Warten (ca. 1-2 Minuten)

#### 3. Konfiguration anpassen

**⚠️ WICHTIG:** Passen Sie die Werte an Ihre Netzwerk-Konfiguration an!

```yaml
smgw_network: "10.11.120.0/24"     # Netzwerk hinter dem GL.iNet Router
gateway_ip: "192.168.0.119"        # WAN-IP des GL.iNet Routers
smgw_ip: "10.11.120.2"             # IP-Adresse des SMGW (für Ping-Test)
log_level: info
```

**Ihre Werte aus der GL.iNet-Anleitung:**
- `gateway_ip`: Die WAN-IP, die Sie in Phase 2.5 notiert haben
- `smgw_network`: Normalerweise `10.11.120.0/24` (Standard bei SMGW)
- `smgw_ip`: Die IP-Adresse Ihres SMGW (normalerweise `10.11.120.2`)

#### 4. Starten und prüfen

1. **STARTEN** klicken
2. **Log** öffnen (Tab oben)
3. Prüfen Sie auf diese Meldungen:
   ```
   [INFO] Route added successfully
   [INFO] ✅ Route is active and working!
   [INFO] Testing connectivity to gateway 192.168.0.119...
   [INFO] ✅ Gateway 192.168.0.119 is reachable
   [INFO] Testing connectivity to SMGW 10.11.120.2...
   [INFO] ✅ SMGW 10.11.120.2 is reachable
   ```

**✅ Fertig!** Das Addon läuft und die Route ist aktiv.

**⚠️ Wenn der SMGW-Ping fehlschlägt:**
- Prüfen Sie, ob der GL.iNet Router läuft (LED leuchtet)
- Prüfen Sie die Firewall-Regel "wan → lan" im GL.iNet
- Prüfen Sie das Ethernet-Kabel zwischen GL.iNet und SMGW

### Phase 3: SMGW-Integration hinzufügen (2 Min)

#### PPC SMGW Integration nutzen

Installieren Sie die [PPC SMGW Integration](https://github.com/klacol/ha-ppc-smgw):

1. **Einstellungen** → **Geräte & Dienste** → **Integration hinzufügen**
2. Nach **"PPC SMGW"** suchen
3. Konfiguration eingeben:
   ```
   Host: 10.11.120.2
   Username: [Ihr SMGW-Username vom Netzbetreiber]
   Password: [Ihr SMGW-Passwort vom Netzbetreiber]
   ```
4. **Absenden** klicken

**💡 Tipp: SSL-Zertifikat ohne Warnung (optional)**

Das SMGW verwendet ein SSL-Zertifikat mit einem spezifischen Hostnamen. Um SSL-Zertifikatswarnungen zu vermeiden, können Sie statt der IP-Adresse den Hostnamen verwenden:

```
Host: ethe0300186023.sm    (statt 10.11.120.2)
```

**⚠️ WICHTIG:** Ersetzen Sie `ethe0300186023.sm` durch den tatsächlichen Hostnamen aus Ihrem SMGW-Zertifikat!

**Voraussetzung:** DNS-Eintrag muss konfiguriert sein.  
→ **[DNS-Setup Anleitung](DNS-SETUP.md)** für Details

**✅ Ergebnis:** SMGW-Sensoren erscheinen in Home Assistant!

---

## 🎉 Das war's!

Ihre komplette Lösung ist jetzt aktiv:

```
✓ GL.iNet Router als Bridge eingerichtet
✓ Route automatisch in Home Assistant konfiguriert
✓ SMGW-Integration funktioniert
✓ Stromverbrauch wird angezeigt
✓ Sensoren aktualisieren sich automatisch
```

## 🔄 Nach einem Home Assistant Update

Das Addon setzt die Route bei jedem Start automatisch neu - **keine manuelle Aktion nötig!**

## 📞 Support

- **GL.iNet Setup-Probleme:** Siehe [Troubleshooting in der GL.iNet-Anleitung](GL-INET-SETUP.md#-häufige-probleme--lösungen)
- **Addon-Probleme:** Öffnen Sie ein [GitHub Issue](https://github.com/klacol/ha-addon-smgw-route/issues)
- **SMGW-Integration-Probleme:** Siehe [PPC SMGW Repository](https://github.com/klacol/ha-ppc-smgw)

**Viel Erfolg! 🚀**
