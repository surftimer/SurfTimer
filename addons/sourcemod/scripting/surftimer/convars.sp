void CreateConVars()
{
  CreateConVar("timer_version", VERSION, "Timer Version.", FCVAR_DONTRECORD | FCVAR_SPONLY | FCVAR_REPLICATED | FCVAR_NOTIFY);
  
  g_hConnectMsg = CreateConVar("ck_connect_msg", "1", "on/off - Enables a player connect message with country", FCVAR_NOTIFY, true, 0.0, true, 1.0);
  g_hAllowRoundEndCvar = CreateConVar("ck_round_end", "0", "on/off - Allows to end the current round", FCVAR_NOTIFY, true, 0.0, true, 1.0);
  g_hDisconnectMsg = CreateConVar("ck_disconnect_msg", "1", "on/off - Enables a player disconnect message in chat", FCVAR_NOTIFY, true, 0.0, true, 1.0);
  g_hMapEnd = CreateConVar("ck_map_end", "1", "on/off - Allows map changes after the timelimit has run out (mp_timelimit must be greater than 0)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
  g_hColoredNames = CreateConVar("ck_colored_chatnames", "0", "on/off Colors players names based on their rank in chat.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
  g_hNoClipS = CreateConVar("ck_noclip", "1", "on/off - Allows players to use noclip", FCVAR_NOTIFY, true, 0.0, true, 1.0);
  g_hGoToServer = CreateConVar("ck_goto", "1", "on/off - Allows players to use the !goto command", FCVAR_NOTIFY, true, 0.0, true, 1.0);
  g_hCommandToEnd = CreateConVar("ck_end", "1", "on/off - Allows players to use the !end command", FCVAR_NOTIFY, true, 0.0, true, 1.0);
  g_hCvarGodMode = CreateConVar("ck_godmode", "1", "on/off - unlimited hp", FCVAR_NOTIFY, true, 0.0, true, 1.0);
  g_hPauseServerside = CreateConVar("ck_pause", "1", "on/off - Allows players to use the !pause command", FCVAR_NOTIFY, true, 0.0, true, 1.0);
  g_hcvarRestore = CreateConVar("ck_restore", "1", "on/off - Restoring of time and last position after reconnect", FCVAR_NOTIFY, true, 0.0, true, 1.0);
  g_hAttackSpamProtection = CreateConVar("ck_attack_spam_protection", "1", "on/off - max 40 shots; +5 new/extra shots per minute; 1 he/flash counts like 9 shots", FCVAR_NOTIFY, true, 0.0, true, 1.0);
  g_hRadioCommands = CreateConVar("ck_use_radio", "0", "on/off - Allows players to use radio commands", FCVAR_NOTIFY, true, 0.0, true, 1.0);
  g_hAutohealing_Hp = CreateConVar("ck_autoheal", "50", "Sets HP amount for autohealing (requires ck_godmode 0)", FCVAR_NOTIFY, true, 0.0, true, 100.0);
  g_hDynamicTimelimit = CreateConVar("ck_dynamic_timelimit", "0", "on/off - Sets a suitable timelimit by calculating the average run time (This method requires ck_map_end 1, greater than 5 map times and a default timelimit in your server config for maps with less than 5 times", FCVAR_NOTIFY, true, 0.0, true, 1.0);
  g_hWelcomeMsg = CreateConVar("ck_welcome_msg", " {yellow}>>{default} {grey}Welcome! This server is using {lime}Surftimer", "Welcome message (supported color tags: {default}, {darkred}, {green}, {lightgreen}, {blue} {olive}, {lime}, {red}, {purple}, {grey}, {yellow}, {lightblue}, {steelblue}, {darkblue}, {pink}, {lightred})", FCVAR_NOTIFY);
  g_hChecker = CreateConVar("ck_zone_checker", "5.0", "The duration in seconds when the beams around zones are refreshed.", FCVAR_NOTIFY);
  g_hZoneDisplayType = CreateConVar("ck_zone_drawstyle", "2", "0 = Do not display zones, 1 = display the lower edges of zones, 2 = display whole zones", FCVAR_NOTIFY);
  g_hZonesToDisplay = CreateConVar("ck_zone_drawzones", "2", "Which zones are visible for players. 1 = draw start & end zones, 2 = draw start, end, stage and bonus zones, 3 = draw all zones.", FCVAR_NOTIFY);
  g_hStartPreSpeed = CreateConVar("ck_pre_start_speed", "350.0", "The maximum prespeed for start zones. 0.0 = No cap", FCVAR_NOTIFY, true, 0.0, true, 3500.0);
  g_hSpeedPreSpeed = CreateConVar("ck_pre_speed_speed", "3000.0", "The maximum prespeed for speed start zones. 0.0 = No cap", FCVAR_NOTIFY, true, 0.0, true, 3500.0);
  g_hBonusPreSpeed = CreateConVar("ck_pre_bonus_speed", "350.0", "The maximum prespeed for bonus start zones. 0.0 = No cap", FCVAR_NOTIFY, true, 0.0, true, 3500.0);
  //g_hStagePreSpeed = CreateConVar("ck_prestage_speed", "0.0", "The maximum prespeed for stage start zones. 0.0 = No cap", FCVAR_NOTIFY, true, 0.0, true, 3500.0);
  g_hSpawnToStartZone = CreateConVar("ck_spawn_to_start_zone", "1.0", "1 = Automatically spawn to the start zone when the client joins the team.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
  g_hSoundEnabled = CreateConVar("ck_startzone_sound_enabled", "1.0", "Enable the sound after leaving the start zone.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
  g_hSoundPath = CreateConVar("ck_startzone_sound_path", "buttons\\button3.wav", "The path to the sound file that plays after the client leaves the start zone..", FCVAR_NOTIFY);
  g_hAnnounceRank = CreateConVar("ck_min_rank_announce", "0", "Higher ranks than this won't be announced to the everyone on the server. 0 = Announce all records.", FCVAR_NOTIFY, true, 0.0);
  g_hAnnounceRecord = CreateConVar("ck_chat_record_type", "0", "0: Announce all times to chat, 1: Only announce PB's to chat, 2: Only announce SR's to chat", FCVAR_NOTIFY, true, 0.0, true, 2.0);
  g_hForceCT = CreateConVar("ck_force_players_ct", "0", "Forces all players to join the CT team.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
  g_hChatSpamFilter = CreateConVar("ck_chat_spamprotection_time", "1.0", "The frequency in seconds that players are allowed to send chat messages. 0.0 = No chat cap.", FCVAR_NOTIFY, true, 0.0);
  g_henableChatProcessing = CreateConVar("ck_chat_enable", "1", "(1 / 0) Enable or disable Surftimers chat processing.", FCVAR_NOTIFY);
  g_hMultiServerMapcycle = CreateConVar("ck_multi_server_mapcycle", "0", "0 = Use mapcycle.txt to load servers maps, 1 = use configs/surftimer/multi_server_mapcycle.txt to load maps", FCVAR_NOTIFY, true, 0.0, true, 1.0);
  g_hDBMapcycle = CreateConVar("ck_db_mapcycle", "1", "0 = use non-db map cycles, 1 use maps from ck_maptier", FCVAR_NOTIFY, true, 0.0, true, 1.0);
  g_hTriggerPushFixEnable = CreateConVar("ck_triggerpushfix_enable", "1", "Enables trigger push fix.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
  g_hSlopeFixEnable = CreateConVar("ck_slopefix_enable", "1", "Enables slope fix.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
  g_hDoubleRestartCommand = CreateConVar("ck_double_restart_command", "1", "(1 / 0) Requires 2 successive !r commands to restart the player to prevent accidental usage.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
  g_hBackupReplays = CreateConVar("ck_replay_backup", "1", "(1 / 0) Back up replay files, when they are being replaced", FCVAR_NOTIFY, true, 0.0, true, 1.0);
  g_hReplaceReplayTime = 	CreateConVar("ck_replay_replace_faster", "1", "(1 / 0) Replace record bots if a players time is faster than the bot, even if the time is not a server record.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
  g_hTeleToStartWhenSettingsLoaded = CreateConVar("ck_teleportclientstostart", "1", "(1 / 0) Teleport players automatically back to the start zone, when their settings have been loaded.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
  
  g_hPointSystem = CreateConVar("ck_point_system", "1", "on/off - Player point system", FCVAR_NOTIFY, true, 0.0, true, 1.0);
  HookConVarChange(g_hPointSystem, OnSettingChanged);
  g_hPlayerSkinChange = CreateConVar("ck_custom_models", "1", "on/off - Allows Surftimer to change the models of players and bots", FCVAR_NOTIFY, true, 0.0, true, 1.0);
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
    PrintToServer("Surftimer | Invalid flag for ck_adminmenu_flag.");
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
    PrintToServer("Surftimer | Invalid flag for ck_zoner_flag.");
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
    LogError("Surftimer | Invalid flag for ck_vip_flag");
    g_VipFlag = ADMFLAG_RESERVATION;
  }
  else
  g_VipFlag = FlagToBit(bufferFlag);
  HookConVarChange(g_hAutoVipFlag, OnSettingChanged);
  
  // g_hCustomTitlesFlag = CreateConVar("ck_customtitles_flag", "a", "Which flag must players have to use Custom Titles. Invalid or not set, disables Custom Titles.", FCVAR_NOTIFY);
  // GetConVarString(g_hCustomTitlesFlag, szFlag, 24);
  // g_bCustomTitlesFlag = FindFlagByChar(szFlag[0], bufferFlag);
  // g_CustomTitlesFlag = FlagToBit(bufferFlag);
  // HookConVarChange(g_hCustomTitlesFlag, OnSettingChanged);
  
  // Prestige Server
  g_hPrestigeRank = CreateConVar("ck_prestige_rank", "0", "Rank of players who can join the server, 0 to disable");
  
  // Surf / Bhop
  g_hServerType = CreateConVar("ck_server_type", "0", "Change the timer to function for Surf or Bhop, 0 = surf, 1 = bhop (Note: Currently does nothing)");
  HookConVarChange(g_hServerType, OnSettingChanged);
  
  // One Jump Limit
  g_hOneJumpLimit = CreateConVar("ck_one_jump_limit", "1", "Enables/Disables the one jump limit globally for all zones");
  
  // Cross Server Announcements
  g_hRecordAnnounce = CreateConVar("ck_announce_records", "0", "Enables/Disables cross-server announcements");
  
  g_hServerID = CreateConVar("ck_server_id", "-1", "Sets the server ID, each server needs a valid id that is UNIQUE");
  HookConVarChange(g_hServerID, OnSettingChanged);
  
  // Discord
  g_hRecordAnnounceDiscord = CreateConVar("ck_announce_records_discord", "", "Web hook link to announce records to discord, keep empty to disable");
  
  g_hReportBugsDiscord = CreateConVar("ck_report_discord", "", "Web hook link to report bugs to discord, keep empty to disable");
  
  g_hCalladminDiscord = CreateConVar("ck_calladmin_discord", "", "Web hook link to allow players to call admin to discord, keep empty to disable");
  
  g_hSidewaysBlockKeys = CreateConVar("ck_sideways_block_keys", "0", "Changes the functionality of sideways, 1 will block keys, 0 will change the clients style to normal if not surfing sideways");
  
  g_hEnforceDefaultTitles = CreateConVar("ck_enforce_default_titles", "0", "Sets whether default titles will be enforced on clients, Enable / Disable");
  HookConVarChange(g_hEnforceDefaultTitles, OnSettingChanged);
  
  // Server Name
  g_hHostName = FindConVar("hostname");
  HookConVarChange(g_hHostName, OnSettingChanged);
  GetConVarString(g_hHostName, g_sServerName, sizeof(g_sServerName));
  
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