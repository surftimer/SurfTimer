#if defined _surftimer_discord_included
 #endinput
#endif
#define _surftimer_discord_included

native void SurfTimer_SendBugReport(int client, char[] sWebhook, char[] sBotName, char[] sBugType, char[] sServerName, char[] sMapName, char[] sSteamID, char[] sBugMessage);

public SharedPlugin:__pl_surftimer_discord =
{
	name = "surftimer_discord",
	file = "surftimer_discord.smx",
	#if defined REQUIRE_PLUGIN
	required = 1,
	#else
	required = 0,
	#endif
};

public __pl_surftimer_discord_SetNTVOptional()
{
	MarkNativeAsOptional("surftimer_GetTimerStatus");
}
