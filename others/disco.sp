#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>
#include <colors_csgo>	// https://forums.alliedmods.net/showthread.php?p=2205447#post2205447
#include <smlib>		// https://github.com/bcserv/smlib
#include <emitsoundany> // https://forums.alliedmods.net/showthread.php?t=237045

#pragma newdecls required
#include <roleplay.inc>	// https://www.ts-x.eu

#define FCT RoundFloat(GetTickedTime() * 5.0)

bool g_bEntityManaged[2049] =  { false, ... };

public void OnPluginStart() {
	RegAdminCmd("sm_effect_id", Cmd_MyId, ADMFLAG_KICK);
	RegAdminCmd("sm_effect_ball", Cmd_Ball, ADMFLAG_KICK);
	RegAdminCmd("sm_effect_smoke", Cmd_Smoke, ADMFLAG_KICK);
}
public void OnMapStart() {
	PrecacheModel("models/props/cs_office/projector.mdl");
	PrecacheModel("models/props_junk/watermelon01.mdl");
}
public Action Cmd_MyId(int client, int args) {
	for (int i = 1; i < MaxClients; i++) {
		if( IsClientInGame(i) )
			ReplyToCommand(client, "%N: %d", i, i);
	}
}
public Action Cmd_Smoke(int client, int args) {
	char tmp[64];
	float pos[3], ang[3];
	
	int target = GetCmdArgInt(1);
	if( target == 0 || target > MaxClients || !IsClientInGame(target) )
		target = client;
	
	int color[3];
	if (args >= 4) {
		color[0] = GetCmdArgInt(2);
		color[1] = GetCmdArgInt(3);
		color[2] = GetCmdArgInt(4);
	}
	else {
		color[0] = GetRandomInt(0, 255);
		color[1] = GetRandomInt(0, 255);
		color[2] = GetRandomInt(0, 255);
	}
	
	Entity_GetAbsOrigin(target, pos);
	Entity_GetAbsAngles(target, ang);
	pos[2] += 32.0;
	ang[1] += 90.0;
	
	int parent = CreateEntityByName("prop_physics");
	DispatchKeyValue(parent, "model", "models/props/cs_office/projector.mdl");
	DispatchKeyValue(parent, "classname", "rp_discosmoke");
	
	TeleportEntity(parent, pos, ang, NULL_VECTOR);
	
	DispatchSpawn(parent);
	ActivateEntity(parent);
	
	int ent = CreateEntityByName("env_smokestack");
	DispatchKeyValueVector(ent, "origin", pos);
	DispatchKeyValueVector(ent, "angles", ang);
	DispatchKeyValue(ent, "BaseSpread", "0");
	DispatchKeyValue(ent, "SpreadSpeed", "10");
	DispatchKeyValue(ent, "Speed", "10");
	DispatchKeyValue(ent, "StartSize", "1");
	DispatchKeyValue(ent, "EndSize", "128");
	DispatchKeyValue(ent, "Rate", "8");
	DispatchKeyValue(ent, "SmokeMaterial", "particle/particle_smokegrenade.vmt");
	Format(tmp, sizeof(tmp), "%d %d %d", color[0], color[1], color[2]);
	DispatchKeyValue(ent, "rendercolor", tmp);
	DispatchKeyValue(ent, "renderamt", "64");
	DispatchKeyValue(ent, "InitialState", "1");
	DispatchKeyValue(ent, "WindAngle", "90");
	DispatchKeyValue(ent, "WindSpeed", "30");
	DispatchKeyValue(ent, "JetLength", "64");
	
	TeleportEntity(ent, pos, ang, NULL_VECTOR);
	
	DispatchSpawn(ent);
	ActivateEntity(ent);
	
	SetVariantString("!activator");
	AcceptEntityInput(ent, "SetParent", parent);
	
	TeleportEntity(ent, view_as<float>( { 0.0, -16.0, 0.0 } ), NULL_VECTOR, NULL_VECTOR);
	
	SDKHook(parent, SDKHook_VPhysicsUpdate, OnThink);
	SetEntPropEnt(parent, Prop_Data, "m_hEffectEntity", ent);
	
	
	SetEntPropEnt(parent, Prop_Send, "m_hOwnerEntity", target);
	SetEntProp(parent, Prop_Data, "m_takedamage", 2);
	SetEntProp(parent, Prop_Data, "m_iHealth", 1000);
	rp_SetBuildingData(parent, BD_started, GetTime());
	rp_SetBuildingData(parent, BD_owner, target );
	rp_SetBuildingData(parent, BD_FromBuild, 0);
	
	return Plugin_Handled;
}
public void OnThink(int parent) {
	float ang[3];
	char tmp[8];
	int ent = GetEntPropEnt(parent, Prop_Data, "m_hEffectEntity");
	GetEntPropVector(parent, Prop_Data, "m_angAbsRotation", ang);
	
	if (ang[2] > 45.0 || ang[2] < -45.0) {
		ang[0] = ang[2] = 0.0;
		TeleportEntity(parent, NULL_VECTOR, ang, NULL_VECTOR);
	}
	
	Format(tmp, sizeof(tmp), "%d", RoundFloat(ang[1]) - 90);
	DispatchKeyValue(ent, "WindAngle", tmp);
}
public Action Cmd_Ball(int client, int args) {
	float pos[3], ang[3];
	char tmp[32];
	int color[3];
	
	int target = GetCmdArgInt(1);
	if( target == 0 || target > MaxClients || !IsClientInGame(target) )
		target = client;
	
	int cpt = GetCmdArgInt(2);
	if (cpt < 1 || cpt > 32)
		cpt = 8;
	if (args >= 5) {
		color[0] = GetCmdArgInt(3);
		color[1] = GetCmdArgInt(4);
		color[2] = GetCmdArgInt(5);
	}
	
	Entity_GetAbsOrigin(target, pos);
	pos[2] += 128.0;
	
	int parent = CreateEntityByName("func_rotating");
	DispatchKeyValue(parent, "maxspeed", "128");
	DispatchKeyValue(parent, "friction", "0");
	DispatchKeyValue(parent, "solid", "0");
	DispatchKeyValue(parent, "spawnflags", "64");
	DispatchSpawn(parent);
	TeleportEntity(parent, pos, NULL_VECTOR, NULL_VECTOR);	
	AcceptEntityInput(parent, "Start");
	
	int node = CreateEntityByName("prop_physics");
	DispatchKeyValue(node, "classname", "rp_discoball");
	DispatchKeyValue(node, "model", "models/props_junk/watermelon01.mdl");
	DispatchKeyValue(node, "rendercolor", "0 0 0");
	DispatchKeyValue(node, "renderamt", "0");
	DispatchKeyValue(node, "rendermode", "3");
	DispatchSpawn(node);
	TeleportEntity(node, pos, NULL_VECTOR, NULL_VECTOR);
	SetVariantString("!activator");
	AcceptEntityInput(parent, "SetParent", node);
	SetEntPropEnt(node, Prop_Data, "m_hEffectEntity", parent);
	
	SetEntityMoveType(node, MOVETYPE_NONE);
	
	g_bEntityManaged[node] = true;
	
	ang[0] = 30.0;
	
	for (int i = 0; i < cpt; i++) {
		ang[1] += (360.0 / float(cpt));
		
		int ent = CreateEntityByName("point_spotlight");
		
		if (args < 5) {
			color[0] = GetRandomInt(0, 255);
			color[1] = GetRandomInt(0, 255);
			color[2] = GetRandomInt(0, 255);
		}
		
		Format(tmp, sizeof(tmp), "%d %d %d", color[0], color[1], color[2]);
		DispatchKeyValue(ent, "rendercolor", tmp);
		DispatchKeyValue(ent, "renderamt", "255");
		
		DispatchKeyValue(ent, "spotlightwidth", "8");
		DispatchKeyValue(ent, "spotlightlength", "512");
		DispatchKeyValue(ent, "spawnflags", "3");
		
		DispatchSpawn(ent);
		TeleportEntity(ent, pos, ang, NULL_VECTOR);
		SetVariantString("!activator");
		AcceptEntityInput(ent, "SetParent", parent);
		
		SDKHook(ent, SDKHook_Think, fwdThink);
	}
	
	int ent = CreateEntityByName("env_projectedtexture");
	DispatchKeyValue(ent, "nearz", "16");
	DispatchKeyValue(ent, "farz", "2048");
	DispatchKeyValue(ent, "texturename", "effects/flashlight001");
	
	if (args < 5)
		color[0] = color[1] = color[2] = 255;
	
	Format(tmp, sizeof(tmp), "%d %d %d 10", color[0], color[1], color[2]);
	DispatchKeyValue(ent, "lightcolor", tmp);
	DispatchKeyValue(ent, "spawnflags", "3");
	DispatchKeyValue(ent, "lightfov", "130");
	DispatchKeyValue(ent, "brightnessscale", "50");
	DispatchKeyValue(ent, "lightworld", "1");
	if (GetCmdArgInt(6) == 42) {
		DispatchKeyValue(ent, "shadowquality", "0");
		DispatchKeyValue(ent, "enableshadows", "1");
	}
	DispatchSpawn(ent);
	TeleportEntity(ent, pos, view_as<float>( { 90.0, 0.0, 0.0 } ), NULL_VECTOR);
	
	SetVariantString("!activator");
	AcceptEntityInput(ent, "SetParent", node);
	
	SetEntPropEnt(node, Prop_Send, "m_hOwnerEntity", target);
	SetEntProp(node, Prop_Data, "m_takedamage", 2);
	SetEntProp(node, Prop_Data, "m_iHealth", 1000);
	rp_SetBuildingData(node, BD_started, GetTime());
	rp_SetBuildingData(node, BD_owner, target );
	rp_SetBuildingData(node, BD_FromBuild, 0);
	
	return Plugin_Handled;
}
public void OnEntityDestroyed(int entity) {
	if(entity <= 0 || entity > sizeof(g_bEntityManaged)) {
		return;
	}
	
	if (g_bEntityManaged[entity]) {
		g_bEntityManaged[entity] = false;
		
		int root = GetEntPropEnt(entity, Prop_Data, "m_hEffectEntity");
		char tmp[64];
		for (int i = MaxClients; i <= 2048; i++) {
			if (!IsValidEdict(i) || !IsValidEntity(i))
				continue;
				
			GetEdictClassname(i, tmp, sizeof(tmp));
			if ( (StrEqual(tmp, "point_spotlight") || StrEqual(tmp, "beam") ||  StrEqual(tmp, "spotlight_end") ) && Entity_GetParent(i) == root) {
				int p = GetEntPropEnt(i, Prop_Data, "m_hEffectEntity");
				if (p > 0) {
					AcceptEntityInput(p, "KillHierarchy");
					int k = GetEntPropEnt(p, Prop_Data, "m_hEndEntity");
					if( k > 0 )
						AcceptEntityInput(k, "KillHierarchy");
				}
				AcceptEntityInput(i, "KillHierarchy");
			}
		}
		AcceptEntityInput(entity, "KillHierarchy");
	}
}
public void fwdThink(int ent) {
	int p = GetEntPropEnt(ent, Prop_Data, "m_hEffectEntity");
	
	if (p == -1) {
		char tmp[64];
		for (int i = MaxClients; i <= 2048; i++) {
			if (!IsValidEdict(i) || !IsValidEntity(i))
				continue;
			
			GetEdictClassname(i, tmp, sizeof(tmp));
			if (StrEqual(tmp, "beam")) {
				int j = GetEntPropEnt(i, Prop_Data, "m_hAttachEntity");
				if (j == ent) {
					SetEntPropEnt(ent, Prop_Data, "m_hEffectEntity", i);
					p = i;
				}
			}
		}
	}
	
	if (p > 0) {
		float s = 8.0 + (32.0 * OctavePerlin(FCT, 8, 2, 8.0, 2.0));
		SetEntPropFloat(p, Prop_Send, "m_fWidth", s);
	}
}

float perlin(int n) {
	n = (n << 13) ^ n;
	float r = (1.0 - ((n * ((n * n * 15731) + 789221) + 1376312589) & 0x7fffffff) / 1073741824.0);
	return (r + 1.0) / 2.0;
}
public float OctavePerlin(int x, int frequency, int octaves, float persistence, float amplitude) {
	float total = 0.0;
	float maxValue = 0.0;
	
	for (int i = 0; i < octaves; i++) {
		total += perlin(x * frequency) * amplitude;
		
		maxValue += amplitude;
		
		amplitude *= persistence;
		frequency *= 2;
	}
	
	return total / maxValue;
}