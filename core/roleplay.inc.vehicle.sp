#if defined _roleplay_vehicle_included
#endinput
#endif
#define _roleplay_vehicle_included

#if defined ROLEPLAY_SUB
	#include "../roleplay.sp"
#else
	#include "roleplay.sp"
#endif

public Action AllowCarAction(Handle timer, any client) {
	g_iMayCarAction[client] = 1;
}
public bool FilterToVehicle(int entity, int mask, any data) {
	return IsValidVehicle(entity);
}
bool IsValidVehicle(int car) {
	if( !IsValidEdict(car) )
		return false;
	if( !IsValidEntity(car) )
		return false;

	if( StrContains(g_szEntityName[car], "prop_vehicle_", false) == 0 )
		return true;
	
	return false;
}
int LookupAttachment(int entity, char[] point) {
	if( g_hLookupAttachment == INVALID_HANDLE ) {
		
		Handle hGameConf = LoadGameConfigFile("roleplay.gamedata");
		StartPrepSDKCall(SDKCall_Entity);
		PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "LookupAttachment");
		PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
		PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
		g_hLookupAttachment = EndPrepSDKCall();
		
		CloseHandle(hGameConf);
		if( g_hLookupAttachment == INVALID_HANDLE )
			return -1;
	}
	
	return SDKCall(g_hLookupAttachment, entity, point);
}

void rp__SetClientVehicle(int client, int vehicleID, bool force=false) {
	
	if( !rp_GetClientKeyVehicle(client, vehicleID) )
		return;
	
	if( LookupAttachment(client, "legacy_weapon_bone") <= 0 ) {
		SetEntityModel(client, "models/player/custom_player/legacy/tm_phoenix.mdl");
	}
	
	if( force ) { }
	
	rp_ClientGiveHands(client);
	
	SetEntProp(vehicleID, Prop_Data, "m_bLocked", 0);
	rp_AcceptEntityInput(vehicleID, "Use", client);
	rp_ScheduleEntityInput(vehicleID, 0.1, "Lock");
	
	int iFlags = GetEntProp(client, Prop_Send, "m_fEffects") & (~EF_NODRAW);
	SetEntProp(client, Prop_Send, "m_fEffects", iFlags | EF_BONEMERGE | EF_NOSHADOW | EF_NOINTERP | EF_BONEMERGE_FASTCULL | EF_PARENT_ANIMATES );
	SetEntProp(client, Prop_Send, "m_CollisionGroup", COLLISION_GROUP_NONE);
	
	ClientCommand(client, "cam_idealpitch 65");	
	ClientCommand(client, "thirdperson");
}
void ExitVehicle(int client, int vehicleID, bool forced=false) {
	
	float ExitPoint[3];
	if( GetExitPoint(client, vehicleID, forced, ExitPoint) == false )
		return;
	
	SetEntProp(vehicleID, Prop_Data, "m_bLocked", 0);
	
	rp_AcceptEntityInput(client, "ClearParent");
	
	SetEntPropEnt(client, Prop_Send, "m_hVehicle", -1);
	SetEntPropEnt(vehicleID, Prop_Send, "m_hPlayer", -1);
	
	SetEntityMoveType(client, MOVETYPE_WALK);
	SetEntProp(client, Prop_Send, "m_CollisionGroup", COLLISION_GROUP_PLAYER);
	
	int hud = GetEntProp(client, Prop_Send, "m_iHideHUD");
	hud &= ~HIDEHUD_WEAPONSELECTION; hud &= ~HIDEHUD_CROSSHAIR; hud &= ~HIDEHUD_INVEHICLE;
	SetEntProp(client, Prop_Send, "m_iHideHUD", hud);

	int EntEffects = GetEntProp(client, Prop_Send, "m_fEffects") & (~EF_NODRAW) & (~EF_BONEMERGE) & (~EF_NOSHADOW) & (~EF_NOINTERP) & (~EF_BONEMERGE_FASTCULL) & (~EF_PARENT_ANIMATES);
	SetEntProp(client, Prop_Send, "m_fEffects", EntEffects);
	SetEntProp(client, Prop_Send, "m_bDrawViewmodel", 1);
	SetEntProp(vehicleID, Prop_Send, "m_nSpeed", 0);
	SetEntPropFloat(vehicleID, Prop_Send, "m_flThrottle", 0.0);
	
	char model[128];
	Entity_GetModel(client, model, sizeof(model));
						
	if( StrContains(model, "sprisioner", false) != -1 ) {
		SetEntityModel(client, "models/player/custom_player/legacy/sprisioner/sprisioner.mdl");
	}
	else {
		rp_ClientResetSkin(client);
	}
	Colorize(client, 255, 255, 255, 255);
	
	SetEntPropFloat(client, Prop_Send, "m_flFallVelocity", 0.0);
	int flags = GetEntityFlags(client);
	SetEntityFlags(client, (flags&~FL_ONGROUND) );
	SetEntPropEnt(client, Prop_Send, "m_hGroundEntity", -1);
	SetEntProp(client, Prop_Data, "m_takedamage", 2);
	float ExitAng[3];	
	GetEntPropVector(vehicleID, Prop_Data, "m_angRotation", ExitAng);
	ExitAng[0] = ExitAng[2] = 0.0;
	ExitAng[1] += 90.0;
	
	TeleportClient(client, ExitPoint, ExitAng, view_as<float>({0.0, 0.0, 0.0}));
	
	SetClientViewEntity(client, client);
	SetEntPropFloat(client, Prop_Send, "m_flModelScale", g_flUserData[client][fl_Size] );
	CreateTimer(0.001, BashFirstPerson, client);
	
	rp_ClientGiveHands(client);
	rp_AcceptEntityInput(vehicleID, "Lock");
	rp_AcceptEntityInput(vehicleID, "TurnOff");
	
	if( g_iUserData[client][i_ThirdPerson] == 0 )
		ClientCommand(client, "firstperson");
		
	for(int i=1; i<=MaxClients; i++) {
		if( !IsValidClient(i) )
			continue;
		if( g_iCarPassager[vehicleID][i] )
			LeaveVehiclePassager(i, vehicleID);
	}
}
bool GetExitPoint(int client, int vehicle, bool forced, float ExitPoint[3]) {
	
	float vector[3];
	
	for (float v = 0.0; v <= 180.0; v+= 10.0 ) {
		
		vector[1] = (90.0 + v);
		if( vector[1] > 180.0 )
			vector[1] -= 180.0;
		
		if ( IsExitClear(client, vehicle, vector, ExitPoint) ) 
			return true;
		
		vector[1] = -vector[1];
		if ( IsExitClear(client, vehicle, vector, ExitPoint) ) 
			return true;
	}
	
	if ( IsExitClear(client, vehicle, view_as<float>({90.0, 0.0, 0.0}), ExitPoint, forced) )
		return true;
		
	return false;
}
bool IsExitClear(int client, int vehicle, float direction[3], float exitpoint[3], bool force = false) {

	float ClientEye[3], VehicleAngle[3], ClientMinHull[3], ClientMaxHull[3], DirectionVec[3], TraceEnd[3], CollisionPoint[3], VehicleEdge[3];
	float maxDist = 8.0;
	if( force )
		maxDist = 100.0;
	
	Entity_GetAbsOrigin(vehicle, ClientEye);
	Entity_GetAbsAngles(vehicle, VehicleAngle);
	ClientEye[2] += 16.0;
	GetEntPropVector(client, Prop_Send, "m_vecMins", ClientMinHull);
	GetEntPropVector(client, Prop_Send, "m_vecMaxs", ClientMaxHull);
	
	for (int i = 0; i <= 2; i++)
		VehicleAngle[i] += direction[i];
	
	
	GetAngleVectors(VehicleAngle, NULL_VECTOR, DirectionVec, NULL_VECTOR);
	ScaleVector(DirectionVec, -160.0);
	AddVectors(ClientEye, DirectionVec, TraceEnd);
	
	TR_TraceHullFilter(ClientEye, TraceEnd, ClientMinHull, ClientMaxHull, MASK_PLAYERSOLID, DontHitClientOrVehicle, client);
	
	if (TR_DidHit()) 
		TR_GetEndPosition(CollisionPoint);
	else 
		CollisionPoint = TraceEnd;
	
	TR_TraceHull(CollisionPoint, ClientEye, ClientMinHull, ClientMaxHull, MASK_PLAYERSOLID);
	TR_GetEndPosition(VehicleEdge);
	
	float ClearDistance = GetVectorDistance(VehicleEdge, CollisionPoint);
	
	
	if( ClearDistance >= maxDist ) {
		MakeVectorFromPoints(VehicleEdge, CollisionPoint, DirectionVec);
		NormalizeVector(DirectionVec, DirectionVec);
		ScaleVector(DirectionVec, maxDist);
		
		AddVectors(VehicleEdge, DirectionVec, exitpoint);
		
		if (TR_PointOutsideWorld(exitpoint)) {
			if( force ) {
					GetClientAbsOrigin(client, exitpoint);
					exitpoint[2] += 30.0;
			}
			else {
				return false;
			}
		}
	}
	else {
		if( force ) {
			GetClientAbsOrigin(client, exitpoint);
			exitpoint[2] += 30.0;
		}
		else {
			return false;
		}
	}
	return true;	
}


void LeaveVehiclePassager(int client, int vehicle=-1) {
	
	LogToGame("[DEBUG] [VEHICLE] %d left %d", client, vehicle);
	
	int min = 0, max = 2048;
	if( vehicle != -1 ) {
		min = max = vehicle;
	}
	
	for(int car=min; car<=max; car++) {
		if( g_iCarPassager[car][client] == 0 )
			continue;
		
		
		SetEntProp(client, Prop_Send, "m_bDrawViewmodel", 1);
		ClientCommand(client, "cam_idealpitch 0");
		rp_AcceptEntityInput(client, "ClearParent");
		rp_AcceptEntityInput(g_iCarPassager[car][client], "Kill");
		SetEntProp(client, Prop_Send, "m_CollisionGroup", COLLISION_GROUP_PLAYER);
		
		int EntEffects = GetEntProp(client, Prop_Send, "m_fEffects") & (~EF_NODRAW) & (~EF_BONEMERGE) & (~EF_NOSHADOW) & (~EF_NOINTERP) & (~EF_BONEMERGE_FASTCULL) & (~EF_PARENT_ANIMATES);
		SetEntProp(client, Prop_Send, "m_fEffects", EntEffects);
		 
		
		g_iCarPassager[car][client] = 0;
		if( g_iUserData[client][i_ThirdPerson] == 0 )
			ClientCommand(client, "firstperson");
		
		for (int j = 0; j < sizeof(g_iCarPassager1[]); j++) {
			if( g_iCarPassager1[car][j] == client )
				g_iCarPassager1[car][j] = 0;
		}
		
		if( IsInPVP(client) )
			GroupColor(client);
		else
			Colorize(client, 255, 255, 255, 255);
		
		SetEntProp(client, Prop_Data, "m_takedamage", 2);
		SetEntityMoveType(client, MOVETYPE_WALK);
		
		if( IsValidClient(client) && IsValidVehicle(car) ) {
			g_iCarPassager2[client] = car;
			float ExitPoint[3];
			GetExitPoint(client, car, true, ExitPoint);
			
			SetClientViewEntity(client, client);
			TeleportClient(client, ExitPoint, NULL_VECTOR, vecNull);
			
			g_iCarPassager2[client] = 0;
		}
		else if( IsValidClient(client) && !IsValidVehicle(car) ) {
			
			SDKHooks_TakeDamage(client, client, client, 1000.0);
		}
	}
}
bool IsInVehicle(int client) {
	int car = GetEntPropEnt(client, Prop_Send, "m_hVehicle");	
	if( car > 0 || g_iCarPassager2[client] > 0 )
		return true;
		
	return false;
}
public Action BashFirstPerson(Handle timer, any client) {
	SetEntPropFloat(client, Prop_Send, "m_flModelScale", g_flUserData[client][fl_Size]);
	SetClientViewEntity(client, client);
}
public bool DontHitClientOrVehicle(int entity, int contentsMask, any data) {
	int InVehicle = GetEntPropEnt(data, Prop_Send, "m_hVehicle");
	if( InVehicle == -1 )
		InVehicle = g_iCarPassager2[data];
	
	if( entity == data )
		return false;
	if( entity == InVehicle )
		return false;
	if( InVehicle > 0 && IsValidClient(entity) ) {
		if( g_iCarPassager[InVehicle][entity] )
			return false;
		
		if( GetEntPropEnt(entity, Prop_Send, "m_hVehicle") == InVehicle )
			return false;
	}
	char classname[64];
	GetEdictClassname(entity, classname, sizeof(classname));
	if( StrEqual(classname, "notsolid") )
		return false;
	if( StrEqual(classname, "ctf_flag") )
		return false;
	
	return true;
}
public void vehicle_OnPreThinkPost(int client) {
	static WasInVehicle[MAXPLAYERS + 1];
	
	int InVehicle = GetEntPropEnt(client, Prop_Send, "m_hVehicle");
	
	if (InVehicle == -1) {
		if (WasInVehicle[client] != 0) {
			if (IsValidEdict(WasInVehicle[client]) && IsValidVehicle(WasInVehicle[client]) ) {
				SendConVarValue(client, FindConVar("sv_client_predict"), "1");
				SetEntProp(WasInVehicle[client], Prop_Send, "m_iTeamNum", 0);
				ClientCommand(client, "cam_idealpitch 0");
			}
			WasInVehicle[client] = 0;
		}
		return;
	}
	else {
		if( WasInVehicle[client] == 0 ) {
			if( !rp_GetClientKeyVehicle(client, InVehicle) ) {
				ExitVehicle(client, InVehicle, true);
				CPrintToChat(client, "" ...MOD_TAG... " Vous n'avez pas les clés de cette voiture.");
				rp_AcceptEntityInput(InVehicle, "Lock");
			}
			ClientCommand(client, "cam_idealpitch 65");
			SendConVarValue(client, FindConVar("sv_client_predict"), "0");
			SetEntityMoveType(client, MOVETYPE_NONE);
			
			WasInVehicle[client] = InVehicle;
		}
		int speed = GetEntProp(InVehicle, Prop_Data, "m_nSpeed");
		if( speed == 0 ) {
			rp_AcceptEntityInput(InVehicle, "TurnOn");
			rp_AcceptEntityInput(InVehicle, "HandBrakeOff");
		}
		g_iGrabbing[client] = 0;
	}
}