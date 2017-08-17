public Action ColorMenu(int client, int args)
{
	if (!IsClientInGame(client))
	{
		return Plugin_Handled;
	}

	if (g_iVipLvl[client] > 1)
		PaintColourMenu(client);
	else
		ReplyToCommand(client, " %cSurfTimer %c| This is a SuperVIP feature", LIMEGREEN, WHITE);

	return Plugin_Handled;
}

public void PaintColourMenu(int client)
{
	Handle hMenu = CreateMenu(MenuHandle_ChooseColor);
	SetMenuTitle(hMenu, "Pick a color:");

	AddMenuItem(hMenu, "-1", "Rainbow");
	AddMenuItem(hMenu, "0", "Black");
	AddMenuItem(hMenu, "1", "Black Medium");
	AddMenuItem(hMenu, "2", "Blue");
	AddMenuItem(hMenu, "3", "Blue Medium");
	AddMenuItem(hMenu, "4", "Brown");
	AddMenuItem(hMenu, "5", "Brown Medium");
	AddMenuItem(hMenu, "6", "Cyan");
	AddMenuItem(hMenu, "7", "Cyan Medium");
	AddMenuItem(hMenu, "8", "Darkgreen");
	AddMenuItem(hMenu, "9", "Darkgreen Medium");
	AddMenuItem(hMenu, "10", "Green");
	AddMenuItem(hMenu, "11", "Green Medium");
	AddMenuItem(hMenu, "12", "LightBlue");
	AddMenuItem(hMenu, "13", "LightBlue Medium");
	AddMenuItem(hMenu, "14", "Lightpink");
	AddMenuItem(hMenu, "15", "Lightpink Medium");
	AddMenuItem(hMenu, "16", "Orange");
	AddMenuItem(hMenu, "17", "Orange Medium");
	AddMenuItem(hMenu, "18", "Pink");
	AddMenuItem(hMenu, "19", "Pink Medium");
	AddMenuItem(hMenu, "20", "Purple");
	AddMenuItem(hMenu, "21", "Purple Medium");
	AddMenuItem(hMenu, "22", "Red");
	AddMenuItem(hMenu, "23", "Red Medium");
	AddMenuItem(hMenu, "24", "White");
	AddMenuItem(hMenu, "25", "White Medium");
	AddMenuItem(hMenu, "26", "Yellow");
	AddMenuItem(hMenu, "27", "Yellow Medium");

	SetMenuOptionFlags(hMenu, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
	return;
}

public Action StartDraw(int client, int args)
{
	if (!IsClientInGame(client))
	{
		return Plugin_Handled;
	}

	if (g_iVipLvl[client] >= 2)
		bPaintMode[client] = true;

	return Plugin_Handled;
}

public Action EndDraw(int client, int args)
{
	if (!IsClientInGame(client))
	{
		ReplyToCommand(client, " %cSurfTimer %c| You do not have access to this commnad", LIMEGREEN, WHITE);
		return Plugin_Handled;
	}

	if (g_iVipLvl[client] >= 2)
		bPaintMode[client] = false;

	return Plugin_Handled;
}

public Action OnPaintParse(Handle timer)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i) && bPaintMode[i] && IsPlayerAlive(i) && IsClientConnected(i))
		{
			float fPos[3];
			if (GetClientEndPoint(i, fPos))
			{
				int color = iChosenColor[i] == -1 ? GetRandomInt(0, g_SpritesAmount - 1) : iChosenColor[i];
				TE_SetupWorldDecal(fPos, 0, g_SpritesVMTIndexes[color]);
				TE_SendToAll();
			}
		}
	}
}

void TE_SetupWorldDecal(const float[3] vecOrigin, int entity, int index)
{
	TE_Start("World Decal");
	TE_WriteVector("m_vecOrigin", vecOrigin);
//	TE_WriteNum("m_nEntity", entity);
	TE_WriteNum("m_nIndex", index);
}

bool GetClientEndPoint(int client, float fPos[3])
{
	float fOrigin[3];
	GetClientEyePosition(client, fOrigin);

	float fAngles[3];
	GetClientEyeAngles(client, fAngles);

	Handle hTrace = TR_TraceRayFilterEx(fOrigin, fAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
	bool bHit = TR_DidHit(hTrace);

	TR_GetEndPosition(fPos, hTrace);

	CloseHandle(hTrace);
	return bHit;

}

public bool TraceEntityFilterPlayer(int entity, int contentsMask)
{
	return entity > GetMaxClients() || !entity;
}

public int MenuHandle_ChooseColor(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char sID[12]; char sDisplay[64];
			GetMenuItem(menu, param2, sID, sizeof(sID), _, sDisplay, sizeof(sDisplay));
			iChosenColor[param1] = StringToInt(sID);
			PrintToChat(param1, " %cSurfTimer%c | You've chosen the colour %s", MOSSGREEN, WHITE, sDisplay);
		}
		case MenuAction_End:
		{
			CloseHandle(menu);
		}
	}
}
