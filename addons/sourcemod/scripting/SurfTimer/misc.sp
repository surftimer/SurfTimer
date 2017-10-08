void disableServerHibernate()
{
	Handle hServerHibernate = FindConVar("sv_hibernate_when_empty");
	g_iServerHibernationValue = GetConVarInt(hServerHibernate);
	if (g_iServerHibernationValue > 0)
	{
		PrintToServer("[surftimer] Disabling server hibernation.");
		SetConVarInt(hServerHibernate, 0, false, false);
	}
	CloseHandle(hServerHibernate);
	return;
}

void revertServerHibernateSettings()
{
	Handle hServerHibernate = FindConVar("sv_hibernate_when_empty");
	if (GetConVarInt(hServerHibernate) != g_iServerHibernationValue)
	{
		PrintToServer("[surftimer] Resetting Server Hibernation CVar");
		SetConVarInt(hServerHibernate, g_iServerHibernationValue, false, false);
	}
	CloseHandle(hServerHibernate);
	return;
}
void setBotQuota()
{
	// Get bot_quota value
	ConVar hBotQuota = FindConVar("bot_quota");

	// Initialize
	SetConVarInt(hBotQuota, 0, false, false);

	// Check how many bots are needed
	int count = 0;
	if (g_bMapReplay)
		count++;
	if (GetConVarBool(g_hInfoBot))
		count++;
	if (g_BonusBotCount > 0)
		count++;
	if (GetConVarBool(g_hWrcpBot) && g_bhasStages && g_bFirstStageReplay)
		count++;

	if (count == 0)
		SetConVarInt(hBotQuota, 0, false, false);
	else
	{
		//count = count + 1;
		SetConVarInt(hBotQuota, count, false, false);
	}

	CloseHandle(hBotQuota);

	return;
}

bool IsValidZonegroup(int zGrp)
{
	if (-1 < zGrp < g_mapZoneGroupCount)
		return true;
	return false;
}

/**
*	Checks if coordinates are inside a zone
* 	Return: zone id where location is in, or -1 if not inside a zone
**/
int IsInsideZone (float location[3], float extraSize = 0.0)
{
	float tmpLocation[3];
	Array_Copy(location, tmpLocation, 3);
	tmpLocation[2] += 5.0;
	int iChecker;

	for (int i = 0; i < g_mapZonesCount; i++)
	{
		iChecker = 0;
		for(int x = 0; x < 3; x++)
		{
			if((g_fZoneCorners[i][7][x] >= g_fZoneCorners[i][0][x] && (tmpLocation[x] <= (g_fZoneCorners[i][7][x] + extraSize) && tmpLocation[x] >= (g_fZoneCorners[i][0][x] - extraSize))) ||
			(g_fZoneCorners[i][0][x] >= g_fZoneCorners[i][7][x] && (tmpLocation[x] <= (g_fZoneCorners[i][0][x] + extraSize) && tmpLocation[x] >= (g_fZoneCorners[i][7][x] - extraSize))))
				iChecker++;
		}
		if(iChecker == 3)
			return i;
	}

	return -1;
}

public void loadAllClientSettings()
{
	for (int i = 1; i < MAXPLAYERS + 1; i++)
	{
		if (IsValidClient(i) && !IsFakeClient(i) && !g_bSettingsLoaded[i] && !g_bLoadingSettings[i])
		{
			g_iSettingToLoad[i] = 0;
			LoadClientSetting(i, 0);
			g_bLoadingSettings[i] = true;
			break;
		}
	}

	g_bServerDataLoaded = true;
}

public void LoadClientSetting(int client, int setting)
{
	if (IsValidClient(client) && !IsFakeClient(client))
	{
		switch (setting)
		{
			case 0: db_viewPersonalRecords(client, g_szSteamID[client], g_szMapName);
			// db_viewMapRankPro(client);
			// db_viewStyleMapRank(client, style);
			case 1: db_viewPersonalBonusRecords(client, g_szSteamID[client]);
			// db_viewMapRankBonus(client, zgroup, 0);
			// db_viewMapRankBonusStyle(client, zgroup, 0, style);
			case 2: db_viewPersonalStageRecords(client, g_szSteamID[client]);
			// db_viewStageRanks(client, stage);
			// db_viewStyleStageRanks(client, stage, style);
			case 3: db_viewPlayerPoints(client);
			// db_GetPlayerRank(client);
			case 4: db_viewPlayerOptions(client, g_szSteamID[client]);
			case 5: db_CheckVIPAdmin(client, g_szSteamID[client]);
			case 6: db_viewCustomTitles(client, g_szSteamID[client]);
			case 7: db_viewCheckpoints(client, g_szSteamID[client], g_szMapName);
			default: db_viewPersonalRecords(client, g_szSteamID[client], g_szMapName);
		}
		g_iSettingToLoad[client]++;
	}
}

public void getSteamIDFromClient(int client, char[] buffer, int length)
{
	// Get steamid - Points are being recalculated by an admin (pretty much going through top 20k players)
	if (client > MAXPLAYERS)
	{
		if (!g_pr_RankingRecalc_InProgress && !g_bProfileRecalc[client])
			return;
		Format(buffer, length, "%s", g_pr_szSteamID[client]);
	}
	else // Get steamid - Normal point increase
	{
		if (!GetConVarBool(g_hPointSystem) || !IsValidClient(client))
			return;
		GetClientAuthId(client, AuthId_Steam2, buffer, length, true);
	}
	return;
}

/*
Handles teleporting of players
Zonegroup: 0 = normal map, >0 bonuses.
Zone types: 1 = Start zone,  >1 Stage zones.
*/
public void teleportClient(int client, int zonegroup, int zone, bool stopTime)
{
	if (!IsValidClient(client))
		return;

	if (!IsValidZonegroup(zonegroup))
	{
		PrintToChat(client, " %cSurftimer %c| Zonegroup not found.", LIMEGREEN, WHITE);
		return;
	}

	// Set Defaults

	//fluffys gravity
	ResetGravity(client);

	if (g_iInitalStyle[client] != 5 && g_iInitalStyle[client] != 6)
	 	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
		
	// Hack fix for b1 of surf_aircontrol_ksf
	if (StrEqual(g_szMapName, "surf_aircontrol_ksf_123") && zonegroup == 1)
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 2.0);

	if (g_bPracticeMode[client])
		Command_normalMode(client, 1);

	g_bNotTeleporting[client] = false;
	g_bInJump[client] = false;

	// Check for spawn locations
	int realZone;
	if (zone < 0)
		realZone = 0;
	else
		realZone = zone;

	if (g_bStartposUsed[client][zonegroup])
	{
		if (GetClientTeam(client) == 1 || GetClientTeam(client) == 0) // Spectating
		{
			if (stopTime)
				Client_Stop(client, 0);

			Array_Copy(g_fStartposLocation[client][zonegroup], g_fTeleLocation[client], 3);
			//Array_Copy(g_fSpawnLocation[zonegroup][realZone], g_fStartposLocation[client][zonegroup], 3);

			g_specToStage[client] = true;
			g_bRespawnPosition[client] = false;

			TeamChangeActual(client, 0);
			return;
		}
		else
		{
			SetEntPropVector(client, Prop_Data, "m_vecVelocity", view_as<float>( { 0.0, 0.0, 0.0 } ));

			// Hack fix for zoneid not being set with hooked zones
			int zId = getZoneID(zonegroup, zone);
			if (!StrEqual(g_mapZones[zId][hookName], "None"))
				g_iTeleportingZoneId[client] = zId;

			teleportEntitySafe(client, g_fStartposLocation[client][zonegroup], g_fStartposAngle[client][zonegroup], view_as<float>( { 0.0, 0.0, 0.0 } ), stopTime);

			return;
		}
	}
	else if (g_bGotSpawnLocation[zonegroup][realZone])
	{
		// Check if teleporting to bonus
		if (zonegroup > 0)
		{
			// Set a bool to allow bonus zones to sit on top of start zones, e.g surf_aircontrol_ksf bonus 1
			g_bInBonus[client] = true;
			g_iInBonus[client] = zonegroup;
		}
		else
		{
			// Not teleporting to a bonus
			g_bInBonus[client] = false;
		}

		if (GetClientTeam(client) == 1 || GetClientTeam(client) == 0) // Spectating
		{
			if (stopTime)
				Client_Stop(client, 0);

			Array_Copy(g_fSpawnLocation[zonegroup][realZone], g_fTeleLocation[client], 3);

			g_specToStage[client] = true;
			g_bRespawnPosition[client] = false;

			TeamChangeActual(client, 0);
			return;
		}
		else
		{
			SetEntPropVector(client, Prop_Data, "m_vecVelocity", view_as<float>( { 0.0, 0.0, 0.0 } ));

			// Hack fix for zoneid not being set with hooked zones
			int zId = getZoneID(zonegroup, zone);
			if (!StrEqual(g_mapZones[zId][hookName], "None"))
				g_iTeleportingZoneId[client] = zId;

			if (realZone == 0)
			{
				g_bInStartZone[client] = false;
				g_bInStageZone[client] = false;
			}

			teleportEntitySafe(client, g_fSpawnLocation[zonegroup][realZone], g_fSpawnAngle[zonegroup][realZone], g_fSpawnVelocity[zonegroup][realZone], stopTime);

			return;
		}
	}
	else
	{
		// Check if the map has zones
		if (g_mapZonesCount > 0)
		{
			// Search for the zoneid we're teleporting to:
			int destinationZoneId = getZoneID(zonegroup, zone);
			g_iTeleportingZoneId[client] = destinationZoneId;

			// Check if zone was found
			if (destinationZoneId > -1)
			{
				// Check if teleporting to bonus
				if (zonegroup > 0)
				{
					// Set a bool to allow bonus zones to sit on top of start zones, e.g surf_aircontrol_ksf bonus 1
					g_bInBonus[client] = true;
					g_iInBonus[client] = zonegroup;
				}
				else
				{
					// Not teleporting to a bonus
					g_bInBonus[client] = false;
				}
				// Check if client is spectating, or not chosen a team yet
				if (GetClientTeam(client) == 1 || GetClientTeam(client) == 0)
				{
					if (stopTime)
						Client_Stop(client, 0);

					// Set spawn location to the destination zone:
					Array_Copy(g_mapZones[destinationZoneId][CenterPoint], g_fTeleLocation[client], 3);

					// Set specToStage flag
					g_bRespawnPosition[client] = false;
					g_specToStage[client] = true;

					// Spawn player
					TeamChangeActual(client, 0);

					if (realZone == 0)
					{
						g_bInStartZone[client] =  false;
						g_bInStageZone[client] = false;
					}
				}
				else // Teleport normally
				{
					bool destinationFound = false;
					int entity;
					float origin[3];
					float ang[3];
					for (int i = 0; i < GetArraySize(g_hDestinations); i++)
					{
						entity = GetArrayCell(g_hDestinations, i);
						GetEntPropVector(entity, Prop_Send, "m_vecOrigin", origin);
						/**
						*	Checks if coordinates are inside a zone
						* 	Return: zone id where location is in, or -1 if not inside a zone
						**/
						if (zonegroup > 0 && StrEqual(g_szMapName, "surf_mudkip_fix"))
						{
							char szBuffer[128];
							char szTargetName[128];
							GetEntPropString(entity, Prop_Send, "m_iName", szBuffer, sizeof(szBuffer));
							Format(szTargetName, 128, "bonus%i", zonegroup);
							if (zonegroup == 5)
								Format(szTargetName, 128, "%s_1", szTargetName);

							if (StrEqual(szBuffer, szTargetName))
							{
								destinationFound = true;
								GetEntPropVector(entity, Prop_Send, "m_angRotation", ang);
								break;
							}
						}
						else
						{
							if (IsInsideZone(origin) == destinationZoneId)
							{
								destinationFound = true;
								GetEntPropVector(entity, Prop_Send, "m_angRotation", ang);
								break;
							}
						}
					}
					
					// Set client speed to 0
					SetEntPropVector(client, Prop_Data, "m_vecVelocity", view_as<float>( { 0.0, 0.0, -100.0 } ));

					float fLocation[3];
					if (destinationFound)
						Array_Copy(origin, fLocation, 3);
					else
						Array_Copy(g_mapZones[destinationZoneId][CenterPoint], fLocation, 3);

					//fluffys dont cheat wrcps!
					g_bWrcpTimeractivated[client] = false;

					if (realZone == 0)
					{
						g_bInStartZone[client] =  false;
						g_bInStageZone[client] = false;
					}

					// Teleport
					if (destinationFound)
						teleportEntitySafe(client, fLocation, ang, view_as<float>( { 0.0, 0.0, -100.0 } ), stopTime);
					else
						teleportEntitySafe(client, fLocation, NULL_VECTOR, view_as<float>( { 0.0, 0.0, -100.0 } ), stopTime);
				}
			}
			else
				PrintToChat(client, " %cSurftimer %c| Destination zone not found!", LIMEGREEN, WHITE);
		}
		else
			PrintToChat(client, " %cSurftimer %c| No zones found in the map.", LIMEGREEN, WHITE);
	}
	g_bNotTeleporting[client] = true;
	return;
}

void teleportEntitySafe(int client, float fDestination[3], float fAngles[3], float fVelocity[3], bool stopTimer)
{
	if (stopTimer)
		Client_Stop(client, 1);

	int zId = setClientLocation(client, fDestination); // Set new location

	if (zId > -1 && g_bTimeractivated[client] && g_mapZones[zId][zoneType] == 2) // If teleporting to the end zone, stop timer
		Client_Stop(client, 0);

	// Teleport
	TeleportEntity(client, fDestination, fAngles, fVelocity);
}

int setClientLocation(int client, float fDestination[3])
{
	int zId = IsInsideZone(fDestination);

	// Hack fix for hooked zones setting the clients zone id to -1
	if (!StrEqual(g_mapZones[g_iTeleportingZoneId[client]][hookName], "None"))
	{
		// Any side effects from doing this? Not sure, I assume joni is getting a new zone id for a reason but I don't understand why when he gets the new zone id in the teleportClient function
		zId = g_iTeleportingZoneId[client];
	}

	if (zId != g_iClientInZone[client][3]) // Ignore location changes, if teleporting to the same zone they are already in
	{
		if (g_iClientInZone[client][0] != -1) // Ignore end touch if teleporting from within a zone
			g_bIgnoreZone[client] = true;

		if (zId > -1)
		{
			g_iClientInZone[client][0] = g_mapZones[zId][zoneType];
			g_iClientInZone[client][1] = g_mapZones[zId][zoneTypeId];
			g_iClientInZone[client][2] = g_mapZones[zId][zoneGroup];
			g_iClientInZone[client][3] = zId;
		}
		else
		{
			g_iClientInZone[client][0] = -1;
			g_iClientInZone[client][1] = -1;
			g_iClientInZone[client][3] = -1;
		}
	}
	return zId;
}

/*
void performTeleport(int client, float pos[3], float ang[3], float vel[3])
{
	Client_Stop(client, 1);
	// Types: Start(1), End(2), Stage(3), Checkpoint(4), Speed(5), TeleToStart(6), Validator(7), Chekcer(8), Stop(0)
	if (destinationZoneId != g_iClientInZone[client][3])
	{
		// If teleporting from inside a zone, ignore the end touch
		if (g_iClientInZone[client][0] != -1)
			g_bIgnoreZone[client] = true;

		if (destinationZoneId > -1)
		{
			g_iClientInZone[client][0] = g_mapZones[destinationZoneId][zoneType];
			g_iClientInZone[client][1] = g_mapZones[destinationZoneId][zoneTypeId];
			g_iClientInZone[client][2] = g_mapZones[destinationZoneId][zoneGroup];
			g_iClientInZone[client][3] = destinationZoneId;
		}
		else
			if (targetClient > -1)
			{
				g_iClientInZone[client][0] = -1;
				g_iClientInZone[client][1] = -1;
				g_iClientInZone[client][2] = g_iClientInZone[targetClient][2];
				g_iClientInZone[client][3] = -1;
			}
	}
	TeleportEntity(client, pos, ang, vel);
}*/


stock void WriteChatLog(int client, const char[] sayOrSayTeam, const char[] msg)
{
	char name[MAX_NAME_LENGTH], steamid[32], teamName[10];

	GetClientName(client, name, MAX_NAME_LENGTH);
	GetTeamName(GetClientTeam(client), teamName, sizeof(teamName));
	GetClientAuthId(client, AuthId_Steam2, steamid, 32, true);
	LogToGame("\"%s<%i><%s><%s>\" %s \"%s\"", name, GetClientUserId(client), steamid, teamName, sayOrSayTeam, msg);
}

// PushFix by Mev, George, & Blacky
// https://forums.alliedmods.net/showthread.php?t=267131
public void SinCos(float radians, float &sine, float &cosine)
{
	sine = Sine(radians);
	cosine = Cosine(radians);
}

void DoPush(int entity, int other, float m_vecPushDir[3])
{
	if (0 < other <= MaxClients)
	{
		if (!DoesClientPassFilter(entity, other))
		{
			return;
		}

		float newVelocity[3], angRotation[3], fPushSpeed;

		fPushSpeed = GetEntPropFloat(entity, Prop_Data, "m_flSpeed");
		GetEntPropVector(entity, Prop_Data, "m_angRotation", angRotation);

		// Rotate vector according to world
		float sr, sp, sy, cr, cp, cy;
		float matrix[3][4];

		SinCos(DegToRad(angRotation[1]), sy, cy);
		SinCos(DegToRad(angRotation[0]), sp, cp);
		SinCos(DegToRad(angRotation[2]), sr, cr);

		matrix[0][0] = cp * cy;
		matrix[1][0] = cp * sy;
		matrix[2][0] = -sp;

		float crcy = cr * cy;
		float crsy = cr * sy;
		float srcy = sr * cy;
		float srsy = sr * sy;

		matrix[0][1] = sp * srcy - crsy;
		matrix[1][1] = sp * srsy + crcy;
		matrix[2][1] = sr * cp;

		matrix[0][2] = (sp * crcy + srsy);
		matrix[1][2] = (sp * crsy - srcy);
		matrix[2][2] = cr * cp;

		matrix[0][3] = angRotation[0];
		matrix[1][3] = angRotation[1];
		matrix[2][3] = angRotation[2];

		float vecAbsDir[3];
		vecAbsDir[0] = m_vecPushDir[0] * matrix[0][0] + m_vecPushDir[1] * matrix[0][1] + m_vecPushDir[2] * matrix[0][2];
		vecAbsDir[1] = m_vecPushDir[0] * matrix[1][0] + m_vecPushDir[1] * matrix[1][1] + m_vecPushDir[2] * matrix[1][2];
		vecAbsDir[2] = m_vecPushDir[0] * matrix[2][0] + m_vecPushDir[1] * matrix[2][1] + m_vecPushDir[2] * matrix[2][2];

		ScaleVector(vecAbsDir, fPushSpeed);

		// Apply the base velocity directly to abs velocity
		GetEntPropVector(other, Prop_Data, "m_vecVelocity", newVelocity);

		newVelocity[2] = newVelocity[2] + (vecAbsDir[2] * GetTickInterval());
		g_bPushing[other] = true;
		TeleportEntity(other, NULL_VECTOR, NULL_VECTOR, newVelocity);

		// Remove the base velocity z height so abs velocity can do it and add old base velocity if there is any
		vecAbsDir[2] = 0.0;
		if (GetEntityFlags(other) & FL_BASEVELOCITY)
		{
			float vecBaseVel[3];
			GetEntPropVector(other, Prop_Data, "m_vecBaseVelocity", vecBaseVel);
			AddVectors(vecAbsDir, vecBaseVel, vecAbsDir);
		}

		SetEntPropVector(other, Prop_Data, "m_vecBaseVelocity", vecAbsDir);
		SetEntityFlags(other, GetEntityFlags(other) | FL_BASEVELOCITY);
	}
}

void GetFilterTargetName(char[] filtername, char[] buffer, int maxlen)
{
	int filter = FindEntityByTargetname(filtername);
	if (filter != -1)
	{
		GetEntPropString(filter, Prop_Data, "m_iFilterName", buffer, maxlen);
	}
}

int FindEntityByTargetname(char[] targetname)
{
	int entity = -1;
	char sName[64];
	while ((entity = FindEntityByClassname(entity, "filter_activator_name")) != -1)
	{
		GetEntPropString(entity, Prop_Data, "m_iName", sName, 64);
		if (StrEqual(sName, targetname))
		{
			return entity;
		}
	}

	return -1;
}

bool DoesClientPassFilter(int entity, int client)
{
	char sPushFilter[64];
	GetEntPropString(entity, Prop_Data, "m_iFilterName", sPushFilter, sizeof sPushFilter);
	if (StrEqual(sPushFilter, ""))
	{
		return true;
	}
	char sFilterName[64];
	GetFilterTargetName(sPushFilter, sFilterName, sizeof sFilterName);
	char sClientName[64];
	GetEntPropString(client, Prop_Data, "m_iName", sClientName, sizeof sClientName);

	return StrEqual(sFilterName, sClientName, true);
}

//https://forums.alliedmods.net/showthread.php?t=206308
void TeamChangeActual(int client, int toteam)
{
	if (GetConVarBool(g_hForceCT)) {
		if (toteam == 0 || toteam == 2) {
			toteam = 3;
		}
	} else {
		if (toteam == 0) {  // client is auto-assigning
			toteam = GetRandomInt(2, 3);
		}
	}

	if (g_bSpectate[client])
	{
		if (g_fStartTime[client] != -1.0 && g_bTimeractivated[client] == true)
			g_fPauseTime[client] = GetGameTime() - g_fStartPauseTime[client];
		g_bSpectate[client] = false;
	}

//	if (!IsPlayerAlive(client) && toteam > 1)
//		CS_RespawnPlayer(client);

	ChangeClientTeam(client, toteam);

	return;
}


public int getZoneID(int zoneGrp, int stage)
{
	if (0 < stage < 2) // Search for map's starting zone
	{
		for (int i = 0; i < g_mapZonesCount; i++)
		{
			if (g_mapZones[i][zoneGroup] == zoneGrp && (g_mapZones[i][zoneType] == 1 || g_mapZones[i][zoneType] == 5) && g_mapZones[i][zoneTypeId] == 0)
				return i;
		}
		for (int i = 0; i < g_mapZonesCount; i++) // If no start zone with typeId 0 found, return any start zone
		{
			if (g_mapZones[i][zoneGroup] == zoneGrp && (g_mapZones[i][zoneType] == 1 || g_mapZones[i][zoneType] == 5))
				return i;
		}
	}
	else if (stage > 1) // Search for a stage
	{
		for (int i = 0; i < g_mapZonesCount; i++)
		{
			if (g_mapZones[i][zoneGroup] == zoneGrp && g_mapZones[i][zoneType] == 3 && g_mapZones[i][zoneTypeId] == (stage - 2))
			{
				return i;
			}
		}
	}
	else if (stage < 0) // Search for the end zone
	{
		for (int i = 0; i < g_mapZonesCount; i++)
		{
			if (g_mapZones[i][zoneType] == 2 && g_mapZones[i][zoneGroup] == zoneGrp)
			{
				return i;
			}
		}
	}
	return -1;
}

public void readMultiServerMapcycle()
{
	char sPath[PLATFORM_MAX_PATH];
	char line[128];

	ClearArray(g_MapList);
	g_pr_MapCount = 0;
	BuildPath(Path_SM, sPath, sizeof(sPath), "%s", MULTI_SERVER_MAPCYCLE);
	Handle fileHandle = OpenFile(sPath, "r");

	if (fileHandle != null)
	{
		while (!IsEndOfFile(fileHandle) && ReadFileLine(fileHandle, line, sizeof(line)))
		{
			TrimString(line); // Only take the map name
			if (StrContains(line, "//", true) == -1) // Escape comments
			{
				g_pr_MapCount++;
				PushArrayString(g_MapList, line);
	 		}
		}
	}
	else
		SetFailState("[surftimer] %s is empty or does not exist.", MULTI_SERVER_MAPCYCLE);

	if (fileHandle != null)
		CloseHandle(fileHandle);

	return;
}

public void readMapycycle()
{
	char map[128];
	char map2[128];
	int mapListSerial = -1;
	g_pr_MapCount = 0;
	if (ReadMapList(g_MapList,
			mapListSerial,
			"mapcyclefile",
			MAPLIST_FLAG_CLEARARRAY | MAPLIST_FLAG_NO_DEFAULT)
		 == null)
	{
		if (mapListSerial == -1)
		{
			SetFailState("[surftimer] mapcycle.txt is empty or does not exist.");
		}
	}
	for (int i = 0; i < GetArraySize(g_MapList); i++)
	{
		GetArrayString(g_MapList, i, map, sizeof(map));
		if (!StrEqual(map, "", false))
		{
			//fix workshop map name
			char mapPieces[6][128];
			int lastPiece = ExplodeString(map, "/", mapPieces, sizeof(mapPieces), sizeof(mapPieces[]));
			Format(map2, sizeof(map2), "%s", mapPieces[lastPiece - 1]);
			SetArrayString(g_MapList, i, map2);
			g_pr_MapCount++;
		}
	}
	return;
}

public bool loadHiddenChatCommands()
{
	char sPath[PLATFORM_MAX_PATH];
	char line[64];

	//add blocked chat commands list
	for (int x = 0; x < 256; x++)
		Format(g_BlockedChatText[x], sizeof(g_BlockedChatText), "");

	BuildPath(Path_SM, sPath, sizeof(sPath), "%s", BLOCKED_LIST_PATH);
	int count = 0;
	Handle fileHandle = OpenFile(sPath, "r");
	if (fileHandle != null)
	{
		while (!IsEndOfFile(fileHandle) && ReadFileLine(fileHandle, line, sizeof(line)))
		{
			TrimString(line);
			if ((StrContains(line, "//", true) == -1) && count < 256)
			{
				Format(g_BlockedChatText[count], sizeof(g_BlockedChatText), "%s", line);
				count++;
			}
		}
	}
	else
		LogError("[surftimer] %s is empty or does not exist.", BLOCKED_LIST_PATH);

	if (fileHandle != null)
		CloseHandle(fileHandle);

	return true;
}

public void addColorToString(char[] StringToAdd, int size)
{
	ReplaceString(StringToAdd, size, "{default}", szWHITE, false);
	ReplaceString(StringToAdd, size, "{white}", szWHITE, false);
	ReplaceString(StringToAdd, size, "{darkred}", szDARKRED, false);
	ReplaceString(StringToAdd, size, "{green}", szGREEN, false);
	ReplaceString(StringToAdd, size, "{lime}", szLIMEGREEN, false);
	ReplaceString(StringToAdd, size, "{blue}", szBLUE, false);
	ReplaceString(StringToAdd, size, "{mossgreen}", szMOSSGREEN, false);
	ReplaceString(StringToAdd, size, "{red}", szRED, false);
	ReplaceString(StringToAdd, size, "{grey}", szGRAY, false);
	ReplaceString(StringToAdd, size, "{gray}", szGRAY, false);
	ReplaceString(StringToAdd, size, "{yellow}", szYELLOW, false);
	ReplaceString(StringToAdd, size, "{lightblue}", szLIGHTBLUE, false);
	ReplaceString(StringToAdd, size, "{darkblue}", szDARKBLUE, false);
	ReplaceString(StringToAdd, size, "{pink}", szPINK, false);
	ReplaceString(StringToAdd, size, "{lightred}", szLIGHTRED, false);
	ReplaceString(StringToAdd, size, "{purple}", szPURPLE, false);
	ReplaceString(StringToAdd, size, "{darkgrey}", szDARKGREY, false);
	ReplaceString(StringToAdd, size, "{darkgray}", szDARKGREY, false);
	ReplaceString(StringToAdd, size, "{limegreen}", szLIMEGREEN, false);
	ReplaceString(StringToAdd, size, "{mossgreen}", szMOSSGREEN, false);
	ReplaceString(StringToAdd, size, "{darkblue}", szDARKBLUE, false);
	ReplaceString(StringToAdd, size, "{lime}", szLIMEGREEN, false);
	ReplaceString(StringToAdd, size, "{orange}", szORANGE, false);
}

public int getFirstColor(char[] StringToSearch)
{
	if (StrContains(StringToSearch, "{default}", false) != -1 || StrContains(StringToSearch, "{white}", false) != -1)
		return 0;
	else if (StrContains(StringToSearch, "{darkred}", false) != -1)
		return 1;
	else if (StrContains(StringToSearch, "{green}", false) != -1)
		return 2;
	else if (StrContains(StringToSearch, "{lightgreen}", false) != -1 || StrContains(StringToSearch, "{limegreen}", false) != -1 || StrContains(StringToSearch, "{lime}", false) != -1)
		return 3;
	else if (StrContains(StringToSearch, "{blue}", false) != -1)
		return 4;
	else if (StrContains(StringToSearch, "{olive}", false) != -1 || StrContains(StringToSearch, "{mossgreen}", false) != -1)
		return 5;
	else if (StrContains(StringToSearch, "{red}", false) != -1)
		return 6;
	else if (StrContains(StringToSearch, "{grey}", false) != -1)
		return 7;
	else if (StrContains(StringToSearch, "{yellow}", false) != -1)
		return 8;
	else if (StrContains(StringToSearch, "{lightblue}", false) != -1)
		return 9;
	else if (StrContains(StringToSearch, "{steelblue}", false) != -1 || StrContains(StringToSearch, "{darkblue}", false) != -1)
		return 10;
	else if (StrContains(StringToSearch, "{pink}", false) != -1)
		return 11;
	else if (StrContains(StringToSearch, "{lightred}", false) != -1)
		return 12;
	else if (StrContains(StringToSearch, "{purple}", false) != -1)
		return 13;
	else if (StrContains(StringToSearch, "{darkgrey}", false) != -1 || StrContains(StringToSearch, "{darkgray}", false) != -1)
		return 14;
	else if (StrContains(StringToSearch, "{orange}", false) != -1)
		return 15;
	else
		return 0;
}

public void setNameColor(char[] ClientName, int index, int size)
{
	switch (index)
	{
		case 0: // 1st Rank
			Format(ClientName, size, "%c%s", WHITE, ClientName);
		case 1:
			Format(ClientName, size, "%c%s", DARKRED, ClientName);
		case 2:
			Format(ClientName, size, "%c%s", GREEN, ClientName);
		case 3:
			Format(ClientName, size, "%c%s", LIMEGREEN, ClientName);
		case 4:
			Format(ClientName, size, "%c%s", BLUE, ClientName);
		case 5:
			Format(ClientName, size, "%c%s", MOSSGREEN, ClientName);
		case 6:
			Format(ClientName, size, "%c%s", RED, ClientName);
		case 7:
			Format(ClientName, size, "%c%s", GRAY, ClientName);
		case 8:
			Format(ClientName, size, "%c%s", YELLOW, ClientName);
		case 9:
			Format(ClientName, size, "%c%s", LIGHTBLUE, ClientName);
		case 10:
			Format(ClientName, size, "%c%s", DARKBLUE, ClientName);
		case 11:
			Format(ClientName, size, "%c%s", PINK, ClientName);
		case 12:
			Format(ClientName, size, "%c%s", LIGHTRED, ClientName);
		case 13:
			Format(ClientName, size, "%c%s", PURPLE, ClientName);
		case 14:
			Format(ClientName, size, "%c%s", DARKGREY, ClientName);
		case 15:
			Format(ClientName, size, "%c%s", ORANGE, ClientName);
		/*default:
			Format(ClientName, size, "%c%s", WHITE, ClientName);*/
	}
}

public void setTextColor(char[] ClientText, int index, int size)
{
	switch (index)
	{
		case 0: // 1st Rank
			Format(ClientText, size, "%c%s", WHITE, ClientText);
		case 1:
			Format(ClientText, size, "%c%s", DARKRED, ClientText);
		case 2:
			Format(ClientText, size, "%c%s", GREEN, ClientText);
		case 3:
			Format(ClientText, size, "%c%s", LIMEGREEN, ClientText);
		case 4:
			Format(ClientText, size, "%c%s", BLUE, ClientText);
		case 5:
			Format(ClientText, size, "%c%s", MOSSGREEN, ClientText);
		case 6:
			Format(ClientText, size, "%c%s", RED, ClientText);
		case 7:
			Format(ClientText, size, "%c%s", GRAY, ClientText);
		case 8:
			Format(ClientText, size, "%c%s", YELLOW, ClientText);
		case 9:
			Format(ClientText, size, "%c%s", LIGHTBLUE, ClientText);
		case 10:
			Format(ClientText, size, "%c%s", DARKBLUE, ClientText);
		case 11:
			Format(ClientText, size, "%c%s", PINK, ClientText);
		case 12:
			Format(ClientText, size, "%c%s", LIGHTRED, ClientText);
		case 13:
			Format(ClientText, size, "%c%s", PURPLE, ClientText);
		case 14:
			Format(ClientText, size, "%c%s", DARKGREY, ClientText);
		case 15:
			Format(ClientText, size, "%c%s", ORANGE, ClientText);
	}
}

public void parseColorsFromString(char[] ParseString, int size)
{
	ReplaceString(ParseString, size, "{default}", "", false);
	ReplaceString(ParseString, size, "{white}", "", false);
	ReplaceString(ParseString, size, "{darkred}", "", false);
	ReplaceString(ParseString, size, "{green}", "", false);
	ReplaceString(ParseString, size, "{lime}", "", false);
	ReplaceString(ParseString, size, "{blue}", "", false);
	ReplaceString(ParseString, size, "{mossgreen}", "", false);
	ReplaceString(ParseString, size, "{red}", "", false);
	ReplaceString(ParseString, size, "{grey}", "", false);
	ReplaceString(ParseString, size, "{gray}", "", false);
	ReplaceString(ParseString, size, "{yellow}", "", false);
	ReplaceString(ParseString, size, "{lightblue}", "", false);
	ReplaceString(ParseString, size, "{darkblue}", "", false);
	ReplaceString(ParseString, size, "{pink}", "", false);
	ReplaceString(ParseString, size, "{lightred}", "", false);
	ReplaceString(ParseString, size, "{purple}", "", false);
	ReplaceString(ParseString, size, "{darkgrey}", "", false);
	ReplaceString(ParseString, size, "{darkgray}", "", false);
	ReplaceString(ParseString, size, "{limegreen}", "", false);
	ReplaceString(ParseString, size, "{mossgreen}", "", false);
	ReplaceString(ParseString, size, "{darkblue}", "", false);
	ReplaceString(ParseString, size, "{lime}", "", false);
	ReplaceString(ParseString, size, "{orange}", "", false);
	ReplaceString(ParseString, size, "{olive}", "", false);
}

public void checkSpawnPoints()
{
	int tEnt, ctEnt;
	float f_spawnLocation[3], f_spawnAngle[3];

	if (FindEntityByClassname(ctEnt, "info_player_counterterrorist") == -1 || FindEntityByClassname(tEnt, "info_player_terrorist") == -1) // No proper zones were found, try to recreate
	{
		// Check if spawn point has been added to the database with !addspawn
		char szQuery[256];
		Format(szQuery, 256, "SELECT pos_x, pos_y, pos_z, ang_x, ang_y, ang_z FROM ck_spawnlocations WHERE mapname = '%s' AND zonegroup = 0;", g_szMapName);
		Handle query = SQL_Query(g_hDb, szQuery);
		if (query == INVALID_HANDLE)
		{
			char szError[255];
			SQL_GetError(g_hDb, szError, sizeof(szError));
			PrintToServer("Failed to query map's spawn points (error: %s)", szError);
		}
		else
		{
			if (SQL_HasResultSet(query) && SQL_FetchRow(query))
			{
				f_spawnLocation[0] = SQL_FetchFloat(query, 0);
				f_spawnLocation[1] = SQL_FetchFloat(query, 1);
				f_spawnLocation[2] = SQL_FetchFloat(query, 2);
				f_spawnAngle[0] = SQL_FetchFloat(query, 3);
				f_spawnAngle[1] = SQL_FetchFloat(query, 4);
				f_spawnAngle[2] = SQL_FetchFloat(query, 5);
			}
			CloseHandle(query);
		}

		if (f_spawnLocation[0] == 0.0 && f_spawnLocation[1] == 0.0 && f_spawnLocation[2] == 0.0) // No spawnpoint added to map with !addspawn, try to find spawns from map
		{
			PrintToServer("surftimer | No valid spawns found in the map.");
			int zoneEnt = -1;
			zoneEnt = FindEntityByClassname(zoneEnt, "info_player_teamspawn"); // CSS/TF spawn found

			if (zoneEnt != -1)
			{
				GetEntPropVector(zoneEnt, Prop_Data, "m_angRotation", f_spawnAngle);
				GetEntPropVector(zoneEnt, Prop_Send, "m_vecOrigin", f_spawnLocation);

				PrintToServer("surftimer | Found info_player_teamspawn in location %f, %f, %f", f_spawnLocation[0], f_spawnLocation[1], f_spawnLocation[2]);
			}
			else
			{
				zoneEnt = FindEntityByClassname(zoneEnt, "info_player_start"); // Random spawn
				if (zoneEnt != -1)
				{
					GetEntPropVector(zoneEnt, Prop_Data, "m_angRotation", f_spawnAngle);
					GetEntPropVector(zoneEnt, Prop_Send, "m_vecOrigin", f_spawnLocation);

					PrintToServer("surftimer | Found info_player_start in location %f, %f, %f", f_spawnLocation[0], f_spawnLocation[1], f_spawnLocation[2]);
				}
				else
				{
					PrintToServer("No valid spawn points found in the map! Record bots will not work. Try adding a spawn point with !addspawn");
					return;
				}
			}
		}

		// Start creating new spawnpoints
		int pointT, pointCT, count = 0;
		while (count < 64)
		{
			pointT = CreateEntityByName("info_player_terrorist");
			ActivateEntity(pointT);
			pointCT = CreateEntityByName("info_player_counterterrorist");
			ActivateEntity(pointCT);
			if (IsValidEntity(pointT) && IsValidEntity(pointCT) && DispatchSpawn(pointT) && DispatchSpawn(pointCT))
			{
				TeleportEntity(pointT, f_spawnLocation, f_spawnAngle, NULL_VECTOR);
				TeleportEntity(pointCT, f_spawnLocation, f_spawnAngle, NULL_VECTOR);
				count++;
			}
		}

		// Remove possiblt bad spawns
		char sClassName[128];
		for (int i = 0; i < GetMaxEntities(); i++)
		{
			if (IsValidEdict(i) && IsValidEntity(i) && GetEdictClassname(i, sClassName, sizeof(sClassName)))
			{
				if (StrEqual(sClassName, "info_player_start") || StrEqual(sClassName, "info_player_teamspawn"))
				{
					RemoveEdict(i);
				}
			}
		}
	}
	else // Valid spawns were found, check that there is enough of them
	{
		int ent, spawnpoint;
		ent = -1;
		while ((ent = FindEntityByClassname(ent, "info_player_terrorist")) != -1)
		{
			if (tEnt == 0)
			{
				GetEntPropVector(ent, Prop_Data, "m_angRotation", f_spawnAngle);
				GetEntPropVector(ent, Prop_Send, "m_vecOrigin", f_spawnLocation);
			}
			tEnt++;
		}
		while ((ent = FindEntityByClassname(ent, "info_player_counterterrorist")) != -1)
		{
			if (ctEnt == 0 && tEnt == 0)
			{
				GetEntPropVector(ent, Prop_Data, "m_angRotation", f_spawnAngle);
				GetEntPropVector(ent, Prop_Send, "m_vecOrigin", f_spawnLocation);
			}
			ctEnt++;
		}

		if (tEnt > 0 || ctEnt > 0)
		{
			if (tEnt < 64)
			{
				while (tEnt < 64)
				{
					spawnpoint = CreateEntityByName("info_player_terrorist");
					if (IsValidEntity(spawnpoint) && DispatchSpawn(spawnpoint))
					{
						ActivateEntity(spawnpoint);
						TeleportEntity(spawnpoint, f_spawnLocation, f_spawnAngle, NULL_VECTOR);
						tEnt++;
					}
				}
			}

			if (ctEnt < 64)
			{
				while (ctEnt < 64)
				{
					spawnpoint = CreateEntityByName("info_player_counterterrorist");
					if (IsValidEntity(spawnpoint) && DispatchSpawn(spawnpoint))
					{
						ActivateEntity(spawnpoint);
						TeleportEntity(spawnpoint, f_spawnLocation, f_spawnAngle, NULL_VECTOR);
						ctEnt++;
					}
				}
			}
		}
	}
}

public Action CallAdmin_OnDrawOwnReason(int client)
{
	g_bClientOwnReason[client] = true;
	return Plugin_Continue;
}

public bool checkSpam(int client)
{
	float time = GetGameTime();
	if (GetConVarFloat(g_hChatSpamFilter) == 0.0)
		return false;

	if (!IsValidClient(client) || (GetUserFlagBits(client) & ADMFLAG_ROOT) || (GetUserFlagBits(client) & ADMFLAG_GENERIC))
		return false;

	bool result = false;

	if (time - g_fLastChatMessage[client] < GetConVarFloat(g_hChatSpamFilter))
	{
		result = true;
		g_messages[client]++;
	}
	else
		g_messages[client] = 0;


	if (4 < g_messages[client] < 8)
		PrintToChat(client, " %cSurftimer %c| %cStop spamming or you will get kicked!", LIMEGREEN, WHITE, RED);
	else
		if (g_messages[client] >= 8)
	{
		KickClient(client, "Kicked for spamming.");
		return true;
	}

	g_fLastChatMessage[client] = time;
	return result;
}

stock bool IsValidClient(int client)
{
	if (client >= 1 && client <= MaxClients && IsValidEntity(client) && IsClientConnected(client) && IsClientInGame(client))
		return true;
	return false;
}

public void PrintConsoleInfo(int client)
{

	if (g_hSkillGroups == null)
	{
		CreateTimer(5.0, reloadConsoleInfo, client);
		return;
	}

	int iConsoleTimeleft;
	GetMapTimeLeft(iConsoleTimeleft);
	int mins, secs;
	char finalOutput[1024];
	mins = iConsoleTimeleft / 60;
	secs = iConsoleTimeleft % 60;
	Format(finalOutput, 1024, "%d:%02d", mins, secs);
	float fltickrate = 1.0 / GetTickInterval();

	if (!IsValidClient(client) || IsFakeClient(client))
		return;

	PrintToConsole(client, "-----------------------------------------------------------------------------------------------------------");
	PrintToConsole(client, "Surftimer v%s - Server tickrate: %i", VERSION, RoundToNearest(fltickrate));
	PrintToConsole(client, " ");
	PrintToConsole(client, "-----------------------------------------------------------------------------------------------------------");
	PrintToConsole(client, " ");
	return;
}
stock void FakePrecacheSound(const char[] szPath)
{
	AddToStringTable(FindStringTable("soundprecache"), szPath);
}

public Action BlockRadio(int client, const char[] command, int args)
{
	if (!GetConVarBool(g_hRadioCommands) && IsValidClient(client))
	{
		PrintToChat(client, "%t", "RadioCommandsDisabled", LIMEGREEN, WHITE);
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public void StringToUpper(char[] input)
{
	for (int i = 0; ; i++)
	{
		if (input[i] == '\0')
			return;
		input[i] = CharToUpper(input[i]);
	}
}

public void GetCountry(int client)
{
	if (client != 0)
	{
		if (!IsFakeClient(client))
		{
			char IP[16];
			char code2[3];
			GetClientIP(client, IP, 16);

			//COUNTRY
			GeoipCountry(IP, g_szCountry[client], 100);
			if (!strcmp(g_szCountry[client], NULL_STRING))
				Format(g_szCountry[client], 100, "Unknown", g_szCountry[client]);
			else
				if (StrContains(g_szCountry[client], "United", false) != -1 ||
				StrContains(g_szCountry[client], "Republic", false) != -1 ||
				StrContains(g_szCountry[client], "Federation", false) != -1 ||
				StrContains(g_szCountry[client], "Island", false) != -1 ||
				StrContains(g_szCountry[client], "Netherlands", false) != -1 ||
				StrContains(g_szCountry[client], "Isle", false) != -1 ||
				StrContains(g_szCountry[client], "Bahamas", false) != -1 ||
				StrContains(g_szCountry[client], "Maldives", false) != -1 ||
				StrContains(g_szCountry[client], "Philippines", false) != -1 ||
				StrContains(g_szCountry[client], "Vatican", false) != -1)
			{
				Format(g_szCountry[client], 100, "The %s", g_szCountry[client]);
			}
			//CODE
			if (GeoipCode2(IP, code2))
			{
				Format(g_szCountryCode[client], 16, "%s", code2);
			}
			else
				Format(g_szCountryCode[client], 16, "??");
		}
	}
}

stock void StripAllWeapons(int client)
{
	int iEnt;
	for (int i = 0; i <= 5; i++)
	{
		if (i != 2)
			while ((iEnt = GetPlayerWeaponSlot(client, i)) != -1)
		{
			RemovePlayerItem(client, iEnt);
			RemoveEdict(iEnt);
		}
	}
	if (GetPlayerWeaponSlot(client, 2) == -1)
		GivePlayerItem(client, "weapon_knife");
}

public void MovementCheck(int client)
{
	MoveType mt;
	mt = GetEntityMoveType(client);
	if (mt == MOVETYPE_FLYGRAVITY)
	{
		Client_Stop(client, 1);
	}
}

public void PlayButtonSound(int client)
{
	if (!GetConVarBool(g_hSoundEnabled))
		return;

	// Players button sound
	if (!IsFakeClient(client))
	{
		char buffer[255];
		GetConVarString(g_hSoundPath, buffer, 255);
		Format(buffer, sizeof(buffer), "play %s", buffer);
		ClientCommand(client, buffer);
	}

	// Spectators button sound
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && !IsPlayerAlive(i))
		{
			int SpecMode = GetEntProp(i, Prop_Send, "m_iObserverMode");
			if (SpecMode == 4 || SpecMode == 5)
			{
				int Target = GetEntPropEnt(i, Prop_Send, "m_hObserverTarget");
				if (Target == client)
				{
					char szsound[255];
					GetConVarString(g_hSoundPath, szsound, 256);
					Format(szsound, sizeof(szsound), "play %s", szsound);
					ClientCommand(i, szsound);
				}
			}
		}
	}
}

public void FixPlayerName(int client)
{
	char szName[64];
	char szOldName[64];
	GetClientName(client, szName, 64);
	Format(szOldName, 64, "%s ", szName);
	ReplaceChar("'", "`", szName);
	if (!(StrEqual(szOldName, szName)))
	{
		SetClientInfo(client, "name", szName);
		SetEntPropString(client, Prop_Data, "m_szNetname", szName);
		SetClientName(client, szName);
	}
}

public void LimitSpeed(int client)
{
	// Dont limits speed if in practice mode, or if there is no end zone in current zonegroup
	if (!IsValidClient(client) || !IsPlayerAlive(client) || IsFakeClient(client) || g_bPracticeMode[client] || g_mapZonesTypeCount[g_iClientInZone[client][2]][2] == 0)
		return;

	float speedCap = 0.0, CurVelVec[3];

	if (g_iClientInZone[client][0] == 1 && g_iClientInZone[client][2] > 0)
		speedCap = GetConVarFloat(g_hBonusPreSpeed);
	else
		if (g_iClientInZone[client][0] == 1)
			speedCap = GetConVarFloat(g_hStartPreSpeed);
		else
			if (g_iClientInZone[client][0] == 5)
			{
				if (!g_bNoClipUsed[client])
					speedCap = GetConVarFloat(g_hSpeedPreSpeed);
				else
					speedCap = GetConVarFloat(g_hStartPreSpeed); // If noclipping, top speed at normal start zone speed
			}
			else
			{
				// Stages
				if (g_iClientInZone[client][0] == 3)
				{
					switch(g_iClientInZone[client][1])
					{
						case 0: speedCap = g_fStagePreSpeed[0]; // Start From Stage 2
						case 1: speedCap = g_fStagePreSpeed[1];
						case 2: speedCap = g_fStagePreSpeed[2];
						case 3: speedCap = g_fStagePreSpeed[3];
						case 4: speedCap = g_fStagePreSpeed[4];
						case 5: speedCap = g_fStagePreSpeed[5];
						case 6: speedCap = g_fStagePreSpeed[6];
						case 7: speedCap = g_fStagePreSpeed[7];
						case 8: speedCap = g_fStagePreSpeed[8];
						case 9: speedCap = g_fStagePreSpeed[9];
						case 10: speedCap = g_fStagePreSpeed[10];
						case 11: speedCap = g_fStagePreSpeed[11];
						case 12: speedCap = g_fStagePreSpeed[12];
						case 13: speedCap = g_fStagePreSpeed[13];
						case 14: speedCap = g_fStagePreSpeed[14];
						case 15: speedCap = g_fStagePreSpeed[15];
						case 16: speedCap = g_fStagePreSpeed[16];
						case 17: speedCap = g_fStagePreSpeed[17];
						case 18: speedCap = g_fStagePreSpeed[18];
						case 19: speedCap = g_fStagePreSpeed[19];
						case 20: speedCap = g_fStagePreSpeed[20];
						case 21: speedCap = g_fStagePreSpeed[21];
						case 22: speedCap = g_fStagePreSpeed[22];
						case 23: speedCap = g_fStagePreSpeed[23];
						case 24: speedCap = g_fStagePreSpeed[24];
						case 25: speedCap = g_fStagePreSpeed[25];
						case 26: speedCap = g_fStagePreSpeed[26];
						case 27: speedCap = g_fStagePreSpeed[27];
						case 28: speedCap = g_fStagePreSpeed[28];
						case 29: speedCap = g_fStagePreSpeed[29];
						case 30: speedCap = g_fStagePreSpeed[30];
						case 31: speedCap = g_fStagePreSpeed[31];
						case 32: speedCap = g_fStagePreSpeed[32];
						case 33: speedCap = g_fStagePreSpeed[33]; // End at stage 35
					}
				}
			}

	if (speedCap == 0.0)
		return;

	GetEntPropVector(client, Prop_Data, "m_vecVelocity", CurVelVec);

	if (CurVelVec[0] == 0.0)
		CurVelVec[0] = 1.0;
	if (CurVelVec[1] == 0.0)
		CurVelVec[1] = 1.0;
	if (CurVelVec[2] == 0.0)
		CurVelVec[2] = 1.0;

	float currentspeed = SquareRoot(Pow(CurVelVec[0], 2.0) + Pow(CurVelVec[1], 2.0));
	// float xy = SquareRoot(Pow(CurVelVec[0], 2.0) + Pow(CurVelVec[1], 2.0));
	// float z = SquareRoot(Pow(CurVelVec[2], 2.0));

	if (currentspeed > speedCap)
	{
		NormalizeVector(CurVelVec, CurVelVec);
		ScaleVector(CurVelVec, speedCap);
		// PrintToChat(client, "XY: %f Z: %f XYZ: %f", xy, z, currentspeed);
		// PrintToChat(client, "%f", CurVelVec);
		// PrintToChat(client, "%f %f %f", CurVelVec[0], CurVelVec[1], CurVelVec[2]);
		// PrintToChat(client, "Limited speed");
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, CurVelVec);
		//TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, CurVelVec);
	}
}

public void LimitMaxSpeed(int client, float fMaxSpeed)
{
	if (!IsValidClient(client) || !IsPlayerAlive(client) || IsFakeClient(client))
		return;

	float CurVelVec[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", CurVelVec);

	if (CurVelVec[0] == 0.0)
		CurVelVec[0] = 1.0;
	if (CurVelVec[1] == 0.0)
		CurVelVec[1] = 1.0;
	if (CurVelVec[2] == 0.0)
		CurVelVec[2] = 1.0;

	float currentspeed = SquareRoot(Pow(CurVelVec[0], 2.0) + Pow(CurVelVec[1], 2.0));

	if (currentspeed > fMaxSpeed)
	{
		if (CurVelVec[0] > fMaxSpeed)
			CurVelVec[0] = fMaxSpeed;
		if (CurVelVec[1] > fMaxSpeed)
			CurVelVec[1] = fMaxSpeed;
		if (CurVelVec[2] > fMaxSpeed)
			CurVelVec[2] = fMaxSpeed;

		NormalizeVector(CurVelVec, CurVelVec);
		ScaleVector(CurVelVec, fMaxSpeed);
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, CurVelVec);
	}
}

public bool Base_TraceFilter(int entity, int contentsMask, any data)
{
	if (entity != data)
		return (false);

	return (true);
}

public void SetClientDefaults(int client)
{
	float GameTime = GetGameTime();
	g_fLastCommandBack[client] = GameTime;
	g_ClientSelectedZone[client] = -1;
	g_Editing[client] = 0;
	g_iSelectedTrigger[client] = -1;

	g_bClientRestarting[client] = false;
	g_fClientRestarting[client] = GameTime;
	g_fErrorMessage[client] = GameTime;
	g_bPushing[client] = false;

	g_bLoadingSettings[client] = false;
	g_bSettingsLoaded[client] = false;

	g_fLastDifferenceTime[client] = 0.0;

	g_flastClientUsp[client] = GameTime;

	g_ClientRenamingZone[client] = false;

	g_bNewReplay[client] = false;
	g_bNewBonus[client] = false;

	g_bFirstTimerStart[client] = true;
	g_pr_Calculating[client] = false;

	g_bTimeractivated[client] = false;
	g_specToStage[client] = false;
	g_bSpectate[client] = false;
	if (!g_bLateLoaded)
		g_bFirstTeamJoin[client] = true;
	g_bFirstSpawn[client] = true;
	g_bRecalcRankInProgess[client] = false;
	g_bPause[client] = false;
	g_bPositionRestored[client] = false;
	g_bRestorePositionMsg[client] = false;
	g_bRestorePosition[client] = false;
	g_bRespawnPosition[client] = false;
	g_bNoClip[client] = false;
	g_bOverlay[client] = false;
	g_bClientOwnReason[client] = false;
	g_AdminMenuLastPage[client] = 0;
	g_MenuLevel[client] = -1;
	g_AttackCounter[client] = 0;
	g_SpecTarget[client] = -1;
	g_pr_points[client] = 0;
	g_fCurrentRunTime[client] = -1.0;
	g_fPlayerCordsLastPosition[client] = view_as<float>( { 0.0, 0.0, 0.0 } );
	g_fLastChatMessage[client] = GetGameTime();
	g_fLastTimeNoClipUsed[client] = -1.0;
	g_fStartTime[client] = -1.0;
	g_fPlayerLastTime[client] = -1.0;
	g_fPauseTime[client] = 0.0;
	g_MapRank[client] = 99999;
	g_OldMapRank[client] = 99999;
	g_PlayerRank[client] = 99999;
	g_fProfileMenuLastQuery[client] = GameTime;
	Format(g_szPlayerPanelText[client], 512, "");
	Format(g_pr_rankname[client], 128, "");
	g_PlayerChatRank[client] = -1;
	g_bValidRun[client] = false;
	g_fMaxPercCompleted[client] = 0.0;
	Format(g_szLastSRDifference[client], 64, "");
	Format(g_szLastPBDifference[client], 64, "");

	Format(g_szPersonalRecord[client], 64, "");


	// Player Checkpoints
	// for (int x = 0; x < 3; x++)
	// {
	// 	g_fCheckpointLocation[client][x] = 0.0;
	// 	g_fCheckpointVelocity[client][x] = 0.0;
	// 	g_fCheckpointAngle[client][x] = 0.0;

	// 	g_fCheckpointLocation_undo[client][x] = 0.0;
	// 	g_fCheckpointVelocity_undo[client][x] = 0.0;
	// 	g_fCheckpointAngle_undo[client][x] = 0.0;
	// }

	for (int x = 0; x < MAXZONEGROUPS; x++)
	{
		Format(g_szPersonalRecordBonus[x][client], 64, "-");
		g_bCheckpointsFound[x][client] = false;
		g_MapRankBonus[x][client] = 9999999;
		g_Stage[x][client] = 0;
		for (int i = 0; i < CPLIMIT; i++)
		{
			g_fCheckpointTimesNew[x][client][i] = 0.0;
			g_fCheckpointTimesRecord[x][client][i] = 0.0;
		}
	}

	// /g_fLastPlayerCheckpoint[client] = GameTime;
	g_bCreatedTeleport[client] = false;
	g_bPracticeMode[client] = false;

	// client options
	g_bHide[client] = false;
	g_bShowSpecs[client] = true;
	g_bAutoBhopClient[client] = true;
	g_bHideChat[client] = false;
	g_bViewModel[client] = true;
	g_bCheckpointsEnabled[client] = true;
	g_bEnableQuakeSounds[client] = true;
	g_bTimerEnabled[client] = true;

	// style defaults
	g_iCurrentStyle[client] = 0;
	g_iInitalStyle[client] = 0;
	g_szInitalStyle[client] = "Normal";

	// show zones
	g_bShowZones[client] = false;

	// text colour
	g_bHasCustomTextColour[client] = false;

	// VIP
	g_bCheckCustomTitle[client] = false;

	// WRCP Replays
	g_bSavingWrcpReplay[client] = false;

	// Reset bonus bool
	g_bInBonus[client] = false;

	// surf_summer credits targetname
	if (StrEqual(g_szMapName, "surf_summer"))
		DispatchKeyValue(client, "targetname", "_m5_");
	
	g_iCenterSpeedEnt[client] = -1;

	g_iPlayTimeAliveSession[client] = 0;
	g_iPlayTimeSpecSession[client] = 0;

	// Show Triggers
	g_bShowTriggers[client] = false;

	// Goose Start Pos
	for (int i = 0; i < MAXZONEGROUPS; i++)
		g_bStartposUsed[client][i] = false;
	
	// Save loc
	g_iLastSaveLocIdClient[client] = 0;
	g_fLastCheckpointMade[client] = 0.0;

	// Discord
	g_bWaitingForBugMsg[client] = false;

	// surf_christmas2
	g_bUsingStageTeleport[client] = false;
}

// public void clearPlayerCheckPoints(int client)
// {
// 	for (int x = 0; x < 3; x++)
// 	{
// 		g_fCheckpointLocation[client][x] = 0.0;
// 		g_fCheckpointVelocity[client][x] = 0.0;
// 		g_fCheckpointAngle[client][x] = 0.0;

// 		g_fCheckpointLocation_undo[client][x] = 0.0;
// 		g_fCheckpointVelocity_undo[client][x] = 0.0;
// 		g_fCheckpointAngle_undo[client][x] = 0.0;
// 	}
// 	g_fLastPlayerCheckpoint[client] = GetGameTime();
// 	g_bCreatedTeleport[client] = false;
// }

// - Get Runtime -
public void GetcurrentRunTime(int client)
{
	float fGetGameTime = GetGameTime();
	g_fCurrentRunTime[client] = fGetGameTime - g_fStartTime[client] - g_fPauseTime[client];

	if (g_bWrcpTimeractivated[client])
		g_fCurrentWrcpRunTime[client] = fGetGameTime - g_fStartWrcpTime[client];
}

public float GetSpeed(int client)
{
	float fVelocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);
	float speed;

	if (g_SpeedMode[client] == 0) // XY
		speed = SquareRoot(Pow(fVelocity[0], 2.0) + Pow(fVelocity[1], 2.0));
	else if (g_SpeedMode[client] == 1) // XYZ
		speed = SquareRoot(Pow(fVelocity[0], 2.0) + Pow(fVelocity[1], 2.0) + Pow(fVelocity[2], 2.0));
	else if (g_SpeedMode[client] == 2) // Z
		speed = fVelocity[2];
	else // XY default
		speed = SquareRoot(Pow(fVelocity[0], 2.0) + Pow(fVelocity[1], 2.0));

	return speed;
}

public void SetCashState()
{
	ServerCommand("mp_startmoney 0; mp_playercashawards 0; mp_teamcashawards 0");
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
			SetEntProp(i, Prop_Send, "m_iAccount", 0);
	}
}

public void PlayRecordSound(int iRecordtype)
{
	char buffer[255];
	if (iRecordtype == 1)
	{
		for (int i = 1; i <= GetMaxClients(); i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i) && g_bEnableQuakeSounds[i] == true)
			{
				Format(buffer, sizeof(buffer), "play %s", WR_RELATIVE_SOUND_PATH);
				ClientCommand(i, buffer);
			}
		}
	}
	else if (iRecordtype == 2)
	{
		for (int i = 1; i <= GetMaxClients(); i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i) && g_bEnableQuakeSounds[i] == true)
			{
				Format(buffer, sizeof(buffer), "play %s", WR2_RELATIVE_SOUND_PATH);
				ClientCommand(i, buffer);
			}
		}
	}
	else if(iRecordtype == 3) // top10
	{
		for (int i = 1; i <= GetMaxClients(); i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i) && g_bEnableQuakeSounds[i] == true)
			{
				Format(buffer, sizeof(buffer), "play %s", TOP10_RELATIVE_SOUND_PATH);
				ClientCommand(i, buffer);
			}
		}
	}
	else if(iRecordtype == 4)//discotime
	{
		for (int i = 1; i <= GetMaxClients(); i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i) && g_bEnableQuakeSounds[i] == true)
			{
				Format(buffer, sizeof(buffer), "play %s", DISCOTIME_RELATIVE_SOUND_PATH);
				ClientCommand(i, buffer);
			}
		}
	}
}

public void PlayUnstoppableSound(int client)
{
	char buffer[255];
	Format(buffer, sizeof(buffer), "play %s", PR_RELATIVE_SOUND_PATH);
	if (!IsFakeClient(client) && g_bEnableQuakeSounds[client])
		ClientCommand(client, buffer);
	//spec stop sound
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && !IsPlayerAlive(i))
		{
			int SpecMode = GetEntProp(i, Prop_Send, "m_iObserverMode");
			if (SpecMode == 4 || SpecMode == 5)
			{
				int Target = GetEntPropEnt(i, Prop_Send, "m_hObserverTarget");
				if (Target == client && g_bEnableQuakeSounds[i])
					ClientCommand(i, buffer);
			}
		}
	}
}

public void PlayWRCPRecord(int iRecordtype)
{
	char buffer[255];
	if (iRecordtype == 1)
	{
		for (int i = 1; i <= GetMaxClients(); i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i) && g_bEnableQuakeSounds[i] == true)
			{
				Format(buffer, sizeof(buffer), "play %s", WRCP_RELATIVE_SOUND_PATH);
				ClientCommand(i, buffer);
			}
		}
	}
}



public void InitPrecache()
{
	// db_precacheCustomSounds();

	AddFileToDownloadsTable(UNSTOPPABLE_SOUND_PATH);
	FakePrecacheSound(UNSTOPPABLE_RELATIVE_SOUND_PATH);
	AddFileToDownloadsTable(PRO_FULL_SOUND_PATH);
	FakePrecacheSound(PRO_RELATIVE_SOUND_PATH);
	AddFileToDownloadsTable(PRO_FULL_SOUND_PATH);
	FakePrecacheSound(PRO_RELATIVE_SOUND_PATH);
	AddFileToDownloadsTable(CP_FULL_SOUND_PATH);
	FakePrecacheSound(CP_RELATIVE_SOUND_PATH);
	//fluffys
	AddFileToDownloadsTable(WRCP_FULL_SOUND_PATH);
	FakePrecacheSound(WRCP_RELATIVE_SOUND_PATH);
	AddFileToDownloadsTable(WR_FULL_SOUND_PATH);
	FakePrecacheSound(WR_RELATIVE_SOUND_PATH);
	AddFileToDownloadsTable(WR2_FULL_SOUND_PATH);
	FakePrecacheSound(WR2_RELATIVE_SOUND_PATH);
	AddFileToDownloadsTable(PR_FULL_SOUND_PATH);
	FakePrecacheSound(PR_RELATIVE_SOUND_PATH);
	AddFileToDownloadsTable(TOP10_FULL_SOUND_PATH);
	FakePrecacheSound(TOP10_RELATIVE_SOUND_PATH);
	AddFileToDownloadsTable(DISCOTIME_FULL_SOUND_PATH);
	FakePrecacheSound(DISCOTIME_RELATIVE_SOUND_PATH);

	char szBuffer[256];
	// Replay Player Model
	GetConVarString(g_hReplayBotPlayerModel, szBuffer, 256);
	AddFileToDownloadsTable(szBuffer);
	PrecacheModel(szBuffer, true);
	// Replay Arm Model
	GetConVarString(g_hReplayBotArmModel, szBuffer, 256);
	AddFileToDownloadsTable(szBuffer);
	PrecacheModel(szBuffer, true);
	// Player Arm Model
	// GetConVarString(g_hArmModel, szBuffer, 256);
	// AddFileToDownloadsTable(szBuffer);
	// PrecacheModel(szBuffer, true);
	// Player Model
	GetConVarString(g_hPlayerModel, szBuffer, 256);
	AddFileToDownloadsTable(szBuffer);
	PrecacheModel(szBuffer, true);

	g_BeamSprite = PrecacheModel("materials/sprites/laserbeam.vmt", true);
	g_HaloSprite = PrecacheModel("materials/sprites/halo.vmt", true);
	PrecacheModel(ZONE_MODEL);
}


// thx to V952 https://forums.alliedmods.net/showthread.php?t=212886
stock int TraceClientViewEntity(int client)
{
	float m_vecOrigin[3];
	float m_angRotation[3];
	GetClientEyePosition(client, m_vecOrigin);
	GetClientEyeAngles(client, m_angRotation);
	Handle tr = TR_TraceRayFilterEx(m_vecOrigin, m_angRotation, MASK_VISIBLE, RayType_Infinite, TRDontHitSelf, client);
	int pEntity = -1;
	if (TR_DidHit(tr))
	{
		pEntity = TR_GetEntityIndex(tr);
		CloseHandle(tr);
		return pEntity;
	}
	CloseHandle(tr);
	return -1;
}

// thx to V952 https://forums.alliedmods.net/showthread.php?t=212886
public bool TRDontHitSelf(int entity, int mask, any data)
{
	if (entity == data)
		return false;
	return true;
}

public void PrintMapRecords(int client, int type)
{
	if(type == 0)
	{
		if (g_fRecordMapTime != 9999999.0)
			{
				PrintToChat(client, "  %cSurftimer %c| %c%s %cholds the record with time: %c%s %con %c%s%c.", LIMEGREEN, WHITE, DARKBLUE, g_szRecordPlayer, WHITE, LIMEGREEN, g_szRecordMapTime, WHITE, BLUE, g_szMapName, WHITE);
			}
	}
	else if(type == 99)
	{
	for (int i = 1; i <= g_mapZoneGroupCount; i++)
		{
			if (g_fBonusFastest[i] != 9999999.0) // BONUS
			{
				PrintToChat(client, " %cSurftimer %c| %c%s %cholds the %c%s %crecord with time: %c%s %con %c%s%c.", LIMEGREEN, WHITE, ORANGE, g_szBonusFastest[i], WHITE, ORANGE, g_szZoneGroupName[i], WHITE, LIMEGREEN, g_szBonusFastestTime[i], WHITE, BLUE, g_szMapName, WHITE);
			}
		}
	}
	else if(type == 1) // sw
	{
		if(g_fRecordStyleMapTime[type] != 9999999.0)
		{
			PrintToChat(client, " %cSurftimer %c| %c%s %cholds the %csideways %crecord with time: %c%s %con %c%s%c.", LIMEGREEN, WHITE, DARKBLUE, g_szRecordStylePlayer[type], WHITE, LIGHTRED, WHITE, LIMEGREEN, g_szRecordStyleMapTime[type], WHITE, BLUE, g_szMapName, WHITE);
		}
	}
	else if(type == 2) // hsw
	{
		if(g_fRecordStyleMapTime[type] != 9999999.0)
		{
			PrintToChat(client, " %cSurftimer %c| %c%s %cholds the %chalf-sideways %crecord with time: %c%s %con %c%s%c.", LIMEGREEN, WHITE, DARKBLUE, g_szRecordStylePlayer[type], WHITE, LIGHTRED, WHITE, LIMEGREEN, g_szRecordStyleMapTime[type], WHITE, BLUE, g_szMapName, WHITE);
		}
	}
	else if(type == 3) // bw
	{
		if(g_fRecordStyleMapTime[type] != 9999999.0)
		{
			PrintToChat(client, " %cSurftimer %c| %c%s %cholds the %cbackwards %crecord with time: %c%s %con %c%s%c.", LIMEGREEN, WHITE, DARKBLUE, g_szRecordStylePlayer[type], WHITE, LIGHTRED, WHITE, LIMEGREEN, g_szRecordStyleMapTime[type], WHITE, BLUE, g_szMapName, WHITE);
		}
	}
	else if(type == 4) // low-gravity
	{
		if(g_fRecordStyleMapTime[type] != 9999999.0)
		{
			PrintToChat(client, " %cSurftimer %c| %c%s %cholds the %clow-gravity %crecord with time: %c%s %con %c%s%c.", LIMEGREEN, WHITE, DARKBLUE, g_szRecordStylePlayer[type], WHITE, LIGHTRED, WHITE, LIMEGREEN, g_szRecordStyleMapTime[type], WHITE, BLUE, g_szMapName, WHITE);
		}
	}
	else if(type == 5) // slow motion
	{
		if(g_fRecordStyleMapTime[type] != 9999999.0)
		{
			PrintToChat(client, " %cSurftimer %c| %c%s %cholds the %cslow motion %crecord with time: %c%s %con %c%s%c.", LIMEGREEN, WHITE, DARKBLUE, g_szRecordStylePlayer[type], WHITE, LIGHTRED, WHITE, LIMEGREEN, g_szRecordStyleMapTime[type], WHITE, BLUE, g_szMapName, WHITE);
		}
	}
	else if(type == 6) // fast forward
	{
		if(g_fRecordStyleMapTime[type] != 9999999.0)
		{
			PrintToChat(client, " %cSurftimer %c| %c%s %cholds the %cfast forward %crecord with time: %c%s %con %c%s%c.", LIMEGREEN, WHITE, DARKBLUE, g_szRecordStylePlayer[type], WHITE, LIGHTRED, WHITE, LIMEGREEN, g_szRecordStyleMapTime[type], WHITE, BLUE, g_szMapName, WHITE);
		}
	}
	else if(type == 991) //bonus sideways
	{
		type = 1;
		for (int i = 1; i <= g_mapZoneGroupCount; i++)
		{
			if (g_fStyleBonusFastest[type][i] != 9999999.0) // BONUS
			{
				PrintToChat(client, " %cSurftimer %c| %c%s %cholds the %csideways %c%s %crecord with time: %c%s %con %c%s%c.", LIMEGREEN, WHITE, ORANGE, g_szStyleBonusFastest[type][i], WHITE, ORANGE, g_szZoneGroupName[i], WHITE, LIMEGREEN, g_szStyleBonusFastestTime[type][i], WHITE, BLUE, g_szMapName, WHITE);
			}
		}
	}
	else if(type == 992) //bonus half-sideways
	{
		type = 2;
		for (int i = 1; i <= g_mapZoneGroupCount; i++)
		{
			if (g_fStyleBonusFastest[type][i] != 9999999.0) // BONUS
			{
				PrintToChat(client, " %cSurftimer %c| %c%s %cholds the %chalf-sideways %c%s %crecord with time: %c%s %con %c%s%c.", LIMEGREEN, WHITE, ORANGE, g_szStyleBonusFastest[type][i], WHITE,LIGHTRED,  ORANGE, g_szZoneGroupName[i], WHITE, LIMEGREEN, g_szStyleBonusFastestTime[type][i], WHITE, BLUE, g_szMapName, WHITE);
			}
		}
	}
	else if(type == 993) //bonus backwards
	{
		type = 3;
		for (int i = 1; i <= g_mapZoneGroupCount; i++)
		{
			if (g_fStyleBonusFastest[type][i] != 9999999.0) // BONUS
			{
				PrintToChat(client, " %cSurftimer %c| %c%s %cholds the %cbackwards %c%s %crecord with time: %c%s %con %c%s%c.", LIMEGREEN, WHITE, ORANGE, g_szStyleBonusFastest[type][i], WHITE, LIGHTRED, ORANGE, g_szZoneGroupName[i], WHITE, LIMEGREEN, g_szStyleBonusFastestTime[type][i], WHITE, BLUE, g_szMapName, WHITE);
			}
		}
	}
	else if(type == 994) //bonus low-gravity
	{
		type = 4;
		for (int i = 1; i <= g_mapZoneGroupCount; i++)
		{
			if (g_fStyleBonusFastest[type][i] != 9999999.0) // BONUS
			{
				PrintToChat(client, " %cSurftimer %c| %c%s %cholds the %clow-gravity %c%s %crecord with time: %c%s %con %c%s%c.", LIMEGREEN, WHITE, ORANGE, g_szStyleBonusFastest[type][i], WHITE, LIGHTRED, ORANGE, g_szZoneGroupName[i], WHITE, LIMEGREEN, g_szStyleBonusFastestTime[type][i], WHITE, BLUE, g_szMapName, WHITE);
			}
		}
	}
	else if(type == 995) //bonus slow motion
	{
		type = 5;
		for (int i = 1; i <= g_mapZoneGroupCount; i++)
		{
			if (g_fStyleBonusFastest[type][i] != 9999999.0) // BONUS
			{
				PrintToChat(client, " %cSurftimer %c| %c%s %cholds the %cslow motion %c%s %crecord with time: %c%s %con %c%s%c.", LIMEGREEN, WHITE, ORANGE, g_szStyleBonusFastest[type][i], WHITE, LIGHTRED, ORANGE, g_szZoneGroupName[i], WHITE, LIMEGREEN, g_szStyleBonusFastestTime[type][i], WHITE, BLUE, g_szMapName, WHITE);
			}
		}
	}
	else if(type == 996) //bonus fast forward
	{
		type = 6;
		for (int i = 1; i <= g_mapZoneGroupCount; i++)
		{
			if (g_fStyleBonusFastest[type][i] != 9999999.0) // BONUS
			{
				PrintToChat(client, " %cSurftimer %c| %c%s %cholds the %cfast forward %c%s %crecord with time: %c%s %con %c%s%c.", LIMEGREEN, WHITE, ORANGE, g_szStyleBonusFastest[type][i], WHITE, LIGHTRED, ORANGE, g_szZoneGroupName[i], WHITE, LIMEGREEN, g_szStyleBonusFastestTime[type][i], WHITE, BLUE, g_szMapName, WHITE);
			}
		}
	}
}

stock void MapFinishedMsgs(int client, int rankThisRun = 0)
{
	if (IsValidClient(client))
	{
		char szName[MAX_NAME_LENGTH];
		GetClientName(client, szName, MAX_NAME_LENGTH);
		int count = g_MapTimesCount;

		if (rankThisRun == 0)
			rankThisRun = g_MapRank[client];

		int rank = g_MapRank[client];
		char szGroup[128];
		if(rank >= 11 && rank <= g_G1Top)
			Format(szGroup, 128, "[%cGroup 1%c]", DARKRED, WHITE);
		else if(rank >= g_G2Bot && rank <= g_G2Top)
			Format(szGroup, 128, "[%cGroup 2%c]", GREEN, WHITE);
		else if(rank >= g_G3Bot && rank <= g_G3Top)
			Format(szGroup, 128, "[%cGroup 3%c]", BLUE, WHITE);
		else if(rank >= g_G4Bot && rank <= g_G4Top)
			Format(szGroup, 128, "[%cGroup 4%c]", YELLOW, WHITE);
		else if(rank >= g_G5Bot && rank <= g_G5Top)
			Format(szGroup, 128, "[%cGroup 5%c]", GRAY, WHITE);
		else
			Format(szGroup, 128, "");

		// Check that ck_chat_record_type matches and ck_min_rank_announce matches
		if ((GetConVarInt(g_hAnnounceRecord) == 0 ||
			(GetConVarInt(g_hAnnounceRecord) == 1 && g_bMapPBRecord[client] || g_bMapSRVRecord[client] || g_bMapFirstRecord[client]) ||
			(GetConVarInt(g_hAnnounceRecord) == 2 && g_bMapSRVRecord[client])) &&
			(rankThisRun <= GetConVarInt(g_hAnnounceRank) || GetConVarInt(g_hAnnounceRank) == 0))
		{
			for (int i = 1; i <= GetMaxClients(); i++)
			{
				if (IsValidClient(i) && !IsFakeClient(i))
				{
					if (g_bMapFirstRecord[client]) // 1st time finishing
					{
						PrintToChat(i, "%t", "MapFinished1", LIMEGREEN, WHITE, LIMEGREEN, szName, GRAY, DARKBLUE, GRAY, LIMEGREEN, g_szFinalTime[client], GRAY, WHITE, LIMEGREEN, g_MapRank[client], WHITE, count, szGroup, LIMEGREEN, g_szRecordMapTime, WHITE);
						PrintToConsole(i, "%s finished the map with a time of (%s). [rank #%i/%i | record %s]", szName, g_szFinalTime[client], g_MapRank[client], count, g_szRecordMapTime);
					}
					else
						if (g_bMapPBRecord[client]) // Own record
						{
							PlayUnstoppableSound(client);
							PrintToChat(i, "%t", "MapFinished3", LIMEGREEN, WHITE, LIMEGREEN, szName, GRAY, DARKBLUE, GRAY, LIMEGREEN, g_szFinalTime[client], GRAY, GREEN, g_szTimeDifference[client], GRAY, WHITE, LIMEGREEN, g_MapRank[client], WHITE, count, szGroup, LIMEGREEN, g_szRecordMapTime, WHITE);
							PrintToConsole(i, "%s finished the map with a time of (%s). Improving their best time by (%s).  [rank #%i/%i | record %s]", szName, g_szFinalTime[client], g_szTimeDifference[client], g_MapRank[client], count, g_szRecordMapTime);
						}
						else
							if (!g_bMapSRVRecord[client] && !g_bMapFirstRecord[client] && !g_bMapPBRecord[client])
							{
								PrintToChat(i, "%t", "MapFinished5", LIMEGREEN, WHITE, LIMEGREEN, szName, GRAY, DARKBLUE, GRAY, LIMEGREEN, g_szFinalTime[client], GRAY, RED, g_szTimeDifference[client], GRAY, WHITE, LIMEGREEN, g_MapRank[client], WHITE, count, szGroup, LIMEGREEN, g_szRecordMapTime, WHITE);
								PrintToConsole(i, "%s finished the map with a time of (%s). Missing their best time by (%s).  [rank #%i/%i | record %s]", szName, g_szFinalTime[client], g_szTimeDifference[client], g_MapRank[client], count, g_szRecordMapTime);
							}

					if (g_bMapSRVRecord[client])
					{
						//int r = GetRandomInt(1, 2);
						PlayRecordSound(2);
						PrintToChat(i, "%t", "NewMapRecord", LIMEGREEN, WHITE, LIMEGREEN, szName, GRAY, DARKBLUE);
						PrintToConsole(i, "surftimer | %s scored a new MAP RECORD", szName);
					}
				}
			}
		} 
		else
		{ // Print to own chat only
			if (IsValidClient(client) && !IsFakeClient(client))
			{
				if (g_bMapFirstRecord[client])
				{
					PrintToChat(client, "%t", "MapFinished1", LIMEGREEN, WHITE, LIMEGREEN, szName, GRAY, DARKBLUE, GRAY, LIMEGREEN, g_szFinalTime[client], GRAY, WHITE, LIMEGREEN, g_MapRank[client], WHITE, count, szGroup, LIMEGREEN, g_szRecordMapTime, WHITE);
					PrintToConsole(client, "%s finished the map with a time of (%s). [rank #%i/%i | record %s]", szName, g_szFinalTime[client], g_MapRank[client], count, g_szRecordMapTime);
				}
				else
				{
					if (g_bMapPBRecord[client])
					{
						PlayUnstoppableSound(client);
						PrintToChat(client, "%t", "MapFinished3", LIMEGREEN, WHITE, LIMEGREEN, szName, GRAY, DARKBLUE, GRAY, LIMEGREEN, g_szFinalTime[client], GRAY, GREEN, g_szTimeDifference[client], GRAY, WHITE, LIMEGREEN, g_MapRank[client], WHITE, count, szGroup, LIMEGREEN, g_szRecordMapTime, WHITE);
						PrintToConsole(client, "%s finished the map with a time of (%s). Improving their best time by (%s).  [rank #%i/%i | record %s]", szName, g_szFinalTime[client], g_szTimeDifference[client], g_MapRank[client], count, g_szRecordMapTime);
					}
					else
					{
						if (!g_bMapSRVRecord[client] && !g_bMapFirstRecord[client] && !g_bMapPBRecord[client])
						{
							PrintToChat(client, "%t", "MapFinished5", LIMEGREEN, WHITE, LIMEGREEN, szName, GRAY, DARKBLUE, GRAY, LIMEGREEN, g_szFinalTime[client], GRAY, RED, g_szTimeDifference[client], GRAY, WHITE, LIMEGREEN, g_MapRank[client], WHITE, count, szGroup, LIMEGREEN, g_szRecordMapTime, WHITE);
							PrintToConsole(client, "%s finished the map with a time of (%s). Missing their best time by (%s).  [rank #%i/%i | record %s]", szName, g_szFinalTime[client], g_szTimeDifference[client], g_MapRank[client], count, g_szRecordMapTime);
						}
					}
				}
			}
		}

		// Send Announcements
		if (g_bMapSRVRecord[client])
		{
			if (GetConVarBool(g_hRecordAnnounce))
				db_insertAnnouncement(szName, g_szMapName, g_szFinalTime[client]);
			char buffer[1024];
			GetConVarString(g_hRecordAnnounceDiscord, buffer, 1024);
			if (!StrEqual(buffer, ""))
				sendDiscordAnnouncement(szName, g_szMapName, g_szFinalTime[client]);
		}

		if(g_bTop10Time[client])
			PlayRecordSound(3);

		if (g_MapRank[client] == 99999 && IsValidClient(client))
			PrintToChat(client, " %cSurftimer %c| %cFailed to save your data correctly! Please contact an admin.", LIMEGREEN, WHITE, DARKRED, RED, DARKRED);

		CreateTimer(0.0, UpdatePlayerProfile, client, TIMER_FLAG_NO_MAPCHANGE);

		if (g_bMapFirstRecord[client] || g_bMapPBRecord[client] || g_bMapSRVRecord[client])
			CheckMapRanks(client);

		/* Start function call */
		Call_StartForward(g_MapFinishForward);

		/* Push parameters one at a time */
		Call_PushCell(client);
		Call_PushFloat(g_fFinalTime[client]);
		Call_PushString(g_szFinalTime[client]);
		Call_PushCell(g_MapRank[client]);
		Call_PushCell(count);

		/* Finish the call, get the result */
		Call_Finish();

	}
	//recalc avg
	db_CalcAvgRunTime();

	return;
}

stock void PrintChatBonus (int client, int zGroup, int rank = 0)
{
	if (!IsValidClient(client))
		return;

	float RecordDiff;
	char szRecordDiff[54], szName[MAX_NAME_LENGTH];

	if (rank == 0)
		rank = g_MapRankBonus[zGroup][client];

	GetClientName(client, szName, MAX_NAME_LENGTH);
	if ((GetConVarInt(g_hAnnounceRecord) == 0 ||
		(GetConVarInt(g_hAnnounceRecord) == 1 && g_bBonusSRVRecord[client] || g_bBonusPBRecord[client] || g_bBonusFirstRecord[client]) ||
		(GetConVarInt(g_hAnnounceRecord) == 2 && g_bBonusSRVRecord[client])) &&
		(rank <= GetConVarInt(g_hAnnounceRank) || GetConVarInt(g_hAnnounceRank) == 0))
	{
		if (g_bBonusSRVRecord[client])
		{
			//int i = GetRandomInt(1, 2);
			PlayRecordSound(2);

			RecordDiff = g_fOldBonusRecordTime[zGroup] - g_fFinalTime[client];
			FormatTimeFloat(client, RecordDiff, 3, szRecordDiff, 54);
			Format(szRecordDiff, 54, "-%s", szRecordDiff);
		}
		if (g_bBonusFirstRecord[client] && g_bBonusSRVRecord[client])
		{
			PrintToChatAll("%t", "BonusFinished2", LIMEGREEN, WHITE, LIMEGREEN, szName, ORANGE, g_szZoneGroupName[zGroup]);
			if (g_tmpBonusCount[zGroup] == 0)
				PrintToChatAll("%t", "BonusFinished3", LIMEGREEN, WHITE, LIMEGREEN, szName, GRAY, ORANGE, g_szZoneGroupName[zGroup], GRAY, LIMEGREEN, g_szFinalTime[client], GRAY, LIMEGREEN, WHITE, LIMEGREEN, g_szFinalTime[client], WHITE);
			else
				PrintToChatAll("%t", "BonusFinished4", LIMEGREEN, WHITE, LIMEGREEN, szName, GRAY, ORANGE, g_szZoneGroupName[zGroup], GRAY, LIMEGREEN, g_szFinalTime[client], GRAY, LIMEGREEN, szRecordDiff, GRAY, LIMEGREEN, g_MapRankBonus[zGroup][client], GRAY, g_iBonusCount[zGroup], LIMEGREEN, g_szFinalTime[client], WHITE);
		}
		if (g_bBonusPBRecord[client] && g_bBonusSRVRecord[client])
		{
			PrintToChatAll("%t", "BonusFinished2", LIMEGREEN, WHITE, LIMEGREEN, szName, ORANGE, g_szZoneGroupName[zGroup]);
			PrintToChatAll("%t", "BonusFinished5", LIMEGREEN, WHITE, LIMEGREEN, szName, GRAY, ORANGE, g_szZoneGroupName[zGroup], GRAY, LIMEGREEN, g_szFinalTime[client], GRAY, LIMEGREEN, szRecordDiff, GRAY, LIMEGREEN, g_MapRankBonus[zGroup][client], GRAY, g_iBonusCount[zGroup], LIMEGREEN, g_szFinalTime[client], WHITE);
		}
		if (g_bBonusPBRecord[client] && !g_bBonusSRVRecord[client])
		{
			PlayUnstoppableSound(client);
			PrintToChatAll("%t", "BonusFinished6", LIMEGREEN, WHITE, LIMEGREEN, szName, GRAY, ORANGE, g_szZoneGroupName[zGroup], GRAY, LIMEGREEN, g_szFinalTime[client], GRAY, LIMEGREEN, g_szBonusTimeDifference[client], GRAY, LIMEGREEN, g_MapRankBonus[zGroup][client], GRAY, g_iBonusCount[zGroup], LIMEGREEN, g_szBonusFastestTime[zGroup], WHITE);
		}
		if (g_bBonusFirstRecord[client] && !g_bBonusSRVRecord[client])
		{
			PrintToChatAll("%t", "BonusFinished7", LIMEGREEN, WHITE, LIMEGREEN, szName, GRAY, ORANGE, g_szZoneGroupName[zGroup], GRAY, LIMEGREEN, g_szFinalTime[client], GRAY, LIMEGREEN, g_MapRankBonus[zGroup][client], GRAY, g_iBonusCount[zGroup], LIMEGREEN, g_szBonusFastestTime[zGroup], WHITE);
		}
		if (!g_bBonusSRVRecord[client] && !g_bBonusFirstRecord[client] && !g_bBonusPBRecord[client])
		{
 			PrintToChatAll("%t", "BonusFinished1", LIMEGREEN, WHITE, LIMEGREEN, szName, GRAY, ORANGE, g_szZoneGroupName[zGroup], GRAY, RED, g_szFinalTime[client], GRAY, RED, g_szBonusTimeDifference[client], GRAY, LIMEGREEN, g_MapRankBonus[zGroup][client], GRAY, g_iBonusCount[zGroup], LIMEGREEN, g_szBonusFastestTime[zGroup], GRAY);
		}
	}
	else
	{
		if (g_bBonusSRVRecord[client])
		{
			//int i = GetRandomInt(1, 2);
			PlayRecordSound(2);
			RecordDiff = g_fOldBonusRecordTime[zGroup] - g_fFinalTime[client];
			FormatTimeFloat(client, RecordDiff, 3, szRecordDiff, 54);
			Format(szRecordDiff, 54, "-%s", szRecordDiff);
		}
		if (g_bBonusFirstRecord[client] && g_bBonusSRVRecord[client])
		{
			PrintToChat(client, "%t", "BonusFinished2", LIMEGREEN, WHITE, LIMEGREEN, szName, ORANGE, g_szZoneGroupName[zGroup]);
			if (g_tmpBonusCount[zGroup] == 0)
				PrintToChat(client, "%t", "BonusFinished3", LIMEGREEN, WHITE, LIMEGREEN, szName, GRAY, ORANGE, g_szZoneGroupName[zGroup], GRAY, LIMEGREEN, g_szFinalTime[client], GRAY, LIMEGREEN, WHITE, LIMEGREEN, g_szFinalTime[client], WHITE);
			else
				PrintToChat(client, "%t", "BonusFinished4", LIMEGREEN, WHITE, LIMEGREEN, szName, GRAY, ORANGE, g_szZoneGroupName[zGroup], GRAY, LIMEGREEN, g_szFinalTime[client], GRAY, LIMEGREEN, szRecordDiff, GRAY, LIMEGREEN, g_MapRankBonus[zGroup][client], GRAY, g_iBonusCount[zGroup], LIMEGREEN, g_szFinalTime[client], WHITE);
		}
		if (g_bBonusPBRecord[client] && g_bBonusSRVRecord[client])
		{
			PrintToChat(client, "%t", "BonusFinished2", LIMEGREEN, WHITE, LIMEGREEN, szName, ORANGE, g_szZoneGroupName[zGroup]);
			PrintToChat(client, "%t", "BonusFinished5", LIMEGREEN, WHITE, LIMEGREEN, szName, GRAY, ORANGE, g_szZoneGroupName[zGroup], GRAY, LIMEGREEN, g_szFinalTime[client], GRAY, LIMEGREEN, szRecordDiff, GRAY, LIMEGREEN, g_MapRankBonus[zGroup][client], GRAY, g_iBonusCount[zGroup], LIMEGREEN, g_szFinalTime[client], WHITE);
		}
		if (g_bBonusPBRecord[client] && !g_bBonusSRVRecord[client])
		{
			PlayUnstoppableSound(client);
			PrintToChat(client, "%t", "BonusFinished6", LIMEGREEN, WHITE, LIMEGREEN, szName, GRAY, ORANGE, g_szZoneGroupName[zGroup], GRAY, LIMEGREEN, g_szFinalTime[client], GRAY, LIMEGREEN, g_szBonusTimeDifference[client], GRAY, LIMEGREEN, g_MapRankBonus[zGroup][client], GRAY, g_iBonusCount[zGroup], LIMEGREEN, g_szBonusFastestTime[zGroup], WHITE);
		}
		if (g_bBonusFirstRecord[client] && !g_bBonusSRVRecord[client])
		{
			PrintToChat(client, "%t", "BonusFinished7", LIMEGREEN, WHITE, LIMEGREEN, szName, GRAY, ORANGE, g_szZoneGroupName[zGroup], GRAY, LIMEGREEN, g_szFinalTime[client], GRAY, LIMEGREEN, g_MapRankBonus[zGroup][client], GRAY, g_iBonusCount[zGroup], LIMEGREEN, g_szBonusFastestTime[zGroup], WHITE);
		}
		if (!g_bBonusSRVRecord[client] && !g_bBonusFirstRecord[client] && !g_bBonusPBRecord[client])
		{
			if (IsValidClient(client))
	 			PrintToChat(client, "%t", "BonusFinished1", LIMEGREEN, WHITE, LIMEGREEN, szName, GRAY, ORANGE, g_szZoneGroupName[zGroup], GRAY, RED, g_szFinalTime[client], GRAY, RED, g_szBonusTimeDifference[client], GRAY, LIMEGREEN, g_MapRankBonus[zGroup][client], GRAY, g_iBonusCount[zGroup], LIMEGREEN, g_szBonusFastestTime[zGroup], GRAY);
		}

	}

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

	CheckBonusRanks(client, zGroup);
	db_CalcAvgRunTimeBonus();

	if (rank == 9999999 && IsValidClient(client))
		PrintToChat(client, " %cSurftimer %c| %cFailed to save your data correctly! Please contact an admin.", LIMEGREEN, WHITE, DARKRED, RED, DARKRED);

	return;
}

public void CheckMapRanks(int client)
{
	// if client has risen in rank,
	if (g_OldMapRank[client] > g_MapRank[client])
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i) && i != client)
			{  //if clients rank used to be bigger than i's, 2nd: clients new rank is at least as big as i's
				if (g_OldMapRank[client] > g_MapRank[i] && g_MapRank[client] <= g_MapRank[i])
					g_MapRank[i]++;
			}
		}
	}
}

public void CheckBonusRanks(int client, int zGroup)
{
	// if client has risen in rank,
	if (g_OldMapRankBonus[zGroup][client] > g_MapRankBonus[zGroup][client])
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i) && i != client)
			{  //if clients rank used to be bigger than i's, 2nd: clients new rank is at least as big as i's
				if (g_OldMapRankBonus[zGroup][client] > g_MapRankBonus[zGroup][i] && g_MapRankBonus[zGroup][client] <= g_MapRankBonus[zGroup][i])
					g_MapRankBonus[zGroup][i]++;
			}
		}
	}
}

public void ReplaceChar(char[] sSplitChar, char[] sReplace, char sString[64])
{
	StrCat(sString, sizeof(sString), " ");
	char sBuffer[16][256];
	ExplodeString(sString, sSplitChar, sBuffer, sizeof(sBuffer), sizeof(sBuffer[]));
	strcopy(sString, sizeof(sString), "");
	for (int i = 0; i < sizeof(sBuffer); i++)
	{
		if (strcmp(sBuffer[i], "") == 0)
			continue;
		if (i != 0)
		{
			char sTmpStr[256];
			Format(sTmpStr, sizeof(sTmpStr), "%s%s", sReplace, sBuffer[i]);
			StrCat(sString, sizeof(sString), sTmpStr);
		}
		else
		{
			StrCat(sString, sizeof(sString), sBuffer[i]);
		}
	}
}

public void FormatTimeFloat(int client, float time, int type, char[] string, int length)
{
	char szMilli[16];
	char szSeconds[16];
	char szMinutes[16];
	char szHours[16];
	char szMilli2[16];
	char szSeconds2[16];
	char szMinutes2[16];
	int imilli;
	int imilli2;
	int iseconds;
	int iminutes;
	int ihours;
	if (type != 6)
		time = FloatAbs(time);
	imilli = RoundToZero(time * 100);
	imilli2 = RoundToZero(time * 10);
	imilli = imilli % 100;
	imilli2 = imilli2 % 10;
	iseconds = RoundToZero(time);
	iseconds = iseconds % 60;
	iminutes = RoundToZero(time / 60);
	iminutes = iminutes % 60;
	ihours = RoundToZero((time / 60) / 60);

	if (imilli < 10)
		Format(szMilli, 16, "0%dms", imilli);
	else
		Format(szMilli, 16, "%dms", imilli);
	if (iseconds < 10)
		Format(szSeconds, 16, "0%ds", iseconds);
	else
		Format(szSeconds, 16, "%ds", iseconds);
	if (iminutes < 10)
		Format(szMinutes, 16, "0%dm", iminutes);
	else
		Format(szMinutes, 16, "%dm", iminutes);


	Format(szMilli2, 16, "%d", imilli2);
	if (iseconds < 10)
		Format(szSeconds2, 16, "0%d", iseconds);
	else
		Format(szSeconds2, 16, "%d", iseconds);
	if (iminutes < 10)
		Format(szMinutes2, 16, "0%d", iminutes);
	else
		Format(szMinutes2, 16, "%d", iminutes);
	//Time: 00m 00s 00ms
	if (type == 0)
	{
		Format(szHours, 16, "%dm", iminutes);
		if (ihours > 0)
		{
			Format(szHours, 16, "%d", ihours);
			Format(string, length, "%s:%s:%s.%s", szHours, szMinutes2, szSeconds2, szMilli2);
		}
		else
		{
			Format(string, length, "%s:%s.%s", szMinutes2, szSeconds2, szMilli2);
		}
	}
	//00m 00s 00ms
	if (type == 1)
	{
		Format(szHours, 16, "%dm", iminutes);
		if (ihours > 0)
		{
			Format(szHours, 16, "%dh", ihours);
			Format(string, length, "%s %s %s %s", szHours, szMinutes, szSeconds, szMilli);
		}
		else
			Format(string, length, "%s %s %s", szMinutes, szSeconds, szMilli);
	}
	else
		//00h 00m 00s 00ms
	if (type == 2)
	{
		imilli = RoundToZero(time * 1000);
		imilli = imilli % 1000;
		if (imilli < 10)
			Format(szMilli, 16, "00%dms", imilli);
		else
			if (imilli < 100)
				Format(szMilli, 16, "0%dms", imilli);
			else
				Format(szMilli, 16, "%dms", imilli);
		Format(szHours, 16, "%dh", ihours);
		Format(string, 32, "%s %s %s %s", szHours, szMinutes, szSeconds, szMilli);
	}
	else
		//00:00:00
	if (type == 3)
	{
		if (imilli < 10)
			Format(szMilli, 16, "0%d", imilli);
		else
			Format(szMilli, 16, "%d", imilli);
		if (iseconds < 10)
			Format(szSeconds, 16, "0%d", iseconds);
		else
			Format(szSeconds, 16, "%d", iseconds);
		if (iminutes < 10)
			Format(szMinutes, 16, "0%d", iminutes);
		else
			Format(szMinutes, 16, "%d", iminutes);
		if (ihours > 0)
		{
			Format(szHours, 16, "%d", ihours);
			Format(string, length, "%s:%s:%s:%s", szHours, szMinutes, szSeconds, szMilli);
		}
		else
			Format(string, length, "%s:%s:%s", szMinutes, szSeconds, szMilli);
	}
	//Time: 00:00:00
	if (type == 4)
	{
		if (imilli < 10)
			Format(szMilli, 16, "0%d", imilli);
		else
			Format(szMilli, 16, "%d", imilli);
		if (iseconds < 10)
			Format(szSeconds, 16, "0%d", iseconds);
		else
			Format(szSeconds, 16, "%d", iseconds);
		if (iminutes < 10)
			Format(szMinutes, 16, "0%d", iminutes);
		else
			Format(szMinutes, 16, "%d", iminutes);
		if (ihours > 0)
		{
			Format(szHours, 16, "%d", ihours);
			Format(string, length, "Time: %s:%s:%s", szHours, szMinutes, szSeconds);
		}
		else
			Format(string, length, "Time: %s:%s", szMinutes, szSeconds);
	}
	// goes to  00:00
	if (type == 5)
	{
		if (imilli < 10)
			Format(szMilli, 16, "0%d", imilli);
		else
			Format(szMilli, 16, "%d", imilli);
		if (iseconds < 10)
			Format(szSeconds, 16, "0%d", iseconds);
		else
			Format(szSeconds, 16, "%d", iseconds);
		if (iminutes < 10)
			Format(szMinutes, 16, "0%d", iminutes);
		else
			Format(szMinutes, 16, "%d", iminutes);
		if (ihours > 0)
		{

			Format(szHours, 16, "%d", ihours);
			Format(string, length, "%s:%s:%s:%s", szHours, szMinutes, szSeconds, szMilli);
		}
		else
			if (iminutes > 0)
				Format(string, length, "%s:%s:%s", szMinutes, szSeconds, szMilli);
			else
				Format(string, length, "%s:%ss", szSeconds, szMilli);
	}
	// +-00:00:00
	if (type == 6)
	{
		if (imilli < 10)
			Format(szMilli, 16, "0%d", imilli);
		else
			Format(szMilli, 16, "%d", imilli);
		if (iseconds < 10)
			Format(szSeconds, 16, "0%d", iseconds);
		else
			Format(szSeconds, 16, "%d", iseconds);
		if (iminutes < 10)
			Format(szMinutes, 16, "0%d", iminutes);
		else
			Format(szMinutes, 16, "%d", iminutes);
		if (ihours > 0)
		{
			Format(szHours, 16, "%d", ihours);
			Format(string, length, "%s:%s:%s:%s", szHours, szMinutes, szSeconds, szMilli);
		}
		else
			Format(string, length, "%s:%s:%s", szMinutes, szSeconds, szMilli);
		
		ReplaceString(string, length, "-", "");

		if (time > 0.0)
			Format(string, length, "+%s", string);
		else
			Format(string, length, "-%s", string);
	}
}

public void SetSkillGroups()
{
	//Map Points
	int mapcount;
	if (g_pr_MapCount < 1)
		mapcount = 1;
	else
		mapcount = g_pr_MapCount;

	float MaxPoints = (float(mapcount) * 700.0) + (float(g_totalBonusCount) * 400.0);

	// Load rank cfg
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), SKILLGROUP_PATH);
	if (FileExists(sPath))
	{
		Handle hKeyValues = CreateKeyValues("surftimer.SkillGroups");
		if (FileToKeyValues(hKeyValues, sPath) && KvGotoFirstSubKey(hKeyValues))
		{
			int RankValue[SkillGroup];

			if (g_hSkillGroups == null)
				g_hSkillGroups = CreateArray(sizeof(RankValue));
			else
				ClearArray(g_hSkillGroups);

			char sRankName[128], sRankNameColored[128];
			float fPercentage;
			int points;
			do
			{
				// Get section as Rankname
				KvGetString(hKeyValues, "name", sRankName, 128);
				KvGetString(hKeyValues, "name", sRankNameColored, 128);

				// Get percentage
				fPercentage = KvGetFloat(hKeyValues, "percentage");

				// Calculate required points for the rank
				if (fPercentage < 0.0)
					points = 0;
				else
					points = RoundToCeil(MaxPoints * fPercentage);

				RankValue[PointReq] = points;

				// Replace colors on name
				addColorToString(sRankNameColored, 128);

				// Get player name color
				RankValue[NameColor] = getFirstColor(sRankName);

				// Remove colors from rank name
				parseColorsFromString(sRankName, 128);

				Format(RankValue[RankName], 128, "%s", sRankName);

				Format(RankValue[RankNameColored], 128, "%s", sRankNameColored);

				PushArrayArray(g_hSkillGroups, RankValue[0]);

			} while (KvGotoNextKey(hKeyValues));
		}
		if (hKeyValues != null)
			CloseHandle(hKeyValues);
	}
	else
		SetFailState("[surftimer] %s not found.", SKILLGROUP_PATH);

}

public void getPlayerRank(int client, int rank, int points)
{
	char szName[64];
	GetClientName(client, szName, sizeof(szName));
	parseColorsFromString(szName, 64);
	char szSkillGroup[32];
	GetRankName(client, rank, points, szSkillGroup, 32);
	Format(g_pr_rankname[client], 128, szSkillGroup);
	Format(g_szRankName[client], sizeof(g_szRankName), szSkillGroup);

	if(points == 0)
	{
		Format(g_pr_chat_coloredrank[client], 128, "[Unranked]%c", WHITE);
		g_rankNameChatColour[client] = 0;
	}
	else if (rank >= 701 && rank <= 750)
	{
		Format(g_pr_chat_coloredrank[client], 128, "%c[%cNewbie%c]", WHITE, GRAY, WHITE);
		g_rankNameChatColour[client] = 0;
	}
	else if(rank >= 651 && rank <= 700)
	{
		Format(g_pr_chat_coloredrank[client], 128, "%c[%cLearning%c]%c", WHITE, GRAY, WHITE, GRAY);
		g_rankNameChatColour[client] = 7;
	}
	else if(rank >= 601 && rank <= 650)
	{
		Format(g_pr_chat_coloredrank[client], 128, "%c[%cNovice%c]", WHITE, DARKGREY, WHITE);
		g_rankNameChatColour[client] = 0;
	}
	else if(rank >= 551 && rank <= 600)
	{
		Format(g_pr_chat_coloredrank[client], 128, "%c[%cBeginner%c]%c", WHITE, DARKGREY, WHITE, DARKGREY);
		g_rankNameChatColour[client] = 14;
	}
	else if(rank >= 501 && rank <= 550)
	{
		Format(g_pr_chat_coloredrank[client], 128, "%c[%cRookie%c]", WHITE, YELLOW, WHITE);
		g_rankNameChatColour[client] = 0;
	}
	else if(rank >= 451 && rank <= 500)
	{
		Format(g_pr_chat_coloredrank[client], 128, "%c[%cAverage%c]%c", WHITE, YELLOW, WHITE, YELLOW);
		g_rankNameChatColour[client] = 8;
	}
	else if(rank >= 401 && rank <= 450)
	{
		Format(g_pr_chat_coloredrank[client], 128, "%c[%cCasual%c]", WHITE, MOSSGREEN, WHITE);
		g_rankNameChatColour[client] = 0;
	}
	else if(rank >= 351 && rank <= 400)
	{
		Format(g_pr_chat_coloredrank[client], 128, "%c[%cAdvanced%c]%c", WHITE, MOSSGREEN, WHITE, MOSSGREEN);
		g_rankNameChatColour[client] = 5;
	}
	else if(rank >= 301 && rank <= 350)
	{
		Format(g_pr_chat_coloredrank[client], 128, "%c[%cSkilled%c]", WHITE, LIMEGREEN, WHITE);
		g_rankNameChatColour[client] = 0;
	}
	else if(rank >= 251 && rank <= 300)
	{
		Format(g_pr_chat_coloredrank[client], 128, "%c[%cExceptional%c]%c", WHITE, LIMEGREEN, WHITE, LIMEGREEN);
		g_rankNameChatColour[client] = 3;
	}
	else if(rank >= 201 && rank <= 250)
	{
		Format(g_pr_chat_coloredrank[client], 128, "%c[%cAmazing%c]", WHITE, GREEN, WHITE);
		g_rankNameChatColour[client] = 0;
	}
	else if(rank >= 101 && rank <= 200)
	{
		Format(g_pr_chat_coloredrank[client], 128, "%c[%cPro%c]%c", WHITE, GREEN, WHITE, GREEN);
		g_rankNameChatColour[client] = 2;
	}
	else if(rank >= 51 && rank <= 100)
	{
		Format(g_pr_chat_coloredrank[client], 128, "%c[%cVeteran%c]", WHITE, BLUE, WHITE);
		g_rankNameChatColour[client] = 0;
	}
	else if(rank >= 26 && rank <= 50)
	{
		Format(g_pr_chat_coloredrank[client], 128, "%c[%cExpert%c]%c", WHITE, BLUE, WHITE, BLUE);
		g_rankNameChatColour[client] = 4;
	}
	else if (rank >= 11 && rank <= 25)
	{
		Format(g_pr_chat_coloredrank[client], 128, "%c[%cElite%c]%c", WHITE, DARKBLUE, WHITE, DARKBLUE);
		g_rankNameChatColour[client] = 10;
	}
	else if (rank >= 4 && rank <= 10)
	{
		Format(g_pr_chat_coloredrank[client], 128, "%c[%cMaster%c]%c", WHITE, ORANGE, WHITE, ORANGE);
		g_rankNameChatColour[client] = 15;
	}
	else if(rank == 3)
	{
		Format(g_pr_chat_coloredrank[client], 128, "%c[%cLegendary%c]%c", WHITE, PINK, WHITE, PINK);
		g_rankNameChatColour[client] = 11;
		g_bCustomTitleAccess[client] = true;
	}
	else if(rank == 2)
	{
		Format(g_pr_chat_coloredrank[client], 128, "%c[%cGodly%c]%c", WHITE, LIGHTRED, WHITE, LIGHTRED);
		g_rankNameChatColour[client] = 12;
		g_bCustomTitleAccess[client] = true;
	}
	else if(rank == 1)
	{
		Format(g_pr_chat_coloredrank[client], 128, "%c[%cKing%c]%c", WHITE, DARKRED, WHITE, DARKRED);
		g_rankNameChatColour[client] = 1;
		g_bCustomTitleAccess[client] = true;
	}
	else
	{
		Format(g_pr_chat_coloredrank[client], 128, "%c[Unranked]", WHITE);
		g_rankNameChatColour[client] = 0;
	}
}

public void GetRankName(int client, int rank, int points, char[] szRank, int length)
{
	if(points == 0)
	{
		Format(szRank, length, "[Unranked]");
	}
	else if (rank >= 701 && rank <= 750)
	{
		Format(szRank, length, "[Newbie]");
	}
	else if(rank >= 651 && rank <= 700)
	{
		Format(szRank, length, "[Learning]");
	}
	else if(rank >= 601 && rank <= 650)
	{
		Format(szRank, length, "[Novice]");
	}
	else if(rank >= 551 && rank <= 600)
	{
		Format(szRank, length, "[Beginner]");
	}
	else if(rank >= 501 && rank <= 550)
	{
		Format(szRank, length, "[Rookie]");
	}
	else if(rank >= 451 && rank <= 500)
	{
		Format(szRank, length, "[Average]");
	}
	else if(rank >= 401 && rank <= 450)
	{
		Format(szRank, length, "[Casual]");
	}
	else if(rank >= 351 && rank <= 400)
	{
		Format(szRank, length, "[Advanced]");
	}
	else if(rank >= 301 && rank <= 350)
	{
		Format(szRank, length, "[Skilled]");
	}
	else if(rank >= 251 && rank <= 300)
	{
		Format(szRank, length, "[Exceptional]");
	}
	else if(rank >= 201 && rank <= 250)
	{
		Format(szRank, length, "[Amazing]");
	}
	else if(rank >= 101 && rank <= 200)
	{
		Format(szRank, length, "[Pro]");
	}
	else if(rank >= 51 && rank <= 100)
	{
		Format(szRank, length, "[Veteran]");
	}
	else if(rank >= 26 && rank <= 50)
	{
		Format(szRank, length, "[Expert]");
	}
	else if (rank >= 11 && rank <= 25)
	{
		Format(szRank, length, "[Elite]");
	}
	else if (rank >= 4 && rank <= 10)
	{
		Format(szRank, length, "[Master]");
	}
	else if(rank == 3)
	{
		Format(szRank, length, "[Legendary]");
	}
	else if(rank == 2)
	{
		Format(szRank, length, "[Godly]");
	}
	else if(rank == 1)
	{
		Format(szRank, length, "[King]");
	}
	else
	{
		Format(szRank, length, "[Unranked]");
	}
}

public void SetPlayerRank(int client)
{
	if (IsFakeClient(client))
		return;

	if (g_hSkillGroups == null)
	{
		CreateTimer(5.0, reloadRank, client);
		return;
	}

	int RankValue[SkillGroup];

	//fluffys
	if (!g_bDbCustomTitleInUse[client])
	{
		// Player is not using a title
		if (GetConVarBool(g_hPointSystem))
		{
			//GetArrayArray(g_hSkillGroups, index, RankValue[0]);

			//Format(g_pr_rankname[client], 128, "%s", RankValue[RankName]);
			//Format(g_pr_chat_coloredrank[client], 128, "%s%c", RankValue[RankNameColored], WHITE);
			int rank = g_PlayerRank[client];
			int points = g_pr_points[client];
			getPlayerRank(client, rank, points);

			g_PlayerChatRank[client] = RankValue[NameColor];
		}
	}
	else
	{
		// Player is using a title
		if (GetConVarBool(g_hPointSystem))
		{
			g_PlayerChatRank[client] = RankValue[NameColor];
		}
		//fluffys
		//Format(g_pr_rankname[client], 128, "[%s]", g_szCustomTitleColoured[client]);
		//Format(g_pr_chat_coloredrank[client], 128, "[%s%c]", g_szflagTitle_Colored[g_iTitleInUse[client]], WHITE);
		//Format(g_pr_chat_coloredrank[client], 128, "[%s%c]", g_szCustomTitleColoured[client], WHITE);
	}

	// Admin Clantag
	if (GetConVarBool(g_hAdminClantag))
	{ if (GetUserFlagBits(client) & ADMFLAG_ROOT || GetUserFlagBits(client) & ADMFLAG_GENERIC)
		{
			Format(g_pr_chat_coloredrank[client], 128, "%s %cADMIN%c", g_pr_chat_coloredrank[client], LIMEGREEN, WHITE);
			Format(g_pr_rankname[client], 128, "ADMIN");
			return;
		}
	}
}

public int GetSkillgroupFromPoints(int points)
{
	int size = GetArraySize(g_hSkillGroups);
	for (int i = 0; i < size; i++)
	{
		int RankValue[SkillGroup];
		GetArrayArray(g_hSkillGroups, i, RankValue[0]);

		if (i == (size-1)) // Last rank
		{
			if (points >= RankValue[PointReq])
			{
				return i;
			}
		}
		else if (i == 0) // First rank
		{
			if (points <= RankValue[PointReq])
			{
				return i;
			}
		}
		else // Mid ranks
		{
			int RankValueNext[SkillGroup];
			GetArrayArray(g_hSkillGroups, (i+1), RankValueNext[0]);
			if (points > RankValue[PointReq] && points <= RankValueNext[PointReq])
			{
				return i;
			}
		}
	}
	// Return 0 if not found
	return 0;
}

stock Action PrintSpecMessageAll(int client)
{
	char szName[64];
	GetClientName(client, szName, sizeof(szName));
	parseColorsFromString(szName, 64);

	char szTextToAll[1024];
	GetCmdArgString(szTextToAll, sizeof(szTextToAll));
	StripQuotes(szTextToAll);
	if (StrEqual(szTextToAll, "") || StrEqual(szTextToAll, " ") || StrEqual(szTextToAll, "  "))
		return Plugin_Handled;

	parseColorsFromString(szTextToAll, 1024);
	char szChatRank[64];
	Format(szChatRank, 64, "%s", g_pr_chat_coloredrank[client]);

	if (GetConVarBool(g_hPointSystem) && GetConVarBool(g_hColoredNames) && !g_bDbCustomTitleInUse[client])
		setNameColor(szName, g_rankNameChatColour[client], 64);
	else if (GetConVarBool(g_hPointSystem) && GetConVarBool(g_hColoredNames) && g_bDbCustomTitleInUse[client])
		setNameColor(szName, g_iCustomColours[client][0], 64);
		//fluffys

	if (g_bHasCustomTextColour[client])
		setTextColor(szTextToAll, g_iCustomColours[client][1], 1024);

	if (GetConVarBool(g_hCountry))
		CPrintToChatAll("{green}%s{default} *SPEC* %s {grey}%s{default}: %s", g_szCountryCode[client], szChatRank, szName, szTextToAll);
	else if (GetConVarBool(g_hPointSystem))
	{
		if(StrContains(szChatRank, "{blue}") != -1)
		{
			char szPlayerTitle2[256][2];
			ExplodeString(szChatRank, "{blue}", szPlayerTitle2, 2, 256);
			if (IsPlayerAlive(client))
				CPrintToChatAll("%s%c%s %s{default}: %s", szPlayerTitle2[0], BLUE, szPlayerTitle2[1], szName, szTextToAll);
			else
				CPrintToChatAll("*DEAD* %s%c%s %s{default}: %s", szPlayerTitle2[0], BLUE, szPlayerTitle2[1], szName, szTextToAll);

			return Plugin_Handled;
		}
		else if(StrContains(szChatRank, "{orange}") != -1)
		{
			char szPlayerTitle2[256][2];
			ExplodeString(szChatRank, "{orange}", szPlayerTitle2, 2, 256);
			if (IsPlayerAlive(client))
				CPrintToChatAll("%s%c%s %s{default}: %s", szPlayerTitle2[0], ORANGE, szPlayerTitle2[1], szName, szTextToAll);
			else
				CPrintToChatAll("*DEAD* %s%c%s %s{default}: %s", szPlayerTitle2[0], ORANGE, szPlayerTitle2[1], szName, szTextToAll);

			return Plugin_Handled;
		}
		else
			CPrintToChatAll("*SPEC* %s {grey}%s{default}: %s", szChatRank, szName, szTextToAll);
		}
		else
			CPrintToChatAll("*SPEC* {grey}%s{default}: %s", szName, szTextToAll);

	for (int i = 1; i <= MaxClients; i++)
		if (IsValidClient(i))
		{
			if (GetConVarBool(g_hCountry) && (GetConVarBool(g_hPointSystem) || ((StrEqual(g_pr_rankname[client], "ADMIN", false)) && GetConVarBool(g_hAdminClantag))))
				PrintToConsole(i, "%s [%s] *SPEC* %s: %s", g_szCountryCode[client], g_pr_rankname[client], szName, szTextToAll);
			else
				if (GetConVarBool(g_hPointSystem) || ((StrEqual(g_pr_rankname[client], "ADMIN", false)) && GetConVarBool(g_hAdminClantag)))
					PrintToConsole(i, "[%s] *SPEC* %s: %s", g_szCountryCode[client], szName, szTextToAll);
				else
					if (GetConVarBool(g_hPointSystem))
						PrintToConsole(i, "[%s] *SPEC* %s: %s", g_pr_rankname[client], szName, szTextToAll);
					else
						PrintToConsole(i, "*SPEC* %s: %s", szName, szTextToAll);
		}
	return Plugin_Handled;
}
//http://pastebin.com/YdUWS93H
public bool CheatFlag(const char[] voice_inputfromfile, bool isCommand, bool remove)
{
	if (remove)
	{
		if (!isCommand)
		{
			Handle hConVar = FindConVar(voice_inputfromfile);
			if (hConVar != null)
			{
				int flags = GetConVarFlags(hConVar);
				SetConVarFlags(hConVar, flags &= ~FCVAR_CHEAT);
				return true;
			}
			else
				return false;
		}
		else
		{
			int flags = GetCommandFlags(voice_inputfromfile);
			if (SetCommandFlags(voice_inputfromfile, flags &= ~FCVAR_CHEAT))
				return true;
			else
				return false;
		}
	}
	else
	{
		if (!isCommand)
		{
			Handle hConVar = FindConVar(voice_inputfromfile);
			if (hConVar != null)
			{
				int flags = GetConVarFlags(hConVar);
				SetConVarFlags(hConVar, flags & FCVAR_CHEAT);
				return true;
			}
			else
				return false;


		} else
		{
			int flags = GetCommandFlags(voice_inputfromfile);
			if (SetCommandFlags(voice_inputfromfile, flags & FCVAR_CHEAT))
				return true;
			else
				return false;

		}
	}
}

public void StringRGBtoInt(char color[24], intColor[4])
{
	char sPart[4][24];
	ExplodeString(color, " ", sPart, sizeof(sPart), sizeof(sPart[]));
	intColor[0] = StringToInt(sPart[0]);
	intColor[1] = StringToInt(sPart[1]);
	intColor[2] = StringToInt(sPart[2]);
	intColor[3] = 255;
}

public void GetRGBColor(int bot, char color[256])
{
	char sPart[4][24];
	ExplodeString(color, " ", sPart, sizeof(sPart), sizeof(sPart[]));

	if (bot == 0)
	{
		g_ReplayBotColor[0] = StringToInt(sPart[0]);
		g_ReplayBotColor[1] = StringToInt(sPart[1]);
		g_ReplayBotColor[2] = StringToInt(sPart[2]);
	}
	else
		if (bot == 1)
	{
		g_BonusBotColor[0] = StringToInt(sPart[0]);
		g_BonusBotColor[1] = StringToInt(sPart[1]);
		g_BonusBotColor[2] = StringToInt(sPart[2]);
	}

	if (bot == 0 && g_RecordBot != -1 && IsValidClient(g_RecordBot))
		SetEntityRenderColor(g_RecordBot, g_ReplayBotColor[0], g_ReplayBotColor[1], g_ReplayBotColor[2], 50);
	else if (bot == 0 && g_WrcpBot != -1 && IsValidClient(g_WrcpBot))
		SetEntityRenderColor(g_WrcpBot, 255, 0, 255, 50);
	else
		if (bot == 1 && g_BonusBot != -1 && IsValidClient(g_BonusBot))
		SetEntityRenderColor(g_BonusBot, g_BonusBotColor[0], g_BonusBotColor[1], g_BonusBotColor[2], 50);

}

public void SpecList(int client)
{
	if (!IsValidClient(client) || IsFakeClient(client) || GetClientMenu(client) != MenuSource_None)
		return;

	if (!StrEqual(g_szPlayerPanelText[client], ""))
	{
		Handle panel = CreatePanel();
		DrawPanelText(panel, g_szPlayerPanelText[client]);
		SendPanelToClient(panel, client, PanelHandler, 1);
		CloseHandle(panel);
	}
}

public int PanelHandler(Handle menu, MenuAction action, int param1, int param2)
{
}

public bool TraceRayDontHitSelf(int entity, int mask, any data)
{
	return entity != data && !(0 < entity <= MaxClients);
}

stock int BooltoInt(bool status)
{
	return (status) ? 1:0;
}

public void PlayQuakeSound_Spec(int client, char[] buffer)
{
	int SpecMode;
	for (int x = 1; x <= MaxClients; x++)
	{
		if (IsValidClient(x) && !IsPlayerAlive(x))
		{
			SpecMode = GetEntProp(x, Prop_Send, "m_iObserverMode");
			if (SpecMode == 4 || SpecMode == 5)
			{
				int Target = GetEntPropEnt(x, Prop_Send, "m_hObserverTarget");
				if (Target == client)
					if (g_bEnableQuakeSounds[x])
					ClientCommand(x, buffer);
			}
		}
	}
}

public void AttackProtection(int client, int &buttons)
{
	if (GetConVarBool(g_hAttackSpamProtection))
	{
		char classnamex[64];
		GetClientWeapon(client, classnamex, 64);
		if (StrContains(classnamex, "knife", true) == -1 && g_AttackCounter[client] >= 40)
		{
			if (buttons & IN_ATTACK)
			{
				int ent;
				ent = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
				if (IsValidEntity(ent))
					SetEntPropFloat(ent, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + 2.0);
			}
		}
	}
}

public void CheckRun(int client)
{
	if (!IsValidClient(client) || IsFakeClient(client))
		return;

	if (g_bTimeractivated[client])
	{
		if (g_fCurrentRunTime[client] > g_fPersonalRecord[client] && !g_bMissedMapBest[client] && !g_bPause[client] && g_iClientInZone[client][2] == 0)
		{
			g_bMissedMapBest[client] = true;
			if (g_fPersonalRecord[client] > 0.0)
				PrintToChat(client, "%t", "MissedMapBest", LIMEGREEN, WHITE, GRAY, DARKBLUE, g_szPersonalRecord[client], GRAY);
			EmitSoundToClient(client, "buttons/button18.wav", client);
		}
		else
		{
			if (g_fCurrentRunTime[client] > g_fPersonalRecordBonus[g_iClientInZone[client][2]][client] && g_iClientInZone[client][2] > 0 && !g_bPause[client] && !g_bMissedBonusBest[client])
			{
				if (g_fPersonalRecordBonus[g_iClientInZone[client][2]][client] > 0.0)
				{
					g_bMissedBonusBest[client] = true;
					PrintToChat(client, " %cSurftimer %c| %cYou have missed your best bonus time of (%c%s%c)", LIMEGREEN, WHITE, GRAY, ORANGE, g_szPersonalRecordBonus[g_iClientInZone[client][2]][client], GRAY);
					EmitSoundToClient(client, "buttons/button18.wav", client);
				}
			}
		}
	}
}

public void NoClipCheck(int client)
{
	MoveType mt;
	mt = GetEntityMoveType(client);
	if (!(g_bOnGround[client]))
	{
		if (mt == MOVETYPE_NOCLIP)
			g_bNoClipUsed[client] = true;
	}
	if (mt == MOVETYPE_NOCLIP && (g_bTimeractivated[client]))
	{
		Client_Stop(client, 1);
	}
}


public void AutoBhopFunction(int client, int &buttons)
{
	if (!IsValidClient(client))
		return;
	if (g_bAutoBhop && g_bAutoBhopClient[client])
	{
		if (buttons & IN_JUMP)
			if (!(g_bOnGround[client]))
			if (!(GetEntityMoveType(client) & MOVETYPE_LADDER))
			if (GetEntProp(client, Prop_Data, "m_nWaterLevel") <= 1)
			buttons &= ~IN_JUMP;

	}
}

public void SpecListMenuDead(int client) // What Spectators see
{
	char szTick[32];
	Format(szTick, 32, "%i", g_Server_Tickrate);
	int ObservedUser;
	ObservedUser = -1;
	char sSpecs[512];
	Format(sSpecs, 512, "");
	int SpecMode;
	ObservedUser = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
	SpecMode = GetEntProp(client, Prop_Send, "m_iObserverMode");

	if (SpecMode == 4 || SpecMode == 5)
	{
		g_SpecTarget[client] = ObservedUser;
		int count;
		count = 0;
		//Speclist
		if (1 <= ObservedUser <= MaxClients)
		{
			int x;
			char szTime2[32];
			char szProBest[32];
			char szPlayerRank[64];
			Format(szPlayerRank, 32, "");
			char szStage[32];

			for (x = 1; x <= MaxClients; x++)
			{
				if (IsValidClient(x) && !IsFakeClient(client) && !IsPlayerAlive(x) && GetClientTeam(x) >= 1 && GetClientTeam(x) <= 3)
				{

					SpecMode = GetEntProp(x, Prop_Send, "m_iObserverMode");
					if (SpecMode == 4 || SpecMode == 5)
					{
						int ObservedUser2;
						ObservedUser2 = GetEntPropEnt(x, Prop_Send, "m_hObserverTarget");
						if (ObservedUser == ObservedUser2)
						{
							count++;
							if (count < 6)
								Format(sSpecs, 512, "%s%N\n", sSpecs, x);
						}
						if (count == 6)
							Format(sSpecs, 512, "%s...", sSpecs);
					}
				}
			}

			//rank
			if (GetConVarBool(g_hPointSystem))
			{
				if (g_pr_points[ObservedUser] != 0)
				{
					char szRank[32];
					if (g_PlayerRank[ObservedUser] > g_pr_RankedPlayers)
						Format(szRank, 32, "-");
					else
						Format(szRank, 32, "%i", g_PlayerRank[ObservedUser]);
					Format(szPlayerRank, 32, "Rank: #%s/%i", szRank, g_pr_RankedPlayers);
				}
				else
					Format(szPlayerRank, 32, "Rank: NA / %i", g_pr_RankedPlayers);
			}

			if (g_fPersonalRecord[ObservedUser] > 0.0)
			{
				FormatTimeFloat(client, g_fPersonalRecord[ObservedUser], 3, szTime2, sizeof(szTime2));
				Format(szProBest, 32, "%s (#%i/%i)", szTime2, g_MapRank[ObservedUser], g_MapTimesCount);
			}
			else
				Format(szProBest, 32, "None");

			if (g_bhasStages) //  There are stages
				Format(szStage, 32, "Stage: %i / %i", g_Stage[g_iClientInZone[ObservedUser][2]][ObservedUser], (g_mapZonesTypeCount[g_iClientInZone[ObservedUser][2]][3] + 1));
			else
				Format(szStage, 32, "Linear map");

			if (g_Stage[g_iClientInZone[client][2]][ObservedUser] == 999) // if player is in stage 999
				Format(szStage, 32, "Bonus");

			if (!StrEqual(sSpecs, ""))
			{
				char szName[MAX_NAME_LENGTH];
				GetClientName(ObservedUser, szName, MAX_NAME_LENGTH);
				if (g_bTimeractivated[ObservedUser])
				{
					char szTime[32];
					float Time;
					Time = GetGameTime() - g_fStartTime[ObservedUser] - g_fPauseTime[ObservedUser];
					FormatTimeFloat(client, Time, 4, szTime, sizeof(szTime));
					if (!g_bPause[ObservedUser])
					{
						if (!IsFakeClient(ObservedUser))
						{
							Format(g_szPlayerPanelText[client], 512, "Specs (%i):\n%s\n  \n%s\n%s\nRecord: %s\n\n%s\n", count, sSpecs, szTime, szPlayerRank, szProBest, szStage);
							if (!g_bShowSpecs[client])
								Format(g_szPlayerPanelText[client], 512, "Specs (%i)\n \n%s\n%s\nRecord: %s\n\nStage: %s\n", count, szTime, szPlayerRank, szProBest, szStage);
						}
						else
						{
							if (ObservedUser == g_RecordBot)
								Format(g_szPlayerPanelText[client], 512, "[Map Record Replay]\n%s\nTickrate: %s\nSpecs: %i\n\n%s\n", szTime, szTick, count, szStage);
							else
								if (ObservedUser == g_BonusBot)
									Format(g_szPlayerPanelText[client], 512, "[%s Record Replay]\n%s\nTickrate: %s\nSpecs: %i\n\n%s\n", g_szZoneGroupName[g_iClientInZone[g_BonusBot][2]], szTime, szTick, count, szStage);

						}
					}
					else
					{
						if (ObservedUser == g_RecordBot)
							Format(g_szPlayerPanelText[client], 512, "[Map Record Replay]\nTime: PAUSED\nTickrate: %s\nSpecs: %i\n\n%s\n", szTick, count, szStage);
						else
							if (ObservedUser == g_BonusBot)
								Format(g_szPlayerPanelText[client], 512, "[%s Record Replay]\nTime: PAUSED\nTickrate: %s\nSpecs: %i\n\nBonus\n", g_szZoneGroupName[g_iClientInZone[g_BonusBot][2]], szTick, count);
					}
				}
				else
				{
					if (ObservedUser != g_RecordBot)
					{
						Format(g_szPlayerPanelText[client], 512, "%Specs (%i):\n%s\n \n%s\nRecord: %s\n", count, sSpecs, szPlayerRank, szProBest);
						if (!g_bShowSpecs[client])
							Format(g_szPlayerPanelText[client], 512, "Specs (%i)\n \n%s\nRecord: %s\n", count, szPlayerRank, szProBest);
					}
				}

				if (g_bShowSpecs[client])
				{
					if (ObservedUser != g_RecordBot && ObservedUser != g_BonusBot && ObservedUser != g_WrcpBot)
						Format(g_szPlayerPanelText[client], 512, "%Specs (%i):\n%s\n \n%s\nRecord: %s\n\n%s\n", count, sSpecs, szPlayerRank, szProBest, szStage);
					else
					{
						if (ObservedUser == g_RecordBot)
							Format(g_szPlayerPanelText[client], 512, "Map Replay\n%s (%s)\n \nSpecs (%i):\n%s\n \n%s\n", g_szReplayName, g_szReplayTime, count, sSpecs, szStage);
						else if (ObservedUser == g_BonusBot)
							Format(g_szPlayerPanelText[client], 512, "Bonus Replay\n%s (%s)\n \nSpecs (%i):\n%s\n \nBonus\n", g_szBonusName, g_szBonusTime, count, sSpecs);
						else if (ObservedUser == g_WrcpBot)
						{
							int stage = g_StageReplayCurrentStage;
							Format(g_szPlayerPanelText[client], 512, "Stage %i Replay (%i)\n%s (%s)\n \nSpecs (%i):\n%s\n", g_StageReplayCurrentStage, g_StageReplaysLoop, g_szWrcpReplayName[stage],  g_szWrcpReplayTime[stage], count, sSpecs);
						}

					}
				}
				if (!g_bShowSpecs[client])
				{
					if (ObservedUser != g_RecordBot)
						Format(g_szPlayerPanelText[client], 512, "%s\nRecord: %s\n\n%s\n", szPlayerRank, szProBest, szStage);
					else
					{
						if (ObservedUser == g_RecordBot)
							Format(g_szPlayerPanelText[client], 512, "Record replay of\n%s\n \nTickrate: %s\n\n%s\n", g_szReplayName, szTick, szStage);
						else
							if (ObservedUser == g_BonusBot)
							Format(g_szPlayerPanelText[client], 512, "Bonus replay of\n%s\n \nTickrate: %s\n\nBonus\n", g_szBonusName, szTick, szStage);

					}
				}
				SpecList(client);
			}
		}
	}
	else
		g_SpecTarget[client] = -1;
}

public void SpecListMenuAlive(int client) // What player sees
{

	if (IsFakeClient(client) || !g_bShowSpecs[client] || GetClientMenu(client) != MenuSource_None)
		return;

	//Spec list for players
	Format(g_szPlayerPanelText[client], 512, "");
	char sSpecs[512];
	int SpecMode;
	Format(sSpecs, 512, "");
	int count;
	count = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && !IsFakeClient(client) && !IsPlayerAlive(i) && !g_bFirstTeamJoin[i] && g_bSpectate[i])
		{
			SpecMode = GetEntProp(i, Prop_Send, "m_iObserverMode");
			if (SpecMode == 4 || SpecMode == 5)
			{
				int Target;
				Target = GetEntPropEnt(i, Prop_Send, "m_hObserverTarget");
				if (Target == client)
				{
					count++;
					if (count < 6)
						Format(sSpecs, 512, "%s%N\n", sSpecs, i);

				}
				if (count == 6)
					Format(sSpecs, 512, "%s...", sSpecs);
			}
		}
	}
	if (count > 0)
	{
		if (g_bShowSpecs[client])
			Format(g_szPlayerPanelText[client], 512, "Specs (%i):\n%s ", count, sSpecs);

		SpecList(client);
	}
	else
		Format(g_szPlayerPanelText[client], 512, "");
}

public void LoadInfoBot()
{
	if (!GetConVarBool(g_hInfoBot))
		return;

	g_InfoBot = -1;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i) || !IsFakeClient(i) || i == g_RecordBot || i == g_BonusBot || i == g_WrcpBot)
			continue;
		g_InfoBot = i;
		break;
	}
	if (IsValidClient(g_InfoBot))
	{
		Format(g_pr_rankname[g_InfoBot], 128, "BOT");
		CS_SetClientClanTag(g_InfoBot, "");
		SetEntProp(g_InfoBot, Prop_Send, "m_iAddonBits", 0);
		SetEntProp(g_InfoBot, Prop_Send, "m_iPrimaryAddon", 0);
		SetEntProp(g_InfoBot, Prop_Send, "m_iSecondaryAddon", 0);
		SetEntProp(g_InfoBot, Prop_Send, "m_iObserverMode", 1);
		SetInfoBotName(g_InfoBot);
	}
	else
	{
		setBotQuota();
		CreateTimer(0.5, RefreshInfoBot, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public void CreateNavFiles()
{
	char DestFile[256];
	char SourceFile[256];
	Format(SourceFile, sizeof(SourceFile), "maps/replay_bot.nav");
	if (!FileExists(SourceFile))
	{
		LogError("<surftimer> Failed to create .nav files. Reason: %s doesn't exist!", SourceFile);
		return;
	}
	char map[256];
	int mapListSerial = -1;
	if (ReadMapList(g_MapList, mapListSerial, "mapcyclefile", MAPLIST_FLAG_CLEARARRAY | MAPLIST_FLAG_NO_DEFAULT) == null)
		if (mapListSerial == -1)
			return;

	for (int i = 0; i < GetArraySize(g_MapList); i++)
	{
		GetArrayString(g_MapList, i, map, sizeof(map));
		if (map[0])
		{
			Format(DestFile, sizeof(DestFile), "maps/%s.nav", map);
			if (!FileExists(DestFile))
				File_Copy(SourceFile, DestFile);
		}
	}
}

public Action RefreshInfoBot(Handle timer)
{
	LoadInfoBot();
}


public void SetInfoBotName(int ent)
{
	char szBuffer[64];
	char sNextMap[128];
	if (!IsValidClient(g_InfoBot) || !GetConVarBool(g_hInfoBot))
		return;
	if (g_bMapChooser && EndOfMapVoteEnabled() && !HasEndOfMapVoteFinished())
		Format(sNextMap, sizeof(sNextMap), "Pending Vote");
	else
	{
		GetNextMap(sNextMap, sizeof(sNextMap));
		char mapPieces[6][128];
		int lastPiece = ExplodeString(sNextMap, "/", mapPieces, sizeof(mapPieces), sizeof(mapPieces[]));
		Format(sNextMap, sizeof(sNextMap), "%s", mapPieces[lastPiece - 1]);
	}
	int iInfoBotTimeleft;
	GetMapTimeLeft(iInfoBotTimeleft);
	float ftime = float(iInfoBotTimeleft);
	char szTime[32];
	FormatTimeFloat(g_InfoBot, ftime, 4, szTime, sizeof(szTime));
	Handle hTmp;
	hTmp = FindConVar("mp_timelimit");
	int iTimeLimit = GetConVarInt(hTmp);
	if (hTmp != null)
		CloseHandle(hTmp);
	if (GetConVarBool(g_hMapEnd) && iTimeLimit > 0)
		Format(szBuffer, sizeof(szBuffer), "%s (in %s)", sNextMap, szTime);
	else
		Format(szBuffer, sizeof(szBuffer), "Pending Vote (no time limit)");
	SetClientName(g_InfoBot, szBuffer);
	Client_SetScore(g_InfoBot, 9999);
	CS_SetClientClanTag(g_InfoBot, "NEXTMAP");
}

public void CenterHudDead(int client)
{
	char szTick[32];
	char obsAika[128];
	float obsTimer;
	Format(szTick, 32, "%i", g_Server_Tickrate);
	int ObservedUser;
	ObservedUser = -1;
	int SpecMode;
	ObservedUser = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
	SpecMode = GetEntProp(client, Prop_Send, "m_iObserverMode");
	if (SpecMode == 4 || SpecMode == 5)
	{
		g_SpecTarget[client] = ObservedUser;
		//keys
		char sResult[256];
		int Buttons;
		if (IsValidClient(ObservedUser))
		{
			Buttons = g_LastButton[ObservedUser];
			if (Buttons & IN_MOVELEFT)
				Format(sResult, sizeof(sResult), "<font color='#00ff00'>A</font>");
			else
				Format(sResult, sizeof(sResult), "_");
			if (Buttons & IN_FORWARD)
				Format(sResult, sizeof(sResult), "%s <font color='#00ff00'>W</font>", sResult);
			else
				Format(sResult, sizeof(sResult), "%s _", sResult);
			if (Buttons & IN_BACK)
				Format(sResult, sizeof(sResult), "%s <font color='#00ff00'>S</font>", sResult);
			else
				Format(sResult, sizeof(sResult), "%s _", sResult);
			if (Buttons & IN_MOVERIGHT)
				Format(sResult, sizeof(sResult), "%s <font color='#00ff00'>D</font>", sResult);
			else
				Format(sResult, sizeof(sResult), "%s _", sResult);
			if (Buttons & IN_DUCK)
				Format(sResult, sizeof(sResult), "%s - <font color='#00ff00'>DUCK</font>", sResult);
			else
				Format(sResult, sizeof(sResult), "%s - _", sResult);
			if (Buttons & IN_JUMP)
				Format(sResult, sizeof(sResult), "%s <font color='#00ff00'>JUMP</font>", sResult);
			else
				Format(sResult, sizeof(sResult), "%s _", sResult);

			if (g_bTimeractivated[ObservedUser])
			 {
				obsTimer = GetGameTime() - g_fStartTime[ObservedUser] - g_fPauseTime[ObservedUser];
				FormatTimeFloat(client, obsTimer, 3, obsAika, sizeof(obsAika));
			}
			else if(g_bWrcpTimeractivated[ObservedUser] && !g_bTimeractivated[ObservedUser])
			{
				obsTimer = GetGameTime() - g_fStartWrcpTime[ObservedUser] - g_fPauseTime[ObservedUser];
				FormatTimeFloat(client, obsTimer, 3, obsAika, sizeof(obsAika));
			}
			else if(!g_bTimerEnabled[ObservedUser])
				obsAika = "<font color='#FF0000'>Disabled</font>";
			else {
				obsAika = "<font color='#FF0000'>00:00:00</font>";
			}
			char timerText[32] = "";
			if (g_iClientInZone[ObservedUser][2] > 0)
				Format(timerText, 32, "[%s] ", g_szZoneGroupName[g_iClientInZone[ObservedUser][2]]);
			if (g_bPracticeMode[ObservedUser])
				Format(timerText, 32, "[P] ");
			else if(g_iCurrentStyle[ObservedUser] != 0)
				Format(timerText, 32, "%s ", g_szStyleHud[ObservedUser]);
				//fluffys come back here
			PrintHintText(client, "<font face=''><font color='#0089ff'>%sTimer:</font> %s\n<font color='#0089ff'>Speed:</font> %.1f u/s\n%s", timerText, obsAika, g_fLastSpeed[ObservedUser], sResult);
		}
	}
	else
		g_SpecTarget[client] = -1;
}

public void CenterHudAlive(int client)
{
	if (!IsValidClient(client))
		return;

	if (g_bCentreHud[client])
	{
		int style = g_iCurrentStyle[client];
		char module[6][1024];
		char pAika[54];

		float gametime = GetGameTime();

		for (int i = 0; i < 6; i++)
		{
			if (g_iCentreHudModule[client][i] == 0)
			{
				Format(module[i], 128, "                         ");
			}
			if (g_iCentreHudModule[client][i] == 1)
			{
				// Timer
				if (g_bTimeractivated[client])
				{
					FormatTimeFloat(client, g_fCurrentRunTime[client], 3, pAika, 128);
					if (g_bPause[client])
					{
						// Paused
						Format(module[i], 128, "<font color='#FFFF00'>%s       </font>", pAika);
					}
					else if (g_bPracticeMode[client])
					{
						// Prac mode
						Format(module[i], 128, "<font color='#ffffff'>[P]: %s       </font>", pAika);
					}
					else if (g_bInBonus[client])
					{
						// In Bonus
						Format(module[i], 128, "<font color='#ff8200'>%s       </font>", pAika);
					}
					else if (g_bMissedMapBest[client] && g_fPersonalRecord[client] > 0.0)
					{
						// Missed Personal Best time
						Format(module[i], 128, "<font color='#fd0000'>%s       </font>", pAika);
					}
					else if (g_fPersonalRecord[client] < 0.1)
					{
						// No Personal Best on map
						Format(module[i], 128, "<font color='#0089ff'>%s       </font>", pAika);
					}
					else
					{
						// Hasn't missed Personal Best yet
						Format(module[i], 128, "<font color='#00ff00'>%s       </font>", pAika);
					}
				}
				else if (g_bWrcpTimeractivated[client] && !g_bPracticeMode[client])
				{
					FormatTimeFloat(client, g_fCurrentWrcpRunTime[client], 3, pAika, 128);
					Format(module[i], 128, "<font color='#bd00ff'>%s       </font>", pAika);
				}
				else if (!g_bTimerEnabled[client])
					Format(module[i], 128, "<font color='#FFFF00'>Disabled       </font>");
				else
				{
					Format(module[i], 128, "<font color='#FF0000'>00:00:00       </font>");
				}

				if (g_iCurrentStyle[client] != 0)
				{
					switch (g_iCurrentStyle[client])
					{
						case 1: Format(module[i], 128, "SW %s", module[i]);
						case 2: Format(module[i], 128, "HSW %s", module[i]);
						case 3: Format(module[i], 128, "BW %s", module[i]);
						case 4: Format(module[i], 128, "LG %s", module[i]);
						case 5: Format(module[i], 128, "SM %s", module[i]);
						case 6: Format(module[i], 128, "FF %s", module[i]);
					}
				}
			}
			else if (g_iCentreHudModule[client][i] == 2)
			{
				// WR
				if (gametime - g_fLastDifferenceTime[client] > 5.0)
				{
					if (g_iClientInZone[client][2] == 0 && style == 0)
					{
						if (g_fRecordMapTime != 9999999.0)
						{
							//fluffys
							if(g_bPracticeMode[client])
								Format(g_szLastSRDifference[client], 64, "WR: %s", g_szRecordMapTime);
							else
								Format(g_szLastSRDifference[client], 64, "WR: %s", g_szRecordMapTime);
						}
						else
							Format(g_szLastSRDifference[client], 64, "WR: N/A");
					}
					else if(g_iClientInZone[client][2] == 0 && g_iCurrentStyle[client] != 0) //styles
					{
						if (g_fRecordStyleMapTime[style] != 9999999.0)
						{
							//fluffys
							if(g_bPracticeMode[client])
								Format(g_szLastSRDifference[client], 64, "WR: %s", g_szRecordStyleMapTime[style]);
							else
								Format(g_szLastSRDifference[client], 64, "WR: %s", g_szRecordStyleMapTime[style]);
						}
						else
							Format(g_szLastSRDifference[client], 64, "WR: N/A");
					}
					else
					{
						if(g_iCurrentStyle[client] == 0)
							Format(g_szLastSRDifference[client], 64, "WR: %s", g_szBonusFastestTime[g_iClientInZone[client][2]]);
						else if(g_iCurrentStyle[client] != 0) // styles
							Format(g_szLastSRDifference[client], 64, "WR: %s", g_szStyleBonusFastestTime[style][g_iClientInZone[client][2]]);
					}
				}
				Format(module[i], 128, "%s", g_szLastSRDifference[client]);
			}
			else if (g_iCentreHudModule[client][i] == 3)
			{
				// PB
				if (gametime - g_fLastDifferenceTime[client] > 5.0)
				{
					if (g_iClientInZone[client][2] == 0 && style == 0)
					{
						if (g_fRecordMapTime != 9999999.0)
						{
							if (g_fPersonalRecord[client] > 0.0)
								Format(g_szLastPBDifference[client], 64, "PB: %s", g_szPersonalRecord[client]);
							else
								Format(g_szLastPBDifference[client], 64, "PB: N/A");
						}
						else
							Format(g_szLastPBDifference[client], 64, "PB: N/A");
					}
					else if(g_iClientInZone[client][2] == 0 && g_iCurrentStyle[client] != 0) //styles
					{
						if (g_fRecordStyleMapTime[style] != 9999999.0)
						{
							if (g_fPersonalStyleRecord[style][client] > 0.0)
								Format(g_szLastPBDifference[client], 64, "PB: %s", g_szPersonalStyleRecord[style][client]);
							else
								Format(g_szLastPBDifference[client], 64, "PB: N/A");
						}
						else
							Format(g_szLastPBDifference[client], 64, "PB: N/A");
					}
					else
					{
						if(g_iCurrentStyle[client] == 0)
							Format(g_szLastPBDifference[client], 64, "PB: %s", g_szPersonalRecordBonus[g_iClientInZone[client][2]][client]);
						else if(g_iCurrentStyle[client] != 0) // styles
							Format(g_szLastPBDifference[client], 64, "PB: %s", g_szStylePersonalRecordBonus[style][g_iClientInZone[client][2]][client]);
					}
				}
				Format(module[i], 128, "%s", g_szLastPBDifference[client]);
			}
			else if (g_iCentreHudModule[client][i] == 4)
			{
				// Rank Display
				char szRank[32];
				if (g_iClientInZone[client][2] > 0) // if in bonus stage, get bonus times
				{
					if(g_iCurrentStyle[client] == 0) //normal
					{
						if (g_fPersonalRecordBonus[g_iClientInZone[client][2]][client] > 0.0)
							Format(szRank, 64, "Rank: %i / %i", g_MapRankBonus[g_iClientInZone[client][2]][client], g_iBonusCount[g_iClientInZone[client][2]]);
						else
							if (g_iBonusCount[g_iClientInZone[client][2]] > 0)
								Format(szRank, 64, "Rank: - / %i", g_iBonusCount[g_iClientInZone[client][2]]);
							else
								Format(szRank, 64, "Rank: N/A");
					}
					else if(g_iCurrentStyle[client] != 0) // styles
					{
						if (g_fStylePersonalRecordBonus[style][g_iClientInZone[client][2]][client] > 0.0)
							Format(szRank, 64, "Rank: %i / %i", g_StyleMapRankBonus[style][g_iClientInZone[client][2]][client], g_iStyleBonusCount[style][g_iClientInZone[client][2]]);
						else
							if (g_iStyleBonusCount[style][g_iClientInZone[client][2]] > 0)
								Format(szRank, 64, "Rank: - / %i", g_iStyleBonusCount[style][g_iClientInZone[client][2]]);
							else
								Format(szRank, 64, "Rank: N/A");
					}
				}
				else // if in normal map, get normal times
				{
					if(g_iCurrentStyle[client] == 0) // Normal
					{
						if (g_fPersonalRecord[client] > 0.0)
							Format(szRank, 64, "Rank: %i / %i", g_MapRank[client], g_MapTimesCount);
						else
							if (g_MapTimesCount > 0)
								Format(szRank, 64, "Rank: - / %i", g_MapTimesCount);
							else
								Format(szRank, 64, "Rank: N/A");
					}
					else if(g_iCurrentStyle[client] != 0) // styles
					{
						if (g_fPersonalStyleRecord[style][client] > 0.0)
							Format(szRank, 64, "Rank: %i / %i", g_StyleMapRank[style][client], g_StyleMapTimesCount[style]);
						else
							if (g_StyleMapTimesCount[style] > 0)
								Format(szRank, 64, "Rank: - / %i", g_StyleMapTimesCount[style]);
							else
								Format(szRank, 64, "Rank: N/A");
					}
				}

				Format(module[i], 128, "%s", szRank);
			}
			else if (g_iCentreHudModule[client][i] == 5)
			{
				// Stage Display
				if (g_iClientInZone[client][2] == 0)
				{
					if (!g_bhasStages) // map is linear
					{
						Format(module[i], 128, "Linear Map");
					}
					else // map has stages
					{
						Format(module[i], 128, "Stage %i / %i", g_Stage[g_iClientInZone[client][2]][client], (g_mapZonesTypeCount[g_iClientInZone[client][2]][3] + 1)); // less \t's to make lines align
					}
				}
				else
					Format(module[i], 128, "Bonus %i", g_iClientInZone[client][2]);
			}
			else if (g_iCentreHudModule[client][i] == 6)
			{
				// Speed Display
				GetSpeedColour(client, RoundToNearest(g_fLastSpeed[client]), g_SpeedGradient[client]);
				if (RoundToNearest(g_fLastSpeed[client]) < 10 && RoundToNearest(g_fLastSpeed[client]) > -1)
				{
					if (i == 0 || i == 2 || i == 4)
						Format(module[i], 128, "Speed: <font color='%s'>%i</font> u/s       ", g_szSpeedColour[client], RoundToNearest(g_fLastSpeed[client]));
					else
						Format(module[i], 128, "Speed: <font color='%s'>%i</font> u/s", g_szSpeedColour[client], RoundToNearest(g_fLastSpeed[client]));
				}
				else
					Format(module[i], 128, "Speed: <font color='%s'>%i</font> u/s", g_szSpeedColour[client], RoundToNearest(g_fLastSpeed[client]));
			}
			else if (g_iCentreHudModule[client][i] == 7)
			{
				// Strafe Sync
				Format(module[i], 128, "Sync: %.02f%%", GetStrafeSync(client, true));
			}
		}

		// if (g_iCurrentStyle[client] > 0)
		// 	Format(timerText, sizeof(timerText), "%s%s", g_szStyleHud[client], timerColour);
		// else
		// 	Format(timerText, sizeof(timerText), "%s", timerColour);

		if (IsValidEntity(client) && 1 <= client <= MaxClients && !g_bOverlay[client])
		{
			//PrintHintText(client, "<font face=''>%s%s\n%s%s\n%s%s</font>", module[0], module2, module[2], module4, module[4], module6);
			PrintHintText(client, "<font face=''>%15s\t %15s\n%15s\t %15s\n%15s\t %15s</font>", module[0], module[1], module[2], module[3], module[4], module[5]);
		}
	}
}

public void SideHudAlive(int client)
{
	if (!IsValidClient(client) || IsFakeClient(client) || GetClientMenu(client) != MenuSource_None)
		return;

	if (g_bSideHud[client])
	{
		char szPanel[1280], szBuffer[2][256], szModule[5][1280];
		int style = g_iCurrentStyle[client];
		int moduleCount = 0;

		for (int i = 0; i < 5; i++)
		{
			if (g_iSideHudModule[client][i] != 0)
				moduleCount++;
		}

		for (int i = 0; i < 5; i++)
		{
			if (g_iSideHudModule[client][i] == 0)
			{
				Format(szModule[i], 256, "");
			}
			if (g_iSideHudModule[client][i] == 1)
			{
				int timeleft;
				GetMapTimeLeft(timeleft);
				int mins = timeleft / 60;
				int secs = timeleft % 60;

				if (mins > 0)
					Format(szModule[i], 256, "Timeleft: %d mins", mins);
				else
					Format(szModule[i], 256, "Timeleft: %d secs", secs);
				
				if ((i + 1) != moduleCount)
					Format(szModule[i], 256, "%s\n \n", szModule[i]);
			}
			else if (g_iSideHudModule[client][i] == 2)
			{
				char szWR[128];
				if (StrContains(g_szLastSRDifference[client], "<font") != -1)
				{
					ExplodeString(g_szLastSRDifference[client], ">", szBuffer, 2, 128);
					ExplodeString(szBuffer[1], "<", szBuffer, 2, 128);
					Format(szWR, 128, "WR: %s", szBuffer[0]);
				}
				else
					Format(szWR, 128, "%s", g_szLastSRDifference[client]);
				char szWRHolder[64];
				if (g_iClientInZone[client][2] == 0)
					Format(szWRHolder, 64, g_szRecordPlayer);
				else
					Format(szWRHolder, 64, g_szBonusFastest[g_iClientInZone[client][2]]);
				
				Format(szModule[i], 256, "%s\nby %s", szWR, szWRHolder);

				if ((i + 1) != moduleCount)
					Format(szModule[i], 256, "%s\n \n", szModule[i]);
			}
			else if (g_iSideHudModule[client][i] == 3)
			{
				char szPB[128];
				if (StrContains(g_szLastPBDifference[client], "<font") != -1)
				{
					ExplodeString(g_szLastPBDifference[client], ">", szBuffer, 2, 128);
					ExplodeString(szBuffer[1], "<", szBuffer, 2, 128);
					Format(szPB, sizeof(szPB), "PB: %s", szBuffer[0]);
				}
				else
					Format(szPB, sizeof(szPB), g_szLastPBDifference[client]);

				// Rank Display
				char szRank[32];
				if (g_iClientInZone[client][2] > 0) // if in bonus stage, get bonus times
				{
					if(g_iCurrentStyle[client] == 0) //normal
					{
						if (g_fPersonalRecordBonus[g_iClientInZone[client][2]][client] > 0.0)
							Format(szRank, 64, "Rank: %i / %i", g_MapRankBonus[g_iClientInZone[client][2]][client], g_iBonusCount[g_iClientInZone[client][2]]);
						else
							if (g_iBonusCount[g_iClientInZone[client][2]] > 0)
								Format(szRank, 64, "Rank: - / %i", g_iBonusCount[g_iClientInZone[client][2]]);
							else
								Format(szRank, 64, "Rank: N/A");
					}
					else if(g_iCurrentStyle[client] != 0) // styles
					{
						if (g_fStylePersonalRecordBonus[style][g_iClientInZone[client][2]][client] > 0.0)
							Format(szRank, 64, "Rank: %i / %i", g_StyleMapRankBonus[style][g_iClientInZone[client][2]][client], g_iStyleBonusCount[style][g_iClientInZone[client][2]]);
						else
							if (g_iStyleBonusCount[style][g_iClientInZone[client][2]] > 0)
								Format(szRank, 64, "Rank: - / %i", g_iStyleBonusCount[style][g_iClientInZone[client][2]]);
							else
								Format(szRank, 64, "Rank: N/A");
					}
				}
				else // if in normal map, get normal times
				{
					if(g_iCurrentStyle[client] == 0) // Normal
					{
						if (g_fPersonalRecord[client] > 0.0)
							Format(szRank, 64, "Rank: %i / %i", g_MapRank[client], g_MapTimesCount);
						else
							if (g_MapTimesCount > 0)
								Format(szRank, 64, "Rank: - / %i", g_MapTimesCount);
							else
								Format(szRank, 64, "Rank: N/A");
					}
					else if(g_iCurrentStyle[client] != 0) // styles
					{
						if (g_fPersonalStyleRecord[style][client] > 0.0)
							Format(szRank, 64, "Rank: %i / %i", g_StyleMapRank[style][client], g_StyleMapTimesCount[style]);
						else
							if (g_StyleMapTimesCount[style] > 0)
								Format(szRank, 64, "Rank: - / %i", g_StyleMapTimesCount[style]);
							else
								Format(szRank, 64, "Rank: N/A");
					}
				}

				Format(szModule[i], 256, "%s\n%s", szPB, szRank);

				if ((i + 1) != moduleCount)
					Format(szModule[i], 256, "%s\n \n", szModule[i]);
			}
			else if (g_iSideHudModule[client][i] == 4)
			{
				int stage = g_Stage[g_iClientInZone[client][2]][client];

				// Stage Display
				char szStage[64];
				if (g_iClientInZone[client][2] == 0)
				{
					if (!g_bhasStages) // map is linear
					{
						//Format(szStage, 64, "Linear Map");
						char szCP[64];
						char szCurrentCP[64];
						if (g_iCurrentCheckpoint[client] == g_mapZonesTypeCount[g_iClientInZone[client][2]][4])
						{
							FormatTimeFloat(0, g_fRecordMapTime, 3, szCP, 64);
							Format(szCurrentCP, 64, "End Zone");
						}
						else
						{
							Format(szCurrentCP, 64, "Checkpoint [%i]", g_iCurrentCheckpoint[client] + 1);
							FormatTimeFloat(0, g_fCheckpointServerRecord[g_iClientInZone[client][2]][g_iCurrentCheckpoint[client]], 3, szCP, 64);
						}

						Format(szModule[i], 256, "%s\n%s", szCurrentCP, szCP);

						if ((i + 1) != moduleCount)
							Format(szModule[i], 256, "%s\n \n", szModule[i]);
					}
					else // map has stages
					{
						Format(szStage, 64, "Stage %i / %i", g_Stage[g_iClientInZone[client][2]][client], (g_mapZonesTypeCount[g_iClientInZone[client][2]][3] + 1));
						char szWrcpTime[64];
						FormatTimeFloat(0, g_fStageRecord[stage], 3, szWrcpTime, 64);
						char szName[64];
						Format(szName, 64, "%s", g_szStageRecordPlayer[stage]);
						Format(szModule[i], 256, "%s\nWRCP: %s\nby %s", szStage, szWrcpTime, szName);

						if ((i + 1) != moduleCount)
							Format(szModule[i], 256, "%s\n \n", szModule[i]);
					}
				}
				else
				{
					//Format(szStage, 64, "Bonus %i", g_iClientInZone[client][2]);
					Format(szModule[i], 256, "", szStage);
				}

			}
			else if (g_iSideHudModule[client][i] == 5)
			{
				char sSpecs[512];
				char szSpecList[512];
				int SpecMode;
				Format(sSpecs, 512, "");
				Format(szSpecList, 512, "Specs (0)");
				int count = 0;
				for (int j = 0; j <= MaxClients; j++)
				{
					if (IsValidClient(j) && !IsFakeClient(client) && !IsPlayerAlive(j) && !g_bFirstTeamJoin[j] && g_bSpectate[j])
					{
						SpecMode = GetEntProp(j, Prop_Send, "m_iObserverMode");
						if (SpecMode == 4 || SpecMode == 5)
						{
							int Target;
							Target = GetEntPropEnt(j, Prop_Send, "m_hObserverTarget");
							if (Target == client)
							{
								count++;
								if (count < 6)
									Format(sSpecs, 512, "%s%N\n", sSpecs, j);

							}
							if (count == 6)
								Format(sSpecs, 512, "%s...", sSpecs);
						}
					}
				}
				if (count > 0)
					Format(szSpecList, 512, "Specs (%i):\n%s ", count, sSpecs);
				else
					Format(szSpecList, 512, "Specs (0)");

				Format(szModule[i], 256, "%s", szSpecList);

				if ((i + 1) != moduleCount)
					Format(szModule[i], 256, "%s\n \n", szModule[i]);
			}
		}

		Format(szPanel, sizeof(szPanel), "%s%s%s%s%s", szModule[0], szModule[1], szModule[2], szModule[3], szModule[4]);
		Handle panel = CreatePanel();
		DrawPanelText(panel, szPanel);

		SendPanelToClient(panel, client, PanelHandler, 1);
		CloseHandle(panel);
	}
}

public void Checkpoint(int client, int zone, int zonegroup, float time)
{
	if (!IsValidClient(client) || g_bPositionRestored[client] || IsFakeClient(client) || zone >= CPLIMIT)
		return;

	//float time = g_fCurrentRunTime[client];
	float percent = -1.0;
	int totalPoints = 0;
	char szPercnt[24];
	char szSpecMessage[512];

	if (g_bhasStages) // If staged map
		totalPoints = g_mapZonesTypeCount[zonegroup][3];
	else
		if (g_mapZonesTypeCount[zonegroup][4] > 0) // If Linear Map and checkpoints
		totalPoints = g_mapZonesTypeCount[zonegroup][4];

	// Count percent of completion
	percent = (float(zone + 1) / float(totalPoints + 1));
	percent = percent * 100.0;
	Format(szPercnt, 24, "%1.f%%", percent);

	if (g_bTimeractivated[client] && !g_bPracticeMode[client]) {
		if (g_fMaxPercCompleted[client] < 1.0) // First time a checkpoint is reached
			g_fMaxPercCompleted[client] = percent;
		else
			if (g_fMaxPercCompleted[client] < percent) // The furthest checkpoint reached
			g_fMaxPercCompleted[client] = percent;
	}

	g_fCheckpointTimesNew[zonegroup][client][zone] = time;


	// Server record difference
	char sz_srDiff[128];
	char sz_srDiff_colorless[128];

	if (g_bCheckpointRecordFound[zonegroup] && g_fCheckpointServerRecord[zonegroup][zone] > 0.1 && g_bTimeractivated[client])
	{
		float f_srDiff = (g_fCheckpointServerRecord[zonegroup][zone] - time);

		FormatTimeFloat(client, f_srDiff, 3, sz_srDiff, 128);

		if (f_srDiff > 0)
		{
			Format(sz_srDiff_colorless, 128, "-%s", sz_srDiff);
			Format(sz_srDiff, 128, "%c%cWR: %c-%s%c", YELLOW, WHITE, GREEN, sz_srDiff, YELLOW);
			if (zonegroup > 0)
				Format(g_szLastSRDifference[client], 64, "WR: <font color='#00ff00'>%s</font>", sz_srDiff_colorless);
			else
				Format(g_szLastSRDifference[client], 64, "WR: <font color='#00ff00'>%s</font>", sz_srDiff_colorless);

		}
		else
		{
			Format(sz_srDiff_colorless, 128, "+%s", sz_srDiff);
			Format(sz_srDiff, 128, "%c%cWR: %c+%s%c", YELLOW, WHITE, RED, sz_srDiff, YELLOW);
			if (zonegroup > 0)
				Format(g_szLastSRDifference[client], 64, "WR: <font color='#FF0000'>%s</font>", sz_srDiff_colorless);
			else if(g_iCurrentStyle[client] > 0)
				Format(g_szLastSRDifference[client], 64, "\tWR: <font color='#FF0000'>%s</font>", sz_srDiff_colorless);
			else
				Format(g_szLastSRDifference[client], 64, "WR: <font color='#FF0000'>%s</font>", sz_srDiff_colorless);
		}
		g_fLastDifferenceTime[client] = GetGameTime();
	}
	else
		Format(sz_srDiff, 128, "%c%cWR: %cN/A%c", YELLOW, WHITE, MOSSGREEN, WHITE);


	// Get client name for spectators
	char szName[MAX_NAME_LENGTH];
	GetClientName(client, szName, MAX_NAME_LENGTH);

	// Has completed the map before
	if (g_bCheckpointsFound[zonegroup][client] && g_bTimeractivated[client] && !g_bPracticeMode[client] && g_fCheckpointTimesRecord[zonegroup][client][zone] > 0.1)
	{
		// Set percent of completion to assist
		if (CS_GetMVPCount(client) < 1)
			CS_SetClientAssists(client, RoundToFloor(g_fMaxPercCompleted[client]));
		else
			CS_SetClientAssists(client, 100);

		// Own record difference
		float diff = (g_fCheckpointTimesRecord[zonegroup][client][zone] - time);
		char szDiff[32];
		char szDiff_colorless[32];

		FormatTimeFloat(client, diff, 3, szDiff, 32);

		// MOVE TO PB variable
		if (diff > 0)
		{
			Format(szDiff_colorless, 32, "-%s", szDiff);
			Format(szDiff, sizeof(szDiff), "%c-%s", GREEN, szDiff);
			if (zonegroup > 0)
				Format(g_szLastPBDifference[client], 64, "PB: <font color='#00ff00'>%s</font>", szDiff_colorless);
			else
				Format(g_szLastPBDifference[client], 64, "PB: <font color='#00ff00'>%s</font>", szDiff_colorless);

			/*
			if (zonegroup > 0)
				Format(g_szLastPBDifference[client], 64, "%s <font color='#99ff99' size='16'>%s</font>", g_szPersonalRecordBonus[zonegroup][client], szDiff_colorless);
			else
				Format(g_szLastPBDifference[client], 64, "%s <font color='#99ff99' size='16'>%s</font>", g_szPersonalRecord[client], szDiff_colorless);
				*/
		}
		else
		{
			Format(szDiff_colorless, 32, "+%s", szDiff);
			Format(szDiff, sizeof(szDiff), "%c+%s", RED, szDiff);
			if (zonegroup > 0)
				Format(g_szLastPBDifference[client], 64, "PB: <font color='#FF0000'>%s</font>", szDiff_colorless);
			else
				Format(g_szLastPBDifference[client], 64, "PB: <font color='#FF0000'>%s</font>", szDiff_colorless);
			/*
			if (zonegroup > 0)
				Format(g_szLastPBDifference[client], 64, "%s <font color='#FF9999' size='16'>%s</font>", g_szPersonalRecordBonus[zonegroup][client], szDiff_colorless);
			else
				Format(g_szLastPBDifference[client], 64, "%s <font color='#FF9999' size='16'>%s</font>", g_szPersonalRecord[client], szDiff_colorless);
				*/
		}
		g_fLastDifferenceTime[client] = GetGameTime();


		if (g_fCheckpointTimesRecord[zonegroup][client][zone] <= 0.0)
			Format(szDiff, 128, "");

		char szTime[32];
		FormatTimeFloat(client, time, 3, szTime, 32);

		if (g_bCheckpointsEnabled[client])
			PrintToChat(client, " %cSurftimer %c| %cCP [%i]:%c %c%s %c(%cPB: %s%c - %s%c)", LIMEGREEN, WHITE, WHITE, g_iClientInZone[client][1] + 1, WHITE, LIMEGREEN, szTime, WHITE, WHITE, szDiff, WHITE, sz_srDiff, WHITE);

		Format(szSpecMessage, sizeof(szSpecMessage), " %cSurftimer %c| %c%s %c| %cCP [%i]:%c %c%s %c(%cPB: %s%c - %s%c)", LIMEGREEN, WHITE, YELLOW, szName, WHITE, WHITE, g_iClientInZone[client][1] + 1, WHITE, LIMEGREEN, szTime, WHITE, YELLOW, szDiff, WHITE, sz_srDiff, WHITE);
		CheckpointToSpec(client, szSpecMessage);

		// Saving difference time for next checkpoint
		tmpDiff[client] = diff;
	}
	else // if first run
		if (g_bTimeractivated[client] && !g_bPracticeMode[client])
		{
			// Set percent of completion to assist
			if (CS_GetMVPCount(client) < 1)
				CS_SetClientAssists(client, RoundToFloor(g_fMaxPercCompleted[client]));
			else
				CS_SetClientAssists(client, 100);

			char szTime[32];
			FormatTimeFloat(client, time, 3, szTime, 32);

			if (percent > -1.0)
			{
				if (g_bCheckpointsEnabled[client])
					PrintToChat(client, " %cSurftimer %c| %cCP [%i]:%c %c%s %c(%cPB: %cN/A%c | %s%c)", LIMEGREEN, WHITE, WHITE, g_iClientInZone[client][1] + 1, WHITE, LIMEGREEN, szTime, WHITE, WHITE, MOSSGREEN, WHITE, sz_srDiff, WHITE);

				Format(szSpecMessage, sizeof(szSpecMessage), " %cSurftimer %c| %c%s %c| %cCP [%i]:%c %c%s %c(%cPB: %cN/A%c | %s%c)", LIMEGREEN, WHITE, YELLOW, szName, WHITE, WHITE, g_iClientInZone[client][1] + 1, WHITE, LIMEGREEN, szTime, WHITE, YELLOW, MOSSGREEN, WHITE, sz_srDiff, WHITE);
				CheckpointToSpec(client, szSpecMessage);
			}
		}
}

public void CheckpointToSpec(int client, char[] buffer)
{
	int SpecMode;
	for (int x = 1; x <= MaxClients; x++)
	{
		if (IsValidClient(x) && !IsPlayerAlive(x))
		{
			SpecMode = GetEntProp(x, Prop_Send, "m_iObserverMode");
			if (SpecMode == 4 || SpecMode == 5)
			{
				int Target = GetEntPropEnt(x, Prop_Send, "m_hObserverTarget");
				if (Target == client)
					PrintToChat(x, "%s", buffer);
			}
		}
	}
}

public void ResetGravity(int client)
{
	if (IsValidClient(client) && !IsFakeClient(client))
	{
		float gravity = GetEntityGravity(client);
		if (g_iCurrentStyle[client] != 4)
		{
			if(gravity != 1.0)
				SetEntityGravity(client, 1.0);
		}
		else
			SetEntityGravity(client, 0.5);
	}
}

stock void StyleFinishedMsgs(int client, int style)
{
	if (IsValidClient(client))
	{
		char szName[MAX_NAME_LENGTH];
		GetClientName(client, szName, MAX_NAME_LENGTH);
		int count = g_StyleMapTimesCount[style];

		if (GetConVarInt(g_hAnnounceRecord) == 0 || GetConVarInt(g_hAnnounceRecord) == 1)
		{
			for (int i = 1; i <= GetMaxClients(); i++)
			{
				if (IsValidClient(i) && !IsFakeClient(i))
				{
					if (g_bStyleMapFirstRecord[style][client]) // 1st time finishing
					{
						PrintToChat(i, " %cSurftimer %c| %c%s%c finished the %cmap %c%s %cwith a time of (%c%s%c). %c[rank %c#%i%c/%i | record %c%s%c", LIMEGREEN, WHITE, LIMEGREEN, szName, GRAY, DARKBLUE, LIGHTRED, g_szStyleFinishPrint[style], GRAY, LIMEGREEN, g_szFinalTime[client], GRAY, WHITE, LIMEGREEN, g_StyleMapRank[style][client], WHITE, count, LIMEGREEN, g_szRecordStyleMapTime[style], WHITE);
					}
					else
					if (g_bStyleMapPBRecord[style][client]) // Own record
					{
						PlayUnstoppableSound(client);
						PrintToChat(i, " %cSurftimer %c| %c%s%c finished the %cmap %c%s %cwith a time of (%c%s%c). Improving their best time by (%c%s%c). %c[rank %c#%i%c/%i | record %c%s%c]", LIMEGREEN, WHITE, LIMEGREEN, szName, GRAY, DARKBLUE, LIGHTRED, g_szStyleFinishPrint[style], GRAY, LIMEGREEN, g_szFinalTime[client], GRAY, GREEN, g_szTimeDifference[client], GRAY, WHITE, LIMEGREEN, g_StyleMapRank[style][client], WHITE, count, LIMEGREEN, g_szRecordStyleMapTime[style], WHITE);
					}

					if (g_bStyleMapSRVRecord[style][client])
					{
						//int r = GetRandomInt(1, 2);
						PlayRecordSound(2);
						PrintToChat(i, " %cSurftimer %c| %c%s%c has beaten the %c%s %cMAP RECORD", LIMEGREEN, WHITE, LIMEGREEN, szName, GRAY, LIGHTRED, g_szStyleRecordPrint[style], DARKBLUE);
					}
				}
			}
		}
		else if (GetConVarInt(g_hAnnounceRecord) == 2)
		{
			for (int i = 1; i <= GetMaxClients(); i++)
			{
				if (g_bStyleMapSRVRecord[style][client])
				{
					//int r = GetRandomInt(1, 2);
					PlayRecordSound(2);
					PrintToChat(i, " %cSurftimer %c| %c%s%c has beaten the %c%s %cMAP RECORD", LIMEGREEN, WHITE, LIMEGREEN, szName, GRAY, LIGHTRED, g_szStyleRecordPrint[style], DARKBLUE);
				}
			}
		}
		if (g_StyleMapRank[style][client] == 99999 && IsValidClient(client))
		PrintToChat(client, " %cSurftimer %c| %cFailed to save your data correctly! Please contact an admin.", LIMEGREEN, WHITE, DARKRED, RED, DARKRED);
		return;
	}
}

stock void PrintChatBonusStyle (int client, int zGroup, int style, int rank = 0)
{
	if (!IsValidClient(client))
	return;

	float RecordDiff;
	char szRecordDiff[54], szName[MAX_NAME_LENGTH];

	if (rank == 0)
	rank = g_StyleMapRankBonus[style][zGroup][client];

	GetClientName(client, szName, MAX_NAME_LENGTH);
	if (g_bBonusSRVRecord[client])
	{
		//int i = GetRandomInt(1, 2);
		PlayRecordSound(2);

		RecordDiff = g_fStyleOldBonusRecordTime[style][zGroup] - g_fFinalTime[client];
		FormatTimeFloat(client, RecordDiff, 3, szRecordDiff, 54);
		Format(szRecordDiff, 54, "-%s", szRecordDiff);
	}
	if (g_bBonusFirstRecord[client] && g_bBonusSRVRecord[client])
	{
		PrintToChatAll(" %cSurftimer %c| %c%s has beaten the %c%s %c%s RECORD", LIMEGREEN, WHITE, LIMEGREEN, szName, LIGHTRED, g_szStyleRecordPrint[style], ORANGE, g_szZoneGroupName[zGroup]);
		if (g_tmpBonusCount[zGroup] == 0)
			PrintToChatAll(" %cSurftimer %c| %c%s %cfinished the %c%s %c%s %cwith a time of %c%s%c. [rank %c#1 %c/ 1 | record %c%s%c]", LIMEGREEN, WHITE, LIMEGREEN, szName, GRAY, LIGHTRED, g_szStyleFinishPrint[style], ORANGE, g_szZoneGroupName[zGroup], GRAY, LIMEGREEN, g_szFinalTime[client], GRAY, LIMEGREEN, WHITE, LIMEGREEN, g_szFinalTime[client], WHITE);
		else
			PrintToChatAll(" %cSurftimer %c| %c%s %cfinished the %c%s %c%s %cwith a time of %c%s%c. Improving the best time by %c%s%c. [rank %c#%i %c/%i | record %c%s%c]", LIMEGREEN, WHITE, LIMEGREEN, szName, GRAY, LIGHTRED, g_szStyleFinishPrint[style], ORANGE, g_szZoneGroupName[zGroup], GRAY, LIMEGREEN, g_szFinalTime[client], GRAY, LIMEGREEN, szRecordDiff, GRAY, LIMEGREEN, g_StyleMapRankBonus[style][zGroup][client], GRAY, g_iStyleBonusCount[style][zGroup], LIMEGREEN, g_szFinalTime[client], WHITE);
	}
	if (g_bBonusPBRecord[client] && g_bBonusSRVRecord[client])
	{
		PrintToChatAll(" %cSurftimer %c| %c%s has beaten the %c%s %c%s RECORD", LIMEGREEN, WHITE, LIMEGREEN, szName, LIGHTRED, g_szStyleRecordPrint[style], ORANGE, g_szZoneGroupName[zGroup]);
		PrintToChatAll(" %cSurftimer %c| %c%s %cfinished the %c%s %c%s %cwith a time of %c%s%c. Improving the best time by %c%s%c. [rank %c#%i %c/%i | record %c%s%c]", LIMEGREEN, WHITE, LIMEGREEN, szName, GRAY,LIGHTRED, g_szStyleFinishPrint[style], ORANGE, g_szZoneGroupName[zGroup], GRAY, LIMEGREEN, g_szFinalTime[client], GRAY, LIMEGREEN, szRecordDiff, GRAY, LIMEGREEN, g_StyleMapRankBonus[style][zGroup][client], GRAY, g_iStyleBonusCount[style][zGroup], LIMEGREEN, g_szFinalTime[client], WHITE);
	}
	if (g_bBonusPBRecord[client] && !g_bBonusSRVRecord[client])
	{
		PlayUnstoppableSound(client);
		PrintToChatAll(" %cSurftimer %c| %c%s %cfinished the %c%s %c%s %cwith a time of %c%s%c. Improving their best time by %c%s%c. [rank %c#%i/%c%i | record %c%s%c]", LIMEGREEN, WHITE, LIMEGREEN, szName, GRAY,LIGHTRED, g_szStyleFinishPrint[style], ORANGE, g_szZoneGroupName[zGroup], GRAY, LIMEGREEN, g_szFinalTime[client], GRAY, LIMEGREEN, g_szBonusTimeDifference[client], GRAY, LIMEGREEN, g_StyleMapRankBonus[style][zGroup][client], GRAY, g_iStyleBonusCount[style][zGroup], LIMEGREEN, g_szStyleBonusFastestTime[style][zGroup], WHITE);
	}
	if (g_bBonusFirstRecord[client] && !g_bBonusSRVRecord[client])
	{
		PrintToChatAll(" %cSurftimer %c| %c%s %cfinished the %c%s %c%s %cwith a time of %c%s%c. [rank %c#%i/%c%i | record %c%s%c]", LIMEGREEN, WHITE, LIMEGREEN, szName, GRAY,LIGHTRED, g_szStyleFinishPrint[style], ORANGE, g_szZoneGroupName[zGroup], GRAY, LIMEGREEN, g_szFinalTime[client], GRAY, LIMEGREEN, g_StyleMapRankBonus[style][zGroup][client], GRAY, g_iStyleBonusCount[style][zGroup], LIMEGREEN, g_szStyleBonusFastestTime[style][zGroup], WHITE);
	}
	if (!g_bBonusSRVRecord[client] && !g_bBonusFirstRecord[client] && !g_bBonusPBRecord[client])
	{
		PrintToChatAll(" %cSurftimer %c| %c%s %cfinished the %c%s %c%s %cwith a time of %c%s%c. Missing their best time by %c%s%c. [rank %c#%i/%c%i | record %c%s%c]", LIMEGREEN, WHITE, LIMEGREEN, szName, GRAY, LIGHTRED, g_szStyleFinishPrint[style], ORANGE, g_szZoneGroupName[zGroup], GRAY, RED, g_szFinalTime[client], GRAY, RED, g_szBonusTimeDifference[client], GRAY, LIMEGREEN, g_StyleMapRankBonus[style][zGroup][client], GRAY, g_iStyleBonusCount[style][zGroup], LIMEGREEN, g_szStyleBonusFastestTime[style][zGroup], GRAY);
	}

	CheckBonusStyleRanks(client, zGroup, style);
	if (rank == 9999999 && IsValidClient(client))
	PrintToChat(client, " %cSurftimer %c| %cFailed to save your data correctly! Please contact an admin.", LIMEGREEN, WHITE, DARKRED, RED, DARKRED);

	return;
}

public void CheckBonusStyleRanks(int client, int zGroup, int style)
{
	// if client has risen in rank,
	if (g_StyleOldMapRankBonus[style][zGroup][client] > g_StyleMapRankBonus[style][zGroup][client])
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i) && i != client)
			{  //if clients rank used to be bigger than i's, 2nd: clients new rank is at least as big as i's
				if (g_StyleOldMapRankBonus[style][zGroup][client] > g_StyleMapRankBonus[style][zGroup][i] && g_StyleMapRankBonus[style][zGroup][client] <= g_StyleMapRankBonus[style][zGroup][i])
					g_StyleMapRankBonus[style][zGroup][i]++;
			}
		}
	}
}

// Streamline Logging jakeey802
/*public Action Commands_CommandListener(int client, const char[] command, any argc)
{
	char gz_sCmdString[256];
	GetCmdArgString(gz_sCmdString, sizeof(gz_sCmdString));
	LogToFileEx(g_sStreamlineLogs, "%L used: %s %s", client, command, gz_sCmdString);
	return Plugin_Continue;
}*/

public void GetSpeedColour(int client, int speed, int type)
{
	int pos;
	if (g_fMaxVelocity == 10000.0)
	{
		if (type == 1 && g_SpeedMode[client] == 0) // green
		{
			pos = RoundToFloor(speed / 400.0);
			if (pos > 24)
				pos = 24;
			Format(g_szSpeedColour[client], sizeof(g_szSpeedColour), g_sz10000mvGradient[pos]);
		}
		else if (type == 2 && g_SpeedMode[client] == 0) // rainbow
		{
			pos = RoundToFloor(speed / 500.0);
			if (pos > 7)
				pos = 7;
			Format(g_szSpeedColour[client], sizeof(g_szSpeedColour), g_szRainbowGradient[pos]);
		}
		else if (type == 3 && g_SpeedMode[client] == 0) // gain/loss
		{
			if (speed >= GetConVarInt(g_hMaxVelocity))
				Format(g_szSpeedColour[client], sizeof(g_szSpeedColour), "#a300ff");
			else if (g_iPreviousSpeed[client] < speed || g_iPreviousSpeed[client] == speed)
				Format(g_szSpeedColour[client], sizeof(g_szSpeedColour), "#66bbff");
			else
				Format(g_szSpeedColour[client], sizeof(g_szSpeedColour), "#ff7d7d");
			
			g_iPreviousSpeed[client] = speed;
		}
		else
			Format(g_szSpeedColour[client], sizeof(g_szSpeedColour), "#ffffff");
	}
	else
	{
		if (type == 1 && g_SpeedMode[client] == 0) // green
		{
			pos = RoundToFloor(speed / 100.0);
			if (pos > 34)
				pos = 34;
			Format(g_szSpeedColour[client], sizeof(g_szSpeedColour), g_sz3500mvGradient[pos]);
		}
		else if (type == 2 && g_SpeedMode[client] == 0) // rainbow
		{
			pos = RoundToFloor(speed / 500.0);
			if (pos > 7)
				pos = 7;

			Format(g_szSpeedColour[client], sizeof(g_szSpeedColour), g_szRainbowGradient[pos]);
		}
		else if (type == 3 && g_SpeedMode[client] == 0) // gain/loss
		{
			if (speed >= GetConVarInt(g_hMaxVelocity))
				Format(g_szSpeedColour[client], sizeof(g_szSpeedColour), "#a300ff");
			else if (g_iPreviousSpeed[client] < speed || g_iPreviousSpeed[client] == speed)
				Format(g_szSpeedColour[client], sizeof(g_szSpeedColour), "#66bbff");
			else
				Format(g_szSpeedColour[client], sizeof(g_szSpeedColour), "#ff7d7d");
			
			g_iPreviousSpeed[client] = speed;
		}
		else
			Format(g_szSpeedColour[client], sizeof(g_szSpeedColour), "#ffffff");
	}
}

public void getColourName(int client, char[] buffer, int length, int colour)
{
	switch (colour)
	{
		case 0: Format(buffer, length, "White");
		case 1: Format(buffer, length, "Dark Red");
		case 2: Format(buffer, length, "Green");
		case 3: Format(buffer, length, "Limegreen");
		case 4: Format(buffer, length, "Blue");
		case 5: Format(buffer, length, "Mossgreen");
		case 6: Format(buffer, length, "Red");
		case 7: Format(buffer, length, "Grey");
		case 8: Format(buffer, length, "Yellow");
		case 9: Format(buffer, length, "Lightblue");
		case 10: Format(buffer, length, "Darkblue");
		case 11: Format(buffer, length, "Pink");
		case 12: Format(buffer, length, "Light Red");
		case 13: Format(buffer, length, "Purple");
		case 14: Format(buffer, length, "Dark Grey");
		case 15: Format(buffer, length, "Orange");
	}

	return;
}

public void diffForHumans(int unix, char[] buffer, int size, int type)
{
	int years, months, days, hours, mins, secs;
	if (type == 0)
	{
		if (unix > 31535999)
		{
			years = unix / 60 / 60 / 24 / 365;
			Format(buffer, size, "%d year%s ago", years, years==1?"":"s");
		}
		if (unix > 2591999)
		{
			months = unix / 60 / 60 / 24 / 30;
			Format(buffer, size, "%d month%s ago", months, months==1?"":"s");
		}
		if (unix > 86399)
		{
			days = unix / 60 / 60 / 24;
			hours = unix / 3600 % 60;
			mins = unix / 60 % 60;
			secs = unix % 60;
			Format(buffer, size, "%d day%s ago", days, days==1?"":"s");
		}
		else if (unix > 3599)
		{
			hours = unix / 3600 % 60;
			mins = unix / 60 % 60;
			secs = unix % 60;
			Format(buffer, size, "%d hour%s %d minute%s %d second%s ago", hours, hours==1?"":"s", mins, mins==1?"":"s", secs, secs==1?"":"s");
		}
		else if (unix > 59)
		{
			mins = unix / 60 % 60;
			secs = unix % 60;
			Format(buffer, size, "%d minute%s %d second%s ago", mins, mins==1?"":"s", secs, secs==1?"":"s");
		}
		else
		{
			secs = unix;
			Format(buffer, size, "%d second%s ago", secs, secs==1?"":"s");
		}
	}
	else if (type == 1)
	{
		if (unix > 31535999)
		{
			years = unix / 60 / 60 / 24 / 365;
			Format(buffer, size, "%d year%s ago", years, years==1?"":"s");
		}
		if (unix > 2591999)
		{
			months = unix / 60 / 60 / 24 / 30;
			Format(buffer, size, "%d month%s ago", months, months==1?"":"s");
		}
		if (unix > 86399)
		{
			days = unix / 60 / 60 / 24;
			Format(buffer, size, "%d day%s ago", days, days==1?"":"s");
		}
		else if (unix > 3599)
		{
			hours = unix / 3600 % 60;
			Format(buffer, size, "%d hour%s ago", hours, hours==1?"":"s");
		}
		else if (unix > 59)
		{
			mins = unix / 60 % 60;
			Format(buffer, size, "%d minute%s ago", mins, mins==1?"":"s");
		}
		else
		{
			secs = unix;
			Format(buffer, size, "%d second%s ago", secs, secs==1?"":"s");
		}
	}
}

public void totalTimeForHumans(int unix, char[] buffer, int size)
{
	int years, months, days, hours, mins, secs;
	if (unix > 31535999)
	{
		years = unix / 60 / 60 / 24 / 365;
		months = unix / 60 / 60 / 24 / 30;
		days = unix / 60 / 60 / 24;
		hours = unix / 3600 % 60;
		mins = unix / 60 % 60;
		secs = unix % 60;
		Format(buffer, size, "%d year%s %d month%s %d day%s %d hour%s %d minute%s %d second%s", years, years==1?"":"s", months, months==1?"":"s", days, days==1?"":"s", hours, hours==1?"":"s", mins, mins==1?"":"s", secs, secs==1?"":"s");
	}
	if (unix > 2591999)
	{
		months = unix / 60 / 60 / 24 / 30;
		days = unix / 60 / 60 / 24;
		hours = unix / 3600 % 60;
		mins = unix / 60 % 60;
		secs = unix % 60;
		Format(buffer, size, "%d month%s %d day%s %d hour%s %d minute%s %d second%s", months, months==1?"":"s", days, days==1?"":"s", hours, hours==1?"":"s", mins, mins==1?"":"s", secs, secs==1?"":"s");
	}
	if (unix > 86399)
	{
		days = unix / 60 / 60 / 24;
		hours = unix / 3600 % 60;
		mins = unix / 60 % 60;
		secs = unix % 60;
		Format(buffer, size, "%d day%s %d hour%s %d minute%s %d second%s", days, days==1?"":"s", hours, hours==1?"":"s", mins, mins==1?"":"s", secs, secs==1?"":"s");
	}
	else if (unix > 3599)
	{
		hours = unix / 3600 % 60;
		mins = unix / 60 % 60;
		secs = unix % 60;
		Format(buffer, size, "%d hour%s %d minute%s %d second%s", hours, hours==1?"":"s", mins, mins==1?"":"s", secs, secs==1?"":"s");
	}
	else if (unix > 59)
	{
		mins = unix / 60 % 60;
		secs = unix % 60;
		Format(buffer, size, "%d minute%s %d second%s", mins, mins==1?"":"s", secs, secs==1?"":"s");
	}
	else
	{
		secs = unix;
		Format(buffer, size, "%d second%s", secs, secs==1?"":"s");
	}
}

public void sendDiscordAnnouncement(char szName[32], char szMapName[128], char szTime[32])
{
	char webhook[1024];
	GetConVarString(g_hRecordAnnounceDiscord, webhook, 1024);
	if (StrEqual(webhook, ""))
		return;
	// Send Discord Announcement
	DiscordWebHook hook = new DiscordWebHook(webhook);
	hook.SlackMode = true;
	
	hook.SetUsername("Surftimer Records");
	
	MessageEmbed Embed = new MessageEmbed();

	// Get a random colour for the.. left colour
	int hex = GetRandomInt(0, 6);
	switch (hex)
	{
		case 0: Embed.SetColor("#ff0000");
		case 1: Embed.SetColor("#ff7F00");
		case 2: Embed.SetColor("#ffD700");
		case 3: Embed.SetColor("#00aa00");
		case 4: Embed.SetColor("#0000ff");
		case 5: Embed.SetColor("#6600ff");
		case 6: Embed.SetColor("#8b00ff");
		default: Embed.SetColor("#ff0000");
	}

	Embed.SetTitle("**NEW MAP RECORD**");

	// Format the msg
	char szMessage[256];

	Format(szMessage, sizeof(szMessage), "%s has beaten the %s map record in the %s server with a time of %s", szName, szMapName, g_sServerName, szTime);

	// Get a random emoji
	int emoji = GetRandomInt(0, 3);
	char szEmoji[128];
	switch (emoji)
	{
		case 0: Format(szEmoji, sizeof(szEmoji), ":ok_hand: :ok_hand: :ok_hand: :ok_hand: :ok_hand:");
		case 1: Format(szEmoji, sizeof(szEmoji), ":thinking: :thinking: :thinking: :thinking: :thinking:");
		case 2: Format(szEmoji, sizeof(szEmoji), ":fire: :fire: :fire: :fire: :fire:");
		case 3: Format(szEmoji, sizeof(szEmoji), ":scream: :scream: :scream: :scream: :scream:");
		default: Format(szEmoji, sizeof(szEmoji), ":ok_hand: :ok_hand: :ok_hand: :ok_hand: :ok_hand:");
	}

	Embed.AddField(szEmoji, szMessage, false);
					
	hook.Embed(Embed);
	hook.Send();
	delete hook;
}

bool IsPlayerVip(int client, int vip, bool admin = true, bool reply = true)
{
	if (admin)
	{
		if (CheckCommandAccess(client, "", ADMFLAG_GENERIC))
			return true;
	}

	if (g_iVipLvl[client] < vip)
	{
		if (reply)
		{
			if (vip == 2)
			{
				PrintToChat(client, " %cSurftimer %c| This is a Super VIP feature", LIMEGREEN, WHITE);
				PrintToConsole(client, "surftimer | This is a Super VIP feature");
			}
			else if (vip == 3)
			{
				PrintToChat(client, " %cSurftimer %c| This is a Superior VIP feature", LIMEGREEN, WHITE);
				PrintToConsole(client, "surftimer | This is a Superior VIP feature");
			}
			else
			{
				PrintToChat(client, " %cSurftimer %c| This is a VIP feature", LIMEGREEN, WHITE);
				PrintToConsole(client, "surftimer | This is a VIP feature");
			}
		}
		return false;
	}
	
	return true;
}

public float GetStrafeSync(int client, bool sync)
{
	// Strafe sync taken from shavit's bhop timer
	return view_as<float>((sync)? (g_iGoodGains[client] == 0)? 100.0:(g_iGoodGains[client] / float(g_iTotalMeasures[client]) * 100.0):-1.0);
}

public void ResetSaveLocs()
{
	g_iSaveLocCount = 0;
	for (int i = 0; i < MAX_LOCS; i++)
	{
		for (int j = 0; j < 3; j++)
		{
			g_fSaveLocCoords[i][j] = 0.0;
			g_fSaveLocAngle[i][j] = 0.0;
			g_fSaveLocVel[i][j] = 0.0;
		}
		g_iSaveLocUnix[i] = 0;
		g_szSaveLocTargetname[i][0] = '\0';
	}
}

public void TeleportToSaveloc(int client, int id)
{
	g_iLastSaveLocIdClient[client] = id;
	ResetGravity(client);
	g_bPracticeMode[client] = true;
	g_bWrcpTimeractivated[client] = false;
	CL_OnStartTimerPress(client);
	DispatchKeyValue(client, "targetname", g_szSaveLocTargetname[id]);
	SetEntPropVector(client, Prop_Data, "m_vecVelocity", view_as<float>( { 0.0, 0.0, 0.0 } ));
	TeleportEntity(client, g_fSaveLocCoords[id], g_fSaveLocAngle[id], g_fSaveLocVel[id]);
}

public void SendBugReport(int client)
{
	char webhook[1024];
	GetConVarString(g_hReportBugsDiscord, webhook, 1024);
	if (StrEqual(webhook, ""))
		return;

	// Send Discord Announcement
	DiscordWebHook hook = new DiscordWebHook(webhook);
	hook.SlackMode = true;
	
	hook.SetUsername("Surftimer Bugtracker");
	
	MessageEmbed Embed = new MessageEmbed();

	// Format title
	char sTitle[256];
	Format(sTitle, sizeof(sTitle), "Bug Type: %s || Server: %s || Map: %s", g_sBugType[client], g_sServerName, g_szMapName);
	Embed.SetTitle(sTitle);

	// Format player
	char sName[MAX_NAME_LENGTH];
	GetClientName(client, sName, sizeof(sName));

	// Format msg
	char sMessage[512];
	Format(sMessage, sizeof(sMessage), "%s (%s): %s", sName, g_szSteamID[client], g_sBugMsg[client]);
	Embed.AddField("", sMessage, true);
					
	hook.Embed(Embed);
	hook.Send();
	delete hook;
	
	PrintToChat(client, " %cSurftimer %c| Bug report sent", LIMEGREEN, WHITE);
}

public void CallAdmin(int client, char[] sText)
{
	char webhook[1024];
	GetConVarString(g_hCalladminDiscord, webhook, 1024);
	if (StrEqual(webhook, ""))
		return;

	// Send Discord Announcement
	DiscordWebHook hook = new DiscordWebHook(webhook);
	hook.SlackMode = true;
	
	hook.SetUsername("Surftimer Calladmin");
	
	MessageEmbed Embed = new MessageEmbed();

	// Format title
	char sTitle[256];
	Format(sTitle, sizeof(sTitle), "Server: %s || Map: %s", g_sServerName, g_szMapName);
	Embed.SetTitle(sTitle);

	// Format player
	char sName[MAX_NAME_LENGTH];
	GetClientName(client, sName, sizeof(sName));

	// Format msg
	char sMessage[512];
	Format(sMessage, sizeof(sMessage), "%s (%s): %s", sName, g_szSteamID[client], sText);
	Embed.AddField("", sMessage, true);
					
	hook.Embed(Embed);
	hook.Send();
	delete hook;
	
	PrintToChat(client, " %cSurftimer %c| Report sent", LIMEGREEN, WHITE);
}