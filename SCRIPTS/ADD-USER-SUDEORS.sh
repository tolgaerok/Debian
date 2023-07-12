#!/bin/bash
# Tolga Erok  6/7/2023
# Add the current user to the list of debian sudoers.

# Check if the script is being run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    sleep 3
    exit 0
fi

# Get the username of the current user
current_user=$(logname)

# Check if the current user is already in sudoers
if grep -q "^$current_user" /etc/sudoers; then
    echo -e "\n\e[33mUser $current_user is already in the sudoers file.\e[0m"
    sleep 3
    exit 0
fi

# Backup the sudoers file
cp /etc/sudoers /etc/sudoers.backup

# Add the current user to sudoers
echo "$current_user ALL=(ALL:ALL) ALL" >>/etc/sudoers

# Verify if the modification was successful
if [ $? -eq 0 ]; then
    echo -e "\n\e[33mUser $current_user has been added to the sudoers file successfully.\e[0m"
    sleep 3
else
    echo -e "\n\e[34mFailed to add user $current_user to the sudoers file.\e[0m"
    sleep 2
    # Restore the backup
    mv /etc/sudoers.backup /etc/sudoers
fi
