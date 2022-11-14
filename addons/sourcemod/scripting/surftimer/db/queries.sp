/////////////////////////
// PREPARED STATEMENTS //
////////////////////////

// ck_announcements
char sql_createAnnouncements[] = "CREATE TABLE IF NOT EXISTS `ck_announcements` (`id` int(11) NOT NULL AUTO_INCREMENT, `server` varchar(256) NOT NULL DEFAULT 'Beginner', `name` varchar(64) NOT NULL, `mapname` varchar(128) NOT NULL, `mode` int(11) NOT NULL DEFAULT '0', `time` varchar(32) NOT NULL, `group` int(12) NOT NULL DEFAULT '0', PRIMARY KEY (`id`))DEFAULT CHARSET=utf8mb4;";

// ck_bonus
char sql_createBonus[] = "CREATE TABLE IF NOT EXISTS ck_bonus (steamid VARCHAR(32), name VARCHAR(64), mapname VARCHAR(32), runtime decimal(12,6) NOT NULL DEFAULT '-1.000000', velStartXY SMALLINT(6) NOT NULL DEFAULT 0, velStartXYZ SMALLINT(6) NOT NULL DEFAULT 0, velStartZ SMALLINT(6) NOT NULL DEFAULT 0, zonegroup INT(12) NOT NULL DEFAULT 1, style INT(11) NOT NULL DEFAULT 0, PRIMARY KEY(steamid, mapname, zonegroup, style)) DEFAULT CHARSET=utf8mb4;";
char sql_createBonusIndex[] = "CREATE INDEX bonusrank ON ck_bonus (mapname,runtime,zonegroup,style);";
char sql_insertBonus[] = "INSERT INTO ck_bonus (steamid, name, mapname, runtime, zonegroup, velStartXY, velStartXYZ, velStartZ) VALUES ('%s', '%s', '%s', '%f', '%i', '%i', '%i', '%i')";
char sql_updateBonus[] = "UPDATE ck_bonus SET runtime = '%f', name = '%s', velStartXY = %i, velStartXYZ = %i, velStartZ = %i WHERE steamid = '%s' AND mapname = '%s' AND zonegroup = %i AND style = 0";
char sql_selectBonusCount[] = "SELECT zonegroup, style, count(1) FROM ck_bonus WHERE mapname = '%s' GROUP BY zonegroup, style;";
char sql_selectPersonalBonusRecords[] = "SELECT runtime, zonegroup, style FROM ck_bonus WHERE steamid = '%s' AND mapname = '%s' AND runtime > '0.0'";
char sql_selectPlayerRankBonus[] = "SELECT name FROM ck_bonus WHERE runtime <= (SELECT runtime FROM ck_bonus WHERE steamid = '%s' AND mapname= '%s' AND runtime > 0.0 AND zonegroup = %i AND style = 0) AND mapname = '%s' AND zonegroup = %i AND style = 0;";
char sql_selectFastestBonus[] = "SELECT t1.name, t1.runtime, t1.zonegroup, t1.style, t1.velStartXY, t1.velStartXYZ, t1.velstartZ from ck_bonus t1 where t1.mapname = '%s' and t1.runtime = (select min(t2.runtime) from ck_bonus t2 where t2.mapname = t1.mapname and t2.zonegroup = t1.zonegroup and t2.style = t1.style);";
char sql_deleteBonus[] = "DELETE FROM ck_bonus WHERE mapname = '%s'";
char sql_selectAllBonusTimesinMap[] = "SELECT zonegroup, runtime from ck_bonus WHERE mapname = '%s';";
char sql_selectTopBonusSurfers[] = "SELECT db2.steamid, db1.name, db2.runtime as overall, db1.steamid, db2.mapname FROM ck_bonus as db2 INNER JOIN ck_playerrank as db1 on db2.steamid = db1.steamid WHERE db2.mapname = '%s' AND db2.style = %i AND db1.style = %i AND db2.runtime > -1.0 AND zonegroup = %i ORDER BY overall ASC LIMIT 100;";

// ck_checkpoints
char sql_createCheckpoints[] = "CREATE TABLE IF NOT EXISTS ck_checkpoints (steamid VARCHAR(32), mapname VARCHAR(32), cp INT(11) NOT NULL, time decimal(12,6) NOT NULL DEFAULT '-1.000000', zonegroup INT(12) NOT NULL DEFAULT 0, PRIMARY KEY(steamid, mapname, cp, zonegroup)) DEFAULT CHARSET=utf8mb4;";
//char sql_updateCheckpoints[] = "UPDATE ck_checkpoints SET time='%f', stage_time='%f', stage_attempts='%i' WHERE steamid='%s' AND mapname='%s' AND cp ='%i' AND zonegroup='%i';";
char sql_InsertOrUpdateCheckpoints[] = "INSERT INTO ck_checkpoints (steamid, mapname, cp, time, stage_time, stage_attempts, zonegroup) VALUES ('%s', '%s', '%i', '%f', '%f', '%i', '%i') ON DUPLICATE KEY UPDATE time='%f', stage_time='%f', stage_attempts='%i';";
char sql_selectCheckpoints[] = "SELECT zonegroup, cp, time FROM ck_checkpoints WHERE mapname='%s' AND steamid = '%s';";
char sql_selectCheckpointsinZoneGroup[] = "SELECT cp, time FROM ck_checkpoints WHERE mapname='%s' AND steamid = '%s' AND zonegroup = %i;";
char sql_selectRecordCheckpoints[] = "SELECT zonegroup, cp, `time` FROM ck_checkpoints WHERE steamid = '%s' AND mapname='%s' UNION SELECT a.zonegroup, b.cp, b.time FROM ck_bonus a LEFT JOIN ck_checkpoints b ON a.steamid = b.steamid AND a.zonegroup = b.zonegroup WHERE a.mapname = '%s' GROUP BY a.zonegroup;";
char sql_deleteCheckpoints[] = "DELETE FROM ck_checkpoints WHERE mapname = '%s'";
char sql_selectStageTimes[] = "SELECT cp, stage_time FROM ck_checkpoints WHERE mapname = '%s' AND steamid = '%s';";
char sql_selectStageAttempts[] = "SELECT cp, stage_attempts FROM ck_checkpoints WHERE mapname = '%s' AND steamid = '%s';";

// ck_latestrecords
char sql_createLatestRecords[] = "CREATE TABLE IF NOT EXISTS ck_latestrecords (steamid VARCHAR(32), name VARCHAR(64), runtime decimal(12,6) NOT NULL DEFAULT '-1.000000', map VARCHAR(32), date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY(steamid,map,date)) DEFAULT CHARSET=utf8mb4;";
char sql_insertLatestRecords[] = "INSERT INTO ck_latestrecords (steamid, name, runtime, map) VALUES('%s','%s','%f','%s');";
char sql_selectLatestRecords[] = "SELECT name, runtime, map, date FROM ck_latestrecords ORDER BY date DESC LIMIT 50";

// ck_maptier
char sql_createMapTier[] = "CREATE TABLE IF NOT EXISTS ck_maptier (mapname VARCHAR(54) NOT NULL, tier INT(12), maxvelocity FLOAT NOT NULL DEFAULT '3500.0', announcerecord INT(11) NOT NULL DEFAULT '0', gravityfix INT(11) NOT NULL DEFAULT '1', ranked INT(11) NOT NULL DEFAULT '1', PRIMARY KEY(mapname)) DEFAULT CHARSET=utf8mb4;";
char sql_selectMapTier[] = "SELECT tier, ranked, mapper FROM ck_maptier WHERE mapname = '%s'";
char sql_insertmaptier[] = "INSERT INTO ck_maptier (mapname, tier) VALUES ('%s', '%i');";
char sql_updatemaptier[] = "UPDATE ck_maptier SET tier = %i WHERE mapname ='%s'";
char sql_updateMapperName[] = "UPDATE ck_maptier SET mapper = '%s' WHERE mapname = '%s'";

// ck_playeroptions2
char sql_createPlayerOptions[] = "CREATE TABLE IF NOT EXISTS `ck_playeroptions2` (`steamid` varchar(32) NOT NULL DEFAULT '', `timer` int(11) NOT NULL DEFAULT '1', `hide` int(11) NOT NULL DEFAULT '0', `sounds` int(11) NOT NULL DEFAULT '1', `chat` int(11) NOT NULL DEFAULT '0', `viewmodel` int(11) NOT NULL DEFAULT '1', `autobhop` int(11) NOT NULL DEFAULT '1', `checkpoints` int(11) NOT NULL DEFAULT '1', `gradient` int(11) NOT NULL DEFAULT '3', `speedmode` int(11) NOT NULL DEFAULT '0', `centrespeed` int(11) NOT NULL DEFAULT '0', `centrehud` int(11) NOT NULL DEFAULT '1', teleside int(11) NOT NULL DEFAULT '0', `module1c` int(11) NOT NULL DEFAULT '1', `module2c` int(11) NOT NULL DEFAULT '2', `module3c` int(11) NOT NULL DEFAULT '3', `module4c` int(11) NOT NULL DEFAULT '4', `module5c` int(11) NOT NULL DEFAULT '5', `module6c` int(11) NOT NULL DEFAULT '6', `sidehud` int(11) NOT NULL DEFAULT '1', `module1s` int(11) NOT NULL DEFAULT '5', `module2s` int(11) NOT NULL DEFAULT '0', `module3s` int(11) NOT NULL DEFAULT '0', `module4s` int(11) NOT NULL DEFAULT '0', `module5s` int(11) NOT NULL DEFAULT '0', prestrafe int(11) NOT NULL DEFAULT '0', cpmessages int(11) NOT NULL DEFAULT '1', wrcpmessages int(11) NOT NULL DEFAULT '1', hints int(11) NOT NULL DEFAULT '1', csd_update_rate int(11) NOT NULL DEFAULT '1' , csd_pos_x float(11) NOT NULL DEFAULT '0.5' , csd_pos_y float(11) NOT NULL DEFAULT '0.3' , csd_r int(11) NOT NULL DEFAULT '255', csd_g int(11) NOT NULL DEFAULT '255', csd_b int(11) NOT NULL DEFAULT '255', PRIMARY KEY (`steamid`)) DEFAULT CHARSET=utf8mb4;";
char sql_insertPlayerOptions[] = "INSERT INTO ck_playeroptions2 (steamid) VALUES ('%s');";
char sql_selectPlayerOptions[] = "SELECT timer, hide, sounds, chat, viewmodel, autobhop, checkpoints, gradient, speedmode, centrespeed, centrehud, teleside, module1c, module2c, module3c, module4c, module5c, module6c, sidehud, module1s, module2s, module3s, module4s, module5s, prestrafe, cpmessages, wrcpmessages, hints, csd_update_rate, csd_pos_x, csd_pos_y, csd_r, csd_g, csd_b, prespeedmode FROM ck_playeroptions2 where steamid = '%s';";
char sql_updatePlayerOptions[] = "UPDATE ck_playeroptions2 SET timer = %i, hide = %i, sounds = %i, chat = %i, viewmodel = %i, autobhop = %i, checkpoints = %i, gradient = %i, speedmode = %i, centrespeed = %i, centrehud = %i, teleside = %i, module1c = %i, module2c = %i, module3c = %i, module4c = %i, module5c = %i, module6c = %i, sidehud = %i, module1s = %i, module2s = %i, module3s = %i, module4s = %i, module5s = %i, prestrafe = %i, cpmessages = %i, wrcpmessages = %i, hints = %i, csd_update_rate = %i, csd_pos_x = %f, csd_pos_y = %f, csd_r= %i, csd_g = %i, csd_b = %i, prespeedmode = %i where steamid = '%s'";

// ck_playerrank
char sql_createPlayerRank[] = "CREATE TABLE IF NOT EXISTS `ck_playerrank` (`steamid` varchar(32) NOT NULL DEFAULT '', `steamid64` varchar(64) DEFAULT NULL, `name` varchar(64) DEFAULT NULL, `country` varchar(32) DEFAULT NULL, `countryCode` varchar(3) DEFAULT NULL, `continentCode` varchar(3) DEFAULT NULL, `points` int(12) DEFAULT '0', `wrpoints` int(12) NOT NULL DEFAULT '0', `wrbpoints` int(12) NOT NULL DEFAULT '0', `wrcppoints` int(11) NOT NULL DEFAULT '0', `top10points` int(12) NOT NULL DEFAULT '0', `groupspoints` int(12) NOT NULL DEFAULT '0', `mappoints` int(11) NOT NULL DEFAULT '0', `bonuspoints` int(12) NOT NULL DEFAULT '0', `finishedmaps` int(12) DEFAULT '0', `finishedmapspro` int(12) DEFAULT '0', `finishedbonuses` int(12) NOT NULL DEFAULT '0', `finishedstages` int(12) NOT NULL DEFAULT '0', `wrs` int(12) NOT NULL DEFAULT '0', `wrbs` int(12) NOT NULL DEFAULT '0', `wrcps` int(12) NOT NULL DEFAULT '0', `top10s` int(12) NOT NULL DEFAULT '0', `groups` int(12) NOT NULL DEFAULT '0', `lastseen` int(64) DEFAULT NULL, `joined` int(64) NOT NULL, `timealive` int(64) NOT NULL DEFAULT '0', `timespec` int(64) NOT NULL DEFAULT '0', `connections` int(64) NOT NULL DEFAULT '1', `readchangelog` int(11) NOT NULL DEFAULT '0', `style` int(11) NOT NULL DEFAULT '0', PRIMARY KEY (`steamid`, `style`)) DEFAULT CHARSET=utf8mb4;";
char sql_insertPlayerRank[] = "INSERT INTO ck_playerrank (steamid, steamid64, name, country, countryCode, continentCode, joined, style) VALUES('%s', '%s', '%s', '%s', '%s', '%s', %i, %i)";
char sql_updatePlayerRankPoints[] = "UPDATE ck_playerrank SET name ='%s', points ='%i', wrpoints = %i, wrbpoints = %i, wrcppoints = %i, top10points = %i, groupspoints = %i, mappoints = %i, bonuspoints = %i, finishedmapspro='%i', finishedbonuses = %i, finishedstages = %i, wrs = %i, wrbs = %i, wrcps = %i, top10s = %i, `groups` = %i where steamid='%s' AND style = %i;";
char sql_updatePlayerRankPoints2[] = "UPDATE ck_playerrank SET name ='%s', points ='%i', wrpoints = %i, wrbpoints = %i, wrcppoints = %i, top10points = %i, groupspoints = %i, mappoints = %i, bonuspoints = %i, finishedmapspro='%i', finishedbonuses = %i, finishedstages = %i, wrs = %i, wrbs = %i, wrcps = %i, top10s = %i, `groups` = %i, country = '%s', countryCode = '%s', continentCode = '%s' where steamid='%s' AND style = %i;";
char sql_updatePlayerRank[] = "UPDATE ck_playerrank SET finishedmaps ='%i', finishedmapspro='%i' where steamid='%s' AND style = '%i';";
char sql_selectPlayerName[] = "SELECT name FROM ck_playerrank where steamid = '%s'";
char sql_UpdateLastSeenMySQL[] = "UPDATE ck_playerrank SET lastseen = UNIX_TIMESTAMP() where steamid = '%s';";
char sql_UpdateLastSeenSQLite[] = "UPDATE ck_playerrank SET lastseen = date('now') where steamid = '%s';";
char sql_selectTopPlayers[] = "SELECT name, points, finishedmapspro, steamid FROM ck_playerrank WHERE style = %i ORDER BY points DESC LIMIT 100";
char sql_selectRankedPlayer[] = "SELECT steamid, name, points, finishedmapspro, country, lastseen, timealive, timespec, connections, readchangelog, style, countryCode, continentCode from ck_playerrank where steamid='%s';";
char sql_selectRankedPlayersRank[] = "SELECT name FROM ck_playerrank WHERE style = %i AND points >= (SELECT points FROM ck_playerrank WHERE steamid = '%s' AND style = %i) ORDER BY points;";
char sql_selectRankedPlayers[] = "SELECT steamid, name from ck_playerrank where points > 0 AND style = 0 ORDER BY points DESC LIMIT 0, 1067;";
char sql_CountRankedPlayers[] = "SELECT COUNT(steamid) FROM ck_playerrank WHERE style = %i;";
char sql_CountRankedPlayers2[] = "SELECT COUNT(steamid) FROM ck_playerrank where points > 0 AND style = %i;";
char sql_selectPlayerProfile[] = "SELECT steamid, steamid64, name, country, points, wrpoints, wrbpoints, wrcppoints, top10points, groupspoints, mappoints, bonuspoints, finishedmapspro, finishedbonuses, finishedstages, wrs, wrbs, wrcps, top10s, `groups`, lastseen, countryCode, continentCode FROM ck_playerrank WHERE steamid = '%s' AND style = '%i';";

// ck_playertemp
char sql_createPlayertmp[] = "CREATE TABLE IF NOT EXISTS ck_playertemp (steamid VARCHAR(32), mapname VARCHAR(32), cords1 FLOAT NOT NULL DEFAULT '-1.0', cords2 FLOAT NOT NULL DEFAULT '-1.0', cords3 FLOAT NOT NULL DEFAULT '-1.0', angle1 FLOAT NOT NULL DEFAULT '-1.0',angle2 FLOAT NOT NULL DEFAULT '-1.0',angle3 FLOAT NOT NULL DEFAULT '-1.0', EncTickrate INT(12) DEFAULT '-1.0', runtimeTmp decimal(12,6) NOT NULL DEFAULT '-1.000000', Stage INT, zonegroup INT NOT NULL DEFAULT 0, PRIMARY KEY(steamid,mapname)) DEFAULT CHARSET=utf8mb4;";
char sql_insertPlayerTmp[] = "INSERT INTO ck_playertemp (cords1, cords2, cords3, angle1,angle2,angle3,runtimeTmp,steamid,mapname,EncTickrate,Stage,zonegroup) VALUES ('%f','%f','%f','%f','%f','%f','%f','%s', '%s', '%i', %i, %i);";
char sql_updatePlayerTmp[] = "UPDATE ck_playertemp SET cords1 = '%f', cords2 = '%f', cords3 = '%f', angle1 = '%f', angle2 = '%f', angle3 = '%f', runtimeTmp = '%f', mapname ='%s', EncTickrate='%i', Stage = %i, zonegroup = %i WHERE steamid = '%s';";
char sql_deletePlayerTmp[] = "DELETE FROM ck_playertemp where steamid = '%s';";
char sql_selectPlayerTmp[] = "SELECT cords1,cords2,cords3, angle1, angle2, angle3,runtimeTmp, EncTickrate, Stage, zonegroup FROM ck_playertemp WHERE steamid = '%s' AND mapname = '%s';";

// ck_playertimes
char sql_createPlayertimes[] = "CREATE TABLE IF NOT EXISTS ck_playertimes (steamid VARCHAR(32), mapname VARCHAR(32), name VARCHAR(64), runtimepro decimal(12,6) NOT NULL DEFAULT '-1.000000', velStartXY SMALLINT(6) NOT NULL DEFAULT 0, velStartXYZ SMALLINT(6) NOT NULL DEFAULT 0, velStartZ SMALLINT(6) NOT NULL DEFAULT 0, style INT(11) NOT NULL DEFAULT '0', PRIMARY KEY(steamid, mapname, style)) DEFAULT CHARSET=utf8mb4;";
char sql_createPlayertimesIndex[] = "CREATE INDEX maprank ON ck_playertimes (mapname, runtimepro, style);";
char sql_insertPlayer[] = "INSERT INTO ck_playertimes (steamid, mapname, name) VALUES('%s', '%s', '%s');";
char sql_insertPlayerTime[] = "INSERT INTO ck_playertimes (steamid, mapname, name, runtimepro, style, velStartXY, velStartXYZ, velStartZ) VALUES('%s', '%s', '%s', '%f', %i, %i, %i, %i);";
char sql_updateRecordPro[] = "UPDATE ck_playertimes SET name = '%s', runtimepro = '%f', velStartXY = '%i', velStartXYZ = '%i', velStartZ = '%i' WHERE steamid = '%s' AND mapname = '%s' AND style = %i;";
char sql_selectPlayer[] = "SELECT steamid FROM ck_playertimes WHERE steamid = '%s' AND mapname = '%s';";
char sql_selectMapRecord[] = "SELECT t1.runtimepro, t1.name, t1.steamid, t1.style, t1.velStartXY, t1.velStartXYZ, t1.velstartZ FROM ck_playertimes t1 JOIN ( SELECT MIN(runtimepro) AS min_runtime, style, mapname FROM ck_playertimes GROUP BY mapname, style ) AS t2 ON t1.runtimepro = t2.min_runtime AND t1.mapname = t2.mapname AND t1.style = t2.style WHERE t1.mapname = '%s'";
char sql_selectPersonalAllRecords[] = "SELECT db1.name, db2.steamid, db2.mapname, db2.runtimepro as overall, db1.steamid, db3.tier FROM ck_playertimes as db2 INNER JOIN ck_playerrank as db1 on db2.steamid = db1.steamid INNER JOIN ck_maptier AS db3 ON db2.mapname = db3.mapname WHERE db2.steamid = '%s' AND db2.style = %i AND db1.style = %i AND db2.runtimepro > -1.0 ORDER BY mapname ASC;";
char sql_selectTopSurfers[] = "SELECT db2.steamid, db1.name, db2.runtimepro as overall, db1.steamid, db2.mapname FROM ck_playertimes as db2 INNER JOIN ck_playerrank as db1 on db2.steamid = db1.steamid WHERE db2.mapname = '%s' AND db1.style = %i AND db2.style = %i AND db2.runtimepro > -1.0 ORDER BY overall ASC LIMIT 50;";
char sql_selectTopSurfers2[] = "SELECT db2.steamid, db1.name, db2.runtimepro as overall, db1.steamid, db2.mapname FROM ck_playertimes as db2 INNER JOIN ck_playerrank as db1 on db2.steamid = db1.steamid WHERE db2.mapname = '%s' AND db1.style = 0 AND db2.style = 0 AND db2.runtimepro > -1.0 ORDER BY overall ASC LIMIT 100;";
char sql_selectPlayerProCount[] = "SELECT style, count(1) FROM ck_playertimes WHERE mapname = '%s' GROUP BY style;";
char sql_selectPlayerRankProTime[] = "SELECT COUNT(*) FROM ck_playertimes WHERE runtimepro <= (SELECT runtimepro FROM ck_playertimes WHERE steamid = '%s' AND mapname = '%s' AND style = 0 AND runtimepro > -1.0) AND mapname = '%s' AND style = 0 AND runtimepro > -1.0;";
char sql_selectAllMapTimesinMap[] = "SELECT runtimepro from ck_playertimes WHERE mapname = '%s';";

char sql_selectMapRankUnknownWithMap[] = "SELECT `steamid`, `name`, `mapname`, `runtimepro` FROM `ck_playertimes` WHERE `mapname` = '%s' AND style = 0 ORDER BY `runtimepro` ASC LIMIT %i, 1;";
// ck_spawnlocations
char sql_createSpawnLocations[] = "CREATE TABLE IF NOT EXISTS ck_spawnlocations (mapname VARCHAR(54) NOT NULL, pos_x FLOAT NOT NULL, pos_y FLOAT NOT NULL, pos_z FLOAT NOT NULL, ang_x FLOAT NOT NULL, ang_y FLOAT NOT NULL, ang_z FLOAT NOT NULL,  `vel_x` float NOT NULL DEFAULT '0', `vel_y` float NOT NULL DEFAULT '0', `vel_z` float NOT NULL DEFAULT '0', zonegroup INT(12) DEFAULT 0, stage INT(12) DEFAULT 0, teleside INT(11) DEFAULT 0, PRIMARY KEY(mapname, zonegroup, stage, teleside)) DEFAULT CHARSET=utf8mb4;";
char sql_insertSpawnLocations[] = "INSERT INTO ck_spawnlocations (mapname, pos_x, pos_y, pos_z, ang_x, ang_y, ang_z, vel_x, vel_y, vel_z, zonegroup, teleside) VALUES ('%s', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', %i, %i);";
char sql_updateSpawnLocations[] = "UPDATE ck_spawnlocations SET pos_x = '%f', pos_y = '%f', pos_z = '%f', ang_x = '%f', ang_y = '%f', ang_z = '%f', vel_x = '%f', vel_y = '%f', vel_z = '%f' WHERE mapname = '%s' AND zonegroup = %i AND teleside = %i;";
char sql_selectSpawnLocations[] = "SELECT mapname, pos_x, pos_y, pos_z, ang_x, ang_y, ang_z, vel_x, vel_y, vel_z, zonegroup, stage, teleside FROM ck_spawnlocations WHERE mapname ='%s';";
char sql_deleteSpawnLocations[] = "DELETE FROM ck_spawnlocations WHERE mapname = '%s' AND zonegroup = %i AND stage = 1 AND teleside = %i;";

// ck_vipadmins (should rename this table..)
char sql_createVipAdmins[] = "CREATE TABLE `ck_vipadmins` (`steamid` varchar(32) NOT NULL DEFAULT '', `title` varchar(128) DEFAULT '0', `namecolour` int(11) DEFAULT '0', `textcolour` int(11) NOT NULL DEFAULT '0', `joinmsg` varchar(255) DEFAULT 'none', `pbsound` varchar(256) NOT NULL DEFAULT 'none', `topsound` varchar(256) NOT NULL DEFAULT 'none', `wrsound` varchar(256) NOT NULL DEFAULT 'none', `inuse` int(11) DEFAULT '0', `vip` int(11) DEFAULT '0', `admin` int(11) NOT NULL DEFAULT '0', `zoner` int(11) NOT NULL DEFAULT '0', `active` int(11) NOT NULL DEFAULT '1', PRIMARY KEY (`steamid`), KEY `vip` (`steamid`,`vip`,`admin`,`zoner`)) DEFAULT CHARSET=utf8mb4;";

// ck_wrcps
char sql_createWrcps[] = "CREATE TABLE IF NOT EXISTS `ck_wrcps` (`steamid` varchar(32) NOT NULL DEFAULT '', `name` varchar(64) DEFAULT NULL, `mapname` varchar(32) NOT NULL DEFAULT '', `runtimepro` decimal(12,6) NOT NULL DEFAULT '-1.000000', `velStartXY` smallint(6) NOT NULL DEFAULT 0, `velStartXYZ` smallint(6) NOT NULL DEFAULT 0, `velStartZ` smallint(6) NOT NULL DEFAULT 0, `stage` int(11) NOT NULL, `style` int(11) NOT NULL DEFAULT '0', PRIMARY KEY (`steamid`,`mapname`,`stage`,`style`), KEY `stagerank` (`mapname`,`runtimepro`,`stage`,`style`)) DEFAULT CHARSET=utf8mb4;";


// ck_zones
char sql_createZones[] = "CREATE TABLE `ck_zones` (`mapname` varchar(54) NOT NULL, `zoneid` int(12) NOT NULL DEFAULT '-1', `zonetype` int(12) DEFAULT '-1', `zonetypeid` int(12) DEFAULT '-1', `pointa_x` float DEFAULT '-1', `pointa_y` float DEFAULT '-1', `pointa_z` float DEFAULT '-1', `pointb_x` float DEFAULT '-1', `pointb_y` float DEFAULT '-1', `pointb_z` float DEFAULT '-1', `vis` int(12) DEFAULT '0', `team` int(12) DEFAULT '0', `zonegroup` int(11) NOT NULL DEFAULT '0', `zonename` varchar(128) DEFAULT NULL, `hookname` varchar(128) DEFAULT 'None', `targetname` varchar(128) DEFAULT 'player', `onejumplimit` int(12) NOT NULL DEFAULT '1', `prespeed` int(64) NOT NULL DEFAULT '%.1f', PRIMARY KEY (`mapname`,`zoneid`)) DEFAULT CHARSET=utf8mb4;";
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


//ck_prinfo 
char sql_CreatePrinfo[] = "CREATE TABLE IF NOT EXISTS ck_prinfo (steamid VARCHAR(32), name VARCHAR(64), mapname VARCHAR(32), runtime decimal(12,6) NOT NULL DEFAULT '-1.000000', zonegroup INT(12) NOT NULL DEFAULT '0', PRtimeinzone decimal(12,6) NOT NULL DEFAULT '-1.000000', PRcomplete FLOAT NOT NULL DEFAULT '0.0', PRattempts FLOAT NOT NULL DEFAULT '0.0', PRstcomplete FLOAT NOT NULL DEFAULT '0.0', PRIMARY KEY(steamid, mapname, zonegroup)) DEFAULT CHARSET=utf8mb4;";

char sql_selectPR[] = "SELECT steamid, name, mapname, zonegroup, PRtimeinzone, PRcomplete, PRattempts, PRstcomplete FROM ck_prinfo WHERE steamid = '%s' AND mapname = '%s' AND zonegroup= '%i';";
char sql_insertPR[] = "INSERT INTO ck_prinfo (steamid, name, mapname, runtime, zonegroup, PRtimeinzone, PRcomplete, PRattempts, PRstcomplete) VALUES('%s', '%s', '%s', '%f', '%i', '%f', '%f', '%f', '%f');";

char sql_selectBonusPR[] = "SELECT steamid, name, mapname, zonegroup, PRtimeinzone, PRcomplete, PRattempts, PRstcomplete FROM ck_prinfo WHERE steamid = '%s' AND mapname = '%s' AND zonegroup = '%i';";

char sql_updatePrinfo[] = "UPDATE ck_prinfo SET PRtimeinzone = '%f', PRcomplete = '%f', PRattempts = '%f', PRstcomplete = '%f' WHERE steamid = '%s' AND mapname = '%s' AND zonegroup = '%i';";
char sql_updatePrinfo_withruntime[] = "UPDATE ck_prinfo SET PRtimeinzone = '%f', PRcomplete = '%f', PRattempts = '%f', PRstcomplete = '%f', runtime = '%f' WHERE steamid = '%s' AND mapname = '%s' AND zonegroup = '%i';";

char sql_clearPRruntime[] = "UPDATE ck_prinfo SET runtime = '0.0' WHERE steamid = '%s' AND mapname = '%s' AND zonegroup = '%i';";

//ck_replays
char sql_createReplays[] = "CREATE TABLE IF NOT EXISTS ck_replays (mapname VARCHAR(32), cp int(12) NOT NULL DEFAULT '0', frame int(12) NOT NULL DEFAULT '0', style INT(12) NOT NULL DEFAULT '0', PRIMARY KEY(mapname, cp, style)) DEFAULT CHARSET=utf8mb4;";
char sql_selectReplayCPTicksAll[] = "SELECT cp, frame, style FROM ck_replays WHERE mapname = '%s' AND style = '%i' ORDER BY cp ASC;";
char sql_insertReplayCPTicks[] = "INSERT INTO ck_replays (mapname, cp, frame, style) VALUES ('%s', '%i', '%i', '%i')";
char sql_updateReplayCPTicks[] = "UPDATE ck_replays SET frame='%i' WHERE mapname='%s' AND cp ='%i' AND style='%i';";
//check tables data type
char sql_checkDataType[] = "SELECT DATA_TYPE, NUMERIC_PRECISION, NUMERIC_SCALE FROM information_schema.COLUMNS WHERE TABLE_SCHEMA='%s' AND TABLE_NAME='%s' AND COLUMN_NAME='%s' HAVING DATA_TYPE = 'decimal' AND NUMERIC_PRECISION = 12 AND NUMERIC_SCALE = 6;";
