#if defined _weaponmod_included
#endinput
#endif
#define _weaponmod_included

#include <cstrike>

#define CSGO_RENAME_WEAPON	1	// WARNING: this might ban your tokken. You also need to add a bones named "v_weapon.uid" out of player's view.
#define CSGO_FIX_STARTRAK	0	// WARNING: this might ban your tokken.
#define CSGO_FIX_SPAWN		0	// some old version of sourcemod require this.
#define USE_VSCRIPT			0	// do you have vscript extension running on your serv?
#define SLOT_REDIRECT		0	// WARNING: this might ban your tokken.
#define RELOAD_RATIO		0.75 // "Reload glitch" ratio. Percentage of reload time spend to complete the reload itself.

#define HUD_MESSAGE			"Alternative ammunition:"
#define HUD_COLOR_R			64
#define HUD_COLOR_G			200
#define HUD_COLOR_B			32
#define HUD_POS_X			0.4
#define HUD_POS_Y			0.96
#define HUD_POS_LEN			0.175

// DO NOT EDIT BELLOW WITHOUT BEING AWARE WHAT YOU ARE DOING.
#define DEBUG				0
#define DEBUG_MAXSPEED		0

#define MAXSPEED_DIFF_WIN	-2
#define MAXSPEED_DIFF_LINUX	-1

#define MAX_CWEAPONS	32
#define MAX_ENTITIES	2049
#define MAX_BLOOD		8
#define MAX_BULLET		4
#define MAX_ANIMATION 	8
#define FLT_MAX			2147483647.0
#define RANGE_NONE		-FLT_MAX
#define RANGE_MELEE		52.0
#define RANGE_WEAPON	4096.0
#define NULL_MODEL		""

typeset CWM_HitCallback {
	function Action(int client, int wpnid, int entity, int target);	// Continue = subit les dégats, handle/stop = pas de dégat
}

native int CWM_Create(char fullname[PLATFORM_MAX_PATH], char name[PLATFORM_MAX_PATH], char weaponToReplace[PLATFORM_MAX_PATH], char v_model[PLATFORM_MAX_PATH], char w_model[PLATFORM_MAX_PATH]);

native void CWM_RegHook(int id, CWM_HookType data, CWM_HookTypeForward fonction);

native void CWM_AddAnimation(int id, CWM_DataAnimation data, int sequence, int frames, int fps);
native void CWM_RunAnimation(int entity, CWM_DataAnimation data, float time = -1.0, int id = -1);
native void CWM_RunAnimationSound(int entity, CWM_DataAnimation data, const char sound[PLATFORM_MAX_PATH], int frame);

native int CWM_Spawn(int id, int client, float pos[3], float ang[3]);

native int CWM_ShootProjectile(int client, int entity, char model[PLATFORM_MAX_PATH], char name[32], float spreadAngle = 0.0, float speed = FLT_MAX, CWM_HitCallback fonction = INVALID_FUNCTION);
native int CWM_ShootHull(int client, int entity, float size, float hit[3]);
native int CWM_ShootRay(int client, int entity, float hit[3] = NULL_VECTOR);
native int CWM_ShootExplode(int client, int wpnid, int entity, float radius);
native int CWM_ShootDamage(int client, int wpnid, int target, float hit[3]);

native void CWM_RefreshHUD(int client, int entity);

native int CWM_GetId(char name[PLATFORM_MAX_PATH]);


native void CWM_SetInt(int id, CWM_DataInteger data, int value);
native int CWM_GetInt(int id, CWM_DataInteger data);
native void CWM_SetEntityInt(int entity, CWM_DataInteger data, int value);
native int CWM_GetEntityInt(int entity, CWM_DataInteger data);

native void CWM_SetFloat(int id, CWM_DataFloat data, float value);
native float CWM_GetFloat(int id, CWM_DataFloat data);
native void CWM_SetEntityFloat(int entity, CWM_DataFloat data, float value);
native float CWM_GetEntityFloat(int entity, CWM_DataFloat data);

native bool CWM_IsCustom(int entity);

native void CWM_ZoomIn(int client, int entity, int fov, int speed=1);
native void CWM_ZoomOut(int client, int entity, int fov, int speed=1);
native int CWM_LookupAttachment(int entity, char name[PLATFORM_MAX_PATH]);
native int CWM_ShellOut(int client, int entity, CWM_MuzzleType muzzle, CWM_ShellType bullet, CWM_TraceType trace, float hit[3] = { 0.0, 0.0, 0.0 }, bool right = true, bool left = false); 

enum CWM_ShellType {
	WST_None,
	WST_50mm,
	WST_9mm,
	WST_CandyCorn,
	WST_Rifle,
	WST_Shotgun,
	
	WST_Max
}
enum CWM_MuzzleType {
	WMT_None,
	WMT_AssaultRifle,
	WMT_AutoShotgun,
	WMT_AWP,
	WMT_HuntingRifle,
	WMT_Para,
	WMT_Pistol,
	WMT_Shotgun,
	WMT_SMG,
	WMT_Taser,
	
	WMT_Max
}
enum CWM_TraceType {
	WTT_None,
	WTT_50mm,
	WTT_AssaultRifle,
	WTT_Mach,
	WTT_Original,
	WTT_Pistol,
	WTT_Rifle,
	WTT_Shot,
	WTT_SMG,
	WTT_Traser,
	
	WTT_Max
}
enum CWM_DataAnimation {
	WAA_Idle,
	WAA_Idle2,
	WAA_Draw,
	WAA_Attack,
	WAA_AttackPost,
	WAA_Attack2,
	WAA_Attack3,
	WAA_Reload,
	WAA_MidToRight,
	WAA_RightToMid,
	
	WAA_Max
}
enum CWM_DataInteger {
	WSI_Identifier,
	
	WSI_AttackDamage,
	WSI_AttackBullet,
	WSI_AttackBulletType,
	WSI_AttackType,
	
	WSI_Attack2Bullet,
	WSI_Attack2BulletType,
	WSI_Attack2Type,
	
	WSI_Attack3Bullet,
	WSI_Attack3BulletType,
	WSI_Attack3Type,
	
	WSI_Bullet,
	WSI_MaxBullet,
	WSI_Ammunition,
	WSI_MaxAmmunition,
	
	WSI_Bullet2,
	WSI_MaxBullet2,
	WSI_Ammunition2,
	WSI_MaxAmmunition2,
	
	WSI_ReloadType,
	
	WSI_Animation,
	WSI_Owner,
	WSI_VModel,
	WSI_WModel,
	WSI_Skin,
	WSI_State,
	WSI_ShotFired,
	WSI_Slot,
	
	WSI_Max
};
enum CWM_DataFloat {
	Float:WSF_Speed,
	Float:WSF_Attack,
	Float:WSF_NextAttack,
	Float:WSF_AttackSpeed,
	Float:WSF_AttackRange,
	Float:WSF_ReloadSpeed,
	Float:WSF_NextIdle,
	Float:WSF_LastReload,
	Float:WSF_AnimationSpeed,
	Float:WSF_Spread,
	Float:WSF_Recoil,
	
	WSF_Max
};
enum CWM_DataString {
	WSS_Fullname,
	WSS_Name,
	WSS_ReplaceWeapon,
	WSS_VModel,
	WSS_WModel,
	
	WSS_Max
};
enum CWM_AttackType {
	WSA_None,
	WSA_Automatic,
	WSA_SemiAutomatic,
	WSA_LockAndLoad,
	
	WSA_Max
};
enum CWM_BulletType {
	WSB_None,
	WSB_Primary,
	WSB_Secondary,
	
	WSB_Max
};
enum CWM_ReloadType {
	WSR_Automatic,
	WSR_OneByOne,
	WSR_Background,
	
	WSR_Max
};
enum CWM_HookType {
	WSH_Draw,
	WSH_Attack,
	WSH_AttackPost,
	WSH_Attack2,
	WSH_Attack3,
	WSH_Reload,
	WSH_Idle,
	WSH_Empty,
	WSH_Max
};
typeset CWM_HookTypeForward {
	function void(int client, int entity);					// WSH_Draw
	function Action(int client, int entity); 				// WSH_Attack 	 // Continue = attack, handled = pas d'attaque mais cooldown, stop = pas d'attaque ni de cooldown
	function void(int client, int entity);					// WSH_Reload
	function void(int client, int entity);					// WSH_Idle
	function void(int client, int entity);					// WSH_Empty
}

stock void CWM_Refill(int entity) {
	int id = CWM_GetEntityInt(entity, WSI_Identifier);
	if( id >= 0 ) {
		CWM_SetEntityInt(entity, WSI_Bullet, CWM_GetInt(id, WSI_MaxBullet));
		CWM_SetEntityInt(entity, WSI_Ammunition, CWM_GetInt(id, WSI_MaxAmmunition));
	}
}
stock void AddModelToDownloadsTable(char file[PLATFORM_MAX_PATH]) {
	char tmp[PLATFORM_MAX_PATH], tmp2[PLATFORM_MAX_PATH];
	int len = strlen(file);
	strcopy(tmp, sizeof(tmp), file);
	
	ReplaceString(tmp, len, ".mdl", "", true);
	Format(tmp2, sizeof(tmp2), "%s.mdl", tmp);		if( FileExists(tmp2, true) ) AddFileToDownloadsTable(tmp2);
	Format(tmp2, sizeof(tmp2), "%s.phy", tmp);		if( FileExists(tmp2, true) ) AddFileToDownloadsTable(tmp2);
	Format(tmp2, sizeof(tmp2), "%s.vvd", tmp);		if( FileExists(tmp2, true) ) AddFileToDownloadsTable(tmp2);
	Format(tmp2, sizeof(tmp2), "%s.dx90.vtx", tmp); if( FileExists(tmp2, true) ) AddFileToDownloadsTable(tmp2);
}
stock void AddMaterialToDownloadsTable(char file[PLATFORM_MAX_PATH]) {
	char tmp[PLATFORM_MAX_PATH], tmp2[PLATFORM_MAX_PATH];
	int len = strlen(file);
	strcopy(tmp, sizeof(tmp), file);
	
	ReplaceString(tmp, len, ".vmt", "", true);
	Format(tmp2, sizeof(tmp2), "%s.vmt", tmp);		if( FileExists(tmp2, true) ) AddFileToDownloadsTable(tmp2);
	Format(tmp2, sizeof(tmp2), "%s.vtf", tmp);		if( FileExists(tmp2, true) ) AddFileToDownloadsTable(tmp2);
}
stock void AddSoundToDownloadsTable(char file[PLATFORM_MAX_PATH]) {
	char tmp[PLATFORM_MAX_PATH];
	Format(tmp, sizeof(tmp), "sound/%s", file);
	if( FileExists(tmp, true) )
		AddFileToDownloadsTable(tmp);
}
#if defined _tsxrp_included_
#else
public Action Cmd_PluginReloadSelf(int args) {
	static char name[64];
	GetPluginFilename(INVALID_HANDLE, name, sizeof(name));
	ServerCommand("sm plugins reload %s", name);
	return Plugin_Continue;
}
stock float GetCmdArgFloat(int index) {
	static char arg[32];
	GetCmdArg(index, arg, sizeof(arg));
	return StringToFloat(arg);
}
stock int GetCmdArgInt(int index) {
	static char arg[32];
	GetCmdArg(index, arg, sizeof(arg));
	return StringToInt(arg);
}
stock bool IsValidClient(int client) {
	if (client <= 0 || client > MaxClients)
		return false;
	
	if (!IsValidEdict(client) || !IsClientConnected(client))
		return false;
	
	return true;
}
#endif
stock bool IsClientZooming(int client) {
	int fov = GetEntProp(client, Prop_Send, "m_iFOV");
	if( fov == 0 || fov == 90 )
		return false;
	return true;
}
