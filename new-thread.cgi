#!/bin/sh

set -e

. ./config
. ./param.sh
. ./threads.sh
. ./html.sh

error() {
    echo "Content-Type: text/html"
    echo
    html_page "Failed to Create Thread" <<EOF
<h1>Failed to Create Thread</h1>
<p>$1</p>
<a href="$INDEX_URL">Home</a>
EOF
    exit
}

if [ "$REQUEST_METHOD" != "POST" ]; then
    echo "Status: 405 Method Not Allowed"
    error "You must use http POST to start new threads."
fi

query=`cat /dev/stdin`

post_text=`get_param content "$query" | urldecode | htmlencode`

# Make the new thread.
thid=`next_thread_id`

if new_thread "$REMOTE_ADDR" Anonymous "$post_text"; then
    # Redirect to the new thread.
    echo "Location: $URL_ROOT/thread.cgi?$thid"
    echo
else
    error "$error"
fi

