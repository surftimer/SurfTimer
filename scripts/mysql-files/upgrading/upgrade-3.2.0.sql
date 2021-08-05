-- WARNING! This file will upgrade your databse to new format used by version 3.2.X, please always backup your database I'm not responsible if You brick it!

CREATE TABLE `ck_checkpointsnew` (
 `steamid` varchar(32),
 `mapname` varchar(32),
 `cp` SMALLINT(6) NOT NULL,
 `time` float NOT NULL,
 `velStartXY` SMALLINT(6) NOT NULL DEFAULT '0',
 `velStartXYZ` SMALLINT(6) NOT NULL DEFAULT '0',
 `velStartZ` SMALLINT(6) NOT NULL DEFAULT '0',
 `zonegroup` TINYINT(4) NOT NULL,
 PRIMARY KEY (`steamid`,`mapname`,`cp`,`zonegroup`)
);

REPLACE INTO ck_checkpointsnew (steamid, mapname, cp, time, zonegroup)
SELECT * FROM (
    SELECT steamid, mapname, 1 AS cp, cp1 AS time, zonegroup FROM ck_checkpoints WHERE cp1 > 0.0
    UNION ALL
    SELECT steamid, mapname, 2 AS cp, cp2, zonegroup FROM ck_checkpoints WHERE cp2 > 0.0
	UNION ALL
    SELECT steamid, mapname, 3 AS cp, cp3, zonegroup FROM ck_checkpoints WHERE cp3 > 0.0
	UNION ALL
    SELECT steamid, mapname, 4 AS cp, cp4, zonegroup FROM ck_checkpoints WHERE cp4 > 0.0
	UNION ALL
	SELECT steamid, mapname, 5 AS cp, cp5, zonegroup FROM ck_checkpoints WHERE cp5 > 0.0
	UNION ALL
	SELECT steamid, mapname, 6 AS cp, cp6, zonegroup FROM ck_checkpoints WHERE cp6 > 0.0
	UNION ALL
	SELECT steamid, mapname, 7 AS cp, cp7, zonegroup FROM ck_checkpoints WHERE cp7 > 0.0
	UNION ALL
	SELECT steamid, mapname, 8 AS cp, cp8, zonegroup FROM ck_checkpoints WHERE cp8 > 0.0
	UNION ALL
	SELECT steamid, mapname, 9 AS cp, cp9, zonegroup FROM ck_checkpoints WHERE cp9 > 0.0
	UNION ALL
	SELECT steamid, mapname, 10 AS cp, cp10, zonegroup FROM ck_checkpoints WHERE cp10 > 0.0
	UNION ALL
	SELECT steamid, mapname, 11 AS cp, cp11, zonegroup FROM ck_checkpoints WHERE cp11 > 0.0
	UNION ALL
	SELECT steamid, mapname, 12 AS cp, cp12, zonegroup FROM ck_checkpoints WHERE cp12 > 0.0
	UNION ALL
	SELECT steamid, mapname, 13 AS cp, cp13, zonegroup FROM ck_checkpoints WHERE cp13 > 0.0
	UNION ALL
	SELECT steamid, mapname, 14 AS cp, cp14, zonegroup FROM ck_checkpoints WHERE cp14 > 0.0
	UNION ALL
	SELECT steamid, mapname, 15 AS cp, cp15, zonegroup FROM ck_checkpoints WHERE cp15 > 0.0
	UNION ALL
	SELECT steamid, mapname, 16 AS cp, cp16, zonegroup FROM ck_checkpoints WHERE cp16 > 0.0
	UNION ALL
	SELECT steamid, mapname, 17 AS cp, cp17, zonegroup FROM ck_checkpoints WHERE cp17 > 0.0
	UNION ALL
	SELECT steamid, mapname, 18 AS cp, cp18, zonegroup FROM ck_checkpoints WHERE cp18 > 0.0
	UNION ALL
	SELECT steamid, mapname, 19 AS cp, cp19, zonegroup FROM ck_checkpoints WHERE cp19 > 0.0
	UNION ALL
	SELECT steamid, mapname, 20 AS cp, cp20, zonegroup FROM ck_checkpoints WHERE cp20 > 0.0
	UNION ALL
	SELECT steamid, mapname, 21 AS cp, cp21, zonegroup FROM ck_checkpoints WHERE cp21 > 0.0
	UNION ALL
	SELECT steamid, mapname, 22 AS cp, cp22, zonegroup FROM ck_checkpoints WHERE cp22 > 0.0
	UNION ALL
	SELECT steamid, mapname, 23 AS cp, cp23, zonegroup FROM ck_checkpoints WHERE cp23 > 0.0
	UNION ALL
	SELECT steamid, mapname, 24 AS cp, cp24, zonegroup FROM ck_checkpoints WHERE cp24 > 0.0
	UNION ALL
	SELECT steamid, mapname, 25 AS cp, cp25, zonegroup FROM ck_checkpoints WHERE cp25 > 0.0
	UNION ALL
	SELECT steamid, mapname, 26 AS cp, cp26, zonegroup FROM ck_checkpoints WHERE cp26 > 0.0
	UNION ALL
	SELECT steamid, mapname, 27 AS cp, cp27, zonegroup FROM ck_checkpoints WHERE cp27 > 0.0
	UNION ALL
	SELECT steamid, mapname, 28 AS cp, cp28, zonegroup FROM ck_checkpoints WHERE cp28 > 0.0
	UNION ALL
	SELECT steamid, mapname, 29 AS cp, cp29, zonegroup FROM ck_checkpoints WHERE cp29 > 0.0
	UNION ALL
	SELECT steamid, mapname, 30 AS cp, cp30, zonegroup FROM ck_checkpoints WHERE cp30 > 0.0
	UNION ALL
	SELECT steamid, mapname, 31 AS cp, cp31, zonegroup FROM ck_checkpoints WHERE cp31 > 0.0
	UNION ALL
	SELECT steamid, mapname, 32 AS cp, cp32, zonegroup FROM ck_checkpoints WHERE cp32 > 0.0
	UNION ALL
	SELECT steamid, mapname, 33 AS cp, cp33, zonegroup FROM ck_checkpoints WHERE cp33 > 0.0
	UNION ALL
	SELECT steamid, mapname, 34 AS cp, cp34, zonegroup FROM ck_checkpoints WHERE cp34 > 0.0
	UNION ALL
	SELECT steamid, mapname, 35 AS cp, cp35, zonegroup FROM ck_checkpoints WHERE cp35 > 0.0
) v;

ALTER TABLE ck_checkpoints RENAME TO ck_checkpointsold;
ALTER TABLE ck_checkpointsnew RENAME TO ck_checkpoints;

ALTER TABLE `ck_playertimes` ADD `velStartXY` SMALLINT NOT NULL AFTER `runtimepro`, ADD `velStartXYZ` SMALLINT NOT NULL AFTER `velStartXY`, ADD `velStartZ` SMALLINT NOT NULL AFTER `velStartXYZ`, ADD `velEndXY` SMALLINT NOT NULL AFTER `velStartZ`, ADD `velEndXYZ` SMALLINT NOT NULL AFTER `velEndXY`, ADD `velEndZ` SMALLINT NOT NULL AFTER `velEndXYZ`;

ALTER TABLE `ck_bonus` ADD `velStartXY` SMALLINT NOT NULL AFTER `runtime`, ADD `velStartXYZ` SMALLINT NOT NULL AFTER `velStartXY`, ADD `velStartZ` SMALLINT NOT NULL AFTER `velStartXYZ`, ADD `velEndXY` SMALLINT NOT NULL AFTER `velStartZ`, ADD `velEndXYZ` SMALLINT NOT NULL AFTER `velEndXY`, ADD `velEndZ` SMALLINT NOT NULL AFTER `velEndXYZ`;

ALTER TABLE `ck_wrcps` ADD `velStartXY` SMALLINT NOT NULL AFTER `runtimepro`, ADD `velStartXYZ` SMALLINT NOT NULL AFTER `velStartXY`, ADD `velStartZ` SMALLINT NOT NULL AFTER `velStartXYZ`;

ALTER TABLE `ck_playeroptions2` ADD `smallhud` tinyint NOT NULL DEFAULT 1 AFTER `wrcpmessages`;
ALTER TABLE `ck_playerrank` DROP `readchangelog`;