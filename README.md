# Wishmaker Distribution Machine
![Preview of title screen](preview.png)

Web UI and automated script for [InjectJirachi](https://github.com/aestellic/InjectJirachi). Intended for usage with a Raspberry Pi running FullPageOS alongside a touch screen [such as this one](https://www.amazon.com/dp/B0B455LDKH) and a [GBxCart RW](https://www.gbxcart.com/) or similar device.

## Usage
 - Install [FullPageOS Stable](https://github.com/guysoft/FullPageOS) using [Raspberry Pi Imager](https://www.raspberrypi.com/software/) or similar software. I highly recommend setting up Wi-Fi and ssh.
 - Warning: The following step will delete ~/.temp
 - ssh into the Pi and run the following:
```sh
mkdir ~/.temp
cd ~/.temp
sudo apt-get update
sudo apt-get install -y git php-cli curl
# Install FlashGBX
wget https://github.com/JJ-Fox/FlashGBX-Linux-builds/releases/download/4.4/rpios12-flashgbx_4.4-1_all.deb
sudo apt-get install -y ./rpios12-flashgbx_4.4-1_all.deb
# Install .NET 9.0 and build InjectJirachi
curl -L https://dot.net/v1/dotnet-install.sh -o dotnet-install.sh
chmod +x ./dotnet-install.sh
./dotnet-install.sh --channel 9.0
export DOTNET_ROOT=$HOME/.dotnet
export PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools
git clone https://github.com/aestellic/InjectJirachi
cd InjectJirachi
git submodule update --init --recursive
cd InjectJirachi
dotnet build
sudo mkdir -p /home/wishmaker/InjectJirachi
sudo cp bin/Debug/net9.0/linux-arm/* /home/wishmaker/InjectJirachi -r
# Install WishmakerDistributionmachine and set it as the homepage
sudo git clone https://github.com/aestellic/WishmakerDistributionMachine /var/www/html/WishmakerDistributionMachine
sudo chmod +x /var/www/html/WishmakerDistributionMachine/injectJirachi.sh
echo "http://localhost/WishmakerDistributionMachine/index.html" | sudo tee /boot/firmware/fullpageos.txt > /dev/null
# Disable scrollbar and cursor
echo 'export CHROMIUM_FLAGS="$CHROMIUM_FLAGS --force-renderer-accessibility --enable-remote-extensions --enable-features=OverlayScrollbar"' | sudo tee /etc/chromium.d/00-rpi-vars > /dev/null
for file in /usr/share/lightdm/lightdm.conf.d/*.conf; do
  echo "xserver-command=X -nocursor" | sudo tee -a "$file" > /dev/null
done
# Set splash screen and disable startup text
sudo cp /var/www/html/WishmakerDistributionMachine/splash.png /boot/firmware/splash.png
sudo cp /var/www/html/WishmakerDistributionMachine/splash.png /opt/custompios/background.png
sudo sed -i -E '
s/(^| )console=serial0,[^ ]*//;
s/(^| )console=tty1//;
/(^| )quiet/! s/$/ quiet/
' /boot/firmware/cmdline.txt
# Setup PHP systemd service, wrapper script, and wishmaker user
sudo useradd -m -s /bin/bash wishmaker
sudo chown -R wishmaker:wishmaker /usr/lib/python3/dist-packages/FlashGBX/
sudo chown -R wishmaker:wishmaker /home/wishmaker
sudo tee /usr/local/bin/start-wishmaker.sh > /dev/null <<'EOF'
#!/bin/bash
USER=wishmaker
HOME=/home/wishmaker

# debug output
echo "Running PHP server as user: $USER, home: $HOME" >> /tmp/wishmaker.log

/usr/bin/php -S 127.0.0.1:8080 -t /var/www/html/WishmakerDistributionMachine
EOF
sudo chmod +x /usr/local/bin/start-wishmaker.sh

sudo tee /etc/systemd/system/wishmakerdistributionmachine.service > /dev/null <<EOF
[Unit]
Description=PHP Built-in Server for WishmakerDistributionMachine
After=network.target

[Service]
User=wishmaker
ExecStart=/usr/local/bin/start-wishmaker.sh
WorkingDirectory=/var/www/html/WishmakerDistributionMachine
Restart=always

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl enable wishmakerdistributionmachine.service
sudo systemctl disable x11vnc.service # Omit this line if you want VNC access
rm -rf ~/.temp
sudo reboot
```
 - Plug in a GBxCart RW, GBFlash, or Joey Jr.
 - Profit.

## Notes
 - You must have an open slot in your party; the program will exit if you do not.
 - The seed used to generate the Jirachi is randomized, so standard Wishmaker RNG manipulation will not work.
 - All randomized seeds should be legal
 - Unlimited Jirachi's can be received per save.
 - Modify `start-injection.php` to fill all open slots in the party with Jirachi's isntead of just one. Instructions to do so are in the file (`/var/www/html/WishmakerDistributionMachine/start-injection.php`).
 - You may need to modify the commands in [Usage](#usage) if you aren't using a Rasbperry Pi
 - You will have to modify the HTML if your display is not 800x480.
 - There is currently no error handling or checks in place for if you have acquired the pokedex or starter pokemon.

## Credits
 - [Cilerba](https://github.com/cilerba/), [Goppier](https://github.com/Goppier), [UndeadxReality](https://digiex.net/members/undeadxreality.54129/), [Zaksabeast](https://github.com/zaksabeast/): inspiration

 - [Cilerba](https://github.com/cilerba/): Professor Oak model poses

 - [MikuMikuKnight + New3DsSuchti](https://www.deviantart.com/mikumikuknight/art/Prof-Oak-dl-859617406): Professor Oak model from Pokemon Masters

 - [shyastreamsstuff](https://www.deviantart.com/shyastreamsstuff/art/Jigglypuff-316410418): Jigglypuff singing art

 - [@drayx7 on Discord](https://discord.com/channels/442462691542695948/442464874287726594/681746898939543556): Wishmaker generation decompilation (join the pret Discord first if the link isn't working)

 - [@Gudf on Discord](https://discord.com/channels/442462691542695948/442464874287726594/1398708582001803274): Help with properly reimplementing the LCRNG algorithm (join the pret Discord first if the link isn't working)

 - [FlashGBX](https://github.com/lesserkuma/FlashGBX): Save data backup/restore

 - [PKHeX](https://github.com/kwsch/PKHeX/): Save data manipulation