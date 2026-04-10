# Projektdokumentation: Fehlerbehebung beim Starten von Obsidian AppImage auf Ubuntu
## Problem
Beim Versuch, die Obsidian AppImage auf einem Ubuntu-System zu starten, wurde das Programm im Anwendungsmenü nicht gestartet. Dies trat auf, nachdem die AppImage-Datei in das System integriert wurde, jedoch nicht wie erwartet funktionierte.

Die Symptome umfassten:

Ein Icon war im Anwendungsmenü sichtbar, aber ein Klick darauf führte zu keiner Reaktion.
Beim Starten der Anwendung direkt über das Terminal funktionierte die AppImage-Datei einwandfrei.
Der Startversuch über das Anwendungsmenü war jedoch erfolglos.
## Systeminformationen
Betriebssystem: Ubuntu (auf einem Intel iMac)
Obsidian-Version: 1.6.7 (AppImage)
Desktop-Umgebung: GNOME Shell
## Lösungsschritte
### 1. Herunterladen und Ausführen des AppImages
Das Problem begann mit dem Start des Obsidian AppImage. Die Datei wurde korrekt heruntergeladen und ausführbar gemacht, aber beim Klick im Anwendungsmenü passierte nichts.

1. Das AppImage wurde von der offiziellen Obsidian-Website heruntergeladen.
2. Um das AppImage ausführbar zu machen, wurde der folgende Befehl verwendet:

       chmod +x /home/stevie/Applications/Obsidian-1.6.7.AppImage

   Das AppImage wurde im Terminal mit dem Befehl --no-sandbox erfolgreich gestartet:
   
        /home/stevie/Applications/Obsidian-1.6.7.AppImage --no-sandbox

### 2. Erstellen einer .desktop-Datei
Um Obsidian über das Anwendungsmenü starten zu können, wurde eine .desktop-Datei manuell erstellt:

    nano ~/.local/share/applications/obsidian.desktop

Der Inhalt der .desktop-Datei war wie folgt:

    [Desktop Entry]
    Version=1.0
    Name=Obsidian
    Exec=/home/stevie/Applications/Obsidian-1.6.7.AppImage --no-sandbox
    Terminal=false
    Type=Application
    Categories=Utility;

### 3. Überprüfen und Aktualisieren der Desktop-Datenbank
Um sicherzustellen, dass das System die neue .desktop-Datei erkennt, wurde die Desktop-Datenbank aktualisiert:

    update-desktop-database ~/.local/share/applications

### 4. Testen mit gtk-launch
Die Datei wurde erfolgreich durch den Befehl gtk-launch ausgeführt, was zeigte, dass die .desktop-Datei technisch korrekt war:

    gtk-launch obsidian

### 5. Verschieben der .desktop-Datei in das globale Verzeichnis
Da die Integration im lokalen Anwendungsverzeichnis nicht wie erwartet funktionierte, wurde die .desktop-Datei in das globale Verzeichnis verschoben:

        sudo mv ~/.local/share/applications/obsidian.desktop /usr/share/applications/
        sudo update-desktop-database /usr/share/applications/

### 6. Neustart der Desktop-Umgebung
Letztlich wurde durch das Abmelden und erneute Anmelden in der Desktop-Umgebung das Problem behoben. Obsidian konnte nun erfolgreich über das Anwendungsmenü gestartet werden.

## Fazit
Das Problem wurde durch das erneute Laden der .desktop-Datei in die globale Desktop-Datenbank und das Abmelden/Anmelden behoben. Diese Schritte können nützlich sein, wenn AppImage-basierte Anwendungen in Ubuntu nicht ordnungsgemäß über das Anwendungsmenü gestartet werden können.

## Wichtige Befehle
AppImage ausführbar machen:

    chmod +x /Pfad/zur/Obsidian.AppImage

Obsidian mit --no-sandbox starten:

    ./Obsidian.AppImage --no-sandbox

Desktop-Datenbank aktualisieren:

    update-desktop-database ~/.local/share/applications

Testen mit gtk-launch:

    gtk-launch obsidian
