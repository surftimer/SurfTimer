/////////////////////////
// PREPARED STATEMENTS //
////////////////////////

// ck_announcements
char sql_createAnnouncements[] = "CREATE TABLE IF NOT EXISTS `ck_announcements` (`id` int(11) NOT NULL AUTO_INCREMENT, `server` varchar(256) NOT NULL DEFAULT 'Beginner', `name` varchar(32) NOT NULL, `mapname` varchar(128) NOT NULL, `mode` smallint(4) NOT NULL DEFAULT '0', `time` varchar(32) NOT NULL, `group` tinyint(4) NOT NULL DEFAULT '0', `style` tinyint(4) NOT NULL DEFAULT '0', PRIMARY KEY (`id`))DEFAULT CHARSET=utf8mb4;";

// ck_bonus
char sql_createBonus[] = "CREATE TABLE IF NOT EXISTS ck_bonus (steamid VARCHAR(32) NOT NULL, name VARCHAR(32) NOT NULL, mapname VARCHAR(32) NOT NULL, runtime FLOAT NOT NULL DEFAULT '-1.0',`velStartXY` smallint(6) NOT NULL,`velStartXYZ` smallint(6) NOT NULL,`velStartZ` smallint(6) NOT NULL,`velEndXY` smallint(6) NOT NULL,`velEndXYZ` smallint(6) NOT NULL,`velEndZ` smallint(6) NOT NULL, zonegroup SMALLINT(6) NOT NULL DEFAULT 1, style TINYINT(4) NOT NULL DEFAULT 0, PRIMARY KEY(steamid, mapname, zonegroup, style)) DEFAULT CHARSET=utf8mb4;";
char sql_createBonusIndex[] = "CREATE INDEX bonusrank ON ck_bonus (mapname,runtime,zonegroup,style);";
char sql_insertBonus[] = "INSERT INTO ck_bonus (steamid, name, mapname, runtime, zonegroup, velStartXY, velStartXYZ, velStartZ, velEndXY, velEndXYZ, velEndZ) VALUES ('%s', '%s', '%s', '%f', '%i', '%i', '%i', '%i', '%i', '%i', '%i')";
char sql_updateBonus[] = "UPDATE ck_bonus SET runtime = '%f', name = '%s', velStartXY = %i, velStartXYZ = %i, velStartZ = %i, velEndXY = %i, velEndXYZ = %i, velEndZ = %i WHERE steamid = '%s' AND mapname = '%s' AND zonegroup = %i";
char sql_selectBonusCount[] = "SELECT zonegroup, style, count(1) FROM ck_bonus WHERE mapname = '%s' GROUP BY zonegroup, style;";
char sql_selectPersonalBonusRecords[] = "SELECT runtime, zonegroup, style, velStartXY, velStartXYZ, velStartZ, velEndXY, velEndXYZ, velEndZ FROM ck_bonus WHERE steamid = '%s' AND mapname = '%s' AND runtime > '0.0'";
char sql_selectPlayerRankBonus[] = "SELECT name FROM ck_bonus WHERE runtime <= (SELECT runtime FROM ck_bonus WHERE steamid = '%s' AND mapname= '%s' AND runtime > 0.0 AND zonegroup = %i AND style = 0) AND mapname = '%s' AND zonegroup = %i AND style = 0;";
char sql_selectFastestBonus[] = "SELECT name, MIN(runtime), zonegroup, style, velStartXY, velStartXYZ, velStartZ, velEndXY, velEndXYZ, velEndZ FROM ck_bonus WHERE mapname = '%s' GROUP BY zonegroup, style;";
char sql_deleteBonus[] = "DELETE FROM ck_bonus WHERE mapname = '%s'";
char sql_selectAllBonusTimesinMap[] = "SELECT zonegroup, runtime from ck_bonus WHERE mapname = '%s';";
char sql_selectTopBonusSurfers[] = "SELECT db2.steamid, db1.name, db2.runtime as overall, db1.steamid, db2.mapname FROM ck_bonus as db2 INNER JOIN ck_playerrank as db1 on db2.steamid = db1.steamid WHERE db2.mapname = '%s' AND db2.style = 0 AND db1.style = 0 AND db2.runtime > -1.0 AND zonegroup = %i ORDER BY overall ASC LIMIT 100;";

// ck_checkpoints
char sql_createCheckpoints[] = "CREATE TABLE `ck_checkpoints` (`steamid` VARCHAR(32) NOT NULL,`mapname` VARCHAR(32) NOT NULL,`cp` smallint(6) NOT NULL,`time` float NOT NULL,`velStartXY` smallint(6) NOT NULL,`velStartXYZ` smallint(6) NOT NULL,`velStartZ` smallint(6) NOT NULL,`zonegroup` tinyint(4) NOT NULL,PRIMARY KEY (`steamid`,`mapname`,`cp`,`zonegroup`)) DEFAULT CHARSET=utf8mb4";

// char sql_updateCheckpoints[] = "UPDATE ck_checkpoints SET cp1='%f', cp2='%f', cp3='%f', cp4='%f', cp5='%f', cp6='%f', cp7='%f', cp8='%f', cp9='%f', cp10='%f', cp11='%f', cp12='%f', cp13='%f', cp14='%f', cp15='%f', cp16='%f', cp17='%f', cp18='%f', cp19='%f', cp20='%f', cp21='%f', cp22='%f', cp23='%f', cp24='%f', cp25='%f', cp26='%f', cp27='%f', cp28='%f', cp29='%f', cp30='%f', cp31='%f', cp32='%f', cp33='%f', cp34='%f', cp35='%f' WHERE steamid='%s' AND mapname='%s' AND zonegroup='%i'";
char sql_updateCheckpoint[] = "UPDATE ck_checkpoints SET time = '%f', velStartXY = %d, velStartXYZ = %d, velStartZ = %d WHERE steamid = '%s' AND mapname = '%s' AND cp = %d AND zonegroup = %d;";

//char sql_insertCheckpoints[] = "INSERT INTO ck_checkpoints VALUES ('%s', '%s', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%i')";
char sql_insertCheckpoint[] = "INSERT INTO ck_checkpoints VALUES ('%s', '%s', '%d', '%f', '%d', '%d', '%d', '%d');";

//char sql_selectCheckpoints[] = "SELECT zonegroup, cp1, cp2, cp3, cp4, cp5, cp6, cp7, cp8, cp9, cp10, cp11, cp12, cp13, cp14, cp15, cp16, cp17, cp18, cp19, cp20, cp21, cp22, cp23, cp24, cp25, cp26, cp27, cp28, cp29, cp30, cp31, cp32, cp33, cp34, cp35 FROM ck_checkpoints WHERE mapname='%s' AND steamid = '%s';";
char sql_selectCheckpoints[] = "SELECT zonegroup, cp, time, velStartXY, velStartXYZ, velStartZ FROM ck_checkpoints WHERE mapname = '%s' AND steamid = '%s' AND zonegroup = 0;";

//char sql_selectCheckpointsinZoneGroup[] = "SELECT cp1, cp2, cp3, cp4, cp5, cp6, cp7, cp8, cp9, cp10, cp11, cp12, cp13, cp14, cp15, cp16, cp17, cp18, cp19, cp20, cp21, cp22, cp23, cp24, cp25, cp26, cp27, cp28, cp29, cp30, cp31, cp32, cp33, cp34, cp35 FROM ck_checkpoints WHERE mapname='%s' AND steamid = '%s' AND zonegroup = %i;";
char sql_selectCheckpointsinZoneGroup[] = "SELECT zonegroup, cp, time, velStartXY, velStartXYZ, velStartZ FROM ck_checkpoints WHERE mapname='%s' AND steamid = '%s' AND zonegroup = %d;";

//char sql_selectRecordCheckpoints[] = "SELECT zonegroup, cp1, cp2, cp3, cp4, cp5, cp6, cp7, cp8, cp9, cp10, cp11, cp12, cp13, cp14, cp15, cp16, cp17, cp18, cp19, cp20, cp21, cp22, cp23, cp24, cp25, cp26, cp27, cp28, cp29, cp30, cp31, cp32, cp33, cp34, cp35 FROM ck_checkpoints WHERE steamid = '%s' AND mapname='%s' UNION SELECT a.zonegroup, b.cp1, b.cp2, b.cp3, b.cp4, b.cp5, b.cp6, b.cp7, b.cp8, b.cp9, b.cp10, b.cp11, b.cp12, b.cp13, b.cp14, b.cp15, b.cp16, b.cp17, b.cp18, b.cp19, b.cp20, b.cp21, b.cp22, b.cp23, b.cp24, b.cp25, b.cp26, b.cp27, b.cp28, b.cp29, b.cp30, b.cp31, b.cp32, b.cp33, b.cp34, b.cp35 FROM ck_bonus a LEFT JOIN ck_checkpoints b ON a.steamid = b.steamid AND a.zonegroup = b.zonegroup WHERE a.mapname = '%s' GROUP BY a.zonegroup";
char sql_selectRecordCheckpoints[] = "SELECT steamid, mapname, cp, time, velStartXY, velStartXYZ, velStartZ, zonegroup FROM ck_checkpoints WHERE steamid = '%s' AND mapname = '%s' AND zonegroup = 0;";

char sql_deleteCheckpoints[] = "DELETE FROM ck_checkpoints WHERE mapname = '%s'";

// ck_latestrecords
char sql_createLatestRecords[] = "CREATE TABLE IF NOT EXISTS ck_latestrecords (steamid VARCHAR(32) NOT NULL, name VARCHAR(32) NOT NULL, runtime FLOAT NOT NULL DEFAULT '-1.0', map VARCHAR(32) NOT NULL, date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY(steamid,map,date)) DEFAULT CHARSET=utf8mb4;";
char sql_insertLatestRecords[] = "INSERT INTO ck_latestrecords (steamid, name, runtime, map) VALUES('%s','%s','%f','%s');";
char sql_selectLatestRecords[] = "SELECT name, runtime, map, date FROM ck_latestrecords ORDER BY date DESC LIMIT 50";

// ck_maptier
char sql_createMapTier[] = "CREATE TABLE IF NOT EXISTS ck_maptier (mapname VARCHAR(54) NOT NULL, tier TINYINT(4) NOT NULL DEFAULT '0', maxvelocity FLOAT NOT NULL DEFAULT '3500.0', announcerecord TINYINT(4) NOT NULL DEFAULT '0', gravityfix TINYINT(4) NOT NULL DEFAULT '1', ranked TINYINT(4) NOT NULL DEFAULT '1', PRIMARY KEY(mapname)) DEFAULT CHARSET=utf8mb4;";
char sql_selectMapTier[] = "SELECT tier, ranked FROM ck_maptier WHERE mapname = '%s'";
char sql_insertmaptier[] = "INSERT INTO ck_maptier (mapname, tier) VALUES ('%s', '%i');";
char sql_updatemaptier[] = "UPDATE ck_maptier SET tier = %i WHERE mapname ='%s'";

// ck_playeroptions2
char sql_createPlayerOptions[] = "CREATE TABLE IF NOT EXISTS `ck_playeroptions2` (`steamid` varchar(32) NOT NULL DEFAULT '', `timer` tinyint(4) NOT NULL DEFAULT '1', `hide` tinyint(4) NOT NULL DEFAULT '0', `sounds` tinyint(4) NOT NULL DEFAULT '1', `chat` tinyint(4) NOT NULL DEFAULT '0', `viewmodel` tinyint(4) NOT NULL DEFAULT '1', `autobhop` tinyint(4) NOT NULL DEFAULT '1', `checkpoints` tinyint(4) NOT NULL DEFAULT '1', `gradient` tinyint(4) NOT NULL DEFAULT '3', `speedmode` tinyint(4) NOT NULL DEFAULT '0', `centrespeed` tinyint(4) NOT NULL DEFAULT '0', `centrehud` tinyint(4) NOT NULL DEFAULT '1', teleside tinyint(4) NOT NULL DEFAULT '0', `module1c` tinyint(4) NOT NULL DEFAULT '1', `module2c` tinyint(4) NOT NULL DEFAULT '2', `module3c` tinyint(4) NOT NULL DEFAULT '3', `module4c` tinyint(4) NOT NULL DEFAULT '4', `module5c` tinyint(4) NOT NULL DEFAULT '5', `module6c` tinyint(4) NOT NULL DEFAULT '6', `sidehud` tinyint(4) NOT NULL DEFAULT '1', `module1s` tinyint(4) NOT NULL DEFAULT '5', `module2s` tinyint(4) NOT NULL DEFAULT '0', `module3s` tinyint(4) NOT NULL DEFAULT '0', `module4s` tinyint(4) NOT NULL DEFAULT '0', `module5s` tinyint(4) NOT NULL DEFAULT '0', prestrafe tinyint(4) NOT NULL DEFAULT '0', cpmessages tinyint(4) NOT NULL DEFAULT '1', wrcpmessages tinyint(4) NOT NULL DEFAULT '1', smallhud tinyint(4) NOT NULL DEFAULT '1', PRIMARY KEY (`steamid`)) DEFAULT CHARSET=utf8mb4;";
char sql_insertPlayerOptions[] = "INSERT INTO ck_playeroptions2 (steamid) VALUES ('%s');";
char sql_selectPlayerOptions[] = "SELECT * FROM ck_playeroptions2 where steamid = '%s';";
char sql_updatePlayerOptions[] = "UPDATE ck_playeroptions2 SET timer = %i, hide = %i, sounds = %i, chat = %i, viewmodel = %i, autobhop = %i, checkpoints = %i, gradient = %i, speedmode = %i, centrespeed = %i, centrehud = %i, teleside = %i, module1c = %i, module2c = %i, module3c = %i, module4c = %i, module5c = %i, module6c = %i, sidehud = %i, module1s = %i, module2s = %i, module3s = %i, module4s = %i, module5s = %i, prestrafe = %i, cpmessages = %i, wrcpmessages = %i, smallhud = %i	 where steamid = '%s'";

// ck_playerrank
char sql_createPlayerRank[] = "CREATE TABLE IF NOT EXISTS `ck_playerrank` (`steamid` varchar(32) NOT NULL DEFAULT '', `steamid64` varchar(64) NOT NULL, `name` varchar(32) NOT NULL, `country` varchar(32) NOT NULL DEFAULT 'Unknown', `points` int(12) NOT NULL DEFAULT '0', `wrpoints` int(12) NOT NULL DEFAULT '0', `wrbpoints` int(12) NOT NULL DEFAULT '0', `wrcppoints` int(11) NOT NULL DEFAULT '0', `top10points` int(12) NOT NULL DEFAULT '0', `groupspoints` int(12) NOT NULL DEFAULT '0', `mappoints` int(11) NOT NULL DEFAULT '0', `bonuspoints` int(12) NOT NULL DEFAULT '0', `finishedmaps` smallint(6) NOT NULL DEFAULT '0', `finishedmapspro` smallint(6) NOT NULL DEFAULT '0', `finishedbonuses` smallint(6) NOT NULL DEFAULT '0', `finishedstages` smallint(6) NOT NULL DEFAULT '0', `wrs` smallint(6) NOT NULL DEFAULT '0', `wrbs` smallint(6) NOT NULL DEFAULT '0', `wrcps` smallint(6) NOT NULL DEFAULT '0', `top10s` smallint(6) NOT NULL DEFAULT '0', `groups` smallint(6) NOT NULL DEFAULT '0', `lastseen` int(64) NOT NULL, `joined` int(64) NOT NULL, `timealive` int(64) NOT NULL DEFAULT '0', `timespec` int(64) NOT NULL DEFAULT '0', `connections` int(64) NOT NULL DEFAULT '1', `style` tinyint(4) NOT NULL DEFAULT '0', PRIMARY KEY (`steamid`, `style`)) DEFAULT CHARSET=utf8mb4;";
char sql_insertPlayerRank[] = "INSERT INTO ck_playerrank (steamid, steamid64, name, country, joined, style) VALUES('%s', '%s', '%s', '%s', %i, %i)";
char sql_updatePlayerRankPoints[] = "UPDATE ck_playerrank SET name ='%s', points ='%i', wrpoints = %i, wrbpoints = %i, wrcppoints = %i, top10points = %i, groupspoints = %i, mappoints = %i, bonuspoints = %i, finishedmapspro='%i', finishedbonuses = %i, finishedstages = %i, wrs = %i, wrbs = %i, wrcps = %i, top10s = %i, `groups` = %i where steamid='%s' AND style = %i;";
char sql_updatePlayerRankPoints2[] = "UPDATE ck_playerrank SET name ='%s', points ='%i', wrpoints = %i, wrbpoints = %i, wrcppoints = %i, top10points = %i, groupspoints = %i, mappoints = %i, bonuspoints = %i, finishedmapspro='%i', finishedbonuses = %i, finishedstages = %i, wrs = %i, wrbs = %i, wrcps = %i, top10s = %i, `groups` = %i, country = '%s' where steamid='%s' AND style = %i;";
char sql_updatePlayerRank[] = "UPDATE ck_playerrank SET finishedmaps ='%i', finishedmapspro='%i' where steamid='%s' AND style = '%i';";
char sql_selectPlayerName[] = "SELECT name FROM ck_playerrank where steamid = '%s'";
char sql_UpdateLastSeenMySQL[] = "UPDATE ck_playerrank SET lastseen = UNIX_TIMESTAMP() where steamid = '%s';";
char sql_UpdateLastSeenSQLite[] = "UPDATE ck_playerrank SET lastseen = date('now') where steamid = '%s';";
char sql_selectTopPlayers[] = "SELECT name, points, finishedmapspro, steamid FROM ck_playerrank WHERE style = %i ORDER BY points DESC LIMIT 100";
char sql_selectRankedPlayer[] = "SELECT steamid, name, points, finishedmapspro, country, lastseen, timealive, timespec, connections, style from ck_playerrank where steamid='%s';";
char sql_selectRankedPlayersRank[] = "SELECT COUNT(*) FROM ck_playerrank WHERE style = %i AND points >= (SELECT points FROM ck_playerrank WHERE steamid = '%s' AND style = %i);";
char sql_selectRankedPlayers[] = "SELECT steamid, name from ck_playerrank where points > 0 AND style = 0 ORDER BY points DESC LIMIT 0, 1067;";
char sql_CountRankedPlayers[] = "SELECT COUNT(steamid) FROM ck_playerrank WHERE style = %i;";
char sql_CountRankedPlayers2[] = "SELECT COUNT(steamid) FROM ck_playerrank where points > 0 AND style = %i;";
char sql_selectPlayerProfile[] = "SELECT steamid, steamid64, name, country, points, wrpoints, wrbpoints, wrcppoints, top10points, groupspoints, mappoints, bonuspoints, finishedmapspro, finishedbonuses, finishedstages, wrs, wrbs, wrcps, top10s, `groups`, lastseen FROM ck_playerrank WHERE steamid = '%s' AND style = '%i';";

// ck_playertemp
char sql_createPlayertmp[] = "CREATE TABLE IF NOT EXISTS ck_playertemp (steamid VARCHAR(32) NOT NULL, mapname VARCHAR(32) NOT NULL, cords1 FLOAT NOT NULL DEFAULT '-1.0', cords2 FLOAT NOT NULL DEFAULT '-1.0', cords3 FLOAT NOT NULL DEFAULT '-1.0', angle1 FLOAT NOT NULL DEFAULT '-1.0',angle2 FLOAT NOT NULL DEFAULT '-1.0',angle3 FLOAT NOT NULL DEFAULT '-1.0', EncTickrate INT(12) NOT NULL DEFAULT '-1.0', runtimeTmp FLOAT NOT NULL DEFAULT '-1.0', Stage SMALLINT(6) NOT NULL DEFAULT '0', zonegroup TINYINT(4) NOT NULL DEFAULT '0', PRIMARY KEY(steamid,mapname)) DEFAULT CHARSET=utf8mb4;";
char sql_insertPlayerTmp[] = "INSERT INTO ck_playertemp (cords1, cords2, cords3, angle1,angle2,angle3,runtimeTmp,steamid,mapname,EncTickrate,Stage,zonegroup) VALUES ('%f','%f','%f','%f','%f','%f','%f','%s', '%s', '%i', %i, %i);";
char sql_updatePlayerTmp[] = "UPDATE ck_playertemp SET cords1 = '%f', cords2 = '%f', cords3 = '%f', angle1 = '%f', angle2 = '%f', angle3 = '%f', runtimeTmp = '%f', mapname ='%s', EncTickrate='%i', Stage = %i, zonegroup = %i WHERE steamid = '%s';";
char sql_deletePlayerTmp[] = "DELETE FROM ck_playertemp where steamid = '%s';";
char sql_selectPlayerTmp[] = "SELECT cords1,cords2,cords3, angle1, angle2, angle3,runtimeTmp, EncTickrate, Stage, zonegroup FROM ck_playertemp WHERE steamid = '%s' AND mapname = '%s';";

// ck_playertimes
char sql_createPlayertimes[] = "CREATE TABLE IF NOT EXISTS ck_playertimes (steamid VARCHAR(32) NOT NULL, mapname VARCHAR(32) NOT NULL, name VARCHAR(32) NOT NULL, runtimepro FLOAT NOT NULL DEFAULT '-1.0', velStartXY SMALLINT(6) NOT NULL DEFAULT '0', velStartXYZ SMALLINT(6) NOT NULL DEFAULT '0', velStartZ SMALLINT(6) NOT NULL DEFAULT '0', velEndXY SMALLINT(6) NOT NULL DEFAULT '0', velEndXYZ SMALLINT(6) NOT NULL DEFAULT '0', velEndZ SMALLINT(6) NOT NULL DEFAULT '0', style TINYINT(4) NOT NULL DEFAULT '0', PRIMARY KEY(steamid, mapname, style)) DEFAULT CHARSET=utf8mb4;";
char sql_createPlayertimesIndex[] = "CREATE INDEX maprank ON ck_playertimes (mapname, runtimepro, style);";
char sql_insertPlayer[] = "INSERT INTO ck_playertimes (steamid, mapname, name) VALUES('%s', '%s', '%s');";
char sql_insertPlayerTime[] = "INSERT INTO ck_playertimes (steamid, mapname, name, runtimepro, velStartXY, velStartXYZ, velStartZ, velEndXY, velEndXYZ, velEndZ, style) VALUES('%s', '%s', '%s', '%f', %i, %i, %i, %i, %i, %i, %i);";
char sql_updateRecordPro[] = "UPDATE ck_playertimes SET name = '%s', runtimepro = '%f', velStartXY = %i, velStartXYZ = %i, velStartZ = %i, velEndXY = %i, velEndXYZ = %i, velEndZ = %i WHERE steamid = '%s' AND mapname = '%s' AND style = %i;";
char sql_selectPlayer[] = "SELECT steamid FROM ck_playertimes WHERE steamid = '%s' AND mapname = '%s';";
char sql_selectMapRecord[] = "SELECT runtimepro, name, steamid, velStartXY, velStartXYZ, velStartZ, velEndXY, velEndXYZ, velEndZ, style FROM ck_playertimes a WHERE runtimepro = ( SELECT MIN(runtimepro) FROM ck_playertimes b WHERE b.style = a.style AND mapname='%s' ) AND mapname='%s';";
char sql_selectPersonalAllRecords[] = "SELECT db1.name, db2.steamid, db2.mapname, db2.runtimepro as overall, db1.steamid, db3.tier FROM ck_playertimes as db2 INNER JOIN ck_playerrank as db1 on db2.steamid = db1.steamid INNER JOIN ck_maptier AS db3 ON db2.mapname = db3.mapname WHERE db2.steamid = '%s' AND db2.style = %i AND db1.style = %i AND db2.runtimepro > -1.0 ORDER BY mapname ASC;";
char sql_selectTopSurfers[] = "SELECT db2.steamid, db1.name, db2.runtimepro as overall, db1.steamid, db2.mapname FROM ck_playertimes as db2 INNER JOIN ck_playerrank as db1 on db2.steamid = db1.steamid WHERE db2.mapname = '%s' AND db1.style = %i AND db2.style = %i AND db2.runtimepro > -1.0 ORDER BY overall ASC LIMIT 50;";
char sql_selectPlayerProCount[] = "SELECT style, count(1) FROM ck_playertimes WHERE mapname = '%s' GROUP BY style;";
char sql_selectPlayerRankProTime[] = "SELECT COUNT(*) FROM ck_playertimes WHERE runtimepro <= (SELECT runtimepro FROM ck_playertimes WHERE steamid = '%s' AND mapname = '%s' AND style = 0 AND runtimepro > -1.0) AND mapname = '%s' AND style = 0 AND runtimepro > -1.0;";
char sql_selectAllMapTimesinMap[] = "SELECT runtimepro from ck_playertimes WHERE mapname = '%s';";

// ck_spawnlocations
char sql_createSpawnLocations[] = "CREATE TABLE IF NOT EXISTS ck_spawnlocations (mapname VARCHAR(54) NOT NULL, pos_x FLOAT NOT NULL, pos_y FLOAT NOT NULL, pos_z FLOAT NOT NULL, ang_x FLOAT NOT NULL, ang_y FLOAT NOT NULL, ang_z FLOAT NOT NULL,  `vel_x` float NOT NULL DEFAULT '0', `vel_y` float NOT NULL DEFAULT '0', `vel_z` float NOT NULL DEFAULT '0', zonegroup TINYINT(4) NOT NULL DEFAULT 0, stage SMALLINT(6) NOT NULL DEFAULT 0, teleside TINYINT(4) NOT NULL DEFAULT 0, PRIMARY KEY(mapname, zonegroup, stage, teleside)) DEFAULT CHARSET=utf8mb4;";
char sql_insertSpawnLocations[] = "INSERT INTO ck_spawnlocations (mapname, pos_x, pos_y, pos_z, ang_x, ang_y, ang_z, vel_x, vel_y, vel_z, zonegroup, stage, teleside) VALUES ('%s', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', %i, %i, %i);";
char sql_updateSpawnLocations[] = "UPDATE ck_spawnlocations SET pos_x = '%f', pos_y = '%f', pos_z = '%f', ang_x = '%f', ang_y = '%f', ang_z = '%f', vel_x = '%f', vel_y = '%f', vel_z = '%f' WHERE mapname = '%s' AND zonegroup = %i AND stage = %i AND teleside = %i;";
char sql_selectSpawnLocations[] = "SELECT mapname, pos_x, pos_y, pos_z, ang_x, ang_y, ang_z, vel_x, vel_y, vel_z, zonegroup, stage, teleside FROM ck_spawnlocations WHERE mapname ='%s';";
char sql_deleteSpawnLocations[] = "DELETE FROM ck_spawnlocations WHERE mapname = '%s' AND zonegroup = %i AND stage = 1 AND teleside = %i;";

// ck_vipadmins (should rename this table..)
char sql_createVipAdmins[] = "CREATE TABLE IF NOT EXISTS `ck_vipadmins` (`steamid` varchar(32) NOT NULL DEFAULT '', `title` varchar(128) NOT NULL DEFAULT '0', `namecolour` tinyint(4) NOT NULL DEFAULT '0', `textcolour` tinyint(4) NOT NULL DEFAULT '0', `joinmsg` varchar(255) NOT NULL DEFAULT 'none', `pbsound` varchar(256) NOT NULL DEFAULT 'none', `topsound` varchar(256) NOT NULL DEFAULT 'none', `wrsound` varchar(256) NOT NULL DEFAULT 'none', `inuse` tinyint(4) NOT NULL DEFAULT '0', `vip` tinyint(4) NOT NULL DEFAULT '0', `admin` tinyint(4) NOT NULL DEFAULT '0', `zoner` tinyint(4) NOT NULL DEFAULT '0', `active` tinyint(4) NOT NULL DEFAULT '1', PRIMARY KEY (`steamid`), KEY `vip` (`steamid`,`vip`,`admin`,`zoner`)) DEFAULT CHARSET=utf8mb4;";
char sql_selectVipAdmins[] = "SELECT `title`, `namecolour`, `textcolour`, `inuse`, `vip`, `zoner`, `joinmsg` FROM `ck_vipadmins` WHERE `steamid` = '%s';";

// ck_wrcps
char sql_createWrcps[] = "CREATE TABLE IF NOT EXISTS `ck_wrcps` (`steamid` varchar(32) NOT NULL DEFAULT '', `name` varchar(32) NOT NULL, `mapname` varchar(32) NOT NULL DEFAULT '', `runtimepro` float NOT NULL DEFAULT -1, `velStartXY` smallint(6) NOT NULL, `velStartXYZ` smallint(6) NOT NULL, `velStartZ` smallint(6) NOT NULL, `stage` smallint(6) NOT NULL, `style` tinyint(4) NOT NULL DEFAULT 0, PRIMARY KEY (`steamid`,`mapname`,`stage`,`style`), KEY `stagerank` (`mapname`,`runtimepro`,`stage`,`style`)) DEFAULT CHARSET=utf8mb4;";

char sql_insertNewWrcp[] = "INSERT INTO ck_wrcps (steamid, name, mapname, runtimepro, stage, velStartXY, velStartXYZ, velStartZ) VALUES ('%s', '%s', '%s', '%f', %i, %i, %i, %i);";
char sql_insertNewWrcpStyle[] = "INSERT INTO ck_wrcps (steamid, name, mapname, runtimepro, stage, style, velStartXY, velStartXYZ, velStartZ) VALUES ('%s', '%s', '%s', '%f', %i, %i, %i, %i, %i);";
char sql_updateWrcp[] = "UPDATE ck_wrcps SET name = '%s', runtimepro = '%f', velStartXY = %i, velStartXYZ = %i, velStartZ = %i WHERE steamid = '%s' AND mapname = '%s' AND stage = %i AND style = 0;";
char sql_updateWrcpStyle[] = "UPDATE ck_wrcps SET name = '%s', runtimepro = '%f', velStartXY = %i, velStartXYZ = %i, velStartZ = %i WHERE steamid = '%s' AND mapname = '%s' AND stage = %i AND style = %i;";
char sql_selectFasterWrcps[] = "SELECT count(runtimepro) FROM ck_wrcps WHERE `mapname` = '%s' AND stage = %i AND style = 0 AND runtimepro < %f-(1E-3) AND runtimepro > -1.0;";
char sql_selectFasterWrcpsStyle[] = "SELECT count(runtimepro) FROM ck_wrcps WHERE mapname = '%s' AND runtimepro < %f-(1E-3) AND stage = %i AND style = %i AND runtimepro > -1.0;";

char sql_selectMapWrcp[] = "SELECT name, MIN(runtimepro), stage, style, velStartXY, velStartXYZ, velStartZ FROM ck_wrcps WHERE mapname = '%s' GROUP BY stage, style;";
char sql_selectStageTimes[] = "SELECT runtimepro, stage, style, velStartXY, velStartXYZ, velStartZ FROM ck_wrcps WHERE steamid = '%s' AND mapname = '%s' AND runtimepro > '0.0';";
char sql_selectPersonalRecords[] = "SELECT runtimepro, style, velStartXY, velStartXYZ, velStartZ, velEndXY, velEndXYZ, velEndZ FROM ck_playertimes WHERE steamid = '%s' AND mapname = '%s' AND runtimepro > 0.0;";

// ck_zones
char sql_createZones[] = "CREATE TABLE IF NOT EXISTS `ck_zones` (`mapname` varchar(54) NOT NULL, `zoneid` smallint(6) NOT NULL DEFAULT '-1', `zonetype` tinyint(4) NOT NULL DEFAULT '-1', `zonetypeid` smallint(6) NOT NULL DEFAULT '-1', `pointa_x` float NOT NULL DEFAULT '-1', `pointa_y` float NOT NULL DEFAULT '-1', `pointa_z` float NOT NULL DEFAULT '-1', `pointb_x` float NOT NULL DEFAULT '-1', `pointb_y` float NOT NULL DEFAULT '-1', `pointb_z` float NOT NULL DEFAULT '-1', `vis` tinyint(4) NOT NULL DEFAULT '0', `team` tinyint(4) NOT NULL DEFAULT '0', `zonegroup` tinyint(4) NOT NULL DEFAULT '0', `zonename` varchar(128) NOT NULL, `hookname` varchar(128) NOT NULL DEFAULT 'None', `targetname` varchar(128) NOT NULL DEFAULT 'player', `onejumplimit` tinyint(4) NOT NULL DEFAULT '0', `prespeed` smallint(6) NOT NULL DEFAULT '350', PRIMARY KEY (`mapname`,`zoneid`)) DEFAULT CHARSET=utf8mb4;";
char sql_insertZones[] = "INSERT INTO ck_zones (mapname, zoneid, zonetype, zonetypeid, pointa_x, pointa_y, pointa_z, pointb_x, pointb_y, pointb_z, vis, team, zonegroup, zonename, hookname, targetname, onejumplimit, prespeed) VALUES ('%s', '%i', '%i', '%i', '%f', '%f', '%f', '%f', '%f', '%f', '%i', '%i', '%i','%s','%s','%s',%i,%f)";
char sql_updateZone[] = "UPDATE ck_zones SET zonetype = '%i', zonetypeid = '%i', pointa_x = '%f', pointa_y ='%f', pointa_z = '%f', pointb_x = '%f', pointb_y = '%f', pointb_z = '%f', vis = '%i', team = '%i', onejumplimit = '%i', prespeed = '%f', hookname = '%s', targetname = '%s', zonegroup = '%i' WHERE zoneid = '%i' AND mapname = '%s'";
char sql_selectzoneTypeIds[] = "SELECT zonetypeid FROM ck_zones WHERE mapname='%s' AND zonetype='%i' AND zonegroup = '%i';";
char sql_selectMapZones[] = "SELECT zoneid, zonetype, zonetypeid, pointa_x, pointa_y, pointa_z, pointb_x, pointb_y, pointb_z, vis, team, zonegroup, zonename, hookname, targetname, onejumplimit, prespeed FROM ck_zones WHERE mapname = '%s' ORDER BY zonetypeid ASC";
char sql_selectTotalBonusCount[] = "SELECT mapname, zoneid, zonetype, zonetypeid, pointa_x, pointa_y, pointa_z, pointb_x, pointb_y, pointb_z, vis, team, zonegroup, zonename FROM ck_zones WHERE zonetype = 3 GROUP BY mapname, zonegroup;";
char sql_selectZoneIds[] = "SELECT mapname, zoneid, zonetype, zonetypeid, pointa_x, pointa_y, pointa_z, pointb_x, pointb_y, pointb_z, vis, team, zonegroup, zonename, hookname, targetname, onejumplimit, prespeed FROM ck_zones WHERE mapname = '%s' ORDER BY zoneid ASC";
char sql_selectBonusesInMap[] = "SELECT mapname, zonegroup, zonename FROM `ck_zones` WHERE mapname LIKE '%c%s%c' AND zonegroup > 0 GROUP BY zonegroup;";
char sql_deleteMapZones[] = "DELETE FROM ck_zones WHERE mapname = '%s'";
char sql_deleteZone[] = "DELETE FROM ck_zones WHERE mapname = '%s' AND zoneid = '%i'";
char sql_deleteZonesInGroup[] = "DELETE FROM ck_zones WHERE mapname = '%s' AND zonegroup = '%i'";
char sql_setZoneNames[] = "UPDATE ck_zones SET zonename = '%s' WHERE mapname = '%s' AND zonegroup = '%i';";

char sql_MainEditQuery[] = "SELECT steamid, name, %s FROM %s where mapname='%s' and style='%i' %sORDER BY %s ASC LIMIT 50";
char sql_MainDeleteQeury[] = "DELETE From %s where mapname='%s' and style='%i' and steamid='%s' %s";

// ck_newmaps
char sql_createNewestMaps[] = "CREATE TABLE IF NOT EXISTS ck_newmaps (mapname VARCHAR(32) NOT NULL, date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY(mapname)) DEFAULT CHARSET=utf8mb4;";
char sql_insertNewestMaps[] = "INSERT INTO ck_newmaps (mapname) VALUES('%s');";
char sql_selectNewestMaps[] = "SELECT mapname, date FROM ck_newmaps ORDER BY date DESC LIMIT 50";
