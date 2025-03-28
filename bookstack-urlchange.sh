#!/bin/bash

BOOKSTACK_DIR="/var/www/bookstack"
CURRENT_IP=$(ip addr | grep 'state UP' -A4 | grep 'inet ' | awk '{print $2}' | cut -f1  -d'/')
SCRIPT_USER="${SUDO_USER:-$USER}"
URL_OLD=$(grep "^APP_URL=" "/var/www/bookstack/.env" | cut -d '=' -f 2)

# Check we're running as root and exit if not
[[ $EUID -ne 0 ]] && echo "This script must be ran with root/sudo privileges." >&2 && exit 1

# Check that the bookstack directory exists
[ ! -d "$BOOKSTACK_DIR" ] && echo "BookStack is not installed on this system." >&2 && exit 1

# Check that the bookstack owner is running the script
dir_owner_uid=$(stat -c '%U' "$BOOKSTACK_DIR")
[[ "$SCRIPT_USER" != "$dir_owner_uid" ]] \
&& "This script must be run by the owner of /var/www/bookstack." >&2 && exit 1

# Ask for new URL
echo; echo "Your current IP address: $CURRENT_IP"
echo "Your current BookStack URL: $URL_OLD"; echo
echo "Enter the full http or https address you want to host BookStack on and press [ENTER]."
echo "Examples: 'https://docs.my-site.com' or 'http://${CURRENT_IP}'"
read -r URL

# Check that input makes sense and confirm
[[ "$URL" == "$URL_OLD" ]] && echo "That is already the URL in use" >&2 && exit 1
[[ ! "$URL" =~ ^https?://[A-Za-z0-9]+\.[A-Za-z0-9]+ ]] && echo "Invalid URL format" >&2 && exit 1
echo; echo "Change URL to $URL? [y/N] "
[[ "$(read -e; echo "$REPLY")" == [Yy]* ]] || { echo "No changes were made"; exit; }

# Migrate to new URL
cd /var/www/bookstack
sed -i.bak "s@APP_URL=.*\$@APP_URL=$URL@" .env
php artisan bookstack:update-url --force "$URL_OLD" "$URL"
php artisan cache:clear

echo; echo "URL change complete!"; echo
