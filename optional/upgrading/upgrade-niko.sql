CREATE TABLE IF NOT EXISTS `ck_announcements` (
 `id` int(11) NOT NULL AUTO_INCREMENT,
 `server` varchar(256) NOT NULL DEFAULT 'Beginner',
 `name` varchar(32) NOT NULL,
 `mapname` varchar(128) NOT NULL,
 `time` varchar(32) NOT NULL,
 PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;

ALTER TABLE `ck_bonus`
DROP PRIMARY KEY,
DROP INDEX bonusrank,
ADD COLUMN `style` int(11) NOT NULL DEFAULT 0 AFTER `zonegroup`,
ADD PRIMARY KEY (steamid, mapname, zonegroup, style),
ADD INDEX `bonusrank` (mapname, runtime, zonegroup, style);

CREATE TABLE `ck_mapsettings` (
 `mapname` varchar(128) NOT NULL,
 `startprespeed` float NOT NULL DEFAULT '350',
 `bonusprespeed` float NOT NULL DEFAULT '350',
 `stageprespeed2` float NOT NULL DEFAULT '350',
 `stageprespeed3` float NOT NULL DEFAULT '350',
 `stageprespeed4` float NOT NULL DEFAULT '350',
 `stageprespeed5` float NOT NULL DEFAULT '350',
 `stageprespeed6` float NOT NULL DEFAULT '350',
 `stageprespeed7` float NOT NULL DEFAULT '350',
 `stageprespeed8` float NOT NULL DEFAULT '350',
 `stageprespeed9` float NOT NULL DEFAULT '350',
 `stageprespeed10` float NOT NULL DEFAULT '350',
 `stageprespeed11` float NOT NULL DEFAULT '350',
 `stageprespeed12` float NOT NULL DEFAULT '350',
 `stageprespeed13` float NOT NULL DEFAULT '350',
 `stageprespeed14` float NOT NULL DEFAULT '350',
 `stageprespeed15` float NOT NULL DEFAULT '350',
 `stageprespeed16` float NOT NULL DEFAULT '350',
 `stageprespeed17` float NOT NULL DEFAULT '350',
 `stageprespeed18` float NOT NULL DEFAULT '350',
 `stageprespeed19` float NOT NULL DEFAULT '350',
 `stageprespeed20` float NOT NULL DEFAULT '350',
 `stageprespeed21` float NOT NULL DEFAULT '350',
 `stageprespeed22` float NOT NULL DEFAULT '350',
 `stageprespeed23` float NOT NULL DEFAULT '350',
 `stageprespeed24` float NOT NULL DEFAULT '350',
 `stageprespeed25` float NOT NULL DEFAULT '350',
 `stageprespeed26` float NOT NULL DEFAULT '350',
 `stageprespeed27` float NOT NULL DEFAULT '350',
 `stageprespeed28` float NOT NULL DEFAULT '350',
 `stageprespeed29` float NOT NULL DEFAULT '350',
 `stageprespeed30` float NOT NULL DEFAULT '350',
 `stageprespeed31` float NOT NULL DEFAULT '350',
 `stageprespeed32` float NOT NULL DEFAULT '350',
 `stageprespeed33` float NOT NULL DEFAULT '350',
 `stageprespeed34` float NOT NULL DEFAULT '350',
 `stageprespeed35` float NOT NULL DEFAULT '350',
 `maxvelocity` float NOT NULL DEFAULT '3500',
 `announcerecord` float NOT NULL DEFAULT '0',
 `gravityfix` int(11) NOT NULL DEFAULT '1',
 PRIMARY KEY (`mapname`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `ck_playeroptions2` (
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
 PRIMARY KEY (`steamid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `ck_playerrank`
DROP COLUMN `winratio`,
DROP COLUMN `pointsratio`,
DROP COLUMN `multiplier`,
DROP COLUMN `lastseen`,
ADD COLUMN `wrpoints` int(12) NOT NULL DEFAULT 0 AFTER `points`,
ADD COLUMN `wrbpoints` int(12) NOT NULL DEFAULT 0 AFTER `wrpoints`,
ADD COLUMN `top10points` int(12) NOT NULL DEFAULT 0 AFTER `wrbpoints`,
ADD COLUMN `groupspoints` int(12) NOT NULL DEFAULT 0 AFTER `top10points`,
ADD COLUMN `mappoints` int(12) NOT NULL DEFAULT 0 AFTER `groupspoints`,
ADD COLUMN `bonuspoints` int(12) NOT NULL DEFAULT 0 AFTER `mappoints`,
ADD COLUMN `finishedbonuses` int(12) NOT NULL DEFAULT 0 AFTER `finishedmapspro`,
ADD COLUMN `finishedstages` int(12) NOT NULL DEFAULT 0 AFTER `finishedbonuses`,
ADD COLUMN `wrs` int(12) NOT NULL DEFAULT 0 AFTER `finishedstages`,
ADD COLUMN `wrbs` int(12) NOT NULL DEFAULT 0 AFTER `wrs`,
ADD COLUMN `wrcps` int(12) NOT NULL DEFAULT 0 AFTER `wrbs`,
ADD COLUMN `top10s` int(12) NOT NULL DEFAULT 0 AFTER `wrcps`,
ADD COLUMN `groups` int(12) NOT NULL DEFAULT 0 AFTER `top10s`,
ADD COLUMN `lastseen` int(64) NULL DEFAULT NULL AFTER `groups`,
ADD COLUMN `joined` int(64) NOT NULL AFTER `lastseen`,
ADD COLUMN `timealive` int(64) NOT NULL DEFAULT 0 AFTER `joined`,
ADD COLUMN `timespec` int(64) NOT NULL DEFAULT 0 AFTER `timealive`,
ADD COLUMN `connections` int(64) NOT NULL DEFAULT 1 AFTER `timespec`,
ADD COLUMN `readchangelog` int(11) NOT NULL DEFAULT 0 AFTER `connections`;

ALTER TABLE `ck_playertimes`
DROP PRIMARY KEY,
DROP INDEX maprank,
ADD COLUMN `style` int(11) NOT NULL DEFAULT 0 AFTER `runtimepro`,
ADD PRIMARY KEY (steamid, mapname, style),
ADD INDEX `maprank` (mapname, runtimepro, style);

ALTER TABLE `ck_spawnlocations`
ADD COLUMN `vel_x` float NOT NULL DEFAULT 0 AFTER `ang_y`,
ADD COLUMN `vel_y` float NOT NULL DEFAULT 0 AFTER `vel_x`,
ADD COLUMN `vel_z` float NOT NULL DEFAULT 0 AFTER `vel_y`;

CREATE TABLE IF NOT EXISTS `ck_vipadmins` (
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
 KEY `vip` (`steamid`,`vip`,`admin`,`zoner`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `ck_wrcps` (
 `steamid` varchar(32) NOT NULL DEFAULT '',
 `name` varchar(32) DEFAULT NULL,
 `mapname` varchar(32) NOT NULL DEFAULT '',
 `runtimepro` float NOT NULL DEFAULT '-1',
 `stage` int(11) NOT NULL,
 `style` int(11) NOT NULL DEFAULT '0',
 PRIMARY KEY (`steamid`,`mapname`,`stage`,`style`),
 KEY `stagerank` (`mapname`,`runtimepro`,`stage`,`style`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `ck_zones`
ADD COLUMN `hookname` varchar(128) NULL DEFAULT 'None' AFTER `zonename`,
ADD COLUMN `targetname` varchar(128) NULL DEFAULT 'player' AFTER `hookname`,
ADD COLUMN `onejumplimit` int(12) NOT NULL DEFAULT 1 AFTER `targetname`;
