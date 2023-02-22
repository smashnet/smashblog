---
layout: post
author: nico
title: Deploying auf IPFS - Ein Test
category: blog
published: true
---
Da diese Seite ja komplett über [IPFS](https://ipfs.io) gehostet wird, arbeite ich aktuell an einer Möglichkeit das so weit wie möglich zu automatisieren. Wie der Techstack genau aussieht, dazu wird es mit Sicherheit noch einen eigenen Post geben. Mit diesem hier möchte ich allerdings erstmal testen, ob mein Deploy-Skript welches sich um alles vom `git pull` bis zum `ipfs name publish` kümmert, funktioniert.

__Update:__  
Es funktioniert! Jetzt muss ich nur noch den Webhook von Github als Trigger nutzen, und fertig ist das Konstrukt :) Das ist übrigens gar keine Kleinigkeit, wenn der Webhook in einem anderen Docker-Container ankommt als der IPFS Daemon läuft... Aber schaffen wir. Ich werde berichten.

__Update 2 (09.02.2022):__  
Ich bin nach wie vor ein riesen Fan von IPFS! Leider hat sich herausgestellt, dass ich recht wenig Care-Time übrig habe für den Blog, daher läuft er seit einiger Zeit wieder beim Hoster des Vertrauens.

__Update 3 (12.07.2022):__  
"Der Hoster des Vertrauens" bedeutet seit einigen Wochen nun Self-Hosting auf dem Home-Server. NGINX in Docker, fertig.
