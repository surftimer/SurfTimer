public int Native_DiscordBot_SendMessageToChannel(Handle plugin, int numParams) {
	DiscordBot bot = GetNativeCell(1);
	char channel[32];
	static char message[2048];
	GetNativeString(2, channel, sizeof(channel));
	GetNativeString(3, message, sizeof(message));
	
	Function fCallback = GetNativeCell(4);
	any data = GetNativeCell(5);
	Handle fForward = null;
	if(fCallback != INVALID_FUNCTION) {
		fForward = CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell, Param_Cell);
		AddToForward(fForward, plugin, fCallback);
	}
	
	SendMessage(bot, channel, message, fForward, data);
}

public int Native_DiscordBot_SendMessage(Handle plugin, int numParams) {
	DiscordBot bot = GetNativeCell(1);
	
	DiscordChannel Channel = GetNativeCell(2);
	char channelID[32];
	Channel.GetID(channelID, sizeof(channelID));
	
	static char message[2048];
	GetNativeString(3, message, sizeof(message));
	
	Function fCallback = GetNativeCell(4);
	any data = GetNativeCell(5);
	Handle fForward = null;
	if(fCallback != INVALID_FUNCTION) {
		fForward = CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell, Param_Cell);
		AddToForward(fForward, plugin, fCallback);
	}
	
	SendMessage(bot, channelID, message, fForward, data);
}

public int Native_DiscordChannel_SendMessage(Handle plugin, int numParams) {
	DiscordChannel channel = view_as<DiscordChannel>(GetNativeCell(1));
	
	char channelID[32];
	channel.GetID(channelID, sizeof(channelID));
	
	DiscordBot bot = GetNativeCell(2);
	
	static char message[2048];
	GetNativeString(3, message, sizeof(message));
	
	Function fCallback = GetNativeCell(4);
	any data = GetNativeCell(5);
	Handle fForward = null;
	if(fCallback != INVALID_FUNCTION) {
		fForward = CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell, Param_Cell);
		AddToForward(fForward, plugin, fCallback);
	}
	
	SendMessage(bot, channelID, message, fForward, data);
}

static void SendMessage(DiscordBot bot, char[] channel, char[] message, Handle fForward, any data) {
	Handle hJson = json_object();
	
	json_object_set_new(hJson, "content", json_string(message));
	
	char url[64];
	FormatEx(url, sizeof(url), "channels/%s/messages", channel);
	
	DataPack dpSafety = new DataPack();
	WritePackCell(dpSafety, bot);
	WritePackString(dpSafety, channel);
	WritePackString(dpSafety, message);
	WritePackCell(dpSafety, fForward);
	WritePackCell(dpSafety, data);
	
	Handle request = PrepareRequest(bot, url, k_EHTTPMethodPOST, hJson, GetSendMessageData);
	if(request == null) {
		delete hJson;
		CreateTimer(2.0, SendMessageDelayed, dpSafety);
		return;
	}
	
	SteamWorks_SetHTTPRequestContextValue(request, dpSafety, UrlToDP(url));
	
	DiscordSendRequest(request, url);
}

public Action SendMessageDelayed(Handle timer, any data) {
	DataPack dp = view_as<DataPack>(data);
	ResetPack(dp);
	
	DiscordBot bot = ReadPackCell(dp);
	
	char channel[32];
	ReadPackString(dp, channel, sizeof(channel));
	
	char message[2048];
	ReadPackString(dp, message, sizeof(message));
	
	Handle fForward = ReadPackCell(dp);
	any dataa = ReadPackCell(dp);
	
	delete dp;
	
	SendMessage(bot, channel, message, fForward, dataa);
}

public int GetSendMessageData(Handle request, bool failure, int offset, int statuscode, any dp) {
	if(failure || statuscode != 200) {
		if(statuscode == 429 || statuscode == 500) {
			ResetPack(dp);
			DiscordBot bot = ReadPackCell(dp);
			
			char channel[32];
			ReadPackString(dp, channel, sizeof(channel));
			
			char message[2048];
			ReadPackString(dp, message, sizeof(message));
			
			Handle fForward = ReadPackCell(dp);
			any data = ReadPackCell(dp);
	
			delete view_as<Handle>(dp);
			
			SendMessage(bot, channel, message, fForward, data);
			
			delete request;
			return;
		}
		LogError("[DISCORD] Couldn't Send Message - Fail %i %i", failure, statuscode);
		delete request;
		delete view_as<Handle>(dp);
		return;
	}
	delete request;
	delete view_as<Handle>(dp);
}