#!/bin/bash

docker run --rm --volume="$PWD:/srv/jekyll" -it jekyll/jekyll jekyll build --baseurl "ipns/smashnet.de/blog/"
