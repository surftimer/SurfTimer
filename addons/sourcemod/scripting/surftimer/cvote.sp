char votetype[32];
char mapnameforvote[64];

Handle mapTime;

public void GetCurrentMaptime()
{
	mapTime = FindConVar("mp_timelimit");
}

public void extendMap(int seconds)
{
	ExtendMapTimeLimit(seconds);
	GetCurrentMaptime();
}

public Action start_vote(int client, int args)
{
	if (!IsValidClient(client))
	return Plugin_Handled;

	if (IsVoteInProgress())
	{
		CPrintToChat(client, "%t", "VoteInProgress", g_szChatPrefix);
		return Plugin_Handled;
	}
	else if (args < 1)
	{
		CPrintToChat(client, "%t", "CVote2", g_szChatPrefix);
	}

	GetCmdArg(1, votetype, sizeof(votetype));
	GetCmdArg(2, mapnameforvote, sizeof(mapnameforvote));

	char szPlayerName[MAX_NAME_LENGTH];
	GetClientName(client, szPlayerName, MAX_NAME_LENGTH);

	if (strcmp(votetype, "extend", false) == 0)
	{
		Menu menu = CreateMenu(Handle_VoteMenuExtend);
		SetMenuTitle(menu, "Extend the map by 10 minutes?");
		AddMenuItem(menu, "yes", "Yes");
		AddMenuItem(menu, "no", "No");
		SetMenuExitButton(menu, false);
		VoteMenuToAll(menu, 20);
		CPrintToChatAll("%t", "VoteStartedBy", g_szChatPrefix, szPlayerName);
	}
	else if (strcmp(votetype, "changemap", false) == 0 && strcmp(mapnameforvote, "", false) == 0)
	{
		CPrintToChat(client, "%t", "CVote4", g_szChatPrefix);
	}
	else if (strcmp(votetype, "changemap", false) == 0)
	{
		Menu menu = CreateMenu(Handle_VoteMenuChangeMap);
		SetMenuTitle(menu, "Change map to %s?", mapnameforvote);
		AddMenuItem(menu, "yes", "Yes");
		AddMenuItem(menu, "no", "No");
		SetMenuExitButton(menu, false);
		VoteMenuToAll(menu, 20);
		CPrintToChatAll("%t", "CVote5", g_szChatPrefix, mapnameforvote, szPlayerName);
	}
	else if (strcmp(votetype, "setnextmap", false) == 0 && strcmp(mapnameforvote, "", false) == 0)
	{
		CPrintToChat(client, "%t", "CVote6", g_szChatPrefix);
	}
	else if (strcmp(votetype, "setnextmap", false) == 0)
	{
		Menu menu = CreateMenu(Handle_VoteMenuSetNextMap);
		SetMenuTitle(menu, "Set next map to %s?", mapnameforvote);
		AddMenuItem(menu, "yes", "Yes");
		AddMenuItem(menu, "no", "No");
		SetMenuExitButton(menu, false);
		VoteMenuToAll(menu, 20);
		CPrintToChatAll("%t", "CVote7", g_szChatPrefix, mapnameforvote, szPlayerName);
	}
	return Plugin_Handled;
}

// sm_cvote extend
public int Handle_VoteMenuExtend(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		/* This is called after VoteEnd */
		delete menu;
	}
	else if (action == MenuAction_VoteEnd)
	{
		char item[64], display[64];
		float percent, limit;
		int votes, totalVotes;

		menu.GetItem(param1, item, sizeof(item), _, display, sizeof(display));
		GetMenuVoteInfo(param2, votes, totalVotes);

		if (strcmp(item, VOTE_NO) == 0 && param1 == 1)
		{
			votes = totalVotes - votes;
		}

		percent = float(votes / totalVotes);

		GetCurrentMaptime();
		int iTimeLimit = GetConVarInt(mapTime);

		if (iTimeLimit >= 90)
			limit = 0.75;
		else
			limit = 0.50;

		/* 0=yes, 1=no */
		if ((strcmp(item, VOTE_YES) == 0 && FloatCompare(percent,limit) < 0 && param1 == 0) || (strcmp(item, VOTE_NO) == 0 && param1 == 1))
		{
			CPrintToChatAll("%t", "CVote8", g_szChatPrefix, RoundToNearest(100.0*limit), RoundToNearest(100.0*percent), totalVotes);
		}
		else
		{
			CPrintToChatAll("%t", "CVote9", g_szChatPrefix, RoundToNearest(100.0*percent), totalVotes);
			CPrintToChatAll("%t", "CVote10", g_szChatPrefix);
			extendMap(600);
		}
	}
}

public int Handle_VoteMenuChangeMap(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		delete menu;
	}
	else if (action == MenuAction_VoteEnd)
	{
		/* 0=yes, 1=no */
		if (param1 == 0) // yes
		{
			CreateTimer(5.0, Change_Map, _, TIMER_FLAG_NO_MAPCHANGE);
			CPrintToChatAll("%t", "CVote11", g_szChatPrefix, mapnameforvote);
		}
		else // No
		{
			CPrintToChatAll("%t", "CVote12", g_szChatPrefix);
		}
	}
}

// Change Map
public Action Change_Map(Handle timer)
{
	ServerCommand("sm_rcon changelevel %s", mapnameforvote);
}

// sm_cvote setnextmap
public int Handle_VoteMenuSetNextMap(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		/* This is called after VoteEnd */
		delete menu;
	}
	else if (action == MenuAction_VoteEnd)
	{
		/* 0=yes, 1=no */
		if (param1 == 0) // yes
		{
			ServerCommand("sm_setnextmap %s", mapnameforvote);
			CPrintToChatAll("%t", "CVote13", g_szChatPrefix, mapnameforvote);
		}
		else // No
		{
			CPrintToChatAll("%t", "CVote12", g_szChatPrefix);
		}
	}
}
