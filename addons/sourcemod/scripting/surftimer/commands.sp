/* 
	Surftimer Commands
	TODO: Cleanup and sort commands
*/
void CreateCommands()
{
	// Client Commands
	RegConsoleCmd("sm_usp", Client_Usp, "[surftimer] spawns a usp silencer");
	RegConsoleCmd("sm_glock", Client_Glock, "[surftimer] spawns a glock");
	RegConsoleCmd("sm_avg", Client_Avg, "[surftimer] prints in chat the average time of the current map");
	RegConsoleCmd("sm_hidechat", Client_HideChat, "[surftimer] hides your ingame chat");
	RegConsoleCmd("sm_hideweapon", Client_HideWeapon, "[surftimer] hides your weapon model");
	RegConsoleCmd("sm_disarm", Client_HideWeapon, "[surftimer] hides your weapon model");
	RegAdminCmd("sm_goto", Client_GoTo, ADMFLAG_CUSTOM2, "[surftimer] teleports you to a selected player");
	RegConsoleCmd("sm_sound", Client_QuakeSounds, "[surftimer] on/off quake sounds");
	RegConsoleCmd("sm_bhop", Client_AutoBhop, "[surftimer] on/off autobhop");
	RegConsoleCmd("sm_flashlight", Client_Flashlight, "[surftimer] on/off flashlight");
	RegConsoleCmd("sm_maptop", Client_MapTop, "[surftimer] displays local map top for a given map");
	RegConsoleCmd("sm_wr", Client_Wr, "[surftimer] prints records wr in chat");
	RegConsoleCmd("sm_wrb", Client_Wrb, "[surftimer] prints records wrb in chat");
	RegConsoleCmd("sm_spec", Client_Spec, "[surftimer] chooses a player who you want to spectate and switch you to spectators");
	RegConsoleCmd("sm_watch", Client_Spec, "[surftimer] chooses a player who you want to spectate and switch you to spectators");
	RegConsoleCmd("sm_spectate", Client_Spec, "[surftimer] chooses a player who you want to spectate and switch you to spectators");
	RegConsoleCmd("sm_helpmenu", Client_Help, "[surftimer] help menu which displays all surftimer commands");
	RegConsoleCmd("sm_help", Client_Help, "[surftimer] help menu which displays all surftimer commands");
	RegConsoleCmd("sm_profile", Client_Profile, "[surftimer] opens a player profile");
	RegConsoleCmd("sm_options", Client_OptionMenu, "[surftimer] opens options menu");
	RegConsoleCmd("sm_top", Client_Top, "[surftimer] displays top rankings (Top 100 Players, Top 50 overall)");
	RegConsoleCmd("sm_topsurfers", Client_Top, "[surftimer] displays top rankings (Top 100 Players, Top 50 overall)");
	RegConsoleCmd("sm_bonustop", Client_BonusTop, "[surftimer] displays top rankings of the bonus");
	RegConsoleCmd("sm_btop", Client_BonusTop, "[surftimer] displays top rankings of the bonus");
	RegConsoleCmd("sm_stop", Client_Stop, "[surftimer] stops your timer");
	RegConsoleCmd("sm_ranks", Client_Ranks, "[surftimer] Displays a menu with available player ranks");
	RegConsoleCmd("sm_pause", Client_Pause, "[surftimer] on/off pause (timer on hold and movement frozen)");
	RegConsoleCmd("sm_latest", Client_Latest, "[surftimer] shows latest map records");
	RegConsoleCmd("sm_rr", Client_Latest, "[surftimer] shows latest map records");
	RegConsoleCmd("sm_rb", Client_Latest, "[surftimer] shows latest map records");
	RegConsoleCmd("sm_hide", Client_Hide, "[surftimer] on/off - hides other players");
	RegConsoleCmd("sm_togglecheckpoints", ToggleCheckpoints, "[surftimer] on/off - Enable player checkpoints");
	RegConsoleCmd("+noclip", NoClip, "[surftimer] Player noclip on");
	RegConsoleCmd("-noclip", UnNoClip, "[surftimer] Player noclip off");
	RegConsoleCmd("sm_nc", Command_ckNoClip, "[surftimer] Player noclip on/off");

	// Teleportation Commands
	RegConsoleCmd("sm_stages", Command_SelectStage, "[surftimer] Opens up the stage selector");
	RegConsoleCmd("sm_r", Command_Restart, "[surftimer] Teleports player back to the start");
	RegConsoleCmd("sm_restart", Command_Restart, "[surftimer] Teleports player back to the start");
	RegConsoleCmd("sm_start", Command_Restart, "[surftimer] Teleports player back to the start");
	RegConsoleCmd("sm_b", Command_ToBonus, "[surftimer] Teleports player to the start of a bonus");
	RegConsoleCmd("sm_bonus", Command_ToBonus, "[surftimer] Teleports player to the start of a bonus");
	RegConsoleCmd("sm_bonuses", Command_ListBonuses, "[surftimer] Displays a list of bonuses in current map");
	RegConsoleCmd("sm_s", Command_ToStage, "[surftimer] Teleports player to the selected stage");
	RegConsoleCmd("sm_stage", Command_ToStage, "[surftimer] Teleports player to the selected stage");
	RegConsoleCmd("sm_end", Command_ToEnd, "[surftimer] Teleports player to the end zone");

	// MISC
	RegConsoleCmd("sm_tier", Command_Tier, "[surftimer] Prints information on the current map");
	RegConsoleCmd("sm_maptier", Command_Tier, "[surftimer] Prints information on the current map");
	RegConsoleCmd("sm_mapinfo", Command_Tier, "[surftimer] Prints information on the current map");
	RegConsoleCmd("sm_m", Command_Tier, "[surftimer] Prints information on the current map");
	RegConsoleCmd("sm_difficulty", Command_Tier, "[surftimer] Prints information on the current map");
	RegConsoleCmd("sm_howto", Command_HowTo, "[surftimer] Displays a youtube video on how to surf");


	// Teleport to the start of the stage
	RegConsoleCmd("sm_stuck", Command_Teleport, "[surftimer] Teleports player back to the start of the stage");
	RegConsoleCmd("sm_back", Command_Teleport, "[surftimer] Teleports player back to the start of the stage");
	RegConsoleCmd("sm_rs", Command_Teleport, "[surftimer] Teleports player back to the start of the stage");
	RegConsoleCmd("sm_play", Command_Teleport, "[surftimer] Teleports player back to the start");
	RegConsoleCmd("sm_spawn", Command_Teleport, "[surftimer] Teleports player back to the start");

	// Player Checkpoints
	RegConsoleCmd("sm_teleport", Command_goToPlayerCheckpoint, "[surftimer] Teleports player to his last checkpoint");
	RegConsoleCmd("sm_tele", Command_goToPlayerCheckpoint, "[surftimer] Teleports player to his last checkpoint");
	RegConsoleCmd("sm_prac", Command_goToPlayerCheckpoint, "[surftimer] Teleports player to his last checkpoint");
	RegConsoleCmd("sm_practice", Command_goToPlayerCheckpoint, "[surftimer] Teleports player to his last checkpoint");
	RegConsoleCmd("sm_loadloc", Command_goToPlayerCheckpoint, "[surftimer] Teleports player to his last checkpoint");

	RegConsoleCmd("sm_cp", Command_createPlayerCheckpoint, "[surftimer] Creates a checkpoint, where the player can teleport back to");
	RegConsoleCmd("sm_checkpoint", Command_createPlayerCheckpoint, "[surftimer] Creates a checkpoint, where the player can teleport back to");
	RegConsoleCmd("sm_saveloc", Command_createPlayerCheckpoint, "[surftimer] Creates a checkpoint, where the player can teleport back to");
	RegConsoleCmd("sm_savelocs", Command_SaveLocList);
	RegConsoleCmd("sm_loclist", Command_SaveLocList);
	RegConsoleCmd("sm_normal", Command_normalMode, "[surftimer] Switches player back to normal mode.");
	RegConsoleCmd("sm_n", Command_normalMode, "[surftimer] Switches player back to normal mode.");

	RegConsoleCmd("sm_ckadmin", Admin_ckPanel, "[surftimer] Displays the surftimer admin menu panel");
	RegConsoleCmd("sm_refreshprofile", Admin_RefreshProfile, "[surftimer] Recalculates player profile for given steam id");

	RegConsoleCmd("sm_clearassists", Admin_ClearAssists, "[surftimer] Clears assist points (map progress) from all players");

	RegConsoleCmd("sm_zones", Command_Zones, "[surftimer] [zoner] Opens up the zone creation menu.");
	RegConsoleCmd("sm_hookzone", Command_HookZones, "[surftimer] [zoner] Opens up zone hook creation menu.");
	RegConsoleCmd("sm_addmaptier", Admin_insertMapTier, "[surftimer] [zoner] Changes maps tier");
	RegConsoleCmd("sm_amt", Admin_insertMapTier, "[surftimer] [zoner] Changes maps tier");
	RegConsoleCmd("sm_addspawn", Admin_insertSpawnLocation, "[surftimer] [zoner] Changes the position !r takes players to");
	RegConsoleCmd("sm_delspawn", Admin_deleteSpawnLocation, "[surftimer] [zoner] Removes custom !r position");
	RegConsoleCmd("sm_mapsettings", Admin_MapSettings, "[surftimer] [zoner] Displays menu containing various options to change map settings");
	RegConsoleCmd("sm_ms", Admin_MapSettings, "[surftimer] [zoner] Displays menu containing various options to change map settings");
	RegConsoleCmd("sm_maxvelocity", Command_SetMaxVelocity, "[surftimer] [zoner] Set the current maps maxvelocity");
	RegConsoleCmd("sm_mv", Command_SetMaxVelocity, "[surftimer] [zoner] Set the current maps max velocity");
	RegConsoleCmd("sm_announcerecord", Command_SetAnnounceRecord, "[surftimer] [zoner] Set whether records will be announced on all finishes, pb only or client only");
	RegConsoleCmd("sm_ar", Command_SetAnnounceRecord, "[surftimer] [zoner] Set whether records will be announced on all finishes, pb only or client only");
	RegConsoleCmd("sm_gravityfix", Command_SetGravityFix, "[surftimer] [zoner] Toggle the gravity fix on the current map");
	RegConsoleCmd("sm_gf", Command_SetGravityFix, "[surftimer] [zoner] Toggle the gravity fix on the current map");
	RegConsoleCmd("sm_triggers", Command_ToggleTriggers, "[surftimer] [zoner] Toggle display of map triggers");
	RegConsoleCmd("sm_noclipspeed", Command_NoclipSpeed, "[surftimer] [zoner] Changes the value of sv_noclipspeed");

	// VIP Commands
	RegAdminCmd("sm_fixbot", Admin_FixBot, g_VipFlag, "[surftimer] Toggles replay bots off and on");

	RegConsoleCmd("sm_vip", Command_Vip, "[surftimer] [vip] Displays the VIP menu to client");
	RegConsoleCmd("sm_mytitle", Command_PlayerTitle, "[surftimer] [vip] Displays a menu to the player showing their custom title and allowing them to change their colours");
	RegConsoleCmd("sm_title", Command_PlayerTitle, "[surftimer] [vip] Displays a menu to the player showing their custom title and allowing them to change their colours");
	RegConsoleCmd("sm_customtitle", Command_SetDbTitle, "[surftimer] [vip] VIPs can set their own custom title into a db");
	RegConsoleCmd("sm_namecolour", Command_SetDbNameColour, "[surftimer] [vip] VIPs can set their own custom name colour into the db");
	RegConsoleCmd("sm_textcolour", Command_SetDbTextColour, "[surftimer] [vip] VIPs can set their own custom text colour into the db");
	RegConsoleCmd("sm_ve", Command_VoteExtend, "[surftimer] [vip] Vote to extend the map");
	RegConsoleCmd("sm_colours", Command_ListColours, "[surftimer] Lists available colours for sm_mytitle and sm_namecolour");
	RegConsoleCmd("sm_toggletitle", Command_ToggleTitle, "[surftimer] [vip] VIPs can toggle their title.");
	RegConsoleCmd("sm_joinmsg", Command_JoinMsg, "[surftimer] [vip] Allows a vip to set their join msg");

	// Automatic Donate Commands
	RegAdminCmd("sm_givevip", VIP_GiveVip, ADMFLAG_ROOT, "[surftimer] Give a player VIP");
	RegAdminCmd("sm_removevip", VIP_RemoveVip, ADMFLAG_ROOT, "[surftimer] Remove a players VIP");
	RegAdminCmd("sm_addcredits", VIP_GiveCredits, ADMFLAG_ROOT, "[surftimer] Give a player credits");

	// WRCPs
	RegConsoleCmd("sm_wrcp", Client_Wrcp, "[surftimer] displays stage times for map");
	RegConsoleCmd("sm_wrcps", Client_Wrcp, "[surftimer] displays stage times for map");

	// QOL Commands
	RegConsoleCmd("sm_gb", Command_GoBack, "[surftimer] Go back a stage");
	RegConsoleCmd("sm_goback", Command_GoBack, "[surftimer] Go back a stage");
	RegConsoleCmd("sm_mtop", Client_MapTop, "[surftimer] displays local map top for a given map");
	RegConsoleCmd("sm_p", Client_Profile, "[surftimer] opens a player profile");
	RegConsoleCmd("sm_timer", Client_OptionMenu, "[surftimer] opens options menu");
	RegConsoleCmd("sm_toggletimer", Client_ToggleTimer, "[surftimer] toggles timer on and off");
	RegConsoleCmd("sm_surftimer", Client_OptionMenu, "[surftimer] opens options menu");
	RegConsoleCmd("sm_bhoptimer", Client_OptionMenu, "[surftimer] opens options menu");
	RegConsoleCmd("sm_knife", Command_GiveKnife, "[surftimer] Give players a knife");

	// New Commands
	RegConsoleCmd("sm_mrank", Command_SelectMapTime, "[surftimer] prints a players map record in chat.");
	RegConsoleCmd("sm_brank", Command_SelectBonusTime, "[surftimer] prints a players bonus record in chat.");
	RegConsoleCmd("sm_pr", Command_SelectPlayerPr, "[surftimer] Displays pr menu to client");
	RegConsoleCmd("sm_togglemapfinish", Command_ToggleMapFinish, "[surftimer] Toggles whether a player will finish a map when entering the end zone.");
	RegConsoleCmd("sm_tmf", Command_ToggleMapFinish, "[surftimer] Toggles whether a player will finish a map when entering the end zone.");
	RegConsoleCmd("sm_repeat", Command_Repeat, "[surftimer] Toggles whether a player will keep repeating the same stage.");
	RegConsoleCmd("sm_rank", Command_SelectRank, "[surftimer] Displays a players server rank in the chat");
	RegConsoleCmd("sm_mi", Command_MapImprovement, "[surftimer] opens map improvement points panel for map");
	RegConsoleCmd("sm_specbot", Command_SpecBot, "[surftimer] Spectate the map bot");
	RegConsoleCmd("sm_specbotbonus", Command_SpecBonusBot, "[surftimer] Spectate the bonus bot");
	RegConsoleCmd("sm_specbotb", Command_SpecBonusBot, "[surftimer] Spectate the bonus bot");
	RegConsoleCmd("sm_showzones", Command_ShowZones, "[surftimer] Clients can toggle whether zones are visible for them");

	// Styles
	RegConsoleCmd("sm_style", Client_SelectStyle, "[surftimer] open style select menu.");
	RegConsoleCmd("sm_styles", Client_SelectStyle, "[surftimer] open style select menu.");

	// style btop if i ever get around to it
	/*RegConsoleCmd("sm_btopsw", Client_SWBonusTop, "[surftimer] displays a local bonus top (sw) for a given map");
	RegConsoleCmd("sm_swbtop", Client_SWBonusTop, "[surftimer] displays a local bonus top (sw) for a given map");
	RegConsoleCmd("sm_btophsw", Client_HSWBonusTop, "[surftimer] displays a local bonus top (hsw) for a given map");
	RegConsoleCmd("sm_hswbtop", Client_HSWBonusTop, "[surftimer] displays a local bonus top (hsw) for a given map");
	RegConsoleCmd("sm_btopbw", Client_BWBonusTop, "[surftimer] displays a local bonus top (bw) for a given map");
	RegConsoleCmd("sm_bwbtop", Client_BWBonusTop, "[surftimer] displays a local bonus top (bw) for a given map");
	RegConsoleCmd("sm_btoplg", Client_LGBonusTop, "[surftimer] displays a local bonus top (low-gravity) for a given map");
	RegConsoleCmd("sm_lgbtop", Client_LGBonusTop, "[surftimer] displays a local bonus top (low-gravity) for a given map");
	RegConsoleCmd("sm_btopsm", Client_SMBonusTop, "[surftimer] displays a local bonus top (slow motion) for a given map");
	RegConsoleCmd("sm_smbtop", Client_SMBonusTop, "[surftimer] displays a local bonus top (slow motion) for a given map");
	RegConsoleCmd("sm_btopff", Client_FFBonusTop, "[surftimer] displays a local bonus top (fast forwards) for a given map");
	RegConsoleCmd("sm_ffbtop", Client_FFBonusTop, "[surftimer] displays a local bonus top (fast forwards) for a given map");*/

	// Test
	RegAdminCmd("sm_test", sm_test, ADMFLAG_CUSTOM6);
	RegAdminCmd("sm_vel", Client_GetVelocity, ADMFLAG_ROOT);
	RegAdminCmd("sm_targetname", Client_TargetName, ADMFLAG_ROOT);

	// !Startpos -- Goose
	RegConsoleCmd("sm_startpos", Command_Startpos, "[surftimer] Saves current location as new !r spawn.");
	RegConsoleCmd("sm_resetstartpos", Command_ResetStartpos, "[surftimer] Removes custom !r spawn.");

	// Discord
	RegConsoleCmd("sm_bug", Command_Bug, "[surftimer] report a bug to our discord");
	RegConsoleCmd("sm_calladmin", Command_Calladmin, "[surftimer] sends a message to the staff");

	// CPR
	RegConsoleCmd("sm_cpr", Command_CPR, "[surftimer] Compare clients time to another clients time");

	// reload map
	RegAdminCmd("sm_rm", Command_ReloadMap, ADMFLAG_ROOT, "[surftimer] Reloads the current map");

	// Play record
	RegConsoleCmd("sm_replay", Command_PlayRecord, "[surftimer] Set the replay bot to replay a run");
	RegConsoleCmd("sm_replays", Command_PlayRecord, "[surftimer] Set the replay bot to replay a run");

	// Delete records
	RegAdminCmd("sm_deleterecords", Command_DeleteRecords, g_ZonerFlag, "[surftimer] [zoner] Delete records");
	RegAdminCmd("sm_dr", Command_DeleteRecords, g_ZonerFlag, "[surftimer] [zoner] Delete records");
}

public Action Command_DeleteRecords(int client, int args)
{
	if(args > 0)
	{
		char sqlStripped[128];
		GetCmdArg(1, sqlStripped[client], 128);
		SQL_EscapeString(g_hDb, sqlStripped, g_EditingMap[client], 256);
	}
	else
		Format(g_EditingMap[client], 256, g_szMapName);
	
	ShowMainDeleteMenu(client);
	return Plugin_Handled;
}

public void ShowMainDeleteMenu(int client)
{
	Menu editing = new Menu(ShowMainDeleteMenuHandler);
	editing.SetTitle("%s Records Editing Menu - %s\n► Select the type of the record you would like to delete\n ", g_szMenuPrefix, g_EditingMap[client]);
	
	editing.AddItem("0", "Map Record");
	editing.AddItem("1", "Stage Record");
	editing.AddItem("2", "Bonus Record");
	
	editing.Display(client, MENU_TIME_FOREVER);
}

public int ShowMainDeleteMenuHandler(Menu menu, MenuAction action, int client, int key)
{
	if(action == MenuAction_Select)
	{
		g_SelectedEditOption[client] = key;
		g_SelectedStyle[client] = 0;
		g_SelectedType[client] = 1;
		
		char szQuery[512];
		
		switch(key)
		{
			case 0:
			{
				FormatEx(szQuery, 512, sql_MainEditQuery, "runtimepro", "ck_playertimes", g_EditingMap[client], g_SelectedStyle[client], "", "runtimepro");
			}
			case 1:
			{
				char stageQuery[32];
				FormatEx(stageQuery, 32, "AND stage='%i' ", g_SelectedType[client]);
				FormatEx(szQuery, 512, sql_MainEditQuery, "runtimepro", "ck_wrcps", g_EditingMap[client], g_SelectedStyle[client], stageQuery, "runtimepro");
			}
			case 2:
			{
				char stageQuery[32];
				FormatEx(stageQuery, 32, "AND zonegroup='%i' ", g_SelectedType[client]);
				FormatEx(szQuery, 512, sql_MainEditQuery, "runtime", "ck_bonus", g_EditingMap[client], g_SelectedStyle[client], stageQuery, "runtime");
			}
		}
		
		PrintToServer(szQuery);
		SQL_TQuery(g_hDb, sql_DeleteMenuView, szQuery, GetClientSerial(client));
	}
	else if(action == MenuAction_End)
		delete menu;
}

void CreateCommandListeners()
{
	// Chat command listener
	AddCommandListener(Say_Hook, "say");
	HookUserMessage(GetUserMessageId("SayText2"), SayText2, true);
	AddCommandListener(Say_Hook, "say_team");
	// AddCommandListener(Commands_CommandListener);

	AddCommandListener(Command_JoinTeam, "jointeam");
	AddCommandListener(Command_ext_Menu, "radio1");
	AddCommandListener(Command_ext_Menu, "radio2");
	AddCommandListener(Command_ext_Menu, "radio3");

	// Hook radio commands
	for (int g; g < sizeof(RadioCMDS); g++)
		AddCommandListener(BlockRadio, RadioCMDS[g]);
}

public Action sm_test(int client, int args)
{
	// CPrintToChatAll("stage: %d : wrcp: %d", g_Stage[0][client], g_WrcpStage[client]);
	// CPrintToChatAll("zoneid: %d", g_iClientInZone[client][3]);
	char arg[128];
	char found[128];
	GetCmdArg(1, arg, 128);
	FindMap(arg, found, 128);
	CPrintToChat(client, "arg: %s | found: %s", arg, found);
	return Plugin_Handled;
}

public Action Client_GetVelocity(int client, int args)
{
	float CurVelVec[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", CurVelVec);
	CPrintToChat(client, "%t", "Commands1", g_szChatPrefix, CurVelVec[0], CurVelVec[1], CurVelVec[2]);

	return Plugin_Handled;
}

public Action Client_TargetName(int client, int args)
{
	char szTargetName[128];
	char szClassName[128];
	GetEntPropString(client, Prop_Data, "m_iName", szTargetName, sizeof(szTargetName));
	GetEntityClassname(client, szClassName, 128);
	CPrintToChat(client, "%t", "Commands2", g_szChatPrefix, szTargetName);
	CPrintToChat(client, "%t", "Commands3", g_szChatPrefix, szClassName);

	return Plugin_Handled;
}

public Action Command_Vip(int client, int args)
{
	return Plugin_Handled;
}

// public Action Command_Vip(int client, int args)
// {
// 	if (!IsPlayerVip(client, 1))
// 	{
// 		return Plugin_Handled;
// 	}
	
// 	VipMenu(client);
// 	return Plugin_Handled;
// }

// public void VipMenu(int client)
// {
// 	Menu menu = CreateMenu(VipMenuHandler);
// 	SetMenuTitle(menu, "VIP Menu");
// 	AddMenuItem(menu, "ve", "Vote Extend");
// 	AddMenuItem(menu, "models", "Player Models");
// 	if (g_iVipLvl[client] > 1)
// 	{
// 		AddMenuItem(menu, "title", "VIP Title");
// 		AddMenuItem(menu, "paintcolour", "Paint Colour");
// 	}
// 	else
// 	{
// 		AddMenuItem(menu, "title", "VIP Title", ITEMDRAW_DISABLED);
// 		AddMenuItem(menu, "paintcolour", "Paint Colour", ITEMDRAW_DISABLED);
// 	}
// 	SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
// 	DisplayMenu(menu, client, MENU_TIME_FOREVER);
// }

// public int VipMenuHandler(Menu menu, MenuAction action, int param1, int param2)
// {
// 	if (action == MenuAction_Select)
// 	{
// 		switch (param2)
// 		{
// 			case 0: VoteExtend(param1);
// 			case 1: FakeClientCommandEx(param1, "sm_models");
// 			case 2: CustomTitleMenu(param1);
// 			case 3: FakeClientCommandEx(param1, "sm_paintcolour");
// 		}
// 	}
// 	else if (action == MenuAction_End)
// 		CloseHandle(menu);
// }

public void CustomTitleMenu(int client)
{
	if (!IsPlayerVip(client))
		return;

	char szName[64], szSteamID[32], szColour[3][96], szTitle[256], szItem[128], szItem2[128];

	GetClientName(client, szName, 64);
	getSteamIDFromClient(client, szSteamID, 32);
	getColourName(client, szColour[0], 32, g_iCustomColours[client][0]);
	getColourName(client, szColour[1], 32, g_iCustomColours[client][1]);

	Format(szTitle, 256, "Custom Titles Menu: %s\nCustom Title: %s\n \n", szName, g_szCustomTitle[client]);
	Format(szItem, 128, "Name Colour: %s", szColour[0]);
	Format(szItem2, 128, "Text Colour: %s", szColour[1]);

	Menu menu = CreateMenu(CustomTitleMenuHandler);
	SetMenuTitle(menu, szTitle);

	AddMenuItem(menu, "Name Colour", szItem);
	AddMenuItem(menu, "Text Colour", szItem2);
	if (g_bDbCustomTitleInUse[client])
		AddMenuItem(menu, "disable", "Disable Custom Title");
	else
		AddMenuItem(menu, "disable", "Enable Custom Title");

	SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int CustomTitleMenuHandler(Handle menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0, 1: db_viewPlayerColours(param1, g_szSteamID[param1], param2);
			case 2: db_toggleCustomPlayerTitle(param1, g_szSteamID[param1]);
		}
	}
	else if (action == MenuAction_End)
		CloseHandle(menu);
}

public Action Command_VoteExtend(int client, int args)
{
	if (!IsValidClient(client) || !IsPlayerVip(client))
		return Plugin_Handled;

	VoteExtend(client);
	return Plugin_Handled;
}

public void VoteExtend(int client)
{
	int timeleft;
	GetMapTimeLeft(timeleft);

	if (timeleft > 300)
	{
		CPrintToChat(client, "%t", "Commands4", g_szChatPrefix);
		return;
	}

	if (IsVoteInProgress())
	{
		CPrintToChat(client, "%t", "Commands5", g_szChatPrefix);
		return;
	}

	char szPlayerName[MAX_NAME_LENGTH];
	GetClientName(client, szPlayerName, MAX_NAME_LENGTH);

	Menu menu = CreateMenu(Handle_VoteMenuExtend);
	SetMenuTitle(menu, "Extend the map by 10 minutes?");
	AddMenuItem(menu, "###yes###", "Yes");
	AddMenuItem(menu, "###no###", "No");
	SetMenuExitButton(menu, false);
	VoteMenuToAll(menu, 20);
	CPrintToChatAll("%t", "VoteStartedBy", g_szChatPrefix, szPlayerName);

	return;
}

public Action Command_normalMode(int client, int args)
{
	if (!IsValidClient(client))
		return Plugin_Handled;

	Client_Stop(client, 1);
	g_bPracticeMode[client] = false;
	Command_Restart(client, 1);

	CPrintToChat(client, "%t", "PracticeNormal", g_szChatPrefix);
	return Plugin_Handled;
}

public Action Command_createPlayerCheckpoint(int client, int args)
{
	if (!IsValidClient(client))
		return Plugin_Handled;
	
	if (g_iClientInZone[client][0] == 1 || g_iClientInZone[client][0] == 5)
	{
		CPrintToChat(client, "%t", "PracticeInStartZone", g_szChatPrefix);
		return Plugin_Handled;
	}

	float time = GetGameTime();

	if ((time - g_fLastCheckpointMade[client]) < 1.0)
		return Plugin_Handled;

	if (g_iSaveLocCount < MAX_LOCS)
	{
		g_iSaveLocCount++;
		GetClientAbsOrigin(client, g_fSaveLocCoords[g_iSaveLocCount]);
		GetClientEyeAngles(client, g_fSaveLocAngle[g_iSaveLocCount]);
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", g_fSaveLocVel[g_iSaveLocCount]);
		GetEntPropString(client, Prop_Data, "m_iName", g_szSaveLocTargetname[g_iSaveLocCount], sizeof(g_szSaveLocTargetname));
		g_iLastSaveLocIdClient[client] = g_iSaveLocCount;
		CPrintToChat(client, "%t", "Commands7", g_szChatPrefix, g_iSaveLocCount);

		g_fLastCheckpointMade[client] = GetGameTime();
		g_iSaveLocUnix[g_iSaveLocCount] = GetTime();
		GetClientName(client, g_szSaveLocClientName[g_iSaveLocCount], MAX_NAME_LENGTH);
	}
	else
	{
		CPrintToChat(client, "%t", "Commands8", g_szChatPrefix);
	}

	return Plugin_Handled;
}

// public Action Command_createPlayerCheckpoint(int client, int args)
// {
// 	if (!IsValidClient(client))
// 		return Plugin_Handled;

// 	if (g_iClientInZone[client][0] == 1 || g_iClientInZone[client][0] == 5)
// 	{
// 		CPrintToChat(client, "%t", "PracticeInStartZone", g_szChatPrefix);
// 		return Plugin_Handled;
// 	}

// 	float CheckpointTime = GetGameTime();

// 	// Move old checkpoint to the undo values, if the last checkpoint was made more than a second ago
// 	if (g_bCreatedTeleport[client] && (CheckpointTime - g_fLastPlayerCheckpoint[client]) > 1.0)
// 	{
// 		g_fLastPlayerCheckpoint[client] = CheckpointTime;
// 		Array_Copy(g_fCheckpointLocation[client], g_fCheckpointLocation_undo[client], 3);
// 		Array_Copy(g_fCheckpointVelocity[client], g_fCheckpointVelocity_undo[client], 3);
// 		Array_Copy(g_fCheckpointAngle[client], g_fCheckpointAngle_undo[client], 3);
// 		Format(g_szCheckpointTargetname_undo[client], sizeof(g_szCheckpointTargetname_undo), "%s", g_szCheckpointTargetname[client]);
// 	}

// 	g_bCreatedTeleport[client] = true;
// 	GetClientAbsOrigin(client, g_fCheckpointLocation[client]);
// 	GetEntPropVector(client, Prop_Data, "m_vecVelocity", g_fCheckpointVelocity[client]);
// 	GetClientEyeAngles(client, g_fCheckpointAngle[client]);
// 	GetEntPropString(client, Prop_Data, "m_iName", g_szCheckpointTargetname[client], sizeof(g_szCheckpointTargetname));


// 	CPrintToChat(client, "%t", "PracticePointCreated", g_szChatPrefix, LIMEGREEN, WHITE);

// 	return Plugin_Handled;
// }

public Action Command_goToPlayerCheckpoint(int client, int args)
{
	if (!IsValidClient(client))
		return Plugin_Handled;
	
	if (g_iSaveLocCount > 0)
	{
		if (args == 0)
		{
			int id = g_iLastSaveLocIdClient[client];
			TeleportToSaveloc(client, id);
		}
		else
		{
			char arg[128];
			char firstChar[2];
			GetCmdArg(1, arg, 128);
			Format(firstChar, 2, arg[0]);
			if (!StrEqual(firstChar, "#"))
			{
				CPrintToChat(client, "%t", "Commands9", g_szChatPrefix);
				return Plugin_Handled;
			}

			ReplaceString(arg, 128, "#", "", false);
			int id = StringToInt(arg);

			if (id < 1 || id > MAX_LOCS - 1 || id > g_iSaveLocCount)
			{
				CPrintToChat(client, "%t", "Commands10", g_szChatPrefix);
				return Plugin_Handled;
			}

			g_iLastSaveLocIdClient[client] = id;
			TeleportToSaveloc(client, id);
		}
	}
	else
	{
		CPrintToChat(client, "%t", "Commands11", g_szChatPrefix);
	}

	return Plugin_Handled;
}

public Action Command_SaveLocList(int client, int args)
{
	if (g_iSaveLocCount < 1)
	{
		CPrintToChat(client, "%t", "Commands11", g_szChatPrefix);
		return Plugin_Handled;
	}

	SaveLocMenu(client);

	return Plugin_Handled;
}

public void SaveLocMenu(int client)
{
	Menu menu = CreateMenu(SaveLocListHandler);
	SetMenuTitle(menu, "Save Locs");
	char szBuffer[128];
	char szItem[256];
	char szId[32];
	int unix;
	for (int i = 1; i <= g_iSaveLocCount; i++)
	{
		unix = GetTime() - g_iSaveLocUnix[i];
		diffForHumans(unix, szBuffer, 128, 1);
		Format(szItem, sizeof(szItem), "#%d - %s - %s", i, g_szSaveLocClientName[i], szBuffer);
		IntToString(i, szId, 32);
		AddMenuItem(menu, szId, szItem);
	}

	int pos = g_iMenuPosition[client];
	if (pos < 6)
		pos = 0;
	else if (pos < 12)
		pos = 6;
	else if (pos < 18)
		pos = 12;
	else if (pos < 24)
		pos = 18;
	else if (pos < 30)
		pos = 24;
	else if (pos < 36)
		pos = 30;
	else if (pos < 42)
		pos = 36;
	else if (pos < 48)
		pos = 42;
	else if (pos < 54)
		pos = 48;
	else if (pos < 60)
		pos = 54;
	SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
	DisplayMenuAtItem(menu, client, pos, MENU_TIME_FOREVER);
}

public int SaveLocListHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		g_iMenuPosition[param1] = param2;
		char szId[32];
		GetMenuItem(menu, param2, szId, 32);
		int id = StringToInt(szId);
		CPrintToChat(param1, "%t", "Commands13", g_szChatPrefix, id);
		TeleportToSaveloc(param1, id);
		SaveLocMenu(param1);
	}
	else if (action == MenuAction_End)
		delete menu;
}

// public Action Command_goToPlayerCheckpoint(int client, int args)
// {
// 	if (!IsValidClient(client))
// 		return Plugin_Handled;

// 	if (g_fCheckpointLocation[client][0] != 0.0 && g_fCheckpointLocation[client][1] != 0.0 && g_fCheckpointLocation[client][2] != 0.0)
// 	{
// 		if (g_bPracticeMode[client] == false)
// 		{
// 			CPrintToChat(client, "%t", "PracticeStarted", g_szChatPrefix, LIMEGREEN, WHITE, LIMEGREEN, WHITE);
// 			CPrintToChat(client, "%t", "PracticeStarted2", g_szChatPrefix, LIMEGREEN, WHITE, LIMEGREEN, WHITE);
// 			g_bPracticeMode[client] = true;
// 		}

// 		// fluffys gravity
// 		if (g_iInitalStyle[client] != 4)
// 			ResetGravity(client);
// 		else // lowgravity
// 			SetEntityGravity(client, 0.5);

// 		CL_OnStartTimerPress(client);
// 		SetEntPropVector(client, Prop_Data, "m_vecVelocity", view_as<float>( { 0.0, 0.0, 0.0 } ));
// 		TeleportEntity(client, g_fCheckpointLocation[client], g_fCheckpointAngle[client], g_fCheckpointVelocity[client]);
// 		g_bWrcpTimeractivated[client] = false;
// 		DispatchKeyValue(client, "targetname", g_szCheckpointTargetname[client]);
// 	}
// 	else
// 		CPrintToChat(client, "%t", "PracticeStartError", g_szChatPrefix, LIGHTGREEN);

// 	return Plugin_Handled;
// }

// public Action Command_undoPlayerCheckpoint(int client, int args)
// {
// 	if (!IsValidClient(client))
// 		return Plugin_Handled;

// 	if (g_fCheckpointLocation_undo[client][0] != 0.0 && g_fCheckpointLocation_undo[client][1] != 0.0 && g_fCheckpointLocation_undo[client][2] != 0.0)
// 	{
// 		float tempLocation[3], tempVelocity[3], tempAngle[3];
// 		char tempTargetname[128];

// 		// Location
// 		Array_Copy(g_fCheckpointLocation_undo[client], tempLocation, 3);
// 		Array_Copy(g_fCheckpointLocation[client], g_fCheckpointLocation_undo[client], 3);
// 		Array_Copy(tempLocation, g_fCheckpointLocation[client], 3);

// 		// Velocity
// 		Array_Copy(g_fCheckpointVelocity_undo[client], tempVelocity, 3);
// 		Array_Copy(g_fCheckpointVelocity[client], g_fCheckpointVelocity_undo[client], 3);
// 		Array_Copy(tempVelocity, g_fCheckpointVelocity[client], 3);

// 		// Angle
// 		Array_Copy(g_fCheckpointAngle_undo[client], tempAngle, 3);
// 		Array_Copy(g_fCheckpointAngle[client], g_fCheckpointAngle_undo[client], 3);
// 		Array_Copy(tempAngle, g_fCheckpointAngle[client], 3);

// 		// Targetname
// 		Format(tempTargetname, sizeof(tempTargetname), "%s", g_szCheckpointTargetname_undo[client]);
// 		Format(g_szCheckpointTargetname[client], sizeof(g_szCheckpointTargetname), "%s", g_szCheckpointTargetname_undo);
// 		Format(g_szCheckpointTargetname[client], sizeof(g_szCheckpointTargetname), "%s", tempTargetname);

// 		CPrintToChat(client, "%t", "PracticeUndo", g_szChatPrefix);
// 	}
// 	else
// 		CPrintToChat(client, "%t", "PracticeUndoError", g_szChatPrefix, LIGHTGREEN);

// 	return Plugin_Handled;
// }

public Action Command_Teleport(int client, int args)
{
	g_bWrcpTimeractivated[client] = false;

	// Throttle using !back to fix errors with replays
	if ((GetGameTime() - g_fLastCommandBack[client]) < 1.0)
		return Plugin_Handled;
	else
		g_fLastCommandBack[client] = GetGameTime();

	if (g_Stage[g_iClientInZone[client][2]][client] == 1)
	{
		// fluffys
		if (g_bPause[client] == true)
			PauseMethod(client);

		teleportClient(client, g_iClientInZone[client][2], 1, false);
		return Plugin_Handled;
	}

	// fluffys
	if (g_bPause[client] == true)
		PauseMethod(client);

	teleportClient(client, g_iClientInZone[client][2], g_Stage[g_iClientInZone[client][2]][client], false);
	return Plugin_Handled;
}

public Action Command_HowTo(int client, int args)
{
	ShowMOTDPanel(client, "How To Surf", "http://koti.kapsi.fi/~mukavajoni/how", MOTDPANEL_TYPE_URL);
	return Plugin_Handled;
}

public Action Command_Zones(int client, int args)
{
	if (IsValidClient(client))
	{
		ZoneMenu(client);
		resetSelection(client);
	}
	return Plugin_Handled;
}

public Action Command_ListBonuses(int client, int args)
{
	if (IsValidClient(client))
	{
		ListBonuses(client, 1);
	}
	return Plugin_Handled;
}

public void ListBonuses(int client, int type)
{
	// Types: Start(1), End(2), Stage(3), Checkpoint(4), Speed(5), TeleToStart(6), Validator(7), Chekcer(8), Stop(0)
	char buffer[3];
	Menu listBonusesMenu;
	if (type == 1)
	{
		listBonusesMenu = new Menu(MenuHandler_SelectBonus);
	}
	else
	{
		listBonusesMenu = new Menu(MenuHandler_SelectBonusTop);
	}

	listBonusesMenu.SetTitle("Choose a bonus");

	if (g_mapZoneGroupCount > 1)
	{
		for (int i = 1; i < g_mapZoneGroupCount; i++)
		{
			IntToString(i, buffer, 3);
			listBonusesMenu.AddItem(buffer, g_szZoneGroupName[i]);
		}
	}
	else
	{
		CPrintToChat(client, "%t", "NoBonusOnMap", g_szChatPrefix);
		return;
	}

	listBonusesMenu.ExitButton = true;
	listBonusesMenu.Display(client, 60);
}

public int MenuHandler_SelectBonusTop(Menu sMenu, MenuAction action, int client, int item)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char aID[3];
			GetMenuItem(sMenu, item, aID, sizeof(aID));
			int zoneGrp = StringToInt(aID);
			db_selectBonusTopSurfers(client, g_szMapName, zoneGrp);
		}
		case MenuAction_End:
		{
			delete sMenu;
		}
	}
}

public int MenuHandler_SelectBonus(Menu sMenu, MenuAction action, int client, int item)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char aID[3];
			GetMenuItem(sMenu, item, aID, sizeof(aID));
			int zoneGrp = StringToInt(aID);
			g_bInBonus[client] = true;
			g_iInBonus[client] = zoneGrp;
			teleportClient(client, zoneGrp, 1, true);
		}
		case MenuAction_End:
		{
			delete sMenu;
		}
	}
}

public Action Command_ToBonus(int client, int args)
{
	if (!IsValidClient(client))
		return Plugin_Handled;

	if (g_mapZoneGroupCount < 2)
	{
		CPrintToChat(client, "%t", "NoBonusOnMap", g_szChatPrefix);
		return Plugin_Handled;
	}

	// If not enough arguments, or there is more than one bonus
	if (args < 1 && g_mapZoneGroupCount > 2) // Tell player to select specific bonus
	{
		/*CPrintToChat(client, "%t Usage: !b <bonus number>", g_szChatPrefix);
		if (g_mapZoneGroupCount > 1)
		{
			CPrintToChat(client, "%t Available bonuses:", g_szChatPrefix);
			for (int i = 1; i < g_mapZoneGroupCount; i++)
			{
				CPrintToChat(client, "[%c%i.%c] %s", YELLOW, i, WHITE, g_szZoneGroupName[i]);
			}
		}*/
		ListBonuses(client, 1);
		return Plugin_Handled;
	}

	int zoneGrp;
	if (g_mapZoneGroupCount > 2) // If there is more than one bonus in the map, get the zGrp from command
	{
		char arg1[3];
		GetCmdArg(1, arg1, sizeof(arg1));

		if (!arg1[0])
			zoneGrp = args;
		else
			zoneGrp = StringToInt(arg1);

		if (zoneGrp == 0) {
			Command_Restart(client, 1);
			return Plugin_Handled;
		}
	}
	else
		zoneGrp = 1;

	g_bInBonus[client] = true;
	g_iInBonus[client] = zoneGrp;
	teleportClient(client, zoneGrp, 1, true);
	return Plugin_Handled;
}

public Action Command_SelectStage(int client, int args)
{
	if (IsValidClient(client))
		ListStages(client, g_iClientInZone[client][2]);
	return Plugin_Handled;
}

public void ListStages(int client, int zonegroup)
{
	// Types: Start(1), End(2), Stage(3), Checkpoint(4), Speed(5), TeleToStart(6), Validator(7), Chekcer(8), Stop(0)
	Menu sMenu = CreateMenu(MenuHandler_SelectStage);
	SetMenuTitle(sMenu, "Stage selector");
	int amount = 0;
	char StageName[64], ZoneInfo[6];

	int StageIds[MAXZONES] = { -1, ... };

	if (g_mapZonesCount > 0)
	{
		for (int i = 0; i <= g_mapZonesCount; i++)
		{
			if (g_mapZones[i][zoneType] == 3 && g_mapZones[i][zoneGroup] == zonegroup)
			{
				StageIds[amount] = i;
				amount++;
			}
		}
		if (amount == 0)
		{
			CPrintToChat(client, "%t", "Commands87", g_szChatPrefix);
		}
		else
		{
			amount = 0;
			for (int t = 0; t < 128; t++)
			{
				if (StageIds[t] >= 0)
				{
					amount++;
					Format(StageName, sizeof(StageName), "Stage %i", (amount + 1));
					IntToString(amount + 1, ZoneInfo, 6);
					AddMenuItem(sMenu, ZoneInfo, StageName);
				}
			}
		}
	}
	else
	{
		AddMenuItem(sMenu, "", "No stages are available.", ITEMDRAW_DISABLED);
	}

	SetMenuExitButton(sMenu, true);
	DisplayMenu(sMenu, client, MENU_TIME_FOREVER);
}

public int MenuHandler_SelectStage(Menu tMenu, MenuAction action, int client, int item)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char aID[64];
			GetMenuItem(tMenu, item, aID, sizeof(aID));
			int id = StringToInt(aID);
			teleportClient(client, g_iClientInZone[client][2], id, true);
		}
		case MenuAction_End:
		{
			CloseHandle(tMenu);
		}
	}
}

public Action Command_ToStage(int client, int args)
{
	if (!IsValidClient(client))
		return Plugin_Handled;

	if (args < 1)
	{
		// Remove chat output to reduce chat spam
		// CPrintToChat(client, "Teleport to stage 1 | Default usage: !s <stage number>");
		g_bInStartZone[client] = false;
		g_bUsingStageTeleport[client] = true;
		teleportClient(client, 0, 1, true);
	}
	else
	{
		char arg1[3];
		// g_bInStartZone[client] = false;
		g_bUsingStageTeleport[client] = true;
		GetCmdArg(1, arg1, sizeof(arg1));
		int StageId = StringToInt(arg1);
		if (StageId == 3)
		{
			g_bWrcpTimeractivated[client] = false;
			teleportClient(client, 0, 3, true);
			g_Stage[0][client] = 3;
			g_CurrentStage[client] = 3;
			return Plugin_Handled;
		}
		teleportClient(client, 0, StageId, true);
	}

	return Plugin_Handled;
}

public Action Command_ToEnd(int client, int args)
{
	if (!IsValidClient(client))
		return Plugin_Handled;

	if (!GetConVarBool(g_hCommandToEnd))
	{
		CReplyToCommand(client, "%t", "Commands71", g_szChatPrefix);
		return Plugin_Handled;
	}
	teleportClient(client, g_iClientInZone[client][2], -1, true);
	return Plugin_Handled;
}

public Action Command_Restart(int client, int args)
{
	if (GetConVarBool(g_hDoubleRestartCommand) && args == 0)
	{
		if (GetGameTime() - g_fClientRestarting[client] > 5.0)
			g_bClientRestarting[client] = false;

		// Check that the client has a timer running, the zonegroup he is in has stages and that this is the first click
		if (IsValidClient(client) && g_bTimerRunning[client] && g_mapZonesTypeCount[g_iClientInZone[client][2]][3] > 0 && !g_bClientRestarting[client] && g_Stage[g_iClientInZone[client][2]][client] > 1)
		{
			g_fClientRestarting[client] = GetGameTime();
			g_bClientRestarting[client] = true;
			CPrintToChat(client, "%t", "Commands34", g_szChatPrefix);
			ClientCommand(client, "play ambient/misc/clank4");
			return Plugin_Handled;
		}
	}

	g_bClientRestarting[client] = false;
	// fluffys
	if (g_bPause[client] == true)
		PauseMethod(client);

	if (!g_bTimerEnabled[client])
		g_bTimerEnabled[client] = true;

	g_bWrcpTimeractivated[client] = false;
	g_bInStageZone[client] = false;
	g_bInStartZone[client] = true;
	g_bLeftZone[client] = false;
	g_bInBhop[client] = false;

	teleportClient(client, 0, 1, true);
	return Plugin_Handled;
}

public Action Client_HideChat(int client, int args)
{
	HideChat(client);
	if (g_bHideChat[client])
		CPrintToChat(client, "%t", "HideChat1", g_szChatPrefix);
	else
		CPrintToChat(client, "%t", "HideChat2", g_szChatPrefix);
	return Plugin_Handled;
}

void HideChat(int client, bool menu = false)
{
	if (!g_bHideChat[client])
	{
		// Hiding
		if (g_bViewModel[client])
			SetEntProp(client, Prop_Send, "m_iHideHUD", GetEntProp(client, Prop_Send, "m_iHideHUD") | HIDE_RADAR | HIDE_CHAT);
		else
			SetEntProp(client, Prop_Send, "m_iHideHUD", GetEntProp(client, Prop_Send, "m_iHideHUD") | HIDE_RADAR | HIDE_CHAT);
	}
	else
	{
		// Displaying
		if (g_bViewModel[client])
			SetEntProp(client, Prop_Send, "m_iHideHUD", HIDE_RADAR);
		else
			SetEntProp(client, Prop_Send, "m_iHideHUD", HIDE_RADAR);
	}

	g_bHideChat[client] = !g_bHideChat[client];
	if (menu)
		MiscellaneousOptions(client);
}

public Action ToggleCheckpoints(int client, int args)
{
	if (!IsValidClient(client))
		return Plugin_Handled;

	if (g_bCheckpointsEnabled[client])
	{
		g_bCheckpointsEnabled[client] = false;
		if (g_bActivateCheckpointsOnStart[client])
			g_bActivateCheckpointsOnStart[client] = false;
		CPrintToChat(client, "%t", "ToogleCheckpoints1", g_szChatPrefix);
	}
	else
	{
		if (g_bTimerRunning[client])
		{
			CPrintToChat(client, "%t", "ToggleCheckpoints3", g_szChatPrefix);
			g_bActivateCheckpointsOnStart[client] = true;
		}
		else
		{
			g_bCheckpointsEnabled[client] = true;
			CPrintToChat(client, "%t", "ToggleCheckpoints2", g_szChatPrefix);
		}
	}
	return Plugin_Handled;
}

public Action Client_HideWeapon(int client, int args)
{
	HideViewModel(client);
	if (g_bViewModel[client])
		CPrintToChat(client, "%t", "HideViewModel2", g_szChatPrefix);
	else
		CPrintToChat(client, "%t", "HideViewModel1", g_szChatPrefix);
	return Plugin_Handled;
}

void HideViewModel(int client, bool menu = false)
{
	Client_SetDrawViewModel(client, !g_bViewModel[client]);
	if (!g_bViewModel[client])
	{
		// Display
		if (!g_bHideChat[client])
			SetEntProp(client, Prop_Send, "m_iHideHUD", HIDE_RADAR);
		else
			SetEntProp(client, Prop_Send, "m_iHideHUD", HIDE_RADAR | HIDE_CHAT);
	}
	else
	{
		// Hiding
		if (!g_bHideChat[client])
			SetEntProp(client, Prop_Send, "m_iHideHUD", GetEntProp(client, Prop_Send, "m_iHideHUD") | HIDE_RADAR | HIDE_CROSSHAIR);
		else
			SetEntProp(client, Prop_Send, "m_iHideHUD", GetEntProp(client, Prop_Send, "m_iHideHUD") | HIDE_RADAR | HIDE_CHAT | HIDE_CROSSHAIR);
	}


	g_bViewModel[client] = !g_bViewModel[client];
	if (menu)
		MiscellaneousOptions(client);
}

public Action Client_Wr(int client, int args)
{
	RateLimit(client);

	if (IsValidClient(client) && !g_bRateLimit[client])
	{
		if (args == 0)
		{
			PrintWorldRecordStyleSelect(client, 0);
		}
		else
		{
			char arg1[128];
			GetCmdArg(1, arg1, sizeof(arg1));

			db_selectMapRecordTime(client, arg1);
		}
	}

	return Plugin_Handled;
}

public Action Client_Wrb(int client, int args)
{
	if (IsValidClient(client))
		PrintWorldRecordStyleSelect(client, 1);
	return Plugin_Handled;
}

public void PrintWorldRecordStyleSelect(int client, int type)
{
	Menu menu = CreateMenu(PrintWorldRecordStyleSelectHandler);
	SetMenuTitle(menu, "WR(B): Select a style\n \n");

	char szType[2];
	IntToString(type, szType, sizeof(szType));

	AddMenuItem(menu, szType, "Normal");
	AddMenuItem(menu, szType, "Sideways");
	AddMenuItem(menu, szType, "Half-Sideways");
	AddMenuItem(menu, szType, "Backwards");
	AddMenuItem(menu, szType, "Low-Gravity");
	AddMenuItem(menu, szType, "Slow Motion");
	AddMenuItem(menu, szType, "Fast Forwards");

	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int PrintWorldRecordStyleSelectHandler(Handle menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char szType[2];
		GetMenuItem(menu, param2, szType, sizeof(szType));
		int type = StringToInt(szType);

		if (type == 0)
		{
			// Normal
			if (param2 == 0)
			{
				// Normal
				if (g_fRecordMapTime == 9999999.0)
					CPrintToChat(param1, "%t", "NoRecordTop", g_szChatPrefix);
				else
					PrintMapRecords(param1, 0);
			}
			else
			{
				// Style
				if (g_fRecordStyleMapTime[param2] == 9999999.0)
					CPrintToChat(param1, "%t", "NoRecordTop", g_szChatPrefix);
				else
					PrintMapRecords(param1, param2);
			}
		}
		else
		{
			// Styles
			if (param2 == 0)
			{
				// Normal
				if (g_fBonusFastest[1] == 9999999.0)
					CPrintToChat(param1, "%t", "NoRecordTop", g_szChatPrefix);
				else
					PrintMapRecords(param1, 99);
			}
			else
			{
				// Style
				if (g_fStyleBonusFastest[param2][1] == 9999999.0)
					CPrintToChat(param1, "%t", "NoRecordTop", g_szChatPrefix);
				else
					PrintMapRecords(param1, 990 + param2);
			}
		}
	}
	else if (action == MenuAction_End)
		delete menu;
}

public Action Command_Tier(int client, int args)
{
	if (IsValidClient(client) && g_bTierFound)
		CPrintToChat(client, "%t", "Timer1", g_szChatPrefix, g_sTierString);
}

public Action Client_Avg(int client, int args)
{
	if (!IsValidClient(client))
		return Plugin_Handled;

	char szProTime[32];
	FormatTimeFloat(client, g_favg_maptime, 3, szProTime, sizeof(szProTime));

	if (g_MapTimesCount == 0)
		Format(szProTime, 32, "N/A");

	CPrintToChat(client, "%t", "AvgTime", g_szChatPrefix, szProTime, g_MapTimesCount);

	if (g_bhasBonus)
	{
		char szBonusTime[32];

		for (int i = 1; i < g_mapZoneGroupCount; i++)
		{
			FormatTimeFloat(client, g_fAvg_BonusTime[i], 3, szBonusTime, sizeof(szBonusTime));

			if (g_iBonusCount[i] == 0)
				Format(szBonusTime, 32, "N/A");
			CPrintToChat(client, "%t", "AvgTimeBonus", g_szChatPrefix, szBonusTime, g_iBonusCount[i]);
		}
	}

	return Plugin_Handled;
}

public Action Client_Flashlight(int client, int args)
{
	if (IsValidClient(client) && IsPlayerAlive(client))
		SetEntProp(client, Prop_Send, "m_fEffects", GetEntProp(client, Prop_Send, "m_fEffects") ^ 4);
	return Plugin_Handled;
}

public Action Client_Usp(int client, int args)
{
	if (!IsValidClient(client) || !IsPlayerAlive(client))
		return Plugin_Handled;

	if ((GetGameTime() - g_flastClientUsp[client]) < 10.0)
		return Plugin_Handled;

	g_flastClientUsp[client] = GetGameTime();

	if (Client_HasWeapon(client, "weapon_hkp2000"))
	{
		int weapon = Client_GetWeapon(client, "weapon_hkp2000");
		FakeClientCommand(client, "use %s", weapon);
		InstantSwitch(client, weapon);
	}
	else if (Client_HasWeapon(client, "weapon_glock"))
	{
		int weapon = Client_GetWeapon(client, "weapon_glock");
		FakeClientCommand(client, "use %s", weapon);
		InstantSwitch(client, weapon);
		FakeClientCommand(client, "drop");
		GivePlayerItem(client, "weapon_usp_silencer");
	}
	else
		GivePlayerItem(client, "weapon_usp_silencer");
	return Plugin_Handled;
}

public Action Client_Glock(int client, int args)
{
	if (!IsValidClient(client) || !IsPlayerAlive(client))
		return Plugin_Handled;

	if ((GetGameTime() - g_flastClientUsp[client]) < 10.0)
		return Plugin_Handled;

	g_flastClientUsp[client] = GetGameTime();

	if (Client_HasWeapon(client, "weapon_glock"))
	{
		int weapon = Client_GetWeapon(client, "weapon_glock");
		FakeClientCommand(client, "use %s", weapon);
		InstantSwitch(client, weapon);
	}
	else if (Client_HasWeapon(client, "weapon_hkp2000"))
	{
		int weapon = Client_GetWeapon(client, "weapon_hkp2000");
		FakeClientCommand(client, "use %s", weapon);
		InstantSwitch(client, weapon);
		FakeClientCommand(client, "drop");
		GivePlayerItem(client, "weapon_glock");
	}
	else
		GivePlayerItem(client, "weapon_glock");
	return Plugin_Handled;
}

void InstantSwitch(int client, int weapon, int timer = 0)
{
	if (weapon == -1)
		return;

	float GameTime = GetGameTime();

	if (!timer)
	{
		SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon);
		SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GameTime);
	}

	SetEntPropFloat(client, Prop_Send, "m_flNextAttack", GameTime);
	int ViewModel = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
	SetEntProp(ViewModel, Prop_Send, "m_nSequence", 0);
}

public Action Command_ext_Menu(int client, const char[] command, int argc)
{
	return Plugin_Handled;
}

// https://forums.alliedmods.net/showthread.php?t=206308
public Action Command_JoinTeam(int client, const char[] command, int argc)
{
	if (!IsValidClient(client) || argc < 1)
		return Plugin_Handled;
	char arg[4];
	GetCmdArg(1, arg, sizeof(arg));
	int toteam = StringToInt(arg);

	TeamChangeActual(client, toteam);
	return Plugin_Handled;
}

public Action Client_OptionMenu(int client, int args)
{
	OptionMenu(client);
	return Plugin_Handled;
}

public Action NoClip(int client, int args)
{
	if (!IsValidClient(client))
		return Plugin_Handled;

	if (g_bTimerEnabled[client])
		{
			g_bTimerEnabled[client] = !g_bTimerEnabled[client];
			CPrintToChat(client, "%t", "Commands19", g_szChatPrefix);
		}

	Action_NoClip(client);

	return Plugin_Handled;
}

public Action UnNoClip(int client, int args)
{

	if (!g_bTimerEnabled[client])
	{
		CPrintToChat(client, "%t", "Commands20", g_szChatPrefix);
	}

	if (g_bNoClip[client] == true)
		Action_UnNoClip(client);

	if (g_iInitalStyle[client] != 4 && IsValidClient(client))
		ResetGravity(client);
	else
		SetEntityGravity(client, 0.5);

	return Plugin_Handled;
}

public Action Command_ckNoClip(int client, int args)
{
	if (!IsValidClient(client))
		return Plugin_Handled;

	if (g_bTimerEnabled[client])
		g_bTimerEnabled[client] = false;

	if (!IsPlayerAlive(client))
	{
		CReplyToCommand(client, "%t", "Commands72", g_szChatPrefix);
	}
	else
	{
		MoveType mt = GetEntityMoveType(client);

		if (mt != MOVETYPE_NOCLIP)
		{
			Action_NoClip(client);
		}
		else
		{
			Action_UnNoClip(client);
		}
	}

	return Plugin_Handled;
}

public Action Client_Top(int client, int args)
{
	TopMenuStyleSelect(client);
	//ckTopMenu(client);
	return Plugin_Handled;
}

public void TopMenuStyleSelect(int client)
{
	Menu menu = CreateMenu(TopMenuStyleSelectHandler);
	SetMenuTitle(menu, "Top Menu - Select a style\n \n");
	AddMenuItem(menu, "", "Normal");
	AddMenuItem(menu, "", "Sideways");
	AddMenuItem(menu, "", "Half-Sideways");
	AddMenuItem(menu, "", "Backwards");
	AddMenuItem(menu, "", "Low-Gravity");
	AddMenuItem(menu, "", "Slow Motion");
	AddMenuItem(menu, "", "Fast Forwards");
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int TopMenuStyleSelectHandler(Handle menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		g_ProfileStyleSelect[param1] = param2;
		ckTopMenu(param1, param2);
	}
	else if (action == MenuAction_End)
		CloseHandle(menu);
}

public Action Client_MapTop(int client, int args)
{
	char szArg[128];

	if (args == 0)
	{
		Format(szArg, 128, "%s", g_szMapName);
	}
	else
	{
		GetCmdArg(1, szArg, 128);
	}
	MapTopMenuSelectStyle(client, szArg);
	return Plugin_Handled;
}

public void MapTopMenuSelectStyle(int client, char szMapName[128])
{
	Menu menu = CreateMenu(MapTopMenuSelectStyleHandler);
	SetMenuTitle(menu, "Map Top: Select a style\n \n");
	AddMenuItem(menu, szMapName, "Normal");
	AddMenuItem(menu, szMapName, "Sideways");
	AddMenuItem(menu, szMapName, "Half-Sideways");
	AddMenuItem(menu, szMapName, "Backwards");
	AddMenuItem(menu, szMapName, "Low-Gravity");
	AddMenuItem(menu, szMapName, "Slow Motion");
	AddMenuItem(menu, szMapName, "Fast Forward");
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int MapTopMenuSelectStyleHandler(Handle menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char szMapName[128];
		GetMenuItem(menu, param2, szMapName, sizeof(szMapName));
		db_selectMapNameEquals(param1, szMapName, param2);
		// if (param2 == 0)
		// {
		// 	g_ProfileStyleSelect[param1] = 0;
		// 	db_selectMapTopSurfers(param1, szMapName);
		// }
		// else
		// {
		// 	g_ProfileStyleSelect[param1] = param2;
		// 	db_selectStyleMapTopSurfers(param1, szMapName, param2);
		// }
	}
	else if (action == MenuAction_End)
		delete menu;
}

public Action Client_BonusTop(int client, int args)
{
	char szArg[128], zGrp;

	if (!IsValidClient(client))
		return Plugin_Handled;

	switch (args) {
		case 0: { // !btop
			if (g_mapZoneGroupCount == 1)
			{
				CPrintToChat(client, "%t", "NoBonusOnMap", g_szChatPrefix);
				CPrintToChat(client, "%t", "BTopUsage", g_szChatPrefix);
				return Plugin_Handled;
			}
			if (g_mapZoneGroupCount == 2)
			{
				zGrp = 1;
				Format(szArg, 128, "%s", g_szMapName);
			}
			if (g_mapZoneGroupCount > 2)
			{
				ListBonuses(client, 2);
				return Plugin_Handled;
			}
		}
		case 1: { // !btop <mapname> / <bonus id>
			// 1st check if bonus id or mapname
			GetCmdArg(1, szArg, 128);
			if (StringToInt(szArg) == 0 && szArg[0] != '0') // passes, if not a number (argument is mapname)
			{
				db_selectBonusesInMap(client, szArg);
				return Plugin_Handled;
			}
			else // argument is a bonus id (Use current map)
			{
				zGrp = StringToInt(szArg);
				if (0 < zGrp < MAXZONEGROUPS)
				{
					Format(szArg, 128, "%s", g_szMapName);
				}
				else
				{
					CPrintToChat(client, "%t", "InvalidBonusID", g_szChatPrefix, zGrp);
					return Plugin_Handled;
				}
			}
		}
		case 2: {
			GetCmdArg(1, szArg, 128);
			if (StringToInt(szArg) != 0 && szArg[0] != '0') // passes, if not a number (argument is mapname)
			{
				char szZGrp[128];
				GetCmdArg(2, szZGrp, 128);
				zGrp = StringToInt(szZGrp);
			}
			else // argument is a bonus id
			{
				zGrp = StringToInt(szArg);
				GetCmdArg(2, szArg, 128);
			}

			if (0 > zGrp || zGrp > MAXZONEGROUPS)
			{
				CPrintToChat(client, "%t", "InvalidBonusID", g_szChatPrefix, zGrp);
				return Plugin_Handled;
			}
		}
		default: {
			CPrintToChat(client, "%t", "BTopUsage", g_szChatPrefix);
			return Plugin_Handled;
		}
	}
	db_selectBonusTopSurfers(client, szArg, zGrp);
	return Plugin_Handled;
}

public Action Client_SWBonusTop(int client, int args)
{
	char szArg[128], zGrp;

	if (!IsValidClient(client))
		return Plugin_Handled;

	switch (args) {
		case 0: { // !btop
			if (g_mapZoneGroupCount == 1)
			{
				CPrintToChat(client, "%t", "NoBonusOnMap", g_szChatPrefix);
				CPrintToChat(client, "%t", "BTopUsage", g_szChatPrefix);
				return Plugin_Handled;
			}
			if (g_mapZoneGroupCount == 2)
			{
				zGrp = 1;
				Format(szArg, 128, "%s", g_szMapName);
			}
			if (g_mapZoneGroupCount > 2)
			{
				ListBonuses(client, 2);
				return Plugin_Handled;
			}
		}
		case 1: { // !btop <mapname> / <bonus id>
			// 1st check if bonus id or mapname
			GetCmdArg(1, szArg, 128);
			if (StringToInt(szArg) == 0 && szArg[0] != '0') // passes, if not a number (argument is mapname)
			{
				db_selectBonusesInMap(client, szArg);
				return Plugin_Handled;
			}
			else // argument is a bonus id (Use current map)
			{
				zGrp = StringToInt(szArg);
				if (0 < zGrp < MAXZONEGROUPS)
				{
					Format(szArg, 128, "%s", g_szMapName);
				}
				else
				{
					CPrintToChat(client, "%t", "InvalidBonusID", g_szChatPrefix, zGrp);
					return Plugin_Handled;
				}
			}
		}
		case 2: {
			GetCmdArg(1, szArg, 128);
			if (StringToInt(szArg) != 0 && szArg[0] != '0') // passes, if not a number (argument is mapname)
			{
				char szZGrp[128];
				GetCmdArg(2, szZGrp, 128);
				zGrp = StringToInt(szZGrp);
			}
			else // argument is a bonus id
			{
				zGrp = StringToInt(szArg);
				GetCmdArg(2, szArg, 128);
			}

			if (0 > zGrp || zGrp > MAXZONEGROUPS)
			{
				CPrintToChat(client, "%t", "InvalidBonusID", g_szChatPrefix, zGrp);
				return Plugin_Handled;
			}
		}
		default: {
			CPrintToChat(client, "%t", "BTopUsage", g_szChatPrefix);
			return Plugin_Handled;
		}
	}
	db_selectBonusTopSurfers(client, szArg, zGrp);
	return Plugin_Handled;
}

public Action Client_Spec(int client, int args)
{
	SpecPlayer(client, args);
	return Plugin_Handled;
}

public void SpecPlayer(int client, int args)
{
	char szPlayerName[MAX_NAME_LENGTH];
	char szPlayerName2[256];
	char szOrgTargetName[MAX_NAME_LENGTH];
	char szTargetName[MAX_NAME_LENGTH];
	char szArg[MAX_NAME_LENGTH];
	Format(szTargetName, MAX_NAME_LENGTH, "");
	Format(szOrgTargetName, MAX_NAME_LENGTH, "");

	if (args == 0)
	{
		Menu menu = CreateMenu(SpecMenuHandler);

		if (g_bSpectate[client])
			SetMenuTitle(menu, "Spec menu (press 'm' to rejoin a team!)\n------------------------------------------------------------\n");
		else
			SetMenuTitle(menu, "Spec menu \n------------------------------\n");
		int playerCount = 0;

		// add replay bots
		if (g_RecordBot != -1)
		{
			if (g_RecordBot != -1 && IsValidClient(g_RecordBot) && IsPlayerAlive(g_RecordBot))
			{
				Format(szPlayerName2, 256, "Map Replay (%s)", g_szReplayTime);
				AddMenuItem(menu, "MAP RECORD REPLAY", szPlayerName2);
				playerCount++;
			}
		}
		if (g_BonusBot != -1)
		{
			if (g_BonusBot != -1 && IsValidClient(g_BonusBot) && IsPlayerAlive(g_BonusBot))
			{
				Format(szPlayerName2, 256, "Bonus Replay (%s)", g_szBonusTime);
				AddMenuItem(menu, "BONUS RECORD REPLAY", szPlayerName2);
				playerCount++;
			}
		}
		if (g_WrcpBot != -1 && g_bhasStages)
		{
			if (g_WrcpBot != -1 && IsValidClient(g_WrcpBot) && IsPlayerAlive(g_WrcpBot))
			{
				Format(szPlayerName2, 256, "Stage %i Replay (%s)", g_StageReplayCurrentStage, g_szWrcpReplayTime[g_StageReplayCurrentStage]);
				AddMenuItem(menu, "STAGE RECORD REPLAY", szPlayerName2);
				playerCount++;
			}
		}

		int count = 0;
		// add players
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && IsPlayerAlive(i) && i != client && !IsFakeClient(i))
			{
				if (count == 0)
				{
					int bestrank = 99999999;
					for (int x = 1; x <= MaxClients; x++)
					{
						if (IsValidClient(x) && IsPlayerAlive(x) && x != client && !IsFakeClient(x) && g_PlayerRank[x][0] > 0)
							if (g_PlayerRank[x][0] <= bestrank)
							bestrank = g_PlayerRank[x][0];
					}
					char szMenu[128];
					Format(szMenu, 128, "Highest ranked player (#%i)", bestrank);
					AddMenuItem(menu, "brp123123xcxc", szMenu);
					AddMenuItem(menu, "", "", ITEMDRAW_SPACER);
				}
				GetClientName(i, szPlayerName, MAX_NAME_LENGTH);
				Format(szPlayerName2, 256, "%s (%s)", szPlayerName, g_pr_rankname[i]);
				AddMenuItem(menu, szPlayerName, szPlayerName2);
				playerCount++;
				count++;
			}
		}

		if (playerCount > 0 || g_RecordBot != -1 || g_BonusBot != -1)
		{
			SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
			DisplayMenu(menu, client, MENU_TIME_FOREVER);
		}

	}
	else
	{
		for (int i = 1; i < 20; i++)
		{
			GetCmdArg(i, szArg, MAX_NAME_LENGTH);
			if (!StrEqual(szArg, "", false))
			{
				if (i == 1)
					Format(szTargetName, MAX_NAME_LENGTH, "%s", szArg);
				else
					Format(szTargetName, MAX_NAME_LENGTH, "%s %s", szTargetName, szArg);
			}
		}
		Format(szOrgTargetName, MAX_NAME_LENGTH, "%s", szTargetName);
		StringToUpper(szTargetName);
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && IsPlayerAlive(i) && i != client)
			{
				GetClientName(i, szPlayerName, MAX_NAME_LENGTH);
				StringToUpper(szPlayerName);
				if ((StrContains(szPlayerName, szTargetName) != -1))
				{
					ChangeClientTeam(client, 1);
					SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", i);
					SetEntProp(client, Prop_Send, "m_iObserverMode", 4);
					g_bWrcpTimeractivated[client] = false;
					return;
				}
			}
		}
		CPrintToChat(client, "%t", "PlayerNotFound", g_szChatPrefix, szOrgTargetName);
	}
}

public int SpecMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		char szPlayerName[MAX_NAME_LENGTH];
		GetMenuItem(menu, param2, info, sizeof(info));

		if (StrEqual(info, "brp123123xcxc"))
		{
			int playerid;
			int count = 0;
			int bestrank = 99999999;
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i) && IsPlayerAlive(i) && i != param1 && !IsFakeClient(i))
				{
					if (g_PlayerRank[i][0] <= bestrank)
					{
						bestrank = g_PlayerRank[i][0];
						playerid = i;
						count++;
					}
				}
			}
			if (count == 0)
				CPrintToChat(param1, "%t", "NoPlayerTop", g_szChatPrefix);
			else
			{
				ChangeClientTeam(param1, 1);
				SetEntPropEnt(param1, Prop_Send, "m_hObserverTarget", playerid);
				SetEntProp(param1, Prop_Send, "m_iObserverMode", 4);
				g_bWrcpTimeractivated[param1] = false;
			}
		}
		else
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i) && IsPlayerAlive(i) && i != param1)
				{
					GetClientName(i, szPlayerName, MAX_NAME_LENGTH);
					if (i == g_RecordBot)
						Format(szPlayerName, MAX_NAME_LENGTH, "MAP RECORD REPLAY");
					if (i == g_BonusBot)
						Format(szPlayerName, MAX_NAME_LENGTH, "BONUS RECORD REPLAY");
					if (i == g_WrcpBot)
						Format(szPlayerName, MAX_NAME_LENGTH, "STAGE RECORD REPLAY");
					if (StrEqual(info, szPlayerName))
					{
						ChangeClientTeam(param1, 1);
						SetEntPropEnt(param1, Prop_Send, "m_hObserverTarget", i);
						SetEntProp(param1, Prop_Send, "m_iObserverMode", 4);
						g_bWrcpTimeractivated[param1] = false;
					}
				}
			}
		}
	}
	else
		if (action == MenuAction_End)
		{
			CloseHandle(menu);
		}
}

public Action Client_AutoBhop(int client, int args)
{
	AutoBhop(client);
	if (g_bAutoBhop)
	{
		if (!g_bAutoBhopClient[client])
			CPrintToChat(client, "%t", "AutoBhop2", g_szChatPrefix);
		else
			CPrintToChat(client, "%t", "AutoBhop1", g_szChatPrefix);
	}
	return Plugin_Handled;
}

public void AutoBhop(int client)
{
	if (!g_bAutoBhop)
		CPrintToChat(client, "%t", "AutoBhop3", g_szChatPrefix);

	g_bAutoBhopClient[client] = !g_bAutoBhopClient[client];

	if (g_bAutoBhopClient[client])
		SendConVarValue(client, g_hAutoBhop, "1");
	else
		SendConVarValue(client, g_hAutoBhop, "0");
}

// fluffys Kismet
public Action Client_ToggleTimer(int client, int args)
{
	ToggleTimer(client);
	if (!g_bTimerEnabled[client])
		CPrintToChat(client, "%t", "Commands31", g_szChatPrefix);
	else
		CPrintToChat(client, "%t", "Commands32", g_szChatPrefix);
	return Plugin_Handled;
}

public void ToggleTimer(int client)
{
	g_bTimerEnabled[client] = !g_bTimerEnabled[client];
	Client_Stop(client, 1);

	if (g_bTimerEnabled[client] || g_bTimerEnabled[client] && g_bNoClip[client])
	{
		Action_UnNoClip(client);
		Command_Restart(client, 1);
	}
}

void SpeedGradient(int client, bool menu = false)
{
	if (g_SpeedGradient[client] != 3)
		g_SpeedGradient[client]++;
	else
		g_SpeedGradient[client] = 0;

	if (menu)
		MiscellaneousOptions(client);
}

void SpeedMode(int client, bool menu = false)
{
	if (g_SpeedMode[client] != 2)
		g_SpeedMode[client]++;
	else
		g_SpeedMode[client] = 0;
	
	if (menu)
		MiscellaneousOptions(client);
}

void CenterSpeedDisplay(int client, bool menu = false)
{
	g_bCenterSpeedDisplay[client] = !g_bCenterSpeedDisplay[client];
	
	if (g_bCenterSpeedDisplay[client])
	{
		SetHudTextParams(-1.0, 0.30, 1.0, 255, 255, 255, 255, 0, 0.25, 0.0, 0.0);
		CreateTimer(0.1, CenterSpeedDisplayTimer, client, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	}

	if (menu)
		MiscellaneousOptions(client);
}

void TeleSide(int client, bool menu = false)
{
	if (g_iTeleSide[client] == 0)
		g_iTeleSide[client]++;
	else
		g_iTeleSide[client] = 0;
	
	if (menu)
		MiscellaneousOptions(client);
}

public Action Client_Hide(int client, int args)
{
	HideMethod(client);
	if (!g_bHide[client])
		CPrintToChat(client, "%t", "HidePlayers1", g_szChatPrefix);
	else
		CPrintToChat(client, "%t", "HidePlayers2", g_szChatPrefix);
	return Plugin_Handled;
}

void HideMethod(int client, bool menu = false)
{
	g_bHide[client] = !g_bHide[client];
	if (menu)
		MiscellaneousOptions(client);
}

public Action Client_Latest(int client, int args)
{
	db_ViewLatestRecords(client);
	return Plugin_Handled;
}

public Action Client_Help(int client, int args)
{
	// taken from adminhelp.sp
	Menu menu = CreateMenu(HelpMenuHandler);
	SetMenuTitle(menu, "Help Menu\n \n");
	Handle cmdIter = GetCommandIterator();
	char name[64];
	char desc[255];
	int flags;
	char szCommand[320];
	while (ReadCommandIterator(cmdIter, name, sizeof(name), flags, desc, sizeof(desc)))
	{
		if ((StrContains(desc, "[surftimer]", false) != -1) && CheckCommandAccess(client, name, flags))
		{
			if ((StrContains(desc, "[zoner]", false) != -1))
			{
				if (!g_bZoner[client])
					continue;
			}
			else if ((StrContains(desc, "[vip]", false) != -1))
			{
				if (!g_bVip[client])
					continue;
			}

			char szBuffer[512][2];
			ExplodeString(desc, "[surftimer]", szBuffer, 2, 512, false);
			Format(szCommand, 320, "%s - %s", name, szBuffer[1]);
			AddMenuItem(menu, "", szCommand, ITEMDRAW_DISABLED);
		}
	}
	SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

public int HelpMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
		CloseHandle(menu);
}

// old client_ranks
/*public Action Client_Ranks(int client, int args)
{
	if (IsValidClient(client))
	{
		char ChatLine[512];
		Format(ChatLine, 512, "%s", g_szChatPrefix);
		int i, RankValue[SkillGroup];
		for (i = 0; i < GetArraySize(g_hSkillGroups); i++)
		{
			GetArrayArray(g_hSkillGroups, i, RankValue[0]);

			if (i != 0 && i % 3 == 0)
			{
				CPrintToChat(client, ChatLine);
				Format(ChatLine, 512, " ");
			}
			Format(ChatLine, 512, "%s%s%c (%ip)   ", ChatLine, RankValue[RankNameColored], WHITE, RankValue[PointReq]);
		}
		CPrintToChat(client, ChatLine);
	}
	return Plugin_Handled;
}*/

public Action Client_Ranks(int client, int args)
{
	if (IsValidClient(client))
		displayRanksMenu(client);
	return Plugin_Handled;
}

public void displayRanksMenu(int client)
{
	Menu menu = CreateMenu(ShowRanksMenuHandler);
	SetMenuTitle(menu, "Chat Ranks");
	char ChatLine[512];
	int RankValue[SkillGroup];
	for (int i = 0; i < GetArraySize(g_hSkillGroups); i++)
	{
		GetArrayArray(g_hSkillGroups, i, RankValue[0]);
		ReplaceString(RankValue[RankName], sizeof(RankValue), "{style}", "");
		if (RankValue[PointsBot] > -1 && RankValue[PointsTop] > -1)
			Format(ChatLine, 512, "%i-%i Points: %s", RankValue[PointsBot], RankValue[PointsTop], RankValue[RankName]);
		else if (RankValue[PointReq] > -1)
			Format(ChatLine, 512, "%i Points: %s", RankValue[PointReq], RankValue[RankName]);
		else if (RankValue[RankBot] > 0 && RankValue[RankTop] > 0)
			Format(ChatLine, 512, "Rank %i-%i: %s", RankValue[RankBot], RankValue[RankTop], RankValue[RankName]);
		else
			Format(ChatLine, 512, "Rank %i: %s", RankValue[RankReq], RankValue[RankName]);
		
		AddMenuItem(menu, "", ChatLine, ITEMDRAW_DISABLED);
	}
	SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int ShowRanksMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public Action Client_Profile(int client, int args)
{
	// spam protection
	float diff = GetGameTime() - g_fProfileMenuLastQuery[client];
	if (diff < 0.5)
	{
		g_bSelectProfile[client] = false;
		return Plugin_Handled;
	}

	// Search for a players profile in the database
	char szName[MAX_NAME_LENGTH], szBuffer[MAX_NAME_LENGTH];
	int style = -1;
	Format(szName, sizeof(szName), "");

	// Add all arguments to the same string for names with spaces
	if (args > 0)
	{
		for (int i = 1; i < 20; i++)
		{
			GetCmdArg(i, szBuffer, MAX_NAME_LENGTH);
			if (!StrEqual(szBuffer, "", false))
			{
				if (i == 1)
				{
					style = GetStyleIndex(szBuffer);
					if (style == -1)
						Format(szName, sizeof(szName), "%s", szBuffer);
				}
				else if (i == 2 && style > -1)
					Format(szName, sizeof(szName), "%s", szBuffer);
				else
					Format(szName, MAX_NAME_LENGTH, "%s %s", szName, szBuffer);
			}
		}
	}

	// Select which style 
	ProfileMenuStyleSelect(client, style, szName);
	return Plugin_Handled;
}

public void ProfileMenuStyleSelect(int client, int style, char szName[MAX_NAME_LENGTH])
{
	if (style == -1)
	{
		Menu menu = CreateMenu(ProfileMenuStyleSelectHandler);
		SetMenuTitle(menu, "Profile Menu - Select a style");
		AddMenuItem(menu, szName, "Normal");
		AddMenuItem(menu, szName, "Sideways");
		AddMenuItem(menu, szName, "Half-Sideways");
		AddMenuItem(menu, szName, "Backwards");
		AddMenuItem(menu, szName, "Low-Gravity");
		AddMenuItem(menu, szName, "Slow Motion");
		AddMenuItem(menu, szName, "Fast Forwards");
		SetMenuExitButton(menu, true);
		DisplayMenu(menu, client, MENU_TIME_FOREVER);
	}
	else
		ProfileMenu2(client, style, szName, "");
}

public int ProfileMenuStyleSelectHandler(Handle menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char szName[MAX_NAME_LENGTH];
		GetMenuItem(menu, param2, szName, sizeof(szName));
		ProfileMenu2(param1, param2, szName, "");
	}
	else if (action == MenuAction_End)
		delete menu;
}

public void ProfileMenu2(int client, int style, char szName[MAX_NAME_LENGTH], char szSteamId3[32])
{
	g_ProfileStyleSelect[client] = style;

	// No Name found, get list of clients in server
	if (StrEqual(szName, "", false) && StrEqual(szSteamId3, ""))
	{
		char szPlayerName[MAX_NAME_LENGTH];
		Menu menu = CreateMenu(ProfilePlayerSelectMenuHandler);
		SetMenuTitle(menu, "Profile Menu - Choose a player\n------------------------------\n");
		GetClientName(client, szPlayerName, sizeof(szPlayerName));
		AddMenuItem(menu, szPlayerName, szPlayerName);
		for (int i = i; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i) && i != client)
			{
				GetClientName(i, szPlayerName, sizeof(szPlayerName));
				AddMenuItem(menu, szPlayerName, szPlayerName);
			}
		}
		g_bSelectProfile[client] = true;
		SetMenuExitButton(menu, true);
		DisplayMenu(menu, client, MENU_TIME_FOREVER);
		return;
	}
	else
	{
		// If provided with a steamid
		if (!StrEqual(szSteamId3, ""))
		{
			db_viewPlayerProfile(client, style, szSteamId3, true, "");
			return;
		}

		// Name provided, search for player on server
		bool bPlayerFound = false;
		g_bProfileInServer[client] = false;
		char szSteamId[32];
		char szBuffer[MAX_NAME_LENGTH];
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i))
			{
				GetClientName(i, szBuffer, sizeof(szBuffer));
				if (StrContains(szBuffer, szName, false) != -1)
				{
					bPlayerFound = true;
					GetClientAuthId(i, AuthId_Steam2, szSteamId, 32, true);
					g_ClientProfile[client] = i;
					g_bProfileInServer[client] = true;
					break;
				}
			}
		}

		db_viewPlayerProfile(client, style, szSteamId, bPlayerFound, szName);
	}
}

public int ProfilePlayerSelectMenuHandler(Handle menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char szPlayerName[MAX_NAME_LENGTH];
		char szBuffer[MAX_NAME_LENGTH];
		char szSteamId[32];
		GetMenuItem(menu, param2, szPlayerName, sizeof(szPlayerName));
		for (int i = 0; i < MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i))
			{
				GetClientName(i, szBuffer, sizeof(szBuffer));
				if (StrEqual(szPlayerName, szBuffer))
				{
					GetClientAuthId(i, AuthId_Steam2, szSteamId, 32, true);
					db_viewPlayerProfile(param1, g_ProfileStyleSelect[param1], szSteamId, true, szPlayerName);
					break;	
				}
			}
		}
	}
	else if (action == MenuAction_End)
		delete menu;
}

public Action Client_Pause(int client, int args)
{
	if (GetClientTeam(client) == 1)return Plugin_Handled;
	if (g_bInStartZone[client])
	{
		CPrintToChat(client, "%t", "Commands33", g_szChatPrefix);
		return Plugin_Handled;
	}
	PauseMethod(client);
	if (g_bPause[client] == false)
		CPrintToChat(client, "%t", "Pause2", g_szChatPrefix);
	else
		CPrintToChat(client, "%t", "Pause3", g_szChatPrefix);
	return Plugin_Handled;
}

public void PauseMethod(int client)
{
	if (GetClientTeam(client) == 1)return;
	if (g_bPause[client] == false && IsValidEntity(client))
	{
		if (GetConVarBool(g_hPauseServerside) == false && client != g_RecordBot && client != g_BonusBot)
		{
			CPrintToChat(client, "%t", "Pause1", g_szChatPrefix);
			return;
		}
		g_bPause[client] = true;
		/*float fVel[3];
		fVel[0] = 0.000000;
		fVel[1] = 0.000000;
		fVel[2] = 0.000000;
		SetEntPropVector(client, Prop_Data, "m_vecVelocity", fVel);
		*/
		SetEntityMoveType(client, MOVETYPE_NONE); // not sure why he sets vel to 0
		// Timer enabled?
		if (g_bTimerRunning[client] == true)
		{
			g_fStartPauseTime[client] = GetGameTime();
			if (g_fPauseTime[client] > 0.0)
				g_fStartPauseTime[client] = g_fStartPauseTime[client] - g_fPauseTime[client];
		}
		SetEntityRenderMode(client, RENDER_NONE);
		SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
	}
	else
	{
		if (g_fStartTime[client] != -1.0 && g_bTimerRunning[client] == true)
		{
			g_fPauseTime[client] = GetGameTime() - g_fStartPauseTime[client];
		}

		g_bNoClip[client] = false;
		g_bPause[client] = false;

		if (!g_bRoundEnd)
			SetEntityMoveType(client, MOVETYPE_WALK);

		SetEntityRenderMode(client, RENDER_NORMAL);

		if (GetConVarBool(g_hCvarNoBlock))
			SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
		else
			SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 5, true);

		// TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, view_as<float>( { 0.0, 0.0, -100.0 } ));
	}
}

public int GoToMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		char szPlayerName[MAX_NAME_LENGTH];
		GetMenuItem(menu, param2, info, sizeof(info));
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && IsPlayerAlive(i) && i != param1)
			{
				GetClientName(i, szPlayerName, MAX_NAME_LENGTH);
				if (StrEqual(info, szPlayerName))
				{
					GotoMethod(param1, i);
				}
				else
				{
					if (i == MaxClients)
					{
						CPrintToChat(param1, "%t", "PlayerNotFound", g_szChatPrefix, szPlayerName);
						Client_GoTo(param1, 0);
					}
				}
			}
		}
	}
	else
		if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public void GotoMethod(int client, int target)
{
	if (!IsValidClient(client) || IsFakeClient(client))
		return;
	char szTargetName[MAX_NAME_LENGTH];
	GetClientName(target, szTargetName, MAX_NAME_LENGTH);
	if (GetEntityFlags(target) & FL_ONGROUND)
	{
		Client_Stop(client, 0);

		int ducked = GetEntProp(target, Prop_Send, "m_bDucked");
		int ducking = GetEntProp(target, Prop_Send, "m_bDucking");
		if (!(GetClientButtons(client) & IN_DUCK) && ducked == 0 && ducking == 0)
		{
			if (GetClientTeam(client) == 1 || GetClientTeam(client) == 0)
			{
				float position[3];
				float angles[3];
				GetClientAbsOrigin(target, position);
				GetClientEyeAngles(target, angles);

				AddVectors(position, angles, g_fTeleLocation[client]);
				g_fTeleLocation[client][0] = FloatDiv(g_fTeleLocation[client][0], 2.0);
				g_fTeleLocation[client][1] = FloatDiv(g_fTeleLocation[client][1], 2.0);
				g_fTeleLocation[client][2] = FloatDiv(g_fTeleLocation[client][2], 2.0);

				g_bRespawnPosition[client] = false;
				g_specToStage[client] = true;
				TeamChangeActual(client, 0);
			}
			else
			{
				float position[3];
				float angles[3];
				GetClientAbsOrigin(target, position);
				GetClientEyeAngles(target, angles);
				teleportEntitySafe(client, position, angles, view_as<float>( { 0.0, 0.0, -100.0 } ), true);
				// TeleportEntity(client, position, angles, Float:{0.0,0.0,-100.0});
				char szClientName[MAX_NAME_LENGTH];
				GetClientName(client, szClientName, MAX_NAME_LENGTH);
				CPrintToChat(target, "%t", "Goto5", g_szChatPrefix, szClientName);
			}
		}
		else
		{
			CPrintToChat(client, "%t", "Goto6", g_szChatPrefix, szTargetName);
			Client_GoTo(client, 0);
		}
	}
	else
	{
		CPrintToChat(client, "%t", "Goto7", g_szChatPrefix, szTargetName);
		Client_GoTo(client, 0);
	}
}

public Action Client_GoTo(int client, int args)
{
	if (!GetConVarBool(g_hGoToServer))
		CPrintToChat(client, "%t", "Goto1", g_szChatPrefix);
	else
		if (!GetConVarBool(g_hCvarNoBlock))
			CPrintToChat(client, "%t", "Goto2", g_szChatPrefix);
		else
			if (g_bTimerRunning[client])
				CPrintToChat(client, "%t", "Goto3", g_szChatPrefix);
			else
			{
				char szPlayerName[MAX_NAME_LENGTH];
				char szOrgTargetName[MAX_NAME_LENGTH];
				char szTargetName[MAX_NAME_LENGTH];
				char szArg[MAX_NAME_LENGTH];
				if (args == 0)
				{
					Menu menu = CreateMenu(GoToMenuHandler);
					SetMenuTitle(menu, "Goto menu");
					int playerCount = 0;
					for (int i = 1; i <= MaxClients; i++)
					{
						if (IsValidClient(i) && IsPlayerAlive(i) && i != client && !IsFakeClient(i))
						{
							GetClientName(i, szPlayerName, MAX_NAME_LENGTH);
							AddMenuItem(menu, szPlayerName, szPlayerName);
							playerCount++;
						}
					}
					if (playerCount > 0)
					{
						SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
						DisplayMenu(menu, client, MENU_TIME_FOREVER);
					}
					else
					{
						CloseHandle(menu);
					}
				}
				else
				{
					for (int i = 1; i < 20; i++)
					{
						GetCmdArg(i, szArg, MAX_NAME_LENGTH);
						if (!StrEqual(szArg, "", false))
						{
							if (i == 1)
								Format(szTargetName, MAX_NAME_LENGTH, "%s", szArg);
							else
								Format(szTargetName, MAX_NAME_LENGTH, "%s %s", szTargetName, szArg);
						}
					}
					Format(szOrgTargetName, MAX_NAME_LENGTH, "%s", szTargetName);
					StringToUpper(szTargetName);
					for (int i = 1; i <= MaxClients; i++)
					{
						if (IsValidClient(i) && IsPlayerAlive(i) && i != client)
						{
							GetClientName(i, szPlayerName, MAX_NAME_LENGTH);
							StringToUpper(szPlayerName);
							if ((StrContains(szPlayerName, szTargetName) != -1))
							{
								GotoMethod(client, i);
								return Plugin_Handled;
							}
						}
					}
					CPrintToChat(client, "%t", "PlayerNotFound", g_szChatPrefix, szOrgTargetName);
				}
			}
	return Plugin_Handled;
}

public Action Client_QuakeSounds(int client, int args)
{
	QuakeSounds(client);
	if (g_bEnableQuakeSounds[client])
		CPrintToChat(client, "%t", "QuakeSounds1", g_szChatPrefix);
	else
		CPrintToChat(client, "%t", "QuakeSounds2", g_szChatPrefix);
	return Plugin_Handled;
}

void QuakeSounds(int client, bool menu = false)
{
	g_bEnableQuakeSounds[client] = !g_bEnableQuakeSounds[client];
	if (menu)
		MiscellaneousOptions(client);
}

public Action Client_Stop(int client, int args)
{
	if (g_bTimerRunning[client])
	{
		// PlayerPanel(client);
		g_bTimerRunning[client] = false;
		g_fStartTime[client] = -1.0;
		g_fCurrentRunTime[client] = -1.0;
	}

	if (g_bWrcpTimeractivated[client])
	{
		g_bWrcpTimeractivated[client] = false;
		g_fStartWrcpTime[client] = -1.0;
		g_fCurrentWrcpRunTime[client] = -1.0;
	}

	// Strafe Sync
	g_iGoodGains[client] = 0;
	g_iTotalMeasures[client] = 0;

	return Plugin_Handled;
}

public void Action_NoClip(int client)
{
	if (IsValidClient(client) && !IsFakeClient(client) && IsPlayerAlive(client) && GetConVarBool(g_hNoClipS))
	{
		g_fLastTimeNoClipUsed[client] = GetGameTime();
		int team = GetClientTeam(client);
		if (team == 2 || team == 3)
		{
			MoveType mt = GetEntityMoveType(client);
			if (mt == MOVETYPE_WALK)
			{
				if (g_bTimerRunning[client])
				{
					Client_Stop(client, 1);
					g_fStartTime[client] = -1.0;
					g_fCurrentRunTime[client] = -1.0;
				}
				SetEntityMoveType(client, MOVETYPE_NOCLIP);
				SetEntityRenderMode(client, RENDER_NONE);
				SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
				g_bNoClip[client] = true;
				g_bInStartZone[client] = true;
				g_bWrcpTimeractivated[client] = false;
			}
		}
	}
	return;
}

public void Action_UnNoClip(int client)
{
	if (IsValidClient(client) && !IsFakeClient(client) && IsPlayerAlive(client))
	{
		g_fLastTimeNoClipUsed[client] = GetGameTime();
		int team = GetClientTeam(client);
		if (team == 2 || team == 3)
		{
			MoveType mt = GetEntityMoveType(client);
			if (mt == MOVETYPE_NOCLIP)
			{
				SetEntityMoveType(client, MOVETYPE_WALK);
				SetEntityRenderMode(client, RENDER_NORMAL);
				if (GetConVarBool(g_hCvarNoBlock))
					SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
				else
					SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 5, 4, true);
				g_bNoClip[client] = false;
			}
		}
	}
	return;
}

public void ckTopMenu(int client, int style)
{
	g_MenuLevel[client] = -1;
	Menu cktopmenu = CreateMenu(TopMenuHandler);

	char szTitle[128], szStyle[2];
	Format(szTitle, sizeof(szTitle), "Top Menu - %s\n------------------------------\n", g_szStyleMenuPrint[style]);
	SetMenuTitle(cktopmenu, szTitle);
	IntToString(style, szStyle, sizeof(szStyle));

	if (GetConVarBool(g_hPointSystem))
		AddMenuItem(cktopmenu, szStyle, "Top 100 Players");

	AddMenuItem(cktopmenu, szStyle, "Map Top");
	AddMenuItem(cktopmenu, szStyle, "Bonus Top", !g_bhasBonus);

	SetMenuOptionFlags(cktopmenu, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(cktopmenu, client, MENU_TIME_FOREVER);
}

public int TopMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char szBuffer[2];
		GetMenuItem(menu, param2, szBuffer, sizeof(szBuffer));
		int style = StringToInt(szBuffer);
		switch (param2)
		{
			case 0: db_selectTopPlayers(param1, style);
			case 1: SelectMapTop(param1, style);
			case 2: BonusTopMenu(param1);
		}
	}
	else
		if (action == MenuAction_End)
		CloseHandle(menu);
}

public void SelectMapTop(int client, int style)
{
	if (IsValidClient(client))
	{
		if (style > 0)
			db_selectStyleMapTopSurfers(client, g_szMapName, style);
		else
			db_selectTopSurfers(client, g_szMapName);
	}
}

public void BonusTopMenu(int client)
{
	if (g_mapZoneGroupCount > 2)
	{
		char buffer[3];
		Menu sMenu = new Menu(BonusTopMenuHandler);
		sMenu.SetTitle("Bonus selector");

		if (g_mapZoneGroupCount > 1)
		{
			for (int i = 1; i < g_mapZoneGroupCount; i++)
			{
				IntToString(i, buffer, 3);
				sMenu.AddItem(buffer, g_szZoneGroupName[i]);
			}
		}
		else
		{
			CPrintToChat(client, "%t", "NoBonusOnMap", g_szChatPrefix);
			return;
		}

		sMenu.ExitButton = true;
		sMenu.Display(client, 60);
	}
	else {
		db_selectBonusTopSurfers(client, g_szMapName, 1);
	}
}

public int BonusTopMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		db_selectBonusTopSurfers(param1, g_szMapName, param2 + 1);
	}
}

public void OptionMenu(int client)
{
	Menu optionmenu = CreateMenu(OptionMenuHandler);
	SetMenuTitle(optionmenu, "Options Menu\n \n");
	// #0
	if (g_bTimerEnabled[client])
		AddMenuItem(optionmenu, "ToggleTimer", "[ON] Toggle Timer\n \n");
	else
		AddMenuItem(optionmenu, "ToggleTimer", "[OFF] Toggle Timer\n \n");

	AddMenuItem(optionmenu, "CentreHud", "Centre Hud Options");
	AddMenuItem(optionmenu, "SideHud", "Side Hud Options");
	AddMenuItem(optionmenu, "Miscellaneous", "Miscellaneous Options");

	SetMenuOptionFlags(optionmenu, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(optionmenu, client, MENU_TIME_FOREVER);
}

public int OptionMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0:
			{
				ToggleTimer(param1);
				OptionMenu(param1);
			}
			case 1: CentreHudOptions(param1, 0);
			case 2: SideHudOptions(param1, 0);
			case 3: MiscellaneousOptions(param1);
		}
	}
	else
		if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public void CentreHudOptions(int client, int item)
{
	Menu menu = CreateMenu(CentreHudOptionsHandler);
	SetMenuTitle(menu, "Options Menu - Centre Hud\n \n");

	if (g_bCentreHud[client])
		AddMenuItem(menu, "", "[ON] Centre Hud");
	else
		AddMenuItem(menu, "", "[OFF] Centre Hud");

	AddMenuItem(menu, "", "Reset Modules\n \n");

	AddMenuItem(menu, "Top Left Module", "Top Left Module");
	AddMenuItem(menu, "Top Right Module", "Top Right Module\n \n");
	AddMenuItem(menu, "Middle Left Module", "Middle Left Module");
	AddMenuItem(menu, "Middle Right Module", "Middle Right Module\n \n");
	AddMenuItem(menu, "Bottom Left Module", "Bottom Left Module");
	AddMenuItem(menu, "Bottom Right Module", "Bottom Right Module");

	SetMenuExitBackButton(menu, true);

	if (item < 6)
		item = 0;
	else if (item < 12)
		item = 6;
		
	DisplayMenuAtItem(menu, client, item, MENU_TIME_FOREVER);
}

public int CentreHudOptionsHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		if (param2 == 0)
		{
			g_bCentreHud[param1] = !g_bCentreHud[param1];
			CentreHudOptions(param1, 0);
		}
		else if (param2 == 1)
		{
			g_bCentreHud[param1] = true;
			g_iCentreHudModule[param1][0] = 1;
			g_iCentreHudModule[param1][1] = 2;
			g_iCentreHudModule[param1][2] = 3;
			g_iCentreHudModule[param1][3] = 4;
			g_iCentreHudModule[param1][4] = 5;
			g_iCentreHudModule[param1][5] = 6;
			CentreHudOptions(param1, 0);
		}
		else
		{
			char szTitle[128];
			int module;
			GetMenuItem(menu, param2, szTitle, sizeof(szTitle));
			if (StrEqual(szTitle, "Top Left Module"))
				module = 0;
			else if (StrEqual(szTitle, "Top Right Module"))
				module = 1;
			else if (StrEqual(szTitle, "Middle Left Module"))
				module = 2;
			else if (StrEqual(szTitle, "Middle Right Module"))
				module = 3;
			else if (StrEqual(szTitle, "Bottom Left Module"))
				module = 4;
			else if (StrEqual(szTitle, "Bottom Right Module"))
				module = 5;
			else
				module = 0;

			CentreHudModulesMenu(param1, module, szTitle);
		}	
	}
	else if (action == MenuAction_Cancel)
		OptionMenu(param1);
	else if (action == MenuAction_End)
		CloseHandle(menu);
}

public void CentreHudModulesMenu(int client, int module, const char[] szTitle)
{
	Menu menu = CreateMenu(CentreHudModulesMenuHandler);
	char szTitle2[256];
	Format(szTitle2, sizeof(szTitle2), "%s\n \n", szTitle);
	SetMenuTitle(menu, szTitle2);

	// Toggle Module
	if (g_iCentreHudModule[client][module] == 0)
		AddMenuItem(menu, szTitle, "[OFF] Toggle Module\n \n");
	else
		AddMenuItem(menu, szTitle, "[ON] Toggle Module\n \n");

	// Timer
	if (g_iCentreHudModule[client][module] == 1)
		AddMenuItem(menu, szTitle, "[ON] Timer");
	else
		AddMenuItem(menu, szTitle, "[OFF] Timer");

	// WR
	if (g_iCentreHudModule[client][module] == 2)
		AddMenuItem(menu, szTitle, "[ON] World Record");
	else
		AddMenuItem(menu, szTitle, "[OFF] World Record");

	// PB
	if (g_iCentreHudModule[client][module] == 3)
		AddMenuItem(menu, szTitle, "[ON] Personal Best");
	else
		AddMenuItem(menu, szTitle, "[OFF] Personal Best");

	// Rank
	if (g_iCentreHudModule[client][module] == 4)
		AddMenuItem(menu, szTitle, "[ON] Rank Display");
	else
		AddMenuItem(menu, szTitle, "[OFF] Rank Display");

	// Stage
	if (g_iCentreHudModule[client][module] == 5)
		AddMenuItem(menu, szTitle, "[ON] Stage Display");
	else
		AddMenuItem(menu, szTitle, "[OFF] Stage Display");

	// Speed
	if (g_iCentreHudModule[client][module] == 6)
		AddMenuItem(menu, szTitle, "[ON] Speed Display");
	else
		AddMenuItem(menu, szTitle, "[OFF] Speed Display");

	// Strafe Sync
	if (g_iCentreHudModule[client][module] == 7)
		AddMenuItem(menu, szTitle, "[ON] Strafe Sync");
	else
		AddMenuItem(menu, szTitle, "[OFF] Strafe Sync");

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int CentreHudModulesMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char szModule[128];
		int module;
		GetMenuItem(menu, param2, szModule, sizeof(szModule));

		if (StrEqual("Top Left Module", szModule))
			module = 0;
		else if (StrEqual("Top Right Module", szModule))
			module = 1;
		else if (StrEqual("Middle Left Module", szModule))
			module = 2;
		else if (StrEqual("Middle Right Module", szModule))
			module = 3;
		else if (StrEqual("Bottom Left Module", szModule))
			module = 4;
		else if (StrEqual("Bottom Right Module", szModule))
			module = 5;
		else
		{
			CPrintToChat(param1, "%t", "Commands37", g_szChatPrefix);
			CloseHandle(menu);
		}

		g_iCentreHudModule[param1][module] = param2;
		CentreHudModulesMenu(param1, module, szModule);
	}
	else if (action == MenuAction_Cancel)
		CentreHudOptions(param1, 0);
	else if (action == MenuAction_End)
		CloseHandle(menu);
}

public void SideHudOptions(int client, int item)
{
	Menu menu = CreateMenu(SideHudOptionsHandler);
	SetMenuTitle(menu, "Options Menu - Side Hud\n \n");

	AddMenuItem(menu, "Module 1", "Module 1");
	AddMenuItem(menu, "Module 2", "Module 2");
	AddMenuItem(menu, "Module 3", "Moudle 3");
	AddMenuItem(menu, "Module 4", "Module 4");
	AddMenuItem(menu, "Module 5", "Module 5\n \n");

	// Side Hud
	if (g_bSideHud[client])
		AddMenuItem(menu, "", "[ON] Side Hud");
	else
		AddMenuItem(menu, "", "[OFF] Side Hud");

	AddMenuItem(menu, "", "How do I get the old spec menu back?");

	SetMenuExitBackButton(menu, true);

	if (item < 6)
		item = 0;
	else if (item < 12)
		item = 6;

	DisplayMenuAtItem(menu, client, item, MENU_TIME_FOREVER);
}

public int SideHudOptionsHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		if (param2 == 5)
		{
			g_bSideHud[param1] = !g_bSideHud[param1];
			SideHudOptions(param1, 0);
		}
		else if (param2 == 6)
		{
			CPrintToChat(param1, "%t", "Commands38", g_szChatPrefix);
			SideHudOptions(param1, 6);
		}
		else
		{
			char szTitle[32];
			GetMenuItem(menu, param2, szTitle, sizeof(szTitle));
			SideHudModulesMenu(param1, param2, szTitle);
		}
	}
	else if (action == MenuAction_Cancel)
		OptionMenu(param1);
	else if (action == MenuAction_End)
		CloseHandle(menu);
}

public void SideHudModulesMenu(int client, int module, char[] szTitle)
{
	Menu menu = CreateMenu(SideHudModulesMenuHandler);
	char szTitle2[256];
	Format(szTitle2, sizeof(szTitle2), "%s\n \n", szTitle);
	SetMenuTitle(menu, szTitle2);

	// Format(szPanel, sizeof(szPanel), "Timeleft: %s\n \n%s \nby %s\n \n%s\n%s\n \n%s\nWRCP: %s\nby %s\n \nSpecs (6)\nfluffys\nGrandpa Goose\nJakeey802\nant\nsoda\n...", szTimeleft, szWR, g_szRecordPlayer, szPB, szRank, szStage, szWrcpTime, g_szStageRecordPlayer[stage]);
	
	// Toggle Module
	if (g_iSideHudModule[client][module] == 0)
		AddMenuItem(menu, szTitle, "[OFF] Toggle Module\n \n");
	else
		AddMenuItem(menu, szTitle, "[ON] Toggle Module\n \n");

	// Timeleft
	if (g_iSideHudModule[client][module] == 1)
		AddMenuItem(menu, szTitle, "[ON] Timeleft");
	else
		AddMenuItem(menu, szTitle, "[OFF] Timeleft");

	// WR
	if (g_iSideHudModule[client][module] == 2)
		AddMenuItem(menu, szTitle, "[ON] World Record Info");
	else
		AddMenuItem(menu, szTitle, "[OFF] World Record Info");

	// PB
	if (g_iSideHudModule[client][module] == 3)
		AddMenuItem(menu, szTitle, "[ON] Personal Best Info");
	else
		AddMenuItem(menu, szTitle, "[OFF] Personal Best Info");

	// Stage Info
	if (g_iSideHudModule[client][module] == 4)
		AddMenuItem(menu, szTitle, "[ON] Stage Info");
	else
		AddMenuItem(menu, szTitle, "[OFF] Stage Info");

	// Spec list
	if (g_iSideHudModule[client][module] == 5)
		AddMenuItem(menu, szTitle, "[ON] Spec List");
	else
		AddMenuItem(menu, szTitle, "[OFF] Spec List");

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int SideHudModulesMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char szModule[128];
		int module;
		GetMenuItem(menu, param2, szModule, sizeof(szModule));

		if (StrEqual("Module 1", szModule))
			module = 0;
		else if (StrEqual("Module 2", szModule))
			module = 1;
		else if (StrEqual("Module 3", szModule))
			module = 2;
		else if (StrEqual("Module 4", szModule))
			module = 3;
		else if (StrEqual("Module 5", szModule))
			module = 4;
		else
		{
			CPrintToChat(param1, "%t", "Commands39", g_szChatPrefix);
			CloseHandle(menu);
		}

		g_iSideHudModule[param1][module] = param2;

		if (g_iSideHudModule[param1][0] == 5 && (g_iSideHudModule[param1][1] == 0 && g_iSideHudModule[param1][2] == 0 && g_iSideHudModule[param1][3] == 0 && g_iSideHudModule[param1][4] == 0))
			g_bSpecListOnly[param1] = true;
		else
			g_bSpecListOnly[param1] = false;

		SideHudModulesMenu(param1, module, szModule);
	}
	else if (action == MenuAction_Cancel)
		SideHudOptions(param1, 0);
	else if (action == MenuAction_End)
		CloseHandle(menu);
}

public void MiscellaneousOptions(int client)
{
	Menu menu = CreateMenu(MiscellaneousOptionsHandler);
	SetMenuTitle(menu, "Options Menu - Miscellaneous\n \n");

	// Hide
	if (g_bHide[client])
		AddMenuItem(menu, "", "[ON] Hide Players");
	else
		AddMenuItem(menu, "", "[OFF] Hide Players");

	// Timer Sounds
	if (g_bEnableQuakeSounds[client])
		AddMenuItem(menu, "", "[ON] Timer Sounds");
	else
		AddMenuItem(menu, "", "[OFF] Timer Sounds");
	
	// Tele Side
	if (g_iTeleSide[client] == 0)
		AddMenuItem(menu, "", "[LEFT] Start Side");
	else
		AddMenuItem(menu, "", "[RIGHT] Start Side");

	// Speed Gradient
	if (g_SpeedGradient[client] == 0)
		AddMenuItem(menu, "", "[WHITE] Speed Gradient");
	else if (g_SpeedGradient[client] == 1)
		AddMenuItem(menu, "", "[GREEN] Speed Gradient");
	else if (g_SpeedGradient[client] == 2)
		AddMenuItem(menu, "", "[RAINBOW] Speed Gradient");
	else
		AddMenuItem(menu, "", "[MOMENTUM] Speed Gradient");
	
	// Speed Mode
	if (g_SpeedMode[client] == 0)
		AddMenuItem(menu, "", "[XY] Speed Mode");
	else if (g_SpeedMode[client] == 1)
		AddMenuItem(menu, "", "[XYZ] Speed Mode");
	else
		AddMenuItem(menu, "", "[Z] Speed Mode");

	// Centre Speed Display
	if (g_bCenterSpeedDisplay[client])
		AddMenuItem(menu, "", "[ON] Centre Speed Display");
	else
		AddMenuItem(menu, "", "[OFF] Centre Speed Display");

	// Hide Chat
	if (g_bHideChat[client])
		AddMenuItem(menu, "", "[ON] Hide Chat");
	else
		AddMenuItem(menu, "", "[OFF] Hide Chat");

	// Hide Weapon
	if (g_bViewModel[client])
		AddMenuItem(menu, "", "[OFF] Hide Weapon");
	else
		AddMenuItem(menu, "", "[ON] Hide Weapon");
	

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int MiscellaneousOptionsHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0: HideMethod(param1, true);
			case 1: QuakeSounds(param1, true);
			case 2: TeleSide(param1, true);
			case 3: SpeedGradient(param1, true);
			case 4: SpeedMode(param1, true);
			case 5: CenterSpeedDisplay(param1, true);
			case 6: HideChat(param1, true);
			case 7: HideViewModel(param1, true);
		}
	}
	else if (action == MenuAction_Cancel)
		OptionMenu(param1);
	else if (action == MenuAction_End)
		CloseHandle(menu);
}

// fluffys
public Action Command_PlayerTitle(int client, int args)
{
	if (IsValidClient(client) && IsPlayerVip(client))
		CustomTitleMenu(client);
	return Plugin_Handled;
}

public Action Command_SetDbTitle(int client, int args)
{
	if (!IsValidClient(client) || !IsPlayerVip(client))
		return Plugin_Handled;

	char arg[256], authSteamId[MAXPLAYERS + 1];
	GetClientAuthId(client, AuthId_Steam2, authSteamId, MAX_NAME_LENGTH, true);

	if (args == 0)
	{
		if (g_bdbHasCustomTitle[client])
		{
			db_toggleCustomPlayerTitle(client, authSteamId);
		}
		else
		{
			CPrintToChat(client, "%t", "Commands40", g_szChatPrefix);
		}
	}
	else
	{
		GetCmdArg(1, arg, 256);
		char upperArg[256];
		char noColoursArg[256];
		upperArg = arg;
		StringToUpper(upperArg);
		noColoursArg = upperArg;
		parseColorsFromString(noColoursArg, 256);

		if (strlen(noColoursArg) > 20)
		{
			CPrintToChat(client, "%t", "Commands41", g_szChatPrefix);

			return Plugin_Handled;
		}
		else if (StrContains(upperArg, "{RED}") != -1)
			ReplaceString(arg, 256, "{red}", "{lightred}", false);
		else if (StrContains(upperArg, "{LIMEGREEN}") != -1)
			ReplaceString(arg, 256, "{limegreen}", "{lime}");
		else if (StrContains(upperArg, "{WHITE}") != -1)
			ReplaceString(arg, 256, "{white}", "{default}", false);

		// Check if arg is in unallowed titles array
		for (int i = 0; i < sizeof(UnallowedTitles); i++)
		{
			if (StrContains(UnallowedTitles[i], upperArg)!=-1)
			{
				arg = "{pink}Fag";
				break;
			}
		}

		db_checkCustomPlayerTitle(client, authSteamId, arg);
	}

	return Plugin_Handled;
}

public Action Command_JoinMsg(int client, int args)
{
	if (!IsValidClient(client) || !IsPlayerVip(client))
		return Plugin_Handled;

	if (args == 0)
	{
		CReplyToCommand(client, "%t", "Commands73", g_szChatPrefix);
		return Plugin_Handled;
	}

	char szArg[256];
	GetCmdArg(1, szArg, sizeof(szArg));
	db_setJoinMsg(client, szArg);

	return Plugin_Handled;
}

public Action Command_ToggleTitle(int client, int args)
{
	if (!IsValidClient(client) || !IsPlayerVip(client))
		return Plugin_Handled;

	char authSteamId[MAXPLAYERS + 1];

	GetClientAuthId(client, AuthId_Steam2, authSteamId, MAX_NAME_LENGTH, true);

	db_toggleCustomPlayerTitle(client, authSteamId);

	return Plugin_Handled;
}

public Action Command_SetDbNameColour(int client, int args)
{
	if (!IsValidClient(client) || !IsPlayerVip(client))
		return Plugin_Handled;

	char arg[128], authSteamId[MAXPLAYERS + 1];
	GetClientAuthId(client, AuthId_Steam2, authSteamId, MAX_NAME_LENGTH, true);

	if (args == 0)
	{
			CPrintToChat(client, "%t", "Commands42", g_szChatPrefix);
	}
	else
	{
		GetCmdArg(1, arg, 128);
		char upperArg[128];
		upperArg = arg;
		StringToUpper(upperArg);
		if (StrContains(upperArg, "{DEFAULT}", false)!=-1 || StrContains(upperArg, "{WHITE}")!=-1)
		{
			arg = "0";
		}
		else if (StrContains(upperArg, "{DARKRED}", false)!=-1)
		{
			arg = "1";
		}
		else if (StrContains(upperArg, "{GREEN}", false)!=-1)
		{
			arg = "2";
		}
		else if (StrContains(upperArg, "{LIMEGREEN}", false)!=-1 || StrContains(upperArg, "{LIME}")!=-1)
		{
			arg = "3";
		}
		else if (StrContains(upperArg, "{BLUE}", false)!=-1)
		{
			arg = "4";
		}
		else if (StrContains(upperArg, "{LIGHTGREEN}", false)!=-1)
		{
		 	arg = "5";
		}
		else if (StrContains(upperArg, "{RED}", false)!=-1)
		{
			arg = "6";
		}
		else if (StrContains(upperArg, "{GREY}", false)!=-1 || StrContains(upperArg, "{GRAY}")!=-1)
		{
			arg = "7";
		}
		else if (StrContains(upperArg, "{YELLOW}", false)!=-1)
		{
		 	arg = "8";
		}
		else if (StrContains(upperArg, "{LIGHTBLUE}", false)!=-1)
		{
			arg = "9";
		}
		else if (StrContains(upperArg, "{DARKBLUE}", false)!=-1)
		{
			arg = "10";
		}
		else if (StrContains(upperArg, "{PINK}", false)!=-1)
		{
			arg = "11";
		}
		else if (StrContains(upperArg, "{LIGHTRED}", false)!=-1)
		{
			arg = "12";
		}
		else if (StrContains(upperArg, "{PURPLE}", false)!=-1)
		{
			arg = "13";
		}
		else if (StrContains(upperArg, "{DARKGREY}", false)!=-1 || StrContains(upperArg, "{DARKGRAY}")!=-1)
		{
			arg = "14";
		}
		else if (StrContains(upperArg, "{ORANGE}", false)!=-1)
		{
			arg = "15";
		}
		else
		{
			arg = "0";
		}

		db_checkCustomPlayerNameColour(client, authSteamId, arg);
	}

	return Plugin_Handled;
}

public Action Command_SetDbTextColour(int client, int args)
{
	if (!IsValidClient(client) || !IsPlayerVip(client))
		return Plugin_Handled;

	char arg[128], authSteamId[MAXPLAYERS + 1];
	GetClientAuthId(client, AuthId_Steam2, authSteamId, MAX_NAME_LENGTH, true);

	if (args == 0)
	{
		CPrintToChat(client, "%t", "Commands43", g_szChatPrefix);
	}
	else
	{
		GetCmdArg(1, arg, 128);
		char upperArg[128];
		upperArg = arg;
		StringToUpper(upperArg);
		if (StrContains(upperArg, "{DEFAULT}", false)!=-1 || StrContains(upperArg, "{WHITE}")!=-1)
		{
			arg = "0";
		}
		else if (StrContains(upperArg, "{DARKRED}", false)!=-1)
		{
			arg = "1";
		}
		else if (StrContains(upperArg, "{GREEN}", false)!=-1)
		{
			arg = "2";
		}
		else if (StrContains(upperArg, "{LIMEGREEN}", false)!=-1 || StrContains(upperArg, "{LIME}", false)!=-1)
		{
			arg = "3";
		}
		else if (StrContains(upperArg, "{BLUE}", false)!=-1)
		{
			arg = "4";
		}
		else if (StrContains(upperArg, "{LIGHTGREEN}", false)!=-1 || StrContains(upperArg, "{OLIVE}", false)!=-1)
		{
		 	arg = "5";
		}
		else if (StrContains(upperArg, "{RED}", false)!=-1)
		{
			arg = "6";
		}
		else if (StrContains(upperArg, "{GREY}", false)!=-1 || StrContains(upperArg, "{GRAY}")!=-1)
		{
			arg = "7";
		}
		else if (StrContains(upperArg, "{YELLOW}", false)!=-1)
		{
		 	arg = "8";
		}
		else if (StrContains(upperArg, "{LIGHTBLUE}", false)!=-1)
		{
			arg = "9";
		}
		else if (StrContains(upperArg, "{DARKBLUE}", false)!=-1)
		{
			arg = "10";
		}
		else if (StrContains(upperArg, "{PINK}", false)!=-1)
		{
			arg = "11";
		}
		else if (StrContains(upperArg, "{LIGHTRED}", false)!=-1)
		{
			arg = "12";
		}
		else if (StrContains(upperArg, "{PURPLE}", false)!=-1)
		{
			arg = "13";
		}
		else if (StrContains(upperArg, "{DARKGREY}", false)!=-1 || StrContains(upperArg, "{DARKGRAY}")!=-1)
		{
			arg = "14";
		}
		else if (StrContains(upperArg, "{ORANGE}", false)!=-1)
		{
			arg = "15";
		}
		else
		{
			arg = "0";
		}

		db_checkCustomPlayerTextColour(client, authSteamId, arg);
	}

	return Plugin_Handled;
}

public Action Command_ListColours(int client, int args)
{
	CPrintToChat(client, "%t", "Commands44", g_szChatPrefix);
	return Plugin_Handled;
}

public Action Client_Wrcp(int client, int args)
{
	if (args == 0)
		Format(g_szWrcpMapSelect[client], sizeof(g_szWrcpMapSelect), g_szMapName);
	else
		GetCmdArg(1, g_szWrcpMapSelect[client], 128);
	WrcpStyleSelectMenu(client);
	return Plugin_Handled;
}

public void WrcpStyleSelectMenu(int client)
{
	Menu menu = CreateMenu(WrcpStyleSelectMenuHandler);
	SetMenuTitle(menu, "WRCP: Select a style");
	AddMenuItem(menu, "", "Normal");
	AddMenuItem(menu, "", "Sideways");
	AddMenuItem(menu, "", "Half-Sideways");
	AddMenuItem(menu, "", "Backwards");
	AddMenuItem(menu, "", "Low-Gravity");
	AddMenuItem(menu, "", "Slow Motion");
	AddMenuItem(menu, "", "Fast Forwards");
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int WrcpStyleSelectMenuHandler(Handle menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		g_ProfileStyleSelect[param1] = param2;
		if (StrEqual(g_szMapName, g_szWrcpMapSelect[param1]))
			WrcpMenu(param1, 0, param2);
		else
			WrcpMenu(param1, 1, param2);
	}
	else if (action == MenuAction_End)
		delete menu;
}

public void WrcpMenu(int client, int args, int style)
{
	// Spam Protection
	float diff = GetGameTime() - g_fWrcpMenuLastQuery[client];
	if (diff < 0.5)
	{
		g_bSelectWrcp[client] = false;
		return;
	}
	g_iWrcpMenuStyleSelect[client] = style;
	g_fWrcpMenuLastQuery[client] = GetGameTime();

	char szStageString[MAXPLAYERS + 1];
	char stage[MAXPLAYERS + 1];
	// No Argument
	if (args == 0)
	{
		if (!g_bhasStages)
		{
			CPrintToChat(client, "%t", "Commands87", g_szChatPrefix);
			return;
		}

		g_szWrcpMapSelect[client] = g_szMapName;
		Menu menu;
		if (style == 0)
		{
			menu = CreateMenu(StageSelectMenuHandler);
			SetMenuTitle(menu, "%s: select a stage \n------------------------------\n", g_szMapName);
		}
		else if (style != 0)
		{
			g_StyleStageSelect[client] = style;
			menu = CreateMenu(StageStyleSelectMenuHandler);
			SetMenuTitle(menu, "%s: select a stage [%s] \n------------------------------\n", g_szMapName, g_szStyleMenuPrint[style]);
		}
		int stageCount = g_TotalStages;
		for (int i = 1; i <= stageCount; i++)
		{
	 			stage[0] = i;
				Format(szStageString, sizeof(szStageString), "Stage %i", i);
				AddMenuItem(menu, stage[0], szStageString);
		}
		g_bSelectWrcp[client] = true;
		SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
		DisplayMenu(menu, client, MENU_TIME_FOREVER);
		return;
	}
	else
	{
		if (StrContains(g_szWrcpMapSelect[client], "#", false) != -1)
		{
			ReplaceString(g_szWrcpMapSelect[client], 128, "#", "", false);
			if (style == 0)
				db_viewWrcpMapRecord(client);
			else
				db_viewWrcpStyleMapRecord(client, style);
		}
		else
		{
			if (style == 0)
				db_viewWrcpMap(client, g_szWrcpMapSelect[client]);
			else
				db_viewStyleWrcpMap(client, g_szWrcpMapSelect[client], style);
		}
	}
}

public int StageSelectMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		GetMenuItem(menu, param2, info, sizeof(info));
		// CPrintToChat(param1, "Stage %i - %s", info, g_szWrcpMapSelect[param1]);
		db_selectStageTopSurfers(param1, info, g_szWrcpMapSelect[param1]);
	}
	else
	{
		if (action == MenuAction_End)
		{
			if (IsValidClient(param1))
				g_bSelectWrcp[param1] = false;
			CloseHandle(menu);
		}
	}
}

public int StageStyleSelectMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		int style = g_StyleStageSelect[param1];
		char info[32];
		GetMenuItem(menu, param2, info, sizeof(info));
		// CPrintToChat(param1, "Stage %i - %s", info, g_szWrcpMapSelect[param1]);
		db_selectStageStyleTopSurfers(param1, info, g_szWrcpMapSelect[param1], style);
	}
	else
	{
		if (action == MenuAction_End)
		{
			if (IsValidClient(param1))
				g_bSelectWrcp[param1] = false;
			CloseHandle(menu);
		}
	}
}

// fluffys sm_gb
public Action Command_GoBack(int client, int args)
{
	if (g_Stage[0][client] <= 1)
		Command_Restart(client, 1);
	else
		teleportClient(client, 0, g_Stage[0][client] - 1, false);

	return Plugin_Handled;
}

// Styles
public Action Client_SelectStyle(int client, int args)
{
	styleSelectMenu(client);
	return Plugin_Handled;
}

public void styleSelectMenu(int client)
{
	Menu styleSelect = CreateMenu(StyleTypeSelectMenuHandler);
	SetMenuTitle(styleSelect, "Current Style: %s\n------------------------------\n", g_szInitalStyle[client]);
	AddMenuItem(styleSelect, "ranked", "Ranked Styles");
	AddMenuItem(styleSelect, "fun", "Fun Styles");
	SetMenuOptionFlags(styleSelect, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(styleSelect, client, MENU_TIME_FOREVER);
}

public int StyleTypeSelectMenuHandler(Menu styleSelect, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0:
			{
				Menu styleSelect2 = CreateMenu(StyleSelectMenuHandler);
				SetMenuTitle(styleSelect2, "Current Style: %s\n------------------------------\n", g_szInitalStyle[param1]);
				AddMenuItem(styleSelect2, "0", "Normal");
				AddMenuItem(styleSelect2, "1", "Sideways");
				AddMenuItem(styleSelect2, "2", "Half-Sideways");
				AddMenuItem(styleSelect2, "3", "Backwards");
				SetMenuOptionFlags(styleSelect2, MENUFLAG_BUTTON_EXIT);
				DisplayMenu(styleSelect2, param1, MENU_TIME_FOREVER);
			}
			case 1:
			{
				Menu styleSelect2 = CreateMenu(StyleSelectMenuHandler);
				SetMenuTitle(styleSelect2, "Current Style: %s\n------------------------------\n", g_szInitalStyle[param1]);
				AddMenuItem(styleSelect2, "0", "Normal - Ranked");
				AddMenuItem(styleSelect2, "4", "Low-Gravity");
				AddMenuItem(styleSelect2, "5", "Slow Motion");
				AddMenuItem(styleSelect2, "6", "Fast Forward");
				SetMenuOptionFlags(styleSelect2, MENUFLAG_BUTTON_EXIT);
				DisplayMenu(styleSelect2, param1, MENU_TIME_FOREVER);
			}
		}
	}
	else
	{
		if (action == MenuAction_End)
			CloseHandle(styleSelect);
	}
}

public int StyleSelectMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		GetMenuItem(menu, param2, info, sizeof(info));
		if (StrContains(info, "1", false)!= -1)
		{
			g_iCurrentStyle[param1] = 1;
			g_iInitalStyle[param1] = 1;
			Format(g_szInitalStyle[param1], 128, "Sideways");
			Format(g_szStyleHud[param1], 32, "[SW]");
			g_bRankedStyle[param1] = true;
			g_bFunStyle[param1] = false;
		}
		else if (StrContains(info, "2", false)!= -1)
		{
			g_iCurrentStyle[param1] = 2;
			g_iInitalStyle[param1] = 2;
			Format(g_szInitalStyle[param1], 128, "Half-Sideways");
			Format(g_szStyleHud[param1], 32, "[HSW]");
			g_bRankedStyle[param1] = true;
			g_bFunStyle[param1] = false;
		}
		else if (StrContains(info, "3", false)!= -1)
		{
			g_iCurrentStyle[param1] = 3;
			g_iInitalStyle[param1] = 3;
			Format(g_szInitalStyle[param1], 128, "Backwards");
			Format(g_szStyleHud[param1], 32, "[BW]");
			g_bRankedStyle[param1] = true;
			g_bFunStyle[param1] = false;
		}
		else if (StrContains(info, "4", false)!= -1)
		{
			g_iCurrentStyle[param1] = 4;
			g_iInitalStyle[param1] = 4;
			Format(g_szInitalStyle[param1], 128, "Low-Gravity");
			Format(g_szStyleHud[param1], 32, "[LG]");
			SetEntityGravity(param1, 0.5);
			g_bRankedStyle[param1] = false;
			g_bFunStyle[param1] = true;
		}
		else if (StrContains(info, "5", false)!= -1)
		{
			g_iCurrentStyle[param1] = 5;
			g_iInitalStyle[param1] = 5;
			Format(g_szInitalStyle[param1], 128, "Slow Motion");
			Format(g_szStyleHud[param1], 32, "[SM]");
			SetEntPropFloat(param1, Prop_Data, "m_flLaggedMovementValue", 0.5);
			g_bRankedStyle[param1] = false;
			g_bFunStyle[param1] = true;
		}
		else if (StrContains(info, "6", false)!= -1)
		{
			g_iCurrentStyle[param1] = 6;
			g_iInitalStyle[param1] = 6;
			Format(g_szInitalStyle[param1], 128, "Fast Forward");
			Format(g_szStyleHud[param1], 32, "[FF]");
			SetEntPropFloat(param1, Prop_Data, "m_flLaggedMovementValue", 1.5);
			g_bRankedStyle[param1] = false;
			g_bFunStyle[param1] = true;
		}
		else
		{
			g_iCurrentStyle[param1] = 0;
			g_iInitalStyle[param1] = 0;
			Format(g_szInitalStyle[param1], 128, "Normal");
			Format(g_szStyleHud[param1], 32, "");
			g_bRankedStyle[param1] = true;
			g_bFunStyle[param1] = false;
		}

		Command_Restart(param1, 1);
	}
	else
	{
		if (action == MenuAction_Cancel)
			styleSelectMenu(param1);
		if (action == MenuAction_End)
			CloseHandle(menu);
	}
}

// Rate Limiting Commands
public void RateLimit(int client)
{
	float currentTime = GetGameTime();
	if (currentTime - g_fCommandLastUsed[client] < 2)
	{
		CPrintToChat(client, "%t", "Commands46", g_szChatPrefix);
		g_bRateLimit[client] = true;
	}
	else
	{
		g_bRateLimit[client] = false;
	}

	g_fCommandLastUsed[client] = GetGameTime();
}

public Action Command_SelectMapTime(int client, int args)
{
	RateLimit(client);

	if (!g_bRateLimit[client])
	{
		if (args == 0)
		{
			db_selectMapRank(client, g_szSteamID[client], g_szMapName);
			return Plugin_Handled;
		}
		else
		{
			char arg1[128];
			char arg2[128];
			GetCmdArg(1, arg1, sizeof(arg1));
			GetCmdArg(2, arg2, sizeof(arg2));

			// bool bPlayerFound = false;
			char szSteamId2[32];
			char szName[MAX_NAME_LENGTH];

			if (StrContains(arg1[0], "surf_", true) != -1) // if arg1 contains a surf map
			{
				db_selectMapRank(client, g_szSteamID[client], arg1);
				return Plugin_Handled;
			}
			else if (StrContains(arg1, "@", false) != -1) // Rank Number / Group
			{
				int rank;
				ReplaceString(arg1, 128, "@", "", false);
				if (StrContains(arg1, "g", false) != -1) // Group
				{
					ReplaceString(arg1, 128, "g", "", false);
					int group;
					group = StringToInt(arg1);
					if (group == 1)
						rank = g_G1Top;
					else if (group == 2)
						rank = g_G2Top;
					else if (group == 3)
						rank = g_G3Top;
					else if (group == 4)
						rank = g_G4Top;
					else if (group == 5)
						rank = g_G5Top;
				}
				else
					rank = StringToInt(arg1);

				if (!arg2[0])
					db_selectMapRankUnknown(client, g_szMapName, rank);
				else
					db_selectMapRankUnknown(client, arg2, rank);

				return Plugin_Handled;
			}
			else // else it will contain a clients name
			{
				for (int i = 1; i <= MaxClients; i++)
				{
					if (IsValidClient(i))
					{
						GetClientName(i, szName, MAX_NAME_LENGTH);
						StringToUpper(szName);
						StringToUpper(arg1);
						if ((StrContains(szName, arg1) != -1))
						{
							// bPlayerFound = true;
							GetClientAuthId(i, AuthId_Steam2, szSteamId2, MAX_NAME_LENGTH, true);
						}
					}
				}
			}
			if (!arg2[0]) // no 2nd argument
			{
				db_selectMapRank(client, szSteamId2, g_szMapName);
			}
			else
			{
				db_selectMapRank(client, szSteamId2, arg2);
			}
		}
	}

	return Plugin_Handled;
}

public Action Command_SelectBonusTime(int client, int args)
{
	RateLimit(client);

	if (!g_bRateLimit[client])
	{
		if (args == 0)
		{
			if (g_mapZoneGroupCount > 2)
			{
				CReplyToCommand(client, "%t", "Commands74", g_szChatPrefix);
				return Plugin_Handled;
			}
			else if (g_mapZoneGroupCount == 1)
			{
				CReplyToCommand(client, "%t", "NoBonusOnMap", g_szChatPrefix);
				return Plugin_Handled;
			}

			db_selectBonusRank(client, g_szSteamID[client], g_szMapName, 1);
			return Plugin_Handled;
		}
		else
		{
			char arg1[128];
			char arg2[128];
			GetCmdArg(1, arg1, sizeof(arg1));
			GetCmdArg(2, arg2, sizeof(arg2));

			// bool bPlayerFound = false;
			char szSteamId2[32];
			char szName[MAX_NAME_LENGTH];

			/*if (StrContains(arg1[0], "surf_", true) != -1) // if arg1 contains a surf map
			{
				db_selectMapRank(client, g_szSteamID[client], arg1);
				return Plugin_Handled;
			}*/
			if (StrContains(arg1, "#", false) != -1) // bonus number
			{
				ReplaceString(arg1, 128, "#", "", false);
				int bonus = StringToInt(arg1);

				if (!arg2[0]) // no mapname or player name
					db_selectBonusRank(client, g_szSteamID[client], g_szMapName, bonus);
				else
				{
					if (StrContains(arg2, "surf_", false) != -1) // sm_brank #x surf_y
						db_selectBonusRank(client, g_szSteamID[client], arg2, bonus);
					else // sm_brank #x player
					{
						for (int i = 1; i <= MaxClients; i++)
						{
							if (IsValidClient(i))
							{
								GetClientName(i, szName, MAX_NAME_LENGTH);
								StringToUpper(szName);
								StringToUpper(arg2);
								if ((StrContains(szName, arg2) != -1))
								{
									// bPlayerFound = true;
									GetClientAuthId(i, AuthId_Steam2, szSteamId2, MAX_NAME_LENGTH, true);
									break;
								}
							}
						}
						db_selectBonusRank(client, szSteamId2, g_szMapName, bonus);
					}
				}

				return Plugin_Handled;
			}
			else // sm_brank player else it will contain a clients name
			{
				if (g_mapZoneGroupCount > 2)
				{
					CReplyToCommand(client, "%t", "Commands76", g_szChatPrefix);
					return Plugin_Handled;
				}
				else if (g_mapZoneGroupCount == 1)
				{
					CReplyToCommand(client, "%t", "NoBonusOnMap", g_szChatPrefix);
					return Plugin_Handled;
				}

				for (int i = 1; i <= MaxClients; i++)
				{
					if (IsValidClient(i))
					{
						GetClientName(i, szName, MAX_NAME_LENGTH);
						StringToUpper(szName);
						StringToUpper(arg1);
						if ((StrContains(szName, arg1) != -1))
						{
							// bPlayerFound = true;
							GetClientAuthId(i, AuthId_Steam2, szSteamId2, MAX_NAME_LENGTH, true);
							break;
						}
					}
				}
			}
			db_selectBonusRank(client, szSteamId2, g_szMapName, 1);
		}
	}

	return Plugin_Handled;
}

// Show Triggers https://forums.alliedmods.net/showthread.php?t=290356
public Action Command_ToggleTriggers(int client, int args)
{
	if (!IsPlayerVip(client))
		return Plugin_Handled;

	g_bShowTriggers[client] = !g_bShowTriggers[client];

	if (g_bShowTriggers[client]) 
		++g_iTriggerTransmitCount;
	else 
		--g_iTriggerTransmitCount;

	CPrintToChat(client, "%t", "Commands47", g_szChatPrefix);

	TransmitTriggers(g_iTriggerTransmitCount > 0);
	return Plugin_Handled;
}

void TransmitTriggers(bool transmit)
{
	// Hook only once
	static bool s_bHooked = false;

	// Have we done this before?
	if (s_bHooked == transmit)
		return;

	// Loop through entities
	char sBuffer[8];
	int lastEdictInUse = GetEntityCount();
	for (int entity = MaxClients + 1; entity <= lastEdictInUse; ++entity)
	{
		if (!IsValidEdict(entity))
			continue;

		// Is this entity a trigger?
		GetEdictClassname(entity, sBuffer, sizeof(sBuffer));
		if (strcmp(sBuffer, "trigger") != 0)
			continue;

		// Is this entity's model a VBSP model?
		GetEntPropString(entity, Prop_Data, "m_ModelName", sBuffer, 2);
		if (sBuffer[0] != '*') 
		{
			// The entity must have been created by a plugin and assigned some random model.
			// Skipping in order to avoid console spam.
			continue;
		}

		// Get flags
		int effectFlags = GetEntData(entity, g_Offset_m_fEffects);
		int edictFlags = GetEdictFlags(entity);

		// Determine whether to transmit or not
		if (transmit) 
		{
			effectFlags &= ~EF_NODRAW;
			edictFlags &= ~FL_EDICT_DONTSEND;
		} 
		else 
		{
			effectFlags |= EF_NODRAW;
			edictFlags |= FL_EDICT_DONTSEND;
		}

		// Apply state changes
		SetEntData(entity, g_Offset_m_fEffects, effectFlags);
		ChangeEdictState(entity, g_Offset_m_fEffects);
		SetEdictFlags(entity, edictFlags);

		// Should we hook?
		if (transmit)
			SDKHook(entity, SDKHook_SetTransmit, Hook_SetTriggerTransmit);
		else
			SDKUnhook(entity, SDKHook_SetTransmit, Hook_SetTriggerTransmit);
	}
	s_bHooked = transmit;
}

public Action Command_ToggleMapFinish(int client, int args)
{
	if (!g_bToggleMapFinish[client])
	{
		g_bToggleMapFinish[client] = true;
		CPrintToChat(client, "%t", "Commands48", g_szChatPrefix);
	}
	else
	{
		g_bToggleMapFinish[client] = false;
		CPrintToChat(client, "%t", "Commands49", g_szChatPrefix);
	}

	return Plugin_Handled;
}

public Action Command_Repeat(int client, int args)
{
	if (!g_bRepeat[client])
	{
		g_bRepeat[client] = true;
		CPrintToChat(client, "%t", "Commands50", g_szChatPrefix);
	}
	else
	{
		g_bRepeat[client] = false;
		CPrintToChat(client, "%t", "Commands51", g_szChatPrefix);
	}

	return Plugin_Handled;
}

public Action Admin_FixBot(int client, int args)
{
	if (!g_bZoner[client] && !CheckCommandAccess(client, "", ADMFLAG_ROOT))
		return Plugin_Handled;

	CPrintToChat(client, "%t", "Commands52", g_szChatPrefix);
	CreateTimer(5.0, FixBot_Off, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(10.0, FixBot_On, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE);

	return Plugin_Handled;
}

public Action Command_GiveKnife(int client, int args)
{
	if (IsPlayerAlive(client))
	{
		GivePlayerItem(client, "weapon_knife");
	}

	return Plugin_Handled;
}

public Action Command_NoclipSpeed(int client, int args)
{
	if (!IsPlayerZoner(client))
		return Plugin_Handled;

	if (args == 0)
	{
		CPrintToChat(client, "%t", "Commands54", g_szChatPrefix);
		return Plugin_Handled;
	}
	else
	{
		char arg1[128];
		GetCmdArg(1, arg1, sizeof(arg1));
		ServerCommand("sv_noclipspeed %s", arg1);
	}

	return Plugin_Handled;
}

public Action Command_SelectRank(int client, int args)
{
	RateLimit(client);

	if (!g_bRateLimit[client])
	{
		if (args == 0) // Self Rank
		{
			db_selectPlayerRank(client, 0, g_szSteamID[client]);
		}
		else
		{
			char arg1[128];
			GetCmdArg(1, arg1, sizeof(arg1));
			if (StrContains(arg1, "@", false) != -1) // Rank Number
			{
				int arg;
				ReplaceString(arg1, 128, "@", "", false);
				arg = StringToInt(arg1);
				db_selectPlayerRank(client, arg, "none");
			}
			else // Player Name
			{
				bool bPlayerFound = false;
				char szName[128];
				for (int i = 1; i <= MaxClients; i++)
				{
					if (IsValidClient(i))
					{
						GetClientName(i, szName, MAX_NAME_LENGTH);
						StringToUpper(szName);
						StringToUpper(arg1);
						if (StrContains(szName, arg1) != -1)
						{
							char szSteamId[32];
							GetClientAuthId(i, AuthId_Steam2, szSteamId, MAX_NAME_LENGTH, true);
							db_selectPlayerRank(i, 0, szSteamId);
							bPlayerFound = true;
							break;
						}
					}
				}
				if (!bPlayerFound)
					db_selectPlayerRankUnknown(client, arg1);
			}
		}
	}

	return Plugin_Handled;
}

public Action Command_MapImprovement(int client, int args)
{
	g_MiType[client] = 0;
	if (args == 0) // Self Rank
		db_selectMapImprovement(client, g_szMapName);
	else
	{
		char arg1[128];
		GetCmdArg(1, arg1, sizeof(arg1));
		db_selectMapImprovement(client, arg1);
	}

	return Plugin_Handled;
}

public Action Command_SpecBot(int client, int args)
{
	if (IsValidClient(client))
	{
		ChangeClientTeam(client, 1);
		SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", g_RecordBot);
		SetEntProp(client, Prop_Send, "m_iObserverMode", 4);
		g_bWrcpTimeractivated[client] = false;
	}

	return Plugin_Handled;
}

public Action Command_SpecBonusBot(int client, int args)
{
	if (IsValidClient(client))
	{
		ChangeClientTeam(client, 1);
		SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", g_BonusBot);
		SetEntProp(client, Prop_Send, "m_iObserverMode", 4);
		g_bWrcpTimeractivated[client] = false;
	}

	return Plugin_Handled;
}

public Action Command_SelectPlayerPr(int client, int args)
{
	if (args == 0)
	{
		g_iPrTarget[client] = client;
		db_viewPlayerPr(client, g_szSteamID[client], g_szMapName);
	}
	else
	{
		char arg1[128];
		char arg1upper[128];
		GetCmdArg(1, arg1, sizeof(arg1));
		char arg2[256];
		char arg2upper[256];
		GetCmdArg(2, arg2, sizeof(arg2));
		char szSteamId2[32];
		char szName[MAX_NAME_LENGTH];
		g_iPrTarget[client] = client;
		if (StrContains(arg1, "surf_")!= -1)
		{
			if (!arg2[0])
				db_viewPlayerPr(client, g_szSteamID[client], arg1);
			else
			{
				bool playerfound = false;

				for (int i = 1; i <= MaxClients; i++)
				{
					if (IsValidClient(i) && !(IsFakeClient(i)))
					{
						GetClientName(i, szName, MAX_NAME_LENGTH);
						StringToUpper(szName);
						Format(arg2upper, 128, "%s", arg2);
						StringToUpper(arg2upper);
						if ((StrContains(szName, arg2upper) != -1))
						{
							g_iPrTarget[client] = i;
							GetClientAuthId(i, AuthId_Steam2, szSteamId2, MAX_NAME_LENGTH, true);
							db_viewPlayerPr(client, szSteamId2, arg1);
							playerfound = true;
							break;
						}
					}
				}

				if (!playerfound)
					CPrintToChat(client, "%t", "Commands55", g_szChatPrefix, arg2, arg1);
			}
		}
		else
		{
			bool playerfound = false;

			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i) && !(IsFakeClient(i)))
				{
					GetClientName(i, szName, MAX_NAME_LENGTH);
					StringToUpper(szName);
					Format(arg1upper, 128, "%s", arg1);
					StringToUpper(arg1upper);
					if ((StrContains(szName, arg1upper) != -1))
					{
						g_iPrTarget[client] = i;
						GetClientAuthId(i, AuthId_Steam2, szSteamId2, MAX_NAME_LENGTH, true);
						db_viewPlayerPr(client, szSteamId2, g_szMapName);
						playerfound = true;
						break;
					}
				}
			}

			if (!playerfound)
				CPrintToChat(client, "%t", "Commands56", g_szChatPrefix, arg1);
		}
	}

	return Plugin_Handled;
}

public Action Command_ShowZones(int client, int args)
{
	g_bShowZones[client] = !g_bShowZones[client];
	if (g_bShowZones[client])
		CReplyToCommand(client, "%t", "Commands78", g_szChatPrefix);
	else
		CReplyToCommand(client, "%t", "Commands79", g_szChatPrefix);

	return Plugin_Handled;
}

public Action Command_HookZones(int client, int args)
{
	HookZonesMenu(client);
	return Plugin_Handled;
}

public void HookZonesMenu(int client)
{
	if (!IsPlayerZoner(client))
	{
		CPrintToChat(client, "%t", "NoZoneAccess", g_szChatPrefix);
		return;
	}

	if (g_hTriggerMultiple == null)
	{
		CPrintToChat(client, "%t", "Commands86", g_szChatPrefix);
		return;
	}

	if (GetArraySize(g_hTriggerMultiple) < 1)
	{
		CPrintToChat(client, "%t", "Commands58", g_szChatPrefix);
		return;
	}

	DisplayMenu(g_mTriggerMultipleMenu, client, MENU_TIME_FOREVER);
}

public int HookZonesMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			g_iSelectedTrigger[param1] = param2;
			char szTriggerName[128];
			GetMenuItem(menu, param2, szTriggerName, sizeof(szTriggerName));

			Menu menu2 = CreateMenu(HookZoneHandler);
			SetMenuTitle(menu2, szTriggerName);

			char szParam[128];
			IntToString(param2, szParam, sizeof(szParam));
			AddMenuItem(menu2, szParam, "Teleport to zone");
			AddMenuItem(menu2, szParam, "Hook zone");

			SetMenuOptionFlags(menu2, MENUFLAG_BUTTON_EXIT);
			DisplayMenu(menu2, param1, MENU_TIME_FOREVER);
		}
		case MenuAction_Cancel: 
		{
			if (IsValidClient(param1))
				g_iSelectedTrigger[param1] = -1;
		}
	}
}

public int HookZoneHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char szTriggerIndex[128];
			GetMenuItem(menu, param2, szTriggerIndex, sizeof(szTriggerIndex));
			int index = StringToInt(szTriggerIndex);
			g_iSelectedTrigger[param1] = index;
			switch (param2)
			{
				case 0: // teleport
				{
					int iEnt = GetArrayCell(g_hTriggerMultiple, index);
					float position[3];
					float angles[3];
					GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", position);
					GetClientEyeAngles(param1, angles);
					char szTriggerName[128];
					GetEntPropString(iEnt, Prop_Send, "m_iName", szTriggerName, 128, 0);

					CPrintToChat(param1, "%t", "TeleportingTo", g_szChatPrefix, szTriggerName, position[0], position[1], position[2]);

					// teleportEntitySafe(param1, position, angles, view_as<float>( { 0.0, 0.0, -100.0 } ), true);
					Client_Stop(param1, 0);
					TeleportEntity(param1, position, angles, view_as<float>( { 0.0, 0.0, -100.0 } ));
				}
				case 1: // hook zone
				{
					int iEnt = GetArrayCell(g_hTriggerMultiple, index);

					char szTriggerName[128];
					GetEntPropString(iEnt, Prop_Send, "m_iName", szTriggerName, 128, 0);

					char szTitle[256];
					Format(szTitle, 256, "Is %s a map or bonus zone?", szTriggerName);

					Menu menu2 = CreateMenu(HookZoneGroupHandler);
					SetMenuTitle(menu2, szTitle);
					AddMenuItem(menu2, szTriggerIndex, "Map");
					AddMenuItem(menu2, szTriggerIndex, "Bonus");
					SetMenuOptionFlags(menu2, MENUFLAG_BUTTON_EXIT);
					DisplayMenu(menu2, param1, MENU_TIME_FOREVER);
				}
			}
		}
		case MenuAction_Cancel: g_iSelectedTrigger[param1] = -1;
		case MenuAction_End:
		{
			if (IsValidClient(param1))
				g_iSelectedTrigger[param1] = -1;
			delete menu;
		}
	}
}

public int HookZoneGroupHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char szTriggerIndex[128];
			GetMenuItem(menu, param2, szTriggerIndex, sizeof(szTriggerIndex));
			int index = StringToInt(szTriggerIndex);
			g_iSelectedTrigger[param1] = index;

			switch (param2)
			{
				case 0:
				{
					g_iWaitingForResponse[param1] = -1;
					g_iZonegroupHook[param1] = 0;
					int iEnt = GetArrayCell(g_hTriggerMultiple, index);

					char szTriggerName[128];
					GetEntPropString(iEnt, Prop_Send, "m_iName", szTriggerName, 128, 0);

					char szTitle[256];
					Format(szTitle, 256, "Set %s as what zone type?", szTriggerName);

					Menu menu2 = CreateMenu(HookZoneTypeHandler);
					SetMenuTitle(menu2, szTitle);
					AddMenuItem(menu2, szTriggerIndex, "Start Zone");
					AddMenuItem(menu2, szTriggerIndex, "Checkpoint Zone");
					AddMenuItem(menu2, szTriggerIndex, "Stage Zone");
					AddMenuItem(menu2, szTriggerIndex, "End Zone");
					SetMenuOptionFlags(menu2, MENUFLAG_BUTTON_EXIT);
					DisplayMenu(menu2, param1, MENU_TIME_FOREVER);
				}
				case 1:
				{
					g_iWaitingForResponse[param1] = 3;
					CPrintToChat(param1, "%t", "Commands60", g_szChatPrefix);

					int iEnt = GetArrayCell(g_hTriggerMultiple, index);

					char szTriggerName[128];
					GetEntPropString(iEnt, Prop_Send, "m_iName", szTriggerName, 128, 0);

					char szTitle[256];
					Format(szTitle, 256, "Set %s as what zone type?", szTriggerName);

					Menu menu2 = CreateMenu(HookZoneTypeHandler);
					SetMenuTitle(menu2, szTitle);
					AddMenuItem(menu2, szTriggerIndex, "Start Zone");
					AddMenuItem(menu2, szTriggerIndex, "Checkpoint Zone");
					AddMenuItem(menu2, szTriggerIndex, "Stage Zone");
					AddMenuItem(menu2, szTriggerIndex, "End Zone");
					SetMenuOptionFlags(menu2, MENUFLAG_BUTTON_EXIT);
					DisplayMenu(menu2, param1, MENU_TIME_FOREVER);
				}
			}
		}
		case MenuAction_Cancel: g_iSelectedTrigger[param1] = -1;
		case MenuAction_End:
		{
			g_iSelectedTrigger[param1] = -1;
			delete menu;
		}
	}
}

public int HookZoneTypeHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{	
			char szTriggerIndex[128];
			GetMenuItem(menu, param2, szTriggerIndex, sizeof(szTriggerIndex));
			int index = StringToInt(szTriggerIndex);

			int iEnt = GetArrayCell(g_hTriggerMultiple, index);
			char szTriggerName[128];
			GetEntPropString(iEnt, Prop_Send, "m_iName", szTriggerName, 128, 0);


			if (g_iWaitingForResponse[param1] == 3)
			{
				CPrintToChat(param1, "%t", "Commands61", g_szChatPrefix);

				char szTitle[256];
				Format(szTitle, 256, "Set %s as what zone type?", szTriggerName);

				Menu menu2 = CreateMenu(HookZoneTypeHandler);
				SetMenuTitle(menu2, szTitle);
				AddMenuItem(menu2, szTriggerIndex, "Start Zone");
				AddMenuItem(menu2, szTriggerIndex, "Checkpoint Zone");
				AddMenuItem(menu2, szTriggerIndex, "Stage Zone");
				AddMenuItem(menu2, szTriggerIndex, "End Zone");
				SetMenuOptionFlags(menu2, MENUFLAG_BUTTON_EXIT);
				DisplayMenu(menu2, param1, MENU_TIME_FOREVER);
				return;
			}

			float position[3], fMins[3], fMaxs[3];
			GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", position);
			GetEntPropVector(iEnt, Prop_Send, "m_vecMins", fMins);
			GetEntPropVector(iEnt, Prop_Send, "m_vecMaxs", fMaxs);

			for (int j = 0; j < 3; j++)
			{
				fMins[j] = (fMins[j] + position[j]);
			}

			for (int j = 0; j < 3; j++)
			{
				fMaxs[j] = (fMaxs[j] + position[j]);
			}

			switch (param2)
			{
				case 0: // Start Zone
				{
					//public void db_insertZoneHook(int zoneid, int zonetype, int zonetypeid, float pointax, float pointay, float pointaz, float pointbx, float pointby, float pointbz, int vis, int team, int zonegroup, char[] szHookName)
					db_insertZoneHook(g_mapZonesCount, 1, g_mapZonesTypeCount[0][1], 0, 0, g_iZonegroupHook[param1], szTriggerName, fMins, fMaxs);
				}
				case 1: // Checkpoint Zone
				{
					db_insertZoneHook(g_mapZonesCount, 4, g_mapZonesTypeCount[0][4], 0, 0, g_iZonegroupHook[param1], szTriggerName, fMins, fMaxs);
				}
				case 2: // Stage Zone
				{
					db_insertZoneHook(g_mapZonesCount, 3, g_mapZonesTypeCount[0][3], 0, 0, g_iZonegroupHook[param1], szTriggerName, fMins, fMaxs);
				}
				case 3: // End Zone
				{
					db_insertZoneHook(g_mapZonesCount, 2, g_mapZonesTypeCount[0][2], 0, 0, g_iZonegroupHook[param1], szTriggerName, fMins, fMaxs);
				}
			}
		}
		case MenuAction_Cancel: g_iSelectedTrigger[param1] = -1;
		case MenuAction_End:
		{
			g_iSelectedTrigger[param1] = -1;
			delete menu;
		}
	}
}

// Startpos Goose
public Action Command_Startpos(int client, int args)
{
	if (!IsValidClient(client))
		return Plugin_Handled;

	if (g_bTimerEnabled[client])
		Startpos(client);
	else 
		CReplyToCommand(client, "%t", "Commands82", g_szChatPrefix);

	return Plugin_Handled;
}

public Action Command_ResetStartpos(int client, int args)
{
	if (!IsValidClient(client))
		return Plugin_Handled;

	g_bStartposUsed[client][g_iClientInZone[client][2]] = false;
	CReplyToCommand(client, "%t", "Commands83", g_szChatPrefix);

	return Plugin_Handled;
}

public void Startpos(int client)
{
	if (IsPlayerAlive(client) && g_iClientInZone[client][0] == 1 && GetEntityFlags(client) & FL_ONGROUND)
	{
		GetClientAbsOrigin(client, g_fStartposLocation[client][g_iClientInZone[client][2]]);
		GetClientEyeAngles(client, g_fStartposAngle[client][g_iClientInZone[client][2]]);
		g_bStartposUsed[client][g_iClientInZone[client][2]] = true;
		CPrintToChat(client, "%t", "Commands68", g_szChatPrefix);
	}
	else
	{
		CPrintToChat(client, "%t", "Commands69", g_szChatPrefix);
	}
}

public Action Command_Bug(int client, int args)
{
	ReportBugMenu(client);
	return Plugin_Handled;
}

public void ReportBugMenu(int client)
{
	Menu menu = CreateMenu(ReportBugHandler);
	SetMenuTitle(menu, "Choose a bug type");
	AddMenuItem(menu, "Map Bug", "Map Bug");
	AddMenuItem(menu, "SurfTimer Bug", "SurfTimer Bug");
	AddMenuItem(menu, "Server Bug", "Server Bug");
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int ReportBugHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		GetMenuItem(menu, param2, g_sBugType[param1], 32);
		g_iWaitingForResponse[param1] = 1;
		CPrintToChat(param1, "%t", "Commands70", g_szChatPrefix);
	}
	else if (action == MenuAction_End)
		CloseHandle(menu);
}

public Action Command_Calladmin(int client, int args)
{
	g_iWaitingForResponse[client] = 2;
	CPrintToChat(client, "%t", "Commands70", g_szChatPrefix);
	return Plugin_Handled;
}

public Action Command_CPR(int client, int args)
{
	if (!IsValidClient(client))
		return Plugin_Handled;

	if (args == 0)
	{
		if (g_fPersonalRecord[client] < 1.0)
		{
			CReplyToCommand(client, "%t", "Commands84", g_szChatPrefix);
			return Plugin_Handled;
		}
		db_selectCPR(client, 1, g_szMapName, "");
	}
	else
	{
		char arg[128];
		GetCmdArg(1, arg, sizeof(arg));
		if (StrContains(arg, "surf_") != -1)
		{
			db_selectCPR(client, 1, arg, "");
		}
		else if (StrContains(arg, "@") != -1)
		{
			ReplaceString(arg, 128, "@", "");
			char arg2[128];
			int rank = StringToInt(arg);
			GetCmdArg(2, arg2, sizeof(arg2));
			if (!arg2[0])
				db_selectCPR(client, rank, g_szMapName, "");
			else
				db_selectCPR(client, rank, arg2, "");
		}
		else
		{
			char szPlayerName[MAX_NAME_LENGTH];
			bool found = false;
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i) && i != client)
				{
					GetClientName(i, szPlayerName, MAX_NAME_LENGTH);
					StringToUpper(szPlayerName);
					if ((StrContains(szPlayerName, arg) != -1))
					{
						found = true;
						db_selectCPR(client, 0, g_szMapName, g_szSteamID[i]);
						break;
					}
				}
			}
			if (!found)
				CReplyToCommand(client, "%t", "Commands85", g_szChatPrefix);
		}
	}

	return Plugin_Handled;
}

public Action Command_ReloadMap(int client, int args)
{
	ServerCommand("changelevel %s", g_szMapName);
	return Plugin_Handled;
}

public Action Command_PlayRecord(int client, int args)
{
	if (GetConVarBool(g_hPlayReplayVipOnly))
	{
		if (!g_bVip[client])
		{
			CReplyToCommand(client, "%t", "Misc43", g_szChatPrefix);
			return Plugin_Handled;
		}
	}

	PlayRecordMenu(client);
	return Plugin_Handled;
}

public void PlayRecordMenu(int client)
{
	Menu menu = CreateMenu(PlayRecordTypeMenuHandler);
	SetMenuTitle(menu, "Play Record: Select a type");

	// Check for map replay
	if (g_bMapReplay[0])
		AddMenuItem(menu, "", "Map Replay");
	else
		AddMenuItem(menu, "", "Map Replay", ITEMDRAW_DISABLED);

	// Check for bonus replay
	for (int i = 1; i < MAXZONEGROUPS; i++)
	{
		if (g_bMapBonusReplay[i][0])
		{
			AddMenuItem(menu, "", "Bonus Replay");
			break;
		}

		if (i == MAXZONEGROUPS - 1)
			AddMenuItem(menu, "", "Bonus Replay", ITEMDRAW_DISABLED);
	}

	// Check for stage replay
	if (g_TotalStages > 0)
	{
		for (int i = 1; i <= g_TotalStages; i++)
		{
			if (g_bStageReplay[i])
			{
				AddMenuItem(menu, "", "Stage Replay");
				break;
			}
			
			if (i == g_TotalStages)
				AddMenuItem(menu, "", "Stage Replay", ITEMDRAW_DISABLED);
		}
	}
	else
		AddMenuItem(menu, "", "Stage Replay", ITEMDRAW_DISABLED);

	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int PlayRecordTypeMenuHandler(Handle menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		if (g_bManualReplayPlayback && g_bManualBonusReplayPlayback)
		{
			switch (param2)
			{
				case 1: CPrintToChat(param1, "%t", "BotInUse", g_szChatPrefix, "Bonus");
				case 2: CPrintToChat(param1, "%t", "BotInUse", g_szChatPrefix, "Stage");
				default: CPrintToChat(param1, "%t", "BotInUse", g_szChatPrefix, "Map");
			}
		}
		else
			ChooseReplayMenu(param1, param2);
	}
	else if (action == MenuAction_End)
		delete menu;
}

public void ChooseReplayMenu(int client, int type)
{
	Menu menu = CreateMenu(PlayRecordMenuHandler);
	char szTitle[128], szItem[128], szBuffer[128];
	if (type == 0)
	{
		Format(szTitle, sizeof(szTitle), "Play Record: Map Replay");
		AddMenuItem(menu, "map", "Map Replay");
 		for (int i = 1; i < MAX_STYLES; i++)
		{
			if (g_bMapReplay[i])
			{
				Format(szItem, sizeof(szItem), "Map - %s", g_szStyleMenuPrint[i]);
				Format(szBuffer, sizeof(szBuffer), "map-style-%d", i);
				AddMenuItem(menu, szBuffer, szItem);
			}
		}
	}
	else if (type == 1)
	{
		Format(szTitle, sizeof(szTitle), "Play Record: Bonus Replay");
		for (int i = 1; i < g_mapZoneGroupCount; i++)
		{
			if (g_bMapBonusReplay[i][0])
			{
				Format(szItem, sizeof(szItem), "Bonus %d", i);
				Format(szBuffer, sizeof(szBuffer), "bonus-%d", i);
				AddMenuItem(menu, szBuffer, szItem);
			}
		}

		for (int i = 1; i < g_mapZoneGroupCount; i++)
		{
			for (int j = 1; j < MAX_STYLES; j++)
			{
				if (g_bMapBonusReplay[i][j])
				{
					Format(szItem, sizeof(szItem), "Bonus %d - %s", i, g_szStyleMenuPrint[j]);
					Format(szBuffer, sizeof(szBuffer), "bonus-%d-style-%d", i, j);
					AddMenuItem(menu, szBuffer, szItem);
				}
			}
		}
	}
	else if (type == 2)
	{
		Format(szTitle, sizeof(szTitle), "Play Record: Stage Replay");
		for (int i = 1; i <= g_TotalStages; i++)
		{
			if (g_bStageReplay[i])
			{
				Format(szItem, sizeof(szItem), "Stage %d Replay", i);
				Format(szBuffer, sizeof(szBuffer), "stage-%d", i);
				AddMenuItem(menu, szBuffer, szItem);
			}
		}
	}

	SetMenuTitle(menu, szTitle);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int PlayRecordMenuHandler(Handle menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char szBuffer[128];
		GetMenuItem(menu, param2, szBuffer, sizeof(szBuffer));

		int bot;
		bool bSpec = true;
		// Did the client select a map replay?
		if ((StrContains(szBuffer, "map", false)) != -1)
		{
			if (g_bManualReplayPlayback)
			{
				bSpec = false;
				CPrintToChat(param1, "%t", "BotInUse", g_szChatPrefix, "Map");
			}
			else
			{
				g_iSelectedReplayType = 0;
				bot = g_RecordBot;

				// Check for style replay
				if ((StrContains(szBuffer, "style", false)) != -1)
				{
					g_iManualReplayCount = 0;
					g_bManualReplayPlayback = true;
					char szBuffer2[2][128];
					ExplodeString(szBuffer, "style-", szBuffer2, 2, sizeof(szBuffer2));
					int style = StringToInt(szBuffer2[1]);
					g_iSelectedReplayStyle = style;
					PlayRecord(bot, 0, style);
				}
				else
				{
					g_bManualReplayPlayback = true;
					g_iManualReplayCount = 99;
					g_iSelectedReplayStyle = 0;
					PlayRecord(bot, 0, 0);
				}
			}
		}
		else if ((StrContains(szBuffer, "bonus", false)) != -1)
		{
			if (g_bManualBonusReplayPlayback)
			{
				bSpec = false;
				CPrintToChat(param1, "%t", "BotInUse", g_szChatPrefix, "Bonus");
			}
			else
			{
				g_iSelectedReplayType = 1;
				bot = g_BonusBot;
				int bonus;

				// Check which bonus
				char szBuffer2[2][128];
				ExplodeString(szBuffer, "bonus-", szBuffer2, 2, sizeof(szBuffer2));
				bonus = StringToInt(szBuffer2[1]);
				// Check for style replay
				if ((StrContains(szBuffer, "style", false)) != -1)
				{
					g_iManualBonusReplayCount = 0;
					g_bManualBonusReplayPlayback = true;
					ExplodeString(szBuffer, "style-", szBuffer2, 2, 128);
					int style = StringToInt(szBuffer2[1]);
					g_iSelectedBonusReplayStyle = style;
					g_iCurrentBonusReplayIndex = 99;
					g_iManualBonusToReplay = bonus;
					PlayRecord(bot, bonus, style);
				}
				else
				{
					g_bManualBonusReplayPlayback = true;
					g_iManualBonusReplayCount = 99;
					g_iSelectedBonusReplayStyle = 0;
					g_iCurrentBonusReplayIndex = 99;
					g_iManualBonusToReplay = bonus;
					PlayRecord(bot, bonus, 0);
				}
			}
		}
		else if ((StrContains(szBuffer, "stage", false)) != -1)
		{
			if (g_bManualStageReplayPlayback)
			{
				bSpec = false;
				CPrintToChat(param1, "%t", "BotInUse", g_szChatPrefix, "Stage");
			}
			else
			{
				g_iSelectedReplayType = 2;
				bot = g_WrcpBot;
				int stage;

				// Check which stage
				char szBuffer2[2][128];
				ExplodeString(szBuffer, "stage-", szBuffer2, 2, 128);
				stage = StringToInt(szBuffer2[1]);

				g_bManualStageReplayPlayback = true;
				g_iManualStageReplayCount = 0;
				g_iSelectedReplayStage = stage;
				PlayRecord(bot, -stage, 0);
			}
		}
		if (bSpec)
		{
			// Delay the switch to spec so the client sees the new bot name
			Handle pack;
			CreateDataTimer(0.2, SpecBot, pack);
			WritePackCell(pack, GetClientUserId(param1));
			WritePackCell(pack, bot);
		}
	}
	else if (action == MenuAction_Cancel)
		PlayRecordMenu(param1);
	else if (action == MenuAction_End)
		delete menu;
}
