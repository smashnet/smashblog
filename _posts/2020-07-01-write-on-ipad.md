---
title: Statische Seiten vom iPad aus befüllen? Klar, geht!  
subtitle: Mein aktueller Workflow  
layout: post
author: nico
category: blog
published: false
---
Eigentlich ist es heute für jeden Website-Admin oder -Author selbstverständlich, dass sich neue Blogposts simpel, von überall und von jedem Endgerät aus erstellen und publizieren lassen. Mit dieser Website war das lange Zeit anders. Aus purer Entwicklerromantik habe ich mich entschieden einen Static Site Generator (hier Jekyll) zu nutzen. Ich habe also kein schickes Web-UI wo ich meine Posts schreibe, sondern schreibe diese in Markdown-Dateien, aus denen dann zusammen mit einem Template statisches HTML gebaut und deployt wird. Wie das alles rein vom iPad aus funktionieren kann, darum geht's in diesem Blogpost.

## Die Schritte zum neuen Blogpost

Eigentlich ist es recht einfach einer statischen Seite einen neuen Blogpost hinzuzufügen. Leider braucht es dafür aber oft Dinge die man auf einem iPad meistens nicht zur Verfügung hat. Werfen wir einen Blick auf die einzelnen Schritte:

* Erstellen einer neuen .md Datei, und Verfassen des Posts
* Generieren der Website
* Aktualisieren der Website auf dem Webserver

Wie so eine Ordnerstruktur einer Jekyllseite aussieht ist [hier](https://jekyllrb.com/docs/structure/) bereits gut beschrieben, daher gehe ich darauf nicht mehr explizit ein.

Der erste Schritt ist auf dem iPad noch problemlos realisierbar. Ich schreibe hier gerade mit [Textastic](https://www.textasticapp.com/) diesen Blogpost, und bin damit sehr zufrieden.

Im zweiten Schritt fangen die Probleme an. Jekyll ist ein Kommandozeilen-Tool welches - einfach gesprochen - aus meinen .md Dateien eine HTML Seite generiert. Jekyll gibt es weder als App, noch lässt Apple uns eine Kommandozeile auf dem iPad nutzen. Soweit so gut (oder auch nicht). 

Der dritte Schritt wäre theoretisch auf dem iPad machbar. Es gibt genug Apps die mir erlauben Daten auf einen Webserver hochzuladen. Das würde sogar direkt mit meiner Schreib-App Textastic gehen. Bringt nur leider nichts, wenn ich wegen Schritt zwei meine Seite auf dem iPad nicht generieren kann.

## Lösungen müssen her

Um dennoch einen Workflow zu finden, der es mir erlaubt neue Posts direkt vom iPad (oder sogar iPhone) aus zu schreiben, bin ich auf Lösungssuche gegangen. Eine wichtige Komponente hatte ich dabei schon zunächst unbewusst an Bord: [GitHub](https://github.com)

Ich nutze Github zur Versionierung meiner Seite in einem Github Repo, und mit [Github Actions](https://github.com/features/actions) ist kürzlich ein Feature für alle Nutzer verfügbar geworden, welches unser Problem löst. Actions erlaubt es uns bestimmte Dinge automatisiert durchzuführen, wenn z.B. neuer Inhalt ins Repo gepusht wurde. Bingo! Wir können also mit Actions das Generieren der HTML Seite mit Jekyll, und das Aktualisieren auf dem Webserver ins Internet verlagern!

Bleibt noch die Frage wie ich auf dem iPad komfortabel mein Repo auf Github mit neuen Posts aktualisieren kann? Dafür nutze ich aktuell die App [Working Copy](https://workingcopyapp.com/). Diese habe ich mit meinem Github-Account verknüpft, und kann an all meinen Repos arbeiten. Prinzipiell geht das direkt direkt auch mit dem Editor in Working Copy, nur arbeite ich lieber mit Textastic. Der Clou ist nun, dass Working Copy in iOS als "Ort" in der Dateien-App auftaucht. Damit ist die Integration in Textastic sehr einfach:

* In Textastic unter "Externe Daten und Ordner" auf "Externen Ordner hinzufügen" klicken
* In der Liste "Working Copy" und darunter das entsprechende Repo auswählen

Mein Repo taucht nun vollständig in Textastic auf, und jede Änderung wir automatisch zu Working Copy gespiegelt.

Ich kann also nun, nachdem ich jetzt diese letzten Worte geschrieben habe einfach von Textastic in die Working Copy App wechseln, dort meinen neuen Post commiten und pushen, und schon sollte sich automagisch meine Website aktualisieren.

Aber Moment, wie war das noćh mit dem Actions Teil? Wie genau funktioniert das? Nun, das würde sicher einen komplett eigenen Blogpost rechtfertigen und füllen, daher hier nur kurz der für mich funktionierende Workflow mit kurzer Erläuterung:

ˋˋˋ
# This is a basic workflow to help you get started with Actions

name: CI

# Controls when the action will run. Triggers the workflow on push or pull request
# events but only for the master branch
on:
  push:
    branches: [ master ]
  pull_request:
    branches: [ master ]

# A workflow run is made up of one or more jobs that can run sequentially or in parallel
jobs:
  # This workflow contains a single job called "build"
  build:
    # The type of runner that the job will run on
    runs-on: ubuntu-latest

    # Steps represent a sequence of tasks that will be executed as part of the job
    steps:
    # Checks-out your repository under $GITHUB_WORKSPACE, so your job can access it
    - name: Checkout
      uses: actions/checkout@v2

    # Hier führe ich das insert_date.sh Skript aus meinem Repo aus, um das Datum des Deployments im Footer meiner Seite zu integrieren
    - name: Insert date of last update
      run: sh insert_date.sh
    
    # Hier wird mit Jekyll die HTML Seite gebaut
    - name: Build Jekyll
      uses: jerryjvl/jekyll-build-action@v1

    # Hier wird die fertige Seite per SSH zum Webserver geschoben
    - name: ssh deploy
      uses: easingthemes/ssh-deploy@v2.1.2
      env:
        # Private Key
        SSH_PRIVATE_KEY: ${{ secrets.STRATO_DEPLOY_KEY }}
        SOURCE: "_site/"
        REMOTE_HOST: ${{ secrets.REMOTE_HOST }}
        REMOTE_USER: ${{ secrets.REMOTE_USER }}
        TARGET: ${{ secrets.REMOTE_TARGET }}
ˋˋˋ

Wenn ihr euch den Aufbau dieser Seite im konkreten Beispiel anschauen wollt, werft gerne einen Blick darauf: [https://github.com/smashnet/smashblog](https://github.com/smashnet/smashblog)