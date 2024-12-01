#!/bin/bash

# Config
NEW_USER="yournewuser"
SSH_JUMPHOST_V4="yourjumphostipv4"
SSH_JUMPHOST_V6="yourjumphostipv6"
SSH_AUTHORIZED_KEYS=$(cat <<EOF
ssh-ed25519 yourpublickeycharacters user@hostname
ssh-ed25519 morepublickeycharacters user@hostname
EOF
)

# Check that user is root
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root." >&2
  exit 1
fi

# Install updates and firewall
apt update
apt dist-upgrade -y
apt install -y ufw

# Firewall setup
ufw allow from "$SSH_JUMPHOST_V4" to any port 22 proto tcp
ufw allow from "$SSH_JUMPHOST_V6" to any port 22 proto tcp
ufw allow to any port 80 proto tcp
ufw allow to any port 443 proto tcp
ufw --force enable

# Set up new sudo user and ssh keys
adduser --gecos "" "$NEW_USER"
usermod -aG sudo "$NEW_USER"
mkdir /home/"$NEW_USER"/.ssh
chmod 700 /home/"$NEW_USER"/.ssh
echo "$SSH_AUTHORIZED_KEYS" > /home/"$NEW_USER"/.ssh/authorized_keys
chmod 600 /home/"$NEW_USER"/.ssh/authorized_keys
chown -R "$NEW_USER":"$NEW_USER" /home/"$NEW_USER"/.ssh

# Harden sshd_config
sed -i.bak "s@^#\?PermitRootLogin.*\$@PermitRootLogin\ no@" /etc/ssh/sshd_config
sed -i.bak "s@^#\?PasswordAuthentication.*\$@PasswordAuthentication\ no@" /etc/ssh/sshd_config
systemctl restart sshd
