
# iMac16,2 Bildschirmhelligkeit unter Ubuntu 22.04 LTS einstellen

## Projektübersicht

In diesem Projekt wird beschrieben, wie die Bildschirmhelligkeit auf einem **Intel iMac16,2** unter **Ubuntu 22.04 LTS** gesteuert werden kann. Da die Standardmethoden zur Helligkeitsanpassung unter Wayland nicht funktionierten, wurde eine Lösung gefunden, die Helligkeit unter Xorg über den Befehl `xrandr` zu steuern und diese Lösung dauerhaft zu implementieren.

## Voraussetzungen

- Intel iMac16,2 mit Ubuntu 22.04 LTS
- Anmeldung unter Xorg (Ubuntu auf Xorg)
- Grundlegende Kenntnisse in der Verwendung des Terminals
- `xrandr` installiert (standardmäßig vorhanden)

## Schritte zur Lösung

### 1. Überprüfung des Grafikservers
Überprüfe, ob Wayland oder Xorg als Grafikserver verwendet wird:
```bash
echo $XDG_SESSION_TYPE
```
Die Ausgabe sollte `x11` anzeigen, um sicherzustellen, dass Xorg verwendet wird.

Falls Wayland verwendet wird, melde dich von deinem System ab und wähle auf dem Anmeldebildschirm **"Ubuntu auf Xorg"** aus.

### 2. Anpassung der Bildschirmhelligkeit über `xrandr`

Führe im Terminal den folgenden Befehl aus, um den Namen des verbundenen Displays zu ermitteln:

```bash
xrandr --verbose
```

In dieser Anleitung wird das Display als `DP-3` erkannt. Um die Helligkeit anzupassen, führe diesen Befehl aus:

```bash
xrandr --output DP-3 --brightness 0.7
```

Der Wert `0.7` kann entsprechend angepasst werden (zwischen 0.1 und 1.0), um die gewünschte Helligkeit zu erreichen.

### 3. Dauerhafte Lösung: Autostart-Skript

Um die Helligkeitsanpassung bei jedem Systemstart automatisch durchzuführen, kann ein Skript erstellt werden:

#### Erstellen des Skripts:
```bash
sudo nano /usr/local/bin/set_brightness.sh
```

Füge folgenden Inhalt in das Skript ein:

```bash
#!/bin/bash
xrandr --output DP-3 --brightness 0.7
```

Speichere die Datei und mache das Skript ausführbar:

```bash
sudo chmod +x /usr/local/bin/set_brightness.sh
```

#### Autostart-Konfiguration:
Erstelle eine `.desktop`-Datei, um das Skript beim Systemstart auszuführen:

```bash
sudo nano /etc/xdg/autostart/set_brightness.desktop
```

Füge den folgenden Inhalt hinzu:

```ini
[Desktop Entry]
Type=Application
Exec=/usr/local/bin/set_brightness.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Set Brightness
Comment=Set screen brightness at startup
```

Speichere die Datei. Bei jedem Neustart wird die Bildschirmhelligkeit nun automatisch angepasst.

## Fazit

Da die Helligkeitsregelung auf diesem iMac-Modell unter Wayland nicht verfügbar war, bietet die Lösung mit `xrandr` unter Xorg eine funktionierende Alternative. Diese Methode ist dauerhaft implementiert, indem ein Autostart-Skript verwendet wird, das die Helligkeit automatisch anpasst.
