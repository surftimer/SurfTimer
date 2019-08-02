/**
 * public native void GetGuildMembers(char[] guild, OnGetMembers fCallback, char[] afterUserID="", int limit=250);
 */
public int Native_DiscordBot_GetGuildMembers(Handle plugin, int numParams) {
	DiscordBot bot = view_as<DiscordBot>(CloneHandle(GetNativeCell(1)));
	
	char guild[32];
	GetNativeString(2, guild, sizeof(guild));
	
	Function fCallback = GetNativeCell(3);
	
	int limit = GetNativeCell(4);
	
	char afterID[32];
	GetNativeString(5, afterID, sizeof(afterID));
	
	Handle hData = json_object();
	json_object_set_new(hData, "bot", bot);
	json_object_set_new(hData, "guild", json_string(guild));
	json_object_set_new(hData, "limit", json_integer(limit));
	json_object_set_new(hData, "afterID", json_string(afterID));
	
	Handle fwd = CreateForward(ET_Ignore, Param_Cell, Param_String, Param_Cell);
	AddToForward(fwd, plugin, fCallback);
	json_object_set_new(hData, "callback", json_integer(view_as<int>(fwd)));
	
	GetMembers(hData);
}

public int Native_DiscordBot_GetGuildMembersAll(Handle plugin, int numParams) {
	DiscordBot bot = view_as<DiscordBot>(CloneHandle(GetNativeCell(1)));
	
	char guild[32];
	GetNativeString(2, guild, sizeof(guild));
	
	Function fCallback = GetNativeCell(3);
	
	int limit = GetNativeCell(4);
	
	char afterID[32];
	GetNativeString(5, afterID, sizeof(afterID));
	
	Handle hData = json_object();
	json_object_set_new(hData, "bot", bot);
	json_object_set_new(hData, "guild", json_string(guild));
	json_object_set_new(hData, "limit", json_integer(limit));
	json_object_set_new(hData, "afterID", json_string(afterID));
	
	Handle fwd = CreateForward(ET_Ignore, Param_Cell, Param_String, Param_Cell);
	AddToForward(fwd, plugin, fCallback);
	json_object_set_new(hData, "callback", json_integer(view_as<int>(fwd)));
	
	GetMembers(hData);
}

static void GetMembers(Handle hData) {
	DiscordBot bot = view_as<DiscordBot>(json_object_get(hData, "bot"));
	
	char guild[32];
	JsonObjectGetString(hData, "guild", guild, sizeof(guild));
	
	int limit = JsonObjectGetInt(hData, "limit");
	
	char afterID[32];
	JsonObjectGetString(hData, "afterID", afterID, sizeof(afterID));
	
	char url[256];
	if(StrEqual(afterID, "")) {
		FormatEx(url, sizeof(url), "https://discordapp.com/api/guilds/%s/members?limit=%i", guild, limit);
	}else {
		FormatEx(url, sizeof(url), "https://discordapp.com/api/guilds/%s/members?limit=%i&afterID=%s", guild, limit, afterID);
	}
	
	char route[128];
	FormatEx(route, sizeof(route), "guild/%s/members", guild);
	
	DiscordRequest request = new DiscordRequest(url, k_EHTTPMethodGET);
	if(request == null) {
		delete bot;
		CreateTimer(2.0, SendGetMembers, hData);
		return;
	}
	request.SetCallbacks(HTTPCompleted, MembersDataReceive);
	request.SetBot(bot);
	request.SetData(hData, route);
	
	request.Send(route);
	
	delete bot;
}

public Action SendGetMembers(Handle timer, any data) {
	GetMembers(view_as<Handle>(data));
}


public MembersDataReceive(Handle request, bool failure, int offset, int statuscode, any dp) {
	if(failure || (statuscode != 200)) {
		if(statuscode == 400) {
			PrintToServer("BAD REQUEST");
		}
		
		if(statuscode == 429 || statuscode == 500) {
			GetMembers(dp);
			
			delete request;
			return;
		}
		LogError("[DISCORD] Couldn't Send GetMembers - Fail %i %i", failure, statuscode);
		delete request;
		delete view_as<Handle>(dp);
		return;
	}
	SteamWorks_GetHTTPResponseBodyCallback(request, GetMembersData, dp);
	delete request;
}

public int GetMembersData(const char[] data, any dp) {
	Handle hJson = json_load(data);
	Handle hData = view_as<Handle>(dp);
	DiscordBot bot = view_as<DiscordBot>(json_object_get(hData, "bot"));
	
	Handle fwd = view_as<Handle>(JsonObjectGetInt(hData, "callback"));
	
	char guild[32];
	JsonObjectGetString(hData, "guild", guild, sizeof(guild));
	
	if(fwd != null) {
		Call_StartForward(fwd);
		Call_PushCell(bot);
		Call_PushString(guild);
		Call_PushCell(hJson);
		Call_Finish();
	}
	
	delete bot;
	if(JsonObjectGetBool(hData, "autoPaginate")) {
		int size = json_array_size(hJson);
		int limit = JsonObjectGetInt(hData, "limit");
		if(limit == size) {
			Handle hLast = json_array_get(hJson, size - 1);
			char lastID[32];
			json_string_value(hLast, lastID, sizeof(lastID));
			delete hJson;
			delete hLast;
			
			json_object_set_new(hData, "afterID", json_string(lastID));
			GetMembers(hData);
			return;
		}
	}
	
	delete hJson;
	delete hData;
	delete fwd;
}