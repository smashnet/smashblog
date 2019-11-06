---
layout: post
author: nico
title: Java-Hopping unter MacOS
subtitle: ... mit Homebrew und jEnv
category: blog
published: true
---

Aus gegebenem Anlass habe ich mich heute damit beschäftigt, wie man unter macOS auf der Konsole möglichst einfach zwischen verschiedenen Java Versionen wechseln kann. Ihr braucht dafür [Homebrew](https://brew.sh/index), und gemacht wird's so:


Gewünschte Java Version(en) installieren:

`brew tap AdoptOpenJDK/openjdk`

`brew search /adoptopenjdk/`

`brew cask install adoptopenjdk8` (oder irgendeine andere Version aus dem vorherigen Schritt)


Benutze `jenv` (setzt JAVA_HOME) um bequem zwischen den Versionen zu springen:

`brew install jenv` (`jenv` installieren)

`jenv add /Library/Java/JavaVirtualMachines/adoptopenjdk-8.jdk/Contents/Home/` (Java Version mit `jenv` bekannt machen)

`jenv versions` (bekannte Versionen anzeigen)

`jenv global openjdk64-1.8.0.232` (zu verwendende Version auswählen)


---
Quellen:

* [Install OpenJDK Versions on the Mac](https://dzone.com/articles/install-openjdk-versions-on-the-mac)
* [jEnv Homepage](http://www.jenv.be)

_Hinweis_

Entegegen der Anleitung von dzone.com gibt es aktuell alle Java Versionen nur noch als `cask` und nicht mehr als `formulae`.
