/*--------------------------------------------------
            Trails-Chroma -> SurfTimer
     merge by Ace - original code by Nickelony

    https://github.com/Nickelony/Trails-Chroma
--------------------------------------------------*/

public void OnConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	gB_PluginEnabled = gCV_PluginEnabled.BoolValue;
	gB_AdminsOnly = gCV_AdminsOnly.BoolValue;
	gB_AllowHide = gCV_AllowHide.BoolValue;
	gB_CheapTrails = gCV_CheapTrails.BoolValue;
	gF_BeamLife = gCV_BeamLife.FloatValue;
	gF_BeamWidth = gCV_BeamWidth.FloatValue;
	gB_RespawnDisable = gCV_RespawnDisable.BoolValue;
}

public void OnClientCookiesCached(int client)
{
	if(IsFakeClient(client))
	{
		return;
	}
	
	char[] sChoiceCookie = new char[8];
	GetClientCookie(client, gH_TrailChoiceCookie, sChoiceCookie, 8);
	
	bool bNoAccess = gB_AdminsOnly && !CheckCommandAccess(client, "sm_trails_override", ADMFLAG_RESERVATION);
	
	if(sChoiceCookie[0] == '\0' || bNoAccess) // If the cookie is empty or the player doesn't have access
	{
		IntToString(TRAIL_NONE, sChoiceCookie, 8);
		SetClientCookie(client, gH_TrailChoiceCookie, sChoiceCookie);
	}
	else
	{
		gI_SelectedTrail[client] = StringToInt(sChoiceCookie);
	}
	
	char[] sHidingCookie = new char[8];
	GetClientCookie(client, gH_TrailHidingCookie, sHidingCookie, 8);
	gB_HidingTrails[client] = StringToInt(sHidingCookie) == 1;
	
	if(IsValidClient(client) && !gB_HidingTrails[client] && aL_Clients.FindValue(client) == -1) // Only works after reloading the plugin
	{
		aL_Clients.Push(client);
	}
}

bool LoadColorsConfig()
{
	if (!gCV_Trails) return true;
	char[] sPath = new char[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, PLATFORM_MAX_PATH, "configs/surftimer/trails-colors.cfg");
	KeyValues kv = new KeyValues("trails-colors");
	
	if(!kv.ImportFromFile(sPath) || !kv.GotoFirstSubKey())
	{
		delete kv;
		return false;
	}
	
	int i = 0;
	
	do
	{
		kv.GetString("name", gS_TrailTitle[i], 128, "<MISSING TRAIL NAME>");
		
		gI_TrailSettings[i][iRedChannel] = kv.GetNum("red", 255);
		gI_TrailSettings[i][iGreenChannel] = kv.GetNum("green", 255);
		gI_TrailSettings[i][iBlueChannel] = kv.GetNum("blue", 255);
		gI_TrailSettings[i][iSpecialColor] = kv.GetNum("special", 0);
		gI_TrailSettings[i][iAlphaChannel] = kv.GetNum("alpha", 128);
		
		i++;
	}
	while(kv.GotoNextKey());
	
	delete kv;
	gI_TrailAmount = i;
	return true;
}

public Action Command_Hide(int client, int args)
{
	if (!gCV_Trails) return Plugin_Handled;
	if(!gB_PluginEnabled || !gB_AllowHide || !IsValidClient(client))
	{
		return Plugin_Handled;
	}
	
	gB_HidingTrails[client] = !gB_HidingTrails[client]; // Toggle it
	
	if(gB_HidingTrails[client])
	{
		int index = aL_Clients.FindValue(client);
		
		if(index != -1) // If the index is valid and the player was found on the list
		{
			aL_Clients.Erase(index);
		}
		
		PrintCenterText(client, "Other players' trails are now <font color='#FF00FF' face=''>Hidden</font>.");
		
		SetClientCookie(client, gH_TrailHidingCookie, "0");
	}
	else
	{
		aL_Clients.Push(client);
		
		PrintCenterText(client, "Other players' trails are now <font color='#FFFF00' face=''>Visible</font>.");
		
		SetClientCookie(client, gH_TrailHidingCookie, "1");
	}
	
	return Plugin_Handled;
}

public Action Command_Trail(int client, int args)
{
	if (!gCV_Trails) return Plugin_Handled;
	if(!gB_PluginEnabled || !IsValidClient(client))
	{
		return Plugin_Handled;
	}
	
	if(!g_iHasEnforcedTitle[client] && !IsPlayerVip(client))
	{
		PrintCenterText(client, "You do not have permission to use this command.");
		return Plugin_Handled;
	}
	
	return OpenTrailMenu(client, 0);
}

Action OpenTrailMenu(int client, int page)
{
	if (!gCV_Trails) return Plugin_Handled;
	Menu menu = new Menu(Menu_Handler);
	menu.SetTitle("Choose a trail:\n ");
	
	char[] sNone = new char[8];
	IntToString(TRAIL_NONE, sNone, 8);
	
	menu.AddItem(sNone, "None", (gI_SelectedTrail[client] == TRAIL_NONE)? ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
	
	for(int i = 0; i < gI_TrailAmount; i++)
	{
		char[] sInfo = new char[8];
		IntToString(i, sInfo, 8);
		
		if(StrEqual(gS_TrailTitle[i], "/empty/") || StrEqual(gS_TrailTitle[i], "/EMPTY/") || StrEqual(gS_TrailTitle[i], "{empty}") || StrEqual(gS_TrailTitle[i], "{EMPTY}"))
		{
			menu.AddItem("", "", ITEMDRAW_SPACER); // Empty line support
		}
		else
		{
			menu.AddItem(sInfo, gS_TrailTitle[i], (gI_SelectedTrail[client] == i)? ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
		}
	}
	
	menu.ExitButton = true;
	menu.DisplayAt(client, page, 60);
	
	return Plugin_Handled;
}

public int Menu_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if(action == MenuAction_Select)
	{
		char[] sInfo = new char[8];
		menu.GetItem(param2, sInfo, 8);
		
		MenuSelection(param1, sInfo);
		OpenTrailMenu(param1, GetMenuSelectionPosition());
	}
	else if(action == MenuAction_End)
	{
		delete menu;
	}
	
	return 0;
}

void MenuSelection(int client, char[] info)
{
	int choice = StringToInt(info);
	
	if(choice == TRAIL_NONE)
	{
		PrintCenterText(client, "Your trail is now <font color='#FF0000' face=''>DISABLED</font>.");
		
		StopSpectrumCycle(client);
	}
	else
	{
		int color[3];
		color[0] = gI_TrailSettings[choice][iRedChannel];
		color[1] = gI_TrailSettings[choice][iGreenChannel];
		color[2] = gI_TrailSettings[choice][iBlueChannel];
		
		char[] sHexColor = new char[16];
		FormatEx(sHexColor, 16, "#%02x%02x%02x", color[0], color[1], color[2]);
		
		if(gI_SelectedTrail[client] == TRAIL_NONE)
		{
			PrintCenterText(client, "Your trail is now <font color='#00FF00' face=''>ENABLED</font>.\nYour beam color is: <font color='%s' face=''>%s</font>.", sHexColor, gS_TrailTitle[choice]);
		}
		else
		{
			PrintCenterText(client, "Your beam color is now: <font color='%s' face=''>%s</font>.", sHexColor, gS_TrailTitle[choice]);
		}
		
		if(gI_TrailSettings[choice][iSpecialColor] == 1 || gI_TrailSettings[choice][iSpecialColor] == 2)
		{
			gI_CycleColor[client][0] = 0;
			gI_CycleColor[client][1] = 0;
			gI_CycleColor[client][2] = 0;
			gB_RedToYellow[client] = true;
		}
		else
		{
			StopSpectrumCycle(client);
		}
	}
	
	gI_SelectedTrail[client] = choice;
	SetClientCookie(client, gH_TrailChoiceCookie, info);
}

void StopSpectrumCycle(int client)
{
	gB_RedToYellow[client] = false;
	gB_YellowToGreen[client] = false;
	gB_GreenToCyan[client] = false;
	gB_CyanToBlue[client] = false;
	gB_BlueToMagenta[client] = false;
	gB_MagentaToRed[client] = false;
}

void ForceCheapTrails(int client)
{
	if(gI_TickCounter[client] == 0)
	{
		float fOrigin[3];
		GetClientAbsOrigin(client, fOrigin);
		
		gF_PlayerOrigin[client][0] = fOrigin[0];
		gF_PlayerOrigin[client][1] = fOrigin[1];
		gF_PlayerOrigin[client][2] = fOrigin[2];
	}
	
	gI_TickCounter[client]++;
	
	if(gI_TickCounter[client] <= 1)
	{
		return; // Skip 1 frame. That's 50% less sprites to render
	}
	
	gI_TickCounter[client] = 0;
	
	CreatePlayerTrail(client, gF_PlayerOrigin[client]);
	gF_LastPosition[client] = gF_PlayerOrigin[client];
}

void ForceExpensiveTrails(int client)
{
	float fOrigin[3];
	GetClientAbsOrigin(client, fOrigin);
	
	CreatePlayerTrail(client, fOrigin);
	gF_LastPosition[client] = fOrigin;
}

void CreatePlayerTrail(int client, float origin[3])
{
	bool bClientTeleported = GetVectorDistance(origin, gF_LastPosition[client], false) > 50.0;
	
	if(!gB_PluginEnabled || gI_SelectedTrail[client] == TRAIL_NONE || !IsPlayerAlive(client) || bClientTeleported)
	{
		return;
	}
	
	if(!g_iHasEnforcedTitle[client] && !IsPlayerVip(client))
	{
		return;
	}
	
	float fFirstPos[3];
	fFirstPos[0] = origin[0];
	fFirstPos[1] = origin[1];
	fFirstPos[2] = origin[2] + 5.0;
	
	float fSecondPos[3];
	fSecondPos[0] = gF_LastPosition[client][0];
	fSecondPos[1] = gF_LastPosition[client][1];
	fSecondPos[2] = gF_LastPosition[client][2] + 5.0;
	
	int color[4];
	GetClientTrailColors(client, color);
	
	TE_SetupBeamPoints(fFirstPos, fSecondPos, gI_BeamSprite, 0, 0, 0, gF_BeamLife, gF_BeamWidth, gF_BeamWidth, 10, 0.0, color, 0);
	SendTempEntity(client); // Oh damn...
}

int[] GetClientTrailColors(int client, int[] color)
{
	int choice = gI_SelectedTrail[client];
	color[3] = gI_TrailSettings[choice][iAlphaChannel];
	int stepsize = 0;
	
	if(gI_TrailSettings[choice][iSpecialColor] == 1) // Spectrum trail
	{
		stepsize = 1;
		DrawSpectrumTrail(client, stepsize);
		
		color[0] = gI_CycleColor[client][0];
		color[1] = gI_CycleColor[client][1];
		color[2] = gI_CycleColor[client][2];
	}
	else if(gI_TrailSettings[choice][iSpecialColor] == 2) // Wave trail
	{
		stepsize = 15;
		DrawSpectrumTrail(client, stepsize);
		
		color[0] = gI_CycleColor[client][0];
		color[1] = gI_CycleColor[client][1];
		color[2] = gI_CycleColor[client][2];
	}
	else if(gI_TrailSettings[choice][iSpecialColor] == 3) // Velocity trail
	{
		float fAbsVelocity[3];
		GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", fAbsVelocity);
		float fCurrentSpeed = SquareRoot(Pow(fAbsVelocity[0], 2.0) + Pow(fAbsVelocity[1], 2.0));
		
		DrawVelocityTrail(client, fCurrentSpeed);
		
		color[0] = gI_CycleColor[client][0];
		color[1] = gI_CycleColor[client][1];
		color[2] = gI_CycleColor[client][2];
	}
	else
	{
		color[0] = gI_TrailSettings[choice][iRedChannel];
		color[1] = gI_TrailSettings[choice][iGreenChannel];
		color[2] = gI_TrailSettings[choice][iBlueChannel];
	}
	
	#if defined DEBUG
	PrintCSGOHUDText(client, "%i\n%i\n%i", color[0], color[1], color[2]);
	#endif
	
	return;
}

void SendTempEntity(int client)
{
	if(gB_HidingTrails[client]) // If the player is hiding other players' trails
	{
		if(aL_Clients.Length == 0) // If there's nobody on the list (everyone has hiding enabled)
		{
			TE_SendToClient(client); // Send the trail to the current client only
		}
		else
		{
			int[] clientList = new int[aL_Clients.Length + 1];
			int arrayIndex = 0;
			
			for(int i = 0; i < aL_Clients.Length; i++) // That's basically "foreach(int clientIndex in aL_Clients)"
			{
				clientList[arrayIndex] = aL_Clients.Get(i);
				arrayIndex++;
			}
			
			clientList[arrayIndex] = client; // Add the current client to the array so he can see his own trail
			
			TE_Send(clientList, aL_Clients.Length + 1); // The client will send the trail to everyone but won't recieve any other trails
		}
	}
	else
	{
		if(aL_Clients.Length == 0) // If there's nobody on the list
		{
			return;
		}
		
		int[] clientList = new int[aL_Clients.Length];
		int arrayIndex = 0;
		
		for(int i = 0; i < aL_Clients.Length; i++) // foreach(int clientIndex in aL_Clients)
		{
			clientList[arrayIndex] = aL_Clients.Get(i);
			arrayIndex++;
		}
		
		TE_Send(clientList, aL_Clients.Length); // The client will send the trail to everyone and will revieve other players' trails as well
	}
}

void DrawSpectrumTrail(int client, int stepsize)
{
	if(gB_RedToYellow[client])
	{
		gB_MagentaToRed[client] = false;
		gI_CycleColor[client][0] = 255; gI_CycleColor[client][1] += stepsize; gI_CycleColor[client][2] = 0;
		
		if(gI_CycleColor[client][0] >= 255 && gI_CycleColor[client][1] >= 255 && gI_CycleColor[client][2] <= 0)
			gB_YellowToGreen[client] = true;
	}
	
	if(gB_YellowToGreen[client])
	{
		gB_RedToYellow[client] = false;
		gI_CycleColor[client][0] -= stepsize; gI_CycleColor[client][1] = 255; gI_CycleColor[client][2] = 0;
		
		if(gI_CycleColor[client][0] <= 0 && gI_CycleColor[client][1] >= 255 && gI_CycleColor[client][2] <= 0)
			gB_GreenToCyan[client] = true;
	}
	
	if(gB_GreenToCyan[client])
	{
		gB_YellowToGreen[client] = false;
		gI_CycleColor[client][0] = 0; gI_CycleColor[client][1] = 255; gI_CycleColor[client][2] += stepsize;
		
		if(gI_CycleColor[client][0] <= 0 && gI_CycleColor[client][1] >= 255 && gI_CycleColor[client][2] >= 255)
			gB_CyanToBlue[client] = true;
	}
	
	if(gB_CyanToBlue[client])
	{
		gB_GreenToCyan[client] = false;
		gI_CycleColor[client][0] = 0; gI_CycleColor[client][1] -= stepsize; gI_CycleColor[client][2] = 255;
		
		if(gI_CycleColor[client][0] <= 0 && gI_CycleColor[client][1] <= 0 && gI_CycleColor[client][2] >= 255)
			gB_BlueToMagenta[client] = true;
	}
	
	if(gB_BlueToMagenta[client])
	{
		gB_CyanToBlue[client] = false;
		gI_CycleColor[client][0] += stepsize; gI_CycleColor[client][1] = 0; gI_CycleColor[client][2] = 255;
		
		if(gI_CycleColor[client][0] >= 255 && gI_CycleColor[client][1] <= 0 && gI_CycleColor[client][2] >= 255)
			gB_MagentaToRed[client] = true;
	}
	
	if(gB_MagentaToRed[client])
	{
		gB_BlueToMagenta[client] = false;
		gI_CycleColor[client][0] = 255; gI_CycleColor[client][1] = 0; gI_CycleColor[client][2] -= stepsize;
		
		if(gI_CycleColor[client][0] >= 255 && gI_CycleColor[client][1] <= 0 && gI_CycleColor[client][2] <= 0)
			gB_RedToYellow[client] = true;
	}
}

void DrawVelocityTrail(int client, float currentspeed)
{
	int stepsize = 0;
	
	if(currentspeed <= 255.0)
	{
		gI_CycleColor[client][0] = 0; gI_CycleColor[client][1] = 0; gI_CycleColor[client][2] = 255;
	}
	else if(currentspeed > 255.0 && currentspeed <= 510.0)
	{
		stepsize = RoundToFloor(currentspeed) - 255;
		gI_CycleColor[client][0] = 0; gI_CycleColor[client][1] = stepsize; gI_CycleColor[client][2] = 255;
	}
	else if(currentspeed > 510.0 && currentspeed <= 765.0)
	{
		stepsize = RoundToFloor(-currentspeed) + 510;
		gI_CycleColor[client][0] = 0; gI_CycleColor[client][1] = 255; gI_CycleColor[client][2] = stepsize;
	}
	else if(currentspeed > 765.0 && currentspeed <= 1020.0)
	{
		stepsize = RoundToFloor(currentspeed) - 765;
		gI_CycleColor[client][0] = stepsize; gI_CycleColor[client][1] = 255; gI_CycleColor[client][2] = 0;
	}
	else if(currentspeed > 1020.0 && currentspeed <= 1275.0)
	{
		stepsize = RoundToFloor(-currentspeed) + 1020;
		gI_CycleColor[client][0] = 255; gI_CycleColor[client][1] = stepsize; gI_CycleColor[client][2] = 0;
	}
	else if(currentspeed > 1275.0 && currentspeed <= 1530.0)
	{
		stepsize = RoundToFloor(currentspeed) - 1275;
		gI_CycleColor[client][0] = 255; gI_CycleColor[client][1] = 0; gI_CycleColor[client][2] = stepsize;
	}
	else if(currentspeed > 1530.0 && currentspeed <= 1655.0)
	{
		stepsize = RoundToFloor(-currentspeed) + 1530;
		gI_CycleColor[client][0] = stepsize; gI_CycleColor[client][1] = 0; gI_CycleColor[client][2] = 255;
	}
	else
	{
		gI_CycleColor[client][0] = 125; gI_CycleColor[client][1] = 0; gI_CycleColor[client][2] = 255;
	}
}