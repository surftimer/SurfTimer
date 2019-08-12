public int Native_DiscordUser_GetID(Handle plugin, int numParams) {
	Handle hJson = GetNativeCell(1);
	char buffer[64];
	JsonObjectGetString(hJson, "id", buffer, sizeof(buffer));
	SetNativeString(2, buffer, GetNativeCell(3));
}

public int Native_DiscordUser_GetUsername(Handle plugin, int numParams) {
	Handle hJson = GetNativeCell(1);
	char buffer[64];
	JsonObjectGetString(hJson, "username", buffer, sizeof(buffer));
	SetNativeString(2, buffer, GetNativeCell(3));
}

public int Native_DiscordUser_GetDiscriminator(Handle plugin, int numParams) {
	Handle hJson = GetNativeCell(1);
	char buffer[16];
	JsonObjectGetString(hJson, "discriminator", buffer, sizeof(buffer));
	SetNativeString(2, buffer, GetNativeCell(3));
}

public int Native_DiscordUser_GetAvatar(Handle plugin, int numParams) {
	Handle hJson = GetNativeCell(1);
	char buffer[256];
	JsonObjectGetString(hJson, "avatar", buffer, sizeof(buffer));
	SetNativeString(2, buffer, GetNativeCell(3));
}

public int Native_DiscordUser_GetEmail(Handle plugin, int numParams) {
	Handle hJson = GetNativeCell(1);
	char buffer[64];
	JsonObjectGetString(hJson, "email", buffer, sizeof(buffer));
	SetNativeString(2, buffer, GetNativeCell(3));
}

public int Native_DiscordUser_IsVerified(Handle plugin, int numParams) {
	Handle hJson = GetNativeCell(1);
	return JsonObjectGetBool(hJson, "verified");
}

public int Native_DiscordUser_IsBot(Handle plugin, int numParams) {
	Handle hJson = GetNativeCell(1);
	return JsonObjectGetBool(hJson, "bot");
}