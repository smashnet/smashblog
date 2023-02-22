#!/bin/bash

docker run --rm -v $(pwd):/site myjekyll build --baseurl "."
