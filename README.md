Starbound Server Manager
========================

# Description
The Starbound Server Manager is service script for managing a starbound server.

# Setup
 - First, follow the [SteamCMD][] documentation for installing and setting up Steam on your server.
 - Run `git clone https://github.com/dotCipher/starbound-server-manager.git` in a directory of your choosing to clone this repo.
- Edit `./service-script/starbound` and change the following values:
```
STEAM_USER=YOUR_STEAM_USERNAME
STEAM_PASS=YOUR_STEAM_PASSWORD
```
- Then you will need to copy over the service script the following way:
`sudo cp ./service-script/starbound /etc/init.d/`

# Usage
- Finally you should be able to manage it as a service, for example:
`service starbound start`

[SteamCMD]: https://developer.valvesoftware.com/wiki/SteamCMD
