if [ $# -gt 0 ]
then
  if [[ "$1" == "-y" ]];
  then
    ok_all=1;
  else
    ok_all=0;
  fi;
fi;

# todo: check config file existed, delete them if needed
# todo: fix /etc/apt/source.list
#  add contrib non-free and delete cd-rom
#  delete this line: deb cdrom:[Debian GNU/Linux 12.6.0 _Bookworm_ - Official amd64 DVD Binary-1 with firmware 20240629-10:19]/ bookworm contrib main non-free-firmware


echo "This script is written for Debian 12 Bookworm.
If you are using other version, check the script before run it" && \
if [[ $ok_all != 1 ]];
then
  read -p "Are you ready to run this script? (Y/N)" confirm
  if [[ "$confirm" != "Y" && "$confirm" != "y" ]];
  then exit 1;
  fi;
fi;


# Install packages
sudo apt-get update && sudo apt-get -y install \
git curl wget bash-completion \
python3-pip python3-dev python3-venv \
dconf-editor gnome-shell-extension-dash-to-panel \
gnome-shell-extension-desktop-icons-ng \
gparted grub-customizer timeshift vlc fonts-unifont


# remove unwanted gnome packages
sudo apt purge --auto-remove gnome-games
# tweak gnome
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"


# remove Firefox ESR and install new version
sudo apt purge --autoremove -y firefox* && \
sudo install -d -m 0755 /etc/apt/keyrings && \
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null && \
gpg -n -q --import --import-options import-show /etc/apt/keyrings/packages.mozilla.org.asc | awk '/pub/{getline; gsub(/^ +| +$/,""); if($0 == "35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3") print "\nThe key fingerprint matches ("$0").\n"; else print "\nVerification failed: the fingerprint ("$0") does not match the expected one.\n"}' && \
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null && \
echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/mozilla  && \
sudo apt-get update && sudo apt-get install -y firefox


# Install Flatpak
sudo apt install -y flatpak && \
sudo apt install -y gnome-software-plugin-flatpak && \
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo


# install docker
# Add Docker's official GPG key:
sudo apt-get update && \
sudo apt-get install ca-certificates curl && \
sudo install -m 0755 -d /etc/apt/keyrings && \
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc && \
sudo chmod a+r /etc/apt/keyrings/docker.asc && \
# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && \
sudo apt-get update && \
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin && \
# add current user to docker group
# sudo groupadd docker ;
sudo usermod -aG docker $USER && \
newgrp docker;


# install steam
mkdir /tmp/steam;
sudo wget "https://cdn.akamai.steamstatic.com/client/installer/steam.deb" -O /tmp/steam/steam.deb && \
if sudo dpkg -i /tmp/steam/steam.deb
then echo "ok";
else sudo apt-get -yf install && sudo dpkg -i /tmp/steam/steam.deb
fi;


# install discord
mkdir /tmp/discord;
sudo wget "https://discord.com/api/download?platform=linux&format=deb" -O /tmp/discord/discord.deb && \
if sudo dpkg -i /tmp/discord/discord.deb
then echo "ok";
else sudo apt-get -yf install && sudo dpkg -i /tmp/discord/discord.deb
fi;


# install convenient scripts
git clone https://github.com/NguyenDanhBinhGiang/convenient_scripts.git ~/script &&\
sudo cp ~/script/docker_prune /usr/local/bin/ && \
mkdir ~/.bash_completion.d && \
sudo wget "https://raw.githubusercontent.com/cykerway/complete-alias/master/complete_alias" -O ~/.bash_completion.d/complete_alias && \
git clone https://github.com/nvbn/thefuck.git /tmp/thefuck &&\
pip3 install --user /tmp/thefuck --break-system-packages && \
cat ~/script/.bashrc > ~/.bashrc


# ----------- Install EasyEffects ----------
apt install --no-install-recommends xdg-desktop-portal-gnome -y
flatpak install flathub com.github.wwmm.easyeffects
#  flatpak permission-reset com.github.wwmm.easyeffects


# install spoof-dpi
curl -fsSL https://raw.githubusercontent.com/xvzc/SpoofDPI/main/install.sh | bash -s linux-amd64 && \
echo "[Unit]
Description=Spoof DPI

[Service]
User=hiragawa
WorkingDirectory=/home/$USER/.spoofdpi/bin/
ExecStart=/home/$USER/.spoofdpi/bin/spoofdpi -port 8123

[Install]
WantedBy=multi-user.target
" | sudo tee /etc/systemd/system/spoof-dpi.service && \
sudo systemctl daemon-reload && \
sudo systemctl enable spoof-dpi.service && \
sudo systemctl start spoof-dpi.service && \
# prompt to automatically settup proxy server
printf "\n\n\n\nSpoof-DPI proxy server installed at 127.0.0.1:8123.\n
Setup your proxy server in network setting if you want to use Spoof-DPI" && \
read -p "Automatically setup proxy? Y/N" confirm && \
if [[ "$confirm" == "Y" || "$confirm" == "y" || $ok_all == 1 ]]
then echo "
http_proxy="http://127.0.0.1:8123/"
https_proxy="http://127.0.0.1:8123/"
ftp_proxy="http://127.0.0.1:8123/"
export http_proxy ftp_proxy https_proxy
" | sudo tee -a /etc/profile;
fi;


# install java
read -p "Install Java? (Y/N)" confirm;
if [[ "$confirm" == "Y" || "$confirm" == "y" || $ok_all == 1 ]]
then
  mkdir /tmp/java;
  sudo wget "https://download.oracle.com/java/17/archive/jdk-17.0.11_linux-x64_bin.deb" -O /tmp/java/jdk17.deb && \
  if sudo dpkg -i /tmp/java/jdk17.deb
  then echo "ok";
  else sudo apt-get -yf install && sudo dpkg -i /tmp/java/jdk17.deb
  fi;
fi;


# install nvidia driver
printf "\n\nMake sure you have fixed /etc/apt/source.list before this step.\n"
read -p "Ready?" confirm;
if [[ "$confirm" == "Y" || "$confirm" == "y" || $ok_all == 1 ]]
then
sudo apt install -y nvidia-driver firmware-misc-nonfree;
fi;


# Complete notify
printf "\n\nInstallation finished. Please restart your computer.\n"
# prompt for reboot
read -p "Restart now? (Y/N)" confirm;
if [[ "$confirm" != "Y" && "$confirm" != "y" || $ok_all == 1 ]];
then exit 1;
fi;
sudo reboot
