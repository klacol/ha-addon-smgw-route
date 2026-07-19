# Git Setup für SMGW Route Manager Repository

## GitHub Repository erstellen

### 1. Auf GitHub

1. Gehe zu https://github.com/new
2. Repository-Name: `ha-addon-smgw-route`
3. Description: `Home Assistant Addon für automatische SMGW-Routen über GL.iNet Router`
4. **Public** wählen (damit Home Assistant darauf zugreifen kann!)
5. **NICHT** "Initialize with README" anklicken (haben wir schon!)
6. **Create repository** klicken

### 2. Lokal initialisieren und pushen

```powershell
# In PowerShell
cd c:\Git\klacol\ha-addon-smgw-route

# Git initialisieren
git init

# Alle Dateien hinzufügen
git add .

# Ersten Commit erstellen
git commit -m "Initial commit: SMGW Route Manager Addon + GL.iNet Setup-Anleitung"

# Main Branch
git branch -M main

# Remote hinzufügen (ERSETZE "klacol" mit Ihrem GitHub-Username!)
git remote add origin https://github.com/klacol/ha-addon-smgw-route.git

# Hochladen
git push -u origin main
```

### 3. Repository-Link prüfen

Nach dem Push sollte Ihr Repository unter dieser URL erreichbar sein:
```
https://github.com/klacol/ha-addon-smgw-route
```

## In Home Assistant einbinden

1. **Einstellungen** → **Add-ons** → **Add-on Store**
2. **⋮** (oben rechts) → **Repositories**
3. URL einfügen:
   ```
   https://github.com/klacol/ha-addon-smgw-route
   ```
4. **Hinzufügen** klicken

Das Addon erscheint jetzt im Add-on Store! 🎉

## Spätere Updates

Wenn Sie Änderungen am Addon vornehmen:

```powershell
cd c:\Git\klacol\ha-addon-smgw-route

# Änderungen committen
git add .
git commit -m "Beschreibung der Änderung"

# Hochladen
git push
```

Home Assistant lädt automatisch die neue Version beim nächsten Update-Check!

## Troubleshooting

### Problem: "remote origin already exists"

```powershell
git remote remove origin
git remote add origin https://github.com/klacol/ha-addon-smgw-route.git
```

### Problem: "Authentication failed"

Verwenden Sie ein **Personal Access Token** statt Passwort:
1. GitHub → Settings → Developer settings → Personal access tokens
2. Generate new token (classic)
3. Scope: `repo` aktivieren
4. Token kopieren und als Passwort verwenden

### Problem: "Repository not found"

- Prüfen Sie die URL
- Prüfen Sie, ob das Repository auf GitHub existiert
- Prüfen Sie Ihren GitHub-Usernamen
