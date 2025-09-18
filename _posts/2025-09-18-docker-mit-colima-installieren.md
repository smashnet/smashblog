---
title: Ein Leben ohne Docker Desktop auf macOS
subtitle: 
layout: post
author: nico
category: blog
published: true
---

Docker Desktop bringt mittlerweile deutlich mehr Features mit als ein pures `docker`. Wer keine Verwendung für Features wie die `Docker Build Cloud`, `Testcontainer Cloud` oder `Docker Model Runner` hat, kann beruhigt auf eine Docker Desktop Lizenz verzichten und kommt mit der Docker Engine und Docker CLI aus.

Da Docker Desktop auf dem Mac auch die Virtualisierung steuert und stellt, braucht es auf dem Mac eine Alternative, und die heißt [Colima](https://github.com/abiosoft/colima). 

Heute möchte ich euch zeigen, wie ihr Docker Desktop auf eurem Mac entfernen und stattdessen Docker mit [Colima](https://github.com/abiosoft/colima) über Homebrew installieren könnt. Das ist eine gute Alternative, die gut mit Apple Silicon funktioniert.

### Schritt 1: Docker Desktop entfernen

Erst einmal müssen wir Docker Desktop von unserem System entfernen:

1. Öffnet ein Terminal und führt folgendes aus, um Docker Desktop zu deinstallieren:
    ```bash
    /Applications/Docker.app/Contents/MacOS/uninstall
    ```
    
    Sollte dabei folgender Fehler auftreten, kann dieser [ignoriert werden](https://docs.docker.com/desktop/uninstall/):
    ```bash
    Error: unlinkat /Users/USER_HOME/Library/Containers/com.docker.docker/.com.apple.containermanagerd.metadata.plist: > operation not permitted
    ```

2. Löscht die Docker App:
   ```bash
   rm -rf /Applications/Docker.app
   ```

3. Entfernt die Zeile \"credsStore\": \"desktop\" aus eurer Docker-Konfiguration:
   ```bash
   sed -i '' '/"credsStore": "desktop"/d' ~/.docker/config.json
   ```

### Schritt 2: Docker mit Colima installieren

Jetzt installieren wir Docker und die notwendigen Tools:

1. Installiert Docker, docker-buildx, docker-credential-helper und Colima mit Homebrew:
   ```bash
   brew install docker docker-compose docker-buildx docker-credential-helper colima
   ```

2. Erstellt einen symbolischen Link für docker-buildx und docker-compose in das Docker CLI-Plugins-Verzeichnis:
   ```bash
   mkdir -p ~/.docker/cli-plugins/
   ln -sfn $(which docker-buildx) ~/.docker/cli-plugins/docker-buildx
   ln -sfn $(which docker-compose) ~/.docker/cli-plugins/docker-compose
    ```
3. Passt das Colima Template an Apple Silicon und eure Bedürfnisse an:
   ```bash
   colima template
   ```
   Folgende Zeilen wollt ihr euch anschauen:
   ```bash
   cpu: 4
   memory: 4
   vmType: vz (Sorgt dafür, dass Apple Virtualization verwendet wird statt qemu)
   rosetta: true (Sorgt dafür, dass x86_64/amd64 Images mit Rosetta gestartet werden)
   ```

4. Damit Colima jetzt automatisch gestartet wird, aktiviert ihr den Service:
   ```bash
   brew services start colima
   ```

Damit startet Colima automatisch bei jedem Systemstart und ihr könnt loslegen!

Viel Spaß mit Docker auf eurem Mac!