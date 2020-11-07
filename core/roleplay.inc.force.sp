#if defined _roleplay_force_included
#endinput
#endif
#define _roleplay_force_included

#if defined ROLEPLAY_SUB
	#include "../roleplay.sp"
#else
	#include "roleplay.sp"
#endif

public MRESReturn DHooks_OnTeleport(int client, Handle hParams) {
 	//float origin[3], angles[3], velocity[3];
 	bool bOriginNull = DHookIsNullParam(hParams, 1);
 	//bool bAnglesNull = DHookIsNullParam(hParams, 2);
 	//bool bVelocityNull = DHookIsNullParam(hParams, 3);
 	
 	
 	
	if( !bOriginNull && g_bMovingTeleport[g_iGrabbedBy[client]] == false ) {
		FORCE_STOP(client);
		FORCE_Release(client);
	}
 
 	return MRES_Ignored;
 }
public Action Cmd_Force_Rebind(int client, int args) {
	char arg[256];
	
	GetCmdArgString(arg, sizeof(arg));
	StripQuotes(arg);
	
	if( StrEqual(arg, "/+force", false) || StrEqual(arg, "/-force", false) ||  StrEqual(arg, "!+force", false) || StrEqual(arg, "!-force", false) || StrEqual(arg, "+force", false) || StrEqual(arg, "-force", false)  ) {
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Force_Bind", client);
		
		FORCE_STOP(client);
		CreateTimer(0.01, FixForce, client);
		return Plugin_Handled;
	}
	return Plugin_Continue;
}
public void FORCE_FRAME(int client) {
	static int g_iFrameCount[MAX_PLAYERS+1];
		
	if( g_iGrabbing[client] > 0 || g_bIsSeeking[client] == true ) {
		if( (GetZoneBit(GetPlayerZone(client)) & BITZONE_BLOCKFORCE) || (GetZoneBit(GetPlayerZone(client)) & BITZONE_POLICEFORCE && (!IsPolice(client) && !IsJuge(client))) ) {
			FORCE_STOP(client);
			return;
		}
	}
	g_iFrameCount[client]++;
	
	if( g_bIsSeeking[client] ) {
		
		if( g_iGrabbing[client] > 0 ) {
			SDKUnhook(g_iGrabbing[client], SDKHook_Touch, OnForceTouch);
		}
		g_iGrabbing[client] = 0;
		
		float position[3];
		int result = GetClientAimTarget(client, false);
		if( !CheckValidGrab(client, result) && g_bCheckSphere[client] && g_iFrameCount[client]%5 == 0 ) {
			
			rp_GetClientTarget(client, position);
			
			result = FindEntityInSphere(client, 1, position, RANGE);
			CheckValidGrab(client, result);
		}
		
		if( g_bToggle[client] ) {
			g_bIsSeeking[client] = false;
		}
		
	}
	else if( g_iGrabbing[client] > 0 && IsValidEdict(g_iGrabbing[client]) && IsValidEntity(g_iGrabbing[client]) ) {
		
		if( GetEntPropEnt(client, Prop_Send, "m_hVehicle") >= MaxClients ) {
			FORCE_STOP(client);
			return;
		}
		
		int entity = g_iGrabbing[client];
		
		if( IsValidClient(entity) ) {
			if( !IsPlayerAlive(entity) ) {
				FORCE_STOP(client);
				return;
			}
			if( GetEntPropFloat(entity, Prop_Data, "m_flLaggedMovementValue") <= 0.1 ) {
				FORCE_STOP(client);
				return;
			}
			if( GetEntityMoveType(entity) == MOVETYPE_NONE || GetEntityMoveType(entity) == MOVETYPE_NOCLIP ) {
				FORCE_STOP(client);
				return;
			}
			if( g_flLubrifian[entity] > GetGameTime() ) {
				FORCE_STOP(client);
				return;
			}
		}
		
		
		float ClientOrigin[3], ClientAimOrigin[3], vecDirection[3];
		float EntityOrigin[3], vecVelocity[3], vecMoveto[3], length;
			
		GetClientEyePosition(client, ClientOrigin);
		rp_GetClientTarget(client, ClientAimOrigin);
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", EntityOrigin);
		SubtractVectors(ClientAimOrigin, ClientOrigin, vecDirection);
			
		length = GetVectorDistance(ClientAimOrigin, ClientOrigin);
		
		if( length <= 0.0 || ((length >= 8000.0 || length <= 10.0) && g_fGrabbedLength[client] > 10.0) ) {
			// Let's prevent bug from TR
			return;
		}
		
		if( g_bGrabNear[client] ) {
			vecMoveto[0] = ClientOrigin[0] + vecDirection[0] * DISTANCE / length;
			vecMoveto[1] = ClientOrigin[1] + vecDirection[1] * DISTANCE / length;
			vecMoveto[2] = ClientOrigin[2] + vecDirection[2] * (DISTANCE/2) / length;
			
			if( GetVectorDistance(ClientOrigin, EntityOrigin, false) >= (DISTANCE*2.0) ) {
				FORCE_STOP(client);
				return;
			}
		}
		else {
			vecMoveto[0] = ClientOrigin[0] + vecDirection[0] * g_fGrabbedLength[client] / length;
			vecMoveto[1] = ClientOrigin[1] + vecDirection[1] * g_fGrabbedLength[client] / length;
			vecMoveto[2] = ClientOrigin[2] + vecDirection[2] * g_fGrabbedLength[client] / length;
		}
		
		float dist = GetVectorDistance( vecMoveto, EntityOrigin);
		
		vecVelocity[0] = (vecMoveto[0] - EntityOrigin[0]) * dist / VELOCITY_MULTIPLIER;
		vecVelocity[1] = (vecMoveto[1] - EntityOrigin[1]) * dist / VELOCITY_MULTIPLIER;
		vecVelocity[2] = (vecMoveto[2] - EntityOrigin[2]) * dist / VELOCITY_MULTIPLIER;
		
		if( g_bGrabNear[client] && GetVectorLength(vecVelocity) >= 4096.0 ) {
 			FORCE_STOP(client);
 			return;
 		}
		
		if( IsValidClient(entity) ) {
			SetEntPropFloat(entity, Prop_Send, "m_flFallVelocity", 0.0);
			int flags = GetEntityFlags(entity);
			SetEntityFlags(entity, (flags&~FL_ONGROUND) );
			SetEntPropEnt(entity, Prop_Send, "m_hGroundEntity", -1);
			
			g_flUserData[entity][fl_ProtectWorldSpawn] = GetGameTime() + 5.0;
		}
			
		if( IsValidVehicle(entity) ) {
			SetEntPropFloat(entity, Prop_Send, "m_flThrottle", 0.0);
		}
		if( g_bMovingTeleport[client] ) {
			TeleportEntity(entity, vecMoveto, NULL_VECTOR, vecVelocity);
		}
		else {
			TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, vecVelocity);
		}
	}
	else {
 		FORCE_STOP(client);
 	}
}
public Action FixForce(Handle timer, any client) {
	if( IsValidClient(g_iGrabbing[client]) ) {
		int entity = g_iGrabbing[client];
		
		SetEntPropFloat(entity, Prop_Send, "m_flFallVelocity", 0.0);
		int flags = GetEntityFlags(entity);
		SetEntityFlags(entity, (flags&~FL_ONGROUND) );
		SetEntPropEnt(entity, Prop_Send, "m_hGroundEntity", -1);
		
		float nulVec[3];
		TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, nulVec);
	}
	FORCE_STOP(client);
}
void FORCE_STOP(int client) {
	if( g_iGrabbing[client] > 0  ) {
		
		SDKUnhook(g_iGrabbing[client], SDKHook_Touch, OnForceTouch);
		if( IsValidClient(g_iGrabbing[client]) ) {
			float nulVec[3];
			int flags = GetEntityFlags(g_iGrabbing[client]);
			SetEntityFlags(g_iGrabbing[client], (flags&~FL_ONGROUND) );
			SetEntPropEnt(g_iGrabbing[client], Prop_Send, "m_hGroundEntity", -1);
			if( g_bToggle[client] ) {
				TeleportEntity(g_iGrabbing[client], NULL_VECTOR, NULL_VECTOR, nulVec);
			}
		}
		
		g_iGrabbedBy[g_iGrabbing[client]] = 0;		
	}
	g_iGrabbing[client] = 0;
	g_bIsSeeking[client] = false;
	
}
void FORCE_Release(int client) {
	
	if( g_iGrabbedBy[client] > 0 ) {
		FORCE_STOP(g_iGrabbedBy[client]);
	}
}
public Action Cmd_grab(int client, int args) {
	for(int i=1; i<=MaxClients; i++) {
		if( !IsValidClient(i) ) 
			continue;
			
		if( g_iGrabbing[i] == client ) {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Force_Already", client);
			FORCE_STOP(client);
			return Plugin_Handled;
		}
	}
	if(
		StringToInt(g_szZoneList[ GetPlayerZone(client) ][zone_type_type]) == 1 ||
		StringToInt(g_szZoneList[ GetPlayerZone(client) ][zone_type_type]) == 101
	) {
		if( !IsPolice(client) && !IsJuge(client) ) {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Force_Here", client);
			FORCE_STOP(client);
			return Plugin_Handled;
		}
	}
	
	if( g_bToggle[client] ) {
		if( g_iGrabbing[client] > 0 ) {
			
			FORCE_STOP(client);
		}
		else {
			g_bIsSeeking[client] = true;
		}
	}
	else {
		if( g_iGrabbing[client] > 0 ) {
			SDKUnhook(g_iGrabbing[client], SDKHook_Touch, OnForceTouch);
		}
		g_iGrabbing[client] = 0;
		g_bIsSeeking[client] = true;
		g_bToggle[client] = false;
	}
	return Plugin_Handled;
}
public Action Cmd_release(int client, int args) {
	
	if( !g_bToggle[client] ) {
		FORCE_STOP(client);
	}
	
	return Plugin_Handled;
}
public Action Cmd_ForceMenu(int client, int args) {
	OpenGestionForce(client);
	return Plugin_Handled;
}
void IncrementForceKill(int client,int victim) {
	if( client == victim ) {
		return;
	}
	g_iCurrentKill[client]++;
	
	LogToGame("[TSX-RP] [FORCE-KILL] %L tue avec la force (%i/10).", client, g_iCurrentKill[client]);
	
	int money = 250;
	int max = 10;
	CPrintToChat(client, "" ...MOD_TAG... " %T", "Force_Kill", client, money, g_iCurrentKill[client], max);
	rp_ClientMoney(client, i_Money, -money);
	
	if( g_iCurrentKill[client] >= 10 ) {
		ServerCommand("amx_ban \"#%i\" \"60\" \"%T\"", GetClientUserId(client), "Force_Ban", LANG_SERVER);
	}
}
void OpenGestionForce(int client) {
	char tmp[128];
	Handle menu = CreateMenu(SetMyForce);
	SetMenuTitle(menu, "%T\n ", "Force_Menu", client);
	
	if( g_iMayGrabAll[client] == 0 ) {
		Format(tmp, sizeof(tmp), "%T", "Force_Filter", client, "Force_Filter_Player");		AddMenuItem(menu, "grab_prop", tmp);
	}
	else if( g_iMayGrabAll[client] == 1 ) {
		Format(tmp, sizeof(tmp), "%T", "Force_Filter", client, "Force_Filter_Prop");		AddMenuItem(menu, "grab_all", tmp);
	}
	else if( g_iMayGrabAll[client] == 2 ) {
		Format(tmp, sizeof(tmp), "%T", "Force_Filter", client, "Force_Filter_All");			AddMenuItem(menu, "grab_player", tmp);
	}
	
	if( g_bMovingTeleport[client]  ) {
		Format(tmp, sizeof(tmp), "%T", "Force_Move", client, "Force_Move_Teleport");		AddMenuItem(menu, "move_velo", tmp);
	}
	else {
		Format(tmp, sizeof(tmp), "%T", "Force_Move", client, "Force_Move_Velocity");		AddMenuItem(menu, "move_tele", tmp);
	}
	
	
	if( g_bCheckSphere[client]  ) {
		Format(tmp, sizeof(tmp), "%T", "Force_Search", client, "Force_Search_Sphere");		AddMenuItem(menu, "search_aim", tmp);
	}
	else {
		Format(tmp, sizeof(tmp), "%T", "Force_Search", client, "Force_Search_Aim");			AddMenuItem(menu, "search_zone", tmp);
	}
	
	if( g_bGrabNear[client] ) {
		Format(tmp, sizeof(tmp), "%T", "Force_Distance", client, "Force_Distance_Nearby");	AddMenuItem(menu, "dist_away", tmp);
	}
	else {
		Format(tmp, sizeof(tmp), "%T", "Force_Distance", client, "Force_Distance_Away");	AddMenuItem(menu, "dist_near", tmp);
	}
	
	if( g_bToggle[client] ) {
		Format(tmp, sizeof(tmp), "%T", "Force_Toggle", client, "Force_Toggle_Alter");		AddMenuItem(menu, "toggle_off", tmp);
	}
	else {
		Format(tmp, sizeof(tmp), "%T", "Force_Toggle", client, "Force_Toggle_HOLD");		AddMenuItem(menu, "toggle_on", tmp);
	}
	
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_DURATION);
}

public int SetMyForce(Handle menu, MenuAction action, int client, int param2) {
	if( action == MenuAction_Select ) {
		char options[64];
		GetMenuItem(menu, param2, options, 63);
		
		if( StrEqual( options, "grab_player", false) ) {
			g_iMayGrabAll[client] = 0;
		}
		else if( StrEqual( options, "grab_prop", false) ) {
			g_iMayGrabAll[client] = 1;
		}
		else if( StrEqual( options, "grab_all", false) ) {
			g_iMayGrabAll[client] = 2;
		}
		else if( StrEqual( options, "move_velo", false) ) {
			g_bMovingTeleport[client] = false;
		}
		else if( StrEqual( options, "move_tele", false) ) {
			g_bMovingTeleport[client] = true;
		}
		else if( StrEqual( options, "search_zone", false) ) {
			g_bCheckSphere[client] = true;
		}
		else if( StrEqual( options, "search_aim", false) ) {
			g_bCheckSphere[client] = false;
		}
		else if( StrEqual( options, "dist_away", false) ) {
			g_bGrabNear[client] = false;
		}
		else if( StrEqual( options, "dist_near", false) ) {
			g_bGrabNear[client] = true;
		}
		else if( StrEqual( options, "toggle_off", false) ) {
			g_bToggle[client] = false;
		}
		else if( StrEqual( options, "toggle_on", false) ) {
			g_bToggle[client] = true;
		}
		OpenGestionForce(client);
	}
	else if( action == MenuAction_End ) {
		CloseHandle(menu);
	}
}

bool CheckValidGrab(int client, int result) {
	if( result > 0 && IsValidEdict(result) && IsValidEntity(result) ) {
		
		if( !MayMoveThisEntity(client, result) ) {
			return false;
		}
		if( result <= MaxClients ) {
			if( !IsAllowed_client(client) ) {
				CPrintToChat(client, "" ...MOD_TAG... " %T", "Force_Cannot_Player", client);
				return false;
			}
			if( !rp_IsEntityGrabable(client, result) ) {
				CPrintToChat(client, "" ...MOD_TAG... " %T", "Force_Cannot_Player", client);
				return false;
			}

			LogToGame("[TSX-RP] [FORCE] %L tien %L", client, result);
		}
		if( IsValidVehicle(result) && !IsAllowed_car(client, result) ) {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Force_Cannot_Car");
			return false;
		}
		
		char classname[32];
		GetEdictClassname(result, classname, sizeof(classname));
		
		if( StrContains(classname, "prop_physic", false) != -1 ) {
			if( !IsAllowed_prop(client, result) ) {
				CPrintToChat(client, "" ...MOD_TAG... " %T", "Force_Cannot_Prop", client);
				return false;
			}
		}

		
		float fOrigin1[3], fOrigin2[3];
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", fOrigin1);
		GetEntPropVector(result, Prop_Send, "m_vecOrigin", fOrigin2);
		
		g_fGrabbedLength[client] = GetVectorDistance(fOrigin1, fOrigin2);

		if( g_bGrabNear[client] && g_fGrabbedLength[client] >= 250.0 ) {
			FORCE_STOP(client);
			return false;
		}

		g_iGrabbing[client] = result;
		g_iGrabbedBy[result] = client;
		g_bIsSeeking[client] = false;
		SDKHook(g_iGrabbing[client], SDKHook_Touch, OnForceTouch);

		int flags = GetUserFlagBits(client);
		if (flags & ADMFLAG_GENERIC || flags & ADMFLAG_ROOT) {
			char name[64];
			GetEdictClassname(result, name, sizeof(name));
			CPrintToChat(client, "[FORCE] %s [%i]", name, result);
		}
		
		if( client == result ) {
			FORCE_STOP(client);
			return false;
		}
		return true;
	}
	return false;
}
public Action OnForceTouch(int entity, int touched) {
	int client = g_iGrabbedBy[entity];
	
	if( client > 0 && g_iGrabbing[client] == 0 ) {
		SDKUnhook(g_iGrabbing[client], SDKHook_Touch, OnForceTouch);
		return Plugin_Continue;
	}
	
	if( client <= 0 ) {
		// Mais qui nous grab, bordel.
		LogError("OnForceTouch with client <= 0");
		for (int i = 1; i <= MaxClients; i++) {
			if( g_iGrabbing[i] == entity ) {
				FORCE_STOP(i);
			}
		}
		return Plugin_Continue;
	}
	
	if( !IsValidVehicle(touched) )
		return Plugin_Continue;
	
	if( rp_GetVehicleInt(touched, car_owner) ==  client )
		return Plugin_Continue;
	
	//if(GetUserFlagBits(client) & ADMFLAG_GENERIC)
	//	return Plugin_Continue;
	
	if( rp_GetZoneBit(rp_GetPlayerZone(touched)) & BITZONE_PARKING ) {
		int zone = getZoneAppart(client);
		
		if( zone > 0 && g_iDoorOwner_v2[client][zone] )
			return Plugin_Continue;

		zone = StringToInt(g_szZoneList[GetPlayerZone(client)][zone_type_type]);
		if( zone != 0 && zone == GetJobPrimaryID(client) )
			return Plugin_Continue;
		
		IncrementForceKill(client, entity);
		
		FORCE_STOP(client);
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}
bool IsAllowed_client(int client) {
	int job = g_iUserData[client][i_Job];
	
	int flags = GetUserFlagBits(client);
	if (flags & ADMFLAG_GENERIC || flags & ADMFLAG_ROOT) 
		return true;
	
	if( job == rp_GetClientJobID(client) && job != 0 && g_bUserData[client][b_IsNoPyj] )
		return true;
	if( g_bUserData[client][b_IsNoPyj] && g_iUserData[client][i_PlayerLVL] >= 870 )
		return true;
	int type = rp_GetZoneInt(rp_GetPlayerZone(client), zone_type_type);
	
	if( !g_bUserData[client][b_IsNoPyj] && type != 1 && type != 101 )
		return false;
	
	if( job == 9 )
		return false;
	
	if( job >= 1 && job <= 10) {
		if( !((job == 9 || job == 8) && GetClientTeam(client) == CS_TEAM_T) )
			return true;
	}
	
	if( job >= 101 && job <= 110)
		return true;
	
	return false;
}
bool IsAllowed_car(int client, int vehicle) {
	
	if( vehicle > 0 && g_iVehicleData[vehicle][car_owner] == client)
		return true;
	
	int job = g_iUserData[client][i_Job];
	
	int flags = GetUserFlagBits(client);
	if (flags & ADMFLAG_GENERIC || flags & ADMFLAG_ROOT) 
		return true;
	
	
	if( job == 9 || job == 109)
		return false;
	if( job >= 1 && job <= 10)
		return true;
	if( job >= 101 && job <= 110)
		return true;
	
	return false;
}
bool IsAllowed_prop(int client, int entity) {
	int flags = GetUserFlagBits(client);
	if (flags & ADMFLAG_GENERIC || flags & ADMFLAG_ROOT) 
		return true;
	
	if( rp_IsEntityGrabable(client, entity) )
		return true;
	
	return false;
}
bool rp_IsEntityGrabable(int client, int entity) {
	if( IsValidClient(entity) ) {		
		return true;
	}
	
	if( rp_GetBuildingData(entity, BD_owner) == client ) {
		return true;
	}
	if( rp_GetBuildingData(entity, BD_owner) == 0 ) {
		return true;
	}
	
	return false;
}
bool MayMoveThisEntity(int client, int ent) {
	if( IsClientInJail(client) ) {
		return false;
	}
	if( IsValidClient(ent) ) {
		if( g_flLubrifian[ent] > GetGameTime() ) {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Cmd_TargetIsSlippy", client);
			return false;
		}
	}
	if( g_iMayGrabAll[client] == 0 ) {
		if( IsValidClient(ent) )
			return true;
	}
	else if( g_iMayGrabAll[client] == 1 ) {
		if( IsMoveAble(ent) )
			return true;
		if( IsValidVehicle(ent) && IsAllowed_car(client, ent) )
			return true;
		
		char classname[64];
		GetEdictClassname(ent, classname, sizeof(classname));
		if( StrContains(classname, "rp_banana") == 0 ) {
			return true;
		}
	}
	else if( g_iMayGrabAll[client] == 2 ) {
		
		char classname[64];
		GetEdictClassname(ent, classname, sizeof(classname));
		if( StrContains(classname, "_door") != -1 ) {
			return false;
		}
		
		int type = FindPropType(ent, "m_vecOrigin");
		if( type == PROPTYPE_SEND || type == PROPTYPE_BOTH ) {
			return true;
		}
	}
	
	return false;
}
int FindEntityInSphere(int client, int base, float vecOrigin[3], float range) {
	int ent = -1;
	float vecEntity[3];
	
	for(int i = base; i <= MAX_ENTITIES; i++) {
		
		if( !IsValidEdict(i) )
			continue;
		if( !IsValidEntity(i) )
			continue;
		if( !MayMoveThisEntity(client, i) ) 
			continue;
		
		GetEntPropVector(i, Prop_Send, "m_vecOrigin", vecEntity);
		
		float dist = GetVectorDistance(vecOrigin, vecEntity);
		
		if( dist >= range )
			continue;
		
		range = dist;
		ent = i;
	}
	return ent;
	
}
int FindPropType(int entity, const char[] prop) {
	if(!IsValidEntity(entity))
		return PROPTYPE_BADENT;
	
	bool NetClsName;
	int PropSend = -1, PropData = -1;
	
	char NetClass[50]="empty";
	NetClsName=GetEntityNetClass(entity,NetClass,sizeof(NetClass));
	
	
	if(NetClsName) {
		
		PropSend=FindSendPropInfo(NetClass,prop);
		
		if(PropSend != -1 && PropData != -1)
			return PROPTYPE_BOTH;
		else if(PropSend !=- 1)
			return PROPTYPE_SEND;
		else if(PropData == -1 && PropSend == -1)
			return PROPTYPE_WRONGPROP;
	}
	
	return PROPTYPE_FAILED;
}