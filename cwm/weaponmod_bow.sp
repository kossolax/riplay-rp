#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <smlib>
#include <emitsoundany>
#include <colors_csgo>

#include <roleplay>
#include <custom_weapon_mod.inc>

char g_szFullName[PLATFORM_MAX_PATH] =	"Arc à fleches";
char g_szName[PLATFORM_MAX_PATH] 	 =	"bow";
char g_szReplace[PLATFORM_MAX_PATH]  =	"weapon_awp";

char g_szVModel[PLATFORM_MAX_PATH] =	"models/weapons/v_huntingbow_csgo.mdl";
char g_szWModel[PLATFORM_MAX_PATH] =	"models/weapons/w_huntingbowcsgo.mdl";

char g_szTModel[PLATFORM_MAX_PATH] =	"models/weapons/w_huntingbow_arrow.mdl";

float g_fWeaponStart[MAX_ENTITIES];

char g_szMaterials[][PLATFORM_MAX_PATH] = {
	"materials/models/weapons/huntingbow/steelarrow.vmt",
	"materials/models/weapons/huntingbow/steelarrow.vtf",
	"materials/models/weapons/huntingbow/steelarrow_m.vtf",
	"materials/models/weapons/huntingbow/steelarrow_n.vtf",
	"materials/models/weapons/huntingbow/steelbow.vmt",
	"materials/models/weapons/huntingbow/steelbow.vtf",
	"materials/models/weapons/huntingbow/steelbow_m.vtf",
	"materials/models/weapons/huntingbow/steelbow_n.vtf"
};

char g_szSounds[][PLATFORM_MAX_PATH] = {
	"weapons/huntingbow/draw_1.wav",
	"weapons/huntingbow/impact_arrow_flesh_1.wav",
	"weapons/huntingbow/impact_arrow_flesh_2.wav",
	"weapons/huntingbow/impact_arrow_flesh_3.wav",
	"weapons/huntingbow/impact_arrow_flesh_4.wav",
	"weapons/huntingbow/impact_arrow_stick_1.wav",
	"weapons/huntingbow/impact_arrow_stick_2.wav",
	"weapons/huntingbow/impact_arrow_stick_3.wav",
	"weapons/huntingbow/pull_1.wav",
	"weapons/huntingbow/pull_2.wav",
	"weapons/huntingbow/pull_3.wav",
	"weapons/huntingbow/shoot_1.wav",
	"weapons/huntingbow/shoot_2.wav",
	"weapons/huntingbow/shoot_3.wav"
};

public void OnPluginStart() {
	RegServerCmd("sm_cwm_reload", Cmd_PluginReloadSelf);
}
public void OnAllPluginsLoaded() {
	int id = CWM_Create(g_szFullName, g_szName, g_szReplace, g_szVModel, g_szWModel);
	
	CWM_SetInt(id, WSI_AttackType,		view_as<int>(WSA_LockAndLoad));
	CWM_SetInt(id, WSI_ReloadType,		view_as<int>(WSR_Automatic));
	CWM_SetInt(id, WSI_AttackDamage, 	25);
	CWM_SetInt(id, WSI_AttackBullet, 	1);
	CWM_SetInt(id, WSI_MaxBullet, 		50);
	CWM_SetInt(id, WSI_MaxAmmunition, 	0);
	CWM_SetInt(id, WSI_ShotFired,		0);
	
	CWM_SetFloat(id, WSF_Speed,			240.0);
	CWM_SetFloat(id, WSF_ReloadSpeed,	0.1);
	CWM_SetFloat(id, WSF_AttackSpeed,	0.5);
	CWM_SetFloat(id, WSF_AttackRange,	RANGE_MELEE * 4.0);
	CWM_SetFloat(id, WSF_Spread, 		0.0);
	CWM_SetFloat(id, WSF_Recoil, 		0.0);
	
	CWM_AddAnimation(id, WAA_Idle, 		0,  1, 30);
	CWM_AddAnimation(id, WAA_Draw, 		10,	44, 30);
	CWM_AddAnimation(id, WAA_Attack, 	6,  25, 30);
	CWM_AddAnimation(id, WAA_Attack2, 	7,  15, 30);
	
	CWM_RegHook(id, WSH_Draw,			OnDraw);
	CWM_RegHook(id, WSH_Attack,			OnAttack);
	CWM_RegHook(id, WSH_AttackPost,		OnAttackPost);
	CWM_RegHook(id, WSH_Idle,			OnIdle);
}
public void OnDraw(int client, int entity) {
	CWM_RunAnimation(entity, WAA_Draw);
	EmitSoundToAllAny(g_szSounds[0], entity, SNDCHAN_WEAPON);
}
public void OnIdle(int client, int entity) {
	CWM_RunAnimation(entity, WAA_Idle);
}
public Action OnAttack(int client, int entity) {
	CWM_RunAnimation(entity, WAA_Attack);
	CWM_ZoomIn(client, entity, 75, 1);
	
	EmitSoundToAllAny(g_szSounds[GetRandomInt(8, 10)], entity, SNDCHAN_WEAPON);
	g_fWeaponStart[entity] = GetGameTime();
	return Plugin_Continue;
}
public Action OnAttackPost(int client, int entity) {
	CWM_ZoomOut(client, entity, 90, 5);
	CWM_RunAnimation(entity, WAA_Attack2);
	
	float pc = (GetGameTime() - g_fWeaponStart[entity]) * (30.0 / 25.0);
	if( pc > 1.0 )
		pc = 1.0;
	
	int ent = CWM_ShootProjectile(client, entity, g_szTModel, "arrow", 0.0, 2000.0 * pc, OnProjectileHit);
	SetEntityGravity(ent, 1.0 - (pc*0.8));
	
	EmitSoundToAllAny(g_szSounds[GetRandomInt(11, 13)], entity, SNDCHAN_WEAPON);
	return Plugin_Continue;
}
public Action OnProjectileHit(int client, int wpnid, int entity, int target) {
	float vel[3], ang[3], pos[3];
	
	Entity_GetAbsOrigin(entity, pos);
	Entity_GetAbsVelocity(entity, vel);
	GetVectorAngles(vel, ang);	
	
	int ent = CreateEntityByName("prop_dynamic_override");
	DispatchKeyValue(ent, "model", g_szTModel);
	DispatchKeyValue(ent, "OnUser1", "!self,KillHierarchy,,5.0,-1");
	DispatchKeyValue(ent, "solid", "0");
	DispatchSpawn(ent);
	TeleportEntity(ent, pos, ang, NULL_VECTOR);
	
	//
	if( target > 0 ) {
		SetVariantString("!activator");
		AcceptEntityInput(ent, "SetParent", target);
			
		CWM_ShootDamage(client, wpnid, target, pos);
		EmitSoundToAllAny(g_szSounds[GetRandomInt(1, 4)], ent, SNDCHAN_WEAPON);
	}
	else {
		EmitSoundToAllAny(g_szSounds[GetRandomInt(5, 7)], ent, SNDCHAN_WEAPON);
	}
	
	AcceptEntityInput(ent, "FireUser1");
	
	return Plugin_Handled;
}
public void OnMapStart() {
	
	AddModelToDownloadsTable(g_szVModel);
	AddModelToDownloadsTable(g_szWModel);
	AddModelToDownloadsTable(g_szTModel);
	
	for (int i = 0; i < sizeof(g_szSounds); i++) {
		AddSoundToDownloadsTable(g_szSounds[i]);
		PrecacheSoundAny(g_szSounds[i]);
	}
	for (int i = 0; i < sizeof(g_szMaterials); i++) {
		AddFileToDownloadsTable(g_szMaterials[i]);
	}

}
