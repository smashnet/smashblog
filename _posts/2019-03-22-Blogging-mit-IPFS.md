---
layout: post
author: nico
title: Blogging mit IPFS
published: false
---
Wer seinen Blog über <a href="https://ipfs.io">IPFS</a> zur Verfügung stellen möchte, wird schnell merken, dass systembedingt die meisten der üblichen Blog-Softwares dafür nicht in Frage kommen. Warum das der Fall ist, und wie man trotzdem seinen Blog mit IPFS ins _Distributed Web_ (DWeb) bekommt, möchte ich in diesem Blogpost erläutern.

# Grundlegendes

Nahezu alle üblichen Verdächtigen wie <a href="https://de.wordpress.org/">Wordpress</a>, <a href="https://ghost.org/">Ghost</a>, <a href="http://www.s9y.org/">Serendipity</a>, etc. liefern den Blog als dynamische Seite aus. Das bedeutet, dass anhand gewisser Eingabeparameter das HTML der gerade aufgerufenen Blogseite dynamisch zusammengesetzt, und ausgeliefert wird. Das gibt dem Nutzer eine Reihe toller Vorteile:

* Er kann nach bestimmten Blogposts suchen
* Er kann über das Web-UI des Blog neue Posts schreiben
* Er kann die Erscheinung des Blogs ändern, oder gar einzelnen Gästen die Möglichkeit geben eigene Präferenzen für die Ansicht des Blogs zu setzen
* ...

Abstrakt gesehen gibt es also eine Datenbasis, wie z.B. Blogpost Inhalte, die meist in einer Datenbank gespeichert ist, und ein dynamisches Frontend welches dem Nutzer erlaubt diese Daten auf verschiedenste Arten - eben dynamisch - anzuzeigen.

Um nun zu verstehen, warum wir beim Blogging mit IPFS etwas umdenken müssen, müssen wir verstehen was Inhalte sind, und wie sie im DWeb in unserem Browser landen, verglichen mit dem normalen Web.

## Inhalte

Als _Inhalt_ oder _Content_ könnte man leicht etwas wie den Text eines Blogposts verstehen. Er ist die Essenz des Blogposts und das was ich als Autor vermitteln möchte. Bei IP__FS__ handelt es sich um ein _File System_ wo Seiten nach ihrem Inhalt adressiert werden. In diesem Kontext bedeutet TODO
