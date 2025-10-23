#!/bin/zsh
# cleanup_inactive_users.sh
# Deletes local user accounts and home folders not used for X days.
# Tested on macOS Sonoma / Sequoia
# Version: 1.0

# ===========================
# CONFIGURATION
# ===========================

# Inactivity threshold in days
THRESHOLD=30

# Folder path where user home directories are stored
# Change if you use a custom mount path
USER_HOME_BASE="/Users"

# Path to log file (rotate with your log policy)
LOG_FILE="/var/log/user_cleanup.log"

# ===========================
# FUNCTIONS
# ===========================

log() {
  /bin/echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | /usr/bin/tee -a "$LOG_FILE"
}

delete_user() {
  local username="$1"
  local userhome="$2"

  log "Deleting local account and home for: $username"
  /usr/bin/dscl . -delete "/Users/$username" 2>/dev/null
  /bin/rm -rf "$userhome"
}

# ===========================
# MAIN
# ===========================

log "---- Starting user cleanup (threshold ${THRESHOLD}d) ----"

# Loop through each local home folder
for userhome in "$USER_HOME_BASE"/*; do
  # skip if not a directory
  [[ -d "$userhome" ]] || continue

  username=$(basename "$userhome")

  # Skip built-in and admin accounts
  case "$username" in
    Shared|Administrator|admin|root)
      continue
      ;;
  esac

  # Skip users in the admin group
  if /usr/bin/dseditgroup -o checkmember -m "$username" admin | grep -q "yes"; then
    continue
  fi

  # Get last login timestamp from `last` or fallback to folder mtime
  last_login_epoch=$(/usr/bin/last -1 "$username" | awk '{print $5, $6, $7, $8}' | xargs -I{} date -j -f "%b %d %T %Y" "{} $(date +%Y)" +%s 2>/dev/null)
  if [[ -z "$last_login_epoch" ]]; then
    last_login_epoch=$(/usr/bin/stat -f "%m" "$userhome")
  fi

  # Calculate inactivity in days
  now_epoch=$(date +%s)
  inactive_days=$(( (now_epoch - last_login_epoch) / 86400 ))

  if (( inactive_days > THRESHOLD )); then
    log "User $username inactive for ${inactive_days}d — deleting."
    delete_user "$username" "$userhome"
  else
    log "User $username active (${inactive_days}d since last use) — keeping."
  fi
done

log "---- Cleanup complete ----"
exit 0
