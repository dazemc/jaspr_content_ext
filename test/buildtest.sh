#!/bin/bash

rm -rf ./web/images/mermaid && rm -rf ./build
jaspr build
cd ./build/jaspr/ || exit
python -m http.server
