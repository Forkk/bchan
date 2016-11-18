# This file provides functions for accessing threads.

. ./config


list_threads() {
    # use grep to make sure we only get numbers
    ls -1 "$THREAD_DIR" | grep '[0-9]\+'
}

list_posts() {
    ls -1 "$THREAD_DIR/$1/" | grep '[0-9]\+'
}

# This function finds the next thread's id by listing files in the thread dir,
# sorting them, and adding one to the highest number.
next_thread_id() {
    last_id=`list_threads | sort -r | head -n 1`
    if [ -z "$last_id" ]; then
        echo 0
    else
        echo "$last_id + 1" | bc
    fi
}

next_post_id() {
    last_id=`list_posts $1 | sort -r | head -n 1`
    if [ -z "$last_id" ]; then
        echo 0
    else
        echo "$last_id + 1" | bc
    fi
}

# This function makes a new thread and prints its id.
new_thread() {
    # This chan is anonymous, but we need a way to ban people, so we track some
    # form of identification (currently IP address).
    ip="$1"
    poster="$2"
    first_post="$3"

    id=`next_thread_id`
    dir="$THREAD_DIR/$id"
    mkdir "$dir"

    new_post "$id" "$ip" "$poster" "$first_post"

    echo "$id"
}

new_post() {
    thid="$1"
    ip="$2"
    poster="$3"
    post="$4"

    thdir="$THREAD_DIR/$thid"
    postid=`next_post_id "$thid"`

    cat <<EOF > "$thdir/$postid"
poster=$poster
ip=$ip
date=`date +%s`
----
$post
EOF
}

# Prints the text of a post.
post_text() {
    thid="$1"
    postid="$2"

    cat "$THREAD_DIR/$thid/$postid" | sed -n '/----/,$p' | tail -n +2
}

# Loads the metadata of a post into environment variables.
post_meta() {
    thid="$1"
    postid="$2"

    file="$THREAD_DIR/$thid/$postid"
    poster=`cat "$file" | grep "poster=" | head -n 1 | sed 's/poster=//'`
    ip=`cat "$file" | grep "ip=" | head -n 1 | sed 's/ip=//'`
    date=`cat "$file" | grep "date=" | head -n 1 | sed 's/date=//'`
}

# Renders a post as html
post_html() {
    thid="$1"
    post="$2"
    post_meta "$thid" "$post"
    cat <<EOF
<div class="post">
<p>#$post by $poster on `date -d @$date`</p>
<pre>
`post_text "$thid" "$post"`
</pre>
</div>
EOF
}

