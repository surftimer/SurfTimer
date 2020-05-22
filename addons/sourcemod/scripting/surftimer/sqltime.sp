public void db_viewPlayerInfo(int client, char szSteamId[32])
{
	char szQuery[512];
	Format(szQuery, sizeof(szQuery), "SELECT steamid, steamid64, name, country, lastseen, joined, connections, timealive, timespec FROM ck_playerrank WHERE steamid = '%s';", szSteamId);
	g_dDb.Query(SQL_ViewPlayerInfoCallback, szQuery, GetClientUserId(client), DBPrio_Low);
}


public void SQL_ViewPlayerInfoCallback(Handle owner, Handle hndl, const char[] error, any userid)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (SQL_ViewPlayerInfoCallback): %s", error);
		return;
	}

	int client = GetClientOfUserId(userid);

	if (IsValidClient(client))
	{
		if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
		{
			char szSteamId[32], szName[MAX_NAME_LENGTH], szCountry[128], szSteamId64[64];
			SQL_FetchString(hndl, 0, szSteamId, 32);
			SQL_FetchString(hndl, 1, szSteamId64, 64);
			SQL_FetchString(hndl, 2, szName, sizeof(szName));
			SQL_FetchString(hndl, 3, szCountry, sizeof(szCountry));
			int lastSeenUnix = SQL_FetchInt(hndl, 4);
			int joinUnix = SQL_FetchInt(hndl, 5);
			int connections = SQL_FetchInt(hndl, 6);
			int timeAlive = SQL_FetchInt(hndl, 7);
			int timeSpec = SQL_FetchInt(hndl, 8);

			// Format Joined Time
			char szTime[128];
			FormatTime(szTime, sizeof(szTime), "%d %b %Y", joinUnix);

			// Format Last Seen Time
			int unix = GetTime();
			int diffUnix = unix - lastSeenUnix;
			char szBuffer[128];
			diffForHumans(diffUnix, szBuffer, 128, 0);

			int totalTime = (timeAlive + timeSpec);

			char szTotalTime[128], szTimeAlive[128], szTimeSpec[128];

			totalTimeForHumans(totalTime, szTotalTime, 128);
			totalTimeForHumans(timeAlive, szTimeAlive, 128);
			totalTimeForHumans(timeSpec, szTimeSpec, 128);

			Menu menu = CreateMenu(ProfileInfoMenuHandler);
			char szTitle[1024];
			Format(szTitle, sizeof(szTitle), "Player: %s\nSteamID: %s\n-------------------------------------- \n \nFirst Time Online: %s\nLast Time Online: %s\n \nTotal Online Time: %s\nTotal Alive Time: %s\nTotal Spec Time: %s\n \nTotal Connections %i\n \n", szName, szSteamId, szTime, szBuffer, szTotalTime, szTimeAlive, szTimeSpec, connections);

			SetMenuTitle(menu, szTitle);

			AddMenuItem(menu, szSteamId64, "Community Profile Link");
			SetMenuExitButton(menu, true);
			
			DisplayMenu(menu, client, MENU_TIME_FOREVER);
		}
		else
			CPrintToChat(client, "%t", "PlayerNotFound", g_szChatPrefix, g_szProfileName[client]);
	}
}

public int ProfileInfoMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char info[64];
		GetMenuItem(menu, param2, info, sizeof(info));
		CPrintToChat(param1, "%t", "SQLTime1", g_szChatPrefix, info);
	}
	else
		if (action == MenuAction_End)
	{
		if (IsValidClient(param1))
			g_bSelectProfile[param1] = false;
		delete menu;
	}
}

public void db_savePlayTime(int client)
{
	char szQuery[512];
	Format(szQuery, sizeof(szQuery), "UPDATE ck_playerrank SET timealive = timealive + %i, timespec = timespec + %i WHERE steamid = '%s';", g_iPlayTimeAliveSession[client], g_iPlayTimeSpecSession[client], g_szSteamID[client]);
	g_dDb.Query(SQL_SavePlayTimeCallback, szQuery, _, DBPrio_Low);
}

public void SQL_SavePlayTimeCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (SQL_SavePlayTimeCallback): %s", error);
		return;
	}
}
