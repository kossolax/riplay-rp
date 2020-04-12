#pragma semicolon 1

#define GAME_CSGO
//#define GAME_CSS

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <phun>
#include <smlib>
#include <cstrike>

#define FLAG_SPEED		250.0
#define PI				3.1415926

public Plugin:myinfo = 
{
	name = "RP-CTF",
	author = "KoSSoLaX",
	description = "CTF MOD roleplay",
	version = "0.1",
	url = "http://www.ts-x.eu"
}



public OnPluginStart() {
	RegAdminCmd("sm_spawnflag", 	Cmd_SpawnFlag, ADMFLAG_ROOT);
	HookEvent("player_death", 		EventDeath, 		EventHookMode_Pre);
	RegConsoleCmd("drop", FlagDrop);
}



public Action:Cmd_SpawnFlag(client, args) {
	new Float:vecOrigin[3];
	GetClientAbsOrigin(client, vecOrigin);
	
	new color[3];
	color[0] = GetCmdArgInt(2);
	color[1] = GetCmdArgInt(3);
	color[2] = GetCmdArgInt(4);
	
	
	CTF_SpawnFlag(vecOrigin, GetCmdArgInt(1),  color);
}
