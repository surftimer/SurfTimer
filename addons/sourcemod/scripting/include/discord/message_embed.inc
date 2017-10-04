methodmap MessageEmbed < Handle {
	public MessageEmbed() {
		Handle hObj = json_object();
		return view_as<MessageEmbed>(hObj);
	}
	
	public bool GetColor(char[] buffer, int maxlength) {
		return JsonObjectGetString(this, "color", buffer, maxlength);
	}
	
	public void SetColor(char[] color) {
		json_object_set_new(this, "color", json_string(color));
	}
	
	public bool GetTitle(char[] buffer, int maxlength) {
		return JsonObjectGetString(this, "title", buffer, maxlength);
	}
	
	public void SetTitle(char[] title) {
		json_object_set_new(this, "title", json_string(title));
	}
	
	/**
	 * Note: Setting Fields will delete the handle!
	 */
	property Handle Fields {
		public get() {
			return json_object_get(this, "fields");
		}
		
		public set(Handle value) {
			json_object_set_new(this, "fields", value);
		}
	}
	
	public void AddField(char[] name, char[] value, bool inline) {
		Handle hObj = json_object();
		json_object_set_new(hObj, "name", json_string(name));
		json_object_set_new(hObj, "value", json_string(value));
		json_object_set_new(hObj, "inline", json_boolean(inline));
		Handle hArray = this.Fields;
		if(this.Fields == null) {
			hArray = json_array();
		}
		json_array_append_new(hArray, hObj);
		this.Fields = hArray;
	}
	
	//Below don't support Slack Mode
	public bool GetDescription(char[] buffer, int maxlength) {
		return JsonObjectGetString(this, "description", buffer, maxlength);
	}
	
	public void SetDescription(char[] description) {
		json_object_set_new(this, "description", json_string(description));
	}
	
	public bool GetURL(char[] buffer, int maxlength) {
		return JsonObjectGetString(this, "url", buffer, maxlength);
	}
	
	public void SetURL(char[] url) {
		json_object_set_new(this, "url", json_string(url));
	}
}