methodmap DiscordGuildUser < Handle {
	//Returns User Object
	public DiscordUser GetUser() {
		return view_as<DiscordUser>(json_object_get(this, "user"));
	}
	
	//Returns player's nick
	public void GetNickname(char[] buffer, int maxlength) {
		JsonObjectGetString(this, "nick", buffer, maxlength);
	}
	
	//Returns JSON array list of roles. You can manually loop through them for now.
	public Handle GetRoles() {
		return json_object_get(this, "roles");
	}
	
	//Returns the date the user joined the guild in format: "2015-04-26T06:26:56.936000+00:00"
	public void GetJoinedAt(char[] buffer, int maxlength) {
		JsonObjectGetString(this, "joined_at", buffer, maxlength);
	}
	
	public bool IsDeaf() {
		return JsonObjectGetBool(this, "deaf");
	}
	
	public bool IsMute() {
		return JsonObjectGetBool(this, "mute");
	}
};
