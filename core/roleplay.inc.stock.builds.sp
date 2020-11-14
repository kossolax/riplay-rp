#if defined _roleplay_stock_build_included
#endinput
#endif
#define _roleplay_stock_build_included

#if defined ROLEPLAY_SUB
	#include "../roleplay.sp"
#else
	#include "roleplay.sp"
#endif


public int Native_rp_WeaponMenu_GetOwner(Handle plugin, int numParams) {
	return g_iOriginOwner[GetNativeCell(1)];
}
public int Native_rp_WeaponMenu_Create(Handle plugin, int numParams) {
	DataPack hBuyMenu = new DataPack();
	hBuyMenu.WriteCell(0);
	DataPackPos pos = hBuyMenu.Position;
	hBuyMenu.Reset();
	hBuyMenu.WriteCell(pos);
	return view_as<int>(hBuyMenu);
}
public int Native_rp_WeaponMenu_Clear(Handle plugin, int numParams) {
	DataPack hBuyMenu = view_as<DataPack>(GetNativeCellRef(1));
	delete hBuyMenu;
	hBuyMenu = null;
	SetNativeCellRef(1, hBuyMenu);
}

public int Native_rp_WeaponMenu_Reset(Handle plugin, int numParams) {
	DataPack hBuyMenu = view_as<DataPack>(GetNativeCell(1));
	hBuyMenu.Reset();
}
public int Native_rp_WeaponMenu_SetPosition(Handle plugin, int numParams) {
	DataPack hBuyMenu = view_as<DataPack>(GetNativeCell(1));
	hBuyMenu.Reset();
	hBuyMenu.Position = GetNativeCell(2);
}
public int Native_rp_WeaponMenu_GetPosition(Handle plugin, int numParams) {
	DataPack hBuyMenu = view_as<DataPack>(GetNativeCell(1));
	return view_as<int>(hBuyMenu.Position);
}
public int Native_rp_WeaponMenu_GetMax(Handle plugin, int numParams) {
	DataPack hBuyMenu = view_as<DataPack>(GetNativeCell(1));
	hBuyMenu.Reset();
	return hBuyMenu.ReadCell();
}
stock bool rp_WeaponMenu_CanBeAdded(int weaponID, int owner=0) {
	if( rp_GetWeaponStorage(weaponID) == true ){
		if(owner == 0 || owner > 2000){
			return false;
		}
	}
	
	return true;
}
public int Native_rp_WeaponMenu_Add(Handle plugin, int numParams) {
	DataPack hBuyMenu = view_as<DataPack>(GetNativeCell(1));
	int weaponID = GetNativeCell(2);
	int owner = GetNativeCell(3);
	
	if( !rp_WeaponMenu_CanBeAdded(weaponID, owner) ){
		return view_as<bool>(false);
	}
	
	char weapon[BM_WeaponNameSize];
	int index = GetEntProp(weaponID, Prop_Send, "m_iItemDefinitionIndex");
	CSGO_GetItemDefinitionNameByIndex(index, weapon, sizeof(weapon));
	if( StrEqual(weapon, "weapon_default") ) {
		GetEntityClassname(weaponID, weapon, sizeof(weapon));
	}
	if( StrContains(weapon, "weapon_knife") == 0 || StrContains(weapon, "weapon_bayonet") == 0 ) {
		Format(weapon, sizeof(weapon), "weapon_knife");
	}
	ReplaceString(weapon, sizeof(weapon), "weapon_", "");
	
	int[] data = new int[view_as<int>(BM_Max)];
	
	data[view_as<int>(BM_Owner)] = owner;
	data[view_as<int>(BM_Prix)] = 50 + rp_GetWeaponPrice(weaponID) / 4;
	data[view_as<int>(BM_Munition)] = Weapon_GetPrimaryClip(weaponID);
	data[view_as<int>(BM_Chargeur)] = GetEntProp(weaponID, Prop_Send, "m_iPrimaryReserveAmmoCount");
	data[view_as<int>(BM_PvP)] = rp_GetWeaponGroupID(weaponID);
	data[view_as<int>(BM_Type)] = view_as<int>(rp_GetWeaponBallType(weaponID));

	if(rp_GetWeaponStorage(weaponID)){
		data[view_as<int>(BM_Prix)] = 0;
	}
	
	hBuyMenu.Reset();
	DataPackPos pos = hBuyMenu.ReadCell();
	hBuyMenu.Position = pos;
	hBuyMenu.WriteString(weapon);
	for (int i = 0; i < view_as<int>(BM_Max); i++) {
		hBuyMenu.WriteCell(data[i]);
	}
	pos = hBuyMenu.Position;
	hBuyMenu.Reset();
	hBuyMenu.WriteCell(pos);
	
	return view_as<bool>(true);
}
public int Native_rp_WeaponMenu_Delete(Handle plugin, int numParams) {
	DataPack hBuyMenu = view_as<DataPack>(GetNativeCellRef(1));
	DataPackPos pos = GetNativeCell(2);
	
	hBuyMenu.Reset();
	DataPackPos max = hBuyMenu.ReadCell();
	DataPackPos position = hBuyMenu.Position;
	
	DataPack clone = new DataPack();
	clone.WriteCell(0);
	
	char weapon[BM_WeaponNameSize];
	int[] data = new int[view_as<int>(BM_Max)];
	 
	while( position < max ) {
		
	
		hBuyMenu.ReadString(weapon, sizeof(weapon));
		for (int i = 0; i < view_as<int>(BM_Max); i++) {
			data[i] = hBuyMenu.ReadCell();
		}
		
		if( position != pos) {
			clone.WriteString(weapon);
			for (int i = 0; i < view_as<int>(BM_Max); i++) {
				 clone.WriteCell(data[i]);
			}
		}
		
		position = hBuyMenu.Position;
	}
	position = clone.Position;
	clone.Reset();
	clone.WriteCell(position);
	delete hBuyMenu;
	SetNativeCellRef(1, clone);
}
public int Native_rp_WeaponMenu_Get(Handle plugin, int numParams) {
	DataPack hBuyMenu = view_as<DataPack>(GetNativeCell(1));
	DataPackPos pos = GetNativeCell(2);
	
	char weapon[BM_WeaponNameSize];
	int[] data = new int[view_as<int>(BM_Max)];
	hBuyMenu.Position = pos;
	hBuyMenu.ReadString(weapon, sizeof(weapon));
	
	for (int i = 0; i < view_as<int>(BM_Max); i++) {
		data[i] = hBuyMenu.ReadCell();
	}
	SetNativeString(3, weapon, sizeof(weapon));
	SetNativeArray(4, data, view_as<int>(BM_Max));
}


public Action WeaponEquip(int client, int weapon) {
	if( g_iOriginOwner[weapon] <= 0 ) {
		g_iOriginOwner[weapon]  = client;
	}
}

void showGraveMenu(int client) {
	char tmp[128];
	if( !g_bUserData[client][b_HasGrave] )
		return;
	if( !IsPlayerAlive(client) )
		return;
	if( g_bIsInCaptureMode )
		return;
	
	
	Handle menu = CreateMenu(eventTombSwitch);
	SetMenuTitle(menu, "%T\n ", "Tomb_Dead", client);
	
	Format(tmp, sizeof(tmp), "%T", "Tomb_RespawnTomb", client);	AddMenuItem(menu, "tomb", tmp);
	Format(tmp, sizeof(tmp), "%T", "Tomb_RespawnMap", client);	AddMenuItem(menu, "any", tmp);
	
	SetMenuExitButton(menu, false);
	DisplayMenu(menu, client, 5);
}
bool CheckBuild(int client, bool showMsg = true) {
	if( IsInVehicle(client) ) {
		if( showMsg )
			CPrintToChat(client, ""...MOD_TAG..." %T", "Build_CannotHere", client);
		return false;
	}
	if(! (GetEntityFlags(client) & FL_ONGROUND) ) {
		if( showMsg )
			CPrintToChat(client, ""...MOD_TAG..." %T", "Build_CannotHere", client);
		return false;
	}
	if( g_iGrabbing[client] > 0 ) {
		if( showMsg )
			CPrintToChat(client, ""...MOD_TAG..." %T", "Build_Cannot_ForNow", client);
		return false;
	}
	if( g_iGroundEntity[client] > 0 ) {
		if( showMsg )
			CPrintToChat(client, ""...MOD_TAG..." %T", "Build_CannotHere", client);
		return false;
	}
	if( GetZoneBit(GetPlayerZone(client) ) & BITZONE_BLOCKBUILD ) {
		if( showMsg )
			CPrintToChat(client, ""...MOD_TAG..." %T", "Build_CannotHere", client);
		return false;
	}
	if( GetZoneBit(GetPlayerZone(client) ) & BITZONE_EVENT ) {
		if( showMsg )
			CPrintToChat(client, ""...MOD_TAG..." %T", "Build_CannotHere", client);
		return false;
	}
	return true;
}
