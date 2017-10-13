public Action sm_test(int client, int args)
{
	// for (int i = 0; i < 3; i++)
	// 	PrintToChat(client, "g_mapZones[0][PointA][%i]: %f", i, g_mapZones[0][PointA][i]);

	// for (int i = 0; i < 3; i++)
	// 	PrintToChat(client, "g_mapZones[0][PointB][%i]: %f", i, g_mapZones[0][PointB][i]);
	
	// for (int i = 0; i < 7; i++)
	// {
	// 	for (int j = 0; j < 3; j++)
	// 		PrintToChat(client, "g_fZoneCorners[0][%i][%i]: %f", i, j, g_fZoneCorners[0][i][j]);
	// }

	// PrintToChat(client, "g_iSelectedTrigger[client]: %i", g_iSelectedTrigger[client]);

	LoadDefaultTitle(client);

	return Plugin_Handled;
}

public Action Client_GetVelocity(int client, int args)
{
	float CurVelVec[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", CurVelVec);
	PrintToChat(client, "X: %f Y: %f Z: %f", CurVelVec[0], CurVelVec[1], CurVelVec[2]);

	return Plugin_Handled;
}

public Action Client_TargetName(int client, int args)
{
	char szTargetName[128];
	char szClassName[128];
	GetEntPropString(client, Prop_Data, "m_iName", szTargetName, sizeof(szTargetName));
	GetEntityClassname(client, szClassName, 128);
	PrintToChat(client, "TN: %s", szTargetName);
	PrintToChat(client, "CN: %s", szClassName);

	return Plugin_Handled;
}

public Action Command_Vip(int client, int args)
{
	if (!IsPlayerVip(client, 1))
	{
		return Plugin_Handled;
	}
	
	VipMenu(client);
	return Plugin_Handled;
}

public void VipMenu(int client)
{
	Menu menu = CreateMenu(VipMenuHandler);
	SetMenuTitle(menu, "VIP Menu");
	AddMenuItem(menu, "ve", "Vote Extend");
	AddMenuItem(menu, "models", "Player Models");
	if (g_iVipLvl[client] > 1)
	{
		AddMenuItem(menu, "title", "VIP Title");
		AddMenuItem(menu, "paintcolour", "Paint Colour");
	}
	else
	{
		AddMenuItem(menu, "title", "VIP Title", ITEMDRAW_DISABLED);
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
			case 0: VoteExtend(param1);
			case 1: FakeClientCommandEx(param1, "sm_models");
			case 2: CustomTitleMenu(param1);
			case 3: FakeClientCommandEx(param1, "sm_paintcolour");
		}
	}
	else if (action == MenuAction_End)
		CloseHandle(menu);
}

public void CustomTitleMenu(int client)
{
	if (!IsPlayerVip(client, 2))
	{
		return;
	}

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
	if(!IsValidClient(client) || !IsPlayerVip(client, 1))
		return Plugin_Handled;

	VoteExtend(client);
	return Plugin_Handled;
}

public void VoteExtend(int client)
{
	int timeleft;
	GetMapTimeLeft(timeleft);

	if (timeleft > 300)
	{
		PrintToChat(client, " %cSurftimer %c| You may only use vote extend when there is 5 minutes left.", LIMEGREEN, WHITE);
		return;
	}

	if (IsVoteInProgress())
	{
		PrintToChat(client, " %cSurftimer %c| Please wait until the current vote has finished.", LIMEGREEN, WHITE);
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
	CPrintToChatAll(" %cSurftimer %c| Vote to Extend started by %c%s", LIMEGREEN, WHITE, LIMEGREEN, szPlayerName);

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

	float time = GetGameTime();

	if ((time - g_fLastCheckpointMade[client]) < 1.0)
		return Plugin_Handled;

	if (g_iSaveLocCount < MAX_LOCS)
	{
		g_iSaveLocCount++;
		GetClientAbsOrigin(client, g_fSaveLocCoords[g_iSaveLocCount]);
		GetClientEyeAngles(client, g_fSaveLocAngle[g_iSaveLocCount]);
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", g_fSaveLocVel[g_iSaveLocCount]);
		GetEntPropString(client, Prop_Data, "m_iName", g_szSaveLocTargetname[g_iSaveLocCount], sizeof(g_szSaveLocTargetname));
		g_iLastSaveLocIdClient[client] = g_iSaveLocCount;
		PrintToChat(client, " %cSurftimer %c| sm_tele #%d", LIMEGREEN, WHITE, g_iSaveLocCount);

		g_fLastCheckpointMade[client] = GetGameTime();
		g_iSaveLocUnix[g_iSaveLocCount] = GetTime();
		GetClientName(client, g_szSaveLocClientName[g_iSaveLocCount], MAX_NAME_LENGTH);
	}
	else
	{
		PrintToChat(client, " %cSurftimer %c| How did you hit 1024 save locs?", LIMEGREEN, WHITE);
	}

	return Plugin_Handled;
}

// public Action Command_createPlayerCheckpoint(int client, int args)
// {
// 	if (!IsValidClient(client))
// 		return Plugin_Handled;

// 	if (g_iClientInZone[client][0] == 1 || g_iClientInZone[client][0] == 5)
// 	{
// 		PrintToChat(client, "%t", "PracticeInStartZone", LIMEGREEN, WHITE);
// 		return Plugin_Handled;
// 	}

// 	float CheckpointTime = GetGameTime();

// 	// Move old checkpoint to the undo values, if the last checkpoint was made more than a second ago
// 	if (g_bCreatedTeleport[client] && (CheckpointTime - g_fLastPlayerCheckpoint[client]) > 1.0)
// 	{
// 		g_fLastPlayerCheckpoint[client] = CheckpointTime;
// 		Array_Copy(g_fCheckpointLocation[client], g_fCheckpointLocation_undo[client], 3);
// 		Array_Copy(g_fCheckpointVelocity[client], g_fCheckpointVelocity_undo[client], 3);
// 		Array_Copy(g_fCheckpointAngle[client], g_fCheckpointAngle_undo[client], 3);
// 		Format(g_szCheckpointTargetname_undo[client], sizeof(g_szCheckpointTargetname_undo), "%s", g_szCheckpointTargetname[client]);
// 	}

// 	g_bCreatedTeleport[client] = true;
// 	GetClientAbsOrigin(client, g_fCheckpointLocation[client]);
// 	GetEntPropVector(client, Prop_Data, "m_vecVelocity", g_fCheckpointVelocity[client]);
// 	GetClientEyeAngles(client, g_fCheckpointAngle[client]);
// 	GetEntPropString(client, Prop_Data, "m_iName", g_szCheckpointTargetname[client], sizeof(g_szCheckpointTargetname));


// 	PrintToChat(client, "%t", "PracticePointCreated", LIMEGREEN, WHITE, LIMEGREEN, WHITE);

// 	return Plugin_Handled;
// }

public Action Command_goToPlayerCheckpoint(int client, int args)
{
	if (!IsValidClient(client))
		return Plugin_Handled;
	
	if (g_iSaveLocCount > 0)
	{
		if (args == 0)
		{
			int id = g_iLastSaveLocIdClient[client];
			TeleportToSaveloc(client, id);
		}
		else
		{
			char arg[128];
			char firstChar[2];
			GetCmdArg(1, arg, 128);
			Format(firstChar, 2, arg[0]);
			if (!StrEqual(firstChar, "#"))
			{
				PrintToChat(client, " %cSurftimer %c| Usage: sm_tele #id", LIMEGREEN, WHITE);
				return Plugin_Handled;
			}

			ReplaceString(arg, 128, "#", "", false);
			int id = StringToInt(arg);

			if (id < 1 || id > MAX_LOCS - 1 || id > g_iSaveLocCount)
			{
				PrintToChat(client, " %cSurftimer %c| Invalid id", LIMEGREEN, WHITE);
				return Plugin_Handled;
			}

			g_iLastSaveLocIdClient[client] = id;
			TeleportToSaveloc(client, id);
		}
	}
	else
	{
		PrintToChat(client, " %cSurftimer %c| There are no save locs, use sm_saveloc to make one", LIMEGREEN, WHITE);
	}

	return Plugin_Handled;
}

public Action Command_SaveLocList(int client, int args)
{
	if (g_iSaveLocCount < 1)
	{
		PrintToChat(client, " %cSurftimer %c| There are no save locs, use sm_saveloc", LIMEGREEN, WHITE);
		return Plugin_Handled;
	}

	Menu menu = CreateMenu(SaveLocListHandler);
	SetMenuTitle(menu, "Save Locs");
	char szBuffer[128];
	char szItem[256];
	char szId[32];
	int unix;
	for (int i = 1; i <= g_iSaveLocCount; i++)
	{
		unix = GetTime() - g_iSaveLocUnix[i];
		diffForHumans(unix, szBuffer, 128, 1);
		Format(szItem, sizeof(szItem), "#%d - %s - %s", i, g_szSaveLocClientName[i], szBuffer);
		IntToString(i, szId, 32);
		AddMenuItem(menu, szId, szItem);
	}
	SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);

	return Plugin_Handled;
}

public int SaveLocListHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char szId[32];
		GetMenuItem(menu, param2, szId, 32);
		int id = StringToInt(szId);
		PrintToChat(param1, " %cSurftimer %c| Set saveloc id to #%d", LIMEGREEN, WHITE, id);
		TeleportToSaveloc(param1, id);
	}
	else if (action == MenuAction_End)
		CloseHandle(menu);
}

// public Action Command_goToPlayerCheckpoint(int client, int args)
// {
// 	if (!IsValidClient(client))
// 		return Plugin_Handled;

// 	if (g_fCheckpointLocation[client][0] != 0.0 && g_fCheckpointLocation[client][1] != 0.0 && g_fCheckpointLocation[client][2] != 0.0)
// 	{
// 		if (g_bPracticeMode[client] == false)
// 		{
// 			PrintToChat(client, "%t", "PracticeStarted", LIMEGREEN, WHITE, LIMEGREEN, WHITE, LIMEGREEN, WHITE);
// 			PrintToChat(client, "%t", "PracticeStarted2", LIMEGREEN, WHITE, LIMEGREEN, WHITE, LIMEGREEN, WHITE);
// 			g_bPracticeMode[client] = true;
// 		}

// 		//fluffys gravity
// 		if(g_iInitalStyle[client] != 4)
// 			ResetGravity(client);
// 		else //lowgravity
// 			SetEntityGravity(client, 0.5);

// 		CL_OnStartTimerPress(client);
// 		SetEntPropVector(client, Prop_Data, "m_vecVelocity", view_as<float>( { 0.0, 0.0, 0.0 } ));
// 		TeleportEntity(client, g_fCheckpointLocation[client], g_fCheckpointAngle[client], g_fCheckpointVelocity[client]);
// 		g_bWrcpTimeractivated[client] = false;
// 		DispatchKeyValue(client, "targetname", g_szCheckpointTargetname[client]);
// 	}
// 	else
// 		PrintToChat(client, "%t", "PracticeStartError", LIMEGREEN, WHITE, MOSSGREEN);

// 	return Plugin_Handled;
// }

// public Action Command_undoPlayerCheckpoint(int client, int args)
// {
// 	if (!IsValidClient(client))
// 		return Plugin_Handled;

// 	if (g_fCheckpointLocation_undo[client][0] != 0.0 && g_fCheckpointLocation_undo[client][1] != 0.0 && g_fCheckpointLocation_undo[client][2] != 0.0)
// 	{
// 		float tempLocation[3], tempVelocity[3], tempAngle[3];
// 		char tempTargetname[128];

// 		// Location
// 		Array_Copy(g_fCheckpointLocation_undo[client], tempLocation, 3);
// 		Array_Copy(g_fCheckpointLocation[client], g_fCheckpointLocation_undo[client], 3);
// 		Array_Copy(tempLocation, g_fCheckpointLocation[client], 3);

// 		// Velocity
// 		Array_Copy(g_fCheckpointVelocity_undo[client], tempVelocity, 3);
// 		Array_Copy(g_fCheckpointVelocity[client], g_fCheckpointVelocity_undo[client], 3);
// 		Array_Copy(tempVelocity, g_fCheckpointVelocity[client], 3);

// 		// Angle
// 		Array_Copy(g_fCheckpointAngle_undo[client], tempAngle, 3);
// 		Array_Copy(g_fCheckpointAngle[client], g_fCheckpointAngle_undo[client], 3);
// 		Array_Copy(tempAngle, g_fCheckpointAngle[client], 3);

// 		// Targetname
// 		Format(tempTargetname, sizeof(tempTargetname), "%s", g_szCheckpointTargetname_undo[client]);
// 		Format(g_szCheckpointTargetname[client], sizeof(g_szCheckpointTargetname), "%s", g_szCheckpointTargetname_undo);
// 		Format(g_szCheckpointTargetname[client], sizeof(g_szCheckpointTargetname), "%s", tempTargetname);

// 		PrintToChat(client, "%t", "PracticeUndo", LIMEGREEN, WHITE);
// 	}
// 	else
// 		PrintToChat(client, "%t", "PracticeUndoError", LIMEGREEN, WHITE, MOSSGREEN);

// 	return Plugin_Handled;
// }

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
		ZoneMenu(client);
		resetSelection(client);
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
		PrintToChat(client, " %cSurftimer %c| There are no bonuses in this map.", LIMEGREEN, WHITE);
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

	if (g_mapZoneGroupCount < 2)
	{
		PrintToChat(client, " %cSurftimer %c| There are no bonuses in this map", LIMEGREEN, WHITE);
		return Plugin_Handled;
	}

	// If not enough arguments, or there is more than one bonus
	if (args < 1 && g_mapZoneGroupCount > 2) // Tell player to select specific bonus
	{
		/*PrintToChat(client, " %cSurftimer %c| Usage: !b <bonus number>", LIMEGREEN, WHITE);
		if (g_mapZoneGroupCount > 1)
		{
			PrintToChat(client, " %cSurftimer %c| Available bonuses:", LIMEGREEN, WHITE);
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
		g_bUsingStageTeleport[client] = true;
		teleportClient(client, 0, 1, true);
	}
	else
	{
		char arg1[3];
		g_bInStartZone[client] = false;
		g_bUsingStageTeleport[client] = true;
		GetCmdArg(1, arg1, sizeof(arg1));
		int StageId = StringToInt(arg1);
		if (StageId == 3)
		{
			g_bWrcpTimeractivated[client] = false;
			teleportClient(client, 0, 3, true);
			g_Stage[0][client] = 3;
			g_CurrentStage[client] = 3;
			return Plugin_Handled;
		}
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
		ReplyToCommand(client, " %cSurftimer %c| Teleportation to the end zone has been disabled on this server.", LIMEGREEN, WHITE);
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
			PrintToChat(client, " %cSurftimer %c| Are you sure you want to restart your run? Use %c!r%c again to restart.", LIMEGREEN, WHITE, GREEN, WHITE);
			ClientCommand(client, "play ambient/misc/clank4");
			return Plugin_Handled;
		}
	}

	g_bClientRestarting[client] = false;
	//fluffys
	if(g_bPause[client] == true)
		PauseMethod(client);

	if (!g_bTimerEnabled[client])
		g_bTimerEnabled[client] = true;

	g_bWrcpTimeractivated[client] = false;
	g_bInStageZone[client] = false;
	g_bInStartZone[client] = true;

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

void HideChat(int client, bool menu = false)
{
	if (!g_bHideChat[client])
	{
		// Hiding
		if (g_bViewModel[client])
			SetEntProp(client, Prop_Send, "m_iHideHUD", GetEntProp(client, Prop_Send, "m_iHideHUD") | HIDE_RADAR | HIDE_CHAT);
		else
			SetEntProp(client, Prop_Send, "m_iHideHUD", GetEntProp(client, Prop_Send, "m_iHideHUD") | HIDE_RADAR | HIDE_CHAT);
	}
	else
	{
		// Displaying
		if (g_bViewModel[client])
			SetEntProp(client, Prop_Send, "m_iHideHUD", HIDE_RADAR);
		else
			SetEntProp(client, Prop_Send, "m_iHideHUD", HIDE_RADAR);
	}

	g_bHideChat[client] = !g_bHideChat[client];
	if (menu)
		MiscellaneousOptions(client);
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

void HideViewModel(int client, bool menu = false)
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
	if (menu)
		MiscellaneousOptions(client);
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
			PrintToChat(client, " %cSurftimer %c| There are no bonuses in this map.", LIMEGREEN, WHITE);
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
			PrintToChat(client, " %cSurftimer %c| Bonus tiers have not been set on this map.", LIMEGREEN, WHITE);
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
	else if (Client_HasWeapon(client, "weapon_glock"))
	{
		int weapon = Client_GetWeapon(client, "weapon_glock");
		FakeClientCommand(client, "use %s", weapon);
		InstantSwitch(client, weapon);
		FakeClientCommand(client, "drop");
		GivePlayerItem(client, "weapon_usp_silencer");
	}
	else
		GivePlayerItem(client, "weapon_usp_silencer");
	return Plugin_Handled;
}

public Action Client_Glock(int client, int args)
{
	if (!IsValidClient(client) || !IsPlayerAlive(client))
		return Plugin_Handled;

	if ((GetGameTime() - g_flastClientUsp[client]) < 10.0)
		return Plugin_Handled;

	g_flastClientUsp[client] = GetGameTime();

	if (Client_HasWeapon(client, "weapon_glock"))
	{
		int weapon = Client_GetWeapon(client, "weapon_glock");
		FakeClientCommand(client, "use %s", weapon);
		InstantSwitch(client, weapon);
	}
	else if (Client_HasWeapon(client, "weapon_hkp2000"))
	{
		int weapon = Client_GetWeapon(client, "weapon_hkp2000");
		FakeClientCommand(client, "use %s", weapon);
		InstantSwitch(client, weapon);
		FakeClientCommand(client, "drop");
		GivePlayerItem(client, "weapon_glock");
	}
	else
		GivePlayerItem(client, "weapon_glock");
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

	if(g_bTimerEnabled[client])
		{
			g_bTimerEnabled[client] = !g_bTimerEnabled[client];
			PrintToChat(client, " %cSurftimer %c| Noclip enabled, timer %cdisabled", LIMEGREEN, WHITE, DARKRED);
		}

	Action_NoClip(client);

	return Plugin_Handled;
}

public Action UnNoClip(int client, int args)
{

	if(!g_bTimerEnabled[client])
	{
		PrintToChat(client, " %cSurftimer %c| Noclip disabled, use %c!surftimer %cto re-enable your timer", LIMEGREEN, WHITE, GREEN, WHITE);
	}

	if (g_bNoClip[client] == true)
		Action_UnNoClip(client);

	if (g_iInitalStyle[client] != 4 && IsValidClient(client))
		ResetGravity(client);
	else
		SetEntityGravity(client, 0.5);

	return Plugin_Handled;
}

public Action Command_ckNoClip(int client, int args)
{
	if(!IsValidClient(client))
		return Plugin_Handled;

	if (g_bTimerEnabled[client])
		g_bTimerEnabled[client] = false;

	if(!IsPlayerAlive(client))
	{
		ReplyToCommand(client, " %cSurftimer %c| You cannot use NoClip while you are dead", LIMEGREEN, WHITE);
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
				PrintToChat(client, " %cSurftimer %c| No bonus found on this map.", LIMEGREEN, WHITE);
				PrintToChat(client, " %cSurftimer %c| Usage: !btop <bonus id> <mapname>", LIMEGREEN, WHITE);
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
					PrintToChat(client, " %cSurftimer %c| Invalid bonus ID %i.", LIMEGREEN, WHITE, zGrp);
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
				PrintToChat(client, " %cSurftimer %c| Invalid bonus ID %i.", LIMEGREEN, WHITE, zGrp);
				return Plugin_Handled;
			}
		}
		default: {
			PrintToChat(client, " %cSurftimer %c| Usage: !btop <bonus id> <mapname>", LIMEGREEN, WHITE);
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
				PrintToChat(client, " %cSurftimer %c| No bonus found on this map.", LIMEGREEN, WHITE);
				PrintToChat(client, " %cSurftimer %c| Usage: !btop <bonus id> <mapname>", LIMEGREEN, WHITE);
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
					PrintToChat(client, " %cSurftimer %c| Invalid bonus ID %i.", LIMEGREEN, WHITE, zGrp);
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
				PrintToChat(client, " %cSurftimer %c| Invalid bonus ID %i.", LIMEGREEN, WHITE, zGrp);
				return Plugin_Handled;
			}
		}
		default: {
			PrintToChat(client, " %cSurftimer %c| Usage: !btop <bonus id> <mapname>", LIMEGREEN, WHITE);
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
			SetMenuTitle(menu, "Spec menu (press 'm' to rejoin a team!)\n------------------------------------------------------------\n");
		else
			SetMenuTitle(menu, "Spec menu \n------------------------------\n");
		int playerCount = 0;

		//add replay bots
		if (g_RecordBot != -1)
		{
			if (g_RecordBot != -1 && IsValidClient(g_RecordBot) && IsPlayerAlive(g_RecordBot))
			{
				Format(szPlayerName2, 256, "Map Replay (%s)", g_szReplayTime);
				AddMenuItem(menu, "MAP RECORD REPLAY", szPlayerName2);
				playerCount++;
			}
		}
		if (g_BonusBot != -1)
		{
			if (g_BonusBot != -1 && IsValidClient(g_BonusBot) && IsPlayerAlive(g_BonusBot))
			{
				Format(szPlayerName2, 256, "Bonus Replay (%s)", g_szBonusTime);
				AddMenuItem(menu, "BONUS RECORD REPLAY", szPlayerName2);
				playerCount++;
			}
		}
		if (g_WrcpBot != -1 && g_bhasStages)
		{
			if (g_WrcpBot != -1 && IsValidClient(g_WrcpBot) && IsPlayerAlive(g_WrcpBot))
			{
				Format(szPlayerName2, 256, "Stage %i Replay (%s)", g_StageReplayCurrentStage, g_szWrcpReplayTime[g_StageReplayCurrentStage]);
				AddMenuItem(menu, "STAGE RECORD REPLAY", szPlayerName2);
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
					if (i == g_WrcpBot)
						Format(szPlayerName, MAX_NAME_LENGTH, "STAGE RECORD REPLAY");
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
		SetMenuTitle(menu, "Profile Menu\n------------------------------\n");
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

//fluffys Kismet
public Action Client_ToggleTimer(int client, int args)
{
	ToggleTimer(client);
	if (!g_bTimerEnabled[client])
		PrintToChat(client, "%cSurftimer %c| Timer %cdisabled.", LIMEGREEN, WHITE, DARKRED);
	else
		PrintToChat(client, "%cSurftimer %c| Timer %cenabled.", LIMEGREEN, WHITE, GREEN);
	return Plugin_Handled;
}

public void ToggleTimer(int client)
{
	g_bTimerEnabled[client] = !g_bTimerEnabled[client];
	Client_Stop(client, 1);

	if(g_bTimerEnabled[client] || g_bTimerEnabled[client] && g_bNoClip[client])
	{
		Action_UnNoClip(client);
		Command_Restart(client, 1);
	}

}

void SpeedGradient(int client, bool menu = false)
{
	if (g_SpeedGradient[client] != 3)
		g_SpeedGradient[client]++;
	else
		g_SpeedGradient[client] = 0;

	if (menu)
		MiscellaneousOptions(client);
}

void SpeedMode(int client, bool menu = false)
{
	if (g_SpeedMode[client] != 2)
		g_SpeedMode[client]++;
	else
		g_SpeedMode[client] = 0;
	
	if (menu)
		MiscellaneousOptions(client);
}

void CenterSpeedDisplay(int client, bool menu = false)
{
	g_bCenterSpeedDisplay[client] = !g_bCenterSpeedDisplay[client];
	
	if (g_bCenterSpeedDisplay[client])
	{
		SetHudTextParams(-1.0, 0.30, 1.0, 255, 255, 255, 255, 0, 0.25, 0.0, 0.0);
		CreateTimer(0.1, CenterSpeedDisplayTimer, client, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	}

	if (menu)
		MiscellaneousOptions(client);
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

void HideMethod(int client, bool menu = false)
{
	g_bHide[client] = !g_bHide[client];
	if (menu)
		MiscellaneousOptions(client);
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
	//HelpPanel(client);
	// taken from adminhelp.sp
	Menu menu = CreateMenu(HelpMenuHandler);
	SetMenuTitle(menu, "Help Menu\n \n");
	Handle cmdIter = GetCommandIterator();
	char name[64];
	char desc[255];
	int flags;
	char szCommand[320];
	while (ReadCommandIterator(cmdIter, name, sizeof(name), flags, desc, sizeof(desc)))
	{
		if ((StrContains(desc, "[zoner]", false) != -1) && g_bZoner[client])
		{
			char szBuffer[512][2];
			ExplodeString(desc, "[surftimer]", szBuffer, 2, 512, false);
			Format(szCommand, 320, "%s - %s", name, szBuffer[1]);
			AddMenuItem(menu, "", szCommand, ITEMDRAW_DISABLED);
		}
		else if ((StrContains(desc, "[vip]", false) != -1) && g_iVipLvl[client] > 0)
		{
			char szBuffer[512][2];
			ExplodeString(desc, "[surftimer]", szBuffer, 2, 512, false);
			Format(szCommand, 320, "%s - %s", name, szBuffer[1]);
			AddMenuItem(menu, "", szCommand, ITEMDRAW_DISABLED);
		}
		else if ((StrContains(desc, "[surftimer]", false) != -1) && CheckCommandAccess(client, name, flags))
		{
			char szBuffer[512][2];
			ExplodeString(desc, "[surftimer]", szBuffer, 2, 512, false);
			Format(szCommand, 320, "%s - %s", name, szBuffer[1]);
			AddMenuItem(menu, "", szCommand, ITEMDRAW_DISABLED);
		}
	}
	SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

public int HelpMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
		CloseHandle(menu);
}

//old client_ranks
/*public Action Client_Ranks(int client, int args)
{
	if (IsValidClient(client))
	{
		char ChatLine[512];
		Format(ChatLine, 512, " %cSurftimer %c| ", LIMEGREEN, WHITE);
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
		/*PrintToChat(client, " %cSurftimer %c| Unranked (0p) Newbie (1-199p) Learning (200-399p) %cNovice %c(400-599p) %cBeginner %c(600-799p) %cRookie %c(800-999p) %cAverage %c(1000-1499p) %cCasual %c(1500-2999p) %cAdvanced %c(3000p+) %cSkilled %c(Rank 451-500) %cExceptional %c(Rank 351-450)", LIMEGREEN, WHITE, GRAY, WHITE, GRAY, WHITE, YELLOW, WHITE, YELLOW, WHITE, MOSSGREEN, WHITE, MOSSGREEN, WHITE, LIMEGREEN, WHITE, LIMEGREEN, WHITE);

		PrintToChat(client, " %cSurftimer %c| %cAmazing %c(Rank 201-350) %cPro %c(Rank 101-200) %cVeteran %c(Rank 51-100) %cExpert %c(Rank 26-50) %cElite %c(Rank 11-25) %cMaster %c(Rank 4-10) %cLegendary %c(Rank 3) %cGodly %c(Rank 2) %cKing %c(Rank 1) [Custom Rank] (Rank 1-3)", LIMEGREEN, WHITE, GREEN, WHITE, GREEN, WHITE, DARKBLUE, WHITE, DARKBLUE, WHITE, LIGHTBLUE, WHITE, LIGHTBLUE, WHITE, ORANGE, WHITE, PINK, WHITE, LIGHTRED, WHITE, DARKRED, WHITE);*/

		displayRanksMenu(client, 0);

	}
	return Plugin_Handled;
}

public void displayRanksMenu(int client, int args)
{

	Menu menu = CreateMenu(ShowRanksMenuHandler);
	SetMenuTitle(menu, "Rank 1: King [Players Choice]\nRank 2: Godly [Players Choice]\nRank 3: Legendary [Players Choice]\nRank 4-10: Master\nRank 11-25: Elite\nRank 26-50: Expert\nRank 51-100: Veteran\nRank 101-200: Pro\nRank 201-250: Amazing\nRank 251-300 Exceptional\nRank 301-350: Skilled\nRank 351-400: Advanced\nRank 401-450: Casual\nRank 451-500: Average\nRank 501-550: Rookie\nRank 551-600: Beginner\nRank 601-650: Novice\nRank 651-700: Learning\nRank 701-750: Newbie\n0 Points: Unranked");
	AddMenuItem(menu, "", "", ITEMDRAW_SPACER);
	SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
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
		PrintToChat(client, " %cSurftimer %c| You cannot pause with your timer stopped.", LIMEGREEN, WHITE);
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

void QuakeSounds(int client, bool menu = false)
{
	g_bEnableQuakeSounds[client] = !g_bEnableQuakeSounds[client];
	if (menu)
		MiscellaneousOptions(client);
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

	// strafe sync
	g_iGoodGains[client] = 0;
	g_iTotalMeasures[client] = 0;

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
	SetMenuTitle(cktopmenu, "Top Menu\n------------------------------\n");
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
			PrintToChat(client, " %cSurftimer %c| There are no bonuses in this map.", LIMEGREEN, WHITE);
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
	PrintToConsole(client, "settings");
	PrintToConsole(client, "-------------------------------------");
	PrintToChat(client, " %cSurftimer %c| See console for output!", LIMEGREEN, WHITE);
}

public void OptionMenu(int client)
{
	Menu optionmenu = CreateMenu(OptionMenuHandler);
	SetMenuTitle(optionmenu, "Options Menu\n \n");
	// #0
	if (g_bTimerEnabled[client])
		AddMenuItem(optionmenu, "ToggleTimer", "[ON] Toggle Timer\n \n");
	else
		AddMenuItem(optionmenu, "ToggleTimer", "[OFF] Toggle Timer\n \n");
	
	AddMenuItem(optionmenu, "CentreHud", "Centre Hud Options");
	AddMenuItem(optionmenu, "SideHud", "Side Hud Options");
	AddMenuItem(optionmenu, "Miscellaneous", "Miscellaneous Options");

	SetMenuOptionFlags(optionmenu, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(optionmenu, client, MENU_TIME_FOREVER);
}

public int OptionMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0:
			{
				ToggleTimer(param1);
				OptionMenu(param1);
			}
			case 1: CentreHudOptions(param1, 0);
			case 2: SideHudOptions(param1, 0);
			case 3: MiscellaneousOptions(param1);
		}
	}
	else
		if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public void CentreHudOptions(int client, int item)
{
	Menu menu = CreateMenu(CentreHudOptionsHandler);
	SetMenuTitle(menu, "Options Menu - Centre Hud\n \n");

	if (g_bCentreHud[client])
		AddMenuItem(menu, "", "[ON] Centre Hud");
	else
		AddMenuItem(menu, "", "[OFF] Centre Hud");
	
	AddMenuItem(menu, "", "Reset Modules\n \n");

	AddMenuItem(menu, "Top Left Module", "Top Left Module");
	AddMenuItem(menu, "Top Right Module", "Top Right Module\n \n");
	AddMenuItem(menu, "Middle Left Module", "Middle Left Module");
	AddMenuItem(menu, "Middle Right Module", "Middle Right Module\n \n");
	AddMenuItem(menu, "Bottom Left Module", "Bottom Left Module");
	AddMenuItem(menu, "Bottom Right Module", "Bottom Right Module");

	SetMenuExitBackButton(menu, true);

	if (item < 6)
		item = 0;
	else if (item < 12)
		item = 6;
		
	DisplayMenuAtItem(menu, client, item, MENU_TIME_FOREVER);
}

public int CentreHudOptionsHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		if (param2 == 0)
		{
			g_bCentreHud[param1] = !g_bCentreHud[param1];
			CentreHudOptions(param1, 0);
		}
		else if (param2 == 1)
		{
			g_bCentreHud[param1] = true;
			g_iCentreHudModule[param1][0] = 1;
			g_iCentreHudModule[param1][1] = 2;
			g_iCentreHudModule[param1][2] = 3;
			g_iCentreHudModule[param1][3] = 4;
			g_iCentreHudModule[param1][4] = 5;
			g_iCentreHudModule[param1][5] = 6;
			CentreHudOptions(param1, 0);
		}
		else
		{
			char szTitle[128];
			int module;
			GetMenuItem(menu, param2, szTitle, sizeof(szTitle));
			if (StrEqual(szTitle, "Top Left Module"))
				module = 0;
			else if (StrEqual(szTitle, "Top Right Module"))
				module = 1;
			else if (StrEqual(szTitle, "Middle Left Module"))
				module = 2;
			else if (StrEqual(szTitle, "Middle Right Module"))
				module = 3;
			else if (StrEqual(szTitle, "Bottom Left Module"))
				module = 4;
			else if (StrEqual(szTitle, "Bottom Right Module"))
				module = 5;
			else
				module = 0;

			CentreHudModulesMenu(param1, module, szTitle);
		}	
	}
	else if (action == MenuAction_Cancel)
		OptionMenu(param1);
	else if (action == MenuAction_End)
		CloseHandle(menu);
}

public void CentreHudModulesMenu(int client, int module, const char[] szTitle)
{
	Menu menu = CreateMenu(CentreHudModulesMenuHandler);
	char szTitle2[256];
	Format(szTitle2, sizeof(szTitle2), "%s\n \n", szTitle);
	SetMenuTitle(menu, szTitle2);
	
	// Toggle Module
	if (g_iCentreHudModule[client][module] == 0)
		AddMenuItem(menu, szTitle, "[OFF] Toggle Module\n \n");
	else
		AddMenuItem(menu, szTitle, "[ON] Toggle Module\n \n");

	// Timer
	if (g_iCentreHudModule[client][module] == 1)
		AddMenuItem(menu, szTitle, "[ON] Timer");
	else
		AddMenuItem(menu, szTitle, "[OFF] Timer");

	// WR
	if (g_iCentreHudModule[client][module] == 2)
		AddMenuItem(menu, szTitle, "[ON] World Record");
	else
		AddMenuItem(menu, szTitle, "[OFF] World Record");

	// PB
	if (g_iCentreHudModule[client][module] == 3)
		AddMenuItem(menu, szTitle, "[ON] Personal Best");
	else
		AddMenuItem(menu, szTitle, "[OFF] Personal Best");

	// Rank
	if (g_iCentreHudModule[client][module] == 4)
		AddMenuItem(menu, szTitle, "[ON] Rank Display");
	else
		AddMenuItem(menu, szTitle, "[OFF] Rank Display");

	// Stage
	if (g_iCentreHudModule[client][module] == 5)
		AddMenuItem(menu, szTitle, "[ON] Stage Display");
	else
		AddMenuItem(menu, szTitle, "[OFF] Stage Display");

	// Speed
	if (g_iCentreHudModule[client][module] == 6)
		AddMenuItem(menu, szTitle, "[ON] Speed Display");
	else
		AddMenuItem(menu, szTitle, "[OFF] Speed Display");

	// Strafe Sync
	if (g_iCentreHudModule[client][module] == 7)
		AddMenuItem(menu, szTitle, "[ON] Strafe Sync");
	else
		AddMenuItem(menu, szTitle, "[OFF] Strafe Sync");

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int CentreHudModulesMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char szModule[128];
		int module;
		GetMenuItem(menu, param2, szModule, sizeof(szModule));

		if (StrEqual("Top Left Module", szModule))
			module = 0;
		else if (StrEqual("Top Right Module", szModule))
			module = 1;
		else if (StrEqual("Middle Left Module", szModule))
			module = 2;
		else if (StrEqual("Middle Right Module", szModule))
			module = 3;
		else if (StrEqual("Bottom Left Module", szModule))
			module = 4;
		else if (StrEqual("Bottom Right Module", szModule))
			module = 5;
		else
		{
			PrintToChat(param1, " %cSurftimer %c| There was a error when editing your centre hud", LIMEGREEN ,WHITE);
			CloseHandle(menu);
		}
	
		g_iCentreHudModule[param1][module] = param2;
		CentreHudModulesMenu(param1, module, szModule);
	}
	else if (action == MenuAction_Cancel)
		CentreHudOptions(param1, 0);
	else if (action == MenuAction_End)
		CloseHandle(menu);
}

public void SideHudOptions(int client, int item)
{
	Menu menu = CreateMenu(SideHudOptionsHandler);
	SetMenuTitle(menu, "Options Menu - Side Hud\n \n");

	AddMenuItem(menu, "Module 1", "Module 1");
	AddMenuItem(menu, "Module 2", "Module 2");
	AddMenuItem(menu, "Module 3", "Moudle 3");
	AddMenuItem(menu, "Module 4", "Module 4");
	AddMenuItem(menu, "Module 5", "Module 5\n \n");

	// Side Hud
	if (g_bSideHud[client])
		AddMenuItem(menu, "", "[ON] Side Hud");
	else
		AddMenuItem(menu, "", "[OFF] Side Hud");
	
	AddMenuItem(menu, "", "How do I get the old spec menu back?");

	SetMenuExitBackButton(menu, true);

	if (item < 6)
		item = 0;
	else if (item < 12)
		item = 6;
		
	DisplayMenuAtItem(menu, client, item, MENU_TIME_FOREVER);
}

public int SideHudOptionsHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		if (param2 == 5)
		{
			g_bSideHud[param1] = !g_bSideHud[param1];
			SideHudOptions(param1, 0);
		}
		else if (param2 == 6)
		{
			PrintToChat(param1, " %cSurftimer %c| Turning on spec list on module 1 and disabling other modules will make the side hud have the old functionality", LIMEGREEN, WHITE);
			SideHudOptions(param1, 6);
		}
		else
		{
			char szTitle[32];
			GetMenuItem(menu, param2, szTitle, sizeof(szTitle));
			SideHudModulesMenu(param1, param2, szTitle);
		}
	}
	else if (action == MenuAction_Cancel)
		OptionMenu(param1);
	else if (action == MenuAction_End)
		CloseHandle(menu);
}

public void SideHudModulesMenu(int client, int module, char[] szTitle)
{
	Menu menu = CreateMenu(SideHudModulesMenuHandler);
	char szTitle2[256];
	Format(szTitle2, sizeof(szTitle2), "%s\n \n", szTitle);
	SetMenuTitle(menu, szTitle2);

	//Format(szPanel, sizeof(szPanel), "Timeleft: %s\n \n%s \nby %s\n \n%s\n%s\n \n%s\nWRCP: %s\nby %s\n \nSpecs (6)\nfluffys\nGrandpa Goose\nJakeey802\nant\nsoda\n...", szTimeleft, szWR, g_szRecordPlayer, szPB, szRank, szStage, szWrcpTime, g_szStageRecordPlayer[stage]);
	
	// Toggle Module
	if (g_iSideHudModule[client][module] == 0)
		AddMenuItem(menu, szTitle, "[OFF] Toggle Module\n \n");
	else
		AddMenuItem(menu, szTitle, "[ON] Toggle Module\n \n");

	// Timeleft
	if (g_iSideHudModule[client][module] == 1)
		AddMenuItem(menu, szTitle, "[ON] Timeleft");
	else
		AddMenuItem(menu, szTitle, "[OFF] Timeleft");

	// WR
	if (g_iSideHudModule[client][module] == 2)
		AddMenuItem(menu, szTitle, "[ON] World Record Info");
	else
		AddMenuItem(menu, szTitle, "[OFF] World Record Info");

	// PB
	if (g_iSideHudModule[client][module] == 3)
		AddMenuItem(menu, szTitle, "[ON] Personal Best Info");
	else
		AddMenuItem(menu, szTitle, "[OFF] Personal Best Info");

	// Stage Info
	if (g_iSideHudModule[client][module] == 4)
		AddMenuItem(menu, szTitle, "[ON] Stage Info");
	else
		AddMenuItem(menu, szTitle, "[OFF] Stage Info");

	// Spec list
	if (g_iSideHudModule[client][module] == 5)
		AddMenuItem(menu, szTitle, "[ON] Spec List");
	else
		AddMenuItem(menu, szTitle, "[OFF] Spec List");

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int SideHudModulesMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char szModule[128];
		int module;
		GetMenuItem(menu, param2, szModule, sizeof(szModule));

		if (StrEqual("Module 1", szModule))
			module = 0;
		else if (StrEqual("Module 2", szModule))
			module = 1;
		else if (StrEqual("Module 3", szModule))
			module = 2;
		else if (StrEqual("Module 4", szModule))
			module = 3;
		else if (StrEqual("Module 5", szModule))
			module = 4;
		else
		{
			PrintToChat(param1, " %cSurftimer %c| There was a error when editing your side hud", LIMEGREEN ,WHITE);
			CloseHandle(menu);
		}
	
		g_iSideHudModule[param1][module] = param2;

		if (g_iSideHudModule[param1][0] == 5 && (g_iSideHudModule[param1][1] == 0 && g_iSideHudModule[param1][2] == 0 && g_iSideHudModule[param1][3] == 0 && g_iSideHudModule[param1][4] == 0))
			g_bSpecListOnly[param1] = true;
		else
			g_bSpecListOnly[param1] = false;

		SideHudModulesMenu(param1, module, szModule);
	}
	else if (action == MenuAction_Cancel)
		SideHudOptions(param1, 0);
	else if (action == MenuAction_End)
		CloseHandle(menu);
}

public void MiscellaneousOptions(int client)
{
	Menu menu = CreateMenu(MiscellaneousOptionsHandler);
	SetMenuTitle(menu, "Options Menu - Miscellaneous\n \n");

	// Hide
	if (g_bHide[client])
		AddMenuItem(menu, "", "[ON] Hide Players");
	else
		AddMenuItem(menu, "", "[OFF] Hide Players");

	// Timer Sounds
	if (g_bEnableQuakeSounds[client])
		AddMenuItem(menu, "", "[ON] Timer Sounds");
	else
		AddMenuItem(menu, "", "[OFF] Timer Sounds");
	
	// Hide Weapon
	if (g_bViewModel[client])
		AddMenuItem(menu, "", "[OFF] Hide Weapon");
	else
		AddMenuItem(menu, "", "[ON] Hide Weapon");

	// Speed Gradient
	if (g_SpeedGradient[client] == 0)
		AddMenuItem(menu, "", "[WHITE] Speed Gradient");
	else if (g_SpeedGradient[client] == 1)
		AddMenuItem(menu, "", "[GREEN] Speed Gradient");
	else if (g_SpeedGradient[client] == 2)
		AddMenuItem(menu, "", "[RAINBOW] Speed Gradient");
	else
		AddMenuItem(menu, "", "[MOMENTUM] Speed Gradient");
	
	// Speed Mode
	if (g_SpeedMode[client] == 0)
		AddMenuItem(menu, "", "[XY] Speed Mode");
	else if (g_SpeedMode[client] == 1)
		AddMenuItem(menu, "", "[XYZ] Speed Mode");
	else
		AddMenuItem(menu, "", "[Z] Speed Mode");

	// Centre Speed Display
	if (g_bCenterSpeedDisplay[client])
		AddMenuItem(menu, "", "[ON] Centre Speed Display");
	else
		AddMenuItem(menu, "", "[OFF] Centre Speed Display");

	// Hide Chat
	if (g_bHideChat[client])
		AddMenuItem(menu, "", "[ON] Hide Chat");
	else
		AddMenuItem(menu, "", "[OFF] Hide Chat");
	
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int MiscellaneousOptionsHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0: HideMethod(param1, true);
			case 1: QuakeSounds(param1, true);
			case 2: HideViewModel(param1, true);
			case 3: SpeedGradient(param1, true);
			case 4: SpeedMode(param1, true);
			case 5: CenterSpeedDisplay(param1, true);
			case 6: HideChat(param1, true);
		}
	}
	else if (action == MenuAction_Cancel)
		OptionMenu(param1);
	else if (action == MenuAction_End)
		CloseHandle(menu);
}

//fluffys
public Action Command_PlayerTitle(int client, int args)
{
	CustomTitleMenu(client);
	return Plugin_Handled;
}

public Action Command_SetDbTitle(int client, int args)
{
	if (!IsValidClient(client))
		return Plugin_Handled;

	if (!IsPlayerVip(client, 2))
	{
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
			PrintToChat(client, " %cSurftimer %c| Usage: sm_mytitle <my cool title>", LIMEGREEN, WHITE);
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
			PrintToChat(client, " %cSurftimer %c| Title too long, Maximum 20 characters. (Not Including colours)", LIMEGREEN, WHITE);

			return Plugin_Handled;
		}
		else if (StrContains(upperArg, "{RED}") != -1)
			ReplaceString(arg, 256, "{red}", "{lightred}", false);
		else if(StrContains(upperArg, "{LIMEGREEN}") != -1)
			ReplaceString(arg, 256, "{limegreen}", "{lime}");
		else if (StrContains(upperArg, "{WHITE}") != -1)
			ReplaceString(arg, 256, "{white}", "{default}", false);

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

public Action Command_JoinMsg(int client, int args)
{
	if (!IsValidClient(client) || !IsPlayerVip(client, 2))
		return Plugin_Handled;
	
	if (args == 0)
	{
		ReplyToCommand(client, " %cSurftimer %c| Usage: sm_joinmsg %c{darkred}my cool {darkblue}join msg%c", LIMEGREEN, WHITE, QUOTE, QUOTE);
		return Plugin_Handled;
	}
	
	char szArg[256];
	GetCmdArg(1, szArg, sizeof(szArg));
	db_setJoinMsg(client, szArg);

	return Plugin_Handled;
}

public Action Command_ToggleTitle(int client, int args)
{
	if (!IsValidClient(client))
		return Plugin_Handled;

	if (!IsPlayerVip(client, 1))
	{
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

	if (!IsPlayerVip(client, 2))
	{
		return Plugin_Handled;
	}

	char arg[128], authSteamId[MAXPLAYERS + 1];
	GetClientAuthId(client, AuthId_Steam2, authSteamId, MAX_NAME_LENGTH, true);

	if (args == 0)
	{
			PrintToChat(client, " %cSurftimer %c| Usage: sm_namecolour {colour}", LIMEGREEN, WHITE);
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

	if (!IsPlayerVip(client, 2))
	{
		return Plugin_Handled;
	}

	char arg[128], authSteamId[MAXPLAYERS + 1];
	GetClientAuthId(client, AuthId_Steam2, authSteamId, MAX_NAME_LENGTH, true);

	if (args == 0)
	{
		PrintToChat(client, " %cSurftimer %c| Usage: sm_textcolour {colour}", LIMEGREEN, WHITE);
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
	PrintToChat(client, " %cSurftimer %c| Available Colours: %c{darkred} %c{lightred} %c{red} %c{green} %c{limegreen} %c{mossgreen} %c{darkblue} %c{lightblue} %c{blue} %c{pink} %c{purple} %c{orange} %c{yellow} %c{darkgrey} %c{grey} %c{white}", LIMEGREEN, WHITE, DARKRED, LIGHTRED, RED, GREEN, LIMEGREEN, MOSSGREEN, DARKBLUE, LIGHTBLUE, BLUE, PINK, PURPLE, ORANGE, YELLOW, DARKGREY, GRAY, WHITE);

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
			PrintToChat(client, " %cSurftimer %c| Map is linear. WRCP Not Available", MOSSGREEN, DARKRED);
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
	if(g_Stage[0][client] <= 1)
		Command_Restart(client, 1);
	else
		teleportClient(client, 0, g_Stage[0][client] - 1, false);

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
				AddMenuItem(styleSelect2, "3", "Backwards");
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

//rate limiting commands
public void RateLimit(int client)
{
	float currentTime = GetGameTime();
	if(currentTime - g_fCommandLastUsed[client] < 2)
	{
		PrintToChat(client, " %cSurftimer %c| Please wait before using this command again.", LIMEGREEN, WHITE);
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

			if (StrContains(arg1[0], "surf_", true) != -1) //if arg1 contains a surf map
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

				if (!arg2[0])
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
				ReplyToCommand(client, " %cSurftimer %c| Usage: %csm_brank #b", LIMEGREEN, WHITE, YELLOW);
				return Plugin_Handled;
			}
			else if (g_mapZoneGroupCount == 1)
			{
				ReplyToCommand(client, " %cSurftimer %c| Bonus not found", LIMEGREEN, WHITE);
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
					ReplyToCommand(client, " %cSurftimer %c| Usage: %csm_brank #b player", LIMEGREEN, WHITE, YELLOW);
					return Plugin_Handled;
				}
				else if (g_mapZoneGroupCount == 1)
				{
					ReplyToCommand(client, " %cSurftimer %c| Bonus not found", LIMEGREEN, WHITE);
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

// Show Triggers https://forums.alliedmods.net/showthread.php?t=290356
public Action Command_ToggleTriggers(int client, int args)
{
	if (!IsPlayerVip(client, 1, true, false))
		return Plugin_Handled;

	g_bShowTriggers[client] = !g_bShowTriggers[client];

	if (g_bShowTriggers[client]) 
		++g_iTriggerTransmitCount;
	else 
		--g_iTriggerTransmitCount;

	PrintToChat(client, " %cSurftimer %c| Triggers toggled", LIMEGREEN, WHITE);

	TransmitTriggers(g_iTriggerTransmitCount > 0);
	return Plugin_Handled;
}

void TransmitTriggers(bool transmit)
{
	// Hook only once
	static bool s_bHooked = false;
	
	// Have we done this before?
	if (s_bHooked == transmit)
		return;
	
	// Loop through entities
	char sBuffer[8];
	int lastEdictInUse = GetEntityCount();
	for (int entity = MaxClients + 1; entity <= lastEdictInUse; ++entity)
	{
		if (!IsValidEdict(entity))
			continue;
		
		// Is this entity a trigger?
		GetEdictClassname(entity, sBuffer, sizeof(sBuffer));
		if (strcmp(sBuffer, "trigger") != 0)
			continue;
		
		// Is this entity's model a VBSP model?
		GetEntPropString(entity, Prop_Data, "m_ModelName", sBuffer, 2);
		if (sBuffer[0] != '*') 
		{
			// The entity must have been created by a plugin and assigned some random model.
			// Skipping in order to avoid console spam.
			continue;
		}
		
		// Get flags
		int effectFlags = GetEntData(entity, g_Offset_m_fEffects);
		int edictFlags = GetEdictFlags(entity);
		
		// Determine whether to transmit or not
		if (transmit) 
		{
			effectFlags &= ~EF_NODRAW;
			edictFlags &= ~FL_EDICT_DONTSEND;
		} 
		else 
		{
			effectFlags |= EF_NODRAW;
			edictFlags |= FL_EDICT_DONTSEND;
		}
		
		// Apply state changes
		SetEntData(entity, g_Offset_m_fEffects, effectFlags);
		ChangeEdictState(entity, g_Offset_m_fEffects);
		SetEdictFlags(entity, edictFlags);
		
		// Should we hook?
		if (transmit)
			SDKHook(entity, SDKHook_SetTransmit, Hook_SetTriggerTransmit);
		else
			SDKUnhook(entity, SDKHook_SetTransmit, Hook_SetTriggerTransmit);
	}
	s_bHooked = transmit;
}

public Action Command_ToggleMapFinish(int client, int args)
{
	if (!g_bToggleMapFinish[client])
	{
		g_bToggleMapFinish[client] = true;
		PrintToChat(client, " %cSurftimer %c| Map finish is now %cenabled", LIMEGREEN, WHITE, GREEN);
	}
	else
	{
		g_bToggleMapFinish[client] = false;
		PrintToChat(client, " %cSurftimer %c| Map finish is now %cdisabled", LIMEGREEN, WHITE, DARKRED);
	}

	return Plugin_Handled;
}

public Action Command_Repeat(int client, int args)
{
	if(!g_bRepeat[client])
	{
		g_bRepeat[client] = true;
		PrintToChat(client, " %cSurftimer %c| Repeat is now %cenabled", LIMEGREEN, WHITE, GREEN);
	}
	else
	{
		g_bRepeat[client] = false;
		PrintToChat(client, " %cSurftimer %c| Map Repeat is now %cdisabled", LIMEGREEN, WHITE, DARKRED);
	}

	return Plugin_Handled;
}

public Action Admin_FixBot(int client, int args)
{
	if (!g_bZoner[client] && !CheckCommandAccess(client, "", ADMFLAG_ROOT))
		return Plugin_Handled;
		
	PrintToChat(client, " %cSurftimer %c| Fixing replay bots", LIMEGREEN, WHITE);
	CreateTimer(5.0, FixBot_Off, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(10.0, FixBot_On, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE);

	return Plugin_Handled;
}

public Action Command_GiveKnife(int client, int args)
{
	if(IsPlayerAlive(client)) // client is alive
	{
		GivePlayerItem(client, "weapon_knife");
		PrintToChat(client, " %cSurftimer %c| You have been given a knife", LIMEGREEN, WHITE);
	}

	return Plugin_Handled;
}

public Action Command_NoclipSpeed(int client, int args)
{
	if (!CheckCommandAccess(client, "", ADMFLAG_CUSTOM2))
		return Plugin_Handled;

	if(args == 0)
	{
		PrintToChat(client, " %cSurftimer %c| Usage: sm_noclipspeed #", LIMEGREEN, WHITE);
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
					PrintToChat(client, " %cSurftimer %c| Player %c%s %cnot found on %c%s", LIMEGREEN, WHITE, YELLOW, arg2, WHITE, YELLOW, arg1);
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
			PrintToChat(client, " %cSurftimer %c| Player %c%s %cnot found", LIMEGREEN, WHITE, YELLOW, arg1, WHITE);
		}
	}

	return Plugin_Handled;
}

public Action Command_ShowZones(int client, int args)
{
	g_bShowZones[client] = !g_bShowZones[client];
	if (g_bShowZones[client])
		ReplyToCommand(client, " %cSurftimer %c| Zones are now %cvisible", LIMEGREEN, WHITE, GREEN);
	else
		ReplyToCommand(client, " %cSurftimer %c| Zones are now %chidden", LIMEGREEN, WHITE, DARKRED);

	return Plugin_Handled;
}

public Action Command_HookZones(int client, int args)
{
	HookZonesMenu(client);
	return Plugin_Handled;
}

public void HookZonesMenu(int client)
{
	if (!(GetUserFlagBits(client) & g_ZoneMenuFlag) && !(GetUserFlagBits(client) & ADMFLAG_ROOT) && !g_bZoner[client])
	{
		PrintToChat(client, " %cSurftimer %c| You don't have access to the zones menu.", LIMEGREEN, WHITE);
		return;
	}
	
	if (g_hTriggerMultiple == null)
	{
		PrintToChat(client, "g_hTriggerMultiple is null!");
		return;
	}

	if (GetArraySize(g_hTriggerMultiple) < 1)
	{
		PrintToChat(client, "No Map Zones found!");
		return;
	}

	DisplayMenu(g_mTriggerMultipleMenu, client, MENU_TIME_FOREVER);
}

public int HookZonesMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			g_iSelectedTrigger[param1] = param2;
			char szTriggerName[128];
			GetMenuItem(menu, param2, szTriggerName, sizeof(szTriggerName));

			Menu menu2 = CreateMenu(HookZoneHandler);
			SetMenuTitle(menu2, szTriggerName);

			char szParam[128];
			IntToString(param2, szParam, sizeof(szParam));
			AddMenuItem(menu2, szParam, "Teleport to zone");
			AddMenuItem(menu2, szParam, "Hook zone");

			SetMenuOptionFlags(menu2, MENUFLAG_BUTTON_EXIT);
			DisplayMenu(menu2, param1, MENU_TIME_FOREVER);
		}
		case MenuAction_Cancel: g_iSelectedTrigger[param1] = -1;
		case MenuAction_End: g_iSelectedTrigger[param1] = -1;
	}
}

public int HookZoneHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char szTriggerIndex[128];
			GetMenuItem(menu, param2, szTriggerIndex, sizeof(szTriggerIndex));
			int index = StringToInt(szTriggerIndex);
			g_iSelectedTrigger[param1] = index;
			switch (param2)
			{
				case 0: // teleport
				{
					int iEnt = GetArrayCell(g_hTriggerMultiple, index);
					float position[3];
					float angles[3];
					GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", position);
					GetClientEyeAngles(param1, angles);
					char szTriggerName[128];
					GetEntPropString(iEnt, Prop_Send, "m_iName", szTriggerName, 128, 0);

					PrintToChat(param1, "Teleporting to %s at %f %f %f", szTriggerName, position[0], position[1], position[2]);

					teleportEntitySafe(param1, position, angles, view_as<float>( { 0.0, 0.0, -100.0 } ), true);
				}
				case 1: // hook zone
				{
					int iEnt = GetArrayCell(g_hTriggerMultiple, index);

					char szTriggerName[128];
					GetEntPropString(iEnt, Prop_Send, "m_iName", szTriggerName, 128, 0);

					char szTitle[256];
					Format(szTitle, 256, "Is %s a map or bonus zone?", szTriggerName);

					Menu menu2 = CreateMenu(HookZoneGroupHandler);
					SetMenuTitle(menu2, szTitle);
					AddMenuItem(menu2, szTriggerIndex, "Map");
					AddMenuItem(menu2, szTriggerIndex, "Bonus");
					SetMenuOptionFlags(menu2, MENUFLAG_BUTTON_EXIT);
					DisplayMenu(menu2, param1, MENU_TIME_FOREVER);
				}
			}
		}
		case MenuAction_Cancel: g_iSelectedTrigger[param1] = -1;
		case MenuAction_End:
		{
			g_iSelectedTrigger[param1] = -1;
			delete menu;
		}
	}
}

public int HookZoneGroupHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char szTriggerIndex[128];
			GetMenuItem(menu, param2, szTriggerIndex, sizeof(szTriggerIndex));
			int index = StringToInt(szTriggerIndex);
			g_iSelectedTrigger[param1] = index;

			switch (param2)
			{
				case 0:
				{
					g_bWaitingForZonegroup[param1] = false;
					g_iZonegroupHook[param1] = 0;
					int iEnt = GetArrayCell(g_hTriggerMultiple, index);

					char szTriggerName[128];
					GetEntPropString(iEnt, Prop_Send, "m_iName", szTriggerName, 128, 0);

					char szTitle[256];
					Format(szTitle, 256, "Set %s as what zone type?", szTriggerName);

					Menu menu2 = CreateMenu(HookZoneTypeHandler);
					SetMenuTitle(menu2, szTitle);
					AddMenuItem(menu2, szTriggerIndex, "Start Zone");
					AddMenuItem(menu2, szTriggerIndex, "Checkpoint Zone");
					AddMenuItem(menu2, szTriggerIndex, "Stage Zone");
					AddMenuItem(menu2, szTriggerIndex, "End Zone");
					SetMenuOptionFlags(menu2, MENUFLAG_BUTTON_EXIT);
					DisplayMenu(menu2, param1, MENU_TIME_FOREVER);
				}
				case 1:
				{
					g_bWaitingForZonegroup[param1] = true;
					PrintToChat(param1, " %cSurftimer %c| Type the bonus number", LIMEGREEN, WHITE);

					int iEnt = GetArrayCell(g_hTriggerMultiple, index);

					char szTriggerName[128];
					GetEntPropString(iEnt, Prop_Send, "m_iName", szTriggerName, 128, 0);

					char szTitle[256];
					Format(szTitle, 256, "Set %s as what zone type?", szTriggerName);

					Menu menu2 = CreateMenu(HookZoneTypeHandler);
					SetMenuTitle(menu2, szTitle);
					AddMenuItem(menu2, szTriggerIndex, "Start Zone");
					AddMenuItem(menu2, szTriggerIndex, "Checkpoint Zone");
					AddMenuItem(menu2, szTriggerIndex, "Stage Zone");
					AddMenuItem(menu2, szTriggerIndex, "End Zone");
					SetMenuOptionFlags(menu2, MENUFLAG_BUTTON_EXIT);
					DisplayMenu(menu2, param1, MENU_TIME_FOREVER);
				}
			}
		}
		case MenuAction_Cancel: g_iSelectedTrigger[param1] = -1;
		case MenuAction_End:
		{
			g_iSelectedTrigger[param1] = -1;
			delete menu;
		}
	}
}

public int HookZoneTypeHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{	
			char szTriggerIndex[128];
			GetMenuItem(menu, param2, szTriggerIndex, sizeof(szTriggerIndex));
			int index = StringToInt(szTriggerIndex);

			int iEnt = GetArrayCell(g_hTriggerMultiple, index);
			char szTriggerName[128];
			GetEntPropString(iEnt, Prop_Send, "m_iName", szTriggerName, 128, 0);

			if (g_bWaitingForZonegroup[param1])
			{
				PrintToChat(param1, " %cSurftimer %c| Type a bonus number first", LIMEGREEN, WHITE);

				char szTitle[256];
				Format(szTitle, 256, "Set %s as what zone type?", szTriggerName);

				Menu menu2 = CreateMenu(HookZoneTypeHandler);
				SetMenuTitle(menu2, szTitle);
				AddMenuItem(menu2, szTriggerIndex, "Start Zone");
				AddMenuItem(menu2, szTriggerIndex, "Checkpoint Zone");
				AddMenuItem(menu2, szTriggerIndex, "Stage Zone");
				AddMenuItem(menu2, szTriggerIndex, "End Zone");
				SetMenuOptionFlags(menu2, MENUFLAG_BUTTON_EXIT);
				DisplayMenu(menu2, param1, MENU_TIME_FOREVER);
				return;
			}

			switch (param2)
			{
				case 0: // Start Zone
				{
					//public void db_insertZoneHook(int zoneid, int zonetype, int zonetypeid, float pointax, float pointay, float pointaz, float pointbx, float pointby, float pointbz, int vis, int team, int zonegroup, char[] szHookName)
					db_insertZoneHook(g_mapZonesCount, 1, g_mapZonesTypeCount[0][1], 0, 0, g_iZonegroupHook[param1], szTriggerName);
				}
				case 1: // Checkpoint Zone
				{
					db_insertZoneHook(g_mapZonesCount, 4, g_mapZonesTypeCount[0][4], 0, 0, g_iZonegroupHook[param1], szTriggerName);
				}
				case 2: // Stage Zone
				{
					db_insertZoneHook(g_mapZonesCount, 3, g_mapZonesTypeCount[0][3], 0, 0, g_iZonegroupHook[param1], szTriggerName);
				}
				case 3: // End Zone
				{
					db_insertZoneHook(g_mapZonesCount, 2, g_mapZonesTypeCount[0][2], 0, 0, g_iZonegroupHook[param1], szTriggerName);
				}
			}
		}
		case MenuAction_Cancel: g_iSelectedTrigger[param1] = -1;
		case MenuAction_End:
		{
			g_iSelectedTrigger[param1] = -1;
			delete menu;
		}
	}
}

public Action Client_ShowBans(int client, int args)
{
	if (IsValidClient(client) && !IsFakeClient(client))
		db_selectAllBans(client);
		
	return Plugin_Handled;
}

public Action Client_ShowComms(int client, int args)
{
	if (IsValidClient(client) && !IsFakeClient(client))
		db_selectAllComms(client);
		
	return Plugin_Handled;
}

public Action Command_VoteMute(int client, int args)
{
	if (IsValidClient(client) && !IsFakeClient(client))
	{
		if (!IsPlayerVip(client, 1))
		{
			return Plugin_Handled;
		}

		if (IsVoteInProgress())
		{
			ReplyToCommand(client, " %cSurftimer %c| A vote is already in progress", LIMEGREEN, WHITE);
			return Plugin_Handled;
		}
		CommsVoteMenu(client, 0);
	}
	return Plugin_Handled;
}


public Action Command_VoteGag(int client, int args)
{
	if (IsValidClient(client) && !IsFakeClient(client))
	{
		if (!IsPlayerVip(client, 1))
		{
			return Plugin_Handled;
		}

		if (IsVoteInProgress())
		{
			ReplyToCommand(client, " %cSurftimer %c| A vote is already in progress", LIMEGREEN, WHITE);
			return Plugin_Handled;
		}
		CommsVoteMenu(client, 1);
	}
	return Plugin_Handled;
}

public void CommsVoteMenu(int client, int type)
{
	Menu menu = CreateMenu(CommsVoteMenuHandler);
	if (type == 0)
		SetMenuTitle(menu, "Choose a player to Vote Mute");
	else
		SetMenuTitle(menu, "Choose a player to Vote Gag");

	//add players
	int playerCount = 0;
	char szPlayerName[MAX_NAME_LENGTH];
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && i != client && !IsFakeClient(i))
		{
			GetClientName(i, szPlayerName, MAX_NAME_LENGTH);
			AddMenuItem(menu, szPlayerName, szPlayerName);
			playerCount++;
		}
	}

	if (playerCount > 0)
	{
		g_iCommsVoteType[client] = type;
		SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
		DisplayMenu(menu, client, MENU_TIME_FOREVER);
	}
	else
	{
		PrintToChat(client, " %cSurftimer %c| No players found", LIMEGREEN, WHITE);
	}
}

public int CommsVoteMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		char szPlayerName[MAX_NAME_LENGTH], szName[MAX_NAME_LENGTH];
		GetClientName(param1, szName, MAX_NAME_LENGTH);
		GetMenuItem(menu, param2, info, sizeof(info));
		
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && IsPlayerAlive(i) && i != param1)
			{
				GetClientName(i, szPlayerName, MAX_NAME_LENGTH);
				if (StrEqual(info, szPlayerName))
				{
					g_iCommsVoteTarget[param1] = i;
					g_iCommsVoteCaller = param1;
					int type = g_iCommsVoteType[param1];
					char szMenuTitle[128];
					if (type == 0) // Vote Mute
					Format(szMenuTitle, sizeof(szMenuTitle), "Mute %s?", szPlayerName);
					else
					Format(szMenuTitle, sizeof(szMenuTitle), "Gag %s?", szPlayerName);
					
					Menu menu2 = CreateMenu(CommsVoteHandle);
					SetMenuTitle(menu2, szMenuTitle);
					AddMenuItem(menu2, "yes", "Yes");
					AddMenuItem(menu2, "no", "No");
					SetMenuExitButton(menu2, false);
					VoteMenuToAll(menu2, 20);
					
					if (type == 0)
					CPrintToChatAll(" %cSurftimer %c| Vote to mute %c%s %cstarted by %c%s", LIMEGREEN, WHITE, YELLOW, szPlayerName, WHITE, YELLOW, szName);
					else
					CPrintToChatAll(" %cSurftimer %c| Vote to gag %c%s %cstarted by %c%s", LIMEGREEN, WHITE, YELLOW, szPlayerName, WHITE, YELLOW, szName);
					
					break;
				}
			}
		}
	}
	else if (action == MenuAction_End)
	CloseHandle(menu);
}

public int CommsVoteHandle(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_VoteEnd)
	{
		char item[64], display[64];
		float percent, limit;
		int votes, totalVotes;
		
		menu.GetItem(param1, item, sizeof(item), _, display, sizeof(display));
		GetMenuVoteInfo(param2, votes, totalVotes);
		
		if (strcmp(item, VOTE_NO) == 0 && param1 == 1)
		votes = totalVotes - votes;
		
		percent = FloatDiv(float(votes),float(totalVotes));
		limit = 0.75;
		
		/* 0=yes, 1=no */
		if ((strcmp(item, VOTE_YES) == 0 && FloatCompare(percent,limit) < 0 && param1 == 0) || (strcmp(item, VOTE_NO) == 0 && param1 == 1))
		{
			PrintToChatAll(" %cSurftimer %c| Vote failed. %i%c vote required. (Received %i%c of %i votes)", LIMEGREEN, WHITE, RoundToNearest(100.0*limit), PERCENT, RoundToNearest(100.0*percent), PERCENT, totalVotes);
		}
		else
		{
			int client = g_iCommsVoteCaller;
			int type = g_iCommsVoteType[client];
			int target = g_iCommsVoteTarget[client];
			char szReason[512], szName[MAX_NAME_LENGTH], szSteamID[32], szTargetName[MAX_NAME_LENGTH];
			GetClientName(client, szName, MAX_NAME_LENGTH);
			GetClientName(target, szTargetName, MAX_NAME_LENGTH);
			GetClientAuthId(client, AuthId_Steam2, szSteamID, 32, true);
			if (type == 0) // Vote Mute
			{
				PrintToChatAll(" %cSurftimer %c| Vote successful, muting %c%s%c. (Received %i%c of %i votes)", LIMEGREEN, WHITE, YELLOW, szTargetName, WHITE, RoundToNearest(100.0*percent), PERCENT, totalVotes);
				Format(szReason, sizeof(szReason), "Muted via vote mute started by %s - %s", szName, szSteamID);
				SourceComms_SetClientMute(target, true, 10, true, szReason);
			}
			else // Vote Gag
			{
				PrintToChatAll(" %cSurftimer %c| Vote successful, gagging %c%s%c. (Received %i%c of %i votes)", LIMEGREEN, WHITE, YELLOW, szTargetName, WHITE, RoundToNearest(100.0*percent), PERCENT, totalVotes);
				Format(szReason, sizeof(szReason), "Gagged via vote gag started by %s - %s", szName, szSteamID);
				SourceComms_SetClientGag(target, true, 10, true, szReason);
			}
		}
	}
	else if (action == MenuAction_End)
	CloseHandle(menu);
}

//Startpos Goose
public Action Command_Startpos(int client, int args)
{
	if (!IsValidClient(client))
		return Plugin_Handled;

	if (g_bTimerEnabled[client])
		Startpos(client);
	else 
		ReplyToCommand(client, " %cSurftimer %c| Your timer must be enabled to use %c!startpos", LIMEGREEN, WHITE, GREEN);

	return Plugin_Handled;
}

public Action Command_ResetStartpos(int client, int args)
{
	if(!IsValidClient(client))
		return Plugin_Handled;

	g_bStartposUsed[client][g_iClientInZone[client][2]] = false;
	ReplyToCommand(client, " %cSurftimer %c| Start position reset", LIMEGREEN, WHITE);

	return Plugin_Handled;
}

public void Startpos(int client)
{
	if (IsPlayerAlive(client) && g_iClientInZone[client][0] == 1 && GetEntityFlags(client) & FL_ONGROUND)
	{
		GetClientAbsOrigin(client, g_fStartposLocation[client][g_iClientInZone[client][2]]);
		GetClientEyeAngles(client, g_fStartposAngle[client][g_iClientInZone[client][2]]);
		g_bStartposUsed[client][g_iClientInZone[client][2]] = true;
		PrintToChat(client, " %cSurftimer %c| New start position saved", MOSSGREEN, WHITE);
	}
	else
	{
		PrintToChat(client, " %cSurftimer %c| You must be in a start zone to use %c!startpos", MOSSGREEN, WHITE, LIMEGREEN);
	}
}

public Action Command_Bug(int client, int args)
{
	ReportBugMenu(client);
	return Plugin_Handled;
}

public void ReportBugMenu(int client)
{
	Menu menu = CreateMenu(ReportBugHandler);
	SetMenuTitle(menu, "Choose a bug type");
	AddMenuItem(menu, "Map Bug", "Map Bug");
	AddMenuItem(menu, "Surftimer Bug", "Surftimer Bug");
	AddMenuItem(menu, "Server Bug", "Server Bug");
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int ReportBugHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		GetMenuItem(menu, param2, g_sBugType[param1], 32);
		g_bWaitingForBugMsg[param1] = true;
		PrintToChat(param1, " %cSurftimer %c| Type your message", LIMEGREEN, WHITE);
	}
	else if (action == MenuAction_End)
		CloseHandle(menu);
}

public Action Command_Calladmin(int client, int args)
{
	g_bWaitingForCAMsg[client] = true;
	PrintToChat(client, " %cSurftimer %c| Type your message", LIMEGREEN, WHITE);
	return Plugin_Handled;
}

public Action Command_CPR(int client, int args)
{
	if (!IsValidClient(client))
		return Plugin_Handled;

	if (args == 0)
	{
		if (g_fPersonalRecord[client] < 1.0)
		{
			ReplyToCommand(client, " %cSurftimer %c| You must complete the map first", LIMEGREEN, WHITE);
			return Plugin_Handled;
		}
		db_selectCPR(client, 1, g_szMapName, "");
	}
	else
	{
		char arg[128];
		GetCmdArg(1, arg, sizeof(arg));
		if (StrContains(arg, "surf_") != -1)
		{
			db_selectCPR(client, 1, arg, "");
		}
		else if (StrContains(arg, "@") != -1)
		{
			ReplaceString(arg, 128, "@", "");
			char arg2[128];
			int rank = StringToInt(arg);
			GetCmdArg(2, arg2, sizeof(arg2));
			if (!arg2[0])
				db_selectCPR(client, rank, g_szMapName, "");
			else
				db_selectCPR(client, rank, arg2, "");
		}
		else
		{
			char szPlayerName[MAX_NAME_LENGTH];
			bool found = false;
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i) && i != client)
				{
					GetClientName(i, szPlayerName, MAX_NAME_LENGTH);
					StringToUpper(szPlayerName);
					if ((StrContains(szPlayerName, arg) != -1))
					{
						found = true;
						db_selectCPR(client, 0, g_szMapName, g_szSteamID[i]);
						break;
					}
				}
			}
			if (!found)
				ReplyToCommand(client, " %cSurftimer %c| Player not found", LIMEGREEN, WHITE);
		}
	}

	return Plugin_Handled;
}

public Action Command_ReloadMap(int client, int args)
{
	ServerCommand("changelevel %s", g_szMapName);
	return Plugin_Handled;
}