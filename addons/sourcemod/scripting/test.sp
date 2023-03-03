#include <sourcemod>

char g_sSteamIdTablesCleanup[][] = {
	"ck_bonus", 
	"ck_checkpoints", 
	"ck_latestrecords", 
	"ck_playeroptions2", 
	"ck_playerrank", 
	"ck_playertemp", 
	"ck_playertimes", 
	"ck_prinfo", 
	"ck_vipadmins"
};

public void OnPluginStart()
{
	char sQuery[256];
	for (int i = 0; i < sizeof(g_sSteamIdTablesCleanup); i++)
	{
		FormatEx(sQuery, sizeof(sQuery), "DELETE FROM \"%s\" WHERE steamid = \"STEAM_ID_STOP_IGNORING_RETVALS\";", g_sSteamIdTablesCleanup[i]);
		LogMessage(sQuery);
	}
}