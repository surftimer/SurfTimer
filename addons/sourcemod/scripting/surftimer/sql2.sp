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
	if (hndl == null)
	{
		LogError("[surftimer] SQL Error (SQL_ViewMapNamePrCallback): %s ", error);
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	char szSteamId[32];
	ReadPackString(pack, szSteamId, 32);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		char szMapName[128];
		SQL_FetchString(hndl, 0, szMapName, 128);
		WritePackString(pack, szMapName);

		char szQuery[1024];
		Format(szQuery, 1024, "SELECT mapname, (SELECT COUNT(1) FROM ck_zones WHERE zonetype = '3' AND mapname = '%s') AS stages, (SELECT COUNT(DISTINCT zonegroup) FROM ck_zones WHERE mapname = '%s' AND zonegroup > 0) AS bonuses FROM ck_maptier WHERE mapname = '%s';", szMapName, szMapName, szMapName);
		SQL_TQuery(g_hDb, SQL_ViewPlayerPrMapInfoCallback, szQuery, pack, DBPrio_Low);
	}
	else
	{
		CloseHandle(pack);
		CPrintToChat(client, "%t", "SQLTwo1", g_szChatPrefix);
	}
}

public void SQL_ViewPlayerPrMapInfoCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[surftimer] SQL Error (SQL_ViewPlayerPrMapInfoCallback): %s ", error);
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
	else
	{
		CloseHandle(pack);
	}
}

public void SQL_ViewPlayerPrMaptimeCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[surftimer] SQL Error (SQL_ViewPlayerPrMaptimeCallback): %s ", error);
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

	Format(szQuery, 1024, "SELECT db1.steamid, db1.name, db1.mapname, db1.runtimepro, db1.stage, (SELECT count(name) FROM ck_wrcps WHERE style = 0 AND mapname = db1.mapname AND stage = db1.stage AND runtimepro > -1.0 AND runtimepro <= db1.runtimepro) AS rank, (SELECT count(name) FROM ck_wrcps WHERE style = 0 AND mapname = db1.mapname AND stage = db1.stage AND runtimepro > -1.0) AS total FROM ck_wrcps db1 WHERE db1.mapname = '%s' AND db1.steamid = '%s' AND db1.runtimepro > -1.0 AND db1.style = 0 ORDER BY stage ASC", szMapName, szSteamId);
	SQL_TQuery(g_hDb, SQL_ViewPlayerPrMaptimeCallback2, szQuery, pack, DBPrio_Low);
}

public void SQL_ViewPlayerPrMaptimeCallback2(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[surftimer] SQL Error (SQL_ViewPlayerPrMaptimeCallback2): %s ", error);
	}

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

	int target = g_iPrTarget[client];
	int stage;
	int stagerank = 1;
	int totalcompletes = 1;
	int totalstages = 0;
	float stagetime[CPLIMIT];

	for (int i = 1; i < CPLIMIT; i++)
		stagetime[i] = -1.0;

	if (SQL_HasResultSet(hndl))
	{
		while (SQL_FetchRow(hndl))
		{
			totalstages++;
			stage = SQL_FetchInt(hndl, 4);
			stagetime[stage] = SQL_FetchFloat(hndl, 3);
			stagerank = SQL_FetchInt(hndl, 5);
			totalcompletes = SQL_FetchInt(hndl, 6);
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
		g_totalStagesPr[client] = g_TotalStages;
	}

	if (g_totalStagesPr[client] > 0)
	{
		for (int i = 1;i <= g_totalStagesPr[client]; i++)
		{
			if (stagetime[i] != -1.0)
			{
				FormatTimeFloat(0, stagetime[i], 3, szRuntimestages[i], 64);
				Format(szStageInfo[i], 256, "Stage %i: %s\nRank: %i/%i\n \n", i, szRuntimestages[i], stagerank, totalcompletes);
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
	if (action == MenuAction_Select)
	{

	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
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
	}

	g_bVip[client] = false;
	g_bZoner[client] = false;

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		g_bVip[client] = view_as<bool>(SQL_FetchInt(hndl, 0));
		g_bZoner[client] = view_as<bool>(SQL_FetchInt(hndl, 2));
	}

	if (!g_bVip[client] || !g_bZoner[client]) // No VIP or Zoner from database, let's check flags
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
		LogToFileEx(g_szLogFile, "[Surftimer] %s: Finished db_CheckVIPAdmin in %fs", g_szSteamID[client], tick);
		g_fTick[client][0] = GetGameTime();


		LoadClientSetting(client, g_iSettingToLoad[client]);
	}
}

public void SQL_InsertVipFromSourcebansCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null)
	{
		LogError("[surftimer] SQL Error (SQL_InsertVipFromSourcebansCallback): %s", error);
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
	if (hndl == INVALID_HANDLE)
	{
		LogError("[surftimer] SQL Error (SQL_checkCustomPlayerTitleCallback): %s", error);
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	char szSteamID[32];
	char arg[128];
	ReadPackString(pack, szSteamID, 32);
	ReadPackString(pack, arg, 128);
	CloseHandle(pack);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		db_updateCustomPlayerTitle(client, szSteamID, arg);
	}
	else
	{
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
	if (hndl == INVALID_HANDLE)
	{
		LogError("[surftimer] SQL Error (SQL_checkCustomPlayerTitleCallback): %s", error);
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	char szSteamID[32];
	char arg[128];
	ReadPackString(pack, szSteamID, 32);
	ReadPackString(pack, arg, 128);
	CloseHandle(pack);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		db_updateCustomPlayerNameColour(client, szSteamID, arg);
	}
	else
	{
		CPrintToChat(client, "%t", "SQLTwo2", g_szChatPrefix);
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
	if (hndl == INVALID_HANDLE)
	{
		LogError("[surftimer] SQL Error (SQL_checkCustomPlayerTextColourCallback): %s", error);
	}

	ResetPack(pack);
	int client = ReadPackCell(pack);
	char szSteamID[32];
	char arg[128];
	ReadPackString(pack, szSteamID, 32);
	ReadPackString(pack, arg, 128);
	CloseHandle(pack);

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		db_updateCustomPlayerTextColour(client, szSteamID, arg);
	}
	else
	{
		CPrintToChat(client, "%t", "SQLTwo3", g_szChatPrefix);
	}
}


public void db_insertCustomPlayerTitle(int client, char[] szSteamID, char[] arg)
{
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, szSteamID);

	char szQuery[512];
	Format(szQuery, 512, "INSERT INTO `ck_vipadmins` (steamid, title, inuse) VALUES ('%s', '%s', 1);", szSteamID, arg);
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
		SQL_FetchString(hndl, 0, g_szCustomTitleColoured[client], sizeof(g_szCustomTitleColoured));

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
		LogToFileEx(g_szLogFile, "[Surftimer] %s: Finished db_viewCustomTitles in %fs", g_szSteamID[client], tick);

		g_fTick[client][0] = GetGameTime();
		LoadClientSetting(client, g_iSettingToLoad[client]);

		// Check Enforced Tags
		if (GetConVarBool(g_hEnforceDefaultTitles))
			LoadDefaultTitle(client);
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
	if (hndl == null)
	{
		LogError("[surftimer] SQL Error (SQL_ViewPlayerColoursCallback): %s", error);
		return;
	}

	ResetPack(data);
	int client = ReadPackCell(data);
	int type = ReadPackCell(data); // 0 = name colour, 1 = text colour
	CloseHandle(data);

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

		switch (item)
		{
			case 0:db_updateColours(client, g_szSteamID[client], 0, type);
			case 1:db_updateColours(client, g_szSteamID[client], 1, type);
			case 2:db_updateColours(client, g_szSteamID[client], 2, type);
			case 3:db_updateColours(client, g_szSteamID[client], 3, type);
			case 4:db_updateColours(client, g_szSteamID[client], 4, type);
			case 5:db_updateColours(client, g_szSteamID[client], 5, type);
			case 6:db_updateColours(client, g_szSteamID[client], 6, type);
			case 7:db_updateColours(client, g_szSteamID[client], 7, type);
			case 8:db_updateColours(client, g_szSteamID[client], 8, type);
			case 9:db_updateColours(client, g_szSteamID[client], 9, type);
			case 10:db_updateColours(client, g_szSteamID[client], 10, type);
			case 11:db_updateColours(client, g_szSteamID[client], 11, type);
			case 12:db_updateColours(client, g_szSteamID[client], 12, type);
			case 13:db_updateColours(client, g_szSteamID[client], 13, type);
			case 14:db_updateColours(client, g_szSteamID[client], 14, type);
			case 15:db_updateColours(client, g_szSteamID[client], 15, type);
		}
	}
	else
	if (action == MenuAction_Cancel)
	{
		CustomTitleMenu(client);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
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
	Format(szQuery, 1024, "SELECT id FROM ck_announcements WHERE server != '%s' AND id > %d", g_sServerName, g_iLastID);
	SQL_TQuery(g_hDb, SQL_SelectAnnouncementsCallback, szQuery, 1, DBPrio_Low);
}

public void SQL_SelectAnnouncementsCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[surftimer] SQL Error (SQL_SelectAnnouncementsCallback): %s", error);

		if (!g_bServerDataLoaded)
			loadAllClientSettings();
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
	{
		g_fServerLoading[1] = GetGameTime();
		g_bHasLatestID = true;
		float time = g_fServerLoading[1] - g_fServerLoading[0];
		LogToFileEx(g_szLogFile, "[Surftimer] Finished loading server settings in %fs", time);
		loadAllClientSettings();
	} 
}

public void db_insertAnnouncement(char szName[32], char szMapName[128], char szTime[32])
{
	if (g_iServerID == -1)
		return;

	char szQuery[512];
	Format(szQuery, 512, "INSERT INTO ck_announcements (server, name, mapname, time) VALUES ('%s', '%s', '%s', '%s');", g_sServerName, szName, szMapName, szTime);
	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, 1, DBPrio_Low);
}

public void db_checkAnnouncements()
{
	char szQuery[512];
	Format(szQuery, 512, "SELECT id, server, name, mapname, time FROM ck_announcements WHERE server != '%s' AND id > %d;", g_sServerName, g_iLastID);
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
			char szServerName[256], szName[32], szMapName[128], szTime[32];
			SQL_FetchString(hndl, 1, szServerName, sizeof(szServerName));
			SQL_FetchString(hndl, 2, szName, sizeof(szName));
			SQL_FetchString(hndl, 3, szMapName, sizeof(szMapName));
			SQL_FetchString(hndl, 4, szTime, sizeof(szTime));

			if (id > g_iLastID)
			{
				// Send Server Announcement
				g_iLastID = id;
				CPrintToChatAll("%t", "SQLTwo4.1");
				CPrintToChatAll("%t", "SQLTwo4.2", g_szChatPrefix, szName, szMapName, szServerName, szTime);
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
			if (tier > 6)
				tier = 6;
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
		Format(szQuery, sizeof(szQuery), "SELECT cp1, cp2, cp3, cp4, cp5, cp6, cp7, cp8, cp9, cp10, cp11, cp12, cp13, cp14, cp15, cp16, cp17, cp18, cp19, cp20, cp21, cp22, cp23, cp24, cp25, cp26, cp27, cp28, cp29, cp30, cp31, cp32, cp33, cp34, cp35 FROM ck_checkpoints WHERE steamid = '%s' AND mapname LIKE '%c%s%c' AND zonegroup = 0;", g_szSteamID[client], PERCENT, g_szCPRMapName[client], PERCENT);
		CPrintToChat(client, "%s", g_szCPRMapName[client]);
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

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		ResetPack(pack);
		int client = ReadPackCell(pack);

		for (int i = 1; i < 36; i++)
		{
			g_fClientCPs[client][i] = SQL_FetchFloat(hndl, i - 1);
		}
		db_selectCPRTarget(pack);
	}
	else
	{
		ResetPack(pack);
		int client = ReadPackCell(pack);
		CPrintToChat(client, "2", LIMEGREEN, WHITE);
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
	else
	{
		ResetPack(pack);
		int client = ReadPackCell(pack);
		CPrintToChat(client, "3", LIMEGREEN, WHITE);
	}
}

public void db_selectCPRTargetCPs(const char[] szSteamId, any pack)
{
	ResetPack(pack);
	int client = ReadPackCell(pack);

	char szQuery[512];
	Format(szQuery, sizeof(szQuery), "SELECT cp1, cp2, cp3, cp4, cp5, cp6, cp7, cp8, cp9, cp10, cp11, cp12, cp13, cp14, cp15, cp16, cp17, cp18, cp19, cp20, cp21, cp22, cp23, cp24, cp25, cp26, cp27, cp28, cp29, cp30, cp31, cp32, cp33, cp34, cp35 FROM ck_checkpoints WHERE steamid = '%s' AND mapname LIKE '%c%s%c' AND zonegroup = 0;", szSteamId, PERCENT, g_szCPRMapName[client], PERCENT);
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

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
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

		for (int i = 1; i < 36; i++)
		{
			targetCPs = SQL_FetchFloat(hndl, i - 1);
			comparedCPs = (g_fClientCPs[client][i] - targetCPs);

			if (targetCPs == 0.0 || g_fClientCPs[client][i] == 0.0)
				continue;
			FormatTimeFloat(client, targetCPs, 3, szCPR, sizeof(szCPR));
			FormatTimeFloat(client, comparedCPs, 6, szCompared, sizeof(szCompared));
			Format(szItem, sizeof(szItem), "CP %i: %s (%s)", i, szCPR, szCompared);
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
	else
	{
		ResetPack(pack);
		int client = ReadPackCell(pack);
		CPrintToChat(client, "4", LIMEGREEN, WHITE);
	}
	CloseHandle(pack);
}

public int CPRMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
		CloseHandle(menu);
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

	SQL_TQuery(g_hDb, SQL_CheckCallback, szQuery, DBPrio_Low);
}
