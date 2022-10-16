/*
	SurfTimer Hooks
	TODO: Cleanup, si si
*/

void CreateHooks()
{
	HookUserMessage(GetUserMessageId("SendPlayerItemFound"), ItemFoundMsg, true);

	// Hooks
	HookEvent("player_spawn", Event_OnPlayerSpawn, EventHookMode_Post);
	HookEvent("player_death", Event_OnPlayerDeath);
	HookEvent("round_start", Event_OnRoundStart, EventHookMode_PostNoCopy);
	HookEvent("round_end", Event_OnRoundEnd, EventHookMode_Pre);
	HookEvent("player_hurt", Event_OnPlayerHurt);
	HookEvent("weapon_fire", Event_OnFire, EventHookMode_Pre);
	HookEvent("player_team", Event_OnPlayerTeam, EventHookMode_Post);
	HookEvent("player_disconnect", Event_PlayerDisconnect, EventHookMode_Pre);
	HookEvent("player_jump", Event_PlayerJump);

	// Gunshots
	AddTempEntHook("Shotgun Shot", Hook_ShotgunShot);

	// Footsteps
	AddNormalSoundHook(Hook_FootstepCheck);
}

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

// Attack Spam Protection
public Action Event_OnFire(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (client <= 0 || !IsClientInGame(client) || !GetConVarBool(g_hAttackSpamProtection))
	{
		return Plugin_Continue;
	}

	char weapon[64];
	GetEventString(event, "weapon", weapon, 64);

	if (StrContains(weapon, "knife", true) != -1 || g_AttackCounter[client] >= 41)
	{
		return Plugin_Continue;
	}

	g_AttackCounter[client]++;
	if (StrContains(weapon, "grenade", true) != -1 || StrContains(weapon, "flash", true) != -1)
	{
		g_AttackCounter[client] = g_AttackCounter[client] > 32 ? 41 : g_AttackCounter[client] + 9;
	}

	return Plugin_Continue;
}

// Player Spawns
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
		// fluffys
		g_bInJump[client] = false;
		g_bInDuck[client] = false;

		// Set stage to 1 on spawn cause why not
		if (!g_bRespawnPosition[client] && !g_specToStage[client])
		{
			g_WrcpStage[client] = 1;
			g_Stage[0][client] = 1;
			g_CurrentStage[client] = 1;
			g_Stage[g_iClientInZone[client][2]][client] = 1;
			g_bWrcpTimeractivated[client] = false;
		}

		if (g_iCurrentStyle[client] == 4) // 4 low gravity
			SetEntityGravity(client, 0.5);
		else if (g_iCurrentStyle[client] == 5)// 5 slowmo
			SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 0.5);
		else if (g_iCurrentStyle[client] == 6)// 6 fastforward
			SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.5);

		if (g_iCurrentStyle[client] < 4) // 0 normal, 1 hsw, 2 sw, 3 bw
		{
			SetEntityGravity(client, 1.0); // normal gravity
			SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0); // normal speed
		}

		// Strip Weapons
		if ((GetClientTeam(client) > 1) && IsValidClient(client))
		{
			StripAllWeapons(client);
			if (!IsFakeClient(client))
			{
				int weapon = GivePlayerWeaponAndSkin(client, "weapon_usp_silencer", CS_TEAM_CT);
				if (weapon > MaxClients)
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon);
			}
		}

		// NoBlock
		if (GetConVarBool(g_hCvarNoBlock))
			SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
		else
			SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 5, 4, true);

		// Replay bot frame init
		if (g_aReplayFrame[client] != null && IsFakeClient(client))
		{
			g_iReplayTick[client] = 0;
			g_CurrentAdditionalTeleportIndex[client] = 0;
		}

		if (IsFakeClient(client))
		{
			if (client == g_InfoBot)
				CS_SetClientClanTag(client, "");
			else if (client == g_RecordBot)
				CS_SetClientClanTag(client, "MAP Replay");
			else if (client == g_BonusBot)
				CS_SetClientClanTag(client, "BONUS Replay");
			else if (client == g_WrcpBot)
				CS_SetClientClanTag(client, "STAGE Replay");

			if (client == g_RecordBot || client == g_BonusBot || client == g_WrcpBot)
			{
				SetEntityGravity(client, 0.0);
			}

			return Plugin_Continue;
		}
		else{
			//PRINFO TIME INCREMENT
			for(int zonegroup = 0; zonegroup < MAXZONEGROUPS; zonegroup++)
				g_fTimeIncrement[client][zonegroup] = 0.0;
		}

		// Change Player Skin
		if (GetConVarBool(g_hPlayerSkinChange) && (GetClientTeam(client) > 1))
		{
			char szBuffer[256];

			GetConVarString(g_hPlayerModel, szBuffer, 256);
			SetEntityModel(client, szBuffer);
			CreateTimer(1.0, SetArmsModel, client, TIMER_FLAG_NO_MAPCHANGE);
		}

		// 1st Spawn & T/CT
		if (g_bFirstSpawn[client] && (GetClientTeam(client) > 1))
		{
			float fLocation[3];
			GetClientAbsOrigin(client, fLocation);
			if (setClientLocation(client, fLocation) == -1)
			{
				g_iClientInZone[client][2] = 0;
				g_bIgnoreZone[client] = false;
			}

			//1st spawn start recording
			StartRecording(client); //Add pre
			if (g_bhasStages)
				Stage_StartRecording(client); //Add pre
        
			CreateTimer(1.5, CenterMsgTimer, client, TIMER_FLAG_NO_MAPCHANGE);

			//THIS "FIXES" A BUG WHERE THE TIMEINCREMENT WOULD BE CHANGED IN THE BEGINNING FOR FUCK ALL REASON...
			if(!IsFakeClient(client)){
				for(int zonegroup = 0; zonegroup < MAXZONEGROUPS; zonegroup++){
					if(g_fTimeIncrement[client][zonegroup] != 0.0)
						g_fTimeIncrement[client][zonegroup] = 0.0;
				}
			}
			g_iCurrentTick[client] = g_iClientTick[client];

			g_bFirstSpawn[client] = false;

		}

		// Get Start Position For Challenge
		GetClientAbsOrigin(client, g_fSpawnPosition[client]);

		// Restore Position
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
						g_bTimerRunning[client] = false;
						g_fStartTime[client] = -1.0;
						g_fCurrentRunTime[client] = -1.0;

						// Spawn Client To The Start Zone.
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

		// Hide Radar
		CreateTimer(0.0, HideHud, client, TIMER_FLAG_NO_MAPCHANGE);

		// Set Clantag
		CreateTimer(1.5, SetClanTag, client, TIMER_FLAG_NO_MAPCHANGE);

		// Set Speclist
		Format(g_szPlayerPanelText[client], 512, "");

		// Get Speed & Origin
		g_fLastSpeed[client] = GetSpeed(client);
		
		// Give Player Kevlar + Helmet
		GivePlayerItem(client, "item_assaultsuit");
		
	}
	else if (IsFakeClient(client)) 
	{
		SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
	}
	return Plugin_Continue;
}

public Action Say_Hook(int client, const char[] command, int argc)
{
	if (!IsValidClient(client))
		return Plugin_Continue;

	// Get message text
	char sText[1024];
	GetCmdArgString(sText, sizeof(sText));

	StripQuotes(sText);
	TrimString(sText);

	// Call Admin - Own Reason
	if (g_bClientOwnReason[client])
	{
		g_bClientOwnReason[client] = false;
		return Plugin_Continue;
	}

	// Renaming zone
	if (g_ClientRenamingZone[client])
	{
		Admin_renameZone(client, sText);
		return Plugin_Handled;
	}

	// Client is muted
	if (BaseComm_IsClientGagged(client))
		return Plugin_Handled;

	// Blocked Commands
	for (int i = 0; i < sizeof(g_BlockedChatText); i++)
	{
		if (StrEqual(g_BlockedChatText[i], sText, true))
			return Plugin_Handled;
	}

	// Functions that require the client to input something via the chat box
	if (g_iWaitingForResponse[client] > None)
	{
		// Check if client is cancelling
		if (StrEqual(sText, "cancel"))
		{
			CPrintToChat(client, "%t", "Hooks1", g_szChatPrefix);
			g_iWaitingForResponse[client] = None;
			return Plugin_Handled;
		}

		// Check which function we're waiting for
		switch (g_iWaitingForResponse[client])
		{
			case PreSpeed: 
			{
				// Set zone Prespeed
				float prespeed = StringToFloat(sText);
				if (prespeed < 0.0)
					prespeed = 0.0;
				g_mapZones[g_ClientSelectedZone[client]].PreSpeed = prespeed;
				PrespeedMenu(client);
			}
			case ZoneGroup:
			{
				// Hook zone zonegroup
				int zgrp = StringToInt(sText);
				if (zgrp < 1 || zgrp > 35)
				{
					CPrintToChat(client, "%t", "Hooks2", g_szChatPrefix);
					return Plugin_Handled;
				}
				g_iZonegroupHook[client] = zgrp;
				CPrintToChat(client, "%t", "Hooks3", g_szChatPrefix, zgrp);
			}
			case MaxVelocity:
			{
				// Maxvelocity for map
				float maxvelocity = StringToFloat(sText);
				if (maxvelocity < 1.0)
					maxvelocity = 10000.0;
				g_fMaxVelocity = maxvelocity;
				db_updateMapSettings();
				MaxVelocityMenu(client);
				CPrintToChat(client, "%t", "Hooks4", g_szChatPrefix, g_szMapName, maxvelocity);
			}
			case TargetName:
			{
				// Zone set clients Target Name
				if (StrEqual(sText, "reset"))
					Format(sText, sizeof(sText), "player");

				Format(g_mapZones[g_ClientSelectedZone[client]].TargetName, sizeof(MapZone::TargetName), "%s", sText);

				CPrintToChat(client, "%t", "Hooks5", g_szChatPrefix, g_szZoneDefaultNames[g_CurrentZoneType[client]], g_mapZones[g_ClientSelectedZone[client]].ZoneTypeId, sText);

				EditorMenu(client);
			}
			case ClientEdit:
			{
				// Deleting records
				g_SelectedType[client] = StringToInt(sText);
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
			}
			case ColorValue:
			{
				//COLOR VALUE FOR CENTER SPEED
				int color_value = StringToInt(sText);

				//KEEP VALUES BETWEEN 0-255
				if(color_value > 255)
					color_value = 255;
				else if(color_value < 0)
					color_value = 0;

				switch(g_iColorChangeIndex[client]){
					case 0: g_iCSD_R[client] = color_value;
					case 1: g_iCSD_G[client] = color_value;
					case 2: g_iCSD_B[client] = color_value;
				}
				CSDOptions(client);
			}
		}

		g_iWaitingForResponse[client] = None;
		return Plugin_Handled;
	}

	if (!GetConVarBool(g_henableChatProcessing))
		return Plugin_Continue;

	// !s & !stage Commands
	if (StrContains(sText, "!s", false) == 0 || StrContains(sText, "!stage", false) == 0)
		return Plugin_Handled;

	// !b & !bonus Commands
	if (StrContains(sText, "!b", false) == 0 || StrContains(sText, "!bonus", false) == 0)
		return Plugin_Handled;

	// Empty Message
	if (StrEqual(sText, " ") || !sText[0])
		return Plugin_Handled;

	// Spam check
	if (checkSpam(client))
		return Plugin_Handled;

	parseColorsFromString(sText, 1024);

	// Lowercase
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

	// Hide ! commands
	if (StrContains(sText, "!", false) == 0)
		return Plugin_Handled;

	if ((IsChatTrigger() && sText[0] == '/') || (sText[0] == '@' && (GetUserFlagBits(client) & ADMFLAG_ROOT || GetUserFlagBits(client) & ADMFLAG_GENERIC)))
		return Plugin_Continue;

	char szName[64];
	GetClientName(client, szName, 64);
	RemoveColors(szName, 64);

	// log the chat of the player to the server so that tools such as HLSW/HLSTATX see it and also it remains logged in the log file
	WriteChatLog(client, "say", sText);
	PrintToServer("%s: %s", szName, sText);

	// Name colors
	if (GetConVarBool(g_hPointSystem) && GetConVarBool(g_hColoredNames) && g_bDbCustomTitleInUse[client])
		setNameColor(szName, g_iCustomColours[client][0], 64);

	// Text colors
	if (GetConVarBool(g_hPointSystem) && GetConVarBool(g_hColoredNames) && g_bDbCustomTitleInUse[client] && g_bHasCustomTextColour[client])
		setTextColor(sText, g_iCustomColours[client][1], 1024);

	if (GetClientTeam(client) == 1)
	{
		// Client is a spectator
		PrintSpecMessageAll(client);
		return Plugin_Handled;
	}
	else
	{
		if (GetConVarBool(g_hPointSystem))
		{
			// Constructing the message
			char szChatRank[1024];
			Format(szChatRank, sizeof(szChatRank), "%s", g_pr_chat_coloredrank[client]);

			char szChatRankColor[1024];
			Format(szChatRankColor, sizeof(szChatRankColor), "%s", g_pr_chat_coloredrank[client]);
			CGetRankColor(szChatRankColor, sizeof(szChatRankColor));

			if (GetConVarBool(g_hColoredNames) && !g_bDbCustomTitleInUse[client])
				Format(szName, sizeof(szName), "{%s}%s", szChatRankColor, szName);

			if (GetConVarBool(g_hCountry)) {	// With country code
				if (IsPlayerAlive(client))
					CPrintToChatAll("%t", "Hooks6", g_szCountryCode[client], szChatRank, szName, sText);
				else
					CPrintToChatAll("%t", "Hooks7", g_szCountryCode[client], szChatRank, szName, sText);
				return Plugin_Handled;
			} 
			else								// Without country code
			{
				if (IsPlayerAlive(client))
					CPrintToChatAll("%t", "Hooks8", szChatRank, szName, sText);
				else
					CPrintToChatAll("%t", "Hooks9", szChatRank, szName, sText);
				return Plugin_Handled;
			}
		}
	}

	return Plugin_Continue;
}

public void CGetRankColor(char[] sMsg, int iSize) // edit from CProcessVariables - colorvars
{
	char[] sOut = new char[iSize];
	char[] sCode = new char[iSize];
	char[] sColor = new char[iSize];
	int iOutPos = 0;
	int iCodePos = -1;
	int iMsgLen = strlen(sMsg);
	int dev = 0;

	for (int i = 0; i < iMsgLen; i++) {
		if (sMsg[i] == '{') {
			iCodePos = 0;
		}

		if (iCodePos > -1) {
			sCode[iCodePos] = sMsg[i];
			sCode[iCodePos + 1] = '\0';

			if (sMsg[i] == '}' || i == iMsgLen - 1) {
				strcopy(sCode, strlen(sCode) - 1, sCode[1]);
				String_ToLower(sCode, sCode, iSize);

				if (CGetColor(sCode, sColor, iSize)) {
					if(dev == 1) {
						break;
					}
					dev++;
				} else {
					Format(sOut, iSize, "%s{%s}", sOut, sCode);
					iOutPos += strlen(sCode) + 2;
				}

				iCodePos = -1;
				strcopy(sColor, iSize, "");
			} else {
				iCodePos++;
			}

			continue;
		}

		sOut[iOutPos] = sMsg[i];
		iOutPos++;
		sOut[iOutPos] = '\0';
	}

	strcopy(sMsg, iSize, sCode);
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
		if (g_bTimerRunning[client])
		{
			g_fStartPauseTime[client] = GetClientTickTime(client);
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
				CPrintToChat(i, "%t", "Disconnected1", szName, disconnectReason);
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
		RemoveRagdoll(client);

		if (!IsFakeClient(client))
		{
			if (g_aRecording[client] != null)// should detect player if is onTimer
			{
				StopRecording(client);
			}
		}
		else
		{
			if (g_aReplayFrame[client] != null)
			{
				g_iReplayTick[client] = 0;
				g_CurrentAdditionalTeleportIndex[client] = 0;
				if (GetClientTeam(client) >= CS_TEAM_T)
				{
					CreateTimer(1.0, RespawnBot, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
				}
			}
		}
	}

	return Plugin_Continue;
}

static void RemoveRagdoll(int client)
{
	int iEntity = GetEntPropEnt(client, Prop_Send, "m_hRagdoll");

	if(iEntity != INVALID_ENT_REFERENCE)
	{
		AcceptEntityInput(iEntity, "Kill");
	}
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
	if (IsValidClient(entity) && !IsFakeClient(entity))
		LimitSpeedNew(entity);

	SetEntPropEnt(entity, Prop_Send, "m_bSpotted", 0);

	sv_noclipspeed.FloatValue = g_iNoclipSpeed[entity];
}


// OnRoundRestart
public Action Event_OnRoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	int iEnt;
	
	db_viewMapSettings();

	// fluffys gravity
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

	// Teleport Destinations (goose)
	iEnt = -1;
	g_hDestinations = CreateArray(128);
	while ((iEnt = FindEntityByClassname(iEnt, "info_teleport_destination")) != -1)
		PushArrayCell(g_hDestinations, iEnt);

	RefreshZones();

	g_bRoundEnd = false;
	return Plugin_Continue;
}

public Action ApplyStyles(Handle timer, int client)
{
	if (IsValidClient(client)) {
		if (g_iCurrentStyle[client] == 5)// 5 slowmo
			SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 0.5);
		else if (g_iCurrentStyle[client] == 6)// 6 fastforward
			SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.5);
	}

	return Plugin_Continue;
}

public Action OnMultipleTrigger1(int entity, int client)
{
	if (IsValidClient(client)) {
		CreateTimer(0.1, ApplyStyles, client);
	}

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

public Action OnEndTouchGravityTrigger(int entity, int other)
{
	if (IsValidClient(other) && !IsFakeClient(other))
	{
		if (!g_bNoClip[other] && GetConVarBool(g_hGravityFix))
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


// thx to TnTSCS (player slap stops timer)
// https://forums.alliedmods.net/showthread.php?t=233966
public Action OnLogAction(Handle source, Identity ident, int client, int target, const char[] message)
{
	if ((1 > target > MaxClients))
		return Plugin_Continue;
	if (IsValidClient(target) && IsPlayerAlive(target) && g_bTimerRunning[target] && !IsFakeClient(target))
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
	//calling this function here makes it refresh musch faster/smoother
	CenterSpeedDisplay(client,false);

	if (buttons & IN_DUCK && g_bInDuck[client] == true)
	{
		CPrintToChat(client, "%t", "Hooks11", g_szChatPrefix);
	}
	else if (g_bInMaxSpeed[client])
	{
		if (g_iClientInZone[client][3] >= 0)
			LimitMaxSpeed(client, g_mapZones[g_iClientInZone[client][3]].PreSpeed);
	}

	/*------ Styles ------*/
	if (g_iCurrentStyle[client] == 1) 	// Sideways
	{
		if (!g_bInStartZone[client] && !g_bInStageZone[client])
		{
			if (!GetConVarBool(g_hSidewaysBlockKeys))
			{
				if (buttons & IN_MOVELEFT)
				{
					g_iCurrentStyle[client] = 0;
					CPrintToChat(client, "%t", "Hooks12", g_szChatPrefix);
				}

				if (buttons & IN_MOVERIGHT)
				{
					g_iCurrentStyle[client] = 0;
					CPrintToChat(client, "%t", "Hooks13", g_szChatPrefix);
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
	else if (g_iCurrentStyle[client] == 2) // Half-sideways
	{
		bool bForward = ((buttons & IN_FORWARD) > 0 && vel[0] >= 100.0);
		bool bMoveLeft = ((buttons & IN_MOVELEFT) > 0 && vel[1] <= -100.0);
		bool bBack = ((buttons & IN_BACK) > 0 && vel[0] <= -100.0);
		bool bMoveRight = ((buttons & IN_MOVERIGHT) > 0 && vel[1] >= 100.0);
		if (!g_bInStartZone[client] && !g_bInStageZone[client])
		{
			if((bForward || bBack) && !(bMoveLeft || bMoveRight))
			{
				vel[0] = 0.0;
				buttons &= ~IN_FORWARD;
				buttons &= ~IN_BACK;
			}
			if((bMoveLeft || bMoveRight) && !(bForward || bBack))
			{
				vel[1] = 0.0;
				buttons &= ~IN_MOVELEFT;
				buttons &= ~IN_MOVERIGHT;
			}
		}
	}
	else if (g_iCurrentStyle[client] == 3)    // Backwards
	{
		bool bInputs = (buttons & IN_FORWARD) > 0 || (buttons & IN_MOVELEFT) > 0 ||
						(buttons & IN_BACK) > 0 || (buttons & IN_MOVERIGHT) > 0;
		
		float eye[3];
		float velocity[3];

		GetClientEyeAngles(client, eye);

		eye[0] = Cosine( DegToRad( eye[1] ) );
		eye[1] = Sine( DegToRad( eye[1] ) );
		eye[2] = 0.0;

		GetEntPropVector(client, Prop_Data, "m_vecVelocity", velocity);
		float fSpeedSqr = (velocity[0] * velocity[0] + velocity[1] * velocity[1]);
		float fSpeedThres = g_hDefaultPreSpeed.FloatValue;
		
		velocity[2] = 0.0;

		float len = SquareRoot(fSpeedSqr);

		velocity[0] /= len;
		velocity[1] /= len;

		float val = GetVectorDotProduct( eye, velocity );
		
		if (!g_bInStartZone[client] && !g_bInStageZone[client] && val > 0.0)
		{
			if (g_KeyCount[client] < 59)
				g_KeyCount[client]++;
			else
			{
				// don't check if we're below the threshold, or not pressing anything.
				// this should solve resets happening on wall collisions and ladders
				if(bInputs && fSpeedSqr > fSpeedThres * fSpeedThres)
				{
					g_iCurrentStyle[client] = 0;
					g_KeyCount[client] = 0;
					CPrintToChat(client, "%t", "Hooks14", g_szChatPrefix);
				}
			}
		}
		else
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

		if (TR_DidHit())
		{
			// Gets the normal vector of the surface under the player
			float vPlane[3], vRealEndPos[3];

			TR_GetPlaneNormal(INVALID_HANDLE, vPlane);
			TR_GetEndPosition(vRealEndPos);

			// Check if client is on a surf ramp, and if he is stuck
			if (0.7 > vPlane[2] && vPos[2] - vRealEndPos[2] < 0.975)
			{
				// Player was stuck, lets put him back on the ramp
				TeleportEntity(client, vRealEndPos, NULL_VECTOR, NULL_VECTOR);
			}
		}
	}

	// Backwards

	if (g_bRoundEnd || !IsValidClient(client))
	{
		return Plugin_Continue;
	}

	if (IsPlayerAlive(client))
	{
		if (IsFakeClient(client))
		{
			Replay_Playback(client, buttons, subtype, seed, impulse, weapon, angles, vel);
		}
		else
		{
			Replay_Recording(client, buttons, subtype, seed, impulse, weapon, angles, vel);
		}

		//PRINFO
		if (!IsFakeClient(client) && g_iCurrentStyle[client] == 0 && !g_bPracticeMode[client] && (g_bTimerRunning[client] || g_bWrcpTimeractivated[client])){
			//PLAYER IS IN A RUN
			if(g_bTimerRunning[client])
				g_fTimeIncrement[client][g_iClientInZone[client][2]] = g_fCurrentRunTime[client];
			//PLAYER IS JUST DOING STAGES
			else if(g_bWrcpTimeractivated[client])
				g_fTimeIncrement[client][g_iClientInZone[client][2]] = g_fCurrentWrcpRunTime[client];
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

		if ((g_bTimerRunning[client] || g_bWrcpTimeractivated[client]) && iGroundEntity == -1 && (GetEntityFlags(client) & FL_INWATER) == 0 && fAngle != 0.0)
		{
			float fAbsVelocity[3];
			GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", fAbsVelocity);

			if (SquareRoot(Pow(fAbsVelocity[0], 2.0) + Pow(fAbsVelocity[1], 2.0)) > 0.0)
			{
				float fTempAngle = angles[1];

				float fAngles[3];
				GetVectorAngles(fAbsVelocity, fAngles);

				if (fTempAngle < 0.0)
				{
					fTempAngle += 360.0;
				}

				float fDirectionAngle = (fTempAngle - fAngles[1]);

				if (fDirectionAngle < 0.0)
				{
					fDirectionAngle = -fDirectionAngle;
				}

				if (g_iCurrentStyle[client] != 2)
				{
					if (fDirectionAngle < 22.5 || fDirectionAngle > 337.5)
					{
						g_iTotalMeasures[client]++;

						if ((fAngle > 0.0 && vel[1] < 0.0) || (fAngle < 0.0 && vel[1] > 0.0))
						{
							g_iGoodGains[client]++;
						}
					}
					else if ((fDirectionAngle > 67.5 && fDirectionAngle < 112.5) || (fDirectionAngle > 247.5 && fDirectionAngle < 292.5))
					{
						g_iTotalMeasures[client]++;

						if (vel[0] != 0.0)
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

		// Menu Refreshing
		CheckRun(client);

		AutoBhopFunction(client, buttons);

		NoClipCheck(client);
		AttackProtection(client, buttons);

		// If in start zone, cap speed
		LimitSpeed(client);

		g_fLastSpeed[client] = speed;
		g_LastButton[client] = buttons;

		BeamBox_OnPlayerRunCmd(client);
	}

	// Strafe Sync taken from shavit's bhop timer
	g_fAngleCache[client] = angles[1];

	return Plugin_Continue;
}

// DHooks
public MRESReturn DHooks_OnTeleport(int client, Handle hParams)
{
	if (!IsValidClient(client))
		return MRES_Ignored;

	// This one is currently mimicing something.
	if (g_aReplayFrame[client] != null)
	{
		// We didn't allow that teleporting. STOP THAT.
		if (!g_bValidTeleportCall[client])
			return MRES_Supercede;
		g_bValidTeleportCall[client] = false;
		return MRES_Ignored;
	}

	// Don't care if he's not recording.
	if (g_aRecording[client] == null)
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

	return MRES_Ignored;
}

public void Hook_PostThinkPost(int entity)
{
	++g_iClientTick[entity];
	UpdateClientCurrentRunTimes(entity);

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
		if (g_bInJump[client] == true && !g_bInStartZone[client] && !g_bInStageZone[client])
		{
			if (!g_bJumpZoneTimer[client])
			{
				CreateTimer(1.0, StartJumpZonePrintTimer, client);
				CPrintToChat(client, "%t", "Hooks10", g_szChatPrefix);
				Handle pack;
				CreateDataTimer(0.05, DelayedVelocityCap, pack);
				WritePackCell(pack, client);
				WritePackFloat(pack, 0.0);
				g_bJumpZoneTimer[client] = true;
			}
		}

		if (GetConVarInt(g_hLimitSpeedType) == 1)
		{
			if (!g_bInStartZone[client] && !g_bInStageZone[client])
				return Plugin_Continue;

			// This logic for detecting bhops is pretty terrible and should be reworked -sneaK
			g_iTicksOnGround[client] = 0;
			float diff = GetClientTickTime(client) - g_iLastJump[client];
			if (!g_bInBhop[client])
			{
				if (g_bFirstJump[client])
				{
					if (diff > 0.8 && g_iCurrentStyle[client] != 4 && g_iCurrentStyle[client] != 5) // diff Normal Threshold + Exclude LG/SM
					{
						g_bFirstJump[client] = true;
						g_iLastJump[client] = GetClientTickTime(client);
					}

					else if (diff > 1.6 && (g_iCurrentStyle[client] == 4 || g_iCurrentStyle[client] == 5)) // LG/SM jump time threshold
					{
						g_bFirstJump[client] = true;
						g_iLastJump[client] = GetClientTickTime(client);
					}
					
					else
					{
						g_iLastJump[client] = GetClientTickTime(client);
						g_bInBhop[client] = true;
					}
				}
				else
				{
					g_iLastJump[client] = GetClientTickTime(client);
					g_bFirstJump[client] = true;
				}
			}
			else
			{
				// 0.2s no-jump buffer (diff + 0.2) to register as no longer in bhop.
				if (diff > 1 && g_iCurrentStyle[client] != 4 && g_iCurrentStyle[client] != 5) // Not LG/SM
				{
					g_bInBhop[client] = false;
					g_iLastJump[client] = GetClientTickTime(client);
				}

				else if (diff > 1.8 && (g_iCurrentStyle[client] == 4 || g_iCurrentStyle[client] == 5)) // LG/SM
				{
					g_bInBhop[client] = false;
					g_iLastJump[client] = GetClientTickTime(client);
				}

				else
				{
					g_iLastJump[client] = GetClientTickTime(client);
				}
			}
		}

		if (GetConVarBool(g_hOneJumpLimit) && GetConVarInt(g_hLimitSpeedType) == 1)
		{
			if (g_bInStartZone[client] || g_bInStageZone[client])
			{
				if (g_mapZones[zoneid].OneJumpLimit == 1)
				{
					if (!g_bJumpedInZone[client])
					{
						g_bJumpedInZone[client] = true;
						g_bResetOneJump[client] = true;
						g_fJumpedInZoneTime[client] = GetClientTickTime(client);
						if (g_iCurrentStyle[client] == 5 || g_iCurrentStyle[client] == 4)
							CreateTimer(1.7, ResetOneJump, client, TIMER_FLAG_NO_MAPCHANGE);
						else
							CreateTimer(1.0, ResetOneJump, client, TIMER_FLAG_NO_MAPCHANGE);
					}
					else
					{
						g_bResetOneJump[client] = false;
						float diff = GetClientTickTime(client) - g_fJumpedInZoneTime[client];
						g_bJumpedInZone[client] = false;
						if ((diff <= 0.9 && g_iCurrentStyle[client] != 4 && g_iCurrentStyle[client] != 5) || (diff <= 1.6 && (g_iCurrentStyle[client] == 4 || g_iCurrentStyle[client] == 5)))
						{
							CPrintToChat(client, "%t", "Hooks15", g_szChatPrefix);
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

	return Plugin_Continue;
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

	return Plugin_Continue;
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
			// return Plugin_Changed;

			return Plugin_Stop;
		}
	}
	return Plugin_Continue;
}

public Action Hook_ShotgunShot(const char[] te_name, const int[] players, int numClients, float delay) 
{
	return Plugin_Handled;
}
