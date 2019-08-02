/*
stock Handle PrepareRequest(DiscordBot bot, char[] url, EHTTPMethod method=k_EHTTPMethodGET, Handle hJson=null, SteamWorksHTTPDataReceived DataReceived = INVALID_FUNCTION, SteamWorksHTTPRequestCompleted RequestCompleted = INVALID_FUNCTION) {
	static char stringJson[16384];
	stringJson[0] = '\0';
	if(hJson != null) {
		json_dump(hJson, stringJson, sizeof(stringJson), 0, true);
	}
	
	//Format url
	static char turl[128];
	FormatEx(turl, sizeof(turl), "https://discordapp.com/api/%s", url);
	
	Handle request = SteamWorks_CreateHTTPRequest(method, turl);
	if(request == null) {
		return null;
	}
	
	if(bot != null) {
		BuildAuthHeader(request, bot);
	}
	
	SteamWorks_SetHTTPRequestRawPostBody(request, "application/json; charset=UTF-8", stringJson, strlen(stringJson));
	
	SteamWorks_SetHTTPRequestNetworkActivityTimeout(request, 30);
	
	if(RequestCompleted == INVALID_FUNCTION) {
		//I had some bugs previously where it wouldn't send request and return code 0 if I didn't set request completed.
		//This is just a safety then, my issue could have been something else and I will test more later on
		RequestCompleted = HTTPCompleted;
	}
	
	if(DataReceived == INVALID_FUNCTION) {
		//Need to close the request handle
		DataReceived = HTTPDataReceive;
	}
	
	SteamWorks_SetHTTPCallbacks(request, RequestCompleted, HeadersReceived, DataReceived);
	if(hJson != null) delete hJson;
	
	return request;
}
 */

methodmap DiscordRequest < Handle {
	public DiscordRequest(char[] url, EHTTPMethod method) {
		Handle request = SteamWorks_CreateHTTPRequest(method, url);
		return view_as<DiscordRequest>(request);
	}
	
	public void SetJsonBody(Handle hJson) {
		static char stringJson[16384];
		stringJson[0] = '\0';
		if(hJson != null) {
			json_dump(hJson, stringJson, sizeof(stringJson), 0, true);
		}
		SteamWorks_SetHTTPRequestRawPostBody(this, "application/json; charset=UTF-8", stringJson, strlen(stringJson));
		if(hJson != null) delete hJson;
	}
	
	public void SetJsonBodyEx(Handle hJson) {
		static char stringJson[16384];
		stringJson[0] = '\0';
		if(hJson != null) {
			json_dump(hJson, stringJson, sizeof(stringJson), 0, true);
		}
		SteamWorks_SetHTTPRequestRawPostBody(this, "application/json; charset=UTF-8", stringJson, strlen(stringJson));
	}
	
	property int Timeout {
		public set(int timeout) {
			SteamWorks_SetHTTPRequestNetworkActivityTimeout(this, timeout);
		}
	}
	
	public void SetCallbacks(SteamWorksHTTPRequestCompleted OnComplete, SteamWorksHTTPDataReceived DataReceived) {
		SteamWorks_SetHTTPCallbacks(this, OnComplete, HeadersReceived, DataReceived);
	}
	
	public void SetContextValue(any data1, any data2) {
		SteamWorks_SetHTTPRequestContextValue(this, data1, data2);
	}
	
	public void SetData(any data1, char[] route) {
		SteamWorks_SetHTTPRequestContextValue(this, data1, UrlToDP(route));
	}
	
	public void SetBot(DiscordBot bot) {
		BuildAuthHeader(this, bot);
	}
	
	public void Send(char[] route) {
		DiscordSendRequest(this, route);
	}
}