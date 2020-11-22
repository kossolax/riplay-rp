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

#define MODEL_SENTRY		"models/props_survival/dronegun/dronegun.mdl"

int g_cBeam;

// ----------------------------------------------------------------------------
public Action Cmd_Reload(int args) {
	char name[64];
	GetPluginFilename(INVALID_HANDLE, name, sizeof(name));
	ServerCommand("sm plugins reload %s", name);
	return Plugin_Continue;
}

public void OnPluginStart() {
	RegServerCmd("rp_quest_reload", Cmd_Reload);
	
	
	int ent = CreateEntityByName("monster_generic");
	DispatchKeyValue(ent, "model", MODEL_SENTRY);
	DispatchSpawn(ent);
	ActivateEntity(ent);
	
	SetEntityFlags(ent, 262144);
	SetEntityMoveType(ent, MOVETYPE_FLYGRAVITY);
	SetEntProp(ent, Prop_Data, "m_lifeState", 2);
	
	float pos[3] =  { 192.5, 192.4, -2143.9 };
	TeleportEntity(ent, pos, NULL_VECTOR, NULL_VECTOR);
	SDKHook(ent, SDKHook_Think, OnThink);
}
public void OnMapStart() {	
	g_cBeam = PrecacheModel("materials/sprites/laserbeam.vmt");
	PrecacheModel(MODEL_SENTRY);
	PrecacheSoundAny("survival/turret_idle_01.wav");
	PrecacheSoundAny("survival/turret_sawplayer_01.wav");
	PrecacheSoundAny("survival/turret_lostplayer_03.wav");
	PrecacheSoundAny("weapons/m249/m249-1.wav");
}

enum {
	STATE_TURN_LEFT,
	STATE_TURN_RIGHT
};

stock float AngleMod(float flAngle) { 
    flAngle = (360.0 / 65536) * (RoundToNearest(flAngle * (65536.0 / 360.0)) & 65535); 
    return flAngle; 
}

void getTargetAngle(int ent, int target, float& tilt, float& yaw) {
	float src[3], dst[3], dir[3], ang[3];
	Entity_GetAbsOrigin(ent, src);
	Entity_GetAbsAngles(ent, ang);
	Entity_GetAbsOrigin(target, dst);
	
	src[2] += 40.0;
	dst[2] += 40.0;

	MakeVectorFromPoints(dst, src, dir);
	GetVectorAngles(dir, dst);
	ang[0] = dst[0] - ang[0];
	ang[1] = dst[1] - ang[1];
	
	ang[1] = AngleMod(ang[1]);
	if( ang[0] < -180.0 )
		ang[0] += 360.0;
	if( ang[0] >  180.0 )
		ang[0] -= 360.0;

	if( ang[0] > 45.0 )
		ang[0] = 45.0;
	if( ang[0] < -45.0 )
		ang[0] = -45.0;
	
	yaw  = 0.5 - (ang[0] / 90.0);
	tilt = ang[1] / 360.0;
}
void moveToTarget(int ent, int enemy, float speed, float& tilt, float& yaw) {
	float tilt2, yaw2;
	getTargetAngle(ent, enemy, tilt2, yaw2);
	
	if( FloatAbs(tilt - tilt2) > speed ) {
		if( tilt2 > tilt )
			tilt += speed;
		else if( tilt2 < tilt )
			tilt -= speed;
	}
	else {
		tilt = tilt2;
	}
	
	if( FloatAbs(yaw - yaw2) > speed ) {
		if( yaw2 > yaw )
			yaw += speed;
		else if( yaw2 < yaw )
			yaw -= speed;
	}
	else {
		yaw = yaw2;
	}
}

int getEnemy(int ent, float src[3], float ang[3], float& tilt, float threshold) {
	float dst[3];
	
	if( false ) {
		Handle trace;
		ang[1] += threshold * 360.0;
		trace = TR_TraceRayFilterEx(src, ang, MASK_SHOT, RayType_Infinite, TraceEntityFilterSelf, ent);
		if( TR_DidHit(trace) ) {
			TR_GetEndPosition(dst, trace);
			
			TE_SetupBeamPoints(src, dst, g_cBeam, 0, 0, 0, 1.0, 1.0, 1.0, 0, 0.0, { 0, 0, 250, 200 }, 0);
			TE_SendToAll();
		}
		delete trace;
		
		ang[1] -= threshold * 360.0;
		ang[1] -= threshold * 360.0;
		trace = TR_TraceRayFilterEx(src, ang, MASK_SHOT, RayType_Infinite, TraceEntityFilterSelf, ent);
		if( TR_DidHit(trace) ) {
			TR_GetEndPosition(dst, trace);
			
			TE_SetupBeamPoints(src, dst, g_cBeam, 0, 0, 0, 1.0, 1.0, 1.0, 0, 0.0, { 0, 0, 250, 200 }, 0);
			TE_SendToAll();
		}
		delete trace;
		ang[1] += threshold * 360.0;
	}
	
	int nearest = 0;
	float dist = 1024.0*1024.0;
	
	for (int i = 1; i <= MaxClients; i++) {
		if( !IsValidClient(i) )
			continue;
		if( !IsPlayerAlive(i) )
			continue;		
		if( GetEntityMoveType(i) == MOVETYPE_NOCLIP )
			continue;
		
		Entity_GetAbsOrigin(i, dst);
		dst[2] += 40.0;
		float tmp = GetVectorDistance(src, dst, true);
					
		if( tmp < dist ) {
			float tilt2, yaw2;
			getTargetAngle(ent, i, tilt2, yaw2);
			if( FloatAbs(tilt-tilt2) <= threshold ) {
				
				Handle trace = TR_TraceRayFilterEx(src, dst, MASK_SHOT, RayType_EndPoint, TraceEntityFilterSelf, ent);
				if( TR_DidHit(trace) ) {
					float x = TR_GetFraction(trace);
					int y = TR_GetEntityIndex(trace);
					
					if( y == i && x > 0.95 ) {
						dist = tmp;
						nearest = i;
					}
				}
				delete trace;
			}
		}
	}
	
	return nearest;
}

public void OnThink(int ent) {
	float tilt = GetEntPropFloat(ent, Prop_Send, "m_flPoseParameter", 0);
	float yaw = GetEntPropFloat(ent, Prop_Send, "m_flPoseParameter", 1);
	float last = GetEntPropFloat(ent, Prop_Data, "m_flLastAttackTime");
	int state = GetEntProp(ent, Prop_Data, "m_iInteractionState");
	int oldEnemy = GetEntPropEnt(ent, Prop_Data, "m_hInteractionPartner");

	int damage = 0; 
	float push = 128.0;
	float fire = 0.0125;
	float speed = (5.0/360.0);
	float threshold = (45.0/360.0)/2.0;

	float src[3], ang[3], dst[3], dir[3], vel[3];
	Entity_GetAbsOrigin(ent, src);
	Entity_GetAbsAngles(ent, ang);
	src[2] += 40.0;
	
	ang[0] = ang[0] + (yaw-0.5) * 90.0;
	ang[1] = ang[1] + AngleMod(180.0 + (tilt * 360.0));
	
	if( false ) {
		Handle trace = TR_TraceRayFilterEx(src, ang, MASK_SHOT, RayType_Infinite, TraceEntityFilterSelf, ent);
		if( TR_DidHit(trace) ) {
			TR_GetEndPosition(dst, trace);
			
			TE_SetupBeamPoints(src, dst, g_cBeam, 0, 0, 0, 1.0, 1.0, 1.0, 0, 0.0, { 250, 0, 0, 200 }, 0);
			TE_SendToAll();
		}
		delete trace;
	}
	
	
	int newEnemy = getEnemy(ent, src, ang, tilt, threshold);
	if( newEnemy > 0 ) {
		if( oldEnemy == 0 )
			EmitAmbientSoundAny("survival/turret_sawplayer_01.wav", NULL_VECTOR, ent);
		
		moveToTarget(ent, newEnemy, speed, tilt, yaw);
		
		if( last+fire < GetGameTime() ) {
			EmitAmbientSoundAny("weapons/m249/m249-1.wav", NULL_VECTOR, ent, _, _, _, SNDPITCH_HIGH);
			SetEntPropFloat(ent, Prop_Data, "m_flLastAttackTime", GetGameTime());
			
			Handle trace = TR_TraceRayFilterEx(src, ang, MASK_SHOT, RayType_Infinite, TraceEntityFilterSelf, ent);
			if( TR_DidHit(trace) ) {
				TR_GetEndPosition(dst, trace);
				int victim = TR_GetEntityIndex(trace);
				
				if( IsValidClient(victim) ) {
					SubtractVectors(dst, src, dir);
					NormalizeVector(dir, dir);
					ScaleVector(dir, push);
					
					Entity_GetAbsVelocity(victim, vel);
					
					AddVectors(vel, dir, dir);
					TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, dir);
					if( damage > 0 )
						rp_ClientDamage(victim, damage, 0, "rp_sentry");
				}
				
				int tracerId = CreateEntityByName("info_particle_system");
				DispatchKeyValue(tracerId, "OnUser1", "!self,KillHierarchy,,0.01,-1");
				DispatchSpawn(tracerId);
				TeleportEntity(tracerId, dst, NULL_VECTOR, NULL_VECTOR);
				AcceptEntityInput(tracerId, "FireUser1");
				
				TE_SetupEffect("weapon_tracers_original", ent, 1);
				TE_WriteNum("m_nOtherEntIndex", tracerId);
				TE_SendToAll();
			}
			delete trace;
		}
	}
	else {
		if( oldEnemy > 0 )
			EmitAmbientSoundAny("survival/turret_lostplayer_03.wav", NULL_VECTOR, ent);
		
		if( state == STATE_TURN_LEFT ) {
			tilt += speed;
			
			if( tilt > 1.0 ) {
				tilt = 1.0;
				state = STATE_TURN_RIGHT;
				EmitAmbientSoundAny("survival/turret_idle_01.wav", NULL_VECTOR, ent);
			}
		}
		else {
			tilt -= speed;
			
			if( tilt < 0.0 ) {
				tilt = 0.0;
				state = STATE_TURN_LEFT;
				EmitAmbientSoundAny("survival/turret_idle_01.wav", NULL_VECTOR, ent);
			}
		}
	}
	
	SetEntPropEnt(ent, Prop_Data, "m_hInteractionPartner", newEnemy);
	SetEntPropFloat(ent, Prop_Send, "m_flPoseParameter", tilt, 0);
	SetEntPropFloat(ent, Prop_Send, "m_flPoseParameter", yaw, 1);
	SetEntProp(ent, Prop_Data, "m_iInteractionState", state);
}
public bool TraceEntityFilterSelf(int entity, int contentsMask, any data) {
	return entity != data;
}
stock int GetEffectIndex(const char[] sEffectName) {
	static int table = INVALID_STRING_TABLE;
	
	if (table == INVALID_STRING_TABLE)
		table = FindStringTable("EffectDispatch");
	
	int iIndex = FindStringIndex(table, sEffectName);
	if(iIndex != INVALID_STRING_INDEX)
		return iIndex;
	
	return 0;
}
stock void TE_SetupEffect(const char[] effect, int parentId, int attachmentId=-1) {
	static int effectId = -1;
	static int table = -1;
	if( effectId == -1 )
		effectId = GetEffectIndex("ParticleEffect");
	if( table == -1 )
		table = FindStringTable("ParticleEffectNames");
	
	TE_Start("EffectDispatch");
	TE_WriteNum("m_nHitBox", FindStringIndex(table, effect));
	TE_WriteNum("m_nAttachmentIndex", attachmentId);		
				
	TE_WriteNum("entindex", parentId);
	TE_WriteNum("m_fFlags", (1<<0));
	TE_WriteNum("m_nDamageType", 4);
	TE_WriteNum("m_iEffectName", effectId);
}