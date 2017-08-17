#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "Elzi"
#define PLUGIN_VERSION "1.00"

#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <ckSurf>

EngineVersion g_Game;

Handle g_hEntity;
int g_iEntIndex[MAXPLAYERS + 1];

public Plugin myinfo = 
{
	name = "[ckSurf] Teleport Destination Finder",
	author = PLUGIN_AUTHOR,
	description = "Teleports clients using !cktele to info_teleport_destinations",
	version = PLUGIN_VERSION,
	url = ""
};

public void OnPluginStart()
{
	g_Game = GetEngineVersion();
	if(g_Game != Engine_CSGO && g_Game != Engine_CSS)
	{
		SetFailState("This plugin is for CSGO/CSS only.");	
	}
	
	RegAdminCmd("sm_cktele", TeleToInfo, ADMFLAG_ROOT, "[ckSurf] Teleport client to a teleport destination in the map");

}

public void OnMapStart()
{
	for (int i = 0; i < MAXPLAYERS + 1; i++)
		g_iEntIndex[i] = 0;
	
	int iEnt;
	g_hEntity = CreateArray(12);

	while ((iEnt = FindEntityByClassname(iEnt, "info_teleport_destination")) != -1)
		PushArrayCell(g_hEntity, iEnt);

}

public void OnMapEnd()
{
	if (g_hEntity != null)
		g_hEntity.Close();
	
	g_hEntity = null;
}


public Action TeleToInfo(int client, int args)
{
	if (g_hEntity == null)
	{
		ReplyToCommand(client, "[CK] g_hEntity was null!");
		return Plugin_Handled;
	}
		
	if (GetArraySize(g_hEntity) < 1)
	{
		ReplyToCommand(client, "[CK] No info_teleport_destinations found in map!");
		return Plugin_Handled;
	}
	
	if (g_iEntIndex[client] == GetArraySize(g_hEntity))
	{
		ReplyToCommand(client, "[CK] All info_teleport_destinations were looped, back to index 0");
		g_iEntIndex[client] = 0;
	}
	
	int iEnt = GetArrayCell(g_hEntity, g_iEntIndex[client]);
	
	if (IsValidEntity(iEnt))
	{
		float position[3];
		GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", position);

		ckSurf_SafeTeleport(client, position, NULL_VECTOR, NULL_VECTOR, true);

		ReplyToCommand(client, "[CK] Teleporting to entity at %f, %f, %f", position[0], position[1], position[2]);
	}
	else
	
		ReplyToCommand(client, "[CK] Entity was invalid!");


	g_iEntIndex[client]++;
	return Plugin_Handled;
}