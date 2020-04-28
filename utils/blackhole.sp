#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <smlib>
#include <phun>
#include <cstrike>

public Plugin:myinfo = 
{
	name = "BlackHole",
	author = "KoSSoLaX",
	description = "Spawn a BlackHole",
	version = "1.0",
	url = "http://www.ts-x.eu/"
}

new Float:g_fOrigin[3];
new g_iBlackHole = 0;
new Float:g_fBlakHoleTick = 0.0;

#define BLACK_TICK 0.025

int g_cShockWave;
public OnPluginStart() {
	
	RegAdminCmd("sm_blackhole", 		Cmd_BlackHole, 		ADMFLAG_BAN);
	RegAdminCmd("sm_blackhole_stop", 	Cmd_BlackHoleStop, 	ADMFLAG_BAN);
}

float g_fPush, g_fForce;
public OnMapStart() {
	g_iBlackHole = 0;
	g_cShockWave = PrecacheModel("materials/effects/concrefract.vmt");
}
public Action:Cmd_BlackHoleStop(client, args) {

	g_iBlackHole = 0;
	ReplyToCommand(client, "Trou noir desactive");
	
	return Plugin_Handled;
}
public Action:Cmd_BlackHole(client, args) {

	
	GetClientAbsOrigin(client, g_fOrigin);
	g_iBlackHole = 1;
	
	g_fOrigin[2] += 100;
	g_fBlakHoleTick = (GetGameTime() + 2.5);
	g_fPush = GetCmdArgFloat(1);
	g_fForce = GetCmdArgFloat(2);
	
	if( g_fPush <= 1.0 )
		g_fPush = 1250.0;
	if( g_fForce <= 1.0 )
		g_fForce = 200.0;
	
	ReplyToCommand(client, "Trou noir active");
	return Plugin_Handled;
}
stock Float:GetVectorDistance2D(Float:vec1[3], Float:vec2[3]) {
	vec1[2] = 0.0;
	vec2[2] = 0.0;
	
	return GetVectorDistance(vec1, vec2);
}
stock BlackHolePush(Float:center[3], Float:radius, Float:speed) {
	
	new String:classname[64];
	
	for(new i=1; i<=2000; i++) {
		
		if( !IsMoveAble(i) )
			continue;
		if( IsValidClient(i) ) {
			if( !IsPlayerAlive(i) )
				continue;
		}
		
		GetEdictClassname(i, classname, 63);
		
		if( StrContains(classname, "prop_vehicle", false) != -1 )
			continue;

		new Float:f_Origin[3];
		GetEntPropVector(i, Prop_Send, "m_vecOrigin", f_Origin);
		
		new Float:dist = GetVectorDistance(f_Origin, center);
		if( dist > radius ) 
			continue;
		if( dist >= 1250.0 )
			continue;
		
		if( dist < 60.0) {
			new Float:hole[3];
			
			hole[0] = 0.0;
			hole[1] = 0.0;
			hole[2] = -999999.0;
			
			TeleportEntity(i, NULL_VECTOR, NULL_VECTOR, hole);
			
			if( IsValidClient(i) ) {
				ForcePlayerSuicide(i);
				CS_RespawnPlayer(i);
			}
			else {
				Desyntegrate(i);
				DealDamage(i, 10, i);
			}
			continue;
		}
		if( dist < 500.0 ) {
			SetEntityGravity(i, 0.4);
			
			new flags = GetEntityFlags(i);
			SetEntityFlags(i, (flags&~FL_ONGROUND) );
			
			if( IsValidClient(i) ) {
				
				SetEntPropEnt(i, Prop_Send, "m_hGroundEntity", -1);
				
				f_Origin[2] += 1.0;
				TeleportEntity(i, f_Origin, NULL_VECTOR, NULL_VECTOR);
			}
		}
		if( dist < 350.0 ) {
			SetEntityGravity(i, 0.2);
		}
		if( dist < 150.0 ) {
			SetEntityGravity(i, 0.1);
		}
		if( dist < 100.0 ) {
			SetEntityGravity(i, 0.01);
		}
		
		
		new Float:to_speed = (1.0 - (dist / radius)) * speed;
		
		to_speed *= -1;
		
		new Float:f_Velocity[3];
		f_Velocity[0] = f_Origin[0] - center[0];
		f_Velocity[1] = f_Origin[1] - center[1];
		f_Velocity[2] = f_Origin[2] - center[2];
		
		new Float:f_Length = GetVectorLength(f_Velocity);
		
		f_Velocity[0] = f_Velocity[0] / f_Length * to_speed * 3.0/10.0;
		f_Velocity[1] = f_Velocity[1] / f_Length * to_speed * 3.0/10.0;
		f_Velocity[2] = f_Velocity[2] / f_Length * to_speed * 3.0/10.0;
		
		new Float:f_Current[3];
		GetEntPropVector(i, Prop_Data, "m_vecVelocity", f_Current);
		
		f_Current[0] += f_Velocity[0];
		f_Current[1] += f_Velocity[1];
		f_Current[2] += f_Velocity[2];
		
		TeleportEntity(i, NULL_VECTOR, NULL_VECTOR, f_Current);
		
		
	}
}

public OnGameFrame() {
	
	if( g_iBlackHole == 1 ) {
		
		if( g_fBlakHoleTick < GetGameTime() ) {
			
			g_fBlakHoleTick = (GetGameTime() + BLACK_TICK);
			
			BlackHolePush( g_fOrigin, g_fPush, g_fForce);
			
			TE_SetupBeamRingPoint(g_fOrigin, 32.0, 128.0, g_cShockWave, g_cShockWave, 0, 1, 0.1, 32.0, 0.0, { 255, 255, 255, 255 }, 0, 0);
			TE_SendToAll();
		}
	}
}