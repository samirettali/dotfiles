#!/bin/bash

COUNT=-1
if [[ $1 =~ ^[0-9]+$ ]]; then
    COUNT=$1
    shift    
fi

STATUS=0

while [ "$COUNT" -ne 0 ]; do
    let COUNT-=1
    $*
    STATUS=$?
    if [ $STATUS -eq 0 ]; then
        exit $STATUS
    fi
done
exit $STATUS
