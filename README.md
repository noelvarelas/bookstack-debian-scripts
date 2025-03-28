# Description
These are the scripts I use to set up a BookStack server on a fresh Debian 12 server.

- bookstack-install.sh - Modified version of [the official Ubuntu 24.04 script](https://codeberg.org/bookstack/devops/src/branch/main/scripts/installation-ubuntu-24.04.sh)
that adds a backup restore option and migrates data to a new domain if necessary.
It also runs Certbot at the end if you use an HTTPS domain. It uses MariaDB instead of MySQL.

- bookstack-backup.sh - A cronjob script to create backups that follows [the official backup process.](https://www.bookstackapp.com/docs/admin/backup-restore/)
The backups can be restored using the bookstack-install.sh script on a new machine.
Edit the top config lines with your details, then place the script in your root user's crontab.

- bookstack-update.sh - An update helper script that automates [the official update process.](https://www.bookstackapp.com/docs/admin/updates/)
This is meant to be run manually after confirming that a new release does not require additional steps.
Do not use this without a recent backup available!

- bookstack-urlchange.sh - Changes your BookStack URL in both the .env file and database in case you switch IP addresses or domains.
Do not use this without a recent backup available!
