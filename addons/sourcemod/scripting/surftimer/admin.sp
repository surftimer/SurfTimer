public void Admin_renameZone(int client, const char[] name)
{
	if (!IsValidClient(client))
	{
		g_ClientRenamingZone[client] = false;
		return;
	}

	if (!name[0] || StrEqual(name, " ") || StrEqual(name, ""))
	{
		CPrintToChat(client, "%t", "Admin1", g_szChatPrefix);
		return;
	}
	if (strlen(name) > 128)
	{
		CPrintToChat(client, "%t", "Admin2", g_szChatPrefix);
		return;
	}
	if (StrEqual(name, "!cancel", false)) // false -> non sensitive
	{
		CPrintToChat(client, "%t", "Admin3", g_szChatPrefix);
		g_ClientRenamingZone[client] = false;
		ListBonusSettings(client);
		return;
	}
	char szZoneName[128];

	Format(szZoneName, 128, "%s", name);
	db_setZoneNames(client, szZoneName);
	g_ClientRenamingZone[client] = false;
}

public void OnAdminMenuReady(Handle topmenu)
{
	if (topmenu == g_hAdminMenu)
		return;

	g_hAdminMenu = topmenu;
	TopMenuObject serverCmds = FindTopMenuCategory(g_hAdminMenu, ADMINMENU_SERVERCOMMANDS);
	AddToTopMenu(g_hAdminMenu, "sm_ckadmin", TopMenuObject_Item, TopMenuHandler2, serverCmds, "sm_ckadmin", ADMFLAG_RCON);
}

public int TopMenuHandler2(Handle topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
		Format(buffer, maxlength, "SurfTimer");

	else if (action == TopMenuAction_SelectOption)
		Admin_ckPanel(param, 0);

	return 0;
}

public Action Admin_insertMapperName(int client, int args)
{
	if (!IsValidClient(client))
		return Plugin_Handled;

	if (!IsPlayerZoner(client))
	{
		CReplyToCommand(client, "%t", "AdminMapperName", g_szChatPrefix);
		return Plugin_Handled;
	}

	if (args == 0)
	{
		CReplyToCommand(client, "%t", "MapperNameUsage", g_szChatPrefix);
		return Plugin_Handled;
	}
	else
	{
		char arg1[64];
		//char sMapperName[64];
		GetCmdArgString(arg1, sizeof(arg1));

		db_insertMapperName(client, arg1);
	}
	return Plugin_Handled;
}

public Action Admin_insertMapTier(int client, int args)
{
	if (!IsValidClient(client))
		return Plugin_Handled;

	if (!IsPlayerZoner(client))
	{
		CPrintToChat(client, "%t", "NoZoneAccess", g_szChatPrefix);
		return Plugin_Handled;
	}

	if (args == 0)
	{
		CReplyToCommand(client, "%t", "Admin5", g_szChatPrefix);
		return Plugin_Handled;
	}
	else
	{
		char arg1[3];
		int tier;
		GetCmdArg(1, arg1, sizeof(arg1));
		tier = StringToInt(arg1);
		if (tier < 9 && tier > -1)
			db_insertMapTier(tier);
		else
			CPrintToChat(client, "%t", "Admin6", g_szChatPrefix);
	}
	return Plugin_Handled;
}

public Action Admin_insertSpawnLocation(int client, int args)
{
	if (!IsValidClient(client) || !IsPlayerZoner(client))
		return Plugin_Handled;

	Menu menu = CreateMenu(ChooseTeleSideHandler);
	SetMenuTitle(menu, "Choose side for this spawn location");
	AddMenuItem(menu, "", "Left");
	AddMenuItem(menu, "", "Right");
	SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);

	return Plugin_Handled;
}

public int ChooseTeleSideHandler(Handle menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
		InsertSpawnLocation(param1, param2);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

public void InsertSpawnLocation(int client, int teleside)
{
	float SpawnLocation[3];
	float SpawnAngle[3];
	float Velocity[3];

	GetClientAbsOrigin(client, SpawnLocation);
	GetClientEyeAngles(client, SpawnAngle);
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", Velocity);

	SpawnLocation[2] += 3.0;

	if (g_bGotSpawnLocation[g_iClientInZone[client][2]][1][teleside])
	{
		db_updateSpawnLocations(SpawnLocation, SpawnAngle, Velocity, g_iClientInZone[client][2], teleside);
		CPrintToChat(client, "%t", "Admin7", g_szChatPrefix);
	}
	else
	{
		db_insertSpawnLocations(SpawnLocation, SpawnAngle, Velocity, g_iClientInZone[client][2], teleside);
		CPrintToChat(client, "%t", "SpawnAdded", g_szChatPrefix);
	}
	
	CPrintToChat(client, "%f : %f : %f : %i", SpawnLocation, SpawnAngle, Velocity, g_iClientInZone[client][2]);
}

public Action Admin_deleteSpawnLocation(int client, int args)
{
	if (!IsValidClient(client) || !IsPlayerZoner(client))
		return Plugin_Handled;

	if (g_bGotSpawnLocation[g_iClientInZone[client][2]][1][0] || g_bGotSpawnLocation[g_iClientInZone[client][2]][1][1])
	{
		Menu menu = CreateMenu(DelSpawnLocationHandler);
		SetMenuTitle(menu, "Choose side of spawn location to delete");

		if (g_bGotSpawnLocation[g_iClientInZone[client][2]][1][0])
			AddMenuItem(menu, "", "Left");
		else
			AddMenuItem(menu, "", "Left", ITEMDRAW_DISABLED);
		
		if (g_bGotSpawnLocation[g_iClientInZone[client][2]][1][1])
			AddMenuItem(menu, "", "Right");
		else
			AddMenuItem(menu, "", "Right", ITEMDRAW_DISABLED);

		SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
		DisplayMenu(menu, client, MENU_TIME_FOREVER);
	}
	else
		CPrintToChat(client, "%t", "Admin9", g_szChatPrefix);

	return Plugin_Handled;
}

public int DelSpawnLocationHandler(Handle menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
		DelSpawnLocation(param1, param2);
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

public void DelSpawnLocation(int client, int teleside)
{
	if (g_bGotSpawnLocation[g_iClientInZone[client][2]][1][teleside])
	{
		db_deleteSpawnLocations(g_iClientInZone[client][2], teleside);
		CPrintToChat(client, "%t", "Admin8", g_szChatPrefix);
	}
	else
		CPrintToChat(client, "%t", "Admin9", g_szChatPrefix);
}

public Action Admin_ClearAssists(int client, int args)
{
	if (IsPlayerTimerAdmin(client))
		return Plugin_Handled;

	for (int i = 1; i <= MAXPLAYERS; i++)
	{
		if (IsValidClient(i))
		{
			CS_SetClientAssists(i, 0);
			g_fMaxPercCompleted[0] = 0.0;
			CS_SetMVPCount(i, 0);
		}
	}

	return Plugin_Handled;
}

public Action Admin_ckPanel(int client, int args)
{
	ckAdminMenu(client);
	return Plugin_Handled;
}

public void ckAdminMenu(int client)
{
	if (!IsValidClient(client))
		return;

	if (IsPlayerTimerAdmin(client))
	{
		char szTmp[128];

		Handle adminmenu = CreateMenu(AdminPanelHandler);
		if (IsPlayerZoner(client))
			Format(szTmp, sizeof(szTmp), "SurfTimer %s Admin Menu (full access)", VERSION);
		else
			Format(szTmp, sizeof(szTmp), "SurfTimer %s Admin Menu (limited access)", VERSION);
		SetMenuTitle(adminmenu, szTmp);

		if (!g_pr_RankingRecalc_InProgress)
			AddMenuItem(adminmenu, "[1.] Recalculate player ranks", "[1.] Recalculate player ranks");
		else
			AddMenuItem(adminmenu, "[1.] Recalculate player ranks", "[1.] Stop the recalculation");

		AddMenuItem(adminmenu, "", "", ITEMDRAW_SPACER);

		int menuItemNumber = 2;

		if (IsPlayerZoner(client))
		{
			Format(szTmp, sizeof(szTmp), "[%i.] Edit or create zones", menuItemNumber);
			AddMenuItem(adminmenu, szTmp, szTmp);
		}
		else
		{
			Format(szTmp, sizeof(szTmp), "[%i.] Edit or create zones", menuItemNumber);
			AddMenuItem(adminmenu, szTmp, szTmp, ITEMDRAW_DISABLED);
		}
		menuItemNumber++;

		if (GetConVarBool(g_hCvarGodMode))
			Format(szTmp, sizeof(szTmp), "[%i.] Godmode  -  Enabled", menuItemNumber);
		else
			Format(szTmp, sizeof(szTmp), "[%i.] Godmode  -  Disabled", menuItemNumber);
		AddMenuItem(adminmenu, szTmp, szTmp);
		menuItemNumber++;

		if (GetConVarBool(g_hCvarNoBlock))
			Format(szTmp, sizeof(szTmp), "[%i.] Noblock  -  Enabled", menuItemNumber);
		else
			Format(szTmp, sizeof(szTmp), "[%i.] Noblock  -  Disabled", menuItemNumber);
		AddMenuItem(adminmenu, szTmp, szTmp);
		menuItemNumber++;

		if (GetConVarBool(g_hAutoRespawn))
			Format(szTmp, sizeof(szTmp), "[%i.] Autorespawn  -  Enabled", menuItemNumber);
		else
			Format(szTmp, sizeof(szTmp), "[%i.] Autorespawn  -  Disabled", menuItemNumber);
		AddMenuItem(adminmenu, szTmp, szTmp);
		menuItemNumber++;

		if (GetConVarBool(g_hCleanWeapons))
			Format(szTmp, sizeof(szTmp), "[%i.] Strip weapons  -  Enabled", menuItemNumber);
		else
			Format(szTmp, sizeof(szTmp), "[%i.] Strip weapons  -  Disabled", menuItemNumber);
		AddMenuItem(adminmenu, szTmp, szTmp);
		menuItemNumber++;

		if (GetConVarBool(g_hcvarRestore))
			Format(szTmp, sizeof(szTmp), "[%i.] Restore function  -  Enabled", menuItemNumber);
		else
			Format(szTmp, sizeof(szTmp), "[%i.] Restore function  -  Disabled", menuItemNumber);
		AddMenuItem(adminmenu, szTmp, szTmp);
		menuItemNumber++;

		if (GetConVarBool(g_hPauseServerside))
			Format(szTmp, sizeof(szTmp), "[%i.] !pause command -  Enabled", menuItemNumber);
		else
			Format(szTmp, sizeof(szTmp), "[%i.] !pause command  -  Disabled", menuItemNumber);
		AddMenuItem(adminmenu, szTmp, szTmp);
		menuItemNumber++;

		if (GetConVarBool(g_hGoToServer))
			Format(szTmp, sizeof(szTmp), "[%i.] !goto command  -  Enabled", menuItemNumber);
		else
			Format(szTmp, sizeof(szTmp), "[%i.] !goto command  -  Disabled", menuItemNumber);
		AddMenuItem(adminmenu, szTmp, szTmp);
		menuItemNumber++;

		if (GetConVarBool(g_hRadioCommands))
			Format(szTmp, sizeof(szTmp), "[%i.] Radio commands  -  Enabled", menuItemNumber);
		else
			Format(szTmp, sizeof(szTmp), "[%i.] Radio commands  -  Disabled", menuItemNumber);
		AddMenuItem(adminmenu, szTmp, szTmp);
		menuItemNumber++;

		if (GetConVarBool(g_hReplayBot))
			Format(szTmp, sizeof(szTmp), "[%i.] Replay bot  -  Enabled", menuItemNumber);
		else
			Format(szTmp, sizeof(szTmp), "[%i.] Replay bot  -  Disabled", menuItemNumber);
		AddMenuItem(adminmenu, szTmp, szTmp);
		menuItemNumber++;

		if (GetConVarBool(g_hPointSystem))
			Format(szTmp, sizeof(szTmp), "[%i.] Player point system  -  Enabled", menuItemNumber);
		else
			Format(szTmp, sizeof(szTmp), "[%i.] Player point system  -  Disabled", menuItemNumber);
		AddMenuItem(adminmenu, szTmp, szTmp);
		menuItemNumber++;

		if (GetConVarBool(g_hCountry))
			Format(szTmp, sizeof(szTmp), "[%i.] Player country tag  -  Enabled", menuItemNumber);
		else
			Format(szTmp, sizeof(szTmp), "[%i.] Player country tag  -  Disabled", menuItemNumber);
		AddMenuItem(adminmenu, szTmp, szTmp);
		menuItemNumber++;

		if (GetConVarBool(g_hPlayerSkinChange))
			Format(szTmp, sizeof(szTmp), "[%i.] Allow custom models  -  Enabled", menuItemNumber);
		else
			Format(szTmp, sizeof(szTmp), "[%i.] Allow custom models  -  Disabled", menuItemNumber);
		AddMenuItem(adminmenu, szTmp, szTmp);
		menuItemNumber++;

		if (GetConVarBool(g_hNoClipS))
			Format(szTmp, sizeof(szTmp), "[%i.] +noclip  -  Enabled", menuItemNumber);
		else
			Format(szTmp, sizeof(szTmp), "[%i.] +noclip (admin/vip excluded)  -  Disabled", menuItemNumber);
		AddMenuItem(adminmenu, szTmp, szTmp);
		menuItemNumber++;

		if (GetConVarBool(g_hAutoBhopConVar))
			Format(szTmp, sizeof(szTmp), "[%i.] Auto bunnyhop (only surf_/bhop_ maps)  -  Enabled", menuItemNumber);
		else
			Format(szTmp, sizeof(szTmp), "[%i.] Auto bunnyhop  -  Disabled", menuItemNumber);
		AddMenuItem(adminmenu, szTmp, szTmp);
		menuItemNumber++;

		if (GetConVarBool(g_hMapEnd))
			Format(szTmp, sizeof(szTmp), "[%i.] Allow map changes  -  Enabled", menuItemNumber);
		else
			Format(szTmp, sizeof(szTmp), "[i.] Allow map changes  -  Disabled", menuItemNumber);
		AddMenuItem(adminmenu, szTmp, szTmp);
		menuItemNumber++;

		if (GetConVarBool(g_hConnectMsg))
			Format(szTmp, sizeof(szTmp), "[%i.] Connect message  -  Enabled", menuItemNumber);
		else
			Format(szTmp, sizeof(szTmp), "[%i.] Connect message  -  Disabled", menuItemNumber);
		AddMenuItem(adminmenu, szTmp, szTmp);
		menuItemNumber++;

		if (GetConVarBool(g_hDisconnectMsg))
			Format(szTmp, sizeof(szTmp), "[%i.] Disconnect message - Enabled", menuItemNumber);
		else
			Format(szTmp, sizeof(szTmp), "[%i.] Disconnect message - Disabled", menuItemNumber);
		AddMenuItem(adminmenu, szTmp, szTmp);
		menuItemNumber++;

		if (GetConVarBool(g_hInfoBot))
			Format(szTmp, sizeof(szTmp), "[%i.] Info bot  -  Enabled", menuItemNumber);
		else
			Format(szTmp, sizeof(szTmp), "[%i.] Info bot  -  Disabled", menuItemNumber);
		AddMenuItem(adminmenu, szTmp, szTmp);
		menuItemNumber++;

		if (GetConVarBool(g_hAttackSpamProtection))
			Format(szTmp, sizeof(szTmp), "[%i.] Attack spam protection  -  Enabled", menuItemNumber);
		else
			Format(szTmp, sizeof(szTmp), "[%i.] Attack spam protection  -  Disabled", menuItemNumber);
		AddMenuItem(adminmenu, szTmp, szTmp);
		menuItemNumber++;

		if (GetConVarBool(g_hAllowRoundEndCvar))
			Format(szTmp, sizeof(szTmp), "[%i.] Allow to end the current round  -  Enabled", menuItemNumber);
		else
			Format(szTmp, sizeof(szTmp), "[%i.] Allow to end the current round  -  Disabled", menuItemNumber);
		AddMenuItem(adminmenu, szTmp, szTmp);
		menuItemNumber++;

		SetMenuExitButton(adminmenu, true);
		SetMenuOptionFlags(adminmenu, MENUFLAG_BUTTON_EXIT);
		if (g_AdminMenuLastPage[client] < 6)
			DisplayMenuAtItem(adminmenu, client, 0, MENU_TIME_FOREVER);
		else
			if (g_AdminMenuLastPage[client] < 12)
				DisplayMenuAtItem(adminmenu, client, 6, MENU_TIME_FOREVER);
			else
				if (g_AdminMenuLastPage[client] < 18)
					DisplayMenuAtItem(adminmenu, client, 12, MENU_TIME_FOREVER);
				else
					if (g_AdminMenuLastPage[client] < 24)
						DisplayMenuAtItem(adminmenu, client, 18, MENU_TIME_FOREVER);
					else
						if (g_AdminMenuLastPage[client] < 30)
							DisplayMenuAtItem(adminmenu, client, 24, MENU_TIME_FOREVER);
						else
							if (g_AdminMenuLastPage[client] < 36)
								DisplayMenuAtItem(adminmenu, client, 30, MENU_TIME_FOREVER);
							else
								if (g_AdminMenuLastPage[client] < 42)
									DisplayMenuAtItem(adminmenu, client, 36, MENU_TIME_FOREVER);
	}
	else
	{
		CPrintToChat(client, "%t", "Admin11", g_szChatPrefix);
		return;
	}
}

public int AdminPanelHandler(Handle menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		bool refresh = true;
		switch (param2)
		{
			case 0:
			{
				if (!g_pr_RankingRecalc_InProgress)
				{
					CPrintToChat(param1, "%t", "PrUpdateStarted", g_szChatPrefix);
					g_bManualRecalc = true;
					g_pr_Recalc_AdminID = param1;
					RefreshPlayerRankTable(MAX_PR_PLAYERS);
				}
				else
				{
					for (int i = 66; i < MAX_PR_PLAYERS; i++)
						g_bProfileRecalc[i] = false;
					g_bManualRecalc = false;
					g_pr_RankingRecalc_InProgress = false;
					CPrintToChat(param1, "%t", "StopRecalculation", g_szChatPrefix);
				}
			}

			case 2:
			{
				ZoneMenu(param1);
				refresh = false;
			}

			case 3:
			{
				if (!GetConVarBool(g_hCvarGodMode))
					ServerCommand("ck_godmode 1");
				else
					ServerCommand("ck_godmode 0");
			}

			case 4:
			{
				if (!GetConVarBool(g_hCvarNoBlock))
					ServerCommand("ck_noblock 1");
				else
					ServerCommand("ck_noblock 0");
			}

			case 5:
			{
				if (!GetConVarBool(g_hAutoRespawn))
					ServerCommand("ck_autorespawn 1");
				else
					ServerCommand("ck_autorespawn 0");
			}

			case 6:
			{
				if (!GetConVarBool(g_hCleanWeapons))
					ServerCommand("ck_clean_weapons 1");
				else
					ServerCommand("ck_clean_weapons 0");
			}

			case 7:
			{
				if (!GetConVarBool(g_hcvarRestore))
					ServerCommand("ck_restore 1");
				else
					ServerCommand("ck_restore 0");
			}

			case 8:
			{
				if (!GetConVarBool(g_hPauseServerside))
					ServerCommand("ck_pause 1");
				else
					ServerCommand("ck_pause 0");
			}

			case 9:
			{
				if (!GetConVarBool(g_hGoToServer))
					ServerCommand("ck_goto 1");
				else
					ServerCommand("ck_goto 0");
			}

			case 10:
			{
				if (!GetConVarBool(g_hRadioCommands))
					ServerCommand("ck_use_radio 1");
				else
					ServerCommand("ck_use_radio 0");
			}

			case 11:
			{
				if (!GetConVarBool(g_hReplayBot))
					ServerCommand("ck_replay_bot 1");
				else
					ServerCommand("ck_replay_bot 0");
			}

			case 12:
			{
				if (!GetConVarBool(g_hPointSystem))
					ServerCommand("ck_point_system 1");
				else
					ServerCommand("ck_point_system 0");
			}

			case 13:
			{
				if (!GetConVarBool(g_hCountry))
					ServerCommand("ck_country_tag 1");
				else
					ServerCommand("ck_country_tag 0");
			}

			case 14:
			{
				if (!GetConVarBool(g_hPlayerSkinChange))
					ServerCommand("ck_custom_models 1");
				else
					ServerCommand("ck_custom_models 0");
			}

			case 15:
			{
				if (!GetConVarBool(g_hNoClipS))
					ServerCommand("ck_noclip 1");
				else
					ServerCommand("ck_noclip 0");
			}

			case 16:
			{
				if (!GetConVarBool(g_hAutoBhopConVar))
					ServerCommand("ck_auto_bhop 1");
				else
					ServerCommand("ck_auto_bhop 0");
			}

			case 17:
			{
				if (!GetConVarBool(g_hMapEnd))
					ServerCommand("ck_map_end 1");
				else
					ServerCommand("ck_map_end 0");
			}

			case 18:
			{
				if (!GetConVarBool(g_hConnectMsg))
					ServerCommand("ck_connect_msg 1");
				else
					ServerCommand("ck_connect_msg 0");
			}

			case 19:
			{
				if (!GetConVarBool(g_hDisconnectMsg))
					ServerCommand("ck_disconnect_msg 1");
				else
					ServerCommand("ck_disconnect_msg 0");
			}

			case 20:
			{
				if (!GetConVarBool(g_hInfoBot))
					ServerCommand("ck_info_bot 1");
				else
					ServerCommand("ck_info_bot 0");
			}

			case 21:
			{
				if (!GetConVarBool(g_hAttackSpamProtection))
					ServerCommand("ck_attack_spam_protection 1");
				else
					ServerCommand("ck_attack_spam_protection 0");
			}

			case 22:
			{
				if (!GetConVarBool(g_hAllowRoundEndCvar))
					ServerCommand("ck_round_end 1");
				else
					ServerCommand("ck_round_end 0");
			}
		}

		g_AdminMenuLastPage[param1] = param2;
		if (menu != null)
			CloseHandle(menu);

		if (refresh)
			CreateTimer(0.1, RefreshAdminMenu, param1, TIMER_FLAG_NO_MAPCHANGE);
	}

	if (action == MenuAction_End)
	{
		if (IsValidClient(param1))
		{
			if (menu != null)
				CloseHandle(menu);
		}
	}

	return 0;
}

public Action Admin_RefreshProfile(int client, int args)
{
	if (!IsPlayerTimerAdmin(client))
		return Plugin_Handled;

	if (args == 0)
	{
		CReplyToCommand(client, "%t", "Admin12", g_szChatPrefix);
		return Plugin_Handled;
	}
	if (args > 0)
	{
		char szSteamID[128];
		char szArg[128];
		Format(szSteamID, 128, "");
		for (int i = 1; i < 6; i++)
		{
			GetCmdArg(i, szArg, 128);
			if (!StrEqual(szArg, "", false))
				Format(szSteamID, 128, "%s%s", szSteamID, szArg);
		}
		RecalcPlayerRank(client, szSteamID);
	}
	return Plugin_Handled;
}

public Action Admin_RefreshPlayerRankTable(int client, int args)
{
	if (!IsPlayerTimerAdmin(client))
		return Plugin_Handled;

	if (args > 0)
	{
		char sArg[12];
		GetCmdArg(1, sArg, sizeof(sArg));
		if (IsStringNumeric(sArg))
		{
			RefreshPlayerRankTable(StringToInt(sArg));
			return Plugin_Handled;
		}
	}
	
	RefreshPlayerRankTable(MAX_PR_PLAYERS);
	return Plugin_Handled;
}

public Action Admin_ResetRecords(int client, int args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "%s Usage: sm_wipeplayer <steamid>", g_szChatPrefix);
		return Plugin_Handled;
	}
	else
	{
		char szArg[32];
		GetCmdArgString(szArg, sizeof(szArg));

		StripQuotes(szArg);
		TrimString(szArg);
		PrintToChat(client, "Output test: %s", szArg);
		db_WipePlayer(client, szArg);
	}
	return Plugin_Handled;
}
