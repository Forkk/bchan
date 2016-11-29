#!/bin/sh

set -e

# Run in the same dir as other scripts even though this one's in a folder.
cd ..

. ./config
. ./html.sh
. ./admins.sh

require_mod


echo "Content-Type: text/html"
echo

cat <<EOF
<!DOCTYPE html>
<html>
<head>
<title>$SITE_TITLE</title>
`html_head`
</head>

<body>
<header>
<h1>Admin Panel</h1>
<a href="$INDEX_URL">Home</a>
</header>

<main>
<p>You are $SESS_USER</p>
<p>Your level is `user_level $SESS_USER`</p>
</main>
</body>
</html>
EOF
