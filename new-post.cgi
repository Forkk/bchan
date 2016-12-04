#!/bin/sh

set -e

. ./config
. ./param.sh
. ./threads.sh
. ./html.sh

if [ "$REQUEST_METHOD" != "POST" ]; then
    echo "Status: 405 Method Not Allowed"
    echo
    echo "You must use http POST to make new posts."
    exit
fi

query=`cat /dev/stdin`

msg=`get_param content "$query" | urldecode | htmlencode`
thread=`get_param thread "$query" | urldecode | sed 's/[^0-9]//g'`

error() {
    echo "Content-Type: text/html"
    echo
    html_page "Post Failed" <<EOF
<h1>Post Failed</h1>
<p>$1</p>
<a href="$INDEX_URL">Home</a> <a href="$ROOT_URL/thread.cgi?$thread">Back to thread</a>
EOF
    exit
}

if [ -z "$thread" ]; then
    error "Invalid thread ID."
fi

if [ ! -d "$THREAD_DIR/$thread" ]; then
    error "Unknown thread $thread."
fi

if new_post "$thread" "$REMOTE_ADDR" Anonymous "$msg"; then
    echo "Location: $URL_ROOT/thread.cgi?$thread"
    echo
else
    error "$error"
fi

