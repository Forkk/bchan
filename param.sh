# This is a "module" meant to be sourced by cgi screpts to gain access to
# functions for handling query parameters.

urldecode() {
    sed "s@+@ @g;s@%@\\\\x@g" | xargs -0 printf "%b"
}

htmlencode() {
    sed "s/</\\&lt;/g;s/>/\\&gt;/g"
}

# Gets the raw (url-encoded) value of a named parameter from the given query
# string.
get_param() {
    local pname="$1"
    local query="$2"
    for kv in `echo "$query" | tr "&" "\n"`; do
        if echo "$kv" | grep "$pname=.\+" 2>&1 > /dev/null; then
            echo -n "$kv" | sed 's/'"$pname"'=//'
        fi
    done
    unset kv
}

# Checks the string HTTP_COOKIE for a cookie with the given name and prints the
# value.
get_cookie() {
    local name="$1"

    for kv in `echo "$HTTP_COOKIE" | sed 's/; /\n/g'`; do
        if echo "$kv" | grep "$name=.\+" 2>&1 > /dev/null; then
            echo -n "$kv" | sed 's/'"$name"'=//'
            unset kv
            return 0
        fi
    done
    unset kv
}

