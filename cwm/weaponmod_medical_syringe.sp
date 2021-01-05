#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <emitsoundany>
#include <smlib>

#include <custom_weapon_mod.inc>

char g_szFullName[PLATFORM_MAX_PATH] =	"Medical Syringe";
char g_szName[PLATFORM_MAX_PATH] 	 =	"medical_syringe";
char g_szReplace[PLATFORM_MAX_PATH]  =	"weapon_taser";

char g_szVModel[PLATFORM_MAX_PATH] =	"models/weapons/kaesar/lockpick/v_lockpick.mdl";
char g_szWModel[PLATFORM_MAX_PATH] =	"models/weapons/Zombie4ever/medical/w_medical.mdl";

bool g_bWasNearPlayer[65];

char g_szMaterials[][PLATFORM_MAX_PATH] = {
};
char g_szSounds[][PLATFORM_MAX_PATH] = {
};

public void OnPluginStart() {
	RegServerCmd("sm_cwm_reload", Cmd_PluginReloadSelf);
}
public void OnAllPluginsLoaded() {
	int id = CWM_Create(g_szFullName, g_szName, g_szReplace, g_szVModel, g_szWModel);
	
	CWM_SetInt(id, WSI_AttackType,		view_as<int>(WSA_SemiAutomatic));
	CWM_SetInt(id, WSI_AttackDamage, 	0);
	CWM_SetInt(id, WSI_AttackBullet, 	100);
	CWM_SetInt(id, WSI_Attack2Type,		view_as<int>(WSA_SemiAutomatic));
	
	CWM_SetInt(id, WSI_ReloadType,		view_as<int>(WSR_Background));
	CWM_SetInt(id, WSI_Attack2Bullet, 	100);
	CWM_SetInt(id, WSI_MaxBullet, 		100);
	CWM_SetInt(id, WSI_MaxAmmunition, 	100);
	CWM_SetInt(id, WSI_ShotFired,		0);
	CWM_SetInt(id, WSI_Slot, 			CS_SLOT_KNIFE);
	
	CWM_SetFloat(id, WSF_Speed,			240.0);
	CWM_SetFloat(id, WSF_ReloadSpeed,	15/100.0);
	CWM_SetFloat(id, WSF_AttackSpeed,	2.0);
	
	CWM_SetFloat(id, WSF_AttackRange,	RANGE_MELEE);
	CWM_SetFloat(id, WSF_Spread, 		0.0);
	CWM_SetFloat(id, WSF_Recoil, 		0.0);
	
	CWM_AddAnimation(id, WAA_Idle, 		0,	95,	30);
	CWM_AddAnimation(id, WAA_RightToMid,2,  9,	30);
	CWM_AddAnimation(id, WAA_MidToRight,4,	9,	30);
	CWM_AddAnimation(id, WAA_Idle2, 	3,	38,	30);
	CWM_AddAnimation(id, WAA_Draw, 		1,	22,	30);
	
	CWM_RegHook(id, WSH_Draw,			OnDraw);
	CWM_RegHook(id, WSH_Idle,			OnIdle);
	CWM_RegHook(id, WSH_Reload,			OnReload);
}
public void OnReload(int client, int entity) {
	OnRefresh(client, entity);
}

public void OnDraw(int client, int entity) {
	CWM_RunAnimation(entity, WAA_Draw);	
	g_bWasNearPlayer[client] = false;
}
public void OnIdle(int client, int entity) {
	OnRefresh(client, entity);
	
	int target = GetClientAimTarget(client, false);
	if (target > 0 && target < MaxClients && Entity_GetDistance(client, target) < RANGE_MELEE && GetClientTeam(client) == GetClientTeam(target) ) {
		if( g_bWasNearPlayer[client] == false )
			CWM_RunAnimation(entity, WAA_RightToMid);
		else
			CWM_RunAnimation(entity, WAA_Idle2);
		
		g_bWasNearPlayer[client] = true;
	}
	else { 
		if( g_bWasNearPlayer[client] == true )
			CWM_RunAnimation(entity, WAA_MidToRight);
		else
			CWM_RunAnimation(entity, WAA_Idle);
		
		g_bWasNearPlayer[client] = false;
	}
}
public Action Timer_LateRefresh(Handle timer, Handle dp) {
	ResetPack(dp);
	int entity = EntRefToEntIndex(ReadPackCell(dp));
	int client = ReadPackCell(dp);
	
	if( entity > 0 )
		OnRefresh(client, entity);
	
	return Plugin_Stop;
}
void OnRefresh(int client, int entity) {
	int cur = CWM_GetEntityInt(entity, WSI_Bullet);
	int max = CWM_GetEntityInt(entity, WSI_MaxBullet);
	int skin = (10*cur) / max;
	
	CWM_SetEntityInt(entity, WSI_Skin, skin);
	CWM_RefreshHUD(client, entity);
}
public void OnMapStart() {

	AddModelToDownloadsTable(g_szVModel);
	AddModelToDownloadsTable(g_szWModel);
	
	for (int i = 0; i < sizeof(g_szSounds); i++) {
		AddSoundToDownloadsTable(g_szSounds[i]);
		PrecacheSoundAny(g_szSounds[i]);
	}
	for (int i = 0; i < sizeof(g_szMaterials); i++) {
		AddFileToDownloadsTable(g_szMaterials[i]);
	}
	
}
