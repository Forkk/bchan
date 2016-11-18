#!/bin/sh

set -e

. ./config
. ./param.sh
. ./threads.sh

query=`cat /dev/stdin`

for param in `echo "$query" | tr "&" "\n"`; do
    if echo "$param" | grep "content=.\+" 2>&1 > /dev/null; then
        msg=`echo "$param" | sed 's/content=//' | urldecode | htmlencode`
    fi
    if echo "$param" | grep "thread=.\+" 2>&1 > /dev/null; then
        thread=`echo "$param" | sed 's/thread=//' | sed 's/[^0-9]//g'`
    fi
done

error() {
    echo "Content-Type: text/plain"
    echo
    echo "$1"
    exit
}

if [ -z "$thread" ]; then
    error "Invalid thread ID."
fi

if [ ! -d "$THREAD_DIR/$thread" ]; then
    error "Unknown thread $thread."
fi

new_post "$thread" "$REMOTE_ADDR" Anonymous "$msg"

echo "Location: $URL_ROOT/thread.cgi?$thread"
echo

