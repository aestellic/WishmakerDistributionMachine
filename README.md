# Wishmaker Distribution Machine
Web UI and automated script for [InjectJirachi](https://github.com/aestellic/InjectJirachi). Intended for usage with a Raspberry Pi running FullPageOS alongside a touch screen [such as this one](https://www.amazon.com/dp/B0B455LDKH) and a GBxCart RW or similar device.

## Usage
 - Install [FullPageOS](https://github.com/guysoft/FullPageOS) using [Raspberry Pi Imager](https://www.raspberrypi.com/software/) or similar software
 - ssh into the Pi and run the following:
```sh
git clone https://github.com/aestellic/InjectJirachi ~/
sudo git clone https://github.com/aestellic/WishmakerDistributionMachine /var/www/html/
sudo echo "http://localhost/WishmakerDistributionMachine/index.html" > /boot/firmware/fullpageos.txt
sudo echo 'export CHROMIUM_FLAGS="$CHROMIUM_FLAGS --force-renderer-accessibility --enable-remote-extensions --enable-features=OverlayScrollbar"' > /etc/chromium.d/00-rpi-vars
sudo echo "xserver-command=X -nocursor" >> /usr/share/lightdm/lightdm.conf.d/*.conf
sudo cp /var/www/html/WishmakerDistributionMachine/splash.png /boot/firmware/splash.png
sudo cp /var/www/html/WishmakerDistributionMachine/splash.png /opt/custompios/background.png
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

## Credits
 - [Cilerba](https://github.com/cilerba/), [Goppier](https://github.com/Goppier), [UndeadxReality](https://digiex.net/members/undeadxreality.54129/), [Zaksabeast](https://github.com/zaksabeast/): inspiration

 - [Cilerba](https://github.com/cilerba/): Professor Oak model poses

 - [MikuMikuKnight + New3DsSuchti](https://www.deviantart.com/mikumikuknight/art/Prof-Oak-dl-859617406): Professor Oak model from Pokemon Masters

 - [shyastreamsstuff](https://www.deviantart.com/shyastreamsstuff/art/Jigglypuff-316410418): Jigglypuff singing art

 - [@drayx7 on Discord](https://discord.com/channels/442462691542695948/442464874287726594/681746898939543556) Wishmaker generation decompilation (join the pret Discord first if the link isn't working)

 - [@Gudf on Discord](https://discord.com/channels/442462691542695948/442464874287726594/1398708582001803274) Help with properly reimplementing the LCRNG algorithm (join the pret Discord first if the link isn't working)