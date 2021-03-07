#if defined _eItems_included_
#endinput
#endif
#define _eItems_included_

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

native int      eItems_GetWeaponCount();
native int      eItems_GetPaintsCount();
native int      eItems_GetGlovesCount();


native bool     eItems_AreItemsSynced();
native bool     eItems_AreItemsSyncing();
native bool     eItems_ReSync();

forward void    eItems_OnItemsSynced();
forward void    eItems_OnWeaponGiven(const int client, const int iWeapon, const char[] szClassName, const int iWeaponDefIndex, const int iSlot, const bool Skinnable, const bool Knife);

/*              Weapons             */

    /*     Generic     */

native int      eItems_GetWeaponNumByDefIndex(int iDefIndex);
native int      eItems_GetWeaponNumByClassName(const char[] szClassName);
native int      eItems_GetWeaponNumByWeapon(int iWeapon);
native int      eItems_GetWeaponDefIndexByWeaponNum(int iWeaponNum);
native int      eItems_GetWeaponDefIndexByClassName(const char[] szClassName); 
native int      eItems_GetWeaponDefIndexByWeapon(int iWeapon); 
native bool     eItems_IsDefIndexKnife(int iDefIndex);
native int      eItems_GetActiveWeaponNum(int client);
native int      eItems_GetActiveWeaponDefIndex(int client);
native int      eItems_GetActiveWeapon(int client);
native int      eItems_GetActiveWeaponClassName(int client, char[] szBuffer, int iLength);
native bool     eItems_IsSkinnableDefIndex(int iDefIndex);
native int      eItems_FindWeaponByWeaponNum(int client, int iWeaponNum);
native int      eItems_FindWeaponByDefIndex(int client, int iDefIndex);
native int      eItems_FindWeaponByClassName(int client, const char[] szClassName);
native bool     eItems_RefillClipAmmo(int iWeapon);
native bool     eItems_RefillReserveAmmo(int iWeapon);
native bool     eItems_IsValidWeapon(int iWeapon);
native int      eItems_GiveWeapon(int client, const char[] szClassName, int iReserveAmmo = -1, int iClipAmmo = -1, int iSwitchTo = -1);
native bool     eItems_RemoveKnife(int client);
native bool     eItems_RemoveWeapon(int client, int iWeapon);
native int      eItems_RespawnWeapon(int client, int iWeapon);
native int      eItems_RespawnWeaponBySlot(int client, int iWeaponSlot);
native int      eItems_RemoveAllWeapons(int client, int iSkipSlot = -1);
native bool     eItems_SetWeaponAmmo(int iWeapon, int iReserveAmmo = -1, int iClipAmmo = -1);
native bool     eItems_SetAllWeaponsAmmoByClassName(const char[] szClassName, int iReserveAmmo = -1, int iClipAmmo = -1);
native bool     eItems_SetAllWeaponsAmmo(int iReserveAmmo = -1, int iClipAmmo = -1);
native bool     eItems_SetActiveWeapon(int client, int iWeapon);
native bool     eItems_DropWeapon(int client, int iWeapon);

    /*  ClassNames  */

native bool     eItems_GetWeaponClassNameByWeaponNum(int iWeaponNum, char[] szBuffer, int iLength);
native bool     eItems_GetWeaponClassNameByDefIndex(int iDefIndex, char[] szBuffer, int iLength);
native bool     eItems_GetWeaponClassNameByWeapon(int iWeapon, char[] szBuffer, int iLength);

    /*  DisplayNames    */

native bool     eItems_GetWeaponDisplayNameByWeaponNum(int iWeaponNum, char[] szBuffer, int iLength);
native bool     eItems_GetWeaponDisplayNameByDefIndex(int iDefIndex, char[] szBuffer, int iLength);
native bool     eItems_GetWeaponDisplayNameByWeapon(int iWeapon, char[] szBuffer, int iLength);
native bool     eItems_GetWeaponDisplayNameByClassName(const char[] szClassName, char[] szBuffer, int iLength);

    /*    ViewModel     */

native bool     eItems_GetWeaponViewModelByWeaponNum(int iWeaponNum, char[] szBuffer, int iLength);
native bool     eItems_GetWeaponViewModelByDefIndex(int iDefIndex, char[] szBuffer, int iLength);
native bool     eItems_GetWeaponViewModelByWeapon(int iWeapon, char[] szBuffer, int iLength);
native bool     eItems_GetWeaponViewModelByClassName(const char[] szClassName, char[] szBuffer, int iLength);

    /*    WorldModel     */

native bool     eItems_GetWeaponWorldModelByWeaponNum(int iWeaponNum, char[] szBuffer, int iLength);
native bool     eItems_GetWeaponWorldModelByDefIndex(int iDefIndex, char[] szBuffer, int iLength);
native bool     eItems_GetWeaponWorldModelByWeapon(int iWeapon, char[] szBuffer, int iLength);
native bool     eItems_GetWeaponWorldModelByClassName(const char[] szClassName, char[] szBuffer, int iLength);

    /*     Slot     */

native int      eItems_GetWeaponSlotByWeaponNum(int iWeaponNum);
native int      eItems_GetWeaponSlotByDefIndex(int iDefIndex);
native int      eItems_GetWeaponSlotByWeapon(int iWeapon);
native int      eItems_GetWeaponSlotByClassName(const char[] szClassName);

    /*     Team     */

native int      eItems_GetWeaponTeamByWeaponNum(int iWeaponNum);
native int      eItems_GetWeaponTeamByDefIndex(int iDefIndex);
native int      eItems_GetWeaponTeamByWeapon(int iWeapon);
native int      eItems_GetWeaponTeamByClassName(const char[] szClassName);

    /*     Clip Ammo     */

native int      eItems_GetWeaponClipAmmoByWeaponNum(int iWeaponNum);
native int      eItems_GetWeaponClipAmmoByDefIndex(int iDefIndex);
native int      eItems_GetWeaponClipAmmoByWeapon(int iWeapon);
native int      eItems_GetWeaponClipAmmoByClassName(const char[] szClassName);

    /*     Reserve Ammo     */

native int      eItems_GetWeaponReserveAmmoByWeaponNum(int iWeaponNum);
native int      eItems_GetWeaponReserveAmmoByDefIndex(int iDefIndex);
native int      eItems_GetWeaponReserveAmmoByWeapon(int iWeapon);
native int      eItems_GetWeaponReserveAmmoByClassName(const char[] szClassName);

    /*     Price     */

native int      eItems_GetWeaponPriceByWeaponNum(int iWeaponNum);
native int      eItems_GetWeaponPriceByDefIndex(int iDefIndex);
native int      eItems_GetWeaponPriceByWeapon(int iWeapon);
native int      eItems_GetWeaponPriceByClassName(const char[] szClassName);

    /*     Max Player Speed     */

native int      eItems_GetWeaponMaxPlayerSpeedByWeaponNum(int iWeaponNum);
native int      eItems_GetWeaponMaxPlayerSpeedByDefIndex(int iDefIndex);
native int      eItems_GetWeaponMaxPlayerSpeedByWeapon(int iWeapon);
native int      eItems_GetWeaponMaxPlayerSpeedByClassName(const char[] szClassName);

    /*     Damage     */

native int      eItems_GetWeaponDamageByWeaponNum(int iWeaponNum);
native int      eItems_GetWeaponDamageByDefIndex(int iDefIndex);
native int      eItems_GetWeaponDamageByWeapon(int iWeapon);
native int      eItems_GetWeaponDamageByClassName(const char[] szClassName);

    /*     Full Auto     */

native bool     eItems_IsWeaponFullAutoByWeaponNum(int iWeaponNum);
native bool     eItems_IsWeaponFullAutoByDefIndex(int iDefIndex);
native bool     eItems_IsWeaponFullAutoByWeapon(int iWeapon);
native bool     eItems_IsWeaponFullAutoByClassName(const char[] szClassName);

    /*     Spread     */

native float    eItems_GetWeaponSpreadByWeaponNum(int iWeaponNum);
native float    eItems_GetWeaponSpreadByDefIndex(int iDefIndex);
native float    eItems_GetWeaponSpreadByWeapon(int iWeapon);
native float    eItems_GetWeaponSpreadByClassName(const char[] szClassName);

    /*     Cycle Time     */

native float    eItems_GetWeaponCycleTimeByWeaponNum(int iWeaponNum);
native float    eItems_GetWeaponCycleTimeByDefIndex(int iDefIndex);
native float    eItems_GetWeaponCycleTimeByWeapon(int iWeapon);
native float    eItems_GetWeaponCycleTimeByClassName(const char[] szClassName);


/*              Skins             */

native bool     eItems_IsSkinNumGloveApplicable(int iSkinNum);
native int      eItems_GetSkinNumByDefIndex(int iDefIndex);
native int      eItems_GetSkinDefIndexBySkinNum(int iSkinNum);
native bool     eItems_GetSkinDisplayNameByDefIndex(int iDefIndex, char[] szBuffer, int iLength);
native bool     eItems_GetSkinDisplayNameBySkinNum(int iSkinNum, char[] szBuffer, int iLength);
native bool     eItems_IsNativeSkin(int iSkinNum, int iItemNum, int iItemType);

/*              Gloves             */

native int      eItems_GetGlovesNumByDefIndex(int iDefIndex);
native int      eItems_GetGlovesDefIndexByGlovesNum(int iGlovesNum);
native bool     eItems_GetGlovesDisplayNameByDefIndex(int iDefIndex, char[] szBuffer, int iLength);
native bool     eItems_GetGlovesDisplayNameByGlovesNum(int iGlovesNum, char[] szBuffer, int iLength);

native bool     eItems_GetGlovesViewModelByGlovesNum(int iGlovesNum, char[] szBuffer, int iLength);
native bool     eItems_GetGlovesViewModelByDefIndex(int iDefIndex, char[] szBuffer, int iLength);
native bool     eItems_GetGlovesWorldModelByGlovesNum(int iGlovesNum, char[] szBuffer, int iLength);
native bool     eItems_GetGlovesWorldModelByDefIndex(int iDefIndex, char[] szBuffer, int iLength);
native int      eItems_GetGlovesNumBySkinNum(int iSkinNum);

