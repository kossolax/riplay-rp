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
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <colors_csgo>	// https://forums.alliedmods.net/showthread.php?p=2205447#post2205447
#include <smlib>		// https://github.com/bcserv/smlib
#include <emitsoundany> // https://forums.alliedmods.net/showthread.php?t=237045

#pragma newdecls required
#include <roleplay.inc>	// https://www.ts-x.eu

public Plugin myinfo = {
	name = "Jobs: Mafia", author = "KoSSoLaX",
	description = "RolePlay - Jobs: Mafia",
	version = __LAST_REV__, url = "https://www.ts-x.eu"
};

int g_iLastDoor[65][3];
int g_iDoorDefine_LOCKER[2049];
int g_iAppartPickLockCount[200];
float g_flAppartNewPickLock[200];
float g_flAppartProtection[200];
bool g_bCanUseCB[MAXPLAYERS+1];
Handle g_vCapture;
int g_cBeam;
DataPack g_hBuyMenu_Items;
DataPack g_hBuyMenu_Weapons;

enum IM_Int {
	IM_Owner,
	IM_StealFrom,
	IM_ItemID,
	IM_Prix,
	IM_Max
}
bool CanClientStealItem(int client, int target) {
	Action a;
	Call_StartForward(rp_GetForwardHandle(client, RP_PreClientStealItem));
	Call_PushCell(client);
	Call_PushCell(target);
	Call_Finish(a);
	if( a == Plugin_Handled || a == Plugin_Stop )
		return false;
	return true;
}
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
	LoadTranslations("roleplay.mafia.phrases");
	
	RegServerCmd("rp_quest_reload", Cmd_Reload);
	RegServerCmd("rp_item_piedbiche", 	Cmd_ItemPiedBiche,		"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_hack",		Cmd_ItemHack,		"RP-ITEM", 	FCVAR_UNREGISTERED);	
	RegServerCmd("rp_item_picklock", 	Cmd_ItemPickLock,		"RP-ITEM",	FCVAR_UNREGISTERED); 
	RegServerCmd("rp_item_picklock2", 	Cmd_ItemPickLock,		"RP-ITEM",	FCVAR_UNREGISTERED);
	// Epicier
	RegServerCmd("rp_item_doorDefine",	Cmd_ItemDoorDefine,		"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_doorprotect", Cmd_ItemDoorProtect,	"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_GetStoreItem",	Cmd_GetStoreItem,			"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_door_breakcadenas", CmdBreakCadenas);
	RegServerCmd("rp_door_remove_cadenas", CmdBreakCadenas_Force);
	
	
	g_hBuyMenu_Items = new DataPack();
	g_hBuyMenu_Items.WriteCell(0);
	DataPackPos pos = g_hBuyMenu_Items.Position;
	g_hBuyMenu_Items.Reset();
	g_hBuyMenu_Items.WriteCell(pos);
	
	for (int i = 1; i <= MaxClients; i++)
		if( IsValidClient(i) )
			OnClientPostAdminCheck(i);
}
public void OnAllPluginsLoaded() {
	g_hBuyMenu_Weapons = rp_WeaponMenu_Create();
}
public void OnPluginEnd() {
	if (g_hBuyMenu_Weapons)
		rp_WeaponMenu_Clear(g_hBuyMenu_Weapons);
}
public Action CmdBreakCadenas_Force(int args) {
	int door = GetCmdArgInt(1);
	int tzone = rp_GetPlayerZone(door);
	int doorID = rp_GetDoorID(door);
	
	if( IsValidClient(g_iDoorDefine_LOCKER[doorID]) ) {			
		char tmp[128];
		rp_GetZoneData(tzone, zone_type_name, tmp, sizeof(tmp));
		CPrintToChat(g_iDoorDefine_LOCKER[doorID], "" ...MOD_TAG... " %T", "Lockpad_BrokenYours", g_iDoorDefine_LOCKER[doorID], tmp);
		g_iDoorDefine_LOCKER[doorID] = 0;
	}
	
	return Plugin_Handled;
}
public Action CmdBreakCadenas(int args) {
	int client = GetCmdArgInt(1);
	int door = GetCmdArgInt(2);
	
	float difficulte = 0.7;
	int tzone = rp_GetPlayerZone(door);
	int doorID = rp_GetDoorID(door);
	
	int appartID = zoneToAppartID(rp_GetPlayerZone(door));
	if( appartID > 0 && g_flAppartProtection[appartID] > GetGameTime() ) {
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Mafia_Protect", client, (g_flAppartProtection[appartID] - GetGameTime()) / 60.0);
		return Plugin_Handled;
	}
	
	if( rp_IsInPVP(client) || rp_GetZoneInt(tzone, zone_type_type) == 101 )
		difficulte += 0.05;
	if( rp_GetZoneBit( tzone ) & BITZONE_HAUTESECU || rp_GetZoneInt(tzone, zone_type_type) == 101 )
		difficulte += 0.05;
	if( g_iDoorDefine_LOCKER[doorID] )
		difficulte += 0.1;
	
	if( GetRandomFloat() > difficulte ) {
		
		if( IsValidClient(g_iDoorDefine_LOCKER[doorID]) ) {			
			char tmp[128];
			rp_GetZoneData(tzone, zone_type_name, tmp, sizeof(tmp));
			CPrintToChat(g_iDoorDefine_LOCKER[doorID], "" ...MOD_TAG... " %T", "Lockpad_BrokenYours", g_iDoorDefine_LOCKER[doorID], tmp);
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Lockpad_Broken", client);
			g_iDoorDefine_LOCKER[doorID] = 0;
		}
		
		rp_SetDoorLock(doorID, false); 
		rp_ClientOpenDoor(client, doorID, true);
	}
	return Plugin_Handled;
}
public Action Cmd_GetStoreItem(int args) {
	Cmd_Buy(GetCmdArgInt(1), true);
}
public Action Cmd_ItemDoorProtect(int args) {
	int client = GetCmdArgInt(1);
	int vendeur = GetCmdArgInt(2);
	int item_id = GetCmdArgInt(args);
	
	int appartID = rp_GetPlayerZoneAppart(client);
	if( appartID > 0 && rp_GetClientKeyAppartement(client, appartID) ) {
		float time = (appartID == 50 || appartID == 51 ? 8.0:24.0);
		
		if( g_flAppartProtection[appartID] <= GetGameTime() ) {
			g_flAppartProtection[appartID] = GetGameTime() + (time * 60.0);
		}
		else {
			g_flAppartProtection[appartID] += (time * 60.0);
		}
		
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Mafia_Protect", client, (g_flAppartProtection[appartID] - GetGameTime()) / 60.0);
	}
	else {
		rp_CANCEL_AUTO_ITEM(client, vendeur, item_id);
		CPrintToChat(client, ""...MOD_TAG..." %T", "Error_OnlyInsideAppart", client);
	}
}
public void OnMapStart() {
	g_cBeam = PrecacheModel("materials/sprites/laserbeam.vmt", true);
}
public void OnConfigsExecuted() {
	g_vCapture =  FindConVar("rp_capture");
}
public void OnClientPostAdminCheck(int client) {
	rp_HookEvent(client, RP_OnPlayerUse,	fwdOnPlayerUse);
	rp_HookEvent(client, RP_OnPlayerSteal,	fwdOnPlayerSteal);
	rp_HookEvent(client, RP_OnPlayerBuild,	fwdOnPlayerBuild);
	rp_HookEvent(client, RP_OnAssurance,	fwdAssurance);
	rp_HookEvent(client, RP_PostStealWeapon, fwdOnStealWeapon);
	
	rp_SetClientBool(client, b_MaySteal, true);
	g_bCanUseCB[client] = true;
}
public Action fwdAssurance(int client, int& amount) {
	for (int i = 1; i < 2048; i++) {
		if( g_iDoorDefine_LOCKER[i] == client )
			amount += 150;
	}
	
	return Plugin_Changed;
}
public Action fwdOnStealWeapon(int client, int target, int weaponID) {
	if( client == target && rp_GetClientJobID(client) == 91 ) {
		if( rp_WeaponMenu_Add(g_hBuyMenu_Weapons, weaponID, client) ) {
			AcceptEntityInput(weaponID, "Kill");
			FakeClientCommand(client, "use weapon_fists");
		}
	}
}
public void OnClientDisconnect(int client) {
	for(int i=0; i<2049; i++){
		if(g_iDoorDefine_LOCKER[i] == client)
			g_iDoorDefine_LOCKER[i] = 0;
	}
}
public Action fwdOnPlayerBuild(int client, float& cooldown){
	if( rp_GetClientJobID(client) != 91 )
		return Plugin_Continue;
	
	if( disapear(client) ) {
		int job = rp_GetClientInt(client, i_Job);
		switch( job ) {
			case 91:	cooldown = 120.0;
			case 92:	cooldown = 120.0;
			case 93:	cooldown = 130.0; // parrain
			case 94:	cooldown = 140.0; // pro
			case 95:	cooldown = 150.0; // mafieux
			case 96:	cooldown = 160.0; // apprenti
			default:	cooldown = 160.0;
		}
	}
	else {
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Mafia_Deguise_Failed", client);
		cooldown = 0.1;
	}
	return Plugin_Stop;
}
public Action fwdOnPlayerSteal(int client, int target, float& cooldown) {
	if( rp_GetClientJobID(client) != 91 )
		return Plugin_Continue;
	static int RandomItem[MAX_ITEMS];
	static char tmp[128], szQuery[1024];
	
	if( rp_GetClientJobID(target) == 91 ) {
		cooldown = 1.0;
		ACCESS_DENIED(client);
	}
	if( rp_GetClientInt(target, i_PlayerLVL) <= 5 ||
		rp_GetClientFloat(target, fl_LastStolen)+60.0 > GetGameTime() ||
		rp_ClientFloodTriggered(client, target, fd_vol) ||
		( rp_IsClientNew(target) && rp_GetClientFloat(target, fl_LastStolen)+300.0 > GetGameTime() ) ) {
		CPrintToChat(client, ""...MOD_TAG..." %T", "Error_CannotSteal_Target_ForNow", client);
		cooldown = 1.0;
		return Plugin_Stop;
	}
	if( rp_GetZoneBit( rp_GetPlayerZone(target) ) & BITZONE_BLOCKSTEAL ) {
		cooldown = 1.0;
		ACCESS_DENIED(client);
	}
	
	if( rp_GetZoneInt(rp_GetPlayerZone(target), zone_type_type) == 91 ) {
		CPrintToChat(client, ""...MOD_TAG..." %T", "Error_CannotSteal_Target_ForNow", client);
		cooldown = 1.0;
		return Plugin_Handled;
	}
	
	int VOL_MAX, amount, money, job, prix;
	money = rp_GetClientInt(target, i_Money);
	VOL_MAX = (money+rp_GetClientInt(target, i_Bank)) / 200;
		
	if( VOL_MAX > 0 && money <= 25 && rp_GetClientInt(client, i_Job) <= 93 && !rp_IsClientNew(target) && CanClientStealItem(client, target) ) {
		amount = 0;
		
		for(int i = 0; i < MAX_ITEMS; i++) {
			
			if( rp_GetClientItem(target, i) <= 0 )
				continue;
				
			job = rp_GetItemInt(i, item_type_job_id);
			if( job == 0|| job == 91 || job == 101 || job == 181 )
				continue;
			if( job == 51 && !(rp_GetClientItem(target, i) >= 1 && Math_GetRandomInt(0, 1) == 1) ) // TODO: Double vérif voiture
				continue;
			
			rp_GetItemData(i, item_type_extra_cmd, tmp, sizeof(tmp));
			if( StrContains(tmp, "rp_item_raw") == 0 )
				continue;
			
			RandomItem[amount++] = i;
		}
		
		if( amount != 0  ) {
			int it = RandomItem[ Math_GetRandomInt(0, (amount-1)) ];
			prix = rp_GetItemInt(it, item_type_prix) / 2;
			
			rp_ClientGiveItem(target, it, -1);
			
			rp_SetClientInt(client, i_LastVolTime, GetTime());
			rp_SetClientInt(client, i_LastVolAmount, (prix * MARCHEMAFIA_PC) / 100);
			rp_SetClientInt(client, i_LastVolTarget, target);
			rp_SetClientInt(target, i_LastVol, client);		
			rp_SetClientFloat(target, fl_LastVente, GetGameTime() + 10.0);
			rp_SetClientFloat(target, fl_LastStolen, GetGameTime() + (rp_GetClientBool(target, b_IsAFK) ? 300.0 : 0.0));
			
			rp_GetItemData(it, item_type_name, tmp, sizeof(tmp));
			
			addBuyMenu(client, target, it);
			amount = rp_GetItemInt(it, item_type_prix);
			
			CPrintToChat(client, ""...MOD_TAG..." %T", "Steal_Item_Target", client, 1, tmp);
			CPrintToChat(target, ""...MOD_TAG..." %T", "Steal_Item_By", target, 1, tmp);
						
			LogToGame("[TSX-RP] [VOL] %L a vole %L 1 %s", client, target, tmp);
			
			GetClientAuthId(client, AUTH_TYPE, tmp, sizeof(tmp), false);
			Format(szQuery, sizeof(szQuery), "INSERT INTO `rp_sell` (`id`, `steamid`, `job_id`, `timestamp`, `item_type`, `item_id`, `item_name`, `amount`) VALUES (NULL, '%s', '%i', '%i', '2', '%i', '%s', '%i');",
				tmp, rp_GetClientJobID(client), GetTime(), it, "Vol: Objet", amount);

			SQL_TQuery( rp_GetDatabase(), SQL_QueryCallBack, szQuery);
			
			int alpha[4];
			alpha[1] = 255;
			alpha[3] = 50;
			
			if( rp_IsNight() ) {
				cooldown *= 1.5;
				alpha[3] = 25;
			}
			else {
				cooldown *= 2.0;
			}
			
			if( amount < 50 )
				cooldown *= 0.5;
			if( amount < 5 )
				cooldown *= 0.5;
			
			for (int i = 1; i <= MaxClients; i++) {
				if( !IsValidClient(i) )
					continue;
				if( rp_GetClientJobID(i) == 91 && i != client )
					rp_ClientFloodIncrement(i, target, fd_vol, cooldown);
			}
			rp_ClientFloodIncrement(client, target, fd_vol, 2.0 * cooldown);
			
			float vecTarget[3];
			GetClientAbsOrigin(client, vecTarget);
			rp_Effect_Cashflow(client, Math_Clamp(RoundToNearest(Pow(amount*2.0, 0.85)), 1, 1000)  );
			
			rp_ClientAggroIncrement(client, target, 1000);
			if( rp_GetClientBool(client, b_GameModePassive) == false ) {
				rp_HookEvent(client, RP_PrePlayerPhysic, fwdAccelerate, 5.0);
			}
			rp_ClientOverlays(target, o_Action_StealItem, 10.0);
			//g_iSuccess_last_pas_vu_pas_pris[target] = GetTime();	
			return Plugin_Stop;	
		}
	}

	if( rp_IsClientNew(target) )
		amount = Math_GetRandomPow(1, VOL_MAX);
	else
		amount = Math_GetRandomInt(1, VOL_MAX);

	if( VOL_MAX > 0 && money >= 1 ) {
		if( amount > money )
			amount = money;
			
		float targetStealImmunity = 60.0;
		rp_SetClientStat(target, i_MoneySpent_Stolen, rp_GetClientStat(target, i_MoneySpent_Stolen) + amount);
		rp_ClientMoney(client, i_AddToPay, amount);
		rp_ClientMoney(target, i_Money, -amount);
		rp_SetClientInt(client, i_LastVolTime, GetTime());
		rp_SetClientInt(client, i_LastVolAmount, amount);
		rp_SetClientInt(client, i_LastVolTarget, target);
		rp_SetClientInt(target, i_LastVol, client);
		
		CPrintToChat(client, ""...MOD_TAG..." %T", "Steal_Money_Target", client, amount);
		CPrintToChat(target, ""...MOD_TAG..." %T", "Steal_Money_By", target, amount);

		//g_iSuccess_last_mafia[client][1] = GetTime();
		//g_iSuccess_last_pas_vu_pas_pris[target] = GetTime();
		LogToGame("[TSX-RP] [VOL] %L a vole %L %i$", client, target, amount);
		
		GetClientAuthId(client, AUTH_TYPE, tmp, sizeof(tmp), false);
		Format(szQuery, sizeof(szQuery), "INSERT INTO `rp_sell` (`id`, `steamid`, `job_id`, `timestamp`, `item_type`, `item_id`, `item_name`, `amount`) VALUES (NULL, '%s', '%i', '%i', '4', '%i', '%s', '%i');",
			tmp, rp_GetClientJobID(client), GetTime(), 0, "Vol: Argent", amount);
		SQL_TQuery(rp_GetDatabase(), SQL_QueryCallBack, szQuery);
		
		if( rp_IsNight() )
			cooldown *= 0.5;
		
		if( amount < 50 )
			cooldown *= 0.5;
		if( amount < 26 )
			targetStealImmunity = 20.0;
		if( amount < 5 )
			cooldown *= 0.5;
			
		if( amount > 500 )
			targetStealImmunity = 70.0;
		if( amount > 2000 )
			targetStealImmunity = 90.0;
		
		for (int i = 1; i <= MaxClients; i++) {
			if( !IsValidClient(i) )
				continue;
			if( rp_GetClientJobID(i) == 91 && i != client )
				rp_ClientFloodIncrement(i, target, fd_vol, cooldown);
		}
		rp_ClientFloodIncrement(client, target, fd_vol, 2.0 * cooldown);

		if(amount >= 25) {
			rp_Effect_Cashflow(client, Math_Clamp(RoundToNearest(Pow(amount*2.0, 0.85)), 1, 1000)  );
		}

		if (rp_GetClientBool(target, b_IsAFK)){
			targetStealImmunity = 300.0;
		}


		rp_SetClientFloat(target, fl_LastStolen, GetGameTime() + targetStealImmunity - 60.0);


		int cpt = rp_GetRandomCapital(91);
		rp_SetJobCapital(91, rp_GetJobCapital(91) + (amount/4));
		rp_SetJobCapital(cpt, rp_GetJobCapital(cpt) - (amount/4));
		
		rp_ClientAggroIncrement(client, target, 1000);
		
		rp_HookEvent(client, RP_PrePlayerPhysic, fwdAccelerate, 10.0);
		if( rp_GetClientBool(client, b_GameModePassive) == false )
			rp_HookEvent(client, RP_PrePlayerPhysic, fwdAccelerate, 5.0);
		
		rp_ClientOverlays(target, o_Action_StealMoney, 10.0);
		return Plugin_Stop;
	}


	CPrintToChat(client, ""...MOD_TAG..." %T", "Error_CannotSteal_Target_Broke", client);

	cooldown = 1.0;
	return Plugin_Stop;	
}

public Action fwdAccelerate(int client, float& speed, float& gravity) {
	speed += 0.5;
	return Plugin_Changed;
}

public Action fwdOnPlayerUse(int client) {
	static char tmp[128];
	
	if( rp_GetClientJobID(client) == 91 && rp_GetZoneInt(rp_GetPlayerZone(client), zone_type_type) == 91 ) {
		bool changed = false;
		
		for(int itemID=1; itemID<=4; itemID++) {
			int mnt = rp_GetClientItem(client, itemID);
			int max = GetMaxKit(client, itemID);
			if( mnt <  max ) {
				rp_ClientGiveItem(client, itemID, max - mnt);
				rp_GetItemData(itemID, item_type_name, tmp, sizeof(tmp));
				CPrintToChat(client, ""...MOD_TAG..." %T", "Item_Take", client, max - mnt, tmp);
				
				changed = true;
			}
		}

		
		if(changed == true) {
			FakeClientCommand(client, "say /item");
		}
	}
	
	float vecOrigin[3];
	GetClientAbsOrigin(client, vecOrigin);
	if( GetVectorDistance(vecOrigin, MARCHEMAFIA_POS) < 150.0 ) {
		Cmd_Buy(client, false);
	}
}
// ----------------------------------------------------------------------------
public Action Cmd_ItemDoorDefine(int args) {
	char Arg1[12];	GetCmdArg(1, Arg1, 11);	
	int client = GetCmdArgInt(2);
	int item_id = GetCmdArgInt(args);
	
	int door = getDoor(client);
	
	if( door == 0 ) {
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_YouMustAim", client, "prop_door_rotating");
		ITEM_CANCEL(client, item_id);
		return Plugin_Handled;
	}
	
	int doorID = rp_GetDoorID(door);
	if(g_iDoorDefine_LOCKER[doorID] != 0 ) {
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Lockpad_Already", client);
		ITEM_CANCEL(client, item_id);
		return Plugin_Handled;
	}
	g_iDoorDefine_LOCKER[doorID] = client;
	
	return Plugin_Handled;
}
public Action Cmd_ItemHack(int args) {
	
	int client = GetCmdArgInt(1);
	int item_id = GetCmdArgInt(args);

	if( rp_GetClientJobID(client) != 91 ) {
		return Plugin_Continue;
	}
	
	if( !g_bCanUseCB[client] ) {
		ITEM_CANCEL(client, item_id);
		
		char tmp[128];
		rp_GetItemData(item_id, item_type_name, tmp, sizeof(tmp));
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_ItemCannotBeUsedForNow", client, tmp);
		return Plugin_Handled;
	}
	
	int type;
	int target = getDistrib(client, type);
	int targetOwner = rp_GetBuildingData(target, BD_owner);

	if( target <= 0 || type != 8) {
		ITEM_CANCEL(client, item_id);
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_YouMustAim", client, "prop_door_rotating");
		return Plugin_Handled;
	}

	if( targetOwner > 0 && rp_GetClientFloat(targetOwner, fl_LastStolen)+60.0 > GetGameTime() ){
		ITEM_CANCEL(client, item_id);
		char tmp[128];
		rp_GetItemData(item_id, item_type_name, tmp, sizeof(tmp));
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_ItemCannotBeUsedForNow", client, tmp);
		return Plugin_Handled;
	}

	float start = 0.0;
	
	rp_SetClientStat(client, i_JobFails, rp_GetClientStat(client, i_JobFails) + 1);

	rp_ClientGiveItem(client, item_id, -rp_GetClientItem(client, item_id));
	g_bCanUseCB[client] = false;
	rp_SetClientInt(client, i_LastVolTime, GetTime());
	rp_SetClientInt(client, i_LastVolAmount, 100);
	rp_SetClientInt(client, i_LastVolTarget, -1);
	rp_ClientReveal(client);
	
	char classname[64];
	GetEdictClassname(target, classname, sizeof(classname));
	
	ServerCommand("sm_effect_particles %d weapon_sensorgren_detonate 1 facemask", client);
	ServerCommand("sm_effect_particles %d Trail2 2 legacy_weapon_bone", client);
	
	Handle dp;
	CreateDataTimer(0.1, ItemPiedBiche_frame, dp, TIMER_DATA_HNDL_CLOSE|TIMER_REPEAT);
	WritePackCell(dp, client);
	WritePackCell(dp, target);
	WritePackCell(dp, start);
	WritePackCell(dp, type);
	WritePackCell(dp, item_id);
	
	return Plugin_Handled;
}

public Action Cmd_ItemPiedBiche(int args) {
	
	int client = GetCmdArgInt(1);
	int item_id = GetCmdArgInt(args);

	if( rp_GetClientJobID(client) != 91 ) {
		return Plugin_Continue;
	}
	
	if( rp_GetClientBool(client, b_MaySteal) == false ) {
		ITEM_CANCEL(client, item_id);
		char tmp[128];
		rp_GetItemData(item_id, item_type_name, tmp, sizeof(tmp));
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_ItemCannotBeUsedForNow", client, tmp);
		return Plugin_Handled;
	}
	
	int type;
	int target = getDistrib(client, type);

	if( target <= 0 || type == 8 ) {
		ITEM_CANCEL(client, item_id);
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Mafia_Crowbar", client);
		return Plugin_Handled;
	}

	float start = 0.0;
	
	if( type == 3 || type == 4  )
		start = Math_GetRandomFloat(0.5, 0.66);
	
	int owner = rp_GetBuildingData(target, BD_owner);
	if( IsValidClient(owner) ) {
		if( type == 4 || type == 5 ) {
			CPrintToChat(owner, "" ...MOD_TAG... " %T", "Crowbar_FauxBillet", owner);
		}
		else if( type == 7 ) {
			CPrintToChat(owner, "" ...MOD_TAG... " %T", "Crowbar_Drugs", owner);
		}
		else if( type == 8 ) {
			CPrintToChat(owner, "" ...MOD_TAG... " %T", "Crowbar_Distrib", owner);
		}
	}
		
	
	rp_SetClientStat(client, i_JobFails, rp_GetClientStat(client, i_JobFails) + 1);

	rp_ClientGiveItem(client, item_id, -rp_GetClientItem(client, item_id));
	rp_SetClientBool(client, b_MaySteal, false);
	rp_SetClientInt(client, i_LastVolTime, GetTime());
	rp_SetClientInt(client, i_LastVolAmount, 100);
	rp_SetClientInt(client, i_LastVolTarget, -1);	
	rp_ClientReveal(client);
	
	char classname[64];
	GetEdictClassname(target, classname, sizeof(classname));
	
	ServerCommand("sm_effect_particles %d weapon_sensorgren_detonate 1 facemask", client);
	ServerCommand("sm_effect_particles %d Trail2 2 legacy_weapon_bone", client);
	
	Handle dp;
	CreateDataTimer(0.1, ItemPiedBiche_frame, dp, TIMER_DATA_HNDL_CLOSE|TIMER_REPEAT);
	WritePackCell(dp, client);
	WritePackCell(dp, target);
	WritePackCell(dp, start);
	WritePackCell(dp, type);
	WritePackCell(dp, item_id);
	
	return Plugin_Handled;
}
public Action ItemPiedBiche_frame(Handle timer, Handle dp) {
	ResetPack(dp);
	int client = ReadPackCell(dp);
	int target = ReadPackCell(dp);
	float percent = ReadPackCell(dp);
	int type = ReadPackCell(dp);
	int item_id = ReadPackCell(dp);
	int type2;
	
	
	if( !IsValidClient(client ) ) {
		return Plugin_Stop;
	}
	if( getDistrib(client, type2) != target ) {
		MENU_ShowPickLock(client, percent, -1, type);
		rp_ClientColorize(client);
		rp_ClientGiveItem(client, item_id, 1);
		if(type == 8)
			CreateTimer(0.1, AllowStealingCB, client);
		else
			CreateTimer(0.1, AllowStealing, client);
		
		return Plugin_Stop;
	}
	
	switch(type) {
		case 4: { // Imprimante
			int owner = rp_GetBuildingData(target, BD_owner);
			if( IsValidClient(owner) ) {				
				rp_ClientAggroIncrement(client, owner, 1000);
			}
		}
		case 5: { // Photocopieuse
			int owner = rp_GetBuildingData(target, BD_owner);
			if( IsValidClient(owner) ) {				
				rp_ClientAggroIncrement(client, owner, 1000);
			}
		}
		case 7: { // Plant de drogue
			int count = rp_GetBuildingData(target, BD_count);
			if( count > 0  ) {				
				int owner = rp_GetBuildingData(target, BD_owner);
				if( IsValidClient(owner) ) {				
					rp_ClientAggroIncrement(client, owner, 1000);
				}
			}
		}
		case 8: { // Distrib Perso
			int owner = rp_GetBuildingData(target, BD_owner);
			if( IsValidClient(owner) ) {
				rp_ClientAggroIncrement(client, owner, 1000);
			}
		}
	}
			
	if( percent >= 1.0 ) {
		rp_ClientColorize(client);
		
		if( rp_GetBuildingData(target, BD_Trapped) > 0 ) {
			rp_Effect_PropExplode(target, client);
			if( rp_GetBuildingData(target, BD_Trapped) == 0 ) {
				CreateTimer(0.1, AllowStealing, client);
				return Plugin_Stop;
			}
		}

		
		rp_SetClientStat(client, i_JobSucess, rp_GetClientStat(client, i_JobSucess) + 1);
		rp_SetClientStat(client, i_JobFails, rp_GetClientStat(client, i_JobFails) - 1);
		
		float time = (rp_IsNight() ? STEAL_TIME:STEAL_TIME*2.0);
		int stealAmount;
		
		Call_StartForward(rp_GetForwardHandle(client, RP_PostPiedBiche));
		Call_PushCell(client);
		Call_PushCell(type);
		Call_Finish();
		
		switch(type) {
			case 2: { // Banque
				time *= 2.0;
				int count = rp_CountPoliceNear(client), rand = 4 + Math_GetRandomPow(0, 4), i;
				
				for (i = 0; i < count; i++)
					rand += (4 + Math_GetRandomPow(0, 12));
				for (i = 0; i < rand; i++)
					CreateTimer(i / 5.0, SpawnMoney, EntIndexToEntRef(target));
				
				stealAmount = 25*rand;
			}
			case 3: { // Armu
				time /= 2.0;
				rp_ClientDrawWeaponMenu(client, target, true);
				stealAmount = 100; 
				
			}
			case 4: { // Imprimante
				time /= 6.0;
				
				int owner = rp_GetBuildingData(target, BD_owner);
				if( IsValidClient(owner) ) {
					rp_SetBuildingData(target, BD_HackedBy, client);
					rp_SetBuildingData(target, BD_HackedTime, GetTime());
					CPrintToChat(owner, "" ...MOD_TAG... " %T", "Crowbar_FauxBillet", owner);
				}
				
				Entity_SetHealth(target, Entity_GetHealth(target) - Entity_GetMaxHealth(target) / 10);
			}
			case 5: { // Photocopieuse
				time /= 6.0;
				
				int owner = rp_GetBuildingData(target, BD_owner);
				if( IsValidClient(owner) ) {
					rp_SetBuildingData(target, BD_HackedBy, client);
					rp_SetBuildingData(target, BD_HackedTime, GetTime());
					CPrintToChat(owner, "" ...MOD_TAG... " %T", "Crowbar_FauxBillet", owner);
				}
				
				Entity_SetHealth(target, Entity_GetHealth(target) - Entity_GetMaxHealth(target) / 10);
			}
			case 6: { // Téléphone
				time *= 6.0;
				stealAmount = 250;
				missionTelephone(client);
			}
			case 7: { // Plant de drogue
				
				int count = rp_GetBuildingData(target, BD_count);
				
				if( count > 0  ) {
					char classname[64];
					
					int sub = rp_GetBuildingData(target, BD_item_id);
					int prix = rp_GetItemInt(sub, item_type_prix);
					int max = 1000 / prix;
					
					if( count > max )
						count = max;
					
					rp_GetItemData(sub, item_type_name, classname, sizeof(classname));
					rp_SetBuildingData(target, BD_count, 0);
					stealAmount = 75 * count;
					SetEntityModel(target, "models/custom_prop/marijuana/marijuana_0.mdl");
					SDKHooks_TakeDamage(target, client, client, 125.0);
					
					int owner = rp_GetBuildingData(target, BD_owner);
					if( IsValidClient(owner) ) {
						CPrintToChat(owner, "" ...MOD_TAG... " %T", "Crowbar_Drugs", owner);
						if( rp_GetBuildingData(target, BD_FromBuild) ) {
							count /= 2;
							if( count < 0 )
								count = 1;
						}
						
						CPrintToChat(owner, "" ...MOD_TAG... " %T", "Steal_Item_By", owner, count, classname);
					}
					
					for (int i = 0; i < count; i++)
						addBuyMenu(client, target, sub);
					
					stealAmount = (count * prix) / 2;
					CPrintToChat(client, "" ...MOD_TAG... " %T", "Steal_Item_Target", owner, count, classname);
				}
				Entity_SetHealth(target, Entity_GetHealth(target) - Entity_GetMaxHealth(target) / 10);
			}
			case 8: { // Distrib Perso
				time *= 4.0;
				int owner = rp_GetBuildingData(target, BD_owner);
				stealAmount = 1500;

				if( IsValidClient(owner) ) {
					
					int vol_max = (rp_GetClientInt(owner, i_Money) + rp_GetClientInt(owner, i_Bank)) / 500;
					int vol_min = (rp_GetClientInt(owner, i_Money)+rp_GetClientInt(owner, i_Bank)) / 2000;

					stealAmount = Math_GetRandomPow(vol_min, vol_max);

					if(vol_max < stealAmount || rp_GetClientFloat(owner, fl_LastStolen)+60.0 > GetGameTime() ){
						CPrintToChat(client, "" ...MOD_TAG... " %T", "Crowbar_Distrib_Failed", client);

						MENU_ShowPickLock(client, percent, -1, type);
						rp_ClientColorize(client);
						CreateTimer(0.1, AllowStealingCB, client);
						rp_ClientGiveItem(client, item_id, 1);
						return Plugin_Stop;						
					}

					rp_SetClientFloat(owner, fl_LastStolen, GetGameTime());

					rp_ClientMoney(owner, i_Bank, -stealAmount);
					rp_ClientMoney(client, i_AddToPay, stealAmount);

					rp_SetClientStat(owner, i_MoneySpent_Stolen, rp_GetClientStat(owner, i_MoneySpent_Stolen) + stealAmount);

					CPrintToChat(owner, "" ...MOD_TAG... " %T", "Crowbar_Distrib", owner);
					CPrintToChat(owner, "" ...MOD_TAG... " %T", "Steal_Money_By", owner, stealAmount);
					CPrintToChat(client, "" ...MOD_TAG... " %T", "Steal_Money_Target", client, stealAmount);
					
					CreateTimer(time, AllowStealingCB, client);
					time = 0.0;
				} else {
					CreateTimer(0.1, AllowStealingCB, client);
					CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_FromServer", client);
					return Plugin_Stop;
				}
			}
		}
		
		rp_SetClientInt(client, i_LastVolTime, GetTime());
		rp_SetClientInt(client, i_LastVolTarget, -1);
		rp_SetClientInt(client, i_LastVolAmount, stealAmount); 
		
		if(time >= 0.0 && type != 8 )
			CreateTimer(time, AllowStealing, client);
		
		return Plugin_Stop;
	}
	
	if( Math_GetRandomInt(1, 10) == 8 )
		ServerCommand("sm_effect_particles %d Trail2 2 legacy_weapon_bone", client);
	if( Math_GetRandomInt(1, 30) == 8 )
		ServerCommand("sm_effect_particles %d Aura2 1 footplant_L", client);
	if( Math_GetRandomInt(1, 30) == 8 )
		ServerCommand("sm_effect_particles %d Aura2 1 footplant_R", client);
		
	if( Math_GetRandomInt(1, 500) == 42 )
		CreateTimer(0.01, timerAlarm, target); 
	
	float ratio = 15.0 / 2500.0;
	
	if( type )
		ratio *= 2.0;
	
	rp_SetClientFloat(client, fl_CoolDown, GetGameTime() + 0.15);
	
	ResetPack(dp);
	WritePackCell(dp, client);
	WritePackCell(dp, target);
	WritePackCell(dp, percent + ratio);
	WritePackCell(dp, type);
	MENU_ShowPickLock(client, percent, 0, type);
	return Plugin_Continue;
}
public Action SpawnMoney(Handle timer, any target) {
	
	target = EntRefToEntIndex(target);
	if( !IsValidEdict(target) )
		return Plugin_Handled;
	
	char classname[64];
	GetEdictClassname(target, classname, sizeof(classname));
	
	float vecOrigin[3], vecAngle[3], vecPos[3], min[3], max[3];
	Entity_GetAbsOrigin(target, vecOrigin);
	Entity_GetAbsAngles(target, vecAngle);
	
	if( StrContains(classname, "rp_bank") == 0 && rp_GetBuildingData(target, BD_owner) <= 0) {
		Math_RotateVector( view_as<float>({ 7.0, 0.0, 40.0 }), vecAngle, vecPos);
		vecOrigin[0] += vecPos[0];
		vecOrigin[1] += vecPos[1];
		vecOrigin[2] += vecPos[2];
		
		vecAngle[0] += Math_GetRandomFloat(-5.0, 5.0);
		vecAngle[1] += Math_GetRandomFloat(-5.0, 5.0);	
		Math_RotateVector( view_as<float>({ 0.0, 250.0, 40.0 }), vecAngle, vecPos);
		
		int rnd = Math_GetRandomInt(2, 5) * 10;
		int job = rp_GetRandomCapital(91);
		rp_SetJobCapital(job, rp_GetJobCapital(job) - rnd);
	}
	else {
		Entity_GetMinSize(target, min);
		Entity_GetMaxSize(target, max);
		
		vecOrigin[2] += max[2] - min[2];
		
		vecPos[0] += Math_GetRandomFloat(-100.0, 100.0);
		vecPos[1] += Math_GetRandomFloat(-100.0, 100.0);
		vecPos[2] += Math_GetRandomFloat(200.0, 300.0);
	}
	
	int m = rp_Effect_SpawnMoney(vecOrigin);
	TeleportEntity(m, NULL_VECTOR, NULL_VECTOR, vecPos);
	ServerCommand("sm_effect_particles %d Trail9 3", m);
	return Plugin_Handled;
}
// ----------------------------------------------------------------------------
public Action Cmd_ItemPickLock(int args) {
	
	int client = GetCmdArgInt(1);
	int item_id = GetCmdArgInt(args);
	bool fast = false;

	char arg[64];
	GetCmdArg(0, arg, sizeof(arg));
	if( StrEqual(arg, "rp_item_picklock2") ) 
		fast = true;
		
	if( rp_GetClientJobID(client) != 91 ) {
		return Plugin_Continue;
	}

	int door = getDoor(client);
	if( door == 0 ) {
		ITEM_CANCEL(client, item_id);
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_YouMustAim", client, "prop_door_rotating");
		return Plugin_Handled;
	}
	
	int appartID = zoneToAppartID(rp_GetPlayerZone(door));
	if( appartID > 0 ) {
		int newPickTime = (appartID == 50 || appartID == 51) ? 60 * 18 : 60 * 12;
		int appartPickThreshold = (appartID == 50 || appartID == 51) ? 12 : 3;

		if(g_flAppartProtection[appartID] > GetGameTime()) {
			ITEM_CANCEL(client, item_id);
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Mafia_Protect", client, (g_flAppartProtection[appartID] - GetGameTime()) / 60.0);
			return Plugin_Handled;
		}

		if (g_flAppartNewPickLock[appartID] > GetGameTime()) {
			ITEM_CANCEL(client, item_id);
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Mafia_Protect", client, (g_flAppartNewPickLock[appartID] - GetGameTime()) / 60.0);
			return Plugin_Handled;
		}
		
		g_iAppartPickLockCount[appartID]++;

		// never be sure ^^ 
		if(g_iAppartPickLockCount[appartID] > appartPickThreshold || g_iAppartPickLockCount[appartID] <= 0) {
			return Plugin_Handled;
		}

		if(g_iAppartPickLockCount[appartID] == appartPickThreshold) {
			g_flAppartNewPickLock[appartID] = GetGameTime() + float(newPickTime);
			g_iAppartPickLockCount[appartID] = 0;
		}
	}
	
	// Anti-cheat:
	if( rp_GetClientItem(client, item_id) >= GetMaxKit(client, item_id)-1 ) {
		rp_ClientGiveItem(client, item_id, -rp_GetClientItem(client, item_id) + GetMaxKit(client, item_id) - 1);
	}
	
	ServerCommand("sm_effect_particles %d weapon_sensorgren_detonate 1 facemask", client);
	ServerCommand("sm_effect_particles %d Trail2 2 legacy_weapon_bone", client);
	
	rp_SetClientStat(client, i_JobFails, rp_GetClientStat(client, i_JobFails) + 1);
	rp_SetClientInt(client, i_LastVolTime, GetTime());
	rp_SetClientInt(client, i_LastVolAmount, 100);
	rp_SetClientInt(client, i_LastVolTarget, -1);
	
	rp_ClientReveal(client);
	runAlarm(client, door);	
	
	Handle dp;
	CreateDataTimer(0.1, ItemPickLockOver_frame, dp, TIMER_DATA_HNDL_CLOSE|TIMER_REPEAT); 
	WritePackCell(dp, client);
	WritePackCell(dp, door);
	WritePackCell(dp, rp_GetDoorID(door));
	WritePackCell(dp, (fast?0.75:0.0));
	
	return Plugin_Handled;
}
public Action ItemPickLockOver_frame(Handle timer, Handle dp) {
	ResetPack(dp);
	int client 	 = ReadPackCell(dp);
	int door = ReadPackCell(dp);
	int doorID = ReadPackCell(dp);
	float percent = ReadPackCell(dp);
	int target = getDoor(client);
	
	if( !IsValidClient(client ) ) {
		return Plugin_Stop;
	}
	if( target <= 0 || rp_GetDoorID(target) != doorID ) {
		MENU_ShowPickLock(client, percent, -1, 1);
		rp_ClientColorize(client);
		return Plugin_Stop;
	}
	
	int difficulte = 1;
	int tzone = rp_GetPlayerZone(door);
	int appartID = zoneToAppartID(tzone);
	
	if( rp_IsInPVP(client) || rp_GetZoneInt(tzone, zone_type_type) == 101 )
		difficulte += 1;
	if( rp_GetZoneBit( tzone ) & BITZONE_HAUTESECU || rp_GetZoneInt(tzone, zone_type_type) == 101 )
		difficulte += 1;
	
	if( g_iDoorDefine_LOCKER[doorID] && rp_GetZoneInt(tzone, zone_type_type) == 1 )
		difficulte += 1;
	if( g_iDoorDefine_LOCKER[doorID] && rp_GetZoneInt(tzone, zone_type_type) != 1 )
		difficulte += 2;
	
	if( appartID > 0 && appartID < 50 )
		difficulte += 2;
	
	for (int i = 1; i <= MaxClients; i++) {
		if( !IsValidClient(i) )
			continue;
		
		if( rp_GetClientKeyDoor(i, doorID) )
			rp_ClientAggroIncrement(client, i, 1000);
	}
	
	if( percent >= 1.0 ) {
		
		Call_StartForward(rp_GetForwardHandle(client, RP_PostPickLock));
		Call_PushCell(client);
		Call_PushCell(door);
		Call_PushCell(difficulte);
		Call_PushCell(g_iDoorDefine_LOCKER[doorID]);
		Call_Finish();
		
		if( IsValidClient(g_iDoorDefine_LOCKER[doorID]) ) {
			char zone[128];
 			rp_GetZoneData(rp_GetPlayerZone(door), zone_type_name, zone, sizeof(zone));
 			
			CPrintToChat(g_iDoorDefine_LOCKER[doorID], "" ...MOD_TAG... " %T", "Lockpad_Open", client, zone);
			
			int max = 10;
			
			if( rp_GetZoneInt(tzone, zone_type_type) == 1 )
				max = 4;
			
			if( Math_GetRandomInt(1, max) == max ) {
				char tmp[128];
				rp_GetZoneData(tzone, zone_type_name, tmp, sizeof(tmp));
			
				CPrintToChat(g_iDoorDefine_LOCKER[doorID], "" ...MOD_TAG... " %T", "Lockpad_BrokenYours", g_iDoorDefine_LOCKER[doorID], tmp);
				CPrintToChat(client, "" ...MOD_TAG... " %T", "Lockpad_Broken", client);
				g_iDoorDefine_LOCKER[doorID] = 0;
			}
		}
		
		rp_ClientColorize(client);
		
		rp_SetClientStat(client, i_JobSucess, rp_GetClientStat(client, i_JobSucess) + 1);
		rp_SetClientStat(client, i_JobFails, rp_GetClientStat(client, i_JobFails) - 1);
		rp_SetClientFloat(client, fl_LastCrochettage, GetGameTime());
		
		if( g_iLastDoor[client][2] != doorID && g_iLastDoor[client][1] != doorID && g_iLastDoor[client][0] != doorID
			&& rp_GetPlayerZone(target) != 91 && rp_GetPlayerZone(client) != 91
			&& !rp_GetClientKeyDoor(client, doorID) && GetEntProp(target, Prop_Data, "m_bLocked") ) {
			
			g_iLastDoor[client][2] = g_iLastDoor[client][1];
			g_iLastDoor[client][1] = g_iLastDoor[client][0];
			g_iLastDoor[client][0] = doorID;
			
			int rnd = rp_GetRandomCapital(91);
			rp_SetJobCapital(rnd, rp_GetJobCapital(rnd) - (100*difficulte));
			rp_SetJobCapital(91, rp_GetJobCapital(91) + (100*difficulte));
		}
		
		rp_SetDoorLock(doorID, false); 
		rp_ClientOpenDoor(client, doorID, true);
		
		return Plugin_Stop;
	}
	
	rp_SetClientFloat(client, fl_CoolDown, GetGameTime() + 0.15);
	float ratio = getKitDuration(client) / 5000.0;
	
	if( Math_GetRandomInt(1, 10) == 8 )
		ServerCommand("sm_effect_particles %d Trail2 2 legacy_weapon_bone", client);
	
	ratio = ratio / float(difficulte);
	ResetPack(dp);
	WritePackCell(dp, client);
	WritePackCell(dp, door);
	WritePackCell(dp, doorID);
	WritePackCell(dp, percent + ratio);
	MENU_ShowPickLock(client, percent, difficulte, 1);
	return Plugin_Continue;
}
// ----------------------------------------------------------------------------
public Action timerAlarm(Handle timer, any door) {
	
	EmitSoundToAllAny("UI/arm_bomb.wav", door, _, _, _, 0.5);
	return Plugin_Handled;
}
public Action AllowStealing(Handle timer, any client) {
	
	rp_SetClientBool(client, b_MaySteal, true);
	CPrintToChat(client, "" ...MOD_TAG... " %T", "Cmd_NowSteal", client);
}
public Action AllowStealingCB(Handle timer, any client) {
	g_bCanUseCB[client] = true;
	CPrintToChat(client, "" ...MOD_TAG... " %T", "Cmd_NowSteal", client);
}
int GetMaxKit(int client, int itemID) {
	int max, job = rp_GetClientInt(client, i_Job);
	
	switch( job ) {
		case 91:	max = 7;
		case 92:	max = 6;
		case 93:	max = 5; // parrain
		case 94:	max = 5; // pro
		case 95:	max = 4; // mafieux
		case 96:	max = 3; // apprenti
		default:	max = 0;
	}
	
	if( itemID == ITEM_PIEDBICHE || itemID == ITEM_MAGNETCB)
		max = 1;
	if( itemID == ITEM_KITEXPLOSIF )
		max = RoundToCeil(max / 3.0);
	
	return max;
}
int getDoor(int client) {
	if( !IsPlayerAlive(client) )
		return 0;
	int door = rp_GetClientTarget(client);
	if( !rp_IsValidDoor(door) && IsValidEdict(door) && rp_IsValidDoor(Entity_GetParent(door)) )
		door = Entity_GetParent(door);
	
	if( !rp_IsValidDoor(door) || !rp_IsEntitiesNear(client, door, true) )
		door = 0;
	return door;
}
int getDistrib(int client, int& type) {
	if( !IsPlayerAlive(client) )
		return 0;
	int target = rp_GetClientTarget(client);
	
	if( target <= MaxClients )
		return 0;
	if( !rp_IsEntitiesNear(client, target, true) )
		return 0;
	
	char classname[128];
	GetEdictClassname(target, classname, sizeof(classname));
	
	int owner = rp_GetBuildingData(target, BD_owner);
	
	if( StrEqual(classname, "rp_bank") && owner == 0 && !rp_GetBuildingData(target, BD_Trapped) )
		type = 2;
	else if( StrEqual(classname, "rp_weaponbox") )
		type = 3;
	else if( (StrEqual(classname, "rp_cashmachine") ) && rp_GetClientJobID(owner) != 91 &&
		!rp_IsClientSafe(owner) && (float(Entity_GetHealth(target))/float(Entity_GetMaxHealth(target)) > 0.75) && rp_GetBuildingData(target, BD_HackedTime)+6*60 < GetTime() )
		type = 4;
	else if( (StrEqual(classname, "rp_bigcashmachine") ) && rp_GetClientJobID(owner) != 91 &&
		!rp_IsClientSafe(owner) && (float(Entity_GetHealth(target))/float(Entity_GetMaxHealth(target)) > 0.75) && rp_GetBuildingData(target, BD_HackedTime)+6*60 < GetTime() )
		type = 5;
	else if( StrEqual(classname, "rp_phone") )
		type = 6;
	else if( (StrEqual(classname, "rp_plant") ) && rp_GetClientJobID(owner) != 91 && (float(Entity_GetHealth(target))/float(Entity_GetMaxHealth(target)) > 0.75) && 
		!rp_IsClientSafe(owner) && rp_GetBuildingData(target, BD_count) > 0 )
		type = 7;
	else if( StrEqual(classname, "rp_bank") && owner > 0 && IsValidClient(owner) && !rp_IsClientSafe(owner) )
		type = 8;
		
	return (type > 0 ? target : 0);
}
void runAlarm(int client, int door) {
	int doorID = rp_GetDoorID(door);
	int alarm = g_iDoorDefine_LOCKER[doorID];
	if( alarm ) {
		
		if( IsValidClient(alarm) ) {
			char zone[128];
			rp_GetZoneData(rp_GetPlayerZone(door), zone_type_name, zone, sizeof(zone));
			
			CPrintToChat(alarm, "" ...MOD_TAG... " %T", "Lockpad_Open", client, zone);
			rp_Effect_BeamBox(alarm, client);
		}
		
		EmitSoundToAllAny("UI/arm_bomb.wav", door);
		CreateTimer(10.0, timerAlarm, door); 
	}
}
int getKitDuration(int client) {
	int job = rp_GetClientInt(client, i_Job);
	int ratio = 0;
	switch( job ) {
		case 91: ratio = 75;	// Chef
		case 92: ratio = 80;	// Co-chef
		case 93: ratio = 85; 	// Parrain
		case 94: ratio = 90;	// Pro
		case 95: ratio = 95;	// Mafieu
		case 96: ratio = 100;	// Apprenti
	}
	return ratio;
}
// ----------------------------------------------------------------------------
void MENU_ShowPickLock(int client, float percent, int difficulte, int type) {

	Handle menu = CreateMenu(eventMenuNone);
	switch( type ) {
		case 1: SetMenuTitle(menu, "%T", "Mafia_Crowbar_Door", client);
		case 2: SetMenuTitle(menu, "%T", "Mafia_Crowbar_Distrib", client);
		case 3: SetMenuTitle(menu, "%T", "Mafia_Crowbar_Armurerie", client);
		case 4: SetMenuTitle(menu, "%T", "Mafia_Crowbar_Imprimante", client);
		case 5: SetMenuTitle(menu, "%T", "Mafia_Crowbar_Photocop", client);
		case 6: SetMenuTitle(menu, "%T", "Mafia_Crowbar_Phone", client);
		case 7: SetMenuTitle(menu, "%T", "Mafia_Crowbar_Plant", client);
		case 8: SetMenuTitle(menu, "%T", "Mafia_Crowbar_Hack", client);
	}
	
	char tmp[64];
	rp_Effect_LoadingBar(tmp, sizeof(tmp), percent );
	AddMenuItem(menu, tmp, tmp, ITEMDRAW_DISABLED);
	
	switch( difficulte ) {
		case  -1: Format(tmp, sizeof(tmp), "%T", "Difficulty_Failed", client);
		case   1: Format(tmp, sizeof(tmp), "%T", "Difficulty_Easy", client);
		case   3: Format(tmp, sizeof(tmp), "%T", "Difficulty_Hard", client);
		case   4: Format(tmp, sizeof(tmp), "%T", "Difficulty_VeryHard", client);
		case   5: Format(tmp, sizeof(tmp), "%T", "Difficulty_Impossible", client);
		
		default: Format(tmp, sizeof(tmp), "%T", "Difficulty_Average", client);
	}
	
	Format(tmp, sizeof(tmp), "%T", "Steal_Nearby", client, rp_CountPoliceNear(client));
	AddMenuItem(menu, ".", tmp, ITEMDRAW_DISABLED);
	
	SetMenuExitBackButton(menu, false);
	DisplayMenu(menu, client, 1);
}
public int eventMenuNone(Handle menu, MenuAction action, int client, int param2) {	
	if( action == MenuAction_End ) {
		CloseHandle(menu);
	}
}
void missionTelephone(int client) {
	float vecDir[3];
	vecDir[0] = Math_GetRandomFloat(-3250.0, 2000.0);
	vecDir[1] = Math_GetRandomFloat(-5000.0, 900.0);
	
	float tmp[3];
	GetClientAbsOrigin(client, tmp);
	TE_SetupBeamPoints(vecDir, tmp, g_cBeam, 0, 0, 0, 17.5, 1.0, 10.0, 0, 0.0, {255, 255, 255, 100}, 20);
	TE_SendToClient(client);
	
	TE_SetupBeamRingPoint(vecDir, 50.0, 250.0, g_cBeam, 0, 0, 30, 17.5, 20.0, 0.0, { 255, 255, 255, 100 }, 10, 0);
	TE_SendToClient(client);
	
	vecDir[2] -= 2000.0;
	
	Handle dp;
	CreateDataTimer(7.5, Copter_Post, dp);
	WritePackFloat(dp, vecDir[0]);
	WritePackFloat(dp, vecDir[1]);
	
	Handle menu = CreateMenu(eventMenuNone);
	SetMenuTitle(menu, "%T\n ", "Phone_Mission", client);
	
	char msg[256];
	rp_GetZoneData(rp_GetZoneFromPoint(vecDir), zone_type_name, msg, sizeof(msg));
	Format(msg, sizeof(msg), "%T", "Phone_Mission_Copter", client, msg);
	AddMenuItem(menu, "_", msg, ITEMDRAW_DISABLED);
	
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, 30);	
}
public Action Copter_Post(Handle timer, Handle dp ) {
	float vecDest[2];
	
	ResetPack(dp);
	vecDest[0] = ReadPackFloat(dp);
	vecDest[1] = ReadPackFloat(dp);
	
	ServerCommand("sm_effect_copter %f %f", vecDest[0], vecDest[1]);
	
	return Plugin_Stop;
}

bool disapear(int client) {
	char model[128];
	GetConVarString(g_vCapture, model, sizeof(model));
	if( StrEqual(model, "active") ) {
		return false;
	}
	Entity_GetModel(client, model, sizeof(model));
	if( StrContains(model, "sprisioner", false) != -1 )
		return false;

	int zoneJob = rp_GetZoneInt(rp_GetPlayerZone(client), zone_type_type);
	
	int rndClient[65], rndCount;
	if( zoneJob == 1 ) {
		for (int i = 1; i <= MaxClients; i++) {
			if( IsValidClient(i) && GetClientTeam(i) == CS_TEAM_CT ) {
				rndClient[rndCount++] = i;
			}
		}
	}
	else {
		for (int i = 1; i <= MaxClients; i++) {
			if( IsValidClient(i) && GetClientTeam(i) != CS_TEAM_CT && !IsFakeClient(i) && rp_GetClientJobID(i) != 91 && i != client ) {
				Entity_GetModel(i, model, sizeof(model));
				if( StrContains(model, "sprisioner", false) == -1 )
					rndClient[rndCount++] = i;
			}
		}
	}
	if( rndCount == 0 )
		return false;
	int rnd = Math_GetRandomInt(0, rndCount - 1);
	
	Entity_GetModel(rndClient[rnd], model, sizeof(model));
	Entity_SetModel(client, model);
	rp_SetClientInt(client, i_FakeClient, rndClient[rnd]);
	
	rp_HookEvent(client, RP_OnPlayerZoneChange, fwdZoneChange);
	rp_HookEvent(client, RP_OnPlayerDead, fwdDead);
	CreateTimer(zoneJob == 1 ? 20.0 : 10.0, appear, client);
	
	float vecCenter[3];
	Entity_GetAbsOrigin(client, vecCenter);
	TE_SetupBeamRingPoint(vecCenter, 1.0, 200.0, g_cBeam, g_cBeam, 0, 10, 0.25, 80.0, 0.0, {100, 100, 255, 10}, 1, 0);
	TE_SendToAll();
	
	char target_name[128];
	GetClientName2(rndClient[rnd], target_name, sizeof(target_name), false);
	CPrintToChat(client, "" ...MOD_TAG... " %T", "Mafia_Deguise_Target", client, target_name);
	LogToGame("[BUILD] [MAFIA] %L est maintenant invisible", client);
	return true;
}
public Action appear(Handle timer, any client) {
	if( rp_GetClientInt(client, i_FakeClient) != 0 ) {
		
		rp_SetClientInt(client, i_FakeClient, 0);
		rp_UnhookEvent(client, RP_OnPlayerZoneChange, fwdZoneChange);
		rp_UnhookEvent(client, RP_OnPlayerDead, fwdDead);
		
		rp_ClientReveal(client);
		rp_ClientResetSkin(client);
		float vecCenter[3];
		Entity_GetAbsOrigin(client, vecCenter);
		TE_SetupBeamRingPoint(vecCenter, 1.0, 200.0, g_cBeam, g_cBeam, 0, 10, 0.25, 80.0, 0.0, {100, 100, 255, 10}, 1, 0);
		TE_SendToAll();
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Mafia_Deguise_Ended", client);
		
		LogToGame("[BUILD] [MAFIA] %L est maintenant visible", client);
	}
}
public Action fwdZoneChange(int client, int newZone, int oldZone) {
	if( rp_GetZoneInt(newZone, zone_type_type) != rp_GetZoneInt(oldZone, zone_type_type) ) {
		CreateTimer(0.1, appear, client);
	}
}
public Action fwdDead(int client, int attacker, float& respawn, int& tdm, float& ctx) {
	CreateTimer(0.1, appear, client);
	return Plugin_Continue;
}

void deleteBuyMenu(DataPackPos pos) {
	g_hBuyMenu_Items.Reset();
	DataPackPos max = g_hBuyMenu_Items.ReadCell();
	DataPackPos position = g_hBuyMenu_Items.Position;
	
	DataPack clone = new DataPack();
	clone.WriteCell(0);
	
	int[] data = new int[IM_Max];
	 
	while( position < max ) {
		
		for (int i = 0; i < view_as<int>(IM_Max); i++) {
			data[i] = g_hBuyMenu_Items.ReadCell();
		}
		
		if( position != pos) {
			for (int i = 0; i < view_as<int>(IM_Max); i++) {
				 clone.WriteCell(data[i]);
			}
		}
		
		position = g_hBuyMenu_Items.Position;
	}
	position = clone.Position;
	clone.Reset();
	clone.WriteCell(position);
	delete g_hBuyMenu_Items;
	g_hBuyMenu_Items = clone;
}
void getBuyMenu(DataPackPos pos, int[] data) {
	g_hBuyMenu_Items.Position = pos;
	
	for (int i = 0; i < view_as<int>(IM_Max); i++) {
		data[i] = g_hBuyMenu_Items.ReadCell();
	}
}
void addBuyMenu(int client, int target, int itemID) {
	
	int[] data = new int[IM_Max];
	
	data[IM_Owner] = client;
	data[IM_StealFrom] = target;
	data[IM_ItemID] = itemID;
	data[IM_Prix] = (rp_GetItemInt(itemID, item_type_prix) * MARCHEMAFIA_PC) / 100;
	
	g_hBuyMenu_Items.Reset();
	DataPackPos pos = g_hBuyMenu_Items.ReadCell();
	g_hBuyMenu_Items.Position = pos;
	for (int i = 0; i < view_as<int>(IM_Max); i++) {
		g_hBuyMenu_Items.WriteCell(data[i]);
	}
	pos = g_hBuyMenu_Items.Position;
	g_hBuyMenu_Items.Reset();
	g_hBuyMenu_Items.WriteCell(pos);
}
void Cmd_Buy(int client, bool free) {
	
	char tmp1[128], tmp2[128];
	Menu menu = new Menu(Menu_BuyMarket);
	menu.SetTitle("%T\n ", "Mafia_BlackMarket", client);
	
	g_hBuyMenu_Items.Reset();
	int itemCount = (view_as<int>(g_hBuyMenu_Items.ReadCell()) - 1) / view_as<int>(IM_Max);
	int weaponCount = (view_as<int>(rp_WeaponMenu_GetMax(g_hBuyMenu_Weapons)) - 1) / view_as<int>(BM_Max);
	
	Format(tmp1, sizeof(tmp1), "item %d", free);
	Format(tmp2, sizeof(tmp2), "%T", "Mafia_BlackMarket_Item", client, itemCount);
	menu.AddItem(tmp1, tmp2);

	Format(tmp1, sizeof(tmp1), "weapon %d", free);
	Format(tmp2, sizeof(tmp2), "%T", "Mafia_BlackMarket_Weapon", client, weaponCount);
	menu.AddItem(tmp1, tmp2);
	
	menu.Display(client, 60);
	return;
}

public int Menu_BuyMarket(Handle p_hMenu, MenuAction p_oAction, int client, int p_iParam2) {
	if (p_oAction == MenuAction_Select) {
		
		char szMenu[64], buffer[2][32];
		if (GetMenuItem(p_hMenu, p_iParam2, szMenu, sizeof(szMenu))) {
			ExplodeString(szMenu, " ", buffer, sizeof(buffer), sizeof(buffer[]));
			
			if( StrEqual(buffer[0], "item") ) {
				Cmd_BuyItem(client, StrEqual(buffer[1], "1"));
			}
			if( StrEqual(buffer[0], "weapon") ) {
				Cmd_BuyWeapon(client, StrEqual(buffer[1], "1"));
			}
			
		}
	}
	else if (p_oAction == MenuAction_End) {
		CloseHandle(p_hMenu);
	}
	return 0;
}

void Cmd_BuyItem(int client, bool free) {
	g_hBuyMenu_Items.Reset();
	DataPackPos max = g_hBuyMenu_Items.ReadCell();
	DataPackPos position = g_hBuyMenu_Items.Position;
	char tmp[8], tmp2[129];
	int[] data = new int[IM_Max];
	
	if( position >= max ) {
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_NoItemToSellForNow", client);
		return;
	}
	
	Menu menu = new Menu(Menu_BuyBlackMarket);
	menu.SetTitle("%T\n ", "Mafia_BlackMarket", client);
	
	while( position < max ) {
		
		getBuyMenu(position, data);
		
		if( data[IM_Owner] == client )
			data[IM_Prix] /= 10;
		
		rp_GetItemData(data[IM_ItemID], item_type_name, tmp2, sizeof(tmp2));
		Format(tmp, sizeof(tmp), "%d %d", position, free);
		Format(tmp2, sizeof(tmp2), "%s - %d$", tmp2, free?0:data[IM_Prix]);
		menu.AddItem(tmp, tmp2);
		
		position = g_hBuyMenu_Items.Position;
	}

	menu.Display(client, 60);
	return;
}
public int Menu_BuyBlackMarket(Handle p_hMenu, MenuAction p_oAction, int client, int p_iParam2) {
	if (p_oAction == MenuAction_Select) {
		
		char szMenu[64], tmp[64], buffer[2][32];
		if( GetMenuItem(p_hMenu, p_iParam2, szMenu, sizeof(szMenu)) ) {
			
			ExplodeString(szMenu, " ", buffer, sizeof(buffer), sizeof(buffer[]));
			int[] data = new int[IM_Max];
			DataPackPos position = view_as<DataPackPos>(StringToInt(buffer[0]));
			getBuyMenu(position, data);
			
			if( data[IM_ItemID] == 0 )
				return 0;
			
			if( data[IM_Owner] == client ) {
				data[IM_Prix] /= 10;
				if( data[IM_Prix] == 0 )
					data[IM_Prix] = 1;
			}
			
			if( StringToInt(buffer[1]) == 1 ) {
				rp_SetClientInt(client, i_LastVolAmount, 100+data[BM_Prix]); 
				data[IM_Prix] = 0;
			}
			if( rp_GetClientInt(client, i_Bank) < data[IM_Prix] )
				return 0;
			
			float vecOrigin[3];
			GetClientAbsOrigin(client, vecOrigin);
			
			if( GetVectorDistance(vecOrigin, MARCHEMAFIA_POS) > 150.0 )
				return 0;
			
			
			deleteBuyMenu(position);
			rp_ClientMoney(client, i_Money, -data[IM_Prix]);
			rp_SetClientStat(client, i_MoneySpent_Shop, rp_GetClientStat(client, i_MoneySpent_Shop) + data[IM_Prix]);
			
			rp_ClientGiveItem(client, data[IM_ItemID]);
			rp_GetItemData(data[IM_ItemID], item_type_name, tmp, sizeof(tmp));
			
			Call_StartForward(rp_GetForwardHandle(client, RP_OnBlackMarket));
			Call_PushCell(client);
			Call_PushCell(91);
			Call_PushCell(data[IM_Owner]);
			Call_PushCell(data[IM_StealFrom]);
			Call_PushCellRef(data[IM_Prix]);
			Call_PushCell(rp_GetItemInt(data[IM_ItemID], item_type_prix) / 2);
			Call_Finish();
			
			if( IsValidClient(data[IM_Owner]) && rp_GetClientJobID(data[IM_Owner]) == 91 )
				LogToGame("[TSX-RP] [ITEM-VENDRE] %L a vendu 1 %s a %L", data[IM_Owner], tmp, client);
			
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Market_Buy", client, 1, tmp, data[IM_Prix]);
			
			if( data[IM_Owner] == client ) {
				rp_SetJobCapital(91, rp_GetJobCapital(91) + RoundToCeil(float(data[IM_Prix]*10) * 0.5));
			}
			else if( IsValidClient(data[IM_Owner]) && rp_GetClientJobID(data[IM_Owner]) == 91 && data[IM_Prix] > 0 ) {
				rp_SetJobCapital(91, rp_GetJobCapital(91) + RoundToCeil(float(data[IM_Prix]) * 0.5));
				rp_ClientMoney(data[IM_Owner], i_AddToPay, RoundToFloor(float(data[IM_Prix]) * 0.5));

				rp_SetClientStat(data[IM_Owner], i_MoneyEarned_Sales, rp_GetClientStat(data[IM_Owner], i_MoneyEarned_Sales) + RoundToFloor(float(data[IM_Prix]) * 0.5));

				CPrintToChat(data[IM_Owner], "" ...MOD_TAG... " %T", "Market_Sell", data[IM_Owner], 1, tmp, data[IM_Prix]);
			}
			else {
				rp_SetJobCapital(91, rp_GetJobCapital(91) + data[IM_Prix]);
				
				if( IsValidClient(data[IM_Owner]) && rp_GetClientJobID(data[IM_Owner]) == 91 )
					CPrintToChat(data[IM_Owner], "" ...MOD_TAG... " %T", "Steal_Item_By", data[IM_Owner], tmp);
			}
			
			
			
			for (int i = 1; i <= MaxClients; i++) {
				if( rp_GetClientJobID(i) == 91 )
					rp_ClientFloodIncrement(i, client, fd_vol, 2.0 * STEAL_TIME);
			}
		}
	}
	else if (p_oAction == MenuAction_End) {
		CloseHandle(p_hMenu);
	}
	return 0;
}


void Cmd_BuyWeapon(int client, bool free) {
	DataPackPos max = rp_WeaponMenu_GetMax(g_hBuyMenu_Weapons);
	DataPackPos position = rp_WeaponMenu_GetPosition(g_hBuyMenu_Weapons);
	char name[BM_WeaponNameSize], tmp[8], tmp2[129];
	int[] data = new int[BM_Max];
	
	if (position >= max) {
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_NoItemToSellForNow", client);
		return;
	}
	
	Menu menu = new Menu(Menu_BuyWeapon);
	Format(tmp2, sizeof(tmp2), "%T\n ", "Mafia_BlackMarket", client);
	menu.SetTitle(tmp2);
	
	while (position < max) {
		
		rp_WeaponMenu_Get(g_hBuyMenu_Weapons, position, name, data);
		Format(tmp, sizeof(tmp), "%d %d", position, free);
		
		if (data[BM_PvP] > 0)
			Format(tmp2, sizeof(tmp2), "[PvP] ");
		else
			Format(tmp2, sizeof(tmp2), "");
		
		if (data[BM_Munition] == -1)
			Format(tmp2, sizeof(tmp2), "%s %s (1) ", tmp2, name);
		else
			Format(tmp2, sizeof(tmp2), "%s %s (%d/%d) ", tmp2, name, data[BM_Munition], data[BM_Chargeur]);
		
		switch (view_as<enum_ball_type>(data[BM_Type])) {
			case ball_type_fire: 			Format(tmp2, sizeof(tmp2), "%T", "wpn_ball_type_fire", client, tmp2);
			case ball_type_caoutchouc:		Format(tmp2, sizeof(tmp2), "%T", "wpn_ball_type_caoutchouc", client, tmp2);
			case ball_type_poison:			Format(tmp2, sizeof(tmp2), "%T", "wpn_ball_type_poison", client, tmp2);
			case ball_type_vampire:			Format(tmp2, sizeof(tmp2), "%T", "wpn_ball_type_vampire", client, tmp2);
			case ball_type_paintball:		Format(tmp2, sizeof(tmp2), "%T", "wpn_ball_type_paintball", client, tmp2);
			case ball_type_reflexive:		Format(tmp2, sizeof(tmp2), "%T", "wpn_ball_type_reflexive", client, tmp2);
			case ball_type_explode:			Format(tmp2, sizeof(tmp2), "%T", "wpn_ball_type_explode", client, tmp2);
			case ball_type_revitalisante:	Format(tmp2, sizeof(tmp2), "%T", "wpn_ball_type_revitalisante", client, tmp2);
			case ball_type_nosteal:			Format(tmp2, sizeof(tmp2), "%T", "wpn_ball_type_nosteal", client, tmp2);
			case ball_type_notk:			Format(tmp2, sizeof(tmp2), "%T", "wpn_ball_type_notk", client, tmp2);
			case ball_type_braquage:		Format(tmp2, sizeof(tmp2), "%T", "wpn_ball_type_braquage", client, tmp2);
		}
		
		
		if( IsValidClient(data[BM_Owner]) && rp_GetClientJobID(data[BM_Owner]) == 91 && data[BM_Owner] == client ) {
			Format(tmp2, sizeof(tmp2), "[ %s - %d$ ]", tmp2, (free ? 0:data[BM_Prix]));
		}
		else {
			Format(tmp2, sizeof(tmp2), "%s - %d$", tmp2, (free ? 0:data[BM_Prix]));
		}
		menu.AddItem(tmp, tmp2);
		
		position = rp_WeaponMenu_GetPosition(g_hBuyMenu_Weapons);
	}
	
	menu.Display(client, 60);
	return;
}
public int Menu_BuyWeapon(Handle p_hMenu, MenuAction p_oAction, int client, int p_iParam2) {
	if (p_oAction == MenuAction_Select) {
		
		char szMenu[64], buffer[2][32];
		if (GetMenuItem(p_hMenu, p_iParam2, szMenu, sizeof(szMenu))) {
			ExplodeString(szMenu, " ", buffer, sizeof(buffer), sizeof(buffer[]));
			
			char name[BM_WeaponNameSize];
			int[] data = new int[BM_Max];
			DataPackPos position = view_as<DataPackPos>(StringToInt(buffer[0]));
			rp_WeaponMenu_Get(g_hBuyMenu_Weapons, position, name, data);
			
			float vecOrigin[3];
			GetClientAbsOrigin(client, vecOrigin);
			
			if (GetVectorDistance(vecOrigin, MARCHEMAFIA_POS) > 150.0)
				return 0;
			if (StringToInt(buffer[1]) == 1) {
				rp_SetClientInt(client, i_LastVolAmount, 100 + data[BM_Prix]);
				data[BM_Prix] = 0;
			}
			
			
			if (rp_GetClientInt(client, i_Bank)+rp_GetClientInt(client, i_Money) < data[BM_Prix])
				return 0;
			Format(name, sizeof(name), "weapon_%s", name);
			
			if( Weapon_ShouldBeEquip(name) && Client_HasWeapon(client, name) )
				return 0;
				
			int wepid = GivePlayerItem(client, name);
			if( Weapon_ShouldBeEquip(name) )
				EquipPlayerWeapon(client, wepid);
			
			rp_SetWeaponBallType(wepid, view_as<enum_ball_type>(data[BM_Type]));
			if (data[BM_PvP] > 0)
				rp_SetWeaponGroupID(wepid, rp_GetClientGroupID(client));
			
			if (data[BM_Munition] != -1) {
				SetEntProp(wepid, Prop_Send, "m_iClip1", data[BM_Munition]);
				SetEntProp(wepid, Prop_Send, "m_iPrimaryReserveAmmoCount", data[BM_Chargeur]);
			}
			rp_SetWeaponStorage(wepid, data[BM_Store] == 1);
			rp_WeaponMenu_Delete(g_hBuyMenu_Weapons, position);
			
			
			rp_ClientMoney(client, i_Money, -data[BM_Prix]);
			
			if( IsValidClient(data[BM_Owner]) && rp_GetClientJobID(data[BM_Owner]) == 91 ) {
				float taxe = data[BM_Owner] == client ? getTaxe(client) : 0.5;
				
				int payClient = RoundToCeil(float(data[BM_Prix]) * (1.0 - taxe));
				int payCapital = RoundToCeil(float(data[BM_Prix]) * (taxe));
				
				rp_ClientMoney(data[BM_Owner], i_AddToPay, payClient);
				rp_SetJobCapital(91, rp_GetJobCapital(91) + payCapital);
			}
			else {
				rp_SetJobCapital(91, rp_GetJobCapital(91) + data[BM_Prix]);
			}
			
			LogToGame("[TSX-RP] [ITEM-VENDRE] %L a vendu 1 %s a %L", client, name, client);
			
			Call_StartForward(rp_GetForwardHandle(client, RP_OnBlackMarket));
			Call_PushCell(client);
			Call_PushCell(91);
			Call_PushCell(client);
			Call_PushCell(client);
			Call_PushCellRef(data[BM_Prix]);
			Call_PushCell(rp_GetClientInt(client, i_LastVolAmount) - 100);
			Call_Finish();
		}
	}
	else if (p_oAction == MenuAction_End) {
		CloseHandle(p_hMenu);
	}
	return 0;
}

int zoneToAppartID(int zoneID) {
	char tmp[64];
	rp_GetZoneData(zoneID, zone_type_type, tmp, sizeof(tmp));
	
	int res = 0;
	
	if( StrContains(tmp, "appart_", false) == 0 ) {
		ReplaceString(tmp, sizeof(tmp), "appart_", "");
		res = StringToInt(tmp);
	}
	
	return res;
}

float getTaxe(int client) {
	int job = rp_GetClientInt(client, i_Job);
	float val = 0.5;
	switch(job) {
		case 91: val = 0.10;
		case 92: val = 0.15;
		case 93: val = 0.20;
		case 94: val = 0.25;
		case 95: val = 0.30;
		case 96: val = 0.35;
		case 97: val = 0.40;
		case 98: val = 0.45;
	}
	return val;
}