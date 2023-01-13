# ZS-GX1 Hacks
Record of attempted hacks on the ZS-GX1 IP Camera

Confirmed working on the following camera models
 * ZS-GX1
 * Snowman SRC-001
 * GUUDGO GD-SC01
 * GUUDGO GD-SC03
 * GUUDGO GD-SC11
 * Digoo DG-W01F
 * YSA CIPC-GC13H
 * KERUI CIPC-GC15HE (read-only version)


Disclaimer - I'm not a programmer, just a hobbyist that likes poking around with things like this. You use the software here at your own risk. If your camera isn't listed as supported you may break your camera. You may even break your camera if it is listed due to a variety of firmware versions available.

A few people have asked if they can donate something, you probably have much better things to spend your money on, but if you insist you can on [PayPal](http://paypal.me/antthomascouk) [![Donate](https://www.paypalobjects.com/webstatic/en_US/i/buttons/pp-acceptance-small.png)](http://paypal.me/antthomascouk)

I will look to put any donations towards getting some other cheap IP Cameras to hack and explore - suggestions welcome!

This is a cheap Pan Tilt IP Camera (supposedly 1080p) that for a time was available on Gearbest for around £12. I bought 2 in an attempt to hack them as the reason they are so cheap is due to them being locked to paid cloud services.

[SOC - GOKE - GK7102](https://www.unifore.net/company-highlights/goke-hd-ip-camera-solution-gk7101-gk7102.html)

[Sensor - SC2135 - supposedly capable of 1080p 30fps](https://www.unifore.net/product-highlights/ip-camera-smartsens-cmos-image-sensors.html)


### Instructions
There's a few different varieties of firmware across various brands of cameras which means it is impossible to know which version of the hack is the best for your camera. Older firmware are more hackable because the root filesystem is mounted read/write, new firmwares need the hack applying differently because the root filesystem is mounted read-only but the ```/home``` directory is writeable.

For example  
Version 3.1.1.0908 is read-write and can use [zsgx1hacks-v0.4.zip](https://github.com/ant-thomas/zsgx1hacks/raw/master/zsgx1hacks-v0.4.zip)  
Version 3.2.8.0121 is read-only and can only use [readonlyhack-v0.1.zip](https://github.com/ant-thomas/zsgx1hacks/raw/master/readonlyhack-v0.1.zip)  
If in doubt use the read-only hack as that is more likely to work across more cameras.

#### How to check version
If you have already configured the camera with the cloud app there should be some info within the app showing firmware version.  
Using an onvif tool/app like Onvifer (Android) should give firmware version.  
You should also be able to find the firmware version by logging in via telnet and excuting the command  
```ls /tmp | grep -F 3.``` or ```ls /tmp | head -1```

#### Steps
* Create network connection
  * WiFi - setup camera via app
  * Ethernet - plug in to network (doesn't need app setup)
* Download hack for your camera

#### Older firmware - read/write
* Download zip file - [zsgx1hacks-v0.4.zip](https://github.com/ant-thomas/zsgx1hacks/raw/master/zsgx1hacks-v0.4.zip) 
* Extract the contents of the zip file to a vfat/fat32 formatted microSD card
* Change options in `config.txt`
  * Option for persistent hack without SD card
    * Default - run off SD Card
    * If in doubt, run it off the SD Card
  * Option to restore original state of camera without hack
  * Option to silence the voices
    * This may be causing issues on some cameras so use at your own risk

#### Newer firmware - read-only
* Download zip file - [readonlyhack-v0.1.zip](https://github.com/ant-thomas/zsgx1hacks/raw/master/readonlyhack-v0.1.zip)
* Extract the contents of the zip file to a vfat/fat32 formatted microSD card

#### All
* Insert microSD card into camera and boot
* Result should be
  * No communication to cloud services
  * RTSP/onvif server on the IP address of the camera
  * SSH server
    * R/W version - user/pass ```root/cxlinux```
    * R-O version - user ```root``` no password
  * Telnet server - user/pass ```root/cxlinux```
  * Updated busybox
  * Annoying whining noise reduced (RW version only currently)
  * WebUI accessible - http://IPAddress:8080/cgi-bin/webui
  * FTP Server pointing to the root file system - no username or password

### Achieved so far
* ```debug_cmd.sh``` on an SD card enables commands to be run
* Change root password to enable telnet login
* Telnet/root password found ```cxlinux``` (thanks 1sttommy2guns)
* Upgrade busybox
* Add dropbear SSH server
* RTSP server accessible - rtsp://IPADDRESS/ 
  * user/pass admin/admin
  * user/pass on a non-setup camera is sometimes admin with no password
  * Different camera models may have different RTSP credentials eg ```dg20160404``` or ```12345```
* Block cloud services via hosts file
* Some GPIO functions found (IR LEDs and IR Cut)
* WebUI - http://IPAddress:8080/cgi-bin/webui
* PTZ control via command line or WebUI
* FTP server - no username or password
* WiFi Connection without inital setup with app in cls.conf


### ToDo
* Figure out GPIO control for Light sensor
* Change bitrate of RTSP stream
* Get rid of ```p2pcam``` and use an alternative RTSP server

#### 2019-22-05 - Update 18 (susw12)
* Adds the ability to have camera connect to WiFi without needing to setup the camera using the app/software.

#### 2018-08-05 - Update 17 (ant-thomas)
* Read-only hack created to enable cameras with a newer firmware to have extra features and turn off cloud connections.
* SSH server has no password. It wasn't working with a password so I enabled no password logins. Hopefully be able to get that fixed.

#### 2018-03-30 - Update 16 (ant-thomas)
* Updated sdcard zip - [zsgx1hacks-v0.4.zip](https://github.com/ant-thomas/zsgx1hacks/raw/master/zsgx1hacks-v0.4.zip)
* `config.txt` file to change some options
* Option for persistent or SD card install - default is SD card
* Option to remove hack and restore camera to before hack

#### 2018-03-24 - Update 15 (ant-thomas)
* Updated sdcard zip - [zsgx1hacks-v0.3.zip](https://github.com/ant-thomas/zsgx1hacks/raw/master/zsgx1hacks-v0.3.zip)
* Hack no longer requires micro SD card to be present. Once installed the micro SD card can be removed.
  * If anyone wants a version that doesn't make any permanent changes to the camera let me know.
* Very simple WebUI created - to be improved - using busybox httpd.
* WebUI has PTZ controls - massive thanks to phaeilo.
* New VOICE.tgz file with empty audio files to silence the voices on boot.
* FTP Server added.

#### 2018-03-16 - Update 14 (phaeilo)
* Documented PTZ driver interface
* Added additional pictures of hardware
* Requesting excessively long URLs on port 80 will cause `p2pcam` to segfault...

#### 2018-02-13 - Update 13 (ant-thomas)
* RTSP streams with sound ```rtsp://ipaddress/0/av0```
* ```av0``` - high res stream with sound
* ```av1``` - low res stream with sound

#### 2017-12-03 - Update 12 (ant-thomas)
* Script updates time
* Removed password update sections - use ```cxlinux``` as password
* Updated hosts file with more addresses to block

#### 2017-11-26 - Update 11 (ant-thomas)
* Telnet/root password found by 1sttommy2guns - ```cxlinux```

#### 2017-11-17 - Update 10 (ant-thomas)
* Pan/Tilt works via onvif - tested on TinyCam Free on Android. Hopefully this can be exploited otherwise using a webUI or other means if it sticks to the onvif api.

#### 2017-11-17 - Update 9
* ~~~Add method to use WiFi without first setting up camera via App using ```goke_p2pcam_param``` as follows (change accordingly):~~~ This currently only updates a camera already setup via the app.

```
./goke_p2pcam_param --wifissid=mywifiap --wifipass=8chrpass
```

* Also see the other options for ```goke_p2pcam_param``` by executing the following command: ```goke_p2pcam_param -h```
* ```goke_volume``` allows you to make the camera much quieter.
```
./goke_volume -s 0
```

#### 2017-11-04 - Update 8

* Observations compared to the Xiaofang camera
  * Image quality is generally better than the Xiaofang camera, much sharper at distance
  * FOV is not as wide as the Xiaofang camera
  * An increase in bitrate would produce a decent quality stream

#### 2017-10-22 - Update 7 - (DJWillis)

* I am not saying the closed source p2pcam blob looks dodgy or anything but this did make me smile (from ```/home/factory_tool.sh```)

``` 
   #avoid p2pcam auto format tf card!!!
   rm -f /bin/mkdosfs
   rm -f /sbin/mkdosfs
```
That feels like the right way to work around some awesome design considerations :).

#### 2017-10-22 - Update 6 - (DJWillis) 

* Firmware can be updated from a ```firmware.bin``` file on the root of the SD card (formatted vfat). 
   This is a JFFS2 image structured much like other generic cameras based on the GOKE SoC's and a good few better know brands.
  * Suspect this will be distrbuted as one section per partition. With the kernel and uboot not normally being flashed.
  * The tool used to flash the images is ```sdc_tool```.
  * https://github.com/zzerrg/gmfwtools should be usable with the right key and board ident (1003) to unpack and repack the userspace firmware into something we can flash. It may also make cross flashing userspaces possible. Right now however you may well end up with a bricked camera or at least needing serial so try at your own risk.

#### 2017-10-22 - Update 5
* IR Cut and IR LED GPIOs found and controllable
  * ```gio -s 40 1``` IR Cut - night
  * ```gio -s 40 0``` IR Cut - day
  * ```gio -s 46 1``` IR LEDs - on
  * ```gio -s 46 0``` IR LEDs - off

#### 2017-10-22 - Update 4
* SD card contents moved to SD card folder
* Updated hosts file included which looks like it prevents the camera from contacting the cloud services. The app shows the camera as disconnected and I'm seeing no activity on my router. RTSP server remains active.

#### 2017-10-22 - Update 3
* RTSP server user/pass - admin/admin - Presents a 1920x1080 12fps stream on rtsp://IPADDRESS/ (no audio)
* Attempted to not run ```p2pcam``` by editing out specific parts of ```start.sh```, this resulting in the WiFi connection not being created. Maybe running ```wpa_supplicant``` via ```debug_cmd.sh``` may fix that.
* As the RTSP server seems to be created by ```p2pcam``` it might be possible to prevent the cloud software communicating outwards by using various hosts file listings.

#### 2017-10-21 - Update 2
* home folder uploaded
* p2pcam.tar.gz is the interesting file - this gets extracted on boot and p2pcam is the camera software.

#### 2017-10-21 - Update 1
* Photos of box and dismantled camera in the photo folder
* Initial process was to download the app via the QR code in the instructions, this gave it WIFI details to logon to, possibly this could be prevented using ethernet. 
  * Update: The need for the app can be bypassed completely by plugging directly into an ethernet connection and not setting up wifi initially as the camera will bring up eth0 via DHCP - Ignore the spoken messages about WiFi.
* Camera dismantled and serial pins found
* Boot output from serial dumped (uploaded)
* The serial interface auto-logs in as root - very useful, but I've been unable to find the root password
* Via serial interface you can add a new user - meaning you can then login via telnet with new user, or change the root password
```
passwd root
```
* /home/start.sh looks for /mnt/debug_cmd.sh which would be placed on a micro SD card - this should be the way to hack the camera.
* Due to the earlier "adduser" or "passwd root" not being persistent through reboots I added the following to debug_cmd.sh
```
(sleep 20 && echo "root:o.eyOMtPAPfbg:0:0:root:/root/:/bin/sh" > /etc/passwd )&
```
* The long sleep is required because the command has to be run after busybox has started - this updates the root password to "root"
* I made a quick attempt to upgrade busybox with a prebuilt binary but the autologin fails on serial - used debug_cmd.sh to copy new version over existing located at /bin/busybox - but having already updated the root password you can login over telnet
* nmap shows the following open ports
```
Starting Nmap 7.40 ( https://nmap.org ) at 2017-10-21 15:55 BST
Nmap scan report for ipc (192.168.1.147)
Host is up (0.035s latency).
Not shown: 65525 closed ports
PORT     STATE SERVICE
23/tcp   open  telnet
80/tcp   open  http
554/tcp  open  rtsp
843/tcp  open  unknown
3201/tcp open  unknown
5050/tcp open  mmcc
6670/tcp open  irc
7101/tcp open  elcn
7103/tcp open  unknown
8001/tcp open  vcom-tunnel
```
* There is an RTSP server running, but it is password protected
