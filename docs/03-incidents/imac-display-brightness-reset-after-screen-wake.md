# iMac-Display-Helligkeit setzt sich nach Bildschirm-Aus/Wake zurück

## Zusammenfassung

Auf einem älteren iMac mit Ubuntu LTS ließ sich die Bildschirmhelligkeit nicht über die Desktop-Einstellungen regeln. Nach dem Booten wurde die Helligkeit zwar per Workaround abgesenkt, nach dem Ausschalten bzw. erneuten Aktivieren des Bildschirms sprang sie jedoch wieder sichtbar auf ein zu helles Niveau zurück.

Die Ursache war, dass keine nutzbare Linux-Backlight-Schnittstelle vorhanden war und daher nur ein softwareseitiger `xrandr`-Workaround zur Verfügung stand. Dieser musste regelmäßig erneut angewendet werden, weil die Helligkeit des iMac-Displays nach einigen Sekunden wieder überschrieben wurde.

## Betroffene Umgebung

- Gerät: älterer Apple iMac
- Betriebssystem: Ubuntu LTS
- Displays:
  - iMac-Panel auf `DP-3`
  - externer Dell-Monitor auf `DP-2`
- Desktop-Sitzung mit X11 / `xrandr`

## Symptome

- keine funktionierende Helligkeitsregelung in den Ubuntu-Einstellungen
- `ls /sys/class/backlight` lieferte keine nutzbaren Einträge
- nach dem Login wurde die Helligkeit abgesenkt
- nach Bildschirm-Aus oder Wake sprang die Helligkeit wieder hoch
- der erste generische Workaround griff zunächst auf den falschen Monitor und dimmte den Dell statt des iMacs

## Analyse

### 1. Keine echte Backlight-Schnittstelle

Die klassische Linux-Schnittstelle unter `/sys/class/backlight` war nicht vorhanden bzw. nicht nutzbar. Damit fiel die saubere Regelung über echte Hintergrundbeleuchtung aus.

### 2. Vorhandener Workaround war `xrandr`-basiert

Im System war bereits ein älterer Workaround vorhanden:

- Autostart-Eintrag: `~/.config/autostart/set_brightness.desktop`
- Skript: `/usr/local/bin/set_brightness.sh`

Das Skript nutzte `xrandr`, also eine softwareseitige Dimmung statt echter Backlight-Steuerung.

### 3. Falscher Monitor im ersten Ansatz

Bei mehreren angeschlossenen Displays griff ein generischer Ansatz zunächst auf den falschen Ausgang. Sichtbar gedimmt wurde dadurch nur der Dell-Monitor, nicht das integrierte iMac-Display.

### 4. iMac-Panel musste gezielt auf `DP-3` festgelegt werden

Die funktionierende Lösung bestand darin, das Skript gezielt auf den iMac-Ausgang `DP-3` festzulegen.

### 5. Einmaliges Setzen reichte nicht

Selbst wenn `xrandr --output DP-3 --brightness 0.35` sichtbar funktionierte, wurde die Helligkeit nach wenigen Sekunden wieder erhöht. Daher musste der Wert regelmäßig neu gesetzt werden.

## Umsetzung

### Skript

Datei:

```bash
/usr/local/bin/set_brightness.sh
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

## Ergebnis

* die Helligkeit des iMac-Displays wird nach dem Login automatisch abgesenkt
* der Wert wird regelmäßig erneut gesetzt
* der Dell-Monitor bleibt unverändert
* ein alter systemweiter Dienst war für diese Aufgabe ungeeignet und wurde aus dem Weg geräumt

## Verworfen / geprüft

* echte Backlight-Steuerung über `/sys/class/backlight` war nicht nutzbar
* ein systemweiter Dienst schlug fehl, weil `xrandr` dort zu früh bzw. ohne gültige grafische Sitzung lief (`Can't open display :0`)
* ein pauschaler Multi-Monitor-Ansatz dimmte zunächst den falschen Monitor
* eine aggressivere Dauerschleife war am Ende nicht nötig, weil der User-Timer ausreichend stabil funktionierte

## Aktueller Betriebszustand

Die Helligkeitsregelung wird als pragmatischer `xrandr`-Workaround betrieben. Es handelt sich nicht um eine echte Hardware-Backlight-Steuerung, sondern um softwareseitige Dimmung, die regelmäßig erneut angewendet werden muss.
