#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <smlib>
#pragma dynamic 65536


public Plugin:myinfo = 
{
	name = "EntityDump",
	author = "KoSSoLaX`",
	description = "Entity dump info",
	version = "1.0",
	url = "http://www.ts-x.eu/"
}

public OnPluginStart() {
	RegAdminCmd("db_dump", CmdEntityDump, ADMFLAG_BAN, "");
	RegAdminCmd("db_bomb", CmdDump, ADMFLAG_BAN);
	
}
public Action:CmdDump(client, args) {
	
	new Float:mins[3] = {9526.0, 5015.0, -1762.0};
	new Float:maxs[3] = {9736.0, 5115.0, -1612.0};
	new Float:center[3];
	
	for(new i=0; i<3; i++) {
		center[i] = (mins[i]+maxs[i])/2.0;
		mins[i] = center[i] - maxs[i];
		maxs[i] = -mins[i];
	}
	
	PrintToConsole(client, "======");
	PrintToConsole(client, "%.2f %.2f %.2f", center[0], center[1], center[2]);
	PrintToConsole(client, "%.2f %.2f %.2f", mins[0], mins[1], mins[2]);
	PrintToConsole(client, "%.2f %.2f %.2f", maxs[0], maxs[1], maxs[2]);
	PrintToConsole(client, "======");
	
	new ent = CreateEntityByName("func_bomb_target");
	DispatchKeyValue(ent, "pushdir", "0 90 0");
	DispatchKeyValue(ent, "speed", "500");
	DispatchKeyValue(ent, "spawnflags", "64");
	
	DispatchSpawn(ent);
	ActivateEntity(ent);
	
	TeleportEntity(ent, center, NULL_VECTOR, NULL_VECTOR);
	PrecacheModel("models/props_c17/cashregister01a.mdl", true);
	SetEntityModel(ent, "models/props_c17/cashregister01a.mdl");
	
	SetEntPropVector(ent, Prop_Send, "m_vecMins", mins);
	SetEntPropVector(ent, Prop_Send, "m_vecMaxs", maxs);
	
	SetEntProp(ent, Prop_Send, "m_nSolidType", 2);
	
	new enteffects = GetEntProp(ent, Prop_Send, "m_fEffects");
	enteffects |= 32;
	SetEntProp(ent, Prop_Send, "m_fEffects", enteffects);

	return Plugin_Handled;
}
public bool:IsValidDoor(Ent) {
	
	if(!IsValidEdict(Ent))
		return false;
	
	if( !IsValidEntity(Ent) )
		return false;
	
	decl String:ClassName[128];
	GetEdictClassname(Ent, ClassName, 127);
	
	if(StrEqual(ClassName, "func_door_rotating") || StrEqual(ClassName, "prop_door_rotating") || StrEqual(ClassName, "func_door"))
		return true;
	
	return false;
}
public OnEntityCreated(ent, const String:classname[])  {
	static count = 0;
	
	if( StrContains(classname, "prop_dynamic") == 0 ) {
		new team = GetEntProp(ent, Prop_Data, "m_iTeamNum");
		if( team == -500 ) {
			count++;
			PrintToServer("removed %i (%i)", ent, count);
			RemoveEdict(ent)
		}
	}
}
public Action:CmdEntityDump(client, args) {
	
	new amount, String:error[1024];
	
	new Handle:bdd = SQL_Connect("default", false, error, sizeof(error));
	SQL_LockDatabase(bdd);
	SQL_Query(bdd, "DELETE FROM `rp_csgo`.`rp_dump`");
	
	for( new i=1; i<= 2049; i++) {
		if( !IsValidEdict(i) )
			continue;
		if( !IsValidEntity(i) )
			continue;
		
		amount++;
		
		new String:classname[64];
		Entity_GetClassName(i, classname, sizeof(classname));
		new String:model[256];
		Entity_GetModel(i, model, sizeof(model));
		//GetEntPropString(i, Prop_Data, "m_iName", model, 128);
		
		new String:query[1024];
		Format(query, sizeof(query), "INSERT INTO `rp_csgo`.`rp_dump` (`id`, `name`, `model`) VALUES ('%i', '%s', '%s');", i, classname, model);
		
		SQL_Query(bdd, query);
		
	}
	SQL_UnlockDatabase(bdd);
	CloseHandle(bdd);
	
	PrintToConsole(client, "Entity amount: %i", amount);
	
	return Plugin_Handled;
}
