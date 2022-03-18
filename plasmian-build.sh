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
curl https://dl.winehq.org/wine-builds/winehq.key > /etc/apt/trusted.gpg.d/winehq.asc
blame_internet
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

#Bloat removal and package installing
apt install -y task-kde-desktop
apt autoremove goldendict dragonplayer juk k3b firefox-esr chromium epiphany-browser libreoffice* anthy fcitx* mozc-utils-gui kasumi apper mlterm mlterm-tiny xiterm+thai xterm ksysguard kmail kate
# if that desn't work (doesn't seem very reliable?) remove packages individually...
apt upgrade -y
blame_internet
apt install -y bash-completion flatpak neofetch kcharselect kamoso vlc elisa kolourpaint command-not-found grub-theme-breeze breeze-gtk-theme sddm-theme-breeze plymouth-theme-breeze winetricks wine-binfmt lutris plasma-discover-backend-flatpak plasma-systemmonitor
blame_internet
apt-file update
blame_internet
update-command-not-found

#Flatpak setup
flatpak remote-add flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak remote-add flathub-beta https://flathub.org/beta-repo/flathub-beta.flatpakrepo
flatpak install -y --noninteractive org.mozilla.firefox org.onlyoffice.desktopeditors com.usebottles.bottles org.mozilla.Thunderbird com.github.tchx84.Flatseal io.github.prateekmedia.appimagepool
blame_internet

#Download plasmian-files
curl -L https://github.com/plasmian/plasmian-files/archive/refs/heads/main.zip -o /tmp/
blame_internet
unzip /tmp/master.zip -d /tmp/
#Install Firefox config
mkdir -p /etc/skel/.var/app/org.mozilla.firefox/config/fontconfig/
cp /tmp/plasmian-files/fonts.conf /etc/skel/.var/app/org.mozilla.firefox/config/fontconfig/
#Install custom app names
mkdir -p /etc/skel/.local/share/applications
cp /tmp/files/* /etc/skel/.local/share/applications
#Install templates
mkdir -p /etc/skel/Templates/
cp /tmp/New* /etc/skel/Templates/

#Breeze everywhere
update-alternatives sddm-debian-theme /usr/share/sddm/themes/breeze
plymouth-set-default-theme breeze
echo "GRUB_THEME=\"/usr/share/grub/themes/breeze/theme.txt\"" > /etc/default/grub
update-grub

#tweaks
kwriteconfig5 --file kdeglobals --group "KDE" --key 'SingleClick' 'false'
kwriteconfig5 --file plasma-org.kde.plasma.desktop-appletsrc --group "Containments" --group "1" --group "General" --key 'arrangement' 1
