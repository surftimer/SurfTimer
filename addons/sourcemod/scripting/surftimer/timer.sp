public Action reloadRank(Handle timer, any client)
{
	if (IsValidClient(client))
		SetPlayerRank(client);
	return Plugin_Handled;
}

public Action AnnounceMap(Handle timer, any client)
{
	if (IsValidClient(client))
		CPrintToChat(client, "%t", "Timer1", g_szChatPrefix, g_sTierString);

	AnnounceTimer[client] = null;
	return Plugin_Handled;
}

public Action RefreshAdminMenu(Handle timer, any client)
{
	if (IsValidEntity(client) && !IsFakeClient(client))
		ckAdminMenu(client);

	return Plugin_Handled;
}

public Action RefreshZoneSettings(Handle timer, any client)
{
	if (IsValidEntity(client) && !IsFakeClient(client))
		ZoneSettings(client);

	return Plugin_Handled;
}

public Action RefreshZonesTimer(Handle timer)
{
	RefreshZones();
	return Plugin_Handled;
}

public Action SetPlayerWeapons(Handle timer, any client)
{
	if ((GetClientTeam(client) > 1) && IsValidClient(client))
	{
		StripAllWeapons(client);
		if (!IsFakeClient(client))
			GivePlayerItem(client, "weapon_usp_silencer");
		int weapon;
		weapon = GetPlayerWeaponSlot(client, 2);
		if (weapon != -1 && !IsFakeClient(client))
			SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon);
	}

	return Plugin_Handled;
}

public Action PlayerRanksTimer(Handle timer)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i) || IsFakeClient(i))
			continue;
		db_GetPlayerRank(i, 0);
	}
	return Plugin_Continue;
}

// Recounts players time
public Action UpdatePlayerProfile(Handle timer, Handle pack)
{
	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	int style = ReadPackCell(pack);

	if (IsValidClient(client) && !IsFakeClient(client))
		db_updateStat(client, style);

	return Plugin_Handled;
}

public Action StartTimer(Handle timer, any client)
{
	if (IsValidClient(client) && !IsFakeClient(client))
		CL_OnStartTimerPress(client);

	return Plugin_Handled;
}

public Action AttackTimer(Handle timer)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i) || IsFakeClient(i))
			continue;

		if (g_AttackCounter[i] > 0)
		{
			if (g_AttackCounter[i] < 5)
				g_AttackCounter[i] = 0;
			else
				g_AttackCounter[i] = g_AttackCounter[i] - 5;
		}
	}
	return Plugin_Continue;
}

public Action CKTimer1(Handle timer)
{
	if (g_bRoundEnd)
		return Plugin_Continue;
	int client;
	for (client = 1; client <= MaxClients; client++)
	{
		if (IsValidClient(client))
		{
			if (IsPlayerAlive(client))
			{
				// 1st team join + in-game
				if (g_bFirstTeamJoin[client])
				{
					g_bFirstTeamJoin[client] = false;
					CreateTimer(10.0, WelcomeMsgTimer, client, TIMER_FLAG_NO_MAPCHANGE);
					CreateTimer(70.0, HelpMsgTimer, client, TIMER_FLAG_NO_MAPCHANGE);
				}

				CenterHudAlive(client);
				MovementCheck(client);
			}
			else
				CenterHudDead(client);
		}
	}
	return Plugin_Continue;
}

public Action DelayedStuff(Handle timer)
{
	if (FileExists("cfg/sourcemod/surftimer/main.cfg"))
		ServerCommand("exec sourcemod/surftimer/main.cfg");
	else
		SetFailState("<SurfTimer> cfg/sourcemod/surftimer/main.cfg not found.");

	return Plugin_Handled;
}

public Action LoadReplaysTimer (Handle timer)
{
	LoadReplays();
	LoadInfoBot();
	return Plugin_Handled;
}

public Action CKTimer2(Handle timer)
{
	if (g_bRoundEnd)
		return Plugin_Continue;

	if (GetConVarBool(g_hMapEnd))
	{
		Handle hTmp;
		hTmp = FindConVar("mp_timelimit");
		int iTimeLimit;
		iTimeLimit = GetConVarInt(hTmp);
		if (hTmp != null)
			CloseHandle(hTmp);
		if (iTimeLimit > 0)
		{
			int timeleft;
			GetMapTimeLeft(timeleft);
			switch (timeleft)
			{
				case 1800:CPrintToChatAll("%t", "TimeleftMinutes", g_szChatPrefix, g_szMapName, timeleft / 60);
				case 1200:CPrintToChatAll("%t", "TimeleftMinutes", g_szChatPrefix, g_szMapName, timeleft / 60);
				case 600:CPrintToChatAll("%t", "TimeleftMinutes", g_szChatPrefix, g_szMapName, timeleft / 60);
				case 300:CPrintToChatAll("%t", "TimeleftMinutes", g_szChatPrefix, g_szMapName, timeleft / 60);
				case 120:CPrintToChatAll("%t", "TimeleftMinutes", g_szChatPrefix, g_szMapName, timeleft / 60);
				case 60:CPrintToChatAll("%t", "TimeleftSeconds", g_szChatPrefix, g_szMapName, timeleft);
				case 30:CPrintToChatAll("%t", "TimeleftSeconds", g_szChatPrefix, g_szMapName, timeleft);
				case 10:CPrintToChatAll("%t", "TimeleftSeconds", g_szChatPrefix, g_szMapName, timeleft);
				case 3:CPrintToChatAll("%s ~~~ MAP ENDING ~~~", g_szChatPrefix);
				case 2:CPrintToChatAll("%s ~~~ MAP ENDING ~~~", g_szChatPrefix);
				case 1:CPrintToChatAll("%s ~~~ MAP ENDING ~~~", g_szChatPrefix);
				case 0:CreateTimer(14.0, ForceNextMap, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE);	
				case -1:
				{
					if (!g_bRoundEnd)
					{
						g_bRoundEnd = true;
						ServerCommand("mp_ignore_round_win_conditions 0");
						char szNextMap[128];
						GetNextMap(szNextMap, 128);
						CreateTimer(1.0, TerminateRoundTimer, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE);
					}
				}
			}

			if (timeleft == 60 || timeleft == 30 || timeleft == 15)
			{
				char szNextMap[128];
				GetNextMap(szNextMap, 128);
				CPrintToChatAll("%t", "Timer2", g_szChatPrefix, szNextMap);
			}
		}
	}

	// info bot name
	SetInfoBotName(g_InfoBot);

	int i;
	for (i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i) || i == g_InfoBot)
			continue;

		// overlay check
		if (g_bOverlay[i] && GetGameTime() - g_fLastOverlay[i] > 5.0)
			g_bOverlay[i] = false;

		// stop replay to prevent server crashes because of a massive recording array (max. 2h)
		if (g_aRecording[i] != null && g_fCurrentRunTime[i] > 6720.0)
		{
			StopRecording(i);
		}

		// Scoreboard
		if (!g_bPause[i])
		{
			if (IsPlayerAlive(i) && g_bTimerRunning[i])
				Client_SetScore(i, RoundToZero(GetClientTickTime(i) - g_fStartTime[i] - g_fPauseTime[i] + 1.0));
			else
				Client_SetScore(i, 0);

			if (g_pr_AllPlayers[0] < g_PlayerRank[i][0] || g_PlayerRank[i][0] == 0)
				CS_SetClientContributionScore(i, -99999);
			else
				CS_SetClientContributionScore(i, -g_PlayerRank[i][0]);

			if (!IsFakeClient(i) && !g_pr_Calculating[i])
				CreateTimer(0.0, SetClanTag, i, TIMER_FLAG_NO_MAPCHANGE);
		}

		if (IsPlayerAlive(i))
		{
			// spec hud
			if (g_bSpecListOnly[i])
				SpecListMenuAlive(i);
			else if (g_bSideHud[i])
				SideHudAlive(i);

			// Last Cords & Angles
			GetClientAbsOrigin(i, g_fPlayerCordsLastPosition[i]);
			GetClientEyeAngles(i, g_fPlayerAnglesLastPosition[i]);
		}
		else
			SpecListMenuDead(i);
	}

	// clean weapons on ground
	int maxEntities;
	maxEntities = GetMaxEntities();
	char classx[20];
	if (GetConVarBool(g_hCleanWeapons))
	{
		int j;
		for (j = MaxClients + 1; j < maxEntities; j++)
		{
			if (IsValidEdict(j) && (GetEntDataEnt2(j, g_ownerOffset) == -1))
			{
				GetEdictClassname(j, classx, sizeof(classx));
				if ((StrContains(classx, "weapon_") != -1) || (StrContains(classx, "item_") != -1))
				{
					AcceptEntityInput(j, "Kill");
				}
			}
		}
	}
	return Plugin_Continue;
}

public Action ReplayTimer(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (IsValidClient(client) && !IsFakeClient(client))
		SaveRecording(client, 0, 0);
	else
		g_bNewReplay[client] = false;


	return Plugin_Handled;
}

public Action BonusReplayTimer(Handle timer, Handle pack)
{
	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	int zGrp = ReadPackCell(pack);

	if (IsValidClient(client) && !IsFakeClient(client))
		SaveRecording(client, zGrp, 0);
	else
		g_bNewBonus[client] = false;


	return Plugin_Handled;
}

public Action StyleReplayTimer(Handle timer, Handle pack)
{
	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	int style = ReadPackCell(pack);

	if (IsValidClient(client) && !IsFakeClient(client))
		SaveRecording(client, 0, style);
	else
		g_bNewReplay[client] = false;

	return Plugin_Handled;
}

public Action StyleBonusReplayTimer(Handle timer, Handle pack)
{
	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	int zGrp = ReadPackCell(pack);
	int style = ReadPackCell(pack);

	if (IsValidClient(client) && !IsFakeClient(client))
		SaveRecording(client, zGrp, style);
	else
		g_bNewBonus[client] = false;


	return Plugin_Handled;
}

public Action SetClanTag(Handle timer, any client)
{
	if (!IsValidClient(client) || IsFakeClient(client) || g_pr_Calculating[client])
		return Plugin_Handled;

	if (!g_hOverrideClantag.BoolValue)
		return Plugin_Handled;

	/*char buffer[MAX_NAME_LENGTH];
	if (CS_GetClientClanTag(client, buffer,MAX_NAME_LENGTH) > 0)
		return Plugin_Handled;
	*/
	if (!GetConVarBool(g_hCountry) && !GetConVarBool(g_hPointSystem))
	{
		CS_SetClientClanTag(client, "");
		return Plugin_Handled;
	}

	char old_pr_rankname[128];
	bool oldrank;
	oldrank = false;
	if (!StrEqual(g_pr_rankname[client], "", false))
	{
		oldrank = true;
		Format(old_pr_rankname, 128, "%s", g_pr_rankname[client]);
	}
	SetPlayerRank(client);

	if (GetConVarBool(g_hCountry))
	{
		char szTabRank[1024], szTabClanTag[1024];
		Format(szTabRank, 1024, "%s", g_pr_chat_coloredrank[client]);
		RemoveColors(szTabRank, 1024);
		Format(szTabClanTag, 1024, "%s | %s", g_szCountryCode[client], szTabRank);
		
		if ((GetUserFlagBits(client) & ADMFLAG_ROOT || GetUserFlagBits(client) & ADMFLAG_GENERIC)) {
			if (GetConVarBool(g_iAdminCountryTags))
				CS_SetClientClanTag(client, szTabRank);
			else 
				CS_SetClientClanTag(client, szTabClanTag);
		} 
		else CS_SetClientClanTag(client, szTabClanTag);
	}
	else
	{
		if (GetConVarBool(g_hPointSystem))
		{
			char szTabRank[1024], szTabClanTag[1024];
			Format(szTabRank, 1024, "%s", g_pr_chat_coloredrank[client]);
			RemoveColors(szTabRank, 1024);
			Format(szTabClanTag, 1024, "%s", szTabRank);
			
			if ((GetUserFlagBits(client) & ADMFLAG_ROOT || GetUserFlagBits(client) & ADMFLAG_GENERIC)) {
				if (GetConVarBool(g_iAdminCountryTags))
					CS_SetClientClanTag(client, szTabRank);
				else 
					CS_SetClientClanTag(client, szTabClanTag);
			} 
			else CS_SetClientClanTag(client, szTabClanTag);
		}
	}

	// new rank
	if (oldrank && GetConVarBool(g_hPointSystem))
		if (!StrEqual(g_pr_rankname[client], old_pr_rankname, false) && IsValidClient(client))
			CPrintToChat(client, "%t", "SkillGroup", g_szChatPrefix, g_pr_chat_coloredrank[client]);

	return Plugin_Handled;
}

public Action ForceNextMap(Handle timer)
{
	char szNextMap[128];
	GetNextMap(szNextMap, 128);
	ServerCommand("changelevel %s", szNextMap);
	return Plugin_Handled;
}


public Action TerminateRoundTimer(Handle timer)
{
	CS_TerminateRound(1.0, CSRoundEnd_CTWin, true);
	bool bSlay = GetConVarBool(g_hSlayOnRoundEnd);
	for (int i = 0; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && !IsFakeClient(i))
		{
			if (bSlay)
				ForcePlayerSuicide(i);
			else
				Client_Stop(i, 1);
		}
	}
	return Plugin_Handled;
}

public Action WelcomeMsgTimer(Handle timer, any client)
{
	char szBuffer[512];
	GetConVarString(g_hWelcomeMsg, szBuffer, 512);
	if (IsValidClient(client) && !IsFakeClient(client) && szBuffer[0])
		CPrintToChat(client, "%s", szBuffer);

	return Plugin_Handled;
}

public Action HelpMsgTimer(Handle timer, any client)
{
	if (IsValidClient(client) && !IsFakeClient(client))
		CPrintToChat(client, "%t", "HelpMsg", g_szChatPrefix);
	return Plugin_Handled;
}

// Shows in game hint to the user
public Action ShowHintsTimer(Handle timer)
{
	char szHint[MAX_HINT_MESSAGES_SIZE];
	char szMessage[512];

	if (g_aHints.Length == 1)
		g_aHints.GetString(0, szHint, sizeof(szHint));
	// Random order
	else if (GetConVarBool(g_bHintsRandomOrder))
	{
		int iNumber;
		// Avoid showing the same hint twice
		while (iNumber == g_iLastHintNumber)
			iNumber = GetRandomInt(0, g_aHints.Length - 1);

		g_iLastHintNumber = iNumber;
		g_aHints.GetString(iNumber, szHint, sizeof(szHint));
	}
	// Fixed order
	else
	{
		g_iLastHintNumber++;
		g_aHints.GetString(g_iLastHintNumber, szHint, sizeof(szHint));

		// Go back to the first hint if the last hint was used
		if (g_iLastHintNumber == g_aHints.Length - 1)
			g_iLastHintNumber = -1;
	}

	// Format and print hint
	Format(szMessage, sizeof(szMessage), "%s %s", g_szChatPrefix, szHint);
	for (int i = 0; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && !IsFakeClient(i) && g_bAllowHints[i])
			CPrintToChat(i, szMessage);
	}

	return Plugin_Continue;
}

public Action CenterMsgTimer(Handle timer, any client)
{
	if (IsValidClient(client) && !IsFakeClient(client))
	{
		if (g_bRestorePositionMsg[client])
		{
			g_fLastOverlay[client] = GetGameTime();
			g_bOverlay[client] = true;
		}
		g_bRestorePositionMsg[client] = false;
	}

	return Plugin_Handled;
}

public Action HideHud(Handle timer, any client)
{
	if (IsValidClient(client) && !IsFakeClient(client))
	{
		SetEntPropEnt(client, Prop_Send, "m_bSpotted", 0);

		// ViewModel
		Client_SetDrawViewModel(client, g_bViewModel[client]);

		// Crosshair and Chat
		if (g_bViewModel[client])
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
	}
	return Plugin_Handled;
}

public Action LoadPlayerSettings(Handle timer)
{
	for (int c = 1; c <= MaxClients; c++)
	{
		if (IsValidClient(c))
			OnClientPutInServer(c);
	}
	return Plugin_Handled;
}

// fluffys
public Action StartJumpZonePrintTimer(Handle timer, any client)
{
	g_bJumpZoneTimer[client] = false;
	return Plugin_Handled;
}


public Action Block2Unload(Handle timer, any client)
{
	ServerCommand("sm plugins unload block2");

	return Plugin_Handled;
}

public Action Block2Load(Handle timer, any client)
{
	ServerCommand("sm plugins load block2");

	return Plugin_Handled;
}

// Replay Bot Fixes

public Action FixBot_Off(Handle timer)
{
	ServerCommand("ck_replay_bot 0");
	ServerCommand("ck_bonus_bot 0");
	ServerCommand("ck_wrcp_bot 0");
	return Plugin_Handled;
}

public Action FixBot_On(Handle timer)
{
	ServerCommand("ck_replay_bot 1");
	ServerCommand("ck_bonus_bot 1");
	ServerCommand("ck_wrcp_bot 1");
	return Plugin_Handled;
}

public Action PlayTimeTimer(Handle timer)
{
	for(int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && !IsFakeClient(i) && IsClientInGame(i))
		{
			int team = GetClientTeam(i);

			if (team == 2 || team == 3)
			{
				g_iPlayTimeAliveSession[i]++;
			}
			else
			{
				g_iPlayTimeSpecSession[i]++;
			}
		}
	}

	return Plugin_Continue;
}

public Action AnnouncementTimer(Handle timer)
{
	if (g_bHasLatestID)
		db_checkAnnouncements();

	return Plugin_Continue;
}

public Action EnableJoinMsgs(Handle timer)
{
	g_bEnableJoinMsgs = true;

	return Plugin_Handled;
}

public Action SetArmsModel(Handle timer, any client)
{
	if (IsValidClient(client) && IsPlayerAlive(client))
	{
		char szBuffer[256];
		GetConVarString(g_hArmModel, szBuffer, 256);
		SetEntPropString(client, Prop_Send, "m_szArmsModel", szBuffer);
	}

	return Plugin_Continue;
}

public Action SpecBot(Handle timer, Handle pack)
{
	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	int bot = ReadPackCell(pack);

	ChangeClientTeam(client, 1);
	SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", bot);
	SetEntProp(client, Prop_Send, "m_iObserverMode", 4);
	g_bWrcpTimeractivated[client] = false;

	return Plugin_Handled;
}

public Action RestartPlayer(Handle timer, any client)
{
	if (IsValidClient(client))
		Command_Restart(client, 1);
	
	return Plugin_Continue;
}

public Action DatabaseUpgrading(Handle timer)
{
	if(!g_tables_converted)
		for(int client = 1; client <= MaxClients; client++)
			if(IsValidClient(client))
				CPrintToChat(client, "Server is still updating database tables, pls wait...");

	return Plugin_Handled;
}
