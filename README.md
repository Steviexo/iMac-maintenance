# iMac-maintenance

Dokumentation, Wartung und Troubleshooting für einen älteren Apple iMac, der mit Ubuntu LTS weiterbetrieben wird.

Das Repository dient als technische Arbeits- und Wissensbasis für den laufenden Betrieb, wiederkehrende Pflegeaufgaben, bekannte Besonderheiten sowie konkrete Vorfälle mit dokumentierten Workarounds.

## Ziel des Repositories

Dieses Repository bündelt:

* Systemüberblick und technische Besonderheiten des Geräts
* Betriebswissen für den Alltag unter Ubuntu LTS
* dokumentierte Vorfälle mit Ursache, Analyse und Workaround
* wiederverwendbare Troubleshooting-Pfade für typische Probleme

Ziel ist es, Änderungen nachvollziehbar zu halten, spätere Fehlersuche zu erleichtern und bewährte Lösungen dauerhaft festzuhalten.

## Geltungsbereich und technische Ausstattung

Fokus dieses Repositories ist ein einzelnes Gerät:

* **iMac (Modell 16,2) mit Ubuntu 24.04 LTS**:
  - **Modell**: Apple iMac 21.5" (Late 2015) – iMac 16,2
  - **Prozessor**: Intel Core i5-5575R, 4 Kerne @ 2,8 GHz
  - **RAM**: 8 GB LPDDR3 (erweiterbar bis 16 GB)
  - **Grafik**: Intel Iris Pro Graphics 6200
  - **Speicher**: 250GB SSD
  - **Betriebssystem**: Ubuntu 24.04 LTS 64-bit (anstelle von macOS)
* Dokumentation von Hardware-, Display-, Power-, Boot- und Betriebsverhalten

## Repository-Struktur

```text
iMac-maintenance/
├── README.md
├── docs/
│   ├── 00-overview/
│   │   └── system-overview.md
│   ├── 01-architecture/
│   │   └── power-display-and-boot-behavior.md
│   ├── 02-operations/
│   │   └── daily-usage-and-maintenance.md
│   ├── 03-incidents/
│   │   ├── imac-display-brightness-reset-after-screen-wake.md
│   │   └── imac-suspend-causes-black-screen-or-hard-power-cycle.md
│   └── 04-troubleshooting/
│       ├── display-brightness-diagnostics.md
│       └── suspend-power-state-diagnostics.md
├── images/
│   └── README.md
└── scripts/
    └── set_brightness.sh
```

## Dokumentationslogik

### `docs/00-overview/`

Geräteüberblick, Betriebssystem, Eckdaten und Ausgangslage.

### `docs/01-architecture/`

Technische Besonderheiten und Designentscheidungen rund um Boot-Verhalten, Display-Ansteuerung, Energieverwaltung und ähnliche systemnahe Themen.

### `docs/02-operations/`

Laufender Betrieb, praktische Nutzung, Pflege, Updates, Alltagshinweise und bewusst gesetzte Betriebsgrenzen.

### `docs/03-incidents/`

Konkrete Vorfälle mit Symptomen, Analyse, getesteten Ansätzen, umgesetztem Fix bzw. Workaround und aktuellem Betriebszustand.

### `docs/04-troubleshooting/`

Allgemein nutzbare Diagnosepfade und wiederverwendbare Debugging-Schritte für typische Problemklassen.

## Bereits dokumentierte bzw. vorgesehene Themen

### Incidents

* Display-Helligkeit setzt sich nach Bildschirm-Aus oder Wake zurück
* Suspend führt zu Schwarzbild, Absturz oder hartem Power-Cycle

### Weitere sinnvolle Themen für später

* Boot-Parameter und Altlasten im Kernel-Command-Line-Setup
* externer Monitorbetrieb und Multi-Monitor-Verhalten
* Bluetooth- und USB-Besonderheiten
* Login-, Session- und GDM-Verhalten
* Backup- oder Wiederherstellungsstrategie für das Gerät

## Arbeitsprinzipien für dieses Repo

* Änderungen möglichst klein und nachvollziehbar halten
* immer nur einen technischen Hebel gleichzeitig ändern
* funktionierende Workarounds dokumentieren, auch wenn sie nicht „schön“ sind
* instabile Funktionen lieber bewusst deaktivieren als halb kaputt weiterzubenutzen
* Vorfälle nicht nur lösen, sondern mit Ursache, Auswirkungen und Betriebsfolgen dokumentieren

## Aktueller technischer Stand

Der iMac wird unter Ubuntu LTS mit dokumentierten Workarounds betrieben. Dazu gehört insbesondere:

* ein `xrandr`-basierter Helligkeits-Workaround für das interne Display
* ein bewusst deaktivierter Suspend-Betrieb, weil Suspend/Resume in dieser Umgebung nicht zuverlässig funktioniert

Diese Entscheidungen sind keine theoretischen Optimierungen, sondern konkrete Maßnahmen aus realem Troubleshooting.

## Pflegehinweis

Bei Änderungen an Power-Management, Display-Verhalten, Boot-Parametern oder Login-/Sitzungsverwaltung sollte die Dokumentation sofort mit aktualisiert werden. Gerade bei älterer Apple-Hardware unter Linux entstehen sonst schnell historische Workarounds, bei denen später niemand mehr weiß, warum sie überhaupt existieren.

## Geplante nächste Inhalte

* `docs/00-overview/system-overview.md`
* `docs/01-architecture/power-display-and-boot-behavior.md`
* `docs/02-operations/daily-usage-and-maintenance.md`
* die beiden Incident-Dateien aus `docs/03-incidents/`
* später ergänzend Troubleshooting-Dateien unter `docs/04-troubleshooting/`
