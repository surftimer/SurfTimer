/*=======================================================
=            	CS:GO Surftimer		       					        *
This is a heavy modification of ckSurf by fluffys
The original version of this timer was by jonitaikaponi
* https://forums.alliedmods.net/showthread.php?t=264498 =
=======================================================*/

/*=============================================
=            		Includes		          				=
=============================================*/

#include <sourcemod>
#include <sdkhooks>
#include <adminmenu>
#include <cstrike>
#include <smlib>
#include <geoip>
#include <basecomm>
#include <colors>
#undef REQUIRE_EXTENSIONS
#include <clientprefs>
#undef REQUIRE_PLUGIN
#include <dhooks>
#include <mapchooser>
#include <sdktools>
#include <store>
#include <discord>
#include <sourcecomms>
#include <surftimer>


/*====================================
=            Declarations            =
====================================*/

/*============================================
=           	 Definitions 		         =
=============================================*/

// Require new syntax and semicolons
#pragma newdecls required
#pragma semicolon 1

// Plugin info
#define VERSION "2.0.1"
#define PLUGIN_VERSION 201

// Database definitions
#define MYSQL 0
#define SQLITE 1
#define PERCENT 0x25
#define QUOTE 0x22

// Chat colors
#define WHITE 0x01
#define DARKRED 0x02
#define PURPLE 0x03
#define GREEN 0x04
#define MOSSGREEN 0x05
#define LIMEGREEN 0x06
#define RED 0x07
#define ORANGE 0x10
#define GRAY 0x08
#define YELLOW 0x09
#define DARKGREY 0x0A
#define BLUE 0x0B
#define DARKBLUE 0x0C
#define LIGHTBLUE 0x0D
#define PINK 0x0E
#define LIGHTRED 0x0F

// Paths
#define CK_REPLAY_PATH "data/replays/"
#define BLOCKED_LIST_PATH "configs/surftimer/hidden_chat_commands.txt"
#define MULTI_SERVER_MAPCYCLE "configs/surftimer/multi_server_mapcycle.txt"
#define CUSTOM_TITLE_PATH "configs/surftimer/custom_chat_titles.txt"
#define SKILLGROUP_PATH "configs/surftimer/skillgroups.cfg"
#define PRO_FULL_SOUND_PATH "sound/quake/holyshit.mp3"
#define PRO_RELATIVE_SOUND_PATH "*quake/holyshit.mp3"
#define CP_FULL_SOUND_PATH "sound/quake/wickedsick.mp3"
#define CP_RELATIVE_SOUND_PATH "*quake/wickedsick.mp3"
#define UNSTOPPABLE_SOUND_PATH "sound/quake/unstoppable.mp3"
#define UNSTOPPABLE_RELATIVE_SOUND_PATH "*quake/unstoppable.mp3"

//fluffys
#define WR_FULL_SOUND_PATH "sound/surftimer/wr/1/valve_logo_music.mp3"
#define WR_RELATIVE_SOUND_PATH "*surftimer/wr/1/valve_logo_music.mp3"
#define WR2_FULL_SOUND_PATH "sound/surftimer/wr/2/valve_logo_music.mp3"
#define WR2_RELATIVE_SOUND_PATH "*surftimer/wr/2/valve_logo_music.mp3"
#define TOP10_FULL_SOUND_PATH "sound/surftimer/top10/valve_logo_music.mp3"
#define TOP10_RELATIVE_SOUND_PATH "*surftimer/top10/valve_logo_music.mp3"
#define PR_FULL_SOUND_PATH "sound/surftimer/pr/valve_logo_music.mp3"
#define PR_RELATIVE_SOUND_PATH "*surftimer/pr/valve_logo_music.mp3"
#define WRCP_FULL_SOUND_PATH "sound/surftimer/wow_fast.mp3"
#define WRCP_RELATIVE_SOUND_PATH "*surftimer/wow_fast.mp3"
#define DISCOTIME_FULL_SOUND_PATH "sound/surftimer/discotime.mp3"
#define DISCOTIME_RELATIVE_SOUND_PATH "*/surftimer/discotime.mp3"
#define MAX_STYLES 7

#define VOTE_NO "###no###"
#define VOTE_YES "###yes###"

// Checkpoint definitions
#define CPLIMIT 37			// Maximum amount of checkpoints in a map

// Zone definitions
#define ZONE_MODEL "models/props/de_train/barrel.mdl"
//fluffys zoneamount
#define ZONEAMOUNT 12		// The amount of different type of zones	-	Types: Start(1), End(2), Stage(3), Checkpoint(4), Speed(5), TeleToStart(6), Validator(7), Chekcer(8), Stop(0), AntiJump(9), AntiDuck(10), MaxSpeed(11)
#define MAXZONEGROUPS 12	// Maximum amount of zonegroups in a map
#define MAXZONES 128		// Maximum amount of zones in a map

// Ranking definitions
#define MAX_PR_PLAYERS 1066
#define MAX_SKILLGROUPS 64

// UI definitions
#define HIDE_RADAR (1 << 12)
#define HIDE_CHAT ( 1<<7 )
#define HIDE_CROSSHAIR 1<<8

// Replay definitions
#define BM_MAGIC 0xBAADF00D
#define BINARY_FORMAT_VERSION 0x01
#define ADDITIONAL_FIELD_TELEPORTED_ORIGIN (1<<0)
#define ADDITIONAL_FIELD_TELEPORTED_ANGLES (1<<1)
#define ADDITIONAL_FIELD_TELEPORTED_VELOCITY (1<<2)
#define FRAME_INFO_SIZE 15
#define AT_SIZE 10
#define ORIGIN_SNAPSHOT_INTERVAL 500
#define FILE_HEADER_LENGTH 74

// Show Triggers
#define EF_NODRAW 32

// New Save Locs
#define MAX_LOCS 1024

/*====================================
=            Enumerations            =
====================================*/

enum UserJumps
{
	LastJumpTimes[4],
}

enum FrameInfo
{
	playerButtons = 0,
	playerImpulse,
	Float:actualVelocity[3],
	Float:predictedVelocity[3],
	Float:predictedAngles[2],
	CSWeaponID:newWeapon,
	playerSubtype,
	playerSeed,
	additionalFields,
	pause,
}

enum AdditionalTeleport
{
	Float:atOrigin[3],
	Float:atAngles[3],
	Float:atVelocity[3],
	atFlags
}

enum FileHeader
{
	FH_binaryFormatVersion = 0,
	String:FH_Time[32],
	String:FH_Playername[32],
	FH_Checkpoints,
	FH_tickCount,
	Float:FH_initialPosition[3],
	Float:FH_initialAngles[3],
	Handle:FH_frames
}

enum MapZone
{
	zoneId,  				// ID within the map
	zoneType,  				// Types: Start(1), End(2), Stage(3), Checkpoint(4), Speed(5), TeleToStart(6), Validator(7), Chekcer(8), Stop(0)
	zoneTypeId, 			// ID of the same type eg. Start-1, Start-2, Start-3...
	Float:PointA[3],
	Float:PointB[3],
	Float:CenterPoint[3],
	String:zoneName[128],
	String:hookName[128],
	String:targetName[128],
	oneJumpLimit,
	zoneGroup,
	Vis,
	Team
}

enum SkillGroup
{
	PointReq,				// Points required for next skillgroup
	NameColor,				// Color to use for name if colored chatnames is turned on
	String:RankName[32],	// Skillgroup name without colors
	String:RankNameColored[32], // Skillgroup name with colors
}


/*===================================
=            Plugin Info            =
===================================*/

public Plugin myinfo =
{
	name = "Surftimer",
	author = "fluffys",
	description = "fork of cksurf",
	version = VERSION,
	url = "http://steamcommunity.com/profiles/76561198000303868/"
};

/*=================================
=            Variables            =
=================================*/

// Testing Variables
float g_fTick[MAXPLAYERS + 1][2];
float g_fServerLoading[2];
float g_fClientsLoading[MAXPLAYERS + 1][2];
char g_szLogFile[PLATFORM_MAX_PATH];

// pr command
int g_iPrTarget[MAXPLAYERS + 1];
int g_totalStagesPr[MAXPLAYERS + 1];
int g_totalBonusesPr[MAXPLAYERS + 1];

// speed gradient
char g_szSpeedColour[MAXPLAYERS + 1];

// show zones
bool g_bShowZones[MAXPLAYERS + 1];

/*----------  Stages  ----------*/
int g_Stage[MAXZONEGROUPS][MAXPLAYERS + 1];						// Which stage is the client in
bool g_bhasStages; 												// Does the map have stages

/*----------  Spawn locations  ----------*/
float g_fSpawnLocation[MAXZONEGROUPS][CPLIMIT][3];						// Spawn coordinates
float g_fSpawnAngle[MAXZONEGROUPS][CPLIMIT][3];							// Spawn angle
float g_fSpawnVelocity[MAXZONEGROUPS][CPLIMIT][3];						// Spawn velocity
bool g_bGotSpawnLocation[MAXZONEGROUPS][CPLIMIT]; 						// Does zonegroup have a spawn location

/*----------  Bonus variables  ----------*/
char g_szBonusFastest[MAXZONEGROUPS][MAX_NAME_LENGTH]; 			// Name of the #1 in the current maps bonus
char g_szBonusFastestTime[MAXZONEGROUPS][64]; 					// Fastest bonus time in 00:00:00:00 format
float g_fPersonalRecordBonus[MAXZONEGROUPS][MAXPLAYERS + 1]; 	// Clients personal bonus record in the current map
char g_szPersonalRecordBonus[MAXZONEGROUPS][MAXPLAYERS + 1][64]; // Personal bonus record in 00:00:00 format
float g_fBonusFastest[MAXZONEGROUPS]; 							// Fastest bonus time in the current map
float g_fOldBonusRecordTime[MAXZONEGROUPS];						// Old record time, for prints + counting
int g_MapRankBonus[MAXZONEGROUPS][MAXPLAYERS + 1];				// Clients personal bonus rank in the current map
int g_OldMapRankBonus[MAXZONEGROUPS][MAXPLAYERS + 1];			// Old rank in bonus
int g_bMissedBonusBest[MAXPLAYERS + 1]; 						// Has the client mbissed his best bonus time
int g_tmpBonusCount[MAXZONEGROUPS];								// Used to make sure bonus finished prints are correct
int g_iBonusCount[MAXZONEGROUPS]; 								// Amount of players that have passed the bonus in current map
int g_totalBonusCount; 											// How many total bonuses there are
bool g_bhasBonus;												// Does map have a bonus?

/*----------  Checkpoint variables  ----------*/
float g_fCheckpointTimesRecord[MAXZONEGROUPS][MAXPLAYERS + 1][CPLIMIT]; // Clients best run's times
float g_fCheckpointTimesNew[MAXZONEGROUPS][MAXPLAYERS + 1][CPLIMIT]; // Clients current run's times
float g_fCheckpointServerRecord[MAXZONEGROUPS][CPLIMIT]; 		// Server record checkpoint times
char g_szLastSRDifference[MAXPLAYERS + 1][64]; 					// Last difference to the server record checkpoint
char g_szLastPBDifference[MAXPLAYERS + 1][64]; 					// Last difference to clients own record checkpoint
float g_fLastDifferenceTime[MAXPLAYERS + 1]; 					// The time difference was shown, used to show for a few seconds in timer panel
float tmpDiff[MAXPLAYERS + 1]; 									// Used to calculate time gain / lost
int lastCheckpoint[MAXZONEGROUPS][MAXPLAYERS + 1]; 				// Used to track which checkpoint was last reached
bool g_bCheckpointsFound[MAXZONEGROUPS][MAXPLAYERS + 1]; 		// Clients checkpoints have been found?
bool g_bCheckpointRecordFound[MAXZONEGROUPS];					// Map record checkpoints found?
float g_fMaxPercCompleted[MAXPLAYERS + 1]; 						// The biggest % amount the player has reached in current map
int g_iCurrentCheckpoint[MAXPLAYERS + 1];

/*----------  Advert variables  ----------*/
int g_Advert; 													// Defines which advert to play

/*----------  Maptier Variables  ----------*/
char g_sTierString[MAXZONEGROUPS][512];							// The string for each zonegroup
bool g_bTierEntryFound;											// Tier data found?
bool g_bTierFound[MAXZONEGROUPS];								// Tier data found in ZGrp
Handle AnnounceTimer[MAXPLAYERS + 1];							// Tier announce timer

/*----------  Zone Variables  ----------*/
// Client
bool g_bIgnoreZone[MAXPLAYERS + 1]; 							// Ignore end zone end touch if teleporting from inside a zone
int g_iClientInZone[MAXPLAYERS + 1][4];							// Which zone the client is in 0 = ZoneType, 1 = ZoneTypeId, 2 = ZoneGroup, 3 = ZoneID
// Zone Counts & Data
int g_mapZonesTypeCount[MAXZONEGROUPS][ZONEAMOUNT];				// Zone type count in each zoneGroup
char g_szZoneGroupName[MAXZONEGROUPS][128];						// Zone group's name
int g_mapZones[MAXZONES][MapZone];								// Map Zone array
int g_mapZonesCount;											// The total amount of zones in the map
int g_mapZoneCountinGroup[MAXZONEGROUPS];						// Map zone count in zonegroups
int g_mapZoneGroupCount;										// Zone group cound
float g_fZoneCorners[MAXZONES][8][3];							// Additional zone corners, can't store multi dimensional arrays in enums..

/*----------  AntiJump & AntiDuck Variables  ----------*/
bool g_bInDuck[MAXPLAYERS + 1] = false;
bool g_bInJump[MAXPLAYERS + 1] = false;
bool g_bInPushTrigger[MAXPLAYERS + 1] = false;
bool g_bJumpZoneTimer[MAXPLAYERS + 1] = false;
bool g_bInStartZone[MAXPLAYERS + 1] = false;
bool g_bInStageZone[MAXPLAYERS + 1];

/*----------  MaxSpeed Variables  ----------*/
bool g_bInMaxSpeed[MAXPLAYERS + 1];

/*----------  Bhop Limiter  ----------*/
int g_userJumps[MAXPLAYERS][UserJumps];

/*----------  VIP Variables  ----------*/
int g_iVipLvl[MAXPLAYERS + 1];
bool g_bZoner[MAXPLAYERS + 1];

/*----------  Custom Titles  ----------*/
char g_szCustomTitleColoured[MAXPLAYERS + 1][1024];
char g_szCustomTitle[MAXPLAYERS + 1][1024];
bool g_bDbCustomTitleInUse[MAXPLAYERS + 1] = false;
bool g_bdbHasCustomTitle[MAXPLAYERS + 1] = false;
int g_iCustomColours[MAXPLAYERS + 1][2]; // 0 = name, 1 = text;
//int g_idbCustomTextColour[MAXPLAYERS + 1] = 0;
bool g_bHasCustomTextColour[MAXPLAYERS + 1] = false;
bool g_bCustomTitleAccess[MAXPLAYERS + 1] = false;
bool g_bUpdatingColours[MAXPLAYERS + 1];
//char g_szsText[MAXPLAYERS + 1];

/*----------  Profile Menu  ----------*/
int g_BonusRecordCount[MAXPLAYERS + 1];
int g_totalBonusTimes[MAXPLAYERS + 1];
//Handle g_FinishedMapsMenu;
int g_StageRecordCount[MAXPLAYERS + 1]; //to be used with sm_p, stage sr
int g_totalStageTimes[MAXPLAYERS +1];
//fluffys total bonus
int g_pr_BonusCount;
int g_totalMapsCompleted[MAXPLAYERS + 1];
int g_mapsCompletedLoop[MAXPLAYERS + 1];
int g_uncMapsCompleted[MAXPLAYERS + 1];
Handle g_CompletedMenu;

/*----------  WRCP Variables  ----------*/
int g_pr_StageCount;
float g_fWrcpRecord[MAXPLAYERS + 1][CPLIMIT][MAX_STYLES]; // Clients best WRCP times
bool g_bWrcpTimeractivated[MAXPLAYERS + 1] = false;
bool g_bWrcpEndZone[MAXPLAYERS + 1] = false;
int g_CurrentStage[MAXPLAYERS + 1];
float g_fStartWrcpTime[MAXPLAYERS + 1];
float g_fFinalWrcpTime[MAXPLAYERS + 1];
char g_szFinalWrcpTime[MAXPLAYERS + 1][32];	// Total time the run took in 00:00:00 format
float g_fCurrentWrcpRunTime[MAXPLAYERS + 1];
int g_StageRank[MAXPLAYERS + 1][CPLIMIT];
float g_fStageRecord[CPLIMIT];
char g_szRecordStageTime[CPLIMIT];
//char g_szRecordStagePlayer[CPLIMIT]; //will be used, need to fix query
//char g_szRecordStageSteamID[CPLIMIT]; // will be used, neex to fix query
int g_TotalStageRecords[CPLIMIT];
int g_TotalStages;
float g_fWrcpMenuLastQuery[MAXPLAYERS + 1] = 1.0;
bool g_bSelectWrcp[MAXPLAYERS + 1];
//char g_StageSelect[MAXPLAYERS + 1]; //can't remember what this was for, keeping just in case
char g_szWrcpMapSelect[MAXPLAYERS + 1][128];
bool g_bStageSRVRecord[MAXPLAYERS + 1][CPLIMIT];
char g_szStageRecordPlayer[CPLIMIT][MAX_NAME_LENGTH];
//.bool g_bFirstStageRecord[CPLIMIT];

/*----------  Map Settings variables ----------*/
float g_fStartPreSpeed;
float g_fBonusPreSpeed;
//ConVar g_hStagePreSpeed[36] = null; 								// Stage zone speed cap
float g_fStagePreSpeed[36];
float g_fMaxVelocity;
ConVar g_hMaxVelocity;
float g_fAnnounceRecord;
bool g_bGravityFix;
ConVar g_hGravityFix;
int g_iMapSettingType[MAXPLAYERS + 1];

/*----------  Style variables
0 = normal, 1 = SW, 2 = HSW, 3 = BW, 4 = Low-Gravity, 5 = Slow Motion, 6 = Fast Forward
----------*/
int g_iCurrentStyle[MAXPLAYERS + 1];
int g_iInitalStyle[MAXPLAYERS + 1];
char g_szInitalStyle[MAXPLAYERS + 1][256];
char g_szStyleHud[MAXPLAYERS + 1][32];
bool g_bRankedStyle[MAXPLAYERS + 1];
bool g_bFunStyle[MAXPLAYERS + 1];
int g_KeyCount[MAXPLAYERS + 1] = 0;

//map styles
int g_StyleMapRank[MAX_STYLES][MAXPLAYERS + 1];
int g_OldStyleMapRank[MAX_STYLES][MAXPLAYERS + 1];
float g_fPersonalStyleRecord[MAX_STYLES][MAXPLAYERS + 1];
char g_szPersonalStyleRecord[MAX_STYLES][MAXPLAYERS + 1];
float g_fRecordStyleMapTime[MAX_STYLES];
char g_szRecordStyleMapTime[MAX_STYLES][64];
char g_szRecordStylePlayer[MAX_STYLES][MAX_NAME_LENGTH];
char g_szRecordStyleMapSteamID[MAX_STYLES][MAX_NAME_LENGTH];
int g_StyleMapTimesCount[MAX_STYLES];
bool g_bStyleMapFirstRecord[MAX_STYLES][MAXPLAYERS + 1];
bool g_bStyleMapPBRecord[MAX_STYLES][MAXPLAYERS + 1];
bool g_bStyleMapSRVRecord[MAX_STYLES][MAXPLAYERS + 1];

//bonus styles
char g_szStyleBonusFastest[MAX_STYLES][MAXZONEGROUPS][MAX_NAME_LENGTH];
char g_szStyleBonusFastestTime[MAX_STYLES][MAXZONEGROUPS][64];
float g_fStylePersonalRecordBonus[MAX_STYLES][MAXZONEGROUPS][MAXPLAYERS + 1];
char g_szStylePersonalRecordBonus[MAX_STYLES][MAXZONEGROUPS][MAXPLAYERS + 1][64];
float g_fStyleBonusFastest[MAX_STYLES][MAXZONEGROUPS];
float g_fStyleOldBonusRecordTime[MAX_STYLES][MAXZONEGROUPS];
int g_StyleMapRankBonus[MAX_STYLES][MAXZONEGROUPS][MAXPLAYERS + 1];
int g_StyleOldMapRankBonus[MAX_STYLES][MAXZONEGROUPS][MAXPLAYERS + 1];
int g_StyletmpBonusCount[MAX_STYLES][MAXZONEGROUPS];
int g_iStyleBonusCount[MAX_STYLES][MAXZONEGROUPS];

//wrcp styles
float g_fStyleStageRecord[MAX_STYLES][CPLIMIT];
int g_StyleStageRank[MAX_STYLES][MAXPLAYERS + 1][CPLIMIT];
int g_TotalStageStyleRecords[MAX_STYLES][CPLIMIT];
char g_szStyleStageRecordPlayer[MAX_STYLES][MAX_NAME_LENGTH][CPLIMIT];
char g_szStyleRecordStageTime[MAX_STYLES][CPLIMIT];
int g_StyleStageSelect[MAXPLAYERS + 1];

//style Profiles
int g_ProfileStyleSelect[MAXPLAYERS + 1];
int g_totalStyleMapTimes[MAXPLAYERS + 1];

/*---------- Player Settings  ----------*/
bool g_bTimerEnabled[MAXPLAYERS + 1];
int g_SpeedGradient[MAXPLAYERS + 1];
int g_SpeedMode[MAXPLAYERS + 1];
bool g_bCenterSpeedDisplay[MAXPLAYERS + 1];
int g_iCenterSpeedEnt[MAXPLAYERS + 1];
int g_iSettingToLoad[MAXPLAYERS + 1];
//Handle g_hServerTier;
// gain/loss speed colour in centre hud
int g_iPreviousSpeed[MAXPLAYERS + 1];

/*----------  Sounds  ----------*/
bool g_bTop10Time[MAXPLAYERS + 1] = false;

//rate limiting commands
float g_fCommandLastUsed[MAXPLAYERS + 1];
bool g_bRateLimit[MAXPLAYERS + 1];

// mrank command
char g_szRuntimepro[MAXPLAYERS + 1][32];
int g_totalPlayerTimes[MAXPLAYERS + 1];

// rank command
int g_rankArg[MAXPLAYERS + 1];

/* --------- ksf style ranking distribution ---------*/
char g_szRankName[MAXPLAYERS + 1][32];
int g_rankNameChatColour[MAXPLAYERS + 1];
int g_GroupMaps[MAX_PR_PLAYERS + 1];
int g_Top10Maps[MAX_PR_PLAYERS + 1];
int g_WRs[MAX_PR_PLAYERS + 1][3]; // 0 = wr, 1 = wrb, 2 = wrcp 
int g_Points[MAX_PR_PLAYERS + 1][7]; // 0 = Map Points, 1 = Bonus Points, 2 = Group Points, 3 = Map WR Points, 4 = Bonus WR Points, 5 = Top 10 Points
int g_ClientProfile[MAXPLAYERS + 1];
bool g_bProfileInServer[MAXPLAYERS + 1];
bool g_bInBonus[MAXPLAYERS + 1];
int g_iInBonus[MAXPLAYERS + 1];

/* --------- ksf points system ---------*/
float g_Group1Pc = 0.03125;
float g_Group2Pc = 0.0625;
float g_Group3Pc = 0.125;
float g_Group4Pc = 0.25;
float g_Group5Pc = 0.5;
char g_szMiMapName[MAXPLAYERS + 1][128];
int g_MiType[MAXPLAYERS + 1];
int g_G1Top;
int g_G2Bot;
int g_G2Top;
int g_G3Bot;
int g_G3Top;
int g_G4Bot;
int g_G4Top;
int g_G5Bot;
int g_G5Top;
bool g_bInsertNewTime = false;

/*----------  fluffys tmf & repeat  ----------*/
bool g_bToggleMapFinish[MAXPLAYERS + 1] = true;
bool g_bRepeat[MAXPLAYERS + 1] = false;
bool g_bNotTeleporting[MAXPLAYERS + 1] = true;

// Client Side autobhop
Handle g_hAutoBhop = INVALID_HANDLE;
Handle g_hEnableBhop = INVALID_HANDLE;

/*----------  Flag Varibles  ----------*/
//ConVar g_hCustomTitlesFlag = null;
//int g_CustomTitlesFlag;
//bool g_bCustomTitlesFlag;

// UNIX times
int g_iPlayTimeAlive[MAXPLAYERS + 1];
int g_iPlayTimeSpec[MAXPLAYERS + 1];
int g_iPlayTimeAliveSession[MAXPLAYERS + 1];
int g_iPlayTimeSpecSession[MAXPLAYERS + 1];
int g_iTotalConnections[MAXPLAYERS + 1];

Menu g_mTriggerMultipleMenu = null;

// Editing zones
bool g_bEditZoneType[MAXPLAYERS + 1];							// If editing zone type
char g_CurrentZoneName[MAXPLAYERS + 1][64];						// Selected zone's name
float g_Positions[MAXPLAYERS + 1][2][3];						// Selected zone's position
float g_fBonusStartPos[MAXPLAYERS + 1][2][3];					// Bonus start zone position
float g_fBonusEndPos[MAXPLAYERS + 1][2][3];						// Bonus end zone positions
float g_AvaliableScales[5] =  { 1.0, 5.0, 10.0, 50.0, 100.0 };	// Scaling options
int g_CurrentSelectedZoneGroup[MAXPLAYERS + 1];					// Currently selected zonegroup
int g_CurrentZoneTeam[MAXPLAYERS + 1];							// Current zone team TODO: Remove
int g_CurrentZoneVis[MAXPLAYERS + 1];							// Current zone visibility per team TODO: Remove
int g_CurrentZoneType[MAXPLAYERS + 1];							// Currenyly selected zone's type
int g_Editing[MAXPLAYERS + 1];									// What state of editing is happening eg. editing, creating etc.
int g_ClientSelectedZone[MAXPLAYERS + 1] =  { -1, ... };		// Currently selected zone id
int g_ClientSelectedScale[MAXPLAYERS + 1];						// Currently selected scale
int g_ClientSelectedPoint[MAXPLAYERS + 1];						// Currently selected point
int g_CurrentZoneTypeId[MAXPLAYERS + 1];						// Currently selected zone's type ID
bool g_ClientRenamingZone[MAXPLAYERS + 1];						// Is client renaming zone?
int beamColorT[] =  { 255, 0, 0, 255 };							// Zone team colors TODO: remove
int beamColorCT[] =  { 0, 0, 255, 255 };
int beamColorN[] =  { 255, 255, 0, 255 };
int beamColorM[] =  { 0, 255, 0, 255 };
char g_szZoneDefaultNames[ZONEAMOUNT][128] =  { "Stop", "Start", "End", "Stage", "Checkpoint", "SpeedStart", "TeleToStart", "Validator", "Checker", "AntiJump", "AntiDuck", "MaxSpeed" }; // Default zone names //fluffys
int g_BeamSprite;												// Zone sprites
int g_HaloSprite;

/*----------  PushFix by Mev, George & Blacky  ----------*/
/*----------  https://forums.alliedmods.net/showthread.php?t=267131  ----------*/
ConVar g_hTriggerPushFixEnable;
bool g_bPushing[MAXPLAYERS + 1];

/*----------  Slope Boost Fix by Mev & Blacky  ----------*/
/*----------  https://forums.alliedmods.net/showthread.php?t=266888  ----------*/
float g_vCurrent[MAXPLAYERS + 1][3];
float g_vLast[MAXPLAYERS + 1][3];
bool g_bOnGround[MAXPLAYERS + 1];
bool g_bLastOnGround[MAXPLAYERS + 1];
bool g_bFixingRamp[MAXPLAYERS + 1];
ConVar g_hSlopeFixEnable;

/*----------  Forwards  ----------*/
Handle g_MapFinishForward;
Handle g_BonusFinishForward;
Handle g_PracticeFinishForward;

/*----------  CVars  ----------*/
// Zones
int g_ZoneMenuFlag;
ConVar g_hZoneMenuFlag = null;
ConVar g_hZoneDisplayType = null;								 // How zones are displayed (lower edge, full)
ConVar g_hZonesToDisplay = null; 								// Which zones are displayed
ConVar g_hChecker; 												// Zone refresh rate
Handle g_hZoneTimer = INVALID_HANDLE;
//Zone Colors
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
ConVar g_hCommandToEnd; 										// !end Enable / Disable
ConVar g_hWelcomeMsg = null;
ConVar g_hReplayBotPlayerModel = null;
ConVar g_hReplayBotArmModel = null; 							// Replay bot arm model
ConVar g_hPlayerModel = null; 									// Player models
ConVar g_hArmModel = null; 										// Player arm models
ConVar g_hcvarRestore = null; 									// Restore player's runs?
ConVar g_hNoClipS = null; 										// Allow noclip?
ConVar g_hReplayBot = null; 									// Replay bot?
ConVar g_hWrcpBot = null;
ConVar g_hBackupReplays = null;									// Back up replay bots?
ConVar g_hReplaceReplayTime = null;								// Replace replay times, even if not SR
ConVar g_hTeleToStartWhenSettingsLoaded = null;
bool g_bMapReplay; // Why two bools?
ConVar g_hBonusBot = null; 										// Bonus bot?
bool g_bMapBonusReplay[MAXZONEGROUPS];
ConVar g_hColoredNames = null; 									// Colored names in chat?
ConVar g_hPauseServerside = null; 								// Allow !pause?
ConVar g_hAutoBhopConVar = null; 								// Allow autobhop?
bool g_bAutoBhop;
ConVar g_hDynamicTimelimit = null; 								// Dynamic timelimit?
ConVar g_hAdminClantag = null;									// Admin clan tag?
ConVar g_hConnectMsg = null; 									// Connect message?
ConVar g_hDisconnectMsg = null; 								// Disconnect message?
ConVar g_hRadioCommands = null; 								// Allow radio commands?
ConVar g_hInfoBot = null; 										// Info bot?
ConVar g_hAttackSpamProtection = null; 							// Throttle shooting?
int g_AttackCounter[MAXPLAYERS + 1]; 							// Used to calculate player shots
ConVar g_hGoToServer = null; 									// Allow !goto?
ConVar g_hAllowRoundEndCvar = null; 							// Allow round ending?
bool g_bRoundEnd; // Why two bools?
ConVar g_hPlayerSkinChange = null; 								// Allow changing player models?
ConVar g_hCountry = null; 										// Display countries for players?
ConVar g_hAutoRespawn = null; 									// Respawn players automatically?
ConVar g_hCvarNoBlock = null; 									// Allow player blocking?
ConVar g_hPointSystem = null; 									// Use the point system?
ConVar g_hCleanWeapons = null; 									// Clean weapons from ground?
int g_ownerOffset; 												// Used to clear weapons from ground
ConVar g_hCvarGodMode = null;									// Enable god mode?
//ConVar g_hAutoTimer = null;
ConVar g_hMapEnd = null; 										// Allow map ending?
ConVar g_hAutohealing_Hp = null; 								// Automatically heal lost HP?
// Bot Colors & effects:
ConVar g_hReplayBotColor = null; 								// Replay bot color
int g_ReplayBotColor[3];
ConVar g_hBonusBotColor = null; 								// Bonus bot color
int g_BonusBotColor[3];
ConVar g_hDoubleRestartCommand;									// Double !r restart
ConVar g_hStartPreSpeed = null; 								// Start zone speed cap
ConVar g_hSpeedPreSpeed = null; 								// Speed Start zone speed cap
ConVar g_hBonusPreSpeed = null; 								// Bonus zone speed cap
ConVar g_hSoundEnabled = null; 									// Enable timer start sound
ConVar g_hSoundPath = null;										// Define start sound
//char sSoundPath[64];
ConVar g_hSpawnToStartZone = null; 								// Teleport on spawn to start zone
ConVar g_hAnnounceRank = null; 									// Min rank to announce in chat
ConVar g_hForceCT = null; 										// Force players CT
ConVar g_hChatSpamFilter = null; 								// Chat spam limiter
float g_fLastChatMessage[MAXPLAYERS + 1]; 						// Last message time
int g_messages[MAXPLAYERS + 1]; 								// Spam message count
ConVar g_henableChatProcessing = null; 							// Is chat processing enabled
ConVar g_hMultiServerMapcycle = null;							// Use multi server mapcycle
ConVar g_hDBMapcycle = null;									// use maps from ck_maptier as the servers mapcycle
ConVar g_hPrestigeRank = null;								// Rank to limit the server
ConVar g_hServerType = null;									// Set server to surf or bhop mode
ConVar g_hOneJumpLimit = null;								// Only allows players to jump once inside a start or stage zone
ConVar g_hServerID = null; // Sets the servers id for cross-server announcements
ConVar g_hRecordAnnounce = null; // Enable/Disable cross-server announcements
ConVar g_hRecordAnnounceDiscord = null; // Web hook link to announce records to discord
ConVar g_hReportBugsDiscord = null; // Web hook link to report bugs to discord
ConVar g_hCalladminDiscord = null; // Web hook link to allow players to call admin to discord
ConVar g_hSidewaysBlockKeys = null;

/*----------  SQL Variables  ----------*/
Handle g_hDb = null; 											// SQL driver
int g_DbType; 													// Database type
bool g_bInTransactionChain = false; 							// Used to check if SQL changes are being made
int g_failedTransactions[7]; 									// Used to track failed transactions when making database changes
bool g_bRenaming = false; 										// Used to track if sql tables are being renamed
bool g_bSettingsLoaded[MAXPLAYERS + 1]; 						// Used to track if a players settings have been loaded
bool g_bLoadingSettings[MAXPLAYERS + 1]; 						// Used to track if players settings are being loaded
bool g_bServerDataLoaded; 										// Are the servers settings loaded
char g_szRecordMapSteamID[MAX_NAME_LENGTH]; 					// SteamdID of #1 player in map, used to fetch checkpoint times
int g_iServerHibernationValue;
/*----------  User Commands  ----------*/
float g_flastClientUsp[MAXPLAYERS + 1]; 						// Throttle !usp command
float g_fLastCommandBack[MAXPLAYERS + 1];						// Throttle !back to prevent desync on record bots
bool g_bNoClip[MAXPLAYERS + 1]; 								// Client is noclipping

/*----------  User Options  ----------*/
// org variables track the original setting status, on disconnect, check if changed, if so, update new settings to database
bool g_bLoadedModules[MAXPLAYERS + 1];				// bool to ensure the modules have loaded before resetting 
bool g_bHideChat[MAXPLAYERS + 1];								// Hides chat
bool g_bViewModel[MAXPLAYERS + 1]; 								// Hides viewmodel
bool g_bCheckpointsEnabled[MAXPLAYERS + 1]; 					// Command to disable checkpoints
bool g_bActivateCheckpointsOnStart[MAXPLAYERS + 1]; 			// Did client enable checkpoints? Then start using them again on the next run
bool g_bEnableQuakeSounds[MAXPLAYERS + 1]; 						// Enable quake sounds?
bool g_bHide[MAXPLAYERS + 1]; 									// Hide other players?
bool g_bShowSpecs[MAXPLAYERS + 1];								// Show spectator list?
bool g_bAutoBhopClient[MAXPLAYERS + 1]; 						// Use auto bhop?
// centre hud new
bool g_bCentreHud[MAXPLAYERS + 1];
int g_iCentreHudModule[MAXPLAYERS + 1][6];

// side hud new
bool g_bSpecListOnly[MAXPLAYERS + 1];
bool g_bSideHud[MAXPLAYERS + 1];
int g_iSideHudModule[MAXPLAYERS + 1][5];

/*----------  Run Variables  ----------*/
float g_fPersonalRecord[MAXPLAYERS + 1];						// Clients personal record in map
bool g_bTimeractivated[MAXPLAYERS + 1]; 						// Is clients timer running
bool g_bValidRun[MAXPLAYERS + 1];								// Used to check if a clients run is valid in validator and checker zones
bool g_bBonusFirstRecord[MAXPLAYERS + 1];						// First bonus time in map?
bool g_bBonusPBRecord[MAXPLAYERS + 1];							// Personal best time in bonus
bool g_bBonusSRVRecord[MAXPLAYERS + 1];							// New server record in bonus
char g_szBonusTimeDifference[MAXPLAYERS + 1];					// How many seconds were improved / lost in that run
float g_fStartTime[MAXPLAYERS + 1]; 							// Time when run was started
float g_fFinalTime[MAXPLAYERS + 1]; 							// Total time the run took
char g_szFinalTime[MAXPLAYERS + 1][32]; 						// Total time the run took in 00:00:00 format
float g_fPauseTime[MAXPLAYERS + 1]; 							// Time spent in !pause this run
float g_fStartPauseTime[MAXPLAYERS + 1]; 						// Time when !pause started
float g_fCurrentRunTime[MAXPLAYERS + 1]; 						// Current runtime
bool g_bMissedMapBest[MAXPLAYERS + 1]; 							// Missed personal record time?
bool g_bMapFirstRecord[MAXPLAYERS + 1];							// Was players run his first time finishing the map?
bool g_bMapPBRecord[MAXPLAYERS + 1];							// Was players run his personal best?
bool g_bMapSRVRecord[MAXPLAYERS + 1];							// Was players run the new server record?
char g_szTimeDifference[MAXPLAYERS + 1][32]; 					// Used to print the client's new times difference to record
float g_fRecordMapTime; 										// Record map time in seconds
char g_szRecordMapTime[64]; 									// Record map time in 00:00:00 format
char g_szPersonalRecord[MAXPLAYERS + 1][64]; 					// Client's peronal record in 00:00:00 format
float g_favg_maptime; 											// Average map time
float g_fAvg_BonusTime[MAXZONEGROUPS]; 							// Average bonus times TODO: Combine with g_favg_maptime
bool g_bFirstTimerStart[MAXPLAYERS + 1];						// If timer is started for the first time, print avg times
bool g_bPause[MAXPLAYERS + 1]; 									// Client has timer paused
int g_MapTimesCount; 											// How many times the map has been beaten
int g_MapRank[MAXPLAYERS + 1]; 									// Clients rank in current map
int g_OldMapRank[MAXPLAYERS + 1];								// Clients old rank
char g_szRecordPlayer[MAX_NAME_LENGTH];							// Current map's record player's name

/*----------  Replay Variables  ----------*/
bool g_bNewRecordBot; 											// Checks if the bot is new, if so, set weapon
bool g_bNewBonusBot; 											// Checks if the bot is new, if so, set weapon
Handle g_hTeleport = null; 										// Used to track teleportations
Handle g_hRecording[MAXPLAYERS + 1]; 							// Client is beign recorded
Handle g_hLoadedRecordsAdditionalTeleport = null;
Handle g_hRecordingAdditionalTeleport[MAXPLAYERS + 1];
Handle g_hBotMimicsRecord[MAXPLAYERS + 1] =  { null, ... }; 	// Is mimicing a record
Handle g_hBotTrail[2] = { null, null };							// Timer to refresh bot trails
float g_fInitialPosition[MAXPLAYERS + 1][3]; 					// Replay start position
float g_fInitialAngles[MAXPLAYERS + 1][3]; 						// Replay start angle
bool g_bValidTeleportCall[MAXPLAYERS + 1]; 						// Is teleport valid?
bool g_bNewReplay[MAXPLAYERS + 1]; 								// Don't allow starting a new run if saving a record run
bool g_bNewBonus[MAXPLAYERS + 1]; 								// Don't allow starting a new run if saving a record run
bool g_createAdditionalTeleport[MAXPLAYERS + 1];
int g_BotMimicRecordTickCount[MAXPLAYERS + 1] =  { 0, ... };
int g_BotActiveWeapon[MAXPLAYERS + 1] =  { -1, ... };
int g_CurrentAdditionalTeleportIndex[MAXPLAYERS + 1];
int g_RecordedTicks[MAXPLAYERS + 1];
int g_RecordPreviousWeapon[MAXPLAYERS + 1];
int g_OriginSnapshotInterval[MAXPLAYERS + 1];
int g_BotMimicTick[MAXPLAYERS + 1] =  { 0, ... };
int g_RecordBot = -1; 											// Record bot client ID
int g_BonusBot = -1; 											// Bonus bot client ID
int g_InfoBot = -1; 											// Info bot client ID
int g_WrcpBot = -1;												// WRCP bot client ID
bool g_bReplayAtEnd[MAXPLAYERS + 1]; 							// Replay is at the end
float g_fReplayRestarted[MAXPLAYERS + 1]; 						// Make replay stand still for long enough for trail to die
char g_szReplayName[128]; 										// Replay bot name
char g_szReplayTime[128]; 										// Replay bot time
char g_szBonusName[128]; 										// Replay bot name
char g_szBonusTime[128]; 										// Replay bot time
char g_szWrcpReplayName[CPLIMIT][128];
char g_szWrcpReplayTime[CPLIMIT][128];
int g_BonusBotCount;
int g_iCurrentBonusReplayIndex;
int g_iBonusToReplay[MAXZONEGROUPS + 1];
float g_fReplayTimes[MAXZONEGROUPS];

/*----------  Misc  ----------*/
Handle g_MapList = null; 										// Used to load the mapcycle
float g_fMapStartTime; 											// Used to check if a player just joined the server
Handle g_hSkillGroups = null;									// Array that holds SkillGroup objects in it
// Use !r twice to restart the run
float g_fErrorMessage[MAXPLAYERS + 1]; 							// Used to limit error message spam too often
float g_fClientRestarting[MAXPLAYERS + 1]; 						// Used to track the time the player took to write the second !r, if too long, reset the boolean
bool g_bClientRestarting[MAXPLAYERS + 1]; 						// Client wanted to restart run
float g_fLastTimeNoClipUsed[MAXPLAYERS + 1]; 					// Last time the client used noclip
bool g_bRespawnPosition[MAXPLAYERS + 1]; 						// Does client have a respawn location in memory?
float g_fLastSpeed[MAXPLAYERS + 1]; 							// Client's last speed, used in panels
bool g_bLateLoaded = false; 									// Was plugin loaded late?
bool g_bMapChooser; 											// Known mapchooser loaded? Used to update info bot
bool g_bClientOwnReason[MAXPLAYERS + 1]; 						// If call admin, ignore chat message
bool g_bNoClipUsed[MAXPLAYERS + 1]; 							// Has client used noclip to gain current speed
bool g_bOverlay[MAXPLAYERS + 1];								// Map finished overlay
bool g_bSpectate[MAXPLAYERS + 1]; 								// Is client spectating
bool g_bFirstTeamJoin[MAXPLAYERS + 1];							// First time client joined game, show start messages & start timers
bool g_bFirstSpawn[MAXPLAYERS + 1]; 							// First time client spawned
bool g_bSelectProfile[MAXPLAYERS + 1];
bool g_specToStage[MAXPLAYERS + 1]; 							// Is client teleporting from spectate?
float g_fTeleLocation[MAXPLAYERS + 1][3];						// Location where client is spawned from spectate
int g_ragdolls = -1; 											// Used to clear ragdolls from ground
int g_Server_Tickrate; 											// Server tickrate
int g_SpecTarget[MAXPLAYERS + 1];								// Who the client is spectating?
int g_LastButton[MAXPLAYERS + 1];								// Buttons the client is using, used to show them when specating
int g_MVPStars[MAXPLAYERS + 1]; 								// The amount of MVP's a client has  TODO: make sure this is used everywhere
int g_PlayerChatRank[MAXPLAYERS + 1]; 							// What color is client's name in chat (based on rank)
char g_pr_chat_coloredrank[MAXPLAYERS + 1][256]; 				// Clients rank, colored, used in chat
char g_pr_rankname[MAXPLAYERS + 1][32]; 						// Client's rank, non-colored, used in clantag
char g_szMapPrefix[2][32]; 										// Map's prefix, used to execute prefix cfg's
char g_szMapName[128]; 											// Current map's name
char g_szPlayerPanelText[MAXPLAYERS + 1][512];					// Info panel text when spectating
char g_szCountry[MAXPLAYERS + 1][100];							// Country codes
char g_szCountryCode[MAXPLAYERS + 1][16];						// Country codes
char g_szSteamID[MAXPLAYERS + 1][32];							// Client's steamID
char g_BlockedChatText[256][256];								// Blocked chat commands
float g_fLastOverlay[MAXPLAYERS + 1];							// Last time an overlay was displayed


/*----------  Player location restoring  ----------*/
bool g_bPositionRestored[MAXPLAYERS + 1]; 						// Clients location was restored this run
bool g_bRestorePositionMsg[MAXPLAYERS + 1]; 					// Show client restore message?
bool g_bRestorePosition[MAXPLAYERS + 1]; 						// Clients position is being restored
float g_fPlayerCordsLastPosition[MAXPLAYERS + 1][3]; 			// Client's last location, used on recovering run and coming back from spectate
float g_fPlayerLastTime[MAXPLAYERS + 1]; 						// Client's last time, used on recovering run and coming back from spec
float g_fPlayerAnglesLastPosition[MAXPLAYERS + 1][3]; 			// Client's last angles, used on recovering run and coming back from spec
float g_fPlayerCordsRestore[MAXPLAYERS + 1][3]; 				// Used in restoring players location
float g_fPlayerAnglesRestore[MAXPLAYERS + 1][3]; 				// Used in restoring players angle

/*----------  Menus  ----------*/
Menu g_menuTopSurfersMenu[MAXPLAYERS + 1] = null;
float g_fProfileMenuLastQuery[MAXPLAYERS + 1]; 					// Last time profile was queried by player, spam protection
int g_MenuLevel[MAXPLAYERS + 1];								// Tracking menu level
char g_pr_szrank[MAXPLAYERS + 1][512];							// Client's rank string displayed in !profile
char g_szProfileName[MAXPLAYERS + 1][MAX_NAME_LENGTH];			// !Profile name
char g_szProfileSteamId[MAXPLAYERS + 1][32];
// Admin
int g_AdminMenuFlag; 											// Admin flag required for !ckadmin
ConVar g_hAdminMenuFlag = null;
Handle g_hAdminMenu = null; 									// Add !ckadmin to !admin
int g_AdminMenuLastPage[MAXPLAYERS + 1]; 						// Weird admin menu trickery TODO: wtf

/*----------  Player Points  ----------*/
float g_pr_finishedmaps_perc[MAX_PR_PLAYERS + 1]; 				// % of maps the client has finished
bool g_pr_RankingRecalc_InProgress; 							// Is point recalculation in progress?
bool g_pr_Calculating[MAXPLAYERS + 1]; 							// Clients points are being calculated
bool g_bProfileRecalc[MAX_PR_PLAYERS + 1]; 						// Has this profile been recalculated?
bool g_bManualRecalc; 											// Point recalculation type
bool g_pr_showmsg[MAXPLAYERS + 1]; 								// Print the amount of gained points to chat?
bool g_bRecalcRankInProgess[MAXPLAYERS + 1]; 					// Is clients points being recalculated?
int g_pr_Recalc_ClientID = 0;									// Client ID being recalculated
int g_pr_Recalc_AdminID = -1;									// ClientID that started the recalculation
int g_pr_AllPlayers; 											// Ranked player count on server
int g_pr_RankedPlayers; 										// Player count with points
int g_pr_MapCount;												// Total map count in mapcycle
int g_pr_TableRowCount; 										// The amount of clients that get recalculated in a full recalculation
int g_pr_points[MAX_PR_PLAYERS + 1]; 							// Clients points
int g_pr_oldpoints[MAX_PR_PLAYERS + 1];							// Clients points before recalculation
int g_pr_finishedmaps[MAX_PR_PLAYERS + 1]; 						// How many maps a client has finished
int g_pr_finishedbonuses[MAX_PR_PLAYERS + 1];					// How many bonuses a client has finished
int g_pr_finishedstages[MAX_PR_PLAYERS + 1];					// How many stages a client has finished
int g_PlayerRank[MAXPLAYERS + 1]; 								// Players server rank
int g_MapRecordCount[MAXPLAYERS + 1];							// SR's the client has
char g_pr_szName[MAX_PR_PLAYERS + 1][64];						// Used to update client's name in database
char g_pr_szSteamID[MAX_PR_PLAYERS + 1][32];					// steamid of client being recalculated

/*----------  Practice Mode  ----------*/
// float g_fCheckpointVelocity_undo[MAXPLAYERS + 1][3]; 			// Velocity at checkpoint that is on !undo
// float g_fCheckpointVelocity[MAXPLAYERS + 1][3]; 				// Current checkpoints velocity
// float g_fCheckpointLocation[MAXPLAYERS + 1][3]; 				// Current checkpoint location
// float g_fCheckpointLocation_undo[MAXPLAYERS + 1][3]; 			// Undo checkpoints location
// float g_fCheckpointAngle[MAXPLAYERS + 1][3]; 					// Current checkpoints angle
// float g_fCheckpointAngle_undo[MAXPLAYERS + 1][3];				// Undo checkpoints angle
// float g_fLastPlayerCheckpoint[MAXPLAYERS + 1]; 					// Don't overwrite checkpoint if spamming !cp
bool g_bCreatedTeleport[MAXPLAYERS + 1];						// Client has created atleast one checkpoint
bool g_bPracticeMode[MAXPLAYERS + 1]; 							// Client is in the practice mode

/*----------  Store Server IP   ----------*/
//char jakeeyIP[16];

/*----------  Reports  ----------*/
bool g_bReportSuccess[MAXPLAYERS + 1];
//char g_sServerInfo[3][32]; // We can store more info later if we need 2

// old challenge variables might need just incase
float g_fSpawnPosition[MAXPLAYERS + 1][3];

// old title variables might need just incase
bool g_bTrailOn[MAXPLAYERS + 1];
// Chat Colors in String Format
char szWHITE[12], szDARKRED[12], szPURPLE[12], szGREEN[12], szMOSSGREEN[12], szLIMEGREEN[12], szRED[12], szGRAY[12], szYELLOW[12], szDARKGREY[12], szBLUE[12], szDARKBLUE[12], szLIGHTBLUE[12], szPINK[12], szLIGHTRED[12], szORANGE[12];

// hook zones
Handle g_hTriggerMultiple;
int g_iTeleportingZoneId[MAXPLAYERS + 1];
int g_iZonegroupHook[MAXPLAYERS + 1];
bool g_bWaitingForZonegroup[MAXPLAYERS + 1];
int g_iSelectedTrigger[MAXPLAYERS + 1];

// Store
int g_iMapTier;
Handle g_hStore;

// Late Load Linux fix
Handle g_cvar_sv_hibernate_when_empty = INVALID_HANDLE;

// Fix prehopping in zones
bool g_bJumpedInZone[MAXPLAYERS + 1];
float g_fJumpedInZoneTime[MAXPLAYERS + 1];
bool g_bResetOneJump[MAXPLAYERS + 1];

// VIP Varibles
bool g_bCheckCustomTitle[MAXPLAYERS + 1];
bool g_bEnableJoinMsgs;
char g_szCustomJoinMsg[MAXPLAYERS + 1][256];
//char g_szCustomSounds[MAXPLAYERS + 1][3][256]; // 1 = PB Sound, 2 = Top 10 Sound, 3 = WR sound

// Stage replays
int g_StageRecStartFrame[MAXPLAYERS+1];	// Number of frames where the replay started being recorded
int g_StageRecStartAT[MAXPLAYERS+1];	// Ammount of additional teleport when the replay started being recorded
float g_fStageInitialPosition[MAXPLAYERS + 1][3]; 					// Replay start position
float g_fStageInitialAngles[MAXPLAYERS + 1][3]; 						// Replay start angle
bool g_bSavingWrcpReplay[MAXPLAYERS + 1];
int g_StageReplayCurrentStage;
int g_StageReplaysLoop;
bool g_bStageReplay[CPLIMIT];
bool g_bFirstStageReplay;
float g_fStageReplayTimes[CPLIMIT];

// Server Announcements
int g_iServerID;
int g_iLastID;
bool g_bHasLatestID;

// Comms Vote Menu
int g_iCommsVoteCaller;
int g_iCommsVoteType[MAXPLAYERS + 1];
int g_iCommsVoteTarget[MAXPLAYERS + 1];

// Show Triggers https://forums.alliedmods.net/showthread.php?t=290356
int g_iTriggerTransmitCount;
bool g_bShowTriggers[MAXPLAYERS + 1];
int g_Offset_m_fEffects = -1;

/*--------- !startpos Goose-----------*/
float g_fStartposLocation[MAXPLAYERS + 1][MAXZONES][3];
float g_fStartposAngle[MAXPLAYERS + 1][MAXZONES][3];
bool g_bStartposUsed[MAXPLAYERS + 1][MAXZONES];

// Strafe Sync (Taken from shavit's bhop timer)
int g_iGoodGains[MAXPLAYERS + 1];
int g_iTotalMeasures[MAXPLAYERS + 1];
float g_fAngleCache[MAXPLAYERS + 1];

// Save locs
int g_iSaveLocCount;
float g_fSaveLocCoords[MAX_LOCS][3]; // [loc id][coords]
float g_fSaveLocAngle[MAX_LOCS][3]; // [loc id][angle]
float g_fSaveLocVel[MAX_LOCS][3]; // [loc id][velocity]
char g_szSaveLocTargetname[MAX_LOCS][128]; // [loc id]
char g_szSaveLocClientName[MAX_LOCS][MAX_NAME_LENGTH];
int g_iLastSaveLocIdClient[MAXPLAYERS + 1];
float g_fLastCheckpointMade[MAXPLAYERS + 1];
int g_iSaveLocUnix[MAX_LOCS]; // [loc id]

char g_sServerName[256];
ConVar g_hHostName = null;

// discord bugtracker
char g_sBugType[MAXPLAYERS + 1][32];
bool g_bWaitingForBugMsg[MAXPLAYERS + 1];
char g_sBugMsg[MAXPLAYERS + 1][256];

// discord calladmin
bool g_bWaitingForCAMsg[MAXPLAYERS + 1];

// Teleport Destinations
Handle g_hDestinations;

// CPR command
float g_fClientCPs[MAXPLAYERS + 1][36];
float g_fTargetTime[MAXPLAYERS + 1];
char g_szTargetCPR[MAXPLAYERS + 1][MAX_NAME_LENGTH];
char g_szCPRMapName[MAXPLAYERS + 1][128];
//float g_fTargetCPs[MAXPLAYERS + 1][35];

// surf_christmas2
bool g_bUsingStageTeleport[MAXPLAYERS + 1];

// Footsteps
ConVar g_hFootsteps = null;

/*=========================================
=            Predefined arrays            =
=========================================*/

char g_sz10000mvGradient[][] =
{
	"#FFFFFF",
	"#F4FFF4",
	"#E9FFE9",
	"#DFFFDF",
	"#D4FFD4",
	"#C9FFC9",
	"#BFFFBF",
	"#B4FFB4",
	"#AAFFAA",
	"#9FFF9F",
	"#94FF94",
	"#8AFF8A",
	"#7FFF7F",
	"#74FF74",
	"#74FF74",
	"#5FFF5F",
	"#55FF55",
	"#4AFF4A",
	"#3FFF3F",
	"#35FF35",
	"#2AFF2A",
	"#1FFF1F",
	"#15FF15",
	"#0AFF0A",
	"#00FF00"
};

char g_sz3500mvGradient[][] =
{
	"#FFFFFF",
	"#F7FFF7",
	"#F0FFF0",
	"#E8FFE8",
	"#E1FFE1",
	"#D9FFD9",
	"#D2FFD2",
	"#CAFFCA",
	"#C3FFC3",
	"#BBFFBB",
	"#B4FFB4",
	"#ACFFAC",
	"#A5FFA5",
	"#9DFF9D",
	"#96FF96",
	"#8EFF8E",
	"#87FF87",
	"#7FFF7F",
	"#78FF78",
	"#70FF70",
	"#69FF69",
	"#61FF61",
	"#5AFF5A",
	"#52FF52",
	"#4BFF4B",
	"#43FF43",
	"#3CFF3C",
	"#34FF34",
	"#2DFF2D",
	"#25FF25",
	"#1EFF1E",
	"#16FF16",
	"#0FFF0F",
	"#07FF07",
	"#00FF00"
};

char g_szRainbowGradient[][] =
{
	"#FFFFFF",
	"#FFD4F0",
	"#e2aaff",
	"#e38be6",
	"#7f7fff",
	"#55c6ff",
	"#2affb8",
	"#00ff00"
};

char UnallowedTitles[][] =
{
	"NEWBIE",
	"LEARNING",
	"NOVICE",
	"BEGINNER",
	"ROOKIE",
	"AVERAGE",
	"CASUAL",
	"ADVANCED",
	"SKILLED",
	"EXCEPTIONAL",
	"AMAZING",
	"PRO",
	"VETERAN",
	"EXPERT",
	"ELITE",
	"MASTER",
	"LEGENDARY",
	"GODLY",
	"KING",
	"ADMIN",
	"ADMLN",
	"HEAD ADMIN",
	"HEADADMIN",
	"MODERATOR",
	"M0DERATOR",
	"M0DERAT0R",
	"MODERAT0R",
	"OWNER",
	"0WNER",
	"ZTS",
	"MOD",
	"M0D",
	"CKSURF",
	"STAFF",
	"BIGDICKCLUB",
	"BIG DICK CLUB",
	"BIGDICK CLUB",
	"BIG DICKCLUB",
	"B DC",
	"BD C",
	"B D C",
	"VIP",
	"SUPER VIP"
};

char g_szStyleFinishPrint[][] =
{
	"",
	"*sideways*",
	"*half-sideways*",
	"*backwards*",
	"*low-gravity*",
	"*slow motion*",
	"*fast forwards*"
};

char g_szStyleRecordPrint[][] =
{
	"",
	"*SIDEWAYS*",
	"*HALF-SIDEWAYS*",
	"*BACKWARDS*",
	"*LOW GRAVITY*",
	"*SLOW MOTION*",
	"*FAST FORWARD*"
};

char g_szStyleMenuPrint[][] =
{
	"",
	"Sideways",
	"Half-Sideways",
	"Backwards",
	"Low-Gravity",
	"Slow Motion",
	"Fast Forward"
};

char EntityList[][] =  // Disable entities that often break maps
{
	"logic_timer",
	"team_round_timer",
	"logic_relay",
};

char RadioCMDS[][] =  // Disable radio commands
{
	"coverme", "takepoint", "holdpos", "regroup", "followme", "takingfire", "go", "fallback", "sticktog",
	"getinpos", "stormfront", "report", "roger", "enemyspot", "needbackup", "sectorclear", "inposition",
	"reportingin", "getout", "negative", "enemydown", "cheer", "thanks", "nice", "compliment"
};

/*=====  End of Declarations  ======*/




/*================================
=            Includes            =
================================*/

#include "surftimer/misc.sp"
#include "surftimer/admin.sp"
#include "surftimer/commands.sp"
#include "surftimer/hooks.sp"
#include "surftimer/buttonpress.sp"
#include "surftimer/sql.sp"
#include "surftimer/sql2.sp"
#include "surftimer/sqltime.sp"
#include "surftimer/timer.sp"
#include "surftimer/replay.sp"
#include "surftimer/surfzones.sp"
#include "surftimer/mapsettings.sp"
#include "surftimer/cvote.sp"
#include "surftimer/vip.sp"



/*==============================
=            Events            =
==============================*/

public void OnLibraryAdded(const char[] name)
{
	Handle tmp = FindPluginByFile("mapchooser_extended.smx");
	if ((StrEqual("mapchooser", name)) || (tmp != null && GetPluginStatus(tmp) == Plugin_Running))
		g_bMapChooser = true;
	if (tmp != null)
		CloseHandle(tmp);

	//botmimic 2
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
				OnClientPutInServer(i);
		}
	}
}

public void OnPluginEnd()
{
	//remove clan tags
	for (int x = 1; x <= MaxClients; x++)
	{
		if (IsValidClient(x))
		{
			SetEntPropEnt(x, Prop_Send, "m_bSpotted", 1);
			SetEntProp(x, Prop_Send, "m_iHideHUD", 0);
			SetEntProp(x, Prop_Send, "m_iAccount", 1);
			CS_SetClientClanTag(x, "");
			OnClientDisconnect(x);
		}
	}


	//set server convars back to default
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

public void OnEntityCreated(int entity, const char[] classname)
{
	// if (StrContains(classname, "trigger_", true) != -1 || StrContains(classname, "_door")!= -1)
	// {
	// 	SDKHook(entity, SDKHook_StartTouch, OnTouchAllTriggers);
	// 	SDKHook(entity, SDKHook_Touch, OnTouchAllTriggers);
	// 	SDKHook(entity, SDKHook_EndTouch, OnEndTouchAllTriggers);
	// }
}

public void OnMapStart()
{
	CreateTimer(30.0, EnableJoinMsgs, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE);

	// Get mapname
	GetCurrentMap(g_szMapName, 128);

	// Debug Logging
	if (!DirExists("addons/sourcemod/logs/surftimer"))
		CreateDirectory("addons/sourcemod/logs/surftimer", 511);

	BuildPath(Path_SM, g_szLogFile, sizeof(g_szLogFile), "logs/surftimer/%s.log", g_szMapName);

	// Get map maxvelocity
	g_hMaxVelocity = FindConVar("sv_maxvelocity");

	// Load spawns
	if (!g_bRenaming && !g_bInTransactionChain)
	checkSpawnPoints();

	db_viewMapSettings();

	// Workshop fix
	char mapPieces[6][128];
	int lastPiece = ExplodeString(g_szMapName, "/", mapPieces, sizeof(mapPieces), sizeof(mapPieces[]));
	Format(g_szMapName, sizeof(g_szMapName), "%s", mapPieces[lastPiece - 1]);


	/** Start Loading Server Settings:
	* 1. Load zones (db_selectMapZones)
	* 2. Get map record time (db_GetMapRecord_Pro)
	* 3. Get the amount of players that have finished the map (db_viewMapProRankCount)
	* 4. Get the fastest bonus times (db_viewFastestBonus)
	* 5. Get the total amount of players that have finsihed the bonus (db_viewBonusTotalCount)
	* 6. Get map tier (db_selectMapTier)
	* 7. Get record checkpoints (db_viewRecordCheckpointInMap)
	* 8. Calculate average run time (db_CalcAvgRunTime)
	* 9. Calculate averate bonus time (db_CalcAvgRunTimeBonus)
	* 10. Calculate player count (db_CalculatePlayerCount)
	* 11. Calculate player count with points (db_CalculatePlayersCountGreater0)
	* 12. Get spawn locations (db_selectSpawnLocations)
	* 13. Clear latest records (db_ClearLatestRecords)
	* 14. Get dynamic timelimit (db_GetDynamicTimelimit)
	//fluffys
	* 15. Get total amount of stages on the map (db_GetTotalStages)
	* -> loadAllClientSettings
	*/
	if (!g_bRenaming && !g_bInTransactionChain && IsServerProcessing())
	{
		LogToFileEx(g_szLogFile, "[surftimer] Starting to load server settings");
		g_fServerLoading[0] = GetGameTime();
		db_selectMapZones();
	}

	//fluffys
	//db_GetTotalStages();

	//db_selectTotalBonusCount();
	//db_selectTotalStageCount();

	//db_selectCurrentMapImprovement();

	//get map tag
	ExplodeString(g_szMapName, "_", g_szMapPrefix, 2, 32);

	//sv_pure 1 could lead to problems with the ckSurf models
	ServerCommand("sv_pure 0");

	//reload language files
	LoadTranslations("surftimer.phrases");

	// load configs
	loadHiddenChatCommands();
	//loadCustomTitles();

	CheatFlag("bot_zombie", false, true);
	for (int i = 0; i < MAXZONEGROUPS; i++)
	{
		g_bTierFound[i] = false;
		g_fBonusFastest[i] = 9999999.0;
		g_bCheckpointRecordFound[i] = false;
	}

	//precache
	InitPrecache();
	SetCashState();

	//timers
	CreateTimer(0.1, CKTimer1, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
	CreateTimer(1.0, CKTimer2, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
	CreateTimer(60.0, AttackTimer, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
	CreateTimer(600.0, PlayerRanksTimer, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
	g_hZoneTimer = CreateTimer(GetConVarFloat(g_hChecker), BeamBoxAll, _, TIMER_REPEAT);

	//AutoBhop?
	if (GetConVarBool(g_hAutoBhopConVar))
		g_bAutoBhop = true;
	else
		g_bAutoBhop = false;


	//main.cfg & replays
	CreateTimer(1.0, DelayedStuff, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(10.0, LoadReplaysTimer, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE);


	if (g_bLateLoaded)
		OnAutoConfigsBuffered();

	g_Advert = 0;
	CreateTimer(180.0, AdvertTimer, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);

	int iEnt;
	for (int i = 0; i < sizeof(EntityList); i++)
	{
		while ((iEnt = FindEntityByClassname(iEnt, EntityList[i])) != -1)
		{
			AcceptEntityInput(iEnt, "Disable");
			AcceptEntityInput(iEnt, "Kill");
		}
	}

	// PushFix by Mev, George, & Blacky
	// https://forums.alliedmods.net/showthread.php?t=267131
	iEnt = -1;
	while ((iEnt = FindEntityByClassname(iEnt, "trigger_push")) != -1)
	{
			SDKHook(iEnt, SDKHook_Touch, OnTouchPushTrigger);
			SDKHook(iEnt, SDKHook_EndTouch, OnEndTouchPushTrigger);
	}

	//fluffys gravity
	iEnt = -1;
	while ((iEnt = FindEntityByClassname(iEnt, "trigger_gravity")) != -1)
	{
		SDKHook(iEnt, SDKHook_EndTouch, OnEndTouchGravityTrigger);
	}

	// hook zones
	iEnt = -1;
	if (g_hTriggerMultiple != null)
		CloseHandle(g_hTriggerMultiple);

	g_hTriggerMultiple = CreateArray(128);
	while ((iEnt = FindEntityByClassname(iEnt, "trigger_multiple")) != -1)
	{
		PushArrayCell(g_hTriggerMultiple, iEnt);
	}

	g_mTriggerMultipleMenu = CreateMenu(HookZonesMenuHandler);
	SetMenuTitle(g_mTriggerMultipleMenu, "Select a trigger");

	for (int i = 0; i < GetArraySize(g_hTriggerMultiple);i++)
	{
		iEnt = GetArrayCell(g_hTriggerMultiple, i);

		if (IsValidEntity(iEnt))
		{
			char szTriggerName[128];
			GetEntPropString(iEnt, Prop_Send, "m_iName", szTriggerName, 128, 0);
			AddMenuItem(g_mTriggerMultipleMenu, szTriggerName, szTriggerName);
		}
	}

	SetMenuOptionFlags(g_mTriggerMultipleMenu, MENUFLAG_BUTTON_EXIT);

	// destinations (goose)
	iEnt = -1;
	if (g_hDestinations != null)
		CloseHandle(g_hDestinations);
	
	g_hDestinations = CreateArray(128);
	while ((iEnt = FindEntityByClassname(iEnt, "info_teleport_destination")) != -1)
		PushArrayCell(g_hDestinations, iEnt);

	// all triggers
	// iEnt = -1;
	// while ((iEnt = FindEntityByClassname(iEnt, "trigger_*")) != -1)
	// {
	// 	SDKHook(iEnt, SDKHook_Touch, OnTouchAllTriggers);
	// 	SDKHook(iEnt, SDKHook_EndTouch, OnEndTouchAllTriggers);
	// }

	//OnConfigsExecuted();

	// Set default values
	g_fMapStartTime = GetGameTime();
	g_bRoundEnd = false;

	// Replay Bot Fix
	// CreateTimer(5.0, FixBot_Off, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE);
	// CreateTimer(10.0, FixBot_On, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE);

	// Playtime
	CreateTimer(1.0, PlayTimeTimer, INVALID_HANDLE, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	
	if(FindPluginByFile("store.smx")!=INVALID_HANDLE)
		LogMessage("Store plugin has been found! Timer credits enabled.");
	else 
	{
		LogMessage("Store not found! Timer credits have been disabled");
	}
	
	// Server Announcements
	g_iServerID = GetConVarInt(g_hServerID);
	if (GetConVarBool(g_hRecordAnnounce))
		CreateTimer(45.0, AnnouncementTimer, INVALID_HANDLE, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

	// Show Triggers
	g_iTriggerTransmitCount = 0;

	// Save Locs
	ResetSaveLocs();
}

public void OnMapEnd()
{
	//ServerCommand("sm_updater_force");
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

	//fluffys wrcps
	for (int client = 1; client <= MAXPLAYERS; client++)
	{
		g_fWrcpMenuLastQuery[client] = 0.0;
		g_bWrcpTimeractivated[client] = false;
	}

	// hook zones
	if (g_hTriggerMultiple != null)
	{
		ClearArray(g_hTriggerMultiple);
		CloseHandle(g_hTriggerMultiple);
	}

	g_hTriggerMultiple = null;
	delete g_hTriggerMultiple;

	CloseHandle(g_mTriggerMultipleMenu);

	if (g_hStore != null)
		CloseHandle(g_hStore);
	
	if (g_hDestinations != null)
		CloseHandle(g_hDestinations);

	g_hDestinations = null;
}

public void OnConfigsExecuted()
{
	if (GetConVarBool(g_hDBMapcycle))
		db_selectMapCycle();
	else if (!GetConVarBool(g_hMultiServerMapcycle))
		readMapycycle();
	else
		readMultiServerMapcycle();

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

	ServerCommand("mp_endmatch_votenextmap 0;mp_do_warmup_period 0;mp_warmuptime 0;mp_match_can_clinch 0;mp_match_end_changelevel 1;mp_match_restart_delay 10;mp_endmatch_votenextleveltime 10;mp_endmatch_votenextmap 0;mp_halftime 0;	bot_zombie 1;mp_do_warmup_period 0;mp_maxrounds 1;mp_drop_knife_enable 1;sv_clamp_unsafe_velocities 0;sv_ladder_scale_speed 1;sv_friction 5.2;sv_staminamax 0");

	if (GetConVarInt(g_hServerType) == 1) // Bhop
	{
		ServerCommand("sv_infinite_ammo 1");
	}
	else // Surf
	{
		ServerCommand("sv_infinite_ammo 2");
		ServerCommand("sv_autobunnyhopping 1");
	}
}


public void OnAutoConfigsBuffered()
{
	//just to be sure that it's not empty
	char szMap[128];
	char szPrefix[2][32];
	GetCurrentMap(szMap, 128);
	char mapPieces[6][128];
	int lastPiece = ExplodeString(szMap, "/", mapPieces, sizeof(mapPieces), sizeof(mapPieces[]));
	Format(szMap, sizeof(szMap), "%s", mapPieces[lastPiece - 1]);
	ExplodeString(szMap, "_", szPrefix, 2, 32);


	//map config
	char szPath[256];
	Format(szPath, sizeof(szPath), "sourcemod/surftimer/map_types/%s_.cfg", szPrefix[0]);
	char szPath2[256];
	Format(szPath2, sizeof(szPath2), "cfg/%s", szPath);
	if (FileExists(szPath2))
		ServerCommand("exec %s", szPath);
	else
		SetFailState("<Surftimer> %s not found.", szPath2);
}

public void OnClientPutInServer(int client)
{
	if (!IsValidClient(client))
	return;

	//defaults
	SetClientDefaults(client);

	//SDKHooks
	SDKHook(client, SDKHook_SetTransmit, Hook_SetTransmit);
	SDKHook(client, SDKHook_PostThinkPost, Hook_PostThinkPost);
	SDKHook(client, SDKHook_OnTakeDamage, Hook_OnTakeDamage);
	SDKHook(client, SDKHook_PreThink, OnPlayerThink);
	SDKHook(client, SDKHook_PreThinkPost, OnPlayerThink);
	SDKHook(client, SDKHook_Think, OnPlayerThink);
	SDKHook(client, SDKHook_PostThink, OnPlayerThink);
	SDKHook(client, SDKHook_PostThinkPost, OnPlayerThink);

	// Footsteps
	if (!IsFakeClient(client))
		SendConVarValue(client, g_hFootsteps, "0");

	g_bReportSuccess[client] = false;
	g_fCommandLastUsed[client] = 0.0;

	//fluffys set bools
	g_bToggleMapFinish[client] = true;
	g_bRepeat[client] = false;
	g_bNotTeleporting[client] = false;

	g_userJumps[client][LastJumpTimes][3] = 0;
	g_userJumps[client][LastJumpTimes][2] = 0;
	g_userJumps[client][LastJumpTimes][1] = 0;
	g_userJumps[client][LastJumpTimes][0] = 0;

	if (IsFakeClient(client))
	{
		g_hRecordingAdditionalTeleport[client] = CreateArray(view_as<int>(AdditionalTeleport));
		CS_SetMVPCount(client, 1);
		return;
	}
	else
		g_MVPStars[client] = 0;

	//client country
	GetCountry(client);

	if (LibraryExists("dhooks"))
	DHookEntity(g_hTeleport, false, client);

	//get client steamID
	GetClientAuthId(client, AuthId_Steam2, g_szSteamID[client], MAX_NAME_LENGTH, true);

	// ' char fix
	FixPlayerName(client);

	//position restoring
	if (GetConVarBool(g_hcvarRestore) && !g_bRenaming && !g_bInTransactionChain)
	db_selectLastRun(client);

	//console info
	PrintConsoleInfo(client);

	if (g_bLateLoaded && IsPlayerAlive(client))
	PlayerSpawn(client);

	if (g_bTierFound[0])
	AnnounceTimer[client] = CreateTimer(20.0, AnnounceMap, client, TIMER_FLAG_NO_MAPCHANGE);

	if (!g_bRenaming && !g_bInTransactionChain && g_bServerDataLoaded && !g_bSettingsLoaded[client] && !g_bLoadingSettings[client])
	{
		/**
		Start loading client settings
		1. Load client map record (db_viewPersonalRecords)
		2. Load client rank in map (db_viewMapRankPro)
		3. Load client bonus record (db_viewPersonalBonusRecords)
		4. Load client points (db_viewPlayerPoints)
		5. Load player rank in server (db_GetPlayerRank)
		6. Load client options (db_viewPlayerOptions)
		7. Load client titles from db (db_viewCustomTitles)
		8. Load client checkpoints (db_viewCheckpoints)
		9. Load client wrcps (db_viewStageRanks)
		*/
		g_bLoadingSettings[client] = true;
		g_iSettingToLoad[client] = 0;
		LoadClientSetting(client, g_iSettingToLoad[client]);
		/*for(int i = 1; i <= 6;i++)
		{
			db_viewStylePersonalRecords(client, g_szSteamID[client], g_szMapName, i);
			db_viewPersonalBonusStylesRecords(client, g_szSteamID[client], i);
		}*/
	}
}

public void OnClientAuthorized(int client)
{
	if (GetConVarBool(g_hConnectMsg) && !IsFakeClient(client))
	{
		char s_Country[32], s_clientName[32], s_address[32];
		GetClientIP(client, s_address, 32);
		GetClientName(client, s_clientName, 32);
		Format(s_Country, 100, "Unknown");
		GeoipCountry(s_address, s_Country, 100);
		if (!strcmp(s_Country, NULL_STRING))
			Format(s_Country, 100, "Unknown", s_Country);
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
			Format(s_Country, 100, "The %s", s_Country);
		}

		if (StrEqual(s_Country, "Unknown", false) || StrEqual(s_Country, "Localhost", false))
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i) && i != client)
				{
					PrintToChat(i, "%t", "Connected1", WHITE, MOSSGREEN, s_clientName, WHITE);
				}
			}
		}
		else
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i) && i != client)
				{
					PrintToChat(i, "%t", "Connected2", WHITE, MOSSGREEN, s_clientName, WHITE, GREEN, s_Country);
				}
			}
		}
	}
}

public void OnClientDisconnect(int client)
{
	if (IsFakeClient(client) && g_hRecordingAdditionalTeleport[client] != null)
	{
		CloseHandle(g_hRecordingAdditionalTeleport[client]);
		g_hRecordingAdditionalTeleport[client] = null;
	}

	db_savePlayTime(client);

	g_fPlayerLastTime[client] = -1.0;
	if (g_fStartTime[client] != -1.0 && g_bTimeractivated[client])
	{
		if (g_bPause[client])
		{
			g_fPauseTime[client] = GetGameTime() - g_fStartPauseTime[client];
			g_fPlayerLastTime[client] = GetGameTime() - g_fStartTime[client] - g_fPauseTime[client];
		}
		else
			g_fPlayerLastTime[client] = g_fCurrentRunTime[client];
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

	//Database
	if (IsValidClient(client) && !g_bRenaming)
	{
		if (!g_bIgnoreZone[client] && !g_bPracticeMode[client])
			db_insertLastPosition(client, g_szMapName, g_Stage[g_iClientInZone[client][2]][client], g_iClientInZone[client][2]);

		db_updatePlayerOptions(client);
	}

	// Stop recording
	if (g_hRecording[client] != null)
		StopRecording(client);

	// Stop Showing Triggers
	if (g_bShowTriggers[client])
	{
		g_bShowTriggers[client] = false;
		--g_iTriggerTransmitCount;
		TransmitTriggers(g_iTriggerTransmitCount > 0);
	}
}

public void OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
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
						g_bTrailOn[i] = false;
					}
					else
					{
						if (!GetConVarBool(g_hBonusBot) && !GetConVarBool(g_hWrcpBot)) // if both bots are off, no need to record
							if (g_hRecording[i] != null)
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
						g_bTrailOn[i] = false;
					}
					else
					{
						if (!GetConVarBool(g_hReplayBot) && !GetConVarBool(g_hWrcpBot)) // if both bots are off
							if (g_hRecording[i] != null)
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
						g_bTrailOn[i] = false;
					}
					else
					{
						if (!GetConVarBool(g_hReplayBot) && !GetConVarBool(g_hBonusBot)) // if both bots are off
							if (g_hRecording[i] != null)
								StopRecording(i);
					}
				}
			}
		}
	}
	else if (convar == g_hAdminClantag)
	{
		if (GetConVarBool(g_hAdminClantag))
		{
			for (int i = 1; i <= MaxClients; i++)
				if (IsValidClient(i))
					CreateTimer(0.0, SetClanTag, i, TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			for (int i = 1; i <= MaxClients; i++)
				if (IsValidClient(i))
					CreateTimer(0.0, SetClanTag, i, TIMER_FLAG_NO_MAPCHANGE);
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
						if (g_bMapReplay)
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
	else if (convar == g_hZoneMenuFlag) {
		AdminFlag flag;
		bool validFlag;
		validFlag = FindFlagByChar(newValue[0], flag);

		if (!validFlag)
		{
			PrintToServer("Surftimer | Invalid flag for ck_zonemenu_flag");
			g_ZoneMenuFlag = ADMFLAG_ROOT;
		}
		else
			g_ZoneMenuFlag = FlagToBit(flag);
	}
	else if (convar == g_hAdminMenuFlag) 
	{
		AdminFlag flag;
		bool validFlag;
		validFlag = FindFlagByChar(newValue[0], flag);

		if (!validFlag)
		{
			PrintToServer("Surftimer | Invalid flag for ck_adminmenu_flag");
			g_AdminMenuFlag = ADMFLAG_GENERIC;
		}
		else
			g_AdminMenuFlag = FlagToBit(flag);
	}
	// else if (convar == g_hCustomTitlesFlag) 
	// {
	// 	AdminFlag flag;
	// 	bool validFlag;
	// 	validFlag = FindFlagByChar(newValue[0], flag);

	// 	if (!validFlag)
	// 	{
	// 		PrintToServer("Surftimer | Invalid flag for ck_customtitles_flag");
	// 		g_CustomTitlesFlag = ADMFLAG_GENERIC;
	// 	}
	// 	else
	// 		g_CustomTitlesFlag = FlagToBit(flag);
	// }
	else if (convar == g_hServerType)
	{
		if (GetConVarInt(g_hServerType) == 1) // Bhop
			ServerCommand("sv_infinite_ammo 1");
		else
			ServerCommand("sv_infinite_ammo 2"); // Surf
	}
	else if (convar == g_hServerID)
		g_iServerID = GetConVarInt(g_hServerID);
	else if (convar == g_hHostName)
	{
		GetConVarString(g_hHostName, g_sServerName, sizeof(g_sServerName));
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
	HookUserMessage(GetUserMessageId("SendPlayerItemFound"), ItemFoundMsg, true);

	// Footsteps
	g_hFootsteps = FindConVar("sv_footsteps");
	AddNormalSoundHook(Hook_FootstepCheck);

	// Gunshots
	AddTempEntHook("Shotgun Shot", Hook_ShotgunShot);

	g_bServerDataLoaded = false;
	g_bHasLatestID = false;

	// Show Triggers
	g_Offset_m_fEffects = FindSendPropInfo("CBaseEntity", "m_fEffects");

	g_cvar_sv_hibernate_when_empty = FindConVar("sv_hibernate_when_empty");
 
 	if (GetConVarInt(g_cvar_sv_hibernate_when_empty) == 1)
	{
 		SetConVarInt(g_cvar_sv_hibernate_when_empty, 0);
 	}

	//Get Server Tickate
	float fltickrate = 1.0 / GetTickInterval();
	if (fltickrate > 65)
		if (fltickrate < 103)
			g_Server_Tickrate = 102;
		else
			g_Server_Tickrate = 128;
	else
		g_Server_Tickrate = 64;

	//language file
	LoadTranslations("surftimer.phrases");

	CreateConVar("timer_version", VERSION, "Timer Version.", FCVAR_DONTRECORD | FCVAR_SPONLY | FCVAR_REPLICATED | FCVAR_NOTIFY);
	// g_hServerTier = CreateConVar("ck_server_tier", "1", "Server Tier", FCVAR_NOTIFY, true, 1.0, true, 3.0);

	g_hConnectMsg = CreateConVar("ck_connect_msg", "1", "on/off - Enables a player connect message with country", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hAllowRoundEndCvar = CreateConVar("ck_round_end", "0", "on/off - Allows to end the current round", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hDisconnectMsg = CreateConVar("ck_disconnect_msg", "1", "on/off - Enables a player disconnect message in chat", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hMapEnd = CreateConVar("ck_map_end", "1", "on/off - Allows map changes after the timelimit has run out (mp_timelimit must be greater than 0)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hColoredNames = CreateConVar("ck_colored_chatnames", "0", "on/off Colors players names based on their rank in chat.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hNoClipS = CreateConVar("ck_noclip", "1", "on/off - Allows players to use noclip", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	//g_hAutoTimer = CreateConVar("ck_auto_timer", "0", "on/off - Timer automatically starts when a player joins a team, dies or uses !start/!r", FCVAR_NOTIFY, true, 0.0, true, 1.0);
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
	g_hAdminClantag = CreateConVar("ck_admin_clantag", "1", "on/off - Admin clan tag (necessary flag: b - z)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	HookConVarChange(g_hAdminClantag, OnSettingChanged);
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
	g_hAdminMenuFlag = CreateConVar("ck_adminmenu_flag", "b", "Admin flag required to open the !ckadmin menu. Invalid or not set, requires flag b. Requires a server restart.", FCVAR_NOTIFY);
	GetConVarString(g_hAdminMenuFlag, szFlag, 24);
	validFlag = FindFlagByChar(szFlag[0], bufferFlag);
	if (!validFlag)
	{
		PrintToServer("Surftimer | Invalid flag for ck_adminmenu_flag.");
		g_AdminMenuFlag = ADMFLAG_GENERIC;
	}
	else
		g_AdminMenuFlag = FlagToBit(bufferFlag);
	HookConVarChange(g_hAdminMenuFlag, OnSettingChanged);

	g_hZoneMenuFlag = CreateConVar("ck_zonemenu_flag", "z", "Admin flag required to open the !zones menu. Invalid or not set, requires flag z. Requires a server restart.", FCVAR_NOTIFY);
	GetConVarString(g_hZoneMenuFlag, szFlag, 24);
	validFlag = FindFlagByChar(szFlag[0], bufferFlag);
	if (!validFlag)
	{
		PrintToServer("Surftimer | Invalid flag for ck_zonemenu_flag.");
		g_ZoneMenuFlag = ADMFLAG_ROOT;
	}
	else
		g_ZoneMenuFlag = FlagToBit(bufferFlag);
	HookConVarChange(g_hZoneMenuFlag, OnSettingChanged);

	// Map Setting ConVars
	g_hGravityFix = CreateConVar("ck_gravityfix_enable", "1", "Enables/Disables trigger_gravity fix", FCVAR_NOTIFY, true, 0.0, true, 1.0);

	// VIP ConVars
	// g_hCustomTitlesFlag = CreateConVar("ck_customtitles_flag", "a", "Which flag must players have to use Custom Titles. Invalid or not set, disables Custom Titles.", FCVAR_NOTIFY);
	// GetConVarString(g_hCustomTitlesFlag, szFlag, 24);
	// g_bCustomTitlesFlag = FindFlagByChar(szFlag[0], bufferFlag);
	// g_CustomTitlesFlag = FlagToBit(bufferFlag);
	// HookConVarChange(g_hCustomTitlesFlag, OnSettingChanged);

	// Prestige Server
	g_hPrestigeRank = CreateConVar("ck_prestige_rank", "0", "Rank of players who can join the server, 0 to disable");

	// Surf / Bhop
	g_hServerType = CreateConVar("ck_server_type", "0", "Change the timer to function for Surf or Bhop, 0 = surf, 1 = bhop");
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

	// Server Name
	g_hHostName = FindConVar("hostname");
	HookConVarChange(g_hHostName, OnSettingChanged);
	GetConVarString(g_hHostName, g_sServerName, sizeof(g_sServerName));

	db_setupDatabase();

	//RegConsoleCmd("sm_rtimes", Command_rTimes, "[surftimer] spawns a usp silencer");


	//client commands
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
	RegConsoleCmd("sm_hidespecs", Client_HideSpecs, "[surftimer] hides spectators from menu/panel");
	RegConsoleCmd("sm_wr", Client_Wr, "[surftimer] prints records wr in chat");
	RegConsoleCmd("sm_wrb", Client_Wrb, "[surftimer] prints records wrb in chat");
	RegConsoleCmd("sm_spec", Client_Spec, "[surftimer] chooses a player who you want to spectate and switch you to spectators");
	RegConsoleCmd("sm_watch", Client_Spec, "[surftimer] chooses a player who you want to spectate and switch you to spectators");
	RegConsoleCmd("sm_spectate", Client_Spec, "[surftimer] chooses a player who you want to spectate and switch you to spectators");
	RegConsoleCmd("sm_helpmenu", Client_Help, "[surftimer] help menu which displays all kp commands");
	RegConsoleCmd("sm_help", Client_Help, "[surftimer] help menu which displays all kp commands");
	RegConsoleCmd("sm_profile", Client_Profile, "[surftimer] opens a player profile");
	RegConsoleCmd("sm_options", Client_OptionMenu, "[surftimer] opens options menu");
	RegConsoleCmd("sm_top", Client_Top, "[surftimer] displays top rankings (Top 100 Players, Top 50 overall)");
	RegConsoleCmd("sm_topSurfers", Client_Top, "[surftimer] displays top rankings (Top 100 Players, Top 50 overall)");
	RegConsoleCmd("sm_bonustop", Client_BonusTop, "[surftimer] displays top rankings of the bonus");
	RegConsoleCmd("sm_btop", Client_BonusTop, "[surftimer] displays top rankings of the bonus");
	RegConsoleCmd("sm_stop", Client_Stop, "[surftimer] stops your timer");
	RegConsoleCmd("sm_ranks", Client_Ranks, "[surftimer] prints in chat the available player ranks");
	RegConsoleCmd("sm_pause", Client_Pause, "[surftimer] on/off pause (timer on hold and movement frozen)");
	RegConsoleCmd("sm_latest", Client_Latest, "[surftimer] shows latest map records");
	RegConsoleCmd("sm_rr", Client_Latest, "[surftimer] shows latest map records");
	RegConsoleCmd("sm_rb", Client_Latest, "[surftimer] shows latest map records");
	RegConsoleCmd("sm_hide", Client_Hide, "[surftimer] on/off - hides other players");
	RegConsoleCmd("sm_togglecheckpoints", ToggleCheckpoints, "[surftimer] on/off - Enable player checkpoints");
	RegConsoleCmd("+noclip", NoClip, "[surftimer] Player noclip on");
	RegConsoleCmd("-noclip", UnNoClip, "[surftimer] Player noclip off");
	RegConsoleCmd("sm_nc", Command_ckNoClip, "[surftimer] Player noclip on/off");

	// Teleportation commands
	RegConsoleCmd("sm_stages", Command_SelectStage, "[surftimer] Opens up the stage selector");
	RegConsoleCmd("sm_r", Command_Restart, "[surftimer] Teleports player back to the start");
	RegConsoleCmd("sm_restart", Command_Restart, "[surftimer] Teleports player back to the start");
	RegConsoleCmd("sm_start", Command_Restart, "[surftimer] Teleports player back to the start");
	RegConsoleCmd("sm_b", Command_ToBonus, "[surftimer] Teleports player back to the start");
	RegConsoleCmd("sm_bonus", Command_ToBonus, "[surftimer] Teleports player back to the start");
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
	RegConsoleCmd("sm_btier", Command_bTier, "[surftimer] Prints tier information on current map's bonuses");
	RegConsoleCmd("sm_bonusinfo", Command_bTier, "[surftimer] Prints tier information on current map's bonuses");
	RegConsoleCmd("sm_bi", Command_bTier, "[surftimer] Prints tier information on current map's bonuses");
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

	RegConsoleCmd("sm_cp", Command_createPlayerCheckpoint, "[surftimer] Creates a checkpoint, where the player can teleport back to");
	RegConsoleCmd("sm_checkpoint", Command_createPlayerCheckpoint, "[surftimer] Creates a eckpoint, where the player can teleport back to");
	//RegConsoleCmd("sm_undo", Command_undoPlayerCheckpoint, "[surftimer] Undoes the players lchast checkpoint.");
	RegConsoleCmd("sm_normal", Command_normalMode, "[surftimer] Switches player back to normal mode.");
	RegConsoleCmd("sm_n", Command_normalMode, "[surftimer] Switches player back to normal mode.");

	RegAdminCmd("sm_ckadmin", Admin_ckPanel, g_AdminMenuFlag, "[surftimer] Displays the kp menu panel");
	RegAdminCmd("sm_refreshprofile", Admin_RefreshProfile, g_AdminMenuFlag, "[surftimer] Recalculates player profile for given steam id");

	RegAdminCmd("sm_clearassists", Admin_ClearAssists, g_AdminMenuFlag, "[surftimer] Clears assist points (map progress) from all players");

	// DB Map Settings && Zoners
	RegConsoleCmd("sm_zones", Command_Zones, "[surftimer] Opens up the zone creation menu.");
	RegConsoleCmd("sm_hookzone", Command_HookZones, "[surftimer] Opens up zone hook creation menu.");
	RegConsoleCmd("sm_addmaptier", Admin_insertMapTier, "[surftimer] Changes maps tier");
	RegConsoleCmd("sm_amt", Admin_insertMapTier, "[surftimer] Changes maps tier");
	RegConsoleCmd("sm_addspawn", Admin_insertSpawnLocation, "[surftimer] Changes the position !r takes players to");
	RegConsoleCmd("sm_delspawn", Admin_deleteSpawnLocation, "[surftimer] Removes custom !r position");
	RegConsoleCmd("sm_startprespeed", Command_SetStartPreSpeed);
	RegConsoleCmd("sm_sps", Command_SetStartPreSpeed);
	RegConsoleCmd("sm_bonusprespeed", Command_SetBonusPreSpeed);
	RegConsoleCmd("sm_bps", Command_SetBonusPreSpeed);
	RegConsoleCmd("sm_stageprespeed", Command_SetStagePreSpeed);
	RegConsoleCmd("sm_stageps", Command_SetStagePreSpeed);
	RegConsoleCmd("sm_maxvelocity", Command_SetMaxVelocity);
	RegConsoleCmd("sm_mv", Command_SetMaxVelocity);
	RegConsoleCmd("sm_announcerecord", Command_SetAnnounceRecord);
	RegConsoleCmd("sm_ar", Command_SetAnnounceRecord);
	RegConsoleCmd("sm_gravityfix", Command_SetGravityFix);
	RegConsoleCmd("sm_gf", Command_SetGravityFix);
	RegConsoleCmd("sm_triggers", Command_ToggleTriggers);
	RegConsoleCmd("sm_noclipspeed", Command_NoclipSpeed);

	// VIP Commands
	RegConsoleCmd("sm_fixbot", Admin_FixBot, "[surftimer] Toggles replay bots off and on");

	RegConsoleCmd("sm_vip", Command_Vip, "[surftimer] Displays the VIP menu to client");
	RegConsoleCmd("sm_mytitle", Command_PlayerTitle, "[surftimer] VIPs can set their own custom title into a db.");
	RegConsoleCmd("sm_title", Command_PlayerTitle, "[surftimer] VIPs can set their own custom title into a db.");
	RegConsoleCmd("sm_customtitle", Command_SetDbTitle, "[surftimer] VIPs can set their own custom title into a db.");
	RegConsoleCmd("sm_namecolour", Command_SetDbNameColour, "[surftimer] VIPs can set their own custom name colour into the db.");
	RegConsoleCmd("sm_textcolour", Command_SetDbTextColour, "[surftimer] VIPs can set their own custom text colour into the db.");
	RegConsoleCmd("sm_ve", Command_VoteExtend, "[surftimer] Vote to extend the map");
	RegConsoleCmd("sm_colours", Command_ListColours, "[surftimer] Lists available colours for sm_mytitle and sm_namecolour");
	RegConsoleCmd("sm_toggletitle", Command_ToggleTitle, "[surftimer] VIPs can toggle their title.");
	RegConsoleCmd("sm_votemute", Command_VoteMute, "[surftimer] starts a vote to mute a client");
	RegConsoleCmd("sm_votegag", Command_VoteGag, "[surftimer] starts a vote to gag a client");
	RegConsoleCmd("sm_joinmsg", Command_JoinMsg, "[surftimer] Allows a vip to set their join msg");

	// Automatic Donate Commands
	RegAdminCmd("sm_givevip", VIP_GiveVip, ADMFLAG_ROOT, "[surftimer] Give a player VIP");
	RegAdminCmd("sm_removevip", VIP_RemoveVip, ADMFLAG_ROOT, "[surftimer] Remove a players VIP");
	RegAdminCmd("sm_addcredits", VIP_GiveCredits, ADMFLAG_ROOT, "[surftimer] Give a player credits");

	// WRCPs
	RegConsoleCmd("sm_wrcp", Client_Wrcp, "[surftimer] displays stage times for map");
	RegConsoleCmd("sm_wrcps", Client_Wrcp, "[surftimer] displays stage times for map");

	// QOL commands
	RegConsoleCmd("sm_gb", Command_GoBack, "[surftimer] Go back a stage");
	RegConsoleCmd("sm_goback", Command_GoBack, "[surftimer] Go back a stage");
	RegConsoleCmd("sm_mtop", Client_MapTop, "[surftimer] displays local map top for a given map");
	RegConsoleCmd("sm_p", Client_Profile, "[surftimer] opens a player profile");
	RegConsoleCmd("sm_kp", Client_OptionMenu, "[surftimer] opens options menu");
	RegConsoleCmd("sm_timer", Client_OptionMenu, "[surftimer] opens options menu");
	RegConsoleCmd("sm_surftimer", Client_OptionMenu, "[surftimer] opens options menu");
	RegConsoleCmd("sm_bhoptimer", Client_OptionMenu, "[surftimer] opens options menu");
	RegConsoleCmd("sm_saveloc", Command_createPlayerCheckpoint, "[surftimer] Creates a checkpoint, where the player can teleport back to");
	RegConsoleCmd("sm_savelocs", Command_SaveLocList);
	RegConsoleCmd("sm_loclist", Command_SaveLocList);
	RegConsoleCmd("sm_knife", Command_GiveKnife, "[surftimer] Give players a knife");

	// New Commands
	RegConsoleCmd("sm_mrank", Command_SelectMapTime, "[surftimer] prints a players map record in chat.");
	RegConsoleCmd("sm_brank", Command_SelectBonusTime, "[surftimer] prints a players bonus record in chat.");
	RegConsoleCmd("sm_pr", Command_SelectPlayerPr, "[surftimer] Displays pr menu to client");
	RegConsoleCmd("sm_togglemapfinish", Command_ToggleMapFinish, "[surftimer] Toggles whether a player will finish a map when entering the end zone.");
	RegConsoleCmd("sm_tmf", Command_ToggleMapFinish, "[surftimer] Toggles whether a player will finish a map when entering the end zone.");
	RegConsoleCmd("sm_repeat", Command_Repeat, "[surftimer] Toggles whether a player will keep repeating the same stage.");
	RegConsoleCmd("sm_rank", Command_SelectRank, "[surftimer] opens a player profile");
	RegConsoleCmd("sm_mi", Command_MapImprovement, "[surftimer] opens map improvement points panel for map");
	RegConsoleCmd("sm_specbot", Command_SpecBot, "[surftimer] Spectate the map bot");
	RegConsoleCmd("sm_specbotbonus", Command_SpecBonusBot, "[surftimer] Spectate the bonus bot");
	RegConsoleCmd("sm_specbotb", Command_SpecBonusBot, "[surftimer] Spectate the bonus bot");
	RegConsoleCmd("sm_showzones", Command_ShowZones, "[surftimer] Clients can toggle whether zones are visible for them");

	// Styles
	RegConsoleCmd("sm_style", Client_SelectStyle, "[surftimer] open style select menu.");
	RegConsoleCmd("sm_styles", Client_SelectStyle, "[surftimer] open style select menu.");

	//Style WR
	RegConsoleCmd("sm_wrsw", Client_Wrsw, "[surftimer] prints records sw in chat");
	RegConsoleCmd("sm_swwr", Client_Wrsw, "[surftimer] prints records sw in chat");
	RegConsoleCmd("sm_wrhsw", Client_Wrhsw, "[surftimer] prints records hsw in chat");
	RegConsoleCmd("sm_hswwr", Client_Wrhsw, "[surftimer] prints records hsw in chat");
	RegConsoleCmd("sm_wrbw", Client_Wrbw, "[surftimer] prints records bw in chat");
	RegConsoleCmd("sm_bwwr", Client_Wrbw, "[surftimer] prints records bw in chat");
	RegConsoleCmd("sm_wrlg", Client_Wrlg, "[surftimer] prints records low-gravity in chat");
	RegConsoleCmd("sm_lgwr", Client_Wrlg, "[surftimer] prints records low-gravity in chat");
	RegConsoleCmd("sm_wrsm", Client_Wrsm, "[surftimer] prints records slow motion in chat");
	RegConsoleCmd("sm_smwr", Client_Wrsm, "[surftimer] prints records slow motion in chat");
	RegConsoleCmd("sm_wrff", Client_Wrff, "[surftimer] prints records fast forwards in chat");
	RegConsoleCmd("sm_ffwr", Client_Wrff, "[surftimer] prints records fast forwards in chat");

	//Style WRB
	RegConsoleCmd("sm_wrbsw", Client_Wrbsw, "[surftimer] prints records sw in chat");
	RegConsoleCmd("sm_swwrb", Client_Wrbsw, "[surftimer] prints records sw in chat");
	RegConsoleCmd("sm_wrbhsw", Client_Wrbhsw, "[surftimer] prints records hsw in chat");
	RegConsoleCmd("sm_hswwrb", Client_Wrbhsw, "[surftimer] prints records hsw in chat");
	RegConsoleCmd("sm_wrbbw", Client_Wrbbw, "[surftimer] prints records bw in chat");
	RegConsoleCmd("sm_bwwrb", Client_Wrbbw, "[surftimer] prints records bw in chat");
	RegConsoleCmd("sm_wrblg", Client_Wrblg, "[surftimer] prints records low-gravity in chat");
	RegConsoleCmd("sm_lgwrb", Client_Wrblg, "[surftimer] prints records low-gravity in chat");
	RegConsoleCmd("sm_wrbsm", Client_Wrbsm, "[surftimer] prints records slow motion in chat");
	RegConsoleCmd("sm_smwrb", Client_Wrbsm, "[surftimer] prints records slow motion in chat");
	RegConsoleCmd("sm_wrbff", Client_Wrbff, "[surftimer] prints records fast forwards in chat");
	RegConsoleCmd("sm_ffwrb", Client_Wrbff, "[surftimer] prints records fast forwards in chat");

	//Style mtop
	RegConsoleCmd("sm_mtopsw", Client_SWMapTop, "[surftimer] displays a local map top (sw) for a given map");
	RegConsoleCmd("sm_swmtop", Client_SWMapTop, "[surftimer] displays a local map top (sw) for a given map");
	RegConsoleCmd("sm_mtophsw", Client_HSWMapTop, "[surftimer] displays a local map top (hsw) for a given map");
	RegConsoleCmd("sm_hswmtop", Client_HSWMapTop, "[surftimer] displays a local map top (hsw) for a given map");
	RegConsoleCmd("sm_mtopbw", Client_BWMapTop, "[surftimer] displays a local map top (bw) for a given map");
	RegConsoleCmd("sm_bwmtop", Client_BWMapTop, "[surftimer] displays a local map top (bw) for a given map");
	RegConsoleCmd("sm_mtoplg", Client_LGMapTop, "[surftimer] displays a local map top (low-gravity) for a given map");
	RegConsoleCmd("sm_lgmtop", Client_LGMapTop, "[surftimer] displays a local map top (low-gravity) for a given map");
	RegConsoleCmd("sm_mtopsm", Client_SMMapTop, "[surftimer] displays a local map top (slow motion) for a given map");
	RegConsoleCmd("sm_smmtop", Client_SMMapTop, "[surftimer] displays a local map top (slow motion) for a given map");
	RegConsoleCmd("sm_mtopff", Client_FFMapTop, "[surftimer] displays a local map top (fast forwards) for a given map");
	RegConsoleCmd("sm_ffmtop", Client_FFMapTop, "[surftimer] displays a local map top (fast forwards) for a given map");

	//style btop if i ever get around to it
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

	//style wrcp
	RegConsoleCmd("sm_wrcpsw", Client_SWWrcp, "[surftimer] displays sideways stage times for map");
	RegConsoleCmd("sm_swwrcp", Client_SWWrcp, "[surftimer] displays sideways stage times for map");
	RegConsoleCmd("sm_wrcphsw", Client_HSWWrcp, "[surftimer] displays half-sideways stage times for map");
	RegConsoleCmd("sm_hswwrcp", Client_HSWWrcp, "[surftimer] displays half-sideways stage times for map");
	RegConsoleCmd("sm_wrcpbw", Client_BWWrcp, "[surftimer] displays backwards stage times for map");
	RegConsoleCmd("sm_bwwrcp", Client_BWWrcp, "[surftimer] displays backwards stage times for map");
	RegConsoleCmd("sm_wrcplg", Client_LGWrcp, "[surftimer] displays low-gravity stage times for map");
	RegConsoleCmd("sm_lgwrcp", Client_LGWrcp, "[surftimer] displays low-gravity stage times for map");
	RegConsoleCmd("sm_wrcpsm", Client_SMWrcp, "[surftimer] displays slow motion stage times for map");
	RegConsoleCmd("sm_smwrcp", Client_SMWrcp, "[surftimer] displays slow motion stage times for map");
	RegConsoleCmd("sm_wrcpff", Client_FFWrcp, "[surftimer] displays fast forwards stage times for map");
	RegConsoleCmd("sm_ffwrcp", Client_FFWrcp, "[surftimer] displays fast forwards stage times for map");

	//style profiles
	RegConsoleCmd("sm_psw", Client_SWProfile, "[surftimer] opens a player sw profile");
	RegConsoleCmd("sm_swp", Client_SWProfile, "[surftimer] opens a player sw profile");
	RegConsoleCmd("sm_phsw", Client_HSWProfile, "[surftimer] opens a player hsw profile");
	RegConsoleCmd("sm_hswp", Client_HSWProfile, "[surftimer] opens a player hsw profile");
	RegConsoleCmd("sm_pbw", Client_BWProfile, "[surftimer] opens a player bw profile");
	RegConsoleCmd("sm_bwp", Client_BWProfile, "[surftimer] opens a player bw profile");
	RegConsoleCmd("sm_plg", Client_LGProfile, "[surftimer] opens a player low-gravity profile");
	RegConsoleCmd("sm_lgp", Client_LGProfile, "[surftimer] opens a player low-gravity profile");
	RegConsoleCmd("sm_psm", Client_SMProfile, "[surftimer] opens a player slow motion profile");
	RegConsoleCmd("sm_smp", Client_SMProfile, "[surftimer] opens a player slow motion profile");
	RegConsoleCmd("sm_pff", Client_FFProfile, "[surftimer] opens a player fast forwards profile");
	RegConsoleCmd("sm_ffp", Client_FFProfile, "[surftimer] opens a player fast forwards profile");

	// Bans & Mutes
	RegConsoleCmd("sm_bans", Client_ShowBans, "[surftimer] displays a menu with the recent bans");
	RegConsoleCmd("sm_mutes", Client_ShowComms, "[surftimer] displays a menu with the recent mutes or gags");
	RegConsoleCmd("sm_gags", Client_ShowComms, "[surftimer] displays a menu with the recent mutes or gags");

	//test
	RegAdminCmd("sm_test", sm_test, ADMFLAG_ROOT);
	RegAdminCmd("sm_vel", Client_GetVelocity, ADMFLAG_ROOT);
	RegAdminCmd("sm_targetname", Client_TargetName, ADMFLAG_ROOT);

	// !Startpos -- Goose
	RegConsoleCmd("sm_startpos", Command_Startpos, "[surftimer] Saves current location as new !r spawn.");
	RegConsoleCmd("sm_resetstartpos", Command_ResetStartpos, "[surftimer] Removes custom !r spawn.");

	// Discord
	RegConsoleCmd("sm_bug", Command_Bug, "[surftimer] report a bug to the KP discord");
	RegConsoleCmd("sm_calladmin", Command_Calladmin, "[surftimer] sends a message to the staff");

	// CPR
	RegConsoleCmd("sm_cpr", Command_CPR, "[surftimer] Compare clients time to another clients time");

	// reload map
	RegAdminCmd("sm_rm", Command_ReloadMap, ADMFLAG_ROOT, "[surftimer] Reloads the current map");
	

	// CVotes
	//RegAdminCmd("sm_cvote", start_vote, "[surftimer] Start an extend, map, nextmap vote.");

	// END TOTAL PLAYER TIME

	// sv_cheats
	//g_hsvCheats = FindConVar("sv_cheats"), g_flagsSvCheats = GetConVarFlags(g_hsvCheats);

	// Client side autobhop
	g_hAutoBhop = FindConVar("sv_autobunnyhopping");
	g_hEnableBhop = FindConVar("sv_enablebunnyhopping");

	SetConVarBool(g_hAutoBhop, true);
	SetConVarBool(g_hEnableBhop, true);

	//chat command listener
	AddCommandListener(Say_Hook, "say");
	HookUserMessage(GetUserMessageId("SayText2"), SayText2, true);
	AddCommandListener(Say_Hook, "say_team");
	//AddCommandListener(Commands_CommandListener);

	//exec surftimer.cfg
	AutoExecConfig(true, "surftimer");

	//mic
	g_ownerOffset = FindSendPropInfo("CBaseCombatWeapon", "m_hOwnerEntity");
	g_ragdolls = FindSendPropInfo("CCSPlayer", "m_hRagdoll");

	//add to admin menu
	Handle tpMenu;
	if (LibraryExists("adminmenu") && ((tpMenu = GetAdminTopMenu()) != null))
		OnAdminMenuReady(tpMenu);

	//hooks
	HookEvent("player_spawn", Event_OnPlayerSpawn, EventHookMode_Post);
	HookEvent("player_death", Event_OnPlayerDeath);
	HookEvent("round_start", Event_OnRoundStart, EventHookMode_PostNoCopy);
	HookEvent("round_end", Event_OnRoundEnd, EventHookMode_Pre);
	HookEvent("player_hurt", Event_OnPlayerHurt);
	HookEvent("weapon_fire", Event_OnFire, EventHookMode_Pre);
	HookEvent("player_team", Event_OnPlayerTeam, EventHookMode_Post);
	HookEvent("player_disconnect", Event_PlayerDisconnect, EventHookMode_Pre);
	HookEvent("player_jump", Event_PlayerJump);
	//HookEvent("player_disconnect", Event_PlayerDisconnect);

	// AddNormalSoundHook(OnNormalSoundPlayed);

	//mapcycle array
	int arraySize = ByteCountToCells(PLATFORM_MAX_PATH);
	g_MapList = CreateArray(arraySize);

	//add command listeners
	AddCommandListener(Command_JoinTeam, "jointeam");
	AddCommandListener(Command_ext_Menu, "radio1");
	AddCommandListener(Command_ext_Menu, "radio2");
	AddCommandListener(Command_ext_Menu, "radio3");

	//hook radio commands
	for (int g; g < sizeof(RadioCMDS); g++)
		AddCommandListener(BlockRadio, RadioCMDS[g]);

	//button sound hook
	//AddNormalSoundHook(NormalSHook_callback);

	//nav files
	CreateNavFiles();

	// Botmimic 2
	// https://forums.alliedmods.net/showthread.php?t=180114
	// Optionally setup a hook on CBaseEntity::Teleport to keep track of sudden place changes
	CheatFlag("bot_zombie", false, true);
	CheatFlag("bot_mimic", false, true);
	g_hLoadedRecordsAdditionalTeleport = CreateTrie();
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
	g_MapFinishForward = CreateGlobalForward("surftimer_OnMapFinished", ET_Event, Param_Cell, Param_Float, Param_String, Param_Cell, Param_Cell);
	g_BonusFinishForward = CreateGlobalForward("surftimer_OnBonusFinished", ET_Event, Param_Cell, Param_Float, Param_String, Param_Cell, Param_Cell, Param_Cell);
	g_PracticeFinishForward = CreateGlobalForward("surftimer_OnPracticeFinished", ET_Event, Param_Cell, Param_Float, Param_String);

	if (g_bLateLoaded)
	{
		CreateTimer(3.0, LoadPlayerSettings, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE);
	}

	Format(szWHITE, 12, "%c", WHITE);
	Format(szDARKRED, 12, "%c", DARKRED);
	Format(szPURPLE, 12, "%c", PURPLE);
	Format(szGREEN, 12, "%c", GREEN);
	Format(szMOSSGREEN, 12, "%c", MOSSGREEN);
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
	g_iLastID = 0;
}

public void OnAllPluginsLoaded()
{
	// Check if store is running
	g_hStore = FindPluginByFile("store.smx");
}
/*=====  End of Events  ======*/



/*===============================
=            Natives            =
===============================*/

public int Native_GetTimerStatus(Handle plugin, int numParams)
{
	return g_bTimeractivated[GetNativeCell(1)];
}

public int Native_StopTimer(Handle plugin, int numParams)
{
	Client_Stop(GetNativeCell(1), 0);
}

public int Native_GetCurrentTime(Handle plugin, int numParams)
{
	return view_as<int>(g_fCurrentRunTime[GetNativeCell(1)]);
}

public int Native_EmulateStartButtonPress(Handle plugin, int numParams)
{
	CL_OnStartTimerPress(GetNativeCell(1));
}

public int Native_EmulateStopButtonPress(Handle plugin, int numParams)
{
	CL_OnEndTimerPress(GetNativeCell(1));
}

public int Native_GetServerRank(Handle plugin, int numParams)
{
	return g_PlayerRank[GetNativeCell(1)];
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

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	RegPluginLibrary("surftimer");
	CreateNative("surftimer_GetTimerStatus", Native_GetTimerStatus);
	CreateNative("surftimer_StopTimer", Native_StopTimer);
	CreateNative("surftimer_EmulateStartButtonPress", Native_EmulateStartButtonPress);
	CreateNative("surftimer_EmulateStopButtonPress", Native_EmulateStopButtonPress);
	CreateNative("surftimer_GetCurrentTime", Native_GetCurrentTime);
	CreateNative("surftimer_GetServerRank", Native_GetServerRank);
	CreateNative("surftimer_SafeTeleport", Native_SafeTeleport);
	MarkNativeAsOptional("Store_GetClientCredits");
	MarkNativeAsOptional("Store_SetClientCredits");
	g_bLateLoaded = late;
	return APLRes_Success;
}

/*=====  End of Natives  ======*/
public Action ItemFoundMsg(UserMsg msg_id, Handle pb, const players[], any playersNum, any reliable, any init)
{
    return Plugin_Handled;
}
