void CheckDatabaseForUpdates()
{
	// If tables haven't been created yet.
	if (!SQL_FastQuery(g_hDb, "SELECT steamid FROM ck_playerrank LIMIT 1"))
	{
		SQL_UnlockDatabase(g_hDb);
		db_createTables();
		return;
	}
	else
	{
		// Check for db upgrades
		if (!SQL_FastQuery(g_hDb, "SELECT prespeed FROM ck_zones LIMIT 1"))
		{
			db_upgradeDatabase(0);
			return;
		}
		
		if(!SQL_FastQuery(g_hDb, "SELECT ranked FROM ck_maptier LIMIT 1") || !SQL_FastQuery(g_hDb, "SELECT style FROM ck_playerrank LIMIT 1;"))
		{
			db_upgradeDatabase(1);
			return;
		}
		
		if (!SQL_FastQuery(g_hDb, "SELECT wrcppoints FROM ck_playerrank LIMIT 1"))
		{
			db_upgradeDatabase(2);
			return;
		}
		
		if (!SQL_FastQuery(g_hDb, "SELECT teleside FROM ck_playeroptions2 LIMIT 1"))
		{
			db_upgradeDatabase(3);
			return;
		}
		
		if (!SQL_FastQuery(g_hDb, "SELECT steamid FROM ck_prinfo LIMIT 1"))
		{
			db_upgradeDatabase(4);
			return;
		}
		
		if (!SQL_FastQuery(g_hDb, "SELECT csd_update_rate FROM ck_playeroptions2 LIMIT 1"))
		{
			db_upgradeDatabase(5);
			return;
		}

		if (!SQL_FastQuery(g_hDb, "SELECT hints FROM ck_playeroptions2 LIMIT 1"))
		{
			db_upgradeDatabase(6);
			return;
		}

		if (!SQL_FastQuery(g_hDb, "SELECT timestamp FROM ck_bonus LIMIT 1"))
		{
			db_upgradeDatabase(7);
			return;
		}

		if (!SQL_FastQuery(g_hDb, "SELECT mapname FROM ck_replays LIMIT 1"))
		{
			db_upgradeDatabase(8);
			return;
		}

		if (!SQL_FastQuery(g_hDb, "SELECT prespeedmode FROM ck_playeroptions2 LIMIT 1"))
		{
			db_upgradeDatabase(9);
			return;
		}

		if (!SQL_FastQuery(g_hDb, "SELECT cp FROM ck_checkpoints LIMIT 1"))
		{
			db_upgradeDatabase(10);
			return;
		}

		if (!SQL_FastQuery(g_hDb, "SELECT countryCode FROM ck_playerrank LIMIT 1"))
		{
			db_upgradeDatabase(11);
			return;
		}

		if (!SQL_FastQuery(g_hDb, "SELECT stage_time FROM ck_checkpoints LIMIT 1"))
		{
			db_upgradeDatabase(12);
			return;
		}

		// Version 13 - Start
		char sQuery[512];
		FormatEx(sQuery, sizeof(sQuery), "SELECT CHARACTER_MAXIMUM_LENGTH FROM information_schema.COLUMNS WHERE TABLE_SCHEMA='%s' AND TABLE_NAME='ck_playertimes' AND COLUMN_NAME='name';", g_sDatabaseName);
		DBResultSet results = SQL_Query(g_hDb, sQuery);

		if (results != null && results.HasResults && results.FetchRow() && results.FetchInt(0) < 64)
		{
			db_upgradeDatabase(13, true);
			delete results;
			return;
		}
		
		// Version 13 - End

		LogMessage("Version 13 looks good.");
	}
}

void db_upgradeDatabase(int ver, bool skipErrorCheck = false)
{
	if (!skipErrorCheck)
	{
		LogUpgradeError(ver);
	}

	if (ver == 0)
	{
		// SurfTimer v2.01 -> SurfTimer v2.1
		char query[128];
		for (int i = 1; i < 11; i++)
		{
			Format(query, sizeof(query), "ALTER TABLE ck_maptier DROP COLUMN btier%i", i);
			SQL_FastQuery(g_hDb, query);
		}

		SQL_FastQuery(g_hDb, "ALTER TABLE ck_maptier ADD COLUMN maxvelocity FLOAT NOT NULL DEFAULT '3500.0';");
		SQL_FastQuery(g_hDb, "ALTER TABLE ck_maptier ADD COLUMN announcerecord INT(11) NOT NULL DEFAULT '0';");
		SQL_FastQuery(g_hDb, "ALTER TABLE ck_maptier ADD COLUMN gravityfix INT(11) NOT NULL DEFAULT '1';");
		SQL_FastQuery(g_hDb, "ALTER TABLE ck_zones ADD COLUMN `prespeed` int(64) NOT NULL DEFAULT '350';");
		SQL_FastQuery(g_hDb, "CREATE INDEX tier ON ck_maptier (mapname, tier);");
		SQL_FastQuery(g_hDb, "CREATE INDEX mapsettings ON ck_maptier (mapname, maxvelocity, announcerecord, gravityfix);");
		SQL_FastQuery(g_hDb, "UPDATE ck_maptier a, ck_mapsettings b SET a.maxvelocity = b.maxvelocity WHERE a.mapname = b.mapname;");
		SQL_FastQuery(g_hDb, "UPDATE ck_maptier a, ck_mapsettings b SET a.announcerecord = b.announcerecord WHERE a.mapname = b.mapname;");
		SQL_FastQuery(g_hDb, "UPDATE ck_maptier a, ck_mapsettings b SET a.gravityfix = b.gravityfix WHERE a.mapname = b.mapname;");
		SQL_FastQuery(g_hDb, "UPDATE ck_zones a, ck_mapsettings b SET a.prespeed = b.startprespeed WHERE a.mapname = b.mapname AND zonetype = 1;");
		SQL_FastQuery(g_hDb, "DROP TABLE ck_mapsettings;");
	}
	else if (ver == 1)
	{
	// SurfTimer v2.1 -> v2.2
		SQL_FastQuery(g_hDb, "ALTER TABLE ck_maptier ADD COLUMN ranked INT(11) NOT NULL DEFAULT '1';");
		SQL_FastQuery(g_hDb, "ALTER TABLE ck_playerrank DROP PRIMARY KEY, ADD COLUMN style INT(11) NOT NULL DEFAULT '0', ADD PRIMARY KEY (steamid, style);");
	}
	else if (ver == 2)
	{
		SQL_FastQuery(g_hDb, "ALTER TABLE ck_playerrank ADD COLUMN wrcppoints INT(11) NOT NULL DEFAULT 0 AFTER `wrbpoints`;");
	}
	else if (ver == 3)
	{
		SQL_FastQuery(g_hDb, "ALTER TABLE ck_playeroptions2 ADD COLUMN teleside INT(11) NOT NULL DEFAULT 0 AFTER centrehud;");
		SQL_FastQuery(g_hDb, "ALTER TABLE ck_spawnlocations DROP PRIMARY KEY, ADD COLUMN teleside INT(11) NOT NULL DEFAULT 0 AFTER stage, ADD PRIMARY KEY (mapname, zonegroup, stage, teleside);");
	}
	else if (ver == 4)
	{
		SQL_FastQuery(g_hDb, sql_CreatePrinfo);
	}
	else if (ver == 5)
	{
		SQL_FastQuery(g_hDb, "ALTER TABLE ck_playeroptions2 ADD csd_update_rate int(11) NOT NULL DEFAULT '1', ADD csd_pos_x float(11) NOT NULL DEFAULT '0.5', ADD csd_pos_y float(11) NOT NULL DEFAULT '0.3', ADD csd_r int(11) NOT NULL DEFAULT '255', ADD csd_g int(11) NOT NULL DEFAULT '255', ADD csd_b int(11) NOT NULL DEFAULT '255';");
	}
	else if (ver == 6)
	{
		SQL_FastQuery(g_hDb, "ALTER TABLE ck_playeroptions2 ADD hints int(11) NOT NULL DEFAULT '1';");
	}
	else if (ver == 7)
	{
		SQL_FastQuery(g_hDb, "ALTER TABLE `ck_bonus` ADD `timestamp` TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP;");
		SQL_FastQuery(g_hDb, "ALTER TABLE `ck_playertimes` ADD `timestamp` TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP;");
		SQL_FastQuery(g_hDb, "ALTER TABLE `ck_wrcps` ADD `timestamp` TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP;");
	}
	else if (ver == 8)
	{
		SQL_FastQuery(g_hDb, sql_createReplays);
	}
	else if (ver == 9)
	{
		SQL_FastQuery(g_hDb, "ALTER TABLE ck_playeroptions2 ADD prespeedmode int(11) NOT NULL DEFAULT '1';");
	}
	else if (ver == 10)
	{
	//ALREADY CONVERTED
		char sQuery[512];
		Format(sQuery, sizeof(sQuery), sql_checkDataType, g_sDatabaseName, "ck_checkpoints", "cp1");
		if(SQL_FastQuery(g_hDb_Updates, sql_checkDataType)){
			SQL_FastQuery(g_hDb_Updates, "CREATE TABLE IF NOT EXISTS `ck_checkpointsnew` (`steamid` varchar(32) NOT NULL, `mapname` varchar(32) NOT NULL, `cp` int(11) NOT NULL DEFAULT '0', `time` decimal(12, 6) NOT NULL DEFAULT '0.000000', `zonegroup` int(12) NOT NULL DEFAULT '0.0', PRIMARY KEY (`steamid`,`mapname`,`cp`,`zonegroup`)) DEFAULT CHARSET=utf8mb4;");
			SQL_FastQuery(g_hDb_Updates, "REPLACE INTO ck_checkpointsnew (steamid, mapname, cp, time, zonegroup) SELECT * FROM ( SELECT steamid, mapname, 1 AS cp, cp1 AS time, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 2 AS cp, cp2, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 3 AS cp, cp3, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 4 AS cp, cp4, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 5 AS cp, cp5, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 6 AS cp, cp6, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 7 AS cp, cp7, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 8 AS cp, cp8, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 9 AS cp, cp9, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 10 AS cp, cp10, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 11 AS cp, cp11, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 12 AS cp, cp12, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 13 AS cp, cp13, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 14 AS cp, cp14, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 15 AS cp, cp15, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 16 AS cp, cp16, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 17 AS cp, cp17, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 18 AS cp, cp18, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 19 AS cp, cp19, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 20 AS cp, cp20, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 21 AS cp, cp21, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 22 AS cp, cp22, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 23 AS cp, cp23, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 24 AS cp, cp24, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 25 AS cp, cp25, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 26 AS cp, cp26, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 27 AS cp, cp27, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 28 AS cp, cp28, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 29 AS cp, cp29, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 30 AS cp, cp30, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 31 AS cp, cp31, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 32 AS cp, cp32, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 33 AS cp, cp33, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 34 AS cp, cp34, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 35 AS cp, cp35, zonegroup FROM ck_checkpoints) v HAVING time > 0;");
			SQL_FastQuery(g_hDb_Updates, "ALTER TABLE ck_checkpoints RENAME TO ck_checkpointsold;");
			SQL_FastQuery(g_hDb_Updates, "ALTER TABLE ck_checkpointsnew RENAME TO ck_checkpoints;");
		}
		//NOT CONVERTED
		else{
			SQL_FastQuery(g_hDb_Updates, "CREATE TABLE IF NOT EXISTS `ck_checkpointsnew` (`steamid` varchar(32) NOT NULL, `mapname` varchar(32) NOT NULL, `cp` int(11) NOT NULL DEFAULT '0', `time` FLOAT NOT NULL DEFAULT '0.0', `zonegroup` int(12) NOT NULL DEFAULT '0.0', PRIMARY KEY (`steamid`,`mapname`,`cp`,`zonegroup`)) DEFAULT CHARSET=utf8mb4;");
			SQL_FastQuery(g_hDb_Updates, "REPLACE INTO ck_checkpointsnew (steamid, mapname, cp, time, zonegroup) SELECT * FROM ( SELECT steamid, mapname, 1 AS cp, cp1 AS time, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 2 AS cp, cp2, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 3 AS cp, cp3, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 4 AS cp, cp4, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 5 AS cp, cp5, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 6 AS cp, cp6, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 7 AS cp, cp7, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 8 AS cp, cp8, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 9 AS cp, cp9, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 10 AS cp, cp10, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 11 AS cp, cp11, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 12 AS cp, cp12, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 13 AS cp, cp13, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 14 AS cp, cp14, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 15 AS cp, cp15, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 16 AS cp, cp16, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 17 AS cp, cp17, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 18 AS cp, cp18, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 19 AS cp, cp19, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 20 AS cp, cp20, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 21 AS cp, cp21, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 22 AS cp, cp22, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 23 AS cp, cp23, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 24 AS cp, cp24, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 25 AS cp, cp25, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 26 AS cp, cp26, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 27 AS cp, cp27, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 28 AS cp, cp28, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 29 AS cp, cp29, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 30 AS cp, cp30, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 31 AS cp, cp31, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 32 AS cp, cp32, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 33 AS cp, cp33, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 34 AS cp, cp34, zonegroup FROM ck_checkpoints UNION ALL SELECT steamid, mapname, 35 AS cp, cp35, zonegroup FROM ck_checkpoints) v HAVING time > 0;");
			SQL_FastQuery(g_hDb_Updates, "ALTER TABLE ck_checkpoints RENAME TO ck_checkpointsold;");
			SQL_FastQuery(g_hDb_Updates, "ALTER TABLE ck_checkpointsnew RENAME TO ck_checkpoints;");
		}
	}
	else if (ver == 11)
	{
		SQL_FastQuery(g_hDb, "ALTER TABLE ck_playerrank ADD COLUMN countryCode varchar(3) DEFAULT NULL AFTER `country`;");
		SQL_FastQuery(g_hDb, "ALTER TABLE ck_playerrank ADD COLUMN continentCode varchar(3) DEFAULT NULL AFTER `countryCode`;");
	}
	else if (ver == 12)
	{
		SQL_FastQuery(g_hDb, "ALTER TABLE ck_checkpoints ADD stage_time decimal(12, 6) NOT NULL DEFAULT '-1.000000', ADD stage_attempts INT NOT NULL DEFAULT '0';");
	}
	else if (ver == 13)
	{
		SQL_FastQuery(g_hDb, "ALTER TABLE ck_announcements MODIFY name VARCHAR(64);");
		SQL_FastQuery(g_hDb, "ALTER TABLE ck_bonus MODIFY name VARCHAR(64);");
		SQL_FastQuery(g_hDb, "ALTER TABLE ck_latestrecords MODIFY name VARCHAR(64);");
		SQL_FastQuery(g_hDb, "ALTER TABLE ck_playerrank MODIFY name VARCHAR(64);");
		SQL_FastQuery(g_hDb, "ALTER TABLE ck_playertimes MODIFY name VARCHAR(64);");
		SQL_FastQuery(g_hDb, "ALTER TABLE ck_wrcps MODIFY name VARCHAR(64);");
		SQL_FastQuery(g_hDb, "ALTER TABLE ck_prinfo MODIFY name VARCHAR(64);");
	}

	CheckDatabaseForUpdates();
}

void LogUpgradeError(int version)
{
	char sError[256];
	SQL_GetError(g_hDb, sError, sizeof(sError));

	LogMessage("SQL Error for Version %d. Error: %s", version, sError);
}

void LoopFloatDecimalTables()
{
	for (int i = 0; i < sizeof(g_sDecimalTables); i++)
	{
		CheckDataType(g_sDecimalTables[i][0], g_sDecimalTables[i][1]);
	}
}

void CheckDataType(const char[] table, const char[] column)
{
	char sColumn[32];
	strcopy(sColumn, sizeof(sColumn), column);

	char sQuery[512];
	Format(sQuery, sizeof(sQuery), "SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE, NUMERIC_PRECISION, NUMERIC_SCALE FROM information_schema.COLUMNS WHERE TABLE_SCHEMA='%s' AND TABLE_NAME='%s' AND COLUMN_NAME='%s';", g_sDatabaseName, table, sColumn);
	DataPack pack = new DataPack();
	pack.WriteString(table);
	pack.WriteString(sColumn);

	SQL_TQuery(g_hDb_Updates, SQLCheckDataType, sQuery, pack);
}

public void SQLCheckDataType(Handle owner, Handle hndl, const char[] error, DataPack pack)
{
	if (owner == null || strlen(error) > 0)
	{
		SetFailState("Nope. Line: %d, Error: %s", __LINE__, error);
		delete pack;
		return;
	}

	char sTable[32];
	char sColumn[32];

	if (SQL_GetRowCount(hndl) != 1)
	{
		pack.Reset();
		pack.ReadString(sTable, sizeof(sTable));
		pack.ReadString(sColumn, sizeof(sColumn));
		SetFailState("More/Less then 1 rows? RowCount: %d, Table: %s, Column: %s", SQL_GetRowCount(hndl), sTable, sColumn);
		delete pack;
		return;
	}

	while (SQL_FetchRow(hndl))
	{
		SQL_FetchString(hndl, 0, sTable, sizeof(sTable));
		SQL_FetchString(hndl, 1, sColumn, sizeof(sColumn));

		char sDataType[12];
		SQL_FetchString(hndl, 2, sDataType, sizeof(sDataType));


		int iPrecision = 0;
		if (!SQL_IsFieldNull(hndl, 3))
		{
			iPrecision = SQL_FetchInt(hndl, 3);
		}

		int iScale = 0;
		if (!SQL_IsFieldNull(hndl, 4))
		{
			iScale = SQL_FetchInt(hndl, 4);
		}

		if (sDataType[0] == 'f' && sDataType[1] == 'l')
		{
			ConvertDataTypeToDecimal(sTable, sColumn, 10, 4);
		}
		else if (sDataType[0] == 'd' && iPrecision != 12 && iScale != 6)
		{
			ConvertDataTypeToDecimal(sTable, sColumn, 12, 6);
		}
		else if (sDataType[0] != 'd' && iPrecision != 12 && iScale != 6)
		{
			LogError("Unsupported table, column and datatype combination. Please open up an issue. Table: %s, Column: %s, DataType: %s, Precision: %d, Scale: %d", sTable, sColumn, sDataType, iPrecision, iScale);
		}
		else if (sDataType[0] == 'd' && iPrecision == 12 && iScale == 6 && (strcmp(g_sDecimalTables[sizeof(g_sDecimalTables)-1][0], sTable) == 0) && !g_tables_converted){
			g_tables_converted = true;

			/// Start Loading Server Settings
			ConVar cvHibernateWhenEmpty = FindConVar("sv_hibernate_when_empty");

			if (!g_bRenaming && !g_bInTransactionChain && (IsServerProcessing() || !cvHibernateWhenEmpty.BoolValue))
			{
				LogQueryTime("[surftimer] Starting to load server settings");
				g_fServerLoading[0] = GetGameTime();
				db_selectMapZones();
			}
		}
	}

	delete pack;
}

void ConvertDataTypeToDecimal(const char[] table, const char[] column, int precision, int scale)
{
	PrintToServer("Converting %s-%s to decimal(%d, %d)...", table, column, precision, scale);
	
	char sQuery[128];
	Format(sQuery, sizeof(sQuery), "ALTER TABLE %s MODIFY %s DECIMAL(%d, %d);", table, column, precision, scale);

	DataPack pack = new DataPack();
	pack.WriteString(table);
	pack.WriteString(column);

	SQL_TQuery(g_hDb_Updates, SQLChangeDataType, sQuery, pack);
}

public void SQLChangeDataType(Handle owner, Handle hndl, const char[] error, DataPack pack)
{
	pack.Reset();

	char sTable[32];
	pack.ReadString(sTable, sizeof(sTable));

	char sColumn[32];
	pack.ReadString(sColumn, sizeof(sColumn));

	delete pack;

	if (owner == null || strlen(error) > 0)
	{
		SetFailState("Nope. Line: %d, Table: %s, Column: %s, Error: %s", __LINE__, sTable, sColumn, error);
		return;
	}

	CheckDataType(sTable, sColumn);
}
