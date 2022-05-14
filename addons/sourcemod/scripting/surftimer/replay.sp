static void SetReplayTime(int zGrp, int stage, int style)
{
	char sPath[256], sTime[54], sBuffer[4][54];

	if (zGrp > 0)
	{
		if (style == 0)
		{
			BuildPath(Path_SM, sPath, sizeof(sPath), "%s%s_bonus_%d.rec", CK_REPLAY_PATH, g_szMapName, zGrp);
		}
		else
		{
			BuildPath(Path_SM, sPath, sizeof(sPath), "%s%s_bonus_%d_style_%d.rec", CK_REPLAY_PATH, g_szMapName, zGrp, style);
		}
	}
	else if (stage > 0)
	{
		BuildPath(Path_SM, sPath, sizeof(sPath), "%s%s_stage_%d.rec", CK_REPLAY_PATH, g_szMapName, stage);
	}
	else
	{
		if (style == 0)
		{
			BuildPath(Path_SM, sPath, sizeof(sPath), "%s%s.rec", CK_REPLAY_PATH, g_szMapName);
		}
		else
		{
			BuildPath(Path_SM, sPath, sizeof(sPath), "%s%s_style_%d.rec", CK_REPLAY_PATH, g_szMapName, style);
		}
	}

	FileHeader header;
	LoadRecordFromFile(sPath, header, true);
	Format(sTime, sizeof(sTime), "%s", header.Time);

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
			{
				time = g_fRecordMapTime;
			}
		}
		else
		{
			if ((g_fRecordStyleMapTime[style] - 0.01) < time < (g_fRecordStyleMapTime[style]) + 0.01)
			{
				time = g_fRecordStyleMapTime[style];
			}
		}
	}
	else if (stage > 0)
	{
		// Stage
		if ((g_fStageRecord[stage] - 0.01) < time < (g_fStageRecord[stage]) + 0.01)
		{
			g_fStageReplayTimes[stage] = g_fStageRecord[stage];
		}
		else
		{
			g_fStageReplayTimes[stage] = time;
		}

		return;
	}
	else
	{
		// Bonus
		if (style == 0)
		{
			if ((g_fBonusFastest[zGrp] - 0.01) < time < (g_fBonusFastest[zGrp]) + 0.01)
			{
				time = g_fBonusFastest[zGrp];
			}
		}
		else
		{
			if ((g_fStyleBonusFastest[style][zGrp] - 0.01) < time < (g_fStyleBonusFastest[style][zGrp]) + 0.01)
			{
				time = g_fStyleBonusFastest[style][zGrp];
			}
		}
	}

	g_fReplayTimes[zGrp][style] = time;
}

public Action RespawnBot(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (!client)
	{
		return Plugin_Stop;
	}

	if (g_aReplayFrame[client] != null && IsValidClient(client) && !IsPlayerAlive(client) && IsFakeClient(client) && GetClientTeam(client) >= CS_TEAM_T)
	{
		TeamChangeActual(client, 2);
		CS_RespawnPlayer(client);
	}

	return Plugin_Stop;
}

// Start zone EndTouch(should be starttouch if add preframe)
public void StartRecording(int client)
{
	if (!IsValidClient(client) || IsFakeClient(client))
	{
		return;
	}

	g_iRecordedTicks[client] = 0;
}

public void StopRecording(int client)
{
	if (!IsValidClient(client))
	{
		return;
	}

	g_Recording = false;

	ClearFrame(client);
}

public void SaveRecording(int client, int zgroup, int style)
{
	if (!IsValidClient(client) || g_aRecording[client] == null)
	{
		return;
	}

	g_bNewReplay[client] = false;
	g_bNewBonus[client] = false;

	// Check if the default record folder exists
	char sPath2[256];
	BuildPath(Path_SM, sPath2, sizeof(sPath2), "%s", CK_REPLAY_PATH);
	if (!DirExists(sPath2))
	{
		CreateDirectory(sPath2, 511);
	}

	// Build path
	char sPath3[256];
	Format(sPath3, sizeof(sPath3), "%s%s", CK_REPLAY_PATH, g_szMapName);

	// Bonus replay path
	if (zgroup > 0)
	{
		Format(sPath3, sizeof(sPath3), "%s_bonus_%d", sPath3, zgroup);
	}
	
	// Style replay path
	if (style > 0)
	{
		Format(sPath3, sizeof(sPath3), "%s_style_%d", sPath3, style);
	}
	
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

	FileHeader header;
	header.BinaryFormatVersion = BINARY_FORMAT_VERSION;
	strcopy(header.Time, sizeof(FileHeader::Time), g_szFinalTime[client]);
	header.TickCount = g_iRecordedTicks[client];
	strcopy(header.Playername, sizeof(FileHeader::Playername), szName);
	header.Checkpoints = 0;
	header.Frames = g_aRecording[client];

	WriteRecordToDisk(sPath2, header);

	g_bNewReplay[client] = false;
	g_bNewBonus[client] = false;

	if (g_aRecording[client] != null)
	{
		StopRecording(client);
	}
}

static void ClearFrame(int client)
{
	delete g_aRecording[client];
	g_aRecording[client] = new ArrayList(sizeof(frame_t));
	g_iRecordedTicks[client] = 0;
}

public void LoadReplays()
{
	if (!GetConVarBool(g_hReplayBot) && !GetConVarBool(g_hBonusBot) && !GetConVarBool(g_hWrcpBot))
	{
		return;
	}

	// Init Variables:
	for (int i = 0; i < MAX_STYLES; i++)
	{
		g_bMapReplay[i] = false;
	}

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
	g_bFirstStageReplay = false;
	FileHeader nullcache;

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

				g_bStageReplay[i] = LoadRecordFromFile(sPath2, nullcache, true);
				SetReplayTime(0, i, 0);
			}
		}

		g_StageReplaysLoop = 1;
	}

	// Check that map replay exists
	char sPath[256];
	BuildPath(Path_SM, sPath, sizeof(sPath), "%s%s.rec", CK_REPLAY_PATH, g_szMapName);
	if (FileExists(sPath))
	{
		SetReplayTime(0, 0, 0);
		g_bMapReplay[0] = LoadRecordFromFile(sPath, nullcache, true);
	}
	else// Check if backup exists
	{
		char sPathBack[256];
		BuildPath(Path_SM, sPathBack, sizeof(sPathBack), "%s%s.rec.bak", CK_REPLAY_PATH, g_szMapName);
		if (FileExists(sPathBack))
		{
			RenameFile(sPath, sPathBack);
			SetReplayTime(0, 0, 0);
			g_bMapReplay[0] = LoadRecordFromFile(sPathBack, nullcache, true);
		}
	}

	// Try to fix old bonus replays
	BuildPath(Path_SM, sPath, sizeof(sPath), "%s%s_Bonus.rec", CK_REPLAY_PATH, g_szMapName);
	File fFile = OpenFile(sPath, "r");

	if (fFile != null)
	{
		FileHeader header;
		float initPos[3];
		char newPath[256];
		LoadRecordFromFile(sPath, header, true);
		Array_Copy(header.InitialPosition, initPos, 3);
		int zId = IsInsideZone(initPos, 50.0);
		if (zId != -1 && g_mapZones[zId].ZoneGroup != 0)
		{
			BuildPath(Path_SM, newPath, sizeof(newPath), "%s%s_bonus_%i.rec", CK_REPLAY_PATH, g_szMapName, g_mapZones[zId].ZoneGroup);
			if (RenameFile(newPath, sPath))
			{
				PrintToServer("SurfTimer | Succesfully renamed bonus record file to: %s", newPath);
			}
		}
	}

	delete fFile;

	// Check if bonus replays exists
	for (int i = 1; i < g_mapZoneGroupCount; i++)
	{
		BuildPath(Path_SM, sPath, sizeof(sPath), "%s%s_bonus_%i.rec", CK_REPLAY_PATH, g_szMapName, i);
		if (FileExists(sPath))
		{
			SetReplayTime(i, 0, 0);
			g_iBonusToReplay[g_BonusBotCount] = i;
			g_BonusBotCount++;
			g_bMapBonusReplay[i][0] = LoadRecordFromFile(sPath, nullcache, true);
		}
		else
		{
			// Check if backup exists
			char sPathBack[256];
			BuildPath(Path_SM, sPathBack, sizeof(sPathBack), "%s%s_bonus_%i.rec.bak", CK_REPLAY_PATH, g_szMapName, i);
			if (FileExists(sPathBack))
			{
				SetReplayTime(i, 0, 0);
				RenameFile(sPath, sPathBack);
				g_iBonusToReplay[g_BonusBotCount] = i;
				g_BonusBotCount++;
				g_bMapBonusReplay[i][0] = LoadRecordFromFile(sPathBack, nullcache, true);
			}
		}
	}

	// Check if style map replays exist
	for (int i = 1; i < MAX_STYLES; i++)
	{
		BuildPath(Path_SM, sPath, sizeof(sPath), "%s%s_style_%d.rec", CK_REPLAY_PATH, g_szMapName, i);
		if (FileExists(sPath))
		{
			g_bMapReplay[i] = LoadRecordFromFile(sPath, nullcache, true);
			SetReplayTime(0, 0, i);
		}
		else
		{
			// Check if backup exists
			char sPathBack[256];
			BuildPath(Path_SM, sPathBack, sizeof(sPathBack), "%s%s_style_%d.rec.bak", CK_REPLAY_PATH, g_szMapName, i);
			if (FileExists(sPathBack))
			{
				g_bMapReplay[i] = LoadRecordFromFile(sPathBack, nullcache, true);
				SetReplayTime(0, 0, i);
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
				g_bMapBonusReplay[i][j] = LoadRecordFromFile(sPath, nullcache, true);
				SetReplayTime(i, 0, j);
			}
			else
			{
				// Check if backup exists
				char sPathBack[256];
				BuildPath(Path_SM, sPathBack, sizeof(sPathBack), "%s%s_bonus_%d_style_%d.rec.bak", CK_REPLAY_PATH, g_szMapName, i, j);
				if (FileExists(sPathBack))
				{
					g_bMapBonusReplay[i][j] = LoadRecordFromFile(sPathBack, nullcache, true);
					SetReplayTime(i, 0, j);
					RenameFile(sPath, sPathBack);
				}
			}
		}
	}

	if (g_bMapReplay[0])
	{
		CreateTimer(1.0, RefreshBot, TIMER_FLAG_NO_MAPCHANGE);
	}

	if (g_BonusBotCount > 0)
	{
		CreateTimer(1.0, RefreshBonusBot, TIMER_FLAG_NO_MAPCHANGE);
	}

	if (g_bhasStages)
	{
		CreateTimer(1.0, RefreshWrcpBot, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public void PlayRecord(int client, int type, int style)
{
	if (!IsValidClient(client))
	{
		return;
	}

	char buffer[256];
	char sPath[256];

	int bonus;
	if (type > 0)
	{
		if (g_iCurrentBonusReplayIndex == 99)
		{
			bonus = type;
		}
		else
		{
			bonus = g_iBonusToReplay[g_iCurrentBonusReplayIndex];
		}
	}

	if (style == 0)
	{
		if (type == 0)
		{
			Format(sPath, sizeof(sPath), "%s%s.rec", CK_REPLAY_PATH, g_szMapName);
		}
		else if (type > 0)
		{
			Format(sPath, sizeof(sPath), "%s%s_bonus_%d.rec", CK_REPLAY_PATH, g_szMapName, bonus);
		}
		else if (type < 0)
		{
			Format(sPath, sizeof(sPath), "%s%s_stage_%d.rec", CK_REPLAY_PATH, g_szMapName, (type * -1));
		}
	}
	else
	{
		if (type == 0)
		{
			Format(sPath, sizeof(sPath), "%s%s_style_%d.rec", CK_REPLAY_PATH, g_szMapName, style);
		}
		else if (type > 0)
		{
			Format(sPath, sizeof(sPath), "%s%s_bonus_%d_style_%d.rec", CK_REPLAY_PATH, g_szMapName, bonus, style);
		}
		else if (type < 0)
		{
			Format(sPath, sizeof(sPath), "%s%s_stage_%d_style_%d.rec", CK_REPLAY_PATH, g_szMapName, (type * -1), style);
		}
	}

	FileHeader header;
	BuildPath(Path_SM, sPath, sizeof(sPath), "%s", sPath);
	if (!LoadRecordFromFile(sPath, header, false))
	{
		return;
	}

	if (type == 0)
	{
		Format(g_szReplayTime, sizeof(g_szReplayTime), "%s", header.Time);
		Format(g_szReplayName, sizeof(g_szReplayName), "%s", header.Playername);

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
		Format(g_szWrcpReplayTime[stage], sizeof(g_szWrcpReplayTime), "%s", header.Time);
		Format(g_szWrcpReplayName[stage], sizeof(g_szWrcpReplayName), "%s", header.Playername);
		Format(buffer, sizeof(buffer), "S%d %s (%s)", stage, g_szWrcpReplayName[stage], g_szWrcpReplayTime[stage]);
		g_iCurrentlyPlayingStage = stage;
		CS_SetClientClanTag(client, "STAGE Replay");
		SetClientName(client, buffer);
	}
	else
	{
		Format(g_szBonusTime, sizeof(g_szBonusTime), "%s", header.Time);
		Format(g_szBonusName, sizeof(g_szBonusName), "%s", header.Playername);
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

	g_aReplayFrame[client] = header.Frames;
	g_iReplayVersion[client] = header.BinaryFormatVersion;
	g_iReplayTick[client] = 0;
	g_iReplayTicksCount[client] = header.TickCount;
	g_CurrentAdditionalTeleportIndex[client] = 0;

	Array_Copy(header.InitialPosition, g_fInitialPosition[client], 3);
	Array_Copy(header.InitialAngles, g_fInitialAngles[client], 3);

	// Disarm bot
	Client_RemoveAllWeapons(client);

	// Respawn him to get him moving!
	if (IsValidClient(client) && !IsPlayerAlive(client) && GetClientTeam(client) >= CS_TEAM_T)
	{
		CS_RespawnPlayer(client);
		if (GetConVarBool(g_hForceCT))
		{
			TeamChangeActual(client, 2);
		}
	}
}

public bool WriteRecordToDisk(const char[] sPath, FileHeader header)
{
	File fFile = OpenFile(sPath, "wb");
	if (fFile == null)
	{
		LogError("Can't open the record file for writing! (%s)", sPath);

		delete fFile;

		return false;
	}

	fFile.WriteInt32(BM_MAGIC);
	fFile.WriteInt8(header.BinaryFormatVersion);
	fFile.WriteInt8(strlen(header.Time));
	fFile.WriteString(header.Time, false);
	fFile.WriteInt8(strlen(header.Playername));
	fFile.WriteString(header.Playername, false);
	fFile.WriteInt32(header.Checkpoints);
	fFile.Write(view_as<int>(header.InitialPosition), 3, 4);
	fFile.Write(view_as<int>(header.InitialAngles), 2, 4);
	fFile.WriteInt32(header.TickCount);

	// use 'any' type to store origin[3], angles[2], buttons, flags, movetype
	any aFrameData[sizeof(frame_t)];
	// optimized replay writing to do less system calls
	any aWriteData[sizeof(frame_t) * 100];
	int iFramesWritten = 0;

	for(int i = 0; i < header.Frames.Length; i++)
	{
		header.Frames.GetArray(i, aFrameData, sizeof(frame_t));

		for(int j = 0; j < sizeof(frame_t); j++)
		{
			aWriteData[(sizeof(frame_t) * iFramesWritten) + j] = aFrameData[j];
		}

		if(++iFramesWritten == 100 || i == header.Frames.Length - 1)
		{
			fFile.Write(aWriteData, sizeof(frame_t) * iFramesWritten, 4);

			iFramesWritten = 0;
		}
	}

	delete fFile;

	LoadReplays();

	return true;
}

public bool LoadRecordFromFile(const char[] path, FileHeader header, bool headerOnly)
{
	File fFile = OpenFile(path, "rb");
	if (fFile == null)
	{
		delete fFile;
		return false;
	}

	int iMagic;
	fFile.ReadInt32(iMagic);
	if (iMagic != BM_MAGIC)
	{
		delete fFile;
		return false;
	}

	fFile.ReadInt8(header.BinaryFormatVersion);

	int iNameLength;
	fFile.ReadInt8(iNameLength);
	char szTime[MAX_NAME_LENGTH];
	fFile.ReadString(szTime, iNameLength + 1, iNameLength);
	szTime[iNameLength] = '\0';
	strcopy(header.Time, sizeof(FileHeader::Time), szTime);

	int iNameLength2;
	fFile.ReadInt8(iNameLength2);
	char szName[MAX_NAME_LENGTH];
	fFile.ReadString(szName, iNameLength2 + 1, iNameLength2);
	szName[iNameLength2] = '\0';
	strcopy(header.Playername, sizeof(FileHeader::Playername), szName);

	fFile.ReadInt32(header.Checkpoints);
	fFile.Read(view_as<int>(header.InitialPosition), 3, 4);
	fFile.Read(view_as<int>(header.InitialAngles), 2, 4);
	fFile.ReadInt32(header.TickCount);

	header.Frames = null;

	if (header.TickCount <= 0) /* file broken? */
	{
		/* should we rename file or delete it directly? */
		char sNewPath[PLATFORM_MAX_PATH];
		strcopy(sNewPath, FindCharInString(path, '.', true) + 1, path);
		StrCat(sNewPath, sizeof(sNewPath), "_broken.rec");

		if(FileExists(sNewPath))
		{
			DeleteFile(sNewPath);
		}

		RenameFile(sNewPath, path);

		LogError("Replay file: '%s' may broken, already rename to '%s', please check your file sizes.", path, sNewPath);

		delete fFile;
		return false;
	}
	else if (headerOnly)
	{
		delete fFile;
		return true;
	}

	if (header.BinaryFormatVersion >= BINARY_FORMAT_VERSION)
	{
		header.Frames = new ArrayList(sizeof(frame_t), header.TickCount);

		any aReplayData[sizeof(frame_t)];

		for(int i = 0; i < header.TickCount; i++)
		{
			if(fFile.Read(aReplayData, sizeof(frame_t), 4) >= 0)
			{
				header.Frames.SetArray(i, aReplayData, sizeof(frame_t));
			}
		}
	}
	else // old replay
	{
		ArrayList aRecordFrames = new ArrayList(sizeof(FrameInfo));
		ArrayList aAdditionalTeleport = new ArrayList(sizeof(AdditionalTeleport));

		FrameInfo iFrame;
		for (int i = 0; i < header.TickCount; i++)
		{
			fFile.Read(iFrame.PlayerButtons, sizeof(FrameInfo::PlayerButtons), 4);
			fFile.Read(iFrame.PlayerImpulse, sizeof(FrameInfo::PlayerImpulse), 4);
			fFile.Read(view_as<int>(iFrame.ActualVelocity), sizeof(FrameInfo::ActualVelocity), 4);
			fFile.Read(view_as<int>(iFrame.PredictedVelocity), sizeof(FrameInfo::PredictedVelocity), 4);
			fFile.Read(view_as<int>(iFrame.PredictedAngles), sizeof(FrameInfo::PredictedAngles), 4);
			fFile.Read(view_as<int>(iFrame.NewWeapon), sizeof(FrameInfo::NewWeapon), 4);
			fFile.Read(iFrame.PlayerSubtype, sizeof(FrameInfo::PlayerSubtype), 4);
			fFile.Read(iFrame.PlayerSeed, sizeof(FrameInfo::PlayerSeed), 4);
			fFile.Read(iFrame.AdditionalFields, sizeof(FrameInfo::AdditionalFields), 4);
			fFile.Read(iFrame.Pause, sizeof(FrameInfo::Pause), 4);
			aRecordFrames.PushArray(iFrame, sizeof(FrameInfo));

			if (iFrame.AdditionalFields & (ADDITIONAL_FIELD_TELEPORTED_ORIGIN | ADDITIONAL_FIELD_TELEPORTED_ANGLES | ADDITIONAL_FIELD_TELEPORTED_VELOCITY))
			{
				AdditionalTeleport iAT;
				if (iFrame.AdditionalFields & ADDITIONAL_FIELD_TELEPORTED_ORIGIN)
				{
					fFile.Read(view_as<int>(iAT.AtOrigin), 3, 4);
				}
				if (iFrame.AdditionalFields & ADDITIONAL_FIELD_TELEPORTED_ANGLES)
				{
					fFile.Read(view_as<int>(iAT.AtAngles), 3, 4);
				}
				if (iFrame.AdditionalFields & ADDITIONAL_FIELD_TELEPORTED_VELOCITY)
				{
					fFile.Read(view_as<int>(iAT.AtVelocity), 3, 4);
				}

				view_as<int>(iAT.AtFlags) = iFrame.AdditionalFields & (ADDITIONAL_FIELD_TELEPORTED_ORIGIN | ADDITIONAL_FIELD_TELEPORTED_ANGLES | ADDITIONAL_FIELD_TELEPORTED_VELOCITY);
				aAdditionalTeleport.PushArray(iAT, sizeof(AdditionalTeleport));
			}
		}

		header.Frames = aRecordFrames;

		// Free any old handles if we already loaded this one once before.
		StringMap smOldAT;
		if (g_smLoadedRecordsAdditionalTeleport.GetValue(path, smOldAT))
		{
			delete smOldAT;
			g_smLoadedRecordsAdditionalTeleport.Remove(path);
		}

		if (aAdditionalTeleport.Length > 0)
		{
			g_smLoadedRecordsAdditionalTeleport.SetValue(path, aAdditionalTeleport);
		}
		else
		{
			delete aAdditionalTeleport;
		}
	}

	delete fFile;

	return true;
}

public Action RefreshBot(Handle timer)
{
	SetBotQuota();
	LoadRecordReplay();
	return Plugin_Handled;
}

public void LoadRecordReplay()
{
	g_RecordBot = -1;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i) || !IsFakeClient(i) || IsClientSourceTV(i) || i == g_InfoBot || i == g_BonusBot || i == g_WrcpBot)
		{
			continue;
		}

		if (!IsPlayerAlive(i))
		{
			CS_RespawnPlayer(i);
			if (GetConVarBool(g_hForceCT))
			{
				TeamChangeActual(i, 2);
			}
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
		{
			g_bNewRecordBot = true;
		}

		g_iClientInZone[g_RecordBot][2] = 0;

		SetEntityGravity(g_RecordBot, 0.0);

		PlayRecord(g_RecordBot, 0, 0);
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
	SetBotQuota();
	LoadBonusReplay();
	return Plugin_Handled;
}

public void LoadBonusReplay()
{
	g_BonusBot = -1;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i) || !IsFakeClient(i) || IsClientSourceTV(i) || i == g_InfoBot || i == g_RecordBot || i == g_WrcpBot)
		{
			continue;
		}

		if (!IsPlayerAlive(i))
		{
			CS_RespawnPlayer(i);

			if (GetConVarBool(g_hForceCT))
			{
				TeamChangeActual(i, 2);
			}
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
		{
			g_bNewBonusBot = true;
		}

		g_iClientInZone[g_BonusBot][2] = g_iBonusToReplay[0];

		SetEntityGravity(g_BonusBot, 0.0);

		PlayRecord(g_BonusBot, 1, 0);
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

public Action RefreshWrcpBot(Handle timer)
{
	SetBotQuota();
	LoadWrcpReplay();
	return Plugin_Handled;
}

public void LoadWrcpReplay()
{
	g_WrcpBot = -1;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i) || !IsFakeClient(i) || IsClientSourceTV(i) || i == g_InfoBot || i == g_RecordBot || i == g_BonusBot)
		{
			continue;
		}

		if (!IsPlayerAlive(i))
		{
			CS_RespawnPlayer(i);

			if (GetConVarBool(g_hForceCT))
			{
				TeamChangeActual(i, 2);
			}
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

		SetEntityGravity(g_WrcpBot, 0.0);

		PlayRecord(g_WrcpBot, -g_StageReplayCurrentStage, 0);
		SetEntityRenderColor(g_WrcpBot, 180, 142, 173, 50);
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
	{
		return;
	}

	g_iReplayTick[client] = 0;
	g_CurrentAdditionalTeleportIndex[client] = 0;
	g_iReplayTicksCount[client] = 0;
	g_bValidTeleportCall[client] = false;
	delete g_aReplayFrame[client];
}

public void Replay_Recording(int client, int &buttons, int &subtype, int &seed, int &impulse, int &weapon, float angles[3], float vel[3])
{
	if (g_aRecording[client] == null || g_bPause[client])
	{
		return;
	}

	if (g_aRecording[client].Length <= g_iRecordedTicks[client])
	{
		// Add about two seconds worth of frames so we don't have to resize so often
		g_aRecording[client].Resize(g_iRecordedTicks[client] + (RoundToCeil(g_fTickrate) * 2));
	}

	//origin[3], angles[2], buttons, flags, movetype
	frame_t aFrame;

	GetClientAbsOrigin(client, aFrame.pos);
	float vecEyes[3];
	GetClientEyeAngles(client, vecEyes);
	aFrame.ang[0] = vecEyes[0];
	aFrame.ang[1] = vecEyes[1];
	aFrame.buttons = buttons;
	aFrame.flags = GetEntityFlags(client);
	aFrame.mt = GetEntityMoveType(client);

	g_aRecording[client].SetArray(g_iRecordedTicks[client]++, aFrame, sizeof(aFrame));
}

public void Replay_Playback(int client, int &buttons, int &subtype, int &seed, int &impulse, int &weapon, float angles[3], float vel[3])
{
	LoopReplay(client);

	if (GetClientTeam(client) < CS_TEAM_T || 
		g_aReplayFrame[client] == null || g_iReplayTicksCount[client] <= 0)
	{
		return;
	}

	if(g_iReplayVersion[client] >= BINARY_FORMAT_VERSION)
	{
		// origin[3], angles[2], buttons, flags, movetype
		frame_t aFrame;
		g_aReplayFrame[client].GetArray(g_iReplayTick[client], aFrame, sizeof(aFrame));

		buttons = aFrame.buttons;

		float vecCurrentPosition[3];
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", vecCurrentPosition);

		float vecVelocity[3];
		MakeVectorFromPoints(vecCurrentPosition, aFrame.pos, vecVelocity);
		ScaleVector(vecVelocity, g_fTickrate);

		float ang[3];
		ang[0] = aFrame.ang[0];
		ang[1] = aFrame.ang[1];

		SetEntityFlags(client, aFrame.flags);

		bool bWalk = true;

		if(aFrame.flags & FL_ONGROUND)
		{
			MoveType mt = MOVETYPE_WALK;
			if(GetVectorLength(vecVelocity) > 300.0)
			{
				TR_TraceRay(aFrame.pos, vecCurrentPosition, MASK_PLAYERSOLID, RayType_EndPoint);
				if(TR_DidHit())
				{
					bWalk = false;
					mt = MOVETYPE_NOCLIP;
				}
			}

			SetEntityMoveType(client, mt);
		}
		else
		{
			bWalk = false;
			SetEntityMoveType(client, MOVETYPE_NOCLIP);
		}

		// shavit idea
		// replay is going above 15k speed, just teleport at this point
		// bot is on ground.. 
		// if the distance between the previous position is much bigger (1.5x) than the expected according to the bot's velocity, 
		// teleport to avoid sync issues
		if((GetVectorLength(vecVelocity) > 15000.0 ||
			(bWalk && GetVectorDistance(vecCurrentPosition, aFrame.pos) > GetVectorLength(vecVelocity) / g_fTickrate * 1.5)))
		{
			TeleportEntity(client, aFrame.pos, ang, NULL_VECTOR);
		}

		else
		{
			TeleportEntity(client, NULL_VECTOR, ang, vecVelocity);
		}
	}

	else // load old replays
	{
		FrameInfo iFrame;
		g_aReplayFrame[client].GetArray(g_iReplayTick[client], iFrame, sizeof(FrameInfo));

		buttons = iFrame.PlayerButtons;
		impulse = iFrame.PlayerImpulse;
		Array_Copy(iFrame.PredictedVelocity, vel, 3);
		Array_Copy(iFrame.PredictedAngles, angles, 2);
		subtype = iFrame.PlayerSubtype;
		seed = iFrame.PlayerSeed;
		weapon = 0;

		float fActualVelocity[3];
		Array_Copy(iFrame.ActualVelocity, fActualVelocity, 3);

		// We're supposed to teleport stuff?
		if (iFrame.AdditionalFields & (ADDITIONAL_FIELD_TELEPORTED_ORIGIN | ADDITIONAL_FIELD_TELEPORTED_ANGLES | ADDITIONAL_FIELD_TELEPORTED_VELOCITY))
		{
			AdditionalTeleport iAT;
			ArrayList hAdditionalTeleport;
			char sPath[PLATFORM_MAX_PATH];
			if (client == g_RecordBot)
			{
				if (g_iSelectedReplayType == 0 && g_iSelectedReplayStyle == 0)
				{
					Format(sPath, sizeof(sPath), "%s%s.rec", CK_REPLAY_PATH, g_szMapName);
				}
				else if (g_iSelectedReplayType == 0 && g_iSelectedReplayStyle > 0)
				{
					Format(sPath, sizeof(sPath), "%s%s_style_%d.rec", CK_REPLAY_PATH, g_szMapName, g_iSelectedReplayStyle);
				}
			}
			else if (client == g_BonusBot)
			{
				int bonus = g_iSelectedReplayBonus;
				if (g_iSelectedReplayType == 1 && g_iSelectedBonusReplayStyle == 0)
				{
					if (g_iCurrentBonusReplayIndex != 99)
					{
						Format(sPath, sizeof(sPath), "%s%s_bonus_%d.rec", CK_REPLAY_PATH, g_szMapName, g_iBonusToReplay[g_iCurrentBonusReplayIndex]);
					}
					else
					{
						Format(sPath, sizeof(sPath), "%s%s_bonus_%d.rec", CK_REPLAY_PATH, g_szMapName, g_iManualBonusToReplay);
					}
				}
				else if (g_iSelectedReplayType == 1 && g_iSelectedBonusReplayStyle > 0)
				{
					Format(sPath, sizeof(sPath), "%s%s_bonus_%d_style_%d.rec", CK_REPLAY_PATH, g_szMapName, bonus, g_iSelectedBonusReplayStyle);
				}
			}

			BuildPath(Path_SM, sPath, sizeof(sPath), "%s", sPath);
			if (g_smLoadedRecordsAdditionalTeleport != null)
			{
				g_smLoadedRecordsAdditionalTeleport.GetValue(sPath, hAdditionalTeleport);
				if (hAdditionalTeleport != null)
				{
					hAdditionalTeleport.GetArray(g_CurrentAdditionalTeleportIndex[client], iAT, 10);
				}

				float fOrigin[3], fAngles[3], fVelocity[3];
				Array_Copy(iAT.AtOrigin, fOrigin, 3);
				Array_Copy(iAT.AtAngles, fAngles, 3);
				Array_Copy(iAT.AtVelocity, fVelocity, 3);

				// The next call to Teleport is ok.
				g_bValidTeleportCall[client] = true;

				if (iAT.AtFlags & ADDITIONAL_FIELD_TELEPORTED_ORIGIN)
				{
					if (iAT.AtFlags & ADDITIONAL_FIELD_TELEPORTED_ANGLES)
					{
						if (iAT.AtFlags & ADDITIONAL_FIELD_TELEPORTED_VELOCITY)
						{
							TeleportEntity(client, fOrigin, fAngles, fVelocity);
						}
						else
						{
							TeleportEntity(client, fOrigin, fAngles, NULL_VECTOR);
						}
					}
					else
					{
						if (iAT.AtFlags & ADDITIONAL_FIELD_TELEPORTED_VELOCITY)
						{
							TeleportEntity(client, fOrigin, NULL_VECTOR, fVelocity);
						}
						else
						{
							TeleportEntity(client, fOrigin, NULL_VECTOR, NULL_VECTOR);
						}
					}
				}
				else
				{
					if (iAT.AtFlags & ADDITIONAL_FIELD_TELEPORTED_ANGLES)
					{
						if (iAT.AtFlags & ADDITIONAL_FIELD_TELEPORTED_VELOCITY)
						{
							TeleportEntity(client, NULL_VECTOR, fAngles, fVelocity);
						}
						else
						{
							TeleportEntity(client, NULL_VECTOR, fAngles, NULL_VECTOR);
						}
					}
					else
					{
						if (iAT.AtFlags & ADDITIONAL_FIELD_TELEPORTED_VELOCITY)
						{
							TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, fVelocity);
						}
					}
				}

				g_CurrentAdditionalTeleportIndex[client]++;
			}
		}

		// This is the first tick. Teleport him to the initial position
		if (g_iReplayTick[client] == 0)
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

		if (iFrame.NewWeapon != CSWeapon_NONE)
		{
			if (g_iReplayTick[client] > 0)
			{
				Client_RemoveAllWeapons(client);
			}
			else
			{
				if ((client == g_RecordBot && g_bNewRecordBot) || (client == g_BonusBot && g_bNewBonusBot))
				{
					if (client == g_RecordBot)
					{
						g_bNewRecordBot = false;
					}
					else
					{
						if (client == g_BonusBot)
						{
							g_bNewBonusBot = false;
						}
					}
				}
				else
				{
					Client_RemoveAllWeapons(client);
				}
			}
		}
	}

	g_iReplayTick[client]++;
}

static void LoopReplay(int client)
{
	if (g_iReplayTick[client] >= g_iReplayTicksCount[client] || g_bReplayAtEnd[client])
	{
		if (client == g_BonusBot)
		{
			if (g_bManualBonusReplayPlayback)
			{
				if (g_iManualBonusReplayCount < 1)
				{
					g_iManualBonusReplayCount++;
				}
				else
				{
					g_iManualBonusReplayCount = 0;
					g_bManualBonusReplayPlayback = false;
					g_iCurrentBonusReplayIndex = 0;
					g_iSelectedBonusReplayStyle = 0;
					PlayRecord(g_BonusBot, 1, 0);
					g_iClientInZone[g_BonusBot][2] = g_iBonusToReplay[g_iCurrentBonusReplayIndex];
				}
			}
			else
			{
				// Call to load another replay
				if (g_iCurrentBonusReplayIndex < (g_BonusBotCount-1))
				{
					g_iCurrentBonusReplayIndex++;
				}
				else
				{
					g_iCurrentBonusReplayIndex = 0;
				}

				g_iSelectedBonusReplayStyle = 0;
				PlayRecord(g_BonusBot, 1, 0);
				g_iClientInZone[g_BonusBot][2] = g_iBonusToReplay[g_iCurrentBonusReplayIndex];
			}
		}
		else if (client == g_RecordBot)
		{
			if (g_bManualReplayPlayback)
			{
				if (g_iManualReplayCount < 1)
				{
					g_iManualReplayCount++;
				}
				else
				{
					g_iManualReplayCount = 0;
					g_bManualReplayPlayback = false;
					g_iSelectedReplayStyle = 0;
					PlayRecord(g_RecordBot, 0, 0);
				}
			}
		}
		else if (client == g_WrcpBot)
		{
			if (g_bManualStageReplayPlayback)
			{
				if (g_iManualStageReplayCount < 2)
				{
					g_iManualStageReplayCount++;
				}
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
						{
							continue;
						}

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
			g_iReplayTick[client] = 0;
			g_CurrentAdditionalTeleportIndex[client] = 0;
		}

		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
		g_bReplayAtEnd[client] = false;
		g_iReplayTick[client] = 0;
		g_CurrentAdditionalTeleportIndex[client] = 0;
	}
}

// Stage zone EndTouch(should be starttouch if add preframe)
public void Stage_StartRecording(int client)
{
	if (!IsValidClient(client) || IsFakeClient(client))
	{
		return;
	}

	g_StageRecording = true;

	g_iStageStartFrame[client] = g_iRecordedTicks[client];

	char szName[MAX_NAME_LENGTH];
	GetClientName(client, szName, MAX_NAME_LENGTH);

	if (g_aRecording[client] == null)
	{
		StartRecording(client);
	}
}

public void Stage_SaveRecording(int client, int stage, char[] time)
{
	if (!IsValidClient(client) || g_aRecording[client] == null)
	{
		return;
	}

	char szName[MAX_NAME_LENGTH];
	GetClientName(client, szName, MAX_NAME_LENGTH);

	char sPath2[256];

	// Check if the default record folder exists?
	BuildPath(Path_SM, sPath2, sizeof(sPath2), "%s", CK_REPLAY_PATH);
	if (!DirExists(sPath2))
	{
		CreateDirectory(sPath2, 511);
	}

	BuildPath(Path_SM, sPath2, sizeof(sPath2), "%s%s_stage_%d.rec", CK_REPLAY_PATH, g_szMapName, stage);

	if (FileExists(sPath2) && GetConVarBool(g_hBackupReplays))
	{
		char newPath[256];
		Format(newPath, 256, "%s.bak", sPath2);
		RenameFile(newPath, sPath2);
	}

	int startFrame = g_iStageStartFrame[client];
	int endFrame = g_iRecordedTicks[client];

	FileHeader header;
	header.BinaryFormatVersion = BINARY_FORMAT_VERSION;
	strcopy(header.Time, sizeof(FileHeader::Time), time);
	header.TickCount = endFrame - startFrame;
	strcopy(header.Playername, sizeof(FileHeader::Playername), szName);
	header.Checkpoints = 0;

	header.Frames = new ArrayList(sizeof(frame_t));
	any aFrameData[sizeof(frame_t)];

	for (int i = startFrame; i < endFrame; i++)
	{
		if (i == -1)
		{
			LogError("Stage record cannot be saved. Client: \"%L\", startFrame: %d (g_iStageStartFrame: %d), endFrame: %d (g_iRecordedTicks: %d), i: %d, Path/File: %s", client, startFrame, g_iStageStartFrame[client], endFrame, g_iRecordedTicks[client], i, sPath2);
			continue;
		}
		
		g_aRecording[client].GetArray(i, aFrameData, sizeof(frame_t));
		header.Frames.PushArray(aFrameData, sizeof(frame_t));
	}

	WriteRecordToDisk(sPath2, header);

	delete header.Frames;

	if (g_bSavingWrcpReplay[client])
	{
		g_bSavingWrcpReplay[client] = false;
	}
}
