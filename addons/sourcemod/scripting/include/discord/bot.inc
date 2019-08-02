methodmap DiscordBot < StringMap {
	public DiscordBot(const char[] token) {
		Handle json = json_object();
		json_object_set_new(json, "token", json_string(token));
		
		return view_as<DiscordBot>(json);
	}
	
	public void StopListening() {
		json_object_del(this, "listeningChannels");
	}
	
	property float MessageCheckInterval {
		public get() {
			return JsonObjectGetFloat(this, "messageInterval", 3.0);
		}
		public set(float value) {
			json_object_set_new(this, "messageInterval", json_real(value));
		}
	}
	
	public native void StartTimer(DiscordChannel Channel, OnChannelMessage fCallback);
	
	/** 
	 * Retrieves a list of Channels the bot is listening to for messages
	 */
	public Handle GetListeningChannels() {
		return json_object_get(this, "listeningChannels");
	}
	
	/**
	 * Checks if the bot is listening to channel for messages
	 * @param DiscordChannel Channel
	 */
	public bool IsListeningToChannel(DiscordChannel Channel) {
		char id[32];
		Channel.GetID(id, sizeof(id));
		
		Handle hChannels = this.GetListeningChannels();
		if(hChannels == null) return false;
		
		for(int i = 0; i < json_array_size(hChannels); i++) {
			DiscordChannel tempChannel = view_as<DiscordChannel>(json_array_get(hChannels, i));
			static char tempID[32];
			tempChannel.GetID(tempID, sizeof(tempID));
			if(StrEqual(id, tempID, false)) {
				delete tempChannel;
				delete hChannels;
				return true;
			}
			delete tempChannel;
		}
		delete hChannels;
		return false;
	}
	
	/**
	 * Checks if the bot is listening to channel for messages
	 * @param DiscordChannel Channel
	 */
	public bool IsListeningToChannelID(const char[] id) {
		Handle hChannels = this.GetListeningChannels();
		if(hChannels == null) return false;
		
		for(int i = 0; i < json_array_size(hChannels); i++) {
			DiscordChannel tempChannel = view_as<DiscordChannel>(json_array_get(hChannels, i));
			static char tempID[32];
			tempChannel.GetID(tempID, sizeof(tempID));
			if(StrEqual(id, tempID, false)) {
				delete tempChannel;
				delete hChannels;
				return true;
			}
			delete tempChannel;
		}
		delete hChannels;
		return false;
	}
	
	/**
	 * Stops the bot from listening to that channel for messages
	 * @param DiscordChannel Channel
	 */
	public void StopListeningToChannel(DiscordChannel Channel) {
		char id[32];
		Channel.GetID(id, sizeof(id));
		
		Handle channels = this.GetListeningChannels();
		if(channels == null) return;
		
		for(int i = 0; i < json_array_size(channels); i++) {
			DiscordChannel tempChannel = view_as<DiscordChannel>(json_array_get(channels, i));
			static char tempID[32];
			tempChannel.GetID(tempID, sizeof(tempID));
			if(StrEqual(id, tempID, false)) {
				json_array_remove(channels, i);
				i--;
				delete tempChannel;
			}
		}
		delete channels;
	}
	
	/**
	 * Stops the bot from listening to that channel id for messages
	 * @param DiscordChannel Channel
	 */
	public void StopListeningToChannelID(const char[] id) {
		Handle channels = this.GetListeningChannels();
		if(channels == null) return;
		
		for(int i = 0; i < json_array_size(channels); i++) {
			DiscordChannel tempChannel = view_as<DiscordChannel>(json_array_get(channels, i));
			static char tempID[32];
			tempChannel.GetID(tempID, sizeof(tempID));
			if(StrEqual(id, tempID, false)) {
				json_array_remove(channels, i);
				i--;
				delete tempChannel;
			}
		}
		delete channels;
	}
	
	public DiscordChannel GetListeningChannelByID(const char[] id) {
		Handle channels = this.GetListeningChannels();
		if(channels == null) return null;
		
		for(int i = 0; i < json_array_size(channels); i++) {
			DiscordChannel tempChannel = view_as<DiscordChannel>(json_array_get(channels, i));
			static char tempID[32];
			tempChannel.GetID(tempID, sizeof(tempID));
			if(StrEqual(id, tempID, false)) {
				delete channels;
				return tempChannel;
			}
		}
		delete channels;
		return null;
	}
	
	/**
	 * Start listening to the channel for messages.
	 * The Channel handle is duplicated. Feel free to close yours.
	 * @param DiscordChannel Channel
	 */
	public void StartListeningToChannel(DiscordChannel Channel, OnChannelMessage fCallback) {
		if(this.IsListeningToChannel(Channel)) return;
		
		Handle channels = this.GetListeningChannels();
		
		if(channels == null) {
			channels = json_array();
			json_object_set(this, "listeningChannels", channels);
		}
		
		json_array_append(channels, Channel);
		
		//Handle fForward = CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_String, Param_String, Param_String, Param_String, Param_String, Param_Cell);
		//AddToForward(fForward, GetMyHandle(), callback);
		
		this.StartTimer(Channel, fCallback);
	}
	
	
	public native void AddReactionID(const char[] channel, const char[] messageid, const char[] emoji);
	
	public void AddReaction(DiscordChannel channel, const char[] messageid, const char[] emoji) {
		char channelid[64];
		channel.GetID(channelid, sizeof(channelid));
		this.AddReactionID(channelid, messageid, emoji);
	}
	
	public native void DeleteReactionID(const char[] channel, const char[] messageid, const char[] emoji, const char[] user);
	
	public void DeleteReaction(DiscordChannel channel, const char[] messageid, const char[] emoji, const char[] user) {
		char chid[64];
		channel.GetID(chid, sizeof(chid));
		this.DeleteReactionID(chid, messageid, emoji, user);
	}
	
	public void DeleteReactionSelf(DiscordChannel channel, const char[] messageid, const char[] emoji) {
		this.DeleteReaction(channel, messageid, emoji, "@me");
	}
	public void DeleteReactionAll(DiscordChannel channel, const char[] messageid, const char[] emoji) {
		this.DeleteReaction(channel, messageid, emoji, "@all");
	}
	
	public void DeleteReactionSelfID(const char[] channel, const char[] messageid, const char[] emoji) {
		this.DeleteReactionID(channel, messageid, emoji, "@me");
	}
	public void DeleteReactionAllID(const char[] channel, const char[] messageid, const char[] emoji) {
		this.DeleteReactionID(channel, messageid, emoji, "@all");
	}
	
	public native void GetReactionID(const char[] channel, const char[] messageid, const char[] emoji, OnGetReactions fCallback=INVALID_FUNCTION, any data=0);
	
	public void GetReaction(DiscordChannel channel, const char[] messageid, const char[] emoji, OnGetReactions fCallback=INVALID_FUNCTION, any data=0) {
		char id[64];
		channel.GetID(id, sizeof(id));
		this.GetReactionID(id, messageid, emoji, fCallback, data);
	}
	
	public native void GetToken(char[] token, int maxlength);
	
	public native void SendMessage(DiscordChannel channel, char[] message, OnMessageSent fCallback=INVALID_FUNCTION, any data=0);
	
	public native void SendMessageToChannelID(char[] channel, char[] message, OnMessageSent fCallback=INVALID_FUNCTION, any data=0);
	
	public native void DeleteMessageID(char[] channel, char[] message, OnMessageDeleted fCallback=INVALID_FUNCTION, any data=0);
	public native void DeleteMessage(DiscordChannel channel, DiscordMessage message, OnMessageDeleted fCallback=INVALID_FUNCTION, any data=0);
	
	
	public native void GetGuilds(DiscordGuildsRetrieve fCallback = INVALID_FUNCTION, DiscordGuildsRetrievedAll fCallbackAll = INVALID_FUNCTION, any data=0);
	
	public native void GetGuildChannels(char[] guild, DiscordGuildChannelsRetrieve fCallback = INVALID_FUNCTION, DiscordGuildChannelsRetrieveAll fCallbackAll = INVALID_FUNCTION, any data=0);
	
	/**
	 * ATM takes guild id, hopefully later on i will implement guild objects.
	 * Limit is from 1-1000
	 */
	public native void GetGuildMembers(char[] guild, OnGetMembers fCallback, int limit=250, char[] afterUserID="");
	
	/**
	 * Same as above but displays ALL members, paginating automatically.
	 * perPage is how many it should display per callback. 1-1000
	 */
	public native void GetGuildMembersAll(char[] guild, OnGetMembers fCallback, int perPage=250, char[] afterUserID="");
	
	public native void GetGuildRoles(char[] guild, DiscordGuildGetRoles fCallback, any data);
};
