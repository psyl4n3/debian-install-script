#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

# Update, upgrade, and autoremove without user interaction
apt-get update -y
apt-get upgrade -y
apt-get autoremove -y

# Prompt for changing the hostname
read -p "Enter the new hostname: " new_hostname
echo $new_hostname > /etc/hostname
hostnamectl set-hostname $new_hostname

# Update /etc/hosts to include the new hostname without disrupting localhost
if ! grep -q "127.0.0.1 $new_hostname" /etc/hosts; then
    echo "127.0.0.1 $new_hostname" >> /etc/hosts
fi

# Prompt for creating a new user
read -p "Enter the username of the new user: " username
adduser --gecos "" $username

# Add new user to the sudoers file for passwordless sudo
echo "$username ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$username

# Modify /etc/ssh/sshd_config to secure SSH
sed -i '/^PermitRootLogin/c\PermitRootLogin no' /etc/ssh/sshd_config
sed -i '/^PubkeyAuthentication/c\PubkeyAuthentication yes' /etc/ssh/sshd_config
sed -i '/^PasswordAuthentication/c\PasswordAuthentication no' /etc/ssh/sshd_config

# Ensure the SSH directory exists for the new user and has appropriate permissions
su - $username -c "mkdir -p ~/.ssh"
su - $username -c "chmod 700 ~/.ssh"

# Copy the key file from the root user to the new user and set appropriate permissions
cp ~/.ssh/authorized_keys /home/$username/.ssh/
chown $username:$username /home/$username/.ssh/authorized_keys
chmod 600 /home/$username/.ssh/authorized_keys

# Restart SSH service
systemctl restart sshd

# Reboot the machine
read -p "Setup is complete. Reboot now? (y/n): " reboot_choice
if [ "$reboot_choice" = "y" ]; then
    reboot
else
    echo "Reboot cancelled. Please reboot manually to complete setup."
fi
