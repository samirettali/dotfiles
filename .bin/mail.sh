#!/bin/bash

set -x

USERNAME="ettali.samir@gmail.com"
PASSWORD="*******"
RECEIVER="$1"
SUBJECT="$2"
BODY=$(cat $3)
AUTH=$(echo -en "\000$USERNAME\000$PASSWORD" | base64)

format_input () {
    echo "EHLO localhost"
    sleep 1
    echo "AUTH PLAIN $AUTH"
    sleep 1
    echo "MAIL FROM: <$USERNAME>"
    echo "RCPT TO: <$RECEIVER>"
    sleep 1
    echo "DATA"
    sleep 1
    echo "Subject: $SUBJECT"
    sleep 1
    echo "From: <$USERNAME>"
    sleep 1
    echo "To: <$RECEIVER>"
    sleep 1
    echo ""
    sleep 1
    echo "$BODY"
    sleep 1
    echo "."
    sleep 1
    echo "QUIT"
}

format_input | openssl s_client -connect smtp.gmail.com:465 -ign_eof -crlf
