public int Native_DiscordBot_DeleteMessageID(Handle plugin, int numParams) {
	DiscordBot bot = GetNativeCell(1);
	
	char channelid[64];
	GetNativeString(2, channelid, sizeof(channelid));
	
	char msgid[64];
	GetNativeString(3, msgid, sizeof(msgid));
	
	Function fCallback = GetNativeCell(4);
	any data = GetNativeCell(5);
	
	DataPack dp = CreateDataPack();
	WritePackCell(dp, bot);
	WritePackString(dp, channelid);
	WritePackString(dp, msgid);
	WritePackCell(dp, plugin);
	WritePackFunction(dp, fCallback);
	WritePackCell(dp, data);
	
	ThisDeleteMessage(bot, channelid, msgid, dp);
}

public int Native_DiscordBot_DeleteMessage(Handle plugin, int numParams) {
	DiscordBot bot = GetNativeCell(1);
	
	char channelid[64];
	DiscordChannel channel = GetNativeCell(2);
	channel.GetID(channelid, sizeof(channelid));
	
	char msgid[64];
	DiscordMessage msg = GetNativeCell(3);
	msg.GetID(msgid, sizeof(msgid));
	
	Function fCallback = GetNativeCell(4);
	any data = GetNativeCell(5);
	
	DataPack dp = CreateDataPack();
	WritePackCell(dp, bot);
	WritePackString(dp, channelid);
	WritePackString(dp, msgid);
	WritePackCell(dp, plugin);
	WritePackFunction(dp, fCallback);
	WritePackCell(dp, data);
	
	ThisDeleteMessage(bot, channelid, msgid, dp);
}

static void ThisDeleteMessage(DiscordBot bot, char[] channelid, char[] msgid, DataPack dp) {
	char url[64];
	FormatEx(url, sizeof(url), "channels/%s/messages/%s", channelid, msgid);
	
	Handle request = PrepareRequest(bot, url, k_EHTTPMethodDELETE, null, MessageDeletedResp);
	if(request == null) {
		CreateTimer(2.0, ThisDeleteMessageDelayed, dp);
		return;
	}
	
	SteamWorks_SetHTTPRequestContextValue(request, dp, UrlToDP(url));
	
	DiscordSendRequest(request, url);
}

public Action ThisDeleteMessageDelayed(Handle timer, any data) {
	DataPack dp = view_as<DataPack>(data);
	ResetPack(dp);
	
	DiscordBot bot = ReadPackCell(dp);
	
	char channelid[32];
	ReadPackString(dp, channelid, sizeof(channelid));
	
	char msgid[32];
	ReadPackString(dp, msgid, sizeof(msgid));
	
	ThisDeleteMessage(bot, channelid, msgid, dp);
}

public int MessageDeletedResp(Handle request, bool failure, int offset, int statuscode, any dp) {
	if(failure || statuscode != 204) {
		if(statuscode == 429 || statuscode == 500) {
			ResetPack(dp);
			DiscordBot bot = ReadPackCell(dp);
			
			char channelid[32];
			ReadPackString(dp, channelid, sizeof(channelid));
			
			char msgid[32];
			ReadPackString(dp, msgid, sizeof(msgid));
			
			ThisDeleteMessage(bot, channelid, msgid, view_as<DataPack>(dp));
			
			delete request;
			return;
		}
		LogError("[DISCORD] Couldn't delete message - Fail %i %i", failure, statuscode);
		delete request;
		delete view_as<Handle>(dp);
		return;
	}
	
	ResetPack(dp);
	DiscordBot bot = ReadPackCell(dp);
	
	char channelid[32];
	ReadPackString(dp, channelid, sizeof(channelid));
	
	char msgid[32];
	ReadPackString(dp, msgid, sizeof(msgid));
	
	Handle plugin = view_as<Handle>(ReadPackCell(dp));
	Function func = ReadPackFunction(dp);
	any pluginData = ReadPackCell(dp);
	
	Handle fForward = INVALID_HANDLE;
	if(func != INVALID_FUNCTION) {
		fForward = CreateForward(ET_Ignore, Param_Cell, Param_Cell);
		AddToForward(fForward, plugin, func);
		
		Call_StartForward(fForward);
		Call_PushCell(bot);
		Call_PushCell(pluginData);
		Call_Finish();
		delete fForward;
	}
	
	delete view_as<Handle>(dp);
	delete request;
}