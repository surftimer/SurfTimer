
// Botmimic3 - modified by 1NutWunDeR
// http://forums.alliedmods.net/showthread.php?t=164148

void setReplayTime(int zGrp, int stage, int style)
{
	char sPath[256], sTime[54], sBuffer[4][54];
	if (zGrp > 0)
	{
		if (style == 0)
			BuildPath(Path_SM, sPath, sizeof(sPath), "%s%s_bonus_%d.rec", CK_REPLAY_PATH, g_szMapName, zGrp);
		else
			BuildPath(Path_SM, sPath, sizeof(sPath), "%s%s_bonus_%d_style_%d.rec", CK_REPLAY_PATH, g_szMapName, zGrp, style);
	}
	else if (stage > 0)
		BuildPath(Path_SM, sPath, sizeof(sPath), "%s%s_stage_%d.rec", CK_REPLAY_PATH, g_szMapName, stage);
	else
	{
		if (style == 0)
			BuildPath(Path_SM, sPath, sizeof(sPath), "%s%s.rec", CK_REPLAY_PATH, g_szMapName);
		else
			BuildPath(Path_SM, sPath, sizeof(sPath), "%s%s_style_%d.rec", CK_REPLAY_PATH, g_szMapName, style);
	}

	int iFileHeader[FILE_HEADER_LENGTH];
	LoadRecordFromFile(sPath, iFileHeader, true);
	Format(sTime, sizeof(sTime), "%s", iFileHeader[view_as<int>(FH_Time)]);

	ExplodeString(sTime, ":", sBuffer, 4, 54);
	float time = (StringToFloat(sBuffer[0]) * 60);
	time += StringToFloat(sBuffer[1]);
	time += (StringToFloat(sBuffer[2]) / 100);
	if (zGrp == 0 && stage == 0)
	{
		// Map
		if (style == 0)
		{
			if ((g_fRecordMapTime - 0.01) < time < (g_fRecordMapTime) + 0.01)
				time = g_fRecordMapTime;
		}
		else
		{
			if ((g_fRecordStyleMapTime[style] - 0.01) < time < (g_fRecordStyleMapTime[style]) + 0.01)
				time = g_fRecordStyleMapTime[style];
		}
	}
	else if (stage > 0)
	{
		// Stage
		if ((g_fStageRecord[stage] - 0.01) < time < (g_fStageRecord[stage]) + 0.01)
			g_fStageReplayTimes[stage] = g_fStageRecord[stage];
		else
			g_fStageReplayTimes[stage] = time;
		return;
	}
	else
	{
		// Bonus
		if (style == 0)
		{
			if ((g_fBonusFastest[zGrp] - 0.01) < time < (g_fBonusFastest[zGrp]) + 0.01)
				time = g_fBonusFastest[zGrp];
		}
		else
		{
			if ((g_fStyleBonusFastest[style][zGrp] - 0.01) < time < (g_fStyleBonusFastest[style][zGrp]) + 0.01)
				time = g_fStyleBonusFastest[style][zGrp];
		}
	}

	g_fReplayTimes[zGrp][style] = time;
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

public void SaveRecording(int client, int zgroup, int style)
{
	if (!IsValidClient(client) || g_hRecording[client] == null)
		return;
	else
	{
		g_bNewReplay[client] = false;
		g_bNewBonus[client] = false;
	}

	char sPath2[256];
	// Check if the default record folder exists
	BuildPath(Path_SM, sPath2, sizeof(sPath2), "%s", CK_REPLAY_PATH);
	if (!DirExists(sPath2))
		CreateDirectory(sPath2, 511);

	// Build path
	char sPath3[256];
	Format(sPath3, sizeof(sPath3), "%s%s", CK_REPLAY_PATH, g_szMapName);

	// Bonus replay path
	if (zgroup > 0)
		Format(sPath3, sizeof(sPath3), "%s_bonus_%d", sPath3, zgroup);
	
	// Style replay path
	if (style > 0)
		Format(sPath3, sizeof(sPath3), "%s_style_%d", sPath3, style);
	
	// Finish the path
	Format(sPath3, sizeof(sPath3), "%s.rec", sPath3);
	BuildPath(Path_SM, sPath2, sizeof(sPath2), sPath3);

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
		CloseHandle(g_hRecordingAdditionalTeleport[client]);

	g_hRecordingAdditionalTeleport[client] = null;

	WriteRecordToDisk(sPath2, iHeader);

	g_bNewReplay[client] = false;
	g_bNewBonus[client] = false;

	if (g_hRecording[client] != null)
		StopRecording(client);
}


public void LoadReplays()
{
	if (!GetConVarBool(g_hReplayBot) && !GetConVarBool(g_hBonusBot) && !GetConVarBool(g_hWrcpBot))
		return;

	// Init Variables:
	for (int i = 0; i < MAX_STYLES; i++)
		g_bMapReplay[i] = false;
	for (int i = 0; i < MAXZONEGROUPS; i++)
	{
		for (int j = 0; j < MAX_STYLES; j++)
		{
			g_fReplayTimes[i][j] = 0.0;
			g_bMapBonusReplay[i][j] = false;
		}
	}

	for (int i = 1; i <= g_TotalStages; i++)
	{
		g_bStageReplay[i] = false;
	}

	g_BonusBotCount = 0;
	g_RecordBot = -1;
	g_BonusBot = -1;
	g_WrcpBot = -1;
	g_iCurrentBonusReplayIndex = 0;

	Handle hSnapshot = CreateTrieSnapshot(g_hLoadedRecordsAdditionalTeleport);
	int iSnapshotLength = TrieSnapshotLength(hSnapshot);
	char sKey[PLATFORM_MAX_PATH];
	Handle hAT;
	for (int i = 0; i < iSnapshotLength; i++)
	{
		GetTrieSnapshotKey(hSnapshot, i, sKey, sizeof(sKey));
		GetTrieValue(g_hLoadedRecordsAdditionalTeleport, sKey, hAT);
		delete hAT;
	}
	CloseHandle(hSnapshot);
	ClearTrie(g_hLoadedRecordsAdditionalTeleport);

	g_bFirstStageReplay = false;
	if (g_bhasStages)
	{
		char sPath2[256];
		for (int i = 1; i <= g_TotalStages; i++)
		{
			BuildPath(Path_SM, sPath2, sizeof(sPath2), "%s%s_stage_%d.rec", CK_REPLAY_PATH, g_szMapName, i);
			if (FileExists(sPath2))
			{
				if (!g_bFirstStageReplay)
				{
					g_StageReplayCurrentStage = i;
					g_bFirstStageReplay = true;
				}
				g_bStageReplay[i] = true;
				setReplayTime(0, i, 0);
			}
		}
		g_StageReplaysLoop = 1;
	}


	ClearTrie(g_hLoadedRecordsAdditionalTeleport);

	// Check that map replay exists
	char sPath[256];
	BuildPath(Path_SM, sPath, sizeof(sPath), "%s%s.rec", CK_REPLAY_PATH, g_szMapName);
	if (FileExists(sPath))
	{
		setReplayTime(0, 0, 0);
		g_bMapReplay[0] = true;
	}
	else// Check if backup exists
	{
		char sPathBack[256];
		BuildPath(Path_SM, sPathBack, sizeof(sPathBack), "%s%s.rec.bak", CK_REPLAY_PATH, g_szMapName);
		if (FileExists(sPathBack))
		{
			RenameFile(sPath, sPathBack);
			setReplayTime(0, 0, 0);
			g_bMapReplay[0] = true;
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
		LoadRecordFromFile(sPath, iFileHeader, true);
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
	delete hFilex;

	// Check if bonus replays exists
	for (int i = 1; i < g_mapZoneGroupCount; i++)
	{
		BuildPath(Path_SM, sPath, sizeof(sPath), "%s%s_bonus_%i.rec", CK_REPLAY_PATH, g_szMapName, i);
		if (FileExists(sPath))
		{
			setReplayTime(i, 0, 0);
			g_iBonusToReplay[g_BonusBotCount] = i;
			g_BonusBotCount++;
			g_bMapBonusReplay[i][0] = true;
		}
		else
		{
			// Check if backup exists
			char sPathBack[256];
			BuildPath(Path_SM, sPathBack, sizeof(sPathBack), "%s%s_bonus_%i.rec.bak", CK_REPLAY_PATH, g_szMapName, i);
			if (FileExists(sPathBack))
			{
				setReplayTime(i, 0, 0);
				RenameFile(sPath, sPathBack);
				g_iBonusToReplay[g_BonusBotCount] = i;
				g_BonusBotCount++;
				g_bMapBonusReplay[i][0] = true;
			}
		}
	}

	// Check if style map replays exist
	for (int i = 1; i < MAX_STYLES; i++)
	{
		BuildPath(Path_SM, sPath, sizeof(sPath), "%s%s_style_%d.rec", CK_REPLAY_PATH, g_szMapName, i);
		if (FileExists(sPath))
		{
			g_bMapReplay[i] = true;
			setReplayTime(0, 0, i);
		}
		else
		{
			// Check if backup exists
			char sPathBack[256];
			BuildPath(Path_SM, sPathBack, sizeof(sPathBack), "%s%s_style_%d.rec.bak", CK_REPLAY_PATH, g_szMapName, i);
			if (FileExists(sPathBack))
			{
				g_bMapReplay[i] = true;
				setReplayTime(0, 0, i);
				RenameFile(sPath, sPathBack);
			}
		}
	}

	// Check if style bonus replays exist
	for (int i = 1; i < MAXZONEGROUPS; i++)
	{
		for (int j = 1; j < MAX_STYLES; j++)
		{
			BuildPath(Path_SM, sPath, sizeof(sPath), "%s%s_bonus_%d_style_%d.rec", CK_REPLAY_PATH, g_szMapName, i, j);
			if (FileExists(sPath))
			{
				g_bMapBonusReplay[i][j] = true;
				setReplayTime(i, 0, j);
			}
			else
			{
				// Check if backup exists
				char sPathBack[256];
				BuildPath(Path_SM, sPathBack, sizeof(sPathBack), "%s%s_bonus_%d_style_%d.rec.bak", CK_REPLAY_PATH, g_szMapName, i, j);
				if (FileExists(sPathBack))
				{
					g_bMapBonusReplay[i][j] = true;
					setReplayTime(i, 0, j);
					RenameFile(sPath, sPathBack);
				}
			}
		}
	}

	if (g_bMapReplay[0])
		CreateTimer(1.0, RefreshBot, TIMER_FLAG_NO_MAPCHANGE);

	if (g_BonusBotCount > 0)
		CreateTimer(1.0, RefreshBonusBot, TIMER_FLAG_NO_MAPCHANGE);

	if (g_bhasStages)
		CreateTimer(1.0, RefreshWrcpBot, TIMER_FLAG_NO_MAPCHANGE);
}

public void PlayRecord(int client, int type, int style)
{
	// He's currently recording. Don't start to play some record on him at the same time.
	if (!IsValidClient(client) || g_hRecording[client] != null || !IsFakeClient(client))
		return;

	char buffer[256];
	char sPath[256];

	int bonus;
	if (type > 0)
	{
		if (g_iCurrentBonusReplayIndex == 99)
			bonus = type;
		else
			bonus = g_iBonusToReplay[g_iCurrentBonusReplayIndex];
	}

	if (style == 0)
	{
		if (type == 0)
			Format(sPath, sizeof(sPath), "%s%s.rec", CK_REPLAY_PATH, g_szMapName);
		else if (type > 0)
			Format(sPath, sizeof(sPath), "%s%s_bonus_%d.rec", CK_REPLAY_PATH, g_szMapName, bonus);
		else if (type < 0)
			Format(sPath, sizeof(sPath), "%s%s_stage_%d.rec", CK_REPLAY_PATH, g_szMapName, (type * -1));
	}
	else
	{
		if (type == 0)
			Format(sPath, sizeof(sPath), "%s%s_style_%d.rec", CK_REPLAY_PATH, g_szMapName, style);
		else if (type > 0)
			Format(sPath, sizeof(sPath), "%s%s_bonus_%d_style_%d.rec", CK_REPLAY_PATH, g_szMapName, bonus, style);
		else if (type < 0)
			Format(sPath, sizeof(sPath), "%s%s_stage_%d_style_%d.rec", CK_REPLAY_PATH, g_szMapName, (type * -1), style);
	}

	int iFileHeader[FILE_HEADER_LENGTH];
	BuildPath(Path_SM, sPath, sizeof(sPath), "%s", sPath);
	LoadRecordFromFile(sPath, iFileHeader, false);

	if (type == 0)
	{
		Format(g_szReplayTime, sizeof(g_szReplayTime), "%s", iFileHeader[view_as<int>(FH_Time)]);
		Format(g_szReplayName, sizeof(g_szReplayName), "%s", iFileHeader[view_as<int>(FH_Playername)]);
		if (style == 0)
		{
			Format(buffer, sizeof(buffer), "%s (%s)", g_szReplayName, g_szReplayTime);
			CS_SetClientClanTag(client, "MAP Replay");
			SetClientName(client, buffer);
		}
		else
		{
			// get style acronym and make it upper case
			char buffer2[128];
			Format(buffer2, sizeof(buffer2), g_szStyleAcronyms[style]);
			StringToUpper(buffer2);
			
			Format(buffer, sizeof(buffer), "%s: %s (%s)", buffer2, g_szReplayName, g_szReplayTime);
			SetClientName(client, buffer);

			Format(buffer, sizeof(buffer), "MAP Replay (%s)", buffer2);
			CS_SetClientClanTag(client, buffer);
		}
	}
	else if (type < 0)
	{
		int stage = type * -1;
		Format(g_szWrcpReplayTime[stage], sizeof(g_szWrcpReplayTime), "%s", iFileHeader[view_as<int>(FH_Time)]);
		Format(g_szWrcpReplayName[stage], sizeof(g_szWrcpReplayName), "%s", iFileHeader[view_as<int>(FH_Playername)]);
		Format(buffer, sizeof(buffer), "S%d %s (%s)", stage, g_szWrcpReplayName[stage], g_szWrcpReplayTime[stage]);
		g_iCurrentlyPlayingStage = stage;
		CS_SetClientClanTag(client, "STAGE Replay");
		SetClientName(client, buffer);
	}
	else
	{
		Format(g_szBonusTime, sizeof(g_szBonusTime), "%s", iFileHeader[view_as<int>(FH_Time)]);
		Format(g_szBonusName, sizeof(g_szBonusName), "%s", iFileHeader[view_as<int>(FH_Playername)]);
		if (style == 0)
		{
			Format(buffer, sizeof(buffer), "%s (%s)", g_szBonusName, g_szBonusTime);
			CS_SetClientClanTag(client, "BONUS Replay");
			SetClientName(client, buffer);
		}
		else
		{
			// get style acronym and make it upper case
			char buffer2[128];
			Format(buffer2, sizeof(buffer2), g_szStyleAcronyms[style]);
			StringToUpper(buffer2);
			
			Format(buffer, sizeof(buffer), "%s: %s (%s)", buffer2, g_szBonusName, g_szBonusTime);
			SetClientName(client, buffer);

			Format(buffer, sizeof(buffer), "SRB Replay (%s)", buffer2);
			CS_SetClientClanTag(client, buffer);
		}
	}

	g_hBotMimicsRecord[client] = iFileHeader[view_as<int>(FH_frames)];
	g_BotMimicTick[client] = 0;
	g_BotMimicRecordTickCount[client] = iFileHeader[view_as<int>(FH_tickCount)];
	g_CurrentAdditionalTeleportIndex[client] = 0;

	Array_Copy(iFileHeader[view_as<int>(FH_initialPosition)], g_fInitialPosition[client], 3);
	Array_Copy(iFileHeader[view_as<int>(FH_initialAngles)], g_fInitialAngles[client], 3);

	// Disarm bot
	Client_RemoveAllWeapons(client);

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

public void LoadRecordFromFile(const char[] path, int headerInfo[FILE_HEADER_LENGTH], bool headerOnly)
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

	if (headerOnly)
	{
		CloseHandle(hFile);
		return;
	}

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

	// Free any old handles if we already loaded this one once before.
	Handle hOldAT;
	if (GetTrieValue(g_hLoadedRecordsAdditionalTeleport, path, hOldAT))
	{
		delete hOldAT;
		RemoveFromTrie(g_hLoadedRecordsAdditionalTeleport, path);
	}

	if (GetArraySize(hAdditionalTeleport) > 0)
		SetTrieValue(g_hLoadedRecordsAdditionalTeleport, path, hAdditionalTeleport);
	else
		CloseHandle(hAdditionalTeleport);

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
		if (!IsValidClient(i) || !IsFakeClient(i) || IsClientSourceTV(i) || i == g_InfoBot || i == g_BonusBot || i == g_WrcpBot)
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

		// "Having a bot in noclip and zero gravity ensures it's smooth" - Crashfort
		// https://github.com/crashfort/SourceToolAssist/blob/be9218583ee0a8086c817a5bd29101b2a260e5a7/Source/surf_segmentplay.sp#L113
		// Disabling noclip, makes the bot bug.
		// Since the bot is getting teleported with angle and speed not angle and position
		// the bot sometimes will fly around like a headless fly (because of getting blocked) or choppy on a ramp
		SetEntityMoveType(g_RecordBot, MOVETYPE_NOCLIP);
		SetEntityGravity(g_RecordBot, 0.0);
		
		PlayRecord(g_RecordBot, 0, 0);
		// We can start multiple bots but first we need to get if bot has finished playing???
		SetEntityRenderColor(g_RecordBot, g_ReplayBotColor[0], g_ReplayBotColor[1], g_ReplayBotColor[2], 50);
		float fOrigin[3];
		GetClientAbsOrigin(g_RecordBot, fOrigin);
		gI_SelectedTrail[g_RecordBot] = 5;
		CreatePlayerTrail(g_RecordBot, fOrigin);
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
		if (!IsValidClient(i) || !IsFakeClient(i) || IsClientSourceTV(i) || i == g_InfoBot || i == g_RecordBot || i == g_WrcpBot)
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

		// "Having a bot in noclip and zero gravity ensures it's smooth" - Crashfort
		// https://github.com/crashfort/SourceToolAssist/blob/be9218583ee0a8086c817a5bd29101b2a260e5a7/Source/surf_segmentplay.sp#L113
		// Disabling noclip, makes the bot bug.
		// Since the bot is getting teleported with angle and speed not angle and position
		// the bot sometimes will fly around like a headless fly (because of getting blocked) or choppy on a ramp
		SetEntityMoveType(g_RecordBot, MOVETYPE_NOCLIP);
		SetEntityGravity(g_RecordBot, 0.0);

		PlayRecord(g_BonusBot, 1, 0);
		SetEntityRenderColor(g_BonusBot, g_BonusBotColor[0], g_BonusBotColor[1], g_BonusBotColor[2], 50);
		float fOrigin[3];
		GetClientAbsOrigin(g_BonusBot, fOrigin);
		gI_SelectedTrail[g_BonusBot] = 4;
		CreatePlayerTrail(g_BonusBot, fOrigin);
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

public Action RefreshWrcpBot(Handle timer)
{
	setBotQuota();
	LoadWrcpReplay();
	return Plugin_Handled;
}

public void LoadWrcpReplay()
{
	g_WrcpBot = -1;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i) || !IsFakeClient(i) || IsClientSourceTV(i) || i == g_InfoBot || i == g_RecordBot || i == g_BonusBot)
			continue;

		if (!IsPlayerAlive(i))
		{
			CS_RespawnPlayer(i);

			if (GetConVarBool(g_hForceCT))
				TeamChangeActual(i, 2);
		}

		g_WrcpBot = i;
		g_fCurrentRunTime[g_WrcpBot] = 0.0;
		break;
	}

	if (IsValidClient(g_WrcpBot))
	{
		char clantag[100];
		CS_GetClientClanTag(g_WrcpBot, clantag, sizeof(clantag));

		g_iClientInZone[g_WrcpBot][2] = 0;

		// "Having a bot in noclip and zero gravity ensures it's smooth" - Crashfort
		// https://github.com/crashfort/SourceToolAssist/blob/be9218583ee0a8086c817a5bd29101b2a260e5a7/Source/surf_segmentplay.sp#L113
		// Disabling noclip, makes the bot bug.
		// Since the bot is getting teleported with angle and speed not angle and position
		// the bot sometimes will fly around like a headless fly (because of getting blocked) or choppy on a ramp
		SetEntityMoveType(g_RecordBot, MOVETYPE_NOCLIP);
		SetEntityGravity(g_RecordBot, 0.0);


		PlayRecord(g_WrcpBot, -g_StageReplayCurrentStage, 0);
		SetEntityRenderColor(g_WrcpBot, 180, 142, 173, 50);
		float fOrigin[3];
		GetClientAbsOrigin(g_WrcpBot, fOrigin);
		gI_SelectedTrail[g_WrcpBot] = 7;
		CreatePlayerTrail(g_WrcpBot, fOrigin);
		if (GetConVarBool(g_hPlayerSkinChange))
		{
			char szBuffer[256];
			GetConVarString(g_hReplayBotPlayerModel, szBuffer, 256);
			SetEntityModel(g_WrcpBot, szBuffer);

			GetConVarString(g_hReplayBotArmModel, szBuffer, 256);
			SetEntPropString(g_WrcpBot, Prop_Send, "m_szArmsModel", szBuffer);
		}
	}
	else
	{
		// Make sure bot_quota is set correctly and try again
		CreateTimer(1.0, RefreshWrcpBot, TIMER_FLAG_NO_MAPCHANGE);
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
	delete g_hBotMimicsRecord[client];
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
		// Dont record pause frames
		if (g_bPause[client])
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
		if (g_OriginSnapshotInterval[client] > ORIGIN_SNAPSHOT_INTERVAL || g_createAdditionalTeleport[client])
		{
			int iAT[AdditionalTeleport];
			float fBuffer[3];
			GetClientAbsOrigin(client, fBuffer);
			Array_Copy(fBuffer, iAT[atOrigin], 3);

			iAT[atFlags] = ADDITIONAL_FIELD_TELEPORTED_ORIGIN;
			PushArrayArray(g_hRecordingAdditionalTeleport[client], iAT[0], view_as<int>(AdditionalTeleport));
			g_OriginSnapshotInterval[client] = 0;
			g_createAdditionalTeleport[client] = false;
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
			if (client == g_BonusBot)
			{
				if (g_bManualBonusReplayPlayback)
				{
					if (g_iManualBonusReplayCount < 1)
						g_iManualBonusReplayCount++;
					else
					{
						g_iManualBonusReplayCount = 0;
						g_bManualBonusReplayPlayback = false;
						g_iCurrentBonusReplayIndex = 0;
						PlayRecord(g_BonusBot, 1, 0);
						g_iClientInZone[g_BonusBot][2] = g_iBonusToReplay[g_iCurrentBonusReplayIndex];
					}
				}
				else
				{
					// Call to load another replay
					if (g_iCurrentBonusReplayIndex < (g_BonusBotCount-1))
						g_iCurrentBonusReplayIndex++;
					else
						g_iCurrentBonusReplayIndex = 0;

					PlayRecord(g_BonusBot, 1, 0);
					g_iClientInZone[g_BonusBot][2] = g_iBonusToReplay[g_iCurrentBonusReplayIndex];
				}
			}
			else if (client == g_RecordBot)
			{
				if (g_bManualReplayPlayback)
				{
					if (g_iManualReplayCount < 1)
						g_iManualReplayCount++;
					else
					{
						g_iManualReplayCount = 0;
						g_bManualReplayPlayback = false;
						PlayRecord(g_RecordBot, 0, 0);
					}
				}
			}
			else if (client == g_WrcpBot)
			{
				if (g_bManualStageReplayPlayback)
				{
					if (g_iManualStageReplayCount < 2)
						g_iManualStageReplayCount++;
					else
					{
						g_iManualStageReplayCount = 0;
						g_bManualStageReplayPlayback = false;
						g_StageReplaysLoop = 3;
						PlayRecord(g_WrcpBot, -g_StageReplayCurrentStage, 0);
					}
				}
				else
				{
					bool found = false;
					if (g_StageReplaysLoop == 3)
					{
						char sPath2[256];
						for (int i = 1; i <= g_TotalStages; i++)
						{
							if (i <= g_StageReplayCurrentStage)
								continue;

							BuildPath(Path_SM, sPath2, sizeof(sPath2), "%s%s_stage_%d.rec", CK_REPLAY_PATH, g_szMapName, i);

							if (FileExists(sPath2))
							{
								g_StageReplayCurrentStage = i;
								g_StageReplaysLoop = 0;
								found = true;
								break;
							}
						}

						if (!found)
						{
							for (int i = 1; i <= g_TotalStages; i++)
							{
								BuildPath(Path_SM, sPath2, sizeof(sPath2), "%s%s_stage_%d.rec", CK_REPLAY_PATH, g_szMapName, i);
								if (FileExists(sPath2))
								{
									g_StageReplayCurrentStage = i;
									g_StageReplaysLoop = 0;
									break;
								}
							}
						}
					}

					g_StageReplaysLoop++;
					PlayRecord(g_WrcpBot, -g_StageReplayCurrentStage, 0);
				}
			}

			if (!g_bReplayAtEnd[client])
			{
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
			{
				if (g_iSelectedReplayType == 0 && g_iSelectedReplayStyle == 0)
					Format(sPath, sizeof(sPath), "%s%s.rec", CK_REPLAY_PATH, g_szMapName);
				else if (g_iSelectedReplayType == 0 && g_iSelectedReplayStyle > 0)
					Format(sPath, sizeof(sPath), "%s%s_style_%d.rec", CK_REPLAY_PATH, g_szMapName, g_iSelectedReplayStyle);
			}
			else if (client == g_BonusBot)
			{
				int bonus = g_iSelectedReplayBonus;
				if (g_iSelectedReplayType == 1 && g_iSelectedBonusReplayStyle == 0)
				{
					if (g_iCurrentBonusReplayIndex != 99)
						Format(sPath, sizeof(sPath), "%s%s_bonus_%d.rec", CK_REPLAY_PATH, g_szMapName, g_iBonusToReplay[g_iCurrentBonusReplayIndex]);
					else
						Format(sPath, sizeof(sPath), "%s%s_bonus_%d.rec", CK_REPLAY_PATH, g_szMapName, g_iManualBonusToReplay);
				}
				else if (g_iSelectedReplayType == 1 && g_iSelectedBonusReplayStyle > 0)
					Format(sPath, sizeof(sPath), "%s%s_bonus_%d_style_%d.rec", CK_REPLAY_PATH, g_szMapName, bonus, g_iSelectedBonusReplayStyle);
			}

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
			if (g_BotMimicTick[client] > 0)
				Client_RemoveAllWeapons(client);
			else
			{
				if ((client == g_RecordBot && g_bNewRecordBot) || (client == g_BonusBot && g_bNewBonusBot))
				{
					if (client == g_RecordBot)
						g_bNewRecordBot = false;
					else
						if (client == g_BonusBot)
							g_bNewBonusBot = false;
				}
				else
					Client_RemoveAllWeapons(client);
			}
		}
		g_BotMimicTick[client]++;
	}
}

public void Stage_StartRecording(int client)
{
	if (!IsValidClient(client) || IsFakeClient(client))
		return;

	GetClientAbsOrigin(client, g_fStageInitialPosition[client]);
	GetClientEyeAngles(client, g_fStageInitialAngles[client]);

	// Client is being recorded, save the ticks where the recording started
	if (g_hRecording[client] != null) 
	{
		g_StageRecStartFrame[client] = g_RecordedTicks[client];
		g_StageRecStartAT[client] = g_CurrentAdditionalTeleportIndex[client];
		return;
	}

	char szName[MAX_NAME_LENGTH];
	GetClientName(client, szName, MAX_NAME_LENGTH);

	if (g_hRecording[client] == null)
		StartRecording(client);

	g_StageRecStartFrame[client] = 0;
	g_StageRecStartAT[client] = 0;
}

public void Stage_SaveRecording(int client, int stage, char[] time)
{
	if (!IsValidClient(client) || g_hRecording[client] == null) 
		return;

	char szName[MAX_NAME_LENGTH];
	GetClientName(client, szName, MAX_NAME_LENGTH);

	char sPath2[256];

	// Check if the default record folder exists?
	BuildPath(Path_SM, sPath2, sizeof(sPath2), "%s", CK_REPLAY_PATH);
	if (!DirExists(sPath2))
		CreateDirectory(sPath2, 511);

	BuildPath(Path_SM, sPath2, sizeof(sPath2), "%s%s_stage_%d.rec", CK_REPLAY_PATH, g_szMapName, stage);


	if (FileExists(sPath2) && GetConVarBool(g_hBackupReplays))
	{
		char newPath[256];
		Format(newPath, 256, "%s.bak", sPath2);
		RenameFile(newPath, sPath2);
	}

	// char szName[MAX_NAME_LENGTH];
	// GetClientName(client, szName, MAX_NAME_LENGTH);

	int startframe = g_StageRecStartFrame[client];
	int framesRecorded = GetArraySize(g_hRecording[client]) - startframe;

	int iHeader[FILE_HEADER_LENGTH];
	iHeader[view_as<int>(FH_binaryFormatVersion)] = BINARY_FORMAT_VERSION;
	strcopy(iHeader[view_as<int>(FH_Time)], 32, time);
	iHeader[view_as<int>(FH_tickCount)] = framesRecorded;
	strcopy(iHeader[view_as<int>(FH_Playername)], 32, szName);
	iHeader[view_as<int>(FH_Checkpoints)] = 0; // So that KZTimers replays work
	Array_Copy(g_fStageInitialPosition[client], iHeader[view_as<int>(FH_initialPosition)], 3);
	Array_Copy(g_fStageInitialAngles[client], iHeader[view_as<int>(FH_initialAngles)], 3);

	Handle frames = CreateArray(view_as<int>(FrameInfo));

	for (int i = startframe; i < GetArraySize(g_hRecording[client]); i++)
	{
		int iFrame[FRAME_INFO_SIZE];
		GetArrayArray(g_hRecording[client], i, iFrame, view_as<int>(FrameInfo));
		PushArrayArray(frames, iFrame, view_as<int>(FrameInfo));
	}

	iHeader[view_as<int>(FH_frames)] = frames;

	if (GetArraySize(g_hRecordingAdditionalTeleport[client]) > 0)
	{
		Handle additionalteleports = CreateArray(view_as<int>(AdditionalTeleport));

		for (int i = g_StageRecStartAT[client]; i < GetArraySize(g_hRecordingAdditionalTeleport[client]); i++)
		{
			int iAT[AT_SIZE];
			GetArrayArray(g_hRecordingAdditionalTeleport[client], i, iAT, AT_SIZE);
			PushArrayArray(additionalteleports, iAT, AT_SIZE);
		}

		SetTrieValue(g_hLoadedRecordsAdditionalTeleport, sPath2, additionalteleports);
	}

	WriteRecordToDisk(sPath2, iHeader);
	if (g_bSavingWrcpReplay[client])
		g_bSavingWrcpReplay[client] = false;
}
