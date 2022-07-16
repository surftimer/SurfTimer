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
		
		if (!SQL_FastQuery(g_hDb, "SELECT steamid FROM ck_prinfo  LIMIT 1"))
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
		LogMessage("Version 8 looks good.");
	}

	SQL_UnlockDatabase(g_hDb);
}

public void db_upgradeDatabase(int ver)
{
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

	CheckDatabaseForUpdates();
}

void LoopFloatDecimalTables()
{
	for (int i = 0; i < sizeof(g_sDecimalTables); i++)
	{
		if (g_sDecimalTables[i][0][3] == 'c' && g_sDecimalTables[i][1][0] == 'c' && g_sDecimalTables[i][1][1] == 'p')
		{
			for (int j = 1; j <= 35; j++)
			{
				CheckDataType(g_sDecimalTables[i][0], g_sDecimalTables[i][1], j);
			}
		}
		else
		{
			CheckDataType(g_sDecimalTables[i][0], g_sDecimalTables[i][1]);
		}
	}
}

void CheckDataType(const char[] table, const char[] column, int cp = 0)
{
	char sColumn[32];
	if (cp > 0)
	{
		Format(sColumn, sizeof(sColumn), "%s%d", column, cp);
	}
	else
	{
		strcopy(sColumn, sizeof(sColumn), column);
	}

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
				LogToFileEx(g_szLogFile, "[surftimer] Starting to load server settings");
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
