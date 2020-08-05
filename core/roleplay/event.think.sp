#if defined _roleplay_event_think_included
#endinput
#endif
#define _roleplay_event_think_included

#if !defined _roleplay_event_think_included || defined ROLEPLAY_SUB
	#define ROLEPLAY_SUB
	#include "../roleplay.sp"
#else
	#include "roleplay.sp"
#endif

void setRecoil(int client) {
	float train = g_flUserData[client][fl_WeaponTrainAdmin] < 0 ? g_flUserData[client][fl_WeaponTrain] : g_flUserData[client][fl_WeaponTrainAdmin];
	if( train <= 4.0 ) {
		int shoot = GetEntProp(client, Prop_Send, "m_iShotsFired");
		float vecAngles[3];
		vecAngles[0] = vecAngles[1] = vecAngles[2] = -float(shoot) * (4.0 - train) * 0.1;
		SetEntPropVector(client, Prop_Send, "m_aimPunchAngle", vecAngles);
	}
}

public Action OnSetTransmit(int entity, int client) {
	if( entity == client )
		return Plugin_Continue;

	if(g_bUserData[entity][b_Invisible] && (g_iUserData[entity][i_Job] == 1 || g_iUserData[entity][i_Job] == 2 || g_iUserData[entity][i_Job] == 4 || g_iUserData[entity][i_Job] == 5)) {
		if( g_iUserData[client][i_ContratType] >= 1000 )
			return Plugin_Continue;
		return Plugin_Handled;
	}
	return Plugin_Continue;
}
public void OnPreThink(int client) {
	setRecoil(client);
}
public void OnPostThinkPost(int client) {
	static int m_flFlashDuration = -1, m_flFlashMaxAlpha = -1;
	if( m_flFlashDuration == -1 )
		m_flFlashDuration = FindSendPropInfo("CCSPlayer", "m_flFlashDuration");
	if( m_flFlashMaxAlpha == -1 )
		m_flFlashMaxAlpha = FindSendPropInfo("CCSPlayer", "m_flFlashMaxAlpha");
	
	setRecoil(client);
	if( g_flUserData[client][fl_Alcool] > 0.0 ) {
		SetEntDataFloat(client, m_flFlashDuration, GetGameTime()+0.1,true);
		SetEntDataFloat(client, m_flFlashMaxAlpha, g_flUserData[client][fl_Alcool] * 10.0 + 20.0, true);
	}
}
public void OnPostThink(int client) {
	static Handle fCvar;
	static float fAngle[65];
	if( fCvar == INVALID_HANDLE )
		fCvar = FindConVar("host_timescale");
	
	int GroundEnt = GetEntPropEnt(client, Prop_Send, "m_hGroundEntity");
	if( GroundEnt != client ) {
		g_iGroundEntity[client] = GroundEnt;
	}

	if ((GroundEnt > 0) && (GroundEnt <= MaxClients)) {
		SetEntPropEnt(client, Prop_Send, "m_hGroundEntity", 0);
	}
	
	setRecoil(client);
	CTF_SNIPER_dot(client);
	
	if( g_flUserData[client][fl_Alcool] > 0.0 ) {
		fAngle[client] += Pow(g_flUserData[client][fl_Alcool], 1.5);
		if( fAngle[client] > 360.0 )
			fAngle[client] -= 360.0;
		
		float radianConversion = degrees_to_radians(fAngle[client]);
		float punch[3];
		punch[0] += Sine(radianConversion) * g_flUserData[client][fl_Alcool] * 100.0;
		punch[1] += Cosine(radianConversion) * g_flUserData[client][fl_Alcool] * 100.0;
		
		SetEntPropVector(client, Prop_Send, "m_aimPunchAngleVel", punch);
		
		
		char str[24];
		float percent = 1.0 - (g_flUserData[client][fl_Alcool]/8.0);
		if( percent > 1.0 )
			percent = 1.0;
		if( percent < 0.1 )
			percent = 0.1;
		
		FloatToString(percent, str, sizeof(str));
		SendConVarValue(client, fCvar, str);
		
		if( GetUserFlagBits(client) & ADMFLAG_CHEATS && GetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue") > 0.01 ) {
			SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", (DEFAULT_SPEED/percent) );
		}
		
		if( GetGameTickCount()%20 == 0 ) {
			ClientCommand(client, "firstperson");
		}
	}
	
}
public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon) {
	static int lastButtons[MAXPLAYERS + 1];
	
	if( !g_bUserData[client][b_isConnected] || !g_bUserData[client][b_isConnected2] )
		return Plugin_Continue;
		
	bool changed = false;
	
	if (buttons & IN_ATTACK2) {
		
		if( g_bUserData[client][b_WeaponIsHands] ) {
			buttons &= ~IN_ATTACK2;
			changed = true;
		}	
	}
	
	if( g_bUserData[client][b_KeyReverse] ) {

		if( Math_GetRandomInt(0, 200) == 17 ) {
			vel[0] = 300.0;
			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
		}
		else if( Math_GetRandomInt(0, 200) == 17 ) {
			vel[0] = -300.0;
			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
		}
		if( Math_GetRandomInt(0, 200) == 17 ) {
			vel[1] = 300.0;
			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
		}
		else if( Math_GetRandomInt(0, 200) == 17 ) {
			vel[1] = -300.0;
			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
		}
	}

	if( g_bUserData[client][b_ForceExit] ) {
		buttons |= IN_USE;
		g_bUserData[client][b_ForceExit] = false;
		changed = true;
	}

	if( g_bUserData[client][b_Invisible] ) {

		if( buttons & IN_ATTACK ) {
			CopSetVisible(client);
		}
		if( buttons & IN_ATTACK2 ) {
			CopSetVisible(client);
		}
	}
	
	if( !IsPlayerAlive(client) && g_flUserData[client][fl_RespawnTime] < GetGameTime() && !IsClientSourceTV(client) ) {

		if( lastButtons[client] != buttons || g_bUserData[client][b_SpawnToTribunal] || g_bUserData[client][b_SpawnToTueur] ) {
			CS_RespawnPlayer(client);
		}
	}
	lastButtons[client] = buttons;
	
	if( impulse == 100 ) {
		if( g_bUserData[client][b_LampePoche] == 0 ) {
			CPrintToChat(client, "" ...MOD_TAG... " Vous n'avez pas de Lampe de poche utilisable.");
			return Plugin_Handled;
		}
	}
	return changed ? Plugin_Changed : Plugin_Continue;
}

