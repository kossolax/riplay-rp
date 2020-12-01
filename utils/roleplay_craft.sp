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
#include <audio>
#include <sdktools_voice>
#include <sdktools_functions>

#pragma newdecls required
#include <roleplay.inc>	// https://www.ts-x.eu

#define	STONE_HP			1
#define TREE_HP				1
#define TREE_RESPAWN_MIN	3.0
#define TREE_RESPAWN_MAX	5.0
#define STONE_MAX			64

#define ITEM_BOIS			293
#define ITEM_LATEX			309
#define ITEM_CANNE			330
#define ITEM_EAU			335

#define MODEL_BUCKET1		"models/props_junk/trafficcone001a.mdl"
#define MODEL_BUCKET2		"models/props_junk/metalbucket01a.mdl"
#define MODEL_SENTRY		"models/props_survival/dronegun/dronegun.mdl"
#define SENTRY_ANGLE		0.5

Handle g_hOnSentryAttack;

enum {
	STATE_TURN_LEFT,
	STATE_TURN_RIGHT
};

char g_szTrees[][] = {
	"models/props/hr_massive/hr_foliage/birch_tree_01.mdl",
	"models/props/hr_massive/hr_foliage/birch_tree_02.mdl"
};
char g_szWoodGibs[][] = {
	"models/props/de_inferno/hr_i/wood_beam_a/wood_beam_a1.mdl"
};
char g_szStone[][][] = {
	{"models/custom_prop/minerals/coal/coal.mdl",						"15",	"1", "0"},
	{"models/custom_prop/minerals/granite/granite.mdl",					"14",	"1", "0"},
	{"models/custom_prop/minerals/ironstone/ironstone.mdl", 			"13",	"1", "289"}, // fer
	{"models/custom_prop/minerals/mineral6/mineral6.mdl", 				"12",	"1", "325"}, // alluminium
	{"models/custom_prop/minerals/mica/mica.mdl", 						"11",	"1", "0"},
	{"models/custom_prop/minerals/mineral7/mineral7.mdl", 				"10",	"2", "0"},
	{"models/custom_prop/minerals/mineral8/mineral8.mdl", 				"9",	"2", "311"}, // cuivre
	{"models/custom_prop/minerals/mineral9/mineral9.mdl", 				"8",	"2", "290"}, // zinc
	{"models/custom_prop/minerals/mineral10/mineral10.mdl", 			"7",	"2", "317"}, // sable
	{"models/custom_prop/minerals/mineral11/mineral11.mdl", 			"6",	"3", "303"},   // or
	{"models/custom_prop/minerals/mineral12/mineral12.mdl", 			"5",	"3", "0"},
	{"models/custom_prop/minerals/mineral13/mineral13.mdl",		 		"4",	"3", "0"},
	{"models/custom_prop/minerals/mineral_green/mineral_green.mdl", 	"3",	"3", "323"},  // uranium
	{"models/custom_prop/minerals/mineral_orange/mineral_orange.mdl",	"2",	"4", "0"},
	{"models/custom_prop/minerals/quartz/quartz.mdl", 					"1",	"4", "299"}   // souffre
};
int g_iTreeID[2049], g_iStoneID[2049];
int g_iStoneCount = 0;
int g_cBeam;
int g_iMaxRandomMineral;
ArrayList g_iSpawn;

float g_flAnimStart[2049];
int g_iAnimState[2049];
int g_iAnimEntity[65][3];

public Plugin myinfo = {
	name = "CRAFTING", author = "KoSSoLaX",
	description = "RolePlay - CRAFTING",
	version = __LAST_REV__, url = "https://www.ts-x.eu"
};

// ----------------------------------------------------------------------------
public Action Cmd_Reload(int args) {
	char name[64];
	GetPluginFilename(INVALID_HANDLE, name, sizeof(name));
	ServerCommand("sm plugins reload %s", name);
	return Plugin_Continue;
}
AudioPlayer api;

public void OnPluginStart() {
	api = new AudioPlayer();
	RegServerCmd("rp_quest_reload", Cmd_Reload);
	
	RegServerCmd("rp_item_fish", 		Cmd_Fish,			"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_sentry", 		Cmd_Sentry,			"RP-ITEM",	FCVAR_UNREGISTERED);
	RegConsoleCmd("sm_audio", 		Cmd_Audio);
	
	
	HookEvent("round_start", 		EventRoundStart, 	EventHookMode_Post);
	
	
	g_iMaxRandomMineral = 0;
	for (int i = 0; i < sizeof(g_szStone); i++) {
		g_iMaxRandomMineral += StringToInt(g_szStone[i][1]);
	}
	
	if( g_iSpawn != INVALID_HANDLE )
		g_iSpawn.Clear();
		
	g_iSpawn = new ArrayList(1, 0);
	for (int i = 0; i < sizeof(g_szStone); i++) {
		for (int j = 0; j < StringToInt(g_szStone[i][1]); j++) {
			g_iSpawn.Push(i);
		}
		
		//PrintToChatAll("%s -- %f %%", g_szStone[i][0], StringToInt(g_szStone[i][1]) / float(g_iMaxRandomMineral) * 100.0);
	}
}
public void OnAllPluginsLoaded() {
	OnRoundStart();
}
public Action Cmd_Audio(int client, int args) {
	
	char url[256];
	GetCmdArgString(url, sizeof(url));
	TrimString(url);
	
	if( strlen(url) < 10 )
		Format(url, sizeof(url), "https://www.youtube.com/watch?v=NnhLfHNcB-o");
	
	int bot = CreateFakeClient("bot");
	CS_SwitchTeam(bot, GetClientTeam(client));
	CS_RespawnPlayer(bot);
	
	float pos[3];
	Entity_GetAbsOrigin(client, pos);
	TeleportEntity(bot, pos, NULL_VECTOR, NULL_VECTOR);
	
	//api.AddArg("-filter:a 'volume=0.2'");
	api.SetFrom(5.0);
	api.PlayAsClient(bot, url);
	
	return Plugin_Handled;
}
public APLRes AskPluginLoad2(Handle hPlugin, bool isAfterMapLoaded, char[] error, int err_max) {	
	g_hOnSentryAttack = CreateGlobalForward("RP_OnSentryAttack", ET_Hook, Param_Cell, Param_Cell);
	return APLRes_Success;
}

public void OnMapStart() {
	g_cBeam = PrecacheModel("materials/sprites/laserbeam.vmt");
	
	PrecacheModel(MODEL_BUCKET1);
	PrecacheModel(MODEL_BUCKET2);	
	PrecacheModel(MODEL_SENTRY);
	PrecacheSoundAny("survival/turret_idle_01.wav");
	PrecacheSoundAny("survival/turret_sawplayer_01.wav");
	PrecacheSoundAny("survival/turret_lostplayer_03.wav");
	PrecacheSoundAny("weapons/m249/m249-1.wav");
	
	for (int i = 0; i < sizeof(g_szTrees); i++) {
		PrecacheModel(g_szTrees[i]);
	}
	for (int i = 0; i < sizeof(g_szWoodGibs); i++) {
		PrecacheModel(g_szWoodGibs[i]);
	}
	for (int i = 0; i < sizeof(g_szStone); i++) {
		PrecacheModel(g_szStone[i][0]);
	}
}
public Action Cmd_Sentry(int args) {
	int client = GetCmdArgInt(1);
	float pos[3], ang[3];
	Entity_GetAbsOrigin(client, pos);
	Entity_GetAbsAngles(client, ang);
	
	CreateSentry(client, pos, ang);
}
public Action Cmd_Fish(int args) {
	int client = GetCmdArgInt(1);
	
	float eye[3], ang[3], src[3], pos[3];
	GetClientEyePosition(client, eye);
	GetClientEyeAngles(client, ang);
	
	char target1[128];
	
	if (rp_ClientEmote(client, "Emote_Fishing")) {
		rp_HookEvent(client, RP_OnPlayerEmote, OnEmote);
		
		int ent = CreateEntityByName("prop_physics");
		Format(target1, sizeof(target1), "rope_1_%d", ent);
		
		DispatchKeyValue(ent, "model", MODEL_BUCKET1);
		DispatchKeyValue(ent, "targetname", target1);

		DispatchSpawn(ent);
		Entity_SetModel(ent, MODEL_BUCKET2);
		
		Entity_SetOwner(ent, client);
		SetEntityMoveType(ent, MOVETYPE_NONE);
		Entity_SetSolidFlags(ent, FSOLID_TRIGGER);
		Entity_SetCollisionGroup(ent, COLLISION_GROUP_DEBRIS_TRIGGER);
		
		src[0] = -32.0;
		ang[0] = ang[2] = 0.0;
		
		Math_RotateVector(src, ang, pos);
		AddVectors(eye, pos, pos);
		ang[0] = -90.0;
		TeleportEntity(ent, pos, ang, NULL_VECTOR);
		
		int rope = CreateEntityByName("move_rope");
		DispatchKeyValue(rope, "Collide", "1");
		DispatchKeyValue(rope, "Slack", "128");
		DispatchKeyValue(rope, "Type", "0" );
		DispatchKeyValue(rope, "Width", "1" );
		DispatchKeyValue(rope, "NextKey", target1);
		DispatchKeyValue(rope, "RopeMaterial", "cable/cable.vmt");
		DispatchSpawn(rope);
		
		TeleportEntity(rope, eye, NULL_VECTOR, NULL_VECTOR);
		ActivateEntity(rope);
		
		SetVariantString("!activator");
		AcceptEntityInput(rope, "SetParent", client);
		
		SetVariantString("weapon_hand_R");
		AcceptEntityInput(rope, "SetParentAttachment", rope, rope, 0);
		
		g_flAnimStart[ent] = GetTickedTime();
		g_iAnimState[ent] = 0;
		g_iAnimEntity[client][0] = ent;
		g_iAnimEntity[client][1] = rope;
		g_iAnimEntity[client][2] = 0;
		
		ServerCommand("sm_effect_fading %d 0.2 0", ent);
		CreateTimer(0.01, Animate, EntIndexToEntRef(ent), TIMER_REPEAT);
	}
	else {
		int item_id = GetCmdArgInt(args);
		if( item_id > 0 ) {
			rp_ClientGiveItem(client, item_id);
		}
	}
	
	
	return Plugin_Handled;
}
public Action Animate(Handle timer, any target) {
	int ent = EntRefToEntIndex(target);
	if( ent == INVALID_ENT_REFERENCE )
		return Plugin_Stop;
	
	float duration = GetTickedTime() - g_flAnimStart[ent];
	float vel[3], ang[3], pos[3], src[3], dst[3];
	
	int client = Entity_GetOwner(ent);
	
	switch(g_iAnimState[ent]) {
		case 0: {
			if( duration > 0.05) {
				SetEntityMoveType(ent, MOVETYPE_VPHYSICS);
				if( duration > 0.1)
					vel[2] = 16.0;
				
				TeleportEntity(ent, NULL_VECTOR, NULL_VECTOR, vel);
				if( duration > 0.25)
					g_iAnimState[ent] =  1;
			}
		}
		case 1: { // throw
			Entity_GetAbsAngles(ent, ang);
			ang[0] = ang[2] = 0.0;
			pos[0] = -256.0;
			pos[2] = 256.0;
			
			Math_RotateVector(pos, ang, vel);
			TeleportEntity(ent, NULL_VECTOR, NULL_VECTOR, vel);
			g_iAnimState[ent] =  2;
		}
		case 2: { // pull
			if( duration > 1.4 ) {
				Entity_GetAbsOrigin(ent, dst);
				GetClientEyePosition(client, src);
				SubtractVectors(src, dst, src);
				
				NormalizeVector(src, src);
				ScaleVector(src, 64.0);
				
				TeleportEntity(ent, NULL_VECTOR, NULL_VECTOR, src);
				
				if( GetEntProp(ent, Prop_Data, "m_nWaterLevel") > 0 )
					g_iAnimEntity[client][2] = 1;
				
				if( duration > 2.8 )
					g_iAnimState[ent] = 3;
			}
		}
		case 3: { // big pull
			int parent = Entity_GetParent(client);
			Entity_GetAbsAngles(parent, ang);
			ang[0] = ang[2] = 0.0;
			pos[0] = -256.0;
			pos[2] = 256.0 + 128.0;
			
			Math_RotateVector(pos, ang, vel);
			
			TeleportEntity(ent, NULL_VECTOR, NULL_VECTOR, vel);
			g_iAnimState[ent] = 4;
		}
		case 4: { // ending
			if( duration > 3.3 ) {
				int parent = Entity_GetParent(client);
				Entity_GetAbsOrigin(ent, dst);
				GetClientEyePosition(client, src);
				SubtractVectors(src, dst, src);
				
				NormalizeVector(src, src);
				ScaleVector(src, 64.0);
				
				TeleportEntity(ent, NULL_VECTOR, NULL_VECTOR, src);
				
				if( duration > 4.0 ) {
					Entity_GetAbsOrigin(parent, dst);
					rp_ClientEmote(client, "");
					return Plugin_Stop;
				}
			}
		}
	}
	
	return Plugin_Continue;
}
public Action OnEmote(int client, const char[] emote, float time) {
	if( StrEqual(emote, "Emote_Fishing") && time >= 0.0 ) {
		if( time >= 4.0 && g_iAnimEntity[client][2]) {
			if( GetRandomInt(0, 100) != 42 ) {
				rp_ClientGiveItem(client, ITEM_CANNE);
			}
			else {
				CPrintToChat(client, "" ...MOD_TAG... " Votre canne à eau s'est {red}brisée{default}.");
			}
			
			rp_ClientGiveItem(client, ITEM_EAU);
			
		}
		else {
			rp_ClientGiveItem(client, ITEM_CANNE);
		}
		
		FakeClientCommand(client, "say /i");
		rp_UnhookEvent(client, RP_OnPlayerEmote, OnEmote);
		
		AcceptEntityInput(g_iAnimEntity[client][1], "Kill");
		AcceptEntityInput(g_iAnimEntity[client][0], "Kill");
	}
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
		if( StrContains(tmp, "rp_tree") == 0 || StrContains(tmp, "rp_wood") == 0 || StrContains(tmp, "rp_stone") == 0 ) {
			rp_AcceptEntityInput(i, "Kill");
		}
	}
	
	for (int i = 0; i < MAX_LOCATIONS; i++) {
		rp_GetLocationData(i, location_type_base, tmp, sizeof(tmp));
		
		if( StrEqual(tmp, "tree") ) {
			CreateTimer(GetRandomFloat(0.0, 3.0), SpawnTree, i);
		}
	}
	
	if( true ) {
		char model[PLATFORM_MAX_PATH];
		float dst[3];
		for (int i = 0; i < sizeof(g_szStone); i++) {
			for (int type = 0; type < 3; type++ ) {
				Format(model, sizeof(model), "%s", g_szStone[i][0]);
				if( type > 0 ) {
					if( type == 1 )
						ReplaceString(model, sizeof(model), ".mdl", "2.mdl");
					if( type == 2 )
						ReplaceString(model, sizeof(model), ".mdl", "3.mdl");
				}
				int ent = CreateEntityByName("prop_physics");
				DispatchKeyValue(ent, "model", model);
				DispatchKeyValue(ent, "solid", "6");
				DispatchKeyValue(ent, "classname", "rp_stone");
				DispatchSpawn(ent);
				ActivateEntity(ent);
				rp_AcceptEntityInput(ent, "DisableMotion");
				
				dst[0] = -6837 - 80.0 * type;
				dst[1] = 128.0 + 64.0 * i;
				dst[2] = -2328.0;
				
				rp_SetBuildingData(ent, BD_item_id, StringToInt(g_szStone[i][3]));
				SDKHook(ent, SDKHook_OnTakeDamage, OnPropDamage);
				
				TeleportEntity(ent, dst, NULL_VECTOR, NULL_VECTOR);
			}
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
	
	SDKHook(ent, SDKHook_OnTakeDamage, OnPropDamage);
	SDKHook(ent, SDKHook_VPhysicsUpdate, OnTreeThink);

	rp_AcceptEntityInput(ent, "DisableMotion");
	rp_AcceptEntityInput(ent, "DisableCollision" );
	rp_AcceptEntityInput(ent, "EnableCollision" );
	
	TeleportEntity(ent, pos, ang, NULL_VECTOR);
	ServerCommand("sm_effect_fading %d 1 0", ent);
	g_iTreeID[ent] = i;
}
void SpawnMineral() {
	float min[3], max[3], src[3], dst[3], nrm[3], dir[3], tmp[3], size[2][3];
	char model[128];
	int pick = GetRandomInt(0, g_iMaxRandomMineral-1);
	int rnd = g_iSpawn.Get(pick);
	int level = StringToInt(g_szStone[rnd][2]);
	int stack[MAX_ZONES];
	int cpt, x, y, z = 2;
	
	for (int i = 0; i < MAX_ZONES; i++) {
		if( getMineLevel(i) == level ) {
			stack[cpt++] = i;
		}
	}
	
	int zone = stack[GetRandomInt(0, cpt - 1)];
	if( g_iStoneCount < STONE_MAX ) {
		min[0] = rp_GetZoneFloat(zone, zone_type_min_x);
		min[1] = rp_GetZoneFloat(zone, zone_type_min_y);
		min[2] = rp_GetZoneFloat(zone, zone_type_min_z);
		
		max[0] = rp_GetZoneFloat(zone, zone_type_max_x);
		max[1] = rp_GetZoneFloat(zone, zone_type_max_y);
		max[2] = rp_GetZoneFloat(zone, zone_type_max_z);
		
		if( max[0] - min[0] > max[1] - min[1] )
			y = 1;
		else
			x = 1;
		
		src[x] = min[x];
		src[y] = (min[y] + max[y]) / 2.0;
		src[z] = (min[z] + max[z]) / 2.0;
		
		dst[x] = max[x];
		dst[y] = (min[y] + max[y]) / 2.0;
		dst[z] = (min[z] + max[z]) / 2.0;
		
		nrm[x] = Math_Lerp(src[x], dst[x], GetRandomFloat());
		nrm[y] = src[y];
		nrm[z] = src[z];
		
		dir[x] = nrm[x];
		dir[y] = nrm[y] + 256.0 * (GetRandomInt(0, 1)==0?1:-1);
		dir[z] = nrm[z];
		
		Handle tr = TR_TraceRayFilterEx(nrm, dir, MASK_SOLID_BRUSHONLY, RayType_EndPoint, FilterToNone);
		if( TR_DidHit(tr) ) {
			TR_GetEndPosition(dir, tr);
			TR_GetPlaneNormal(tr, tmp);
			
			Format(model, sizeof(model), "%s", g_szStone[rnd][0]);
	
			int type = Math_GetRandomPow(0, 2);
			if( type > 0 ) {
				if( type == 1 )
					ReplaceString(model, sizeof(model), ".mdl", "2.mdl");
				if( type == 2 )
					ReplaceString(model, sizeof(model), ".mdl", "3.mdl");
			}
			
			int ent = CreateEntityByName("prop_physics");
			DispatchKeyValue(ent, "model", model);
			DispatchKeyValue(ent, "solid", "6");
			DispatchKeyValue(ent, "classname", "rp_stone");
			DispatchSpawn(ent);
			ActivateEntity(ent);
			
			Entity_GetMinSize(ent, size[0]);
			Entity_GetMaxSize(ent, size[1]);
			
			SetEntProp(ent, Prop_Data, "m_iHealth", RoundFloat((max[z]-min[z])*STONE_HP));
			Entity_SetMaxHealth(ent, RoundFloat((max[z]-min[z])*STONE_HP));
			
			SDKHook(ent, SDKHook_OnTakeDamage, OnPropDamage);
			
			rp_AcceptEntityInput(ent, "DisableMotion");
			rp_AcceptEntityInput(ent, "DisableCollision" );
			rp_AcceptEntityInput(ent, "EnableCollision" );
			rp_SetBuildingData(ent, BD_item_id, StringToInt(g_szStone[rnd][3]));
			rp_SetBuildingData(ent, BD_count, type + 1);

			GetVectorAngles(tmp, nrm);
			nrm[0] += 90.0;
			dir[z] = GetRandomFloat(min[z] - size[0][0], max[z] - size[1][0]);
			TeleportEntity(ent, dir, nrm, NULL_VECTOR);
			ServerCommand("sm_effect_fading %d 1 0", ent);
			g_iStoneID[ent] = rnd+1;
			g_iStoneCount++;
		}
		delete tr;		
	}
}

public Action OnPlayerRunCmd(int client) {
	int lvl = getMineLevel(rp_GetPlayerZone(client));
	
	if( lvl >= 0 ) {
		SpawnMineral();
	}
	
	if( !api.IsFinished && api.PlayedSecs > 0.1 ) {
		//PrintToChatAll("%.1f", api.PlayedSecs);
	}
}
public bool FilterToNone(int entity, int mask, any data) {
	return false;
}
public void OnEntityCreated(int entity, const char[] classname) {
	if( entity > 0 ) {
		g_iTreeID[entity] = 0;
		g_iStoneID[entity] = 0;
	}
}
public void OnEntityDestroyed(int entity) {
	if( entity > 0 ) {
		if( g_iTreeID[entity] > 0 ) {
			CreateTimer(GetRandomFloat(TREE_RESPAWN_MIN, TREE_RESPAWN_MAX), SpawnTree, g_iTreeID[entity]);
			g_iTreeID[entity] = 0;
		}
		if( g_iStoneID[entity] > 0 ) {
			g_iStoneCount--;
		}
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
			SDKHook(ent, SDKHook_OnTakeDamage, OnPropDamage);
		}
		
		Entity_SetSolidType(entity, SOLID_NONE);
		ServerCommand("sm_effect_fading %d 1 1", entity);
		rp_ScheduleEntityInput(entity, 1.0, "Kill");
		SDKUnhook(entity, SDKHook_VPhysicsUpdate, OnTreeThink);
	}
}
public Action OnPropDamage(int victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3]) {
	static char tmp[128];

	if( attacker == inflictor && damagetype & DMG_SLASH ) {
		GetEdictClassname(victim, tmp, sizeof(tmp));
		
		if( StrEqual(tmp, "rp_stone") && IsMeleeHammer(weapon) ) {
			SetEntProp(victim, Prop_Data, "m_iHealth", Entity_GetHealth(victim) - RoundFloat(damage));
			if( Entity_GetHealth(victim) <= 0 ) {
				SetEntProp(victim, Prop_Data, "m_iHealth", 0);
				rp_AcceptEntityInput(victim, "EnableMotion");
				
				Entity_SetCollisionGroup(victim, COLLISION_GROUP_DEBRIS);
				rp_ScheduleEntityInput(victim, 10.0, "Break");
				ServerCommand("sm_effect_fading %d 10 1", victim);
				
				int itemID = rp_GetBuildingData(victim, BD_item_id);
				if( itemID > 0 ) {
					rp_ClientGiveItem(attacker, itemID, rp_GetBuildingData(victim, BD_count));
					
					if( GetRandomInt(0, 100) == 42 ) {
						AcceptEntityInput(weapon, "Kill");
						FakeClientCommand(attacker, "use weapon_fists");
					}
				}
			}
		}
		if( StrEqual(tmp, "rp_wood") && IsMeleeAxe(weapon) ) {
			rp_ClientGiveItem(attacker, ITEM_BOIS);
			AcceptEntityInput(victim, "Break");
			
			if( GetRandomInt(0, 100) == 42 ) {
				AcceptEntityInput(weapon, "Kill");
				FakeClientCommand(attacker, "use weapon_fists");
			}
		}
		if( StrEqual(tmp, "rp_tree") && IsMeleeAxe(weapon) ) {
			SetEntProp(victim, Prop_Data, "m_iHealth", Entity_GetHealth(victim) - RoundFloat(damage));
			if( Entity_GetHealth(victim) <= 0 ) {
				rp_ClientGiveItem(attacker, ITEM_LATEX);
				SetEntProp(victim, Prop_Data, "m_iHealth", 0);
				AcceptEntityInput(victim, "EnableMotion");
				SDKUnhook(victim, SDKHook_OnTakeDamage, OnPropDamage);
			
				float vel[3];
				vel[2] = 32.0;				
				TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, damageForce);	
			}
		}
	}
}
stock int getMineLevel(int zone) {
	static int level[MAX_ZONES] =  { -2, ... };
	
	if( level[zone] == -2 ) {
		char tmp[128];
		
		rp_GetZoneData(zone, zone_type_type, tmp, sizeof(tmp));
		if( StrContains(tmp, "mine") == 0 ) {
			ReplaceString(tmp, sizeof(tmp), "mine_", "");
			level[zone] = StringToInt(tmp);
		}
		else {
			level[zone] = -1;
		}
	}
	
	return level[zone];
}
// ------------------------------------------------------------------------------------------------
void CreateSentry(int owner, float pos[3], float ang[3]) {	
	int ent = CreateEntityByName("monster_generic");
	DispatchKeyValue(ent, "classname", "rp_sentry");
	DispatchKeyValue(ent, "model", MODEL_SENTRY);
	DispatchSpawn(ent);
	ActivateEntity(ent);
	
	Entity_SetOwner(ent, owner);
	SetEntityFlags(ent, 262144);
	SetEntityMoveType(ent, MOVETYPE_FLYGRAVITY);
	SetEntProp(ent, Prop_Data, "m_lifeState", 2);
	
	TeleportEntity(ent, pos, ang, NULL_VECTOR);
	SDKHook(ent, SDKHook_Think, OnThink);
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
	float dist = 2048.0*2048.0;
	int owner = Entity_GetOwner(ent);
	int zone = rp_GetZoneInt(rp_GetPlayerZone(ent), zone_type_type);
	int appart = rp_GetPlayerZoneAppart(ent);
	
	for (int i = 1; i <= MaxClients; i++) {
		if( !IsValidClient(i) )
			continue;
		if( !IsPlayerAlive(i) )
			continue;		
		if( GetEntityMoveType(i) == MOVETYPE_NOCLIP )
			continue;
		if( owner == i )
			continue;
		if( zone > 0 && rp_GetClientJobID(i) == zone )
			continue;
		if( appart > 0 && rp_GetClientKeyAppartement(i, appart) )
			continue;
		if( (zone == 1 && rp_GetClientJobID(i) == 101) || (zone == 101 && rp_GetClientJobID(i) == 1) )
			continue;
		if( rp_ClientCanAttack(owner, i) == false )
			continue;
		if( GetEntProp(i, Prop_Data, "m_takedamage") != 2 )
			continue;
		
		Action a;
		Call_StartForward(g_hOnSentryAttack);
		Call_PushCell(ent);
		Call_PushCell(i);
		Call_Finish(a);
		
		if( a == Plugin_Stop )
			continue;
		
		Entity_GetAbsOrigin(i, dst);
		dst[2] += 40.0;
		float tmp = GetVectorDistance(src, dst, true);
					
		if( tmp < dist ) {
			float tilt2, yaw2;
			getTargetAngle(ent, i, tilt2, yaw2);
			if( tilt2 > 0.5 - SENTRY_ANGLE/2 && tilt2 < 0.5 + SENTRY_ANGLE/2 && FloatAbs(tilt-tilt2) <= threshold ) {
				
				Handle trace = TR_TraceRayFilterEx(src, dst, MASK_SHOT, RayType_EndPoint, TraceEntityFilterSelf, ent);

				if( TR_DidHit(trace) ) {
					int y = TR_GetEntityIndex(trace);
					
					if( y == i ) {
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

	int damage = 10;
	float push = 128.0;
	float fire = 0.0125;
	float speed = (5.0/360.0);
	float threshold = (45.0/360.0)/2.0;

	float src[3], ang[3], dst[3], dir[3], vel[3];
	Entity_GetAbsOrigin(ent, src);
	Entity_GetAbsAngles(ent, ang);
	src[2] += 43.0; 
	
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
				
				if( rp_IsMoveAble(victim) ) {
					SubtractVectors(dst, src, dir);
					NormalizeVector(dir, dir);
					ScaleVector(dir, push);
					
					Entity_GetAbsVelocity(victim, vel);
					
					AddVectors(vel, dir, dir);
					TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, dir);
					if( damage > 0 )
						rp_ClientDamage(victim, damage, Entity_GetOwner(ent), "rp_sentry");
				}
				
				TE_SetupBeamPoints(src, dst, g_cBeam, 0, 0, 0, 0.1, 0.25, 0.25, 0, 0.0, { 64, 64, 64, 64 }, 0);
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
			
			if( tilt > 0.5 + SENTRY_ANGLE/2 ) {
				tilt = 0.5 + SENTRY_ANGLE/2;
				state = STATE_TURN_RIGHT;
				EmitAmbientSoundAny("survival/turret_idle_01.wav", NULL_VECTOR, ent);
			}
		}
		else {
			tilt -= speed;
			
			if( tilt < 0.5 - SENTRY_ANGLE/2 ) {
				tilt = 0.5 - SENTRY_ANGLE/2;
				state = STATE_TURN_LEFT;
				EmitAmbientSoundAny("survival/turret_idle_01.wav", NULL_VECTOR, ent);
			}
		}
		
		if( yaw+speed > 0.5 && yaw-speed < 0.5 )
			yaw = 0.5;
		else if( yaw > 0.5 )
			yaw -= speed;
		else if( yaw < 0.5 )
			yaw += speed;
		
	}
	
	SetEntPropEnt(ent, Prop_Data, "m_hInteractionPartner", newEnemy);
	SetEntPropFloat(ent, Prop_Send, "m_flPoseParameter", tilt, 0);
	SetEntPropFloat(ent, Prop_Send, "m_flPoseParameter", yaw, 1);
	SetEntProp(ent, Prop_Data, "m_iInteractionState", state);
}
// ------------------------------------------------------------------------------------------------
bool IsMeleeAxe(int weapon) {
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
bool IsMeleeHammer(int weapon) {
	static char tmp[128];
	
	GetEdictClassname(weapon, tmp, sizeof(tmp));
	if( StrEqual(tmp, "weapon_melee") ) {
		Entity_GetModel(weapon, tmp, sizeof(tmp));
		if( StrEqual(tmp, "models/weapons/v_hammer.mdl") ) {
			return true;
		}
	}
	return false;
}
bool IsMeleeSpanner(int weapon) {
	static char tmp[128];
	
	GetEdictClassname(weapon, tmp, sizeof(tmp));
	if( StrEqual(tmp, "weapon_melee") ) {
		Entity_GetModel(weapon, tmp, sizeof(tmp));
		if( StrEqual(tmp, "models/weapons/v_spanner.mdl") ) {
			return true;
		}
	}
	return false;
}
float AngleMod(float flAngle) { 
    flAngle = (360.0 / 65536) * (RoundToNearest(flAngle * (65536.0 / 360.0)) & 65535); 
    return flAngle; 
}
public bool TraceEntityFilterSelf(int entity, int contentsMask, any data) {
	return entity != data;
}
