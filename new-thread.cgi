#!/bin/sh

set -e

error() {
    echo "Content-Type: text/plain"
    echo
    echo "$1"
    exit
}

if [ "$REQUEST_METHOD" != "POST" ]; then
    echo "Status: 405 Method Not Allowed"
    echo
    echo "You must use http POST to start new threads."
    exit
fi

. ./config
. ./param.sh
. ./threads.sh

query=`cat /dev/stdin`

post_text=`echo "$query" | sed 's/content=//' | urldecode | htmlencode`

# Make the new thread.
thid=`next_thread_id`

if new_thread "$REMOTE_ADDR" Anonymous "$post_text"; then
    # Redirect to the new thread.
    echo "Location: $URL_ROOT/thread.cgi?$thid"
    echo
else
    error "$error"
fi

