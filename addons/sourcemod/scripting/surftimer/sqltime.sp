public void db_viewPlayerInfo(int client, char szSteamId[32])
{
	char szQuery[512];
	Format(szQuery, sizeof(szQuery), "SELECT steamid, steamid64, name, country, lastseen, joined, connections, timealive, timespec FROM ck_playerrank WHERE steamid = '%s';", szSteamId);
	if (g_cLogQueries.BoolValue)
	{
		LogToFile(g_szQueryFile, "db_viewPlayerInfo - szQuery: %s", szQuery);
	}
	g_dDb.Query(SQL_ViewPlayerInfoCallback, szQuery, GetClientUserId(client), DBPrio_Low);
}


public void SQL_ViewPlayerInfoCallback(Database db, DBResultSet results, const char[] error, any userid)
{
	if (!IsValidDatabase(db, error))
	{
		LogError("[SurfTimer] SQL Error (SQL_ViewPlayerInfoCallback): %s", error);
		return;
	}

	int client = GetClientOfUserId(userid);

	if (IsValidClient(client))
	{
		if (results.HasResults && results.FetchRow())
		{
			char szSteamId[32], szName[MAX_NAME_LENGTH], szCountry[128], szSteamId64[64];
			results.FetchString(0, szSteamId, 32);
			results.FetchString(1, szSteamId64, 64);
			results.FetchString(2, szName, sizeof(szName));
			results.FetchString(3, szCountry, sizeof(szCountry));
			int lastSeenUnix = results.FetchInt(4);
			int joinUnix = results.FetchInt(5);
			int connections = results.FetchInt(6);
			int timeAlive = results.FetchInt(7);
			int timeSpec = results.FetchInt(8);

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
	if (g_cLogQueries.BoolValue)
	{
		LogToFile(g_szQueryFile, "db_savePlayTime- szQuery: %s", szQuery);
	}
	g_dDb.Query(SQL_SavePlayTimeCallback, szQuery, _, DBPrio_Low);
}

public void SQL_SavePlayTimeCallback(Database db, DBResultSet results, const char[] error, any data)
{
	if (!IsValidDatabase(db, error))
	{
		LogError("[SurfTimer] SQL Error (SQL_SavePlayTimeCallback): %s", error);
		return;
	}
}
