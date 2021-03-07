#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <smlib>
#include <emitsoundany>
#include <colors_csgo>
#include <dhooks>
#include <eItems>
#include <SteamWorks>

#include <custom_weapon_mod.inc>

#if USE_VSCRIPT == 1
#include <vscriptfun>
#endif

#pragma newdecls required

int g_iStackCount = 0;
int g_iStack[MAX_CWEAPONS][WSI_Max], g_iEntityData[MAX_ENTITIES][WSI_Max];
int g_aStack[MAX_CWEAPONS][WAA_Max][MAX_ANIMATION][3];
float g_fStack[MAX_CWEAPONS][WSF_Max], g_fEntityData[MAX_ENTITIES][WSF_Max];
Handle g_hStack[MAX_CWEAPONS][WSH_Max], g_hReloading[MAX_ENTITIES];
char g_sStack[MAX_CWEAPONS][WSS_Max][PLATFORM_MAX_PATH];
int g_cBlood[MAX_BLOOD], g_cScorch, g_cBullet[MAX_BULLET], g_cBeam;
int g_iClientZoom[65][4];
DataPack g_hProjectile[MAX_ENTITIES];

Handle g_hCSPlayer_GetPlayerMaxSpeed = INVALID_HANDLE;
bool g_bHasCustomWeapon[65], g_bInAttack3[65];
StringMap g_hNamedIdentified;

char g_szMuzzle[][PLATFORM_MAX_PATH] = {
	"weapon_muzzle_flash_assaultrifle",
	"weapon_muzzle_flash_autoshotgun",
	"weapon_muzzle_flash_awp",
	"weapon_muzzle_flash_huntingrifle",
	"weapon_muzzle_flash_para",
	"weapon_muzzle_flash_pistol", 
	"weapon_muzzle_flash_shotgun",
	"weapon_muzzle_flash_smg",
	"weapon_muzzle_flash_taser"
};
char g_szBullet[][PLATFORM_MAX_PATH] = {
	"weapon_shell_casing_50cal",
	"weapon_shell_casing_9mm",
	"weapon_shell_casing_candycorn",
	"weapon_shell_casing_rifle",
	"weapon_shell_casing_shotgun"
};
char g_szTracer[][PLATFORM_MAX_PATH] = {
	"weapon_tracers_50cal",
	"weapon_tracers_assrifle",
	"weapon_tracers_mach",
	"weapon_tracers_original",
	"weapon_tracers_pistol",
	"weapon_tracers_rifle",
	"weapon_tracers_shot",
	"weapon_tracers_smg",
	"weapon_tracers_taser"
};

#define ANIM_SEQ		0
#define	ANIM_FRAME		1
#define ANIM_FPS		2

#define ZOOM_DOING		0
#define ZOOM_DIRECTION	1
#define ZOOM_DESIRED	2
#define ZOOM_SPEED		3

#define DEG2RAD(%1)		(%1*3.14159265/180.0)
#define CAN_ATTACK(%1)  (!g_hReloading[%1] && g_fEntityData[%1][WSF_NextAttack] <= time)

// -----------------------------------------------------------------------------------------------------------------
//
//	PLUGIN START
//
public void OnPluginStart() {
	
	bool win = GameConfGetOffset(LoadGameConfigFile("core.games/common.games"), "GetDataDescMap") == 11 ? true : false;
	int offset = GameConfGetOffset(LoadGameConfigFile("sdktools.games/engine.csgo"), "CommitSuicide") + (win?MAXSPEED_DIFF_WIN:MAXSPEED_DIFF_LINUX);
	g_hCSPlayer_GetPlayerMaxSpeed = DHookCreate(offset, HookType_Entity, ReturnType_Float, ThisPointer_CBaseEntity, CCSPlayer_GetPlayerMaxSpeed);

	for (int i = 1; i < MaxClients; i++)
		if (IsClientInGame(i))
			OnClientPostAdminCheck(i);
	
	for (int i = 1; i < MAX_ENTITIES; i++)
		g_iEntityData[i][WSI_Identifier] = -1;
	
	
	RegAdminCmd("sm_cwm", Cmd_Spawn, ADMFLAG_ROOT);
//	RegConsoleCmd("sm_cwm", Cmd_Spawn);
	
	AddCommandListener(Cmd_LAW_Press, "+lookatweapon");
	AddCommandListener(Cmd_LAW_Release, "-lookatweapon");
	
	LoadTranslations("common.phrases");
	
	g_hNamedIdentified = new StringMap();
}

public void OnMapStart() {
	char tmp[PLATFORM_MAX_PATH];
	for (int i = 0; i < MAX_BLOOD; i++) {
		Format(tmp, sizeof(tmp), "decals/blood%d.vtf", i + 1); // vtf ? 
		g_cBlood[i] = PrecacheDecal(tmp);
	}
	for (int i = 0; i < MAX_BULLET; i++) {
		Format(tmp, sizeof(tmp), "decals/brick/brick%d.vmt", i + 1);
		g_cBullet[i] = PrecacheDecal(tmp);
	}
	
	for (int i = 0; i < sizeof(g_szBullet); i++)
		PrecacheParticleSystem(g_szBullet[i]);
	for (int i = 0; i < sizeof(g_szMuzzle); i++)
		PrecacheParticleSystem(g_szMuzzle[i]);
	for (int i = 0; i < sizeof(g_szTracer); i++)
		PrecacheParticleSystem(g_szTracer[i]);
	
	PrecacheEffect("Impact");
	PrecacheEffect("ParticleEffect");
	
	g_cScorch = PrecacheDecal("decals/scorch1.vtf");
	g_cBeam = PrecacheModel("materials/sprites/laserbeam.vmt");
	
	if( g_cBeam ) { } // This is mostly for debug propuse. So we might need to remove this warning.
	
	PrecacheSound("weapons/clipempty_rifle.wav");
	PrecacheSound("weapons/sg556/sg556_draw.wav");
	
	for (int i = 0; i < g_iStackCount; i++) {
		g_iStack[i][WSI_VModel] = PrecacheModel(g_sStack[i][WSS_VModel]);
		g_iStack[i][WSI_WModel] = PrecacheModel(g_sStack[i][WSS_WModel]);
		
		Format(tmp, sizeof(tmp), "materials/panorama/images/icons/equipment/%s.svg", g_sStack[i][WSS_Name]);
		if( FileExists(tmp) )
			AddFileToDownloadsTable(tmp);
	}
}
public APLRes AskPluginLoad2(Handle hPlugin, bool isAfterMapLoaded, char[] error, int err_max) {
	RegPluginLibrary("CustomWeaponMod");
	
	CreateNative("CWM_Create", Native_CWM_Create);
	
	CreateNative("CWM_SetInt", Native_CWM_SetInt);
	CreateNative("CWM_GetInt", Native_CWM_GetInt);
	CreateNative("CWM_SetEntityInt", Native_CWM_SetEntityInt);
	CreateNative("CWM_GetEntityInt", Native_CWM_GetEntityInt);
	
	CreateNative("CWM_SetFloat", Native_CWM_SetFloat);
	CreateNative("CWM_GetFloat", Native_CWM_GetFloat);
	CreateNative("CWM_SetEntityFloat", Native_CWM_SetEntityFloat);
	CreateNative("CWM_GetEntityFloat", Native_CWM_GetEntityFloat);
	
	CreateNative("CWM_RegHook", Native_CWM_RegHook);
	
	CreateNative("CWM_AddAnimation", Native_CWM_AddAnimation);
	CreateNative("CWM_RunAnimation", Native_CWM_RunAnimation);
	CreateNative("CWM_RunAnimationSound", Native_CWM_RunAnimationSound);
	
	CreateNative("CWM_Spawn", Native_CWM_Spawn);
	
	CreateNative("CWM_ShootProjectile", Native_CWM_ShootProjectile);
	CreateNative("CWM_ShootDamage", Native_CWM_ShootDamage);
	CreateNative("CWM_ShootHull", Native_CWM_ShootHull);
	CreateNative("CWM_ShootRay", Native_CWM_ShootRay);
	CreateNative("CWM_ShootExplode", Native_CWM_ShootExplode);
	
	CreateNative("CWM_GetId", Native_CWM_GetId);
	CreateNative("CWM_RefreshHUD", Native_CWM_RefreshHUD);
	CreateNative("CWM_IsCustom", Native_CWM_IsCustom);
	CreateNative("CWM_GetName", Native_CWM_GetName);
	
	CreateNative("CWM_ZoomIn", Native_CWM_ZoomIn);
	CreateNative("CWM_ZoomOut", Native_CWM_ZoomOut);
	CreateNative("CWM_ShellOut", Native_CWM_ShellOut);
	
	CreateNative("CWM_LookupAttachment", Native_CWM_LookupAttachment);
	
	ServerCommand("sm_cwm_reload");
}
// -----------------------------------------------------------------------------------------------------------------
//
//	Admin commands
//
public Action Cmd_Spawn(int client, int args) {
	char tmp[64], tmp2[64], tmp3[MAX_TARGET_LENGTH];
	float pos[3], ang[3];
	GetCmdArg(1, tmp, sizeof(tmp));
	GetCmdArg(2, tmp2, sizeof(tmp2));
	
	
	if (args <= 0) {
		menu_Open(client);
		return Plugin_Handled;
	}	
	
	int id;
	if (g_hNamedIdentified.GetValue(tmp, id)) {
		
		if( args >= 2 ) {
			
			if (StrContains(tmp2, "#") == 0 ) {
				ReplaceString(tmp2, sizeof(tmp2), "#", "");
				int target = GetClientOfUserId(StringToInt(tmp2));
				if( IsValidClient(target) )
					CWM_Spawn(id, target, pos, ang);
			}
			else if( IsValidClient(StringToInt(tmp2)) ) {
				CWM_Spawn(id, StringToInt(tmp2), pos, ang);
			}
			else {
				int target_list[MAXPLAYERS], target_count; bool tn_is_ml;
				if ( (target_count = ProcessTargetString(tmp2, client, target_list, MAXPLAYERS,
					COMMAND_FILTER_ALIVE|COMMAND_FILTER_NO_IMMUNITY, tmp3, sizeof(tmp3), tn_is_ml)) <= 0) {
					ReplyToTargetError(client, target_count);
					return Plugin_Handled;
				}
				
				for (int i = 0; i < target_count; i++)
					CWM_Spawn(id, target_list[i], pos, ang);
			}
		}
		else if (client > 0) {
			GetClientAimedLocation(client, pos, ang);
			ang[0] = ang[2] = 0.0;
			ang[1] += 180.0;
			CWM_Spawn(id, 0, pos, ang);
		}
	}
	return Plugin_Handled;
}
void menu_Open(int client, int start = 0) {
	Menu menu = CreateMenu(menu_Spawn);
	menu.SetTitle("Que voulez-vous spawn?");
	for (int i = 0; i < g_iStackCount; i++) {
		menu.AddItem(g_sStack[i][WSS_Name], g_sStack[i][WSS_Fullname]);
	}
	menu.DisplayAt(client, start, MENU_TIME_FOREVER);
}
public int menu_Spawn(Handle handler, MenuAction action, int client, int param) {
	if (action == MenuAction_Select) {
		char item[32];
		GetMenuItem(handler, param, item, sizeof(item));
		ClientCommand(client, "sm_cwm %s #%d", item, GetClientUserId(client));
		menu_Open(client, GetMenuSelectionPosition());
	}
	else if (action == MenuAction_End) {
		CloseHandle(handler);
	}
}
// -----------------------------------------------------------------------------------------------------------------
//
//	Native
//
public int Native_CWM_GetId(Handle plugin, int numParams) {
	static char tmp[PLATFORM_MAX_PATH];
	GetNativeString(1, tmp, sizeof(tmp));
	
	int id;
	if (g_hNamedIdentified.GetValue(tmp, id))
		return id;
	return -1;
}
public int Native_CWM_Create(Handle plugin, int numParams) {
	static char tmp[PLATFORM_MAX_PATH];
	GetNativeString(2, tmp, sizeof(tmp));
	
	int id;
	if( !g_hNamedIdentified.GetValue(tmp, id) )
		id = g_iStackCount++;
	else {
		PrintToServer("[CWM] Warning: same weapon already exist. Overriding.");
		for (int i = 0; i < sizeof(g_aStack[]); i++)
			g_aStack[id][i][0][0] = 0;
	}
		
	GetNativeString(1, g_sStack[id][WSS_Fullname], PLATFORM_MAX_PATH);
	GetNativeString(2, g_sStack[id][WSS_Name], PLATFORM_MAX_PATH);
	GetNativeString(3, g_sStack[id][WSS_ReplaceWeapon], PLATFORM_MAX_PATH);
	GetNativeString(4, g_sStack[id][WSS_VModel], PLATFORM_MAX_PATH);
	GetNativeString(5, g_sStack[id][WSS_WModel], PLATFORM_MAX_PATH);
	
	g_iStack[id][WSI_VModel] = PrecacheModel(g_sStack[id][WSS_VModel]);
	g_iStack[id][WSI_WModel] = PrecacheModel(g_sStack[id][WSS_WModel]);
	Format(tmp, sizeof(tmp), "materials/panorama/images/icons/equipment/%s.svg", g_sStack[id][WSS_Name]);
	if( FileExists(tmp) )
		AddFileToDownloadsTable(tmp);
	
	g_iStack[id][WSI_AttackBulletType] = g_iStack[id][WSI_Attack2BulletType] = g_iStack[id][WSI_Attack3BulletType] = view_as<int>(WSB_Primary);
	
	view_as<Handle>(g_hStack[id][WSH_Draw]) = CreateForward(ET_Hook, Param_Cell, Param_Cell);
	view_as<Handle>(g_hStack[id][WSH_Attack]) = CreateForward(ET_Hook, Param_Cell, Param_Cell);
	view_as<Handle>(g_hStack[id][WSH_AttackPost]) = CreateForward(ET_Hook, Param_Cell, Param_Cell);
	view_as<Handle>(g_hStack[id][WSH_Attack2]) = CreateForward(ET_Hook, Param_Cell, Param_Cell);
	view_as<Handle>(g_hStack[id][WSH_Attack3]) = CreateForward(ET_Hook, Param_Cell, Param_Cell);
	view_as<Handle>(g_hStack[id][WSH_Reload]) = CreateForward(ET_Hook, Param_Cell, Param_Cell);
	view_as<Handle>(g_hStack[id][WSH_Idle]) = CreateForward(ET_Hook, Param_Cell, Param_Cell);
	view_as<Handle>(g_hStack[id][WSH_Empty]) = CreateForward(ET_Hook, Param_Cell, Param_Cell);	
	
	g_hNamedIdentified.SetValue(g_sStack[id][WSS_Name], id);
	return id++;
}
public int Native_CWM_RunAnimationSound(Handle plugin, int numParams) {
	char tmp[PLATFORM_MAX_PATH];
	int entity = GetNativeCell(1);
	int id = g_iEntityData[entity][WSI_Identifier];
	int client = g_iEntityData[entity][WSI_Owner];
	
	if (id == -1)
		return;
	
	int anim = GetNativeCell(2);
	GetNativeString(3, tmp, sizeof(tmp));
	int frame = GetNativeCell(4);	
	
	float timer = (frame / float(g_aStack[id][anim][1][ANIM_FRAME])) * g_fEntityData[entity][WSF_AnimationSpeed];
	
	Handle dp;
	CreateDataTimer(timer, Timer_CWM_RunAnimationSound, dp, TIMER_DATA_HNDL_CLOSE);
	WritePackCell(dp, entity);
	WritePackCell(dp, client);
	WritePackCell(dp, g_iEntityData[entity][WSI_Animation]);
	WritePackString(dp, tmp);
	
}
public Action Timer_CWM_RunAnimationSound(Handle timer, Handle dp) {
	char tmp[PLATFORM_MAX_PATH];
	ResetPack(dp);
	int entity = ReadPackCell(dp);
	int client = ReadPackCell(dp);
	int anim = ReadPackCell(dp);
	
	if( g_iEntityData[entity][WSI_Owner] != client )
		return Plugin_Stop;
	
	if( anim != g_iEntityData[entity][WSI_Animation] ) // TODO: Save WSI_AnimationType
		return Plugin_Stop;
	
	ReadPackString(dp, tmp, sizeof(tmp));
	EmitSoundToAllAny(tmp, client, SNDCHAN_WEAPON);
	
	return Plugin_Stop;
}
public int Native_CWM_RunAnimation(Handle plugin, int numParams) {
	int entity = GetNativeCell(1);
	int id = g_iEntityData[entity][WSI_Identifier];
	int client = g_iEntityData[entity][WSI_Owner];
	
	if (id == -1)
		return;
	
	int anim = GetNativeCell(2);
	float time = GetNativeCell(3);
	int rnd = GetNativeCell(4);
	
	if( rnd < 0 ) {
		
		if( g_aStack[id][anim][0][0] > 1 ) {
			
			rnd = Math_GetRandomInt(1, g_aStack[id][anim][0][0]);
			
			if( g_aStack[id][anim][rnd][ANIM_SEQ] == g_iEntityData[entity][WSI_Animation] )
				rnd = 1 + (rnd % g_aStack[id][anim][0][0]);
		}
		else
			rnd = 1;
	}
	
	float factor;
	float duration = g_aStack[id][anim][rnd][ANIM_FRAME] / float(g_aStack[id][anim][rnd][ANIM_FPS]);
	
	if( time <= 0.0 ) {
		time = duration;
		factor = 1.0;
	}
	else {
		factor = duration / time;
	}
	
	g_iEntityData[entity][WSI_Animation] = g_aStack[id][anim][rnd][ANIM_SEQ];
	g_fEntityData[entity][WSF_NextIdle] = GetGameTime() + time;
	g_fEntityData[entity][WSF_AnimationSpeed] = time;
	
	CWM_Animation(client, entity, factor);
}
public int Native_CWM_AddAnimation(Handle plugin, int numParams) {
	int id = GetNativeCell(1);
	int data = GetNativeCell(2);
	int cpt = g_aStack[id][data][0][ANIM_SEQ] + 1;
	
	g_aStack[id][data][cpt][ANIM_SEQ] = GetNativeCell(3);
	g_aStack[id][data][cpt][ANIM_FRAME] = GetNativeCell(4);
	g_aStack[id][data][cpt][ANIM_FPS] = GetNativeCell(5);
	
	g_aStack[id][data][0][0] = cpt;
}
public int Native_CWM_SetInt(Handle plugin, int numParams) {
	g_iStack[GetNativeCell(1)][GetNativeCell(2)] = GetNativeCell(3);
	return 1;
}
public int Native_CWM_SetEntityInt(Handle plugin, int numParams) {
	g_iEntityData[GetNativeCell(1)][GetNativeCell(2)] = GetNativeCell(3);
	return 1;
}
public int Native_CWM_GetEntityInt(Handle plugin, int numParams) {
	return g_iEntityData[GetNativeCell(1)][GetNativeCell(2)];
}
public int Native_CWM_GetInt(Handle plugin, int numParams) {
	return g_iStack[GetNativeCell(1)][GetNativeCell(2)];
}
public int Native_CWM_SetFloat(Handle plugin, int numParams) {
	g_fStack[GetNativeCell(1)][GetNativeCell(2)] = GetNativeCell(3);
	return 1;
}
public int Native_CWM_SetEntityFloat(Handle plugin, int numParams) {
	g_fEntityData[GetNativeCell(1)][GetNativeCell(2)] = GetNativeCell(3);
	return 1;
}
public int Native_CWM_GetEntityFloat(Handle plugin, int numParams) {
	return view_as<int>(g_fEntityData[GetNativeCell(1)][GetNativeCell(2)]);
}
public int Native_CWM_GetFloat(Handle plugin, int numParams) {
	return view_as<int>(g_fStack[GetNativeCell(1)][GetNativeCell(2)]);
}
public int Native_CWM_RegHook(Handle plugin, int numParams) {
	AddToForward(g_hStack[GetNativeCell(1)][GetNativeCell(2)], plugin, GetNativeFunction(3));
}
public int Native_CWM_Spawn(Handle plugin, int numParams) {
	float pos[3], ang[3];
	int id = GetNativeCell(1);
	int target = GetNativeCell(2);
	GetNativeArray(3, pos, sizeof(pos));
	GetNativeArray(4, ang, sizeof(ang));
	
#if CSGO_FIX_SPAWN == 1
	int sClient[65], sCount;
	for (int i = 1; i <= MaxClients; i++) {
		if( !IsValidClient(i) )
			continue;
		sClient[sCount++] = i;
	}
	
	int player = sClient[GetRandomInt(0, sCount - 1)];
	int wepid1 = GivePlayerItem(player, g_sStack[id][WSS_ReplaceWeapon]);
	int entity = GivePlayerItem(player, g_sStack[id][WSS_ReplaceWeapon]);
	RemovePlayerItem(player, entity);
	RemovePlayerItem(player, wepid1);
	RemoveEdict(wepid1);
#else
	int entity = CreateEntityByName(g_sStack[id][WSS_ReplaceWeapon]);
	DispatchKeyValue(entity, "classname", g_sStack[id][WSS_ReplaceWeapon]);
	DispatchKeyValue(entity, "CanBePickedUp", "1");
	DispatchSpawn(entity);
#endif

#if CSGO_RENAME_WEAPON == 1
	SetEntDataString(entity, FindSendPropInfo("CBaseAttributableItem", "m_szCustomName"), g_sStack[id][WSS_Fullname], 128);
#endif

#if CSGO_FIX_STARTRAK == 1
	SetEntData(entity, FindSendPropInfo("CBaseAttributableItem", "m_iItemIDLow"), -1);
	SetEntData(entity, FindSendPropInfo("CBaseAttributableItem", "m_nFallbackPaintKit"), GetRandomInt(1, 2048));
	SetEntData(entity, FindSendPropInfo("CBaseAttributableItem", "m_nFallbackStatTrak"), -1);
	
	SetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex", eItems_GetWeaponDefIndexByClassName(g_sStack[id][WSS_ReplaceWeapon]));
#endif

	SetEntityModel(entity, g_sStack[id][WSS_WModel]);
	TeleportEntity(entity, pos, ang, NULL_VECTOR);
	
	g_fEntityData[entity][WSF_LastReload] = GetGameTime();
	g_fEntityData[entity][WSF_NextAttack] = GetGameTime();
	g_iEntityData[entity][WSI_ShotFired] = 0;
	g_iEntityData[entity][WSI_Identifier] = id;
	
	g_iEntityData[entity][WSI_AttackDamage] = g_iStack[id][WSI_AttackDamage];
	
	g_iEntityData[entity][WSI_Bullet] = g_iStack[id][WSI_MaxBullet];
	g_iEntityData[entity][WSI_Ammunition] = g_iStack[id][WSI_MaxAmmunition];
	g_iEntityData[entity][WSI_MaxBullet] = g_iStack[id][WSI_MaxBullet];
	g_iEntityData[entity][WSI_MaxAmmunition] = g_iStack[id][WSI_MaxAmmunition];
	
	g_iEntityData[entity][WSI_Bullet2] = g_iStack[id][WSI_MaxBullet2];
	g_iEntityData[entity][WSI_Ammunition2] = g_iStack[id][WSI_MaxAmmunition2];
	g_iEntityData[entity][WSI_MaxBullet2] = g_iStack[id][WSI_MaxBullet];
	g_iEntityData[entity][WSI_MaxAmmunition2] = g_iStack[id][WSI_MaxAmmunition];
	
	g_iEntityData[entity][WSI_AttackType] = g_iStack[id][WSI_AttackType];
	g_iEntityData[entity][WSI_Attack2Type] = g_iStack[id][WSI_Attack2Type];
	g_iEntityData[entity][WSI_Attack3Type] = g_iStack[id][WSI_Attack3Type];
	
	g_iEntityData[entity][WSI_Slot] = g_iStack[id][WSI_Slot];
	g_fEntityData[entity][WSF_Speed] = g_fStack[id][WSF_Speed];
	g_hReloading[entity] = INVALID_HANDLE;	
	
	if (IsValidClient(target)) {
		Client_EquipWeapon(target, entity, true);
		QueryClientConVar(target, "viewmodel_offset_x", view_as<ConVarQueryFinished>(ClientConVar), target);
		QueryClientConVar(target, "viewmodel_offset_y", view_as<ConVarQueryFinished>(ClientConVar), target);
		QueryClientConVar(target, "viewmodel_offset_z", view_as<ConVarQueryFinished>(ClientConVar), target);
	}
	

	if (Weapon_GetOwner(entity) > 0)
		OnClientWeaponSwitch(Weapon_GetOwner(entity), entity);
	
#if SLOT_REDIRECT == 1
	CreateTimer(2.0, CWM_Spawn_Post, entity);
#endif

}
public Action CWM_Spawn_Post(Handle timer, any entity) {
	int id = g_iEntityData[entity][WSI_Identifier];
	
	char tmp[PLATFORM_MAX_PATH];
	switch(g_iStack[id][WSI_Slot]) {
		case CS_SLOT_PRIMARY: {
			strcopy(tmp, sizeof(tmp), "weapon_negev");
		}
		case CS_SLOT_SECONDARY: {
			strcopy(tmp, sizeof(tmp), "weapon_deagle");
		}
		case CS_SLOT_KNIFE: {
			strcopy(tmp, sizeof(tmp), "weapon_knife");
		}
		case CS_SLOT_GRENADE: {
			strcopy(tmp, sizeof(tmp), "weapon_hegrenade");
		}
		case CS_SLOT_C4: {
			strcopy(tmp, sizeof(tmp), "weapon_c4");
		}
	}
	
	if( id >= 0 )
		SetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex", eItems_GetWeaponDefIndexByClassName(tmp));
} 
public int Native_CWM_ShootHull(Handle plugin, int numParams) {
	float src[3], ang[3], hit[3], dst[3], min[3], max[3];
	int client = GetNativeCell(1);
	int wpnid = GetNativeCell(2);
	float size = GetNativeCell(3);
	GetNativeArray(4, hit, sizeof(hit));
	
	int id = g_iEntityData[wpnid][WSI_Identifier];
	
	GetClientEyePosition(client, src);
	GetClientEyeAngles(client, ang);
	ang[0] += GetRandomFloat(-g_fStack[id][WSF_Spread], g_fStack[id][WSF_Spread]);
	ang[1] += GetRandomFloat(-g_fStack[id][WSF_Spread], g_fStack[id][WSF_Spread]);
	GetAngleVectors(ang, dst, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(dst, 10000.0);
	AddVectors(src, dst, dst);
	
	for (int i = 0; i < 3; i++) {
		min[i] = -size;
		max[i] =  size;
	}
	
	int target;
	Handle trace = TR_TraceHullFilterEx(src, dst, min, max, MASK_SHOT, TraceEntityFilterSelf, client);

	if (TR_DidHit(trace)) {
		TR_GetEndPosition(hit, trace);
		target = TR_GetEntityIndex(trace);

		if (GetVectorDistance(src, hit) < g_fStack[id][WSF_AttackRange]) {

			if (IsBreakable(target)) {
				
				Entity_Hurt(target, g_iEntityData[wpnid][WSI_AttackDamage], client, DMG_CRUSH|DMG_SLASH, g_sStack[id][WSS_Name]);
				
				if (IsValidClient(target)) {
					TE_SetupBloodSprite(hit, view_as<float>( { 0.0, 0.0, 0.0 } ), { 255, 0, 0, 255 }, 16, 0, 0);
					TE_SendToAll();
					
					Entity_GetGroundOrigin(target, dst);
					TE_SetupWorldDecal(dst, g_cBlood[GetRandomInt(0, MAX_BLOOD - 1)]);
					TE_SendToAll();
				}
			}
			else
				target = 0;
		}
		else
			target = -1;
	}
	
	delete trace;
	if (target >= 0)
		SetNativeArray(4, hit, sizeof(hit));
	return target;
}
public int Native_CWM_ShootRay(Handle plugin, int numParams) {
	static float src[3], ang[3], hit[3], dst[3], nor[3];
	int client = GetNativeCell(1);
	int wpnid = GetNativeCell(2);
	GetNativeArray(3, hit, sizeof(hit));
	
	int id = g_iEntityData[wpnid][WSI_Identifier];
	
	GetClientEyePosition(client, src);
	GetClientEyeAngles(client, ang);
	GetEntPropVector(client, Prop_Send, "m_aimPunchAngleVel", nor);
	float penality = GetEntPropFloat(wpnid, Prop_Send, "m_fAccuracyPenalty") * 8.0;
	
	ang[0] += GetRandomFloat(-g_fStack[id][WSF_Spread], g_fStack[id][WSF_Spread]) * penality + (nor[0]/10.0)*2.0;
	ang[1] += GetRandomFloat(-g_fStack[id][WSF_Spread], g_fStack[id][WSF_Spread]) * penality + (nor[1]/10.0)*2.0;
	
	int target;
	Handle trace = TR_TraceRayFilterEx(src, ang, MASK_SHOT, RayType_Infinite, TraceEntityFilterSelf, client);

	if (TR_DidHit(trace)) {
		TR_GetEndPosition(hit, trace);
		TR_GetPlaneNormal(trace, nor);
		target = TR_GetEntityIndex(trace);
		int hitbox = TR_GetHitGroup(trace);
		
		
		if (GetVectorDistance(src, hit) < g_fStack[id][WSF_AttackRange]) {
			 
			TE_Start("Entity Decal");
			TE_WriteNum("m_nEntity", target > 0 ? target : 0);
			TE_WriteVector("m_vecOrigin", hit);
			TE_WriteVector("m_vecStart", src);
			TE_WriteNum("m_nIndex", g_cBullet[GetRandomInt(0, MAX_BULLET - 1)]);
			TE_SendToAll();
			
			if( IsMoveable(target) ) {
				float physcale = 8.0; // TODO: Use cvar: phys_pushscale
				SubtractVectors(hit, src, nor);
				NormalizeVector(nor, nor);
				ScaleVector(nor, float(g_iEntityData[wpnid][WSI_AttackDamage]) * physcale);
				TeleportEntity(target, NULL_VECTOR, NULL_VECTOR, nor);
			}
			
			if (IsBreakable(target)) {
				
				Entity_Hurt(target, g_iEntityData[wpnid][WSI_AttackDamage], client, DMG_CRUSH, g_sStack[id][WSS_Name]);
				
				if (IsValidClient(target)) {
					TE_SetupBloodSprite(hit, nor, { 255, 0, 0, 255 }, 16, 0, 0);
					TE_SendToAll();
					
					Entity_GetGroundOrigin(target, dst);
					TE_SetupWorldDecal(dst, g_cBlood[GetRandomInt(0, MAX_BLOOD - 1)]);
					TE_SendToAll();
				}
				else {
					TE_SetupBloodSprite(hit, nor, { 0, 0, 0, 255 }, 16, 0, 0);
					TE_SendToAll();
				}
			}
			else {				
				TE_Start("EffectDispatch");
				TE_WriteFloatArray("m_vOrigin.x", hit, 3);
				TE_WriteFloatArray("m_vStart.x", src, 3);
				TE_WriteNum("m_nHitBox", hitbox);
				TE_WriteNum("m_nSurfaceProp", 0);
				TE_WriteNum("m_nDamageType", DMG_CRUSH);
				TE_WriteNum("entindex", target);
				TE_WriteNum("m_iEffectName", GetEffectIndex("Impact"));
				TE_SendToAll();
				target = 0;
			}
			
		}
		else
			target = -1;
	}
	
	delete trace;
	if (target >= 0)
		SetNativeArray(3, hit, sizeof(hit));
	return target;
}
public int Native_CWM_ShootDamage(Handle plugin, int numParams) {
	static float hit[3];
	int client = GetNativeCell(1);
	int wpnid = GetNativeCell(2);
	int target = GetNativeCell(3);
	GetNativeArray(4, hit, sizeof(hit));
	
	int id = g_iEntityData[wpnid][WSI_Identifier];
	
	if (IsBreakable(target)) {
		Entity_Hurt(target, g_iEntityData[wpnid][WSI_AttackDamage], client, DMG_CRUSH, g_sStack[id][WSS_Name]);
		
		if (IsValidClient(target)) {
			TE_SetupBloodSprite(hit, view_as<float>( { 0.0, 0.0, 0.0 } ), { 255, 0, 0, 255 }, 16, 0, 0);
			TE_SendToAll();
					
			Entity_GetGroundOrigin(target, hit);
			TE_SetupWorldDecal(hit, g_cBlood[GetRandomInt(0, MAX_BLOOD - 1)]);
			TE_SendToAll();
		}
	}
	
	return target;
}
public int Native_CWM_ShootExplode(Handle plugin, int numParams) {
	int client = GetNativeCell(1);
	int wpnid = GetNativeCell(2);
	int entity = GetNativeCell(3);
	float radius = view_as<float>(GetNativeCell(4));
	int id = g_iEntityData[wpnid][WSI_Identifier];
	float falloff = float(g_iEntityData[wpnid][WSI_AttackDamage]) / radius;
	float src[3], dst[3], distance, min[3], max[3], hit[3], fraction;
	Handle tr;
	Entity_GetAbsOrigin(entity, src);
	
	TE_Start("World Decal");
	TE_WriteVector("m_vecOrigin", src);
	TE_WriteNum("m_nIndex", g_cScorch);
	TE_SendToAll();
	
	int MTRACE = 8;
	
	for (int i = 1; i <= MAX_ENTITIES; i++) {
		if (!IsValidEdict(i) || !IsValidEntity(i))
			continue;
		if (!IsBreakable(i))
			continue;
		if (IsValidClient(i) && !IsPlayerAlive(i))
			continue;
		
		Entity_GetAbsOrigin(i, dst);
		distance = view_as<float>(Math_Min(1.0, GetVectorDistance(src, dst)));
		if (distance > radius)
			continue;
		
		Entity_GetMinSize(i, min);
		Entity_GetMaxSize(i, max);
		fraction = 0.0;
		
		for (int j = 0; j < MTRACE; j++) {
			
			for (int k = 0; k <= 2; k++)
			hit[k] = dst[k] + GetRandomFloat(min[k], max[k]);
			
			
			tr = TR_TraceRayFilterEx(src, hit, MASK_SHOT, RayType_EndPoint, TraceEntityFilterSelf, entity);
			
			if (TR_DidHit(tr)) {
				fraction += TR_GetFraction(tr);
				if (TR_GetEntityIndex(tr) == i) {
					TE_SetupBloodSprite(hit, view_as<float>( { 0.0, 0.0, 0.0 } ), { 255, 0, 0, 255 }, 16, 0, 0);
					TE_SendToAll();
				}
			}
			else {
				fraction += 1.0;
				TE_SetupBloodSprite(hit, view_as<float>( { 0.0, 0.0, 0.0 } ), { 255, 0, 0, 255 }, 16, 0, 0);
				TE_SendToAll();
			}
			delete tr;
		}
		
		float damage = (fraction / float(MTRACE)) * (radius - distance) * falloff;
		if (damage > 0.0) {
			Entity_Hurt(i, RoundToCeil(damage), client, DMG_BLAST, g_sStack[id][WSS_Name]);
		}
	}
	
	
	return 1;
}
public int Native_CWM_ShootProjectile(Handle plugin, int numParams) {
	char name[32], model[PLATFORM_MAX_PATH];
	int client = GetNativeCell(1);
	int entity = GetNativeCell(2);
	GetNativeString(3, model, sizeof(model));
	GetNativeString(4, name, sizeof(name));
	float spreadAngle = view_as<float>(GetNativeCell(5));
	float speed = view_as<float>(GetNativeCell(6));
	Function callback = GetNativeFunction(7);
	
	int ent = CreateEntityByName("hegrenade_projectile");
	DispatchKeyValue(ent, "classname", name);
	DispatchSpawn(ent);
	
	SetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity", client);
	SetEntPropFloat(ent, Prop_Send, "m_flElasticity", 0.4);
	SetEntityMoveType(ent, MOVETYPE_FLYGRAVITY);
	
	Entity_SetSolidType(ent, SOLID_VPHYSICS);
	Entity_SetSolidFlags(ent, FSOLID_TRIGGER);
	Entity_SetCollisionGroup(ent, COLLISION_GROUP_PLAYER);	
	
	if (!StrEqual(model, NULL_MODEL)) {
		if (!IsModelPrecached(model))
			PrecacheModel(model);
		SetEntityModel(ent, model);
	}
	else
		SetEntityRenderMode(ent, RENDER_NONE);
	
	float vecOrigin[3], vecAngles[3], vecDir[3], vecPush[3];
	
	GetClientEyePosition(g_iEntityData[entity][WSI_Owner], vecOrigin);
	GetClientEyeAngles(g_iEntityData[entity][WSI_Owner], vecAngles);
	
	vecAngles[0] += GetRandomFloat(-spreadAngle, spreadAngle);
	vecAngles[1] += GetRandomFloat(-spreadAngle, spreadAngle);
	
	GetAngleVectors(vecAngles, vecPush, NULL_VECTOR, NULL_VECTOR);
	GetAngleVectors(vecAngles, vecDir, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(vecPush, RANGE_MELEE - 16.0);
	ScaleVector(vecDir, speed);
	
	
	float delta[3] =  { 32.0, -4.0, -12.0 };
	Math_RotateVector(delta, vecAngles, delta);
	vecOrigin[0] += delta[0];
	vecOrigin[1] += delta[1];
	vecOrigin[2] += delta[2];
	
	if (g_hProjectile[ent])
		delete g_hProjectile[ent];
	g_hProjectile[ent] = new DataPack();
	g_hProjectile[ent].WriteCell(client);
	g_hProjectile[ent].WriteCell(entity);
	g_hProjectile[ent].WriteCell(plugin);
	g_hProjectile[ent].WriteFunction(callback);
	
	TeleportEntity(ent, vecOrigin, vecAngles, vecDir);
	SDKHook(ent, SDKHook_StartTouch, CWM_ProjectileTouch);
	return ent;
}
public int Native_CWM_RefreshHUD(Handle plugin, int numParams) {
	CWM_Refresh(GetNativeCell(1), GetNativeCell(2));
}
public int Native_CWM_IsCustom(Handle plugin, int numParams) {
	int entity = GetNativeCell(1);
	return view_as<int>(g_iEntityData[entity][WSI_Identifier] >= 0);
}
public int Native_CWM_GetName(Handle plugin, int numParams) {
	int id = GetNativeCell(1);
	SetNativeString(2, g_sStack[id][WSS_Name], sizeof(g_sStack[][]));
}
public int Native_CWM_ZoomIn(Handle plugin, int numParams) {
	int client = GetNativeCell(1);
	
	g_iClientZoom[client][ZOOM_DIRECTION] = -1;
	g_iClientZoom[client][ZOOM_DOING] = GetNativeCell(2);
	g_iClientZoom[client][ZOOM_DESIRED] = GetNativeCell(3);
	g_iClientZoom[client][ZOOM_SPEED] = GetNativeCell(4);
	
	int hud = GetEntProp(client, Prop_Send, "m_iHideHUD");
	SetEntProp(client, Prop_Send, "m_iHideHUD", hud|HIDEHUD_CROSSHAIR);
}
public int Native_CWM_ZoomOut(Handle plugin, int numParams) {
	int client = GetNativeCell(1);
	
	g_iClientZoom[client][ZOOM_DIRECTION] = 1;
	g_iClientZoom[client][ZOOM_DOING] = GetNativeCell(2);
	g_iClientZoom[client][ZOOM_DESIRED] = GetNativeCell(3);
	g_iClientZoom[client][ZOOM_SPEED] = GetNativeCell(4);
	
	int hud = GetEntProp(client, Prop_Send, "m_iHideHUD");
	SetEntProp(client, Prop_Send, "m_iHideHUD", hud&~HIDEHUD_CROSSHAIR);
}
public int Native_CWM_ShellOut(Handle plugin, int numParams) {
	static float hit[3];
	
	int client = GetNativeCell(1);
	int wpnid = GetNativeCell(2);
	int muzzle = GetNativeCell(3);
	int bullet = GetNativeCell(4);
	int tracer = GetNativeCell(5);
	GetNativeArray(6, hit, sizeof(hit));
	bool right = view_as<bool>(GetNativeCell(7));
	bool left = view_as<bool>(GetNativeCell(8));
	
	int idx;
	int view = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
	int world = GetEntPropEnt(wpnid, Prop_Send, "m_hWeaponWorldModel");
	
	if( view <= 0 || world <= 0 )
		return 0;
	
	int pCount = 0, pPlayers[65];
	for (int i = 1; i < MaxClients; i++)
		if( IsValidClient(i) && i != client )
			pPlayers[pCount++] = i;
	
	
	int tracerId = CreateEntityByName("info_particle_system");
	DispatchKeyValue(tracerId, "OnUser1", "!self,KillHierarchy,,0.01,-1");
	DispatchSpawn(tracerId);
	TeleportEntity(tracerId, hit, NULL_VECTOR, NULL_VECTOR);
	AcceptEntityInput(tracerId, "FireUser1");
	
	if( right ) {
		
		if( muzzle > 0 ) {
			idx = CWM_LookupAttachment(view, "rw_muzzle");
			if( idx > 0 ) {
				TE_SetupEffect(g_szMuzzle[muzzle - 1], view, idx);
				TE_SendToClient(client);
			}
			idx = CWM_LookupAttachment(world, "muzzle_flash");
			if( idx > 0 ) {
				TE_SetupEffect(g_szMuzzle[muzzle - 1], world, idx);
				TE_Send(pPlayers, pCount);
			}
		}
		if( bullet > 0 ) {
			idx = CWM_LookupAttachment(view, "rw_bullet");
			if( idx > 0 ) {
				TE_SetupEffect(g_szBullet[bullet - 1], view, idx);
				TE_SendToClient(client);
			}
			idx = CWM_LookupAttachment(world, "shell_eject");
			if( idx > 0 ) {
				TE_SetupEffect(g_szBullet[bullet - 1], world, idx);
				TE_Send(pPlayers, pCount);
			}
		}
		if( tracer > 0 && tracerId > 0 ) {
			
			idx = CWM_LookupAttachment(view, "rw_muzzle");
			if( idx > 0 ) {
				TE_SetupEffect(g_szTracer[tracer - 1], view, idx);
				TE_WriteNum("m_nOtherEntIndex", tracerId);
				TE_SendToClient(client);
			}
			idx = CWM_LookupAttachment(world, "muzzle_flash");
			if( idx > 0 ) {
				TE_SetupEffect(g_szTracer[tracer - 1], world, idx);
				TE_WriteNum("m_nOtherEntIndex", tracerId);
				TE_Send(pPlayers, pCount);
			}
		}
	}
	
	if( left ) {
		if( muzzle > 0 ) {
			idx = CWM_LookupAttachment(view, "lw_muzzle");
			if( idx > 0 ) {
				TE_SetupEffect(g_szMuzzle[muzzle - 1], view, idx);
				TE_SendToClient(client);
			}
			idx = CWM_LookupAttachment(world, "muzzle_flash2");
			if( idx > 0 ) {
				TE_SetupEffect(g_szMuzzle[muzzle - 1], world, idx);
				TE_Send(pPlayers, pCount);
			}
		}
		if( bullet > 0 ) {
			idx = CWM_LookupAttachment(view, "lw_bullet");
			if( idx > 0 ) {
				TE_SetupEffect(g_szBullet[bullet - 1], view, idx);
				TE_SendToClient(client);
			}
			idx = CWM_LookupAttachment(world, "shell_eject2");
			if( idx > 0 ) {
				TE_SetupEffect(g_szBullet[bullet - 1], world, idx);
				TE_Send(pPlayers, pCount);
			}
		}
		if( tracer > 0 && tracerId > 0 ) {
			idx = CWM_LookupAttachment(view, "rl_muzzle");
			if( idx > 0 ) {
				TE_SetupEffect(g_szTracer[tracer - 1], view, idx);
				TE_WriteNum("m_nOtherEntIndex", tracerId);
				TE_SendToClient(client);
			}
			idx = CWM_LookupAttachment(world, "muzzle_flash2");
			if( idx > 0 ) {
				TE_SetupEffect(g_szTracer[tracer - 1], world, idx);
				TE_WriteNum("m_nOtherEntIndex", tracerId);
				TE_Send(pPlayers, pCount);
			}
		}
	}
	return 1;
}
public int Native_CWM_LookupAttachment(Handle plugin, int numParams) {
	static char tmp[PLATFORM_MAX_PATH], model[PLATFORM_MAX_PATH], key[PLATFORM_MAX_PATH * 2+1];
	static StringMap cache;
	if( !cache )
		cache = new StringMap();
	
	int value = -1;
	
	int ent = GetNativeCell(1);
	GetNativeString(2, tmp, sizeof(tmp));
	Entity_GetModel(ent, model, sizeof(model));
	
	Format(key, sizeof(key), "%s###%s", model, tmp);
	if( cache.GetValue(key, value) )
		return value;
	
#if USE_VSCRIPT == 1
	VSF_CBaseAnimating mdl = VSF_CBaseAnimating.FromEntIndex(ent); 
	value = mdl.LookupAttachment(tmp);
#else
	static Handle ptr = INVALID_HANDLE;
	
	if( ptr == INVALID_HANDLE ) {
		Handle hGameConf = LoadGameConfigFile("cwm.gamedata");
		StartPrepSDKCall(SDKCall_Entity);
		PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "LookupAttachment");
		PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
		PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
		ptr = EndPrepSDKCall();
	}
	
	if( ptr != INVALID_HANDLE )
		value = SDKCall(ptr, ent, tmp);
#endif
	
	cache.SetValue(key, value);
	return value;
}
// -----------------------------------------------------------------------------------------------------------------
//
//	EVENT
//
public void ClientConVar(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue) {
	int value = StringToInt(cvarValue);
	if( StrEqual(cvarName, "viewmodel_offset_x") && value != 1 ) {
		PrintToChat(client, "[CWM] Bad view model setting. Please change viewmodel_offset_x to 1");
	}
	if( StrEqual(cvarName, "viewmodel_offset_y") && value != 1 ) {
		PrintToChat(client, "[CWM] Bad view model setting. Please change viewmodel_offset_y to 1");
	}
	if( StrEqual(cvarName, "viewmodel_offset_z") && value != -1 ) {
		PrintToChat(client, "[CWM] Bad view model setting. Please change viewmodel_offset_z to -1");
	}
}
public void OnClientPostAdminCheck(int client) {
	
	SDKHook(client, SDKHook_WeaponSwitchPost, OnClientWeaponSwitch);
	SDKHook(client, SDKHook_WeaponDropPost, OnClientWeaponDrop);
	SDKHook(client, SDKHook_ShouldCollide, OnClientCollide);
	SDKHook(client, SDKHook_PreThinkPost, OnClientThink);

#if DEBUG_MAXSPEED == 1
	DHookEntity(g_hCSPlayer_GetPlayerMaxSpeed, true, client);
#else
	DHookEntity(g_hCSPlayer_GetPlayerMaxSpeed, false, client);
#endif
	
}
public void OnClientThink(int client) {
	
	int entity = g_iClientZoom[client][ZOOM_DOING];
	if( entity > 0 ) {
		int wpnid = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
		
		if( g_bHasCustomWeapon[client] && wpnid == entity ) {
			int fov = GetEntProp(client, Prop_Send, "m_iFOV");
			if( fov == 0 )
				fov = 90;
			
			if( (g_iClientZoom[client][ZOOM_DIRECTION] > 0 && fov < g_iClientZoom[client][ZOOM_DESIRED]) || (g_iClientZoom[client][ZOOM_DIRECTION] < 0 && fov > g_iClientZoom[client][ZOOM_DESIRED]))
				SetEntProp(client, Prop_Send, "m_iFOV", fov + (g_iClientZoom[client][ZOOM_DIRECTION]*g_iClientZoom[client][ZOOM_SPEED]));
			else
				g_iClientZoom[client][ZOOM_DOING] = 0;
		}
		else {
			g_iClientZoom[client][ZOOM_DOING] = 0;
		}
	}
}
public void OnEntityCreated(int entity, const char[] classname) {
	if( entity > 0 )
		g_iEntityData[entity][WSI_Identifier] = -1;
}
public void OnEntityDestroyed(int entity) {
	if( entity > 0 && g_hProjectile[entity] )
		delete g_hProjectile[entity];
}
public Action Cmd_LAW_Release(int client, const char[] command, int argc) {
	g_bInAttack3[client] = false;
	return Plugin_Continue;
}
public Action Cmd_LAW_Press(int client, const char[] command, int argc) {
	
	if (g_bHasCustomWeapon[client]) {
		
		float time = GetGameTime();
		int wpnid = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
		
		if (wpnid > 0) {
			
			if ( CAN_ATTACK(wpnid) ) {
				switch (g_iEntityData[wpnid][WSI_Attack3Type]) {
					case WSA_Automatic: {
						CWM_Attack3(client, wpnid);
					}
					case WSA_LockAndLoad: {
						CWM_Attack3(client, wpnid);
					}
					case WSA_SemiAutomatic: {
						if (!g_bInAttack3[client])
							CWM_Attack3(client, wpnid);
					}
				}
			}
			
			g_bInAttack3[client] = true;
			
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}
public Action OnPlayerRunCmd(int client, int& btn, int & impulse, float vel[3], float ang[3], int& weapon, int& subtype, int& cmd, int& tick, int& seed, int mouse[2]) {
	static int lastButton[65];
	
	float time = GetGameTime();
	
	if (g_bHasCustomWeapon[client]) {
		
		int wpnid = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
		
		if (wpnid > 0) {
			
			CWM_RefreshHUD(client, wpnid);
			
			// int id = g_iEntityData[wpnid][WSI_Identifier];
			// ------------------------------------------------
			if ( CAN_ATTACK(wpnid) && (btn & IN_ATTACK2)) {
				switch (g_iEntityData[wpnid][WSI_Attack2Type]) {
					case WSA_Automatic: {
						CWM_Attack2(client, wpnid);
					}
					case WSA_LockAndLoad: {
						if (g_iEntityData[wpnid][WSI_State] == 0) {
							g_iEntityData[wpnid][WSI_State] = 2;
							CWM_Attack2(client, wpnid);
						}
					}
					case WSA_SemiAutomatic: {
						if (!(lastButton[client] & IN_ATTACK2))
							CWM_Attack2(client, wpnid);
					}
				}
			}
			if (g_iEntityData[wpnid][WSI_State] == 2 && !(btn & IN_ATTACK2) ) {
				switch (g_iEntityData[wpnid][WSI_Attack2Type]) {
					case WSA_LockAndLoad: {
						CWM_AttackPost(client, wpnid);
						g_iEntityData[wpnid][WSI_State] = 0;
					}
				}
			}
			// ------------------------------------------------
			if ( CAN_ATTACK(wpnid) && (btn & IN_ATTACK)) {
				switch (g_iEntityData[wpnid][WSI_AttackType]) {
					case WSA_Automatic: {
						CWM_Attack(client, wpnid);
					}
					case WSA_LockAndLoad: {
						if (g_iEntityData[wpnid][WSI_State] == 0) {
							g_iEntityData[wpnid][WSI_State] = 1;
							CWM_Attack(client, wpnid);
						}
					}
					case WSA_SemiAutomatic: {
						if (!(lastButton[client] & IN_ATTACK))
							CWM_Attack(client, wpnid);
					}
				}
			}
			if (g_iEntityData[wpnid][WSI_State] == 1 && !(btn & IN_ATTACK) ) {
				switch (g_iEntityData[wpnid][WSI_AttackType]) {
					case WSA_LockAndLoad: {
						CWM_AttackPost(client, wpnid);
						g_iEntityData[wpnid][WSI_State] = 0;
					}
				}
			}
			// ------------------------------------------------
			if ( CAN_ATTACK(wpnid) && (btn & IN_RELOAD) ) {
				if (g_iEntityData[wpnid][WSI_State] == 1 ) {
					if (g_iEntityData[wpnid][WSI_AttackType] == view_as<int>(WSA_LockAndLoad)) {
						CWM_AttackPost(client, wpnid);
						g_iEntityData[wpnid][WSI_State] = 0;
					}
				}
				if (g_iEntityData[wpnid][WSI_State] == 2 ) {
					if (g_iEntityData[wpnid][WSI_Attack2Type] == view_as<int>(WSA_LockAndLoad)) {
						CWM_AttackPost(client, wpnid);
						g_iEntityData[wpnid][WSI_State] = 0;
					}
				}
				CWM_Reload(client, wpnid);
			}
			// ------------------------------------------------
			
			lastButton[client] = btn;
			if ( g_fEntityData[wpnid][WSF_NextIdle] <= time && g_iEntityData[wpnid][WSI_State] == 0)
				CWM_Idle(client, wpnid);
		}
	}
		
	return Plugin_Continue;
}
public MRESReturn CCSPlayer_GetPlayerMaxSpeed(int client, Handle hReturn, Handle hParams) {

#if DEBUG_MAXSPEED == 1
	if (g_bHasCustomWeapon[client]) {
		float speed = DHookGetReturn(hReturn);
		PrintToChat(21, "%f", speed);
	}
	return MRES_Ignored;
#else
	if (g_bHasCustomWeapon[client]) {
		int wpnid = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
		if (wpnid > 0) {
			DHookSetReturn(hReturn, g_fEntityData[wpnid][WSF_Speed]);
			return MRES_Supercede;
		}
	}
	return MRES_Ignored;
#endif
}
// -----------------------------------------------------------------------------------------------------------------
//
//	State Machine
//
stock void CWM_Refresh(int client, int wpnid) {
	static Handle hudSync[2];
	static float lastUpdate[65];
	
	if( hudSync[0] == null ) {
		hudSync[0] = CreateHudSynchronizer();
		hudSync[1] = CreateHudSynchronizer();
	}
	
	int view = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
	int world = GetEntPropEnt(wpnid, Prop_Send, "m_hWeaponWorldModel");
	
	if (GetEntPropFloat(wpnid, Prop_Send, "m_flNextPrimaryAttack") != FLT_MAX)
		SetEntPropFloat(wpnid, Prop_Send, "m_flNextPrimaryAttack", FLT_MAX);
	if (GetEntPropFloat(wpnid, Prop_Send, "m_flNextSecondaryAttack") != FLT_MAX)
		SetEntPropFloat(wpnid, Prop_Send, "m_flNextSecondaryAttack", FLT_MAX);
	if (GetEntProp(wpnid, Prop_Send, "m_iClip1") != g_iEntityData[wpnid][WSI_Bullet])
		SetEntProp(wpnid, Prop_Send, "m_iClip1", g_iEntityData[wpnid][WSI_Bullet]);
	if (GetEntProp(wpnid, Prop_Send, "m_iPrimaryReserveAmmoCount") != g_iEntityData[wpnid][WSI_Ammunition])
		SetEntProp(wpnid, Prop_Send, "m_iPrimaryReserveAmmoCount", g_iEntityData[wpnid][WSI_Ammunition]);
	
	//SetEntProp(view, Prop_Send, "m_bShouldIgnoreOffsetAndAccuracy", 0);
	
	if (view > 0) {
		if (GetEntProp(view, Prop_Send, "m_nSkin") != g_iEntityData[wpnid][WSI_Skin])
			SetEntProp(view, Prop_Send, "m_nSkin", g_iEntityData[wpnid][WSI_Skin]);
//		SetEntProp(view, Prop_Send, "m_bShouldIgnoreOffsetAndAccuracy", 0);
	}
	if (world > 0) {
		if (GetEntProp(world, Prop_Data, "m_nSkin") != g_iEntityData[wpnid][WSI_Skin])
			SetEntProp(world, Prop_Data, "m_nSkin", g_iEntityData[wpnid][WSI_Skin]);
	}
	if (GetEntProp(wpnid, Prop_Send, "m_nSkin") != g_iEntityData[wpnid][WSI_Skin])
		SetEntProp(wpnid, Prop_Send, "m_nSkin", g_iEntityData[wpnid][WSI_Skin]);
	
	int id = g_iEntityData[wpnid][WSI_Identifier];
	float time = GetGameTime();
	
	if( g_iStack[id][WSI_ReloadType] == view_as<int>(WSR_Background) ) {
		
		if( g_fEntityData[wpnid][WSF_LastReload]+g_fStack[id][WSF_ReloadSpeed] < time ) {
			int cpt = RoundToFloor((time - g_fEntityData[wpnid][WSF_LastReload]) / g_fStack[id][WSF_ReloadSpeed]);
				
			g_iEntityData[wpnid][WSI_Bullet] += cpt;
			if( g_iEntityData[wpnid][WSI_Bullet]>g_iStack[id][WSI_MaxBullet] )
				g_iEntityData[wpnid][WSI_Bullet] = g_iStack[id][WSI_MaxBullet];
				
			g_fEntityData[wpnid][WSF_LastReload] = time;
		}
	}
	
	if( lastUpdate[client] < time && (
		g_iStack[id][WSI_AttackBulletType]  > view_as<int>(WSB_Primary) ||
		g_iStack[id][WSI_Attack2BulletType] > view_as<int>(WSB_Primary) ||
		g_iStack[id][WSI_Attack3BulletType] > view_as<int>(WSB_Primary) )
		) {
		
		lastUpdate[client] = time + 0.2;
		
		SetHudTextParams(HUD_POS_X, HUD_POS_Y, 0.3334, HUD_COLOR_R, HUD_COLOR_G, HUD_COLOR_B, 50, 0, 0.0, 0.0, 0.0);
		ShowSyncHudText(client, hudSync[0], HUD_MESSAGE, g_iEntityData[wpnid][WSI_Bullet2], g_iEntityData[wpnid][WSI_Ammunition2]);
		SetHudTextParams(HUD_POS_X+HUD_POS_LEN, HUD_POS_Y, 0.3334, HUD_COLOR_R, HUD_COLOR_G, HUD_COLOR_B, 50, 1, 0.0, 0.0, 0.0); 
		ShowSyncHudText(client, hudSync[1], "%3d / %d", g_iEntityData[wpnid][WSI_Bullet2], g_iEntityData[wpnid][WSI_Ammunition2]);
	}
}
stock void CWM_Animation(int client, int entity, float speed) {
	int view = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
	if (view > 0) {
		SetEntPropFloat(view, Prop_Send, "m_flPlaybackRate", speed);
		SetEntProp(view, Prop_Send, "m_nSequence", g_iEntityData[entity][WSI_Animation]);
	}
}
stock void CWM_Idle(int client, int wpnid) {
	int id = g_iEntityData[wpnid][WSI_Identifier];
	Call_StartForward(view_as<Handle>(g_hStack[id][WSH_Idle]));
	Call_PushCell(client);
	Call_PushCell(wpnid);
	Call_Finish();
}
stock void CWM_Reload(int client, int wpnid) {
	int id = g_iEntityData[wpnid][WSI_Identifier];
	
	if( g_iStack[id][WSI_ReloadType] == view_as<int>(WSR_Background) )
		return;
	
	int bulletCount = g_iStack[id][WSI_ReloadType] == view_as<int>(WSR_Automatic) ? g_iStack[id][WSI_MaxBullet] : 1;
	
	if ((bulletCount + g_iEntityData[wpnid][WSI_Bullet]) > g_iStack[id][WSI_MaxBullet])
		bulletCount = g_iStack[id][WSI_MaxBullet] - g_iEntityData[wpnid][WSI_Bullet];
	
	if (bulletCount > 0 && g_iEntityData[wpnid][WSI_Ammunition] > 0) {
		
		Call_StartForward(view_as<Handle>(g_hStack[id][WSH_Reload]));
		Call_PushCell(client);
		Call_PushCell(wpnid);
		Call_Finish();
		
		Handle dp;
		g_hReloading[wpnid] = CreateDataTimer(g_fStack[id][WSF_ReloadSpeed] * RELOAD_RATIO, CWM_ReloadPost, dp, TIMER_DATA_HNDL_CLOSE);
		WritePackCell(dp, id);
		WritePackCell(dp, wpnid);
		WritePackCell(dp, bulletCount);
	}
	else {
		CWM_Empty(client, wpnid);
	}
}
public Action CWM_ReloadPost(Handle timer, Handle dp) {	
	ResetPack(dp);
	int id = ReadPackCell(dp);
	int wpnid = ReadPackCell(dp);
	int bullet = ReadPackCell(dp);
	
	if( g_hReloading[wpnid] == INVALID_HANDLE )
		return Plugin_Stop;
	
	g_iEntityData[wpnid][WSI_Ammunition] -= bullet;
	g_iEntityData[wpnid][WSI_Bullet] += bullet;
		
	if (g_iEntityData[wpnid][WSI_Ammunition] < 0) {
		g_iEntityData[wpnid][WSI_Bullet] += g_iEntityData[wpnid][WSI_Ammunition];
		g_iEntityData[wpnid][WSI_Ammunition] = 0;
	}
	
	g_fEntityData[wpnid][WSF_NextAttack] = GetGameTime() + g_fStack[id][WSF_ReloadSpeed] * (1.0-RELOAD_RATIO);
	g_hReloading[wpnid] = INVALID_HANDLE;
	
	if( g_iStack[id][WSI_ReloadType] == view_as<int>(WSR_OneByOne) )
		CreateTimer(g_fStack[id][WSF_ReloadSpeed] * (1.0-RELOAD_RATIO), CWM_ReloadBatch, wpnid);
	
	return Plugin_Stop;
}
public Action CWM_ReloadBatch(Handle timer, any wpnid) {
	
	int client = g_iEntityData[wpnid][WSI_Owner];
	int id = g_iEntityData[wpnid][WSI_Identifier];
	g_iEntityData[wpnid][WSI_State] = 0;
	
	if (client > 0 && g_iEntityData[wpnid][WSI_Ammunition] > 1 && g_iEntityData[wpnid][WSI_Bullet] < g_iStack[id][WSI_MaxBullet])
		CWM_Reload(client, wpnid);
	
	return Plugin_Handled;
}
stock void CWM_Empty(int client, int wpnid) {
	int id = g_iEntityData[wpnid][WSI_Identifier];
	
	Action a;
	Call_StartForward(view_as<Handle>(g_hStack[id][WSH_Empty]));
	Call_PushCell(client);
	Call_PushCell(wpnid);
	Call_Finish(a);
	
	if (a != Plugin_Stop) {
		g_fEntityData[wpnid][WSF_NextAttack] = GetGameTime() + 0.5 + g_fStack[id][WSF_AttackSpeed];
		
		if (a != Plugin_Handled)
			EmitSoundToAll("weapons/clipempty_rifle.wav", wpnid, SNDCHAN_WEAPON);
	}
	
}
stock void CWM_Draw(int client, int wpnid) {
	int id = g_iEntityData[wpnid][WSI_Identifier];
	
	SetEntProp(wpnid, Prop_Send, "m_nModelIndex", g_iStack[id][WSI_WModel]);
	int view = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
	int world = GetEntPropEnt(wpnid, Prop_Send, "m_hWeaponWorldModel");
	
	if (view > 0) {
		SetEntProp(view, Prop_Send, "m_nModelIndex", g_iStack[id][WSI_VModel]);
		SetEntityModel(view, g_sStack[id][WSS_VModel]);
	}
	if (world > 0)
		SetEntProp(world, Prop_Send, "m_nModelIndex", g_iStack[id][WSI_WModel]);
	
	SetEntPropFloat(wpnid, Prop_Send, "m_flNextPrimaryAttack", FLT_MAX);
	SetEntPropFloat(wpnid, Prop_Send, "m_flNextSecondaryAttack", FLT_MAX);
	SetEntPropFloat(wpnid, Prop_Send, "m_flTimeWeaponIdle", FLT_MAX);
	
	Action a;
	Call_StartForward(view_as<Handle>(g_hStack[id][WSH_Draw]));
	Call_PushCell(client);
	Call_PushCell(wpnid);
	Call_Finish(a);
	
	if (a != Plugin_Stop) {
		float time = GetGameTime();
		
		if( (g_fEntityData[wpnid][WSF_NextAttack]-time) < 1.0 )
			g_fEntityData[wpnid][WSF_NextAttack] = GetGameTime() + 1.0;
		
		if (a != Plugin_Handled)
			EmitSoundToAll("weapons/sg556/sg556_draw.wav", wpnid, SNDCHAN_WEAPON);
	}
}

stock bool Bullet_HasEnought(int wpnid, int attackBulletType, int attackBulletCount) {
	if( attackBulletType == view_as<int>(WSB_None) )
		return true;
	if( (g_iEntityData[wpnid][view_as<int>(attackBulletType == view_as<int>(WSB_Primary) ? WSI_Bullet : WSI_Bullet2)] - attackBulletCount) >= 0 )
		return true;
	return false;
}
stock void Bullet_Decrease(int wpnid, int attackBulletType, int attackBulletCount) {
	if( attackBulletType != view_as<int>(WSB_None) )
		g_iEntityData[wpnid][view_as<int>(attackBulletType == view_as<int>(WSB_Primary) ? WSI_Bullet : WSI_Bullet2)] -= attackBulletCount;
}

stock void CWM_Attack(int client, int wpnid) {
	int id = g_iEntityData[wpnid][WSI_Identifier];
	float time = GetGameTime();
	
	if (GetForwardFunctionCount(view_as<Handle>(g_hStack[id][WSH_Attack])) == 0) {
		g_iEntityData[wpnid][WSI_State] = 0;
		return;
	}
	
	if ( Bullet_HasEnought(wpnid, g_iStack[id][WSI_AttackBulletType], g_iStack[id][WSI_AttackBullet]) ) {
		
		Action a;
		Call_StartForward(view_as<Handle>(g_hStack[id][WSH_Attack]));
		Call_PushCell(client);
		Call_PushCell(wpnid);
		Call_Finish(a);
		
		if (a != Plugin_Stop) {
			g_fEntityData[wpnid][WSF_NextAttack] = time + g_fStack[id][WSF_AttackSpeed];
			g_fEntityData[wpnid][WSF_LastReload] = time + g_fStack[id][WSF_AttackSpeed];
			
			if (a != Plugin_Handled) {
				Bullet_Decrease(wpnid, g_iStack[id][WSI_AttackBulletType], g_iStack[id][WSI_AttackBullet]);
				CWM_Recoil(client, wpnid);
			}
			
			if (g_iEntityData[wpnid][WSI_Bullet] == 0 && g_iEntityData[wpnid][WSI_State] == 0 )
				CreateTimer(g_fStack[id][WSF_AttackSpeed], CWM_ReloadBatch, wpnid);
		}
	}
	else {
		g_iEntityData[wpnid][WSI_State] = 0;
		CWM_Reload(client, wpnid);
	}
}
stock void CWM_Recoil(int client, int wpnid) {
	static float vec[3];
	int id = g_iEntityData[wpnid][WSI_Identifier];
	if( g_fStack[id][WSF_Recoil] <= 0.0 )
		return;
	
	g_iEntityData[wpnid][WSI_ShotFired]++;
	CreateTimer(g_fStack[id][WSF_AttackSpeed] * float(g_iStack[id][WSI_ShotFired]), CWM_Attack_Recoil, wpnid);
	vec[0] = -float(g_iEntityData[wpnid][WSI_ShotFired]) * g_fStack[id][WSF_Recoil] * 0.5;
	//vec[1] = vec[0]/2.0;
	
	SetEntPropVector(client, Prop_Send, "m_aimPunchAngleVel", vec);
}
public Action CWM_Attack_Recoil(Handle timer, any wpnid) {
	g_iEntityData[wpnid][WSI_ShotFired]--;
}
stock void CWM_AttackPost(int client, int wpnid) {
	int id = g_iEntityData[wpnid][WSI_Identifier];
	
	Action a;
	Call_StartForward(view_as<Handle>(g_hStack[id][WSH_AttackPost]));
	Call_PushCell(client);
	Call_PushCell(wpnid);
	Call_Finish(a);
	
	if (g_iEntityData[wpnid][WSI_Bullet] == 0 )
		CreateTimer(g_fStack[id][WSF_AttackSpeed], CWM_ReloadBatch, wpnid);
	
}
stock void CWM_Attack2(int client, int wpnid) {
	int id = g_iEntityData[wpnid][WSI_Identifier];
	float time = GetGameTime();
	
	if (GetForwardFunctionCount(view_as<Handle>(g_hStack[id][WSH_Attack2])) == 0)
		return;
	
	if ( Bullet_HasEnought(wpnid, g_iStack[id][WSI_Attack2BulletType], g_iStack[id][WSI_Attack2Bullet]) ) {
		
		Action a;
		Call_StartForward(view_as<Handle>(g_hStack[id][WSH_Attack2]));
		Call_PushCell(client);
		Call_PushCell(wpnid);
		Call_Finish(a);
		
		if (a != Plugin_Stop) {
			g_fEntityData[wpnid][WSF_NextAttack] = time + g_fStack[id][WSF_AttackSpeed];
			if (a != Plugin_Handled) {
				Bullet_Decrease(wpnid, g_iStack[id][WSI_Attack2BulletType], g_iStack[id][WSI_Attack2Bullet]);
				CWM_Recoil(client, wpnid);
			}
		}
	}
	else {
		CWM_Reload(client, wpnid);
	}
}
stock void CWM_Attack3(int client, int wpnid) {
	int id = g_iEntityData[wpnid][WSI_Identifier];
	float time = GetGameTime();
	
	if (GetForwardFunctionCount(view_as<Handle>(g_hStack[id][WSH_Attack3])) == 0)
		return;
	
	if ( Bullet_HasEnought(wpnid, g_iStack[id][WSI_Attack3BulletType], g_iStack[id][WSI_Attack3Bullet]) ) {
		
		Action a;
		Call_StartForward(view_as<Handle>(g_hStack[id][WSH_Attack3]));
		Call_PushCell(client);
		Call_PushCell(wpnid);
		Call_Finish(a);
		
		if (a != Plugin_Stop) {
			g_fEntityData[wpnid][WSF_NextAttack] = time + g_fStack[id][WSF_AttackSpeed];
			if (a != Plugin_Handled) {
				Bullet_Decrease(wpnid, g_iStack[id][WSI_Attack3BulletType], g_iStack[id][WSI_Attack3Bullet]);
				CWM_Recoil(client, wpnid);
			}
		}
	}
	else {
		CWM_Reload(client, wpnid);
	}
}
// -----------------------------------------------------------------------------------------------------------------
//
//	Forwards
//
public bool OnClientCollide(int entity, int collisiongroup, int contentsmask, int originalResult) {
	bool result = originalResult == 255 ? true : false;
	
	if( collisiongroup == 13 && contentsmask == 1107845259 && result )
		return false;
	
	return result;
}
public Action OnClientWeaponSwitch(int client, int wpnid) {
	static int lastWeapon[65];
	
	if( lastWeapon[client] > 0 && lastWeapon[client] != wpnid ) {
		if( g_hReloading[lastWeapon[client]] )
			delete g_hReloading[lastWeapon[client]];
	}
	
	int id = g_iEntityData[wpnid][WSI_Identifier];
	if (id >= 0) {
		g_bHasCustomWeapon[client] = true;
		g_iEntityData[wpnid][WSI_Owner] = client;
		
		/*
		int wpnCount = 0;
		int wpnId[MAX_CWEAPONS];
		
		for (int i = 1; i <= 2048; i++) {
			if( g_iEntityData[i][WSI_Identifier] > 0 && g_iEntityData[i][WSI_Owner] == client && g_iStack[i][WSI_Slot] == g_iStack[wpnid][WSI_Slot]  )
				wpnId[wpnCount++] = i;
		}
		
		if( wpnCount > 1 ) {
			wpnid = wpnId[(++lastWeaponUsed[client]) % wpnCount];		
			SetEntPropEnt(client, Prop_Data, "m_hActiveWeapon", wpnid);
		}
		*/
		if( GetEntProp(wpnid, Prop_Send, "m_hPrevOwner") < 0 )
			SetEntProp(wpnid, Prop_Send, "m_hPrevOwner", client);
		CWM_Draw(client, wpnid);
		lastWeapon[client] = wpnid;
	}
	else {
		g_bHasCustomWeapon[client] = false;
	}
	
	
}
public Action OnClientWeaponDrop(int client, int wpnid) {
	
	if (wpnid > 0 && g_iEntityData[wpnid][WSI_Identifier] >= 0) {
		if( g_hReloading[wpnid] )
			delete g_hReloading[wpnid];
		
		g_bHasCustomWeapon[client] = false;
		g_iEntityData[wpnid][WSI_Owner] = 0;
		RequestFrame(OnClientWeaponDropPost, EntIndexToEntRef(wpnid));
	}
}
public void OnClientWeaponDropPost(int wpnid) {
	wpnid = EntRefToEntIndex(wpnid);
	if (wpnid > 0 && g_iEntityData[wpnid][WSI_Identifier] >= 0)
		SetEntProp(wpnid, Prop_Send, "m_nModelIndex", g_iStack[g_iEntityData[wpnid][WSI_Identifier]][WSI_WModel]);
}
public bool TraceEntityFilterSelf(int entity, int contentsMask, any data) {
	return entity != data;
}
public bool TraceEntityFilterSelfAndEntity(int entity, int contentsMask, any data) {
	return entity > 0 && entity != 0;
}
public Action CWM_ProjectileTouch(int ent, int target) {
	g_hProjectile[ent].Reset();
	int client = g_hProjectile[ent].ReadCell();
	int wpnid = g_hProjectile[ent].ReadCell();
	Handle plugin = g_hProjectile[ent].ReadCell();
	Function callback = g_hProjectile[ent].ReadFunction();
	
	int id = g_iEntityData[wpnid][WSI_Identifier];
	
	if (callback != INVALID_FUNCTION && target >= 0 && target != client) {
		
		Action a;
		Call_StartFunction(plugin, callback);
		Call_PushCell(client);
		Call_PushCell(wpnid);
		Call_PushCell(ent);
		Call_PushCell(target);
		Call_Finish(a);
		
		if (a == Plugin_Continue && IsBreakable(target)) {
			Entity_Hurt(target, g_iEntityData[wpnid][WSI_AttackDamage], g_iEntityData[wpnid][WSI_Owner], DMG_GENERIC, g_sStack[id][WSS_Name]);
		}
		
		if (a != Plugin_Stop) {
			AcceptEntityInput(ent, "KillHierarchy");
			delete g_hProjectile[ent];
		}
	}
	
	return Plugin_Handled;
}
// -----------------------------------------------------------------------------------------------------------------
//
//	UTILS: CWM
//
public bool IsMoveable(int ent) {
	static char classname[64];
	GetEdictClassname(ent, classname, sizeof(classname));
	
	if (StrContains(classname, "prop_physic", false) == 0)
		return true;
	if (StrContains(classname, "weapon_", false) == 0)
		return true; 
	return false;
}
public bool IsBreakable(int ent) {
	static char classname[64];
	if (ent <= 0 || !IsValidEdict(ent) || !IsValidEntity(ent))
		return false;
	if (IsValidClient(ent))
		return IsPlayerAlive(ent);
	if (!HasEntProp(ent, Prop_Send, "m_vecOrigin"))
		return false;
	
	if (!HasEntProp(ent, Prop_Send, "m_vecVelocity") && !HasEntProp(ent, Prop_Data, "m_vecAbsVelocity"))
		return false;
	if (Entity_GetMaxHealth(ent) <= 0)
		return false;
	
	GetEdictClassname(ent, classname, sizeof(classname));
	
	if (StrContains(classname, "door", false) == 0)
		return false;
	if (StrContains(classname, "prop_p", false) == 0)
		return true;
	if (StrContains(classname, "weapon_", false) == 0)
		return true;
	if (StrContains(classname, "chicken", false) == 0)
		return true;
	if (StrContains(classname, "monster_generic", false) == 0)
		return true;
	if (StrContains(classname, "rp_", false) == 0)
		return true;
	
	return false;
}
// -----------------------------------------------------------------------------------------------------------------
//
//	UTILS: Generics
//
stock int GetClientAimedLocation(int client, float position[3], float angles[3]) {
	int index = -1;
	GetClientEyePosition(client, position);
	GetClientEyeAngles(client, angles);
	
	Handle trace = TR_TraceRayFilterEx(position, angles, MASK_SOLID_BRUSHONLY, RayType_Infinite, TraceEntityFilterSelf, client);
	if (TR_DidHit(trace)) {
		TR_GetEndPosition(position, trace);
		index = TR_GetEntityIndex(trace);
	}
	CloseHandle(trace);
	
	return index;
}
stock void TE_SetupWorldDecal(float origin[3], int index) {
	TE_Start("World Decal");
	TE_WriteVector("m_vecOrigin", origin);
	TE_WriteNum("m_nIndex", index);
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
stock int Entity_GetGroundOrigin(int entity, float pos[3]) {
	static float source[3], target[3];
	Entity_GetAbsOrigin(entity, source);
	target[0] = source[0];
	target[1] = source[1];
	target[2] = source[2] - 999999.9;
	
	Handle tr;
	tr = TR_TraceRayFilterEx(source, target, MASK_SOLID, RayType_EndPoint, TraceEntityFilterSelf, entity);
	if (tr)
		TR_GetEndPosition(pos, tr);
	delete tr;
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
stock void PrecacheEffect(const char[] sEffectName) {
	static int table = INVALID_STRING_TABLE;
	
	if (table == INVALID_STRING_TABLE)
		table = FindStringTable("EffectDispatch");
	
	bool save = LockStringTables(false);
	AddToStringTable(table, sEffectName);
	LockStringTables(save);
}
