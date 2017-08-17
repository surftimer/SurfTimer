#if defined _CKSurf_included
 #endinput
#endif
#define _CKSurf_included

/* Natives */

/**
 * Checks clients timer status
 *
 * @param client    Client's id
 * @return          True / False 
 */
native bool:ckSurf_GetTimerStatus(client);

/**
 * Stops client's timer.
 *
 * @param client    Client's id
 * @return          No return
 */
native ckSurf_StopTimer(client);

/**
 * Starts client's timer
 *
 * @param client    Client's id
 * @return          No return
 */
native ckSurf_EmulateStartButtonPress(client);

/**
 * Finishes a client's run.
 *
 * @param client    Client's id
 * @return          No return
 */
native ckSurf_EmulateStopButtonPress(client);

/**
 * Get client's current runtime.
 *
 * @param client     Client's id
 * @return           Client's curren runtime as a float.
 */
native Float:ckSurf_GetCurrentTime(client);

/**
 * Checks if the client has VIP status
 *
 * @param client     Client's id
 * @return           True / False
 */
native bool:ckSurf_ClientIsVIP(client);

/**
 * Gets the server rank of a client
 *
 * @param client     Client's id
 * @return           Server rank as an int
 */
native ckSurf_GetServerRank(client);

/**
 * Safely teleports the client. Does not trigger end touches
 * and sets client location correctly.
 *
 * @param client    		Client's id
 * @param fDestination 		Teleport location
 * @param fAngle 			Teleport angle
 * @param fVelocity 		Teleport velocity
 * @param bStopTimer 		Stop the client's timer, default false
 * @return           true on success / false on failure
 */
native bool:ckSurf_SafeTeleport(client, Float:fDestination[3], Float:fAngle[3], Float:fVelocity[3], bool:bStopTimer = false);

/*
		FORWARDS
						*/

/**
 * Called when a player finishes a map
 *
 * @param client     Player index.
 * @return           Plugin_Handled; to stop the player from searching.
 */
forward Action:ckSurf_OnMapFinished(client, Float:fRunTime, String:sRunTime[54], rank, total);

/**
 * Called when a player finishes a bonus
 *
 * @param client     Player index.
 * @return           Plugin_Handled; to stop the player from searching.
 */
forward Action:ckSurf_OnBonusFinished(client, Float:fRunTime, String:sRunTime[54], rank, total, bonusid);

/**
 * Called when a player finishes a map in practice mode
 *
 * @param client     Player index.
 * @return           Plugin_Handled; to stop the player from searching.
 */
 forward Action:ckSurf_OnPracticeFinished(client, Float:fRunTime, String:sRunTime[54]);


public SharedPlugin:__pl_ckSurf =
{
	name = "ckSurf",
	file = "ckSurf.smx",
	#if defined REQUIRE_PLUGIN
	required = 1,
	#else
	required = 0,
	#endif
};

public __pl_ckSurf_SetNTVOptional()
{
	MarkNativeAsOptional("ckSurf_GetTimerStatus");
	MarkNativeAsOptional("ckSurf_StopTimer");
	MarkNativeAsOptional("ckSurf_EmulateStartButtonPress");	
	MarkNativeAsOptional("ckSurf_EmulateStopButtonPress");
	MarkNativeAsOptional("ckSurf_GetCurrentTime");
	MarkNativeAsOptional("ckSurf_ClientIsVIP");
	MarkNativeAsOptional("ckSurf_GetServerRank");
	MarkNativeAsOptional("ckSurf_SafeTeleport");
}