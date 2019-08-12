methodmap MessageEmbed < Handle {
	public MessageEmbed() {
		Handle hObj = json_object();
		return view_as<MessageEmbed>(hObj);
	}

	public bool GetColor(char[] buffer, int maxlength) {
		return JsonObjectGetString(this, "color", buffer, maxlength);
	}

	public void SetColor(const char[] color) {
		json_object_set_new(this, "color", json_string(color));
	}

	public bool GetTitle(char[] buffer, int maxlength) {
		return JsonObjectGetString(this, "title", buffer, maxlength);
	}

	public void SetTitle(const char[] title) {
		json_object_set_new(this, "title", json_string(title));
	}

	public bool GetTitleLink(char[] buffer, int maxlength) {
		return JsonObjectGetString(this, "title_link", buffer, maxlength);
	}

	public void SetTitleLink(const char[] title_link) {
		json_object_set_new(this, "title_link", json_string(title_link));
	}

	public bool GetImage(char[] buffer, int maxlength) {
		return JsonObjectGetString(this, "image_url", buffer, maxlength);
	}

	public void SetImage(const char[] image_url) {
		json_object_set_new(this, "image_url", json_string(image_url));
	}

	public bool GetAuthor(char[] buffer, int maxlength) {
		return JsonObjectGetString(this, "author_name", buffer, maxlength);
	}

	public void SetAuthor(const char[] author_name) {
		json_object_set_new(this, "author_name", json_string(author_name));
	}

	public bool GetAuthorLink(char[] buffer, int maxlength) {
		return JsonObjectGetString(this, "author_link", buffer, maxlength);
	}

	public void SetAuthorLink(const char[] author_link) {
		json_object_set_new(this, "author_link", json_string(author_link));
	}

	public bool GetAuthorIcon(char[] buffer, int maxlength) {
		return JsonObjectGetString(this, "author_icon", buffer, maxlength);
	}

	public void SetAuthorIcon(const char[] author_icon) {
		json_object_set_new(this, "author_icon", json_string(author_icon));
	}

	public bool GetThumb(char[] buffer, int maxlength) {
		return JsonObjectGetString(this, "thumb_url", buffer, maxlength);
	}

	public void SetThumb(const char[] thumb_url) {
		json_object_set_new(this, "thumb_url", json_string(thumb_url));
	}

	public bool GetFooter(char[] buffer, int maxlength) {
		return JsonObjectGetString(this, "footer", buffer, maxlength);
	}

	public void SetFooter(const char[] footer) {
		json_object_set_new(this, "footer", json_string(footer));
	}

	public bool GetFooterIcon(char[] buffer, int maxlength) {
		return JsonObjectGetString(this, "footer_icon", buffer, maxlength);
	}

	public void SetFooterIcon(const char[] footer_icon) {
		json_object_set_new(this, "footer_icon", json_string(footer_icon));
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

	public void AddField(const char[] name, const char[] value, bool inline) {
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

	public void SetDescription(const char[] description) {
		json_object_set_new(this, "description", json_string(description));
	}

	public bool GetURL(char[] buffer, int maxlength) {
		return JsonObjectGetString(this, "url", buffer, maxlength);
	}

	public void SetURL(const char[] url) {
		json_object_set_new(this, "url", json_string(url));
	}
};
