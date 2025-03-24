#!/bin/bash

# Warn user about auto-updating
echo; echo "Please read the official release notes before updating. Some updates may require additional action."
echo "https://www.bookstackapp.com/docs/admin/updates/#version-specific-instructions"
echo "Do not run this script without having a recent backup available."
echo; [[ "$(read -e -p 'Are you sure you want to continue? [y/N] '; echo "$REPLY")" == [Yy]* ]] && echo || exit

# Check we're running as root and exit if not
if [[ $EUID -ne 0 ]]; then
  echo "This script must be ran with root/sudo privileges." >&2
  exit 1
fi

# Check that the bookstack directory exists
if [ ! -d "/var/www/bookstack" ]; then
  echo "BookStack is not installed on this system." >&2
  exit 1
fi

# Check that the bookstack owner is running the script
dir_owner_uid=$(stat -c '%U' "/var/www/bookstack")
SCRIPT_USER="${SUDO_USER:-$USER}"
if [[ "$SCRIPT_USER" != "$dir_owner_uid" ]]; then
  echo "This script must be run by the owner of /var/www/bookstack." >&2
  exit 1
fi

# Update commands
cd /var/www/bookstack
git pull origin release
sudo -u "$SCRIPT_USER" composer install --no-dev
php artisan migrate
php artisan cache:clear
php artisan config:clear
php artisan view:clear

echo "Resetting filesystem permissions..."; echo

# Set the bookstack folders and files to be owned by the script user and have the group www-data
chown -R $SCRIPT_USER:www-data /var/www/bookstack

# Set all bookstack files and folders to be readable, writable & executable by the script user and
# readable & executable by the group and everyone else
chmod -R 755 /var/www/bookstack

# For the listed directories, grant the group (www-data) write-access
chmod -R 775 /var/www/bookstack/storage /var/www/bookstack/bootstrap/cache /var/www/bookstack/public/uploads

# Limit the .env file to only be readable by the user and group, and only writable by the user.
chmod 640 /var/www/bookstack/.env

echo "Done!"
