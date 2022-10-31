CREATE DATABASE IF NOT EXISTS surftimer;
USE surftimer;

CREATE TABLE IF NOT EXISTS ck_announcements (
    `id` int(11) NOT NULL AUTO_INCREMENT, 
    `server` varchar(256) NOT NULL DEFAULT 'Beginner', 
    `name` varchar(64) NOT NULL, 
    `mapname` varchar(128) NOT NULL, 
    `mode` int(11) NOT NULL DEFAULT '0', 
    `time` varchar(32) NOT NULL, 
    `group` int(12) NOT NULL DEFAULT '0',
    `style` tinyint NOT NULL DEFAULT '0', 
    PRIMARY KEY (`id`))
    DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ck_bonus (
    `steamid` VARCHAR(32), 
    `name` VARCHAR(64), 
    `mapname` VARCHAR(32), 
    `runtime` decimal(12,6) NOT NULL DEFAULT '-1.000000', 
    `velStartXY` SMALLINT(6) NOT NULL DEFAULT 0, 
    `velStartXYZ` SMALLINT(6) NOT NULL DEFAULT 0, 
    `velStartZ` SMALLINT(6) NOT NULL DEFAULT 0,
    `velEndXY` SMALLINT(6) NOT NULL DEFAULT 0, 
    `velEndXYZ` SMALLINT(6) NOT NULL DEFAULT 0, 
    `velEndZ` SMALLINT(6) NOT NULL DEFAULT 0, 
    `zonegroup` INT(12) NOT NULL DEFAULT 1, 
    `style` INT(11) NOT NULL DEFAULT 0,
    `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY(`steamid`, `mapname`, `zonegroup`, `style`)) 
    DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ck_checkpoints (
    `steamid` VARCHAR(32), 
    `mapname` VARCHAR(32), 
    `cp` int NOT NULL DEFAULT '0',
    `time` decimal(12,6) NOT NULL DEFAULT '0.000000',
    `stage_time` decimal(12,6) NOT NULL DEFAULT '-1.000000',
    `stage_attempts` int NOT NULL DEFAULT '0',
    `zonegroup` INT(12) NOT NULL DEFAULT 0, 
    PRIMARY KEY(`steamid`, `mapname`, `cp`, `zonegroup`))
    DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ck_latestrecords (
    `steamid` VARCHAR(32), 
    `name` VARCHAR(64), 
    `runtime` decimal(12,6) NOT NULL DEFAULT '-1.000000', 
    `map` VARCHAR(32), 
    `date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, 
    PRIMARY KEY(`steamid`, `map`, `date`))
    DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ck_maptier (
    `mapname` VARCHAR(54) NOT NULL, 
    `tier` INT(12), 
    `maxvelocity` FLOAT NOT NULL DEFAULT '3500.0', 
    `announcerecord` INT(11) NOT NULL DEFAULT '0', 
    `gravityfix` INT(11) NOT NULL DEFAULT '1', 
    `ranked` INT(11) NOT NULL DEFAULT '1', 
    PRIMARY KEY(`mapname`)) 
    DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ck_playeroptions2 (
    `steamid` varchar(32) NOT NULL DEFAULT '', 
    `timer` int(11) NOT NULL DEFAULT '1', 
    `hide` int(11) NOT NULL DEFAULT '0', 
    `sounds` int(11) NOT NULL DEFAULT '1', 
    `chat` int(11) NOT NULL DEFAULT '0', 
    `viewmodel` int(11) NOT NULL DEFAULT '1', 
    `autobhop` int(11) NOT NULL DEFAULT '1', 
    `checkpoints` int(11) NOT NULL DEFAULT '1', 
    `gradient` int(11) NOT NULL DEFAULT '3', 
    `speedmode` int(11) NOT NULL DEFAULT '0', 
    `centrespeed` int(11) NOT NULL DEFAULT '0', 
    `centrehud` int(11) NOT NULL DEFAULT '1', 
    `teleside` int(11) NOT NULL DEFAULT '0', 
    `module1c` int(11) NOT NULL DEFAULT '1', 
    `module2c` int(11) NOT NULL DEFAULT '2', 
    `module3c` int(11) NOT NULL DEFAULT '3', 
    `module4c` int(11) NOT NULL DEFAULT '4', 
    `module5c` int(11) NOT NULL DEFAULT '5', 
    `module6c` int(11) NOT NULL DEFAULT '6', 
    `sidehud` int(11) NOT NULL DEFAULT '1', 
    `module1s` int(11) NOT NULL DEFAULT '5', 
    `module2s` int(11) NOT NULL DEFAULT '0', 
    `module3s` int(11) NOT NULL DEFAULT '0', 
    `module4s` int(11) NOT NULL DEFAULT '0', 
    `module5s` int(11) NOT NULL DEFAULT '0', 
    `prestrafe` int(11) NOT NULL DEFAULT '0', 
    `cpmessages` int(11) NOT NULL DEFAULT '1', 
    `wrcpmessages` int(11) NOT NULL DEFAULT '1', 
    `hints` int(11) NOT NULL DEFAULT '1', 
    `csd_update_rate` int(11) NOT NULL DEFAULT '1', 
    `csd_pos_x` float(11) NOT NULL DEFAULT '0.5', 
    `csd_pos_y` float(11) NOT NULL DEFAULT '0.3', 
    `csd_r` int(11) NOT NULL DEFAULT '255', 
    `csd_g` int(11) NOT NULL DEFAULT '255', 
    `csd_b` int(11) NOT NULL DEFAULT '255',
    `prespeedmode` int NOT NULL DEFAULT '1', 
    PRIMARY KEY (`steamid`)) 
    DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ck_playerrank (
    `steamid` varchar(32) NOT NULL DEFAULT '', 
    `steamid64` varchar(64) DEFAULT NULL, 
    `name` varchar(64) DEFAULT NULL, 
    `country` varchar(32) DEFAULT NULL, 
    `countryCode` varchar(3) DEFAULT NULL, 
    `continentCode` varchar(3) DEFAULT NULL, 
    `points` int(12) DEFAULT '0', 
    `wrpoints` int(12) NOT NULL DEFAULT '0', 
    `wrbpoints` int(12) NOT NULL DEFAULT '0', 
    `wrcppoints` int(11) NOT NULL DEFAULT '0', 
    `top10points` int(12) NOT NULL DEFAULT '0', 
    `groupspoints` int(12) NOT NULL DEFAULT '0', 
    `mappoints` int(11) NOT NULL DEFAULT '0', 
    `bonuspoints` int(12) NOT NULL DEFAULT '0', 
    `finishedmaps` int(12) DEFAULT '0', 
    `finishedmapspro` int(12) DEFAULT '0', 
    `finishedbonuses` int(12) NOT NULL DEFAULT '0', 
    `finishedstages` int(12) NOT NULL DEFAULT '0', 
    `wrs` int(12) NOT NULL DEFAULT '0', 
    `wrbs` int(12) NOT NULL DEFAULT '0', 
    `wrcps` int(12) NOT NULL DEFAULT '0', 
    `top10s` int(12) NOT NULL DEFAULT '0', 
    `groups` int(12) NOT NULL DEFAULT '0', 
    `lastseen` int(64) DEFAULT NULL, 
    `joined` int(64) NOT NULL, 
    `timealive` int(64) NOT NULL DEFAULT '0', 
    `timespec` int(64) NOT NULL DEFAULT '0', 
    `connections` int(64) NOT NULL DEFAULT '1', 
    `readchangelog` int(11) NOT NULL DEFAULT '0', 
    `style` int(11) NOT NULL DEFAULT '0', 
    PRIMARY KEY (`steamid`, `style`)) 
    DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ck_playertemp (
    `steamid` VARCHAR(32), 
    `mapname` VARCHAR(32), 
    `cords1` FLOAT NOT NULL DEFAULT '-1.0', 
    `cords2` FLOAT NOT NULL DEFAULT '-1.0', 
    `cords3` FLOAT NOT NULL DEFAULT '-1.0', 
    `angle1` FLOAT NOT NULL DEFAULT '-1.0',
    `angle2` FLOAT NOT NULL DEFAULT '-1.0',
    `angle3` FLOAT NOT NULL DEFAULT '-1.0', 
    `EncTickrate` INT(12) DEFAULT '-1.0', 
    `runtimeTmp` decimal(12,6) NOT NULL DEFAULT '-1.000000', 
    `Stage` INT, 
    `zonegroup` INT NOT NULL DEFAULT 0, 
    PRIMARY KEY(`steamid`,`mapname`)) 
    DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ck_playertimes (
    `steamid` VARCHAR(32), 
    `mapname` VARCHAR(32), 
    `name` VARCHAR(64), 
    `runtimepro` decimal(12,6) NOT NULL DEFAULT '-1.000000', 
    `velStartXY` SMALLINT(6) NOT NULL DEFAULT 0, 
    `velStartXYZ` SMALLINT(6) NOT NULL DEFAULT 0, 
    `velStartZ` SMALLINT(6) NOT NULL DEFAULT 0, 
    `style` INT(11) NOT NULL DEFAULT '0',
    `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
    PRIMARY KEY(`steamid`, `mapname`, `style`)) 
    DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ck_spawnlocations (
    `mapname` VARCHAR(54) NOT NULL, 
    `pos_x` FLOAT NOT NULL, 
    `pos_y` FLOAT NOT NULL, 
    `pos_z` FLOAT NOT NULL, 
    `ang_x` FLOAT NOT NULL, 
    `ang_y` FLOAT NOT NULL, 
    `ang_z` FLOAT NOT NULL,  
    `vel_x` float NOT NULL DEFAULT '0', 
    `vel_y` float NOT NULL DEFAULT '0', 
    `vel_z` float NOT NULL DEFAULT '0', 
    `zonegroup` INT(12) DEFAULT 0, 
    `stage` INT(12) DEFAULT 0, 
    `teleside` INT(11) DEFAULT 0, 
    PRIMARY KEY(`mapname`, `zonegroup`, `stage`, `teleside`)) 
    DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ck_vipadmins (
    `steamid` varchar(32) NOT NULL DEFAULT '', 
    `title` varchar(128) DEFAULT '0', 
    `namecolour` int(11) DEFAULT '0', 
    `textcolour` int(11) NOT NULL DEFAULT '0', 
    `joinmsg` varchar(255) DEFAULT 'none', 
    `pbsound` varchar(256) NOT NULL DEFAULT 'none', 
    `topsound` varchar(256) NOT NULL DEFAULT 'none', 
    `wrsound` varchar(256) NOT NULL DEFAULT 'none', 
    `inuse` int(11) DEFAULT '0', 
    `vip` int(11) DEFAULT '0', 
    `admin` int(11) NOT NULL DEFAULT '0', 
    `zoner` int(11) NOT NULL DEFAULT '0', 
    `active` int(11) NOT NULL DEFAULT '1', 
    PRIMARY KEY (`steamid`), 
    KEY `vip` (`steamid`,`vip`,`admin`,`zoner`)) 
    DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ck_wrcps (
    `steamid` varchar(32) NOT NULL DEFAULT '', 
    `name` varchar(64) DEFAULT NULL, 
    `mapname` varchar(32) NOT NULL DEFAULT '', 
    `runtimepro` decimal(12,6) NOT NULL DEFAULT '-1.000000', 
    `velStartXY` smallint(6) NOT NULL DEFAULT 0, 
    `velStartXYZ` smallint(6) NOT NULL DEFAULT 0, 
    `velStartZ` smallint(6) NOT NULL DEFAULT 0, 
    `stage` int(11) NOT NULL, 
    `style` int(11) NOT NULL DEFAULT '0',
    `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
    PRIMARY KEY (`steamid`,`mapname`,`stage`,`style`), 
    KEY `stagerank` (`mapname`,`runtimepro`,`stage`,`style`)) 
    DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ck_zones (
    `mapname` varchar(54) NOT NULL, 
    `zoneid` int(12) NOT NULL DEFAULT '-1', 
    `zonetype` int(12) DEFAULT '-1', 
    `zonetypeid` int(12) DEFAULT '-1', 
    `pointa_x` float DEFAULT '-1', 
    `pointa_y` float DEFAULT '-1', 
    `pointa_z` float DEFAULT '-1', 
    `pointb_x` float DEFAULT '-1', 
    `pointb_y` float DEFAULT '-1', 
    `pointb_z` float DEFAULT '-1', 
    `vis` int(12) DEFAULT '0', 
    `team` int(12) DEFAULT '0', 
    `zonegroup` int(11) NOT NULL DEFAULT '0', 
    `zonename` varchar(128) DEFAULT NULL, 
    `hookname` varchar(128) DEFAULT 'None', 
    `targetname` varchar(128) DEFAULT 'player', 
    `onejumplimit` int(12) NOT NULL DEFAULT '1', 
    `prespeed` int(64) NOT NULL DEFAULT '260.0',
    `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`mapname`,`zoneid`)) 
    DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ck_prinfo (
    `steamid` VARCHAR(32), 
    `name` VARCHAR(64), 
    `mapname` VARCHAR(32), 
    `runtime` decimal(12,6) NOT NULL DEFAULT '-1.000000', 
    `zonegroup` INT(12) NOT NULL DEFAULT '0', 
    `PRtimeinzone` DECIMAL(12, 6) NOT NULL DEFAULT '0.0', 
    `PRcomplete` FLOAT NOT NULL DEFAULT '0.0', 
    `PRattempts` FLOAT NOT NULL DEFAULT '0.0', 
    `PRstcomplete` FLOAT NOT NULL DEFAULT '0.0', 
    PRIMARY KEY(`steamid`, `mapname`, `zonegroup`)) 
    DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ck_replays (
    `mapname` VARCHAR(32),
    `cp` int(12) NOT NULL DEFAULT '0',
    `frame` int(12) NOT NULL DEFAULT '0',
    `style` INT(12) NOT NULL DEFAULT '0',
    PRIMARY KEY(`mapname`, `cp`, `style`))
    DEFAULT CHARSET=utf8mb4;
