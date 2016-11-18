#!/bin/bash

set -e

error() {
    echo "Content-Type: text/plain"
    echo
    echo "$1"
    exit
}

if [[ "$REQUEST_METHOD" == "GET" ]]; then
    error "You can't post threads with HTTP get."
fi

. ./config
. ./param.sh
. ./threads.sh

query=`cat /dev/stdin`

post_text=`echo "$query" | sed 's/content=//' | urldecode | htmlencode`

# Make the new thread.
thid=`new_thread "$REMOTE_ADDR" Anonymous "$post_text"`

# Redirect to the new thread.
echo "Location: $URL_ROOT/thread.cgi?$thid"
echo
