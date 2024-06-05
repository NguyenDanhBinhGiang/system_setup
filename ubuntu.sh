echo "This script should not be executed as-is. You should read and modify it first before execute it." && \
read -p "Are you ready to run this script? (Y/N)" confirm
if [[ "$confirm" != "Y" && "$confirm" != "y" ]];
then exit 1;
fi

# you should remove all snap package first. If the system is just installed, then there might not be any package to remove
# https://askubuntu.com/a/1309605
# https://discuss.getsol.us/d/9323-how-i-delete-snap-and-all-traces-of-it/3

# Use these example command to remove all snaps package (If there is any)
# sudo snap remove $(snap list | awk '!/^Name|^core/ {print $1}' | grep -v bare)
# sudo snap remove bare && \
# sudo rm -rf /var/cache/snapd/

#remove firefox snap and install it from apt
sudo add-apt-repository ppa:mozillateam/ppa && \
echo '
Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001

Package: firefox
Pin: version 1:1snap*
Pin-Priority: -1
' | sudo tee /etc/apt/preferences.d/mozilla-firefox && \

# in case snap failed to remove firefox:
# sudo systemctl stop var-snap-firefox-common-host\\x2dhunspell.mount && \
# sudo systemctl disable var-snap-firefox-common-host\\x2dhunspell.mount
sudo snap remove firefox && \
sudo apt install -y firefox && \
# To ensure that unattended upgrades do not reinstall the snap version of Firefox
# Alternatively, you can turn off unattended upgrades
echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:${distro_codename}";' | sudo tee /etc/apt/apt.conf.d/51unattended-upgrades-firefox


# Install Flatpak
sudo apt install -y flatpak && \
sudo apt install -y gnome-software-plugin-flatpak && \
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo


# Install git
sudo apt install -y git curl wget


# install docker
# Add Docker's official GPG key:
sudo apt-get update && \
sudo apt-get -y install ca-certificates curl && \
sudo install -m 0755 -d /etc/apt/keyrings && \
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc && \
sudo chmod a+r /etc/apt/keyrings/docker.asc && \
# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && \
sudo apt-get update && \
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin && \
# add current user to docker group
sudo groupadd docker ;
sudo usermod -aG docker $USER && \
newgrp docker;


# install steam
mkdir /tmp/steam;
wget "https://cdn.akamai.steamstatic.com/client/installer/steam.deb" -O /tmp/steam/steam.deb && \
if dpkg -i /tmp/steam/steam.deb
then echo "ok";
else sudo apt-get -yf install && sudo dpkg -i /tmp/steam/steam.deb
fi;


# install discord
mkdir /tmp/discord;
wget "https://discord.com/api/download?platform=linux&format=deb" -O /tmp/discord/discord.deb && \
if dpkg -i /tmp/discord/discord.deb
then echo "ok";
else sudo apt-get -yf install && sudo dpkg -i /tmp/discord/discord.deb
fi;


# install script
git clone https://github.com/NguyenDanhBinhGiang/convenient_scripts.git ~/script
cp ~/script/docker_prune /usr/local/bin/
cat ~/script/.bashrc > ~/.bashrc


# prompt reboot
printf "\n\n\n\n";
read -p "Restart now? (Y/N)" confirm;
if [[ "$confirm" != "Y" && "$confirm" != "y" ]];
then exit 1;
fi;
sudo reboot
