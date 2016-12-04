#!/bin/bash

set -e

# Run in the same dir as other scripts even though this one's in a folder.
cd ..

. ./config
. ./html.sh
. ./admins.sh

require_mod


echo "Content-Type: text/html"
echo

html_page "Admen Panel" <<EOF
<h1>Admin Panel</h1>
<a href="$INDEX_URL">Home</a>

<p>You are $SESS_USER</p>
<p>Your level is $(user_level "$SESS_USER")</p>
EOF

