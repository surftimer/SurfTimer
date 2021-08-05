-- WARNING! This file will optimise your databse version 3.2.X, please always backup your database I'm not responsible if You brick it!

-- CK_PLAYEROPTIONS2

ALTER TABLE `ck_playeroptions2` CHANGE `timer` `timer` TINYINT(4) NOT NULL DEFAULT '1';
ALTER TABLE `ck_playeroptions2` CHANGE `hide` `hide` TINYINT(4) NOT NULL DEFAULT '0';
ALTER TABLE `ck_playeroptions2` CHANGE `sounds` `sounds` TINYINT(4) NOT NULL DEFAULT '1';
ALTER TABLE `ck_playeroptions2` CHANGE `chat` `chat` TINYINT(4) NOT NULL DEFAULT '0';
ALTER TABLE `ck_playeroptions2` CHANGE `viewmodel` `viewmodel` TINYINT(4) NOT NULL DEFAULT '1';
ALTER TABLE `ck_playeroptions2` CHANGE `autobhop` `autobhop` TINYINT(4) NOT NULL DEFAULT '1';
ALTER TABLE `ck_playeroptions2` CHANGE `checkpoints` `checkpoints` TINYINT(4) NOT NULL DEFAULT '1';
ALTER TABLE `ck_playeroptions2` CHANGE `gradient` `gradient` TINYINT(4) NOT NULL DEFAULT '3';
ALTER TABLE `ck_playeroptions2` CHANGE `speedmode` `speedmode` TINYINT(4) NOT NULL DEFAULT '0';
ALTER TABLE `ck_playeroptions2` CHANGE `centrespeed` `centrespeed` TINYINT(4) NOT NULL DEFAULT '0';
ALTER TABLE `ck_playeroptions2` CHANGE `centrehud` `centrehud` TINYINT(4) NOT NULL DEFAULT '1';
ALTER TABLE `ck_playeroptions2` CHANGE `teleside` `teleside` TINYINT(4) NOT NULL DEFAULT '0';
ALTER TABLE `ck_playeroptions2` CHANGE `module1c` `module1c` TINYINT(4) NOT NULL DEFAULT '1';
ALTER TABLE `ck_playeroptions2` CHANGE `module2c` `module2c` TINYINT(4) NOT NULL DEFAULT '2';
ALTER TABLE `ck_playeroptions2` CHANGE `module3c` `module3c` TINYINT(4) NOT NULL DEFAULT '3';
ALTER TABLE `ck_playeroptions2` CHANGE `module4c` `module4c` TINYINT(4) NOT NULL DEFAULT '4';
ALTER TABLE `ck_playeroptions2` CHANGE `module5c` `module5c` TINYINT(4) NOT NULL DEFAULT '5';
ALTER TABLE `ck_playeroptions2` CHANGE `module6c` `module6c` TINYINT(4) NOT NULL DEFAULT '6';
ALTER TABLE `ck_playeroptions2` CHANGE `sidehud` `sidehud` TINYINT(4) NOT NULL DEFAULT '1';
ALTER TABLE `ck_playeroptions2` CHANGE `module1s` `module1s` TINYINT(4) NOT NULL DEFAULT '5';
ALTER TABLE `ck_playeroptions2` CHANGE `module2s` `module2s` TINYINT(4) NOT NULL DEFAULT '0';
ALTER TABLE `ck_playeroptions2` CHANGE `module3s` `module3s` TINYINT(4) NOT NULL DEFAULT '0';
ALTER TABLE `ck_playeroptions2` CHANGE `module4s` `module4s` TINYINT(4) NOT NULL DEFAULT '0';
ALTER TABLE `ck_playeroptions2` CHANGE `module5s` `module5s` TINYINT(4) NOT NULL DEFAULT '0';
ALTER TABLE `ck_playeroptions2` CHANGE `prestrafe` `prestrafe` TINYINT(4) NOT NULL DEFAULT '1';
ALTER TABLE `ck_playeroptions2` CHANGE `cpmessages` `cpmessages` TINYINT(4) NOT NULL DEFAULT '1';
ALTER TABLE `ck_playeroptions2` CHANGE `wrcpmessages` `wrcpmessages` TINYINT(4) NOT NULL DEFAULT '1';

-- CK_ANNOUNCEMENTS

ALTER TABLE `ck_announcements` CHANGE `mode` `mode` SMALLINT(4) NOT NULL DEFAULT '0';
ALTER TABLE `ck_announcements` CHANGE `group` `group` TINYINT(4) NOT NULL DEFAULT '0';
ALTER TABLE `ck_announcements` CHANGE `style` `style` TINYINT(4) NOT NULL DEFAULT '0';

-- CK_BONUS

ALTER TABLE `ck_bonus` CHANGE `name` `name` VARCHAR(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '';
ALTER TABLE `ck_bonus` CHANGE `zonegroup` `zonegroup` TINYINT(4) NOT NULL DEFAULT '1';
ALTER TABLE `ck_bonus` CHANGE `style` `style` TINYINT(4) NOT NULL DEFAULT '0';

-- CK_LATESTRECORDS

ALTER TABLE `ck_latestrecords` CHANGE `name` `name` VARCHAR(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '';

-- CK_MAPTIER

ALTER TABLE `ck_maptier` CHANGE `tier` `tier` TINYINT(4) NOT NULL DEFAULT '0';
ALTER TABLE `ck_maptier` CHANGE `announcerecord` `announcerecord` TINYINT(4) NOT NULL DEFAULT '0';
ALTER TABLE `ck_maptier` CHANGE `gravityfix` `gravityfix` TINYINT(4) NOT NULL DEFAULT '1';
ALTER TABLE `ck_maptier` CHANGE `ranked` `ranked` TINYINT(4) NOT NULL DEFAULT '1';


-- CK_PLAYERRANK

ALTER TABLE `ck_playerrank` CHANGE `steamid64` `steamid64` VARCHAR(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL;
ALTER TABLE `ck_playerrank` CHANGE `name` `name` VARCHAR(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL;
ALTER TABLE `ck_playerrank` CHANGE `country` `country` VARCHAR(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'Unknown';
ALTER TABLE `ck_playerrank` CHANGE `points` `points` INT(12) NOT NULL DEFAULT '0';
ALTER TABLE `ck_playerrank` CHANGE `finishedmaps` `finishedmaps` SMALLINT(6) NOT NULL DEFAULT '0';
ALTER TABLE `ck_playerrank` CHANGE `finishedmapspro` `finishedmapspro` SMALLINT(6) NOT NULL DEFAULT '0';
ALTER TABLE `ck_playerrank` CHANGE `finishedbonuses` `finishedbonuses` SMALLINT(6) NOT NULL DEFAULT '0';
ALTER TABLE `ck_playerrank` CHANGE `finishedstages` `finishedstages` SMALLINT(6) NOT NULL DEFAULT '0';
ALTER TABLE `ck_playerrank` CHANGE `wrs` `wrs` SMALLINT(6) NOT NULL DEFAULT '0';
ALTER TABLE `ck_playerrank` CHANGE `wrbs` `wrbs` SMALLINT(6) NOT NULL DEFAULT '0';
ALTER TABLE `ck_playerrank` CHANGE `wrcps` `wrcps` SMALLINT(6) NOT NULL DEFAULT '0';
ALTER TABLE `ck_playerrank` CHANGE `top10s` `top10s` SMALLINT(6) NOT NULL DEFAULT '0';
ALTER TABLE `ck_playerrank` CHANGE `groups` `groups` SMALLINT(6) NOT NULL DEFAULT '0';
ALTER TABLE `ck_playerrank` CHANGE `lastseen` `lastseen` INT(64) NOT NULL;
ALTER TABLE `ck_playerrank` CHANGE `style` `style` TINYINT(4) NOT NULL DEFAULT '0';


-- CK_PLAYERTEMP

ALTER TABLE `ck_playertemp` CHANGE `EncTickrate` `EncTickrate` INT(12) NOT NULL DEFAULT '-1';
ALTER TABLE `ck_playertemp` CHANGE `Stage` `Stage` SMALLINT(6) NOT NULL DEFAULT '0';
ALTER TABLE `ck_playertemp` CHANGE `zonegroup` `zonegroup` TINYINT(4) NOT NULL DEFAULT '0';


-- CK_PLAYERTIMES

ALTER TABLE `ck_playertimes` CHANGE `name` `name` VARCHAR(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL;
ALTER TABLE `ck_playertimes` CHANGE `style` `style` TINYINT(4) NOT NULL DEFAULT '0';


-- CK_SPAWNLOCATIONS

ALTER TABLE `ck_spawnlocations` CHANGE `zonegroup` `zonegroup` TINYINT(4) NOT NULL DEFAULT '0';
ALTER TABLE `ck_spawnlocations` CHANGE `stage` `stage` SMALLINT(6) NOT NULL DEFAULT '0';
ALTER TABLE `ck_spawnlocations` CHANGE `teleside` `teleside` TINYINT(4) NOT NULL DEFAULT '0';


-- CK_VIPADMINS

ALTER TABLE `ck_vipadmins` CHANGE `title` `title` VARCHAR(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL;
ALTER TABLE `ck_vipadmins` CHANGE `namecolour` `namecolour` TINYINT(4) NOT NULL DEFAULT '0';
ALTER TABLE `ck_vipadmins` CHANGE `textcolour` `textcolour` TINYINT(4) NOT NULL DEFAULT '0';
ALTER TABLE `ck_vipadmins` CHANGE `joinmsg` `joinmsg` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'none';
ALTER TABLE `ck_vipadmins` CHANGE `inuse` `inuse` TINYINT(4) NOT NULL DEFAULT '0';
ALTER TABLE `ck_vipadmins` CHANGE `vip` `vip` TINYINT(4) NOT NULL DEFAULT '0';
ALTER TABLE `ck_vipadmins` CHANGE `admin` `admin` TINYINT(4) NOT NULL DEFAULT '0';
ALTER TABLE `ck_vipadmins` CHANGE `zoner` `zoner` TINYINT(4) NOT NULL DEFAULT '0';
ALTER TABLE `ck_vipadmins` CHANGE `active` `active` TINYINT(4) NOT NULL DEFAULT '1';


-- CK_WRCP

ALTER TABLE `ck_wrcps` CHANGE `name` `name` VARCHAR(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL;
ALTER TABLE `ck_wrcps` CHANGE `stage` `stage` SMALLINT(6) NOT NULL;
ALTER TABLE `ck_wrcps` CHANGE `style` `style` TINYINT(4) NOT NULL DEFAULT '0';


-- CK_ZONES

ALTER TABLE `ck_zones` CHANGE `zoneid` `zoneid` SMALLINT(6) NOT NULL DEFAULT '-1';
ALTER TABLE `ck_zones` CHANGE `zonetype` `zonetype` TINYINT(4) NOT NULL DEFAULT '-1';
ALTER TABLE `ck_zones` CHANGE `zonetypeid` `zonetypeid` SMALLINT(6) NOT NULL DEFAULT '-1';
ALTER TABLE `ck_zones` CHANGE `pointa_x` `pointa_x` FLOAT NOT NULL DEFAULT '-1';
ALTER TABLE `ck_zones` CHANGE `pointa_y` `pointa_y` FLOAT NOT NULL DEFAULT '-1';
ALTER TABLE `ck_zones` CHANGE `pointa_z` `pointa_z` FLOAT NOT NULL DEFAULT '-1';
ALTER TABLE `ck_zones` CHANGE `pointb_x` `pointb_x` FLOAT NOT NULL DEFAULT '-1';
ALTER TABLE `ck_zones` CHANGE `pointb_y` `pointb_y` FLOAT NOT NULL DEFAULT '-1';
ALTER TABLE `ck_zones` CHANGE `pointb_z` `pointb_z` FLOAT NOT NULL DEFAULT '-1';
ALTER TABLE `ck_zones` CHANGE `vis` `vis` TINYINT(4) NOT NULL DEFAULT '0';
ALTER TABLE `ck_zones` CHANGE `team` `team` TINYINT(4) NOT NULL DEFAULT '0';
ALTER TABLE `ck_zones` CHANGE `zonegroup` `zonegroup` TINYINT(4) NOT NULL DEFAULT '0';
ALTER TABLE `ck_zones` CHANGE `onejumplimit` `onejumplimit` TINYINT(4) NOT NULL DEFAULT '0';
ALTER TABLE `ck_zones` CHANGE `prespeed` `prespeed` SMALLINT(6) NOT NULL DEFAULT '350';

