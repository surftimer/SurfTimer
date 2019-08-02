public int Native_DiscordMessage_GetID(Handle plugin, int numParams) {
	Handle hJson = GetNativeCell(1);
	char buffer[64];
	JsonObjectGetString(hJson, "id", buffer, sizeof(buffer));
	SetNativeString(2, buffer, GetNativeCell(3));
}

public int Native_DiscordMessage_IsPinned(Handle plugin, int numParams) {
	Handle hJson = GetNativeCell(1);
	return JsonObjectGetBool(hJson, "pinned");
}

public int Native_DiscordMessage_GetAuthor(Handle plugin, int numParams) {
	Handle hJson = GetNativeCell(1);
	
	Handle hAuthor = json_object_get(hJson, "author");
	
	DiscordUser user = view_as<DiscordUser>(CloneHandle(hAuthor, plugin));
	delete hAuthor;
	
	return _:user;
}

public int Native_DiscordMessage_GetContent(Handle plugin, int numParams) {
	Handle hJson = GetNativeCell(1);
	static char buffer[2000];
	JsonObjectGetString(hJson, "content", buffer, sizeof(buffer));
	SetNativeString(2, buffer, GetNativeCell(3));
}

public int Native_DiscordMessage_GetChannelID(Handle plugin, int numParams) {
	Handle hJson = GetNativeCell(1);
	char buffer[64];
	JsonObjectGetString(hJson, "channel_id", buffer, sizeof(buffer));
	SetNativeString(2, buffer, GetNativeCell(3));
}