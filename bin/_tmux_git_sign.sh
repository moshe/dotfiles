#!/bin/bash
cd "$2" 2>/dev/null || exit 0

# Cache file path based on repo
CACHE_DIR="/tmp/tmux_git_cache"
REPO_HASH=$(echo "$2" | md5)
CACHE_FILE="${CACHE_DIR}/${REPO_HASH}"
LOCK_FILE="${CACHE_DIR}/${REPO_HASH}.lock"
CACHE_TTL=5  # seconds

# Create cache directory if it doesn't exist
mkdir -p "$CACHE_DIR"

# Function to generate git status
generate_status() {
    # Use --no-optional-locks to avoid taking the git index lock.
    # git status only needs the lock for an optional index cache update;
    # skipping it prevents conflicts with real git operations.
    local status_output=$(git --no-optional-locks status --porcelain 2>/dev/null)
    local branch=$(git --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null | sed -e "s/AMVP-\([0-9]*\)//g" -e "s/_/ /g" -e "s/moshe.//" -e "s/-feature//" -e "s/-/ /g" -e 's/^\.//g')

    # Parse status for different indicators
    local has_staged=""
    local has_modified=""
    local has_deleted=""
    local has_added=""

    if [[ -n "$status_output" ]]; then
        # Check for staged files (left column)
        echo "$status_output" | grep -q '^[MADRCU]' && has_staged="^ "

        # Check for modified files (right column M or left column M)
        echo "$status_output" | grep -q '^ M\|^M' && has_modified="M "

        # Check for deleted files
        echo "$status_output" | grep -q '^ D\|^D' && has_deleted="D "

        # Check for untracked files (??)
        echo "$status_output" | grep -q '^??' && has_added="+ "
    fi

    # Write to cache file
    cat > "$CACHE_FILE" <<EOF
BRANCH="$branch"
STAGED="$has_staged"
MODIFIED="$has_modified"
DELETED="$has_deleted"
ADDED="$has_added"
EOF
}

# Check if cache is valid
if [[ -f "$CACHE_FILE" ]]; then
    CACHE_AGE=$(($(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0)))
    if [[ $CACHE_AGE -lt $CACHE_TTL ]]; then
        # Use cached data
        source "$CACHE_FILE" 2>/dev/null
    else
        # Cache expired, regenerate with lock
        (
            flock -x -w 2 200 || exit 1
            # Check again after acquiring lock (another process may have regenerated)
            CACHE_AGE=$(($(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0)))
            if [[ $CACHE_AGE -ge $CACHE_TTL ]]; then
                generate_status
            fi
        ) 200>"$LOCK_FILE"
        source "$CACHE_FILE" 2>/dev/null
    fi
else
    # No cache, generate with lock
    (
        flock -x -w 2 200 || exit 1
        # Check again after acquiring lock
        if [[ ! -f "$CACHE_FILE" ]]; then
            generate_status
        fi
    ) 200>"$LOCK_FILE"
    source "$CACHE_FILE" 2>/dev/null
fi

# Output based on requested indicator
case "$1" in
    "branch")
        echo "$BRANCH"
        ;;
    "staged")
        echo "$STAGED"
        ;;
    "modified")
        echo "$MODIFIED"
        ;;
    "deleted")
        echo "$DELETED"
        ;;
    "added")
        echo "$ADDED"
        ;;
esac
