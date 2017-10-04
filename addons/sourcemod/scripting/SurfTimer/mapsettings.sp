public void setMapSettings()
{
  SetConVarFloat(g_hStartPreSpeed, g_fStartPreSpeed, true, true);
  SetConVarFloat(g_hSpeedPreSpeed, g_fStartPreSpeed, true, true);
  SetConVarFloat(g_hBonusPreSpeed, g_fBonusPreSpeed, true, true);
  SetConVarFloat(g_hMaxVelocity, g_fMaxVelocity, true, true);
  SetConVarFloat(g_hAnnounceRecord, g_fAnnounceRecord, true, true);
  SetConVarBool(g_hGravityFix, g_bGravityFix, true, true);
}

public Action Command_SetStartPreSpeed(int client, int args)
{
  if (!IsValidClient(client))
  return Plugin_Handled;

  if (!CheckCommandAccess(client, "", ADMFLAG_CUSTOM2))
    return Plugin_Handled;

  char arg[128];
  if(args == 0)
  {
    PrintToChat(client, "Current Start Prespeed: %f", g_fStartPreSpeed);
    return Plugin_Handled;
  }

  GetCmdArg(1, arg, 128);
  g_iMapSettingType[client] = 1;
  db_updateMapSettings(client, arg);

  return Plugin_Handled;
}

public Action Command_SetBonusPreSpeed(int client, int args)
{
  if (!IsValidClient(client))
  return Plugin_Handled;

  if (!CheckCommandAccess(client, "", ADMFLAG_CUSTOM2))
    return Plugin_Handled;

  char arg[128];
  if(args == 0)
  {
    PrintToChat(client, "Current Bonus Prespeed: %f", g_fBonusPreSpeed);
    return Plugin_Handled;
  }

  GetCmdArg(1, arg, 128);
  g_iMapSettingType[client] = 2;
  db_updateMapSettings(client, arg);

  return Plugin_Handled;
}

public Action Command_SetStagePreSpeed(int client, int args)
{
  if (!IsValidClient(client))
  return Plugin_Handled;

  if (!CheckCommandAccess(client, "", ADMFLAG_CUSTOM2))
    return Plugin_Handled;

  char arg1[128];
  char arg2[128];
  if(args == 0)
  {
    PrintToChat(client, " %cSurftimer %c| Usage: sm_stageps [#stage/prespeed] [prespeed]", LIMEGREEN, WHITE);
    return Plugin_Handled;
  }

  GetCmdArg(1, arg1, 128);
  if(StrContains(arg1, "#", false) != -1)
  {
    ReplaceString(arg1, 128, "#", "", false);
    int stageSelect;
    stageSelect = StringToInt(arg1);

    if(stageSelect > g_TotalStages || stageSelect < 2)
    {
      PrintToChat(client, " %cSurftimer %c| Invalid stage", LIMEGREEN, WHITE);
      return Plugin_Handled;
    }

    GetCmdArg(2, arg2, 128);
    db_updateStageMapSettings(client, arg2, stageSelect);
    PrintToChatAll(" %cSurftimer %c| Stage %i prespeed changed to %c%s", LIMEGREEN, WHITE, stageSelect, LIMEGREEN, arg2);
  }
  else
  {
    db_updateStageMapSettings(client, arg1, 0);
    PrintToChatAll(" %cSurftimer %c| All stages prespeed changed to %c%s", LIMEGREEN, WHITE, LIMEGREEN, arg1);
  }

  return Plugin_Handled;
}

public Action Command_SetMaxVelocity(int client, int args)
{
  if (!IsValidClient(client))
  return Plugin_Handled;

  if (!CheckCommandAccess(client, "", ADMFLAG_CUSTOM2))
    return Plugin_Handled;

  char arg[128];
  if(args == 0)
  {
    PrintToChat(client, "Current sv_maxvelocity: %f", g_fMaxVelocity);
    return Plugin_Handled;
  }

  GetCmdArg(1, arg, 128);
  g_iMapSettingType[client] = 3;
  db_updateMapSettings(client, arg);
  PrintToChatAll("Server cvar 'sv_maxvelocity' changed to %s", arg);

  return Plugin_Handled;
}

public Action Command_SetAnnounceRecord(int client, int args)
{
  if (!IsValidClient(client))
  return Plugin_Handled;

  if (!CheckCommandAccess(client, "", ADMFLAG_CUSTOM2))
    return Plugin_Handled;

  char arg[128];
  if(args == 0)
  {
    PrintToChat(client, "Current Announce Record: %f (0 = All Finishes, 1 = PB Only, 2 = WR Only)", g_fAnnounceRecord);
    return Plugin_Handled;
  }

  GetCmdArg(1, arg, 128);
  g_iMapSettingType[client] = 4;
  db_updateMapSettings(client, arg);
  PrintToChat(client, "(0 = All Finishes, 1 = PB Only, 2 = WR Only)");

  return Plugin_Handled;
}

public Action Command_SetGravityFix(int client, int args)
{
  if (!IsValidClient(client))
    return Plugin_Handled;

  if (!CheckCommandAccess(client, "", ADMFLAG_CUSTOM2))
    return Plugin_Handled;

  if (args == 0)
  {
    if (g_bGravityFix)
      ReplyToCommand(client, " %cSurftimer %c| Usage: sm_gravityfix <0/1> (0 Disabled, 1 Enabled) (Gravity Fix currently %cenabled%c)", LIMEGREEN, WHITE, GREEN, WHITE);
    else
      ReplyToCommand(client, " %cSurftimer %c| Usage: sm_gravityfix <0/1> (0 Disabled, 1 Enabled) (Gravity Fix currently %cdisabled%c)", LIMEGREEN, WHITE, DARKRED, WHITE);

    return Plugin_Handled;
  }

  char arg[128];
  GetCmdArg(1, arg, 128);
  g_iMapSettingType[client] = 5;
  db_updateMapSettings(client, arg);

  return Plugin_Handled;
}

public void db_viewMapSettings()
{
  char szQuery[2048];
  Format(szQuery, 2048, "SELECT `mapname`, `startprespeed`, `bonusprespeed`, `stageprespeed2`, `stageprespeed3`, `stageprespeed4`, `stageprespeed5`, `stageprespeed6`, `stageprespeed7`, `stageprespeed8`, `stageprespeed9`, `stageprespeed10`, `stageprespeed11`, `stageprespeed12`, `stageprespeed13`, `stageprespeed14`, `stageprespeed15`, `stageprespeed16`, `stageprespeed17`, `stageprespeed18`, `stageprespeed19`, `stageprespeed20`, `stageprespeed21`, `stageprespeed22`, `stageprespeed23`, `stageprespeed24`, `stageprespeed25`, `stageprespeed26`, `stageprespeed27`, `stageprespeed28`, `stageprespeed29`, `stageprespeed30`, `stageprespeed31`, `stageprespeed32`, `stageprespeed33`, `stageprespeed34`, `stageprespeed35`, `maxvelocity`, `announcerecord`, `gravityfix` FROM `ck_mapsettings` WHERE `mapname` = '%s'", g_szMapName);
  SQL_TQuery(g_hDb, sql_viewMapSettingsCallback, szQuery, DBPrio_Low);
}

public void sql_viewMapSettingsCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
  if (hndl == null)
  {
    LogError("[surftimer] SQL Error (sql_viewMapSettingsCallback): %s", error);
  }

  if (SQL_HasResultSet(hndl) && SQL_GetRowCount(hndl) > 0)
  {
    while (SQL_FetchRow(hndl))
    {
      g_fStartPreSpeed = SQL_FetchFloat(hndl, 1);
      g_fBonusPreSpeed = SQL_FetchFloat(hndl, 2);

      int k = 3;
      for (int i = 0; i <= 35; i++)
      {
        g_fStagePreSpeed[i] = SQL_FetchFloat(hndl, k);
        k++;
      }

      g_fMaxVelocity = SQL_FetchFloat(hndl, 37);
      g_fAnnounceRecord = SQL_FetchFloat(hndl, 38);
      g_bGravityFix = view_as<bool>(SQL_FetchInt(hndl, 39));
    }
    setMapSettings();
  }
  else
  {
    char szQuery[2048];
    Format(szQuery, 2048, "INSERT INTO `ck_mapsettings` (`mapname`) VALUES ('%s')", g_szMapName);
    SQL_TQuery(g_hDb, sql_insertMapSettingsCallback, szQuery, DBPrio_Low);
  }
}

public void sql_insertMapSettingsCallback(Handle owner, Handle hndl, const char[] error, any pack)
{
  if (hndl == null)
  {
    LogError("[surftimer] SQL Error (sql_insertMapSettingsCallback): %s", error);
  }

  db_viewMapSettings();
}

public void db_updateMapSettings(int client, char[] arg)
{
  char szQuery[512];
  if (g_iMapSettingType[client] == 1)
    Format(szQuery, 512, "UPDATE `ck_mapsettings` SET `startprespeed` = '%s' WHERE `mapname` = '%s'", arg, g_szMapName);
  else if (g_iMapSettingType[client] == 2)
    Format(szQuery, 512, "UPDATE `ck_mapsettings` SET `bonusprespeed` = '%s' WHERE `mapname` = '%s'", arg, g_szMapName);
  else if (g_iMapSettingType[client] == 3)
    Format(szQuery, 512, "UPDATE `ck_mapsettings` SET `maxvelocity` = '%s' WHERE `mapname` = '%s'", arg, g_szMapName);
  else if (g_iMapSettingType[client] == 4)
    Format(szQuery, 512, "UPDATE `ck_mapsettings` SET `announcerecord` = '%s' WHERE `mapname` = '%s'", arg, g_szMapName);
  else if (g_iMapSettingType[client] == 5)
    Format(szQuery, 512, "UPDATE `ck_mapsettings` SET `gravityfix` = %s WHERE `mapname` = '%s'", arg, g_szMapName);


  SQL_TQuery(g_hDb, sql_insertMapSettingsCallback, szQuery, DBPrio_Low);
}

public void db_updateStageMapSettings(int client, char[] prespeed, int stage)
{
  char szQuery[2048];
  if(stage == 0)
  Format(szQuery, 2048, "UPDATE `ck_mapsettings` SET `stageprespeed2` = '%s', `stageprespeed3` = '%s', `stageprespeed4` = '%s', `stageprespeed5` = '%s', `stageprespeed6` = '%s', `stageprespeed7` = '%s', `stageprespeed8` = '%s', `stageprespeed9` = '%s', `stageprespeed10` = '%s', `stageprespeed11` = '%s', `stageprespeed12` = '%s', `stageprespeed13` = '%s', `stageprespeed14` = '%s', `stageprespeed15` = '%s', `stageprespeed16` = '%s', `stageprespeed17` = '%s', `stageprespeed18` = '%s', `stageprespeed19` = '%s', `stageprespeed20` = '%s', `stageprespeed21` = '%s', `stageprespeed22` = '%s', `stageprespeed23` = '%s', `stageprespeed24` = '%s', `stageprespeed25` = '%s', `stageprespeed26` = '%s', `stageprespeed27` = '%s', `stageprespeed28` = '%s', `stageprespeed29` = '%s', `stageprespeed30` = '%s', `stageprespeed31` = '%s', `stageprespeed32` = '%s', `stageprespeed33` = '%s', `stageprespeed34` = '%s', `stageprespeed35` = '%s' WHERE `mapname` = '%s'", prespeed, prespeed, prespeed, prespeed, prespeed, prespeed, prespeed, prespeed, prespeed, prespeed, prespeed, prespeed, prespeed, prespeed, prespeed, prespeed, prespeed, prespeed, prespeed, prespeed, prespeed, prespeed, prespeed, prespeed, prespeed, prespeed, prespeed, prespeed, prespeed, prespeed, prespeed, prespeed, prespeed, prespeed, g_szMapName);
  else
  Format(szQuery, 2048, "UPDATE `ck_mapsettings` SET `stageprespeed%i` = '%s' WHERE `mapname` = '%s'", stage, prespeed, g_szMapName);

  SQL_TQuery(g_hDb, sql_insertMapSettingsCallback, szQuery, DBPrio_Low);
}
