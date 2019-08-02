public int Native_DiscordBot_StartTimer(Handle plugin, int numParams) {
	DiscordBot bot = GetNativeCell(1);
	DiscordChannel channel = GetNativeCell(2);
	Function func = GetNativeCell(3);
	
	Handle hObj = json_object();
	json_object_set(hObj, "bot", bot);
	json_object_set(hObj, "channel", channel);
	
	Handle fwd = CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
	AddToForward(fwd, plugin, func);
	
	json_object_set_new(hObj, "callback", json_integer(view_as<int>(fwd)));
	
	GetMessages(hObj);
}

public void GetMessages(Handle hObject) {
	DiscordBot bot = view_as<DiscordBot>(json_object_get(hObject, "bot"));
	DiscordChannel channel = view_as<DiscordChannel>(json_object_get(hObject, "channel"));
	//Handle fwd = view_as<Handle>(json_object_get(hObject, "callback"));
	
	char channelID[32];
	channel.GetID(channelID, sizeof(channelID));
	
	char lastMessage[64];
	channel.GetLastMessageID(lastMessage, sizeof(lastMessage));
	
	char url[256];
	FormatEx(url, sizeof(url), "channels/%s/messages?limit=%i&after=%s", channelID, 100, lastMessage);
	
	Handle request = PrepareRequest(bot, url, _, null, OnGetMessage);
	if(request == null) {
		delete bot;
		delete channel;
		CreateTimer(2.0, GetMessagesDelayed, hObject);
		return;
	}
	
	char route[128];
	FormatEx(route, sizeof(route), "channels/%s", channelID);
	
	SteamWorks_SetHTTPRequestContextValue(request, hObject, UrlToDP(route));
	
	delete bot;
	delete channel;
	
	DiscordSendRequest(request, route);
}

public Action GetMessagesDelayed(Handle timer, any data) {
	GetMessages(view_as<Handle>(data));
}

public Action CheckMessageTimer(Handle timer, any dpt) {
	GetMessages(view_as<Handle>(dpt));
}

public int OnGetMessage(Handle request, bool failure, int offset, int statuscode, any dp) {
	if(failure || statuscode != 200) {
		if(statuscode == 429 || statuscode == 500) {
			GetMessages(view_as<Handle>(dp));
			delete request;
			return;
		}
		LogError("[DISCORD] Couldn't Retrieve Messages - Fail %i %i", failure, statuscode);
		delete request;
		Handle fwd = view_as<Handle>(JsonObjectGetInt(view_as<Handle>(dp), "callback"));
		if(fwd != null) delete fwd;
		delete view_as<Handle>(dp);
		return;
	}

	SteamWorks_GetHTTPResponseBodyCallback(request, OnGetMessage_Data, dp);
	delete request;
}

public int OnGetMessage_Data(const char[] data, any dpt) {
	Handle hObj = view_as<Handle>(dpt);
	
	DiscordBot Bot = view_as<DiscordBot>(json_object_get(hObj, "bot"));
	DiscordChannel channel = view_as<DiscordChannel>(json_object_get(hObj, "channel"));
	Handle fwd = view_as<Handle>(JsonObjectGetInt(hObj, "callback"));
	
	if(!Bot.IsListeningToChannel(channel) || GetForwardFunctionCount(fwd) == 0) {
		delete Bot;
		delete channel;
		delete hObj;
		delete fwd;
		return;
	}
	
	Handle hJson = json_load(data);
	
	if(json_is_array(hJson)) {
		for(int i = json_array_size(hJson) - 1; i >= 0; i--) {
			Handle hObject = json_array_get(hJson, i);
			
			//The reason we find Channel for each message instead of global incase
			//Bot stops listening for the channel while we are still sending messages
			char channelID[32];
			JsonObjectGetString(hObject, "channel_id", channelID, sizeof(channelID));
			
			//Find Channel corresponding to Channel id
			//DiscordChannel Channel = Bot.GetListeningChannelByID(channelID);
			if(!Bot.IsListeningToChannelID(channelID)) {
				//Channel is no longer listed to, remove any handles & stop
				delete hObject;
				delete hJson;
				
				delete fwd;
				delete Bot;
				delete channel;
				delete hObj;
				return;
			}
			
			char id[32];
			JsonObjectGetString(hObject, "id", id, sizeof(id));
			
			if(i == 0) {
				channel.SetLastMessageID(id);
			}
			
			//Get info and fire forward
			if(fwd != null) {
				Call_StartForward(fwd);
				Call_PushCell(Bot);
				Call_PushCell(channel);
				Call_PushCell(view_as<DiscordMessage>(hObject));
				Call_Finish();
			}
			
			delete hObject;
		}
	}
	
	CreateTimer(Bot.MessageCheckInterval, CheckMessageTimer, hObj);
	
	delete Bot;
	delete channel;
	
	
	delete hJson;
}