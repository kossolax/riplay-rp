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
#include <colors_csgo>	// https://forums.alliedmods.net/showthread.php?p=2205447#post2205447
#include <smlib>		// https://github.com/bcserv/smlib

#define CLASSNAME		"rp_sapin"

#pragma newdecls required
#include <roleplay.inc>	// https://www.ts-x.eu



public Plugin myinfo = {
	name = "Event: Noel", author = "KoSSoLaX",
	description = "RolePlay - Event: Noel",
	version = __LAST_REV__, url = "https://www.ts-x.eu"
};

int g_bLoading = false;

public void OnPluginStart() {
	RegAdminCmd("rp_sapin_add", Cmd_AddSapin, ADMFLAG_ROOT);
	CreateConVar("rp_sapin_speed", "120.0");
	
	HookEvent("round_start", 		EventRoundStart, 	EventHookMode_Post);
	
	CreateTimer(1.0, LoadSapin, _, TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(2.0, SapinLoop);	
}
public void OnMapStart() {
	CreateTimer(30.0, LoadSapin, _, TIMER_FLAG_NO_MAPCHANGE);
	
	AddFileToDownloadsTable("materials/DeadlyDesire/maps/snow2.vmt");
}
public Action EventRoundStart(Handle ev, const char[] name, bool  bd) {
	CreateTimer(10.0, LoadSapin, _, TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Continue;
}
public Action LoadSapin(Handle timer, any none) {
	if( g_bLoading )
		return Plugin_Handled;
	
	char classname[64];
	
	for (int i = MaxClients; i <= 2049; i++) {
		if( !IsValidEdict(i) || !IsValidEntity(i) )
			continue;
		GetEdictClassname(i, classname, sizeof(classname));
		if( StrEqual(classname, CLASSNAME) ) {
			rp_AcceptEntityInput(i, "Kill");
		}
	}
	
	char query[2048];
	g_bLoading = true;
	Format(query, sizeof(query), "SELECT x, y, z, id FROM `rp_sapin` ORDER BY id ASC");
	SQL_TQuery(rp_GetDatabase(), SQL_SpawnSapin, query);
	return Plugin_Handled;
}
public void SQL_SpawnSapin(Handle owner, Handle hQuery, const char[] error, any client) {
	ServerCommand("sm_effect_weather snow 100");
	while( SQL_FetchRow(hQuery) ) {
		float dst[3];
		dst[0] = SQL_FetchFloat(hQuery, 0);
		dst[1] = SQL_FetchFloat(hQuery, 1);
		dst[2] = SQL_FetchFloat(hQuery, 2);
		int id = SQL_FetchInt(hQuery, 3);
		
		int ent = CreateEntityByName("prop_dynamic");
		if( id == 1 ) {
			DispatchKeyValue(ent, "model", "models/models_kit/xmas/xmastree.mdl");
		}
		else {
			DispatchKeyValue(ent, "model", "models/models_kit/xmas/xmastree_mini.mdl");
		}
		DispatchKeyValue(ent, "classname", CLASSNAME);
		DispatchSpawn(ent);
		ActivateEntity(ent);
		TeleportEntity(ent, dst, NULL_VECTOR, NULL_VECTOR);
		SetEntProp(ent, Prop_Send, "m_nSkin", Math_GetRandomInt(0, 3));
	}
	g_bLoading = false;
}

public Action Cmd_AddSapin(int client, int args) {
	float dst[3];
	GetClientAbsOrigin(client, dst);
	
	char query[2048];
	Format(query, sizeof(query), "INSERT INTO `rp_csgo`.`rp_sapin` (`id`, `x`, `y`, `z`) VALUES (NULL, '%d', '%d', '%d');", RoundFloat(dst[0]), RoundFloat(dst[1]), RoundFloat(dst[2]));
	SQL_TQuery(rp_GetDatabase(), SQL_QueryCallBack, query);
	
	CreateTimer(1.0, LoadSapin, _, TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Handled;
}
public Action SapinLoop(Handle timer, any none) {
	int stack[128], amount;
	float pos[3], pos2[3];
	char classname[64];
	char tmp[128];
	
	
	for (int i = MaxClients; i <= 2049; i++) {
		if( !IsValidEdict(i) || !IsValidEntity(i) )
			continue;
		
		GetEdictClassname(i, classname, sizeof(classname));
		if( StrEqual(classname, CLASSNAME) ) {
			stack[amount++] = i;
			
			Entity_GetModel(i, tmp, sizeof(tmp));
			if( StrEqual(tmp, "models/models_kit/xmas/xmastree.mdl") ) {
				stack[amount++] = i;
			}
		}
	}
	
	
	if( amount > 0 && GetClientCount(true) >= 3 ) {
		int rand = Math_GetRandomInt(0, amount - 1);
		Entity_GetAbsOrigin(stack[rand], pos);
		
		
		Entity_GetModel(stack[rand], tmp, sizeof(tmp));
		float dist = 32.0;
		amount = Math_GetRandomInt(3, 6);
		if( StrEqual(tmp, "models/models_kit/xmas/xmastree.mdl") ) {
			amount += 5 + Math_GetRandomPow(1, 20);
			dist = 128.0;
		}
		
		
		for (int i = 0; i <= amount; i++) {
			float Angle = GetRandomFloat(0.0, 359.9);
			
			pos2[0] = (pos[0] + (dist * Cosine(DegToRad(Angle))));
			pos2[1] = (pos[1] + (dist * Sine(DegToRad(Angle))));
			pos2[2] = (pos[2] + 64.0);
			
			ServerCommand("rp_zombie_die %f %f %f", pos2[0], pos2[1], pos2[2]);
		}
		CPrintToChatAll("{red}Ho ! Ho ! Ho !{default} ");
	}
	
	float time = GetConVarFloat(FindConVar("rp_sapin_speed")) - GetClientCount(true) * 1.5;
	if( time < 1.0 )
		time = 1.0;
	
	CreateTimer(Math_GetRandomFloat(time/2.0, time)/1.0, SapinLoop);
}
