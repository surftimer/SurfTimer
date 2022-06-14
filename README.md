# SurfTimer for CS:GO

This is an open source timer plugin made for CS:GO.

[SurfTimer Discord](https://discord.surftimer.dev)

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
* Set up A MySQL Database (MySQL 5.7, MySQL 8+, MariaDB supported)
* Add a MySQL database called surftimer to csgo/addons/sourcemod/configs/databases.cfg
* Ensure [End-Touch-Fix](https://github.com/rumourA/End-Touch-Fix) is loaded, this is required to ensure times are always accurate
* Ensure you have added all the requirements below

## Installation common errors
<details>
  <summary>[SurfTimer] Database tables could not be created! Error: Lost connection to MySQL server during query</summary>

Run the following queries on your database:

	CREATE TABLE IF NOT EXISTS `ck_announcements` (`id` int(11) NOT NULL AUTO_INCREMENT, `server` varchar(256) NOT NULL DEFAULT 'Beginner', `name` varchar(32) NOT NULL, `mapname` varchar(128) NOT NULL, `mode` int(11) NOT NULL DEFAULT '0', `time` varchar(32) NOT NULL, `group` int(12) NOT NULL DEFAULT '0', PRIMARY KEY (`id`))DEFAULT CHARSET=utf8mb4;
	CREATE TABLE IF NOT EXISTS ck_bonus (steamid VARCHAR(32), name VARCHAR(32), mapname VARCHAR(32), runtime FLOAT NOT NULL DEFAULT '-1.0', zonegroup INT(12) NOT NULL DEFAULT 1, style INT(11) NOT NULL DEFAULT 0, PRIMARY KEY(steamid, mapname, zonegroup, style)) DEFAULT CHARSET=utf8mb4;
	CREATE TABLE IF NOT EXISTS ck_checkpoints (steamid VARCHAR(32), mapname VARCHAR(32), cp1 FLOAT DEFAULT '0.0', cp2 FLOAT DEFAULT '0.0', cp3 FLOAT DEFAULT '0.0', cp4 FLOAT DEFAULT '0.0', cp5 FLOAT DEFAULT '0.0', cp6 FLOAT DEFAULT '0.0', cp7 FLOAT DEFAULT '0.0', cp8 FLOAT DEFAULT '0.0', cp9 FLOAT DEFAULT '0.0', cp10 FLOAT DEFAULT '0.0', cp11 FLOAT DEFAULT '0.0', cp12 FLOAT DEFAULT '0.0', cp13 FLOAT DEFAULT '0.0', cp14 FLOAT DEFAULT '0.0', cp15 FLOAT DEFAULT '0.0', cp16 FLOAT DEFAULT '0.0', cp17  FLOAT DEFAULT '0.0', cp18 FLOAT DEFAULT '0.0', cp19 FLOAT DEFAULT '0.0', cp20  FLOAT DEFAULT '0.0', cp21 FLOAT DEFAULT '0.0', cp22 FLOAT DEFAULT '0.0', cp23 FLOAT DEFAULT '0.0', cp24 FLOAT DEFAULT '0.0', cp25 FLOAT DEFAULT '0.0', cp26 FLOAT DEFAULT '0.0', cp27 FLOAT DEFAULT '0.0', cp28 FLOAT DEFAULT '0.0', cp29 FLOAT DEFAULT '0.0', cp30 FLOAT DEFAULT '0.0', cp31 FLOAT DEFAULT '0.0', cp32  FLOAT DEFAULT '0.0', cp33 FLOAT DEFAULT '0.0', cp34 FLOAT DEFAULT '0.0', cp35 FLOAT DEFAULT '0.0', zonegroup INT(12) NOT NULL DEFAULT 0, PRIMARY KEY(steamid, mapname, zonegroup)) DEFAULT CHARSET=utf8mb4;
	CREATE TABLE IF NOT EXISTS ck_latestrecords (steamid VARCHAR(32), name VARCHAR(32), runtime FLOAT NOT NULL DEFAULT '-1.0', map VARCHAR(32), date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY(steamid,map,date)) DEFAULT CHARSET=utf8mb4;
	CREATE TABLE IF NOT EXISTS ck_maptier (mapname VARCHAR(54) NOT NULL, tier INT(12), maxvelocity FLOAT NOT NULL DEFAULT '3500.0', announcerecord INT(11) NOT NULL DEFAULT '0', gravityfix INT(11) NOT NULL DEFAULT '1', ranked INT(11) NOT NULL DEFAULT '1', PRIMARY KEY(mapname)) DEFAULT CHARSET=utf8mb4;
	CREATE TABLE IF NOT EXISTS `ck_playeroptions2` (`steamid` varchar(32) NOT NULL DEFAULT '', `timer` int(11) NOT NULL DEFAULT '1', `hide` int(11) NOT NULL DEFAULT '0', `sounds` int(11) NOT NULL DEFAULT '1', `chat` int(11) NOT NULL DEFAULT '0', `viewmodel` int(11) NOT NULL DEFAULT '1', `autobhop` int(11) NOT NULL DEFAULT '1', `checkpoints` int(11) NOT NULL DEFAULT '1', `gradient` int(11) NOT NULL DEFAULT '3', `speedmode` int(11) NOT NULL DEFAULT '0', `centrespeed` int(11) NOT NULL DEFAULT '0', `centrehud` int(11) NOT NULL DEFAULT '1', teleside int(11) NOT NULL DEFAULT '0', `module1c` int(11) NOT NULL DEFAULT '1', `module2c` int(11) NOT NULL DEFAULT '2', `module3c` int(11) NOT NULL DEFAULT '3', `module4c` int(11) NOT NULL DEFAULT '4', `module5c` int(11) NOT NULL DEFAULT '5', `module6c` int(11) NOT NULL DEFAULT '6', `sidehud` int(11) NOT NULL DEFAULT '1', `module1s` int(11) NOT NULL DEFAULT '5', `module2s` int(11) NOT NULL DEFAULT '0', `module3s` int(11) NOT NULL DEFAULT '0', `module4s` int(11) NOT NULL DEFAULT '0', `module5s` int(11) NOT NULL DEFAULT '0', prestrafe int(11) NOT NULL DEFAULT '0', cpmessages int(11) NOT NULL DEFAULT '1', wrcpmessages int(11) NOT NULL DEFAULT '1', PRIMARY KEY (`steamid`)) DEFAULT CHARSET=utf8mb4;
	CREATE TABLE IF NOT EXISTS `ck_playerrank` (`steamid` varchar(32) NOT NULL DEFAULT '', `steamid64` varchar(64) DEFAULT NULL, `name` varchar(32) DEFAULT NULL, `country` varchar(32) DEFAULT NULL, `points` int(12) DEFAULT '0', `wrpoints` int(12) NOT NULL DEFAULT '0', `wrbpoints` int(12) NOT NULL DEFAULT '0', `wrcppoints` int(11) NOT NULL DEFAULT '0', `top10points` int(12) NOT NULL DEFAULT '0', `groupspoints` int(12) NOT NULL DEFAULT '0', `mappoints` int(11) NOT NULL DEFAULT '0', `bonuspoints` int(12) NOT NULL DEFAULT '0', `finishedmaps` int(12) DEFAULT '0', `finishedmapspro` int(12) DEFAULT '0', `finishedbonuses` int(12) NOT NULL DEFAULT '0', `finishedstages` int(12) NOT NULL DEFAULT '0', `wrs` int(12) NOT NULL DEFAULT '0', `wrbs` int(12) NOT NULL DEFAULT '0', `wrcps` int(12) NOT NULL DEFAULT '0', `top10s` int(12) NOT NULL DEFAULT '0', `groups` int(12) NOT NULL DEFAULT '0', `lastseen` int(64) DEFAULT NULL, `joined` int(64) NOT NULL, `timealive` int(64) NOT NULL DEFAULT '0', `timespec` int(64) NOT NULL DEFAULT '0', `connections` int(64) NOT NULL DEFAULT '1', `readchangelog` int(11) NOT NULL DEFAULT '0', `style` int(11) NOT NULL DEFAULT '0', PRIMARY KEY (`steamid`, `style`)) DEFAULT CHARSET=utf8mb4;
	CREATE TABLE IF NOT EXISTS ck_playertemp (steamid VARCHAR(32), mapname VARCHAR(32), cords1 FLOAT NOT NULL DEFAULT '-1.0', cords2 FLOAT NOT NULL DEFAULT '-1.0', cords3 FLOAT NOT NULL DEFAULT '-1.0', angle1 FLOAT NOT NULL DEFAULT '-1.0',angle2 FLOAT NOT NULL DEFAULT '-1.0',angle3 FLOAT NOT NULL DEFAULT '-1.0', EncTickrate INT(12) DEFAULT '-1.0', runtimeTmp FLOAT NOT NULL DEFAULT '-1.0', Stage INT, zonegroup INT NOT NULL DEFAULT 0, PRIMARY KEY(steamid,mapname)) DEFAULT CHARSET=utf8mb4;
	CREATE TABLE IF NOT EXISTS ck_playertimes (steamid VARCHAR(32), mapname VARCHAR(32), name VARCHAR(32), runtimepro FLOAT NOT NULL DEFAULT '-1.0', style INT(11) NOT NULL DEFAULT '0', PRIMARY KEY(steamid, mapname, style)) DEFAULT CHARSET=utf8mb4;
	CREATE TABLE IF NOT EXISTS ck_spawnlocations (mapname VARCHAR(54) NOT NULL, pos_x FLOAT NOT NULL, pos_y FLOAT NOT NULL, pos_z FLOAT NOT NULL, ang_x FLOAT NOT NULL, ang_y FLOAT NOT NULL, ang_z FLOAT NOT NULL,  `vel_x` float NOT NULL DEFAULT '0', `vel_y` float NOT NULL DEFAULT '0', `vel_z` float NOT NULL DEFAULT '0', zonegroup INT(12) DEFAULT 0, stage INT(12) DEFAULT 0, teleside INT(11) DEFAULT 0, PRIMARY KEY(mapname, zonegroup, stage, teleside)) DEFAULT CHARSET=utf8mb4;
	CREATE TABLE IF NOT EXISTS `ck_vipadmins` (`steamid` varchar(32) NOT NULL DEFAULT '', `title` varchar(128) DEFAULT '0', `namecolour` int(11) DEFAULT '0', `textcolour` int(11) NOT NULL DEFAULT '0', `joinmsg` varchar(255) DEFAULT 'none', `pbsound` varchar(256) NOT NULL DEFAULT 'none', `topsound` varchar(256) NOT NULL DEFAULT 'none', `wrsound` varchar(256) NOT NULL DEFAULT 'none', `inuse` int(11) DEFAULT '0', `vip` int(11) DEFAULT '0', `admin` int(11) NOT NULL DEFAULT '0', `zoner` int(11) NOT NULL DEFAULT '0', `active` int(11) NOT NULL DEFAULT '1', PRIMARY KEY (`steamid`), KEY `vip` (`steamid`,`vip`,`admin`,`zoner`)) DEFAULT CHARSET=utf8mb4;
	CREATE TABLE IF NOT EXISTS `ck_wrcps` (`steamid` varchar(32) NOT NULL DEFAULT '', `name` varchar(32) DEFAULT NULL, `mapname` varchar(32) NOT NULL DEFAULT '', `runtimepro` float NOT NULL DEFAULT '-1', `stage` int(11) NOT NULL, `style` int(11) NOT NULL DEFAULT '0', PRIMARY KEY (`steamid`,`mapname`,`stage`,`style`), KEY `stagerank` (`mapname`,`runtimepro`,`stage`,`style`)) DEFAULT CHARSET=utf8mb4;
	CREATE TABLE IF NOT EXISTS `ck_zones` (`mapname` varchar(54) NOT NULL, `zoneid` int(12) NOT NULL DEFAULT '-1', `zonetype` int(12) DEFAULT '-1', `zonetypeid` int(12) DEFAULT '-1', `pointa_x` float DEFAULT '-1', `pointa_y` float DEFAULT '-1', `pointa_z` float DEFAULT '-1', `pointb_x` float DEFAULT '-1', `pointb_y` float DEFAULT '-1', `pointb_z` float DEFAULT '-1', `vis` int(12) DEFAULT '0', `team` int(12) DEFAULT '0', `zonegroup` int(11) NOT NULL DEFAULT '0', `zonename` varchar(128) DEFAULT NULL, `hookname` varchar(128) DEFAULT 'None', `targetname` varchar(128) DEFAULT 'player', `onejumplimit` int(12) NOT NULL DEFAULT '1', `prespeed` int(64) NOT NULL DEFAULT '250.0', PRIMARY KEY (`mapname`,`zoneid`)) DEFAULT CHARSET=utf8mb4;
	CREATE TABLE IF NOT EXISTS ck_prinfo (steamid VARCHAR(32), name VARCHAR(32), mapname VARCHAR(32), runtime FLOAT NOT NULL DEFAULT '0.0', zonegroup INT(12) NOT NULL DEFAULT '0', PRtimeinzone FLOAT NOT NULL DEFAULT '0.0', PRcomplete FLOAT NOT NULL DEFAULT '0.0', PRattempts FLOAT NOT NULL DEFAULT '0.0', PRstcomplete FLOAT NOT NULL DEFAULT '0.0', PRIMARY KEY(steamid, mapname, zonegroup)) DEFAULT CHARSET=utf8mb4;

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
* [DHooks](https://github.com/peace-maker/DHooks2)
* *(recommended)* [Cleaner](https://github.com/Accelerator74/Cleaner) - Suppresses server console warnings

**SourceMod Libraries**
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