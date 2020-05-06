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
	tTransaction.AddQuery("SELECT teleside FROM ck_playeroptions LIMIT 1", 3);
	tTransaction.AddQuery("SELECT velEndXYZ FROM ck_checkpoints LIMIT 1", 4);
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
		tTransaction.AddQuery("CREATE TABLE `ck_checkpointsnew`( `steamid` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL, `mapname` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL, `cp` int(11) NOT NULL, `time` float NOT NULL, `velStartXY` int(11) NOT NULL, `velStartXYZ` int(11) NOT NULL, `velStartZ` int(11) NOT NULL, `velEndXY` int(11) NOT NULL, `velEndXYZ` int(11) NOT NULL, `velEndZ` int(11) NOT NULL, `velAvgXY` int(11) NOT NULL, `velAvgXYZ` int(11) NOT NULL, `velAvgZ` int(11) NOT NULL, `zonegroup` int(12) NOT NULL, PRIMARY KEY (`steamid`,`mapname`,`cp`,`zonegroup`));", 1);
		tTransaction.AddQuery("REPLACE INTO ck_checkpointsnew (steamid, mapname, cp, time, zonegroup) SELECT * FROM ( SELECT steamid, mapname, 1 AS cp, cp1 AS time, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 2 AS cp, cp2, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 3 AS cp, cp3, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 4 AS cp, cp4, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 5 AS cp, cp5, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 6 AS cp, cp6, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 7 AS cp, cp7, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 8 AS cp, cp8, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 9 AS cp, cp9, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 10 AS cp, cp10, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 11 AS cp, cp11, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 12 AS cp, cp12, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 13 AS cp, cp13, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 14 AS cp, cp14, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 15 AS cp, cp15, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 16 AS cp, cp16, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 17 AS cp, cp17, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 18 AS cp, cp18, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 19 AS cp, cp19, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 20 AS cp, cp20, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 21 AS cp, cp21, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 22 AS cp, cp22, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 23 AS cp, cp23, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 24 AS cp, cp24, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 25 AS cp, cp25, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 26 AS cp, cp26, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 27 AS cp, cp27, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 28 AS cp, cp28, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 29 AS cp, cp29, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 30 AS cp, cp30, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 31 AS cp, cp31, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 32 AS cp, cp32, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 33 AS cp, cp33, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 34 AS cp, cp34, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 35 AS cp, cp35, zonegroup FROM ck_checkpoints );", 2);
		tTransaction.AddQuery("ALTER TABLE ck_checkpoints RENAME TO ck_checkpointsold;", 3);
		tTransaction.AddQuery("ALTER TABLE ck_checkpointsnew RENAME TO ck_checkpoints;", 4);
		tTransaction.AddQuery("ALTER TABLE `ck_playertimes` ADD `velStartXY` INT NOT NULL AFTER `runtimepro`, ADD `velStartXYZ` INT NOT NULL AFTER `velStartXY`, ADD `velStartZ` INT NOT NULL AFTER `velStartXYZ`, ADD `velEndXY` INT NOT NULL AFTER `velStartZ`, ADD `velEndXYZ` INT NOT NULL AFTER `velEndXY`, ADD `velEndZ` INT NOT NULL AFTER `velEndXYZ`;", 5);
		tTransaction.AddQuery("ALTER TABLE `ck_bonus` ADD `velStartXY` INT NOT NULL AFTER `runtime`, ADD `velStartXYZ` INT NOT NULL AFTER `velStartXY`, ADD `velStartZ` INT NOT NULL AFTER `velStartXYZ`, ADD `velEndXY` INT NOT NULL AFTER `velStartZ`, ADD `velEndXYZ` INT NOT NULL AFTER `velEndXY`, ADD `velEndZ` INT NOT NULL AFTER `velEndXYZ`;", 6);
		tTransaction.AddQuery("ALTER TABLE `ck_wrcps` ADD `velStartXY` INT NOT NULL AFTER `runtimepro`, ADD `velStartXYZ` INT NOT NULL AFTER `velStartXY`, ADD `velStartZ` INT NOT NULL AFTER `velStartXYZ`, ADD `velEndXY` INT NOT NULL AFTER `velStartZ`, ADD `velEndXYZ` INT NOT NULL AFTER `velEndXY`, ADD `velEndZ` INT NOT NULL AFTER `velEndXYZ`;", 7);
		tTransaction.AddQuery("ALTER TABLE `ck_playeroptions2` ADD `velcmphud` INT NOT NULL DEFAULT 1 AFTER `teleside`, ADD `velcmpchat` INT NOT NULL DEFAULT 1 AFTER `velcmphud`;", 8);
	}
	else
	{
		delete tTransaction;
		return;
	}

	g_dDb.Execute(tTransaction, SQLTxn_UpgradeDatabaseSuccess, SQLTxn_UpgradeDatabaseFailed, version);
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
