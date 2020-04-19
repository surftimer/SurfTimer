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
ConVar g_hRecordAnnounceDiscord = null;							// Web hook link to announce records to discord
ConVar g_hRecordAnnounceDiscordBonus = null;							// Web hook link to announce bonus records to discord
ConVar g_hReportBugsDiscord = null;								// Web hook link to report bugs to discord
ConVar g_hCalladminDiscord = null;								// Web hook link to allow players to call admin to discord
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
ConVar g_dcMapRecordName = null;
ConVar g_dcBonusRecordName = null;
ConVar g_dcCalladminName = null;
ConVar g_dcBugTrackerName = null;
ConVar g_drDeleteSecurity = null;
ConVar g_iAdminCountryTags = null;
ConVar g_replayBotDelay = null;

// Trails
ConVar gCV_PluginEnabled = null;
ConVar gCV_AdminsOnly = null;
ConVar gCV_AllowHide = null;
ConVar gCV_CheapTrails = null;
ConVar gCV_BeamLife = null;
ConVar gCV_BeamWidth = null;
ConVar gCV_RespawnDisable = null;
ConVar gCV_Trails = null;

void CreateConVars()
{
	CreateConVar("timer_version", VERSION, "Timer Version.", FCVAR_DONTRECORD | FCVAR_SPONLY | FCVAR_REPLICATED | FCVAR_NOTIFY);

	g_hChatPrefix = CreateConVar("ck_chat_prefix", "{lime}SurfTimer {default}|", "Determines the prefix used for chat messages", FCVAR_NOTIFY);
	g_hConnectMsg = CreateConVar("ck_connect_msg", "1", "on/off - Enables a player connect message with country tag", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hAllowRoundEndCvar = CreateConVar("ck_round_end", "0", "on/off - Allows to end the current round", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hDisconnectMsg = CreateConVar("ck_disconnect_msg", "1", "on/off - Enables a player disconnect message in chat", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hMapEnd = CreateConVar("ck_map_end", "1", "on/off - Allows map changes after the timelimit has run out (mp_timelimit must be greater than 0)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hColoredNames = CreateConVar("ck_colored_chatnames", "1", "on/off Colors players names based on their rank in chat.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hNoClipS = CreateConVar("ck_noclip", "1", "on/off - Allows players to use noclip", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hGoToServer = CreateConVar("ck_goto", "1", "on/off - Allows players to use the !goto command", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCommandToEnd = CreateConVar("ck_end", "1", "on/off - Allows players to use the !end command", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvarGodMode = CreateConVar("ck_godmode", "1", "on/off - Godmode", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hPauseServerside = CreateConVar("ck_pause", "1", "on/off - Allows players to use the !pause command", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hcvarRestore = CreateConVar("ck_restore", "1", "on/off - Restoring of time and last position after reconnect", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hAttackSpamProtection = CreateConVar("ck_attack_spam_protection", "1", "on/off - max 40 shots; +5 new/extra shots per minute; 1 he/flash counts like 9 shots", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hRadioCommands = CreateConVar("ck_use_radio", "0", "on/off - Allows players to use radio commands", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hAutohealing_Hp = CreateConVar("ck_autoheal", "50", "Sets HP amount for autohealing (requires ck_godmode 0)", FCVAR_NOTIFY, true, 0.0, true, 100.0);
	g_hDynamicTimelimit = CreateConVar("ck_dynamic_timelimit", "0", "on/off - Sets a suitable timelimit by calculating the average run time (This method requires ck_map_end 1, greater than 5 map times and a default timelimit in your server config for maps with less than 5 times", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hWelcomeMsg = CreateConVar("ck_welcome_msg", "{yellow}>>{default} {grey}Welcome! This server is using {lime}SurfTimer", "Welcome message (supported color tags: {default}, {darkred}, {green}, {lightgreen}, {blue} {olive}, {lime}, {red}, {purple}, {grey}, {yellow}, {lightblue}, {darkblue}, {pink}, {lightred})", FCVAR_NOTIFY);
	g_hChecker = CreateConVar("ck_zone_checker", "5.0", "The duration in seconds when the beams around zones are refreshed.", FCVAR_NOTIFY);
	g_hZoneDisplayType = CreateConVar("ck_zone_drawstyle", "0", "0 = Do not display zones, 1 = display the lower edges of zones, 2 = display whole zones", FCVAR_NOTIFY);
	g_hZonesToDisplay = CreateConVar("ck_zone_drawzones", "1", "Which zones are visible for players. 1 = draw start & end zones, 2 = draw start, end, stage and bonus zones, 3 = draw all zones.", FCVAR_NOTIFY);
	g_hSpawnToStartZone = CreateConVar("ck_spawn_to_start_zone", "1.0", "1 = Automatically spawn to the start zone when the client joins the team.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hSoundEnabled = CreateConVar("ck_startzone_sound_enabled", "1.0", "Enable the sound after leaving the start zone.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hSoundPath = CreateConVar("ck_startzone_sound_path", "buttons\\button3.wav", "The path to the sound file that plays after the client leaves the start zone..", FCVAR_NOTIFY);
	g_hAnnounceRank = CreateConVar("ck_min_rank_announce", "0", "Higher ranks than this won't be announced to the everyone on the server. 0 = Announce all records.", FCVAR_NOTIFY, true, 0.0);
	g_hAnnounceRecord = CreateConVar("ck_chat_record_type", "0", "0: Announce all times to chat, 1: Only announce PB's to chat, 2: Only announce SR's to chat", FCVAR_NOTIFY, true, 0.0, true, 2.0);
	g_hForceCT = CreateConVar("ck_force_players_ct", "0", "Forces all players to join the CT team.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hChatSpamFilter = CreateConVar("ck_chat_spamprotection_time", "1.0", "The frequency in seconds that players are allowed to send chat messages. 0.0 = No chat cap.", FCVAR_NOTIFY, true, 0.0);
	g_henableChatProcessing = CreateConVar("ck_chat_enable", "1", "(1 / 0) Enable or disable SurfTimers chat processing.", FCVAR_NOTIFY);
	g_hMultiServerMapcycle = CreateConVar("ck_multi_server_mapcycle", "0", "0 = Use mapcycle.txt to load servers maps, 1 = use configs/surftimer/multi_server_mapcycle.txt to load maps", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hDBMapcycle = CreateConVar("ck_db_mapcycle", "1", "0 = use non-db map cycles, 1 use maps from ck_maptier", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hTriggerPushFixEnable = CreateConVar("ck_triggerpushfix_enable", "1", "Enables trigger push fix.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hSlopeFixEnable = CreateConVar("ck_slopefix_enable", "1", "Enables slope fix.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hDoubleRestartCommand = CreateConVar("ck_double_restart_command", "1", "(1 / 0) Requires 2 successive !r commands to restart the player to prevent accidental usage.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hBackupReplays = CreateConVar("ck_replay_backup", "1", "(1 / 0) Back up replay files, when they are being replaced", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hReplaceReplayTime = 	CreateConVar("ck_replay_replace_faster", "1", "(1 / 0) Replace record bots if a players time is faster than the bot, even if the time is not a server record.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hTeleToStartWhenSettingsLoaded = CreateConVar("ck_teleportclientstostart", "1", "(1 / 0) Teleport players automatically back to the start zone, when their settings have been loaded.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_dcCalladminName = CreateConVar("ck_discord_calladmin_name", "Calladmin", "Webhook name for !calladmin - Discord side", FCVAR_NOTIFY);
	g_dcBugTrackerName = CreateConVar("ck_discord_bug_tracker_name", "Bugtracker", "Webhook name for !bug - Discord side", FCVAR_NOTIFY);
	g_dcBonusRecordName = CreateConVar("ck_discord_bonus_record_name", "Surf Records", "Webhook name for bonus record announcements - Discord side", FCVAR_NOTIFY);
	g_dcMapRecordName = CreateConVar("ck_discord_map_record_name", "Surf Records", "Webhook name for map record announcements - Discord side", FCVAR_NOTIFY);
	g_drDeleteSecurity = CreateConVar("ck_dr_delete_security", "1", "(1 / 0) Disabled/Enable delete security for !dr command", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_iAdminCountryTags = CreateConVar("ck_admin_country_tags", "0", "(1 / 0) Disabled/Enable country tags for admins", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_replayBotDelay = CreateConVar("ck_replay_bot_delay", "10", "Delay in seconds after initial mapstart after the bots join the server", FCVAR_NOTIFY, true, 10.0);
	

	// Trails
	gCV_PluginEnabled = CreateConVar("sm_trails_enable", "1", "Enable or Disable all features of the plugin.", 0, true, 0.0, true, 1.0);
	gCV_AdminsOnly = CreateConVar("sm_trails_admins_only", "1", "Enable trails for admins only.", 0, true, 0.0, true, 1.0);
	gCV_AllowHide = CreateConVar("sm_trails_allow_hide", "1", "Allow hiding other players' trails.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gCV_CheapTrails = CreateConVar("sm_trails_cheap", "0", "Force cheap trails (FPS boost).", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gCV_BeamLife = CreateConVar("sm_trails_life", "2.5", "Time duration of the trails.", FCVAR_NOTIFY, true, 0.0);
	gCV_BeamWidth = CreateConVar("sm_trails_width", "1.5", "Width of the trail beams.", FCVAR_NOTIFY, true, 0.0);
	gCV_RespawnDisable = CreateConVar("sm_trails_respawn_disable", "0", "Disable the player's trail after respawning.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gCV_Trails = CreateConVar("ck_trails_enable", "1", "Enable or Disable trails completely ", FCVAR_NOTIFY, true, 0.0, true, 1.0);

	g_hPointSystem = CreateConVar("ck_point_system", "1", "on/off - Player point system", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	HookConVarChange(g_hPointSystem, OnSettingChanged);
	g_hPlayerSkinChange = CreateConVar("ck_custom_models", "1", "on/off - Allows SurfTimer to change the models of players and bots", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	HookConVarChange(g_hPlayerSkinChange, OnSettingChanged);
	g_hReplayBotPlayerModel = CreateConVar("ck_replay_bot_skin", "models/player/tm_professional_var1.mdl", "Replay pro bot skin", FCVAR_NOTIFY);
	HookConVarChange(g_hReplayBotPlayerModel, OnSettingChanged);
	g_hReplayBotArmModel = CreateConVar("ck_replay_bot_arm_skin", "models/weapons/t_arms_professional.mdl", "Replay pro bot arm skin", FCVAR_NOTIFY);
	HookConVarChange(g_hReplayBotArmModel, OnSettingChanged);
	g_hPlayerModel = CreateConVar("ck_player_skin", "models/player/ctm_sas_varianta.mdl", "Player skin", FCVAR_NOTIFY);
	HookConVarChange(g_hPlayerModel, OnSettingChanged);
	g_hArmModel = CreateConVar("ck_player_arm_skin", "models/weapons/ct_arms_sas.mdl", "Player arm skin", FCVAR_NOTIFY);
	HookConVarChange(g_hArmModel, OnSettingChanged);
	g_hAutoBhopConVar = CreateConVar("ck_auto_bhop", "1", "on/off - AutoBhop on surf_ maps", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	HookConVarChange(g_hAutoBhopConVar, OnSettingChanged);
	g_hCleanWeapons = CreateConVar("ck_clean_weapons", "1", "on/off - Removes all weapons on the ground", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	HookConVarChange(g_hCleanWeapons, OnSettingChanged);
	g_hCountry = CreateConVar("ck_country_tag", "1", "on/off - Country clan tag", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	HookConVarChange(g_hCountry, OnSettingChanged);
	g_hAutoRespawn = CreateConVar("ck_autorespawn", "1", "on/off - Auto respawn", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	HookConVarChange(g_hAutoRespawn, OnSettingChanged);
	g_hCvarNoBlock = CreateConVar("ck_noblock", "1", "on/off - Player no blocking", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	HookConVarChange(g_hCvarNoBlock, OnSettingChanged);
	g_hReplayBot = CreateConVar("ck_replay_bot", "1", "on/off - Bots mimic the local map record", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	HookConVarChange(g_hReplayBot, OnSettingChanged);
	g_hBonusBot = CreateConVar("ck_bonus_bot", "1", "on/off - Bots mimic the local bonus record", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	HookConVarChange(g_hBonusBot, OnSettingChanged);
	g_hInfoBot = CreateConVar("ck_info_bot", "0", "on/off - provides information about nextmap and timeleft in his player name", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	HookConVarChange(g_hInfoBot, OnSettingChanged);
	g_hWrcpBot = CreateConVar("ck_wrcp_bot", "1", "on/off - Bots mimic the local stage records", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	HookConVarChange(g_hWrcpBot, OnSettingChanged);

	g_hReplayBotColor = CreateConVar("ck_replay_bot_color", "52 91 248", "The default replay bot color - Format: \"red green blue\" from 0 - 255.", FCVAR_NOTIFY);
	HookConVarChange(g_hReplayBotColor, OnSettingChanged);
	char szRBotColor[256];
	GetConVarString(g_hReplayBotColor, szRBotColor, 256);
	GetRGBColor(0, szRBotColor);

	g_hBonusBotColor = CreateConVar("ck_bonus_bot_color", "255 255 20", "The bonus replay bot color - Format: \"red green blue\" from 0 - 255.", FCVAR_NOTIFY);
	HookConVarChange(g_hBonusBotColor, OnSettingChanged);
	szRBotColor = "";
	GetConVarString(g_hBonusBotColor, szRBotColor, 256);
	GetRGBColor(1, szRBotColor);

	g_hzoneStartColor = CreateConVar("ck_zone_startcolor", "000 255 000", "The color of START zones \"red green blue\" from 0 - 255", FCVAR_NOTIFY);
	GetConVarString(g_hzoneStartColor, g_szZoneColors[1], 24);
	StringRGBtoInt(g_szZoneColors[1], g_iZoneColors[1]);
	HookConVarChange(g_hzoneStartColor, OnSettingChanged);

	g_hzoneEndColor = CreateConVar("ck_zone_endcolor", "255 000 000", "The color of END zones \"red green blue\" from 0 - 255", FCVAR_NOTIFY);
	GetConVarString(g_hzoneEndColor, g_szZoneColors[2], 24);
	StringRGBtoInt(g_szZoneColors[2], g_iZoneColors[2]);
	HookConVarChange(g_hzoneEndColor, OnSettingChanged);

	g_hzoneCheckerColor = CreateConVar("ck_zone_checkercolor", "255 255 000", "The color of CHECKER zones \"red green blue\" from 0 - 255", FCVAR_NOTIFY);
	GetConVarString(g_hzoneCheckerColor, g_szZoneColors[10], 24);
	StringRGBtoInt(g_szZoneColors[10], g_iZoneColors[10]);
	HookConVarChange(g_hzoneCheckerColor, OnSettingChanged);

	g_hzoneBonusStartColor = CreateConVar("ck_zone_bonusstartcolor", "000 255 255", "The color of BONUS START zones \"red green blue\" from 0 - 255", FCVAR_NOTIFY);
	GetConVarString(g_hzoneBonusStartColor, g_szZoneColors[3], 24);
	StringRGBtoInt(g_szZoneColors[3], g_iZoneColors[3]);
	HookConVarChange(g_hzoneBonusStartColor, OnSettingChanged);

	g_hzoneBonusEndColor = CreateConVar("ck_zone_bonusendcolor", "255 000 255", "The color of BONUS END zones \"red green blue\" from 0 - 255", FCVAR_NOTIFY);
	GetConVarString(g_hzoneBonusEndColor, g_szZoneColors[4], 24);
	StringRGBtoInt(g_szZoneColors[4], g_iZoneColors[4]);
	HookConVarChange(g_hzoneBonusEndColor, OnSettingChanged);

	g_hzoneStageColor = CreateConVar("ck_zone_stagecolor", "000 000 255", "The color of STAGE zones \"red green blue\" from 0 - 255", FCVAR_NOTIFY);
	GetConVarString(g_hzoneStageColor, g_szZoneColors[5], 24);
	StringRGBtoInt(g_szZoneColors[5], g_iZoneColors[5]);
	HookConVarChange(g_hzoneStageColor, OnSettingChanged);

	g_hzoneCheckpointColor = CreateConVar("ck_zone_checkpointcolor", "000 000 255", "The color of CHECKPOINT zones \"red green blue\" from 0 - 255", FCVAR_NOTIFY);
	GetConVarString(g_hzoneCheckpointColor, g_szZoneColors[6], 24);
	StringRGBtoInt(g_szZoneColors[6], g_iZoneColors[6]);
	HookConVarChange(g_hzoneCheckpointColor, OnSettingChanged);

	g_hzoneSpeedColor = CreateConVar("ck_zone_speedcolor", "255 000 000", "The color of SPEED zones \"red green blue\" from 0 - 255", FCVAR_NOTIFY);
	GetConVarString(g_hzoneSpeedColor, g_szZoneColors[7], 24);
	StringRGBtoInt(g_szZoneColors[7], g_iZoneColors[7]);
	HookConVarChange(g_hzoneSpeedColor, OnSettingChanged);

	g_hzoneTeleToStartColor = CreateConVar("ck_zone_teletostartcolor", "255 255 000", "The color of TELETOSTART zones \"red green blue\" from 0 - 255", FCVAR_NOTIFY);
	GetConVarString(g_hzoneTeleToStartColor, g_szZoneColors[8], 24);
	StringRGBtoInt(g_szZoneColors[8], g_iZoneColors[8]);
	HookConVarChange(g_hzoneTeleToStartColor, OnSettingChanged);

	g_hzoneValidatorColor = CreateConVar("ck_zone_validatorcolor", "255 255 255", "The color of VALIDATOR zones \"red green blue\" from 0 - 255", FCVAR_NOTIFY);
	GetConVarString(g_hzoneValidatorColor, g_szZoneColors[9], 24);
	StringRGBtoInt(g_szZoneColors[9], g_iZoneColors[9]);
	HookConVarChange(g_hzoneValidatorColor, OnSettingChanged);

	g_hzoneStopColor = CreateConVar("ck_zone_stopcolor", "000 000 000", "The color of CHECKER zones \"red green blue\" from 0 - 255", FCVAR_NOTIFY);
	GetConVarString(g_hzoneStopColor, g_szZoneColors[0], 24);
	StringRGBtoInt(g_szZoneColors[0], g_iZoneColors[0]);
	HookConVarChange(g_hzoneStopColor, OnSettingChanged);

	bool validFlag;
	char szFlag[24];
	AdminFlag bufferFlag;
	g_hAdminMenuFlag = CreateConVar("ck_adminmenu_flag", "z", "Admin flag required to open the !ckadmin menu. Invalid or not set, requires flag z. Requires a server restart.", FCVAR_NOTIFY);
	GetConVarString(g_hAdminMenuFlag, szFlag, 24);
	validFlag = FindFlagByChar(szFlag[0], bufferFlag);
	if (!validFlag)
	{
		PrintToServer("SurfTimer | Invalid flag for ck_adminmenu_flag.");
		g_AdminMenuFlag = ADMFLAG_ROOT;
	}
	else
		g_AdminMenuFlag = FlagToBit(bufferFlag);
	HookConVarChange(g_hAdminMenuFlag, OnSettingChanged);

	g_hZonerFlag = CreateConVar("ck_zoner_flag", "z", "Zoner status will automatically be granted to players with this flag. If the convar is invalid or not set, z (root) will be used by default.", FCVAR_NOTIFY);
	GetConVarString(g_hZonerFlag, szFlag, 24);
	validFlag = FindFlagByChar(szFlag[0], bufferFlag);
	if (!validFlag)
	{
		LogError("SurfTimer | Invalid flag for ck_zoner_flag, using ADMFLAG_ROOT");
		g_ZonerFlag = ADMFLAG_ROOT;
	}
	else
		g_ZonerFlag = FlagToBit(bufferFlag);
	HookConVarChange(g_hZonerFlag, OnSettingChanged);

	// Map Setting ConVars
	g_hGravityFix = CreateConVar("ck_gravityfix_enable", "1", "Enables/Disables trigger_gravity fix", FCVAR_NOTIFY, true, 0.0, true, 1.0);

	// VIP ConVars
	g_hAutoVipFlag = CreateConVar("ck_vip_flag", "a", "VIP status will be automatically granted to players with this flag. If the convar is invalid or not set, a (reservation) will be used by default.", FCVAR_NOTIFY);
	GetConVarString(g_hAutoVipFlag, szFlag, 24);
	validFlag = FindFlagByChar(szFlag[0], bufferFlag);
	if (!validFlag)
	{
		LogError("SurfTimer | Invalid flag for ck_vip_flag");
		g_VipFlag = ADMFLAG_RESERVATION;
	}
	else
	g_VipFlag = FlagToBit(bufferFlag);
	HookConVarChange(g_hAutoVipFlag, OnSettingChanged);

	// Prestige Server
	g_hPrestigeRank = CreateConVar("ck_prestige_rank", "0", "Rank of players who can join the server, 0 to disable");
	g_hPrestigeStyles = CreateConVar("ck_prestige_all_styles", "1", "If enabled, players must be the rank of ck_prestige_rank in ANY style");
	g_hPrestigeVip = CreateConVar("ck_prestige_rank_vip", "1", "if enabled, VIPs will ingore the prestige rank");

	// One Jump Limit
	g_hOneJumpLimit = CreateConVar("ck_one_jump_limit", "1", "Enables/Disables the one jump limit globally for all zones");

	// Cross Server Announcements
	g_hRecordAnnounce = CreateConVar("ck_announce_records", "0", "Enables/Disables cross-server announcements");

	g_hServerID = CreateConVar("ck_server_id", "-1", "Sets the server ID, each server needs a valid id that is UNIQUE");
	HookConVarChange(g_hServerID, OnSettingChanged);

	// Discord
	g_hRecordAnnounceDiscord = CreateConVar("ck_announce_records_discord", "", "Web hook link to announce records to discord, keep empty to disable");

	g_hRecordAnnounceDiscordBonus = CreateConVar("ck_announce_bonus_records_discord", "", "Web hook link to announce bonus records to discord, keep empty to use ck_announce_records_discord");	

	g_hReportBugsDiscord = CreateConVar("ck_report_discord", "", "Web hook link to report bugs to discord, keep empty to disable");

	g_hCalladminDiscord = CreateConVar("ck_calladmin_discord", "", "Web hook link to allow players to call admin to discord, keep empty to disable");

	g_hSidewaysBlockKeys = CreateConVar("ck_sideways_block_keys", "0", "Changes the functionality of sideways, 1 will block keys, 0 will change the clients style to normal if not surfing sideways");

	g_hEnforceDefaultTitles = CreateConVar("ck_enforce_default_titles", "0", "Sets whether default titles will be enforced on clients, Enable / Disable");
	HookConVarChange(g_hEnforceDefaultTitles, OnSettingChanged);

	// WRCP Points
	g_hWrcpPoints = CreateConVar("ck_wrcp_points", "0", "Sets the amount of points a player should get for a WRCP, 0 to disable");

	// Play Replay
	g_hPlayReplayVipOnly = CreateConVar("ck_play_replay_vip_only", "1", "Sets whether the sm_replay command will be VIP only Disable/Enable");

	// Sound Convars
	g_hSoundPathWR = CreateConVar("ck_sp_wr", "sound/surftimer/wr.mp3", "Set the sound path for the WR sound");
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

	g_hSoundPathTop = CreateConVar("ck_sp_top", "sound/surftimer/top10.mp3", "Set the sound path for the Top 10 sound");
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

	g_hSoundPathPB = CreateConVar("ck_sp_pb", "sound/surftimer/pr.mp3", "Set the sound path for the PB sound");
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

	g_hSoundPathWRCP = CreateConVar("ck_sp_wrcp", "sound/physics/glass/glass_bottle_break2.wav", "Set the sound path for the WRCP sound");
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

	g_hMustPassCheckpoints = CreateConVar("ck_enforce_checkpoints", "1", "Sets whether a player must pass all checkpoints to finish their run. Enable/Disable");

	g_hSlayOnRoundEnd = CreateConVar("ck_slay_on_round_end", "1", "If enabled, all players will be slain on round end. If disabled all players timers will be stopped on round end");

	g_hLimitSpeedType = CreateConVar("ck_limit_speed_type", "1", "1 Use new style of limiting speed, 0 use old/cksurf way");

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

	g_cvar_sv_hibernate_when_empty = FindConVar("sv_hibernate_when_empty");

	if (GetConVarInt(g_cvar_sv_hibernate_when_empty) == 1)
		SetConVarInt(g_cvar_sv_hibernate_when_empty, 0);

	// Show Triggers
	g_Offset_m_fEffects = FindSendPropInfo("CBaseEntity", "m_fEffects");

	// Server Tickate
	g_Server_Tickrate = RoundFloat(1 / GetTickInterval());

	// Footsteps
	g_hFootsteps = FindConVar("sv_footsteps");
}
