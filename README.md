# VaporOS Brewmaster

 VaporOS - a version of the Stephenson's Rocket SteamOS installer with multiple added packages.
 
# Improvements

VaporOS adds the following packages to Stephenson's rocket:

BPM
- Kodi, a media player which offers a great experience on a TV with a controller (you can add it as a library shortcut from the setting)
- RetroArch, an emulator front-end with many emulators included in it
- Controller binds for Xbox 360 controllers. There are binds for screenshots(LS+RS), recording(LB+RB+A to start/stop recording), displaying fps(LB+RB+X) and restarting Steam(LB+RB+Home)

Desktop
- VLC, a media player
- Gedit, a text editor
- File Roller, an archiving tool
- Gnome Tweak Tool, which allows you to configure the desktop in many additional ways

Command line
- Bash-completion, for making it easier to use the commandline
- Lgogdownloader, a command line tool for downloading GOG games
- Ice-steamos, a tool for adding roms to your Steam Library. Instructions on how to use this tool can be found [here](https://github.com/ProfessorKaos64/Ice#running-ice)
- Lbav, a tool for recording and converting video and audio

General Improvements
- TRIM support for SSD users
- Mouse acceleration is disabled by default

# Planned improvements

- Automatic updates for packages specific to VaporOS. Currently security updates for the additional packages will have to be installed manually from the Debian repositories!
- Adding support for more controllers to vaporos-binds-xbox360
- Making Ice-steamos easier to use
- Making building Stephenson's Rocket and VaporOS ISOs possible on more operating systems(think Arch, Fedora, etc)

# How to install?

ISO's for the latest releases are always available on http://download.vaporos.net/

Otherwise you could build it yourself.

## Installing from a DVD

Just burn the ISO to a blank DVD from your favourite tool, and boot it.

## Installing from USB (Mac)

Open a Terminal window from the Utilities section of Applications.

Type `diskutil list` to get a list of devices - one of them will be your USB stick (e.g. `/dev/disk2`). Follow the Linux instructions below, with this `/dev/rdiskX` entry instead of `/dev/sdX`

## Installing from USB (Linux)

Plug in the USB stick and run `dmesg`; look for a line similar to this:

    [377039.485179] sd 7:0:0:0: [sdc] Attached SCSI removable disk

In this case, `sdc` is the device name for the USB stick you just inserted. Now we put the installer on the stick, as root (e.g. use `sudo`) run 

    dd bs=1M if=/path/to/vaporosX.iso of=/dev/sdX 
    
sdX should be the USB stick device from the information you received from `dmesg`. Be sure to use sdX, not sdX1 or sdX2. Then boot into the stick.

## Installing from USB (Windows)

Download [Win32 Disk Imager](http://sourceforge.net/projects/win32diskimager/) and use it to copy the .iso to your USB stick (1GB minimum size).

## Once the installer is up...

Pick the "Automatic Install" option to wipe the first hard disk in your system and install SteamOS to it.

For more sophisticated booting - e.g. dual-boot or custom partition sizes - select the "Expert" option. Use of this mode is documented in the support video [here](https://www.youtube.com/watch?v=3MjkfMs-4T4).

Beyond that, just follow Valve's instructions from [their site](http://store.steampowered.com/steamos/buildyourown) - Stephenson's Rocket should behave exactly like the real SteamOS, except it works on more systems

# How to build an iso?
To build the iso you'll need to use a Debian based distribution like Ubuntu, Mint or Debian itself.

Since VaporOS is based on Stephenson's Rocket, you'll have to clone that repo before building the iso. You can do that with the following command:

    git clone --depth=1 https://github.com/steamos-community/stephensons-rocket.git

After you've done that move into the newly created repo and clone this repo like this:

    cd stephensons-rocket
    git clone --depth=1 https://github.com/sharkwouter/vaporos-brewmaster.git
    
Now you can build the iso with:

    ./gen.sh -n "VaporOS" vaporos-brewmaster
    
You will be missing some dependencies, but the script should tell you how to get them. The resulting iso will be called vaporos-brewmaster.iso.

# Known issues and workarounds

- Running in Virtualbox is not supported.

# Special Thanks

- All contributors to Stephenson's Rocket, Directhex in particular.
- [40-1]PvtBalderick, for help with ideas and testing.
- ProfessorKaos64, for help with ideas and testing.
- Dubigrasu, for help with development, testing and ideas.
- Ryochan7, for some ideas and getting controlling bindings working in SteamOS Brewmaster
- Nate Wardawg, for the name.
- Jorgën Såagrid, for allowing the continued use of the name VaporOS.
- Valve for creating SteamOS in the first place.
