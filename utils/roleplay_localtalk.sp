#pragma semicolon 1
//
#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <sdkhooks>
#include <phun>
#include <css-rp>
//

#define MAX_AREA_DIST	400

public Plugin:myinfo =  {
	name = "RolePlay: Local-Talk",
	author = "KoSSoLaX",
	description = "gestion des micros local",
	version = "1.2b",
	url = "http://www.ts-x.eu"
}


public OnPluginStart() {
	//
	CreateTimer(0.1, Timer_UpdateListeners, _, TIMER_REPEAT);
	//
}
//
//
// Voice Proximity Plugin
//
public Action:Timer_UpdateListeners(Handle:timer) {
	for (new client = 1; client<=GetMaxClients(); client++) {
		if(!IsValidClient(client)) {
			continue;
		}
		
		if( IsPlayerAlive(client) ) {
			check_area(client);
		}
		else {
			check_dead(client);
		}
	}
}

public check_area(client)  {
	
	if( !IsValidClient(client) )
		return;
	
	for (new id = 1; id <= GetMaxClients() ; id++) {
		
		if( !IsValidClient(id) )
			continue;
		
		if( id == client )
			continue;
		
		if(entity_distance_stock(client, id) <= MAX_AREA_DIST && IsPlayerAlive(id) && !rp_IsJailled(id)) {	
			//In Range
			SetListenOverride(client, id, Listen_Yes);
		}
		else {
			//Out of Range
			SetListenOverride(client, id, Listen_No);
		}
	}
}

public check_dead(client) {
	
	if( !IsValidClient(client) )
		return;
	
	for (new id = 1; id <= GetMaxClients() ; id++) {
		
		if( !IsValidClient(id) )
			continue;
		
		if( id == client ) 
			continue;
		
		SetListenOverride(client, id, Listen_No);
	}
}

public Float:entity_distance_stock(ent1, ent2) {
	new Float:orig1[3];
	new Float:orig2[3];
 
	GetEntPropVector(ent1, Prop_Send, "m_vecOrigin", orig1);
	GetEntPropVector(ent2, Prop_Send, "m_vecOrigin", orig2);

	return GetVectorDistance(orig1, orig2);
}
