#!/bin/bash

# My personal debian 12 installer, KDE PLASMA
# Tolga Erok
# 28/6/2023

# Check if Script is Run as Root:
if [[ $EUID -ne 0 ]]; then
    echo "You must be a root user to run this script, please run sudo ./install.sh" 2>&1
    exit 1
fi

username=$(id -u -n 1000)
builddir=$(pwd)

USER_PIC="/home/$username/Pictures/CUSTOM-WALLPAPERS"
SAMBA="/etc/samba"
SMB_DIR="$builddir/SAMBA"
WALLPAPERS_DIR="$builddir/WALLPAPER"

# Update packages list and update system:
echo "$USER"
sudo sh -c 'echo "deb https://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
deb-src https://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
deb https://deb.debian.org/debian-security/ bookworm-security main contrib non-free non-free-firmware
deb-src https://deb.debian.org/debian-security/ bookworm-security main contrib non-free non-free-firmware
deb https://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware
deb-src https://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware
deb https://deb.debian.org/debian bookworm-backports main contrib non-free non-free-firmware
deb-src https://deb.debian.org/debian bookworm-backports main contrib non-free non-free-firmware
" > /etc/apt/sources.list'

sudo apt update && sudo apt list --upgradable && sudo apt upgrade -y

# Install nala first:
sudo apt install nala netselect-apt -y

# Find fastest mirrors. ( Optional ):
echo "Finding fastest mirrors ..."
sudo netselect-apt

echo "List of fastest mirrors saved into home directory ..."
sleep 2

# Install Linux Firmware and base packages:
sudo apt install -y firmware-linux firmware-linux-nonfree firmware-misc-nonfree linux-headers-$(uname -r) dkms

# Support for additional file systems:
filesystem_packages=(
    btrfs-progs exfatprogs f2fs-tools hfsprogs hfsplus jfsutils lvm2 nilfs-tools
    reiserfsprogs reiser4progs udftools xfsprogs disktype
)

filesystem_explanations=(
    "btrfs-progs              : Tools for managing Btrfs file systems."
    "exfatprogs               : Utilities for exFAT file system."
    "f2fs-tools               : Utilities for Flash-Friendly File System (F2FS)."
    "hfsprogs                 : Tools for HFS and HFS+ file systems."
    "hfsplus                  : Tools for HFS+ file system."
    "jfsutils                 : Utilities for JFS (Journaled File System)."
    "lvm2                     : Logical Volume Manager 2 utilities."
    "nilfs-tools              : Tools for NILFS (New Implementation of a Log-structured File System)."
    "reiserfsprogs            : Tools for ReiserFS file system."
    "reiser4progs             : Tools for Reiser4 file system."
    "udftools                 : Tools for UDF (Universal Disk Format) file system."
    "xfsprogs                 : Tools for managing XFS file systems."
    "disktype                 : Detects the content format of a disk or disk image."
)

echo "The following packages will be installed:"
for ((i = 0; i < ${#filesystem_packages[@]}; i++)); do
    echo "- ${filesystem_explanations[i]}"
done

echo
read -p "Do you want to proceed with the installation? (y/n): " choice

if [[ $choice =~ ^[Yy]$ ]]; then
    echo "Installing the packages..."
    sudo apt install -y "${filesystem_packages[@]}"
    echo "Package installation completed."
else
    echo "Package installation skipped."
fi

qt5_packages=(
    qt5-style-plugins
)

qt5_explanations=(
    "qt5-style-plugins:     Plugins for QT applications to use GTK-based styles."
)

echo "The following packages will be installed:"
for ((i = 0; i < ${#qt5_packages[@]}; i++)); do
    echo "- ${qt5_packages[i]} : ${qt5_explanations[i]}"
done

echo
read -p "Do you want to proceed with the installation? (y/n): " choice

if [[ $choice =~ ^[Yy]$ ]]; then
    echo "Installing the packages..."
    sudo apt install -y "${qt5_packages[@]}"
    echo "Package installation completed."
else
    echo "Package installation skipped."
fi

echo
read -p "Do you want to set the QT_QPA_PLATFORMTHEME environment variable? (y/n): " set_variable

if [[ $set_variable =~ ^[Yy]$ ]]; then
    echo "Setting the environment variable..."
    echo "export QT_QPA_PLATFORMTHEME=gtk2" >>~/.profile
    echo "Environment variable has been set."
else
    echo "Skipping environment variable setup."
fi

# The default non-free firmware only gives you basic functionality. To get the most out of your
# Brodcom WiFi chip, install the following firmware packages::
echo "Checking if Broadcom Wi-Fi is available on the device..."

if lspci -nnk | grep -i broadcom &>/dev/null; then
    echo "Broadcom Wi-Fi detected. Installing and enabling 'ALL' Wi-Fi functions..."
    sudo apt install -y broadcom-sta-dkms broadcom-sta-common firmware-brcm80211
    sleep 2
else
    echo "Broadcom Wi-Fi is not available on this device."
fi

sleep 2

# Install Bluetooth packages:
echo "Checking if Bluetooth is available on the device..."

if lspci -nnk | grep -i bluetooth &>/dev/null; then
    echo "Bluetooth detected on the device."

    read -rp "Do you want to install Bluetooth packages? (y/n): " choice

    if [[ $choice =~ ^[Yy]$ ]]; then
        echo "Installing and enabling 'ALL' Bluetooth functions..."

        packages=(
            "bluetooth:                       The Bluetooth core libraries and utilities."
            "bluez:                           The official Bluetooth protocol stack for Linux."
            "bluez-tools:                     Command-line utilities for interacting with Bluetooth devices."
            "bluez-firmware:                  Firmware files for specific Bluetooth devices."
            "bluez-cups:                      Integration of Bluetooth printing support with CUPS (Common UNIX Printing System)."
            "pulseaudio-module-bluetooth:     PulseAudio module for Bluetooth audio support."
            "pulseaudio-module-zeroconf:      Zeroconf support for PulseAudio Bluetooth audio devices."
        )

        echo "The following Bluetooth packages will be installed:"
        for package in "${packages[@]}"; do
            echo "- $package"
        done

        read -rp "Proceed with the installation? (y/n): " install_choice

        if [[ $install_choice =~ ^[Yy]$ ]]; then
            sudo apt install -y bluetooth bluez bluez-tools bluez-firmware bluez-cups bluez-tools pulseaudio-module-bluetooth pulseaudio-module-zeroconf
            sleep 2
            echo "Bluetooth packages installed successfully."
        else
            echo "Bluetooth packages installation skipped."
        fi
    else
        echo "Bluetooth packages installation skipped."
    fi
else
    echo "Bluetooth is not available on this device."
fi

# Accsess Root through GUI in KDE (X11 Only):
# sudo apt install -y dbus-x11 policykit-1

# Open Settings as Root:
# sudo pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY KDE_SESSION_VERSION=5 KDE_FULL_SESSION=true dbus-launch systemsettings5

# Install some software:
software_packages=(
    acl attr cifs-utils dnsutils ffmpeg ffmpegthumbnailer firmware-realtek flatpak
    gdebi gnome-software-plugin-flatpak gstreamer1.0-libav gstreamer1.0-plugins-bad
    gstreamer1.0-plugins-ugly gstreamer1.0-tools gstreamer1.0-vaapi htop
    krb5-config krb5-user kdegraphics-thumbnailers libavcodec-extra libdvdcss2
    libdvd-pkg libnss-winbind libpam-winbind neofetch ntp ntpdate
    plasma-discover-backend-flatpak plocate python3-setproctitle rhythmbox samba
    simplescreenrecorder snmp software-properties-common sntp synaptic terminator
    ttf-mscorefonts-installer tumbler-plugins-extra vlc winbind rar unrar p7zip-rar nvidia-detect
)

software_explanations=(
    "acl:                        Access control list utilities for file permissions management."
    "attr:                       Tools for managing extended attributes on filesystems."
    "cifs-utils:                 Utilities for mounting and managing CIFS/SMB file systems."
    "dnsutils:                   DNS utilities for querying DNS servers."
    "ffmpeg:                     Complete, cross-platform solution for recording, converting, and streaming audio and video."
    "ffmpegthumbnailer:          Lightweight video thumbnailer."
    "firmware-realtek:           Firmware files for Realtek WiFi cards."
    "flatpak:                    Application sandboxing and distribution framework."
    "gdebi:                      Simple tool for installing deb packages."
    "gnome-software-plugin-flatpak: GNOME Software plugin for Flatpak integration."
    "gstreamer1.0-libav:         GStreamer plugins for the libav codec library."
    "gstreamer1.0-plugins-bad:   GStreamer plugins from the 'bad' set."
    "gstreamer1.0-plugins-ugly:  GStreamer plugins from the 'ugly' set."
    "gstreamer1.0-tools:         Tools for GStreamer multimedia framework."
    "gstreamer1.0-vaapi:         GStreamer plugins for video decoding/encoding using VA-API."
    "htop:                       Interactive process viewer and system monitor."
    "krb5-config:                Configuration files for Kerberos clients."
    "krb5-user:                  Basic Kerberos programs for client machines."
    "kdegraphics-thumbnailers:   Graphics file format thumbnailers for KDE."
    "libavcodec-extra:           Extra multimedia codecs for libavcodec."
    "libdvdcss2:                 Library for accessing encrypted DVDs."
    "libdvd-pkg:                 Package for installing DVD support on Debian."
    "libnss-winbind:             Name Service Switch module for Winbind."
    "libpam-winbind:             Pluggable Authentication Module for Winbind."
    "neofetch:                   Fast, highly customizable system info script."
    "ntp:                        Network Time Protocol daemon and utility programs."
    "ntpdate:                    Client for setting system time from NTP servers."
    "plasma-discover-backend-flatpak: Flatpak backend for Plasma Discover."
    "plocate:                    Fast filesystem search tool."
    "python3-setproctitle:       Allow customization of the process title."
    "rhythmbox:                  Music player and organizer for GNOME."
    "samba:                      SMB/CIFS file, print, and login server for Unix."
    "simplescreenrecorder:       Screen recorder for Linux."
    "snmp:                       SNMP (Simple Network Management Protocol) applications."
    "software-properties-common: Software properties common utilities."
    "sntp:                       Simple Network Time Protocol (SNTP) client."
    "synaptic:                   Graphical package manager for apt."
    "terminator:                 Multiple GNOME terminals in one window."
    "ttf-mscorefonts-installer:  Installer for Microsoft TrueType core fonts."
    "tumbler-plugins-extra:      Additional plugins for the tumbler thumbnail rendering service."
    "vlc:                        Multimedia player and streaming server."
    "winbind:                    Samba utility for resolving user and group information from Windows NT servers."
    "rar:                        Archive manager for RAR files."
    "unrar:                      Extract files from RAR archives."
    "p7zip-rar:                  RAR support for p7zip."
    "nvidia-detect:              NVIDIA GPU detection utility."
)

echo "The following packages will be installed:"
for ((i = 0; i < ${#software_packages[@]}; i++)); do
    echo "- ${software_explanations[i]}"
done

echo
read -p "Do you want to proceed with the installation? (y/n): " choice

if [[ $choice =~ ^[Yy]$ ]]; then
    echo "Installing the packages..."
    sudo apt install -y "${software_packages[@]}"
    echo "Package installation completed."
else
    echo "Package installation skipped."
fi

# Setup sudo dpkg-reconfigure libdvd-pkg:
echo
echo "The necessary components for DVD playback are going to be properly installed and configured on your system...."
sleep 3
sudo dpkg-reconfigure libdvd-pkg

# Set-up flatpak and some flatpak software:
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo flatpak install -y flathub com.sindresorhus.Caprine

# Download teamviewer:
download_url="https://download.teamviewer.com/download/linux/teamviewer_amd64.deb?utm_source=google&utm_medium=cpc&utm_campaign=au%7Cb%7Cpr%7C22%7Cjun%7Ctv-core-download-sn%7Cfree%7Ct0%7C0&utm_content=Download&utm_term=download+teamviewer"
download_location="/tmp/teamviewer.x86_64.deb"

echo "Downloading teamviewer..."
wget -O "$download_location" "$download_url"

# Install Visual Studio Code:
echo "Installing teamviwer..."
sudo dpkg -i "$download_location"
sudo apt-get install "$download_location" -f -y

# Cleanup
echo "Cleaning up..."
rm "$download_location"

# Download Visual Studio Code
download_url="https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
download_location="/tmp/vscode.deb"

echo "Downloading Visual Studio Code..."
wget -O "$download_location" "$download_url"

# Install Visual Studio Code
echo "Installing Visual Studio Code..."
sudo dpkg -i "$download_location"
sudo apt-get install "$download_location" -f -y

# Cleanup
echo "Cleaning up..."
rm "$download_location"

echo "Installation completed."

# Install system components for powershell
sudo apt update && sudo apt install -y curl gnupg apt-transport-https

# Save the public repository GPG keys
curl https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --yes --dearmor --output /usr/share/keyrings/microsoft.gpg

# Register the Microsoft Product feed
sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/microsoft-debian-bullseye-prod bullseye main" > /etc/apt/sources.list.d/microsoft.list'

# Install PowerShell
sudo apt update && sudo apt install -y powershell

# Start PowerShell
# pwsh

# Check GPU information
gpu_info=$(lspci | grep -i 'VGA\|3D')
if [[ -z $gpu_info ]]; then
    echo "No GPU found."
    exit 1
fi

# Check if NVIDIA GPU is present
if [[ $gpu_info =~ "NVIDIA" ]]; then
    # Check if NVIDIA drivers are already installed
    if nvidia-smi &>/dev/null; then
        read -r -p "NVIDIA drivers are already installed" -t 2 -n 1 -s
        echo "."
    else
        # Install NVIDIA drivers
        sudo apt update
        sudo apt install nvidia-driver firmware-misc-nonfree -y
        sudo apt install -y nvidia-driver
        echo "NVIDIA drivers installed successfully."
    fi

    # Run NVIDIA settings
    sudo nvidia-settings

else
    # Install video acceleration for HD Intel i965
    sudo apt update
    sudo apt install -y i965-va-driver libva-drm2 libva-x11-2 vainfo
    echo "Video acceleration drivers installed successfully."
fi

# Samba configurations files
read -r -p "Copying samba files? 
" -t 2 -n 1 -s

# Define the backup folder path
backup_folder="/etc/samba/backup"

# Create the backup folder if it doesn't exist
sudo mkdir -p "$backup_folder"

# Define the original folder path
original_folder="/etc/samba/ORIGINAL"

# Create the original folder if it doesn't exist
sudo mkdir -p "$original_folder"

# Enable extglob option
shopt -s extglob

# Move contents of /etc/samba (excluding ORIGINAL folder) to original folder
sudo mv /etc/samba/!(ORIGINAL) "$original_folder"

# Copy contents of /etc/samba to backup folder
sudo cp -R "$original_folder"/* "$backup_folder"

# Check if the SMB_DIR exists
if [ ! -d "$SMB_DIR" ]; then
    echo "Error: $SMB_DIR directory not found."
    exit 1
fi

# Copy the files from SMB_DIR to TARGET_DIR
cp -R "$SMB_DIR"/* "$SAMBA"

# Check if the copy operation was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to copy files from $SMB_DIR to $SAMBA."
    exit 1
fi

echo ""
echo "Samba Files copied successfully!"
echo "SMB_DIR: $SMB_DIR"
echo "SMB TARGET_DIR: $SAMBA"
echo ""

# Refresh /etc/samba
sudo systemctl restart smb.service

read -r -p "Continuing...
" -t 1 -n 1 -s

# Create samba user/group
read -r -p "Install samba and create user/group
" -t 2 -n 1 -s

# Prompt for the desired username for samba
read -p $'\n'"Enter the USERNAME to add to Samba: " sambausername

# Prompt for the desired name for samba
read -p $'\n'"Enter the GROUP name to add username to Samba: " sambagroup

sudo groupadd $sambagroup
sudo useradd -m $sambausername
sudo smbpasswd -a $sambausername
sudo usermod -aG $sambagroup $sambausername

read -r -p "
Continuing..." -t 1 -n 1 -s

# Configure custom samba folder
read -r -p "Create and configure custom samba folder
" -t 2 -n 1 -s

sudo mkdir /home/Deb12
sudo chgrp samba /home/Deb12
sudo chmod 770 /home/Deb12

read -r -p "
Continuing..." -t 1 -n 1 -s

# Configure usershares plugin
read -r -p "Create and configure the Samba Filesharing Plugin ...
" -t 3 -n 1 -s

# Prompt for the desired username
read -p $'\n'"Enter the username to configure Samba Filesharing Plugin for: " username

# Set umask value
umask 0002

# Set the shared folder path
shared_folder="/home/$username"

# Set permissions for the shared folder and parent directories (excluding hidden files and .cache directory)
find "$shared_folder" -type d ! -path '/.' ! -path '/.cache' -exec chmod 0757 {}
2>/dev/null

# Create the sambashares group if it doesn't exist
sudo groupadd -r sambashares

# Create the usershares directory and set permissions
sudo mkdir -p /var/lib/samba/usershares
sudo chown $username:sambashares /var/lib/samba/usershares
sudo chmod 1770 /var/lib/samba/usershares

# Restore SELinux context for the usershares directory
sudo restorecon -R /var/lib/samba/usershares

# Add the user to the sambashares group
sudo gpasswd sambashares -a $username

# Add the user to the sambashares group (alternative method)
sudo usermod -aG sambashares $username

# Set permissions for the user's home directory
sudo chmod 0757 /home/$username

# Enable and start SMB and NMB services
sudo systemctl enable smb.service nmb.service
sudo systemctl start smb.service nmb.service

# Restart SMB and NMB services (optional)
sudo systemctl restart smb.service nmb.service

# Check Samba configuration
sudo testparm -s

# Prompt for user to open browser to kde store - share plugin
read -p $'\n'"Press Enter to open the Samba Filesharing Plugin website. Please select [ install ] when ready ...  "

# Check if Firefox is installed
if command -v firefox >/dev/null 2>&1; then
    sudo -u $username firefox "https://apps.kde.org/kdenetwork_filesharing/"
    exit 0
fi

# Check if Chrome is installed
if command -v google-chrome-stable >/dev/null 2>&1; then
    sudo -u $username google-chrome-stable "https://apps.kde.org/kdenetwork_filesharing/"
    exit 0
fi

# If neither Firefox nor Chrome is found, display an error message
echo "Error: Neither Firefox nor Chrome is installed."

read -r -p "
Continuing ... " -t 1 -n 1 -s

# Configure fstab
read -r -p "Configure fstab
" -t 2 -n 1 -s

# Backup the original /etc/fstab file
sudo cp /etc/fstab /etc/fstab.backup

# Define the mount entries
mount_entries=(
    "# Custom mount points"
    "//192.168.0.20/LinuxData /mnt/linux-data cifs credentials=/etc/samba/credentials,uid=tolga,gid=samba,file_mode=0777,dir_mode=0777,x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s 0 0"
    "//192.168.0.20/LinuxData/HOME/PROFILES /mnt/home-profiles cifs credentials=/etc/samba/credentials,uid=tolga,gid=samba,file_mode=0777,dir_mode=0777,x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s 0 0"
    "//192.168.0.20/LinuxData/BUDGET-ARCHIVE/ /mnt/Budget-Archives cifs credentials=/etc/samba/credentials,uid=tolga,gid=samba,file_mode=0777,dir_mode=0777,x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s 0 0"
    "//192.168.0.20/WINDOWSDATA /mnt/windows-data cifs credentials=/etc/samba/credentials,uid=tolga,gid=samba,file_mode=0777,dir_mode=0777,x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s 0 0"
)

# Append the mount entries to /etc/fstab
for entry in "${mount_entries[@]}"; do
    echo "$entry" | sudo tee -a /etc/fstab >/dev/null
done

echo "Mount entries added to /etc/fstab.
"

# Check if systemd is installed
if ! command -v systemctl >/dev/null 2>&1; then
    echo "Systemd is not installed."

    # Check if the system is Debian-based
    if command -v apt-get >/dev/null 2>&1; then
        echo "Installing systemd for Debian-based systems..."
        sudo apt-get update
        sudo apt-get install systemd -y
        echo "Systemd has been installed."   
    else
        echo "Unsupported distribution. Cannot install systemd."
        exit 1
    fi
fi

# Check if systemd is running
if systemctl is-active systemd >/dev/null 2>&1; then
    echo "Systemd is running."

    # Check if remote-fs.target is enabled
    if systemctl is-enabled remote-fs.target >/dev/null 2>&1; then
        echo "Automounting is already enabled."
    else
        # Enable and start remote-fs.target
        echo "Enabling and starting automounting..."
        sudo systemctl enable --now remote-fs.target
        echo "Automounting has been enabled and started."
    fi
else
    echo "Systemd is not running. Automounting cannot be configured."
fi

sudo systemctl daemon-reload

read -r -p "
Continuing..." -t 1 -n 1 -s

# Create mount points and set permissions
read -r -p "Create mount points and set permissions
" -t 2 -n 1 -s

sudo mkdir -p /mnt/Budget-Archives
sudo mkdir -p /mnt/home-profiles
sudo mkdir -p /mnt/linux-data
sudo mkdir -p /mnt/smb
sudo mkdir -p /mnt/smb-budget
sudo mkdir -p /mnt/smb-rsync
sudo mkdir -p /mnt/windows-data
sudo chmod 777 /mnt/Budget-Archives
sudo chmod 777 /mnt/home-profiles
sudo chmod 777 /mnt/linux-data
sudo chmod 777 /mnt/smb
sudo chmod 777 /mnt/smb-budget
sudo chmod 777 /mnt/smb-rsync
sudo chmod 777 /mnt/windows-data

read -r -p "
Continuing..." -t 1 -n 1 -s

# Mount the shares and start services
read -r -p "Mount the shares and start services
" -t 2 -n 1 -s && echo ""

sudo mount -a || {
    echo "Mount failed"
    sleep 3
}
sudo systemctl enable smb nmb || {
    echo "Failed to enable services"
    sleep 3
}
sudo systemctl restart smb.service nmb.service || {
    echo "Failed to restart services"
    sleep 3
}
sudo systemctl daemon-reload

read -r -p "
Continuing..." -t 1 -n 1 -s

# Test the fstab entries
read -r -p "Test the fstab entries" -t 2 -n 1 -s

sudo ls /mnt/home-profiles || {
    echo "Failed to list Linux data"
    sleep 3
}
sudo ls /mnt/linux-data || {
    echo "Failed to list Linux data"
    sleep 3
}
sudo ls /mnt/smb || {
    echo "Failed to list SMB share"
    sleep 3
}
sudo ls /mnt/windows-data || {
    echo "Failed to list Windows data"
    sleep 3
}
sudo ls /mnt/Budget-Archives || {
    echo "Failed to list Windows data"
    sleep 3
}
sudo ls /mnt/smb-budget || {
    echo "Failed to list Windows data"
    sleep 3
}
sudo ls /mnt/smb-rsync || {
    echo "Failed to list Windows data"
    sleep 3
}

read -r -p "
Continuing ..." -t 1 -n 1 -s

read -r -p "Copy WALLPAPER to user home
" -t 2 -n 1 -s

# Create the TARGET_DIR if it doesn't exist
mkdir -p "$USER_PIC"

# Copy the files from WALLPAPERS to TARGET_DIR
cp -r "$WALLPAPERS_DIR"/debian12-tolga.jpg "$USER_PIC"
chown -R $username:$username /home/$username

# Check if the copy operation was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to copy files from $WALLPAPERS_DIR to $USER_PIC."
    exit 1
fi

echo ""
echo "Wallpaper Files copied successfully!"
echo "WALLPAPERS_DIR: $WALLPAPERS_DIR"
echo "WALLPAPERTARGET_DIR: $USER_PIC"
echo ""

echo "Continuing ..."
sleep 1

read -r -p "Installing afew fonts ...
" -t 2 -n 1 -s

# Installing fonts
sudo apt install fontawesome-fonts fontawesome-fonts-web
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip
unzip FiraCode.zip -d /usr/share/fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Meslo.zip
unzip Meslo.zip -d /usr/share/fonts
wget https://github.com/tolgaerok/fonts-tolga/raw/main/WPS-FONTS.zip
unzip WPS-FONTS.zip -d /usr/share/fonts

# Reloading Font
sudo fc-cache -vf

# Removing zip Files
rm ./FiraCode.zip ./Meslo.zip ./WPS-FONTS.zip

read -r -p "
..... Complete" -t 1 -n 1 -s

echo "Done. Time to fstrim."
sudo fstrim -av

echo -e "\n\n----------------------------------------------"
echo -e "|                                            |"
echo -e "|        Setup Complete! Enjoy debian!       |"
echo -e "|       Please run RUN-AFTER-INSTALL.sh      |"
echo -e "|    to back up your APT packages and more   |"
echo -e "|                                            |"
echo -e "----------------------------------------------\n\n"

exit 0
