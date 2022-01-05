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
# Everything after choosing free or non-free (input 1 or 2 there) is automated unless something goes wrong.

blame_internet (){
  if [ $? != 0 ]; then
    echo "Something went wrong. probably internet lost"
    exit 1
  fi
}

echo "Free (1), non-free (2), or nVidia (3)?"
read $free

#Wine setup
dpkg --add-architecture i386
curl https://dl.winehq.org/wine-builds/winehq.key > winehq.key
blame_internet
apt-key add winehq.key
rm winehq.key

#Lutris key
curl https://download.opensuse.org/repositories/home:/strycore/Debian_11/Release.key | sudo apt-key add -
blame_internet

#Repo modification
if [[ "$free" = "2" ]]
then
  printf "deb http://deb.debian.org/debian testing main contrib non-free\ndeb-src http://deb.debian.org/debian testing main contrib\ndeb https://dl.winehq.org/wine-builds/debian/ bookworm main\ndeb http://download.opensuse.org/repositories/home:/strycore/Debian_11/ ./" > /etc/apt/sources.list
  apt update
  blame_internet
elif [ "$free" = "3" ]
then
  printf "deb http://deb.debian.org/debian testing main contrib non-free\ndeb-src http://deb.debian.org/debian testing main contrib\ndeb https://dl.winehq.org/wine-builds/debian/ bookworm main\ndeb http://download.opensuse.org/repositories/home:/strycore/Debian_11/ ./" > /etc/apt/sources.list
  apt update
  blame_internet
  apt install -y linux-headers-amd64
  blame_internet
  apt install -y nvidia-driver firmware-misc-nonfree nvidia-legacy-390xx-driver
  blame_internet
elif [ "$free" = "1" ]
then
  printf "deb http://deb.debian.org/debian testing main\ndeb-src http://deb.debian.org/debian testing main\ndeb https://dl.winehq.org/wine-builds/debian/ bookworm main\ndeb http://download.opensuse.org/repositories/home:/strycore/Debian_11/ ./" > /etc/apt/sources.list
  apt update
  blame_internet
  apt install -y vrms
  blame_internet
  apt purge -y $(vrms -s)
  echo "System purification has been achieved and vRMS is pacified."
fi
apt upgrade -y
blame_internet

#Bloat removal and package installing
apt autoremove -y goldendict dragonplayer juk k3b firefox-esr konqueror chromium epiphany-browser libreoffice* anthy fcitx* mozc-utils-gui apper mlterm mlterm-tiny xiterm+thai xterm ksysguard kmail kate
blame_internet
apt install -y bash-completion flatpak neofetch vlc elisa kolourpaint grub-theme-breeze breeze-gtk-theme sddm-theme-breze plymouth-theme-breeze winetricks wine-binfmt lutris plasma-discover-plugin-flatpak plasma-systemmonitor
blame_internet

#Flatpak setup
flatpak remote-add flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak remote-add flathub-beta https://flathub.org/beta-repo/flathub-beta.flatpakrepo
flatpak install -y --noninteractive org.mozilla.firefox org.onlyoffice.desktopeditors com.usebottles.bottles thunderbird flatseal
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

#Breeze everywhere
