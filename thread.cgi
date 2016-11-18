#!/bin/sh

. ./config
. ./param.sh
. ./threads.sh

thid=`echo "$QUERY_STRING" | sed 's/[^0-9]//g'`

if [ -z "$thid" ]; then
    echo "Content-Type: text/plain"
    echo
    echo "Invalid thread ID."
    exit
fi

if [ ! -d "$THREAD_DIR/$thid" ]; then
    echo "Content-Type: text-plain"
    echo
    echo "Sorry, I can't seem to find thread $thid."
    exit
fi

echo "Content-Type: text/html"
echo

cat <<EOF
<!DOCTYPE html>
<html>
<head>
<title>Thread $thid -- Bchan</title>
</head>

<body>
<h1>Thread $thid</h1>
<a href="$INDEX_URL">Back to thread list</a>

<h2>Posts</h2>
EOF

for post in `list_posts "$thid"`; do
    echo "<h3>Post $post</h2>"
    echo "<pre>"
    post_text "$thid" "$post"
    echo "</pre>"
done

cat <<EOF
<h2>New Post</h2>

<form method="POST" action="$URL_ROOT/new-post.cgi">
    Type your post below and press post.
    <br/>
    <input type="hidden" name="thread" value="$thid">
    <textarea name="content" rows="8" cols="50"></textarea>
    <br/>
    <input type="submit" value="Post">
</form>

</body>
</html>
EOF
