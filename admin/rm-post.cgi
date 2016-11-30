#!/bin/bash

set -e

cd ..

. ./config
. ./threads.sh
. ./html.sh
. ./param.sh
. ./bans.sh
. ./admins.sh

require_mod

# FIXME: This and the ban page are very similar. Should be refactored.

# The page /admin/rm-post.cgi?<thread>-<post> will present a moderator with a
# form asking for why the post is to be removed. The post file will be moved to
# data/removed/<thread>-<post>.

do_rm() {
    query=`cat /dev/stdin`

    thread=`get_param thread "$query"`
    post=`get_param post "$query"`

    echo "Location: $URL_ROOT/thread.cgi?$thread"
    echo

    remove_post $thread $post

    echo "Post removed"
}

rm_form() {
    thread=`echo "$QUERY_STRING" | cut -d '-' -f 1 | sed 's/[^0-9]//g'`
    post=`echo "$QUERY_STRING" | cut -d '-' -f 2 | sed 's/[^0-9]//g'`

    echo "Content-Type: text/html"
    echo
    html_page "Remove Post" <<EOF
<h1>Remove Post</h1>
<p>You are removing this post:</p>
`post_html $thread $post`

<p>The post will be archived in a separate directory, but will no longer be
visible on the main page.</p>

<p>Please enter a reason for the removal and click the remove button.</p>
<form method="POST">
<input type="hidden" name="thread" value="$thread">
<input type="hidden" name="post" value="$post">
<input type="text" name="reason">
<input type="submit" value="Remove">
</form>
EOF
}

case "$REQUEST_METHOD" in
    POST )
        do_rm
        ;;
    GET )
        rm_form
        ;;
    * )
        echo "Status: 405 Method Not Allowed"
        echo
        ;;
esac


