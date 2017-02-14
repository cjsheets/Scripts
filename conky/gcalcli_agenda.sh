#!/bin/bash

gcalcli --conky --calendar 'Work' --calendar 'Personal' --calendar 'Family' \
    agenda $(date +%m/%d/%Y) $(date +%m/%d/%Y -d "+3 days") |
    sed -e 's/white/#0077ff/g' \
        -e 's/yellow/#0077ff/g' \
        -e 's/cyan/white/g' \
        -e '/$2500/ d'

# $2500 processed out a spam message