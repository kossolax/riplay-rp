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
#include <colors_csgo>	// https://forums.alliedmods.net/showthread.php?p=2205447#post2205447
#include <smlib>		// https://github.com/bcserv/smlib
#include <emitsoundany> // https://forums.alliedmods.net/showthread.php?t=237045

#pragma newdecls required
#include <roleplay.inc>	// https://www.ts-x.eu

public Plugin myinfo = {
	name = "Jobs: CARSHOP", author = "KoSSoLaX",
	description = "RolePlay - Jobs: CarShop",
	version = __LAST_REV__, url = "https://www.ts-x.eu"
};

bool g_bEntityManaged[2049] =  { false, ... };
float g_flEntity[2049];

Handle g_hMAX_CAR, g_hCarUnstuck, g_hCarHeal;
int g_cExplode;
int g_iBlockedTime[65][65];
float g_lastpos[2049][3];

int g_lastTouch[2049], g_touchCount[2049], g_damageCount[2049], g_lastDamage[2049];

char g_szParticles[][][32] =  {
	{ "Trail",		"Propulseur" },
	{ "Trail2",		"Fusée n°1" },
	{ "Trail3",		"Petit cube bleu" },
	{ "Trail4",		"Fumée verte" },
	{ "Trail5",		"Seringue" },
	{ "Trail7",		"Petite fumée verte" },
	{ "Trail8",		"Fumée blanche et bleue" },
	{ "Trail9",		"Drogue n°1" },
	{ "Trail10",	"Bulle bleue n°1" },
	{ "Trail11",	"Fumée Or" },
	{ "Trail12",	"Fumée bleue" },
	{ "Trail13",	"Bulle bleue °2" },
	{ "Trail14",	"Drogue °2" },
	{ "Trail15",	"Trait jaune et vert" },
	{ "Trail_01",	"Fusée n°2" },
	{ "Trail_02",	"Fumée bleue n°2" },
	{ "Trail_03",	"Fumée verte" },
	{ "Trail_04",	"Fumée bleue et rose" },
};
char g_szColor[][][32] = {
	{ "128 0 0", 	"Rubis" },  	{ "255 0 0", 	"Rouge" }, 		{ "255 128 0", 	"Orange" },  	{ "255 255 0", 	"Jaune" }, 
	{ "128 255 0", 	"Vert-pomme"},  { "0 255 0", 	"Vert" },  		{ "0 128 0", 	"Vert-foncé" }, { "0 255 128", 	"Vert-émeraude" }, 
	{ "0 255 255", 	"Bleu-ciel" },  { "0 128 255", 	"Bleu-clair" },	{ "0 0 255", 	"Bleu" },  		{ "0 0 128", 	"Bleu-Foncé" }, 
	{ "128 0 255", 	"Mauve" },  	{ "255 0 255", 	"Rose" },  		{ "255 0 128", 	"Fushia" }, 
	{ "255 255 255","Blanc" },  	{ "128 128 128","Gris" },  		{ "0 0 0", 		"Noir" }
};

int g_iVehiclePolice = -1;
int g_iVehicleJustice = -1;

// ----------------------------------------------------------------------------
public Action Cmd_Reload(int args) {
	char name[64];
	GetPluginFilename(INVALID_HANDLE, name, sizeof(name));
	ServerCommand("sm plugins reload %s", name);
	return Plugin_Continue;
}

public APLRes AskPluginLoad2(Handle hPlugin, bool isAfterMapLoaded, char[] error, int err_max) {
	CreateNative("rp_CreateVehicle", 		Native_rp_CreateVehicle);
	
	return APLRes_Success;
}
public void OnPluginStart() {
	RegServerCmd("rp_quest_reload", 	Cmd_Reload);
	RegServerCmd("rp_item_vehicle", 	Cmd_ItemVehicle,		"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_vehicle2", 	Cmd_ItemVehicle,		"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_vehicle3", 	Cmd_ItemVehicle,		"RP-ITEM",	FCVAR_UNREGISTERED);
	RegAdminCmd("rp_vehicle", 			Cmd_SpawnVehicle,		ADMFLAG_KICK);
	
	RegServerCmd("rp_item_carstuff", 	Cmd_ItemVehicleStuff,	"RP-ITEM",	FCVAR_UNREGISTERED);
	RegAdminCmd("rp_vehiclexit",		Cmd_VehicleExit,		ADMFLAG_KICK);
	
	g_hMAX_CAR = CreateConVar("rp_max_car",	"20", "Nombre de voiture maximum sur le serveur", 0, true, 0.0, true, GetConVarInt(FindConVar("hostport")) == 27015 ? 10.0 : 500.0 );
	g_hCarUnstuck = CreateConVar("rp_car_unstuck", "1", "Les voitures peuvent-elle s'auto-débloquer?", 0, true, 0.0, true, 1.0);
	g_hCarHeal = CreateConVar("rp_car_heal", "1000", "La vie des voitures", 0, true, 100.0, true, 100000.0);
	
	char model[PLATFORM_MAX_PATH];
	
	// Reload:
	for (int i = 1; i <= MaxClients; i++) {
		if( IsValidClient(i) )
			OnClientPostAdminCheck(i);
	}
	for (int i = MaxClients; i <= 2048; i++) {
		if( rp_IsValidVehicle(i) ) {
			SDKHook(i, SDKHook_Touch, VehicleTouch);
			SDKHook(i, SDKHook_Think, OnThink);	
			CreateTimer(GetRandomFloat(0.5, 1.5), Timer_VehicleRemoveCheck, EntIndexToEntRef(i));
			
			Entity_GetModel(i, model, sizeof(model));
			if( StrContains(model, "police_crown_victoria_csgo") >= 0 ) {
				int skin = GetEntProp(i, Prop_Send, "m_nSkin");
				if( skin == 6 )
					g_iVehiclePolice = EntIndexToEntRef(i);
				if( skin == 1 )
					g_iVehicleJustice = EntIndexToEntRef(i);
			}
		}
	}
	
	CreateTimer(1.0, Check_VehiclePolice);
}
public void OnPluginEnd() {
	for (int i = MaxClients; i <= 2048; i++) {
		if( !IsValidEdict(i) || !IsValidEntity(i) )
			continue;
		if( g_bEntityManaged[i] ) {
			AcceptEntityInput(i, "Kill");
		}
	}
}
public Action Check_VehiclePolice(Handle timer, any none) {
	float spawn[][3] = {
		{1477.0, 1818.0, -2143.0},
		{1332.0, 1818.0, -2143.0}
	};
	
	if( EntRefToEntIndex(g_iVehiclePolice) <= 0 ) {
		int rnd = GetRandomInt(0, sizeof(spawn)-1);
		
		int car = rp_CreateVehicle(spawn[rnd], view_as<float>({0.0, 180.0, 0.0}), "models/natalya/vehicles/police_crown_victoria_csgo_v2.mdl", 6);
		if( rp_IsValidVehicle(car) ) {
			SetEntProp(car, Prop_Data, "m_bLocked", 1);
			rp_SetVehicleInt(car, car_owner, -1);
			rp_SetVehicleInt(car, car_maxPassager, 3);
			SetEntProp(car, Prop_Send, "m_nBody", 3);
			
			g_iVehiclePolice = EntIndexToEntRef(car);
		}
	}
	
	if( EntRefToEntIndex(g_iVehicleJustice) <= 0 ) {
		int rnd = GetRandomInt(0, sizeof(spawn)-1);
		
		int car = rp_CreateVehicle(spawn[rnd], view_as<float>({0.0, 180.0, 0.0}), "models/natalya/vehicles/police_crown_victoria_csgo_v2.mdl", 1);
		if( rp_IsValidVehicle(car) ) {
			SetEntProp(car, Prop_Data, "m_bLocked", 1);
			rp_SetVehicleInt(car, car_owner, -101);
			rp_SetVehicleInt(car, car_maxPassager, 3);
			SetEntProp(car, Prop_Send, "m_nBody", 3);
			
			g_iVehicleJustice = EntIndexToEntRef(car);
		}
	}
	
	bool light = (GetConVarInt(FindConVar("rp_braquage")) > 0 || GetConVarInt(FindConVar("rp_kidnapping")) > 0 || GetConVarInt(FindConVar("rp_perquisition")) > 0);
	if( light ) {
		if( EntRefToEntIndex(g_iVehiclePolice) >= 0 ) {
			updatePoliceLight(g_iVehiclePolice);
		}
		if( EntRefToEntIndex(g_iVehicleJustice) >= 0 ) {
			updatePoliceLight(g_iVehicleJustice);
		}
	}
	else {
		if( EntRefToEntIndex(g_iVehiclePolice) >= 0 ) {
			removePoliceLight(g_iVehiclePolice);
		}
		if( EntRefToEntIndex(g_iVehicleJustice) >= 0 ) {
			removePoliceLight(g_iVehicleJustice);
		}
	}
	
	
	for (int i = 1; i <= MaxClients; i++) {
		if( !IsValidClient(i) )
			continue;
		
		if( rp_GetClientJobID(i) == 1 && EntRefToEntIndex(g_iVehiclePolice) > 0 ) {
			rp_SetClientKeyVehicle(i, EntRefToEntIndex(g_iVehiclePolice), true);
		}
			
		if( rp_GetClientJobID(i) == 101 && EntRefToEntIndex(g_iVehicleJustice) > 0 )
			rp_SetClientKeyVehicle(i, EntRefToEntIndex(g_iVehicleJustice), true);
		
	}
	
	CreateTimer(1.0, Check_VehiclePolice);
}
void removePoliceLight(int car) {
	car = EntRefToEntIndex(car);
	if( car <= 0 )
		return;
	
	
	
	if( EntRefToEntIndex(rp_GetVehicleInt(car, car_gyro_left)) > 0 ) {
		AcceptEntityInput(EntRefToEntIndex(rp_GetVehicleInt(car, car_gyro_left)), "Kill");
	}
	if( EntRefToEntIndex(rp_GetVehicleInt(car, car_gyro_right)) > 0 ) {
		AcceptEntityInput(EntRefToEntIndex(rp_GetVehicleInt(car, car_gyro_right)), "Kill");
	}
}
void updatePoliceLight(int car) {
	static float lastpos[2049][3];
	
	car = EntRefToEntIndex(car);
	if( car <= 0 )
		return;
	
	float src[3];
	Entity_GetAbsOrigin(car, src);
	
	bool first = (EntRefToEntIndex(rp_GetVehicleInt(car, car_gyro_left)) <= 0 || EntRefToEntIndex(rp_GetVehicleInt(car, car_gyro_right)) <= 1);
	
	if( GetVectorDistance(src, lastpos[car]) > 2048.0 || first ) {
		attachPoliceLight(car);
		Entity_GetAbsOrigin(car, lastpos[car]);
	}
}
public Action Cmd_VehicleExit(int client, int args) {
	for (int i = 1; i <= MaxClients; i++) {
		if( !IsValidClient(i) )
			continue;
		
		int vehicle = GetEntPropEnt(i, Prop_Send, "m_hVehicle");
		if( vehicle > 0 )
			rp_ClientVehicleExit(i, vehicle);
		
		int passager = rp_GetClientVehiclePassager(i);
		if( passager > 0 )
			rp_ClientVehiclePassagerExit(i, passager);

	}
	return Plugin_Handled;
}
public void OnMapStart() {
	g_cExplode = PrecacheModel("materials/sprites/muzzleflash4.vmt", true);
}
public void OnClientPostAdminCheck(int client) {
	rp_HookEvent(client, RP_OnPlayerUse, fwdUse);
	rp_HookEvent(client, RP_OnPlayerBuild, fwdOnPlayerBuild);
	
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	
	for (int i = 1; i < 65; i++)
		g_iBlockedTime[client][i] = 0;
}
public bool FilterToVehicle(int entity, int mask, any data) {
	return rp_IsValidVehicle(entity) && entity != data;
}
public Action OnTakeDamage(int victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3]) {
	
	if( damagetype == 1 && inflictor == 0 && attacker == 0 && weapon == -1 && damageForce[0] == 0.0 && damageForce[1] == 0.0 && damageForce[2] <= -8192.0 ) {
		// Bug relou des voitures.
		return Plugin_Stop;
	}
	
	if( victim == attacker && IsValidClient(victim) && rp_IsValidVehicle(inflictor) && damagetype == 17 ) {
		
		if( GetVectorLength(damageForce) > 8192.0 ) {
			int tick = GetGameTickCount();
			
			
			if( g_lastDamage[inflictor]+1 >= tick) {
				g_damageCount[inflictor]++;
			}
			else {
				g_damageCount[inflictor] = 0;
				
				float g_flVehicleDamage = GetConVarFloat(FindConVar("rp_car_damages")) / 10.0;
				int heal = RoundToCeil(damage * g_flVehicleDamage);
				
				if( heal > 250 )
					heal = 250;
				
				if( heal > 0 ) {
					rp_SetVehicleInt(inflictor, car_health, rp_GetVehicleInt(inflictor, car_health) - heal);
				}
			}
			
			g_lastDamage[inflictor] = tick;
			
			return Plugin_Stop;
		}
		else {
			
			float g_flVehicleDamage = GetConVarFloat(FindConVar("rp_car_damages")) / 10.0;
			int heal = RoundToCeil(damage * g_flVehicleDamage);
			
			if( heal > 0 ) {
				rp_SetVehicleInt(inflictor, car_health, rp_GetVehicleInt(inflictor, car_health) - heal); 
			}
		}
	}
	
	if( rp_IsValidVehicle(attacker) && rp_IsValidVehicle(inflictor) ) {
		float g_flVehicleDamage = GetConVarFloat(FindConVar("rp_car_damages")) / 2.0;
		float min[3] =  { -16.0, -16.0, -16.0 };
		float max[3] =  { 16.0, 16.0, 16.0 };
		Handle tr = TR_TraceHullFilterEx(damagePosition, damagePosition, min, max, MASK_ALL, FilterToVehicle, inflictor);
		if( TR_DidHit(tr) ) {
				
			int InVehicle = TR_GetEntityIndex(tr);
			if( rp_IsValidVehicle(InVehicle) ) {
				if( damage > 50.0 )
					damage = 50.0;
				
				float delta = (SquareRoot(float(GetEntProp(inflictor, Prop_Send, "m_nSpeed"))) + 1.0) / (SquareRoot(float(GetEntProp(InVehicle, Prop_Send, "m_nSpeed"))) + 1.0);
				
				int heal = RoundToCeil(damage * g_flVehicleDamage * delta);
				
				if( heal > 0 ) {
					rp_SetVehicleInt(InVehicle, car_health, rp_GetVehicleInt(InVehicle, car_health) - heal);
				}
				
				heal = RoundToCeil(damage * g_flVehicleDamage * (1.0-delta));
				
				if( heal > 0 ) {
					rp_SetVehicleInt(inflictor, car_health, rp_GetVehicleInt(inflictor, car_health) - heal);
				}
			}
		}
		CloseHandle(tr);
	}
	
	if( IsValidClient(attacker) && rp_IsValidVehicle(inflictor) && IsValidClient(victim) ) {
		float g_flVehicleDamage = GetConVarFloat(FindConVar("rp_car_damages")) / 5.0;
		int heal = RoundToCeil(damage * g_flVehicleDamage);
		if( heal > GetClientHealth(victim) ) {
			heal = GetClientHealth(victim);
		}
		
		if( !(rp_GetZoneBit(rp_GetPlayerZone(victim)) & BITZONE_ROAD) ) {		
			if( heal > 0 ) {
				rp_SetVehicleInt(inflictor, car_health, rp_GetVehicleInt(inflictor, car_health) - heal);
			}
		}
	}
	
	if( Client_GetVehicle(victim) > 0 ) {
		if( attacker > 0 && inflictor == attacker ) {
			char tmp[64];
			GetEdictClassname(inflictor, tmp, sizeof(tmp));
			if( StrEqual(tmp, "entityflame") )
				return Plugin_Continue;
		}
		
		return Plugin_Handled;
	}
		
	return Plugin_Continue;
}
public void OnClientDisconnect(int client) {
	for (int i = MaxClients+1; i <= 2048; i++) {
		if( !IsValidEdict(i) )
			continue;
		if( !IsValidEntity(i) )
			continue;
		if( rp_GetVehicleInt(i, car_owner) == client) {
			VehicleRemove(i);
		}
	}
}
// ----------------------------------------------------------------------------
public Action fwdOnPlayerBuild(int client, float& cooldown){
	if( rp_GetClientJobID(client) != 51 )
		return Plugin_Continue;
	
	Handle menu = CreateMenu(SpawnVehicle);
	SetMenuTitle(menu, "Une voiture pour 6 minutes");

	AddMenuItem(menu, "mustang",	"Mustang");
	AddMenuItem(menu, "victoria",	"Victoria");
	AddMenuItem(menu, "moto", 		"Moto");

	DisplayMenu(menu, client, 60);
	cooldown = 5.0;
	
	return Plugin_Stop;
}
public Action taskGarageMenu(Handle timer, any client) {
	if( rp_ClientCanDrawPanel(client) )
		DisplayGarageMenu(client);
}
public Action fwdUse(int client) {
	
	if( IsInGarage(client) && rp_ClientCanDrawPanel(client) ) { 
		CreateTimer(0.1, taskGarageMenu, client);
	}
	
	int target = rp_GetClientTarget(client);
	int vehicle = GetEntPropEnt(client, Prop_Send, "m_hVehicle");
	int passager = rp_GetClientVehiclePassager(client);
	
	// 
	if( vehicle > 0 ) {
		int speed = GetEntProp(vehicle, Prop_Data, "m_nSpeed");
		int buttons = GetClientButtons(client);
			
		if( speed <= 20 && !(buttons & IN_DUCK) ) {
			rp_ClientVehicleExit(client, vehicle);
		}
	}
	else if( passager > 0 ) {
		rp_ClientVehiclePassagerExit(client, passager);
	}
	else if( rp_IsValidVehicle(target) && rp_IsEntitiesNear(client, target, true) && rp_IsTutorialOver(client) ) {
		
		int driver = GetEntPropEnt(target, Prop_Send, "m_hPlayer");
		if( driver > 0 ) {
			
			if( rp_GetVehicleInt(target, car_owner) == client && driver != client ) {
				CPrintToChat(client, "" ...MOD_TAG... " Vous pouvez éjecter le conducteur avec la commande /out.");
			}
			AskToJoinCar(client, target);			
		}
		else {
			rp_SetClientVehicle(client, target, true);
		}
	}
}
// ----------------------------------------------------------------------------
int countVehicle(int client) {
	int count = 0;
	for(int i=MaxClients; i<=2048; i++) {
		if( !rp_IsValidVehicle(i) )
			continue;
		
		count++;
		if( rp_GetVehicleInt(i, car_owner) == client )
			count += 5;
	}
	return count;
}
public Action Cmd_SpawnVehicle(int client, int args) {
	
	if( !(rp_GetZoneBit(rp_GetPlayerZone(client)) & BITZONE_EVENT ) ) {
		CPrintToChat(client, "" ...MOD_TAG... " Vous devez être en zone event.");
		return Plugin_Handled;
	}
	
	float vecOrigin[3], vecAngles[3];
	GetClientAbsOrigin(client, vecOrigin);
	vecOrigin[2] += 10.0;
	
	GetClientEyeAngles(client, vecAngles);
	vecAngles[0] = vecAngles[2] = 0.0;
	vecAngles[1] -= 90.0;
	
	int car = rp_CreateVehicle(vecOrigin, vecAngles, "models/natalya/vehicles/natalya_mustang_csgo_2016.mdl", 1, client);
	if( !car ) {
		CPrintToChat(client, "" ...MOD_TAG... " Il n'y a pas assez de place ici.");
		return Plugin_Handled;
	}
	
	rp_SetVehicleInt(car, car_owner, 0);
	rp_SetVehicleInt(car, car_item_id, 0);
	rp_SetVehicleInt(car, car_maxPassager, 3);
	rp_SetVehicleInt(car, car_donateur, 0);
	rp_SetVehicleInt(car, car_boost, 1);
	
	return Plugin_Handled;
	
}
public Action Cmd_ItemVehicle(int args) {
	
	char arg1[128];
	GetCmdArg(1, arg1, sizeof(arg1));
	
	int skinid = GetCmdArgInt(2);
	int client = GetCmdArgInt(3);
	int sendToBank = 0;
	if( args == 5 )
		sendToBank = GetCmdArgInt(4);
	
	int item_id = GetCmdArgInt(args);
	int max = 0;
	
	if( StrEqual(arg1, "models/natalya/vehicles/natalya_mustang_csgo_2016.mdl") ) {
		max = 3;
	}
	if( StrEqual(arg1, "models/natalya/vehicles/police_crown_victoria_csgo_v2.mdl") ) {
		max = 3;
	}
	
	if( rp_GetZoneBit( rp_GetPlayerZone(client) ) & BITZONE_PEACEFULL ) {
		CAR_CANCEL(client, item_id, sendToBank);
		CPrintToChat(client, "" ...MOD_TAG... " Cet objet est interdit où vous êtes.");
		return Plugin_Handled;
	}
	
	if( countVehicle(client) >= GetConVarInt(g_hMAX_CAR) ) {
		CAR_CANCEL(client, item_id, sendToBank);
		CPrintToChat(client, "" ...MOD_TAG... " Il y a trop de voitures en circulation pour l'instant.");
		return Plugin_Handled;			
	}
	
	float vecOrigin[3], vecAngles[3];
	GetClientAbsOrigin(client, vecOrigin);
	vecOrigin[2] += 10.0;
	
	GetClientEyeAngles(client, vecAngles);
	vecAngles[0] = vecAngles[2] = 0.0;
	vecAngles[1] -= 90.0;
	
	int car = rp_CreateVehicle(vecOrigin, vecAngles, arg1, skinid, client);
	if( !car ) {
		CAR_CANCEL(client, item_id, sendToBank);
		CPrintToChat(client, "" ...MOD_TAG... " Il n'y a pas assez de place ici.");
		return Plugin_Handled;
	}
	
	rp_SetVehicleInt(car, car_owner, client);
	rp_SetVehicleInt(car, car_item_id, item_id);
	rp_SetVehicleInt(car, car_maxPassager, max);
	rp_SetVehicleInt(car, car_donateur, 0);
	
	rp_SetClientKeyVehicle(client, car, true);
	
	// Voiture donateur, on la thune wesh
	char arg0[128];
	GetCmdArg(0, arg0, sizeof(arg0));
	if( StrEqual(arg0, "rp_item_vehicle2") && StrEqual(arg1, "models/natalya/vehicles/natalya_mustang_csgo_2016.mdl") ) {
		ServerCommand("sm_effect_colorize %d 255 64 32 255", car);
		rp_SetVehicleInt(car, car_particle, 9);
		rp_SetVehicleInt(car, car_battery, 1);
		rp_SetVehicleInt(car, car_light_r, 255);
		rp_SetVehicleInt(car, car_light_g, 64);
		rp_SetVehicleInt(car, car_light_b, 32);
		rp_SetVehicleInt(car, car_boost, 1);
		rp_SetVehicleInt(car, car_donateur, 1);

		DispatchKeyValue(car, "vehiclescript", 	"scripts/vehicles/natalya_mustang_csgo_20163.txt");
		ServerCommand("vehicle_flushscript");
		attachVehicleLight(car);
	}
	
	if( StrEqual(arg0, "rp_item_vehicle3") ) {
		rp_SetVehicleInt(car, car_owner, 0);
	}
	
	return Plugin_Handled;
}
public void VehicleTouch(int car, int entity) {
	
	if( rp_IsValidDoor(entity) ) {
		
		int client = Vehicle_GetDriver(car);
		int door = rp_GetDoorID(entity);
		int tick = GetGameTickCount();
		
		if( client > 0 && rp_GetClientKeyDoor(client, door) ) {
			if( g_lastTouch[car]+1 >= tick) {
				g_touchCount[car]++;
			}
			else {
				g_touchCount[car] = 0;
			}
			
			if( g_touchCount[car] > 64 && g_damageCount[car] > 64 ) {
				rp_SetDoorLock(door, false);
				rp_ClientOpenDoor(client, door, true);
				
				g_touchCount[car] = 0;
				g_damageCount[car] = 0;
			}
			g_lastTouch[car] = GetGameTickCount();
		}
	}
}
public void CAR_CANCEL(int client, int item_id, int fromBank ){
	if( item_id != -1) {
		if( fromBank == 1 ) {
			rp_ClientGiveItem(client, item_id, 1, true);
		}
		else {
			ITEM_CANCEL(client, item_id);
		}
	}
}
public Action Cmd_ItemVehicleStuff(int args) {
	static int offset = -1;	
	
	char arg1[12];
	GetCmdArg(1, arg1, sizeof(arg1));
	
	int client = GetCmdArgInt(2);
	int target = GetClientAimTarget(client, false);
	int item_id = GetCmdArgInt(args);
	
	if( !rp_IsValidVehicle(target) ) {
		ITEM_CANCEL(client, item_id);
		return Plugin_Handled;
	}
	
	
	if( !rp_GetClientKeyVehicle(client, target) ) {
		ITEM_CANCEL(client, item_id);
		return Plugin_Handled;
	}
	
	if( offset == -1 ) {
		offset = GetEntSendPropOffs(target, "m_clrRender", true);
	}
	
	if( StrEqual(arg1, "key") ) {
		
		if( Vehicle_GetDriver(target) != client) {
			CPrintToChat(client, "" ...MOD_TAG... " Vous devez utiliser cet objet dans votre voiture.");
			ITEM_CANCEL(client, item_id);
			return Plugin_Handled;
		}
		
		if( rp_GetVehicleInt(target, car_owner) != client ) {
			CPrintToChat(client, "" ...MOD_TAG... " Vous n'êtes pas le propriétaire de cette voiture.");
			ITEM_CANCEL(client, item_id);
			return Plugin_Handled;
		}
		
		int amount=0;
		for(int i=1; i<=MaxClients; i++) {
			if( !IsValidClient(i) )
				continue;
			if( !rp_IsTutorialOver(i) )
				continue;
			if( rp_GetClientVehiclePassager(i) != target )
				continue;
			if( rp_GetClientKeyVehicle(i, target) )
				continue;
			
			amount++;
			rp_SetClientKeyVehicle(i, target, true);
			CPrintToChat(client, "" ...MOD_TAG... " %N{default} a maintenant la clé de votre voiture.", i);
		}
		
		if( amount == 0 ) {
			CPrintToChat(client, "" ...MOD_TAG... " Il n'y a personne dans votre voiture à qui donner la clé.");
			ITEM_CANCEL(client, item_id);
			return Plugin_Handled;
		}
		
		
	}
	else if( StrEqual(arg1, "gang") ) {
		
		int gID = rp_GetClientGroupID(client);
		
		if( gID == 0 ) {
			CPrintToChat(client, "" ...MOD_TAG... " Vous n'avez pas de gang.");
			ITEM_CANCEL(client, item_id);
			return Plugin_Handled;
		}
		if( Vehicle_GetDriver(target) != client) {
			CPrintToChat(client, "" ...MOD_TAG... " Vous devez utiliser cet objet dans votre voiture.");
			ITEM_CANCEL(client, item_id);
			return Plugin_Handled;
		}
		
		if( rp_GetVehicleInt(target, car_owner) != client ) {
			CPrintToChat(client, "" ...MOD_TAG... " Vous n'êtes pas le propriétaire de cette voiture.");
			ITEM_CANCEL(client, item_id);
			return Plugin_Handled;
		}
		
		int amount=0;
		for(int i=1; i<=MaxClients; i++) {
			if( !IsValidClient(i) )
				continue;
			if( rp_GetClientGroupID(i) != gID )
				continue;
			if( rp_GetClientKeyVehicle(i, target) )
				continue;
			if( !rp_IsTutorialOver(i) )
				continue;
			
			amount++;
			rp_SetClientKeyVehicle(i, target, true);
			CPrintToChat(client, "" ...MOD_TAG... " %N{default} a maintenant la clé de votre voiture.", i);
		}
		if( amount == 0 ) {
			CPrintToChat(client, "" ...MOD_TAG... " Vous n'avez personne à qui donner la clé.");
			ITEM_CANCEL(client, item_id);
			return Plugin_Handled;
		}
	}
	else if( StrEqual(arg1, "battery") ){
		if(rp_GetVehicleInt(target, car_battery)!= -1){
			CPrintToChat(client, "" ...MOD_TAG... " Votre voiture est déjà équipée d'une batterie secondaire.");
			ITEM_CANCEL(client, item_id);
			return Plugin_Handled;
		}
		
		if( target == EntRefToEntIndex(g_iVehiclePolice) || target == EntRefToEntIndex(g_iVehicleJustice) ) {
			CPrintToChat(client, "" ...MOD_TAG... " Il n'est pas possible d'équiper une voiture de fonction d'une batterie.");
			ITEM_CANCEL(client, item_id);
			return Plugin_Handled;
		}
		
		rp_SetVehicleInt(target, car_battery, 0);
		CPrintToChat(client, "" ...MOD_TAG... " Votre voiture est maintenant équipée d'une batterie secondaire.");
	}
	else if( StrEqual(arg1, "jump") ){
		if( rp_GetVehicleInt(target, car_can_jump) == 1 ){
			CPrintToChat(client, "" ...MOD_TAG... " Votre voiture est déjà équipée de suspensions hydrauliques.");
			ITEM_CANCEL(client, item_id);
			return Plugin_Handled;
		}
		rp_SetVehicleInt(target, car_can_jump, 1);
		CPrintToChat(client, "" ...MOD_TAG... " Votre voiture est maintenant équipée de suspensions hydrauliques.");
	}
	else if( StrEqual(arg1, "boost") ){
		if( rp_GetVehicleInt(target, car_boost) != -1){
			CPrintToChat(client, "" ...MOD_TAG... " Votre voiture est déjà équipée d'un boost.");
			ITEM_CANCEL(client, item_id);
			return Plugin_Handled;
		}
		
		rp_SetVehicleInt(target, car_boost, 1);
		char ScriptPath[PLATFORM_MAX_PATH], buffer[8][64];
		Entity_GetModel(target, ScriptPath, sizeof(ScriptPath));
		int amount = ExplodeString(ScriptPath, "/", buffer, sizeof(buffer), sizeof(buffer[]));
		if( amount > 0 ) {
			ReplaceString(buffer[amount-1], sizeof(buffer[]), ".mdl", "");
			Format(ScriptPath, sizeof(ScriptPath), "scripts/vehicles/%s2.txt", buffer[amount-1]);
			
			if( FileExists(ScriptPath) ) {
				DispatchKeyValue(target, "vehiclescript", 		ScriptPath);
				ServerCommand("vehicle_flushscript");
				CPrintToChat(client, "" ...MOD_TAG... " Votre voiture est maintenant équipée d'un boost.");
			}
			else {
				CPrintToChat(client, "" ...MOD_TAG... " Impossible d'installer un boost sur votre voiture.");
				ITEM_CANCEL(client, item_id);
			}
		}
		
		
	}
	
	return Plugin_Handled;
}
// ----------------------------------------------------------------------------
public int Native_rp_CreateVehicle(Handle plugin, int numParams) {
	LogToFile("vehicules.txt", "Native_rp_CreateVehicle");

	float origin[3], angle[3];
	int skin = GetNativeCell(4);
	int client = GetNativeCell(5);
	int l_model;
	GetNativeArray(1, origin, sizeof(origin));
	GetNativeArray(2, angle, sizeof(angle));
	GetNativeStringLength(3, l_model);
	char[] model = new char[ l_model + 2];
	GetNativeString(3, model, l_model + 1);

	// Thanks blodia: https://forums.alliedmods.net/showthread.php?p=1268368#post1268368
	
	int ent = CreateEntityByName("prop_vehicle_driveable");
	if( ent == -1) { return 0; } // Tout le monde sait que ça n'arrive jamais...
	
	char ScriptPath[PLATFORM_MAX_PATH], szSkin[12], buffer[8][64];
	bool valid = false;
	int amount = ExplodeString(model, "/", buffer, sizeof(buffer), sizeof(buffer[]));

	if( amount > 0 ) {
		ReplaceString(buffer[amount-1], sizeof(buffer[]), ".mdl", "");
		Format(ScriptPath, sizeof(ScriptPath), "scripts/vehicles/%s.txt", buffer[amount-1]);
		if(FileExists(ScriptPath)) {
			valid = true;
		}
	}

	if(!valid) {
		Format(ScriptPath, sizeof(ScriptPath), "scripts/vehicles/jeep.txt");
	}
	
	DispatchKeyValue(ent, "model", 				model);
	DispatchKeyValue(ent, "vehiclescript", 		ScriptPath);

	DispatchKeyValue(ent, "solid",				"6");
	DispatchKeyValue(ent, "actionScale",		"1");
	DispatchKeyValue(ent, "EnableGun",			"0");
	DispatchKeyValue(ent, "ignorenormals",		"0");
	DispatchKeyValue(ent, "fadescale",			"1");
	DispatchKeyValue(ent, "fademindist",		"-1");
	DispatchKeyValue(ent, "VehicleLocked",		"0");
	DispatchKeyValue(ent, "screenspacefade",	"0");
	DispatchKeyValue(ent, "spawnflags", 		"256" );
	DispatchKeyValue(ent, "setbodygroup", 		"511" );
	DispatchKeyValueFloat(ent, "MaxPitch", 		360.00);
	DispatchKeyValueFloat(ent, "MinPitch", 		-360.00);
	DispatchKeyValueFloat(ent, "MaxYaw", 		90.00);

	IntToString(skin, szSkin, sizeof(szSkin));
	DispatchKeyValue(ent, "skin", szSkin);
	DispatchKeyValue(ent, "body", "0");
	DispatchSpawn(ent);

	// check if theres space to spawn the vehicle.
	float MinHull[3],  MaxHull[3];
	GetEntPropVector(ent, Prop_Send, "m_vecMins", MinHull);
	GetEntPropVector(ent, Prop_Send, "m_vecMaxs", MaxHull);
	
	Handle trace;

	if( client == 0 )
		trace = TR_TraceHullEx(origin, origin, MinHull, MaxHull, MASK_SOLID);
	else
		trace = TR_TraceHullFilterEx(origin, origin, MinHull, MaxHull, MASK_SOLID, FilterToOne, client);

	if( TR_DidHit(trace) ) { 
		delete trace; 
		rp_AcceptEntityInput(ent, "Kill");	
		
		return 0; 
	}

	delete trace;

	TeleportEntity(ent, origin, angle, NULL_VECTOR);
	rp_SetVehicleInt(ent, car_light, -1);
	rp_SetVehicleInt(ent, car_light_r, -1);
	rp_SetVehicleInt(ent, car_light_g, -1);
	rp_SetVehicleInt(ent, car_light_b, -1);
	rp_SetVehicleInt(ent, car_battery, -1);
	rp_SetVehicleInt(ent, car_boost, -1);
	rp_SetVehicleInt(ent, car_particle, -1);	
	rp_SetVehicleInt(ent, car_health, GetConVarInt(g_hCarHeal));
	rp_SetVehicleInt(ent, car_klaxon, Math_GetRandomInt(1, 6));
	rp_SetVehicleInt(ent, car_can_jump, -1);
	rp_SetVehicleInt(ent, car_item_id, 0);
	rp_SetVehicleInt(ent, car_owner, 0);
	
	SetEntProp(ent, Prop_Data, "m_takedamage", DAMAGE_NO); // Nope
	//SetEntProp(ent, Prop_Data, "m_nNextThinkTick", -1);
	SetEntProp(ent, Prop_Data, "m_bHasGun", 0);
	
	SDKHook(ent, SDKHook_Think, OnThink);	
	

	//rp_AcceptEntityInput(ent, "HandBrakeOn");
	rp_AcceptEntityInput(ent, "TurnOff");
	
	if( IsValidClient(client) ) {
		
		rp_SetVehicleInt(ent, car_owner, client);
		rp_SetClientKeyVehicle(client, ent, true);
	
		rp_SetClientVehicle(client, ent, true);

		 // PLEASE CHECK AGAIN SERVER WAS SLOW OK?
		Handle dp;
		CreateDataTimer(0.1, rp_SetClientVehicleTask, dp, TIMER_DATA_HNDL_CLOSE);
		WritePackCell(dp, client);
		WritePackCell(dp, ent);
	}
	
	SDKHook(ent, SDKHook_Touch, VehicleTouch);
	CreateTimer(3.5, Timer_VehicleRemoveCheck, EntIndexToEntRef(ent));
	CreateTimer(0.5, Timer_Flush);

	return ent;
}
public Action Timer_Flush(Handle timer, any none) {
	ServerCommand("vehicle_flushscript");
}
public void OnThink(int ent) {
	SetEntPropFloat(ent, Prop_Data, "m_flTurnOffKeepUpright", 1.0);
	SetEntProp(ent, Prop_Send, "m_bEnterAnimOn", 0);
	
	if( rp_GetVehicleInt(ent, car_can_jump) == 1 ) {
		int player = Vehicle_GetDriver(ent);
		if( player > 0 && IsValidClient(player) && (GetClientButtons(player) & IN_DUCK) ) {
			Handle trace;
			float src[3], ang[3], dst[3];
			Entity_GetAbsOrigin(ent, src);
			Entity_GetAbsAngles(ent, ang);
			src[2] += 8.0;
			ang[0] += 90.0;
			trace = TR_TraceRayFilterEx(src, ang, MASK_SHOT, RayType_Infinite, FilterToAll);
			
			if( TR_DidHit(trace) ) {
				TR_GetEndPosition(dst, trace);
				
				if( GetVectorDistance(src, dst) <= 9.0 ) {
					float speed = float(GetEntProp(ent, Prop_Send, "m_nSpeed"));
					ang[0] -= 90.0;
					ang[1] += 90.0;
					GetAngleVectors(ang, dst, NULL_VECTOR, NULL_VECTOR);
					ScaleVector(dst, speed*25.0);
					dst[2] += 400.0;
					
					TeleportEntity(ent, NULL_VECTOR, NULL_VECTOR, dst);
				}
			}
			delete trace;
		}
	}
}
public bool FilterToAll(int entity, int mask, any data) {
	return (entity < 0);
}
void VehicleRemove(int vehicle, bool explode = false) {
	if( vehicle <= 0 || !rp_IsValidVehicle(vehicle) )
		return;
	
	int client = GetEntPropEnt(vehicle, Prop_Send, "m_hPlayer");
	if( IsValidClient(client) )
		rp_ClientVehicleExit(client, vehicle, true);

	CreateTimer(0.1, BatchLeave, vehicle);
	
	for(int i=1; i<=MaxClients; i++) {
		rp_SetClientKeyVehicle(i, vehicle, false);
		int j = rp_GetClientVehiclePassager(i);
		if( j == vehicle )
			rp_ClientVehiclePassagerExit(i, vehicle);
	}
	
	rp_SetVehicleInt(vehicle, car_owner, -1);
	rp_SetVehicleInt(vehicle, car_particle, -1);
	
	if( explode ) {
		IgniteEntity(vehicle, 1.75);
		// Bim, boum badaboum.
		for(float time = 0.0; time<=2.5; time+=0.75 ) {
			float vecOrigin[3];
			Entity_GetAbsOrigin(vehicle, vecOrigin);
			
			vecOrigin[0] += GetRandomFloat(-20.0, 20.0);
			vecOrigin[1] += GetRandomFloat(-20.0, 20.0);
			vecOrigin[2] += GetRandomFloat(5.0, 20.0);
			
			TE_SetupExplosion(vecOrigin, g_cExplode, GetRandomFloat(0.5, 2.0), 2, 1, Math_GetRandomInt(25, 100) , Math_GetRandomInt(25, 100) );
			TE_SendToAll(time);
		}
	}
	dettachVehicleLight(vehicle);
	
	char class[64];
	for (int i = MaxClients; i < 2049; i++) {
		if( !IsValidEdict(i) || !IsValidEntity(i) )
			continue;
		
		GetEdictClassname(i, class, sizeof(class));
		if( StrEqual(class, "rp_gyrophare") && Entity_GetParent(i) == vehicle )
			rp_AcceptEntityInput(i, "Kill");
	}
	
	ServerCommand("sm_effect_fading %i 2.5 1", vehicle);
	rp_ScheduleEntityInput(vehicle, 2.5, "Kill");
}
// ----------------------------------------------------------------------------
public Action rp_SetClientVehicleTask(Handle timer, Handle dp) {
	
	ResetPack(dp);
	int client = ReadPackCell(dp);
	int car = ReadPackCell(dp);
	rp_SetClientVehicle(client, car, true);
}
public Action BatchLeave(Handle timer, any vehicle) {
	
	if( vehicle <= 0 )
		return;
	int client = GetEntPropEnt(vehicle, Prop_Send, "m_hPlayer");
	
	if( IsValidClient(client) ) {
		rp_ClientVehicleExit(client, vehicle, true);
		
		
		for(int i=1; i<=MaxClients; i++) {
			if( !IsValidClient(i) )
				continue;
			rp_ClientVehicleExit(i, vehicle, true);
		}
	}
}

void attachPoliceLight(int target) {
	float pos[3], ang[3];
	char tmp[128];
	
	Entity_GetAbsOrigin(target, pos);
	pos[2] += 76.0;
	
	int cpt = 2;
	int color[3];
	
	if( rp_GetVehicleInt(target, car_health) <= 0 )
		return;
	
	for (int j = 1; j <= 2; j++) {
		int parent = CreateEntityByName("info_target");
		DispatchKeyValue(parent, "classname", "rp_gyrophare");
		SetVariantString("!activator");
		AcceptEntityInput(parent, "SetParent", target);
		
		Format(tmp, sizeof(tmp), "light_bar%d", j);
		SetVariantString(tmp);
		AcceptEntityInput(parent, "SetParentAttachment", parent, parent, 0);
		
		g_bEntityManaged[parent] = true;
		
		
		
		if( EntRefToEntIndex(rp_GetVehicleInt(target, j == 1 ? car_gyro_right : car_gyro_left)) > 0 ) {
			AcceptEntityInput(EntRefToEntIndex(rp_GetVehicleInt(target, j == 1 ? car_gyro_right : car_gyro_left)), "Kill");
		}
		rp_SetVehicleInt(target, j == 1 ? car_gyro_right : car_gyro_left, EntIndexToEntRef(parent));
		
		for (int i = 0; i < cpt; i++) {
			ang[0] += (360.0 / float(cpt));
			
			int ent = CreateEntityByName("point_spotlight");
			
			if( j%2 == 0 ) {
				color[0] = 255;
				color[1] = 0;
				color[2] = 0;
			}
			else {
				color[0] = 0;
				color[1] = 0;
				color[2] = 255;
			}
			
			Format(tmp, sizeof(tmp), "%d %d %d", color[0], color[1], color[2]);
			DispatchKeyValue(ent, "rendercolor", tmp);
			DispatchKeyValue(ent, "renderamt", "255");
			
			DispatchKeyValue(ent, "spotlightwidth", "8");
			DispatchKeyValue(ent, "spotlightlength", "64");
			DispatchKeyValue(ent, "spawnflags", "3");
			
			DispatchSpawn(ent);
			//
			
			SetVariantString("!activator");
			AcceptEntityInput(ent, "SetParent", parent);
			
			TeleportEntity(ent, view_as<float>({0.0, 0.0, 0.0}), ang, NULL_VECTOR);
			
			g_flEntity[ent] = ang[0];
			SDKHook(ent, SDKHook_Think, fwdThink2);
		}
		
	}
}
#define FCT RoundFloat(GetTickedTime() * 5.0)
public void fwdThink2(int ent) {
	int p = GetEntPropEnt(ent, Prop_Data, "m_hEffectEntity");
	
	if (p == -1) {
		char tmp[64];
		for (int i = MaxClients; i <= 2048; i++) {
			if (!IsValidEdict(i) || !IsValidEntity(i))
				continue;
			
			GetEdictClassname(i, tmp, sizeof(tmp));
			if (StrEqual(tmp, "beam")) {
				int j = GetEntPropEnt(i, Prop_Data, "m_hAttachEntity");
				if (j == ent) {
					SetEntPropEnt(ent, Prop_Data, "m_hEffectEntity", i);
					p = i;
				}
			}
		}
	}
	
	if (p > 0) {
		float s = 8.0 + (32.0 * OctavePerlin(FCT, 8, 2, 8.0, 2.0));
		SetEntPropFloat(p, Prop_Send, "m_fWidth", s);
		
		float ang[3];
		Entity_GetAbsAngles(ent, ang);
		ang[1] = 90.0;
		ang[0] = g_flEntity[ent];
		
		g_flEntity[ent] += 2.0;
		
		TeleportEntity(p, NULL_VECTOR, ang, NULL_VECTOR);
		TeleportEntity(ent, NULL_VECTOR, ang, NULL_VECTOR);
	}
}

float perlin(int n) {
	n = (n << 13) ^ n;
	float r = (1.0 - ((n * ((n * n * 15731) + 789221) + 1376312589) & 0x7fffffff) / 1073741824.0);
	return (r + 1.0) / 2.0;
}
public float OctavePerlin(int x, int frequency, int octaves, float persistence, float amplitude) {
	float total = 0.0;
	float maxValue = 0.0;
	
	for (int i = 0; i < octaves; i++) {
		total += perlin(x * frequency) * amplitude;
		
		maxValue += amplitude;
		
		amplitude *= persistence;
		frequency *= 2;
	}
	
	return total / maxValue;
}
void attachVehicleLight(int vehicle) {
	if( rp_GetVehicleInt(vehicle, car_light) > 0 ||  rp_GetVehicleInt(vehicle, car_light_r) == -1 ||  rp_GetVehicleInt(vehicle, car_light_g) == -1 ||  rp_GetVehicleInt(vehicle, car_light_b) == -1 )
		return;
		
	char model[128], color[128];
	Format(color, sizeof(color), "%d %d %d 800", rp_GetVehicleInt(vehicle, car_light_r), rp_GetVehicleInt(vehicle, car_light_g), rp_GetVehicleInt(vehicle, car_light_b));
	Entity_GetModel(vehicle, model, sizeof(model));
	
	int ent = CreateEntityByName("env_projectedtexture");
	DispatchKeyValue(ent, "nearz", "22");
	DispatchKeyValue(ent, "farz", "64");
	DispatchKeyValue(ent, "texturename", "effects/flashlight001");
	DispatchKeyValue(ent, "lightcolor", color);
	DispatchKeyValue(ent, "spawnflags", "3");
	
	if( StrContains(model, "dirtbike") != -1 )
		DispatchKeyValue(ent, "lightfov", "90");
	else
		DispatchKeyValue(ent, "lightfov", "170");
	
	DispatchKeyValue(ent, "brightnessscale", "50");
	DispatchKeyValue(ent, "lightworld", "1");
	
	DispatchSpawn(ent);
	
	SetVariantString("!activator");
	rp_AcceptEntityInput(ent, "SetParent", vehicle);
	TeleportEntity(ent, view_as<float>({0.0, 0.0, 24.0}), view_as<float>({ 90.0, 0.0, 0.0 }), NULL_VECTOR);
	
	rp_SetVehicleInt(vehicle, car_light, ent);
}
void dettachVehicleLight(int vehicle) {
	char class[128];
		
	int ent = rp_GetVehicleInt(vehicle, car_light);
	if( ent > 0 ) {
		GetEdictClassname(ent, class, sizeof(class));
		
		if( StrEqual(class, "env_projectedtexture") && Entity_GetParent(ent) == vehicle )
			rp_AcceptEntityInput(ent, "Kill");
	}
	
	rp_SetVehicleInt(vehicle, car_light, -1);
}
public Action Timer_VehicleRemoveCheck(Handle timer, any ent) {
	static int rotate[2049];
	ent = EntRefToEntIndex(ent);
	if( ent <= 0 || !IsValidEdict(ent) )
		return Plugin_Handled;
	
	bool IsNear = false;
	float vecOrigin[3];
	Entity_GetAbsOrigin(ent, vecOrigin);
	
	int owner = rp_GetVehicleInt(ent, car_owner);
	if( rp_GetVehicleInt(ent, car_health) <= 0 ) {
		if( IsValidClient(owner) ) {
			CPrintToChat(owner, ""...MOD_TAG..." Votre voiture a explosé");
		}
		VehicleRemove(ent, true);
		return Plugin_Handled;
	}
	
	if( !Vehicle_HasDriver(ent) && (!IsValidClient(owner) || Entity_GetDistance(owner, ent) > 512) )
		dettachVehicleLight(ent);
		
	if( Vehicle_HasDriver(ent) ) {
		IsNear = true;
		int driver = GetEntPropEnt(ent, Prop_Send, "m_hPlayer");		
		if( GetVectorDistance(g_lastpos[ent], vecOrigin) > 50.0 && !rp_GetClientBool(driver, b_IsAFK) ) {
			int particule = rp_GetVehicleInt(ent, car_particle);
			int batterie = rp_GetVehicleInt(ent, car_battery);
			
			if( particule != -1 ) {
				ServerCommand("sm_effect_particles %d %s 1 light_rl", ent, g_szParticles[particule][0]);
				ServerCommand("sm_effect_particles %d %s 1 light_rr", ent, g_szParticles[particule][0]);	
			}
			attachVehicleLight(ent);
			
			if( batterie != -1 && !rp_GetClientBool(driver, b_IsAFK) ) {
				if( rp_GetVehicleInt(ent, car_battery) < 420 ) {
					rp_SetVehicleInt(ent, car_battery, rp_GetVehicleInt(ent, car_battery)+1);
					
					if( rp_GetVehicleInt(ent, car_battery) == 420 )
						CPrintToChat(driver, "" ...MOD_TAG... " Votre batterie est pleine vous pouvez maintenant aller au garage pour la revendre.");
					else if( rp_GetVehicleInt(ent, car_battery)%42 == 0 )
						CPrintToChat(driver, "" ...MOD_TAG... " Votre batterie est chargée à %i%%.", rp_GetVehicleInt(ent, car_battery)*100/420);
				}
			}
			g_lastpos[ent] = vecOrigin;
		}
	}
	else if( rp_GetZoneBit(rp_GetPlayerZone(ent)) & (BITZONE_PARKING|BITZONE_EVENT) )
		IsNear = true;
	else {
		float vecTarget[3];
			
		for(int client=1; client<=MAXPLAYERS; client++) {
			if( !IsValidClient(client) )
				continue;
			
			if( rp_GetClientVehiclePassager(client) == ent ) {
				IsNear = true;
				break;
			}
			
			if( rp_GetClientKeyVehicle(client, ent) ) {
				
				Entity_GetAbsOrigin(client, vecTarget);
					
				if( GetVectorDistance(vecOrigin, vecTarget) <= 4000.0 ) {
					IsNear = true;
					break;
				}
				
				int appart = rp_GetPlayerZoneAppart(client);
				if( appart > 0 && rp_GetAppartementInt(appart, appart_bonus_garage) ) {
					IsNear = true;
					break;
				}
			}
		}
	}
		
	if( !IsNear ) {
		int tick = rp_GetVehicleInt(ent, car_awayTick) + 1;
		rp_SetVehicleInt(ent, car_awayTick, tick );
		
		if( tick > 12*60 ) {		
			if( IsValidClient(owner) ) {
				CPrintToChat(owner, ""...MOD_TAG..." Votre voiture est restée trop longtemps sans surveillance et a été détruite.");
			}
			VehicleRemove(ent);
			return Plugin_Handled;
		}
	}
	else {
		rp_SetVehicleInt(ent, car_awayTick, 0 );
	}
	
	float vecAngles[3];
	Entity_GetAbsAngles(ent, vecAngles);
	
	if( (vecAngles[2] >= 150 || vecAngles[2] <= -150) && !rp_IsGrabbed(ent) ) {
		
		if( GetEntProp(ent, Prop_Data, "m_nSpeed") == 0 )
			rotate[ent]++;
	
		if( rotate[ent] >= 5 &&  GetConVarInt(g_hCarUnstuck) == 1 ) {
			vecOrigin[0] = Math_GetRandomFloat(-100.0, 100.0);
			vecOrigin[1] = Math_GetRandomFloat(-100.0, 100.0);
			vecOrigin[2] = Math_GetRandomFloat(200.0, 300.0);
			
			vecAngles[0] = 0.0;
			vecAngles[2] = 0.0;
			TeleportEntity(ent, NULL_VECTOR, vecAngles, NULL_VECTOR);
			rotate[ent] = 0;
		}
	}
	else if( rotate[ent] > 0 ) {
		rotate[ent]--;
	}
	
	CreateTimer(1.01, Timer_VehicleRemoveCheck, EntIndexToEntRef(ent));
	return Plugin_Continue;
}
// ----------------------------------------------------------------------------
void AskToJoinCar(int client, int vehicle) {
	
	if( rp_GetVehicleInt(vehicle, car_maxPassager) <= CountPassagerInVehicle(vehicle) ) {
		CPrintToChat(client, "" ...MOD_TAG... " Il n'y a plus de place dans cette voiture.");
		return;
	}
	
	int driver = GetEntPropEnt(vehicle, Prop_Send, "m_hPlayer");
	if( g_iBlockedTime[driver][client] != 0 ) {
		if( (g_iBlockedTime[driver][client]+(6*60)) >= GetTime() ) {
			CPrintToChat(client, "" ...MOD_TAG... " Ce conducteur ne vous repondra pas.");
			return;
		}
	}
	char tmp[255];	
	Handle menu = CreateMenu(AskToJoinCar_Menu);
	
	Format(tmp, sizeof(tmp), "%N souhaite entrer dans votre voiture.\n L'acceptez-vous ?\n ", client);
	SetMenuTitle(menu, tmp);
	
	Format(tmp, sizeof(tmp), "%i_%i_1", client, vehicle);	AddMenuItem(menu, tmp, "Accepter la demande");
	Format(tmp, sizeof(tmp), "%i_%i_2", client, vehicle);	AddMenuItem(menu, tmp, "Refuser la demande");
	AddMenuItem(menu, "vide", "-----------------", ITEMDRAW_DISABLED);
	Format(tmp, sizeof(tmp), "%i_%i_3", client, vehicle);	AddMenuItem(menu, tmp, "Ignorer ce joueur");
	
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, driver, MENU_TIME_DURATION);
}
public int AskToJoinCar_Menu(Handle p_hItemMenu, MenuAction p_oAction, int client, int p_iParam2) {
	if (p_oAction == MenuAction_Select) {
		char szMenuItem[32];
		
		if (GetMenuItem(p_hItemMenu, p_iParam2, szMenuItem, sizeof(szMenuItem))) {
			
			char data[3][32];
			ExplodeString(szMenuItem, "_", data, sizeof(data), sizeof(data[]));
			
			int request = StringToInt(data[0]);
			int vehicle = StringToInt(data[1]);
			int type = StringToInt(data[2]);
			
			if( type == 1 ) {
				if( rp_GetVehicleInt(vehicle, car_maxPassager) <= CountPassagerInVehicle(vehicle) ) {
					CPrintToChat(client, "" ...MOD_TAG... " Il n'y a plus de place dans cette voiture.");
					CPrintToChat(request, "" ...MOD_TAG... " Il n'y a plus de place dans cette voiture.");
					
					return;
				}
				if( !IsPlayerAlive(request) ) {
					CPrintToChat(request, "" ...MOD_TAG... " Vous êtes mort.");
					return;
				}
				if( Vehicle_GetDriver(vehicle) != client  ) {
					CPrintToChat(request, "" ...MOD_TAG... " Le conducteur n'est plus dans sa voiture.");
					return;
				}
				
				if( Entity_GetDistance(request, vehicle) >= (CONTACT_DIST) ) {
					CPrintToChat(request, "" ...MOD_TAG... " La voiture est trop éloignée.");
					return;
				}
				
				if( rp_SetClientVehiclePassager(request, vehicle) )
					ClientCommand(request, "thirdperson");
			}
			else if( type == 2 ) {
				CPrintToChat(request, "" ...MOD_TAG... " Le conducteur a refusé votre demande.");
				return;
			}
			else if( type == 3 ) {
				g_iBlockedTime[client][request] = GetTime();
				CPrintToChat(request, "" ...MOD_TAG... " Le conducteur a refusé, et vous ignorera.");
				CPrintToChat(client, "" ...MOD_TAG... " Vous ignorez les demandes de %N{default} pour 6 heures", request);
				return;
			}
		}
	}
	else if (p_oAction == MenuAction_End) {
		CloseHandle(p_hItemMenu);
	}
}
int CountPassagerInVehicle(int vehicle) {
	int cpt = 0;
	
	for (int i = 1; i <= MaxClients; i++) {
		if( !IsValidClient(i) )
			continue;
		if ( rp_GetClientVehiclePassager(i) == vehicle )
			cpt++;
	}
	return cpt;
}
// ----------------------------------------------------------------------------
void DisplayGarageMenu(int client) {
	
	Handle menu = CreateMenu(eventGarageMenu);
	SetMenuTitle(menu, "Menu du garage\n ");
	
	AddMenuItem(menu, "to_bank", 	"Ranger la voiture");
	AddMenuItem(menu, "from_bank", 	"Sortir la voiture");
	AddMenuItem(menu, "colors", 	"Peindre la voiture");	
	AddMenuItem(menu, "particles", 	"Ajouter des particules");
	AddMenuItem(menu, "neons", 		"Ajouter un néon");
	AddMenuItem(menu, "klaxon", 		"Changer de klaxon");
	
	AddMenuItem(menu, "repair", 	"Réparer la voiture");
	AddMenuItem(menu, "battery", 	"Vendre la batterie");
	
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_DURATION);
}
void displayColorMenu(int client) {
	Handle menu2 = CreateMenu(eventGarageMenu);
	SetMenuTitle(menu2, "Menu du garage\n ");
	AddMenuItem(menu2, "colors_custom",		"Personnalisé");
			
	char tmp[64];
	for (int i = 0; i < sizeof(g_szColor); i++) {
		Format(tmp, sizeof(tmp), "color %s", g_szColor[i][0]);
		AddMenuItem(menu2, tmp, g_szColor[i][1]);
	}
	
	SetMenuExitButton(menu2, true);
	DisplayMenu(menu2, client, MENU_TIME_DURATION);
}
void displayColorMenu2(int client) {
	Handle menu2 = CreateMenu(eventGarageMenu);
	SetMenuTitle(menu2, "Menu du garage\n ");
	AddMenuItem(menu2, "white",	"Ajouter du blanc");
	AddMenuItem(menu2, "black",	"Ajouter du noir");
	AddMenuItem(menu2, "red", 	"Ajouter du rouge");
	AddMenuItem(menu2, "green", "Ajouter du vert");
	AddMenuItem(menu2, "bleue", "Ajouter du bleu");
	SetMenuExitButton(menu2, true);
	DisplayMenu(menu2, client, MENU_TIME_DURATION);
}
void displayNeonMenu(int client) {
	Handle menu2 = CreateMenu(eventGarageMenu);
	SetMenuTitle(menu2, "Menu du garage\n ");
				
	char tmp[64];
	for (int i = 0; i < sizeof(g_szColor); i++) {
		Format(tmp, sizeof(tmp), "neon %s", g_szColor[i][0]);
		AddMenuItem(menu2, tmp, g_szColor[i][1]);
	}
			
	SetMenuExitButton(menu2, true);
	DisplayMenu(menu2, client, MENU_TIME_DURATION);
}
void displayParticleMenu(int client) {
	Handle menu2 = CreateMenu(eventGarageMenu);
	char tmp[64];
	SetMenuTitle(menu2, "Menu du garage\n ");
				
	for (int i = 0; i < sizeof(g_szParticles); i++) {
		Format(tmp, sizeof(tmp), "Particule %d", i+1);
		AddMenuItem(menu2, tmp, g_szParticles[i][1]);
	}
	SetMenuExitButton(menu2, true);
	DisplayMenu(menu2, client, MENU_TIME_DURATION);
}
void displayKlaxonMenu(int client){
	char tmp[32];
	Menu menu = new Menu(eventGarageMenu);
	menu.SetTitle("Changer de klaxon\n ");
	for(int i=1; i<=6; i++){
		Format(tmp, sizeof(tmp), "Klaxon %d", i);
		menu.AddItem(tmp, tmp);
	}
	menu.Display(client, 60);
}
public int eventGarageMenu(Handle menu, MenuAction action, int client, int param) {
	static int last[65], offset;
	
	
	if( action == MenuAction_Select ) {
		char arg1[64];
		
		if( GetMenuItem(menu, param, arg1, sizeof(arg1)) ) {
			
			if( !IsInGarage(client) )
				return;
			
			int zone = rp_GetPlayerZone(client);
			
			if( StrEqual(arg1, "from_bank") ) {
					
				Handle menu2 = CreateMenu(eventGarageMenu2);
				SetMenuTitle(menu2, "Sélectionnez votre voiture\n ");
				
				char tmp[12], tmp2[64];
				
				for(int i = 0; i < MAX_ITEMS; i++) {
					if( rp_GetClientItem(client, i, true) <= 0 )
						continue;
						
					rp_GetItemData(i, item_type_extra_cmd, tmp2, sizeof(tmp2));
					
					if( StrContains(tmp2, "rp_item_vehicle") != 0 )
						continue;
					
					Format(tmp, sizeof(tmp), "%d", i);
					rp_GetItemData(i, item_type_name, tmp2, sizeof(tmp2));
					Format(tmp2, sizeof(tmp2), "%s (%i)",tmp2,rp_GetClientItem(client, i, true));
					AddMenuItem(menu2, tmp, tmp2);
				}
				SetMenuExitButton(menu2, true);
				DisplayMenu(menu2, client, MENU_TIME_DURATION);
				return;
			}
			else if( StrEqual(arg1, "colors") ) {
				displayColorMenu(client);
				return;
			}
			else if( StrEqual(arg1, "colors_custom") ) {
				displayColorMenu2(client);
				return;
			}
			else if( StrEqual(arg1, "neons") ) {
				displayNeonMenu(client);
				return;
			}
			else if( StrEqual(arg1, "particles") ) {
				displayParticleMenu(client);
				return;
			}
			else if( StrEqual(arg1, "klaxon") ){
				displayKlaxonMenu(client);
				return;
			}
			
			for (int target = MaxClients; target <= 2048; target++) {
				if( !rp_IsValidVehicle(target) )
					continue;
				if( rp_GetPlayerZone(target) != zone )
					continue;
				if( rp_GetVehicleInt(target, car_owner) != client)
					continue;
				
				if( StrEqual(arg1, "red") ||  StrEqual(arg1, "green") ||  StrEqual(arg1, "bleue") ||  StrEqual(arg1, "white") ||  StrEqual(arg1, "black") || StrContains(arg1, "color ") == 0 ) {

					int color[4];
					if( offset == 0 )
						offset = GetEntSendPropOffs(target, "m_clrRender", true);
					for(int i=0; i<3; i++)
						color[i] = GetEntData(target, offset+i, 1);
					color[3] = 255;
					
					if( color[0] >= 250 && color[1] >= 250 && color[2] >= 250 && last[client] != target ) {
						rp_IncrementSuccess(client, success_list_carshop);
					}
					
					last[client] = target;
					int j = 16;
					
					if( StrEqual(arg1, "red") ) {
						color[0] += j;	color[1] -= j;	color[2] -= j;
						displayColorMenu2(client);
					}
					else if( StrEqual(arg1, "green") ) {
						color[0] -= j;	color[1] += j;	color[2] -= j;
						displayColorMenu2(client);
					}
					else if( StrEqual(arg1, "bleue") ) {
						color[0] -= j;	color[1] -= j;	color[2] += j;
						displayColorMenu2(client);
					}
					else if( StrEqual(arg1, "white") ) {
						color[0] += j;	color[1] += j;	color[2] += j;
						displayColorMenu2(client);
					}
					else if( StrEqual(arg1, "black") ) {
						color[0] -= j;	color[1] -= j;	color[2] -= j;
						displayColorMenu2(client);
					}
					else {
						char data[4][8];
						ExplodeString(arg1, " ", data, sizeof(data), sizeof(data[]));
						color[0] = StringToInt(data[1]);
						color[1] = StringToInt(data[2]);
						color[2] = StringToInt(data[3]);
						displayColorMenu(client);
					}
					
					for(int i=0; i<3; i++) {
						if( color[i] > 255 )
							color[i] = 255;
						else if( color[i] < 0 )
							color[i] = 0;
					}
						
					ServerCommand("sm_effect_colorize %d %d %d %d 255", target, color[0], color[1], color[2]);
				}
				else if( StrContains(arg1, "neon ") == 0 ) {
					
					
					if( rp_GetVehicleInt(target, car_light_r) == -1 ) {
						if( rp_GetClientItem(client, ITEM_NEONS, true) <= 0 ) {
							CPrintToChat(client, "" ...MOD_TAG... " Vous n'avez pas de kit de néons en banque.");
							DisplayGarageMenu(client);
							return;
						}
						rp_ClientGiveItem(client, ITEM_NEONS, -1, true);
					}
					
					char data[4][8];
					ExplodeString(arg1, " ", data, sizeof(data), sizeof(data[]));
					
					rp_SetVehicleInt(target, car_light_r, StringToInt(data[1]));
					rp_SetVehicleInt(target, car_light_g, StringToInt(data[2]));
					rp_SetVehicleInt(target, car_light_b, StringToInt(data[3]));
					dettachVehicleLight(target);
					attachVehicleLight(target);
					displayNeonMenu(client);
				}
				else if( StrContains(arg1, "Particule ") == 0 ) {
					
					if( rp_GetVehicleInt(target, car_particle) == -1 ) {
						if( rp_GetClientItem(client, ITEM_PARTICULES, true) <= 0 ) {
							CPrintToChat(client, "" ...MOD_TAG... " Vous n'avez pas de kit de particules en banque.");
							DisplayGarageMenu(client);
							return;
						}
						rp_ClientGiveItem(client, ITEM_PARTICULES, -1, true);
					}
					
					char data[2][8];
					ExplodeString(arg1, " ", data, sizeof(data), sizeof(data[]));
					
					rp_SetVehicleInt(target, car_particle, StringToInt(data[1])-1);
					displayParticleMenu(client);
				}
				else if(StrContains(arg1, "Klaxon ") == 0 ) {
					char data[2][8];
					char tmp[255];
					ExplodeString(arg1, " ", data, sizeof(data), sizeof(data[]));
					int sound = StringToInt(data[1]);
					rp_SetVehicleInt(target, car_klaxon, sound);
					displayKlaxonMenu(client);
					Format(tmp, sizeof(tmp), "vehicles/v8/beep_%i.mp3", sound);
					EmitSoundToClientAny(client, tmp, target, 6, SNDLEVEL_CAR, SND_NOFLAGS, SNDVOL_NORMAL);
				}
				else if( StrEqual(arg1, "to_bank") ) {
					
					if( rp_GetVehicleInt(target, car_owner) != client )
						continue;
						
					if( rp_GetVehicleInt(target, car_health) < 1000 ) {
						CPrintToChat(client, "" ...MOD_TAG... " Votre véhicule est endommagé.");
						continue;
					}
					
					if( rp_GetVehicleInt(target, car_item_id) <= 0 ) {
						CPrintToChat(client, "" ...MOD_TAG... " Impossible de ranger ce véhicule.");
						continue;
					}
					
					if( rp_GetVehicleInt(target, car_donateur) == 1 && rp_GetVehicleInt(target, car_battery) == -1 ) {
						LogToGame("[CHEATING] %L a tenté de ranger sa voiture donateur, sans batterie.", client);
						CPrintToChat(client, "" ...MOD_TAG... " Votre mustang sportive n'a plus sa batterie.");
						continue;
					}		
					
					if( Vehicle_GetDriver(target) > 0 ) {
						CPrintToChat(client, "" ...MOD_TAG... " Il y a quelqu'un dans votre véhicule.");
						continue;
					}
					
					VehicleRemove(target, false);
					
					int itemID = rp_GetVehicleInt(target, car_item_id);
					rp_ClientGiveItem(client, itemID, 1, true);
					DisplayGarageMenu(client);
				}
				else if( StrEqual(arg1, "repair") ) {
					
					if( rp_GetClientItem(client, ITEM_REPAIR, true) <= 0 ) {
						CPrintToChat(client, "" ...MOD_TAG... " Vous n'avez pas de kit de carrosserie en banque.");
						DisplayGarageMenu(client);
						return;
					}
					rp_ClientGiveItem(client, ITEM_REPAIR, -1, true);
					
					int heal = rp_GetVehicleInt(target, car_health) + 1000;
					if( heal >= 2500 ) {
						heal = 2500;
					}
					
					rp_SetVehicleInt(target, car_health, heal);
					DisplayGarageMenu(client);
				}
				else if( StrEqual(arg1, "battery") ) {
					if( rp_GetVehicleInt(target, car_owner) != client )
						continue;

					if(rp_GetVehicleInt(target, car_battery) >= 420){
						int toPay = 1500;
						
						rp_ClientMoney(client, i_AddToPay, toPay);
						
						int capital_id = rp_GetRandomCapital( rp_GetClientJobID(client)  );
						rp_SetJobCapital( capital_id, rp_GetJobCapital(capital_id)-toPay );
						CPrintToChat(client, "" ...MOD_TAG... " Vous avez vendu votre batterie. Le virement des %d$ sera effectué en fin de journée.", toPay);
						rp_SetVehicleInt(target, car_battery, -1);
					}
					
					DisplayGarageMenu(client);
				}
			}
		}
	}
	else if( action == MenuAction_End ) {
		CloseHandle(menu);
	}
}
public int eventGarageMenu2(Handle menu, MenuAction action, int client, int param ) {
	if( action == MenuAction_Select ) {
		char szMenuItem[128];
		
		if( GetMenuItem(menu, param, szMenuItem, sizeof(szMenuItem)) ) {
			
			int itemID = StringToInt(szMenuItem);
			rp_GetItemData(itemID, item_type_extra_cmd, szMenuItem, sizeof(szMenuItem));
			
			
			if( rp_GetClientItem(client, itemID, true) > 0 ) {
				rp_ClientGiveItem(client, itemID, -1, true);
				ServerCommand("%s %d 1 %d", szMenuItem, client, itemID);
			}
		}
	}
	else if( action == MenuAction_End ) {
		CloseHandle(menu);
	}
}
public int SpawnVehicle(Handle menu, MenuAction action, int client, int param) {
	if( action == MenuAction_Select ) {
		char arg1[64];
		
		if( GetMenuItem(menu, param, arg1, sizeof(arg1)) ) {
			char model[128];
			int max = 0;
			
			int skinid = 1;
			
			if( StrEqual(arg1, "mustang") ) {
				Format(model, sizeof(model), "models/natalya/vehicles/natalya_mustang_csgo_2016.mdl");
				max = 3;
			}
			if( StrEqual(arg1, "victoria") ) {
				Format(model, sizeof(model), "models/natalya/vehicles/police_crown_victoria_csgo_v2.mdl");
				max = 3;
				skinid = 0;
			}
			else if( StrEqual(arg1, "moto") ) {
				Format(model, sizeof(model), "models/natalya/vehicles/dirtbike.mdl");
			}
			
			
			
			if( rp_GetZoneBit( rp_GetPlayerZone(client) ) & BITZONE_PEACEFULL ) {
				CPrintToChat(client, "" ...MOD_TAG... " Cet objet est interdit où vous êtes.");
				return;
			}
			
			if( countVehicle(client) >= GetConVarInt(g_hMAX_CAR) ) {
				CPrintToChat(client, "" ...MOD_TAG... " Il y a trop de voitures en circulation pour l'instant.");
				return;			
			}
			
			float vecOrigin[3], vecAngles[3];
			GetClientAbsOrigin(client, vecOrigin);
			vecOrigin[2] += 10.0;
			
			GetClientEyeAngles(client, vecAngles);
			vecAngles[0] = vecAngles[2] = 0.0;
			vecAngles[1] -= 90.0;
			
			int car = rp_CreateVehicle(vecOrigin, vecAngles, model, skinid, client);
			if( !car ) {
				CPrintToChat(client, "" ...MOD_TAG... " Il n'y a pas assez de place ici.");
				return;
			}
			
			rp_SetVehicleInt(car, car_owner, client);
			rp_SetVehicleInt(car, car_item_id, -1);
			rp_SetVehicleInt(car, car_maxPassager, max);
			rp_SetClientKeyVehicle(client, car, true);	
			CreateTimer(360.0, Timer_VehicleRemove, EntIndexToEntRef(car));
		}
	}
}
public Action Timer_VehicleRemove(Handle timer, any ent) {
	ent = EntRefToEntIndex(ent);
	if( ent <= 0 || !IsValidEdict(ent) )
		return Plugin_Handled;
	
	VehicleRemove(ent, true);
	return Plugin_Handled;
}

public void OnEntityDestroyed(int entity) {
	if(entity <= 0 || entity > sizeof(g_bEntityManaged)) {
		return;
	}
	
	if (g_bEntityManaged[entity]) {
		g_bEntityManaged[entity] = false;
		
		
		int root = GetEntPropEnt(entity, Prop_Data, "m_hEffectEntity");
		char tmp[64];
		for (int i = MaxClients; i <= 2048; i++) {
			if (!IsValidEdict(i) || !IsValidEntity(i))
				continue;
			
			
			
			if( EntRefToEntIndex(rp_GetVehicleInt(i, car_gyro_right)) == entity ) {
				rp_SetVehicleInt(i, car_gyro_right, 0);
			}
			if( EntRefToEntIndex(rp_GetVehicleInt(i, car_gyro_left)) == entity ) {
				rp_SetVehicleInt(i, car_gyro_left, 0);
			}
			
			GetEdictClassname(i, tmp, sizeof(tmp));
			if ( (StrEqual(tmp, "point_spotlight") || StrEqual(tmp, "beam") ||  StrEqual(tmp, "spotlight_end") ) && Entity_GetParent(i) == root) {
				int p = GetEntPropEnt(i, Prop_Data, "m_hEffectEntity");
				if (p > 0) {
					AcceptEntityInput(p, "KillHierarchy");
					int k = GetEntPropEnt(p, Prop_Data, "m_hEndEntity");
					if( k > 0 )
						AcceptEntityInput(k, "KillHierarchy");
				}
				AcceptEntityInput(i, "KillHierarchy");
			}
		}
		AcceptEntityInput(entity, "KillHierarchy");
	}
}
// ----------------------------------------------------------------------------
bool IsInGarage(int client) {
	int app = rp_GetPlayerZoneAppart(client);
	
	if( rp_GetZoneBit(rp_GetPlayerZone(client)) & BITZONE_PARKING && app > 0 && rp_GetClientKeyAppartement(client, app) ) {
		return true;
	}

	return false;
}
