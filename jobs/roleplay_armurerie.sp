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
#include <csgo_items>   // https://forums.alliedmods.net/showthread.php?t=243009
#include <colors_csgo>	// https://forums.alliedmods.net/showthread.php?p=2205447#post2205447
#include <smlib>		// https://github.com/bcserv/smlib

#pragma newdecls required
#include <roleplay.inc>	// https://www.ts-x.eu


public Plugin myinfo = {
	name = "Jobs: Armurerier", author = "KoSSoLaX",
	description = "RolePlay - Jobs: Armurerier",
	version = __LAST_REV__, url = "https://www.ts-x.eu"
};

float vecNull[3];
int g_cBeam;
int g_iClientColor[65][4];
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
	LoadTranslations("roleplay.armurerie.phrases");
	
	RegServerCmd("rp_quest_reload", Cmd_Reload);
	RegServerCmd("rp_giveitem",			Cmd_GiveItem,			"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_giveitem_pvp",		Cmd_GiveItemPvP,		"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_balltype",	Cmd_ItemBallType,		"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_redraw",		Cmd_ItemRedraw,			"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_sanandreas",	Cmd_ItemSanAndreas,		"RP-ITEM",	FCVAR_UNREGISTERED);
	
	for (int i = 1; i <= MaxClients; i++)
		if( IsValidClient(i) )
			OnClientPostAdminCheck(i);
}
public void OnMapStart() {
	g_cBeam = PrecacheModel("materials/sprites/laserbeam.vmt", true);
}
// ----------------------------------------------------------------------------
public Action Cmd_GiveItem(int args) {
	
	char Arg1[64];
	GetCmdArg(1, Arg1, sizeof(Arg1));
	int client = GetCmdArgInt(2);
	int item_id = GetCmdArgInt(args);
		
	if( StrEqual(Arg1, "weapon_usp") || StrEqual(Arg1, "weapon_p228") || StrEqual(Arg1, "weapon_m3") || StrEqual(Arg1, "weapon_galil") || StrEqual(Arg1, "weapon_scout") ) {
		ITEM_CANCEL(client, item_id);
		return Plugin_Handled;
	}
	if( StrEqual(Arg1, "weapon_sg552") || StrEqual(Arg1, "weapon_sg550") || StrEqual(Arg1, "weapon_tmp") || StrEqual(Arg1, "weapon_mp5navy") ) {
		ITEM_CANCEL(client, item_id);
		return Plugin_Handled;
	}
	
	if( Weapon_ShouldBeEquip(Arg1) && Client_HasWeapon(client, Arg1) ) {
		ITEM_CANCEL(client, item_id);
		return Plugin_Handled;
	}
	
	if( (StrContains(Arg1, "weapon_knife") == 0 || StrContains(Arg1, "weapon_bayonet") == 0) && Client_HasWeapon(client, "weapon_knife") ) {
		ITEM_CANCEL(client, item_id);
		return Plugin_Handled;
	}
	
	int ent = GivePlayerItem(client, Arg1);
	
	if( Weapon_ShouldBeEquip(Arg1) )
		EquipPlayerWeapon(client, ent);
	
	
	if( StrContains(Arg1, "weapon_taser") == 0 ) {
		Weapon_SetPrimaryClip(ent, 1000);
		SDKHook(ent, SDKHook_Reload, OnWeaponReload);
	}
	
	return Plugin_Handled;
}
public Action Cmd_GiveItemPvP(int args) {
	
	char Arg1[64];
	GetCmdArg(1, Arg1, sizeof(Arg1));
	
	int client = GetCmdArgInt(2);
	int wpnID = GivePlayerItem(client, Arg1);	
	int group = rp_GetClientGroupID(client);
	rp_SetWeaponGroupID(wpnID, group);
}
// ----------------------------------------------------------------------------
public Action Cmd_ItemBallType(int args) {
	
	char arg1[32];
	GetCmdArg(1, arg1, sizeof(arg1));
	
	int client = GetCmdArgInt(2);
	int wepid = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	int item_id = GetCmdArgInt(args);
	
	
	if( !IsValidEntity(wepid) ) {
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Armu_WeaponInHands", client);
		ITEM_CANCEL(client, item_id);
		return Plugin_Handled;
	}
	
	char classname[64];
	GetEdictClassname(wepid, classname, sizeof(classname));
	if( Weapon_ShouldBeEquip(classname) ) {
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Armu_WeaponInHands", client);
		ITEM_CANCEL(client, item_id);
		return Plugin_Handled;
	}
	
	if( rp_GetWeaponBallType(wepid) == ball_type_braquage ) {
		ITEM_CANCEL(client, item_id);
		return Plugin_Handled;
	}
	
	if( StrEqual(arg1, "fire") ) {
		rp_SetWeaponBallType(wepid, ball_type_fire);
	}
	else if( StrEqual(arg1, "caoutchouc") ) {
		rp_SetWeaponBallType(wepid, ball_type_caoutchouc);
	}
	else if( StrEqual(arg1, "paintball") ) {
		rp_SetWeaponBallType(wepid, ball_type_paintball);
	}
	else if( StrEqual(arg1, "poison") ) {
		rp_SetWeaponBallType(wepid, ball_type_poison);
	}
	else if( StrEqual(arg1, "vampire") ) {
		rp_SetWeaponBallType(wepid, ball_type_vampire);
	}
	else if( StrEqual(arg1, "reflex") ) {
		rp_SetWeaponBallType(wepid, ball_type_reflexive);
	}
	else if( StrEqual(arg1, "explode") ) {
		rp_SetWeaponBallType(wepid, ball_type_explode);
	}
	else if( StrEqual(arg1, "revitalisante") ) {
		rp_SetWeaponBallType(wepid, ball_type_revitalisante);
	}
	else if( StrEqual(arg1, "nosteal") ) {
		rp_SetWeaponBallType(wepid, ball_type_nosteal);
	}
	else if( StrEqual(arg1, "notk") ) {
		rp_SetWeaponBallType(wepid, ball_type_notk);
	}
	
	return Plugin_Handled;
}
public void OnClientPostAdminCheck(int client) {
	rp_HookEvent(client, RP_PostTakeDamageWeapon, fwdWeapon);
	rp_HookEvent(client, RP_OnPlayerBuild, fwdOnPlayerBuild);
}
public Action fwdOnPlayerBuild(int client, float& cooldown){
	if( rp_GetClientJobID(client) != 111 )
		return Plugin_Continue;

	int wep_id = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	char wep_name[32], tmp1[128], tmp2[128];
	GetEdictClassname(wep_id, wep_name, sizeof(wep_name));
	
	if( Weapon_ShouldBeEquip(wep_name) ) {
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Armu_WeaponInHands", client);
		return Plugin_Handled;
	}

	Handle menu = CreateMenu(ModifyWeapon);
	SetMenuTitle(menu, "%T\n ", "edit_weapon", client);
	
	char szMenu[][][] = {
		{"sanandreas",		"150",	"add_sanAndreas"},
		{"pvp",				"250",	"add_bullet_pvp"},
		{"fire",			"250",	"add_ball_type_fire"},
		{"caoutchouc",		"200",	"add_ball_type_caoutchouc"},
		{"poison",			"200",	"add_ball_type_poison"},
		{"vampire",			"200",	"add_ball_type_vampire"},
		{"paintball",		"50",	"add_ball_type_paintball"},
		{"reflexive",		"200",	"add_ball_type_reflexive"},
		{"explode", 		"300",	"add_ball_type_explode"},
		{"revitalisante",	"200",	"add_ball_type_revitalisante"},
		{"nosteal", 		"75",	"add_ball_type_nosteal"},
		{"notk", 			"50",	"add_ball_type_notk"},
		{"braquage",		"500",	"add_ball_type_braquage"}
	};
	
	for (int i = 0; i < sizeof(szMenu); i++) {
		Format(tmp1, sizeof(tmp1), "%s_%s", szMenu[i][0], szMenu[i][1]);
		Format(tmp2, sizeof(tmp2), "%T - %s$", szMenu[i][2], client, szMenu[i][1]);
		AddMenuItem(menu, tmp1, tmp2);
	}
	
	DisplayMenu(menu, client, 60);
	cooldown = 5.0;
	
	return Plugin_Stop;
}

public int ModifyWeapon(Handle p_hItemMenu, MenuAction p_oAction, int client, int p_iParam2) {

	if (p_oAction == MenuAction_Select) {
		char szMenuItem[32];
		if (GetMenuItem(p_hItemMenu, p_iParam2, szMenuItem, sizeof(szMenuItem))){

			char data[2][32];
			ExplodeString(szMenuItem, "_", data, sizeof(data), sizeof(data[]));

			char type[32];
			strcopy(type, 31, data[0]);
			int price = StringToInt(data[1]);
			int wep_id = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
			char wep_name[32];
			GetEdictClassname(wep_id, wep_name, sizeof(wep_name));

			if( Weapon_ShouldBeEquip(wep_name) ) {
				CPrintToChat(client, "" ...MOD_TAG... " %T", "Armu_WeaponInHands", client);
				return;
			}

			if(StrEqual(type, "pvp")){
				Handle menupvp = CreateMenu(ModifyWeaponPVP);
				char tmp[64], tmp2[64];
				SetMenuTitle(menupvp, "%T\n ", "edit_weapon_gang", client);
				for(int i=1; i<MAX_GROUPS; i+=10){
					for(int j=1;j< MAXPLAYERS+1;j++){
						if( !IsValidClient(j) )
							continue;
						if(rp_GetClientGroupID(j)==i){
							rp_GetGroupData(i, group_type_name, tmp, 63);
							Format(tmp2,63,"%i_%i",i,price);
							AddMenuItem(menupvp, tmp2, tmp);
							break;
						}
					}
				}
				DisplayMenu(menupvp, client, 60);
			}
			else{
				if((rp_GetClientInt(client, i_Bank)+rp_GetClientInt(client, i_Money)) >= price){
					rp_ClientMoney(client, i_Money, -price);
					CPrintToChat(client, "" ...MOD_TAG... " %T", "edit_weapon_done", client);
					rp_SetClientStat(client, i_TotalBuild, rp_GetClientStat(client, i_TotalBuild)+1);
				}
				else{
					CPrintToChat(client, ""...MOD_TAG..." %T", "Error_NotEnoughtMoney", client);
					return;
				}

				if(StrEqual(type, "fire")){
					rp_SetWeaponBallType(wep_id, ball_type_fire);
				}
				else if(StrEqual(type, "caoutchouc")){
					rp_SetWeaponBallType(wep_id, ball_type_caoutchouc);
				}
				else if(StrEqual(type, "poison")){
					rp_SetWeaponBallType(wep_id, ball_type_poison);
				}
				else if(StrEqual(type, "vampire")){
					rp_SetWeaponBallType(wep_id, ball_type_vampire);
				}
				else if(StrEqual(type, "reflexive")){
					rp_SetWeaponBallType(wep_id, ball_type_reflexive);
				}
				else if(StrEqual(type, "explode")){
					rp_SetWeaponBallType(wep_id, ball_type_explode);
				}
				else if(StrEqual(type, "revitalisante")){
					rp_SetWeaponBallType(wep_id, ball_type_revitalisante);
				}
				else if(StrEqual(type, "paintball")){
					rp_SetWeaponBallType(wep_id, ball_type_paintball);
				}
				else if(StrEqual(type, "nosteal")){
					rp_SetWeaponBallType(wep_id, ball_type_nosteal);
				}
				else if(StrEqual(type, "notk")){
					rp_SetWeaponBallType(wep_id, ball_type_notk);
				}
				else if(StrEqual(type, "reload")){
					ServerCommand("rp_item_redraw %i 74", client);
				}
				else if(StrEqual(type, "sanandreas")){
					int ammo = Weapon_GetPrimaryClip(wep_id);
					if( ammo >= 150 ) {
						CPrintToChat(client, "" ...MOD_TAG... " %T", "edit_weapon_sanAndreas", client, ammo);
						return;
					}
					ammo += 1000; if( ammo > 5000 ) ammo = 5000;
					Weapon_SetPrimaryClip(wep_id, ammo);
					SDKHook(wep_id, SDKHook_Reload, OnWeaponReload);
				}
				rp_SetJobCapital( 111, rp_GetJobCapital(111)+price );
				FakeClientCommand(client, "say /build");

			}
		}
	}
	else if (p_oAction == MenuAction_End) {
		CloseHandle(p_hItemMenu);
	}
}

public Action OnWeaponReload(int wepid) {
	static float cache[65];
	
	int ammo = Weapon_GetPrimaryClip(wepid);
	if( ammo >= 150 ) {
		int client = Weapon_GetOwner(wepid);
		
		if( cache[client] < GetGameTime() ) {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "weapon_sanAndreas", client, ammo);
			cache[client] = GetGameTime() + 1.0;
		}
		
		return Plugin_Handled;
	}
	return Plugin_Continue;
}
public int ModifyWeaponPVP(Handle p_hItemMenu, MenuAction p_oAction, int client, int p_iParam2){

	if (p_oAction == MenuAction_Select) {
		char szMenuItem[32];
		if (GetMenuItem(p_hItemMenu, p_iParam2, szMenuItem, sizeof(szMenuItem))){

			char data[2][32];
			ExplodeString(szMenuItem, "_", data, sizeof(data), sizeof(data[]));

			int groupid = StringToInt(data[0]);
			int price = StringToInt(data[1]);
			int wep_id = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
			char wep_name[32];
			GetEdictClassname(wep_id, wep_name, 31);

			if( Weapon_ShouldBeEquip(wep_name) ) {
				CPrintToChat(client, "" ...MOD_TAG... " %T", "Armu_WeaponInHands", client);
				return;
			}

			if((rp_GetClientInt(client, i_Bank)+rp_GetClientInt(client, i_Money)) >= price){
				rp_ClientMoney(client, i_Money, -price);
				rp_SetJobCapital( 111, rp_GetJobCapital(111)+price );
				CPrintToChat(client, "" ...MOD_TAG... " %T", "edit_weapon_done", client);
			}
			else{
				CPrintToChat(client, ""...MOD_TAG..." %T", "Error_NotEnoughtMoney", client);
				return;
			}

			rp_SetWeaponGroupID(wep_id, groupid);
		}
	}
	else if (p_oAction == MenuAction_End) {
		CloseHandle(p_hItemMenu);
	}
}

public Action fwdWeapon(int victim, int attacker, float &damage, int wepID, float pos[3]) {
	bool changed = true;
	enum_ball_type wepType = rp_GetWeaponBallType(wepID);
	
	if( wepType != ball_type_revitalisante )
		rp_ClientAggroIncrement(attacker, victim, RoundFloat(damage));
	
	switch( wepType ) {
		case ball_type_fire: {
			rp_ClientIgnite(victim, 10.0, attacker);
			changed = false;
		}
		case ball_type_caoutchouc: {
			damage *= 0.0;
			
			if( rp_IsInPVP(victim) ) {
				TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, vecNull);
				damage *= 0.5;
				
				rp_SetClientFloat(victim, fl_FrozenTime, GetGameTime() + 1.5);
				if(!rp_GetClientBool(victim, ch_Yeux))
					ServerCommand("sm_effect_flash %d 1.5 180", victim);
			}
			else {
				if( !rp_ClientFloodTriggered(attacker, victim, fd_flash) ) {
					rp_ClientFloodIncrement(attacker, victim, fd_flash, 1.0);
					
					rp_SetClientFloat(victim, fl_FrozenTime, GetGameTime() + 1.5);
					if(!rp_GetClientBool(victim, ch_Yeux))
						ServerCommand("sm_effect_flash %d 1.5 180", victim);
				}
			}
		}
		case ball_type_poison: {
			damage *= 0.66;
			rp_ClientPoison(victim, 30.0, attacker);
		}
		case ball_type_vampire: {
			damage *= 0.75;
			int current = GetClientHealth(attacker);
			if( current < 500 ) {
				current += RoundToFloor(damage*0.2);

				if( current > 500 )
					current = 500;

				SetEntityHealth(attacker, current);
				
				float vecOrigin[3], vecOrigin2[3];
				GetClientEyePosition(attacker, vecOrigin);
				GetClientEyePosition(victim, vecOrigin2);
				
				vecOrigin[2] -= 20.0; vecOrigin2[2] -= 20.0;
				
				TE_SetupBeamPoints(vecOrigin, vecOrigin2, g_cBeam, 0, 0, 0, 0.1, 10.0, 10.0, 0, 10.0, {250, 50, 50, 250}, 10);
				TE_SendToAll();
			}
		}
		case ball_type_paintball: {
			damage *= 1.0;
			
			g_iClientColor[victim][0] = Math_GetRandomInt(50, 255);
			g_iClientColor[victim][1] = Math_GetRandomInt(50, 255);
			g_iClientColor[victim][2] = Math_GetRandomInt(50, 255);
			g_iClientColor[victim][3] = Math_GetRandomInt(100, 240);

			rp_HookEvent(victim, RP_PreHUDColorize, fwdColorize, 5.0);
		}
		case ball_type_reflexive: {
			damage = 0.9;
		}
		case ball_type_explode: {
			damage *= 0.8;
		}
		case ball_type_revitalisante: {
			int current = GetClientHealth(victim);
			if( current < 500 ) {
				current += RoundToCeil(damage*0.1); // On rend environ 10% des degats infligés sous forme de vie

				if( current > 500 )
					current = 500;

				SetEntityHealth(victim, current);
				
				float vecOrigin[3], vecOrigin2[3];
				GetClientEyePosition(attacker, vecOrigin);
				GetClientEyePosition(victim, vecOrigin2);
				
				vecOrigin[2] -= 20.0; vecOrigin2[2] -= 20.0;
				
				TE_SetupBeamPoints(vecOrigin, vecOrigin2, g_cBeam, 0, 0, 0, 0.1, 10.0, 10.0, 0, 10.0, {0, 255, 0, 250}, 10); // Laser vert entre les deux
				TE_SendToAll();
			}
			damage = 0.0; // L'arme ne fait pas de dégats
		}
		case ball_type_notk: {
			if(rp_GetClientGroupID(attacker) != rp_GetClientGroupID(victim)){
				changed = false;
			}
			else{
				damage *= 0.0;
			}
		}
		default: {
			changed = false;
		}
	}
	
	if( changed )
		return Plugin_Changed;
	return Plugin_Continue;
}
// ----------------------------------------------------------------------------
public Action fwdColorize(int client, int color[4]) {
	for (int i = 0; i < 4; i++)
		color[i] += g_iClientColor[client][i];
	return Plugin_Changed;
}
public Action Cmd_ItemRedraw(int args) {
	int client = GetCmdArgInt(1);
	
	int wep_id = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	int item_id = GetCmdArgInt(args);
	char classname[64];
	
	if( IsValidEntity(wep_id) ) {
		GetEdictClassname(wep_id, classname, sizeof(classname));
		if( StrContains(classname, "weapon_bayonet") == 0 || StrContains(classname, "weapon_knife") == 0 ) {
			ITEM_CANCEL(client, item_id);
			return Plugin_Handled;
		}
	}
	
	int index = GetEntProp(wep_id, Prop_Send, "m_iItemDefinitionIndex");
	CSGO_GetItemDefinitionNameByIndex(index, classname, sizeof(classname));
	
	enum_ball_type wep_type = rp_GetWeaponBallType(wep_id);
	int g = rp_GetWeaponGroupID(wep_id);
	bool s = rp_GetWeaponStorage(wep_id);
	
	RemovePlayerItem(client, wep_id );
	RemoveEdict( wep_id );
	
	wep_id = GivePlayerItem(client, classname);
	rp_SetWeaponBallType(wep_id, wep_type);
	rp_SetWeaponGroupID(wep_id, g);
	rp_SetWeaponStorage(wep_id, s);
	
	return Plugin_Handled;
}

// ----------------------------------------------------------------------------
public Action Cmd_ItemSanAndreas(int args) {
	
	int client = GetCmdArgInt(1);
	int item_id = GetCmdArgInt(args);
	int wepid = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	char classname[64];
	
	if( !IsValidEntity(wepid) ) {
		ITEM_CANCEL(client, item_id);
		return Plugin_Handled;
	}
	
	GetEdictClassname(wepid, classname, sizeof(classname));
		
	if( StrContains(classname, "weapon_bayonet") == 0 || StrContains(classname, "weapon_knife") == 0 ) {
		ITEM_CANCEL(client, item_id);
		return Plugin_Handled;
	}
		
	int ammo = Weapon_GetPrimaryClip(wepid);
	if( ammo >= 5000 ) {
		ITEM_CANCEL(client, item_id);
		CPrintToChat(client, ""...MOD_TAG..." %T", "edit_weapon_sanAndreas", client, ammo);
		return Plugin_Handled;
	}
	ammo += 1000;
	if( ammo > 5000 )
		ammo = 5000;
	Weapon_SetPrimaryClip(wepid, ammo);
	CPrintToChat(client, "" ...MOD_TAG... " %T", "weapon_sanAndreas", client, ammo);
	
	SDKHook(wepid, SDKHook_Reload, OnWeaponReload);
	return Plugin_Handled;
}
