#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <colors_csgo>
#include <roleplay>
#include <rp_tools>
#include <phun>
#include <smlib>

#pragma newdecls required
#define BLOCK_CLASSNAME	"rp_block"

public Plugin myinfo =  {
	name = "Props manager",
	author = "KoSSoLaX`",
	description = "http://www.ts-x.eu/",
	version = "2.1",
	url = "Entity Manager"
}

bool processing = false;

enum block_data {
	data_size = 0,
	data_skin,
	data_color,
	data_type,
	data_scale,
	data_max
};

int g_iData[data_max][65];

char g_szSize[3][12] = {
	"32x32",
	"64x8",
	"64x16"
};
float g_fMins[3][3] = {
	{ -16.0, -16.0, -16.0 },
	{ -32.0, -32.0, -4.0 },
	{ -32.0, -32.0, -8.0 }
};
float g_fMaxs[3][3] = {
	{ 16.0, 16.0, 16.0 },
	{ 32.0, 32.0, 4.0 },
	{ 32.0, 32.0, 8.0 }
};
char g_szSkins[9][32] = {
	"Intérieur: Noir",
	"Bord: Noir",
	"Bord: Bleu",
	"Bord: Vert",
	"Bord: Orange",
	"Bord: Rouge",
	"Bord: Rose",
	"Intérieur: A pois",
	"Intérieur: Rayé",
	
	
};
char g_szColors[10][2][12] = {
	{	"Rouge",	"255 0 0"		},
	{	"Orange",	"255 128 0"		},
	{	"Jaune",	"255 255 0"		},
	
	{	"Azure",	"0 64 128"		},
	{	"Bleu",		"0 0 255"		},
	{	"Violet",	"128 0 255"		},
	
	{	"Vert",		"0 255 0"		},
	{	"Vert-Kaki","191 255 0"		},
	
	{	"Brun",		"185 122 87"	},
	
	
	{	"Blanc",	"255 255 255"	}
	
};

char g_szScale[9][12] = {
	"1.0", "2.0", "4.0", "0.5", "0.25", "8.0", "16.0", "32.0", "64.0"
};

enum block_type {
	BLOCK_NORMAL,
	BLOCK_TRANSPARENT,
	BLOCK_INVISIBLE,
	BLOCK_FLAME,
	BLOCK_BUNNY,
	BLOCK_BOOST,
	BLOCK_JUMP,
	BLOCK_FREEZE,
	BLOCK_MIRROR,
	BLOCK_STRIP,
	BLOCK_HEAL,
	BLOCK_KILL,
	BLOCK_LIGHT,
	BLOCK_TP,
	BLOCK_GRAVITY,
	BLOCK_BREAKABLE,
	BLOCK_COLORIZE,
	BLOCK_FAKE,
	BLOCK_REMOVER
}
char g_szType[block_type][32] = {
	"Normal",
	"Transparent",
	"Invisible",
	"Flame",
	"B-Hop",
	"Boost",
	"Jump",
	"Glue",
	"Mirroir",
	"Désarme",
	"Heal",
	"Kill",
	"Lumineux",
	"TP",
	"Gravite",
	"Cassable",
	"Colorisant",
	"Fake",
	"Trou noir"
};

int tpTypeExit = 0;

enum block_float_data {
	float_mins,
	float_maxs,
	float_int_color,
	float_int_scale,
	float_block_max
}
float g_flBlockData[ 2048 ][float_block_max][3];
int g_iTeleportTo[2048];
int g_iBlockType[2048];
float g_fPending_BOOST[65];
int g_iPending_BOOST[65];

float g_fPending_FREEZE[65];
float g_fPending_MIRROR[65];
float g_fPending_FALL[65];
float g_fPending_GRAVITY[65];

Handle g_cMaxHealth = INVALID_HANDLE;
Handle g_cMaxSnap = INVALID_HANDLE;

int MaxHealth = 100;
int MaxSnap = 16;
int LaserCache;
int HaloSprite;


// -----------------------------------------------------------------------------------------------
public void OnClientPutInServer(int client) {
	g_fPending_BOOST[client] = g_fPending_FREEZE[client] = g_fPending_MIRROR[client] = g_fPending_FALL[client] = g_fPending_GRAVITY[client] = -99999999.0;
}
public void OnPluginStart() {
	LoadTranslations("common.phrases");
	
	RegAdminCmd("db_location", 		Command_getLoc,			ADMFLAG_SLAY,	"Returns the actual location");
	RegAdminCmd("db_angles",		Command_getAng,			ADMFLAG_SLAY,	"Returns the actual angle");
	RegAdminCmd("db_info",			Command_getSkin,		ADMFLAG_SLAY,	"Returns everything you can know of an entity"); 
	RegAdminCmd("db_remove",		Command_remove,			ADMFLAG_SLAY,	"Removes an entity");
	RegAdminCmd("db_rotate", 		Command_rotate, 		ADMFLAG_SLAY,	"Rotate an Entity");
	RegAdminCmd("db_rename", 		Command_rename, 		ADMFLAG_SLAY,	"Rotate an Entity");
	RegAdminCmd("db_find", 			Command_fin, 			ADMFLAG_SLAY,	"Find an Entity");
	RegAdminCmd("db_fire", 			Command_fire, 			ADMFLAG_SLAY,	"Fire to an Entity");
	RegAdminCmd("db_fires", 		Command_fires, 			ADMFLAG_SLAY,	"Fire to an Entity");
	RegAdminCmd("db_teleport", 		Command_teleport, 		ADMFLAG_SLAY,	"Fire to an Entity");
	
	RegAdminCmd("db_create_physics",Command_create, 		ADMFLAG_SLAY,	"Creates an Entity");
	RegAdminCmd("db_create_dynamic",Command_create,		 	ADMFLAG_SLAY,	"Creates an Entity");
	RegAdminCmd("db_create_throw",	Command_create,			ADMFLAG_SLAY,	"Creates and Throw an entity");
	RegAdminCmd("db_create_ball",	Command_create,			ADMFLAG_ROOT,	"Creates and Throw an entity");
	
	RegAdminCmd("db_create", 		Cmd_CreateMenuc, 		ADMFLAG_SLAY, "Create an Entity");
	RegAdminCmd("db_dublicate",		Command_dublicate,		ADMFLAG_SLAY,	"Dublicates an Entity");

	RegAdminCmd("sm_blocks", 		CmdBlock, 				ADMFLAG_BAN, 	"SpawnBlock");
	RegAdminCmd("sm_block", 		CmdBlock, 				ADMFLAG_BAN, 	"SpawnBlock");
	
	RegAdminCmd("db_saveevent", 	Command_saveEvent,		ADMFLAG_SLAY,	"Saves an event");
	RegAdminCmd("db_loadevent", 	Command_loadEvent,		ADMFLAG_SLAY,	"Loads an event");
	RegAdminCmd("db_removeevent", 	Command_removeEvent,	ADMFLAG_SLAY,	"Deletes an event");
	
	RegAdminCmd("sm_goto", 			Command_GoTo,			ADMFLAG_SLAY,	"Teleport to player");
	RegAdminCmd("sm_bring", 		Command_Bring,			ADMFLAG_SLAY,	"Teleport a player to you");
	
	
	HookEvent("player_death", 		EventReset, 		EventHookMode_Pre);
	HookEvent("player_spawn", 		EventReset, 		EventHookMode_Post);

	g_cMaxSnap = CreateConVar("rp_block_snap", "16");
	g_cMaxHealth = CreateConVar("rp_props_maxhealth", "100", "Max cube health", _, true, 1.0, true, 50000.0);
	HookConVarChange(g_cMaxHealth, Cvar_MaxHealChange);
	HookConVarChange(g_cMaxSnap, Cvar_MaxSnapChange);
	
	
	for(int i=1; i<=MaxClients; i++) {
		if( !IsValidClient(i) )
			continue;
		OnClientPutInServer(i);
	}
}

public Action Command_GoTo(int client, int args) {
	if( args < 1 || args > 1) {
		if( client != 0 )
			ReplyToCommand(client, "Utilisation: sm_goto \"joueur\"");
		else
			PrintToServer("Utilisation: sm_goto \"joueur\"");
		
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
	
	for (int i = 0; i < target_count; i++) {
		int target = target_list[i];
		float vec[3];
		Entity_GetAbsOrigin(target, vec);
		rp_ClientTeleport(client, vec);
		
		ShowActivity(client, "s'est Téléporté sur %N.", target);
		LogToGame("[ADMIN] %L s'est téléporté sur %L.", client, target);
	}
	return Plugin_Handled;
}

public Action Command_Bring(int client, int args) {
	if( args < 1 || args > 1) {
		if( client != 0 )
			ReplyToCommand(client, "Utilisation: sm_bring \"joueur\"");
		else
			PrintToServer("Utilisation: sm_bring \"joueur\"");
		
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
		COMMAND_FILTER_CONNECTED|COMMAND_FILTER_ALIVE,
		target_name,
		sizeof(target_name),
		tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	float vec[3];
	Entity_GetAbsOrigin(client, vec);

	for (int i = 0; i < target_count; i++) {
		int target = target_list[i];
		rp_ClientTeleport(target, vec);
		
		ShowActivity(client, "a Téléporté %N.", target);
		LogToGame("[ADMIN] %L a téléporté %L.", client, target);
	}
	return Plugin_Handled;
}

public Action Command_teleport(int client, int args) {
	int target = GetCmdArgInt(1);
	if( target == 0 || !IsValidEdict(target) || !IsValidEntity(target) || IsValidClient(target) )
		return Plugin_Handled;
	
	float vec[3];
	vec[0] = GetCmdArgFloat(2);
	vec[1] = GetCmdArgFloat(3);
	vec[2] = GetCmdArgFloat(4);
	TeleportEntity(target, vec, NULL_VECTOR, NULL_VECTOR);
	
	return Plugin_Handled;
}
public Action Cmd_CreateMenuc(int client, int args) {
	static int table = -1;
	if( table == -1)
		table = FindStringTable("modelprecache");
	
	int length = GetStringTableMaxStrings(table);
	char data[PLATFORM_MAX_PATH];
	
	Handle menu = CreateMenu(h_Cmd_CreateMenu);
	SetMenuTitle(menu, "Spawn un prop");
	
	for (int i = 0; i < length; i++) {
		ReadStringTable(table, i, data, sizeof(data));
		if( String_EndsWith(data, ".mdl") ) {
			AddMenuItem(menu, data, data);
		}
	}
	
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

public int h_Cmd_CreateMenu(Handle menu, MenuAction action, int client, int param2) {
	if( action == MenuAction_Select ) {
		char data[PLATFORM_MAX_PATH];
		GetMenuItem(menu, param2, data, sizeof(data));
		if( String_EndsWith(data, ".mdl") )
			ClientCommand(client, "db_create_dynamic \"%s\"", data);
	}
	else if( action == MenuAction_End ) {
		CloseHandle(menu);
	}
}
public void OnMapStart() {
	
	AddFileToDownloadsTable("materials/DeadlyDesire/props/princeton/blocks/face_inner_blue.vmt");
	AddFileToDownloadsTable("materials/DeadlyDesire/props/princeton/blocks/face_inner_blue.vtf");
	AddFileToDownloadsTable("materials/DeadlyDesire/props/princeton/blocks/face_inner_green.vmt");
	AddFileToDownloadsTable("materials/DeadlyDesire/props/princeton/blocks/face_inner_green.vtf");
	AddFileToDownloadsTable("materials/DeadlyDesire/props/princeton/blocks/face_inner_orange.vmt");
	AddFileToDownloadsTable("materials/DeadlyDesire/props/princeton/blocks/face_inner_orange.vtf");
	AddFileToDownloadsTable("materials/DeadlyDesire/props/princeton/blocks/face_inner_red.vmt");
	AddFileToDownloadsTable("materials/DeadlyDesire/props/princeton/blocks/face_inner_red.vtf");
	AddFileToDownloadsTable("materials/DeadlyDesire/props/princeton/blocks/face_inner_rose.vmt");
	AddFileToDownloadsTable("materials/DeadlyDesire/props/princeton/blocks/face_inner_rose.vtf");
	AddFileToDownloadsTable("materials/DeadlyDesire/props/princeton/blocks/face_inner_black.vmt");
	AddFileToDownloadsTable("materials/DeadlyDesire/props/princeton/blocks/face_inner_black.vtf");
	AddFileToDownloadsTable("materials/DeadlyDesire/props/princeton/blocks/face_outter.vmt");
	AddFileToDownloadsTable("materials/DeadlyDesire/props/princeton/blocks/face_outter.vtf");
	AddFileToDownloadsTable("materials/DeadlyDesire/props/princeton/blocks/face_line.vmt");
	AddFileToDownloadsTable("materials/DeadlyDesire/props/princeton/blocks/face_line.vtf");
	AddFileToDownloadsTable("materials/DeadlyDesire/props/princeton/blocks/face_dotted.vmt");
	AddFileToDownloadsTable("materials/DeadlyDesire/props/princeton/blocks/face_dotted.vtf");
	
	
	AddFileToDownloadsTable("models/props/DeadlyDesire/blocks/32x32.dx90.vtx");
	DownloadAndPrecache("models/props/DeadlyDesire/blocks/32x32.mdl");
	AddFileToDownloadsTable("models/props/DeadlyDesire/blocks/32x32.phy");
	AddFileToDownloadsTable("models/props/DeadlyDesire/blocks/32x32.sw.vtx");
	AddFileToDownloadsTable("models/props/DeadlyDesire/blocks/32x32.vvd");
	
	AddFileToDownloadsTable("models/props/DeadlyDesire/blocks/64x8.dx90.vtx");
	DownloadAndPrecache("models/props/DeadlyDesire/blocks/64x8.mdl");
	AddFileToDownloadsTable("models/props/DeadlyDesire/blocks/64x8.phy");
	AddFileToDownloadsTable("models/props/DeadlyDesire/blocks/64x8.sw.vtx");
	AddFileToDownloadsTable("models/props/DeadlyDesire/blocks/64x8.vvd");
	
	AddFileToDownloadsTable("models/props/DeadlyDesire/blocks/64x16.dx90.vtx");
	DownloadAndPrecache("models/props/DeadlyDesire/blocks/64x16.mdl");
	AddFileToDownloadsTable("models/props/DeadlyDesire/blocks/64x16.phy");
	AddFileToDownloadsTable("models/props/DeadlyDesire/blocks/64x16.sw.vtx");
	AddFileToDownloadsTable("models/props/DeadlyDesire/blocks/64x16.vvd");
	
	AddFileToDownloadsTable("materials/phoenix_storms/indenttiles2.vmt");
	AddFileToDownloadsTable("materials/phoenix_storms/indenttiles2.vtf");
	AddFileToDownloadsTable("materials/phoenix_storms/indenttiles_1-2.vmt");
	AddFileToDownloadsTable("materials/phoenix_storms/indenttiles_1-2.vtf");
	AddFileToDownloadsTable("materials/phoenix_storms/indenttiles_bump.vtf");
	AddFileToDownloadsTable("materials/phoenix_storms/plastic.vmt");
	AddFileToDownloadsTable("materials/phoenix_storms/plastic.vtf");
	AddFileToDownloadsTable("materials/phoenix_storms/plastic_bump.vtf");
	
	AddFileToDownloadsTable("models/props_phx/construct/plastic/plastic_panel1x1.dx90.vtx");
	AddFileToDownloadsTable("models/props_phx/construct/plastic/plastic_panel1x1.mdl");
	AddFileToDownloadsTable("models/props_phx/construct/plastic/plastic_panel1x1.phy");
	AddFileToDownloadsTable("models/props_phx/construct/plastic/plastic_panel1x1.vvd");
	AddFileToDownloadsTable("models/props_phx/construct/plastic/plastic_panel1x2.dx90.vtx");
	AddFileToDownloadsTable("models/props_phx/construct/plastic/plastic_panel1x2.mdl");
	AddFileToDownloadsTable("models/props_phx/construct/plastic/plastic_panel1x2.phy");
	AddFileToDownloadsTable("models/props_phx/construct/plastic/plastic_panel1x2.vvd");
	AddFileToDownloadsTable("models/props_phx/construct/plastic/plastic_panel1x3.dx90.vtx");
	AddFileToDownloadsTable("models/props_phx/construct/plastic/plastic_panel1x3.mdl");
	AddFileToDownloadsTable("models/props_phx/construct/plastic/plastic_panel1x3.phy");
	AddFileToDownloadsTable("models/props_phx/construct/plastic/plastic_panel1x3.vvd");
	AddFileToDownloadsTable("models/props_phx/construct/plastic/plastic_panel1x4.dx90.vtx");
	AddFileToDownloadsTable("models/props_phx/construct/plastic/plastic_panel1x4.mdl");
	AddFileToDownloadsTable("models/props_phx/construct/plastic/plastic_panel1x4.phy");
	AddFileToDownloadsTable("models/props_phx/construct/plastic/plastic_panel1x4.vvd");
	AddFileToDownloadsTable("models/props_phx/construct/plastic/plastic_panel1x8.dx90.vtx");
	AddFileToDownloadsTable("models/props_phx/construct/plastic/plastic_panel1x8.mdl");
	AddFileToDownloadsTable("models/props_phx/construct/plastic/plastic_panel1x8.phy");
	AddFileToDownloadsTable("models/props_phx/construct/plastic/plastic_panel1x8.vvd");
	AddFileToDownloadsTable("models/props_phx/construct/plastic/plastic_panel2x2.dx90.vtx");
	AddFileToDownloadsTable("models/props_phx/construct/plastic/plastic_panel2x2.mdl");
	AddFileToDownloadsTable("models/props_phx/construct/plastic/plastic_panel2x2.phy");
	AddFileToDownloadsTable("models/props_phx/construct/plastic/plastic_panel2x2.vvd");
	AddFileToDownloadsTable("models/props_phx/construct/plastic/plastic_panel2x3.dx90.vtx");
	AddFileToDownloadsTable("models/props_phx/construct/plastic/plastic_panel2x3.mdl");
	AddFileToDownloadsTable("models/props_phx/construct/plastic/plastic_panel2x3.phy");
	AddFileToDownloadsTable("models/props_phx/construct/plastic/plastic_panel2x3.vvd");
	AddFileToDownloadsTable("models/props_phx/construct/plastic/plastic_panel2x4.dx90.vtx");
	AddFileToDownloadsTable("models/props_phx/construct/plastic/plastic_panel2x4.mdl");
	AddFileToDownloadsTable("models/props_phx/construct/plastic/plastic_panel2x4.phy");
	AddFileToDownloadsTable("models/props_phx/construct/plastic/plastic_panel2x4.vvd");
	AddFileToDownloadsTable("models/props_phx/construct/plastic/plastic_panel2x8.dx90.vtx");
	AddFileToDownloadsTable("models/props_phx/construct/plastic/plastic_panel2x8.mdl");
	AddFileToDownloadsTable("models/props_phx/construct/plastic/plastic_panel2x8.phy");
	AddFileToDownloadsTable("models/props_phx/construct/plastic/plastic_panel2x8.vvd");
	AddFileToDownloadsTable("models/props_phx/construct/plastic/plastic_panel3x3.dx90.vtx");
	AddFileToDownloadsTable("models/props_phx/construct/plastic/plastic_panel3x3.mdl");
	AddFileToDownloadsTable("models/props_phx/construct/plastic/plastic_panel3x3.phy");
	AddFileToDownloadsTable("models/props_phx/construct/plastic/plastic_panel3x3.vvd");
	AddFileToDownloadsTable("models/props_phx/construct/plastic/plastic_panel4x4.dx90.vtx");
	AddFileToDownloadsTable("models/props_phx/construct/plastic/plastic_panel4x4.mdl");
	AddFileToDownloadsTable("models/props_phx/construct/plastic/plastic_panel4x4.phy");
	AddFileToDownloadsTable("models/props_phx/construct/plastic/plastic_panel4x4.vvd");
	AddFileToDownloadsTable("models/props_phx/construct/plastic/plastic_panel4x8.dx90.vtx");
	AddFileToDownloadsTable("models/props_phx/construct/plastic/plastic_panel4x8.mdl");
	AddFileToDownloadsTable("models/props_phx/construct/plastic/plastic_panel4x8.phy");
	AddFileToDownloadsTable("models/props_phx/construct/plastic/plastic_panel4x8.vvd");
	AddFileToDownloadsTable("models/props_phx/construct/plastic/plastic_panel8x8.dx90.vtx");
	AddFileToDownloadsTable("models/props_phx/construct/plastic/plastic_panel8x8.mdl");
	AddFileToDownloadsTable("models/props_phx/construct/plastic/plastic_panel8x8.phy");
	AddFileToDownloadsTable("models/props_phx/construct/plastic/plastic_panel8x8.vvd");

	LaserCache = PrecacheModel("materials/sprites/laserbeam.vmt");
	HaloSprite = PrecacheModel("materials/sprites/halo01.vmt");
	
	PrecacheSound("weapons/hegrenade/explode5.wav", true);
}
// -----------------------------------------------------------------------------------------------
public void Cvar_MaxHealChange(Handle cvar, const char[] oldVal, const char[] newVal){
	MaxHealth = StringToInt(newVal);
}
public void Cvar_MaxSnapChange(Handle cvar, const char[] oldVal, const char[] newVal){
	MaxSnap = StringToInt(newVal);
}
public Action Command_getLoc(int Client,int args) {
	float ClientOrigin[3];
	GetClientAbsOrigin(Client, ClientOrigin); 
	ReplyToCommand(Client, "[Actual Location] %f %f %f",ClientOrigin[0],ClientOrigin[1],ClientOrigin[2]);         
	return Plugin_Handled;
}
public Action Command_getAng(int Client,int args) {
	float ClientAngles[3];
	
	int ent = GetCmdArgInt(1);
	if( ent == 0 )
		ent = Client;
		
	Entity_GetAbsAngles(ent, ClientAngles);
	PrintToChat(Client, "[Actual Angles] %f %f %f", ClientAngles[0], ClientAngles[1], ClientAngles[2]);         
	return Plugin_Handled;
}
public Action Command_getSkin(int Client,int args) {
	char modelname[128], name[128], i_targetname[128];
	int Ent = GetCmdArgInt(1);
	
	if( Ent <= 0 || (!IsValidEdict(Ent) && !IsValidEntity(Ent) )) {
		Ent = GetClientAimTarget(Client, false);
	}
	if( !IsValidEdict(Ent) && !IsValidEntity(Ent) ) {
		return Plugin_Handled;
	}
	
	GetEdictClassname(Ent, name, sizeof(name));
	GetEntPropString(Ent, Prop_Data, "m_ModelName", modelname, 128);
	GetEntPropString(Ent, Prop_Data, "m_iName", i_targetname, sizeof(i_targetname));
	int hammer = GetEntProp(Ent, Prop_Data, "m_iHammerID");
	
	PrintToChat(Client, "[SKIN] %s [CLASS] %s [ID] %d [PERM-ID] %d [HAMMER-ID] %d [NAME] %s",modelname, name, Ent, (Ent-MaxClients), hammer, i_targetname);         
	return Plugin_Handled;
}
public Action Command_remove(int client,int args ) {
	
	int index = -1;
	if ( args > 0 ) {
		char param[128];
		GetCmdArg( 1, param, sizeof(param) );
		index = StringToInt( param );
	}
	else {
		index = GetClientAimedLocationData( client, NULL_VECTOR, NULL_VECTOR, NULL_VECTOR );
		
		if( IsValidVehicle( index ) ) {
			ReplyToCommand(client, "Vous avez essaye de supprimer une voiture, la commande a ete bloquee avant de crasher le serveur :<");
			return Plugin_Handled;
		}
	}
	
	
	if( !IsValidEdict(index) || !IsValidEntity(index) )
		return Plugin_Handled;
	
	char ClassName[128];
	GetEdictClassname(index, ClassName, 127);
	
	if(StrEqual(ClassName, "func_door_rotating") || StrEqual(ClassName, "prop_door_rotating") || StrEqual(ClassName, "func_door"))
		return Plugin_Handled;
	if(StrEqual(ClassName, "info_player_terrorist") || StrEqual(ClassName, "info_player_counterterrorist") )
		return Plugin_Handled;
	
	if ( index > MaxClients ) {
		rp_AcceptEntityInput(index, "Kill");
	}
	else {
		return Plugin_Handled;
	}
	
	int Ent = index;
	char modelname[128], name[128], i_targetname[128];
	
	GetEdictClassname(Ent, name, sizeof(name));
	GetEntPropString(Ent, Prop_Data, "m_ModelName", modelname, 128);
	GetEntPropString(Ent, Prop_Data, "m_iName", i_targetname, sizeof(i_targetname));
	
	char szSteamID[64];
	GetClientAuthId(client, AUTH_TYPE, szSteamID, sizeof(szSteamID));
	
	LogToGame("[REMOVED] %L [SKIN] %s [CLASS] %s [ID] %d [PERM-ID] %d [NAME] %s", client, modelname, name, Ent, (Ent-MaxClients), i_targetname);
	return Plugin_Handled;
}
public Action Command_rotate(int client,int args) {
	
	int index = GetClientAimedLocationData( client, NULL_VECTOR, NULL_VECTOR, NULL_VECTOR );
	if ( index <= 0 ) {
		return Plugin_Handled;
	}
	
	char param[128];
	float angles[3];
	GetEntPropVector( index, Prop_Data, "m_angRotation", angles );
	
	float degree;
	
	if ( args > 0 ) {
		GetCmdArg( 1, param, sizeof(param) );
		degree = StringToFloat( param );
		angles[1] += degree;
	}	
	if( args > 1 ) {
		GetCmdArg( 2, param, sizeof(param) );
		degree = StringToFloat( param );
		angles[0] += degree;
	}
	if( args > 2 ) {
		GetCmdArg( 3, param, sizeof(param) );
		degree = StringToFloat( param );
		angles[2] += degree;
	}
	
	DispatchKeyValueVector( index, "Angles", angles );
	
	return Plugin_Handled;
}
public Action Command_rename(int client,int args) {
	char name[64];
	GetCmdArg(2, name, sizeof(name));
	
	Entity_SetTargetName(GetCmdArgInt(1), name);
	
	return Plugin_Handled;
}
public Action Command_fin(int client,int args) {
	char name[64], tmp[64];
	GetCmdArg(1, name, sizeof(name));
	
	for (int i = 1; i <= 2048; i++) {
		if( !IsValidEdict(i) )
			continue;
		if( !IsValidEntity(i) )
			continue;
		
		
		GetEdictClassname(i, tmp, sizeof(tmp));
		if( StrContains(tmp, name) >= 0 )
			ReplyToCommand(client, "%s %d", tmp, i);
	}
	return Plugin_Handled;
}
public Action Command_fire(int client,int args) {
	char arg[32], arg2[32];
	GetCmdArg(2, arg, sizeof(arg));
	GetCmdArg(3, arg2, sizeof(arg2));
	
	SetVariantString(arg2);
	rp_AcceptEntityInput(GetCmdArgInt(1), arg);
	ReplyToCommand(client, "%d %s %s", GetCmdArgInt(1), arg, arg2);
	
	return Plugin_Handled;
}
public Action Command_fires(int client,int args) {
	char arg[32], arg2[32], plop[64];
	GetCmdArg(1, arg, sizeof(arg));
	GetCmdArg(2, arg2, sizeof(arg2));
	
	for (int i = 1; i <= 2048;i++) {
		if( !IsValidEntity(i) )
			continue;
		
		GetEdictClassname(i, plop, sizeof(plop));
		if (StrContains(plop, arg, false) != -1 ) {
			rp_AcceptEntityInput(i, arg2);
		}
	}
	
	rp_AcceptEntityInput(GetCmdArgInt(1), arg);
	
	return Plugin_Handled;
}
bool PropInterdi(char modelname[256]) {
	if( StrContains(modelname, "katharsmodels/present/type-") >= 0 )
		return true;
	
	return false;
}
public Action Command_create(int client,int args) {
	
	char arg0[64];
	GetCmdArg(0, arg0, sizeof(arg0));
	
	bool isPhysics = true;
	bool isInFront = false;
	
	if( StrEqual(arg0, "db_create_dynamic") ) {
		isPhysics = false;
	}
	if( StrEqual(arg0, "db_create_throw") ) {
		isInFront = true;
		
		int flags = GetUserFlagBits(client);
		if( !(flags & ADMFLAG_ROOT) && !(rp_GetZoneBit(rp_GetPlayerZone(client)) & BITZONE_EVENT ) ) {
			return Plugin_Handled;
		}
	}
	if( StrEqual(arg0, "db_create_ball") ) {
		isInFront = true;
	}
	
	
	char modelname[256];
	GetCmdArg( 1, modelname, sizeof(modelname) );
	ReplaceString(modelname, sizeof(modelname), "\\", "/");
	
	if( strlen( modelname ) <= 4 || !String_EndsWith(modelname, ".mdl") || !String_StartsWith(modelname, "models/") || PropInterdi(modelname) ) {
		ReplyToCommand(client, "Je ne pense pas que %s soit un model, t'es sur de toi?", modelname);
		return Plugin_Handled;
	}
	
	int index = -1;
	if( StrEqual(arg0, "db_create_ball" ) ) {
		index = CreateEntityByName("prop_sphere");
	}
	else if ( isPhysics ) {
		index = CreateEntityByName("prop_physics_override");
	}
	else {
		index = CreateEntityByName("prop_dynamic_override");
	}
	if ( index == -1 ) {
		return Plugin_Handled;
	}
	
	if ( !IsModelPrecached( modelname ) ) {
		int table = FindStringTable("modelprecache");
		int length = GetStringTableMaxStrings(table) - (GetStringTableNumStrings(table) + 32);
		if( length <= 0 ) {
			ReplyToCommand(client, "ERREUR, Impossible de mettre le model en cache aujourd'hui: Risque de crash élevé :(");
			return Plugin_Handled;
		}
		if( !PrecacheModel( modelname ) ) {
			ReplyToCommand(client, "ERREUR, quelque chose s'est mal passé... immpossible de crée ce props");
			return Plugin_Handled;
		}
	}
	SetEntityModel( index, modelname );
	
	char query[1024], model2[sizeof(modelname) + 1];
	SQL_EscapeString(rp_GetDatabase(), modelname, model2, sizeof(model2));
	Format(query, sizeof(query), "INSERT INTO `rp_shared`.`rp_props` (`model`) VALUES ('%s') ON DUPLICATE KEY UPDATE `count`=`count`+1", model2);
	SQL_TQuery(rp_GetDatabase(), SQL_QueryCallBack, query);
	
	float min[3], max[3], position[3], ang_eye[3], ang_ent[3], normal[3];
	GetEntPropVector( index, Prop_Send, "m_vecMins", min );
	GetEntPropVector( index, Prop_Send, "m_vecMaxs", max );
	
	if ( isInFront ){
		float distance = 50.0;
		distance -= min[0];
		GetClientFrontLocationData( client, position, ang_eye, distance );
		normal[0] = 0.0;
		normal[1] = 0.0;
		normal[2] = 1.0;
	}
	else {
		if ( GetClientAimedLocationData( client, position, ang_eye, normal ) == -1 ) {
			RemoveEdict( index );
			return Plugin_Handled;
		}
	}
	
	//NegateVector( normal );
	GetVectorAngles( normal, ang_ent );
	ang_ent[0] += 90.0;
	
	// here we will rotate the entity to let it face or back to you
	float cross[3], vec_eye[3], vec_ent[3];
	GetAngleVectors( ang_eye, vec_eye, NULL_VECTOR, NULL_VECTOR );
	GetAngleVectors( ang_ent, vec_ent, NULL_VECTOR, NULL_VECTOR );
	GetVectorCrossProduct( vec_eye, normal, cross );
	float yaw = GetAngleBetweenVectors( vec_ent, cross, normal );
	RotateYaw( ang_ent, yaw - 90.0 );
	
	
	// avoid some model burying under ground/in wall
	// don't forget the normal was negated
	position[0] -= normal[0] * min[2];
	position[1] -= normal[1] * min[2];
	position[2] -= normal[2] * min[2];
	
	
	
	if ( !isPhysics ) {
		SetEntProp( index, Prop_Send, "m_nSolidType", 6 );
		SetEntProp( index, Prop_Send, "m_CollisionGroup", 5);
		SetEntityMoveType( index, MOVETYPE_VPHYSICS);
	}
	else {
		SetEntProp( index, Prop_Data, "m_spawnflags", 256 );
	}
	
	DispatchKeyValue(index, "physdamagescale", "0.0");
	DispatchKeyValue(index, "health", "200");
	DispatchKeyValue(index,"m_takedamage", "2");
	DispatchKeyValue(index, "DisableBoneFollowers", "1");
	
	DispatchKeyValueVector( index, "Origin", position );
	DispatchKeyValueVector( index, "Angles", ang_ent );
	
	DispatchSpawn( index );
	TargetBeamBox(client, index);
	
	
	
	if ( !isPhysics ) {
		// we need to make a prop_dynamic entity collide
		// don't know why but the following code work
		rp_AcceptEntityInput( index, "DisableCollision" );
		rp_AcceptEntityInput( index, "EnableCollision" );
		rp_AcceptEntityInput(index, "TurnOn");
	}
	else {
		rp_AcceptEntityInput(index, "EnableMotion");
		rp_AcceptEntityInput(index, "Wake");
	}
	
	int zone = rp_GetPlayerZone(client);
	
	if( (StrEqual(arg0, "db_create_throw")) && (rp_GetZoneBit( zone ) & BITZONE_EVENT) ) {
		
		float EyeAngles[3];
		float Push[3];
		
		GetClientEyeAngles(client, EyeAngles);
		
		Push[0] = (5000.0 * Cosine(DegToRad(EyeAngles[1])));
		Push[1] = (5000.0 * Sine(DegToRad(EyeAngles[1])));
		Push[2] = (-12000.0 * Sine(DegToRad(EyeAngles[0])));
		
		int AltBeamColor[4] = {255, 100, 100, 200}; 
		TE_SetupBeamFollow(index, LaserCache, HaloSprite, 1.0, 8.0, 8.0, 1000, AltBeamColor);
		TE_SendToAll();
		
		IgniteEntity(index, 5.0);
		CreateTimer(5.0, MakeExplode, index);
		
		TeleportEntity(index, NULL_VECTOR, NULL_VECTOR, Push);
	}
	else if( StrEqual(arg0, "db_create_ball" ) ) {
		SetEntityGravity(index, 2.8);
		
		Entity_SetHealth(index, 100000, true);
	}

	PrintToConsole(client, "RP_PROPS: Props %d créé", index);
	
	return Plugin_Handled;
}
public Action Command_dublicate(int Client,int args) {
	char modelname[128];
	int Ent2 = GetClientAimTarget(Client, false);
	GetEntPropString(Ent2, Prop_Data, "m_ModelName", modelname, 128);
	
	int Ent;
	
	Ent = CreateEntityByName("prop_physics"); 
	
	DispatchKeyValue(Ent, "physdamagescale", "0.0");
	DispatchKeyValue(Ent, "model", modelname);
	DispatchSpawn(Ent);
	
	float FurnitureOrigin[3], ClientOrigin[3], EyeAngles[3];
	GetClientEyeAngles(Client, EyeAngles);
	GetClientAbsOrigin(Client, ClientOrigin); 
	FurnitureOrigin[0] = (ClientOrigin[0] + (50 * Cosine(DegToRad(EyeAngles[1]))));
	FurnitureOrigin[1] = (ClientOrigin[1] + (50 * Sine(DegToRad(EyeAngles[1]))));
	FurnitureOrigin[2] = (ClientOrigin[2] + 100);
	
	TeleportEntity(Ent, FurnitureOrigin, NULL_VECTOR, NULL_VECTOR);
	SetEntityMoveType(Ent, MOVETYPE_VPHYSICS);
	
	return Plugin_Handled;
}
public Action CmdBlock(int client,int args) {
	
	Menu_BlockSpawn_Base(client);
	return Plugin_Handled;
}
// -----------------------------------------------------------------------------------------------
bool IsValidVehicle(int car) {
	if( !IsValidEdict(car) )
		return false;
	if( !IsValidEntity(car) )
		return false;
	
	char classname[64];
	GetEdictClassname(car, classname, sizeof(classname));
	if( StrContains(classname, "prop_vehicle_", false) == 0 )
		return true;
	
	return false;
}
void RotateYaw( float angles[3], float degree ) {
	float direction[3], normal[3];
	GetAngleVectors( angles, direction, NULL_VECTOR, normal );
	
	float sin = Sine( degree * 0.01745328 );     // Pi/180
	float cos = Cosine( degree * 0.01745328 );
	float a = normal[0] * sin;
	float b = normal[1] * sin;
	float c = normal[2] * sin;
	float x = direction[2] * b + direction[0] * cos - direction[1] * c;
	float y = direction[0] * c + direction[1] * cos - direction[2] * a;
	float z = direction[1] * a + direction[2] * cos - direction[0] * b;
	direction[0] = x;
	direction[1] = y;
	direction[2] = z;
	
	GetVectorAngles( direction, angles );
	
	float up[3];
	GetVectorVectors( direction, NULL_VECTOR, up );
	
	float roll = GetAngleBetweenVectors( up, normal, direction );
	angles[2] += roll;
}
void DownloadAndPrecache( char[] model ) {
	PrecacheModel(model, true);
	AddFileToDownloadsTable(model);
}
// -----------------------------------------------------------------------------------------------


public Action MakeExplode( Handle timer, any Ent) {
	
	if( !IsValidEdict(Ent) && !IsValidEntity(Ent) )
		return Plugin_Handled;
	
	float MissilePos[3];
	Entity_GetAbsOrigin(Ent, MissilePos);
	
	int ExplosionIndex = CreateEntityByName("env_explosion");
	if (ExplosionIndex != -1) {
		
		SetEntProp(ExplosionIndex, Prop_Data, "m_spawnflags", 6146);
		SetEntProp(ExplosionIndex, Prop_Data, "m_iMagnitude", 200);
		SetEntProp(ExplosionIndex, Prop_Data, "m_iRadiusOverride", 200);
		
		DispatchSpawn(ExplosionIndex);
		ActivateEntity(ExplosionIndex);
		
		TeleportEntity(ExplosionIndex, MissilePos, NULL_VECTOR, NULL_VECTOR);
		
		EmitSoundToAll("weapons/hegrenade/explode5.wav", ExplosionIndex, 1, 90);
		
		rp_AcceptEntityInput(ExplosionIndex, "Explode");
		
		rp_AcceptEntityInput(ExplosionIndex, "Kill");
	}
	
	rp_AcceptEntityInput(Ent, "Kill");
	
	return Plugin_Handled;
	
}
public Action EventReset(Handle Evt, const char[] Name, bool Broadcast) {
	int cli = GetClientOfUserId(GetEventInt(Evt, "userid"));
	
	SetEntityGravity(cli, 1.0);
	
	OnClientPutInServer(cli);
}
void Menu_BlockSpawn_Base(int client) {
	
	Handle menu = CreateMenu(h_Menu_BlockSpawn_Base);
	SetMenuTitle(menu, "Gestion des Blocks:");
	
	char tmp[128];
	
	Format(tmp, 127, "Taille: [%s]", g_szSize[ g_iData[data_size][client] ]);
	AddMenuItem(menu, "swap_size", 	tmp);
	
	Format(tmp, 127, "Skin: [%s]", g_szSkins[ g_iData[data_skin][client] ]);
	AddMenuItem(menu, "swap_skin", tmp);
	
	Format(tmp, 127, "Couleur: [%s]", g_szColors[ g_iData[data_color][client] ][0]);
	AddMenuItem(menu, "swap_color", tmp);
	
	Format(tmp, 127, "Type: [%s]", g_szType[ g_iData[data_type][client] ]);
	AddMenuItem(menu, "swap_type", tmp);
	
	Format(tmp, 127, "Echelle: [%s]", g_szScale[ g_iData[data_scale][client] ]);
	AddMenuItem(menu, "swap_scale", tmp);
	
	AddMenuItem(menu, "spawn", "Spawn");
	
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int h_Menu_BlockSpawn_Base(Handle menu, MenuAction action, int client, int param2) {
	if( action == MenuAction_Select ) {
		
		char options[64];
		GetMenuItem(menu, param2, options, 63);
		
		if( StrEqual( options, "swap_size", false) ) {
			g_iData[data_size][client]++;
			if( g_iData[data_size][client] >= sizeof(g_szSize) ) {
				g_iData[data_size][client] = 0;
			}
		}
		else if( StrEqual( options, "swap_skin", false) ) {
			g_iData[data_skin][client]++;
			if( g_iData[data_skin][client] >= sizeof(g_szSkins) ) {
				g_iData[data_skin][client] = 0;
			}
		}
		else if( StrEqual( options, "swap_color", false) ) {
			g_iData[data_color][client]++;
			if( g_iData[data_color][client] >= sizeof(g_szColors) ) {
				g_iData[data_color][client] = 0;
			}
		}
		else if( StrEqual( options, "swap_type", false) ) {
			g_iData[data_type][client]++;
			if( g_iData[data_type][client] >= sizeof(g_szType) ) {
				g_iData[data_type][client] = 0;
			}
		}
		else if( StrEqual( options, "swap_scale", false) ) {
			g_iData[data_scale][client]++;
			if( g_iData[data_scale][client] >= sizeof(g_szScale) ) {
				g_iData[data_scale][client] = 0;
			}
		}
		else if( StrEqual( options, "spawn", false) ) {
			SpawnBlock(client);
		}
		
		Menu_BlockSpawn_Base(client);
	}
	else if( action == MenuAction_End ) {
		CloseHandle(menu);
	}
}

void SpawnBlock(int client) {
	
	float position[3];
	rp_GetClientTarget(client, position);
	
	int index = CreateEntityByName("prop_physics");
	if( !IsValidEdict(index) )
		return;
	
	g_iBlockType[index] = view_as<int>(g_iData[data_type][client]);
	DispatchKeyValue(index, "classname", BLOCK_CLASSNAME);
	
	char model_path[PLATFORM_MAX_PATH];
	Format(model_path, PLATFORM_MAX_PATH, "models/props/DeadlyDesire/blocks/%s.mdl", g_szSize[ g_iData[data_size][client] ]);

	
	if ( !IsModelPrecached( model_path ) ) {
		int table = FindStringTable("modelprecache");
		int length = GetStringTableMaxStrings(table) - (GetStringTableNumStrings(table) + 24);
		if( length <= 0 ) {
			ReplyToCommand(client, "ERREUR, Impossible de mettre le model en cache aujourd'hui: Risque de crash élevé :(");
			return;
		}
		PrecacheModel( model_path );
	}
	
	char dataColor[3][12];
	ExplodeString(g_szColors[ g_iData[data_color][client] ][1], " ", dataColor, 3, 11);
	
	float scale = StringToFloat( g_szScale[ g_iData[data_scale][client] ] );
	SetEntPropFloat(index,  Prop_Send, "m_flModelScale", scale);
	g_flBlockData[index][float_int_scale][0] = scale;
	
	for(int i=0; i<=2; i++ ) {
		g_flBlockData[index][float_mins][i] = g_fMins[ g_iData[data_size][client] ][i] * scale;
		g_flBlockData[index][float_maxs][i] = g_fMaxs[ g_iData[data_size][client] ][i] * scale;
		
		g_flBlockData[index][float_int_color][i] = StringToFloat(dataColor[i]);
	}
	
	position[2] += g_flBlockData[index][float_maxs][2];
	
	char skin[12];
	IntToString(g_iData[data_skin][client], skin, 11);
	
	DispatchKeyValue(index, "model", model_path);
	DispatchKeyValue(index, "Skin", skin);
	
	DispatchKeyValue(index, "rendermode", "5");
	DispatchKeyValue(index, "rendercolor", g_szColors[ g_iData[data_color][client] ][1]);
	
	DispatchKeyValue(index, "solid", "2");
	
	//DispatchKeyValue(index, "fademindist", "-1");
	//DispatchKeyValue(index, "fademaxdist", "0");
	DispatchKeyValue(index, "disableshadows", "1");
	
	
	ActivateEntity( index );
	DispatchSpawn( index );
	
	SetEntPropVector( index, Prop_Send, "m_vecMins", g_flBlockData[index][float_mins]);
	SetEntPropVector( index, Prop_Send, "m_vecMaxs", g_flBlockData[index][float_maxs]);  
	SetEntProp(index, Prop_Send, "m_nSolidType", 2);
	
	doSnapping(index, position);
		
	Entity_MarkSurrBoundsDirty( index );
	
	SetEntityMoveType(index, MOVETYPE_NONE);
	
	BlockType(client, index);
}
bool ValidBox(int ent) {
	if( !IsValidEdict(ent) )
		return false;
	if( !IsValidEntity(ent) )
		return false;
	
	char classname[64];
	GetEdictClassname(ent, classname, sizeof(classname));
	if( StrContains(classname, BLOCK_CLASSNAME, false) == 0 )
		return true;
	
	return false;
}
void doSnapping(int ent, float fMoveTo[3]) {

	float fSnapSize = MaxSnap * g_flBlockData[ent][float_int_scale][0];
	float vReturn[3];
	float dist;
	float distOld = 99999.9;
	float vTraceStart[3];
	float vTraceEnd[3];
	int tr;
	int trClosest = 0;
	int blockFace;
	float fSizeMin[3], fSizeMax[3];
	fSizeMin = g_flBlockData[ent][float_mins];
	fSizeMax = g_flBlockData[ent][float_maxs];
	
	//do 6 traces out from each face of the block
	for (int i = 0; i < 6; i++) {
		//setup the start of the trace
		vTraceStart = fMoveTo;
		
		switch (i) {
			case 0: vTraceStart[0] += fSizeMin[0];		//edge of block on -X
			case 1: vTraceStart[0] += fSizeMax[0];		//edge of block on +X
			case 2: vTraceStart[1] += fSizeMin[1];		//edge of block on -Y
			case 3: vTraceStart[1] += fSizeMax[1];		//edge of block on +Y
			case 4: vTraceStart[2] += fSizeMin[2];		//edge of block on -Z
			case 5: vTraceStart[2] += fSizeMax[2];		//edge of block on +Z
		}
		
		//setup the end of the trace
		vTraceEnd = vTraceStart;
		
		switch (i) {
			case 0: vTraceEnd[0] -= fSnapSize;
			case 1: vTraceEnd[0] += fSnapSize;
			case 2: vTraceEnd[1] -= fSnapSize;
			case 3: vTraceEnd[1] += fSnapSize;
			case 4: vTraceEnd[2] -= fSnapSize;
			case 5: vTraceEnd[2] += fSnapSize;
		}
		
		//trace a line out from one of the block faces
		Handle trace = TR_TraceRayFilterEx(vTraceStart, vTraceEnd, MASK_PLAYERSOLID, RayType_EndPoint, FilterToOne, ent);
		tr = TR_GetEntityIndex(trace);
		TR_GetEndPosition(vReturn, trace);
		CloseHandle(trace);
		
		//if the trace found a block and block is not in group or block to snap to is not in group
		if( ValidBox(tr) ) {
			//get the distance from the grabbed block to the found block
			dist = GetVectorDistance(vTraceStart, vReturn);
			
			//if distance to found block is less than the previous block
			if (dist < distOld) {
				trClosest = tr;
				distOld = dist;
				
				//save the block face where the trace came from
				blockFace = i;
			}
		}
	}
		
	//if there is a block within the snapping range
	if( ValidBox(trClosest) ) {
		//get origin of closest block
		float vOrigin[3], fTrSizeMin[3], fTrSizeMax[3];
		Entity_GetAbsOrigin(trClosest, vOrigin);
		
		fTrSizeMin = g_flBlockData[trClosest][float_mins];
		fTrSizeMax = g_flBlockData[trClosest][float_maxs];
		
		//move the subject block to the origin of the closest block
		fMoveTo = vOrigin;
		
		//offset the block to be on the side where the trace hit the closest block
		if (blockFace == 0) fMoveTo[0] += (fTrSizeMax[0] + fSizeMax[0])/* + gfSnappingGap[id]*/;
		if (blockFace == 1) fMoveTo[0] += (fTrSizeMin[0] + fSizeMin[0])/* - gfSnappingGap[id]*/;
		if (blockFace == 2) fMoveTo[1] += (fTrSizeMax[1] + fSizeMax[1])/* + gfSnappingGap[id]*/;
		if (blockFace == 3) fMoveTo[1] += (fTrSizeMin[1] + fSizeMin[1])/* - gfSnappingGap[id]*/;
		if (blockFace == 4) fMoveTo[2] += (fTrSizeMax[2] + fSizeMax[2])/* + gfSnappingGap[id]*/;
		if (blockFace == 5) fMoveTo[2] += (fTrSizeMin[2] + fSizeMin[2])/* - gfSnappingGap[id]*/;
	}
	
	TeleportEntity(ent, fMoveTo, NULL_VECTOR, NULL_VECTOR);
}
stock void SetupGlow(int entity, int r, int g, int b, int a) {
	static int offset;

	// Get sendprop offset for prop_dynamic_override
	if (!offset && (offset = GetEntSendPropOffs(entity, "m_clrGlow")) == -1) {
		LogError("Unable to find property offset: \"m_clrGlow\"!");
		return;
	}

	// Enable glow for custom skin
	SetEntProp(entity, Prop_Send, "m_bShouldGlow", true, true);

	// So now setup given glow colors for the skin
	SetEntData(entity, offset, r, _, true);    // Red
	SetEntData(entity, offset + 1, g, _, true); // Green
	SetEntData(entity, offset + 2, b, _, true); // Blue
	SetEntData(entity, offset + 3, a, _, true); // Alpha
}
void BlockType(int client, int index) {
	
	int r = RoundFloat( g_flBlockData[index][float_int_color][0] );
	int g = RoundFloat( g_flBlockData[index][float_int_color][1] );
	int b = RoundFloat( g_flBlockData[index][float_int_color][2] );
	
	switch(g_iData[data_type][client]) {
		case BLOCK_TRANSPARENT: {
			SetEntityRenderColor(index, r, g, b, 128);
		}
		case BLOCK_INVISIBLE: {
			SetEntityRenderColor(index, r, g, b, 10);
		}
		case BLOCK_FLAME: {
			SetEntProp(index, Prop_Send, "m_nSkin", 6); 
			SetEntityRenderColor(index, 255, 180, 0, 255);
			
			SDKHook(index, SDKHook_Touch, Block_IGNITE);
		}
		case BLOCK_BUNNY: {
			SetEntProp(index, Prop_Send, "m_nSkin", 0); 
			SetEntityRenderColor(index, 255, 0, 0, 128);
			
			SDKHook(index, SDKHook_StartTouch, Block_BHOP);
		}
		case BLOCK_BOOST: {
			SetEntProp(index, Prop_Send, "m_nSkin", 3); 
			SetEntityRenderColor(index, 100, 255, 100, 200);
			
			SDKHook(index, SDKHook_Touch, Block_BOOST);
		}
		case BLOCK_JUMP: {
			SetEntProp(index, Prop_Send, "m_nSkin", 6); 
			SetEntityRenderColor(index, 255, 128, 255, 200);
			
			SDKHook(index, SDKHook_EndTouchPost, Block_JUMP);
		}
		case BLOCK_HEAL: {
			SetEntProp(index, Prop_Send, "m_nSkin", 3); 
			SetEntityRenderColor(index, 200, 255, 200, 255);
			
			SDKHook(index, SDKHook_Touch, Block_HEAL);
		}
		case BLOCK_KILL: {
			SetEntProp(index, Prop_Send, "m_nSkin", 5); 
			SetEntityRenderColor(index, 255, 50, 50, 255);
			
			SDKHook(index, SDKHook_StartTouch, Block_KILL);
		}
		case BLOCK_FREEZE: {
			SetEntProp(index, Prop_Send, "m_nSkin", 2); 
			SetEntityRenderColor(index, 100, 100, 255, 200);
			
			SDKHook(index, SDKHook_Touch, Block_FREEZE);
		}
		case BLOCK_MIRROR: {
			SetEntProp(index, Prop_Send, "m_nSkin", 4); 
			SetEntityRenderColor(index, 255, 200, 100, 200);
			
			SDKHook(index, SDKHook_Touch, Block_MIRROR);
		}
		case BLOCK_STRIP: {
			SetEntProp(index, Prop_Send, "m_nSkin", 1); 
			SetEntityRenderColor(index, 100, 100, 100, 200);
			
			SDKHook(index, SDKHook_StartTouch, Block_STRIP);
		}
		case BLOCK_LIGHT: {
			SetEntityRenderColor(index, r, g, b, 200);
			
			SDKHook(index, SDKHook_Touch, Block_LIGHT);
		}
		case BLOCK_TP: {
			if( tpTypeExit > 0 && IsValidEdict(tpTypeExit) && IsValidEntity(tpTypeExit) ) {
				SetEntityRenderColor(index, 0, 0, 0, 100);
				SetEntProp(index, Prop_Send, "m_nSkin", 0); 
				SDKHook(index, SDKHook_Touch, Block_MIRROR);
				g_iTeleportTo[tpTypeExit] = index;
				tpTypeExit = 0;
			}
			else {
				SetEntityRenderColor(index, 255, 255, 255, 250);
				SetEntProp(index, Prop_Send, "m_nSkin", 1); 
				SDKHook(index, SDKHook_Touch, Block_TP_IN);
				tpTypeExit = index;
			}
		}
		case BLOCK_GRAVITY: {
			SetEntityRenderColor(index, 128, 64, 64, 250);
			
			SDKHook(index, SDKHook_Touch, Block_GRAVITY);
		}
		case BLOCK_BREAKABLE: {
			SetEntProp(index, Prop_Send, "m_nSkin", 1); 
			SetEntityRenderColor(index, 0, 255, 0, 200);
			SetEntProp(index, Prop_Data, "m_takedamage", 2, 1);
			
			SDKHook(index, SDKHook_OnTakeDamagePost, Block_BREAKABLE_Damage);
			
			Entity_SetHealth(index, 140, true);
			Entity_SetMaxHealth(index, 140);
		}
		case BLOCK_COLORIZE: {
			SetEntProp(index, Prop_Send, "m_nSkin", 1); 
			SetEntityRenderColor(index, r, g, b, 200);
			
			SDKHook(index, SDKHook_Touch, Block_Colorize);
			SDKHook(index, SDKHook_Touch, Block_LIGHT);
		}
		case BLOCK_FAKE: {
			SetEntityRenderColor(index, r, g, b, 250);
			SetEntProp( index, Prop_Send, "m_nSolidType", 0);		
		}
		case BLOCK_REMOVER: {
			
			SetEntityRenderColor(index, 0, 0, 0, 255);
			Entity_SetSolidFlags(index, FSOLID_TRIGGER|FSOLID_TRIGGER_TOUCH_DEBRIS|FSOLID_USE_TRIGGER_BOUNDS|FSOLID_VOLUME_CONTENTS);
			
			SDKHook(index, SDKHook_Touch, Block_REMOVER);
		}
	}
	
	SetEntProp(index, Prop_Send, "m_nSkin", 0); 
}
public Action Block_REMOVER(int index, int entity) {
	char classname[64];
	GetEdictClassname(entity, classname, sizeof(classname));
	
	if( StrContains(classname, "prop_physics", false) == 0 || StrContains(classname, "prop_sphere", false) == 0 || StrContains(classname, "player", false) == 0 || StrContains(classname, "weapon_", false) == 0 ) {
		if( IsValidClient(entity) ) {
			int heal = GetClientHealth(entity) * 10;
			SDKHooks_TakeDamage(entity, index, entity, float(heal));
		}
		else {
			Desyntegrate(entity);
		}
	}
	return Plugin_Continue;
	
}
public Action Block_Colorize(int index, int client) {
	if( IsValidClient(client) ) {
		int r = RoundFloat( g_flBlockData[index][float_int_color][0] );
		int g = RoundFloat( g_flBlockData[index][float_int_color][1] );
		int b = RoundFloat( g_flBlockData[index][float_int_color][2] );
		SetEntityRenderColor(client, r, g, b, 255);
	}
}
public void Block_BREAKABLE_Damage(int victim, int attacker, int inflictor, float damage, int damagetype) {
	int heal = Entity_GetHealth(victim);
	int max = Entity_GetMaxHealth(victim);
	if( max == 0 )
		max = 140;
	
	int red = RoundFloat(255.0 - (float(heal) / float(max) * 255.0));
	int green = RoundFloat(float(heal) / float(max) * 255.0);
	
	if( red < 0 )
		red = 0;
	if( red > 255 )
		red = 255;
	
	if( green < 0 )
		green = 0;
	if( green > 255 )
		green = 255;
	
	
	SetEntityRenderColor(victim, red, green, 0, 200);
}
public Action Block_TP_IN(int index, int client) {
	if( IsValidClient(client) && IsValidEdict(g_iTeleportTo[index]) ) {
		
		float offset[3], vecOrigin[3];
		
		
		Entity_GetAbsOrigin(g_iTeleportTo[index], vecOrigin);
		
		if( vecOrigin[0] <= 1.0 && vecOrigin[1] <= 1.0 && vecOrigin[1] <= 1.0 && 
			vecOrigin[0] >= -1.0 && vecOrigin[1] >= -1.0 && vecOrigin[1] >= -1.0 )
				return;
			
		vecOrigin[2] += g_flBlockData[index][float_maxs][2] * 2.0;
		
		while( GetVectorLength(offset) < 128.0 ) {
			offset[0] = GetRandomFloat(-256.0, 256.0);
			offset[1] = GetRandomFloat(-256.0, 256.0);
		}
		offset[2] = 64.0;
		
		rp_ClientTeleport(client, vecOrigin);
		
	}
}

float g_flBlockLightLast[2048];
public Action Block_LIGHT(int index, int client) {
	if( IsValidClient(client) && g_flBlockLightLast[index]+0.95 < GetTickedTime() ) {
		float vecOrigin[3];
		Entity_GetAbsOrigin(index, vecOrigin);
		
		int r = RoundFloat( g_flBlockData[index][float_int_color][0] );
		int g = RoundFloat( g_flBlockData[index][float_int_color][1] );
		int b = RoundFloat( g_flBlockData[index][float_int_color][2] );
		
		TE_SetupDynamicLight(vecOrigin, r, g, b, 10, 200.0, 1.0, 1.0);
		TE_SendToAll();
		
		g_flBlockLightLast[index] = GetTickedTime();
	}
}

public Action Block_GRAVITY(int index, int client) {
	if( IsValidClient(client) ) {
		if( g_fPending_GRAVITY[client]+0.1 > GetGameTime() ) {
			g_fPending_GRAVITY[client] = GetGameTime();
			SetEntityGravity(client, -0.5);
		}
		else if( g_fPending_GRAVITY[client]+3600.0 > GetGameTime() ) {
			g_fPending_GRAVITY[client] = -999999999.0;
			SetEntityGravity(client, 1.0);
			if( g_fPending_FALL[client] < 1.0) {
				SDKHook(client, SDKHook_OnTakeDamage, Block_JUMP_3);
			}
			g_fPending_FALL[client] = GetGameTime() + 5.0;
		}
		else {
			g_fPending_GRAVITY[client] = GetGameTime();
			SetEntityGravity(client, -0.5);
		}
	}
}
public Action Block_STRIP(int index, int client) {
	if( IsValidClient(client) ) {
		int wepIdx;
		for(int i = 0; i < 5; i++ ) {			
			while( ( wepIdx = GetPlayerWeaponSlot( client, i ) ) != -1 ) {
				RemovePlayerItem( client, wepIdx );
				RemoveEdict( wepIdx );
			}
		}
		
		rp_SetClientBool(client, b_WeaponIsKnife, false);
		rp_SetClientBool(client, b_WeaponIsHands, true);
		rp_SetClientBool(client, b_WeaponIsMelee, false);
		
		rp_ClientGiveHands(client);
	}
}
public Action Block_IGNITE(int index, int client) {
	if( IsValidClient(client) ) {
		IgniteEntity(client, 10.0);
	}
}

int g_bPending_Bunny[2049];

public Action Block_BHOP(int index, int client) {
	if( IsValidClient(client) ) {
		
		if( !g_bPending_Bunny[index] ) {
			g_bPending_Bunny[index] = true;
			CreateTimer( 0.1, Block_BHOP_2, index );
		}
	}
}
public Action Block_BHOP_2(Handle timer, any index) {
	
	SetEntityRenderColor(index, 255, 0, 0, 20);
	SetEntProp( index, Prop_Send, "m_nSolidType", 0);
	
	CreateTimer( 1.0, Block_BHOP_3, index );
}
public Action Block_BHOP_3(Handle timer, any index) {
	
	SetEntityRenderColor(index, 255, 0, 0, 128);
	SetEntProp( index, Prop_Send, "m_nSolidType", 2);
	
	g_bPending_Bunny[index] = false;	
}
public Action Block_BOOST(int index, int client) {
	if( IsValidClient(client) ) {
		
		g_fPending_BOOST[client] = GetGameTime();
		g_iPending_BOOST[client] = index;
		
	}
}
public Action Block_FREEZE(int index, int client) {
	if( IsValidClient(client) ) {
		
		g_fPending_FREEZE[client] = GetGameTime();
	}
}
public Action Block_MIRROR(int index, int client) {
	if( IsValidClient(client) ) {
		
		g_fPending_MIRROR[client] = GetGameTime();
	}
}
public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon) {
	if( g_fPending_BOOST[client]+0.1 > GetGameTime() ) {
		
		float ang[3], ang2[3];
		
		Entity_GetAbsAngles(g_iPending_BOOST[client], ang2);
		ang[0] = 0.0;
		ang[1] = angles[1];
		ang[2] = 0.0;
		
		if( ang2[0] > 0.0 )
			ang[0] = -ang2[0];
		
		if( ang2[2] > 0.0 )
			ang[0] = -ang2[2];
		
		GetAngleVectors(ang, vel, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(vel, 800.0);
		
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
		
		int flags = GetEntityFlags(client);
		SetEntityFlags(client, (flags&~FL_ONGROUND) );
		SetEntPropEnt(client, Prop_Send, "m_hGroundEntity", -1);
		
		return Plugin_Changed;
	}
	if( g_fPending_FREEZE[client]+0.1 > GetGameTime() ) {
		
		float ang[3];
		ang[1] = angles[1];
		
		GetAngleVectors(ang, vel, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(vel, 15.0);
		vel[2] = 1.0;
		
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
		return Plugin_Changed;
	}
	if( g_fPending_MIRROR[client]+0.1 > GetGameTime() ) {
		
		float ang[3];
		ang[1] = angles[1];
		
		GetAngleVectors(ang, vel, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(vel, -240.0);
		vel[2] = 1.0;
		
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
		return Plugin_Changed;
	}
	if( g_fPending_GRAVITY[client]+3600.0 > GetGameTime() ) {
		SetEntityGravity(client, -0.5);
		
		int flags = GetEntityFlags(client);
		SetEntityFlags(client, (flags&~FL_ONGROUND) );
		SetEntPropEnt(client, Prop_Send, "m_hGroundEntity", -1);
	}
	return Plugin_Continue;
}
public Action Block_JUMP(int index, int client) {
	if( IsValidClient(client) && !rp_IsGrabbed(index) ) {
		
		int flags = GetEntityFlags(client);
		SetEntityFlags(client, (flags&~FL_ONGROUND) );
		SetEntPropEnt(client, Prop_Send, "m_hGroundEntity", -1);
		
		float vecVelocity[3];
		
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", vecVelocity);
		vecVelocity[2] += 600.0;
		if( vecVelocity[2] < 2000.0 )
			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vecVelocity);
		
		if( g_fPending_FALL[client] < 1.0) {
			SDKHook(client, SDKHook_OnTakeDamage, Block_JUMP_3);
		}
		g_fPending_FALL[client] = GetGameTime();
	}
}
public void OnGameFrame() {
	for(int client=1; client<=MaxClients; client++) {
		if( !IsValidClient(client) )
			continue;
		
		if( g_fPending_FALL[client] > 0.0 && g_fPending_FALL[client]+5.0 < GetGameTime() ) {
			g_fPending_FALL[client] = 0.0;
			SDKUnhook(client, SDKHook_OnTakeDamage, Block_JUMP_3);
		}
		if( g_fPending_GRAVITY[client] > 0.0 && g_fPending_GRAVITY[client]+3600.0 < GetGameTime() ) {
			SetEntityGravity(client, 1.0);
			g_fPending_GRAVITY[client] = -9999999.0;
			
			if( g_fPending_FALL[client] < 1.0) {
				SDKHook(client, SDKHook_OnTakeDamage, Block_JUMP_3);
			}
			g_fPending_FALL[client] = GetGameTime() + 5.0;
		}
	}
}
public Action Block_JUMP_3(int client, int& attacker, int& inflictor, float& damage, int& damagetype) {
	if(damagetype & DMG_FALL) {
		
		damage *= 0.0;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}
public Action Block_HEAL(int index, int client) {
	if( IsValidClient(client) ) {
		
		int heal = GetClientHealth(client);
		
		if( MaxHealth > heal ) {
			heal++;
			
			if( heal > MaxHealth )
				heal = MaxHealth;
			
			SetEntityHealth(client, heal);
		}
	}
}
public Action Block_KILL(int index, int client) {
	if( IsValidClient(client) ) {
		
		int heal = GetClientHealth(client) * 10;
		
		SDKHooks_TakeDamage(client, index, client, float(heal));		
	}
}

// ---------------------------------------------------------------------------------------------------------
// ---------------------------------------- PROP SAVER W.I.P -----------------------------------------------
// ---------------------------------------------------------------------------------------------------------

public Action Command_saveEvent(int client,int args) {
	char savename[64],tmp[64],steamId[64],prequery[256];
	Handle db = rp_GetDatabase();
	for(int i=1; i<=args; i++) {
		GetCmdArg(i, tmp, sizeof(tmp));
		Format(savename, sizeof(savename), "%s %s", savename, tmp);
	}
	SQL_EscapeString(db, savename, savename, sizeof(savename));
	GetClientAuthId(client, AUTH_TYPE, steamId, sizeof(steamId));
	Format(prequery, sizeof(prequery), "INSERT INTO `rp_shared`.`rp_propsaves`(`name`, `steamid`, `date`) VALUES (\"%s\",\"%s\",NOW())", savename, steamId);
	SQL_TQuery(db, SQL_SaveEventPre, prequery, client, DBPrio_High);
	return Plugin_Handled;
}
public void SQL_SaveEventPre(Handle owner, Handle row, const char[] error, any client) {
	Handle db = rp_GetDatabase();
	char pClass[64];
	int saveId,countProps;
	float pPos[3];
	int reqLength = 2;

	saveId = SQL_GetInsertId(db);

	for(int i = MAXPLAYERS+1;i<2048; i++){
		if(!IsValidEdict(i))
			continue;
		if(!IsValidEntity(i))
			continue;
		GetEdictClassname(i, pClass, sizeof(pClass));
		if(!((StrContains(pClass, BLOCK_CLASSNAME, false) == 0) || 
			(StrContains(pClass, "prop_physics", false) == 0) || 
			(StrContains(pClass, "prop_dynamic", false) == 0) || 
			(StrContains(pClass, "weapon_", false) == 0)))
			continue;
		Entity_GetAbsOrigin(i, pPos);
		if(rp_GetZoneBit(rp_GetZoneFromPoint(pPos)) & BITZONE_EVENT)
			reqLength++;
	}

	if(reqLength < 3)
		return;
	reqLength *= 300;


	char[] query = new char[reqLength--];
	Format(query, reqLength, "INSERT INTO `rp_shared`.`rp_propcontent`(`id`, `classname`, `model`, `posX`, `posY`, `posZ`, `rotP`, `rotY`, `rotR`, `colr`, `colg`, `colb`, `cola`, `scale`, `bloctype`, `skin`) VALUES");

	bool firstrow = true;
	float pAng[3], pScale;
	char pModel[128];
	int pCol[4], pZone, pSkin, pBlockType;

	for(int i = MAXPLAYERS+1;i<2049; i++){
		if(!IsValidEdict(i))
			continue;
		if(!IsValidEntity(i))
			continue;

		GetEdictClassname(i, pClass, sizeof(pClass));
		if(!((StrContains(pClass, BLOCK_CLASSNAME, false) == 0) || 
			(StrContains(pClass, "prop_physics", false) == 0) || 
			(StrContains(pClass, "prop_dynamic", false) == 0) || 
			(StrContains(pClass, "weapon_", false) == 0)))
			continue;
		GetPropInfo(i, pPos, pAng, pCol, pClass, pModel, pScale, pSkin, pBlockType);
		if(view_as<block_type>(pBlockType) == BLOCK_TP)
			continue;
		pZone = rp_GetZoneFromPoint(pPos);
		if( ! (rp_GetZoneBit(pZone) & BITZONE_EVENT))
			continue;
		
		ReplaceString(pModel, sizeof(pModel), "\\", "/");
		countProps++;
		if(!firstrow){
			Format(query, reqLength, "%s, (%i, \"%s\", \"%s\", \"%f\", \"%f\", \"%f\", \"%f\", \"%f\", \"%f\", %i, %i, %i, %i, \"%f\", %i, %i)",
				query,
				saveId,
				pClass,
				pModel,
				pPos[0], pPos[1], pPos[2],
				pAng[0], pAng[1], pAng[2],
				pCol[0], pCol[1], pCol[2], pCol[3],
				pScale,
				pBlockType,
				pSkin );
		}
		else{
			Format(query, reqLength, "%s(%i, \"%s\", \"%s\", \"%f\", \"%f\", \"%f\", \"%f\", \"%f\", \"%f\", %i, %i, %i, %i, \"%f\", %i, %i)",
				query,
				saveId,
				pClass,
				pModel,
				pPos[0], pPos[1], pPos[2],
				pAng[0], pAng[1], pAng[2],
				pCol[0], pCol[1], pCol[2], pCol[3],
				pScale,
				pBlockType,
				pSkin );
			firstrow= false;
		}
	}
	SQL_TQuery(db, SQL_QueryCallBack, query, _, DBPrio_Low);
	CPrintToChat(client, "" ...MOD_TAG... " %i props ont été sauvegardé.", countProps);
}
void GetPropInfo(int gpEnt, float pPos[3], float pAng[3], int pCol[4], char pClass[64], char pModel[128], float& pScale, int& pSkin, int& pBlockType){
	Entity_GetAbsOrigin(gpEnt, pPos);

	Entity_GetAbsAngles(gpEnt, pAng);

	GetEdictClassname(gpEnt, pClass, sizeof(pClass));

	int offset = GetEntSendPropOffs(gpEnt, "m_clrRender", true);
	for(int i=0; i<sizeof(pCol); i++)
		pCol[i]=GetEntData(gpEnt, offset+i, 1);

	GetEntPropString(gpEnt, Prop_Data, "m_ModelName", pModel, sizeof(pModel));
	pScale = GetEntPropFloat(gpEnt,  Prop_Send, "m_flModelScale", 0);
	pSkin = GetEntProp(gpEnt,  Prop_Send, "m_nSkin", 0);
	pBlockType = g_iBlockType[gpEnt];
	
}
public Action Command_loadEvent(int client,int args) {
	Handle db = rp_GetDatabase();

	char tmp[128], savename[64], query[256];

	for(int i=1; i<=args; i++) {
		GetCmdArg(i, tmp, sizeof(tmp));
		Format(savename, sizeof(savename), "%s %s", savename, tmp);
	}
	SQL_EscapeString(db, savename, savename, sizeof(savename));
	Format(query, sizeof(query), "SELECT S.`id`, `name`, SUM(IF( C.classname LIKE \"weapon_%%\", 2, 1)) FROM `rp_shared`.`rp_propsaves` S INNER JOIN `rp_shared`.rp_propcontent C ON S.id=C.id WHERE `name` LIKE '%%%s%%' AND `disabled` = 0 GROUP BY S.`id` ORDER BY date DESC", savename);
	SQL_TQuery(db, SQL_LoadEvent, query, client, DBPrio_High);

	return Plugin_Handled;
}
int countEntity() {
	int cpt = MaxClients;
	for (int i = MaxClients; i <= 2048; i++) {
		if( IsValidEdict(i) && IsValidEntity(i) )
			cpt++;
	}
	return cpt;
}
public void SQL_LoadEvent(Handle owner, Handle row, const char[] error, any client) {
	int max = GetConVarInt(FindConVar("rp_max_entity"));
	int current = countEntity();
	
	int countLine = 0;
	char tmp[128],tmp2[16];
	Handle menu = CreateMenu(MenuLoadEvent);
	SetMenuTitle(menu, "Selection de l'event à charger:");
	while(SQL_FetchRow(row)){
		SQL_FetchString(row, 1, tmp, sizeof(tmp));
		
		int cpt = SQL_FetchInt(row, 2);
		
		Format(tmp, sizeof(tmp), "%s (+%.1f%%)", tmp, cpt*100.0/float(max));
		
		Format(tmp2, sizeof(tmp2), "%i", SQL_FetchInt(row, 0));
		AddMenuItem(menu, tmp2, tmp, ((current+cpt) >= max) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		countLine++;
	}
	CloseHandle(row);
	if(countLine > 0)
		DisplayMenu(menu, client, 60*10);
	else
		ReplyToCommand(client, "ERREUR, Aucun event trouvé.");
		

}
public Action Command_removeEvent(int client,int args) {
	Handle db = rp_GetDatabase();
	char tmp[128], savename[64], query[256];
	for(int i=1; i<=args; i++) {
		GetCmdArg(i, tmp, sizeof(tmp));
		Format(savename, sizeof(savename), "%s %s", savename, tmp);
	}
	SQL_EscapeString(db, savename, savename, sizeof(savename));
	Format(query, sizeof(query), "SELECT `id`, `name` FROM `rp_shared`.`rp_propsaves` WHERE `name` LIKE '%%%s%%' AND `disabled`= 0 AND DATE_ADD(date, INTERVAL 14 DAY) > NOW()", savename);
	SQL_TQuery(db, SQL_removeEvent, query, client, DBPrio_High);
	return Plugin_Handled;
}
public void SQL_removeEvent(Handle owner, Handle row, const char[] error, any client) {
	int countLine = 0;
	char tmp[128],tmp2[16];
	Handle menu = CreateMenu(MenuDeleteEvent);
	SetMenuTitle(menu, "Selection de l'event à supprimer:");
	while(SQL_FetchRow(row)){
		SQL_FetchString(row, 1, tmp, sizeof(tmp));
		Format(tmp2, sizeof(tmp2), "%i", SQL_FetchInt(row, 0));
		AddMenuItem(menu, tmp2, tmp);
		countLine++;
	}
	CloseHandle(row);
	if(countLine > 0)
		DisplayMenu(menu, client, 60);
	else
		ReplyToCommand(client, "ERREUR, Aucun event trouvé.");

}
public int MenuLoadEvent(Handle menu, MenuAction action, int client, int param2) {
	#if defined DEBUG
	PrintToServer("MenuLoadEvent");
	#endif
	
	if( action == MenuAction_Select ) {
		char szMenuItem[16];
		int sdata;
		if( GetMenuItem(menu, param2, szMenuItem, sizeof(szMenuItem)) ) {
			sdata = StringToInt(szMenuItem) + client*10000;
			if(processing){
				CPrintToChat(client, "" ...MOD_TAG... " Un event est déjà entrain d'être respawn.");
				return;
			}
			for(int i=0;i<MAX_ZONES;i++){
				if(rp_GetZoneBit(i) & BITZONE_EVENT)
					ServerCommand("rp_force_clean %d full", i);
			}
			CreateTimer(1.0, timerRespawnEvent, sdata);
			processing = true;
			CreateTimer(5.0, endProcessing, client);
		}
	}
	else if( action == MenuAction_End ) {
		CloseHandle(menu);
	}
}
public int MenuDeleteEvent(Handle menu, MenuAction action, int client, int param2) {
	#if defined DEBUG
	PrintToServer("MenuLoadEvent");
	#endif
	
	if( action == MenuAction_Select ) {
		char szMenuItem[16];
		int saveId;
		char req[256];
		Handle db = rp_GetDatabase();
		if( GetMenuItem(menu, param2, szMenuItem, sizeof(szMenuItem)) ) {
			saveId = StringToInt(szMenuItem);
			Format(req, sizeof(req), "UPDATE `rp_shared`.`rp_propsaves` SET `disabled`=1 WHERE id=%i", saveId);
			SQL_TQuery(db, SQL_QueryCallBack, req);
		}
	}
	else if( action == MenuAction_End ) {
		CloseHandle(menu);
	}
}
public Action endProcessing(Handle timer, any client) {
	processing = false;
}
public Action timerRespawnEvent(Handle timer, any sdata) {
	#if defined DEBUG
	PrintToServer("timerRespawnEvent");
	#endif
	Handle db = rp_GetDatabase();
	char req[256];
	int client,saveId;
	saveId = sdata % 10000;
	client = (sdata - saveId)/10000;

	Format(req, sizeof(req), "SELECT `classname`, `model`, `posX`, `posY`, `posZ`, `rotP`, `rotY`, `rotR`, `colr`, `colg`, `colb`, `cola`, `scale`, `skin`, `bloctype` FROM `rp_shared`.`rp_propcontent` WHERE id=%i", saveId);
	SQL_TQuery(db, SQL_RespawnEvent, req, client, DBPrio_High);
}

public void SQL_RespawnEvent(Handle owner, Handle row, const char[] error, any client) {
	int field;
	char pModel[PLATFORM_MAX_PATH], pClass[64];
	int countProps = 0;
	int pCol[4], pSkin, pBlockType;
	float pPos[3], pAng[3], pScale;
	StripWeapons(client);
	
	int entCount = countEntity();
	int max = GetConVarInt(FindConVar("rp_max_entity"));
	
	PrintToChatAll(error);
	while( SQL_FetchRow(row) ){
		field=0;
		SQL_FetchString(row, field++, pClass, sizeof(pClass));

		SQL_FetchString(row, field++, pModel, sizeof(pModel));
		
		pPos[0] = SQL_FetchFloat(row, field++);
		pPos[1] = SQL_FetchFloat(row, field++);
		pPos[2] = SQL_FetchFloat(row, field++);
		
		pAng[0] = SQL_FetchFloat(row, field++);
		pAng[1] = SQL_FetchFloat(row, field++);
		pAng[2] = SQL_FetchFloat(row, field++);

		pCol[0] = SQL_FetchInt(row, field++);
		pCol[1] = SQL_FetchInt(row, field++);
		pCol[2] = SQL_FetchInt(row, field++);
		pCol[3] = SQL_FetchInt(row, field++);

		pScale  = SQL_FetchFloat(row, field++);

		pSkin   = SQL_FetchInt(row, field++);
		pBlockType= SQL_FetchInt(row, field++);
		RespawnProp(client, pPos, pAng, pCol, pClass, pModel, pScale, pSkin, pBlockType);
		countProps++;
		entCount++;
		
		if( countEntity() != entCount && StrContains(pClass, "weapon_") != 0 ) {
			CPrintToChat(client, "WARNING!!!!!: %s %s", pClass, pModel);
		}
		
		entCount = countEntity(); // certains props compte pour plus d'une entité.
		
		if( countEntity() >= max ) {
			CPrintToChat(client, "ERREUR !!! Votre event à risquer de faire crash le serveur. Trop de props.");
			
			for(int i=0;i<MAX_ZONES;i++){
				if(rp_GetZoneBit(i) & BITZONE_EVENT)
					ServerCommand("rp_force_clean %d full", i);
			}
			break;
		}
	}
	CloseHandle(row);
}
void RespawnProp(int client, float pPos[3], float pAng[3], int pCol[4], char pClass[64], char pModel[PLATFORM_MAX_PATH], float pScale, int pSkin, int pBlockType){
	static char skin[12], rendcol[64], dataColor[3][12];
	if(StrContains(pClass, BLOCK_CLASSNAME, false) == 0){
		int index = CreateEntityByName("prop_physics");
		if( !IsValidEdict(index) )
			return;

		DispatchKeyValue(index, "classname", pClass);
		
		if ( !IsModelPrecached( pModel ) ) {
			int table = FindStringTable("modelprecache");
			int length = GetStringTableMaxStrings(table) - (GetStringTableNumStrings(table) + 24);
			if( length <= 0 ) {
				ReplyToCommand(client, "ERREUR, Impossible de mettre le model en cache aujourd'hui: Risque de crash élevé :(");
				return;
			}
			PrecacheModel( pModel );
		}

		SetEntPropFloat(index,  Prop_Send, "m_flModelScale", pScale);
		g_flBlockData[index][float_int_scale][0] = pScale;
		int dSize;
		for(int i=0; i<sizeof(g_szSize); i++){
			if(StrContains(pModel, g_szSize[i], false) != -1){
				dSize = i;
				break;
			}
		}

		Format(rendcol, sizeof(rendcol), "%i %i %i", pCol[0], pCol[1], pCol[2]);

		ExplodeString(rendcol, " ", dataColor, 3, 11);

		SetEntPropFloat(index,  Prop_Send, "m_flModelScale", pScale);
		g_flBlockData[index][float_int_scale][0] = pScale;

		for(int i=0; i<=2; i++ ) {
			g_flBlockData[index][float_mins][i] = g_fMins[dSize][i] * pScale;
			g_flBlockData[index][float_maxs][i] = g_fMaxs[dSize][i] * pScale;
			
			g_flBlockData[index][float_int_color][i] = StringToFloat(dataColor[i]);
		}
		

		IntToString(pSkin, skin, 11);
		
		DispatchKeyValue(index, "model", pModel);
		DispatchKeyValue(index, "Skin", skin);
		
		DispatchKeyValue(index, "rendermode", "5");
		DispatchKeyValue(index, "rendercolor", rendcol);
		DispatchKeyValue(index, "solid", "2");
		DispatchKeyValue(index, "disableshadows", "1");


		ActivateEntity( index );
		DispatchSpawn( index );
		
		SetEntPropVector( index, Prop_Send, "m_vecMins", g_flBlockData[index][float_mins]);
		SetEntPropVector( index, Prop_Send, "m_vecMaxs", g_flBlockData[index][float_maxs]);  
		SetEntProp(index, Prop_Send, "m_nSolidType", 2);

		TeleportEntity(index, pPos, pAng, NULL_VECTOR);

		Entity_MarkSurrBoundsDirty( index );
		SetEntityMoveType(index, MOVETYPE_NONE);


		g_iData[data_type][client] = pBlockType;
		g_iBlockType[index] = pBlockType;
		
		BlockType(client, index);
	}
	else if(StrContains(pClass, "weapon_", false) == 0){
		int wepid1 = GivePlayerItem(client, pClass);
		int wepid = GivePlayerItem(client, pClass);
		
		RemovePlayerItem(client, wepid);
		TeleportEntity(wepid, pPos, pAng, view_as<float>({0.0, 0.0, 0.0}));
		
		RemovePlayerItem(client, wepid1);
		RemoveEdict(wepid1);
		
		Format(rendcol, sizeof(rendcol), "%i %i %i", pCol[0], pCol[1], pCol[2]);
		DispatchKeyValue(wepid, "rendermode", "5");
		DispatchKeyValue(wepid, "rendercolor", rendcol);
		DispatchKeyValue(wepid, "disableshadows", "1");
		SetEntPropFloat(wepid,  Prop_Send, "m_flModelScale", pScale);
		DispatchKeyValue(wepid, "physdamagescale", "0.0");
	}
	else{
		bool isPhysics = true;
		
		if(StrContains(pClass, "prop_dynamic", false) == 0) {
			isPhysics = false;
		}	
		int index = -1;
		if ( isPhysics ) {
			index = CreateEntityByName("prop_physics_override");
		}
		else {
			index = CreateEntityByName("prop_dynamic_override");
		}
		
		if ( strlen( pModel ) != 0 ) {
			if ( !IsModelPrecached( pModel ) ) {
				int table = FindStringTable("modelprecache");
				int length = GetStringTableMaxStrings(table) - (GetStringTableNumStrings(table) + 24);
				if( length <= 0 ) {
					ReplyToCommand(client, "ERREUR, Impossible de mettre le model en cache aujourd'hui: Risque de crash élevé :(");
					return;
				}
				PrecacheModel( pModel );
			}
			SetEntityModel( index, pModel );
		}
		
		if ( !isPhysics ) {
			SetEntProp( index, Prop_Send, "m_nSolidType", 6 );
			SetEntProp( index, Prop_Send, "m_CollisionGroup", 5);
			SetEntityMoveType( index, MOVETYPE_VPHYSICS);
		}
		else {
			SetEntProp( index, Prop_Data, "m_spawnflags", 256 );
		}

		Format(rendcol, sizeof(rendcol), "%i %i %i", pCol[0], pCol[1], pCol[2]);
		DispatchKeyValue(index, "rendermode", "5");
		DispatchKeyValue(index, "rendercolor", rendcol);
		DispatchKeyValue(index, "disableshadows", "1");	
		DispatchKeyValue(index, "DisableBoneFollowers", "1");
		SetEntPropFloat(index,  Prop_Send, "m_flModelScale", pScale);
		DispatchKeyValue(index, "physdamagescale", "0.0");
		DispatchKeyValue(index, "health", "200");
		DispatchKeyValue(index,"m_takedamage", "2");
		
		DispatchKeyValueVector( index, "Origin", pPos );
		DispatchKeyValueVector( index, "Angles", pAng );
		
		DispatchSpawn( index );
		
		if ( !isPhysics ) {
			rp_AcceptEntityInput( index, "DisableCollision" );
			rp_AcceptEntityInput( index, "EnableCollision" );
			rp_AcceptEntityInput(index, "TurnOn");
		}
		else {
			rp_AcceptEntityInput(index, "EnableMotion");
			rp_AcceptEntityInput(index, "Wake");
		}
	}
}


void StripWeapons(int client ) {
	#if defined DEBUG
	PrintToServer("StripWeapons");
	#endif
	
	int wepIdx;
	
	for( int i = 0; i < 5; i++ ){
		if( i == CS_SLOT_KNIFE ) continue; 
		
		while( ( wepIdx = GetPlayerWeaponSlot( client, i ) ) != -1 ) {
			RemovePlayerItem( client, wepIdx );
			RemoveEdict( wepIdx );
		}
	}
	
	FakeClientCommand(client, "use weapon_fists");
}
