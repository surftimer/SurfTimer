/*=========================================================
=                    CS:GO SurfTimer                      =
=       modified version of "SurfTimer" from fluffy       =
= The original version of this timer was by jonitaikaponi =
=  https://forums.alliedmods.net/showthread.php?t=264498  =
=========================================================*/

/*====================================
=              Includes              =
====================================*/

#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <adminmenu>
#include <cstrike>
#include <geoip>
#include <basecomm>
#include <colorlib>
#include <autoexecconfig>
#include <regex>
#undef REQUIRE_EXTENSIONS
#include <clientprefs>
#undef REQUIRE_PLUGIN
#include <dhooks>
#include <mapchooser>
#include <surftimer>

// Require New Syntax & Semicolons
#pragma newdecls required
#pragma semicolon 1

// More dynamic array size
#pragma dynamic 2621440

/*====================================
=              Includes              =
====================================*/

#include "surftimer/globals.sp"
#include "surftimer/api.sp"
#include "surftimer/convars.sp"
#include "surftimer/misc.sp"
#include "surftimer/db/queries.sp"
#include "surftimer/db/updater.sp"
#include "surftimer/sql.sp"
#include "surftimer/admin.sp"
#include "surftimer/newmaps.sp"
#include "surftimer/commands.sp"
#include "surftimer/hooks.sp"
#include "surftimer/buttonpress.sp"
#include "surftimer/sqltime.sp"
#include "surftimer/timer.sp"
#include "surftimer/replay.sp"
#include "surftimer/surfzones.sp"
#include "surftimer/mapsettings.sp"
#include "surftimer/cvote.sp"
#include "surftimer/vip.sp"

/*====================================
=               Events               =
====================================*/

public void OnLibraryAdded(const char[] name)
{
	Handle tmp = FindPluginByFile("mapchooser_extended.smx");
	if ((StrEqual("mapchooser", name)) || (tmp != null && GetPluginStatus(tmp) == Plugin_Running))
		g_bMapChooser = true;
	if (tmp != null)
		CloseHandle(tmp);

	// botmimic 2
	if (StrEqual(name, "dhooks") && g_hTeleport == null)
	{
		// Optionally setup a hook on CBaseEntity::Teleport to keep track of sudden place changes
		Handle hGameData = LoadGameConfigFile("sdktools.games");
		if (hGameData == null)
			return;
		int iOffset = GameConfGetOffset(hGameData, "Teleport");
		CloseHandle(hGameData);
		if (iOffset == -1)
			return;

		g_hTeleport = DHookCreate(iOffset, HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity, DHooks_OnTeleport);
		if (g_hTeleport == null)
			return;
		DHookAddParam(g_hTeleport, HookParamType_VectorPtr);
		DHookAddParam(g_hTeleport, HookParamType_ObjectPtr);
		DHookAddParam(g_hTeleport, HookParamType_VectorPtr);
		if (GetEngineVersion() == Engine_CSGO)
			DHookAddParam(g_hTeleport, HookParamType_Bool);

		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i))
			{
				OnClientPutInServer(i);
			}
		}
	}
}

public void OnAllPluginsLoaded()
{
	if (!LibraryExists("endtouchfix"))
	{
		SetFailState("Plugin \"End-Touch-Fix\" not loaded!");
		return;
	}
}

public void OnPluginEnd()
{
	// remove clan tags
	for (int x = 1; x <= MaxClients; x++)
	{
		if (IsValidClient(x))
		{
			SetEntPropEnt(x, Prop_Send, "m_bSpotted", 1);
			SetEntProp(x, Prop_Send, "m_iHideHUD", 0);
			SetEntProp(x, Prop_Send, "m_iAccount", 1);
			if (g_hOverrideClantag.BoolValue)
				CS_SetClientClanTag(x, "");
			OnClientDisconnect(x);
		}
	}


	// set server convars back to default
	ServerCommand("sm_cvar sv_enablebunnyhopping 0;sv_friction 5.2;sv_accelerate 5.5;sv_airaccelerate 10;sv_maxvelocity 2000;sv_staminajumpcost .08;sv_staminalandcost .050");
	ServerCommand("mp_respawn_on_death_ct 0;mp_respawn_on_death_t 0;mp_respawnwavetime_ct 10.0;mp_respawnwavetime_t 10.0;bot_zombie 0;mp_ignore_round_win_conditions 0");
	ServerCommand("sv_infinite_ammo 0;mp_endmatch_votenextmap 1;mp_do_warmup_period 1;mp_warmuptime 60;mp_match_can_clinch 1;mp_match_end_changelevel 0");
	ServerCommand("mp_match_restart_delay 15;mp_endmatch_votenextleveltime 20;mp_endmatch_votenextmap 1;mp_halftime 0;mp_do_warmup_period 1;mp_maxrounds 0;bot_quota 0");
	ServerCommand("mp_startmoney 800; mp_playercashawards 1; mp_teamcashawards 1");
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "adminmenu"))
		g_hAdminMenu = null;
	if (StrEqual(name, "dhooks"))
		g_hTeleport = null;
}

public void OnEntityCreated(int entity, const char[] classname) {
	if( (classname[0] == 't' || classname[0] == 'l') ? (StrEqual(classname, "trigger_teleport", false) ) : false)
	{
		SDKHook(entity, SDKHook_Use, IgnoreTriggers);
		SDKHook(entity, SDKHook_StartTouch, IgnoreTriggers);
		SDKHook(entity, SDKHook_Touch, IgnoreTriggers);
		SDKHook(entity, SDKHook_EndTouch, IgnoreTriggers);
	}
}

public void OnMapStart()
{
	CreateTimer(30.0, EnableJoinMsgs, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE);

	// Get mapname
	GetCurrentMap(g_szMapName, 128);

	// Download map radar image if existing
	AddRadarImages();
	
	// Create nav file
	CreateNavFile();

	// Workshop fix
	char mapPieces[6][128];
	int lastPiece = ExplodeString(g_szMapName, "/", mapPieces, sizeof(mapPieces), sizeof(mapPieces[]));
	Format(g_szMapName, sizeof(g_szMapName), "%s", mapPieces[lastPiece - 1]);

	// Debug Logging
	if (!DirExists("addons/sourcemod/logs/surftimer"))
		CreateDirectory("addons/sourcemod/logs/surftimer", 511);
	BuildPath(Path_SM, g_szLogFile, sizeof(g_szLogFile), "logs/surftimer/%s.log", g_szMapName);

	// Get map maxvelocity
	g_hMaxVelocity = FindConVar("sv_maxvelocity");

	// Load spawns
	if (!g_bRenaming && !g_bInTransactionChain)
	{
		checkSpawnPoints();
	}

	db_viewMapSettings();

	/// Start Loading Server Settings
	ConVar cvHibernateWhenEmpty = FindConVar("sv_hibernate_when_empty");
	
	if(g_tables_converted)
	{
		if (!g_bRenaming && !g_bInTransactionChain && (IsServerProcessing() || !cvHibernateWhenEmpty.BoolValue))
		{
			LogQueryTime("[surftimer] Starting to load server settings");
			g_fServerLoading[0] = GetGameTime();
			db_selectMapZones();
		}
	}
	else
	{
		CreateTimer(1.0, DatabaseUpgrading, INVALID_HANDLE, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	}

	// Get Map Tag
	ExplodeString(g_szMapName, "_", g_szMapPrefix, 2, 32);

	// sv_pure 1 could lead to problems with the ckSurf models
	ServerCommand("sv_pure 0");

	// reload language files
	LoadTranslations("surftimer.phrases");

	CheatFlag("bot_zombie", false, true);
	g_bTierFound = false;
	for (int i = 0; i < MAXZONEGROUPS; i++)
	{
		g_fBonusFastest[i] = 9999999.0;
		g_bCheckpointRecordFound[i] = false;
	}

	for (int i = 0; i < MAX_STYLES; i++)
	{
		g_bReplayTickFound[i] = false;
	}

	// Precache
	InitPrecache();
	SetCashState();

	// Timers
	CreateTimer(0.1, CKTimer1, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
	CreateTimer(1.0, CKTimer2, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
	CreateTimer(60.0, AttackTimer, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
	CreateTimer(600.0, PlayerRanksTimer, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
	g_hZoneTimer = CreateTimer(GetConVarFloat(g_hChecker), BeamBoxAll, _, TIMER_REPEAT);

	// AutoBhop
	g_bAutoBhop = GetConVarBool(g_hAutoBhopConVar);

	// main.cfg & replays
	CreateTimer(1.0, DelayedStuff, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(GetConVarFloat(g_replayBotDelay), LoadReplaysTimer, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE); // replay bots

	int iEnt;

	// Trigger Gravity Fix
	iEnt = -1;
	while ((iEnt = FindEntityByClassname(iEnt, "trigger_gravity")) != -1)
	{
		SDKHook(iEnt, SDKHook_EndTouch, OnEndTouchGravityTrigger);
	}

	// Hook Zones
	iEnt = -1;
	if (g_hTriggerMultiple != null)
	{
		CloseHandle(g_hTriggerMultiple);
	}

	g_hTriggerMultiple = CreateArray(256);
	while ((iEnt = FindEntityByClassname(iEnt, "trigger_multiple")) != -1)
	{
		SDKHook(iEnt, SDKHook_EndTouch, OnMultipleTrigger1);
		SDKHook(iEnt, SDKHook_StartTouch, OnMultipleTrigger1);
		/* SDKHook(iEnt, SDKHook_StartTouch, OnMultipleTrigger2);
		SDKHook(iEnt, SDKHook_EndTouch, OnMultipleTrigger3);
		HookSingleEntityOutput(iEnt, "OnEndTouch", OnTriggerOutput); */
		PushArrayCell(g_hTriggerMultiple, iEnt);
	}

	g_mTriggerMultipleMenu = CreateMenu(HookZonesMenuHandler);
	SetMenuTitle(g_mTriggerMultipleMenu, "Select a trigger");

	for (int i = 0; i < GetArraySize(g_hTriggerMultiple); i++)
	{
		iEnt = GetArrayCell(g_hTriggerMultiple, i);

		if (IsValidEntity(iEnt))
		{
			char szTriggerName[128];
			GetEntPropString(iEnt, Prop_Send, "m_iName", szTriggerName, 128, 0);
			//PushArrayString(g_TriggerMultipleList, szTriggerName);
			AddMenuItem(g_mTriggerMultipleMenu, szTriggerName, szTriggerName);
		}
	}

	SetMenuOptionFlags(g_mTriggerMultipleMenu, MENUFLAG_BUTTON_EXIT);

	// info_teleport_destinations
	iEnt = -1;
	if (g_hDestinations != null)
		CloseHandle(g_hDestinations);

	g_hDestinations = CreateArray(128);
	while ((iEnt = FindEntityByClassname(iEnt, "info_teleport_destination")) != -1)
		PushArrayCell(g_hDestinations, iEnt);

	// Set default values
	g_fMapStartTime = GetGameTime();
	g_bRoundEnd = false;

	// Playtime
	CreateTimer(1.0, PlayTimeTimer, INVALID_HANDLE, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

	// Server Announcements
	g_iServerID = GetConVarInt(g_hServerID);
	if (GetConVarBool(g_hRecordAnnounce))
		CreateTimer(45.0, AnnouncementTimer, INVALID_HANDLE, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

	// Show Triggers
	g_iTriggerTransmitCount = 0;

	// Save Locs
	ResetSaveLocs();

	//CSD Hud Synchronizer
	HUD_Handle = CreateHudSynchronizer();
}

public void OnMapEnd()
{

	// ServerCommand("sm_updater_force");
	g_bEnableJoinMsgs = false;
	g_bServerDataLoaded = false;
	g_bHasLatestID = false;
	for (int i = 0; i < MAXZONEGROUPS; i++)
		Format(g_sTierString[i], 512, "");

	g_RecordBot = -1;
	g_BonusBot = -1;
	g_WrcpBot = -1;
	db_Cleanup();

	if (g_hSkillGroups != null)
		CloseHandle(g_hSkillGroups);
	g_hSkillGroups = null;

	if (g_hBotTrail[0] != null)
		CloseHandle(g_hBotTrail[0]);
	g_hBotTrail[0] = null;

	if (g_hBotTrail[1] != null)
		CloseHandle(g_hBotTrail[1]);
	g_hBotTrail[1] = null;

	Format(g_szMapName, sizeof(g_szMapName), "");

	// wrcps
	for (int client = 1; client <= MAXPLAYERS; client++)
	{
		g_fWrcpMenuLastQuery[client] = 0.0;
		g_bWrcpTimeractivated[client] = false;
	}

	// Hook Zones
	if (g_hTriggerMultiple != null)
	{
		ClearArray(g_hTriggerMultiple);
		CloseHandle(g_hTriggerMultiple);
	}

	g_hTriggerMultiple = null;
	delete g_hTriggerMultiple;

	CloseHandle(g_mTriggerMultipleMenu);

	if (g_hDestinations != null)
		CloseHandle(g_hDestinations);

	g_hDestinations = null;
}

public void OnConfigsExecuted()
{
	// Get Chat Prefix
	GetConVarString(g_hChatPrefix, g_szChatPrefix, sizeof(g_szChatPrefix));
	GetConVarString(g_hChatPrefix, g_szMenuPrefix, sizeof(g_szMenuPrefix));
	RemoveColors(g_szMenuPrefix, sizeof(g_szMenuPrefix));

	if (GetConVarBool(g_hDBMapcycle))
		db_selectMapCycle();
	else if (!GetConVarBool(g_hMultiServerMapcycle))
		readMapycycle();
	else
		readMultiServerMapcycle();

	if (GetConVarFloat(g_iHintsInterval) > 0.0)
	{
		readHints();
		if (g_aHints.Length != 0)
			CreateTimer(GetConVarFloat(g_iHintsInterval), ShowHintsTimer, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
	}

	if (GetConVarBool(g_hEnforceDefaultTitles))
		ReadDefaultTitlesWhitelist();

	// Count the amount of bonuses and then set skillgroups
	if (!g_bRenaming && !g_bInTransactionChain)
		db_selectBonusCount();

	ServerCommand("sv_pure 0");

	if (GetConVarBool(g_hAllowRoundEndCvar))
		ServerCommand("mp_ignore_round_win_conditions 0");
	else
		ServerCommand("mp_ignore_round_win_conditions 1;mp_maxrounds 1");

	if (GetConVarBool(g_hAutoRespawn))
		ServerCommand("mp_respawn_on_death_ct 1;mp_respawn_on_death_t 1;mp_respawnwavetime_ct 3.0;mp_respawnwavetime_t 3.0");
	else
		ServerCommand("mp_respawn_on_death_ct 0;mp_respawn_on_death_t 0");

	ServerCommand("mp_endmatch_votenextmap 0;mp_do_warmup_period 0;mp_warmuptime 0;mp_match_can_clinch 0;mp_match_end_changelevel 1;mp_match_restart_delay 10;mp_endmatch_votenextleveltime 10;mp_endmatch_votenextmap 0;mp_halftime 0;bot_zombie 1;mp_do_warmup_period 0;mp_maxrounds 1");
	ServerCommand("sv_infinite_ammo 2");
	ServerCommand("sv_autobunnyhopping 1");
}

public void OnClientConnected(int client)
{
	g_Stage[g_iClientInZone[client][2]][client] = 1;
	g_WrcpStage[client] = 1;
	g_Stage[0][client] = 1;
	g_bWrcpTimeractivated[client] = false;
	g_CurrentStage[client] = 1;
	g_iInBonus[client] = 0;
}

public void OnClientPutInServer(int client)
{
	if (!IsValidClient(client))
	{
		return;
	}

	// Defaults
	SetClientDefaults(client);
	Command_Restart(client, 1);

	// SDKHooks
	SDKHook(client, SDKHook_SetTransmit, Hook_SetTransmit);
	SDKHook(client, SDKHook_PostThinkPost, Hook_PostThinkPost);
	SDKHook(client, SDKHook_OnTakeDamage, Hook_OnTakeDamage);
	SDKHook(client, SDKHook_PreThink, OnPlayerThink);
	SDKHook(client, SDKHook_PreThinkPost, OnPlayerThink);
	SDKHook(client, SDKHook_Think, OnPlayerThink);
	SDKHook(client, SDKHook_PostThink, OnPlayerThink);
	SDKHook(client, SDKHook_PostThinkPost, OnPlayerThink);

	if (!IsFakeClient(client))
	{
		SendConVarValue(client, g_hFootsteps, "0");
		StopRecording(client); // clear client replay frames
	}

	g_bReportSuccess[client] = false;
	g_fCommandLastUsed[client] = 0.0;

	// fluffys set bools
	g_bToggleMapFinish[client] = true;
	g_bRepeat[client] = false;
	g_bNotTeleporting[client] = false;

	if (IsFakeClient(client))
	{
		CS_SetMVPCount(client, 1);
		return;
	}
	else
		g_MVPStars[client] = 0;

	// Client Country
	GetCountry(client);

	if (LibraryExists("dhooks"))
		DHookEntity(g_hTeleport, false, client);

	// Get SteamID
	GetClientAuthId(client, AuthId_Steam2, g_szSteamID[client], MAX_NAME_LENGTH, true);

	// char fix
	FixPlayerName(client);

	// Position Restoring
	if (GetConVarBool(g_hcvarRestore) && !g_bRenaming && !g_bInTransactionChain)
	db_selectLastRun(client);

	if (g_bTierFound)
		AnnounceTimer[client] = CreateTimer(20.0, AnnounceMap, client, TIMER_FLAG_NO_MAPCHANGE);

	if (!g_bRenaming && !g_bInTransactionChain && g_bServerDataLoaded && !g_bSettingsLoaded[client] && !g_bLoadingSettings[client])
	{
		// Start loading client settings
		g_bLoadingSettings[client] = true;
		g_iSettingToLoad[client] = 0;
		LoadClientSetting(client, g_iSettingToLoad[client]);
	}
}

public void OnClientAuthorized(int client)
{
	if (GetConVarBool(g_hConnectMsg) && !IsFakeClient(client))
	{
		char s_Country[32], s_clientName[32], s_address[32];
		GetClientIP(client, s_address, sizeof(s_address));
		GetClientName(client, s_clientName, sizeof(s_clientName));
		Format(s_Country, sizeof(s_Country), "Unknown");
		GeoipCountry(s_address, s_Country, sizeof(s_Country));
		if (!strcmp(s_Country, NULL_STRING))
			Format(s_Country, sizeof(s_Country), "Unknown", s_Country);
		else
			if (StrContains(s_Country, "United", false) != -1 ||
			StrContains(s_Country, "Republic", false) != -1 ||
			StrContains(s_Country, "Federation", false) != -1 ||
			StrContains(s_Country, "Island", false) != -1 ||
			StrContains(s_Country, "Netherlands", false) != -1 ||
			StrContains(s_Country, "Isle", false) != -1 ||
			StrContains(s_Country, "Bahamas", false) != -1 ||
			StrContains(s_Country, "Maldives", false) != -1 ||
			StrContains(s_Country, "Philippines", false) != -1 ||
			StrContains(s_Country, "Vatican", false) != -1)
		{
			Format(s_Country, sizeof(s_Country), "The %s", s_Country);
		}

		if (StrEqual(s_Country, "Unknown", false) || StrEqual(s_Country, "Localhost", false))
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i) && i != client)
				{
					CPrintToChat(i, "%t", "Connected1", s_clientName);
				}
			}
		}
		else
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i) && i != client)
				{
					CPrintToChat(i, "%t", "Connected2", s_clientName, s_Country);
				}
			}
		}
	}
}

public void OnClientDisconnect(int client)
{
	db_savePlayTime(client);

	g_fPlayerLastTime[client] = -1.0;
	if (g_fStartTime[client] != -1.0 && g_bTimerRunning[client])
	{
		if (g_bPause[client])
		{
			g_fPauseTime[client] = GetClientTickTime(client) - g_fStartPauseTime[client];
			g_fPlayerLastTime[client] = GetClientTickTime(client) - g_fStartTime[client] - g_fPauseTime[client];
		}
		else
		{
			g_fPlayerLastTime[client] = g_fCurrentRunTime[client];
		}
	}

	SDKUnhook(client, SDKHook_SetTransmit, Hook_SetTransmit);
	SDKUnhook(client, SDKHook_PostThinkPost, Hook_PostThinkPost);
	SDKUnhook(client, SDKHook_OnTakeDamage, Hook_OnTakeDamage);
	SDKUnhook(client, SDKHook_PreThink, OnPlayerThink);
	SDKUnhook(client, SDKHook_PreThinkPost, OnPlayerThink);
	SDKUnhook(client, SDKHook_Think, OnPlayerThink);
	SDKUnhook(client, SDKHook_PostThink, OnPlayerThink);
	SDKUnhook(client, SDKHook_PostThinkPost, OnPlayerThink);

	if (client == g_RecordBot)
	{
		StopPlayerMimic(client);
		g_RecordBot = -1;
		return;
	}
	if (client == g_BonusBot)
	{
		StopPlayerMimic(client);
		g_BonusBot = -1;
		return;
	}
	if (client == g_WrcpBot)
	{
		StopPlayerMimic(client);
		g_WrcpBot = -1;
		return;
	}

	// Database
	if (IsValidClient(client) && !g_bRenaming)
	{
		if (!g_bIgnoreZone[client] && !g_bPracticeMode[client])
			db_insertLastPosition(client, g_szMapName, g_Stage[g_iClientInZone[client][2]][client], g_iClientInZone[client][2]);

		db_updatePlayerOptions(client);
	}

	// Stop recording
	if (g_aRecording[client] != null)
		StopRecording(client);

	// Stop Showing Triggers
	if (g_bShowTriggers[client])
	{
		g_bShowTriggers[client] = false;
		--g_iTriggerTransmitCount;
		TransmitTriggers(g_iTriggerTransmitCount > 0);
	}

	// New noclipspeed
	sv_noclipspeed.FloatValue = g_iDefaultNoclipSpeed;

	//PRINFO
	if(IsValidClient(client) && !IsFakeClient(client)){
		for(int zonegroup = 0; zonegroup < MAXZONEGROUPS; zonegroup++){
			if(g_fTimeIncrement[client][zonegroup] != 0.0)
				g_fTimeinZone[client][zonegroup] += g_fTimeIncrement[client][zonegroup];
			db_UpdatePRinfo(client, g_szSteamID[client], zonegroup);
		}
	}
}

public void OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if (convar == g_hChatPrefix)
	{
		GetConVarString(g_hChatPrefix, g_szChatPrefix, sizeof(g_szChatPrefix));
		GetConVarString(g_hChatPrefix, g_szMenuPrefix, sizeof(g_szMenuPrefix));
		RemoveColors(g_szMenuPrefix, sizeof(g_szMenuPrefix));
	}
	if (convar == g_hReplayBot)
	{
		if (GetConVarBool(g_hReplayBot))
			LoadReplays();
		else
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i))
				{
					if (i == g_RecordBot)
					{
						StopPlayerMimic(i);
						KickClient(i);
					}
					else
					{
						if (!GetConVarBool(g_hBonusBot) && !GetConVarBool(g_hWrcpBot)) // if both bots are off, no need to record
							if (g_aRecording[i] != null)
								StopRecording(i);
					}
				}
			}
			if (GetConVarBool(g_hInfoBot) && GetConVarBool(g_hBonusBot))
				ServerCommand("bot_quota 2");
			else
				if (GetConVarBool(g_hInfoBot) || GetConVarBool(g_hBonusBot))
					ServerCommand("bot_quota 1");
				else
					ServerCommand("bot_quota 0");

			if (g_hBotTrail[0] != null)
				CloseHandle(g_hBotTrail[0]);
			g_hBotTrail[0] = null;
		}
	}
	else if (convar == g_hBonusBot)
	{
		if (GetConVarBool(g_hBonusBot))
			LoadReplays();
		else
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i))
				{
					if (i == g_BonusBot)
					{
						StopPlayerMimic(i);
						KickClient(i);
					}
					else
					{
						if (!GetConVarBool(g_hReplayBot) && !GetConVarBool(g_hWrcpBot)) // if both bots are off
							if (g_aRecording[i] != null)
								StopRecording(i);
					}
				}
			}
			if (GetConVarBool(g_hInfoBot) && GetConVarBool(g_hReplayBot))
				ServerCommand("bot_quota 2");
			else
				if (GetConVarBool(g_hInfoBot) || GetConVarBool(g_hReplayBot))
					ServerCommand("bot_quota 1");
				else
					ServerCommand("bot_quota 0");

			if (g_hBotTrail[1] != null)
				CloseHandle(g_hBotTrail[1]);
			g_hBotTrail[1] = null;
		}
	}
	else if (convar == g_hWrcpBot)
	{
		if (GetConVarBool(g_hWrcpBot))
		{
			LoadReplays();
		}
		else
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i))
				{
					if (i == g_WrcpBot)
					{
						StopPlayerMimic(i);
						KickClient(i);
					}
					else
					{
						if (!GetConVarBool(g_hReplayBot) && !GetConVarBool(g_hBonusBot)) // if both bots are off
							if (g_aRecording[i] != null)
								StopRecording(i);
					}
				}
			}
		}
	}
	else if (convar == g_hAutoRespawn)
	{
		if (GetConVarBool(g_hAutoRespawn))
		{
			ServerCommand("mp_respawn_on_death_ct 1;mp_respawn_on_death_t 1;mp_respawnwavetime_ct 3.0;mp_respawnwavetime_t 3.0");
		}
		else
		{
			ServerCommand("mp_respawn_on_death_ct 0;mp_respawn_on_death_t 0");
		}
	}
	else if (convar == g_hPlayerSkinChange)
	{
		if (GetConVarBool(g_hPlayerSkinChange))
		{
			char szBuffer[256];
			for (int i = 1; i <= MaxClients; i++)
				if (IsValidClient(i))
				{
					if (i == g_RecordBot || i == g_BonusBot || i == g_WrcpBot)
					{
						// Player Model
						GetConVarString(g_hReplayBotPlayerModel, szBuffer, 256);
						SetEntityModel(i, szBuffer);
						// Arm Model
						GetConVarString(g_hReplayBotArmModel, szBuffer, 256);
						SetEntPropString(i, Prop_Send, "m_szArmsModel", szBuffer);
						SetEntityModel(i, szBuffer);
					}
					else
					{
						GetConVarString(g_hArmModel, szBuffer, 256);
						SetEntPropString(i, Prop_Send, "m_szArmsModel", szBuffer);

						GetConVarString(g_hPlayerModel, szBuffer, 256);
						SetEntityModel(i, szBuffer);
					}
				}
		}
	}
	else if (convar == g_hPointSystem)
	{
		if (GetConVarBool(g_hPointSystem))
		{
			for (int i = 1; i <= MaxClients; i++)
				if (IsValidClient(i))
					CreateTimer(0.0, SetClanTag, i, TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			for (int i = 1; i <= MaxClients; i++)
				if (IsValidClient(i))
				{
					Format(g_pr_rankname[i], 128, "");
					CreateTimer(0.0, SetClanTag, i, TIMER_FLAG_NO_MAPCHANGE);
				}
		}
	}
	else if (convar == g_hCvarNoBlock)
	{
		if (GetConVarBool(g_hCvarNoBlock))
		{
			for (int client = 1; client <= MAXPLAYERS; client++)
				if (IsValidEntity(client))
					SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);

		}
		else
		{
			for (int client = 1; client <= MAXPLAYERS; client++)
				if (IsValidEntity(client))
					SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 5, 4, true);
		}
	}
	else if (convar == g_hCleanWeapons)
	{
		if (GetConVarBool(g_hCleanWeapons))
		{
			char szclass[32];
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i) && IsPlayerAlive(i))
				{
					for (int j = 0; j < 4; j++)
					{
						int weapon = GetPlayerWeaponSlot(i, j);
						if (weapon != -1 && j != 2)
						{
							GetEdictClassname(weapon, szclass, sizeof(szclass));
							RemovePlayerItem(i, weapon);
							RemoveEdict(weapon);
							int equipweapon = GetPlayerWeaponSlot(i, 2);
							if (equipweapon != -1)
								EquipPlayerWeapon(i, equipweapon);
						}
					}
				}
			}
		}
	}
	else if (convar == g_hAutoBhopConVar)
	{
		g_bAutoBhop = view_as<bool>(StringToInt(newValue[0]));
	}
	else if (convar == g_hCountry)
	{
		if (GetConVarBool(g_hCountry))
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i))
				{
					GetCountry(i);
					if (GetConVarBool(g_hPointSystem))
						CreateTimer(0.5, SetClanTag, i, TIMER_FLAG_NO_MAPCHANGE);
				}
			}
		}
		else
		{
			if (GetConVarBool(g_hPointSystem))
				for (int i = 1; i <= MaxClients; i++)
					if (IsValidClient(i))
						CreateTimer(0.5, SetClanTag, i, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	else if (convar == g_hInfoBot)
	{
		if (GetConVarBool(g_hInfoBot))
		{
			LoadInfoBot();
		}
		else
		{
			for (int i = 1; i <= MaxClients; i++)
				if (IsValidClient(i) && IsFakeClient(i))
				{
					if (i == g_InfoBot)
					{
						int count = 0;
						g_InfoBot = -1;
						KickClient(i);
						char szBuffer[64];
						if (g_bMapReplay[0])
							count++;
						if (g_BonusBotCount > 0)
							count++;
						Format(szBuffer, sizeof(szBuffer), "bot_quota %i", count);
						ServerCommand(szBuffer);
					}
				}
		}
	}
	else if (convar == g_hReplayBotPlayerModel)
	{
		char szBuffer[256];
		GetConVarString(g_hReplayBotPlayerModel, szBuffer, 256);
		PrecacheModel(szBuffer, true);
		AddFileToDownloadsTable(szBuffer);
		if (IsValidClient(g_RecordBot))
			SetEntityModel(g_RecordBot, szBuffer);
		if (IsValidClient(g_BonusBot))
			SetEntityModel(g_BonusBot, szBuffer);
		if (IsValidClient(g_WrcpBot))
			SetEntityModel(g_WrcpBot, szBuffer);
	}
	else if (convar == g_hReplayBotArmModel)
	{
		char szBuffer[256];
		GetConVarString(g_hReplayBotArmModel, szBuffer, 256);
		PrecacheModel(szBuffer, true);
		AddFileToDownloadsTable(szBuffer);
		if (IsValidClient(g_RecordBot))
			SetEntPropString(g_RecordBot, Prop_Send, "m_szArmsModel", szBuffer);
		if (IsValidClient(g_BonusBot))
			SetEntPropString(g_RecordBot, Prop_Send, "m_szArmsModel", szBuffer);
		if (IsValidClient(g_WrcpBot))
			SetEntPropString(g_WrcpBot, Prop_Send, "m_szArmsModel", szBuffer);

	}
	else if (convar == g_hPlayerModel)
	{
		char szBuffer[256];
		GetConVarString(g_hPlayerModel, szBuffer, 256);

		PrecacheModel(szBuffer, true);
		AddFileToDownloadsTable(szBuffer);
		if (!GetConVarBool(g_hPlayerSkinChange))
			return;
		for (int i = 1; i <= MaxClients; i++)
			if (IsValidClient(i) && i != g_RecordBot)
				SetEntityModel(i, szBuffer);
			else if (IsValidClient(i) && i != g_BonusBot)
				SetEntityModel(i, szBuffer);
			else if (IsValidClient(i) && i != g_WrcpBot)
				SetEntityModel(i, szBuffer);
	}
	else if (convar == g_hArmModel)
	{
		char szBuffer[256];
		GetConVarString(g_hArmModel, szBuffer, 256);

		PrecacheModel(szBuffer, true);
		AddFileToDownloadsTable(szBuffer);
		if (!GetConVarBool(g_hPlayerSkinChange))
			return;
		for (int i = 1; i <= MaxClients; i++)
			if (IsValidClient(i) && i != g_RecordBot)
				SetEntPropString(i, Prop_Send, "m_szArmsModel", szBuffer);
			else if (IsValidClient(i) && i != g_BonusBot)
				SetEntPropString(i, Prop_Send, "m_szArmsModel", szBuffer);
			else if (IsValidClient(i) && i != g_WrcpBot)
				SetEntPropString(i, Prop_Send, "m_szArmsModel", szBuffer);
	}
	else if (convar == g_hReplayBotColor)
	{
		char color[256];
		Format(color, 256, "%s", newValue[0]);
		GetRGBColor(0, color);
	}
	else if (convar == g_hBonusBotColor)
	{
		char color[256];
		Format(color, 256, "%s", newValue[0]);
		GetRGBColor(1, color);
	}
	else if (convar == g_hzoneStartColor)
	{
		char color[24];
		Format(color, 28, "%s", newValue[0]);
		StringRGBtoInt(color, g_iZoneColors[1]);
	}
	else if (convar == g_hzoneEndColor)
	{
		char color[24];
		Format(color, 28, "%s", newValue[0]);
		StringRGBtoInt(color, g_iZoneColors[2]);
	}
	else if (convar == g_hzoneCheckerColor)
	{
		char color[24];
		Format(color, 28, "%s", newValue[0]);
		StringRGBtoInt(color, g_iZoneColors[10]);
	}
	else if (convar == g_hzoneBonusStartColor)
	{
		char color[24];
		Format(color, 28, "%s", newValue[0]);
		StringRGBtoInt(color, g_iZoneColors[3]);
	}
	else if (convar == g_hzoneBonusEndColor)
	{
		char color[24];
		Format(color, 28, "%s", newValue[0]);
		StringRGBtoInt(color, g_iZoneColors[4]);
	}
	else if (convar == g_hzoneStageColor)
	{
		char color[24];
		Format(color, 28, "%s", newValue[0]);
		StringRGBtoInt(color, g_iZoneColors[5]);
	}
	else if (convar == g_hzoneCheckpointColor)
	{
		char color[24];
		Format(color, 28, "%s", newValue[0]);
		StringRGBtoInt(color, g_iZoneColors[6]);
	}
	else if (convar == g_hzoneSpeedColor)
	{
		char color[24];
		Format(color, 28, "%s", newValue[0]);
		StringRGBtoInt(color, g_iZoneColors[7]);
	}
	else if (convar == g_hzoneTeleToStartColor)
	{
		char color[24];
		Format(color, 28, "%s", newValue[0]);
		StringRGBtoInt(color, g_iZoneColors[8]);
	}
	else if (convar == g_hzoneValidatorColor)
	{
		char color[24];
		Format(color, 28, "%s", newValue[0]);
		StringRGBtoInt(color, g_iZoneColors[9]);
	}
	else if (convar == g_hzoneStopColor)
	{
		char color[24];
		Format(color, 28, "%s", newValue[0]);
		StringRGBtoInt(color, g_iZoneColors[0]);
	}
	else if (convar == g_hZonerFlag)
	{
		AdminFlag flag;
		bool validFlag;
		validFlag = FindFlagByChar(newValue[0], flag);

		if (!validFlag)
		{
			PrintToServer("SurfTimer | Invalid flag for ck_zoner_flag");
			g_ZonerFlag = ADMFLAG_ROOT;
		}
		else
			g_ZonerFlag = FlagToBit(flag);
	}
	else if (convar == g_hAdminMenuFlag)
	{
		AdminFlag flag;
		bool validFlag;
		validFlag = FindFlagByChar(newValue[0], flag);

		if (!validFlag)
		{
			PrintToServer("SurfTimer | Invalid flag for ck_adminmenu_flag");
			g_AdminMenuFlag = ADMFLAG_ROOT;
		}
		else
			g_AdminMenuFlag = FlagToBit(flag);
	}

	else if (convar == g_hServerID)
		g_iServerID = GetConVarInt(g_hServerID);
	else if (convar == g_hHostName)
	{
		GetConVarString(g_hHostName, g_sServerName, sizeof(g_sServerName));
	}
	else if (convar == g_hEnforceDefaultTitles)
	{
		for (int i = 1; i < MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i))
			{
				if (!GetConVarBool(g_hEnforceDefaultTitles))
					db_viewCustomTitles(i, g_szSteamID[i]);
				else
					LoadDefaultTitle(i);
			}
		}
	}
	else if (convar == g_hAutoVipFlag)
	{
		AdminFlag flag;
		bool validFlag;
		validFlag = FindFlagByChar(newValue[0], flag);

		if (!validFlag)
		{
			LogError("SurfTimer | Invalid flag for ck_vip_flag");
			g_VipFlag = ADMFLAG_RESERVATION;
		}
		else
			g_VipFlag = FlagToBit(flag);
	}
	else if (convar == g_hSoundPathWR)
	{
		GetConVarString(g_hSoundPathWR, g_szSoundPathWR, sizeof(g_szSoundPathWR));
		if (FileExists(g_szSoundPathWR))
		{
			char sBuffer[2][PLATFORM_MAX_PATH];
			ExplodeString(g_szSoundPathWR, "sound/", sBuffer, 2, PLATFORM_MAX_PATH);
			Format(g_szRelativeSoundPathWR, sizeof(g_szRelativeSoundPathWR), "*%s", sBuffer[1]);
		}
		else
		{
			Format(g_szSoundPathWR, sizeof(g_szSoundPathWR), WR2_FULL_SOUND_PATH);
			Format(g_szRelativeSoundPathWR, sizeof(g_szRelativeSoundPathWR), WR2_RELATIVE_SOUND_PATH);
		}
	}
	else if (convar == g_hSoundPathTop)
	{
		GetConVarString(g_hSoundPathTop, g_szSoundPathTop, sizeof(g_szSoundPathTop));
		if (FileExists(g_szSoundPathTop))
		{
			char sBuffer[2][PLATFORM_MAX_PATH];
			ExplodeString(g_szSoundPathTop, "sound/", sBuffer, 2, PLATFORM_MAX_PATH);
			Format(g_szRelativeSoundPathTop, sizeof(g_szRelativeSoundPathTop), "*%s", sBuffer[1]);
		}
		else
		{
			Format(g_szSoundPathTop, sizeof(g_szSoundPathTop), TOP10_FULL_SOUND_PATH);
			Format(g_szRelativeSoundPathTop, sizeof(g_szRelativeSoundPathTop), TOP10_RELATIVE_SOUND_PATH);
		}
	}
	else if (convar == g_hSoundPathPB)
	{
		GetConVarString(g_hSoundPathPB, g_szSoundPathPB, sizeof(g_szSoundPathPB));
		if (FileExists(g_szSoundPathPB))
		{
			char sBuffer[2][PLATFORM_MAX_PATH];
			ExplodeString(g_szSoundPathPB, "sound/", sBuffer, 2, PLATFORM_MAX_PATH);
			Format(g_szRelativeSoundPathPB, sizeof(g_szRelativeSoundPathPB), "*%s", sBuffer[1]);
		}
		else
		{
			Format(g_szSoundPathPB, sizeof(g_szSoundPathPB), PR_FULL_SOUND_PATH);
			Format(g_szRelativeSoundPathPB, sizeof(g_szRelativeSoundPathPB), PR_RELATIVE_SOUND_PATH);
		}
	}
	else if (convar == g_hSoundPathWRCP)
	{
		GetConVarString(g_hSoundPathWRCP, g_szSoundPathWRCP, sizeof(g_szSoundPathWRCP));
		if (FileExists(g_szSoundPathWRCP))
		{
			char sBuffer[2][PLATFORM_MAX_PATH];
			ExplodeString(g_szSoundPathWRCP, "sound/", sBuffer, 2, PLATFORM_MAX_PATH);
			Format(g_szRelativeSoundPathWRCP, sizeof(g_szRelativeSoundPathWRCP), "*%s", sBuffer[1]);
		}
		else
		{
			Format(g_szSoundPathWRCP, sizeof(g_szSoundPathWRCP), "sound/physics/glass/glass_bottle_break2.wav");
			Format(g_szRelativeSoundPathWRCP, sizeof(g_szRelativeSoundPathWRCP), "*physics/glass/glass_bottle_break2.wav");
		}
	}
	if (g_hZoneTimer != INVALID_HANDLE)
	{
		KillTimer(g_hZoneTimer);
		g_hZoneTimer = INVALID_HANDLE;
	}

	g_hZoneTimer = CreateTimer(GetConVarFloat(g_hChecker), BeamBoxAll, _, TIMER_REPEAT);
}

public void OnPluginStart()
{
	g_bServerDataLoaded = false;

	// Language File
	LoadTranslations("surftimer.phrases");

	CreateConVars();
	CreateCommands();
	CreateHooks();
	CreateCommandListeners();

	db_setupDatabase();
	CreateCommandsNewMap();

	// mic
	g_ownerOffset = FindSendPropInfo("CBaseCombatWeapon", "m_hOwnerEntity");

	// add to admin menu
	Handle tpMenu;
	if (LibraryExists("adminmenu") && ((tpMenu = GetAdminTopMenu()) != null))
		OnAdminMenuReady(tpMenu);

	// Hints array
	g_aHints = new ArrayList(MAX_HINT_SIZE);

	// mapcycle array
	int arraySize = ByteCountToCells(PLATFORM_MAX_PATH);
	g_MapList = CreateArray(arraySize);

	// default titles whitelist array
	g_DefaultTitlesWhitelist = CreateArray();

	// Botmimic 3
	// https://forums.alliedmods.net/showthread.php?t=180114

	CheatFlag("bot_zombie", false, true);
	CheatFlag("bot_mimic", false, true);
	g_smLoadedRecordsAdditionalTeleport = new StringMap();
	Handle hGameData = LoadGameConfigFile("sdktools.games");
	if (hGameData == null)
	{
		SetFailState("GameConfigFile sdkhooks.games was not found.");
		return;
	}
	int iOffset = GameConfGetOffset(hGameData, "Teleport");
	CloseHandle(hGameData);
	if (iOffset == -1)
		return;

	if (LibraryExists("dhooks"))
	{
		g_hTeleport = DHookCreate(iOffset, HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity, DHooks_OnTeleport);
		if (g_hTeleport == null)
			return;
		DHookAddParam(g_hTeleport, HookParamType_VectorPtr);
		DHookAddParam(g_hTeleport, HookParamType_ObjectPtr);
		DHookAddParam(g_hTeleport, HookParamType_VectorPtr);
		DHookAddParam(g_hTeleport, HookParamType_Bool);
	}

	// Forwards
	Register_Forwards();

	if (g_bLateLoaded)
	{
		CreateTimer(3.0, LoadPlayerSettings, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE);
	}

	Format(szWHITE, 12, "%c", WHITE);
	Format(szDARKRED, 12, "%c", DARKRED);
	Format(szPURPLE, 12, "%c", PURPLE);
	Format(szGREEN, 12, "%c", GREEN);
	Format(szLIGHTGREEN, 12, "%c", LIGHTGREEN);
	Format(szLIMEGREEN, 12, "%c", LIMEGREEN);
	Format(szRED, 12, "%c", RED);
	Format(szGRAY, 12, "%c", GRAY);
	Format(szYELLOW, 12, "%c", YELLOW);
	Format(szDARKGREY, 12, "%c", DARKGREY);
	Format(szBLUE, 12, "%c", BLUE);
	Format(szDARKBLUE, 12, "%c", DARKBLUE);
	Format(szLIGHTBLUE, 12, "%c", LIGHTBLUE);
	Format(szPINK, 12, "%c", PINK);
	Format(szLIGHTRED, 12, "%c", LIGHTRED);
	Format(szORANGE, 12, "%c", ORANGE);

	// Server Announcements
	g_bHasLatestID = false;
	g_iLastID = 0;
}

/*======  End of Events  ======*/

public Action ItemFoundMsg(UserMsg msg_id, Protobuf msg, const int[] players, int playersNum, bool reliable, bool init)
{
	return Plugin_Handled;
}