/////////////////////////
// PREPARED STATEMENTS //
////////////////////////

//TABLE PLAYER REPORTS
char sql_createPlayerReports[] = "CREATE TABLE IF NOT EXISTS ck_reports (id int(11) NOT NULL AUTO_INCREMENT, steamid varchar(32) NOT NULL, map varchar(32) NOT NULL, ip varchar(16) NOT NULL, port INT(6) NOT NULL, report varchar(255) NOT NULL, vip int(1) NOT NULL, date timestamp NOT NULL default CURRENT_TIMESTAMP, PRIMARY KEY (id));";

//TABLE PLAYER TIME
char sql_createPlayerTotalTime[] = "CREATE TABLE IF NOT EXISTS ck_playertotaltime (name varchar(64) CHARACTER SET utf8 NOT NULL, steamid varchar(64) NOT NULL, time_played int(64) NOT NULL, UNIQUE KEY steamid (steamid));";

//TABLE CK_SPAWNLOCATIONS
char sql_createSpawnLocations[] = "CREATE TABLE IF NOT EXISTS ck_spawnlocations (mapname VARCHAR(54) NOT NULL, pos_x FLOAT NOT NULL, pos_y FLOAT NOT NULL, pos_z FLOAT NOT NULL, ang_x FLOAT NOT NULL, ang_y FLOAT NOT NULL, ang_z FLOAT NOT NULL,  `vel_x` float NOT NULL DEFAULT '0', `vel_y` float NOT NULL DEFAULT '0', `vel_z` float NOT NULL DEFAULT '0', zonegroup INT(12) DEFAULT 0, stage INT(12) DEFAULT 0, PRIMARY KEY(mapname, zonegroup, stage));";
char sql_insertSpawnLocations[] = "INSERT INTO ck_spawnlocations (mapname, pos_x, pos_y, pos_z, ang_x, ang_y, ang_z, vel_x, vel_y, vel_z, zonegroup) VALUES ('%s', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', %i);";
char sql_updateSpawnLocations[] = "UPDATE ck_spawnlocations SET pos_x = '%f', pos_y = '%f', pos_z = '%f', ang_x = '%f', ang_y = '%f', ang_z = '%f', vel_x = '%f', vel_y = '%f', vel_z = '%f' WHERE mapname = '%s' AND zonegroup = %i";
char sql_selectSpawnLocations[] = "SELECT mapname, pos_x, pos_y, pos_z, ang_x, ang_y, ang_z, vel_x, vel_y, vel_z, zonegroup, stage FROM ck_spawnlocations WHERE mapname ='%s';";
char sql_deleteSpawnLocations[] = "DELETE FROM ck_spawnlocations WHERE mapname = '%s' AND zonegroup = %i AND stage = 0";

//TABLE ZONES
char sql_createZones[] = "CREATE TABLE IF NOT EXISTS ck_zones (mapname VARCHAR(54) NOT NULL, zoneid INT(12) DEFAULT '-1', zonetype INT(12) DEFAULT '-1', zonetypeid INT(12) DEFAULT '-1', pointa_x FLOAT DEFAULT '-1.0', pointa_y FLOAT DEFAULT '-1.0', pointa_z FLOAT DEFAULT '-1.0', pointb_x FLOAT DEFAULT '-1.0', pointb_y FLOAT DEFAULT '-1.0', pointb_z FLOAT DEFAULT '-1.0', vis INT(12) DEFAULT '0', team INT(12) DEFAULT '0', zonegroup INT(12) DEFAULT 0, zonename VARCHAR(128), PRIMARY KEY(mapname, zoneid));";
char sql_insertZones[] = "INSERT INTO ck_zones (mapname, zoneid, zonetype, zonetypeid, pointa_x, pointa_y, pointa_z, pointb_x, pointb_y, pointb_z, vis, team, zonegroup, zonename) VALUES ('%s', '%i', '%i', '%i', '%f', '%f', '%f', '%f', '%f', '%f', '%i', '%i', '%i','%s')";
char sql_updateZone[] = "UPDATE ck_zones SET zonetype = '%i', zonetypeid = '%i', pointa_x = '%f', pointa_y ='%f', pointa_z = '%f', pointb_x = '%f', pointb_y = '%f', pointb_z = '%f', vis = '%i', team = '%i', onejumplimit = '%i', zonegroup = '%i' WHERE zoneid = '%i' AND mapname = '%s'";
char sql_selectzoneTypeIds[] = "SELECT zonetypeid FROM ck_zones WHERE mapname='%s' AND zonetype='%i' AND zonegroup = '%i';";
char sql_selectMapZones[] = "SELECT zoneid, zonetype, zonetypeid, pointa_x, pointa_y, pointa_z, pointb_x, pointb_y, pointb_z, vis, team, zonegroup, zonename, hookname, targetname, onejumplimit FROM ck_zones WHERE mapname = '%s' ORDER BY zonetypeid ASC";
char sql_selectTotalBonusCount[] = "SELECT mapname, zoneid, zonetype, zonetypeid, pointa_x, pointa_y, pointa_z, pointb_x, pointb_y, pointb_z, vis, team, zonegroup, zonename FROM ck_zones WHERE zonetype = 3 GROUP BY mapname, zonegroup;";
char sql_selectZoneIds[] = "SELECT mapname, zoneid, zonetype, zonetypeid, pointa_x, pointa_y, pointa_z, pointb_x, pointb_y, pointb_z, vis, team, zonegroup, zonename FROM ck_zones WHERE mapname = '%s' ORDER BY zoneid ASC";
char sql_selectBonusesInMap[] = "SELECT mapname, zonegroup, zonename FROM `ck_zones` WHERE mapname LIKE '%c%s%c' AND zonegroup > 0 GROUP BY zonegroup;";
char sql_deleteMapZones[] = "DELETE FROM ck_zones WHERE mapname = '%s'";
char sql_deleteZone[] = "DELETE FROM ck_zones WHERE mapname = '%s' AND zoneid = '%i'";
char sql_deleteZonesInGroup[] = "DELETE FROM ck_zones WHERE mapname = '%s' AND zonegroup = '%i'";
char sql_setZoneNames[] = "UPDATE ck_zones SET zonename = '%s' WHERE mapname = '%s' AND zonegroup = '%i';";

//TABLE MAPTIER
char sql_createMapTier[] = "CREATE TABLE IF NOT EXISTS ck_maptier (mapname VARCHAR(54) NOT NULL, tier INT(12), btier1 INT(12), btier2 INT(12), btier3 INT(12), btier4 INT(12), btier5 INT(12), btier6 INT(12), btier7 INT(12), btier8 INT(12), btier9 INT(12), btier10 INT(12), PRIMARY KEY(mapname));";
char sql_selectMapTier[] = "SELECT tier, btier1, btier2, btier3, btier4, btier5, btier6, btier7, btier8, btier9, btier10 FROM ck_maptier WHERE mapname = '%s'";
char sql_insertmaptier[] = "INSERT INTO ck_maptier (mapname, tier) VALUES ('%s', '%i');";
char sql_updatemaptier[] = "UPDATE ck_maptier SET tier = %i WHERE mapname ='%s'";
char sql_updateBonusTier[] = "UPDATE ck_maptier SET btier%i = %i WHERE mapname ='%s'";
char sql_insertBonusTier[] = "INSERT INTO ck_maptier (mapname, btier%i) VALUES ('%s', '%i');";

//TABLE BONUS
char sql_createBonus[] = "CREATE TABLE IF NOT EXISTS ck_bonus (steamid VARCHAR(32), name VARCHAR(32), mapname VARCHAR(32), runtime FLOAT NOT NULL DEFAULT '-1.0', zonegroup INT(12) NOT NULL DEFAULT 1, PRIMARY KEY(steamid, mapname, zonegroup));";
char sql_createBonusIndex[] = "CREATE INDEX bonusrank ON ck_bonus (mapname,runtime,zonegroup);";
char sql_insertBonus[] = "INSERT INTO ck_bonus (steamid, name, mapname, runtime, zonegroup) VALUES ('%s', '%s', '%s', '%f', '%i')";
char sql_updateBonus[] = "UPDATE ck_bonus SET runtime = '%f', name = '%s' WHERE steamid = '%s' AND mapname = '%s' AND zonegroup = %i";
char sql_selectBonusCount[] = "SELECT zonegroup, style, count(1) FROM ck_bonus WHERE mapname = '%s' GROUP BY zonegroup, style;";
char sql_selectPersonalBonusRecords[] = "SELECT runtime, zonegroup, style FROM ck_bonus WHERE steamid = '%s' AND mapname = '%s' AND runtime > '0.0'";
char sql_selectPlayerRankBonus[] = "SELECT name FROM ck_bonus WHERE runtime <= (SELECT runtime FROM ck_bonus WHERE steamid = '%s' AND mapname= '%s' AND runtime > 0.0 AND zonegroup = %i AND style = 0) AND mapname = '%s' AND zonegroup = %i AND style = 0;";
char sql_selectFastestBonus[] = "SELECT name, MIN(runtime), zonegroup, style FROM ck_bonus WHERE mapname = '%s' GROUP BY zonegroup, style;";
char sql_deleteBonus[] = "DELETE FROM ck_bonus WHERE mapname = '%s'";
char sql_selectAllBonusTimesinMap[] = "SELECT zonegroup, runtime from ck_bonus WHERE mapname = '%s';";
char sql_selectTopBonusSurfers[] = "SELECT db2.steamid, db1.name, db2.runtime as overall, db1.steamid, db2.mapname FROM ck_bonus as db2 INNER JOIN ck_playerrank as db1 on db2.steamid = db1.steamid WHERE db2.mapname LIKE '%c%s%c' AND style = 0 AND db2.runtime > -1.0 AND zonegroup = %i ORDER BY overall ASC LIMIT 100;";

//TABLE CHECKPOINTS
char sql_createCheckpoints[] = "CREATE TABLE IF NOT EXISTS ck_checkpoints (steamid VARCHAR(32), mapname VARCHAR(32), cp1 FLOAT DEFAULT '0.0', cp2 FLOAT DEFAULT '0.0', cp3 FLOAT DEFAULT '0.0', cp4 FLOAT DEFAULT '0.0', cp5 FLOAT DEFAULT '0.0', cp6 FLOAT DEFAULT '0.0', cp7 FLOAT DEFAULT '0.0', cp8 FLOAT DEFAULT '0.0', cp9 FLOAT DEFAULT '0.0', cp10 FLOAT DEFAULT '0.0', cp11 FLOAT DEFAULT '0.0', cp12 FLOAT DEFAULT '0.0', cp13 FLOAT DEFAULT '0.0', cp14 FLOAT DEFAULT '0.0', cp15 FLOAT DEFAULT '0.0', cp16 FLOAT DEFAULT '0.0', cp17  FLOAT DEFAULT '0.0', cp18 FLOAT DEFAULT '0.0', cp19 FLOAT DEFAULT '0.0', cp20  FLOAT DEFAULT '0.0', cp21 FLOAT DEFAULT '0.0', cp22 FLOAT DEFAULT '0.0', cp23 FLOAT DEFAULT '0.0', cp24 FLOAT DEFAULT '0.0', cp25 FLOAT DEFAULT '0.0', cp26 FLOAT DEFAULT '0.0', cp27 FLOAT DEFAULT '0.0', cp28 FLOAT DEFAULT '0.0', cp29 FLOAT DEFAULT '0.0', cp30 FLOAT DEFAULT '0.0', cp31 FLOAT DEFAULT '0.0', cp32  FLOAT DEFAULT '0.0', cp33 FLOAT DEFAULT '0.0', cp34 FLOAT DEFAULT '0.0', cp35 FLOAT DEFAULT '0.0', zonegroup INT(12) NOT NULL DEFAULT 0, PRIMARY KEY(steamid, mapname, zonegroup));";
char sql_updateCheckpoints[] = "UPDATE ck_checkpoints SET cp1='%f', cp2='%f', cp3='%f', cp4='%f', cp5='%f', cp6='%f', cp7='%f', cp8='%f', cp9='%f', cp10='%f', cp11='%f', cp12='%f', cp13='%f', cp14='%f', cp15='%f', cp16='%f', cp17='%f', cp18='%f', cp19='%f', cp20='%f', cp21='%f', cp22='%f', cp23='%f', cp24='%f', cp25='%f', cp26='%f', cp27='%f', cp28='%f', cp29='%f', cp30='%f', cp31='%f', cp32='%f', cp33='%f', cp34='%f', cp35='%f' WHERE steamid='%s' AND mapname='%s' AND zonegroup='%i'";
char sql_insertCheckpoints[] = "INSERT INTO ck_checkpoints VALUES ('%s', '%s', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%i')";
char sql_selectCheckpoints[] = "SELECT zonegroup, cp1, cp2, cp3, cp4, cp5, cp6, cp7, cp8, cp9, cp10, cp11, cp12, cp13, cp14, cp15, cp16, cp17, cp18, cp19, cp20, cp21, cp22, cp23, cp24, cp25, cp26, cp27, cp28, cp29, cp30, cp31, cp32, cp33, cp34, cp35 FROM ck_checkpoints WHERE mapname='%s' AND steamid = '%s';";
char sql_selectCheckpointsinZoneGroup[] = "SELECT cp1, cp2, cp3, cp4, cp5, cp6, cp7, cp8, cp9, cp10, cp11, cp12, cp13, cp14, cp15, cp16, cp17, cp18, cp19, cp20, cp21, cp22, cp23, cp24, cp25, cp26, cp27, cp28, cp29, cp30, cp31, cp32, cp33, cp34, cp35 FROM ck_checkpoints WHERE mapname='%s' AND steamid = '%s' AND zonegroup = %i;";
char sql_selectRecordCheckpoints[] = "SELECT zonegroup, cp1, cp2, cp3, cp4, cp5, cp6, cp7, cp8, cp9, cp10, cp11, cp12, cp13, cp14, cp15, cp16, cp17, cp18, cp19, cp20, cp21, cp22, cp23, cp24, cp25, cp26, cp27, cp28, cp29, cp30, cp31, cp32, cp33, cp34, cp35 FROM ck_checkpoints WHERE steamid = '%s' AND mapname='%s' UNION SELECT a.zonegroup, b.cp1, b.cp2, b.cp3, b.cp4, b.cp5, b.cp6, b.cp7, b.cp8, b.cp9, b.cp10, b.cp11, b.cp12, b.cp13, b.cp14, b.cp15, b.cp16, b.cp17, b.cp18, b.cp19, b.cp20, b.cp21, b.cp22, b.cp23, b.cp24, b.cp25, b.cp26, b.cp27, b.cp28, b.cp29, b.cp30, b.cp31, b.cp32, b.cp33, b.cp34, b.cp35 FROM ck_bonus a LEFT JOIN ck_checkpoints b ON a.steamid = b.steamid AND a.zonegroup = b.zonegroup WHERE a.mapname = '%s' GROUP BY a.zonegroup";
char sql_deleteCheckpoints[] = "DELETE FROM ck_checkpoints WHERE mapname = '%s'";

//TABLE LATEST 15 LOCAL RECORDS
char sql_createLatestRecords[] = "CREATE TABLE IF NOT EXISTS ck_latestrecords (steamid VARCHAR(32), name VARCHAR(32), runtime FLOAT NOT NULL DEFAULT '-1.0', map VARCHAR(32), date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY(steamid,map,date));";
char sql_insertLatestRecords[] = "INSERT INTO ck_latestrecords (steamid, name, runtime, map) VALUES('%s','%s','%f','%s');";
char sql_selectLatestRecords[] = "SELECT name, runtime, map, date FROM ck_latestrecords ORDER BY date DESC LIMIT 50";

//TABLE PLAYEROPTIONS
char sql_createPlayerOptions[] = "CREATE TABLE `ck_playeroptions2` ( `steamid` varchar(32) NOT NULL DEFAULT '', `timer` int(11) NOT NULL DEFAULT '1', `hide` int(11) NOT NULL DEFAULT '0', `sounds` int(11) NOT NULL DEFAULT '1', `chat` int(11) NOT NULL DEFAULT '0', `viewmodel` int(11) NOT NULL DEFAULT '1', `autobhop` int(11) NOT NULL DEFAULT '1', `checkpoints` int(11) NOT NULL DEFAULT '1', `centrehud` int(11) NOT NULL DEFAULT '1', `centretimer` int(11) NOT NULL DEFAULT '1', `centrewr` int(11) NOT NULL DEFAULT '1', `centrepb` int(11) NOT NULL DEFAULT '1', `centrestage` int(11) NOT NULL DEFAULT '1', `centrespeedometer` int(11) NOT NULL DEFAULT '1', `centrespeedmode` int(11) NOT NULL DEFAULT '0', `centregradient` int(11) NOT NULL DEFAULT '3', `centrestrafesync` int(11) NOT NULL DEFAULT '0', `sidehud` int(11) NOT NULL DEFAULT '1', `sidetimer` int(11) NOT NULL DEFAULT '0', `sidewr` int(11) NOT NULL DEFAULT '0', `sidepb` int(11) NOT NULL DEFAULT '0', `sidestage` int(11) NOT NULL DEFAULT '0', `sidespeedometer` int(11) NOT NULL DEFAULT '0', `sidespeedmode` int(11) NOT NULL DEFAULT '0', `sidestrafesync` int(11) NOT NULL DEFAULT '0', `sidespeclist` int(11) NOT NULL DEFAULT '1', PRIMARY KEY (`steamid`));";

char sql_insertPlayerOptions[] = "INSERT INTO ck_playeroptions2 (steamid) VALUES ('%s');";

char sql_selectPlayerOptions[] = "SELECT timer, hide, sounds, chat, viewmodel, autobhop, checkpoints, gradient, speedmode, centrespeed, centrehud, module1c, module2c, module3c, module4c, module5c, module6c, sidehud, module1s, module2s, module3s, module4s, module5s FROM ck_playeroptions2 where steamid = '%s';";

char sql_updatePlayerOptions[] = "UPDATE ck_playeroptions2 SET timer = %i, hide = %i, sounds = %i, chat = %i, viewmodel = %i, autobhop = %i, checkpoints = %i, gradient = %i, speedmode = %i, centrespeed = %i, centrehud = %i, module1c = %i, module2c = %i, module3c = %i, module4c = %i, module5c = %i, module6c = %i, sidehud = %i, module1s = %i, module2s = %i, module3s = %i, module4s = %i, module5s = %i where steamid = '%s'";

//TABLE PLAYERRANK
char sql_createPlayerRank[] = "CREATE TABLE IF NOT EXISTS ck_playerrank (steamid VARCHAR(32), name VARCHAR(32), country VARCHAR(32), points INT(12)  DEFAULT '0',finishedmaps INT(12) DEFAULT '0', finishedmapspro INT(12) DEFAULT '0', lastseen DATE, PRIMARY KEY(steamid));";
char sql_insertPlayerRank[] = "INSERT INTO ck_playerrank (steamid, steamid64, name, country, joined) VALUES('%s', '%s', '%s', '%s', %i);";
char sql_updatePlayerRankPoints[] = "UPDATE ck_playerrank SET name ='%s', points ='%i', wrpoints = %i, wrbpoints = %i, top10points = %i, groupspoints = %i, mappoints = %i, bonuspoints = %i, finishedmapspro='%i', finishedbonuses = %i, finishedstages = %i, wrs = %i, wrbs = %i, wrcps = %i, top10s = %i, groups = %i where steamid='%s';";
char sql_updatePlayerRankPoints2[] = "UPDATE ck_playerrank SET name ='%s', points ='%i', wrpoints = %i, wrbpoints = %i, top10points = %i, groupspoints = %i, mappoints = %i, bonuspoints = %i, finishedmapspro='%i', finishedbonuses = %i, finishedstages = %i, wrs = %i, wrbs = %i, wrcps = %i, top10s = %i, groups = %i, country = '%s' where steamid='%s';";
char sql_updatePlayerRank[] = "UPDATE ck_playerrank SET finishedmaps ='%i', finishedmapspro='%i' where steamid='%s'";
char sql_selectPlayerRankAll[] = "SELECT name, steamid FROM ck_playerrank where name like '%c%s%c'";
char sql_selectPlayerRankAll2[] = "SELECT name, steamid FROM ck_playerrank where name = '%s'";
char sql_selectPlayerName[] = "SELECT name FROM ck_playerrank where steamid = '%s'";
char sql_UpdateLastSeenMySQL[] = "UPDATE ck_playerrank SET lastseen = UNIX_TIMESTAMP() where steamid = '%s';";
char sql_UpdateLastSeenSQLite[] = "UPDATE ck_playerrank SET lastseen = date('now') where steamid = '%s';";
char sql_selectTopPlayers[] = "SELECT name, points, finishedmapspro, steamid FROM ck_playerrank ORDER BY points DESC LIMIT 100";
char sql_selectRankedPlayer[] = "SELECT steamid, name, points, finishedmapspro, country, lastseen, timealive, timespec, connections, readchangelog from ck_playerrank where steamid='%s';";
char sql_selectRankedPlayersRank[] = "SELECT name FROM ck_playerrank WHERE points >= (SELECT points FROM ck_playerrank WHERE steamid = '%s') ORDER BY points";
char sql_selectRankedPlayers[] = "SELECT steamid, name from ck_playerrank where points > 0 ORDER BY points DESC";
char sql_CountRankedPlayers[] = "SELECT COUNT(steamid) FROM ck_playerrank";
char sql_CountRankedPlayers2[] = "SELECT COUNT(steamid) FROM ck_playerrank where points > 0";

//TABLE PLAYERTIMES
char sql_createPlayertimes[] = "CREATE TABLE IF NOT EXISTS ck_playertimes (steamid VARCHAR(32), mapname VARCHAR(32), name VARCHAR(32), runtimepro FLOAT NOT NULL DEFAULT '-1.0', PRIMARY KEY(steamid,mapname));";
char sql_createPlayertimesIndex[] = "CREATE INDEX maprank ON ck_playertimes (mapname, runtimepro, style);";
char sql_insertPlayer[] = "INSERT INTO ck_playertimes (steamid, mapname, name) VALUES('%s', '%s', '%s');";
char sql_insertPlayerTime[] = "INSERT INTO ck_playertimes (steamid, mapname, name, runtimepro, style) VALUES('%s', '%s', '%s', '%f', %i);";
char sql_updateRecordPro[] = "UPDATE ck_playertimes SET name = '%s', runtimepro = '%f' WHERE steamid = '%s' AND mapname = '%s' AND style = %i;";
char sql_selectPlayer[] = "SELECT steamid FROM ck_playertimes WHERE steamid = '%s' AND mapname = '%s';";
char sql_selectMapRecord[] = "SELECT MIN(runtimepro), name, steamid, style FROM ck_playertimes WHERE mapname = '%s' AND runtimepro > -1.0 GROUP BY style;";
char sql_selectPersonalRecords[] = "SELECT runtimepro, name FROM ck_playertimes WHERE mapname = '%s' AND steamid = '%s' AND runtimepro > 0.0";
char sql_selectPersonalAllRecords[] = "SELECT db1.name, db2.steamid, db2.mapname, db2.runtimepro as overall, db1.steamid, db3.tier FROM ck_playertimes as db2 INNER JOIN ck_playerrank as db1 on db2.steamid = db1.steamid INNER JOIN ck_maptier AS db3 ON db2.mapname = db3.mapname WHERE db2.steamid = '%s' AND db2.style = 0 AND db2.runtimepro > -1.0 ORDER BY mapname ASC";
char sql_selectProSurfers[] = "SELECT db1.name, db2.runtimepro, db2.steamid, db1.steamid FROM ck_playertimes as db2 INNER JOIN ck_playerrank as db1 on db2.steamid = db1.steamid WHERE db2.mapname = '%s' AND db2.runtimepro > -1.0 ORDER BY db2.runtimepro ASC LIMIT 20";
char sql_selectTopSurfers2[] = "SELECT db2.steamid, db1.name, db2.runtimepro as overall, db1.steamid, db2.mapname FROM ck_playertimes as db2 INNER JOIN ck_playerrank as db1 on db2.steamid = db1.steamid WHERE db2.mapname LIKE '%c%s%c' AND db2.style = 0 AND db2.runtimepro > -1.0 ORDER BY overall ASC LIMIT 100;";
char sql_selectTopSurfers3[] = "SELECT db2.steamid, db1.name, db2.runtimepro as overall, db1.steamid, db2.mapname FROM ck_playertimes as db2 INNER JOIN ck_playerrank as db1 on db2.steamid = db1.steamid WHERE db2.mapname = '%s' AND db2.style = 0 AND db2.runtimepro > -1.0 ORDER BY overall ASC LIMIT 100;";
char sql_selectTopSurfers[] = "SELECT db2.steamid, db1.name, db2.runtimepro as overall, db1.steamid, db2.mapname FROM ck_playertimes as db2 INNER JOIN ck_playerrank as db1 on db2.steamid = db1.steamid WHERE db2.mapname = '%s' AND db2.style = 0 AND db2.runtimepro > -1.0 ORDER BY overall ASC LIMIT 100;";
char sql_selectPlayerProCount[] = "SELECT style, count(1) FROM ck_playertimes WHERE mapname = '%s' GROUP BY style;";
char sql_selectPlayerRankProTime[] = "SELECT name,mapname FROM ck_playertimes WHERE runtimepro <= (SELECT runtimepro FROM ck_playertimes WHERE steamid = '%s' AND mapname = '%s' AND style = 0 AND runtimepro > -1.0) AND mapname = '%s' AND style = 0 AND runtimepro > -1.0 ORDER BY runtimepro;";
char sql_selectMapRecordHolders[] = "SELECT y.steamid, COUNT(*) AS rekorde FROM (SELECT s.steamid FROM ck_playertimes s INNER JOIN (SELECT mapname, MIN(runtimepro) AS runtimepro FROM ck_playertimes where runtimepro > -1.0 GROUP BY mapname) x ON s.mapname = x.mapname AND s.runtimepro = x.runtimepro) y GROUP BY y.steamid ORDER BY rekorde DESC , y.steamid LIMIT 5;";
char sql_selectMapRecordCount[] = "SELECT y.steamid, COUNT(*) AS rekorde FROM (SELECT s.steamid, s.style FROM ck_playertimes s INNER JOIN (SELECT mapname, MIN(runtimepro) AS runtimepro FROM ck_playertimes where runtimepro > -1.0 AND style = 0 GROUP BY mapname) x ON s.mapname = x.mapname AND s.runtimepro = x.runtimepro) y where y.steamid = '%s' AND y.style = 0 GROUP BY y.steamid ORDER BY rekorde DESC , y.steamid";
char sql_selectAllMapTimesinMap[] = "SELECT runtimepro from ck_playertimes WHERE mapname = '%s';";

//TABLE PLAYERTEMP
char sql_createPlayertmp[] = "CREATE TABLE IF NOT EXISTS ck_playertemp (steamid VARCHAR(32), mapname VARCHAR(32), cords1 FLOAT NOT NULL DEFAULT '-1.0', cords2 FLOAT NOT NULL DEFAULT '-1.0', cords3 FLOAT NOT NULL DEFAULT '-1.0', angle1 FLOAT NOT NULL DEFAULT '-1.0',angle2 FLOAT NOT NULL DEFAULT '-1.0',angle3 FLOAT NOT NULL DEFAULT '-1.0', EncTickrate INT(12) DEFAULT '-1.0', runtimeTmp FLOAT NOT NULL DEFAULT '-1.0', Stage INT, zonegroup INT NOT NULL DEFAULT 0, PRIMARY KEY(steamid,mapname));";
char sql_insertPlayerTmp[] = "INSERT INTO ck_playertemp (cords1, cords2, cords3, angle1,angle2,angle3,runtimeTmp,steamid,mapname,EncTickrate,Stage,zonegroup) VALUES ('%f','%f','%f','%f','%f','%f','%f','%s', '%s', '%i', %i, %i);";
char sql_updatePlayerTmp[] = "UPDATE ck_playertemp SET cords1 = '%f', cords2 = '%f', cords3 = '%f', angle1 = '%f', angle2 = '%f', angle3 = '%f', runtimeTmp = '%f', mapname ='%s', EncTickrate='%i', Stage = %i, zonegroup = %i WHERE steamid = '%s';";
char sql_deletePlayerTmp[] = "DELETE FROM ck_playertemp where steamid = '%s';";
char sql_selectPlayerTmp[] = "SELECT cords1,cords2,cords3, angle1, angle2, angle3,runtimeTmp, EncTickrate, Stage, zonegroup FROM ck_playertemp WHERE steamid = '%s' AND mapname = '%s';";

////////////////////////
//// DATABASE SETUP/////
////////////////////////

public void db_setupDatabase()
{
	////////////////////////////////
	// INIT CONNECTION TO DATABASE//
	////////////////////////////////
	char szError[255];
	g_hDb = SQL_Connect("surftimer", false, szError, 255);

	if (g_hDb == null)
	{
		SetFailState("[Surftimer] Unable to connect to database (%s)", szError);
		return;
	}

	char szIdent[8];
	SQL_ReadDriver(g_hDb, szIdent, 8);

	if (strcmp(szIdent, "mysql", false) == 0)
	{
		g_DbType = MYSQL;
	}
	else
	if (strcmp(szIdent, "sqlite", false) == 0)
	g_DbType = SQLITE;
	else
	{
		LogError("[Surftimer] Invalid Database-Type");
		return;
	}

	// If updating from a previous version
	SQL_LockDatabase(g_hDb);
	SQL_FastQuery(g_hDb, "SET NAMES  'utf8'");
	SQL_FastQuery(g_hDb, "SET name 'utf8'");
	SQL_FastQuery(g_hDb, "SET closername 'utf8'");
	SQL_FastQuery(g_hDb, "SET reopenname 'utf8'");
	SQL_FastQuery(g_hDb, "ALTER TABLE reports AUTO_INCREMENT = 1;");


	////////////////////////////////
	// CHECK WHICH CHANGES ARE    //
	// TO BE DONE TO THE DATABASE //
	////////////////////////////////
	g_bRenaming = false;
	g_bInTransactionChain = false;

	// If coming from KZTimer or a really old version, rename and edit tables to new format
	if (SQL_FastQuery(g_hDb, "SELECT steamid FROM playerrank LIMIT 1") && !SQL_FastQuery(g_hDb, "SELECT steamid FROM ck_playerrank LIMIT 1"))
	{
		SQL_UnlockDatabase(g_hDb);
		db_renameTables();
		return;
	}
	else // If startring for the first time and tables haven't been created yet.
	if (!SQL_FastQuery(g_hDb, "SELECT steamid FROM playerrank LIMIT 1") && !SQL_FastQuery(g_hDb, "SELECT steamid FROM ck_playerrank LIMIT 1"))
	{
		SQL_UnlockDatabase(g_hDb);
		db_createTables();
		return;
	}


	// 1.17 Command to disable checkpoint messages
	SQL_FastQuery(g_hDb, "ALTER TABLE ck_playeroptions2 ADD checkpoints INT DEFAULT 1;");


	////////////////////////////
	// 1.18 A bunch of changes //
	// - Zone Groups          //
	// - Zone Names           //
	// - Bonus Tiers          //
	// - Titles               //
	// - More checkpoints     //
	////////////////////////////

	SQL_FastQuery(g_hDb, "ALTER TABLE ck_zones ADD zonegroup INT NOT NULL DEFAULT 0;");
	SQL_FastQuery(g_hDb, "ALTER TABLE ck_zones ADD zonename VARCHAR(128);");
	SQL_FastQuery(g_hDb, "ALTER TABLE ck_playertemp ADD zonegroup INT NOT NULL DEFAULT 0;");

	SQL_FastQuery(g_hDb, "CREATE INDEX maprank ON ck_playertimes (mapname, runtimepro)");
	SQL_FastQuery(g_hDb, "CREATE INDEX bonusrank ON ck_bonus (mapname,runtime,zonegroup)");

	SQL_UnlockDatabase(g_hDb);

	for (int i = 0; i < sizeof(g_failedTransactions); i++)
	g_failedTransactions[i] = 0;

	txn_addExtraCheckpoints();
	return;
}

void txn_addExtraCheckpoints()
{
	// Add extra checkpoints to Checkpoints and add new primary key:
	if (!SQL_FastQuery(g_hDb, "SELECT cp35 FROM ck_checkpoints;"))
	{
		PrintToServer("---------------------------------------------------------------------------");
		disableServerHibernate();
		PrintToServer("surftimer | Started to make changes to database. Updating from 1.17 -> 1.18.");
		PrintToServer("surftimer | WARNING: DO NOT CONNECT TO THE SERVER, OR CHANGE MAP!");
		PrintToServer("surftimer | Adding extra checkpoints... (1 / 6)");

		g_bInTransactionChain = true;
		Transaction h_checkpoint = SQL_CreateTransaction();

		SQL_AddQuery(h_checkpoint, "ALTER TABLE ck_checkpoints RENAME TO ck_checkpoints_temp;");
		SQL_AddQuery(h_checkpoint, sql_createCheckpoints);
		SQL_AddQuery(h_checkpoint, "INSERT INTO ck_checkpoints(steamid, mapname, zonegroup, cp1, cp2, cp3, cp4, cp5, cp6, cp7, cp8, cp9, cp10, cp11, cp12, cp13, cp14, cp15, cp16, cp17, cp18, cp19, cp20) SELECT steamid, mapname, 0, cp1, cp2, cp3, cp4, cp5, cp6, cp7, cp8, cp9, cp10, cp11, cp12, cp13, cp14, cp15, cp16, cp17, cp18, cp19, cp20 FROM ck_checkpoints_temp GROUP BY mapname, steamid;");
		SQL_AddQuery(h_checkpoint, "DROP TABLE ck_checkpoints_temp;");

		SQL_ExecuteTransaction(g_hDb, h_checkpoint, SQLTxn_Success, SQLTxn_TXNFailed, 1);
	}
	else
	{
		PrintToServer("surftimer | No database update needed!");
		return;
	}
}

void txn_addZoneGroups()
{
	// Add zonegroups to ck_bonus and make it a primary key
	if (!SQL_FastQuery(g_hDb, "SELECT zonegroup FROM ck_bonus;"))
	{
		Transaction h_bonus = SQL_CreateTransaction();

		SQL_AddQuery(h_bonus, "ALTER TABLE ck_bonus RENAME TO ck_bonus_temp;");
		SQL_AddQuery(h_bonus, sql_createBonus);
		SQL_AddQuery(h_bonus, sql_createBonusIndex);
		SQL_AddQuery(h_bonus, "INSERT INTO ck_bonus(steamid, name, mapname, runtime) SELECT steamid, name, mapname, runtime FROM ck_bonus_temp;");
		SQL_AddQuery(h_bonus, "DROP TABLE ck_bonus_temp;");

		SQL_ExecuteTransaction(g_hDb, h_bonus, SQLTxn_Success, SQLTxn_TXNFailed, 2);
	}
	else
	{
		PrintToServer("surftimer | Zonegroup changes were already done! Skipping to recreating playertemp!");
		txn_recreatePlayerTemp();
	}
}

void txn_recreatePlayerTemp()
{
	// Recreate playertemp without BonusTimer
	if (SQL_FastQuery(g_hDb, "SELECT BonusTimer FROM ck_playertemp;"))
	{
		// No need to preserve temp data, just drop table
		Transaction h_playertemp = SQL_CreateTransaction();
		SQL_AddQuery(h_playertemp, "DROP TABLE IF EXISTS ck_playertemp");
		SQL_AddQuery(h_playertemp, sql_createPlayertmp);
		SQL_ExecuteTransaction(g_hDb, h_playertemp, SQLTxn_Success, SQLTxn_TXNFailed, 3);
	}
	else
	{
		PrintToServer("surftimer | Playertemp was already recreated! Skipping to bonus tiers");
		txn_addBonusTiers();
	}
}

void txn_addBonusTiers()
{
	// Add bonus tiers
	if (SQL_FastQuery(g_hDb, "ALTER TABLE ck_maptier ADD btier1 INT;"))
	{
		Transaction h_maptiers = SQL_CreateTransaction();
		char sql[258];
		for (int x = 2; x < 11; x++)
		{
			Format(sql, 258, "ALTER TABLE ck_maptier ADD btier%i INT;", x);
			SQL_AddQuery(h_maptiers, sql);
		}
		SQL_ExecuteTransaction(g_hDb, h_maptiers, SQLTxn_Success, SQLTxn_TXNFailed, 4);
	}
	else
	{
		PrintToServer("surftimer | Bonus tiers were already added. Skipping to spawn points");
		txn_addSpawnPoints();
	}
}
void txn_addSpawnPoints()
{
	if (!SQL_FastQuery(g_hDb, "SELECT zonegroup FROM ck_spawnlocations;"))
	{
		Transaction h_spawnPoints = SQL_CreateTransaction();
		SQL_AddQuery(h_spawnPoints, "ALTER TABLE ck_spawnlocations RENAME TO ck_spawnlocations_temp;");
		SQL_AddQuery(h_spawnPoints, sql_createSpawnLocations);
		SQL_AddQuery(h_spawnPoints, "INSERT INTO ck_spawnlocations (mapname, pos_x, pos_y, pos_z, ang_x, ang_y, ang_z) SELECT mapname, pos_x, pos_y, pos_z, ang_x, ang_y, ang_z, vel FROM ck_spawnlocations_temp;");
		SQL_AddQuery(h_spawnPoints, "DROP TABLE ck_spawnlocations_temp");
		SQL_ExecuteTransaction(g_hDb, h_spawnPoints, SQLTxn_Success, SQLTxn_TXNFailed, 5);
	}
	else
	{
		PrintToServer("surftimer | Spawnpoints were already added! Skipping to changes in zones");
		txn_changesToZones();
	}
}

void txn_changesToZones()
{
	Transaction h_changesToZones = SQL_CreateTransaction();
	// Set right zonegroups
	SQL_AddQuery(h_changesToZones, "UPDATE ck_zones SET zonegroup = 1 WHERE zonetype = 3 OR zonetype = 4;");
	SQL_AddQuery(h_changesToZones, "UPDATE ck_zones SET zonetypeid = 0 WHERE zonetype = 3 OR zonetype = 4;");

	// Remove ZoneTypes 3 & 4
	SQL_AddQuery(h_changesToZones, "UPDATE ck_zones SET zonetype = 1 WHERE zonetype = 3;");
	SQL_AddQuery(h_changesToZones, "UPDATE ck_zones SET zonetype = 2 WHERE zonetype = 4;");

	// Adjust bigger zonetype numbers to match the changes
	SQL_AddQuery(h_changesToZones, "UPDATE ck_zones SET zonetype = zonetype-2 WHERE zonetype > 4;");
	SQL_ExecuteTransaction(g_hDb, h_changesToZones, SQLTxn_Success, SQLTxn_TXNFailed, 6);
}


public void SQLTxn_Success(Handle db, any data, int numQueries, Handle[] results, any[] queryData)
{
	switch (data)
	{
		case 1: {
			PrintToServer("surftimer | Checkpoints added succesfully! Next up: adding zonegroups to ck_bonus (2 / 6)");
			txn_addZoneGroups();
		}
		case 2: {
			PrintToServer("surftimer | Bonus zonegroups succesfully added! Next up: recreating playertemp (3 / 6)");
			txn_recreatePlayerTemp();
		}
		case 3: {
			PrintToServer("surftimer | Playertemp succesfully recreated! Next up: adding bonus tiers (4 / 6)");
			txn_addBonusTiers();
		}
		case 4: {
			PrintToServer("surftimer | Bonus tiers added succesfully! Next up: adding spawn points (5 / 6)");
			txn_addSpawnPoints();
		}
		case 5: {
			PrintToServer("surftimer | Spawnpoints added succesfully! Next up: making changes to zones, to make them match the new database (6 / 6)");
			txn_changesToZones();
		}
		case 6: {
			g_bInTransactionChain = false;

			revertServerHibernateSettings();
			PrintToServer("surftimer | All changes succesfully done! Changing map!");
			ForceChangeLevel(g_szMapName, "surftimer | Changing level after changes to the database have been done");
		}
	}
}

public void SQLTxn_TXNFailed(Handle db, any data, int numQueries, const char[] error, int failIndex, any[] queryData)
{
	if (g_failedTransactions[data] == 0)
	{
		switch (data)
		{
			case 1: {
				PrintToServer("surftimer | Error in adding extra checkpoints! Retrying.. (%s)", error);
				txn_addExtraCheckpoints();
			}
			case 2: {
				PrintToServer("surftimer | Error in addin zonegroups! Retrying... (%s)", error);
				txn_addZoneGroups();
			}
			case 3: {
				PrintToServer("surftimer | Error in recreating playertemp! Retrying... (%s)", error);
				txn_recreatePlayerTemp();
			}
			case 4: {
				PrintToServer("surftimer | Error in adding bonus tiers! Retrying... (%s)", error);
				txn_addBonusTiers();
			}
			case 5: {
				PrintToServer("surftimer | Error in adding spawn points! Retrying... (%s)", error);
				txn_addSpawnPoints();
			}
			case 6: {
				PrintToServer("surftimer | Error in making changes to zones! Retrying... (%s)", error);
				txn_changesToZones();
			}
		}
	}
	else
	{
		revertServerHibernateSettings();
		PrintToServer("surftimer | Couldn't make changes into the database. Transaction: %i, error: %s", data, error);
		PrintToServer("surftimer | Revert back to database backup.");
		LogError("[Surftimer]: Couldn't make changes into the database. Transaction: %i, error: %s", data, error);
		return;
	}
	g_failedTransactions[data]++;
}


public void db_createTables()
{
	Transaction createTableTnx = SQL_CreateTransaction();

	SQL_AddQuery(createTableTnx, sql_createPlayertmp);
	SQL_AddQuery(createTableTnx, sql_createPlayertimes);
	SQL_AddQuery(createTableTnx, sql_createPlayertimesIndex);
	SQL_AddQuery(createTableTnx, sql_createPlayerRank);
	SQL_AddQuery(createTableTnx, sql_createPlayerOptions);
	SQL_AddQuery(createTableTnx, sql_createLatestRecords);
	SQL_AddQuery(createTableTnx, sql_createBonus);
	SQL_AddQuery(createTableTnx, sql_createBonusIndex);
	SQL_AddQuery(createTableTnx, sql_createCheckpoints);
	SQL_AddQuery(createTableTnx, sql_createZones);
	SQL_AddQuery(createTableTnx, sql_createMapTier);
	SQL_AddQuery(createTableTnx, sql_createSpawnLocations);
	SQL_AddQuery(createTableTnx, sql_createPlayerReports);
	SQL_AddQuery(createTableTnx, sql_createPlayerTotalTime);

	SQL_ExecuteTransaction(g_hDb, createTableTnx, SQLTxn_CreateDatabaseSuccess, SQLTxn_CreateDatabaseFailed);

}

public void SQLTxn_CreateDatabaseSuccess(Handle db, any data, int numQueries, Handle[] results, any[] queryData)
{
	PrintToServer("[Surftimer] Database tables succesfully created!");
}

public void SQLTxn_CreateDatabaseFailed(Handle db, any data, int numQueries, const char[] error, int failIndex, any[] queryData)
{
	SetFailState("[Surftimer] Database tables could not be created! Error: %s", error);
}


public void db_renameTables()
{
	disableServerHibernate();

	g_bRenaming = true;
	Transaction hndl = SQL_CreateTransaction();

	SQL_AddQuery(hndl, sql_createSpawnLocations);

	if (g_DbType == MYSQL)
	{
		// Remove unused columns, if coming from KZTimer
		SQL_AddQuery(hndl, "ALTER TABLE latestrecords DROP COLUMN teleports");
		SQL_AddQuery(hndl, "ALTER TABLE playeroptions2 DROP COLUMN colorchat");
		SQL_AddQuery(hndl, "ALTER TABLE playeroptions2 DROP COLUMN Surfersmenu_sounds");
		SQL_AddQuery(hndl, "ALTER TABLE playeroptions2 DROP COLUMN strafesync");
		SQL_AddQuery(hndl, "ALTER TABLE playeroptions2 DROP COLUMN cpmessage");
		SQL_AddQuery(hndl, "ALTER TABLE playeroptions2 DROP COLUMN adv_menu");
		SQL_AddQuery(hndl, "ALTER TABLE playeroptions2 DROP COLUMN jumppenalty");
		SQL_AddQuery(hndl, "ALTER TABLE playerrank DROP COLUMN finishedmapstp");
		SQL_AddQuery(hndl, "ALTER TABLE playertimes DROP COLUMN teleports");
		SQL_AddQuery(hndl, "ALTER TABLE playertimes DROP COLUMN runtime");
		SQL_AddQuery(hndl, "ALTER TABLE playertimes DROP COLUMN teleports_pro");
		SQL_AddQuery(hndl, "ALTER TABLE playertmp DROP COLUMN teleports");
		SQL_AddQuery(hndl, "ALTER TABLE playertmp DROP COLUMN checkpoints");
		SQL_AddQuery(hndl, "ALTER TABLE LatestRecords DROP COLUMN teleports");

		SQL_AddQuery(hndl, "ALTER TABLE playeroptions2 RENAME TO ck_playeroptions2;");
		SQL_AddQuery(hndl, "ALTER TABLE playertimes RENAME TO ck_playertimes;");
		SQL_AddQuery(hndl, "ALTER TABLE playerrank RENAME TO ck_playerrank;");

	}
	else if (g_DbType == SQLITE)
	{
		// player options
		SQL_AddQuery(hndl, sql_createPlayerOptions);
		SQL_AddQuery(hndl, "INSERT INTO ck_playeroptions2(steamid, speedmeter, quake_sounds, autobhop, shownames, goto, showtime, hideplayers, showspecs, new1, new2, new3) SELECT steamid, speedmeter, quake_sounds, autobhop, shownames, goto, showtime, hideplayers, showspecs, new1, new2, new3 FROM playeroptions2;");
		SQL_AddQuery(hndl, "DROP TABLE IF EXISTS playeroptions2");

		// player times
		SQL_AddQuery(hndl, sql_createPlayertimes);
		SQL_AddQuery(hndl, sql_createPlayertimesIndex);
		SQL_AddQuery(hndl, "INSERT INTO ck_playertimes(steamid, mapname, name, runtimepro) SELECT steamid, mapname, name, runtimepro FROM playertimes;");
		SQL_AddQuery(hndl, "DROP TABLE IF EXISTS playertimes");

		// playerrank
		SQL_AddQuery(hndl, sql_createPlayerRank);
		SQL_AddQuery(hndl, "INSERT INTO ck_playerrank(steamid, name, country, points, winratio, pointsratio, finishedmaps, multiplier, finishedmapspro, lastseen) SELECT steamid, name, country, points, winratio, pointsratio, finishedmaps, multiplier, finishedmapspro, lastseen FROM playerrank;");
		SQL_AddQuery(hndl, "DROP TABLE IF EXISTS playerrank");
	}

	SQL_AddQuery(hndl, "ALTER TABLE bonus RENAME TO ck_bonus;");
	SQL_AddQuery(hndl, "ALTER TABLE checkpoints RENAME TO ck_checkpoints;");
	SQL_AddQuery(hndl, "ALTER TABLE maptier RENAME TO ck_maptier;");
	SQL_AddQuery(hndl, "ALTER TABLE zones RENAME TO ck_zones;");

	SQL_AddQuery(hndl, sql_createPlayertmp);
	SQL_AddQuery(hndl, sql_createLatestRecords);

	// Drop useless tables from KZTimer
	SQL_AddQuery(hndl, "DROP TABLE IF EXISTS playertmp");
	SQL_AddQuery(hndl, "DROP TABLE IF EXISTS LatestRecords");
	SQL_AddQuery(hndl, "DROP TABLE IF EXISTS ck_mapbuttons");
	SQL_AddQuery(hndl, "DROP TABLE IF EXISTS playerjumpstats3");

	SQL_ExecuteTransaction(g_hDb, hndl, SQLTxn_RenameSuccess, SQLTxn_RenameFailed);
}

public void SQLTxn_RenameSuccess(Handle db, any data, int numQueries, Handle[] results, any[] queryData)
{
	g_bRenaming = false;
	revertServerHibernateSettings();
	PrintToChatAll(" %cSurftimer %c| Database changes done succesfully, reloading the map...");
	ForceChangeLevel(g_szMapName, "Database Renaming Done. Restarting Map.");
}

public void SQLTxn_RenameFailed(Handle db, any data, int numQueries, const char[] error, int failIndex, any[] queryData)
{
	g_bRenaming = false;
	revertServerHibernateSettings();
	SetFailState("[Surftimer] Database changes failed! (Renaming) Error: %s", error);
}


///////////////////////
//// PLAYER TITLES ////
///////////////////////


/////////////////////////
//// SPAWN LOCATIONS ////
/////////////////////////

public void db_deleteSpawnLocations(int zGrp)
{
	g_bGotSpawnLocation[zGrp][0] = false;
	char szQuery[128];
	Format(szQuery, 128, sql_deleteSpawnLocations, g_szMapName, zGrp);
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, 1, DBPrio_Low);
}


public void db_updateSpawnLocations(float position[3], float angle[3], float vel[3], int zGrp)
{
	char szQuery[512];
	Format(szQuery, 512, sql_updateSpawnLocations, position[0], position[1], position[2], angle[0], angle[1], angle[2], vel[0], vel[1], vel[2], g_szMapName, zGrp);
	SQL_TQuery(g_hDb, db_editSpawnLocationsCallback, szQuery, zGrp, DBPrio_Low);
}

public void db_insertSpawnLocations(float position[3], float angle[3], float vel[3], int zGrp)
{
	char szQuery[512];
	Format(szQuery, 512, sql_insertSpawnLocations, g_szMapName, position[0], position[1], position[2], angle[0], angle[1], angle[2], vel[0], vel[1], vel[2], zGrp);
	SQL_TQuery(g_hDb, db_editSpawnLocationsCallback, szQuery, zGrp, DBPrio_Low);
}

public void db_editSpawnLocationsCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (db_editSpawnLocationsCallback): %s ", error);
		return;
	}
	db_selectSpawnLocations();
}

public void db_selectSpawnLocations()
{
	for (int s = 0; s < CPLIMIT; s++)
	{
		for (int i = 0; i < MAXZONEGROUPS; i++)
			g_bGotSpawnLocation[i][s] = false;
	}

	char szQuery[254];
	Format(szQuery, 254, sql_selectSpawnLocations, g_szMapName);
	SQL_TQuery(g_hDb, db_selectSpawnLocationsCallback, szQuery, 1, DBPrio_Low);
}

public void db_selectSpawnLocationsCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (db_selectSpawnLocationsCallback): %s ", error);
		if (!g_bServerDataLoaded)
			db_ClearLatestRecords();
		return;
	}

	if (SQL_HasResultSet(hndl))
	{
		while (SQL_FetchRow(hndl))
		{
			g_bGotSpawnLocation[SQL_FetchInt(hndl, 10)][SQL_FetchInt(hndl, 11)] = true;
			g_fSpawnLocation[SQL_FetchInt(hndl, 10)][SQL_FetchInt(hndl, 11)][0] = SQL_FetchFloat(hndl, 1);
			g_fSpawnLocation[SQL_FetchInt(hndl, 10)][SQL_FetchInt(hndl, 11)][1] = SQL_FetchFloat(hndl, 2);
			g_fSpawnLocation[SQL_FetchInt(hndl, 10)][SQL_FetchInt(hndl, 11)][2] = SQL_FetchFloat(hndl, 3);
			g_fSpawnAngle[SQL_FetchInt(hndl, 10)][SQL_FetchInt(hndl, 11)][0] = SQL_FetchFloat(hndl, 4);
			g_fSpawnAngle[SQL_FetchInt(hndl, 10)][SQL_FetchInt(hndl, 11)][1] = SQL_FetchFloat(hndl, 5);
			g_fSpawnAngle[SQL_FetchInt(hndl, 10)][SQL_FetchInt(hndl, 11)][2] = SQL_FetchFloat(hndl, 6);
			g_fSpawnVelocity[SQL_FetchInt(hndl, 10)][SQL_FetchInt(hndl, 11)][0] = SQL_FetchFloat(hndl, 7);
			g_fSpawnVelocity[SQL_FetchInt(hndl, 10)][SQL_FetchInt(hndl, 11)][1] = SQL_FetchFloat(hndl, 8);
			g_fSpawnVelocity[SQL_FetchInt(hndl, 10)][SQL_FetchInt(hndl, 11)][2] = SQL_FetchFloat(hndl, 9);
		}
	}
	if (!g_bServerDataLoaded)
	db_ClearLatestRecords();
	return;
}



/////////////////////
//// PLAYER RANK ////
/////////////////////

public void db_viewMapProRankCount()
{
	g_MapTimesCount = 0;
	char szQuery[512];
	Format(szQuery, 512, sql_selectPlayerProCount, g_szMapName);
	SQL_TQuery(g_hDb, sql_selectPlayerProCountCallback, szQuery, DBPrio_Low);
}

public void sql_selectPlayerProCountCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (sql_selectPlayerProCountCallback): %s", error);
		if (!g_bServerDataLoaded)
		{
			db_viewFastestBonus();
		}
		return;
	}

	int style;
	int count;
	if (SQL_HasResultSet(hndl))
	{
		while (SQL_FetchRow(hndl))
		{
			style = SQL_FetchInt(hndl, 0);
			count = SQL_FetchInt(hndl, 1);
			if (style == 0)
				g_MapTimesCount = count;
			else
				g_StyleMapTimesCount[style] = count;
		}
	}
	else
	{
		g_MapTimesCount = 0;
		for (int i = 1; i < MAX_STYLES; i++)
			g_StyleMapTimesCount[style] = 0;
	}

	if (!g_bServerDataLoaded)
	{
		db_viewFastestBonus();
	}
	return;
}

//
// Get players rank in current map
//
public void db_viewMapRankPro(int client)
{
	char szQuery[512];
	if (!IsValidClient(client))
	return;

	//"SELECT name,mapname FROM ck_playertimes WHERE runtimepro <= (SELECT runtimepro FROM ck_playertimes WHERE steamid = '%s' AND mapname = '%s' AND runtimepro > -1.0) AND mapname = '%s' AND runtimepro > -1.0 ORDER BY runtimepro;";
	Format(szQuery, 512, sql_selectPlayerRankProTime, g_szSteamID[client], g_szMapName, g_szMapName);
	SQL_TQuery(g_hDb, db_viewMapRankProCallback, szQuery, client, DBPrio_Low);
}

public void db_viewMapRankProCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (db_viewMapRankProCallback): %s ", error);
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		g_MapRank[client] = SQL_GetRowCount(hndl);
	}

	// if (!g_bSettingsLoaded[client])
	// {
	// 	g_fTick[client][1] = GetGameTime();
	// 	float tick = g_fTick[client][1] - g_fTick[client][0];
	// 	LogToFileEx(g_szLogFile, "[Surftimer] %s: Finished db_viewPersonalRecords in %fs", g_szSteamID[client], tick);
	// 	g_fTick[client][0] = GetGameTime();

	// 	db_viewPersonalBonusRecords(client, g_szSteamID[client]);
	// }
}

//
// Players points have changed in game, make changes in database and recalculate points
//
public void db_updateStat(int client)
{
	char szQuery[512];
	//"UPDATE ck_playerrank SET finishedmaps ='%i', finishedmapspro='%i', multiplier ='%i'  where steamid='%s'";
	Format(szQuery, 512, sql_updatePlayerRank, g_pr_finishedmaps[client], g_pr_finishedmaps[client], g_szSteamID[client]);

	SQL_TQuery(g_hDb, SQL_UpdateStatCallback, szQuery, client, DBPrio_Low);

}

public void SQL_UpdateStatCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_UpdateStatCallback): %s", error);
		return;
	}

	// Calculating starts here:
	CalculatePlayerRank(data);
}

public void RecalcPlayerRank(int client, char steamid[128])
{
	int i = 66;
	while (g_bProfileRecalc[i] == true)
	i++;
	if (!g_bProfileRecalc[i])
	{
		char szQuery[255];
		char szsteamid[128 * 2 + 1];
		SQL_EscapeString(g_hDb, steamid, szsteamid, 128 * 2 + 1);
		Format(g_pr_szSteamID[i], 32, "%s", steamid);
		Format(szQuery, 255, sql_selectPlayerName, szsteamid);
		Handle pack = CreateDataPack();
		WritePackCell(pack, i);
		WritePackCell(pack, client);
		SQL_TQuery(g_hDb, sql_selectPlayerNameCallback, szQuery, pack);
	}
}

//
//  1. Point calculating starts here
// 	There are two ways:
//	- if client > MAXPLAYERS, his rank is being recalculated by an admin
//	- else player has increased his rank = recalculate points
//
public void CalculatePlayerRank(int client)
{

	char szQuery[255];
	char szSteamId[32];
	// Take old points into memory, so at the end you can show how much the points changed
	g_pr_oldpoints[client] = g_pr_points[client];
	// Initialize point calculatin
	g_pr_points[client] = 0;

	// Start fluffys points
	g_Points[client][0] = 0; // Map Points
	g_Points[client][1] = 0; // Bonus Points
	g_Points[client][2] = 0; // Group Points
	g_Points[client][3] = 0; // Map WR Points
	g_Points[client][4] = 0; // Bonus WR Points
	g_Points[client][5] = 0; // Top 10 Points
	// g_GroupPoints[client][0] // G1 Points
	// g_GroupPoints[client][1] // G2 Points
	// g_GroupPoints[client][2] // G3 Points
	// g_GroupPoints[client][3] // G4 Points
	// g_GroupPoints[client][4] // G5 Points
	g_GroupMaps[client] = 0; // Group Maps
	g_Top10Maps[client] = 0; // Top 10 Maps
	g_WRs[client][0] = 0; // WRs
	g_WRs[client][1] = 0; // WRBs
	g_WRs[client][2] = 0; // WRCPs

	getSteamIDFromClient(client, szSteamId, 32);

	Format(szQuery, 255, "SELECT name FROM ck_playerrank WHERE steamid = '%s'", szSteamId);
	SQL_TQuery(g_hDb, sql_selectRankedPlayerCallback, szQuery, client, DBPrio_Low);
}

//
// 2. See if player exists, insert new player into the database
// Fetched values:
// name
//
public void sql_selectRankedPlayerCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (sql_selectRankedPlayerCallback): %s", error);
		return;
	}


	char szSteamId[32], szSteamId64[64];

	getSteamIDFromClient(client, szSteamId, 32);

	if (IsValidClient(client))
		GetClientAuthId(client, AuthId_SteamID64, szSteamId64, MAX_NAME_LENGTH, true);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		if (IsValidClient(client))
		{
			if (GetClientTime(client) < (GetEngineTime() - g_fMapStartTime))
				db_UpdateLastSeen(client); // Update last seen on server
		}

		if (IsValidClient(client))
		g_pr_Calculating[client] = true;

		// Next up, calculate bonus points:
		char szQuery[512];
		Format(szQuery, 512, "SELECT mapname, (SELECT count(1)+1 FROM ck_bonus b WHERE a.mapname=b.mapname AND a.runtime > b.runtime AND a.zonegroup = b.zonegroup AND b.style = 0) AS rank, (SELECT count(1) FROM ck_bonus b WHERE a.mapname = b.mapname AND a.zonegroup = b.zonegroup AND b.style = 0) as total FROM ck_bonus a WHERE steamid = '%s' AND style = 0", szSteamId);
		SQL_TQuery(g_hDb, sql_CountFinishedBonusCallback, szQuery, client, DBPrio_Low);
	}
	else
	{
		// Players first time on server
		if (client <= MaxClients)
		{
			g_pr_Calculating[client] = false;
			g_pr_AllPlayers++;

			// Insert player to database
			char szQuery[512];
			char szUName[MAX_NAME_LENGTH];
			char szName[MAX_NAME_LENGTH * 2 + 1];

			GetClientName(client, szUName, MAX_NAME_LENGTH);
			SQL_EscapeString(g_hDb, szUName, szName, MAX_NAME_LENGTH * 2 + 1);

			//"INSERT INTO ck_playerrank (steamid, name, country) VALUES('%s', '%s', '%s');";
			// No need to continue calculating, as the doesn't have any records.
			Format(szQuery, 512, sql_insertPlayerRank, szSteamId, szSteamId64, szName, g_szCountry[client], GetTime());
			SQL_TQuery(g_hDb, SQL_InsertPlayerCallBack, szQuery, client, DBPrio_Low);

			g_pr_finishedmaps[client] = 0;
			g_pr_finishedmaps_perc[client] = 0.0;
			g_pr_finishedbonuses[client] = 0;
			g_pr_finishedstages[client] = 0;
			g_GroupMaps[client] = 0; // Group Maps
			g_Top10Maps[client] = 0; // Top 10 Maps

			// play time
			g_iPlayTimeAlive[client] = 0;
			g_iPlayTimeSpec[client ] = 0;
		}
	}
}

//
// 3. Calculate points gained from bonuses
// Fetched values
// mapname, rank, total
//
public void sql_CountFinishedBonusCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (sql_CountFinishedBonusCallback): %s", error);
		return;
	}

	char szMap[128], szSteamId[32], szMapName2[128];
	//int totalplayers
	int rank;

	getSteamIDFromClient(client, szSteamId, 32);
	int finishedbonuses = 0;
	int wrbs = 0;

	if (SQL_HasResultSet(hndl))
	{
		while (SQL_FetchRow(hndl))
		{
			finishedbonuses++;
			// Total amount of players who have finished the bonus
			//totalplayers = SQL_FetchInt(hndl, 2);
			rank = SQL_FetchInt(hndl, 1);
			SQL_FetchString(hndl, 0, szMap, 128);
			for (int i = 0; i < GetArraySize(g_MapList); i++) // Check that the map is in the mapcycle
			{
				GetArrayString(g_MapList, i, szMapName2, sizeof(szMapName2));
				if (StrEqual(szMapName2, szMap, false))
				{
					/*float percentage = 1.0 + ((1.0 / float(totalplayers)) - (float(rank) / float(totalplayers)));
					g_pr_points[client] += RoundToCeil(200.0 * percentage);*/
					switch (rank)
					{
						case 1:
						{
							g_pr_points[client] += 200;
							g_Points[client][4] += 200;
							wrbs++;
						}
						case 2:
						{
							g_pr_points[client] += 190;
							g_Points[client][1] += 190;
						}
						case 3:
						{
							g_pr_points[client] += 180;
							g_Points[client][1] += 180;
						}
						case 4:
						{
							g_pr_points[client] += 170;
							g_Points[client][1] += 170;
						}
						case 5:
						{
							g_pr_points[client] += 150;
							g_Points[client][1] += 150;
						}
						case 6:
						{
							g_pr_points[client] += 140;
							g_Points[client][1] += 140;
						}
						case 7:
						{
							g_pr_points[client] += 135;
							g_Points[client][1] += 135;
						}
						case 8:
						{
							g_pr_points[client] += 120;
							g_Points[client][1] += 120;
						}
						case 9:
						{
							g_pr_points[client] += 115;
							g_Points[client][1] += 115;
						}
						case 10:
						{
							g_pr_points[client] += 105;
							g_Points[client][1] += 105;
						}
						case 11:
						{
							g_pr_points[client] += 100;
							g_Points[client][1] += 100;
						}
						case 12:
						{
							g_pr_points[client] += 90;
							g_Points[client][1] += 90;
						}
						case 13:
						{
							g_pr_points[client] += 80;
							g_Points[client][1] += 80;
						}
						case 14:
						{
							g_pr_points[client] += 75;
							g_Points[client][1] += 75;
						}
						case 15:
						{
							g_pr_points[client] += 60;
							g_Points[client][1] += 60;
						}
						case 16:
						{
							g_pr_points[client] += 50;
							g_Points[client][1] += 50;
						}
						case 17:
						{
							g_pr_points[client] += 40;
							g_Points[client][1] += 40;
						}
						case 18:
						{
							g_pr_points[client] += 30;
							g_Points[client][1] += 30;
						}
						case 19:
						{
							g_pr_points[client] += 20;
							g_Points[client][1] += 20;
						}
						case 20:
						{
							g_pr_points[client] += 10;
							g_Points[client][1] += 10;
						}
					}
					break;
				}
			}
		}
	}

	g_pr_finishedbonuses[client] = finishedbonuses;
	g_WRs[client][1] = wrbs;
	// Next up: Points from stages
	char szQuery[512];
	Format(szQuery, 512, "SELECT mapname, stage, (select count(1)+1 from ck_wrcps b where a.mapname=b.mapname and a.runtimepro > b.runtimepro and a.style = b.style and a.stage = b.stage) AS rank FROM ck_wrcps a where steamid = '%s' AND style = 0", szSteamId);
	SQL_TQuery(g_hDb, sql_CountFinishedStagesCallback, szQuery, client, DBPrio_Low);

	//Format(szQuery, 512, "SELECT mapname, stage, (select count(1)+1 from ck_wrcps b where a.mapname=b.mapname and a.runtimepro > b.runtimepro and a.style = b.style and a.stage = b.stage) AS rank, (SELECT count(1) FROM ck_wrcps b WHERE a.mapname = b.mapname and a.style = b.style and a.stage = b.stage) as total FROM ck_wrcps a where steamid = '%s' AND style = 0;", szSteamId);

	// Next up: Points from maps
	/*char szQuery[512];
	Format(szQuery, 512, "SELECT mapname, (select count(1)+1 from ck_playertimes b where a.mapname=b.mapname and a.runtimepro > b.runtimepro) AS rank, (SELECT count(1) FROM ck_playertimes b WHERE a.mapname = b.mapname AND b.style = 0) as total, (SELECT tier FROM `ck_maptier` b WHERE a.mapname = b.mapname) as tier FROM ck_playertimes a where steamid = '%s' AND style = 0", szSteamId);
	SQL_TQuery(g_hDb, sql_CountFinishedMapsCallback, szQuery, client, DBPrio_Low);*/
}

//
// 4. Calculate points gained from stages
// Fetched values
// mapname, stage, rank, total
//
public void sql_CountFinishedStagesCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (sql_CountFinishedStagesCallback): %s", error);
		return;
	}

	char szMap[128], szSteamId[32], szMapName2[128];
	//int totalplayers, rank;

	getSteamIDFromClient(client, szSteamId, 32);
	int finishedstages = 0;
	int rank;
	int wrcps = 0;

	if (SQL_HasResultSet(hndl))
	{
		while (SQL_FetchRow(hndl))
		{
			finishedstages++;
			// Total amount of players who have finished the bonus
			//totalplayers = SQL_FetchInt(hndl, 2);
			SQL_FetchString(hndl, 0, szMap, 128);
			rank = SQL_FetchInt(hndl, 2);
			for (int i = 0; i < GetArraySize(g_MapList); i++) // Check that the map is in the mapcycle
			{
				GetArrayString(g_MapList, i, szMapName2, sizeof(szMapName2));
				if (StrEqual(szMapName2, szMap, false))
				{
					switch (rank)
					{
						case 1: wrcps++;
					}
					/*switch (rank)
					{
						case 1:
						{
							g_pr_points[client] += 200;
							g_Points[client][4] += 200;
						}
						case 2:
						{
							g_pr_points[client] += 190;
							g_Points[client][1] += 190;
						}
						case 3:
						{
							g_pr_points[client] += 180;
							g_Points[client][1] += 180;
						}
						case 4:
						{
							g_pr_points[client] += 170;
							g_Points[client][1] += 170;
						}
						case 5:
						{
							g_pr_points[client] += 150;
							g_Points[client][1] += 150;
						}
						case 6:
						{
							g_pr_points[client] += 140;
							g_Points[client][1] += 140;
						}
						case 7:
						{
							g_pr_points[client] += 135;
							g_Points[client][1] += 135;
						}
						case 8:
						{
							g_pr_points[client] += 120;
							g_Points[client][1] += 120;
						}
						case 9:
						{
							g_pr_points[client] += 115;
							g_Points[client][1] += 115;
						}
						case 10:
						{
							g_pr_points[client] += 105;
							g_Points[client][1] += 105;
						}
						case 11:
						{
							g_pr_points[client] += 100;
							g_Points[client][1] += 100;
						}
						case 12:
						{
							g_pr_points[client] += 90;
							g_Points[client][1] += 90;
						}
						case 13:
						{
							g_pr_points[client] += 80;
							g_Points[client][1] += 80;
						}
						case 14:
						{
							g_pr_points[client] += 75;
							g_Points[client][1] += 75;
						}
						case 15:
						{
							g_pr_points[client] += 60;
							g_Points[client][1] += 60;
						}
						case 16:
						{
							g_pr_points[client] += 50;
							g_Points[client][1] += 50;
						}
						case 17:
						{
							g_pr_points[client] += 40;
							g_Points[client][1] += 40;
						}
						case 18:
						{
							g_pr_points[client] += 30;
							g_Points[client][1] += 30;
						}
						case 19:
						{
							g_pr_points[client] += 20;
							g_Points[client][1] += 20;
						}
						case 20:
						{
							g_pr_points[client] += 10;
							g_Points[client][1] += 10;
						}
					}*/
					break;
				}
			}
		}
	}

	g_pr_finishedstages[client] = finishedstages;
	g_WRs[client][2] = wrcps;

	// Next up: Points from maps
	char szQuery[512];
	Format(szQuery, 512, "SELECT mapname, (select count(1)+1 from ck_playertimes b where a.mapname=b.mapname and a.runtimepro > b.runtimepro AND b.style = 0) AS rank, (SELECT count(1) FROM ck_playertimes b WHERE a.mapname = b.mapname AND b.style = 0) as total, (SELECT tier FROM `ck_maptier` b WHERE a.mapname = b.mapname) as tier FROM ck_playertimes a where steamid = '%s' AND style = 0", szSteamId);
	SQL_TQuery(g_hDb, sql_CountFinishedMapsCallback, szQuery, client, DBPrio_Low);
}

//
// 5. Count the points gained from regular maps
// Fetching:
// mapname, rank, total, tier
//
public void sql_CountFinishedMapsCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (sql_CountFinishedMapsCallback): %s", error);
		return;
	}

	char szMap[128], szMapName2[128];
	int finishedMaps = 0, totalplayers, rank, tier, wrs;

	if (SQL_HasResultSet(hndl))
	{
		while (SQL_FetchRow(hndl))
		{
			// Total amount of players who have finished the map
			totalplayers = SQL_FetchInt(hndl, 2);
			// Rank in that map
			rank = SQL_FetchInt(hndl, 1);
			// Map name
			SQL_FetchString(hndl, 0, szMap, 128);
			// Map tier
			tier = SQL_FetchInt(hndl, 3);

			for (int i = 0; i < GetArraySize(g_MapList); i++) // Check that the map is in the mapcycle
			{
				GetArrayString(g_MapList, i, szMapName2, sizeof(szMapName2));
				if (StrEqual(szMapName2, szMap, false))
				{
					finishedMaps++;
					float wrpoints;
					int iwrpoints;
					float points;
					//bool wr;
					//bool top10;
					float g1points;
					float g2points;
					float g3points;
					float g4points;
					float g5points;

					// Calculate Group Ranks
					// Group 1
					float fG1top;
					int g1top;
					int g1bot = 11;
					fG1top = (float(totalplayers) * g_Group1Pc);
					fG1top += 11.0; // Rank 11 is always End of Group 1
					g1top = RoundToCeil(fG1top);

					int g1difference = (g1top - g1bot);
					if(g1difference < 4)
						g1top = (g1bot + 4);

					//Group 2
					float fG2top;
					int g2top;
					int g2bot;
					g2bot = g1top + 1;
					fG2top = (float(totalplayers) * g_Group2Pc);
					fG2top += 11.0;
					g2top = RoundToCeil(fG2top);

					int g2difference = (g2top - g2bot);
					if(g2difference < 4)
						g2top = (g2bot + 4);

					//Group 3
					float fG3top;
					int g3top;
					int g3bot;
					g3bot = g2top + 1;
					fG3top = (float(totalplayers) * g_Group3Pc);
					fG3top += 11.0;
					g3top = RoundToCeil(fG3top);

					int g3difference = (g3top - g3bot);
					if(g3difference < 4)
						g3top = (g3bot + 4);

					//Group 4
					float fG4top;
					int g4top;
					int g4bot;
					g4bot = g3top + 1;
					fG4top = (float(totalplayers) * g_Group4Pc);
					fG4top += 11.0;
					g4top = RoundToCeil(fG4top);

					int g4difference = (g4top - g4bot);
					if(g4difference < 4)
						g4top = (g4bot + 4);

					//Group 5
					float fG5top;
					int g5top;
					int g5bot;
					g5bot = g4top + 1;
					fG5top = (float(totalplayers) * g_Group5Pc);
					fG5top += 11.0;
					g5top = RoundToCeil(fG5top);

					int g5difference = (g5top - g5bot);
					if(g5difference < 4)
						g5top = (g5bot + 4);

					if(tier == 1)
					{
						wrpoints = ((float(totalplayers) * 1.75) / 6);
						wrpoints += 58.5;
					}
					else if(tier == 2)
					{
						wrpoints = ((float(totalplayers) * 2.8) / 5);
						wrpoints += 82.15;
					}
					else if(tier == 3)
					{
						wrpoints = ((float(totalplayers) * 3.5) / 4);
						if (wrpoints < 300)
							wrpoints = 350.0;
						else
							wrpoints += 117;
					}
					else if(tier == 4)
					{
						wrpoints = ((float(totalplayers) * 5.74) / 4);
						if (wrpoints < 400)
							wrpoints = 400.0;
						else
							wrpoints += 164.25;
					}
					else if(tier == 5)
					{
						wrpoints = ((float(totalplayers) * 7) / 4);
						if (wrpoints < 500)
							wrpoints = 500.0;
						else
							wrpoints += 234;
					}
					else if(tier == 6)
					{
						wrpoints = ((float(totalplayers) * 14) / 4);
						if (wrpoints < 600)
							wrpoints = 600.0;
						else
							wrpoints += 328;
					}
					else // no tier set
						wrpoints = 25.0;

					// Round WR points up
					iwrpoints = RoundToCeil(wrpoints);

					// Top 10 Points
					if(rank < 11)
					{
						g_Top10Maps[client]++;
						if (rank == 1)
						{
							g_pr_points[client] += iwrpoints;
							g_Points[client][3] += iwrpoints;
							wrs++;
						}
						else if(rank == 2)
						{
							points = (0.80 * iwrpoints);
							g_pr_points[client] += RoundToCeil(points);
							g_Points[client][5] += RoundToCeil(points);
						}
						else if(rank == 3)
						{
							points = (0.75 * iwrpoints);
							g_pr_points[client] += RoundToCeil(points);
							g_Points[client][5] += RoundToCeil(points);
						}
						else if(rank == 4)
						{
							points = (0.70 * iwrpoints);
							g_pr_points[client] += RoundToCeil(points);
							g_Points[client][5] += RoundToCeil(points);
						}
						else if(rank == 5)
						{
							points = (0.65 * iwrpoints);
							g_pr_points[client] += RoundToCeil(points);
							g_Points[client][5] += RoundToCeil(points);
						}
						else if(rank == 6)
						{
							points = (0.60 * iwrpoints);
							g_pr_points[client] += RoundToCeil(points);
							g_Points[client][5] += RoundToCeil(points);
						}
						else if(rank == 7)
						{
							points = (0.55 * iwrpoints);
							g_pr_points[client] += RoundToCeil(points);
							g_Points[client][5] += RoundToCeil(points);
						}
						else if(rank == 8)
						{
							points = (0.50 * iwrpoints);
							g_pr_points[client] += RoundToCeil(points);
							g_Points[client][5] += RoundToCeil(points);
						}
						else if(rank == 9)
						{
							points = (0.45 * iwrpoints);
							g_pr_points[client] += RoundToCeil(points);
							g_Points[client][5] += RoundToCeil(points);
						}
						else if(rank == 10)
						{
							points = (0.40 * iwrpoints);
							g_pr_points[client] += RoundToCeil(points);
							g_Points[client][5] += RoundToCeil(points);
						}
					}
					// Group Points
					else if(rank > 10 && rank <= g5top)
					{
						g_GroupMaps[client] += 1;
						// Calculate Group Points
						g1points = (iwrpoints * 0.25);
						g2points = (g1points / 1.5);
						g3points = (g2points / 1.5);
						g4points = (g3points / 1.5);
						g5points = (g4points / 1.5);

						if(rank >= g1bot && rank <= g1top) // Group 1
						{
							g_pr_points[client] += RoundFloat(g1points);
							g_Points[client][2] += RoundFloat(g1points);
						}
						else if(rank >= g2bot && rank <= g2top) // Group 2
						{
							g_pr_points[client] += RoundFloat(g2points);
							g_Points[client][2] += RoundFloat(g2points);
						}
						else if(rank >= g3bot && rank <= g3top) // Group 3
						{
							g_pr_points[client] += RoundFloat(g3points);
							g_Points[client][2] += RoundFloat(g3points);
						}
						else if(rank >= g4bot && rank <= g4top) // Group 4
						{
							g_pr_points[client] += RoundFloat(g4points);
							g_Points[client][2] += RoundFloat(g4points);
						}
						else if(rank >= g5bot && rank <= g5top) // Group 5
						{
							g_pr_points[client] += RoundFloat(g5points);
							g_Points[client][2] += RoundFloat(g5points);
						}
					}

					// Map Completiton Points
					if(tier == 1)
					{
						g_pr_points[client] += 25;
						g_Points[client][0] += 25;
					}
					else if(tier == 2)
					{
						g_pr_points[client] += 50;
						g_Points[client][0] += 50;
					}
					else if(tier == 3)
					{
						g_pr_points[client] += 100;
						g_Points[client][0] += 100;
					}
					else if(tier == 4)
					{
						g_pr_points[client] += 200;
						g_Points[client][0] += 200;
					}
					else if(tier == 5)
					{
						g_pr_points[client] += 400;
						g_Points[client][0] += 400;
					}
					else if(tier == 6)
					{
						g_pr_points[client] += 600;
						g_Points[client][0] += 600;
					}
					else // no tier
					{
						g_pr_points[client] += 13;
						g_Points[client][0] += 13;
					}

					break;
				}
			}
		}
	}
	// Finished maps amount is stored in memory
	g_pr_finishedmaps[client] = finishedMaps;
	// Percentage of maps finished
	g_pr_finishedmaps_perc[client] = (float(finishedMaps) / float(g_pr_MapCount)) * 100.0;

	//wrs
	g_WRs[client][0] = wrs;

	int totalperc = g_pr_finishedstages[client] + g_pr_finishedbonuses[client] + g_pr_finishedmaps[client];
	int totalcomp = g_pr_StageCount + g_pr_BonusCount + g_pr_MapCount;
	float ftotalperc;

	ftotalperc = (float(totalperc) / (float(totalcomp))) * 100.0;

	if (IsValidClient(client) && !IsFakeClient(client))
		CS_SetMVPCount(client, (RoundFloat(ftotalperc)));

	// Done checking, update points
	db_updatePoints(client);

}

//
// 6. Updating points to database
//
public void db_updatePoints(int client)
{
	char szQuery[512];
	char szName[MAX_NAME_LENGTH * 2 + 1];
	char szSteamId[32];
	if (client > MAXPLAYERS && g_pr_RankingRecalc_InProgress || client > MAXPLAYERS && g_bProfileRecalc[client])
	{
		SQL_EscapeString(g_hDb, g_pr_szName[client], szName, MAX_NAME_LENGTH * 2 + 1);
		Format(szQuery, 512, sql_updatePlayerRankPoints, szName, g_pr_points[client], g_Points[client][3], g_Points[client][4], g_Points[client][5], g_Points[client][2], g_Points[client][0], g_Points[client][1], g_pr_finishedmaps[client], g_pr_finishedbonuses[client], g_pr_finishedstages[client], g_WRs[client][0], g_WRs[client][1], g_WRs[client][2], g_Top10Maps[client], g_GroupMaps[client], g_pr_szSteamID[client]);
		SQL_TQuery(g_hDb, sql_updatePlayerRankPointsCallback, szQuery, client, DBPrio_Low);
	}
	else
	{
		if (IsValidClient(client))
		{
			GetClientName(client, szName, MAX_NAME_LENGTH);
			GetClientAuthId(client, AuthId_Steam2, szSteamId, MAX_NAME_LENGTH, true);
			//GetClientAuthString(client, szSteamId, MAX_NAME_LENGTH);
			Format(szQuery, 512, sql_updatePlayerRankPoints2, szName, g_pr_points[client], g_Points[client][3], g_Points[client][4], g_Points[client][5], g_Points[client][2], g_Points[client][0], g_Points[client][1], g_pr_finishedmaps[client], g_pr_finishedbonuses[client], g_pr_finishedstages[client], g_WRs[client][0], g_WRs[client][1], g_WRs[client][2], g_Top10Maps[client], g_GroupMaps[client], g_szCountry[client], szSteamId);
			SQL_TQuery(g_hDb, sql_updatePlayerRankPointsCallback, szQuery, client, DBPrio_Low);
		}
	}
}

//
// 7. Calculations done, if calculating all, move forward, if not announce changes.
//
public void sql_updatePlayerRankPointsCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (sql_updatePlayerRankPointsCallback): %s", error);
		return;
	}

	// If was recalculating points, go to the next player, announce or end calculating
	if (data > MAXPLAYERS && g_pr_RankingRecalc_InProgress || data > MAXPLAYERS && g_bProfileRecalc[data])
	{
		if (g_bProfileRecalc[data] && !g_pr_RankingRecalc_InProgress)
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i))
				{
					if (StrEqual(g_szSteamID[i], g_pr_szSteamID[data]))
					CalculatePlayerRank(i);
				}
			}
		}
		g_bProfileRecalc[data] = false;
		if (g_pr_RankingRecalc_InProgress)
		{
			//console info
			if (IsValidClient(g_pr_Recalc_AdminID) && g_bManualRecalc)
			PrintToConsole(g_pr_Recalc_AdminID, "%i/%i", g_pr_Recalc_ClientID, g_pr_TableRowCount);
			int x = 66 + g_pr_Recalc_ClientID;
			if (StrContains(g_pr_szSteamID[x], "STEAM", false) != -1)
			{
				ContinueRecalc(x);
			}
			else
			{
				for (int i = 1; i <= MaxClients; i++)
				if (1 <= i <= MaxClients && IsValidEntity(i) && IsValidClient(i))
				{
					if (g_bManualRecalc)
					PrintToChat(i, "%t", "PrUpdateFinished", LIMEGREEN, WHITE, LIMEGREEN);
				}
				g_bManualRecalc = false;
				g_pr_RankingRecalc_InProgress = false;

				if (IsValidClient(g_pr_Recalc_AdminID))
				CreateTimer(0.1, RefreshAdminMenu, g_pr_Recalc_AdminID, TIMER_FLAG_NO_MAPCHANGE);
			}
			g_pr_Recalc_ClientID++;
		}
	}
	else // Gaining points normally
	{
		// Player recalculated own points in !profile
		if (g_bRecalcRankInProgess[data] && data <= MAXPLAYERS)
		{
			ProfileMenu(data, -1, 0);
			if (IsValidClient(data))
			PrintToChat(data, "%t", "Rc_PlayerRankFinished", LIMEGREEN, WHITE, GRAY, PURPLE, g_pr_points[data], GRAY);
			g_bRecalcRankInProgess[data] = false;
		}
		if (IsValidClient(data) && g_pr_showmsg[data]) // Player gained points
		{
			char szName[MAX_NAME_LENGTH];
			GetClientName(data, szName, MAX_NAME_LENGTH);
			int diff = g_pr_points[data] - g_pr_oldpoints[data];
			if (diff > 0) // if player earned points -> Announce
			{
				for (int i = 1; i <= MaxClients; i++)
				if (IsValidClient(i))
				PrintToChat(i, "%t", "EarnedPoints", LIMEGREEN, WHITE, PURPLE, szName, GRAY, PURPLE, diff, GRAY, PURPLE, g_pr_points[data], GRAY);
			}
			g_pr_showmsg[data] = false;
			db_CalculatePlayersCountGreater0();
		}
		g_pr_Calculating[data] = false;
		db_GetPlayerRank(data);
		CreateTimer(1.0, SetClanTag, data, TIMER_FLAG_NO_MAPCHANGE);
	}
}

//
// Called when player joins server
//
public void db_viewPlayerPoints(int client)
{
	g_pr_finishedmaps[client] = 0;
	g_pr_finishedmaps_perc[client] = 0.0;
	g_pr_points[client] = 0;
	g_iPlayTimeAlive[client] = 0;
	g_iPlayTimeSpec[client] = 0;
	g_iTotalConnections[client] = 1;
	char szQuery[255];
	if (!IsValidClient(client))
	return;

	//"SELECT steamid, name, points, finishedmapspro, country, lastseen, timealive, timespec, connections from ck_playerrank where steamid='%s'";
	Format(szQuery, 255, sql_selectRankedPlayer, g_szSteamID[client]);
	SQL_TQuery(g_hDb, db_viewPlayerPointsCallback, szQuery, client, DBPrio_Low);
}

public void db_viewPlayerPointsCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (db_viewPlayerPointsCallback): %s", error);
		if (!g_bSettingsLoaded[client])
			LoadClientSetting(client, g_iSettingToLoad[client]);
		return;
	}
	//SELECT steamid, name, points, finishedmapspro, country, lastseen, timealive, timespec, connections from ck_playerrank where steamid='%s';
	// Old player - get points
	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		g_pr_points[client] = SQL_FetchInt(hndl, 2);
		g_pr_finishedmaps[client] = SQL_FetchInt(hndl, 3);
		g_pr_finishedmaps_perc[client] = (float(g_pr_finishedmaps[client]) / float(g_pr_MapCount)) * 100.0;

		g_iPlayTimeAlive[client] = SQL_FetchInt(hndl, 6);
		g_iPlayTimeSpec[client] = SQL_FetchInt(hndl, 7);
		g_iTotalConnections[client] = SQL_FetchInt(hndl, 8);

		g_iTotalConnections[client]++;

		char updateConnections[1024];
		Format(updateConnections, 1024, "UPDATE ck_playerrank SET connections = connections + 1 WHERE steamid = '%s';", g_szSteamID[client]);
		SQL_TQuery(g_hDb, SQL_CheckCallback, updateConnections, DBPrio_Low);

		// Debug
		g_fTick[client][1] = GetGameTime();
		float tick = g_fTick[client][1] - g_fTick[client][0];
		LogToFileEx(g_szLogFile, "[Surftimer] %s: Finished db_viewPlayerPoints in %fs", g_szSteamID[client], tick);
		g_fTick[client][0] = GetGameTime();

		if (IsValidClient(client)) // Count players rank
			db_GetPlayerRank(client);
	}
	else
	{  // New player - insert
		if (IsValidClient(client))
		{
			//insert
			char szQuery[512];
			char szUName[MAX_NAME_LENGTH];

			if (IsValidClient(client))
			GetClientName(client, szUName, MAX_NAME_LENGTH);
			else
			return;

			// SQL injection protection
			char szName[MAX_NAME_LENGTH * 2 + 1];
			SQL_EscapeString(g_hDb, szUName, szName, MAX_NAME_LENGTH * 2 + 1);

			char szSteamId64[64];
			GetClientAuthId(client, AuthId_SteamID64, szSteamId64, MAX_NAME_LENGTH, true);

			Format(szQuery, 512, sql_insertPlayerRank, g_szSteamID[client], szSteamId64, szName, g_szCountry[client], GetTime());
			SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, DBPrio_Low);

			// Play time
			g_iPlayTimeAlive[client] = 0;
			g_iPlayTimeSpec[client] = 0;

			// Debug
			g_fTick[client][1] = GetGameTime();
			float tick = g_fTick[client][1] - g_fTick[client][0];
			LogToFileEx(g_szLogFile, "[Surftimer] %s: Finished db_viewPlayerPoints in %fs", g_szSteamID[client], tick);
			g_fTick[client][0] = GetGameTime();

			db_GetPlayerRank(client); // Count players rank
		}
	}
}

//
// Get the amount of palyers, who have more points
//
public void db_GetPlayerRank(int client)
{
	char szQuery[512];
	//"SELECT name FROM ck_playerrank WHERE points >= (SELECT points FROM ck_playerrank WHERE steamid = '%s') ORDER BY points";
	Format(szQuery, 512, sql_selectRankedPlayersRank, g_szSteamID[client]);
	SQL_TQuery(g_hDb, sql_selectRankedPlayersRankCallback, szQuery, client, DBPrio_Low);
}

public void sql_selectRankedPlayersRankCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (sql_selectRankedPlayersRankCallback): %s", error);
		if (!g_bSettingsLoaded[client])
			LoadClientSetting(client, g_iSettingToLoad[client]);
		return;
	}

	if (!IsValidClient(client))
	return;

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		g_PlayerRank[client] = SQL_GetRowCount(hndl);

		if (GetConVarInt(g_hPrestigeRank) != 0)
		{
			if (g_PlayerRank[client] > GetConVarInt(g_hPrestigeRank))
				KickClient(client, "You must be at least rank %i to join this server", GetConVarInt(g_hPrestigeRank));
		}

		// Custom Title Access
		if(g_PlayerRank[client] <= 3 && g_PlayerRank[client] > 0) // Rank 1-3
			g_bCustomTitleAccess[client] = true;

		// Sort players by rank in scoreboard
		if (g_pr_AllPlayers < g_PlayerRank[client])
			CS_SetClientContributionScore(client, -99999);
		else
			CS_SetClientContributionScore(client, -g_PlayerRank[client]);
		//CS_SetClientContributionScore(client, (g_pr_AllPlayers - SQL_GetRowCount(hndl)));
	}

	if (!g_bSettingsLoaded[client])
	{
		g_fTick[client][1] = GetGameTime();
		float tick = g_fTick[client][1] - g_fTick[client][0];
		LogToFileEx(g_szLogFile, "[Surftimer] %s: Finished db_GetPlayerRank in %fs", g_szSteamID[client], tick);
		g_fTick[client][0] = GetGameTime();

		LoadClientSetting(client, g_iSettingToLoad[client]);
	}
}

public void db_viewPlayerRank(int client, char szSteamId[32])
{
	char szQuery[512];
	Format(g_pr_szrank[client], 512, "");
	Format(szQuery, 512, sql_selectRankedPlayer, szSteamId);
	SQL_TQuery(g_hDb, SQL_ViewRankedPlayerCallback, szQuery, client, DBPrio_Low);
}

public void SQL_ViewRankedPlayerCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_ViewRankedPlayerCallback): %s", error);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		char szQuery[512];
		char szName[MAX_NAME_LENGTH];
		char szCountry[100];
		char szLastSeen[100];
		char szSteamId[32];
		int finishedmapspro;
		int points;
		g_MapRecordCount[data] = 0;

		//get the result SELECT steamid, name, points, finishedmapspro, country, lastseen from ck_playerrank where steamid='%s';
		SQL_FetchString(hndl, 0, szSteamId, 32);
		SQL_FetchString(hndl, 1, szName, MAX_NAME_LENGTH);
		points = SQL_FetchInt(hndl, 2);
		finishedmapspro = SQL_FetchInt(hndl, 3);
		SQL_FetchString(hndl, 4, szCountry, 100);
		SQL_FetchString(hndl, 5, szLastSeen, 100);
		Handle pack_pr = CreateDataPack();
		WritePackString(pack_pr, szName);
		WritePackString(pack_pr, szSteamId);
		WritePackCell(pack_pr, data);
		WritePackCell(pack_pr, points);
		WritePackCell(pack_pr, finishedmapspro);
		WritePackString(pack_pr, szCountry);
		WritePackString(pack_pr, szLastSeen);
		Format(szQuery, 512, sql_selectRankedPlayersRank, szSteamId);
		SQL_TQuery(g_hDb, SQL_ViewRankedPlayerCallback2, szQuery, pack_pr, DBPrio_Low);
	}
}

public void SQL_ViewRankedPlayerCallback2(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_ViewRankedPlayerCallback2): %s", error);
		return;
	}


	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		int rank = SQL_GetRowCount(hndl);
		char szQuery[512];
		char szSteamId[32];
		char szName[MAX_NAME_LENGTH];

		WritePackCell(data, rank);
		ResetPack(data);
		ReadPackString(data, szName, MAX_NAME_LENGTH);
		ReadPackString(data, szSteamId, 32);

		Format(szQuery, 512, "SELECT COUNT(`steamid`) FROM `ck_bonus` WHERE `steamid` = '%s' AND style = 0;", szSteamId); //fluffys
		SQL_TQuery(g_hDb, SQL_ViewRankedPlayerCallbackBonus, szQuery, data, DBPrio_Low);
	}
	else
	{
		CloseHandle(data);
	}
}

//fluffys add bonus count callback
public void SQL_ViewRankedPlayerCallbackBonus(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_ViewRankedPlayerCallbackBonus): %s", error);
		return;
	}

	char szSteamId[32];
	char szName[MAX_NAME_LENGTH];
	ResetPack(data);
	ReadPackString(data, szName, MAX_NAME_LENGTH);
	ReadPackString(data, szSteamId, 32);
	int client = ReadPackCell(data);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		char szQuery[512];
		//get the result
		g_totalBonusTimes[client] = SQL_FetchInt(hndl, 0); //fluffys pack full i think
		Format(szQuery, 512, "SELECT COUNT(runtimepro) AS totalstages FROM ck_wrcps WHERE steamid = '%s' AND style = 0;", szSteamId);
		SQL_TQuery(g_hDb, SQL_ViewRankedPlayerStageTotalCallback, szQuery, data, DBPrio_Low);
	}
	else
	{
		CloseHandle(data);
	}
}

//fluffys add bonus count callback
public void SQL_ViewRankedPlayerStageTotalCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_ViewRankedPlayerStageTotalCallback): %s", error);
		return;
	}

	char szSteamId[32];
	char szName[MAX_NAME_LENGTH];
	ResetPack(data);
	ReadPackString(data, szName, MAX_NAME_LENGTH);
	ReadPackString(data, szSteamId, 32);
	int client = ReadPackCell(data);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		char szQuery[512];
		//get the result
		g_totalStageTimes[client] = SQL_FetchInt(hndl, 0); //fluffys pack full i think
		Format(szQuery, 512, sql_selectMapRecordCount, szSteamId);
		SQL_TQuery(g_hDb, SQL_ViewRankedPlayerCallback4, szQuery, data, DBPrio_Low);
	}
	else
	{
		CloseHandle(data);
	}
}

public void SQL_ViewRankedPlayerCallback4(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_ViewRankedPlayerCallback4): %s", error);
		return;
	}

	char szQuery[512];
	char szSteamId[32];
	char szName[MAX_NAME_LENGTH];

	ResetPack(data);
	ReadPackString(data, szName, MAX_NAME_LENGTH);
	ReadPackString(data, szSteamId, 32);
	int client = ReadPackCell(data);
	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	g_MapRecordCount[client] = SQL_FetchInt(hndl, 1); //pack full?
	Format(szQuery, 512, "SELECT y.steamid, y.name, COUNT(*) AS wrbs FROM (SELECT s.steamid, s.name, s.style FROM ck_bonus s INNER JOIN (SELECT mapname, style, MIN(runtime) AS runtime FROM ck_bonus where runtime > -1.0  GROUP BY mapname) x ON s.mapname = x.mapname AND s.runtime = x.runtime) y WHERE steamid = '%s' AND style = 0", szSteamId); //fluffys
	/*SQL_TQuery(g_hDb, SQL_ViewRankedPlayerCallback5, szQuery, data, DBPrio_Low);*/ //fluffys come back (old)
	SQL_TQuery(g_hDb, SQL_ViewRankedPlayerCallback5, szQuery, data, DBPrio_Low);
}
//SQL_ViewRankedPlayerStageRecordsCallback
/*Format(szQuery, 512, sql_selectMapRecordCount, szSteamId);
SQL_TQuery(g_hDb, SQL_ViewRankedPlayerCallback4, szQuery, data, DBPrio_Low);*/
public void SQL_ViewRankedPlayerCallback5(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_ViewRankedPlayerCallback5): %s", error);
		return;
	}

	char szQuery[512];
	char szSteamId[32];
	char szName[MAX_NAME_LENGTH];

	ResetPack(data);
	ReadPackString(data, szName, MAX_NAME_LENGTH);
	ReadPackString(data, szSteamId, 32);
	int client = ReadPackCell(data);
	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
		g_BonusRecordCount[client] = SQL_FetchInt(hndl, 2); //pack full?
	Format(szQuery, 512, "SELECT mapname, stage, (select count(1)+1 from ck_wrcps b where a.mapname=b.mapname and a.runtimepro > b.runtimepro AND b.style = 0 and a.stage = b.stage) AS rank, (SELECT count(1) FROM ck_wrcps b WHERE a.mapname = b.mapname and b.style = 0 and a.stage = b.stage) as total FROM ck_wrcps a where steamid = '%s' AND style = 0", szSteamId); //fluffys
	/*SQL_TQuery(g_hDb, SQL_ViewRankedPlayerCallback5, szQuery, data, DBPrio_Low);*/ //fluffys come back (old)
	SQL_TQuery(g_hDb, SQL_ViewRankedPlayerCallback6, szQuery, data, DBPrio_Low);
}

public void SQL_ViewRankedPlayerCallback6(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_ViewRankedPlayerCallback6): %s", error);
		return;
	}

	char szName[MAX_NAME_LENGTH];
	char szSteamId[32];
	char szCountry[100];
	char szLastSeen[100];
	char szSkillGroup[32];

	ResetPack(data);
	ReadPackString(data, szName, MAX_NAME_LENGTH);
	ReadPackString(data, szSteamId, 32);
	int client = ReadPackCell(data);
	int points = ReadPackCell(data);
	int finishedmapspro = ReadPackCell(data);
	ReadPackString(data, szCountry, 100);
	ReadPackString(data, szLastSeen, 100);
	if (StrEqual(szLastSeen, ""))
		Format(szLastSeen, 100, "Unknown");
	int rank = ReadPackCell(data);
	int prorecords = g_MapRecordCount[client];
	Format(g_szProfileSteamId[client], 32, "%s", szSteamId);
	Format(g_szProfileName[client], MAX_NAME_LENGTH, "%s", szName);

	//fluffys map percentage
	float fperc;
	float bfperc;
	char szPerc[32];
	char szBPerc[32];
	char szStagePerc[32];
	char szTotalPerc[32];
	fperc = (float(finishedmapspro) / (float(g_pr_MapCount))) * 100.0;
	int finishedbonuses = g_totalBonusTimes[client];
	int target = g_ClientProfile[client];
	char percent[2]; //fluffys percent wont print !!
	percent = "%%";

	if (fperc < 10.0)
	Format(szPerc, 32, "%.1f", fperc);
	else
	if (fperc == 100.0)
	Format(szPerc, 32, "100.0");
	else
	if (fperc > 100.0) //player profile not refreshed after removing maps
	Format(szPerc, 32, "100.0");
	else
	Format(szPerc, 32, "%.1f", fperc);

	bfperc = (float(finishedbonuses) / (float(g_pr_BonusCount))) * 100.0;

	if (bfperc < 10.0)
	Format(szBPerc, 32, "%.1f", bfperc);
	else
	if (bfperc == 100.0)
	Format(szBPerc, 32, "100.0");
	else
	if (bfperc > 100.0) //player profile not refreshed after removing maps
	Format(szBPerc, 32, "100.0");
	else
	Format(szBPerc, 32, "%.1f", bfperc);


	CloseHandle(data);

	if (StrEqual(szSteamId, g_szSteamID[client]))
		g_PlayerRank[client] = rank;

	g_StageRecordCount[client] = 0;


	if (SQL_HasResultSet(hndl))
	{
		int stagerank;
		while (SQL_FetchRow(hndl))
		{
			stagerank = SQL_FetchInt(hndl, 2);
			if (stagerank == 1)
				g_StageRecordCount[client]++;
		}
	}

	int bonusrecords = g_BonusRecordCount[client];
	int stagerecords = g_StageRecordCount[client];

	int playerstages = g_totalStageTimes[client];
	int totalstages = g_pr_StageCount;
	float stagefperc;

	stagefperc = (float(playerstages) / (float(totalstages))) * 100.0;

	if (stagefperc < 10.0)
		Format(szStagePerc, 32, "%.1f", stagefperc);
	else if (stagefperc == 100.0)
		Format(szStagePerc, 32, "100.0");
	else if (stagefperc > 100.0) //player profile not refreshed after removing maps
		Format(szStagePerc, 32, "100.0");
	else
		Format(szStagePerc, 32, "%.1f", stagefperc);

	int totalperc = playerstages + finishedbonuses + finishedmapspro;
	int totalcomp = totalstages + g_pr_BonusCount + g_pr_MapCount;
	float ftotalperc;

	ftotalperc = (float(totalperc) / (float(totalcomp))) * 100.0;

	if (ftotalperc < 10.0)
		Format(szTotalPerc, 32, "%.1f", ftotalperc);
	else if (ftotalperc >= 100.0)
		Format(szTotalPerc, 32, "100.0");
	else
		Format(szTotalPerc, 32, "%.1f", ftotalperc);


	if (finishedmapspro > g_pr_MapCount)
		finishedmapspro = g_pr_MapCount;

	//fluffys ksf style Ranking
	GetRankName(client, rank, points, szSkillGroup, 32);
	//Format(szSkillGroup, 32, "%s", );

	char szRank[32];
	if (rank > g_pr_RankedPlayers || points == 0)
	Format(szRank, 32, "-");
	else
	Format(szRank, 32, "%i", rank);

	char szRanking[255];
	Format(szRanking, 255, "");
	char szCompleted[1024];
	char szMapPoints[128];
	char szBonusPoints[128];
	char szTop10Points[128];
	char szStagePc[128];
	char szMiPc[128];
	char szRecords[128];

	if(g_bProfileInServer[client])
	{
		Format(szMapPoints, 128, "Maps: %i/%i - [%i] (%s%c)", finishedmapspro, g_pr_MapCount, g_Points[target][0], szPerc, PERCENT);

		if(g_Points[target][4] > 0)
			Format(szBonusPoints, 128, "Bonuses: %i/%i - [%i+%i] (%s%c)", finishedbonuses, g_pr_BonusCount, g_Points[target][1], g_Points[target][4], szBPerc, PERCENT);
		else
			Format(szBonusPoints, 128, "Bonuses: %i/%i - [%i] (%s%c)", finishedbonuses, g_pr_BonusCount, g_Points[target][1], szBPerc, PERCENT);

		if(g_Points[target][3] > 0)
			Format(szTop10Points, 128, "Top10: %i - [%i+%i]", g_Top10Maps[target], g_Points[target][5], g_Points[target][3]);
		else
			Format(szTop10Points, 128, "Top10: %i - [%i]", g_Top10Maps[target], g_Points[target][5]);

		Format(szStagePc, 128, "Stages: %i/%i (%s%c)", playerstages, totalstages, szStagePerc, PERCENT);

		Format(szMiPc, 128, "Map Improvement Pts: %i - [%i]", g_GroupMaps[target], g_Points[target][2]);

		Format(szRecords, 128, "Records:\nMap WR: %i\nStage WR: %i\nBonus WR: %i", prorecords, stagerecords, bonusrecords);

		Format(szCompleted, 1024, "Completed - Points (%s%c):\n%s\n%s\n%s\n%s\n \n%s\n \n%s\n \n", szTotalPerc, PERCENT, szMapPoints, szBonusPoints, szTop10Points, szStagePc, szMiPc, szRecords);

		Format(g_pr_szrank[client], 512, "Rank: %s/%i (%s)\nTotal pts: %ip\n \n", szRank, g_pr_RankedPlayers, szSkillGroup, points);
	}
	else
	{
		Format(g_pr_szrank[client], 512, "Rank: %s/%i (%s)\nTotal pts: %ip \n \nCompleted:\nMaps: %i/%i (%s%s)\nStages: %i/%i (%s%s)\nBonuses: %i/%i (%s%s)\n \nRecords:\nMap WR: %i\nStage WR: %i\nBonus WR: %i\n ", szRank, g_pr_RankedPlayers, szSkillGroup, points, finishedmapspro, g_pr_MapCount, szPerc, percent, playerstages, totalstages, szStagePerc, percent, finishedbonuses, g_pr_BonusCount, szBPerc, percent, prorecords, stagerecords, bonusrecords);
	}

	char szID[32][2];
	ExplodeString(szSteamId, "_", szID, 2, 32);
	char szTitle[1024];
	if (GetConVarBool(g_hCountry))
	Format(szTitle, 1024, "[%s ||| Online: %s]\n-------------------------------------\nSTEAM_%s\nCountry: %s\n \n%s\n", szName, szLastSeen, szID[1], szCountry, g_pr_szrank[client]);
	else
	Format(szTitle, 1024, "[%s ||| Online: %s]\n-------------------------------------\nSTEAM_%s\n \n%s", szName, szLastSeen, szID[1], g_pr_szrank[client]);

	Menu profileMenu = new Menu(ProfileMenuHandler);
	profileMenu.SetTitle(szTitle);
	if(g_bProfileInServer[client])
		profileMenu.AddItem("Finished maps", szCompleted);
	else
		profileMenu.AddItem("Finished Maps", "Finished maps");

	profileMenu.AddItem(szSteamId, "Player Info");

	if (IsValidClient(client))
	{
		if (StrEqual(szSteamId, g_szSteamID[client]))
		{
			if (GetConVarBool(g_hPointSystem))
				profileMenu.AddItem("Refresh my profile", "Refresh my profile");
		}
	}
	profileMenu.ExitButton = true;
	profileMenu.Display(client, MENU_TIME_FOREVER);
}

public int ProfileMenuHandler(Handle menu, MenuAction action, int client, int item)
{
	if (action == MenuAction_Select)
	{
		switch (item)
		{
			case 0: completionMenu(client);
			case 1:
			{
				char szSteamId[32];
				GetMenuItem(menu, item, szSteamId, 32);
				db_viewPlayerInfo(client, szSteamId);
			}
			case 2:
			{
				if (g_bRecalcRankInProgess[client])
				{
					PrintToChat(client, " %cSurftimer %c| %cRecalculation in progress. Please wait!", LIMEGREEN, WHITE, GRAY);
				}
				else
				{
					g_bRecalcRankInProgess[client] = true;
					PrintToChat(client, "%t", "Rc_PlayerRankStart", LIMEGREEN, WHITE, GRAY);
					CalculatePlayerRank(client);
				}
			}
		}
	}
	else if (action == MenuAction_Cancel)
	{
		if (1 <= client <= MaxClients && IsValidClient(client))
		{
			switch (g_MenuLevel[client])
			{
				case 0:db_selectTopPlayers(client);
				case 3:db_viewWrcpMap(client, g_szWrcpMapSelect[client]);
				case 9:db_selectProSurfers(client);
				case 11:db_selectTopProRecordHolders(client);

			}
			if (g_MenuLevel[client] < 0)
			{
				if (g_bSelectProfile[client])
				ProfileMenu(client, 0, 0);
			}
		}
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public void completionMenu(int client)
{
	char szTitle[128];
	Format(szTitle, 128, "[%s | Completion Menu]\n \n", g_szProfileName[client]);
	Menu theCompletionMenu = new Menu(CompletionMenuHandler);
	SetMenuTitle(theCompletionMenu, szTitle);
	AddMenuItem(theCompletionMenu, "Complete Maps", "Complete Maps");
	AddMenuItem(theCompletionMenu, "Incomplete Maps", "Incomplete Maps");
	AddMenuItem(theCompletionMenu, "Top 10 Maps", "Top 10 Maps");
	AddMenuItem(theCompletionMenu, "WRs", "WRs");
	SetMenuExitBackButton(theCompletionMenu, true);
	DisplayMenu(theCompletionMenu, client, MENU_TIME_FOREVER);
}

public int CompletionMenuHandler(Handle menu, MenuAction action, int client, int item)
{
	if (action == MenuAction_Select)
	{
		switch (item)
		{
			case 0:db_viewAllRecords(client, g_szProfileSteamId[client]);
			case 1:db_viewUnfinishedMaps(client, g_szProfileSteamId[client]);
			case 2:db_viewTop10Records(client, g_szProfileSteamId[client], 0);
			case 3:db_viewTop10Records(client, g_szProfileSteamId[client], 1);
		}
	}
	else if (action == MenuAction_Cancel)
		db_viewPlayerRank(client, g_szProfileSteamId[client]);
	else if (action == MenuAction_End)
		CloseHandle(menu);
}


public void db_viewPlayerAll(int client, char szPlayerName[MAX_NAME_LENGTH])
{
	char szQuery[512];
	char szName[MAX_NAME_LENGTH * 2 + 1];
	SQL_EscapeString(g_hDb, szPlayerName, szName, MAX_NAME_LENGTH * 2 + 1);
	Format(szQuery, 512, sql_selectPlayerRankAll, PERCENT, szName, PERCENT);
	SQL_TQuery(g_hDb, SQL_ViewPlayerAllCallback, szQuery, client, DBPrio_Low);
}


public void SQL_ViewPlayerAllCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_ViewPlayerAllCallback): %s", error);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		SQL_FetchString(hndl, 1, g_szProfileSteamId[data], 32);
		db_viewPlayerRank(data, g_szProfileSteamId[data]);
	}
	else
	if (IsClientInGame(data))
	PrintToChat(data, "%t", "PlayerNotFound", LIMEGREEN, WHITE, g_szProfileName[data]);
}

public void ContinueRecalc(int client)
{
	//ON RECALC ALL
	if (client > MAXPLAYERS)
	CalculatePlayerRank(client);
	else
	{
		//ON CONNECT
		if (!IsValidClient(client) || IsFakeClient(client))
		return;
		float diff = GetGameTime() - g_fMapStartTime + 1.5;
		if (GetClientTime(client) < diff)
		{
			CalculatePlayerRank(client);
		}
		else
		{
			db_viewPlayerPoints(client);
		}
	}
}

public void TopTpHoldersHandler1(Handle menu, MenuAction action, int param1, int param2)
{

	if (action == MenuAction_Select)
	{
		char info[32];
		GetMenuItem(menu, param2, info, sizeof(info));
		g_MenuLevel[param1] = 10;
		db_viewPlayerRank(param1, info);
	}

	if (action == MenuAction_Cancel)
	{
		ckTopMenu(param1);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public int TopProHoldersHandler1(Handle menu, MenuAction action, int client, int item)
{

	if (action == MenuAction_Select)
	{
		char info[32];
		GetMenuItem(menu, item, info, sizeof(info));
		g_MenuLevel[client] = 11;
		db_viewPlayerRank(client, info);
	}

	if (action == MenuAction_Cancel)
	{
		ckTopMenu(client);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

///////////////////
// PLAYERTIMES ////
///////////////////

public void db_GetMapRecord_Pro()
{
	g_fRecordMapTime = 9999999.0;
	for (int i = 1; i < MAX_STYLES; i++)
		g_fRecordStyleMapTime[i] = 9999999.0;

	char szQuery[512];
	// SELECT MIN(runtimepro), name, steamid, style FROM ck_playertimes WHERE mapname = '%s' AND runtimepro > -1.0 GROUP BY style
	Format(szQuery, 512, sql_selectMapRecord, g_szMapName);
	SQL_TQuery(g_hDb, sql_selectMapRecordCallback, szQuery, DBPrio_Low);
}

public void sql_selectMapRecordCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (sql_selectMapRecordCallback): %s", error);
		if (!g_bServerDataLoaded)
		{
			db_viewMapProRankCount();
		}
		return;
	}

	int style;

	if (SQL_HasResultSet(hndl))
	{
		while (SQL_FetchRow(hndl))
		{
			style = SQL_FetchInt(hndl, 3);
			if (style == 0)
			{
				g_fRecordMapTime = SQL_FetchFloat(hndl, 0);

				if (g_fRecordMapTime > -1.0 && !SQL_IsFieldNull(hndl, 0))
				{
					g_fRecordMapTime = SQL_FetchFloat(hndl, 0);
					FormatTimeFloat(0, g_fRecordMapTime, 3, g_szRecordMapTime, 64);
					SQL_FetchString(hndl, 1, g_szRecordPlayer, MAX_NAME_LENGTH);
					SQL_FetchString(hndl, 2, g_szRecordMapSteamID, MAX_NAME_LENGTH);
				}
				else
				{
					Format(g_szRecordMapTime, 64, "N/A");
					g_fRecordMapTime = 9999999.0;
				}
			}
			else
			{
				g_fRecordStyleMapTime[style] = SQL_FetchFloat(hndl, 0);

				if (g_fRecordStyleMapTime[style] > -1.0 && !SQL_IsFieldNull(hndl, 0))
				{
					g_fRecordStyleMapTime[style] = SQL_FetchFloat(hndl, 0);
					FormatTimeFloat(0, g_fRecordStyleMapTime[style], 3, g_szRecordStyleMapTime[style], 64);
					SQL_FetchString(hndl, 1, g_szRecordStylePlayer[style], MAX_NAME_LENGTH);
					SQL_FetchString(hndl, 2, g_szRecordStyleMapSteamID[style], MAX_NAME_LENGTH);
				}
				else
				{
					Format(g_szRecordStyleMapTime[style], 64, "N/A");
					g_fRecordStyleMapTime[style] = 9999999.0;
				}
			}
		}
	}
	else
	{
		Format(g_szRecordMapTime, 64, "N/A");
		g_fRecordMapTime = 9999999.0;
		for (int i = 1; i < MAX_STYLES; i++)
		{
			Format(g_szRecordStyleMapTime[i], 64, "N/A");
			g_fRecordStyleMapTime[i] = 9999999.0;
		}
	}
	if (!g_bServerDataLoaded)
	{
		db_viewMapProRankCount();
	}
	return;
}


public void sql_selectProSurfersCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (sql_selectProSurfersCallback): %s", error);
		return;
	}

	char szValue[128];
	char szSteamID[32];
	char szName[64];
	char szTime[32];
	float time;

	Menu topSurfersMenu = new Menu(MapMenuHandler3);
	topSurfersMenu.Pagination = 5;
	topSurfersMenu.SetTitle("Top 20 Map Times (local)\n    Rank   Time              Player");
	if (SQL_HasResultSet(hndl))

	{
		int i = 1;
		while (SQL_FetchRow(hndl))
		{
			SQL_FetchString(hndl, 0, szName, 64);
			time = SQL_FetchFloat(hndl, 1);
			SQL_FetchString(hndl, 2, szSteamID, 32);
			FormatTimeFloat(data, time, 3, szTime, sizeof(szTime));
			if (time < 3600.0)
			Format(szTime, 32, "  %s", szTime);
			if (i < 10)
			Format(szValue, 128, "[0%i.] %s    » %s", i, szTime, szName);
			else
			Format(szValue, 128, "[%i.] %s    » %s", i, szTime, szName);
			AddMenuItem(topSurfersMenu, szSteamID, szValue, ITEMDRAW_DEFAULT);
			i++;
		}
		if (i == 1)
		{
			PrintToChat(data, "%t", "NoMapRecords", LIMEGREEN, WHITE, g_szMapName);
		}
	}
	topSurfersMenu.OptionFlags = MENUFLAG_BUTTON_EXIT;
	topSurfersMenu.Display(data, MENU_TIME_FOREVER);
}

public void db_selectTopSurfers(int client, char mapname[128])
{
	char szQuery[1024];
	Format(szQuery, 1024, sql_selectTopSurfers, mapname);
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, mapname);
	WritePackCell(pack, 0);
	SQL_TQuery(g_hDb, sql_selectTopSurfersCallback, szQuery, pack, DBPrio_Low);
}

public void db_selectMapTopSurfers(int client, char mapname[128])
{
	char szQuery[1024];
	char type[128];
	type = "normal";
	if (StrEqual(mapname, "surf_me"))
		Format(szQuery, 1024, sql_selectTopSurfers3, mapname);
	else
		Format(szQuery, 1024, sql_selectTopSurfers2, PERCENT, mapname, PERCENT);
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, mapname);
	WritePackString(pack, type);
	SQL_TQuery(g_hDb, sql_selectTopSurfersCallback, szQuery, pack, DBPrio_Low);
}


//// BONUS //////////'

public void db_selectBonusesInMap(int client, char mapname[128])
{
	// SELECT mapname, zonegroup, zonename FROM `ck_zones` WHERE mapname LIKE '%c%s%c' AND zonegroup > 0 GROUP BY zonegroup;
	char szQuery[512];
	Format(szQuery, 512, sql_selectBonusesInMap, PERCENT, mapname, PERCENT);
	SQL_TQuery(g_hDb, db_selectBonusesInMapCallback, szQuery, client, DBPrio_Low);
}

public void db_selectBonusesInMapCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (db_selectBonusesInMapCallback): %s", error);
		return;
	}
	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		char mapname[128], MenuTitle[248], BonusName[128], MenuID[248];
		int zGrp;

		if (SQL_GetRowCount(hndl) == 1)
		{
			SQL_FetchString(hndl, 0, mapname, 128);
			db_selectBonusTopSurfers(client, mapname, SQL_FetchInt(hndl, 1));
			return;
		}

		Menu listBonusesinMapMenu = new Menu(MenuHandler_SelectBonusinMap);

		SQL_FetchString(hndl, 0, mapname, 128);
		zGrp = SQL_FetchInt(hndl, 1);
		Format(MenuTitle, 248, "Choose a Bonus in %s", mapname);
		listBonusesinMapMenu.SetTitle(MenuTitle);

		SQL_FetchString(hndl, 2, BonusName, 128);

		if (!BonusName[0])
		Format(BonusName, 128, "BONUS %i", zGrp);

		Format(MenuID, 248, "%s-%i", mapname, zGrp);

		listBonusesinMapMenu.AddItem(MenuID, BonusName);


		while (SQL_FetchRow(hndl))
		{
			SQL_FetchString(hndl, 2, BonusName, 128);
			zGrp = SQL_FetchInt(hndl, 1);

			if (StrEqual(BonusName, "NULL", false))
			Format(BonusName, 128, "BONUS %i", zGrp);

			Format(MenuID, 248, "%s-%i", mapname, zGrp);

			listBonusesinMapMenu.AddItem(MenuID, BonusName);
		}

		listBonusesinMapMenu.ExitButton = true;
		listBonusesinMapMenu.Display(client, 60);
	}
	else
	{
		PrintToChat(client, " %cSurftimer %c| No bonuses found.", LIMEGREEN, WHITE);
		return;
	}
}

public int MenuHandler_SelectBonusinMap(Handle sMenu, MenuAction action, int client, int item)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char aID[248];
			char splits[2][128];
			GetMenuItem(sMenu, item, aID, sizeof(aID));
			ExplodeString(aID, "-", splits, sizeof(splits), sizeof(splits[]));

			db_selectBonusTopSurfers(client, splits[0], StringToInt(splits[1]));
		}
		case MenuAction_End:
		{
			delete sMenu;
		}
	}
}



public void db_selectBonusTopSurfers(int client, char mapname[128], int zGrp)
{
	char szQuery[1024];
	Format(szQuery, 1024, sql_selectTopBonusSurfers, PERCENT, mapname, PERCENT, zGrp);
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, mapname);
	WritePackCell(pack, zGrp);
	SQL_TQuery(g_hDb, sql_selectTopBonusSurfersCallback, szQuery, pack, DBPrio_Low);
}

public void sql_selectTopBonusSurfersCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (sql_selectTopBonusSurfersCallback): %s", error);
		return;
	}

	ResetPack(data);
	int client = ReadPackCell(data);
	char szMap[128];
	ReadPackString(data, szMap, 128);
	int zGrp = ReadPackCell(data);
	CloseHandle(data);

	char szFirstMap[128], szValue[128], szName[64], szSteamID[32], lineBuf[256], title[256];
	float time;
	bool bduplicat = false;
	Handle stringArray = CreateArray(100);
	Menu topMenu;

	if (StrEqual(szMap, g_szMapName))
	topMenu = new Menu(MapMenuHandler1);
	else
	topMenu = new Menu(MapTopMenuHandler2);

	topMenu.Pagination = 5;

	if (SQL_HasResultSet(hndl))
	{
		int i = 1;
		while (SQL_FetchRow(hndl))
		{
			bduplicat = false;
			SQL_FetchString(hndl, 0, szSteamID, 32);
			SQL_FetchString(hndl, 1, szName, 64);
			time = SQL_FetchFloat(hndl, 2);
			SQL_FetchString(hndl, 4, szMap, 128);
			if (i == 1 || (i > 1 && StrEqual(szFirstMap, szMap)))
			{
				int stringArraySize = GetArraySize(stringArray);
				for (int x = 0; x < stringArraySize; x++)
				{
					GetArrayString(stringArray, x, lineBuf, sizeof(lineBuf));
					if (StrEqual(lineBuf, szName, false))
					bduplicat = true;
				}
				if (bduplicat == false && i < 51)
				{
					char szTime[32];
					FormatTimeFloat(client, time, 3, szTime, sizeof(szTime));
					if (time < 3600.0)
					Format(szTime, 32, "   %s", szTime);
					if (i == 100)
					Format(szValue, 128, "[%i.] %s |    » %s", i, szTime, szName);
					if (i >= 10)
					Format(szValue, 128, "[%i.] %s |    » %s", i, szTime, szName);
					else
					Format(szValue, 128, "[0%i.] %s |    » %s", i, szTime, szName);
					topMenu.AddItem(szSteamID, szValue, ITEMDRAW_DEFAULT);
					PushArrayString(stringArray, szName);
					if (i == 1)
					Format(szFirstMap, 128, "%s", szMap);
					i++;
				}
			}
		}
		if (i == 1)
		{
			PrintToChat(client, "%t", "NoTopRecords", LIMEGREEN, WHITE, szMap);
		}
	}
	else
	PrintToChat(client, "%t", "NoTopRecords", LIMEGREEN, WHITE, szMap);
	Format(title, 256, "Top 50 Times on %s (B %i) \n    Rank    Time               Player", szFirstMap, zGrp);
	topMenu.SetTitle(title);
	topMenu.OptionFlags = MENUFLAG_BUTTON_EXIT;
	topMenu.Display(client, MENU_TIME_FOREVER);
	CloseHandle(stringArray);
}

public void sql_selectTopSurfersCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (sql_selectTopSurfersCallback): %s", error);
		return;
	}

	ResetPack(data);
	int client = ReadPackCell(data);
	char szMap[128];
	ReadPackString(data, szMap, 128);
	int style = ReadPackCell(data);
	CloseHandle(data);

	char szFirstMap[128];
	char szValue[128];
	char szName[64];
	float time;
	char szSteamID[32];
	char lineBuf[256];
	Handle stringArray = CreateArray(100);
	Handle menu;
	if (StrEqual(szMap, g_szMapName))
		menu = CreateMenu(MapMenuHandler1);
	else
		menu = CreateMenu(MapTopMenuHandler2);
	SetMenuPagination(menu, 5);
	bool bduplicat = false;
	char title[256];
	if (SQL_HasResultSet(hndl))
	{
		int i = 1;
		while (SQL_FetchRow(hndl))
		{
			bduplicat = false;
			SQL_FetchString(hndl, 0, szSteamID, 32);
			SQL_FetchString(hndl, 1, szName, 64);
			time = SQL_FetchFloat(hndl, 2);
			SQL_FetchString(hndl, 4, szMap, 128);
			if (i == 1 || (i > 1 && StrEqual(szFirstMap, szMap)))
			{
				int stringArraySize = GetArraySize(stringArray);
				for (int x = 0; x < stringArraySize; x++)
				{
					GetArrayString(stringArray, x, lineBuf, sizeof(lineBuf));
					if (StrEqual(lineBuf, szName, false))
					bduplicat = true;
				}
				if (bduplicat == false && i < 51)
				{
					char szTime[32];
					FormatTimeFloat(client, time, 3, szTime, sizeof(szTime));
					if (time < 3600.0)
					Format(szTime, 32, "   %s", szTime);
					if (i == 100)
					Format(szValue, 128, "[%i.] %s |    » %s", i, szTime, szName);
					if (i >= 10)
					Format(szValue, 128, "[%i.] %s |    » %s", i, szTime, szName);
					else
					Format(szValue, 128, "[0%i.] %s |    » %s", i, szTime, szName);
					AddMenuItem(menu, szSteamID, szValue, ITEMDRAW_DEFAULT);
					PushArrayString(stringArray, szName);
					if (i == 1)
					Format(szFirstMap, 128, "%s", szMap);
					i++;
				}
			}
		}
		if (i == 1)
		{
			PrintToChat(client, "%t", "NoTopRecords", LIMEGREEN, WHITE, szMap);
		}
	}
	else
	PrintToChat(client, "%t", "NoTopRecords", LIMEGREEN, WHITE, szMap);
	if(style == 0) // normal
	Format(title, 256, "Top 50 Times on %s \n    Rank    Time               Player", szFirstMap);
	else if(style == 1) // sw
	Format(title, 256, "Top 50 SW Times on %s \n    Rank    Time               Player", szFirstMap);
	else if(style == 2) //HSW
	Format(title, 256, "Top 50 HSW Times on %s \n    Rank    Time               Player", szFirstMap);
	else if(style == 3) // BW
	Format(title, 256, "Top 50 BW Times on %s \n    Rank    Time               Player", szFirstMap);
	else if(style == 4) // Low-Gravity
	Format(title, 256, "Top 50 Low-Gravity Times on %s \n    Rank    Time               Player", szFirstMap);
	else if(style == 5) // Slow Motion
	Format(title, 256, "Top 50 Slow Motion Times on %s \n    Rank    Time               Player", szFirstMap);
	else if(style == 6) // Fast Forward
	Format(title, 256, "Top 50 Fast Forward Times on %s \n    Rank    Time               Player", szFirstMap);
	SetMenuTitle(menu, title);
	SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	CloseHandle(stringArray);
}

public void db_selectProSurfers(int client)
{
	char szQuery[1024];
	Format(szQuery, 1024, sql_selectProSurfers, g_szMapName);
	SQL_TQuery(g_hDb, sql_selectProSurfersCallback, szQuery, client, DBPrio_Low);
}

public void db_currentRunRank(int client)
{
	if (!IsValidClient(client))
	return;

	char szQuery[512];
	Format(szQuery, 512, "SELECT count(runtimepro)+1 FROM `ck_playertimes` WHERE `mapname` = '%s' AND `runtimepro` < %f;", g_szMapName, g_fFinalTime[client]);
	SQL_TQuery(g_hDb, SQL_CurrentRunRankCallback, szQuery, client, DBPrio_Low);
}

public void SQL_CurrentRunRankCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_CurrentRunRankCallback): %s", error);
		return;
	}
	// Get players rank, 9999999 = error
	int rank;
	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		rank = SQL_FetchInt(hndl, 0);
	}

	MapFinishedMsgs(client, rank);
}

//
// Get clients record from database
// Called when a player finishes a map
//
public void db_selectRecord(int client)
{
	if (!IsValidClient(client))
	return;

	char szQuery[255];
	Format(szQuery, 255, "SELECT runtimepro FROM ck_playertimes WHERE steamid = '%s' AND mapname = '%s' AND runtimepro > -1.0 AND style = 0;", g_szSteamID[client], g_szMapName);
	SQL_TQuery(g_hDb, sql_selectRecordCallback, szQuery, client, DBPrio_Low);
}

public void sql_selectRecordCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (sql_selectRecordCallback): %s", error);
		return;
	}

	if (!IsValidClient(data))
	return;


	char szQuery[512];

	// Found old time from database
	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		float time = SQL_FetchFloat(hndl, 0);

		// If old time was slower than the new time, update record
		if ((g_fFinalTime[data] <= time || time <= 0.0))
		{
			db_updateRecordPro(data);
		}
	}
	else
	{  // No record found from database - Let's insert

	// Escape name for SQL injection protection
	char szName[MAX_NAME_LENGTH * 2 + 1], szUName[MAX_NAME_LENGTH];
	GetClientName(data, szUName, MAX_NAME_LENGTH);
	SQL_EscapeString(g_hDb, szUName, szName, MAX_NAME_LENGTH);

	// Move required information in datapack
	Handle pack = CreateDataPack();
	WritePackFloat(pack, g_fFinalTime[data]);
	WritePackCell(pack, data);

	//"INSERT INTO ck_playertimes (steamid, mapname, name, runtimepro, style) VALUES('%s', '%s', '%s', '%f', %i);";
	Format(szQuery, 512, sql_insertPlayerTime, g_szSteamID[data], g_szMapName, szName, g_fFinalTime[data], 0);
	SQL_TQuery(g_hDb, SQL_UpdateRecordProCallback, szQuery, pack, DBPrio_Low);

	g_bInsertNewTime = true;
}
}

//
// If latest record was faster than old - Update time
//
public void db_updateRecordPro(int client)
{
	char szUName[MAX_NAME_LENGTH];

	if (IsValidClient(client))
	GetClientName(client, szUName, MAX_NAME_LENGTH);
	else
	return;

	// Also updating name in database, escape string
	char szName[MAX_NAME_LENGTH * 2 + 1];
	SQL_EscapeString(g_hDb, szUName, szName, MAX_NAME_LENGTH * 2 + 1);

	// Packing required information for later
	Handle pack = CreateDataPack();
	WritePackFloat(pack, g_fFinalTime[client]);
	WritePackCell(pack, client);

	char szQuery[1024];
	//"UPDATE ck_playertimes SET name = '%s', runtimepro = '%f' WHERE steamid = '%s' AND mapname = '%s' AND style = %i;";
	Format(szQuery, 1024, sql_updateRecordPro, szName, g_fFinalTime[client], g_szSteamID[client], g_szMapName, 0);
	SQL_TQuery(g_hDb, SQL_UpdateRecordProCallback, szQuery, pack, DBPrio_Low);
}


public void SQL_UpdateRecordProCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_UpdateRecordProCallback): %s", error);
		return;
	}

	if (data != INVALID_HANDLE)
	{
		ResetPack(data);
		float time = ReadPackFloat(data);
		int client = ReadPackCell(data);
		CloseHandle(data);

		// Find out how many times are are faster than the players time
		char szQuery[512];
		Format(szQuery, 512, "SELECT count(runtimepro) FROM `ck_playertimes` WHERE `mapname` = '%s' AND `runtimepro` < %f AND style = 0;", g_szMapName, time);
		SQL_TQuery(g_hDb, SQL_UpdateRecordProCallback2, szQuery, client, DBPrio_Low);

	}
}

public void SQL_UpdateRecordProCallback2(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_UpdateRecordProCallback2): %s", error);
		return;
	}
	// Get players rank, 9999999 = error
	int rank = 9999999;
	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		rank = (SQL_FetchInt(hndl, 0)+1);
	}
	g_MapRank[data] = rank;
	if(rank <= 10 && rank > 1)
		g_bTop10Time[data] = true;
	else
		g_bTop10Time[data] = false;

	MapFinishedMsgs(data);

	if(g_bInsertNewTime)
	{
		db_selectCurrentMapImprovement();
		g_bInsertNewTime = false;
	}
}

public void db_viewRecord(int client, char szSteamId[32], char szMapName[128])
{
	char szQuery[512];
	// SELECT runtimepro, name FROM ck_playertimes WHERE mapname = '%s' AND steamid = '%s' AND runtimepro > 0.0
	Handle pack = CreateDataPack();
	WritePackString(pack, szMapName);
	WritePackString(pack, szSteamId);
	WritePackCell(pack, client);

	Format(szQuery, 512, sql_selectPersonalRecords, szSteamId, szMapName);
	SQL_TQuery(g_hDb, SQL_ViewRecordCallback, szQuery, pack, DBPrio_Low);
}



public void SQL_ViewRecordCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_ViewRecordCallback): %s", error);
		return;
	}

	char szSteamId[32];
	char szMapName[128];

	ResetPack(pack);
	ReadPackString(pack, szMapName, 128);
	ReadPackString(pack, szSteamId, 32);
	int client = ReadPackCell(pack);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{

		char szName[MAX_NAME_LENGTH];

		SQL_FetchString(hndl, 1, szName, MAX_NAME_LENGTH);
		float runtime = SQL_FetchFloat(hndl, 0);

		Handle pack1 = CreateDataPack();
		WritePackString(pack1, szMapName);
		WritePackString(pack1, szSteamId);
		WritePackString(pack1, szName);
		WritePackCell(pack1, client);
		WritePackFloat(pack1, runtime);

		char szQuery[512];
		Format(szQuery, 512, sql_selectPlayerRankProTime, szSteamId, szMapName, szMapName);
		SQL_TQuery(g_hDb, SQL_ViewRecordCallback2, szQuery, pack1, DBPrio_Low);
	}
	else
	{
		Panel panel = new Panel();
		panel.DrawText("Current map time");
		panel.DrawText(" ");
		panel.DrawText("No record found on this map.");
		panel.DrawItem("exit");
		panel.Send(client, MenuHandler2, 300);
		delete panel;
		CloseHandle(pack);
	}
}

public void SQL_ViewRecordCallback2(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_ViewRecordCallback2): %s", error);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		char szQuery[512];
		int rank = SQL_GetRowCount(hndl);
		char szMapName[128];
		char szSteamId[32];
		char szName[MAX_NAME_LENGTH];

		WritePackCell(data, rank);
		ResetPack(data);
		ReadPackString(data, szMapName, 128);
		ReadPackString(data, szSteamId, 32);
		ReadPackString(data, szName, MAX_NAME_LENGTH);

		Format(szQuery, 512, sql_selectPlayerProCount, szMapName);
		SQL_TQuery(g_hDb, SQL_ViewRecordCallback3, szQuery, data, DBPrio_Low);
	}
}


public void SQL_ViewRecordCallback3(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_ViewRecordCallback3): %s", error);
		return;
	}

	//if there is a player record
	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		int count1 = SQL_GetRowCount(hndl);
		char szMapName[128];
		char szSteamId[32];
		char szName[MAX_NAME_LENGTH];
		float runtime = ReadPackFloat(data);

		ResetPack(data);
		ReadPackString(data, szMapName, 128);
		ReadPackString(data, szSteamId, 32);
		ReadPackString(data, szName, MAX_NAME_LENGTH);
		int client = ReadPackCell(data);
		int rank = ReadPackCell(data);

		if (runtime != -1.0)
		{
			Panel panel = new Panel();
			char szVrItem[256];
			Format(szVrItem, 256, "Map time of %s", szName);
			panel.DrawText(szVrItem);
			panel.DrawText(" ");

			FormatTimeFloat(client, runtime, 3, szVrItem, sizeof(szVrItem));
			Format(szVrItem, 256, "Time: %s", szVrItem);
			panel.DrawText(szVrItem);

			panel.DrawText("Map time:");
			Format(szVrItem, 256, "Rank: %i of %i", rank, count1);
			panel.DrawText(szVrItem);
			panel.DrawText(" ");

			panel.DrawItem("Exit");
			CloseHandle(data);
			panel.Send(client, RecordPanelHandler, 300);
			CloseHandle(panel);
		}
		else
		if (runtime != 0.000000)
		{
			WritePackCell(data, count1);
			char szQuery[512];
			Format(szQuery, 512, sql_selectPlayerRankProTime, szSteamId, szMapName, szMapName);
			SQL_TQuery(g_hDb, SQL_ViewRecordCallback4, szQuery, data, DBPrio_Low);
		}
	}
}

public void SQL_ViewRecordCallback4(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_ViewRecordCallback4): %s", error);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{

		char szQuery[512];
		int rankPro = SQL_GetRowCount(hndl);
		char szMapName[128];

		WritePackCell(data, rankPro);
		ResetPack(data);
		ReadPackString(data, szMapName, 128);

		Format(szQuery, 512, sql_selectPlayerProCount, szMapName);
		SQL_TQuery(g_hDb, SQL_ViewRecordCallback5, szQuery, data, DBPrio_Low);
	}
}

public void SQL_ViewRecordCallback5(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_ViewRecordCallback5): %s", error);
		return;
	}

	//if there is a player record
	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		int countPro = SQL_GetRowCount(hndl);
		//retrieve all values
		ResetPack(data);
		char szMapName[128];
		ReadPackString(data, szMapName, 128);
		char szSteamId[32];
		ReadPackString(data, szSteamId, 32);
		char szName[MAX_NAME_LENGTH];
		ReadPackString(data, szName, MAX_NAME_LENGTH);
		int client = ReadPackCell(data);
		float runtime = ReadPackFloat(data);
		int rank = ReadPackCell(data);
		int count1 = ReadPackCell(data);
		int rankPro = ReadPackCell(data);
		if (runtime != -1.0)
		{
			Handle panel = CreatePanel();
			char szVrName[256];
			Format(szVrName, 256, "Map time of %s", szName);
			DrawPanelText(panel, szVrName);
			Format(szVrName, 256, "on %s", g_szMapName);
			DrawPanelText(panel, " ");

			char szVrRank[32];
			char szVrRankPro[32];
			char szVrTimePro[256];
			FormatTimeFloat(client, runtime, 3, szVrTimePro, sizeof(szVrTimePro));
			Format(szVrTimePro, 256, "Time: %s", szVrTimePro);

			Format(szVrRank, 32, "Rank: %i of %i", rank, count1);
			Format(szVrRankPro, 32, "Rank: %i of %i", rankPro, countPro);

			DrawPanelText(panel, szVrRank);
			DrawPanelText(panel, " ");
			DrawPanelText(panel, "Time:");
			DrawPanelText(panel, szVrTimePro);
			DrawPanelText(panel, szVrRankPro);
			DrawPanelText(panel, " ");
			DrawPanelItem(panel, "exit");
			SendPanelToClient(panel, client, RecordPanelHandler, 300);
			CloseHandle(panel);
		}
	}
	CloseHandle(data);
}

public void db_viewAllRecords(int client, char szSteamId[32])
{
	//"SELECT db1.name, db2.steamid, db2.mapname, db2.runtimepro as overall, db1.steamid FROM ck_playertimes as db2 INNER JOIN ck_playerrank as db1 on db2.steamid = db1.steamid WHERE db2.steamid = '%s' AND db2.runtimepro > -1.0 ORDER BY mapname ASC;";

	char szQuery[1024];
	Format(szQuery, 1024, sql_selectPersonalAllRecords, szSteamId, szSteamId);
	if ((StrContains(szSteamId, "STEAM_") != -1))
		SQL_TQuery(g_hDb, SQL_ViewAllRecordsCallback, szQuery, client, DBPrio_Low);
	else if (IsClientInGame(client))
		PrintToChat(client, " %cSurftimer %c| Invalid SteamID found.", RED, WHITE);

	//ProfileMenu(client, -1, 0);
}


public void SQL_ViewAllRecordsCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_ViewAllRecordsCallback): %s", error);
		return;
	}

	int bHeader = false;
	char szUncMaps[1024];
	int mapcount = 0;
	char szName[MAX_NAME_LENGTH];
	char szSteamId[32];
	if (SQL_HasResultSet(hndl))
	{
		float time;
		char szMapName[128];
		char szMapName2[128];
		char szQuery[1024];
		Format(szUncMaps, sizeof(szUncMaps), "");
		g_totalMapsCompleted[data] = SQL_GetRowCount(hndl);

		g_CompletedMenu = CreateMenu(FinishedMapsMenuHandler);
		SetMenuPagination(g_CompletedMenu, 5);
		g_mapsCompletedLoop[data] = 0;

		while (SQL_FetchRow(hndl))
		{
			SQL_FetchString(hndl, 0, szName, MAX_NAME_LENGTH);
			SQL_FetchString(hndl, 1, szSteamId, MAX_NAME_LENGTH);
			SQL_FetchString(hndl, 2, szMapName, 128);

			time = SQL_FetchFloat(hndl, 3);

			int tier = SQL_FetchInt(hndl, 5);

			int mapfound = false;

			//map in rotation?
			for (int i = 0; i < GetArraySize(g_MapList); i++)
			{
				GetArrayString(g_MapList, i, szMapName2, sizeof(szMapName2));
				if (StrEqual(szMapName2, szMapName, false))
				{
					if (!bHeader)
					{
						PrintToConsole(data, " ");
						PrintToConsole(data, "-------------");
						PrintToConsole(data, "Finished Maps");
						PrintToConsole(data, "Player: %s", szName);
						PrintToConsole(data, "SteamID: %s", szSteamId);
						PrintToConsole(data, "-------------");
						PrintToConsole(data, " ");
						bHeader = true;
						PrintToChat(data, "%t", "ConsoleOutput", LIMEGREEN, WHITE);
					}
					Handle pack = CreateDataPack();
					WritePackString(pack, szName);
					WritePackString(pack, szSteamId);
					WritePackString(pack, szMapName);
					WritePackFloat(pack, time);
					WritePackCell(pack, data);
					WritePackCell(pack, tier);
					Format(szQuery, 1024, sql_selectPlayerRankProTime, szSteamId, szMapName, szMapName);
					SQL_TQuery(g_hDb, SQL_ViewAllRecordsCallback2, szQuery, pack, DBPrio_Low);
					mapfound = true;
					continue;
				}
			}
			if (!mapfound)
			{
				mapcount++;
				g_uncMapsCompleted[data] = mapcount;
				if (!mapfound && mapcount == 1)
				{
					Format(szUncMaps, sizeof(szUncMaps), "%s", szMapName);
				}
				else
				{
					if (!mapfound && mapcount > 1)
					{
						Format(szUncMaps, sizeof(szUncMaps), "%s, %s", szUncMaps, szMapName);
					}
				}
			}
		}
	}
	if (!StrEqual(szUncMaps, ""))
	{
		if (!bHeader)
		{
			PrintToChat(data, "%t", "ConsoleOutput", LIMEGREEN, WHITE);
			PrintToConsole(data, " ");
			PrintToConsole(data, "-------------");
			PrintToConsole(data, "Finished Maps");
			PrintToConsole(data, "Player: %s", szName);
			PrintToConsole(data, "SteamID: %s", szSteamId);
			PrintToConsole(data, "-------------");
			PrintToConsole(data, " ");
		}
		PrintToConsole(data, "Times on maps which are not in the mapcycle.txt (Records still count but you don't get points): %s", szUncMaps);
	}
	if (!bHeader && StrEqual(szUncMaps, ""))
	{
		ProfileMenu(data, -1, 0);
		PrintToChat(data, "%t", "PlayerHasNoMapRecords", LIMEGREEN, WHITE, g_szProfileName[data]);
	}
}

public void SQL_ViewAllRecordsCallback2(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_ViewAllRecordsCallback2): %s", error);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		char szQuery[512];
		char szName[MAX_NAME_LENGTH];
		char szSteamId[32];
		char szMapName[128];

		int rank = SQL_GetRowCount(hndl);
		WritePackCell(data, rank);
		ResetPack(data);
		ReadPackString(data, szName, MAX_NAME_LENGTH);
		ReadPackString(data, szSteamId, 32);
		ReadPackString(data, szMapName, 128);

		Format(szQuery, 512, sql_selectPlayerProCount, szMapName);
		SQL_TQuery(g_hDb, SQL_ViewAllRecordsCallback3, szQuery, data, DBPrio_Low);
	}
}

public void SQL_ViewAllRecordsCallback3(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_ViewAllRecordsCallback3): %s", error);
		return;
	}

	//fluffys
	/*Handle menu;
	menu = CreateMenu(FinishedMapsMenuHandler);
	SetMenuPagination(menu, 5);*/

	//if there is a player record
	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		int count = SQL_FetchInt(hndl, 1);
		char szTime[32];
		char szMapName[128];
		char szSteamId[32];
		char szName[MAX_NAME_LENGTH];
		//fluffys
		char szValue[128];

		ResetPack(data);
		ReadPackString(data, szName, MAX_NAME_LENGTH);
		ReadPackString(data, szSteamId, 32);
		ReadPackString(data, szMapName, 128);
		float time = ReadPackFloat(data);
		int client = ReadPackCell(data);
		int tier = ReadPackCell(data);
		int rank = ReadPackCell(data);
		CloseHandle(data);

		FormatTimeFloat(client, time, 3, szTime, sizeof(szTime));

		if (time < 3600.0)
		Format(szTime, 32, "%s", szTime);

		char szS[32];
		char szT[32];
		char szTotal[32];
		IntToString(rank, szT, sizeof(szT));
		IntToString(count, szS, sizeof(szS));
		Format(szTotal, sizeof(szTotal), "%s%s", szT, szS);
		if (strlen(szTotal) == 6)
			Format(szValue, 128, "%i/%i    %s | » %s - %i", rank, count, szTime, szMapName, tier);
		else if (strlen(szTotal) == 5)
			Format(szValue, 128, "%i/%i      %s | » %s - %i", rank, count, szTime, szMapName, tier);
		else if (strlen(szTotal) == 4)
			Format(szValue, 128, "%i/%i        %s | » %s - %i", rank, count, szTime, szMapName, tier);
		else if (strlen(szTotal) == 3)
			Format(szValue, 128, "%i/%i          %s | » %s - %i", rank, count, szTime, szMapName, tier);
		else if (strlen(szTotal) == 2)
			Format(szValue, 128, "%i/%i           %s | » %s - %i", rank, count, szTime, szMapName, tier);
		else if (strlen(szTotal) == 1)
			Format(szValue, 128, "%i/%i            %s | » %s - %i", rank, count, szTime, szMapName, tier);
		else
			Format(szValue, 128, "%i/%i  %s | » %s - %i", rank, count, szTime, szMapName, tier);


		g_mapsCompletedLoop[client]++;
		AddMenuItem(g_CompletedMenu, szSteamId, szValue, ITEMDRAW_DISABLED);
		int totalMaps = g_totalMapsCompleted[client] - g_uncMapsCompleted[client];
		//PrintToChat(client, "totalMaps: %i , g_mapsCompletedLoop: %i", totalMaps, g_mapsCompletedLoop[client]);
		if (g_mapsCompletedLoop[client] == totalMaps)
		{
			//PrintToChat(client, "test");
			char title[256];
			Format(title, 256, "%i Finished maps for %s \n    Rank          Time          Mapname - Tier", totalMaps, szName);
			SetMenuTitle(g_CompletedMenu, title);
			SetMenuOptionFlags(g_CompletedMenu, MENUFLAG_BUTTON_EXIT);
			DisplayMenu(g_CompletedMenu, client, MENU_TIME_FOREVER);
		}

		if (IsValidClient(client))
		PrintToConsole(client, "%s - Tier: %i, Time: %s, Rank: %i/%i", szMapName, tier, szTime, rank, count);
	}
}

public void db_viewTop10Records(int client, char szSteamId[32], int type)
{
	//"SELECT db1.name, db2.steamid, db2.mapname, db2.runtimepro as overall, db1.steamid FROM ck_playertimes as db2 INNER JOIN ck_playerrank as db1 on db2.steamid = db1.steamid WHERE db2.steamid = '%s' AND db2.runtimepro > -1.0 ORDER BY mapname ASC;";

	Handle data = CreateDataPack();
	WritePackCell(data, client);
	WritePackCell(data, type);

	char szQuery[1024];
	Format(szQuery, 1024, sql_selectPersonalAllRecords, szSteamId, szSteamId);
	if ((StrContains(szSteamId, "STEAM_") != -1))
	SQL_TQuery(g_hDb, SQL_ViewTop10RecordsCallback, szQuery, data, DBPrio_Low);
	else
	if (IsClientInGame(client))
	PrintToChat(client, " %cSurftimer %c| Invalid SteamID found.", RED, WHITE);
	ProfileMenu(client, -1, 0);
}


public void SQL_ViewTop10RecordsCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_ViewAllRecordsCallback): %s", error);
		return;
	}

	ResetPack(pack);
	int data = ReadPackCell(pack);
	int type = ReadPackCell(pack);
	CloseHandle(pack);

	int bHeader = false;
	char szUncMaps[1024];
	int mapcount = 0;
	char szName[MAX_NAME_LENGTH];
	char szSteamId[32];
	if (SQL_HasResultSet(hndl))
	{
		float time;
		char szMapName[128];
		char szMapName2[128];
		char szQuery[1024];
		Format(szUncMaps, sizeof(szUncMaps), "");
		while (SQL_FetchRow(hndl))
		{
			SQL_FetchString(hndl, 0, szName, MAX_NAME_LENGTH);
			SQL_FetchString(hndl, 1, szSteamId, MAX_NAME_LENGTH);
			SQL_FetchString(hndl, 2, szMapName, 128);

			time = SQL_FetchFloat(hndl, 3);

			int mapfound = false;

			//map in rotation?
			for (int i = 0; i < GetArraySize(g_MapList); i++)
			{
				GetArrayString(g_MapList, i, szMapName2, sizeof(szMapName2));
				if (StrEqual(szMapName2, szMapName, false))
				{
					if (!bHeader)
					{
						PrintToConsole(data, " ");
						PrintToConsole(data, "-------------");
						if (type == 0)
							PrintToConsole(data, "Top 10 Maps");
						else
							PrintToConsole(data, "World Records");
						PrintToConsole(data, "Player: %s", szName);
						PrintToConsole(data, "SteamID: %s", szSteamId);
						PrintToConsole(data, "-------------");
						PrintToConsole(data, " ");
						bHeader = true;
						PrintToChat(data, "%t", "ConsoleOutput", LIMEGREEN, WHITE);
					}
					Handle pack2 = CreateDataPack();
					WritePackString(pack2, szName);
					WritePackString(pack2, szSteamId);
					WritePackString(pack2, szMapName);
					WritePackFloat(pack2, time);
					WritePackCell(pack2, data);
					WritePackCell(pack2, type);

					Format(szQuery, 1024, sql_selectPlayerRankProTime, szSteamId, szMapName, szMapName);
					SQL_TQuery(g_hDb, SQL_ViewTop10RecordsCallback2, szQuery, pack2, DBPrio_Low);
					mapfound = true;
					continue;
				}
			}
			if (!mapfound)
			{
				mapcount++;
				if (!mapfound && mapcount == 1)
				{
					Format(szUncMaps, sizeof(szUncMaps), "%s", szMapName);
				}
				else
				{
					if (!mapfound && mapcount > 1)
					{
						Format(szUncMaps, sizeof(szUncMaps), "%s, %s", szUncMaps, szMapName);
					}
				}
			}
		}
	}
	if (!StrEqual(szUncMaps, ""))
	{
		if (!bHeader)
		{
			PrintToChat(data, "%t", "ConsoleOutput", LIMEGREEN, WHITE);
			PrintToConsole(data, " ");
			PrintToConsole(data, "-------------");
			if (type == 0)
				PrintToConsole(data, "Top 10 Maps");
			else
				PrintToConsole(data, "World Records");
			PrintToConsole(data, "Player: %s", szName);
			PrintToConsole(data, "SteamID: %s", szSteamId);
			PrintToConsole(data, "-------------");
			PrintToConsole(data, " ");
		}
		PrintToConsole(data, "Times on maps which are not in the mapcycle.txt (Records still count but you don't get points): %s", szUncMaps);
	}
	if (!bHeader && StrEqual(szUncMaps, ""))
	{
		ProfileMenu(data, -1, 0);
		PrintToChat(data, "%t", "PlayerHasNoMapRecords", LIMEGREEN, WHITE, g_szProfileName[data]);
	}
}

public void SQL_ViewTop10RecordsCallback2(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_ViewAllRecordsCallback2): %s", error);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		char szQuery[512];
		char szName[MAX_NAME_LENGTH];
		char szSteamId[32];
		char szMapName[128];

		int rank = SQL_GetRowCount(hndl);
		WritePackCell(data, rank);
		ResetPack(data);
		ReadPackString(data, szName, MAX_NAME_LENGTH);
		ReadPackString(data, szSteamId, 32);
		ReadPackString(data, szMapName, 128);

		Format(szQuery, 512, sql_selectPlayerProCount, szMapName);
		SQL_TQuery(g_hDb, SQL_ViewTop10RecordsCallback3, szQuery, data, DBPrio_Low);
	}
}

public void SQL_ViewTop10RecordsCallback3(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_ViewAllRecordsCallback3): %s", error);
		return;
	}

	//fluffys
	/*Handle menu;
	menu = CreateMenu(FinishedMapsMenuHandler);
	SetMenuPagination(menu, 5);*/

	int i = 1;

	//if there is a player record
	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		int count = SQL_GetRowCount(hndl);
		char szTime[32];
		char szMapName[128];
		char szSteamId[32];
		char szName[MAX_NAME_LENGTH];
		//fluffys
		char szValue[128];

		ResetPack(data);
		ReadPackString(data, szName, MAX_NAME_LENGTH);
		ReadPackString(data, szSteamId, 32);
		ReadPackString(data, szMapName, 128);
		float time = ReadPackFloat(data);
		int client = ReadPackCell(data);
		int type = ReadPackCell(data);
		int rank = ReadPackCell(data);
		CloseHandle(data);

		FormatTimeFloat(client, time, 3, szTime, sizeof(szTime));

		if (time < 3600.0)
		Format(szTime, 32, "   %s", szTime);

		Format(szValue, 128, "%i/%i %s |    » %s", rank, count, szTime, szMapName);
		/*AddMenuItem(menu, szSteamId, szValue, ITEMDRAW_DEFAULT);*/
		i++;

		/*Format(title, 256, "Finished maps for %s \n    Rank    Time               Mapnname", szName);
		SetMenuTitle(menu, title);
		SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
		DisplayMenu(menu, client, MENU_TIME_FOREVER);*/

		if (IsValidClient(client))
		{
			if(type == 0)
			{
				if (rank <= 10)
					PrintToConsole(client, "%s, Time: %s, Rank: %i/%i", szMapName, szTime, rank, count);
			}
			else
			{
				if (rank == 1)
					PrintToConsole(client, "%s, Time: %s, Rank: %i/%i", szMapName, szTime, rank, count);
			}
		}
	}
}


public void db_selectPlayer(int client)
{
	char szQuery[255];
	if (!IsValidClient(client))
	return;
	Format(szQuery, 255, sql_selectPlayer, g_szSteamID[client], g_szMapName);
	SQL_TQuery(g_hDb, SQL_SelectPlayerCallback, szQuery, client, DBPrio_Low);
}

public void SQL_SelectPlayerCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_SelectPlayerCallback): %s", error);
		return;
	}

	if (!SQL_HasResultSet(hndl) && !SQL_FetchRow(hndl) && !IsValidClient(data))
	db_insertPlayer(data);
}

public void db_insertPlayer(int client)
{
	char szQuery[255];
	char szUName[MAX_NAME_LENGTH];
	if (IsValidClient(client))
	{
		GetClientName(client, szUName, MAX_NAME_LENGTH);
	}
	else
	return;
	char szName[MAX_NAME_LENGTH * 2 + 1];
	SQL_EscapeString(g_hDb, szUName, szName, MAX_NAME_LENGTH * 2 + 1);
	Format(szQuery, 255, sql_insertPlayer, g_szSteamID[client], g_szMapName, szName);
	SQL_TQuery(g_hDb, SQL_InsertPlayerCallBack, szQuery, client, DBPrio_Low);
}

//
// Getting player settings starts here
//
public void db_viewPersonalRecords(int client, char szSteamId[32], char szMapName[128])
{
	char szName[32];
	GetClientName(client, szName, sizeof(szName));
	g_fClientsLoading[client][0] = GetGameTime();
	LogToFileEx(g_szLogFile, "[Surftimer] Loading %s - %s settings", szSteamId, szName);

	g_fTick[client][0] = GetGameTime();

	char szQuery[1024];
	Format(szQuery, 1024, "SELECT runtimepro, style FROM ck_playertimes WHERE steamid = '%s' AND mapname = '%s' AND runtimepro > 0.0;", szSteamId, szMapName);
	SQL_TQuery(g_hDb, SQL_selectPersonalRecordsCallback, szQuery, client, DBPrio_Low);
}


public void SQL_selectPersonalRecordsCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_selectPersonalRecordsCallback): %s", error);
		if (!g_bSettingsLoaded[client])
			LoadClientSetting(client, g_iSettingToLoad[client]);
		return;
	}

	g_fPersonalRecord[client] = 0.0;
	Format(g_szPersonalRecord[client], 64, "NONE");
	for (int i = 1; i < MAX_STYLES; i++)
	{
		Format(g_szPersonalStyleRecord[i][client], 64, "NONE");
		g_fPersonalStyleRecord[i][client] = 0.0;
	}

	if (SQL_HasResultSet(hndl))
	{
		int style;
		while (SQL_FetchRow(hndl))
		{
			style = SQL_FetchInt(hndl, 1);
			if (style == 0)
			{
				g_fPersonalRecord[client] = SQL_FetchFloat(hndl, 0);

				if (g_fPersonalRecord[client] > 0.0)
				{
					FormatTimeFloat(client, g_fPersonalRecord[client], 3, g_szPersonalRecord[client], 64);
					// Time found, get rank in current map
					db_viewMapRankPro(client);
				}
			}
			else
			{
				g_fPersonalStyleRecord[style][client] = SQL_FetchFloat(hndl, 0);

				if (g_fPersonalStyleRecord[style][client] > 0.0)
				{
					FormatTimeFloat(client, g_fPersonalStyleRecord[style][client], 3, g_szPersonalStyleRecord[style][client], 64);
					// Time found, get rank in current map
					db_viewStyleMapRank(client, style);
				}
			}
		}
	}
	else
	{
		Format(g_szPersonalRecord[client], 64, "NONE");
		g_fPersonalRecord[client] = 0.0;

		for (int i = 1; i < MAX_STYLES; i++)
		{
			Format(g_szPersonalStyleRecord[i][client], 64, "NONE");
			g_fPersonalStyleRecord[i][client] = 0.0;
		}
	}

	if (!g_bSettingsLoaded[client])
	{
		g_fTick[client][1] = GetGameTime();
		float tick = g_fTick[client][1] - g_fTick[client][0];
		LogToFileEx(g_szLogFile, "[Surftimer] %s: Finished db_viewPersonalRecords in %fs", g_szSteamID[client], tick);
		g_fTick[client][0] = GetGameTime();
		LoadClientSetting(client, g_iSettingToLoad[client]);
	}
}












///////////////////////
//// PLAYER TEMP //////
///////////////////////

public void db_deleteTmp(int client)
{
	char szQuery[256];
	if (!IsValidClient(client))
	return;
	Format(szQuery, 256, sql_deletePlayerTmp, g_szSteamID[client]);
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, client, DBPrio_Low);
}

public void db_selectLastRun(int client)
{
	char szQuery[512];
	if (!IsValidClient(client))
	return;
	Format(szQuery, 512, sql_selectPlayerTmp, g_szSteamID[client], g_szMapName);
	SQL_TQuery(g_hDb, SQL_LastRunCallback, szQuery, client, DBPrio_Low);
}

public void SQL_LastRunCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_LastRunCallback): %s", error);
		return;
	}

	g_bTimeractivated[data] = false;
	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl) && IsValidClient(data))
	{

		//"SELECT cords1,cords2,cords3, angle1, angle2, angle3,runtimeTmp, EncTickrate, Stage, zonegroup FROM ck_playertemp WHERE steamid = '%s' AND mapname = '%s';";

		//Get last psition
		g_fPlayerCordsRestore[data][0] = SQL_FetchFloat(hndl, 0);
		g_fPlayerCordsRestore[data][1] = SQL_FetchFloat(hndl, 1);
		g_fPlayerCordsRestore[data][2] = SQL_FetchFloat(hndl, 2);
		g_fPlayerAnglesRestore[data][0] = SQL_FetchFloat(hndl, 3);
		g_fPlayerAnglesRestore[data][1] = SQL_FetchFloat(hndl, 4);
		g_fPlayerAnglesRestore[data][2] = SQL_FetchFloat(hndl, 5);


		int zGroup;
		zGroup = SQL_FetchInt(hndl, 9);

		g_iClientInZone[data][2] = zGroup;

		g_Stage[zGroup][data] = SQL_FetchInt(hndl, 8);

		//Set new start time
		float fl_time = SQL_FetchFloat(hndl, 6);
		int tickrate = RoundFloat(float(SQL_FetchInt(hndl, 7)) / 5.0 / 11.0);
		if (tickrate == g_Server_Tickrate)
		{
			if (fl_time > 0.0)
			{
				g_fStartTime[data] = GetGameTime() - fl_time;
				g_bTimeractivated[data] = true;
			}

			if (SQL_FetchFloat(hndl, 0) == -1.0 && SQL_FetchFloat(hndl, 1) == -1.0 && SQL_FetchFloat(hndl, 2) == -1.0)
			{
				g_bRestorePosition[data] = false;
				g_bRestorePositionMsg[data] = false;
			}
			else
			{
				if (g_bLateLoaded && IsPlayerAlive(data) && !g_specToStage[data])
				{
					g_bPositionRestored[data] = true;
					TeleportEntity(data, g_fPlayerCordsRestore[data], g_fPlayerAnglesRestore[data], NULL_VECTOR);
					g_bRestorePosition[data] = false;
				}
				else
				{
					g_bRestorePosition[data] = true;
					g_bRestorePositionMsg[data] = true;
				}

			}
		}
	}
	else
	{

		g_bTimeractivated[data] = false;
	}
}









///////////////////////
//// Checkpoints //////
///////////////////////



public void db_viewRecordCheckpointInMap()
{
	for (int k = 0; k < MAXZONEGROUPS; k++)
	{
		g_bCheckpointRecordFound[k] = false;
		for (int i = 0; i < CPLIMIT; i++)
		g_fCheckpointServerRecord[k][i] = 0.0;
	}

	//"SELECT c.zonegroup, c.cp1, c.cp2, c.cp3, c.cp4, c.cp5, c.cp6, c.cp7, c.cp8, c.cp9, c.cp10, c.cp11, c.cp12, c.cp13, c.cp14, c.cp15, c.cp16, c.cp17, c.cp18, c.cp19, c.cp20, c.cp21, c.cp22, c.cp23, c.cp24, c.cp25, c.cp26, c.cp27, c.cp28, c.cp29, c.cp30, c.cp31, c.cp32, c.cp33, c.cp34, c.cp35 FROM ck_checkpoints c WHERE steamid = '%s' AND mapname='%s' UNION SELECT a.zonegroup, b.cp1, b.cp2, b.cp3, b.cp4, b.cp5, b.cp6, b.cp7, b.cp8, b.cp9, b.cp10, b.cp11, b.cp12, b.cp13, b.cp14, b.cp15, b.cp16, b.cp17, b.cp18, b.cp19, b.cp20, b.cp21, b.cp22, b.cp23, b.cp24, b.cp25, b.cp26, b.cp27, b.cp28, b.cp29, b.cp30, b.cp31, b.cp32, b.cp33, b.cp34, b.cp35 FROM ck_bonus a LEFT JOIN ck_checkpoints b ON a.steamid = b.steamid AND a.zonegroup = b.zonegroup WHERE a.mapname = '%s' GROUP BY a.zonegroup";
	char szQuery[1028];
	Format(szQuery, 1028, sql_selectRecordCheckpoints, g_szRecordMapSteamID, g_szMapName, g_szMapName);
	SQL_TQuery(g_hDb, sql_selectRecordCheckpointsCallback, szQuery, 1, DBPrio_Low);
}

public void sql_selectRecordCheckpointsCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (sql_selectRecordCheckpointsCallback): %s", error);
		if (!g_bServerDataLoaded)
			db_CalcAvgRunTime();
		return;
	}

	if (SQL_HasResultSet(hndl))
	{
		int zonegroup;
		while (SQL_FetchRow(hndl))
		{
			zonegroup = SQL_FetchInt(hndl, 0);
			for (int i = 0; i < 35; i++)
			{
				g_fCheckpointServerRecord[zonegroup][i] = SQL_FetchFloat(hndl, (i + 1));
				if (!g_bCheckpointRecordFound[zonegroup] && g_fCheckpointServerRecord[zonegroup][i] > 0.0)
				g_bCheckpointRecordFound[zonegroup] = true;
			}
		}
	}

	if (!g_bServerDataLoaded)
		db_CalcAvgRunTime();

	return;
}

public void db_viewCheckpoints(int client, char szSteamID[32], char szMapName[128])
{
	char szQuery[1024];
	//"SELECT zonegroup, cp1, cp2, cp3, cp4, cp5, cp6, cp7, cp8, cp9, cp10, cp11, cp12, cp13, cp14, cp15, cp16, cp17, cp18, cp19, cp20, cp21, cp22, cp23, cp24, cp25, cp26, cp27, cp28, cp29, cp30, cp31, cp32, cp33, cp34, cp35 FROM ck_checkpoints WHERE mapname='%s' AND steamid = '%s';";
	Format(szQuery, 1024, sql_selectCheckpoints, szMapName, szSteamID);
	SQL_TQuery(g_hDb, SQL_selectCheckpointsCallback, szQuery, client, DBPrio_Low);
}

public void SQL_selectCheckpointsCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	//fluffys come back
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_selectCheckpointsCallback): %s", error);
		return;
	}

	int zoneGrp;

	if (!IsValidClient(client))
	return;

	if (SQL_HasResultSet(hndl))
	{
		while (SQL_FetchRow(hndl))
		{
			zoneGrp = SQL_FetchInt(hndl, 0);
			g_bCheckpointsFound[zoneGrp][client] = true;
			int k = 1;
			for (int i = 0; i < 35; i++)
			{
				g_fCheckpointTimesRecord[zoneGrp][client][i] = SQL_FetchFloat(hndl, k);
				k++;
			}
		}
	}

	if (!g_bSettingsLoaded[client])
	{
		g_fTick[client][1] = GetGameTime();
		float tick = g_fTick[client][1] - g_fTick[client][0];
		LogToFileEx(g_szLogFile, "[Surftimer] %s: Finished db_viewCheckpoints in %fs", g_szSteamID[client], tick);

		float time = g_fTick[client][1] - g_fClientsLoading[client][0];
		char szName[32];
		GetClientName(client, szName, sizeof(szName));
		LogToFileEx(g_szLogFile, "[Surftimer] Finished loading %s - %s settings in %fs", g_szSteamID[client], szName, time);
		
		// Print a VIP's custom join msg to all
		if (g_bEnableJoinMsgs && !StrEqual(g_szCustomJoinMsg[client], "none") && IsPlayerVip(client, 2, true, false))
		{
			CPrintToChatAll("%s", g_szCustomJoinMsg[client]);
		}

		//CalculatePlayerRank(client);
		g_bSettingsLoaded[client] = true;
		g_bLoadingSettings[client] = false;

		db_UpdateLastSeen(client);

		if (GetConVarBool(g_hTeleToStartWhenSettingsLoaded))
			Command_Restart(client, 1);

		// Seach for next client to load
		for (int i = 1; i < MAXPLAYERS + 1; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i) && !g_bSettingsLoaded[i] && !g_bLoadingSettings[i])
			{
				char szSteamID[32];
				GetClientAuthId(i, AuthId_Steam2, szSteamID, 32, true);
				g_iSettingToLoad[i] = 0;
				LoadClientSetting(i, g_iSettingToLoad[i]);
				g_bLoadingSettings[i] = true;
				break;
			}
		}
	}
}

public void db_viewCheckpointsinZoneGroup(int client, char szSteamID[32], char szMapName[128], int zonegroup)
{
	char szQuery[1024];
	//"SELECT cp1, cp2, cp3, cp4, cp5, cp6, cp7, cp8, cp9, cp10, cp11, cp12, cp13, cp14, cp15, cp16, cp17, cp18, cp19, cp20, cp21, cp22, cp23, cp24, cp25, cp26, cp27, cp28, cp29, cp30, cp31, cp32, cp33, cp34, cp35 FROM ck_checkpoints WHERE mapname='%s' AND steamid = '%s' AND zonegroup = %i;";
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackCell(pack, zonegroup);

	Format(szQuery, 1024, sql_selectCheckpointsinZoneGroup, szMapName, szSteamID, zonegroup);
	SQL_TQuery(g_hDb, db_viewCheckpointsinZoneGroupCallback, szQuery, pack, DBPrio_Low);
}

public void db_viewCheckpointsinZoneGroupCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_selectCheckpointsCallback): %s", error);
		return;
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	int zonegrp = ReadPackCell(pack);
	CloseHandle(pack);

	if (!IsValidClient(client))
	return;

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		g_bCheckpointsFound[zonegrp][client] = true;
		for (int i = 0; i < 35; i++)
		{
			g_fCheckpointTimesRecord[zonegrp][client][i] = SQL_FetchFloat(hndl, i);
		}
	}
	else
	{
		g_bCheckpointsFound[zonegrp][client] = false;
	}
}



public void db_UpdateCheckpoints(int client, char szSteamID[32], int zGroup)
{
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackCell(pack, zGroup);
	if (g_bCheckpointsFound[zGroup][client])
	{
		char szQuery[1024];
		Format(szQuery, 1024, sql_updateCheckpoints, g_fCheckpointTimesNew[zGroup][client][0], g_fCheckpointTimesNew[zGroup][client][1], g_fCheckpointTimesNew[zGroup][client][2], g_fCheckpointTimesNew[zGroup][client][3], g_fCheckpointTimesNew[zGroup][client][4], g_fCheckpointTimesNew[zGroup][client][5], g_fCheckpointTimesNew[zGroup][client][6], g_fCheckpointTimesNew[zGroup][client][7], g_fCheckpointTimesNew[zGroup][client][8], g_fCheckpointTimesNew[zGroup][client][9], g_fCheckpointTimesNew[zGroup][client][10], g_fCheckpointTimesNew[zGroup][client][11], g_fCheckpointTimesNew[zGroup][client][12], g_fCheckpointTimesNew[zGroup][client][13], g_fCheckpointTimesNew[zGroup][client][14], g_fCheckpointTimesNew[zGroup][client][15], g_fCheckpointTimesNew[zGroup][client][16], g_fCheckpointTimesNew[zGroup][client][17], g_fCheckpointTimesNew[zGroup][client][18], g_fCheckpointTimesNew[zGroup][client][19], g_fCheckpointTimesNew[zGroup][client][20], g_fCheckpointTimesNew[zGroup][client][21], g_fCheckpointTimesNew[zGroup][client][22], g_fCheckpointTimesNew[zGroup][client][23], g_fCheckpointTimesNew[zGroup][client][24], g_fCheckpointTimesNew[zGroup][client][25], g_fCheckpointTimesNew[zGroup][client][26], g_fCheckpointTimesNew[zGroup][client][27], g_fCheckpointTimesNew[zGroup][client][28], g_fCheckpointTimesNew[zGroup][client][29], g_fCheckpointTimesNew[zGroup][client][30], g_fCheckpointTimesNew[zGroup][client][31], g_fCheckpointTimesNew[zGroup][client][32], g_fCheckpointTimesNew[zGroup][client][33], g_fCheckpointTimesNew[zGroup][client][34], szSteamID, g_szMapName, zGroup);
		SQL_TQuery(g_hDb, SQL_updateCheckpointsCallback, szQuery, pack, DBPrio_Low);
	}
	else
	{
		char szQuery[1024];
		Format(szQuery, 1024, sql_insertCheckpoints, szSteamID, g_szMapName, g_fCheckpointTimesNew[zGroup][client][0], g_fCheckpointTimesNew[zGroup][client][1], g_fCheckpointTimesNew[zGroup][client][2], g_fCheckpointTimesNew[zGroup][client][3], g_fCheckpointTimesNew[zGroup][client][4], g_fCheckpointTimesNew[zGroup][client][5], g_fCheckpointTimesNew[zGroup][client][6], g_fCheckpointTimesNew[zGroup][client][7], g_fCheckpointTimesNew[zGroup][client][8], g_fCheckpointTimesNew[zGroup][client][9], g_fCheckpointTimesNew[zGroup][client][10], g_fCheckpointTimesNew[zGroup][client][11], g_fCheckpointTimesNew[zGroup][client][12], g_fCheckpointTimesNew[zGroup][client][13], g_fCheckpointTimesNew[zGroup][client][14], g_fCheckpointTimesNew[zGroup][client][15], g_fCheckpointTimesNew[zGroup][client][16], g_fCheckpointTimesNew[zGroup][client][17], g_fCheckpointTimesNew[zGroup][client][18], g_fCheckpointTimesNew[zGroup][client][19], g_fCheckpointTimesNew[zGroup][client][20], g_fCheckpointTimesNew[zGroup][client][21], g_fCheckpointTimesNew[zGroup][client][22], g_fCheckpointTimesNew[zGroup][client][23], g_fCheckpointTimesNew[zGroup][client][24], g_fCheckpointTimesNew[zGroup][client][25], g_fCheckpointTimesNew[zGroup][client][26], g_fCheckpointTimesNew[zGroup][client][27], g_fCheckpointTimesNew[zGroup][client][28], g_fCheckpointTimesNew[zGroup][client][29], g_fCheckpointTimesNew[zGroup][client][30], g_fCheckpointTimesNew[zGroup][client][31], g_fCheckpointTimesNew[zGroup][client][32], g_fCheckpointTimesNew[zGroup][client][33], g_fCheckpointTimesNew[zGroup][client][34], zGroup);
		SQL_TQuery(g_hDb, SQL_updateCheckpointsCallback, szQuery, pack, DBPrio_Low);
	}
}

public void SQL_updateCheckpointsCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_updateCheckpointsCallback): %s", error);
		return;
	}
	ResetPack(data);
	int client = ReadPackCell(data);
	int zonegrp = ReadPackCell(data);
	CloseHandle(data);

	db_viewCheckpointsinZoneGroup(client, g_szSteamID[client], g_szMapName, zonegrp);
}

public void db_deleteCheckpoints()
{
	char szQuery[258];
	Format(szQuery, 258, sql_deleteCheckpoints, g_szMapName);
	SQL_TQuery(g_hDb, SQL_deleteCheckpointsCallback, szQuery, 1, DBPrio_Low);
}

public void SQL_deleteCheckpointsCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_deleteCheckpointsCallback): %s", error);
		return;
	}
}















//////////////////////
//// MapTier /////////
//////////////////////

public void db_insertMapTier(int tier, int zGrp)
{
	char szQuery[256];
	if (g_bTierEntryFound)
	{
		if (zGrp > 0)
		{
			Format(szQuery, 256, sql_updateBonusTier, zGrp, tier, g_szMapName);
		}
		else
		{
			Format(szQuery, 256, sql_updatemaptier, tier, g_szMapName);
		}
		SQL_TQuery(g_hDb, db_insertMapTierCallback, szQuery, 1, DBPrio_Low);
	}
	else
	{
		if (zGrp > 0)
		{
			Format(szQuery, 256, sql_insertBonusTier, zGrp, tier, g_szMapName);
		}
		else
		{
			Format(szQuery, 256, sql_insertmaptier, g_szMapName, tier);
		}
		SQL_TQuery(g_hDb, db_insertMapTierCallback, szQuery, 1, DBPrio_Low);
	}
}

public void db_insertMapTierCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (db_insertMapTierCallback): %s", error);
		return;
	}

	db_selectMapTier();
}

public void db_selectMapTier()
{
	g_bTierEntryFound = false;

	char szQuery[1024];
	Format(szQuery, 1024, sql_selectMapTier, g_szMapName);
	SQL_TQuery(g_hDb, SQL_selectMapTierCallback, szQuery, 1, DBPrio_Low);
}

public void SQL_selectMapTierCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_selectMapTierCallback): %s", error);
		if (!g_bServerDataLoaded)
			db_viewRecordCheckpointInMap();
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		g_bTierEntryFound = true;
		int tier;

		// Format tier string for all
		for (int i = 0; i < 11; i++)
		{
			tier = SQL_FetchInt(hndl, i);
			if (0 < tier < 7)
			{
				g_bTierFound[i] = true;
				if (i == 0)
				{
					g_iMapTier = tier;
					Format(g_sTierString[0], 512, "  %cSurftimer %c| %cMap: %c%s %c| ", LIMEGREEN, WHITE, GREEN, LIMEGREEN, g_szMapName, GREEN);
					switch (tier)
					{
						case 1:Format(g_sTierString[0], 512, "%s%cTier %i %c| ", g_sTierString[0], GRAY, tier, GREEN);
						case 2:Format(g_sTierString[0], 512, "%s%cTier %i %c| ", g_sTierString[0], LIGHTBLUE, tier, GREEN);
						case 3:Format(g_sTierString[0], 512, "%s%cTier %i %c| ", g_sTierString[0], BLUE, tier, GREEN);
						case 4:Format(g_sTierString[0], 512, "%s%cTier %i %c| ", g_sTierString[0], DARKBLUE, tier, GREEN);
						case 5:Format(g_sTierString[0], 512, "%s%cTier %i %c| ", g_sTierString[0], RED, tier, GREEN);
						case 6:Format(g_sTierString[0], 512, "%s%cTier %i %c| ", g_sTierString[0], DARKRED, tier, GREEN);
						default:Format(g_sTierString[0], 512, "%s%cTier %i %c| ", g_sTierString[0], GRAY, tier, GREEN);
					}
					if (g_bhasStages)
					Format(g_sTierString[0], 512, "%s%c%i Stages", g_sTierString[0], MOSSGREEN, (g_mapZonesTypeCount[0][3] + 1));
					else
					Format(g_sTierString[0], 512, "%s%cLinear", g_sTierString[0], LIMEGREEN);

					if (g_bhasBonus)
					if (g_mapZoneGroupCount > 2)
					Format(g_sTierString[0], 512, "%s %c|%c %i Bonuses", g_sTierString[0], GREEN, ORANGE, (g_mapZoneGroupCount - 1));
					else
					Format(g_sTierString[0], 512, "%s %c|%c Bonus", g_sTierString[0], GREEN, ORANGE, (g_mapZoneGroupCount - 1));
				}
				else
				{
					switch (tier)
					{
						case 1:Format(g_sTierString[i], 512, " %cSurftimer %c| &c%s Tier: %i", LIMEGREEN, WHITE, GRAY, g_szZoneGroupName[i], tier);
						case 2:Format(g_sTierString[i], 512, " %cSurftimer %c| &c%s Tier: %i", LIMEGREEN, WHITE, LIGHTBLUE, g_szZoneGroupName[i], tier);
						case 3:Format(g_sTierString[i], 512, " %cSurftimer %c| &c%s Tier: %i", LIMEGREEN, WHITE, BLUE, g_szZoneGroupName[i], tier);
						case 4:Format(g_sTierString[i], 512, " %cSurftimer %c| &c%s Tier: %i", LIMEGREEN, WHITE, DARKBLUE, g_szZoneGroupName[i], tier);
						case 5:Format(g_sTierString[i], 512, " %cSurftimer %c| &c%s Tier: %i", LIMEGREEN, WHITE, RED, g_szZoneGroupName[i], tier);
						case 6:Format(g_sTierString[i], 512, " %cSurftimer %c| &c%s Tier: %i", LIMEGREEN, WHITE, DARKRED, g_szZoneGroupName[i], tier);
					}
				}
			}
		}
	}
	else
	g_bTierEntryFound = false;

	if (!g_bServerDataLoaded)
		db_viewRecordCheckpointInMap();

	return;
}

/////////////////////
//// SQL Bonus //////
/////////////////////

public void db_currentBonusRunRank(int client, int zGroup)
{
	char szQuery[512];
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackCell(pack, zGroup);
	Format(szQuery, 512, "SELECT count(runtime)+1 FROM ck_bonus WHERE mapname = '%s' AND zonegroup = '%i' AND runtime < %f", g_szMapName, zGroup, g_fFinalTime[client]);
	SQL_TQuery(g_hDb, db_viewBonusRunRank, szQuery, pack, DBPrio_Low);
}

public void db_viewBonusRunRank(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (db_viewBonusRunRank): %s", error);
		return;
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	int zGroup = ReadPackCell(pack);
	CloseHandle(pack);
	int rank;
	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		rank = SQL_FetchInt(hndl, 0);
	}

	PrintChatBonus(client, zGroup, rank);
}

public void db_viewMapRankBonus(int client, int zgroup, int type)
{
	char szQuery[1024];
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackCell(pack, zgroup);
	WritePackCell(pack, type);

	Format(szQuery, 1024, sql_selectPlayerRankBonus, g_szSteamID[client], g_szMapName, zgroup, g_szMapName, zgroup);
	SQL_TQuery(g_hDb, db_viewMapRankBonusCallback, szQuery, pack, DBPrio_Low);
}

public void db_viewMapRankBonusCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (db_viewMapRankBonusCallback): %s", error);
		return;
	}

	ResetPack(data);
	int client = ReadPackCell(data);
	int zgroup = ReadPackCell(data);
	int type = ReadPackCell(data);
	CloseHandle(data);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		g_MapRankBonus[zgroup][client] = SQL_GetRowCount(hndl);
	}
	else
	{
		g_MapRankBonus[zgroup][client] = 9999999;
	}

	switch (type)
	{
		case 1: {
			g_iBonusCount[zgroup]++;
			PrintChatBonus(client, zgroup);
		}
		case 2: {
			PrintChatBonus(client, zgroup);
		}
	}
}

//
// Get player rank in bonus - current map
//
public void db_viewPersonalBonusRecords(int client, char szSteamId[32])
{
	char szQuery[1024];
	//"SELECT runtime, zonegroup, style FROM ck_bonus WHERE steamid = '%s AND mapname = '%s' AND runtime > '0.0'";
	Format(szQuery, 1024, sql_selectPersonalBonusRecords, szSteamId, g_szMapName);
	SQL_TQuery(g_hDb, SQL_selectPersonalBonusRecordsCallback, szQuery, client, DBPrio_Low);
}

public void SQL_selectPersonalBonusRecordsCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_selectPersonalBonusRecordsCallback): %s", error);
		if (!g_bSettingsLoaded[client])
			LoadClientSetting(client, g_iSettingToLoad[client]);
		return;
	}

	int zgroup;
	int style;

	for (int i = 0; i < MAXZONEGROUPS; i++)
	{
		g_fPersonalRecordBonus[i][client] = 0.0;
		Format(g_szPersonalRecordBonus[i][client], 64, "N/A");
		for (int s = 1; s < MAX_STYLES; s++)
		{
			g_fStylePersonalRecordBonus[s][i][client] = 0.0;
			Format(g_szStylePersonalRecordBonus[s][i][client], 64, "N/A");
		}
	}

	if (SQL_HasResultSet(hndl))
	{
		while (SQL_FetchRow(hndl))
		{
			zgroup = SQL_FetchInt(hndl, 1);
			style = SQL_FetchInt(hndl, 2);

			if (style == 0)
			{
				g_fPersonalRecordBonus[zgroup][client] = SQL_FetchFloat(hndl, 0);

				if (g_fPersonalRecordBonus[zgroup][client] > 0.0)
				{
					FormatTimeFloat(client, g_fPersonalRecordBonus[zgroup][client], 3, g_szPersonalRecordBonus[zgroup][client], 64);
					db_viewMapRankBonus(client, zgroup, 0); // get rank
				}
				else
				{
					Format(g_szPersonalRecordBonus[zgroup][client], 64, "N/A");
					g_fPersonalRecordBonus[zgroup][client] = 0.0;
				}
			}
			else
			{
				g_fStylePersonalRecordBonus[style][zgroup][client] = SQL_FetchFloat(hndl, 0);

				if (g_fStylePersonalRecordBonus[style][zgroup][client] > 0.0)
				{
					FormatTimeFloat(client, g_fStylePersonalRecordBonus[style][zgroup][client], 3, g_szStylePersonalRecordBonus[style][zgroup][client], 64);
					db_viewMapRankBonusStyle(client, zgroup, 0, style);
				}
				else
				{
					Format(g_szPersonalRecordBonus[zgroup][client], 64, "N/A");
					g_fPersonalRecordBonus[zgroup][client] = 0.0;
				}
			}
		}
	}

	if (!g_bSettingsLoaded[client])
	{
		g_fTick[client][1] = GetGameTime();
		float tick = g_fTick[client][1] - g_fTick[client][0];
		LogToFileEx(g_szLogFile, "[Surftimer] %s: Finished db_viewPersonalBonusRecords in %fs", g_szSteamID[client], tick);
		g_fTick[client][0] = GetGameTime();

		LoadClientSetting(client, g_iSettingToLoad[client]);
	}
	return;
}

public void db_viewFastestBonus()
{
	char szQuery[1024];
	//SELECT name, MIN(runtime), zonegroup, style FROM ck_bonus WHERE mapname = '%s' GROUP BY zonegroup, style;
	Format(szQuery, 1024, sql_selectFastestBonus, g_szMapName);
	SQL_TQuery(g_hDb, SQL_selectFastestBonusCallback, szQuery, 1, DBPrio_High);
}

public void SQL_selectFastestBonusCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_selectFastestBonusCallback): %s", error);

		if (!g_bServerDataLoaded)
		{
			db_viewBonusTotalCount();
		}
		return;
	}

	for (int i = 0; i < MAXZONEGROUPS; i++)
	{
		Format(g_szBonusFastestTime[i], 64, "N/A");
		g_fBonusFastest[i] = 9999999.0;

		for (int s = 1; s < MAX_STYLES; s++)
		{
			Format(g_szStyleBonusFastestTime[s][i], 64, "N/A");
			g_fStyleBonusFastest[s][i] = 9999999.0;
		}
	}

	if (SQL_HasResultSet(hndl))
	{
		int zonegroup;
		int style;
		while (SQL_FetchRow(hndl))
		{
			zonegroup = SQL_FetchInt(hndl, 2);
			style = SQL_FetchInt(hndl, 3);

			if (style == 0)
			{
				SQL_FetchString(hndl, 0, g_szBonusFastest[zonegroup], MAX_NAME_LENGTH);
				g_fBonusFastest[zonegroup] = SQL_FetchFloat(hndl, 1);
				FormatTimeFloat(1, g_fBonusFastest[zonegroup], 3, g_szBonusFastestTime[zonegroup], 64);
			}
			else
			{
				SQL_FetchString(hndl, 0, g_szStyleBonusFastest[style][zonegroup], MAX_NAME_LENGTH);
				g_fStyleBonusFastest[style][zonegroup] = SQL_FetchFloat(hndl, 1);
				FormatTimeFloat(1, g_fStyleBonusFastest[style][zonegroup], 3, g_szStyleBonusFastestTime[style][zonegroup], 64);
			}
		}
	}

	for (int i = 0; i < MAXZONEGROUPS; i++)
	{
		if (g_fBonusFastest[i] == 0.0)
			g_fBonusFastest[i] = 9999999.0;

		for (int s = 1; s < MAX_STYLES; s++)
		{
			if (g_fStyleBonusFastest[s][i] == 0.0)
				g_fStyleBonusFastest[s][i] = 9999999.0;
		}
	}

	if (!g_bServerDataLoaded)
	{
		db_viewBonusTotalCount();
	}
	return;
}

public void db_deleteBonus()
{
	char szQuery[1024];
	Format(szQuery, 1024, sql_deleteBonus, g_szMapName);
	SQL_TQuery(g_hDb, SQL_deleteBonusCallback, szQuery, 1, DBPrio_Low);
}
public void db_viewBonusTotalCount()
{
	char szQuery[1024];
	//SELECT zonegroup, style, count(1) FROM ck_bonus WHERE mapname = '%s' GROUP BY zonegroup, style;
	Format(szQuery, 1024, sql_selectBonusCount, g_szMapName);
	SQL_TQuery(g_hDb, SQL_selectBonusTotalCountCallback, szQuery, 1, DBPrio_Low);
}

public void SQL_selectBonusTotalCountCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_selectBonusTotalCountCallback): %s", error);
		if (!g_bServerDataLoaded)
			db_selectMapTier();
		return;
	}

	for (int i = 1; i < MAXZONEGROUPS; i++)
	g_iBonusCount[i] = 0;

	if (SQL_HasResultSet(hndl))
	{
		int zonegroup;
		int style;
		while (SQL_FetchRow(hndl))
		{
			zonegroup = SQL_FetchInt(hndl, 0);
			style = SQL_FetchInt(hndl, 1);
			if (style == 0)
				g_iBonusCount[zonegroup] = SQL_FetchInt(hndl, 2);
			else
				g_iStyleBonusCount[style][zonegroup] = SQL_FetchInt(hndl, 2);
		}
	}

	if (!g_bServerDataLoaded)
		db_selectMapTier();

	return;
}


public void db_insertBonus(int client, char szSteamId[32], char szUName[32], float FinalTime, int zoneGrp)
{
	char szQuery[1024];
	char szName[MAX_NAME_LENGTH * 2 + 1];
	SQL_EscapeString(g_hDb, szUName, szName, MAX_NAME_LENGTH * 2 + 1);
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackCell(pack, zoneGrp);
	Format(szQuery, 1024, sql_insertBonus, szSteamId, szName, g_szMapName, FinalTime, zoneGrp);
	SQL_TQuery(g_hDb, SQL_insertBonusCallback, szQuery, pack, DBPrio_Low);
}

public void SQL_insertBonusCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_insertBonusCallback): %s", error);
		return;
	}

	ResetPack(data);
	int client = ReadPackCell(data);
	int zgroup = ReadPackCell(data);
	CloseHandle(data);

	db_viewMapRankBonus(client, zgroup, 1);
	// Change to update profile timer, if giving multiplier count or extra points for bonuses
	CalculatePlayerRank(client);
}

public void db_updateBonus(int client, char szSteamId[32], char szUName[32], float FinalTime, int zoneGrp)
{
	char szQuery[1024];
	char szName[MAX_NAME_LENGTH * 2 + 1];
	Handle datapack = CreateDataPack();
	WritePackCell(datapack, client);
	WritePackCell(datapack, zoneGrp);
	SQL_EscapeString(g_hDb, szUName, szName, MAX_NAME_LENGTH * 2 + 1);
	Format(szQuery, 1024, sql_updateBonus, FinalTime, szName, szSteamId, g_szMapName, zoneGrp);
	SQL_TQuery(g_hDb, SQL_updateBonusCallback, szQuery, datapack, DBPrio_Low);
}


public void SQL_updateBonusCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_updateBonusCallback): %s", error);
		return;
	}

	ResetPack(data);
	int client = ReadPackCell(data);
	int zgroup = ReadPackCell(data);
	CloseHandle(data);

	db_viewMapRankBonus(client, zgroup, 2);

	CalculatePlayerRank(client);
}

public void SQL_deleteBonusCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_deleteBonusCallback): %s", error);
		return;
	}
}

public void db_selectBonusCount()
{
	char szQuery[258];
	Format(szQuery, 258, sql_selectTotalBonusCount);
	SQL_TQuery(g_hDb, SQL_selectBonusCountCallback, szQuery, 1, DBPrio_Low);
}

public void SQL_selectBonusCountCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_selectBonusCountCallback): %s", error);
		return;
	}

	if (SQL_HasResultSet(hndl))
	{
		char mapName[128];
		char mapName2[128];
		g_totalBonusCount = 0;
		while (SQL_FetchRow(hndl))
		{
			SQL_FetchString(hndl, 0, mapName2, 128);
			for (int i = 0; i < GetArraySize(g_MapList); i++)
			{
				GetArrayString(g_MapList, i, mapName, 128);
				if (StrEqual(mapName, mapName2, false))
				g_totalBonusCount++;
			}
		}
	}
	else
	{
		g_totalBonusCount = 0;
	}
	SetSkillGroups();
}














////////////////////////////
//// SQL Zones /////////////
////////////////////////////

public void db_setZoneNames(int client, char szName[128])
{
	char szQuery[512], szEscapedName[128 * 2 + 1];
	SQL_EscapeString(g_hDb, szName, szEscapedName, 128 * 2 + 1);
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackCell(pack, g_CurrentSelectedZoneGroup[client]);
	WritePackString(pack, szEscapedName);
	// UPDATE ck_zones SET zonename = '%s' WHERE mapname = '%s' AND zonegroup = '%i';
	Format(szQuery, 512, sql_setZoneNames, szEscapedName, g_szMapName, g_CurrentSelectedZoneGroup[client]);
	SQL_TQuery(g_hDb, sql_setZoneNamesCallback, szQuery, pack, DBPrio_Low);
}

public void sql_setZoneNamesCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (sql_setZoneNamesCallback): %s", error);
		CloseHandle(data);
		return;
	}

	char szName[64];
	ResetPack(data);
	int client = ReadPackCell(data);
	int zonegrp = ReadPackCell(data);
	ReadPackString(data, szName, 64);
	CloseHandle(data);

	for (int i = 0; i < g_mapZonesCount; i++)
	{
		if (g_mapZones[i][zoneGroup] == zonegrp)
		Format(g_mapZones[i][zoneName], 64, szName);
	}

	if (IsValidClient(client))
	{
		PrintToChat(client, " %cSurftimer %c| Bonus name succesfully changed.", LIMEGREEN, WHITE);
		ListBonusSettings(client);
	}
	db_selectMapZones();
}

public void db_checkAndFixZoneIds()
{
	char szQuery[512];
	//"SELECT mapname, zoneid, zonetype, zonetypeid, pointa_x, pointa_y, pointa_z, pointb_x, pointb_y, pointb_z, vis, team, zonegroup, zonename FROM ck_zones WHERE mapname = '%s' ORDER BY zoneid ASC";
	if (!g_szMapName[0])
	GetCurrentMap(g_szMapName, 128);

	Format(szQuery, 512, sql_selectZoneIds, g_szMapName);
	SQL_TQuery(g_hDb, db_checkAndFixZoneIdsCallback, szQuery, 1, DBPrio_Low);
}

public void db_checkAndFixZoneIdsCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (db_checkAndFixZoneIdsCallback): %s", error);
		return;
	}

	if (SQL_HasResultSet(hndl))
	{
		bool IDError = false;
		float x1[128], y1[128], z1[128], x2[128], y2[128], z2[128];
		int checker = 0, i, zonetype[128], zonetypeid[128], vis[128], team[128], zoneGrp[128];
		char zName[128][128];

		while (SQL_FetchRow(hndl))
		{
			i = SQL_FetchInt(hndl, 1);
			zonetype[checker] = SQL_FetchInt(hndl, 2);
			zonetypeid[checker] = SQL_FetchInt(hndl, 3);
			x1[checker] = SQL_FetchFloat(hndl, 4);
			y1[checker] = SQL_FetchFloat(hndl, 5);
			z1[checker] = SQL_FetchFloat(hndl, 6);
			x2[checker] = SQL_FetchFloat(hndl, 7);
			y2[checker] = SQL_FetchFloat(hndl, 8);
			z2[checker] = SQL_FetchFloat(hndl, 9);
			vis[checker] = SQL_FetchInt(hndl, 10);
			team[checker] = SQL_FetchInt(hndl, 11);
			zoneGrp[checker] = SQL_FetchInt(hndl, 12);
			SQL_FetchString(hndl, 13, zName[checker], 128);

			if (i != checker)
			IDError = true;

			checker++;
		}

		if (IDError)
		{
			char szQuery[256];
			Format(szQuery, 256, sql_deleteMapZones, g_szMapName);
			SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, DBPrio_Low);
			//SQL_FastQuery(g_hDb, szQuery);

			for (int k = 0; k < checker; k++)
			{
				db_insertZoneCheap(k, zonetype[k], zonetypeid[k], x1[k], y1[k], z1[k], x2[k], y2[k], z2[k], vis[k], team[k], zoneGrp[k], zName[k], -10);
			}
		}
	}
	db_selectMapZones();
}

public void ZoneDefaultName(int zonetype, int zonegroup, char zName[128])
{
	if (zonegroup > 0)
	{
		Format(zName, 64, "BONUS %i", zonegroup);
	}
	else
	if (-1 < zonetype < ZONEAMOUNT)
	Format(zName, 128, "%s %i", g_szZoneDefaultNames[zonetype], zonegroup);
	else
	Format(zName, 64, "Unknown");
}

public void db_insertZoneCheap(int zoneid, int zonetype, int zonetypeid, float pointax, float pointay, float pointaz, float pointbx, float pointby, float pointbz, int vis, int team, int zGrp, char zName[128], int query)
{
	char szQuery[1024];
	//"INSERT INTO ck_zones (mapname, zoneid, zonetype, zonetypeid, pointa_x, pointa_y, pointa_z, pointb_x, pointb_y, pointb_z, vis, team, zonegroup, zonename) VALUES ('%s', '%i', '%i', '%i', '%f', '%f', '%f', '%f', '%f', '%f', '%i', '%i', '%i', '%s')";
	Format(szQuery, 1024, sql_insertZones, g_szMapName, zoneid, zonetype, zonetypeid, pointax, pointay, pointaz, pointbx, pointby, pointbz, vis, team, zGrp, zName);
	SQL_TQuery(g_hDb, SQL_insertZonesCheapCallback, szQuery, query, DBPrio_Low);
}

public void SQL_insertZonesCheapCallback(Handle owner, Handle hndl, const char[] error, any query)
{
	if (hndl == null)
	{
		PrintToChatAll(" %cSurftimer %c| Failed to create a zone, attempting a fix... Recreate the zone, please.", LIMEGREEN, WHITE);
		db_checkAndFixZoneIds();
		return;
	}
	if (query == (g_mapZonesCount - 1))
	db_selectMapZones();
}

public void db_insertZone(int zoneid, int zonetype, int zonetypeid, float pointax, float pointay, float pointaz, float pointbx, float pointby, float pointbz, int vis, int team, int zonegroup)
{
	char szQuery[1024];
	char zName[128];

	if (zonegroup == g_mapZoneGroupCount)
	ZoneDefaultName(zonetype, zonegroup, zName);
	else
	Format(zName, 128, g_szZoneGroupName[zonegroup]);

	//"INSERT INTO ck_zones (mapname, zoneid, zonetype, zonetypeid, pointa_x, pointa_y, pointa_z, pointb_x, pointb_y, pointb_z, vis, team, zonegroup, zonename) VALUES ('%s', '%i', '%i', '%i', '%f', '%f', '%f', '%f', '%f', '%f', '%i', '%i', '%i', '%s')";
	Format(szQuery, 1024, sql_insertZones, g_szMapName, zoneid, zonetype, zonetypeid, pointax, pointay, pointaz, pointbx, pointby, pointbz, vis, team, zonegroup, zName);
	SQL_TQuery(g_hDb, SQL_insertZonesCallback, szQuery, 1, DBPrio_Low);
}

public void SQL_insertZonesCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{

		PrintToChatAll(" %cSurftimer %c| Failed to create a zone, attempting a fix... Recreate the zone, please.", LIMEGREEN, WHITE);
		db_checkAndFixZoneIds();
		return;
	}

	db_selectMapZones();
}

public void db_insertZoneHook(int zoneid, int zonetype, int zonetypeid, int vis, int team, int zonegroup, char[] szHookName)
{
	char szQuery[1024];
	char zName[128];

	if (zonegroup == g_mapZoneGroupCount)
	ZoneDefaultName(zonetype, zonegroup, zName);
	else
	Format(zName, 128, g_szZoneGroupName[zonegroup]);

	//"INSERT INTO ck_zones (mapname, zoneid, zonetype, zonetypeid, pointa_x, pointa_y, pointa_z, pointb_x, pointb_y, pointb_z, vis, team, zonegroup, zonename) VALUES ('%s', '%i', '%i', '%i', '%f', '%f', '%f', '%f', '%f', '%f', '%i', '%i', '%i', '%s')";
	Format(szQuery, 1024, "INSERT INTO ck_zones (mapname, zoneid, zonetype, zonetypeid, pointa_x, pointa_y, pointa_z, pointb_x, pointb_y, pointb_z, vis, team, zonegroup, zonename, hookname) VALUES ('%s', '%i', '%i', '%i', '%f', '%f', '%f', '%f', '%f', '%f', '%i', '%i', '%i','%s','%s')", g_szMapName, zoneid, zonetype, zonetypeid, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, vis, team, zonegroup, zName, szHookName);
	SQL_TQuery(g_hDb, SQL_insertZonesCallback, szQuery, 1, DBPrio_Low);
}

public void db_saveZones()
{
	char szQuery[258];
	Format(szQuery, 258, sql_deleteMapZones, g_szMapName);
	SQL_TQuery(g_hDb, SQL_saveZonesCallBack, szQuery, 1, DBPrio_Low);
}

public void SQL_saveZonesCallBack(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_saveZonesCallBack): %s", error);
		return;
	}
	char szzone[128];
	for (int i = 0; i < g_mapZonesCount; i++)
	{
		Format(szzone, 128, "%s", g_szZoneGroupName[g_mapZones[i][zoneGroup]]);
		if (g_mapZones[i][PointA][0] != -1.0 && g_mapZones[i][PointA][1] != -1.0 && g_mapZones[i][PointA][2] != -1.0)
		db_insertZoneCheap(g_mapZones[i][zoneId], g_mapZones[i][zoneType], g_mapZones[i][zoneTypeId], g_mapZones[i][PointA][0], g_mapZones[i][PointA][1], g_mapZones[i][PointA][2], g_mapZones[i][PointB][0], g_mapZones[i][PointB][1], g_mapZones[i][PointB][2], g_mapZones[i][Vis], g_mapZones[i][Team], g_mapZones[i][zoneGroup], szzone, i);
	}
}

public void db_updateZone(int zoneid, int zonetype, int zonetypeid, float[] Point1, float[] Point2, int vis, int team, int zonegroup, int onejumplimit)
{
	char szQuery[1024];
	Format(szQuery, 1024, sql_updateZone, zonetype, zonetypeid, Point1[0], Point1[1], Point1[2], Point2[0], Point2[1], Point2[2], vis, team, onejumplimit, zonegroup, zoneid, g_szMapName);
	SQL_TQuery(g_hDb, SQL_updateZoneCallback, szQuery, 1, DBPrio_Low);
}

public void SQL_updateZoneCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_updateZoneCallback): %s", error);
		return;
	}

	db_selectMapZones();
}

public int db_deleteZonesInGroup(int client)
{
	char szQuery[258];

	if (g_CurrentSelectedZoneGroup[client] < 1)
	{
		if(IsValidClient(client))
		PrintToChat(client, "[%cCKc%] Invalid zonegroup index selected, aborting. (%i)", LIMEGREEN, WHITE, g_CurrentSelectedZoneGroup[client]);

		PrintToServer("surftimer | Invalid zonegroup index selected, aborting. (%i)", g_CurrentSelectedZoneGroup[client]);
	}

	Transaction h_DeleteZoneGroup = SQL_CreateTransaction();

	Format(szQuery, 258, sql_deleteZonesInGroup, g_szMapName, g_CurrentSelectedZoneGroup[client]);
	SQL_AddQuery(h_DeleteZoneGroup, szQuery);

	Format(szQuery, 258, "UPDATE ck_zones SET zonegroup = zonegroup-1 WHERE zonegroup > %i AND mapname = '%s';", g_CurrentSelectedZoneGroup[client], g_szMapName);
	SQL_AddQuery(h_DeleteZoneGroup, szQuery);

	Format(szQuery, 258, "DELETE FROM ck_bonus WHERE zonegroup = %i AND mapname = '%s';", g_CurrentSelectedZoneGroup[client], g_szMapName);
	SQL_AddQuery(h_DeleteZoneGroup, szQuery);

	Format(szQuery, 258, "UPDATE ck_bonus SET zonegroup = zonegroup-1 WHERE zonegroup > %i AND mapname = '%s';", g_CurrentSelectedZoneGroup[client], g_szMapName);
	SQL_AddQuery(h_DeleteZoneGroup, szQuery);

	SQL_ExecuteTransaction(g_hDb, h_DeleteZoneGroup, SQLTxn_ZoneGroupRemovalSuccess, SQLTxn_ZoneGroupRemovalFailed, client);

}

public void SQLTxn_ZoneGroupRemovalSuccess(Handle db, any client, int numQueries, Handle[] results, any[] queryData)
{
	PrintToServer("surftimer | Zonegroup removal was successful");

	db_selectMapZones();
	db_viewFastestBonus();
	db_viewBonusTotalCount();
	db_viewRecordCheckpointInMap();

	if (IsValidClient(client))
	{
		ZoneMenu(client);
		PrintToChat(client, " %cSurftimer %c| Zone group deleted.", LIMEGREEN, WHITE);
	}
	return;
}

public void SQLTxn_ZoneGroupRemovalFailed(Handle db, any client, int numQueries, const char[] error, int failIndex, any[] queryData)
{
	if(IsValidClient(client))
	PrintToChat(client, " %cSurftimer %c| Zonegroup removal failed! (Error: %s)", LIMEGREEN, WHITE, error);

	PrintToServer("surftimer | Zonegroup removal failed (Error: %s)", error);
	return;
}

public void db_selectzoneTypeIds(int zonetype, int client, int zonegrp)
{
	char szQuery[258];
	Format(szQuery, 258, sql_selectzoneTypeIds, g_szMapName, zonetype, zonegrp);
	SQL_TQuery(g_hDb, SQL_selectzoneTypeIdsCallback, szQuery, client, DBPrio_Low);
}

public void SQL_selectzoneTypeIdsCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_selectzoneTypeIdsCallback): %s", error);
		return;
	}

	if (SQL_HasResultSet(hndl))
	{
		int availableids[MAXZONES] =  { 0, ... }, i;
		while (SQL_FetchRow(hndl))
		{
			i = SQL_FetchInt(hndl, 0);
			if (i < MAXZONES)
			availableids[i] = 1;
		}
		Menu TypeMenu = new Menu(Handle_EditZoneTypeId);
		char MenuNum[24], MenuInfo[6], MenuItemName[24];
		int x = 0;
		// Types: Start(1), End(2), Stage(3), Checkpoint(4), Speed(5), TeleToStart(6), Validator(7), Chekcer(8), Stop(0) //fluffys AntiJump(9), AntiDuck(10)
		switch (g_CurrentZoneType[data]) {
			case 0:Format(MenuItemName, 24, "Stop");
			case 1:Format(MenuItemName, 24, "Start");
			case 2:Format(MenuItemName, 24, "End");
			case 3: {
				Format(MenuItemName, 24, "Stage");
				x = 2;
			}
			case 4:Format(MenuItemName, 24, "Checkpoint");
			case 5:Format(MenuItemName, 24, "Speed");
			case 6:Format(MenuItemName, 24, "TeleToStart");
			case 7:Format(MenuItemName, 24, "Validator");
			case 8:Format(MenuItemName, 24, "Checker");
			//fluffys
			case 9:Format(MenuItemName, 24, "AntiJump");
			case 10:Format(MenuItemName, 24, "AntiDuck");
			case 11:Format(MenuItemName, 24, "MaxSpeed");
			default:Format(MenuItemName, 24, "Unknown");
		}

		for (int k = 0; k < 35; k++)
		{
			if (availableids[k] == 0)
			{
				Format(MenuNum, sizeof(MenuNum), "%s-%i", MenuItemName, (k + x));
				Format(MenuInfo, sizeof(MenuInfo), "%i", k);
				TypeMenu.AddItem(MenuInfo, MenuNum);
			}
		}
		TypeMenu.ExitButton = true;
		TypeMenu.Display(data, MENU_TIME_FOREVER);
	}
}
/*
public checkZoneTypeIds()
{
InitZoneVariables();

char szQuery[258];
Format(szQuery, 258, "SELECT `zonegroup` ,`zonetype`, `zonetypeid`  FROM `ck_zones` WHERE `mapname` = '%s';", g_szMapName);
SQL_TQuery(g_hDb, checkZoneTypeIdsCallback, szQuery, 1, DBPrio_High);
}

public checkZoneTypeIdsCallback(Handle owner, Handle hndl, const char[] error, any:data)
{
if(hndl == null)
{
LogError("[Surftimer] SQL Error (checkZoneTypeIds): %s", error);
return;
}
if(SQL_HasResultSet(hndl))
{
int idChecker[MAXZONEGROUPS][ZONEAMOUNT][MAXZONES], idCount[MAXZONEGROUPS][ZONEAMOUNT];
char szQuery[258];
//  Fill array with id's
// idChecker = map zones in
while (SQL_FetchRow(hndl))
{
idChecker[SQL_FetchInt(hndl, 0)][SQL_FetchInt(hndl, 1)][SQL_FetchInt(hndl, 2)] = 1;
idCount[SQL_FetchInt(hndl, 0)][SQL_FetchInt(hndl, 1)]++;
}
for (int i = 0; i < MAXZONEGROUPS; i++)
{
for (int j = 0; j < ZONEAMOUNT; j++)
{
for (int k = 0; k < idCount[i][j]; k++)
{
if (idChecker[i][j][k] == 1)
continue;
else
{
PrintToServer("[Surftimer] Error on zonetype: %i, zonetypeid: %i", i, idChecker[i][k]);
Format(szQuery, 258, "UPDATE `ck_zones` SET zonetypeid = zonetypeid-1 WHERE mapname = '%s' AND zonetype = %i AND zonetypeid > %i AND zonegroup = %i;", g_szMapName, j, k, i);
SQL_LockDatabase(g_hDb);
SQL_FastQuery(g_hDb, szQuery);
SQL_UnlockDatabase(g_hDb);
}
}
}
}

Format(szQuery, 258, "SELECT `zoneid` FROM `ck_zones` WHERE mapname = '%s' ORDER BY zoneid ASC;", g_szMapName);
SQL_TQuery(g_hDb, checkZoneIdsCallback, szQuery, 1, DBPrio_High);
}
}

public checkZoneIdsCallback(Handle owner, Handle hndl, const char[] error, any:data)
{
if(hndl == null)
{
LogError("[Surftimer] SQL Error (checkZoneIdsCallback): %s", error);
return;
}

if(SQL_HasResultSet(hndl))
{
int i = 0;
char szQuery[258];
while (SQL_FetchRow(hndl))
{
if (SQL_FetchInt(hndl, 0) == i)
{
i++;
continue;
}
else
{
PrintToServer("[Surftimer] Found an error in ZoneID's. Fixing...");
Format(szQuery, 258, "UPDATE `ck_zones` SET zoneid = %i WHERE mapname = '%s' AND zoneid = %i", i, g_szMapName, SQL_FetchInt(hndl, 0));
SQL_LockDatabase(g_hDb);
SQL_FastQuery(g_hDb, szQuery);
SQL_UnlockDatabase(g_hDb);
i++;
}
}

char szQuery2[258];
Format(szQuery2, 258, "SELECT `zonegroup` FROM `ck_zones` WHERE `mapname` = '%s' ORDER BY `zonegroup` ASC;", g_szMapName);
SQL_TQuery(g_hDb, checkZoneGroupIds, szQuery2, 1, DBPrio_Low);
}
}

public checkZoneGroupIds(Handle owner, Handle hndl, const char[] error, any:data)
{
if(hndl == null)
{
LogError("[Surftimer] SQL Error (checkZoneGroupIds): %s", error);
return;
}

if(SQL_HasResultSet(hndl))
{
int i = 0;
char szQuery[258];
while (SQL_FetchRow(hndl))
{
if (SQL_FetchInt(hndl, 0) == i)
continue;
else if (SQL_FetchInt(hndl, 0) == (i+1))
i++;
else
{
i++;
PrintToServer("[Surftimer] Found an error in zoneGroupID's. Fixing...");
Format(szQuery, 258, "UPDATE `ck_zones` SET `zonegroup` = %i WHERE `mapname` = '%s' AND `zonegroup` = %i", i, g_szMapName, SQL_FetchInt(hndl, 0));
SQL_LockDatabase(g_hDb);
SQL_FastQuery(g_hDb, szQuery);
SQL_UnlockDatabase(g_hDb);
}
}
db_selectMapZones();
}
}
*/
public void db_selectMapZones()
{
	char szQuery[258];
	Format(szQuery, 258, sql_selectMapZones, g_szMapName);
	SQL_TQuery(g_hDb, SQL_selectMapZonesCallback, szQuery, 1, DBPrio_High);
}

public void SQL_selectMapZonesCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_selectMapZonesCallback): %s", error);
		if (!g_bServerDataLoaded)
		{
			db_GetMapRecord_Pro();
		}
		return;
	}

	RemoveZones();

	if (SQL_HasResultSet(hndl))
	{
		g_mapZonesCount = 0;
		g_bhasStages = false;
		g_bhasBonus = false;
		g_mapZoneGroupCount = 0; // 1 = No Bonus, 2 = Bonus, >2 = Multiple bonuses

		for (int i = 0; i < MAXZONES; i++)
		{
			g_mapZones[i][zoneId] = -1;
			g_mapZones[i][PointA] = -1.0;
			g_mapZones[i][PointB] = -1.0;
			g_mapZones[i][zoneId] = -1;
			g_mapZones[i][zoneType] = -1;
			g_mapZones[i][zoneTypeId] = -1;
			g_mapZones[i][zoneName] = 0;
			g_mapZones[i][hookName] = 0;
			g_mapZones[i][Vis] = 0;
			g_mapZones[i][Team] = 0;
			g_mapZones[i][zoneGroup] = 0;
			g_mapZones[i][targetName] = 0;
			g_mapZones[i][oneJumpLimit] = 1;
		}

		for (int x = 0; x < MAXZONEGROUPS; x++)
		{
			g_mapZoneCountinGroup[x] = 0;
			for (int k = 0; k < ZONEAMOUNT; k++)
			g_mapZonesTypeCount[x][k] = 0;
		}

		int zoneIdChecker[MAXZONES], zoneTypeIdChecker[MAXZONEGROUPS][ZONEAMOUNT][MAXZONES], zoneTypeIdCheckerCount[MAXZONEGROUPS][ZONEAMOUNT], zoneGroupChecker[MAXZONEGROUPS];

		// Types: Start(1), End(2), Stage(3), Checkpoint(4), Speed(5), TeleToStart(6), Validator(7), Chekcer(8), Stop(0)
		while (SQL_FetchRow(hndl))
		{
			g_mapZones[g_mapZonesCount][zoneId] = SQL_FetchInt(hndl, 0);
			g_mapZones[g_mapZonesCount][zoneType] = SQL_FetchInt(hndl, 1);
			g_mapZones[g_mapZonesCount][zoneTypeId] = SQL_FetchInt(hndl, 2);
			g_mapZones[g_mapZonesCount][PointA][0] = SQL_FetchFloat(hndl, 3);
			g_mapZones[g_mapZonesCount][PointA][1] = SQL_FetchFloat(hndl, 4);
			g_mapZones[g_mapZonesCount][PointA][2] = SQL_FetchFloat(hndl, 5);
			g_mapZones[g_mapZonesCount][PointB][0] = SQL_FetchFloat(hndl, 6);
			g_mapZones[g_mapZonesCount][PointB][1] = SQL_FetchFloat(hndl, 7);
			g_mapZones[g_mapZonesCount][PointB][2] = SQL_FetchFloat(hndl, 8);
			g_mapZones[g_mapZonesCount][Vis] = SQL_FetchInt(hndl, 9);
			g_mapZones[g_mapZonesCount][Team] = SQL_FetchInt(hndl, 10);
			g_mapZones[g_mapZonesCount][zoneGroup] = SQL_FetchInt(hndl, 11);


			/**
			* Initialize error checking
			* 0 = zone not found
			* 1 = zone found
			*
			* IDs must be in order 0, 1, 2.... n
			* Duplicate zoneids not possible due to primary key
			*/
			zoneIdChecker[g_mapZones[g_mapZonesCount][zoneId]]++;
			if (zoneGroupChecker[g_mapZones[g_mapZonesCount][zoneGroup]] != 1)
			{
				// 1 = No Bonus, 2 = Bonus, >2 = Multiple bonuses
				g_mapZoneGroupCount++;
				zoneGroupChecker[g_mapZones[g_mapZonesCount][zoneGroup]] = 1;
			}

			// You can have the same zonetype and zonetypeid values in different zonegroups
			zoneTypeIdChecker[g_mapZones[g_mapZonesCount][zoneGroup]][g_mapZones[g_mapZonesCount][zoneType]][g_mapZones[g_mapZonesCount][zoneTypeId]]++;
			zoneTypeIdCheckerCount[g_mapZones[g_mapZonesCount][zoneGroup]][g_mapZones[g_mapZonesCount][zoneType]]++;

			SQL_FetchString(hndl, 12, g_mapZones[g_mapZonesCount][zoneName], 128);
			SQL_FetchString(hndl, 13, g_mapZones[g_mapZonesCount][hookName], 128);
			SQL_FetchString(hndl, 14, g_mapZones[g_mapZonesCount][targetName], 128);
			g_mapZones[g_mapZonesCount][oneJumpLimit] = SQL_FetchInt(hndl, 15);

			if (!g_mapZones[g_mapZonesCount][zoneName][0])
			{
				switch (g_mapZones[g_mapZonesCount][zoneType])
				{
					case 0: {
						Format(g_mapZones[g_mapZonesCount][zoneName], 128, "Stop-%i", g_mapZones[g_mapZonesCount][zoneTypeId]);
					}
					case 1: {
						if (g_mapZones[g_mapZonesCount][zoneGroup] > 0)
						{
							g_bhasBonus = true;
							Format(g_mapZones[g_mapZonesCount][zoneName], 128, "BonusStart-%i", g_mapZones[g_mapZonesCount][zoneTypeId]);
							Format(g_szZoneGroupName[g_mapZones[g_mapZonesCount][zoneGroup]], 128, "BONUS %i", g_mapZones[g_mapZonesCount][zoneGroup]);
						}
						else
						Format(g_mapZones[g_mapZonesCount][zoneName], 128, "Start-%i", g_mapZones[g_mapZonesCount][zoneTypeId]);
					}
					case 2: {
						if (g_mapZones[g_mapZonesCount][zoneGroup] > 0)
						Format(g_mapZones[g_mapZonesCount][zoneName], 128, "BonusEnd-%i", g_mapZones[g_mapZonesCount][zoneTypeId]);
						else
						Format(g_mapZones[g_mapZonesCount][zoneName], 128, "End-%i", g_mapZones[g_mapZonesCount][zoneTypeId]);
					}
					case 3: {
						g_bhasStages = true;
						Format(g_mapZones[g_mapZonesCount][zoneName], 128, "Stage-%i", (g_mapZones[g_mapZonesCount][zoneTypeId] + 2));
					}
					case 4: {
						Format(g_mapZones[g_mapZonesCount][zoneName], 128, "Checkpoint-%i", g_mapZones[g_mapZonesCount][zoneTypeId]);
					}
					case 5: {
						Format(g_mapZones[g_mapZonesCount][zoneName], 128, "Speed-%i", g_mapZones[g_mapZonesCount][zoneTypeId]);
					}
					case 6: {
						Format(g_mapZones[g_mapZonesCount][zoneName], 128, "TeleToStart-%i", g_mapZones[g_mapZonesCount][zoneTypeId]);
					}
					case 7: {
						Format(g_mapZones[g_mapZonesCount][zoneName], 128, "Validator-%i", g_mapZones[g_mapZonesCount][zoneTypeId]);
					}
					case 8: {
						Format(g_mapZones[g_mapZonesCount][zoneName], 128, "Checker-%i", g_mapZones[g_mapZonesCount][zoneTypeId]);
					}
					case 9: { //fluffys
						Format(g_mapZones[g_mapZonesCount][zoneName], 128, "AntiJump-%i", g_mapZones[g_mapZonesCount][zoneTypeId]);
					}
					case 10: {
						Format(g_mapZones[g_mapZonesCount][zoneName], 128, "AntiDuck-%i", g_mapZones[g_mapZonesCount][zoneTypeId]);
					}
					case 11: {
						Format(g_mapZones[g_mapZonesCount][zoneName], 128, "MaxSpeed-%i", g_mapZones[g_mapZonesCount][zoneTypeId]);
					}
				}
			}
			else
			{
				switch (g_mapZones[g_mapZonesCount][zoneType])
				{
					case 1:
					{
						if (g_mapZones[g_mapZonesCount][zoneGroup] > 0)
						g_bhasBonus = true;
						Format(g_szZoneGroupName[g_mapZones[g_mapZonesCount][zoneGroup]], 128, "%s", g_mapZones[g_mapZonesCount][zoneName]);
					}
					case 3:
					g_bhasStages = true;

				}
			}

			/**
			*	Count zone center
			**/
			// Center
			float posA[3], posB[3], result[3];
			Array_Copy(g_mapZones[g_mapZonesCount][PointA], posA, 3);
			Array_Copy(g_mapZones[g_mapZonesCount][PointB], posB, 3);
			AddVectors(posA, posB, result);
			g_mapZones[g_mapZonesCount][CenterPoint][0] = FloatDiv(result[0], 2.0);
			g_mapZones[g_mapZonesCount][CenterPoint][1] = FloatDiv(result[1], 2.0);
			g_mapZones[g_mapZonesCount][CenterPoint][2] = FloatDiv(result[2], 2.0);

			for (int i = 0; i < 3; i++)
			{
				g_fZoneCorners[g_mapZonesCount][0][i] = g_mapZones[g_mapZonesCount][PointA][i];
				g_fZoneCorners[g_mapZonesCount][7][i] = g_mapZones[g_mapZonesCount][PointB][i];
			}

			// Zone counts:
			g_mapZonesTypeCount[g_mapZones[g_mapZonesCount][zoneGroup]][g_mapZones[g_mapZonesCount][zoneType]]++;
			g_mapZonesCount++;
		}
		// Count zone corners
		// https://forums.alliedmods.net/showpost.php?p=2006539&postcount=8
		for (int x = 0; x < g_mapZonesCount; x++)
		{
			for(int i = 1; i < 7; i++)
			{
				for(int j = 0; j < 3; j++)
				{
					g_fZoneCorners[x][i][j] = g_fZoneCorners[x][((i >> (2-j)) & 1) * 7][j];
				}
			}
		}

		/**
		* Check for errors
		*
		* 1. ZoneId
		*/
		char szQuery[258];
		for (int i = 0; i < g_mapZonesCount; i++)
		if (zoneIdChecker[i] == 0)
		{
			PrintToServer("[Surftimer] Found an error in zoneid : %i", i);
			Format(szQuery, 258, "UPDATE `ck_zones` SET zoneid = zoneid-1 WHERE mapname = '%s' AND zoneid > %i", g_szMapName, i);
			PrintToServer("Query: %s", szQuery);
			SQL_TQuery(g_hDb, sql_zoneFixCallback, szQuery, -1, DBPrio_Low);
			return;
		}

		// 2nd ZoneGroup
		for (int i = 0; i < g_mapZoneGroupCount; i++)
		if (zoneGroupChecker[i] == 0)
		{
			PrintToServer("[Surftimer] Found an error in zonegroup %i (ZoneGroups total: %i)", i, g_mapZoneGroupCount);
			Format(szQuery, 258, "UPDATE `ck_zones` SET `zonegroup` = zonegroup-1 WHERE `mapname` = '%s' AND `zonegroup` > %i", g_szMapName, i);
			SQL_TQuery(g_hDb, sql_zoneFixCallback, szQuery, zoneGroupChecker[i], DBPrio_Low);
			return;
		}

		// 3rd ZoneTypeId
		for (int i = 0; i < g_mapZoneGroupCount; i++)
		for (int k = 0; k < ZONEAMOUNT; k++)
		for (int x = 0; x < zoneTypeIdCheckerCount[i][k]; x++)
		if (zoneTypeIdChecker[i][k][x] != 1 && (k == 3) || (k == 4))
		{
			if (zoneTypeIdChecker[i][k][x] == 0)
			{
				PrintToServer("[Surftimer] ZoneTypeID missing! [ZoneGroup: %i ZoneType: %i, ZonetypeId: %i]", i, k, x);
				Format(szQuery, 258, "UPDATE `ck_zones` SET zonetypeid = zonetypeid-1 WHERE mapname = '%s' AND zonetype = %i AND zonetypeid > %i AND zonegroup = %i;", g_szMapName, k, x, i);
				SQL_TQuery(g_hDb, sql_zoneFixCallback, szQuery, -1, DBPrio_Low);
				return;
			}
			else if (zoneTypeIdChecker[i][k][x] > 1)
			{
				char szerror[258];
				Format(szerror, 258, "[Surftimer] Duplicate Stage Zone ID's on %s [ZoneGroup: %i, ZoneType: 3, ZoneTypeId: %i]", g_szMapName, k, x);
				LogError(szerror);
			}
		}

		RefreshZones();

		// Set mapzone count in group
		for (int x = 0; x < g_mapZoneGroupCount; x++)
		for (int k = 0; k < ZONEAMOUNT; k++)
		if (g_mapZonesTypeCount[x][k] > 0)
		g_mapZoneCountinGroup[x]++;

		if (!g_bServerDataLoaded)
		{
			db_GetMapRecord_Pro();
		}

		return;
	}
}

public void sql_zoneFixCallback(Handle owner, Handle hndl, const char[] error, any zongeroup)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (sql_zoneFixCallback): %s", error);
		return;
	}
	if (zongeroup == -1)
	{
		db_selectMapZones();
	}
	else
	{
		char szQuery[258];
		Format(szQuery, 258, "DELETE FROM `ck_bonus` WHERE `mapname` = '%s' AND `zonegroup` = %i;", g_szMapName, zongeroup);
		SQL_TQuery(g_hDb, sql_zoneFixCallback2, szQuery, zongeroup, DBPrio_Low);
	}
}

public void sql_zoneFixCallback2(Handle owner, Handle hndl, const char[] error, any zongeroup)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (sql_zoneFixCallback2): %s", error);
		return;
	}

	char szQuery[258];
	Format(szQuery, 258, "UPDATE ck_bonus SET zonegroup = zonegroup-1 WHERE `mapname` = '%s' AND `zonegroup` = %i;", g_szMapName, zongeroup);
	SQL_TQuery(g_hDb, sql_zoneFixCallback, szQuery, -1, DBPrio_Low);
}

public void db_deleteMapZones()
{
	char szQuery[258];
	Format(szQuery, 258, sql_deleteMapZones, g_szMapName);
	SQL_TQuery(g_hDb, SQL_deleteMapZonesCallback, szQuery, 1, DBPrio_Low);
}

public void SQL_deleteMapZonesCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_deleteMapZonesCallback): %s", error);
		return;
	}
}

public void db_deleteZone(int client, int zoneid)
{
	char szQuery[258];
	Transaction h_deleteZone = SQL_CreateTransaction();

	Format(szQuery, 258, sql_deleteZone, g_szMapName, zoneid);
	SQL_AddQuery(h_deleteZone, szQuery);

	Format(szQuery, 258, "UPDATE ck_zones SET zoneid = zoneid-1 WHERE mapname = '%s' AND zoneid > %i", g_szMapName, zoneid);
	SQL_AddQuery(h_deleteZone, szQuery);

	SQL_ExecuteTransaction(g_hDb, h_deleteZone, SQLTxn_ZoneRemovalSuccess, SQLTxn_ZoneRemovalFailed, client);
}

public void SQLTxn_ZoneRemovalSuccess(Handle db, any client, int numQueries, Handle[] results, any[] queryData)
{
	if (IsValidClient(client))
	PrintToChat(client, " %cSurftimer %c| Zone Removed Succesfully", LIMEGREEN, WHITE);
	PrintToServer("[Surftimer] Zone Removed Succesfully");
}

public void SQLTxn_ZoneRemovalFailed(Handle db, any client, int numQueries, const char[] error, int failIndex, any[] queryData)
{
	if (IsValidClient(client))
	PrintToChat(client, " %cSurftimer %c| %cZone Removal Failed! Error:%c %s", LIMEGREEN, WHITE, RED, WHITE, error);
	PrintToServer("[Surftimer] Zone Removal Failed. Error: %s", error);
	return;
}












///////////////////////
//// MISC /////////////
///////////////////////


public void db_insertLastPosition(int client, char szMapName[128], int stage, int zgroup)
{
	if (GetConVarBool(g_hcvarRestore) && !g_bRoundEnd && (StrContains(g_szSteamID[client], "STEAM_") != -1) && g_bTimeractivated[client])
	{
		Handle pack = CreateDataPack();
		WritePackCell(pack, client);
		WritePackString(pack, szMapName);
		WritePackString(pack, g_szSteamID[client]);
		WritePackCell(pack, stage);
		WritePackCell(pack, zgroup);
		char szQuery[512];
		Format(szQuery, 512, "SELECT * FROM ck_playertemp WHERE steamid = '%s'", g_szSteamID[client]);
		SQL_TQuery(g_hDb, db_insertLastPositionCallback, szQuery, pack, DBPrio_Low);
	}
}

public void db_insertLastPositionCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (db_insertLastPositionCallback): %s", error);
		return;
	}

	char szQuery[1024];
	char szMapName[128];
	char szSteamID[32];

	ResetPack(data);
	int client = ReadPackCell(data);
	ReadPackString(data, szMapName, 128);
	ReadPackString(data, szSteamID, 32);
	int stage = ReadPackCell(data);
	int zgroup = ReadPackCell(data);
	CloseHandle(data);

	if (1 <= client <= MaxClients)
	{
		if (!g_bTimeractivated[client])
		g_fPlayerLastTime[client] = -1.0;
		int tickrate = g_Server_Tickrate * 5 * 11;
		if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
		{
			Format(szQuery, 1024, sql_updatePlayerTmp, g_fPlayerCordsLastPosition[client][0], g_fPlayerCordsLastPosition[client][1], g_fPlayerCordsLastPosition[client][2], g_fPlayerAnglesLastPosition[client][0], g_fPlayerAnglesLastPosition[client][1], g_fPlayerAnglesLastPosition[client][2], g_fPlayerLastTime[client], szMapName, tickrate, stage, zgroup, szSteamID);
			SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, DBPrio_Low);
		}
		else
		{
			Format(szQuery, 1024, sql_insertPlayerTmp, g_fPlayerCordsLastPosition[client][0], g_fPlayerCordsLastPosition[client][1], g_fPlayerCordsLastPosition[client][2], g_fPlayerAnglesLastPosition[client][0], g_fPlayerAnglesLastPosition[client][1], g_fPlayerAnglesLastPosition[client][2], g_fPlayerLastTime[client], szSteamID, szMapName, tickrate, stage, zgroup);
			SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, DBPrio_Low);
		}
	}
}

public void db_deletePlayerTmps()
{
	char szQuery[64];
	Format(szQuery, 64, "delete FROM ck_playertemp");
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, DBPrio_Low);
}

public void db_ViewLatestRecords(int client)
{
	SQL_TQuery(g_hDb, sql_selectLatestRecordsCallback, sql_selectLatestRecords, client, DBPrio_Low);
}

public void sql_selectLatestRecordsCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (sql_selectLatestRecordsCallback): %s", error);
		return;
	}

	char szName[64];
	char szMapName[64];
	char szDate[64];
	char szTime[32];
	float ftime;
	PrintToConsole(data, "----------------------------------------------------------------------------------------------------");
	PrintToConsole(data, "Last map records:");
	if (SQL_HasResultSet(hndl))
	{
		Menu menu = CreateMenu(LatestRecordsMenuHandler);
		SetMenuTitle(menu, "Recently Broken Records");

		int i = 1;
		char szItem[128];
		while (SQL_FetchRow(hndl))
		{
			SQL_FetchString(hndl, 0, szName, 64);
			ftime = SQL_FetchFloat(hndl, 1);
			FormatTimeFloat(data, ftime, 3, szTime, sizeof(szTime));
			SQL_FetchString(hndl, 2, szMapName, 64);
			SQL_FetchString(hndl, 3, szDate, 64);
			Format(szItem, sizeof(szItem), "%s - %s by %s (%s)", szMapName, szTime, szName, szDate);
			PrintToConsole(data, szItem);
			AddMenuItem(menu, "", szItem, ITEMDRAW_DISABLED);
			i++;
		}
		if (i == 1)
		{
			PrintToConsole(data, "No records found.");
			CloseHandle(menu);
		}
		else
		{
			SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
			DisplayMenu(menu, data, MENU_TIME_FOREVER);
		}
	}
	else
	PrintToConsole(data, "No records found.");
	PrintToConsole(data, "----------------------------------------------------------------------------------------------------");
	PrintToChat(data, " %cSurftimer %c| See console for output!", LIMEGREEN, WHITE);
}

public int LatestRecordsMenuHandler(Handle menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
		CloseHandle(menu);
}

public void db_InsertLatestRecords(char szSteamID[32], char szName[32], float FinalTime)
{
	char szQuery[512];
	Format(szQuery, 512, sql_insertLatestRecords, szSteamID, szName, FinalTime, g_szMapName);
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, DBPrio_Low);
}

public void GetDBName(int client, char szSteamId[32])
{
	char szQuery[512];
	Format(szQuery, 512, sql_selectRankedPlayer, szSteamId);
	SQL_TQuery(g_hDb, GetDBNameCallback, szQuery, client, DBPrio_Low);
}

public void GetDBNameCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (GetDBNameCallback): %s", error);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		SQL_FetchString(hndl, 1, g_szProfileName[data], MAX_NAME_LENGTH);
		db_viewPlayerAll(data, g_szProfileName[data]);
	}
}

public void db_CalcAvgRunTime()
{
	char szQuery[256];
	Format(szQuery, 256, sql_selectAllMapTimesinMap, g_szMapName);
	SQL_TQuery(g_hDb, SQL_db_CalcAvgRunTimeCallback, szQuery, DBPrio_Low);
}

public void SQL_db_CalcAvgRunTimeCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_db_CalcAvgRunTimeCallback): %s", error);

		if (!g_bServerDataLoaded && g_bhasBonus)
			db_CalcAvgRunTimeBonus();
		else if (!g_bServerDataLoaded)
			db_CalculatePlayerCount();

		return;
	}

	g_favg_maptime = 0.0;
	if (SQL_HasResultSet(hndl))
	{
		int rowcount = SQL_GetRowCount(hndl);
		int i, protimes;
		float ProTime;
		while (SQL_FetchRow(hndl))
		{
			float pro = SQL_FetchFloat(hndl, 0);
			if (pro > 0.0)
			{
				ProTime += pro;
				protimes++;
			}
			i++;
			if (rowcount == i)
			{
				g_favg_maptime = ProTime / protimes;
			}
		}
	}

	if (g_bhasBonus)
		db_CalcAvgRunTimeBonus();
	else
		db_CalculatePlayerCount();
}
public void db_CalcAvgRunTimeBonus()
{
	char szQuery[256];
	Format(szQuery, 256, sql_selectAllBonusTimesinMap, g_szMapName);
	SQL_TQuery(g_hDb, SQL_db_CalcAvgRunBonusTimeCallback, szQuery, 1, DBPrio_Low);
}

public void SQL_db_CalcAvgRunBonusTimeCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_db_CalcAvgRunTimeCallback): %s", error);
		if (!g_bServerDataLoaded)
		db_CalculatePlayerCount();
		return;
	}

	for (int i = 1; i < MAXZONEGROUPS; i++)
	g_fAvg_BonusTime[i] = 0.0;

	if (SQL_HasResultSet(hndl))
	{
		int zonegroup, runtimes[MAXZONEGROUPS];
		float runtime[MAXZONEGROUPS], time;
		while (SQL_FetchRow(hndl))
		{
			zonegroup = SQL_FetchInt(hndl, 0);
			time = SQL_FetchFloat(hndl, 1);
			if (time > 0.0)
			{
				runtime[zonegroup] += time;
				runtimes[zonegroup]++;
			}
		}

		for (int i = 1; i < MAXZONEGROUPS; i++)
		g_fAvg_BonusTime[i] = runtime[i] / runtimes[i];
	}

	if (!g_bServerDataLoaded)
		db_CalculatePlayerCount();

	return;
}

public void db_GetDynamicTimelimit()
{
	if (!GetConVarBool(g_hDynamicTimelimit))
	{
		if (!g_bServerDataLoaded)
			db_GetTotalStages();
		return;
	}
	char szQuery[256];
	Format(szQuery, 256, sql_selectAllMapTimesinMap, g_szMapName);
	SQL_TQuery(g_hDb, SQL_db_GetDynamicTimelimitCallback, szQuery, DBPrio_Low);
}


public void SQL_db_GetDynamicTimelimitCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_db_GetDynamicTimelimitCallback): %s", error);
		loadAllClientSettings();
		return;
	}

	if (SQL_HasResultSet(hndl))
	{
		int maptimes = 0;
		float total = 0.0, time = 0.0;
		while (SQL_FetchRow(hndl))
		{
			time = SQL_FetchFloat(hndl, 0);
			if (time > 0.0)
			{
				total += time;
				maptimes++;
			}
		}
		//requires min. 5 map times
		if (maptimes > 5)
		{
			int scale_factor = 3;
			int avg = RoundToNearest((total) / 60.0 / float(maptimes));

			//scale factor
			if (avg <= 10)
			scale_factor = 5;
			if (avg <= 5)
			scale_factor = 8;
			if (avg <= 3)
			scale_factor = 10;
			if (avg <= 2)
			scale_factor = 12;
			if (avg <= 1)
			scale_factor = 14;

			avg = avg * scale_factor;

			//timelimit: min 20min, max 120min
			if (avg < 20)
			avg = 20;
			if (avg > 120)
			avg = 120;

			//set timelimit
			char szTimelimit[32];
			Format(szTimelimit, 32, "mp_timelimit %i;mp_roundtime %i", avg, avg);
			ServerCommand(szTimelimit);
			ServerCommand("mp_restartgame 1");
		}
		else
		ServerCommand("mp_timelimit 50");
	}

	if (!g_bServerDataLoaded)
		db_GetTotalStages();
		//loadAllClientSettings();

	return;
}


public void db_CalculatePlayerCount()
{
	char szQuery[255];
	Format(szQuery, 255, sql_CountRankedPlayers);
	SQL_TQuery(g_hDb, sql_CountRankedPlayersCallback, szQuery, DBPrio_Low);
}

public void db_CalculatePlayersCountGreater0()
{
	char szQuery[255];
	Format(szQuery, 255, sql_CountRankedPlayers2);
	SQL_TQuery(g_hDb, sql_CountRankedPlayers2Callback, szQuery, DBPrio_Low);
}



public void sql_CountRankedPlayersCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (sql_CountRankedPlayersCallback): %s", error);
		db_CalculatePlayersCountGreater0();
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		g_pr_AllPlayers = SQL_FetchInt(hndl, 0);
	}
	else
	g_pr_AllPlayers = 1;

	//get amount of players with actual player points
	db_CalculatePlayersCountGreater0();
	return;
}

public void sql_CountRankedPlayers2Callback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (sql_CountRankedPlayers2Callback): %s", error);
		if (!g_bServerDataLoaded)
		db_selectSpawnLocations();
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		g_pr_RankedPlayers = SQL_FetchInt(hndl, 0);
	}
	else
	g_pr_RankedPlayers = 0;

	if (!g_bServerDataLoaded)
	db_selectSpawnLocations();

	return;
}


public void db_ClearLatestRecords()
{
	if (g_DbType == MYSQL)
		SQL_TQuery(g_hDb, SQL_CheckCallback, "DELETE FROM ck_latestrecords WHERE date < NOW() - INTERVAL 1 WEEK", DBPrio_Low);
	else
		SQL_TQuery(g_hDb, SQL_CheckCallback, "DELETE FROM ck_latestrecords WHERE date <= date('now','-7 day')", DBPrio_Low);

	if (!g_bServerDataLoaded)
		db_GetDynamicTimelimit();
}

public void db_viewUnfinishedMaps(int client, char szSteamId[32])
{
	if (IsValidClient(client))
	{
		PrintToChat(client, "%t", "ConsoleOutput", LIMEGREEN, WHITE);
		ProfileMenu(client, -1, 0);
	}
	else
	return;

	char szQuery[720];
	// Gets all players unfinished maps and bonuses from the database
	Format(szQuery, 720, "SELECT mapname, zonegroup, zonename, (SELECT tier FROM ck_maptier d WHERE d.mapname = a.mapname) AS tier FROM ck_zones a WHERE (zonetype = 1 OR zonetype = 5) AND (SELECT runtimepro FROM ck_playertimes b WHERE b.mapname = a.mapname AND a.zonegroup = 0 AND b.style = 0 AND steamid = '%s' UNION SELECT runtime FROM ck_bonus c WHERE c.mapname = a.mapname AND c.zonegroup = a.zonegroup AND c.style = 0 AND steamid = '%s') IS NULL GROUP BY mapname, zonegroup ORDER BY tier, mapname, zonegroup ASC", szSteamId, szSteamId);
	SQL_TQuery(g_hDb, db_viewUnfinishedMapsCallback, szQuery, client, DBPrio_Low);
}

public void db_viewUnfinishedMapsCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (db_viewUnfinishedMapsCallback): %s", error);
		return;
	}

	if (SQL_HasResultSet(hndl))
	{
		char szMap[128], szMap2[128], tmpMap[128], consoleString[1024], unfinishedBonusBuffer[772], zName[128];
		bool mapUnfinished, bonusUnfinished;
		int zGrp, count, mapCount, bonusCount, mapListSize = GetArraySize(g_MapList), digits;
		float time = 0.5;
		int tier;
		while (SQL_FetchRow(hndl))
		{
			// Get the map and check that it is in the mapcycle
			SQL_FetchString(hndl, 0, szMap, 128);
			tier = SQL_FetchInt(hndl, 3);
			for (int i = 0; i < mapListSize; i++)
			{
				GetArrayString(g_MapList, i, szMap2, 128);
				if (StrEqual(szMap, szMap2, false))
				{
					// Map is in the mapcycle, and is unfinished

					// Initialize the name
					if (!tmpMap[0])
					strcopy(tmpMap, 128, szMap);

					// Check if the map changed, if so announce to client's console
					if (!StrEqual(szMap, tmpMap, false))
					{
						if (count < 10)
						digits = 1;
						else
						if (count < 100)
						digits = 2;
						else
						digits = 3;

						if (strlen(tmpMap) < (13-digits)) // <- 11
							Format(tmpMap, 128, "%s - Tier %i:\t\t\t\t", tmpMap, tier);
						else if ((12-digits) < strlen(tmpMap) < (21-digits)) // 12 - 19
							Format(tmpMap, 128, "%s - Tier %i:\t\t\t", tmpMap, tier);
						else if ((20-digits) < strlen(tmpMap) < (28-digits)) // 20 - 25
							Format(tmpMap, 128, "%s - Tier %i:\t\t", tmpMap, tier);
						else
							Format(tmpMap, 128, "%s - Tier %i:\t", tmpMap, tier);

						count++;
						if (!mapUnfinished) // Only bonus is unfinished
						Format(consoleString, 1024, "%i. %s\t\t|  %s", count, tmpMap, unfinishedBonusBuffer);
						else if (!bonusUnfinished) // Only map is unfinished
						Format(consoleString, 1024, "%i. %sMap unfinished\t|", count, tmpMap);
						else // Both unfinished
						Format(consoleString, 1024, "%i. %sMap unfinished\t|  %s", count, tmpMap, unfinishedBonusBuffer);

						// Throttle messages to not cause errors on huge mapcycles
						time = time + 0.1;
						Handle pack = CreateDataPack();
						WritePackCell(pack, client);
						WritePackString(pack, consoleString);
						CreateTimer(time, PrintUnfinishedLine, pack);

						mapUnfinished = false;
						bonusUnfinished = false;
						consoleString[0] = '\0';
						unfinishedBonusBuffer[0] = '\0';
						strcopy(tmpMap, 128, szMap);
					}

					zGrp = SQL_FetchInt(hndl, 1);
					if (zGrp < 1)
					{
						mapUnfinished = true;
						mapCount++;
					}
					else
					{
						SQL_FetchString(hndl, 2, zName, 128);

						if (!zName[0])
						Format(zName, 128, "BONUS %i", zGrp);

						if (bonusUnfinished)
						Format(unfinishedBonusBuffer, 772, "%s, %s", unfinishedBonusBuffer, zName);
						else
						{
							bonusUnfinished = true;
							Format(unfinishedBonusBuffer, 772, "Bonus: %s", zName);
						}
						bonusCount++;
					}
					break;
				}
			}
		}
		if (IsValidClient(client))
		{
			PrintToConsole(client, " ");
			PrintToConsole(client, "------- User Stats -------");
			PrintToConsole(client, "%i unfinished maps of total %i maps", mapCount, g_pr_MapCount);
			PrintToConsole(client, "%i unfinished bonuses", bonusCount);
			PrintToConsole(client, "SteamID: %s", g_szProfileSteamId[client]);
			PrintToConsole(client, "--------------------------");
			PrintToConsole(client, " ");
			PrintToConsole(client, "------------------------------ Map Details -----------------------------");
		}
	}
	return;
}
public Action PrintUnfinishedLine(Handle timer, any pack)
{
	ResetPack(pack);
	int client = ReadPackCell(pack);
	char teksti[1024];
	ReadPackString(pack, teksti, 1024);
	CloseHandle(pack);
	PrintToConsole(client, teksti);

}

/*
void PrintUnfinishedLine(Handle pack)
{
ResetPack(pack);
int client = ReadPackCell(pack);
char teksti[1024];
ReadPackString(pack, teksti, 1024);
CloseHandle(pack);
PrintToConsole(client, teksti);
}
*/
public void db_viewPlayerProfile1(int client, char szPlayerName[MAX_NAME_LENGTH])
{
	char szQuery[512];
	char szName[MAX_NAME_LENGTH * 2 + 1];
	SQL_EscapeString(g_hDb, szPlayerName, szName, MAX_NAME_LENGTH * 2 + 1);
	Format(szQuery, 512, sql_selectPlayerRankAll2, szName);
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, szPlayerName);
	SQL_TQuery(g_hDb, SQL_ViewPlayerProfile1Callback, szQuery, pack, DBPrio_Low);
}

public void SQL_ViewPlayerProfile1Callback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_ViewPlayerProfile1Callback): %s", error);
		return;
	}
	char szPlayerName[MAX_NAME_LENGTH];

	ResetPack(data);
	int client = ReadPackCell(data);
	ReadPackString(data, szPlayerName, MAX_NAME_LENGTH);
	CloseHandle(data);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		SQL_FetchString(hndl, 1, g_szProfileSteamId[client], 32);
		db_viewPlayerRank(client, g_szProfileSteamId[client]);
	}
	else
	{
		char szQuery[512];
		char szName[MAX_NAME_LENGTH * 2 + 1];
		SQL_EscapeString(g_hDb, szPlayerName, szName, MAX_NAME_LENGTH * 2 + 1);
		Format(szQuery, 512, sql_selectPlayerRankAll, PERCENT, szName, PERCENT);
		SQL_TQuery(g_hDb, SQL_ViewPlayerProfile2Callback, szQuery, client, DBPrio_Low);
	}
}


public void sql_selectPlayerNameCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (sql_selectPlayerNameCallback): %s", error);
		return;
	}

	ResetPack(data);
	int clientid = ReadPackCell(data);
	int client = ReadPackCell(data);
	CloseHandle(data);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		SQL_FetchString(hndl, 0, g_pr_szName[clientid], 64);
		g_bProfileRecalc[clientid] = true;
		if (IsValidClient(client))
		PrintToConsole(client, "Profile refreshed (%s).", g_pr_szSteamID[clientid]);
	}
	else
	if (IsValidClient(client))
	PrintToConsole(client, "SteamID %s not found.", g_pr_szSteamID[clientid]);
}

//
// 0. Admins counting players points starts here
//
public void RefreshPlayerRankTable(int max)
{
	g_pr_Recalc_ClientID = 1;
	g_pr_RankingRecalc_InProgress = true;
	char szQuery[255];

	//SELECT steamid, name from ck_playerrank where points > 0 ORDER BY points DESC";
	//SELECT steamid, name from ck_playerrank where points > 0 ORDER BY points DESC
	Format(szQuery, 255, sql_selectRankedPlayers);
	SQL_TQuery(g_hDb, sql_selectRankedPlayersCallback, szQuery, max, DBPrio_Low);
}

public void sql_selectRankedPlayersCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (sql_selectRankedPlayersCallback): %s", error);
		return;
	}

	if (SQL_HasResultSet(hndl))
	{
		int i = 66;
		int x;
		g_pr_TableRowCount = SQL_GetRowCount(hndl);
		if (g_pr_TableRowCount == 0)
		{
			for (int c = 1; c <= MaxClients; c++)
			if (1 <= c <= MaxClients && IsValidEntity(c) && IsValidClient(c))
			{
				if (g_bManualRecalc)
				PrintToChat(c, "%t", "PrUpdateFinished", LIMEGREEN, WHITE, LIMEGREEN);
			}
			g_bManualRecalc = false;
			g_pr_RankingRecalc_InProgress = false;

			if (IsValidClient(g_pr_Recalc_AdminID))
			{
				PrintToConsole(g_pr_Recalc_AdminID, ">> Recalculation finished");
				CreateTimer(0.1, RefreshAdminMenu, g_pr_Recalc_AdminID, TIMER_FLAG_NO_MAPCHANGE);
			}
		}
		if (MAX_PR_PLAYERS != data && g_pr_TableRowCount > data)
		x = 66 + data;
		else
		x = 66 + g_pr_TableRowCount;

		if (g_pr_TableRowCount > MAX_PR_PLAYERS)
		g_pr_TableRowCount = MAX_PR_PLAYERS;

		if (x > MAX_PR_PLAYERS)
		x = MAX_PR_PLAYERS - 1;
		if (IsValidClient(g_pr_Recalc_AdminID) && g_bManualRecalc)
		{
			int max = MAX_PR_PLAYERS - 66;
			PrintToConsole(g_pr_Recalc_AdminID, " \n>> Recalculation started! (Only Top %i because of performance reasons)", max);
		}
		while (SQL_FetchRow(hndl))
		{
			if (i <= x)
			{
				g_pr_points[i] = 0;
				SQL_FetchString(hndl, 0, g_pr_szSteamID[i], 32);
				SQL_FetchString(hndl, 1, g_pr_szName[i], 64);

				g_bProfileRecalc[i] = true;
				i++;
			}
			if (i == x)
			{
				CalculatePlayerRank(66);
			}
		}
	}
	else
	PrintToConsole(g_pr_Recalc_AdminID, " \n>> No valid players found!");
}

public void db_Cleanup()
{
	char szQuery[255];

	//tmps
	Format(szQuery, 255, "DELETE FROM ck_playertemp where mapname != '%s'", g_szMapName);
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery);

	//times
	SQL_TQuery(g_hDb, SQL_CheckCallback, "DELETE FROM ck_playertimes where runtimepro = -1.0");

	//fluffys pointless players
	SQL_TQuery(g_hDb, SQL_CheckCallback, "DELETE FROM ck_playerrank WHERE `points` <= 0");
	/*SQL_TQuery(g_hDb, SQL_CheckCallback, "DELETE FROM ck_wrcps WHERE `runtimepro` <= -1.0");
	SQL_TQuery(g_hDb, SQL_CheckCallback, "DELETE FROM ck_wrcps WHERE `stage` = 0");*/

}

public void SQL_InsertPlayerCallBack(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_InsertPlayerCallBack): %s", error);
		return;
	}

	if (IsClientInGame(data))
	db_UpdateLastSeen(data);
}


public void db_UpdateLastSeen(int client)
{
	if ((StrContains(g_szSteamID[client], "STEAM_") != -1) && !IsFakeClient(client))
	{
		char szQuery[512];
		if (g_DbType == MYSQL)
		Format(szQuery, 512, sql_UpdateLastSeenMySQL, g_szSteamID[client]);
		else
		if (g_DbType == SQLITE)
		Format(szQuery, 512, sql_UpdateLastSeenSQLite, g_szSteamID[client]);
		SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, DBPrio_Low);
	}
}


/////////////////////////////
///// DEFAULT CALLBACKS /////
/////////////////////////////

public void SQL_CheckCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_CheckCallback): %s", error);
		return;
	}
}


public void SQL_CheckCallback2(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_CheckCallback2): %s", error);
		return;
	}

	db_viewMapProRankCount();
	db_GetMapRecord_Pro();
}

public void SQL_CheckCallback3(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_CheckCallback3): %s", error);
		return;
	}

	char steamid[128];

	ResetPack(data);
	int client = ReadPackCell(data);
	ReadPackString(data, steamid, 128);
	CloseHandle(data);

	RecalcPlayerRank(client, steamid);
	db_viewMapProRankCount();
	db_GetMapRecord_Pro();
}

public void SQL_CheckCallback4(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_CheckCallback4): %s", error);
		return;
	}
	char steamid[128];

	ResetPack(data);
	int client = ReadPackCell(data);
	ReadPackString(data, steamid, 128);
	CloseHandle(data);

	RecalcPlayerRank(client, steamid);
}














///////////////////////////
///// PLAYER OPTIONS //////
///////////////////////////

public void db_viewPlayerOptions(int client, char szSteamId[32])
{
	g_bLoadedModules[client] = false;
	char szQuery[1024];
	Format(szQuery, 1024, sql_selectPlayerOptions, szSteamId);
	SQL_TQuery(g_hDb, db_viewPlayerOptionsCallback, szQuery, client, DBPrio_Low);
}

public void db_viewPlayerOptionsCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (db_viewPlayerOptionsCallback): %s", error);
		if (!g_bSettingsLoaded[client])
			LoadClientSetting(client, g_iSettingToLoad[client]);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		//"SELECT timer, hide, sounds, chat, viewmodel, autobhop, checkpoints, gradient, speedmode, centrehud, module1c, module2c, module3c, module4c, module5c, module6c, sidehud, module1s, module2s, module3s, module4s, module5s FROM ck_playeroptions2 where steamid = '%s';"

		g_bTimerEnabled[client] = view_as<bool>(SQL_FetchInt(hndl, 0));
		g_bHide[client] = view_as<bool>(SQL_FetchInt(hndl, 1));
		g_bEnableQuakeSounds[client] = view_as<bool>(SQL_FetchInt(hndl, 2));
		g_bHideChat[client] = view_as<bool>(SQL_FetchInt(hndl, 3));
		g_bViewModel[client] = view_as<bool>(SQL_FetchInt(hndl, 4));
		g_bAutoBhopClient[client] = view_as<bool>(SQL_FetchInt(hndl, 5));
		g_bCheckpointsEnabled[client] = view_as<bool>(SQL_FetchInt(hndl, 6));
		g_SpeedGradient[client] = SQL_FetchInt(hndl, 7);
		g_SpeedMode[client] = SQL_FetchInt(hndl, 8);
		g_bCenterSpeedDisplay[client] = view_as<bool>(SQL_FetchInt(hndl, 9));
		g_bCentreHud[client] = view_as<bool>(SQL_FetchInt(hndl, 10));
		g_iCentreHudModule[client][0] = SQL_FetchInt(hndl, 11);
		g_iCentreHudModule[client][1] = SQL_FetchInt(hndl, 12);
		g_iCentreHudModule[client][2] = SQL_FetchInt(hndl, 13);
		g_iCentreHudModule[client][3] = SQL_FetchInt(hndl, 14);
		g_iCentreHudModule[client][4] = SQL_FetchInt(hndl, 15);
		g_iCentreHudModule[client][5] = SQL_FetchInt(hndl, 16);
		g_bSideHud[client] = view_as<bool>(SQL_FetchInt(hndl, 17));
		g_iSideHudModule[client][0] = SQL_FetchInt(hndl, 18);
		g_iSideHudModule[client][1] = SQL_FetchInt(hndl, 19);
		g_iSideHudModule[client][2] = SQL_FetchInt(hndl, 20);
		g_iSideHudModule[client][3] = SQL_FetchInt(hndl, 21);
		g_iSideHudModule[client][4] = SQL_FetchInt(hndl, 22);

		// Functionality for normal spec list
		if (g_iSideHudModule[client][0] == 5 && (g_iSideHudModule[client][1] == 0 && g_iSideHudModule[client][2] == 0 && g_iSideHudModule[client][3] == 0 && g_iSideHudModule[client][4] == 0))
			g_bSpecListOnly[client] = true;
		else
			g_bSpecListOnly[client] = false;
		
		g_bLoadedModules[client] = true;
	}
	else
	{
		char szQuery[512];
		if (!IsValidClient(client))
		return;

		//"INSERT INTO ck_playeroptions2 (steamid, timer, hide, sounds, chat, viewmodel, autobhop, checkpoints, centrehud, module1c, module2c, module3c, module4c, module5c, module6c, sidehud, module1s, module2s, module3s, module4s, module5s) VALUES('%s', '%i', '%i', '%i', '%i', '%i', '%i', '%i', '%i', '%i', '%i', '%i', '%i', '%i', '%i', '%i', '%i', '%i', '%i', '%i', '%i');";

		Format(szQuery, 1024, sql_insertPlayerOptions, g_szSteamID[client]);
		SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, DBPrio_Low);

		g_bTimerEnabled[client] = true;
		g_bHide[client] = false;
		g_bEnableQuakeSounds[client] = true;
		g_bHideChat[client] = false;
		g_bViewModel[client] = true;
		g_bAutoBhopClient[client] = true;
		g_bCheckpointsEnabled[client] = true;
		g_SpeedGradient[client] = 3;
		g_SpeedMode[client] = 0;
		g_bCenterSpeedDisplay[client] = false;
		g_bCentreHud[client] = true;
		g_iCentreHudModule[client][0] = 1;
		g_iCentreHudModule[client][1] = 2;
		g_iCentreHudModule[client][2] = 3;
		g_iCentreHudModule[client][3] = 4;
		g_iCentreHudModule[client][4] = 5;
		g_iCentreHudModule[client][5] = 6;
		g_bSideHud[client] = true;
		g_iSideHudModule[client][0] = 5;
		g_iSideHudModule[client][1] = 0;
		g_iSideHudModule[client][2] = 0;
		g_iSideHudModule[client][3] = 0;
		g_iSideHudModule[client][4] = 0;
		g_bSpecListOnly[client] = true;
	}

	if (!g_bSettingsLoaded[client])
	{
		g_fTick[client][1] = GetGameTime();
		float tick = g_fTick[client][1] - g_fTick[client][0];
		LogToFileEx(g_szLogFile, "[Surftimer] %s: Finished db_viewPlayerOptions in %fs", g_szSteamID[client], tick);
		g_fTick[client][0] = GetGameTime();

		LoadClientSetting(client, g_iSettingToLoad[client]);
	}
	return;
}

public void db_updatePlayerOptions(int client)
{
	char szQuery[1024];
	// "UPDATE ck_playeroptions2 SET timer = %i, hide = %i, sounds = %i, chat = %i, viewmodel = %i, autobhop = %i, checkpoints = %i, centrehud = %i, module1c = %i, module2c = %i, module3c = %i, module4c = %i, module5c = %i, module6c = %i, sidehud = %i, module1s = %i, module2s = %i, module3s = %i, module4s = %i, module5s = %i where steamid = '%s'";
	if (g_bSettingsLoaded[client] && g_bServerDataLoaded && g_bLoadedModules[client])
	{
		Format(szQuery, 1024, sql_updatePlayerOptions, BooltoInt(g_bTimerEnabled[client]), BooltoInt(g_bHide[client]), BooltoInt(g_bEnableQuakeSounds[client]),  BooltoInt(g_bHideChat[client]),  BooltoInt(g_bViewModel[client]),  BooltoInt(g_bAutoBhopClient[client]),  BooltoInt(g_bCheckpointsEnabled[client]),  g_SpeedGradient[client], g_SpeedMode[client], BooltoInt(g_bCenterSpeedDisplay[client]), BooltoInt(g_bCentreHud[client]), g_iCentreHudModule[client][0], g_iCentreHudModule[client][1], g_iCentreHudModule[client][2], g_iCentreHudModule[client][3], g_iCentreHudModule[client][4], g_iCentreHudModule[client][5],  BooltoInt(g_bSideHud[client]), g_iSideHudModule[client][0], g_iSideHudModule[client][1], g_iSideHudModule[client][2], g_iSideHudModule[client][3], g_iSideHudModule[client][4], g_szSteamID[client]);
		SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, client, DBPrio_Low);
	}
}















//////////////////////////////
/// MENUS ////////////////////
//////////////////////////////


public void db_selectTopProRecordHolders(int client)
{
	char szQuery[512];
	Format(szQuery, 512, sql_selectMapRecordHolders);
	SQL_TQuery(g_hDb, db_sql_selectMapRecordHoldersCallback, szQuery, client);
}

public void db_sql_selectMapRecordHoldersCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (db_sql_selectMapRecordHoldersCallback): %s", error);
		return;
	}

	char szSteamID[32];
	char szRecords[64];
	char szQuery[256];
	int records = 0;
	if (SQL_HasResultSet(hndl))
	{
		int i = SQL_GetRowCount(hndl);
		int x = i;
		g_menuTopSurfersMenu[data] = new Menu(TopProHoldersHandler1);
		g_menuTopSurfersMenu[data].SetTitle("Top 5 Pro Surfers\n#   Records       Player");
		while (SQL_FetchRow(hndl))
		{
			SQL_FetchString(hndl, 0, szSteamID, 32);
			records = SQL_FetchInt(hndl, 1);
			if (records > 9)
			Format(szRecords, 64, "%i", records);
			else
			Format(szRecords, 64, "%i  ", records);

			Handle pack = CreateDataPack();
			WritePackCell(pack, data);
			WritePackString(pack, szRecords);
			WritePackCell(pack, i);
			WritePackString(pack, szSteamID);
			Format(szQuery, 256, sql_selectRankedPlayer, szSteamID);
			SQL_TQuery(g_hDb, db_sql_selectMapRecordHoldersCallback2, szQuery, pack);
			i--;
		}
		if (x == 0)
		{
			PrintToChat(data, "%t", "NoRecordTop", LIMEGREEN, WHITE);
			ckTopMenu(data);
		}
	}
	else
	{
		PrintToChat(data, "%t", "NoRecordTop", LIMEGREEN, WHITE);
		ckTopMenu(data);
	}
}

public void db_sql_selectMapRecordHoldersCallback2(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (db_sql_selectMapRecordHoldersCallback2): %s", error);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		char szName[MAX_NAME_LENGTH];
		char szSteamID[32];
		char szRecords[64];
		char szValue[128];

		ResetPack(data);
		int client = ReadPackCell(data);
		ReadPackString(data, szRecords, 64);
		int count = ReadPackCell(data);
		ReadPackString(data, szSteamID, 32);
		CloseHandle(data);

		SQL_FetchString(hndl, 1, szName, MAX_NAME_LENGTH);
		Format(szValue, 128, "      %s       »  %s", szRecords, szName);
		g_menuTopSurfersMenu[client].AddItem(szSteamID, szValue, ITEMDRAW_DEFAULT);
		if (count == 1)
		{
			g_menuTopSurfersMenu[client].OptionFlags = MENUFLAG_BUTTON_EXIT;
			g_menuTopSurfersMenu[client].Display(client, MENU_TIME_FOREVER);
		}
	}
}

public void db_selectTopPlayers(int client)
{
	char szQuery[128];
	Format(szQuery, 128, sql_selectTopPlayers);
	SQL_TQuery(g_hDb, db_selectTop100PlayersCallback, szQuery, client, DBPrio_Low);
}

public void db_selectTop100PlayersCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (db_selectTop100PlayersCallback): %s", error);
		return;
	}

	char szValue[128];
	char szName[64];
	char szRank[16];
	char szSteamID[32];
	char szPerc[16];
	int points;
	Menu menu = new Menu(TopPlayersMenuHandler1);
	menu.SetTitle("Top 100 Players\n    Rank   Points       Maps            Player");
	menu.Pagination = 5;
	if (SQL_HasResultSet(hndl))
	{
		int i = 1;
		while (SQL_FetchRow(hndl))
		{
			SQL_FetchString(hndl, 0, szName, 64);
			if (i == 100)
			Format(szRank, 16, "[%i.]", i);
			else
			if (i < 10)
			Format(szRank, 16, "[0%i.]  ", i);
			else
			Format(szRank, 16, "[%i.]  ", i);

			points = SQL_FetchInt(hndl, 1);
			int pro = SQL_FetchInt(hndl, 2);
			SQL_FetchString(hndl, 3, szSteamID, 32);
			float fperc;
			fperc = (float(pro) / (float(g_pr_MapCount))) * 100.0;

			if (fperc < 10.0)
			Format(szPerc, 16, "  %.1f%c  ", fperc, PERCENT);
			else
			if (fperc == 100.0)
			Format(szPerc, 16, "100.0%c", PERCENT);
			else
			if (fperc > 100.0) //player profile not refreshed after removing maps
			Format(szPerc, 16, "100.0%c", PERCENT);
			else
			Format(szPerc, 16, "%.1f%c  ", fperc, PERCENT);

			if (points < 10)
			Format(szValue, 128, "%s      %ip       %s     » %s", szRank, points, szPerc, szName);
			else
			if (points < 100)
			Format(szValue, 128, "%s     %ip       %s     » %s", szRank, points, szPerc, szName);
			else
			if (points < 1000)
			Format(szValue, 128, "%s   %ip       %s     » %s", szRank, points, szPerc, szName);
			else
			if (points < 10000)
			Format(szValue, 128, "%s %ip       %s     » %s", szRank, points, szPerc, szName);
			else
			if (points < 100000)
			Format(szValue, 128, "%s %ip     %s     » %s", szRank, points, szPerc, szName);
			else
			Format(szValue, 128, "%s %ip   %s     » %s", szRank, points, szPerc, szName);

			menu.AddItem(szSteamID, szValue, ITEMDRAW_DEFAULT);
			i++;
		}
		if (i == 1)
		{
			PrintToChat(data, "%t", "NoPlayerTop", LIMEGREEN, WHITE);
		}
		else
		{
			menu.OptionFlags = MENUFLAG_BUTTON_EXIT;
			menu.Display(data, MENU_TIME_FOREVER);
		}
	}
	else
	{
		PrintToChat(data, "%t", "NoPlayerTop", LIMEGREEN, WHITE);
	}
}

public void SQL_ViewPlayerProfile2Callback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_ViewPlayerProfile2Callback): %s", error);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		SQL_FetchString(hndl, 1, g_szProfileSteamId[data], 32);
		db_viewPlayerRank(data, g_szProfileSteamId[data]);
	}
	else
	if (IsClientInGame(data))
	PrintToChat(data, "%t", "PlayerNotFound", LIMEGREEN, WHITE, g_szProfileName[data]);
}

public int TopPlayersMenuHandler1(Handle menu, MenuAction action, int client, int item)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		GetMenuItem(menu, item, info, sizeof(info));
		g_MenuLevel[client] = 0;
		db_viewPlayerRank(client, info);
	}
	if (action == MenuAction_Cancel)
	{
		ckTopMenu(client);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public int MapMenuHandler1(Handle menu, MenuAction action, int client, int item)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		GetMenuItem(menu, item, info, sizeof(info));
		g_MenuLevel[client] = 1;
		db_viewPlayerRank(client, info);
	}
	if (action == MenuAction_Cancel)
	{
		ckTopMenu(client);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public int FinishedMapsMenuHandler(Handle menu, MenuAction action, int client, int item)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		GetMenuItem(menu, item, info, sizeof(info));
		g_MenuLevel[client] = 1;
		//db_viewPlayerRank(client, info);
	}
	if (action == MenuAction_Cancel)
	{
		ckTopMenu(client);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public int MapTopMenuHandler2(Handle menu, MenuAction action, int client, int item)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		GetMenuItem(menu, item, info, sizeof(info));
		g_MenuLevel[client] = 1;
		db_viewPlayerRank(client, info);
	}
	else if (action == MenuAction_End)
		CloseHandle(menu);
}

public void MapMenuHandler2(Handle menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		GetMenuItem(menu, param2, info, sizeof(info));
		g_MenuLevel[param1] = 8;
		db_viewPlayerRank(param1, info);
	}
	if (action == MenuAction_Cancel)
	{
		ckTopMenu(param1);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}


public int MapMenuHandler3(Handle menu, MenuAction action, int client, int item)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		GetMenuItem(menu, item, info, sizeof(info));
		g_MenuLevel[client] = 9;
		db_viewPlayerRank(client, info);
	}
	if (action == MenuAction_Cancel)
	{
		ckTopMenu(client);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}


public int MenuHandler2(Handle menu, MenuAction action, int client, int param2)
{
	if (action == MenuAction_Cancel || action == MenuAction_Select)
	{
		ProfileMenu(client, -1, 0);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public int RecordPanelHandler(Handle menu, MenuAction action, int client, int item)
{
	if (action == MenuAction_Select)
	{
		ProfileMenu(client, -1, 0);
	}
	else if (action == MenuAction_End)
		CloseHandle(menu);
}

public void RecordPanelHandler2(Handle menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		ckTopMenu(param1);
	}
	else if (action == MenuAction_End)
		CloseHandle(menu);
}

//fluffys sql select total bonus
public void db_selectTotalBonusCount()
{
	char szQuery[512];
	Format(szQuery, 512, "SELECT COUNT(DISTINCT `mapname`, `zonetypeid`) FROM `ck_zones` WHERE `zonetypeid` = 0 AND `zonegroup` > 0");
	SQL_TQuery(g_hDb, sql_selectTotalBonusCountCallback, szQuery, DBPrio_Low);
}

public void sql_selectTotalBonusCountCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (sql_selectTotalBonusCountCallback): %s", error);
		if (!g_bServerDataLoaded)
			db_selectTotalStageCount();
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
		g_pr_BonusCount = SQL_FetchInt(hndl, 0);

	if (!g_bServerDataLoaded)
		db_selectTotalStageCount();

	return;
}

//fluffys sql select total stages
public void db_selectTotalStageCount()
{
	char szQuery[512];
	Format(szQuery, 512, "SELECT COUNT(DISTINCT `mapname`, `zonetypeid`) FROM `ck_zones` WHERE `zonetype` = 3 AND `zonetypeid` = 0 AND `zonegroup` = 0");
	SQL_TQuery(g_hDb, sql_selectTotalStageCountCallback, szQuery, DBPrio_Low);
}

public void sql_selectTotalStageCountCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (sql_selectTotalBonusCountCallback): %s", error);

		if (!g_bServerDataLoaded)
			db_selectCurrentMapImprovement();
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
		g_pr_StageCount = SQL_FetchInt(hndl, 0);

	g_pr_StageCount = g_pr_StageCount * 2;

	if (!g_bServerDataLoaded)
		db_selectCurrentMapImprovement();

	return;
}

public void db_selectWrcpRecord(int client, int style, int stage)
{
	if (!IsValidClient(client) || g_bUsingStageTeleport[client])
	return;

	if (stage > g_TotalStages) // Hack fix for multiple end zones
		stage = g_TotalStages;

	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackCell(pack, style);
	WritePackCell(pack, stage);

	char szQuery[255];
	if(style == 0)
		Format(szQuery, 255, "SELECT runtimepro FROM ck_wrcps WHERE steamid = '%s' AND mapname = '%s' AND stage = %i AND style = 0", g_szSteamID[client], g_szMapName, stage);
	else if(style != 0)
		Format(szQuery, 255, "SELECT runtimepro FROM ck_wrcps WHERE steamid = '%s' AND mapname = '%s' AND stage = %i AND style = %i", g_szSteamID[client], g_szMapName, stage, style);

	SQL_TQuery(g_hDb, sql_selectWrcpRecordCallback, szQuery, pack, DBPrio_Low);
}

public void sql_selectWrcpRecordCallback(Handle owner, Handle hndl, const char[] error, any packx)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (sql_selectWrcpRecordCallback): %s", error);
		CloseHandle(packx);
		return;
	}

	ResetPack(packx);
	int data = ReadPackCell(packx);
	int style = ReadPackCell(packx);
	int stage = ReadPackCell(packx);
	CloseHandle(packx);

	if (!IsValidClient(data))
	return;

	char szName[32];
	GetClientName(data, szName, 32);


	char szQuery[512];

	if (stage > g_TotalStages) // Hack fix for multiple end zones
		stage = g_TotalStages;

	char sz_srDiff[128];
	char szDiff[128];
	float time = g_fFinalWrcpTime[data];
	float f_srDiff;
	float fDiff;

	// PB
	fDiff = (g_fWrcpRecord[data][stage][style] - time);
	FormatTimeFloat(data, fDiff, 3, szDiff, 128);

	if (fDiff > 0)
		Format(szDiff, 128, "%cPB: %c-%s%c", WHITE, GREEN, szDiff, YELLOW);
	else
		Format(szDiff, 128, "%cPB: %c+%s%c", WHITE, RED, szDiff, YELLOW);

	// SR
	if (style == 0)
		f_srDiff = (g_fStageRecord[stage] - time);
	else //styles
		f_srDiff = (g_fStyleStageRecord[style][stage] - time);

	FormatTimeFloat(data, f_srDiff, 3, sz_srDiff, 128);

	if (f_srDiff > 0)
		Format(sz_srDiff, 128, "%c%cWR: %c-%s%c", YELLOW, WHITE, GREEN, sz_srDiff, YELLOW);
	else
		Format(sz_srDiff, 128, "%c%cWR: %c+%s%c", YELLOW, WHITE, RED, sz_srDiff, YELLOW);

	// Found old time from database
	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		float stagetime = SQL_FetchFloat(hndl, 0);

		// If old time was slower than the new time, update record
		if ((g_fFinalWrcpTime[data] <= stagetime || stagetime <= 0.0))
		{
			db_updateWrcpRecord(data, style, stage);
		}
		else
		{//fluffys come back
			char szSpecMessage[512];

			g_bStageSRVRecord[data][stage] = false;
			if(style == 0)
			{
				PrintToChat(data, " %cSurftimer %c| %cStage %i:%c %c%s %c(%s%c - %s%c)", LIMEGREEN, WHITE, WHITE, stage, WHITE, LIMEGREEN, g_szFinalWrcpTime[data], WHITE, szDiff, WHITE, sz_srDiff, WHITE);

				Format(szSpecMessage, sizeof(szSpecMessage), " %cSurftimer %c| %c%s %c| %cStage %i:%c %c%s %c(%s%c - %s%c)", LIMEGREEN, WHITE, YELLOW, szName, WHITE, PINK, stage, WHITE, LIMEGREEN, g_szFinalWrcpTime[data], WHITE, szDiff, WHITE, sz_srDiff, WHITE);
			}
			else if(style != 0)//styles
			{
				PrintToChat(data, " %cSurftimer %c| Completed %cStage %i %c%s %cin %c%s%s %c(Rank: %c#%i%c/%i)", LIMEGREEN, WHITE, WHITE,  stage, LIGHTRED, g_szStyleFinishPrint[style], WHITE, LIMEGREEN, g_szFinalWrcpTime[data], sz_srDiff, WHITE, LIMEGREEN, g_StyleStageRank[style][data][stage], WHITE, g_TotalStageStyleRecords[style][stage]);
				Format(szSpecMessage, sizeof(szSpecMessage), " %cSurftimer %c| Completed %cStage %i %c%s %cin %c%s%s %c(Rank: %c#%i%c/%i)", LIMEGREEN, WHITE, WHITE, stage, LIGHTRED, g_szStyleFinishPrint[style], WHITE, LIMEGREEN, g_szFinalWrcpTime[data], sz_srDiff, WHITE, LIMEGREEN, g_StyleStageRank[style][data][stage], WHITE, g_TotalStageStyleRecords[style][stage]);
			}
			CheckpointToSpec(data, szSpecMessage);

			if(g_bRepeat[data])
			{
				if(g_CurrentStage[data] <= 1)
					Command_Restart(data, 1);
				else
					teleportClient(data, 0, g_CurrentStage[data], false);
			}
		}
	}
	else
	{  // No record found from database - Let's insert

		// Escape name for SQL injection protection
		char szName2[MAX_NAME_LENGTH * 2 + 1], szUName[MAX_NAME_LENGTH];
		GetClientName(data, szUName, MAX_NAME_LENGTH);
		SQL_EscapeString(g_hDb, szUName, szName2, MAX_NAME_LENGTH);

		// Move required information in datapack
		Handle pack = CreateDataPack();
		WritePackFloat(pack, g_fFinalWrcpTime[data]);
		WritePackCell(pack, data);
		WritePackCell(pack, style);

		if(style == 0)
			Format(szQuery, 512, "INSERT INTO ck_wrcps (steamid, name, mapname, runtimepro, stage) VALUES ('%s', '%s', '%s', '%f', %i);", g_szSteamID[data], szName, g_szMapName, g_fFinalWrcpTime[data], stage);
		else if(style != 0)
			Format(szQuery, 512, "INSERT INTO ck_wrcps (steamid, name, mapname, runtimepro, stage, style) VALUES ('%s', '%s', '%s', '%f', %i, %i);", g_szSteamID[data], szName, g_szMapName, g_fFinalWrcpTime[data], stage, style);

		SQL_TQuery(g_hDb, SQL_UpdateWrcpRecordCallback, szQuery, pack, DBPrio_Low);

		g_bStageSRVRecord[data][stage] = false;
	}
}

//
// If latest record was faster than old - Update time
//
public void db_updateWrcpRecord(int client, int style, int stage)
{
	if (IsValidClient(client) && !IsFakeClient(client))
		return;
		
	char szUName[MAX_NAME_LENGTH];
	GetClientName(client, szUName, MAX_NAME_LENGTH);

	// Also updating name in database, escape string
	char szName[MAX_NAME_LENGTH * 2 + 1];
	SQL_EscapeString(g_hDb, szUName, szName, MAX_NAME_LENGTH * 2 + 1);
	//int stage = g_CurrentStage[client];

	// Packing required information for later
	Handle pack = CreateDataPack();
	WritePackFloat(pack, g_fFinalWrcpTime[client]);
	WritePackCell(pack, style);
	WritePackCell(pack, stage);
	WritePackCell(pack, client);

	char szQuery[1024];
	//"UPDATE ck_playertimes SET name = '%s', runtimepro = '%f' WHERE steamid = '%s' AND mapname = '%s';";
	if(style == 0)
		Format(szQuery, 1024, "UPDATE ck_wrcps SET name = '%s', runtimepro = '%f' WHERE steamid = '%s' AND mapname = '%s' AND stage = %i AND style = 0", szName, g_fFinalWrcpTime[client], g_szSteamID[client], g_szMapName, stage);
	if(style > 0)
		Format(szQuery, 1024, "UPDATE ck_wrcps SET name = '%s', runtimepro = '%f' WHERE steamid = '%s' AND mapname = '%s' AND stage = %i AND style = %i", szName, g_fFinalWrcpTime[client], g_szSteamID[client], g_szMapName, stage, style);
	SQL_TQuery(g_hDb, SQL_UpdateWrcpRecordCallback, szQuery, pack, DBPrio_Low);
}


public void SQL_UpdateWrcpRecordCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_UpdateWrcpRecordCallback): %s", error);
		CloseHandle(data);
		return;
	}

	ResetPack(data);
	float stagetime = ReadPackFloat(data);
	int style = ReadPackCell(data);
	int stage = ReadPackCell(data);

	if (g_TotalStageRecords[stage] > 0) //fluffys FIXME
		db_viewTotalStageRecords();
	else if(g_TotalStageStyleRecords[style][stage] > 0)
		db_viewTotalStageRecords();

	// Find out how many times are are faster than the players time
	char szQuery[512];
	if(style == 0)
		Format(szQuery, 512, "SELECT count(runtimepro) FROM ck_wrcps WHERE `mapname` = '%s' AND stage = %i AND style = 0 AND runtimepro < %f AND runtimepro > -1.0;", g_szMapName, stage, stagetime);
	else if(style != 0)
		Format(szQuery, 512, "SELECT count(runtimepro) FROM ck_wrcps WHERE mapname = '%s' AND runtimepro < %f AND stage = %i AND style = %i AND runtimepro > -1.0;", g_szMapName, stagetime, stage, style);

	SQL_TQuery(g_hDb, SQL_UpdateWrcpRecordCallback2, szQuery, data, DBPrio_Low);
}

public void SQL_UpdateWrcpRecordCallback2(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_UpdateRecordProCallback2): %s", error);
		CloseHandle(data);
		return;
	}

	ResetPack(data);
	float time = ReadPackFloat(data);
	int style = ReadPackCell(data);
	int stage = ReadPackCell(data);
	int client = ReadPackCell(data);
	CloseHandle(data);

	if(stage == 0)
		return;

	// Get players rank, 9999999 = error
	int stagerank = 9999999;
	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		stagerank = SQL_FetchInt(hndl, 0)+1;
	}

	if (stage > g_TotalStages) // Hack Fix for multiple end zone issue
		stage = g_TotalStages;

	if(style == 0)
		g_StageRank[client][stage] = stagerank;
	else if(style != 0)
		g_StyleStageRank[style][client][stage] = stagerank;

	db_viewTotalStageRecords();

	// Get client name
	char szName[MAX_NAME_LENGTH];
	GetClientName(client, szName, MAX_NAME_LENGTH);

	char sz_srDiff[128];

	// PB
	char szDiff[128];
	float fDiff;

	fDiff = (g_fWrcpRecord[client][stage][style] - time);
	FormatTimeFloat(client, fDiff, 3, szDiff, 128);

	if (g_fWrcpRecord[client][stage][style] != -1.0) // Existing stage time
	{
		if (fDiff > 0)
			Format(szDiff, 128, "%cPB: %c-%s%c", WHITE, GREEN, szDiff, YELLOW);
		else
			Format(szDiff, 128, "%cPB: %c+%s%c", WHITE, RED, szDiff, YELLOW);
	}
	else
	{
		Format(szDiff, 128, "%cPB: %c%s%c", WHITE, LIMEGREEN, g_szFinalWrcpTime[client], YELLOW);
	}

	// SR
	float f_srDiff;
	if(style == 0)
		f_srDiff = (g_fStageRecord[stage] - time);
	else if(style != 0)
		f_srDiff = (g_fStyleStageRecord[style][stage] - time);

	FormatTimeFloat(client, f_srDiff, 3, sz_srDiff, 128);

	if (f_srDiff > 0)
		Format(sz_srDiff, 128, "%c%cWR: %c-%s%c", YELLOW, WHITE, GREEN, sz_srDiff, YELLOW);
	else
		Format(sz_srDiff, 128, "%c%cWR: %c+%s%c", YELLOW, WHITE, RED, sz_srDiff, YELLOW);

	// Check for SR
	if(style == 0)
	{
		if (g_TotalStageRecords[stage] > 0)
		{  // If the server already has a record

			if (g_fFinalWrcpTime[client] < g_fStageRecord[stage] && g_fFinalWrcpTime[client] > 0.0)
			{  // New fastest time in map
				db_viewTotalStageRecords();
				g_bStageSRVRecord[client][stage] = true;
				g_fStageRecord[stage] = g_fFinalTime[client];
				Format(g_szStageRecordPlayer[stage], MAX_NAME_LENGTH, "%s", szName);
				FormatTimeFloat(1, g_fStageRecord[stage], 3, g_szRecordStageTime[stage], 64);

				PrintToChatAll(" %cSurftimer %c| %c%s %chas beaten the %cSTAGE %i RECORD %c%s %s %c(Rank: %c#1%c/%i)", LIMEGREEN, WHITE, LIMEGREEN, szName, WHITE, PINK, stage, LIMEGREEN, g_szFinalWrcpTime[client], sz_srDiff, WHITE, LIMEGREEN, WHITE, g_TotalStageRecords[stage]);
				g_bSavingWrcpReplay[client] = true;
				//Stage_SaveRecording(client, stage, g_szFinalWrcpTime[client]);
				//PlayWRCPRecord(1);
			}
			else
			{
				db_viewTotalStageRecords();

				char szSpecMessage[512];

				PrintToChat(client, " %cSurftimer %c| Stage %i%c: %c%s %c(%s%c | %s%c) (Rank: %c%i%c/%c%i%c)", LIMEGREEN, WHITE, stage, WHITE, LIMEGREEN, g_szFinalWrcpTime[client], WHITE, szDiff, WHITE, sz_srDiff, WHITE, LIMEGREEN, g_StageRank[client][stage], WHITE, LIMEGREEN, g_TotalStageRecords[stage], WHITE);

				Format(szSpecMessage, sizeof(szSpecMessage), " %cSurftimer %c| %c%s %c| Stage %i%c: %c%s %c(%s%c | %s%c) (Rank: %c%i%c/%c%i%c)", LIMEGREEN, WHITE, YELLOW, szName, WHITE, stage, WHITE, LIMEGREEN, g_szFinalWrcpTime[client], WHITE, szDiff, WHITE, sz_srDiff, WHITE, LIMEGREEN, g_StageRank[client][stage], WHITE, LIMEGREEN, g_TotalStageRecords[stage], WHITE);
				CheckpointToSpec(client, szSpecMessage);
			}
		}
		else
		{  // Has to be the new record, since it is the first completion
			g_bStageSRVRecord[client][stage] = true;
			g_fStageRecord[stage] = g_fFinalTime[client];
			Format(g_szStageRecordPlayer[stage], MAX_NAME_LENGTH, "%s", szName);
			FormatTimeFloat(1, g_fStageRecord[stage], 3, g_szRecordStageTime[stage], 64);

			PrintToChatAll(" %cSurftimer %c| %c%s %chas set a new %cSTAGE %i RECORD %c%s %c(Rank: %c#1%c/1)", LIMEGREEN, WHITE, LIMEGREEN, szName, WHITE, PINK, stage, LIMEGREEN, g_szFinalWrcpTime[client], WHITE, LIMEGREEN, WHITE);
			g_bSavingWrcpReplay[client] = true;
			//Stage_SaveRecording(client, stage, g_szFinalWrcpTime[client]);
			//PlayWRCPRecord(1);
		}
	}
	else if(style != 0) //styles
	{
		if (g_TotalStageStyleRecords[style][stage] > 0)
		{  // If the server already has a record

			if (g_fFinalWrcpTime[client] < g_fStyleStageRecord[style][stage] && g_fFinalWrcpTime[client] > 0.0)
			{  // New fastest time in map
				db_viewTotalStageRecords();
				g_bStageSRVRecord[client][stage] = true;
				g_fStyleStageRecord[style][stage] = g_fFinalTime[client];
				Format(g_szStyleStageRecordPlayer[style][stage], MAX_NAME_LENGTH, "%s", szName);
				FormatTimeFloat(1, g_fStyleStageRecord[style][stage], 3, g_szStyleRecordStageTime[style][stage], 64);

				PrintToChatAll(" %cSurftimer %c| %c%s %chas beaten the %c%s %cSTAGE %i RECORD %c%s %s %c(Rank: %c#%i%c/%i)", LIMEGREEN, WHITE, LIMEGREEN, szName, WHITE, LIGHTRED, g_szStyleRecordPrint[style], PINK, stage, LIMEGREEN, g_szFinalWrcpTime[client], sz_srDiff, WHITE, LIMEGREEN, g_StyleStageRank[style][client][stage], WHITE, g_TotalStageStyleRecords[style][stage]);
				//PlayWRCPRecord(1);
			}
			else
			{
				db_viewTotalStageRecords();

				char szSpecMessage[512];

				PrintToChat(client, " %cSurftimer %c| Completed %cStage %i %c%s %cin %c%s%s %c(Rank: %c#%i%c/%i)", LIMEGREEN, WHITE, WHITE, stage, LIGHTRED, g_szStyleFinishPrint[style], WHITE, LIMEGREEN, g_szFinalWrcpTime[client], sz_srDiff, WHITE, LIMEGREEN, g_StyleStageRank[style][client][stage], WHITE, g_TotalStageStyleRecords[style][stage]);
				Format(szSpecMessage, sizeof(szSpecMessage), " %cSurftimer %c| Completed %cStage %i %c%s %cin %c%s%s %c(Rank: %c#%i%c/%i)", LIMEGREEN, WHITE, WHITE, stage, LIGHTRED, g_szStyleFinishPrint[style], WHITE, LIMEGREEN, g_szFinalWrcpTime[client], sz_srDiff, WHITE, LIMEGREEN, g_StyleStageRank[style][client][stage], WHITE,  g_TotalStageStyleRecords[style][stage]);
				CheckpointToSpec(client, szSpecMessage);
			}
		}
		else
		{  // Has to be the new record, since it is the first completion
			g_bStageSRVRecord[client][stage] = true;
			g_fStyleStageRecord[style][stage] = g_fFinalTime[client];
			Format(g_szStyleStageRecordPlayer[style][stage], MAX_NAME_LENGTH, "%s", szName);
			FormatTimeFloat(1, g_fStyleStageRecord[style][stage], 3, g_szStyleRecordStageTime[style][stage], 64);

			PrintToChatAll(" %cSurftimer %c| %c%s %chas set a new %c%s %cSTAGE %i RECORD %c%s %c(Rank: %c#1%c/1)", LIMEGREEN, WHITE, LIMEGREEN, szName, WHITE, LIGHTRED, g_szStyleRecordPrint[style], PINK, stage, LIMEGREEN, g_szFinalWrcpTime[client], WHITE, LIMEGREEN, WHITE);
			//PlayWRCPRecord(1);
		}
	}

	g_fWrcpRecord[client][stage][style] = time;

	db_viewStageRecords();

	if(g_bRepeat[client])
	{
		if(g_CurrentStage[client] <= 1)
			Command_Restart(client, 1);
		else
			teleportClient(client, 0, g_CurrentStage[client], false);
	}

}

//
// Get players stage rank in current map
//
public void db_viewPersonalStageRecords(int client, char szSteamId[32])
{
	if (!g_bSettingsLoaded[client] && !g_bhasStages)
	{
		LogToFileEx(g_szLogFile, "[Surftimer] %s: Skipping db_viewPersonalStageRecords (linear map)", g_szSteamID[client]);
		LoadClientSetting(client, 3);
		return;
	}

	char szQuery[1024];
	Format(szQuery, 1024, "SELECT runtimepro, stage, style FROM ck_wrcps WHERE steamid = '%s' AND mapname = '%s' AND runtimepro > '0.0';", szSteamId, g_szMapName);
	SQL_TQuery(g_hDb, SQL_selectPersonalStageRecordsCallback, szQuery, client, DBPrio_Low);
}

public void SQL_selectPersonalStageRecordsCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_selectPersonalStageRecordsCallback): %s", error);
		if (!g_bSettingsLoaded[client])
			LoadClientSetting(client, g_iSettingToLoad[client]);
		return;
	}

	int style;
	int stage;
	float time;

	for (int i = 0; i < CPLIMIT; i++)
	{
		for (int s = 0; s < MAX_STYLES; s++)
		{
			g_fWrcpRecord[client][i][s] = -1.0;
		}
	}

	if (SQL_HasResultSet(hndl))
	{
		while (SQL_FetchRow(hndl))
		{
			stage = SQL_FetchInt(hndl, 1);
			style = SQL_FetchInt(hndl, 2);
			time = SQL_FetchFloat(hndl, 0);

			g_fWrcpRecord[client][stage][style] = time;

			if (style == 0)
			{
				db_viewStageRanks(client, stage);
			}
			else
			{
				db_viewStyleStageRanks(client, stage, style);
			}
		}
	}

	if (!g_bSettingsLoaded[client])
	{
		g_fTick[client][1] = GetGameTime();
		float tick = g_fTick[client][1] - g_fTick[client][0];
		LogToFileEx(g_szLogFile, "[Surftimer] %s: Finished db_viewPersonalStageRecords in %fs", g_szSteamID[client], tick);
		g_fTick[client][0] = GetGameTime();

		LoadClientSetting(client, g_iSettingToLoad[client]);
	}
}

public void db_viewStageRanks(int client, int stage)
{
	if (!IsValidClient(client))
		return;

	char szQuery[512];

	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackCell(pack, stage);

	//"SELECT name,mapname FROM ck_playertimes WHERE runtimepro <= (SELECT runtimepro FROM ck_playertimes WHERE steamid = '%s' AND mapname = '%s' AND runtimepro > -1.0) AND mapname = '%s' AND runtimepro > -1.0 ORDER BY runtimepro;";
	//SELECT name FROM ck_bonus WHERE runtime <= (SELECT runtime FROM ck_bonus WHERE steamid = '%s' AND mapname= '%s' AND runtime > 0.0 AND zonegroup = %i) AND mapname = '%s' AND zonegroup = %i;
	Format(szQuery, 512, "SELECT name, mapname, stage, runtimepro FROM ck_wrcps WHERE runtimepro <= (SELECT runtimepro FROM ck_wrcps WHERE steamid = '%s' AND mapname = '%s' AND runtimepro > -1.0 AND stage = %i AND style = 0) AND mapname = '%s' AND stage = %i AND style = 0 AND runtimepro > -1.0 ORDER BY runtimepro;", g_szSteamID[client], g_szMapName, stage, g_szMapName, stage);
	SQL_TQuery(g_hDb, sql_viewStageRanksCallback, szQuery, pack, DBPrio_Low);
}

public void sql_viewStageRanksCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (sql_viewStageRanksCallback): %s ", error);
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	int stage = ReadPackCell(pack);
	CloseHandle(pack);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		g_StageRank[client][stage] = SQL_GetRowCount(hndl);
	}
}

//
// Get Total Stages
//
public void db_GetTotalStages()
{
	// Check if map has stages, if not don't bother loading this
	if(!g_bhasStages)
	{
		db_selectTotalBonusCount();
		return;
	}

	char szQuery[512];

	Format(szQuery, 512, "SELECT COUNT(`zonetype`) AS stages FROM `ck_zones` WHERE `zonetype` = '3' AND `mapname` = '%s'", g_szMapName);
	SQL_TQuery(g_hDb, db_GetTotalStagesCallback, szQuery, DBPrio_Low);
}

public void db_GetTotalStagesCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (db_GetTotalStagesCallback): %s ", error);
		db_viewStageRecords();
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		g_TotalStages = SQL_FetchInt(hndl, 0) + 1;

		for(int i = 1;i <= g_TotalStages;i++)
		{
			g_fStageRecord[i] = 0.0;
			//fluffys comeback yo
		}
	}

	if (!g_bServerDataLoaded)
		db_viewStageRecords();
}

public void db_viewWrcpMap(int client, char mapname[128])
{
	char szQuery[1024];
	Format(szQuery, 512, "SELECT `mapname`, COUNT(`zonetype`) AS stages FROM `ck_zones` WHERE `zonetype` = '3' AND `mapname` = (SELECT DISTINCT `mapname` FROM `ck_zones` WHERE `zonetype` = '3' AND `mapname` LIKE '%c%s%c' LIMIT 0, 1)", PERCENT, g_szWrcpMapSelect[client], PERCENT);
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, mapname);
	SQL_TQuery(g_hDb, sql_viewWrcpMapCallback, szQuery, pack, DBPrio_Low);
}

public void sql_viewWrcpMapCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (sql_viewWrcpMapCallback): %s ", error);
	}

	int totalstages;
	char mapnameresult[128];
	char stage[MAXPLAYERS + 1];
	char szStageString[MAXPLAYERS + 1];
	ResetPack(pack);
	int client = ReadPackCell(pack);
	char mapname[128];
	ReadPackString(pack, mapname, 128);
	CloseHandle(pack);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		totalstages = SQL_FetchInt(hndl, 1) + 1;
		SQL_FetchString(hndl, 0, mapnameresult, 128);
		if(totalstages == 0 || totalstages == 1)
		{
			PrintToChat(client, " %cSurftimer %c| Map %c%s %cnot found or is linear.", LIMEGREEN, WHITE, BLUE, mapname, WHITE);
			return;
		}

		if (pack != INVALID_HANDLE)
		{
			g_szWrcpMapSelect[client] = mapnameresult;
			Menu menu = CreateMenu(StageSelectMenuHandler);
			SetMenuTitle(menu, "%s: select a stage\n------------------------------\n", mapnameresult);
			int stageCount = totalstages;
			for (int i = 1; i <= stageCount; i++)
			{
				stage[0] = i;
				Format(szStageString, sizeof(szStageString), "Stage %i", i);
				AddMenuItem(menu, stage[0], szStageString);
			}
			g_bSelectWrcp[client] = true;
			SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
			DisplayMenu(menu, client, MENU_TIME_FOREVER);
			return;

			/*// Find out how many times are are faster than the players time
			char szQuery[512];
			Format(szQuery, 512, "", g_szMapName, g_CurrentStage[data], stagetime);
			SQL_TQuery(g_hDb, SQL_UpdateRecordProCallback2, szQuery, client, DBPrio_Low);*/
		}
	}
}

public void db_viewWrcpMapRecord(int client)
{
	char szQuery[1024];
	Format(szQuery, 512, "SELECT name, MIN(runtimepro) FROM ck_wrcps WHERE mapname = '%s' AND runtimepro > -1.0 AND stage = %s AND style = 0;", g_szMapName, g_szWrcpMapSelect[client]);

	SQL_TQuery(g_hDb, sql_viewWrcpMapRecordCallback, szQuery, client, DBPrio_Low);
}

public void sql_viewWrcpMapRecordCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (sql_viewWrcpMapRecordCallback): %s ", error);
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		if (SQL_IsFieldNull(hndl, 1))
		{
			PrintToChat(client, " %cSurftimer %c| %cNo record found.", LIMEGREEN, WHITE, DARKRED);
			return;
		}

		char szName[MAX_NAME_LENGTH];
		float runtimepro;
		char szRuntimepro[64];

		SQL_FetchString(hndl, 0, szName, 128);
		runtimepro = SQL_FetchFloat(hndl, 1);
		FormatTimeFloat(0, runtimepro, 3, szRuntimepro, 64);

		PrintToChat(client, " %cSurftimer %c| %c%s %cholds the record with time: %c%s %cfor %cStage %s %con %c%s", LIMEGREEN, WHITE, LIMEGREEN, szName, WHITE, LIMEGREEN, szRuntimepro, WHITE, PINK, g_szWrcpMapSelect[client], WHITE, YELLOW, g_szMapName);
		return;
	}
	else
	{
		PrintToChat(client, " %cSurftimer %c| %cNo record found.", LIMEGREEN, WHITE, DARKRED);
	}
}

public void db_selectStageTopSurfers(int client, char info[32], char mapname[128])
{
	char szQuery[1024];
	Format(szQuery, 1024, "SELECT db2.steamid, db1.name, db2.runtimepro as overall, db1.steamid, db2.mapname FROM ck_wrcps as db2 INNER JOIN ck_playerrank as db1 on db2.steamid = db1.steamid WHERE db2.mapname = '%s' AND db2.runtimepro > -1.0 AND db2.stage = %i AND db2.style = 0 ORDER BY overall ASC LIMIT 50;", mapname, info);
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	//WritePackCell(pack, stage);
	WritePackString(pack, info);
	WritePackString(pack, mapname);
	SQL_TQuery(g_hDb, sql_selectStageTopSurfersCallback, szQuery, pack, DBPrio_Low);
}

public void sql_selectStageTopSurfersCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (sql_selectStageTopSurfersCallback): %s ", error);
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	char stage[32];
	ReadPackString(pack, stage, 32);
	char mapname[128];
	ReadPackString(pack, mapname, 128);
	CloseHandle(pack);


	char szSteamID[32];
	char szName[64];
	float time;
	char szMap[128];
	char szValue[128];
	char lineBuf[256];
	Handle stringArray = CreateArray(100);
	Handle menu;
	menu = CreateMenu(StageTopMenuHandler);
	SetMenuPagination(menu, 5);
	bool bduplicat = false;
	char title[256];
	if (SQL_HasResultSet(hndl))
	{
		int i = 1;
		while (SQL_FetchRow(hndl))
		{
			bduplicat = false;
			SQL_FetchString(hndl, 0, szSteamID, 32);
			SQL_FetchString(hndl, 1, szName, 64);
			time = SQL_FetchFloat(hndl, 2);
			SQL_FetchString(hndl, 4, szMap, 128);
			if (i == 1 || (i > 1))
			{
				int stringArraySize = GetArraySize(stringArray);
				for (int x = 0; x < stringArraySize; x++)
				{
					GetArrayString(stringArray, x, lineBuf, sizeof(lineBuf));
					if (StrEqual(lineBuf, szName, false))
					bduplicat = true;
				}
				if (bduplicat == false && i < 51)
				{
					char szTime[32];
					FormatTimeFloat(client, time, 3, szTime, sizeof(szTime));
					if (time < 3600.0)
					Format(szTime, 32, "   %s", szTime);
					if (i == 100)
					Format(szValue, 128, "[%i.] %s |    » %s", i, szTime, szName);
					if (i >= 10)
					Format(szValue, 128, "[%i.] %s |    » %s", i, szTime, szName);
					else
					Format(szValue, 128, "[0%i.] %s |    » %s", i, szTime, szName);
					AddMenuItem(menu, szSteamID, szValue, ITEMDRAW_DEFAULT);
					PushArrayString(stringArray, szName);
					i++;
				}
			}
		}
		if (i == 1)
		{
			PrintToChat(client, " %cSurftimer %c| No stage records for %cStage %i %con %c%s", LIMEGREEN, WHITE, PINK, stage, WHITE, YELLOW, mapname);
		}
	}
	else
	PrintToChat(client, " %cSurftimer %c| No stage records for %cStage %i %con %c%s", LIMEGREEN, WHITE, PINK, stage, WHITE, YELLOW, mapname);

	Format(title, 256, "[Top 50 | Stage %i | %s] \n    Rank    Time               Player", stage, szMap);
	SetMenuTitle(menu, title);
	SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	CloseHandle(stringArray);
}

public int StageTopMenuHandler(Menu menu, MenuAction action, int client, int item)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		GetMenuItem(menu, item, info, sizeof(info));
		g_MenuLevel[client] = 3;
		db_viewPlayerRank(client, info);
	}
	else if (action == MenuAction_Cancel)
	{
		db_viewWrcpMap(client, g_szWrcpMapSelect[client]);
	}
	else if (action == MenuAction_End)
		CloseHandle(menu);
}

public void db_viewStageRecords()
{
	char szQuery[512];
	Format(szQuery, 512, "SELECT name, MIN(runtimepro), stage, style FROM ck_wrcps WHERE mapname = '%s' GROUP BY stage, style;", g_szMapName);
	SQL_TQuery(g_hDb, sql_viewStageRecordsCallback, szQuery, 0, DBPrio_Low);
}

public void sql_viewStageRecordsCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (sql_viewStageRecordsCallback): %s", error);
		if (!g_bServerDataLoaded)
		{
			db_selectTotalBonusCount();
			return;
		}
	}

	if (SQL_HasResultSet(hndl))
	{
		int stage;
		int style;
		char szName[MAX_NAME_LENGTH];

		while (SQL_FetchRow(hndl))
		{
			SQL_FetchString(hndl, 0, szName, sizeof(szName));
			stage = SQL_FetchInt(hndl, 2);
			style = SQL_FetchInt(hndl, 3);

			if (style == 0)
			{
				g_fStageRecord[stage] = SQL_FetchFloat(hndl, 1);
				if (g_fStageRecord[stage] > -1.0 && !SQL_IsFieldNull(hndl, 1))
				{
					g_fStageRecord[stage] = SQL_FetchFloat(hndl, 1);
					Format(g_szStageRecordPlayer[stage], sizeof(g_szStageRecordPlayer), szName);
					FormatTimeFloat(0, g_fStageRecord[stage], 3, g_szRecordStageTime[stage], 64);
				}
				else
				{
					Format(g_szStageRecordPlayer[stage], sizeof(g_szStageRecordPlayer), "N/A");
					Format(g_szRecordStageTime[stage], 64, "N/A");
					g_fStageRecord[stage] = 9999999.0;
				}
			}
			else
			{
				g_fStyleStageRecord[style][stage] = SQL_FetchFloat(hndl, 1);
				if (g_fStyleStageRecord[style][stage] > -1.0 && !SQL_IsFieldNull(hndl, 1))
				{
					g_fStyleStageRecord[style][stage] = SQL_FetchFloat(hndl, 1);
					FormatTimeFloat(0, g_fStyleStageRecord[style][stage], 3, g_szStyleRecordStageTime[style][stage], 64);
				}
				else
				{
					Format(g_szStyleRecordStageTime[style][stage], 64, "N/A");
					g_fStyleStageRecord[style][stage] = 9999999.0;
				}
			}
		}
	}
	else
	{
		for (int i = 1; i <= g_TotalStages; i++)
		{
			Format(g_szRecordStageTime[i], 64, "N/A");
			g_fStageRecord[i] = 9999999.0;
			for (int s = 1; s < MAX_STYLES; s++)
			{
				Format(g_szStyleRecordStageTime[s][i], 64, "N/A");
				g_fStyleStageRecord[s][i] = 9999999.0;
			}
		}
	}

	if (!g_bServerDataLoaded)
		db_viewTotalStageRecords();
}

public void db_viewTotalStageRecords()
{
	char szQuery[512];
	Format(szQuery, 512, "SELECT stage, style, count(1) FROM ck_wrcps WHERE mapname = '%s' GROUP BY stage, style;", g_szMapName);
	SQL_TQuery(g_hDb, sql_viewTotalStageRecordsCallback, szQuery, 0, DBPrio_Low);
}

public void sql_viewTotalStageRecordsCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (sql_viewTotalStageRecordsCallback): %s", error);
		if (!g_bServerDataLoaded)
			db_selectTotalBonusCount();
		return;
	}

	if (SQL_HasResultSet(hndl))
	{
		int stage;
		int style;

		for (int i = 0; i < CPLIMIT; i++)
		{
			g_TotalStageRecords[i] = 0;
		}

		while (SQL_FetchRow(hndl))
		{
			stage = SQL_FetchInt(hndl, 0);
			style = SQL_FetchInt(hndl, 1);

			if (style == 0)
			{
				g_TotalStageRecords[stage] = SQL_FetchInt(hndl, 2);
				if (g_TotalStageRecords[stage] > -1.0 && !SQL_IsFieldNull(hndl, 2))
				{
					g_TotalStageRecords[stage] = SQL_FetchInt(hndl, 2);
				}
				else
				{
					g_TotalStageRecords[stage] = 0;
				}
			}
			else
			{
				g_TotalStageStyleRecords[style][stage] = SQL_FetchInt(hndl, 2);
				if (g_TotalStageStyleRecords[style][stage] > -1.0 && !SQL_IsFieldNull(hndl, 2))
				{
					g_TotalStageStyleRecords[style][stage] = SQL_FetchInt(hndl, 2);
				}
				else
				{
					g_TotalStageStyleRecords[style][stage] = 0;
				}
			}
		}
	}
	else
	{
		for (int i = 1; i <= g_TotalStages; i++)
		{
			g_TotalStageRecords[i] = 0;
			for (int s = 1; i < MAX_STYLES; s++)
			{
				g_TotalStageStyleRecords[s][i] = 0;
			}
		}
	}

	if (!g_bServerDataLoaded)
		db_selectTotalBonusCount();
}

public void db_selectMapName(char[] mapname)
{
	char szQuery[1028];
	Format(szQuery, 1028, "SELECT `mapname` FROM `ck_maptier` WHERE `mapname` LIKE '%c%s%c' LIMIT 0, 1", PERCENT, mapname, PERCENT);
	SQL_TQuery(g_hDb, sql_SelectMapNameCallBack, szQuery, DBPrio_Low);
}

public void sql_SelectMapNameCallBack(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (sql_SelectMapNameCallBack): %s", error);
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		char mapname[128];
		SQL_FetchString(hndl, 0, mapname, sizeof(mapname));
		ServerCommand("sm_rcon sm_setnextmap %s", mapname);
	}
}
/*** Styles for Maps ***/
public void db_selectStyleRecord(int client, int style)
{
	if (!IsValidClient(client))
	return;

	Handle stylepack = CreateDataPack();
	WritePackCell(stylepack, client);
	WritePackCell(stylepack, style);

	char szQuery[255];
	Format(szQuery, 255, "SELECT runtimepro FROM `ck_playertimes` WHERE `steamid` = '%s' AND `mapname` = '%s' AND `style` = %i AND `runtimepro` > -1.0", g_szSteamID[client], g_szMapName, style);
	SQL_TQuery(g_hDb, sql_selectStyleRecordCallback, szQuery, stylepack, DBPrio_Low);
}

public void sql_selectStyleRecordCallback(Handle owner, Handle hndl, const char[] error, any stylepack)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (sql_selectStyleRecordCallback): %s", error);
		return;
	}

	ResetPack(stylepack);
	int data = ReadPackCell(stylepack);
	int style = ReadPackCell(stylepack);
	CloseHandle(stylepack);

	if (!IsValidClient(data))
	return;


	char szQuery[512];

	// Found old time from database
	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		float time = SQL_FetchFloat(hndl, 0);

		// If old time was slower than the new time, update record
		if ((g_fFinalTime[data] <= time || time <= 0.0))
		{
			db_updateStyleRecord(data, style);
		}
	}
	else
	{  // No record found from database - Let's insert

	// Escape name for SQL injection protection
	char szName[MAX_NAME_LENGTH * 2 + 1], szUName[MAX_NAME_LENGTH];
	GetClientName(data, szUName, MAX_NAME_LENGTH);
	SQL_EscapeString(g_hDb, szUName, szName, MAX_NAME_LENGTH);

	// Move required information in datapack
	Handle pack = CreateDataPack();
	WritePackFloat(pack, g_fFinalTime[data]);
	WritePackCell(pack, data);
	WritePackCell(pack, style);

	g_StyleMapTimesCount[style]++;

	Format(szQuery, 512, "INSERT INTO ck_playertimes (steamid, mapname, name, runtimepro, style) VALUES ('%s', '%s', '%s', '%f', %i)", g_szSteamID[data], g_szMapName, szName, g_fFinalTime[data], style);
	SQL_TQuery(g_hDb, SQL_UpdateStyleRecordCallback, szQuery, pack, DBPrio_Low);
}
}

//
// If latest record was faster than old - Update time
//
public void db_updateStyleRecord(int client, int style)
{
	char szUName[MAX_NAME_LENGTH];

	if (IsValidClient(client))
	GetClientName(client, szUName, MAX_NAME_LENGTH);
	else
	return;

	// Also updating name in database, escape string
	char szName[MAX_NAME_LENGTH * 2 + 1];
	SQL_EscapeString(g_hDb, szUName, szName, MAX_NAME_LENGTH * 2 + 1);

	// Packing required information for later
	Handle pack = CreateDataPack();
	WritePackFloat(pack, g_fFinalTime[client]);
	WritePackCell(pack, client);
	WritePackCell(pack, style);

	char szQuery[1024];
	//"UPDATE ck_playertimes SET name = '%s', runtimepro = '%f' WHERE steamid = '%s' AND mapname = '%s';";
	Format(szQuery, 1024, "UPDATE `ck_playertimes` SET `name` = '%s', runtimepro = '%f' WHERE `steamid` = '%s' AND `mapname` = '%s' AND `style` = %i;", szName, g_fFinalTime[client], g_szSteamID[client], g_szMapName, style);
	SQL_TQuery(g_hDb, SQL_UpdateStyleRecordCallback, szQuery, pack, DBPrio_Low);
}


public void SQL_UpdateStyleRecordCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_UpdateStyleRecordCallback): %s", error);
		return;
	}

	ResetPack(pack);
	float time = ReadPackFloat(pack);
	int client = ReadPackCell(pack);
	int style = ReadPackCell(pack);
	CloseHandle(pack);

	Handle data = CreateDataPack();
	WritePackCell(data, client);
	WritePackCell(data, style);

	// Find out how many times are are faster than the players time
	char szQuery[512];
	Format(szQuery, 512, "SELECT count(runtimepro) FROM `ck_playertimes` WHERE `mapname` = '%s' AND `style` = %i AND `runtimepro` < %f;", g_szMapName, style, time);
	SQL_TQuery(g_hDb, SQL_UpdateStyleRecordCallback2, szQuery, data, DBPrio_Low);
}

public void SQL_UpdateStyleRecordCallback2(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_UpdateStyleRecordProCallback2): %s", error);
		return;
	}
	// Get players rank, 9999999 = error
	int rank = 9999999;
	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		rank = (SQL_FetchInt(hndl, 0)+1);
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	int style = ReadPackCell(pack);
	CloseHandle(pack);


	g_StyleMapRank[style][client] = rank;
	StyleFinishedMsgs(client, style);
}

public void db_GetStyleMapRecord_Pro(int style)
{
	g_fRecordStyleMapTime[style] = 9999999.0;
	char szQuery[512];

	Format(szQuery, 512, "SELECT MIN(runtimepro), name, steamid FROM ck_playertimes WHERE mapname = '%s' AND style = %i AND runtimepro > -1.0", g_szMapName, style);
	SQL_TQuery(g_hDb, sql_selectStyleMapRecordCallback, szQuery, style, DBPrio_Low);
}

public void sql_selectStyleMapRecordCallback(Handle owner, Handle hndl, const char[] error, int style)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (sql_selectStyleMapRecordCallback): %s", error);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		g_fRecordStyleMapTime[style] = SQL_FetchFloat(hndl, 0);
		if (g_fRecordStyleMapTime[style] > -1.0 && !SQL_IsFieldNull(hndl, 0))
		{
			g_fRecordStyleMapTime[style] = SQL_FetchFloat(hndl, 0);
			FormatTimeFloat(0, g_fRecordStyleMapTime[style], 3, g_szRecordStyleMapTime[style], 64);
			SQL_FetchString(hndl, 1, g_szRecordStylePlayer[style], MAX_NAME_LENGTH);
			SQL_FetchString(hndl, 2, g_szRecordStyleMapSteamID[style], MAX_NAME_LENGTH);
		}
		else
		{
			Format(g_szRecordStyleMapTime[style], 64, "N/A");
			g_fRecordStyleMapTime[style] = 9999999.0;
		}
	}
	else
	{
		Format(g_szRecordStyleMapTime[style], 64, "N/A");
		g_fRecordStyleMapTime[style] = 9999999.0;
	}
	return;
}

public void db_viewStyleMapRankCount(int style)
{
	g_StyleMapTimesCount[style] = 0;
	char szQuery[512];
	Format(szQuery, 512, "SELECT name FROM ck_playertimes WHERE mapname = '%s' AND style = %i AND runtimepro  > -1.0;", g_szMapName, style);
	SQL_TQuery(g_hDb, sql_selectStylePlayerCountCallback, szQuery, style, DBPrio_Low);
}

public void sql_selectStylePlayerCountCallback(Handle owner, Handle hndl, const char[] error, int style)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (sql_selectStylePlayerCountCallback): %s", error);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	g_StyleMapTimesCount[style] = SQL_GetRowCount(hndl);
	else
	g_StyleMapTimesCount[style] = 0;

	return;
}

public void db_viewStyleMapRank(int client, int style)
{
	char szQuery[512];
	if (!IsValidClient(client))
	return;

	Handle data = CreateDataPack();
	WritePackCell(data, client);
	WritePackCell(data, style);

	Format(szQuery, 512, "SELECT name,mapname FROM ck_playertimes WHERE runtimepro <= (SELECT runtimepro FROM ck_playertimes WHERE steamid = '%s' AND mapname = '%s' AND style = %i AND runtimepro > -1.0) AND mapname = '%s' AND style = %i AND runtimepro > -1.0 ORDER BY runtimepro;", g_szSteamID[client], g_szMapName, style, g_szMapName, style);
	SQL_TQuery(g_hDb, db_viewStyleMapRankCallback, szQuery, data, DBPrio_Low);
}

public void db_viewStyleMapRankCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (db_viewStyleMapRankCallback): %s ", error);
	}

	ResetPack(data);
	int client = ReadPackCell(data);
	int style = ReadPackCell(data);
	CloseHandle(data);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		g_StyleMapRank[style][client] = SQL_GetRowCount(hndl);
	}

	return;
}

public void db_selectStyleMapTopSurfers(int client, char mapname[128], int style)
{
	char szQuery[1024];
	Format(szQuery, 1024, "SELECT db2.steamid, db1.name, db2.runtimepro as overall, db1.steamid, db2.mapname FROM ck_playertimes as db2 INNER JOIN ck_playerrank as db1 on db2.steamid = db1.steamid WHERE db2.mapname LIKE '%c%s%c' AND db2.style = %i AND db2.runtimepro > -1.0 ORDER BY overall ASC LIMIT 100;", PERCENT, mapname, PERCENT, style);
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, mapname);
	WritePackCell(pack, style);
	SQL_TQuery(g_hDb, sql_selectTopSurfersCallback, szQuery, pack, DBPrio_Low);
}

/*** Styles for Bonuses ***/
public void db_insertBonusStyle(int client, char szSteamId[32], char szUName[32], float FinalTime, int zoneGrp, int style)
{
	char szQuery[1024];
	char szName[MAX_NAME_LENGTH * 2 + 1];
	SQL_EscapeString(g_hDb, szUName, szName, MAX_NAME_LENGTH * 2 + 1);
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackCell(pack, zoneGrp);
	WritePackCell(pack, style);
	Format(szQuery, 1024, "INSERT INTO ck_bonus (steamid, name, mapname, runtime, zonegroup, style) VALUES ('%s', '%s', '%s', '%f', '%i', '%i')", szSteamId, szName, g_szMapName, FinalTime, zoneGrp, style);
	SQL_TQuery(g_hDb, SQL_insertBonusStyleCallback, szQuery, pack, DBPrio_Low);
}

public void SQL_insertBonusStyleCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_insertBonusStyleCallback): %s", error);
		return;
	}

	ResetPack(data);
	int client = ReadPackCell(data);
	int zgroup = ReadPackCell(data);
	int style = ReadPackCell(data);
	CloseHandle(data);

	db_viewMapRankBonusStyle(client, zgroup, 1, style);
	/*// Change to update profile timer, if giving multiplier count or extra points for bonuses
	CalculatePlayerRank(client);*/
}

public void db_viewMapRankBonusStyle(int client, int zgroup, int type, int style)
{
	char szQuery[1024];
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackCell(pack, zgroup);
	WritePackCell(pack, type);
	WritePackCell(pack, style);

	Format(szQuery, 1024, "SELECT name FROM ck_bonus WHERE runtime <= (SELECT runtime FROM ck_bonus WHERE steamid = '%s' AND mapname= '%s' AND style = %i AND runtime > 0.0 AND zonegroup = %i) AND mapname = '%s' AND style = %i AND zonegroup = %i;", g_szSteamID[client], g_szMapName, style, zgroup, g_szMapName, style, zgroup);
	SQL_TQuery(g_hDb, db_viewMapRankBonusStyleCallback, szQuery, pack, DBPrio_Low);
}

public void db_viewMapRankBonusStyleCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (db_viewMapRankBonusStyleCallback): %s", error);
		return;
	}

	ResetPack(data);
	int client = ReadPackCell(data);
	int zgroup = ReadPackCell(data);
	int type = ReadPackCell(data);
	int style = ReadPackCell(data);
	CloseHandle(data);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		g_StyleMapRankBonus[style][zgroup][client] = SQL_GetRowCount(hndl);
	}
	else
	{
		g_StyleMapRankBonus[style][zgroup][client] = 9999999;
	}

	switch (type)
	{
		case 1: {
			g_iStyleBonusCount[style][zgroup]++;
			PrintChatBonusStyle(client, zgroup, style);
		}
		case 2: {
			PrintChatBonusStyle(client, zgroup, style);
		}
	}
}

public void db_updateBonusStyle(int client, char szSteamId[32], char szUName[32], float FinalTime, int zoneGrp, int style)
{
	char szQuery[1024];
	char szName[MAX_NAME_LENGTH * 2 + 1];
	Handle datapack = CreateDataPack();
	WritePackCell(datapack, client);
	WritePackCell(datapack, zoneGrp);
	WritePackCell(datapack, style);
	SQL_EscapeString(g_hDb, szUName, szName, MAX_NAME_LENGTH * 2 + 1);
	Format(szQuery, 1024, "UPDATE ck_bonus SET runtime = '%f', name = '%s' WHERE steamid = '%s' AND mapname = '%s' AND zonegroup = %i AND style = %i", FinalTime, szName, szSteamId, g_szMapName, zoneGrp, style);
	SQL_TQuery(g_hDb, SQL_updateBonusStyleCallback, szQuery, datapack, DBPrio_Low);
}


public void SQL_updateBonusStyleCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_updateBonusCallback): %s", error);
		return;
	}

	ResetPack(data);
	int client = ReadPackCell(data);
	int zgroup = ReadPackCell(data);
	int style = ReadPackCell(data);
	CloseHandle(data);

	db_viewMapRankBonusStyle(client, zgroup, 2, style);
}

public void db_currentBonusStyleRunRank(int client, int zGroup, int style)
{
	char szQuery[512];
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackCell(pack, zGroup);
	WritePackCell(pack, style);
	Format(szQuery, 512, "SELECT count(runtime)+1 FROM ck_bonus WHERE mapname = '%s' AND zonegroup = '%i' AND style = '%i' AND runtime < %f", g_szMapName, zGroup, style, g_fFinalTime[client]);
	SQL_TQuery(g_hDb, db_viewBonusStyleRunRank, szQuery, pack, DBPrio_Low);
}

public void db_viewBonusStyleRunRank(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (db_viewBonusStyleRunRank): %s", error);
		return;
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	int zGroup = ReadPackCell(pack);
	int style = ReadPackCell(pack);
	CloseHandle(pack);
	int rank;
	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		rank = SQL_FetchInt(hndl, 0);
	}

	PrintChatBonusStyle(client, zGroup, style, rank);
}

public void db_viewPersonalBonusStylesRecords(int client, char szSteamId[32], int style)
{
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackCell(pack, style);

	char szQuery[1024];
	//"SELECT runtime, zonegroup FROM ck_bonus WHERE steamid = '%s' AND mapname = '%s' AND runtime > '0.0'";
	Format(szQuery, 1024, "SELECT runtime, zonegroup FROM ck_bonus WHERE steamid = '%s' AND mapname = '%s' AND style = '%i' AND runtime > '0.0'", szSteamId, g_szMapName, style);
	SQL_TQuery(g_hDb, SQL_selectPersonalBonusStylesRecordsCallback, szQuery, pack, DBPrio_Low);
}

public void SQL_selectPersonalBonusStylesRecordsCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	ResetPack(pack);
	int client = ReadPackCell(pack);
	int style = ReadPackCell(pack);
	CloseHandle(pack);

	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_selectPersonalBonusRecordsCallback): %s", error);

		if (style == 6)
		{
			if (!g_bSettingsLoaded[client])
			{
				db_viewPersonalBonusRecords(client, g_szSteamID[client]);
			}
		}

		return;
	}

	int zgroup;

	for (int i = 0; i < MAXZONEGROUPS; i++)
	{
		g_fStylePersonalRecordBonus[style][i][client] = 0.0;
		Format(g_szStylePersonalRecordBonus[style][i][client], 64, "N/A");
	}

	if (SQL_HasResultSet(hndl))
	{
		while (SQL_FetchRow(hndl))
		{
			zgroup = SQL_FetchInt(hndl, 1);
			g_fStylePersonalRecordBonus[style][zgroup][client] = SQL_FetchFloat(hndl, 0);

			if (g_fStylePersonalRecordBonus[style][zgroup][client] > 0.0)
			{
				FormatTimeFloat(client, g_fStylePersonalRecordBonus[style][zgroup][client], 3, g_szStylePersonalRecordBonus[style][zgroup][client], 64);
				//db_viewMapRankBonus(client, zgroup, 0); // get rank
				db_viewMapRankBonusStyle(client, zgroup, 0, style);
			}
			else
			{
				Format(g_szStylePersonalRecordBonus[style][zgroup][client], 64, "N/A");
				g_fStylePersonalRecordBonus[style][zgroup][client] = 0.0;
			}
		}
	}

	if (style == 6)
	{
		if (!g_bSettingsLoaded[client])
		{
			db_viewPersonalBonusRecords(client, g_szSteamID[client]);
		}
	}

	return;
}

/*** Style WRCPS ***/
public void db_viewStyleStageRanks(int client, int stage, int style)
{
	char szQuery[512];
	if (!IsValidClient(client))
	return;

	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackCell(pack, stage);
	WritePackCell(pack, style);

	//"SELECT name,mapname FROM ck_playertimes WHERE runtimepro <= (SELECT runtimepro FROM ck_playertimes WHERE steamid = '%s' AND mapname = '%s' AND runtimepro > -1.0) AND mapname = '%s' AND runtimepro > -1.0 ORDER BY runtimepro;";
	Format(szQuery, 512, "SELECT name, mapname FROM ck_wrcps WHERE runtimepro <= (SELECT runtimepro FROM ck_wrcps WHERE steamid = '%s' AND mapname = '%s' AND stage = %i AND style = %i AND runtimepro > -1.0) AND mapname = '%s' AND stage = %i AND style = %i AND runtimepro > -1.0 ORDER BY runtimepro;", g_szSteamID[client], g_szMapName, stage, style, g_szMapName, stage, style);
	SQL_TQuery(g_hDb, sql_viewStyleStageRanksCallback, szQuery, pack, DBPrio_Low);
}

public void sql_viewStyleStageRanksCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (sql_viewStyleStageRanksCallback): %s ", error);
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	int stage = ReadPackCell(pack);
	int style = ReadPackCell(pack);
	CloseHandle(pack);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		g_StyleStageRank[style][client][stage] = SQL_GetRowCount(hndl);
	}
}

public void db_viewWrcpStyleMapRecord(int client, int style)
{
	char szQuery[1024];
	Format(szQuery, 512, "SELECT name, s%s FROM `ck_wrcps` WHERE `mapname` = '%s' AND `style` = %i AND `s%s` > -1.0 ORDER BY s%s ASC LIMIT 0, 1", g_szWrcpMapSelect[client], g_szMapName, style, g_szWrcpMapSelect[client], g_szWrcpMapSelect[client]);

	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackCell(pack, style);

	SQL_TQuery(g_hDb, sql_viewWrcpStyleMapRecordCallback, szQuery, pack, DBPrio_Low);
}

public void sql_viewWrcpStyleMapRecordCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (sql_viewWrcpMapCallback): %s ", error);
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	int style = ReadPackCell(pack);
	CloseHandle(pack);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		char szName[MAX_NAME_LENGTH];
		float runtimepro;
		char szRuntimepro[64];

		SQL_FetchString(hndl, 0, szName, 128);
		runtimepro = SQL_FetchFloat(hndl, 1);
		FormatTimeFloat(0, runtimepro, 3, szRuntimepro, 64);

		PrintToChat(client, " %cSurftimer %c| %c%s %cholds the %c%s %crecord with time: %c%s %cfor %cStage %s %con %c%s.", LIMEGREEN, WHITE, LIMEGREEN, szName, WHITE, LIGHTRED, g_szStyleFinishPrint[style], WHITE, LIMEGREEN, szRuntimepro, WHITE, PINK, g_szWrcpMapSelect[client], WHITE, LIMEGREEN, g_szMapName);
		return;
	}
	else
	{
		PrintToChat(client, " %cSurftimer %c| %cNo record found.", LIMEGREEN, WHITE, DARKRED);
	}
}

public void db_viewStyleWrcpMap(int client, char mapname[128], int style)
{
	char szQuery[1024];
	Format(szQuery, 512, "SELECT `mapname`, COUNT(`zonetype`) AS stages FROM `ck_zones` WHERE `zonetype` = '3' AND `mapname` = (SELECT DISTINCT `mapname` FROM `ck_zones` WHERE `zonetype` = '3' AND `mapname` LIKE '%c%s%c' LIMIT 0, 1)", PERCENT, g_szWrcpMapSelect[client], PERCENT);
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, mapname);
	WritePackCell(pack, style);
	SQL_TQuery(g_hDb, sql_viewStyleWrcpMapCallback, szQuery, pack, DBPrio_Low);
}

public void sql_viewStyleWrcpMapCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (sql_viewWrcpMapCallback): %s ", error);
	}

	int totalstages;
	char mapnameresult[128];
	char stage[MAXPLAYERS + 1];
	char szStageString[MAXPLAYERS + 1];
	ResetPack(pack);
	int client = ReadPackCell(pack);
	char mapname[128];
	int style = ReadPackCell(pack);
	ReadPackString(pack, mapname, 128);
	CloseHandle(pack);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		totalstages = SQL_FetchInt(hndl, 1) + 1;
		SQL_FetchString(hndl, 0, mapnameresult, 128);
		if(totalstages == 0 || totalstages == 1)
		{
			PrintToChat(client, " %cSurftimer %c| Map %c%s %cnot found or is linear.", LIMEGREEN, WHITE, YELLOW, mapname, WHITE);
			return;
		}

		if (pack != INVALID_HANDLE)
		{
			g_StyleStageSelect[client] = style;
			g_szWrcpMapSelect[client] = mapnameresult;
			Menu menu;
			menu = CreateMenu(StageStyleSelectMenuHandler);

			SetMenuTitle(menu, "%s: Select a stage [%s]\n------------------------------\n", mapnameresult, g_szStyleMenuPrint[style]);
			int stageCount = totalstages;
			for (int i = 1; i <= stageCount; i++)
			{
				stage[0] = i;
				Format(szStageString, sizeof(szStageString), "Stage %i", i);
				AddMenuItem(menu, stage[0], szStageString);
			}
			g_bSelectWrcp[client] = true;
			SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
			DisplayMenu(menu, client, MENU_TIME_FOREVER);
			return;
		}
	}
}

public void db_selectStageStyleTopSurfers(int client, char info[32], char mapname[128], int style)
{
	char szQuery[1024];
	Format(szQuery, 1024, "SELECT db2.steamid, db1.name, db2.runtimepro as overall, db1.steamid, db2.mapname FROM ck_wrcps as db2 INNER JOIN ck_playerrank as db1 on db2.steamid = db1.steamid WHERE db2.mapname = '%s' AND db2.style = %i AND db2.stage = %i AND db2.runtimepro > -1.0 ORDER BY overall ASC LIMIT 50;", mapname, style, info);
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackCell(pack, style);
	//WritePackCell(pack, stage);
	WritePackString(pack, info);
	WritePackString(pack, mapname);
	SQL_TQuery(g_hDb, sql_selectStageStyleTopSurfersCallback, szQuery, pack, DBPrio_Low);
}

public void sql_selectStageStyleTopSurfersCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (sql_selectStageStyleTopSurfersCallback): %s ", error);
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	int style = ReadPackCell(pack);
	char stage[32];
	ReadPackString(pack, stage, 32);
	char mapname[128];
	ReadPackString(pack, mapname, 128);
	CloseHandle(pack);

	char szSteamID[32];
	char szName[64];
	float time;
	char szMap[128];
	char szValue[128];
	char lineBuf[256];
	Handle stringArray = CreateArray(100);
	Handle menu;
	menu = CreateMenu(StageStyleTopMenuHandler);
	SetMenuPagination(menu, 5);
	bool bduplicat = false;
	char title[256];
	if (SQL_HasResultSet(hndl))
	{
		int i = 1;
		while (SQL_FetchRow(hndl))
		{
			bduplicat = false;
			SQL_FetchString(hndl, 0, szSteamID, 32);
			SQL_FetchString(hndl, 1, szName, 64);
			time = SQL_FetchFloat(hndl, 2);
			SQL_FetchString(hndl, 4, szMap, 128);
			if (i == 1 || (i > 1))
			{
				int stringArraySize = GetArraySize(stringArray);
				for (int x = 0; x < stringArraySize; x++)
				{
					GetArrayString(stringArray, x, lineBuf, sizeof(lineBuf));
					if (StrEqual(lineBuf, szName, false))
					bduplicat = true;
				}
				if (bduplicat == false && i < 51)
				{
					char szTime[32];
					FormatTimeFloat(client, time, 3, szTime, sizeof(szTime));
					if (time < 3600.0)
					Format(szTime, 32, "   %s", szTime);
					if (i == 100)
					Format(szValue, 128, "[%i.] %s |    » %s", i, szTime, szName);
					if (i >= 10)
					Format(szValue, 128, "[%i.] %s |    » %s", i, szTime, szName);
					else
					Format(szValue, 128, "[0%i.] %s |    » %s", i, szTime, szName);
					AddMenuItem(menu, szSteamID, szValue, ITEMDRAW_DEFAULT);
					PushArrayString(stringArray, szName);
					i++;
				}
			}
		}
		if (i == 1)
		{
			PrintToChat(client, " %cSurftimer %c| No stage records for %cStage %i %con %c%s", LIMEGREEN, WHITE, PINK, stage, WHITE, YELLOW, mapname);
		}
	}
	else
	PrintToChat(client, " %cSurftimer %c| No stage records for %cStage %i %con %c%s", LIMEGREEN, WHITE, PINK, stage, WHITE, YELLOW, mapname);

	Format(title, 256, "[Top 50 %s | Stage %i | %s] \n    Rank    Time               Player", g_szStyleMenuPrint[style], stage, szMap);
	SetMenuTitle(menu, title);
	SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	CloseHandle(stringArray);
}

public int StageStyleTopMenuHandler(Menu menu, MenuAction action, int client, int item)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		GetMenuItem(menu, item, info, sizeof(info));
		g_MenuLevel[client] = 3;
		db_viewPlayerRank(client, info);
	}
	else if (action == MenuAction_Cancel)
	{
			db_viewStyleWrcpMap(client, g_szWrcpMapSelect[client], 1);
	}
	else if (action == MenuAction_End)
		CloseHandle(menu);
}

//style Profiles
public void db_viewPlayerRankStyle(int client, char szSteamId[32], int style)
{
	Handle data = CreateDataPack();
	WritePackCell(data, client);
	WritePackCell(data, style);

	char szQuery[512];
	Format(szQuery, 512, "SELECT steamid, name, country, lastseen from ck_playerrank where steamid='%s'", szSteamId);
	SQL_TQuery(g_hDb, SQL_ViewRankedPlayerStyleCallback, szQuery, data, DBPrio_Low);
}

public void SQL_ViewRankedPlayerStyleCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_ViewRankedPlayerStyleCallback): %s", error);
		return;
	}

	ResetPack(data);
	int client = ReadPackCell(data);
	int style = ReadPackCell(data);
	CloseHandle(data);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		char szQuery[512];
		char szName[MAX_NAME_LENGTH];
		char szCountry[100];
		char szLastSeen[100];
		char szSteamId[32];
		g_MapRecordCount[client] = 0;

		//get the result
		SQL_FetchString(hndl, 0, szSteamId, 32);
		SQL_FetchString(hndl, 1, szName, MAX_NAME_LENGTH);
		SQL_FetchString(hndl, 2, szCountry, 100);
		SQL_FetchString(hndl, 3, szLastSeen, 100);
		Handle pack_pr = CreateDataPack();
		WritePackString(pack_pr, szName);
		WritePackString(pack_pr, szSteamId);
		WritePackCell(pack_pr, style);
		WritePackCell(pack_pr, client);
		WritePackString(pack_pr, szCountry);
		WritePackString(pack_pr, szLastSeen);
		Format(szQuery, 512, "SELECT COUNT(`steamid`) FROM `ck_playertimes` WHERE `steamid` = '%s' AND `style` = %i", szSteamId, style); //fluffys
		SQL_TQuery(g_hDb, SQL_ViewRankedPlayerMapsStyleCallback, szQuery, pack_pr, DBPrio_Low);
	}
}

public void SQL_ViewRankedPlayerMapsStyleCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_ViewRankedPlayerMapsStyleCallback): %s", error);
		return;
	}

	char szSteamId[32];
	char szName[MAX_NAME_LENGTH];
	ResetPack(data);
	ReadPackString(data, szName, MAX_NAME_LENGTH);
	ReadPackString(data, szSteamId, 32);
	int style = ReadPackCell(data);
	int client = ReadPackCell(data);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		char szQuery[512];

		g_totalStyleMapTimes[client] = SQL_FetchInt(hndl, 0); //fluffys pack full i think
		Format(szQuery, 512, "SELECT COUNT(`steamid`) FROM `ck_bonus` WHERE `steamid` = '%s' AND `style` = %i", szSteamId, style); //fluffys
		SQL_TQuery(g_hDb, SQL_ViewRankedPlayerBonusesStyleCallback, szQuery, data, DBPrio_Low);
	}
	else
	{
		CloseHandle(data);
	}
}

//fluffys add bonus count callback
public void SQL_ViewRankedPlayerBonusesStyleCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_ViewRankedPlayerBonusesStyleCallback): %s", error);
		return;
	}


	char szSteamId[32];
	char szName[MAX_NAME_LENGTH];
	ResetPack(data);
	ReadPackString(data, szName, MAX_NAME_LENGTH);
	ReadPackString(data, szSteamId, 32);
	int style = ReadPackCell(data);
	int client = ReadPackCell(data);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		char szQuery[512];
		//get the result
		g_totalBonusTimes[client] = SQL_FetchInt(hndl, 0); //fluffys pack full i think
		Format(szQuery, 512, "SELECT COUNT(`steamid`) FROM `ck_wrcps` WHERE `steamid` = '%s' AND `style` = %i AND `runtimepro` > -1.0", szSteamId, style);
		SQL_TQuery(g_hDb, SQL_ViewRankedPlayerStagesStyleTotalCallback, szQuery, data, DBPrio_Low);
	}
	else
	{
		CloseHandle(data);
	}
}

//fluffys add bonus count callback
public void SQL_ViewRankedPlayerStagesStyleTotalCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_ViewRankedPlayerStageTotalCallback): %s", error);
		return;
	}

	char szSteamId[32];
	char szName[MAX_NAME_LENGTH];
	ResetPack(data);
	ReadPackString(data, szName, MAX_NAME_LENGTH);
	ReadPackString(data, szSteamId, 32);
	int style = ReadPackCell(data);
	int client = ReadPackCell(data);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		char szQuery[512];
		//get the result
		g_totalStageTimes[client] = SQL_FetchInt(hndl, 0); //fluffys pack full i think
		Format(szQuery, 512, "SELECT y.steamid, COUNT(*) AS rekorde FROM (SELECT s.steamid FROM ck_playertimes s INNER JOIN (SELECT mapname, MIN(runtimepro) AS runtimepro FROM ck_playertimes where runtimepro > -1.0 AND style = %i GROUP BY mapname) x ON s.mapname = x.mapname AND s.runtimepro = x.runtimepro) y where y.steamid = '%s' GROUP BY y.steamid ORDER BY rekorde DESC , y.steamid;", style, szSteamId);
		SQL_TQuery(g_hDb, SQL_ViewRankedPlayerStyleCallback4, szQuery, data, DBPrio_Low);
	}
	else
	{
		CloseHandle(data);
	}
}
//SQL_ViewRankedPlayerStageRecordsCallback
/*Format(szQuery, 512, sql_selectMapRecordCount, szSteamId);
SQL_TQuery(g_hDb, SQL_ViewRankedPlayerCallback4, szQuery, data, DBPrio_Low);*/
public void SQL_ViewRankedPlayerStyleCallback4(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_ViewRankedPlayerCallback4): %s", error);
		return;
	}

	char szQuery[512];
	char szSteamId[32];
	char szName[MAX_NAME_LENGTH];

	ResetPack(data);
	ReadPackString(data, szName, MAX_NAME_LENGTH);
	ReadPackString(data, szSteamId, 32);
	int style = ReadPackCell(data);
	int client = ReadPackCell(data);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
		g_MapRecordCount[client] = SQL_FetchInt(hndl, 1); //pack full?

	Format(szQuery, 512, "SELECT y.steamid, y.name, COUNT(*) AS wrbs FROM (SELECT s.steamid, s.name FROM ck_bonus s INNER JOIN (SELECT mapname, MIN(runtime) AS runtime FROM ck_bonus where runtime > -1.0 AND style = %i GROUP BY mapname) x ON s.mapname = x.mapname AND s.runtime = x.runtime) y WHERE `steamid` = '%s'", style, szSteamId); //fluffys
	SQL_TQuery(g_hDb, SQL_ViewRankedPlayerStyleCallback5, szQuery, data, DBPrio_Low);
}

public void SQL_ViewRankedPlayerStyleCallback5(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_ViewRankedPlayerCallback5): %s", error);
		return;
	}

	char szName[MAX_NAME_LENGTH];
	char szSteamId[32];
	char szCountry[100];
	char szLastSeen[100];

	ResetPack(data);
	ReadPackString(data, szName, MAX_NAME_LENGTH);
	ReadPackString(data, szSteamId, 32);
	int style = ReadPackCell(data);
	int client = ReadPackCell(data);
	int finishedmapspro = g_totalStyleMapTimes[client];
	ReadPackString(data, szCountry, 100);
	ReadPackString(data, szLastSeen, 100);
	if (StrEqual(szLastSeen, ""))
		Format(szLastSeen, 100, "Unknown");
	int prorecords = g_MapRecordCount[client];
	Format(g_szProfileSteamId[client], 32, "%s", szSteamId);
	Format(g_szProfileName[client], MAX_NAME_LENGTH, "%s", szName);
	bool master = false;

	//fluffys map percentage
	float fperc;
	float bfperc;
	char szPerc[32];
	char szBPerc[32];
	char szStagePerc[32];
	fperc = (float(finishedmapspro) / (float(g_pr_MapCount))) * 100.0;
	int finishedbonuses = g_totalBonusTimes[client];
	char percent[2]; //fluffys percent wont print !!
	percent = "%%";

	if (fperc < 10.0)
	Format(szPerc, 32, "%.1f", fperc);
	else
	if (fperc == 100.0)
	Format(szPerc, 32, "100.0");
	else
	if (fperc > 100.0) //player profile not refreshed after removing maps
	Format(szPerc, 32, "100.0");
	else
	Format(szPerc, 32, "%.1f", fperc);

	bfperc = (float(finishedbonuses) / (float(g_pr_BonusCount))) * 100.0;

	if (bfperc < 10.0)
	Format(szBPerc, 32, "%.1f", bfperc);
	else
	if (bfperc == 100.0)
	Format(szBPerc, 32, "100.0");
	else
	if (bfperc > 100.0) //player profile not refreshed after removing maps
	Format(szBPerc, 32, "100.0");
	else
	Format(szBPerc, 32, "%.1f", bfperc);


	CloseHandle(data);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
		g_BonusRecordCount[client] = SQL_FetchInt(hndl, 2); //pack full?

	int bonusrecords = g_BonusRecordCount[client];

	int playerstages = g_totalStageTimes[client];
	int totalstages = g_pr_StageCount;
	float stagefperc;

	stagefperc = (float(playerstages) / (float(totalstages))) * 100.0;

	if (stagefperc < 10.0)
	Format(szStagePerc, 32, "%.1f", stagefperc);
	else
	if (stagefperc == 100.0)
	Format(szStagePerc, 32, "100.0");
	else
	if (stagefperc > 100.0) //player profile not refreshed after removing maps
	Format(szStagePerc, 32, "100.0");
	else
	Format(szStagePerc, 32, "%.1f", stagefperc);


	if (finishedmapspro > g_pr_MapCount)
	finishedmapspro = g_pr_MapCount;

	char szStyle[128];
	if(style == 1) //sideways
		Format(szStyle, 128, "Sideways");
	else if(style == 2) //hsw
		Format(szStyle, 128, "Half-Sideways");
	else if(style == 3) //bw
		Format(szStyle, 128, "Backwards");
	else if(style == 4) //lg
		Format(szStyle, 128, "Low-Gravity");
	else if(style == 5)
		Format(szStyle, 128, "Slow Motion");
	else if(style == 6)
		Format(szStyle, 128, "Fast Forwards");

	if (master == false)
	{ //fluffys edit !p menu
		if (GetConVarBool(g_hPointSystem))
			Format(g_pr_szrank[client], 512, "%s Completed:\nMaps: %i/%i (%s%s)\nStages: %i/%i (%s%s)\nBonuses: %i/%i (%s%s)\n \n%s Records:\nMap WR: %i\nStage WR: (WIP)\nBonus WR: %i\n ", szStyle, finishedmapspro, g_pr_MapCount, szPerc, percent, playerstages, totalstages, szStagePerc, percent, finishedbonuses, g_pr_BonusCount, szBPerc, percent, szStyle, prorecords, bonusrecords);
	}

	char szID[32][2];
	ExplodeString(szSteamId, "_", szID, 2, 32);
	char szTitle[1024];
	if (GetConVarBool(g_hCountry))
	Format(szTitle, 1024, "%s [%s] STEAM_%s\n------------------------------------\nCountry: %s \nLast online: %s\n \n%s\n", szName, szStyle, szID[1], szCountry, szLastSeen, g_pr_szrank[client]);
	else
	Format(szTitle, 1024, "Player: %s\nSteamID: %s\nStyle: %s\nLast seen: %s\n \n%s\n", szName, szID[1], szStyle, szLastSeen, g_pr_szrank[client]);
	g_ProfileStyleSelect[client] = style;
	Menu profileMenu = new Menu(StyleProfileMenuHandler);
	profileMenu.SetTitle(szTitle);
	profileMenu.AddItem("Finished maps", "Finished maps");

	if (IsValidClient(client))
	{
		if (StrEqual(szSteamId, g_szSteamID[client]))
		{
			profileMenu.AddItem("Unfinished maps", "Unfinished maps");
			if (GetConVarBool(g_hPointSystem))
			profileMenu.AddItem("Refresh my profile", "Refresh my profile");
		}
	}
	profileMenu.ExitButton = true;
	profileMenu.Display(client, MENU_TIME_FOREVER);
}

public int StyleProfileMenuHandler(Handle menu, MenuAction action, int client, int item)
{
	if (action == MenuAction_Select)
	{
		int style = g_ProfileStyleSelect[client];
		switch (item)
		{
			case 0:db_viewAllStyleRecords(client, g_szProfileSteamId[client], style);//fluffys
			case 1:db_viewUnfinishedMaps(client, g_szProfileSteamId[client]);
			case 2:
			{
				if (g_bRecalcRankInProgess[client])
				{
					PrintToChat(client, " %cSurftimer %c| %cRecalculation in progress. Please wait!", LIMEGREEN, WHITE, GRAY);
				}
				else
				{

					g_bRecalcRankInProgess[client] = true;
					PrintToChat(client, "%t", "Rc_PlayerRankStart", LIMEGREEN, WHITE, GRAY);
					CalculatePlayerRank(client);
				}
			}
		}
	}
	else if (action == MenuAction_Cancel)
	{
		if (1 <= client <= MaxClients && IsValidClient(client))
		{
			switch (g_MenuLevel[client])
			{
				case 0:db_selectTopPlayers(client);
				case 3:db_viewWrcpMap(client, g_szWrcpMapSelect[client]);
				case 9:db_selectProSurfers(client);
				case 11:db_selectTopProRecordHolders(client);

			}
			if (g_MenuLevel[client] < 0)
			{
				if (g_bSelectProfile[client])
				ProfileMenu(client, 0, 0);
			}
		}
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public void db_viewAllStyleRecords(int client, char szSteamId[32], int style)
{
	char szQuery[1024];
	Format(szQuery, 1024, "SELECT db1.name, db2.steamid, db2.mapname, db2.runtimepro as overall, db1.steamid, db2.style FROM ck_playertimes as db2 INNER JOIN ck_playerrank as db1 on db2.steamid = db1.steamid WHERE db2.steamid = '%s' AND db2.style = %i AND db2.runtimepro > -1.0 ORDER BY mapname ASC;", szSteamId, style);
	if ((StrContains(szSteamId, "STEAM_") != -1))
		SQL_TQuery(g_hDb, SQL_ViewAllStyleRecordsCallback, szQuery, client, DBPrio_Low);
	else
	if (IsClientInGame(client))
		PrintToChat(client, " %cSurftimer %c| Invalid SteamID found.", RED, WHITE);
	//ProfileMenu(client, -1, 0);
}


public void SQL_ViewAllStyleRecordsCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_ViewAllStyleRecordsCallback): %s", error);
		return;
	}

	int bHeader = false;
	char szUncMaps[1024];
	int mapcount = 0;
	char szName[MAX_NAME_LENGTH];
	char szSteamId[32];

	int style;
	char szStyle[128];

	if (SQL_HasResultSet(hndl))
	{
		float time;
		char szMapName[128];
		char szMapName2[128];
		char szQuery[1024];
		Format(szUncMaps, sizeof(szUncMaps), "");
		while (SQL_FetchRow(hndl))
		{
			SQL_FetchString(hndl, 0, szName, MAX_NAME_LENGTH);
			SQL_FetchString(hndl, 1, szSteamId, MAX_NAME_LENGTH);
			SQL_FetchString(hndl, 2, szMapName, 128);

			time = SQL_FetchFloat(hndl, 3);
			style = SQL_FetchInt(hndl, 5);

			if (style == 1)
				Format(szStyle, 128, "Sideways");
			else if (style == 2)
				Format(szStyle, 128, "Half-Sideways");
			else if (style == 3)
				Format(szStyle, 128, "Backwards");
			else if (style == 4)
				Format(szStyle, 128, "Low-Gravity");
			else if (style == 5)
				Format(szStyle, 128, "Slow Motion");
			else if (style == 6)
				Format(szStyle, 128, "Fast Forwards");

			int mapfound = false;

			//map in rotation?
			for (int i = 0; i < GetArraySize(g_MapList); i++)
			{
				//PrintToChat(data, "for loop, getarraysize(g_maplist)");
				GetArrayString(g_MapList, i, szMapName2, sizeof(szMapName2));
				if (StrEqual(szMapName2, szMapName, false))
				{
					if (!bHeader)
					{
						PrintToConsole(data, " ");
						PrintToConsole(data, "-------------");
						PrintToConsole(data, "Finished Maps [%s]", szStyle);
						PrintToConsole(data, "Player: %s", szName);
						PrintToConsole(data, "SteamID: %s", szSteamId);
						PrintToConsole(data, "-------------");
						PrintToConsole(data, " ");
						bHeader = true;
						PrintToChat(data, "%t", "ConsoleOutput", LIMEGREEN, WHITE);
					}
					Handle pack = CreateDataPack();
					WritePackString(pack, szName);
					WritePackString(pack, szSteamId);
					WritePackString(pack, szMapName);
					WritePackFloat(pack, time);
					WritePackCell(pack, data);
					WritePackCell(pack, style);

					Format(szQuery, 1024, "SELECT name,mapname FROM ck_playertimes WHERE runtimepro <= (SELECT runtimepro FROM ck_playertimes WHERE steamid = '%s' AND mapname = '%s' AND style = %i AND runtimepro > -1.0) AND mapname = '%s' AND style = %i AND runtimepro > -1.0 ORDER BY runtimepro;", szSteamId, szMapName, style, szMapName, style);
					SQL_TQuery(g_hDb, SQL_ViewAllStyleRecordsCallback2, szQuery, pack, DBPrio_Low);
					mapfound = true;
					continue;
				}
			}
			if (!mapfound)
			{
				mapcount++;
				if (!mapfound && mapcount == 1)
				{
					Format(szUncMaps, sizeof(szUncMaps), "%s", szMapName);
				}
				else
				{
					if (!mapfound && mapcount > 1)
					{
						Format(szUncMaps, sizeof(szUncMaps), "%s, %s", szUncMaps, szMapName);
					}
				}
			}
		}
	}
	if (!StrEqual(szUncMaps, ""))
	{
		if (!bHeader)
		{
			PrintToChat(data, "%t", "ConsoleOutput", LIMEGREEN, WHITE);
			PrintToConsole(data, " ");
			PrintToConsole(data, "-------------");
			PrintToConsole(data, "Finished Maps");
			PrintToConsole(data, "Player: %s", szName);
			PrintToConsole(data, "SteamID: %s", szSteamId);
			PrintToConsole(data, "-------------");
			PrintToConsole(data, " ");
		}
		PrintToConsole(data, "Times on maps which are not in the mapcycle.txt (Records still count but you don't get points): %s", szUncMaps);
	}
	if (!bHeader && StrEqual(szUncMaps, ""))
	{
		PrintToChat(data, "%t", "PlayerHasNoMapRecords", LIMEGREEN, WHITE, g_szProfileName[data]);
	}
}

public void SQL_ViewAllStyleRecordsCallback2(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error SQL_ViewAllStyleRecordsCallback2): %s", error);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		char szQuery[512];
		char szName[MAX_NAME_LENGTH];
		char szSteamId[32];
		char szMapName[128];

		int rank = SQL_GetRowCount(hndl);
		WritePackCell(data, rank);
		ResetPack(data);
		ReadPackString(data, szName, MAX_NAME_LENGTH);
		ReadPackString(data, szSteamId, 32);
		ReadPackString(data, szMapName, 128);
		//float time = ReadPackFloat(data);
		//int client = ReadPackCell(data);
		int style = ReadPackCell(data);

		Format(szQuery, 512, "SELECT name FROM ck_playertimes WHERE mapname = '%s' AND style = %i AND runtimepro > -1.0;", szMapName, style);
		SQL_TQuery(g_hDb, SQL_ViewAllStyleRecordsCallback3, szQuery, data, DBPrio_Low);
	}
}

public void SQL_ViewAllStyleRecordsCallback3(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_ViewAllStyleRecordsCallback3): %s", error);
		return;
	}

	int i = 1;

	char szTime[32];
	char szMapName[128];
	char szSteamId[32];
	char szName[MAX_NAME_LENGTH];
	//fluffys
	char szValue[128];
	ResetPack(data);
	ReadPackString(data, szName, MAX_NAME_LENGTH);
	ReadPackString(data, szSteamId, 32);
	ReadPackString(data, szMapName, 128);
	float time = ReadPackFloat(data);
	int client = ReadPackCell(data);
	//int style = ReadPackCell(data);
	int rank = ReadPackCell(data);
	CloseHandle(data);

	//if there is a player record
	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		int count = SQL_GetRowCount(hndl);

		FormatTimeFloat(client, time, 3, szTime, sizeof(szTime));

		if (time < 3600.0)
		Format(szTime, 32, "   %s", szTime);

		Format(szValue, 128, "%i/%i %s |    » %s", rank, count, szTime, szMapName);
		i++;

		/*Format(title, 256, "Finished maps for %s \n    Rank    Time               Mapnname", szName);
		SetMenuTitle(menu, title);
		SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
		DisplayMenu(menu, client, MENU_TIME_FOREVER);*/

		if (IsValidClient(client))
			PrintToConsole(client, "%s, Time: %s, Rank: %i/%i", szMapName, szTime, rank, count);
	}
}

public void db_viewPlayerStyleProfile1(int client, char szPlayerName[MAX_NAME_LENGTH], int style)
{
	char szQuery[512];
	char szName[MAX_NAME_LENGTH * 2 + 1];
	SQL_EscapeString(g_hDb, szPlayerName, szName, MAX_NAME_LENGTH * 2 + 1);
	Format(szQuery, 512, sql_selectPlayerRankAll2, szName);
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackCell(pack, style);
	WritePackString(pack, szPlayerName);
	SQL_TQuery(g_hDb, SQL_ViewPlayerStyleProfile1Callback, szQuery, pack, DBPrio_Low);
}

public void SQL_ViewPlayerStyleProfile1Callback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_ViewPlayerStyleProfile1Callback): %s", error);
		return;
	}
	char szPlayerName[MAX_NAME_LENGTH];

	ResetPack(data);
	int client = ReadPackCell(data);
	int style = ReadPackCell(data);
	ReadPackString(data, szPlayerName, MAX_NAME_LENGTH);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		SQL_FetchString(hndl, 1, g_szProfileSteamId[client], 32);
		db_viewPlayerRankStyle(client, g_szProfileSteamId[client], style);
	}
	else
	{
		char szQuery[512];
		char szName[MAX_NAME_LENGTH * 2 + 1];
		SQL_EscapeString(g_hDb, szPlayerName, szName, MAX_NAME_LENGTH * 2 + 1);
		Format(szQuery, 512, sql_selectPlayerRankAll, PERCENT, szName, PERCENT);
		SQL_TQuery(g_hDb, SQL_ViewPlayerStyleProfile2Callback, szQuery, data, DBPrio_Low);
	}
}

public void SQL_ViewPlayerStyleProfile2Callback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (SQL_ViewPlayerStyleProfile2Callback): %s", error);
		return;
	}

	ResetPack(data);
	int client = ReadPackCell(data);
	int style = ReadPackCell(data);
	CloseHandle(data);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		SQL_FetchString(hndl, 1, g_szProfileSteamId[client], 32);
		db_viewPlayerRankStyle(data, g_szProfileSteamId[client], style);
	}
	else
	if (IsClientInGame(client))
	PrintToChat(client, "%t", "PlayerNotFound", LIMEGREEN, WHITE, g_szProfileName[client]);
}

public void db_selectMapRank(int client, char szSteamId[32], char szMapName[128])
{
	char szQuery[1024];
	if (StrEqual(szMapName, "surf_me"))
			Format(szQuery, 1024, "SELECT `steamid`, `name`, `mapname`, `runtimepro` FROM `ck_playertimes` WHERE `steamid` = '%s' AND `mapname` = '%s' AND style = 0 LIMIT 1;", szSteamId, szMapName);
	else
		Format(szQuery, 1024, "SELECT `steamid`, `name`, `mapname`, `runtimepro` FROM `ck_playertimes` WHERE `steamid` = '%s' AND `mapname` LIKE '%c%s%c' AND style = 0 LIMIT 1;", szSteamId, PERCENT, szMapName, PERCENT);
	SQL_TQuery(g_hDb, db_selectMapRankCallback, szQuery, client, DBPrio_Low);
}

public void db_selectMapRankCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (db_selectMapRankCallback): %s", error);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		char szSteamId[32];
		char playername[MAX_NAME_LENGTH];
		char mapname[128];
		float runtimepro;

		SQL_FetchString(hndl, 0, szSteamId, 32);
		SQL_FetchString(hndl, 1, playername, MAX_NAME_LENGTH);
		SQL_FetchString(hndl, 2, mapname, sizeof(mapname));
		runtimepro = SQL_FetchFloat(hndl, 3);

		FormatTimeFloat(client, runtimepro, 3, g_szRuntimepro[client], sizeof(g_szRuntimepro));

		Handle pack = CreateDataPack();
		WritePackCell(pack, client);
		WritePackString(pack, szSteamId);
		WritePackString(pack, playername);
		WritePackString(pack, mapname);

		char szQuery[1024];

		Format(szQuery, 1024, "SELECT count(name) FROM `ck_playertimes` WHERE `mapname` = '%s' AND style = 0;", mapname);
		SQL_TQuery(g_hDb, db_SelectTotalMapCompletesCallback, szQuery, pack, DBPrio_Low);
	}
	else
	{
		PrintToChat(client, " %cSurftimer %c| No result found for player or map", LIMEGREEN, WHITE);
	}
}

public void db_SelectTotalMapCompletesCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (db_SelectTotalMapCompletesCallback): %s ", error);
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	char szSteamId[32];
	char playername[MAX_NAME_LENGTH];
	char mapname[128];
	ReadPackString(pack, szSteamId, 32);
	ReadPackString(pack, playername, sizeof(playername));
	ReadPackString(pack, mapname, sizeof(mapname));

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		g_totalPlayerTimes[client] = SQL_FetchInt(hndl, 0);

		char szQuery[1024];

		Format(szQuery, 1024, "SELECT name,mapname FROM ck_playertimes WHERE runtimepro <= (SELECT runtimepro FROM ck_playertimes WHERE steamid = '%s' AND mapname = '%s' AND runtimepro > -1.0 AND style = 0) AND mapname = '%s' AND style = 0 AND runtimepro > -1.0 ORDER BY runtimepro;", szSteamId, mapname, mapname);
		SQL_TQuery(g_hDb, db_SelectPlayersMapRankCallback, szQuery, pack, DBPrio_Low);
	}
	else
	{
		CloseHandle(pack);
	}
}

public void db_SelectPlayersMapRankCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (db_SelectPlayersMapRankCallback): %s ", error);
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	char szSteamId[32];
	char playername[MAX_NAME_LENGTH];
	char mapname[128];
	ReadPackString(pack, szSteamId, 32);
	ReadPackString(pack, playername, sizeof(playername));
	ReadPackString(pack, mapname, sizeof(mapname));
	CloseHandle(pack);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		int rank;
		rank = SQL_GetRowCount(hndl);

		if(StrEqual(mapname, g_szMapName))
		{
			char szGroup[128];
			if(rank >= 11 && rank <= g_G1Top)
				Format(szGroup, 128, "[%cGroup 1%c]", DARKRED, WHITE);
			else if(rank >= g_G2Bot && rank <= g_G2Top)
				Format(szGroup, 128, "[%cGroup 2%c]", GREEN, WHITE);
			else if(rank >= g_G3Bot && rank <= g_G3Top)
				Format(szGroup, 128, "[%cGroup 3%c]", BLUE, WHITE);
			else if(rank >= g_G4Bot && rank <= g_G4Top)
				Format(szGroup, 128, "[%cGroup 4%c]", YELLOW, WHITE);
			else if(rank >= g_G5Bot && rank <= g_G5Top)
				Format(szGroup, 128, "[%cGroup 5%c]", GRAY, WHITE);
			else
				Format(szGroup, 128, "");

			if(rank >= 11 && rank <= g_G5Top)
				PrintToChatAll(" %cSurftimer %c| %c%s %cis ranked %c#%i%c/%i %s with a time of %c%s %con %c%s", LIMEGREEN, WHITE, YELLOW, playername, WHITE, LIMEGREEN, rank, WHITE, g_totalPlayerTimes[client], szGroup, LIMEGREEN, g_szRuntimepro[client], WHITE, YELLOW, mapname);
			else
				PrintToChatAll(" %cSurftimer %c| %c%s %cis ranked %c#%i%c/%i with a time of %c%s %con %c%s", LIMEGREEN, WHITE, YELLOW, playername, WHITE, LIMEGREEN, rank, WHITE, g_totalPlayerTimes[client], LIMEGREEN, g_szRuntimepro[client], WHITE, YELLOW, mapname);
		}
		else
		{
			PrintToChatAll(" %cSurftimer %c| %c%s %cis ranked %c#%i%c/%i with a time of %c%s %con %c%s", LIMEGREEN, WHITE, YELLOW, playername, WHITE, LIMEGREEN, rank, WHITE, g_totalPlayerTimes[client], LIMEGREEN, g_szRuntimepro[client], WHITE, YELLOW, mapname);
		}
	}
	else
	{
		CloseHandle(pack);
	}
}

//sm_mrank @x command
public void db_selectMapRankUnknown(int client, char szMapName[128], int rank)
{
	char szQuery[1024];
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackCell(pack, rank);

	rank = rank - 1;
	Format(szQuery, 1024, "SELECT `steamid`, `name`, `mapname`, `runtimepro` FROM `ck_playertimes` WHERE `mapname` LIKE '%c%s%c' AND style = 0 ORDER BY `runtimepro` ASC LIMIT %i, 1;", PERCENT, szMapName, PERCENT, rank);
	SQL_TQuery(g_hDb, db_selectMapRankUnknownCallback, szQuery, pack, DBPrio_Low);
}

public void db_selectMapRankUnknownCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (db_selectMapRankUnknownCallback): %s", error);
		return;
	}

	ResetPack(data);
	int client = ReadPackCell(data);
	int rank = ReadPackCell(data);
	CloseHandle(data);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		char szSteamId[32];
		char playername[MAX_NAME_LENGTH];
		char mapname[128];
		float runtimepro;

		SQL_FetchString(hndl, 0, szSteamId, 32);
		SQL_FetchString(hndl, 1, playername, MAX_NAME_LENGTH);
		SQL_FetchString(hndl, 2, mapname, sizeof(mapname));
		runtimepro = SQL_FetchFloat(hndl, 3);

		FormatTimeFloat(client, runtimepro, 3, g_szRuntimepro[client], sizeof(g_szRuntimepro));

		Handle pack = CreateDataPack();
		WritePackCell(pack, client);
		WritePackCell(pack, rank);
		WritePackString(pack, szSteamId);
		WritePackString(pack, playername);
		WritePackString(pack, mapname);

		char szQuery[1024];

		Format(szQuery, 1024, "SELECT count(name) FROM `ck_playertimes` WHERE `mapname` = '%s' AND style = 0;", mapname);
		SQL_TQuery(g_hDb, db_SelectTotalMapCompletesUnknownCallback, szQuery, pack, DBPrio_Low);
	}
	else
	{
		PrintToChat(client, " %cSurftimer %c| No result found for player or map", LIMEGREEN, WHITE);
	}
}

public void db_SelectTotalMapCompletesUnknownCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (db_SelectTotalMapCompletesUnknownCallback): %s ", error);
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	int rank = ReadPackCell(pack);
	char szSteamId[32];
	char playername[MAX_NAME_LENGTH];
	char mapname[128];
	ReadPackString(pack, szSteamId, 32);
	ReadPackString(pack, playername, sizeof(playername));
	ReadPackString(pack, mapname, sizeof(mapname));
	CloseHandle(pack);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		int totalplayers = SQL_FetchInt(hndl, 0);

		if(StrEqual(mapname, g_szMapName))
		{
			char szGroup[128];
			if(rank >= 11 && rank <= g_G1Top)
				Format(szGroup, 128, "[%cGroup 1%c]", DARKRED, WHITE);
			else if(rank >= g_G2Bot && rank <= g_G2Top)
				Format(szGroup, 128, "[%cGroup 2%c]", GREEN, WHITE);
			else if(rank >= g_G3Bot && rank <= g_G3Top)
				Format(szGroup, 128, "[%cGroup 3%c]", BLUE, WHITE);
			else if(rank >= g_G4Bot && rank <= g_G4Top)
				Format(szGroup, 128, "[%cGroup 4%c]", YELLOW, WHITE);
			else if(rank >= g_G5Bot && rank <= g_G5Top)
				Format(szGroup, 128, "[%cGroup 5%c]", GRAY, WHITE);
			else
				Format(szGroup, 128, "");

			if(rank >= 11 && rank <= g_G5Top)
				PrintToChatAll(" %cSurftimer %c| %c%s %cis ranked %c#%i%c/%i %s with a time of %c%s %con %c%s", LIMEGREEN, WHITE, YELLOW, playername, WHITE, LIMEGREEN, rank, WHITE, totalplayers, szGroup, LIMEGREEN, g_szRuntimepro[client], WHITE, YELLOW, mapname);
			else
				PrintToChatAll(" %cSurftimer %c| %c%s %cis ranked %c#%i%c/%i with a time of %c%s %con %c%s", LIMEGREEN, WHITE, YELLOW, playername, WHITE, LIMEGREEN, rank, WHITE, totalplayers, LIMEGREEN, g_szRuntimepro[client], WHITE, YELLOW, mapname);
		}
		else
		{
			PrintToChatAll(" %cSurftimer %c| %c%s %cis ranked %c#%i%c/%i with a time of %c%s %con %c%s", LIMEGREEN, WHITE, YELLOW, playername, WHITE, LIMEGREEN, rank, WHITE, totalplayers, LIMEGREEN, g_szRuntimepro[client], WHITE, YELLOW, mapname);
		}
	}
	else
	{
		PrintToChat(client, " %cSurftimer %c| No result found for player or map", LIMEGREEN, WHITE);
	}
}

public void db_selectBonusRank(int client, char szSteamId[32], char szMapName[128], int bonus)
{
	char szQuery[1024];

	Format(szQuery, 1024, "SELECT `steamid`, `name`, `mapname`, `runtime`, zonegroup FROM `ck_bonus` WHERE `steamid` = '%s' AND `mapname` LIKE '%c%s%c' AND zonegroup = %i AND style = 0 LIMIT 1;", szSteamId, PERCENT, szMapName, PERCENT, bonus);
	SQL_TQuery(g_hDb, db_selectBonusRankCallback, szQuery, client, DBPrio_Low);
}

public void db_selectBonusRankCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (db_selectBonusRankCallback): %s", error);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		char szSteamId[32];
		char playername[MAX_NAME_LENGTH];
		char mapname[128];
		float runtimepro;
		int bonus;

		SQL_FetchString(hndl, 0, szSteamId, 32);
		SQL_FetchString(hndl, 1, playername, MAX_NAME_LENGTH);
		SQL_FetchString(hndl, 2, mapname, sizeof(mapname));
		runtimepro = SQL_FetchFloat(hndl, 3);
		bonus = SQL_FetchInt(hndl, 4);

		FormatTimeFloat(client, runtimepro, 3, g_szRuntimepro[client], sizeof(g_szRuntimepro));

		Handle pack = CreateDataPack();
		WritePackCell(pack, client);
		WritePackString(pack, szSteamId);
		WritePackString(pack, playername);
		WritePackString(pack, mapname);
		WritePackCell(pack, bonus);

		char szQuery[1024];

		Format(szQuery, 1024, "SELECT count(name) FROM `ck_bonus` WHERE `mapname` = '%s' AND zonegroup = %i AND style = 0 AND runtime > 0.0;", mapname, bonus);
		SQL_TQuery(g_hDb, db_SelectTotalBonusCompletesCallback, szQuery, pack, DBPrio_Low);
	}
	else
	{
		PrintToChat(client, " %cSurftimer %c| No result found for player or map", LIMEGREEN, WHITE);
	}
}

public void db_SelectTotalBonusCompletesCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (db_SelectTotalBonusCompletesCallback): %s ", error);
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	char szSteamId[32];
	char playername[MAX_NAME_LENGTH];
	char mapname[128];
	ReadPackString(pack, szSteamId, 32);
	ReadPackString(pack, playername, sizeof(playername));
	ReadPackString(pack, mapname, sizeof(mapname));
	int bonus = ReadPackCell(pack);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		g_totalPlayerTimes[client] = SQL_FetchInt(hndl, 0);

		char szQuery[1024];

		Format(szQuery, 1024, "SELECT name,mapname FROM ck_bonus WHERE runtime <= (SELECT runtime FROM ck_bonus WHERE steamid = '%s' AND mapname = '%s' AND zonegroup = %i AND style = 0 AND runtime > -1.0) AND mapname = '%s' AND zonegroup = %i AND runtime > -1.0 ORDER BY runtime;", szSteamId, mapname, bonus, mapname, bonus);
		SQL_TQuery(g_hDb, db_SelectPlayersBonusRankCallback, szQuery, pack, DBPrio_Low);
	}
	else
	{
		CloseHandle(pack);
	}
}

public void db_SelectPlayersBonusRankCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (db_SelectPlayersBonusRankCallback): %s ", error);
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	char szSteamId[32];
	char playername[MAX_NAME_LENGTH];
	char mapname[128];
	ReadPackString(pack, szSteamId, 32);
	ReadPackString(pack, playername, sizeof(playername));
	ReadPackString(pack, mapname, sizeof(mapname));
	int bonus = ReadPackCell(pack);
	CloseHandle(pack);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		int rank;
		rank = SQL_GetRowCount(hndl);


		PrintToChatAll(" %cSurftimer %c| %c%s %cis ranked %c#%i%c/%i with a time of %c%s %con %c%s %cbonus %i", LIMEGREEN, WHITE, YELLOW, playername, WHITE, LIMEGREEN, rank, WHITE, g_totalPlayerTimes[client], LIMEGREEN, g_szRuntimepro[client], WHITE, YELLOW, mapname, ORANGE, bonus);
	}
	else
	{
		CloseHandle(pack);
	}
}

public void db_selectMapRecordTime(int client, char szMapName[128])
{
	char szQuery[1024];

	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, szMapName);

	Format(szQuery, 1024, "SELECT db1.runtimepro, IFNULL(db1.mapname, 'NULL'),  db2.name, db1.steamid FROM ck_playertimes db1 INNER JOIN ck_playerrank db2 ON db1.steamid = db2.steamid WHERE mapname LIKE '%c%s%c' AND runtimepro > -1.0 AND style = 0 ORDER BY runtimepro ASC LIMIT 1", PERCENT, szMapName, PERCENT);
	SQL_TQuery(g_hDb, db_selectMapRecordTimeCallback, szQuery, pack, DBPrio_Low);
}

public void db_selectMapRecordTimeCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (db_selectMapRecordTimeCallback): %s", error);
		return;
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	char szMapNameArg[128];
	ReadPackString(pack, szMapNameArg, sizeof(szMapNameArg));
	CloseHandle(pack);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		float runtimepro;
		char szMapName[128];
		char szRecord[64];
		char szName[64];
		runtimepro = SQL_FetchFloat(hndl, 0);
		SQL_FetchString(hndl, 1, szMapName, sizeof(szMapName));
		SQL_FetchString(hndl, 2, szName, sizeof(szName));

		if(StrEqual(szMapName, "NULL"))
		{
			PrintToChat(client, " %cSurftimer %c| No result found for %s", LIMEGREEN, WHITE, szMapNameArg);
		}
		else
		{
			FormatTimeFloat(client, runtimepro, 3, szRecord, sizeof(szRecord));

			PrintToChat(client, " %cSurftimer %c| %c%s %cholds the record with time: %c%s %con %c%s", LIMEGREEN, WHITE, YELLOW, szName, WHITE, LIMEGREEN, szRecord, WHITE, YELLOW, szMapName);
		}
	}
	else
	{
		PrintToChat(client, " %cSurftimer %c| No result found for %s", LIMEGREEN, WHITE, szMapNameArg);
	}
}

public void db_selectPlayerRank(int client, int rank, char szSteamId[32])
{
	char szQuery[1024];

	if(StrContains(szSteamId, "none", false)!= -1) // Select Rank Number
	{
		g_rankArg[client] = rank;
		rank -= 1;
		Format(szQuery, 1024, "SELECT `name`, `points` FROM `ck_playerrank` ORDER BY `points` DESC LIMIT %i, 1;", rank);
	}
	else if(rank == 0) // Self Rank Cmd
	{
		g_rankArg[client] = -1;
		Format(szQuery, 1024, "SELECT `name`, `points` FROM `ck_playerrank` WHERE `steamid` = '%s';", szSteamId);
	}

	SQL_TQuery(g_hDb, db_selectPlayerRankCallback, szQuery, client, DBPrio_Low);
}

public void db_selectPlayerRankCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (db_selectPlayerRankCallback): %s", error);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		char szName[32];
		int points;
		int rank;

		SQL_FetchString(hndl, 0, szName, sizeof(szName));
		points = SQL_FetchInt(hndl, 1);

		if(g_rankArg[client] == -1)
		{
			rank = g_PlayerRank[client];
			g_rankArg[client] = 1;
		}
		else
			rank = g_rankArg[client];

		PrintToChatAll(" %cSurftimer %c| %c%s %cis ranked %c%i%c/%i with %c%i %cpoints", LIMEGREEN, WHITE, YELLOW, szName, WHITE, LIMEGREEN, rank, WHITE, g_pr_RankedPlayers, LIMEGREEN, points, WHITE);
	}
	else
		PrintToChat(client, " %cSurftimer %c| No result found", LIMEGREEN, WHITE);
}

public void db_selectPlayerRankUnknown(int client, char szName[128])
{
	char szQuery[1024];
	char szNameE[MAX_NAME_LENGTH * 2 + 1];
	SQL_EscapeString(g_hDb, szName, szNameE, MAX_NAME_LENGTH * 2 + 1);
	Format(szQuery, 1024, "SELECT `steamid`, `name`, `points` FROM `ck_playerrank` WHERE `name` LIKE '%c%s%c' ORDER BY `points` DESC LIMIT 0, 1;", PERCENT, szNameE, PERCENT);

	SQL_TQuery(g_hDb, db_selectPlayerRankUnknownCallback, szQuery, client, DBPrio_Low);
}

public void db_selectPlayerRankUnknownCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (db_selectPlayerRankUnknownCallback): %s", error);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		char szSteamId[32];
		char szName[128];
		int points;

		SQL_FetchString(hndl, 0, szSteamId, sizeof(szSteamId));
		SQL_FetchString(hndl, 1, szName, sizeof(szName));
		points = SQL_FetchInt(hndl, 2);

		Handle pack = CreateDataPack();
		WritePackString(pack, szSteamId);
		WritePackString(pack, szName);
		WritePackCell(pack, points);
		WritePackCell(pack, client);

		char szQuery[1024];
		//"SELECT name FROM ck_playerrank WHERE points >= (SELECT points FROM ck_playerrank WHERE steamid = '%s') ORDER BY points";
		Format(szQuery, 512, sql_selectRankedPlayersRank, szSteamId);
		SQL_TQuery(g_hDb, db_getPlayerRankUnknownCallback, szQuery, pack, DBPrio_Low);
	}
	else
		PrintToChat(client, " %cSurftimer %c| No result found", LIMEGREEN, WHITE);
}

public void db_getPlayerRankUnknownCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (db_getPlayerRankUnknownCallback): %s", error);
		return;
	}

	ResetPack(pack);
	char szSteamId[32];
	char szName[128];
	ReadPackString(pack, szSteamId, sizeof(szSteamId));
	ReadPackString(pack, szName, sizeof(szName));
	int points = ReadPackCell(pack);
	int client = ReadPackCell(pack);
	CloseHandle(pack);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		int playerrank = SQL_GetRowCount(hndl);

		PrintToChatAll(" %cSurftimer %c| %c%s %cis ranked %c%i%c/%i with %c%i %cpoints", LIMEGREEN, WHITE, YELLOW, szName, WHITE, LIMEGREEN, playerrank, WHITE, g_pr_RankedPlayers, LIMEGREEN, points, WHITE);
	}
	else
		PrintToChat(client, " %cSurftimer %c| No result found for %c%s", LIMEGREEN, WHITE, YELLOW, szName);
}

public void db_selectMapImprovement(int client, char szMapName[128])
{
	char szQuery[1024];

	Format(szQuery, 1024, "SELECT mapname, (SELECT count(1) FROM ck_playertimes b WHERE a.mapname = b.mapname AND b.style = 0) as total, (SELECT tier FROM ck_maptier b WHERE a.mapname = b.mapname) as tier FROM ck_playertimes a where mapname LIKE '%c%s%c' AND style = 0 LIMIT 1;", PERCENT, szMapName, PERCENT);
	SQL_TQuery(g_hDb, db_selectMapImprovementCallback, szQuery, client, DBPrio_Low);
}

public void db_selectMapImprovementCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (db_selectMapImprovementCallback): %s", error);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		char szMapName[32];
		int totalplayers;
		int tier;

		SQL_FetchString(hndl, 0, szMapName, sizeof(szMapName));
		totalplayers = SQL_FetchInt(hndl, 1);
		tier = SQL_FetchInt(hndl, 2);

		g_szMiMapName[client] = szMapName;
		int type;
		type = g_MiType[client];

		// Map Completion Points
		int mapcompletion;
		if(tier == 1)
			mapcompletion = 25;
		else if(tier == 2)
			mapcompletion = 50;
		else if(tier == 3)
			mapcompletion = 100;
		else if(tier == 4)
			mapcompletion = 200;
		else if(tier == 5)
			mapcompletion = 400;
		else if(tier == 6)
			mapcompletion = 600;
		else // no tier
			mapcompletion = 13;

		// Calculate Group Ranks
		float wrpoints;
		//float points;
		float g1points;
		float g2points;
		float g3points;
		float g4points;
		float g5points;

		// Group 1
		float fG1top;
		int g1top;
		int g1bot = 11;
		fG1top = (float(totalplayers) * g_Group1Pc);
		fG1top += 11.0; // Rank 11 is always End of Group 1
		g1top = RoundToCeil(fG1top);

		int g1difference = (g1top - g1bot);
		if(g1difference < 4)
			g1top = (g1bot + 4);


		//Group 2
		float fG2top;
		int g2top;
		int g2bot;
		g2bot = g1top + 1;
		fG2top = (float(totalplayers) * g_Group2Pc);
		fG2top += 11.0;
		g2top = RoundToCeil(fG2top);

		int g2difference = (g2top - g2bot);
		if(g2difference < 4)
			g2top = (g2bot + 4);

		//Group 3
		float fG3top;
		int g3top;
		int g3bot;
		g3bot = g2top + 1;
		fG3top = (float(totalplayers) * g_Group3Pc);
		fG3top += 11.0;
		g3top = RoundToCeil(fG3top);

		int g3difference = (g3top - g3bot);
		if(g3difference < 4)
			g3top = (g3bot + 4);

		//Group 4
		float fG4top;
		int g4top;
		int g4bot;
		g4bot = g3top + 1;
		fG4top = (float(totalplayers) * g_Group4Pc);
		fG4top += 11.0;
		g4top = RoundToCeil(fG4top);

		int g4difference = (g4top - g4bot);
		if(g4difference < 4)
			g4top = (g4bot + 4);

		//Group 5
		float fG5top;
		int g5top;
		int g5bot;
		g5bot = g4top + 1;
		fG5top = (float(totalplayers) * g_Group5Pc);
		fG5top += 11.0;
		g5top = RoundToCeil(fG5top);

		int g5difference = (g5top - g5bot);
		if(g5difference < 4)
			g5top = (g5bot + 4);

		// WR Points
		if(tier == 1)
		{
			wrpoints = ((float(totalplayers) * 1.75) / 6);
			wrpoints += 58.5;
		}
		else if(tier == 2)
		{
			wrpoints = ((float(totalplayers) * 2.8) / 5);
			wrpoints += 82.15;
		}
		else if(tier == 3)
		{
			wrpoints = ((float(totalplayers) * 3.5) / 4);
			if(wrpoints < 300)
				wrpoints = 350.0;
			else
				wrpoints += 117;
		}
		else if(tier == 4)
		{
			wrpoints = ((float(totalplayers) * 5.74) / 4);
			if(wrpoints < 400)
				wrpoints = 400.0;
			else
				wrpoints += 164.25;
		}
		else if(tier == 5)
		{
			wrpoints = ((float(totalplayers) * 7) / 4);
			if(wrpoints < 500)
				wrpoints = 500.0;
			else
				wrpoints += 234;
		}
		else if(tier == 6)
		{
			wrpoints = ((float(totalplayers) * 14) / 4);
			if(wrpoints < 600)
				wrpoints = 600.0;
			else
				wrpoints += 328;
		}
		else // no tier set
			wrpoints = 25.0;

		// Round WR points up
		int iwrpoints;
		iwrpoints = RoundToCeil(wrpoints);

		// Calculate Top 10 Points
		int rank2;
		float frank2;
		int rank3;
		float frank3;
		int rank4;
		float frank4;
		int rank5;
		float frank5;
		int rank6;
		float frank6;
		int rank7;
		float frank7;
		int rank8;
		float frank8;
		int rank9;
		float frank9;
		int rank10;
		float frank10;

		frank2 = (0.80 * iwrpoints);
		rank2 += RoundToCeil(frank2);
		frank3 = (0.75 * iwrpoints);
		rank3 += RoundToCeil(frank3);
		frank4 = (0.70 * iwrpoints);
		rank4 += RoundToCeil(frank4);
		frank5 = (0.65 * iwrpoints);
		rank5 += RoundToCeil(frank5);
		frank6 = (0.60 * iwrpoints);
		rank6 += RoundToCeil(frank6);
		frank7 = (0.55 * iwrpoints);
		rank7 += RoundToCeil(frank7);
		frank8 = (0.50 * iwrpoints);
		rank8 += RoundToCeil(frank8);
		frank9 = (0.45 * iwrpoints);
		rank9 += RoundToCeil(frank9);
		frank10 = (0.40 * iwrpoints);
		rank10 += RoundToCeil(frank10);

		// Calculate Group Points
		g1points = (wrpoints * 0.25);
		g2points = (g1points / 1.5);
		g3points = (g2points / 1.5);
		g4points = (g3points / 1.5);
		g5points = (g4points / 1.5);

		// Draw Menu Map Improvement Menu
		if(type == 0)
		{
			Menu mi = CreateMenu(MapImprovementMenuHandler);
			SetMenuTitle(mi, "[Point Reward: %s]\n------------------------------\nTier: %i\n \n[Completion Points]\n \nMap Finish Points: %i\n \n[Map Improvement Groups]\n \n[Group 1] Ranks 11-%i ~ %i Pts\n[Group 2] Ranks %i-%i ~ %i Pts\n[Group 3] Ranks %i-%i ~ %i Pts\n[Group 4] Ranks %i-%i ~ %i Pts\n[Group 5] Ranks %i-%i ~ %i Pts\n \nWR Pts: %i\n \nTotal Completions: %i\n \n",szMapName, tier, mapcompletion, g1top, RoundFloat(g1points), g2bot, g2top, RoundFloat(g2points), g3bot, g3top, RoundFloat(g3points), g4bot, g4top, RoundFloat(g4points), g5bot, g5top, RoundFloat(g5points), iwrpoints, totalplayers);
			//AddMenuItem(mi, "", "", ITEMDRAW_SPACER);
			AddMenuItem(mi, szMapName, "Top 10 Points");
			SetMenuOptionFlags(mi, MENUFLAG_BUTTON_EXIT);
			DisplayMenu(mi, client, MENU_TIME_FOREVER);
		}
		else // Draw Top 10 Points Menu
		{
			Menu mi = CreateMenu(MapImprovementTop10MenuHandler);
			SetMenuTitle(mi, "[Point Reward: %s]\n------------------------------\nTier: %i\n \n[Completion Points]\n \nMap Finish Points: %i\n \n[Top 10 Points]\n \nRank 1: %i Pts\nRank 2: %i Pts\nRank 3: %i Pts\nRank 4: %i Pts\nRank 5: %i Pts\nRank 6: %i Pts\nRank 7: %i Pts\nRank 8: %i Pts\nRank 9: %i Pts\nRank 10: %i Pts\n \nTotal Completions: %i\n",szMapName, tier, mapcompletion, iwrpoints, rank2, rank3, rank4, rank5, rank6, rank7, rank8, rank9, rank10, totalplayers);
			AddMenuItem(mi, "", "", ITEMDRAW_SPACER);
			SetMenuOptionFlags(mi, MENUFLAG_BUTTON_EXIT);
			DisplayMenu(mi, client, MENU_TIME_FOREVER);
		}
	}
	else
	{
		PrintToChat(client, " %cSurftimer %c| No result found for player or map", LIMEGREEN, WHITE);
	}
}

public int MapImprovementMenuHandler(Menu mi, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char szMapName[128];
		GetMenuItem(mi, param2, szMapName, sizeof(szMapName));
		g_MiType[param1] = 1;
		db_selectMapImprovement(param1, szMapName);
	}
	if (action == MenuAction_End)
		CloseHandle(mi);
}

public int MapImprovementTop10MenuHandler(Menu mi, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Cancel)
	{
		g_MiType[param1] = 0;
		db_selectMapImprovement(param1, g_szMiMapName[param1]);
	}
	if (action == MenuAction_End)
	{
		CloseHandle(mi);
	}
}

public void db_selectCurrentMapImprovement()
{
	char szQuery[1024];

	Format(szQuery, 1024, "SELECT mapname, (SELECT count(1) FROM ck_playertimes b WHERE a.mapname = b.mapname AND b.style = 0) as total FROM ck_playertimes a where mapname = '%s' AND style = 0 LIMIT 0, 1;", g_szMapName);
	SQL_TQuery(g_hDb, db_selectMapCurrentImprovementCallback, szQuery, DBPrio_Low);
}

public void db_selectMapCurrentImprovementCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (db_selectMapCurrentImprovementCallback): %s", error);
		if (!g_bServerDataLoaded)
			db_selectAnnouncements();
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		int totalplayers;
		totalplayers = SQL_FetchInt(hndl, 1);

		// Group 1
		float fG1top;
		int g1top;
		int g1bot = 11;
		fG1top = (float(totalplayers) * g_Group1Pc);
		fG1top += 11.0; // Rank 11 is always End of Group 1
		g1top = RoundToCeil(fG1top);

		int g1difference = (g1top - g1bot);
		if(g1difference < 4)
			g1top = (g1bot + 4);

		g_G1Top = g1top;

		//Group 2
		float fG2top;
		int g2top;
		int g2bot;
		g2bot = g1top + 1;
		fG2top = (float(totalplayers) * g_Group2Pc);
		fG2top += 11.0;
		g2top = RoundToCeil(fG2top);
		g_G2Bot = g2bot;
		g_G2Top = g2top;

		int g2difference = (g2top - g2bot);
		if(g2difference < 4)
			g2top = (g2bot + 4);

		g_G2Bot = g2bot;
		g_G2Top = g2top;

		//Group 3
		float fG3top;
		int g3top;
		int g3bot;
		g3bot = g2top + 1;
		fG3top = (float(totalplayers) * g_Group3Pc);
		fG3top += 11.0;
		g3top = RoundToCeil(fG3top);

		int g3difference = (g3top - g3bot);
		if(g3difference < 4)
			g3top = (g3bot + 4);

		g_G3Bot = g3bot;
		g_G3Top = g3top;

		//Group 4
		float fG4top;
		int g4top;
		int g4bot;
		g4bot = g3top + 1;
		fG4top = (float(totalplayers) * g_Group4Pc);
		fG4top += 11.0;
		g4top = RoundToCeil(fG4top);

		int g4difference = (g4top - g4bot);
		if(g4difference < 4)
			g4top = (g4bot + 4);

		g_G4Bot = g4bot;
		g_G4Top = g4top;

		//Group 5
		float fG5top;
		int g5top;
		int g5bot;
		g5bot = g4top + 1;
		fG5top = (float(totalplayers) * g_Group5Pc);
		fG5top += 11.0;
		g5top = RoundToCeil(fG5top);

		int g5difference = (g5top - g5bot);
		if(g5difference < 4)
			g5top = (g5bot + 4);

		g_G5Bot = g5bot;
		g_G5Top = g5top;
	}
	else
	{
		PrintToServer("surftimer | No result found for map %s (db_selectMapCurrentImprovementCallback)", g_szMapName);
	}

	if (!g_bServerDataLoaded)
		db_selectAnnouncements();
}
