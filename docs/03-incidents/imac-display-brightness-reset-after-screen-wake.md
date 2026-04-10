# iMac-Display-Helligkeit setzt sich nach Bildschirm-Aus/Wake zurück

## Zusammenfassung

Auf einem älteren iMac mit Ubuntu LTS ließ sich die Bildschirmhelligkeit nicht zuverlässig über die Desktop-Einstellungen regeln. Ein früherer Workaround reduzierte die Helligkeit bereits beim Start über `xrandr`, reichte im Alltag jedoch nicht dauerhaft aus. Nach dem Ausschalten bzw. erneuten Aktivieren des Bildschirms sprang die Helligkeit des iMac-Displays wieder sichtbar auf ein zu helles Niveau zurück.

Die Ursache war, dass keine nutzbare Linux-Backlight-Schnittstelle vorhanden war und deshalb nur ein softwareseitiger `xrandr`-Workaround zur Verfügung stand. Dieser musste nicht nur beim Login, sondern regelmäßig erneut angewendet werden.

## Historie

Ein früherer Stand dieses Repositories dokumentierte bereits einen funktionierenden Helligkeits-Workaround unter:

- `docs/hardware/brightness-fix/README.md`
- `docs/hardware/brightness-fix/set_brightness.sh`

Dieser ältere Ansatz hielt bereits die wesentlichen Grundlagen fest:

- Ubuntu sollte unter **Xorg statt Wayland** laufen
- die Helligkeit wurde per `xrandr` gesetzt
- der relevante iMac-Ausgang war `DP-3`
- ein Skript `set_brightness.sh` wurde beim Start ausgeführt

Im späteren Betrieb zeigte sich jedoch, dass dieser Ansatz nur einen Teil des Problems löste: Die Helligkeit ließ sich zwar nach dem Login absenken, sprang nach Bildschirm-Aus oder Wake aber erneut hoch. Die frühere Dokumentation wurde deshalb in diese Incident-Datei überführt und um den heutigen, alltagstauglichen Stand ergänzt.

## Betroffene Umgebung

- Gerät: älterer Apple iMac
- Betriebssystem: Ubuntu LTS
- Display-Stack: X11 / Xorg
- Displays:
  - iMac-Panel auf `DP-3`
  - externer Dell-Monitor auf `DP-2`

## Symptome

- keine funktionierende Helligkeitsregelung in den Ubuntu-Einstellungen
- `ls /sys/class/backlight` lieferte keine nutzbaren Einträge
- nach dem Login wurde die Helligkeit abgesenkt
- nach Bildschirm-Aus oder Wake sprang die Helligkeit des iMac wieder hoch
- ein generischer Multi-Monitor-Ansatz dimmte zunächst den Dell statt des iMac
- ein alter systemweiter Dienst war für die Aufgabe ungeeignet

## Analyse

### 1. Keine nutzbare Linux-Backlight-Schnittstelle

Die übliche Linux-Schnittstelle unter `/sys/class/backlight` war nicht nutzbar. Damit fiel eine echte Hardware-Backlight-Steuerung aus.

### 2. `xrandr` war der praktikable Workaround

Die Helligkeit ließ sich auf diesem iMac nur softwareseitig per `xrandr` regeln. Das ist keine echte Steuerung der Hintergrundbeleuchtung, sondern ein visueller Dimm-Workaround.

### 3. Xorg war Teil des funktionierenden Setups

Der ältere Workaround dokumentierte bereits, dass die Lösung unter Xorg lief. Diese Voraussetzung blieb für den funktionierenden `xrandr`-Ansatz relevant.

### 4. Der Zielmonitor musste fest auf `DP-3` gelegt werden

Bei mehreren Displays war ein pauschaler Ansatz unzuverlässig. Erst die gezielte Ansprache von `DP-3` dimmte zuverlässig das interne iMac-Display.

### 5. Einmaliges Setzen beim Login reichte nicht

Der frühere Autostart-Ansatz setzte die Helligkeit beim Start korrekt. Im Alltag zeigte sich aber, dass der iMac die Helligkeit nach einigen Sekunden bzw. nach Wake wieder erhöhte. Deshalb musste der Wert regelmäßig neu gesetzt werden.

### 6. Night Light verursachte Konflikte mit dem `xrandr`-Workaround

Während der weiteren Analyse zeigte sich ein Hell-Dunkel-Wechsel des iMac-Displays. Ursache war sehr wahrscheinlich ein Konflikt zwischen GNOME Color Management bzw. Night Light und dem `xrandr`-basierten Helligkeits-Workaround.

Relevante Beobachtungen:

- `org.gnome.SettingsDaemon.Color.service` war aktiv
- `gsd-color` lief in der grafischen Sitzung
- `night-light-enabled` war auf `true`
- `night-light-schedule-automatic` war auf `true`

Nach dem Deaktivieren von Night Light verschwand das Hell-Dunkel-Verhalten.

### 7. Doppelter Autostart wurde bereinigt

Zusätzlich existierte neben dem Timer noch ein doppelter Autostart-Eintrag für den Helligkeits-Workaround. Der benutzerspezifische Eintrag unter `~/.config/autostart/set_brightness.desktop` wurde entfernt, damit nicht mehrere Mechanismen parallel dieselbe Aufgabe übernehmen.

## Umsetzung

### Aktuelles Skript

Datei:

```bash
scripts/set_brightness.sh
````

Inhalt:

```bash
#!/usr/bin/env bash
set -euo pipefail

TARGET_BRIGHTNESS="${1:-0.35}"
export DISPLAY=:0
export XAUTHORITY="/home/stevie/.Xauthority"

sleep 3
xrandr --output DP-3 --brightness "$TARGET_BRIGHTNESS"
```

### User-Service

Datei:

```ini
~/.config/systemd/user/screen-brightness-enforcer.service
```

Inhalt:

```ini
[Unit]
Description=Reapply xrandr brightness for iMac screen
After=graphical-session.target
PartOf=graphical-session.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/set_brightness.sh 0.35
```

### User-Timer

Datei:

```ini
~/.config/systemd/user/screen-brightness-enforcer.timer
```

Inhalt:

```ini
[Unit]
Description=Reapply screen brightness regularly

[Timer]
OnBootSec=20
OnUnitActiveSec=15
Unit=screen-brightness-enforcer.service

[Install]
WantedBy=timers.target
```

### Aktivierung

```bash
systemctl --user daemon-reload
systemctl --user enable --now screen-brightness-enforcer.timer
systemctl --user restart screen-brightness-enforcer.timer
systemctl --user start screen-brightness-enforcer.service
```
## Zusätzliche Bereinigung

Night Light wurde deaktiviert, um Konflikte mit dem xrandr-Workaround zu vermeiden:

```bash
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled false
```
Der doppelte benutzerspezifische Autostart wurde entfernt:

```bash
rm -f ~/.config/autostart/set_brightness.desktop
```

## Ergebnis

* die Helligkeit des iMac-Displays wird nach dem Login automatisch abgesenkt
* der Wert wird regelmäßig erneut gesetzt
* das interne Display auf `DP-3` wird gezielt gedimmt
* der Dell-Monitor bleibt unverändert
* der frühere Login-Workaround wurde nicht verworfen, sondern funktional erweitert

## Verworfen / geprüft

* echte Backlight-Steuerung über `/sys/class/backlight` war nicht nutzbar
* ein systemweiter Dienst schlug fehl, weil `xrandr` dort zu früh bzw. ohne gültige grafische Sitzung lief (`Can't open display :0`)
* ein pauschaler Multi-Monitor-Ansatz dimmte zunächst den falschen Monitor
* eine aggressivere Dauerschleife war am Ende nicht nötig, weil der User-Timer ausreichend stabil funktionierte

## Migration aus der alten Struktur

Die frühere Dokumentation unter `docs/hardware/brightness-fix/` wurde in dieser Datei inhaltlich zusammengeführt.

### Alt

* `docs/hardware/brightness-fix/README.md`
* `docs/hardware/brightness-fix/set_brightness.sh`

### Neu

* `docs/03-incidents/imac-display-brightness-reset-after-screen-wake.md`
* `scripts/set_brightness.sh`

## Aktueller Betriebszustand

Die Helligkeitsregelung wird als pragmatischer `xrandr`-Workaround betrieben. Es handelt sich nicht um eine echte Hardware-Backlight-Steuerung, sondern um softwareseitige Dimmung, die regelmäßig erneut angewendet werden muss.

## Kurzzeitig manuell heller stellen

Wenn du den iMac nur vorübergehend heller brauchst, stoppe zuerst den Timer. Sonst setzt er die Helligkeit kurz darauf wieder auf den Standardwert zurück.

### Temporär heller stellen

```bash
systemctl --user stop screen-brightness-enforcer.timer
xrandr --output DP-3 --brightness 0.60
```

Du kannst den Wert bei Bedarf anpassen, zum Beispiel:

* `0.50` = etwas heller
* `0.60` = merklich heller
* `0.70` = deutlich heller

### Wieder auf Standard zurückstellen

```bash
systemctl --user start screen-brightness-enforcer.timer
/usr/local/bin/set_brightness.sh 0.35
```

### Status prüfen

```bash
systemctl --user status screen-brightness-enforcer.timer
```
