#if defined _roleplay_stock_effect_included
#endinput
#endif
#define _roleplay_stock_effect_included

#if defined ROLEPLAY_SUB
	#include "../roleplay.sp"
#else
	#include "roleplay.sp"
#endif

void displayDeathOverlay(int Client, int Attacker, bool carkill=false) {
	if( Attacker == 0 )
		rp_ClientOverlays(Client, o_Death_Basket);
	else if( g_iHideNextLog[Attacker][Client] == 0 ) {
		int tips[5], tipsCount, TipsType[4];
		for (int i = 1; i <= MaxClients; i++) {
			if( !IsValidClient(i) )
				continue;
			
			if( rp_GetClientJobID(i) == 1 && TipsType[0] == 0 ) {
				tips[tipsCount++] = o_Death_Police;
				TipsType[0] = 1;
			}
			else if( rp_GetClientJobID(i) == 101 && TipsType[1] == 0 ) {
				tips[tipsCount++] = o_Death_Tribunal;
				TipsType[1] = 1;
			}
			else if( rp_GetClientJobID(i) == 41 && TipsType[2] == 0 ) {
				tips[tipsCount++] = o_Death_Mercenaire;
				TipsType[2] = 1;
			}
			else if( TipsType[3] == 0 && !g_bUserData[Client][b_GameModePassive] ) {
				tips[tipsCount++] = o_Death_Passive;
				TipsType[3] = 1;
			}
		}
				
		if( g_iKillLegitime[Attacker][Client] >= GetTime() )
			tips[tipsCount++] = o_Death_Legitime;
		
		rp_ClientOverlays(Client, view_as<overlaysImg>(tips[ Math_GetRandomInt(0, tipsCount-1) ]), 10.0);
	}
	else if( carkill )
		rp_ClientOverlays(Client, o_Death_Voiture, 10.0);
	else
		rp_ClientOverlays(Client, o_Death_MisAPrix, 10.0);
}
void killSpect(int client) {
	
	if( g_bIsInCaptureMode )
		return;
	
	int old = EntRefToEntIndex(g_iUserData[client][i_FPD]);
	if( old > 0 ) {
		rp_AcceptEntityInput(old, "Kill");
		g_iUserData[client][i_FPD] = 0;
		return;
	}
	
	int ragdoll = GetEntPropEnt(client, Prop_Send, "m_hRagdoll");
	int team = GetClientTeam(client);
	
	if( ragdoll <= 0 )
		return;
	if( team != CS_TEAM_CT && team != CS_TEAM_T )
		return;
	
	int ent = CreateEntityByName("prop_dynamic_override");
	DispatchKeyValue(ent, "model", "models/props/cs_office/plant01_gib1.mdl");
	DispatchSpawn(ent);
	
	SetVariantString("!activator");
	rp_AcceptEntityInput(ent, "SetParent", ragdoll, ragdoll);
	SetVariantString("facemask");
	rp_AcceptEntityInput(ent, "SetParentAttachment", ragdoll, ragdoll);
	
	SetEntityRenderMode(ent, RENDER_NONE);
	
	g_iUserData[client][i_FPD] = EntIndexToEntRef(ent);
	
	SetEntProp(client, Prop_Send, "m_hObserverTarget", -1);
	SetEntProp(client, Prop_Send, "m_iObserverMode", 0);
	
	SetClientViewEntity(client, ent);
	
	ClientCommand(client, "firstperson");
}
void TE_SetupParticle(const char[] name, int entity, char[] attachment) {
	static int table = INVALID_STRING_TABLE;
	if (table == INVALID_STRING_TABLE) {
		table = FindStringTable("ParticleEffectNames");
	}
	
	
	float dst[3];
	GetEntPropVector(entity, Prop_Data, "m_vecOrigin", dst);
	
	TE_Start("EffectDispatch");
	TE_WriteNum("m_nHitBox", FindStringIndex(table, name));
	TE_WriteFloatArray("m_vOrigin.x", dst, 3);
	TE_WriteNum("m_nAttachmentIndex", LookupAttachment(entity, attachment));
	TE_WriteNum("entindex", entity);
	TE_WriteNum("m_fFlags", (1<<0));
	TE_WriteNum("m_nDamageType", 4);
	TE_WriteNum("m_iEffectName", 5);
}
void EffectPissing(int Client) {
	static float ang[3], pos[3], ppos[3], aang[3], end[3];
	
	if( g_flUserData[Client][fl_Alcool] > 0.0 && g_bUserData[Client][b_Pissing] ) {
		GetClientEyePosition(Client, pos);
		GetClientEyeAngles(Client, ang);
		pos[2] -= 23.0; 
		ang[0] = 60.0;
			
		TR_TraceRayFilter(pos, ang, MASK_PLAYERSOLID, RayType_Infinite, FilterToOne, Client);
		TR_GetEndPosition(end);
		int ent = TR_GetEntityIndex();
			
		if( IsValidClient(ent) ) {
			PerformFade(ent, 5, {255, 240, 0, 100});
			TE_SetupBeamRingPoint(end, 5.0, 10.0, g_cBeam, g_cGlow, 0, 15, 0.5, 5.0, 1.0, {255, 255, 0, 255}, 10, 0);
			TE_SendToAll();
				
			if( GetClientTeam(ent) == CS_TEAM_CT && Math_GetRandomInt(1, 10) == 5 ) { 
				IncrementSuccess(Client, success_list_pissing);
			}
		}
		else {
			TE_SetupBeamRingPoint(end, 5.0, 15.0, g_cBeam, g_cGlow, 0, 15, 0.5, 5.0, 1.0, {255, 255, 0, 255}, 10, 0);
			TE_SendToAll();
		}
			
		GetClientEyePosition(Client, ppos);
		ppos[2]-=30.0;
				
		GetClientEyeAngles(Client, aang);
			
		if(aang[1] > 0) {
			ppos[0]+=(10.0 - ((10.0/90.0)* aang[1]));
			ppos[1]+=(10.0 - ((10.0/90.0)* FloatAbs((aang[1]-90.0))));
		}
		else {
			ppos[0]+=(10.0 - ((10.0/90.0)* FloatAbs(aang[1])));
			ppos[1]-=(10.0 - ((10.0/90.0)* FloatAbs((FloatAbs(aang[1])-90.0))));
		}
		
		aang[0]=0.0;
		aang[1]+=180.0;
		aang[2]=0.0;
			
		TE_SetupBeamPoints(end, ppos, g_cBeam, g_cGlow, 1, 30, 0.1, 1.0, 1.0, 0, 10.0, {255, 255, 0, 255}, 10);
		TE_SendToAll();
			
		g_flUserData[Client][fl_Alcool] -= (0.15/60.0/10.0);
		if( g_flUserData[Client][fl_Alcool] <= 0.0 ) {
			g_flUserData[Client][fl_Alcool] = 0.0;
			SendConVarValue(Client, FindConVar("host_timescale"), "1.0000");
		}
	}
}
void EffectHallucination(int Client, float time) {
	static float Origin[3], Direction[3];
	
	if( g_flUserData[Client][fl_HallucinationTime] > time ) {
				
		GetClientAbsOrigin(Client, Origin);
		Origin[0] += Math_GetRandomFloat(-255.0, 255.0);
		Origin[0] += Math_GetRandomFloat(-255.0, 255.0);
		Origin[0] += Math_GetRandomFloat( -50.0, 255.0);
		
		Direction[0] = Math_GetRandomFloat(0.0, 1.0);
		Direction[1] = Math_GetRandomFloat(0.0, 1.0);
		Direction[2] = Math_GetRandomFloat(0.0, 1.0);
			
		switch(Math_GetRandomInt(1, 8)) {
			case 1: {
				TE_SetupExplosion(Origin, g_cExplode, Math_GetRandomFloat(0.5, 2.0), 2, 1, Math_GetRandomInt(25, 100) , Math_GetRandomInt(25, 100) );
				TE_SendToClient(Client);
			}
			case 2: {
				TE_SetupDust(Origin, Direction, Math_GetRandomFloat(50.0, 100.0), 10.0);
				TE_SendToClient(Client);
			}
			case 3: {
				TE_SetupEnergySplash(Origin, Direction, true);
				TE_SendToClient(Client);
			}
			case 4: {
				TE_SetupMetalSparks(Origin, Direction);
				TE_SendToClient(Client);
			}
			case 5: {
				TE_SetupSparks(Origin, Direction, Math_GetRandomInt(1, 10), Math_GetRandomInt(1, 10));
				TE_SendToClient(Client);
			}
			case 6: {
				TE_SetupArmorRicochet(Origin, Direction);
				TE_SendToClient(Client);
			}
			case 7: {
				TE_SetupArmorRicochet(Origin, Direction);
				TE_SendToClient(Client);
			}
			case 8: {
				TE_SetupArmorRicochet(Origin, Direction);
				TE_SendToClient(Client);
			}
			case 9: {
				TE_SetupMetalSparks(Origin, Direction);
				TE_SendToClient(Client);
			}
			default: {
				TE_SetupSparks(Origin, Direction, Math_GetRandomInt(1, 10), Math_GetRandomInt(1, 10));
				TE_SendToClient(Client);
			}
		}
	}
}
void SmokingEffet(int client, float ftime=30.0) {
	for( float time=0.1; time<ftime; time+=0.5) {
		CreateTimer(time, SpawnSomeSmoke, client);
	}
}
public Action SpawnSomeSmoke(Handle timer, any client) {
	if( !IsValidClient(client) )
		return Plugin_Handled;
	
	float origin[3];
	GetClientEyePosition(client, origin);
	origin[2] += 1;
	
	float up[3] = { 0.0, 0.0, 1.0 };
	
	TE_SetupDust(origin, up, 10.0, 0.1);
	TE_SendToAll();
	TE_SetupDust(origin, up, 10.0, 0.1);
	TE_SendToAll(0.1);
	TE_SetupDust(origin, up, 10.0, 0.1);
	TE_SendToAll(0.2);
	TE_SetupDust(origin, up, 10.0, 0.1);
	TE_SendToAll(0.3);
	TE_SetupDust(origin, up, 10.0, 0.1);
	TE_SendToAll(0.4);
	
	g_bUserData[client][b_Smoking] = 1;
	return Plugin_Continue;
}
public Action bleeding(Handle timer, any client) {
	if( IsValidClient(client) ) {
		AttachParticle(client, "blood_impact_heavy", 5.0);
	}
}
void PerformFade(int client, int duration, const color[4], bool timer = true) {
	g_iAlphaChannel[client][0] = color[0];
	g_iAlphaChannel[client][1] = color[1];
	g_iAlphaChannel[client][2] = color[2];
	g_iAlphaChannel[client][3] = color[3];
	
	if( timer ) 
		CreateTimer(float(duration), PerformFade_end, client);
	
}
public Action PerformFade_end(Handle time, any client) {
	g_iAlphaChannel[client][0] = 0;
	g_iAlphaChannel[client][1] = 0;
	g_iAlphaChannel[client][2] = 0;
	g_iAlphaChannel[client][3] = 0;
}

#define HIDEHUD_RADAR (1<<12)
#define HIDEHUD_TIMER (1<<13)

void RP_PerformFade(int client) {
	int color[4];
	
	if( g_iUserData[client][i_Sickness] > GetTime() || g_iUserData[client][i_Malus] ) {
		color[1] = 120;
		color[3] = 80;
	}
	
	if( g_iUserData[client][i_Mask] > 0 ) {
		color[3] += 20;
	}
	
	Action a;
	Call_StartForward( view_as<Handle>(g_hRPNative[client][RP_PreHUDColorize]));
	Call_PushCell(client);
	Call_PushArrayEx(color, sizeof(color), SP_PARAMFLAG_BYREF);
	Call_Finish(a);
	
	for(int i=0; i<4; i++) {
		
		color[i] += g_iAlphaChannel[client][i];
		
		if( color[i] > 255 )
			color[i] = 255;
		if( color[i] < 0 )
			color[i] = 0;
		
	}
	
	if( HasDoctor(client) && g_iUserData[client][i_Sick] != 0 && a != Plugin_Stop ) {
		color[0] -= 50;
		color[1] -= 50;
		color[2] -= 50;
		
		color[0] += 100;
		
		if( g_iUserData[client][i_Sick] == view_as<int>(sick_type_fievre) ) 
			color[3] = 220;
		else
			color[3] = 180;
		
		if( color[0] < 0 )
			color[0] = 0;
		if( color[0] > 255 )
			color[0] = 255;
		if( color[1] < 0 )
			color[1] = 0;
		if( color[2] < 0 )
			color[2] = 0;
	}
	
	
	if( g_bUserData[client][b_Blind] /*|| !IsPlayerAlive(client)*/ ) {
		color[0] = color[1] = color[2] = 0;
		color[3] = 255;
	}
	
	if( IsClientSourceTV(client) ) {
		color[0] = color[1] = color[2] = color[3] = 0;
	}
	
	
	
	int hud = GetEntProp(client, Prop_Send, "m_iHideHUD");
	int hud2 = hud;
	bool radar = ( !IsInPVP(client) && !(GetZoneBit( GetPlayerZone(client) ) & BITZONE_BLOCKRADAR) && !g_bUserData[client][b_GameModePassive] && GetEntProp(client, Prop_Send, "m_bDrawViewmodel") == 1 );
	
	if( g_bUserData[client][b_Blind] || !radar || (GetZoneBit( GetPlayerZone(client) ) & BITZONE_EVENT) ) {
		if( !(hud & HIDEHUD_RADAR) )
			hud |= HIDEHUD_RADAR;
	}
	else if( hud & HIDEHUD_RADAR ) {
		hud &= ~HIDEHUD_RADAR;
	}
	
	if( !(hud & HIDEHUD_TIMER) ) {
		hud |= HIDEHUD_TIMER;
	}
	
	if( hud != hud2 ) {
		SetEntProp(client, Prop_Send, "m_iHideHUD", hud);
	}
	
	Handle hFadeClient = StartMessageOne("Fade",client);
	PbSetInt(hFadeClient, "duration", 1);
	PbSetInt(hFadeClient, "hold_time", 1);
	PbSetInt(hFadeClient, "flags", (FFADE_PURGE | FFADE_STAYOUT));
	PbSetColor(hFadeClient, "clr", color);
	EndMessage();
}
//
// Drugs:
void ShakingVision(int client, float max = DRUG_DURATION) {
	
	float time = 0.0;
	
	for(time = 0.01; time < max; time += 1.0 ) {
		CreateTimer(time, TaskShakingVision, client);
	}
	
	CreateTimer( (time+0.5), TaskShakingVisionStop, client);
}
public Action TaskShakingVision(Handle time, any client) {
	if( !IsValidClient(client) )
		return Plugin_Handled;
	float angs[3];
	GetClientEyeAngles(client, angs);
	angs[2] = GetRandomFloat(-15.0, 15.0);
	
	TeleportEntity(client, NULL_VECTOR, angs, NULL_VECTOR);
	
	return Plugin_Continue;
}
public Action TaskShakingVisionStop(Handle time, any client) {
	if( !IsValidClient(client) )
		return Plugin_Handled;
	
	float angs[3];
	GetClientEyeAngles(client, angs);
	
	angs[2] = 0.0;
	
	TeleportEntity(client, NULL_VECTOR, angs, NULL_VECTOR);
	
	return Plugin_Continue;
}
void VisionTrouble(int client, float max = 10.0) {
	
	float time;
	for(time = 0.01; time < max; time += 1.0 ) {
		CreateTimer(time, TaskVisionTrouble, client);
	}
	
	CreateTimer( (time+0.5), TaskVisionTroubleStop, client);
}
public Action TaskVisionTrouble(Handle timer, any client) {
	ClientCommand(client, "r_screenoverlay sprites/heatwave");
}
public Action TaskVisionTroubleStop(Handle timer, any client) {
	ClientCommand(client, "r_screenoverlay 0");
}
void TazerEffect(int client, int target) {
	float vecStart[3], vecEnd[3], vecDir[3];
	GetClientEyePosition(client, vecStart);
	GetClientEyeAngles(client, vecDir);
	
	if( IsValidClient(target) ) {
		GetClientEyePosition(target, vecEnd);
		vecEnd[2] -= 10.0;
	}
	else {
		Entity_GetAbsOrigin(target, vecEnd);
	}
	
	
	vecStart[2] -= 2.5;
	
	
	ShowTrack(client, "weapon_tracers_taser", vecStart, vecDir, vecEnd);
	
	vecDir[0] = vecDir[1] = vecDir[2] = 0.0;
	
	TE_SetupArmorRicochet(vecEnd, vecDir);
	TE_SendToAll();
	
	TE_SetupDust(vecEnd, vecDir, 1.0, 1.0);
	TE_SendToAll();
	
	TE_SetupSparks(vecEnd, vecDir, 1, 2);
	TE_SendToAll();
}
void IgnitePlayer(int target, float time, int client = 0) {
	
	int victim_zone = GetPlayerZone(target);
	if( StringToInt(g_szZoneList[victim_zone][zone_type_bit]) & BITZONE_PEACEFULL )
		return;
	if( IsValidClient(client) ) {
		int attacker_zone = GetPlayerZone(client);
		if( StringToInt(g_szZoneList[attacker_zone][zone_type_bit]) & BITZONE_PEACEFULL )
			return;
		
		if( Client_CanAttack(client, target) == false )
			return;
	}
	
	
	IgniteEntity(target, time);
	g_flUserData[target][fl_Burning] = (GetGameTime() + time);
	g_iUserData[target][i_LastAgression] = GetTime() + RoundFloat(time);
	g_iUserData[target][i_BurnedBy] = client;
	
}
void PoisonPlayer(int target, float time, int client) {
	float vecOrigin[3], vecOrigin2[3];
	GetClientEyePosition(target, vecOrigin);
	GetClientEyePosition(client, vecOrigin2);
	
	vecOrigin[2] -= 20.0; vecOrigin2[2] -= 20.0;
	TE_SetupBeamPoints(vecOrigin, vecOrigin2, g_cBeam, 0, 0, 0, 0.1, 10.0, 10.0, 0, 10.0, {50, 250, 50, 250}, 10);
	TE_SendToAll();
	
	if( Client_CanAttack(client, target) == false )
		return;
	
	if( !(rp_GetClientJobID(target) == 11 && !g_bUserData[target][b_GameModePassive]) && g_flUserData[target][fl_LastPoison] < GetGameTime() ) {
		g_iUserData[target][i_Sickness] = 1;
		g_flUserData[target][fl_LastPoison] = GetGameTime();
		
		if( time >= 0.1 ) {
			CreateTimer(60.0, StopPoison, target);
		}
	}
}

public Action StopPoison(Handle time, any  target) {
	if( g_iUserData[target][i_Sickness] == 1 && g_flUserData[target][fl_LastPoison]+59 <= GetGameTime() ) {
		g_iUserData[target][i_Sickness] = 0;
		g_flUserData[target][fl_LastPoison] = GetGameTime() + 12.0 * 60.0;
	}
	
}

public void CTF_SNIPER_dot(int client) {
	
	float train = g_flUserData[client][fl_WeaponTrainAdmin] < 0 ? g_flUserData[client][fl_WeaponTrain] : g_flUserData[client][fl_WeaponTrainAdmin];
	
	if( train > 4.0 ) {
	
		float vecOrigin[3], vecOrigin2[3];
		GetClientEyePosition(client, vecOrigin);
		rp_GetClientTarget(client, vecOrigin2);
		float distance = GetVectorDistance(vecOrigin, vecOrigin2);
		distance = Pow(distance, 0.5) / 10.0;
		
		vecOrigin = vecOrigin2;	
		vecOrigin2[2] -= distance;
		vecOrigin[2] += distance;
		
		TE_SetupBeamPoints(vecOrigin, vecOrigin2, g_cHacked, g_cHacked, 0, 0, 0.1, distance, distance, 0, 45.0, {255, 0, 0, 255}, 10);
		TE_SendToClient(client);
	}	
}
public void DoBeacon(int client) {
	
	if( IsValidClient(g_iUserData[client][i_Protect_From]) ) {
		
		int target = g_iUserData[client][i_Protect_From];
		
		if( rp_GetDistance(client, target) < 500.0 ) {
			
			float pos[3], top[3];
			top[2] = 1.0;
			
			GetClientAbsOrigin(client, pos);
			
			for(int i=1; i<MaxClients; i++) {
				if( !IsValidClient(i) )
					continue;
				if( !IsPolice(i) && i != target && i != client )
					continue;
				
				TE_SetupEnergySplash(pos, top, false);
				TE_SendToClient(i);
			}
			
			GetClientAbsOrigin(target, pos);
			for(int i=1; i<MaxClients; i++) {
				if( !IsValidClient(i) )
					continue;
				if( !IsPolice(i) && i != target && i != client )
					continue;
				TE_SetupEnergySplash(pos, top, false);
				TE_SendToClient(i);
			}
			
			int heal = GetClientHealth(client);
			heal += Math_GetRandomInt(1, 5);
			if( heal > 500 )
				heal = 500;
			SetEntityHealth(client, heal);
			
			heal = GetClientHealth(target);
			heal += Math_GetRandomInt(1, 5);
			if( heal > 500 )
				heal = 500;
			SetEntityHealth(target, heal);
		}
	}
	
	if( g_bUserData[client][b_Beacon] == 0 )
		return;
	
	
	int team = GetClientTeam(client);
	
	float vec[3];
	GetClientAbsOrigin(client, vec);
	vec[2] += 10;
	
	TE_SetupBeamRingPoint(vec, 10.0, 375.0, g_cBeam, g_cGlow, 0, 15, 0.5, 5.0, 0.0, {128, 128, 128, 255}, 10, 0);
	TE_SendToAll();
	
	if (team == 2) {
		TE_SetupBeamRingPoint(vec, 10.0, 375.0, g_cBeam, g_cGlow, 0, 10, 0.6, 10.0, 0.5, {255, 75, 75, 255}, 10, 0);
	}
	else if (team == 3) {
		TE_SetupBeamRingPoint(vec, 10.0, 375.0, g_cBeam, g_cGlow, 0, 10, 0.6, 10.0, 0.5, {75, 75, 255, 255}, 10, 0);
	}
	else {
		TE_SetupBeamRingPoint(vec, 10.0, 375.0, g_cBeam, g_cGlow, 0, 10, 0.6, 10.0, 0.5, {75, 255, 75, 255}, 10, 0);
	}
	
	TE_SendToAll();
	
	GetClientEyePosition(client, vec);
	EmitSoundToAllAny("buttons/blip1.wav", client);
}

public Action fwdTazerBlue(int client, int color[4]) {
	color[0] -= 50;
	color[1] -= 50;
	color[2] += 255;
	color[3] += 50;
	return Plugin_Changed;
}
