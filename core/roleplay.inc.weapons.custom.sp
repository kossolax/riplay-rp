#if defined _roleplay_weapons_custom_included
#endinput
#endif
#define _roleplay_weapons_custom_included

#if defined ROLEPLAY_SUB
	#include "../roleplay.sp"
#else
	#include "roleplay.sp"
#endif

void ExplodeMine(int ent) {
	static float Marked[MAX_ENTITIES];
	static float dist = 100.0;
	
	if( !IsValidEdict(ent) )
		return;
	if( !IsValidEntity(ent) )
		return;
	
	char classname[64];
	GetEdictClassname(ent, classname, sizeof(classname));
	
	if( !StrEqual(classname, "rp_mine") ) {
		return;
	}
	
	if( Marked[ent] > 0.0 && Marked[ent] > GetGameTime() )
		return;
	
	Marked[ent] = GetGameTime() + 10.0;
	
	float vecOrigin[3];
	GetEntPropVector(ent, Prop_Send, "m_vecOrigin", vecOrigin);
	int owner = GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity");
	
	rp_AcceptEntityInput(ent, "Kill");	
	ExplosionDamage(vecOrigin, 150.0, dist, owner, ent);
	
	TE_SetupBeamRingPoint(vecOrigin, 1.0, dist, g_cShockWave, 0, 0, 20, 0.2, 20.0, 0.0, {255, 255, 255, 255}, 1, 0);
	TE_SendToAll();
	
	for(int i=1; i<=2048; i++) {
		if( !IsValidEdict(i) )
			continue;
		if( !IsValidEntity(i) )
			continue;
		if( i == ent )
			continue;
		if( Marked[i] > GetGameTime() )
			continue;
		
		GetEdictClassname(i, classname, sizeof(classname));
		
		if( StrEqual(classname, "rp_mine") ) {
			float vecOrigin2[3];
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", vecOrigin2);
			
			if( GetVectorDistance(vecOrigin, vecOrigin2) >= dist )
				continue;
			
			CreateTimer(0.25, ExplodeTask, i);
		}
	}
	
}
public Action ExplodeTask(Handle timer, any ent) {
	if( !IsValidEdict(ent) )
		return Plugin_Handled;
	if( !IsValidEntity(ent) )
		return Plugin_Handled;
	
	char classname[64];
	GetEdictClassname(ent, classname, sizeof(classname));
	
	if( StrEqual(classname, "rp_mine") ) {
		ExplodeMine(ent);
	}
	
	return Plugin_Handled;
}

int CTF_NADE_BASE(int client, const char[] classname) {
	int ent = CreateEntityByName("hegrenade_projectile");
	
	DispatchKeyValue(ent, "classname", classname);
	strcopy(g_szEntityName[ent], sizeof(g_szEntityName[]), classname);
	
	DispatchSpawn(ent);
		
	SetEntProp(ent, Prop_Send, "m_CollisionGroup", COLLISION_GROUP_WEAPON);
	
	SetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity", client);
	SetEntPropFloat(ent, Prop_Send, "m_flElasticity", 0.4);
	SetEntityMoveType(ent, MOVETYPE_FLYGRAVITY);
	
	return ent;
}