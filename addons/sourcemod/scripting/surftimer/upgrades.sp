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
	tTransaction.AddQuery("SELECT teleside FROM ck_spawnlocations LIMIT 1", 4);
	tTransaction.AddQuery("SELECT velEndXYZ FROM ck_checkpoints LIMIT 1", 5);
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

void db_upgradeDatabase(int version)
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
		tTransaction.AddQuery("ALTER TABLE ck_playeroptions2 ADD COLUMN teleside INT(11) NOT NULL DEFAULT 0 AFTER centrehud;", 1);
	}
	else if (version == 4)
	{
		tTransaction.AddQuery("ALTER TABLE ck_spawnlocations DROP PRIMARY KEY, ADD COLUMN teleside INT(11) NOT NULL DEFAULT 0 AFTER stage, ADD PRIMARY KEY (mapname, zonegroup, stage, teleside);", 1);
	}
	else if (version == 5)
	{
		delete tTransaction;
		LogError("Please execute the mysql upgrade script \"upgrade-checkpoints.sql\" in your \"scripts/mysql-files/upgrading\" folder. After this run this command again!");
		return;
	}
	else if (version == 6)
	{
		tTransaction.AddQuery("ALTER TABLE `ck_announcements` ADD `steamid` varchar(32) NOT NULL AFTER `server`;", 1);

		// to support older versions
		tTransaction.AddQuery("ALTER TABLE `ck_playertimes` MODIFY `velStartXY` INT NOT NULL DEFAULT 0;", 2);
		tTransaction.AddQuery("ALTER TABLE `ck_playertimes` MODIFY `velStartXYZ` INT NOT NULL DEFAULT 0;", 3);
		tTransaction.AddQuery("ALTER TABLE `ck_playertimes` MODIFY `velStartZ` INT NOT NULL DEFAULT 0;", 4);
		tTransaction.AddQuery("ALTER TABLE `ck_playertimes` MODIFY `velEndXY` INT NOT NULL DEFAULT 0;", 5);
		tTransaction.AddQuery("ALTER TABLE `ck_playertimes` MODIFY `velEndXYZ` INT NOT NULL DEFAULT 0;", 6);
		tTransaction.AddQuery("ALTER TABLE `ck_playertimes` MODIFY `velEndZ` INT NOT NULL DEFAULT 0;", 7);
		tTransaction.AddQuery("ALTER TABLE `ck_bonus` MODIFY `velStartXY` INT NOT NULL DEFAULT 0;", 8);
		tTransaction.AddQuery("ALTER TABLE `ck_bonus` MODIFY `velStartXYZ` INT NOT NULL DEFAULT 0;", 9);
		tTransaction.AddQuery("ALTER TABLE `ck_bonus` MODIFY `velStartZ` INT NOT NULL DEFAULT 0;", 10);
		tTransaction.AddQuery("ALTER TABLE `ck_bonus` MODIFY `velEndXY` INT NOT NULL DEFAULT 0;", 11);
		tTransaction.AddQuery("ALTER TABLE `ck_bonus` MODIFY `velEndXYZ` INT NOT NULL DEFAULT 0;", 12);
		tTransaction.AddQuery("ALTER TABLE `ck_bonus` MODIFY `velEndZ` INT NOT NULL DEFAULT 0;", 13);
		tTransaction.AddQuery("ALTER TABLE `ck_wrcps` MODIFY `velStartXY` INT NOT NULL DEFAULT 0;", 14);
		tTransaction.AddQuery("ALTER TABLE `ck_wrcps` MODIFY `velStartXYZ` INT NOT NULL DEFAULT 0;", 15);
		tTransaction.AddQuery("ALTER TABLE `ck_wrcps` MODIFY `velStartZ` INT NOT NULL DEFAULT 0;", 16);
		tTransaction.AddQuery("ALTER TABLE `ck_wrcps` MODIFY `velEndXY` INT NOT NULL DEFAULT 0;", 17);
		tTransaction.AddQuery("ALTER TABLE `ck_wrcps` MODIFY `velEndXYZ` INT NOT NULL DEFAULT 0;", 18);
		tTransaction.AddQuery("ALTER TABLE `ck_wrcps` MODIFY `velEndZ` INT NOT NULL DEFAULT 0;", 19);
	}
	else
	{
		LogMessage("surftimer | Database is up to date.");
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
