#include <sourcemod>
#include <cstrike>
#include <sdkhooks>
#include <colors_csgo>	// https://forums.alliedmods.net/showthread.php?p=2205447#post2205447
#include <smlib>		// https://github.com/bcserv/smlib

#pragma newdecls required
#include <roleplay.inc>	// https://www.ts-x.eu

#pragma newdecls required

public Plugin myinfo =  {
	name = "UnStuck",
	author = "KoSSoLaX",
	description = "Décoince toi..",
	version = "2.1",
	url = "http://www.ts-x.eu"
}

 float g_size[][3] = {
	{0.0, 0.0, 1.0}, {0.0, 1.0, 0.0}, {0.0, -1.0, 0.0}, {1.0, 0.0, 0.0}, {-1.0, 0.0, 0.0}, {-1.0, 1.0, 1.0}, {1.0, 1.0, 1.0}, {1.0, -1.0, 1.0}, {-1.0, -1.0, 1.0},
	{0.0, 0.0, 2.0}, {0.0, 2.0, 0.0}, {0.0, -2.0, 0.0}, {2.0, 0.0, 0.0}, {-2.0, 0.0, 0.0}, {-2.0, 2.0, 2.0}, {2.0, 2.0, 2.0}, {2.0, -2.0, 2.0}, {-2.0, -2.0, 2.0},
	{0.0, 0.0, 3.0}, {0.0, 3.0, 0.0}, {0.0, -3.0, 0.0}, {3.0, 0.0, 0.0}, {-3.0, 0.0, 0.0}, {-3.0, 3.0, 3.0}, {3.0, 3.0, 3.0}, {3.0, -3.0, 3.0}, {-3.0, -3.0, 3.0},
	{0.0, 0.0, 4.0}, {0.0, 4.0, 0.0}, {0.0, -4.0, 0.0}, {4.0, 0.0, 0.0}, {-4.0, 0.0, 0.0}, {-4.0, 4.0, 4.0}, {4.0, 4.0, 4.0}, {4.0, -4.0, 4.0}, {-4.0, -4.0, 4.0},
	{0.0, 0.0, 5.0}, {0.0, 5.0, 0.0}, {0.0, -5.0, 0.0}, {5.0, 0.0, 0.0}, {-5.0, 0.0, 0.0}, {-5.0, 5.0, 5.0}, {5.0, 5.0, 5.0}, {5.0, -5.0, 5.0}, {-5.0, -5.0, 5.0}
};
float MinHull[3] = { -16.0, -16.0,  0.0 };
float MaxHull[3] = {  16.0,  16.0, 72.0 };

public void OnPluginStart() {
	RegConsoleCmd("sm_stuck", CmdStuck);
	RegServerCmd("sm_stuck2", CmdStuck2);
	RegServerCmd("sm_stuck3", CmdStuck3);
}
public Action CmdStuck2(int args) {
	int client = GetCmdArgInt(1);
	float pos[3];
	GetClientAbsOrigin(client, pos);
	
	UnstuckClient(client, pos);
	return Plugin_Handled;
}
public Action CmdStuck3(int args) {
	int client = GetCmdArgInt(1);
	float pos[3];
	pos[0] = GetCmdArgFloat(2);
	pos[1] = GetCmdArgFloat(3);
	pos[2] = GetCmdArgFloat(4);
	
	TeleportEntity(client, pos, NULL_VECTOR, NULL_VECTOR);
	UnstuckClient(client, pos);
	return Plugin_Handled;
}
public Action CmdStuck(int client, int args) {
	static float g_flLastTest[65]
	float time = GetGameTime();
	
	if( g_flLastTest[client] > time )
		return Plugin_Handled;
	
	g_flLastTest[client] = time + 1.0;
	
	float pos[3];
	GetClientAbsOrigin(client, pos);
	
	UnstuckClient(client, pos);
	return Plugin_Handled;
}
void UnstuckClient(int client, float vecOrigin[3]) {
	float vec[3], vecTarget[3];
	
	LogToGame("[STUCK] %N wants unstuck", client);
	
	for(int i=1; i<=MaxClients; i++) {
		if( i == client || !IsValidClient(i) || !IsPlayerAlive(i) )
			continue;
		if( GetEntityMoveType(i) == MOVETYPE_NOCLIP )
			continue;
		
		GetClientAbsOrigin(i, vecTarget);
		if( GetVectorDistance(vecTarget, vecOrigin) > 128.0 )
			continue;
		
		if( GetVectorDistance(vecTarget, vecOrigin) > 24.0 ) {
			GetClientAbsOrigin(i, vecTarget);
			if( FloatAbs(vecTarget[2]-vecOrigin[2]) <= 72.0 ) {
				vecTarget[2] = vecOrigin[2];
				if( GetVectorDistance(vecOrigin, vecTarget) > 32.0 )
					continue;
			}
			else {
				continue;
			}
		}
		
		if( rp_GetClientBool(i, b_IsAFK) ) {
			SDKHooks_TakeDamage(i, i, i, 10000.0);
			continue;
		}
		
		LogToGame("[STUCK] %N is stuck into %N", client, i);
		
		for(int j=0; j<sizeof(g_size); j++) {
			vec[0] = vecOrigin[0] - (MinHull[0] * g_size[j][0] * 2.1);
			vec[1] = vecOrigin[1] - (MinHull[1] * g_size[j][1] * 2.1);
			vec[2] = vecOrigin[2] - (MinHull[2] * g_size[j][2] * 2.1);
			
			if( isHullVacant(vec, client) ) {
				TeleportEntity(client, vec, NULL_VECTOR, NULL_VECTOR);
				LogToGame("[STUCK] %N has been unstucked in %d attempts", client, j);
				return;
			}
		}
		LogToGame("[STUCK] %N has failed to unstuck", client);
		break;
	}
}
bool isHullVacant(const float origin[3], int target) {
	
	Handle tr = TR_TraceHullFilterEx(origin, origin, MinHull, MaxHull, MASK_PLAYERSOLID, TraceRayDontHitSelf, target);
	if( TR_DidHit(tr) ) {
		CloseHandle(tr);
		return false;
	}
	CloseHandle(tr);
	return true;
}
public bool TraceRayDontHitSelf(int entity, int mask, any data) {
	if(entity == data) {
		return false; // Don't let the entity be hit
	}
	return true; // It didn't hit itself
}
