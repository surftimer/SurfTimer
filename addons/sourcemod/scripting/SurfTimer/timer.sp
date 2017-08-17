public Action reloadRank(Handle timer, any client)
{
	if (IsValidClient(client))
		SetPlayerRank(client);
	return Plugin_Handled;
}

public Action reloadConsoleInfo(Handle timer, any client)
{
	if (IsValidClient(client))
		PrintConsoleInfo(client);
	return Plugin_Handled;
}


public Action AnnounceMap(Handle timer, any client)
{
	if (IsValidClient(client))
	{
		PrintToChat(client, g_sTierString[0]);
	}

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

public Action SetPlayerWeapons(Handle timer, any client)
{
	if ((GetClientTeam(client) > 1) && IsValidClient(client))
	{
		StripAllWeapons(client);
		if (!IsFakeClient(client))
			GivePlayerItem(client, "weapon_usp_silencer");
		if (!g_bStartWithUsp[client])
		{
			int weapon;
			weapon = GetPlayerWeaponSlot(client, 2);
			if (weapon != -1 && !IsFakeClient(client))
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon);
		}
	}

	return Plugin_Handled;
}

public Action PlayerRanksTimer(Handle timer)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i) || IsFakeClient(i))
			continue;
		db_GetPlayerRank(i);
	}
	return Plugin_Continue;
}

//
// Recounts players time
//
public Action UpdatePlayerProfile(Handle timer, any client)
{
	if (IsValidClient(client) && !IsFakeClient(client))
		db_updateStat(client);

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
				//1st team join + in-game
				if (g_bFirstTeamJoin[client])
				{
					g_bFirstTeamJoin[client] = false;
					CreateTimer(0.0, StartMsgTimer, client, TIMER_FLAG_NO_MAPCHANGE);
					CreateTimer(10.0, WelcomeMsgTimer, client, TIMER_FLAG_NO_MAPCHANGE);
					CreateTimer(70.0, HelpMsgTimer, client, TIMER_FLAG_NO_MAPCHANGE);
				}
				GetcurrentRunTime(client);

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
				case 1800:PrintToChatAll("%t", "TimeleftMinutes", LIMEGREEN, WHITE, BLUE, g_szMapName, WHITE, MOSSGREEN, timeleft / 60, WHITE);
				case 1200:PrintToChatAll("%t", "TimeleftMinutes", LIMEGREEN, WHITE, BLUE, g_szMapName, WHITE, MOSSGREEN, timeleft / 60, WHITE);
				case 600:PrintToChatAll("%t", "TimeleftMinutes", LIMEGREEN, WHITE, BLUE, g_szMapName,  WHITE, MOSSGREEN, timeleft / 60, WHITE);
				case 300:PrintToChatAll("%t", "TimeleftMinutes", LIMEGREEN, WHITE, BLUE, g_szMapName,  WHITE, MOSSGREEN, timeleft / 60, WHITE);
				case 120:PrintToChatAll("%t", "TimeleftMinutes", LIMEGREEN, WHITE, BLUE, g_szMapName,  WHITE, MOSSGREEN, timeleft / 60, WHITE);
				case 60:PrintToChatAll("%t", "TimeleftSeconds", LIMEGREEN, WHITE, BLUE, g_szMapName,  WHITE, MOSSGREEN, timeleft, WHITE);
				case 30:PrintToChatAll("%t", "TimeleftSeconds", LIMEGREEN, WHITE, BLUE, g_szMapName,  WHITE, MOSSGREEN, timeleft, WHITE);
				case 15:PrintToChatAll("%t", "TimeleftSeconds", LIMEGREEN, WHITE, BLUE, g_szMapName,  WHITE, MOSSGREEN, timeleft, WHITE);
				case  - 1:PrintToChatAll("%t", "TimeleftCounter", LIMEGREEN, WHITE, BLUE, g_szMapName, WHITE, MOSSGREEN, 3, WHITE);
				case  - 2:PrintToChatAll("%t", "TimeleftCounter", LIMEGREEN, WHITE, BLUE, g_szMapName, WHITE, MOSSGREEN, 2, WHITE);
				case  - 3:
				{
					if (!g_bRoundEnd)
					{
						g_bRoundEnd = true;
						ServerCommand("mp_ignore_round_win_conditions 0");
						PrintToChatAll("%t", "TimeleftCounter", LIMEGREEN, WHITE, BLUE, g_szMapName, WHITE, MOSSGREEN, 1, WHITE);
						CreateTimer(1.0, TerminateRoundTimer, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE);
					}
				}
			}
		}
	}

	//info bot name
	SetInfoBotName(g_InfoBot);

	int i;
	for (i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i) || i == g_InfoBot)
			continue;

		//overlay check
		if (g_bOverlay[i] && GetGameTime() - g_fLastOverlay[i] > 5.0)
			g_bOverlay[i] = false;

		//stop replay to prevent server crashes because of a massive recording array (max. 2h)
		if (g_hRecording[i] != null && g_fCurrentRunTime[i] > 6720.0)
		{
			StopRecording(i);
		}

		//Scoreboard
		if (!g_bPause[i])
		{
			float fltime;
			fltime = GetGameTime() - g_fStartTime[i] - g_fPauseTime[i] + 1.0;
			if (IsPlayerAlive(i) && g_bTimeractivated[i])
			{
				int time;
				time = RoundToZero(fltime);
				Client_SetScore(i, time);
			}
			else
			{
				Client_SetScore(i, 0);
			}
			if (!IsFakeClient(i) && !g_pr_Calculating[i])
				CreateTimer(0.0, SetClanTag, i, TIMER_FLAG_NO_MAPCHANGE);
		}

		if (IsPlayerAlive(i))
		{
			//spec hud
			SpecListMenuAlive(i);

			//Last Cords & Angles
			GetClientAbsOrigin(i, g_fPlayerCordsLastPosition[i]);
			GetClientEyeAngles(i, g_fPlayerAnglesLastPosition[i]);
		}
		else
			SpecListMenuDead(i);
	}

	//clean weapons on ground
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
		SaveRecording(client, 0);
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
		SaveRecording(client, zGrp);
	else
		g_bNewBonus[client] = false;


	return Plugin_Handled;
}

public Action SetClanTag(Handle timer, any client)
{
	if (!IsValidClient(client) || IsFakeClient(client) || g_pr_Calculating[client])
		return Plugin_Handled;

	/*char buffer[MAX_NAME_LENGTH];
	if (CS_GetClientClanTag(client, buffer,MAX_NAME_LENGTH) > 0)
		return Plugin_Handled;
	*/
	if (!GetConVarBool(g_hCountry) && !GetConVarBool(g_hPointSystem) && !GetConVarBool(g_hAdminClantag))
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

	/*if (GetConVarBool(g_hCountry))
	{
		Format(tag, 154, "%s | %s", g_szCountryCode[client], g_pr_rankname[client]);
		CS_SetClientClanTag(client, tag);
	}
	else
	{
		if (GetConVarBool(g_hPointSystem) || ((StrEqual(g_pr_rankname[client], "ADMIN", false)) && GetConVarBool(g_hAdminClantag)))
			CS_SetClientClanTag(client, g_pr_rankname[client]);
	}*/

	//fluffys
	if (GetConVarBool(g_hPointSystem) || ((StrEqual(g_pr_rankname[client], "ADMIN", false)) && GetConVarBool(g_hAdminClantag)))
		CS_SetClientClanTag(client, g_pr_rankname[client]);

	//new rank
	if (oldrank && GetConVarBool(g_hPointSystem))
		if (!StrEqual(g_pr_rankname[client], old_pr_rankname, false) && IsValidClient(client))
			CPrintToChat(client, "%t", "SkillGroup", LIMEGREEN, WHITE, GRAY, GRAY, g_pr_chat_coloredrank[client]);

	return Plugin_Handled;
}

public Action TerminateRoundTimer(Handle timer)
{
	CS_TerminateRound(1.0, CSRoundEnd_CTWin, true);
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
		PrintToChat(client, "%t", "HelpMsg", LIMEGREEN, WHITE, GREEN, WHITE);

	return Plugin_Handled;
}


public Action AdvertTimer(Handle timer)
{
	g_Advert++;
	if ((g_Advert % 2) == 0)
	{
		if (g_bhasBonus)
		{
			PrintToChatAll("%t", "AdvertBonus", LIMEGREEN, WHITE, LIMEGREEN, WHITE, MOSSGREEN);
		}
		else if (g_bhasStages)
		{
			PrintToChatAll("%t", "AdvertStage", LIMEGREEN, WHITE, LIMEGREEN, WHITE, LIMEGREEN, WHITE, MOSSGREEN);
		}
	}
	else
	{
		if (g_bhasStages)
		{
			PrintToChatAll("%t", "AdvertStage", LIMEGREEN, WHITE, LIMEGREEN, WHITE, LIMEGREEN, WHITE, MOSSGREEN);
		}
		else if (g_bhasBonus)
		{
			PrintToChatAll("%t", "AdvertBonus", LIMEGREEN, WHITE, LIMEGREEN, WHITE, MOSSGREEN);
		}
	}
	return Plugin_Continue;
}

public Action StartMsgTimer(Handle timer, any client)
{
	if (IsValidClient(client) && !IsFakeClient(client))
	{
		PrintMapRecords(client, 0);
		PrintMapRecords(client, 99);
	}
	return Plugin_Handled;
}

public Action CenterMsgTimer(Handle timer, any client)
{
	if (IsValidClient(client) && !IsFakeClient(client))
	{
		if (g_bRestorePositionMsg[client])
		{
			g_fLastOverlay[client] = GetGameTime();
			g_bOverlay[client] = true;
			//fluffys
			//PrintHintText(client, "%t", "PositionRestored");
		}
		g_bRestorePositionMsg[client] = false;
	}

	return Plugin_Handled;
}

public Action RemoveRagdoll(Handle timer, any victim)
{
	if (IsValidEntity(victim) && !IsPlayerAlive(victim))
	{
		int player_ragdoll;
		player_ragdoll = GetEntDataEnt2(victim, g_ragdolls);
		if (player_ragdoll != -1)
			RemoveEdict(player_ragdoll);
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

		// Crosshair and chat
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

//fluffys
public Action StartJumpZonePrintTimer(Handle timer, any client)
{
	g_bJumpZoneTimer[client] = false;
	return Plugin_Handled;
}


public Action Block2Unload(Handle timer, any client)
{
	ServerCommand("sm plugins unload block2");
}

public Action Block2Load(Handle timer, any client)
{
	ServerCommand("sm plugins load block2");
}

public Action ReportRateLimitTimer(Handle timer, any client)
{
  g_bReportRateLimited[client] = false;
  return;
}

// Replay Bot Fixes

public Action FixBot_Off(Handle timer)
{
	ServerCommand("ck_replay_bot 0");
	ServerCommand("ck_bonus_bot 0");
}

public Action FixBot_On(Handle timer)
{
	ServerCommand("ck_replay_bot 1");
	ServerCommand("ck_bonus_bot 1");
	CPrintToChatAll(" %cSurfTimer %c| Replay bots fixed", LIMEGREEN, WHITE);
}
