#!/bin/bash

BOOKSTACK_DIR="/var/www/bookstack"

SCRIPT_USER="${SUDO_USER:-$USER}"

# Warn user about auto-updating
echo; echo "Please read the official release notes before updating. Some updates may require additional action."
echo "https://www.bookstackapp.com/docs/admin/updates/#version-specific-instructions"
echo "Do not run this script without having a recent backup available."
echo; [[ "$(read -e -p 'Are you sure you want to continue? [y/N] '; echo "$REPLY")" == [Yy]* ]] && echo || exit

# Check we're running as root and exit if not
[[ $EUID -ne 0 ]] && echo "This script must be ran with root/sudo privileges." >&2 && exit 1

# Check that the bookstack directory exists
[ ! -d "$BOOKSTACK_DIR" ] && echo "BookStack was not found. Currently configured for: $BOOKSTACK_DIR." >&2 && exit 1

# Check that the bookstack owner is running the script
dir_owner_uid=$(stat -c '%U' "$BOOKSTACK_DIR")
[[ "$SCRIPT_USER" != "$dir_owner_uid" ]] && echo "This script must be run by the owner of $BOOKSTACK_DIR." >&2 && exit 1

# Update commands
cd "$BOOKSTACK_DIR"
git pull origin release
sudo -u "$SCRIPT_USER" composer install --no-dev
php artisan migrate
php artisan cache:clear
php artisan config:clear
php artisan view:clear

# Reset filesystem permissions
echo "Resetting filesystem permissions..."; echo
chown -R "$SCRIPT_USER":www-data "$BOOKSTACK_DIR"
chmod -R 755 "$BOOKSTACK_DIR"
chmod -R 775 "$BOOKSTACK_DIR"/storage "$BOOKSTACK_DIR"/bootstrap/cache "$BOOKSTACK_DIR"/public/uploads
chmod 640 "$BOOKSTACK_DIR"/.env

echo "Done!"
