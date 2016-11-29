# This "module" provides functions for managing the ban lists.

. ./config

# The ban file is two columns. The first is the banned IP, and the second is
# the unban date. If the value in the second column is "inf", the IP is
# permabanned.
BAN_FILE=$DATA_DIR/bans

unban() {
    ip="$1"
    if [ -f "$BAN_FILE" ]; then
        sed -i "/$ip/d" "$BAN_FILE"
    fi
}

# Adds the given IP to the permanent ban list.
perm_ban() {
    ip="$1"
    # Remove any existing bans for the IP.
    unban "$ip"
    echo "$ip inf" >> $BAN_FILE
}

# Bans the given IP until the given date.
ban_until() {
    ip="$1"
    date="$2"
    unban "$ip"
    echo "$ip $date" >> $BAN_FILE
} 

# Exits success if the given IP is banned.
is_banned() {
    ip="$1"
    now=`date +%s`

    if [ ! -f "$BAN_FILE" ]; then
        return 1 # Nobody is banned
    fi

    if grep "$ip" "$BAN_FILE" 2>&1 >/dev/null; then
        ban_end=`grep "$ip" "$BAN_FILE" | head -n1 | awk '{ print $2; }'`

        if [ "$ban_end" == "inf" ] || [ "$now" -gt "$ban_end" ]; then
            return 1
        else
            return 0
        fi
    else
        return 1
    fi
}

# Prints a ban notice box if the current REMOTE_ADDR is banned.
ban_notice() {
    if is_banned "$REMOTE_ADDR"; then
        cat <<EOF
<div class="notice notice-red">
    <p>You are banned from posting.</p>
</div>
EOF
    fi
}

