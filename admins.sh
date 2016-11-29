# This "module" provides functions for managing and accessing admin and
# moderator accounts as well as their login sessions.

. ./config
. ./param.sh

# The admin list. This is a three-column file where each line contains a
# username, that user's access level (either "admin" or "mod"), and then the
# user's hashed password.
ADMIN_FILE=$DATA_DIR/admins

# File to store session information.
SESS_FILE=$DATA_DIR/sess

# Exits successfully if the current session is logged in as an admin.
is_admin() {
    if whoami; then
        local level=`user_level "$SESS_USER"`
        if [ "$level" = "admin" ]; then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
}

is_mod() {
    if whoami; then
        local level=`user_level "$SESS_USER"`
        if [ "$level" = "mod" ] || [ "$level" = "admin" ]; then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
}

# Requires that the user is a moderator. If not, responds with status 403 and
# prints an error. This should be done before the page prints anything.
require_mod() {
    if ! is_mod; then
        echo "Status: 403 Forbidden"
        echo "Content-Type: text/plain"
        echo
        echo "You don't have access to this page."
        exit 0
    fi
}

require_admin() {
    if ! is_admin; then
        echo "Status: 403 Forbidden"
        echo "Content-Type: text/plain"
        echo
        echo "You don't have access to this page."
        exit 0
    fi
}

# Sends a web response that logs in as the given user. This terminates the
# script. This prints an entire CGI response and should be done before the
# script has printed anything.
login_as() {
    sessid=`gen_sessid`
    # Set our new session
    echo "$1 "`date +%s`" $sessid" >> $SESS_FILE

    echo "Content-Type: text/html"
    echo "Set-Cookie: sessid=$sessid; HtmlOnly; Path=/"
    echo
    echo "<p>Logged in as $1</p>"
    echo "<a href=\"$URL_ROOT/admin/index.cgi\">Admin panel</a>"
    exit 0
}

# NOTE: Some functions here contain code that handles plaintext passwords. It
# is critical that any variables storing sensitive user info, such as
# passwords, are declared as local variables. That is, use "local pass=$2"
# instead of "pass=$2".

# Exits success if the given username and password authenticate successfully.
auth_check() {
    local user="$1"
    local pass="$2"

    local inhash=`hash_passwd "$pass"`
    local uhash=`user_hash "$user"`

    if [ "$inhash" = "$uhash" ]; then
        # Authentication succeeded.
        return 0
    else
        return 1
    fi
}

# Prints the user level for the given user.
user_level() {
    local user="$1"
    cat "$ADMIN_FILE" | grep "$user" | awk '{ print $2; }'
}

# Prints the hashed password for the given user.
user_hash() {
    local user="$1"
    cat "$ADMIN_FILE" | grep "$user" | awk '{ print $3; }'
}

# TODO: Salt passwords too
hash_passwd() {
    echo -n "$1" | sha512sum | awk '{ print $1; }'
}

# Checks who the current session ID is logged in as. Stores the result in
# "$SESS_USER" if there is a user. If the session ID is invalid or expired,
# returns nonzero.
whoami() {
    local sessid=`get_cookie sessid`
    if [ -z "$sessid" ]; then
        return 1
    fi

    if whois_sessid "$sessid"; then
        return 0
    else
        return 1
    fi
}

# Checks who the given session is logged in as. Stores the result in
# "$SESS_USER" if there is a user. If the session ID is invalid or expired,
# returns nonzero.
whois_sessid() {
    sess_info=`cat "$SESS_FILE" | grep "$1"`
    if [ "$?" = "0" ]; then
        SESS_USER=`echo "$sess_info" | awk '{ print $1; }'`
        return 0
    else
        return 1
    fi
}

gen_sessid() {
    uuidgen
}

