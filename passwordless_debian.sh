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

# Prompt user for new hostname
read -p "Enter new hostname: " new_hostname
# Change hostname
hostnamectl set-hostname "$new_hostname"
echo "127.0.1.1 $new_hostname" >> /etc/hosts
# Prompt user for new username and password
read -p "Enter new username: " new_user
read -s -p "Enter password for $new_user: " user_password
echo
read -s -p "Confirm password for $new_user: " user_password_confirm
echo
# Check if passwords match
while [ "$user_password" != "$user_password_confirm" ]; do
    echo "Passwords do not match. Please try again."
    read -s -p "Enter password for $new_user: " user_password
    echo
    read -s -p "Confirm password for $new_user: " user_password_confirm
    echo
done
# Create new user with sudo privileges
useradd -m -s /bin/bash "$new_user"
echo "$new_user:$user_password" | chpasswd
usermod -aG sudo "$new_user"
echo "$new_user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/"$new_user"
# Copy SSH public key to new user's authorized_keys
mkdir -p /home/"$new_user"/.ssh
cp ~/.ssh/authorized_keys /home/"$new_user"/.ssh/
chown -R "$new_user":"$new_user" /home/"$new_user"/.ssh
chmod 700 /home/"$new_user"/.ssh
chmod 600 /home/"$new_user"/.ssh/authorized_keys
# Configure SSH
sed -i '/^PermitRootLogin/d; $a\PermitRootLogin no' /etc/ssh/sshd_config
sed -i '/^PasswordAuthentication/d; $a\PasswordAuthentication no' /etc/ssh/sshd_config
sed -i '/^PubkeyAuthentication/d; $a\PubkeyAuthentication yes' /etc/ssh/sshd_config
sed -i '/^AuthorizedKeysFile/d; $a\AuthorizedKeysFile .ssh/authorized_keys .ssh/authorized_keys2' /etc/ssh/sshd_config
systemctl restart sshd
# Prompt user to install Docker
read -p "Do you want to install Docker? (y/n): " install_docker
if [[ "$install_docker" =~ ^[Yy]$ ]]; then
    # Install Docker
    apt-get update
    apt-get install -y apt-transport-https ca-certificates curl gnupg
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io
    # Install Docker Compose
    curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    # Add user to docker group
    usermod -aG docker "$new_user"
fi