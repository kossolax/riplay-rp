#if defined _roleplay_stock_doors_included
#endinput
#endif
#define _roleplay_stock_doors_included

#if defined ROLEPLAY_SUB
	#include "../roleplay.sp"
#else
	#include "roleplay.sp"
#endif

Action OpenBossGestionCle(int client, bool typess = false) {
	if( ! IsBoss(client) ) {
		ACCESS_DENIED(client);
	}
	
	int Ent = GetClientAimTarget(client, false);
	if( !IsValidDoor(Ent) ) {
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_YouMustAim", client, "prop_door_rotating");
		return Plugin_Handled;
	}
	
	int door_bdd = (Ent - MaxClients);
	
	if( !g_iDoorJob[g_iUserData[client][i_Job]][door_bdd] ) {
		if( !IsAdmin(client) ) {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Door_Cannot_NoKey", client);
			return Plugin_Handled;
		}
	}
	
	if( g_iDoorDouble[door_bdd] < door_bdd && g_iDoorDouble[door_bdd] != 0) {
		door_bdd = g_iDoorDouble[door_bdd];
	}
	
	Handle menu;
	
	// Setup menu
	if( typess ) {
		menu = CreateMenu(GestionKeyBoss_2);
	}
	else {
		menu = CreateMenu(GestionKeyBoss);
	}
	
	SetMenuTitle(menu, "%T\n ", "Menu_Villa_Key", client);
	
	char tmp[256], tmp2[256];
	
	if( typess ) {
		Format(tmp, sizeof(tmp), "-1_%i", door_bdd);	Format(tmp2, sizeof(tmp2), "%T", "Door_RemoveAll", client);	AddMenuItem(menu, tmp, tmp2);
		Format(tmp, sizeof(tmp), "-2_%i", door_bdd);	Format(tmp2, sizeof(tmp2), "%T", "Door_AddAll", client);	AddMenuItem(menu, tmp, tmp2);
	}
	
	
	for(int i = 0; i < MAX_JOBS; i++) {
		if( StringToInt(g_szJobList[i][2]) != g_iUserData[client][i_Job] ) {
			if( !IsAdmin(client) || (IsAdmin(client) && !typess)) 
				continue;
		}
		
		if( strlen(g_szJobList[i][job_type_name]) <= 1 ) {
			continue;
		}
		
		
		if( typess ) {
			if( StringToInt(g_szJobList[i][job_type_isboss]) != 1 ) {
				continue;
			}
		}
		
		Format(tmp, sizeof(tmp), "%i_%i", i, door_bdd);
		Format(tmp2, sizeof(tmp2), "%T", g_iDoorJob[i][door_bdd] ? "Door_Remove" : "Door_Add", client, g_szJobList[i][job_type_name]);
		AddMenuItem(menu, tmp, tmp2);
	}
	
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_DURATION);
	
	return Plugin_Handled;
}
bool IsValidDoor(int ent) {
	if( ent <= 0 )
		return false;
	
	static float g_flLastCheck[MAX_ENTITIES+1];
	static bool g_bLastData[MAX_ENTITIES+1];
	
	if( g_flLastCheck[ent] > GetGameTime() ) {
		return g_bLastData[ent];
	}
	
	g_bLastData[ent] = false;
	g_flLastCheck[ent] = GetGameTime() + Math_GetRandomFloat(3.0, 5.0);
	
	if(!IsValidEdict(ent))
		return g_bLastData[ent];
	if( !IsValidEntity(ent) )
		return g_bLastData[ent];
	
	char classname[64];
	GetEdictClassname(ent, classname, sizeof(classname));
	
	if( StrContains("func_door_rotating_prop_door_rotating_func_door", classname) >= 0 ) {
		GetEntPropString(ent, Prop_Data, "m_iName", classname, sizeof(classname));
		if( !StrEqual(classname, "night_skybox") ) {
			g_bLastData[ent] = true;
		}
	}
	
	return g_bLastData[ent];
}


//
// Doors:
void LoadDoors(int Client = 0) {
	Handle hQuery;
	
	if(Client == 0) {
		
		char szmapname[64];
		GetCurrentMap(szmapname, sizeof(szmapname));
		
		char szQuery[1024];
		Format(szQuery, sizeof(szQuery), "SELECT `id`, `locked`, `cannot_force`, `double_door`, `no_use` FROM `rp_door_locked` WHERE `map`='%s';", szmapname);
		
		SQL_LockDatabase(g_hBDD);
		if ((hQuery = SQL_Query(g_hBDD, szQuery)) == INVALID_HANDLE) {
			
			CloseHandle(hQuery);
			SQL_UnlockDatabase(g_hBDD);
			return;
		}
		
		
		while( SQL_FetchRow(hQuery) ) {
			int id = SQL_FetchInt(hQuery, 0);
			int locked = SQL_FetchInt(hQuery, 1);
			
			g_iDoorKnowed[id] = 1;
			g_iDoorCannotForce[id] = SQL_FetchInt(hQuery, 2);
			g_iDoorDouble[id] = SQL_FetchInt(hQuery, 3);
			g_iDoorNouse[id] = SQL_FetchInt(hQuery, 4);
			
			
			if( IsValidEntity( (id+MaxClients ) ) ) {
				if( locked ) {
					LockSomeDoor(id, 1);
				}
				else {
					LockSomeDoor(id, 0);
				}
				
				char classname[64];
				int door_id = id+MaxClients;
				
				GetEdictClassname(door_id, classname, sizeof(classname));
				if( StrContains("func_door_func_door_rotating_func_rotating", classname) >= 0 ) {
					SetEntPropFloat( door_id, Prop_Data, "m_flBlockDamage", 0.0);
				}
			}
		}
		
		CloseHandle(hQuery);
		SQL_UnlockDatabase(g_hBDD);
	}
	
	return;
}
void SaveDoors() {
	
	for(int i=1; i < MAX_ENTITIES; i++) {
		
		if( IsValidDoor(i) && IsValidEdict(i) && IsValidEntity(i) && HasEntProp(i, Prop_Data, "m_bLocked") ) {
			
			int i_bdd = (i-MaxClients);
			char query[1024], szMapname[64];
			GetCurrentMap(szMapname, sizeof(szMapname));
			
			Format(query, 1023, "UPDATE `rp_door_locked` SET `locked`='%i', `no_use`='%i' WHERE `id`='%i' AND `map`='%s' LIMIT 1;", GetEntProp(i, Prop_Data, "m_bLocked"), g_iDoorNouse[i_bdd], i_bdd, szMapname);
			SQL_TQuery(g_hBDD, SQL_QueryCallBack, query, 0, DBPrio_Low);
		}
	}
	
	return;
}
stock bool IsPlayerHaveKey( int client, int door, int lock=0) {
	if( IsClientInJail(client) )
		return false;
	
	if( lock == 0 )
		lock = GetLockType(door);
	
	if( IsClientInJail(client) )
		return false;
	if( g_iUserData[client][i_KidnappedBy] > 0 )
		return false;
	if( g_iUserData[client][i_Job] == 1 || g_iUserData[client][i_Job] == 101 )
		return true;
		
	if( (GetJobPrimaryID(client) == 1 || GetJobPrimaryID(client) == 101) && (GetZoneBit(GetPlayerZone(door)) & BITZONE_PERQUIZ) )
		return true;
	if( GetJobPrimaryID(client) == 1 && StringToInt(g_szZoneList[GetPlayerZone(door)][zone_type_type]) == 1 )
		return true;
	if( GetJobPrimaryID(client) == 101 && StringToInt(g_szZoneList[GetPlayerZone(door)][zone_type_type]) == 101 )
		return true;
	
	if( g_iUserData[client][i_AlzheimerTime] > GetTime() )
		return false;
	
	if( lock == 2 && (GetJobPrimaryID(client) == 51 || GetJobPrimaryID(client) == 61) ) {
		int appart = getZoneAppart(door);
		if( GetJobPrimaryID(client) == 51 && appart > 100 && !IsValidClient(g_iAppartBonus[appart][appart_proprio]) ) {
			return true;
		}
		if( GetJobPrimaryID(client) == 61 && appart > 0 && appart < 50 && !IsValidClient(g_iAppartBonus[appart][appart_proprio]) ) {
			return true;
		}
	}
	
	Action c;
	Call_StartForward( view_as<Handle>(g_hRPNative[client][RP_OnPlayerCheckKey]));
	Call_PushCell(client);
	Call_PushCell(door);
	Call_PushCell(lock);
	Call_Finish(c);
	 
	if( c == Plugin_Changed )
		return true;
	if( c == Plugin_Handled || c == Plugin_Stop )
		return false;
	
	if( GotPvPKey(client, door) ) {
		return true;
	}
	
	door = door - MaxClients;
	
	if( g_iDoorDouble[door] < door && g_iDoorDouble[door] != 0 ) {
		door = g_iDoorDouble[door];
	}
	
	if( g_iDoorJob[ g_iUserData[client][i_Job] ][door] ) {
		return true;
	}
	// Custom Key et appart
	char ParentList[32][12];
	int length;
	
	for(int a=1; a<MAX_KEYSELL; a++) {
		length = ExplodeString(g_szSellingKeys[a][key_type_parent], "-", ParentList, sizeof(ParentList), sizeof(ParentList[]));		
		
		for(int b=0; b<length; b++) {
			if( StringToInt(ParentList[b]) <= 0 )
				continue;
			
			if( StringToInt(ParentList[b]) == door ) {
				if( g_iDoorOwner_v2[client][a] ) { 
					return true;
				}
			}
		}
	}
	return false;
}
void ToggleDoorLock(int client, int door, int lock_type) {
	int door_bdd = (door - MaxClients);

	
	if( !IsValidDoor(door) )
		return;
	
	if( Entity_GetDistance(client, door) > MAX_AREA_DIST )
		return;
	
	if( IsPlayerHaveKey( client, door, lock_type) ) {
		// Lock
		if( lock_type == 1) {
			if( !GetEntProp(door, Prop_Data, "m_bLocked") ) {
				CPrintToChat(client, "" ...MOD_TAG... " %T", "Door_Lock", client);
				EmitSoundToAllAny("doors/default_locked.wav", door, _, _, _, 0.25);
			}
			LockSomeDoor(door_bdd, 1);
		}
		// UnLock
		if( lock_type == 2) {
			if( GetEntProp(door, Prop_Data, "m_bLocked") ) {
				CPrintToChat(client, "" ...MOD_TAG... " %T", "Door_Unlock", client);
				EmitSoundToAllAny("doors/latchunlocked1.wav", door, _, _, _, 0.25);
			}
			LockSomeDoor(door_bdd, 0);
		}
	}
	else if( IsValidDoor(door) ) {
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Door_Cannot_NoKey", client);
	}
}
int GetLockType(int door) {
	int lock = GetEntProp(door, Prop_Data, "m_bLocked");
	if (lock == 0)
		lock = 2;
	return lock;
}
void ToggleDoor(int client, int door) {
	int door_bdd = (door - MaxClients);
	
	if( IsPlayerHaveKey( client, door, GetLockType(door)) ) {
		if( GetEntProp(door, Prop_Data, "m_bLocked") ) {
			LockSomeDoor(door_bdd, 1);
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Door_IsLocked", client);
			return;
		}
	}
	else {
		if( GetEntProp(door, Prop_Data, "m_bLocked") ) {
			LockSomeDoor(door_bdd, 1);
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Door_Cannot_NoKey", client);
			return;
		}
	}
	
	char classname[64];
	GetEdictClassname(door, classname, sizeof(classname));
	if( StrEqual(classname, "func_door", false) || StrEqual(classname, "func_door_rotating", false)  || StrEqual(classname, "prop_door_rotating", false) ) {
		ActivateDoor(client, door_bdd);
	}
}
void LockSomeDoor(int door_bdd, int lock) {
	
	int door = (door_bdd + MaxClients);
	
	if( !IsValidDoor(door) )
		return;
	
	SetEntProp(door, Prop_Data, "m_bLocked", lock);
	
	door_bdd = g_iDoorDouble[door_bdd];
	
	if( door_bdd > 0 ) {
		
		door = (door_bdd + MaxClients);
		
		if( !IsValidDoor(door) )
			return;
		
		SetEntProp(door, Prop_Data, "m_bLocked", lock);
	}
	
}
void ActivateDoor(int client, int door_bdd) {
	int door = (door_bdd + MaxClients);
	
	rp_AcceptEntityInput(door, "Toggle", client);
	if( rp_GetBuildingData(door, BD_Trapped) == 1 ) {
		rp_Effect_PropExplode(door, client);
	}
	
	door_bdd = g_iDoorDouble[door_bdd];
	
	if( door_bdd > 0 ) {
		
		door = (door_bdd + MaxClients);
		rp_AcceptEntityInput(door, "Toggle", client);
		if( rp_GetBuildingData(door, BD_Trapped) == 1 ) {
			rp_Effect_PropExplode(door, client);
		}

	}
}

int getDoorAppart(int target) {
	
	if( !IsValidDoor(target) )
		return -1;
	
	int door_bdd = (target-MaxClients);
	char ParentList[32][12];
	int length;
	
	for(int a=0; a<MAX_KEYSELL; a++) {
		length = ExplodeString(g_szSellingKeys[a][key_type_parent], "-", ParentList, sizeof(ParentList), sizeof(ParentList[]));
		
		for(int b=0; b<length; b++) {
			if( StringToInt(ParentList[b]) <= 0 )
				continue;
			if( StringToInt(ParentList[b]) == door_bdd ) {
				return a;
			}
		}
	}
	
	return -1;
}
