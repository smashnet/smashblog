---
title: LUKS optimieren für schnellere Bootvorgänge  
subtitle: LUKS für Dummies (wie mich)  
layout: post
author: nico
category: blog
published: false
---

Wer Festplattenverschlüsselung auf Partitionsebene für sein Linux System haben möchte, nutzt dafür aktuell fast unvermeidlich [dm-crypt](https://de.wikipedia.org/wiki/Dm-crypt) mit [LUKS](https://de.wikipedia.org/wiki/Dm-crypt#Erweiterung_mit_LUKS). So auch in meinem Fall, nach meinem Wechsel weg vom Mac hin zu [Manjaro Linux](https://manjaro.org/). In diesem Blogpost geht es um eine kleine Optimierung - und die dabei erlebten Fallstricke - um den Bootvorgang in diesem Szenario zu beschleunigen.

Was mich nun dazu brachte mir das Thema _LUKS_ genauer anzuschauen war, dass mein System sich bei jedem Bootvorgang nach Eingabe der Passphrase gefühlte 5-10 Gedenksekunden erlaubt hat, bevor es mit dem Start des OS weiterging. Um zu verstehen wie diese Verzögerung zustande kommt, müssen wir uns zunächst (stark vereinfacht) anschauen was _dm-crypt_ und _LUKS_ genau tun:

**Dm-Crypt** ist der eigentliche Verschlüsselungslayer. Das Tool wird mit einem _Schlüssel_ gefüttert, und ver- und entschlüsselt damit alle Daten die auf die Partition geschrieben und gelesen werden. Dafür nutzt es ein zu Beginn festgelegtes, symmetrisches Chiffrierungsverfahren wie z.B. [AES](https://de.wikipedia.org/wiki/Advanced_Encryption_Standard). Dabei gibt es zwei in der Praxis unschöne Probleme:

1. Der von dm-crypt verwendete Schlüssel ist nicht einfach die vom Nutzer gewählte Passphrase, sondern eine generierte Folge von Bits einer festen Länge, z.B. 256-bit bei AES-256. Diese Bitfolge (der _Schlüssel_) wird aus der vom Nutzer gewählten Passphrase abgeleitet (z.B. per [PBKDF2](https://de.wikipedia.org/wiki/PBKDF2) oder [Argon2](https://de.wikipedia.org/wiki/Argon2)). Möchte der Nutzer aber nun seine Passphrase ändern, müsste er den kompletten Inhalt seiner Festplatte neu verschlüsseln, da sich aus der neu gewählten Passphrase natürlich auch ein anderer Schlüssel ableitet.

2. Wenn es sich um ein System mit mehreren Benutzern handelt, dann müssten alle Benutzer zusätzlich zu ihren individuellen Benutzer-Passwörtern auch die Passphrase kennen, um den Rechner zu starten.

Um (unter Anderem) diese beiden Punkte zu adressieren kommt nun **LUKS** ins Spiel.

-----

* Damit einem Angreifer es möglichst schwer gemacht wird einfach viele Passphrasen durchzuprobieren, versuchen die _Schlüsselableitungsfunktionen_ (PBKDF2, Argon2, s.o.) möglichst rechenintensiv zu sein. Statt z.B. die Passphrase nur einfach zu hashen, wird diese über viele Iterationen (Rounds) gehasht. 

Die meisten Linux-Distributionen erlauben mittlerweile das einfache Aktivieren der Festplattenverschlüsselung in ihren Installern, und nutzen dafür genau die beiden besagten Tools.