#! /bin/bash
# Plasmian Build Script
# Made for building Plasmian using a Debian live ISO and remaster-iso.
# https://cdimage.debian.org/cdimage/unofficial/non-free/cd-including-firmware/weekly-live-builds/amd64/iso-hybrid/debian-live-testing-amd64-kde+nonfree.iso
# is the Debian ISO used to build Plasmian. The latest file is donloaded before building.
#
# Setup:
# Be in the directory with the ISO.
# sudo remaster-extract -i debian-live-testing-amd64-kde+nonfree.iso
# sudo remaster-squashfs-editor
# Select (C)hroot.
# Download the plasmian-build script in the chroot using curl and run it.
# Everything after this is automated unless something goes wrong.

blame_internet (){
  if [ $? != 0 ]; then
    echo "Something went wrong. probably internet lost"
    exit 1
}

#Wine setup
dpkg --add-architecture i386
wget -nc https://dl.winehq.org/wine-builds/winehq.key
blame_internet
apt-key add winehq.key
rm winehq.key

#Repo modification
printf "deb http://deb.debian.org/debian testing main contrib non-free\ndeb-src http://deb.debian.org/debian testing main contrib\ndeb https://dl.winehq.org/wine-builds/debian/ bookworm main" > /etc/apt/sources.list
apt update
blame_internet
apt upgrade -y
blame_internet

#Bloat removal and package installing
apt autoremove -y #TODO: fill <----------------------
apt install -y bash-completion flatpak neofetch vlc kolourpaint#TODO: fill <-------------------------------
blame_internet

#Flatpak setup
flatpak remote-add flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak remote-add flathub-beta https://flathub.org/beta-repo/flathub-beta.flatpakrepo
flatpak install -y --noninteractive org.mozilla.firefox org.onlyoffice.desktopeditors com.usebottles.bottles
blame_internet

#Install smxi
curl -L  https://github.com/smxi/smxi/archive/master.zip -o /tmp/smxi.zip
blame_internet
unzip /tmp/smxi.zip -d /usr/local/bin/

#Download plasmian-files
curl -L https://github.com/plasmian/plasmian-files/archive/refs/heads/main.zip -o /tmp/
blame_internet
unzip /tmp/master.zip -d /tmp/
#Install Firefox config
mkdir -p /etc/skel/.var/app/org.mozilla.firefox/config/fontconfig/
cp /tmp/plasmian-files/fonts.conf /etc/skel/.var/app/org.mozilla.firefox/config/fontconfig/
#Install custom app names
mkdir -p /etc/skel/.local/share/applications
#TODO: make desktop files, add to plasmian-files repo, copy them over to here <-------------------------------
#Install templates
mkdir -p /etc/skel/Templates/
cp /tmp/New* /etc/skel/Templates/
