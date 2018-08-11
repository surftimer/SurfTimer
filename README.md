# SurfTimer v2.2 CS:GO
[Read the changes](CHANGELOG.md)

## Backstory

This is a CS:GO timer which is heavily modified from ckSurf, the original developer (Jonitaikaponi) has quit working on it, I decided to use this as an opportunity to learn SourcePawn, I didn't want to release this yet as a lot of things are hard coded and very messy, but events occurred and well, here it is.

Keep in mind this is my own version of ckSurf, a lot of things are hard coded so perhaps you should look to <a href="https://github.com/nikooo777/ckSurf">Nikos</a> or <a href="https://github.com/marcowmadeira/ckSurf">Marcos</a> fork of ckSurf instead.

## Requirements

* Sourcemod 1.8
* MySQL (SQLite may work but is not supported by me)
* DHooks (Included)

The following dependencies are required for the discord functionality, I will make these things optional in the future, sorry:
* Sourcemod-Discord (Included)
* <a href="https://forums.alliedmods.net/showthread.php?t=229556">SteamWorks</a>
* <a href="https://forums.alliedmods.net/showthread.php?t=184604">SMJansson</a>

## Installation

* Upload all the files to your csgo server directory
* Add a MySQL database called `surftimer` to `csgo/addons/sourcemod/configs/databases.cfg`
#### Upgrading
If you wish to upgrade from a different fork of cksurf you may run the upgrade sql files located in `optional/upgrading/`, this will convert your database schema to this timer, so make sure you backup first!
###### Optional
* Import the ck_zones.sql file if you want to use my pre-made zones
* Import the ck_maptier.sql file if you want to use my pre-made tiers

## Stripper
* ~I have uploaded my stripper files <a href="https://github.com/fluffyst/skillsurf-csgo">here</a>~ I have temporarily deleted this repo as I'm restarting my community, don't want the competiton to copy my server! Feel free to PM me for a download link though.

## Other Plugins
https://github.com/fluffyst/ckSurf-mapchooser

## Extra
* I've made a discord so it's easier to discuss changes/additions rather than having to use GitHub issues https://discord.gg/MmuRW4k

## Credits

* Jonitaikaponi - Original ckSurf creator
* nikooo777 - ckSurf 1.19 Fork
* <a href="http://steamcommunity.com/id/fluffystko/">fluffys</a>
* Jakeey802
* Grandpa Goose
