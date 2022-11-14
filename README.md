# SurfTimer for CS:GO

This is an open source timer plugin made for CS:GO.

[SurfTimer Discord](https://discord.surftimer.dev)

SurfTimer Test Servers:
 - North America: `connect na-test-server.surftimer.dev`
 - Europe: `connect eu-test-server.surftimer.dev:27045`

## Project Goals

Since the vast majority of CS:GO surf communties use this plugin, our main goal with the project has been to fix the major bugs/issues that exist. Since we now believe the vast majority to be fixed, we have now started looking into adding some new features! 

We encourage everyone who uses this plugin to also share their bug related fixes. If so, we can all work towards having a bug free, feature rich timer plugin.

Less bugs = better experience = more players for surf!

## Issue Rules

**We are only helping with timer related bugs, any host related issue will be closed immediately.**

**If any of the rules listed below are not followed, you must expect the issue to be closed immediately.**

- Prerequisites:
	- Ensure your timer version is up to date with the [latest release](https://github.com/surftimer/Surftimer-Official/releases/latest)
	- [SourceMod](https://www.sourcemod.net/downloads.php?branch=stable) and [Metamod](https://www.sourcemm.net/downloads.php/?branch=stable) are up to date (support only for latest stable)
	- Stock timer without any additional changes
- Follow the template
	- That means you won't delete any pre-entered questions!
- Give clear and as precise information as you can
	- If applicable include related logs / configs (posted to [pastebin](https://pastebin.com/))
- Don't edit issues
	- Always write a new comment below!

## Installation

* Download and install [Metamod 1.11](https://www.sourcemm.net/downloads.php/?branch=stable)
* Download and install [SourceMod 1.10](https://www.sourcemod.net/downloads.php?branch=stable) (latest stable) or [SourceMod 1.11](https://www.sourcemod.net/downloads.php?branch=master&all=1) (required for some recommended plugins)
* Download latest [release](https://github.com/surftimer/SurfTimer/releases/latest) and upload all the files to your csgo server directory
* Set up A MySQL Database (MySQL 5.7, MySQL 8+, MariaDB supported) and [initialise a schema for surftimer](https://github.com/surftimer/SurfTimer/blob/master/scripts/mysql-files/fresh_install.sql)
* Add a MySQL database called surftimer to csgo/addons/sourcemod/configs/databases.cfg
* Ensure [End-Touch-Fix](https://github.com/rumourA/End-Touch-Fix) is loaded, this is required to ensure times are always accurate (note: this is included in the official SurfTimer release build and loaded automatically without installing separately unless you are compiling SurfTimer yourself)
* Ensure you have added all the requirements below

## Installation common errors
<details>
  <summary>[SurfTimer] Database tables could not be created! Error: Lost connection to MySQL server during query</summary>

Run the following [queries](https://github.com/surftimer/SurfTimer/blob/master/scripts/mysql-files/fresh_install.sql) on your database

</details>

<details>
  <summary>[SurfTimer.smx] [SurfTimer] SQL Error (sql_selectMapRecordCallback): Unknown column 'cp1.velStartXY' in 'field list'
  [SurfTimer.smx] [SurfTimer] SQL Error (SQL_selectFastestBonusCallback): Unknown column 't1.velStartXY' in 'field list'</summary>

Run the following queries on your database:

	ALTER TABLE ck_bonus ADD velStartXY smallint(6) DEFAULT 0 NOT NULL;
	ALTER TABLE ck_bonus ADD velStartXYZ smallint(6) DEFAULT 0 NOT NULL;
	ALTER TABLE ck_bonus ADD velStartZ smallint(6) DEFAULT 0 NOT NULL;

	ALTER TABLE ck_playertimes ADD velStartXY smallint(6) DEFAULT 0 NOT NULL;
	ALTER TABLE ck_playertimes ADD velStartXYZ smallint(6) DEFAULT 0 NOT NULL;
	ALTER TABLE ck_playertimes ADD velStartZ smallint(6) DEFAULT 0 NOT NULL;

	ALTER TABLE ck_wrcps ADD velStartXY smallint(6) DEFAULT 0 NOT NULL;
	ALTER TABLE ck_wrcps ADD velStartXYZ smallint(6) DEFAULT 0 NOT NULL;
	ALTER TABLE ck_wrcps ADD velStartZ smallint(6) DEFAULT 0 NOT NULL;

</details>

## Requirements

**SourceMod Extensions**
* (\*) [DHooks](https://github.com/peace-maker/DHooks2)
* *(recommended)* [Cleaner](https://github.com/Accelerator74/Cleaner) - Suppresses server console warnings

(\*) *Already included with SourceMod 1.11.6820 and newer*

**SourceMod Libraries**

ℹ️ SourceMod Libraries are only required if you are compiling SurfTimer yourself

* [SMLib](https://github.com/bcserv/smlib/tree/transitional_syntax)
* [ColorLib](https://github.com/c0rp3n/colorlib-sm)
* [AutoExecConfig](https://github.com/Impact123/AutoExecConfig)

**SourceMod Plugins**
* *(recommended)* [SurfTimer Mapchooser](https://github.com/surftimer/SurfTimer-Mapchooser) - Allows clients to !nominate, !rtv etc
* *(recommended)* [Movement Unlocker](https://forums.alliedmods.net/showthread.php?t=255298) - Enables ground sliding AKA prestrafing
* *(recommended)* [MomSurfFix](https://github.com/GAMMACASE/MomSurfFix) - Fixes ramp glitches
* *(recommended)* [RNGFix](https://github.com/jason-e/rngfix) - Fixes a bunch of engine physics "bugs"
* *(recommended)* [HeadBugFix](https://github.com/GAMMACASE/HeadBugFix) - Fixes the head boundary box poping up when you start ducking
* *(recommended)* [PushFixDE](https://github.com/GAMMACASE/PushFixDE) - Fixes client prediction errors in push triggers
* *(recommended)* [crouchboostfix](https://github.com/t5mat/crouchboostfix) - Prevents crouchboosting
* *(recommended)* [Normalized-Run-Speed](https://github.com/sneak-it/Normalized-Run-Speed) - Normalizes players run speed across all weapons
* *(optional)* [Surftimer-Discord](https://github.com/Sarrus1/SurfTimer-discord) - Discord WR notifications

**Misc**
* *(recommended)* [Stripper:Source](http://www.bailopan.net/stripper/) - Allows adding/modifying/removing entities from a map before it loads (config files included)
* *(optional)* [Surftimer-Web-Stats](https://github.com/KristianP26/Surftimer-Web-Stats) - Web statistics
* *(optional)* [Surftimer-Discord-Bot](https://github.com/Sarrus1/SurfTimer-Discord-Bot) - Discord BOT
* *(optional)* [CSGO-Surf-Load-Screens](https://github.com/Sayt123/CSGO-Surf-Load-Screens) - Map loading images for surf maps

## Upgrading

### Upgrading from SurfTimer (fluffys)

*   Download the latest version from the release page [here](https://github.com/surftimer/SurfTimer/releases/latest)
*   Copy the files to your CS:GO directory <br> - an update script can be found [here](https://github.com/z4lab/z4lab-surftimer/blob/master/scripts/upgrade_scripts/upgrade-fluffy.sh)
*   Edit configs (mysql db, etc, to do)
*   Run `mysql-files/upgrade-fluffy.sql` in your surftimer db

### Upgrading from ckSurf (nikooo777)

*   Download the latest version from the release page [here](https://github.com/surftimer/SurfTimer/releases/latest)
*   Copy the files to your CS:GO directory
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

## Credits & Contributors

Extensions used in this version:
*   [DHooks](https://forums.alliedmods.net/showthread.php?t=180114) (Dr!fter)
*   [Trails Chroma](https://github.com/Nickelony/Trails-Chroma) (Nickelony)

The original plugin was known as ckSurf, developed by Jonitaikaponi. A year or so later fluffys released his updated [fork known as SurfTimer.](https://github.com/fluffyst/Surftimer) Since then, the plugin has recieved significant development from many different contributors.

*   [ckSurf Contributors](https://github.com/nikooo777/ckSurf/graphs/contributors)
*   [SurfTimer Contributors](https://github.com/surftimer/SurfTimer/graphs/contributors)
