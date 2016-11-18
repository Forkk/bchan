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
    uid="$1"
    first_post="$2"

    id=`next_thread_id`
    dir="$THREAD_DIR/$id"
    mkdir "$dir"

    new_post "$id" "$uid" "$first_post"

    echo "$id"
}

new_post() {
    thid="$1"
    uid="$2"
    post="$3"

    thdir="$THREAD_DIR/$thid"
    postid=`next_post_id "$thid"`

    cat <<EOF > "$thdir/$postid"
poster=$uid
date=`date`
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

