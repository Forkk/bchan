#!/bin/sh

set -e

cd ..

. ./config
. ./html.sh
. ./admins.sh

login_page() {
    echo "Content-Type: text/html"
    echo
    html_page "Admin/Moderator Login" <<EOF
<h1>Admin / Moderator Login</h1>
`
    if [ ! -z "$1" ]; then
        cat <<EOF2
<div class="notice notice-red">
    <p>$1</p>
</div>
EOF2
    fi
`
<form method="POST">
    <table>
        <tr>
            <td>Username:</td>
            <td><input type="text" name="username"></td>
        </tr>
        <tr>
            <td>Password:</td>
            <td><input type="password" name="password"></td>
        </tr>
        <tr>
            <td><input type="submit" value="Log in"></td>
        </tr>
    </table>
</form>
EOF
}

do_login() {
    local query=`cat /dev/stdin`
    local pass=`get_param password "$query" | urldecode`
    local user=`get_param username "$query" | urldecode | sed 's/[^a-zA-Z0-9_.-]//g'`

    if auth_check "$user" "$pass"; then
        login_as "$user"
    else
        login_page "Invalid credentials"
    fi
}

case "$REQUEST_METHOD" in
    POST )
        do_login
        ;;
    GET )
        login_page
        ;;
    * )
        echo "Status: 405 Method Not Allowed"
        echo
        ;;
esac
