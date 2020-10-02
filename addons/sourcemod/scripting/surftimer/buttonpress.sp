// Start Timer
public void CL_OnStartTimerPress(int client)
{
	g_fStartTime[client] = GetGameTime();
	int zgrp = g_iClientInZone[client][2];
	float fVelocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);

	if (!IsFakeClient(client))
	{
		if (IsValidClient(client))
		{
			if (!g_bServerDataLoaded)
			{
				if (GetGameTime() - g_fErrorMessage[client] > 1.0)
				{
					CPrintToChat(client, "%t", "BPress1", g_szChatPrefix);
					ClientCommand(client, "play buttons\\button10.wav");
					g_fErrorMessage[client] = GetGameTime();
				}
				return;
			}
			else if (g_bLoadingSettings[client])
			{
				if (GetGameTime() - g_fErrorMessage[client] > 1.0)
				{
					CPrintToChat(client, "%t", "BPress2", g_szChatPrefix);
					ClientCommand(client, "play buttons\\button10.wav");
					g_fErrorMessage[client] = GetGameTime();
				}
				return;
			}
			else if (!g_bSettingsLoaded[client])
			{
				if (GetGameTime() - g_fErrorMessage[client] > 1.0)
				{
					CPrintToChat(client, "%t", "BPress3", g_szChatPrefix);
					ClientCommand(client, "play buttons\\button10.wav");
					g_fErrorMessage[client] = GetGameTime();
				}
				return;
			}
		}
		if (g_bNewReplay[client] || g_bNewBonus[client]) // Don't allow starting the timer, if players record is being saved
		return;
	}

	if (!g_bSpectate[client] && !g_bNoClip[client] && ((GetGameTime() - g_fLastTimeNoClipUsed[client]) > 2.0))
	{
		if (g_bActivateCheckpointsOnStart[client])
		g_bCheckpointsEnabled[client] = true;

		// Reset Run Variables
		tmpDiff[client] = 9999.0;
		g_fPauseTime[client] = 0.0;
		g_fStartPauseTime[client] = 0.0;
		g_bPause[client] = false;
		SetEntityMoveType(client, MOVETYPE_WALK);
		SetEntityRenderMode(client, RENDER_NORMAL);
		g_fCurrentRunTime[client] = 0.0;
		g_bPositionRestored[client] = false;
		g_bMissedMapBest[client] = true;
		g_bMissedBonusBest[client] = true;
		g_bTimerRunning[client] = true;
		g_bTop10Time[client] = false;
		// Strafe Sync
		g_iGoodGains[client] = 0;
		g_iTotalMeasures[client] = 0;
		g_iCurrentCheckpoint[client] = 0;
		g_iCheckpointsPassed[client] = 0;
		g_bIsValidRun[client] = false;
		g_bSavingMapTime[client] = false;

		if (!IsFakeClient(client))
		{
			// Reset Checkpoint Times
			for (int i = 0; i < CPLIMIT; i++)
			g_fCheckpointTimesNew[g_iClientInZone[client][2]][client][i] = 0.0;

			// Set missed record time variables
			if (g_iClientInZone[client][2] == 0)
			{
				if (g_fPersonalStyleRecord[0][client] > 0.0)
				g_bMissedMapBest[client] = false;
			}
			else
			{
				if (g_fStylePersonalRecordBonus[0][g_iClientInZone[client][2]][client] > 0.0)
				g_bMissedBonusBest[client] = false;

			}

			// int startSpeed[3];

			g_iStartVelsNew[client][zgrp][0] = RoundToNearest(SquareRoot(Pow(fVelocity[0], 2.0) + Pow(fVelocity[1], 2.0))); // XY
			g_iStartVelsNew[client][zgrp][1] = RoundToNearest(SquareRoot(Pow(fVelocity[0], 2.0) + Pow(fVelocity[1], 2.0) + Pow(fVelocity[2], 2.0))); // XYZ
			g_iStartVelsNew[client][zgrp][2] = RoundToNearest(fVelocity[2]); // Z

			int idiff;
			if (g_iStartVelsServerRecord[zgrp][1] == 0)
				idiff = g_iStartVelsNew[client][zgrp][1];
			else
				idiff = (g_iStartVelsNew[client][zgrp][1] - g_iStartVelsServerRecord[zgrp][1]);

			char szDiff[32], szDiff2[32];
			if (g_iStartVelsNew[client][zgrp][1] > g_iStartVelsServerRecord[zgrp][1] || g_iStartVelsServerRecord[zgrp][1] == 0)
			{
				Format(g_szLastSpeedDifference[client], 128, "(WR +%d)", idiff);
				Format(szDiff, sizeof(szDiff), "+%d", idiff);
			}
			else
			{
				Format(g_szLastSpeedDifference[client], 128, "(WR %d)", idiff);
				Format(szDiff, sizeof(szDiff), "%d", idiff);
			}

			if (g_iStartVelsRecord[client][zgrp][1] == 0)
				idiff = g_iStartVelsNew[client][zgrp][1];
			else
				idiff = (g_iStartVelsNew[client][zgrp][1] - g_iStartVelsRecord[client][zgrp][1]);
			
			
			if (g_iStartVelsNew[client][zgrp][1] > g_iStartVelsRecord[client][zgrp][1] || g_iStartVelsRecord[client][zgrp][1] == 0)
			{
				Format(szDiff2, sizeof(szDiff2), "+%d", idiff);
			}
			else
			{
				Format(szDiff2, sizeof(szDiff2), "%d", idiff);
			}
				
			// Print Speed if velocity setting
			if (g_bShowSpeedDifferenceHud[client])
				g_fLastDifferenceSpeed[client] = GetGameTime();

			CPrintToChat(client, "%s {default}Speed: {yellow}%d u/s {default}[WR: %s {default}| PB: %s{default}]", g_szChatPrefix, g_iStartVelsNew[client][zgrp][1], szDiff ,szDiff2);
		}
	}

	// Play Start Sound if not in practicemode
	if (!g_bPracticeMode[client])
	{
		PlayButtonSound(client);
	}

	// Start recording for record bot
	if (((!IsFakeClient(client) && GetConVarBool(g_hReplayBot)) || (!IsFakeClient(client) && GetConVarBool(g_hBonusBot))) && !g_hRecording[client])
	{
		if (!IsPlayerAlive(client) || GetClientTeam(client) == 1)
		{
			if (g_hRecording[client] != null)
				StopRecording(client);
		}
		else
		{
			if (g_hRecording[client] != null)
				StopRecording(client);
			StartRecording(client);
			if (g_bhasStages)
				Stage_StartRecording(client);
		}
	}
}

// End Timer
public void CL_OnEndTimerPress(int client)
{
	if (!IsValidClient(client) || g_bSavingMapTime[client])
		return;

	int zGroup = g_iClientInZone[client][2];

	g_fFinalTime[client] = GetGameTime() - g_fStartTime[client] - g_fPauseTime[client];
	float fVelocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);
	
	g_iEndVelsNew[client][zGroup][0] = RoundToNearest(SquareRoot(Pow(fVelocity[0], 2.0) + Pow(fVelocity[1], 2.0))); // XY
	g_iEndVelsNew[client][zGroup][1] = RoundToNearest(SquareRoot(Pow(fVelocity[0], 2.0) + Pow(fVelocity[1], 2.0) + Pow(fVelocity[2], 2.0))); // XYZ
	g_iEndVelsNew[client][zGroup][2] = RoundToNearest(fVelocity[2]); // Z

	int idiff;
	if (g_iEndVelsServerRecord[zGroup][1] == 0)
		idiff = g_iEndVelsNew[client][zGroup][1];
	else
		idiff = (g_iEndVelsNew[client][zGroup][1] - g_iEndVelsServerRecord[zGroup][1]);

	char szDiff[54], szDiff2[54];
	if (g_iEndVelsNew[client][zGroup][1] > g_iEndVelsServerRecord[zGroup][1] || g_iEndVelsServerRecord[zGroup][1] == 0)
		Format(szDiff, sizeof(szDiff), "{lightgreen}+%d", idiff);
	else
		Format(szDiff, sizeof(szDiff), "{red}%d", idiff);

	if (g_iEndVelsRecord[client][zGroup][1] == 0)
		idiff = g_iEndVelsNew[client][zGroup][1];
	else
		idiff = (g_iEndVelsNew[client][zGroup][1] - g_iEndVelsRecord[client][zGroup][1]);
	
	if (g_iEndVelsNew[client][zGroup][1] > g_iEndVelsRecord[client][zGroup][1] || g_iEndVelsRecord[client][zGroup][1] == 0)
		Format(szDiff2, sizeof(szDiff2), "{lightgreen}+%d", idiff);
	else
		Format(szDiff2, sizeof(szDiff2), "{red}%d",idiff);
				
	// Print Speed if velocity setting

	CPrintToChat(client, "%s {default}Speed: {yellow}%d {default}[WR: %s {default}| PB: %s{default}]", g_szChatPrefix, g_iEndVelsNew[client][zGroup][1], szDiff ,szDiff2);

	// Print bot finishing message to spectators
	if (IsFakeClient(client) && g_bTimerRunning[client])
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsPlayerAlive(i))
			{
				int SpecMode = GetEntProp(i, Prop_Send, "m_iObserverMode");
				if (SpecMode == 4 || SpecMode == 5)
				{
					int Target = GetEntPropEnt(i, Prop_Send, "m_hObserverTarget");
					if (Target == client)
					{
						if (Target == g_RecordBot)
							CPrintToChat(i, "%t", "ReplayFinishingMsg", g_szChatPrefix, g_szReplayName, g_szReplayTime);
						if (Target == g_BonusBot)
							CPrintToChat(i, "%t", "ReplayFinishingMsgBonus", g_szChatPrefix, g_szBonusName, g_szZoneGroupName[g_iClientInZone[g_BonusBot][2]], g_szBonusTime);
					}
				}
			}
		}

		PlayButtonSound(client);

		g_bTimerRunning[client] = false;
		return;
	}

	// If timer is not on, play error sound and return
	if (!g_bTimerRunning[client])
	{
		ClientCommand(client, "play buttons\\button10.wav");
		return;
	}
	else
		PlayButtonSound(client);

	g_bSavingMapTime[client] = true;
	// Get client name
	char szName[MAX_NAME_LENGTH];
	GetClientName(client, szName, MAX_NAME_LENGTH);

	// Get runtime and format it to a string
	FormatTimeFloat(client, g_fFinalTime[client], 3, g_szFinalTime[client], 32);

	/*====================================
	=        Handle Practice Mode        =
	====================================*/

	if (g_bPracticeMode[client])
	{
		if (g_iClientInZone[client][2] > 0)
			CPrintToChat(client, "%t", "BPress4", g_szChatPrefix, szName, g_szFinalTime[client]);
		else
			CPrintToChat(client, "%t", "BPress5", g_szChatPrefix, szName, g_szFinalTime[client]);
		
		/* Start function call */
		Call_StartForward(g_PracticeFinishForward);

		/* Push parameters one at a time */
		Call_PushCell(client);
		Call_PushFloat(g_fFinalTime[client]);
		Call_PushString(g_szFinalTime[client]);

		/* Finish the call, get the result */
		Call_Finish();

		return;
	}

	int style = g_iCurrentStyle[client];

	/*====================================
	=         Handling Map Times         =
	====================================*/

	if (zGroup == 0)
	{
		if (style == 0)
		{
			// Make a new record bot?
			if (GetConVarBool(g_hReplaceReplayTime) && (g_fFinalTime[client] < g_fReplayTimes[0][0] || g_fReplayTimes[0][0] == 0.0))
			{
				if (GetConVarBool(g_hReplayBot) && !g_bPositionRestored[client])
				{
					g_fReplayTimes[0][0] = g_fFinalTime[client];
					g_bNewReplay[client] = true;
					CreateTimer(0.0, ReplayTimer, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
				}
			}

			// char szDiff[54];
			float diff;

			// Record bools init
			g_bStyleMapFirstRecord[0][client] = false;
			g_bStyleMapPBRecord[0][client] = false;
			g_bStyleMapSRVRecord[0][client] = false;

			g_OldStyleMapRank[0][client] = g_StyleMapRank[0][client];

			diff = g_fPersonalStyleRecord[0][client] - g_fFinalTime[client];
			FormatTimeFloat(client, diff, 3, szDiff, sizeof(szDiff));
			if (diff > 0.0)
				Format(g_szTimeDifference[client], sizeof(szDiff), "-%s", szDiff);
			else
				Format(g_szTimeDifference[client], sizeof(szDiff), "+%s", szDiff);

			// If the server already has a record
			if (g_StyleMapTimesCount[0] > 0)
			{
				if (g_fFinalTime[client] < g_fRecordStyleMapTime[0])
				{
					// New fastest time in map
					g_bStyleMapSRVRecord[0][client] = true;
					g_fOldRecordMapTime = g_fRecordStyleMapTime[0];
					g_fRecordStyleMapTime[0] = g_fFinalTime[client];
					Format(g_szRecordStylePlayer[0], MAX_NAME_LENGTH, "%s", szName);
					FormatTimeFloat(1, g_fRecordStyleMapTime[0], 3, g_szRecordStyleMapTime[0], 64);

					// Insert latest record
					db_InsertLatestRecords(g_szSteamID[client], szName, g_fFinalTime[client]);

					// Update Velocitys
					for (int i = 0; i < 3; i++)
					{
						g_iStartVelsServerRecord[zGroup][i] = g_iStartVelsNew[client][zGroup][i];
						g_iEndVelsServerRecord[zGroup][i] = g_iEndVelsNew[client][zGroup][i];
					}

					// Update Checkpoints
					if (!g_bPositionRestored[client])
					{
						for (int i = 0; i < CPLIMIT; i++)
						{
							g_fCheckpointServerRecord[zGroup][i] = g_fCheckpointTimesNew[zGroup][client][i];
							
							// Update Velocitys
							for (int j = 0; j < 3; j++)
							{
								g_iCheckpointVelsStartServerRecord[zGroup][i][j] = g_iCheckpointVelsStartNew[zGroup][client][i][j];
								g_iCheckpointVelsEndServerRecord[zGroup][i][j] = g_iCheckpointVelsEndNew[zGroup][client][i][j];
							}
						}
						g_bCheckpointRecordFound[zGroup] = true;
					}

					if (GetConVarBool(g_hReplayBot) && !g_bPositionRestored[client] && !g_bNewReplay[client])
					{
						g_bNewReplay[client] = true;
						g_fReplayTimes[0][0] = g_fFinalTime[client];
						CreateTimer(0.0, ReplayTimer, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
					}
					// wrCredits = 500;
				}
			}
			else
			{
				// Has to be the new record, since it is the first completion
				if (GetConVarBool(g_hReplayBot) && !g_bPositionRestored[client] && !g_bNewReplay[client])
				{
					g_fReplayTimes[0][0] = g_fFinalTime[client];
					g_bNewReplay[client] = true;
					CreateTimer(0.0, ReplayTimer, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
				}

				g_fOldRecordMapTime = g_fRecordStyleMapTime[0];
				g_bStyleMapSRVRecord[0][client] = true;
				g_fRecordStyleMapTime[0] = g_fFinalTime[client];
				Format(g_szRecordStylePlayer[0], MAX_NAME_LENGTH, "%s", szName);
				FormatTimeFloat(1, g_fRecordStyleMapTime[0], 3, g_szRecordStyleMapTime[0], 64);

				// Insert latest record
				db_InsertLatestRecords(g_szSteamID[client], szName, g_fFinalTime[client]);

				// Update Velocitys
				for (int i = 0; i < 3; i++)
				{
					g_iStartVelsServerRecord[zGroup][i] = g_iStartVelsNew[client][zGroup][i];
					g_iEndVelsServerRecord[zGroup][i] = g_iEndVelsNew[client][zGroup][i];
				}

				// Update Checkpoints
				if (!g_bPositionRestored[client])
				{
					for (int i = 0; i < CPLIMIT; i++)
					{
						g_fCheckpointServerRecord[zGroup][i] = g_fCheckpointTimesNew[zGroup][client][i];
						
						// Update Velocitys
						for (int j = 0; j < 3; j++)
						{
							g_iCheckpointVelsStartServerRecord[zGroup][i][j] = g_iCheckpointVelsStartNew[zGroup][client][i][j];
							g_iCheckpointVelsEndServerRecord[zGroup][i][j] = g_iCheckpointVelsEndNew[zGroup][client][i][j];
						}
					}
					g_bCheckpointRecordFound[zGroup] = true;
				}

				g_fOldRecordMapTime = g_fRecordStyleMapTime[0];
				// wrCredits = fcTierCredits;
			}


			// Clients first record
			if (g_fPersonalStyleRecord[0][client] == 0.0)
			{
				g_fPersonalStyleRecord[0][client] = g_fFinalTime[client];
				g_pr_finishedmaps[client][0]++;
				g_StyleMapTimesCount[0]++;
				FormatTimeFloat(1, g_fPersonalStyleRecord[0][client], 3, g_szPersonalStyleRecord[0][client], 64);

				g_bStyleMapFirstRecord[0][client] = true;
				g_pr_showmsg[client] = true;
				db_UpdateCheckpoints(client, g_szSteamID[client], zGroup);

				db_selectRecord(client);

				// fcCredits = fcTierCredits;
			}
			else if (diff > 0.0)
			{
				// Client's new record
				g_fPersonalStyleRecord[0][client] = g_fFinalTime[client];
				FormatTimeFloat(1, g_fPersonalStyleRecord[0][client], 3, g_szPersonalStyleRecord[0][client], 64);

				g_bStyleMapPBRecord[0][client] = true;
				g_pr_showmsg[client] = true;
				db_UpdateCheckpoints(client, g_szSteamID[client], zGroup);

				db_selectRecord(client);

				// pbCredits = tierCredits;
			}
			if (!g_bStyleMapSRVRecord[0][client] && !g_bStyleMapFirstRecord[0][client] && !g_bStyleMapPBRecord[0][client])
			{
				// for ck_min_rank_announce
				db_currentRunRank(client);
				// slowCredits = 1 * g_iMapTier;
			}
		}
		else if (style != 0)
		{
			// Make a new record bot?
			if (GetConVarBool(g_hReplaceReplayTime) && (g_fFinalTime[client] < g_fReplayTimes[0][style] || g_fReplayTimes[0][style] == 0.0))
			{
				if (GetConVarBool(g_hReplayBot) && !g_bPositionRestored[client])
				{
					g_fReplayTimes[0][style] = g_fFinalTime[client];
					g_bNewReplay[client] = true;
					Handle pack;
					CreateDataTimer(3.0, StyleReplayTimer, pack, TIMER_FLAG_NO_MAPCHANGE);
					WritePackCell(pack, GetClientUserId(client));
					WritePackCell(pack, style);
				}
			}

			// Styles
			// char szDiff[54];
			float diff;

			// Record bools init
			g_bStyleMapFirstRecord[style][client] = false;
			g_bStyleMapPBRecord[style][client] = false;
			g_bStyleMapSRVRecord[style][client] = false;

			g_OldStyleMapRank[style][client] = g_StyleMapRank[style][client];
			g_fOldRecordStyleMapTime[style] = g_fRecordStyleMapTime[style];

			diff = g_fPersonalStyleRecord[style][client] - g_fFinalTime[client];
			FormatTimeFloat(client, diff, 3, szDiff, sizeof(szDiff));
			if (diff > 0.0)
				Format(g_szTimeDifference[client], sizeof(szDiff), "-%s", szDiff);
			else
				Format(g_szTimeDifference[client], sizeof(szDiff), "+%s", szDiff);

			// If the server already has a record
			if (g_StyleMapTimesCount[style] > 0)
			{
				if (g_fFinalTime[client] < g_fRecordStyleMapTime[style])
				{
					// New fastest time in map
					g_bStyleMapSRVRecord[style][client] = true;
					g_fRecordStyleMapTime[style] = g_fFinalTime[client];
					Format(g_szRecordStylePlayer[style], MAX_NAME_LENGTH, "%s", szName);
					FormatTimeFloat(1, g_fRecordStyleMapTime[style], 3, g_szRecordStyleMapTime[style], 64);

					if (GetConVarBool(g_hReplayBot) && !g_bPositionRestored[client] && !g_bNewReplay[client])
					{
						g_bNewReplay[client] = true;
						g_fReplayTimes[0][style] = g_fFinalTime[client];
						Handle pack;
						CreateDataTimer(3.0, StyleReplayTimer, pack, TIMER_FLAG_NO_MAPCHANGE);
						WritePackCell(pack, GetClientUserId(client));
						WritePackCell(pack, style);
					}
					
					// Insert latest record
					// db_InsertLatestRecords(g_szSteamID[client], szName, g_fFinalTime[client]);
				}
			}
			else
			{
				if (GetConVarBool(g_hReplayBot) && !g_bPositionRestored[client] && !g_bNewReplay[client])
				{
					g_bNewReplay[client] = true;
					g_fReplayTimes[0][style] = g_fFinalTime[client];
					Handle pack;
					CreateDataTimer(3.0, StyleReplayTimer, pack, TIMER_FLAG_NO_MAPCHANGE);
					WritePackCell(pack, GetClientUserId(client));
					WritePackCell(pack, style);
				}

				// Has to be the new record, since it is the first completion
				g_bStyleMapSRVRecord[style][client] = true;
				g_fRecordStyleMapTime[style] = g_fFinalTime[client];
				Format(g_szRecordStylePlayer[style], MAX_NAME_LENGTH, "%s", szName);
				FormatTimeFloat(1, g_fRecordStyleMapTime[style], 3, g_szRecordStyleMapTime[style], 64);

				// Insert latest record
				// db_InsertLatestRecords(g_szSteamID[client], szName, g_fFinalTime[client]);

				g_fOldRecordStyleMapTime[style] = g_fRecordStyleMapTime[style];
			}


			// Check for personal record
			if (g_fPersonalStyleRecord[style][client] == 0.0)
			{
				// Clients first record
				g_fPersonalStyleRecord[style][client] = g_fFinalTime[client];
				/*g_pr_finishedmaps[client]++;
				g_StyleMapTimesCount[0]++;*/
				FormatTimeFloat(1, g_fPersonalStyleRecord[style][client], 3, g_szPersonalStyleRecord[style][client], 64);
				
				g_bStyleMapFirstRecord[style][client] = true;
				g_pr_showmsg[client] = true;
				
				db_selectStyleRecord(client, style);
			}
			else if (diff > 0.0)
			{
				// Client's new record
				g_fPersonalStyleRecord[style][client] = g_fFinalTime[client];
				FormatTimeFloat(1, g_fPersonalStyleRecord[style][client], 3, g_szPersonalStyleRecord[style][client], 64);

				g_bStyleMapPBRecord[style][client] = true;
				g_pr_showmsg[client] = true;

				db_selectStyleRecord(client, style);
			}

			if (!g_bStyleMapSRVRecord[style][client] && !g_bStyleMapFirstRecord[style][client] && !g_bStyleMapPBRecord[style][client]) // Player did not beat Server Record nor finish for 1st time nor beat Personal Record using style
			{
				float RecordDiff;
				char szRecordDiff[32];
				int count = g_StyleMapTimesCount[style];

				// Map style SR, time difference formatting
				RecordDiff = g_fRecordStyleMapTime[style] - g_fFinalTime[client];
				FormatTimeFloat(client, RecordDiff, 3, szRecordDiff, 32);
				if (RecordDiff > 0.0)
				{
				Format(szRecordDiff, 32, "-%s", szRecordDiff);
				}
				else
				{
				Format(szRecordDiff, 32, "+%s", szRecordDiff);
				}

				for (int i = 1; i <= MaxClients; i++)
				{
					if (IsValidClient(i) && !IsFakeClient(i))
					{
						CPrintToChat(i, "%t", "StyleMapFinished5", g_szChatPrefix, szName, g_szStyleRecordPrint[style], g_szFinalTime[client], szRecordDiff, g_szTimeDifference[client], g_StyleMapRank[style][client], count);
						PrintToConsole(client, "Surftimer | %s finished %s in %s [SR %s | PB %s | Rank #%i/%i]", szName, g_szStyleRecordPrint[style], g_szFinalTime[client], szRecordDiff, g_szTimeDifference[client], g_StyleMapRank[style][client], count);
					}
				}
			} 
			
			CS_SetClientAssists(client, 100);
		}
	}
	else
	{
		/*====================================
		=            Handle Bonus            =
		====================================*/
		if (style == 0)
		{
			if (GetConVarBool(g_hReplaceReplayTime) && (g_fFinalTime[client] < g_fReplayTimes[zGroup][0] || g_fReplayTimes[zGroup][0] == 0.0))
			{
				if (GetConVarBool(g_hBonusBot) && !g_bPositionRestored[client])
				{
					g_fReplayTimes[zGroup][0] = g_fFinalTime[client];
					g_bNewBonus[client] = true;
					Handle pack;
					CreateDataTimer(3.0, BonusReplayTimer, pack, TIMER_FLAG_NO_MAPCHANGE);
					WritePackCell(pack, GetClientUserId(client));
					WritePackCell(pack, zGroup);
				}
			}

			float diff;

			// Record bools init
			g_bBonusFirstRecord[client] = false;
			g_bBonusPBRecord[client] = false;
			g_bBonusSRVRecord[client] = false;

			g_StyleOldMapRankBonus[0][zGroup][client] = g_StyleMapRankBonus[0][zGroup][client];

			diff = g_fStylePersonalRecordBonus[0][zGroup][client] - g_fFinalTime[client];
			FormatTimeFloat(client, diff, 3, szDiff, sizeof(szDiff));

			if (diff > 0.0)
				Format(g_szBonusTimeDifference[client], sizeof(szDiff), "-%s", szDiff);
			else
				Format(g_szBonusTimeDifference[client], sizeof(szDiff), "+%s", szDiff);


			g_StyletmpBonusCount[0][zGroup] = g_iStyleBonusCount[0][zGroup];

			// If the server already has a record
			if (g_iStyleBonusCount[0][zGroup] > 0)
			{
				// New fastest time in current bonus
				if (g_fFinalTime[client] < g_fStyleBonusFastest[0][zGroup])
				{
					g_fStyleOldBonusRecordTime[0][zGroup] = g_fStyleBonusFastest[0][zGroup];
					g_fStyleBonusFastest[0][zGroup] = g_fFinalTime[client];
					Format(g_szStyleBonusFastest[0][zGroup], 128, "%s", szName);
					FormatTimeFloat(1, g_fStyleBonusFastest[0][zGroup], 3, g_szStyleBonusFastestTime[0][zGroup], 128);

					// Update Checkpoints
					if (g_bCheckpointsEnabled[client] && !g_bPositionRestored[client])
					{
						for (int i = 0; i < CPLIMIT; i++)
						{
							g_fCheckpointServerRecord[zGroup][i] = g_fCheckpointTimesNew[zGroup][client][i];
						}
						g_bCheckpointRecordFound[zGroup] = true;
					}

					g_bBonusSRVRecord[client] = true;
					if (GetConVarBool(g_hBonusBot) && !g_bPositionRestored[client] && !g_bNewBonus[client])
					{
						g_bNewBonus[client] = true;
						g_fReplayTimes[zGroup][0] = g_fFinalTime[client];
						Handle pack;
						CreateDataTimer(3.0, BonusReplayTimer, pack, TIMER_FLAG_NO_MAPCHANGE);
						WritePackCell(pack, GetClientUserId(client));
						WritePackCell(pack, zGroup);
					}
				}
			}
			else
			{
				// Has to be the new record, since it is the first completion
				if (GetConVarBool(g_hBonusBot) && !g_bPositionRestored[client] && !g_bNewBonus[client])
				{
					g_bNewBonus[client] = true;
					g_fReplayTimes[zGroup][0] = g_fFinalTime[client];
					Handle pack;
					CreateDataTimer(3.0, BonusReplayTimer, pack, TIMER_FLAG_NO_MAPCHANGE);
					WritePackCell(pack, GetClientUserId(client));
					WritePackCell(pack, zGroup);
				}

				g_fStyleOldBonusRecordTime[0][zGroup] = g_fStyleBonusFastest[0][zGroup];
				g_fStyleBonusFastest[0][zGroup] = g_fFinalTime[client];
				Format(g_szStyleBonusFastest[0][zGroup], 128, "%s", szName);
				FormatTimeFloat(1, g_fStyleBonusFastest[0][zGroup], 3, g_szStyleBonusFastestTime[0][zGroup], 128);

				// Update Checkpoints
				if (g_bCheckpointsEnabled[client] && !g_bPositionRestored[client])
				{
					for (int i = 0; i < CPLIMIT; i++)
						g_fCheckpointServerRecord[zGroup][i] = g_fCheckpointTimesNew[zGroup][client][i];
					g_bCheckpointRecordFound[zGroup] = true;
				}

				g_bBonusSRVRecord[client] = true;

				g_fStyleOldBonusRecordTime[0][zGroup] = g_fStyleBonusFastest[0][zGroup];
			}

			// Clients first record
			if (g_fStylePersonalRecordBonus[0][zGroup][client] == 0.0)
			{
				g_fStylePersonalRecordBonus[0][zGroup][client] = g_fFinalTime[client];
				FormatTimeFloat(1, g_fStylePersonalRecordBonus[0][zGroup][client], 3, g_szStylePersonalRecordBonus[0][zGroup][client], 128);

				g_bBonusFirstRecord[client] = true;
				g_pr_showmsg[client] = true;
				db_UpdateCheckpoints(client, g_szSteamID[client], zGroup);
				db_insertBonus(client, g_szSteamID[client], szName, g_fFinalTime[client], zGroup);
			}

			else if (diff > 0.0)
			{
				// client's new record
				g_fStylePersonalRecordBonus[0][zGroup][client] = g_fFinalTime[client];
				FormatTimeFloat(1, g_fStylePersonalRecordBonus[0][zGroup][client], 3, g_szStylePersonalRecordBonus[0][zGroup][client], 128);

				g_bBonusPBRecord[client] = true;
				g_pr_showmsg[client] = true;
				db_UpdateCheckpoints(client, g_szSteamID[client], zGroup);
				db_updateBonus(client, g_szSteamID[client], szName, g_fFinalTime[client], zGroup);
			}


			if (!g_bBonusSRVRecord[client] && !g_bBonusFirstRecord[client] && !g_bBonusPBRecord[client])
			{
				db_currentBonusRunRank(client, zGroup);
			}
		}
		else if (style != 0)
		{
			if (GetConVarBool(g_hReplaceReplayTime) && (g_fFinalTime[client] < g_fReplayTimes[zGroup][style] || g_fReplayTimes[zGroup][style] == 0.0))
			{
				if (GetConVarBool(g_hBonusBot) && !g_bPositionRestored[client])
				{
					g_fReplayTimes[zGroup][style] = g_fFinalTime[client];
					g_bNewBonus[client] = true;
					Handle pack;
					CreateDataTimer(3.0, StyleBonusReplayTimer, pack, TIMER_FLAG_NO_MAPCHANGE);
					WritePackCell(pack, GetClientUserId(client));
					WritePackCell(pack, zGroup);
					WritePackCell(pack, style);
				}
			}

			// styles for bonus
			float diff;

			// Record bools init
			g_bBonusFirstRecord[client] = false;
			g_bBonusPBRecord[client] = false;
			g_bBonusSRVRecord[client] = false;

			g_StyleOldMapRankBonus[style][zGroup][client] = g_StyleMapRankBonus[style][zGroup][client];

			diff = g_fStylePersonalRecordBonus[style][zGroup][client] - g_fFinalTime[client];
			FormatTimeFloat(client, diff, 3, szDiff, sizeof(szDiff));

			if (diff > 0.0)
				Format(g_szBonusTimeDifference[client], sizeof(szDiff), "-%s", szDiff);
			else
				Format(g_szBonusTimeDifference[client], sizeof(szDiff), "+%s", szDiff);


			g_StyletmpBonusCount[style][zGroup] = g_iStyleBonusCount[style][zGroup];
			
			// If the server already has a record
			if (g_iStyleBonusCount[style][zGroup] > 0)
			{
				if (g_fFinalTime[client] < g_fStyleBonusFastest[style][zGroup])
				{
					// New fastest time in current bonus
					g_fStyleOldBonusRecordTime[style][zGroup] = g_fStyleBonusFastest[style][zGroup];
					g_fStyleBonusFastest[style][zGroup] = g_fFinalTime[client];
					Format(g_szStyleBonusFastest[style][zGroup], 128, "%s", szName); // fluffys come back stopped here
					FormatTimeFloat(1, g_fStyleBonusFastest[style][zGroup], 3, g_szStyleBonusFastestTime[style][zGroup], 128);

					g_bBonusSRVRecord[client] = true;
					if (GetConVarBool(g_hBonusBot) && !g_bPositionRestored[client] && !g_bNewBonus[client])
					{
						g_bNewBonus[client] = true;
						g_fReplayTimes[zGroup][style] = g_fFinalTime[client];
						Handle pack;
						CreateDataTimer(3.0, StyleBonusReplayTimer, pack, TIMER_FLAG_NO_MAPCHANGE);
						WritePackCell(pack, GetClientUserId(client));
						WritePackCell(pack, zGroup);
						WritePackCell(pack, style);
					}
				}
			}
			else
			{
				if (GetConVarBool(g_hBonusBot) && !g_bPositionRestored[client] && !g_bNewBonus[client])
				{
					g_bNewBonus[client] = true;
					g_fReplayTimes[zGroup][style] = g_fFinalTime[client];
					Handle pack;
					CreateDataTimer(3.0, StyleBonusReplayTimer, pack, TIMER_FLAG_NO_MAPCHANGE);
					WritePackCell(pack, GetClientUserId(client));
					WritePackCell(pack, zGroup);
					WritePackCell(pack, style);
				}

				// Has to be the new record, since it is the first completion
				g_fStyleOldBonusRecordTime[style][zGroup] = g_fStyleBonusFastest[style][zGroup];
				g_fStyleBonusFastest[style][zGroup] = g_fFinalTime[client];
				Format(g_szStyleBonusFastest[style][zGroup], 128, "%s", szName);
				FormatTimeFloat(1, g_fStyleBonusFastest[style][zGroup], 3, g_szStyleBonusFastestTime[style][zGroup], 128);

				g_bBonusSRVRecord[client] = true;

				g_fStyleOldBonusRecordTime[style][zGroup] = g_fStyleBonusFastest[style][zGroup];
			}

			// Clients first record
			if (g_fStylePersonalRecordBonus[style][zGroup][client] == 0.0)
			{
				g_fStylePersonalRecordBonus[style][zGroup][client] = g_fFinalTime[client];
				FormatTimeFloat(1, g_fStylePersonalRecordBonus[style][zGroup][client], 3, g_szStylePersonalRecordBonus[style][zGroup][client], 128);

				g_bBonusFirstRecord[client] = true;
				g_pr_showmsg[client] = true;
				db_insertBonusStyle(client, g_szSteamID[client], szName, g_fFinalTime[client], zGroup, style);
			}
			else if (diff > 0.0)
			{
				// client's new record
				g_fStylePersonalRecordBonus[style][zGroup][client] = g_fFinalTime[client];
				FormatTimeFloat(1, g_fStylePersonalRecordBonus[style][zGroup][client], 3, g_szStylePersonalRecordBonus[style][zGroup][client], 128);

				g_bBonusPBRecord[client] = true;
				g_pr_showmsg[client] = true;
				db_updateBonusStyle(client, g_szSteamID[client], szName, g_fFinalTime[client], zGroup, style);
			}


			if (!g_bBonusSRVRecord[client] && !g_bBonusFirstRecord[client] && !g_bBonusPBRecord[client])
			{
				db_currentBonusStyleRunRank(client, zGroup, style);
			}
		}
	}

	Client_Stop(client, 1);
	db_deleteTmp(client);
}

// Start Timer
public void CL_OnStartWrcpTimerPress(int client)
{
	float fVelocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);

	if (!g_bSpectate[client] && !g_bNoClip[client] && ((GetGameTime() - g_fLastTimeNoClipUsed[client]) > 2.0))
	{
		int zGroup = g_iClientInZone[client][2];
		if (zGroup == 0)
		{
			g_fStartWrcpTime[client] = GetGameTime();
			// g_fStartWrcpTime[client] = 0.0;
			g_fCurrentWrcpRunTime[client] = 0.0;
			g_bWrcpTimeractivated[client] = true;
			g_bNotTeleporting[client] = true;
			g_WrcpStage[client] = g_Stage[0][client];
			int stage = g_WrcpStage[client];
			// Stage_StartRecording(client);

			g_iWrcpVelsStartNew[client][stage][0] = RoundToNearest(SquareRoot(Pow(fVelocity[0], 2.0) + Pow(fVelocity[1], 2.0))); // XY
			g_iWrcpVelsStartNew[client][stage][1] = RoundToNearest(SquareRoot(Pow(fVelocity[0], 2.0) + Pow(fVelocity[1], 2.0) + Pow(fVelocity[2], 2.0))); // XYZ
			g_iWrcpVelsStartNew[client][stage][2] = RoundToNearest(fVelocity[2]); // Z

			int idiff;
			if (g_iWrcpVelsStartServerRecord[stage][1] == 0)
				idiff = g_iWrcpVelsStartNew[client][stage][1];
			else
				idiff = (g_iWrcpVelsStartNew[client][stage][1] - g_iWrcpVelsStartServerRecord[stage][1]);

			char szDiff[32], szDiff2[32];
			if (g_iWrcpVelsStartNew[client][stage][1] > g_iWrcpVelsStartServerRecord[stage][1] || g_iWrcpVelsStartServerRecord[stage][1] == 0)
			{
				if (!g_bTimerRunning[client])
					Format(g_szLastSpeedDifference[client], 128, "(WR +%d)", idiff);
				Format(szDiff, sizeof(szDiff), "+%d", idiff);
			}
			else
			{
				if (!g_bTimerRunning[client])
					Format(g_szLastSpeedDifference[client], 128, "(WR %d)", idiff);
				Format(szDiff, sizeof(szDiff), "%d", idiff);
			}

			if (g_iWrcpVelsStartRecord[client][stage][1] == 0)
				idiff = g_iWrcpVelsStartNew[client][stage][1];
			else
				idiff = (g_iWrcpVelsStartNew[client][stage][1] - g_iWrcpVelsStartRecord[client][stage][1]);
			
			
			if (g_iWrcpVelsStartNew[client][stage][1] > g_iWrcpVelsStartRecord[client][stage][1] || g_iWrcpVelsStartRecord[client][stage][1] == 0)
			{
				Format(szDiff2, sizeof(szDiff2), "+%d", idiff);
			}
			else
			{
				Format(szDiff2, sizeof(szDiff2), "%d", idiff);
			}
				
			// Print Speed if velocity setting
			if (!g_bTimerRunning[client])
			{
				if (g_bShowSpeedDifferenceHud[client])
					g_fLastDifferenceSpeed[client] = GetGameTime();
				
				CPrintToChat(client, "%s {default}Stage %d: {yellow}%d u/s {default}[WR: %s {default}| PB: %s{default}]", g_szChatPrefix, stage, g_iWrcpVelsStartNew[client][stage][1], szDiff ,szDiff2);
			}
		}
	}
}

// End Timer
public void CL_OnEndWrcpTimerPress(int client, float time2)
{
	if (!IsValidClient(client))
		return;

	// Print bot finishing message to spectators
	if (IsFakeClient(client))
	{
		g_bWrcpTimeractivated[client] = false;
		return;
	}

	int stage = g_WrcpStage[client];
	// Get Client Name
	char szName[MAX_NAME_LENGTH];
	GetClientName(client, szName, MAX_NAME_LENGTH);

	if (g_bWrcpEndZone[client])
	{
		stage += 1;
		g_bWrcpEndZone[client] = false;
	}

	if (stage > g_TotalStages) // Hack Fix for multiple end zone issue
		stage = g_TotalStages;
	else if (stage < 1)
		stage = 1;

	if (g_bWrcpTimeractivated[client] && g_iCurrentStyle[client] == 0)
	{
		// int stage = g_CurrentStage[client];

		// g_fFinalWrcpTime[client] = GetGameTime() - g_fStartWrcpTime[client];
		g_fFinalWrcpTime[client] = g_fCurrentWrcpRunTime[client];

		// g_fFinalWrcpTime[client] = g_fStartWrcpTime[client] - time2;
		if (g_fFinalWrcpTime[client] <= 0.0)
		{
			CPrintToChat(client, "%t", "ErrorStageTime", g_szChatPrefix, stage);
			return;
		}

		if (stage == 2 && g_wrcpStage2Fix[client])
		{
			CPrintToChat(client, "%t", "StageNotRecorded", g_szChatPrefix);
			g_wrcpStage2Fix[client] = false;
			return;
		}

		g_wrcpStage2Fix[client] = false;

		char sz_srDiff[128];
		float time = g_fFinalWrcpTime[client];
		float f_srDiff = (g_fStyleStageRecord[0][stage] - time);
		FormatTimeFloat(client, f_srDiff, 3, sz_srDiff, 128);
		if (f_srDiff > 0)
		{
			// Format(sz_srDiff_colorless, 128, "-%s", sz_srDiff);
			Format(sz_srDiff, 128, "%cWR: %c-%s%c", WHITE, LIGHTGREEN, sz_srDiff, WHITE);
		}
		else
		{
			// Format(sz_srDiff_colorless, 128, "+%s", sz_srDiff);
			Format(sz_srDiff, 128, "%cWR: %c+%s%c", WHITE, RED, sz_srDiff, WHITE);
		}
		// g_fLastDifferenceTime[client] = GetGameTime();
		/*else
		Format(sz_srDiff, 128, "");*/

		FormatTimeFloat(client, g_fFinalWrcpTime[client], 3, g_szFinalWrcpTime[client], 32);
		// Make a new stage replay bot?
		if (GetConVarBool(g_hReplaceReplayTime) && (!g_bStageReplay[stage] || g_fFinalWrcpTime[client] < g_fStageReplayTimes[stage]))
		{
			Stage_SaveRecording(client, stage, g_szFinalWrcpTime[client]);
		}
		else
		{
			if (g_TotalStageStyleRecords[0][stage] > 0)
			{ // If the server already has a record
				if (g_fFinalWrcpTime[client] < g_fStyleStageRecord[0][stage] && g_fFinalWrcpTime[client] > 0.0)
				{
					Stage_SaveRecording(client, stage, g_szFinalWrcpTime[client]);
				}
			}
			else
			{
				Stage_SaveRecording(client, stage, g_szFinalWrcpTime[client]);
			}
		}

		db_selectWrcpRecord(client, 0, stage);
		g_bWrcpTimeractivated[client] = false;
	}
	else if (g_bWrcpTimeractivated[client] && g_iCurrentStyle[client] != 0) // styles
	{
		int style = g_iCurrentStyle[client];
		g_fFinalWrcpTime[client] = GetGameTime() - g_fStartWrcpTime[client];
		if (g_fFinalWrcpTime[client] <= 0.0)
		{
			CPrintToChat(client, "%t", "ErrorStageTime", g_szChatPrefix, stage);
			return;
		}

		char sz_srDiff[128];
		float time = g_fFinalWrcpTime[client];
		float f_srDiff = (g_fStyleStageRecord[style][stage] - time);
		FormatTimeFloat(client, f_srDiff, 3, sz_srDiff, 128);
		if (f_srDiff > 0)
		{
			// Format(sz_srDiff_colorless, 128, "-%s", sz_srDiff);
			Format(sz_srDiff, 128, "%cWR: %c-%s%c", WHITE, LIGHTGREEN, sz_srDiff, WHITE);
		}
		else
		{
			// Format(sz_srDiff_colorless, 128, "+%s", sz_srDiff);
			Format(sz_srDiff, 128, "%cWR: %c+%s%c", WHITE, RED, sz_srDiff, WHITE);
		}
		// g_fLastDifferenceTime[client] = GetGameTime();
		/*else
		Format(sz_srDiff, 128, "");*/

		FormatTimeFloat(client, g_fFinalWrcpTime[client], 3, g_szFinalWrcpTime[client], 32);
		db_selectWrcpRecord(client, style, stage);
		g_bWrcpTimeractivated[client] = false;
	}
	else if (!g_bWrcpTimeractivated[client])
	{
		g_StageRecStartFrame[client] = -1;
	}

	Client_StopWrcp(client, 1);
}