methodmap DiscordWebHook < Handle {
	public DiscordWebHook(char[] url) {
		Handle mp = json_object();
		json_object_set_new(mp, "__url", json_string(url));
		Handle data = json_object();
		json_object_set_new(mp, "__data", data);

		return view_as<DiscordWebHook>(mp);
	}

	public void GetUrl(char[] buffer, int maxlength) {
		JsonObjectGetString(this, "__url", buffer, maxlength);
	}

	/**
	 * Gets/Sets if the hook should be sent as Slack.
	 * Note: color is different for slack than discord msg.
	 *
	 * @return 			True if Slack, otherwise false.
	 */
	property bool SlackMode {
		public get() {
			return JsonObjectGetBool(this, "__slack", false);
		}

		public set(bool value) {
			json_object_set_new(this, "__slack", (value) ? json_true() : json_false());
		}
	}

	property Handle Data {
		public get() {
			return json_object_get(this, "__data");
		}

		public set(Handle value) {
			json_object_set_new(this, "__data", value);
		}
	}

	public void UpdateDataObject(char[] key, Handle hObject) {
		Handle data = this.Data;
		json_object_set_new(data, key, hObject);
		delete data;
	}

	public bool GetDataBool(char[] key, bool defaultValue=false) {
		Handle data = this.Data;
		bool value = JsonObjectGetBool(data, key, defaultValue);
		delete data;
		return value;
	}

	public bool GetDataString(char[] key, char[] buffer, int maxlength) {
		Handle data = this.Data;
		bool success = JsonObjectGetString(data, key, buffer, maxlength);
		delete data;
		return success;
	}

	/**
	 * Note: Deletes the MessageEmbed Object!
	 */
	public void Embed(MessageEmbed Object) {
		//this.UpdateDataObject("embeds", Object);
		Handle data = this.Data;
		Handle hArray = json_object_get(data, "embeds");

		if(hArray == null) {
			hArray = json_array();
			json_object_set(data, "embeds", hArray);
		}

		json_array_append_new(hArray, Object);
		delete hArray;
		delete data;

	}

	property bool tts {
		public get() {
			return this.GetDataBool("tts", false);
		}

		public set(bool value) {
			this.UpdateDataObject("tts", json_boolean(value));
		}
	}

	public bool GetUsername(char[] buffer, int maxlength) {
		return this.GetDataString("username", buffer, maxlength);
	}

	public void SetUsername(const char[] name) {
		this.UpdateDataObject("username", json_string(name));
	}

	public bool GetAvatar(char[] buffer, int maxlength) {
		return this.GetDataString("icon_url", buffer, maxlength);
	}

	public void SetAvatar(const char[] icon_url) {
		this.UpdateDataObject("icon_url", json_string(icon_url));
	}

	public bool GetContent(char[] buffer, int maxlength) {
		return this.GetDataString("content", buffer, maxlength);
	}

	public void SetContent(const char[] content) {
		this.UpdateDataObject("content", json_string(content));
	}

	/*property Handle OnComplete {
		public get() {
			Handle fForward = null;
			if(!GetTrieValue(this, "callback", fForward)) {
				return null;
			}

			return fForward;
		}

		public set(Handle value) {
			SetTrieValue(this, "callback", value);
			SetTrieValue(this, "plugin", GetMyHandle());
		}
	}

	property Handle CallbackPlugin {
		public get() {
			Handle value = null;
			if(!GetTrieValue(this, "plugin", value)) {
				return null;
			}

			return value;
		}
	}*/

	public native void Send();
};
