/*----------  CVars  ----------*/
// Zones
bool g_bZoner[MAXPLAYERS + 1];
int g_ZonerFlag;
ConVar g_hZonerFlag = null;
ConVar g_hZoneDisplayType = null;								// How zones are displayed (lower edge, full)
ConVar g_hZonesToDisplay = null;								// Which zones are displayed
ConVar g_hChecker;												// Zone refresh rate
Handle g_hZoneTimer = INVALID_HANDLE;
// Zone Colors
int g_iZoneColors[ZONEAMOUNT+2][4];								// ZONE COLOR TYPES: Stop(0), Start(1), End(2), BonusStart(3), BonusEnd(4), Stage(5),
char g_szZoneColors[ZONEAMOUNT+2][24];							// Checkpoint(6), Speed(7), TeleToStart(8), Validator(9), Chekcer(10)
ConVar g_hzoneStartColor = null;
ConVar g_hzoneEndColor = null;
ConVar g_hzoneBonusStartColor = null;
ConVar g_hzoneBonusEndColor = null;
ConVar g_hzoneStageColor = null;
ConVar g_hzoneCheckpointColor = null;
ConVar g_hzoneSpeedColor = null;
ConVar g_hzoneTeleToStartColor = null;
ConVar g_hzoneValidatorColor = null;
ConVar g_hzoneCheckerColor = null;
ConVar g_hzoneStopColor = null;
ConVar g_hAnnounceRecord;										// Announce rank type: 0 announce all, 1 announce only PB's, 3 announce only SR's
ConVar g_hCommandToEnd;											// !end Enable / Disable
ConVar g_hWelcomeMsg = null;
ConVar g_hReplayBotPlayerModel = null;
ConVar g_hReplayBotArmModel = null;								// Replay bot arm model
ConVar g_hPlayerModel = null;									// Player models
ConVar g_hArmModel = null;										// Player arm models
ConVar g_hcvarRestore = null;									// Restore player's runs?
ConVar g_hNoClipS = null;										// Allow noclip?
ConVar g_hReplayBot = null;										// Replay bot?
ConVar g_hReplayPre = null;										// Seconds for prestrafe recording
ConVar g_hWrcpBot = null;
ConVar g_hBackupReplays = null;									// Back up replay bots?
ConVar g_hReplaceReplayTime = null;								// Replace replay times, even if not SR
ConVar g_hTeleToStartWhenSettingsLoaded = null;
bool g_bMapReplay[MAX_STYLES];									// Why two bools?
ConVar g_hBonusBot = null;										// Bonus bot?
bool g_bMapBonusReplay[MAXZONEGROUPS][MAX_STYLES];
ConVar g_hColoredNames = null;									// Colored names in chat?
ConVar g_hPauseServerside = null;								// Allow !pause?
ConVar g_hAutoBhopConVar = null;								// Allow autobhop?
bool g_bAutoBhop;
ConVar g_hDynamicTimelimit = null;								// Dynamic timelimit?
ConVar g_hConnectMsg = null;									// Connect message?
ConVar g_hDisconnectMsg = null;									// Disconnect message?
ConVar g_hRadioCommands = null;									// Allow radio commands?
ConVar g_hInfoBot = null;										// Info bot?
ConVar g_hAttackSpamProtection = null;							// Throttle shooting?
int g_AttackCounter[MAXPLAYERS + 1];							// Used to calculate player shots
ConVar g_hGoToServer = null;									// Allow !goto?
ConVar g_hAllowRoundEndCvar = null;								// Allow round ending?
bool g_bRoundEnd;												// Why two bools?
ConVar g_hPlayerSkinChange = null;								// Allow changing player models?
ConVar g_hCountry = null;										// Display countries for players?
ConVar g_hAutoRespawn = null;									// Respawn players automatically?
ConVar g_hCvarNoBlock = null;									// Allow player blocking?
ConVar g_hPointSystem = null;									// Use the point system?
ConVar g_hCleanWeapons = null;									// Clean weapons from ground?
int g_ownerOffset;												// Used to clear weapons from ground
ConVar g_hCvarGodMode = null;									// Enable god mode?
// ConVar g_hAutoTimer = null;
ConVar g_hMapEnd = null;										// Allow map ending?
ConVar g_hAutohealing_Hp = null;								// Automatically heal lost HP?
// Bot Colors & effects:
ConVar g_hReplayBotColor = null;								// Replay bot color
int g_ReplayBotColor[3];
ConVar g_hBonusBotColor = null;									// Bonus bot color
int g_BonusBotColor[3];
ConVar g_hDoubleRestartCommand;									// Double !r restart
ConVar g_hSoundEnabled = null;									// Enable timer start sound
ConVar g_hSoundPath = null;										// Define start sound
// char sSoundPath[64];
ConVar g_hSpawnToStartZone = null;								// Teleport on spawn to start zone
ConVar g_hAnnounceRank = null;									// Min rank to announce in chat
ConVar g_hForceCT = null;										// Force players CT
ConVar g_hChatSpamFilter = null;								// Chat spam limiter
float g_fLastChatMessage[MAXPLAYERS + 1];						// Last message time
int g_messages[MAXPLAYERS + 1];									// Spam message count
ConVar g_henableChatProcessing = null;							// Is chat processing enabled
ConVar g_hMultiServerMapcycle = null;							// Use multi server mapcycle
ConVar g_hDBMapcycle = null;									// use maps from ck_maptier as the servers mapcycle
ConVar g_hPrestigeRank = null;									// Rank to limit the server
ConVar g_hPrestigeStyles = null;								// Determines if the rank limit applies to normal style or all styles
ConVar g_hPrestigeVip = null;
ConVar g_hOneJumpLimit = null;									// Only allows players to jump once inside a start or stage zone
ConVar g_hServerID = null;										// Sets the servers id for cross-server announcements
ConVar g_hRecordAnnounce = null;								// Enable/Disable cross-server announcements
ConVar g_hSidewaysBlockKeys = null;
ConVar g_hEnforceDefaultTitles = null;
ConVar g_hWrcpPoints = null;
ConVar g_hPlayReplayVipOnly = null;
ConVar g_hSoundPathWR = null;
char g_szSoundPathWR[PLATFORM_MAX_PATH];
char g_szRelativeSoundPathWR[PLATFORM_MAX_PATH];
ConVar g_hSoundPathTop = null;
char g_szSoundPathTop[PLATFORM_MAX_PATH];
char g_szRelativeSoundPathTop[PLATFORM_MAX_PATH];
ConVar g_hSoundPathPB = null;
char g_szSoundPathPB[PLATFORM_MAX_PATH];
char g_szRelativeSoundPathPB[PLATFORM_MAX_PATH];
ConVar g_hSoundPathWRCP = null;
char g_szSoundPathWRCP[PLATFORM_MAX_PATH];
char g_szRelativeSoundPathWRCP[PLATFORM_MAX_PATH];
ConVar g_hMustPassCheckpoints = null;
ConVar g_hSlayOnRoundEnd = null;
ConVar g_hLimitSpeedType = null;
ConVar g_drDeleteSecurity = null;
ConVar g_iAdminCountryTags = null;
ConVar g_replayBotDelay = null;
ConVar g_hAllowCheckpointRecreation = null;						// Allows players to recreate checkpoints along with where to display info
ConVar g_iHintsInterval = null;									// Time between two hints. 0 = off
ConVar g_bHintsRandomOrder = null;								// If hints are in random order
ConVar g_hOverrideClantag = null;
ConVar g_hDefaultPreSpeed = null;
ConVar g_hLogQueryTimes = null;

void CreateConVars()
{
	CreateConVar("timer_version", VERSION, "Timer Version.", FCVAR_DONTRECORD | FCVAR_SPONLY | FCVAR_REPLICATED | FCVAR_NOTIFY);

	AutoExecConfig_SetCreateDirectory(true);
	AutoExecConfig_SetCreateFile(true);
	AutoExecConfig_SetFile("surftimer");

	g_hChatPrefix = AutoExecConfig_CreateConVar("ck_chat_prefix", "{lime}SurfTimer {default}|", "Determines the prefix used for chat messages");
	g_hConnectMsg = AutoExecConfig_CreateConVar("ck_connect_msg", "1", "on/off - Enables a player connect message with country tag", _,true, 0.0, true, 1.0);
	g_hAllowRoundEndCvar = AutoExecConfig_CreateConVar("ck_round_end", "0", "on/off - Allows to end the current round", _, true, 0.0, true, 1.0);
	g_hDisconnectMsg = AutoExecConfig_CreateConVar("ck_disconnect_msg", "1", "on/off - Enables a player disconnect message in chat", _, true, 0.0, true, 1.0);
	g_hMapEnd = AutoExecConfig_CreateConVar("ck_map_end", "1", "on/off - Allows map changes after the timelimit has run out (mp_timelimit must be greater than 0)", _, true, 0.0, true, 1.0);
	g_hColoredNames = AutoExecConfig_CreateConVar("ck_colored_chatnames", "1", "on/off Colors players names based on their rank in chat.", _, true, 0.0, true, 1.0);
	g_hNoClipS = AutoExecConfig_CreateConVar("ck_noclip", "1", "on/off - Allows players to use noclip", _, true, 0.0, true, 1.0);
	g_hGoToServer = AutoExecConfig_CreateConVar("ck_goto", "1", "on/off - Allows players to use the !goto command", _, true, 0.0, true, 1.0);
	g_hCommandToEnd = AutoExecConfig_CreateConVar("ck_end", "1", "on/off - Allows players to use the !end command", _, true, 0.0, true, 1.0);
	g_hCvarGodMode = AutoExecConfig_CreateConVar("ck_godmode", "1", "on/off - Godmode", _, true, 0.0, true, 1.0);
	g_hPauseServerside = AutoExecConfig_CreateConVar("ck_pause", "1", "on/off - Allows players to use the !pause command", _, true, 0.0, true, 1.0);
	g_hcvarRestore = AutoExecConfig_CreateConVar("ck_restore", "1", "on/off - Restoring of time and last position after reconnect", _, true, 0.0, true, 1.0);
	g_hAttackSpamProtection = AutoExecConfig_CreateConVar("ck_attack_spam_protection", "1", "on/off - max 40 shots; +5 new/extra shots per minute; 1 he/flash counts like 9 shots", _, true, 0.0, true, 1.0);
	g_hRadioCommands = AutoExecConfig_CreateConVar("ck_use_radio", "0", "on/off - Allows players to use radio commands", _, true, 0.0, true, 1.0);
	g_hAutohealing_Hp = AutoExecConfig_CreateConVar("ck_autoheal", "50", "Sets HP amount for autohealing (requires ck_godmode 0)", _, true, 0.0, true, 100.0);
	g_hDynamicTimelimit = AutoExecConfig_CreateConVar("ck_dynamic_timelimit", "0", "on/off - Sets a suitable timelimit by calculating the average run time (This method requires ck_map_end 1, greater than 5 map times and a default timelimit in your server config for maps with less than 5 times", _, true, 0.0, true, 1.0);
	g_hWelcomeMsg = AutoExecConfig_CreateConVar("ck_welcome_msg", "{yellow}>>{default} {grey}Welcome! This server is using {lime}SurfTimer", "Welcome message (supported color tags: {default}, {darkred}, {green}, {lightgreen}, {blue} {olive}, {lime}, {red}, {purple}, {grey}, {yellow}, {lightblue}, {darkblue}, {pink}, {lightred})");
	g_hChecker = AutoExecConfig_CreateConVar("ck_zone_checker", "5.0", "The duration in seconds when the beams around zones are refreshed.");
	g_hZoneDisplayType = AutoExecConfig_CreateConVar("ck_zone_drawstyle", "0", "0 = Do not display zones, 1 = display the lower edges of zones, 2 = display whole zones");
	g_hZonesToDisplay = AutoExecConfig_CreateConVar("ck_zone_drawzones", "1", "Which zones are visible for players. 1 = draw start & end zones, 2 = draw start, end, stage and bonus zones, 3 = draw all zones.");
	g_hSpawnToStartZone = AutoExecConfig_CreateConVar("ck_spawn_to_start_zone", "1.0", "1 = Automatically spawn to the start zone when the client joins the team.", _, true, 0.0, true, 1.0);
	g_hSoundEnabled = AutoExecConfig_CreateConVar("ck_startzone_sound_enabled", "1.0", "Enable the sound after leaving the start zone.", _, true, 0.0, true, 1.0);
	g_hSoundPath = AutoExecConfig_CreateConVar("ck_startzone_sound_path", "buttons\\button3.wav", "The path to the sound file that plays after the client leaves the start zone..");
	g_hAnnounceRank = AutoExecConfig_CreateConVar("ck_min_rank_announce", "0", "Higher ranks than this won't be announced to the everyone on the server. 0 = Announce all records.", _, true, 0.0);
	g_hAnnounceRecord = AutoExecConfig_CreateConVar("ck_chat_record_type", "0", "0: Announce all times to chat, 1: Only announce PB's to chat, 2: Only announce SR's to chat", _, true, 0.0, true, 2.0);
	g_hForceCT = AutoExecConfig_CreateConVar("ck_force_players_ct", "0", "Forces all players to join the CT team.", _, true, 0.0, true, 1.0);
	g_hChatSpamFilter = AutoExecConfig_CreateConVar("ck_chat_spamprotection_time", "1.0", "The frequency in seconds that players are allowed to send chat messages. 0.0 = No chat cap.", _, true, 0.0);
	g_henableChatProcessing = AutoExecConfig_CreateConVar("ck_chat_enable", "1", "(1 / 0) Enable or disable SurfTimers chat processing.");
	g_hMultiServerMapcycle = AutoExecConfig_CreateConVar("ck_multi_server_mapcycle", "0", "0 = Use mapcycle.txt to load servers maps, 1 = use configs/surftimer/multi_server_mapcycle.txt to load maps", _, true, 0.0, true, 1.0);
	g_hDBMapcycle = AutoExecConfig_CreateConVar("ck_db_mapcycle", "1", "0 = use non-db map cycles, 1 use maps from ck_maptier", _, true, 0.0, true, 1.0);
	g_hDoubleRestartCommand = AutoExecConfig_CreateConVar("ck_double_restart_command", "1", "(1 / 0) Requires 2 successive !r commands to restart the player to prevent accidental usage.", _, true, 0.0, true, 1.0);
	g_hBackupReplays = AutoExecConfig_CreateConVar("ck_replay_backup", "1", "(1 / 0) Back up replay files, when they are being replaced", _, true, 0.0, true, 1.0);
	g_hReplaceReplayTime = 	AutoExecConfig_CreateConVar("ck_replay_replace_faster", "1", "(1 / 0) Replace record bots if a players time is faster than the bot, even if the time is not a server record.", _, true, 0.0, true, 1.0);
	g_hTeleToStartWhenSettingsLoaded = AutoExecConfig_CreateConVar("ck_teleportclientstostart", "1", "(1 / 0) Teleport players automatically back to the start zone, when their settings have been loaded.", _, true, 0.0, true, 1.0);
	g_drDeleteSecurity = AutoExecConfig_CreateConVar("ck_dr_delete_security", "1", "(1 / 0) Enable/Disable delete security for !dr command", _, true, 0.0, true, 1.0);
	g_iAdminCountryTags = AutoExecConfig_CreateConVar("ck_admin_country_tags", "0", "(1 / 0) Enable/Disable country tags for admins", _, true, 0.0, true, 1.0);
	g_replayBotDelay = AutoExecConfig_CreateConVar("ck_replay_bot_delay", "10", "Delay in seconds after initial mapstart after the bots join the server", _, true, 10.0);
	g_iHintsInterval = AutoExecConfig_CreateConVar("ck_hints_interval", "240", "Seconds between two hints. Leave empty or set to 0 to disable", _, true, 0.0);
	g_bHintsRandomOrder = AutoExecConfig_CreateConVar("ck_hints_random_order", "1", "(1 / 0) Enable/Disable hints shown in a random order", _, true, 0.0, true, 1.0);
	g_hOverrideClantag = AutoExecConfig_CreateConVar("ck_override_clantag", "1", "Override player's clantag", _, true, 0.0, true, 1.0);
	g_hReplayPre = AutoExecConfig_CreateConVar("ck_replay_pre", "1", "Maximum amount of seconds for prestrafe recording", _, true, 1.0);
	g_hDefaultPreSpeed = AutoExecConfig_CreateConVar("ck_default_prespeed", "260", "Set the default prespeed value.");

	g_hPointSystem = AutoExecConfig_CreateConVar("ck_point_system", "1", "on/off - Player point system", _, true, 0.0, true, 1.0);
	HookConVarChange(g_hPointSystem, OnSettingChanged);
	g_hPlayerSkinChange = AutoExecConfig_CreateConVar("ck_custom_models", "1", "on/off - Allows SurfTimer to change the models of players and bots", _, true, 0.0, true, 1.0);
	HookConVarChange(g_hPlayerSkinChange, OnSettingChanged);
	g_hReplayBotPlayerModel = AutoExecConfig_CreateConVar("ck_replay_bot_skin", "models/player/tm_professional_var1.mdl", "Replay pro bot skin");
	HookConVarChange(g_hReplayBotPlayerModel, OnSettingChanged);
	g_hReplayBotArmModel = AutoExecConfig_CreateConVar("ck_replay_bot_arm_skin", "models/weapons/t_arms_professional.mdl", "Replay pro bot arm skin");
	HookConVarChange(g_hReplayBotArmModel, OnSettingChanged);
	g_hPlayerModel = AutoExecConfig_CreateConVar("ck_player_skin", "models/player/ctm_sas_varianta.mdl", "Player skin");
	HookConVarChange(g_hPlayerModel, OnSettingChanged);
	g_hArmModel = AutoExecConfig_CreateConVar("ck_player_arm_skin", "models/weapons/ct_arms_sas.mdl", "Player arm skin");
	HookConVarChange(g_hArmModel, OnSettingChanged);
	g_hAutoBhopConVar = AutoExecConfig_CreateConVar("ck_auto_bhop", "1", "on/off - AutoBhop on surf_ maps", _, true, 0.0, true, 1.0);
	HookConVarChange(g_hAutoBhopConVar, OnSettingChanged);
	g_hCleanWeapons = AutoExecConfig_CreateConVar("ck_clean_weapons", "1", "on/off - Removes all weapons on the ground", _, true, 0.0, true, 1.0);
	HookConVarChange(g_hCleanWeapons, OnSettingChanged);
	g_hCountry = AutoExecConfig_CreateConVar("ck_country_tag", "1", "on/off - Country clan tag", _, true, 0.0, true, 1.0);
	HookConVarChange(g_hCountry, OnSettingChanged);
	g_hAutoRespawn = AutoExecConfig_CreateConVar("ck_autorespawn", "1", "on/off - Auto respawn", _, true, 0.0, true, 1.0);
	HookConVarChange(g_hAutoRespawn, OnSettingChanged);
	g_hCvarNoBlock = AutoExecConfig_CreateConVar("ck_noblock", "1", "on/off - Player no blocking", _, true, 0.0, true, 1.0);
	HookConVarChange(g_hCvarNoBlock, OnSettingChanged);
	g_hReplayBot = AutoExecConfig_CreateConVar("ck_replay_bot", "1", "on/off - Bots mimic the local map record", _, true, 0.0, true, 1.0);
	HookConVarChange(g_hReplayBot, OnSettingChanged);
	g_hBonusBot = AutoExecConfig_CreateConVar("ck_bonus_bot", "1", "on/off - Bots mimic the local bonus record", _, true, 0.0, true, 1.0);
	HookConVarChange(g_hBonusBot, OnSettingChanged);
	g_hInfoBot = AutoExecConfig_CreateConVar("ck_info_bot", "0", "on/off - provides information about nextmap and timeleft in his player name", _, true, 0.0, true, 1.0);
	HookConVarChange(g_hInfoBot, OnSettingChanged);
	g_hWrcpBot = AutoExecConfig_CreateConVar("ck_wrcp_bot", "1", "on/off - Bots mimic the local stage records", _, true, 0.0, true, 1.0);
	HookConVarChange(g_hWrcpBot, OnSettingChanged);

	g_hReplayBotColor = AutoExecConfig_CreateConVar("ck_replay_bot_color", "52 91 248", "The default replay bot color - Format: \"red green blue\" from 0 - 255.");
	HookConVarChange(g_hReplayBotColor, OnSettingChanged);
	char szRBotColor[256];
	GetConVarString(g_hReplayBotColor, szRBotColor, 256);
	GetRGBColor(0, szRBotColor);

	g_hBonusBotColor = AutoExecConfig_CreateConVar("ck_bonus_bot_color", "255 255 20", "The bonus replay bot color - Format: \"red green blue\" from 0 - 255.");
	HookConVarChange(g_hBonusBotColor, OnSettingChanged);
	szRBotColor = "";
	GetConVarString(g_hBonusBotColor, szRBotColor, 256);
	GetRGBColor(1, szRBotColor);

	g_hzoneStartColor = AutoExecConfig_CreateConVar("ck_zone_startcolor", "000 255 000", "The color of START zones \"red green blue\" from 0 - 255");
	GetConVarString(g_hzoneStartColor, g_szZoneColors[1], 24);
	StringRGBtoInt(g_szZoneColors[1], g_iZoneColors[1]);
	HookConVarChange(g_hzoneStartColor, OnSettingChanged);

	g_hzoneEndColor = AutoExecConfig_CreateConVar("ck_zone_endcolor", "255 000 000", "The color of END zones \"red green blue\" from 0 - 255");
	GetConVarString(g_hzoneEndColor, g_szZoneColors[2], 24);
	StringRGBtoInt(g_szZoneColors[2], g_iZoneColors[2]);
	HookConVarChange(g_hzoneEndColor, OnSettingChanged);

	g_hzoneCheckerColor = AutoExecConfig_CreateConVar("ck_zone_checkercolor", "255 255 000", "The color of CHECKER zones \"red green blue\" from 0 - 255");
	GetConVarString(g_hzoneCheckerColor, g_szZoneColors[10], 24);
	StringRGBtoInt(g_szZoneColors[10], g_iZoneColors[10]);
	HookConVarChange(g_hzoneCheckerColor, OnSettingChanged);

	g_hzoneBonusStartColor = AutoExecConfig_CreateConVar("ck_zone_bonusstartcolor", "000 255 255", "The color of BONUS START zones \"red green blue\" from 0 - 255");
	GetConVarString(g_hzoneBonusStartColor, g_szZoneColors[3], 24);
	StringRGBtoInt(g_szZoneColors[3], g_iZoneColors[3]);
	HookConVarChange(g_hzoneBonusStartColor, OnSettingChanged);

	g_hzoneBonusEndColor = AutoExecConfig_CreateConVar("ck_zone_bonusendcolor", "255 000 255", "The color of BONUS END zones \"red green blue\" from 0 - 255");
	GetConVarString(g_hzoneBonusEndColor, g_szZoneColors[4], 24);
	StringRGBtoInt(g_szZoneColors[4], g_iZoneColors[4]);
	HookConVarChange(g_hzoneBonusEndColor, OnSettingChanged);

	g_hzoneStageColor = AutoExecConfig_CreateConVar("ck_zone_stagecolor", "000 000 255", "The color of STAGE zones \"red green blue\" from 0 - 255");
	GetConVarString(g_hzoneStageColor, g_szZoneColors[5], 24);
	StringRGBtoInt(g_szZoneColors[5], g_iZoneColors[5]);
	HookConVarChange(g_hzoneStageColor, OnSettingChanged);

	g_hzoneCheckpointColor = AutoExecConfig_CreateConVar("ck_zone_checkpointcolor", "000 000 255", "The color of CHECKPOINT zones \"red green blue\" from 0 - 255");
	GetConVarString(g_hzoneCheckpointColor, g_szZoneColors[6], 24);
	StringRGBtoInt(g_szZoneColors[6], g_iZoneColors[6]);
	HookConVarChange(g_hzoneCheckpointColor, OnSettingChanged);

	g_hzoneSpeedColor = AutoExecConfig_CreateConVar("ck_zone_speedcolor", "255 000 000", "The color of SPEED zones \"red green blue\" from 0 - 255");
	GetConVarString(g_hzoneSpeedColor, g_szZoneColors[7], 24);
	StringRGBtoInt(g_szZoneColors[7], g_iZoneColors[7]);
	HookConVarChange(g_hzoneSpeedColor, OnSettingChanged);

	g_hzoneTeleToStartColor = AutoExecConfig_CreateConVar("ck_zone_teletostartcolor", "255 255 000", "The color of TELETOSTART zones \"red green blue\" from 0 - 255");
	GetConVarString(g_hzoneTeleToStartColor, g_szZoneColors[8], 24);
	StringRGBtoInt(g_szZoneColors[8], g_iZoneColors[8]);
	HookConVarChange(g_hzoneTeleToStartColor, OnSettingChanged);

	g_hzoneValidatorColor = AutoExecConfig_CreateConVar("ck_zone_validatorcolor", "255 255 255", "The color of VALIDATOR zones \"red green blue\" from 0 - 255");
	GetConVarString(g_hzoneValidatorColor, g_szZoneColors[9], 24);
	StringRGBtoInt(g_szZoneColors[9], g_iZoneColors[9]);
	HookConVarChange(g_hzoneValidatorColor, OnSettingChanged);

	g_hzoneStopColor = AutoExecConfig_CreateConVar("ck_zone_stopcolor", "000 000 000", "The color of CHECKER zones \"red green blue\" from 0 - 255");
	GetConVarString(g_hzoneStopColor, g_szZoneColors[0], 24);
	StringRGBtoInt(g_szZoneColors[0], g_iZoneColors[0]);
	HookConVarChange(g_hzoneStopColor, OnSettingChanged);

	bool validFlag;
	char szFlag[24];
	AdminFlag bufferFlag;
	g_hAdminMenuFlag = AutoExecConfig_CreateConVar("ck_adminmenu_flag", "z", "Admin flag required to open the !ckadmin menu. Invalid or not set, requires flag z. Requires a server restart.");
	GetConVarString(g_hAdminMenuFlag, szFlag, 24);
	validFlag = FindFlagByChar(szFlag[0], bufferFlag);
	if (!validFlag)
	{
		PrintToServer("SurfTimer | Invalid flag for ck_adminmenu_flag.");
		g_AdminMenuFlag = ADMFLAG_ROOT;
	}
	else
	{
		g_AdminMenuFlag = FlagToBit(bufferFlag);
	}
	HookConVarChange(g_hAdminMenuFlag, OnSettingChanged);

	g_hZonerFlag = AutoExecConfig_CreateConVar("ck_zoner_flag", "z", "Zoner status will automatically be granted to players with this flag. If the convar is invalid or not set, z (root) will be used by default.");
	GetConVarString(g_hZonerFlag, szFlag, 24);
	validFlag = FindFlagByChar(szFlag[0], bufferFlag);
	if (!validFlag)
	{
		LogError("SurfTimer | Invalid flag for ck_zoner_flag, using ADMFLAG_ROOT");
		g_ZonerFlag = ADMFLAG_ROOT;
	}
	else
	{
		g_ZonerFlag = FlagToBit(bufferFlag);
	}
	HookConVarChange(g_hZonerFlag, OnSettingChanged);

	// Map Setting ConVars
	g_hGravityFix = AutoExecConfig_CreateConVar("ck_gravityfix_enable", "1", "Enables/Disables trigger_gravity fix", _, true, 0.0, true, 1.0);

	// VIP ConVars
	g_hAutoVipFlag = AutoExecConfig_CreateConVar("ck_vip_flag", "a", "VIP status will be automatically granted to players with this flag. If the convar is invalid or not set, a (reservation) will be used by default.");
	GetConVarString(g_hAutoVipFlag, szFlag, 24);
	validFlag = FindFlagByChar(szFlag[0], bufferFlag);
	if (!validFlag)
	{
		LogError("SurfTimer | Invalid flag for ck_vip_flag");
		g_VipFlag = ADMFLAG_RESERVATION;
	}
	else
	{
		g_VipFlag = FlagToBit(bufferFlag);
	}
	HookConVarChange(g_hAutoVipFlag, OnSettingChanged);

	// Prestige Server
	g_hPrestigeRank = AutoExecConfig_CreateConVar("ck_prestige_rank", "0", "Rank of players who can join the server, 0 to disable");
	g_hPrestigeStyles = AutoExecConfig_CreateConVar("ck_prestige_all_styles", "1", "If enabled, players must be the rank of ck_prestige_rank in ANY style");
	g_hPrestigeVip = AutoExecConfig_CreateConVar("ck_prestige_rank_vip", "1", "if enabled, VIPs will ingore the prestige rank");

	// One Jump Limit
	g_hOneJumpLimit = AutoExecConfig_CreateConVar("ck_one_jump_limit", "1", "Enables/Disables the one jump limit globally for all zones");

	// Cross Server Announcements
	g_hRecordAnnounce = AutoExecConfig_CreateConVar("ck_announce_records", "0", "Enables/Disables cross-server announcements");

	g_hServerID = AutoExecConfig_CreateConVar("ck_server_id", "-1", "Sets the server ID, each server needs a valid id that is UNIQUE");
	HookConVarChange(g_hServerID, OnSettingChanged);

	g_hSidewaysBlockKeys = AutoExecConfig_CreateConVar("ck_sideways_block_keys", "0", "Changes the functionality of sideways, 1 will block keys, 0 will change the clients style to normal if not surfing sideways");

	g_hEnforceDefaultTitles = AutoExecConfig_CreateConVar("ck_enforce_default_titles", "0", "Sets whether default titles will be enforced on clients, Enable / Disable");
	HookConVarChange(g_hEnforceDefaultTitles, OnSettingChanged);

	// SaveLoc
	g_hAllowCheckpointRecreation = AutoExecConfig_CreateConVar("ck_allow_checkpoint_recreation", "0", "Allow player checkpoint recreation (saveloc). 0 - Disabled | 1 - Print info to player chat | 2 - Print info to player console | 3 - Print info to both chat and console");

	// WRCP Points
	g_hWrcpPoints = AutoExecConfig_CreateConVar("ck_wrcp_points", "0", "Sets the amount of points a player should get for a WRCP, 0 to disable");

	// Play Replay
	g_hPlayReplayVipOnly = AutoExecConfig_CreateConVar("ck_play_replay_vip_only", "1", "Sets whether the sm_replay command will be VIP only Disable/Enable");

	// Sound Convars
	g_hSoundPathWR = AutoExecConfig_CreateConVar("ck_sp_wr", "sound/surftimer/wr.mp3", "Set the sound path for the WR sound");
	HookConVarChange(g_hSoundPathWR, OnSettingChanged);
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

	g_hSoundPathTop = AutoExecConfig_CreateConVar("ck_sp_top", "sound/surftimer/top10.mp3", "Set the sound path for the Top 10 sound");
	HookConVarChange(g_hSoundPathTop, OnSettingChanged);
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

	g_hSoundPathPB = AutoExecConfig_CreateConVar("ck_sp_pb", "sound/surftimer/pr.mp3", "Set the sound path for the PB sound");
	HookConVarChange(g_hSoundPathPB, OnSettingChanged);
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

	g_hSoundPathWRCP = AutoExecConfig_CreateConVar("ck_sp_wrcp", "sound/physics/glass/glass_bottle_break2.wav", "Set the sound path for the WRCP sound");
	HookConVarChange(g_hSoundPathWRCP, OnSettingChanged);
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

	g_hMustPassCheckpoints = AutoExecConfig_CreateConVar("ck_enforce_checkpoints", "1", "Sets whether a player must pass all checkpoints to finish their run. Enable/Disable");

	g_hSlayOnRoundEnd = AutoExecConfig_CreateConVar("ck_slay_on_round_end", "1", "If enabled, all players will be slain on round end. If disabled all players timers will be stopped on round end");

	g_hLimitSpeedType = AutoExecConfig_CreateConVar("ck_limit_speed_type", "1", "1 Use new style of limiting speed, 0 use old/cksurf way");
	g_hLogQueryTimes = AutoExecConfig_CreateConVar("ck_log_query_times", "1", "Log query times or just print in server console. Default \"0\", it'll just print into servers console.", _, true, 0.0, true, 1.0);

	// Server Name
	g_hHostName = FindConVar("hostname");
	HookConVarChange(g_hHostName, OnSettingChanged);
	GetConVarString(g_hHostName, g_sServerName, sizeof(g_sServerName));

	// Chat Prefix
	GetConVarString(g_hChatPrefix, g_szChatPrefix, sizeof(g_szChatPrefix));
	HookConVarChange(g_hChatPrefix, OnSettingChanged);

	// Client side autobhop
	g_hAutoBhop = FindConVar("sv_autobunnyhopping");
	g_hEnableBhop = FindConVar("sv_enablebunnyhopping");

	SetConVarBool(g_hAutoBhop, true);
	SetConVarBool(g_hEnableBhop, true);

	// Show Triggers
	g_Offset_m_fEffects = FindSendPropInfo("CBaseEntity", "m_fEffects");

	// Server Tickate
	g_iTickrate = RoundFloat(1 / GetTickInterval());
	g_fTickrate = (1 / GetTickInterval());

	// Footsteps
	g_hFootsteps = FindConVar("sv_footsteps");

	// New noclip
	sv_noclipspeed = FindConVar("sv_noclipspeed");
	sv_noclipspeed.Flags &= ~(FCVAR_NOTIFY | FCVAR_REPLICATED);
	g_iDefaultNoclipSpeed = sv_noclipspeed.FloatValue;
	for(int i = 1; i <= MaxClients; i++)
	{
		g_iNoclipSpeed[i] = g_iDefaultNoclipSpeed;
	}

	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
}
