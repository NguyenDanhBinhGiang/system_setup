echo "This script should not be executed as-is. You should read and modify it first before execute it." && \
read -p "Are you ready to run this script? (Y/N)" confirm
if [[ "$confirm" != "Y" && "$confirm" != "y" ]];
then exit 1;
fi


# Install git
sudo apt-get update && sudo apt-get -y install git curl wget


# install docker
# Add Docker's official GPG key:
sudo apt-get -y install ca-certificates curl && \
sudo install -m 0755 -d /etc/apt/keyrings && \
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc && \
sudo chmod a+r /etc/apt/keyrings/docker.asc && \
# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu jammy stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && \
sudo apt-get update && \
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin && \
# add current user to docker group
sudo groupadd docker ;
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
git clone https://github.com/NguyenDanhBinhGiang/convenient_scripts.git ~/script
cp ~/script/docker_prune /usr/local/bin/
pip3 install thefuck
cat ~/script/.bashrc > ~/.bashrc


# install pipewire
# todo: check if this line is correct
if [[ ! $(pactl info | grep "Server Name") =~ .*PipeWire ]];
then
  # ------------------------------
  # PIPEWIRE AND EASYEFFECTS SETUP
  # ------------------------------

  # Install pipewire from repository
  add-apt-repository ppa:pipewire-debian/pipewire-upstream -y
  add-apt-repository ppa:pipewire-debian/wireplumber-upstream -y
  apt update
  apt install pipewire -y
  apt upgrade -y

  # Install wireplumber
  apt purge pipewire-media-session -y
  apt install wireplumber -y
  apt install pipewire-pulse -y
  apt purge pulseaudio -y
  apt autoremove -y

  # Mask pulseaudio
  systemctl --user --now disable pulseaudio.service pulseaudio.socket
  systemctl --user mask pulseaudio
  systemctl --user --now enable pipewire pipewire-pulse wireplumber

  # Additional packages
  apt install libldacbt-abr2 libldacbt-enc2 libspa-0.2-bluetooth pipewire-audio-client-libraries libspa-0.2-jack -y

  # ----------- You can remove this part if you don't want EasyEffects ----------

  apt install --no-install-recommends xdg-desktop-portal-gnome -y
  flatpak install app/com.github.wwmm.easyeffects/x86_64/stable -y
  flatpak permission-reset com.github.wwmm.easyeffects

  # -----------------------------------------------------------------------------
  echo "Pipewire and EasyEffects installation finished."
fi


# prompt reboot
printf "\n\n\n\n";
echo "Installation finished. Please restart your computer."
read -p "Restart now? (Y/N)" confirm;
if [[ "$confirm" != "Y" && "$confirm" != "y" ]];
then exit 1;
fi;
sudo reboot
