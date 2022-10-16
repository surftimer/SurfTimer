public void setMapSettings()
{
	SetConVarFloat(g_hMaxVelocity, g_fMaxVelocity, true, true);
	SetConVarBool(g_hGravityFix, g_bGravityFix, true, true);
}

public Action Admin_MapSettings(int client, int args)
{
	if (!IsPlayerZoner(client))
		return Plugin_Handled;

	MapSettingsMenu(client);
	return Plugin_Handled;
}

public void MapSettingsMenu(int client)
{
	Menu menu = CreateMenu(MapSettingsMenuHandler);
	char szBuffer[256];
	Format(szBuffer, sizeof(szBuffer), "Map Settings - %s\n \n", g_szMapName);
	SetMenuTitle(menu, szBuffer);

	Format(szBuffer, sizeof(szBuffer), "Tier: %d", g_iMapTier);
	AddMenuItem(menu, "", szBuffer);

	if (g_bRankedMap)
		AddMenuItem(menu, "", "Ranked");
	else
		AddMenuItem(menu, "", "Unranked");

	Format(szBuffer, sizeof(szBuffer), "Max Velocity: %f", GetConVarFloat(g_hMaxVelocity));
	AddMenuItem(menu, "", szBuffer);

	if (g_fAnnounceRecord == 1)
		AddMenuItem(menu, "", "Announce Finishes: PBs Only");
	else if (g_fAnnounceRecord == 2)
		AddMenuItem(menu, "", "Announce Finishes: WRs Only");
	else
		AddMenuItem(menu, "", "Announce Finishes: All");

	if (g_bGravityFix)
		AddMenuItem(menu, "", "Gravity Fix Enabled");
	else
		AddMenuItem(menu, "", "Gravity Fix Disabled");

	if (g_bhasStages)
		AddMenuItem(menu, "", "Unlimit prespeed for all stage zones");
	else
		AddMenuItem(menu, "", "Unlimit prespeed for all stage zones", ITEMDRAW_DISABLED);
		
	AddMenuItem(menu, "", "Remove onejumplimit for all zones");

	SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int MapSettingsMenuHandler(Handle menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0:
			{
				// Change Map Tier
				ChangeMapTier(param1);
			}
			case 1:
			{
				// Ranked/Unranked
				db_updateMapRankedStatus();
				MapSettingsMenu(param1);
			}
			case 2:
			{
				// Max Velocity
				MaxVelocityMenu(param1);
			}
			case 3:
			{
				if (g_fAnnounceRecord < 2)
					g_fAnnounceRecord++;
				else
					g_fAnnounceRecord = 0.0;
				db_updateMapSettings();
				MapSettingsMenu(param1);
			}
			case 4:
			{
				g_bGravityFix = !g_bGravityFix;
				db_updateMapSettings();
				MapSettingsMenu(param1);
			}
			case 5:
			{
				db_unlimitAllStages(g_szMapName);
			}
			case 6:
			{
				db_removeOnejumplimit(g_szMapName);
			}
		}
	}
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

public void ChangeMapTier(int client)
{
	Menu menu = CreateMenu(ChangeMapTierHandler);
	char szTitle[256];
	Format(szTitle, sizeof(szTitle), "%s - Tier: %d", g_szMapName, g_iMapTier);
	SetMenuTitle(menu, szTitle);

	for (int i = 1; i < 9; i++)
	{
		char szMenuItem[32];
		Format(szMenuItem, sizeof(szMenuItem), "Tier: %d", i);
		if (i == g_iMapTier)
			AddMenuItem(menu, "", szMenuItem, ITEMDRAW_DISABLED);
		else
			AddMenuItem(menu, "", szMenuItem);
	}

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int ChangeMapTierHandler(Handle menu, MenuAction action, int client, int tier)
{
	if (action == MenuAction_Select)
	{
		tier += 1;
		g_iMapTier = tier;
		db_insertMapTier(tier);
		MapSettingsMenu(client);
	}
	else if (action == MenuAction_Cancel)
		MapSettingsMenu(client);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

public void MaxVelocityMenu(int client)
{
	Menu menu = CreateMenu(MaxVelocityMenuHandler);
	char szTitle[128];
	Format(szTitle, sizeof(szTitle), "Max Velocity: %f", g_fMaxVelocity);
	SetMenuTitle(menu, szTitle);

	AddMenuItem(menu, "3500.0", "3500.0");
	AddMenuItem(menu, "4000.0", "4000.0");
	AddMenuItem(menu, "5000.0", "5000.0");
	AddMenuItem(menu, "10000.0", "10000.0");
	AddMenuItem(menu, "-1.0", "Custom Max Velocity");

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int MaxVelocityMenuHandler(Handle tMenu, MenuAction action, int client, int item)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char szMaxvelocity[32];
			GetMenuItem(tMenu, item, szMaxvelocity, sizeof(szMaxvelocity));
			float maxvelocity = StringToFloat(szMaxvelocity);
			if (maxvelocity == -1.0)
			{
				CPrintToChat(client, "%t", "MSettings1", g_szChatPrefix);
				g_iWaitingForResponse[client] = MaxVelocity;
				return 0;
			}
			else
				g_fMaxVelocity = maxvelocity;
			db_updateMapSettings();
			MaxVelocityMenu(client);
		}
		case MenuAction_Cancel:
		{
			MapSettingsMenu(client);
		}
		case MenuAction_End:
		{
			delete tMenu;
		}
	}

	return 0;
}

public Action Command_SetMaxVelocity(int client, int args)
{
	if (!IsValidClient(client))
	return Plugin_Handled;

	if (!IsPlayerZoner(client))
		return Plugin_Handled;

	char arg[128];
	if (args == 0)
	{
		CPrintToChat(client, "%t", "MSettings2", g_szChatPrefix, g_fMaxVelocity);
		return Plugin_Handled;
	}

	GetCmdArg(1, arg, 128);
	float maxvelocity = StringToFloat(arg);
	g_fMaxVelocity = maxvelocity;
	db_updateMapSettings();
	CPrintToChatAll("%t", "MSettings3", arg);

	return Plugin_Handled;
}

public Action Command_SetAnnounceRecord(int client, int args)
{
	if (!IsValidClient(client))
	return Plugin_Handled;

	if (!IsPlayerZoner(client))
		return Plugin_Handled;

	char arg[128];
	if (args == 0)
	{
		CPrintToChat(client, "%t", "MSettings4", g_szChatPrefix, g_fAnnounceRecord);
		return Plugin_Handled;
	}

	GetCmdArg(1, arg, 128);
	float setting = StringToFloat(arg);
	g_fAnnounceRecord = setting;
	db_updateMapSettings();

	return Plugin_Handled;
}

public Action Command_SetGravityFix(int client, int args)
{
	if (!IsValidClient(client))
		return Plugin_Handled;

	if (!IsPlayerZoner(client))
		return Plugin_Handled;

	if (args == 0)
	{
		if (g_bGravityFix)
			CReplyToCommand(client, "%t", "MSettings6", g_szChatPrefix);
		else
			CReplyToCommand(client, "%t", "MSettings7", g_szChatPrefix);

		return Plugin_Handled;
	}

	char arg[128];
	GetCmdArg(1, arg, 128);
	int enable = StringToInt(arg);
	g_bGravityFix = view_as<bool>(enable);
	db_updateMapSettings();

	return Plugin_Handled;
}

public void db_viewMapSettings()
{
	char szQuery[2048];
	Format(szQuery, 2048, "SELECT `mapname`, `maxvelocity`, `announcerecord`, `gravityfix` FROM `ck_maptier` WHERE `mapname` = '%s'", g_szMapName);
	SQL_TQuery(g_hDb, sql_viewMapSettingsCallback, szQuery, GetGameTime(), DBPrio_High);
}

public void sql_viewMapSettingsCallback(Handle owner, Handle hndl, const char[] error, float time)
{
	LogQueryTime("[SurfTimer] : Finished sql_viewMapSettingsCallback in: %f", GetGameTime() - time);
	
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (sql_viewMapSettingsCallback): %s", error);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_GetRowCount(hndl) > 0)
	{
		while (SQL_FetchRow(hndl))
		{
			g_fMaxVelocity = SQL_FetchFloat(hndl, 1);
			g_fAnnounceRecord = SQL_FetchFloat(hndl, 2);
			g_bGravityFix = view_as<bool>(SQL_FetchInt(hndl, 3));
		}
		setMapSettings();
	}
}

public void sql_insertMapSettingsCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (sql_insertMapSettingsCallback): %s", error);
		return;
	}

	db_viewMapSettings();
}

public void db_updateMapSettings()
{
	char szQuery[512];
	Format(szQuery, 512, "UPDATE `ck_maptier` SET `maxvelocity` = '%f', `announcerecord` = '%f', `gravityfix` = %i WHERE `mapname` = '%s';", g_fMaxVelocity, g_fAnnounceRecord, view_as<int>(g_bGravityFix), g_szMapName);
	SQL_TQuery(g_hDb, sql_insertMapSettingsCallback, szQuery, _, DBPrio_Low);
}

public void db_unlimitAllStages(char[] szMapName)
{
	char szQuery[256];
	Format(szQuery, 256, "UPDATE ck_zones SET prespeed = 0.0 WHERE mapname = '%s' AND zonetype = 3;", g_szMapName);
	SQL_TQuery(g_hDb, SQL_UnlimitAllStagesCallback, szQuery, _, DBPrio_Low);
}

public void db_removeOnejumplimit(char[] szMapName)
{
	char szQuery[256];
	Format(szQuery, 256, "UPDATE ck_zones SET onejumplimit = 0 WHERE mapname = '%s';", g_szMapName);
	SQL_TQuery(g_hDb, SQL_removeOnejumplimitCallback, szQuery, _, DBPrio_Low);
}

public void SQL_UnlimitAllStagesCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (SQL_UnlimitAllStagesCallback): %s", error);
		return;
	}

	db_selectMapZones();
}

public void SQL_removeOnejumplimitCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (SQL_removeOnejumplimitCallback): %s", error);
		return;
	}

	db_selectMapZones();
}
