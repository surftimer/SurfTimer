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
		int iWinVotes, iTotalVotes;

		menu.GetItem(param1, item, sizeof(item), _, display, sizeof(display));
		GetMenuVoteInfo(param2, iWinVotes, iTotalVotes);

		float winVotes = float(iWinVotes);
		float totalVotes = float(iTotalVotes);
		float votes = 0.0;

		if (strcmp(item, VOTE_NO) == 0 && param1 == 1)
		{
			votes = totalVotes - winVotes;
		}

		percent = votes / totalVotes;

		GetCurrentMaptime();
		int iTimeLimit = GetConVarInt(mapTime);

		if (iTimeLimit >= 90)
			limit = 0.75;
		else
			limit = 0.50;

		/* 0=yes, 1=no */
		if ((strcmp(item, VOTE_YES) == 0 && FloatCompare(percent,limit) < 0 && param1 == 0) || (strcmp(item, VOTE_NO) == 0 && param1 == 1))
		{
			CPrintToChatAll("%t", "CVote8", g_szChatPrefix, RoundToNearest(100.0*limit), RoundToNearest(100.0*percent), iTotalVotes);
		}
		else
		{
			CPrintToChatAll("%t", "CVote9", g_szChatPrefix, RoundToNearest(100.0*percent), iTotalVotes);
			CPrintToChatAll("%t", "CVote10", g_szChatPrefix);
			extendMap(600);
		}
	}
}


// Change Map
public Action Change_Map(Handle timer)
{
	ServerCommand("sm_rcon changelevel %s", mapnameforvote);
}
