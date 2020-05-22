static int g_iCount = -1;
static int g_iCounter = -1;
static float g_fStart = 0.0;

public Action Command_DatabaseUpgrade(int client, int args)
{
    ReplyToCommand(client, "Starting database upgrade...");

    db_startUpgrading();
}

void db_startUpgrading()
{
	Transaction tTransaction = new Transaction();
	tTransaction.AddQuery("SELECT prespeed FROM ck_zones LIMIT 1", 0);
	tTransaction.AddQuery("SELECT ck_maptier.ranked, ck_playerrank.style FROM ck_maptier, ck_playerrank LIMIT 1", 1);
	tTransaction.AddQuery("SELECT wrcppoints FROM ck_playerrank LIMIT 1", 2);
	tTransaction.AddQuery("SELECT teleside FROM ck_playeroptions2 LIMIT 1", 3);
	tTransaction.AddQuery("SELECT velEndXYZ FROM ck_checkpoints LIMIT 1", 4);
	// Version 5 will used in SQLTxn_InsertCheckpouintsSuccess callback
	tTransaction.AddQuery("SELECT steamid FROM ck_announcements LIMIT 1", 6);
	g_dDb.Execute(tTransaction, SQLTxn_CheckDatabaseUpgradesSuccess, SQLTxn_CheckDatabaseUpgradesFailed);
}

public void SQLTxn_CheckDatabaseUpgradesSuccess(Handle db, any data, int numQueries, Handle[] results, any[] queryData)
{
	LogMessage("[SurfTimer] All tables are up to date!");
}

public void SQLTxn_CheckDatabaseUpgradesFailed(Handle db, any data, int numQueries, const char[] error, int failIndex, any[] queryData)
{
	LogMessage("[SurfTimer] Upgrading database... (Version: %d)", queryData[failIndex]);
	db_upgradeDatabase(queryData[failIndex]);
}

public void db_upgradeDatabase(int version)
{
	Transaction tTransaction = new Transaction();

	if (version == 0)
	{
		// SurfTimer v2.01 -> SurfTimer v2.1
		char query[128];
		for (int i = 1; i < 11; i++)
		{
			Format(query, sizeof(query), "ALTER TABLE ck_maptier DROP COLUMN btier%i", i);
			tTransaction.AddQuery(query);
		}

		tTransaction.AddQuery("ALTER TABLE ck_maptier ADD COLUMN maxvelocity FLOAT NOT NULL DEFAULT '3500.0';", 1);
		tTransaction.AddQuery("ALTER TABLE ck_maptier ADD COLUMN announcerecord INT(11) NOT NULL DEFAULT '0';", 2);
		tTransaction.AddQuery("ALTER TABLE ck_maptier ADD COLUMN gravityfix INT(11) NOT NULL DEFAULT '1';", 3);
		tTransaction.AddQuery("ALTER TABLE ck_zones ADD COLUMN `prespeed` int(64) NOT NULL DEFAULT '350';", 4);
		tTransaction.AddQuery("ALTER TABLE ck_maptier ADD INDEX tier (mapname, tier);", 5);
		tTransaction.AddQuery("ALTER TABLE ck_maptier ADD INDEX mapsettings (mapname, maxvelocity, announcerecord, gravityfix);", 6);
		tTransaction.AddQuery("UPDATE ck_maptier a, ck_mapsettings b SET a.maxvelocity = b.maxvelocity WHERE a.mapname = b.mapname;", 7);
		tTransaction.AddQuery("UPDATE ck_maptier a, ck_mapsettings b SET a.announcerecord = b.announcerecord WHERE a.mapname = b.mapname;", 8);
		tTransaction.AddQuery("UPDATE ck_maptier a, ck_mapsettings b SET a.gravityfix = b.gravityfix WHERE a.mapname = b.mapname;", 9);
		tTransaction.AddQuery("UPDATE ck_zones a, ck_mapsettings b SET a.prespeed = b.startprespeed WHERE a.mapname = b.mapname AND zonetype = 1;", 10);
		tTransaction.AddQuery("DROP TABLE IF EXISTS ck_mapsettings;", 11);
	}
	else if (version == 1)
	{
		// SurfTimer v2.1 -> v2.2
		tTransaction.AddQuery("ALTER TABLE ck_maptier ADD COLUMN ranked INT(11) NOT NULL DEFAULT '1';", 1);
		tTransaction.AddQuery("ALTER TABLE ck_playerrank DROP PRIMARY KEY, ADD COLUMN style INT(11) NOT NULL DEFAULT '0', ADD PRIMARY KEY (steamid, style);", 2);
	}
	else if (version == 2)
	{
		tTransaction.AddQuery("ALTER TABLE ck_playerrank ADD COLUMN wrcppoints INT(11) NOT NULL DEFAULT 0 AFTER `wrbpoints`;", 1);
	}
	else if (version == 3)
	{
		tTransaction.AddQuery("ALTER TABLE ck_playeroptions2 DROP COLUMN teleside, ADD COLUMN teleside INT(11) NOT NULL DEFAULT 0 AFTER centrehud;", 1);
		tTransaction.AddQuery("ALTER TABLE ck_spawnlocations DROP PRIMARY KEY, DROP COLUMN teleside, ADD COLUMN teleside INT(11) NOT NULL DEFAULT 0 AFTER stage, ADD PRIMARY KEY (mapname, zonegroup, stage, teleside);", 1);
	}
	else if (version == 4)
	{
		g_dDb.Query(sqlCreateCheckPointsNew, "CREATE TABLE IF NOT EXISTS `ck_checkpointsnew`( `steamid` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL, `mapname` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL, `cp` int(11) NOT NULL, `time` float NOT NULL, `velStartXY` int(11) DEFAULT 0, `velStartXYZ` int(11) DEFAULT 0, `velStartZ` int(11) DEFAULT 0, `velEndXY` int(11) DEFAULT 0, `velEndXYZ` int(11) DEFAULT 0, `velEndZ` int(11) DEFAULT 0, `velAvgXY` int(11) DEFAULT 0, `velAvgXYZ` int(11) DEFAULT 0, `velAvgZ` int(11) DEFAULT 0, `zonegroup` int(12) NOT NULL, PRIMARY KEY (`steamid`,`mapname`,`cp`,`zonegroup`)) DEFAULT CHARSET=utf8mb4;");
		
		delete tTransaction;
		return;
	}
	else if (version == 5)
	{
		tTransaction.AddQuery("ALTER TABLE ck_checkpoints RENAME TO ck_checkpointsold;", 1);
		tTransaction.AddQuery("ALTER TABLE ck_checkpointsnew RENAME TO ck_checkpoints;", 2);
		tTransaction.AddQuery("ALTER TABLE `ck_playertimes` ADD `velStartXY` INT NOT NULL DEFAULT 0 AFTER `runtimepro`, ADD `velStartXYZ` INT NOT NULL DEFAULT 0 AFTER `velStartXY`, ADD `velStartZ` INT NOT NULL DEFAULT 0 AFTER `velStartXYZ`, ADD `velEndXY` INT NOT NULL DEFAULT 0 AFTER `velStartZ`, ADD `velEndXYZ` INT NOT NULL DEFAULT 0 AFTER `velEndXY`, ADD `velEndZ` INT NOT NULL DEFAULT 0 AFTER `velEndXYZ`;", 3);
		tTransaction.AddQuery("ALTER TABLE `ck_bonus` ADD `velStartXY` INT NOT NULL DEFAULT 0 AFTER `runtime`, ADD `velStartXYZ` INT NOT NULL DEFAULT 0 AFTER `velStartXY`, ADD `velStartZ` INT NOT NULL DEFAULT 0 AFTER `velStartXYZ`, ADD `velEndXY` INT NOT NULL DEFAULT 0 AFTER `velStartZ`, ADD `velEndXYZ` INT NOT NULL DEFAULT 0 AFTER `velEndXY`, ADD `velEndZ` INT NOT NULL DEFAULT 0 AFTER `velEndXYZ`;", 4);
		tTransaction.AddQuery("ALTER TABLE `ck_wrcps` ADD `velStartXY` INT NOT NULL DEFAULT 0 AFTER `runtimepro`, ADD `velStartXYZ` INT NOT NULL DEFAULT 0 AFTER `velStartXY`, ADD `velStartZ` INT NOT NULL DEFAULT 0 AFTER `velStartXYZ`, ADD `velEndXY` INT NOT NULL DEFAULT 0 AFTER `velStartZ`, ADD `velEndXYZ` INT NOT NULL DEFAULT 0 AFTER `velEndXY`, ADD `velEndZ` INT NOT NULL DEFAULT 0 AFTER `velEndXYZ`;", 5);
		tTransaction.AddQuery("ALTER TABLE `ck_playeroptions2` DROP COLUMN `velcmphud`, DROP COLUMN `velcmpchat`, ADD COLUMN `velcmphud` INT NOT NULL DEFAULT 1 AFTER `teleside`, ADD COLUMN `velcmpchat` INT NOT NULL DEFAULT 1 AFTER `velcmphud`;", 6);
	}
	else if (version == 6)
	{
		tTransaction.AddQuery("ALTER TABLE `ck_announcements` ADD `steamid` varchar(32) NOT NULL AFTER `server`;", 1);
	}
	else if (version == 7)
	{
		tTransaction.AddQuery("ALTER TABLE `ck_playertimes` MODIFY `velStartXY` INT NOT NULL DEFAULT 0;", 1);
		tTransaction.AddQuery("ALTER TABLE `ck_playertimes` MODIFY `velStartXYZ` INT NOT NULL DEFAULT 0;", 2);
		tTransaction.AddQuery("ALTER TABLE `ck_playertimes` MODIFY `velStartZ` INT NOT NULL DEFAULT 0;", 3);
		tTransaction.AddQuery("ALTER TABLE `ck_playertimes` MODIFY `velEndXY` INT NOT NULL DEFAULT 0;", 4);
		tTransaction.AddQuery("ALTER TABLE `ck_playertimes` MODIFY `velEndXYZ` INT NOT NULL DEFAULT 0;", 5);
		tTransaction.AddQuery("ALTER TABLE `ck_playertimes` MODIFY `velEndZ` INT NOT NULL DEFAULT 0;", 6);
		tTransaction.AddQuery("ALTER TABLE `ck_bonus` MODIFY `velStartXY` INT NOT NULL DEFAULT 0;", 7);
		tTransaction.AddQuery("ALTER TABLE `ck_bonus` MODIFY `velStartXYZ` INT NOT NULL DEFAULT 0;", 8);
		tTransaction.AddQuery("ALTER TABLE `ck_bonus` MODIFY `velStartZ` INT NOT NULL DEFAULT 0;", 9);
		tTransaction.AddQuery("ALTER TABLE `ck_bonus` MODIFY `velEndXY` INT NOT NULL DEFAULT 0;", 10);
		tTransaction.AddQuery("ALTER TABLE `ck_bonus` MODIFY `velEndXYZ` INT NOT NULL DEFAULT 0;", 11);
		tTransaction.AddQuery("ALTER TABLE `ck_bonus` MODIFY `velEndZ` INT NOT NULL DEFAULT 0;", 12);
		tTransaction.AddQuery("ALTER TABLE `ck_wrcps` MODIFY `velStartXY` INT NOT NULL DEFAULT 0;", 13);
		tTransaction.AddQuery("ALTER TABLE `ck_wrcps` MODIFY `velStartXYZ` INT NOT NULL DEFAULT 0;", 14);
		tTransaction.AddQuery("ALTER TABLE `ck_wrcps` MODIFY `velStartZ` INT NOT NULL DEFAULT 0;", 15);
		tTransaction.AddQuery("ALTER TABLE `ck_wrcps` MODIFY `velEndXY` INT NOT NULL DEFAULT 0;", 16);
		tTransaction.AddQuery("ALTER TABLE `ck_wrcps` MODIFY `velEndXYZ` INT NOT NULL DEFAULT 0;", 17);
		tTransaction.AddQuery("ALTER TABLE `ck_wrcps` MODIFY `velEndZ` INT NOT NULL DEFAULT 0;", 18);
	}
	else
	{
		delete tTransaction;
		return;
	}

	g_dDb.Execute(tTransaction, SQLTxn_UpgradeDatabaseSuccess, SQLTxn_UpgradeDatabaseFailed, version);
}

public void sqlCreateCheckPointsNew(Database db, DBResultSet results, const char[] error, any data)
{
	if (db == null || strlen(error))
	{
		SetFailState("[SurfTimer] (sqlCreateCheckPointsNew) Can't create table \"ck_checkpointsnew\".");
		return;
	}

	g_dDb.Query(sqlGetCheckpointsCount, "SELECT COUNT(steamid) FROM ck_checkpoints;");
}

public void sqlGetCheckpointsCount(Database db, DBResultSet results, const char[] error, any data)
{
	if (db == null || strlen(error))
	{
		SetFailState("[SurfTimer] (sqlGetCheckpointsCount) Can't create table \"ck_checkpointsnew\".");
		return;
	}

	if (results.HasResults && results.FetchRow())
	{
		g_iCount = results.FetchInt(0);
		g_fStart = GetEngineTime();
	}

	if (g_iCount > 0)
	{
		g_dDb.Query(sqlSelectOldCheckpoints, "SELECT * FROM ck_checkpoints;");
	}
}

public void sqlSelectOldCheckpoints(Database db, DBResultSet results, const char[] error, any data)
{
	if (db == null || strlen(error))
	{
		SetFailState("[SurfTimer] (sqlSelectOldCheckpoints) Can't create table \"ck_checkpointsnew\".");
		return;
	}

	char sBuffer[256];
	char sSteam[32];
	char sMap[128];
	float fCP1, fCP2, fCP3, fCP4, fCP5, fCP6, fCP7, fCP8, fCP9, fCP10, fCP11, fCP12, fCP13, fCP14, fCP15, fCP16, fCP17, fCP18, fCP19, fCP20, fCP21, fCP22, fCP23, fCP24, fCP25, fCP26, fCP27, fCP28, fCP29, fCP30, fCP31, fCP32, fCP33, fCP34, fCP35;
	int iZonegroup;

	if (results.HasResults)
	{
		g_iCounter = 0;

		while (results.FetchRow())
		{
			Transaction tTransaction = new Transaction();

			results.FetchString(0, sSteam, sizeof(sSteam));
			results.FetchString(1, sMap, sizeof(sMap));
			fCP1 = results.FetchFloat(2);
			fCP2 = results.FetchFloat(3);
			fCP3 = results.FetchFloat(4);
			fCP4 = results.FetchFloat(5);
			fCP5 = results.FetchFloat(6);
			fCP6 = results.FetchFloat(7);
			fCP7 = results.FetchFloat(8);
			fCP8 = results.FetchFloat(9);
			fCP9 = results.FetchFloat(10);
			fCP10 = results.FetchFloat(11);
			fCP11 = results.FetchFloat(12);
			fCP12 = results.FetchFloat(13);
			fCP13 = results.FetchFloat(14);
			fCP14 = results.FetchFloat(15);
			fCP15 = results.FetchFloat(16);
			fCP16 = results.FetchFloat(17);
			fCP17 = results.FetchFloat(18);
			fCP18 = results.FetchFloat(19);
			fCP19 = results.FetchFloat(20);
			fCP20 = results.FetchFloat(21);
			fCP21 = results.FetchFloat(22);
			fCP22 = results.FetchFloat(23);
			fCP23 = results.FetchFloat(24);
			fCP24 = results.FetchFloat(25);
			fCP25 = results.FetchFloat(26);
			fCP26 = results.FetchFloat(27);
			fCP27 = results.FetchFloat(28);
			fCP28 = results.FetchFloat(29);
			fCP29 = results.FetchFloat(30);
			fCP30 = results.FetchFloat(31);
			fCP31 = results.FetchFloat(32);
			fCP32 = results.FetchFloat(33);
			fCP33 = results.FetchFloat(34);
			fCP34 = results.FetchFloat(35);
			fCP35 = results.FetchFloat(36);
			iZonegroup = results.FetchInt(37);

			if (fCP1 != 0.0)
			{
				Format(sBuffer, sizeof(sBuffer), "INSERT INTO `ck_checkpointsnew` (`steamid`, `mapname`, `cp`, `time`, `zonegroup`) VALUES (\"%s\", \"%s\", '1', '%f', '%d');", sSteam, sMap, fCP1, iZonegroup);
				tTransaction.AddQuery(sBuffer);
			}
			
			if (fCP2 != 0.0)
			{
				Format(sBuffer, sizeof(sBuffer), "INSERT INTO `ck_checkpointsnew` (`steamid`, `mapname`, `cp`, `time`, `zonegroup`) VALUES (\"%s\", \"%s\", '2', '%f', '%d');", sSteam, sMap, fCP2, iZonegroup);
				tTransaction.AddQuery(sBuffer);
			}
			
			if (fCP3 != 0.0)
			{
				Format(sBuffer, sizeof(sBuffer), "INSERT INTO `ck_checkpointsnew` (`steamid`, `mapname`, `cp`, `time`, `zonegroup`) VALUES (\"%s\", \"%s\", '3', '%f', '%d');", sSteam, sMap, fCP3, iZonegroup);
				tTransaction.AddQuery(sBuffer);
			}
			
			if (fCP4 != 0.0)
			{
				Format(sBuffer, sizeof(sBuffer), "INSERT INTO `ck_checkpointsnew` (`steamid`, `mapname`, `cp`, `time`, `zonegroup`) VALUES (\"%s\", \"%s\", '4', '%f', '%d');", sSteam, sMap, fCP4, iZonegroup);
				tTransaction.AddQuery(sBuffer);
			}
			
			if (fCP5 != 0.0)
			{
				Format(sBuffer, sizeof(sBuffer), "INSERT INTO `ck_checkpointsnew` (`steamid`, `mapname`, `cp`, `time`, `zonegroup`) VALUES (\"%s\", \"%s\", '5', '%f', '%d');", sSteam, sMap, fCP5, iZonegroup);
				tTransaction.AddQuery(sBuffer);
			}
			
			if (fCP6 != 0.0)
			{
				Format(sBuffer, sizeof(sBuffer), "INSERT INTO `ck_checkpointsnew` (`steamid`, `mapname`, `cp`, `time`, `zonegroup`) VALUES (\"%s\", \"%s\", '6', '%f', '%d');", sSteam, sMap, fCP6, iZonegroup);
				tTransaction.AddQuery(sBuffer);
			}
			
			if (fCP7 != 0.0)
			{
				Format(sBuffer, sizeof(sBuffer), "INSERT INTO `ck_checkpointsnew` (`steamid`, `mapname`, `cp`, `time`, `zonegroup`) VALUES (\"%s\", \"%s\", '7', '%f', '%d');", sSteam, sMap, fCP7, iZonegroup);
				tTransaction.AddQuery(sBuffer);
			}
			
			if (fCP8 != 0.0)
			{
				Format(sBuffer, sizeof(sBuffer), "INSERT INTO `ck_checkpointsnew` (`steamid`, `mapname`, `cp`, `time`, `zonegroup`) VALUES (\"%s\", \"%s\", '8', '%f', '%d');", sSteam, sMap, fCP8, iZonegroup);
				tTransaction.AddQuery(sBuffer);
			}
			
			if (fCP9 != 0.0)
			{
				Format(sBuffer, sizeof(sBuffer), "INSERT INTO `ck_checkpointsnew` (`steamid`, `mapname`, `cp`, `time`, `zonegroup`) VALUES (\"%s\", \"%s\", '9', '%f', '%d');", sSteam, sMap, fCP9, iZonegroup);
				tTransaction.AddQuery(sBuffer);
			}
			
			if (fCP10 != 0.0)
			{
				Format(sBuffer, sizeof(sBuffer), "INSERT INTO `ck_checkpointsnew` (`steamid`, `mapname`, `cp`, `time`, `zonegroup`) VALUES (\"%s\", \"%s\", '10', '%f', '%d');", sSteam, sMap, fCP10, iZonegroup);
				tTransaction.AddQuery(sBuffer);
			}
			
			if (fCP11 != 0.0)
			{
				Format(sBuffer, sizeof(sBuffer), "INSERT INTO `ck_checkpointsnew` (`steamid`, `mapname`, `cp`, `time`, `zonegroup`) VALUES (\"%s\", \"%s\", '11', '%f', '%d');", sSteam, sMap, fCP11, iZonegroup);
				tTransaction.AddQuery(sBuffer);
			}
			
			if (fCP12 != 0.0)
			{
				Format(sBuffer, sizeof(sBuffer), "INSERT INTO `ck_checkpointsnew` (`steamid`, `mapname`, `cp`, `time`, `zonegroup`) VALUES (\"%s\", \"%s\", '12', '%f', '%d');", sSteam, sMap, fCP12, iZonegroup);
				tTransaction.AddQuery(sBuffer);
			}
			
			if (fCP13 != 0.0)
			{
				Format(sBuffer, sizeof(sBuffer), "INSERT INTO `ck_checkpointsnew` (`steamid`, `mapname`, `cp`, `time`, `zonegroup`) VALUES (\"%s\", \"%s\", '13', '%f', '%d');", sSteam, sMap, fCP13, iZonegroup);
				tTransaction.AddQuery(sBuffer);
			}
			
			if (fCP14 != 0.0)
			{
				Format(sBuffer, sizeof(sBuffer), "INSERT INTO `ck_checkpointsnew` (`steamid`, `mapname`, `cp`, `time`, `zonegroup`) VALUES (\"%s\", \"%s\", '14', '%f', '%d');", sSteam, sMap, fCP14, iZonegroup);
				tTransaction.AddQuery(sBuffer);
			}
			
			if (fCP15 != 0.0)
			{
				Format(sBuffer, sizeof(sBuffer), "INSERT INTO `ck_checkpointsnew` (`steamid`, `mapname`, `cp`, `time`, `zonegroup`) VALUES (\"%s\", \"%s\", '15', '%f', '%d');", sSteam, sMap, fCP15, iZonegroup);
				tTransaction.AddQuery(sBuffer);
			}
			
			if (fCP16 != 0.0)
			{
				Format(sBuffer, sizeof(sBuffer), "INSERT INTO `ck_checkpointsnew` (`steamid`, `mapname`, `cp`, `time`, `zonegroup`) VALUES (\"%s\", \"%s\", '16', '%f', '%d');", sSteam, sMap, fCP16, iZonegroup);
				tTransaction.AddQuery(sBuffer);
			}
			
			if (fCP17 != 0.0)
			{
				Format(sBuffer, sizeof(sBuffer), "INSERT INTO `ck_checkpointsnew` (`steamid`, `mapname`, `cp`, `time`, `zonegroup`) VALUES (\"%s\", \"%s\", '17', '%f', '%d');", sSteam, sMap, fCP17, iZonegroup);
				tTransaction.AddQuery(sBuffer);
			}
			
			if (fCP18 != 0.0)
			{
				Format(sBuffer, sizeof(sBuffer), "INSERT INTO `ck_checkpointsnew` (`steamid`, `mapname`, `cp`, `time`, `zonegroup`) VALUES (\"%s\", \"%s\", '18', '%f', '%d');", sSteam, sMap, fCP18, iZonegroup);
				tTransaction.AddQuery(sBuffer);
			}
			
			if (fCP19 != 0.0)
			{
				Format(sBuffer, sizeof(sBuffer), "INSERT INTO `ck_checkpointsnew` (`steamid`, `mapname`, `cp`, `time`, `zonegroup`) VALUES (\"%s\", \"%s\", '19', '%f', '%d');", sSteam, sMap, fCP19, iZonegroup);
				tTransaction.AddQuery(sBuffer);
			}
			
			if (fCP20 != 0.0)
			{
				Format(sBuffer, sizeof(sBuffer), "INSERT INTO `ck_checkpointsnew` (`steamid`, `mapname`, `cp`, `time`, `zonegroup`) VALUES (\"%s\", \"%s\", '20', '%f', '%d');", sSteam, sMap, fCP20, iZonegroup);
				tTransaction.AddQuery(sBuffer);
			}
			
			if (fCP21 != 0.0)
			{
				Format(sBuffer, sizeof(sBuffer), "INSERT INTO `ck_checkpointsnew` (`steamid`, `mapname`, `cp`, `time`, `zonegroup`) VALUES (\"%s\", \"%s\", '21', '%f', '%d');", sSteam, sMap, fCP21, iZonegroup);
				tTransaction.AddQuery(sBuffer);
			}
			
			if (fCP22 != 0.0)
			{
				Format(sBuffer, sizeof(sBuffer), "INSERT INTO `ck_checkpointsnew` (`steamid`, `mapname`, `cp`, `time`, `zonegroup`) VALUES (\"%s\", \"%s\", '22', '%f', '%d');", sSteam, sMap, fCP22, iZonegroup);
				tTransaction.AddQuery(sBuffer);
			}
			
			if (fCP23 != 0.0)
			{
				Format(sBuffer, sizeof(sBuffer), "INSERT INTO `ck_checkpointsnew` (`steamid`, `mapname`, `cp`, `time`, `zonegroup`) VALUES (\"%s\", \"%s\", '23', '%f', '%d');", sSteam, sMap, fCP23, iZonegroup);
				tTransaction.AddQuery(sBuffer);
			}
			
			if (fCP24 != 0.0)
			{
				Format(sBuffer, sizeof(sBuffer), "INSERT INTO `ck_checkpointsnew` (`steamid`, `mapname`, `cp`, `time`, `zonegroup`) VALUES (\"%s\", \"%s\", '24', '%f', '%d');", sSteam, sMap, fCP24, iZonegroup);
				tTransaction.AddQuery(sBuffer);
			}
			
			if (fCP25 != 0.0)
			{
				Format(sBuffer, sizeof(sBuffer), "INSERT INTO `ck_checkpointsnew` (`steamid`, `mapname`, `cp`, `time`, `zonegroup`) VALUES (\"%s\", \"%s\", '25', '%f', '%d');", sSteam, sMap, fCP25, iZonegroup);
				tTransaction.AddQuery(sBuffer);
			}
			
			if (fCP26 != 0.0)
			{
				Format(sBuffer, sizeof(sBuffer), "INSERT INTO `ck_checkpointsnew` (`steamid`, `mapname`, `cp`, `time`, `zonegroup`) VALUES (\"%s\", \"%s\", '26', '%f', '%d');", sSteam, sMap, fCP26, iZonegroup);
				tTransaction.AddQuery(sBuffer);
			}
			
			if (fCP27 != 0.0)
			{
				Format(sBuffer, sizeof(sBuffer), "INSERT INTO `ck_checkpointsnew` (`steamid`, `mapname`, `cp`, `time`, `zonegroup`) VALUES (\"%s\", \"%s\", '27', '%f', '%d');", sSteam, sMap, fCP27, iZonegroup);
				tTransaction.AddQuery(sBuffer);
			}
			
			if (fCP28 != 0.0)
			{
				Format(sBuffer, sizeof(sBuffer), "INSERT INTO `ck_checkpointsnew` (`steamid`, `mapname`, `cp`, `time`, `zonegroup`) VALUES (\"%s\", \"%s\", '28', '%f', '%d');", sSteam, sMap, fCP28, iZonegroup);
				tTransaction.AddQuery(sBuffer);
			}
			
			if (fCP29 != 0.0)
			{
				Format(sBuffer, sizeof(sBuffer), "INSERT INTO `ck_checkpointsnew` (`steamid`, `mapname`, `cp`, `time`, `zonegroup`) VALUES (\"%s\", \"%s\", '29', '%f', '%d');", sSteam, sMap, fCP29, iZonegroup);
				tTransaction.AddQuery(sBuffer);
			}
			
			if (fCP30 != 0.0)
			{
				Format(sBuffer, sizeof(sBuffer), "INSERT INTO `ck_checkpointsnew` (`steamid`, `mapname`, `cp`, `time`, `zonegroup`) VALUES (\"%s\", \"%s\", '30', '%f', '%d');", sSteam, sMap, fCP30, iZonegroup);
				tTransaction.AddQuery(sBuffer);
			}
			
			if (fCP31 != 0.0)
			{
				Format(sBuffer, sizeof(sBuffer), "INSERT INTO `ck_checkpointsnew` (`steamid`, `mapname`, `cp`, `time`, `zonegroup`) VALUES (\"%s\", \"%s\", '31', '%f', '%d');", sSteam, sMap, fCP31, iZonegroup);
				tTransaction.AddQuery(sBuffer);
			}
			
			if (fCP32 != 0.0)
			{
				Format(sBuffer, sizeof(sBuffer), "INSERT INTO `ck_checkpointsnew` (`steamid`, `mapname`, `cp`, `time`, `zonegroup`) VALUES (\"%s\", \"%s\", '32', '%f', '%d');", sSteam, sMap, fCP32, iZonegroup);
				tTransaction.AddQuery(sBuffer);
			}
			
			if (fCP33 != 0.0)
			{
				Format(sBuffer, sizeof(sBuffer), "INSERT INTO `ck_checkpointsnew` (`steamid`, `mapname`, `cp`, `time`, `zonegroup`) VALUES (\"%s\", \"%s\", '33', '%f', '%d');", sSteam, sMap, fCP33, iZonegroup);
				tTransaction.AddQuery(sBuffer);
			}
			
			if (fCP34 != 0.0)
			{
				Format(sBuffer, sizeof(sBuffer), "INSERT INTO `ck_checkpointsnew` (`steamid`, `mapname`, `cp`, `time`, `zonegroup`) VALUES (\"%s\", \"%s\", '34', '%f', '%d');", sSteam, sMap, fCP34, iZonegroup);
				tTransaction.AddQuery(sBuffer);
			}
			
			if (fCP35 != 0.0)
			{
				Format(sBuffer, sizeof(sBuffer), "INSERT INTO `ck_checkpointsnew` (`steamid`, `mapname`, `cp`, `time`, `zonegroup`) VALUES (\"%s\", \"%s\", '35', '%f', '%d');", sSteam, sMap, fCP35, iZonegroup);
				tTransaction.AddQuery(sBuffer);
			}
			

			g_dDb.Execute(tTransaction, SQLTxn_InsertCheckpouintsSuccess, SQLTxn_InsertCheckpouintsFailed);
		}
	}
}

public void SQLTxn_InsertCheckpouintsSuccess(Handle db, any data, int numQueries, Handle[] results, any[] queryData)
{
	g_iCounter++;

	if (g_iCounter == g_iCount)
	{
		float fTime = GetEngineTime() - g_fStart;
		PrintToServer("%fs for %d transactions with a total amount of %d queries", fTime, g_iCount, g_iCount*35);
		db_upgradeDatabase(5);
	}
}

public void SQLTxn_InsertCheckpouintsFailed(Handle db, any data, int numQueries, const char[] error, int failIndex, any[] queryData)
{
	LogMessage("[SurfTimer] Failed to insert new checkpoints... Error: %s", error);
}

public void SQLTxn_UpgradeDatabaseSuccess(Database db, int version, int numQueries, DBResultSet[] results, any[] queryData)
{
	LogMessage("surftimer | Database upgrade (Version %d) was successful", version);
	db_upgradeDatabase(version + 1);
}

public void SQLTxn_UpgradeDatabaseFailed(Database db, int version, int numQueries, const char[] error, int failIndex, any[] queryData)
{
	LogError("[SurfTimer] Database upgrade (Version: %d) failed at query %d (Error: %s)", version, queryData[failIndex], error);
}
