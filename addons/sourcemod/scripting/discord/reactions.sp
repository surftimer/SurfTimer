public int Native_DiscordBot_AddReaction(Handle plugin, int numParams) {
	DiscordBot bot = GetNativeCell(1);
	
	char channel[32];
	GetNativeString(2, channel, sizeof(channel));
	
	char msgid[64];
	GetNativeString(3, msgid, sizeof(msgid));
	
	char emoji[128];
	GetNativeString(4, emoji, sizeof(emoji));
	
	AddReaction(bot, channel, msgid, emoji);
}

public int Native_DiscordBot_DeleteReaction(Handle plugin, int numParams) {
	DiscordBot bot = GetNativeCell(1);
	
	char channel[32];
	GetNativeString(2, channel, sizeof(channel));
	
	char msgid[64];
	GetNativeString(3, msgid, sizeof(msgid));
	
	char emoji[128];
	GetNativeString(4, emoji, sizeof(emoji));
	
	char user[128];
	GetNativeString(5, user, sizeof(user));
	
	DeleteReaction(bot, channel, msgid, emoji, user);
}

public int Native_DiscordBot_GetReaction(Handle plugin, int numParams) {
	DiscordBot bot = GetNativeCell(1);
	
	char channel[32];
	GetNativeString(2, channel, sizeof(channel));
	
	char msgid[64];
	GetNativeString(3, msgid, sizeof(msgid));
	
	char emoji[128];
	GetNativeString(4, emoji, sizeof(emoji));
	
	OnGetReactions fCallback = GetNativeCell(5);
	Handle fForward = null;
	if(fCallback != INVALID_FUNCTION) {
		fForward = CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_String, Param_String, Param_String, Param_String, Param_Cell);
		AddToForward(fForward, plugin, fCallback);
	}
	
	any data = GetNativeCell(6);
	
	GetReaction(bot, channel, msgid, emoji, fForward, data);
}

///channels/{channel.id}/messages/{message.id}/reactions/{emoji}/@me
public void AddReaction(DiscordBot bot, char[] channel, char[] messageid, char[] emoji) {
	char url[256];
	FormatEx(url, sizeof(url), "channels/%s/messages/%s/reactions/%s/@me", channel, messageid, emoji);
	
	Handle request = PrepareRequest(bot, url, k_EHTTPMethodPUT, null, AddReactionReceiveData);
	
	DataPack dp = new DataPack();
	WritePackCell(dp, bot);
	WritePackString(dp, channel);
	WritePackString(dp, messageid);
	WritePackString(dp, emoji);
	
	if(request == dp) {
		CreateTimer(2.0, AddReactionDelayed, dp);
		return;
	}
	
	char route[128];
	FormatEx(route, sizeof(route), "channels/%s/messages/msgid/reactions", channel);
	
	SteamWorks_SetHTTPRequestContextValue(request, dp, UrlToDP(route));
	
	DiscordSendRequest(request, url);
}

public Action AddReactionDelayed(Handle timer, any data) {
	DataPack dp = view_as<DataPack>(data);
	
	DiscordBot bot = ReadPackCell(dp);
	char channel[64];
	char messageid[64];
	char emoji[64];
	ReadPackString(dp, channel, sizeof(channel));
	ReadPackString(dp, messageid, sizeof(messageid));
	ReadPackString(dp, emoji, sizeof(emoji));
	delete dp;
	
	AddReaction(bot, channel, messageid, emoji);
}

public AddReactionReceiveData(Handle request, bool failure, int offset, int statuscode, any data) {
	if(failure || statuscode != 204) {
		if(statuscode == 429 || statuscode == 500) {
			
			DataPack dp = view_as<DataPack>(data);
	
			DiscordBot bot = ReadPackCell(dp);
			char channel[64];
			char messageid[64];
			char emoji[64];
			ReadPackString(dp, channel, sizeof(channel));
			ReadPackString(dp, messageid, sizeof(messageid));
			ReadPackString(dp, emoji, sizeof(emoji));
			delete dp;
			
			AddReaction(bot, channel, messageid, emoji);
			
			delete request;
			return;
		}
		LogError("[DISCORD] Couldn't Add Reaction - Fail %i %i", failure, statuscode);
		delete request;
		delete view_as<Handle>(data);
		delete view_as<Handle>(data);
		return;
	}
	delete request;
	delete view_as<Handle>(data);
}

///channels/{channel.id}/messages/{message.id}/reactions/{emoji}/{user.id}
public void DeleteReaction(DiscordBot bot, char[] channel, char[] messageid, char[] emoji, char[] userid) {
	char url[256];
	
	if(StrEqual(userid, "@all")) {
		FormatEx(url, sizeof(url), "channels/%s/messages/%s/reactions/%s", channel, messageid, emoji);
	}else {
		FormatEx(url, sizeof(url), "channels/%s/messages/%s/reactions/%s/%s", channel, messageid, emoji, userid);
	}
	
	Handle request = PrepareRequest(bot, url, k_EHTTPMethodDELETE, null, DeleteReactionReceiveData);
	
	DataPack dp = new DataPack();
	WritePackCell(dp, bot);
	WritePackString(dp, channel);
	WritePackString(dp, messageid);
	WritePackString(dp, emoji);
	WritePackString(dp, userid);
	
	if(request == dp) {
		CreateTimer(2.0, DeleteReactionDelayed, dp);
		return;
	}
	
	char route[128];
	FormatEx(route, sizeof(route), "channels/%s/messages/msgid/reactions", channel);
	
	SteamWorks_SetHTTPRequestContextValue(request, dp, UrlToDP(route));
	
	DiscordSendRequest(request, url);
}

public Action DeleteReactionDelayed(Handle timer, any data) {
	DataPack dp = view_as<DataPack>(data);
	
	DiscordBot bot = ReadPackCell(dp);
	char channel[64];
	char messageid[64];
	char emoji[64];
	char userid[64];
	ReadPackString(dp, channel, sizeof(channel));
	ReadPackString(dp, messageid, sizeof(messageid));
	ReadPackString(dp, emoji, sizeof(emoji));
	ReadPackString(dp, userid, sizeof(userid));
	delete dp;
	
	DeleteReaction(bot, channel, messageid, emoji, userid);
}

public DeleteReactionReceiveData(Handle request, bool failure, int offset, int statuscode, any data) {
	if(failure || statuscode != 204) {
		if(statuscode == 429 || statuscode == 500) {
			
			DataPack dp = view_as<DataPack>(data);
	
			DiscordBot bot = ReadPackCell(dp);
			char channel[64];
			char messageid[64];
			char emoji[64];
			char userid[64];
			ReadPackString(dp, channel, sizeof(channel));
			ReadPackString(dp, messageid, sizeof(messageid));
			ReadPackString(dp, emoji, sizeof(emoji));
			ReadPackString(dp, userid, sizeof(userid));
			delete dp;
			
			DeleteReaction(bot, channel, messageid, emoji, userid);
			
			delete request;
			return;
		}
		LogError("[DISCORD] Couldn't Delete Reaction - Fail %i %i", failure, statuscode);
		delete request;
		delete view_as<Handle>(data);
		return;
	}
	delete request;
	delete view_as<Handle>(data);
}

public void GetReaction(DiscordBot bot, char[] channel, char[] messageid, char[] emoji, Handle fForward, any data) {
	char url[256];
	FormatEx(url, sizeof(url), "channels/%s/messages/%s/reactions/%s", channel, messageid, emoji);
	
	Handle request = PrepareRequest(bot, url, k_EHTTPMethodGET, null, GetReactionReceiveData);
	
	DataPack dp = new DataPack();
	WritePackCell(dp, bot);
	WritePackString(dp, channel);
	WritePackString(dp, messageid);
	WritePackString(dp, emoji);
	WritePackCell(dp, fForward);
	WritePackCell(dp, data);
	
	if(request == dp) {
		CreateTimer(2.0, GetReactionDelayed, dp);
		return;
	}
	
	char route[128];
	FormatEx(route, sizeof(route), "channels/%s/messages/msgid/reactions", channel);
	
	SteamWorks_SetHTTPRequestContextValue(request, dp, UrlToDP(route));
	
	DiscordSendRequest(request, url);
}

public Action GetReactionDelayed(Handle timer, any data) {
	DataPack dp = view_as<DataPack>(data);
	
	DiscordBot bot = ReadPackCell(dp);
	char channel[64];
	char messageid[64];
	char emoji[64];
	ReadPackString(dp, channel, sizeof(channel));
	ReadPackString(dp, messageid, sizeof(messageid));
	ReadPackString(dp, emoji, sizeof(emoji));
	Handle fForward = ReadPackCell(dp);
	any addData = ReadPackCell(dp);
	delete dp;
	
	GetReaction(bot, channel, messageid, emoji, fForward, addData);
}

public GetReactionReceiveData(Handle request, bool failure, int offset, int statuscode, any data) {
	if(failure || statuscode != 204) {
		if(statuscode == 429 || statuscode == 500) {
			
			DataPack dp = view_as<DataPack>(data);
	
			DiscordBot bot = ReadPackCell(dp);
			char channel[64];
			char messageid[64];
			char emoji[64];
			ReadPackString(dp, channel, sizeof(channel));
			ReadPackString(dp, messageid, sizeof(messageid));
			ReadPackString(dp, emoji, sizeof(emoji));
			Handle fForward = ReadPackCell(dp);
			any addData = ReadPackCell(dp);
			delete dp;
			
			GetReaction(bot, channel, messageid, emoji, fForward, addData);
			
			delete request;
			return;
		}
		LogError("[DISCORD] Couldn't Delete Reaction - Fail %i %i", failure, statuscode);
		delete request;
		delete view_as<Handle>(data);
		return;
	}
	
	SteamWorks_GetHTTPResponseBodyCallback(request, GetReactionsData, data);
	
	delete request;
}

public int GetReactionsData(const char[] data, any datapack) {
	DataPack dp = view_as<DataPack>(datapack);
	
	DiscordBot bot = ReadPackCell(dp);
	char channel[64];
	char messageid[64];
	char emoji[64];
	ReadPackString(dp, channel, sizeof(channel));
	ReadPackString(dp, messageid, sizeof(messageid));
	ReadPackString(dp, emoji, sizeof(emoji));
	Handle fForward = ReadPackCell(dp);
	any addData = ReadPackCell(dp);
	delete dp;
	
	Handle hJson = json_load(data);
	
	ArrayList alUsers = new ArrayList();
	
	if(json_is_array(hJson)) {
		for(int i = 0; i < json_array_size(hJson); i++) {
			DiscordUser user = view_as<DiscordUser>(json_array_get(hJson, i));
			alUsers.Push(user);
		}
	}
	delete hJson;
	
	if(fForward != null) {
		Call_StartForward(fForward);
		Call_PushCell(bot);
		Call_PushCell(alUsers);
		Call_PushString(channel);
		Call_PushString(messageid);
		Call_PushString(emoji);
		Call_PushCell(addData);
		Call_Finish();
	}
	
	for(int i = 0; i < alUsers.Length; i++) {
		DiscordUser user = alUsers.Get(i);
		delete user;
	}
	delete alUsers;
}