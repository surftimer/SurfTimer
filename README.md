# Surftimer-olokos for CS:GO

_I have renamed the repository to Surftimer-olokos just to make it obvious, that we're entering a new chapter in CS:GO surf community, a milestone._

## Project Goals

As you probably all know there are quite some bugs in all open-source versions of cksurf or surftimer.
Our main goal with this project to have a bug-free, properly optimized surf timer that would work as we all expect it to, across all configurations.
Because of this, we will be putting new features and additions on the side, as they can potentially introduce new, unknown issues and there's plenty of those already.

**Does it mean this version is buggy?**

Yes, but not any more than other projects currently and for past years.

**Pull requests and any contributions are welcome and encouraged!**

## Installation and Requirements
* [SourceMod 1.10](https://www.sourcemod.net/downloads.php?branch=stable)
* [Metamod 1.10](https://www.sourcemm.net/downloads.php/?branch=stable)
* [SourceMod-Discord API](https://github.com/Deathknife/sourcemod-discord)
* A MySQL Database (MySQL 5.7, MySQL 8+, MariaDB supported)

<sup>(We only support the latest stable version of Sourcemod.)</sup>

**Extensions:**
* [DHooks](https://forums.alliedmods.net/showthread.php?t=180114) - **Recommended:** [Detours Build](https://forums.alliedmods.net/showpost.php?p=2588686&postcount=589) for SourceMod 1.10 Stable
* [SMJansson](https://forums.alliedmods.net/showthread.php?t=184604)
* [SteamWorks](https://forums.alliedmods.net/showthread.php?t=229556)

**Compilation Requirements (Includes):**
* [SMJansson](https://github.com/JoinedSenses/SourceMod-IncludeLibrary/blob/master/include/smjansson.inc)
* [SMLib (Transitional Syntax Branch)](https://github.com/bcserv/smlib/tree/transitional_syntax)
* [SourceMod Includes](https://www.sourcemod.net/downloads.php?branch=stable)
* [Sourcemod-Discord API](https://github.com/Deathknife/sourcemod-discord)
* [SteamWorks](https://forums.alliedmods.net/showthread.php?t=229556)
* [colorvariables](https://github.com/olokos/Chat-Processor/blob/master/scripting/include/colorvariables.inc)

**Recommended:**
* [Cleaner Extension](https://github.com/Accelerator74/Cleaner) (Suppresses console warnings)
* [Stripper:Source](https://forums.alliedmods.net/showthread.php?t=39439) (Allows you to add/modify/removes entities from maps, recommended filter file included)

## Issue Rules

**If any of the rules listed below are not followed, you must expect the issue to be closed immediately.**

- Requirements:
	- Ensure your timer version is up to date with the latest release
	- SourceMod and Metamod are up to date (support will only be given for latest stable versions)
	- Ensure includes for compilation are up to date
	- Using the stock timer without any additional changes
- You're following the template
	- That means you won't delete any pre-entered questions!
- You're giving clear information
- You won't edit issues - you always write a new comment below!
- **Any community/server specific bug/suggestion will be ignored/closed!**

## Fresh Install

*   Clone or download the repository ([Link](https://github.com/olokos/Surftimer-olokos-public/archive/master.zip))
*   Obtain all of the [compilation requirements](https://github.com/olokos/Surftimer-olokos#installation-and-requirements)
*   Download latest stable SourceMod version (1.10+) for your OS ([Link](https://www.sourcemod.net/downloads.php?branch=stable))
*   Windows: Put spcomp.exe and compile.exe in scripting folder and double click compile.exe
*   If there are no errors, (warnings are fine, for now) move .smx files from compiled to /plugins
*   Copy the rest of the files from this repository to your csgo directory
*   Edit configs (databases.cfg, admins, etc.)

## Upgrading

### Upgrading from SurfTimer (fluffys)

*   Download the latest version from the release page [here](https://github.com/z4lab/z4lab-surftimer/releases/latest)
*   Copy the files to your csgo directory <br> - an update script can be found [here](https://github.com/z4lab/z4lab-surftimer/blob/master/scripts/upgrade_scripts/upgrade-fluffy.sh)
*   Edit configs (mysql db, etc, to do)
*   Run `mysql-files/upgrade-fluffy.sql` in your surftimer db

### Upgrading from ckSurf (nikooo777)

*   Download the latest version from the release page [here](https://github.com/z4lab/z4lab-surftimer/releases/latest)
*   Copy the files to your csgo directory
*   Remove all old ckSurf data you don't want anymore
*   Run `mysql-files/upgrade-niko.sql` in your ckSurf db
*   Edit configs (mysql db, etc, to do)


## Point System
<details>
  <summary>Explanation</summary> 
  
The points system has seen a massive overhaul from the original ckSurf; it is now a percentile tiered system. Points are now distributed in two ways: (1) map completion, and (2) map ranking. Map completion points will be given to all players who complete a specific and are dependent on the tier.
* Tier 1: 25
* Tier 2: 50
* Tier 3: 100
* Tier 4: 200
* Tier 5: 400
* Tier 6: 600
* Tier 7: 800
* Tier 8: 1000

Map ranking points are dependent upon the individuals ranking on the map. This is done firstly by calculation of the WR points for the map. WR points per tier are calculated as follows:
* Tier 1: WR = MAX(250, (58.5 + (1.75 * Number of Completes) / 6))
* Tier 2: WR = MAX(500, (82.15 + (2.8 * Number of Completes) / 5))
* Tier 3: WR = MAX(750, (117 + (3.5 * Number of Completes) / 4))
* Tier 4: WR = MAX(1000, (164.25 + (5.74 * Number of Completes) / 4))
* Tier 5: WR = MAX(1250, (234 + (7 * Number of Completes) / 4))
* Tier 6: WR = MAX(1500, (328 + (14 * Number of Completes) / 4))
* Tier 7: WR = MAX(1750, (420 + (21 * Number of Completes) / 4))
* Tier 8: WR = MAX(2000, (560 + (30 * Number of Completes) / 4))

Once the WR points are calculated the top 10 are points are calculated by multiplying the WR points by a factor. These factors are:
* Rank 2 = WR * 0.8
* Rank 3 = WR * 0.75
* Rank 4 = WR * 0.7
* Rank 5 = WR * 0.65
* Rank 6 = WR * 0.6
* Rank 7 = WR * 0.55
* Rank 8 = WR * 0.5
* Rank 9 = WR * 0.45
* Rank 10 = WR * 0.4

Players who are not in the top 10 but are above the 50th percentile in map ranking will be sorted into 5 groups – with each higher group giving proportionally more points. These groups and their point distribution are as follows:
* Group 1 (top 3.125%) = WR * 0.25
* Group 2 (top 6.25%) = (Group 1) / 1.5
* Group 3 (top 12.5%) = (Group 2) / 1.5
* Group 4 (top 25%) = (Group 3) / 1.5
* Group 5 (top 50%) = (Group 4) / 1.5

Take surf_aircontrol_nbv for example: (You can use sm_mi to see this menu)
<img src="http://puu.sh/ykaR8/7520a6b0d6.jpg" width="372" height="469" />

###### Credit to NDiamond for theory crafting this point system, I just implemented his idea
  
</details>

## Credits

Extensions used in this version:
*   [SteamWorks](https://forums.alliedmods.net/showthread.php?t=229556) (KyleS)
*   [SMJansson](https://forums.alliedmods.net/showthread.php?t=184604) (Thrawn2)
*   [DHooks](https://forums.alliedmods.net/showthread.php?t=180114) (Dr!fter)
*   [Discord API](https://github.com/Deathknife/sourcemod-discord) (Deathknife)
*   [Trails Chroma](https://github.com/Nickelony/Trails-Chroma) (Nickelony)
<details>
  <summary>forked from fluffys - contributors</summary> 
  
*   Jonitaikaponi - Original ckSurf creator
*   sneaK
*   nikooo777 - ckSurf 1.19 Fork
*   fluffys
*   Jakeey802
*   Grandpa Goose
  
</details>

*	[Ace](https://github.com/13ace37) [xace.ch](https://xace.ch)
*	[olokos](https://github.com/olokos) [Steam](https://steamcommunity.com/id/olokos/) [My server](https://kiepownica.pl/)
*	and many, many more people who contributed to the project!

