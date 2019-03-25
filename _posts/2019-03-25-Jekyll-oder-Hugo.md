---
layout: post
author: nico
title: Jekyll oder Hugo?
category: blog post # Can be "blog post" or "article"
published: true
---

Aktuell wird dieser Blog mit [Jekyll](https://jekyllrb.com/) erstellt, und bis auf ein paar Kleinigkeiten bin ich auch recht zufrieden damit. Jetzt hab' ich [hier](http://withblue.ink/2019/03/20/hugo-and-ipfs-how-this-blog-works-and-scales.html) gelesen, dass [Hugo](https://gohugo.io/) einige Vorteile mit sich bringen soll, die speziell im Umfeld mit IPFS nützlich sind.

Im Speziellen ermöglicht Hugo echte relative URLs. Das ist deshalb toll, da ein Blogpost `/2019/03/25/blogpost.html` seine Assets mit `../../../assets/` verlinken kann. Ich muss also keine Sorge haben, ob mein Blog nachher über `https://ipfs.io/ipns/smashnet.de/blog/...` oder über `ipns://smashnet.de/blog/...` aufgerufen wird.

Im Moment nutze ich mit Jekyll `baseurl: /ipns/smashnet.de/blog/`. Das funktioniert auch in 99,9% der Fälle, nämlich genau dann wenn der Blog nach dem `https` Muster aufgerufen wird. Ob ich einen Wechsel zu Hugo mache wird wohl davon abhängen, ob es noch mehr sinnvolle Vorteile gibt.
