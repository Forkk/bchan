# This file defines functions which print pre-defined parts of the html
# document like scripts and stylesheets.

# Prints things that always go in the head tag like stylesheets and meta
# attributes.
html_head() {
    echo '<meta name="viewport" content="width=device-width, initial-scale=1.0">'
    echo '<link rel="stylesheet" href="'$STATIC_URL'/style.css">'
}

# Base template for html pages. This includes all the javascript and
# stylesheets as well as page elements that show on every page such as a nav
# bar and footer. The body should be written to stdin (probably via here-doc)
# and will be inserted into the "<main>" tag on the page.
#
# The first and only argument to this function is the page title.
html_page() {
    cat <<EOF
<!DOCTYPE html>
<html>
<head>
<title>$1</title>
`html_head`
</head>

<body>
<main>
`cat /dev/stdin`
</main>
</body>
</html>
EOF
}

