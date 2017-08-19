//sm_pr command
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

	if(StrEqual(szUpper, szUpper2)) // is the mapname the current map?
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
		LogError("[SurfTimer] SQL Error (SQL_ViewMapNamePrCallback): %s ", error);
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
		PrintToChat(client, " %cSurfTimer %c| Map not found");
	}
}

public void SQL_ViewPlayerPrMapInfoCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (SQL_ViewPlayerPrMapInfoCallback): %s ", error);
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
		LogError("[SurfTimer] SQL Error (SQL_ViewPlayerPrMaptimeCallback): %s ", error);
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

	//PrintToChat(client, "total: %i , runtimepro: %f", total, time);

	WritePackFloat(pack, time);
	WritePackCell(pack, total);
	WritePackCell(pack, rank);

	char szQuery[1024];

	Format(szQuery, 1024, "SELECT steamid, name, mapname, runtimepro, stage FROM ck_wrcps WHERE mapname = '%s' AND steamid = '%s' AND runtimepro > -1.0 AND style = 0 ORDER BY `ck_wrcps`.`stage` ASC", szMapName, szSteamId);
	SQL_TQuery(g_hDb, SQL_ViewPlayerPrMaptimeCallback2, szQuery, pack, DBPrio_Low);
}

public void SQL_ViewPlayerPrMaptimeCallback2(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (SQL_ViewPlayerPrMaptimeCallback2): %s ", error);
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
	GetClientName(client, szName, sizeof(szName));
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
				Format(szStageInfo[i], 256, "Stage %i: %s\nRank: %i/%i\n \n", i, szRuntimestages[i], g_StageRank[target][i], g_TotalStageRecords[i]);
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

//
// VIP
//

// fluffys start vip & admins

public void db_CheckVIPAdmin(int client, char[] szSteamID)
{
	char szQuery[1024];
	Format(szQuery, 1024, "SELECT steamid, vip, admin, zoner FROM ck_vipadmins WHERER steamid = '%s';", szSteamID);
	SQL_TQuery(g_hDb, SQL_CheckVIPAdminCallback, szQuery, client, DBPrio_Low);
}

public void SQL_CheckVIPAdminCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	char szSteamId[32];
	getSteamIDFromClient(client, szSteamId, 32);

	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (SQL_CheckVIPAdminCallback): %s", error);

		if (!g_bSettingsLoaded[client])
		{
			db_viewCustomTitles(client, szSteamId);
		}
	}

	// Set Client Defaults
	g_iVipLvl[client] = 0;
	g_iAdminLvl[client] = 0;
	g_bZoner[client] = false;

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		g_iVipLvl[client] = SQL_FetchInt(hndl, 1);
		g_iAdminLvl[client] = SQL_FetchInt(hndl, 2);
		g_bZoner[client] = view_as<bool>(SQL_FetchInt(hndl, 3));
		if (g_bZoner[client] && g_iVipLvl[client] < 1) // zoner but no vip
			g_iVipLvl[client] = 1;
		else if (g_iAdminLvl[client] > 0) // admins
			g_iVipLvl[client] = 2;
	}

	if (!g_bSettingsLoaded[client])
	{
		db_viewCustomTitles(client, szSteamId);
	}
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
		LogError("[SurfTimer] SQL Error (SQL_checkCustomPlayerTitleCallback): %s", error);
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
		LogError("[SurfTimer] SQL Error (SQL_checkCustomPlayerTitleCallback): %s", error);
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
		PrintToChat(client, "You must set a custom title using sm_mytitle before you can set your name colour.");
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
		LogError("[SurfTimer] SQL Error (SQL_checkCustomPlayerTextColourCallback): %s", error);
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
		PrintToChat(client, "You must set a custom title using sm_mytitle before you can set your text colour.");
	}
}


public void db_insertCustomPlayerTitle(int client, char[] szSteamID, char[] arg)
{
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackString(pack, szSteamID);

	char szQuery[512];
	Format(szQuery, 512, "INSERT INTO `ck_vipadmins` VALUES ('%s', '%s', 0, '{default}', 1);", szSteamID, arg);
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
	if(g_bDbCustomTitleInUse[client])
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
	Format(szQuery, 728, "SELECT `title`, `namecolour`, `textcolour`, `inuse`, `vip`, `zoner` FROM `ck_vipadmins` WHERE `steamid` = '%s'", szSteamID);
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
		LogError("[SurfTimer] SQL Error (SQL_viewCustomTitlesCallback): %s ", error);

		if (!g_bSettingsLoaded[client])
		{
			if(g_bhasStages)
				db_viewPersonalStageRecords(client, szSteamID);
			else
				db_viewCheckpoints(client, szSteamID, g_szMapName);
		}

		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		g_bdbHasCustomTitle[client] = true;
		SQL_FetchString(hndl, 0, g_szCustomTitleColoured[client], sizeof(g_szCustomTitleColoured));

		//fluffys temp fix for scoreboard
		int RankValue[SkillGroup];
		int index = GetSkillgroupFromPoints(g_pr_points[client]);
		GetArrayArray(g_hSkillGroups, index, RankValue[0]);
		Format(g_pr_chat_coloredrank[client], 1024, "%s", g_szCustomTitleColoured[client]);

		char szTitle[1024];
		Format(szTitle, 1024, "%s", g_szCustomTitleColoured[client]);
		parseColorsFromString(szTitle, 1024);
		Format(g_pr_rankname[client], 1024, "%s", szTitle);
		Format(g_szCustomTitle[client], 1024, "%s", szTitle);

		if (SQL_FetchInt(hndl, 3) == 0)
		{
			g_bDbCustomTitleInUse[client] = false;
		}
		else
		{
			g_bDbCustomTitleInUse[client] = true;
			g_iCustomColours[client][0] = SQL_FetchInt(hndl, 1);
			//setNameColor(szName, g_szdbCustomNameColour[client], 64);

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
		if(g_bhasStages)
			db_viewPersonalStageRecords(client, szSteamID);
		else
			db_viewCheckpoints(client, szSteamID, g_szMapName);
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
    LogError("[SurfTimer] SQL Error (SQL_ViewPlayerColoursCallback): %s", error);
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
		changeColoursMenu.AddItem(szType, "Purple", ITEMDRAW_DISABLED);
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
		LogError("[SurfTimer] SQL Error (SQL_UpdatePlayerColoursCallback): %s", error);
		return;
	}

	g_bUpdatingColours[client] = true;
	db_viewCustomTitles(client, g_szSteamID[client]);
}

// fluffys end custom titles
