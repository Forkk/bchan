# This file defines functions which print pre-defined parts of the html
# document like scripts and stylesheets.

# Prints things that always go in the head tag like stylesheets and meta
# attributes.
html_head() {
    echo '<meta name="viewport" content="width=device-width, initial-scale=1.0">'

    # FIXME: This is a symlink for now. This is not optimal, but we can't serve
    # static files from the cgi directory.
    echo '<link rel="stylesheet" href="//s.forkk.net/bchan-style.css">'
}


html_scripts() {
    echo ""
}


