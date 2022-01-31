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
	int client = GetNativeCell(1);
	int rank = 99999;
	if (IsValidClient(client) && !IsFakeClient(client))
	{
		char szTime[64], szCountry[16];

		GetNativeString(1, szTime, 64);
		rank = GetNativeCell(2);
		GetNativeString(3, szCountry, 16);

		if (g_fPersonalRecord[client] > 0.0)
			Format(szTime, 64, "%s", g_szPersonalRecord[client]);
		else
			Format(szTime, 64, "N/A");

		Format(szCountry, sizeof(szCountry), g_szCountryCode[client]);

		rank = g_MapRank[client];

		SetNativeString(2, szTime, sizeof(szTime), true);
		SetNativeString(4, szCountry, sizeof(szCountry), true);
	}

	return rank;
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