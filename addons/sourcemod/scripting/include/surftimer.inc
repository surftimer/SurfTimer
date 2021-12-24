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
 * @param name				String to store the WR holder's name.
 * @param time				String to store the WR holder's time.
 * @return						The number of players who have finished the current map.
 */
native int surftimer_GetMapData(char[] name, char[] time);

/**
 * Retrieves the client's data.
 *
 * @param client			The client's ID.
 * @param time				String to store the client's map time.
 * @param rank				int to store the client's map rank.
 * @param country			String to store the client's country.
 */
native void surftimer_GetPlayerData(int& client, char[] time, int& rank, char[] country);

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
forward Action surftimer_OnMapFinished(int client, float fRunTime, char sRunTime[54], int rank, int total);

/**
 * Called when a player reaches a checkpoint zone or a stage.
 *
 * @param client			The client's ID.
 * @return						Plugin_Handled, to stop the client from searching.
 */
forward Action surftimer_OnCheckpoint(int client, float fRunTime, char sRunTime[54], float fPbCp, char sPbDiff[16], char fSrCp, char sSrDiff[16]);


/**
 * Called when a client finishes a bonus.
 *
 * @param client			The client's ID.
 * @return						Plugin_Handled, to stop the player from searching.
 */
forward Action surftimer_OnBonusFinished(int client, float fRunTime, char sRunTime[54], int rank, int total, int bonusid);

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
 * @param style				Style index
 * @param time				Time set by the player
 * @param timeDif			Time difference with the former record
 * @param bonusGroup	Group of the bonus. -1 if the record isn't a bonus
 */
forward void surftimer_OnNewRecord(int client, int style, char[] time, char[] timeDif, int bonusGroup);

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
}
