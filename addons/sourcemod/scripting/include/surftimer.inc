#if defined _surftimer_included
 #endinput
#endif
#define _surftimer_included

/*  Natives  */

/**
 * Checks if a client's timer is active.
 *
 * @param client		The client's ID.
 * @return					true if the client's timer is active. False otherwise.
 */
native bool surftimer_GetTimerStatus(int client);

/**
 * Stops a client's timer.
 *
 * @param client		The client's ID.
 */
native void surftimer_StopTimer(int client);

/**
 * Starts a client's timer.
 *
 * @param client		The client's ID.
 */
native void surftimer_EmulateStartButtonPress(int client);

/**
 * Finishes a client's run.
 *
 * @param client		The client's ID.
 */
native void surftimer_EmulateStopButtonPress(int client);

/**
 * Retrives a client's current runtime.
 *
 * @param client			The client's ID.
 * @return						The current runtime of the client.
 */
native float surftimer_GetCurrentTime(int client);

/**
 * Checks if a client has the VIP status.
 *
 * @param client			The client's ID.
 * @return						true if the client's has the VIP status. False otherwise.
 */
native bool surftimer_IsClientVip(int client);

/**
 * Retrieves the rank of a client.
 *
 * @param client			The client's ID.
 * @return						The rank of the client. -1 on failure.
 */
native int surftimer_GetPlayerRank(int client);

/**
 * Retrieves a client's rank.
 *
 * @param client			The client's ID.
 * @return						The points of the client. -1 on failure.
 */
native int surftimer_GetPlayerPoints(int client);

/**
 * Retrieves the skillgroup of a client
 *
 * @param client			The client's ID.
 * @param str					The string to convert.
 * @return						Skillgroup as a string. Unranked on failure.
 */
native void surftimer_GetPlayerSkillgroup(int client, char[] str);

/**
 * Retrieves the current map tier.
 *
 * @return						Current map tier.
 */
native int surftimer_GetMapTier();

/**
 * Retrieves the number of stages on the current map.
 *
 * @return						Number of stages on the current map. 0 if the map is linear.
 */
native int surftimer_GetMapStages();

/**
 * Retrieves a client's name with colors.
 *
 * @param client			The client's ID.
 * @param str					The string to convert.
 * @return						The client's name with colors. Invalid on failure.
 */
native void surftimer_GetPlayerNameColored(int client, char[] str);

/**
 * Retrieves the current map's WR holder and the associated time.
 *
 * @param szname				String to store the WR holder's name.
 * @param sztime				String to store the WR holder's time.
 * @param time					float to store the WR holder's time.
 * @return						The number of players who have finished the current map.
 */
native int surftimer_GetMapData(char[] szname, char[] sztime, float& time);

/**
 * Retrieves the wr/pb info regarding the current bonus a players is on
 *
 * @param client				The client's ID.
 * @param szWRname				String to store the Bonus WR holder's name.
 * @param WRtime				float to store the Bonus WR holder's time.
 * @param pbtime				float to store the Bonus PB holder's time.
 * @return						The number of players who have finished the current bonus.
 */
native int surftimer_GetBonusData(int client, char[] szWRname, float& WRtime, float& PBtime);

/**
 * Retrieves the current map's stage WR holder and the associated times.
 *
 * @param client				The client's ID.
 * @param szWRname				String to store the stage WR holder's name.
 * @param WRtime				float to store the stage WR holder's time.
 * @param pbtime				float to store the stage PB holder's time.
 * @return						The number of players who have finished the current stage.
 */
native int surftimer_GetStageData(int client, char[] szWRname, float& WRtime, float& PBtime);

/**
 * Retrieves the client's data.
 *
 * @param client			The client's ID.
 * @param time				String to store the client's map time.
 * @param rank				int to store the client's map rank.
 * @param country			String to store the client's country.
 * @param countryCode			String to store the client's countryCode.
 * @param continentCode			String to store the client's continentCode.
 */
native void surftimer_GetPlayerData(int& client, float& time, int& rank, char[] country, char countryCode[3], char continentCode[3]);

/**
 * Retrieves the client's current info.
 *
 * @param client			The client's ID.
 * @param iWrcpTimer		Int to store the client's WRCP timer.
 * @param iPracMode			Int to store the client's Practice mode.
 * @param iStage			Int to store the client's current stage.
 * @param iBonus			Int to store the client's current bonus.
 */
native void surftimer_GetPlayerInfo(int& client, int& iWrcpTimer, int& iPracMode, int& iStage, int& iBonus);

/**
 * Retrieves the client's current sync.
 *
 * @param client			The client's ID.
 * @return					Client's sync.
 */
native float surftimer_GetClientSync(int client);

/**
 * Retrieves the client's current style.
 *
 * @param client			The client's ID.
 * @return					Current client's style.
 */
native int surftimer_GetClientStyle(int client);

/**
 * Teleport a client safely, without triggering end touches
 * and sets the client's location correctly.
 *
 * @param client					The client's ID.
 * @param fDestination		The teleport location.
 * @param fAngle					The teleport angle.
 * @param fVelocity				The teleport velocity.
 * @param bStopTimer			Whether or not to stop the client's timer. Defaults to false.
 * @return								true on success, false otherwise.
 */
native bool surftimer_SafeTeleport(int client, float fDestination[3], float fAngle[3], float fVelocity[3], bool bStopTimer = false);

/*  FORWARDS  */

/**
 * Called when a client finishes a map.
 *
 * @param client			The client's ID.
 * @return						Plugin_Handled, to stop the client from searching.
 */
forward Action surftimer_OnMapFinished(int client, float fRunTime, char sRunTime[54], float PBDiff, float WRDiff, int rank, int total, int style, ArrayList cps);

/**
 * Called when a player reaches a checkpoint zone or a stage.
 *
 * @param client			The client's ID.
 * @param fRunTime			Run time of the client to the checkpoint in float
 * @param sRunTime			Run time of the client to the checkpoint
 * @param fPbCp				Personal best of the client to the checkpoint in float
 * @param sPbDiff			Personal best difference of the client with current run time
 * @param fSrCp				Record checkpoint time in float
 * @param sSrDiff			Record checkpoint time difference of the client with current run time
 * @param iCheckpoint		Checkpoint number that was just passed
 * @return					Plugin_Handled, to stop the client from searching.
 */
forward Action surftimer_OnCheckpoint(int client, float fRunTime, char sRunTime[54], float fPbCp, char sPbDiff[16], float fSrCp, char sSrDiff[16], int iCheckpoint);


/**
 * Called when a client finishes a bonus.
 *
 * @param client			The client's ID.
 * @return						Plugin_Handled, to stop the player from searching.
 */
forward Action surftimer_OnBonusFinished(int client, float fRunTime, char sRunTime[54], float fPBDiff, float fSRDiff, int rank, int total, int bonusid, int style);

/**
 * Called when a client finishes a map in practice mode
 *
 * @param client			The client's ID.
 * @return						Plugin_Handled, to stop the player from searching.
 */
forward Action surftimer_OnPracticeFinished(int client, float fRunTime, char sRunTime[54]);

/**
 * Called when a client sets a new record
 *
 * @param client			The client's ID.
 * @param style				Style index.
 * @param time				Time set by the player.
 * @param timeDif			Time difference with the former record.
 * @param bonusGroup	    Group of the bonus. -1 if the record isn't a bonus.
 * @param checkpoints       Array with checkpoint differences for the run.
 */
forward void surftimer_OnNewRecord(int client, int style, char[] time, char[] timeDif, int bonusGroup, ArrayList checkpoints);

/**
 * Called when a client sets a new WRCP
 *
 * @param client			The client's ID.
 * @param style				Style index.
 * @param time				Time set by the player.
 * @param timeDif			Time difference with the former record.
 * @param stage			  	The id of the stage of the WRCP.
 * @param fRunTime			Run time for the WRCP in float.
 */
forward void surftimer_OnNewWRCP(int client, int style, char[] time, char[] timeDif, int stage, float fRunTime);

/**
 * Called when a client sets a new WRCP
 *
 * @param client			The client's ID.
 * @param style				Style index.
 * @param time				Time set by the player.
 * @param timeDif			Time difference with the former record.
 * @param stage			  	The id of the stage of the WRCP.
 * @param fRunTime			Run time for the WRCP in float.
 * @param fClientRunTime	Run time for the client of the current stage in float.
 */
forward void surftimer_OnStageFinished(int client, int style, char[] time, char[] timeDif, int stage, float fRunTime, float fClientRunTime);

/**
 * Converts steamid2 (STEAM_X:Y:Z) to the accountid which will returned.
 */
stock int SteamId2ToAccountId(const char[] steamid)
{
    return (StringToInt(steamid[10]) * 2) + (steamid[8] == '1' ? 1 : 0);
}

public SharedPlugin:__pl_surftimer =
{
	name = "surftimer",
	file = "surftimer.smx",
	#if defined REQUIRE_PLUGIN
	required = 1,
	#else
	required = 0,
	#endif
};

public __pl_surftimer_SetNTVOptional()
{
	MarkNativeAsOptional("surftimer_GetTimerStatus");
	MarkNativeAsOptional("surftimer_StopTimer");
	MarkNativeAsOptional("surftimer_EmulateStartButtonPress");
	MarkNativeAsOptional("surftimer_EmulateStopButtonPress");
	MarkNativeAsOptional("surftimer_GetCurrentTime");
	MarkNativeAsOptional("surftimer_ClientIsVIP");
	MarkNativeAsOptional("surftimer_GetServerRank");
	MarkNativeAsOptional("surftimer_SafeTeleport");
	MarkNativeAsOptional("surftimer_OnNewRecord");
	MarkNativeAsOptional("surftimer_OnStageFinished");
}
