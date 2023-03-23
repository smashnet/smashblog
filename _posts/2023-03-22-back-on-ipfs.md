---
title: Back on IPFS!
subtitle: 
layout: post
author: nico
category: blog
published: true
---

Currently, it seems to me this site is more like a tech toy for me rather than a place to publish lengthy quality content :D However, I can at least proudly say "We're back on IPFS!" and this time it's more of a dual stack solution :)

When I first set this blog up my approach was to only host on IPFS. Users without IPFS would see the site through a gateway while users with IPFS could directly load the site. The problem was - and probably still is - that most public IPFS gateways are slow as hell. You might be lucky loading IPFS content directly using the CID but as soon as you would use IPNS, public gateways take ages to load.

This time users with browsers lacking IPFS support will get inden.one delivered directly by a standard web server. Dead simple, really fast. But as soon as you have a browser with integrated IPFS support or one with the [IPFS Companion](https://github.com/ipfs/ipfs-companion) extension, loading inden.one will lookup the DNS TXT entry containing a link to an IPNS entry for the most current version of my site and all content will be served through IPFS.

If you have any comments or think that something might not be working correctly with my blog and IPFS please don't hesitate to drop me a line using the envelope on the top right! (Who needs dynamic sites with comments when you can have mail?)

Btw, if your browser does not transform the URL automatically, this is the way to go: <a href="ipns://inden.one">ipns://inden.one</a>

I really hope to come up with some real and less meta or even content at all in future :)
