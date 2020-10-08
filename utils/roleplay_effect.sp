#pragma semicolon 1

#define GAME_CSGO
//#define GAME_CSS

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <colors_csgo>
#include <smlib>
#include <emitsoundany.inc>
#include <roleplay>
#include <phun>

#pragma newdecls required
#define MATH_PI 3.141592653589793


//fading
float g_fEntity_over[ MAX_ENTITIES+1 ];
float g_fEntity_star[ MAX_ENTITIES+1 ];
int g_iEntity_styl[ MAX_ENTITIES+1 ];
//velocity
float g_fEntity_over2[ MAX_ENTITIES+1 ];
float g_fEntity_star2[ MAX_ENTITIES+1 ];
float g_fEntity_fact2[ MAX_ENTITIES+1 ];
//Panel/Progressbar
int g_iProgress[65];
float g_flProgress_start[65];
float g_flProgress_end[65];
char g_szProgress[65][128];
//Time
float g_flFADE_TIME_start;
float g_flFADE_TIME_end;
int g_iFADE_TIME_type;
float g_flFADE_TIME_last;
char g_szFADE_TIME_light[14][1] = {"n", "m", "l", "k", "j", "i", "h", "g", "f", "e", "d", "c", "b", "a" };
// Resize
float g_fEntity_over3[ MAX_ENTITIES+1 ];
float g_fEntity_star3[ MAX_ENTITIES+1 ];
float g_fEntity_size_from[ MAX_ENTITIES+1 ];
float g_fEntity_size_to[ MAX_ENTITIES+1 ];
// Flash
float g_flFlash_start[65];
float g_flFlash_end[65];
float g_flFlash_amp[65];
// Alcool
float g_flAlcool_start[65];
float g_flAlcool_end[65];
float g_flAlcool_amp[65];
float g_flAlcool_length[65];

int g_iBallon[MAX_ENTITIES + 1];

// Weather
int g_iWeatherType = 0;
int g_iWeatherSpeed = 0;
int g_cModel, g_cBeam;
int SkyBoxID = -1;
//
Handle g_hDict;
Handle g_hLocations;
int g_cSnow;
ArrayList g_iParentedParticle[65];

public Plugin myinfo = {
	name = "PHUN: Effect", author = "KoSSoLaX",
	description = "Effect", version = "1.7",
	url = "http://www.ts-x.eu"
}

public void OnMapStart() {
	g_cModel = PrecacheModel("materials/sprites/water_drop.vmt");
	g_cBeam = PrecacheModel("materials/sprites/laserbeam.vmt");
	g_cSnow = PrecacheDecal("DeadlyDesire/maps/snow.vmt");	
	
	PrecacheSoundAny("ambient/weather/thunder1.wav");
	PrecacheSoundAny("ambient/weather/thunder2.wav");
	PrecacheSoundAny("ambient/weather/thunder3.wav");
	
	PrecacheGeneric("particles/effect_particles01.pcf", true);
	PrecacheGeneric("particles/effect_particles02.pcf", true);
	PrecacheGeneric("particles/effect_particles04.pcf", true);
	
	PrecacheGeneric("particles/tsx-rp-v004.pcf", true);
	
	PrecacheEffect("ParticleEffect");
	PrecacheParticleEffect("headskull");
	PrecacheEffect("ParticleEffect");
	PrecacheParticleEffect("levelup");

	PrecacheMaterial("materials/effects/skull.vmt");
	PrecacheMaterial("materials/effects/skull.vtf");
	
	for (int i = 0; i <= MAXPLAYERS; i++) {
		g_iParentedParticle[i] = new ArrayList(1);
	}
	
	SetCommandFlags("stopsound", GetCommandFlags("stopsound") ^ FCVAR_CHEAT);


//	CreateTimer(20.0, MapFix, _, TIMER_FLAG_NO_MAPCHANGE);
}
public void OnPluginEnd() {
	for (int i = 0; i <= MAXPLAYERS; i++)
		delete g_iParentedParticle[i];
}
public Action MapFix(Handle timer, any none) {
	char map[128];
	GetCurrentMap(map, sizeof(map));
	
	if( StrContains(map, "princeton") == -1 ) {
		ServerCommand("host_workshop_map 230499475");
	}
	else {
		CreateTimer(60.0, MapFix, _, TIMER_FLAG_NO_MAPCHANGE);
	}
	
}
public void OnClientPutInServer(int i) {
	SDKHook(i, SDKHook_PostThinkPost, think);
	
	// Flash
	g_flFlash_start[i] = g_flFlash_end[i] = g_flFlash_amp[i] = 0.0;
	// Alcool
	g_flAlcool_start[i] = g_flAlcool_end[i] = g_flAlcool_amp[i] = g_flAlcool_length[i] = 0.0;
}
public void OnClientDisconnect(int client) {
	static Handle cvar;
	if( cvar == INVALID_HANDLE )
		cvar = FindConVar("host_timescale");
	
	
	SendConVarValue(client, cvar, "1.0");
}

public Action Effect_Particle(int client, int args) {
	int target = GetCmdArgInt(1);
	char arg2[32], arg4[32];
	GetCmdArg(2, arg2, sizeof(arg2));
	float delay = GetCmdArgFloat(3);
	
	if( IsValidEdict(target) && IsValidEntity(target) ) {
		int particles = AttachParticle(target, arg2, delay);
		
		if( args == 4 ) {
			GetCmdArg(4, arg4, sizeof(arg4));
			SetVariantString(arg4);
			rp_AcceptEntityInput(particles, "SetParentAttachment", particles, particles, 0);
		}
		
		if( IsValidClient(target) ) {
			g_iParentedParticle[target].Push(EntIndexToEntRef(particles));
			rp_HookEvent(target, RP_OnPlayerDead, fwdPlayerDead);
			rp_HookEvent(target, RP_PostClientSendToJail, fwdPlayerDead);
			
		}
	}
	
	return Plugin_Handled;
}
public Action fwdPlayerDead(int client, int attacker, float& respawn, int& tdm) {
	char classname[65];
	int ent;
	for (int i = 0; i < g_iParentedParticle[client].Length; i++) {
		ent = EntRefToEntIndex(g_iParentedParticle[client].Get(i));
		if( ent > 0 && ent != INVALID_ENT_REFERENCE && IsValidEdict(ent) && IsValidEntity(ent) ) {
			GetEdictClassname(ent, classname, sizeof(classname));
			if( StrEqual(classname, "info_particle_system") )
				rp_AcceptEntityInput(ent, "Stop");
		}
	}
	g_iParentedParticle[client].Clear();
	rp_UnhookEvent(client, RP_OnPlayerDead, fwdPlayerDead);
	rp_UnhookEvent(client, RP_PostClientSendToJail, fwdPlayerDead);
}
stock void PrecacheParticleEffect(const char[] sEffectName) {
	static int table = INVALID_STRING_TABLE;
	
	if (table == INVALID_STRING_TABLE) {
		table = FindStringTable("ParticleEffectNames");
	}
	
	bool save = LockStringTables(false);
	AddToStringTable(table, sEffectName);
	LockStringTables(save);
}
stock void PrecacheEffect(const char[] sEffectName) {
	static int table = INVALID_STRING_TABLE;
	
	if (table == INVALID_STRING_TABLE) {
		table = FindStringTable("EffectDispatch");
	}
	
	bool save = LockStringTables(false);
	AddToStringTable(table, sEffectName);
	LockStringTables(save);
}
public Action Cmd_Fixes(int client, int args) {
	char classname[64], targetname[64];
	for(int i=MaxClients; i<=2048; i++) {
		if( !IsValidEdict(i) || !IsValidEntity(i) )
				continue;
		
		GetEdictClassname(i, classname, sizeof(classname));
		if( StrContains("func_door_func_brush", classname) >= 0 ) {
			GetEntPropString(i, Prop_Data, "m_iName", targetname, sizeof(targetname));
			
			if( StrEqual(classname, "func_door") && StrEqual(targetname, "night_skybox") ) {
				TeleportEntity(i, view_as<float>({0.0, -2048.0, 255.5}), view_as<float>({0.0, 0.0, 0.0}), NULL_VECTOR);
			}
			else if( StrEqual(classname, "func_brush") && StrEqual(targetname, "night_skybox") ) {
				TeleportEntity(i, view_as<float>({-9216.0, 10240.0, -2080.0}), view_as<float>({0.0, 0.0, 0.0}), NULL_VECTOR);
			}
			else if( StrEqual(classname, "func_brush") && StrEqual(targetname, "job=201__-pvp_wall") ) {
				TeleportEntity(i, view_as<float>({-1640.0, -7780.0, -420.0}), view_as<float>({0.0, 0.0, 0.0}), NULL_VECTOR);
				AcceptEntityInput(i, "Enable");
			}
		}
	}
	return Plugin_Handled;
}
public void OnPluginStart() {
	
	LoadTranslations("common.phrases");
	//CreateTimer(20.0, MapFix, _, TIMER_FLAG_NO_MAPCHANGE);
	RegAdminCmd("sm_effect_fading",		Effect_Fading,		ADMFLAG_BAN, 	"sm_effect_fading [entity] [delay] [style]");
	RegAdminCmd("sm_effect_setmodel2",	ChaningModel_TG, 	ADMFLAG_BAN, 	"sm_setmodel_effect2 [target] [model]");
	RegAdminCmd("sm_effect_setmodel",	ChaningModel_1, 	ADMFLAG_BAN, 	"sm_setmodel_effect [entity] [model]");
	RegAdminCmd("sm_effect_velocity",	Effect_Velocity, 	ADMFLAG_BAN, 	"sm_effect_velocity [entity] [delay] [factor]");
	RegAdminCmd("sm_effect_flash",		Effect_Flash,		ADMFLAG_BAN,	"sm_effect_flash [player] [delay] [factor]");
	RegAdminCmd("sm_effect_alcool",		Effect_Alcool,		ADMFLAG_BAN,	"sm_effect_alcool [player] [amp] [factor] [delay]");
	RegAdminCmd("sm_effect_particles", Effect_Particle, 	ADMFLAG_BAN, 	"sm_effect_particles [player] [name] [delay]");
	RegAdminCmd("sm_effect_baloon",		Effect_Ballon, 		ADMFLAG_BAN, 	"sm_effect_baloon [amount]");
	
	
	RegAdminCmd("sm_effect_colorize",	Effect_Colorize, 	ADMFLAG_BAN,	"sm_effect_colorize [joueur] [rouge] [vert] [bleu] [alpha]");
	RegAdminCmd("sm_effect_panel",		Effect_Panel, 		ADMFLAG_ROOT,	"sm_effect_panel [entity] [delay] [text]");
	RegAdminCmd("sm_effect_time",		EffectTime, 		ADMFLAG_CHEATS,	"sm_effect_time [day/night] [delay]");
	RegAdminCmd("sm_effect_createzone", Command_Spawn_BombZone, ADMFLAG_ROOT);
	RegAdminCmd("sm_effect_spray",		Cmd_Spray, 			ADMFLAG_BAN);
	RegAdminCmd("sm_effect_spraytag", 	Effect_Tag,			ADMFLAG_ROOT);
	RegAdminCmd("sm_effect_camtag", 	Effect_CamTag,			ADMFLAG_ROOT);
	
	
	RegAdminCmd("sm_effect_resize",		EffectResize,		ADMFLAG_CHEATS,	"sm_effect_resize [entity] [size] [delay]");
	RegAdminCmd("sm_effect_group",		Effect_Group,		ADMFLAG_BAN,	"sm_effect_group [groupID]");
	
	RegAdminCmd("sm_effect_sun",		EffectSun,			ADMFLAG_CHEATS,	"sm_effect_sun [hours] [minutes]");
	RegAdminCmd("sm_effect_weather",	Effect_Weather,		ADMFLAG_KICK,	"sm_effect_weather [weather]");
	
	RegAdminCmd("sm_effect_loto",		Cmd_Loto,			ADMFLAG_CHEATS, "sm_effect_loto [amount]");
	RegAdminCmd("sm_effect_fixes",		Cmd_Fixes,			ADMFLAG_BAN, "sm_effect_fixes");
	
	RegServerCmd("sm_effect_text", 		Cmd_Text, "sm_effect_text x y z a r g b message time");
	
	RegConsoleCmd("sm_cut",				GiveMeCut);
	
	RegAdminCmd("rp_time",				EffectTime,			ADMFLAG_CHEATS);
	RegAdminCmd("rp_color2",				cmd_SetColor,		ADMFLAG_BAN);
	
	PrecacheGeneric("particles/effect_particles01.pcf", true);
	PrecacheGeneric("particles/effect_particles02.pcf", true);
	PrecacheGeneric("particles/effect_particles04.pcf", true);
	PrecacheGeneric("particles/tsx-rp-v002.pcf", true);
	
	
	for(int i=1; i<=MaxClients; i++) {
		if( !IsValidClient(i) )
			continue;
		
		SDKHook(i, SDKHook_PostThinkPost, think);		
	}
	{
		g_hDict = CreateTrie();
		g_hLocations = CreateArray();
		
		Handle hLocation;
		int iIndex;
		// ----------------------------------
		// 1
		hLocation = CreateArray(6);
		PushArrayArray(hLocation, view_as<float>({0.0, 0.0, 0.0, 	0.0, 0.0, 100.0}), 6);
		PushArrayArray(hLocation, view_as<float>({0.0, 0.0, 100.0, 	50.0, 0.0, 50.0}), 6);
		
		iIndex = PushArrayCell(g_hLocations, hLocation);
		SetTrieValue(g_hDict, "1", iIndex);
		// ----------------------------------
		// 2
		hLocation = CreateArray(6);
		PushArrayArray(hLocation, view_as<float>({0.0, 0.0, 0.0, 	50.0, 0.0, 0.0}), 6);
		PushArrayArray(hLocation, view_as<float>({50.0, 0.0, 0.0, 	50.0, 0.0, 50.0}), 6);
		PushArrayArray(hLocation, view_as<float>({50.0, 0.0, 50.0, 	0.0, 0.0, 50.0}), 6);
		PushArrayArray(hLocation, view_as<float>({0.0, 0.0, 50.0, 	0.0, 0.0, 100.0}), 6);
		PushArrayArray(hLocation, view_as<float>({0.0, 0.0, 100.0, 	50.0, 0.0, 100.0}), 6);
		iIndex = PushArrayCell(g_hLocations, hLocation);
		SetTrieValue(g_hDict, "2", iIndex);
		// ----------------------------------
		// 3
		hLocation = CreateArray(6);
		PushArrayArray(hLocation, view_as<float>({0.0, 0.0, 0.0, 	0.0, 0.0, 100.0}), 6);
		PushArrayArray(hLocation, view_as<float>({0.0, 0.0, 0.0, 	50.0, 0.0, 0.0}), 6);
		PushArrayArray(hLocation, view_as<float>({0.0, 0.0, 50.0, 	50.0, 0.0, 50.0}), 6);
		PushArrayArray(hLocation, view_as<float>({0.0, 0.0, 100.0, 	50.0, 0.0, 100.0}), 6);
		iIndex = PushArrayCell(g_hLocations, hLocation);
		SetTrieValue(g_hDict, "3", iIndex);
		// ----------------------------------
		// 4
		hLocation = CreateArray(6);
		PushArrayArray(hLocation, view_as<float>({0.0, 0.0, 0.0, 	0.0, 0.0, 100.0}), 6);
		PushArrayArray(hLocation, view_as<float>({50.0, 0.0, 50.0, 	50.0, 0.0, 100.0}), 6);
		PushArrayArray(hLocation, view_as<float>({0.0, 0.0, 50.0, 	50.0, 0.0, 50.0}), 6);
		iIndex = PushArrayCell(g_hLocations, hLocation);
		SetTrieValue(g_hDict, "4", iIndex);
		// ----------------------------------
		// 5
		hLocation = CreateArray(6);
		PushArrayArray(hLocation, view_as<float>({50.0, 0.0, 0.0, 	0.0, 0.0, 0.0}), 6);
		PushArrayArray(hLocation, view_as<float>({0.0, 0.0, 0.0, 	0.0, 0.0, 50.0}), 6);
		PushArrayArray(hLocation, view_as<float>({0.0, 0.0, 50.0, 	50.0, 0.0, 50.0}), 6);
		PushArrayArray(hLocation, view_as<float>({50.0, 0.0, 50.0, 	50.0, 0.0, 100.0}), 6);
		PushArrayArray(hLocation, view_as<float>({50.0, 0.0, 100.0, 	0.0, 0.0, 100.0}), 6);
		iIndex = PushArrayCell(g_hLocations, hLocation);
		SetTrieValue(g_hDict, "5", iIndex);
		// ----------------------------------
		// 6
		hLocation = CreateArray(6);
		PushArrayArray(hLocation, view_as<float>({50.0, 0.0, 0.0, 	50.0, 0.0, 100.0}), 6);
		PushArrayArray(hLocation, view_as<float>({50.0, 0.0, 0.0, 	0.0, 0.0, 0.0}), 6);
		PushArrayArray(hLocation, view_as<float>({0.0, 0.0, 0.0, 	0.0, 0.0, 50.0}), 6);
		PushArrayArray(hLocation, view_as<float>({0.0, 0.0, 50.0, 	50.0, 0.0, 50.0}), 6);
		iIndex = PushArrayCell(g_hLocations, hLocation);
		SetTrieValue(g_hDict, "6", iIndex);
		// ----------------------------------
		// 7
		hLocation = CreateArray(6);
		PushArrayArray(hLocation, view_as<float>({50.0, 0.0, 0.0, 	0.0, 0.0, 100.0}), 6);
		PushArrayArray(hLocation, view_as<float>({0.0, 0.0, 100.0, 	50.0, 0.0, 100.0}), 6);
		iIndex = PushArrayCell(g_hLocations, hLocation);
		SetTrieValue(g_hDict, "7", iIndex);
		// ----------------------------------
		// 8
		hLocation = CreateArray(6);
		PushArrayArray(hLocation, view_as<float>({0.0, 0.0, 0.0, 	0.0, 0.0, 100.0}), 6);
		PushArrayArray(hLocation, view_as<float>({50.0, 0.0, 0.0, 	50.0, 0.0, 100.0}), 6);
		PushArrayArray(hLocation, view_as<float>({0.0, 0.0, 100.0, 	50.0, 0.0, 100.0}), 6);
		PushArrayArray(hLocation, view_as<float>({0.0, 0.0, 0.0, 	50.0, 0.0, 0.0}), 6);
		PushArrayArray(hLocation, view_as<float>({0.0, 0.0, 50.0, 	50.0, 0.0, 50.0}), 6);
		iIndex = PushArrayCell(g_hLocations, hLocation);
		SetTrieValue(g_hDict, "8", iIndex);
		// ----------------------------------
		// 9
		hLocation = CreateArray(6);
		PushArrayArray(hLocation, view_as<float>({0.0, 0.0, 0.0, 	0.0, 0.0, 100.0}), 6);
		PushArrayArray(hLocation, view_as<float>({0.0, 0.0, 50.0, 	50.0, 0.0, 50.0}), 6);
		PushArrayArray(hLocation, view_as<float>({0.0, 0.0, 100.0, 	50.0, 0.0, 100.0}), 6);
		PushArrayArray(hLocation, view_as<float>({50.0, 0.0, 50.0, 	50.0, 0.0, 100.0}), 6);
		
		
		iIndex = PushArrayCell(g_hLocations, hLocation);
		SetTrieValue(g_hDict, "9", iIndex);	
		// ----------------------------------
		// 0
		hLocation = CreateArray(6);
		PushArrayArray(hLocation, view_as<float>({0.0, 0.0, 0.0, 	0.0, 0.0, 100.0}), 6);
		PushArrayArray(hLocation, view_as<float>({50.0, 0.0, 0.0, 	50.0, 0.0, 100.0}), 6);
		PushArrayArray(hLocation, view_as<float>({0.0, 0.0, 100.0, 	50.0, 0.0, 100.0}), 6);
		PushArrayArray(hLocation, view_as<float>({0.0, 0.0, 0.0, 	50.0, 0.0, 0.0}), 6);
		iIndex = PushArrayCell(g_hLocations, hLocation);
		SetTrieValue(g_hDict, "0", iIndex);
	}
	
	AddNormalSoundHook(sound_hook);
}
public Action Cmd_Text(int args) {
	float pos[3], ang[3];
	pos[0] = GetCmdArgFloat(1);
	pos[1] = GetCmdArgFloat(2);
	pos[2] = GetCmdArgFloat(3);
	ang[1] = GetCmdArgFloat(4);
	
	int r = GetCmdArgInt(5);
	int g = GetCmdArgInt(6);
	int b = GetCmdArgInt(7);
	int s = GetCmdArgInt(8);
	
	char text[255];
	GetCmdArg(9, text, sizeof(text));
	float time = GetCmdArgFloat(10);
	if( time <= 1.0 )
		time = 1.0;
	if( time >= 600.0 )
		time = 600.0;
	
	int ent = Point_WorldText(pos, ang, text, s, r, g, b);
	rp_ScheduleEntityInput(ent, time, "Kill");
}
stock int Point_WorldText(float fPos[3], float fAngles[3], char[] sText = "Source 2 Engine?", int iSize = 10,  int r = 255, int g = 255, int b = 255, any ...) 
{ 
    int iEntity = CreateEntityByName("point_worldtext"); 
     
    if(iEntity == -1) 
        return iEntity; 
     
    char sBuffer[512]; 
    VFormat(sBuffer, sizeof(sBuffer), sText, 8); 
    DispatchKeyValue(iEntity,     "message", sBuffer); 
     
    char sSize[4]; 
    IntToString(iSize, sSize, sizeof(sSize)); 
    DispatchKeyValue(iEntity,     "textsize", sSize); 
     
    char sColor[16]; 
    Format(sColor, sizeof(sColor), "%d %d %d", r, g, b); 
    DispatchKeyValue(iEntity,     "color", sColor); 
     
    TeleportEntity(iEntity, fPos, fAngles, NULL_VECTOR); 
     
    return iEntity; 
}  
public Action sound_hook(int clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags) {
	
	if( StrContains(sample, "coin_pickup") != -1 ) {
		
		volume = 0.1;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}
public void OnEntityCreated(int entity, const char[] classname)  {
	if( StrEqual(classname, "item_coop_coin") ) {
		SDKHook(entity, SDKHook_Touch, OnTouch);
	}
}

public void OnTouch(int entity, int client) {
	if( IsValidClient(client) ) {
		PrintToChatAll("%N a ramassé une pièce !", client);
		SDKUnhook(entity, SDKHook_Touch, OnTouch);
		
		
		rp_ClientMoney(client, i_Money, Math_GetRandomInt(1, 5)*10);
	}
}
public Action Effect_Ballon(int client, int args) {
	int entity = GetClientAimTarget(client, false);
	int amount = GetCmdArgInt(1);
	
	if( amount == 0 )
		amount = 1;
	
	if( amount < 0 ) {
		SDKUnhook(entity, SDKHook_OnTakeDamage, OnTakeDamage);
		g_iBallon[entity] = 0;
		return Plugin_Handled;
	}
	
	if( g_iBallon[entity] == 0 ) {
		SDKHook(entity, SDKHook_OnTakeDamage, OnTakeDamage);
	}
	g_iBallon[entity] += amount;
	return Plugin_Handled;
}
public Action OnTakeDamage(int entity, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3]) {
	g_iBallon[entity]--;
	
	AttachParticle(entity, "confetti_balloons", 10.0);
	float dstOrigin[3];
	Entity_GetAbsOrigin(entity, dstOrigin);
	dstOrigin[2] += 20.0;
	
	TE_SetupBeamRingPoint(dstOrigin, 40.0, 50.0, g_cBeam, 0, 0, 30, 2.0, 5.0, 20.0, {0, 255, 0, 250}, 10, 0);
	TE_SendToAll();
	
	if( g_iBallon[entity] == 0 ) {
		SDKUnhook(entity, SDKHook_OnTakeDamage, OnTakeDamage);
	}
}
public Action Effect_CamTag(int client, int args) {
	char arg1[65];
	GetCmdArg(1, arg1, sizeof(arg1));
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	
	if ((target_count = ProcessTargetString(arg1, client, target_list, MAXPLAYERS,COMMAND_FILTER_CONNECTED|COMMAND_FILTER_NO_MULTI,target_name, sizeof(target_name),tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		SetEntPropEnt(client, Prop_Send, "m_hViewEntity", -1);
		SetEntProp(client, Prop_Send, "m_bShouldDrawPlayerWhileUsingViewEntity", 0);
		SetEntProp(client, Prop_Send, "m_iDefaultFOV", 0);
		SetEntProp(client, Prop_Send, "m_iObserverMode", 0);
		return Plugin_Handled;
	}
	
	
	for (int i = 0; i < target_count; i++) {
		if( target_list[i] == client )
			continue;
		
		SetEntPropEnt(client, Prop_Send, "m_hViewEntity", target_list[i]);
		SetEntProp(client, Prop_Send, "m_bShouldDrawPlayerWhileUsingViewEntity", 1);
		SetEntProp(client, Prop_Send, "m_iObserverMode", 1);
	}
	return Plugin_Handled;
}
public Action Effect_Tag(int client, int args) {
	float pos[2][3];
	char arg[12], arg2[12];
	GetCmdArg(1, arg, sizeof(arg));
	GetCmdArg(2, arg2, sizeof(arg2));
	
	if( StrEqual(arg2, "11") || StrEqual(arg2, "21") || StrEqual(arg2, "51") || StrEqual(arg2, "71") ||  StrEqual(arg2, "91") ||  StrEqual(arg2, "131") ) {
		Format(arg2, sizeof(arg2), "%sa", arg2);
	}
	if( StrEqual(arg2, "31") || StrEqual(arg2, "41") || StrEqual(arg2, "61") ||  StrEqual(arg2, "121") ) {
		Format(arg2, sizeof(arg2), "%sb", arg2);
	}
	
	char path[128];
	Format(path, sizeof(path), "deadlydesire/groups/princeton/%s.vmt", arg2);
	
	if( StrEqual(arg, "tower") ) {
		pos[0][0] = pos[1][0] = 790.0;
		pos[0][1] = pos[1][1] = 1150.0;
		pos[0][2] = pos[1][2] = -2060.0;
		
		pos[1][0] = 218.0;
	}
	else if( StrEqual(arg, "nuke") ) {
		pos[0][0] = pos[1][0] = -4224.0;
		pos[0][1] = pos[1][1] = -6028.0;
		pos[0][2] = pos[1][2] = -1842.0;
		
		pos[1][0] = -1942.0;
		pos[1][1] = -6272.0;
	}
	else if( StrEqual(arg, "villa") ) {
		// -6616.3 2075.9 -2169.1
		// -6984.0 3827.4 -2228.3

		pos[0][0] = -6616.3;
		pos[0][1] = 2075.9;
		pos[0][2] = -2169.1;
		
		
		pos[1][0] = -6984.0;
		pos[1][1] = 3827.4;
		pos[1][2] = -2228.3;
		
	}
	
	int precache = PrecacheDecal(path);
	for(int i=0; i<=1; i++) {
		TE_Start("World Decal");
		TE_WriteVector("m_vecOrigin",pos[i]);
		TE_WriteNum("m_nIndex", precache);
		TE_SendToAll();
	}
	
	return Plugin_Handled;
}
public Action Cmd_Spray(int client, int args) {
	char path[128], arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	Format(path, sizeof(path), "deadlydesire/groups/princeton/%s.vmt", arg);
	
	int precache = PrecacheDecal(path);
	float origin[3], origin2[3], angles[3];
	GetClientEyeAngles(client, angles);
	GetClientEyePosition(client, origin);
	Handle tr = TR_TraceRayFilterEx(origin, angles, MASK_SOLID, RayType_Infinite, FilterToOne, client);
	if( tr && TR_DidHit(tr) ) {
		TR_GetEndPosition(origin2, tr);
		if( GetVectorDistance(origin, origin2) <= 1000.0 ) {
			PrintToChatAll("%.1f %.1f %.1f", origin2[0], origin2[1], origin2[2]);
			TE_Start("World Decal");
			TE_WriteVector("m_vecOrigin",origin2);
			TE_WriteNum("m_nIndex", precache);
			TE_SendToAll();
		}
	}
	CloseHandle(tr);
	
	return Plugin_Handled;
}
public Action Command_Spawn_BombZone(int client, int args) {
	
	char arg[64];
	GetCmdArg(1, arg, sizeof(arg));
	
	float vAngles[3], vOrigin[3], vBuffer[3], vStart[3], Distance, position[3];
	
	GetClientEyePosition(client,vOrigin);
	GetClientEyeAngles(client, vAngles);
	
	//get endpoint for teleport
	Handle trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterStuff);
	
	if(TR_DidHit(trace)) {   	 
		TR_GetEndPosition(vStart, trace);
		//GetVectorDistance(vOrigin, vStart, false);
		Distance = -35.0;
		GetAngleVectors(vAngles, vBuffer, NULL_VECTOR, NULL_VECTOR);
		position[0] = vStart[0] + (vBuffer[0]*Distance);
		position[1] = vStart[1] + (vBuffer[1]*Distance);
		position[2] = vStart[2] + (vBuffer[2]*Distance);
		CloseHandle(trace);
		
		// Spawn
		int ent = CreateEntityByName(arg);
		if (ent != -1) {
			DispatchKeyValue(ent, "pushdir", "0 90 0");
			DispatchKeyValue(ent, "speed", "500");
			DispatchKeyValue(ent, "spawnflags", "64");
		}
		
		DispatchSpawn(ent);
		ActivateEntity(ent);
		
		TeleportEntity(ent, position, NULL_VECTOR, NULL_VECTOR);
		PrecacheModel("models/props_c17/metalladder001.mdl", true);
		SetEntityModel(ent, "models/props_c17/metalladder001.mdl");
		
		float minbounds[3] = {-100.0, -100.0, 0.0};
		float maxbounds[3] = {100.0, 100.0, 200.0};
		SetEntPropVector(ent, Prop_Send, "m_vecMins", minbounds);
		SetEntPropVector(ent, Prop_Send, "m_vecMaxs", maxbounds);
		
		SetEntProp(ent, Prop_Send, "m_nSolidType", 2);
		
		int enteffects = GetEntProp(ent, Prop_Send, "m_fEffects");
		enteffects |= 32;
		SetEntProp(ent, Prop_Send, "m_fEffects", enteffects);
	}
	else {
		CloseHandle(trace);
	}   
	
	return (Plugin_Handled);
}

void FormatNumberInt(int value, char[] buffer, int size) {
    char[] helper = new char[size];
    IntToString(value, helper, size);
    strcopy(buffer, size, helper);

    int length = strlen(helper);

    int n_helper;

    if (helper[0] == '-') {
        n_helper += ((length-1) % 3) + 1;

        if (n_helper == 1) {
            n_helper = 4;
        }
    }
    else {
        n_helper += length % 3;

        if (n_helper == 0) {
            n_helper = 3;
        }
    }

    int n_buffer = n_helper;

    while (n_helper < length) {
        buffer[n_buffer] = ' ';
        strcopy(buffer[n_buffer + 1], size, helper[n_helper]);
        n_buffer += 4;
        n_helper += 3;
    }
}
public void DrawNumberLOTO(const char sText[512], float fOrigin[3], float scale, bool moving) {
	
	int a = 0;
	float fIndentation = scale, fLastIndentation = scale;
	
	char sChar[2];
	int iLength = strlen(sText), iIndex, iColor[4], iSize;
	Handle hLocation;
	bool bKnownChar = false;
	float fLocation[3], fData[6], fStart[3], fEnd[3];
	
	fLocation = fOrigin;
	fLocation[2] += 100.0;
	
	iColor[0] = 0;
	iColor[1] = 255;
	iColor[2] = 0;
	iColor[3] = 255;
	float ampl = 0.0;
	if( moving ) {
		ampl = 10.0;
	}
	
	
	while(a < iLength) {
		fLastIndentation = fIndentation;
		Format(sChar, sizeof(sChar), "%c", sText[iLength-a-1]);
		a += 1;
		
		sChar[0] = CharToLower(sChar[0]);
		
		// Is this letter in our dictionary?
		bKnownChar = GetTrieValue(g_hDict, sChar, iIndex);
		
		// Reset x value
		fLocation[0] = fOrigin[0];
		
		if(bKnownChar) {
			hLocation = GetArrayCell(g_hLocations, iIndex);
			
			iSize = GetArraySize(hLocation);
			for(int i=0;i<iSize;i++) {
				GetArrayArray(hLocation, i, fData, 6);
				float vec1[3];
				float vec2[3];
				
				vec1[0] = fData[0];
				vec1[1] = fData[1];
				vec1[2] = fData[2];
				vec2[0] = fData[3];
				vec2[1] = fData[4];
				vec2[2] = fData[5];
				
				ScaleVector(vec1, scale);
				ScaleVector(vec2, scale);
				
				
				fStart[0] = vec1[0];
				fStart[1] = vec1[1];
				fStart[2] = vec1[2];
				
				fEnd[0] = vec2[0];
				fEnd[1] = vec2[1];
				fEnd[2] = vec2[2];
				
				fStart[0] += fLastIndentation;
				fEnd[0] += fLastIndentation;
				
				
				AddVectors(fLocation, fStart, fStart);
				AddVectors(fLocation, fEnd, fEnd);
				
				TE_SetupBeamPoints(fStart, fEnd, g_cModel, 0, 0, 0, 10.1, 5.0 * scale, 5.0 * scale, 0, ampl, iColor, 12);
				TE_SendToAll();
			}
			
			fIndentation += (45.0 * scale);
		}
		
		fIndentation += (30.0 * scale);
		
	}
}
public Action Cmd_Loto(int client, int args) {
	float fOrigin[3];
	fOrigin[0] = 1750.0;
	fOrigin[1] = -4925.0;
	fOrigin[2] = -1750.0;
	
	int amount = GetCmdArgInt(1);
	bool moving = false;
	char sText[512], szDayOfWeek[12], szHours[12], szMinutes[12], szSecondes[12];
	
	FormatTime(szDayOfWeek, 11, "%w");
	FormatTime(szHours, 11, "%H");
	FormatTime(szMinutes, 11, "%M");
	FormatTime(szSecondes, 11, "%S");
	
	if( StringToInt(szDayOfWeek) == 2 || StringToInt(szDayOfWeek) == 6 ) {	// Mardi & Samedi
		if( StringToInt(szHours) == 20 && StringToInt(szMinutes) == 59 && StringToInt(szSecondes) >= 45 ) {	// 21h00m00s
			moving = true;
		}
	}
	
	IntToString(amount/100*70, sText, sizeof(sText));
	FormatNumberInt(StringToInt(sText),	sText,sizeof(sText));
	DrawNumberLOTO(sText, fOrigin, 1.0, moving);
	
	fOrigin[2] -= 90.0;
	IntToString(amount/100*20, sText, sizeof(sText));
	FormatNumberInt(StringToInt(sText),	sText,sizeof(sText));
	DrawNumberLOTO(sText, fOrigin, 0.66, moving);
	
	fOrigin[2] -= 60.0;
	IntToString(amount/100*10, sText, sizeof(sText));
	FormatNumberInt(StringToInt(sText),	sText,sizeof(sText));
	DrawNumberLOTO(sText, fOrigin, 0.33, moving);
	
	
	
	return Plugin_Handled;
}
public Action cmd_SetColor(int client, int args) {
	if( args < 5 || args > 5) {
		if( client != 0 )
			ReplyToCommand(client, "Utilisation: rp_color \"joueur\" \"rouge\" \"vert\" \"bleu\" \"alpha\"");
		else
		PrintToServer("Utilisation: rp_color2 \"joueur\" \"rouge\" \"vert\" \"bleu\" \"alpha\"");
		
		return Plugin_Handled;
	}
	
	char arg1[64];
	GetCmdArg(1, arg1, sizeof( arg1 ) );
	
	char arg2[12], arg3[12], arg4[12], arg5[12];
	GetCmdArg(2, arg2, sizeof(arg2));
	GetCmdArg(3, arg3, sizeof(arg3));
	GetCmdArg(4, arg4, sizeof(arg4));
	GetCmdArg(5, arg5, sizeof(arg5));
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	
	if ((target_count = ProcessTargetString(arg1, client, target_list, MAXPLAYERS,COMMAND_FILTER_CONNECTED|COMMAND_FILTER_ALIVE,target_name, sizeof(target_name),tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	for (int i = 0; i < target_count; i++) {
		int target = target_list[i];
		ReplyToCommand(client, "[TSX-RP] %N a été coloré.", target);
		Colorize(target, StringToInt(arg2), StringToInt(arg3), StringToInt(arg4), StringToInt(arg5));
	}
	
	return Plugin_Handled;
}

public Action Effect_Weather(int client, int args) {
	if( args < 1 ) {
		ReplyToCommand(client, "sm_effect_weather [rain|snow|sunny|storm] [percent]");
		return Plugin_Handled;
	}
	
	int id = 0, type, amount;
	char arg1[12], arg2[12];
	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));
	
	amount = StringToInt(arg2);
	if( amount <= 0 )
		amount = 0;
	if( amount >= 100 )
		amount = 100;
	
	amount = RoundFloat(float(amount) * 2.55);
	
	if( args == 1 ) {
		amount = GetRandomInt(1, 255);
		ReplyToCommand(client, "puissance: %.2f%%", float(amount)/255.0 * 100.0);
	}
	
	if( StrEqual(arg1, "rain") ) {
		type = 4;
		g_iWeatherType = 0;
	}
	else if( StrEqual(arg1, "snow") ) {
		type = 2;
		g_iWeatherType = 2;
		g_iWeatherSpeed = amount;
	}
	else if( StrEqual(arg1, "storm") ) {
		
		type = 4;
		g_iWeatherType = 1;
		g_iWeatherSpeed = amount;
		amount = 255;
		ServerCommand("rp_time night 1");
	}
	else if( StrEqual(arg1, "fog") ) {
		type = 4;
		g_iWeatherType = 0;
		
		amount = 255 - amount;
		
		while( (id = FindEntityByClassname(id, "env_fog_controller")) > 0 ) {
			
			SetEntPropFloat(id, Prop_Send, "m_fog.start",  0.0);
			SetEntPropFloat(id, Prop_Send, "m_fog.end", 500.0+float(amount)*6.0);
			
			SetVariantColor({128, 128, 128, 255});
			rp_AcceptEntityInput(id, "SetColor");
			SetVariantColor({128, 128, 128, 255});
			rp_AcceptEntityInput(id, "SetColorSecondary");
		}
		
		amount = 0;
	}
	else if( StrEqual(arg1, "sunny") || StrEqual(arg1, "sun") || StrEqual(arg1, "off") || StrEqual(arg1, "none") ) {
		type = 4;
		amount = 0;
		g_iWeatherType = 0;
		ServerCommand("rp_time day 1");
		while( (id = FindEntityByClassname(id, "env_fog_controller")) > 0 ) {
			
			SetEntPropFloat(id, Prop_Send, "m_fog.start",  0.0);
			SetEntPropFloat(id, Prop_Send, "m_fog.end", 500.0+float(amount)*6.0);
			
			SetVariantColor({40, 40, 40, 255});
			rp_AcceptEntityInput(id, "SetColor");
			SetVariantColor({40, 40, 40, 255});
			rp_AcceptEntityInput(id, "SetColorSecondary");
		}
	}
	else {
		ReplyToCommand(client, "sm_effect_weather [rain|snow|sunny] [percent]");
		return Plugin_Handled;
	}
	
	
	id = 0;
	while( (id = FindEntityByClassname(id, "func_precipitation")) > 0 ) {
		SetEntProp(id, Prop_Send, "m_nPrecipType", type);
		SetEntityRenderColor(id, 255, 255, 255, amount);
	}
	
	return Plugin_Handled;
}
public Action EffectSun(int client, int arg) {
	//static int id = 0;
	int id = 0;

	if( id <= 0 ) {
		id = FindEntityByClassname(0, "env_cascade_light");
		SetEntPropFloat(id, Prop_Send, "m_flMaxShadowDist", 1250.0);
	}
	
	char arg1[12], arg2[12], arg3[12];
	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));
	GetCmdArg(3, arg3, sizeof(arg3));
	
	
	float hours = StringToFloat(arg1);
	float minutes = StringToFloat(arg2);
	float seconds = StringToFloat(arg3);
	
	float x, y;
	
	if( hours < 6.0 || hours > 18.0 )
		hours = 12.0;
	
	x = (((hours*3600.0) + minutes * 60.0) + seconds) / (3600.0);
	y = (((hours*3600.0) + minutes * 60.0) + seconds) / 240.0;
	
	x = (Sine((x-6.0)/(12.0/3.141592654))*(80.0-32.5)) + 32.5;
	if( x < 32.5 )
		x = 32.5;
	
	char args[128];
	Format(args, sizeof(args), "%f %f 0.0", x, y);
	
	SetVariantString(args);
	rp_AcceptEntityInput(id, "SetAngles");
	return Plugin_Handled;
}
public Action Effect_Group(int client, int args) {
	
	char path[128], arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	Format(path, sizeof(path), "deadlydesire/midway/group/%s.vmt", arg);
	
	int precache = PrecacheDecal(path, true);
	
	for(int i=1; i<=2049; i++) {
		if( !IsValidEdict(i) )
			continue;
		if( !IsValidEntity(i) )
			continue;
		
		char classname[128];
		GetEdictClassname(i, classname, sizeof(classname));
		
		if( StrContains(classname, "info_target") == 0 ) {
			char targetname[128];
			GetEntPropString(i, Prop_Data, "m_iName", targetname, sizeof(targetname));
			
			if( StrContains(targetname, "pvp_decal") == 0 ) {
				float pos[3];
				Entity_GetAbsOrigin(i, pos);
				
				TE_Start("World Decal");
				TE_WriteVector("m_vecOrigin",pos);
				TE_WriteNum("m_nIndex", precache);
				TE_SendToAll();
			}
		}
	}
	
	return Plugin_Handled;
}

public Action ChaningModel_TG(int client, int args) {
	if( args < 2 || args > 2) {
		return Plugin_Handled;
	}
	
	char arg1[64];
	
	GetCmdArg(1, arg1, sizeof( arg1 ) );
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	
	if ((target_count = ProcessTargetString(
	arg1,
	client,
	target_list,
	MAXPLAYERS,
	COMMAND_FILTER_CONNECTED|COMMAND_FILTER_NO_BOTS|COMMAND_FILTER_NO_MULTI|COMMAND_FILTER_ALIVE,
	target_name,
	sizeof(target_name),
	tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	char arg2[256];
	GetCmdArg(2, arg2, sizeof( arg2 ) );
	
	for (int i = 0; i < target_count; i++) {
		int target = target_list[i];
		ClientCommand(client, "sm_effect_setmodel \"%i\" \"%s\"", target, arg2); 
	}
	return Plugin_Handled;
}
public Action GiveMeCut(int client, int args) {
	int wepid = GetPlayerWeaponSlot( client, 2 );
	if( !IsValidEdict(wepid) && !IsValidEntity(wepid) ) {
		GivePlayerItem(client, "weapon_knife");
	}
}
public Action Effect_Flash(int client, int args) {
	int target = GetCmdArgInt(1);
	
	g_flFlash_start[target] = GetGameTime();
	g_flFlash_end[target] = GetGameTime() + GetCmdArgFloat(2);
	g_flFlash_amp[target] = GetCmdArgFloat(3);
	return Plugin_Handled;
}
public Action Effect_Alcool(int client, int args) {
	int target = GetCmdArgInt(1);
	
	float duration = GetCmdArgFloat(4);
	if( duration == 0.0 )
		duration = 60.0;
	
	g_flAlcool_start[target] = GetGameTime();
	g_flAlcool_end[target] = GetGameTime() + duration;
	g_flAlcool_amp[target] = GetCmdArgFloat(2);
	g_flAlcool_length[target] = GetCmdArgFloat(3);
	
	if( g_flAlcool_amp[target] == 0.0 )
		g_flAlcool_amp[target] = 20.0;
	if( g_flAlcool_length[target] == 0.0 )
		g_flAlcool_length[target] = 600.0;
	
	CreateTimer(duration+0.01, StopAlcool, target);
	
	return Plugin_Handled;
}
public Action StopAlcool(Handle timer, any client) {
	static Handle cvar;
	
	if( cvar == INVALID_HANDLE ) {
		cvar = FindConVar("host_timescale");
	}
	
	SendConVarValue(client, cvar, "1.0000");
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
}
public Action  EffectResize(int client, int args) {
	char arg1[12], arg2[12], arg3[12];
	
	GetCmdArg(1, arg1, 11);
	GetCmdArg(2, arg2, 11);
	GetCmdArg(3, arg3, 11);
	
	int entity = StringToInt(arg1);
	float facteur = StringToFloat(arg2);
	float delay = StringToFloat(arg3);
	
	if( facteur <= 0.0 )
		facteur = 0.0;
	if( facteur >= 10.0 )
		facteur = 10.0;
	
	if( entity < 1 )
		entity = client;
	
	g_fEntity_star3[ entity ] = (GetGameTime());
	g_fEntity_over3[ entity ] = (GetGameTime()+ delay);
	g_fEntity_size_from[ entity ] = GetEntPropFloat(entity, Prop_Send, "m_flModelScale");
	g_fEntity_size_to[ entity ] = facteur;
	
	if( IsValidClient(entity) ) {
		
		SetEntPropEnt(entity, Prop_Send, "m_hObserverTarget", 0);
		SetEntProp(entity, Prop_Send, "m_iObserverMode", 1);
		SetEntProp(entity, Prop_Send, "m_bDrawViewmodel", 0);
		SetEntPropFloat(entity, Prop_Data, "m_flLaggedMovementValue", 0.5);
		
		CreateTimer( (delay+1.0) , ChaningModel_3, entity);
	}
	
	return Plugin_Handled;
}
public Action Effect_Panel(int client, int args) {
	char arg1[12], arg2[12], text[128];
	
	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));
	GetCmdArg(3, text, sizeof(text));
	
	int target = StringToInt(arg1);
	float delay = StringToFloat(arg2);
	
	g_iProgress[target] = 0;
	g_flProgress_start[target] = GetGameTime();
	g_flProgress_end[target] = GetGameTime() + delay;
	g_szProgress[target] = text;
	//	Format(g_szProgress[target], sizeof(g_szProgress[target]), "%s", text);
	
	Handle kv = INVALID_HANDLE;
	kv = Build_NAV_PROGRESS( g_szProgress[target], 1000, 0, true );
	ShowVGUIPanel(target, "nav_progress", kv, true);
	
	CreateTimer(0.01, msg_generate, target, TIMER_FLAG_NO_MAPCHANGE);
}
public Action msg_generate(Handle timer, any client) {
	if(client == 0 || !IsClientInGame(client)) {
		return Plugin_Stop;
	}
	
	static int tick = 1000;
	Handle kv = INVALID_HANDLE;
	
	if(g_iProgress[client] < tick) {
		
		g_iProgress[client] = RoundFloat( (1.0/(g_flProgress_end[client]-g_flProgress_start[client])) * ( GetGameTime() - g_flProgress_start[client] ) * float(tick));
		
		if(g_iProgress[client] > tick)
			g_iProgress[client] = tick;
		if(g_iProgress[client] < 0)
			g_iProgress[client] = 0;
		
		kv = Build_NAV_PROGRESS( g_szProgress[client], 1000, g_iProgress[client], true );
		ShowVGUIPanel(client, "nav_progress", kv, true);
		
		CreateTimer(0.01, msg_generate, client, TIMER_FLAG_NO_MAPCHANGE);
	}
	else {
		kv = CreateKeyValues("data");
		ShowVGUIPanel(client, "nav_progress", kv, false);
	}
	CloseHandle(kv);
	return Plugin_Continue;
} 
stock Handle Build_NAV_PROGRESS( const char[] msg, int ticks, int current, bool showPercent = true ) {
	char buffer[192];
	buffer[0] = '\0';
	
	if ( showPercent && ticks ) {
		Format(buffer, sizeof(buffer), "%s %.1f%", msg, float(current)*100.0/float(ticks));
	}
	else {
		strcopy(buffer, sizeof(buffer), msg);
	}
	
	Handle kv = CreateKeyValues("data");
	KvSetString(kv,    "msg",        buffer);
	KvSetNum(kv,    "total",    ticks);
	KvSetNum(kv,    "current",    current);
	
	return kv;
}  
public Action EffectTime(int client, int args) {
	char arg1[12], arg2[12];
	GetCmdArg(1, arg1, sizeof(arg1));
	
	float time = 60.0;
	
	if( args == 2 ) {
		GetCmdArg(2, arg2, sizeof(arg2));
		time = StringToFloat(arg2);
	}
	
	if( !StrEqual(arg1, "day", false) && !StrEqual(arg1, "night", false) ) {
		ReplyToCommand(client, "type inconu, utiliser day ou night.");
		return Plugin_Handled;
	}
	
	if( StrEqual(arg1, "day", false) ) {
		g_iFADE_TIME_type = 1;
		ScheduleTargetInput("night_skybox", 60.0/4.0 + 0.1, "Unlock");
		ScheduleTargetInput("night_skybox", 60.0/4.0 + 0.25, "Open");
	}
	else {
		g_iFADE_TIME_type = 2;
		ScheduleTargetInput("night_skybox", 60.0/2.0 + 0.1, "Unlock");
		ScheduleTargetInput("night_skybox", 60.0/2.0 + 0.25, "Close");
	}
	
	g_flFADE_TIME_start = GetGameTime();
	g_flFADE_TIME_end = GetGameTime() + time;
	
	return Plugin_Handled;
}

public Action Effect_Colorize(int client, int args) {
	char arg1[12], arg2[12], arg3[12], arg4[12], arg5[12];
	
	GetCmdArg(1, arg1, 11);
	GetCmdArg(2, arg2, 11);
	GetCmdArg(3, arg3, 11);
	GetCmdArg(4, arg4, 11);
	GetCmdArg(5, arg5, 11);
	
	
	Colorize(StringToInt(arg1), StringToInt(arg2), StringToInt(arg3), StringToInt(arg4), StringToInt(arg5));

	return Plugin_Handled;
}

public Action  Effect_Velocity(int client, int args) {
	char arg1[12], arg2[12], arg3[12];
	
	GetCmdArg(1, arg1, 11);
	GetCmdArg(2, arg2, 11);
	GetCmdArg(3, arg3, 11);
	
	int entity = StringToInt(arg1);
	float delay = StringToFloat(arg2);
	float factor = StringToFloat(arg3);
	
	if( entity < 1 )
		entity = client;
	
	g_fEntity_star2[ entity ] = (GetGameTime());
	g_fEntity_over2[ entity ] = (GetGameTime()+ delay);
	g_fEntity_fact2[ entity ] = factor;
	
	return Plugin_Handled;
}
bool IsValidModel(const char[] modelname){
	
	return (FileExists(modelname, true) || FileExists(modelname, false)) && (StrContains(modelname, ".mdl", false) != -1);
	
}
public Action ChaningModel_1(int client, int args) {
	
	char path[128];
	GetCmdArg(2, path, 127);
	
	if( strlen(path) <= 3 ) {
		ReplyToCommand(client, "[EFFECT] Ce model: \"%s\" semble ne pas exister.", path);
		return Plugin_Handled;
	}
	if( !IsValidModel(path) ) {
		ReplyToCommand(client, "[EFFECT] Ce model: \"%s\" semble ne pas exister.", path);
		return Plugin_Handled;
	}
	if (!IsModelPrecached(path)) {
		if( PrecacheModel(path) == 0 ) {
			ReplyToCommand(client, "[EFFECT] Ce model: \"%s\" semble ne pas exister.", path);
			return Plugin_Handled;
		}
	}
	
	char arg1[12];
	GetCmdArg(1, arg1, 11);
	client = StringToInt(arg1);
	
	
	if( !IsValidClient(client) ) {
		return Plugin_Handled;
	}
	
	SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", 0);
	SetEntProp(client, Prop_Send, "m_iObserverMode", 1);
	SetEntProp(client, Prop_Send, "m_bDrawViewmodel", 0);
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 0.5);
	
	ServerCommand("sm_effect_fading %i 0.5 1", client);
	
	Handle dp;
	CreateDataTimer(0.5, ChaningModel_2, dp); 
	WritePackCell(dp, client);
	WritePackString(dp, path);
	
	return Plugin_Handled;
}
public Action ChaningModel_2(Handle timer, Handle dp) {
	
	ResetPack(dp);
	int client = ReadPackCell(dp);
	char path[128];
	ReadPackString(dp, path, 127);
	
	if( !IsValidClient(client) ) {
		return Plugin_Handled;
	}
	
	SetEntityModel(client, path);
	ServerCommand("sm_effect_fading %i 0.5 0", client);
	
	CreateTimer(1.0, ChaningModel_3, client);
	return Plugin_Handled;
}
public Action ChaningModel_3(Handle timer, any client) {
	
	if( !IsValidClient(client) ) {
		return Plugin_Handled;
	}
	
	SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", -1);
	SetEntProp(client, Prop_Send, "m_iObserverMode", 0);
	SetEntProp(client, Prop_Send, "m_bDrawViewmodel", 1);
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
	return Plugin_Handled;
}
public Action Effect_Fading(int client, int args) {
	
	char Arg1[12], Arg2[12], Arg3[12];
	GetCmdArg(1, Arg1, 11);
	GetCmdArg(2, Arg2, 11);
	GetCmdArg(3, Arg3, 11);
	
	int target = StringToInt(Arg1);
	
	
	if( target < 1 ) {
		target = client;
	}
	
//	Colorize(target, 255, 255, 255, StringToInt(Arg3) == 0 ? 255 : 0);
	g_fEntity_over[ target ] = (GetGameTime()+ StringToFloat(Arg2));
	g_fEntity_star[ target ] = (GetGameTime());
	g_iEntity_styl[ target ] = StringToInt(Arg3);
	
	return Plugin_Handled;
}



public void OnGameFrame() {
	
	for(int i=1; i<= MAX_ENTITIES; i++) {
		
		if( !IsValidEdict(i) ) {
			g_fEntity_over[i] = 0.0;
			g_fEntity_star[i] = 0.0;
			
			g_fEntity_over2[i] = 0.0;
			g_fEntity_star2[i] = 0.0;
			
			g_fEntity_over3[i] = 0.0;
			g_fEntity_star3[i] = 0.0;
			continue;
		}
		if( !IsValidEntity(i) ) {
			g_fEntity_over[i] = 0.0;
			g_fEntity_star[i] = 0.0;
			
			g_fEntity_over2[i] = 0.0;
			g_fEntity_star2[i] = 0.0;
			
			g_fEntity_over3[i] = 0.0;
			g_fEntity_star3[i] = 0.0;
			continue;
		}
		
		if( g_fEntity_over[i] >= GetGameTime() ) {
			
			float max = 255.0;
			int color = RoundFloat((max/(g_fEntity_over[i]-g_fEntity_star[i]) ) * (GetGameTime()-g_fEntity_star[i]));
			if( color > 255 ) {
				color = 255;
			}
			
			if( g_iEntity_styl[i] == 1 ) {
				color = RoundFloat(max-color);
			}
			
			Colorize(i, color, color, 255, color);
		}
		else if(g_fEntity_over[i] >= 0.1 ) {
			
			SetEntityRenderMode(i, RENDER_NORMAL);
			SetEntityRenderColor(i, 255, 255, 255, 255);
			
			if( g_iEntity_styl[i] == 1 ) {
				Colorize(i, 0, 0, 255, 0);
			}
			g_fEntity_over[i] = 0.0;
			g_fEntity_star[i] = 0.0;
		}
		
		if( g_fEntity_over2[i] >= GetGameTime() ) {
			
			float vecVelocity[3];
			GetEntPropVector(i, Prop_Data, "m_vecVelocity", vecVelocity);
			
			float facteur = ((g_fEntity_fact2[i]/(g_fEntity_over2[i]-g_fEntity_star2[i]) ) * (GetGameTime()-g_fEntity_star2[i]));
			if( facteur > 1.0 )
				facteur = 1.0;
			if( facteur < 0.0 )
				facteur = 0.0;
			
			vecVelocity[0] = vecVelocity[0] * facteur;
			vecVelocity[1] = vecVelocity[1] * facteur;
			
			SetEntPropVector(i, Prop_Data, "m_vecVelocity", vecVelocity);
		}
		else if(g_fEntity_over2[i] >= 0.1 ) {
			g_fEntity_over2[i] = 0.0;
			g_fEntity_star2[i] = 0.0;
			g_fEntity_fact2[i] = 0.0;
		}
		
		if( g_fEntity_over3[i] >= GetGameTime() ) {
			
			float facteur = (((g_fEntity_size_to[i]-g_fEntity_size_from[i])/(g_fEntity_over3[i]-g_fEntity_star3[i]) ) * (GetGameTime()-g_fEntity_star3[i])) + g_fEntity_size_from[i];
			if( facteur <= 0.0 )
				facteur = 0.0;
			if( facteur >= 10.0 )
				facteur = 10.0;
			
			SetEntPropFloat(i,  Prop_Send, "m_flModelScale", facteur);
			
		}
		else if(g_fEntity_over3[i] >= 0.1 ) {
			g_fEntity_over3[i] = 0.0;
			g_fEntity_star3[i] = 0.0;
		}
	}
	if( g_flFADE_TIME_start >= 0.1 && g_flFADE_TIME_end >= 0.1 && g_flFADE_TIME_start <= GetGameTime() && g_flFADE_TIME_last <= GetGameTime() ) {
		float percent = (1.0/(g_flFADE_TIME_end-g_flFADE_TIME_start)) * ( GetGameTime() - g_flFADE_TIME_start );
		
		if( g_iFADE_TIME_type == 1 ) {
			percent = 1.0 - percent;
		}
		
		int light = RoundFloat( float(sizeof(g_szFADE_TIME_light)-1)	* percent);
		int alpha = RoundFloat( 255.0									* percent);
		
		if( alpha < 0 || alpha > 300 ) {
			return;
		}
		
		char szLight[12], szAlpha[12], name[128], name2[128];
		//
		Format(szLight, 11, "%s", g_szFADE_TIME_light[light]);
		//
		Format(szAlpha, 11, "%i", alpha);
		
		g_flFADE_TIME_last = GetGameTime() + ( (g_flFADE_TIME_end-g_flFADE_TIME_start) / 255.0);
		
		for(int a=MaxClients; a<=2048; a++) {
			if( !IsValidEdict(a) )
				continue;
			if( !IsValidEntity(a) )
				continue;
			
			GetEdictClassname(a, name2, sizeof(name2));
			if( StrEqual(name2, "env_fog_controller") ) {
				percent = 1.0 - percent;
				if( percent >= 0.0 && percent <= 1.0 ) {
					SetEntPropFloat(a, Prop_Send, "m_fog.start",  (((5000.0-0.0) * percent) + 0.0) );
					SetEntPropFloat(a, Prop_Send, "m_fog.end",  (((5000.0-2500.0) * percent) + 2500.0) );
					
					int color[4];
					color[0] = color[1] = color[2] = RoundFloat(32.0 * percent) + 8;
					color[3] = 255;
					
				//	SetVariantColor(color);
				//	rp_AcceptEntityInput(a, "SetColor");
				//	SetVariantColor(color);
				//	rp_AcceptEntityInput(a, "SetColorSecondary");
				}
				//SetEntPropFloat(a, Prop_Send, "m_fog.farz",  (((5000.0-2000.0) * percent) + 2000.0) );
				
				percent = 1.0 - percent;
			}
			
			
			GetEntPropString(a, Prop_Data, "m_iName", name, sizeof(name));
			
			if( StrEqual(name2, "light_environment", false) ) {
				SetVariantString(szLight);
				rp_AcceptEntityInput(a, "SetPattern");
			}
			
			if( StrEqual(name, "night_skybox", false) /*&& StrEqual(name2, "func_brush", false)*/ ) {
				SetVariantString(szAlpha);
				rp_AcceptEntityInput(a, "Alpha");
				SkyBoxID = a;
			}
			
			if( alpha < 128 ) {
				if( StrEqual(name, "night_light", false) ) {
					rp_AcceptEntityInput(a, "TurnOff");
				}
				if( StrEqual(name, "night_spotlight", false) ) {
					rp_AcceptEntityInput(a, "LightOff");
				}
			}
			else if( alpha > 128 ) {
				if( StrEqual(name, "night_light", false) ) {
					rp_AcceptEntityInput(a, "TurnOn");
				}
				if( StrEqual(name, "night_spotlight", false) ) {
					rp_AcceptEntityInput(a, "LightOn");
				}
			}
		}
		
		if( g_flFADE_TIME_end <= GetGameTime() ) {
			g_flFADE_TIME_start = 0.0;
			g_flFADE_TIME_end = 0.0;
		}
	}
	
	if( g_iWeatherType >= 1 ) {
		if( GetRandomInt(1, 500) <= g_iWeatherSpeed ) {
			float srcOrigin[3], dstOrigin[3];
			srcOrigin[0] = dstOrigin[0] = GetRandomFloat(-6150.0, 4100.0); 
			srcOrigin[1] = dstOrigin[1] = GetRandomFloat(-8200.0, 3100.0);
			srcOrigin[2] = 30.0;
			dstOrigin[2] = -999999.9;
			
			
			if( Math_GetRandomInt(1, 50) == 10 ) {
				srcOrigin[0] = dstOrigin[0] = 1042.0;
				srcOrigin[1] = dstOrigin[1] = 32.0;
			}
			
			Handle line = TR_TraceRayFilterEx(srcOrigin, dstOrigin, MASK_SHOT, RayType_EndPoint, TraceRayDontHitSelf, SkyBoxID );
			if( line ) {
				if( TR_DidHit(line) ) {
					int id = TR_GetEntityIndex(line);
					char snd[128];
					
					GetEntPropString(id, Prop_Data, "m_iName", snd, sizeof(snd));
					if( StrEqual(snd, "night_skybox") ) {
						SkyBoxID = id;
					}
					
					TR_GetEndPosition(dstOrigin, line);
					
					if( g_iWeatherType == 1 ) {
						
						dstOrigin[2] += 1.0;
						
						Format(snd, sizeof(snd), "ambient/weather/thunder%i.wav", Math_GetRandomInt(1, 3));
						EmitSoundToAllAny(snd, SOUND_FROM_WORLD, SNDCHAN_STATIC, _, _, _, _, _, dstOrigin);
						
						ExplosionDamage(dstOrigin, 200.0, 150.0);
						
						TE_SetupBeamRingPoint(dstOrigin, 0.0, 150.0, g_cModel, 0, 0, 30, 0.1, 1.0, 20.0, {200, 200, 250, 50}, 10, 0);
						TE_SendToAll();
						
						TE_SetupDynamicLight(dstOrigin, 200, 200, 255, 10, 1000.0, 0.1, 1.0);
						TE_SendToAll();
						
						for(int i=0; i<GetRandomInt(1, 10); i++) {
							
							TE_SetupBeamPoints(srcOrigin, dstOrigin, g_cBeam, 0, 0, 30, 0.1, 20.0, GetRandomFloat(1.0, 5.0), 5, GetRandomFloat(7.5, 12.5), {200, 200, 250, 255}, 10);
							TE_SendToAll(float(i)/10.0);
						}
					}
					else if( g_iWeatherType == 2 ) {
						
						float client[3];
						bool found = false;
						
						for (int j = 1; j <= MaxClients; j++) {
							if( !IsValidClient(j) )
								continue;
							GetClientAbsOrigin(j, client);
							if( GetVectorDistance(client, dstOrigin) > 512.0 )
								continue;
							found = true;
							break;
						}
						if( found ) {
							TE_Start("World Decal");
							TE_WriteVector("m_vecOrigin", dstOrigin);
							TE_WriteNum("m_nIndex", g_cSnow);
							TE_SendToAll();
						}
					}
					
				}
			}
			CloseHandle(line);
		}
	}
}

public bool TraceRayDontHitSelf(int entity, int mask, any data) {
	if(entity == data) {
		return false; // Don't let the entity be hit
	}
	return true; // It didn't hit itself
}

int ExplosionDamage(float origin[3], float damage, float lenght) {
	
	float PlayerVec[3], distance, falloff = (damage/lenght);
	
	
	for(int i=1; i<=GetMaxEntities(); i++) {
		if( !IsValidEdict(i) )
			continue;
		if( !IsValidEntity(i) )
			continue;
		if( !IsMoveAble(i) )
			continue;
		
		if( IsValidClient(i) ) {
			GetClientEyePosition(i, PlayerVec);
		}
		else {
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", PlayerVec);
		}
		
		
		distance = GetVectorDistance(origin, PlayerVec);
		if( distance > lenght )
			continue;
		
		distance *= falloff;
		
		float dmg = (damage - distance);
		if( dmg < 0.0 )
			continue;
		
		TR_TraceRayFilter(origin, PlayerVec, MASK_SHOT, RayType_EndPoint, TraceEntityFilterStuff2);
		float fraction = (TR_GetFraction()) * 1.5;
		
		if( TR_GetEntityIndex() == i )
			fraction = 1.0;
		
		if( fraction > 1.0 )
			fraction = 1.0;
		if( fraction < 0.0 )
			fraction = 0.0;
		
		dmg *= fraction;
		
		if( dmg < 0.0 )
			continue;
		
		if( IsValidClient(i) && GetRandomInt(1, 3) == 3 ) {
			IgniteEntity(i, 10.0);
			DealDamage(i, RoundFloat(dmg/10.0));
		}
		else {
			DealDamage(i, RoundFloat(dmg));
		}
	}
	MakeRadiusPush2(origin, lenght, damage * 1.5);
	
	return 0;
}

public bool TraceEntityFilterStuff2(int entity, int mask) {
	
	if( IsValidClient(entity) || IsMoveAble(entity) )
		return false;
	
	if( entity > 0 && IsValidEdict(entity) && IsValidEntity(entity) ) {
		char classname[64];
		GetEdictClassname(entity, classname, sizeof(classname));
		if( StrContains(classname, "rp_") == 0 || StrContains(classname, "ctf_") == 0 ) {
			return false;
		}
	}
	
	return true;
}
void MakeRadiusPush2( float center[3], float lenght, float damage, bool bfraction = true) {
	
	float vecPushDir[3], vecOrigin[3], vecVelo[3], FallOff = (damage/lenght);
	
	for(int i=1; i<=2048; i++) {
		if( !IsValidEdict(i) )
			continue;
		if( !IsValidEntity(i) )
			continue;
		if( !IsMoveAble(i) )
			continue;
		
		if( IsValidClient(i) ) {
			GetClientEyePosition(i, vecOrigin);
		}
		else {
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", vecOrigin);
		}
		
		if( GetVectorDistance(vecOrigin, center) > lenght )
			continue;
		
		GetEntPropVector(i, Prop_Data, "m_vecVelocity", vecVelo);
		
		vecPushDir[0] = vecOrigin[0] - center[0];
		vecPushDir[1] = vecOrigin[1] - center[1];
		vecPushDir[2] = vecOrigin[2] - center[2];
		
		NormalizeVector(vecPushDir, vecPushDir);
		float dist = (lenght - GetVectorDistance(vecOrigin, center)) * FallOff;
		
		TR_TraceRayFilter(center, vecOrigin, MASK_SHOT, RayType_EndPoint, TraceEntityFilterStuff2);
		float fraction = (TR_GetFraction()) * 1.5;
		
		if( fraction >= 1.0 )
			fraction = 1.0;
		
		if( bfraction ) 
			dist *= fraction;
		
		float vecPush[3];
		vecPush[0] = (dist * vecPushDir[0]) + vecVelo[0];
		vecPush[1] = (dist * vecPushDir[1]) + vecVelo[1];
		vecPush[2] = (dist * vecPushDir[2]) + vecVelo[2];
		
		int flags = GetEntityFlags(i);
		if( vecPush[2] > 0.0 && (flags & FL_ONGROUND) ) {
			
			SetEntityFlags(i, (flags&~FL_ONGROUND) );
			SetEntPropEnt(i, Prop_Send, "m_hGroundEntity", -1);
		}
		TeleportEntity(i, NULL_VECTOR, NULL_VECTOR, vecPush);
	}
	
}


public void think(int i) {
	static Handle cvar;
	if( cvar == INVALID_HANDLE )
		cvar = FindConVar("host_timescale");
	
	if( IsValidClient(i) && g_flFlash_end[i] >= GetGameTime() ) {
		
		float percent = (1.0/(g_flFlash_end[i]-g_flFlash_start[i])) * ( GetGameTime() - g_flFlash_start[i] );
		percent = 1.0 - percent;
		if( percent < 0.0 )
			percent = 0.0;
		if( percent > 1.0 )
			percent = 1.0;
		
		percent *= g_flFlash_amp[i];
		SetEntPropFloat(i, Prop_Send, "m_flFlashDuration", GetGameTime()+0.1);
		SetEntPropFloat(i, Prop_Send, "m_flFlashMaxAlpha", percent);
	}
	/*if( IsValidClient(i) && g_flAlcool_end[i] >= GetGameTime() ) {
		float percent = (1.0/(g_flAlcool_end[i]-g_flAlcool_start[i])) * ( GetGameTime() - g_flAlcool_start[i] );
		float scale = percent/3.0 + 0.66;
		scale = percent/2.0 + 0.500;
		
		char str[24];
		FloatToString(scale, str, sizeof(str));
		SendConVarValue(i, cvar, str);
		
		if( GetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue") > 0.01 )
			SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.0/scale);
		
		percent = 1.0 - percent;
		if( percent >= 1.0 )
			percent = 1.0;
		if( percent <= 0.0 )
			percent = 0.0;
		
		float punch[3];
		
		punch[0] = Cosine(percent * MATH_PI * 2.0 * g_flAlcool_amp[i]) * percent * g_flAlcool_length[i];
		punch[1] = Sine(percent * MATH_PI * 2.0 * g_flAlcool_amp[i]) * percent * g_flAlcool_length[i];
		
		SetEntPropVector(i, Prop_Send, "m_aimPunchAngleVel", punch);
		SetEntPropFloat(i, Prop_Send, "m_flFlashDuration", GetGameTime()+0.1);
		SetEntPropFloat(i, Prop_Send, "m_flFlashMaxAlpha", percent * 30.0 + 10.0);
		
		if( GetGameTickCount()%20 == 0 ) {
			ClientCommand(i, "firstperson");
		}
	}*/
}

