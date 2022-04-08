// Commands
public Action VIP_GiveVip(int client, int args)
{
	// sm_givevip steamid viplvl
	if (args == 0)
	{
		CReplyToCommand(client, "%t", "VIP1", g_szChatPrefix);
		return Plugin_Handled;
	}

	char szSteamId[128], szBuffer[128];
	int iVip;
	GetCmdArg(1, szSteamId, sizeof(szSteamId));
	GetCmdArg(2, szBuffer, sizeof(szBuffer));

	iVip = StringToInt(szBuffer);
	db_selectVipStatus(szSteamId, iVip, 0);

	return Plugin_Handled;
}

public Action VIP_RemoveVip(int client, int args)
{
	// sm_removevip steamid
	if (args == 0)
	{
		CReplyToCommand(client, "%t", "VIP2", g_szChatPrefix);
		return Plugin_Handled;
	}

	char szSteamId[128];
	GetCmdArg(1, szSteamId, sizeof(szSteamId));
	db_selectVipStatus(szSteamId, 0, 1);

	return Plugin_Handled;
}

public Action VIP_GiveCredits(int client, int args)
{
	// sm_addcredits steamid
	if (args != 2)
	{
		CReplyToCommand(client, "%t", "VIP3", g_szChatPrefix);
		return Plugin_Handled;
	}

	char szSteamId[128];
	GetCmdArg(1, szSteamId, sizeof(szSteamId));
	// Find Client
	int foundClient = -1;
	for (int i = 1;i <= MaxClients;i++)
	{
		if (IsValidClient(i) && !IsFakeClient(i))
		{
			if (StrEqual(szSteamId, g_szSteamID[i]))
			{
				foundClient = i;
				break;
			}
		}
	}

	if (foundClient == -1)
	return Plugin_Handled;

	int userid = GetClientUserId(foundClient);

	// Get credit amount
	char szCredits[128];
	GetCmdArg(2, szCredits, sizeof(szCredits));
	int credits = StringToInt(szCredits);
	ServerCommand("sm_givecredits #%i %i", userid, credits);

	return Plugin_Handled;
}

// SQL
public void db_selectVipStatus(char szSteamId[128], int iVip, int type)
{
	char szQuery[256];
	if (type == 0)
	{
		Handle pack = CreateDataPack();
		WritePackString(pack, szSteamId);
		WritePackCell(pack, iVip);
		
		Format(szQuery, 256, "SELECT steamid, vip, active FROM ck_vipadmins WHERE steamid = '%s';", szSteamId);
		SQL_TQuery(g_hDb, db_selectVipStatusCallback, szQuery, pack, DBPrio_Low);
	}
	else
	{
		// Find Client
		int client = -1;
		for (int i = 1;i <= MaxClients;i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i))
			{
				if (StrEqual(szSteamId, g_szSteamID[i]))
				{
					client = i;
					break;
				}
			}
		}
		Format(szQuery, 256, "UPDATE ck_vipadmins SET inuse = 0, active = 0 WHERE steamid = '%s';", szSteamId);
		SQL_TQuery(g_hDb, db_removeVipCallback, szQuery, client, DBPrio_Low);
	}
}

public void db_selectVipStatusCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	char szSteamId[128];
	ResetPack(pack);
	ReadPackString(pack, szSteamId, sizeof(szSteamId));
	int iVip = ReadPackCell(pack);
	CloseHandle(pack);

	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (db_selectVipStatusCallback): %s", error);
		return;
	}

	if (SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		// Exisiting Player
		int iVipCompare, active;
		SQL_FetchString(hndl, 0, szSteamId, 128);
		iVipCompare = SQL_FetchInt(hndl, 1);
		active = SQL_FetchInt(hndl, 2);

		// Check to see if need to update
		if (active == 1)
		{
			if (iVip != iVipCompare)
			{
				// Need to update players VIP lvl
				db_updateVip(szSteamId, iVip);
			}
		}
		else
		{
			// Need to update players VIP lvl
			db_updateVip(szSteamId, iVip);
		}
	}
	else
	{
		// New Player, lets insert
		db_insertVip(szSteamId, iVip);
	}
}

public void db_removeVipCallback(Handle owner, Handle hndl, const char[] error, any client)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (db_removeVipCallback): %s", error);
		return;
	}

	g_bCheckCustomTitle[client] = true;
	db_CheckVIPAdmin(client, g_szSteamID[client]);
}

public void db_insertVip(char szSteamId[128], int iVip)
{
	char szQuery[256], szTitle[128];
	int colour;
	switch (iVip)
	{
		case 1:
		{
			Format(szTitle, sizeof(szTitle), "[{lime}VIP{default}]");
			colour = 3;
		}
		case 2:
		{
			Format(szTitle, sizeof(szTitle), "[{pink}Super VIP{default}]");
			colour = 11;
		}
		case 3: 
		{
			Format(szTitle, sizeof(szTitle), "[{darkred}Superior VIP{default}]");
			colour = 1;
		}
	}

	Handle pack = CreateDataPack();
	WritePackString(pack, szSteamId);
	WritePackCell(pack, iVip);

	Format(szQuery, 256, "INSERT INTO ck_vipadmins (steamid, title, namecolour, textcolour, inuse, vip, admin, zoner) VALUES ('%s', '%s', %i, 0, 1 , %i, 0, 0);", szSteamId, szTitle, colour, iVip);
	SQL_TQuery(g_hDb, db_insertVipCallback, szQuery, pack, DBPrio_Low);
}

public void db_insertVipCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl == null)
	{
		LogError("[SurfTimer] SQL Error (db_insertVipCallback): %s", error);
		return;
	}

	char szSteamId[128];
	// int iVip;
	ResetPack(pack);
	ReadPackString(pack, szSteamId, 128);
	// iVip = ReadPackCell(pack);
	CloseHandle(pack);

	// Find Client
	int client = -1;
	for (int i = 1;i <= MaxClients;i++)
	{
		if (IsValidClient(i) && !IsFakeClient(i))
		{
			if (StrEqual(szSteamId, g_szSteamID[i]))
			{
				client = i;
				break;
			}
		}
	}

	if (client != -1)
	{
		g_bCheckCustomTitle[client] = true;
		db_CheckVIPAdmin(client, szSteamId);
	}
}

public void db_updateVip(char szSteamId[128], int iVip)
{
	char szQuery[256], szTitle[128];
	int colour;
	switch (iVip)
	{
		case 1:
		{
			Format(szTitle, sizeof(szTitle), "[{lime}VIP{default}]");
			colour = 3;
		}
		case 2:
		{
			Format(szTitle, sizeof(szTitle), "[{pink}Super VIP{default}]");
			colour = 11;
		}
		case 3: 
		{
			Format(szTitle, sizeof(szTitle), "[{darkred}Superior VIP{default}]");
			colour = 1;
		}
	}

	Handle pack = CreateDataPack();
	WritePackString(pack, szSteamId);
	WritePackCell(pack, iVip);

	Format(szQuery, 256, "UPDATE ck_vipadmins SET title = '%s', namecolour = %i, textcolour = 0, inuse = 1, vip = %i WHERE steamid = '%s';", szTitle, colour, iVip, szSteamId);
	SQL_TQuery(g_hDb, db_insertVipCallback, szQuery, pack, DBPrio_Low);
}
