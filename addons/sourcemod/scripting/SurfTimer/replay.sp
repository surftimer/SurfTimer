
//
// Botmimic2 - modified by 1NutWunDeR
// http://forums.alliedmods.net/showthread.php?t=164148
//
void setReplayTime(int zGrp)
{
	char sPath[256], sTime[54], sBuffer[4][54];
	if (zGrp > 0)
		BuildPath(Path_SM, sPath, sizeof(sPath), "%s%s_bonus_%i.rec", CK_REPLAY_PATH, g_szMapName, zGrp);
	else
		BuildPath(Path_SM, sPath, sizeof(sPath), "%s%s.rec", CK_REPLAY_PATH, g_szMapName);

	int iFileHeader[FILE_HEADER_LENGTH];
	LoadRecordFromFile(sPath, iFileHeader);
	Format(sTime, sizeof(sTime), "%s", iFileHeader[view_as<int>(FH_Time)]);

	ExplodeString(sTime, ":", sBuffer, 4, 54);
	float time = (StringToFloat(sBuffer[0]) * 60);
	time += StringToFloat(sBuffer[1]);
	time += (StringToFloat(sBuffer[2]) / 100);
	if (zGrp == 0)
	{
		if ((g_fRecordMapTime - 0.01) < time < (g_fRecordMapTime) + 0.01)
			time = g_fRecordMapTime;
	}
	else
	{
		if ((g_fBonusFastest[zGrp] - 0.01) < time < (g_fBonusFastest[zGrp]) + 0.01)
			time = g_fBonusFastest[zGrp];
	}

	g_fReplayTimes[zGrp] = time;
}

public Action RespawnBot(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (!client)
		return Plugin_Stop;

	if (g_hBotMimicsRecord[client] != null && IsValidClient(client) && !IsPlayerAlive(client) && IsFakeClient(client) && GetClientTeam(client) >= CS_TEAM_T)
	{
		TeamChangeActual(client, 2);
		CS_RespawnPlayer(client);
	}

	return Plugin_Stop;
}

public Action Hook_WeaponCanSwitchTo(int client, int weapon)
{
	if (g_hBotMimicsRecord[client] == null)
		return Plugin_Continue;

	if (g_BotActiveWeapon[client] != weapon)
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public void StartRecording(int client)
{
	if (!IsValidClient(client) || IsFakeClient(client))
		return;

	g_hRecording[client] = CreateArray(view_as<int>(FrameInfo));
	g_hRecordingAdditionalTeleport[client] = CreateArray(view_as<int>(AdditionalTeleport));
	GetClientAbsOrigin(client, g_fInitialPosition[client]);
	GetClientEyeAngles(client, g_fInitialAngles[client]);
	g_RecordedTicks[client] = 0;
	g_OriginSnapshotInterval[client] = 0;
}

public void StopRecording(int client)
{
	if (!IsValidClient(client) || g_hRecording[client] == null)
		return;

	CloseHandle(g_hRecording[client]);
	CloseHandle(g_hRecordingAdditionalTeleport[client]);
	g_hRecording[client] = null;
	g_hRecordingAdditionalTeleport[client] = null;

	g_RecordedTicks[client] = 0;
	g_RecordPreviousWeapon[client] = 0;
	g_CurrentAdditionalTeleportIndex[client] = 0;
	g_OriginSnapshotInterval[client] = 0;
}

public void SaveRecording(int client, int zgroup)
{
	if (!IsValidClient(client) || g_hRecording[client] == null)
		return;
	else
	{
		g_bNewReplay[client] = false;
		g_bNewBonus[client] = false;
	}

	char sPath2[256];
	// Check if the default record folder exists?
	BuildPath(Path_SM, sPath2, sizeof(sPath2), "%s", CK_REPLAY_PATH);
	if (!DirExists(sPath2))
	{
		CreateDirectory(sPath2, 511);
	}

	if (zgroup == 0) // replay bot
	{
		BuildPath(Path_SM, sPath2, sizeof(sPath2), "%s%s.rec", CK_REPLAY_PATH, g_szMapName);
	}
	else
	{
		if (zgroup > 0) // bonus bot
		{
			BuildPath(Path_SM, sPath2, sizeof(sPath2), "%s%s_bonus_%i.rec", CK_REPLAY_PATH, g_szMapName, zgroup);
		}
	}

	if (FileExists(sPath2) && GetConVarBool(g_hBackupReplays))
	{
		char newPath[256];
		Format(newPath, 256, "%s.bak", sPath2);
		RenameFile(newPath, sPath2);
	}

	char szName[MAX_NAME_LENGTH];
	GetClientName(client, szName, MAX_NAME_LENGTH);

	int iHeader[FILE_HEADER_LENGTH];
	iHeader[view_as<int>(FH_binaryFormatVersion)] = BINARY_FORMAT_VERSION;
	strcopy(iHeader[view_as<int>(FH_Time)], 32, g_szFinalTime[client]);
	iHeader[view_as<int>(FH_tickCount)] = GetArraySize(g_hRecording[client]);
	strcopy(iHeader[view_as<int>(FH_Playername)], 32, szName);
	iHeader[view_as<int>(FH_Checkpoints)] = 0; // So that KZTimers replays work
	Array_Copy(g_fInitialPosition[client], iHeader[view_as<int>(FH_initialPosition)], 3);
	Array_Copy(g_fInitialAngles[client], iHeader[view_as<int>(FH_initialAngles)], 3);
	iHeader[view_as<int>(FH_frames)] = g_hRecording[client];

	if (GetArraySize(g_hRecordingAdditionalTeleport[client]) > 0)
		SetTrieValue(g_hLoadedRecordsAdditionalTeleport, sPath2, g_hRecordingAdditionalTeleport[client]);
	else
	{
		CloseHandle(g_hRecordingAdditionalTeleport[client]);
		g_hRecordingAdditionalTeleport[client] = null;
	}

	WriteRecordToDisk(sPath2, iHeader);

	g_bNewReplay[client] = false;
	g_bNewBonus[client] = false;

	if (g_hRecording[client] != null)
		StopRecording(client);
}


public void LoadReplays()
{
	if (!GetConVarBool(g_hReplayBot) && !GetConVarBool(g_hBonusBot))
		return;
	// Init variables:
	g_bMapReplay = false;
	for (int i = 0; i < MAXZONEGROUPS; i++)
	{
		g_fReplayTimes[i] = 0.0;
		g_bMapBonusReplay[i] = false;
	}

	g_BonusBotCount = 0;
	g_RecordBot = -1;
	g_BonusBot = -1;
	g_iCurrentBonusReplayIndex = 0;
	ClearTrie(g_hLoadedRecordsAdditionalTeleport);

	// Check that map replay exists
	char sPath[256];
	BuildPath(Path_SM, sPath, sizeof(sPath), "%s%s.rec", CK_REPLAY_PATH, g_szMapName);
	if (FileExists(sPath))
	{
		setReplayTime(0);
		g_bMapReplay = true;
	}
	else// Check if backup exists
	{
		char sPathBack[256];
		BuildPath(Path_SM, sPathBack, sizeof(sPathBack), "%s%s.rec.bak", CK_REPLAY_PATH, g_szMapName);
		if (FileExists(sPathBack))
		{
			RenameFile(sPath, sPathBack);
			setReplayTime(0);
			g_bMapReplay = true;
		}
	}

	// Try to fix old bonus replays
	BuildPath(Path_SM, sPath, sizeof(sPath), "%s%s_Bonus.rec", CK_REPLAY_PATH, g_szMapName);
	Handle hFilex = OpenFile(sPath, "r");

	if (hFilex != null)
	{
		int iFileHeader[FILE_HEADER_LENGTH];
		float initPos[3];
		char newPath[256];
		LoadRecordFromFile(sPath, iFileHeader);
		Array_Copy(iFileHeader[view_as<int>(FH_initialPosition)], initPos, 3);
		int zId = IsInsideZone(initPos, 50.0);
		if (zId != -1 && g_mapZones[zId][zoneGroup] != 0)
		{
			BuildPath(Path_SM, newPath, sizeof(newPath), "%s%s_bonus_%i.rec", CK_REPLAY_PATH, g_szMapName, g_mapZones[zId][zoneGroup]);
			if (RenameFile(newPath, sPath))
				PrintToServer("SurfTimer | Succesfully renamed bonus record file to: %s", newPath);
		}
		CloseHandle(hFilex);
	}
	hFilex = null;

	// Check if bonus replays exists
	for (int i = 1; i < g_mapZoneGroupCount; i++)
	{
		BuildPath(Path_SM, sPath, sizeof(sPath), "%s%s_bonus_%i.rec", CK_REPLAY_PATH, g_szMapName, i);
		if (FileExists(sPath))
		{
			setReplayTime(i);
			g_iBonusToReplay[g_BonusBotCount] = i;
			g_BonusBotCount++;
			g_bMapBonusReplay[i] = true;
		}
		else// Check if backup exists
		{
			char sPathBack[256];
			BuildPath(Path_SM, sPathBack, sizeof(sPathBack), "%s%s_bonus_%i.rec.bak", CK_REPLAY_PATH, g_szMapName, i);
			if (FileExists(sPathBack))
			{
				setReplayTime(i);
				RenameFile(sPath, sPathBack);
				g_iBonusToReplay[g_BonusBotCount] = i;
				g_BonusBotCount++;
				g_bMapBonusReplay[i] = true;
			}
		}
	}
	if (g_bMapReplay)
		CreateTimer(1.0, RefreshBot, TIMER_FLAG_NO_MAPCHANGE);

	if (g_BonusBotCount > 0)
		CreateTimer(1.0, RefreshBonusBot, TIMER_FLAG_NO_MAPCHANGE);
}

public void PlayRecord(int client, int type)
{
	if (!IsValidClient(client))
		return;
	char buffer[256];
	char sPath[256];
	if (type == 0)
		Format(sPath, sizeof(sPath), "%s%s.rec", CK_REPLAY_PATH, g_szMapName);
	if (type == 1)
		Format(sPath, sizeof(sPath), "%s%s_bonus_%i.rec", CK_REPLAY_PATH, g_szMapName, g_iBonusToReplay[g_iCurrentBonusReplayIndex]);
	// He's currently recording. Don't start to play some record on him at the same time.
	if (g_hRecording[client] != null || !IsFakeClient(client))
		return;

	int iFileHeader[FILE_HEADER_LENGTH];
	BuildPath(Path_SM, sPath, sizeof(sPath), "%s", sPath);
	LoadRecordFromFile(sPath, iFileHeader);

	if (type == 0)
	{
		Format(g_szReplayTime, sizeof(g_szReplayTime), "%s", iFileHeader[view_as<int>(FH_Time)]);
		Format(g_szReplayName, sizeof(g_szReplayName), "%s", iFileHeader[view_as<int>(FH_Playername)]);
		Format(buffer, sizeof(buffer), "%s (%s)", g_szReplayName, g_szReplayTime);
		CS_SetClientClanTag(client, "SR Replay");
		SetClientName(client, buffer);
	}
	else
	{
		Format(g_szBonusTime, sizeof(g_szBonusTime), "%s", iFileHeader[view_as<int>(FH_Time)]);
		Format(g_szBonusName, sizeof(g_szBonusName), "%s", iFileHeader[view_as<int>(FH_Playername)]);
		Format(buffer, sizeof(buffer), "%s (%s)", g_szBonusName, g_szBonusTime);
		CS_SetClientClanTag(client, "SRB Replay");
		SetClientName(client, buffer);
	}
	g_hBotMimicsRecord[client] = iFileHeader[view_as<int>(FH_frames)];
	g_BotMimicTick[client] = 0;
	g_BotMimicRecordTickCount[client] = iFileHeader[view_as<int>(FH_tickCount)];
	g_CurrentAdditionalTeleportIndex[client] = 0;

	Array_Copy(iFileHeader[view_as<int>(FH_initialPosition)], g_fInitialPosition[client], 3);
	Array_Copy(iFileHeader[view_as<int>(FH_initialAngles)], g_fInitialAngles[client], 3);
	SDKHook(client, SDKHook_WeaponCanSwitchTo, Hook_WeaponCanSwitchTo);
	// Respawn him to get him moving!
	if (IsValidClient(client) && !IsPlayerAlive(client) && GetClientTeam(client) >= CS_TEAM_T)
	{
		CS_RespawnPlayer(client);
		if (GetConVarBool(g_hForceCT))
			TeamChangeActual(client, 2);
	}
}

public void WriteRecordToDisk(const char[] sPath, iFileHeader[FILE_HEADER_LENGTH])
{
	Handle hFile = OpenFile(sPath, "wb");
	if (hFile == null)
	{
		LogError("Can't open the record file for writing! (%s)", sPath);
		return;
	}

	WriteFileCell(hFile, BM_MAGIC, 4);
	WriteFileCell(hFile, iFileHeader[view_as<int>(FH_binaryFormatVersion)], 1);
	WriteFileCell(hFile, strlen(iFileHeader[view_as<int>(FH_Time)]), 1);
	WriteFileString(hFile, iFileHeader[view_as<int>(FH_Time)], false);
	WriteFileCell(hFile, strlen(iFileHeader[view_as<int>(FH_Playername)]), 1);
	WriteFileString(hFile, iFileHeader[view_as<int>(FH_Playername)], false);
	WriteFileCell(hFile, iFileHeader[view_as<int>(FH_Checkpoints)], 4);
	WriteFile(hFile, view_as<int>(iFileHeader[view_as<int>(FH_initialPosition)]), 3, 4);
	WriteFile(hFile, view_as<int>(iFileHeader[view_as<int>(FH_initialAngles)]), 2, 4);

	Handle hAdditionalTeleport;
	int iATIndex;
	GetTrieValue(g_hLoadedRecordsAdditionalTeleport, sPath, hAdditionalTeleport);

	int iTickCount = iFileHeader[view_as<int>(FH_tickCount)];
	WriteFileCell(hFile, iTickCount, 4);

	int iFrame[FRAME_INFO_SIZE];
	for (int i = 0; i < iTickCount; i++)
	{
		GetArrayArray(iFileHeader[view_as<int>(FH_frames)], i, iFrame, view_as<int>(FrameInfo));
		WriteFile(hFile, iFrame, view_as<int>(FrameInfo), 4);

		// Handle the optional Teleport call
		if (hAdditionalTeleport != null && iFrame[view_as<int>(additionalFields)] & (ADDITIONAL_FIELD_TELEPORTED_ORIGIN | ADDITIONAL_FIELD_TELEPORTED_ANGLES | ADDITIONAL_FIELD_TELEPORTED_VELOCITY))
		{
			int iAT[AT_SIZE];
			GetArrayArray(hAdditionalTeleport, iATIndex, iAT, AT_SIZE);
			if (iFrame[view_as<int>(additionalFields)] & ADDITIONAL_FIELD_TELEPORTED_ORIGIN)
				WriteFile(hFile, view_as<int>(iAT[view_as<int>(atOrigin)]), 3, 4);
			if (iFrame[view_as<int>(additionalFields)] & ADDITIONAL_FIELD_TELEPORTED_ANGLES)
				WriteFile(hFile, view_as<int>(iAT[view_as<int>(atAngles)]), 3, 4);
			if (iFrame[view_as<int>(additionalFields)] & ADDITIONAL_FIELD_TELEPORTED_VELOCITY)
				WriteFile(hFile, view_as<int>(iAT[view_as<int>(atVelocity)]), 3, 4);
			iATIndex++;
		}
	}

	CloseHandle(hFile);
	LoadReplays();
}

public void LoadRecordFromFile(const char[] path, int headerInfo[FILE_HEADER_LENGTH])
{
	Handle hFile = OpenFile(path, "rb");
	if (hFile == null)
		return;
	int iMagic;
	ReadFileCell(hFile, iMagic, 4);
	if (iMagic != BM_MAGIC)
	{
		CloseHandle(hFile);
		return;
	}
	int iBinaryFormatVersion;
	ReadFileCell(hFile, iBinaryFormatVersion, 1);
	headerInfo[view_as<int>(FH_binaryFormatVersion)] = iBinaryFormatVersion;

	if (iBinaryFormatVersion > BINARY_FORMAT_VERSION)
	{
		CloseHandle(hFile);
		return;
	}

	int iNameLength;
	ReadFileCell(hFile, iNameLength, 1);
	char szTime[MAX_NAME_LENGTH];
	ReadFileString(hFile, szTime, iNameLength + 1, iNameLength);
	szTime[iNameLength] = '\0';

	int iNameLength2;
	ReadFileCell(hFile, iNameLength2, 1);
	char szName[MAX_NAME_LENGTH];
	ReadFileString(hFile, szName, iNameLength2 + 1, iNameLength2);
	szName[iNameLength2] = '\0';

	int iCp;
	ReadFileCell(hFile, iCp, 4);

	ReadFile(hFile, view_as<int>(headerInfo[view_as<int>(FH_initialPosition)]), 3, 4);
	ReadFile(hFile, view_as<int>(headerInfo[view_as<int>(FH_initialAngles)]), 2, 4);

	int iTickCount;
	ReadFileCell(hFile, iTickCount, 4);

	strcopy(headerInfo[view_as<int>(FH_Time)], 32, szTime);
	strcopy(headerInfo[view_as<int>(FH_Playername)], 32, szName);
	headerInfo[view_as<int>(FH_Checkpoints)] = iCp;
	headerInfo[view_as<int>(FH_tickCount)] = iTickCount;
	headerInfo[view_as<int>(FH_frames)] = null;

	Handle hRecordFrames = CreateArray(view_as<int>(FrameInfo));
	Handle hAdditionalTeleport = CreateArray(AT_SIZE);

	int iFrame[FRAME_INFO_SIZE];
	for (int i = 0; i < iTickCount; i++)
	{
		ReadFile(hFile, iFrame, view_as<int>(FrameInfo), 4);
		PushArrayArray(hRecordFrames, iFrame, view_as<int>(FrameInfo));

		if (iFrame[view_as<int>(additionalFields)] & (ADDITIONAL_FIELD_TELEPORTED_ORIGIN | ADDITIONAL_FIELD_TELEPORTED_ANGLES | ADDITIONAL_FIELD_TELEPORTED_VELOCITY))
		{
			int iAT[AT_SIZE];
			if (iFrame[view_as<int>(additionalFields)] & ADDITIONAL_FIELD_TELEPORTED_ORIGIN)
				ReadFile(hFile, view_as<int>(iAT[atOrigin]), 3, 4);
			if (iFrame[view_as<int>(additionalFields)] & ADDITIONAL_FIELD_TELEPORTED_ANGLES)
				ReadFile(hFile, view_as<int>(iAT[atAngles]), 3, 4);
			if (iFrame[view_as<int>(additionalFields)] & ADDITIONAL_FIELD_TELEPORTED_VELOCITY)
				ReadFile(hFile, view_as<int>(iAT[atVelocity]), 3, 4);
			iAT[view_as<int>(atFlags)] = iFrame[view_as<int>(additionalFields)] & (ADDITIONAL_FIELD_TELEPORTED_ORIGIN | ADDITIONAL_FIELD_TELEPORTED_ANGLES | ADDITIONAL_FIELD_TELEPORTED_VELOCITY);
			PushArrayArray(hAdditionalTeleport, iAT, AT_SIZE);
		}
	}

	headerInfo[view_as<int>(FH_frames)] = hRecordFrames;

	if (GetArraySize(hAdditionalTeleport) > 0)
		SetTrieValue(g_hLoadedRecordsAdditionalTeleport, path, hAdditionalTeleport);
	CloseHandle(hFile);

	return;
}

public Action RefreshBot(Handle timer)
{
	setBotQuota();
	LoadRecordReplay();
	return Plugin_Handled;
}

public void LoadRecordReplay()
{
	g_RecordBot = -1;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i) || !IsFakeClient(i) || i == g_InfoBot || i == g_BonusBot)
			continue;
		if (!IsPlayerAlive(i))
		{
			CS_RespawnPlayer(i);
			if (GetConVarBool(g_hForceCT))
				TeamChangeActual(i, 2);
		}

		g_RecordBot = i;
		g_fCurrentRunTime[g_RecordBot] = 0.0;
		break;
	}

	if (IsValidClient(g_RecordBot))
	{
		char clantag[100];
		CS_GetClientClanTag(g_RecordBot, clantag, sizeof(clantag));
		if (StrContains(clantag, "REPLAY") == -1)
			g_bNewRecordBot = true;

		g_iClientInZone[g_RecordBot][2] = 0;
		PlayRecord(g_RecordBot, 0);
		// We can start multiple bots but first we need to get if bot has finished playing???
		SetEntityRenderColor(g_RecordBot, g_ReplayBotColor[0], g_ReplayBotColor[1], g_ReplayBotColor[2], 50);
		if (GetConVarBool(g_hPlayerSkinChange))
		{
			char szBuffer[256];
			GetConVarString(g_hReplayBotPlayerModel, szBuffer, 256);
			SetEntityModel(g_RecordBot, szBuffer);

			GetConVarString(g_hReplayBotArmModel, szBuffer, 256);
			SetEntPropString(g_RecordBot, Prop_Send, "m_szArmsModel", szBuffer);
		}
	}
	else
	{
		CreateTimer(1.0, RefreshBot, TIMER_FLAG_NO_MAPCHANGE);
	}
}
public Action RefreshBonusBot(Handle timer)
{
	setBotQuota();
	LoadBonusReplay();
	return Plugin_Handled;
}

public void LoadBonusReplay()
{
	g_BonusBot = -1;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i) || !IsFakeClient(i) || i == g_InfoBot || i == g_RecordBot)
			continue;

		if (!IsPlayerAlive(i))
		{
			CS_RespawnPlayer(i);

			if (GetConVarBool(g_hForceCT))
				TeamChangeActual(i, 2);
		}

		g_BonusBot = i;
		g_fCurrentRunTime[g_BonusBot] = 0.0;
		break;
	}

	if (IsValidClient(g_BonusBot))
	{
		char clantag[100];
		CS_GetClientClanTag(g_BonusBot, clantag, sizeof(clantag));
		if (StrContains(clantag, "REPLAY") == -1)
			g_bNewBonusBot = true;
		g_iClientInZone[g_BonusBot][2] = g_iBonusToReplay[0];
		PlayRecord(g_BonusBot, 1);
		SetEntityRenderColor(g_BonusBot, g_BonusBotColor[0], g_BonusBotColor[1], g_BonusBotColor[2], 50);
		if (GetConVarBool(g_hPlayerSkinChange))
		{
			char szBuffer[256];
			GetConVarString(g_hReplayBotPlayerModel, szBuffer, 256);
			SetEntityModel(g_BonusBot, szBuffer);

			GetConVarString(g_hReplayBotArmModel, szBuffer, 256);
			SetEntPropString(g_BonusBot, Prop_Send, "m_szArmsModel", szBuffer);
		}
	}
	else
	{
		// Make sure bot_quota is set correctly and try again
		CreateTimer(1.0, RefreshBonusBot, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public void StopPlayerMimic(int client)
{
	if (!IsValidClient(client))
		return;

	g_BotMimicTick[client] = 0;
	g_CurrentAdditionalTeleportIndex[client] = 0;
	g_BotMimicRecordTickCount[client] = 0;
	g_bValidTeleportCall[client] = false;
	SDKUnhook(client, SDKHook_WeaponCanSwitchTo, Hook_WeaponCanSwitchTo);
	g_hBotMimicsRecord[client] = null;
}

public bool IsPlayerMimicing(int client)
{
	if (!IsValidClient(client))
		return false;
	return g_hBotMimicsRecord[client] != null;
}

public void RecordReplay (int client, int &buttons, int &subtype, int &seed, int &impulse, int &weapon, float angles[3], float vel[3])
{
	if (g_hRecording[client] != null && !IsFakeClient(client))
	{
		if (g_bPause[client]) //  Dont record pause frames
			return;

		int iFrame[FrameInfo];
		iFrame[playerButtons] = buttons;
		iFrame[playerImpulse] = impulse;

		float vVel[3];
		Entity_GetAbsVelocity(client, vVel);
		iFrame[actualVelocity] = vVel;
		iFrame[predictedVelocity] = vel;

		Array_Copy(angles, iFrame[predictedAngles], 2);
		iFrame[newWeapon] = CSWeapon_NONE;
		iFrame[playerSubtype] = subtype;
		iFrame[playerSeed] = seed;

		// Save the current position
		if (g_OriginSnapshotInterval[client] > ORIGIN_SNAPSHOT_INTERVAL)
		{
			int iAT[AdditionalTeleport];
			float fBuffer[3];
			GetClientAbsOrigin(client, fBuffer);
			Array_Copy(fBuffer, iAT[atOrigin], 3);

			/*GetClientEyeAngles(client, fBuffer);
			Array_Copy(fBuffer, iAT[atAngles], 3);

			Entity_GetAbsVelocity(client, fBuffer);
			Array_Copy(fBuffer, iAT[atVelocity], 3);*/

			iAT[atFlags] = ADDITIONAL_FIELD_TELEPORTED_ORIGIN;
			PushArrayArray(g_hRecordingAdditionalTeleport[client], iAT[0], view_as<int>(AdditionalTeleport));
			g_OriginSnapshotInterval[client] = 0;
		}
		g_OriginSnapshotInterval[client]++;

		// Check for additional Teleports
		if (GetArraySize(g_hRecordingAdditionalTeleport[client]) > g_CurrentAdditionalTeleportIndex[client])
		{
			int iAT[AdditionalTeleport];
			GetArrayArray(g_hRecordingAdditionalTeleport[client], g_CurrentAdditionalTeleportIndex[client], iAT[0], view_as<int>(AdditionalTeleport));
			// Remember, we were teleported this frame!
			iFrame[additionalFields] |= iAT[atFlags];
			g_CurrentAdditionalTeleportIndex[client]++;
		}

		int iNewWeapon = -1;
		// Did he change his weapon?
		if (weapon)
			iNewWeapon = weapon;
		else // Picked up a new one?
		{
			int iWeapon = Client_GetActiveWeapon(client);
			if (iWeapon != -1 && (g_RecordedTicks[client] == 0 || g_RecordPreviousWeapon[client] != iWeapon))
				iNewWeapon = iWeapon;
		}

		if (iNewWeapon != -1)
		{
			if (IsValidEntity(iNewWeapon) && IsValidEdict(iNewWeapon))
			{
				g_RecordPreviousWeapon[client] = iNewWeapon;
				char sClassName[64];
				GetEdictClassname(iNewWeapon, sClassName, sizeof(sClassName));
				ReplaceString(sClassName, sizeof(sClassName), "weapon_", "", false);
				char sWeaponAlias[64];
				CS_GetTranslatedWeaponAlias(sClassName, sWeaponAlias, sizeof(sWeaponAlias));
				CSWeaponID weaponId = CS_AliasToWeaponID(sWeaponAlias);
				iFrame[newWeapon] = weaponId;
			}
		}

		PushArrayArray(g_hRecording[client], iFrame[0], view_as<int>(FrameInfo));
		g_RecordedTicks[client]++;
	}
}

public void PlayReplay(int client, int &buttons, int &subtype, int &seed, int &impulse, int &weapon, float angles[3], float vel[3])
{
	if (g_hBotMimicsRecord[client] != null)
	{
		if (!IsPlayerAlive(client) || GetClientTeam(client) < CS_TEAM_T)
			return;

		if (g_BotMimicTick[client] >= g_BotMimicRecordTickCount[client] || g_bReplayAtEnd[client])
		{
			if (!g_bReplayAtEnd[client])
			{
				if (client == g_BonusBot)
				{
					// Call to load another replay
					if (g_iCurrentBonusReplayIndex < (g_BonusBotCount-1))
						g_iCurrentBonusReplayIndex++;
					else
						g_iCurrentBonusReplayIndex = 0;

					PlayRecord(g_BonusBot, 1);
					g_iClientInZone[g_BonusBot][2] = g_iBonusToReplay[g_iCurrentBonusReplayIndex];
				}
				g_fReplayRestarted[client] = GetEngineTime();
				SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 0.0);
				g_bReplayAtEnd[client] = true;
			}
			
			if (client != g_BonusBot)
			{
				g_BotMimicTick[client] = 0;
				g_CurrentAdditionalTeleportIndex[client] = 0;
			}

			SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
			g_bReplayAtEnd[client] = false;
			g_BotMimicTick[client] = 0;
			g_CurrentAdditionalTeleportIndex[client] = 0;
		}

		int iFrame[15];
		GetArrayArray(g_hBotMimicsRecord[client],
						g_BotMimicTick[client],
						iFrame,
						view_as<int>(FrameInfo)
					);

		buttons = iFrame[playerButtons];
		impulse = iFrame[playerImpulse];
		Array_Copy(iFrame[predictedVelocity], vel, 3);
		Array_Copy(iFrame[predictedAngles], angles, 2);
		subtype = iFrame[playerSubtype];
		seed = iFrame[playerSeed];
		weapon = 0;

		float fActualVelocity[3];
		Array_Copy(iFrame[actualVelocity], fActualVelocity, 3);

		// We're supposed to teleport stuff?
		if (iFrame[additionalFields] & (ADDITIONAL_FIELD_TELEPORTED_ORIGIN | ADDITIONAL_FIELD_TELEPORTED_ANGLES | ADDITIONAL_FIELD_TELEPORTED_VELOCITY))
		{
			int iAT[10];
			Handle hAdditionalTeleport;
			char sPath[PLATFORM_MAX_PATH];
			if (client == g_RecordBot)
				Format(sPath, sizeof(sPath), "%s%s.rec", CK_REPLAY_PATH, g_szMapName);
			else
				if (client == g_BonusBot)
					Format(sPath, sizeof(sPath), "%s%s_bonus_%i.rec", CK_REPLAY_PATH, g_szMapName, g_iBonusToReplay[g_iCurrentBonusReplayIndex]);

			BuildPath(Path_SM, sPath, sizeof(sPath), "%s", sPath);
			if (g_hLoadedRecordsAdditionalTeleport != null)
			{
				GetTrieValue(g_hLoadedRecordsAdditionalTeleport, sPath, hAdditionalTeleport);
				if (hAdditionalTeleport != null)
					GetArrayArray(hAdditionalTeleport, g_CurrentAdditionalTeleportIndex[client], iAT, 10);

				float fOrigin[3], fAngles[3], fVelocity[3];
				Array_Copy(iAT[atOrigin], fOrigin, 3);
				Array_Copy(iAT[atAngles], fAngles, 3);
				Array_Copy(iAT[atVelocity], fVelocity, 3);

				// The next call to Teleport is ok.
				g_bValidTeleportCall[client] = true;

				if (iAT[atFlags] & ADDITIONAL_FIELD_TELEPORTED_ORIGIN)
				{
					if (iAT[atFlags] & ADDITIONAL_FIELD_TELEPORTED_ANGLES)
					{
						if (iAT[atFlags] & ADDITIONAL_FIELD_TELEPORTED_VELOCITY)
							TeleportEntity(client, fOrigin, fAngles, fVelocity);
						else
							TeleportEntity(client, fOrigin, fAngles, NULL_VECTOR);
					}
					else
					{
						if (iAT[atFlags] & ADDITIONAL_FIELD_TELEPORTED_VELOCITY)
							TeleportEntity(client, fOrigin, NULL_VECTOR, fVelocity);
						else
							TeleportEntity(client, fOrigin, NULL_VECTOR, NULL_VECTOR);
					}
				}
				else
				{
					if (iAT[atFlags] & ADDITIONAL_FIELD_TELEPORTED_ANGLES)
					{
						if (iAT[atFlags] & ADDITIONAL_FIELD_TELEPORTED_VELOCITY)
							TeleportEntity(client, NULL_VECTOR, fAngles, fVelocity);
						else
							TeleportEntity(client, NULL_VECTOR, fAngles, NULL_VECTOR);
					}
					else
					{
						if (iAT[atFlags] & ADDITIONAL_FIELD_TELEPORTED_VELOCITY)
							TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, fVelocity);
					}
				}
				g_CurrentAdditionalTeleportIndex[client]++;
			}
		}

		// This is the first tick. Teleport him to the initial position
		if (g_BotMimicTick[client] == 0)
		{
			CL_OnStartTimerPress(client);
			g_bValidTeleportCall[client] = true;
			TeleportEntity(client, g_fInitialPosition[client], g_fInitialAngles[client], fActualVelocity);

		}
		else
		{
			g_bValidTeleportCall[client] = true;
			TeleportEntity(client, NULL_VECTOR, angles, fActualVelocity);
		}

		if (iFrame[newWeapon] != CSWeapon_NONE)
		{
			char sAlias[64];
			CS_WeaponIDToAlias(iFrame[newWeapon], sAlias, sizeof(sAlias));

			Format(sAlias, sizeof(sAlias), "weapon_%s", sAlias);

			if (g_BotMimicTick[client] > 0 && Client_HasWeapon(client, sAlias))
			{
				weapon = Client_GetWeapon(client, sAlias);
				g_BotActiveWeapon[client] = weapon;
				InstantSwitch(client, weapon);
			}
			else
			{
				if ((client == g_RecordBot && g_bNewRecordBot) || (client == g_BonusBot && g_bNewBonusBot))
				{
					bool hasweapon;
					if (client == g_RecordBot)
						g_bNewRecordBot = false;
					else
						if (client == g_BonusBot)
							g_bNewBonusBot = false;

					if (StrEqual(sAlias, "weapon_hkp2000") && !hasweapon)
					{
						if (Client_HasWeapon(client, "weapon_hkp2000"))
						{
							weapon = Client_GetWeapon(client, sAlias);
							g_BotActiveWeapon[client] = weapon;
							hasweapon = true;
							InstantSwitch(client, weapon);

						}
						Format(sAlias, sizeof(sAlias), "weapon_usp_silencer", sAlias);
					}

					if (!hasweapon)
					{
						weapon = GivePlayerItem(client, sAlias);
						if (weapon != INVALID_ENT_REFERENCE)
						{
							g_BotActiveWeapon[client] = weapon;
							// Grenades shouldn't be equipped.
							if (StrContains(sAlias, "grenade") == -1
								 && StrContains(sAlias, "flashbang") == -1
								 && StrContains(sAlias, "decoy") == -1
								 && StrContains(sAlias, "molotov") == -1)
							{
								EquipPlayerWeapon(client, weapon);
							}
							InstantSwitch(client, weapon);
						}
					}
				}
				else
				{
					weapon = Client_GetWeapon(client, sAlias);
					g_BotActiveWeapon[client] = weapon;
					InstantSwitch(client, weapon);
				}
			}
		}
		g_BotMimicTick[client]++;
	}
}
