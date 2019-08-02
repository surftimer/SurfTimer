#pragma semicolon 1

#define PLUGIN_VERSION "0.1.103"

#include <sourcemod>
#include <discord>
#include <SteamWorks>
#include <smjansson>

#include "discord/DiscordRequest.sp"
#include "discord/SendMessage.sp"
#include "discord/GetGuilds.sp"
#include "discord/GetGuildChannels.sp"
#include "discord/ListenToChannel.sp"
#include "discord/SendWebHook.sp"
#include "discord/reactions.sp"
#include "discord/UserObject.sp"
#include "discord/MessageObject.sp"
#include "discord/GuildMembers.sp"
#include "discord/GuildRole.sp"
#include "discord/deletemessage.sp"

//For rate limitation
Handle hRateLimit = null;
Handle hRateReset = null;
Handle hRateLeft = null;

public Plugin myinfo =  {
	name = "Discord API",
	author = "Deathknife",
	description = "",
	version = PLUGIN_VERSION,
	url = ""
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
	CreateNative("DiscordBot.GetToken", Native_DiscordBot_Token_Get);
	
	//SendMessage.sp
	CreateNative("DiscordBot.SendMessage", Native_DiscordBot_SendMessage);
	CreateNative("DiscordBot.SendMessageToChannelID", Native_DiscordBot_SendMessageToChannel);
	CreateNative("DiscordChannel.SendMessage", Native_DiscordChannel_SendMessage);
	
	//deletemessage.sp
	CreateNative("DiscordBot.DeleteMessageID", Native_DiscordBot_DeleteMessageID);
	CreateNative("DiscordBot.DeleteMessage", Native_DiscordBot_DeleteMessage);
	
	//ListenToChannel.sp
	CreateNative("DiscordBot.StartTimer", Native_DiscordBot_StartTimer);
	
	//GetGuilds.sp
	CreateNative("DiscordBot.GetGuilds", Native_DiscordBot_GetGuilds);
	//GetGuildChannels.sp
	CreateNative("DiscordBot.GetGuildChannels", Native_DiscordBot_GetGuildChannels);
	//GuildRole.sp
	CreateNative("DiscordBot.GetGuildRoles", Native_DiscordBot_GetGuildRoles);
	
	//reactions.sp
	CreateNative("DiscordBot.AddReactionID", Native_DiscordBot_AddReaction);
	CreateNative("DiscordBot.DeleteReactionID", Native_DiscordBot_DeleteReaction);
	CreateNative("DiscordBot.GetReactionID", Native_DiscordBot_GetReaction);
	
	//GuildMembers.sp
	CreateNative("DiscordBot.GetGuildMembers", Native_DiscordBot_GetGuildMembers);
	CreateNative("DiscordBot.GetGuildMembersAll", Native_DiscordBot_GetGuildMembersAll);
	
	//CreateNative("DiscordChannel.Destroy", Native_DiscordChannel_Destroy);
	
	//SendWebHook.sp
	CreateNative("DiscordWebHook.Send", Native_DiscordWebHook_Send);
	//CreateNative("DiscordWebHook.AddField", Native_DiscordWebHook_AddField);
	//CreateNative("DiscordWebHook.DeleteFields", Native_DiscordWebHook_DeleteFields);
	
	//UserObject.sp
	CreateNative("DiscordUser.GetID", Native_DiscordUser_GetID);
	CreateNative("DiscordUser.GetUsername", Native_DiscordUser_GetUsername);
	CreateNative("DiscordUser.GetDiscriminator", Native_DiscordUser_GetDiscriminator);
	CreateNative("DiscordUser.GetAvatar", Native_DiscordUser_GetAvatar);
	CreateNative("DiscordUser.IsVerified", Native_DiscordUser_IsVerified);
	CreateNative("DiscordUser.GetEmail", Native_DiscordUser_GetEmail);
	CreateNative("DiscordUser.IsBot", Native_DiscordUser_IsBot);
	
	//MessageObject.sp
	CreateNative("DiscordMessage.GetID", Native_DiscordMessage_GetID);
	CreateNative("DiscordMessage.IsPinned", Native_DiscordMessage_IsPinned);
	CreateNative("DiscordMessage.GetAuthor", Native_DiscordMessage_GetAuthor);
	CreateNative("DiscordMessage.GetContent", Native_DiscordMessage_GetContent);
	CreateNative("DiscordMessage.GetChannelID", Native_DiscordMessage_GetChannelID);
	
	RegPluginLibrary("discord-api");
	
	return APLRes_Success;
}

public void OnPluginStart() {
	hRateLeft = new StringMap();
	hRateReset = new StringMap();
	hRateLimit = new StringMap();
}

public int Native_DiscordBot_Token_Get(Handle plugin, int numParams) {
	DiscordBot bot = GetNativeCell(1);
	static char token[196];
	JsonObjectGetString(bot, "token", token, sizeof(token));
	SetNativeString(2, token, GetNativeCell(3));
}

stock void BuildAuthHeader(Handle request, DiscordBot Bot) {
	static char buffer[256];
	static char token[196];
	JsonObjectGetString(Bot, "token", token, sizeof(token));
	FormatEx(buffer, sizeof(buffer), "Bot %s", token);
	SteamWorks_SetHTTPRequestHeaderValue(request, "Authorization", buffer);
}


stock Handle PrepareRequest(DiscordBot bot, char[] url, EHTTPMethod method=k_EHTTPMethodGET, Handle hJson=null, SteamWorksHTTPDataReceived DataReceived = INVALID_FUNCTION, SteamWorksHTTPRequestCompleted RequestCompleted = INVALID_FUNCTION) {
	static char stringJson[16384];
	stringJson[0] = '\0';
	if(hJson != null) {
		json_dump(hJson, stringJson, sizeof(stringJson), 0, true);
	}
	
	//Format url
	static char turl[128];
	FormatEx(turl, sizeof(turl), "https://discordapp.com/api/%s", url);
	
	Handle request = SteamWorks_CreateHTTPRequest(method, turl);
	if(request == null) {
		return null;
	}
	
	if(bot != null) {
		BuildAuthHeader(request, bot);
	}
	
	SteamWorks_SetHTTPRequestRawPostBody(request, "application/json; charset=UTF-8", stringJson, strlen(stringJson));
	
	SteamWorks_SetHTTPRequestNetworkActivityTimeout(request, 30);
	
	if(RequestCompleted == INVALID_FUNCTION) {
		//I had some bugs previously where it wouldn't send request and return code 0 if I didn't set request completed.
		//This is just a safety then, my issue could have been something else and I will test more later on
		RequestCompleted = HTTPCompleted;
	}
	
	if(DataReceived == INVALID_FUNCTION) {
		//Need to close the request handle
		DataReceived = HTTPDataReceive;
	}
	
	SteamWorks_SetHTTPCallbacks(request, RequestCompleted, HeadersReceived, DataReceived);
	if(hJson != null) delete hJson;
	
	return request;
}

stock Handle PrepareRequestRaw(DiscordBot bot, char[] url, EHTTPMethod method=k_EHTTPMethodGET, Handle hJson=null, SteamWorksHTTPDataReceived DataReceived = INVALID_FUNCTION, SteamWorksHTTPRequestCompleted RequestCompleted = INVALID_FUNCTION) {
	static char stringJson[16384];
	stringJson[0] = '\0';
	if(hJson != null) {
		json_dump(hJson, stringJson, sizeof(stringJson), 0, true);
	}
	
	Handle request = SteamWorks_CreateHTTPRequest(method, url);
	if(request == null) {
		return null;
	}
	
	if(bot != null) {
		BuildAuthHeader(request, bot);
	}
	
	SteamWorks_SetHTTPRequestRawPostBody(request, "application/json; charset=UTF-8", stringJson, strlen(stringJson));
	
	SteamWorks_SetHTTPRequestNetworkActivityTimeout(request, 30);
	
	if(RequestCompleted == INVALID_FUNCTION) {
		//I had some bugs previously where it wouldn't send request and return code 0 if I didn't set request completed.
		//This is just a safety then, my issue could have been something else and I will test more later on
		RequestCompleted = HTTPCompleted;
	}
	
	if(DataReceived == INVALID_FUNCTION) {
		//Need to close the request handle
		DataReceived = HTTPDataReceive;
	}
	
	SteamWorks_SetHTTPCallbacks(request, RequestCompleted, HeadersReceived, DataReceived);
	if(hJson != null) delete hJson;
	
	return request;
}

public int HTTPCompleted(Handle request, bool failure, bool requestSuccessful, EHTTPStatusCode statuscode, any data, any data2) {
}

public int HTTPDataReceive(Handle request, bool failure, int offset, int statuscode, any dp) {
	delete request;
}

public int HeadersReceived(Handle request, bool failure, any data, any datapack) {
	DataPack dp = view_as<DataPack>(datapack);
	if(failure) {
		delete dp;
		return;
	}
	
	char xRateLimit[16];
	char xRateLeft[16];
	char xRateReset[32];
	
	bool exists = false;
	
	exists = SteamWorks_GetHTTPResponseHeaderValue(request, "X-RateLimit-Limit", xRateLimit, sizeof(xRateLimit));
	exists = SteamWorks_GetHTTPResponseHeaderValue(request, "X-RateLimit-Remaining", xRateLeft, sizeof(xRateLeft));
	exists = SteamWorks_GetHTTPResponseHeaderValue(request, "X-RateLimit-Reset", xRateReset, sizeof(xRateReset));
	
	//Get url
	char route[128];
	ResetPack(dp);
	ReadPackString(dp, route, sizeof(route));
	delete dp;
	
	int reset = StringToInt(xRateReset);
	if(reset > GetTime() + 3) {
		reset = GetTime() + 3;
	}
	
	if(exists) {
		SetTrieValue(hRateReset, route, reset);
		SetTrieValue(hRateLeft, route, StringToInt(xRateLeft));
		SetTrieValue(hRateLimit, route, StringToInt(xRateLimit));
	}else {
		SetTrieValue(hRateReset, route, -1);
		SetTrieValue(hRateLeft, route, -1);
		SetTrieValue(hRateLimit, route, -1);
	}
}

/*
This is rate limit imposing for per-route basis. Doesn't support global limit yet.
 */
public void DiscordSendRequest(Handle request, const char[] route) {
	//Check for reset
	int time = GetTime();
	int resetTime;
	
	int defLimit = 0;
	if(!GetTrieValue(hRateLimit, route, defLimit)) {
		defLimit = 1;
	}
	
	bool exists = GetTrieValue(hRateReset, route, resetTime);
	
	if(!exists) {
		SetTrieValue(hRateReset, route, GetTime() + 5);
		SetTrieValue(hRateLeft, route, defLimit - 1);
		SteamWorks_SendHTTPRequest(request);
		return;
	}
	
	if(time == -1) {
		//No x-rate-limit send
		SteamWorks_SendHTTPRequest(request);
		return;
	}
	
	if(time > resetTime) {
		SetTrieValue(hRateLeft, route, defLimit - 1);
		SteamWorks_SendHTTPRequest(request);
		return;
	}else {
		int left;
		GetTrieValue(hRateLeft, route, left);
		if(left == 0) {
			float remaining = float(resetTime) - float(time) + 1.0;
			Handle dp = new DataPack();
			WritePackCell(dp, request);
			WritePackString(dp, route);
			CreateTimer(remaining, SendRequestAgain, dp);
		}else {
			left--;
			SetTrieValue(hRateLeft, route, left);
			SteamWorks_SendHTTPRequest(request);
		}
	}
}

public Handle UrlToDP(char[] url) {
	DataPack dp = new DataPack();
	WritePackString(dp, url);
	return dp;
}

public Action SendRequestAgain(Handle timer, any dp) {
	ResetPack(dp);
	Handle request = ReadPackCell(dp);
	char route[128];
	ReadPackString(dp, route, sizeof(route));
	delete view_as<Handle>(dp);
	DiscordSendRequest(request, route);
}

stock bool RenameJsonObject(Handle hJson, char[] key, char[] toKey) {
	Handle hObject = json_object_get(hJson, key);
	if(hObject != null) {
		json_object_set_new(hJson, toKey, hObject);
		json_object_del(hJson, key);
		return true;
	}
	return false;
}