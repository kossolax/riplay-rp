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
	name = "Jobs: Immo", author = "KoSSoLaX",
	description = "RolePlay - Jobs: Immobilier",
	version = __LAST_REV__, url = "https://www.ts-x.eu"
};

int g_cBeam, g_cGlow;

#define ITEM_PROP_APPART 77
#define ITEM_PROP_EXTRER 184
#define VILLA_PRICE		 50000
#define MENU_POS			view_as<float>({-8517.4, 829.8, -2303.9})


// -----
float g_flMinsMax[MAX_ZONES][3][3];
int g_iRayCount[MAX_ZONES][2];
int g_sCount[MAXPLAYERS][64], g_iHealth[MAXPLAYERS][64][64];
float g_vecOrigin[MAXPLAYERS][64][64][3], g_vecAngle[MAXPLAYERS][64][64][3];
char g_szModel[MAXPLAYERS][64][64][PLATFORM_MAX_PATH];
bool g_bDataLoaded[MAXPLAYERS];
bool g_bAppartCanBeSaved[64];
// -----

int g_iDirtyCount[200];
int g_iDirtType[200][16];
float g_flDirtPos[200][16][3];
int g_cDirt[5];
// -----

int g_iEntitycount = 0;
char g_PropsAppart[][128] = {
	"models/props_office/desk_01.mdl",
	"models/props_interiors/tv.mdl",
	"models/props_c17/furniturewashingmachine001a.mdl",
	"models/props_c17/FurnitureDresser001a.mdl",
	"models/props_interiors/chair_office2.mdl",
	"models/props_interiors/couch.mdl",
	"models/props_interiors/coffee_table_rectangular.mdl",
//	"models/props/cs_assault/box_stack1.mdl",
	"models/props/cs_militia/bar01.mdl",
	"models/props/de_house/bed_rustic.mdl",
	"models/props_interiors/tv_cabinet.mdl"
};
char g_PropsOutdoor[][128] = {
	"models/props/DeadlyDesire/blocks/32x32.mdl",
	"models/props_industrial/pallet_stack_96.mdl",
	"models/props_fortifications/concrete_block001_128_reference.mdl",
	"models/props/cs_office/vending_machine.mdl",
	"models/props_urban/boat002.mdl",
	"models/props_urban/outhouse002.mdl",
	"models/props_pipes/concrete_pipe001b.mdl",
	"models/props_interiors/table_picnic.mdl",
	"models/props_industrial/warehouse_shelf001.mdl",
	"models/props/cs_assault/box_stack1.mdl",
	"models/props/de_vertigo/construction_wood_2x4_01.mdl"
};
// ----------------------------------------------------------------------------
public Action Cmd_Reload(int args) {
	char name[64];
	GetPluginFilename(INVALID_HANDLE, name, sizeof(name));
	ServerCommand("sm plugins reload %s", name);
	return Plugin_Continue;
}
public void OnPluginStart() {
	LoadTranslations("core.phrases");
	LoadTranslations("common.phrases");
	LoadTranslations("roleplay.phrases");
	LoadTranslations("roleplay.items.phrases");
	LoadTranslations("roleplay.immo.phrases");
	
	RegServerCmd("rp_quest_reload", Cmd_Reload);
	RegServerCmd("rp_give_appart_door",		Cmd_ItemGiveAppart,				"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_appart_bonus",	Cmd_ItemGiveBonus,				"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_appart_keys",		Cmd_ItemGiveAppartDouble,		"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_appart_serrure",		Cmd_ItemAppartSerrure,		"RP-ITEM",	FCVAR_UNREGISTERED);
	
	RegServerCmd("rp_item_prop_appart",		Cmd_ItemPropAppart,			"RP-ITEM",  FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_prop_outdoor",	Cmd_ItemPropOutdoor,		"RP-ITEM",  FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_proptraps",	Cmd_ItemPropTrap,		"RP-ITEM",  FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_graves",		Cmd_ItemGrave,			"RP-ITEM", 	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_ticketvilla",		Cmd_eventBedConfirm,			"RP-ITEM", 	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_lampe", 		Cmd_ItemLampe,			"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_jumelle", 	Cmd_ItemLampe,			"RP-ITEM",	FCVAR_UNREGISTERED);
	
	RegAdminCmd("rp_force_appart", 		CmdForceAppart, 		ADMFLAG_ROOT);
	RegAdminCmd("rp_force_villa", 		CmdForceVilla, 			ADMFLAG_ROOT);
	
	for (int i = 1; i <= MaxClients; i++) 
		if( IsValidClient(i) )
			OnClientPostAdminCheck(i);
	
	for (int i = 0; i < 64; i++) {
		g_flMinsMax[i][0][0] = g_flMinsMax[i][0][1] = g_flMinsMax[i][0][2] =  99999.9;
		g_flMinsMax[i][1][0] = g_flMinsMax[i][1][1] = g_flMinsMax[i][1][2] = -99999.9;
	}
	CreateTimer(1.0, taskVillaProp);
	CreateTimer(60.0, taskVillaProp);
	CreateTimer(1.0, saveProps, 0, TIMER_REPEAT);
}
public Action saveProps(Handle timer, any none) {
	char tmp[128];
	
	g_iEntitycount = 0;
	for(int i=1; i<= 2048; i++) {
		if( !IsValidEdict(i) || !IsValidEntity(i) )
			continue;
		g_iEntitycount++;
	}
	
	for (int i = 0; i < MAX_ZONES; i++) {
		
		rp_GetZoneData(i, zone_type_type, tmp, sizeof(tmp));
		
		if( StrContains(tmp, "appart_") == 0) {
			ReplaceString(tmp, sizeof(tmp), "appart_", "");
			int appartID = StringToInt(tmp);
			
			if( appartID > 0 && appartID < 50 && g_bAppartCanBeSaved[appartID] ) {
				if( g_iRayCount[i][0] < 128 ) {
					calibrate(i);
				}
				else {
					if( rp_GetAppartementInt(appartID, appart_proprio) > 0 ) {
						saveAppart(i, appartID, GetRandomInt(0, 100) == 50 );
					}
				}
			}
		}
	}
	
	for (int i = 0; i < sizeof(g_iDirtyCount); i++) {
		if( GetRandomFloat() > 0.75 ) {
			for (int j = 0; j < g_iDirtyCount[i]; j++) {
				TE_SetupWorldDecal(g_flDirtPos[i][j], g_cDirt[ g_iDirtType[i][j] ]);
				TE_SendToAll();
			}
		}
	}
}
void calibrate(int zone) {
	float min[3], max[3], src[3];
	
	min[0] = rp_GetZoneFloat(zone, zone_type_min_x);
	min[1] = rp_GetZoneFloat(zone, zone_type_min_y);
	min[2] = rp_GetZoneFloat(zone, zone_type_min_z);
	
	max[0] = rp_GetZoneFloat(zone, zone_type_max_x);
	max[1] = rp_GetZoneFloat(zone, zone_type_max_y);
	max[2] = rp_GetZoneFloat(zone, zone_type_max_z);
	
	src[0] = GetRandomFloat(min[0] + 32.0, max[0] - 32.0);
	src[1] = GetRandomFloat(min[1] + 32.0, max[1] - 32.0);
	src[2] = GetRandomFloat(min[2] + 32.0, max[2] - 32.0);
	
	bool changed = false;
	changed = changed || calibrateRay(zone, src, min, max, view_as<float>({1.0, 0.0, 0.0}));
	changed = changed || calibrateRay(zone, src, min, max, view_as<float>({0.0, 1.0, 0.0}));
	changed = changed || calibrateRay(zone, src, min, max, view_as<float>({0.0, 0.0, 1.0}));
	
	g_iRayCount[zone][0]++;
	if( changed )
		g_iRayCount[zone][1]++;
}
bool calibrateRay(int zone, float src[3], float min[3], float max[3], float dir[3]) {
	Handle tr;
	int x = 0;
	int y = 1;
	int z = 2;
	bool changed = false;
	
	float dst[3];
	dst[x] = min[x] * dir[x] + src[x] * (1.0-dir[x]);
	dst[y] = min[y] * dir[y] + src[y] * (1.0-dir[y]);
	dst[z] = min[z] * dir[z] + src[z] * (1.0-dir[z]);
	
	tr = TR_TraceRayFilterEx(src, dst, MASK_SOLID_BRUSHONLY, RayType_EndPoint, FilterToNone);
	if( TR_DidHit(tr) && TR_GetFraction(tr) > 0.8 && TR_GetFraction(tr) < 1.0 && GetVectorDistance(src, dst) > 32.0 ) {
		TR_GetEndPosition(dst, tr);
		
		{
			if( dst[x] < g_flMinsMax[zone][0][x] && dst[x] >= min[x] && dir[x] > 0.0 ) {
				g_flMinsMax[zone][0][x] = dst[x];
				changed = true;
			}
			if( dst[y] < g_flMinsMax[zone][0][y] && dst[y] >= min[y] && dir[y] > 0.0 ) {
				g_flMinsMax[zone][0][y] = dst[y];
				changed = true;
			}
			if( dst[z] < g_flMinsMax[zone][0][z] && dst[z] >= min[z] && dir[z] > 0.0 ) {
				g_flMinsMax[zone][0][z] = dst[z];
				changed = true;
			}
		}
	}
	delete tr;
	
	dst[x] = max[x] * dir[x] + src[x] * (1.0-dir[x]);
	dst[y] = max[y] * dir[y] + src[y] * (1.0-dir[y]);
	dst[z] = max[z] * dir[z] + src[z] * (1.0-dir[z]);
	
	tr = TR_TraceRayFilterEx(src, dst, MASK_SOLID_BRUSHONLY, RayType_EndPoint, FilterToNone);
	if( TR_DidHit(tr) && TR_GetFraction(tr) > 0.8 && TR_GetFraction(tr) < 1.0 && GetVectorDistance(src, dst) > 32.0 ) {		
		TR_GetEndPosition(dst, tr);
				
		{
			if( dst[x] > g_flMinsMax[zone][1][x] && dst[x] <= max[x] && dir[x] > 0.0 ) {
				g_flMinsMax[zone][1][x] = dst[x];
				changed = true;
			}
			if( dst[y] > g_flMinsMax[zone][1][y] && dst[y] <= max[y] && dir[y] > 0.0 ) {
				g_flMinsMax[zone][1][y] = dst[y];
				changed = true;
			}
			if( dst[z] > g_flMinsMax[zone][1][z] && dst[z] <= max[z] && dir[z] > 0.0 ) {
				g_flMinsMax[zone][1][z] = dst[z];
				changed = true;
			}	
		}
	}
	delete tr;
	
	if( changed ) {
		g_flMinsMax[zone][2][0] = (g_flMinsMax[zone][0][0] + g_flMinsMax[zone][1][0]) / 2.0;
		g_flMinsMax[zone][2][1] = (g_flMinsMax[zone][0][1] + g_flMinsMax[zone][1][1]) / 2.0;
		g_flMinsMax[zone][2][2] = (g_flMinsMax[zone][0][2] + g_flMinsMax[zone][1][2]) / 2.0;
	}
	
	return changed;
}
void saveAppart(int zone, int appartID, bool sql = false) {
	if( g_bAppartCanBeSaved[appartID] == false )
		return;
	if( g_iRayCount[zone][0] < 128 )
		return;

	float src[3], ang[3], dir[3];
	int appartType = getAppartType(appartID);
	int client = rp_GetAppartementInt(appartID, appart_proprio);
	
	if( g_bDataLoaded[client] == false )
		return;
	
	g_sCount[client][appartType] = 0;
				
	getAppartRotation(appartID, ang);
	NegateVector(ang);
	
	static char save[PLATFORM_MAX_PATH * 2 * 32 + 1024], query[PLATFORM_MAX_PATH * 2 * 32 + 1024];
	char tmp[128];
	
	save[0] = 0;
	query[0] = 0;
	
	for (int i = MaxClients; i <= 2048; i++) {
		if( !IsValidEdict(i) || !IsValidEntity(i) )
			continue;
		if( rp_GetBuildingData(i, BD_owner) != client )
			continue;
		if( rp_GetBuildingData(i, BD_item_id) != ITEM_PROP_APPART )
			continue;
		GetEdictClassname(i, tmp, sizeof(tmp));
		if( !StrEqual(tmp, "rp_props") )
			continue;
		if( rp_GetPlayerZoneAppart(i) != appartID )
			continue;
		
		int id = g_sCount[client][appartType];
		Entity_GetAbsOrigin(i, src);
		SubtractVectors(src, g_flMinsMax[zone][2], src);
		Math_RotateVector(src, ang, g_vecOrigin[client][appartType][id]);

		Entity_GetAbsAngles(i, dir);
		AddVectors(dir, ang, g_vecAngle[client][appartType][id]);
		
		Entity_GetModel(i, g_szModel[client][appartType][id], sizeof(g_szModel[][]));
		
		g_iHealth[client][appartType][id] = Entity_GetHealth(i);
		
		g_sCount[client][appartType]++;
		
		if( sql ) {
			Format(save, sizeof(save), "%s%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%s,%d;", save,
				g_vecOrigin[client][appartType][id][0], g_vecOrigin[client][appartType][id][1], g_vecOrigin[client][appartType][id][2]+0.01,
				g_vecAngle[client][appartType][id][0], g_vecAngle[client][appartType][id][1], g_vecAngle[client][appartType][id][2],
				g_szModel[client][appartType][id], g_iHealth[client][appartType][id]
			);
		}
		
		if( g_sCount[client][appartType] >= 20 )
			break;
	}
	
	if( sql ) {
		char steamid[64];
		GetClientAuthId(client, AUTH_TYPE, steamid, sizeof(steamid));
		
		Format(query, sizeof(query), "INSERT INTO `rp_appart` (`steamid`, `appartid`, `props`) VALUES ('%s', '%d', '%s') ON DUPLICATE KEY UPDATE `props`='%s';",
			steamid, appartType, save, save);
		
		SQL_TQuery(rp_GetDatabase(), SQL_QueryCallBack, query, 0, DBPrio_Low);
	}
}
void loadAppart(int appartID) {
	if( g_iEntitycount > 1800 )
		return;
	
	int client = rp_GetAppartementInt(appartID, appart_proprio);
	if( g_bDataLoaded[client] == false )
		return;

	int zone = getAppartZone(appartID);
	if( g_iRayCount[zone][0] < 128 )
		return;
	
	float ang[3], src[3], dir[3];
	int appartType = getAppartType(appartID);
	
	g_bAppartCanBeSaved[appartID] = true; // do not remove.
	cleanAppart(appartID);
	g_bAppartCanBeSaved[appartID] = true; // do not remove, volontary twice.
	
	getAppartRotation(appartID, ang);
	
	for (int i = 0; i < g_sCount[client][appartType]; i++) {
		
		Math_RotateVector(g_vecOrigin[client][appartType][i], ang, src);
		AddVectors(src, g_flMinsMax[zone][2], src);
		
		AddVectors(g_vecAngle[client][appartType][i], ang, dir);					
		int ent = SpawnProp(client, src, dir, g_szModel[client][appartType][i]);
		
		Entity_SetHealth(ent, g_iHealth[client][appartType][i]);
	}
}
void cleanAppart(int appartID) {
	char tmp[128];
	
	for (int i = MaxClients; i <= 2048; i++) {
		if( !IsValidEdict(i) || !IsValidEntity(i) )
			continue;
		if( rp_GetBuildingData(i, BD_item_id) != ITEM_PROP_APPART )
			continue;
		GetEdictClassname(i, tmp, sizeof(tmp));
		if( !StrEqual(tmp, "rp_props") )
			continue;
		
		if( rp_GetPlayerZoneAppart(i) != appartID )
			continue;
				
		AcceptEntityInput(i, "Kill");
	}
	
	
	g_bAppartCanBeSaved[appartID] = false; // do not move upper "kill".
	
}
int getAppartType(int appartID) {
	if( appartID < 50 ) {
		int a = (appartID / 10) * 10;
		int c = appartID % 2;
		
		int base = a + c;
		
		if( base == 41 )
			base = 10;
		if( base == 30 )
			base = 11;
		
		return base;
	}
	return 0;
}
void getAppartRotation(int appartID, float ang[3]) {
	ang[0] = ang[1] = ang[2] = 0.0;

	if( appartID < 50 ) {
		int a = (appartID / 10) * 10;
		int c = appartID % 2;
		int base = a + c;
		
		if( base == 30 )
			ang[1] = 90.0;
	}
}
int getAppartZone(int appartID) {
	static char tmp[128];
	for (int i = 0; i < MAX_ZONES; i++) {
		rp_GetZoneData(i, zone_type_type, tmp, sizeof(tmp));
		
		if( StrContains(tmp, "appart_") == 0) {
			ReplaceString(tmp, sizeof(tmp), "appart_", "");
			if( appartID == StringToInt(tmp) )
				return i;
		}
	}
	return 0;
}
public bool FilterToNone(int entity, int mask, any data) {
	return false;
}

public Action OnPlayerRunCmd(int client) {
	int zone = rp_GetPlayerZone(client);
	
	if( g_iRayCount[zone][0] < 128 ) {
		int appartID = rp_GetPlayerZoneAppart(client);
		if( appartID > 0 && appartID < 50 ) {
			calibrate(zone);
		}
	}
}
public void OnEntityCreated(int entity, const char[] classname)  {
	if( g_iEntitycount > 1900 ) {
		int stack[64], count;
		
		for (int i = 1; i <= 50; i++) {
			if( g_bAppartCanBeSaved[i] == true && rp_GetAppartementInt(i, appart_proprio) > 0 )
				stack[count++] = i;
		}
		
		if( count > 0 ) {
			int rnd = GetRandomInt(0, count - 1);
			cleanAppart(stack[rnd]);
		}
	}
	
	if( entity > 0 && entity <= 2048 )
		g_iEntitycount++;
}
public void OnEntityDestroyed(int entity) {
	if( entity > 0 && entity <= 2048 )
		g_iEntitycount--;
	
	if( g_iEntitycount < 1800 ) {
		int stack[64], count;
		
		for (int i = 1; i <= 50; i++) {
			if( g_bAppartCanBeSaved[i] == false && rp_GetAppartementInt(i, appart_proprio) > 0 )
				stack[count++] = i;
		}
		
		if( count > 0 ) {
			int rnd = GetRandomInt(0, count - 1);
			loadAppart(stack[rnd]);
		}
	}
}
// ----------------------------------------------------------------------------
public Action taskVillaProp(Handle timer, any none) {
	for(int i=0; i<view_as<int>(appart_bonus_paye); i++) {
		rp_SetAppartementInt(50, view_as<type_appart_bonus>(i), 1);
		rp_SetAppartementInt(51, view_as<type_appart_bonus>(i), 1);
	}
	rp_SetAppartementInt(50, appart_bonus_paye, 200);
	rp_SetAppartementInt(51, appart_bonus_paye, 200);
}
public void OnMapStart() {
	g_cBeam = PrecacheModel("materials/sprites/laserbeam.vmt", true);
	g_cGlow = PrecacheModel("materials/sprites/glow01.vmt", true);
	PrecacheModel(MODEL_GRAVE, true);
	
	char tmp[128];
	
	for (int i = 0; i < sizeof(g_cDirt); i++) {
		Format(tmp, sizeof(tmp), "decals/trashdecal0%da.vmt", i);
		g_cDirt[i] = PrecacheDecal(tmp);
	}
}
public Action RP_OnPlayerGotPay(int client, int salary, int & topay, bool verbose) {
	int appart = rp_GetPlayerZoneAppart(client);
	
	if( appart > 0 && rp_GetClientKeyAppartement(client, appart) || appart > 0 &&  rp_GetClientJobID(client) == 61 ) {
		float multi = float(rp_GetAppartementInt(appart, appart_bonus_paye)) / 100.0;
		
		if( multi <= 1.5 && rp_GetClientJobID(client) == 61 && !rp_GetClientBool(client, b_GameModePassive) )
			multi = 1.5;
		
		if( HasImmo() && !rp_GetClientBool(client, b_IsAFK) ) {
			multi -= 1.5 * (float(g_iDirtyCount[appart]) / 10.0);
			if( multi < 0.0 )
				multi = 0.0;
		}
		
		int sum = RoundToCeil(float(salary) * multi);
		
		if( verbose && HasImmo() && !rp_GetClientBool(client, b_IsAFK) ) {
			if( g_iDirtyCount[appart] < 10 ) {
				Handle dp;
				CreateDataTimer(0.1, task_AddDirt, dp, TIMER_DATA_HNDL_CLOSE);
				WritePackCell(dp, client);
				WritePackCell(dp, appart);
			}
		}
		
		if( verbose && multi > 0 )
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Pay_Bonus_Appart", client, sum);
		
		topay += sum;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}
public Action task_AddDirt(Handle timer, Handle dp) {
	ResetPack(dp);
	int client = ReadPackCell(dp);
	int appart = ReadPackCell(dp);
	
	if( IsValidClient(client) && g_iDirtyCount[appart] < 10 ) {
		
		Entity_GetGroundOrigin(rp_GetClientEntity(client), g_flDirtPos[appart][g_iDirtyCount[appart]]);
		 
		g_iDirtType[appart][g_iDirtyCount[appart]] = GetRandomInt(1, sizeof(g_cDirt) - 1);
		g_iDirtyCount[appart]++;
	}
}
public void OnClientPostAdminCheck(int client) {
	rp_HookEvent(client, RP_OnPlayerCommand, fwdCommand);
	rp_HookEvent(client, RP_OnPlayerDataLoaded, fwdLoaded);
	rp_HookEvent(client, RP_OnPlayerBuild,	fwdOnPlayerBuild);
	rp_HookEvent(client, RP_OnPlayerUse, fwdOnPlayerUse);
	rp_HookEvent(client, RP_OnFrameSeconde, fwdOnFrame);
	
	
	g_bDataLoaded[client] = false;
	for (int i = 0; i < 64; i++) {
		g_sCount[client][i] = 0;
	}
	
	char query[1024], steamid[64];
	GetClientAuthId(client, AUTH_TYPE, steamid, sizeof(steamid));
	Format(query, sizeof(query), "SELECT `appartid`, `props` FROM `rp_appart` WHERE `steamid`='%s';", steamid);
	SQL_TQuery(rp_GetDatabase(), SQL_QueryProps, query, client, DBPrio_Low);
}
public Action fwdOnFrame(int client) {
	int appart = rp_GetPlayerZoneAppart(client);
	float src[3], dst[3];
	
	if( appart > 0 ) {
		fwdLoaded(client);
	}
	
	if( appart > 0 && (rp_GetClientKeyAppartement(client, appart)||rp_GetClientJobID(client)==61)  ) {
		for (int j = 0; j < g_iDirtyCount[appart]; j++) {
			dst = g_flDirtPos[appart][j];
			dst[2] += 8.0;
			
			TE_SetupBeamRingPoint(dst, 32.0, 33.0, g_cBeam, g_cGlow, 0, 0, 1.0, 8.0, 0.0, {200, 32, 32, 50}, 0, 0);
			TE_SendToClient(client);
			
			if( GetRandomInt(0, 10) ) {
				GetClientAbsOrigin(client, src);
				src[2] += 32.0;
				
				TE_SetupBeamPoints(src, dst, g_cBeam, g_cGlow, 0, 0, 1.0, 8.0, 8.0, 0, 0.0, { 200, 32, 32, 50 }, 0);
				TE_SendToClient(client);
			}
		}
	}
}
public void SQL_QueryProps(Handle owner, Handle hQuery, const char[] error, any client) {
	static char save[PLATFORM_MAX_PATH * 1 * 64 + 1024], data[64][PLATFORM_MAX_PATH + 256], row[8][PLATFORM_MAX_PATH];
	
	while( SQL_FetchRow(hQuery) ) {
		int appartType = SQL_FetchInt(hQuery, 0);
		
		SQL_FetchString(hQuery, 1, save, sizeof(save));
		int cpt = ExplodeString(save, ";", data, sizeof(data), sizeof(data[]));
		
		g_sCount[client][appartType] = 0;
		for (int i = 0; i < cpt; i++) {
			cpt = ExplodeString(data[i], ",", row, sizeof(row), sizeof(row[]));
			if( cpt < 5 || strlen(data[i]) < 5 ) // means there is no data
				break;
			
			int id = g_sCount[client][appartType];
			
			g_vecOrigin[client][appartType][id][0] = StringToFloat(row[0]);
			g_vecOrigin[client][appartType][id][1] = StringToFloat(row[1]);
			g_vecOrigin[client][appartType][id][2] = StringToFloat(row[2]);
			
			g_vecAngle[client][appartType][id][0] = StringToFloat(row[3]);
			g_vecAngle[client][appartType][id][1] = StringToFloat(row[4]);
			g_vecAngle[client][appartType][id][2] = StringToFloat(row[5]);
			
			Format(g_szModel[client][appartType][id], sizeof(g_szModel[][]), "%s", row[6]);
			
			g_iHealth[client][appartType][id] = StringToInt(row[7]);
			
			g_sCount[client][appartType]++;
		}
	}
	
	
	g_bDataLoaded[client] = true;
}
public void OnClientDisconnect(int client) {
	for (int i = 1; i <= 2048; i++) {
		if( IsValidEdict(i) && IsValidEntity(i) && rp_GetBuildingData(i, BD_Trapped) == client ) {
			rp_SetBuildingData(i, BD_Trapped, 0);
			SDKUnhook(i, SDKHook_OnTakeDamage, PropsDamage);
			SDKUnhook(i, SDKHook_Touch,	PropsTouched);
		}
	}
	
	for(int a=1; a<200; a++) {
		if( rp_GetAppartementInt(a, appart_proprio) != client )
			continue;
		
		if( a < 50 )
			cleanAppart(a);
		
		int stack[64], count;
		for(int i=1; i<=MaxClients; i++) {
			if( !IsValidClient(i) || i == client )
				continue;
			
			if( rp_GetClientKeyAppartement(i, a) ) {
				stack[count++] = i;
			}
		}
		
		if( count > 0 ) {
			rp_SetAppartementInt(a, appart_proprio, stack[GetRandomInt(0, count - 1)]);
			loadAppart(a);
		}
		else {
			rp_SetAppartementInt(a, appart_proprio, 0);
			g_iDirtyCount[a] = 0;
		}
	}
}
public Action fwdLoaded(int client) {
	
	if( rp_GetClientBool(client, b_HasVilla) ) {
		if( rp_GetClientKeyAppartement(client, 50) == false ) {
			rp_SetClientKeyAppartement(client, 50, true);
			rp_SetClientInt(client, i_AppartCount, rp_GetClientInt(client, i_AppartCount) + 1);
		}
	}
	else {
		if( rp_GetClientKeyAppartement(client, 50) == true ) {
			rp_SetClientKeyAppartement(client, 50, false);
			rp_SetClientInt(client, i_AppartCount, rp_GetClientInt(client, i_AppartCount) - 1);
		}
	}
	
	if( rp_GetClientGroupID(client) > 0 && rp_GetCaptureInt(cap_bunker) == rp_GetClientGroupID(client) ) {
		if( rp_GetClientKeyAppartement(client, 51) == false ) {
			rp_SetClientKeyAppartement(client, 51, true );
			rp_SetClientInt(client, i_AppartCount, rp_GetClientInt(client, i_AppartCount) + 1);
		}
	}
	else {
		if( rp_GetClientKeyAppartement(client, 51) == true ) {
			rp_SetClientKeyAppartement(client, 51, false);
			rp_SetClientInt(client, i_AppartCount, rp_GetClientInt(client, i_AppartCount) - 1);
		}
	}
	
}
public Action fwdOnPlayerUse(int client) {
	if( rp_GetClientJobID(client) == 61 ) {
		int appart = rp_GetPlayerZoneAppart(client);
		if( appart > 0 ) {
			float src[3];
			GetClientAbsOrigin(client, src);
			
			bool exist = false;
			for (int j = 0; j < g_iDirtyCount[appart]; j++) {
				if( GetVectorDistance(g_flDirtPos[appart][j], src) <= 128.0 )
					exist = true;
			}
			
			if( exist && rp_ClientEmote(client, "Emote_Snap") ) {
				rp_HookEvent(client, RP_OnPlayerEmote, OnEmote);
				return Plugin_Handled;
			}
		}
	}
	
	if( rp_GetPlayerZone(client) == 316 ) { // mairie
		float pos[3];
		char tmp[512];
		GetClientAbsOrigin(client, pos);
		
		if( GetVectorDistance(pos, MENU_POS) < 128.0 ) {
			
			Handle menu = CreateMenu(eventBedConfirm);
			
			char text[512] = "Bonjour à vous citoyens, vous pouvez acheter un ticket ici même pour le tirage au sort afin de remporter une semaine dans une magnifique villa tout confort ! Le ticket est à 50 000$ et il y aura 4 personnes qui seront tirés au sort ! Bonne chance à vous !";
			Format(tmp, sizeof(tmp), "%s", text); // TODO déplacer ça en trad
			
			String_WordWrap(tmp, 50); SetMenuTitle(menu, tmp);
			
			Format(tmp, sizeof(tmp), "Oui, payer %d$!", VILLA_PRICE);
			AddMenuItem(menu, "yes", tmp);
			AddMenuItem(menu, "no", "Non");
			
			DisplayMenu(menu, client, MENU_TIME_DURATION);
		}
	}
	
	return Plugin_Continue;
}
public int eventBedConfirm(Handle menu, MenuAction action, int client, int param2) {
	
	if( action == MenuAction_Select ) {
		char options[64];
		GetMenuItem(menu, param2, options, sizeof(options));
		
		if( StrEqual(options, "yes") ) {
			if( rp_GetClientInt(client, i_Bank) >= VILLA_PRICE ) {
				char szSteamID[32], query[1024];
				GetClientAuthId(client, AUTH_TYPE, szSteamID, sizeof(szSteamID), false);
				Format(query, sizeof(query), "SELECT COUNT(*) FROM `rp_villa` WHERE `steamid`='%s';", szSteamID);
				SQL_TQuery(rp_GetDatabase(), SQL_GetVillaCount, query, client, DBPrio_Low);
				rp_ClientMoney(client, i_Bank, -VILLA_PRICE);
			}
			else {
				CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_NotEnoughtMoney", client);
			}
		}
	}
	else if( action == MenuAction_End ) {
		CloseHandle(menu);
	}
}

/*public Action Cmd_eventBedConfirm(int client) {

	char szSteamID[32], query[1024];
	GetClientAuthId(client, AUTH_TYPE, szSteamID, sizeof(szSteamID), false);
	Format(query, sizeof(query), "SELECT COUNT(*) FROM `rp_villa` WHERE `steamid`='%s';", szSteamID);
	SQL_TQuery(rp_GetDatabase(), SQL_GetVillaCount, query, client, DBPrio_Low);
	/*rp_ClientMoney(client, i_Bank, -VILLA_PRICE);*/

}*/

public void SQL_GetVillaCount(Handle owner, Handle hQuery, const char[] error, any client) {
	
	if( SQL_FetchRow(hQuery) ) {
		int cpt = SQL_FetchInt(hQuery, 0);
		
		if( cpt == 0 ) {
			char query[1024], szSteamID[32];
			GetClientAuthId(client, AUTH_TYPE, szSteamID, sizeof(szSteamID), false);
			
			Format(query, sizeof(query), "INSERT INTO `rp_villa` (`id`, `steamid`) VALUES (NULL, '%s');", szSteamID);
			SQL_TQuery(rp_GetDatabase(), SQL_QueryCallBack, query, 0, DBPrio_High);
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Lotery_OnlyOne_Validated", client);
		}
		else {
			rp_ClientMoney(client, i_Bank, VILLA_PRICE);
			/*CPrintToChat(client, "" ...MOD_TAG... " %T", "Lotery_OnlyOne_Refund", client);*/
			CPrintToChat(client, "" ...MOD_TAG... " Votre ticket a déjà été validé, il vous a été remboursé.");
		}
	}		
}

public Action OnEmote(int client, const char[] emote, float time) {
	if( StrEqual(emote, "Emote_Snap") && time >= 0.0 ) {
		
		if( time >= 1.95 ) {
			int parent = Entity_GetParent(client);
			int appart = rp_GetPlayerZoneAppart(parent);
			
			if( appart > 0 ) {
				float src[3], dst[3];
				Entity_GetAbsOrigin(parent, src);
				int xp = 0;
				
				for (int j = 0; j < g_iDirtyCount[appart]; j++) {
					if( GetVectorDistance(g_flDirtPos[appart][j], src) <= 128.0 ) {
						
						
						TE_SetupWorldDecal(g_flDirtPos[appart][j], g_cDirt[ 0 ]);
						TE_SendToAll();
						
						for (float t = 0.0; t < 1.0; t+= 0.1) {
							dst = g_flDirtPos[appart][j];
							dst[0] += GetRandomFloat(-4.0, 4.0);
							dst[1] += GetRandomFloat(-4.0, 4.0);
							TE_SetupWorldDecal(dst, g_cDirt[ 0 ]);
							TE_SendToAll(t);
						}
						
						
						
						for (int k = j+1; k < g_iDirtyCount[appart]; k++) {
							g_flDirtPos[appart][j] = g_flDirtPos[appart][j + 1];
						}
						
						xp += 100;
						
						g_iDirtyCount[appart]--;
						j--;
					}
				}
				
				if( xp > 0 )
					rp_ClientXPIncrement(client, xp);
				
				if( g_iDirtyCount[appart] == 0 ) {
					ClientCommand(client, "r_cleardecals");
					for (int i = 1; i <= MaxClients; i++) {
						if( IsValidClient(i) && rp_GetClientKeyAppartement(i, appart) )
							ClientCommand(i, "r_cleardecals");
					}
				}
			}
		}
		
		rp_UnhookEvent(client, RP_OnPlayerEmote, OnEmote);
	}
}
public Action fwdOnPlayerBuild(int client, float& cooldown) {
	if( rp_GetClientJobID(client) != 61 )
		return Plugin_Continue;
	
	int ent = BuildingTomb(client);
	rp_SetBuildingData(ent, BD_FromBuild, 1);
	SetEntProp(ent, Prop_Data, "m_iHealth", GetEntProp(ent, Prop_Data, "m_iHealth")/5);
	Entity_SetMaxHealth(ent, Entity_GetHealth(ent));
	
	if( ent > 0 ) {
		rp_SetClientStat(client, i_TotalBuild, rp_GetClientStat(client, i_TotalBuild)+1);
		cooldown = 30.0;
	}
	else {
		cooldown = 3.0;
	}
	return Plugin_Stop;
}
// ----------------------------------------------------------------------------
public Action fwdCommand(int client, char[] command, char[] arg) {
	if( StrEqual(command, "infocoloc") ||  StrEqual(command, "infocolloc") ) {
		return Cmd_InfoColoc(client);
	}
	if( StrEqual(command, "villa") ) {
		return Cmd_BedVilla(client);
	}
	return Plugin_Continue;
}
public Action Cmd_ItemGiveAppart(int args) {
	
	int client = GetCmdArgInt(1);
	int appart = GetCmdArgInt(2);
	int vendeur = GetCmdArgInt(3);
	int item_id = GetCmdArgInt(args);
	
	if( rp_GetAppartementInt(appart, appart_proprio) > 0 ) {
		rp_CANCEL_AUTO_ITEM(client, vendeur, item_id);
		
		if( appart > 100 )
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Garage_AlreadySell", client);
		else
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Appart_AlreadySell", client);
		
		return Plugin_Continue;
	}

	rp_SetClientFloat(vendeur, fl_LastVente, GetGameTime() + 17.0);

	
	if( !rp_GetClientKeyAppartement(client, appart) ) {
		
		for (int i = 0; i < view_as<int>(appart_bonus_max); i++) {
			if( i != view_as<int>(appart_price) )
				rp_SetAppartementInt(appart, view_as<type_appart_bonus>(i), 0);
		}
		
		rp_SetClientInt(client, i_AppartCount, rp_GetClientInt(client, i_AppartCount) + 1);
		rp_SetClientKeyAppartement(client, appart, true);
		rp_SetAppartementInt(appart, appart_proprio, client);
		g_iDirtyCount[appart] = 0;
		
		if( appart > 100 )
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Garage_Buy", client, appart-100);
		else
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Appart_Buy", client, appart);
		
		
		if( appart > 0 && appart < 50 ) {
			loadAppart(appart);
		}
	}
	
	return Plugin_Continue;
}
public Action Cmd_ItemAppartSerrure(int args) {

	int client = GetCmdArgInt(1);
	int item_id = GetCmdArgInt(args);
	int appartID = rp_GetPlayerZoneAppart(client);
	Handle dp;
	CreateDataTimer(0.25 , Task_ItemAppartSerrure, dp, TIMER_DATA_HNDL_CLOSE);
	WritePackCell(dp, client);
	WritePackCell(dp, item_id);
	WritePackCell(dp, appartID);
	return Plugin_Handled;
}
public Action Task_ItemAppartSerrure(Handle timer, Handle dp) {
	ResetPack(dp);
	int client = ReadPackCell(dp);
	int item_id = ReadPackCell(dp);
	int appartID = ReadPackCell(dp);

	if( appartID == -1 ) {
		CPrintToChat(client, ""...MOD_TAG..." %T", "Error_OnlyInsideAppart", client);
		ITEM_CANCEL(client, item_id);
		return Plugin_Handled;
	}
	if( rp_GetAppartementInt(appartID, appart_proprio) != client ) {
		CPrintToChat(client, ""...MOD_TAG..." %T", "Appart_MustBeOwner", client);
		ITEM_CANCEL(client, item_id);
		return Plugin_Handled;
	}
	rp_ClientGiveItem(client, item_id); // On redonne l'item au gars au cas ou il ferme son menu
	Handle menu = CreateMenu(MenuSerrureVirer);
	SetMenuTitle(menu, "%T", "Appart_RemoveKey", client);
	
	char tmp[32], tmp2[128];
	for(int i=1; i<=MAXPLAYERS; i++){
		if( !IsValidClient(i) )
			continue;
		
		if(rp_GetClientKeyAppartement(i, appartID) && i!=client){
			Format(tmp, sizeof(tmp), "%i_%i_%i", item_id, appartID, i);
			GetClientName2(i, tmp2, sizeof(tmp2), true);
			AddMenuItem(menu,tmp,tmp2);
		}
	}
	DisplayMenu(menu, client, 60);
	return Plugin_Handled;
}
public int MenuSerrureVirer(Handle menu, MenuAction action, int client, int param2) {
	if( action == MenuAction_Select ) {
		char options[64], data[3][32];
		GetMenuItem(menu, param2, options, 63);
		ExplodeString(options, "_", data, sizeof(data), sizeof(data[]));
		int item_id = StringToInt(data[0]);
		int appartID = StringToInt(data[1]);
		int target = StringToInt(data[2]);
		
		char client_name[128], target_name[128];
		GetClientName2(client, client_name, sizeof(client_name), false);
		GetClientName2(target, target_name, sizeof(target_name), false);
		
		if(rp_GetClientItem(client, item_id)==0){
			char item_name[128];
			rp_GetItemData(item_id, item_type_name, item_name, sizeof(item_name));
			CPrintToChat(client, ""...MOD_TAG..." %T", "Error_ItemMissing", client, item_name);
			return;
		}
		else if(rp_GetClientKeyAppartement(target, appartID) == false ){
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Appart_TargetNoKey", client);
			rp_SetClientFloat(client, fl_CoolDown, 0.05); // On remet le cooldown du gars à 0 mais on lui redonne pas l'item vu qu'il l'a deja
		}
		else{
			rp_SetClientInt(target, i_AppartCount, rp_GetClientInt(target, i_AppartCount) - 1);
			rp_SetClientKeyAppartement(target, appartID, false);
			rp_ClientGiveItem(client, item_id, -1); // On prend l'item au gars comme il l'a utilisé
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Appart_KeyRemovedTo", client, appartID, target_name);
			CPrintToChat(target, "" ...MOD_TAG... " %T", "Appart_KeyRemovedBy", target, appartID, client_name);
		}
	}
	else if( action == MenuAction_End ) {
		CloseHandle(menu);
	}
}
public Action Cmd_ItemGiveAppartDouble(int args) {
	
	int client = GetCmdArgInt(1);
	int itemID = GetCmdArgInt(args);
	int target = GetClientAimTarget(client);
	
	if( !IsValidClient(target) ) {
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_CannotFindTarget", client);
		ITEM_CANCEL(client, itemID);
		return Plugin_Handled;
	}
	
	int appartID = rp_GetPlayerZoneAppart(client);
	if( appartID == -1 ) {
		CPrintToChat(client, ""...MOD_TAG..." %T", "Error_OnlyInsideAppart", client);
		ITEM_CANCEL(client, itemID);
		return Plugin_Handled;
	}
	if( rp_GetAppartementInt(appartID, appart_proprio) != client ) {
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Appart_MustBeOwner", client);
		ITEM_CANCEL(client, itemID);
		return Plugin_Handled;
	}
	
	if( rp_GetClientKeyAppartement(target, appartID ) ) {
		CPrintToChat(client, ""...MOD_TAG..." %T", "Appart_TargetAlreadyKey", client);
		ITEM_CANCEL(client, itemID);
		return Plugin_Handled;
	}
	
	int price = rp_GetAppartementInt(appartID, appart_price);
	int max = 0;
	switch( price ) {
		case 600: max = 3;
		case 900: max = 4;
		case 1200: max = 5;
		
		case 1000: max = 1;
		case 1500: max = 3;
	}
	
	int count = 0;
	for(int i=1; i<=MAXPLAYERS; i++){
		if( !IsValidClient(i) )
			continue;
		
		if( rp_GetClientKeyAppartement(i, appartID) && i!=client){
			count++;
		}
	}
	
	if( count >= max ) {
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Appart_KeyTooMany", client);
		ITEM_CANCEL(client, itemID);
		return Plugin_Handled;
	}
	
	rp_SetClientInt(target, i_AppartCount, rp_GetClientInt(target, i_AppartCount) + 1);
	rp_SetClientKeyAppartement(target, appartID, true);
	
	char client_name[128], target_name[128];
	GetClientName2(client, client_name, sizeof(client_name), false);
	GetClientName2(target, target_name, sizeof(target_name), false);
	CPrintToChat(client, "" ...MOD_TAG... " %T", "Appart_KeyGiveTo", client, appartID, target_name);
	CPrintToChat(target, "" ...MOD_TAG... " %T", "Appart_KeyGiveBy", target, appartID, client_name);
	
	return Plugin_Handled;
}
public Action Cmd_ItemGiveBonus(int args) {
	
	char arg1[32];
	GetCmdArg(1, arg1, sizeof(arg1));
	int client = GetCmdArgInt(2);
	int itemID = GetCmdArgInt(args);
	
	int appartID = rp_GetPlayerZoneAppart(client);
	if( appartID == -1 || appartID >= 150) {
		CPrintToChat(client, ""...MOD_TAG..." %T", "Error_OnlyInsideAppart", client);
		ITEM_CANCEL(client, itemID);
		return Plugin_Handled;
	}
	if( !rp_GetClientKeyAppartement(client, appartID) ) {
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Appart_MustBeOwner", client);
		ITEM_CANCEL(client, itemID);
		return Plugin_Handled;
	}
	
	int bonus, mnt = 1;
	// BO BO BONUS
	
	if( StrEqual(arg1, "heal") )
		bonus = appart_bonus_heal;
	else if( StrEqual(arg1, "armor") )
		bonus = appart_bonus_armor;
	else if( StrEqual(arg1, "energy") )
		bonus = appart_bonus_energy;
	else if( StrEqual(arg1, "garage") )
		bonus = appart_bonus_garage;
	else if( StrEqual(arg1, "vitality") )
		bonus = appart_bonus_vitality;
	else if( StrEqual(arg1, "coffre") )
		bonus = appart_bonus_coffre;
	else if( StrEqual(arg1, "bronze") ) {
		bonus = appart_bonus_paye;
		mnt = 50;
	}
	else if( StrEqual(arg1, "argent") ) {
		bonus = appart_bonus_paye;
		mnt = 75;
	}
	else if( StrEqual(arg1, "or") ) {
		bonus = appart_bonus_paye;
		mnt = 100;
	}
	else if( StrEqual(arg1, "platine") ) {
		bonus = appart_bonus_paye;
		mnt = 150;
	}
	else if( StrEqual(arg1, "all") ) {
		bool hasAll = true;
		
		for(int i=0; i<view_as<int>(appart_bonus_paye); i++) {
			if( rp_GetAppartementInt(appartID, view_as<type_appart_bonus>(bonus)) == 0 ) {
				hasAll = false;
			}
		}
		
		if( hasAll ) {
			ITEM_CANCEL(client, itemID);
			return Plugin_Handled;
		}
		
		for(int i=0; i<view_as<int>(appart_bonus_paye); i++) {
			rp_SetAppartementInt(appartID, view_as<type_appart_bonus>(i), 1);
		}
		rp_SetAppartementInt(appartID, appart_bonus_paye, 150);
		return Plugin_Handled;
	}
	else {
		ITEM_CANCEL(client, itemID);
		return Plugin_Handled;	
	}
		
	if( rp_GetAppartementInt(appartID, view_as<type_appart_bonus>(bonus)) >= mnt ) {
		ITEM_CANCEL(client, itemID);
		return Plugin_Handled;
	}
	rp_SetAppartementInt(appartID, view_as<type_appart_bonus>(bonus), mnt);
	
	return Plugin_Handled;	
}
// ----------------------------------------------------------------------------
public Action Cmd_ItemPropAppart(int args){
	int client = GetCmdArgInt(1);
	int item_id = GetCmdArgInt(args);
	rp_ClientGiveItem(client,item_id);

	int zone = rp_GetPlayerZone(client);
	int appart = rp_GetPlayerZoneAppart(client);
	if(appart == -1){
		if(rp_GetZoneInt(zone, zone_type_type) != rp_GetClientJobID(client)){
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_OnlyInside", client);
			return Plugin_Handled;
		}
	}
	CreateTimer(0.25, task_ItemPropAppart, client);
	return Plugin_Handled;
}
public Action task_ItemPropAppart(Handle timer, any client) {
	Handle menu = CreateMenu(MenuPropAppart);
	SetMenuTitle(menu, "%T\n ", "Prop_ToSpawn", client);
	
	char tmp[128];
	for(int i=0; i<sizeof(g_PropsAppart); i++){
		Format(tmp, sizeof(tmp), "%T", g_PropsAppart[i], client);
		AddMenuItem(menu, g_PropsAppart[i], tmp);
	}
	DisplayMenu(menu, client, 60);
	return Plugin_Handled;
}
int SpawnProp(int client, float pos[3], float ang[3], const char[] model) {
	int ent = CreateEntityByName("prop_physics_override"); 
	if( !IsModelPrecached(model) ) {
		PrecacheModel(model);
	}
	DispatchKeyValue(ent, "classname", "rp_props");
	DispatchKeyValue(ent, "physdamagescale", "0.0");
	DispatchKeyValue(ent, "model", model);
	DispatchSpawn(ent);
	SetEntityModel(ent, model);
	
	TeleportEntity(ent, pos, ang, NULL_VECTOR);
	
	rp_SetBuildingData(ent, BD_owner, client);
	rp_SetBuildingData(ent, BD_item_id, ITEM_PROP_APPART);
	SDKHook(ent, SDKHook_OnTakeDamage, OnPropDamage);
	
	SetEntityMoveType(ent, MOVETYPE_VPHYSICS); 
	
	float min[3], max[3];
	GetEntPropVector( ent, Prop_Send, "m_vecMins", min );
	GetEntPropVector( ent, Prop_Send, "m_vecMaxs", max );
	
	float volume = (max[0]-min[0]) * (max[1]-min[1]) * (max[2]-min[2]);
	int heal = RoundToCeil(volume/50.0)+10;
	
	SetEntProp( ent, Prop_Data, "m_takedamage", 2);
	SetEntProp( ent, Prop_Data, "m_iHealth", heal);	
	Entity_SetMaxHealth(ent, Entity_GetHealth(ent));
	
	rp_AcceptEntityInput(ent, "DisableMotion");
	rp_ScheduleEntityInput(ent, 0.6, "EnableMotion");
	
	return ent;
}
public int MenuPropAppart(Handle menu, MenuAction action, int client, int param2) {
	if( action == MenuAction_Select ) {
		char model[128];
		GetMenuItem(menu, param2, model, 127);

		int zone = rp_GetPlayerZone(client);
		int appart = rp_GetPlayerZoneAppart(client);
		if(appart == -1){
			if(rp_GetZoneInt(zone, zone_type_type) != rp_GetClientJobID(client)){
				CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_OnlyInside", client);
				return;
			}
		}
		if( appart < 50 && g_bAppartCanBeSaved[appart] == false ) {
			char item_name[128];
			rp_GetItemData(ITEM_PROP_APPART, item_type_name, item_name, sizeof(item_name));
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_ItemCannotBeUsedForNow", client, item_name);
			return;
		}
		
		float min[3], max[3], position[3], ang_eye[3];
		float distance = 50.0;
		
		int ent = SpawnProp(client, position, ang_eye, model);
		GetEntPropVector( ent, Prop_Send, "m_vecMins", min );
		GetEntPropVector( ent, Prop_Send, "m_vecMaxs", max );
		
		distance += SquareRoot( (max[0] - min[0]) * (max[0] - min[0]) + (max[1] - min[1]) * (max[1] - min[1]) ) * 0.5;
		
		GetClientFrontLocationData(client, position, ang_eye, distance );
		position[2] = position[2] - min[2] + 0.05;
		
		max[2] -= min[2];
		max[2] -= 1.0;
		min[2] = 0.0;
		
		Handle trace = TR_TraceHullFilterEx(position, position, min, max, MASK_SOLID_BRUSHONLY, FilterToOne, ent);
		if( TR_DidHit(trace) ) {
			float tmp[3];
			TR_GetEndPosition(tmp, trace);
			
			PrintToChat(28, "%f %f %f", min[0], min[1], min[2]);
			PrintToChat(28, "%f %f %f", max[0], max[1], max[2]);
			
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Build_CannotHere", client);
			rp_AcceptEntityInput(ent, "Kill");
			delete trace;
			return;
		}
		delete trace;
		
		TeleportEntity(ent, position, ang_eye, NULL_VECTOR);
		
		ServerCommand("sm_effect_fading %i 0.5", ent);
		rp_Effect_BeamBox(client, ent, NULL_VECTOR, 0, 64, 255);
		rp_ClientGiveItem(client,ITEM_PROP_APPART,-1);
	}
	else if( action == MenuAction_End ) {
		CloseHandle(menu);
	}
}
public Action Cmd_ItemPropOutdoor(int args){
	int client = GetCmdArgInt(1);
	int item_id = GetCmdArgInt(args);
	rp_ClientGiveItem(client,item_id);

	int zone = rp_GetPlayerZone(client);
	int zoneBIT = rp_GetZoneBit(zone);

	if( rp_GetZoneInt(zone, zone_type_type) == 1 || zoneBIT & BITZONE_PEACEFULL || zoneBIT & BITZONE_BLOCKBUILD ) {
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_CannotUseItemHere");
		return Plugin_Handled;
	}
	CreateTimer(0.25, task_ItemPropOutdoor, client);
	return Plugin_Handled;
}

public Action task_ItemPropOutdoor(Handle timer, any client){
	Handle menu = CreateMenu(MenuPropOutdoor);
	SetMenuTitle(menu, "%T\n ", "Prop_ToSpawn", client);
	
	char tmp[128];
	for(int i=0; i<sizeof(g_PropsOutdoor); i++) {
		Format(tmp, sizeof(tmp), "%T", g_PropsOutdoor[i], client);
		AddMenuItem(menu, g_PropsOutdoor[i], tmp);
	}
	DisplayMenu(menu, client, 60);
	return Plugin_Handled;
}
public int MenuPropOutdoor(Handle menu, MenuAction action, int client, int param2) {
	if( action == MenuAction_Select ) {
		char model[128];
		GetMenuItem(menu, param2, model, 127);

		int zone = rp_GetPlayerZone(client);
		int zoneBIT = rp_GetZoneBit(zone);

		int ent = CreateEntityByName("prop_physics_override"); 
		if( !IsModelPrecached(model) ) {
			PrecacheModel(model);
		}
		if( rp_GetZoneInt(zone, zone_type_type) == 1 || zoneBIT & BITZONE_PEACEFULL || zoneBIT & BITZONE_BLOCKBUILD ) {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_CannotUseItemHere");
			return;
		}
		DispatchKeyValue(ent, "classname", "rp_props");
		DispatchKeyValue(ent, "physdamagescale", "0.0");
		DispatchKeyValue(ent, "model", model);
		DispatchSpawn(ent);
		SetEntityModel(ent, model);
		
		float min[3], max[3], position[3], ang_eye[3], ang_ent[3], normal[3];
		float distance = 50.0;
		
		GetEntPropVector( ent, Prop_Send, "m_vecMins", min );
		GetEntPropVector( ent, Prop_Send, "m_vecMaxs", max );
		
		distance += SquareRoot( (max[0] - min[0]) * (max[0] - min[0]) + (max[1] - min[1]) * (max[1] - min[1]) ) * 0.5;
		
		GetClientFrontLocationData( client, position, ang_eye, distance );
		normal[0] = 0.0;
		normal[1] = 0.0;
		normal[2] = 1.0;
		
		NegateVector( normal );
		GetVectorAngles( normal, ang_ent );
		
		float volume = (max[0]-min[0]) * (max[1]-min[1]) * (max[2]-min[2]);
		int heal = RoundToCeil(volume/50.0)+10;
		position[2] += max[2];
		Handle trace = TR_TraceHullEx(position, position, min, max, MASK_SOLID);
		if( TR_DidHit(trace) ) {
			delete trace;
			
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Build_CannotHere", client);
			rp_AcceptEntityInput(ent, "Kill");
			return;
		}
		delete trace;
		
		SetEntProp( ent, Prop_Data, "m_takedamage", 2);
		SetEntProp( ent, Prop_Data, "m_iHealth", heal);	
		Entity_SetMaxHealth(ent, Entity_GetHealth(ent));
		
		SetEntityMoveType(ent, MOVETYPE_VPHYSICS); 
		TeleportEntity(ent, position, ang_ent, NULL_VECTOR);
		rp_AcceptEntityInput(ent, "DisableMotion");
		rp_ScheduleEntityInput(ent, 0.6, "EnableMotion");
		
		ServerCommand("sm_effect_fading %i 0.5", ent);
		
		rp_SetBuildingData(ent, BD_owner, client);
		rp_SetBuildingData(ent, BD_item_id, ITEM_PROP_EXTRER);
		rp_Effect_BeamBox(client, ent, NULL_VECTOR, 0, 64, 255);
		
		SDKHook(ent, SDKHook_OnTakeDamage, OnPropDamage);
		rp_ClientGiveItem(client,ITEM_PROP_EXTRER,-1);
	}
	else if( action == MenuAction_End ) {
		CloseHandle(menu);
	}
}
public Action OnPropDamage(int caller, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom) {
	
	int heal = Entity_GetHealth(caller);
	
	if( heal-RoundFloat(damage) <= 0 ) {
		int owner = rp_GetBuildingData(caller, BD_owner);
		rp_SetBuildingData(caller, BD_owner, 0);
		
		if( IsValidClient(attacker) && IsValidClient(owner) ) {
			rp_ClientAggroIncrement(attacker, owner, 1000);
	
			if( owner == attacker ) {
				rp_IncrementSuccess(owner, success_list_ikea_fail);
			}
		}
		
		Entity_SetHealth(caller, 1);
		SDKHooks_TakeDamage(caller, attacker, attacker, damage*10.0);
	}
	
	return Plugin_Continue;
}
// ----------------------------------------------------------------------------
bool canBeTrapped(int client, int entity) {
	char classname[128];
	GetEdictClassname(entity, classname, sizeof(classname));
	
	if( rp_IsValidDoor(entity) && rp_GetClientKeyDoor(client, rp_GetDoorID(entity)) ) {
		return true;
	}
	
	if( rp_GetBuildingData(entity, BD_owner) == client ) {
		return true;
	}
	
	
	return false;
}
public Action Cmd_ItemPropTrap(int args) {
	int client = GetCmdArgInt(1);
	int target = rp_GetClientTarget(client);
	
	int item_id = GetCmdArgInt(args);
	if( target == 0 || !IsValidEdict(target) || !IsValidEntity(target) || !canBeTrapped(client, target) ) {
		ITEM_CANCEL(client, item_id);
		return Plugin_Handled;
	}
	
	if( rp_GetBuildingData(target, BD_Trapped) != 0 ) {
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Prop_AlreadyTrap", client);
		ITEM_CANCEL(client, item_id);
		return Plugin_Handled;
	}
	
	float vecTarget[3];
	Entity_GetAbsOrigin(target, vecTarget);
	TE_SetupBeamRingPoint(vecTarget, 1.0, 150.0, g_cBeam, g_cGlow, 0, 15, 0.5, 50.0, 0.0, {50, 100, 255, 50}, 10, 0);
	TE_SendToAll();
	
	rp_SetBuildingData(target, BD_Trapped, client);
	SDKHook(target,	SDKHook_OnTakeDamage, PropsDamage);
	SDKHook(target, SDKHook_Touch,		PropsTouched);
	return Plugin_Handled;
}
public void PropsTouched(int touched, int toucher) {
	if( IsValidClient(toucher) && toucher != rp_GetBuildingData(touched, BD_owner) ) {
		rp_Effect_PropExplode(touched, toucher);
	}
}
public Action PropsDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype) {
	if( attacker == inflictor && IsValidClient(attacker) ) {
		int wep_id = GetEntPropEnt(attacker, Prop_Send, "m_hActiveWeapon");
		char sWeapon[32];
		
		GetEdictClassname(wep_id, sWeapon, sizeof(sWeapon));
		if( StrContains(sWeapon, "weapon_knife") == 0 || StrContains(sWeapon, "weapon_bayonet") == 0 || StrContains(sWeapon, "weapon_fists") == 0 || StrContains(sWeapon, "weapon_melee") == 0 ) {
			rp_Effect_PropExplode(victim, attacker);
		}
	}
}
// ----------------------------------------------------------------------------
public Action Cmd_ItemGrave(int args) {
	int client = GetCmdArgInt(1);
	
	if( BuildingTomb(client) == 0 ) {
		char arg_last[12];
		GetCmdArg(args, arg_last, 11);
		int item_id = StringToInt(arg_last);
		
		ITEM_CANCEL(client, item_id);
	}
	
	return Plugin_Handled;
}
int BuildingTomb(int client) {
	
	if( !rp_IsBuildingAllowed(client) )
		return 0;	
	
	char classname[64], tmp[64];
	Format(classname, sizeof(classname), "rp_grave");
	
	float vecOrigin[3], vecAngles[3];
	GetClientAbsOrigin(client, vecOrigin);
	GetClientEyeAngles(client, vecAngles);
	
	for(int i=1; i<=2048; i++) {
		if( !IsValidEdict(i) )
			continue;
		if( !IsValidEntity(i) )
			continue;
		
		GetEdictClassname(i, tmp, sizeof(tmp));
		
		if( StrEqual(classname, tmp) && rp_GetBuildingData(i, BD_owner) == client ) {
			CPrintToChat(client, ""...MOD_TAG..." %T", "Build_TooMany", client);
			return 0;
		}
	}
	
	EmitSoundToAllAny("player/ammo_pack_use.wav", client, _, _, _, 0.66);
	
	int ent = CreateEntityByName("prop_physics");
	
	DispatchKeyValue(ent, "classname", classname);
	DispatchKeyValue(ent, "model", MODEL_GRAVE);
	DispatchKeyValue(ent, "solid", "0");
	DispatchSpawn(ent);
	ActivateEntity(ent);
	
	SetEntityModel(ent, MODEL_GRAVE);
	
	SetEntProp( ent, Prop_Data, "m_iHealth", 500);
	SetEntProp( ent, Prop_Data, "m_takedamage", 0);
	
	SetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity", client);
	
	
	vecAngles[0] = vecAngles[2] = 0.0;
	TeleportEntity(ent, vecOrigin, vecAngles, NULL_VECTOR);
	
	ServerCommand("sm_effect_fading \"%i\" \"3.0\" \"0\"", ent);
	
	SetEntityMoveType(client, MOVETYPE_NONE);
	SetEntityMoveType(ent, MOVETYPE_NONE);
	
	CreateTimer(3.0, BuildingTomb_post, ent);
	rp_SetBuildingData(ent, BD_owner, client);
	
	rp_SetClientBool(client, b_HasGrave, true);
	rp_SetClientBool(client, b_SpawnToGrave, true);
	Entity_SetMaxHealth(ent, Entity_GetHealth(ent));
	
	return 1;
}
public Action BuildingTomb_post(Handle timer, any entity) {
	int client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	SetEntityMoveType(client, MOVETYPE_WALK);
	
	rp_Effect_BeamBox(client, entity, NULL_VECTOR, 0, 255, 100);
	SetEntProp(entity, Prop_Data, "m_takedamage", 2);
	SDKHook(entity, SDKHook_OnTakeDamage, DamageMachine);
	
	HookSingleEntityOutput(entity, "OnBreak", BuildingTomb_break);
	return Plugin_Handled;
}
public Action DamageMachine(int victim, int &attacker, int &inflictor, float &damage, int &damagetype) {
	if( !Entity_CanBeBreak(victim, attacker) ) {
		damage = 0.0;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}
public void BuildingTomb_break(const char[] output, int caller, int activator, float delay) {
	
	int owner = GetEntPropEnt(caller, Prop_Send, "m_hOwnerEntity");
	if( IsValidClient(owner) ) {
		char tmp[128];
		GetEdictClassname(caller, tmp, sizeof(tmp));
		CPrintToChat(owner, "" ...MOD_TAG... " %T", "Build_Destroyed", owner, tmp);
		rp_SetClientBool(owner, b_HasGrave, false);
	}
}
public Action Cmd_ItemLampe(int args) {
	char arg1[32];
	GetCmdArg(0, arg1, sizeof(arg1));
	
	int client = GetCmdArgInt(1);
	
	if( StrContains(arg1, "jumelle") != -1 ) {
		rp_SetClientBool(client, b_Jumelle, true);
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Item_Jumelle", client);
		rp_HookEvent(client, RP_OnAssurance,	fwdAssurance2);
	}
	else if( StrContains(arg1, "lampe") != -1 ) {
		rp_SetClientBool(client, b_LampePoche, true);
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Item_NightVision", client);
		rp_HookEvent(client, RP_OnAssurance,	fwdAssurance);
	}
	return Plugin_Handled;
}
public Action fwdAssurance(int client, int& amount) {
	amount += 250;
	return Plugin_Changed;
}
public Action fwdAssurance2(int client, int& amount) {
	amount += 300;
	return Plugin_Changed;
}
// ----------------------------------------------------------------------------
void GetClientFrontLocationData( int client, float position[3], float angles[3], float distance = 50.0 ) {
	
	float _origin[3], _angles[3], direction[3], target[3];
	GetClientAbsOrigin( client, _origin );
	GetClientEyeAngles( client, _angles );
	
	GetAngleVectors( _angles, direction, NULL_VECTOR, NULL_VECTOR );
	
	position[0] = _origin[0] + direction[0] * distance;
	position[1] = _origin[1] + direction[1] * distance;
	position[2] = _origin[2];
	
	angles[0] = 0.0;
	angles[1] = _angles[1];
	angles[2] = 0.0;
	
	target[0] = position[0];
	target[1] = position[1];
	target[2] = position[2] - 999999.9;
	
	Handle tr;
	tr = TR_TraceRayFilterEx(position, target, MASK_SOLID_BRUSHONLY, RayType_EndPoint, PVE_Filter, client);
	if (tr) {
		TR_GetEndPosition(target, tr);
		
		if( GetVectorDistance(position, target) < distance ) {
			position[2] = target[2];
		}
	}
	delete tr;
}

public Action Cmd_InfoColoc(int client){
	if(rp_GetClientInt(client, i_AppartCount) == 0){
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Appart_None", client);
		return Plugin_Handled;
	}
	char tmp[128];
	int proprio;
	Handle menu = CreateMenu(MenuNothing);
	SetMenuTitle(menu, "%T", "Appart_Info", client);
	for (int i = 1; i < 200; i++) {
		if( rp_GetClientKeyAppartement(client, i) ) {

			Format(tmp, sizeof(tmp),"--- %T ---", i < 100 ? "Appart_Number" : "Garage_Number", client, i);

			AddMenuItem(menu, tmp, tmp,	ITEMDRAW_DISABLED);
			
			tmp[0] = 0;
			
			if(rp_GetAppartementInt(i, appart_bonus_energy) == 1)
				Format(tmp, sizeof(tmp), "%s %T", tmp, "appart_bonus_energy", client);
			if(rp_GetAppartementInt(i, appart_bonus_heal) == 1)
				Format(tmp, sizeof(tmp), "%s %T", tmp, "appart_bonus_heal", client);
			if(rp_GetAppartementInt(i, appart_bonus_armor) == 1)
				Format(tmp, sizeof(tmp), "%s %T", tmp, "appart_bonus_armor", client);
			if(rp_GetAppartementInt(i, appart_bonus_garage) == 1)
				Format(tmp, sizeof(tmp), "%s %T", tmp, "appart_bonus_garage", client);
			if(rp_GetAppartementInt(i, appart_bonus_vitality) == 1)
				Format(tmp, sizeof(tmp), "%s %T", tmp, "appart_bonus_vitality", client);
			if(rp_GetAppartementInt(i, appart_bonus_coffre) == 1)
				Format(tmp, sizeof(tmp), "%s %T", tmp, "appart_bonus_coffre", client);
			if(rp_GetAppartementInt(i, appart_bonus_paye) >= 50)
				Format(tmp, sizeof(tmp), "%s %T", tmp, "appart_bonus_paye", client, rp_GetAppartementInt(i, appart_bonus_paye));
			
			Format(tmp, sizeof(tmp), "%T", "appart_bonus", client, tmp);
			AddMenuItem(menu, tmp, tmp,	ITEMDRAW_DISABLED);
			
			proprio = rp_GetAppartementInt(i, appart_proprio);
			if( IsValidClient(proprio) ) {
				GetClientName2(proprio, tmp, sizeof(tmp), true);
				Format(tmp, sizeof(tmp), "%T", "appart_owner", client, tmp);
				AddMenuItem(menu, tmp, tmp,	ITEMDRAW_DISABLED);
			}

			for(int j=1; j<=MAXPLAYERS; j++){
				if( !IsValidClient(j) )
					continue;
				if(rp_GetClientKeyAppartement(j, i) && j != proprio) {
					GetClientName2(j, tmp, sizeof(tmp), true);
					AddMenuItem(menu, tmp, tmp,	ITEMDRAW_DISABLED);
				}
			}
		}
	}
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, 60);
	return Plugin_Handled;
}

public int MenuNothing(Handle menu, MenuAction action, int client, int param2) {
	if( action == MenuAction_Select ) {
		if( menu != INVALID_HANDLE )
			CloseHandle(menu);
	}
	else if( action == MenuAction_End ) {
		if( menu != INVALID_HANDLE )
			CloseHandle(menu);
	}
}
// ----------------------------------------------------------------------------
public Action Cmd_BedVilla(int client){
	char tmp[128];
	
	if( rp_GetClientInt(client, i_PlayerLVL) < 42 ) {
		rp_GetLevelData(level_owner, rank_type_name, tmp, sizeof(tmp));
		CPrintToChat(client, "" ...MOD_TAG... "%T", "Error_Level", client, 42, tmp);
		return Plugin_Handled;
	}
	
	if( rp_GetClientBool(client, b_MaySteal) == false ) {
		ACCESS_DENIED(client);
	}
	rp_SetClientBool(client, b_MaySteal, false);
	
	char sql[256];
	GetClientAuthId(client, AUTH_TYPE, sql, sizeof(sql));
	
	Format(sql, sizeof(sql), "(SELECT `name`, `amount` FROM `rp_bid`B INNER JOIN`rp_users`U ON U.`steamid`=B.`steamid` ORDER BY `amount` DESC LIMIT 3) UNION (SELECT 'Vous', `amount` FROM `rp_bid` C WHERE `steamid` = '%s')", sql);
	SQL_TQuery(rp_GetDatabase(), SQL_BedVillaMenu, sql, client);
	
	
	return Plugin_Handled;
}
public void SQL_BedVillaMenu(Handle owner, Handle hQuery, const char[] error, any client) {
	
	Handle menu = CreateMenu(bedVillaMenu);
	SetMenuTitle(menu, "%T\n ", "Menu_Villa", client);
	
	char nick[128], steamid[64], steamid2[64];
	rp_GetServerString(villaOwnerID, steamid, sizeof(steamid));
	GetClientAuthId(client, AUTH_TYPE, steamid2, sizeof(steamid2));
	
	int max = 0, last = 0;
	
	while( SQL_FetchRow(hQuery) ) {
		last = SQL_FetchInt(hQuery, 1);
		if( last > max )
			max = last;
		
		SQL_FetchString(hQuery, 0, nick, sizeof(nick));
		Format(nick, sizeof(nick), "%s: %d$", nick, last);
		
		AddMenuItem(menu, nick, nick, ITEMDRAW_DISABLED);
	}
	
	char szDayOfWeek[12], szHours[12], tmp[128];
	
	FormatTime(szDayOfWeek, 11, "%w");
	FormatTime(szHours, 11, "%H");
	
	if( StringToInt(szDayOfWeek) == 5 && StringToInt(szHours) < 21 && rp_GetClientBool(client, b_HasVilla) == false ) {	// Vendredi avant 21h
		Format(tmp, sizeof(tmp), "%T", "Menu_Villa_Bed", client);
		AddMenuItem(menu, "miser", tmp);
	}
	
	if( StrEqual(steamid, steamid2) ) {
		Format(tmp, sizeof(tmp), "%T", "Menu_Villa_Key", client);
		AddMenuItem(menu, "key", tmp);
	}
	
	DisplayMenu(menu, client, 60);
	
	rp_SetClientBool(client, b_MaySteal, true);
}
public int bedVillaMenu(Handle p_hItemMenu, MenuAction p_oAction, int client, int p_iParam2) {

	if( p_oAction == MenuAction_Select) {
		char szMenuItem[32];
		if( GetMenuItem(p_hItemMenu, p_iParam2, szMenuItem, sizeof(szMenuItem)) ) {
			if( StrEqual(szMenuItem, "miser") ) {
				OpenBedMenu(client);
			}
			else if( StrEqual(szMenuItem, "key") ) {
				
				if( rp_GetClientBool(client, b_MaySteal) == false ) {
					return;
				}
				rp_SetClientBool(client, b_MaySteal, false);
				SQL_TQuery(rp_GetDatabase(), SQL_BedVillaMenuKey, "SELECT `name` FROM `rp_users` WHERE `hasVilla`=1", client);
			}
		}
	}
	else if (p_oAction == MenuAction_End) {
		CloseHandle(p_hItemMenu);
	}
}
public void SQL_BedVillaMenuKey(Handle owner, Handle hQuery, const char[] error, any client) {
	char steamid[64], steamid2[64], tmp[128];
	rp_GetServerString(villaOwnerID, steamid, sizeof(steamid));
	GetClientAuthId(client, AUTH_TYPE, steamid2, sizeof(steamid2));
	if( !StrEqual(steamid, steamid2) )
		return;
	
	Handle menu = CreateMenu(bedVillaMenu_KEY);
	int i = 0;
	while( SQL_FetchRow(hQuery) ) {
		i++;
		SQL_FetchString(hQuery, 0, steamid, sizeof(steamid));
		AddMenuItem(menu, steamid, steamid, ITEMDRAW_DISABLED);
	}
	
	if( i < 4 ) {
		Format(tmp, sizeof(tmp), "%T", "Menu_Villa_Key", client);
		AddMenuItem(menu, "add", tmp);
	}
	DisplayMenu(menu, client, 60);
	
	rp_SetClientBool(client, b_MaySteal, true);
	
}
public int bedVillaMenu_KEY(Handle p_hItemMenu, MenuAction p_oAction, int client, int p_iParam2) {

	if( p_oAction == MenuAction_Select) {
		char szMenuItem[32], tmp[64], szQuery[1024];
		if( GetMenuItem(p_hItemMenu, p_iParam2, szMenuItem, sizeof(szMenuItem)) ) {
			if( StrEqual(szMenuItem, "add") ) {
				Handle menu2 = CreateMenu(bedVillaMenu_KEY);
				for (int i = 1; i <= MaxClients; i++) {
					if( !IsValidClient(i) || i == client )
						continue;
					if( rp_GetClientBool(i, b_HasVilla) )
						continue;
					
					GetClientName(i, tmp, sizeof(tmp));
					Format(szMenuItem, sizeof(szMenuItem), "%d", i);
					AddMenuItem(menu2, szMenuItem, tmp);
				}
				DisplayMenu(menu2, client, 60);
				return;
			}
			int target = StringToInt(szMenuItem);
			rp_SetClientBool(target, b_HasVilla, true);
			rp_SetClientKeyAppartement(target, 50, true);
			rp_SetClientInt(target, i_AppartCount, rp_GetClientInt(target, i_AppartCount) + 1);
			GetClientAuthId(target, AUTH_TYPE, szMenuItem, sizeof(szMenuItem));
			
			Format(szQuery, sizeof(szQuery), "UPDATE `rp_users` SET `hasVilla`='1' WHERE `steamid`='%s'", szMenuItem);
			SQL_TQuery(rp_GetDatabase(), SQL_QueryCallBack, szQuery, DBPrio_High);
		}
	}
	else if (p_oAction == MenuAction_End) {
		CloseHandle(p_hItemMenu);
	}
}
void OpenBedMenu(int client) {
	char tmp[128];
	Handle menu = CreateMenu(bedVillaMenu_BED);
	SetMenuTitle(menu, "%T", "Menu_Bed", client);
	
	
	AddMenuItem(menu, "1",		"1$");
	AddMenuItem(menu, "10",		"10$");
	AddMenuItem(menu, "100",	"100$");
	AddMenuItem(menu, "1000",	"1000$");
	AddMenuItem(menu, "10000",	"10 000$");
	AddMenuItem(menu, "100000",	"100 000$");
	
	AddMenuItem(menu, "_", " ", ITEMDRAW_SPACER);
	
	Format(tmp, sizeof(tmp), "%T", "Back", client);
	AddMenuItem(menu, "back",	tmp);
	
	SetMenuPagination(menu, MENU_NO_PAGINATION);
	DisplayMenu(menu, client, 60);
}
public int bedVillaMenu_BED(Handle p_hItemMenu, MenuAction p_oAction, int client, int p_iParam2) {

	if( p_oAction == MenuAction_Select) {
		char szMenuItem[32], szDayOfWeek[12], szHours[12], sql[256];
		
		if( GetMenuItem(p_hItemMenu, p_iParam2, szMenuItem, sizeof(szMenuItem)) ) {
			if( StrEqual(szMenuItem, "back") ) {
				Cmd_BedVilla(client);
				return;
			}
			int amount = StringToInt(szMenuItem);
			if( amount > (rp_GetClientInt(client, i_Money)+rp_GetClientInt(client, i_Bank)) ) {
				CPrintToChat(client, ""...MOD_TAG..." %T", "Error_NotEnoughtMoney", client);
				OpenBedMenu(client);
				return;
			}
	
			FormatTime(szDayOfWeek, 11, "%w");
			FormatTime(szHours, 11, "%H");
			
			if( StringToInt(szDayOfWeek) == 5 && StringToInt(szHours) < 21 ) {	// Vendredi avant 21h
			
				GetClientAuthId(client, AUTH_TYPE, sql, sizeof(sql));
				Format(sql, sizeof(sql), "INSERT INTO `rp_bid` (`steamid`, `amount`) VALUES ('%s', '%d') ON DUPLICATE KEY UPDATE `amount`=`amount`+%d;", sql, amount, amount);
				SQL_TQuery(rp_GetDatabase(), SQL_QueryCallBack, sql);
				rp_ClientMoney(client, i_Money, -amount);
			}
			
			OpenBedMenu(client);
		}
	}
	else if (p_oAction == MenuAction_End) {
		CloseHandle(p_hItemMenu);
	}
}
public Action CmdForceVilla(int client, int args) {
	SQL_TQuery(rp_GetDatabase(), SQL_GetVillaWiner, "SELECT U.`steamid`, U.`name` FROM `rp_villa` V INNER JOIN `rp_users` U ON U.`steamid`=V.`steamid` WHERE U.hasVilla=0 ORDER BY RAND() LIMIT 4;");
	
	return Plugin_Handled;
}
public void SQL_GetVillaWiner(Handle owner, Handle hQuery, const char[] error, any none) {
	CPrintToChatAll("{lightblue} =================================={default} ");
	char szSteamID[32], szName[64], szSteamID2[32], szQuery[1024];
	
	while( SQL_FetchRow(hQuery) ) {
		
		SQL_FetchString(hQuery, 0, szSteamID, sizeof(szSteamID));
		SQL_FetchString(hQuery, 1, szName, sizeof(szName));
		
		for( int i = 1; i <= MaxClients; i++) {
			if( !IsValidClient(i) )
				continue;
			
			GetClientAuthId(i, AUTH_TYPE, szSteamID2, sizeof(szSteamID2));
			
			if( StrEqual(szSteamID, szSteamID2) ) {
				rp_SetClientBool(i, b_HasVilla, true);
				rp_SetClientKeyAppartement(i, 50, true);
				rp_SetClientInt(i, i_AppartCount, rp_GetClientInt(i, i_AppartCount) + 1);
			}
		}
		
		int gain = 50000;
			
		CPrintToChatAll("" ...MOD_TAG... " %T", "Villa_Winner", LANG_SERVER, szName, gain);
		LogToGame("[TSX-RP] [VILLA] %s %s gagne la villa pour %d$", szName, szSteamID, gain);
		
		Format(szQuery, sizeof(szQuery), "UPDATE `rp_users` SET `hasVilla`='2' WHERE `steamid`='%s'", szSteamID);
		SQL_TQuery(rp_GetDatabase(), SQL_QueryCallBack, szQuery);
	}
	
	CPrintToChatAll("{lightblue} =================================={default} ");
	
	SQL_TQuery(rp_GetDatabase(), SQL_QueryCallBack, "TRUNCATE `rp_villa`");
}
public Action CmdForceAppart(int client, int args) {
	SQL_TQuery(rp_GetDatabase(), SQL_GetAppartWiner, "SELECT B.`steamid`, `name`, `amount` FROM `rp_bid` B INNER JOIN `rp_users` U ON B.`steamid`=U.`steamid` ORDER BY `amount` DESC;");
	
	return Plugin_Handled;
}

public void SQL_GetAppartWiner(Handle owner, Handle hQuery, const char[] error, any none) {
	int gain, place = 0;
	CPrintToChatAll("{lightblue} =================================={default} ");
	char szSteamID[32], szName[64], szQuery[1024], szSteamID2[32];
	
	while( SQL_FetchRow(hQuery) ) {
		
		SQL_FetchString(hQuery, 0, szSteamID, sizeof(szSteamID));
		gain = SQL_FetchInt(hQuery, 2);
		
		if( place == 0 ) {
			SQL_FetchString(hQuery, 1, szName, sizeof(szName));	
			
			CPrintToChatAll("" ...MOD_TAG... " %T", "Villa_Winner", LANG_SERVER, szName, gain);
			LogToGame("[TSX-RP] [VILLA] %s %s gagne la villa pour %d$", szName, szSteamID, gain);
			
			dispatchToJob(gain);
			
			rp_SetServerString(villaOwnerID,  	szSteamID, sizeof(szSteamID));
			rp_SetServerString(villaOwnerName,  szName, sizeof(szName));
			
			for( int i = 1; i <= MaxClients; i++) {
				if( !IsValidClient(i) )
					continue;

				rp_SetClientBool(i, b_HasVilla, false);
				rp_SetClientKeyAppartement(i, 50, false);
				
				GetClientAuthId(i, AUTH_TYPE, szSteamID2, sizeof(szSteamID2));
				
				if( StrEqual(szSteamID, szSteamID2) ) {
					rp_SetClientBool(i, b_HasVilla, true);
					rp_SetClientKeyAppartement(i, 50, true);
					rp_SetClientInt(i, i_AppartCount, rp_GetClientInt(i, i_AppartCount) + 1);
				}
			}
			
			Format(szQuery, sizeof(szQuery), "UPDATE `rp_users` SET `hasVilla`='0' WHERE `steamid`<>'%s'", szSteamID);
			SQL_TQuery(rp_GetDatabase(), SQL_QueryCallBack, szQuery);
			
			Format(szQuery, sizeof(szQuery), "UPDATE `rp_users` SET `hasVilla`='1' WHERE `steamid`='%s'", szSteamID);
			SQL_TQuery(rp_GetDatabase(), SQL_QueryCallBack, szQuery);
			
			Format(szQuery, sizeof(szQuery), "UPDATE `rp_servers` SET `villaOwner`='%s'", szSteamID);
			SQL_TQuery(rp_GetDatabase(), SQL_QueryCallBack, szQuery);
		}
		else {
			Format(szQuery, sizeof(szQuery), "INSERT INTO `rp_users2` (`steamid`,  `bank`) VALUES ('%s', %d);", szSteamID, gain);
			SQL_TQuery(rp_GetDatabase(), SQL_QueryCallBack, szQuery);
		}
		place++;
	}
	
	SQL_TQuery(rp_GetDatabase(), SQL_QueryCallBack, "TRUNCATE `rp_bid`");
}
void dispatchToJob(int gain) {
	int jobCount = 0;
	int capitalTotal = 0;
	

	for (int i = 1; i <= 221; i+=10) {
		if( rp_GetJobInt(i, job_type_isboss) == 1 ) {
			capitalTotal += rp_GetJobCapital(i);
			jobCount++;
		}
	}
	
	int fraction = capitalTotal / jobCount;
	jobCount = 0;
	
	for (int i = 1; i <= 221; i+=10) {
		if( rp_GetJobInt(i, job_type_isboss) == 1 && rp_GetJobCapital(i) <= fraction )
			jobCount++;
	}
	
	for (int i = 1; i <= 221; i+=10) {
		if( rp_GetJobInt(i, job_type_isboss) == 1 && rp_GetJobCapital(i) <= fraction )
			rp_SetJobCapital(i, rp_GetJobCapital(i) + (gain / jobCount));
	}
}
// ----------------------------------------------------------------------------
stock void TE_SetupWorldDecal(float origin[3], int index) {
	TE_Start("World Decal");
	TE_WriteVector("m_vecOrigin", origin);
	TE_WriteNum("m_nIndex", index);
}
stock int Entity_GetGroundOrigin(int entity, float pos[3]) {
	static float source[3], target[3];
	Entity_GetAbsOrigin(entity, source);
	target[0] = source[0];
	target[1] = source[1];
	target[2] = source[2] - 999999.9;
	
	Handle tr;
	tr = TR_TraceRayFilterEx(source, target, MASK_SOLID_BRUSHONLY, RayType_EndPoint, PVE_Filter);
	if (tr)
		TR_GetEndPosition(pos, tr);
	delete tr;
}
public bool PVE_Filter(int entity, int contentsMask, any data) {
	if( entity == 0 )
		return true;
	return true;
}

bool HasImmo() {	
	
	static float g_flLastCheck = 0.0;
	static bool g_bLastData = false;
	
	if( g_flLastCheck > GetGameTime() ) {
		return g_bLastData;
	}


	g_flLastCheck = GetGameTime() + 5.0;
	g_bLastData = false;
	
	for(int i=1;i<=MaxClients;i++) {
		if( !IsValidClient(i) )
			continue;
		if( rp_GetClientBool(i, b_IsAFK) ) 
			continue;
		if( rp_GetZoneBit(rp_GetPlayerZone(i)) & BITZONE_EVENT ) 
			continue;
		if( rp_GetZoneBit(rp_GetPlayerZone(i)) & BITZONE_JAIL ) 
			continue;
		
		if( rp_GetClientJobID(i) == 61 ) {
			g_bLastData = true;
			break;
		}
	}
	
	
	return g_bLastData;
}
