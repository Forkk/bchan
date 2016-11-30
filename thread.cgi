#!/bin/sh

. ./config
. ./param.sh
. ./admins.sh
. ./threads.sh
. ./html.sh

thid=`echo "$QUERY_STRING" | sed 's/[^0-9]//g'`

if [ -z "$thid" ] || [ ! -d "$THREAD_DIR/$thid" ]; then
    echo "Status: 404 Not Found"
    echo "Content-Type: text-plain"
    echo
    html_page <<EOF
<h1>Thread Not Found</h1>
<p>Sorry, I can't seem to find that thread.</p>
EOF
    exit
fi

echo "Content-Type: text/html"
echo

html_page "Thread $thid &ndash; $SITE_TITLE" <<EOF
<h1>Thread $thid</h1>
`ban_notice`
<a href="$INDEX_URL">Back to thread list</a>
<h2>Posts</h2>
`
for post in \`list_posts "$thid"\`; do
    post_html "$thid" "$post"
done
`

<h2>New Post</h2>

<form method="POST" action="$URL_ROOT/new-post.cgi">
    Type your post below and press post.
    <br/>
    <input type="hidden" name="thread" value="$thid">
    <textarea name="content"></textarea>
    <br/>
    <input type="submit" value="Post">
</form>
EOF

