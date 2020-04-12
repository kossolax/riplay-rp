#if defined _phun_included
#endinput
#endif
#define _phun_included

#include <core>
#include <sourcemod>

#define DMG_GENERIC					0
#define DMG_CRUSH					(1 << 0)
#define DMG_BULLET					(1 << 1)
#define DMG_SLASH					(1 << 2)
#define DMG_BURN					(1 << 3)
#define DMG_VEHICLE					(1 << 4)
#define DMG_FALL					(1 << 5)
#define DMG_BLAST					(1 << 6)
#define DMG_CLUB					(1 << 7)
#define DMG_SHOCK					(1 << 8)
#define DMG_SONIC					(1 << 9)
#define DMG_ENERGYBEAM				(1 << 10)
#define DMG_PREVENT_PHYSICS_FORCE	(1 << 11)
#define DMG_NEVERGIB				(1 << 12)
#define DMG_ALWAYSGIB				(1 << 13)
#define DMG_DROWN					(1 << 14)
#define DMG_TIMEBASED				(DMG_PARALYZE | DMG_NERVEGAS | DMG_POISON | DMG_RADIATION | DMG_DROWNRECOVER | DMG_ACID | DMG_SLOWBURN)
#define DMG_PARALYZE				(1 << 15)
#define DMG_NERVEGAS				(1 << 16)
#define DMG_POISON					(1 << 17)
#define DMG_RADIATION				(1 << 18)
#define DMG_DROWNRECOVER			(1 << 19)
#define DMG_ACID					(1 << 20)
#define DMG_SLOWBURN				(1 << 21)
#define DMG_REMOVENORAGDOLL			(1 << 22)
#define DMG_PHYSGUN					(1 << 23)
#define DMG_PLASMA					(1 << 24)
#define DMG_AIRBOAT					(1 << 25)
#define DMG_DISSOLVE				(1 << 26)
#define DMG_BLAST_SURFACE			(1 << 27)
#define DMG_DIRECT					(1 << 28)
#define DMG_BUCKSHOT				(1 << 29)

// Hud Element hiding flags
#define HIDEHUD_WEAPONSELECTION		( 1<<0 )    // Hide ammo count & weapon selection
#define HIDEHUD_FLASHLIGHT			( 1<<1 )
#define HIDEHUD_ALL					( 1<<2 )
#define HIDEHUD_HEALTH				( 1<<3 )    // Hide health & armor / suit battery
#define HIDEHUD_PLAYERDEAD			( 1<<4 )    // Hide when local player's dead
#define HIDEHUD_NEEDSUIT			( 1<<5 )    // Hide when the local player doesn't have the HEV suit
#define HIDEHUD_MISCSTATUS 			( 1<<6 )    // Hide miscellaneous status elements (trains, pickup history, death notices, etc)
#define HIDEHUD_CHAT				( 1<<7 )    // Hide all communication elements (saytext, voice icon, etc)
#define HIDEHUD_CROSSHAIR			( 1<<8 )    // Hide crosshairs
#define HIDEHUD_VEHICLE_CROSSHAIR	( 1<<9 )    // Hide vehicle crosshair
#define HIDEHUD_INVEHICLE			( 1<<10 )
#define HIDEHUD_BONUS_PROGRESS		( 1<<11 )    // Hide bonus progress display (for bonus map challenges)
#define HIDEHUD_BITCOUNT			12

#define WEAPONS_MAX_LENGTH 32
#define WEAPONS_SLOTS_MAX 5
// -----------------------------------------------------------------------------------------------------------
//
// Natives:
//

// -----------------------------------------------------------------------------------------------------------
//
// Stocks:
//
#if defined _tsxrp_included_
#else
int GetClientTarget(int client) {
	float vecStart[3], vecAngles[3];
	GetClientEyePosition(client, vecStart);
	GetClientEyeAngles(client, vecAngles);
	
	Handle trace = TR_TraceRayFilterEx(vecStart, vecAngles, MASK_SOLID, RayType_Infinite, TRFilter_AimTarget, client);
	if( !TR_DidHit(trace) ) {
		CloseHandle(trace);
		return 0;
	}
	
	int ent = TR_GetEntityIndex(trace);
	CloseHandle(trace);
	
	return ent;
}
public bool TRFilter_AimTarget(int entity, int mask, any client) {
	if (entity == client)
		return false;
	
	return true;
}
#endif
public void ScheduleEntityInput(int entity, float time, const char[] input) {
	
	if( !IsValidEdict(entity) )
		return;
	if( !IsValidEntity(entity) )
		return;
	
	char classname[65];
	GetEdictClassname(entity, classname, sizeof(classname));
	
	//PrintToServer("[DEBUG] [INPUT] %d(%s) -> %s -> %f", int entity, classname, input, time);
	
	Handle dp;
	CreateDataTimer( time, ScheduleTargetInput_Task, dp, TIMER_DATA_HNDL_CLOSE); 
	WritePackCell(dp, EntIndexToEntRef(entity));
	WritePackString(dp, input);
}
public void ScheduleTargetInput( const char[] targetname, float time, const char[] input) {
	char i_targetname[128];
	//char classname[65];
	
	for(int i=1; i<=2048; i++) {
		if( !IsValidEdict(i) )
			continue;
		if( !IsValidEntity(i) )
			continue;
		
		
		GetEntPropString(i, Prop_Data, "m_iName", i_targetname, sizeof(i_targetname));
		
		if( !StrEqual(targetname, i_targetname, false) )
			continue;
		
		
		//GetEdictClassname(i, classname, sizeof(classname));
		//PrintToServer("[DEBUG] [INPUT] %d(%s) -> %s", i, classname, input);
		
		Handle dp;
		CreateDataTimer( time, ScheduleTargetInput_Task, dp, TIMER_DATA_HNDL_CLOSE); 
		WritePackCell(dp, EntIndexToEntRef(i));
		WritePackString(dp, input);
	}
}
public Action ScheduleTargetInput_Task(Handle timer, Handle dp) {
	int entity;
	char input[128];
	
	ResetPack(dp);
	
	entity = EntRefToEntIndex(ReadPackCell(dp));
	ReadPackString(dp, input, 127);
	
	if( entity == INVALID_ENT_REFERENCE ) 
		return Plugin_Handled;
	if( entity <= 0 )
		return Plugin_Handled;
	if( !IsValidEdict(entity) )
		return Plugin_Handled;
	if( !IsValidEntity(entity) )
		return Plugin_Handled;
	
	//char classname[65];
	//GetEdictClassname(entity, classname, sizeof(classname));
	
	//if( StrEqual(classname, "prop_vehicle_driveable") && StrEqual(input, "KillHierarchy") )
	//	LogToGame("[DEBUG] [INPUT] %d(%s) -> %s", int entity, classname, input);
	AcceptEntityInput(entity, input);
	return Plugin_Handled;
}
#if defined _tsxrp_included_
#else
public float GetCmdArgFloat(index) {
	char arg[24];
	GetCmdArg(index, arg, sizeof(arg));
	return StringToFloat(arg);
}
public GetCmdArgInt(index) {
	char arg[24];
	GetCmdArg(index, arg, sizeof(arg));
	return StringToInt(arg);
}
#endif
// ----------------------------------------------------------------------------
// ClientViews()
// ----------------------------------------------------------------------------
stock bool ClientViews(int Viewer, int Target, float fMaxDistance=0.0, float fThreshold=0.73)
{
	// Retrieve view and target eyes position
	
	float fViewPos[3], fViewAng[3], fViewDir[3];
	float fTargetPos[3], fTargetDir[3], fDistance[3];
	
	if( IsValidClient(Viewer) ) {
		GetClientEyePosition(Viewer, fViewPos);
		GetClientEyeAngles(Viewer, fViewAng);
	}
	else {
		
		GetEntPropVector(Viewer, Prop_Send, "m_vecOrigin", fViewPos);
		GetEntPropVector(Viewer, Prop_Send, "m_angRotation", fViewAng);
	}
	
	if( IsValidClient(Target) ) {
		GetClientEyePosition(Target, fTargetPos);
	}
	else {
		GetEntPropVector(Viewer, Prop_Send, "m_vecOrigin", fTargetPos);
	}
	
	// Calculate view direction
	fViewAng[0] = fViewAng[2] = 0.0;
	GetAngleVectors(fViewAng, fViewDir, NULL_VECTOR, NULL_VECTOR);
	
	// Calculate distance to viewer to see if it can be seen.
	fDistance[0] = fTargetPos[0]-fViewPos[0];
	fDistance[1] = fTargetPos[1]-fViewPos[1];
	fDistance[2] = 0.0;
	if (fMaxDistance != 0.0)
	{
		if (((fDistance[0]*fDistance[0])+(fDistance[1]*fDistance[1])) >= (fMaxDistance*fMaxDistance)) {
			return false;
		}
	}
	
	// Check dot product. If it's negative, that means the viewer is facing
	// backwards to the target.
	NormalizeVector(fDistance, fTargetDir);
	float dot = GetVectorDotProduct(fViewDir, fTargetDir);
	if( dot < fThreshold) {
		return false;
	}
	
	// Now check if there are no obstacles in between through raycasting
	Handle hTrace = TR_TraceRayFilterEx(fViewPos, fTargetPos, MASK_PLAYERSOLID_BRUSHONLY, RayType_EndPoint, ClientViewsFilter, Viewer);
	if( TR_DidHit(hTrace) ) {
		CloseHandle(hTrace); 
		return false;
	}
	CloseHandle(hTrace);
	
	// Done, it's visible
	return true;
}
stock bool ClientViews_LeftRight(int Viewer, int Target, float fMaxDistance=0.0, float fThreshold=0.73, float PosePara=0.5)
{
	// Retrieve view and target eyes position
	
	float fViewPos[3], float fViewAng[3], float fViewDir[3];
	float fTargetPos[3], float fTargetDir[3], float fDistance[3];
	
	if( IsValidClient(Viewer) ) {
		GetClientEyePosition(Viewer, fViewPos);
		GetClientEyeAngles(Viewer, fViewAng);
	}
	else {
		
		GetEntPropVector(Viewer, Prop_Send, "m_vecOrigin", fViewPos);
		GetEntPropVector(Viewer, Prop_Send, "m_angRotation", fViewAng);
		
		fViewAng[1] = (fViewAng[1] + 180.0) - (360.0*PosePara);
	}
	
	if( IsValidClient(Target) ) {
		GetClientEyePosition(Target, fTargetPos);
	}
	else {
		GetEntPropVector(Viewer, Prop_Send, "m_vecOrigin", fTargetPos);
	}
	
	// Calculate view direction
	fViewAng[0] = fViewAng[2] = 0.0;
	GetAngleVectors(fViewAng, fViewDir, NULL_VECTOR, NULL_VECTOR);
	
	// Calculate distance to viewer to see if it can be seen.
	fDistance[0] = fTargetPos[0]-fViewPos[0];
	fDistance[1] = fTargetPos[1]-fViewPos[1];
	fDistance[2] = 0.0;
	if (fMaxDistance != 0.0)
	{
		if (((fDistance[0]*fDistance[0])+(fDistance[1]*fDistance[1])) >= (fMaxDistance*fMaxDistance)) {
			return false;
		}
	}
	
	// Check dot product. If it's negative, that means the viewer is facing
	// backwards to the target.
	NormalizeVector(fDistance, fTargetDir);
	float dot = GetVectorDotProduct(fViewDir, fTargetDir);
	if( dot < fThreshold) {
		return false;
	}
	
	// Now check if there are no obstacles in between through raycasting
	Handle hTrace = TR_TraceRayFilterEx(fViewPos, fTargetPos, MASK_PLAYERSOLID_BRUSHONLY, RayType_EndPoint, ClientViewsFilter, Viewer);
	if( TR_DidHit(hTrace) ) {
		CloseHandle(hTrace); 
		return false;
	}
	CloseHandle(hTrace);
	
	// Done, it's visible
	return true;
}
// ----------------------------------------------------------------------------
// ClientViewsFilter()
// ----------------------------------------------------------------------------
public bool ClientViewsFilter(int Entity, int Mask, any Junk) {
	if( Junk == Entity )
		return false;
	if (Entity >= 1 && Entity <= MaxClients)
		return false;
	return true;
}
stock void UningiteEntity(int entity) {
	if( !IsValidEdict(entity) )
		return;
	
	int ent = GetEntPropEnt(entity, Prop_Data, "m_hEffectEntity");
	if (IsValidEdict(ent))
		SetEntPropFloat(ent, Prop_Data, "m_flLifetime", 0.0); 
}
stock void ShowParticle(float pos[3], const char[] particlename, float time) {
	
	int particle = CreateEntityByName("info_particle_system");
	
	if (IsValidEdict(particle)) {
		TeleportEntity(particle, pos, NULL_VECTOR, NULL_VECTOR);
		DispatchKeyValue(particle, "effect_name", particlename);
		ActivateEntity(particle);
		AcceptEntityInput(particle, "start");
		ScheduleEntityInput(particle, time, "Kill");
	}
	else {
		LogError("ShowParticle: could not create info_particle_system");
	}    
}
stock int ShowTrack(int client, char cmd[128], float pos[3], float ang[3], float endpos[3] ) {  
	LogToGame("[DANGER] %d - %s", client, cmd);
 	char temp[16]="";		
	int target = CreateEntityByName("info_particle_system");
	Format(temp, sizeof(temp), "cptarget%d", target);
	DispatchKeyValue(target, "targetname", temp);	
	TeleportEntity(target, endpos, NULL_VECTOR, NULL_VECTOR); 
	ActivateEntity(target); 
	
	int particle = CreateEntityByName("info_particle_system");
	DispatchKeyValue(particle, "effect_name", cmd);
	DispatchKeyValue(particle, "cpoint1", temp);
	
	DispatchSpawn(particle);
	ActivateEntity(particle); 
	TeleportEntity(particle, pos, ang, NULL_VECTOR);
	AcceptEntityInput(particle, "start");	
	
	ScheduleEntityInput(target, 0.5, "Kill");
	ScheduleEntityInput(particle, 0.5, "Kill");
	return particle;
}
stock int AttachParticle(int ent, const char[] particleType, float time, int target=0)
{
	int particle = CreateEntityByName("info_particle_system");
	PrintToServer("[WARNING] %d --> %s (%.2f) @ %d", ent, particleType, time, target);
	
	if (IsValidEdict(particle))
	{
		float pos[3];
		GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
		TeleportEntity(particle, pos, NULL_VECTOR, NULL_VECTOR);
		
		DispatchKeyValue(particle, "effect_name", particleType);
		
		
		if( target > 0 ) {
			PrintToServer("[WARNING] !!!");
			char tName[64];
			Format(tName, sizeof(tName), "ph_child_%i%i_%i", particle, target, GetRandomInt(1111, 9999));
			DispatchKeyValue(ent, "targetname", tName);
			DispatchKeyValue(particle, "cpoint1_parent", tName);
			SetVariantString(tName);
			AcceptEntityInput(particle, "SetParent");
			SetVariantString("weapon_bone");
			AcceptEntityInput(particle, "SetParentAttachment", particle, particle, 0);
			
			Format(tName, sizeof(tName), "ph_child_%i%i_%i", particle, target, GetRandomInt(1111, 9999));
			DispatchKeyValue(target, "targetname", tName);
			DispatchKeyValue(particle, "cpoint1", tName);
			
			Format(tName, sizeof(tName), "ph_child_%i%i_%i", particle, target, GetRandomInt(1111, 9999));
			DispatchKeyValue(target, "targetname", tName);
			DispatchKeyValue(particle, "cpoint2", tName);
		}
		else {
			
			SetVariantString("!activator");
			AcceptEntityInput(particle, "SetParent", ent);/*
			SetVariantString("weapon_bone");
			AcceptEntityInput(particle, "SetParentAttachment", particle, particle, 0);*/
		}
		
		DispatchSpawn(particle);
		ActivateEntity(particle);
		
		AcceptEntityInput(particle, "start");
		
		ScheduleEntityInput(particle, time, "Kill");
		
		return particle;
	}
	else
	{
		LogError("AttachParticle: could not create info_particle_system");
	}
	
	return -1;
}
stock void TE_Particle(const char[] Name, float origin[3]=NULL_VECTOR, float start[3]=NULL_VECTOR, float angles[3]=NULL_VECTOR, int entindex=-1, int attachtype=-1, int attachpoint=-1, bool resetParticles=true, float delay=0.0) {
	
	// find string table
	int tblidx = FindStringTable("ParticleEffectNames");
	
	if (tblidx==INVALID_STRING_TABLE) {
		LogError("Could not find string table: ParticleEffectNames");
		return;
	}
	//
	// find particle index
	char tmp[256];
	int count = GetStringTableNumStrings(tblidx);
	int stridx = INVALID_STRING_INDEX;
	int i;
	
	for (i=0; i<count; i++) {
		
		ReadStringTable(tblidx, i, tmp, sizeof(tmp));
		
		//PrintToServer(tmp);
		if (StrEqual(tmp, Name, false)) {
			stridx = i;
			break;
		}
	}
	if (stridx == INVALID_STRING_INDEX) {
		LogError("Could not find particle: %s", Name);
		return;
	}
	
	TE_Start("TFParticleEffect");
	TE_WriteFloat("m_vecOrigin[0]", origin[0]);
	TE_WriteFloat("m_vecOrigin[1]", origin[1]);
	TE_WriteFloat("m_vecOrigin[2]", origin[2]);
	TE_WriteFloat("m_vecStart[0]", start[0]);
	TE_WriteFloat("m_vecStart[1]", start[1]);
	TE_WriteFloat("m_vecStart[2]", start[2]);
	TE_WriteVector("m_vecAngles", angles);
	TE_WriteNum("m_iParticleSystemIndex", stridx);
	
	if (entindex != -1) {
		TE_WriteNum("entindex", entindex);
	}
	if (attachtype != -1) {
		TE_WriteNum("m_iAttachType", attachtype);
	}
	if (attachpoint != -1) {
		TE_WriteNum("m_iAttachmentPointIndex", attachpoint);
	}
	
	TE_WriteNum("m_bResetParticles", resetParticles ? 1 : 0);    
	TE_SendToAll(delay);
}
stock void strclear( char[] str, int len) {
	for(int i = 0;i < len;i++) {
		str[i] = 0;
	}
	return;
}
stock void Colorize(int client, int red=0, int green=0, int blue=0, int alpha=255) {
	
	int weapon;
	if( IsValidClient(client) ) {
		for( int i = 0; i < 5; i++ ) {
			weapon = GetPlayerWeaponSlot( client, i );
			if( !IsValidEntity(weapon))
				continue;
			
			SetEntityRenderMode(weapon, RENDER_TRANSALPHA);
			SetEntityRenderColor(weapon, red, green, blue, alpha);
		}		
	}
	
	SetEntityRenderMode(client, RENDER_TRANSALPHA);
	SetEntityRenderColor(client, red, green, blue, alpha);
	
	return;
}

public void hideModel(int id) {	
	
	int EntEffects = GetEntProp(id, Prop_Send, "m_fEffects");
	EntEffects |= (32);
	SetEntProp(id, Prop_Send, "m_fEffects", EntEffects);
}
public void showModel(int id) {
	
	int EntEffects = GetEntProp(id, Prop_Send, "m_fEffects");
	EntEffects &= ~(32);
	SetEntProp(id, Prop_Send, "m_fEffects", EntEffects);
}
stock float GetClientSpeed(int client) {
	
	float vec[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", vec);
	
	return GetVectorLength(vec);
}
stock bool CheckPlayerNearby(int client, int target, float distance) {
	int bool isVisible = false;
	float ClientVector[3], float TargetVector[3];
	GetClientEyePosition(client, ClientVector);
	GetClientEyePosition(target, TargetVector);
	
	if (GetVectorDistance(ClientVector, TargetVector) < distance) 
	{
		if (IsPointVisible(ClientVector, TargetVector))
			isVisible = true;
	}
	
	return isVisible;
}

stock bool IsPointVisible(const float start[3], const float end[3]) {
	TR_TraceRayFilter(start, end, MASK_OPAQUE, RayType_EndPoint, TraceEntityFilterStuff);
	
	return TR_GetFraction() >= 0.75;
}

public bool TraceEntityFilterStuff(int entity, int mask) {
	return (entity < 0);
}
#if defined _tsxrp_included_
#else
public bool IsValidClient(int client) {
	if( client <= 0 )
		return false;
	
	if( client > MaxClients )
		return false;
	
	if( !IsValidEdict(client) )
		return false;
	
	if( !IsClientConnected(client) )
		return false;
	
	return true;
}
#endif
public void SetClientLookAtMe(int me ,int client ) { 
	float myPosition[3], hisPosition[3], newAngle[3]; 
	
	GetClientAbsOrigin(me,myPosition); 
	GetClientAbsOrigin(client,hisPosition); 
	
	float temp[3];
	MakeVectorFromPoints(hisPosition,myPosition,temp);
	GetVectorAngles(temp,newAngle);
	
	//looking to the top --> 0 > newAngle[0] > -90.0
	if ( newAngle[0] > 90.0 ) {
		newAngle[0] = (360.0-newAngle[0])*-1.0;
		if ( newAngle[0] < -90.0 ) newAngle[0] = -89.9;
	}
	
	TeleportEntity(client, NULL_VECTOR, newAngle, NULL_VECTOR); 
} 

stock void BarTime(client, duration) {
	
	SetEntPropFloat(client, Prop_Send, "m_flProgressBarStartTime", GetGameTime());
	SetEntProp(client, Prop_Send, "m_iProgressBarDuration", duration);
	
	CreateTimer( float(duration), BarTimeStop, any client);
}
public Action BarTimeStop(Handle time, any client) {
	
	SetEntPropFloat(client, Prop_Send, "m_flProgressBarStartTime", GetGameTime());
	SetEntProp(client, Prop_Send, "m_iProgressBarDuration", 0);
}

stock void DealDamage(victim, damage, attacker=0, dmg_type=DMG_GENERIC, String:weapon[]="") {
	//PrintToServer("pre-damage--> %d", victim);
	Entity_Hurt(victim, damage, attacker, dmg_type, weapon);
	//PrintToServer("post-damage--> %d", victim);
	return;
}
public bool ____TraceEntityFilterPlayers(int entity, int contentsMask, any data ) {
	return entity > GetMaxClients() && entity != data;
}
stock void TE_SetupBSPDecal(const float vecOrigin[3], int entity, int index) {
	
	TE_Start("BSP Decal");
	TE_WriteVector("m_vecOrigin",vecOrigin);
	TE_WriteNum("m_nEntity",entity);
	TE_WriteNum("m_nIndex",index);
}
stock void TE_SetupDynamicLight(const float vecOrigin[3], r,g,b,iExponent,float fRadius,float fTime,float fDecay) {
	TE_Start("Dynamic Light");
	TE_WriteVector("m_vecOrigin",vecOrigin);
	TE_WriteNum("r",r);
	TE_WriteNum("g",g);
	TE_WriteNum("b",b);
	TE_WriteNum("exponent",iExponent);
	TE_WriteFloat("m_fRadius",fRadius);
	TE_WriteFloat("m_fTime",fTime);
	TE_WriteFloat("m_fDecay",fDecay);
}
stock int FindEntityByTargetname(const char[] targetname, const char[] classname)
{
	char namebuf[32];
	int index = -1;
	namebuf[0] = '\0';
	
	while(strcmp(namebuf, targetname) != 0
		&& (index = FindEntityByClassname(index, classname)) != -1)
	GetEntPropString(index, Prop_Data, "m_iName", namebuf, sizeof(namebuf));
	
	return(index);
} 
stock void Desyntegrate(int Entity) {
	if (!IsValidEntity(Entity))
		return;
	
	
	float f_Current[3];
	f_Current[0] = 0.0;
	f_Current[1] = 0.0;
	f_Current[2] = 45.0;
	
	TeleportEntity(Entity, NULL_VECTOR, NULL_VECTOR, f_Current);
	SetEntityGravity(Entity, 1.0);
	
	char dname[32];
	Format(dname, sizeof(dname), "dis_%d", int entity);
	
	char cname[64];
	GetEdictClassname(Entity, cname, 63);
	
	int ent = CreateEntityByName("env_entity_dissolver");
	if (ent>0) {
		DispatchKeyValue(Entity, "targetname", dname);
		DispatchKeyValue(ent, "dissolvetype", "0");
		DispatchKeyValue(ent, "target", dname);
		AcceptEntityInput(ent, "Dissolve");
		AcceptEntityInput(ent, "kill");
		
		if( IsValidClient(Entity) ) {
			CreateTimer(0.2, RemoveRageDollTask, int entity);
		}
	}
}
public Action RemoveRageDollTask(Handle timer, any client) {
	RemoveRagdoll(client);
}
stock void RemoveRagdoll(int client) {
	
	if( !IsValidClient(client) ) 
		return;
	
	int ragdoll = GetEntPropEnt(client, Prop_Send, "m_hRagdoll");
	
	if( !IsValidEdict(ragdoll) )
		return;
	
	if( !IsValidEntity(ragdoll) )
		return;
	
	char dname[32];
	Format(dname, sizeof(dname), "dis_%d", ragdoll);
	
	int ent = CreateEntityByName("env_entity_dissolver");
	if (ent>0 && ragdoll>0) {
		DispatchKeyValue(ragdoll, "targetname", dname);
		
		DispatchKeyValue(ent, "dissolvetype", "0");
		DispatchKeyValue(ent, "target", dname);
		AcceptEntityInput(ent, "Dissolve");
		AcceptEntityInput(ent, "kill");
	}
}

public bool IsMoveAble(int ent) {
	static char classname[64];
	if( ent <= 0 || !IsValidEdict(ent) || !IsValidEntity(ent) )
		return false;
	if( IsValidClient(ent) ) 
		return IsPlayerAlive(ent);
	if( !HasEntProp(ent, Prop_Send, "m_vecOrigin") )
		return false;
	if( GetEntityMoveType(ent) != MOVETYPE_VPHYSICS )
		return false;
	if( !HasEntProp(ent, Prop_Send, "m_vecVelocity") && !HasEntProp(ent, Prop_Data, "m_vecAbsVelocity") )
		return false;
	
	
	GetEdictClassname(ent, classname, sizeof(classname));
	if( StrContains(classname, "door", false) == 0 )
		return false;
	if( StrContains(classname, "prop_p", false) == 0 )
		return true;
	if( StrContains(classname, "weapon_", false) == 0 )
		return true;
	if( StrContains(classname, "chicken", false) == 0 )
		return true;
	
	return false;
}
stock void MakeRadiusPush(float center[3], float radius, float speed, ignore = -1) {
	
	if( radius < 1.0 && radius > -1.0 )
		radius = 1.0;
	
	for(int i=1; i<=2048; i++) {
		
		if( ignore == i )
			continue;
		
		if( !IsMoveAble(i) )
			continue;
		
		float f_Origin[3];
		
		if( IsValidClient(i) ) {
			GetClientEyePosition(i, f_Origin);
		}
		else {
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", f_Origin);
		}
		
		float dist = GetVectorDistance(f_Origin, center);
		if( dist > radius ) 
			continue;
		
		float to_speed = (1.0 - (dist / radius)) * speed;
		
		float f_Velocity[3];
		f_Velocity[0] = f_Origin[0] - center[0];
		f_Velocity[1] = f_Origin[1] - center[1];
		f_Velocity[2] = f_Origin[2] - center[2];
		
		float f_Length = GetVectorLength(f_Velocity);
		if( f_Velocity ) < 1.0
			f_Velocity = 1.0;
		
		f_Velocity[0] = f_Velocity[0] / f_Length * to_speed;
		f_Velocity[1] = f_Velocity[1] / f_Length * to_speed;
		f_Velocity[2] = f_Velocity[2] / f_Length * to_speed;
		
		
		float vecVelocity[3];
		GetEntPropVector(i, Prop_Data, "m_vecVelocity", vecVelocity);
		
		f_Velocity[0] = (vecVelocity[0]*0.5) + f_Velocity[0];
		f_Velocity[1] = (vecVelocity[0]*0.5) + f_Velocity[1];
		f_Velocity[2] = (vecVelocity[0]*0.5) + f_Velocity[2];
		
		int flags = GetEntityFlags(i);
		if( f_Velocity[2] > 0.0 && (flags & FL_ONGROUND) ) {
			SetEntityFlags(i, (flags&~FL_ONGROUND) );
			SetEntPropEnt(i, Prop_Send, "m_hGroundEntity", -1);
		}
		TeleportEntity(i, NULL_VECTOR, NULL_VECTOR, f_Velocity);
		
	}
}
stock TE_SetupWorldDecal(const float vecOrigin[3], int index)
{    
	TE_Start("World Decal");
	TE_WriteVector("m_vecOrigin",vecOrigin);
	TE_WriteNum("m_nIndex",index);
}


stock GetClientMaxHealth(Client) {
	return GetEntData(Client, FindDataMapInfo(Client, "m_iMaxHealth"), 4);
}

/**
* Checks if a client has a specific weapon.
* 
* @param client    The client index.
* @param weapon    The weapon classname.
*/
stock bool WeaponsClientHasWeapon(client, const String:weapon[]) {
	// Get all of client's current weapons.
	int weapons[WeaponsSlot];
	WeaponsGetClientWeapons(client, weapons);
	
	char classname[64];
	
	// x = slot index
	for (int x = 0; x < WEAPONS_SLOTS_MAX; x++) {
		// If slot is empty, then stop.
		if (weapons[x] == -1) {
			continue;
		}
		
		// If the weapon's classname matches, then return true.
		GetEdictClassname(weapons[x], classname, sizeof(classname));
		ReplaceString(classname, sizeof(classname), "weapon_", "");
		if (StrEqual(weapon, classname, false)) {
			return true;
		}
	}
	
	return false;
}

/**
* Return an array that contains all client's weapon indexes.
* 
* @param client    The client index.
* @param weapons   The weapon index array.
*                  -1 if no weapon in slot. 
*/
stock WeaponsGetClientWeapons(client, weapons[6]) {
	// x = Weapon slot.
	for (int x = 0; x < WEAPONS_SLOTS_MAX; x++) {
		weapons[x] = GetPlayerWeaponSlot(client, x);
	}
}

/**
* Returns weapon index of the client's deployed weapon.
* 
* @param client    The client index.
* @return          The weapon index of the deployed weapon.
*                  -1 if no weapon is deployed. 
*/
stock WeaponsGetDeployedWeaponIndex(client) {
	// Return the client's active weapon.
	return GetEntDataEnt2(client, FindSendPropInfo("CAI_BaseNPC", "m_hActiveWeapon"));
}

/**
* Returns slot of client's deployed weapon.
*
* @param client    The client index.
* @return          The slot number of deployed weapon.
*/
stock WeaponsGetDeployedWeaponSlot(client) {
	// Get all client's weapon indexes.
	int weapons[6];
	WeaponsGetClientWeapons(client, weapons);
	
	// Get client's deployed weapon.
	int deployedweapon = WeaponsGetDeployedWeaponIndex(client);
	
	// If client has no deployed weapon, then stop.
	if (deployedweapon == -1) {
		return -1;
	}
	
	// x = weapon slot.
	for (int x = 0; x < WEAPONS_SLOTS_MAX; x++) {
		if (weapons[x] == deployedweapon) {
			return x;
		}
	}
	
	return -1;
}

stock GetRandomString( String:random[], len) {
	static const String:chrs[]="23456789abcdefg";
	int size = strlen(chrs)-1;
	
	for( int i = 0; i < len; i++ ) {
		random[i] = chrs[ GetRandomInt(0, size) ];
	}  
}
#if defined _tsxrp_included_
#else
public bool FilterToOne(entity, mask, any data) {
	return (data != entity);
}
#endif

stock void TargetBeamBox(int client, int target, float vecTarget[3] = {0.0, 0.0, 0.0}, int red=0, int green=255, int blue=0) {
	static int _cHackedSprite = -1;
	static int _cPhysicBeam = -1;
	
	if( !IsModelPrecached("materials/sprites/physbeam.vmt") || _cPhysicBeam == -1 )
		_cPhysicBeam = PrecacheModel("materials/sprites/physbeam.vmt");
	if( !IsModelPrecached("materials/sprites/white.vmt") || _cHackedSprite == -1 )
		_cHackedSprite = PrecacheModel("materials/sprites/white.vmt");

	
	float vecOrigin[3];
	Entity_GetAbsOrigin(client, vecOrigin);
	
	if( target > 0 )
		Entity_GetAbsOrigin(target, vecTarget);
	
	
	int color[4];
	color[0] = red;
	color[1] = green;
	color[2] = blue;
	color[3] = 50;
	
	vecOrigin[2] += 4.0;
	vecTarget[2] += 4.0;
	
	TE_SetupBeamRingPoint(vecTarget, 10.0, 400.0, _cPhysicBeam, 0, 0, 0, 1.0, 10.0, 0.0, color, 0, 0);
	TE_SendToClient(client);
	
	color[3] += 200;
	
	TE_SetupBeamPoints(vecOrigin, vecTarget, _cPhysicBeam, 0, 0, 0, 1.0, 2.0, 2.0, 0, 0.0, color, 0);
	TE_SendToClient(client);
	
	SetupBeamPoints2(vecOrigin, vecTarget, "materials/sprites/physbeam.vmt", 1.0, 2.0, 2.0, color, client);
	
	if( target > 0 ) {
		float position[3], min[3], max[3], f_points[8][3];
		GetEntPropVector( target, Prop_Send, "m_vecMins", min );
		GetEntPropVector( target, Prop_Send, "m_vecMaxs", max );
		GetEntPropVector( target, Prop_Send, "m_vecOrigin", position);
		
		f_points[0][0] = position[0] + max[0];
		f_points[0][1] = position[1] + max[1];
		f_points[0][2] = position[2] + max[2];
		
		f_points[1][0] = position[0] + min[0];
		f_points[1][1] = position[1] + max[1];
		f_points[1][2] = position[2] + max[2];
		
		f_points[2][0] = position[0] + min[0];
		f_points[2][1] = position[1] + min[1];
		f_points[2][2] = position[2] + max[2];
		
		f_points[3][0] = position[0] + max[0];
		f_points[3][1] = position[1] + min[1];
		f_points[3][2] = position[2] + max[2];
		
		f_points[4][0] = position[0] + max[0];
		f_points[4][1] = position[1] + max[1];
		f_points[4][2] = position[2] + min[2];
		
		f_points[5][0] = position[0] + min[0];
		f_points[5][1] = position[1] + max[1];
		f_points[5][2] = position[2] + min[2];
		
		f_points[6][0] = position[0] + min[0];
		f_points[6][1] = position[1] + min[1];
		f_points[6][2] = position[2] + min[2];
		
		f_points[7][0] = position[0] + max[0];
		f_points[7][1] = position[1] + min[1];
		f_points[7][2] = position[2] + min[2];
		
		TE_SetupBeamPoints(f_points[0], f_points[1], _cHackedSprite, 0, 0, 15, 0.2, 1.0, 1.0, 0, 0.0, color, 10);
		TE_SendToClient(client);
		TE_SetupBeamPoints(f_points[1], f_points[2], _cHackedSprite, 0, 0, 15, 0.11, 1.0, 1.0, 0, 0.0, color, 10);
		TE_SendToClient(client);
		TE_SetupBeamPoints(f_points[2], f_points[3], _cHackedSprite, 0, 0, 15, 0.11, 1.0, 1.0, 0, 0.0, color, 10);
		TE_SendToClient(client);
		TE_SetupBeamPoints(f_points[3], f_points[0], _cHackedSprite, 0, 0, 15, 0.11, 1.0, 1.0, 0, 0.0, color, 10);
		TE_SendToClient(client);
		
		TE_SetupBeamPoints(f_points[4], f_points[5], _cHackedSprite, 0, 0, 15, 0.11, 1.0, 1.0, 0, 0.0, color, 10);
		TE_SendToClient(client);
		TE_SetupBeamPoints(f_points[5], f_points[6], _cHackedSprite, 0, 0, 15, 0.11, 1.0, 1.0, 0, 0.0, color, 10);
		TE_SendToClient(client);
		TE_SetupBeamPoints(f_points[6], f_points[7], _cHackedSprite, 0, 0, 15, 0.11, 1.0, 1.0, 0, 0.0, color, 10);
		TE_SendToClient(client);
		TE_SetupBeamPoints(f_points[7], f_points[4], _cHackedSprite, 0, 0, 15, 0.11, 1.0, 1.0, 0, 0.0, color, 10);
		TE_SendToClient(client);
		
		TE_SetupBeamPoints(f_points[0], f_points[4], _cHackedSprite, 0, 0, 15, 0.11, 1.0, 1.0, 0, 0.0, color, 10);
		TE_SendToClient(client);
		TE_SetupBeamPoints(f_points[1], f_points[5], _cHackedSprite, 0, 0, 15, 0.11, 1.0, 1.0, 0, 0.0, color, 10);
		TE_SendToClient(client);
		TE_SetupBeamPoints(f_points[2], f_points[6], _cHackedSprite, 0, 0, 15, 0.11, 1.0, 1.0, 0, 0.0, color, 10);
		TE_SendToClient(client);
		TE_SetupBeamPoints(f_points[3], f_points[7], _cHackedSprite, 0, 0, 15, 0.11, 1.0, 1.0, 0, 0.0, color, 10);
		TE_SendToClient(client);
	}
}
void SetupBeamPoints2(const float start[3], const float end[3], const char[] model, float Life, 
	float Width, float EndWidth, const int Color[4], int Owner)
{
	char output[64];
	int ent = CreateEntityByName("env_beam");
	if (ent != -1) {
		TeleportEntity(ent, start, NULL_VECTOR, NULL_VECTOR);
		
		SetEntityModel(ent, model);
		
		SetEntPropFloat(ent, Prop_Data, "m_fWidth", Width);
		SetEntPropFloat(ent, Prop_Data, "m_fEndWidth", EndWidth);
		SetEntPropVector(ent, Prop_Data, "m_vecEndPos", end);
		SetEntPropEnt(ent, Prop_Data, "m_hEffectEntity", Owner);
		
		DispatchKeyValue(ent, "life", "0");
		
		Format(output, sizeof(output), "%d %d %d", Color[0], Color[1], Color[2]);
		DispatchKeyValue(ent, "rendercolor", output);
		
		Format(output, sizeof(output), "%d", Color[3]);
		DispatchKeyValue(ent, "renderamt", output);
		
		Format(output, sizeof(output), "!self,kill,,%.1f,-1", Life);
		DispatchKeyValue(ent, "OnUser1", output);
		
		DispatchSpawn(ent);
		ActivateEntity(ent);
		
		AcceptEntityInput(ent, "TurnOn");
		AcceptEntityInput(ent, "FireUser1");
		
		
		SDKHook(ent, SDKHook_SetTransmit, OnLaserTransmit);
	}
}
public Action OnLaserTransmit(int ent, int client) {
	if( client == GetEntPropEnt(ent, Prop_Data, "m_hEffectEntity") )
		return Plugin_Continue;
	return Plugin_Handled;
}


//---------------------------------------------------------
// the filter function for TR_TraceRayFilterEx
//---------------------------------------------------------
public bool TraceEntityFilterPlayers( entity, contentsMask, any data )
{
	return entity > MaxClients && entity != data;
}

//---------------------------------------------------------
// get position, angles and normal of aimed location if the parameters are not NULL_VECTOR
// return the index of entity you aimed
//---------------------------------------------------------
stock GetClientAimedLocationData( client, float position[3], float angles[3], float normal[3] )
{
	int index = -1;
	
	int player = client;
	
	float _origin[3], _angles[3];
	GetClientEyePosition( player, _origin );
	GetClientEyeAngles( player, _angles );
	
	Handle trace = TR_TraceRayFilterEx( _origin, _angles, MASK_SOLID_BRUSHONLY, RayType_Infinite, TraceEntityFilterPlayers );
	if( !TR_DidHit( trace ) )
	{ 
		index = -1;
	}
	else
	{
		TR_GetEndPosition( position, trace );
		TR_GetPlaneNormal( trace, normal );
		angles[0] = _angles[0];
		angles[1] = _angles[1];
		angles[2] = _angles[2];
		
		index = TR_GetEntityIndex( trace );
	}
	CloseHandle( trace );
	
	return index;
}

//---------------------------------------------------------
// get position just in front of you
// and the angles you are facing in horizontal
//---------------------------------------------------------
stock GetClientFrontLocationData( client, float position[3], float angles[3], float distance = 50.0 )
{
	int player = client;
	
	float _origin[3], _angles[3];
	GetClientAbsOrigin( player, _origin );
	GetClientEyeAngles( player, _angles );
	
	float direction[3];
	GetAngleVectors( _angles, direction, NULL_VECTOR, NULL_VECTOR );
	
	position[0] = _origin[0] + direction[0] * distance;
	position[1] = _origin[1] + direction[1] * distance;
	position[2] = _origin[2];
	
	angles[0] = 0.0;
	angles[1] = _angles[1];
	angles[2] = 0.0;
}

//---------------------------------------------------------
// calculate the angle between 2 vectors
// the direction will be used to determine the sign of angle (right hand rule)
// all of the 3 vectors have to be normalized
//---------------------------------------------------------
stock float GetAngleBetweenVectors( const float vector1[3], const float vector2[3], const float direction[3] )
{
	float vector1_n[3], vector2_n[3], direction_n[3], cross[3];
	NormalizeVector( direction, direction_n );
	NormalizeVector( vector1, vector1_n );
	NormalizeVector( vector2, vector2_n );
	float degree = ArcCosine( GetVectorDotProduct( vector1_n, vector2_n ) ) * 57.29577951;   // 180/Pi
	GetVectorCrossProduct( vector1_n, vector2_n, cross );
	
	if ( GetVectorDotProduct( cross, direction_n ) < 0.0 )
	{
		degree *= -1.0;
	}
	
	return degree;
}
