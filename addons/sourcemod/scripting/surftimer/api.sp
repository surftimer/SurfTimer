/*===================================
=              Natives              =
===================================*/

public int Native_GetTimerStatus(Handle plugin, int numParams)
{
	return g_bTimerRunning[GetNativeCell(1)];
}

public int Native_StopTimer(Handle plugin, int numParams)
{
	Client_Stop(GetNativeCell(1), 0);

	return 0;
}

public int Native_GetCurrentTime(Handle plugin, int numParams)
{
	return view_as<int>(g_fCurrentRunTime[GetNativeCell(1)]);
}

public int Native_EmulateStartButtonPress(Handle plugin, int numParams)
{
	CL_OnStartTimerPress(GetNativeCell(1));

	return 0;
}

public int Native_EmulateStopButtonPress(Handle plugin, int numParams)
{
	CL_OnEndTimerPress(GetNativeCell(1));

	return 0;
}

public int Native_SafeTeleport(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	if (IsValidClient(client))
	{
		float fDestination[3], Angle[3], Vel[3];
		GetNativeArray(2, fDestination, 3);
		GetNativeArray(3, Angle, 3);
		GetNativeArray(4, Vel, 3);

		teleportEntitySafe(client, fDestination, Angle, Vel, GetNativeCell(5));

		return true;
	}
	else
		return false;
}

public int Native_IsClientVip(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	if (IsValidClient(client) && !IsFakeClient(client))
		return g_bVip[client];
	else
		return false;
}

public int Native_GetPlayerRank(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	if (IsValidClient(client) && !IsFakeClient(client))
		return g_PlayerRank[client][0];
	else
		return -1;
}

public int Native_GetPlayerPoints(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	if (IsValidClient(client) && !IsFakeClient(client))
		return g_pr_points[client][0];
	else
		return -1;
}

public int Native_GetPlayerSkillgroup(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	char str[256];
	GetNativeString(2, str, 256);
	if (IsValidClient(client) && !IsFakeClient(client))
	{
		Format(str, sizeof(str), g_pr_chat_coloredrank[client]);
		SetNativeString(2, str, 256, true);
	}
	else
	{
		Format(str, sizeof(str), "Unranked");
		SetNativeString(2, str, 256, true);
	}

	return 0;
}

public int Native_GetPlayerNameColored(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	char str[256];
	GetNativeString(2, str, 256);
	if (IsValidClient(client) && !IsFakeClient(client))
	{
		GetClientName(client, str, sizeof(str));
		Format(str, sizeof(str), "%s%s",  g_pr_namecolour[client], str);
		SetNativeString(2, str, 256, true);
	}
	else
	{
		Format(str, sizeof(str), "invalid");
		SetNativeString(2, str, 256, true);
	}

	return 0;
}

public int Native_GetMapData(Handle plugin, int numParams)
{
	char name[MAX_NAME_LENGTH], time[64];
	GetNativeString(1, name, MAX_NAME_LENGTH);
	GetNativeString(2, time, 64);

	Format(name, sizeof(name), g_szRecordPlayer);
	Format(time, sizeof(time), g_szRecordMapTime);
	SetNativeString(1, name, sizeof(name), true);
	SetNativeString(2, time, sizeof(time), true);

	return g_MapTimesCount;
}

public int Native_GetPlayerData(Handle plugin, int numParams)
{
	int client = GetNativeCellRef(1);
	int rank = 99999;
	if (IsValidClient(client) && !IsFakeClient(client))
	{
		char szTime[64], szCountry[16], szCountryCode[3], szContinentCode[3];

		GetNativeString(2, szTime, 64);
		rank = GetNativeCellRef(3);
		GetNativeString(4, szCountry, 16);
		GetNativeString(5, szCountryCode, sizeof(szCountryCode));
		GetNativeString(6, szContinentCode, sizeof(szContinentCode));

		if (g_fPersonalRecord[client] > 0.0)
			Format(szTime, 64, "%s", g_szPersonalRecord[client]);
		else
			Format(szTime, 64, "N/A");

		Format(szCountry, sizeof(szCountry), g_szCountry[client]);
		Format(szCountryCode, sizeof(szCountryCode), g_szCountryCode[client]);
		Format(szContinentCode, sizeof(szContinentCode), g_szContinentCode[client]);

		rank = g_MapRank[client];

		SetNativeString(2, szTime, sizeof(szTime), true);
		SetNativeCellRef(3, rank);
		SetNativeString(4, szCountry, sizeof(szCountry), true);
		SetNativeString(4, szCountryCode, sizeof(szCountryCode), true);
		SetNativeString(4, szContinentCode, sizeof(szContinentCode), true);
	}

	return rank;
}

public int Native_GetPlayerInfo(Handle plugin, int numParams)
{
	int client = GetNativeCellRef(1);
	int iStage = 9999;
	if (IsValidClient(client) && !IsFakeClient(client))
	{
		iStage = g_Stage[0][client];
		SetNativeCellRef(2, g_bWrcpTimeractivated[client]);
		SetNativeCellRef(3, g_bPracticeMode[client]);
		SetNativeCellRef(4, iStage);
		SetNativeCellRef(5, g_iInBonus[client]);
	}

	return iStage;
}

public int Native_GetMapTier(Handle plugin, int numParams)
{
	return g_iMapTier;
}

public int Native_GetMapStages(Handle plugin, int numParams)
{
	int stages = 0;
	if (g_bhasStages)
		stages = g_mapZonesTypeCount[0][3] + 1;
	return stages;
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	RegPluginLibrary("surftimer");
	CreateNative("surftimer_GetTimerStatus", Native_GetTimerStatus);
	CreateNative("surftimer_StopTimer", Native_StopTimer);
	CreateNative("surftimer_EmulateStartButtonPress", Native_EmulateStartButtonPress);
	CreateNative("surftimer_EmulateStopButtonPress", Native_EmulateStopButtonPress);
	CreateNative("surftimer_GetCurrentTime", Native_GetCurrentTime);
	CreateNative("surftimer_GetPlayerRank", Native_GetPlayerRank);
	CreateNative("surftimer_GetPlayerPoints", Native_GetPlayerPoints);
	CreateNative("surftimer_GetPlayerSkillgroup", Native_GetPlayerSkillgroup);
	CreateNative("surftimer_GetPlayerNameColored", Native_GetPlayerNameColored);
	CreateNative("surftimer_GetMapData", Native_GetMapData);
	CreateNative("surftimer_GetPlayerData", Native_GetPlayerData);
	CreateNative("surftimer_GetPlayerInfo", Native_GetPlayerInfo);
	CreateNative("surftimer_GetMapTier", Native_GetMapTier);
	CreateNative("surftimer_GetMapStages", Native_GetMapStages);
	CreateNative("surftimer_SafeTeleport", Native_SafeTeleport);
	CreateNative("surftimer_IsClientVip", Native_IsClientVip);
	MarkNativeAsOptional("Store_GetClientCredits");
	MarkNativeAsOptional("Store_SetClientCredits");
	g_bLateLoaded = late;
	return APLRes_Success;
}

/*======  End of Natives  ======*/


/*===================================
=             Forwards              =
===================================*/

void Register_Forwards()
{
	g_MapFinishForward = new GlobalForward("surftimer_OnMapFinished", ET_Event, Param_Cell, Param_Float, Param_String, Param_Cell, Param_Cell, Param_Cell);
	g_MapCheckpointForward = new GlobalForward("surftimer_OnCheckpoint", ET_Event, Param_Cell, Param_Float, Param_String, Param_Float, Param_String, Param_Float, Param_String);
	g_BonusFinishForward = new GlobalForward("surftimer_OnBonusFinished", ET_Event, Param_Cell, Param_Float, Param_String, Param_Cell, Param_Cell, Param_Cell);
	g_PracticeFinishForward = new GlobalForward("surftimer_OnPracticeFinished", ET_Event, Param_Cell, Param_Float, Param_String);
	g_NewRecordForward = new GlobalForward("surftimer_OnNewRecord", ET_Event, Param_Cell, Param_Cell, Param_String, Param_String, Param_Cell);
	g_NewWRCPForward = new GlobalForward("surftimer_OnNewWRCP", ET_Event, Param_Cell, Param_Cell, Param_String, Param_String, Param_Cell);
}

/**
 * Sends a map finish forward on surftimer_OnMapFinished.
 * 
 * @param client           Index of the client who beat the map.
 * @param count            The number of times the map has been beaten.
 */
void SendMapFinishForward(int client, int count, int style)
{
	/* Start function call */
	Call_StartForward(g_MapFinishForward);

	/* Push parameters one at a time */
	Call_PushCell(client);
	Call_PushFloat(g_fFinalTime[client]);
	Call_PushString(g_szFinalTime[client]);
	Call_PushCell(g_MapRank[client]);
	Call_PushCell(count);
	Call_PushCell(style);

	/* Finish the call, get the result */
	Call_Finish();
}

/**
 * Sends a map checkpoint forward on surftimer_OnCheckpoint.
 * 
 * @param client               Index of the client.
 * @param zonegroup            ID of the zone group.
 * @param zone                 ID of the zone.
 * @param time                 Time at the zone.
 * @param szTime               Formatted time.
 * @param szDiff_colorless     Colorless time diff.
 * @param sz_srDiff_colorless  Colorless time diff with the record.
 */
void SendMapCheckpointForward(
	int client, 
	int zonegroup, 
	int zone, 
	float time, 
	const char[] szTime, 
	const char[] szDiff_colorless, 
	const char[] sz_srDiff_colorless)
{
	// Checkpoint forward
	Call_StartForward(g_MapCheckpointForward);

	/* Push parameters one at a time */
	Call_PushCell(client);
	Call_PushFloat(time);
	Call_PushString(szTime);
	Call_PushFloat(g_fCheckpointTimesRecord[zonegroup][client][zone]);
	Call_PushString(szDiff_colorless);
	Call_PushFloat(g_fCheckpointServerRecord[zonegroup][zone]);
	Call_PushString(sz_srDiff_colorless);

	/* Finish the call, get the result */
	Call_Finish();
}

/**
 * Sends a bonus finish forward on surftimer_OnBonusFinished.
 * 
 * @param client           Index of the client.
 * @param rank             Rank of the client.
 * @param zGroup           Zone group of the bonus.
 */
void SendBonusFinishForward(int client, int rank, int zGroup)
{
	/* Start function call */
	Call_StartForward(g_BonusFinishForward);

	/* Push parameters one at a time */
	Call_PushCell(client);
	Call_PushFloat(g_fFinalTime[client]);
	Call_PushString(g_szFinalTime[client]);
	Call_PushCell(rank);
	Call_PushCell(g_iBonusCount[zGroup]);
	Call_PushCell(zGroup);

	/* Finish the call, get the result */
	Call_Finish();
}

/**
 * Sends a practive finish forward on surftimer_OnPracticeFinished.
 * 
 * @param client           Index of the client.
 */
void SendPracticeFinishForward(int client)
{
	/* Start function call */
	Call_StartForward(g_PracticeFinishForward);

	/* Push parameters one at a time */
	Call_PushCell(client);
	Call_PushFloat(g_fFinalTime[client]);
	Call_PushString(g_szFinalTime[client]);

	/* Finish the call, get the result */
	Call_Finish();
}

/**
 * Sends a new record forward on surftimer_OnNewRecord.
 * 
 * @param client           Index of the client.
 * @param szRecordDiff     String containing the formatted difference with the previous record.
 * @param bonusGroup       Number of the bonus. Default = -1.
 */
void SendNewRecordForward(int client, const char[] szRecordDiff, int bonusGroup = -1)
{
	/* Start New record function call */
	Call_StartForward(g_NewRecordForward);

	/* Push parameters one at a time */
	Call_PushCell(client);
	Call_PushCell(g_iCurrentStyle[client]);
	Call_PushString(g_szFinalTime[client]);
	Call_PushString(szRecordDiff);
	Call_PushCell(bonusGroup);

	/* Finish the call, get the result */
	Call_Finish();
}

/**
 * Sends a new WRCP forward on surftimer_OnNewWRCP.
 * 
 * @param client           Index of the client.
 * @param stage            ID of the stage.
 * @param szRecordDiff     String containing the formatted difference with the previous record.
 */
void SendNewWRCPForward(int client, int stage, const char[] szRecordDiff)
{
	/* Start New record function call */
	Call_StartForward(g_NewWRCPForward);

	/* Push parameters one at a time */
	Call_PushCell(client);
	Call_PushCell(g_iCurrentStyle[client]);
	Call_PushString(g_szFinalWrcpTime[client]);
	Call_PushString(szRecordDiff);
	Call_PushCell(stage);

	/* Finish the call, get the result */
	Call_Finish();
}

/*======  End of Forwards  ======*/