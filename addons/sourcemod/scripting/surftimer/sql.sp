/*==================================
=          DATABASE SETUP          =
==================================*/

public void db_setupDatabase()
{
	/*===================================
	=    INIT CONNECTION TO DATABASE    =
	===================================*/
	char szError[255];
	g_hDb = SQL_Connect("surftimer", false, szError, 255);
	g_hDb_Updates = SQL_Connect("surftimer", false, szError, 255);

	if (g_hDb == null)
	{
		SetFailState("[SurfTimer] Unable to connect to database (%s)", szError);
		return;
	}

	char szIdent[8];
	SQL_ReadDriver(g_hDb, szIdent, 8);

	if (strcmp(szIdent, "mysql", false) == 0)
	{
		// https://github.com/nikooo777/ckSurf/pull/58
		SQL_LockDatabase(g_hDb);
		SQL_FastQuery(g_hDb, "SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));");
		SQL_UnlockDatabase(g_hDb);
		g_DbType = MYSQL;
	}
	else if (strcmp(szIdent, "sqlite", false) == 0)
	{
		SetFailState("[SurfTimer] Sorry SQLite is not supported.");
		return;
	}
	else
	{
		SetFailState("[SurfTimer] Invalid database type");
		return;
	}

	// If updating from a previous version
	SQL_LockDatabase(g_hDb);
	SQL_FastQuery(g_hDb, "SET NAMES 'utf8mb4'");

	// Check if tables need to be Created or database needs to be upgraded
	g_bRenaming = false;
	g_bInTransactionChain = false;

	GetDatabaseName(g_sDatabaseName, sizeof(g_sDatabaseName));
	CheckDatabaseForUpdates();

	SQL_UnlockDatabase(g_hDb);
	SQL_UnlockDatabase(g_hDb_Updates);
	LoopFloatDecimalTables();

	for (int i = 0; i < sizeof(g_failedTransactions); i++)
		g_failedTransactions[i] = 0;
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

	char sBuffer[1024];
	FormatEx(sBuffer, sizeof(sBuffer), sql_createZones, g_hDefaultPreSpeed.FloatValue);
	SQL_AddQuery(createTableTnx, sBuffer);

	SQL_AddQuery(createTableTnx, sql_createMapTier);
	SQL_AddQuery(createTableTnx, sql_createSpawnLocations);
	SQL_AddQuery(createTableTnx, sql_createAnnouncements);
	SQL_AddQuery(createTableTnx, sql_createVipAdmins);
	SQL_AddQuery(createTableTnx, sql_createWrcps);
	SQL_AddQuery(createTableTnx, sql_CreatePrinfo);

	SQL_ExecuteTransaction(g_hDb, createTableTnx, SQLTxn_CreateDatabaseSuccess, SQLTxn_CreateDatabaseFailed);

}

public void SQLTxn_CreateDatabaseSuccess(Handle db, any data, int numQueries, Handle[] results, any[] queryData)
{
	PrintToServer("[SurfTimer] Database tables succesfully created!");
}

public void SQLTxn_CreateDatabaseFailed(Handle db, any data, int numQueries, const char[] error, int failIndex, any[] queryData)
{
	SetFailState("[SurfTimer] Database tables could not be created! Error: %s", error);
}

/* Admin Delete Menu */

public void sql_DeleteMenuView(Handle owner, Handle hndl, const char[] error, any data)
{
	int client = GetClientFromSerial(data);
	
	Menu editing = new Menu(callback_DeleteRecord);
	editing.SetTitle("%s Records Editing Menu - %s\n► Editing %s record\n► Press the menu item to delete the record\n ", g_szMenuPrefix, g_EditingMap[client], g_EditTypes[g_SelectedEditOption[client]]);
	
	char menuFormat[88];
	FormatEx(menuFormat, sizeof(menuFormat), "Style: %s\n► Press the menu item to change the style\n ", g_EditStyles[g_SelectedStyle[client]]);
	editing.AddItem("0", menuFormat);
	
	if(g_SelectedEditOption[client] > 0)
	{
		FormatEx(menuFormat, sizeof(menuFormat), "%s: %i\n► Press the menu item to change the %s\n ", g_SelectedEditOption[client] == 1 ? "Stage":"Bonus", g_SelectedType[client], g_SelectedEditOption[client] == 1 ? "stage":"bonus");
		editing.AddItem("0", menuFormat);
	}
	
	if (hndl == INVALID_HANDLE)
	{
		PrintToServer("Error %s", error);
	}
	else if (!SQL_GetRowCount(hndl))
	{
		editing.AddItem("1", "No records found", ITEMDRAW_DISABLED);
		editing.Display(client, MENU_TIME_FOREVER);
	}
	else
	{
		char playerName[32], steamID[32];
		float runTime;
		char menuFormatz[128];
		int i = 0;
		while (SQL_FetchRow(hndl))
		{
			i++;
			SQL_FetchString(hndl, 0, steamID, 32);
			SQL_FetchString(hndl, 1, playerName, 32);
			runTime = SQL_FetchFloat(hndl, 2);
			char szRunTime[128];
			FormatTimeFloat(data, runTime, 3, szRunTime, sizeof(szRunTime));
			FormatEx(menuFormat, sizeof(menuFormat), "Rank: %d ► %s - %s", i, playerName, szRunTime);
			ReplaceString(playerName, 32, ";;;", ""); // make sure the client dont has this in their name.
			
			FormatEx(menuFormatz, 128, "%s;;;%s;;;%s", playerName, steamID, szRunTime);
			editing.AddItem(menuFormatz, menuFormat);
		}
		editing.Display(client, MENU_TIME_FOREVER);
	}
}

public int callback_DeleteRecord(Menu menu, MenuAction action, int client, int key)
{
	if(action == MenuAction_Select)
	{
		if(key == 0)
		{
			if(g_SelectedStyle[client] < MAX_STYLES - 1)
				g_SelectedStyle[client]++;
			else
				g_SelectedStyle[client] = 0;
			
			char szQuery[512];
			
			switch(g_SelectedEditOption[client])
			{
				case 0:
				{
					FormatEx(szQuery, 512, sql_MainEditQuery, "runtimepro", "ck_playertimes", g_EditingMap[client], g_SelectedStyle[client], "", "runtimepro");
				}
				case 1:
				{
					char stageQuery[32];
					FormatEx(stageQuery, 32, "AND stage='%i' ", g_SelectedType[client]);
					FormatEx(szQuery, 512, sql_MainEditQuery, "runtimepro", "ck_wrcps", g_EditingMap[client], g_SelectedStyle[client], stageQuery, "runtimepro");
				}
				case 2:
				{
					char stageQuery[32];
					FormatEx(stageQuery, 32, "AND zonegroup='%i' ", g_SelectedType[client]);
					FormatEx(szQuery, 512, sql_MainEditQuery, "runtime", "ck_bonus", g_EditingMap[client], g_SelectedStyle[client], stageQuery, "runtime");
				}
			}

			SQL_TQuery(g_hDb, sql_DeleteMenuView, szQuery, GetClientSerial(client));
			return 0;
		}
	
		if(g_SelectedEditOption[client] > 0 && key == 1)
		{
			g_iWaitingForResponse[client] = ClientEdit;
			CPrintToChat(client, "%t", "DeleteRecordsNewValue", g_szChatPrefix);
			return 0;
		}
	
		
		char menuItem[128];
		menu.GetItem(key, menuItem, 128);
		
		char recordsBreak[3][32];
		ExplodeString(menuItem, ";;;", recordsBreak, sizeof(recordsBreak), sizeof(recordsBreak[]));
		
		Menu confirm = new Menu(callback_Confirm);

		confirm.SetTitle("%s Records Editing Menu - Confirm Deletion\n► Deleting %s [%s] %s record\n ", g_szMenuPrefix, recordsBreak[0], recordsBreak[1], recordsBreak[2]);

		confirm.AddItem("0", "No");
		confirm.AddItem(recordsBreak[1], "Yes\n \n► This cannot be undone");

		if (GetConVarBool(g_drDeleteSecurity))
			confirm.Display(client, MENU_TIME_FOREVER);
		else
			callback_Confirm(confirm, MenuAction_Select, client, 1);

		return 0;
	}
	else if (action == MenuAction_Cancel)
	{
		if (key == MenuCancel_Exit)
			ShowMainDeleteMenu(client);
	}
	else if(action == MenuAction_End)
		delete menu;
		
	return 0;
}

public int callback_Confirm(Menu menu, MenuAction action, int client, int key)
{
	if(action == MenuAction_Select)
	{
		if(key == 1)
		{
			char steamID[32];
			menu.GetItem(key, steamID, 32);
			
			char szQuery[512];
			
			switch(g_SelectedEditOption[client])
			{
				case 0:
				{
					FormatEx(szQuery, sizeof(szQuery), sql_MainDeleteQeury, "ck_playertimes", g_EditingMap[client], g_SelectedStyle[client], steamID, "");
				}
				case 1:
				{
					char stageQuery[32];
					FormatEx(stageQuery, sizeof(stageQuery), "AND stage='%i'", g_SelectedType[client]);
					FormatEx(szQuery, sizeof(szQuery), sql_MainDeleteQeury, "ck_wrcps", g_EditingMap[client], g_SelectedStyle[client], steamID, stageQuery);
				}
				case 2:
				{
					char zoneQuery[32];
					FormatEx(zoneQuery, sizeof(zoneQuery), "AND zonegroup='%i'", g_SelectedType[client]);
					FormatEx(szQuery, sizeof(szQuery), sql_MainDeleteQeury, "ck_bonus", g_EditingMap[client], g_SelectedStyle[client], steamID, zoneQuery);
					
					char BonusPRruntime[512];
					Format(BonusPRruntime, sizeof(BonusPRruntime), sql_clearPRruntime, steamID, g_EditingMap[client], g_SelectedType[client]);
					SQL_TQuery(g_hDb, SQL_CheckCallback, BonusPRruntime, .prio=DBPrio_Low);
				}
			}
			SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, .prio=DBPrio_Low);
			
			// Looking for online player to refresh his record after deleting it.
			char player_steamID[32];
			for(int i=1; i <= MaxClients; i++)
			{
				if (!IsValidClient(i) || IsFakeClient(client))
					continue;
					
				GetClientAuthId(i, AuthId_Steam2, player_steamID, 32, true);
				if(StrEqual(player_steamID,steamID))
				{
					g_bSettingsLoaded[client] = false;
					g_bLoadingSettings[client] = true;
					g_iSettingToLoad[client] = 0;
					LoadClientSetting(client, g_iSettingToLoad[client]);
					break;
				}
			}
			
			db_GetMapRecord_Pro();
			
			CPrintToChat(client, "%t", "DeleteRecordsDeletion", g_szChatPrefix);
			ShowMainDeleteMenu(client);
		}

	}
	else if(action == MenuAction_End)
		delete menu;

	return 0;
}

public void db_WipePlayer(int client, char szSteamID[32])
{
	Transaction tTransaction = new Transaction();
	char szQuery[256];

	Format(szQuery, sizeof(szQuery), "DELETE FROM ck_playertimes WHERE steamid = \"%s\";", szSteamID);
	tTransaction.AddQuery(szQuery, 1);
	Format(szQuery, sizeof(szQuery), "DELETE FROM ck_bonus WHERE steamid = \"%s\";", szSteamID);
	tTransaction.AddQuery(szQuery, 2);
	Format(szQuery, sizeof(szQuery), "DELETE FROM ck_checkpoints WHERE steamid = \"%s\";", szSteamID);
	tTransaction.AddQuery(szQuery, 3);
	Format(szQuery, sizeof(szQuery), "DELETE FROM ck_playerrank WHERE steamid = \"%s\";", szSteamID);
	tTransaction.AddQuery(szQuery, 4);
	Format(szQuery, sizeof(szQuery), "DELETE FROM ck_wrcps WHERE steamid = \"%s\";", szSteamID);
	tTransaction.AddQuery(szQuery, 5);
	Format(szQuery, sizeof(szQuery), "DELETE FROM ck_playeroptions2 WHERE steamid = \"%s\";", szSteamID);
	tTransaction.AddQuery(szQuery, 6);
	Format(szQuery, sizeof(szQuery), "DELETE FROM ck_latestrecords WHERE steamid = \"%s\";", szSteamID);
	tTransaction.AddQuery(szQuery, 7);
	Format(szQuery, sizeof(szQuery), "DELETE FROM ck_playertemp WHERE steamid = \"%s\";", szSteamID);
	tTransaction.AddQuery(szQuery, 8);

	DataPack pack = new DataPack();
	pack.WriteCell(GetClientUserId(client));
	pack.WriteString(szSteamID);
	SQL_ExecuteTransaction(g_hDb ,tTransaction, SQLTxn_WipePlayerSuccess, SQLTxn_WipePlayerFailed, pack, DBPrio_High);
}

public void SQLTxn_WipePlayerSuccess(Handle db, DataPack pack, int numQueries, Handle[] results, any[] queryData)
{
	pack.Reset();

	int client = GetClientOfUserId(pack.ReadCell());

	char szSteamID[32];
	pack.ReadString(szSteamID, sizeof(szSteamID));

	delete pack;


	if (IsValidClient(client))
	{
		PrintToChat(client, "Player %s has been wiped!", szSteamID);
		PrintToConsole(client, "Player %s has been wiped!", szSteamID);
	}

	char sBuffer[32];

	for(int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		GetClientAuthId(i, AuthId_Steam2, sBuffer, sizeof(sBuffer));
		if (StrEqual(sBuffer, szSteamID, false))
		{
			g_bSettingsLoaded[client] = false;
			g_bLoadingSettings[client] = true;
			g_iSettingToLoad[client] = 0;
			LoadClientSetting(client, g_iSettingToLoad[client]);
			break;
		}
	}
}

public void SQLTxn_WipePlayerFailed(Handle db, DataPack pack, int numQueries, const char[] error, int failIndex, any[] queryData)
{
	pack.Reset();

	int client = GetClientOfUserId(pack.ReadCell());

	char szSteamID[32];
	pack.ReadString(szSteamID, sizeof(szSteamID));

	delete pack;


	LogError("[SurfTimer] Wipe of player %s failed! Error (Query: %d): %s", szSteamID, queryData[failIndex], error);

	if (IsValidClient(client))
	{
		PrintToChat(client, "[SurfTimer] Wipe of player %s failed! Error (Query: %d): %s", szSteamID, queryData[failIndex], error);
		PrintToConsole(client, "[SurfTimer] Wipe of player %s failed! Error (Query: %d): %s", szSteamID, queryData[failIndex], error);
	}
}

/*==================================
=          SPAWN LOCATION          =
==================================*/

public void db_deleteSpawnLocations(int zGrp, int teleside)
{
	g_bGotSpawnLocation[zGrp][1][teleside] = false;
	char szQuery[128];
	Format(szQuery, sizeof(szQuery), sql_deleteSpawnLocations, g_szMapName, zGrp, teleside);
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, _, DBPrio_Low);
}


public void db_updateSpawnLocations(float position[3], float angle[3], float vel[3], int zGrp, int teleside)
{
	char szQuery[512];
	Format(szQuery, 512, sql_updateSpawnLocations, position[0], position[1], position[2], angle[0], angle[1], angle[2], vel[0], vel[1], vel[2], g_szMapName, zGrp, teleside);
	SQL_TQuery(g_hDb, db_editSpawnLocationsCallback, szQuery, zGrp, DBPrio_Low);
}

public void db_insertSpawnLocations(float position[3], float angle[3], float vel[3], int zGrp, int teleside)
{
	char szQuery[512];
	Format(szQuery, 512, sql_insertSpawnLocations, g_szMapName, position[0], position[1], position[2], angle[0], angle[1], angle[2], vel[0], vel[1], vel[2], zGrp, teleside);
	SQL_TQuery(g_hDb, db_editSpawnLocationsCallback, szQuery, zGrp, DBPrio_Low);
}

public void db_editSpawnLocationsCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (db_editSpawnLocationsCallback): %s ", error);
		return;
	}
	db_selectSpawnLocations();
}

public void db_selectSpawnLocations()
{
	for (int s = 0; s < CPLIMIT; s++)
	{
		for (int i = 0; i < MAXZONEGROUPS; i++)
		{
			g_bGotSpawnLocation[i][s][0] = false;
			g_bGotSpawnLocation[i][s][1] = false;
		}
	}

	char szQuery[254];
	Format(szQuery, 254, sql_selectSpawnLocations, g_szMapName);
	SQL_TQuery(g_hDb, db_selectSpawnLocationsCallback, szQuery, GetGameTime(), DBPrio_Low);
}

public void db_selectSpawnLocationsCallback(Handle owner, Handle hndl, const char[] error, float time)
{
	LogQueryTime("[SurfTimer] : Finished db_selectSpawnLocationsCallback in: %f", GetGameTime() - time);
	
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (db_selectSpawnLocationsCallback): %s ", error);
		if (!g_bServerDataLoaded)
			db_GetDynamicTimelimit();
		return;
	}

	if (SQL_HasResultSet(hndl))
	{
		while (SQL_FetchRow(hndl))
		{
			int zonegroup = SQL_FetchInt(hndl, 10);
			int stage = SQL_FetchInt(hndl, 11);
			int teleside = SQL_FetchInt(hndl, 12);

			g_bGotSpawnLocation[zonegroup][stage][teleside] = true;
			g_fSpawnLocation[zonegroup][stage][teleside][0] = SQL_FetchFloat(hndl, 1);
			g_fSpawnLocation[zonegroup][stage][teleside][1] = SQL_FetchFloat(hndl, 2);
			g_fSpawnLocation[zonegroup][stage][teleside][2] = SQL_FetchFloat(hndl, 3);
			g_fSpawnAngle[zonegroup][stage][teleside][0] = SQL_FetchFloat(hndl, 4);
			g_fSpawnAngle[zonegroup][stage][teleside][1] = SQL_FetchFloat(hndl, 5);
			g_fSpawnAngle[zonegroup][stage][teleside][2] = SQL_FetchFloat(hndl, 6);
			g_fSpawnVelocity[zonegroup][stage][teleside][0] = SQL_FetchFloat(hndl, 7);
			g_fSpawnVelocity[zonegroup][stage][teleside][1] = SQL_FetchFloat(hndl, 8);
			g_fSpawnVelocity[zonegroup][stage][teleside][2] = SQL_FetchFloat(hndl, 9);
		}
	}

	if (!g_bServerDataLoaded)
		db_GetDynamicTimelimit();
}

/*===================================
=            PLAYER RANK            =
===================================*/

public void db_viewMapProRankCount()
{
	g_MapTimesCount = 0;
	char szQuery[512];
	Format(szQuery, 512, sql_selectPlayerProCount, g_szMapName);
	SQL_TQuery(g_hDb, sql_selectPlayerProCountCallback, szQuery, GetGameTime(), DBPrio_Low);
}

public void sql_selectPlayerProCountCallback(Handle owner, Handle hndl, const char[] error, float time)
{
	LogQueryTime("[SurfTimer] : Finished sql_selectPlayerProCountCallback in: %f", GetGameTime() - time);
	
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (sql_selectPlayerProCountCallback): %s", error);
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

// Get players rank in current map
public void db_viewMapRankPro(int client)
{
	char szQuery[512];
	if (!IsValidClient(client))
	return;

	// "SELECT COUNT(*) FROM ck_playertimes WHERE runtimepro <= (SELECT runtimepro FROM ck_playertimes WHERE steamid = '%s' AND mapname = '%s' AND runtimepro > -1.0) AND mapname = '%s' AND runtimepro > -1.0";
	Format(szQuery, 512, sql_selectPlayerRankProTime, g_szSteamID[client], g_szMapName, g_szMapName);
	SQL_TQuery(g_hDb, db_viewMapRankProCallback, szQuery, client, DBPrio_Low);
}

public void db_viewMapRankProCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (db_viewMapRankProCallback): %s ", error);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		g_MapRank[client] = SQL_FetchInt(hndl, 0);
	}
}

// Players points have changed in game, make changes in database and recalculate points
public void db_updateStat(int client, int style)
{
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackCell(pack, style);

	char szQuery[512];
	// "UPDATE ck_playerrank SET finishedmaps ='%i', finishedmapspro='%i', multiplier ='%i' where steamid='%s'";
	Format(szQuery, 512, sql_updatePlayerRank, g_pr_finishedmaps[client], g_pr_finishedmaps[client], g_szSteamID[client], style);

	SQL_TQuery(g_hDb, SQL_UpdateStatCallback, szQuery, pack, DBPrio_Low);

}

public void SQL_UpdateStatCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (SQL_UpdateStatCallback): %s", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	int style = ReadPackCell(pack);
	CloseHandle(pack);

	// Calculating starts here:
	CalculatePlayerRank(client, style);
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
//	1. Point calculating starts here
// 	There are two ways:
//	- if client > MAXPLAYERS, his rank is being recalculated by an admin
//	- else player has increased his rank = recalculate points
//
public void CalculatePlayerRank(int client, int style)
{
	char szQuery[255];
	char szSteamId[32];
	// Take old points into memory, so at the end you can show how much the points changed
	g_pr_oldpoints[client][style] = g_pr_points[client][style];
	// Initialize point calculatin
	g_pr_points[client][style] = 0;

	// Start fluffys points
	g_Points[client][style][0] = 0; // Map Points
	g_Points[client][style][1] = 0; // Bonus Points
	g_Points[client][style][2] = 0; // Group Points
	g_Points[client][style][3] = 0; // Map WR Points
	g_Points[client][style][4] = 0; // Bonus WR Points
	g_Points[client][style][5] = 0; // Top 10 Points
	g_Points[client][style][6] = 0; // WRCP Points
	g_GroupMaps[client][style] = 0; // Group Maps
	g_Top10Maps[client][style] = 0; // Top 10 Maps
	g_WRs[client][style][0] = 0; // WRs
	g_WRs[client][style][1] = 0; // WRBs
	g_WRs[client][style][2] = 0; // WRCPs

	getSteamIDFromClient(client, szSteamId, 32);

	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackCell(pack, style);

	Format(szQuery, 255, "SELECT name FROM ck_playerrank WHERE steamid = '%s' AND style = '%i';", szSteamId, style);
	SQL_TQuery(g_hDb, sql_CalcuatePlayerRankCallback, szQuery, pack, DBPrio_Low);
}

// 2. See if player exists, insert new player into the database
// Fetched values:
// name
public void sql_CalcuatePlayerRankCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (sql_CalcuatePlayerRankCallback): %s", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	int style = ReadPackCell(pack);

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
		Format(szQuery, 512, "SELECT mapname, (SELECT count(1)+1 FROM ck_bonus b WHERE a.mapname=b.mapname AND a.runtime > b.runtime AND a.zonegroup = b.zonegroup AND b.style = %i) AS `rank`, (SELECT count(1) FROM ck_bonus b WHERE a.mapname = b.mapname AND a.zonegroup = b.zonegroup AND b.style = %i) as total FROM ck_bonus a WHERE steamid = '%s' AND style = %i;", style, style, szSteamId, style);
		SQL_TQuery(g_hDb, sql_CountFinishedBonusCallback, szQuery, pack, DBPrio_Low);
	}
	else
	{
		CloseHandle(pack);
		
		// Players first time on server
		if (client <= MaxClients)
		{
			g_pr_Calculating[client] = false;
			g_pr_AllPlayers[style]++;

			// Insert player to database
			char szQuery[512];
			char szUName[MAX_NAME_LENGTH];
			char szName[MAX_NAME_LENGTH * 2 + 1];

			GetClientName(client, szUName, MAX_NAME_LENGTH);
			SQL_EscapeString(g_hDb, szUName, szName, MAX_NAME_LENGTH * 2 + 1);

			// "INSERT INTO ck_playerrank (steamid, name, country) VALUES('%s', '%s', '%s');";
			// No need to continue calculating, as the doesn't have any records.
			Format(szQuery, 512, sql_insertPlayerRank, szSteamId, szSteamId64, szName, g_szCountry[client], g_szCountryCode[client], g_szContinentCode[client], GetTime(), style);
			SQL_TQuery(g_hDb, SQL_InsertPlayerCallBack, szQuery, client, DBPrio_Low);

			g_pr_finishedmaps[client][style] = 0;
			g_pr_finishedmaps_perc[client][style] = 0.0;
			g_pr_finishedbonuses[client][style] = 0;
			g_pr_finishedstages[client][style] = 0;
			g_GroupMaps[client][style] = 0; // Group Maps
			g_Top10Maps[client][style] = 0; // Top 10 Maps

			// play time
			g_iPlayTimeAlive[client] = 0;
			g_iPlayTimeSpec[client] = 0;

			CalculatePlayerRank(client, style);
		}
	}
}

//
// 3. Calculate points gained from bonuses
// Fetched values
// mapname, rank, total
//
public void sql_CountFinishedBonusCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (sql_CountFinishedBonusCallback): %s", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	int style = ReadPackCell(pack);

	char szMap[128], szSteamId[32], szMapName2[128];
	// int totalplayers
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
			rank = SQL_FetchInt(hndl, 1);
			SQL_FetchString(hndl, 0, szMap, 128);
			for (int i = 0; i < GetArraySize(g_MapList); i++) // Check that the map is in the mapcycle
			{
				GetArrayString(g_MapList, i, szMapName2, sizeof(szMapName2));
				if (StrEqual(szMapName2, szMap, false))
				{
					switch (rank)
					{
						case 1:
						{
							g_pr_points[client][style] += 250;
							g_Points[client][style][4] += 250;
							wrbs++;
						}
						case 2:
						{
							g_pr_points[client][style] += 235;
							g_Points[client][style][1] += 235;
						}
						case 3:
						{
							g_pr_points[client][style] += 220;
							g_Points[client][style][1] += 220;
						}
						case 4:
						{
							g_pr_points[client][style] += 205;
							g_Points[client][style][1] += 205;
						}
						case 5:
						{
							g_pr_points[client][style] += 190;
							g_Points[client][style][1] += 190;
						}
						case 6:
						{
							g_pr_points[client][style] += 175;
							g_Points[client][style][1] += 175;
						}
						case 7:
						{
							g_pr_points[client][style] += 160;
							g_Points[client][style][1] += 160;
						}
						case 8:
						{
							g_pr_points[client][style] += 145;
							g_Points[client][style][1] += 145;
						}
						case 9:
						{
							g_pr_points[client][style] += 130;
							g_Points[client][style][1] += 130;
						}
						case 10:
						{
							g_pr_points[client][style] += 100;
							g_Points[client][style][1] += 100;
						}
						case 11:
						{
							g_pr_points[client][style] += 95;
							g_Points[client][style][1] += 95;
						}
						case 12:
						{
							g_pr_points[client][style] += 90;
							g_Points[client][style][1] += 90;
						}
						case 13:
						{
							g_pr_points[client][style] += 80;
							g_Points[client][style][1] += 80;
						}
						case 14:
						{
							g_pr_points[client][style] += 70;
							g_Points[client][style][1] += 70;
						}
						case 15:
						{
							g_pr_points[client][style] += 60;
							g_Points[client][style][1] += 60;
						}
						case 16:
						{
							g_pr_points[client][style] += 50;
							g_Points[client][style][1] += 50;
						}
						case 17:
						{
							g_pr_points[client][style] += 40;
							g_Points[client][style][1] += 40;
						}
						case 18:
						{
							g_pr_points[client][style] += 30;
							g_Points[client][style][1] += 30;
						}
						case 19:
						{
							g_pr_points[client][style] += 20;
							g_Points[client][style][1] += 20;
						}
						case 20:
						{
							g_pr_points[client][style] += 10;
							g_Points[client][style][1] += 10;
						}
						default:
						{
							g_pr_points[client][style] += 5;
							g_Points[client][style][1] += 5;
						}
					}
					break;
				}
			}
		}
	}

	g_pr_finishedbonuses[client][style] = finishedbonuses;
	g_WRs[client][style][1] = wrbs;
	// Next up: Points from stages
	char szQuery[512];
	Format(szQuery, 512, "SELECT mapname, stage, (select count(1)+1 from ck_wrcps b where a.mapname=b.mapname and a.runtimepro > b.runtimepro and a.style = b.style and a.stage = b.stage) AS `rank` FROM ck_wrcps a where steamid = '%s' AND style = %i;", szSteamId, style);
	SQL_TQuery(g_hDb, sql_CountFinishedStagesCallback, szQuery, pack, DBPrio_Low);
}

//
// 4. Calculate points gained from stages
// Fetched values
// mapname, stage, rank, total
//
public void sql_CountFinishedStagesCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (sql_CountFinishedStagesCallback): %s", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	int style = ReadPackCell(pack);

	char szMap[128], szSteamId[32], szMapName2[128];

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
			SQL_FetchString(hndl, 0, szMap, 128);
			rank = SQL_FetchInt(hndl, 2);
			for (int i = 0; i < GetArraySize(g_MapList); i++) // Check that the map is in the mapcycle
			{
				GetArrayString(g_MapList, i, szMapName2, sizeof(szMapName2));
				if (StrEqual(szMapName2, szMap, false))
				{
					if (rank == 1)
					{
						wrcps++;
						int wrcpPoints = GetConVarInt(g_hWrcpPoints);
						if (wrcpPoints > 0)
						{
							g_pr_points[client][style] += wrcpPoints;
							g_Points[client][style][6] += wrcpPoints;
						}
					}
					break;
				}
			}
		}
	}

	g_pr_finishedstages[client][style] = finishedstages;
	g_WRs[client][style][2] = wrcps;

	// Next up: Points from maps
	char szQuery[512];
	Format(szQuery, 512, "SELECT mapname, (select count(1)+1 from ck_playertimes b where a.mapname=b.mapname and a.runtimepro > b.runtimepro AND b.style = %i) AS `rank`, (SELECT count(1) FROM ck_playertimes b WHERE a.mapname = b.mapname AND b.style = %i) as total, (SELECT tier FROM `ck_maptier` b WHERE a.mapname = b.mapname) as tier FROM ck_playertimes a where steamid = '%s' AND style = %i;", style, style, szSteamId, style);
	SQL_TQuery(g_hDb, sql_CountFinishedMapsCallback, szQuery, pack, DBPrio_Low);
}

// 5. Count the points gained from regular maps
// Fetching:
// mapname, rank, total, tier
public void sql_CountFinishedMapsCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (sql_CountFinishedMapsCallback): %s", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	int style = ReadPackCell(pack);
	CloseHandle(pack);

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
					if (g1difference < 4)
						g1top = (g1bot + 4);

					// Group 2
					float fG2top;
					int g2top;
					int g2bot;
					g2bot = g1top + 1;
					fG2top = (float(totalplayers) * g_Group2Pc);
					fG2top += 11.0;
					g2top = RoundToCeil(fG2top);

					int g2difference = (g2top - g2bot);
					if (g2difference < 4)
						g2top = (g2bot + 4);

					// Group 3
					float fG3top;
					int g3top;
					int g3bot;
					g3bot = g2top + 1;
					fG3top = (float(totalplayers) * g_Group3Pc);
					fG3top += 11.0;
					g3top = RoundToCeil(fG3top);

					int g3difference = (g3top - g3bot);
					if (g3difference < 4)
						g3top = (g3bot + 4);

					// Group 4
					float fG4top;
					int g4top;
					int g4bot;
					g4bot = g3top + 1;
					fG4top = (float(totalplayers) * g_Group4Pc);
					fG4top += 11.0;
					g4top = RoundToCeil(fG4top);

					int g4difference = (g4top - g4bot);
					if (g4difference < 4)
						g4top = (g4bot + 4);

					// Group 5
					float fG5top;
					int g5top;
					int g5bot;
					g5bot = g4top + 1;
					fG5top = (float(totalplayers) * g_Group5Pc);
					fG5top += 11.0;
					g5top = RoundToCeil(fG5top);

					int g5difference = (g5top - g5bot);
					if (g5difference < 4)
						g5top = (g5bot + 4);

					if (tier == 1)
					{
						wrpoints = ((float(totalplayers) * 1.75) / 6);
						wrpoints += 58.5;
						if (wrpoints < 250.0)
							wrpoints = 250.0;
					}
					else if (tier == 2)
					{
						wrpoints = ((float(totalplayers) * 2.8) / 5);
						wrpoints += 82.15;
						if (wrpoints < 500.0)
							wrpoints = 500.0;
					}
					else if (tier == 3)
					{
						wrpoints = ((float(totalplayers) * 3.5) / 4);
						if (wrpoints < 750.0)
							wrpoints = 750.0;
						else
							wrpoints += 117;
					}
					else if (tier == 4)
					{
						wrpoints = ((float(totalplayers) * 5.74) / 4);
						if (wrpoints < 1000.0)
							wrpoints = 1000.0;
						else
							wrpoints += 164.25;
					}
					else if (tier == 5)
					{
						wrpoints = ((float(totalplayers) * 7) / 4);
						if (wrpoints < 1250.0)
							wrpoints = 1250.0;
						else
							wrpoints += 234;
					}
					else if (tier == 6)
					{
						wrpoints = ((float(totalplayers) * 14) / 4);
						if (wrpoints < 1500.0)
							wrpoints = 1500.0;
						else
							wrpoints += 328;
					}
					else if (tier == 7)
					{
						wrpoints = ((float(totalplayers) * 21) / 4);
						if (wrpoints < 1750.0)
							wrpoints = 1750.0;
						else
							wrpoints += 420;
					}
					else if (tier == 8)
					{
						wrpoints = ((float(totalplayers) * 30) / 4);
						if (wrpoints < 2000.0)
							wrpoints = 2000.0;
						else
							wrpoints += 560;
					}
					else // no tier set
						wrpoints = 25.0;

					// Round WR points up
					iwrpoints = RoundToCeil(wrpoints);

					// Top 10 Points
					if (rank < 11)
					{
						g_Top10Maps[client][style]++;
						if (rank == 1)
						{
							g_pr_points[client][style] += iwrpoints;
							g_Points[client][style][3] += iwrpoints;
							wrs++;
						}
						else if (rank == 2)
						{
							points = (0.80 * iwrpoints);
							g_pr_points[client][style] += RoundToCeil(points);
							g_Points[client][style][5] += RoundToCeil(points);
						}
						else if (rank == 3)
						{
							points = (0.75 * iwrpoints);
							g_pr_points[client][style] += RoundToCeil(points);
							g_Points[client][style][5] += RoundToCeil(points);
						}
						else if (rank == 4)
						{
							points = (0.70 * iwrpoints);
							g_pr_points[client][style] += RoundToCeil(points);
							g_Points[client][style][5] += RoundToCeil(points);
						}
						else if (rank == 5)
						{
							points = (0.65 * iwrpoints);
							g_pr_points[client][style] += RoundToCeil(points);
							g_Points[client][style][5] += RoundToCeil(points);
						}
						else if (rank == 6)
						{
							points = (0.60 * iwrpoints);
							g_pr_points[client][style] += RoundToCeil(points);
							g_Points[client][style][5] += RoundToCeil(points);
						}
						else if (rank == 7)
						{
							points = (0.55 * iwrpoints);
							g_pr_points[client][style] += RoundToCeil(points);
							g_Points[client][style][5] += RoundToCeil(points);
						}
						else if (rank == 8)
						{
							points = (0.50 * iwrpoints);
							g_pr_points[client][style] += RoundToCeil(points);
							g_Points[client][style][5] += RoundToCeil(points);
						}
						else if (rank == 9)
						{
							points = (0.45 * iwrpoints);
							g_pr_points[client][style] += RoundToCeil(points);
							g_Points[client][style][5] += RoundToCeil(points);
						}
						else if (rank == 10)
						{
							points = (0.40 * iwrpoints);
							g_pr_points[client][style] += RoundToCeil(points);
							g_Points[client][style][5] += RoundToCeil(points);
						}
					}
					else if (rank > 10 && rank <= g5top)
					{
						// Group 1-5 Points
						g_GroupMaps[client][style] += 1;
						// Calculate Group Points
						g1points = (iwrpoints * 0.25);
						g2points = (g1points / 1.5);
						g3points = (g2points / 1.5);
						g4points = (g3points / 1.5);
						g5points = (g4points / 1.5);

						if (rank >= g1bot && rank <= g1top) // Group 1
						{
							g_pr_points[client][style] += RoundFloat(g1points);
							g_Points[client][style][2] += RoundFloat(g1points);
						}
						else if (rank >= g2bot && rank <= g2top) // Group 2
						{
							g_pr_points[client][style] += RoundFloat(g2points);
							g_Points[client][style][2] += RoundFloat(g2points);
						}
						else if (rank >= g3bot && rank <= g3top) // Group 3
						{
							g_pr_points[client][style] += RoundFloat(g3points);
							g_Points[client][style][2] += RoundFloat(g3points);
						}
						else if (rank >= g4bot && rank <= g4top) // Group 4
						{
							g_pr_points[client][style] += RoundFloat(g4points);
							g_Points[client][style][2] += RoundFloat(g4points);
						}
						else if (rank >= g5bot && rank <= g5top) // Group 5
						{
							g_pr_points[client][style] += RoundFloat(g5points);
							g_Points[client][style][2] += RoundFloat(g5points);
						}
					}

					// Map Completiton Points
					if (tier == 1)
					{
						g_pr_points[client][style] += 25;
						g_Points[client][style][0] += 25;
					}
					else if (tier == 2)
					{
						g_pr_points[client][style] += 50;
						g_Points[client][style][0] += 50;
					}
					else if (tier == 3)
					{
						g_pr_points[client][style] += 100;
						g_Points[client][style][0] += 100;
					}
					else if (tier == 4)
					{
						g_pr_points[client][style] += 200;
						g_Points[client][style][0] += 200;
					}
					else if (tier == 5)
					{
						g_pr_points[client][style] += 400;
						g_Points[client][style][0] += 400;
					}
					else if (tier == 6)
					{
						g_pr_points[client][style] += 600;
						g_Points[client][style][0] += 600;
					}
					else if (tier == 7)
					{
						g_pr_points[client][style] += 800;
						g_Points[client][style][0] += 800;
					}
					else if (tier == 8)
					{
						g_pr_points[client][style] += 1000;
						g_Points[client][style][0] += 1000;
					}
					else // no tier
					{
						g_pr_points[client][style] += 13;
						g_Points[client][style][0] += 13;
					}
					break;
				}
			}
		}
	}

	// Finished maps amount is stored in memory
	g_pr_finishedmaps[client][style] = finishedMaps;
	// Percentage of maps finished
	g_pr_finishedmaps_perc[client][style] = (float(finishedMaps) / float(g_pr_MapCount[0])) * 100.0;

	// WRs
	g_WRs[client][style][0] = wrs;

	int totalperc = g_pr_finishedstages[client][style] + g_pr_finishedbonuses[client][style] + g_pr_finishedmaps[client][style];
	int totalcomp = g_pr_StageCount + g_pr_BonusCount + g_pr_MapCount[0];
	float ftotalperc;

	ftotalperc = (float(totalperc) / (float(totalcomp))) * 100.0;

	if (IsValidClient(client) && !IsFakeClient(client))
		CS_SetMVPCount(client, (RoundFloat(ftotalperc)));

	// Done checking, update points
	db_updatePoints(client, style);
}

// 6. Updating points to database
public void db_updatePoints(int client, int style)
{
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackCell(pack, style);

	char szQuery[512];
	char szName[MAX_NAME_LENGTH * 2 + 1];
	char szSteamId[32];
	if (client > MAXPLAYERS && g_pr_RankingRecalc_InProgress || client > MAXPLAYERS && g_bProfileRecalc[client])
	{
		SQL_EscapeString(g_hDb, g_pr_szName[client], szName, MAX_NAME_LENGTH * 2 + 1);
		Format(szQuery, 512, sql_updatePlayerRankPoints, szName, g_pr_points[client][style], g_Points[client][style][3], g_Points[client][style][4], g_Points[client][style][6], g_Points[client][style][5], g_Points[client][style][2], g_Points[client][style][0], g_Points[client][style][1], g_pr_finishedmaps[client][style], g_pr_finishedbonuses[client][style], g_pr_finishedstages[client][style], g_WRs[client][style][0], g_WRs[client][style][1], g_WRs[client][style][2], g_Top10Maps[client][style], g_GroupMaps[client][style], g_pr_szSteamID[client], style);
		SQL_TQuery(g_hDb, sql_updatePlayerRankPointsCallback, szQuery, pack, DBPrio_Low);
	}
	else
	{
		if (IsValidClient(client))
		{
			GetClientName(client, szName, MAX_NAME_LENGTH);
			GetClientAuthId(client, AuthId_Steam2, szSteamId, MAX_NAME_LENGTH, true);
			Format(szQuery, 512, sql_updatePlayerRankPoints2, szName, g_pr_points[client][style], g_Points[client][style][3], g_Points[client][style][4], g_Points[client][style][6], g_Points[client][style][5], g_Points[client][style][2], g_Points[client][style][0], g_Points[client][style][1], g_pr_finishedmaps[client][style], g_pr_finishedbonuses[client][style], g_pr_finishedstages[client][style], g_WRs[client][style][0], g_WRs[client][style][1], g_WRs[client][style][2], g_Top10Maps[client][style], g_GroupMaps[client][style], g_szCountry[client], g_szCountryCode[client], g_szContinentCode[client], szSteamId, style);
			SQL_TQuery(g_hDb, sql_updatePlayerRankPointsCallback, szQuery, pack, DBPrio_Low);
		}
	}
}

// 7. Calculations done, if calculating all, move forward, if not announce changes.
public void sql_updatePlayerRankPointsCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (sql_updatePlayerRankPointsCallback): %s", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);
	int data = ReadPackCell(pack);
	int style = ReadPackCell(pack);
	CloseHandle(pack);

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
					CalculatePlayerRank(i, 0);
				}
			}
		}

		g_bProfileRecalc[data] = false;
		if (g_pr_RankingRecalc_InProgress)
		{
			// console info
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
						CPrintToChat(i, "%t", "PrUpdateFinished", g_szChatPrefix);
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
			ProfileMenu2(data, style, "", g_szSteamID[data]);
			if (IsValidClient(data))
			{
				if (style == 0)
					CPrintToChat(data, "%t", "Rc_PlayerRankFinished", g_szChatPrefix, g_pr_points[data][style]);
				else
					CPrintToChat(data, "%t", "Rc_PlayerRankFinished2", g_szChatPrefix, g_szStyleMenuPrint[style], g_pr_points[data][style]);
			}

			g_bRecalcRankInProgess[data] = false;
		}
		if (IsValidClient(data) && g_pr_showmsg[data]) // Player gained points
		{
			char szName[MAX_NAME_LENGTH];
			GetClientName(data, szName, MAX_NAME_LENGTH);

			int diff = g_pr_points[data][style] - g_pr_oldpoints[data][style];
			if (diff > 0) // if player earned points -> Announce
			{
				for (int i = 1; i <= MaxClients; i++)
				{
					if (IsValidClient(i))
					{
						if (style == 0)
							CPrintToChat(i, "%t", "EarnedPoints", g_szChatPrefix, szName, diff, g_pr_points[data][0]);
						else
							CPrintToChat(i, "%t", "EarnedPoints2", g_szChatPrefix, szName, diff, g_szStyleRecordPrint[style], g_pr_points[data][style]);
					}
				}
			}

			g_pr_showmsg[data] = false;
			db_CalculatePlayersCountGreater0(style);
		}
		g_pr_Calculating[data] = false;
		db_GetPlayerRank(data, style);
		CreateTimer(1.0, SetClanTag, data, TIMER_FLAG_NO_MAPCHANGE);
	}
}

// Called when player joins server
public void db_viewPlayerPoints(int client)
{
	for (int i = 0; i < MAX_STYLES; i++)
	{
		g_pr_finishedmaps[client][i] = 0;
		g_pr_finishedmaps_perc[client][i] = 0.0;
		g_pr_points[client][i] = 0;
	}

	if (GetConVarBool(g_hEnforceDefaultTitles))
		LoadDefaultTitle(client);

	g_bPrestigeCheck[client] = false;
	g_bPrestigeAvoid[client] = false;
	
	if (!g_bPrestigeCheck[client]) {
		if (GetConVarBool(g_hPrestigeVip) && (IsPlayerVip(client, false, false) || g_iHasEnforcedTitle[client])) {
			g_bPrestigeCheck[client] = true;
			g_bPrestigeAvoid[client] = true;
		}
	}
	
	g_iPlayTimeAlive[client] = 0;
	g_iPlayTimeSpec[client] = 0;
	g_iTotalConnections[client] = 1;
	char szQuery[255];

	if (!IsValidClient(client))
		return;

	// "SELECT steamid, name, points, finishedmapspro, country, lastseen, timealive, timespec, connections from ck_playerrank where steamid='%s'";
	Format(szQuery, 255, sql_selectRankedPlayer, g_szSteamID[client]);
	SQL_TQuery(g_hDb, db_viewPlayerPointsCallback, szQuery, client, DBPrio_Low);
}

public void db_viewPlayerPointsCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (db_viewPlayerPointsCallback): %s", error);
		if (!g_bSettingsLoaded[client])
			LoadClientSetting(client, g_iSettingToLoad[client]);
		return;
	}
	// SELECT steamid, name, points, finishedmapspro, country, lastseen, timealive, timespec, connections from ck_playerrank where steamid='%s';
	// Old player - get points
	if (SQL_HasResultSet(hndl))
	{
		int style;
		while (SQL_FetchRow(hndl))
		{
			style = SQL_FetchInt(hndl, 10);
			g_pr_points[client][style] = SQL_FetchInt(hndl, 2);
			g_pr_finishedmaps[client][style] = SQL_FetchInt(hndl, 3);
			g_pr_finishedmaps_perc[client][style] = (float(g_pr_finishedmaps[client][style]) / float(g_pr_MapCount[0])) * 100.0;
			if (style == 0)
			{
				g_iPlayTimeAlive[client] = SQL_FetchInt(hndl, 6);
				g_iPlayTimeSpec[client] = SQL_FetchInt(hndl, 7);
				g_iTotalConnections[client] = SQL_FetchInt(hndl, 8);
			}
		}

		g_iTotalConnections[client]++;

		char updateConnections[1024];
		Format(updateConnections, sizeof(updateConnections), "UPDATE ck_playerrank SET connections = connections + 1 WHERE steamid = '%s';", g_szSteamID[client]);
		SQL_TQuery(g_hDb, SQL_CheckCallback, updateConnections, _, DBPrio_Low);

		// Debug
		g_fTick[client][1] = GetGameTime();
		float tick = g_fTick[client][1] - g_fTick[client][0];
		LogQueryTime("[SurfTimer] %s: Finished db_viewPlayerPoints in %fs", g_szSteamID[client], tick);
		g_fTick[client][0] = GetGameTime();
		
		// Count players rank
		if (IsValidClient(client))
			for (int i = 0; i < MAX_STYLES; i++)
				db_GetPlayerRank(client, i);
	}
	else
	{
		if (IsValidClient(client))
		{
			// New player - insert
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

			Format(szQuery, sizeof(szQuery), sql_insertPlayerRank, g_szSteamID[client], szSteamId64, szName, g_szCountry[client], g_szCountryCode[client], g_szContinentCode[client], GetTime());
			SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, _, DBPrio_Low);

			// Play time
			g_iPlayTimeAlive[client] = 0;
			g_iPlayTimeSpec[client] = 0;

			// Debug
			g_fTick[client][1] = GetGameTime();
			float tick = g_fTick[client][1] - g_fTick[client][0];
			LogQueryTime("[SurfTimer] %s: Finished db_viewPlayerPoints in %fs", g_szSteamID[client], tick);
			g_fTick[client][0] = GetGameTime();

			// Count players rank
			for (int i = 0; i < MAX_STYLES; i++)
				db_GetPlayerRank(client, i);
		}
	}
}

// Get the amount of players, who have more points
public void db_GetPlayerRank(int client, int style)
{
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackCell(pack, style);

	char szQuery[512];
	// "SELECT name FROM ck_playerrank WHERE points >= (SELECT points FROM ck_playerrank WHERE steamid = '%s') ORDER BY points";
	Format(szQuery, 512, sql_selectRankedPlayersRank, style, g_szSteamID[client], style);
	SQL_TQuery(g_hDb, sql_selectRankedPlayersRankCallback, szQuery, pack, DBPrio_Low);
}

public void sql_selectRankedPlayersRankCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	ResetPack(pack);
	int client = ReadPackCell(pack);
	int style = ReadPackCell(pack);
	CloseHandle(pack);

	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (sql_selectRankedPlayersRankCallback): %s", error);
		CloseHandle(pack);
		if (!g_bSettingsLoaded[client])
			LoadClientSetting(client, g_iSettingToLoad[client]);
		return;
	}

	if (!IsValidClient(client))
		return;

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		g_PlayerRank[client][style] = SQL_GetRowCount(hndl);
		if (GetConVarInt(g_hPrestigeRank) > 0)
		{
			if (GetConVarBool(g_hPrestigeStyles) && !g_bPrestigeAvoid[client])
			{
				if (style == 0)
				{
					if (g_PlayerRank[client][0] >= GetConVarInt(g_hPrestigeRank) && !g_bPrestigeCheck[client])
						KickClient(client, "You must be at least rank %i to join this server", GetConVarInt(g_hPrestigeRank));
				}

				if (style == MAX_STYLES && !g_bPrestigeCheck[client])
					KickClient(client, "You must be at least rank %i to join this server", GetConVarInt(g_hPrestigeRank));
			}
			else
			{
				if (g_PlayerRank[client][0] <= GetConVarInt(g_hPrestigeRank) || g_bPrestigeCheck[client])
					g_bPrestigeCheck[client] = true;
				else if (!g_bPrestigeAvoid[client])
					KickClient(client, "You must be at least rank %i to join this server", GetConVarInt(g_hPrestigeRank));
			}
		}

		// Custom Title Access
		if (g_PlayerRank[client][0] <= 3 && g_PlayerRank[client][0] > 0) // Rank 1-3
			g_bCustomTitleAccess[client] = true;

		// Sort players by rank in scoreboard
		if (style == 0)
		{
			if (g_pr_AllPlayers[style] < g_PlayerRank[client][style] || g_PlayerRank[client][style] == 0)
				CS_SetClientContributionScore(client, -99999);
			else
				CS_SetClientContributionScore(client, -g_PlayerRank[client][style]);
		}
	}
	else if (style == 0 && GetConVarInt(g_hPrestigeRank) > 0 && !g_bPrestigeCheck[client])
		KickClient(client, "You must be at least rank %i to join this server", GetConVarInt(g_hPrestigeRank));

	if (!g_bSettingsLoaded[client] && style == (MAX_STYLES - 1))
	{
		g_fTick[client][1] = GetGameTime();
		float tick = g_fTick[client][1] - g_fTick[client][0];
		LogQueryTime("[SurfTimer] %s: Finished db_GetPlayerRank in %fs", g_szSteamID[client], tick);
		g_fTick[client][0] = GetGameTime();

		LoadClientSetting(client, g_iSettingToLoad[client]);
	}
}

public void db_viewPlayerProfile(int client, int style, char szSteamId[32], bool bPlayerFound, char szName[MAX_NAME_LENGTH])
{
	char szQuery[512];
	Format(g_pr_szrank[client], 512, "");

	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackCell(pack, style);
	WritePackString(pack, szSteamId);
	WritePackString(pack, szName);

	if (bPlayerFound)
	{
		// "SELECT name FROM ck_playerrank WHERE style = %i AND points >= (SELECT points FROM ck_playerrank WHERE steamid = '%s' AND style = %i) ORDER BY points";
		Format(szQuery, 512, sql_selectRankedPlayersRank, style, szSteamId, style);
		SQL_TQuery(g_hDb, sql_selectPlayerRankCallback, szQuery, pack, DBPrio_Low);
	}
	else
	{
		// "SELECT steamid, steamid64, name, country, points, wrpoints, wrbpoints, top10points, groupspoints, mappoints, bonuspoints, finishedmapspro, finishedbonuses, finishedstages, wrs, wrbs, wrcps, top10s, groups, lastseen FROM ck_playerrank WHERE name LIKE '%c%s%c' AND style = '%i';"; sql_selectUnknownProfile
		Format(szQuery, sizeof(szQuery), "SELECT steamid FROM ck_playerrank WHERE style = %i AND name LIKE '%c%s%c' LIMIT 1;", style, PERCENT, szName, PERCENT);
		SQL_TQuery(g_hDb, sql_selectUnknownPlayerCallback, szQuery, pack, DBPrio_Low);
	}
}

public void sql_selectUnknownPlayerCallback (Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (sql_selectUnknownPlayerCallback): %s", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	int style = ReadPackCell(pack);
	char szSteamId[32], szName[MAX_NAME_LENGTH];
	ReadPackString(pack, szSteamId, sizeof(szSteamId));
	ReadPackString(pack, szName, sizeof(szName));

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		SQL_FetchString(hndl, 0, szSteamId, sizeof(szSteamId));

		// Remake pack
		ResetPack(pack, true);
		WritePackCell(pack, client);
		WritePackCell(pack, style);
		WritePackString(pack, szSteamId);
		WritePackString(pack, szName);

		// "SELECT name FROM ck_playerrank WHERE style = %i AND points >= (SELECT points FROM ck_playerrank WHERE steamid = '%s' AND style = %i) ORDER BY points";
		char szQuery[512];
		Format(szQuery, 512, sql_selectRankedPlayersRank, style, szSteamId, style);
		SQL_TQuery(g_hDb, sql_selectPlayerRankCallback, szQuery, pack, DBPrio_Low);
	}
	else
	{
		CPrintToChat(client, "%t", "SQL40", g_szChatPrefix, szName);
		CloseHandle(pack);
	}
}

public void sql_selectPlayerRankCallback (Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (sql_selectPlayerRankCallback): %s", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	int style = ReadPackCell(pack);
	char szSteamId[32], szName[MAX_NAME_LENGTH];
	ReadPackString(pack, szSteamId, sizeof(szSteamId));
	ReadPackString(pack, szName, sizeof(szName));

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		WritePackCell(pack, SQL_GetRowCount(hndl));

		// "SELECT steamid, steamid64, name, country, points, wrpoints, wrbpoints, wrcppoints, top10points, groupspoints, mappoints, bonuspoints, finishedmapspro, finishedbonuses, finishedstages, wrs, wrbs, wrcps, top10s, groups, lastseen FROM ck_playerrank WHERE steamid = '%s' AND style = '%i';";
		char szQuery[512];
		Format(szQuery, sizeof(szQuery), sql_selectPlayerProfile, szSteamId, style);
		SQL_TQuery(g_hDb, sql_selectPlayerProfileCallback, szQuery, pack, DBPrio_Low);
	}
	else
	{
		CPrintToChat(client, "%t", "SQL40", g_szChatPrefix, szName);
		CloseHandle(pack);
	}
}

public void sql_selectPlayerProfileCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (sql_selectPlayerProfileCallback): %s", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	int style = ReadPackCell(pack);
	char szSteamId[32], szName2[MAX_NAME_LENGTH];
	ReadPackString(pack, szSteamId, sizeof(szSteamId));
	ReadPackString(pack, szName2, sizeof(szName2));
	int rank = ReadPackCell(pack);
	CloseHandle(pack);

	// "SELECT steamid, steamid64, name, country, points, wrpoints, wrbpoints, wrcppoints top10points, groupspoints, mappoints, bonuspoints, finishedmapspro, finishedbonuses, finishedstages, wrs, wrbs, wrcps, top10s, groups, lastseen FROM ck_playerrank WHERE steamid = '%s' AND style = '%i';";

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		char szName[MAX_NAME_LENGTH], szSteamId2[32], szCountry[64];

		SQL_FetchString(hndl, 0, szSteamId2, sizeof(szSteamId2));
		Format(g_szProfileSteamId[client], sizeof(g_szProfileSteamId), szSteamId2);
		SQL_FetchString(hndl, 2, szName, sizeof(szName));
		Format(g_szProfileName[client], sizeof(g_szProfileName), szName);
		SQL_FetchString(hndl, 3, szCountry, sizeof(szCountry));
		int points = SQL_FetchInt(hndl, 4);
		int wrPoints = SQL_FetchInt(hndl, 5);
		int wrbPoints = SQL_FetchInt(hndl, 6);
		int wrcpPoints = SQL_FetchInt(hndl, 7);
		int top10Points = SQL_FetchInt(hndl, 8);
		int groupPoints = SQL_FetchInt(hndl, 9);
		int mapPoints = SQL_FetchInt(hndl, 10);
		int bonusPoints = SQL_FetchInt(hndl, 11);
		int finishedMaps = SQL_FetchInt(hndl, 12);
		int finishedBonuses = SQL_FetchInt(hndl, 13);
		int finishedStages = SQL_FetchInt(hndl, 14);
		int wrs = SQL_FetchInt(hndl, 15);
		int wrbs = SQL_FetchInt(hndl, 16);
		int wrcps = SQL_FetchInt(hndl, 17);
		int top10s = SQL_FetchInt(hndl, 18);
		int groups = SQL_FetchInt(hndl, 19);
		int lastseen = SQL_FetchInt(hndl, 20);

		if (finishedMaps > g_pr_MapCount[0])
			finishedMaps = g_pr_MapCount[0];
		
		if (finishedBonuses > g_pr_BonusCount)
			finishedBonuses = g_pr_BonusCount;
		
		if (finishedStages > g_pr_StageCount)
			finishedStages = g_pr_StageCount;

		int totalCompleted = finishedMaps + finishedBonuses + finishedStages;
		int totalZones = g_pr_MapCount[0] + g_pr_BonusCount + g_pr_StageCount;

		// Completion Percentage 
		float fPerc, fBPerc, fSPerc, fTotalPerc;
		char szPerc[32], szBPerc[32], szSPerc[32], szTotalPerc[32];

		// Calculate percentages and format them into strings
		fPerc = (float(finishedMaps) / (float(g_pr_MapCount[0]))) * 100.0;
		fBPerc = (float(finishedBonuses) / (float(g_pr_BonusCount))) * 100.0;
		fSPerc = (float(finishedStages) / (float(g_pr_StageCount))) * 100.0;
		fTotalPerc = (float(totalCompleted) / (float(totalZones))) * 100.0;

		FormatPercentage(fPerc, szPerc, sizeof(szPerc));
		FormatPercentage(fBPerc, szBPerc, sizeof(szBPerc));
		FormatPercentage(fSPerc, szSPerc, sizeof(szSPerc));
		FormatPercentage(fTotalPerc, szTotalPerc, sizeof(szTotalPerc));

		// Get players skillgroup
		SkillGroup RankValue;
		int index = GetSkillgroupIndex(rank, points);
		GetArrayArray(g_hSkillGroups, index, RankValue, sizeof(SkillGroup));
		char szSkillGroup[128];
		Format(szSkillGroup, sizeof(szSkillGroup), RankValue.RankName);
		ReplaceString(szSkillGroup, sizeof(szSkillGroup), "{style}", "");

		char szRank[32];
		if (rank > g_pr_RankedPlayers[0] || points == 0)
			Format(szRank, 32, "-");
		else
			Format(szRank, 32, "%i", rank);

		// Format Profile Menu
		char szCompleted[1024], szMapPoints[128], szBonusPoints[128], szTop10Points[128], szStagePc[128], szMiPc[128], szRecords[128], szLastSeen[128];
		
		// Get last seen
		int time = GetTime();
		int unix = time - lastseen;
		diffForHumans(unix, szLastSeen, sizeof(szLastSeen), 1);

		Format(szMapPoints, 128, "Maps: %i/%i - [%i] (%s%c)", finishedMaps, g_pr_MapCount[0], mapPoints, szPerc, PERCENT);

		if (wrbPoints > 0)
			Format(szBonusPoints, 128, "Bonuses: %i/%i - [%i+%i] (%s%c)", finishedBonuses, g_pr_BonusCount, bonusPoints, wrbPoints, szBPerc, PERCENT);
		else
			Format(szBonusPoints, 128, "Bonuses: %i/%i - [%i] (%s%c)", finishedBonuses, g_pr_BonusCount, bonusPoints, szBPerc, PERCENT);

		if (wrPoints > 0)
			Format(szTop10Points, 128, "Top10: %i - [%i+%i]", top10s, top10Points, wrPoints);
		else
			Format(szTop10Points, 128, "Top10: %i - [%i]", top10s, top10Points);

		if (wrcpPoints > 0)
			Format(szStagePc, 128, "Stages: %i/%i [0+%d] (%s%c)", finishedStages, g_pr_StageCount, wrcpPoints, szSPerc, PERCENT);
		else
			Format(szStagePc, 128, "Stages: %i/%i [0] (%s%c)", finishedStages, g_pr_StageCount, szSPerc, PERCENT);

		Format(szMiPc, 128, "Map Improvement Pts: %i - [%i]", groups, groupPoints);

		Format(szRecords, 128, "Records:\nMap WR: %i\nStage WR: %i\nBonus WR: %i", wrs, wrcps, wrbs);

		Format(szCompleted, 1024, "Completed - Points (%s%c):\n%s\n%s\n%s\n%s\n \n%s\n \n%s\n \n", szTotalPerc, PERCENT, szMapPoints, szBonusPoints, szTop10Points, szStagePc, szMiPc, szRecords);

		Format(g_pr_szrank[client], 512, "Rank: %s/%i %s\nTotal pts: %i\n \n", szRank, g_pr_RankedPlayers[style], szSkillGroup, points);
		
		char szTop[128];
		if (style > 0)
			Format(szTop, sizeof(szTop), "[%s | %s | Online: %s]\n", szName, g_szStyleMenuPrint[style], szLastSeen);
		else
			Format(szTop, sizeof(szTop), "[%s ||| Online: %s]\n", szName, szLastSeen);

		char szTitle[1024];
		if (GetConVarBool(g_hCountry))
			Format(szTitle, 1024, "%s-------------------------------------\n%s\nCountry: %s\n \n%s\n", szTop, szSteamId, szCountry, g_pr_szrank[client]);
		else
			Format(szTitle, 1024, "%s-------------------------------------\n%s\n \n%s", szTop, szSteamId, g_pr_szrank[client]);

		Menu menu = CreateMenu(ProfileMenuHandler);
		SetMenuTitle(menu, szTitle);
		AddMenuItem(menu, "Finished maps", szCompleted);
		AddMenuItem(menu, szSteamId, "Player Info");

		if (IsValidClient(client))
			if (StrEqual(szSteamId, g_szSteamID[client]))
				AddMenuItem(menu, "Refresh my profile", "Refresh my profile");

		SetMenuExitButton(menu, true);
		DisplayMenu(menu, client, MENU_TIME_FOREVER);
	}
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
					CPrintToChat(client, "%t", "SQL1", g_szChatPrefix);
				}
				else
				{
					g_bRecalcRankInProgess[client] = true;
					CPrintToChat(client, "%t", "Rc_PlayerRankStart", g_szChatPrefix);
					CalculatePlayerRank(client, g_ProfileStyleSelect[client]);
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
				case 0:db_selectTopPlayers(client, 0);
				case 3:db_viewWrcpMap(client, g_szWrcpMapSelect[client]);
			}
			if (g_MenuLevel[client] < 0)
			{
				if (g_bSelectProfile[client])
					ProfileMenu2(client, g_ProfileStyleSelect[client], "", "");
			}
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}

	return 0;
}

public void completionMenu(int client)
{
	int style = g_ProfileStyleSelect[client];
	char szTitle[128];
	if (style == 0)
		Format(szTitle, 128, "[%s | Completion Menu]\n \n", g_szProfileName[client]);
	else
		Format(szTitle, 128, "[%s | %s | Completion Menu]\n \n", g_szProfileName[client], g_szStyleMenuPrint[style]);

	Menu theCompletionMenu = CreateMenu(CompletionMenuHandler);
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
		db_viewPlayerProfile(client, g_ProfileStyleSelect[client], g_szProfileSteamId[client], true, "");
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

public void ContinueRecalc(int client)
{
	// ON RECALC ALL
	if (client > MAXPLAYERS)
		CalculatePlayerRank(client, 0);
	else
	{
		// ON CONNECT
		if (!IsValidClient(client) || IsFakeClient(client))
		return;
		float diff = GetGameTime() - g_fMapStartTime + 1.5;
		if (GetClientTime(client) < diff)
		{
			CalculatePlayerRank(client, 0);
		}
		else
		{
			db_viewPlayerPoints(client);
		}
	}
}

/*==================================
=           PLAYER TIMES           =
==================================*/

public void db_GetMapRecord_Pro()
{
	g_fRecordMapTime = 9999999.0;
	for (int i = 1; i < MAX_STYLES; i++)
		g_fRecordStyleMapTime[i] = 9999999.0;

	char szQuery[512];
	// SELECT MIN(runtimepro), name, steamid, style FROM ck_playertimes WHERE mapname = '%s' AND runtimepro > -1.0 GROUP BY style
	Format(szQuery, 512, sql_selectMapRecord, g_szMapName);
	SQL_TQuery(g_hDb, sql_selectMapRecordCallback, szQuery, GetGameTime(), DBPrio_Low);
}

public void sql_selectMapRecordCallback(Handle owner, Handle hndl, const char[] error, float time)
{
	LogQueryTime("[SurfTimer] : Finished sql_selectMapRecordCallback in: %f", GetGameTime() - time);
	
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (sql_selectMapRecordCallback): %s", error);
		if (!g_bServerDataLoaded)
		{
			db_viewMapProRankCount();
			CreateTimer(3.0, RefreshZonesTimer, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE);
		}
		return;
	}

	for (int i=0; i < MAX_STYLES; i++)
	{
		g_iRecordPreStrafe[0][0][i] = 0;
		g_iRecordPreStrafe[1][0][i] = 0;
		g_iRecordPreStrafe[2][0][i] = 0;
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

			g_iRecordPreStrafe[0][0][style] = SQL_FetchInt(hndl, 4);
			g_iRecordPreStrafe[1][0][style] = SQL_FetchInt(hndl, 5);
			g_iRecordPreStrafe[2][0][style] = SQL_FetchInt(hndl, 6);
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
		CreateTimer(3.0, RefreshZonesTimer, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE);
	}
	return;
}

public void db_selectTopSurfers(int client, char mapname[128])
{
	char szQuery[1024];
	Format(szQuery, 1024, sql_selectTopSurfers, mapname, 0, 0);
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, mapname);
	WritePackCell(pack, 0);
	SQL_TQuery(g_hDb, sql_selectTopSurfersCallback, szQuery, pack, DBPrio_Low);
}

public void db_selectMapTopSurfers(int client, char mapname[128])
{
	char szQuery[1024];
	int type = 0;
	Format(szQuery, 1024, sql_selectTopSurfers2, mapname);
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, mapname);
	WritePackCell(pack, type);
	SQL_TQuery(g_hDb, sql_selectTopSurfersCallback, szQuery, pack, DBPrio_Low);
}

public void sql_selectTopSurfersCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (sql_selectTopSurfersCallback): %s", error);
		return;
	}

	ResetPack(data);
	int client = ReadPackCell(data);
	char szMap[128];
	ReadPackString(data, szMap, 128);
	int style = 0; // ReadPackCell(data);
	CloseHandle(data);

	char szFirstMap[128];
	char szValue[128];
	char szName[64];
	float time;
	char szSteamID[32];

	Handle menu;
	menu = CreateMenu(MapMenuHandler1);
	SetMenuPagination(menu, 5);

	char title[256];
	if (SQL_HasResultSet(hndl))
	{
		int i = 1;
		while (SQL_FetchRow(hndl))
		{
			SQL_FetchString(hndl, 0, szSteamID, 32);
			SQL_FetchString(hndl, 1, szName, 64);
			time = SQL_FetchFloat(hndl, 2);
			SQL_FetchString(hndl, 4, szMap, 128);

			if (i == 1 || (i > 1 && StrEqual(szFirstMap, szMap)))
			{
				if (i < 51)
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

					if (i == 1)
						Format(szFirstMap, 128, "%s", szMap);
					i++;
				}
			}
		}
		if (i == 1)
		{
			CPrintToChat(client, "%t", "NoTopRecords", g_szChatPrefix, szMap);
		}
	}
	else
		CPrintToChat(client, "%t", "NoTopRecords", g_szChatPrefix, szMap);

	switch (style)
	{
		case 1: Format(title, 256, "Top 50 SW Times on %s \n    Rank    Time               Player", szFirstMap);
		case 2: Format(title, 256, "Top 50 HSW Times on %s \n    Rank    Time               Player", szFirstMap);
		case 3: Format(title, 256, "Top 50 BW Times on %s \n    Rank    Time               Player", szFirstMap);
		case 4: Format(title, 256, "Top 50 Low-Gravity Times on %s \n    Rank    Time               Player", szFirstMap);
		case 5: Format(title, 256, "Top 50 Slow Motion Times on %s \n    Rank    Time               Player", szFirstMap);
		case 6: Format(title, 256, "Top 50 Fast Forward Times on %s \n    Rank    Time               Player", szFirstMap);
		case 7: Format(title, 256, "Top 50 Freestyle Times on %s \n    Rank    Time               Player", szFirstMap);
		default: Format(title, 256, "Top 50 Times on %s \n    Rank    Time               Player", szFirstMap);
	}

	SetMenuTitle(menu, title);
	SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}


// BONUS
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
		LogError("[SurfTimer] SQL Error (db_selectBonusesInMapCallback): %s", error);
		return;
	}
	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		char mapname[128], MenuTitle[248], BonusName[128], MenuID[248];
		int zGrp;

		if (SQL_GetRowCount(hndl) == 1)
		{
			SQL_FetchString(hndl, 0, mapname, 128);
			db_selectBonusTopSurfers(client, mapname, SQL_FetchInt(hndl, 1), 0);
			return;
		}

		Menu listBonusesinMapMenu = new Menu(MenuHandler_SelectBonusinMap);

		SQL_FetchString(hndl, 0, mapname, 128);
		zGrp = SQL_FetchInt(hndl, 1);
		Format(MenuTitle, 248, "Choose a Bonus in %s", mapname);
		listBonusesinMapMenu.SetTitle(MenuTitle);

		SQL_FetchString(hndl, 2, BonusName, 128);

		if (!BonusName[0])
			Format(BonusName, 128, "bonus %i", zGrp);

		Format(MenuID, 248, "%s-%i", mapname, zGrp);

		listBonusesinMapMenu.AddItem(MenuID, BonusName);


		while (SQL_FetchRow(hndl))
		{
			SQL_FetchString(hndl, 2, BonusName, 128);
			zGrp = SQL_FetchInt(hndl, 1);

			if (StrEqual(BonusName, "NULL", false))
				Format(BonusName, 128, "bonus %i", zGrp);

			Format(MenuID, 248, "%s-%i", mapname, zGrp);

			listBonusesinMapMenu.AddItem(MenuID, BonusName);
		}

		listBonusesinMapMenu.ExitButton = true;
		listBonusesinMapMenu.Display(client, 60);
	}
	else
	{
		CPrintToChat(client, "%t", "SQL2", g_szChatPrefix);
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

			db_selectBonusTopSurfers(client, splits[0], StringToInt(splits[1]), 0);
		}
		case MenuAction_End:
		{
			delete sMenu;
		}
	}

	return 0;
}

public void db_selectBonusTopSurfers(int client, char mapname[128], int zGrp, int style)
{
	char szQuery[1024];
	Format(szQuery, 1024, sql_selectTopBonusSurfers, mapname, style, style, zGrp);
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
		LogError("[SurfTimer] SQL Error (sql_selectTopBonusSurfersCallback): %s", error);
		return;
	}

	ResetPack(data);
	int client = ReadPackCell(data);
	char szMap[128];
	ReadPackString(data, szMap, 128);
	int zGrp = ReadPackCell(data);
	CloseHandle(data);

	char szFirstMap[128], szValue[128], szName[64], szSteamID[32], title[256];
	float time;
	Menu topMenu;

	topMenu = new Menu(MapMenuHandler1);

	topMenu.Pagination = 5;

	if (SQL_HasResultSet(hndl))
	{
		int i = 1;
		while (SQL_FetchRow(hndl))
		{
			SQL_FetchString(hndl, 0, szSteamID, 32);
			SQL_FetchString(hndl, 1, szName, 64);
			time = SQL_FetchFloat(hndl, 2);
			SQL_FetchString(hndl, 4, szMap, 128);
			if (i == 1 || (i > 1 && StrEqual(szFirstMap, szMap)))
			{
				if (i < 51)
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
					if (i == 1)
						Format(szFirstMap, 128, "%s", szMap);
					i++;
				}
			}
		}
		if (i == 1)
		{
			CPrintToChat(client, "%t", "NoTopRecords", g_szChatPrefix, szMap);
		}
	}
	else
	CPrintToChat(client, "%t", "NoTopRecords", g_szChatPrefix, szMap);
	Format(title, 256, "Top 50 Times on %s (B %i) \n    Rank    Time               Player", szFirstMap, zGrp);
	topMenu.SetTitle(title);
	topMenu.OptionFlags = MENUFLAG_BUTTON_EXIT;
	topMenu.Display(client, MENU_TIME_FOREVER);
}

public void db_currentRunRank(int client, int style)
{
	if (!IsValidClient(client))
		return;

	float runtime = g_fCurrentRunTime[client];

	char szQuery[512];
	Format(szQuery, 512, "SELECT count(runtimepro)+1 FROM ck_playertimes WHERE mapname = '%s' AND runtimepro < '%f' AND style = '%i';", g_szMapName, runtime, style);
	SQL_TQuery(g_hDb, SQL_CurrentRunRankCallback, szQuery, client, DBPrio_Low);
}

public void SQL_CurrentRunRankCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (SQL_CurrentRunRankCallback): %s", error);
		return;
	}
	// Get players rank, 9999999 = error
	int rank;
	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		rank = SQL_FetchInt(hndl, 0);
	}

	if(g_bPracticeModeRun[client])
	{

		float runtime = g_fCurrentRunTime[client];
		float f_srDiff;
		char sz_srDiff[128];

		if(g_fRecordMapTime != 9999999.0)
			f_srDiff = (g_fRecordMapTime - runtime);
		else
			f_srDiff = runtime;

		FormatTimeFloat(client, f_srDiff, 3, sz_srDiff, 128);

		if(f_srDiff == runtime)
			Format(sz_srDiff, 128, "SR: N/A", sz_srDiff);
		else if (f_srDiff > 0.0)
			Format(sz_srDiff, 128, "%cSR: %c-%s%c", WHITE, LIGHTGREEN, sz_srDiff, WHITE);
		else if(f_srDiff <= 0.0)
			Format(sz_srDiff, 128, "%cSR: %c+%s%c", WHITE, RED, sz_srDiff, WHITE);

		char szSpecMessage[512];

		CPrintToChat(client, "%t", "BPress5", g_szChatPrefix, g_szPracticeTime[client], sz_srDiff , rank);
		Format(szSpecMessage, sizeof(szSpecMessage), "%t", "BPress5", g_szChatPrefix, g_szPracticeTime[client], sz_srDiff, rank);

		CheckpointToSpec(client, szSpecMessage);
	}
	else
		MapFinishedMsgs(client, rank);
}

public void db_currentRunRank_StagePrac(int client, int style, int stage, float fClientPbStageTime)
{

	if (!IsValidClient(client))
		return;

	Handle data_srcp = CreateDataPack();
	WritePackCell(data_srcp, client);
	WritePackCell(data_srcp, style);
	WritePackCell(data_srcp, stage);
	WritePackFloat(data_srcp, fClientPbStageTime);

	char szQuery[1024];
	Format(szQuery, 1024, "SELECT count(runtimepro)+1 FROM ck_wrcps WHERE mapname = '%s' AND stage = '%i' AND style = '%i' AND runtimepro < '%f';", g_szMapName, stage, style, g_fCurrentRunTime[client]);
	SQL_TQuery(g_hDb, SQL_CurrentRunRank_StagePracCallback, szQuery, data_srcp, DBPrio_Low);

}

public void SQL_CurrentRunRank_StagePracCallback(Handle owner, Handle hndl, const char[] error, any data_srcp)
{

	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (SQL_CurrentRunRank_StagePracCallback): %s", error);
		delete view_as<DataPack>(data_srcp);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{	
		
		int stage_rank = SQL_FetchInt(hndl, 0);

		ResetPack(data_srcp);
		int data = ReadPackCell(data_srcp);
		int style = ReadPackCell(data_srcp);
		int stage = ReadPackCell(data_srcp);
		float stage_time = ReadPackFloat(data_srcp);
		WritePackCell(data_srcp, stage_rank);
		delete view_as<DataPack>(data_srcp);

		PrintPracSrcp(data, style, stage, stage_rank, stage_time);
		
	}

}

// Get clients record from database
// Called when a player finishes a map
public void db_selectRecord(int client)
{
	if (!IsValidClient(client) || g_bPracticeMode[client])
		return;

	char szQuery[255];
	Format(szQuery, 255, "SELECT runtimepro FROM ck_playertimes WHERE steamid = '%s' AND mapname = '%s' AND runtimepro > -1.0 AND style = 0;", g_szSteamID[client], g_szMapName);
	SQL_TQuery(g_hDb, sql_selectRecordCallback, szQuery, client, DBPrio_Low);
}

public void sql_selectRecordCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (sql_selectRecordCallback): %s", error);
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
	{ // No record found from database - Let's insert

		// Escape name for SQL injection protection
		char szName[MAX_NAME_LENGTH * 2 + 1], szUName[MAX_NAME_LENGTH];
		GetClientName(data, szUName, MAX_NAME_LENGTH);
		SQL_EscapeString(g_hDb, szUName, szName, MAX_NAME_LENGTH);

		// Move required information in datapack
		Handle pack = CreateDataPack();
		WritePackFloat(pack, g_fFinalTime[data]);
		WritePackCell(pack, data);

		// "INSERT INTO ck_playertimes (steamid, mapname, name, runtimepro, style) VALUES('%s', '%s', '%s', '%f', %i);";
		Format(szQuery, 512, sql_insertPlayerTime, g_szSteamID[data], g_szMapName, szName, g_fFinalTime[data], 0, g_iPreStrafe[0][0][0][data], g_iPreStrafe[1][0][0][data], g_iPreStrafe[2][0][0][data]);
		SQL_TQuery(g_hDb, SQL_UpdateRecordProCallback, szQuery, pack, DBPrio_Low);

		g_bInsertNewTime = true;
	}
}

// If latest record was faster than old - Update time
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
	// "UPDATE ck_playertimes SET name = '%s', runtimepro = '%f' WHERE steamid = '%s' AND mapname = '%s' AND style = %i;";
	Format(szQuery, 1024, sql_updateRecordPro, szName, g_fFinalTime[client], g_iPreStrafe[0][0][0][client], g_iPreStrafe[1][0][0][client], g_iPreStrafe[2][0][0][client], g_szSteamID[client], g_szMapName, 0);
	SQL_TQuery(g_hDb, SQL_UpdateRecordProCallback, szQuery, pack, DBPrio_Low);
}


public void SQL_UpdateRecordProCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (SQL_UpdateRecordProCallback): %s", error);
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
		Format(szQuery, sizeof(szQuery), "SELECT count(runtimepro) FROM `ck_playertimes` WHERE `mapname` = '%s' AND `runtimepro` < %f AND style = 0;", g_szMapName, time);
		SQL_TQuery(g_hDb, SQL_UpdateRecordProCallback2, szQuery, client, DBPrio_Low);
	}
}

public void SQL_UpdateRecordProCallback2(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (SQL_UpdateRecordProCallback2): %s", error);
		return;
	}
	// Get players rank, 9999999 = error
	int rank = 9999999;
	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		rank = (SQL_FetchInt(hndl, 0)+1);
	}
	g_MapRank[data] = rank;
	if (rank <= 10 && rank > 1)
		g_bTop10Time[data] = true;
	else
		g_bTop10Time[data] = false;

	MapFinishedMsgs(data);

	if (g_bInsertNewTime)
	{
		db_selectCurrentMapImprovement();
		g_bInsertNewTime = false;
	}
}

public void db_viewAllRecords(int client, char szSteamId[32])
{
	// "SELECT db1.name, db2.steamid, db2.mapname, db2.runtimepro as overall, db1.steamid, db3.tier FROM ck_playertimes as db2 INNER JOIN ck_playerrank as db1 on db2.steamid = db1.steamid INNER JOIN ck_maptier AS db3 ON db2.mapname = db3.mapname WHERE db2.steamid = '%s' AND db2.style = %i AND db1.style = %i AND db2.runtimepro > -1.0 ORDER BY mapname ASC;";

	char szQuery[1024];
	Format(szQuery, 1024, sql_selectPersonalAllRecords, szSteamId, g_ProfileStyleSelect[client], g_ProfileStyleSelect[client]);

	if ((StrContains(szSteamId, "STEAM_") != -1))
		SQL_TQuery(g_hDb, SQL_ViewAllRecordsCallback, szQuery, client, DBPrio_Low);
	else if (IsClientInGame(client))
		CPrintToChat(client, "%t", "SQL3", g_szChatPrefix);
}


public void SQL_ViewAllRecordsCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (SQL_ViewAllRecordsCallback): %s", error);
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

			// map in rotation?
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
						CPrintToChat(data, "%t", "ConsoleOutput", g_szChatPrefix);
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
			CPrintToChat(data, "%t", "ConsoleOutput", g_szChatPrefix);
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
		ProfileMenu2(data, g_ProfileStyleSelect[data], "", g_szSteamID[data]);
		CPrintToChat(data, "%t", "PlayerHasNoMapRecords", g_szChatPrefix, g_szProfileName[data]);
	}
}

public void SQL_ViewAllRecordsCallback2(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (SQL_ViewAllRecordsCallback2): %s", error);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		char szQuery[512];
		char szName[MAX_NAME_LENGTH];
		char szSteamId[32];
		char szMapName[128];

		int rank = SQL_FetchInt(hndl, 0);
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
		LogError("[SurfTimer] SQL Error (SQL_ViewAllRecordsCallback3): %s", error);
		return;
	}

	// fluffys

	// if there is a player record
	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		int count = SQL_FetchInt(hndl, 1);
		char szTime[32];
		char szMapName[128];
		char szSteamId[32];
		char szName[MAX_NAME_LENGTH];
		// fluffys
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
		if (strlen(szTotal) == 8)
			Format(szValue, 128, "%i/%i    %s | » %s - %i", rank, count, szTime, szMapName, tier);
		else if (strlen(szTotal) == 7)
			Format(szValue, 128, "%i/%i      %s | » %s - %i", rank, count, szTime, szMapName, tier);
		else if (strlen(szTotal) == 6)
			Format(szValue, 128, "%i/%i      %s | » %s - %i", rank, count, szTime, szMapName, tier);
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

		if (g_mapsCompletedLoop[client] == totalMaps)
		{
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
	// "SELECT db1.name, db2.steamid, db2.mapname, db2.runtimepro as overall, db1.steamid, db3.tier FROM ck_playertimes as db2 INNER JOIN ck_playerrank as db1 on db2.steamid = db1.steamid INNER JOIN ck_maptier AS db3 ON db2.mapname = db3.mapname WHERE db2.steamid = '%s' AND db2.style = %i AND db1.style = %i AND db2.runtimepro > -1.0 ORDER BY mapname ASC;";

	Handle data = CreateDataPack();
	WritePackCell(data, client);
	WritePackCell(data, type);

	char szQuery[1024];
	Format(szQuery, 1024, sql_selectPersonalAllRecords, szSteamId, g_ProfileStyleSelect[client], g_ProfileStyleSelect[client]);

	if ((StrContains(szSteamId, "STEAM_") != -1))
		SQL_TQuery(g_hDb, SQL_ViewTop10RecordsCallback, szQuery, data, DBPrio_Low);
	else if (IsClientInGame(client))
		CPrintToChat(client, "%t", "SQL3", g_szChatPrefix);
}

public void SQL_ViewTop10RecordsCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (SQL_ViewAllRecordsCallback): %s", error);
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

			// map in rotation?
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
						CPrintToChat(data, "%t", "ConsoleOutput", g_szChatPrefix);
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
			CPrintToChat(data, "%t", "ConsoleOutput", g_szChatPrefix);
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
		ProfileMenu2(data, g_ProfileStyleSelect[data], "", g_szSteamID[data]);
		CPrintToChat(data, "%t", "PlayerHasNoMapRecords", g_szChatPrefix, g_szProfileName[data]);
	}
}

public void SQL_ViewTop10RecordsCallback2(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (SQL_ViewAllRecordsCallback2): %s", error);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		char szQuery[512];
		char szName[MAX_NAME_LENGTH];
		char szSteamId[32];
		char szMapName[128];

		int rank = SQL_FetchInt(hndl, 0);
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
		LogError("[SurfTimer] SQL Error (SQL_ViewAllRecordsCallback3): %s", error);
		return;
	}

	// fluffys

	int i = 1;

	// if there is a player record
	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		int count = SQL_GetRowCount(hndl);
		char szTime[32];
		char szMapName[128];
		char szSteamId[32];
		char szName[MAX_NAME_LENGTH];
		// fluffys
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
		i++;

		if (IsValidClient(client))
		{
			if (type == 0)
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
		LogError("[SurfTimer] SQL Error (SQL_SelectPlayerCallback): %s", error);
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

// Getting player settings starts here
public void db_viewPersonalRecords(int client, char szSteamId[32], char szMapName[128])
{
	char szName[32];
	GetClientName(client, szName, sizeof(szName));
	g_fClientsLoading[client][0] = GetGameTime();
	LogQueryTime("[SurfTimer] Loading %s - %s settings", szSteamId, szName);

	g_fTick[client][0] = GetGameTime();

	char szQuery[1024];
	Format(szQuery, 1024, "SELECT runtimepro, style FROM ck_playertimes WHERE steamid = '%s' AND mapname = '%s' AND runtimepro > 0.0;", szSteamId, szMapName);
	SQL_TQuery(g_hDb, SQL_selectPersonalRecordsCallback, szQuery, client, DBPrio_Low);
}


public void SQL_selectPersonalRecordsCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (SQL_selectPersonalRecordsCallback): %s", error);
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
		LogQueryTime("[SurfTimer] %s: Finished db_viewPersonalRecords in %fs", g_szSteamID[client], tick);
		g_fTick[client][0] = GetGameTime();
		LoadClientSetting(client, g_iSettingToLoad[client]);
	}
}

/*===================================
=            PLAYER TEMP            =
===================================*/

public void db_deleteTmp(int client)
{
	char szQuery[256];
	if (!IsValidClient(client))
		return;
	Format(szQuery, sizeof(szQuery), sql_deletePlayerTmp, g_szSteamID[client]);
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, _, DBPrio_Low);
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
		LogError("[SurfTimer] SQL Error (SQL_LastRunCallback): %s", error);
		return;
	}

	g_bTimerRunning[data] = false;
	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl) && IsValidClient(data))
	{

		// "SELECT cords1,cords2,cords3, angle1, angle2, angle3,runtimeTmp, EncTickrate, Stage, zonegroup FROM ck_playertemp WHERE steamid = '%s' AND mapname = '%s';";

		// Get last psition
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

		// Set new start time
		float fl_time = SQL_FetchFloat(hndl, 6);
		int tickrate = RoundFloat(float(SQL_FetchInt(hndl, 7)) / 5.0 / 11.0);
		if (tickrate == g_iTickrate)
		{
			if (fl_time > 0.0)
			{
				g_fStartTime[data] = GetClientTickTime(data) - fl_time;
				g_bTimerRunning[data] = true;
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

		g_bTimerRunning[data] = false;
	}
}

/*===================================
=            CHECKPOINTS            =
===================================*/

public void db_viewRecordCheckpointInMap()
{
	for (int k = 0; k < MAXZONEGROUPS; k++)
	{
		g_bCheckpointRecordFound[k] = false;
		for (int i = 0; i < CPLIMIT; i++)
		g_fCheckpointServerRecord[k][i] = 0.0;
	}

	// "SELECT c.zonegroup, c.cp1, c.cp2, c.cp3, c.cp4, c.cp5, c.cp6, c.cp7, c.cp8, c.cp9, c.cp10, c.cp11, c.cp12, c.cp13, c.cp14, c.cp15, c.cp16, c.cp17, c.cp18, c.cp19, c.cp20, c.cp21, c.cp22, c.cp23, c.cp24, c.cp25, c.cp26, c.cp27, c.cp28, c.cp29, c.cp30, c.cp31, c.cp32, c.cp33, c.cp34, c.cp35 FROM ck_checkpoints c WHERE steamid = '%s' AND mapname='%s' UNION SELECT a.zonegroup, b.cp1, b.cp2, b.cp3, b.cp4, b.cp5, b.cp6, b.cp7, b.cp8, b.cp9, b.cp10, b.cp11, b.cp12, b.cp13, b.cp14, b.cp15, b.cp16, b.cp17, b.cp18, b.cp19, b.cp20, b.cp21, b.cp22, b.cp23, b.cp24, b.cp25, b.cp26, b.cp27, b.cp28, b.cp29, b.cp30, b.cp31, b.cp32, b.cp33, b.cp34, b.cp35 FROM ck_bonus a LEFT JOIN ck_checkpoints b ON a.steamid = b.steamid AND a.zonegroup = b.zonegroup WHERE a.mapname = '%s' GROUP BY a.zonegroup";
	char szQuery[1028];
	Format(szQuery, 1028, sql_selectRecordCheckpoints, g_szRecordMapSteamID, g_szMapName, g_szMapName);
	SQL_TQuery(g_hDb, sql_selectRecordCheckpointsCallback, szQuery, GetGameTime(), DBPrio_Low);
}

public void sql_selectRecordCheckpointsCallback(Handle owner, Handle hndl, const char[] error, float time)
{
	LogQueryTime("[SurfTimer] : Finished sql_selectRecordCheckpointsCallback in: %f", GetGameTime() - time);
	
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (sql_selectRecordCheckpointsCallback): %s", error);
		if (!g_bServerDataLoaded)
			db_CalcAvgRunTime();
		return;
	}

	if (SQL_HasResultSet(hndl))
	{
		int zonegroup;
		int cp;

		while (SQL_FetchRow(hndl))
		{
			zonegroup = SQL_FetchInt(hndl, 0);
			cp = SQL_FetchInt(hndl, 1);

			if(zonegroup == 0) {
				g_fCheckpointServerRecord[zonegroup][cp-1] = SQL_FetchFloat(hndl, 2);
				if (!g_bCheckpointRecordFound[zonegroup] && g_fCheckpointServerRecord[zonegroup][cp-1] > 0.0)
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
	Format(szQuery, sizeof(szQuery), sql_selectCheckpoints, szMapName, szSteamID);
	SQL_TQuery(g_hDb, SQL_selectCheckpointsCallback, szQuery, client, DBPrio_Low);
}

public void SQL_selectCheckpointsCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	// fluffys come back
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (SQL_selectCheckpointsCallback): %s", error);
		if (!g_bSettingsLoaded[client])
			LoadClientSetting(client, g_iSettingToLoad[client]);
		return;
	}

	if (!IsValidClient(client))
		return;

	if (SQL_HasResultSet(hndl))
	{	

		int zoneGrp;
		int cp;

		while (SQL_FetchRow(hndl))
		{
			zoneGrp = SQL_FetchInt(hndl, 0);
			g_bCheckpointsFound[zoneGrp][client] = true;
			
			cp = SQL_FetchInt(hndl, 1);
			g_fCheckpointTimesRecord[zoneGrp][client][cp-1] = SQL_FetchFloat(hndl, 2);
		}
	}

	if (!g_bSettingsLoaded[client])
	{
		g_fTick[client][1] = GetGameTime();
		float tick = g_fTick[client][1] - g_fTick[client][0];
		LogQueryTime("[SurfTimer] %s: Finished db_viewCheckpoints in %fs", g_szSteamID[client], tick);
		LoadClientSetting(client, g_iSettingToLoad[client]);
	}

}

public void db_LoadCCP(int client)
{
	db_LoadCCP_StageTimes(client);
}

public void db_LoadCCP_StageTimes(int client)
{
	char szQuery[1024];
	Format(szQuery, sizeof(szQuery), sql_selectStageTimes, g_szMapName, g_szSteamID[client]);
	SQL_TQuery(g_hDb, SQL_LoadCCP_StageTimesCallback, szQuery, client, DBPrio_Low);
}

public void SQL_LoadCCP_StageTimesCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (SQL_LoadCCP_StageTimesCallback): %s", error);
		if (!g_bSettingsLoaded[client])
			LoadClientSetting(client, g_iSettingToLoad[client]);
		return;
	}

	if (!IsValidClient(client))
		return;

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		g_bStageTimesFound[client] = true;
		while (SQL_FetchRow(hndl))
		{
			int cp;
			cp = SQL_FetchInt(hndl, 0);
			g_fCCPStageTimesRecord[client][cp-1] = SQL_FetchFloat(hndl, 1);
		}
	}

	db_LoadStageAttempts(client);

}

public void db_LoadStageAttempts(int client){

	char szQuery[1024];
	Format(szQuery, sizeof(szQuery), sql_selectStageAttempts, g_szMapName, g_szSteamID[client]);
	SQL_TQuery(g_hDb, SQL_LoadStageAttemptsCallback, szQuery, client, DBPrio_Low);

}

public void SQL_LoadStageAttemptsCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (SQL_LoadStageAttemptsCallback): %s", error);
		if (!g_bSettingsLoaded[client])
			LoadClientSetting(client, g_iSettingToLoad[client]);
		return;
	}

	if (!IsValidClient(client))
		return;

	if (SQL_HasResultSet(hndl) )
	{
		while (SQL_FetchRow(hndl))
		{	
			g_bStageAttemptsFound[client] = true;

			int cp = SQL_FetchInt(hndl, 0);
			g_iCCPStageAttemptsRecord[client][cp-1] = SQL_FetchInt(hndl, 1);
		}
	}

	if (!g_bSettingsLoaded[client])
	{
		g_fTick[client][1] = GetGameTime();
		float tick = g_fTick[client][1] - g_fTick[client][0];
		LogQueryTime("[SurfTimer] %s: Finished db_LoadCCP in %fs", g_szSteamID[client], tick);
		LoadClientSetting(client, g_iSettingToLoad[client]);
	}
}

public void db_viewReplayCPTicks(char szMapName[128])
{
	char szQuery[1024];

	for(int style = 0; style < MAX_STYLES; style++){
		g_bReplayTickFound[style] = false;

		Format(szQuery, sizeof(szQuery), sql_selectReplayCPTicksAll, szMapName, style);
		DataPack pack = new DataPack()
		pack.WriteCell(style);
		pack.WriteFloat(GetGameTime());
		SQL_TQuery(g_hDb, SQL_selectReplayCPTicksCallback, szQuery, pack, DBPrio_Low);
	}
}

public void SQL_selectReplayCPTicksCallback(Handle owner, Handle hndl, const char[] error, DataPack pack)
{
	pack.Reset();
	int iStyle = pack.ReadCell();
	float fTime = pack.ReadFloat();
	delete pack;

	LogQueryTime("[SurfTimer] : Finished SQL_selectReplayCPTicksCallback for %s in: %f", g_EditStyles[iStyle], GetGameTime() - fTime);

	// fluffys come back
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (SQL_selectReplayCPTicksCallback): %s", error);
		if (!g_bServerDataLoaded)
			loadAllClientSettings();
		return;
	}

	if (SQL_HasResultSet(hndl))
	{
		int cp;
		int frame;
		int style;

		while(SQL_FetchRow(hndl)){
			cp = SQL_FetchInt(hndl, 0);
			frame = SQL_FetchInt(hndl, 1);
			style = SQL_FetchInt(hndl, 2);

			g_iCPStartFrame[style][cp-1] = frame;

			if (!g_bReplayTickFound[style] && g_iCPStartFrame[style][cp - 1] > 0)
				g_bReplayTickFound[style] = true;
		}
	}
	else{
		for(int i = 0; i < MAX_STYLES; i++)
			for(int j = 0; j < CPLIMIT; j++)
				g_iCPStartFrame[i][j] = 0;
	}
	
	if (!g_bServerDataLoaded)
	{
		g_fServerLoading[1] = GetGameTime();
		g_bHasLatestID = true;
		float time = g_fServerLoading[1] - g_fServerLoading[0];
		LogQueryTime("[SurfTimer] Finished loading server settings in %fs", time);
		loadAllClientSettings();
	} 
}

public void db_UpdateReplaysTick(int client, int style){
	char szQuery[1024];

	int cp_count;
	if(!g_bhasStages)
		cp_count = g_iTotalCheckpoints;
	else
		cp_count = g_TotalStages - 1;

	Transaction TicksTransaction = new Transaction();

	if(!g_bReplayTickFound[style]){
		g_bReplayTickFound[style] = true;
		for(int i = 0; i < cp_count; i++){
			Format(szQuery, sizeof(szQuery), sql_insertReplayCPTicks, g_szMapName, i+1, g_iCPStartFrame[style][i], style);
			TicksTransaction.AddQuery(szQuery);
		}
	}
	else{
		for(int i = 0; i < cp_count; i++){
			Format(szQuery, sizeof(szQuery), sql_updateReplayCPTicks, g_iCPStartFrame[style][i], g_szMapName, i+1, style);
			TicksTransaction.AddQuery(szQuery);
		}
	}

	SQL_ExecuteTransaction(g_hDb, TicksTransaction, db_TicksTransactionOnSuccess, db_TicksTransactionOnFailure, _, DBPrio_Low);

}

public void db_TicksTransactionOnSuccess(Handle db, any pack, int numQueries, Handle[] results, any[] queryData)
{
	PrintToServer("[SurfTimer] Transaction Sucessfully Done!");
}

public void db_TicksTransactionOnFailure(Handle db, any pack, int numQueries, const char[] error, int failIndex, any[] queryData)
{
	LogError("[SurfTimer] SQL Error (db_TicksTransactionOnFailure): %s", error);
}

public void db_viewCheckpointsinZoneGroup(int client, char szSteamID[32], char szMapName[128], int zonegroup)
{
	char szQuery[1024];
	// "SELECT cp1, cp2, cp3, cp4, cp5, cp6, cp7, cp8, cp9, cp10, cp11, cp12, cp13, cp14, cp15, cp16, cp17, cp18, cp19, cp20, cp21, cp22, cp23, cp24, cp25, cp26, cp27, cp28, cp29, cp30, cp31, cp32, cp33, cp34, cp35 FROM ck_checkpoints WHERE mapname='%s' AND steamid = '%s' AND zonegroup = %i;";
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
		LogError("[SurfTimer] SQL Error (db_viewCheckpointsinZoneGroupCallback): %s", error);
		return;
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	int zonegrp = ReadPackCell(pack);
	CloseHandle(pack);

	if (!IsValidClient(client))
		return;

	if (SQL_HasResultSet(hndl))
	{	
		int cp;

		while(SQL_FetchRow(hndl)){
			g_bCheckpointsFound[zonegrp][client] = true;
			
			cp = SQL_FetchInt(hndl, 0);

			g_fCheckpointTimesRecord[zonegrp][client][cp-1] = SQL_FetchFloat(hndl, 1);
		}
		if(g_bhasStages)
			db_LoadCCP(client);
	}
	else
	{
		g_bCheckpointsFound[zonegrp][client] = false;
	}
}

public void db_InsertOrUpdateCheckpoints(int client, char szSteamID[32], int zGroup)
{
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackCell(pack, zGroup);

	int cp_count;
	if(!g_bhasStages)
		cp_count = g_iTotalCheckpoints;
	else
		cp_count = g_TotalStages - 1;
	
	cp_count += 1;

	char szQuery[1024];
	Transaction tAction = new Transaction();

	for (int i = 0; i < cp_count; i++) {
		if(g_bhasStages)
			Format(szQuery, sizeof(szQuery), sql_InsertOrUpdateCheckpoints, szSteamID, g_szMapName, i+1, g_fCheckpointTimesNew[zGroup][client][i], g_fStageTimesNew[client][i], g_iStageAttemptsNew[client][i], zGroup, g_fCheckpointTimesNew[zGroup][client][i], g_fStageTimesNew[client][i], g_iStageAttemptsNew[client][i]);
		else
			Format(szQuery, sizeof(szQuery), sql_InsertOrUpdateCheckpoints, szSteamID, g_szMapName, i+1, g_fCheckpointTimesNew[zGroup][client][i], -1.0, -1, zGroup, g_fCheckpointTimesNew[zGroup][client][i], -1.0, -1);
		
		tAction.AddQuery(szQuery);
	}

	SQL_ExecuteTransaction(g_hDb, tAction, db_UpdateCheckpointsOnSuccess, db_UpdateCheckpointsOnFailure, pack, DBPrio_Low);
}

public void db_UpdateCheckpointsOnSuccess(Handle db, any pack, int numQueries, Handle[] results, any[] queryData)
{
	ResetPack(pack);
	int client = ReadPackCell(pack);
	int zonegrp = ReadPackCell(pack);
	CloseHandle(pack);
	
  	db_viewCheckpointsinZoneGroup(client, g_szSteamID[client], g_szMapName, zonegrp);
}

public void db_UpdateCheckpointsOnFailure(Handle db, any pack, int numQueries, const char[] error, int failIndex, any[] queryData)
{
	LogError("[SurfTimer] SQL Error (db_UpdateCheckpointsOnFailure): %s", error);
	CloseHandle(pack);
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
		LogError("[SurfTimer] SQL Error (SQL_deleteCheckpointsCallback): %s", error);
		return;
	}
}

public void db_viewPRinfo(int client, char szSteamID[32], char szMapName[128])
{
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, szSteamID);
	WritePackString(pack, szMapName);

	if (!IsValidClient(client))
		return;

	char szQuery[1024];
	Format(szQuery, 1024, sql_selectPR, szSteamID, szMapName, 0);
	//PrintToConsole(client,szQuery);
	SQL_TQuery(g_hDb, db_viewPRinfoCallback, szQuery, pack, DBPrio_Low);
}

public void db_viewPRinfoCallback(Handle owner, Handle hndl, const char[] error, DataPack pack)
{	

	ResetPack(pack);
	int client = ReadPackCell(pack);

	char szSteamID[32];
	ReadPackString(pack, szSteamID, 32);
	
	char szMapName[32];
	ReadPackString(pack, szMapName, 32);

	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (db_viewPRinfoCallback): %s", error);
		CloseHandle(pack);
		return;
	}

	if (!IsValidClient(client)){
		CloseHandle(pack);
		return;
	}

	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)){

		CloseHandle(pack);

		g_fTimeinZone[client][0] = SQL_FetchFloat(hndl, 4);
		g_fCompletes[client][0] = SQL_FetchFloat(hndl, 5);
		g_fAttempts[client][0] = SQL_FetchFloat(hndl, 6);
		g_fstComplete[client][0] = SQL_FetchFloat(hndl, 7);

	}
	else{
		char szQuery[1024];

		g_fTimeinZone[client][0] = 0.0;
		g_fCompletes[client][0] = 0.0;
		g_fAttempts[client][0] = 0.0;
		g_fstComplete[client][0] = 0.0;

		Format(szQuery, 1024, "SELECT runtimepro FROM ck_playertimes WHERE steamid = '%s' AND style = 0 AND mapname = '%s';", szSteamID, szMapName);
		//PrintToConsole(client,szQuery);
		SQL_TQuery(g_hDb, db_prinforuntimecallback, szQuery, pack, DBPrio_Low);
	}

	//SETUP BONUS PRINFO
	if(g_bhasBonus){
		db_viewBonusPRinfo(client, szSteamID, szMapName);
	}
	else{
		if (!g_bSettingsLoaded[client])
		{
			g_fTick[client][1] = GetGameTime();
			float tick = g_fTick[client][1] - g_fTick[client][0];
			LogQueryTime("[SurfTimer] %s: Finished db_viewPRinfo in %fs", g_szSteamID[client], tick);
			g_fTick[client][0] = GetGameTime();

			// Print a VIP's custom join msg to all
			if (g_bEnableJoinMsgs && !StrEqual(g_szCustomJoinMsg[client], "none") && IsPlayerVip(client, true, false))
				CPrintToChatAll("%s", g_szCustomJoinMsg[client]);

			// CalculatePlayerRank(client);
			g_bSettingsLoaded[client] = true;
			g_bLoadingSettings[client] = false;

			db_UpdateLastSeen(client);

			if (GetConVarBool(g_hTeleToStartWhenSettingsLoaded))
			{
				Command_Restart(client, 1);
				CreateTimer(0.1, RestartPlayer, client);
			}

			// Seach for next client to load
			for (int i = 1; i < MAXPLAYERS + 1; i++)
			{
				if (IsValidClient(i) && !IsFakeClient(i) && !g_bSettingsLoaded[i] && !g_bLoadingSettings[i])
				{
					szSteamID = "";
					GetClientAuthId(i, AuthId_Steam2, szSteamID, 32, true);
					g_iSettingToLoad[i] = 0;
					LoadClientSetting(i, g_iSettingToLoad[i]);
					g_bLoadingSettings[i] = true;
					break;
				}
			}

			float time = g_fTick[client][1] - g_fClientsLoading[client][0];
			char szName[32];
			GetClientName(client, szName, sizeof(szName));
			LogQueryTime("[SurfTimer] Finished loading %s - %s settings in %fs", g_szSteamID[client], szName, time);
		}
	}

	return;
}

public void db_prinforuntimecallback(Handle owner, Handle hndl, const char[] error, DataPack pack)
{

	ResetPack(pack);
	int client = ReadPackCell(pack);

	char szSteamID[32];
	ReadPackString(pack, szSteamID, 32);

	char szMapName[32];
	ReadPackString(pack, szMapName, 32);
	CloseHandle(pack);

	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (db_prinforuntimecallback): %s", error);
		return;
	}

	if (!IsValidClient(client)){
		return;
	}

	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)){

		float runtime = SQL_FetchFloat(hndl, 0);

		// Escape name for SQL injection protection
		char szName[MAX_NAME_LENGTH * 2 + 1], szUName[MAX_NAME_LENGTH];
		GetClientName(client, szUName, MAX_NAME_LENGTH);
		SQL_EscapeString(g_hDb, szUName, szName, MAX_NAME_LENGTH);

		char szQuery[1024];
		Format(szQuery, sizeof(szQuery), sql_insertPR, szSteamID, szName, szMapName, runtime, 0, 0.0, 0.0, 0.0, 0.0);
		SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, _, DBPrio_Low);
	}
	else{

		// Escape name for SQL injection protection
		char szName[MAX_NAME_LENGTH * 2 + 1], szUName[MAX_NAME_LENGTH];
		GetClientName(client, szUName, MAX_NAME_LENGTH);
		SQL_EscapeString(g_hDb, szUName, szName, MAX_NAME_LENGTH);


		char szQuery[1024];
		Format(szQuery, sizeof(szQuery), sql_insertPR, szSteamID, szName, szMapName, 0.0, 0, 0.0, 0.0, 0.0, 0.0);
		SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, _, DBPrio_Low);
	}

	return;
}

public void db_viewBonusPRinfo(int client, char szSteamID[32], char szMapName[32])
{

	char szQuery[1024];

	if (!IsValidClient(client))
		return;

	for(int zonegroup = 1; zonegroup < g_mapZoneGroupCount; zonegroup++){
		Format(szQuery, sizeof(szQuery), sql_selectBonusPR, szSteamID, szMapName, zonegroup);
		//PrintToConsole(client,szQuery);

		Handle pack = CreateDataPack();
		WritePackCell(pack, client);
		WritePackString(pack, szSteamID);
		WritePackString(pack, szMapName);
		WritePackCell(pack, zonegroup);

		SQL_TQuery(g_hDb, db_viewBonusPRinfoCallback, szQuery, pack, DBPrio_Low);
	}
}

public void db_viewBonusPRinfoCallback(Handle owner, Handle hndl, const char[] error, DataPack pack)
{	

	ResetPack(pack);
	int client = ReadPackCell(pack);

	char szSteamID[32];
	ReadPackString(pack, szSteamID, 32);

	char szMapName[32];
	ReadPackString(pack, szMapName, 32);

	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (db_viewBonusPRinfoCallback): %s", error);
		CloseHandle(pack);
		return;
	}

	if (!IsValidClient(client)){
		CloseHandle(pack);
		return;
	}

	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)){

			CloseHandle(pack);

			int zonegroup = SQL_FetchInt(hndl, 3);

			g_fTimeinZone[client][zonegroup] = SQL_FetchFloat(hndl, 4);
			g_fCompletes[client][zonegroup] = SQL_FetchFloat(hndl, 5);
			g_fAttempts[client][zonegroup] = SQL_FetchFloat(hndl, 6);
			g_fstComplete[client][zonegroup] = SQL_FetchFloat(hndl, 7);
			
	}
	else{
		char szQuery[1024];

		int zonegroup = ReadPackCell(pack);

		g_fTimeinZone[client][zonegroup] = 0.0;
		g_fCompletes[client][zonegroup] = 0.0;
		g_fAttempts[client][zonegroup] = 0.0;
		g_fstComplete[client][zonegroup] = 0.0;
		
		Format(szQuery, 1024, "SELECT runtime, zonegroup FROM ck_bonus WHERE steamid = '%s' AND mapname = '%s' AND zonegroup = '%i';", szSteamID, szMapName, zonegroup);
		//PrintToConsole(client,szQuery);

		SQL_TQuery(g_hDb, db_bonusprinforuntimecallback, szQuery, pack, DBPrio_Low);
	}

	if (!g_bSettingsLoaded[client])
	{
		g_fTick[client][1] = GetGameTime();
		float tick = g_fTick[client][1] - g_fTick[client][0];
		LogQueryTime("[SurfTimer] %s: Finished db_viewPRinfo in %fs", g_szSteamID[client], tick);
		g_fTick[client][0] = GetGameTime();

		// Print a VIP's custom join msg to all
		if (g_bEnableJoinMsgs && !StrEqual(g_szCustomJoinMsg[client], "none") && IsPlayerVip(client, true, false))
			CPrintToChatAll("%s", g_szCustomJoinMsg[client]);

		// CalculatePlayerRank(client);
		g_bSettingsLoaded[client] = true;
		g_bLoadingSettings[client] = false;

		db_UpdateLastSeen(client);

		if (GetConVarBool(g_hTeleToStartWhenSettingsLoaded))
		{
			Command_Restart(client, 1);
			CreateTimer(0.1, RestartPlayer, client);
		}

		// Seach for next client to load
		for (int i = 1; i < MAXPLAYERS + 1; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i) && !g_bSettingsLoaded[i] && !g_bLoadingSettings[i])
			{
				szSteamID = "";
				GetClientAuthId(i, AuthId_Steam2, szSteamID, 32, true);
				g_iSettingToLoad[i] = 0;
				LoadClientSetting(i, g_iSettingToLoad[i]);
				g_bLoadingSettings[i] = true;
				break;
			}
		}

		float time = g_fTick[client][1] - g_fClientsLoading[client][0];
		char szName[32];
		GetClientName(client, szName, sizeof(szName));
		LogQueryTime("[SurfTimer] Finished loading %s - %s settings in %fs", g_szSteamID[client], szName, time);
	}

	return;
}

public void db_bonusprinforuntimecallback(Handle owner, Handle hndl, const char[] error, DataPack pack)
{

	ResetPack(pack);
	int client = ReadPackCell(pack);

	char szSteamID[32];
	ReadPackString(pack, szSteamID, 32);

	char szMapName[32];
	ReadPackString(pack, szMapName, 32);

	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (db_prinforuntimecallback): %s", error);
		CloseHandle(pack);
		return;
	}

	if (!IsValidClient(client)){
		CloseHandle(pack);
		return;
	}

	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)){
		//PrintToConsole(client,"ALREADY EXISTS");

		float runtime;
		int zonegroup;

		// Escape name for SQL injection protection
		char szName[MAX_NAME_LENGTH * 2 + 1], szUName[MAX_NAME_LENGTH];
		GetClientName(client, szUName, MAX_NAME_LENGTH);
		SQL_EscapeString(g_hDb, szUName, szName, MAX_NAME_LENGTH);
		
		char szQuery[1024];
		runtime = SQL_FetchFloat(hndl, 0);
		zonegroup = SQL_FetchInt(hndl, 1);

		Format(szQuery, sizeof(szQuery), sql_insertPR, szSteamID, szName, szMapName, runtime, zonegroup, 0.0, 0.0, 0.0, 0.0);
		SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, _, DBPrio_Low);

	}
	else{
		//PrintToConsole(client,"NEW ENTRY");

		// Escape name for SQL injection protection
		char szName[MAX_NAME_LENGTH * 2 + 1], szUName[MAX_NAME_LENGTH];
		GetClientName(client, szUName, MAX_NAME_LENGTH);
		SQL_EscapeString(g_hDb, szUName, szName, MAX_NAME_LENGTH);

		int zonegroup = ReadPackCell(pack);

		char szQuery[1024];

		Format(szQuery, sizeof(szQuery), sql_insertPR, szSteamID, szName, szMapName, 0.0, zonegroup, 0.0, 0.0, 0.0, 0.0);
		SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, _, DBPrio_Low);

	}

	CloseHandle(pack);
	return;
}

public void db_UpdatePRinfo_WithRuntime(int client, char szSteamID[32], int zGroup, float runtime)
{	
	if (!IsValidClient(client))
		return;

	char szQuery[2048];
	//PrintToConsole(client, "%f || %f || %f || %f || %f\n", g_fTimeinZone[client][zGroup], g_fCompletes[client][zGroup], g_fAttempts[client][zGroup], g_fstComplete[client][zGroup], runtime);
	Format(szQuery, sizeof(szQuery), sql_updatePrinfo_withruntime, g_fTimeinZone[client][zGroup], g_fCompletes[client], g_fAttempts[client][zGroup], g_fstComplete[client][zGroup], runtime, szSteamID, g_szMapName, zGroup);
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, .prio=DBPrio_Low);
}
//this is called whenever the player's time stops and he is not in a end zone (map/bonus/stage)
public void db_UpdatePRinfo(int client, char szSteamID[32], int zGroup)
{	
	if (!IsValidClient(client))
		return;

	char szQuery[2048];
	//PrintToConsoleAll("%f || %f || %f || %f\n", g_fTimeinZone[client][zGroup], g_fCompletes[client][zGroup], g_fAttempts[client][zGroup], g_fstComplete[client][zGroup]);
	Format(szQuery, sizeof(szQuery), sql_updatePrinfo, g_fTimeinZone[client][zGroup], g_fCompletes[client][zGroup], g_fAttempts[client][zGroup], g_fstComplete[client][zGroup], szSteamID, g_szMapName, zGroup);
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, .prio=DBPrio_Low);
}

/*===================================
=              MAPTIER              =
===================================*/

public void db_insertMapperName(int client, char arg1[64])
{	
	char szQuery[256];

	if (!g_bTierEntryFound)
	{
		CReplyToCommand(client, "%t", "NoTierEntry", g_szChatPrefix);
		return;
	}
	if (g_bMapperNameFound)
	{
		CReplyToCommand(client, "%t", "UpdateMapperName", g_szChatPrefix, arg1);
		Format(szQuery, sizeof(szQuery), sql_updateMapperName, arg1, g_szMapName);
		SQL_TQuery(g_hDb, db_insertMapperNameCallback, szQuery, 1, DBPrio_Low);
	}
	else
	{	
		CReplyToCommand(client, "%t", "InsertMapperName", g_szChatPrefix, arg1);
		Format(szQuery, sizeof(szQuery), sql_updateMapperName, arg1, g_szMapName);
		SQL_TQuery(g_hDb, db_insertMapperNameCallback, szQuery, 1, DBPrio_Low);
	}
}

public void db_insertMapperNameCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[Surftimer] SQL Error (db_insertMapperNameCallback): %s", error);
		return;
	}

	db_selectMapTier();
}

public void db_insertMapTier(int tier)
{
	char szQuery[256];
	if (g_bTierEntryFound)
	{
		Format(szQuery, sizeof(szQuery), sql_updatemaptier, tier, g_szMapName);
		SQL_TQuery(g_hDb, db_insertMapTierCallback, szQuery, 1, DBPrio_Low);
	}
	else
	{
		Format(szQuery, sizeof(szQuery), sql_insertmaptier, g_szMapName, tier);
		SQL_TQuery(g_hDb, db_insertMapTierCallback, szQuery, 1, DBPrio_Low);
	}
}

public void db_insertMapTierCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (db_insertMapTierCallback): %s", error);
		return;
	}

	db_selectMapTier();
}

//USED WHEN ( sm_ccp <map> )
//CHECK IF THE MAP REQUESTED FOR CCP IS LINEAR OR NOT
public void isLinear(int client, char szSteamID[32], char szMapName[32])
{
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, szSteamID);
	WritePackString(pack, szMapName);

	char szQuery[1024];
	Format(szQuery, 1024, "SELECT COUNT(zonetype) FROM ck_zones WHERE mapname LIKE '%s' AND zonetype = 3;", szMapName);
	SQL_TQuery(g_hDb, SQL_isLinearCallback, szQuery, pack, DBPrio_Low);
}

public void SQL_isLinearCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (SQL_selectMapTierCallback): %s", error);
		CloseHandle(data);
		return;
	}

	ResetPack(data);
	int client = ReadPackCell(data);
	char szSteamID[32];
	char szMapName[128];
	ReadPackString(data, szSteamID, sizeof(szSteamID));
	ReadPackString(data, szMapName, sizeof(szMapName));
	CloseHandle(data);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)){

		int stages = SQL_FetchInt(hndl, 0);

		//IF THE MAP HAS STAGE ZONES
		if(stages > 0){
			//GET PLAYERS RANK
			db_viewCCP_GetMapRank(client, szSteamID, szMapName);
		}
		else
			CPrintToChat(client, "%t", "CCP_01", g_szChatPrefix);
	}
	
}

public void db_selectMapTier()
{
	g_bTierEntryFound = false;

	char szQuery[1024];
	Format(szQuery, 1024, sql_selectMapTier, g_szMapName);
	SQL_TQuery(g_hDb, SQL_selectMapTierCallback, szQuery, GetGameTime(), DBPrio_Low);
}

public void SQL_selectMapTierCallback(Handle owner, Handle hndl, const char[] error, float time)
{
	LogQueryTime("[SurfTimer] : Finished SQL_selectMapTierCallback in: %f", GetGameTime() - time);
	
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (SQL_selectMapTierCallback): %s", error);
		if (!g_bServerDataLoaded)
			db_viewRecordCheckpointInMap();
		return;
	}
	g_bRankedMap = false;

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		g_bTierEntryFound = true;
		int tier;

		// Format tier string
		tier = SQL_FetchInt(hndl, 0);
		g_bRankedMap = view_as<bool>(SQL_FetchInt(hndl, 1));

		if (SQL_IsFieldNull(hndl, 2))
		{
			g_szMapperName = "N/A";
			g_bMapperNameFound = false;
		}
		else
		{
			SQL_FetchString(hndl, 2, g_szMapperName, sizeof(g_szMapperName));
			g_bMapperNameFound = true;
		}

		if (0 < tier < 9)
		{
			g_bTierFound = true;
			g_iMapTier = tier;
			if (g_bMapperNameFound)
			{	
				Format(g_sTierString, 512, "%c%s \x01by \x03%s %c- ", BLUE, g_szMapName, g_szMapperName, WHITE);
			}
			else
			{
				Format(g_sTierString, 512, "%c%s %c- ", BLUE, g_szMapName, WHITE);
			}

			switch (tier)
			{
				case 1:Format(g_sTierString, 512, "%s%cTier %i %c- ", g_sTierString, GRAY, tier, WHITE);
				case 2:Format(g_sTierString, 512, "%s%cTier %i %c- ", g_sTierString, LIGHTBLUE, tier, WHITE);
				case 3:Format(g_sTierString, 512, "%s%cTier %i %c- ", g_sTierString, BLUE, tier, WHITE);
				case 4:Format(g_sTierString, 512, "%s%cTier %i %c- ", g_sTierString, DARKBLUE, tier, WHITE);
				case 5:Format(g_sTierString, 512, "%s%cTier %i %c- ", g_sTierString, RED, tier, WHITE);
				case 6:Format(g_sTierString, 512, "%s%cTier %i %c- ", g_sTierString, DARKRED, tier, WHITE);
				case 7:Format(g_sTierString, 512, "%s%cTier %i %c- ", g_sTierString, ORCHID, tier, WHITE);
				case 8:Format(g_sTierString, 512, "%s%cTier %i %c- ", g_sTierString, PURPLE, tier, WHITE);
				default:Format(g_sTierString, 512, "%s%cTier %i %c- ", g_sTierString, GRAY, tier, WHITE);
			}
			if (g_bhasStages)
				Format(g_sTierString, 512, "%s%c%i Stages", g_sTierString, LIGHTGREEN, (g_mapZonesTypeCount[0][3] + 1));
			else
				Format(g_sTierString, 512, "%s%cLinear", g_sTierString, LIMEGREEN);

			if (g_bhasBonus)
				if (g_mapZoneGroupCount > 2)
					Format(g_sTierString, 512, "%s %c-%c %i Bonuses", g_sTierString, WHITE, ORANGE, (g_mapZoneGroupCount - 1));
				else
					Format(g_sTierString, 512, "%s %c-%c Bonus", g_sTierString, WHITE, ORANGE, (g_mapZoneGroupCount - 1));
		}
	}
	else
	g_bTierEntryFound = false;

	if (!g_bServerDataLoaded)
		db_viewRecordCheckpointInMap();

	return;
}

/*===================================
=             SQL Bonus             =
===================================*/

public void db_currentBonusRunRank(int client, int style, int zGroup)
{
	char szQuery[512];
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackCell(pack, zGroup);

	float runtime = g_fCurrentRunTime[client];

	Format(szQuery, 512, "SELECT count(runtime)+1 FROM ck_bonus WHERE mapname = '%s' AND zonegroup = '%i' AND runtime < '%f' AND style = '%i';", g_szMapName, zGroup, runtime, style);
	SQL_TQuery(g_hDb, db_viewBonusRunRank, szQuery, pack, DBPrio_Low);
}

public void db_viewBonusRunRank(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (db_viewBonusRunRank): %s", error);
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

	if(g_bPracticeModeRun[client])
	{
		float runtime = g_fCurrentRunTime[client];
		char sz_srDiff[128];
		float f_srDiff;

		if(g_fBonusFastest[g_iClientInZone[client][2]] != 9999999.0)
			f_srDiff = (g_fBonusFastest[g_iClientInZone[client][2]] - runtime);
		else
			f_srDiff = runtime;

		FormatTimeFloat(client, f_srDiff, 3, sz_srDiff, 128);

		if(f_srDiff == runtime)
			Format(sz_srDiff, 128, "SR: N/A", sz_srDiff);
		else if (f_srDiff > 0.0)
			Format(sz_srDiff, 128, "%cSR: %c-%s%c", WHITE, LIGHTGREEN, sz_srDiff, WHITE);
		else if(f_srDiff <= 0.0)
			Format(sz_srDiff, 128, "%cSR: %c+%s%c", WHITE, RED, sz_srDiff, WHITE);

		char szSpecMessage[512];
		
		CPrintToChat(client, "%t", "BPress4", g_szChatPrefix, zGroup, g_szPracticeTime[client], sz_srDiff, rank);
		Format(szSpecMessage, sizeof(szSpecMessage), "%t", "BPress4", g_szChatPrefix, zGroup, g_szPracticeTime[client], sz_srDiff, rank);

		CheckpointToSpec(client, szSpecMessage);
	}
	else
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
		LogError("[SurfTimer] SQL Error (db_viewMapRankBonusCallback): %s", error);
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

		char szUName[MAX_NAME_LENGTH * 2 + 1];
		GetClientName(client,szUName, MAX_NAME_LENGTH * 2 + 1);

		char szName[MAX_NAME_LENGTH * 2 + 1];
		SQL_EscapeString(g_hDb, szUName, szName, MAX_NAME_LENGTH * 2 + 1);

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

// Get player rank in bonus - current map
public void db_viewPersonalBonusRecords(int client, char szSteamId[32])
{
	char szQuery[1024];
	// "SELECT runtime, zonegroup, style FROM ck_bonus WHERE steamid = '%s AND mapname = '%s' AND runtime > '0.0'";
	Format(szQuery, 1024, sql_selectPersonalBonusRecords, szSteamId, g_szMapName);
	SQL_TQuery(g_hDb, SQL_selectPersonalBonusRecordsCallback, szQuery, client, DBPrio_Low);
}

public void SQL_selectPersonalBonusRecordsCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (SQL_selectPersonalBonusRecordsCallback): %s", error);
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
		LogQueryTime("[SurfTimer] %s: Finished db_viewPersonalBonusRecords in %fs", g_szSteamID[client], tick);
		g_fTick[client][0] = GetGameTime();

		LoadClientSetting(client, g_iSettingToLoad[client]);
	}
	return;
}

public void db_viewFastestBonus()
{
	char szQuery[1024];
	// SELECT name, MIN(runtime), zonegroup, style FROM ck_bonus WHERE mapname = '%s' GROUP BY zonegroup, style;
	Format(szQuery, 1024, sql_selectFastestBonus, g_szMapName);
	SQL_TQuery(g_hDb, SQL_selectFastestBonusCallback, szQuery, GetGameTime(), DBPrio_High);
}

public void SQL_selectFastestBonusCallback(Handle owner, Handle hndl, const char[] error, float time)
{
	LogQueryTime("[SurfTimer] : Finished SQL_selectFastestBonusCallback in: %f", GetGameTime() - time);
	
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (SQL_selectFastestBonusCallback): %s", error);

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

		for (int s = 0; s < MAX_STYLES; s++)
		{
			if (s != 0)
			{
			Format(g_szStyleBonusFastestTime[s][i], 64, "N/A");
			g_fStyleBonusFastest[s][i] = 9999999.0;
			}

			g_iRecordPreStrafeBonus[0][i][s] = 0;
			g_iRecordPreStrafeBonus[1][i][s] = 0;
			g_iRecordPreStrafeBonus[2][i][s] = 0;
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

			g_iRecordPreStrafeBonus[0][zonegroup][style] = SQL_FetchInt(hndl, 4);
			g_iRecordPreStrafeBonus[1][zonegroup][style] = SQL_FetchInt(hndl, 5);
			g_iRecordPreStrafeBonus[2][zonegroup][style] = SQL_FetchInt(hndl, 6);
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
	// SELECT zonegroup, style, count(1) FROM ck_bonus WHERE mapname = '%s' GROUP BY zonegroup, style;
	Format(szQuery, 1024, sql_selectBonusCount, g_szMapName);
	SQL_TQuery(g_hDb, SQL_selectBonusTotalCountCallback, szQuery, GetGameTime(), DBPrio_Low);
}

public void SQL_selectBonusTotalCountCallback(Handle owner, Handle hndl, const char[] error, float time)
{
	LogQueryTime("[SurfTimer] : Finished SQL_selectBonusTotalCountCallback in: %f", GetGameTime() - time);
	
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (SQL_selectBonusTotalCountCallback): %s", error);
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

public void db_insertBonus(int client, char szSteamId[32], char szUName[128], float FinalTime, int zoneGrp)
{	
	if (g_bPracticeMode[client])
		return;
	
	char szQuery[1024];
	char szName[MAX_NAME_LENGTH * 2 + 1];
	SQL_EscapeString(g_hDb, szUName, szName, MAX_NAME_LENGTH * 2 + 1);
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackCell(pack, zoneGrp);
	Format(szQuery, 1024, sql_insertBonus, szSteamId, szName, g_szMapName, FinalTime, zoneGrp, g_iPreStrafeBonus[0][zoneGrp][0][client], g_iPreStrafeBonus[1][zoneGrp][0][client], g_iPreStrafeBonus[2][zoneGrp][0][client]);
	SQL_TQuery(g_hDb, SQL_insertBonusCallback, szQuery, pack, DBPrio_Low);
}

public void SQL_insertBonusCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (SQL_insertBonusCallback): %s", error);
		return;
	}

	ResetPack(data);
	int client = ReadPackCell(data);
	int zgroup = ReadPackCell(data);
	CloseHandle(data);

	db_viewMapRankBonus(client, zgroup, 1);
	// Change to update profile timer, if giving multiplier count or extra points for bonuses
	CalculatePlayerRank(client, 0);
}

public void db_updateBonus(int client, char szSteamId[32], char szUName[128], float FinalTime, int zoneGrp)
{	
	if (g_bPracticeMode[client])
		return;
	
	char szQuery[1024];
	char szName[MAX_NAME_LENGTH * 2 + 1];
	Handle datapack = CreateDataPack();
	WritePackCell(datapack, client);
	WritePackCell(datapack, zoneGrp);
	SQL_EscapeString(g_hDb, szUName, szName, MAX_NAME_LENGTH * 2 + 1);
	Format(szQuery, 1024, sql_updateBonus,FinalTime, szName, g_iPreStrafeBonus[0][zoneGrp][0][client], g_iPreStrafeBonus[1][zoneGrp][0][client], g_iPreStrafeBonus[2][zoneGrp][0][client], szSteamId, g_szMapName, zoneGrp);
	SQL_TQuery(g_hDb, SQL_updateBonusCallback, szQuery, datapack, DBPrio_Low);
}


public void SQL_updateBonusCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (SQL_updateBonusCallback): %s", error);
		return;
	}

	ResetPack(data);
	int client = ReadPackCell(data);
	int zgroup = ReadPackCell(data);
	CloseHandle(data);

	db_viewMapRankBonus(client, zgroup, 2);

	CalculatePlayerRank(client, 0);
}

public void SQL_deleteBonusCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (SQL_deleteBonusCallback): %s", error);
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
		LogError("[SurfTimer] SQL Error (SQL_selectBonusCountCallback): %s", error);
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

/*===================================
=             SQL Zones             =
===================================*/

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
		LogError("[SurfTimer] SQL Error (sql_setZoneNamesCallback): %s", error);
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
		if (g_mapZones[i].ZoneGroup == zonegrp)
		Format(g_mapZones[i].ZoneName, 64, szName);
	}

	if (IsValidClient(client))
	{
		CPrintToChat(client, "%t", "SQL4", g_szChatPrefix);
		ListBonusSettings(client);
	}
	db_selectMapZones();
}

public void db_checkAndFixZoneIds()
{
	char szQuery[512];
	// "SELECT mapname, zoneid, zonetype, zonetypeid, pointa_x, pointa_y, pointa_z, pointb_x, pointb_y, pointb_z, vis, team, zonegroup, zonename FROM ck_zones WHERE mapname = '%s' ORDER BY zoneid ASC";
	if (!g_szMapName[0])
	GetCurrentMap(g_szMapName, 128);

	Format(szQuery, 512, sql_selectZoneIds, g_szMapName);
	SQL_TQuery(g_hDb, db_checkAndFixZoneIdsCallback, szQuery, 1, DBPrio_Low);
}

public void db_checkAndFixZoneIdsCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (db_checkAndFixZoneIdsCallback): %s", error);
		return;
	}

	if (SQL_HasResultSet(hndl))
	{
		bool IDError = false;
		float x1[128], y1[128], z1[128], x2[128], y2[128], z2[128];
		int checker = 0, i, zonetype[128], zonetypeid[128], vis[128], team[128], zoneGrp[128];
		char zName[128][128];
		char hookname[128][128], targetname[128][128];
		int onejumplimit[128];
		float prespeed[128];

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
			SQL_FetchString(hndl, 14, hookname[checker], 128);
			SQL_FetchString(hndl, 15, targetname[checker], 128);
			onejumplimit[checker] = SQL_FetchInt(hndl, 16);
			prespeed[checker] = SQL_FetchFloat(hndl, 17);

			if (i != checker)
			IDError = true;

			checker++;
		}

		if (IDError)
		{
			char szQuery[256];
			Format(szQuery, sizeof(szQuery), sql_deleteMapZones, g_szMapName);
			SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, _, DBPrio_Low);
			// SQL_FastQuery(g_hDb, szQuery);

			for (int k = 0; k < checker; k++)
			{
				db_insertZoneCheap(k, zonetype[k], zonetypeid[k], x1[k], y1[k], z1[k], x2[k], y2[k], z2[k], vis[k], team[k], zoneGrp[k], zName[k], -10, hookname[k], targetname[k], onejumplimit[k], prespeed[k]);
			}
		}
	}
	db_selectMapZones();
}

public void ZoneDefaultName(int zonetype, int zonegroup, char zName[128])
{
	if (zonegroup > 0)
		Format(zName, sizeof(zName), "bonus %i", zonegroup);
	else
	if (-1 < zonetype < ZONEAMOUNT)
	Format(zName, sizeof(zName), "%s %i", g_szZoneDefaultNames[zonetype], zonegroup);
	else
	Format(zName, sizeof(zName), "Unknown");
}

public void db_insertZoneCheap(int zoneid, int zonetype, int zonetypeid, float pointax, float pointay, float pointaz, float pointbx, float pointby, float pointbz, int vis, int team, int zGrp, char zName[128], int query, char hookname[128], char targetname[128], int ojl, float prespeed)
{
	char szQuery[1024];
	// "INSERT INTO ck_zones (mapname, zoneid, zonetype, zonetypeid, pointa_x, pointa_y, pointa_z, pointb_x, pointb_y, pointb_z, vis, team, zonegroup, zonename) VALUES ('%s', '%i', '%i', '%i', '%f', '%f', '%f', '%f', '%f', '%f', '%i', '%i', '%i', '%s')";
	Format(szQuery, 1024, sql_insertZones, g_szMapName, zoneid, zonetype, zonetypeid, pointax, pointay, pointaz, pointbx, pointby, pointbz, vis, team, zGrp, zName, hookname, targetname, ojl, prespeed);
	SQL_TQuery(g_hDb, SQL_insertZonesCheapCallback, szQuery, query, DBPrio_Low);
}

public void SQL_insertZonesCheapCallback(Handle owner, Handle hndl, const char[] error, any query)
{
	if (hndl == null)
	{
		CPrintToChatAll("%t", "SQL5", g_szChatPrefix);
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

	// char sql_insertZones[] = "INSERT INTO ck_zones (mapname, zoneid, zonetype, zonetypeid, pointa_x, pointa_y, pointa_z, pointb_x, pointb_y, pointb_z, vis, team, zonegroup, zonename, hookname, targetname, onejumplimit, prespeed) VALUES ('%s', '%i', '%i', '%i', '%f', '%f', '%f', '%f', '%f', '%f', '%i', '%i', '%i','%s','%s','%s',%i,%f)";
	Format(szQuery, 1024, sql_insertZones, g_szMapName, zoneid, zonetype, zonetypeid, pointax, pointay, pointaz, pointbx, pointby, pointbz, vis, team, zonegroup, zName, "None", "player", 1, 250.0);
	SQL_TQuery(g_hDb, SQL_insertZonesCallback, szQuery, 1, DBPrio_Low);
}

public void SQL_insertZonesCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		CPrintToChatAll("%t", "SQL5", g_szChatPrefix);
		db_checkAndFixZoneIds();
		return;
	}

	db_selectMapZones();
}

public void db_insertZoneHook(int zoneid, int zonetype, int zonetypeid, int vis, int team, int zonegroup, char[] szHookName, float point_a[3], float point_b[3])
{
	char szQuery[1024];
	char zName[128];

	if (zonegroup == g_mapZoneGroupCount)
	ZoneDefaultName(zonetype, zonegroup, zName);
	else
	Format(zName, 128, g_szZoneGroupName[zonegroup]);

	// "INSERT INTO ck_zones (mapname, zoneid, zonetype, zonetypeid, pointa_x, pointa_y, pointa_z, pointb_x, pointb_y, pointb_z, vis, team, zonegroup, zonename) VALUES ('%s', '%i', '%i', '%i', '%f', '%f', '%f', '%f', '%f', '%f', '%i', '%i', '%i', '%s')";
	Format(szQuery, 1024, "INSERT INTO ck_zones (mapname, zoneid, zonetype, zonetypeid, pointa_x, pointa_y, pointa_z, pointb_x, pointb_y, pointb_z, vis, team, zonegroup, zonename, hookname) VALUES ('%s', '%i', '%i', '%i', '%f', '%f', '%f', '%f', '%f', '%f', '%i', '%i', '%i','%s','%s')", g_szMapName, zoneid, zonetype, zonetypeid, point_a[0], point_a[1], point_a[2], point_b[0], point_b[1], point_b[2], vis, team, zonegroup, zName, szHookName);
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
		LogError("[SurfTimer] SQL Error (SQL_saveZonesCallBack): %s", error);
		return;
	}
	char szzone[128];
	char hookname[128], targetname[128];
	for (int i = 0; i < g_mapZonesCount; i++)
	{
		Format(szzone, 128, "%s", g_szZoneGroupName[g_mapZones[i].ZoneGroup]);
		Format(hookname, 128, "%s", g_mapZones[i].HookName);
		Format(targetname, 128, "%s", g_mapZones[i].TargetName);

		if (g_mapZones[i].PointA[0] != -1.0 && g_mapZones[i].PointA[1] != -1.0 && g_mapZones[i].PointA[2] != -1.0)
		{
			db_insertZoneCheap(g_mapZones[i].ZoneId, g_mapZones[i].ZoneType, g_mapZones[i].ZoneTypeId, g_mapZones[i].PointA[0], g_mapZones[i].PointA[1], g_mapZones[i].PointA[2], g_mapZones[i].PointB[0], g_mapZones[i].PointB[1], g_mapZones[i].PointB[2], g_mapZones[i].Vis, g_mapZones[i].Team, g_mapZones[i].ZoneGroup, szzone, i, hookname, targetname, g_mapZones[i].OneJumpLimit, g_mapZones[i].PreSpeed);
		}
	}
}

public void db_updateZone(int zoneid, int zonetype, int zonetypeid, float[] Point1, float[] Point2, int vis, int team, int zonegroup, int onejumplimit, float prespeed, char[] hookname, char[] targetname)
{
	char szQuery[1024];
	Format(szQuery, 1024, sql_updateZone, zonetype, zonetypeid, Point1[0], Point1[1], Point1[2], Point2[0], Point2[1], Point2[2], vis, team, onejumplimit, prespeed, hookname, targetname, zonegroup, zoneid, g_szMapName);
	SQL_TQuery(g_hDb, SQL_updateZoneCallback, szQuery, 1, DBPrio_Low);
}

public void SQL_updateZoneCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (SQL_updateZoneCallback): %s", error);
		return;
	}

	db_selectMapZones();
}

void db_deleteZonesInGroup(int client)
{
	char szQuery[258];

	if (g_CurrentSelectedZoneGroup[client] < 1)
	{
		if (IsValidClient(client))
			CPrintToChat(client, "%t", "SQL6", g_szChatPrefix, g_CurrentSelectedZoneGroup[client]);

		PrintToServer("surftimer | Invalid zonegroup index selected, aborting. (%i)", g_CurrentSelectedZoneGroup[client]);
	}

	Transaction h_DeleteZoneGroup = SQL_CreateTransaction();

	Format(szQuery, 258, sql_deleteZonesInGroup, g_szMapName, g_CurrentSelectedZoneGroup[client]);
	SQL_AddQuery(h_DeleteZoneGroup, szQuery);

	// Format(szQuery, 258, "UPDATE ck_zones SET zonegroup = zonegroup-1 WHERE zonegroup > %i AND mapname = '%s';", g_CurrentSelectedZoneGroup[client], g_szMapName);
	// SQL_AddQuery(h_DeleteZoneGroup, szQuery);

	Format(szQuery, 258, "DELETE FROM ck_bonus WHERE zonegroup = %i AND mapname = '%s';", g_CurrentSelectedZoneGroup[client], g_szMapName);
	SQL_AddQuery(h_DeleteZoneGroup, szQuery);

	// Format(szQuery, 258, "UPDATE ck_bonus SET zonegroup = zonegroup-1 WHERE zonegroup > %i AND mapname = '%s';", g_CurrentSelectedZoneGroup[client], g_szMapName);
	// SQL_AddQuery(h_DeleteZoneGroup, szQuery);

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
		CPrintToChat(client, "%t", "SQL7", g_szChatPrefix);
	}
	return;
}

public void SQLTxn_ZoneGroupRemovalFailed(Handle db, any client, int numQueries, const char[] error, int failIndex, any[] queryData)
{
	if (IsValidClient(client))
	CPrintToChat(client, "%t", "SQL8", g_szChatPrefix, error);

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
		LogError("[SurfTimer] SQL Error (SQL_selectzoneTypeIdsCallback): %s", error);
		return;
	}

	if (SQL_HasResultSet(hndl))
	{
		int availableids[MAXZONES] = { 0, ... }, i;
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
			// fluffys
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
Format(szQuery, 258, "SELECT `zonegroup` ,`zonetype`, `zonetypeid` FROM `ck_zones` WHERE `mapname` = '%s';", g_szMapName);
SQL_TQuery(g_hDb, checkZoneTypeIdsCallback, szQuery, 1, DBPrio_High);
}

public checkZoneTypeIdsCallback(Handle owner, Handle hndl, const char[] error, any:data)
{
if (hndl == null)
{
LogError("[SurfTimer] SQL Error (checkZoneTypeIds): %s", error);
return;
}
if (SQL_HasResultSet(hndl))
{
int idChecker[MAXZONEGROUPS][ZONEAMOUNT][MAXZONES], idCount[MAXZONEGROUPS][ZONEAMOUNT];
char szQuery[258];
// Fill array with id's
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
PrintToServer("[SurfTimer] Error on zonetype: %i, zonetypeid: %i", i, idChecker[i][k]);
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
if (hndl == null)
{
LogError("[SurfTimer] SQL Error (checkZoneIdsCallback): %s", error);
return;
}

if (SQL_HasResultSet(hndl))
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
PrintToServer("[SurfTimer] Found an error in ZoneID's. Fixing...");
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
if (hndl == null)
{
LogError("[SurfTimer] SQL Error (checkZoneGroupIds): %s", error);
return;
}

if (SQL_HasResultSet(hndl))
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
PrintToServer("[SurfTimer] Found an error in zoneGroupID's. Fixing...");
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
	char szQuery[512];
	Format(szQuery, sizeof(szQuery), sql_selectMapZones, g_szMapName);
	SQL_TQuery(g_hDb, SQL_selectMapZonesCallback, szQuery, GetGameTime(), DBPrio_High);
}

public void SQL_selectMapZonesCallback(Handle owner, Handle hndl, const char[] error, float time)
{
	LogQueryTime("[SurfTimer] : Finished SQL_selectMapZonesCallback in: %f", GetGameTime() - time);
	
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (SQL_selectMapZonesCallback): %s", error);
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
		g_iTotalCheckpoints = 0;

		for (int i = 0; i < MAXZONES; i++)
		{
			g_mapZones[i].ZoneId = -1;
			g_mapZones[i].PointA = view_as<float>({ -1.0, -1.0, -1.0 });
			g_mapZones[i].PointB = view_as<float>({ -1.0, -1.0, -1.0 });
			g_mapZones[i].ZoneId = -1;
			g_mapZones[i].ZoneType = -1;
			g_mapZones[i].ZoneTypeId = -1;
			Format(g_mapZones[i].ZoneName, sizeof(MapZone::ZoneName), "");
			Format(g_mapZones[i].HookName, sizeof(MapZone::HookName), "");
			g_mapZones[i].Vis = 0;
			g_mapZones[i].Team = 0;
			g_mapZones[i].ZoneGroup = 0;
			Format(g_mapZones[i].TargetName, sizeof(MapZone::TargetName), "");
			g_mapZones[i].OneJumpLimit = 1;
			g_mapZones[i].PreSpeed = g_hDefaultPreSpeed.FloatValue;
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
			g_mapZones[g_mapZonesCount].ZoneId = SQL_FetchInt(hndl, 0);
			g_mapZones[g_mapZonesCount].ZoneType = SQL_FetchInt(hndl, 1);
			g_mapZones[g_mapZonesCount].ZoneTypeId = SQL_FetchInt(hndl, 2);
			g_mapZones[g_mapZonesCount].PointA[0] = SQL_FetchFloat(hndl, 3);
			g_mapZones[g_mapZonesCount].PointA[1] = SQL_FetchFloat(hndl, 4);
			g_mapZones[g_mapZonesCount].PointA[2] = SQL_FetchFloat(hndl, 5);
			g_mapZones[g_mapZonesCount].PointB[0] = SQL_FetchFloat(hndl, 6);
			g_mapZones[g_mapZonesCount].PointB[1] = SQL_FetchFloat(hndl, 7);
			g_mapZones[g_mapZonesCount].PointB[2] = SQL_FetchFloat(hndl, 8);
			g_mapZones[g_mapZonesCount].Vis = SQL_FetchInt(hndl, 9);
			g_mapZones[g_mapZonesCount].Team = SQL_FetchInt(hndl, 10);
			g_mapZones[g_mapZonesCount].ZoneGroup = SQL_FetchInt(hndl, 11);

			// Total amount of checkpoints
			if (g_mapZones[g_mapZonesCount].ZoneGroup == 0)
			{
				if (g_mapZones[g_mapZonesCount].ZoneType == 4)
				{
					g_iTotalCheckpoints++;
				}
			}

			/**
			* Initialize error checking
			* 0 = zone not found
			* 1 = zone found
			*
			* IDs must be in order 0, 1, 2....
			* Duplicate zoneids not possible due to primary key
			*/
			zoneIdChecker[g_mapZones[g_mapZonesCount].ZoneId]++;
			if (zoneGroupChecker[g_mapZones[g_mapZonesCount].ZoneGroup] != 1)
			{
				// 1 = No Bonus, 2 = Bonus, >2 = Multiple bonuses
				g_mapZoneGroupCount++;
				zoneGroupChecker[g_mapZones[g_mapZonesCount].ZoneGroup] = 1;
			}

			// You can have the same zonetype and zonetypeid values in different zonegroups
			zoneTypeIdChecker[g_mapZones[g_mapZonesCount].ZoneGroup][g_mapZones[g_mapZonesCount].ZoneType][g_mapZones[g_mapZonesCount].ZoneTypeId]++;
			zoneTypeIdCheckerCount[g_mapZones[g_mapZonesCount].ZoneGroup][g_mapZones[g_mapZonesCount].ZoneType]++;

			SQL_FetchString(hndl, 12, g_mapZones[g_mapZonesCount].ZoneName, sizeof(MapZone::ZoneName));
			SQL_FetchString(hndl, 13, g_mapZones[g_mapZonesCount].HookName, sizeof(MapZone::HookName));
			SQL_FetchString(hndl, 14, g_mapZones[g_mapZonesCount].TargetName, sizeof(MapZone::TargetName));
			g_mapZones[g_mapZonesCount].OneJumpLimit = SQL_FetchInt(hndl, 15);
			g_mapZones[g_mapZonesCount].PreSpeed = SQL_FetchFloat(hndl, 16);

			if (!g_mapZones[g_mapZonesCount].ZoneName[0])
			{
				switch (g_mapZones[g_mapZonesCount].ZoneType)
				{
					case 0: {
						Format(g_mapZones[g_mapZonesCount].ZoneName, sizeof(MapZone::ZoneName), "Stop-%i", g_mapZones[g_mapZonesCount].ZoneTypeId);
					}
					case 1: {
						if (g_mapZones[g_mapZonesCount].ZoneGroup > 0)
						{
							g_bhasBonus = true;
							Format(g_mapZones[g_mapZonesCount].ZoneName, sizeof(MapZone::ZoneName), "BonusStart-%i", g_mapZones[g_mapZonesCount].ZoneTypeId);
							Format(g_szZoneGroupName[g_mapZones[g_mapZonesCount].ZoneGroup], sizeof(MapZone::ZoneGroup), "Bonus %i", g_mapZones[g_mapZonesCount].ZoneGroup);
						}
						else
						Format(g_mapZones[g_mapZonesCount].ZoneName, sizeof(MapZone::ZoneName), "Start-%i", g_mapZones[g_mapZonesCount].ZoneTypeId);
					}
					case 2: {
						if (g_mapZones[g_mapZonesCount].ZoneGroup > 0)
						Format(g_mapZones[g_mapZonesCount].ZoneName, sizeof(MapZone::ZoneName), "BonusEnd-%i", g_mapZones[g_mapZonesCount].ZoneTypeId);
						else
						Format(g_mapZones[g_mapZonesCount].ZoneName, sizeof(MapZone::ZoneName), "End-%i", g_mapZones[g_mapZonesCount].ZoneTypeId);
					}
					case 3: {
						if (g_mapZones[g_mapZonesCount].ZoneGroup == 0)
						{
							g_bhasStages = true;
							Format(g_mapZones[g_mapZonesCount].ZoneName, sizeof(MapZone::ZoneName), "Stage-%i", (g_mapZones[g_mapZonesCount].ZoneTypeId + 2));
						}
					}
					case 4: {
						Format(g_mapZones[g_mapZonesCount].ZoneName, sizeof(MapZone::ZoneName), "Checkpoint-%i", g_mapZones[g_mapZonesCount].ZoneTypeId);
					}
					case 5: {
						Format(g_mapZones[g_mapZonesCount].ZoneName, sizeof(MapZone::ZoneName), "Speed-%i", g_mapZones[g_mapZonesCount].ZoneTypeId);
					}
					case 6: {
						Format(g_mapZones[g_mapZonesCount].ZoneName, sizeof(MapZone::ZoneName), "TeleToStart-%i", g_mapZones[g_mapZonesCount].ZoneTypeId);
					}
					case 7: {
						Format(g_mapZones[g_mapZonesCount].ZoneName, sizeof(MapZone::ZoneName), "Validator-%i", g_mapZones[g_mapZonesCount].ZoneTypeId);
					}
					case 8: {
						Format(g_mapZones[g_mapZonesCount].ZoneName, sizeof(MapZone::ZoneName), "Checker-%i", g_mapZones[g_mapZonesCount].ZoneTypeId);
					}
					case 9: { // fluffys
						Format(g_mapZones[g_mapZonesCount].ZoneName, sizeof(MapZone::ZoneName), "AntiJump-%i", g_mapZones[g_mapZonesCount].ZoneTypeId);
					}
					case 10: {
						Format(g_mapZones[g_mapZonesCount].ZoneName, sizeof(MapZone::ZoneName), "AntiDuck-%i", g_mapZones[g_mapZonesCount].ZoneTypeId);
					}
					case 11: {
						Format(g_mapZones[g_mapZonesCount].ZoneName, sizeof(MapZone::ZoneName), "MaxSpeed-%i", g_mapZones[g_mapZonesCount].ZoneTypeId);
					}
				}
			}
			else
			{
				switch (g_mapZones[g_mapZonesCount].ZoneType)
				{
					case 1:
					{
						if (g_mapZones[g_mapZonesCount].ZoneGroup > 0)
							g_bhasBonus = true;
						Format(g_szZoneGroupName[g_mapZones[g_mapZonesCount].ZoneGroup], 128, "%s", g_mapZones[g_mapZonesCount].ZoneName);
					}
					case 3: 
					{
						if (g_mapZones[g_mapZonesCount].ZoneGroup == 0)
						{
							g_bhasStages = true;
						}
					}
				}
			}

			/**
			*	Count zone center
			**/
			// Center
			float posA[3], posB[3], result[3];
			Array_Copy(g_mapZones[g_mapZonesCount].PointA, posA, 3);
			Array_Copy(g_mapZones[g_mapZonesCount].PointB, posB, 3);
			AddVectors(posA, posB, result);
			g_mapZones[g_mapZonesCount].CenterPoint[0] = result[0] / 2.0;
			g_mapZones[g_mapZonesCount].CenterPoint[1] = result[1] / 2.0;
			g_mapZones[g_mapZonesCount].CenterPoint[2] = result[2] / 2.0;

			for (int i = 0; i < 3; i++)
			{
				g_fZoneCorners[g_mapZonesCount][0][i] = g_mapZones[g_mapZonesCount].PointA[i];
				g_fZoneCorners[g_mapZonesCount][7][i] = g_mapZones[g_mapZonesCount].PointB[i];
			}

			// Zone counts:
			g_mapZonesTypeCount[g_mapZones[g_mapZonesCount].ZoneGroup][g_mapZones[g_mapZonesCount].ZoneType]++;
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
			PrintToServer("[SurfTimer] Found an error in zoneid : %i", i);
			Format(szQuery, 258, "UPDATE `ck_zones` SET zoneid = zoneid-1 WHERE mapname = '%s' AND zoneid > %i", g_szMapName, i);
			PrintToServer("Query: %s", szQuery);
			SQL_TQuery(g_hDb, sql_zoneFixCallback, szQuery, -1, DBPrio_Low);
			return;
		}

		// 2nd ZoneGroup
		for (int i = 0; i < g_mapZoneGroupCount; i++)
		if (zoneGroupChecker[i] == 0)
		{
			PrintToServer("[SurfTimer] Found an error in zonegroup %i (ZoneGroups total: %i)", i, g_mapZoneGroupCount);
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
				PrintToServer("[SurfTimer] ZoneTypeID missing! [ZoneGroup: %i ZoneType: %i, ZonetypeId: %i]", i, k, x);
				Format(szQuery, 258, "UPDATE `ck_zones` SET zonetypeid = zonetypeid-1 WHERE mapname = '%s' AND zonetype = %i AND zonetypeid > %i AND zonegroup = %i;", g_szMapName, k, x, i);
				SQL_TQuery(g_hDb, sql_zoneFixCallback, szQuery, -1, DBPrio_Low);
				return;
			}
			else if (zoneTypeIdChecker[i][k][x] > 1)
			{
				char szerror[258];
				Format(szerror, 258, "[SurfTimer] Duplicate Stage Zone ID's on %s [ZoneGroup: %i, ZoneType: 3, ZoneTypeId: %i]", g_szMapName, k, x);
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
			db_GetMapRecord_Pro();
	}
}

public void sql_zoneFixCallback(Handle owner, Handle hndl, const char[] error, any zongeroup)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (sql_zoneFixCallback): %s", error);
		return;
	}
	if (zongeroup == -1)
		db_selectMapZones();
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
		LogError("[SurfTimer] SQL Error (sql_zoneFixCallback2): %s", error);
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
		LogError("[SurfTimer] SQL Error (SQL_deleteMapZonesCallback): %s", error);
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
	CPrintToChat(client, "%t", "SQL9", g_szChatPrefix);
	PrintToServer("[SurfTimer] Zone Removed Succesfully");
}

public void SQLTxn_ZoneRemovalFailed(Handle db, any client, int numQueries, const char[] error, int failIndex, any[] queryData)
{
	if (IsValidClient(client))
	CPrintToChat(client, "%t", "SQL10", g_szChatPrefix, error);
	PrintToServer("[SurfTimer] Zone Removal Failed. Error: %s", error);
	return;
}

/*==================================
=               MISC               =
==================================*/

public void db_insertLastPosition(int client, char szMapName[128], int stage, int zgroup)
{
	if (GetConVarBool(g_hcvarRestore) && !g_bRoundEnd && (StrContains(g_szSteamID[client], "STEAM_") != -1) && g_bTimerRunning[client])
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
		LogError("[SurfTimer] SQL Error (db_insertLastPositionCallback): %s", error);
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
		if (!g_bTimerRunning[client])
		g_fPlayerLastTime[client] = -1.0;
		int tickrate = g_iTickrate * 5 * 11;
		if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
		{
			Format(szQuery, sizeof(szQuery), sql_updatePlayerTmp, g_fPlayerCordsLastPosition[client][0], g_fPlayerCordsLastPosition[client][1], g_fPlayerCordsLastPosition[client][2], g_fPlayerAnglesLastPosition[client][0], g_fPlayerAnglesLastPosition[client][1], g_fPlayerAnglesLastPosition[client][2], g_fPlayerLastTime[client], szMapName, tickrate, stage, zgroup, szSteamID);
			SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, _, DBPrio_Low);
		}
		else
		{
			Format(szQuery, sizeof(szQuery), sql_insertPlayerTmp, g_fPlayerCordsLastPosition[client][0], g_fPlayerCordsLastPosition[client][1], g_fPlayerCordsLastPosition[client][2], g_fPlayerAnglesLastPosition[client][0], g_fPlayerAnglesLastPosition[client][1], g_fPlayerAnglesLastPosition[client][2], g_fPlayerLastTime[client], szSteamID, szMapName, tickrate, stage, zgroup);
			SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, _, DBPrio_Low);
		}
	}
}

public void db_deletePlayerTmps()
{
	char szQuery[64];
	Format(szQuery, sizeof(szQuery), "delete FROM ck_playertemp");
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, _, DBPrio_Low);
}

public void db_ViewLatestRecords(int client)
{
	SQL_TQuery(g_hDb, sql_selectLatestRecordsCallback, sql_selectLatestRecords, client, DBPrio_Low);
}

public void sql_selectLatestRecordsCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (sql_selectLatestRecordsCallback): %s", error);
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
			delete menu;
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
	CPrintToChat(data, "%t", "ConsoleOutput", g_szChatPrefix);
}

public int LatestRecordsMenuHandler(Handle menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
		delete menu;

	return 0;
}

public void db_InsertLatestRecords(char szSteamID[32], char szName[128], float FinalTime)
{
	char szQuery[512];
	Format(szQuery, sizeof(szQuery), sql_insertLatestRecords, szSteamID, szName, FinalTime, g_szMapName);
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, _, DBPrio_Low);
}

public void db_CalcAvgRunTime()
{
	char szQuery[256];
	Format(szQuery, sizeof(szQuery), sql_selectAllMapTimesinMap, g_szMapName);
	SQL_TQuery(g_hDb, SQL_db_CalcAvgRunTimeCallback, szQuery, GetGameTime(), DBPrio_Low);
}

public void SQL_db_CalcAvgRunTimeCallback(Handle owner, Handle hndl, const char[] error, float time)
{
	LogQueryTime("[SurfTimer] : Finished SQL_db_CalcAvgRunTimeCallback in: %f", GetGameTime() - time);
	
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (SQL_db_CalcAvgRunTimeCallback): %s", error);

		if (!g_bServerDataLoaded && g_bhasBonus)
			db_CalcAvgRunTimeBonus();
		else if (!g_bServerDataLoaded)
			db_CalculatePlayerCount(0);

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
		db_CalculatePlayerCount(0);
}

public void db_CalcAvgRunTimeBonus()
{
	char szQuery[256];
	Format(szQuery, 256, sql_selectAllBonusTimesinMap, g_szMapName);
	SQL_TQuery(g_hDb, SQL_db_CalcAvgRunBonusTimeCallback, szQuery, GetGameTime(), DBPrio_Low);
}

public void SQL_db_CalcAvgRunBonusTimeCallback(Handle owner, Handle hndl, const char[] error, float fTime)
{
	LogQueryTime("[SurfTimer] : Finished SQL_db_CalcAvgRunBonusTimeCallback in: %f", GetGameTime() - fTime);
	
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (SQL_db_CalcAvgRunBonusTimeCallback): %s", error);
		if (!g_bServerDataLoaded)
			db_CalculatePlayerCount(0);
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
		db_CalculatePlayerCount(0);

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
	SQL_TQuery(g_hDb, SQL_db_GetDynamicTimelimitCallback, szQuery, GetGameTime(), DBPrio_Low);
}

public void SQL_db_GetDynamicTimelimitCallback(Handle owner, Handle hndl, const char[] error, float fTime)
{
	LogQueryTime("[SurfTimer] : Finished SQL_db_GetDynamicTimelimitCallback in: %f", GetGameTime() - fTime);
	
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (SQL_db_GetDynamicTimelimitCallback): %s", error);
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
		// requires min. 5 map times
		if (maptimes > 5)
		{
			int scale_factor = 3;
			int avg = RoundToNearest((total) / 60.0 / float(maptimes));

			// scale factor
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

			// timelimit: min 20min, max 120min
			if (avg < 20)
			avg = 20;
			if (avg > 120)
			avg = 120;

			// set timelimit
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
		// loadAllClientSettings();

	return;
}

public void db_CalculatePlayerCount(int style)
{
	char szQuery[255];
	Format(szQuery, 255, sql_CountRankedPlayers, style);
	DataPack pack = new DataPack();
	pack.WriteCell(style);
	pack.WriteFloat(GetGameTime());
	SQL_TQuery(g_hDb, sql_CountRankedPlayersCallback, szQuery, pack, DBPrio_Low);
}

public void db_CalculatePlayersCountGreater0(int style)
{
	char szQuery[255];
	Format(szQuery, 255, sql_CountRankedPlayers2, style);
	DataPack pack = new DataPack();
	pack.WriteCell(style);
	pack.WriteFloat(GetGameTime());
	SQL_TQuery(g_hDb, sql_CountRankedPlayers2Callback, szQuery, pack, DBPrio_Low);
}

public void sql_CountRankedPlayersCallback(Handle owner, Handle hndl, const char[] error, DataPack pack)
{
	pack.Reset();
	int style = pack.ReadCell();
	float time = pack.ReadFloat();
	delete pack;

	LogQueryTime("[SurfTimer] : Finished sql_CountRankedPlayersCallback in: %f", GetGameTime() - time);

	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (sql_CountRankedPlayersCallback): %s", error);
		db_CalculatePlayersCountGreater0(style);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		g_pr_AllPlayers[style] = SQL_FetchInt(hndl, 0);
	}
	else
		g_pr_AllPlayers[style] = 1;

	// get amount of players with actual player points
	db_CalculatePlayersCountGreater0(style);
	return;
}

public void sql_CountRankedPlayers2Callback(Handle owner, Handle hndl, const char[] error, DataPack pack)
{
	pack.Reset();
	int style = pack.ReadCell();
	float time = pack.ReadFloat();
	delete pack;

	LogQueryTime("[SurfTimer] : Finished sql_CountRankedPlayers2Callback in: %f", GetGameTime() - time);
	
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (sql_CountRankedPlayers2Callback): %s", error);

		if (!g_bServerDataLoaded)
			db_selectSpawnLocations();
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		g_pr_RankedPlayers[style] = SQL_FetchInt(hndl, 0);
	}
	else
		g_pr_RankedPlayers[style] = 0;

	if (!g_bServerDataLoaded)
		db_selectSpawnLocations();

	return;
}

public void db_viewUnfinishedMaps(int client, char szSteamId[32])
{
	if (IsValidClient(client))
		CPrintToChat(client, "%t", "ConsoleOutput", g_szChatPrefix);
	else
		return;

	char szQuery[720];
	// Gets all players unfinished maps and bonuses from the database
	Format(szQuery, 720, "SELECT mapname, zonegroup, zonename, (SELECT tier FROM ck_maptier d WHERE d.mapname = a.mapname) AS tier FROM ck_zones a WHERE (zonetype = 1 OR zonetype = 5) AND (SELECT runtimepro FROM ck_playertimes b WHERE b.mapname = a.mapname AND a.zonegroup = 0 AND b.style = %d AND steamid = '%s' UNION SELECT runtime FROM ck_bonus c WHERE c.mapname = a.mapname AND c.zonegroup = a.zonegroup AND c.style = %d AND steamid = '%s') IS NULL GROUP BY mapname, zonegroup ORDER BY tier, mapname, zonegroup ASC", g_ProfileStyleSelect[client], szSteamId, g_ProfileStyleSelect[client], szSteamId);
	SQL_TQuery(g_hDb, db_viewUnfinishedMapsCallback, szQuery, client, DBPrio_Low);
}

public void db_viewUnfinishedMapsCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (db_viewUnfinishedMapsCallback): %s", error);
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
							Format(zName, 128, "bonus %i", zGrp);

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
			PrintToConsole(client, "%i unfinished maps of total %i maps", mapCount, g_pr_MapCount[0]);
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

	return Plugin_Continue;
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

public void sql_selectPlayerNameCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (sql_selectPlayerNameCallback): %s", error);
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
	else if (IsValidClient(client))
		PrintToConsole(client, "SteamID %s not found.", g_pr_szSteamID[clientid]);
}

// 0. Admins counting players points starts here
public void RefreshPlayerRankTable(int max)
{
	g_pr_Recalc_ClientID = 1;
	g_pr_RankingRecalc_InProgress = true;
	char szQuery[255];

	// SELECT steamid, name from ck_playerrank where points > 0 ORDER BY points DESC";
	// SELECT steamid, name from ck_playerrank where points > 0 ORDER BY points DESC
	Format(szQuery, 255, sql_selectRankedPlayers);
	SQL_TQuery(g_hDb, sql_selectRankedPlayersCallback, szQuery, max, DBPrio_Low);
}

public void sql_selectRankedPlayersCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (sql_selectRankedPlayersCallback): %s", error);
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
					CPrintToChat(c, "%t", "PrUpdateFinished", g_szChatPrefix);
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
				g_pr_points[i][0] = 0;
				SQL_FetchString(hndl, 0, g_pr_szSteamID[i], 32);
				SQL_FetchString(hndl, 1, g_pr_szName[i], 64);

				g_bProfileRecalc[i] = true;
				i++;
			}
			if (i == x)
				CalculatePlayerRank(66, 0);
		}
	}
	else
		PrintToConsole(g_pr_Recalc_AdminID, " \n>> No valid players found!");
}

public void db_Cleanup()
{
	char szQuery[255];

	// tmps
	Format(szQuery, sizeof(szQuery), "DELETE FROM ck_playertemp where mapname != '%s'", g_szMapName);
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, _, DBPrio_Low);

	// times
	SQL_TQuery(g_hDb, SQL_CheckCallback, "DELETE FROM ck_playertimes where runtimepro = -1.0", _, DBPrio_Low);

	// fluffys pointless players
	SQL_TQuery(g_hDb, SQL_CheckCallback, "DELETE FROM ck_playerrank WHERE `points` <= 0", _, DBPrio_Low);

}

public void SQL_InsertPlayerCallBack(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (SQL_InsertPlayerCallBack): %s", error);
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
			Format(szQuery, sizeof(szQuery), sql_UpdateLastSeenMySQL, g_szSteamID[client]);
		else if (g_DbType == SQLITE)
			Format(szQuery, sizeof(szQuery), sql_UpdateLastSeenSQLite, g_szSteamID[client]);

		SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, _, DBPrio_Low);
	}
}

/*===================================
=         DEFAULT CALLBACKS         =
===================================*/

public void SQL_CheckCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogStackTrace("[SurfTimer] SQL Error (SQL_CheckCallback): %s", error);
		return;
	}
}

/*==================================
=          PLAYER OPTIONS          =
==================================*/

public void db_viewPlayerOptions(int client, char szSteamId[32])
{
	g_bLoadedModules[client] = false;
	char szQuery[2048];
	Format(szQuery, 2048, sql_selectPlayerOptions, szSteamId);
	SQL_TQuery(g_hDb, db_viewPlayerOptionsCallback, szQuery, client, DBPrio_Low);
}

public void db_viewPlayerOptionsCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (db_viewPlayerOptionsCallback): %s", error);
		if (!g_bSettingsLoaded[client])
			LoadClientSetting(client, g_iSettingToLoad[client]);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		// "SELECT timer, hide, sounds, chat, viewmodel, autobhop, checkpoints, gradient, speedmode, centrehud, module1c, module2c, module3c, module4c, module5c, module6c, sidehud, module1s, module2s, module3s, module4s, module5s, prestrafe FROM ck_playeroptions2 where steamid = '%s';"

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
		g_iTeleSide[client] = SQL_FetchInt(hndl, 11);
		g_iCentreHudModule[client][0] = SQL_FetchInt(hndl, 12);
		g_iCentreHudModule[client][1] = SQL_FetchInt(hndl, 13);
		g_iCentreHudModule[client][2] = SQL_FetchInt(hndl, 14);
		g_iCentreHudModule[client][3] = SQL_FetchInt(hndl, 15);
		g_iCentreHudModule[client][4] = SQL_FetchInt(hndl, 16);
		g_iCentreHudModule[client][5] = SQL_FetchInt(hndl, 17);
		g_bSideHud[client] = view_as<bool>(SQL_FetchInt(hndl, 18));
		g_iSideHudModule[client][0] = SQL_FetchInt(hndl, 19);
		g_iSideHudModule[client][1] = SQL_FetchInt(hndl, 20);
		g_iSideHudModule[client][2] = SQL_FetchInt(hndl, 21);
		g_iSideHudModule[client][3] = SQL_FetchInt(hndl, 22);
		g_iSideHudModule[client][4] = SQL_FetchInt(hndl, 23);
		g_iPrespeedText[client] = view_as<bool>(SQL_FetchInt(hndl, 24));
		g_iCpMessages[client] = view_as<bool>(SQL_FetchInt(hndl, 25));
		g_iWrcpMessages[client] = view_as<bool>(SQL_FetchInt(hndl, 26));
		g_bAllowHints[client] = view_as<bool>(SQL_FetchInt(hndl, 27));
		g_iCSDUpdateRate[client] = SQL_FetchInt(hndl, 28);
		g_fCSD_POS_X[client] = SQL_FetchFloat(hndl, 29);
		g_fCSD_POS_Y[client] = SQL_FetchFloat(hndl, 30);
		g_iCSD_R[client] = SQL_FetchInt(hndl, 31);
		g_iCSD_G[client] = SQL_FetchInt(hndl, 32);
		g_iCSD_B[client] = SQL_FetchInt(hndl, 33);
		g_PreSpeedMode[client] = SQL_FetchInt(hndl, 34);
		

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

		// "INSERT INTO ck_playeroptions2 (steamid, timer, hide, sounds, chat, viewmodel, autobhop, checkpoints, centrehud, module1c, module2c, module3c, module4c, module5c, module6c, sidehud, module1s, module2s, module3s, module4s, module5s) VALUES('%s', '%i', '%i', '%i', '%i', '%i', '%i', '%i', '%i', '%i', '%i', '%i', '%i', '%i', '%i', '%i', '%i', '%i', '%i', '%i', '%i');";

		Format(szQuery, sizeof(szQuery), sql_insertPlayerOptions, g_szSteamID[client]);
		SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, _, DBPrio_Low);

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
		g_iTeleSide[client] = 0;
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
		g_iPrespeedText[client] = false;
		g_iCpMessages[client] = false;
		g_iWrcpMessages[client] = false;
		g_bAllowHints[client] = true;
		g_iCSDUpdateRate[client] = 1;
		g_fCSD_POS_X[client] = 0.5;
		g_fCSD_POS_Y[client] = 0.4;
		g_iCSD_R[client] = 255;
		g_iCSD_G[client] = 255;
		g_iCSD_B[client] = 255;
		g_PreSpeedMode[client] = 0;
	}

	if (!g_bSettingsLoaded[client])
	{
		g_fTick[client][1] = GetGameTime();
		float tick = g_fTick[client][1] - g_fTick[client][0];
		LogQueryTime("[SurfTimer] %s: Finished db_viewPlayerOptions in %fs", g_szSteamID[client], tick);
		g_fTick[client][0] = GetGameTime();

		LoadClientSetting(client, g_iSettingToLoad[client]);
	}
	return;
}

public void db_updatePlayerOptions(int client)
{
	char szQuery[2048];
	// "UPDATE ck_playeroptions2 SET timer = %i, hide = %i, sounds = %i, chat = %i, viewmodel = %i, autobhop = %i, checkpoints = %i, centrehud = %i, module1c = %i, module2c = %i, module3c = %i, module4c = %i, module5c = %i, module6c = %i, sidehud = %i, module1s = %i, module2s = %i, module3s = %i, module4s = %i, module5s = %i where steamid = '%s'";
	if (g_bSettingsLoaded[client] && g_bServerDataLoaded && g_bLoadedModules[client])
	{
		Format(szQuery, sizeof(szQuery), sql_updatePlayerOptions, BooltoInt(g_bTimerEnabled[client]), BooltoInt(g_bHide[client]), BooltoInt(g_bEnableQuakeSounds[client]), BooltoInt(g_bHideChat[client]), BooltoInt(g_bViewModel[client]), BooltoInt(g_bAutoBhopClient[client]), BooltoInt(g_bCheckpointsEnabled[client]), g_SpeedGradient[client], g_SpeedMode[client], BooltoInt(g_bCenterSpeedDisplay[client]), BooltoInt(g_bCentreHud[client]), g_iTeleSide[client], g_iCentreHudModule[client][0], g_iCentreHudModule[client][1], g_iCentreHudModule[client][2], g_iCentreHudModule[client][3], g_iCentreHudModule[client][4], g_iCentreHudModule[client][5], BooltoInt(g_bSideHud[client]), g_iSideHudModule[client][0], g_iSideHudModule[client][1], g_iSideHudModule[client][2], g_iSideHudModule[client][3], g_iSideHudModule[client][4], BooltoInt(g_iPrespeedText[client]), BooltoInt(g_iCpMessages[client]), BooltoInt(g_iWrcpMessages[client]), BooltoInt(g_bAllowHints[client]), g_iCSDUpdateRate[client], g_fCSD_POS_X[client], g_fCSD_POS_Y[client], g_iCSD_R[client], g_iCSD_G[client], g_iCSD_B[client], g_PreSpeedMode[client], g_szSteamID[client]);
		//Format(szQuery, 1024, sql_updatePlayerOptions, BooltoInt(g_bTimerEnabled[client]), BooltoInt(g_bHide[client]), BooltoInt(g_bEnableQuakeSounds[client]), BooltoInt(g_bHideChat[client]), BooltoInt(g_bViewModel[client]), BooltoInt(g_bAutoBhopClient[client]), BooltoInt(g_bCheckpointsEnabled[client]), g_SpeedGradient[client], g_SpeedMode[client], BooltoInt(g_bCenterSpeedDisplay[client]), BooltoInt(g_bCentreHud[client]), g_iTeleSide[client], g_iCentreHudModule[client][0], g_iCentreHudModule[client][1], g_iCentreHudModule[client][2], g_iCentreHudModule[client][3], g_iCentreHudModule[client][4], g_iCentreHudModule[client][5], BooltoInt(g_bSideHud[client]), g_iSideHudModule[client][0], g_iSideHudModule[client][1], g_iSideHudModule[client][2], g_iSideHudModule[client][3], g_iSideHudModule[client][4], BooltoInt(g_iPrespeedText[client]), BooltoInt(g_iCpMessages[client]), BooltoInt(g_iWrcpMessages[client]), BooltoInt(g_bAllowHints[client]), BooltoInt(g_bTimeleftDisplay[client]), g_szSteamID[client]);
		SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, _, DBPrio_Low);
	}
}

/*===================================
=               MENUS               =
===================================*/

public void db_selectTopPlayers(int client, int style)
{
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackCell(pack, style);

	char szQuery[128];
	Format(szQuery, 128, sql_selectTopPlayers, style);
	SQL_TQuery(g_hDb, db_selectTop100PlayersCallback, szQuery, pack, DBPrio_Low);
}

public void db_selectTop100PlayersCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (db_selectTop100PlayersCallback): %s", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);
	int data = ReadPackCell(pack);
	int style = ReadPackCell(pack);
	CloseHandle(pack);

	char szValue[128];
	char szName[64];
	char szRank[16];
	char szSteamID[32];
	char szPerc[16];
	int points;
	Menu menu = new Menu(TopPlayersMenuHandler1);
	char szTitle[256];
	if (style == 0)
		Format(szTitle, sizeof(szTitle), "Top 100 Players\n    Rank   Points       Maps            Player");
	else
		Format(szTitle, sizeof(szTitle), "Top 100 Players - %s\n    Rank   Points       Maps            Player", g_szStyleMenuPrint[style]);

	menu.SetTitle(szTitle);
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
			fperc = (float(pro) / (float(g_pr_MapCount[0]))) * 100.0;

			if (fperc < 10.0)
			Format(szPerc, 16, "  %.1f%c  ", fperc, PERCENT);
			else
			if (fperc == 100.0)
			Format(szPerc, 16, "100.0%c", PERCENT);
			else
			if (fperc > 100.0) // player profile not refreshed after removing maps
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
			CPrintToChat(data, "%t", "NoPlayerTop", g_szChatPrefix);
		}
		else
		{
			menu.OptionFlags = MENUFLAG_BUTTON_EXIT;
			menu.Display(data, MENU_TIME_FOREVER);
		}
	}
	else
	{
		CPrintToChat(data, "%t", "NoPlayerTop", g_szChatPrefix);
	}
}

public int TopPlayersMenuHandler1(Handle menu, MenuAction action, int client, int item)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		GetMenuItem(menu, item, info, sizeof(info));
		g_MenuLevel[client] = 0;
		db_viewPlayerProfile(client, g_ProfileStyleSelect[client], info, true, "");
	}
	if (action == MenuAction_Cancel)
	{
		ckTopMenu(client, 0);
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}

	return 0;
}

public int MapMenuHandler1(Handle menu, MenuAction action, int client, int item)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		GetMenuItem(menu, item, info, sizeof(info));
		g_MenuLevel[client] = 1;
		db_viewPlayerProfile(client, g_ProfileStyleSelect[client], info, true, "");
	}
	if (action == MenuAction_Cancel)
	{
		ckTopMenu(client, g_ProfileStyleSelect[client]);
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}

	return 0;
}

public int FinishedMapsMenuHandler(Handle menu, MenuAction action, int client, int item)
{
	if (action == MenuAction_Cancel)
	{
		ProfileMenu2(client, g_ProfileStyleSelect[client], "", g_szSteamID[client]);
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}

	return 0;
}

// fluffys sql select total bonus
public void db_selectTotalBonusCount()
{
	char szQuery[512];
	Format(szQuery, sizeof(szQuery), "SELECT COUNT(DISTINCT `a`.`mapname`, `a`.`zonegroup`) AS `count` FROM `ck_zones` `a` INNER JOIN `ck_maptier` `b` ON `b`.`mapname` = `a`.`mapname` WHERE `a`.`zonetype` = 1 AND `a`.`zonegroup` > 0");
	SQL_TQuery(g_hDb, sql_selectTotalBonusCountCallback, szQuery, GetGameTime(), DBPrio_Low);
}

public void sql_selectTotalBonusCountCallback(Handle owner, Handle hndl, const char[] error, float time)
{
	LogQueryTime("[SurfTimer] : Finished sql_selectTotalBonusCountCallback in: %f", GetGameTime() - time);
	
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (sql_selectTotalBonusCountCallback): %s", error);
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

// fluffys sql select total stages
public void db_selectTotalStageCount()
{
	char szQuery[512];
	Format(szQuery, sizeof(szQuery), "SELECT COUNT(DISTINCT `a`.`mapname`) + COUNT(1) AS `count` FROM `ck_zones` `a` INNER JOIN `ck_maptier` `b` ON `b`.`mapname` = `a`.`mapname` WHERE `a`.`zonetype` = 3 AND `a`.`zonegroup` = 0;");
	SQL_TQuery(g_hDb, sql_selectTotalStageCountCallback, szQuery, GetGameTime(), DBPrio_Low);
}

public void sql_selectTotalStageCountCallback(Handle owner, Handle hndl, const char[] error, float time)
{
	LogQueryTime("[SurfTimer] : Finished sql_selectTotalStageCountCallback in: %f", GetGameTime() - time);

	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (sql_selectTotalStageCountCallback): %s", error);

		if (!g_bServerDataLoaded)
			db_selectCurrentMapImprovement();
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
		g_pr_StageCount = SQL_FetchInt(hndl, 0);

	if (!g_bServerDataLoaded)
		db_selectCurrentMapImprovement();

	return;
}

public void db_selectWrcpRecord(int client, int style, int stage)
{
	if (!IsValidClient(client) || IsFakeClient(client) || g_bUsingStageTeleport[client] || g_bPracticeMode[client])
		return;

	if (stage > g_TotalStages) // Hack fix for multiple end zones
		stage = g_TotalStages;

	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackCell(pack, style);
	WritePackCell(pack, stage);

	char szQuery[255];
	if (style == 0)
		Format(szQuery, 255, "SELECT runtimepro FROM ck_wrcps WHERE steamid = '%s' AND mapname = '%s' AND stage = %i AND style = 0", g_szSteamID[client], g_szMapName, stage);
	else if (style != 0)
		Format(szQuery, 255, "SELECT runtimepro FROM ck_wrcps WHERE steamid = '%s' AND mapname = '%s' AND stage = %i AND style = %i", g_szSteamID[client], g_szMapName, stage, style);

	SQL_TQuery(g_hDb, sql_selectWrcpRecordCallback, szQuery, pack, DBPrio_Low);
}

public void sql_selectWrcpRecordCallback(Handle owner, Handle hndl, const char[] error, any packx)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (sql_selectWrcpRecordCallback): %s", error);
		CloseHandle(packx);
		return;
	}

	ResetPack(packx);
	int data = ReadPackCell(packx);
	int style = ReadPackCell(packx);
	int stage = ReadPackCell(packx);
	CloseHandle(packx);

	if (!IsValidClient(data) || IsFakeClient(data) || g_bPracticeMode[data])
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
		Format(szDiff, 128, "%cPB: %c-%s%c", WHITE, LIGHTGREEN, szDiff, WHITE);
	else
		Format(szDiff, 128, "%cPB: %c+%s%c", WHITE, RED, szDiff, WHITE);

	// SR
	if (style == 0)
		f_srDiff = (g_fStageRecord[stage] - time);
	else // styles
		f_srDiff = (g_fStyleStageRecord[style][stage] - time);

	FormatTimeFloat(data, f_srDiff, 3, sz_srDiff, 128);

	if (f_srDiff > 0)
		Format(sz_srDiff, 128, "%cSR: %c-%s%c", WHITE, LIGHTGREEN, sz_srDiff, WHITE);
	else
		Format(sz_srDiff, 128, "%cSR: %c+%s%c", WHITE, RED, sz_srDiff, WHITE);

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
		{ // fluffys come back
			char szSpecMessage[512];

			g_bStageSRVRecord[data][stage] = false;
			if (style == 0)
			{
				if (g_iWrcpMessages[data])
					CPrintToChat(data, "%t", "SQL11", g_szChatPrefix, stage, g_szFinalWrcpTime[data], szDiff, sz_srDiff);

				Format(szSpecMessage, sizeof(szSpecMessage), "%t", "SQL12", g_szChatPrefix, szName, stage, g_szFinalWrcpTime[data], szDiff, sz_srDiff);
			}
			else if (style != 0) // styles
			{
				if (g_iWrcpMessages[data])
					CPrintToChat(data, "%t", "SQL13", g_szChatPrefix, stage, g_szStyleRecordPrint[style], g_szFinalWrcpTime[data], sz_srDiff, g_StyleStageRank[style][data][stage], g_TotalStageStyleRecords[style][stage]);
				
				Format(szSpecMessage, sizeof(szSpecMessage), "%t", "SQL14", g_szChatPrefix, stage, g_szStyleRecordPrint[style], g_szFinalWrcpTime[data], sz_srDiff, g_StyleStageRank[style][data][stage], g_TotalStageStyleRecords[style][stage]);
			}
			CheckpointToSpec(data, szSpecMessage);

			if (g_bRepeat[data])
			{
				if (stage <= 1)
					Command_Restart(data, 1);
				else
					teleportClient(data, 0, stage, false);
			}
		}
	}
	else
	{ // No record found from database - Let's insert

		// Escape name for SQL injection protection
		char szName2[MAX_NAME_LENGTH * 2 + 1], szUName[MAX_NAME_LENGTH];
		GetClientName(data, szUName, MAX_NAME_LENGTH);
		SQL_EscapeString(g_hDb, szUName, szName2, MAX_NAME_LENGTH);

		// Move required information in datapack
		Handle pack = CreateDataPack();
		WritePackFloat(pack, g_fFinalWrcpTime[data]);
		WritePackCell(pack, style);
		WritePackCell(pack, stage);
		WritePackCell(pack, 1);
		WritePackCell(pack, data);

		if (style == 0)
			Format(szQuery, sizeof(szQuery), "INSERT INTO ck_wrcps (steamid, name, mapname, runtimepro, stage, velStartXY, velStartXYZ, velStartZ) VALUES ('%s', '%s', '%s', '%f', %i, %i, %i, %i);", g_szSteamID[data], szName, g_szMapName, g_fFinalWrcpTime[data], stage, g_iPreStrafeStage[0][stage][0][data], g_iPreStrafeStage[1][stage][0][data], g_iPreStrafeStage[2][stage][0][data]);
		else if (style != 0)
			Format(szQuery, sizeof(szQuery), "INSERT INTO ck_wrcps (steamid, name, mapname, runtimepro, stage, style, velStartXY, velStartXYZ, velStartZ) VALUES ('%s', '%s', '%s', '%f', %i, %i, %i, %i, %i);", g_szSteamID[data], szName, g_szMapName, g_fFinalWrcpTime[data], stage, style, g_iPreStrafeStage[0][stage][style][data], g_iPreStrafeStage[1][stage][style][data], g_iPreStrafeStage[2][stage][style][data]);

		SQL_TQuery(g_hDb, SQL_UpdateWrcpRecordCallback, szQuery, pack, DBPrio_Low);

		g_bStageSRVRecord[data][stage] = false;
	}
}

// If latest record was faster than old - Update time
public void db_updateWrcpRecord(int client, int style, int stage)
{
	if (!IsValidClient(client) || IsFakeClient(client))
		return;

	char szUName[MAX_NAME_LENGTH];
	GetClientName(client, szUName, MAX_NAME_LENGTH);

	// Also updating name in database, escape string
	char szName[MAX_NAME_LENGTH * 2 + 1];
	SQL_EscapeString(g_hDb, szUName, szName, MAX_NAME_LENGTH * 2 + 1);
	// int stage = g_CurrentStage[client];

	// Packing required information for later
	Handle pack = CreateDataPack();
	WritePackFloat(pack, g_fFinalWrcpTime[client]);
	WritePackCell(pack, style);
	WritePackCell(pack, stage);
	WritePackCell(pack, 0);
	WritePackCell(pack, client);

	char szQuery[1024];
	// "UPDATE ck_playertimes SET name = '%s', runtimepro = '%f' WHERE steamid = '%s' AND mapname = '%s';";
	if (style == 0)
		Format(szQuery, sizeof(szQuery), "UPDATE ck_wrcps SET name = '%s', runtimepro = '%f', velStartXY = %i, velStartXYZ = %i, velStartZ = %i WHERE steamid = '%s' AND mapname = '%s' AND stage = %i AND style = 0;", szName, g_fFinalWrcpTime[client], g_iPreStrafeStage[0][stage][0][client], g_iPreStrafeStage[1][stage][0][client], g_iPreStrafeStage[2][stage][0][client], g_szSteamID[client], g_szMapName, stage);
	if (style > 0)
		Format(szQuery, sizeof(szQuery), "UPDATE ck_wrcps SET name = '%s', runtimepro = '%f', velStartXY = %i, velStartXYZ = %i, velStartZ = %i WHERE steamid = '%s' AND mapname = '%s' AND stage = %i AND style = %i;", szName, g_fFinalWrcpTime[client], g_iPreStrafeStage[0][stage][style][client], g_iPreStrafeStage[1][stage][style][client], g_iPreStrafeStage[2][stage][style][client], g_szSteamID[client], g_szMapName, stage, style);
	SQL_TQuery(g_hDb, SQL_UpdateWrcpRecordCallback, szQuery, pack, DBPrio_Low);
}


public void SQL_UpdateWrcpRecordCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (SQL_UpdateWrcpRecordCallback): %s", error);
		CloseHandle(data);
		return;
	}

	ResetPack(data);
	float stagetime = ReadPackFloat(data);
	int style = ReadPackCell(data);
	int stage = ReadPackCell(data);

	// Find out how many times are are faster than the players time
	char szQuery[512];
	if (style == 0)
		Format(szQuery, 512, "SELECT count(runtimepro) FROM ck_wrcps WHERE `mapname` = '%s' AND stage = %i AND style = 0 AND runtimepro < %f AND runtimepro > -1.0;", g_szMapName, stage, stagetime);
	else if (style != 0)
		Format(szQuery, 512, "SELECT count(runtimepro) FROM ck_wrcps WHERE mapname = '%s' AND runtimepro < %f AND stage = %i AND style = %i AND runtimepro > -1.0;", g_szMapName, stagetime, stage, style);

	SQL_TQuery(g_hDb, SQL_UpdateWrcpRecordCallback2, szQuery, data, DBPrio_Low);
}

public void SQL_UpdateWrcpRecordCallback2(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (SQL_UpdateWrcpRecordCallback2): %s", error);
		CloseHandle(data);
		return;
	}

	ResetPack(data);
	float time = ReadPackFloat(data);
	int style = ReadPackCell(data);
	int stage = ReadPackCell(data);
	bool bInsert = view_as<bool>(ReadPackCell(data));
	int client = ReadPackCell(data);
	CloseHandle(data);

	if (bInsert) // fluffys FIXME
	{
		if (style == 0)
			g_TotalStageRecords[stage]++;
		else
			g_TotalStageStyleRecords[style][stage]++;
	}

	if (stage == 0)
		return;

	// Get players rank, 9999999 = error
	int stagerank = 9999999;
	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
		stagerank = SQL_FetchInt(hndl, 0) + 1;

	if (stage > g_TotalStages) // Hack Fix for multiple end zone issue
		stage = g_TotalStages;

	if (style == 0)
		g_StageRank[client][stage] = stagerank;
	else
		g_StyleStageRank[style][client][stage] = stagerank;

	// Get client name
	char szName[MAX_NAME_LENGTH];
	GetClientName(client, szName, MAX_NAME_LENGTH);

	char sz_srDiff[128];
	char sz_srRawDiff[128];

	// PB
	char szDiff[128];
	float fDiff;

	fDiff = (g_fWrcpRecord[client][stage][style] - time);
	FormatTimeFloat(client, fDiff, 3, szDiff, 128);

	if (g_fWrcpRecord[client][stage][style] != -1.0) // Existing stage time
	{
		if (fDiff > 0)
			Format(szDiff, 128, "%cPB: %c-%s%c", WHITE, LIGHTGREEN, szDiff, WHITE);
		else
			Format(szDiff, 128, "%cPB: %c+%s%c", WHITE, RED, szDiff, WHITE);
	}
	else
	{
		Format(szDiff, 128, "%cPB: %c%s%c", WHITE, LIMEGREEN, g_szFinalWrcpTime[client], WHITE);
	}

	if (g_fWrcpRecord[client][stage][style] != -1.0){ // Existing stage time
		if (fDiff >= 0){
			SetNewPersonalRecordPrestrafe(client, stage, style, false, false, true);
		}
	}
	else{
		SetNewPersonalRecordPrestrafe(client, stage, style, false, false, true);
	}

	// SR
	float f_srDiff;
	if (style == 0)
		f_srDiff = (g_fStageRecord[stage] - time);
	else if (style != 0)
		f_srDiff = (g_fStyleStageRecord[style][stage] - time);

	FormatTimeFloat(client, f_srDiff, 3, sz_srRawDiff, 128);

	if (f_srDiff > 0)
	{
		Format(sz_srDiff, 128, "%cSR: %c-%s%c", WHITE, LIGHTGREEN, sz_srRawDiff, WHITE);
		Format(sz_srRawDiff, sizeof sz_srRawDiff, "-%s", sz_srRawDiff);
	}
	else
	{
		Format(sz_srDiff, 128, "%cSR: %c+%s%c", WHITE, RED, sz_srRawDiff, WHITE);
		Format(sz_srRawDiff, sizeof sz_srRawDiff, "+%s", sz_srRawDiff);
	}

	// Check for SR
	bool newRecordHolder = false;
	if (style == 0)
	{
		if (g_TotalStageRecords[stage] > 0)
		{ // If the server already has a record

			if (g_fFinalWrcpTime[client] < g_fStageRecord[stage] && g_fFinalWrcpTime[client] > 0.0)
			{ 
				// New fastest time in map
				g_bStageSRVRecord[client][stage] = true;
				if (g_fWrcpRecord[client][stage][0] != g_fStageRecord[stage])
					newRecordHolder = true;
				g_fStageRecord[stage] = g_fFinalTime[client];
				Format(g_szStageRecordPlayer[stage], MAX_NAME_LENGTH, "%s", szName);
				FormatTimeFloat(1, g_fStageRecord[stage], 3, g_szRecordStageTime[stage], 64);
				CPrintToChatAll("%t", "SQL15", g_szChatPrefix, szName, stage, g_szFinalWrcpTime[client], sz_srDiff, g_TotalStageRecords[stage]);
				g_bSavingWrcpReplay[client] = true;
				// Stage_SaveRecording(client, stage, g_szFinalWrcpTime[client]);
				PlayWRCPRecord();
				SendNewWRCPForward(client, stage, sz_srRawDiff, g_fStageRecord[stage]);

				SetNewRecordPrestrafe(client, stage, 0, false, false, true);
			}
			else
			{
				CPrintToChat(client, "%t", "SQL16", g_szChatPrefix, stage, g_szFinalWrcpTime[client], szDiff, sz_srDiff, g_StageRank[client][stage], g_TotalStageRecords[stage]);

				char szSpecMessage[512];
				Format(szSpecMessage, sizeof(szSpecMessage), "%t", "SQL17", g_szChatPrefix, szName, stage, g_szFinalWrcpTime[client], szDiff, sz_srDiff, g_StageRank[client][stage], g_TotalStageRecords[stage]);
				CheckpointToSpec(client, szSpecMessage);
			}
		}
		else
		{
			// Has to be the new record, since it is the first completion
			newRecordHolder = true;
			g_bStageSRVRecord[client][stage] = true;
			g_fStageRecord[stage] = g_fFinalTime[client];
			Format(g_szStageRecordPlayer[stage], MAX_NAME_LENGTH, "%s", szName);
			FormatTimeFloat(1, g_fStageRecord[stage], 3, g_szRecordStageTime[stage], 64);

			CPrintToChatAll("%t", "SQL18", g_szChatPrefix, szName, stage, g_szFinalWrcpTime[client]);
			g_bSavingWrcpReplay[client] = true;
			// Stage_SaveRecording(client, stage, g_szFinalWrcpTime[client]);
			PlayWRCPRecord();
			SendNewWRCPForward(client, stage, sz_srRawDiff, g_fStageRecord[stage]);

			SetNewRecordPrestrafe(client, stage, 0, false, false, true);
		}
	}
	else if (style != 0) // styles
	{
		if (g_TotalStageStyleRecords[style][stage] > 0)
		{
			// If the server already has a record
			if (g_fFinalWrcpTime[client] < g_fStyleStageRecord[style][stage] && g_fFinalWrcpTime[client] > 0.0)
			{
				// New fastest time in map
				g_bStageSRVRecord[client][stage] = true;
				if (g_fWrcpRecord[client][stage][style] != g_fStyleStageRecord[style][stage])
					newRecordHolder = true;

				g_fStyleStageRecord[style][stage] = g_fFinalTime[client];
				Format(g_szStyleStageRecordPlayer[style][stage], MAX_NAME_LENGTH, "%s", szName);
				FormatTimeFloat(1, g_fStyleStageRecord[style][stage], 3, g_szStyleRecordStageTime[style][stage], 64);

				CPrintToChatAll("%t", "SQL19", g_szChatPrefix, szName, g_szStyleRecordPrint[style], stage, g_szFinalWrcpTime[client], sz_srDiff, g_StyleStageRank[style][client][stage], g_TotalStageStyleRecords[style][stage]);
				PlayWRCPRecord();
				SendNewWRCPForward(client, stage, sz_srRawDiff, g_fStageRecord[stage]);

				SetNewRecordPrestrafe(client, stage, style, false, false, true);
			}
			else
			{
				CPrintToChat(client, "%t", "SQL20", g_szChatPrefix, stage, g_szStyleRecordPrint[style], g_szFinalWrcpTime[client], sz_srDiff, g_StyleStageRank[style][client][stage], g_TotalStageStyleRecords[style][stage]);

				char szSpecMessage[512];
				Format(szSpecMessage, sizeof(szSpecMessage), "%t", "SQL21", g_szChatPrefix, stage, g_szStyleRecordPrint[style], g_szFinalWrcpTime[client], sz_srDiff, g_StyleStageRank[style][client][stage], g_TotalStageStyleRecords[style][stage]);
				CheckpointToSpec(client, szSpecMessage);
			}
		}
		else
		{
			// Has to be the new record, since it is the first completion
			g_bStageSRVRecord[client][stage] = true;
			newRecordHolder = true;
			g_fStyleStageRecord[style][stage] = g_fFinalTime[client];
			Format(g_szStyleStageRecordPlayer[style][stage], MAX_NAME_LENGTH, "%s", szName);
			FormatTimeFloat(1, g_fStyleStageRecord[style][stage], 3, g_szStyleRecordStageTime[style][stage], 64);

			CPrintToChatAll("%t", "SQL22", g_szChatPrefix, szName, g_szStyleRecordPrint[style], stage, g_szFinalWrcpTime[client]);
			PlayWRCPRecord();
			SendNewWRCPForward(client, stage, sz_srRawDiff, g_fStageRecord[stage]);

			SetNewRecordPrestrafe(client, stage, style, false, false, true);
		}
	}

	// Check if new record and if someone else had the old record, if so give them points
	if (g_bStageSRVRecord[client][stage])
	{
		int points = GetConVarInt(g_hWrcpPoints);
		if (style == 0)
		{
			if (newRecordHolder)
			{
				if (points > 0)
				{
					g_pr_oldpoints[client][0] = g_pr_points[client][0];
					g_pr_points[client][0] += points;
					int diff = g_pr_points[client][0] - g_pr_oldpoints[client][0];
					CPrintToChat(client, "%t", "EarnedPoints", g_szChatPrefix, szName, diff, g_pr_points[client][0]);
				}
			}
		}
		else
		{
			if (newRecordHolder)
			{
				if (points > 0)
				{
					g_pr_oldpoints[client][style] = g_pr_points[client][style];
					g_pr_points[client][style] += points;
					int diff = g_pr_points[client][style] - g_pr_oldpoints[client][style];
					CPrintToChat(client, "%t", "EarnedPoints2", g_szChatPrefix, szName, diff, g_szStyleRecordPrint[style], g_pr_points[client][style]);
				}
			}
		}
	}

	g_fWrcpRecord[client][stage][style] = time;

	db_viewStageRecords();

	if (g_bRepeat[client])
	{
		if (stage <= 1)
			Command_Restart(client, 1);
		else
			teleportClient(client, 0, stage, false);
	}

}

// Get players stage rank in current map
public void db_viewPersonalStageRecords(int client, char szSteamId[32])
{
	if (!g_bSettingsLoaded[client] && !g_bhasStages)
	{
		LogQueryTime("[SurfTimer] %s: Skipping db_viewPersonalStageRecords (linear map)", g_szSteamID[client]);
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
		LogError("[SurfTimer] SQL Error (SQL_selectPersonalStageRecordsCallback): %s", error);
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
		LogQueryTime("[SurfTimer] %s: Finished db_viewPersonalStageRecords in %fs", g_szSteamID[client], tick);
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

	// "SELECT name,mapname FROM ck_playertimes WHERE runtimepro <= (SELECT runtimepro FROM ck_playertimes WHERE steamid = '%s' AND mapname = '%s' AND runtimepro > -1.0) AND mapname = '%s' AND runtimepro > -1.0 ORDER BY runtimepro;";
	// SELECT name FROM ck_bonus WHERE runtime <= (SELECT runtime FROM ck_bonus WHERE steamid = '%s' AND mapname= '%s' AND runtime > 0.0 AND zonegroup = %i) AND mapname = '%s' AND zonegroup = %i;
	Format(szQuery, 512, "SELECT COUNT(*) FROM ck_wrcps WHERE runtimepro <= (SELECT runtimepro FROM ck_wrcps WHERE steamid = '%s' AND mapname = '%s' AND runtimepro > -1.0 AND stage = %i AND style = 0) AND mapname = '%s' AND stage = %i AND style = 0 AND runtimepro > -1.0;", g_szSteamID[client], g_szMapName, stage, g_szMapName, stage);
	SQL_TQuery(g_hDb, sql_viewStageRanksCallback, szQuery, pack, DBPrio_Low);
}

public void sql_viewStageRanksCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	ResetPack(pack);
	int client = ReadPackCell(pack);
	int stage = ReadPackCell(pack);
	CloseHandle(pack);

	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (sql_viewStageRanksCallback): %s ", error);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		g_StageRank[client][stage] = SQL_FetchInt(hndl, 0);
	}
}

public void db_viewPersonalPrestrafeSpeeds(int client, char szSteamId[32]){

	selectPersonalPrestrafeSpeeds_Map(client, szSteamId);

}

public void selectPersonalPrestrafeSpeeds_Map(int client, char szSteamId[32]){

	char szQuery[1024];
	Format(szQuery, sizeof(szQuery), "SELECT style, velStartXY, velStartXYZ, velStartZ FROM ck_playertimes WHERE steamid = '%s' AND mapname = '%s' AND runtimepro > '0.0';", szSteamId, g_szMapName);
	SQL_TQuery(g_hDb, SQL_selectPersonalPrestrafeSpeeds_MapCallback, szQuery, client, DBPrio_Low);

}

public void SQL_selectPersonalPrestrafeSpeeds_MapCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null) {
		LogError("[SurfTimer] SQL Error (SQL_selectPersonalPrestrafeSpeeds_MapCallback): %s", error);
		if (g_bhasStages) {
			selectPersonalPrestrafeSpeeds_Stages(client, g_szSteamID[client]);
		}
		else if (g_bhasBonus) {
			selectPersonalPrestrafeSpeeds_Bonus(client, g_szSteamID[client]);
		}
		else {
			if (!g_bSettingsLoaded[client]) {
				LoadClientSetting(client, g_iSettingToLoad[client]);
			}
		}
		return;
	}

	//MAYBE IN FUTURE ADD CP PRESTRAFES SPEEDS AND USE VALUES FOR EACH CHECKPOINT
	//FOR NOW JUST USE THE STARTZONE VALUE

	int style;
	int velStartXY, velStartXYZ, velStartZ;

	for (int i = 0; i < CPLIMIT; i++) {
		for (int s = 0; s < MAX_STYLES; s++) {
			g_iPersonalRecordPreStrafe[client][0][i][s] = 0;
			g_iPersonalRecordPreStrafe[client][1][i][s] = 0;
			g_iPersonalRecordPreStrafe[client][2][i][s] = 0;
		}
	}

	if (SQL_HasResultSet(hndl)) {
		while (SQL_FetchRow(hndl)) {
			style = SQL_FetchInt(hndl, 0);

			velStartXY = SQL_FetchInt(hndl, 1);
			velStartXYZ = SQL_FetchInt(hndl, 2);
			velStartZ = SQL_FetchInt(hndl, 3);

			g_iPersonalRecordPreStrafe[client][0][0][style] = velStartXY;
			g_iPersonalRecordPreStrafe[client][1][0][style] = velStartXYZ;
			g_iPersonalRecordPreStrafe[client][2][0][style] = velStartZ;

		}
	}
	
	if (g_bhasStages) {
		selectPersonalPrestrafeSpeeds_Stages(client, g_szSteamID[client]);
	}
	else if (g_bhasBonus) {
		selectPersonalPrestrafeSpeeds_Bonus(client, g_szSteamID[client]);
	}
	else {
		if (!g_bSettingsLoaded[client])
		{
			g_fTick[client][1] = GetGameTime();
			float tick = g_fTick[client][1] - g_fTick[client][0];
			LogQueryTime("[SurfTimer] %s: Finished db_viewPersonalRecords in %fs", g_szSteamID[client], tick);
			g_fTick[client][0] = GetGameTime();
			LoadClientSetting(client, g_iSettingToLoad[client]);
		}
	}

}

public void selectPersonalPrestrafeSpeeds_Stages(int client, char szSteamId[32]){

	char szQuery[1024];
	Format(szQuery, sizeof(szQuery), "SELECT stage, style, velStartXY, velStartXYZ, velStartZ FROM ck_wrcps WHERE steamid = '%s' AND mapname = '%s' AND runtimepro > '0.0';", szSteamId, g_szMapName);
	SQL_TQuery(g_hDb, SQL_selectPersonalPrestrafeSpeeds_StagesCallback, szQuery, client, DBPrio_Low);

}

public void SQL_selectPersonalPrestrafeSpeeds_StagesCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (SQL_selectPersonalPrestrafeSpeeds_StagesCallback): %s", error);
		if(g_bhasBonus)
			selectPersonalPrestrafeSpeeds_Bonus(client, g_szSteamID[client]);
		else
			if (!g_bSettingsLoaded[client])
				LoadClientSetting(client, g_iSettingToLoad[client]);
		return;
	}

	int style;
	int stage;
	int velStartXY, velStartXYZ, velStartZ;

	for (int i = 0; i < CPLIMIT; i++)
	{
		for (int s = 0; s < MAX_STYLES; s++)
		{
			g_iPersonalRecordPreStrafeStage[client][0][i][s] = 0;
			g_iPersonalRecordPreStrafeStage[client][1][i][s] = 0;
			g_iPersonalRecordPreStrafeStage[client][2][i][s] = 0;

		}
	}

	if (SQL_HasResultSet(hndl))
	{
		while (SQL_FetchRow(hndl))
		{
			stage = SQL_FetchInt(hndl, 0);
			style = SQL_FetchInt(hndl, 1);

			velStartXY = SQL_FetchInt(hndl, 2);
			velStartXYZ = SQL_FetchInt(hndl, 3);
			velStartZ = SQL_FetchInt(hndl, 4);

			g_iPersonalRecordPreStrafeStage[client][0][stage][style] = velStartXY;
			g_iPersonalRecordPreStrafeStage[client][1][stage][style] = velStartXYZ;
			g_iPersonalRecordPreStrafeStage[client][2][stage][style] = velStartZ;

		}
	}

	if(g_bhasBonus)
		selectPersonalPrestrafeSpeeds_Bonus(client, g_szSteamID[client]);
	else{
		if (!g_bSettingsLoaded[client])
		{
			PrintToServer("[SurfTimer] : %s Finished db_viewPersonalPrestrafeSpeeds", g_szSteamID[client]);
			LoadClientSetting(client, g_iSettingToLoad[client]);
		}
	}
}

public void selectPersonalPrestrafeSpeeds_Bonus(int client, char szSteamId[32]){

	char szQuery[1024];
	Format(szQuery, sizeof(szQuery), "SELECT zonegroup, style, velStartXY, velStartXYZ, velStartZ FROM ck_bonus WHERE steamid = '%s' AND mapname = '%s' AND runtime > '0.0';", szSteamId, g_szMapName);
	SQL_TQuery(g_hDb, SQL_selectPersonalPrestrafeSpeeds_BonusCallback, szQuery, client, DBPrio_Low);

}

public void SQL_selectPersonalPrestrafeSpeeds_BonusCallback(Handle owner, Handle hndl, const char[] error, any client)
{	
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (SQL_selectPersonalPrestrafeSpeeds_BonusCallback): %s", error);
		if (!g_bSettingsLoaded[client])
			LoadClientSetting(client, g_iSettingToLoad[client]);
		return;
	}

	int style;
	int zonegroup;
	int velStartXY, velStartXYZ, velStartZ;

	for (int i = 0; i < g_mapZoneGroupCount - 1; i++)
	{
		for (int s = 0; s < MAX_STYLES; s++)
		{
			g_iPersonalRecordPreStrafeBonus[client][0][i][s] = 0;
			g_iPersonalRecordPreStrafeBonus[client][1][i][s] = 0;
			g_iPersonalRecordPreStrafeBonus[client][2][i][s] = 0;
		}
	}

	if (SQL_HasResultSet(hndl))
	{
		while (SQL_FetchRow(hndl))
		{
			zonegroup = SQL_FetchInt(hndl, 0);
			style = SQL_FetchInt(hndl, 1);

			velStartXY = SQL_FetchInt(hndl, 2);
			velStartXYZ = SQL_FetchInt(hndl, 3);
			velStartZ = SQL_FetchInt(hndl, 4);

			g_iPersonalRecordPreStrafeBonus[client][0][zonegroup][style] = velStartXY;
			g_iPersonalRecordPreStrafeBonus[client][1][zonegroup][style] = velStartXYZ;
			g_iPersonalRecordPreStrafeBonus[client][2][zonegroup][style] = velStartZ;

		}
	}

	if (!g_bSettingsLoaded[client])
	{
		PrintToServer("[SurfTimer] : %s Finished db_viewPersonalPrestrafeSpeeds", g_szSteamID[client]);
		LoadClientSetting(client, g_iSettingToLoad[client]);
	}

}

// Get Total Stages
public void db_GetTotalStages()
{
	// Check if map has stages, if not don't bother loading this
	if (!g_bhasStages)
	{
		db_selectTotalBonusCount();
		return;
	}

	char szQuery[512];

	Format(szQuery, 512, "SELECT COUNT(`zonetype`) AS stages FROM `ck_zones` WHERE `zonetype` = '3' AND `mapname` = '%s'", g_szMapName);
	SQL_TQuery(g_hDb, db_GetTotalStagesCallback, szQuery, GetGameTime(), DBPrio_Low);
}

public void db_GetTotalStagesCallback(Handle owner, Handle hndl, const char[] error, float time)
{
	LogQueryTime("[SurfTimer] : Finished db_GetTotalStagesCallback in: %f", GetGameTime() - time);
	
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (db_GetTotalStagesCallback): %s ", error);
		db_viewStageRecords();
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		g_TotalStages = SQL_FetchInt(hndl, 0) + 1;

		for(int i = 1;i <= g_TotalStages;i++)
		{
			g_fStageRecord[i] = 0.0;
			// fluffys comeback yo
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
	int totalstages;
	char mapnameresult[128];
	char stage[MAXPLAYERS + 1];
	char szStageString[MAXPLAYERS + 1];
	ResetPack(pack);
	int client = ReadPackCell(pack);
	char mapname[128];
	ReadPackString(pack, mapname, 128);
	CloseHandle(pack);

	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (sql_viewWrcpMapCallback): %s ", error);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		totalstages = SQL_FetchInt(hndl, 1) + 1;
		SQL_FetchString(hndl, 0, mapnameresult, 128);
		if (totalstages == 0 || totalstages == 1)
		{
			CPrintToChat(client, "%t", "SQL23", g_szChatPrefix, mapname);
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
			SQL_TQuery(g_hDb, sql_viewWrcpMapCallback, szQuery, client, DBPrio_Low);*/
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
		LogError("[SurfTimer] SQL Error (sql_viewWrcpMapRecordCallback): %s ", error);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		if (SQL_IsFieldNull(hndl, 1))
		{
			CPrintToChat(client, "%t", "SQL24", g_szChatPrefix);
			return;
		}

		char szName[MAX_NAME_LENGTH];
		float runtimepro;
		char szRuntimepro[64];

		SQL_FetchString(hndl, 0, szName, 128);
		runtimepro = SQL_FetchFloat(hndl, 1);
		FormatTimeFloat(0, runtimepro, 3, szRuntimepro, 64);

		CPrintToChat(client, "%t", "SQL25", g_szChatPrefix, szName, szRuntimepro, g_szWrcpMapSelect[client], g_szMapName);
		return;
	}
	else
	{
		CPrintToChat(client, "%t", "SQL24", g_szChatPrefix);
	}
}

public void db_selectStageTopSurfers(int client, char info[32], char mapname[128])
{
	char szQuery[1024];
	Format(szQuery, 1024, "SELECT db2.steamid, db1.name, db2.runtimepro as overall, db1.steamid, db2.mapname FROM ck_wrcps as db2 INNER JOIN ck_playerrank as db1 on db2.steamid = db1.steamid WHERE db2.mapname = '%s' AND db2.runtimepro > -1.0 AND db2.stage = %i AND db1.style = 0 AND db2.style = 0 ORDER BY overall ASC LIMIT 50;", mapname, info);
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	// WritePackCell(pack, stage);
	WritePackString(pack, info);
	WritePackString(pack, mapname);
	SQL_TQuery(g_hDb, sql_selectStageTopSurfersCallback, szQuery, pack, DBPrio_Low);
}

public void sql_selectStageTopSurfersCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	ResetPack(pack);
	int client = ReadPackCell(pack);
	char stage[32];
	ReadPackString(pack, stage, 32);
	char mapname[128];
	ReadPackString(pack, mapname, 128);
	CloseHandle(pack);


	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (sql_selectStageTopSurfersCallback): %s ", error);
		return;
	}

	char szSteamID[32];
	char szName[64];
	float time;
	char szMap[128];
	char szValue[128];
	Handle menu;
	menu = CreateMenu(StageTopMenuHandler);
	SetMenuPagination(menu, 5);
	char title[256];
	if (SQL_HasResultSet(hndl))
	{
		int i = 1;
		while (SQL_FetchRow(hndl))
		{
			SQL_FetchString(hndl, 0, szSteamID, 32);
			SQL_FetchString(hndl, 1, szName, 64);
			time = SQL_FetchFloat(hndl, 2);
			SQL_FetchString(hndl, 4, szMap, 128);
			if (i == 1 || (i > 1))
			{
				if (i < 51)
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
					i++;
				}
			}
		}
		if (i == 1)
		{
			CPrintToChat(client, "%t", "SQL26", g_szChatPrefix, stage, mapname);
		}
	}
	else
	CPrintToChat(client, "%t", "SQL26", g_szChatPrefix, stage, mapname);

	Format(title, 256, "[Top 50 | Stage %i | %s] \n    Rank    Time               Player", stage, szMap);
	SetMenuTitle(menu, title);
	SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int StageTopMenuHandler(Menu menu, MenuAction action, int client, int item)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		GetMenuItem(menu, item, info, sizeof(info));
		g_MenuLevel[client] = 3;
		db_viewPlayerProfile(client, g_ProfileStyleSelect[client], info, true, "");
	}
	else if (action == MenuAction_Cancel)
	{
		db_viewWrcpMap(client, g_szWrcpMapSelect[client]);
	}
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

public void db_viewStageRecords()
{
	char szQuery[512];
	Format(szQuery, 512, "SELECT cp1.name, cp1.runtimepro, cp1.stage, cp1.style, cp1.velStartXY, cp1.velStartXYZ, cp1.velstartZ FROM ck_wrcps cp1 JOIN ( SELECT MIN(runtimepro) AS min_runtime, stage, style, mapname FROM ck_wrcps GROUP BY stage, mapname, style ) AS cp2 ON cp1.stage = cp2.stage AND cp1.runtimepro = cp2.min_runtime AND cp1.mapname=cp2.mapname AND cp1.style=cp2.style WHERE cp1.mapname='%s'", g_szMapName);
	SQL_TQuery(g_hDb, sql_viewStageRecordsCallback, szQuery, GetGameTime(), DBPrio_Low);
}

public void sql_viewStageRecordsCallback(Handle owner, Handle hndl, const char[] error, float time)
{
	LogQueryTime("[SurfTimer] : Finished sql_viewStageRecordsCallback in: %f", GetGameTime() - time);
	
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (sql_viewStageRecordsCallback): %s", error);
		if (!g_bServerDataLoaded)
		{
			db_selectTotalBonusCount();
		}
		return;
	}

	for (int i = 1; i < CPLIMIT; i++)
	{
		for (int s = 0; s < MAX_STYLES; s++)
		{
			g_iRecordPreStrafeStage[0][i][s] = 0;
			g_iRecordPreStrafeStage[1][i][s] = 0;
			g_iRecordPreStrafeStage[2][i][s] = 0;
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
			g_iRecordPreStrafeStage[0][stage][style] = SQL_FetchInt(hndl, 4);
			g_iRecordPreStrafeStage[1][stage][style] = SQL_FetchInt(hndl, 5);
			g_iRecordPreStrafeStage[2][stage][style] = SQL_FetchInt(hndl, 6);
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
	SQL_TQuery(g_hDb, sql_viewTotalStageRecordsCallback, szQuery, GetGameTime(), DBPrio_Low);
}

public void sql_viewTotalStageRecordsCallback(Handle owner, Handle hndl, const char[] error, float time)
{
	LogQueryTime("[SurfTimer] : Finished sql_viewTotalStageRecordsCallback in: %f", GetGameTime() - time);
	
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (sql_viewTotalStageRecordsCallback): %s", error);
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

// Styles for maps
public void db_selectPersonalStyleRecord(int client, int style)
{
	if (!IsValidClient(client))
	return;

	Handle stylepack = CreateDataPack();
	WritePackCell(stylepack, client);
	WritePackCell(stylepack, style);

	char szQuery[255];
	Format(szQuery, 255, "SELECT runtimepro FROM `ck_playertimes` WHERE `steamid` = '%s' AND `mapname` = '%s' AND `style` = %i AND `runtimepro` > -1.0", g_szSteamID[client], g_szMapName, style);
	SQL_TQuery(g_hDb, sql_selectPersonalStyleRecordCallback, szQuery, stylepack, DBPrio_Low);
}

public void sql_selectPersonalStyleRecordCallback(Handle owner, Handle hndl, const char[] error, any stylepack)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (sql_selectPersonalStyleRecordCallback): %s", error);
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

		// If old time was slower than the new time, update personal record
		if ((g_fFinalTime[data] <= time || time <= 0.0))
		{
			db_updatePersonalStyleRecord(data, style);
		}
	}
	// No PERSONAL record found from database - Let's insert
	else
	{ 
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

		Format(szQuery, 512, "INSERT INTO ck_playertimes (steamid, mapname, name, runtimepro, style, velStartXY, velStartXYZ, velStartZ) VALUES ('%s', '%s', '%s', '%f', %i, %i, %i, %i)", g_szSteamID[data], g_szMapName, szName, g_fFinalTime[data], style, g_iPreStrafe[0][0][style], g_iPreStrafe[1][0][style], g_iPreStrafe[2][0][style]);
		SQL_TQuery(g_hDb, SQL_UpdatePersonalStyleRecordCallback, szQuery, pack, DBPrio_Low);
	}
}

// If latest record was faster than old - Update time
public void db_updatePersonalStyleRecord(int client, int style)
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
	// "UPDATE ck_playertimes SET name = '%s', runtimepro = '%f' WHERE steamid = '%s' AND mapname = '%s';";
	Format(szQuery, 1024, "UPDATE `ck_playertimes` SET `name` = '%s', runtimepro = '%f', `velStartXY` = %i, `velStartXYZ` = %i, `velStartZ` = %i WHERE `steamid` = '%s' AND `mapname` = '%s' AND `style` = %i;", szName, g_fFinalTime[client], g_iPreStrafe[0][0][style], g_iPreStrafe[1][0][style], g_iPreStrafe[2][0][style], g_szSteamID[client], g_szMapName, style);
	SQL_TQuery(g_hDb, SQL_UpdatePersonalStyleRecordCallback, szQuery, pack, DBPrio_Low);
}

public void SQL_UpdatePersonalStyleRecordCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (SQL_UpdatePersonalStyleRecordCallback): %s", error);
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
	SQL_TQuery(g_hDb, SQL_UpdatePersonalStyleRecordCallback2, szQuery, data, DBPrio_Low);
}

public void SQL_UpdatePersonalStyleRecordCallback2(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (SQL_UpdatePersonalStyleRecordCallback2): %s", error);
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
		LogError("[SurfTimer] SQL Error (sql_selectStyleMapRecordCallback): %s", error);
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
	Format(szQuery, 512, "SELECT name FROM ck_playertimes WHERE mapname = '%s' AND style = %i AND runtimepro > -1.0;", g_szMapName, style);
	SQL_TQuery(g_hDb, sql_selectStylePlayerCountCallback, szQuery, style, DBPrio_Low);
}

public void sql_selectStylePlayerCountCallback(Handle owner, Handle hndl, const char[] error, int style)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (sql_selectStylePlayerCountCallback): %s", error);
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

	Format(szQuery, 512, "SELECT COUNT(*) FROM ck_playertimes WHERE runtimepro <= (SELECT runtimepro FROM ck_playertimes WHERE steamid = '%s' AND mapname = '%s' AND style = %i AND runtimepro > -1.0) AND mapname = '%s' AND style = %i AND runtimepro > -1.0;", g_szSteamID[client], g_szMapName, style, g_szMapName, style);
	SQL_TQuery(g_hDb, db_viewStyleMapRankCallback, szQuery, data, DBPrio_Low);
}

public void db_viewStyleMapRankCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	ResetPack(data);
	int client = ReadPackCell(data);
	int style = ReadPackCell(data);
	CloseHandle(data);

	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (db_viewStyleMapRankCallback): %s ", error);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		g_StyleMapRank[style][client] = SQL_FetchInt(hndl, 0);
	}

	return;
}

public void db_selectStyleMapTopSurfers(int client, char mapname[128], int style)
{
	char szQuery[1024];
	Format(szQuery, 1024, sql_selectTopSurfers, mapname, style, style);
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, mapname);
	WritePackCell(pack, style);
	SQL_TQuery(g_hDb, sql_selectTopSurfersCallback, szQuery, pack, DBPrio_Low);
}

// Styles for bonuses
public void db_insertBonusStyle(int client, char szSteamId[32], char szUName[128], float FinalTime, int zoneGrp, int style)
{	
	if (g_bPracticeMode[client])
		return;
	
	char szQuery[1024];
	char szName[MAX_NAME_LENGTH * 2 + 1];
	SQL_EscapeString(g_hDb, szUName, szName, MAX_NAME_LENGTH * 2 + 1);
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackCell(pack, zoneGrp);
	WritePackCell(pack, style);
	Format(szQuery, 1024, "INSERT INTO ck_bonus (steamid, name, mapname, runtime, zonegroup, style, velStartXY, velStartXYZ, velStartZ) VALUES ('%s', '%s', '%s', '%f', '%i', '%i', '%i', '%i', '%i')", szSteamId, szName, g_szMapName, FinalTime, zoneGrp, style, g_iPreStrafeBonus[0][zoneGrp][style][client], g_iPreStrafeBonus[1][zoneGrp][style][client], g_iPreStrafeBonus[2][zoneGrp][style][client]);
	SQL_TQuery(g_hDb, SQL_insertBonusStyleCallback, szQuery, pack, DBPrio_Low);
}

public void SQL_insertBonusStyleCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	ResetPack(data);
	int client = ReadPackCell(data);
	int zgroup = ReadPackCell(data);
	int style = ReadPackCell(data);
	CloseHandle(data);

	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (SQL_insertBonusStyleCallback): %s", error);
		return;
	}

	db_viewMapRankBonusStyle(client, zgroup, 1, style);
	/*Change to update profile timer, if giving multiplier count or extra points for bonuses
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
	ResetPack(data);
	int client = ReadPackCell(data);
	int zgroup = ReadPackCell(data);
	int type = ReadPackCell(data);
	int style = ReadPackCell(data);
	CloseHandle(data);

	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (db_viewMapRankBonusStyleCallback): %s", error);
		return;
	}

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
		case 1: 
		{
			g_iStyleBonusCount[style][zgroup]++;
			PrintChatBonusStyle(client, zgroup, style);
		}
		case 2: 
		{
			PrintChatBonusStyle(client, zgroup, style);
		}
	}
}

public void db_updateBonusStyle(int client, char szSteamId[32], char szUName[128], float FinalTime, int zoneGrp, int style)
{	
	if (g_bPracticeMode[client])
		return;
	
	char szQuery[1024];
	char szName[MAX_NAME_LENGTH * 2 + 1];
	Handle datapack = CreateDataPack();
	WritePackCell(datapack, client);
	WritePackCell(datapack, zoneGrp);
	WritePackCell(datapack, style);
	SQL_EscapeString(g_hDb, szUName, szName, MAX_NAME_LENGTH * 2 + 1);
	Format(szQuery, 1024, "UPDATE ck_bonus SET runtime = '%f', name = '%s', velStartXY = %i, velStartXYZ = %i, velStartZ = %i WHERE steamid = '%s' AND mapname = '%s' AND zonegroup = %i AND style = %i;", FinalTime, szName, g_iPreStrafeBonus[0][zoneGrp][style][client], g_iPreStrafeBonus[1][zoneGrp][style][client], g_iPreStrafeBonus[2][zoneGrp][style][client], szSteamId, g_szMapName, zoneGrp, style);
	SQL_TQuery(g_hDb, SQL_updateBonusStyleCallback, szQuery, datapack, DBPrio_Low);
}


public void SQL_updateBonusStyleCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	ResetPack(data);
	int client = ReadPackCell(data);
	int zgroup = ReadPackCell(data);
	int style = ReadPackCell(data);
	CloseHandle(data);

	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (SQL_updateBonusCallback): %s", error);
		return;
	}

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
	ResetPack(pack);
	int client = ReadPackCell(pack);
	int zGroup = ReadPackCell(pack);
	int style = ReadPackCell(pack);
	CloseHandle(pack);

	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (db_viewBonusStyleRunRank): %s", error);
		return;
	}

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
	// "SELECT runtime, zonegroup FROM ck_bonus WHERE steamid = '%s' AND mapname = '%s' AND runtime > '0.0'";
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
		LogError("[SurfTimer] SQL Error (SQL_selectPersonalBonusRecordsCallback): %s", error);

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
				// db_viewMapRankBonus(client, zgroup, 0); // get rank
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

// Style WRCPS
public void db_viewStyleStageRanks(int client, int stage, int style)
{
	char szQuery[512];
	if (!IsValidClient(client))
	return;

	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackCell(pack, stage);
	WritePackCell(pack, style);

	Format(szQuery, 512, "SELECT COUNT(*) FROM ck_wrcps WHERE runtimepro <= (SELECT runtimepro FROM ck_wrcps WHERE steamid = '%s' AND mapname = '%s' AND stage = %i AND style = %i AND runtimepro > -1.0) AND mapname = '%s' AND stage = %i AND style = %i AND runtimepro > -1.0;", g_szSteamID[client], g_szMapName, stage, style, g_szMapName, stage, style);
	SQL_TQuery(g_hDb, sql_viewStyleStageRanksCallback, szQuery, pack, DBPrio_Low);
}

public void sql_viewStyleStageRanksCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	ResetPack(pack);
	int client = ReadPackCell(pack);
	int stage = ReadPackCell(pack);
	int style = ReadPackCell(pack);
	CloseHandle(pack);

	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (sql_viewStyleStageRanksCallback): %s ", error);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		g_StyleStageRank[style][client][stage] = SQL_FetchInt(hndl, 0);
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
	ResetPack(pack);
	int client = ReadPackCell(pack);
	int style = ReadPackCell(pack);
	CloseHandle(pack);

	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (sql_viewWrcpMapCallback): %s ", error);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		char szName[MAX_NAME_LENGTH];
		float runtimepro;
		char szRuntimepro[64];

		SQL_FetchString(hndl, 0, szName, 128);
		runtimepro = SQL_FetchFloat(hndl, 1);
		FormatTimeFloat(0, runtimepro, 3, szRuntimepro, 64);

		CPrintToChat(client, "%t", "SQL27", g_szChatPrefix, szName, g_szStyleRecordPrint[style], szRuntimepro, g_szWrcpMapSelect[client], g_szMapName);
		return;
	}
	else
	{
		CPrintToChat(client, "%t", "SQL24", g_szChatPrefix);
	}
}

public void db_viewStyleWrcpMap(int client, char mapname[128], int style)
{
	char szQuery[1024];
	Format(szQuery, 512, "SELECT `mapname`, COUNT(`zonetype`) AS stages FROM `ck_zones` WHERE `zonetype` = '3' AND `mapname` = (SELECT DISTINCT `mapname` FROM `ck_zones` WHERE `zonetype` = '3' AND `mapname` LIKE '%c%s%c' LIMIT 0, 1)", PERCENT, g_szWrcpMapSelect[client], PERCENT);
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackCell(pack, style);
	WritePackString(pack, mapname);
	SQL_TQuery(g_hDb, sql_viewStyleWrcpMapCallback, szQuery, pack, DBPrio_Low);
}

public void sql_viewStyleWrcpMapCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	int totalstages;
	char mapnameresult[128];
	char stage[MAXPLAYERS + 1];
	char szStageString[MAXPLAYERS + 1];
	ResetPack(pack);
	int client = ReadPackCell(pack);
	int style = ReadPackCell(pack);
	char mapname[128];
	ReadPackString(pack, mapname, 128);
	CloseHandle(pack);

	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (sql_viewWrcpMapCallback): %s ", error);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		totalstages = SQL_FetchInt(hndl, 1) + 1;
		SQL_FetchString(hndl, 0, mapnameresult, 128);
		if (totalstages == 0 || totalstages == 1)
		{
			CPrintToChat(client, "%t", "SQL23", g_szChatPrefix, mapname);
			return;
		}

		if (pack != INVALID_HANDLE)
		{
			g_StyleStageSelect[client] = style;
			g_szWrcpMapSelect[client] = mapnameresult;
			Menu menu;
			menu = CreateMenu(StageStyleSelectMenuHandler);

			SetMenuTitle(menu, "%s: select a stage [%s]\n------------------------------\n", mapnameresult, g_szStyleMenuPrint[style]);
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
	Format(szQuery, 1024, "SELECT db2.steamid, db1.name, db2.runtimepro as overall, db1.steamid, db2.mapname FROM ck_wrcps as db2 INNER JOIN ck_playerrank as db1 on db2.steamid = db1.steamid WHERE db2.mapname = '%s' AND db1.style = %i AND db2.style = %i AND db2.stage = %i AND db2.runtimepro > -1.0 ORDER BY overall ASC LIMIT 50;", mapname, style, style, info);
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackCell(pack, style);
	// WritePackCell(pack, stage);
	WritePackString(pack, info);
	WritePackString(pack, mapname);
	SQL_TQuery(g_hDb, sql_selectStageStyleTopSurfersCallback, szQuery, pack, DBPrio_Low);
}

public void sql_selectStageStyleTopSurfersCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	ResetPack(pack);
	int client = ReadPackCell(pack);
	int style = ReadPackCell(pack);
	char stage[32];
	ReadPackString(pack, stage, 32);
	char mapname[128];
	ReadPackString(pack, mapname, 128);
	CloseHandle(pack);

	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (sql_selectStageStyleTopSurfersCallback): %s ", error);
		return;
	}

	char szSteamID[32];
	char szName[64];
	float time;
	char szMap[128];
	char szValue[128];
	Handle menu;
	menu = CreateMenu(StageStyleTopMenuHandler);
	SetMenuPagination(menu, 5);
	char title[256];
	if (SQL_HasResultSet(hndl))
	{
		int i = 1;
		while (SQL_FetchRow(hndl))
		{
			SQL_FetchString(hndl, 0, szSteamID, 32);
			SQL_FetchString(hndl, 1, szName, 64);
			time = SQL_FetchFloat(hndl, 2);
			SQL_FetchString(hndl, 4, szMap, 128);
			if (i == 1 || (i > 1))
			{
				if (i < 51)
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
					i++;
				}
			}
		}
		if (i == 1)
		{
			CPrintToChat(client, "%t", "SQL26", g_szChatPrefix, stage, mapname);
		}
	}
	else
	CPrintToChat(client, "%t", "SQL26", g_szChatPrefix, stage, mapname);

	Format(title, 256, "[Top 50 %s | Stage %i | %s] \n    Rank    Time               Player", g_szStyleMenuPrint[style], stage, szMap);
	SetMenuTitle(menu, title);
	SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int StageStyleTopMenuHandler(Menu menu, MenuAction action, int client, int item)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		GetMenuItem(menu, item, info, sizeof(info));
		g_MenuLevel[client] = 3;
		db_viewPlayerProfile(client, g_ProfileStyleSelect[client], info, true, "");
	}
	else if (action == MenuAction_Cancel)
	{
			db_viewStyleWrcpMap(client, g_szWrcpMapSelect[client], g_iWrcpMenuStyleSelect[client]);
	}
	else if (action == MenuAction_End)
		delete menu;

	return 0;
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
		CPrintToChat(client, "%t", "SQL28", g_szChatPrefix);
	}
}

public void db_SelectTotalMapCompletesCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (db_SelectTotalMapCompletesCallback): %s ", error);
		CloseHandle(pack);
		return;
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
	ResetPack(pack);
	int client = ReadPackCell(pack);
	char szSteamId[32];
	char playername[MAX_NAME_LENGTH];
	char mapname[128];
	ReadPackString(pack, szSteamId, 32);
	ReadPackString(pack, playername, sizeof(playername));
	ReadPackString(pack, mapname, sizeof(mapname));
	CloseHandle(pack);

	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (db_SelectPlayersMapRankCallback): %s ", error);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		int rank;
		rank = SQL_GetRowCount(hndl);

		if (StrEqual(mapname, g_szMapName))
		{
			char szGroup[128];
			if (rank >= 11 && rank <= g_G1Top)
				Format(szGroup, 128, "[%cGroup 1%c]", DARKRED, WHITE);
			else if (rank >= g_G2Bot && rank <= g_G2Top)
				Format(szGroup, 128, "[%cGroup 2%c]", GREEN, WHITE);
			else if (rank >= g_G3Bot && rank <= g_G3Top)
				Format(szGroup, 128, "[%cGroup 3%c]", BLUE, WHITE);
			else if (rank >= g_G4Bot && rank <= g_G4Top)
				Format(szGroup, 128, "[%cGroup 4%c]", YELLOW, WHITE);
			else if (rank >= g_G5Bot && rank <= g_G5Top)
				Format(szGroup, 128, "[%cGroup 5%c]", GRAY, WHITE);
			else
				Format(szGroup, 128, "");

			if (rank >= 11 && rank <= g_G5Top)
				CPrintToChatAll("%t", "SQL29", g_szChatPrefix, playername, rank, g_totalPlayerTimes[client], szGroup, g_szRuntimepro[client], mapname);
			else
				CPrintToChatAll("%t", "SQL30", g_szChatPrefix, playername, rank, g_totalPlayerTimes[client], g_szRuntimepro[client], mapname);
		}
		else
		{
			CPrintToChatAll("%t", "SQL31", g_szChatPrefix, playername, rank, g_totalPlayerTimes[client], g_szRuntimepro[client], mapname);
		}
	}
	else
	{
		CloseHandle(pack);
	}
}

// sm_mrank @x command with map parameter
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

// sm_mrank @x command without map parameter (current mapname being used)
public void db_selectMapRankUnknownWithMap(int client, char szMapName[128], int rank)
{
	char szQuery[1024];
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackCell(pack, rank);

	rank = Math_Min(rank - 1, 0);
	Format(szQuery, 1024, sql_selectMapRankUnknownWithMap, szMapName, rank);
	SQL_TQuery(g_hDb, db_selectMapRankUnknownCallback, szQuery, pack, DBPrio_Low);
}

public void db_selectMapRankUnknownCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	ResetPack(data);
	int client = ReadPackCell(data);
	int rank = ReadPackCell(data);
	CloseHandle(data);

	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (db_selectMapRankUnknownCallback): %s", error);
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
		CPrintToChat(client, "%t", "SQL28", g_szChatPrefix);
	}
}

public void db_SelectTotalMapCompletesUnknownCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
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

	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (db_SelectTotalMapCompletesUnknownCallback): %s ", error);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		int totalplayers = SQL_FetchInt(hndl, 0);

		if (StrEqual(mapname, g_szMapName))
		{
			char szGroup[128];
			if (rank >= 11 && rank <= g_G1Top)
				Format(szGroup, 128, "[%cGroup 1%c]", DARKRED, WHITE);
			else if (rank >= g_G2Bot && rank <= g_G2Top)
				Format(szGroup, 128, "[%cGroup 2%c]", GREEN, WHITE);
			else if (rank >= g_G3Bot && rank <= g_G3Top)
				Format(szGroup, 128, "[%cGroup 3%c]", BLUE, WHITE);
			else if (rank >= g_G4Bot && rank <= g_G4Top)
				Format(szGroup, 128, "[%cGroup 4%c]", YELLOW, WHITE);
			else if (rank >= g_G5Bot && rank <= g_G5Top)
				Format(szGroup, 128, "[%cGroup 5%c]", GRAY, WHITE);
			else
				Format(szGroup, 128, "");

			if (rank >= 11 && rank <= g_G5Top)
				CPrintToChatAll("%t", "SQL33", g_szChatPrefix, playername, rank, totalplayers, szGroup, g_szRuntimepro[client], mapname);
			else
				CPrintToChatAll("%t", "SQL34", g_szChatPrefix, playername, rank, totalplayers, g_szRuntimepro[client], mapname);
		}
		else
		{
			CPrintToChatAll("%t", "SQL35", g_szChatPrefix, playername, rank, totalplayers, g_szRuntimepro[client], mapname);
		}
	}
	else
	{
		CPrintToChat(client, "%t", "SQL28", g_szChatPrefix);
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
		LogError("[SurfTimer] SQL Error (db_selectBonusRankCallback): %s", error);
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
		CPrintToChat(client, "%t", "SQL28", g_szChatPrefix);
	}
}

public void db_SelectTotalBonusCompletesCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (db_SelectTotalBonusCompletesCallback): %s ", error);
		CloseHandle(pack);
		return;
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

	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (db_SelectPlayersBonusRankCallback): %s ", error);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		int rank;
		rank = SQL_GetRowCount(hndl);

		CPrintToChatAll("%t", "SQL36", g_szChatPrefix, playername, rank, g_totalPlayerTimes[client], g_szRuntimepro[client], bonus, mapname);
	}
}

public void db_selectMapRecordTime(int client, char szMapName[128])
{
	char szQuery[1024];

	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, szMapName);

	Format(szQuery, 1024, "SELECT db1.runtimepro, IFNULL(db1.mapname, 'NULL'), db2.name, db1.steamid FROM ck_playertimes db1 INNER JOIN ck_playerrank db2 ON db1.steamid = db2.steamid WHERE mapname LIKE '%c%s%c' AND runtimepro > -1.0 AND db1.style = 0 AND db2.style = 0 ORDER BY runtimepro ASC LIMIT 1", PERCENT, szMapName, PERCENT);
	SQL_TQuery(g_hDb, db_selectMapRecordTimeCallback, szQuery, pack, DBPrio_Low);
}

public void db_selectMapRecordTimeCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	ResetPack(pack);
	int client = ReadPackCell(pack);
	char szMapNameArg[128];
	ReadPackString(pack, szMapNameArg, sizeof(szMapNameArg));
	CloseHandle(pack);

	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (db_selectMapRecordTimeCallback): %s", error);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		float runtimepro;
		char szMapName[128];
		char szRecord[64];
		char szName[64];
		runtimepro = SQL_FetchFloat(hndl, 0);
		SQL_FetchString(hndl, 1, szMapName, sizeof(szMapName));
		SQL_FetchString(hndl, 2, szName, sizeof(szName));

		if (StrEqual(szMapName, "NULL"))
		{
			CPrintToChat(client, "%t", "NoMapFound", g_szChatPrefix, szMapNameArg);
		}
		else
		{
			FormatTimeFloat(client, runtimepro, 3, szRecord, sizeof(szRecord));

			CPrintToChat(client, "%t", "SQL38", g_szChatPrefix, szName, szRecord, szMapName);
		}
	}
	else
	{
		CPrintToChat(client, "%t", "NoMapFound", g_szChatPrefix, szMapNameArg);
	}
}

public void db_selectPlayerRank(int client, int rank, char szSteamId[32])
{
	char szQuery[1024];

	if (StrContains(szSteamId, "none", false)!= -1 && rank > 0) // Select Rank Number
	{
		g_rankArg[client] = rank;
		rank -= 1;
		Format(szQuery, 1024, "SELECT `name`, `points` FROM `ck_playerrank` WHERE `style` = 0 ORDER BY `points` DESC LIMIT %i, 1;", rank);
	}
	else if (rank == 0) // Self Rank Cmd
	{
		g_rankArg[client] = -1;
		Format(szQuery, 1024, "SELECT `name`, `points` FROM `ck_playerrank` WHERE `steamid` = '%s' AND `style` = 0;", szSteamId);
	}

	SQL_TQuery(g_hDb, db_selectPlayerRankCallback, szQuery, client, DBPrio_Low);
}

public void db_selectPlayerRankCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (db_selectPlayerRankCallback): %s", error);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		char szName[32];
		int points;
		int rank;

		SQL_FetchString(hndl, 0, szName, sizeof(szName));
		points = SQL_FetchInt(hndl, 1);

		if (g_rankArg[client] == -1)
		{
			rank = g_PlayerRank[client][0];
			g_rankArg[client] = 1;
		}
		else
			rank = g_rankArg[client];

		CPrintToChatAll("%t", "SQL39", g_szChatPrefix, szName, rank, g_pr_RankedPlayers, points);
	}
	else
		CPrintToChat(client, "%t", "SQLTwo7", g_szChatPrefix);
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
		LogError("[SurfTimer] SQL Error (db_selectPlayerRankUnknownCallback): %s", error);
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
		// "SELECT name FROM ck_playerrank WHERE points >= (SELECT points FROM ck_playerrank WHERE steamid = '%s') ORDER BY points";
		Format(szQuery, 512, sql_selectRankedPlayersRank, 0, szSteamId, 0);
		SQL_TQuery(g_hDb, db_getPlayerRankUnknownCallback, szQuery, pack, DBPrio_Low);
	}
	else
		CPrintToChat(client, "%t", "SQLTwo7", g_szChatPrefix);
}

public void db_getPlayerRankUnknownCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	ResetPack(pack);
	char szSteamId[32];
	char szName[128];
	ReadPackString(pack, szSteamId, sizeof(szSteamId));
	ReadPackString(pack, szName, sizeof(szName));
	int points = ReadPackCell(pack);
	int client = ReadPackCell(pack);
	CloseHandle(pack);

	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (db_getPlayerRankUnknownCallback): %s", error);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		int playerrank = SQL_GetRowCount(hndl);

		CPrintToChatAll("%t", "SQL39", g_szChatPrefix, szName, playerrank, g_pr_RankedPlayers, points);
	}
	else
		CPrintToChat(client, "%t", "SQL40", g_szChatPrefix, szName);
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
		LogError("[SurfTimer] SQL Error (db_selectMapImprovementCallback): %s", error);
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
		if (tier == 1)
			mapcompletion = 25;
		else if (tier == 2)
			mapcompletion = 50;
		else if (tier == 3)
			mapcompletion = 100;
		else if (tier == 4)
			mapcompletion = 200;
		else if (tier == 5)
			mapcompletion = 400;
		else if (tier == 6)
			mapcompletion = 600;
		else if (tier == 7)
			mapcompletion = 800;
		else if (tier == 8)
			mapcompletion = 1000;
		else // no tier
			mapcompletion = 13;

		// Calculate Group Ranks
		float wrpoints;
		// float points;
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
		if (g1difference < 4)
			g1top = (g1bot + 4);


		// Group 2
		float fG2top;
		int g2top;
		int g2bot;
		g2bot = g1top + 1;
		fG2top = (float(totalplayers) * g_Group2Pc);
		fG2top += 11.0;
		g2top = RoundToCeil(fG2top);

		int g2difference = (g2top - g2bot);
		if (g2difference < 4)
			g2top = (g2bot + 4);

		// Group 3
		float fG3top;
		int g3top;
		int g3bot;
		g3bot = g2top + 1;
		fG3top = (float(totalplayers) * g_Group3Pc);
		fG3top += 11.0;
		g3top = RoundToCeil(fG3top);

		int g3difference = (g3top - g3bot);
		if (g3difference < 4)
			g3top = (g3bot + 4);

		// Group 4
		float fG4top;
		int g4top;
		int g4bot;
		g4bot = g3top + 1;
		fG4top = (float(totalplayers) * g_Group4Pc);
		fG4top += 11.0;
		g4top = RoundToCeil(fG4top);

		int g4difference = (g4top - g4bot);
		if (g4difference < 4)
			g4top = (g4bot + 4);

		// Group 5
		float fG5top;
		int g5top;
		int g5bot;
		g5bot = g4top + 1;
		fG5top = (float(totalplayers) * g_Group5Pc);
		fG5top += 11.0;
		g5top = RoundToCeil(fG5top);

		int g5difference = (g5top - g5bot);
		if (g5difference < 4)
			g5top = (g5bot + 4);

		// WR Points
		if (tier == 1)
		{
			wrpoints = ((float(totalplayers) * 1.75) / 6);
			wrpoints += 58.5;
			if (wrpoints < 250.0)
				wrpoints = 250.0;
		}
		else if (tier == 2)
		{
			wrpoints = ((float(totalplayers) * 2.8) / 5);
			wrpoints += 82.15;
			if (wrpoints < 500.0)
				wrpoints = 500.0;
		}
		else if (tier == 3)
		{
			wrpoints = ((float(totalplayers) * 3.5) / 4);
			if (wrpoints < 750.0)
				wrpoints = 750.0;
			else
				wrpoints += 117;
		}
		else if (tier == 4)
		{
			wrpoints = ((float(totalplayers) * 5.74) / 4);
			if (wrpoints < 1000.0)
				wrpoints = 1000.0;
			else
				wrpoints += 164.25;
		}
		else if (tier == 5)
		{
			wrpoints = ((float(totalplayers) * 7) / 4);
			if (wrpoints < 1250.0)
				wrpoints = 1250.0;
			else
				wrpoints += 234;
		}
		else if (tier == 6)
		{
			wrpoints = ((float(totalplayers) * 14) / 4);
			if (wrpoints < 1500.0)
				wrpoints = 1500.0;
			else
				wrpoints += 328;
		}
		else if (tier == 7)
		{
			wrpoints = ((float(totalplayers) * 21) / 4);
			if (wrpoints < 1750.0)
				wrpoints = 1750.0;
			else
				wrpoints += 420;
		}
		else if (tier == 8)
		{
			wrpoints = ((float(totalplayers) * 30) / 4);
			if (wrpoints < 2000.0)
				wrpoints = 2000.0;
			else
				wrpoints += 560;
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
		if (type == 0)
		{
			Menu mi = CreateMenu(MapImprovementMenuHandler);
			SetMenuTitle(mi, "[Point Reward: %s]\n------------------------------\nTier: %i\n \nMapper: %s\n \n[Completion Points]\n \nMap Finish Points: %i\n \n[Map Improvement Groups]\n \n[Group 1] Ranks 11-%i ~ %i Pts\n[Group 2] Ranks %i-%i ~ %i Pts\n[Group 3] Ranks %i-%i ~ %i Pts\n[Group 4] Ranks %i-%i ~ %i Pts\n[Group 5] Ranks %i-%i ~ %i Pts\n \nSR Pts: %i\n \nTotal Completions: %i\n \n",szMapName, tier, g_szMapperName, mapcompletion, g1top, RoundFloat(g1points), g2bot, g2top, RoundFloat(g2points), g3bot, g3top, RoundFloat(g3points), g4bot, g4top, RoundFloat(g4points), g5bot, g5top, RoundFloat(g5points), iwrpoints, totalplayers);
			// AddMenuItem(mi, "", "", ITEMDRAW_SPACER);
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
		CPrintToChat(client, "%t", "SQL28", g_szChatPrefix);
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
		delete mi;

	return 0;
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
		delete mi;
	}

	return 0;
}

public void db_selectCurrentMapImprovement()
{
	char szQuery[1024];
	Format(szQuery, 1024, "SELECT mapname, (SELECT count(1) FROM ck_playertimes b WHERE a.mapname = b.mapname AND b.style = 0) as total FROM ck_playertimes a where mapname = '%s' AND style = 0 LIMIT 0, 1;", g_szMapName);
	SQL_TQuery(g_hDb, db_selectMapCurrentImprovementCallback, szQuery, GetGameTime(), DBPrio_Low);
}

public void db_selectMapCurrentImprovementCallback(Handle owner, Handle hndl, const char[] error, float time)
{
	LogQueryTime("[SurfTimer] : Finished db_selectMapCurrentImprovementCallback in: %f", GetGameTime() - time);

	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (db_selectMapCurrentImprovementCallback): %s", error);
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
		if (g1difference < 4)
			g1top = (g1bot + 4);

		g_G1Top = g1top;

		// Group 2
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
		if (g2difference < 4)
			g2top = (g2bot + 4);

		g_G2Bot = g2bot;
		g_G2Top = g2top;

		// Group 3
		float fG3top;
		int g3top;
		int g3bot;
		g3bot = g2top + 1;
		fG3top = (float(totalplayers) * g_Group3Pc);
		fG3top += 11.0;
		g3top = RoundToCeil(fG3top);

		int g3difference = (g3top - g3bot);
		if (g3difference < 4)
			g3top = (g3bot + 4);

		g_G3Bot = g3bot;
		g_G3Top = g3top;

		// Group 4
		float fG4top;
		int g4top;
		int g4bot;
		g4bot = g3top + 1;
		fG4top = (float(totalplayers) * g_Group4Pc);
		fG4top += 11.0;
		g4top = RoundToCeil(fG4top);

		int g4difference = (g4top - g4bot);
		if (g4difference < 4)
			g4top = (g4bot + 4);

		g_G4Bot = g4bot;
		g_G4Top = g4top;

		// Group 5
		float fG5top;
		int g5top;
		int g5bot;
		g5bot = g4top + 1;
		fG5top = (float(totalplayers) * g_Group5Pc);
		fG5top += 11.0;
		g5top = RoundToCeil(fG5top);

		int g5difference = (g5top - g5bot);
		if (g5difference < 4)
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

public void db_selectMapNameEquals(int client, char[] szMapName, int style)
{
	char szQuery[256];
	Format(szQuery, sizeof(szQuery), "SELECT DISTINCT mapname FROM ck_zones WHERE mapname = '%s' LIMIT 1;", szMapName);

	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackCell(pack, style);
	WritePackString(pack, szMapName);

	SQL_TQuery(g_hDb, sql_selectMapNameEqualsCallback, szQuery, pack, DBPrio_Low);
}

public void sql_selectMapNameEqualsCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (sql_selectMapNameEqualsCallback): %s", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	int style = ReadPackCell(pack);
	char szMapName[128];
	ReadPackString(pack, szMapName, sizeof(szMapName));

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		SQL_FetchString(hndl, 0, g_szMapNameFromDatabase[client], sizeof(g_szMapNameFromDatabase));
		if (style == 0)
		{
			g_ProfileStyleSelect[client] = 0;
			db_selectMapTopSurfers(client, g_szMapNameFromDatabase[client]);
		}
		else
		{
			g_ProfileStyleSelect[client] = style;
			db_selectStyleMapTopSurfers(client, g_szMapNameFromDatabase[client], style);
		}
	}
	else
	{
		Format(g_szMapNameFromDatabase[client], sizeof(g_szMapNameFromDatabase), "invalid");
		char szQuery[256];
		Format(szQuery, sizeof(szQuery), "SELECT DISTINCT mapname FROM ck_zones WHERE mapname LIKE '%c%s%c';", PERCENT, szMapName, PERCENT);
		SQL_TQuery(g_hDb, sql_selectMapNameLikeCallback, szQuery, pack, DBPrio_Low);
	}
}

public void sql_selectMapNameLikeCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	ResetPack(pack);
	int client = ReadPackCell(pack);
	int style = ReadPackCell(pack);
	char szMapName[128];
	ReadPackString(pack, szMapName, sizeof(szMapName));
	CloseHandle(pack);

	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (sql_selectMapNameLikeCallback): %s", error);
		return;
	}

	if (SQL_HasResultSet(hndl))
	{
		int count = SQL_GetRowCount(hndl);
		if (count > 1)
		{
			char szMapName2[128];
			Menu menu = CreateMenu(ChooseMapMenuHandler);
			g_ProfileStyleSelect[client] = style;

			while (SQL_FetchRow(hndl))
			{
				SQL_FetchString(hndl, 0, szMapName2, sizeof(szMapName2));
				AddMenuItem(menu, szMapName2, szMapName2);
			}

			SetMenuTitle(menu, "Choose a map:");
			SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
			DisplayMenu(menu, client, MENU_TIME_FOREVER);
		}
		else
		{
			if (SQL_FetchRow(hndl))
			{
				SQL_FetchString(hndl, 0, g_szMapNameFromDatabase[client], sizeof(g_szMapNameFromDatabase));
				if (style == 0)
				{
					g_ProfileStyleSelect[client] = 0;
					db_selectMapTopSurfers(client, g_szMapNameFromDatabase[client]);
				}
				else
				{
					g_ProfileStyleSelect[client] = style;
					db_selectStyleMapTopSurfers(client, g_szMapNameFromDatabase[client], style);
				}
			}
			else
				CPrintToChat(client, "%t", "NoMapFound", g_szChatPrefix, szMapName);
		}
	}
	else
		CPrintToChat(client, "%t", "NoMapFound", g_szChatPrefix, szMapName);
}

public int ChooseMapMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		GetMenuItem(menu, param2, g_szMapNameFromDatabase[param1], sizeof(g_szMapNameFromDatabase));
		int style = g_ProfileStyleSelect[param1];
		if (style == 0)
		{
			g_ProfileStyleSelect[param1] = 0;
			db_selectMapTopSurfers(param1, g_szMapNameFromDatabase[param1]);
		}
		else
		{
			db_selectStyleMapTopSurfers(param1, g_szMapNameFromDatabase[param1], style);
		}
	}
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

// sm_pr command
public void db_viewPlayerPr(int client, char szSteamId[32], char szMapName[128])
{
	char szQuery[1024];
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, szSteamId);

	char szUpper[128];
	char szUpper2[128];
	Format(szUpper, 128, "%s", szMapName);
	Format(szUpper2, 128, "%s", g_szMapName);
	StringToUpper(szUpper);
	StringToUpper(szUpper2);

	if (StrEqual(szUpper, szUpper2)) // is the mapname the current map?
	{
		WritePackString(pack, szMapName);
		WritePackCell(pack, g_TotalStages);
		WritePackCell(pack, g_mapZoneGroupCount);
		// first select map time
		Format(szQuery, 1024, "SELECT steamid, name, mapname, runtimepro, (select count(name) FROM ck_playertimes WHERE mapname = '%s' AND style = 0) as total FROM ck_playertimes WHERE runtimepro <= (SELECT runtimepro FROM ck_playertimes WHERE steamid = '%s' AND mapname = '%s' AND runtimepro > -1.0 AND style = 0) AND mapname = '%s' AND runtimepro > -1.0 AND style = 0 ORDER BY runtimepro;", szMapName, szSteamId, szMapName, szMapName);
		SQL_TQuery(g_hDb, SQL_ViewPlayerPrMaptimeCallback, szQuery, pack, DBPrio_Low);
	}
	else
	{
		Format(szQuery, 1024, "SELECT mapname FROM ck_maptier WHERE mapname LIKE '%c%s%c' LIMIT 1;", PERCENT, szMapName, PERCENT);
		SQL_TQuery(g_hDb, SQL_ViewMapNamePrCallback, szQuery, pack, DBPrio_Low);
	}
}

public void SQL_ViewMapNamePrCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	ResetPack(pack);
	int client = ReadPackCell(pack);
	char szSteamId[32];
	ReadPackString(pack, szSteamId, 32);
	
	if (hndl == null)
	{
		LogError("[surftimer] SQL Error (SQL_ViewMapNamePrCallback): %s ", error);
		CPrintToChat(client, "%t", "SQLTwo1", g_szChatPrefix);
		CloseHandle(pack);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		char szMapName[128];
		SQL_FetchString(hndl, 0, szMapName, 128);
		WritePackString(pack, szMapName);

		char szQuery[1024];
		Format(szQuery, 1024, "SELECT mapname, (SELECT COUNT(1) FROM ck_zones WHERE zonetype = '3' AND mapname = '%s') AS stages, (SELECT COUNT(DISTINCT zonegroup) FROM ck_zones WHERE mapname = '%s' AND zonegroup > 0) AS bonuses FROM ck_maptier WHERE mapname = '%s';", szMapName, szMapName, szMapName);
		SQL_TQuery(g_hDb, SQL_ViewPlayerPrMapInfoCallback, szQuery, pack, DBPrio_Low);
	}
}

public void SQL_ViewPlayerPrMapInfoCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[surftimer] SQL Error (SQL_ViewPlayerPrMapInfoCallback): %s ", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	char szSteamId[32];
	char szMapName[128];
	ReadPackString(pack, szSteamId, 32);
	ReadPackString(pack, szMapName, 128);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		g_totalStagesPr[client] = SQL_FetchInt(hndl, 1);
		g_totalBonusesPr[client] = SQL_FetchInt(hndl, 2);

		if (g_totalStagesPr[client] != 0)
			g_totalStagesPr[client]++;

		if (g_totalBonusesPr[client] != 0)
			g_totalBonusesPr[client]++;

		char szQuery[1024];
		Format(szQuery, 1024, "SELECT steamid, name, mapname, runtimepro, (select count(name) FROM ck_playertimes WHERE mapname = '%s' AND style = 0) as total FROM ck_playertimes WHERE runtimepro <= (SELECT runtimepro FROM ck_playertimes WHERE steamid = '%s' AND mapname = '%s' AND runtimepro > -1.0 AND style = 0) AND mapname = '%s' AND runtimepro > -1.0 AND style = 0 ORDER BY runtimepro;", szMapName, szSteamId, szMapName, szMapName);
		SQL_TQuery(g_hDb, SQL_ViewPlayerPrMaptimeCallback, szQuery, pack, DBPrio_Low);
	}
}

public void SQL_ViewPlayerPrMaptimeCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[surftimer] SQL Error (SQL_ViewPlayerPrMaptimeCallback): %s ", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	char szSteamId[32];
	char szMapName[128];
	ReadPackString(pack, szSteamId, 32);
	ReadPackString(pack, szMapName, 128);

	float time = -1.0;
	int total;
	int rank = 0;
	if (SQL_HasResultSet(hndl) && IsValidClient(client))
	{
		int i = 1;
		char szSteamId2[32];
		while (SQL_FetchRow(hndl))
		{
			if (i == 1)
				total = SQL_FetchInt(hndl, 4);
			i++;
			rank++;

			SQL_FetchString(hndl, 0, szSteamId2, 32);
			if (StrEqual(szSteamId, szSteamId2))
			{
				time = SQL_FetchFloat(hndl, 3);
				break;
			}
			else
				continue;
		}
	}
	else
	{
		time = -1.0;
	}

	// CPrintToChat(client, "total: %i , runtimepro: %f", total, time);

	WritePackFloat(pack, time);
	WritePackCell(pack, total);
	WritePackCell(pack, rank);

	char szQuery[1024];

	Format(szQuery, 1024, "SELECT db1.steamid, db1.name, db1.mapname, db1.runtimepro, db1.stage, (SELECT count(name) FROM ck_wrcps WHERE style = 0 AND mapname = db1.mapname AND stage = db1.stage AND runtimepro > -1.0 AND runtimepro <= db1.runtimepro) AS `rank`, (SELECT count(name) FROM ck_wrcps WHERE style = 0 AND mapname = db1.mapname AND stage = db1.stage AND runtimepro > -1.0) AS total FROM ck_wrcps db1 WHERE db1.mapname = '%s' AND db1.steamid = '%s' AND db1.runtimepro > -1.0 AND db1.style = 0 ORDER BY stage ASC", szMapName, szSteamId);
	SQL_TQuery(g_hDb, SQL_ViewPlayerPrMaptimeCallback2, szQuery, pack, DBPrio_Low);
}

public void SQL_ViewPlayerPrMaptimeCallback2(Handle owner, Handle hndl, const char[] error, any pack)
{
	char szSteamId[32];
	char szMapName[128];
	
	ResetPack(pack);
	int client = ReadPackCell(pack);
	ReadPackString(pack, szSteamId, 32);
	ReadPackString(pack, szMapName, 128);
	float time = ReadPackFloat(pack);
	int total = ReadPackCell(pack);
	int rank = ReadPackCell(pack);
	CloseHandle(pack);

	if (hndl == null)
	{
		LogError("[surftimer] SQL Error (SQL_ViewPlayerPrMaptimeCallback2): %s ", error);
		return;
	}

	int target = g_iPrTarget[client];
	int stage;
	int stagerank[CPLIMIT];
	int totalcompletes[CPLIMIT];
	int totalstages = 0;
	float stagetime[CPLIMIT];

	for (int i = 1; i < CPLIMIT; i++)
	{
		stagetime[i] = -1.0;
		stagerank[i] = 0;
		totalcompletes[i] = 0;
	}

	if (SQL_HasResultSet(hndl))
	{
		while (SQL_FetchRow(hndl))
		{
			totalstages++;
			stage = SQL_FetchInt(hndl, 4);
			stagetime[stage] = SQL_FetchFloat(hndl, 3);
			stagerank[stage] = SQL_FetchInt(hndl, 5);
			totalcompletes[stage] = SQL_FetchInt(hndl, 6);
		}
	}

	char szMapInfo[256];
	char szRuntimepro[64];
	char szStageInfo[CPLIMIT][256];
	char szRuntimestages[CPLIMIT][64];
	char szBonusInfo[MAXZONEGROUPS][256];

	Menu menu;
	menu = CreateMenu(PrMenuHandler);
	char szName[MAX_NAME_LENGTH];
	GetClientName(target, szName, sizeof(szName));

	SetMenuTitle(menu, "Personal Record for %s\n%s\n \n", szName, szMapName);
	if (time != -1.0)
	{
		FormatTimeFloat(0, time, 3, szRuntimepro, 64);
		Format(szMapInfo, 256, "Map Time: %s\nRank: %i/%i\n \n", szRuntimepro, rank, total);
	}
	else
	{
		Format(szMapInfo, 256, "Map Time: None\n \n", szRuntimepro, rank, total);
	}
	AddMenuItem(menu, "map", szMapInfo);

	if (StrEqual(szMapName, g_szMapName))
	{
		g_totalBonusesPr[client] = g_mapZoneGroupCount;

		if (g_bhasStages)
			g_totalStagesPr[client] = g_TotalStages;
		else
			g_totalStagesPr[client] = 0;
	}

	if (g_totalStagesPr[client] > 0)
	{
		for (int i = 1;i <= g_totalStagesPr[client]; i++)
		{
			if (stagetime[i] != -1.0)
			{
				FormatTimeFloat(0, stagetime[i], 3, szRuntimestages[i], 64);
				Format(szStageInfo[i], 256, "Stage %i: %s\nRank: %i/%i\n \n", i, szRuntimestages[i], stagerank[i], totalcompletes[i]);
			}
			else
			{
				Format(szStageInfo[i], 256, "Stage %i: None\n \n", i);
			}

			AddMenuItem(menu, "stage", szStageInfo[i]);
		}
	}

	if (g_totalBonusesPr[client] > 1)
	{
		for (int i = 1; i < g_totalBonusesPr[client]; i++)
		{
			if (g_fPersonalRecordBonus[i][client] != 0.0)
				Format(szBonusInfo[i], 256, "Bonus %i: %s\nRank: %i/%i\n \n", i, g_szPersonalRecordBonus[i][target], g_MapRankBonus[i][target], g_iBonusCount[i]);
			else
				Format(szBonusInfo[i], 256, "Bonus %i: None\n \n", i);

			AddMenuItem(menu, "bonus", szBonusInfo[i]);
		}
	}

	SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	return;
}

public int PrMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		delete menu;
	}

	return 0;
}

// VIP

// fluffys start vip & admins

public void db_CheckVIPAdmin(int client, char[] szSteamID)
{
	char szQuery[1024];
	Format(szQuery, 1024, "SELECT vip, admin, zoner FROM ck_vipadmins WHERE steamid = '%s';", szSteamID);
	SQL_TQuery(g_hDb, SQL_CheckVIPAdminCallback, szQuery, client, DBPrio_Low);
}

public void SQL_CheckVIPAdminCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	char szSteamId[32];
	getSteamIDFromClient(client, szSteamId, 32);

	if (hndl == null)
	{
		LogError("[surftimer] SQL Error (SQL_CheckVIPAdminCallback): %s", error);

		if (!g_bSettingsLoaded[client])
			LoadClientSetting(client, g_iSettingToLoad[client]);
		
		return;
	}

	g_bVip[client] = false;
	g_bZoner[client] = false;

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		g_bVip[client] = view_as<bool>(SQL_FetchInt(hndl, 0));
		g_bZoner[client] = view_as<bool>(SQL_FetchInt(hndl, 2));
	}

	if (!IsPlayerVip(client) || !g_bZoner[client]) // No VIP or Zoner from database, let's check flags
	{
		if (CheckCommandAccess(client, "", g_VipFlag))
			g_bVip[client] = true;

		if (CheckCommandAccess(client, "", g_ZonerFlag))
			g_bZoner[client] = true;
	}

	if (g_bCheckCustomTitle[client])
	{
		db_viewCustomTitles(client, szSteamId);
		g_bCheckCustomTitle[client] = false;
	}

	if (!g_bSettingsLoaded[client])
	{
		g_fTick[client][1] = GetGameTime();
		float tick = g_fTick[client][1] - g_fTick[client][0];
		LogQueryTime("[SurfTimer] %s: Finished db_CheckVIPAdmin in %fs", g_szSteamID[client], tick);
		g_fTick[client][0] = GetGameTime();


		LoadClientSetting(client, g_iSettingToLoad[client]);
	}
}

public void SQL_InsertVipFromSourcebansCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null)
	{
		LogError("[surftimer] SQL Error (SQL_InsertVipFromSourcebansCallback): %s", error);
		return;
	}

	char szSteamId[32];
	getSteamIDFromClient(client, szSteamId, 32);
	db_CheckVIPAdmin(client, szSteamId);
}

public void db_checkCustomPlayerTitle(int client, char[] szSteamID, char[] arg)
{
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, szSteamID);
	WritePackString(pack, arg);

	char szQuery[512];
	Format(szQuery, 512, "SELECT `steamid` FROM `ck_vipadmins` WHERE `steamid` = '%s';", szSteamID);
	SQL_TQuery(g_hDb, SQL_checkCustomPlayerTitleCallback, szQuery, pack, DBPrio_Low);

}

public void SQL_checkCustomPlayerTitleCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	ResetPack(pack);
	int client = ReadPackCell(pack);
	char szSteamID[32];
	char arg[128];
	ReadPackString(pack, szSteamID, 32);
	ReadPackString(pack, arg, 128);
	CloseHandle(pack);
	
	if (hndl == INVALID_HANDLE)
	{
		LogError("[surftimer] SQL Error (SQL_checkCustomPlayerTitleCallback): %s", error);
		db_insertCustomPlayerTitle(client, szSteamID, arg);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		db_updateCustomPlayerTitle(client, szSteamID, arg);
	} else {
		db_insertCustomPlayerTitle(client, szSteamID, arg);
	}
}

public void db_checkCustomPlayerNameColour(int client, char[] szSteamID, char[] arg)
{
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, szSteamID);
	WritePackString(pack, arg);

	char szQuery[512];
	Format(szQuery, 512, "SELECT `steamid` FROM `ck_vipadmins` WHERE `steamid` = '%s';", szSteamID);
	SQL_TQuery(g_hDb, SQL_checkCustomPlayerNameColourCallback, szQuery, pack, DBPrio_Low);

}

public void SQL_checkCustomPlayerNameColourCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	ResetPack(pack);
	int client = ReadPackCell(pack);
	char szSteamID[32];
	char arg[128];
	ReadPackString(pack, szSteamID, 32);
	ReadPackString(pack, arg, 128);
	CloseHandle(pack);

	if (hndl == INVALID_HANDLE)
	{
		LogError("[surftimer] SQL Error (SQL_checkCustomPlayerTitleCallback): %s", error);
		CPrintToChat(client, "%t", "SQLTwo2", g_szChatPrefix);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		db_updateCustomPlayerNameColour(client, szSteamID, arg);
	}
}

public void db_checkCustomPlayerTextColour(int client, char[] szSteamID, char[] arg)
{
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, szSteamID);
	WritePackString(pack, arg);

	char szQuery[512];
	Format(szQuery, 512, "SELECT `steamid` FROM `ck_vipadmins` WHERE `steamid` = '%s';", szSteamID);
	SQL_TQuery(g_hDb, SQL_checkCustomPlayerTextColourCallback, szQuery, pack, DBPrio_Low);

}

public void SQL_checkCustomPlayerTextColourCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	ResetPack(pack);
	int client = ReadPackCell(pack);
	char szSteamID[32];
	char arg[128];
	ReadPackString(pack, szSteamID, 32);
	ReadPackString(pack, arg, 128);
	CloseHandle(pack);

	if (hndl == INVALID_HANDLE)
	{
		LogError("[surftimer] SQL Error (SQL_checkCustomPlayerTextColourCallback): %s", error);
		CPrintToChat(client, "%t", "SQLTwo3", g_szChatPrefix);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		db_updateCustomPlayerTextColour(client, szSteamID, arg);
	}
}


public void db_insertCustomPlayerTitle(int client, char[] szSteamID, char[] arg)
{
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, szSteamID);

	// Escape title to prevent mysql injection
	int buffer_len = strlen(arg) * 2 + 1;
	char[] new_arg = new char[buffer_len];
	SQL_EscapeString(g_hDb, arg, new_arg, buffer_len);

	char szQuery[512];
	Format(szQuery, 512, "INSERT INTO `ck_vipadmins` (steamid, title, inuse) VALUES ('%s', '%s', 1);", szSteamID, new_arg);
	SQL_TQuery(g_hDb, SQL_insertCustomPlayerTitleCallback, szQuery, pack, DBPrio_Low);
}

public void SQL_insertCustomPlayerTitleCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	ResetPack(pack);
	int client = ReadPackCell(pack);
	char szSteamID[32];
	ReadPackString(pack, szSteamID, 32);
	CloseHandle(pack);

	PrintToServer("Successfully inserted custom title.");

	db_viewCustomTitles(client, szSteamID);
}

public void db_updateCustomPlayerTitle(int client, char[] szSteamID, char[] arg)
{
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, szSteamID);

	char szQuery[512];
	Format(szQuery, 512, "UPDATE `ck_vipadmins` SET `title` = '%s' WHERE `steamid` = '%s';", arg, szSteamID);
	SQL_TQuery(g_hDb, SQL_updateCustomPlayerTitleCallback, szQuery, pack, DBPrio_Low);
}

public void SQL_updateCustomPlayerTitleCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	ResetPack(pack);
	int client = ReadPackCell(pack);
	char szSteamID[32];
	ReadPackString(pack, szSteamID, 32);
	CloseHandle(pack);

	PrintToServer("Successfully updated custom title.");
	db_viewCustomTitles(client, szSteamID);
}

public void db_updateCustomPlayerNameColour(int client, char[] szSteamID, char[] arg)
{
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, szSteamID);

	char szQuery[512];
	Format(szQuery, 512, "UPDATE `ck_vipadmins` SET `namecolour` = '%s' WHERE `steamid` = '%s';", arg, szSteamID);
	SQL_TQuery(g_hDb, SQL_updateCustomPlayerNameColourCallback, szQuery, pack, DBPrio_Low);
}

public void SQL_updateCustomPlayerNameColourCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	ResetPack(pack);
	int client = ReadPackCell(pack);
	char szSteamID[32];
	ReadPackString(pack, szSteamID, 32);
	CloseHandle(pack);

	PrintToServer("Successfully updated custom player colour");
	db_viewCustomTitles(client, szSteamID);
}

public void db_updateCustomPlayerTextColour(int client, char[] szSteamID, char[] arg)
{
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, szSteamID);

	char szQuery[512];
	Format(szQuery, 512, "UPDATE `ck_vipadmins` SET `textcolour` = '%s' WHERE `steamid` = '%s';", arg, szSteamID);
	SQL_TQuery(g_hDb, SQL_updateCustomPlayerTextColourCallback, szQuery, pack, DBPrio_Low);
}

public void SQL_updateCustomPlayerTextColourCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	ResetPack(pack);
	int client = ReadPackCell(pack);
	char szSteamID[32];
	ReadPackString(pack, szSteamID, 32);
	CloseHandle(pack);

	PrintToServer("Successfully updated custom player text colour");
	db_viewCustomTitles(client, szSteamID);
}

public void db_toggleCustomPlayerTitle(int client, char[] szSteamID)
{
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, szSteamID);

	char szQuery[512];
	if (g_bDbCustomTitleInUse[client])
	{
		Format(szQuery, 512, "UPDATE `ck_vipadmins` SET `inuse` = '0' WHERE `steamid` = '%s';", szSteamID);
	}
	else
	{
		Format(szQuery, 512, "UPDATE `ck_vipadmins` SET `inuse` = '1' WHERE `steamid` = '%s';", szSteamID);
	}

	SQL_TQuery(g_hDb, SQL_insertCustomPlayerTitleCallback, szQuery, pack, DBPrio_Low);
}

public void SQL_toggleCustomPlayerTitleCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	ResetPack(pack);
	int client = ReadPackCell(pack);
	char szSteamID[32];
	ReadPackString(pack, szSteamID, 32);
	CloseHandle(pack);

	/*PrintToServer("Successfully updated custom title.");
	db_viewCustomTitles(client, szSteamID);*/
	SetPlayerRank(client);
}

public void db_viewCustomTitles(int client, char[] szSteamID)
{
	char szQuery[728];

	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, szSteamID);
	Format(szQuery, 728, "SELECT `title`, `namecolour`, `textcolour`, `inuse`, `vip`, `zoner`, `joinmsg` FROM `ck_vipadmins` WHERE `steamid` = '%s'", szSteamID);
	SQL_TQuery(g_hDb, SQL_viewCustomTitlesCallback, szQuery, pack, DBPrio_Low);
}

public void SQL_viewCustomTitlesCallback(Handle owner, Handle hndl, const char[] error, any pack) 
{
	ResetPack(pack);
	int client = ReadPackCell(pack);
	char szSteamID[32];
	ReadPackString(pack, szSteamID, 32);
	CloseHandle(pack);

	if (hndl == null)
	{
		LogError("[surftimer] SQL Error (SQL_viewCustomTitlesCallback): %s ", error);
		if (!g_bSettingsLoaded[client])
			LoadClientSetting(client, g_iSettingToLoad[client]);
		return;
	}

	g_bDbCustomTitleInUse[client] = false;
	g_bHasCustomTextColour[client] = false;
	g_bdbHasCustomTitle[client] = false;

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		g_bdbHasCustomTitle[client] = true;
		SQL_FetchString(hndl, 0, g_szCustomTitleColoured[client], sizeof(g_szCustomTitleColoured[]));

		// fluffys temp fix for scoreboard
		// int RankValue[SkillGroup];
		// int index = GetSkillgroupIndex(g_pr_rank[client], g_pr_points[client]);
		// GetArrayArray(g_hSkillGroups, index, RankValue[0]);
		Format(g_pr_chat_coloredrank[client], 1024, "%s", g_szCustomTitleColoured[client]);

		char szTitle[1024];
		Format(szTitle, 1024, "%s", g_szCustomTitleColoured[client]);
		parseColorsFromString(szTitle, 1024);
		Format(g_pr_rankname[client], 1024, "%s", szTitle);
		Format(g_pr_rankname_style[client], 1024, "%s", szTitle);
		Format(g_szCustomTitle[client], 1024, "%s", szTitle);

		if (!SQL_IsFieldNull(hndl, 6) && IsPlayerVip(client, true, false))
			SQL_FetchString(hndl, 6, g_szCustomJoinMsg[client], sizeof(g_szCustomJoinMsg));
		else
			Format(g_szCustomJoinMsg[client], sizeof(g_szCustomJoinMsg), "none");

		// SQL_FetchString(hndl, 7, g_szCustomSounds[client][0], sizeof(g_szCustomSounds));
		// SQL_FetchString(hndl, 8, g_szCustomSounds[client][1], sizeof(g_szCustomSounds));
		// SQL_FetchString(hndl, 9, g_szCustomSounds[client][2], sizeof(g_szCustomSounds));

		if (SQL_FetchInt(hndl, 3) == 0)
		{
			g_bDbCustomTitleInUse[client] = false;
		}
		else
		{
			g_bDbCustomTitleInUse[client] = true;
			g_iCustomColours[client][0] = SQL_FetchInt(hndl, 1);
			// setNameColor(szName, g_szdbCustomNameColour[client], 64);

			g_iCustomColours[client][1] = SQL_FetchInt(hndl, 2);
			g_bHasCustomTextColour[client] = true;
		}
	}
	else
	{
		g_bDbCustomTitleInUse[client] = false;
		g_bHasCustomTextColour[client] = false;
		g_bdbHasCustomTitle[client] = false;
	}

	if (g_bUpdatingColours[client])
		CustomTitleMenu(client);

	g_bUpdatingColours[client] = false;

	if (!g_bSettingsLoaded[client])
	{
		g_fTick[client][1] = GetGameTime();
		float tick = g_fTick[client][1] - g_fTick[client][0];
		LogQueryTime("[SurfTimer] %s: Finished db_viewCustomTitles in %fs", g_szSteamID[client], tick);

		g_fTick[client][0] = GetGameTime();
		LoadClientSetting(client, g_iSettingToLoad[client]);

		/* Check Enforced Tags
		if (GetConVarBool(g_hEnforceDefaultTitles))
			LoadDefaultTitle(client);*/
	}
}

public void db_viewPlayerColours(int client, char szSteamId[32], int type)
{
	Handle data = CreateDataPack();
	WritePackCell(data, client);
	WritePackCell(data, type); // 10 = name colour, 1 = text colour

	char szQuery[512];
	Format(szQuery, 512, "SELECT steamid, namecolour, textcolour FROM ck_vipadmins WHERE `steamid` = '%s';", szSteamId);

	SQL_TQuery(g_hDb, SQL_ViewPlayerColoursCallback, szQuery, data, DBPrio_Low);
}

public void SQL_ViewPlayerColoursCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	ResetPack(data);
	int client = ReadPackCell(data);
	int type = ReadPackCell(data); // 0 = name colour, 1 = text colour
	CloseHandle(data);

	if (hndl == null)
	{
		LogError("[surftimer] SQL Error (SQL_ViewPlayerColoursCallback): %s", error);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		char szSteamId[32];
		int colour[2];

		// get the result
		SQL_FetchString(hndl, 0, szSteamId, 32);
		colour[0] = SQL_FetchInt(hndl, 1);
		colour[1] = SQL_FetchInt(hndl, 2);

		char szColour[32];
		getColourName(client, szColour, 32, colour[type]);

		// change title menu
		char szTitle[1024];
		char szType[32];
		switch (type)
		{
			case 0:
			{
				Format(szTitle, 1024, "Changing Name Colour (Current: %s):\n \n", szColour);
				Format(szType, 32, "name");
			}
			case 1:
			{
				Format(szTitle, 1024, "Changing Text Colour (Current: %s):\n \n", szColour);
				Format(szType, 32, "text");
			}
		}

		Menu changeColoursMenu = new Menu(changeColoursMenuHandler);

		changeColoursMenu.SetTitle(szTitle);

		changeColoursMenu.AddItem(szType, "White");
		changeColoursMenu.AddItem(szType, "Dark Red");
		changeColoursMenu.AddItem(szType, "Green");
		changeColoursMenu.AddItem(szType, "Lime Green");
		changeColoursMenu.AddItem(szType, "Blue");
		changeColoursMenu.AddItem(szType, "Moss Green");
		changeColoursMenu.AddItem(szType, "Red");
		changeColoursMenu.AddItem(szType, "Grey");
		changeColoursMenu.AddItem(szType, "Yellow");
		changeColoursMenu.AddItem(szType, "Light Blue");
		changeColoursMenu.AddItem(szType, "Dark Blue");
		changeColoursMenu.AddItem(szType, "Pink");
		changeColoursMenu.AddItem(szType, "Light Red");
		changeColoursMenu.AddItem(szType, "Purple");
		changeColoursMenu.AddItem(szType, "Dark Grey");
		changeColoursMenu.AddItem(szType, "Orange");

		changeColoursMenu.ExitButton = true;
		changeColoursMenu.Display(client, MENU_TIME_FOREVER);
	}
}

public int changeColoursMenuHandler(Handle menu, MenuAction action, int client, int item)
{
	if (action == MenuAction_Select)
	{
		char szType[32];
		int type;
		GetMenuItem(menu, item, szType, sizeof(szType));
		if (StrEqual(szType, "name"))
			type = 0;
		else if (StrEqual(szType, "text"))
			type = 1;
		if(item >= 0 && item <= 15)
			db_updateColours(client, g_szSteamID[client], item, type);
	}
	else if (action == MenuAction_Cancel)
	{
		CustomTitleMenu(client);
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}

	return 0;
}

public void db_updateColours(int client, char szSteamId[32], int newColour, int type)
{
	char szQuery[512];
	switch (type)
	{
		case 0: Format(szQuery, 512, "UPDATE ck_vipadmins SET namecolour = %i WHERE steamid = '%s';", newColour, szSteamId);
		case 1: Format(szQuery, 512, "UPDATE ck_vipadmins SET textcolour = %i WHERE steamid = '%s';", newColour, szSteamId);
	}

	SQL_TQuery(g_hDb, SQL_UpdatePlayerColoursCallback, szQuery, client, DBPrio_Low);
}

public void SQL_UpdatePlayerColoursCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null)
	{
		LogError("[surftimer] SQL Error (SQL_UpdatePlayerColoursCallback): %s", error);
		return;
	}

	g_bUpdatingColours[client] = true;
	db_viewCustomTitles(client, g_szSteamID[client]);
}

// fluffys end custom titles

// WR Announcements
public void db_selectAnnouncements()
{
	char szQuery[1024];
	char szEscServerName[128];
	SQL_EscapeString(g_hDb, g_sServerName, szEscServerName, sizeof(szEscServerName));
	Format(szQuery, 1024, "SELECT `id` FROM `ck_announcements` WHERE `server` != '%s' AND `id` > %d", szEscServerName, g_iLastID);
	SQL_TQuery(g_hDb, SQL_SelectAnnouncementsCallback, szQuery, GetGameTime(), DBPrio_Low);
}

public void SQL_SelectAnnouncementsCallback(Handle owner, Handle hndl, const char[] error, float time)
{
	LogQueryTime("[SurfTimer] : Finished SQL_SelectAnnouncementsCallback in: %f", GetGameTime() - time);

	if (hndl == null)
	{
		LogError("[surftimer] SQL Error (SQL_SelectAnnouncementsCallback): %s", error);
		if (!g_bServerDataLoaded)
			db_viewReplayCPTicks(g_szMapName);
		return;
	}

	if (SQL_HasResultSet(hndl))
	{
		while (SQL_FetchRow(hndl))
		{
			int id = SQL_FetchInt(hndl, 0);
			if (id > g_iLastID)
				g_iLastID = id;
		}
	}

	if (!g_bServerDataLoaded)
		db_viewReplayCPTicks(g_szMapName);

}

public void db_insertAnnouncement(char szName[128], char szMapName[128], int szMode, char szTime[32], int szGroup)
{
	if (g_iServerID == -1)
		return;

	char szQuery[512];
	char szEscServerName[128];
	SQL_EscapeString(g_hDb, g_sServerName, szEscServerName, sizeof(szEscServerName));
	Format(szQuery, 512, "INSERT INTO `ck_announcements` (`server`, `name`, `mapname`, `mode`, `time`, `group`) VALUES ('%s', '%s', '%s', '%i', '%s', '%i');", szEscServerName, szName, szMapName, szMode, szTime, szGroup);
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, _, DBPrio_Low);
}

public void db_checkAnnouncements()
{
	char szQuery[512];
	char szEscServerName[128];
	SQL_EscapeString(g_hDb, g_sServerName, szEscServerName, sizeof(szEscServerName));
	Format(szQuery, 512, "SELECT `id`, `server`, `name`, `mapname`, `mode`, `time`, `group` FROM `ck_announcements` WHERE `server` != '%s' AND `id` > %d;", szEscServerName, g_iLastID);
	SQL_TQuery(g_hDb, SQL_CheckAnnouncementsCallback, szQuery, 1, DBPrio_Low);
}

public void SQL_CheckAnnouncementsCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[surftimer] SQL Error (SQL_CheckAnnouncementsCallback): %s", error);
		return;
	}

	if (SQL_HasResultSet(hndl))
	{
		while (SQL_FetchRow(hndl))
		{
			int id = SQL_FetchInt(hndl, 0);
			int mode = SQL_FetchInt(hndl, 4);
			int group = SQL_FetchInt(hndl, 6);
			char szServerName[256], szName[128], szMapName[128], szTime[32];
			SQL_FetchString(hndl, 1, szServerName, sizeof(szServerName));
			SQL_FetchString(hndl, 2, szName, sizeof(szName));
			SQL_FetchString(hndl, 3, szMapName, sizeof(szMapName));
			SQL_FetchString(hndl, 5, szTime, sizeof(szTime));

			if (id > g_iLastID)
			{
				// Send Server Announcement
				g_iLastID = id;
				CPrintToChatAll("%t", "SQLTwo4.1");
				if (mode == 0)
					CPrintToChatAll("%t", "SQLTwo4.2", g_szChatPrefix, szName, szMapName, szServerName, szTime);
				else if (mode == 1)
					CPrintToChatAll("%t", "SQLTwo4.2Bonus", g_szChatPrefix, szName, szMapName, group, szServerName, szTime);
				CPrintToChatAll("%t", "SQLTwo4.3");
			}
		}
	}
}

public void db_selectMapCycle()
{
	char szQuery[128];
	Format(szQuery, sizeof(szQuery), "SELECT mapname, tier FROM ck_maptier ORDER BY mapname ASC");
	SQL_TQuery(g_hDb, SQL_SelectMapCycleCallback, szQuery, 1, DBPrio_Low);
}

public void SQL_SelectMapCycleCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[surftimer] SQL Error (SQL_SelectMapCycleCallback): %s", error);
		return;
	}

	g_pr_MapCount[0] = 0;
	ClearArray(g_MapList);

	if (SQL_HasResultSet(hndl))
	{
		char szMapname[128];
		int tier;

		while (SQL_FetchRow(hndl))
		{
			g_pr_MapCount[0]++;
			SQL_FetchString(hndl, 0, szMapname, sizeof(szMapname));
			tier = SQL_FetchInt(hndl, 1);
			// No out of bounds arrays please
			if (tier > 8)
				tier = 8;
			else if (tier < 1)
				tier = 1;

			g_pr_MapCount[tier]++;
			PushArrayString(g_MapList, szMapname);
		}
	}
}

public void db_setJoinMsg(int client, char[] szArg)
{
	char szQuery[512];
	Format(szQuery, sizeof(szQuery), "UPDATE ck_vipadmins SET joinmsg = '%s' WHERE steamid = '%s';", szArg, g_szSteamID[client]);
	Format(g_szCustomJoinMsg[client], sizeof(g_szCustomJoinMsg), "%s", szArg);
	SQL_TQuery(g_hDb, SQL_SetJoinMsgCallback, szQuery, client, DBPrio_Low);
}

public void SQL_SetJoinMsgCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null)
	{
		LogError("[surftimer] SQL Error (SQL_SetJoinMsgCallback): %s", error);
		return;
	}

	if (StrEqual(g_szCustomJoinMsg[client], "none"))
		CPrintToChat(client, "%t", "SQLTwo5", g_szChatPrefix);
	else
		CPrintToChat(client, "%t", "SQLTwo6", g_szChatPrefix, g_szCustomJoinMsg[client]);
}

// public void db_precacheCustomSounds()
// {
// 	char szQuery[512];
// 	Format(szQuery, sizeof(szQuery), "SELECT pbsound, topsound, wrsound FROM ck_vipadmins");
// 	SQL_TQuery(g_hDb, SQL_PrecacheCustomSoundsCallback szQuery, 1, DBPrio_Low);
// }

// public void SQL_SetJoinMsgCallback(Handle owner, Handle hndl, const char[] error, any data)
// {
// 	if (hndl == null)
// 	{
// 		LogError("[surftimer] SQL Error (SQL_PrecacheCustomSoundsCallback): %s", error);
// 		return;
// 	}

// 	if (SQL_HasResultSet(hndl))
// 	{
// 		char pbsound[256], topsound[256], wrsound[256];
// 		while (SQL_FetchRow(hndl))
// 		{
// 			SQL_FetchString(hndl, 0, pbsound, sizeof(pbsound));
// 			SQL_FetchString(hndl, 1, topsound, sizeof(topsound));
// 			SQL_FetchString(hndl, 2, wrsound, sizeof(wrsound));

// 			if (!StrEqual(pbsound, "none"))
// 			{
// 				AddFileToDownloadsTable(pbsound);
// 				FakePrecacheSound(pbsound);
// 			}

// 			if (!StrEqual(topsound, "none"))
// 			{
// 				AddFileToDownloadsTable(topsound);
// 				FakePrecacheSound(topsound);
// 			}

// 			if (!StrEqual(wrsound, "none"))
// 			{
// 				AddFileToDownloadsTable(wrsound);
// 				FakePrecacheSound(wrsound);
// 			}
// 		}
// 	}
// }

public void db_selectCPR(int client, int rank, const char szMapName[128], const char szSteamId[32])
{
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackCell(pack, rank);
	WritePackString(pack, szSteamId);

	char szQuery[512];
	Format(szQuery, sizeof(szQuery), "SELECT `steamid`, `name`, `mapname`, `runtimepro` FROM `ck_playertimes` WHERE `steamid` = '%s' AND `mapname` LIKE '%c%s%c' AND style = 0", g_szSteamID[client], PERCENT, szMapName, PERCENT);
	SQL_TQuery(g_hDb, SQL_SelectCPRTimeCallback, szQuery, pack, DBPrio_Low);
}

public void SQL_SelectCPRTimeCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[surftimer] SQL Error (SQL_SelectCPRTimeCallback): %s", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		SQL_FetchString(hndl, 2, g_szCPRMapName[client], 128);
		g_fClientCPs[client][0] = SQL_FetchFloat(hndl, 3);

		char szQuery[512];
		Format(szQuery, sizeof(szQuery), "SELECT cp, time FROM ck_checkpoints WHERE steamid = '%s' AND mapname = '%s' AND zonegroup = 0;", g_szSteamID[client], g_szCPRMapName[client]);
		SQL_TQuery(g_hDb, SQL_SelectCPRCallback, szQuery, pack, DBPrio_Low);
	}
	else
	{
		CPrintToChat(client, "%t", "SQLTwo7", g_szChatPrefix);
		CloseHandle(pack);
	}
}

public void SQL_SelectCPRCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[surftimer] SQL Error (SQL_SelectCPRCallback): %s", error);
		CloseHandle(pack);
		return;
	}

	if (SQL_HasResultSet(hndl))
	{
		ResetPack(pack);
		int client = ReadPackCell(pack);

		while(SQL_FetchRow(hndl))
		{
			int cp = SQL_FetchInt(hndl, 0);
			g_fClientCPs[client][cp] = SQL_FetchFloat(hndl, 1);
		}
		db_selectCPRTarget(pack);
	}
}

public void db_selectCPRTarget(any pack)
{
	ResetPack(pack);
	int client = ReadPackCell(pack);
	int rank = ReadPackCell(pack);
	rank = rank - 1;

	char szQuery[512];
	if (rank == -1)
	{
		char szSteamId[32];
		ReadPackString(pack, szSteamId, 32);
		Format(szQuery, sizeof(szQuery), "SELECT `steamid`, `name`, `mapname`, `runtimepro` FROM `ck_playertimes` WHERE `mapname` LIKE '%c%s%c' AND steamid = '%s' AND style = 0", PERCENT, g_szCPRMapName[client], PERCENT, szSteamId);
	}
	else
		Format(szQuery, sizeof(szQuery), "SELECT `steamid`, `name`, `mapname`, `runtimepro` FROM `ck_playertimes` WHERE `mapname` LIKE '%c%s%c' AND style = 0 ORDER BY `runtimepro` ASC LIMIT %i, 1;", PERCENT, g_szCPRMapName[client], PERCENT, rank);
	SQL_TQuery(g_hDb, SQL_SelectCPRTargetCallback, szQuery, pack, DBPrio_Low);
}

public void SQL_SelectCPRTargetCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[surftimer] SQL Error (SQL_SelectCPRTargetCallback): %s", error);
		CloseHandle(pack);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		ResetPack(pack);
		int client = ReadPackCell(pack);

		char szSteamId[32];
		SQL_FetchString(hndl, 0, szSteamId, sizeof(szSteamId));
		SQL_FetchString(hndl, 1, g_szTargetCPR[client], sizeof(g_szTargetCPR));
		g_fTargetTime[client] = SQL_FetchFloat(hndl, 3);
		db_selectCPRTargetCPs(szSteamId, pack);
	}
}

public void db_selectCPRTargetCPs(const char[] szSteamId, any pack)
{
	ResetPack(pack);
	int client = ReadPackCell(pack);

	char szQuery[512];
	Format(szQuery, sizeof(szQuery), "SELECT cp, time FROM ck_checkpoints WHERE steamid = '%s' AND mapname = '%s' AND zonegroup = 0;", szSteamId, g_szCPRMapName[client]);
	SQL_TQuery(g_hDb, SQL_SelectCPRTargetCPsCallback, szQuery, pack, DBPrio_Low);
}

public void SQL_SelectCPRTargetCPsCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[surftimer] SQL Error (SQL_SelectCPRTargetCPsCallback): %s", error);
		CloseHandle(pack);
		return;
	}

	if (SQL_HasResultSet(hndl))
	{
		ResetPack(pack);
		int client = ReadPackCell(pack);
		int rank = ReadPackCell(pack);

		Menu menu = CreateMenu(CPRMenuHandler);
		char szTitle[256], szName[MAX_NAME_LENGTH];
		GetClientName(client, szName, sizeof(szName));
		Format(szTitle, sizeof(szTitle), "%s VS %s on %s\n \n", szName, g_szTargetCPR[client], g_szCPRMapName[client], rank);
		SetMenuTitle(menu, szTitle);

		float targetCPs, comparedCPs;
		char szCPR[32], szCompared[32], szItem[256];

		int cp_count;
		if(!g_bhasStages)
			cp_count = g_iTotalCheckpoints;
		else
			cp_count = g_TotalStages - 1;


		while(SQL_FetchRow(hndl))
		{	
			int cp = SQL_FetchInt(hndl, 0);
			targetCPs = SQL_FetchFloat(hndl, 1);
			if(cp <= cp_count)
				comparedCPs = (g_fClientCPs[client][cp] - targetCPs);
			else
				continue;

			if (targetCPs == 0.0 || g_fClientCPs[client][cp] == 0.0)
				continue;
			
			FormatTimeFloat(client, targetCPs, 3, szCPR, sizeof(szCPR));
			FormatTimeFloat(client, comparedCPs, 6, szCompared, sizeof(szCompared));
			Format(szItem, sizeof(szItem), "CP %i: %s (%s)", cp, szCPR, szCompared);
			AddMenuItem(menu, "", szItem, ITEMDRAW_DISABLED);
		}

		char szTime[32], szCompared2[32];
		float compared = g_fClientCPs[client][0] - g_fTargetTime[client];
		FormatTimeFloat(client, g_fClientCPs[client][0], 3, szTime, sizeof(szTime));
		FormatTimeFloat(client, compared, 6, szCompared2, sizeof(szCompared2));
		Format(szItem, sizeof(szItem), "Total Time: %s (%s)", szTime, szCompared2);
		AddMenuItem(menu, "", szItem, ITEMDRAW_DISABLED);
		SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
		DisplayMenu(menu, client, MENU_TIME_FOREVER);
	}

	CloseHandle(pack);
}

public int CPRMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
		delete menu;

	return 0;
}

//MAP
// sm_prinfo @x command with map parameter
public void db_selectPRinfoUnknown(int client, int rank, int zonegroup, char szSteamID[32])
{
	char szQuery[1024];
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	
	if(rank == 99999 || rank == 9999999)
		rank = -1;

	rank = Math_Min((rank - 1), 0);

	WritePackCell(pack, rank + 1);

	WritePackCell(pack, zonegroup);

	Format(szQuery, 1024, "SELECT steamid, name, mapname, runtime, PRtimeinzone, PRcomplete, PRattempts, PRstcomplete FROM ck_prinfo WHERE mapname LIKE '%c%s%c' AND zonegroup = '%i' AND steamid = '%s';", PERCENT, g_szMapName, PERCENT, zonegroup, szSteamID);
	//PrintToConsole(client, "QUERY %s", szQuery);
	SQL_TQuery(g_hDb, db_selectPRinfoUnknownCallback, szQuery, pack, DBPrio_Low);
}

// sm_prinfo @x command without map parameter (current mapname being used)
public void db_selectPRinfoUnknownWithMap(int client, int rank, char szMapName[128], int zonegroup, char szSteamID[32])
{	

	if (!IsValidClient(client))
		return;

	char szQuery[1024];
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);

	if(rank == 99999 || rank == 9999999){
		CPrintToChat(client, "%t", "SQL28", g_szChatPrefix);
		return;
	}

	rank = Math_Min((rank - 1), 0);

	WritePackCell(pack, rank + 1);

	WritePackCell(pack, zonegroup);

	Format(szQuery, 1024, "SELECT steamid, name, mapname, runtime, PRtimeinzone, PRcomplete, PRattempts, PRstcomplete FROM ck_prinfo WHERE mapname = '%s' AND zonegroup = '%i' AND steamid = '%s';", szMapName, zonegroup, szSteamID);
	//PrintToConsole(client, "QUERY %s", szQuery);
	SQL_TQuery(g_hDb, db_selectPRinfoUnknownCallback, szQuery, pack, DBPrio_Low);
}

public void db_selectPRinfoUnknownCallback(Handle owner, Handle hndl, const char[] error, any pack)
{	
	ResetPack(pack);

	int client = ReadPackCell(pack);
	int rank = ReadPackCell(pack);
	int zonegroup = ReadPackCell(pack);
	CloseHandle(pack);

	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (db_selectPRinfoUnknownCallback): %s", error);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{	
		char szSteamId[32];
		char szMapName[32];
		char szPlayerName[MAX_NAME_LENGTH];
		float runtime;
		float PRTimeinZone;
		float PRCompletes;
		float PRAttempts;
		float PRstcomplete;

		SQL_FetchString(hndl, 0, szSteamId, 32);
		SQL_FetchString(hndl, 1, szPlayerName, sizeof(szPlayerName));
		SQL_FetchString(hndl, 2, szMapName, sizeof(szMapName));

		runtime = SQL_FetchFloat(hndl, 3);

		/*
		//DISPLAY CHAT ERROR MESSAGE WHEN PLAYER HASNT COMPLETED THE MAP
		if(runtime == 0.0 && rank == 0){
			CPrintToChat(client, "%t", "SQL28", g_szChatPrefix);
			return;
		}
		*/

		PRTimeinZone = SQL_FetchFloat(hndl, 4);
		PRCompletes = SQL_FetchFloat(hndl, 5);
		PRAttempts = SQL_FetchFloat(hndl, 6);
		PRstcomplete = SQL_FetchFloat(hndl, 7);
		
		Handle pack_aux = CreateDataPack();
		WritePackCell(pack_aux, client);
		WritePackString(pack_aux, szSteamId);
		WritePackString(pack_aux, szPlayerName);
		WritePackCell(pack_aux, rank);
		WritePackCell(pack_aux, zonegroup);
		WritePackString(pack_aux, szMapName);
		WritePackFloat(pack_aux, runtime);
		WritePackFloat(pack_aux, PRTimeinZone);
		WritePackFloat(pack_aux, PRCompletes);
		WritePackFloat(pack_aux, PRAttempts);
		WritePackFloat(pack_aux, PRstcomplete);

		db_PRinfoDoneCallback(pack_aux);
	}
	else
	{
		CPrintToChat(client, "%t", "SQL28", g_szChatPrefix);
	}
}

//GET PLAYER PRINFO MAP RANK
public void db_viewPRinfoMapRank(int client, char szSteamID[32], char szMapName[128])
{
	if (!IsValidClient(client))
		return;

	char szQuery[512];

	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, szMapName);
	WritePackString(pack, szSteamID);

	Format(szQuery, 1024, "SELECT COUNT(*),steamid FROM ck_playertimes WHERE runtimepro <= (SELECT runtimepro FROM ck_playertimes WHERE steamid = '%s' AND mapname LIKE '%c%s%c' AND style = 0 AND runtimepro > -1.0) AND mapname LIKE '%c%s%c' AND style = 0 AND runtimepro > -1.0;", szSteamID, PERCENT, szMapName, PERCENT, PERCENT, szMapName, PERCENT);
	//PrintToConsole(client, "QUERY %s", szQuery);
	SQL_TQuery(g_hDb, db_viewPRinfoMapRankCallback, szQuery, pack, DBPrio_Low);
}

public void db_viewPRinfoMapRankCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (db_viewMapRankProCallback): %s ", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);

	int client = ReadPackCell(pack);

	char szMapName[128];
	ReadPackString(pack, szMapName, sizeof(szMapName));

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		g_iPRinfoMapRank[client] = SQL_FetchInt(hndl, 0);

		char szSteamID[32];
		SQL_FetchString(hndl, 1, szSteamID, 32);

		db_selectPRinfoUnknownWithMap(client, g_iPRinfoMapRank[client], szMapName, 0, szSteamID);
	}
	else{
		CPrintToChat(client, "%t", "SQL28", g_szChatPrefix);
	}

}
//GET PLAYER PRINFO MAP RANK
public void db_viewPRinfoMapRankBonus(int client, char szSteamID[32], char szMapName[128], int zonegroup)
{
	if (!IsValidClient(client))
		return;

	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, szMapName);
	WritePackCell(pack, zonegroup);

	char szQuery[512];

	Format(szQuery, 1024, "SELECT COUNT(*), steamid FROM ck_bonus WHERE runtime <= (SELECT runtime FROM ck_bonus WHERE steamid = '%s' AND mapname LIKE '%c%s%c' AND runtime > -1.0 AND zonegroup = %i AND style = 0) AND mapname = '%s' AND zonegroup = %i AND style = 0;", szSteamID, PERCENT, szMapName, PERCENT, zonegroup, szMapName, zonegroup);
	//PrintToConsole(client, "QUERY %s", szQuery);
	SQL_TQuery(g_hDb, db_viewPRinfoMapRankBonusCallback, szQuery, pack, DBPrio_Low);
}

public void db_viewPRinfoMapRankBonusCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (db_viewMapRankProCallback): %s ", error);
		return;
	}

	ResetPack(pack);

	int client = ReadPackCell(pack);

	char szMapName[128];
	ReadPackString(pack, szMapName, sizeof(szMapName));

	int bonus_number = ReadPackCell(pack);
	CloseHandle(pack);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{	
		g_iPRinfoMapRankBonus[client] = SQL_FetchInt(hndl, 0);

		char szSteamID[32];
		SQL_FetchString(hndl, 1, szSteamID, 32);

		db_selectPRinfoUnknownWithMap(client, g_iPRinfoMapRankBonus[client], szMapName, bonus_number, szSteamID);
	}
	else{
		CPrintToChat(client, "%t", "SQL28", g_szChatPrefix);
	}
}

//GET THE STEAMID OF THE REQUESTED RANK
public void db_GetRankSteamID(int client, char szMapName[128], int rank, int zonegroup)
{
	if (!IsValidClient(client))
		return;

	char szQuery[512];

	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, szMapName);
	WritePackCell(pack, rank);
	WritePackCell(pack, zonegroup);

	if(zonegroup == 0){
		Format(szQuery, 1024, "SELECT steamid FROM ck_playertimes WHERE mapname = '%s' AND style = 0 AND runtimepro > -1.0 ORDER BY runtimepro ASC LIMIT %i, 1;", szMapName, rank - 1);
		//PrintToConsole(client, "QUERY %s", szQuery);
		SQL_TQuery(g_hDb, SQL_GetRankSteamIDCallback, szQuery, pack, DBPrio_Low);
	}
	else{
		Format(szQuery, 1024, "SELECT steamid FROM ck_bonus WHERE mapname = '%s' AND style = 0 AND runtime > -1.0 AND zonegroup = '%i' ORDER BY runtime ASC LIMIT %i, 1;", szMapName, zonegroup, rank - 1);
		//PrintToConsole(client, "QUERY %s", szQuery);
		SQL_TQuery(g_hDb, SQL_GetRankSteamIDCallback, szQuery, pack, DBPrio_Low);
	}

}

public void SQL_GetRankSteamIDCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (db_viewMapRankProCallback): %s ", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);

	int client = ReadPackCell(pack);

	char szMapName[128];
	ReadPackString(pack, szMapName, sizeof(szMapName));
	int rank = ReadPackCell(pack);
	int zonegroup = ReadPackCell(pack);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		char szSteamID[32];
		SQL_FetchString(hndl, 0, szSteamID, 32);

		db_selectPRinfoUnknownWithMap(client, rank, szMapName, zonegroup, szSteamID);
	}
	else{
		CPrintToChat(client, "%t", "SQL28", g_szChatPrefix);
	}

}

public void db_PRinfoDoneCallback(any pack){

	if (pack == 0)
	{
		LogError("[SurfTimer] SQL Error (db_PRinfoDoneCallback)");
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);

	int client = ReadPackCell(pack);

	char szSteamId[32];
	ReadPackString(pack, szSteamId, sizeof(szSteamId));

	char playername[MAX_NAME_LENGTH];
	ReadPackString(pack, playername, sizeof(playername));

	int rank = ReadPackCell(pack);

	int zonegroup = ReadPackCell(pack);

	char mapname[128];
	ReadPackString(pack, mapname, sizeof(mapname));

	float runtime = ReadPackFloat(pack);

	float PRTimeinZone = ReadPackFloat(pack);
	float PRCompletes = ReadPackFloat(pack);
	float PRAttempts = ReadPackFloat(pack);
	float PRstComplete = ReadPackFloat(pack);

	float time_in_zone = PRTimeinZone;
	float completes = PRCompletes;
	float attempts = PRAttempts;
	float stcomplete = PRstComplete;

	Menu menu = CreateMenu(PRMenuHandler);
	char szItem[256];

	char szTimeinZoneformatted[32];
	FormatTimeFloat(client, time_in_zone, 7, szTimeinZoneformatted, 32);

	char szstCompleteFormatted[32];
	FormatTimeFloat(client, stcomplete, 7, szstCompleteFormatted, 32);

	char szruntimeFormatted[32];
	FormatTimeFloat(client, runtime, 3, szruntimeFormatted, 32);

	SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
	if(zonegroup == 0)
		SetMenuTitle(menu, "PR info for %s on %s\n\n", playername, mapname);
	else
		SetMenuTitle(menu, "PR info for %s on %s | Bonus %i\n\n", playername, mapname, zonegroup);

	if(rank == 0 || runtime == 0.0){
		Format(szItem, sizeof(szItem), "Rank: N/A", rank);
		AddMenuItem(menu, "", szItem, ITEMDRAW_DISABLED);
	}
	else if(rank != 99999 && rank != 9999999 ){
		Format(szItem, sizeof(szItem), "Rank: %i\n", rank);
		AddMenuItem(menu, "", szItem, ITEMDRAW_DISABLED);

		Format(szItem, sizeof(szItem), "Personal Record: %s", szruntimeFormatted);
		AddMenuItem(menu, "", szItem, ITEMDRAW_DISABLED);
	}

	Format(szItem, sizeof(szItem), "Total Time: %s\n", szTimeinZoneformatted);
	AddMenuItem(menu, "", szItem, ITEMDRAW_DISABLED);

	if(attempts != 0.0){
		Format(szItem, sizeof(szItem), "Completes : (%i / %i) (%.2f %%)\n\n", RoundToFloor(completes), RoundToFloor(attempts), (completes / attempts) * 100.0 );
		AddMenuItem(menu, "", szItem, ITEMDRAW_DISABLED);
	}
	else{
		Format(szItem, sizeof(szItem), "Completes : N/A\n\n");
		AddMenuItem(menu, "", szItem, ITEMDRAW_DISABLED);
	}

	if(stcomplete != 0.0){
		Format(szItem, sizeof(szItem), "First Complete: %s\n", szstCompleteFormatted);
		AddMenuItem(menu, "", szItem, ITEMDRAW_DISABLED);
	}
	else{
		Format(szItem, sizeof(szItem), "First Complete: N/A\n\n");
		AddMenuItem(menu, "", szItem, ITEMDRAW_DISABLED);
	}

	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int PRMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
		delete menu;

	return 0;
}

public void db_updateMapRankedStatus()
{
	char szQuery[256];
	if (g_bRankedMap)
	{
		Format(szQuery, sizeof(szQuery), "UPDATE ck_maptier SET ranked = 0 WHERE mapname = '%s';", g_szMapName);
		g_bRankedMap = false;
	}
	else
	{
		Format(szQuery, sizeof(szQuery), "UPDATE ck_maptier SET ranked = 1 WHERE mapname = '%s';", g_szMapName);
		g_bRankedMap = true;
	}

	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, _, DBPrio_Low);
}

public void db_selectPracWrcpRecord(int client, int style, int stage)
{
	if (!IsValidClient(client) || IsFakeClient(client) || g_bUsingStageTeleport[client])
	{
		return;
	}

	if (stage > g_TotalStages) // Hack fix for multiple end zones
	{
		stage = g_TotalStages;
	}

	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackCell(pack, style);
	WritePackCell(pack, stage);

	char szQuery[255];
	if (style == 0)
	{
		Format(szQuery, 255, "SELECT runtimepro FROM ck_wrcps WHERE steamid = '%s' AND mapname = '%s' AND stage = %i AND style = 0", g_szSteamID[client], g_szMapName, stage);
	}
	else if (style != 0)
	{
		Format(szQuery, 255, "SELECT runtimepro FROM ck_wrcps WHERE steamid = '%s' AND mapname = '%s' AND stage = %i AND style = %i", g_szSteamID[client], g_szMapName, stage, style);
	}

	SQL_TQuery(g_hDb, sql_selectPracWrcpRecordCallback, szQuery, pack, DBPrio_Low);
}

public void sql_selectPracWrcpRecordCallback(Handle owner, Handle hndl, const char[] error, DataPack packx)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (sql_selectPracWrcpRecordCallback): %s", error);
		delete packx;
		return;
	}

	ResetPack(packx);
	int data = ReadPackCell(packx);
	int style = ReadPackCell(packx);
	int stage = ReadPackCell(packx);
	delete packx;

	if (!IsValidClient(data) || IsFakeClient(data))
	{
		return;
	}

	if (stage > g_TotalStages) // Hack fix for multiple end zones
	{
		stage = g_TotalStages;
	}
	
	float fClientPbStageTime;

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		fClientPbStageTime = SQL_FetchFloat(hndl, 0);
	}
	else
	{
		fClientPbStageTime = 0.0;
	}

	db_currentRunRank_StagePrac(data, style, stage, fClientPbStageTime);
	//PrintPracSrcp(data, style, stage, fClientPbStageTime);
}

//sm_crank
public void db_SelectCountryRank(int client, char szPlayerName[MAX_NAME_LENGTH], char szCountry[100], int style)
{
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, szPlayerName);
	WritePackString(pack, szCountry);
	WritePackCell(pack, style);

	//GET TOTAL AMOUNT OF PLAYERS
	char szQuery[512];
	Format(szQuery, sizeof szQuery, "SELECT COUNT(steamid), country FROM ck_playerrank WHERE country = '%s' AND style = '%i';", szCountry, style);
	SQL_TQuery(g_hDb, db_SelectCountryRankCallback, szQuery, pack, DBPrio_Low);
}

public void db_SelectCountryRankCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (db_SelectCountryRankCallback): %s ", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);

	char szPlayerName[MAX_NAME_LENGTH];
	ReadPackString(pack, szPlayerName, sizeof szPlayerName);

	char szCountry[100];
	ReadPackString(pack, szCountry, sizeof szCountry);

	int style = ReadPackCell(pack);
	CloseHandle(pack);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)) {

		db_GetPlayerPoints(client, SQL_FetchInt(hndl, 0), szPlayerName, szCountry, style);
	}
}

public void db_GetPlayerPoints(int client, int CountryPlayerTotal, char szPlayerName[MAX_NAME_LENGTH], char szCountry[100], int style)
{	
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackCell(pack, CountryPlayerTotal);
	WritePackString(pack, szPlayerName);
	WritePackString(pack, szCountry);
	WritePackCell(pack, style);

	//GET PLAYER POINTS
	char szQuery[512];
	Format(szQuery, sizeof szQuery, "SELECT points FROM ck_playerrank WHERE name = '%s' AND style = '%i';", szPlayerName, style);
	SQL_TQuery(g_hDb, db_GetPlayerPointsCallback, szQuery, pack, DBPrio_Low);
}

public void db_GetPlayerPointsCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (db_GetPlayerPointsCallback): %s ", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	int CountryPlayerTotal = ReadPackCell(pack);
	char szPlayerName[MAX_NAME_LENGTH];
	ReadPackString(pack, szPlayerName, sizeof szPlayerName);
	char szCountry[100];
	ReadPackString(pack, szCountry, sizeof szCountry);
	int style = ReadPackCell(pack);
	CloseHandle(pack);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)) {
		db_GetPlayerCountryRank(SQL_FetchInt(hndl, 0), CountryPlayerTotal, szPlayerName, szCountry, style);
	}
	else {
		CPrintToChat(client, "%t", "Player_Data_Not_Found", g_szChatPrefix);
	}
}

public void db_GetPlayerCountryRank(int PlayerPoints, int CountryPlayerTotal, char szPlayerName[MAX_NAME_LENGTH], char szCountry[100], int style)
{	
	Handle pack = CreateDataPack();
	WritePackCell(pack, PlayerPoints);
	WritePackCell(pack, CountryPlayerTotal);
	WritePackString(pack, szPlayerName);
	WritePackString(pack, szCountry);
	WritePackCell(pack, style);

	//GET CLIENT COUNTRY RANK
	char szQuery[512];
	Format(szQuery, sizeof szQuery, "SELECT COUNT(steamid) + 1 FROM ck_playerrank WHERE country = '%s' AND style = '%i' AND points > '%i';", szCountry, style, PlayerPoints);
	SQL_TQuery(g_hDb, db_GetPlayerCountryRankCallback, szQuery, pack, DBPrio_Low);
}

public void db_GetPlayerCountryRankCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (db_GetPlayerCountryRankCallback): %s ", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);
	int PlayerPoints = ReadPackCell(pack);
	int CountryPlayerTotal = ReadPackCell(pack);
	char szPlayerName[MAX_NAME_LENGTH];
	ReadPackString(pack, szPlayerName, sizeof szPlayerName);
	char szCountry[100];
	ReadPackString(pack, szCountry, sizeof szCountry);
	int style = ReadPackCell(pack);
	CloseHandle(pack);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)) {
		CPrintToChatAll("%t", "Country_Rank", g_szChatPrefix, g_szStyleRecordPrint[style], szPlayerName, SQL_FetchInt(hndl, 0), CountryPlayerTotal, szCountry, PlayerPoints);
	}
}

//sm_crank <playername>
//sm_crank <playername> <style>
//sm_crank <style> <playername>
public void db_SelectCustomPlayerCountryRank(int client, char szPlayerName[MAX_NAME_LENGTH], int style)
{
	// Escape name for SQL injection protection
	char szName[MAX_NAME_LENGTH * 2 + 1];
	SQL_EscapeString(g_hDb, szPlayerName, szName, MAX_NAME_LENGTH);

	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, szName);
	WritePackCell(pack, style);

	//CHECK IF PLAYER EXISTS
	char szQuery[512];
	Format(szQuery, sizeof szQuery, "SELECT * FROM ck_playerrank WHERE name = '%s';", szName);
	SQL_TQuery(g_hDb, db_SelectCustomPlayerCountryRankCallback, szQuery, pack, DBPrio_Low);
}

public void db_SelectCustomPlayerCountryRankCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (db_SelectCustomPlayerCountryRankCallback): %s ", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	char szPlayerName[MAX_NAME_LENGTH];
	ReadPackString(pack, szPlayerName, sizeof szPlayerName);
	int style = ReadPackCell(pack);
	CloseHandle(pack);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)) {
		db_SelectCustomPlayerCountryRank_GetCountry(client, szPlayerName, style);
	}
	else {
		CPrintToChat(client, "%t", "PlayerNotFound", g_szChatPrefix, szPlayerName);
	}
}

public void db_SelectCustomPlayerCountryRank_GetCountry(int client, char szPlayerName[MAX_NAME_LENGTH], int style)
{
	// Escape name for SQL injection protection
	char szName[MAX_NAME_LENGTH * 2 + 1];
	SQL_EscapeString(g_hDb, szPlayerName, szName, MAX_NAME_LENGTH);

	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, szName);
	WritePackCell(pack, style);

	//GET SELECT PLAYER COUNTRY
	char szQuery[512];
	Format(szQuery, sizeof szQuery, "SELECT country FROM ck_playerrank WHERE name = '%s' AND style = '%i';", szName, style);
	SQL_TQuery(g_hDb, db_SelectCustomPlayerCountryRank_GetCountryCallback, szQuery, pack, DBPrio_Low);
}

public void db_SelectCustomPlayerCountryRank_GetCountryCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (db_SelectCustomPlayerCountryRank_GetCountryCallback): %s ", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	char szPlayerName[MAX_NAME_LENGTH];
	ReadPackString(pack, szPlayerName, sizeof szPlayerName);
	int style = ReadPackCell(pack);
	CloseHandle(pack);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)) {
		char szCountryName[100];
		SQL_FetchString(hndl, 0, szCountryName, sizeof szCountryName);

		db_SelectCountryRank(client, szPlayerName, szCountryName, style);
	}
	else {
		CPrintToChat(client, "%t", "Player_Data_Not_Found", g_szChatPrefix);
	}
}

//sm_ctop
public void db_SelectCountryTOP(int client, char szCountryName[256], int style)
{
	if (!IsValidClient(client))
		return;

	g_iCountryTopStyleSelected[client] = style;

	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, szCountryName);
	WritePackCell(pack, style);

	char szQuery[512];
	Format(szQuery, sizeof szQuery, "SELECT name, country, points, style FROM ck_playerrank WHERE country = '%s' AND style = '%i' ORDER BY points DESC LIMIT 100;", szCountryName, style);
	SQL_TQuery(g_hDb, db_SelectCountryTOPCallback, szQuery, pack, DBPrio_Low);
}

public void db_SelectCountryTOPCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (db_SelectCountryTOPCallback): %s ", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	char szCountryName[56];
	ReadPackString(pack, szCountryName, sizeof szCountryName);
	int style = ReadPackCell(pack);
	CloseHandle(pack);

	if (SQL_HasResultSet(hndl)) {
		
		Menu menu = CreateMenu(CountryTopMenu);
		char szItem[256];

		if (SQL_GetRowCount(hndl) == 0) {
			CPrintToChat(client, "%t", "country_data_not_found", g_szChatPrefix);

			SetMenuTitle(menu, "Country Top for %s | %s\n \n", szCountryName, g_szStyleMenuPrint[style]);

			AddMenuItem(menu, "", "No Players Found", ITEMDRAW_DISABLED);

			SetMenuExitBackButton(menu, true);
			DisplayMenu(menu, client, MENU_TIME_FOREVER);

			return;
		}

		char szRank[16];
		char szPlayerName[MAX_NAME_LENGTH];
		int PlayerPoints;
		int Style;

		int row = 1;
		while (SQL_FetchRow(hndl)) {

			SQL_FetchString(hndl, 0, szPlayerName, sizeof szPlayerName);
			SQL_FetchString(hndl, 1, szCountryName, sizeof szCountryName);
			PlayerPoints = SQL_FetchInt(hndl, 2);
			
			Style = SQL_FetchInt(hndl, 3);
			char szStyle[256];
			IntToString(Style, szStyle, sizeof szStyle);
			
			if (row == 100)
				Format(szRank, sizeof szRank, "[%i.]", row);
			else if (row < 10)
				Format(szRank, sizeof szRank, "[0%i.]  ", row);
			else
				Format(szRank, sizeof szRank, "[%i.]  ", row);

			if (PlayerPoints < 10)
				Format(szItem, sizeof szItem, "%s      %dp        %s", szRank, PlayerPoints, szPlayerName);
			else if (PlayerPoints < 100)
				Format(szItem, sizeof szItem, "%s     %dp       %s", szRank, PlayerPoints, szPlayerName);
			else if (PlayerPoints < 1000)
				Format(szItem, sizeof szItem, "%s   %dp       %s", szRank, PlayerPoints, szPlayerName);
			else if (PlayerPoints < 10000)
				Format(szItem, sizeof szItem, "%s %dp       %s", szRank, PlayerPoints, szPlayerName);
			else if (PlayerPoints < 100000)
				Format(szItem, sizeof szItem, "%s %dp     %s", szRank, PlayerPoints, szPlayerName);
			else
				Format(szItem, sizeof szItem, "%s %dp   %s", szRank, PlayerPoints, szPlayerName);

			AddMenuItem(menu, szStyle, szItem, ITEMDRAW_DISABLED);

			row++;
		}

		SetMenuTitle(menu, "Country Top for %s | %s\n \n    Rank   Points       Player", szCountryName, g_szStyleMenuPrint[Style]);
		SetMenuPagination(menu, 5);
		SetMenuExitBackButton(menu, true);

		DisplayMenu(menu, client, MENU_TIME_FOREVER);
	}
}

public int CountryTopMenu(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Cancel) {
		db_GetCountriesNames(param1, g_iCountryTopStyleSelected[param1]);
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}

	return 0;
}

public void db_GetCountriesNames(int client, int style)
{
	if (!IsValidClient(client))
		return;

	g_iCountryTopStyleSelected[client] = style;

	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackCell(pack, style);

	char szQuery[512];
	Format(szQuery, sizeof szQuery, "SELECT DISTINCT(country) FROM ck_playerrank WHERE style = '%i' ORDER BY country;", style);
	SQL_TQuery(g_hDb, db_GetCountriesNamesCallback, szQuery, pack, DBPrio_Low);
}

public void db_GetCountriesNamesCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (db_GetCountriesNamesCallback): %s ", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	int style = ReadPackCell(pack);
	CloseHandle(pack);

	if (SQL_HasResultSet(hndl)) {

		Menu menu = CreateMenu(CountriesMenu);

		if (SQL_GetRowCount(hndl) == 0) {
			CPrintToChat(client, "%t", "country_data_not_found", g_szChatPrefix);

			SetMenuTitle(menu, "Countries List | %s\n \n", g_szStyleMenuPrint[style]);
			AddMenuItem(menu, "", "No Countries Found", ITEMDRAW_DISABLED);

			SetMenuExitBackButton(menu, true);
			DisplayMenu(menu, client, MENU_TIME_FOREVER);
			return;
		}

		char szBuffer[256];
		char szItem[256];
		char szCountryName[56];

		if (strcmp(g_szCountry[client], "", false) != 0) {
			Format(szItem, sizeof szItem, "My Country\n ");
			Format(szBuffer, sizeof szBuffer, "%s-%d", g_szCountry[client], style);
			AddMenuItem(menu, szBuffer, szItem);
		}

		while (SQL_FetchRow(hndl)) {
			SQL_FetchString(hndl, 0, szCountryName, sizeof szCountryName);
			Format(szItem, sizeof szItem, "%s", szCountryName);
			Format(szBuffer, sizeof szBuffer, "%s-%d", szCountryName, style);
			AddMenuItem(menu, szBuffer, szItem);
		}

		SetMenuTitle(menu, "Countries List | %s\n \n", g_szStyleMenuPrint[style]);
		SetMenuExitBackButton(menu, true);

		DisplayMenu(menu, client, MENU_TIME_FOREVER);
	}

}

public int CountriesMenu(Menu menu, MenuAction action, int param1, int param2)
{	
	if (action == MenuAction_Select) {
		char szBuffer[256];
		GetMenuItem(menu, param2, szBuffer, sizeof(szBuffer));

		char splits[2][256];
		ExplodeString(szBuffer, "-", splits, sizeof(splits), sizeof(splits[]));
		db_SelectCountryTOP(param1, splits[0], StringToInt(splits[1]));
	}
	else if (action == MenuAction_Cancel)
	{
		char szBuffer[256] = "none-none";
		CountryTopMenuStyleSelect(param1, szBuffer);
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}

	return 0;
}


//sm_continentrank
public void db_SelectContinentRank(int client, char szPlayerName[MAX_NAME_LENGTH], char szContinentCode[3], int style)
{
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, szPlayerName);
	WritePackString(pack, szContinentCode);
	WritePackCell(pack, style);

	//GET TOTAL AMOUNT OF PLAYERS
	char szQuery[512];
	Format(szQuery, sizeof szQuery, "SELECT COUNT(steamid) FROM ck_playerrank WHERE continentCode = '%s' AND style = '%i';", szContinentCode, style);
	SQL_TQuery(g_hDb, db_SelectContinentRankCallback, szQuery, pack, DBPrio_Low);
}

public void db_SelectContinentRankCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (db_SelectContinentRankCallback): %s ", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);

	char szPlayerName[MAX_NAME_LENGTH];
	ReadPackString(pack, szPlayerName, sizeof szPlayerName);

	char szContinentCode[3];
	ReadPackString(pack, szContinentCode, sizeof szContinentCode);

	int style = ReadPackCell(pack);
	CloseHandle(pack);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)) {

		db_GetPlayerPointsContinent(client, SQL_FetchInt(hndl, 0), szPlayerName, szContinentCode, style);
	}
}

public void db_GetPlayerPointsContinent(int client, int ContinentPlayerTotal, char szPlayerName[MAX_NAME_LENGTH], char szContinentCode[3], int style)
{	
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackCell(pack, ContinentPlayerTotal);
	WritePackString(pack, szPlayerName);
	WritePackString(pack, szContinentCode);
	WritePackCell(pack, style);

	//GET PLAYER POINTS
	char szQuery[512];
	Format(szQuery, sizeof szQuery, "SELECT points FROM ck_playerrank WHERE name = '%s' AND style = '%i';", szPlayerName, style);
	SQL_TQuery(g_hDb, db_GetPlayerPointsContinentCallback, szQuery, pack, DBPrio_Low);
}

public void db_GetPlayerPointsContinentCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (db_GetPlayerPointsCallback): %s ", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	int ContinentPlayerTotal = ReadPackCell(pack);
	char szPlayerName[MAX_NAME_LENGTH];
	ReadPackString(pack, szPlayerName, sizeof szPlayerName);
	char szContinentCode[3];
	ReadPackString(pack, szContinentCode, sizeof szContinentCode);
	int style = ReadPackCell(pack);
	CloseHandle(pack);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)) {
		db_GetPlayerContinentRank(SQL_FetchInt(hndl, 0), ContinentPlayerTotal, szPlayerName, szContinentCode, style);
	}
	else {
		CPrintToChat(client, "%t", "Player_Data_Not_Found", g_szChatPrefix);
	}
}

public void db_GetPlayerContinentRank(int PlayerPoints, int ContinentPlayerTotal, char szPlayerName[MAX_NAME_LENGTH], char szContinentCode[3], int style)
{	
	Handle pack = CreateDataPack();
	WritePackCell(pack, PlayerPoints);
	WritePackCell(pack, ContinentPlayerTotal);
	WritePackString(pack, szPlayerName);
	WritePackString(pack, szContinentCode);
	WritePackCell(pack, style);

	//GET CLIENT CONTINENT RANK
	char szQuery[512];
	Format(szQuery, sizeof szQuery, "SELECT COUNT(steamid) + 1 FROM ck_playerrank WHERE continentCode = '%s' AND style = '%i' AND points > '%i';", szContinentCode, style, PlayerPoints);
	SQL_TQuery(g_hDb, db_GetPlayerContinentRankCallback, szQuery, pack, DBPrio_Low);
}

public void db_GetPlayerContinentRankCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (db_GetPlayerContinentRankCallback): %s ", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);
	int PlayerPoints = ReadPackCell(pack);
	int ContinentPlayerTotal = ReadPackCell(pack);
	char szPlayerName[MAX_NAME_LENGTH];
	ReadPackString(pack, szPlayerName, sizeof szPlayerName);
	char szContinentCode[3];
	ReadPackString(pack, szContinentCode, sizeof szContinentCode);
	int style = ReadPackCell(pack);
	CloseHandle(pack);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)) {
		char szContinentName[100];
		GetContinentName(szContinentCode, szContinentName, sizeof szContinentName);

		CPrintToChatAll("%t", "Continent_Rank", g_szChatPrefix, g_szStyleRecordPrint[style], szPlayerName, SQL_FetchInt(hndl, 0), ContinentPlayerTotal, szContinentName, PlayerPoints);
	}
}

//sm_continent <playername>
//sm_continentrank <playername> <style>
//sm_continentnrank <style> <playername>
public void db_SelectCustomPlayerContinentRank(int client, char szPlayerName[MAX_NAME_LENGTH], int style)
{
	// Escape name for SQL injection protection
	char szName[MAX_NAME_LENGTH * 2 + 1];
	SQL_EscapeString(g_hDb, szPlayerName, szName, MAX_NAME_LENGTH);

	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, szName);
	WritePackCell(pack, style);

	//CHECK IF PLAYER EXISTS
	char szQuery[512];
	Format(szQuery, sizeof szQuery, "SELECT * FROM ck_playerrank WHERE name = '%s';", szName);
	SQL_TQuery(g_hDb, db_SelectCustomPlayerContinentRankCallback, szQuery, pack, DBPrio_Low);
}

public void db_SelectCustomPlayerContinentRankCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (db_SelectCustomPlayerContinentRankCallback): %s ", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	char szPlayerName[MAX_NAME_LENGTH];
	ReadPackString(pack, szPlayerName, sizeof szPlayerName);
	int style = ReadPackCell(pack);
	CloseHandle(pack);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)) {
		db_SelectCustomPlayerContinentRank_GetContinent(client, szPlayerName, style);
	}
	else {
		CPrintToChat(client, "%t", "PlayerNotFound", g_szChatPrefix, szPlayerName);
	}
}

public void db_SelectCustomPlayerContinentRank_GetContinent(int client, char szPlayerName[MAX_NAME_LENGTH], int style)
{
	// Escape name for SQL injection protection
	char szName[MAX_NAME_LENGTH * 2 + 1];
	SQL_EscapeString(g_hDb, szPlayerName, szName, MAX_NAME_LENGTH);

	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, szName);
	WritePackCell(pack, style);

	//GET SELECT PLAYER CONTINENT
	char szQuery[512];
	Format(szQuery, sizeof szQuery, "SELECT continentCode FROM ck_playerrank WHERE name = '%s' AND style = '%i';", szName, style);
	SQL_TQuery(g_hDb, db_SelectCustomPlayerContinentRank_GetContinentCallback, szQuery, pack, DBPrio_Low);
}

public void db_SelectCustomPlayerContinentRank_GetContinentCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (db_SelectCustomPlayerContinentRank_GetContinentCallback): %s ", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	char szPlayerName[MAX_NAME_LENGTH];
	ReadPackString(pack, szPlayerName, sizeof szPlayerName);
	int style = ReadPackCell(pack);
	CloseHandle(pack);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)) {
		char szContinentCode[3];
		SQL_FetchString(hndl, 0, szContinentCode, sizeof szContinentCode);

		db_SelectContinentRank(client, szPlayerName, szContinentCode, style);
	}
	else {
		CPrintToChat(client, "%t", "Player_Data_Not_Found", g_szChatPrefix);
	}
}

//sm_continenttop
public void db_SelectContinentTOP(int client, char szContinentCode[3], int style)
{
	if (!IsValidClient(client))
		return;

	g_iContinentTopStyleSelected[client] = style;

	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, szContinentCode);
	WritePackCell(pack, style);

	char szQuery[512];
	Format(szQuery, sizeof szQuery, "SELECT name,  points, style FROM ck_playerrank WHERE continentCode = '%s' AND style = '%i' ORDER BY points DESC LIMIT 100;", szContinentCode, style);
	SQL_TQuery(g_hDb, db_SelectContinentTOPCallback, szQuery, pack, DBPrio_Low);
}

public void db_SelectContinentTOPCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (db_SelectContinentTOPCallback): %s ", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	char szContinentCode[3];
	ReadPackString(pack, szContinentCode, sizeof szContinentCode);
	int style = ReadPackCell(pack);
	CloseHandle(pack);

	char szContinentName[100];
	GetContinentName(szContinentCode, szContinentName, sizeof szContinentName);

	if (SQL_HasResultSet(hndl)) {

		Menu menu = CreateMenu(ContinentTopMenu);
		char szItem[256];

		if (SQL_GetRowCount(hndl) == 0) {
			CPrintToChat(client, "%t", "continent_data_not_found", g_szChatPrefix);

			SetMenuTitle(menu, "Continent Top for %s | %s\n \n", szContinentName, g_szStyleMenuPrint[style]);

			AddMenuItem(menu, "", "No Players Found", ITEMDRAW_DISABLED);

			SetMenuExitBackButton(menu, true);
			DisplayMenu(menu, client, MENU_TIME_FOREVER);

			return;
		}

		char szRank[16];
		char szPlayerName[MAX_NAME_LENGTH];
		int PlayerPoints;
		int Style;

		int row = 1;
		while (SQL_FetchRow(hndl)) {

			SQL_FetchString(hndl, 0, szPlayerName, sizeof szPlayerName);
			PlayerPoints = SQL_FetchInt(hndl, 1);
			
			Style = SQL_FetchInt(hndl, 2);
			char szStyle[256];
			IntToString(Style, szStyle, sizeof szStyle);
			
			if (row == 100)
				Format(szRank, sizeof szRank, "[%i.]", row);
			else if (row < 10)
				Format(szRank, sizeof szRank, "[0%i.]  ", row);
			else
				Format(szRank, sizeof szRank, "[%i.]  ", row);

			if (PlayerPoints < 10)
				Format(szItem, sizeof szItem, "%s      %dp        %s", szRank, PlayerPoints, szPlayerName);
			else if (PlayerPoints < 100)
				Format(szItem, sizeof szItem, "%s     %dp       %s", szRank, PlayerPoints, szPlayerName);
			else if (PlayerPoints < 1000)
				Format(szItem, sizeof szItem, "%s   %dp       %s", szRank, PlayerPoints, szPlayerName);
			else if (PlayerPoints < 10000)
				Format(szItem, sizeof szItem, "%s %dp       %s", szRank, PlayerPoints, szPlayerName);
			else if (PlayerPoints < 100000)
				Format(szItem, sizeof szItem, "%s %dp     %s", szRank, PlayerPoints, szPlayerName);
			else
				Format(szItem, sizeof szItem, "%s %dp   %s", szRank, PlayerPoints, szPlayerName);

			AddMenuItem(menu, szStyle, szItem, ITEMDRAW_DISABLED);

			row++;
		}

		SetMenuTitle(menu, "Continent Top for %s | %s\n \n    Rank   Points       Player", szContinentName, g_szStyleMenuPrint[Style]);
		SetMenuPagination(menu, 5);
		SetMenuExitBackButton(menu, true);

		DisplayMenu(menu, client, MENU_TIME_FOREVER);
	}
}

public int ContinentTopMenu(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Cancel) {
		db_GetContinentNames(param1, g_iContinentTopStyleSelected[param1]);
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}

	return 0;
}

public void db_GetContinentNames(int client, int style)
{
	if (!IsValidClient(client))
		return;

	g_iContinentTopStyleSelected[client] = style;

	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackCell(pack, style);

	char szQuery[512];
	Format(szQuery, sizeof szQuery, "SELECT DISTINCT(continentCode) FROM ck_playerrank WHERE style = '%i' AND continentCode IS NOT NULL ORDER BY continentCode;", style);
	SQL_TQuery(g_hDb, db_GetContinentNamesCallback, szQuery, pack, DBPrio_Low);
}

public void db_GetContinentNamesCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (db_GetContinentNamesCallback): %s ", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	int style = ReadPackCell(pack);
	CloseHandle(pack);

	if (SQL_HasResultSet(hndl)) {

		Menu menu = CreateMenu(ContinentMenu);

		if (SQL_GetRowCount(hndl) == 0) {
			CPrintToChat(client, "%t", "continent_data_not_found", g_szChatPrefix);

			SetMenuTitle(menu, "Continent's List | %s\n \n", g_szStyleMenuPrint[style]);
			AddMenuItem(menu, "", "No Continent's Found", ITEMDRAW_DISABLED);

			SetMenuExitBackButton(menu, true);
			DisplayMenu(menu, client, MENU_TIME_FOREVER);
			return;
		}

		char szBuffer[256];
		char szItem[256];
		char szContinentCode[3];
		char szContinentName[100];
		GetContinentName(szContinentCode, szContinentName, sizeof szContinentName);

		if (strcmp(g_szContinentCode[client], "", false) != 0) {
			Format(szItem, sizeof szItem, "My Continent\n ");
			Format(szBuffer, sizeof szBuffer, "%s-%d", g_szContinentCode[client], style);
			AddMenuItem(menu, szBuffer, szItem);
		}

		while (SQL_FetchRow(hndl)) {
			SQL_FetchString(hndl, 0, szContinentCode, sizeof szContinentCode);
			GetContinentName(szContinentCode, szContinentName, sizeof szContinentName);
			Format(szItem, sizeof szItem, "%s", szContinentName);
			Format(szBuffer, sizeof szBuffer, "%s-%d", szContinentCode, style);
			AddMenuItem(menu, szBuffer, szItem);
		}

		SetMenuTitle(menu, "Continent's List | %s\n \n", g_szStyleMenuPrint[style]);
		SetMenuExitBackButton(menu, true);

		DisplayMenu(menu, client, MENU_TIME_FOREVER);
	}

}

public int ContinentMenu(Menu menu, MenuAction action, int param1, int param2)
{	
	if (action == MenuAction_Select) {
		char szBuffer[256];
		GetMenuItem(menu, param2, szBuffer, sizeof(szBuffer));

		char splits[2][256];
		char szContinentCode[3];
		ExplodeString(szBuffer, "-", splits, sizeof(splits), sizeof(splits[]));
		Format(szContinentCode, sizeof szContinentCode, "%s", splits[0]);
		db_SelectContinentTOP(param1, szContinentCode, StringToInt(splits[1]));
	}
	else if (action == MenuAction_Cancel)
	{
		char szBuffer[256] = "none-none";
		ContinentTopMenuStyleSelect(param1, szBuffer);
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}

	return 0;
}



public void db_ViewPlayerRank(int client)
{
	char szQuery[512];
	Format(szQuery, sizeof szQuery, "SELECT name, points, style FROM ck_playerrank WHERE style = %i AND points >= (SELECT points FROM ck_playerrank WHERE steamid = '%s' AND style = %i) ORDER BY points;", g_iCurrentStyle[client], g_szSteamID[client], g_iCurrentStyle[client]);
	SQL_TQuery(g_hDb, db_ViewPlayerRankCallback, szQuery, client, DBPrio_Low);
}

public void db_ViewPlayerRankCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null) {
		LogError("[SurfTimer] SQL Error (db_ViewPlayerRankCallback): %s", error);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)) {
		int rank = SQL_GetRowCount(hndl);
		int points = SQL_FetchInt(hndl, 1);

		// Get players skillgroup
		SkillGroup RankValue;
		SkillGroup Next_RankValue;
		int index = GetSkillgroupIndex(rank, points);
		GetArrayArray(g_hSkillGroups, index, RankValue, sizeof(SkillGroup));

		if (index != 0) {
			GetArrayArray(g_hSkillGroups, index-1, Next_RankValue, sizeof(Next_RankValue));

			char szSkillGroup[128];
			Format(szSkillGroup, sizeof(szSkillGroup), Next_RankValue.RankNameColored);
			ReplaceString(szSkillGroup, sizeof(szSkillGroup), "{style}", "");

			//FOR RANKS THAT USE POINT RANGE
			//i.e
			/*
			"15"	
			{
				"rankTitle" "{default}[{gray}ROOKIE{default}]"
				"nameColour" "{gray}"
				"points" "1-299"
			}
			*/
			if ( RankValue.PointsBot > -1 && RankValue.PointsTop > -1) {
				CPrintToChat(client, "%t", "NextRankPointRequired", g_szChatPrefix, Next_RankValue.PointsTop - points, szSkillGroup);
			}
			//FOR RANKS WITHOUT POINT RANGE
			//i.e
			/*
			"16"
			{
				"rankTitle" "{default}[UNRANKED]"
				"nameColour" "{default}"
				"points" "0"
			}
			*/
			else if (RankValue.PointReq > -1) {
				CPrintToChat(client, "%t", "NextRankPointRequired", g_szChatPrefix, Next_RankValue.PointReq - points, szSkillGroup);
			}
			//FOR RANKS THAT DONT USE POINTS, BUT RATHER RANK RANGE
			//i.e
			/*
			"4"
			{
				"rankTitle" "{default}[{pink}LEGEND{default}]"
				"nameColour" "{pink}"
				"rank" "4-10"
			}
			*/
			else if ( RankValue.RankBot > 0 && RankValue.RankTop > 0) {
				db_GetNextRankPoints(client, SQL_FetchInt(hndl, 2), points, Next_RankValue.RankTop, szSkillGroup);
			}
			//FOR RANKS THAT ARE A FIXED NUMBER
			//i.e
			/*
			"1"
			{
				"rankTitle" "{default}[{style}{darkred}GENERAL{default}]"
				"nameColour" "{darkred}"
				"rank" "1"
			}
			*/
			else {
				db_GetNextRankPoints(client, SQL_FetchInt(hndl, 2), points, Next_RankValue.RankReq, szSkillGroup);
			}

		}
		else {
			CPrintToChat(client, "%t", "MAX_RANK", g_szChatPrefix);
		}
	}

}

public void db_GetNextRankPoints(int client, int style, int points, int next_rank, char szNextRankName[128])
{
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackCell(pack, points);
	WritePackString(pack, szNextRankName);

	char szQuery[512];
	Format(szQuery, sizeof szQuery, "SELECT points FROM ck_playerrank WHERE style = %d ORDER BY points DESC LIMIT %d,1;", style, next_rank - 1);
	SQL_TQuery(g_hDb, db_GetNextRankPointsCallback, szQuery, pack, DBPrio_Low);
}

public void db_GetNextRankPointsCallback(Handle owner, Handle hndl, const char[] error, DataPack pack)
{
	if (hndl == null) {
		LogError("[SurfTimer] SQL Error (db_GetNextRankPointsCallback): %s", error);
		delete pack;
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl)) {

		ResetPack(pack);
		int client = ReadPackCell(pack);
		int points = ReadPackCell(pack);
		char szNextRankName[128];
		ReadPackString(pack, szNextRankName, sizeof szNextRankName);
		delete pack;

		CPrintToChat(client, "%t", "NextRankPointRequired", g_szChatPrefix, SQL_FetchInt(hndl, 0) - points, szNextRankName);
	}

}

//ALREADY HAVE THE PLAYER RANK ( sm_ccp @<rank> )
public void db_viewCCP_WithMapRank(int client, char szSteamID[32], char szMapName[128], int map_rank)
{
	if (!IsValidClient(client))
		return;

	char szQuery[2048];

	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, szSteamID);
	WritePackString(pack, szMapName);
	WritePackCell(pack, map_rank);

	Format(szQuery, 2048, "SELECT -1, runtimepro, steamid  FROM ck_playertimes WHERE mapname = '%s' AND style = '0' ORDER BY runtimepro ASC LIMIT %i, 1;", szMapName, map_rank-1);
	SQL_TQuery(g_hDb, SQL_viewCCP_GetMapRankCallback, szQuery, pack, DBPrio_Low);
}

//GET PLAYER'S CCP MAP RANK
public void db_viewCCP_GetMapRank(int client, char szSteamID[32], char szMapName[128])
{
	if (!IsValidClient(client))
		return;

	char szQuery[2048];

	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, szSteamID);
	WritePackString(pack, szMapName);
	
	Format(szQuery, sizeof(szQuery), "SELECT COUNT(*), runtimepro, steamid FROM ck_playertimes WHERE runtimepro <= (SELECT runtimepro FROM ck_playertimes WHERE steamid = '%s' AND mapname = '%s' AND style = 0 AND runtimepro > -1.0) AND mapname = '%s' AND style = 0 AND runtimepro > -1.0;", szSteamID, szMapName, szMapName);
	SQL_TQuery(g_hDb, SQL_viewCCP_GetMapRankCallback, szQuery, pack, DBPrio_Low);
}

public void SQL_viewCCP_GetMapRankCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (db_viewCCP_GetMapRankCallback): %s ", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);

	int client = ReadPackCell(pack);

	char szSteamID[32];
	char szMapName[128];
	ReadPackString(pack, szSteamID, sizeof(szSteamID));
	ReadPackString(pack, szMapName, sizeof(szMapName));

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		int map_rank = SQL_FetchInt(hndl, 0);
		
		float map_time = SQL_FetchFloat(hndl, 1);

		char szPlayerSteamID[32];
		SQL_FetchString(hndl, 2,  szPlayerSteamID, 32);

		char szMapTimeFormatted[32];
		FormatTimeFloat(client, map_time, 3, szMapTimeFormatted, 32);
		
		//IF THE DIDNT PLAYER PROVIDED THE RANK BEFORE
		//THIS -1 IS A COLUMN FROM THE SQL QUERY
		//WHEN IT HAS A -1 IN IT , IT MEANS THE PLAYER PROVIDED THE RANK
		if(map_rank != -1) {
			db_GetTotalMapCompletions(client, szSteamID, szMapName, map_time, map_rank);
		}
		//IF THE PLAYER PROVIDED THE RANK BEFORE
		else{
			//SINCE THE PLAYER PROVIDED THE RANK WE READ FROM THE PACK GENERATED WITH THE RANK
			map_rank = ReadPackCell(pack);
			db_GetTotalMapCompletions(client, szPlayerSteamID, szMapName, map_time, map_rank);
		}
	}
	else {
		CPrintToChat(client, "%t", "CCP_02", g_szChatPrefix);
	}
	
	CloseHandle(pack);
}

//GET TOTAL MAP COMPLETIONS
public void db_GetTotalMapCompletions(int client, char szSteamID[32], char szMapName[128], float map_time, int map_rank){

	char szQuery[2048];

	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackFloat(pack, map_time);
	WritePackCell(pack, map_rank);
	WritePackString(pack, szSteamID);
	WritePackString(pack, szMapName);

	Format(szQuery, 1024, "SELECT count(runtimepro) FROM ck_playertimes WHERE mapname = '%s' AND style = '0';", szMapName);
	SQL_TQuery(g_hDb, SQL_GetTotalMapCompletionsCallback, szQuery, pack, DBPrio_Low);

}

public void SQL_GetTotalMapCompletionsCallback(Handle owner, Handle hndl, const char[] error, any pack){

	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (SQL_viewCCP_GetMapStageTimesPracCallbac): %s ", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);

	int client = ReadPackCell(pack);

	float map_time = ReadPackFloat(pack);
	int map_rank = ReadPackCell(pack);

	char szSteamID[32];
	char szMapName[128];
	ReadPackString(pack, szSteamID, sizeof(szSteamID));
	ReadPackString(pack, szMapName, sizeof(szMapName));

	CloseHandle(pack);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		int total_map_completions = SQL_FetchInt(hndl, 0);

		if(total_map_completions > 0)
			db_getRecordTime(client, szSteamID, szMapName, map_time, map_rank, total_map_completions);
		else
			CPrintToChat(client, "%t", "CCP_03", g_szChatPrefix);
	}
}

//GET RECORD TIME (200IQ EXPLANATION)
public void db_getRecordTime(int client, char szSteamID[32], char szMapName[128], float map_time, int map_rank, int total_map_completions){

	char szQuery[2048];

	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackFloat(pack, map_time);
	WritePackCell(pack, map_rank);
	WritePackCell(pack, total_map_completions);
	WritePackString(pack, szSteamID);
	WritePackString(pack, szMapName);

	Format(szQuery, 1024, "SELECT steamid, runtimepro FROM ck_playertimes WHERE mapname = '%s' AND style = 0 ORDER BY runtimepro ASC LIMIT 1;", szMapName);
	SQL_TQuery(g_hDb, SQL_getRecordTimeCallback, szQuery, pack, DBPrio_Low);

}

public void SQL_getRecordTimeCallback(Handle owner, Handle hndl, const char[] error, any pack){

	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (SQL_viewCCP_GetMapStageTimesPracCallbac): %s ", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);

	int client = ReadPackCell(pack);

	float map_time = ReadPackFloat(pack);
	int map_rank = ReadPackCell(pack);
	int total_map_completions = ReadPackCell(pack);

	char szSteamID[32];
	char szMapName[128];
	ReadPackString(pack, szSteamID, sizeof(szSteamID));
	ReadPackString(pack, szMapName, sizeof(szMapName));

	CloseHandle(pack);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		char Record_SteamID[32];
		SQL_FetchString(hndl, 0, Record_SteamID, 32);

		float record_time = SQL_FetchFloat(hndl, 1);

		db_viewCCP_GetMapStageTimes_Record(client, szSteamID, Record_SteamID, szMapName, map_time, map_rank, total_map_completions, record_time);

	}
	else {
		CPrintToChat(client, "%t", "CCP_04", g_szChatPrefix);
	}

}

public void db_viewCCP_GetMapStageTimes_Record(int client, char szSteamID[32], char Record_SteamID[32], char szMapName[128], float map_time, int map_rank,int total_map_completions, float record_time)
{
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackFloat(pack, map_time);
	WritePackFloat(pack, record_time);
	WritePackCell(pack, map_rank);
	WritePackCell(pack, total_map_completions);
	WritePackString(pack, szSteamID);
	WritePackString(pack, szMapName);

	char szQuery[2048];

	Format(szQuery, 2048, sql_selectStageTimes, szMapName, Record_SteamID);
	SQL_TQuery(g_hDb, SQL_viewCCP_GetMapStageTimes_RecordCallback, szQuery, pack, DBPrio_Low);

}

public void SQL_viewCCP_GetMapStageTimes_RecordCallback(Handle owner, Handle hndl, const char[] error, any pack)
{

	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (SQL_viewCCP_GetMapStageTimes_RecordCallback): %s ", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);

	int client = ReadPackCell(pack);

	float map_time = ReadPackFloat(pack);
	float record_time = ReadPackFloat(pack);
	int map_rank = ReadPackCell(pack);
	int total_map_completions = ReadPackCell(pack);

	char szSteamID[32];
	char szMapName[128];
	ReadPackString(pack, szSteamID, sizeof(szSteamID));
	ReadPackString(pack, szMapName, sizeof(szMapName));

	CloseHandle(pack);

	if (SQL_HasResultSet(hndl))
	{
		while (SQL_FetchRow(hndl)) {
			int cp;
			cp = SQL_FetchInt(hndl, 0);

			g_fCCP_StageTimes_ServerRecord[client][cp-1] = SQL_FetchFloat(hndl, 1);
		}

		//IF RECORD HAS CCP ENTRIES
		if(g_fCCP_StageTimes_ServerRecord[client][0] > 0.0)
			db_viewCCP_GetPlayerPR(client, szSteamID, szMapName, map_time, map_rank, record_time, total_map_completions);
		else
			CPrintToChat(client, "%t", "CCP_06", g_szChatPrefix);
	}
	else
		CPrintToChat(client, "%t", "CCP_05", g_szChatPrefix);

}

//THIS FUNCTION RETRIEVES
//STAGE RUNTIME OF CCP
//STAGE ATTEMPTS OF CCP
//STAGE RANK OF CCP
//STAGE TOTAL OF CCP
public void db_viewCCP_GetPlayerPR(int client, char szSteamID[32], char szMapName[128], float map_time, int map_rank, float record_time, int total_map_completions){

	Handle pack = CreateDataPack();
	WritePackCell(pack, client); //CLIENT WHO DID SM_CCP
	WritePackFloat(pack, map_time); //PLAYERS MAP TIME
	WritePackFloat(pack, record_time); //RECORD MAP TIME
	WritePackCell(pack, map_rank); //PLAYERS MAP RANK
	WritePackCell(pack, total_map_completions); // TOTAL COMPLETIONS ON GIVEN MAP
	WritePackString(pack, szSteamID);  // REQUESTED PLAYER CCP STEAMID
	WritePackString(pack, szMapName); //MAP USED ON CCP

	char szQuery[2048];
	Format(szQuery, sizeof szQuery, "SELECT db1.steamid, db1.mapname, db1.cp, db1.stage_time, db1.stage_attempts, (SELECT count(name)+1 FROM ck_wrcps WHERE style = 0 AND mapname = db1.mapname AND stage = db1.cp AND stage_time > -1.0 AND runtimepro <= db1.stage_time) AS `rank`, (SELECT count(name) FROM ck_wrcps WHERE style = 0 AND mapname = db1.mapname AND stage = db1.cp AND runtimepro > -1.0) AS total FROM ck_checkpoints db1 WHERE db1.mapname = '%s' AND db1.steamid = '%s' AND db1.stage_time > -1.0  ORDER BY cp ASC;", szMapName, szSteamID);
	SQL_TQuery(g_hDb, SQL_db_viewCCP_GetPlayerPRCallback, szQuery, pack, DBPrio_Low);
}

public void SQL_db_viewCCP_GetPlayerPRCallback(Handle owner, Handle hndl, const char[] error, any pack)
{

	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (SQL_db_viewCCP_GetPlayerPRCallback): %s ", error);
		CloseHandle(pack);
		return;
	}

	ResetPack(pack);

	int client = ReadPackCell(pack);

	//MAP VARIABLES
	float map_time = ReadPackFloat(pack);
	float record_time = ReadPackFloat(pack);
	int map_rank = ReadPackCell(pack);
	int total_map_completions = ReadPackCell(pack);

	char szSteamID[32];
	char szMapName[128];
	ReadPackString(pack, szSteamID, sizeof(szSteamID));
	ReadPackString(pack, szMapName, sizeof(szMapName));

	CloseHandle(pack);

	if (SQL_HasResultSet(hndl))
	{
		//STRUCTURE OF RETURNED QUERY
		// STEAMDID | NAME | MAPNAME | STAGE | STAGETIME | STAGE ATTEMPTS | STAGE RANK | STAGE TOTAL

		//USE ROW COUNT TO GET TOTAL OF STAGES
		int total_stages = SQL_GetRowCount(hndl);

		while (SQL_FetchRow(hndl)) {
			int cp = SQL_FetchInt(hndl, 2);

			g_fCCP_StageTimes_Player[client][cp-1] = SQL_FetchFloat(hndl, 3);
			g_iCCP_StageAttempts_Player[client][cp-1] = SQL_FetchInt(hndl, 4);
			g_iCCP_StageRank_Player[client][cp-1] = SQL_FetchInt(hndl, 5);
			g_iCCP_StageTotal_Player[client][cp-1] = SQL_FetchInt(hndl, 6);

		}

		DisplayCCPMenu(client, map_time, record_time, map_rank, total_map_completions, total_stages, szSteamID, szMapName);
	}

}

public void DisplayCCPMenu(int client, float map_time, float record_time, int map_rank, int total_map_completions, int total_stages, char szSteamID[32], char szMapName[128])
{
	Menu ccp_menu = new Menu(CCPMenuHandler);
	
	char szItem[256];

	for (int i = 0; i < total_stages; i++) 
	{
		//FORMAT PLAYER STAGE TIME
		char szStageTimeFormatted[32];
		FormatTimeFloat(client, g_fCCP_StageTimes_Player[client][i], 3, szStageTimeFormatted, sizeof szStageTimeFormatted);
		//FORMAT WRCP DIFF
		char szStageTimeDifferenceFormatted[32];
		FormatTimeFloat(client, g_fCCP_StageTimes_ServerRecord[client][i] - g_fCCP_StageTimes_Player[client][i], 3, szStageTimeDifferenceFormatted, sizeof szStageTimeDifferenceFormatted);
		if(g_fCCP_StageTimes_ServerRecord[client][i] - g_fCCP_StageTimes_Player[client][i] >= 0.0)
			Format(szStageTimeDifferenceFormatted, sizeof szStageTimeDifferenceFormatted, "-%s", szStageTimeDifferenceFormatted);
		else
			Format(szStageTimeDifferenceFormatted, sizeof szStageTimeDifferenceFormatted, "+%s", szStageTimeDifferenceFormatted);

		//FORMAT STAGE DISPLAY
		//IF THE STAGE RANK THE PLAYER GETS IS THE SLOWEST JUST INCREASE THE RANKS BY 1
		if(g_iCCP_StageRank_Player[client][i] < g_iCCP_StageTotal_Player[client][i])
			Format(szItem, sizeof(szItem), "Stage %i\nRank %i/%i\nAttempts : %i\nTime: %s (%s)\n \n", i+1, g_iCCP_StageRank_Player[client][i], g_iCCP_StageTotal_Player[client][i], g_iCCP_StageAttempts_Player[client][i], szStageTimeFormatted, szStageTimeDifferenceFormatted);
		else
			Format(szItem, sizeof(szItem), "Stage %i\nRank %i/%i\nAttempts : %i\nTime: %s (%s)\n \n", i+1, g_iCCP_StageRank_Player[client][i], g_iCCP_StageTotal_Player[client][i] + 1, g_iCCP_StageAttempts_Player[client][i], szStageTimeFormatted, szStageTimeDifferenceFormatted);


		AddMenuItem(ccp_menu, "", szItem, ITEMDRAW_DEFAULT);
	}
	
	//FORMAT PLAYERS RUNTIME
	char szMapTimeFormatted[32];
	FormatTimeFloat(client, map_time, 3, szMapTimeFormatted, sizeof szMapTimeFormatted);
	//FORMAT PLAYERS VS RECORD TIME DIFFERENCE
	char szMapTimeDiffFormatted[32];
	FormatTimeFloat(client, record_time - map_time, 3, szMapTimeDiffFormatted, sizeof szMapTimeDiffFormatted);

	Format(szItem, sizeof(szItem), "Map\nRank %i/%i\n%s (+%s)\n \n", map_rank, total_map_completions, szMapTimeFormatted, szMapTimeDiffFormatted);
	AddMenuItem(ccp_menu, "", szItem, ITEMDRAW_DEFAULT);

	//MENU TITLE
	SetMenuTitle(ccp_menu, "%s CCP Times for Rank %i\nTime: %s (+%s)\n \n", szMapName, map_rank, szMapTimeFormatted, szMapTimeDiffFormatted);
	SetMenuPagination(ccp_menu, 3);
	DisplayMenu(ccp_menu, client, MENU_TIME_FOREVER);

	//RESET THE SM_CCP VALUES
	resetCCPDefaults(client);
}

public int CCPMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if(action == MenuAction_Select)
		return 0;
	else if(action == MenuAction_End)
		delete menu;

	return 0;
}
