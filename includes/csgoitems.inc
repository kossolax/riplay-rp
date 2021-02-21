#if defined _csgoitems_included_
#endinput
#endif
#define _csgoitems_included_


public SharedPlugin __pl_csgoitems = 
{
	name = "CSGO_Items", 
	file = "CSGO_Items.smx", 
	#if defined REQUIRE_PLUGIN
	required = 1, 
	#else
	required = 0, 
	#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_csgoitems_SetNTVOptional() {
	MarkNativeAsOptional("CSGOItems_IsValidWeapon");
	MarkNativeAsOptional("CSGOItems_GiveWeapon");
}
#endif

#define SEQUENCE_DEFAULT_DRAW 0
#define SEQUENCE_DEFAULT_IDLE1 1
#define SEQUENCE_DEFAULT_IDLE2 2
#define SEQUENCE_DEFAULT_LIGHT_MISS1 3
#define SEQUENCE_DEFAULT_LIGHT_MISS2 4
#define SEQUENCE_DEFAULT_LIGHT_HIT1 5
#define SEQUENCE_DEFAULT_LIGHT_HIT2 6
#define SEQUENCE_DEFAULT_LIGHT_BACKSTAB1 7
#define SEQUENCE_DEFAULT_LIGHT_BACKSTAB2 8
#define SEQUENCE_DEFAULT_HEAVY_MISS1 9
#define SEQUENCE_DEFAULT_HEAVY_HIT1 10
#define SEQUENCE_DEFAULT_HEAVY_BACKSTAB1 11
#define SEQUENCE_DEFAULT_LOOKAT01 12

#define SEQUENCE_BUTTERFLY_DRAW1 0
#define SEQUENCE_BUTTERFLY_DRAW2 1
#define SEQUENCE_BUTTERFLY_IDLE1 2
#define SEQUENCE_BUTTERFLY_IDLE2 3
#define SEQUENCE_BUTTERFLY_LIGHT_MISS1 4
#define SEQUENCE_BUTTERFLY_LIGHT_MISS2 5
#define SEQUENCE_BUTTERFLY_LIGHT_HIT1 6
#define SEQUENCE_BUTTERFLY_LIGHT_HIT2 7
#define SEQUENCE_BUTTERFLY_LIGHT_BACKSTAB1 8
#define SEQUENCE_BUTTERFLY_LIGHT_BACKSTAB2 9
#define SEQUENCE_BUTTERFLY_HEAVY_MISS1 10
#define SEQUENCE_BUTTERFLY_HEAVY_HIT1 11
#define SEQUENCE_BUTTERFLY_HEAVY_BACKSTAB1 12
#define SEQUENCE_BUTTERFLY_LOOKAT01 13
#define SEQUENCE_BUTTERFLY_LOOKAT02 14
#define SEQUENCE_BUTTERFLY_LOOKAT03 15

#define SEQUENCE_FALCHION_IDLE1 1
#define SEQUENCE_FALCHION_HEAVY_MISS1 8
#define SEQUENCE_FALCHION_HEAVY_MISS1_NOFLIP 9
#define SEQUENCE_FALCHION_LOOKAT01 12
#define SEQUENCE_FALCHION_LOOKAT02 13

#define SEQUENCE_DAGGERS_DRAW 0
#define SEQUENCE_DAGGERS_IDLE1 1
#define SEQUENCE_DAGGERS_LIGHT_MISS1 2
#define SEQUENCE_DAGGERS_LIGHT_MISS2 3
#define SEQUENCE_DAGGERS_LIGHT_MISS3 4
#define SEQUENCE_DAGGERS_LIGHT_MISS4 5
#define SEQUENCE_DAGGERS_LIGHT_MISS5 6
#define SEQUENCE_DAGGERS_LIGHT_HIT1 7
#define SEQUENCE_DAGGERS_LIGHT_HIT2 8
#define SEQUENCE_DAGGERS_LIGHT_BACKSTAB1 9
#define SEQUENCE_DAGGERS_LIGHT_BACKSTAB2 10
#define SEQUENCE_DAGGERS_HEAVY_MISS1 11
#define SEQUENCE_DAGGERS_HEAVY_MISS2 12
#define SEQUENCE_DAGGERS_HEAVY_HIT1 13
#define SEQUENCE_DAGGERS_HEAVY_BACKSTAB1 14
#define SEQUENCE_DAGGERS_LOOKAT01 15

#define SEQUENCE_BOWIE_DRAW 0
#define SEQUENCE_BOWIE_IDLE1 1
#define SEQUENCE_BOWIE_LIGHT_MISS1 2
#define SEQUENCE_BOWIE_LIGHT_MISS2 3
#define SEQUENCE_BOWIE_LIGHT_HIT1 4
#define SEQUENCE_BOWIE_LIGHT_HIT2 5
#define SEQUENCE_BOWIE_LIGHT_BACKSTAB1 6
#define SEQUENCE_BOWIE_LIGHT_BACKSTAB2 7
#define SEQUENCE_BOWIE_HEAVY_MISS1 8
#define SEQUENCE_BOWIE_HEAVY_HIT1 9
#define SEQUENCE_BOWIE_HEAVY_BACKSTAB1 10
#define SEQUENCE_BOWIE_LOOKAT01 11

#define ITEMTYPE_WEAPON 0
#define ITEMTYPE_GLOVES 1
#define ITEMTYPE_PAINTKIT 2
#define ITEMTYPE_SPRAY 3
#define ITEMTYPE_MUSICKIT 4

native int CSGOItems_GetWeaponCount();
native int CSGOItems_GetMusicKitCount();
native int CSGOItems_GetSkinCount();
native int CSGOItems_GetGlovesCount();
native int CSGOItems_GetSprayCount();
native int CSGOItems_GetGlovesPaintCount();
native int CSGOItems_GetActiveWeaponCount(const char[] szClassName, int iTeam = 0);

// WEAPONS
native int CSGOItems_GetWeaponNumByDefIndex(int iDefIndex);
native bool CSGOItems_GetWeaponNumByClassName(const char[] szClassName);
native int CSGOItems_GetWeaponNumByWeapon(int iWeapon);
native int CSGOItems_GetWeaponDefIndexByWeaponNum(int iWeaponNum);
native bool CSGOItems_GetWeaponDefIndexByClassName(const char[] szClassName);
native bool CSGOItems_GetWeaponClassNameByWeaponNum(int iWeaponNum, char[] szBuffer, int iLength);
native bool CSGOItems_GetWeaponClassNameByDefIndex(int iDefIndex, char[] szBuffer, int iLength);
native bool CSGOItems_GetWeaponClassNameByWeapon(int iWeapon, char[] szBuffer, int iLength);
native bool CSGOItems_GetWeaponDisplayNameByDefIndex(int iDefIndex, char[] szBuffer, int iLength);
native bool CSGOItems_GetWeaponDisplayNameByClassName(const char[] szClassName, char[] szBuffer, int iLength);
native bool CSGOItems_GetWeaponDisplayNameByWeaponNum(int iWeaponNum, char[] szBuffer, int iLength);
native bool CSGOItems_GetWeaponDisplayNameByWeapon(int iWeapon, char[] szBuffer, int iLength);
native bool CSGOItems_GetWeaponViewModelByWeaponNum(int iWeaponNum, char[] szBuffer, int iLength);
native bool CSGOItems_GetWeaponViewModelByWeapon(int iWeapon, char[] szBuffer, int iLength);
native bool CSGOItems_GetWeaponViewModelByDefIndex(int iDefIndex, char[] szBuffer, int iLength);
native bool CSGOItems_GetWeaponViewModelByClassName(const char[] szClassName, char[] szBuffer, int iLength);
native bool CSGOItems_GetWeaponWorldModelByWeaponNum(int iWeaponNum, char[] szBuffer, int iLength);
native bool CSGOItems_GetWeaponWorldModelByWeapon(int iWeapon, char[] szBuffer, int iLength);
native bool CSGOItems_GetWeaponWorldModelByDefIndex(int iDefIndex, char[] szBuffer, int iLength);
native bool CSGOItems_GetWeaponWorldModelByClassName(const char[] szClassName, char[] szBuffer, int iLength);
native bool CSGOItems_IsDefIndexKnife(int iDefIndex);
native int CSGOItems_GetWeaponDefIndexByWeapon(int iWeapon);
native int CSGOItems_GetActiveWeapon(int iClient);
native int CSGOItems_GetActiveWeaponDefIndex(int iClient);
native bool CSGOItems_GetActiveClassName(int iClient, char[] szBuffer, int iLength);
native bool CSGOItems_IsSkinnableDefIndex(int iDefIndex);
native int CSGOItems_FindWeaponByClassName(int iClient, const char[] szClassName);
native int CSGOItems_FindWeaponByWeaponNum(int iClient, int iWeaponNum);
native int CSGOItems_FindWeaponByDefIndex(int iClient, int iDefIndex);
native int CSGOItems_GetActiveWeaponNum(int iClient);
native int CSGOItems_GetWeaponSlotByWeaponNum(int iWeaponNum);
native int CSGOItems_GetWeaponSlotByWeapon(int iWeapon);
native int CSGOItems_GetWeaponSlotByClassName(const char[] szClassName);
native int CSGOItems_GetWeaponSlotByDefIndex(int iDefIndex);
native int CSGOItems_GetWeaponTeamByDefIndex(int iDefIndex);
native int CSGOItems_GetWeaponTeamByClassName(const char[] szClassName);
native int CSGOItems_GetWeaponTeamByWeaponNum(int iWeaponNum);
native int CSGOItems_GetWeaponTeamByWeapon(int iWeapon);
native int CSGOItems_GetWeaponClipAmmoByDefIndex(int iDefIndex);
native int CSGOItems_GetWeaponClipAmmoByClassName(const char[] szClassName);
native int CSGOItems_GetWeaponClipAmmoByWeaponNum(int iWeaponNum);
native int CSGOItems_GetWeaponClipAmmoByWeapon(int iWeapon);
native int CSGOItems_GetWeaponReserveAmmoByDefIndex(int iDefIndex);
native int CSGOItems_GetWeaponReserveAmmoByClassName(const char[] szClassName);
native int CSGOItems_GetWeaponReserveAmmoByWeaponNum(int iWeaponNum);
native int CSGOItems_GetWeaponReserveAmmoByWeapon(int iWeapon);
native int CSGOItems_GetWeaponKillAwardByDefIndex(int iDefIndex);
native int CSGOItems_GetWeaponKillAwardByClassName(const char[] szClassName);
native int CSGOItems_GetWeaponKillAwardByWeaponNum(int iWeaponNum);
native int CSGOItems_GetWeaponKillAwardByWeapon(int iWeapon);
native float CSGOItems_GetWeaponSpreadByDefIndex(int iDefIndex);
native float CSGOItems_GetWeaponSpreadByClassName(const char[] szClassName);
native float CSGOItems_GetWeaponSpreadByWeaponNum(int iWeaponNum);
native float CSGOItems_GetWeaponSpreadByWeapon(int iWeapon);
native float CSGOItems_GetWeaponCycleTimeByDefIndex(int iDefIndex);
native float CSGOItems_GetWeaponCycleTimeByClassName(const char[] szClassName);
native float CSGOItems_GetWeaponCycleTimeByWeaponNum(int iWeaponNum);
native float CSGOItems_GetWeaponCycleTimeByWeapon(int iWeapon);
native bool CSGOItems_GetItemSetNumByClassName(const char[] szClassName, char[] szBuffer, int iLength);
native bool CSGOItems_GetItemSetDisplayNameByClassName(const char[] szClassName, char[] szBuffer, int iLength);
native bool CSGOItems_GetItemSetDisplayNameByItemSetNum(int iSetNum, char[] szBuffer, int iLength);
native bool CSGOItems_RefillClipAmmo(int iWeapon);
native bool CSGOItems_RefillReserveAmmo(int iWeapon);
native bool CSGOItems_IsValidWeapon(int iWeapon);
native int CSGOItems_GiveWeapon(int iClient, const char[] szClassName, int iReserveAmmo = -1, int iClipAmmo = -1, int iSwitchTo = -1);
native int CSGOItems_RespawnWeapon(int iClient, int iWeapon);
native int CSGOItems_RespawnWeaponBySlot(int iClient, int iWeaponSlot);
native bool CSGOItems_RemoveKnife(int iClient);
native bool CSGOItems_RemoveWeapon(int iClient, int iWeapon);
native int CSGOItems_RemoveAllWeapons(int iClient, int iSkipSlot = -1);
native bool CSGOItems_SetWeaponAmmo(int iWeapon, int iReserveAmmo = -1, int iClipAmmo = -1);
native int CSGOItems_SetAllWeaponsAmmo(const char[] szClassName, int iReserveAmmo = -1, int iClipAmmo = -1);
native bool CSGOItems_SetActiveWeapon(int iClient, int iWeapon);
native bool CSGOItems_DropWeapon(int iClient, int iWeapon);
native int CSGOItems_GetActiveWeaponSlot(int iClient);
native bool CSGOItems_AreItemsSynced();
native bool CSGOItems_AreItemsSyncing();
native bool CSGOItems_ReSync();
native int CSGOItems_GetRandomSkin();

// SKINS
native bool CSGOItems_IsSkinNumGloveApplicable(int iSkinNum);
native int CSGOItems_GetSkinNumByDefIndex(int iDefIndex);
native int CSGOItems_GetSkinDefIndexBySkinNum(int iSkinNum);
native bool CSGOItems_GetSkinDisplayNameByDefIndex(int iDefIndex, char[] szBuffer, int iLength);
native bool CSGOItems_GetSkinDisplayNameBySkinNum(int iSkinNum, char[] szBuffer, int iLength);
native bool CSGOItems_GetSkinVmtPathBySkinNum(int iSkinNum, char[] szBuffer, int iLength);
native bool CSGOItems_IsNativeSkin(int iSkinNum, int iItemNum, int iItemType);
native int CSGOItems_GetWeaponNumBySkinNum(int iSkinNum);

// Gloves
native int CSGOItems_GetGlovesNumByDefIndex(int iDefIndex);
native bool CSGOItems_GetGlovesNumByClassName(const char[] szClassName);
native int CSGOItems_GetGlovesDefIndexByGlovesNum(int iGlovesNum);
native bool CSGOItems_GetGlovesDisplayNameByDefIndex(int iDefIndex, char[] szBuffer, int iLength);
native bool CSGOItems_GetGlovesDisplayNameByGlovesNum(int iGlovesNum, char[] szBuffer, int iLength);

native bool CSGOItems_GetGlovesViewModelByGlovesNum(int iGlovesNum, char[] szBuffer, int iLength);
native bool CSGOItems_GetGlovesViewModelByDefIndex(int iDefIndex, char[] szBuffer, int iLength);
native bool CSGOItems_GetGlovesWorldModelByGlovesNum(int iGlovesNum, char[] szBuffer, int iLength);
native bool CSGOItems_GetGlovesWorldModelByDefIndex(int iDefIndex, char[] szBuffer, int iLength);
native int CSGOItems_GetGlovesNumBySkinNum(int iSkinNum);

// Sprays
native int CSGOItems_GetSprayNumByDefIndex(int iDefIndex);
native int CSGOItems_GetSprayDefIndexBySprayNum(int iSprayNum);

native int CSGOItems_GetSprayCacheIndexByDefIndex(int iDefIndex);
native int CSGOItems_GetSprayCacheIndexBySprayNum(int iSprayNum);

native bool CSGOItems_GetSprayDisplayNameByDefIndex(int iDefIndex, char[] szBuffer, int iLength);
native bool CSGOItems_GetSprayDisplayNameBySprayNum(int iSprayNum, char[] szBuffer, int iLength);

native bool CSGOItems_GetSprayVMTBySprayNum(int iSprayNum, char[] szBuffer, int iLength);
native bool CSGOItems_GetSprayVMTByDefIndex(int iDefIndex, char[] szBuffer, int iLength);
native bool CSGOItems_GetSprayVTFBySprayNum(int iSprayNum, char[] szBuffer, int iLength);
native bool CSGOItems_GetSprayVTFByDefIndex(int iSprayNum, char[] szBuffer, int iLength);

// MUSIC KITS
native int CSGOItems_GetMusicKitNumByDefIndex(int iDefIndex);
native int CSGOItems_GetMusicKitDefIndexByMusicKitNum(int iMusicKitNum);
native bool CSGOItems_GetMusicKitDisplayNameByDefIndex(int iDefIndex, char[] szBuffer, int iLength);
native bool CSGOItems_GetMusicKitDisplayNameByMusicKitNum(int iMusicKitNum, char[] szBuffer, int iLength); 