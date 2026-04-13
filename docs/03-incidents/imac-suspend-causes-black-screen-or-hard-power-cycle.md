# iMac-Suspend führt zu Schwarzbild, Absturz oder hartem Power-Cycle

## Zusammenfassung

Auf einem älteren iMac mit Ubuntu LTS führte das Auslösen von Suspend/Bereitschaft wiederholt zu einem instabilen Zustand. Der Rechner fiel nicht sauber in den Ruhemodus und wachte nicht zuverlässig wieder auf. Teilweise war danach ein langer Druck auf den Einschaltknopf nötig, um das Gerät hart auszuschalten, bevor es erneut gestartet werden konnte.

Sowohl der Suspend-Modus `deep` als auch `s2idle` wurden getestet. Keiner der beiden Modi funktionierte stabil. Suspend wurde deshalb bewusst deaktiviert.

## Betroffene Umgebung

- Gerät: älterer Apple iMac
- Betriebssystem: Ubuntu LTS
- Kernel zeigte verfügbare Sleep-Zustände:

```text
freeze mem disk
````

* `mem_sleep` zeigte:

```text
s2idle [deep]
```

Das bedeutete: `deep` war standardmäßig aktiv.

## Symptome

* Rechner fuhr beim Versuch von Bereitschaft/Suspend nicht sauber in einen stabilen Schlafzustand
* nach dem Suspend-Versuch blieb das Bild schwarz oder das System war nicht normal reaktivierbar
* zum Wiederstart war teilweise ein langer Druck auf den Einschaltknopf nötig
* in einzelnen Fällen wirkte es so, als sei der Rechner statt in Bereitschaft eher abgestürzt oder hart weggekippt

## Analyse

### 1. `deep` war aktiv und schlug fehl

Die Diagnose zeigte, dass `deep` als aktiver `mem`-Modus verwendet wurde. Im Journal war zu sehen:

* `The system will suspend now!`
* `Performing sleep operation 'suspend'...`
* `PM: suspend entry (deep)`

Danach erfolgte kein sauber dokumentierter Resume-Pfad.

### 2. Test mit `s2idle` brachte keine Besserung

Es wurde testweise temporär umgeschaltet:

```bash
echo s2idle | sudo tee /sys/power/mem_sleep
cat /sys/power/mem_sleep
```

Danach zeigte die Ausgabe:

```text
[s2idle] deep
```

Trotzdem führte ein Suspend-Versuch erneut zu einem harten Ausfallverhalten. Damit war klar: Nicht nur `deep`, sondern auch `s2idle` ist in dieser Umgebung unzuverlässig.

### 3. Bluetooth war nicht die Hauptursache

Im Vorfeld fiel im Log ein möglicher USB-/Bluetooth-Hinweis auf:

```text
usb 1-8: Failed to suspend device, error -110
```

Das betroffene Gerät war:

```text
Broadcom Corp. Bluetooth USB Host Controller
```

Es wurde ein Test ohne Bluetooth durchgeführt:

* `bluetooth.service` gestoppt
* Bluetooth-Module entladen
* erneuter Suspend-Test

Ergebnis: Das Suspend-Problem blieb bestehen. Bluetooth war damit nicht die Hauptursache.

### 4. Logind-/Session-Neustarts reagierten empfindlich

Beim späteren Eingriff in `logind` kam es nach dem Neustart von `systemd-logind` sofort zur Abmeldung. Beim Wiederanmelden erschien teilweise nur ein schwarzer Bildschirm. Das zeigte zusätzlich, dass diese iMac-/Ubuntu-Kombination auf Änderungen rund um Sitzungs- und Power-Handling empfindlich reagiert.

## Umsetzung / Workaround

Da Suspend in dieser Umgebung nicht stabil nutzbar war, wurde er bewusst deaktiviert.

### Sleep-Konfiguration

Datei:

```ini
/etc/systemd/sleep.conf.d/disable-suspend.conf
```

Inhalt:

```ini
[Sleep]
AllowSuspend=no
AllowHibernation=no
AllowHybridSleep=no
AllowSuspendThenHibernate=no
```

### Logind-Konfiguration

Datei:

```ini
/etc/systemd/logind.conf
```

Relevante Zeilen:

```ini
[Login]
HandleSuspendKey=ignore
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
```

## Ergebnis

* Suspend wurde bewusst deaktiviert
* die Sleep-Taste wird von `systemd-logind` ignoriert
* der Rechner soll im Alltag nicht mehr absichtlich in Bereitschaft geschickt werden
* damit wird ein bekannter instabiler Betriebszustand vermieden

## Verworfen / geprüft

* Suspend mit `deep`: fehlgeschlagen
* Suspend mit `s2idle`: fehlgeschlagen
* Test ohne Bluetooth: keine grundlegende Verbesserung
* weitere Suspend-Tests wurden bewusst beendet, um zusätzliche Abstürze und Datenrisiken zu vermeiden

## Empfohlene Alltagsnutzung

* Rechner normal laufen lassen
* Bildschirm bei Bedarf sperren
* Bildschirm dunkel werden lassen statt Suspend zu verwenden
* keine weiteren Suspend-Experimente im Alltagsbetrieb

## Offene Punkte für spätere Analyse

Dieses Thema wurde bewusst nicht vollständig „gelöst“, sondern stabil entschärft. Falls später erneut tiefer analysiert werden soll, dann getrennt und mit Vorsicht:

* Kernel-Parameter im Bootloader prüfen und ausmisten
* ACPI-/Apple-Firmware-Besonderheiten bewerten
* GPU-/Resume-Verhalten getrennt untersuchen
* `logind`-Änderungen perspektivisch als Drop-in statt direkt in der Hauptdatei pflegen

## Fazit

Für diese konkrete iMac-/Ubuntu-Kombination war Suspend nicht zuverlässig nutzbar. Der saubere und alltagstaugliche Weg bestand daher nicht in weiterer Optimierung, sondern im bewussten Abschalten der problematischen Funktion.

## Zusätzliche Beobachtungen nach der ersten Stabilisierung

### Login-/Display-Manager-Verhalten

Im Verlauf der Analyse zeigte sich zusätzlich ein Problem beim Login:

* nach der Passwort-Eingabe erschien zeitweise nur ein schwarzer Bildschirm mit sichtbarem Mauszeiger
* im Journal zeigten sich Hinweise auf Probleme rund um GDM, GNOME Shell und `Xwayland`

Die Benutzersitzung lief bereits auf `x11`, GDM selbst war jedoch noch nicht fest auf Xorg konfiguriert. Nach dem Setzen von

```ini
WaylandEnable=false
```

in `/etc/gdm3/custom.conf` wurde der Login stabiler und das Schwarzbild nach der Anmeldung verschwand.

### Bereinigte Kernel-Parameter

Im weiteren Verlauf wurden historische Kernel-Parameter aus der GRUB-Konfiguration entfernt, um alte Altlasten nicht weiter mitzuschleppen. Der Login blieb danach stabil und die Helligkeitskonfiguration funktionierte weiterhin.

### Poweroff-Verhalten weiterhin fehlerhaft

Trotz stabilerem Login und bereinigter Kernel-Parameter bleibt ein separates Problem bestehen:

* `systemctl poweroff` schaltet den iMac sichtbar aus
* der Rechner landet dabei jedoch offenbar nicht in einem gesunden finalen Aus-Zustand
* für einen späteren Start ist häufig ein langer Druck auf den Einschaltknopf nötig, bevor das Gerät anschließend wieder normal eingeschaltet werden kann
* ein Vergleichstest zeigte identisches Verhalten sowohl beim Ausschalten über die GNOME-Oberfläche als auch bei systemctl poweroff

Dieses Verhalten spricht eher für ein Low-Level-Problem im Bereich ACPI, Apple-Firmware oder Hardware-Power-State als für ein GNOME- oder Suspend-Problem.

### Zusätzliche offene Punkte für spätere Analyse

* Poweroff-/S5-Verhalten getrennt vom Suspend-Verhalten analysieren
* prüfen, ob das fehlerhafte Ausschaltverhalten unabhängig vom Aufrufweg identisch ist, also sowohl bei `systemctl poweroff` als auch beim Ausschalten über die GNOME-Oberfläche
* Kernel- und Firmware-seitige Besonderheiten des iMac weiter untersuchen, falls das Thema später erneut vertieft werden soll
