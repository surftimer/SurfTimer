public int Native_DiscordWebHook_Send(Handle plugin, int numParams) {
	DiscordWebHook hook = GetNativeCell(1);
	SendWebHook(view_as<DiscordWebHook>(hook));
}

public void SendWebHook(DiscordWebHook hook) {
	if(!JsonObjectGetBool(hook, "__selfCopy", false)) {
		hook = view_as<DiscordWebHook>(json_deep_copy(hook));
		json_object_set_new(hook, "__selfCopy", json_true());
	}
	Handle hJson = hook.Data;
	
	char url[256];
	hook.GetUrl(url, sizeof(url));
	
	if(hook.SlackMode) {
		if(StrContains(url, "/slack") == -1) {
			Format(url, sizeof(url), "%s/slack", url);
		}
		
		RenameJsonObject(hJson, "content", "text");
		RenameJsonObject(hJson, "embeds", "attachments");
		
		Handle hAttachments = json_object_get(hJson, "attachments");
		if(hAttachments != null) {
			if(json_is_array(hAttachments)) {
				for(int i = 0; i < json_array_size(hAttachments); i++) {
					Handle hEmbed = json_array_get(hAttachments, i);
					
					Handle hFields = json_object_get(hEmbed, "fields");
					if(hFields) {
						if(json_is_array(hFields)) {
							for(int j = 0; j < json_array_size(hFields); j++) {
								Handle hField = json_array_get(hFields, j);
								RenameJsonObject(hField, "name", "title");
								RenameJsonObject(hField, "inline", "short");
								//json_array_set_new(hFields, j, hField);
								delete hField;
							}
						}
						
						//json_object_set_new(hEmbed, "fields", hFields);
						delete hFields;
					}
					
					//json_array_set_new(hAttachments, i, hEmbed);
					delete hEmbed;
				}
			}
			
			//json_object_set_new(hJson, "attachments", hAttachments);
			delete hAttachments;
		}
	}
	
	//Send
	DiscordRequest request = new DiscordRequest(url, k_EHTTPMethodPOST);
	request.SetCallbacks(HTTPCompleted, SendWebHookReceiveData);
	request.SetJsonBodyEx(hJson);
	//Handle request = PrepareRequestRaw(null, url, k_EHTTPMethodPOST, hJson, SendWebHookReceiveData);
	if(request == null) {
		CreateTimer(2.0, SendWebHookDelayed, hJson);
		return;
	}
	
	request.SetContextValue(hJson, UrlToDP(url));
	
	//DiscordSendRequest(request, url);
	request.Send(url);
}

public Action SendWebHookDelayed(Handle timer, any data) {
	SendWebHook(view_as<DiscordWebHook>(data));
}

public SendWebHookReceiveData(Handle request, bool failure, int offset, int statuscode, any dp) {
	if(failure || (statuscode != 200 && statuscode != 204)) {
		if(statuscode == 400) {
			PrintToServer("BAD REQUEST");
			SteamWorks_GetHTTPResponseBodyCallback(request, WebHookData, dp);
		}
		
		if(statuscode == 429 || statuscode == 500) {
			SendWebHook(view_as<DiscordWebHook>(dp));
			
			delete request;
			return;
		}
		LogError("[DISCORD] Couldn't Send Webhook - Fail %i %i", failure, statuscode);
		delete request;
		delete view_as<Handle>(dp);
		return;
	}
	delete request;
	delete view_as<Handle>(dp);
}

public int WebHookData(const char[] data, any dp) {
	PrintToServer("DATA RECE: %s", data);
	static char stringJson[16384];
	stringJson[0] = '\0';
	json_dump(view_as<Handle>(dp), stringJson, sizeof(stringJson), 0, true);
	PrintToServer("DATA SENT: %s", stringJson);
}