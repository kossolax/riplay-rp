#if defined _roleplay_stock_voice_included
#endinput
#endif
#define _roleplay_stock_voice_included

#if defined ROLEPLAY_SUB
	#include "../roleplay.sp"
#else
	#include "roleplay.sp"
#endif

int _GetListenOverride(int client, int id) {
	
	static float g_flLastCheck[MAX_PLAYERS+1][MAX_PLAYERS+1];
	static g_bLastData[MAX_PLAYERS+1][MAX_PLAYERS+1];
	
	if( g_flLastCheck[client][id] > GetGameTime() ) {
		return g_bLastData[client][id];
	}
	
	g_flLastCheck[client][id] = GetGameTime() + 0.25;
	g_bLastData[client][id] = view_as<int>(GetListenOverride(client, id));
	
	return g_bLastData[client][id];
}
float _Entity_GetDistance(int client, int id) {
	static float g_flLastCheck[MAX_PLAYERS+1][MAX_PLAYERS+1];
	static float g_flLastData[MAX_PLAYERS+1][MAX_PLAYERS+1];
	
	if( g_flLastCheck[client][id] > GetGameTime() ) {
		return g_flLastData[client][id];
	}
	
	int source = GetEntPropEnt(client, Prop_Send, "m_hVehicle");
	if( source <= 0 )
		source = rp_GetClientVehiclePassager(client);
	if( source <= 0 )
		source = Entity_GetParent(client);
	if( source <= 0 )
		source = client;
	
	int target = GetEntPropEnt(id, Prop_Send, "m_hVehicle");
	if( target <= 0 )
		target = rp_GetClientVehiclePassager(id);
	if( target <= 0 )
		target = Entity_GetParent(id);
	if( target <= 0 )
		target = id;
			
	g_flLastCheck[client][id] = GetGameTime() + 0.25;
	g_flLastData[client][id] = Entity_GetDistance(source, target);		
		
	Action a;
	Call_StartForward(view_as<Handle>(g_hRPNative[client][RP_OnPlayerHear]));
	Call_PushCell(client);
	Call_PushCell(id);
	Call_PushFloatRef(g_flLastData[client][id]);
	Call_Finish(a);
		
	if( a == Plugin_Handled || a == Plugin_Stop )
		g_flLastData[client][id] = FLT_MAX;	
	
	return g_flLastData[client][id];
}

void check_area(int client) {
	
	for (int id = 1; id <= MaxClients ; id++) {
		
		if( !IsValidClient(id) )
			continue;
		
		if( id == client )
			continue;
		
		if( _Entity_GetDistance(client, id) <= MAX_AREA_DIST && IsPlayerAlive(id) ) {	
			//In Range
			if( _GetListenOverride(client, id) != view_as<int>(Listen_Yes) )
				SetListenOverride(client, id, Listen_Yes);
		}
		else {
			//Out of Range
			if( _GetListenOverride(client, id) != view_as<int>(Listen_No) )
				SetListenOverride(client, id, Listen_No);
		}
	}
}

void check_dead(int client) {
	
	for (int id = 1; id <= MaxClients ; id++) {
		
		if( !IsValidClient(id) )
			continue;
		
		if( id == client ) 
			continue;
		
		if( _GetListenOverride(client, id) != view_as<int>(Listen_No) )
			SetListenOverride(client, id, Listen_No);
	}
}
