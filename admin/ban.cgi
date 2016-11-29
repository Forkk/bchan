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

# The page /admin/ban.cgi?<thread>-<post> will present a moderator with a form
# asking for why the user is to be banned for the given post, and then, on post
# of that form, bans the user.

do_ban() {
    query=`cat /dev/stdin`

    thread=`get_param thread "$query"`
    post=`get_param post "$query"`

    echo "Content-Type: text/plain"
    echo

    # this sets $ip
    post_meta $thread $post
    ban_until "$ip" `date -d +1day +%s`

    echo "User banned"
}

ban_form() {
    thread=`echo "$QUERY_STRING" | cut -d '-' -f 1 | sed 's/[^0-9]//g'`
    post=`echo "$QUERY_STRING" | cut -d '-' -f 2 | sed 's/[^0-9]//g'`

    cat <<EOF
Content-Type: text/html

<!DOCTYPE html>
<html>
<head>
<title>Ban User</title>
`html_head`
</head>

<body>
<header>
<h1>Ban</h1>
</header>
<main>
<p>You are banning someone for posting this post:</p>
`post_html $thread $post`

<p>The IP address that posted this will be banned from posting for 1 day. They
will see a notice at the top of their screen telling them they are banned from
posting including the reason you specify below.</p>

<p>Please enter a reason for the ban and click the ban button.</p>
<form method="POST">
<input type="hidden" name="thread" value="$thread">
<input type="hidden" name="post" value="$post">
<input type="text" name="reason">
<input type="submit" value="Ban">
</form>
</main>
</body>
</html>
EOF
}

case "$REQUEST_METHOD" in
    POST )
        do_ban
        ;;
    GET )
        ban_form
        ;;
esac

