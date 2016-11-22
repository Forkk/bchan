# This file defines functions which print pre-defined parts of the html
# document like scripts and stylesheets.

# Prints things that always go in the head tag like stylesheets and meta
# attributes.
html_head() {
    echo '<meta name="viewport" content="width=device-width, initial-scale=1.0">'
    echo '<link rel="stylesheet" href="'$STATIC_URL'/style.css">'
}


html_scripts() {
    echo ""
}


