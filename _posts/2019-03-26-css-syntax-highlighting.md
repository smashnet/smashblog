---
layout: post
author: nico
title: Syntax Highlighting und Kleinigkeiten
category: blog
published: true
---
Endlich klappt dann auch das Syntax-Highlighting, und ein paar weitere Kleinigkeiten die gerade Code und Tabellen lesbarer machen.

Beim Syntax-Highlighting war meine erste Anlaufstelle [highlighter.js](https://highlightjs.org/), da ich es noch aus [CodiMD](https://github.com/hackmdio/codimd) kannte. Allerdings integrierte sich das nicht so schön mit Jekyll. Netterweise bringt Jekyll allerdings die Möglichkeit mit z.B. [Rouge](https://github.com/jneen/rouge) zu integrieren. Das hat den großen Vorteil, dass Rouge bereits beim Bauen der Seite die verwendete Sprache erkennt, und das HTML entsprechend bauen kann. Highlighter JS fährt hier den Ansatz das Dokument auf Clientseite nachträglich zu analysieren und per JS umzubauen. Nicht so schön...

Weiterhin sind noch ein paar Kleinigkeiten wie `besser sichtbarer inline-code`, schönere Headings und

{:.table .table-striped}
| Tabellen              | mit             |
|---------------------------|------------------------------|
| sichtbaren | Rändern |
| und gestreiften | Zeilen |

... außerdem wird das CSS nun in der `main.css` importiert, sodass im HTML nur noch ein Aufruf notwendig ist.
