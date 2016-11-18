# This is a "module" meant to be sourced by cgi screpts to gain access to
# functions for handling query parameters.

urldecode() {
    sed "s@+@ @g;s@%@\\\\x@g" | xargs -0 printf "%b"
}

htmlencode() {
    sed "s/</\\&lt;/g;s/>/\\&gt;/g"
}

