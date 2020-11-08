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
#include <sdkhooks>
#include <colors_csgo>	// https://forums.alliedmods.net/showthread.php?p=2205447#post2205447
#include <smlib>		// https://github.com/bcserv/smlib
#include <emitsoundany> // https://forums.alliedmods.net/showthread.php?t=237045

#pragma newdecls required
#include <roleplay.inc>	// https://www.ts-x.eu

public Plugin myinfo = {
	name = "Jobs: Immo", author = "KoSSoLaX",
	description = "RolePlay - Jobs: Immobilier",
	version = __LAST_REV__, url = "https://www.ts-x.eu"
};

int g_cBeam, g_cGlow;

int g_PropsAppartItemId,g_PropsOutdoorItemId;
char g_PropsAppart[][128] = {
	"models/props_office/desk_01.mdl",
	"models/props_interiors/tv.mdl",
	"models/props_c17/furniturewashingmachine001a.mdl",
	"models/props_c17/FurnitureDresser001a.mdl",
	"models/props_interiors/chair_office2.mdl",
	"models/props_interiors/couch.mdl",
	"models/props_interiors/coffee_table_rectangular.mdl",
	"models/props/cs_assault/box_stack1.mdl",
	"models/props/cs_militia/bar01.mdl",
	"models/props/de_house/bed_rustic.mdl",
	"models/props_interiors/tv_cabinet.mdl"
};
char g_PropsOutdoor[][128] = {
	"models/props/DeadlyDesire/blocks/32x32.mdl",
	"models/props_industrial/pallet_stack_96.mdl",
	"models/props_fortifications/concrete_block001_128_reference.mdl",
	"models/props/cs_office/vending_machine.mdl",
	"models/props_urban/boat002.mdl",
	"models/props_urban/outhouse002.mdl",
	"models/props_pipes/concrete_pipe001b.mdl",
	"models/props_interiors/table_picnic.mdl",
	"models/props_industrial/warehouse_shelf001.mdl",
	"models/props/cs_assault/box_stack1.mdl",
	"models/props/de_vertigo/construction_wood_2x4_01.mdl"
};
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
	LoadTranslations("roleplay.immo.phrases");
	
	RegServerCmd("rp_quest_reload", Cmd_Reload);
	RegServerCmd("rp_give_appart_door",		Cmd_ItemGiveAppart,				"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_appart_bonus",	Cmd_ItemGiveBonus,				"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_appart_keys",		Cmd_ItemGiveAppartDouble,		"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_appart_serrure",		Cmd_ItemAppartSerrure,		"RP-ITEM",	FCVAR_UNREGISTERED);
	
	RegServerCmd("rp_item_prop_appart",		Cmd_ItemPropAppart,			"RP-ITEM",  FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_prop_outdoor",	Cmd_ItemPropOutdoor,		"RP-ITEM",  FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_proptraps",	Cmd_ItemPropTrap,		"RP-ITEM",  FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_graves",		Cmd_ItemGrave,			"RP-ITEM", 	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_lampe", 		Cmd_ItemLampe,			"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_jumelle", 	Cmd_ItemLampe,			"RP-ITEM",	FCVAR_UNREGISTERED);
	
	RegAdminCmd("rp_force_appart", 		CmdForceAppart, 			ADMFLAG_ROOT);
	
	for (int i = 1; i <= MaxClients; i++) 
		if( IsValidClient(i) )
			OnClientPostAdminCheck(i);
	
	CreateTimer(1.0, taskVillaProp);
	CreateTimer(60.0, taskVillaProp);
}
public Action taskVillaProp(Handle timer, any none) {
	for(int i=0; i<view_as<int>(appart_bonus_paye); i++) {
		rp_SetAppartementInt(50, view_as<type_appart_bonus>(i), 1);
		rp_SetAppartementInt(51, view_as<type_appart_bonus>(i), 1);
	}
	rp_SetAppartementInt(50, appart_bonus_paye, 200);
	rp_SetAppartementInt(51, appart_bonus_paye, 200);
}
public void OnMapStart() {
	g_cBeam = PrecacheModel("materials/sprites/laserbeam.vmt", true);
	g_cGlow = PrecacheModel("materials/sprites/glow01.vmt", true);
	PrecacheModel(MODEL_GRAVE, true);
}
public Action RP_OnPlayerGotPay(int client, int salary, int & topay, bool verbose) {
	int appart = rp_GetPlayerZoneAppart(client);
	
	if( appart > 0 && rp_GetClientKeyAppartement(client, appart) ) {
		float multi = float(rp_GetAppartementInt(appart, appart_bonus_paye)) / 100.0;
		
		if( multi <= 1.5 && rp_GetClientJobID(client) == 61 && !rp_GetClientBool(client, b_GameModePassive) )
			multi = 1.5;
		
		int sum = RoundToCeil(float(salary) * multi);
		
		if( verbose )
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Pay_Bonus_Appart", client, sum);
		
		topay += sum;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}
public void OnClientPostAdminCheck(int client) {
	rp_HookEvent(client, RP_OnPlayerCommand, fwdCommand);
	rp_HookEvent(client, RP_OnPlayerDataLoaded, fwdLoaded);
	rp_HookEvent(client, RP_OnPlayerBuild,	fwdOnPlayerBuild);
}
public Action fwdLoaded(int client) {
	
	rp_SetClientKeyAppartement(client, 50, rp_GetClientBool(client, b_HasVilla) );
	if( rp_GetClientBool(client, b_HasVilla) )
		rp_SetClientInt(client, i_AppartCount, rp_GetClientInt(client, i_AppartCount) + 1);
	
	char tmp[32], tmp2[32];
	GetClientAuthId(client, AUTH_TYPE, tmp, sizeof(tmp));
	rp_GetServerString(mairieID, tmp2, sizeof(tmp2));
	if( StrEqual(tmp, tmp2) ) {
		rp_SetClientKeyAppartement(client, 51, true );
		rp_SetClientInt(client, i_AppartCount, rp_GetClientInt(client, i_AppartCount) + 1);
	}
}
public Action fwdOnPlayerBuild(int client, float& cooldown) {
	if( rp_GetClientJobID(client) != 61 )
		return Plugin_Continue;
	
	int ent = BuildingTomb(client);
	rp_SetBuildingData(ent, BD_FromBuild, 1);
	SetEntProp(ent, Prop_Data, "m_iHealth", GetEntProp(ent, Prop_Data, "m_iHealth")/5);
	Entity_SetMaxHealth(ent, Entity_GetHealth(ent));
	
	if( ent > 0 ) {
		rp_SetClientStat(client, i_TotalBuild, rp_GetClientStat(client, i_TotalBuild)+1);
		cooldown = 30.0;
	}
	else {
		cooldown = 3.0;
	}
	return Plugin_Stop;
}

// ----------------------------------------------------------------------------
public Action fwdCommand(int client, char[] command, char[] arg) {
	if( StrEqual(command, "infocoloc") ||  StrEqual(command, "infocolloc") ) {
		return Cmd_InfoColoc(client);
	}
	if( StrEqual(command, "villa") ) {
		return Cmd_BedVilla(client);
	}
	return Plugin_Continue;
}
public Action Cmd_ItemGiveAppart(int args) {
	
	int client = GetCmdArgInt(1);
	int appart = GetCmdArgInt(2);
	int vendeur = GetCmdArgInt(3);
	int item_id = GetCmdArgInt(args);
	
	if( rp_GetAppartementInt(appart, appart_proprio) > 0 ) {
		rp_CANCEL_AUTO_ITEM(client, vendeur, item_id);
		
		if( appart > 100 )
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Appart_AlreadySell", client);
		else
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Garage_AlreadySell", client);
		
		return Plugin_Continue;
	}

	rp_SetClientFloat(vendeur, fl_LastVente, GetGameTime() + 17.0);

	
	if( !rp_GetClientKeyAppartement(client, appart) ) {
		
		for (int i = 0; i < view_as<int>(appart_bonus_max); i++) {
			if( i != view_as<int>(appart_price) )
				rp_SetAppartementInt(appart, view_as<type_appart_bonus>(i), 0);
		}
		
		rp_SetClientInt(client, i_AppartCount, rp_GetClientInt(client, i_AppartCount) + 1);
		rp_SetClientKeyAppartement(client, appart, true);
		rp_SetAppartementInt(appart, appart_proprio, client);
		
		if( appart > 100 )
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Garage_Buy", client, appart-100);
		else
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Appart_Buy", client,appart);
	}
	
	return Plugin_Continue;
}
public Action Cmd_ItemAppartSerrure(int args) {

	int client = GetCmdArgInt(1);
	int item_id = GetCmdArgInt(args);
	int appartID = rp_GetPlayerZoneAppart(client);
	Handle dp;
	CreateDataTimer(0.25 , Task_ItemAppartSerrure, dp, TIMER_DATA_HNDL_CLOSE);
	WritePackCell(dp, client);
	WritePackCell(dp, item_id);
	WritePackCell(dp, appartID);
	return Plugin_Handled;
}
public Action Task_ItemAppartSerrure(Handle timer, Handle dp) {
	ResetPack(dp);
	int client = ReadPackCell(dp);
	int item_id = ReadPackCell(dp);
	int appartID = ReadPackCell(dp);

	if( appartID == -1 ) {
		CPrintToChat(client, ""...MOD_TAG..." %T", "Error_OnlyInsideAppart", client);
		ITEM_CANCEL(client, item_id);
		return Plugin_Handled;
	}
	if( rp_GetAppartementInt(appartID, appart_proprio) != client ) {
		CPrintToChat(client, ""...MOD_TAG..." %T", "Appart_MustBeOwner", client);
		ITEM_CANCEL(client, item_id);
		return Plugin_Handled;
	}
	rp_ClientGiveItem(client, item_id); // On redonne l'item au gars au cas ou il ferme son menu
	Handle menu = CreateMenu(MenuSerrureVirer);
	SetMenuTitle(menu, "%T", "Appart_RemoveKey", client);
	
	char tmp[32], tmp2[128];
	for(int i=1; i<=MAXPLAYERS; i++){
		if( !IsValidClient(i) )
			continue;
		
		if(rp_GetClientKeyAppartement(i, appartID) && i!=client){
			Format(tmp, sizeof(tmp), "%i_%i_%i", item_id, appartID, i);
			GetClientName2(i, tmp2, sizeof(tmp2), true);
			AddMenuItem(menu,tmp,tmp2);
		}
	}
	DisplayMenu(menu, client, 60);
	return Plugin_Handled;
}
public int MenuSerrureVirer(Handle menu, MenuAction action, int client, int param2) {
	if( action == MenuAction_Select ) {
		char options[64], data[3][32];
		GetMenuItem(menu, param2, options, 63);
		ExplodeString(options, "_", data, sizeof(data), sizeof(data[]));
		int item_id = StringToInt(data[0]);
		int appartID = StringToInt(data[1]);
		int target = StringToInt(data[2]);
		
		char client_name[128], target_name[128];
		GetClientName2(client, client_name, sizeof(client_name), false);
		GetClientName2(target, target_name, sizeof(target_name), false);
		
		if(rp_GetClientItem(client, item_id)==0){
			char item_name[128];
			rp_GetItemData(item_id, item_type_name, item_name, sizeof(item_name));
			CPrintToChat(client, ""...MOD_TAG..." %T", "Error_ItemMissing", client, item_name);
			return;
		}
		else if(rp_GetClientKeyAppartement(target, appartID) == false ){
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Appart_TargetNoKey", client);
			rp_SetClientFloat(client, fl_CoolDown, 0.05); // On remet le cooldown du gars à 0 mais on lui redonne pas l'item vu qu'il l'a deja
		}
		else{
			rp_SetClientInt(target, i_AppartCount, rp_GetClientInt(target, i_AppartCount) - 1);
			rp_SetClientKeyAppartement(target, appartID, false);
			rp_ClientGiveItem(client, item_id, -1); // On prend l'item au gars comme il l'a utilisé
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Appart_KeyRemovedTo", client, appartID, target_name);
			CPrintToChat(target, "" ...MOD_TAG... " %T", "Appart_KeyRemovedBy", target, appartID, client_name);
		}
	}
	else if( action == MenuAction_End ) {
		CloseHandle(menu);
	}
}
public Action Cmd_ItemGiveAppartDouble(int args) {
	
	int client = GetCmdArgInt(1);
	int itemID = GetCmdArgInt(args);
	int target = GetClientAimTarget(client);
	
	if( !IsValidClient(target) ) {
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_CannotFindTarget", client);
		ITEM_CANCEL(client, itemID);
		return Plugin_Handled;
	}
	
	int appartID = rp_GetPlayerZoneAppart(client);
	if( appartID == -1 ) {
		CPrintToChat(client, ""...MOD_TAG..." %T", "Error_OnlyInsideAppart", client);
		ITEM_CANCEL(client, itemID);
		return Plugin_Handled;
	}
	if( rp_GetAppartementInt(appartID, appart_proprio) != client ) {
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Appart_MustBeOwner", client);
		ITEM_CANCEL(client, itemID);
		return Plugin_Handled;
	}
	
	if( rp_GetClientKeyAppartement(target, appartID ) ) {
		CPrintToChat(client, ""...MOD_TAG..." %T", "Appart_TargetAlreadyKey", client);
		ITEM_CANCEL(client, itemID);
		return Plugin_Handled;
	}
	
	int price = rp_GetAppartementInt(appartID, appart_price);
	int max = 0;
	switch( price ) {
		case 300: max = 3;
		case 450: max = 4;
		case 600: max = 5;
		
		case 500: max = 1;
		case 750: max = 3;
	}
	
	int count = 0;
	for(int i=1; i<=MAXPLAYERS; i++){
		if( !IsValidClient(i) )
			continue;
		
		if( rp_GetClientKeyAppartement(i, appartID) && i!=client){
			count++;
		}
	}
	
	if( count >= max ) {
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Appart_KeyTooMany", client);
		ITEM_CANCEL(client, itemID);
		return Plugin_Handled;
	}
	
	rp_SetClientInt(target, i_AppartCount, rp_GetClientInt(target, i_AppartCount) + 1);
	rp_SetClientKeyAppartement(target, appartID, true);
	
	char client_name[128], target_name[128];
	GetClientName2(client, client_name, sizeof(client_name), false);
	GetClientName2(target, target_name, sizeof(target_name), false);
	CPrintToChat(client, "" ...MOD_TAG... " %T", "Appart_KeyGiveTo", client, appartID, target_name);
	CPrintToChat(target, "" ...MOD_TAG... " %T", "Appart_KeyGiveBy", target, appartID, client_name);
	
	return Plugin_Handled;
}
public Action Cmd_ItemGiveBonus(int args) {
	
	char arg1[32];
	GetCmdArg(1, arg1, sizeof(arg1));
	int client = GetCmdArgInt(2);
	int itemID = GetCmdArgInt(args);
	
	int appartID = rp_GetPlayerZoneAppart(client);
	if( appartID == -1 || appartID >= 50) {
		CPrintToChat(client, ""...MOD_TAG..." %T", "Error_OnlyInsideAppart", client);
		ITEM_CANCEL(client, itemID);
		return Plugin_Handled;
	}
	if( !rp_GetClientKeyAppartement(client, appartID) ) {
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Appart_MustBeOwner", client);
		ITEM_CANCEL(client, itemID);
		return Plugin_Handled;
	}
	
	int bonus, mnt = 1;
	// BO BO BONUS
	
	if( StrEqual(arg1, "heal") )
		bonus = appart_bonus_heal;
	else if( StrEqual(arg1, "armor") )
		bonus = appart_bonus_armor;
	else if( StrEqual(arg1, "energy") )
		bonus = appart_bonus_energy;
	else if( StrEqual(arg1, "garage") )
		bonus = appart_bonus_garage;
	else if( StrEqual(arg1, "vitality") )
		bonus = appart_bonus_vitality;
	else if( StrEqual(arg1, "coffre") )
		bonus = appart_bonus_coffre;
	else if( StrEqual(arg1, "bronze") ) {
		bonus = appart_bonus_paye;
		mnt = 50;
	}
	else if( StrEqual(arg1, "argent") ) {
		bonus = appart_bonus_paye;
		mnt = 75;
	}
	else if( StrEqual(arg1, "or") ) {
		bonus = appart_bonus_paye;
		mnt = 100;
	}
	else if( StrEqual(arg1, "platine") ) {
		bonus = appart_bonus_paye;
		mnt = 150;
	}
	else if( StrEqual(arg1, "all") ) {
		bool hasAll = true;
		
		for(int i=0; i<view_as<int>(appart_bonus_paye); i++) {
			if( rp_GetAppartementInt(appartID, view_as<type_appart_bonus>(bonus)) == 0 ) {
				hasAll = false;
			}
		}
		
		if( hasAll ) {
			ITEM_CANCEL(client, itemID);
			return Plugin_Handled;
		}
		
		for(int i=0; i<view_as<int>(appart_bonus_paye); i++) {
			rp_SetAppartementInt(appartID, view_as<type_appart_bonus>(i), 1);
		}
		rp_SetAppartementInt(appartID, appart_bonus_paye, 150);
		return Plugin_Handled;
	}
	else {
		ITEM_CANCEL(client, itemID);
		return Plugin_Handled;	
	}
		
	if( rp_GetAppartementInt(appartID, view_as<type_appart_bonus>(bonus)) >= mnt ) {
		ITEM_CANCEL(client, itemID);
		return Plugin_Handled;
	}
	rp_SetAppartementInt(appartID, view_as<type_appart_bonus>(bonus), mnt);
	
	return Plugin_Handled;	
}
// ----------------------------------------------------------------------------
public Action Cmd_ItemPropAppart(int args){
	int client = GetCmdArgInt(1);
	int item_id = GetCmdArgInt(args);
	rp_ClientGiveItem(client,item_id);
	g_PropsAppartItemId = item_id;
	int zone = rp_GetPlayerZone(client);
	int appart = rp_GetPlayerZoneAppart(client);
	if(appart == -1){
		if(rp_GetZoneInt(zone, zone_type_type) != rp_GetClientJobID(client)){
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_OnlyInside", client);
			return Plugin_Handled;
		}
	}
	CreateTimer(0.25, task_ItemPropAppart, client);
	return Plugin_Handled;
}
public Action task_ItemPropAppart(Handle timer, any client) {
	Handle menu = CreateMenu(MenuPropAppart);
	SetMenuTitle(menu, "%T\n ", "Prop_ToSpawn", client);
	
	char tmp[128];
	for(int i=0; i<sizeof(g_PropsAppart); i++){
		Format(tmp, sizeof(tmp), "%T", g_PropsAppart[i], client);
		AddMenuItem(menu, g_PropsAppart[i], tmp);
	}
	DisplayMenu(menu, client, 60);
	return Plugin_Handled;
}
public int MenuPropAppart(Handle menu, MenuAction action, int client, int param2) {
	if( action == MenuAction_Select ) {
		char model[128];
		GetMenuItem(menu, param2, model, 127);
		int item_id = g_PropsAppartItemId;
		int zone = rp_GetPlayerZone(client);
		int appart = rp_GetPlayerZoneAppart(client);
		if(appart == -1){
			if(rp_GetZoneInt(zone, zone_type_type) != rp_GetClientJobID(client)){
				CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_OnlyInside", client);
				return;
			}
		}
		int ent = CreateEntityByName("prop_physics_override"); 
		if( !IsModelPrecached(model) ) {
			PrecacheModel(model);
		}
		DispatchKeyValue(ent, "classname", "rp_props");
		DispatchKeyValue(ent, "physdamagescale", "0.0");
		DispatchKeyValue(ent, "model", model);
		DispatchSpawn(ent);
		SetEntityModel(ent, model);
		
		float min[3], max[3], position[3], ang_eye[3], ang_ent[3], normal[3];
		float distance = 50.0;
		
		GetEntPropVector( ent, Prop_Send, "m_vecMins", min );
		GetEntPropVector( ent, Prop_Send, "m_vecMaxs", max );
		
		distance += SquareRoot( (max[0] - min[0]) * (max[0] - min[0]) + (max[1] - min[1]) * (max[1] - min[1]) ) * 0.5;
		
		GetClientFrontLocationData( client, position, ang_eye, distance );
		normal[0] = 0.0;
		normal[1] = 0.0;
		normal[2] = 1.0;
		
		NegateVector( normal );
		GetVectorAngles( normal, ang_ent );
		
		float volume = (max[0]-min[0]) * (max[1]-min[1]) * (max[2]-min[2]);
		int heal = RoundToCeil(volume/50.0)+10;
		position[2] += max[2];
		Handle trace = TR_TraceHullEx(position, position, min, max, MASK_SOLID);
		if( TR_DidHit(trace) ) {
			delete trace;
			
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Build_CannotHere", client);
			rp_AcceptEntityInput(ent, "Kill");
			return;
		}
		delete trace;
		
		SetEntProp( ent, Prop_Data, "m_takedamage", 2);
		SetEntProp( ent, Prop_Data, "m_iHealth", heal);	
		Entity_SetMaxHealth(ent, Entity_GetHealth(ent));
		
		SetEntityMoveType(ent, MOVETYPE_VPHYSICS); 
		TeleportEntity(ent, position, ang_ent, NULL_VECTOR);
		rp_AcceptEntityInput(ent, "DisableMotion");
		rp_ScheduleEntityInput(ent, 0.6, "EnableMotion");
		
		ServerCommand("sm_effect_fading %i 0.5", ent);
		
		rp_SetBuildingData(ent, BD_owner, client);
		rp_SetBuildingData(ent, BD_item_id, item_id);
		rp_Effect_BeamBox(client, ent, NULL_VECTOR, 0, 64, 255);
		
		SDKHook(ent, SDKHook_OnTakeDamage, OnPropDamage);
		rp_ClientGiveItem(client,item_id,-1);
	}
	else if( action == MenuAction_End ) {
		CloseHandle(menu);
	}
}
public Action Cmd_ItemPropOutdoor(int args){
	int client = GetCmdArgInt(1);
	int item_id = GetCmdArgInt(args);
	rp_ClientGiveItem(client,item_id);
	g_PropsOutdoorItemId = item_id;
	int zone = rp_GetPlayerZone(client);
	int zoneBIT = rp_GetZoneBit(zone);

	if( rp_GetZoneInt(zone, zone_type_type) == 1 || zoneBIT & BITZONE_PEACEFULL || zoneBIT & BITZONE_BLOCKBUILD ) {
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_CannotUseItemHere");
		return Plugin_Handled;
	}
	CreateTimer(0.25, task_ItemPropOutdoor, client);
	return Plugin_Handled;
}

public Action task_ItemPropOutdoor(Handle timer, any client){
	Handle menu = CreateMenu(MenuPropOutdoor);
	SetMenuTitle(menu, "%T\n ", "Prop_ToSpawn", client);
	
	char tmp[128];
	for(int i=0; i<sizeof(g_PropsOutdoor); i++) {
		Format(tmp, sizeof(tmp), "%T", g_PropsOutdoor[i], client);
		AddMenuItem(menu, g_PropsOutdoor[i], tmp);
	}
	DisplayMenu(menu, client, 60);
	return Plugin_Handled;
}
public int MenuPropOutdoor(Handle menu, MenuAction action, int client, int param2) {
	if( action == MenuAction_Select ) {
		char model[128];
		GetMenuItem(menu, param2, model, 127);
		int item_id = g_PropsOutdoorItemId;
		int zone = rp_GetPlayerZone(client);
		int zoneBIT = rp_GetZoneBit(zone);

		int ent = CreateEntityByName("prop_physics_override"); 
		if( !IsModelPrecached(model) ) {
			PrecacheModel(model);
		}
		if( rp_GetZoneInt(zone, zone_type_type) == 1 || zoneBIT & BITZONE_PEACEFULL || zoneBIT & BITZONE_BLOCKBUILD ) {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_CannotUseItemHere");
			return;
		}
		DispatchKeyValue(ent, "classname", "rp_props");
		DispatchKeyValue(ent, "physdamagescale", "0.0");
		DispatchKeyValue(ent, "model", model);
		DispatchSpawn(ent);
		SetEntityModel(ent, model);
		
		float min[3], max[3], position[3], ang_eye[3], ang_ent[3], normal[3];
		float distance = 50.0;
		
		GetEntPropVector( ent, Prop_Send, "m_vecMins", min );
		GetEntPropVector( ent, Prop_Send, "m_vecMaxs", max );
		
		distance += SquareRoot( (max[0] - min[0]) * (max[0] - min[0]) + (max[1] - min[1]) * (max[1] - min[1]) ) * 0.5;
		
		GetClientFrontLocationData( client, position, ang_eye, distance );
		normal[0] = 0.0;
		normal[1] = 0.0;
		normal[2] = 1.0;
		
		NegateVector( normal );
		GetVectorAngles( normal, ang_ent );
		
		float volume = (max[0]-min[0]) * (max[1]-min[1]) * (max[2]-min[2]);
		int heal = RoundToCeil(volume/50.0)+10;
		position[2] += max[2];
		Handle trace = TR_TraceHullEx(position, position, min, max, MASK_SOLID);
		if( TR_DidHit(trace) ) {
			delete trace;
			
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Build_CannotHere", client);
			rp_AcceptEntityInput(ent, "Kill");
			return;
		}
		delete trace;
		
		SetEntProp( ent, Prop_Data, "m_takedamage", 2);
		SetEntProp( ent, Prop_Data, "m_iHealth", heal);	
		Entity_SetMaxHealth(ent, Entity_GetHealth(ent));
		
		SetEntityMoveType(ent, MOVETYPE_VPHYSICS); 
		TeleportEntity(ent, position, ang_ent, NULL_VECTOR);
		rp_AcceptEntityInput(ent, "DisableMotion");
		rp_ScheduleEntityInput(ent, 0.6, "EnableMotion");
		
		ServerCommand("sm_effect_fading %i 0.5", ent);
		
		rp_SetBuildingData(ent, BD_owner, client);
		rp_SetBuildingData(ent, BD_item_id, item_id);
		rp_Effect_BeamBox(client, ent, NULL_VECTOR, 0, 64, 255);
		
		SDKHook(ent, SDKHook_OnTakeDamage, OnPropDamage);
		rp_ClientGiveItem(client,item_id,-1);
	}
	else if( action == MenuAction_End ) {
		CloseHandle(menu);
	}
}
public Action OnPropDamage(int caller, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom) {
	
	int heal = Entity_GetHealth(caller);
	
	if( heal-RoundFloat(damage) <= 0 ) {
		int owner = rp_GetBuildingData(caller, BD_owner);
		rp_SetBuildingData(caller, BD_owner, 0);
		
		if( IsValidClient(attacker) && IsValidClient(owner) ) {
			rp_ClientAggroIncrement(attacker, owner, 1000);
	
			if( owner == attacker ) {
				rp_IncrementSuccess(owner, success_list_ikea_fail);
			}
		}
		
		Entity_SetHealth(caller, 1);
		SDKHooks_TakeDamage(caller, attacker, attacker, damage*10.0);
	}
	
	return Plugin_Continue;
}
// ----------------------------------------------------------------------------
public Action Cmd_ItemPropTrap(int args) {
	int client = GetCmdArgInt(1);
	int target = GetClientAimTarget(client, false);
	
	int item_id = GetCmdArgInt(args);
	if( target == 0 || !IsValidEdict(target) || !IsValidEntity(target) || !rp_IsMoveAble(target) ) {
		ITEM_CANCEL(client, item_id);
		return Plugin_Handled;
	}
	
	if( rp_GetBuildingData(target, BD_owner) != client ) {
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Prop_YouDontOwn", client);
		ITEM_CANCEL(client, item_id);
		return Plugin_Handled;
	}
	
	if( rp_GetBuildingData(target, BD_Trapped) ) {
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Prop_AlreadyTrap", client);
		ITEM_CANCEL(client, item_id);
		return Plugin_Handled;
	}
	
	rp_SetClientInt(client, i_LastAgression, GetTime());
	float vecTarget[3];
	Entity_GetAbsOrigin(target, vecTarget);
	TE_SetupBeamRingPoint(vecTarget, 1.0, 150.0, g_cBeam, g_cGlow, 0, 15, 0.5, 50.0, 0.0, {50, 100, 255, 50}, 10, 0);
	TE_SendToAll();
	
	rp_SetBuildingData(target, BD_Trapped, 1);
	SDKHook(target, SDKHook_OnTakeDamage, PropsDamage);
	SDKHook(target, SDKHook_Touch,		PropsTouched);
	return Plugin_Handled;
}
public void PropsTouched(int touched, int toucher) {
	if( IsValidClient(toucher) && toucher != rp_GetBuildingData(touched, BD_owner) ) {
		rp_Effect_PropExplode(touched);
		rp_SetClientInt(rp_GetBuildingData(touched, BD_owner), i_LastAgression, GetTime());
	}
}
public Action PropsDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype) {
	if( attacker == inflictor && IsValidClient(attacker) ) {
		int wep_id = GetEntPropEnt(attacker, Prop_Send, "m_hActiveWeapon");
		char sWeapon[32];
		
		GetEdictClassname(wep_id, sWeapon, sizeof(sWeapon));
		if( StrContains(sWeapon, "weapon_knife") == 0 || StrContains(sWeapon, "weapon_bayonet") == 0 ) {
			rp_Effect_PropExplode(victim);
		}
	}
}
// ----------------------------------------------------------------------------
public Action Cmd_ItemGrave(int args) {
	int client = GetCmdArgInt(1);
	
	if( BuildingTomb(client) == 0 ) {
		char arg_last[12];
		GetCmdArg(args, arg_last, 11);
		int item_id = StringToInt(arg_last);
		
		ITEM_CANCEL(client, item_id);
	}
	
	return Plugin_Handled;
}
int BuildingTomb(int client) {
	
	if( !rp_IsBuildingAllowed(client) )
		return 0;	
	
	char classname[64], tmp[64];
	Format(classname, sizeof(classname), "rp_grave");
	
	float vecOrigin[3], vecAngles[3];
	GetClientAbsOrigin(client, vecOrigin);
	GetClientEyeAngles(client, vecAngles);
	
	for(int i=1; i<=2048; i++) {
		if( !IsValidEdict(i) )
			continue;
		if( !IsValidEntity(i) )
			continue;
		
		GetEdictClassname(i, tmp, sizeof(tmp));
		
		if( StrEqual(classname, tmp) && rp_GetBuildingData(i, BD_owner) == client ) {
			CPrintToChat(client, ""...MOD_TAG..." %T", "Build_TooMany", client);
			return 0;
		}
	}
	
	EmitSoundToAllAny("player/ammo_pack_use.wav", client, _, _, _, 0.66);
	
	int ent = CreateEntityByName("prop_physics");
	
	DispatchKeyValue(ent, "classname", classname);
	DispatchKeyValue(ent, "model", MODEL_GRAVE);
	DispatchKeyValue(ent, "solid", "0");
	DispatchSpawn(ent);
	ActivateEntity(ent);
	
	SetEntityModel(ent, MODEL_GRAVE);
	
	SetEntProp( ent, Prop_Data, "m_iHealth", 25000);
	SetEntProp( ent, Prop_Data, "m_takedamage", 0);
	
	SetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity", client);
	
	
	vecAngles[0] = vecAngles[2] = 0.0;
	TeleportEntity(ent, vecOrigin, vecAngles, NULL_VECTOR);
	
	ServerCommand("sm_effect_fading \"%i\" \"3.0\" \"0\"", ent);
	
	SetEntityMoveType(client, MOVETYPE_NONE);
	SetEntityMoveType(ent, MOVETYPE_NONE);
	
	CreateTimer(3.0, BuildingTomb_post, ent);
	rp_SetBuildingData(ent, BD_owner, client);
	
	rp_SetClientBool(client, b_HasGrave, true);
	rp_SetClientBool(client, b_SpawnToGrave, true);
	Entity_SetMaxHealth(ent, Entity_GetHealth(ent));
	
	return 1;
}
public Action BuildingTomb_post(Handle timer, any entity) {
	int client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	SetEntityMoveType(client, MOVETYPE_WALK);
	
	rp_Effect_BeamBox(client, entity, NULL_VECTOR, 0, 255, 100);
	SetEntProp(entity, Prop_Data, "m_takedamage", 2);
	
	HookSingleEntityOutput(entity, "OnBreak", BuildingTomb_break);
	return Plugin_Handled;
}
public void BuildingTomb_break(const char[] output, int caller, int activator, float delay) {
	
	int owner = GetEntPropEnt(caller, Prop_Send, "m_hOwnerEntity");
	if( IsValidClient(owner) ) {
		char tmp[128];
		GetEdictClassname(caller, tmp, sizeof(tmp));
		CPrintToChat(owner, "" ...MOD_TAG... " %T", "Build_Destroyed", owner, tmp);
		rp_SetClientBool(owner, b_HasGrave, false);
	}
}
public Action Cmd_ItemLampe(int args) {
	char arg1[32];
	GetCmdArg(0, arg1, sizeof(arg1));
	
	int client = GetCmdArgInt(1);
	
	if( StrContains(arg1, "jumelle") != -1 ) {
		rp_SetClientBool(client, b_Jumelle, true);
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Item_Jumelle", client);
		rp_HookEvent(client, RP_OnAssurance,	fwdAssurance2);
	}
	else if( StrContains(arg1, "lampe") != -1 ) {
		rp_SetClientBool(client, b_LampePoche, true);
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Item_NightVision", client);
		rp_HookEvent(client, RP_OnAssurance,	fwdAssurance);
	}
	return Plugin_Handled;
}
public Action fwdAssurance(int client, int& amount) {
	amount += 250;
	return Plugin_Changed;
}
public Action fwdAssurance2(int client, int& amount) {
	amount += 300;
	return Plugin_Changed;
}
// ----------------------------------------------------------------------------
void GetClientFrontLocationData( int client, float position[3], float angles[3], float distance = 50.0 ) {
	
	float _origin[3], _angles[3], direction[3];
	GetClientAbsOrigin( client, _origin );
	GetClientEyeAngles( client, _angles );
	
	
	GetAngleVectors( _angles, direction, NULL_VECTOR, NULL_VECTOR );
	
	position[0] = _origin[0] + direction[0] * distance;
	position[1] = _origin[1] + direction[1] * distance;
	position[2] = _origin[2];
	
	angles[0] = 0.0;
	angles[1] = _angles[1];
	angles[2] = 0.0;
}

public Action Cmd_InfoColoc(int client){
	if(rp_GetClientInt(client, i_AppartCount) == 0){
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Appart_None");
		return Plugin_Handled;
	}
	char tmp[128];
	int proprio;
	Handle menu = CreateMenu(MenuNothing);
	SetMenuTitle(menu, "%T", "Appart_Info", client);
	for (int i = 1; i < 200; i++) {
		if( rp_GetClientKeyAppartement(client, i) ) {

			Format(tmp, sizeof(tmp),"--- %T ---", i < 100 ? "Appart_Number" : "Garage_Number", client, i);

			AddMenuItem(menu, tmp, tmp,	ITEMDRAW_DISABLED);
			
			tmp[0] = 0;
			
			if(rp_GetAppartementInt(i, appart_bonus_energy) == 1)
				Format(tmp, sizeof(tmp), "%s %T", tmp, "appart_bonus_energy", client);
			if(rp_GetAppartementInt(i, appart_bonus_heal) == 1)
				Format(tmp, sizeof(tmp), "%s %T", tmp, "appart_bonus_heal", client);
			if(rp_GetAppartementInt(i, appart_bonus_armor) == 1)
				Format(tmp, sizeof(tmp), "%s %T", tmp, "appart_bonus_armor", client);
			if(rp_GetAppartementInt(i, appart_bonus_garage) == 1)
				Format(tmp, sizeof(tmp), "%s %T", tmp, "appart_bonus_garage", client);
			if(rp_GetAppartementInt(i, appart_bonus_vitality) == 1)
				Format(tmp, sizeof(tmp), "%s %T", tmp, "appart_bonus_vitality", client);
			if(rp_GetAppartementInt(i, appart_bonus_coffre) == 1)
				Format(tmp, sizeof(tmp), "%s %T", tmp, "appart_bonus_coffre", client);
			if(rp_GetAppartementInt(i, appart_bonus_paye) >= 50)
				Format(tmp, sizeof(tmp), "%s %T", tmp, "appart_bonus_paye", client, rp_GetAppartementInt(i, appart_bonus_paye));
			
			Format(tmp, sizeof(tmp), "%T", "appart_bonus", client, tmp);
			AddMenuItem(menu, tmp, tmp,	ITEMDRAW_DISABLED);

			proprio = rp_GetAppartementInt(i, appart_proprio);
			GetClientName2(proprio, tmp, sizeof(tmp), true);
			Format(tmp, sizeof(tmp), "%T", "appart_owner", client, tmp);
			AddMenuItem(menu, tmp, tmp,	ITEMDRAW_DISABLED);

			for(int j=1; j<=MAXPLAYERS; j++){
				if( !IsValidClient(j) )
					continue;
				if(rp_GetClientKeyAppartement(j, i) && j != proprio){
					GetClientName2(i, tmp, sizeof(tmp), true);
					AddMenuItem(menu, tmp, tmp,	ITEMDRAW_DISABLED);
				}
			}
		}
	}
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, 60);
	return Plugin_Handled;
}

public int MenuNothing(Handle menu, MenuAction action, int client, int param2) {
	if( action == MenuAction_Select ) {
		if( menu != INVALID_HANDLE )
			CloseHandle(menu);
	}
	else if( action == MenuAction_End ) {
		if( menu != INVALID_HANDLE )
			CloseHandle(menu);
	}
}
// ----------------------------------------------------------------------------
public Action Cmd_BedVilla(int client){
	
	if( rp_GetClientInt(client, i_PlayerLVL) < 42 ) {
		CPrintToChat(client, "" ...MOD_TAG... "%T", "Error_Level", client, 42, "LEVEL_42");
		return Plugin_Handled;
	}
	
	if( rp_GetClientBool(client, b_MaySteal) == false ) {
		ACCESS_DENIED(client);
	}
	rp_SetClientBool(client, b_MaySteal, false);
	
	char sql[256];
	GetClientAuthId(client, AUTH_TYPE, sql, sizeof(sql));
	
	Format(sql, sizeof(sql), "(SELECT `name`, `amount` FROM `rp_bid`B INNER JOIN`rp_users`U ON U.`steamid`=B.`steamid` ORDER BY `amount` DESC LIMIT 3) UNION (SELECT 'Vous', `amount` FROM `rp_bid` C WHERE `steamid` = '%s')", sql);
	SQL_TQuery(rp_GetDatabase(), SQL_BedVillaMenu, sql, client);
	
	
	return Plugin_Handled;
}
public void SQL_BedVillaMenu(Handle owner, Handle hQuery, const char[] error, any client) {
	
	Handle menu = CreateMenu(bedVillaMenu);
	SetMenuTitle(menu, "%T\n ", "Menu_Villa", client);
	
	char nick[128], steamid[64], steamid2[64];
	rp_GetServerString(villaOwnerID, steamid, sizeof(steamid));
	GetClientAuthId(client, AUTH_TYPE, steamid2, sizeof(steamid2));
	
	int max = 0, last = 0;
	
	while( SQL_FetchRow(hQuery) ) {
		last = SQL_FetchInt(hQuery, 1);
		if( last > max )
			max = last;
		
		SQL_FetchString(hQuery, 0, nick, sizeof(nick));
		Format(nick, sizeof(nick), "%s: %d$", nick, last);
		
		AddMenuItem(menu, nick, nick, ITEMDRAW_DISABLED);
	}
	
	char szDayOfWeek[12], szHours[12], tmp[128];
	
	FormatTime(szDayOfWeek, 11, "%w");
	FormatTime(szHours, 11, "%H");
	
	if( StringToInt(szDayOfWeek) == 0 && StringToInt(szHours) < 21 ) {	// Dimanche avant 21h
		Format(tmp, sizeof(tmp), "%T", "Menu_Villa_Bed", client);
		AddMenuItem(menu, "miser", tmp);
	}
	
	if( StrEqual(steamid, steamid2) ) {
		Format(tmp, sizeof(tmp), "%T", "Menu_Villa_Key", client);
		AddMenuItem(menu, "key", tmp);
	}
	
	DisplayMenu(menu, client, 60);
	
	rp_SetClientBool(client, b_MaySteal, true);
}
public int bedVillaMenu(Handle p_hItemMenu, MenuAction p_oAction, int client, int p_iParam2) {

	if( p_oAction == MenuAction_Select) {
		char szMenuItem[32];
		if( GetMenuItem(p_hItemMenu, p_iParam2, szMenuItem, sizeof(szMenuItem)) ) {
			if( StrEqual(szMenuItem, "miser") ) {
				OpenBedMenu(client);
			}
			else if( StrEqual(szMenuItem, "key") ) {
				
				if( rp_GetClientBool(client, b_MaySteal) == false ) {
					return;
				}
				rp_SetClientBool(client, b_MaySteal, false);
				SQL_TQuery(rp_GetDatabase(), SQL_BedVillaMenuKey, "SELECT `name` FROM `rp_users` WHERE `hasVilla`=1", client);
			}
		}
	}
	else if (p_oAction == MenuAction_End) {
		CloseHandle(p_hItemMenu);
	}
}
public void SQL_BedVillaMenuKey(Handle owner, Handle hQuery, const char[] error, any client) {
	char steamid[64], steamid2[64], tmp[128];
	rp_GetServerString(villaOwnerID, steamid, sizeof(steamid));
	GetClientAuthId(client, AUTH_TYPE, steamid2, sizeof(steamid2));
	if( !StrEqual(steamid, steamid2) )
		return;
	
	Handle menu = CreateMenu(bedVillaMenu_KEY);
	int i = 0;
	while( SQL_FetchRow(hQuery) ) {
		i++;
		SQL_FetchString(hQuery, 0, steamid, sizeof(steamid));
		AddMenuItem(menu, steamid, steamid, ITEMDRAW_DISABLED);
	}
	
	if( i < 8 ) {
		Format(tmp, sizeof(tmp), "%T", "Menu_Villa_Key", client);
		AddMenuItem(menu, "add", tmp);
	}
	DisplayMenu(menu, client, 60);
	
	rp_SetClientBool(client, b_MaySteal, true);
	
}
public int bedVillaMenu_KEY(Handle p_hItemMenu, MenuAction p_oAction, int client, int p_iParam2) {

	if( p_oAction == MenuAction_Select) {
		char szMenuItem[32], tmp[64], szQuery[1024];
		if( GetMenuItem(p_hItemMenu, p_iParam2, szMenuItem, sizeof(szMenuItem)) ) {
			if( StrEqual(szMenuItem, "add") ) {
				Handle menu2 = CreateMenu(bedVillaMenu_KEY);
				for (int i = 1; i <= MaxClients; i++) {
					if( !IsValidClient(i) || i == client )
						continue;
					if( rp_GetClientBool(i, b_HasVilla) )
						continue;
					
					GetClientName(i, tmp, sizeof(tmp));
					Format(szMenuItem, sizeof(szMenuItem), "%d", i);
					AddMenuItem(menu2, szMenuItem, tmp);
				}
				DisplayMenu(menu2, client, 60);
				return;
			}
			int target = StringToInt(szMenuItem);
			rp_SetClientBool(target, b_HasVilla, true);
			rp_SetClientKeyAppartement(target, 50, true);
			rp_SetClientInt(target, i_AppartCount, rp_GetClientInt(target, i_AppartCount) + 1);
			GetClientAuthId(target, AUTH_TYPE, szMenuItem, sizeof(szMenuItem));
			
			Format(szQuery, sizeof(szQuery), "UPDATE `rp_users` SET `hasVilla`='1' WHERE `steamid`='%s'", szMenuItem);
			SQL_TQuery(rp_GetDatabase(), SQL_QueryCallBack, szQuery, DBPrio_High);
		}
	}
	else if (p_oAction == MenuAction_End) {
		CloseHandle(p_hItemMenu);
	}
}
void OpenBedMenu(int client) {
	char tmp[128];
	Handle menu = CreateMenu(bedVillaMenu_BED);
	SetMenuTitle(menu, "%T", "Menu_Bed", client);
	
	
	AddMenuItem(menu, "1",		"1$");
	AddMenuItem(menu, "10",		"10$");
	AddMenuItem(menu, "100",	"100$");
	AddMenuItem(menu, "1000",	"1000$");
	AddMenuItem(menu, "10000",	"10 000$");
	AddMenuItem(menu, "100000",	"100 000$");
	
	AddMenuItem(menu, "_", " ", ITEMDRAW_SPACER);
	
	Format(tmp, sizeof(tmp), "%T", client, "Back");
	AddMenuItem(menu, "back",	tmp);
	
	SetMenuPagination(menu, MENU_NO_PAGINATION);
	DisplayMenu(menu, client, 60);
}
public int bedVillaMenu_BED(Handle p_hItemMenu, MenuAction p_oAction, int client, int p_iParam2) {

	if( p_oAction == MenuAction_Select) {
		char szMenuItem[32], szDayOfWeek[12], szHours[12], sql[256];
		
		if( GetMenuItem(p_hItemMenu, p_iParam2, szMenuItem, sizeof(szMenuItem)) ) {
			if( StrEqual(szMenuItem, "back") ) {
				Cmd_BedVilla(client);
				return;
			}
			int amount = StringToInt(szMenuItem);
			if( amount > (rp_GetClientInt(client, i_Money)+rp_GetClientInt(client, i_Bank)) ) {
				CPrintToChat(client, ""...MOD_TAG..." %T", "Error_NotEnoughtMoney", client);
				OpenBedMenu(client);
				return;
			}
	
			FormatTime(szDayOfWeek, 11, "%w");
			FormatTime(szHours, 11, "%H");
			
			if( StringToInt(szDayOfWeek) == 0 && StringToInt(szHours) < 21 ) {	// Dimanche avant 21h
			
				GetClientAuthId(client, AUTH_TYPE, sql, sizeof(sql));
				Format(sql, sizeof(sql), "INSERT INTO `rp_bid` (`steamid`, `amount`) VALUES ('%s', '%d') ON DUPLICATE KEY UPDATE `amount`=`amount`+%d;", sql, amount, amount);
				SQL_TQuery(rp_GetDatabase(), SQL_QueryCallBack, sql);
				rp_ClientMoney(client, i_Money, -amount);
			}
			
			OpenBedMenu(client);
		}
	}
	else if (p_oAction == MenuAction_End) {
		CloseHandle(p_hItemMenu);
	}
}
public Action CmdForceAppart(int client, int args) {
	
	CheckAppart();
	return Plugin_Handled;
}
void CheckAppart() {
	SQL_TQuery(rp_GetDatabase(), SQL_GetAppartWiner, "SELECT B.`steamid`, `name`, `amount` FROM `rp_bid` B INNER JOIN `rp_users` U ON B.`steamid`=U.`steamid` ORDER BY `amount` DESC;");
}
public void SQL_GetAppartWiner(Handle owner, Handle hQuery, const char[] error, any none) {
	int gain, place = 0;
	CPrintToChatAll("{lightblue} =================================={default} ");
	char szSteamID[32], szName[64], szQuery[1024], szSteamID2[32];
	
	while( SQL_FetchRow(hQuery) ) {
		
		SQL_FetchString(hQuery, 0, szSteamID, sizeof(szSteamID));
		gain = SQL_FetchInt(hQuery, 2);
		
		if( place == 0 ) {
			SQL_FetchString(hQuery, 1, szName, sizeof(szName));	
			
			CPrintToChatAll("" ...MOD_TAG... " %T", "Villa_Winner", LANG_SERVER, szName, gain);
			LogToGame("[TSX-RP] [VILLA] %s %s gagne la villa pour %d$", szName, szSteamID, gain);
			
			dispatchToJob(gain);
			
			rp_SetServerString(villaOwnerID,  	szSteamID, sizeof(szSteamID));
			rp_SetServerString(villaOwnerName,  szName, sizeof(szName));
			
			for( int i = 1; i <= MaxClients; i++) {
				if( !IsValidClient(i) )
					continue;

				rp_SetClientBool(i, b_HasVilla, false);
				rp_SetClientKeyAppartement(i, 50, false);
				
				GetClientAuthId(i, AUTH_TYPE, szSteamID2, sizeof(szSteamID2));
				
				if( StrEqual(szSteamID, szSteamID2) ) {
					rp_SetClientBool(i, b_HasVilla, true);
					rp_SetClientKeyAppartement(i, 50, true);
					rp_SetClientInt(i, i_AppartCount, rp_GetClientInt(i, i_AppartCount) + 1);
				}
			}
			
			Format(szQuery, sizeof(szQuery), "UPDATE `rp_users` SET `hasVilla`='0' WHERE `steamid`<>'%s'", szSteamID);
			SQL_TQuery(rp_GetDatabase(), SQL_QueryCallBack, szQuery);
			
			Format(szQuery, sizeof(szQuery), "UPDATE `rp_users` SET `hasVilla`='1' WHERE `steamid`='%s'", szSteamID);
			SQL_TQuery(rp_GetDatabase(), SQL_QueryCallBack, szQuery);
			
			Format(szQuery, sizeof(szQuery), "UPDATE `rp_servers` SET `villaOwner`='%s'", szSteamID);
			SQL_TQuery(rp_GetDatabase(), SQL_QueryCallBack, szQuery);
		}
		else {
			Format(szQuery, sizeof(szQuery), "INSERT INTO `rp_users2` (`steamid`,  `bank`) VALUES ('%s', %d);", szSteamID, gain);
			SQL_TQuery(rp_GetDatabase(), SQL_QueryCallBack, szQuery);
		}
		place++;
	}
	
	SQL_TQuery(rp_GetDatabase(), SQL_QueryCallBack, "TRUNCATE `rp_bid`");
}
void dispatchToJob(int gain) {
	int jobCount = 0;
	int capitalTotal = 0;
	

	for (int i = 1; i <= 221; i+=10) {
		if( rp_GetJobInt(i, job_type_isboss) == 1 ) {
			capitalTotal += rp_GetJobCapital(i);
			jobCount++;
		}
	}
	
	int fraction = capitalTotal / jobCount;
	jobCount = 0;
	
	for (int i = 1; i <= 221; i+=10) {
		if( rp_GetJobInt(i, job_type_isboss) == 1 && rp_GetJobCapital(i) <= fraction )
			jobCount++;
	}
	
	for (int i = 1; i <= 221; i+=10) {
		if( rp_GetJobInt(i, job_type_isboss) == 1 && rp_GetJobCapital(i) <= fraction )
			rp_SetJobCapital(i, rp_GetJobCapital(i) + (gain / jobCount));
	}
}
