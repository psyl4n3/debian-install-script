# Passwordless Debian Setup Script

This script is designed to bring a fresh Debian installation and assumes that the root user has a ssh key stored at ~/.ssh/authorized_keys.

## What Does It Do?

Here's a quick rundown of what the script does:

- **Updates and Upgrades:** Updates up your system with the latest packages.
- **User Creation:** Creates a new user with passwordless sudo privileges.
- **Secures SSH:** Tweaks your SSH settings to enhance security by:
  - Disabling root login.
  - Requiring keys for SSH login.
  - Turning off password authentication.
- **Sets Up SSH Keys:** Copies your root user's SSH key to the new user to keep things smooth.
- **Hostname Change:** Lets you set a new hostname for your machine and ensures it plays nicely with your system.
- **Reboot Option:** Gives you the choice to reboot your system after setup (to make sure all changes take effect).

## How to Use It

1. **Download the Script:** You can clone this repo or just copy the script using:
```
git clone https://github.com/psyl4n3/symmetrical-octo-garbanzo.git
```
2. **Make It Executable:** Run 
```
chmod +x passworless_debian.sh` to make sure the script can do its thing.
```
3. **Run It:** Execute the script as a super user:
```
./passwordless_debian.sh
```


## Notes

- The script assumes you're starting with a fresh Debian 12 installation.
- You'll be prompted to enter a few details (like the new user's username and your desired hostname).
- STest the script in a non-production environment.
