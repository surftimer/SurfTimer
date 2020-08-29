#pragma semicolon 1

#include <sourcemod>
#include <discord>
#include <surftimer>

#pragma newdecls required

public Plugin myinfo =
{
	name = "SurfTimer - Discord",
	author = "All contributors",
	description = "a fork from fluffys cksurf fork",
	version = VERSION,
	url = "https://github.com/surftimer/Surftimer-olokos"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("SurfTimer_SendBugReport", Native_SendBugReport);
	CreateNative("SurfTimer_SendCallAdmin", Native_SendCallAdmin);
	CreateNative("SurfTimer_SendAnnouncement", Native_SendAnnouncement);
	CreateNative("SurfTimer_SendAnnouncementBonus", Native_SendAnnouncementBonus);


	RegPluginLibrary("surftimer_discord");
}

public int Native_SendBugReport(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);

	char sWebhook[1024], sBotName[64], sBugType[32], sServerName[256], sMap[128], sBugMessage[256];

	GetNativeString(2, sWebhook, sizeof(sWebhook));
	GetNativeString(3, sBotName, sizeof(sBotName));
	GetNativeString(4, sBugType, sizeof(sBugType));
	GetNativeString(5, sServerName, sizeof(sServerName));
	GetNativeString(6, sMap, sizeof(sMap));
	GetNativeString(8, sBugMessage, sizeof(sBugMessage));

	// Send Discord Announcement
	DiscordWebHook hook = new DiscordWebHook(sWebhook);
	hook.SlackMode = true;

	hook.SetUsername(sBotName);

	MessageEmbed Embed = new MessageEmbed();

	// Format Title
	char sTitle[256];
	Format(sTitle, sizeof(sTitle), "Bug Type: %s ║ Server: %s ║ Map: %s", sBugType, sServerName, sMap);
	Embed.SetTitle(sTitle);

	// Format Player
	char sName[MAX_NAME_LENGTH], sSteamID[32];
	GetClientName(client, sName, sizeof(sName));
	GetClientAuthId(client, AuthId_Steam2, sSteamID, sizeof(sSteamID));

	// Format Message
	char sMessage[512];
	Format(sMessage, sizeof(sMessage), "%s (%s): %s", sName, sSteamID, sBugMessage);
	Embed.AddField("", sMessage, true);

	hook.Embed(Embed);
	hook.Send();
	delete hook;
}

public int Native_SendCallAdmin(Handle plugin, int numParams)
{

}

public int Native_SendAnnouncement(Handle plugin, int numParams)
{

}

public int Native_SendAnnouncementBonus(Handle plugin, int numParams)
{

}
