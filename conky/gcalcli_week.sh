#!/bin/sh

gcalcli --conky --calendar 'Work' --calendar 'Personal' --nolineart -w 18 calw 1 |
    sed -e 's/yellow/white/g' \
        -e 's/cyan/#0077ff/g'