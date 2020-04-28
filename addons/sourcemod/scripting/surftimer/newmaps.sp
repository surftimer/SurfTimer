void CreateCommandsNewMap()
{
	RegConsoleCmd("sm_newmap", Client_NewMap, "[surftimer] shows new maps");
	RegConsoleCmd("sm_nm", Client_NewMap, "[surftimer] shows new maps");
	RegAdminCmd("sm_addnewmap", Client_AddNewMap, ADMFLAG_ROOT, "[surftimer] add a new map");
	RegAdminCmd("sm_anm", Client_AddNewMap, ADMFLAG_ROOT, "[surftimer] add a new map");
}

public Action Client_NewMap(int client, int args)
{
	db_ViewNewestMaps(client);
	return Plugin_Handled;
}

public Action Client_AddNewMap(int client, int args)
{
	db_InsertNewestMaps();
	return Plugin_Handled;
}

public int NewMapMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
		delete menu;
}


public void db_ViewNewestMaps(int client)
{
	char sql_selectNewestMaps[] = "SELECT mapname, date FROM ck_newmaps ORDER BY date DESC LIMIT 50";
	g_dDb.Query(sql_selectNewestMapsCallback, sql_selectNewestMaps, GetClientUserId(client), DBPrio_Low);
}

public void sql_selectNewestMapsCallback(Database db, DBResultSet results, const char[] error, int userid)
{
	if (db == null || strlen(error))
	{
		LogError("[Surftimer] SQL Error (sql_selectNewestMapsCallback): %s", error);
		return;
	}

	char szMapName[64];
	char szDate[64];
	if (results.HasResults)
	{
		Menu menu = new Menu(NewMapMenuHandler);
		menu.SetTitle("New Maps: ");

		int i = 1;
		char szItem[128];
		while (results.FetchRow())
		{
			results.FetchString(0, szMapName, sizeof(szMapName));
			results.FetchString(1, szDate, sizeof(szDate));
			Format(szItem, sizeof(szItem), "%s since %s", szMapName, szDate);
			menu.AddItem("", szItem, ITEMDRAW_DISABLED);
			i++;
		}
		if (i == 1)
		{
			delete menu;
		}
		else
		{
			menu.OptionFlags = MENUFLAG_BUTTON_EXIT;
			int client = GetClientUserId(userid);

			if (IsClientInGame(client))
			{
				DisplayMenu(menu, client, MENU_TIME_FOREVER);
			}
			else
			{
				delete menu;
			}
		}
	}
}

public void db_InsertNewestMaps()
{
	char szQuery[512];
	Format(szQuery, sizeof(szQuery), "INSERT INTO ck_newmaps (mapname) VALUES('%s');", g_szMapName);
	g_dDb.Query(SQL_CheckCallback, szQuery, DBPrio_Low);
}

//update Database just incase
public void db_present()
{
	// Check for db upgrades
	g_dDb.Query(sqlCheckNewMaps, "SELECT mapname FROM ck_newmaps LIMIT 1");
}

public void sqlCheckNewMaps(Database db, DBResultSet results, const char[] error, any data)
{
	if (db == null || strlen(error))
	{
		LogError("[surftimer] SQL Error (sqlCheckNewMaps): %s", error);
		return;
	}

	if (!results.HasResults)
	{
		db_upgradeDbNewMap();
	}
}

public void db_upgradeDbNewMap()
{
	g_dDb.Query(sqlCreateNewMaps, "CREATE TABLE IF NOT EXISTS ck_newmaps (mapname VARCHAR(32), date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY(mapname)) DEFAULT CHARSET=utf8mb4;");
}

public void sqlCreateNewMaps(Database db, DBResultSet results, const char[] error, any data)
{
	if (db == null || strlen(error))
	{
		LogError("[surftimer] SQL Error (sqlCreateNewMaps): %s", error);
		return;
	}
}
