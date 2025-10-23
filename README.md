# Mac User Cleanup - Delete inactive accounts

Deletes inactive local user accounts and home folders on macOS after 30 days.  
Designed for Macs bound to Active Directory and deployed via Lightspeed MDM.

---

## Features
- Deletes local user accounts and home directories older than 30 days.
- Skips admin, shared, and system accounts.
- Logs all actions to `/var/log/user_cleanup.log`.
- Safe to deploy via MDM or LaunchDaemon.

---

## Configuration
Edit these variables in `cleanup_inactive_users.sh` before deployment:

```bash
THRESHOLD=30
USER_HOME_BASE="/Users"
LOG_FILE="/var/log/user_cleanup.log"
