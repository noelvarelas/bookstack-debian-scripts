# Description
These are the scripts I use to set up a BookStack server on a Debian 12 VPS.

- 1-bookstack-vps-setup-debian-12.sh - Initial setup of sudo user, sshd, and firewall.

- 2-bookstack-installation-debian-12.sh - Modified version of [the official Ubuntu 24.04 script](https://codeberg.org/bookstack/devops/src/branch/main/scripts/installation-ubuntu-24.04.sh)
that adds a backup restore option and migrates data to a new domain if necessary. It also runs Certbot at the end if you use an HTTPS domain. It uses MariaDB instead of MySQL.

- 3-bookstack-backup.sh - A cronjob script that follows [the official documentation](https://www.bookstackapp.com/docs/admin/backup-restore/)
instructions on making backups, which can be restored using the previous script on a new machine.
