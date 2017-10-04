char votetype[32];
char mapnameforvote[64];
//float g_fmptimelimit;

Handle mapTime;

public void GetCurrentMaptime()
{
  mapTime = FindConVar("mp_timelimit");
  //g_fmptimelimit = GetConVarFloat(mapTime);
}

/*public int GetCurrentMaptime()
{
char buffer[128];

mapTime.GetString(buffer, 128);

return StringToInt(buffer);
}*/

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
    PrintToChat(client, "[SM] Vote is already in progress.");
    return Plugin_Handled;
  }
  else if (args < 1)
  {
    PrintToChat(client, " %cSurftimer %c| Usage: sm_cvote <extend, changemap, setnextmap> <mapname>", LIMEGREEN, WHITE);
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
    CPrintToChatAll(" %cSurftimer %c| Vote to Extend started by %c%s", LIMEGREEN, WHITE, LIMEGREEN, szPlayerName);
  }
  else if(strcmp(votetype, "changemap", false) == 0 && strcmp(mapnameforvote, "", false) == 0)
  {
    PrintToChat(client, " %cSurftimer %c| Usage: sm_cvote <changemap> <mapname>", LIMEGREEN, WHITE);
  }
  else if(strcmp(votetype, "changemap", false) == 0)
  {
    Menu menu = CreateMenu(Handle_VoteMenuChangeMap);
    SetMenuTitle(menu, "Change map to %s?", mapnameforvote);
    AddMenuItem(menu, "yes", "Yes");
    AddMenuItem(menu, "no", "No");
    SetMenuExitButton(menu, false);
    VoteMenuToAll(menu, 20);
    CPrintToChatAll(" %cSurftimer %c| Vote to change map to %c%s started by %c%s", LIMEGREEN, WHITE, BLUE, mapnameforvote, LIMEGREEN, szPlayerName);
  }
  else if(strcmp(votetype, "setnextmap", false) == 0 && strcmp(mapnameforvote, "", false) == 0)
  {
    PrintToChat(client, " %cSurftimer %c| Usage: sm_cvote <setnextmap> <mapname>", LIMEGREEN, WHITE);
  }
  else if(strcmp(votetype, "setnextmap", false) == 0)
  {
    Menu menu = CreateMenu(Handle_VoteMenuSetNextMap);
    SetMenuTitle(menu, "Set next map to %s?", mapnameforvote);
    AddMenuItem(menu, "yes", "Yes");
    AddMenuItem(menu, "no", "No");
    SetMenuExitButton(menu, false);
    VoteMenuToAll(menu, 20);
    CPrintToChatAll(" %cSurftimer %c| Vote to set next map to %c%s started by %c%s", LIMEGREEN, WHITE, BLUE, mapnameforvote, LIMEGREEN, szPlayerName);
  }
  return Plugin_Handled;
}

//sm_cvote extend
public int Handle_VoteMenuExtend(Menu menu, MenuAction action, int param1, int param2)
{
  if (action == MenuAction_End)
  {
    /* This is called after VoteEnd */
    CloseHandle(menu);
  }
  else if (action == MenuAction_VoteEnd)
  {
    char item[64], display[64];
    float percent, limit;
    int votes, totalVotes;

    menu.GetItem(param1, item, sizeof(item), _, display, sizeof(display));
    GetMenuVoteInfo(param2, votes, totalVotes);

    if (strcmp(item, VOTE_NO) == 0 && param1 == 1)
      votes = totalVotes - votes;

    percent = FloatDiv(float(votes),float(totalVotes));

    GetCurrentMaptime();
    int iTimeLimit = GetConVarInt(mapTime);

    if (iTimeLimit >= 90)
      limit = 0.75;
    else
      limit = 0.50;

    /* 0=yes, 1=no */
    if ((strcmp(item, VOTE_YES) == 0 && FloatCompare(percent,limit) < 0 && param1 == 0) || (strcmp(item, VOTE_NO) == 0 && param1 == 1))
    {
      PrintToChatAll(" %cSurftimer %c| Vote failed. %i%c vote required. (Received %i%c of %i votes)", LIMEGREEN, WHITE, RoundToNearest(100.0*limit), PERCENT, RoundToNearest(100.0*percent), PERCENT, totalVotes);
    }
    else
    {
      PrintToChatAll(" %cSurftimer %c| Vote successful. (Received %i%c of %i votes)", LIMEGREEN, WHITE, RoundToNearest(100.0*percent), PERCENT, totalVotes);
      PrintToChatAll(" %cSurftimer %c| Extending map by 10 minutes.", LIMEGREEN, WHITE);
      extendMap(600);
    }
  }
}

public int Handle_VoteMenuChangeMap(Menu menu, MenuAction action, int param1, int param2)
{
  if (action == MenuAction_End)
  {
    CloseHandle(menu);
  }
  else if (action == MenuAction_VoteEnd)
  {
    /* 0=yes, 1=no */
    if (param1 == 0) // yes
    {
      CreateTimer(5.0, Change_Map, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE);
      PrintToChatAll("[SM] Changing map to %s.", mapnameforvote);
    }
    else // No
    {
      PrintToChatAll(" %cSurftimer %c| Vote failed.", LIMEGREEN, WHITE);
    }
  }
}

//change map
public Action Change_Map(Handle timer)
{
  ServerCommand("sm_rcon changelevel %s", mapnameforvote);
}

//sm_cvote setnextmap
public int Handle_VoteMenuSetNextMap(Menu menu, MenuAction action, int param1, int param2)
{
  if (action == MenuAction_End)
  {
    /* This is called after VoteEnd */
    CloseHandle(menu);
  }
  else if (action == MenuAction_VoteEnd)
  {
    /* 0=yes, 1=no */
    if (param1 == 0) // yes
    {
      ServerCommand("sm_setnextmap %s", mapnameforvote);
      PrintToChatAll("[SM] Set next map to %s.", mapnameforvote);
    }
    else // No
    {
      PrintToChatAll("[SM] Vote failed.");
    }
  }
}
