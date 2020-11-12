/*
 * Cette oeuvre, création, site ou texte est sous licence Creative Commons Attribution
 * - Pas d’Utilisation Commerciale
 * - Partage dans les Mêmes Conditions 4.0 International. 
 * Pour accéder à une copie de cette licence, merci de vous rendre à l'adresse suivante
 * http://creativecommons.org/licenses/by-nc-sa/4.0/ .
 *
 * Merci de respecter le travail fourni par le ou les auteurs 
 * https://www.ts-x.eu/ - kossolax@ts-x.eu
 */
#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>
#include <basecomm>
#include <topmenus>
#include <smlib>		// https://github.com/bcserv/smlib
#include <colors_csgo>	// https://forums.alliedmods.net/showthread.php?p=2205447#post2205447
#include <emitsoundany> // https://forums.alliedmods.net/showthread.php?t=237045

#pragma newdecls required
#include <roleplay.inc>	// https://www.ts-x.eu


#define TREE_HP				1
#define TREE_RESPAWN_MIN	3.0
#define TREE_RESPAWN_MAX	5.0


char g_szTrees[][] = {
	"models/props/hr_massive/hr_foliage/birch_tree_01.mdl",
	"models/props/hr_massive/hr_foliage/birch_tree_02.mdl",
	"models/props/de_inferno/tree_large.mdl"
};
char g_szWoodGibs[][] = {
	"models/props/de_inferno/hr_i/wood_beam_a/wood_beam_a1.mdl"
};

int g_iTreeID[2049];

public void OnMapStart() {
	for (int i = 0; i < sizeof(g_szTrees); i++) {
		PrecacheModel(g_szTrees[i]);
	}
	for (int i = 0; i < sizeof(g_szWoodGibs); i++) {
		PrecacheModel(g_szWoodGibs[i]);
	}
}
public void OnPluginStart() {
	HookEvent("round_start", 		EventRoundStart, 	EventHookMode_Post);
	OnRoundStart();
}
public Action EventRoundStart(Handle ev, const char[] name, bool  bd) {
	OnRoundStart();

	return Plugin_Continue;
}
public void OnRoundStart() {
	char tmp[256];
	for(int i=0; i<MAX_ENTITIES; i++) {
		if( !IsValidEdict(i) )
			continue;
		if( !IsValidEntity(i) )
			continue;
		
		GetEdictClassname(i, tmp, sizeof(tmp));
		if( StrContains(tmp, "rp_tree") == 0 || StrContains(tmp, "rp_wood") == 0 ) {
			rp_AcceptEntityInput(i, "Kill");
		}
	}
	
	for (int i = 0; i < MAX_LOCATIONS; i++) {
		rp_GetLocationData(i, location_type_base, tmp, sizeof(tmp));
		
		if( StrEqual(tmp, "tree") ) {
			CreateTimer(GetRandomFloat(0.0, 3.0), SpawnTree, i);
		}
	}
}

public Action SpawnTree(Handle timer, any i) {
	float pos[3], ang[3], min[3], max[3];
	pos[0] = float(rp_GetLocationInt(i, location_type_origin_x));
	pos[1] = float(rp_GetLocationInt(i, location_type_origin_y));
	pos[2] = float(rp_GetLocationInt(i, location_type_origin_z));
	
	
	int rnd = GetRandomInt(0, sizeof(g_szTrees) - 1);
	
	int ent = CreateEntityByName("prop_physics");
	DispatchKeyValue(ent, "model", g_szTrees[rnd]);
	DispatchKeyValue(ent, "solid", "6");
	DispatchKeyValue(ent, "classname", "rp_tree");
	DispatchSpawn(ent);
	ActivateEntity(ent);
	
	ang[1] += GetRandomFloat(-180.0, 180.0);
	
	Entity_GetMinSize(ent, min);
	Entity_GetMaxSize(ent, max);
	
	int size = RoundFloat(max[2] - min[2]);
	SetEntProp(ent, Prop_Data, "m_iHealth", size*TREE_HP);
	Entity_SetMaxHealth(ent, size*TREE_HP);
	
	SDKHook(ent, SDKHook_OnTakeDamage, OnTreeDamage);
	SDKHook(ent, SDKHook_VPhysicsUpdate, OnTreeThink);

	rp_AcceptEntityInput(ent, "DisableMotion");
	rp_AcceptEntityInput(ent, "DisableCollision" );
	rp_AcceptEntityInput(ent, "EnableCollision" );
	
	TeleportEntity(ent, pos, ang, NULL_VECTOR);
	ServerCommand("sm_effect_fading %d 1 0", ent);
	g_iTreeID[ent] = i;
}
public void OnEntityCreated(int entity, const char[] classname) {
	if( entity > 0 ) {
		g_iTreeID[entity] = 0;
	}
}
public void OnEntityDestroyed(int entity) {
	if( entity > 0 && g_iTreeID[entity] > 0 ) {
		CreateTimer(GetRandomFloat(TREE_RESPAWN_MIN, TREE_RESPAWN_MAX), SpawnTree, g_iTreeID[entity]);
		g_iTreeID[entity] = 0;
	}
}
public void OnTreeThink(int entity) {
	static float lastMove[2048][3];
	float ang[3], vel[3], src[3], dst[3], min[3], max[3];
	Entity_GetAbsAngles(entity, ang);
	Entity_GetAbsOrigin(entity, dst);
	GetAngleVectors(ang, NULL_VECTOR, NULL_VECTOR, vel);
	
	if( FloatAbs(vel[2]) < 0.5 && Entity_GetHealth(entity) <= 0 ) {		
		if( GetVectorDotProduct(lastMove[entity], vel) < 0.999999999 ) {
			lastMove[entity] = vel;
			return;
		}
		
		int rnd = GetRandomInt(0, sizeof(g_szWoodGibs) - 1);

		float dist = 0.0;
		while( dist < float(Entity_GetMaxHealth(entity)/TREE_HP)-128.0 ) {
			int ent = CreateEntityByName("prop_physics");
			DispatchKeyValue(ent, "model", g_szWoodGibs[rnd]);
			DispatchKeyValue(ent, "classname", "rp_wood");
			DispatchSpawn(ent);
			ActivateEntity(ent);
			
			Entity_GetMinSize(ent, min);
			Entity_GetMaxSize(ent, max);
			
			dist += (max[2] - min[2]);
			
			src[0] = 0.0;
			src[1] = 0.0;
			src[2] = dist;
			
			Math_RotateVector(src, ang, src);
			AddVectors(src, dst, src);
			
			TeleportEntity(ent, src, ang, NULL_VECTOR);
			rp_ScheduleEntityInput(ent, 60.0, "Break");
			Entity_SetCollisionGroup(ent, COLLISION_GROUP_DEBRIS|COLLISION_GROUP_PLAYER);
			SDKHook(ent, SDKHook_OnTakeDamage, OnWoodDamage);
		}
		
		Entity_SetSolidType(entity, SOLID_NONE);
		ServerCommand("sm_effect_fading %d 1 1", entity);
		rp_ScheduleEntityInput(entity, 1.0, "Kill");
		SDKUnhook(entity, SDKHook_VPhysicsUpdate, OnTreeThink);
	}
}
public Action OnWoodDamage(int victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3]) {
	if( attacker == inflictor && damagetype & DMG_SLASH ) {
		if( IsMeleeAxe(weapon) ) {	
			AcceptEntityInput(victim, "Break");
		}
	}
}
public Action OnTreeDamage(int victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3]) {
	if( attacker == inflictor && damagetype & DMG_SLASH ) {
		if( IsMeleeAxe(weapon) ) {				
			SetEntProp(victim, Prop_Data, "m_iHealth", Entity_GetHealth(victim) - RoundFloat(damage));
			if( Entity_GetHealth(victim) <= 0 ) {		
				SetEntProp(victim, Prop_Data, "m_iHealth", 0);
				AcceptEntityInput(victim, "EnableMotion");
			
				float vel[3];
				vel[2] = 32.0;				
				TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, damageForce);	
			}
		}
	}
}


stock bool IsMeleeAxe(int weapon) {
	static char tmp[128];
	
	GetEdictClassname(weapon, tmp, sizeof(tmp));
	if( StrEqual(tmp, "weapon_melee") ) {
		Entity_GetModel(weapon, tmp, sizeof(tmp));
		if( StrEqual(tmp, "models/weapons/v_axe.mdl") ) {
			return true;
		}
	}
	return false;
}