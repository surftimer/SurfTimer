public Action Command_Vip(int client, int args)
{
	if (g_iVipLvl[client] < 1 && g_iAdminLvl[client] < 1)
	{
		PrintToChat(client, " %cSurfTimer %c| You must be a VIP to use this feature %chttps://ztsgaming.com.au/Donate", LIMEGREEN, WHITE, YELLOW);
		return Plugin_Handled;
	}

	VipMenu(client, g_iVipLvl[client], g_iAdminLvl[client]);
	return Plugin_Handled;
}

public void VipMenu(int client, int vip, int admin)
{
	Menu menu = CreateMenu(VipMenuHandler);
	if (vip == 1) // VIP
	{
		SetMenuTitle(menu, "VIP Menu");
		AddMenuItem(menu, "models", "Player Models");
		AddMenuItem(menu, "title", "VIP Title");
		AddMenuItem(menu, "ve", "Vote Extend", ITEMDRAW_DISABLED);
		AddMenuItem(menu, "paintcolour", "Paint Colour", ITEMDRAW_DISABLED);
	}
	else if (vip > 1)
	{
		if (vip == 2)
			SetMenuTitle(menu, "SuperVIP Menu");
		else if (vip == 3)
			SetMenuTitle(menu, "BigDickClub Menu");

		AddMenuItem(menu, "models", "Player Models");
		AddMenuItem(menu, "title", "Custom Titles");
		AddMenuItem(menu, "ve", "Vote Extend");
		AddMenuItem(menu, "paintcolour", "Paint Colour");
	}
	else if (admin > 0)
	{
		SetMenuTitle(menu, "Vip Menu (Admin)");
		AddMenuItem(menu, "models", "Player Models", ITEMDRAW_DISABLED);
		AddMenuItem(menu, "title", "Admin Titles");
		AddMenuItem(menu, "ve", "Vote Extend");
		AddMenuItem(menu, "paintcolour", "Paint Colour", ITEMDRAW_DISABLED);
	}
	SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int VipMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0: FakeClientCommandEx(param1, "sm_models");
			case 1: CustomTitleMenu(param1);
			case 2: VoteExtend(param1);
			case 3: FakeClientCommandEx(param1, "sm_paintcolour");
		}
	}
	else if (action == MenuAction_End)
		CloseHandle(menu);
}

public void CustomTitleMenu(int client)
{
	char szName[64], szSteamID[32], szColour[3][96], szTitle[256], szItem[128], szItem2[128];

	GetClientName(client, szName, 64);
	getSteamIDFromClient(client, szSteamID, 32);
	getColourName(client, szColour[0], 32, g_iCustomColours[client][0]);
	getColourName(client, szColour[1], 32, g_iCustomColours[client][1]);

	Format(szTitle, 256, "Custom Titles Menu: %s\nCustom Title: %s\n \n", szName, g_szCustomTitle[client]);
	Format(szItem, 128, "Name Colour: %s", szColour[0]);
	Format(szItem2, 128, "Text Colour: %s", szColour[1]);

	Menu menu = CreateMenu(CustomTitleMenuHandler);
	SetMenuTitle(menu, szTitle);

	AddMenuItem(menu, "Name Colour", szItem);
	AddMenuItem(menu, "Text Colour", szItem2);
	if (g_bDbCustomTitleInUse[client])
		AddMenuItem(menu, "disable", "Disable Custom Title");
	else
		AddMenuItem(menu, "disable", "Enable Custom Title");

	SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int CustomTitleMenuHandler(Handle menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0, 1: db_viewPlayerColours(param1, g_szSteamID[param1], param2);
			case 2: db_toggleCustomPlayerTitle(param1, g_szSteamID[param1]);
		}
	}
	else if (action == MenuAction_End)
		CloseHandle(menu);
}

public Action Command_VoteExtend(int client, int args)
{
	if(!IsValidClient(client))
		return Plugin_Handled;

	if (g_iVipLvl[client] < 1)
	{
		ReplyToCommand(client, " %cSurfTimer %c| You do not have access to this commnad", LIMEGREEN, WHITE);
		return Plugin_Handled;
	}

	VoteExtend(client);
	return Plugin_Handled;
}

public void VoteExtend(int client)
{
	int timeleft;
	GetMapTimeLeft(timeleft);

	if (timeleft > 300)
	{
		PrintToChat(client, " %cSurfTimer%c | You may only use vote extend when there is 5 minutes left.", LIMEGREEN, WHITE);
		return;
	}

	if (IsVoteInProgress())
	{
		PrintToChat(client, " %cSurfTimer%c | Please wait until the current vote has finished.", LIMEGREEN, WHITE);
		return;
	}

	char szPlayerName[MAX_NAME_LENGTH];
	GetClientName(client, szPlayerName, MAX_NAME_LENGTH);

	Menu menu = CreateMenu(Handle_VoteMenuExtend);
	SetMenuTitle(menu, "Extend the map by 10 minutes?");
	AddMenuItem(menu, "###yes###", "Yes");
	AddMenuItem(menu, "###no###", "No");
	SetMenuExitButton(menu, false);
	VoteMenuToAll(menu, 20);
	CPrintToChatAll(" %cSurfTimer%c | Vote to Extend started by %c%s", LIMEGREEN, WHITE, LIMEGREEN, szPlayerName);

	return;
}

public Action Command_normalMode(int client, int args)
{
	if (!IsValidClient(client))
		return Plugin_Handled;

	Client_Stop(client, 1);
	g_bPracticeMode[client] = false;
	Command_Restart(client, 1);

	PrintToChat(client, "%t", "PracticeNormal", LIMEGREEN, WHITE, MOSSGREEN);
	return Plugin_Handled;
}

public Action Command_createPlayerCheckpoint(int client, int args)
{
	if (!IsValidClient(client))
		return Plugin_Handled;

	if (g_iClientInZone[client][0] == 1 || g_iClientInZone[client][0] == 5)
	{
		PrintToChat(client, "%t", "PracticeInStartZone", LIMEGREEN, WHITE);
		return Plugin_Handled;
	}

	float CheckpointTime = GetGameTime();

	// Move old checkpoint to the undo values, if the last checkpoint was made more than a second ago
	if (g_bCreatedTeleport[client] && (CheckpointTime - g_fLastPlayerCheckpoint[client]) > 1.0)
	{
		g_fLastPlayerCheckpoint[client] = CheckpointTime;
		Array_Copy(g_fCheckpointLocation[client], g_fCheckpointLocation_undo[client], 3);
		Array_Copy(g_fCheckpointVelocity[client], g_fCheckpointVelocity_undo[client], 3);
		Array_Copy(g_fCheckpointAngle[client], g_fCheckpointAngle_undo[client], 3);
	}

	g_bCreatedTeleport[client] = true;
	GetClientAbsOrigin(client, g_fCheckpointLocation[client]);
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", g_fCheckpointVelocity[client]);
	GetClientEyeAngles(client, g_fCheckpointAngle[client]);


	PrintToChat(client, "%t", "PracticePointCreated", LIMEGREEN, WHITE, LIMEGREEN, WHITE);

	return Plugin_Handled;
}

public Action Command_goToPlayerCheckpoint(int client, int args)
{
	if (!IsValidClient(client))
		return Plugin_Handled;

	if (g_fCheckpointLocation[client][0] != 0.0 && g_fCheckpointLocation[client][1] != 0.0 && g_fCheckpointLocation[client][2] != 0.0)
	{
		if (g_bPracticeMode[client] == false)
		{
			PrintToChat(client, "%t", "PracticeStarted", LIMEGREEN, WHITE, LIMEGREEN, WHITE, LIMEGREEN, WHITE);
			PrintToChat(client, "%t", "PracticeStarted2", LIMEGREEN, WHITE, LIMEGREEN, WHITE, LIMEGREEN, WHITE);
			g_bPracticeMode[client] = true;
		}

		//fluffys gravity
		if(g_iInitalStyle[client] != 4)
			ResetGravity(client);
		else //lowgravity
			SetEntityGravity(client, 0.5);

		CL_OnStartTimerPress(client);
		SetEntPropVector(client, Prop_Data, "m_vecVelocity", view_as<float>( { 0.0, 0.0, 0.0 } ));
		TeleportEntity(client, g_fCheckpointLocation[client], g_fCheckpointAngle[client], g_fCheckpointVelocity[client]);
		g_bWrcpTimeractivated[client] = false;
	}
	else
		PrintToChat(client, "%t", "PracticeStartError", LIMEGREEN, WHITE, MOSSGREEN);

	return Plugin_Handled;
}

public Action Command_undoPlayerCheckpoint(int client, int args)
{
	if (!IsValidClient(client))
		return Plugin_Handled;

	if (g_fCheckpointLocation_undo[client][0] != 0.0 && g_fCheckpointLocation_undo[client][1] != 0.0 && g_fCheckpointLocation_undo[client][2] != 0.0)
	{
		float tempLocation[3], tempVelocity[3], tempAngle[3];

		// Location
		Array_Copy(g_fCheckpointLocation_undo[client], tempLocation, 3);
		Array_Copy(g_fCheckpointLocation[client], g_fCheckpointLocation_undo[client], 3);
		Array_Copy(tempLocation, g_fCheckpointLocation[client], 3);

		// Velocity
		Array_Copy(g_fCheckpointVelocity_undo[client], tempVelocity, 3);
		Array_Copy(g_fCheckpointVelocity[client], g_fCheckpointVelocity_undo[client], 3);
		Array_Copy(tempVelocity, g_fCheckpointVelocity[client], 3);

		// Angle
		Array_Copy(g_fCheckpointAngle_undo[client], tempAngle, 3);
		Array_Copy(g_fCheckpointAngle[client], g_fCheckpointAngle_undo[client], 3);
		Array_Copy(tempAngle, g_fCheckpointAngle[client], 3);

		PrintToChat(client, "%t", "PracticeUndo", LIMEGREEN, WHITE);
	}
	else
		PrintToChat(client, "%t", "PracticeUndoError", LIMEGREEN, WHITE, MOSSGREEN);

	return Plugin_Handled;
}

public Action Command_Teleport(int client, int args)
{
	g_bWrcpTimeractivated[client] = false;

	// Throttle using !back to fix errors with replays
	if ((GetGameTime() - g_fLastCommandBack[client]) < 1.0)
		return Plugin_Handled;
	else
		g_fLastCommandBack[client] = GetGameTime();

	if (g_Stage[g_iClientInZone[client][2]][client] == 1)
	{
		//fluffys
		if(g_bPause[client] == true)
			PauseMethod(client);

		teleportClient(client, g_iClientInZone[client][2], 1, false);
		return Plugin_Handled;
	}

	//fluffys
	if(g_bPause[client] == true)
		PauseMethod(client);

	teleportClient(client, g_iClientInZone[client][2], g_Stage[g_iClientInZone[client][2]][client], false);
	return Plugin_Handled;
}

public Action Command_HowTo(int client, int args)
{
	ShowMOTDPanel(client, "How To Surf", "http://koti.kapsi.fi/~mukavajoni/how", MOTDPANEL_TYPE_URL);
	return Plugin_Handled;
}

public Action Command_Zones(int client, int args)
{
	if (IsValidClient(client))
	{
		if(g_bZoner[client] || CheckCommandAccess(client, "", ADMFLAG_CUSTOM2))
		{
			ZoneMenu(client);
			resetSelection(client);
		}
		else
			ReplyToCommand(client, " %cSurfTimer %c| You do not have access to this command.", LIMEGREEN, WHITE);
	}
	return Plugin_Handled;
}

public Action Command_ListBonuses(int client, int args)
{
	if (IsValidClient(client))
	{
		ListBonuses(client, 1);
	}
	return Plugin_Handled;
}

public void ListBonuses(int client, int type)
{
	// Types: Start(1), End(2), Stage(3), Checkpoint(4), Speed(5), TeleToStart(6), Validator(7), Chekcer(8), Stop(0)
	char buffer[3];
	Menu listBonusesMenu;
	if (type == 1)
	{
		listBonusesMenu = new Menu(MenuHandler_SelectBonus);
	}
	else
	{
		listBonusesMenu = new Menu(MenuHandler_SelectBonusTop);
	}

	listBonusesMenu.SetTitle("Choose a bonus");

	if (g_mapZoneGroupCount > 1)
	{
		for (int i = 1; i < g_mapZoneGroupCount; i++)
		{
			IntToString(i, buffer, 3);
			listBonusesMenu.AddItem(buffer, g_szZoneGroupName[i]);
		}
	}
	else
	{
		PrintToChat(client, " %cSurfTimer %c| There are no bonuses in this map.", LIMEGREEN, WHITE);
		return;
	}

	listBonusesMenu.ExitButton = true;
	listBonusesMenu.Display(client, 60);
}

public int MenuHandler_SelectBonusTop(Menu sMenu, MenuAction action, int client, int item)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char aID[3];
			GetMenuItem(sMenu, item, aID, sizeof(aID));
			int zoneGrp = StringToInt(aID);
			db_selectBonusTopSurfers(client, g_szMapName, zoneGrp);
		}
		case MenuAction_End:
		{
			delete sMenu;
		}
	}
}


public int MenuHandler_SelectBonus(Menu sMenu, MenuAction action, int client, int item)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char aID[3];
			GetMenuItem(sMenu, item, aID, sizeof(aID));
			int zoneGrp = StringToInt(aID);

			teleportClient(client, zoneGrp, 1, true);
		}
		case MenuAction_End:
		{
			delete sMenu;
		}
	}
}

public Action Command_ToBonus(int client, int args)
{
	if (!IsValidClient(client))
		return Plugin_Handled;

	// If not enough arguments, or there is more than one bonus
	if (args < 1 && g_mapZoneGroupCount > 2) // Tell player to select specific bonus
	{
		/*PrintToChat(client, " %cSurfTimer %c| Usage: !b <bonus number>", LIMEGREEN, WHITE);
		if (g_mapZoneGroupCount > 1)
		{
			PrintToChat(client, " %cSurfTimer %c| Available bonuses:", LIMEGREEN, WHITE);
			for (int i = 1; i < g_mapZoneGroupCount; i++)
			{
				PrintToChat(client, "[%c%i.%c] %s", YELLOW, i, WHITE, g_szZoneGroupName[i]);
			}
		}*/
		ListBonuses(client, 1);
		return Plugin_Handled;
	}

	int zoneGrp;
	if (g_mapZoneGroupCount > 2) // If there is more than one bonus in the map, get the zGrp from command
	{
		char arg1[3];
		GetCmdArg(1, arg1, sizeof(arg1));

		if (!arg1[0])
			zoneGrp = args;
		else
			zoneGrp = StringToInt(arg1);

		if (zoneGrp == 0) {
			Command_Restart(client, 1);
			return Plugin_Handled;
		}
	}
	else
		zoneGrp = 1;

	teleportClient(client, zoneGrp, 1, true);
	return Plugin_Handled;
}

public Action Command_SelectStage(int client, int args)
{
	if (IsValidClient(client))
		ListStages(client, g_iClientInZone[client][2]);
	return Plugin_Handled;
}


public void ListStages(int client, int zonegroup)
{
	// Types: Start(1), End(2), Stage(3), Checkpoint(4), Speed(5), TeleToStart(6), Validator(7), Chekcer(8), Stop(0)
	Menu sMenu = CreateMenu(MenuHandler_SelectStage);
	SetMenuTitle(sMenu, "Stage selector");
	int amount = 0;
	char StageName[64], ZoneInfo[6];

	int StageIds[MAXZONES] =  { -1, ... };

	if (g_mapZonesCount > 0)
	{
		for (int i = 0; i <= g_mapZonesCount; i++)
		{
			if (g_mapZones[i][zoneType] == 3 && g_mapZones[i][zoneGroup] == zonegroup)
			{
				StageIds[amount] = i;
				amount++;
			}
		}
		if (amount == 0)
		{
			AddMenuItem(sMenu, "", "The map is linear.", ITEMDRAW_DISABLED);
		}
		else
		{
			amount = 0;
			for (int t = 0; t < 128; t++)
			{
				if (StageIds[t] >= 0)
				{
					amount++;
					Format(StageName, sizeof(StageName), "Stage %i", (amount + 1));
					IntToString(amount + 1, ZoneInfo, 6);
					AddMenuItem(sMenu, ZoneInfo, StageName);
				}
			}
		}
	}
	else
	{
		AddMenuItem(sMenu, "", "No stages are available.", ITEMDRAW_DISABLED);
	}

	SetMenuExitButton(sMenu, true);
	DisplayMenu(sMenu, client, MENU_TIME_FOREVER);
}

public int MenuHandler_SelectStage(Menu tMenu, MenuAction action, int client, int item)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char aID[64];
			GetMenuItem(tMenu, item, aID, sizeof(aID));
			int id = StringToInt(aID);
			teleportClient(client, g_iClientInZone[client][2], id, true);
		}
		case MenuAction_End:
		{
			CloseHandle(tMenu);
		}
	}
}

public Action Command_ToStage(int client, int args)
{
	if (!IsValidClient(client))
		return Plugin_Handled;
	if (args < 1)
	{
		// Remove chat output to reduce chat spam
		//PrintToChat(client, "Teleport to stage 1 | Default usage: !s <stage number>");
		g_bInStartZone[client] = false;
		teleportClient(client, 0, 1, true);
	}
	else
	{
		char arg1[3];
		g_bInStartZone[client] = false;
		GetCmdArg(1, arg1, sizeof(arg1));
		int StageId = StringToInt(arg1);
		teleportClient(client, 0, StageId, true);
	}



	return Plugin_Handled;
}

public Action Command_ToEnd(int client, int args)
{
	if (!IsValidClient(client))
		return Plugin_Handled;

	if (!GetConVarBool(g_hCommandToEnd))
	{
		ReplyToCommand(client, " %cSurfTimer %c| Teleportation to the end zone has been disabled on this server.", LIMEGREEN, WHITE);
		return Plugin_Handled;
	}
	teleportClient(client, g_iClientInZone[client][2], -1, true);
	return Plugin_Handled;
}

public Action Command_Restart(int client, int args)
{
	if (GetConVarBool(g_hDoubleRestartCommand) && args == 0)
	{
		if (GetGameTime() - g_fClientRestarting[client] > 5.0)
			g_bClientRestarting[client] = false;

		// Check that the client has a timer running, the zonegroup he is in has stages and that this is the first click
		if (IsValidClient(client) && g_bTimeractivated[client] && g_mapZonesTypeCount[g_iClientInZone[client][2]][3] > 0 && !g_bClientRestarting[client] && g_Stage[g_iClientInZone[client][2]][client] > 1)
		{
			g_fClientRestarting[client] = GetGameTime();
			g_bClientRestarting[client] = true;
			PrintToChat(client, " %cSurfTimer %c| Are you sure you want to restart your run? Use %c!r%c again to restart.", LIMEGREEN, WHITE, GREEN, WHITE);
			ClientCommand(client, "play ambient/misc/clank4");
			return Plugin_Handled;
		}
	}

	g_bClientRestarting[client] = false;
	//fluffys
	if(g_bPause[client] == true)
		PauseMethod(client);

	g_bWrcpTimeractivated[client] = false;
	g_bInStageZone[client] = false;
	g_bInStartZone[client] = true;
	// Reset targetname for filters
	if(StrContains(g_szMapName, "surf_parc_colore", false)!=-1)
		DispatchKeyValue(client, "targetname", "player_LVL1_start");
	else
		DispatchKeyValue(client, "targetname", "player");

	teleportClient(client, 0, 1, true);
	return Plugin_Handled;
}

public Action Client_HideChat(int client, int args)
{
	HideChat(client);
	if (g_bHideChat[client])
		PrintToChat(client, "%t", "HideChat1", LIMEGREEN, WHITE);
	else
		PrintToChat(client, "%t", "HideChat2", LIMEGREEN, WHITE);
	return Plugin_Handled;
}

public void HideChat(int client)
{
	if (!g_bHideChat[client])
	{
		// Hiding
		if (g_bViewModel[client])
			SetEntProp(client, Prop_Send, "m_iHideHUD", GetEntProp(client, Prop_Send, "m_iHideHUD") | HIDE_RADAR | HIDE_CHAT | HIDE_CROSSHAIR);
		else
			SetEntProp(client, Prop_Send, "m_iHideHUD", GetEntProp(client, Prop_Send, "m_iHideHUD") | HIDE_RADAR | HIDE_CHAT);
	}
	else
	{
		// Displaying
		if (g_bViewModel[client])
			SetEntProp(client, Prop_Send, "m_iHideHUD", HIDE_RADAR | HIDE_CROSSHAIR);
		else
			SetEntProp(client, Prop_Send, "m_iHideHUD", HIDE_RADAR);
	}

	g_bHideChat[client] = !g_bHideChat[client];
}

public Action ToggleCheckpoints(int client, int args)
{
	if (!IsValidClient(client))
		return Plugin_Handled;

	if (g_bCheckpointsEnabled[client])
	{
		g_bCheckpointsEnabled[client] = false;
		if (g_bActivateCheckpointsOnStart[client])
			g_bActivateCheckpointsOnStart[client] = false;
		PrintToChat(client, "%t", "ToogleCheckpoints1", LIMEGREEN, WHITE);
	}
	else
	{
		if (g_bTimeractivated[client])
		{
			PrintToChat(client, "%t", "ToggleCheckpoints3", LIMEGREEN, WHITE);
			g_bActivateCheckpointsOnStart[client] = true;
		}
		else
		{
			g_bCheckpointsEnabled[client] = true;
			PrintToChat(client, "%t", "ToggleCheckpoints2", LIMEGREEN, WHITE);
		}
	}
	return Plugin_Handled;
}

public Action Client_HideWeapon(int client, int args)
{
	HideViewModel(client);
	if (g_bViewModel[client])
		PrintToChat(client, "%t", "HideViewModel2", LIMEGREEN, WHITE);
	else
		PrintToChat(client, "%t", "HideViewModel1", LIMEGREEN, WHITE);
	return Plugin_Handled;
}

public void HideViewModel(int client)
{
	Client_SetDrawViewModel(client, !g_bViewModel[client]);
	if (!g_bViewModel[client])
	{
		// Display
		if (!g_bHideChat[client])
			SetEntProp(client, Prop_Send, "m_iHideHUD", HIDE_RADAR);
		else
			SetEntProp(client, Prop_Send, "m_iHideHUD", HIDE_RADAR | HIDE_CHAT);
	}
	else
	{
		// Hiding
		if (!g_bHideChat[client])
			SetEntProp(client, Prop_Send, "m_iHideHUD", GetEntProp(client, Prop_Send, "m_iHideHUD") | HIDE_RADAR | HIDE_CROSSHAIR);
		else
			SetEntProp(client, Prop_Send, "m_iHideHUD", GetEntProp(client, Prop_Send, "m_iHideHUD") | HIDE_RADAR | HIDE_CHAT | HIDE_CROSSHAIR);
	}


	g_bViewModel[client] = !g_bViewModel[client];
}

public Action Client_Wr(int client, int args)
{
	RateLimit(client);

	if (IsValidClient(client) && !g_bRateLimit[client])
	{
		if(args == 0)
		{
			if (g_fRecordMapTime == 9999999.0)
				PrintToChat(client, "%t", "NoRecordTop", LIMEGREEN, WHITE);
			else
				PrintMapRecords(client, 0);
		}
		else
		{
			char arg1[128];
			GetCmdArg(1, arg1, sizeof(arg1));

			db_selectMapRecordTime(client, arg1);
		}
	}

	return Plugin_Handled;
}

public Action Client_Wrb(int client, int args)
{
	if (IsValidClient(client))
	{
		if (g_fBonusFastest[1] == 9999999.0)
			PrintToChat(client, "%t", "NoRecordTop", LIMEGREEN, WHITE);
		else
			PrintMapRecords(client, 99);
	}
	return Plugin_Handled;
}

public Action Client_Wrbsw(int client, int args)
{
	if (IsValidClient(client))
	{
		if (g_fStyleBonusFastest[1][1] == 9999999.0)
			PrintToChat(client, "%t", "NoRecordTop", LIMEGREEN, WHITE);
		else
			PrintMapRecords(client, 991);
	}
	return Plugin_Handled;
}

public Action Client_Wrbhsw(int client, int args)
{
	if (IsValidClient(client))
	{
		if (g_fStyleBonusFastest[2][1] == 9999999.0)
			PrintToChat(client, "%t", "NoRecordTop", LIMEGREEN, WHITE);
		else
			PrintMapRecords(client, 992);
	}
	return Plugin_Handled;
}

public Action Client_Wrbbw(int client, int args)
{
	if (IsValidClient(client))
	{
		if (g_fStyleBonusFastest[3][1] == 9999999.0)
			PrintToChat(client, "%t", "NoRecordTop", LIMEGREEN, WHITE);
		else
			PrintMapRecords(client, 993);
	}
	return Plugin_Handled;
}

public Action Client_Wrblg(int client, int args)
{
	if (IsValidClient(client))
	{
		if (g_fStyleBonusFastest[4][1] == 9999999.0)
			PrintToChat(client, "%t", "NoRecordTop", LIMEGREEN, WHITE);
		else
			PrintMapRecords(client, 994);
	}
	return Plugin_Handled;
}

public Action Client_Wrbsm(int client, int args)
{
	if (IsValidClient(client))
	{
		if (g_fStyleBonusFastest[5][1] == 9999999.0)
			PrintToChat(client, "%t", "NoRecordTop", LIMEGREEN, WHITE);
		else
			PrintMapRecords(client, 995);
	}
	return Plugin_Handled;
}

public Action Client_Wrbff(int client, int args)
{
	if (IsValidClient(client))
	{
		if (g_fStyleBonusFastest[6][1] == 9999999.0)
			PrintToChat(client, "%t", "NoRecordTop", LIMEGREEN, WHITE);
		else
			PrintMapRecords(client, 996);
	}
	return Plugin_Handled;
}

public Action Client_Wrsw(int client, int args)
{
	if (IsValidClient(client))
	{
		if (g_fRecordStyleMapTime[1] == 9999999.0)
			PrintToChat(client, "%t", "NoRecordTop", LIMEGREEN, WHITE);
		else
			PrintMapRecords(client, 1);
	}
	return Plugin_Handled;
}

public Action Client_Wrhsw(int client, int args)
{
	if (IsValidClient(client))
	{
		if (g_fRecordStyleMapTime[2] == 9999999.0)
			PrintToChat(client, "%t", "NoRecordTop", LIMEGREEN, WHITE);
		else
			PrintMapRecords(client, 2);
	}
	return Plugin_Handled;
}

public Action Client_Wrbw(int client, int args)
{
	if (IsValidClient(client))
	{
		if (g_fRecordStyleMapTime[3] == 9999999.0)
			PrintToChat(client, "%t", "NoRecordTop", LIMEGREEN, WHITE);
		else
			PrintMapRecords(client, 3);
	}
	return Plugin_Handled;
}

public Action Client_Wrlg(int client, int args)
{
	if (IsValidClient(client))
	{
		if (g_fRecordStyleMapTime[4] == 9999999.0)
			PrintToChat(client, "%t", "NoRecordTop", LIMEGREEN, WHITE);
		else
			PrintMapRecords(client, 4);
	}
	return Plugin_Handled;
}

public Action Client_Wrsm(int client, int args)
{
	if (IsValidClient(client))
	{
		if (g_fRecordStyleMapTime[5] == 9999999.0)
			PrintToChat(client, "%t", "NoRecordTop", LIMEGREEN, WHITE);
		else
			PrintMapRecords(client, 5);
	}
	return Plugin_Handled;
}

public Action Client_Wrff(int client, int args)
{
	if (IsValidClient(client))
	{
		if (g_fRecordStyleMapTime[6] == 9999999.0)
			PrintToChat(client, "%t", "NoRecordTop", LIMEGREEN, WHITE);
		else
			PrintMapRecords(client, 6);
	}
	return Plugin_Handled;
}

public Action Command_Tier(int client, int args)
{
	if (IsValidClient(client) && g_bTierFound[0]) //the second condition is only checked if the first passes
		PrintToChat(client, g_sTierString[0]);
}

public Action Command_bTier(int client, int args)
{
	if (IsValidClient(client))
	{
		if (g_mapZoneGroupCount == 1)
		{
			PrintToChat(client, " %cSurfTimer %c| There are no bonuses in this map.", LIMEGREEN, WHITE);
			return;
		}

		int found = 0;
		for (int i = 1; i < MAXZONEGROUPS; i++)
		{
			if (g_bTierFound[i])
			{
				PrintToChat(client, g_sTierString[i]);
				found++;
			}
		}

		if (found == 0)
		{
			PrintToChat(client, " %cSurfTimer %c| Bonus tiers have not been set on this map.", LIMEGREEN, WHITE);
		}
	}
}

public Action Client_Avg(int client, int args)
{
	if (!IsValidClient(client))
		return Plugin_Handled;

	char szProTime[32];
	FormatTimeFloat(client, g_favg_maptime, 3, szProTime, sizeof(szProTime));

	if (g_MapTimesCount == 0)
		Format(szProTime, 32, "N/A");

	PrintToChat(client, "%t", "AvgTime", LIMEGREEN, WHITE, GRAY, DARKBLUE, WHITE, szProTime, g_MapTimesCount);

	if (g_bhasBonus)
	{
		char szBonusTime[32];

		for (int i = 1; i < g_mapZoneGroupCount; i++)
		{
			FormatTimeFloat(client, g_fAvg_BonusTime[i], 3, szBonusTime, sizeof(szBonusTime));

			if (g_iBonusCount[i] == 0)
				Format(szBonusTime, 32, "N/A");
			PrintToChat(client, "%t", "AvgTimeBonus", LIMEGREEN, WHITE, GRAY, ORANGE, WHITE, szBonusTime, g_iBonusCount[i]);
		}
	}

	return Plugin_Handled;
}

public Action Client_Flashlight(int client, int args)
{
	if (IsValidClient(client) && IsPlayerAlive(client))
		SetEntProp(client, Prop_Send, "m_fEffects", GetEntProp(client, Prop_Send, "m_fEffects") ^ 4);
	return Plugin_Handled;
}

public Action Client_Usp(int client, int args)
{
	if (!IsValidClient(client) || !IsPlayerAlive(client))
		return Plugin_Handled;

	if ((GetGameTime() - g_flastClientUsp[client]) < 10.0)
		return Plugin_Handled;

	g_flastClientUsp[client] = GetGameTime();

	if (Client_HasWeapon(client, "weapon_hkp2000"))
	{
		int weapon = Client_GetWeapon(client, "weapon_hkp2000");
		FakeClientCommand(client, "use %s", weapon);
		InstantSwitch(client, weapon);
	}
	else
		GivePlayerItem(client, "weapon_usp_silencer");
	return Plugin_Handled;
}

void InstantSwitch(int client, int weapon, int timer = 0)
{
	if (weapon == -1)
		return;

	float GameTime = GetGameTime();

	if (!timer)
	{
		SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon);
		SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GameTime);
	}

	SetEntPropFloat(client, Prop_Send, "m_flNextAttack", GameTime);
	int ViewModel = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
	SetEntProp(ViewModel, Prop_Send, "m_nSequence", 0);
}

public Action Command_ext_Menu(int client, const char[] command, int argc)
{
	return Plugin_Handled;
}

//https://forums.alliedmods.net/showthread.php?t=206308
public Action Command_JoinTeam(int client, const char[] command, int argc)
{
	if (!IsValidClient(client) || argc < 1)
		return Plugin_Handled;
	char arg[4];
	GetCmdArg(1, arg, sizeof(arg));
	int toteam = StringToInt(arg);

	TeamChangeActual(client, toteam);
	return Plugin_Handled;
}

public Action Client_OptionMenu(int client, int args)
{
	OptionMenu(client);
	return Plugin_Handled;
}

public Action NoClip(int client, int args)
{
	if (!IsValidClient(client))
		return Plugin_Handled;

	if(g_bSurfTimerEnabled[client])
		{
			g_bSurfTimerEnabled[client] = !g_bSurfTimerEnabled[client];
			PrintToChat(client, " %cSurfTimer %c| Noclip enabled, surftimer %cdisabled", LIMEGREEN, WHITE, DARKRED);
		}

	Action_NoClip(client);

	return Plugin_Handled;
}

public Action UnNoClip(int client, int args)
{

if(!g_bSurfTimerEnabled[client])
	{
		PrintToChat(client, " %cSurfTimer %c| Noclip disabled, use %c!surftimer %cto re-enable your timer", LIMEGREEN, WHITE, GREEN, WHITE);
	}

	if (g_bNoClip[client] == true)
		Action_UnNoClip(client);

	if (g_iInitalStyle[client] != 4)
		ResetGravity(client);
	else
		SetEntityGravity(client, 0.5);

	return Plugin_Handled;
}

public Action Command_ckNoClip(int client, int args)
{
	if(!IsValidClient(client))
		return Plugin_Handled;

	if(g_bSurfTimerEnabled[client])
		{
			PrintToChat(client, " %cSurfTimer %c| You must %cdisable your surftimer %cbefore you can use noclip, !surftimer.", LIMEGREEN, WHITE, DARKRED, WHITE);
			return Plugin_Handled;
		}

	if(!IsPlayerAlive(client))
	{
		ReplyToCommand(client, " %cSurfTimer %c| You cannot use NoClip while you are dead", LIMEGREEN, WHITE);
	}
	else
	{
		MoveType mt = GetEntityMoveType(client);

		if (mt != MOVETYPE_NOCLIP)
		{
			Action_NoClip(client);
		}
		else
		{
			Action_UnNoClip(client);
		}
	}

	return Plugin_Handled;
}


public Action Client_Top(int client, int args)
{
	ckTopMenu(client);
	return Plugin_Handled;
}

public Action Client_MapTop(int client, int args)
{
	char szArg[128];

	if (args == 0)
	{
		Format(szArg, 128, "%s", g_szMapName);
	}
	else
	{
		GetCmdArg(1, szArg, 128);
	}
	db_selectMapTopSurfers(client, szArg);
	return Plugin_Handled;
}

public Action Client_BonusTop(int client, int args)
{
	char szArg[128], zGrp;

	if (!IsValidClient(client))
		return Plugin_Handled;

	switch (args) {
		case 0: {  // !btop
			if (g_mapZoneGroupCount == 1)
			{
				PrintToChat(client, " %cSurfTimer %c| No bonus found on this map.", LIMEGREEN, WHITE);
				PrintToChat(client, " %cSurfTimer %c| Usage: !btop <bonus id> <mapname>", LIMEGREEN, WHITE);
				return Plugin_Handled;
			}
			if (g_mapZoneGroupCount == 2)
			{
				zGrp = 1;
				Format(szArg, 128, "%s", g_szMapName);
			}
			if (g_mapZoneGroupCount > 2)
			{
				ListBonuses(client, 2);
				return Plugin_Handled;
			}
		}
		case 1: {  //!btop <mapname> / <bonus id>
			// 1st check if bonus id or mapname
			GetCmdArg(1, szArg, 128);
			if (StringToInt(szArg) == 0 && szArg[0] != '0') // passes, if not a number (argument is mapname)
			{
				db_selectBonusesInMap(client, szArg);
				return Plugin_Handled;
			}
			else // argument is a bonus id (Use current map)
			{
				zGrp = StringToInt(szArg);
				if (0 < zGrp < MAXZONEGROUPS)
				{
					Format(szArg, 128, "%s", g_szMapName);
				}
				else
				{
					PrintToChat(client, " %cSurfTimer %c| Invalid bonus ID %i.", LIMEGREEN, WHITE, zGrp);
					return Plugin_Handled;
				}
			}
		}
		case 2: {
			GetCmdArg(1, szArg, 128);
			if (StringToInt(szArg) != 0 && szArg[0] != '0') // passes, if not a number (argument is mapname)
			{
				char szZGrp[128];
				GetCmdArg(2, szZGrp, 128);
				zGrp = StringToInt(szZGrp);
			}
			else // argument is a bonus id
			{
				zGrp = StringToInt(szArg);
				GetCmdArg(2, szArg, 128);
			}

			if (0 > zGrp || zGrp > MAXZONEGROUPS)
			{
				PrintToChat(client, " %cSurfTimer %c| Invalid bonus ID %i.", LIMEGREEN, WHITE, zGrp);
				return Plugin_Handled;
			}
		}
		default: {
			PrintToChat(client, " %cSurfTimer %c| Usage: !btop <bonus id> <mapname>", LIMEGREEN, WHITE);
			return Plugin_Handled;
		}
	}
	db_selectBonusTopSurfers(client, szArg, zGrp);
	return Plugin_Handled;
}

public Action Client_SWBonusTop(int client, int args)
{
	char szArg[128], zGrp;

	if (!IsValidClient(client))
		return Plugin_Handled;

	switch (args) {
		case 0: {  // !btop
			if (g_mapZoneGroupCount == 1)
			{
				PrintToChat(client, " %cSurfTimer %c| No bonus found on this map.", LIMEGREEN, WHITE);
				PrintToChat(client, " %cSurfTimer %c| Usage: !btop <bonus id> <mapname>", LIMEGREEN, WHITE);
				return Plugin_Handled;
			}
			if (g_mapZoneGroupCount == 2)
			{
				zGrp = 1;
				Format(szArg, 128, "%s", g_szMapName);
			}
			if (g_mapZoneGroupCount > 2)
			{
				ListBonuses(client, 2);
				return Plugin_Handled;
			}
		}
		case 1: {  //!btop <mapname> / <bonus id>
			// 1st check if bonus id or mapname
			GetCmdArg(1, szArg, 128);
			if (StringToInt(szArg) == 0 && szArg[0] != '0') // passes, if not a number (argument is mapname)
			{
				db_selectBonusesInMap(client, szArg);
				return Plugin_Handled;
			}
			else // argument is a bonus id (Use current map)
			{
				zGrp = StringToInt(szArg);
				if (0 < zGrp < MAXZONEGROUPS)
				{
					Format(szArg, 128, "%s", g_szMapName);
				}
				else
				{
					PrintToChat(client, " %cSurfTimer %c| Invalid bonus ID %i.", LIMEGREEN, WHITE, zGrp);
					return Plugin_Handled;
				}
			}
		}
		case 2: {
			GetCmdArg(1, szArg, 128);
			if (StringToInt(szArg) != 0 && szArg[0] != '0') // passes, if not a number (argument is mapname)
			{
				char szZGrp[128];
				GetCmdArg(2, szZGrp, 128);
				zGrp = StringToInt(szZGrp);
			}
			else // argument is a bonus id
			{
				zGrp = StringToInt(szArg);
				GetCmdArg(2, szArg, 128);
			}

			if (0 > zGrp || zGrp > MAXZONEGROUPS)
			{
				PrintToChat(client, " %cSurfTimer %c| Invalid bonus ID %i.", LIMEGREEN, WHITE, zGrp);
				return Plugin_Handled;
			}
		}
		default: {
			PrintToChat(client, " %cSurfTimer %c| Usage: !btop <bonus id> <mapname>", LIMEGREEN, WHITE);
			return Plugin_Handled;
		}
	}
	db_selectBonusTopSurfers(client, szArg, zGrp);
	return Plugin_Handled;
}

public Action Client_SWMapTop(int client, int args)
{
	char szArg[128];

	if (args == 0)
	{
		Format(szArg, 128, "%s", g_szMapName);
	}
	else
	{
		GetCmdArg(1, szArg, 128);
	}
	db_selectStyleMapTopSurfers(client, szArg, 1);
	return Plugin_Handled;
}

public Action Client_HSWMapTop(int client, int args)
{
	char szArg[128];

	if (args == 0)
	{
		Format(szArg, 128, "%s", g_szMapName);
	}
	else
	{
		GetCmdArg(1, szArg, 128);
	}
	db_selectStyleMapTopSurfers(client, szArg, 2);
	return Plugin_Handled;
}

public Action Client_BWMapTop(int client, int args)
{
	char szArg[128];

	if (args == 0)
	{
		Format(szArg, 128, "%s", g_szMapName);
	}
	else
	{
		GetCmdArg(1, szArg, 128);
	}
	db_selectStyleMapTopSurfers(client, szArg, 3);
	return Plugin_Handled;
}

public Action Client_LGMapTop(int client, int args)
{
	char szArg[128];

	if (args == 0)
	{
		Format(szArg, 128, "%s", g_szMapName);
	}
	else
	{
		GetCmdArg(1, szArg, 128);
	}
	db_selectStyleMapTopSurfers(client, szArg, 4);
	return Plugin_Handled;
}

public Action Client_SMMapTop(int client, int args)
{
	char szArg[128];

	if (args == 0)
	{
		Format(szArg, 128, "%s", g_szMapName);
	}
	else
	{
		GetCmdArg(1, szArg, 128);
	}
	db_selectStyleMapTopSurfers(client, szArg, 5);
	return Plugin_Handled;
}

public Action Client_FFMapTop(int client, int args)
{
	char szArg[128];

	if (args == 0)
	{
		Format(szArg, 128, "%s", g_szMapName);
	}
	else
	{
		GetCmdArg(1, szArg, 128);
	}
	db_selectStyleMapTopSurfers(client, szArg, 6);
	return Plugin_Handled;
}


public Action Client_Spec(int client, int args)
{
	SpecPlayer(client, args);
	return Plugin_Handled;
}

public void SpecPlayer(int client, int args)
{
	char szPlayerName[MAX_NAME_LENGTH];
	char szPlayerName2[256];
	char szOrgTargetName[MAX_NAME_LENGTH];
	char szTargetName[MAX_NAME_LENGTH];
	char szArg[MAX_NAME_LENGTH];
	Format(szTargetName, MAX_NAME_LENGTH, "");
	Format(szOrgTargetName, MAX_NAME_LENGTH, "");

	if (args == 0)
	{
		Menu menu = CreateMenu(SpecMenuHandler);

		if (g_bSpectate[client])
			SetMenuTitle(menu, "SurfTimer - Spec menu (press 'm' to rejoin a team!)\n------------------------------------------------------------\n");
		else
			SetMenuTitle(menu, "SurfTimer - Spec menu \n------------------------------\n");
		int playerCount = 0;

		//add replay bots
		if (g_RecordBot != -1)
		{
			if (g_RecordBot != -1 && IsValidClient(g_RecordBot) && IsPlayerAlive(g_RecordBot))
			{
				Format(szPlayerName2, 256, "Map record replay (%s)", g_szReplayTime);
				AddMenuItem(menu, "MAP RECORD REPLAY", szPlayerName2);
				playerCount++;
			}
		}
		if (g_BonusBot != -1)
		{
			if (g_BonusBot != -1 && IsValidClient(g_BonusBot) && IsPlayerAlive(g_BonusBot))
			{
				Format(szPlayerName2, 256, "Bonus record replay (%s)", g_szBonusTime);
				AddMenuItem(menu, "BONUS RECORD REPLAY", szPlayerName2);
				playerCount++;
			}
		}


		int count = 0;
		//add players
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && IsPlayerAlive(i) && i != client && !IsFakeClient(i))
			{
				if (count == 0)
				{
					int bestrank = 99999999;
					for (int x = 1; x <= MaxClients; x++)
					{
						if (IsValidClient(x) && IsPlayerAlive(x) && x != client && !IsFakeClient(x) && g_PlayerRank[x] > 0)
							if (g_PlayerRank[x] <= bestrank)
							bestrank = g_PlayerRank[x];
					}
					char szMenu[128];
					Format(szMenu, 128, "Highest ranked player (#%i)", bestrank);
					AddMenuItem(menu, "brp123123xcxc", szMenu);
					AddMenuItem(menu, "", "", ITEMDRAW_SPACER);
				}
				GetClientName(i, szPlayerName, MAX_NAME_LENGTH);
				Format(szPlayerName2, 256, "%s (%s)", szPlayerName, g_pr_rankname[i]);
				AddMenuItem(menu, szPlayerName, szPlayerName2);
				playerCount++;
				count++;
			}
		}

		if (playerCount > 0 || g_RecordBot != -1 || g_BonusBot != -1)
		{
			SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
			DisplayMenu(menu, client, MENU_TIME_FOREVER);
		}

	}
	else
	{
		for (int i = 1; i < 20; i++)
		{
			GetCmdArg(i, szArg, MAX_NAME_LENGTH);
			if (!StrEqual(szArg, "", false))
			{
				if (i == 1)
					Format(szTargetName, MAX_NAME_LENGTH, "%s", szArg);
				else
					Format(szTargetName, MAX_NAME_LENGTH, "%s %s", szTargetName, szArg);
			}
		}
		Format(szOrgTargetName, MAX_NAME_LENGTH, "%s", szTargetName);
		StringToUpper(szTargetName);
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && IsPlayerAlive(i) && i != client)
			{
				GetClientName(i, szPlayerName, MAX_NAME_LENGTH);
				StringToUpper(szPlayerName);
				if ((StrContains(szPlayerName, szTargetName) != -1))
				{
					ChangeClientTeam(client, 1);
					SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", i);
					SetEntProp(client, Prop_Send, "m_iObserverMode", 4);
					g_bWrcpTimeractivated[client] = false;
					return;
				}
			}
		}
		PrintToChat(client, "%t", "PlayerNotFound", LIMEGREEN, WHITE, szOrgTargetName);
	}
}

public int SpecMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		char szPlayerName[MAX_NAME_LENGTH];
		GetMenuItem(menu, param2, info, sizeof(info));

		if (StrEqual(info, "brp123123xcxc"))
		{
			int playerid;
			int count = 0;
			int bestrank = 99999999;
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i) && IsPlayerAlive(i) && i != param1 && !IsFakeClient(i))
				{
					if (g_PlayerRank[i] <= bestrank)
					{
						bestrank = g_PlayerRank[i];
						playerid = i;
						count++;
					}
				}
			}
			if (count == 0)
				PrintToChat(param1, "%t", "NoPlayerTop", LIMEGREEN, WHITE);
			else
			{
				ChangeClientTeam(param1, 1);
				SetEntPropEnt(param1, Prop_Send, "m_hObserverTarget", playerid);
				SetEntProp(param1, Prop_Send, "m_iObserverMode", 4);
				g_bWrcpTimeractivated[param1] = false;
			}
		}
		else
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i) && IsPlayerAlive(i) && i != param1)
				{
					GetClientName(i, szPlayerName, MAX_NAME_LENGTH);
					if (i == g_RecordBot)
						Format(szPlayerName, MAX_NAME_LENGTH, "MAP RECORD REPLAY");
					if (i == g_BonusBot)
						Format(szPlayerName, MAX_NAME_LENGTH, "BONUS RECORD REPLAY");
					if (StrEqual(info, szPlayerName))
					{
						ChangeClientTeam(param1, 1);
						SetEntPropEnt(param1, Prop_Send, "m_hObserverTarget", i);
						SetEntProp(param1, Prop_Send, "m_iObserverMode", 4);
						g_bWrcpTimeractivated[param1] = false;
					}
				}
			}
		}
	}
	else
		if (action == MenuAction_End)
		{
			CloseHandle(menu);
		}
}

public void ProfileMenu(int client, int args, int style)
{
	//spam protection
	float diff = GetGameTime() - g_fProfileMenuLastQuery[client];
	if (diff < 0.5)
	{
		g_bSelectProfile[client] = false;
		return;
	}
	g_fProfileMenuLastQuery[client] = GetGameTime();
	g_ProfileStyleSelect[client] = style;

	char szArg[MAX_NAME_LENGTH];
	//no argument
	if (args == 0)
	{
		char szPlayerName[MAX_NAME_LENGTH];
		Menu menu = CreateMenu(ProfileSelectMenuHandler);
		SetMenuTitle(menu, "SurfTimer - Profile Menu\n------------------------------\n");
		GetClientName(client, szPlayerName, MAX_NAME_LENGTH);
		AddMenuItem(menu, szPlayerName, szPlayerName);
		int playerCount = 1;
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && i != client && !IsFakeClient(i))
			{
				GetClientName(i, szPlayerName, MAX_NAME_LENGTH);
				AddMenuItem(menu, szPlayerName, szPlayerName);
				playerCount++;
			}
		}
		g_bSelectProfile[client] = true;
		SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
		DisplayMenu(menu, client, MENU_TIME_FOREVER);
		return;
	}
	else
	{
		if (args != -1)
		{
			g_bSelectProfile[client] = false;
			Format(g_szProfileName[client], MAX_NAME_LENGTH, "");
			for (int i = 1; i < 20; i++)
			{
				GetCmdArg(i, szArg, MAX_NAME_LENGTH);
				if (!StrEqual(szArg, "", false))
				{
					if (i == 1)
						Format(g_szProfileName[client], MAX_NAME_LENGTH, "%s", szArg);
					else
						Format(g_szProfileName[client], MAX_NAME_LENGTH, "%s %s", g_szProfileName[client], szArg);
				}
			}
		}
	}
	//player ingame? new name?
	if (args != 0 && !StrEqual(g_szProfileName[client], "", false))
	{
		bool bPlayerFound = false;
		char szSteamId2[32];
		char szName[MAX_NAME_LENGTH];
		char szName2[MAX_NAME_LENGTH];
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i))
			{
				GetClientName(i, szName, MAX_NAME_LENGTH);
				StringToUpper(szName);
				Format(szName2, MAX_NAME_LENGTH, "%s", g_szProfileName[client]);
				if ((StrContains(szName, szName2, false) != -1))
				{
					bPlayerFound = true;
					GetClientAuthId(i, AuthId_Steam2, szSteamId2, MAX_NAME_LENGTH, true);
					//GetClientAuthString(i, szSteamId2, 32);
					g_ClientProfile[client] = i;
					g_bProfileInServer[client] = true;
					continue;
				}
			}
		}
		if(style == 0)
		{
			if(bPlayerFound)
			{
				g_bProfileInServer[client] = true;
				db_viewPlayerRank(client, szSteamId2);
			}
			else
			{
				g_bProfileInServer[client] = false;
				db_viewPlayerProfile1(client, g_szProfileName[client]);
			}
		}
		else
		{
			if (bPlayerFound)
			{
				db_viewPlayerRankStyle(client, szSteamId2, style);
			}
			else
			{
				db_viewPlayerStyleProfile1(client, g_szProfileName[client], style);
			}
		}
	}
}

public int ProfileSelectMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		char szPlayerName[MAX_NAME_LENGTH];
		GetMenuItem(menu, param2, info, sizeof(info));

		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i))
			{
				GetClientName(i, szPlayerName, MAX_NAME_LENGTH);
				if (StrEqual(info, szPlayerName))
				{
					Format(g_szProfileName[param1], MAX_NAME_LENGTH, "%s", szPlayerName);
					char szSteamId[32];
					GetClientAuthId(i, AuthId_Steam2, szSteamId, MAX_NAME_LENGTH, true);
					g_ClientProfile[param1] = i;
					//GetClientAuthString(i, szSteamId, 32);
					//fluffys comeback style menu
					int style = g_ProfileStyleSelect[param1];
					if(style == 0)
					{
						g_bProfileInServer[param1] = true;
						db_viewPlayerRank(param1, szSteamId);
					}
					else
						db_viewPlayerRankStyle(param1, szSteamId, style);
				}
			}
		}
	}
	else
		if (action == MenuAction_End)
	{
		if (IsValidClient(param1))
			g_bSelectProfile[param1] = false;
		CloseHandle(menu);
	}
}

public Action Client_AutoBhop(int client, int args)
{
	AutoBhop(client);
	if (g_bAutoBhop)
	{
		if (!g_bAutoBhopClient[client])
			PrintToChat(client, "%t", "AutoBhop2", LIMEGREEN, WHITE);
		else
			PrintToChat(client, "%t", "AutoBhop1", LIMEGREEN, WHITE);
	}
	return Plugin_Handled;
}

public void AutoBhop(int client)
{
	if (!g_bAutoBhop)
		PrintToChat(client, "%t", "AutoBhop3", LIMEGREEN, WHITE);

	g_bAutoBhopClient[client] = !g_bAutoBhopClient[client];

	if(g_bAutoBhopClient[client])
		SendConVarValue(client, g_hAutoBhop, "1");
	else
		SendConVarValue(client, g_hAutoBhop, "0");
}

//fluffys surftimer
public Action Client_SurfTimer(int client, int args)
{
	SurfTimer(client);
	if (!g_bSurfTimerEnabled[client])
		PrintToChat(client, "%cSurfTimer %c| SurfTimer %cdisabled.", LIMEGREEN, WHITE, DARKRED);
	else
		PrintToChat(client, "%cSurfTimer %c| SurfTimer %cenabled.", LIMEGREEN, WHITE, GREEN);
	return Plugin_Handled;
}

public void SurfTimer(int client)
{
	g_bSurfTimerEnabled[client] = !g_bSurfTimerEnabled[client];
	Client_Stop(client, 1);

	if(g_bSurfTimerEnabled[client] || g_bSurfTimerEnabled[client] && g_bNoClip[client])
	{
		Action_UnNoClip(client);
		Command_Restart(client, 1);
	}

}

public void SpeedGradient(int client)
{
	if (g_SpeedGradient[client] != 2)
		g_SpeedGradient[client]++;
	else
		g_SpeedGradient[client] = 0;
}

public Action Client_Hide(int client, int args)
{
	HideMethod(client);
	if (!g_bHide[client])
		PrintToChat(client, "%t", "Hide1", LIMEGREEN, WHITE);
	else
		PrintToChat(client, "%t", "Hide2", LIMEGREEN, WHITE);
	return Plugin_Handled;
}

public void HideMethod(int client)
{
	g_bHide[client] = !g_bHide[client];
}

public Action Client_Latest(int client, int args)
{
	db_ViewLatestRecords(client);
	return Plugin_Handled;
}

public Action Client_Showsettings(int client, int args)
{
	ShowSrvSettings(client);
	return Plugin_Handled;
}

public Action Client_Help(int client, int args)
{
	HelpPanel(client);
	return Plugin_Handled;
}

//old client_ranks
/*public Action Client_Ranks(int client, int args)
{
	if (IsValidClient(client))
	{
		char ChatLine[512];
		Format(ChatLine, 512, " %cSurfTimer %c| ", LIMEGREEN, WHITE);
		int i, RankValue[SkillGroup];
		for (i = 0; i < GetArraySize(g_hSkillGroups); i++)
		{
			GetArrayArray(g_hSkillGroups, i, RankValue[0]);

			if (i != 0 && i % 3 == 0)
			{
				PrintToChat(client, ChatLine);
				Format(ChatLine, 512, " ");
			}
			Format(ChatLine, 512, "%s%s%c (%ip)   ", ChatLine, RankValue[RankNameColored], WHITE, RankValue[PointReq]);
		}
		PrintToChat(client, ChatLine);
	}
	return Plugin_Handled;
}*/

public Action Client_Ranks(int client, int args)
{
	if (IsValidClient(client))
	{
		/*PrintToChat(client, " %cSurfTimer %c| Unranked (0p) Newbie (1-199p) Learning (200-399p) %cNovice %c(400-599p) %cBeginner %c(600-799p) %cRookie %c(800-999p) %cAverage %c(1000-1499p) %cCasual %c(1500-2999p) %cAdvanced %c(3000p+) %cSkilled %c(Rank 451-500) %cExceptional %c(Rank 351-450)", LIMEGREEN, WHITE, GRAY, WHITE, GRAY, WHITE, YELLOW, WHITE, YELLOW, WHITE, MOSSGREEN, WHITE, MOSSGREEN, WHITE, LIMEGREEN, WHITE, LIMEGREEN, WHITE);

		PrintToChat(client, " %cSurftimer %c| %cAmazing %c(Rank 201-350) %cPro %c(Rank 101-200) %cVeteran %c(Rank 51-100) %cExpert %c(Rank 26-50) %cElite %c(Rank 11-25) %cMaster %c(Rank 4-10) %cLegendary %c(Rank 3) %cGodly %c(Rank 2) %cKing %c(Rank 1) [Custom Rank] (Rank 1-3)", LIMEGREEN, WHITE, GREEN, WHITE, GREEN, WHITE, DARKBLUE, WHITE, DARKBLUE, WHITE, LIGHTBLUE, WHITE, LIGHTBLUE, WHITE, ORANGE, WHITE, PINK, WHITE, LIGHTRED, WHITE, DARKRED, WHITE);*/

		displayRanksMenu(client, 0);

	}
	return Plugin_Handled;
}

public void displayRanksMenu(int client, int args)
{
	if(args == 0)
	{
		Menu menu = CreateMenu(ShowRanksMenuHandler);
		char szMenuTitle[1028];
		SetMenuTitle(menu, "Rank 1: King [Players Choice]\nRank 2: Godly [Players Choice]\nRank 3: Legendary [Players Choice]\nRank 4-10: Master\nRank 11-25: Elite\nRank 26-50: Expert\nRank 51-100: Veteran\nRank 101-200: Pro\nRank 201-250: Amazing\n10000+ Points: Exceptional\n8000-9999 Points: Skilled\n7000-7999 Points: Advanced\n6000-6999 Points: Casual\n5000-5999 Points: Average\n4000-4999 Points: Rookie\n3000-3999 Points: Beginner\n2000-2999 Points: Novice\n1000-1999 Points: Learning\n1-999 Points: Newbie\n0 Points: Unranked");
		AddMenuItem(menu, "", "", ITEMDRAW_SPACER);
		SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
		DisplayMenu(menu, client, MENU_TIME_FOREVER);

		return;
	}
}

public int ShowRanksMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	/*if (action == MenuAction_Select)
	{

	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}*/
}

public Action Client_Profile(int client, int args)
{
	ProfileMenu(client, args, 0);
	return Plugin_Handled;
}

public Action Client_SWProfile(int client, int args)
{
	ProfileMenu(client, args, 1);
	return Plugin_Handled;
}

public Action Client_HSWProfile(int client, int args)
{
	ProfileMenu(client, args, 2);
	return Plugin_Handled;
}

public Action Client_BWProfile(int client, int args)
{
	ProfileMenu(client, args, 3);
	return Plugin_Handled;
}

public Action Client_LGProfile(int client, int args)
{
	ProfileMenu(client, args, 4);
	return Plugin_Handled;
}

public Action Client_SMProfile(int client, int args)
{
	ProfileMenu(client, args, 5);
	return Plugin_Handled;
}

public Action Client_FFProfile(int client, int args)
{
	ProfileMenu(client, args, 6);
	return Plugin_Handled;
}

public Action Client_Pause(int client, int args)
{
	if (GetClientTeam(client) == 1)return Plugin_Handled;
	if (g_bInStartZone[client])
	{
		PrintToChat(client, " %cSurfTimer %c| You cannot pause with your timer stopped.", LIMEGREEN, WHITE);
		return Plugin_Handled;
	}
	PauseMethod(client);
	if (g_bPause[client] == false)
		PrintToChat(client, "%t", "Pause2", LIMEGREEN, WHITE, RED, WHITE);
	else
		PrintToChat(client, "%t", "Pause3", LIMEGREEN, WHITE);
	return Plugin_Handled;
}

public void PauseMethod(int client)
{
	if (GetClientTeam(client) == 1)return;
	if (g_bPause[client] == false && IsValidEntity(client))
	{
		if (GetConVarBool(g_hPauseServerside) == false && client != g_RecordBot && client != g_BonusBot)
		{
			PrintToChat(client, "%t", "Pause1", LIMEGREEN, WHITE, RED, WHITE);
			return;
		}
		g_bPause[client] = true;
		/*float fVel[3];
		fVel[0] = 0.000000;
		fVel[1] = 0.000000;
		fVel[2] = 0.000000;
		SetEntPropVector(client, Prop_Data, "m_vecVelocity", fVel);
		*/
		SetEntityMoveType(client, MOVETYPE_NONE); //not sure why he sets vel to 0
		//Timer enabled?
		if (g_bTimeractivated[client] == true)
		{
			g_fStartPauseTime[client] = GetGameTime();
			if (g_fPauseTime[client] > 0.0)
				g_fStartPauseTime[client] = g_fStartPauseTime[client] - g_fPauseTime[client];
		}
		SetEntityRenderMode(client, RENDER_NONE);
		SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
	}
	else
	{
		if (g_fStartTime[client] != -1.0 && g_bTimeractivated[client] == true)
		{
			g_fPauseTime[client] = GetGameTime() - g_fStartPauseTime[client];
		}
			g_bNoClip[client] = false;
		g_bPause[client] = false;
		if (!g_bRoundEnd)
			SetEntityMoveType(client, MOVETYPE_WALK);
		SetEntityRenderMode(client, RENDER_NORMAL);
		if (GetConVarBool(g_hCvarNoBlock))
			SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
		else
			SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 5, true);

		//TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, view_as<float>( { 0.0, 0.0, -100.0 } ));
	}
}

public Action Client_HideSpecs(int client, int args)
{
	HideSpecs(client);
	if (g_bShowSpecs[client] == true)
		PrintToChat(client, "%t", "HideSpecs1", LIMEGREEN, WHITE);
	else
		PrintToChat(client, "%t", "HideSpecs2", LIMEGREEN, WHITE);
	return Plugin_Handled;
}

public void HideSpecs(int client)
{
	g_bShowSpecs[client] = !g_bShowSpecs[client];
}

public Action Client_Showtime(int client, int args)
{
	ShowTime(client);
	if (g_bShowTime[client])
		PrintToChat(client, "%t", "Showtime1", LIMEGREEN, WHITE);
	else
		PrintToChat(client, "%t", "Showtime2", LIMEGREEN, WHITE);
	return Plugin_Handled;
}

public void ShowTime(int client)
{
	g_bShowTime[client] = !g_bShowTime[client];
}

public int GoToMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		char szPlayerName[MAX_NAME_LENGTH];
		GetMenuItem(menu, param2, info, sizeof(info));
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && IsPlayerAlive(i) && i != param1)
			{
				GetClientName(i, szPlayerName, MAX_NAME_LENGTH);
				if (StrEqual(info, szPlayerName))
				{
					GotoMethod(param1, i);
				}
				else
				{
					if (i == MaxClients)
					{
						PrintToChat(param1, "%t", "Goto4", LIMEGREEN, WHITE, szPlayerName);
						Client_GoTo(param1, 0);
					}
				}
			}
		}
	}
	else
		if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public void GotoMethod(int client, int target)
{
	if (!IsValidClient(client) || IsFakeClient(client))
		return;
	char szTargetName[MAX_NAME_LENGTH];
	GetClientName(target, szTargetName, MAX_NAME_LENGTH);
	if (GetEntityFlags(target) & FL_ONGROUND)
	{
		Client_Stop(client, 0);

		int ducked = GetEntProp(target, Prop_Send, "m_bDucked");
		int ducking = GetEntProp(target, Prop_Send, "m_bDucking");
		if (!(GetClientButtons(client) & IN_DUCK) && ducked == 0 && ducking == 0)
		{
			if (GetClientTeam(client) == 1 || GetClientTeam(client) == 0)
			{
				float position[3];
				float angles[3];
				GetClientAbsOrigin(target, position);
				GetClientEyeAngles(target, angles);

				AddVectors(position, angles, g_fTeleLocation[client]);
				g_fTeleLocation[client][0] = FloatDiv(g_fTeleLocation[client][0], 2.0);
				g_fTeleLocation[client][1] = FloatDiv(g_fTeleLocation[client][1], 2.0);
				g_fTeleLocation[client][2] = FloatDiv(g_fTeleLocation[client][2], 2.0);

				g_bRespawnPosition[client] = false;
				g_specToStage[client] = true;
				TeamChangeActual(client, 0);
			}
			else
			{
				float position[3];
				float angles[3];
				GetClientAbsOrigin(target, position);
				GetClientEyeAngles(target, angles);
				teleportEntitySafe(client, position, angles, view_as<float>( { 0.0, 0.0, -100.0 } ), true);
				//TeleportEntity(client, position, angles, Float:{0.0,0.0,-100.0});
				char szClientName[MAX_NAME_LENGTH];
				GetClientName(client, szClientName, MAX_NAME_LENGTH);
				PrintToChat(target, "%t", "Goto5", LIMEGREEN, WHITE, szClientName);
			}
		}
		else
		{
			PrintToChat(client, "%t", "Goto6", LIMEGREEN, WHITE, szTargetName);
			Client_GoTo(client, 0);
		}
	}
	else
	{
		PrintToChat(client, "%t", "Goto7", LIMEGREEN, WHITE, szTargetName);
		Client_GoTo(client, 0);
	}
}



public Action Client_GoTo(int client, int args)
{
	if (!GetConVarBool(g_hGoToServer))
		PrintToChat(client, "%t", "Goto1", LIMEGREEN, WHITE, RED, WHITE);
	else
		if (!GetConVarBool(g_hCvarNoBlock))
			PrintToChat(client, "%t", "Goto2", LIMEGREEN, WHITE);
		else
			if (g_bTimeractivated[client])
				PrintToChat(client, "%t", "Goto3", LIMEGREEN, WHITE, GREEN, WHITE);
			else
			{
				char szPlayerName[MAX_NAME_LENGTH];
				char szOrgTargetName[MAX_NAME_LENGTH];
				char szTargetName[MAX_NAME_LENGTH];
				char szArg[MAX_NAME_LENGTH];
				if (args == 0)
				{
					Menu menu = CreateMenu(GoToMenuHandler);
					SetMenuTitle(menu, "Goto menu");
					int playerCount = 0;
					for (int i = 1; i <= MaxClients; i++)
					{
						if (IsValidClient(i) && IsPlayerAlive(i) && i != client && !IsFakeClient(i))
						{
							GetClientName(i, szPlayerName, MAX_NAME_LENGTH);
							AddMenuItem(menu, szPlayerName, szPlayerName);
							playerCount++;
						}
					}
					if (playerCount > 0)
					{
						SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
						DisplayMenu(menu, client, MENU_TIME_FOREVER);
					}
					else
					{
						CloseHandle(menu);
					}
				}
				else
				{
					for (int i = 1; i < 20; i++)
					{
						GetCmdArg(i, szArg, MAX_NAME_LENGTH);
						if (!StrEqual(szArg, "", false))
						{
							if (i == 1)
								Format(szTargetName, MAX_NAME_LENGTH, "%s", szArg);
							else
								Format(szTargetName, MAX_NAME_LENGTH, "%s %s", szTargetName, szArg);
						}
					}
					Format(szOrgTargetName, MAX_NAME_LENGTH, "%s", szTargetName);
					StringToUpper(szTargetName);
					for (int i = 1; i <= MaxClients; i++)
					{
						if (IsValidClient(i) && IsPlayerAlive(i) && i != client)
						{
							GetClientName(i, szPlayerName, MAX_NAME_LENGTH);
							StringToUpper(szPlayerName);
							if ((StrContains(szPlayerName, szTargetName) != -1))
							{
								GotoMethod(client, i);
								return Plugin_Handled;
							}
						}
					}
					PrintToChat(client, "%t", "PlayerNotFound", LIMEGREEN, WHITE, szOrgTargetName);
				}
			}
	return Plugin_Handled;
}

public Action Client_QuakeSounds(int client, int args)
{
	QuakeSounds(client);
	if (g_bEnableQuakeSounds[client])
		PrintToChat(client, "%t", "QuakeSounds1", LIMEGREEN, WHITE);
	else
		PrintToChat(client, "%t", "QuakeSounds2", LIMEGREEN, WHITE);
	return Plugin_Handled;
}

public void QuakeSounds(int client)
{
	g_bEnableQuakeSounds[client] = !g_bEnableQuakeSounds[client];
}

public Action Client_Stop(int client, int args)
{
	if (g_bTimeractivated[client])
	{
		//PlayerPanel(client);
		g_bTimeractivated[client] = false;
		g_fStartTime[client] = -1.0;
		g_fCurrentRunTime[client] = -1.0;
	}

	if(g_bWrcpTimeractivated[client])
	{
		g_bWrcpTimeractivated[client] = false;
		g_fStartWrcpTime[client] = -1.0;
		g_fCurrentWrcpRunTime[client] = -1.0;
	}

	return Plugin_Handled;
}

public void Action_NoClip(int client)
{
	if (IsValidClient(client) && !IsFakeClient(client) && IsPlayerAlive(client) && GetConVarBool(g_hNoClipS))
	{
		g_fLastTimeNoClipUsed[client] = GetGameTime();
		int team = GetClientTeam(client);
		if (team == 2 || team == 3)
		{
			MoveType mt = GetEntityMoveType(client);
			if (mt == MOVETYPE_WALK)
			{
				if (g_bTimeractivated[client])
				{
					Client_Stop(client, 1);
					g_fStartTime[client] = -1.0;
					g_fCurrentRunTime[client] = -1.0;
				}
				SetEntityMoveType(client, MOVETYPE_NOCLIP);
				SetEntityRenderMode(client, RENDER_NONE);
				SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
				g_bNoClip[client] = true;
				g_bInStartZone[client] = true;
				g_bWrcpTimeractivated[client] = false;
			}
		}
	}
	return;
}

public void Action_UnNoClip(int client)
{
	if (IsValidClient(client) && !IsFakeClient(client) && IsPlayerAlive(client))
	{
		g_fLastTimeNoClipUsed[client] = GetGameTime();
		int team = GetClientTeam(client);
		if (team == 2 || team == 3)
		{
			MoveType mt = GetEntityMoveType(client);
			if (mt == MOVETYPE_NOCLIP)
			{
				SetEntityMoveType(client, MOVETYPE_WALK);
				SetEntityRenderMode(client, RENDER_NORMAL);
				if (GetConVarBool(g_hCvarNoBlock))
					SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
				else
					SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 5, 4, true);
				g_bNoClip[client] = false;
			}
		}
	}
	return;
}

public void ckTopMenu(int client)
{
	g_MenuLevel[client] = -1;
	Menu cktopmenu = CreateMenu(TopMenuHandler);
	SetMenuTitle(cktopmenu, "SurfTimer - Top Menu\n------------------------------\n");
	if (GetConVarBool(g_hPointSystem))
		AddMenuItem(cktopmenu, "Top 100 Players", "Top 100 Players");
	AddMenuItem(cktopmenu, "Map Top", "Map Top");

	AddMenuItem(cktopmenu, "Bonus Top", "Bonus Top", !g_bhasBonus);

	SetMenuOptionFlags(cktopmenu, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(cktopmenu, client, MENU_TIME_FOREVER);
}

public int TopMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		if (GetConVarBool(g_hPointSystem))
		{
			switch (param2)
			{
				case 0:db_selectTopPlayers(param1);
				case 1:db_selectTopSurfers(param1, g_szMapName);
				case 2:BonusTopMenu(param1);
			}
		}
		else
		{
			switch (param2)
			{
				case 0:db_selectTopProRecordHolders(param1);
				case 1:db_selectTopSurfers(param1, g_szMapName);
				case 2:BonusTopMenu(param1);
			}
		}
	}
	else
		if (action == MenuAction_End)
		CloseHandle(menu);
}

public void BonusTopMenu(int client)
{
	if (g_mapZoneGroupCount > 2)
	{
		char buffer[3];
		Menu sMenu = new Menu(BonusTopMenuHandler);
		sMenu.SetTitle("Bonus selector");

		if (g_mapZoneGroupCount > 1)
		{
			for (int i = 1; i < g_mapZoneGroupCount; i++)
			{
				IntToString(i, buffer, 3);
				sMenu.AddItem(buffer, g_szZoneGroupName[i]);
			}
		}
		else
		{
			PrintToChat(client, " %cSurfTimer %c| There are no bonuses in this map.", LIMEGREEN, WHITE);
			return;
		}

		sMenu.ExitButton = true;
		sMenu.Display(client, 60);
	}
	else {
		db_selectBonusTopSurfers(client, g_szMapName, 1);
	}
}

public int BonusTopMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		db_selectBonusTopSurfers(param1, g_szMapName, param2 + 1);
	}
}

public void HelpPanel(int client)
{
	PrintConsoleInfo(client);
	Handle panel = CreatePanel();
	char title[64];
	Format(title, 64, "Help (1/4)");
	DrawPanelText(panel, title);
	DrawPanelText(panel, " ");
	DrawPanelText(panel, "!help - opens this menu");
	DrawPanelText(panel, "!help2 - explanation of the ranking system");
	DrawPanelText(panel, "!menu - checkpoint menu");
	DrawPanelText(panel, "!options - player options menu");
	DrawPanelText(panel, "!top - top menu");
	DrawPanelText(panel, "!latest - prints in console the last map records");
	DrawPanelText(panel, "!profile/!ranks - opens your profile");
	DrawPanelText(panel, " ");
	DrawPanelItem(panel, "next page");
	DrawPanelItem(panel, "exit");
	SendPanelToClient(panel, client, HelpPanelHandler, 10000);
	CloseHandle(panel);
}

public int HelpPanelHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		if (param2 == 1)
			HelpPanel2(param1);
	}
}

public int HelpPanel2(int client)
{
	Handle panel = CreatePanel();
	char szTmp[64];
	Format(szTmp, 64, "Help (2/4)");
	DrawPanelText(panel, szTmp);
	DrawPanelText(panel, " ");
	DrawPanelText(panel, "!start/!r - go back to start");
	DrawPanelText(panel, "!stop - stops the timer");
	DrawPanelText(panel, "!pause - on/off pause");
	DrawPanelText(panel, "!usp - spawns a usp silencer");
	DrawPanelText(panel, "!spec [<name>] - select a player you want to watch");
	DrawPanelText(panel, "!goto [<name>] - teleports you to a given player");
	DrawPanelText(panel, "!showsettings - shows plugin settings");
	DrawPanelText(panel, " ");
	DrawPanelItem(panel, "previous page");
	DrawPanelItem(panel, "next page");
	DrawPanelItem(panel, "exit");
	SendPanelToClient(panel, client, HelpPanel2Handler, 10000);
	CloseHandle(panel);
}

public int HelpPanel2Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		if (param2 == 1)
			HelpPanel(param1);
		else
			if (param2 == 2)
			HelpPanel3(param1);
	}
}

public void HelpPanel3(int client)
{
	Handle panel = CreatePanel();
	char szTmp[64];
	Format(szTmp, 64, "Help (3/4)");
	DrawPanelText(panel, szTmp);
	DrawPanelText(panel, " ");
	DrawPanelText(panel, "!maptop <mapname> - displays map top for a given map");
	DrawPanelText(panel, "!flashlight - on/off flashlight");
	DrawPanelText(panel, "!ranks - prints in chat the available ranks");
	DrawPanelText(panel, "!measure - allows you to measure the distance between 2 points");
	DrawPanelText(panel, "!language - opens the language menu");
	DrawPanelText(panel, "!wr - prints in chat the record of the current map");
	DrawPanelText(panel, "!avg - prints in chat the average map time");
	DrawPanelText(panel, "!stuck / !back - teleports player back to the start of the stage. Does not stop timer");
	DrawPanelText(panel, "!avg - !");
	DrawPanelText(panel, " ");
	DrawPanelItem(panel, "previous page");
	DrawPanelItem(panel, "exit");
	SendPanelToClient(panel, client, HelpPanel3Handler, 10000);
	CloseHandle(panel);
}
public int HelpPanel3Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		if (param2 == 1)
			HelpPanel2(param1);
		else
			if (param2 == 2)
			HelpPanel4(param1);
	}
}

public void HelpPanel4(int client)
{
	Handle panel = CreatePanel();
	char szTmp[64];
	Format(szTmp, 64, "Help (4/4)");
	DrawPanelText(panel, szTmp);
	DrawPanelText(panel, " ");
	DrawPanelText(panel, "!cp - Creates a checkpoint to use in practice mode.");
	DrawPanelText(panel, "!tele / !teleport / !practice / !prac - Starts practice mode");
	DrawPanelText(panel, "!undo - Undoes your latest checkpoint");
	DrawPanelText(panel, " ");
	DrawPanelItem(panel, "previous page");
	DrawPanelItem(panel, "exit");
	SendPanelToClient(panel, client, HelpPanel4Handler, 10000);
	CloseHandle(panel);
}

public int HelpPanel4Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		if (param2 == 1)
			HelpPanel2(param1);
	}
}

public void ShowSrvSettings(int client)
{
	PrintToConsole(client, " ");
	PrintToConsole(client, "-----------------");
	PrintToConsole(client, "SurfTimer settings");
	PrintToConsole(client, "-------------------------------------");
	PrintToChat(client, " %cSurfTimer %c| See console for output!", LIMEGREEN, WHITE);
}

public void OptionMenu(int client)
{
	Menu optionmenu = CreateMenu(OptionMenuHandler);
	SetMenuTitle(optionmenu, "SurfTimer - Options Menu\n------------------------------\n");
	// #0
	if (g_bSurfTimerEnabled[client])
		AddMenuItem(optionmenu, "SurfTimer  -  Enabled", "Surftimer -  Enabled");
	else
		AddMenuItem(optionmenu, "SurfTimer  -  Disabled", "Surftimer -  Disabled");

	if (g_SpeedGradient[client] == 0)
		AddMenuItem(optionmenu, "Speed Gradient  -  Disabled", "Speed Gradient  -  Disabled");
	else if (g_SpeedGradient[client] == 1)
		AddMenuItem(optionmenu, "Speed Gradient  -  Green", "Speed Gradient  -  Green");
	else if (g_SpeedGradient[client] == 2)
		AddMenuItem(optionmenu, "Speed Gradient  -  Rainbow", "Speed Gradient  -  Rainbow");

	if (g_bHide[client])
		AddMenuItem(optionmenu, "Hide Players  -  Enabled", "Hide other players  -  Enabled");
	else
		AddMenuItem(optionmenu, "Hide Players  -  Disabled", "Hide other players  -  Disabled");
	// #1
	if (g_bEnableQuakeSounds[client])
		AddMenuItem(optionmenu, "Quake sounds - Enabled", "Quake sounds - Enabled");
	else
		AddMenuItem(optionmenu, "Quake sounds - Disabled", "Quake sounds - Disabled");
	// #2
	if (g_bShowTime[client])
		AddMenuItem(optionmenu, "Show Timer  -  Enabled", "Show timer text  -  Enabled");
	else
		AddMenuItem(optionmenu, "Show Timer  -  Disabled", "Show timer text  -  Disabled");
	// #3
	if (g_bShowSpecs[client])
		AddMenuItem(optionmenu, "Spectator list  -  Enabled", "Spectator list  -  Enabled");
	else
		AddMenuItem(optionmenu, "Spectator list  -  Disabled", "Spectator list  -  Disabled");
	// #4
	if (g_bInfoPanel[client])
		AddMenuItem(optionmenu, "Speed/Stage panel  -  Enabled", "Speed/Stage panel  -  Enabled");
	else
		AddMenuItem(optionmenu, "Speed/Stage panel  -  Disabled", "Speed/Stage panel  -  Disabled");
	// #5
	if (g_bStartWithUsp[client])
		AddMenuItem(optionmenu, "Active start weapon  -  Usp", "Start weapon  -  USP");
	else
		AddMenuItem(optionmenu, "Active start weapon  -  Knife", "Start weapon  -  Knife");
	// #6
	if (g_bGoToClient[client])
		AddMenuItem(optionmenu, "Goto  -  Enabled", "Goto me  -  Enabled");
	else
		AddMenuItem(optionmenu, "Goto  -  Disabled", "Goto me  -  Disabled");

	if (g_bAutoBhop)
	{
		// #7
		if (g_bAutoBhopClient[client])
			AddMenuItem(optionmenu, "AutoBhop  -  Enabled", "AutoBhop  -  Enabled");
		else
			AddMenuItem(optionmenu, "AutoBhop  -  Disabled", "AutoBhop  -  Disabled");
	}
	else
	{
		// #7
		if (g_bAutoBhopClient[client])
			AddMenuItem(optionmenu, "AutoBhop  -  Enabled", "AutoBhop  -  Enabled", ITEMDRAW_DISABLED);
		else
			AddMenuItem(optionmenu, "AutoBhop  -  Disabled", "AutoBhop  -  Disabled", ITEMDRAW_DISABLED);
	}
	// #8
	if (g_bHideChat[client])
		AddMenuItem(optionmenu, "Hide Chat - Hidden", "Hide Chat - Hidden");
	else
		AddMenuItem(optionmenu, "Hide Chat - Visible", "Hide Chat - Visible");
	// #9
	if (g_bViewModel[client])
		AddMenuItem(optionmenu, "Hide Weapon - Visible", "Hide Weapon - Visible");
	else
		AddMenuItem(optionmenu, "Hide Weapon - Hidden", "Hide Weapon - Hidden");
	// #10
	if (g_bCheckpointsEnabled[client])
		AddMenuItem(optionmenu, "Checkpoints - Enabled", "Checkpoints - Enabled");
	else
		AddMenuItem(optionmenu, "Checkpoints - Disabled", "Checkpoints - Disabled");

	SetMenuOptionFlags(optionmenu, MENUFLAG_BUTTON_EXIT);
	if (g_OptionsMenuLastPage[client] < 6)
		DisplayMenuAtItem(optionmenu, client, 0, MENU_TIME_FOREVER);
	else
		if (g_OptionsMenuLastPage[client] < 12)
			DisplayMenuAtItem(optionmenu, client, 6, MENU_TIME_FOREVER);
		else
			if (g_OptionsMenuLastPage[client] < 18)
				DisplayMenuAtItem(optionmenu, client, 12, MENU_TIME_FOREVER);
}


public int OptionMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0:SurfTimer(param1);
			case 1:SpeedGradient(param1);
			case 2:HideMethod(param1);
			case 3:QuakeSounds(param1);
			case 4:ShowTime(param1);
			case 5:HideSpecs(param1);
			case 6:InfoPanel(param1);
			case 7:SwitchStartWeapon(param1);
			case 8:DisableGoTo(param1);
			case 9:AutoBhop(param1);
			case 10:HideChat(param1);
			case 11:HideViewModel(param1);
			case 12:ToggleCheckpoints(param1, 1);
		}
		g_OptionsMenuLastPage[param1] = param2;
		OptionMenu(param1);
	}
	else
		if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}



public void SwitchStartWeapon(int client)
{
	g_bStartWithUsp[client] = !g_bStartWithUsp[client];
}

public Action Client_DisableGoTo(int client, int args)
{
	DisableGoTo(client);
	if (g_bGoToClient[client])
		PrintToChat(client, "%t", "DisableGoto1", LIMEGREEN, WHITE);
	else
		PrintToChat(client, "%t", "DisableGoto2", LIMEGREEN, WHITE);
	return Plugin_Handled;
}


public void DisableGoTo(int client)
{
	g_bGoToClient[client] = !g_bGoToClient[client];
}

public Action Client_InfoPanel(int client, int args)
{
	InfoPanel(client);
	if (g_bInfoPanel[client] == true)
		PrintToChat(client, "%t", "Info1", LIMEGREEN, WHITE);
	else
		PrintToChat(client, "%t", "Info2", LIMEGREEN, WHITE);
	return Plugin_Handled;
}

public void InfoPanel(int client)
{
	g_bInfoPanel[client] = !g_bInfoPanel[client];
}

//fluffys
public Action Command_PlayerTitle(int client, int args)
{
	if (g_iVipLvl[client] < 2)
	{
		PrintToChat(client, " %cSurfTimer %c| This is a SUPER VIP feature", LIMEGREEN, WHITE);
		return Plugin_Handled;
	}

	CustomTitleMenu(client);
	return Plugin_Handled;
}
public Action Command_SetDbTitle(int client, int args)
{
	if (!IsValidClient(client))
		return Plugin_Handled;

	if(g_iVipLvl[client] < 2)
	{
		PrintToChat(client, " %cSurfTimer %c| This is a SUPER VIP feature", LIMEGREEN, WHITE);
		return Plugin_Handled;
	}

	char arg[256], authSteamId[MAXPLAYERS + 1];
	GetClientAuthId(client, AuthId_Steam2, authSteamId, MAX_NAME_LENGTH, true);

	if (args == 0)
	{
		if(g_bdbHasCustomTitle[client])
		{
			db_toggleCustomPlayerTitle(client, authSteamId);
		}
		else
		{
			PrintToChat(client, " %cSurfTimer %c| Usage: sm_mytitle <my cool title>", LIMEGREEN, WHITE);
		}
	}
	else
	{
		GetCmdArg(1, arg, 256);
		char upperArg[256];
		char noColoursArg[256];
		upperArg = arg;
		StringToUpper(upperArg);
		noColoursArg = upperArg;
		parseColorsFromString(noColoursArg, 256);

		if(strlen(noColoursArg) > 20)
		{
			PrintToChat(client, " %cSurfTimer %c| Title too long, Maximum 20 characters. (Not Including colours)", LIMEGREEN, WHITE);

			return Plugin_Handled;
		}
		else if (StrContains(upperArg, "{RED}") != -1)
			ReplaceString(arg, 256, "{red}", "{lightred}", false);
		else if(StrContains(upperArg, "{LIMEGREEN}") != -1)
			ReplaceString(arg, 256, "{limegreen}", "{lime}");
		else if (StrContains(upperArg, "{WHITE}") != -1)
			ReplaceString(arg, 256, "{white}", "{default}", false);
		else if (StrContains(upperArg, "{PURPLE}") != -1)
			ReplaceString(arg, 256, "{purple}", "{default}", false);

		// Admin Checks - Head Admin
		if(CheckCommandAccess(client, "sm_ban", ADMFLAG_BAN) && StrContains(upperArg, "HEAD ADMIN")!=-1)
		{
			// Allow head admins to set their title to head admin
			db_checkCustomPlayerTitle(client, authSteamId, arg);
			return Plugin_Handled;
		}
		// Admin
		else if(CheckCommandAccess(client, "sm_kick", ADMFLAG_KICK) && StrEqual(upperArg, "ADMIN"))
		{
			// Allow admins to set their title to admin
			db_checkCustomPlayerTitle(client, authSteamId, arg);
			return Plugin_Handled;
		}
		// Moderator
		else if(CheckCommandAccess(client, "sm_say", ADMFLAG_GENERIC) && StrContains(upperArg, "MODERATOR")!=-1)
		{
			// Allow admins to set their title to admin
			db_checkCustomPlayerTitle(client, authSteamId, arg);
			return Plugin_Handled;
		}

		// Check if arg is in unallowed titles array
		for (int i = 0; i < sizeof(UnallowedTitles); i++)
		{
			if(StrContains(UnallowedTitles[i], upperArg)!=-1)
			{
				arg = "{pink}Fag";
				break;
			}
		}

		db_checkCustomPlayerTitle(client, authSteamId, arg);
	}

	return Plugin_Handled;
}

public Action Command_ToggleTitle(int client, int args)
{
	if (!IsValidClient(client))
		return Plugin_Handled;

	if (g_iVipLvl[client] < 1)
	{
		PrintToChat(client, "[SM] You do not have access to this command.");
		return Plugin_Handled;
	}

	char authSteamId[MAXPLAYERS + 1];

	GetClientAuthId(client, AuthId_Steam2, authSteamId, MAX_NAME_LENGTH, true);

	db_toggleCustomPlayerTitle(client, authSteamId);

	return Plugin_Handled;
}

public Action Command_SetDbNameColour(int client, int args)
{
	if (!IsValidClient(client))
		return Plugin_Handled;

	if(g_iVipLvl[client] < 2)
	{
		PrintToChat(client, "[SM] You do not have access to this command.");
		return Plugin_Handled;
	}

	char arg[128], authSteamId[MAXPLAYERS + 1];
	GetClientAuthId(client, AuthId_Steam2, authSteamId, MAX_NAME_LENGTH, true);

	if (args == 0)
	{
			PrintToChat(client, " %cSurfTimer %c| Usage: sm_namecolour {colour}", LIMEGREEN, WHITE);
	}
	else
	{
		GetCmdArg(1, arg, 128);
		char upperArg[128];
		upperArg = arg;
		StringToUpper(upperArg);
		if (StrContains(upperArg, "{WHITE}", false)!=-1 || StrContains(upperArg, "{DEFAULT}")!=-1)
		{
			arg = "0";
		}
		else if (StrContains(upperArg, "{DARKRED}", false)!=-1)
		{
			arg = "1";
		}
		else if (StrContains(upperArg, "{GREEN}", false)!=-1)
		{
			arg = "2";
		}
		else if (StrContains(upperArg, "{LIMEGREEN}", false)!=-1)
		{
			arg = "3";
		}
		else if (StrContains(upperArg, "{BLUE}", false)!=-1)
		{
			arg = "4";
		}
		else if (StrContains(upperArg, "{MOSSGREEN}", false)!=-1)
		{
		 	arg = "5";
		}
		else if (StrContains(upperArg, "{RED}", false)!=-1)
		{
			arg = "6";
		}
		else if (StrContains(upperArg, "{GREY}", false)!=-1)
		{
			arg = "7";
		}
		else if (StrContains(upperArg, "{YELLOW}", false)!=-1)
		{
		 	arg = "8";
		}
		else if (StrContains(upperArg, "{LIGHTBLUE}", false)!=-1)
		{
			arg = "9";
		}
		else if (StrContains(upperArg, "{DARKBLUE}", false)!=-1)
		{
			arg = "10";
		}
		else if (StrContains(upperArg, "{PINK}", false)!=-1)
		{
			arg = "11";
		}
		else if (StrContains(upperArg, "{LIGHTRED}", false)!=-1)
		{
			arg = "12";
		}
		else if (StrContains(upperArg, "{PURPLE}", false)!=-1)
		{
			//arg = "13";
			arg = "0";
		}
		else if (StrContains(upperArg, "{DARKGREY}", false)!=-1)
		{
			arg = "14";
		}
		else if (StrContains(upperArg, "{ORANGE}", false)!=-1)
		{
			arg = "15";
		}
		else
		{
			arg = "0";
		}

		db_checkCustomPlayerNameColour(client, authSteamId, arg);
	}

	return Plugin_Handled;
}

public Action Command_SetDbTextColour(int client, int args)
{
	if (!IsValidClient(client))
		return Plugin_Handled;

	if(g_iVipLvl[client] < 2)
	{
		PrintToChat(client, "[SM] You do not have access to this command.");
		return Plugin_Handled;
	}

	char arg[128], authSteamId[MAXPLAYERS + 1];
	GetClientAuthId(client, AuthId_Steam2, authSteamId, MAX_NAME_LENGTH, true);

	if (args == 0)
	{
		PrintToChat(client, " %cSurfTimer %c| Usage: sm_textcolour {colour}", LIMEGREEN, WHITE);
	}
	else
	{
		GetCmdArg(1, arg, 128);
		char upperArg[128];
		upperArg = arg;
		StringToUpper(upperArg);
		if (StrContains(upperArg, "{WHITE}", false)!=-1 || StrContains(upperArg, "{DEFAULT}")!=-1)
		{
			arg = "0";
		}
		else if (StrContains(upperArg, "{DARKRED}", false)!=-1)
		{
			arg = "1";
		}
		else if (StrContains(upperArg, "{GREEN}", false)!=-1)
		{
			arg = "2";
		}
		else if (StrContains(upperArg, "{LIMEGREEN}", false)!=-1 || StrContains(upperArg, "{LIME}", false)!=-1)
		{
			arg = "3";
		}
		else if (StrContains(upperArg, "{BLUE}", false)!=-1)
		{
			arg = "4";
		}
		else if (StrContains(upperArg, "{MOSSGREEN}", false)!=-1 || StrContains(upperArg, "{OLIVE}", false)!=-1)
		{
		 	arg = "5";
		}
		else if (StrContains(upperArg, "{RED}", false)!=-1)
		{
			arg = "6";
		}
		else if (StrContains(upperArg, "{GREY}", false)!=-1)
		{
			arg = "7";
		}
		else if (StrContains(upperArg, "{YELLOW}", false)!=-1)
		{
		 	arg = "8";
		}
		else if (StrContains(upperArg, "{LIGHTBLUE}", false)!=-1)
		{
			arg = "9";
		}
		else if (StrContains(upperArg, "{DARKBLUE}", false)!=-1)
		{
			arg = "10";
		}
		else if (StrContains(upperArg, "{PINK}", false)!=-1)
		{
			arg = "11";
		}
		else if (StrContains(upperArg, "{LIGHTRED}", false)!=-1)
		{
			arg = "12";
		}
		else if (StrContains(upperArg, "{PURPLE}", false)!=-1)
		{
			//arg = "13";
			arg = "0";
		}
		else if (StrContains(upperArg, "{DARKGREY}", false)!=-1)
		{
			arg = "14";
		}
		else if (StrContains(upperArg, "{ORANGE}", false)!=-1)
		{
			arg = "15";
		}
		else
		{
			arg = "0";
		}

		db_checkCustomPlayerTextColour(client, authSteamId, arg);
	}

	return Plugin_Handled;
}

public Action Command_ListColours(int client, int args)
{
	PrintToChat(client, " %cSurfTimer %c| Available Colours: %c{darkred} %c{lightred} %c{red} %c{green} %c{limegreen} %c{mossgreen} %c{darkblue} %c{lightblue} %c{blue} %c{pink} %c{purple} %c{orange} %c{yellow} %c{darkgrey} %c{grey} %c{white}", LIMEGREEN, WHITE, DARKRED, LIGHTRED, RED, GREEN, LIMEGREEN, MOSSGREEN, DARKBLUE, LIGHTBLUE, BLUE, PINK, PURPLE, ORANGE, YELLOW, DARKGREY, GRAY, WHITE);

	return Plugin_Handled;
}

public Action Client_Wrcp(int client, int args)
{
	WrcpMenu(client, args, 0);
	return Plugin_Handled;
}

public Action Client_SWWrcp(int client, int args)
{
	WrcpMenu(client, args, 1);
}

public Action Client_HSWWrcp(int client, int args)
{
	WrcpMenu(client, args, 2);
}

public Action Client_BWWrcp(int client, int args)
{
	WrcpMenu(client, args, 3);
}

public Action Client_LGWrcp(int client, int args)
{
	WrcpMenu(client, args, 4);
}

public Action Client_SMWrcp(int client, int args)
{
	WrcpMenu(client, args, 5);
}

public Action Client_FFWrcp(int client, int args)
{
	WrcpMenu(client, args, 6);
}

public void WrcpMenu(int client, int args, int style)
{
	//spam protection
	float diff = GetGameTime() - g_fWrcpMenuLastQuery[client];
	if (diff < 0.5)
	{
		g_bSelectWrcp[client] = false;
		return;
	}
	g_fWrcpMenuLastQuery[client] = GetGameTime();

	char szStageString[MAXPLAYERS + 1];
	char stage[MAXPLAYERS + 1];
	//no argument
	if (args == 0)
	{
		if(!g_bhasStages)
		{
			PrintToChat(client, " %cSurfTimer %c| Map is linear. WRCP Not Available", MOSSGREEN, DARKRED);
			return;
		}

		g_szWrcpMapSelect[client] = g_szMapName;
		Menu menu;
		if(style == 0)
		{
			menu = CreateMenu(StageSelectMenuHandler);
			SetMenuTitle(menu, "%s: select a stage \n------------------------------\n", g_szMapName);
		}
		else if(style != 0)
		{
			g_StyleStageSelect[client] = style;
			menu = CreateMenu(StageStyleSelectMenuHandler);
			SetMenuTitle(menu, "%s: select a stage [%s] \n------------------------------\n", g_szMapName, g_szStyleMenuPrint[style]);
		}
		int stageCount = g_TotalStages;
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
	else
	{
		GetCmdArg(1, g_szWrcpMapSelect[client], 128);
		if(StrContains(g_szWrcpMapSelect[client], "#", false) != -1)
		{
			ReplaceString(g_szWrcpMapSelect[client], 128, "#", "", false);
			if(style == 0)
				db_viewWrcpMapRecord(client);
			else
				db_viewWrcpStyleMapRecord(client, style);
		}
		else
		{
			if(style == 0)
				db_viewWrcpMap(client, g_szWrcpMapSelect[client]);
			else
				db_viewStyleWrcpMap(client, g_szWrcpMapSelect[client], style);
		}
	}
}

public int StageSelectMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		GetMenuItem(menu, param2, info, sizeof(info));
		//PrintToChat(param1, "Stage %i - %s", info, g_szWrcpMapSelect[param1]);
		db_selectStageTopSurfers(param1, info, g_szWrcpMapSelect[param1]);
	}
	else
	{
		if (action == MenuAction_End)
		{
			if (IsValidClient(param1))
				g_bSelectWrcp[param1] = false;
			CloseHandle(menu);
		}
	}
}

public int StageStyleSelectMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		int style = g_StyleStageSelect[param1];
		char info[32];
		GetMenuItem(menu, param2, info, sizeof(info));
		//PrintToChat(param1, "Stage %i - %s", info, g_szWrcpMapSelect[param1]);
		db_selectStageStyleTopSurfers(param1, info, g_szWrcpMapSelect[param1], style);
	}
	else
	{
		if (action == MenuAction_End)
		{
			if (IsValidClient(param1))
				g_bSelectWrcp[param1] = false;
			CloseHandle(menu);
		}
	}
}

//fluffys sm_gb
public Action Command_GoBack(int client, int args)
{
	if(g_CurrentStage[client] <= 1)
		Command_Restart(client, 1);
	else
		teleportClient(client, 0, g_CurrentStage[client], false);

	return Plugin_Handled;
}

//Styles
public Action Client_SelectStyle(int client, int args)
{
	styleSelectMenu(client);
	return Plugin_Handled;
}

public void styleSelectMenu(int client)
{
	Menu styleSelect = CreateMenu(StyleTypeSelectMenuHandler);
	SetMenuTitle(styleSelect, "Current Style: %s\n------------------------------\n", g_szInitalStyle[client]);
	AddMenuItem(styleSelect, "ranked", "Ranked Styles");
	AddMenuItem(styleSelect, "fun", "Fun Styles");
	SetMenuOptionFlags(styleSelect, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(styleSelect, client, MENU_TIME_FOREVER);
}

public int StyleTypeSelectMenuHandler(Menu styleSelect, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0:
			{
				Menu styleSelect2 = CreateMenu(StyleSelectMenuHandler);
				SetMenuTitle(styleSelect2, "Current Style: %s\n------------------------------\n", g_szInitalStyle[param1]);
				AddMenuItem(styleSelect2, "0", "Normal");
				AddMenuItem(styleSelect2, "1", "Sideways");
				AddMenuItem(styleSelect2, "2", "Half-Sideways");
				AddMenuItem(styleSelect2, "3", "Backwards", ITEMDRAW_DISABLED);
				SetMenuOptionFlags(styleSelect2, MENUFLAG_BUTTON_EXIT);
				DisplayMenu(styleSelect2, param1, MENU_TIME_FOREVER);
			}
			case 1:
			{
				Menu styleSelect2 = CreateMenu(StyleSelectMenuHandler);
				SetMenuTitle(styleSelect2, "Current Style: %s\n------------------------------\n", g_szInitalStyle[param1]);
				AddMenuItem(styleSelect2, "0", "Normal - Ranked");
				AddMenuItem(styleSelect2, "4", "Low-Gravity");
				AddMenuItem(styleSelect2, "5", "Slow Motion");
				AddMenuItem(styleSelect2, "6", "Fast Forward");
				SetMenuOptionFlags(styleSelect2, MENUFLAG_BUTTON_EXIT);
				DisplayMenu(styleSelect2, param1, MENU_TIME_FOREVER);
			}
		}
	}
	else
	{
		if (action == MenuAction_End)
			CloseHandle(styleSelect);
	}
}


public int StyleSelectMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		GetMenuItem(menu, param2, info, sizeof(info));
		if(StrContains(info, "1", false)!= -1)
		{
			g_iCurrentStyle[param1] = 1;
			g_iInitalStyle[param1] = 1;
			Format(g_szInitalStyle[param1], 128, "Sideways");
			Format(g_szStyleHud[param1], 32, "[SW]");
			g_bRankedStyle[param1] = true;
			g_bFunStyle[param1] = false;
		}
		else if(StrContains(info, "2", false)!= -1)
		{
			g_iCurrentStyle[param1] = 2;
			g_iInitalStyle[param1] = 2;
			Format(g_szInitalStyle[param1], 128, "Half-Sideways");
			Format(g_szStyleHud[param1], 32, "[HSW]");
			g_bRankedStyle[param1] = true;
			g_bFunStyle[param1] = false;
		}
		else if(StrContains(info, "3", false)!= -1)
		{
			g_iCurrentStyle[param1] = 3;
			g_iInitalStyle[param1] = 3;
			Format(g_szInitalStyle[param1], 128, "Backwards");
			Format(g_szStyleHud[param1], 32, "[BW]");
			g_bRankedStyle[param1] = true;
			g_bFunStyle[param1] = false;
		}
		else if(StrContains(info, "4", false)!= -1)
		{
			g_iCurrentStyle[param1] = 4;
			g_iInitalStyle[param1] = 4;
			Format(g_szInitalStyle[param1], 128, "Low-Gravity");
			Format(g_szStyleHud[param1], 32, "[LG]");
			SetEntityGravity(param1, 0.5);
			g_bRankedStyle[param1] = false;
			g_bFunStyle[param1] = true;
		}
		else if(StrContains(info, "5", false)!= -1)
		{
			g_iCurrentStyle[param1] = 5;
			g_iInitalStyle[param1] = 5;
			Format(g_szInitalStyle[param1], 128, "Slow Motion");
			Format(g_szStyleHud[param1], 32, "[SM]");
			SetEntPropFloat(param1, Prop_Data, "m_flLaggedMovementValue", 0.5);
			g_bRankedStyle[param1] = false;
			g_bFunStyle[param1] = true;
		}
		else if(StrContains(info, "6", false)!= -1)
		{
			g_iCurrentStyle[param1] = 6;
			g_iInitalStyle[param1] = 6;
			Format(g_szInitalStyle[param1], 128, "Fast Forward");
			Format(g_szStyleHud[param1], 32, "[FF]");
			SetEntPropFloat(param1, Prop_Data, "m_flLaggedMovementValue", 1.5);
			g_bRankedStyle[param1] = false;
			g_bFunStyle[param1] = true;
		}
		else
		{
			g_iCurrentStyle[param1] = 0;
			g_iInitalStyle[param1] = 0;
			Format(g_szInitalStyle[param1], 128, "Normal");
			Format(g_szStyleHud[param1], 32, "");
			g_bRankedStyle[param1] = true;
			g_bFunStyle[param1] = false;
		}

		Command_Restart(param1, 1);
	}
	else
	{
		if(action == MenuAction_Cancel)
			styleSelectMenu(param1);
		if (action == MenuAction_End)
			CloseHandle(menu);
	}
}

public Action Command_Reportbug(int client, int args)
{
  if(!g_bReportRateLimited[client])
  {
    g_bWaitingForReportTitle[client] = false;
    g_bWaitingForReportMessage[client] = false;
    ReportTypeMenu(client);
  }
  else
    PrintToChat(client, " %cSurfTimer %c| Please wait before submitting another report.", LIMEGREEN, WHITE);
  return;
}

public void ReportTypeMenu(int client)
{
  Menu menu = CreateMenu(ReportTypeMenuHandler);
  SetMenuTitle(menu, "Select a report type:\n------------------------------\n");

  AddMenuItem(menu, "0", "Map Report");
  AddMenuItem(menu, "1", "Surftimer Report");
  AddMenuItem(menu, "2", "Server Report");

  SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
  DisplayMenu(menu, client, MENU_TIME_FOREVER);
  return;
}

public int ReportTypeMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
  if (action == MenuAction_Select)
  {
    char info[32];
    GetMenuItem(menu, param2, info, sizeof(info));
    if(StrContains(info, "0", false) != -1) //map report
    {
      g_ReportType[param1] = 0;
      db_selectMaps(param1);
    }
    else if(StrContains(info, "1", false) != -1) //surftimer Report
    {
      g_ReportType[param1] = 1;
      g_bWaitingForReportTitle[param1] = true;
      g_bWaitingForReportMessage[param1] = false;
      g_szReportMapName[param1] = "none";
    }
    else //server report
    {
      g_ReportType[param1] = 2;
      g_bWaitingForReportTitle[param1] = true;
      g_bWaitingForReportMessage[param1] = false;
      g_szReportMapName[param1] = "none";
    }
    if(g_ReportType[param1] != 0)
      PrintToChat(param1, " %cSurfTimer %c| Type the title of your report", LIMEGREEN, WHITE);
  }
  else
  {
    if (action == MenuAction_End)
    {
      //if (IsValidClient(param1))
      CloseHandle(menu);
    }
  }
}

//rate limiting commands
public void RateLimit(int client)
{
	float currentTime = GetGameTime();
	if(currentTime - g_fCommandLastUsed[client] < 2)
	{
		PrintToChat(client, " %cSurfTimer %c| Please wait before using this command again.", LIMEGREEN, WHITE);
		g_bRateLimit[client] = true;
	}
	else
	{
		g_bRateLimit[client] = false;
	}

	g_fCommandLastUsed[client] = GetGameTime();
}

public Action Command_SelectMapTime(int client, int args)
{
	RateLimit(client);

	if(!g_bRateLimit[client])
	{
		if(args == 0)
		{
			db_selectMapRank(client, g_szSteamID[client], g_szMapName);
			return Plugin_Handled;
		}
		else
		{
			char arg1[128];
			char arg2[128];
			GetCmdArg(1, arg1, sizeof(arg1));
			GetCmdArg(2, arg2, sizeof(arg2));

			//bool bPlayerFound = false;
			char szSteamId2[32];
			char szName[MAX_NAME_LENGTH];

			if(StrContains(arg1[0], "surf_", true) != -1) //if arg1 contains a surf map
			{
				db_selectMapRank(client, g_szSteamID[client], arg1);
				return Plugin_Handled;
			}
			else if(StrContains(arg1, "@", false) != -1) // Rank Number / Group
			{
				int rank;
				ReplaceString(arg1, 128, "@", "", false);
				if(StrContains(arg1, "g", false) != -1) // Group
				{
					ReplaceString(arg1, 128, "g", "", false);
					int group;
					group = StringToInt(arg1);
					if(group == 1)
						rank = g_G1Top;
					else if(group == 2)
						rank = g_G2Top;
					else if(group == 3)
						rank = g_G3Top;
					else if(group == 4)
						rank = g_G4Top;
					else if(group == 5)
						rank = g_G5Top;
				}
				else
					rank = StringToInt(arg1);

				if(!arg2[0])
					db_selectMapRankUnknown(client, g_szMapName, rank);
				else
					db_selectMapRankUnknown(client, arg2, rank);

				return Plugin_Handled;
			}
			else //else it will contain a clients name
			{
				for (int i = 1; i <= MaxClients; i++)
				{
					if (IsValidClient(i))
					{
						GetClientName(i, szName, MAX_NAME_LENGTH);
						StringToUpper(szName);
						StringToUpper(arg1);
						if ((StrContains(szName, arg1) != -1))
						{
							//bPlayerFound = true;
							GetClientAuthId(i, AuthId_Steam2, szSteamId2, MAX_NAME_LENGTH, true);
						}
					}
				}
			}
			if(!arg2[0]) //no 2nd argument
			{
				db_selectMapRank(client, szSteamId2, g_szMapName);
			}
			else
			{
				db_selectMapRank(client, szSteamId2, arg2);
			}
		}
	}

	return Plugin_Handled;
}

public Action Command_SelectBonusTime(int client, int args)
{
	RateLimit(client);

	if(!g_bRateLimit[client])
	{
		if(args == 0)
		{
			if (g_mapZoneGroupCount > 2)
			{
				ReplyToCommand(client, " %cSurfTimer %c| Usage: %csm_brank #b", LIMEGREEN, WHITE, YELLOW);
				return Plugin_Handled;
			}
			else if (g_mapZoneGroupCount == 1)
			{
				ReplyToCommand(client, " %cSurfTimer %c| Bonus not found", LIMEGREEN, WHITE);
				return Plugin_Handled;
			}

			db_selectBonusRank(client, g_szSteamID[client], g_szMapName, 1);
			return Plugin_Handled;
		}
		else
		{
			char arg1[128];
			char arg2[128];
			GetCmdArg(1, arg1, sizeof(arg1));
			GetCmdArg(2, arg2, sizeof(arg2));

			//bool bPlayerFound = false;
			char szSteamId2[32];
			char szName[MAX_NAME_LENGTH];

			/*if(StrContains(arg1[0], "surf_", true) != -1) //if arg1 contains a surf map
			{
				db_selectMapRank(client, g_szSteamID[client], arg1);
				return Plugin_Handled;
			}*/
			if(StrContains(arg1, "#", false) != -1) // bonus number
			{
				ReplaceString(arg1, 128, "#", "", false);
				int bonus = StringToInt(arg1);

				if(!arg2[0]) // no mapname or player name
					db_selectBonusRank(client, g_szSteamID[client], g_szMapName, bonus);
				else
				{
					if (StrContains(arg2, "surf_", false) != -1) // sm_brank #x surf_y
						db_selectBonusRank(client, g_szSteamID[client], arg2, bonus);
					else // sm_brank #x player
					{
						for (int i = 1; i <= MaxClients; i++)
						{
							if (IsValidClient(i))
							{
								GetClientName(i, szName, MAX_NAME_LENGTH);
								StringToUpper(szName);
								StringToUpper(arg2);
								if ((StrContains(szName, arg2) != -1))
								{
									//bPlayerFound = true;
									GetClientAuthId(i, AuthId_Steam2, szSteamId2, MAX_NAME_LENGTH, true);
									break;
								}
							}
						}
						db_selectBonusRank(client, szSteamId2, g_szMapName, bonus);
					}
				}

				return Plugin_Handled;
			}
			else //sm_brank player else it will contain a clients name
			{
				if (g_mapZoneGroupCount > 2)
				{
					ReplyToCommand(client, " %cSurfTimer %c| Usage: %csm_brank #b player", LIMEGREEN, WHITE, YELLOW);
					return Plugin_Handled;
				}
				else if (g_mapZoneGroupCount == 1)
				{
					ReplyToCommand(client, " %cSurfTimer %c| Bonus not found", LIMEGREEN, WHITE);
					return Plugin_Handled;
				}

				for (int i = 1; i <= MaxClients; i++)
				{
					if (IsValidClient(i))
					{
						GetClientName(i, szName, MAX_NAME_LENGTH);
						StringToUpper(szName);
						StringToUpper(arg1);
						if ((StrContains(szName, arg1) != -1))
						{
							//bPlayerFound = true;
							GetClientAuthId(i, AuthId_Steam2, szSteamId2, MAX_NAME_LENGTH, true);
							break;
						}
					}
				}
			}
			db_selectBonusRank(client, szSteamId2, g_szMapName, 1);
		}
	}

	return Plugin_Handled;
}


public Action Command_ToggleTriggers(int client, int args)
{

	if(!g_bZoner[client] && !CheckCommandAccess(client, "", ADMFLAG_CUSTOM2))
		return Plugin_Handled;

	SetConVarFlags(g_hsvCheats, g_flagsSvCheats^(FCVAR_NOTIFY|FCVAR_REPLICATED));
	SetConVarInt(g_hsvCheats, 1, true, false);
	FakeClientCommand(client, "showtriggers_toggle");
	SetConVarInt(g_hsvCheats, 0, true, false);

	PrintToChat(client, " %cSurfTimer %c| Triggers toggled", LIMEGREEN, WHITE);

	return Plugin_Handled;
}

// Get player's own playtime
public Action Command_MyTime(int client, int args)
{
	if(args == 0)
	TimeCommand(client, client);
	else
	{
		char arg1[128];
		char szName[MAX_NAME_LENGTH];
		GetCmdArg(1, arg1, sizeof(arg1));
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i))
			{
				GetClientName(i, szName, MAX_NAME_LENGTH);
				StringToUpper(szName);
				StringToUpper(arg1);
				if ((StrContains(szName, arg1) != -1))
				{
					TimeCommand(client, i);
				}
			}
		}
	}

	return Plugin_Handled;
}

public Action Command_ToggleMapFinish(int client, int args)
{
	if(!g_bToggleMapFinish[client])
	{
		g_bToggleMapFinish[client] = true;
		PrintToChat(client, " %cSurfTimer %c| Map finish is now %cenabled", LIMEGREEN, WHITE, GREEN);
	}
	else
	{
		g_bToggleMapFinish[client] = false;
		PrintToChat(client, " %cSurfTimer %c| Map finish is now %cdisabled", LIMEGREEN, WHITE, DARKRED);
	}

	return Plugin_Handled;
}

public Action Command_Repeat(int client, int args)
{
	if(!g_bRepeat[client])
	{
		g_bRepeat[client] = true;
		PrintToChat(client, " %cSurfTimer %c| Repeat is now %cenabled", LIMEGREEN, WHITE, GREEN);
	}
	else
	{
		g_bRepeat[client] = false;
		PrintToChat(client, " %cSurfTimer %c| Map Repeat is now %cdisabled", LIMEGREEN, WHITE, DARKRED);
	}

	return Plugin_Handled;
}

public Action Admin_FixBot(int client, int args)
{
	if (g_iVipLvl[client] < 1)
	{
		ReplyToCommand(client, " %cSurfTimer %c| You do not have access to this commnad", LIMEGREEN, WHITE);
		return Plugin_Handled;
	}

	PrintToChat(client, " %cSurfTimer %c| Fixing replay bots", LIMEGREEN, WHITE);
	CreateTimer(5.0, FixBot_Off);
	CreateTimer(10.0, FixBot_On);

	return Plugin_Handled;
}

public Action Command_GiveKnife(int client, int args)
{
	if(IsPlayerAlive(client)) // client is alive
	{
		GivePlayerItem(client, "weapon_knife");
		PrintToChat(client, " %cSurfTimer %c| You have been given a knife", LIMEGREEN, WHITE);
	}

	return Plugin_Handled;
}

public Action Command_NoclipSpeed(int client, int args)
{
	if(!g_bZoner[client] && !CheckCommandAccess(client, "", ADMFLAG_CUSTOM2))
		return Plugin_Handled;

	if(args == 0)
	{
		PrintToChat(client, " %cSurfTimer %c| Usage: sm_noclipspeed #", LIMEGREEN, WHITE);
		return Plugin_Handled;
	}
	else
	{
		char arg1[128];
		GetCmdArg(1, arg1, sizeof(arg1));
		ServerCommand("sv_noclipspeed %s", arg1);
	}

	return Plugin_Handled;
}


public Action Command_SelectRank(int client, int args)
{
	RateLimit(client);

	if(!g_bRateLimit[client])
	{
		if(args == 0) // Self Rank
		{
			db_selectPlayerRank(client, 0, g_szSteamID[client]);
		}
		else
		{
			char arg1[128];
			GetCmdArg(1, arg1, sizeof(arg1));
			if(StrContains(arg1, "@", false) != -1) // Rank Number
			{
				int arg;
				ReplaceString(arg1, 128, "@", "", false);
				arg = StringToInt(arg1);
				db_selectPlayerRank(client, arg, "none");
			}
			else // Player Name
			{
				bool bPlayerFound = false;
				char szName[128];
				for (int i = 1; i <= MaxClients; i++)
				{
					if (IsValidClient(i))
					{
						GetClientName(i, szName, MAX_NAME_LENGTH);
						StringToUpper(szName);
						StringToUpper(arg1);
						if (StrContains(szName, arg1) != -1)
						{
							char szSteamId[32];
							GetClientAuthId(i, AuthId_Steam2, szSteamId, MAX_NAME_LENGTH, true);
							db_selectPlayerRank(i, 0, szSteamId);
							bPlayerFound = true;
							break;
						}
					}
				}
				if (!bPlayerFound)
					db_selectPlayerRankUnknown(client, arg1);
			}
		}
	}

	return Plugin_Handled;
}

public Action Command_MapImprovement(int client, int args)
{
	g_MiType[client] = 0;
	if(args == 0) // Self Rank
		db_selectMapImprovement(client, g_szMapName);
	else
	{
		char arg1[128];
		GetCmdArg(1, arg1, sizeof(arg1));
		db_selectMapImprovement(client, arg1);
	}

	return Plugin_Handled;
}

public Action Command_SpecBot(int client, int args)
{
	if (IsValidClient(client))
	{
		ChangeClientTeam(client, 1);
		SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", g_RecordBot);
		SetEntProp(client, Prop_Send, "m_iObserverMode", 4);
		g_bWrcpTimeractivated[client] = false;
	}

	return Plugin_Handled;
}

public Action Command_SpecBonusBot(int client, int args)
{
	if (IsValidClient(client))
	{
		ChangeClientTeam(client, 1);
		SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", g_BonusBot);
		SetEntProp(client, Prop_Send, "m_iObserverMode", 4);
		g_bWrcpTimeractivated[client] = false;
	}

	return Plugin_Handled;
}

public Action command_test(int client, int args)
{
	g_bShowZones[client] = !g_bShowZones[client];
	if (g_bShowZones[client])
		PrintToChat(client, "true");
	else
		PrintToChat(client, "false");

	return Plugin_Handled;
}

public Action Command_SelectPlayerPr(int client, int args)
{
	if (args == 0)
	{
		g_iPrTarget[client] = client;
		db_viewPlayerPr(client, g_szSteamID[client], g_szMapName);
	}
	else
	{
		char arg1[128];
		char arg1upper[128];
		GetCmdArg(1, arg1, sizeof(arg1));
		char arg2[256];
		char arg2upper[256];
		GetCmdArg(2, arg2, sizeof(arg2));
		char szSteamId2[32];
		char szName[MAX_NAME_LENGTH];
		g_iPrTarget[client] = client;
		if (StrContains(arg1, "surf_")!= -1)
		{
			if(!arg2[0])
				db_viewPlayerPr(client, g_szSteamID[client], arg1);
			else
			{
				bool playerfound = false;

				for (int i = 1; i <= MaxClients; i++)
				{
					if (IsValidClient(i) && !(IsFakeClient(i)))
					{
						GetClientName(i, szName, MAX_NAME_LENGTH);
						StringToUpper(szName);
						Format(arg2upper, 128, "%s", arg2);
						StringToUpper(arg2upper);
						if ((StrContains(szName, arg2upper) != -1))
						{
							g_iPrTarget[client] = i;
							GetClientAuthId(i, AuthId_Steam2, szSteamId2, MAX_NAME_LENGTH, true);
							db_viewPlayerPr(client, szSteamId2, arg1);
							playerfound = true;
							break;
						}
					}
				}

				if (!playerfound)
					PrintToChat(client, " %cSurfTimer %c| Player %c%s %cnot found on %c%s", LIMEGREEN, WHITE, YELLOW, arg2, WHITE, YELLOW, arg1);
			}
		}
		else
		{
			bool playerfound = false;

			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i) && !(IsFakeClient(i)))
				{
					GetClientName(i, szName, MAX_NAME_LENGTH);
					StringToUpper(szName);
					Format(arg1upper, 128, "%s", arg1);
					StringToUpper(arg1upper);
					if ((StrContains(szName, arg1upper) != -1))
					{
						g_iPrTarget[client] = i;
						GetClientAuthId(i, AuthId_Steam2, szSteamId2, MAX_NAME_LENGTH, true);
						db_viewPlayerPr(client, szSteamId2, g_szMapName);
						playerfound = true;
						break;
					}
				}
			}

			if (!playerfound)
			PrintToChat(client, " %cSurfTimer %c| Player %c%s %cnot found", LIMEGREEN, WHITE, YELLOW, arg1, WHITE);
		}
	}

	return Plugin_Handled;
}

public Action Command_ShowZones(int client, int args)
{
	g_bShowZones[client] = !g_bShowZones[client];
	if (g_bShowZones[client])
		ReplyToCommand(client, " %cSurfTimer %c| Zones are now %cvisible", LIMEGREEN, WHITE, GREEN);
	else
		ReplyToCommand(client, " %cSurfTimer %c| Zones are now %chidden", LIMEGREEN, WHITE, DARKRED);

	return Plugin_Handled;
}
