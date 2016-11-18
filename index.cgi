#!/bin/sh

set -e

echo "Content-Type: text/html"
echo

. ./config
. ./threads.sh


cat <<EOF
<!DOCTYPE html>
<html>
<head>
<title>Bchan</title>
</head>

<body>

<h1>Bchan</h1>

<h2>New Thread</h2>
<form method="POST" action="$URL_ROOT/new-thread.cgi">
    Type an initial post below and click create thread to start a new thread.
    <br/>
    <textarea name="content" rows="8" cols="50"></textarea>
    <br/>
    <input type="submit" value="Create Thread">
</form>

<h2>Threads</h2>
EOF

for th in `list_threads | sort -r`; do
    echo "<h3>Thread $th</h3>"
    echo "<p>First 10 posts:</p>"
    echo "<ul>"
    for post in `seq 0 10`; do
        file="$THREAD_DIR/$th/$post"
        if [ -f "$file" ]; then
            cat <<EOF
<li>`post_text "$th" "$post"`</li>
EOF
        fi
    done
    echo "</ul>"
    echo "<a href=\"$URL_ROOT/thread.cgi?$th\">Full thread</a>"
done

echo "</body></html>"

