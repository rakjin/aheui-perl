#!/bin/bash

prove -l

if [ -e snippets ]; then
    cd snippets
    git pull
else
    git clone https://github.com/aheui/snippets
    cd snippets
fi

chmod 755 ../bin/aheui
AHEUI="perl -I ../lib ../bin/aheui" bash test.sh standard
cd ..

