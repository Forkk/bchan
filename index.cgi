#!/bin/bash

set -e

. ./config
. ./threads.sh
. ./html.sh
. ./bans.sh

echo "Content-Type: text/html"
echo

html_thread_list() {
    for th in $(list_threads | sort -rg); do
        echo '<div class="thread">'
        echo "<h2>Thread $th</h2>"
        for post in $(seq 0 5); do
            file="$THREAD_DIR/$th/$post"
            if [ -f "$file" ]; then
                post_html "$th" "$post"
            fi
        done
        echo "<a href=\"$URL_ROOT/thread.cgi?$th\">Full thread</a>"
        echo "</div>"
    done
}

html_page "$SITE_TITLE" <<EOF
$(ban_notice)

<h2>What is this?</h2>
<p>$SITE_TITLE is a simple clone of 4chan without images (for now) written entirely
in bash. It's not meant to be anything big, just a little toy to see if I could
make a bulletin board type thing using only shell scripts.</p>

<p>To use $SITE_TITLE, you can either start a new thread by typing the initial post
in the box below, or you can post on one of the existing threads (listed
below). All posts are anonymous, although your IP address will be stored along
with your posts for banning purposes.</p>

<p>There aren't really any rules right now, just don't be a dick, don't spam,
etc.</p>

<h2>New Thread</h2>
<form method="POST" action="$URL_ROOT/new-thread.cgi">
    Type an initial post below and click create thread to start a new thread.
    <br/>
    <textarea name="content"></textarea>
    <br/>
    <input type="submit" value="Create Thread">
</form>

$(html_thread_list)
EOF
