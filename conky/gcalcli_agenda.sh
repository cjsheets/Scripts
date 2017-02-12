#!/bin/sh

gcalcli --conky --calendar 'Work' --calendar 'Personal' --calendar 'Family' \
    agenda $(date +%m/%d/%Y) $(date +%m/%d/%Y -d "+3 days") |
    sed -e 's/yellow/white/g' \
        -e 's/cyan/#0077ff/g' \
        -e '/$2500/ d'

# $2500 processed out a spam message