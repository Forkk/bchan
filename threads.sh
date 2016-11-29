# This file provides functions for accessing threads.

. ./config
. ./bans.sh
. ./admins.sh

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

    if is_banned "$ip"; then
        error="You are banned from posting"
        return 1
    fi

    id=`next_thread_id`
    dir="$THREAD_DIR/$id"
    mkdir "$dir"

    if new_post "$id" "$ip" "$poster" "$first_post"; then
        echo "$id"
    else
        rmdir "$dir"
        return 1
    fi
}

# Writes a new post in the given thread. Returns nonzero and sets an error
# message in the "error" variable if posting fails for some reason.
new_post() {
    thid="$1"
    ip="$2"
    poster="$3"
    post="$4"

    if is_banned "$ip"; then
        error="You are banned from posting"
        return 1
    fi

    if [ -z "$post" ]; then
        error="Can't post empty text"
        return 1
    fi

    # If the post is too long.
    if [ "${#post}" -gt "$MAX_POST_LEN" ]; then
        error="Post can't be longer than $MAX_POST_LEN characters."
        return 1
    fi

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
<p>#$post by $poster on `date -d @$date`
EOF
    if is_mod; then
        cat <<EOF
<a href="$URL_ROOT/admin/ban.cgi?${thid}-${post}">ban</a> |
<a href="$URL_ROOT/admin/rm-post.cgi?${thid}-${post}">remove</a>
EOF
    fi
    cat <<EOF
</p>
<pre>
`post_text "$thid" "$post"`
</pre>
</div>
EOF
}

