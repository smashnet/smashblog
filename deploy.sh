#!/bin/bash -e

./build.sh

rsync -r _site/* eck:Docker/inden.one/content/
