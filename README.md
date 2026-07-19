# SMGW Route Manager - Home Assistant Addon

🎯 **Komplettlösung: GL.iNet Router + Automatische Route-Konfiguration für Home Assistant**

Dieses Repository bietet eine **schlüsselfertige Lösung** für die Integration Ihres SMGW (Smart Meter Gateway) in Home Assistant über einen GL.iNet Router als Bridge-Gerät.

## 📦 Was ist enthalten?

### 1. GL.iNet Router Setup-Anleitung
**→ [Vollständige GL.iNet-Anleitung](GL-INET-SETUP.md)**

Schritt-für-Schritt-Anleitung zur Einrichtung des GL.iNet MT300N-V2 Routers als Bridge zwischen Ihrem Heimnetzwerk und dem SMGW.

### 2. Home Assistant Addon
Das **SMGW Route Manager Addon** fügt automatisch die benötigte statische Route in Home Assistant OS hinzu - ohne manuelle Konfiguration!

## 🚀 Features

- ✅ **Komplette Hardware-Lösung** - GL.iNet Router als Bridge zum SMGW
- ✅ **Automatische Route-Konfiguration** in Home Assistant beim Start
- ✅ **Persistent** über Reboots hinweg
- ✅ **Konfigurierbar** über Home Assistant UI
- ✅ **Keine manuelle Netzwerk-Konfiguration** auf Clients nötig
- ✅ **Detaillierte Anleitung** für alle Schritte
- ✅ **Funktioniert out-of-the-box** mit PPC SMGW Integration

## 🎯 Für wen ist das?

- Sie haben ein SMGW (z.B. Theben Smart Energy Connexa) mit eigenem Netzwerk (10.11.120.x)
- Sie möchten das SMGW in Home Assistant integrieren
- Sie suchen eine **einfache, schlüsselfertige Lösung**
- Sie möchten **keine komplizierten Routen** auf jedem Gerät konfigurieren

## 📋 Voraussetzungen

### Hardware
- GL.iNet MT300N-V2 Router (ca. 25-30 €)
- 2× Ethernet-Kabel (1× lang für Heimnetzwerk → Zählerschrank, 1× kurz für Router → SMGW)
- SMGW mit HAN-Zugang (z.B. Theben, PPC)

### Software
- Home Assistant OS (oder Supervised)
- SMGW-Zugangsdaten vom Netzbetreiber

### Netzwerk
- SMGW im privaten Netzwerk des GL.iNet (z.B. 10.11.120.2)
- GL.iNet erreichbar im Home Assistant Netzwerk (z.B. 192.168.0.119)

## 🏗️ Gesamtlösung - Architektur

```
┌─────────────────────────────────┐
│  Home Assistant Server          │
│  + SMGW Route Manager Addon     │
│    (automatische Route)         │
└────────────┬────────────────────┘
             │ Heimnetzwerk
             │ (192.168.0.x)
             ↓
┌────────────────────────────────┐
│  GL.iNet MT300N-V2 Router      │
│  WAN: 192.168.0.119            │  ← Im Heimnetzwerk
│  LAN: 10.11.120.1              │  ← SMGW-Netzwerk
└────────────┬───────────────────┘
             │ Ethernet
             ↓
┌────────────────────────────────┐
│  SMGW (Smart Meter Gateway)    │
│  IP: 10.11.120.2               │
└────────────────────────────────┘
```

## 🚀 Quick Start

### Schritt 1: GL.iNet Router einrichten
Folgen Sie der **[detaillierten GL.iNet-Anleitung](GL-INET-SETUP.md)** für:
- Router-Erstkonfiguration
- Netzwerk-Setup
- Installation im Zählerschrank
- Firewall-Konfiguration

**⏱️ Zeit:** 30-40 Minuten (einmalig)

### Schritt 2: Home Assistant Addon installieren

## 🔧 Installation

### Schritt 1: Repository hinzufügen

1. Öffne Home Assistant
2. Gehe zu **Einstellungen** → **Add-ons**
3. Klicke auf **Add-on Store** (unten rechts)
4. Klicke auf die drei Punkte (⋮) oben rechts
5. Wähle **Repositories**
6. Füge diese URL hinzu:
   ```
   https://github.com/klacol/ha-addon-smgw-route
   ```
7. Klicke auf **Hinzufügen**

### Schritt 2: Addon installieren

1. Suche im Add-on Store nach **"SMGW Route Manager"**
2. Klicke auf das Addon
3. Klicke auf **INSTALLIEREN**
4. Warte, bis die Installation abgeschlossen ist

### Schritt 3: Konfiguration

Vor dem Start des Addons musst du die Netzwerk-Parameter anpassen:

```yaml
smgw_network: "10.11.120.0/24"  # Netzwerk des SMGW hinter dem Router
gateway_ip: "192.168.0.119"      # IP des GL.iNet Routers im HA-Netzwerk
log_level: info
```

**Wichtig:** Passe diese Werte an deine Netzwerk-Konfiguration an!

### Schritt 4: Starten

1. Klicke auf **STARTEN**
2. Prüfe das Log:
   - ✅ "Route added successfully"
   - ✅ "Route is active and working!"
   - ✅ "Gateway is reachable"

## 🎯 Wie funktioniert es?

Das Addon führt beim Start folgende Schritte aus:

1. **Findet die aktive Netzwerk-Verbindung** in Home Assistant OS
2. **Fügt eine statische Route hinzu** mit `nmcli`:
   ```bash
   nmcli connection modify "Supervisor enp2s1" +ipv4.routes "10.11.120.0/24 192.168.0.119"
   ```
3. **Reaktiviert die Verbindung**, damit die Route sofort aktiv ist
4. **Verifiziert** die Route mit `ip route`
5. **Testet** die Verbindung zum Gateway

Die Route bleibt **permanent** erhalten, auch nach Reboots!

## 📊 Konfigurationsparameter

| Parameter | Standard | Beschreibung |
|-----------|----------|--------------|
| `smgw_network` | `10.11.120.0/24` | Das Netzwerk hinter dem GL.iNet Router, in dem sich das SMGW befindet |
| `gateway_ip` | `192.168.0.119` | Die IP-Adresse des GL.iNet Routers im Home Assistant Netzwerk |
| `log_level` | `info` | Log-Level: `debug`, `info`, `warning`, `error` |

## 🔍 Troubleshooting

### Addon startet nicht

Prüfe das Log auf Fehler:
- Ist die Gateway-IP erreichbar?
- Existiert die Netzwerk-Verbindung in Home Assistant OS?

### Route wird nicht angewendet

1. Öffne das Addon-Log
2. Suche nach Fehlermeldungen
3. Prüfe mit SSH auf Home Assistant OS:
   ```bash
   ip route | grep 10.11.120
   ```

### SMGW immer noch nicht erreichbar

1. Prüfe, ob der GL.iNet Router läuft
2. Teste die Verbindung zum Router:
   ```bash
   ping 192.168.0.119
   ```
3. Prüfe die Port-Forwarding-Regeln auf dem Router

## 📝 Verwendung mit PPC SMGW Integration

Nach Installation des Addons kannst du die [PPC SMGW Integration](https://github.com/jannickfahlbusch/ha-ppc-smgw) verwenden:

Die Route sorgt dafür, dass Home Assistant das SMGW über den GL.iNet Router erreicht!

## 🛠️ Entwicklung

### Repository-Struktur

```
ha-addon-smgw-route/
├── README.md              # Diese Datei
├── repository.yaml        # Repository-Manifest
└── smgw-route/           # Addon-Verzeichnis
    ├── config.yaml       # Addon-Konfiguration
    ├── Dockerfile        # Container-Image
    └── run.sh           # Startup-Script
```

### Lokale Tests

```bash
# Repository klonen
git clone https://github.com/klacol/ha-addon-smgw-route.git

# In Home Assistant als lokales Repository einbinden
# Settings → Add-ons → Add-on Store → ⋮ → Repositories
# file:///path/to/ha-addon-smgw-route
```

## 📄 Lizenz

MIT License - siehe [LICENSE](LICENSE)

## 🤝 Beiträge

Issues und Pull Requests sind willkommen!

## 📧 Support

Bei Fragen oder Problemen öffne ein [GitHub Issue](https://github.com/klacol/ha-addon-smgw-route/issues).

---

**Made with ❤️ for Home Assistant und GL.iNet Router Nutzer**
