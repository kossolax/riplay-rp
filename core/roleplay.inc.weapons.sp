#if defined _roleplay_weapons_included
#endinput
#endif
#define _roleplay_weapons_included

#if defined ROLEPLAY_SUB
	#include "../roleplay.sp"
#else
	#include "roleplay.sp"
#endif

public Action Strip_Weapon(Handle timer, any client) {
	StripWeaponsButKnife(client);
}
void StripWeaponsButKnife(int client ){
	int wepIdx;
	
	for( int i = 0; i < 5; i++ ){
		if( i == CS_SLOT_KNIFE ) continue; 
		if( i == CS_SLOT_C4 ) continue;
		
		while( ( wepIdx = GetPlayerWeaponSlot( client, i ) ) != -1 ) {
			RemovePlayerItem( client, wepIdx );
			RemoveEdict( wepIdx );
		}
	}
	
	Client_RemoveWeapon(client, "weapon_taser");	
	FakeClientCommand(client, "use weapon_knife");
	FakeClientCommand(client, "use weapon_knifegg");	
}
void RedrawWeapon(int target) {
	char weapon[64];
	
	int id = WeaponsGetDeployedWeaponIndex(target);
	int index = GetEntProp(id, Prop_Send, "m_iItemDefinitionIndex");
	CSGO_GetItemDefinitionNameByIndex(index, weapon, sizeof(weapon));
	
	enum_ball_type wep_type = g_iWeaponsBallType[id];
	int g = g_iWeaponsGroup[id];
	int s = g_iWeaponFromStore[id];
	
	RemovePlayerItem(target, id );
	RemoveEdict( id );
	
	
	id = GivePlayerItem(target, weapon);
	g_iWeaponsBallType[id] = wep_type;
	g_iWeaponsGroup[id] = g;
	g_iWeaponFromStore[id] = s;
}

bool IsAmmunition(int ent) {
	if( !IsValidEdict(ent) )
		return false;
	if( !IsValidEntity(ent) )
		return false;
	if( IsValidClient(ent) )
		return false;
	
	char classname[64];
	GetEdictClassname(ent, classname, sizeof(classname));
	
	if( StrEqual(classname, "rp_weaponbox") ) {
		return true;
	}
	
	return false;
}
