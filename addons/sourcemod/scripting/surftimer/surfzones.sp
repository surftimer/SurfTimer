public void CreateZoneEntity(int zoneIndex)
{
	float fMiddle[3], fMins[3], fMaxs[3];
	char sZoneName[64];
	char szHookName[128];

	if (g_mapZones[zoneIndex].PointA[0] == -1.0 && g_mapZones[zoneIndex].PointA[1] == -1.0 && g_mapZones[zoneIndex].PointA[2] == -1.0)
	{
		return;
	}

	Array_Copy(g_mapZones[zoneIndex].PointA, fMins, 3);
	Array_Copy(g_mapZones[zoneIndex].PointB, fMaxs, 3);

	Format(sZoneName, sizeof(sZoneName), "%s", g_mapZones[zoneIndex].ZoneName);
	Format(szHookName, sizeof(szHookName), "%s", g_mapZones[zoneIndex].HookName);

	if (!StrEqual(szHookName, "None"))
	{
		int iEnt;
		for (int i = 0; i < GetArraySize(g_hTriggerMultiple); i++)
		{
			iEnt = GetArrayCell(g_hTriggerMultiple, i);

			if (IsValidEntity(iEnt))
			{
				char szTriggerName[128];
				GetEntPropString(iEnt, Prop_Send, "m_iName", szTriggerName, 128, 0);

				if (StrEqual(szHookName, szTriggerName))
				{
					Format(sZoneName, sizeof(sZoneName), "sm_ckZoneHooked %i", zoneIndex);
					float position[3];
					// come back
					GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", position);
					GetEntPropVector(iEnt, Prop_Send, "m_vecMins", fMins);
					GetEntPropVector(iEnt, Prop_Send, "m_vecMaxs", fMaxs);

					g_mapZones[zoneIndex].CenterPoint[0] = position[0];
					g_mapZones[zoneIndex].CenterPoint[1] = position[1];
					g_mapZones[zoneIndex].CenterPoint[2] = position[2];
					// g_mapZones[zoneIndex].ZoneType

					for (int j = 0; j < 3; j++)
					{
						fMins[j] = (fMins[j] + position[j]);
					}

					for (int j = 0; j < 3; j++)
					{
						fMaxs[j] = (fMaxs[j] + position[j]);
					}

					g_mapZones[zoneIndex].PointA[0] = fMins[0];
					g_mapZones[zoneIndex].PointA[1] = fMins[1];
					g_mapZones[zoneIndex].PointA[2] = fMins[2];
					g_mapZones[zoneIndex].PointB[0] = fMaxs[0];
					g_mapZones[zoneIndex].PointB[1] = fMaxs[1];
					g_mapZones[zoneIndex].PointB[2] = fMaxs[2];

					for (int j = 0; j < 3; j++)
					{
						g_fZoneCorners[zoneIndex][0][j] = g_mapZones[zoneIndex].PointA[j];
						g_fZoneCorners[zoneIndex][7][j] = g_mapZones[zoneIndex].PointB[j];
					}

					for(int j = 1; j < 7; j++)
					{
						for(int k = 0; k < 3; k++)
						{
							g_fZoneCorners[zoneIndex][j][k] = g_fZoneCorners[zoneIndex][((j >> (2-k)) & 1) * 7][k];
						}
					}

					DispatchKeyValue(iEnt, "targetname", sZoneName);

					SDKHook(iEnt, SDKHook_StartTouch, StartTouchTrigger);
					SDKHook(iEnt, SDKHook_EndTouch, EndTouchTrigger);

					DispatchKeyValue(iEnt, "m_iClassname", "hooked");
				}
			}
		}
	}
	else
	{
		int iEnt = CreateEntityByName("trigger_multiple");

		if (iEnt > 0 && IsValidEntity(iEnt))
		{
			SetEntityModel(iEnt, ZONE_MODEL);
			// Spawnflags:	1 - only a player can trigger this by touch, makes it so a NPC cannot fire a trigger_multiple
			// 2 - Won't fire unless triggering ent's view angles are within 45 degrees of trigger's angles (in addition to any other conditions), so if you want the player to only be able to fire the entity at a 90 degree angle you would do ",angles,0 90 0," into your spawnstring.
			// 4 - Won't fire unless player is in it and pressing use button (in addition to any other conditions), you must make a bounding box,(max\mins) for this to work.
			// 8 - Won't fire unless player/NPC is in it and pressing fire button, you must make a bounding box,(max\mins) for this to work.
			// 16 - only non-player NPCs can trigger this by touch
			// 128 - Start off, has to be activated by a target_activate to be touchable/usable
			// 256 - multiple players can trigger the entity at the same time
			DispatchKeyValue(iEnt, "spawnflags", "257");
			DispatchKeyValue(iEnt, "StartDisabled", "0");

			Format(sZoneName, sizeof(sZoneName), "sm_ckZone %i", zoneIndex);
			DispatchKeyValue(iEnt, "targetname", sZoneName);
			DispatchKeyValue(iEnt, "wait", "0");

			if (DispatchSpawn(iEnt))
			{
				ActivateEntity(iEnt);

				GetMiddleOfABox(fMins, fMaxs, fMiddle);

				TeleportEntity(iEnt, fMiddle, NULL_VECTOR, NULL_VECTOR);

				// Have the mins always be negative
				for(int i = 0; i < 3; i++){
					fMins[i] = fMins[i] - fMiddle[i];
					if (fMins[i] > 0.0)
						fMins[i] *= -1.0;
				}

				// And the maxs always be positive
				for(int i = 0; i < 3; i++){
					fMaxs[i] = fMaxs[i] - fMiddle[i];
					if (fMaxs[i] < 0.0)
						fMaxs[i] *= -1.0;
				}

				SetEntPropVector(iEnt, Prop_Send, "m_vecMins", fMins);
				SetEntPropVector(iEnt, Prop_Send, "m_vecMaxs", fMaxs);
				SetEntProp(iEnt, Prop_Send, "m_nSolidType", 2);

				int iEffects = GetEntProp(iEnt, Prop_Send, "m_fEffects");
				iEffects |= 0x020;
				SetEntProp(iEnt, Prop_Send, "m_fEffects", iEffects);

				SDKHook(iEnt, SDKHook_StartTouch, StartTouchTrigger);
				SDKHook(iEnt, SDKHook_EndTouch, EndTouchTrigger);
			}
			else
			{
				LogError("Not able to dispatchspawn for Entity %i in SpawnTrigger", iEnt);
			}
		}
	}
}

public Action IgnoreTriggers(int entity, int client) //add command to !options
{
	if (!(client > 0 && client <= MaxClients) || !IsPlayerAlive(client)) return Plugin_Continue;

	if (IsFakeClient(client)) return Plugin_Handled;

	if (GetEntityMoveType(client) != MOVETYPE_NOCLIP) return Plugin_Continue;

	if (g_iDisableTriggers[client]) return Plugin_Continue;

	return Plugin_Handled;
} 

// Types: Start(1), End(2), Stage(3), Checkpoint(4), Speed(5), TeleToStart(6), Validator(7), Chekcer(8), Stop(0)
public Action StartTouchTrigger(int caller, int activator)
{
	int client = activator;

	// Ignore dead players
	if (!IsValidClient(client)) {
		return Plugin_Continue;
	}

	char sTargetName[256];
	int action[3];
	GetEntPropString(caller, Prop_Data, "m_iName", sTargetName, sizeof(sTargetName));

	if (StrContains(sTargetName, "sm_ckZoneHooked") != -1)
		ReplaceString(sTargetName, sizeof(sTargetName), "sm_ckZoneHooked ", "");
	else
		ReplaceString(sTargetName, sizeof(sTargetName), "sm_ckZone ", "");

	int id = StringToInt(sTargetName);

	action[0] = g_mapZones[id].ZoneType;
	action[1] = g_mapZones[id].ZoneTypeId;
	action[2] = g_mapZones[id].ZoneGroup;

	// Hack fix to allow bonus zones to sit on top of start zones, e.g surf_aircontrol_ksf bonus 1
	if (g_bTimerRunning[activator])
	{
		if (action[0] < 6 && g_bInBonus[activator])
		{
			if (action[2] != g_iInBonus[activator])
			{
				return Plugin_Continue;
			}
		}
		else
		{
			if (!g_bInBonus[activator] && action[2] > 0)
			{
				return Plugin_Continue;
			}
		}
	}
	else
	{
		if (!g_bInBonus[activator] && action[2] > 0)
		{
			g_bInBonus[activator] = false;
			return Plugin_Continue;
		}
		else if (action[2] > 0)
			g_bInBonus[activator] = true;
	}

	if (g_bUsingStageTeleport[activator])
		g_bUsingStageTeleport[activator] = false;

	if (action[2] == g_iClientInZone[activator][2]) // Is touching zone in right zonegroup
	{
		// Set client location
		g_iClientInZone[activator][0] = action[0];
		g_iClientInZone[activator][1] = action[1];
		g_iClientInZone[activator][2] = action[2];
		g_iInBonus[activator] = action[2];
		g_iClientInZone[activator][3] = id;
		StartTouch(activator, action);
	}
	else
	{
		if (action[0] == 1 || action[0] == 5) // Ignore other than start and misc zones in other zonegroups
		{
			// Set client location
			g_iClientInZone[activator][0] = action[0];
			g_iClientInZone[activator][1] = action[1];
			g_iClientInZone[activator][2] = action[2];
			g_iInBonus[activator] = action[2];
			g_iClientInZone[activator][3] = id;
			StartTouch(activator, action);
		}
		else
			if (action[0] == 6 || action[0] == 7 || action[0] == 8 || action[0] == 0 || action[0] == 9 || action[0] == 10 || action[0] == 11) // Allow MISC zones regardless of zonegroup // fluffys add nojump, noduck
				StartTouch(activator, action);
	}

	return Plugin_Continue;
}

public Action EndTouchTrigger(int caller, int activator)
{
	int client = activator;

	// Ignore dead players
	if (!IsValidClient(client)) {
		return Plugin_Continue;
	}

	// For new speed limiter
	g_bLeftZone[activator] = true;

	// Ignore if teleporting out of the zone
	if (g_bIgnoreZone[activator])
	{
		g_bIgnoreZone[activator] = false;
		return Plugin_Continue;
	}

	// Reset Prehop Limit
	// g_bJumpedInZone[activator] = false;

	char sTargetName[256];
	int action[3];
	GetEntPropString(caller, Prop_Data, "m_iName", sTargetName, sizeof(sTargetName));

	if (StrContains(sTargetName, "sm_ckZoneHooked") != -1)
		ReplaceString(sTargetName, sizeof(sTargetName), "sm_ckZoneHooked ", "");
	else
		ReplaceString(sTargetName, sizeof(sTargetName), "sm_ckZone ", "");

	int id = StringToInt(sTargetName);

	action[0] = g_mapZones[id].ZoneType;
	action[1] = g_mapZones[id].ZoneTypeId;
	action[2] = g_mapZones[id].ZoneGroup;

	if (action[2] != g_iClientInZone[activator][2] || action[0] == 6 || action[0] == 8 || action[0] != g_iClientInZone[activator][0]) // Ignore end touches in other zonegroups, zones that teleports away or multiple zones on top of each other // fluffys
		return Plugin_Continue;

	// End touch
	if (!g_bSaveLocTele[client])
	{
		EndTouch(activator, action);
	}

	return Plugin_Continue;
}

public void StartTouch(int client, int action[3])
{
	/* if (g_iClientInZone[client][0] > 0){
		g_TeleInTriggerMultiple[client] = false;
	} */

	if (IsValidClient(client))
	{
		float fCurrentRunTime = g_fCurrentRunTime[client];
		float fCurrentWrcpRunTime = g_fCurrentWrcpRunTime[client];
		float fCurrentPracSrcpRunTime = g_fCurrentPracSrcpRunTime[client];
		
		// Types: Start(1), End(2), Stage(3), Checkpoint(4), Speed(5), TeleToStart(6), Validator(7), Chekcer(8), Stop(0) // fluffys: NoBhop(9), NoCrouch(10)

		//PRINFO
		int zGroup = g_iClientInZone[client][2]; //ease of use 
		if ((action[0] == 1 || action[0] == 2 || action[0] == 3) && (!g_bPracticeMode[client] && !IsFakeClient(client) && g_iCurrentStyle[client] == 0)){

			//PLAYER ON A RUN
			if(action[0] == 2 && g_bTimerRunning[client]){
				g_fCompletes[client][zGroup]++;

				g_fTimeinZone[client][zGroup] += fCurrentRunTime;
				g_fTimeIncrement[client][zGroup] = 0.0;

				if(g_fstComplete[client][zGroup] == 0.0)
					g_fstComplete[client][zGroup] = g_fTimeinZone[client][zGroup];

				//END ZONE OF MAP
				if(zGroup == 0)
					//PLAYER ALREADY HAS A COMPLETION
					if( g_fPersonalRecord[client] > 0.0 )
						//IMPROVES COMPLETION
						if(g_fCurrentRunTime[client] < g_fPersonalRecord[client])
							db_UpdatePRinfo_WithRuntime(client, g_szSteamID[client], zGroup, g_fCurrentRunTime[client]); //UPDATE THE PLAYERS PRINFO WITH THEIR RUNTIME IF THEY IMPROVED
						else
							db_UpdatePRinfo(client, g_szSteamID[client], zGroup); //UPDATE THE PLAYERS PRINFO EXECPT FOR THE RUNTIME
					//PLAYER FINISHES FOR THE 1ST TIME
					else
						db_UpdatePRinfo_WithRuntime(client, g_szSteamID[client], zGroup, g_fCurrentRunTime[client]);
				//ENDZONE OF BONUS
				else
					//PLAYER ALREADY HAS A COMPLETION
					if(g_fPersonalRecordBonus[zGroup][client] > 0)
						//IMPROVES COMPLETION
						if (g_fCurrentRunTime[client] < g_fPersonalRecordBonus[zGroup][client])
							db_UpdatePRinfo_WithRuntime(client, g_szSteamID[client], zGroup, g_fCurrentRunTime[client]); //UPDATE THE PLAYERS PRINFO WITH THEIR RUNTIME IF THEY IMPROVED
						else
							db_UpdatePRinfo(client, g_szSteamID[client], zGroup); //UPDATE THE PLAYERS PRINFO EXECPT FOR THE RUNTIME
					//PLAYER FINISHES FOR THE 1ST TIME
					else
						db_UpdatePRinfo_WithRuntime(client, g_szSteamID[client], zGroup, g_fCurrentRunTime[client]);
			}
			//PLAYER JUST DOING STAGES
			else if(action[0] == 3 && g_bWrcpTimeractivated[client] && !g_bTimerRunning[client]){
				//CHECK IF THERE IS TIME NOT ADDED TO TIMEINZONE
				if(g_fTimeIncrement[client][zGroup] != 0.0){
					g_fTimeinZone[client][zGroup] += g_fTimeIncrement[client][zGroup];
					g_fTimeIncrement[client][zGroup] = 0.0;
				}
			}
			//CASE WHERE PLAYER IS RUNNING THE MAP BUT MID RUN SWAP TO LETS SAY /B 1, THE VALUE CONTINUES STORES IN THE g_fTimeIncrement[ZONEGROUP 0], WHEN PLAYER GOES BACK
			//TO MAP STARTZONE THE PREVIOUSLY INCREMENTED VALUE IS NOW ADDED TO THE TIMEINZONE
			//MAP OR BONUS STARTZONE
			else if(action[0] == 1){
				//CHECK IF THERE IS TIME NOT ADDED TO TIMEINZONE
				if(g_fTimeIncrement[client][zGroup] != 0.0){
					g_fTimeinZone[client][zGroup] += g_fTimeIncrement[client][zGroup];
					g_fTimeIncrement[client][zGroup] = 0.0;
				}
			}
		}

		if (action[0] == 0) // Stop Zone
		{
			Client_Stop(client, 1);
			lastCheckpoint[g_iClientInZone[client][2]][client] = 999;
		}
		else if (action[0] == 1 || action[0] == 5) // Start Zone or Speed Start
		{
			// Set Default Values
			Client_Stop(client, 1);
			ResetGravity(client);
			g_KeyCount[client] = 0;
			g_bInJump[client] = false;
			g_bInDuck[client] = false;
			g_iCurrentCheckpoint[client] = 0;
			g_Stage[g_iClientInZone[client][2]][client] = 1;
			g_bInStartZone[client] = true;
			g_bInStageZone[client] = false;
			g_iCurrentStyle[client] = g_iInitalStyle[client];
			lastCheckpoint[g_iClientInZone[client][2]][client] = 1;
			g_bSaveLocTele[client] = false;

			// StopRecording(client); //Add pre
			StartRecording(client); //Add pre

			if (g_bhasStages)
			{
				g_bWrcpTimeractivated[client] = false;
				g_bPracSrcpTimerActivated[client] = false;
				g_CurrentStage[client] = 0;
        
				// Prevents the Stage(X) replay from starting before the Stage(X) start zone
				g_iStageStartTouchTick[client] = g_iRecordedTicks[client]; //Add pre
			}
		}
		else if (action[0] == 2) // End Zone
		{	
			if (g_iClientInZone[client][2] == action[2]) // Cant end bonus timer in this zone && in the having the same timer on
			{
				// fluffys gravity
				if (g_iCurrentStyle[client] != 4) // low grav
					ResetGravity(client);
				
				g_bInJump[client] = false;
				g_bInDuck[client] = false;

				if (g_bPracticeMode[client])
				{
					g_bPracticeModeRun[client] = true;
				}
				else
				{
					g_bPracticeModeRun[client] = false;
				}

				// fluffys wrcps
				if (g_bhasStages)
				{
					
					if (!g_bPracticeMode[client] && g_iClientInZone[client][2] == 0 && g_iCurrentStyle[client] == 0) {
						g_fCheckpointTimesNew[0][client][g_TotalStages-1] = fCurrentRunTime;
					}

					if (!g_bPracticeMode[client])
					{
						g_bWrcpEndZone[client] = true;
						CL_OnEndWrcpTimerPress(client, fCurrentRunTime);
					}
					else
					{
						if (!g_bInBonus[client])
						{
							CL_OnEndPracSrcpTimerPress(client, fCurrentPracSrcpRunTime);
						}
					}

					g_bPracSrcpEndZone[client] = true;
				}
				else
				{
					if (g_bPracticeMode[client])
					{
						// This bypasses checkpoint enforcer when in PracMode as players wont always be passing all checkpoints
						g_bIsValidRun[client] = true;
					}
				}

				if (g_bToggleMapFinish[client])
				{
					if (GetConVarBool(g_hMustPassCheckpoints) && g_iTotalCheckpoints > 0 && action[2] == 0)
					{
						if (g_bIsValidRun[client])
							CL_OnEndTimerPress(client);
						else
							CPrintToChat(client, "%t", "InvalidRun", g_szChatPrefix, g_bhasStages ? "stages" : "checkpoints");
					}
					else
						CL_OnEndTimerPress(client);
				}
			}
			else
			{
				return;
			}
			// Resetting checkpoints
			lastCheckpoint[g_iClientInZone[client][2]][client] = 999;
		}
		else if (action[0] == 3) // Stage Zone
		{
			g_bInStageZone[client] = true;
			g_bInStartZone[client] = false;
			g_bInJump[client] = false;
			g_bInDuck[client] = false;
			g_KeyCount[client] = 0;

			// Prevents the Stage(X) replay from starting before the Stage(X) start zone
			g_iStageStartTouchTick[client] = g_iRecordedTicks[client]; //Add pre
			// stop bot wrcp timer
			if (client == g_WrcpBot)
			{
				Client_Stop(client, 1);
				g_bWrcpTimeractivated[client] = false;
				g_bPracSrcpTimerActivated[client] = false;
			}

			// Setting valid to false, in case of checkers
			g_bValidRun[client] = false;

			// Announcing checkpoint
			if (action[1] != lastCheckpoint[g_iClientInZone[client][2]][client] && g_iClientInZone[client][2] == action[2])
			{
				// Make sure the player is not going backwards
				if ((action[1] + 2) < g_Stage[g_iClientInZone[client][2]][client])
				{
					g_bWrcpTimeractivated[client] = false;
					g_bPracSrcpTimerActivated[client] = false;
				}
				else
					g_bNewStage[client] = true;

				g_Stage[g_iClientInZone[client][2]][client] = (action[1] + 2);

				if (!g_bInBonus[client]) // Stop announcement from happening in bonus because if bonus has stages then this will display incorrect info
				{
					if (!g_bPracticeMode[client])
					{
						CL_OnEndWrcpTimerPress(client, fCurrentWrcpRunTime);
					}
					else
					{
						CL_OnEndPracSrcpTimerPress(client, fCurrentPracSrcpRunTime);
					}
				}
				
				// Stage enforcer
				g_iCheckpointsPassed[client]++;
				if (g_iCheckpointsPassed[client] == g_TotalStages)
					g_bIsValidRun[client] = true;
				
				if (g_iCurrentStyle[client] == 0)
				{
					Checkpoint(client, action[1], g_iClientInZone[client][2], fCurrentRunTime);
				}
				else{
					//PrintToChatAll("style %d | cp %i | %d tick count", g_iCurrentStyle[client], action[1], g_iRecordedTicks[client]);
					g_iCPStartFrame_CurrentRun[g_iCurrentStyle[client]][action[1]][client] = g_iRecordedTicks[client];
				}
				
				if (!g_bSaveLocTele[client])
				{
					lastCheckpoint[g_iClientInZone[client][2]][client] = action[1];
				}
				else
				{
					lastCheckpoint[g_iClientInZone[client][2]][client] = g_iPlayerPracLocationSnap[client][g_iLastSaveLocIdClient[client]] - 1;
				}
			}
			else if (!g_bTimerRunning[client])
			{
				g_iCurrentStyle[client] = g_iInitalStyle[client];
			}

			if (g_bWrcpTimeractivated[client])
			{
				g_bWrcpTimeractivated[client] = false;
			}

			if(g_bPracSrcpTimerActivated[client])
			{
				g_bPracSrcpTimerActivated[client] = false;
			}

			if (g_bPracticeMode[client]) 
			{
				g_bSaveLocTele[client] = false;
			}
		}
		else if (action[0] == 4) // Checkpoint Zone
		{
			if (action[1] != lastCheckpoint[g_iClientInZone[client][2]][client] && g_iClientInZone[client][2] == action[2] || g_bPracticeMode[client])
			{
				g_iCurrentCheckpoint[client]++;
				g_bSaveLocTele[client] = false;
				
				// Checkpoint enforcer
				if (GetConVarBool(g_hMustPassCheckpoints) && g_iTotalCheckpoints > 0)
				{
					if (!g_bPracticeMode[client])
					{
						g_iCheckpointsPassed[client]++;

						if (g_iCheckpointsPassed[client] == g_iTotalCheckpoints)
						{	
							g_bIsValidRun[client] = true;
						}
					}
					else
					{
						// This bypasses checkpoint enforcer when in PracMode as players wont always be passing all checkpoints
						g_bIsValidRun[client] = true;
					}
				}

				// Announcing checkpoint in linear maps
				if (g_iCurrentStyle[client] == 0)
				{
					Checkpoint(client, action[1], g_iClientInZone[client][2], fCurrentRunTime);
					
					if (!g_bSaveLocTele[client])
					{
						lastCheckpoint[g_iClientInZone[client][2]][client] = action[1];
					}
					else
					{
						lastCheckpoint[g_iClientInZone[client][2]][client] = g_iPlayerPracLocationSnap[client][g_iLastSaveLocIdClient[client]] - 1;
					}
				}
				else{
					//PrintToChatAll("style %d | cp %i | %d tick count", g_iCurrentStyle[client], action[1], g_iRecordedTicks[client]);
					g_iCPStartFrame_CurrentRun[g_iCurrentStyle[client]][action[1]][client] = g_iRecordedTicks[client];
				}
			}

		}
		else if (action[0] == 6) // TeleToStart Zone
		{
			teleportClient(client, g_iClientInZone[client][2], 1, true);
		}
		else if (action[0] == 7) // Validator Zone
		{
			g_bValidRun[client] = true;
		}
		else if (action[0] == 8) // Checker Zone
		{
			if (!g_bValidRun[client])
				Command_Teleport(client, 1);
		}
		else if (action[0] == 9) // fluffys nobhop
		{
			g_bInJump[client] = true;
		}
		else if (action[0] == 10) // fluffys noduck
		{
			g_bInDuck[client] = true;
		}
		else if (action[0] == 11) // MaxSpeed
		{
			g_bInMaxSpeed[client] = true;
			// CPrintToChat(client, "Inside MaxSpeed zone");
		}
		
		//INCASE THE RECORD IS OLD, WHEN THERE IS NOT DATA IN THE DATABASE
		//WE SIMPLY ADD TO "g_iCPStartFrame" THE CURRENT REPLAY BOT TICK
		//THIS WAY WHEN THE DATABASE HAS NO VALUES
		//THE PLAYERS CAN SELECT THE CHECKPOINTS OPTION IN THE REPLAY MENU WITH THE CORRECT VALUES
		//ONLY PERFOM ACTIONS IF THE CLIENT INDEX IS THE MAP RECORD BOT'S INDEX AND IF THERE ARE NOT REPLAY TICKS FOUND
		if(IsPlayerAlive(client) && IsFakeClient(client) && !g_bReplayTickFound[g_iCurrentStyle[client]] && client == g_RecordBot){
			//MAKE BOTS REGISTER TICKS
			if(action[0] == 3 || action[0] == 4)
				g_iCPStartFrame[g_iCurrentStyle[client]][action[1]] = g_iReplayTick[client];

			if(action[0] == 2)
				db_UpdateReplaysTick(client, g_iCurrentStyle[client]);
		}

	}
}

public void EndTouch(int client, int action[3])
{
	if (IsValidClient(client))
	{
		LimitSpeed(client);

		// float CurVelVec[3];
		// GetEntPropVector(client, Prop_Data, "m_vecVelocity", CurVelVec);
		// float currentspeed = SquareRoot(Pow(CurVelVec[0], 2.0) + Pow(CurVelVec[1], 2.0) + Pow(CurVelVec[2], 2.0));
		// float xy = SquareRoot(Pow(CurVelVec[0], 2.0) + Pow(CurVelVec[1], 2.0));
		// float z = SquareRoot(Pow(CurVelVec[2], 2.0));
		// CPrintToChat(client, "XY: %f Z: %f XYZ: %f", xy, z, currentspeed);
		// CPrintToChat(client, "%f", CurVelVec);
		// CPrintToChat(client, "%f %f %f", CurVelVec[0], CurVelVec[1], CurVelVec[2]);

		// Types: Start(1), End(2), Stage(3), Checkpoint(4), Speed(5), TeleToStart(6), Validator(7), Chekcer(8), Stop(0)

		if (action[0] == 1 || action[0] == 5)
		{	
			if (!g_bPracticeMode[client])
			{
				g_WrcpStage[client] = 1;
				g_bWrcpEndZone[client] = false;
				g_Stage[g_iClientInZone[client][2]][client] = 1;
				lastCheckpoint[g_iClientInZone[client][2]][client] = 999;

				// NoClip check
				if (g_bNoClip[client] || (!g_bNoClip[client] && (GetGameTime() - g_fLastTimeNoClipUsed[client]) < 3.0))
				{
					CPrintToChat(client, "%t", "SurfZones1", g_szChatPrefix);
					EmitSoundToClientNoPreCache(client, "play buttons\\button10.wav", false);
					// fluffys
					// ClientCommand(client, "sm_stuck");
				}
				else
				{
					if (g_bhasStages && g_bTimerEnabled[client])
					{
						CL_OnStartWrcpTimerPress(client); // fluffys only start stage timer if not in prac mode
					}

					if (g_bTimerEnabled[client])
					{
						CL_OnStartTimerPress(client);
						CL_OnStartPracSrcpTimerPress(client);
					}
				}

				// fluffys
				if (!g_bNoClip[client])
					g_bInStartZone[client] = false;

				g_bValidRun[client] = false;
			}
		}
		// fluffys
		else if (action[0] == 3) // fluffys stage
		{
			g_bInStageZone[client] = false;

			if (!g_bPracticeMode[client] && g_bTimerEnabled[client])
			{
				CL_OnStartWrcpTimerPress(client);
			}
			
			CL_OnStartPracSrcpTimerPress(client);
		}
		else if (action[0] == 9) // fluffys nojump
		{
			g_bInJump[client] = false;
		}
		else if (action[0] == 10) // fluffys noduck
		{
			g_bInDuck[client] = false;
		}
		else if (action[0] == 11) // MaxSpeed zone
		{
			g_bInMaxSpeed[client] = false;
		// 	CPrintToChat(client, "Left MaxSpeed zone");
		}

		// Set client location
		g_iClientInZone[client][0] = -1;
		g_iClientInZone[client][1] = -1;
		g_iClientInZone[client][2] = action[2];
		g_iClientInZone[client][3] = -1;
	}
}

public void InitZoneVariables()
{
	g_mapZonesCount = 0;
	for (int i = 0; i < MAXZONES; i++)
	{
		g_mapZones[i].ZoneId = -1;
		g_mapZones[i].PointA = view_as<float>({ -1.0, -1.0, -1.0 });
		g_mapZones[i].PointB = view_as<float>({ -1.0, -1.0, -1.0 });
		g_mapZones[i].ZoneId = -1;
		g_mapZones[i].ZoneType = -1;
		g_mapZones[i].ZoneTypeId = -1;
		g_mapZones[i].ZoneGroup = -1;
		Format(g_mapZones[i].ZoneName, sizeof(MapZone::ZoneName), "");
		g_mapZones[i].Vis = 0;
		g_mapZones[i].Team = 0;
	}
}

public void getZoneTeamColor(int team, int color[4])
{
	switch (team)
	{
		case 1:
		{
			color = beamColorM;
		}
		case 2:
		{
			color = beamColorT;
		}
		case 3:
		{
			color = beamColorCT;
		}
		default:
		{
			color = beamColorN;
		}
	}
}

public void DrawBeamBox(int client)
{
	int zColor[4];
	getZoneTeamColor(g_CurrentZoneTeam[client], zColor);
	TE_SendBeamBoxToClient(client, g_Positions[client][1], g_Positions[client][0], g_BeamSprite, g_HaloSprite, 0, 30, 1.0, 1.0, 1.0, 2, 0.0, zColor, 0, 1);
	CreateTimer(1.0, BeamBox, client, TIMER_REPEAT);
}

public Action BeamBox(Handle timer, any client)
{
	if (IsClientInGame(client))
	{
		if (g_Editing[client] == 2)
		{
			int zColor[4];
			getZoneTeamColor(g_CurrentZoneTeam[client], zColor);
			TE_SendBeamBoxToClient(client, g_Positions[client][1], g_Positions[client][0], g_BeamSprite, g_HaloSprite, 0, 30, 1.0, 1.0, 1.0, 2, 0.0, zColor, 0, 1);
			return Plugin_Continue;
		}
	}
	return Plugin_Stop;
}

public Action BeamBoxAll(Handle timer, any data)
{
	int zColor[4], tzColor[4];
	bool draw;

	// if (GetConVarInt(g_hZoneDisplayType) < 1)
	// 	return Plugin_Handled;

	for (int i = 0; i < g_mapZonesCount; ++i)
	{
		draw = false;
		// Types: Start(1), End(2), Stage(3), Checkpoint(4), Speed(5), TeleToStart(6), Validator(7), Chekcer(8), Stop(0)
		if (0 < g_mapZones[i].Vis < 4)
		{
			draw = true;
		}
		else
		{
			if (GetConVarInt(g_hZonesToDisplay) == 1 && ((0 < g_mapZones[i].ZoneType < 3) || g_mapZones[i].ZoneType == 5))
			{
				draw = true;
			}
			else
			{
				if (GetConVarInt(g_hZonesToDisplay) == 2 && ((0 < g_mapZones[i].ZoneType < 4) || g_mapZones[i].ZoneType == 5))
				{
					draw = true;
				}
				else
				{
					if (GetConVarInt(g_hZonesToDisplay) == 3)
					{
						draw = true;
					}
				}
			}
		}

		if (draw)
		{
			getZoneDisplayColor(g_mapZones[i].ZoneType, zColor, g_mapZones[i].ZoneGroup);
			getZoneTeamColor(g_mapZones[i].Team, tzColor);
			for (int p = 1; p <= MaxClients; p++)
			{
				if (GetConVarInt(g_hZoneDisplayType) == 0 && !g_bShowZones[p] && g_Editing[p] == 0)
				{
					// if (GetConVarInt(g_hZoneDisplayType) < 1)
						continue;
				}

				if (IsValidClient(p) && !IsFakeClient(p))
				{
					if (GetConVarInt(g_hZoneDisplayType) == 0 && !g_bShowZones[p])
						continue;

					if ( g_mapZones[i].Vis == 2 || g_mapZones[i].Vis == 3)
					{
						if (GetClientTeam(p) == g_mapZones[i].Vis && g_ClientSelectedZone[p] != i)
						{
							float buffer_a[3], buffer_b[3];
							for (int x = 0; x < 3; x++)
							{
								buffer_a[x] = g_mapZones[i].PointA[x];
								buffer_b[x] = g_mapZones[i].PointB[x];
							}
							TE_SendBeamBoxToClient(p, buffer_a, buffer_b, g_BeamSprite, g_HaloSprite, 0, 30, GetConVarFloat(g_hChecker), 1.0, 1.0, 2, 0.0, tzColor, 0, 0, i);
						}
					}
					else
					{
						if (g_ClientSelectedZone[p] != i)
						{
							float buffer_a[3], buffer_b[3];
							for (int x = 0; x < 3; x++)
							{
								buffer_a[x] = g_mapZones[i].PointA[x];
								buffer_b[x] = g_mapZones[i].PointB[x];
							}
							TE_SendBeamBoxToClient(p, buffer_a, buffer_b, g_BeamSprite, g_HaloSprite, 0, 30, GetConVarFloat(g_hChecker), 1.0, 1.0, 2, 0.0, zColor, 0, 0, i);
						}
					}
				}
			}
		}
	}
	return Plugin_Continue;
}

public void getZoneDisplayColor(int type, int zColor[4], int zGrp)
{
	// Types: Start(1), End(2), Stage(3), Checkpoint(4), Speed(5), TeleToStart(6), Validator(7), Chekcer(8), Stop(0)
	switch (type)
	{
		case 1: {

			if (zGrp > 0)
				zColor = g_iZoneColors[3];
			else
				zColor = g_iZoneColors[1];
		}
		case 2: {
			if (zGrp > 0)
				zColor = g_iZoneColors[4];
			else
				zColor = g_iZoneColors[2];
		}
		case 3: {
			zColor = g_iZoneColors[5];
		}
		case 4: {
			zColor = g_iZoneColors[6];
		}
		case 5: {
			zColor = g_iZoneColors[7];
		}
		case 6: {
			zColor = g_iZoneColors[8];
		}
		case 7: {
			zColor = g_iZoneColors[9];
		}
		case 8: {
			zColor = g_iZoneColors[10];
		}
		case 0: {
			zColor = g_iZoneColors[0];
		}
		default:zColor = beamColorT;
	}
}

public void BeamBox_OnPlayerRunCmd(int client)
{
	if (g_Editing[client] == 1 || g_Editing[client] == 3 || g_Editing[client] == 10 || g_Editing[client] == 11)
	{
		float pos[3], ang[3];
		int zColor[4];
		getZoneTeamColor(g_CurrentZoneTeam[client], zColor);
		if (g_Editing[client] == 1)
		{
			GetClientEyePosition(client, pos);
			GetClientEyeAngles(client, ang);
			TR_TraceRayFilter(pos, ang, MASK_PLAYERSOLID, RayType_Infinite, TraceRayDontHitSelf, client);
			TR_GetEndPosition(g_Positions[client][1]);
		}

		if (g_Editing[client] == 10 || g_Editing[client] == 11)
		{
			GetClientEyePosition(client, pos);
			GetClientEyeAngles(client, ang);
			TR_TraceRayFilter(pos, ang, MASK_PLAYERSOLID, RayType_Infinite, TraceRayDontHitSelf, client);
			if (g_Editing[client] == 10)
			{
				TR_GetEndPosition(g_fBonusStartPos[client][1]);
				TE_SendBeamBoxToClient(client, g_fBonusStartPos[client][1], g_fBonusStartPos[client][0], g_BeamSprite, g_HaloSprite, 0, 30, 0.1, 1.0, 1.0, 2, 0.0, zColor, 0, 1);
			}
			else
			{
				TR_GetEndPosition(g_fBonusEndPos[client][1]);
				TE_SendBeamBoxToClient(client, g_fBonusEndPos[client][1], g_fBonusEndPos[client][0], g_BeamSprite, g_HaloSprite, 0, 30, 0.1, 1.0, 1.0, 2, 0.0, zColor, 0, 1);
			}
		}
		else
			TE_SendBeamBoxToClient(client, g_Positions[client][1], g_Positions[client][0], g_BeamSprite, g_HaloSprite, 0, 30, 0.1, 1.0, 1.0, 2, 0.0, zColor, 0, 1);
	}

	if (g_iSelectedTrigger[client] > -1)
	{
		// come back
		float position[3], fMins[3], fMaxs[3];
		int zColor[4];
		getZoneTeamColor(g_CurrentZoneTeam[client], zColor);

		int iEnt = GetArrayCell(g_hTriggerMultiple, g_iSelectedTrigger[client]);
		if (IsValidEntity(iEnt))
		{
			GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", position);
			GetEntPropVector(iEnt, Prop_Send, "m_vecMins", fMins);
			GetEntPropVector(iEnt, Prop_Send, "m_vecMaxs", fMaxs);

			for (int j = 0; j < 3; j++)
			{
				fMins[j] = (fMins[j] + position[j]);
			}

			for (int j = 0; j < 3; j++)
			{
				fMaxs[j] = (fMaxs[j] + position[j]);
			}

			TE_SendBeamBoxToClient(client, fMins, fMaxs, g_BeamSprite, g_HaloSprite, 0, 30, 1.0, 1.0, 1.0, 2, 0.0, view_as<int>({255, 255, 0, 255}), 0, 1);
		}
	}
}

stock void TE_SendBeamBoxToClient(int client, float uppercorner[3], float bottomcorner[3], int ModelIndex, int HaloIndex, int StartFrame, int FrameRate, float Life, float Width, float EndWidth, int FadeLength, float Amplitude, const int Color[4], int Speed, int type, int zoneid = -1)
{
	// 0 = Do not display zones, 1 = Display the lower edges of zones, 2 = Display whole zone
	if (!IsValidClient(client) || GetConVarInt(g_hZoneDisplayType) < 1 && !g_bShowZones[client] && g_Editing[client] == 0 && g_iSelectedTrigger[client] == -1)
		return;

	if (GetConVarInt(g_hZoneDisplayType) > 1 || type == 1 || g_bShowZones[client] || g_Editing[client] > 0 || g_iSelectedTrigger[client] > -1) // All sides
	{
		float corners[8][3];
		if (zoneid == -1)
		{
			Array_Copy(uppercorner, corners[0], 3);
			Array_Copy(bottomcorner, corners[7], 3);

			// Count ponts from coordinates provided
			for(int i = 1; i < 7; i++)
			{
				for(int j = 0; j < 3; j++)
				{
					corners[i][j] = corners[((i >> (2-j)) & 1) * 7][j];
				}
			}
		}
		else
		{
			// Get values that are already counted
			for (int i = 0; i < 8; i++)
				for (int k = 0; k < 3; k++)
					corners[i][k] = g_fZoneCorners[zoneid][i][k];
		}

		// Send beams to client
		// https://forums.alliedmods.net/showpost.php?p=2006539&postcount=8
		for (int i = 0, i2 = 3; i2 >= 0; i+=i2--)
		{
		for(int j = 1; j <= 7; j += (j / 2) + 1)
			{
				if (j != 7-i)
				{
					TE_SetupBeamPoints(corners[i], corners[j], ModelIndex, HaloIndex, StartFrame, FrameRate, Life, Width, EndWidth, FadeLength, Amplitude, Color, Speed);
					TE_SendToClient(client);
				}
			}
		}
	}
	else
	{
		if (GetConVarInt(g_hZoneDisplayType) == 1 && zoneid != -1 || g_bShowZones[client] || g_Editing[client] > 0 || g_iSelectedTrigger[client] > -1) // Only bottom corners
		{
			float corners[4][3], fTop[3];

			if (g_mapZones[zoneid].PointA[2] > g_mapZones[zoneid].PointB[2]) // Make sure bottom corner is always the lowest
			{
				for(int i = 0; i < 3; i++)
				{
					corners[0][i] = g_mapZones[zoneid].PointB[i];
					fTop[i] = g_mapZones[zoneid].PointA[i];
				}
			}
			else
			{
				for(int i = 0; i < 3; i++)
				{
					corners[0][i] = g_mapZones[zoneid].PointA[i];
					fTop[i] = g_mapZones[zoneid].PointB[i];
				}
			}

			bool foundOther = false;
			// Get other corners
			for (int i = 0, count = 0, k = 2; i < 8; i++)
			{
				if (g_fZoneCorners[zoneid][i][2] != fTop[2]) // Get the lowest corner
				{
					if (!foundOther && g_fZoneCorners[zoneid][i][0] == fTop[0] && g_fZoneCorners[zoneid][i][1] == fTop[1]) // Other corner
					{
						count++;
						for (int x = 0; x < 3; x++)
							corners[1][x] = g_fZoneCorners[zoneid][i][x];

						foundOther = true;
					}
					else
					{
						if (k < 4 && (g_fZoneCorners[zoneid][i][0] != corners[0][0] || g_fZoneCorners[zoneid][i][1] != corners[0][1])) // Other two corners
						{
							for (int x = 0; x < 3; x++)
								corners[k][x] = g_fZoneCorners[zoneid][i][x];

							count++;
							k++;
						}
					}
				}
				if (count == 3)
					break;
			}

			// lift a bit higher, so not under ground
			// corners[0][2] += 5.0;
			// corners[1][2] += 5.0;
			// corners[2][2] += 5.0;
			// corners[3][2] += 5.0;

			corners[0][2] += 1.0;
			corners[1][2] += 1.0;
			corners[2][2] += 1.0;
			corners[3][2] += 1.0;

			for (int i = 0; i < 2; i++) // Connect main corners to the other corners
			{
				TE_SetupBeamPoints(corners[i], corners[2], ModelIndex, HaloIndex, StartFrame, FrameRate, Life, Width, EndWidth, FadeLength, Amplitude, Color, Speed);
				TE_SendToClient(client);
				TE_SetupBeamPoints(corners[i], corners[3], ModelIndex, HaloIndex, StartFrame, FrameRate, Life, Width, EndWidth, FadeLength, Amplitude, Color, Speed);
				TE_SendToClient(client);
			}
		}
	}
}

// !zones menu starts here
public void ZoneMenu(int client)
{
	if (!IsValidClient(client))
		return;

	if (IsPlayerZoner(client))
	{
		resetSelection(client);
		Menu ckZoneMenu = new Menu(Handle_ZoneMenu);
		ckZoneMenu.SetTitle("Zones");
		ckZoneMenu.AddItem("", "Create a Zone");
		ckZoneMenu.AddItem("", "Edit Zones");
		ckZoneMenu.AddItem("", "Save Zones");
		ckZoneMenu.AddItem("", "Edit Zone Settings");
		ckZoneMenu.AddItem("", "Reload Zones");
		ckZoneMenu.ExitButton = true;
		ckZoneMenu.Display(client, MENU_TIME_FOREVER);
	}
	else
		CPrintToChat(client, "%t", "NoZoneAccess", g_szChatPrefix);
}

public int Handle_ZoneMenu(Handle tMenu, MenuAction action, int client, int item)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			switch (item)
			{
				case 0:
				{
					// Create a zone
					SelectZoneGroup(client);
				}
				case 1:
				{
					// Edit Zones
					EditZoneGroup(client);
				}
				case 2:
				{
					// Save Zones
					db_saveZones();
					resetSelection(client);
					ZoneMenu(client);
				}
				case 3:
				{
					// Edit Zone Settings
					ZoneSettings(client);
				}
				case 4:
				{
					// Reload Zones
					db_selectMapZones();
					CPrintToChat(client, "%t", "SurfZones3", g_szChatPrefix);
					resetSelection(client);
					ZoneMenu(client);
				}
			}
		}
		case MenuAction_End:
		{
			delete tMenu;
		}
	}

	return 0;
}

public void EditZoneGroup(int client)
{
	Menu editZoneGroupMenu = new Menu(h_editZoneGroupMenu);
	editZoneGroupMenu.SetTitle("Which zones do you want to edit?");
	editZoneGroupMenu.AddItem("1", "Normal map zones");
	editZoneGroupMenu.AddItem("2", "Bonus zones");
	editZoneGroupMenu.AddItem("3", "Misc zones");
	editZoneGroupMenu.ExitButton = true;
	editZoneGroupMenu.Display(client, MENU_TIME_FOREVER);
}

public int h_editZoneGroupMenu(Handle tMenu, MenuAction action, int client, int item)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			switch (item)
			{
				case 0: // Normal map zones
				{
					g_CurrentSelectedZoneGroup[client] = 0;
					ListZones(client, true);
				}
				case 1: // Bonus Zones
				{
					ListBonusGroups(client);
				}
				case 2: // Misc zones
				{
					g_CurrentSelectedZoneGroup[client] = 0;
					ListZones(client, false);
				}
			}
		}
		case MenuAction_Cancel:
		{
			resetSelection(client);
			ZoneMenu(client);
		}
		case MenuAction_End:
		{
			delete tMenu;
		}
	}

	return 0;
}

public void ListBonusGroups(int client)
{
	Menu h_bonusGroupListing = new Menu(Handler_bonusGroupListing);
	h_bonusGroupListing.SetTitle("Available Bonuses");

	char listGroupName[256], ZoneId[64], Id[64];
	if (g_mapZoneGroupCount > 1)
	{ // Types: Start(1), End(2), Stage(3), Checkpoint(4), Speed(5), TeleToStart(6), Validator(7), Chekcer(8), Stop(0)
		for (int i = 1; i < g_mapZoneGroupCount; ++i)
		{
			Format(ZoneId, sizeof(ZoneId), "%s", g_szZoneGroupName[i]);
			IntToString(i, Id, sizeof(Id));
			Format(listGroupName, sizeof(listGroupName), ZoneId);
			h_bonusGroupListing.AddItem(Id, ZoneId);
		}
	}
	else
	{
		h_bonusGroupListing.AddItem("", "No Bonuses are available", ITEMDRAW_DISABLED);
	}
	h_bonusGroupListing.ExitButton = true;
	h_bonusGroupListing.Display(client, MENU_TIME_FOREVER);
}

public int Handler_bonusGroupListing(Handle tMenu, MenuAction action, int client, int item)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char aID[64];
			GetMenuItem(tMenu, item, aID, sizeof(aID));
			g_CurrentSelectedZoneGroup[client] = StringToInt(aID);
			ListBonusSettings(client);
		}
		case MenuAction_Cancel:
		{
			resetSelection(client);
			EditZoneGroup(client);
		}
		case MenuAction_End:
		{
			delete tMenu;
		}
	}

	return 0;
}

public void ListBonusSettings(int client)
{
	Menu h_ListBonusSettings = new Menu(Handler_ListBonusSettings);
	h_ListBonusSettings.SetTitle("Settings for %s", g_szZoneGroupName[g_CurrentSelectedZoneGroup[client]]);

	h_ListBonusSettings.AddItem("1", "Create a new zone");
	h_ListBonusSettings.AddItem("2", "List Zones in this group");
	h_ListBonusSettings.AddItem("3", "Rename Bonus");
	h_ListBonusSettings.AddItem("4", "Delete this group");

	h_ListBonusSettings.ExitButton = true;
	h_ListBonusSettings.Display(client, MENU_TIME_FOREVER);
}

public int Handler_ListBonusSettings(Handle tMenu, MenuAction action, int client, int item)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			switch (item)
			{
				case 0:SelectBonusZoneType(client);
				case 1:listZonesInGroup(client);
				case 2:renameBonusGroup(client);
				case 3:checkForMissclick(client);
			}
		}
		case MenuAction_Cancel:
		{
			resetSelection(client);
			ListBonusGroups(client);
		}
		case MenuAction_End:
		{
			delete tMenu;
		}
	}

	return 0;
}

public void checkForMissclick(int client)
{
	Menu h_checkForMissclick = new Menu(Handle_checkForMissclick);
	h_checkForMissclick.SetTitle("Delete all zones in %s?", g_szZoneGroupName[g_CurrentSelectedZoneGroup[client]]);

	h_checkForMissclick.AddItem("1", "NO");
	h_checkForMissclick.AddItem("2", "NO");
	h_checkForMissclick.AddItem("3", "YES");
	h_checkForMissclick.AddItem("4", "NO");

	h_checkForMissclick.ExitButton = true;
	h_checkForMissclick.Display(client, MENU_TIME_FOREVER);
}

public int Handle_checkForMissclick(Handle tMenu, MenuAction action, int client, int item)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			switch (item)
			{
				case 0:ListBonusSettings(client);
				case 1:ListBonusSettings(client);
				case 2:db_deleteZonesInGroup(client);
				case 3:ListBonusSettings(client);
			}
		}
		case MenuAction_Cancel:
		{
			ListBonusSettings(client);
		}
		case MenuAction_End:
		{
			delete tMenu;
		}
	}

	return 0;
}

public void listZonesInGroup(int client)
{
	Menu h_listBonusZones = new Menu(Handler_listBonusZones);
	if (g_mapZoneCountinGroup[g_CurrentSelectedZoneGroup[client]] > 0)
	{ // Types: Start(1), End(2), Stage(3), Checkpoint(4), Speed(5), TeleToStart(6), Validator(7), Chekcer(8), Stop(0)
		char listZoneName[256], ZoneId[64], Id[64];
		for (int i = 0; i < g_mapZonesCount; ++i)
		{
			if (g_mapZones[i].ZoneGroup == g_CurrentSelectedZoneGroup[client])
			{
				Format(ZoneId, sizeof(ZoneId), "%s-%i", g_szZoneDefaultNames[g_mapZones[i].ZoneType], g_mapZones[i].ZoneTypeId);
				IntToString(i, Id, sizeof(Id));
				Format(listZoneName, sizeof(listZoneName), ZoneId);
				h_listBonusZones.AddItem(Id, ZoneId);
			}
		}
	}
	else
	{
		h_listBonusZones.AddItem("", "No zones are available", ITEMDRAW_DISABLED);
	}
	h_listBonusZones.ExitButton = true;
	h_listBonusZones.Display(client, MENU_TIME_FOREVER);
}

public int Handler_listBonusZones(Handle tMenu, MenuAction action, int client, int item)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char aID[64];
			GetMenuItem(tMenu, item, aID, sizeof(aID));
			g_ClientSelectedZone[client] = StringToInt(aID);
			g_CurrentZoneType[client] = g_mapZones[g_ClientSelectedZone[client]].ZoneType;
			DrawBeamBox(client);
			g_Editing[client] = 2;
			if (g_ClientSelectedZone[client] != -1)
			{
				GetClientSelectedZone(client, g_CurrentZoneTeam[client], g_CurrentZoneVis[client]);
			}
			EditorMenu(client);
		}
		case MenuAction_Cancel:
		{
			ListBonusSettings(client);
		}
		case MenuAction_End:
		{
			delete tMenu;
		}
	}

	return 0;
}

public void renameBonusGroup(int client)
{
	if (!IsValidClient(client))
		return;

	CPrintToChat(client, "%t", "SurfZones4", g_szChatPrefix);
	g_ClientRenamingZone[client] = true;
}

// Types: Start(1), End(2), Stage(3), Checkpoint(4), Speed(5), TeleToStart(6), Validator(7), Chekcer(8), Stop(0)
public void SelectBonusZoneType(int client)
{
	Menu h_selectBonusZoneType = new Menu(Handler_selectBonusZoneType);
	h_selectBonusZoneType.SetTitle("Select Bonus Zone Type");

	h_selectBonusZoneType.AddItem("1", "Start");
	h_selectBonusZoneType.AddItem("2", "End");
	h_selectBonusZoneType.AddItem("3", "Stage");
	h_selectBonusZoneType.AddItem("4", "Checkpoint");

	h_selectBonusZoneType.ExitButton = true;
	h_selectBonusZoneType.Display(client, MENU_TIME_FOREVER);
}

public int Handler_selectBonusZoneType(Handle tMenu, MenuAction action, int client, int item)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char aID[12];
			GetMenuItem(tMenu, item, aID, sizeof(aID));
			g_CurrentZoneType[client] = StringToInt(aID);
			if (g_bEditZoneType[client]) {
				db_selectzoneTypeIds(g_CurrentZoneType[client], client, g_CurrentSelectedZoneGroup[client]);
			}
			else
				EditorMenu(client);
		}
		case MenuAction_Cancel:
		{
			resetSelection(client);
			SelectZoneGroup(client);
		}
		case MenuAction_End:
		{
			delete tMenu;
		}
	}

	return 0;
}

// Create zone 2nd
public void SelectZoneGroup(int client)
{
	Menu newZoneGroupMenu = new Menu(h_newZoneGroupMenu);
	newZoneGroupMenu.SetTitle("Which zones do you want to create?");

	newZoneGroupMenu.AddItem("1", "Normal map zones");
	newZoneGroupMenu.AddItem("2", "Bonus zones");
	newZoneGroupMenu.AddItem("3", "Misc zones");

	newZoneGroupMenu.ExitButton = true;
	newZoneGroupMenu.Display(client, MENU_TIME_FOREVER);
}

public int h_newZoneGroupMenu(Handle tMenu, MenuAction action, int client, int item)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			switch (item)
			{
				case 0: // Normal map zones
				{
					g_CurrentSelectedZoneGroup[client] = 0;
					SelectNormalZoneType(client);
				}
				case 1: // Bonus Zones
				{
					g_CurrentSelectedZoneGroup[client] = -1;
					StartBonusZoneCreation(client);
				}
				case 2: // Misc zones
				{
					g_CurrentSelectedZoneGroup[client] = 0;
					SelectMiscZoneType(client);
				}
			}
		}
		case MenuAction_Cancel:
		{
			resetSelection(client);
			ZoneMenu(client);
		}
		case MenuAction_End:
		{
			delete tMenu;
		}
	}

	return 0;
}

public void StartBonusZoneCreation(int client)
{
	Menu CreateBonusFirst = new Menu(H_CreateBonusFirst);
	CreateBonusFirst.SetTitle("Create the Bonus Start Zone:");
	if (g_Editing[client] == 0)
		CreateBonusFirst.AddItem("1", "Start Drawing");
	else
	{
		CreateBonusFirst.AddItem("1", "Restart Drawing");
		CreateBonusFirst.AddItem("2", "Save Bonus Start Zone");

	}
	CreateBonusFirst.ExitButton = true;
	CreateBonusFirst.Display(client, MENU_TIME_FOREVER);
}

public int H_CreateBonusFirst(Handle tMenu, MenuAction action, int client, int item)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			switch (item)
			{
				case 0:
				{
					// Start
					g_Editing[client] = 10;
					float pos[3], ang[3];
					GetClientEyePosition(client, pos);
					GetClientEyeAngles(client, ang);
					TR_TraceRayFilter(pos, ang, MASK_PLAYERSOLID, RayType_Infinite, TraceRayDontHitSelf, client);
					TR_GetEndPosition(g_fBonusStartPos[client][0]);
					StartBonusZoneCreation(client);
				}
				case 1:
				{
					if (!IsValidClient(client))
						return 0;

					g_Editing[client] = 2;
					CPrintToChat(client, "%t", "SurfZones5", g_szChatPrefix);
					EndBonusZoneCreation(client);
				}
			}
		}
		case MenuAction_Cancel:
		{
			resetSelection(client);
			SelectZoneGroup(client);
		}
		case MenuAction_End:
		{
			delete tMenu;
		}
	}

	return 0;
}

public void EndBonusZoneCreation(int client)
{
	Menu CreateBonusSecond = new Menu(H_CreateBonusSecond);
	CreateBonusSecond.SetTitle("Create the Bonus End Zone:");
	if (g_Editing[client] == 2)
		CreateBonusSecond.AddItem("1", "Start Drawing");
	else
	{
		CreateBonusSecond.AddItem("1", "Restart Drawing");
		CreateBonusSecond.AddItem("2", "Save Bonus End Zone");
	}
	CreateBonusSecond.ExitButton = true;
	CreateBonusSecond.Display(client, MENU_TIME_FOREVER);
}

public int H_CreateBonusSecond(Handle tMenu, MenuAction action, int client, int item)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			switch (item)
			{
				case 0:
				{
					// Start
					g_Editing[client] = 11;
					float pos[3], ang[3];
					GetClientEyePosition(client, pos);
					GetClientEyeAngles(client, ang);
					TR_TraceRayFilter(pos, ang, MASK_PLAYERSOLID, RayType_Infinite, TraceRayDontHitSelf, client);
					TR_GetEndPosition(g_fBonusEndPos[client][0]);
					EndBonusZoneCreation(client);
				}
				case 1:
				{
					g_Editing[client] = 2;
					SaveBonusZones(client);
					ZoneMenu(client);
				}
			}
		}
		case MenuAction_Cancel:
		{
			resetSelection(client);
			SelectZoneGroup(client);
		}
		case MenuAction_End:
		{
			delete tMenu;
		}
	}

	return 0;
}

public void SaveBonusZones(int client)
{
	if ((g_fBonusEndPos[client][0][0] != -1.0 && g_fBonusEndPos[client][0][1] != -1.0 && g_fBonusEndPos[client][0][2] != -1.0) || (g_fBonusStartPos[client][1][0] != -1.0 && g_fBonusStartPos[client][1][1] != -1.0 && g_fBonusStartPos[client][1][2] != -1.0))
	{
		int id2 = g_mapZonesCount + 1;
		db_insertZone(g_mapZonesCount, 1, 0, g_fBonusStartPos[client][0][0], g_fBonusStartPos[client][0][1], g_fBonusStartPos[client][0][2], g_fBonusStartPos[client][1][0], g_fBonusStartPos[client][1][1], g_fBonusStartPos[client][1][2], 0, 0, g_mapZoneGroupCount);
		db_insertZone(id2, 2, 0, g_fBonusEndPos[client][0][0], g_fBonusEndPos[client][0][1], g_fBonusEndPos[client][0][2], g_fBonusEndPos[client][1][0], g_fBonusEndPos[client][1][1], g_fBonusEndPos[client][1][2], 0, 0, g_mapZoneGroupCount);
		CPrintToChat(client, "%t", "SurfZones6", g_szChatPrefix);
	}
	else
		CPrintToChat(client, "%t", "SurfZones7", g_szChatPrefix);

	resetSelection(client);
	ZoneMenu(client);
	db_selectMapZones();
}

public void SelectNormalZoneType(int client)
{
	Menu SelectNormalZoneMenu = new Menu(Handle_SelectNormalZoneType);
	SelectNormalZoneMenu.SetTitle("Select Zone Type");
	SelectNormalZoneMenu.AddItem("1", "Start");
	SelectNormalZoneMenu.AddItem("2", "End");
	if (g_mapZonesTypeCount[g_CurrentSelectedZoneGroup[client]][3] == 0 && g_mapZonesTypeCount[g_CurrentSelectedZoneGroup[client]][4] == 0)
	{
		SelectNormalZoneMenu.AddItem("3", "Stage");
		SelectNormalZoneMenu.AddItem("4", "Checkpoint");
	}
	else if (g_mapZonesTypeCount[g_CurrentSelectedZoneGroup[client]][3] > 0 && g_mapZonesTypeCount[g_CurrentSelectedZoneGroup[client]][4] == 0)
	{
		SelectNormalZoneMenu.AddItem("3", "Stage");
	}
	else if (g_mapZonesTypeCount[g_CurrentSelectedZoneGroup[client]][3] == 0 && g_mapZonesTypeCount[g_CurrentSelectedZoneGroup[client]][4] > 0)
		SelectNormalZoneMenu.AddItem("4", "Checkpoint");

	SelectNormalZoneMenu.AddItem("hook", "Hook Zone");

	SelectNormalZoneMenu.ExitButton = true;
	SelectNormalZoneMenu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_SelectNormalZoneType(Handle tMenu, MenuAction action, int client, int item)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char aID[12];
			GetMenuItem(tMenu, item, aID, sizeof(aID));
			if (StrEqual(aID, "hook"))
				HookZonesMenu(client);
			else
			{
				g_CurrentZoneType[client] = StringToInt(aID);
				if (g_bEditZoneType[client])
					db_selectzoneTypeIds(g_CurrentZoneType[client], client, 0);
				else
					EditorMenu(client);
			}
		}
		case MenuAction_Cancel:
		{
			resetSelection(client);
			SelectZoneGroup(client);
		}
		case MenuAction_End:
		{
			delete tMenu;
		}
	}

	return 0;
}

public void ZoneSettings(int client)
{
	Menu ZoneSettingMenu = new Menu(Handle_ZoneSettingMenu);
	ZoneSettingMenu.SetTitle("Global Zone Settings");
	switch (GetConVarInt(g_hZoneDisplayType))
	{
		case 0:
			ZoneSettingMenu.AddItem("1", "Visible: Nothing");
		case 1:
			ZoneSettingMenu.AddItem("1", "Visible: Lower edges");
		case 2:
			ZoneSettingMenu.AddItem("1", "Visible: All sides");
	}

	switch (GetConVarInt(g_hZonesToDisplay))
	{
		case 1:
			ZoneSettingMenu.AddItem("2", "Draw Zones: Start & End");
		case 2:
			ZoneSettingMenu.AddItem("2", "Draw Zones: Start, End, Stage, Bonus");
		case 3:
			ZoneSettingMenu.AddItem("2", "Draw Zones: All zones");
	}
	ZoneSettingMenu.ExitButton = true;
	ZoneSettingMenu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_ZoneSettingMenu(Handle tMenu, MenuAction action, int client, int item)
{
	switch (action)
	{

		case MenuAction_Select:
		{
			switch (item)
			{
				case 0:
				{
					if (GetConVarInt(g_hZoneDisplayType) < 2)
					{
						SetConVarInt(g_hZoneDisplayType, (GetConVarInt(g_hZoneDisplayType) + 1));
					}
					else
						SetConVarInt(g_hZoneDisplayType, 0);
				}
				case 1:
				{
					if (GetConVarInt(g_hZonesToDisplay) < 3)
					{
						SetConVarInt(g_hZonesToDisplay, (GetConVarInt(g_hZonesToDisplay) + 1));
					}
					else
						SetConVarInt(g_hZonesToDisplay, 1);
				}
			}
			CreateTimer(0.1, RefreshZoneSettings, client, TIMER_FLAG_NO_MAPCHANGE);
		}
		case MenuAction_Cancel:
		{
			resetSelection(client);
			ZoneMenu(client);
		}
		case MenuAction_End:
		{
			delete tMenu;
		}
	}

	return 0;
}

public void SelectMiscZoneType(int client)
{
	Menu SelectZoneMenu = new Menu(Handle_SelectMiscZoneType);
	SelectZoneMenu.SetTitle("Select Misc Zone Type");

	SelectZoneMenu.AddItem("6", "TeleToStart");
	SelectZoneMenu.AddItem("7", "Validator");
	SelectZoneMenu.AddItem("8", "Checker");
	// fluffys add antijump and antiduck zones to menu
	SelectZoneMenu.AddItem("9", "AntiJump");
	SelectZoneMenu.AddItem("10", "AntiDuck");
	SelectZoneMenu.AddItem("11", "MaxSpeed");
	SelectZoneMenu.AddItem("0", "Stop");

	SelectZoneMenu.ExitButton = true;
	SelectZoneMenu.Display(client, MENU_TIME_FOREVER);
}

public int Handle_SelectMiscZoneType(Handle tMenu, MenuAction action, int client, int item)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char aID[12];
			GetMenuItem(tMenu, item, aID, sizeof(aID));
			g_CurrentZoneType[client] = StringToInt(aID);
			if (g_bEditZoneType[client]) {
				db_selectzoneTypeIds(g_CurrentZoneType[client], client, 0);
			}
			else
				EditorMenu(client);
		}
		case MenuAction_Cancel:
		{
			resetSelection(client);
			SelectZoneGroup(client);
		}
		case MenuAction_End:
		{
			delete tMenu;
		}
	}

	return 0;
}
// Types: Start(1), End(2), Stage(3), Checkpoint(4), Speed(5), TeleToStart(6), Validator(7), Chekcer(8), Stop(0)
public int Handle_EditZoneTypeId(Handle tMenu, MenuAction action, int client, int item)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char selection[12];
			GetMenuItem(tMenu, item, selection, sizeof(selection));
			g_CurrentZoneTypeId[client] = StringToInt(selection);
			EditorMenu(client);
		}
		case MenuAction_Cancel:
		{
			SelectNormalZoneType(client);
		}
		case MenuAction_End:
		{
			delete tMenu;
		}
	}

	return 0;
}

public void ListZones(int client, bool mapzones)
{
	Menu ZoneList = new Menu(MenuHandler_ZoneModify);
	ZoneList.SetTitle("Available Zones");

	char listZoneName[256], ZoneId[64], Id[64];
	if (g_mapZonesCount > 0)
	{ // Types: Start(1), End(2), Stage(3), Checkpoint(4), Speed(5), TeleToStart(6), Validator(7), Chekcer(8), Stop(0) // fluffys AntiJump (9), AntiDuck (10)
		if (mapzones)
		{
			for (int i = 0; i < g_mapZonesCount; ++i)
			{
				if (g_mapZones[i].ZoneGroup == 0 && 0 < g_mapZones[i].ZoneType < 6)
				{
					// Make stages match the stage number, rather than the ID, to make it more clear for the user
					if (g_mapZones[i].ZoneType == 3)
						Format(ZoneId, sizeof(ZoneId), "%s-%i", g_szZoneDefaultNames[g_mapZones[i].ZoneType], (g_mapZones[i].ZoneTypeId + 2));
					else
						Format(ZoneId, sizeof(ZoneId), "%s-%i", g_szZoneDefaultNames[g_mapZones[i].ZoneType], g_mapZones[i].ZoneTypeId);
					IntToString(i, Id, sizeof(Id));
					Format(listZoneName, sizeof(listZoneName), ZoneId);
					ZoneList.AddItem(Id, ZoneId);
				}
			}
		}
		else
		{
			for (int i = 0; i < g_mapZonesCount; ++i)
			{
				if (g_mapZones[i].ZoneGroup == 0 && (g_mapZones[i].ZoneType == 0 || g_mapZones[i].ZoneType > 5))
				{
					Format(ZoneId, sizeof(ZoneId), "%s-%i", g_szZoneDefaultNames[g_mapZones[i].ZoneType], g_mapZones[i].ZoneTypeId);
					IntToString(i, Id, sizeof(Id));
					Format(listZoneName, sizeof(listZoneName), ZoneId);
					ZoneList.AddItem(Id, ZoneId);
				}
			}
		}
	}
	else
	{
		ZoneList.AddItem("", "No zones are available", ITEMDRAW_DISABLED);
	}
	ZoneList.ExitButton = true;
	ZoneList.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_ZoneModify(Handle tMenu, MenuAction action, int client, int item)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char aID[64];
			GetMenuItem(tMenu, item, aID, sizeof(aID));
			g_ClientSelectedZone[client] = StringToInt(aID);
			g_CurrentZoneType[client] = g_mapZones[g_ClientSelectedZone[client]].ZoneType;
			DrawBeamBox(client);
			g_Editing[client] = 2;
			if (g_ClientSelectedZone[client] != -1)
			{
				GetClientSelectedZone(client, g_CurrentZoneTeam[client], g_CurrentZoneVis[client]);
			}
			EditorMenu(client);
		}
		case MenuAction_Cancel:
		{
			resetSelection(client);
			ZoneMenu(client);
		}
		case MenuAction_End:
		{
			delete tMenu;
		}
	}

	return 0;
}

/*
g_Editing:
0: Starting a new zone, not yet drawing
1: Drawing a new zone
2: Editing paused
3: Scaling zone
10: Creating bonus start
11: creating bonus end
*/

public void EditorMenu(int client)
{
	// If scaling zone
	if (g_Editing[client] == 3)
	{
		DrawBeamBox(client);
		g_Editing[client] = 2;
	}

	Menu editMenu = new Menu(MenuHandler_Editor);
	// If a zone is selected
	if (g_ClientSelectedZone[client] != -1)
		editMenu.SetTitle("Editing Zone: %s-%i", g_szZoneDefaultNames[g_CurrentZoneType[client]], g_mapZones[g_ClientSelectedZone[client]].ZoneTypeId);
	else
		editMenu.SetTitle("Creating a New %s Zone", g_szZoneDefaultNames[g_CurrentZoneType[client]]);

	// If creating a completely new zone, or editing an existing one
	if (g_Editing[client] == 0)
		editMenu.AddItem("", "Start Drawing the Zone");
	else
		editMenu.AddItem("", "Restart the Zone Drawing");

	// If editing an existing zone
	if (g_Editing[client] > 0)
	{
		editMenu.AddItem("", "Set zone type");

		// If editing is paused
		if (g_Editing[client] == 2)
			editMenu.AddItem("", "Continue Editing");
		else
			editMenu.AddItem("", "Pause Editing");

		editMenu.AddItem("", "Delete Zone");
		editMenu.AddItem("", "Save Zone");

		switch (g_CurrentZoneTeam[client])
		{
			case 0:
			{
				editMenu.AddItem("", "Set Zone Yellow");
			}
			case 1:
			{
				editMenu.AddItem("", "Set Zone Green");
			}
			case 2:
			{
				editMenu.AddItem("", "Set Zone Red");
			}
			case 3:
			{
				editMenu.AddItem("", "Set Zone Blue");
			}
		}
		editMenu.AddItem("", "Go to Zone");
		editMenu.AddItem("", "Stretch Zone");

		if (g_ClientSelectedZone[client] != -1)
		{
			char szMenuItem[128];
			// Hookname
			Format(szMenuItem, sizeof(szMenuItem), "Hook Name: %s", g_mapZones[g_ClientSelectedZone[client]].HookName);
			editMenu.AddItem("", szMenuItem, ITEMDRAW_DISABLED);

			// Targetname
			Format(szMenuItem, sizeof(szMenuItem), "Target Name: %s", g_mapZones[g_ClientSelectedZone[client]].TargetName);
			editMenu.AddItem("", szMenuItem);
			
			// One jump limit
			if (g_mapZones[g_ClientSelectedZone[client]].OneJumpLimit == 1)
				editMenu.AddItem("", "Disable One Jump Limit");
			else
				editMenu.AddItem("", "Enable One Jump Limit");
			
			// Prespeed
			Format(szMenuItem, sizeof(szMenuItem), "Prespeed: %f", g_mapZones[g_ClientSelectedZone[client]].PreSpeed);
			editMenu.AddItem("", szMenuItem);
		}
	}

	editMenu.ExitButton = true;
	editMenu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_Editor(Handle tMenu, MenuAction action, int client, int item)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			switch (item)
			{
				case 0:
				{
					// Start
					g_Editing[client] = 1;
					float pos[3], ang[3];
					GetClientEyePosition(client, pos);
					GetClientEyeAngles(client, ang);
					TR_TraceRayFilter(pos, ang, MASK_PLAYERSOLID, RayType_Infinite, TraceRayDontHitSelf, client);
					TR_GetEndPosition(g_Positions[client][0]);
					EditorMenu(client);
				}
				case 1: // Setting zone type
				{
					g_bEditZoneType[client] = true;
					if (g_CurrentSelectedZoneGroup[client] == 0)
						SelectNormalZoneType(client);
					else if (g_CurrentSelectedZoneGroup[client] > 0)
						SelectBonusZoneType(client);

				}
				case 2:
				{
					// Pause
					if (g_Editing[client] == 2)
					{
						g_Editing[client] = 1;
					} else {
						DrawBeamBox(client);
						g_Editing[client] = 2;
					}
					EditorMenu(client);
				}
				case 3:
				{
					// Delete
					if (g_ClientSelectedZone[client] != -1)
					{
						db_deleteZone(client, g_mapZones[g_ClientSelectedZone[client]].ZoneId);
						resetZone(g_ClientSelectedZone[client]);
					}
					resetSelection(client);
					ZoneMenu(client);
				}
				case 4:
				{
					// Save
					if (g_ClientSelectedZone[client] != -1)
					{
						if (!g_bEditZoneType[client])
							db_updateZone(g_mapZones[g_ClientSelectedZone[client]].ZoneId, g_mapZones[g_ClientSelectedZone[client]].ZoneType, g_mapZones[g_ClientSelectedZone[client]].ZoneTypeId, g_Positions[client][0], g_Positions[client][1], g_CurrentZoneVis[client], g_CurrentZoneTeam[client], g_CurrentSelectedZoneGroup[client], g_mapZones[g_ClientSelectedZone[client]].OneJumpLimit, g_mapZones[g_ClientSelectedZone[client]].PreSpeed, g_mapZones[g_ClientSelectedZone[client]].HookName, g_mapZones[g_ClientSelectedZone[client]].TargetName);
						else
							db_updateZone(g_mapZones[g_ClientSelectedZone[client]].ZoneId, g_CurrentZoneType[client], g_CurrentZoneTypeId[client], g_Positions[client][0], g_Positions[client][1], g_CurrentZoneVis[client], g_CurrentZoneTeam[client], g_CurrentSelectedZoneGroup[client], g_mapZones[g_ClientSelectedZone[client]].OneJumpLimit, g_mapZones[g_ClientSelectedZone[client]].PreSpeed, g_mapZones[g_ClientSelectedZone[client]].HookName, g_mapZones[g_ClientSelectedZone[client]].TargetName);
						g_bEditZoneType[client] = false;
					}
					else
					{
						db_insertZone(g_mapZonesCount, g_CurrentZoneType[client], g_mapZonesTypeCount[g_CurrentSelectedZoneGroup[client]][g_CurrentZoneType[client]], g_Positions[client][0][0], g_Positions[client][0][1], g_Positions[client][0][2], g_Positions[client][1][0], g_Positions[client][1][1], g_Positions[client][1][2], 0, 0, g_CurrentSelectedZoneGroup[client]);
						g_bEditZoneType[client] = false;
					}
					CPrintToChat(client, "%t", "SurfZones8", g_szChatPrefix);
					resetSelection(client);
					ZoneMenu(client);
				}
				case 5:
				{
					// Set team
					++g_CurrentZoneTeam[client];
					if (g_CurrentZoneTeam[client] == 4)
						g_CurrentZoneTeam[client] = 0;
					EditorMenu(client);
				}
				case 6:
				{
					// Teleport
					float ZonePos[3];
					surftimer_StopTimer(client);
					AddVectors(g_Positions[client][0], g_Positions[client][1], ZonePos);
					ZonePos[0] = ZonePos[0] / 2.0;
					ZonePos[1] = ZonePos[1] / 2.0;
					ZonePos[2] = ZonePos[2] / 2.0;

					TeleportEntity(client, ZonePos, NULL_VECTOR, NULL_VECTOR);
					EditorMenu(client);
				}
				case 7:
				{
					// Scaling
					ScaleMenu(client);
				}
				case 8:
				{
					ChangeZonesHook(client);
				}
				case 9:
				{
					// Set Target Name
					g_iWaitingForResponse[client] = TargetName;
					CPrintToChat(client, "%t", "SurfZones9", g_szChatPrefix);
				}
				case 10:
				{
					// One jump limit
					if (g_mapZones[g_ClientSelectedZone[client]].OneJumpLimit == 1)
						g_mapZones[g_ClientSelectedZone[client]].OneJumpLimit = 0;
					else
						g_mapZones[g_ClientSelectedZone[client]].OneJumpLimit = 1;
					
					EditorMenu(client);
				}
				case 11:
				{
					// prespeed
					PrespeedMenu(client);
				}
			}
		}
		case MenuAction_Cancel:
		{
			resetSelection(client);
			ZoneMenu(client);
		}
		case MenuAction_End:
		{
			delete tMenu;
		}
	}

	return 0;
}

public void resetSelection(int client)
{
	g_CurrentSelectedZoneGroup[client] = -1;
	g_CurrentZoneTeam[client] = 0;
	g_CurrentZoneVis[client] = 0;
	g_ClientSelectedZone[client] = -1;
	g_Editing[client] = 0;
	g_CurrentZoneTypeId[client] = -1;
	g_CurrentZoneType[client] = -1;
	g_bEditZoneType[client] = false;

	float resetArray[] = { -1.0, -1.0, -1.0 };
	Array_Copy(resetArray, g_Positions[client][0], 3);
	Array_Copy(resetArray, g_Positions[client][1], 3);
	Array_Copy(resetArray, g_fBonusEndPos[client][0], 3);
	Array_Copy(resetArray, g_fBonusEndPos[client][1], 3);
	Array_Copy(resetArray, g_fBonusStartPos[client][0], 3);
	Array_Copy(resetArray, g_fBonusStartPos[client][1], 3);
}

public void ScaleMenu(int client)
{
	g_Editing[client] = 3;
	Menu ckScaleMenu = new Menu(MenuHandler_Scale);
	ckScaleMenu.SetTitle("Stretch Zone");

	if (g_ClientSelectedPoint[client] == 1)
		ckScaleMenu.AddItem("", "Point B");
	else
		ckScaleMenu.AddItem("", "Point A");

	ckScaleMenu.AddItem("", "+ Width");
	ckScaleMenu.AddItem("", "- Width");
	ckScaleMenu.AddItem("", "+ Length");
	ckScaleMenu.AddItem("", "- Length");
	ckScaleMenu.AddItem("", "+ Height");
	ckScaleMenu.AddItem("", "- Height");

	char ScaleSize[128];
	Format(ScaleSize, sizeof(ScaleSize), "Scale Size %f", g_AvaliableScales[g_ClientSelectedScale[client]]);
	ckScaleMenu.AddItem("", ScaleSize);

	ckScaleMenu.ExitButton = true;
	ckScaleMenu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_Scale(Handle tMenu, MenuAction action, int client, int item)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			switch (item)
			{
				case 0:
				{
					if (g_ClientSelectedPoint[client] == 1)
						g_ClientSelectedPoint[client] = 0;
					else
						g_ClientSelectedPoint[client] = 1;
				}
				case 1:
				{
					g_Positions[client][g_ClientSelectedPoint[client]][0] = g_Positions[client][g_ClientSelectedPoint[client]][0] + g_AvaliableScales[g_ClientSelectedScale[client]];
				}
				case 2:
				{
					g_Positions[client][g_ClientSelectedPoint[client]][0] = g_Positions[client][g_ClientSelectedPoint[client]][0] - g_AvaliableScales[g_ClientSelectedScale[client]];
				}
				case 3:
				{
					g_Positions[client][g_ClientSelectedPoint[client]][1] = g_Positions[client][g_ClientSelectedPoint[client]][1] + g_AvaliableScales[g_ClientSelectedScale[client]];
				}
				case 4:
				{
					g_Positions[client][g_ClientSelectedPoint[client]][1] = g_Positions[client][g_ClientSelectedPoint[client]][1] - g_AvaliableScales[g_ClientSelectedScale[client]];
				}
				case 5:
				{
					g_Positions[client][g_ClientSelectedPoint[client]][2] = g_Positions[client][g_ClientSelectedPoint[client]][2] + g_AvaliableScales[g_ClientSelectedScale[client]];
				}
				case 6:
				{
					g_Positions[client][g_ClientSelectedPoint[client]][2] = g_Positions[client][g_ClientSelectedPoint[client]][2] - g_AvaliableScales[g_ClientSelectedScale[client]];
				}
				case 7:
				{
					++g_ClientSelectedScale[client];
					if (g_ClientSelectedScale[client] == 5)
						g_ClientSelectedScale[client] = 0;
				}
			}
			ScaleMenu(client);
		}
		case MenuAction_Cancel:
		{
			EditorMenu(client);
		}
		case MenuAction_End:
		{
			delete tMenu;
		}
	}

	return 0;
}

public void PrespeedMenu(int client)
{
	Menu menu = new Menu(MenuHandler_Prespeed);
	char szTitle[128];
	if ( g_mapZones[g_ClientSelectedZone[client]].PreSpeed == 0.0)
		Format(szTitle, sizeof(szTitle), "Zone Prespeed (No Limit)");
	else
		Format(szTitle, sizeof(szTitle), "Zone Prespeed (%f)", g_mapZones[g_ClientSelectedZone[client]].PreSpeed);
	SetMenuTitle(menu, szTitle);

	AddMenuItem(menu, "250.0", "250.0");
	AddMenuItem(menu, "260.0", "260.0");
	AddMenuItem(menu, "285.0", "285.0");
	AddMenuItem(menu, "300.0", "300.0");
	AddMenuItem(menu, "350.0", "350.0");
	AddMenuItem(menu, "500.0", "500.0");
	AddMenuItem(menu, "-1.0", "Custom Limit");
	AddMenuItem(menu, "-2.0", "Remove Limit");

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int MenuHandler_Prespeed(Handle tMenu, MenuAction action, int client, int item)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char szPrespeed[32];
			GetMenuItem(tMenu, item, szPrespeed, sizeof(szPrespeed));
			float prespeed = StringToFloat(szPrespeed);
			if (prespeed == -1.0)
			{
				CPrintToChat(client, "%t", "SurfZones10", g_szChatPrefix, g_szZoneDefaultNames[g_CurrentZoneType[client]], g_mapZones[g_ClientSelectedZone[client]].ZoneTypeId);
				g_iWaitingForResponse[client] = PreSpeed;
				return 0;
			}
			else if (prespeed == -2.0)
				g_mapZones[g_ClientSelectedZone[client]].PreSpeed = 0.0;
			else
				g_mapZones[g_ClientSelectedZone[client]].PreSpeed = prespeed;
			PrespeedMenu(client);
		}
		case MenuAction_Cancel:
		{
			EditorMenu(client);
		}
		case MenuAction_End:
		{
			delete tMenu;
		}
	}

	return 0;
}

public void ChangeZonesHook(int client)
{
	Menu menu = CreateMenu(ChangeZonesHookMenuHandler);
	SetMenuTitle(menu, "Select a trigger");

	for (int i = 0; i < GetArraySize(g_TriggerMultipleList); i++)
	{
		char szTriggerName[128];
		GetArrayString(g_TriggerMultipleList, i, szTriggerName, sizeof(szTriggerName));
		AddMenuItem(menu, szTriggerName, szTriggerName);
	}
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int ChangeZonesHookMenuHandler(Handle menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
		SelectTrigger(param1, param2);
	else if (action == MenuAction_Cancel)
		g_iSelectedTrigger[param1] = -1;
	else if (action == MenuAction_End)
		delete menu;

	return 0;
}

public void SelectTrigger(int client, int index)
{
	g_iSelectedTrigger[client] = index;
	char szTriggerName[128];
	GetArrayString(g_TriggerMultipleList, index, szTriggerName, sizeof(szTriggerName));

	Menu menu = CreateMenu(ZoneHookHandler);
	SetMenuTitle(menu, szTriggerName);

	char szParam[128];
	IntToString(index, szParam, sizeof(szParam));
	AddMenuItem(menu, szParam, "Teleport to zone");
	AddMenuItem(menu, szParam, "Hook zone");
	AddMenuItem(menu, szParam, "Back");

	SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int ZoneHookHandler(Handle menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char szTriggerIndex[128];
		GetMenuItem(menu, param2, szTriggerIndex, sizeof(szTriggerIndex));
		int index = StringToInt(szTriggerIndex);
		int iEnt = GetArrayCell(g_hTriggerMultiple, index);
		g_iSelectedTrigger[param1] = index;
		char szTriggerName[128];
		GetArrayString(g_TriggerMultipleList, index, szTriggerName, sizeof(szTriggerName));

		switch (param2)
		{
			case 0: // teleport
			{
				float position[3];
				float angles[3];
				GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", position);
				GetClientEyeAngles(param1, angles);

				CPrintToChat(param1, "%t", "TeleportingTo", g_szChatPrefix, szTriggerName, position[0], position[1], position[2]);

				teleportEntitySafe(param1, position, angles, view_as<float>( { 0.0, 0.0, -100.0 } ), true);
				SelectTrigger(param1, index);
			}
			case 1: // hook zone
			{
				float position[3], fMins[3], fMaxs[3];

				GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", position);
				GetEntPropVector(iEnt, Prop_Send, "m_vecMins", fMins);
				GetEntPropVector(iEnt, Prop_Send, "m_vecMaxs", fMaxs);
					

				g_mapZones[g_ClientSelectedZone[param1]].CenterPoint[0] = position[0];
				g_mapZones[g_ClientSelectedZone[param1]].CenterPoint[1] = position[1];
				g_mapZones[g_ClientSelectedZone[param1]].CenterPoint[2] = position[2];

				for (int j = 0; j < 3; j++)
				{
					fMins[j] = (fMins[j] + position[j]);
				}

				for (int j = 0; j < 3; j++)
				{
					fMaxs[j] = (fMaxs[j] + position[j]);
				}

				g_mapZones[g_ClientSelectedZone[param1]].PointA[0] = fMins[0];
				g_mapZones[g_ClientSelectedZone[param1]].PointA[1] = fMins[1];
				g_mapZones[g_ClientSelectedZone[param1]].PointA[2] = fMins[2];
				g_mapZones[g_ClientSelectedZone[param1]].PointB[0] = fMaxs[0];
				g_mapZones[g_ClientSelectedZone[param1]].PointB[1] = fMaxs[1];
				g_mapZones[g_ClientSelectedZone[param1]].PointB[2] = fMaxs[2];

				for (int j = 0; j < 3; j++)
				{
					g_fZoneCorners[g_ClientSelectedZone[param1]][0][j] = g_mapZones[g_ClientSelectedZone[param1]].PointA[j];
					g_fZoneCorners[g_ClientSelectedZone[param1]][7][j] = g_mapZones[g_ClientSelectedZone[param1]].PointB[j];
				}

				for(int j = 1; j < 7; j++)
				{
					for(int k = 0; k < 3; k++)
					{
						g_fZoneCorners[g_ClientSelectedZone[param1]][j][k] = g_fZoneCorners[g_ClientSelectedZone[param1]][((j >> (2-k)) & 1) * 7][k];
					}
				}

				g_Positions[param1][0] = fMins;
				g_Positions[param1][1] = fMaxs;

				Format(g_mapZones[g_ClientSelectedZone[param1]].HookName, sizeof(g_mapZones), szTriggerName);

				CPrintToChat(param1, "%t", "SurfZones12", g_szChatPrefix, g_szZoneDefaultNames[g_CurrentZoneType[param1]], g_mapZones[g_ClientSelectedZone[param1]].ZoneTypeId, szTriggerName);
				SelectTrigger(param1, index);
			}
			case 2: // Back
			{
				g_iSelectedTrigger[param1] = -1;
				EditorMenu(param1);
			}
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}

	return 0;
}

public void GetClientSelectedZone(int client, int &team, int &vis)
{
	if (g_ClientSelectedZone[client] != -1)
	{
		Format(g_CurrentZoneName[client], 32, "%s", g_mapZones[g_ClientSelectedZone[client]].ZoneName);
		Array_Copy(g_mapZones[g_ClientSelectedZone[client]].PointA, g_Positions[client][0], 3);
		Array_Copy(g_mapZones[g_ClientSelectedZone[client]].PointB, g_Positions[client][1], 3);
		team = g_mapZones[g_ClientSelectedZone[client]].Team;
		vis = g_mapZones[g_ClientSelectedZone[client]].Vis;
	}
}

public void ClearZonesMenu(int client)
{
	Menu hClearZonesMenu = new Menu(MenuHandler_ClearZones);

	hClearZonesMenu.SetTitle("Are you sure, you want to clear all zones on this map?");
	hClearZonesMenu.AddItem("", "NO GO BACK!");
	hClearZonesMenu.AddItem("", "NO GO BACK!");
	hClearZonesMenu.AddItem("", "YES! DO IT!");

	hClearZonesMenu.Display(client, 20);
}

public int MenuHandler_ClearZones(Handle tMenu, MenuAction action, int client, int item)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (item == 2)
			{
				for (int i = 0; i < MAXZONES; i++)
				{
					g_mapZones[i].ZoneId = -1;
					g_mapZones[i].PointA = view_as<float>({-1.0, -1.0, -1.0});
					g_mapZones[i].PointB = view_as<float>({-1.0, -1.0, -1.0});
					g_mapZones[i].ZoneId = -1;
					g_mapZones[i].ZoneType = -1;
					g_mapZones[i].ZoneTypeId = -1;
					Format(g_mapZones[i].ZoneName, sizeof(MapZone::ZoneName), "");
					g_mapZones[i].Vis = 0;
					g_mapZones[i].Team = 0;
				}
				g_mapZonesCount = 0;
				db_deleteMapZones();
				CPrintToChat(client, "%t", "SurfZones13", g_szChatPrefix);
				RemoveZones();
			}
			resetSelection(client);
			ZoneMenu(client);
		}
		case MenuAction_End:
		{
			delete tMenu;
		}
	}

	return 0;
}

stock void GetMiddleOfABox(const float vec1[3], const float vec2[3], float buffer[3])
{
	float mid[3];
	MakeVectorFromPoints(vec1, vec2, mid);
	mid[0] = mid[0] / 2.0;
	mid[1] = mid[1] / 2.0;
	mid[2] = mid[2] / 2.0;
	AddVectors(vec1, mid, buffer);
}

stock void RefreshZones()
{
	RemoveZones();
	for (int i = 0; i < g_mapZonesCount; i++)
	{
		CreateZoneEntity(i);
	}
}

stock void RemoveZones()
{
	// First remove any old zone triggers
	int iEnts = GetMaxEntities();
	char sClassName[64];
	for (int i = MaxClients; i < iEnts; i++)
	{
		if (IsValidEntity(i)
			 && IsValidEdict(i)
			 && GetEdictClassname(i, sClassName, sizeof(sClassName))
			 && StrContains(sClassName, "trigger_multiple") != -1
			 && GetEntPropString(i, Prop_Data, "m_iName", sClassName, sizeof(sClassName))
			 && StrContains(sClassName, "sm_ckZone") != -1)
		{
			// Don't destroy hooked zone entities
			if (StrContains(sClassName, "sm_ckZoneHooked") == -1)
			{
				SDKUnhook(i, SDKHook_StartTouch, StartTouchTrigger);
				SDKUnhook(i, SDKHook_EndTouch, EndTouchTrigger);
				AcceptEntityInput(i, "Disable");
				AcceptEntityInput(i, "Kill");
			}
		}
	}
}

void resetZone(int zoneIndex)
{
	g_mapZones[zoneIndex].ZoneId = -1;
	g_mapZones[zoneIndex].PointA = view_as<float>({-1.0, -1.0, -1.0});
	g_mapZones[zoneIndex].PointB = view_as<float>({-1.0, -1.0, -1.0});
	g_mapZones[zoneIndex].ZoneType = -1;
	g_mapZones[zoneIndex].ZoneTypeId = -1;
	Format(g_mapZones[zoneIndex].ZoneName, sizeof(MapZone::ZoneName), "");
	g_mapZones[zoneIndex].Vis = 0;
	g_mapZones[zoneIndex].Team = 0;
	g_mapZones[zoneIndex].ZoneGroup = 0;
}
