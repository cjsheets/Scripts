#!/bin/sh

gcalcli --conky --calendar 'Work' --calendar 'Personal' --nolineart -w 18 calw 1 |
    sed -e 's/white/#0077ff/g' \
        -e 's/yellow/#0077ff/g' \
        -e 's/cyan/white/g'