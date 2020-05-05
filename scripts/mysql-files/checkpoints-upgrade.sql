CREATE TABLE `ck_checkpointsnew` (
 `steamid` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
 `mapname` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
 `cp` int(11) NOT NULL,
 `time` float NOT NULL,
 `velStartXY` int(11) NOT NULL,
 `velStartXYZ` int(11) NOT NULL,
 `velStartZ` int(11) NOT NULL,
 `velEndXY` int(11) NOT NULL,
 `velEndXYZ` int(11) NOT NULL,
 `velEndZ` int(11) NOT NULL,
 `velAvgXY` int(11) NOT NULL,
 `velAvgXYZ` int(11) NOT NULL,
 `velAvgZ` int(11) NOT NULL,
 `zonegroup` int(12) NOT NULL,
 PRIMARY KEY (`steamid`,`mapname`,`cp`,`zonegroup`)
);

REPLACE INTO ck_checkpointsnew (steamid, mapname, cp, time, zonegroup)
SELECT * FROM (
    SELECT steamid, mapname, 1 AS cp, cp1 AS time, zonegroup FROM ck_checkpoints
    UNION ALL
    SELECT steamid, mapname, 2 AS cp, cp2, zonegroup FROM ck_checkpoints
	UNION ALL
    SELECT steamid, mapname, 3 AS cp, cp3, zonegroup FROM ck_checkpoints
	UNION ALL
    SELECT steamid, mapname, 4 AS cp, cp4, zonegroup FROM ck_checkpoints
	UNION ALL
	SELECT steamid, mapname, 5 AS cp, cp5, zonegroup FROM ck_checkpoints
	UNION ALL
	SELECT steamid, mapname, 6 AS cp, cp6, zonegroup FROM ck_checkpoints
	UNION ALL
	SELECT steamid, mapname, 7 AS cp, cp7, zonegroup FROM ck_checkpoints
	UNION ALL
	SELECT steamid, mapname, 8 AS cp, cp8, zonegroup FROM ck_checkpoints
	UNION ALL
	SELECT steamid, mapname, 9 AS cp, cp9, zonegroup FROM ck_checkpoints
	UNION ALL
	SELECT steamid, mapname, 10 AS cp, cp10, zonegroup FROM ck_checkpoints
	UNION ALL
	SELECT steamid, mapname, 11 AS cp, cp11, zonegroup FROM ck_checkpoints
	UNION ALL
	SELECT steamid, mapname, 12 AS cp, cp12, zonegroup FROM ck_checkpoints
	UNION ALL
	SELECT steamid, mapname, 13 AS cp, cp13, zonegroup FROM ck_checkpoints
	UNION ALL
	SELECT steamid, mapname, 14 AS cp, cp14, zonegroup FROM ck_checkpoints
	UNION ALL
	SELECT steamid, mapname, 15 AS cp, cp15, zonegroup FROM ck_checkpoints
	UNION ALL
	SELECT steamid, mapname, 16 AS cp, cp16, zonegroup FROM ck_checkpoints
	UNION ALL
	SELECT steamid, mapname, 17 AS cp, cp17, zonegroup FROM ck_checkpoints
	UNION ALL
	SELECT steamid, mapname, 18 AS cp, cp18, zonegroup FROM ck_checkpoints
	UNION ALL
	SELECT steamid, mapname, 19 AS cp, cp19, zonegroup FROM ck_checkpoints
	UNION ALL
	SELECT steamid, mapname, 20 AS cp, cp20, zonegroup FROM ck_checkpoints
	UNION ALL
	SELECT steamid, mapname, 21 AS cp, cp21, zonegroup FROM ck_checkpoints
	UNION ALL
	SELECT steamid, mapname, 22 AS cp, cp22, zonegroup FROM ck_checkpoints
	UNION ALL
	SELECT steamid, mapname, 23 AS cp, cp23, zonegroup FROM ck_checkpoints
	UNION ALL
	SELECT steamid, mapname, 24 AS cp, cp24, zonegroup FROM ck_checkpoints
	UNION ALL
	SELECT steamid, mapname, 25 AS cp, cp25, zonegroup FROM ck_checkpoints
	UNION ALL
	SELECT steamid, mapname, 26 AS cp, cp26, zonegroup FROM ck_checkpoints
	UNION ALL
	SELECT steamid, mapname, 27 AS cp, cp27, zonegroup FROM ck_checkpoints
	UNION ALL
	SELECT steamid, mapname, 28 AS cp, cp28, zonegroup FROM ck_checkpoints
	UNION ALL
	SELECT steamid, mapname, 29 AS cp, cp29, zonegroup FROM ck_checkpoints
	UNION ALL
	SELECT steamid, mapname, 30 AS cp, cp30, zonegroup FROM ck_checkpoints
	UNION ALL
	SELECT steamid, mapname, 31 AS cp, cp31, zonegroup FROM ck_checkpoints
	UNION ALL
	SELECT steamid, mapname, 32 AS cp, cp32, zonegroup FROM ck_checkpoints
	UNION ALL
	SELECT steamid, mapname, 33 AS cp, cp33, zonegroup FROM ck_checkpoints
	UNION ALL
	SELECT steamid, mapname, 34 AS cp, cp34, zonegroup FROM ck_checkpoints
	UNION ALL
	SELECT steamid, mapname, 35 AS cp, cp35, zonegroup FROM ck_checkpoints
) v;

ALTER TABLE ck_checkpoints RENAME TO ck_checkpointsold;
ALTER TABLE ck_checkpointsnew RENAME TO ck_checkpoints;

ALTER TABLE `ck_playertimes` ADD `velStartXY` INT NOT NULL AFTER `runtimepro`, ADD `velStartXYZ` INT NOT NULL AFTER `velStartXY`, ADD `velStartZ` INT NOT NULL AFTER `velStartXYZ`, ADD `velEndXY` INT NOT NULL AFTER `velStartZ`, ADD `velEndXYZ` INT NOT NULL AFTER `velEndXY`, ADD `velEndZ` INT NOT NULL AFTER `velEndXYZ`;

ALTER TABLE `ck_bonus` ADD `velStartXY` INT NOT NULL AFTER `runtime`, ADD `velStartXYZ` INT NOT NULL AFTER `velStartXY`, ADD `velStartZ` INT NOT NULL AFTER `velStartXYZ`, ADD `velEndXY` INT NOT NULL AFTER `velStartZ`, ADD `velEndXYZ` INT NOT NULL AFTER `velEndXY`, ADD `velEndZ` INT NOT NULL AFTER `velEndXYZ`;

ALTER TABLE `ck_wrcps` ADD `velStartXY` INT NOT NULL AFTER `runtimepro`, ADD `velStartXYZ` INT NOT NULL AFTER `velStartXY`, ADD `velStartZ` INT NOT NULL AFTER `velStartXYZ`, ADD `velEndXY` INT NOT NULL AFTER `velStartZ`, ADD `velEndXYZ` INT NOT NULL AFTER `velEndXY`, ADD `velEndZ` INT NOT NULL AFTER `velEndXYZ`;

ALTER TABLE `ck_playeroptions2` ADD `velcmphud` INT NOT NULL DEFAULT 1 AFTER `teleside`, ADD `velcmpchat` INT NOT NULL DEFAULT 1 AFTER `velcmphud`;

ALTER TABLE `ck_wrcps` ADD INDEX `selectwrcps` (`mapname`, `stage`, `runtimepro`);
