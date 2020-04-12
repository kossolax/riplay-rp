#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <phun>
#include <colors>
#include <smlib>


public Plugin:myinfo = 
{
	name = "New Plugin",
	author = "KoSSoLaX",
	description = "<- Description ->",
	version = "0.1",
	url = "<- URL ->"
}

public OnPluginStart() {
	RegAdminCmd("rp_vehicle", CmdVehicle, ADMFLAG_ROOT);
}

public Action:CmdVehicle(client, args) {
	new Float:vecOrigin[3], Float:vecAngles[3];
	new String:arg[12], String:model[128], String:script[128];
	new skin;
	
	for(new i=0;i<3; i++) {
		GetCmdArg(1+i, arg, sizeof(arg));	vecOrigin[i] = StringToFloat(arg);
	}
	
	GetCmdArg(4, arg, sizeof(arg));			vecAngles[1] = StringToFloat(arg);
	GetCmdArg(5, model, sizeof(model));
	GetCmdArg(6, script, sizeof(script));
	GetCmdArg(7, arg, sizeof(arg));			skin = StringToInt(arg);
	
	SpawnVehicle(vecOrigin, vecAngles, model, script, skin, client);
}

SpawnVehicle(Float:spawnorigin[3], Float:spawnangles[3], const String:ModelPath[], const String:ScriptPath[], skin, client=0) {
	
	new VehicleIndex = CreateEntityByName("prop_vehicle_driveable");
	if (VehicleIndex == -1) {
		PrintToServer("********** vehiclemod: could not create vehicle entity");
		return;
	}
	
	new String:TargetName[10];
	Format(TargetName, sizeof(TargetName), "%i",VehicleIndex);
	DispatchKeyValue(VehicleIndex, "targetname", TargetName);
	
	if( PrecacheModel(ModelPath) == 0 ) {
		AcceptEntityInput(VehicleIndex, "Kill");
		
		PrintToServer("********** vehiclemod: failed to precache");
		return;
	}
	
	DispatchKeyValue(VehicleIndex, "model", ModelPath);
	DispatchKeyValue(VehicleIndex, "vehiclescript", ScriptPath);
	
	SetEntProp(VehicleIndex, Prop_Send, "m_nSolidType", SOLID_VPHYSICS);
	SetEntProp(VehicleIndex, Prop_Send, "m_nSkin", skin);
	DispatchSpawn(VehicleIndex);
	ActivateEntity(VehicleIndex);
	
	// stops the vehicle rolling back when it is spawned.
	SetEntProp(VehicleIndex, Prop_Data, "m_nNextThinkTick", -1);
	
	
	// check if theres space to spawn the vehicle.
	new Float:MinHull[3];
	new Float:MaxHull[3];
	GetEntPropVector(VehicleIndex, Prop_Send, "m_vecMins", MinHull);
	GetEntPropVector(VehicleIndex, Prop_Send, "m_vecMaxs", MaxHull);
	
	new Float:temp;
	
	temp = MinHull[0];
	MinHull[0] = MinHull[1];
	MinHull[1] = temp;
	
	temp = MaxHull[0];
	MaxHull[0] = MaxHull[1];
	MaxHull[1] = temp;
	
	if (client == 0) {
		TR_TraceHull(spawnorigin, spawnorigin, MinHull, MaxHull, MASK_SOLID);
	}
	else {
		TR_TraceHullFilter(spawnorigin, spawnorigin, MinHull, MaxHull, MASK_SOLID, RayDontHitClient, client);
	}
	
	if (TR_DidHit()) {
		AcceptEntityInput(VehicleIndex, "Kill");
		
		PrintToServer("********** vehiclemod: spawn coordinates not clear");
		return;
	}
	
	TeleportEntity(VehicleIndex, spawnorigin, spawnangles, NULL_VECTOR);
	
	SetEntProp(VehicleIndex, Prop_Data, "m_takedamage", 0);
	
	// force players in.
	if (client != 0) {
		AcceptEntityInput(VehicleIndex, "use", client);
	}
}
public bool:RayDontHitClient(entity, contentsMask, any:data)
{
	return (entity != data);
}
