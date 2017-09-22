# SurfTimer v2.00 CS:GO

## Backstory

This is a CS:GO timer which is heavily modified from ckSurf, the original developer (Jonitaikaponi) has quit working on it, I decided to use this a opportunity to learn SourcePawn, I didn't want to release this yet as a lot of things are hard coded and very messy, but events occurred and well, here it is.

Keep in mind this version of my timer is a older version and has a lot of issues, so perhaps you should look to <a href="https://github.com/nikooo777/ckSurf">Nikos</a> or <a href="https://github.com/marcowmadeira/ckSurf">Marcos</a> fork of ckSurf instead. I may look into releasing the updated version once I feel like it's ready to be released.

## Requirements

* Sourcemod 1.8
* MySQL (SQLite may work but is not supported by me)
* DHooks (Included)

## Installation

* The timer does auto-create some tables, but they will most likely have the wrong schema, use the create-tables.sql file instead.
* Upload all the files to your csgo server directory
* Add a MySQL database called `surftimer` to `csgo/addons/sourcemod/configs/databases.cfg`

## Credits

* Jonitaikaponi - Original ckSurf creator
* nikooo777 - ckSurf 1.19 Fork
* <a href="http://steamcommunity.com/id/fluffystko/">fluffys</a>
* Jakeey802
* Grandpa Goose

Checkout <a href="http://kpsurf.xyz">KP Surf</a> if you want to see the latest version in action.
