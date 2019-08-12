public int Native_DiscordBot_GetGuildRoles(Handle plugin, int numParams) {
	DiscordBot bot = view_as<DiscordBot>(CloneHandle(GetNativeCell(1)));
	
	char guild[32];
	GetNativeString(2, guild, sizeof(guild));
	
	Function fCallback = GetNativeCell(3);
	
	any data = GetNativeCell(4);
	
	Handle hData = json_object();
	json_object_set_new(hData, "bot", bot);
	json_object_set_new(hData, "guild", json_string(guild));
	json_object_set_new(hData, "data1", json_integer(view_as<int>(data)));
	
	Handle fwd = CreateForward(ET_Ignore, Param_Cell, Param_String, Param_Cell, Param_Cell);
	AddToForward(fwd, plugin, fCallback);
	json_object_set_new(hData, "callback", json_integer(view_as<int>(fwd)));
	
	GetGuildRoles(hData);
}

static void GetGuildRoles(Handle hData) {
	DiscordBot bot = view_as<DiscordBot>(json_object_get(hData, "bot"));
	
	char guild[32];
	JsonObjectGetString(hData, "guild", guild, sizeof(guild));
	
	
	char url[256];
	FormatEx(url, sizeof(url), "https://discordapp.com/api/guilds/%s/roles", guild);
	
	char route[128];
	FormatEx(route, sizeof(route), "guild/%s/roles", guild);
	
	DiscordRequest request = new DiscordRequest(url, k_EHTTPMethodGET);
	if(request == null) {
		delete bot;
		CreateTimer(2.0, SendGetGuildRoles, hData);
		return;
	}
	request.SetCallbacks(HTTPCompleted, GetGuildRolesReceive);
	request.SetBot(bot);
	request.SetData(hData, route);
	
	request.Send(route);
	
	delete bot;
}

public Action SendGetGuildRoles(Handle timer, any data) {
	GetGuildRoles(view_as<Handle>(data));
}


public GetGuildRolesReceive(Handle request, bool failure, int offset, int statuscode, any dp) {
	if(failure || (statuscode != 200)) {
		if(statuscode == 400) {
			PrintToServer("BAD REQUEST");
		}
		
		if(statuscode == 429 || statuscode == 500) {
			GetGuildRoles(dp);
			
			delete request;
			return;
		}
		LogError("[DISCORD] Couldn't Send GetGuildRoles - Fail %i %i", failure, statuscode);
		delete request;
		delete view_as<Handle>(dp);
		return;
	}
	SteamWorks_GetHTTPResponseBodyCallback(request, GetRolesData, dp);
	delete request;
}

public int GetRolesData(const char[] data, any dp) {
	Handle hJson = json_load(data);
	Handle hData = view_as<Handle>(dp);
	DiscordBot bot = view_as<DiscordBot>(json_object_get(hData, "bot"));
	
	Handle fwd = view_as<Handle>(JsonObjectGetInt(hData, "callback"));
	
	char guild[32];
	JsonObjectGetString(hData, "guild", guild, sizeof(guild));
	
	any data1 = JsonObjectGetInt(hData, "data1");
	
	if(fwd != null) {
		Call_StartForward(fwd);
		Call_PushCell(bot);
		Call_PushString(guild);
		Call_PushCell(view_as<RoleList>(hJson));
		Call_PushCell(data1);
		Call_Finish();
	}
	
	delete bot;
	delete hJson;
	delete hData;
	delete fwd;
}