public Action SayText2(UserMsg msg_id, Handle bf, int[] players, int playersNum, bool reliable, bool init)
{
	if (!reliable)return Plugin_Continue;
	char buffer[25];
	if (GetUserMessageType() == UM_Protobuf)
	{
		PbReadString(bf, "msg_name", buffer, sizeof(buffer));
		if (StrEqual(buffer, "#Cstrike_Name_Change"))
			return Plugin_Handled;
	}
	else
	{
		BfReadChar(bf);
		BfReadChar(bf);
		BfReadString(bf, buffer, sizeof(buffer));

		if (StrEqual(buffer, "#Cstrike_Name_Change"))
			return Plugin_Handled;
	}
	return Plugin_Continue;
}

//attack spam protection
public Action Event_OnFire(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (client > 0 && IsClientInGame(client) && GetConVarBool(g_hAttackSpamProtection))
	{
		char weapon[64];
		GetEventString(event, "weapon", weapon, 64);
		if (StrContains(weapon, "knife", true) == -1 && g_AttackCounter[client] < 41)
		{
			if (g_AttackCounter[client] < 41)
			{
				g_AttackCounter[client]++;
				if (StrContains(weapon, "grenade", true) != -1 || StrContains(weapon, "flash", true) != -1)
				{
					g_AttackCounter[client] = g_AttackCounter[client] + 9;
					if (g_AttackCounter[client] > 41)
						g_AttackCounter[client] = 41;
				}
			}
		}
	}
}

// - PlayerSpawn -
public Action Event_OnPlayerSpawn(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (client != 0)
	{
		g_SpecTarget[client] = -1;
		g_bPause[client] = false;
		g_bFirstTimerStart[client] = true;
		SetEntityMoveType(client, MOVETYPE_WALK);
		SetEntityRenderMode(client, RENDER_NORMAL);
		//fluffys
		g_bInJump[client] = false;
		g_bInDuck[client] = false;

		if(g_iCurrentStyle[client] == 4) //4 low gravity
			SetEntityGravity(client, 0.5);
		else if(g_iCurrentStyle[client] == 5)//5 slowmo
			SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 0.5);
		else if(g_iCurrentStyle[client] == 6)//6 fastforward
			SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.5);

		if(g_iCurrentStyle[client] < 4) //0 normal, 1 hsw, 2 sw, 3 bw
		{
			SetEntityGravity(client, 1.0); //normal gravity
			SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0); //normal speed
		}

		//strip weapons
		if ((GetClientTeam(client) > 1) && IsValidClient(client))
		{
			StripAllWeapons(client);
			if (!IsFakeClient(client))
				GivePlayerItem(client, "weapon_usp_silencer");
			int weapon = GetPlayerWeaponSlot(client, 2);
			if (weapon != -1 && !IsFakeClient(client))
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon);
		}

		//NoBlock
		if (GetConVarBool(g_hCvarNoBlock))
			SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
		else
			SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 5, 4, true);

		//botmimic2
		if (g_hBotMimicsRecord[client] != null && IsFakeClient(client))
		{
			g_BotMimicTick[client] = 0;
			g_CurrentAdditionalTeleportIndex[client] = 0;
		}

		if (IsFakeClient(client))
		{
			if (client == g_InfoBot)
				CS_SetClientClanTag(client, "");
			else if (client == g_RecordBot)
				CS_SetClientClanTag(client, "WR Replay");
			else if (client == g_BonusBot)
				CS_SetClientClanTag(client, "WRB Replay");
			else if (client == g_WrcpBot)
				CS_SetClientClanTag(client, "WRCP Replay");
			
			if (client == g_RecordBot || client == g_BonusBot || client == g_WrcpBot)
			{
				// Disabling noclip, makes the bot bug, look into later
				//SetEntityMoveType(client, MOVETYPE_NOCLIP);
				SetEntityGravity(client, 0.0);
			}

			return Plugin_Continue;
		}

		//change player skin
		if (GetConVarBool(g_hPlayerSkinChange) && (GetClientTeam(client) > 1))
		{
			char szBuffer[256];
			GetConVarString(g_hArmModel, szBuffer, 256);
			SetEntPropString(client, Prop_Send, "m_szArmsModel", szBuffer);

			GetConVarString(g_hPlayerModel, szBuffer, 256);
			SetEntityModel(client, szBuffer);
		}

		//1st spawn & t/ct
		if (g_bFirstSpawn[client] && (GetClientTeam(client) > 1))
		{
			float fLocation[3];
			GetClientAbsOrigin(client, fLocation);
			if (setClientLocation(client, fLocation) == -1)
			{
				g_iClientInZone[client][2] = 0;
				g_bIgnoreZone[client] = false;
			}


			StartRecording(client);
			CreateTimer(1.5, CenterMsgTimer, client, TIMER_FLAG_NO_MAPCHANGE);

			if (g_bCenterSpeedDisplay[client])
			{
				SetHudTextParams(-1.0, 0.30, 1.0, 255, 255, 255, 255, 0, 0.25, 0.0, 0.0);
				CreateTimer(0.1, CenterSpeedDisplayTimer, client, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			}

			g_bFirstSpawn[client] = false;
		}

		//get start pos for challenge
		GetClientAbsOrigin(client, g_fSpawnPosition[client]);

		//restore position
		if (!g_specToStage[client])
		{

			if ((GetClientTeam(client) > 1))
			{
				if (g_bRestorePosition[client])
				{
					g_bPositionRestored[client] = true;
					teleportEntitySafe(client, g_fPlayerCordsRestore[client], g_fPlayerAnglesRestore[client], NULL_VECTOR, false);
					g_bRestorePosition[client] = false;
				}
				else
				{
					if (g_bRespawnPosition[client])
					{
						teleportEntitySafe(client, g_fPlayerCordsRestore[client], g_fPlayerAnglesRestore[client], NULL_VECTOR, false);
						g_bRespawnPosition[client] = false;
					}
					else
					{
						g_bTimeractivated[client] = false;
						g_fStartTime[client] = -1.0;
						g_fCurrentRunTime[client] = -1.0;

						// Spawn client to the start zone.
						if (GetConVarBool(g_hSpawnToStartZone))
							Command_Restart(client, 1);
					}
				}
			}
		}
		else
		{
			Array_Copy(g_fTeleLocation[client], g_fPlayerCordsRestore[client], 3);
			Array_Copy(NULL_VECTOR, g_fPlayerAnglesRestore[client], 3);
			SetEntPropVector(client, Prop_Data, "m_vecVelocity", view_as<float>( { 0.0, 0.0, -100.0 } ));
			teleportEntitySafe(client, g_fTeleLocation[client], NULL_VECTOR, view_as<float>( { 0.0, 0.0, -100.0 } ), false);
			g_specToStage[client] = false;
		}

		//hide radar
		CreateTimer(0.0, HideHud, client, TIMER_FLAG_NO_MAPCHANGE);

		//set clantag
		CreateTimer(1.5, SetClanTag, client, TIMER_FLAG_NO_MAPCHANGE);

		//set speclist
		Format(g_szPlayerPanelText[client], 512, "");

		//get speed & origin
		g_fLastSpeed[client] = GetSpeed(client);
	}
	else if (IsFakeClient(client)) 
	{
		SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
	}
	return Plugin_Continue;
}

public void PlayerSpawn(int client)
{

}

public Action Say_Hook(int client, const char[] command, int argc)
{
	//Call Admin - Own Reason
	if (g_bClientOwnReason[client])
	{
		g_bClientOwnReason[client] = false;
		return Plugin_Continue;
	}

	char sText[1024];
	GetCmdArgString(sText, sizeof(sText));

	StripQuotes(sText);
	TrimString(sText);

	if (IsValidClient(client) && g_ClientRenamingZone[client])
	{
		Admin_renameZone(client, sText);
		return Plugin_Handled;
	}

	if (!GetConVarBool(g_henableChatProcessing))
		return Plugin_Continue;

	if (IsValidClient(client))
	{
		if (client > 0)
			if (BaseComm_IsClientGagged(client))
			return Plugin_Handled;

		//blocked commands
		for (int i = 0; i < sizeof(g_BlockedChatText); i++)
		{
			if (StrEqual(g_BlockedChatText[i], sText, true))
			{

				return Plugin_Handled;
			}
		}

		if (g_bWaitingForBugMsg[client])
		{
			Format(g_sBugMsg[client], sizeof(g_sBugMsg), sText);
			SendBugReport(client);
			g_bWaitingForBugMsg[client] = false;
			return Plugin_Handled;
		}
		else if (g_bWaitingForCAMsg[client])
		{
			CallAdmin(client, sText);
			g_bWaitingForCAMsg[client] = false;
			return Plugin_Handled;
		}
		else if (g_bWaitingForZonegroup[client])
		{
			int zgrp = StringToInt(sText);
			if (zgrp < 1 || zgrp > 35)
			{
				PrintToChat(client, " %cSurftimer %c| Invalid Bonus", LIMEGREEN, WHITE);
				return Plugin_Handled;
			}
			g_iZonegroupHook[client] = zgrp;
			PrintToChat(client, " %cSurftimer %c| Bonus %i to use with hooked zones", LIMEGREEN, WHITE, zgrp);
			g_bWaitingForZonegroup[client] = false;
			return Plugin_Handled;
		}

		// !s and !stage commands
		if (StrContains(sText, "!s", false) == 0 || StrContains(sText, "!stage", false) == 0)
			return Plugin_Handled;

		// !b and !bonus commands
		if (StrContains(sText, "!b", false) == 0 || StrContains(sText, "!bonus", false) == 0)
			return Plugin_Handled;

		// maptier
		if (StrContains(sText, "!map", false) == 0)
		{
			if (CheckCommandAccess(client, "sm_map", ADMFLAG_RESERVATION))
			{
				char mapname[1024];
				mapname = sText;
				ReplaceString(mapname, 1024, "!map ", "", false);
				db_selectMapName(mapname);
			}
			else
				return Plugin_Handled;
		}

		//empty message
		if (StrEqual(sText, " ") || !sText[0])
			return Plugin_Handled;

		if (checkSpam(client))
			return Plugin_Handled;

		parseColorsFromString(sText, 1024);

		/*if(g_bDbCustomTitleInUse[client])
			Format(sText, 1024, "%s%s", g_szTextColoured[client], sText);*/

		//lowercase
		if ((sText[0] == '/') || (sText[0] == '!'))
		{
			if (IsCharUpper(sText[1]))
			{
				for (int i = 0; i <= strlen(sText); ++i)
					sText[i] = CharToLower(sText[i]);
				FakeClientCommand(client, "say %s", sText);
				return Plugin_Handled;
			}
		}

		// hide ! commands
		if (StrContains(sText, "!", false) == 0)
		return Plugin_Handled;

		//chat trigger?
		if ((IsChatTrigger() && sText[0] == '/') || (sText[0] == '@' && (GetUserFlagBits(client) & ADMFLAG_ROOT || GetUserFlagBits(client) & ADMFLAG_GENERIC)))
		{
			return Plugin_Continue;
		}

		char szName[64];
		GetClientName(client, szName, 64);

		//log the chat of the player to the server so that tools such as HLSW/HLSTATX see it and also it remains logged in the log file
		WriteChatLog(client, "say", sText);
		PrintToServer("%s: %s", szName, sText);

		parseColorsFromString(szName, 64);

		if (GetConVarBool(g_hPointSystem) && GetConVarBool(g_hColoredNames) && !g_bDbCustomTitleInUse[client])
			setNameColor(szName, g_rankNameChatColour[client], 64);
		else if (GetConVarBool(g_hPointSystem) && GetConVarBool(g_hColoredNames) && g_bDbCustomTitleInUse[client])
			setNameColor(szName, g_iCustomColours[client][0], 64);
			//fluffys

		if(GetConVarBool(g_hPointSystem) && GetConVarBool(g_hColoredNames) && g_bDbCustomTitleInUse[client] && g_bHasCustomTextColour[client])
			setTextColor(sText, g_iCustomColours[client][1], 1024);

		if (GetClientTeam(client) == 1)
		{
			PrintSpecMessageAll(client);
			return Plugin_Handled;
		}
		else
		{
			char szChatRank[1024];
			Format(szChatRank, 1024, "%s", g_pr_chat_coloredrank[client]);

			if (GetConVarBool(g_hCountry) && (GetConVarBool(g_hPointSystem)))
			{
				if (IsPlayerAlive(client))
					CPrintToChatAll("{green}%s{default} %s {teamcolor}%s{default}: %s", g_szCountryCode[client], szChatRank, szName, sText);
				else
					CPrintToChatAll("*DEAD* {green}%s{default} %s %s{default}: %s", g_szCountryCode[client], szChatRank, szName, sText);
				return Plugin_Handled;
			}
			else
			{
				if (GetConVarBool(g_hPointSystem))
				{
					if (IsPlayerAlive(client))
						CPrintToChatAll("%s {teamcolor}%s{default}: %s", szChatRank, szName, sText);
					else
						CPrintToChatAll("*DEAD* %s %s{default}: %s", szChatRank, szName, sText);
					return Plugin_Handled;
				}
			}
		}
	}
	return Plugin_Continue;
}

public Action Event_OnPlayerTeam(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!IsValidClient(client) || IsFakeClient(client))
		return Plugin_Continue;
	int team = GetEventInt(event, "team");
	if (team == 1)
	{
		SpecListMenuDead(client);
		if (!g_bFirstSpawn[client])
		{
			GetClientAbsOrigin(client, g_fPlayerCordsRestore[client]);
			GetClientEyeAngles(client, g_fPlayerAnglesRestore[client]);
			g_bRespawnPosition[client] = true;
		}
		if (g_bTimeractivated[client])
		{
			g_fStartPauseTime[client] = GetGameTime();
			if (g_fPauseTime[client] > 0.0)
				g_fStartPauseTime[client] = g_fStartPauseTime[client] - g_fPauseTime[client];
		}
		g_bSpectate[client] = true;
		g_bPause[client] = false;
	}
	return Plugin_Continue;
}

public Action Event_PlayerDisconnect(Handle event, const char[] name, bool dontBroadcast)
{
	if (GetConVarBool(g_hDisconnectMsg))
	{
		char szName[64];
		char disconnectReason[64];
		int clientid = GetEventInt(event, "userid");
		int client = GetClientOfUserId(clientid);
		if (!IsValidClient(client) || IsFakeClient(client))
			return Plugin_Handled;
		GetEventString(event, "name", szName, sizeof(szName));
		GetEventString(event, "reason", disconnectReason, sizeof(disconnectReason));
		for (int i = 1; i <= MaxClients; i++)
			if (IsValidClient(i) && i != client && !IsFakeClient(i))
				PrintToChat(i, "%t", "Disconnected1", WHITE, MOSSGREEN, szName, WHITE, disconnectReason);
		return Plugin_Handled;
	}
	else
	{
		SetEventBroadcast(event, true);
		return Plugin_Handled;
	}
}

public Action Hook_SetTransmit(int entity, int client)
{
	if (client != entity && (0 < entity <= MaxClients) && IsValidClient(client))
	{
		if (g_bHide[client] && entity != g_SpecTarget[client])
			return Plugin_Handled;
		else
			if (entity == g_InfoBot && entity != g_SpecTarget[client])
				return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action Event_OnPlayerDeath(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetEventInt(event, "userid");
	if (IsValidClient(client))
	{
		if (!IsFakeClient(client))
		{
			if (g_hRecording[client] != null)
				StopRecording(client);
			CreateTimer(2.0, RemoveRagdoll, client);
		}
		else
			if (g_hBotMimicsRecord[client] != null)
			{
				g_BotMimicTick[client] = 0;
				g_CurrentAdditionalTeleportIndex[client] = 0;
				if (GetClientTeam(client) >= CS_TEAM_T)
					CreateTimer(1.0, RespawnBot, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
			}
	}
	return Plugin_Continue;
}

public Action CS_OnTerminateRound(float &delay, CSRoundEndReason &reason)
{
	if (reason == CSRoundEnd_GameStart)
		return Plugin_Handled;
	int timeleft;
	GetMapTimeLeft(timeleft);
	if (timeleft >= -1 && !GetConVarBool(g_hAllowRoundEndCvar))
		return Plugin_Handled;
	return Plugin_Continue;
}

public Action Event_OnRoundEnd(Handle event, const char[] name, bool dontBroadcast)
{
	g_bRoundEnd = true;
	return Plugin_Continue;
}

public void OnPlayerThink(int entity)
{
	SetEntPropEnt(entity, Prop_Send, "m_bSpotted", 0);
}


// OnRoundRestart
public Action Event_OnRoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	int iEnt;
	for (int i = 0; i < sizeof(EntityList); i++)
	{
		while ((iEnt = FindEntityByClassname(iEnt, EntityList[i])) != -1)
		{
			AcceptEntityInput(iEnt, "Disable");
			AcceptEntityInput(iEnt, "Kill");
		}
	}

	// PushFix by Mev, George, & Blacky
	// https://forums.alliedmods.net/showthread.php?t=267131
	iEnt = -1;
	while ((iEnt = FindEntityByClassname(iEnt, "trigger_push")) != -1)
	{
		SDKHook(iEnt, SDKHook_Touch, OnTouchPushTrigger);
		SDKHook(iEnt, SDKHook_EndTouch, OnEndTouchPushTrigger);
	}

	//fluffys gravity
	iEnt = -1;
	while ((iEnt = FindEntityByClassname(iEnt, "trigger_gravity")) != -1)
	{
		SDKHook(iEnt, SDKHook_EndTouch, OnEndTouchGravityTrigger);
	}

	// Hook zones
	iEnt = -1;
	g_hTriggerMultiple = CreateArray(128);
	while ((iEnt = FindEntityByClassname(iEnt, "trigger_multiple")) != -1)
	{
		PushArrayCell(g_hTriggerMultiple, iEnt);
	}

	// iEnt = -1;
	// while ((iEnt = FindEntityByClassname(iEnt, "trigger_*")) != -1)
	// {
	// 	SDKHook(iEnt, SDKHook_Touch, OnTouchAllTriggers);
	// 	SDKHook(iEnt, SDKHook_EndTouch, OnEndTouchAllTriggers);
	// }

	// Teleport Destinations (goose)
	iEnt = -1;
	g_hDestinations = CreateArray(128);
	while ((iEnt = FindEntityByClassname(iEnt, "info_teleport_destination")) != -1)
		PushArrayCell(g_hDestinations, iEnt);

	RefreshZones();

	g_bRoundEnd = false;
	return Plugin_Continue;
}

public Action OnTouchAllTriggers(int entity, int other)
{
	if (other >= 1 && other <= MaxClients && IsFakeClient(other))
		return Plugin_Handled;
	return Plugin_Continue;
}

public Action OnEndTouchAllTriggers(int entity, int other)
{
	if (other >= 1 && other <= MaxClients && IsFakeClient(other))
		return Plugin_Handled;
	return Plugin_Continue;
}

// PushFix by Mev, George, & Blacky
// https://forums.alliedmods.net/showthread.php?t=267131
public Action OnTouchPushTrigger(int entity, int other)
{
	if (IsValidClient(other) && GetConVarBool(g_hTriggerPushFixEnable) == true)
	{
		if (IsFakeClient(other))
			return Plugin_Handled;
			
		//Takes a new additional teleport to increase acuraccy for bot recordings.
		if (g_hRecording[other] != null && !IsFakeClient(other))
		{
			g_createAdditionalTeleport[other] = true;
		}

		//fluffys
		g_bInPushTrigger[other] = true;

		if (IsValidEntity(entity))
		{
			float m_vecPushDir[3];
			GetEntPropVector(entity, Prop_Data, "m_vecPushDir", m_vecPushDir);
			if (m_vecPushDir[2] == 0.0)
				return Plugin_Continue;
			else
				DoPush(entity, other, m_vecPushDir);
		}
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action OnEndTouchPushTrigger(int entity, int other)
{
	if (IsValidClient(other) && GetConVarBool(g_hTriggerPushFixEnable) == true)
	{
		if (IsFakeClient(other))
			return Plugin_Handled;

		if (IsValidEntity(entity))
		{
			g_bInPushTrigger[other] = false;
		}
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action OnEndTouchGravityTrigger(int entity, int other)
{
	if (IsValidClient(other) && !IsFakeClient(other))
	{
		if(!g_bNoClip[other] && GetConVarBool(g_hGravityFix))
			return Plugin_Handled;
	}
	return Plugin_Continue;
}

// PlayerHurt
public Action Event_OnPlayerHurt(Handle event, const char[] name, bool dontBroadcast)
{
	if (!GetConVarBool(g_hCvarGodMode) && GetConVarInt(g_hAutohealing_Hp) > 0)
	{
		int client = GetClientOfUserId(GetEventInt(event, "userid"));
		int remainingHeatlh = GetEventInt(event, "health");
		if (remainingHeatlh > 0)
		{
			if ((remainingHeatlh + GetConVarInt(g_hAutohealing_Hp)) > 100)
				SetEntData(client, FindSendPropInfo("CBasePlayer", "m_iHealth"), 100);
			else
				SetEntData(client, FindSendPropInfo("CBasePlayer", "m_iHealth"), remainingHeatlh + GetConVarInt(g_hAutohealing_Hp));
		}
	}
	return Plugin_Continue;
}

// PlayerDamage (if godmode 0)
public Action Hook_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (GetConVarBool(g_hCvarGodMode))
	{
		return Plugin_Handled;
	}
	return Plugin_Continue;
}


//thx to TnTSCS (player slap stops timer)
//https://forums.alliedmods.net/showthread.php?t=233966
public Action OnLogAction(Handle source, Identity ident, int client, int target, const char[] message)
{
	if ((1 > target > MaxClients))
		return Plugin_Continue;
	if (IsValidClient(target) && IsPlayerAlive(target) && g_bTimeractivated[target] && !IsFakeClient(target))
	{
		char logtag[PLATFORM_MAX_PATH];
		if (ident == Identity_Plugin)
			GetPluginFilename(source, logtag, sizeof(logtag));
		else
			Format(logtag, sizeof(logtag), "OTHER");

		if ((strcmp("playercommands.smx", logtag, false) == 0) || (strcmp("slap.smx", logtag, false) == 0))
			Client_Stop(target, 0);
	}
	return Plugin_Continue;
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	//fluffys
	if(buttons & IN_JUMP && g_bInJump[client] == true && !g_bInStartZone[client] && !g_bInStageZone[client])
	{
		if(!g_bJumpZoneTimer[client])
		{
			CreateTimer(1.0, StartJumpZonePrintTimer, client);
			PrintToChat(client, "%cSurftimer %c| | You may not jump in this area.");
			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, view_as<float>( { 0.0, 0.0, 0.0} ));
			SetEntPropVector(client, Prop_Data, "m_vecVelocity", view_as<float>( { 0.0, 0.0, 0.0 } ));
			g_bJumpZoneTimer[client] = true;
		}
	}
	else if(buttons & IN_DUCK && g_bInDuck[client] == true)
	{
		PrintToChat(client, "%cSurftimer %c| | You may not crouch in this area.");
	}
	else if(buttons & IN_DUCK && g_bInPushTrigger[client] == true)
	{
		buttons &= ~IN_DUCK;
		g_bInPushTrigger[client] = false;
	}
	else if (g_bInMaxSpeed[client])
	{
		LimitMaxSpeed(client, 2500.0);
	}

	/*------ Styles ------*/
	if(g_iCurrentStyle[client] == 1) 	//Sideways
	{
		if(!g_bInStartZone[client] && !g_bInStageZone[client])
		{
			if (!GetConVarBool(g_hSidewaysBlockKeys))
			{
				if(buttons & IN_MOVELEFT)
				{
					g_iCurrentStyle[client] = 0;
					PrintToChat(client, " %cSurftimer %c| Style set to %cNormal%c, A used.", LIMEGREEN, WHITE, GREEN, WHITE);
				}

				if(buttons & IN_MOVERIGHT)
				{
					g_iCurrentStyle[client] = 0;
					PrintToChat(client, " %cSurftimer %c| Style set to %cNormal%c, D used.", LIMEGREEN, WHITE, GREEN, WHITE);
				}
			}
			else
			{
				if (buttons & IN_MOVELEFT)
				{
					vel[1] = 0.0;
					buttons &= ~IN_MOVELEFT;
				}

				if (buttons & IN_MOVERIGHT)
				{
					vel[1] = 0.0;
					buttons &= ~IN_MOVERIGHT;
				}
			}
		}
	}
	else if(g_iCurrentStyle[client] == 2) // Half-sideways
	{
		if(!g_bInStartZone[client] && !g_bInStageZone[client])
		{
			if (buttons & IN_BACK && !(buttons & IN_MOVELEFT || buttons & IN_MOVERIGHT))
			{
				g_KeyCount[client]++;
				if (g_KeyCount[client] == 60)
				{
					g_iCurrentStyle[client] = 0;
					g_KeyCount[client] = 0;
					PrintToChat(client, " %cSurftimer %c| Style set to %cNormal.", LIMEGREEN, WHITE, GREEN);
				}
			}
			else if (buttons & IN_BACK && (buttons & IN_MOVELEFT || buttons & IN_MOVERIGHT))
				g_KeyCount[client] = 0;

			if (buttons & IN_FORWARD && !(buttons & IN_MOVELEFT || buttons & IN_MOVERIGHT))
				{
					g_KeyCount[client]++;
					if(g_KeyCount[client] == 60)
					{
						g_iCurrentStyle[client] = 0;
						g_KeyCount[client] = 0;
						PrintToChat(client, " %cSurftimer %c| Style set to %cNormal.", LIMEGREEN, WHITE, GREEN);
					}
				}
			else if (buttons & IN_FORWARD && (buttons & IN_MOVELEFT || buttons & IN_MOVERIGHT))
				g_KeyCount[client] = 0;

			if (buttons & IN_MOVELEFT && !(buttons & IN_FORWARD || buttons & IN_BACK))
				{
					g_KeyCount[client]++;
					if(g_KeyCount[client] == 60)
					{
						g_iCurrentStyle[client] = 0;
						g_KeyCount[client] = 0;
						PrintToChat(client, " %cSurftimer %c| Style set to %cNormal.", LIMEGREEN, WHITE, GREEN);
					}
				}
			else if (buttons & IN_MOVELEFT && (buttons & IN_FORWARD || buttons & IN_BACK))
				g_KeyCount[client] = 0;

			if (buttons & IN_MOVERIGHT && !(buttons & IN_FORWARD || buttons & IN_BACK))
				{
					g_KeyCount[client]++;
					if(g_KeyCount[client] == 60)
					{
						g_iCurrentStyle[client] = 0;
						g_KeyCount[client] = 0;
						PrintToChat(client, " %cSurftimer %c| Style set to %cNormal.", LIMEGREEN, WHITE, GREEN);
					}
				}
				else if (buttons & IN_MOVELEFT && (buttons & IN_FORWARD || buttons & IN_BACK))
					g_KeyCount[client] = 0;
		}
	}
	else if(g_iCurrentStyle[client] == 3)    //Backwards
	{
		float eye[3];
		float velocity[3];
		
		GetClientEyeAngles(client, eye);
		
		eye[0] = Cosine( DegToRad( eye[1] ) );
		eye[1] = Sine( DegToRad( eye[1] ) );
		eye[2] = 0.0;
		
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", velocity);
		
		velocity[2] = 0.0;
		
		float len = SquareRoot( velocity[0] * velocity[0] + velocity[1] * velocity[1] );
		
		velocity[0] /= len;
		velocity[1] /= len;
		
		float val = GetVectorDotProduct( eye, velocity );
		
		//PrintToChat(client, "%.2f", val); //for testing
		
		if(!g_bInStartZone[client] && !g_bInStageZone[client] && val > -0.75)
		{
			g_KeyCount[client]++;
			if(g_KeyCount[client] == 60)
			{
				g_iCurrentStyle[client] = 0;
				g_KeyCount[client] = 0;
				PrintToChat(client, "%cSurftimer %c| Style set to %cNormal.", LIMEGREEN, WHITE, GREEN);
			}
		}
		else if (!g_bInStartZone[client] && !g_bInStageZone[client] && val < -0.75)
		g_KeyCount[client] = 0;
	}
	else if (g_iCurrentStyle[client] == 5) // Slow Motion
	{
		// Maybe fix ramp glitches in slow motion, using https://forums.alliedmods.net/showthread.php?t=277523

		// Set up and do tracehull to find out if the player landed on a surf
		float vPos[3];
		GetEntPropVector(client, Prop_Data, "m_vecOrigin", vPos);

		float vMins[3];
		GetEntPropVector(client, Prop_Send, "m_vecMins", vMins);

		float vMaxs[3];
		GetEntPropVector(client, Prop_Send, "m_vecMaxs", vMaxs);
		
		// Fix weird shit that made people go through the roof
		vPos[2] += 1.0;
		vMaxs[2] -= 1.0;
		
		float vEndPos[3];
		
		// Take account for the client already being stuck
		vEndPos[0] = vPos[0];
		vEndPos[1] = vPos[1];
		vEndPos[2] = vPos[2] - g_fMaxVelocity;
		
		TR_TraceHullFilter(vPos, vEndPos, vMins, vMaxs, MASK_PLAYERSOLID_BRUSHONLY, TraceRayDontHitSelf, client);
		
		if(TR_DidHit())
		{
			// Gets the normal vector of the surface under the player
			float vPlane[3], vRealEndPos[3];
			
			TR_GetPlaneNormal(INVALID_HANDLE, vPlane);
			TR_GetEndPosition(vRealEndPos);
			
			// Check if client is on a surf ramp, and if he is stuck
			if(0.7 > vPlane[2] && vPos[2] - vRealEndPos[2] < 0.975)
			{
				// Player was stuck, lets put him back on the ramp
				TeleportEntity(client, vRealEndPos, NULL_VECTOR, NULL_VECTOR);
			}
		}
	}

	//Backwards



	if (g_bRoundEnd || !IsValidClient(client))
		return Plugin_Continue;

	if (IsPlayerAlive(client))
	{
		g_bLastOnGround[client] = g_bOnGround[client];
		if (GetEntityFlags(client) & FL_ONGROUND)
			g_bOnGround[client] = true;
		else
			g_bOnGround[client] = false;

		float newVelocity[3];
		// Slope Boost Fix by Mev, & Blacky
		// https://forums.alliedmods.net/showthread.php?t=266888
		//if (GetConVarBool(g_hSlopeFixEnable) == true)
		if (GetConVarBool(g_hSlopeFixEnable) == true && !IsFakeClient(client))
		{
			g_vLast[client][0] = g_vCurrent[client][0];
			g_vLast[client][1] = g_vCurrent[client][1];
			g_vLast[client][2] = g_vCurrent[client][2];
			g_vCurrent[client][0] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[0]");
			g_vCurrent[client][1] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[1]");
			g_vCurrent[client][2] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[2]");

			// Check if player landed on the ground
			if (g_bOnGround[client] == true && g_bLastOnGround[client] == false)
			{
				// Set up and do tracehull to find out if the player landed on a slope
				float vPos[3];
				GetEntPropVector(client, Prop_Data, "m_vecOrigin", vPos);

				float vMins[3];
				GetEntPropVector(client, Prop_Send, "m_vecMins", vMins);

				float vMaxs[3];
				GetEntPropVector(client, Prop_Send, "m_vecMaxs", vMaxs);

				float vEndPos[3];
				vEndPos[0] = vPos[0];
				vEndPos[1] = vPos[1];
				vEndPos[2] = vPos[2] - FindConVar("sv_maxvelocity").FloatValue;

				TR_TraceHullFilter(vPos, vEndPos, vMins, vMaxs, MASK_PLAYERSOLID_BRUSHONLY, TraceRayDontHitSelf, client);

				if (TR_DidHit())
				{
					// Gets the normal vector of the surface under the player
					float vPlane[3], vLast[3];
					TR_GetPlaneNormal(INVALID_HANDLE, vPlane);

					// Make sure it's not flat ground and not a surf ramp (1.0 = flat ground, < 0.7 = surf ramp)
					if (0.7 <= vPlane[2] < 1.0)
					{
						/*
						Copy the ClipVelocity function from sdk2013
						(https://mxr.alliedmods.net/hl2sdk-sdk2013/source/game/shared/gamemovement.cpp#3145)
						With some minor changes to make it actually work
						*/
						vLast[0] = g_vLast[client][0];
						vLast[1] = g_vLast[client][1];
						vLast[2] = g_vLast[client][2];
						vLast[2] -= (FindConVar("sv_gravity").FloatValue * GetTickInterval() * 0.5);

						float fBackOff = GetVectorDotProduct(vLast, vPlane);

						float change, vVel[3];
						for (int i; i < 2; i++)
						{
							change = vPlane[i] * fBackOff;
							vVel[i] = vLast[i] - change;
						}

						float fAdjust = GetVectorDotProduct(vVel, vPlane);
						if (fAdjust < 0.0)
						{
							for (int i; i < 2; i++)
							{
								vVel[i] -= (vPlane[i] * fAdjust);
							}
						}

						vVel[2] = 0.0;
						vLast[2] = 0.0;

						// Make sure the player is going down a ramp by checking if they actually will gain speed from the boost
						if (GetVectorLength(vVel) > GetVectorLength(vLast))
						{
							// Teleport the player, also adds basevelocity
							if (GetEntityFlags(client) & FL_BASEVELOCITY)
							{
								float vBase[3];
								GetEntPropVector(client, Prop_Data, "m_vecBaseVelocity", vBase);

								AddVectors(vVel, vBase, vVel);
							}
							g_bFixingRamp[client] = true;
							Array_Copy(vVel, newVelocity, 3);
							TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vVel);
						}
					}
				}
			}
		}

		if (newVelocity[0] == 0.0 && newVelocity[1] == 0.0 && newVelocity[2] == 0.0)
		{
			RecordReplay(client, buttons, subtype, seed, impulse, weapon, angles, vel);
			if (IsFakeClient(client))
				PlayReplay(client, buttons, subtype, seed, impulse, weapon, angles, vel);
		}
		else
		{
			RecordReplay(client, buttons, subtype, seed, impulse, weapon, angles, newVelocity);
			if (IsFakeClient(client))
				PlayReplay(client, buttons, subtype, seed, impulse, weapon, angles, newVelocity);
		}

		// Strafe Sync taken from shavit's bhoptimer
		int iGroundEntity = GetEntPropEnt(client, Prop_Send, "m_hGroundEntity");
		float fAngle = (angles[1] - g_fAngleCache[client]);

		while(fAngle > 180.0)
		{
			fAngle -= 360.0;
		}

		while(fAngle < -180.0)
		{
			fAngle += 360.0;
		}

		if ((g_bTimeractivated[client] || g_bWrcpTimeractivated[client]) && iGroundEntity == -1 && (GetEntityFlags(client) & FL_INWATER) == 0 && fAngle != 0.0)
		{
			float fAbsVelocity[3];
			GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", fAbsVelocity);

			if(SquareRoot(Pow(fAbsVelocity[0], 2.0) + Pow(fAbsVelocity[1], 2.0)) > 0.0)
			{
				float fTempAngle = angles[1];

				float fAngles[3];
				GetVectorAngles(fAbsVelocity, fAngles);

				if(fTempAngle < 0.0)
				{
					fTempAngle += 360.0;
				}

				float fDirectionAngle = (fTempAngle - fAngles[1]);

				if(fDirectionAngle < 0.0)
				{
					fDirectionAngle = -fDirectionAngle;
				}

				if (g_iCurrentStyle[client] != 2)
				{
					if(fDirectionAngle < 22.5 || fDirectionAngle > 337.5)
					{
						g_iTotalMeasures[client]++;

						if((fAngle > 0.0 && vel[1] < 0.0) || (fAngle < 0.0 && vel[1] > 0.0))
						{
							g_iGoodGains[client]++;
						}
					}
					else if((fDirectionAngle > 67.5 && fDirectionAngle < 112.5) || (fDirectionAngle > 247.5 && fDirectionAngle < 292.5))
					{
						g_iTotalMeasures[client]++;

						if(vel[0] != 0.0)
						{
							g_iGoodGains[client]++;
						}
					}
				}
				else
				{
					if (fAngle > 0)
					{
						g_iTotalMeasures[client]++;
						if (buttons & IN_MOVELEFT)
							g_iGoodGains[client]++;
						else if (buttons & IN_FORWARD && buttons & IN_MOVELEFT)
							g_iGoodGains[client]++;
					}
					else if (fAngle < 0)
					{
						g_iTotalMeasures[client]++;
						if (buttons & IN_MOVERIGHT)
							g_iGoodGains[client]++;
						else if (buttons & IN_BACK && buttons & IN_MOVERIGHT)
							g_iGoodGains[client]++;
					}
				}
			}
		}

		float speed, origin[3], ang[3];
		GetClientAbsOrigin(client, origin);
		GetClientEyeAngles(client, ang);

		speed = GetSpeed(client);

		//menu refreshing
		CheckRun(client);

		AutoBhopFunction(client, buttons);

		NoClipCheck(client);
		AttackProtection(client, buttons);

		// If in start zone, cap speed
		LimitSpeed(client);

		g_fLastSpeed[client] = speed;
		g_LastButton[client] = buttons;

		BeamBox_OnPlayerRunCmd(client);

		// if (!IsFakeClient(client))
		// {
		// 	float vVelocity[3];
		// 	GetEntPropVector(client, Prop_Data, "m_vecVelocity", vVelocity);
		// 	float velocity = GetVectorLength(vVelocity);

		// 	if (velocity == 0.0)
		// 	{
		// 		if (g_iClientInZone[client][0] == 1 || g_iClientInZone[client][0] == 5) // Start & Start Speed zones
		// 		{
		// 			if (g_hRecording[client] != null)
		// 			{
		// 				StopRecording(client);
		// 			}

		// 			if (g_StageRecStartFrame[client] != -1)
		// 				g_StageRecStartFrame[client] = -1;
		// 		}
		// 		else if (g_iClientInZone[client][0] == 3) // Stage zones
		// 		{
		// 			// Check if the stage replay is being recorded
		// 			if (g_StageRecStartFrame[client] != -1)
		// 				g_StageRecStartFrame[client] = -1;
		// 		}
		// 	}
		// 	else
		// 	{
		// 		if (g_iClientInZone[client][0] == 1 || g_iClientInZone[client][0] == 5) // Start & Start Speed zones
		// 		{
		// 			if (g_hRecording[client] == null)
		// 				StartRecording(client);
					
		// 			// Check if the map has stages
		// 			if (g_bhasStages && g_StageRecStartFrame[client] == -1)
		// 				Stage_StartRecording(client);
		// 		}
		// 		else if (g_iClientInZone[client][0] == 3) // Stage zones
		// 		{
		// 			if (g_StageRecStartFrame[client] == -1)
		// 				Stage_StartRecording(client);
		// 		}
		// 	}
		// }
	}

	// Strafe Sync taken from shavit's bhop timer
	g_fAngleCache[client] = angles[1];

	return Plugin_Continue;
}

//dhooks
public MRESReturn DHooks_OnTeleport(int client, Handle hParams)
{

	if (!IsValidClient(client))
		return MRES_Ignored;

	if (g_bPushing[client])
	{
		g_bPushing[client] = false;
		return MRES_Ignored;
	}

	if (g_bFixingRamp[client])
	{
		g_bFixingRamp[client] = false;
		return MRES_Ignored;
	}


	// This one is currently mimicing something.
	if (g_hBotMimicsRecord[client] != null)
	{
		// We didn't allow that teleporting. STOP THAT.
		if (!g_bValidTeleportCall[client])
			return MRES_Supercede;
		g_bValidTeleportCall[client] = false;
		return MRES_Ignored;
	}

	// Don't care if he's not recording.
	if (g_hRecording[client] == null)
		return MRES_Ignored;

	bool bOriginNull = DHookIsNullParam(hParams, 1);
	bool bAnglesNull = DHookIsNullParam(hParams, 2);
	bool bVelocityNull = DHookIsNullParam(hParams, 3);

	float origin[3], angles[3], velocity[3];

	if (!bOriginNull)
		DHookGetParamVector(hParams, 1, origin);

	if (!bAnglesNull)
	{
		for (int i = 0; i < 3; i++)
			angles[i] = DHookGetParamObjectPtrVar(hParams, 2, i * 4, ObjectValueType_Float);
	}

	if (!bVelocityNull)
		DHookGetParamVector(hParams, 3, velocity);

	if (bOriginNull && bAnglesNull && bVelocityNull)
		return MRES_Ignored;

	int iAT[AT_SIZE];
	Array_Copy(origin, iAT[atOrigin], 3);
	Array_Copy(angles, iAT[atAngles], 3);
	Array_Copy(velocity, iAT[atVelocity], 3);

	// Remember,
	if (!bOriginNull)
		iAT[atFlags] |= ADDITIONAL_FIELD_TELEPORTED_ORIGIN;
	if (!bAnglesNull)
		iAT[atFlags] |= ADDITIONAL_FIELD_TELEPORTED_ANGLES;
	if (!bVelocityNull)
		iAT[atFlags] |= ADDITIONAL_FIELD_TELEPORTED_VELOCITY;

	if (g_hRecordingAdditionalTeleport[client] != null)
		PushArrayArray(g_hRecordingAdditionalTeleport[client], iAT, AT_SIZE);

	return MRES_Ignored;
}

public void Hook_PostThinkPost(int entity)
{
	SetEntProp(entity, Prop_Send, "m_bInBuyZone", 0);
}

public Action Event_PlayerJump(Handle event, char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (client == 0 && !IsPlayerAlive(client) && !IsClientObserver(client))
		return Plugin_Continue;
	
	int zoneid = g_iClientInZone[client][3];
	if (zoneid < 0)
		zoneid = 0;

	if (IsValidClient(client) && !IsFakeClient(client))
	{
		// Prehop limit in zone
		if (GetConVarBool(g_hOneJumpLimit))
		{
			if (g_bInStartZone[client] || g_bInStageZone[client])
			{
				if (g_mapZones[zoneid][oneJumpLimit] == 1)
				{
					if (!g_bJumpedInZone[client])
					{
						g_bJumpedInZone[client] = true;
						g_bResetOneJump[client] = true;
						g_fJumpedInZoneTime[client] = GetGameTime();
						//PrintToChat(client, "First Time: %f", g_fJumpedInZoneTime[client]);
						CreateTimer(1.0, ResetOneJump, client, TIMER_FLAG_NO_MAPCHANGE);
					}
					else
					{
						g_bResetOneJump[client] = false;
						float time = GetGameTime();
						float time2 = time - g_fJumpedInZoneTime[client];
						//PrintToChat(client, "Second Time: %f", time);
						//PrintToChat(client, "Second Time - First Time = %f", time2);
						g_bJumpedInZone[client] = false;
						if (time2 <= 0.9)
						{
							PrintToChat(client, " %cSurftimer %c| %cYou may only jump once inside this zone", LIMEGREEN, WHITE, DARKRED, WHITE, YELLOW, WHITE);
							Handle pack;
							CreateDataTimer(0.05, DelayedVelocityCap, pack);
							WritePackCell(pack, client);
							WritePackFloat(pack, 0.0);
						}
					}
				}
			}
		}
	}

	return Plugin_Continue;
}

public Action ResetOneJump(Handle timer, any client)
{
	if (g_bResetOneJump[client])
	{
		g_bJumpedInZone[client] = false;
		g_bResetOneJump[client] = false;
	}
}

public Action DelayedVelocityCap(Handle timer, Handle pack)
{
	ResetPack(pack);
	int client = ReadPackCell(pack);
	float speedCap = ReadPackFloat(pack);
	float CurVelVec[3];

	GetEntPropVector(client, Prop_Data, "m_vecVelocity", CurVelVec);

	if (CurVelVec[0] == 0.0)
		CurVelVec[0] = 1.0;
	if (CurVelVec[1] == 0.0)
		CurVelVec[1] = 1.0;
	if (CurVelVec[2] == 0.0)
		CurVelVec[2] = 1.0;

	NormalizeVector(CurVelVec, CurVelVec);
	ScaleVector(CurVelVec, speedCap);
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, CurVelVec);
}

public Action Hook_SetTriggerTransmit(int entity, int client)
{
	if (!g_bShowTriggers[client])
	{
		// I will not display myself to this client :(
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action Hook_FootstepCheck(int clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags) 
{
	// Player
  if (0 < entity <= MaxClients)
  {
		if (StrContains(sample, "land") != -1 || StrContains(sample, "suit_") != -1 || StrContains(sample, "knife") != -1)
			return Plugin_Handled;

		if (StrContains(sample, "footsteps") != -1 || StrContains(sample, "physics") != -1)
		{
			numClients = 1;
			clients[0] = entity;
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i) && !IsPlayerAlive(i))
				{
					int SpecMode = GetEntProp(i, Prop_Send, "m_iObserverMode");
					if (SpecMode == 4 || SpecMode == 5)
					{
						int Target = GetEntPropEnt(i, Prop_Send, "m_hObserverTarget");
						if (Target == entity)
							clients[numClients++] = i;
					}
				}
			}
			EmitSound(clients, numClients, sample, entity);
			//return Plugin_Changed;

			return Plugin_Stop;
		}
  }
  return Plugin_Continue;
}

public Action Hook_ShotgunShot(const char[] te_name, const int[] players, int numClients, float delay) 
{
	return Plugin_Handled;
	// int shooter = TE_ReadNum("m_iPlayer") + 1;

	// int[] newClients = new int[MaxClients];
	// int newTotal = 0;

	// for (int i = 1; i <= MaxClients; i++)
	// {
	// 	if (IsValidClient(i) && !IsPlayerAlive(i))
	// 	{
	// 		int SpecMode = GetEntProp(i, Prop_Send, "m_iObserverMode");
	// 		if (SpecMode == 4 || SpecMode == 5)
	// 		{
	// 			int Target = GetEntPropEnt(i, Prop_Send, "m_hObserverTarget");
	// 			if (Target == shooter)
	// 				newClients[newTotal] = i;
	// 				newTotal++;
	// 			}
	// 	}
	// }

	// if (newTotal == 0)
	// 	return Plugin_Stop;
	
	// float vTemp[3];
  // TE_Start("Shotgun Shot");
  // TE_ReadVector("m_vecOrigin", vTemp);
  // TE_WriteVector("m_vecOrigin", vTemp);
  // TE_WriteFloat("m_vecAngles[0]", TE_ReadFloat("m_vecAngles[0]"));
  // TE_WriteFloat("m_vecAngles[1]", TE_ReadFloat("m_vecAngles[1]"));
  // TE_WriteNum("m_weapon", TE_ReadNum("m_weapon"));
  // TE_WriteNum("m_iMode", TE_ReadNum("m_iMode"));
  // TE_WriteNum("m_iSeed", TE_ReadNum("m_iSeed"));
  // TE_WriteNum("m_iPlayer", TE_ReadNum("m_iPlayer"));
  // TE_WriteFloat("m_fInaccuracy", TE_ReadFloat("m_fInaccuracy"));
  // TE_WriteFloat("m_fSpread", TE_ReadFloat("m_fSpread"));
  // TE_Send(newClients, newTotal, delay);

	// return Plugin_Stop;
}