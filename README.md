# mac-user-cleanup

Deletes inactive local user accounts and home folders on macOS after 30 days.

## Use
1. Edit `THRESHOLD` and `USER_HOME_BASE` in `cleanup_inactive_users.sh`.
2. Deploy both files via MDM (script + LaunchDaemon plist).
3. Logs to `/var/log/user_cleanup.log`.

Test before production.
