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
#include <csgo_items>   // https://forums.alliedmods.net/showthread.php?t=243009
#include <advanced_motd>// https://forums.alliedmods.net/showthread.php?t=232476

#pragma newdecls required
#include <roleplay.inc>	// https://www.ts-x.eu

public Plugin myinfo =  {
	name = "Jobs: Police", author = "KoSSoLaX", 
	description = "RolePlay - Jobs: Police", 
	version = __LAST_REV__, url = "https://www.ts-x.eu"
};

enum jail_raison_type {
	jail_raison = 0, 
	jail_temps, 
	jail_temps_nopay, 
	jail_amende, 
	jail_simple, 
	
	jail_type_max
};
char g_szJailRaison[][][128] =  {
	{ "Garde à vue", "12", "12", "0", "0" }, 
	{ "Meurtre", "-1", "-1", "-1", "1" }, 
	{ "Agression physique", "1", "6", "250", "1" }, 
	{ "Intrusion propriété privée", "0", "3", "100", "0" }, 
	{ "Vol, tentative de vol", "0", "3", "50", "1" }, 
	{ "Fuite, refus d'obtempérer", "0", "6", "200", "0" }, 
	{ "Insultes, Irrespect", "1", "6", "250", "0" }, 
	{ "Trafic illégal", "0", "6", "100", "0" }, 
	{ "Nuisance sonore", "0", "6", "100", "0" }, 
	{ "Tir dans la rue", "0", "6", "100", "1" }, 
	{ "Conduite dangereuse", "0", "6", "150", "0" }, 
	{ "Mutinerie, évasion", "-2", "-2", "50", "1" }
};
float g_flLastPos[65][3];
DataPack g_hBuyMenu;
char g_szTribunal[65][65];

#define ARMU_POLICE view_as<float>({ 2550.8, 1663.1, -2015.96 })


bool CanSendToJail(int client, int target) {
	Action a;
	Call_StartForward(rp_GetForwardHandle(target, RP_PreClientSendToJail));
	Call_PushCell(client);
	Call_PushCell(target);
	Call_Finish(a);
	if (a == Plugin_Handled || a == Plugin_Stop)
		return false;
	return true;
}
void ClientTazedItem(int client, int reward) {
	Call_StartForward(rp_GetForwardHandle(client, RP_OnClientTazedItem));
	Call_PushCell(client);
	Call_PushCell(reward);
	Call_Finish();
}

// ----------------------------------------------------------------------------
public Action Cmd_Reload(int args) {
	char name[64];
	GetPluginFilename(INVALID_HANDLE, name, sizeof(name));
	ServerCommand("sm plugins reload %s", name);
	return Plugin_Continue;
}
public void OnPluginStart() {
	RegServerCmd("rp_quest_reload", Cmd_Reload);
	
	RegServerCmd("rp_item_ratio", Cmd_ItemRatio, "RP-ITEM", FCVAR_UNREGISTERED);
	RegServerCmd("rp_SendToJail", Cmd_SendToJail, "RP-ITEM", FCVAR_UNREGISTERED);
	RegServerCmd("rp_GetStoreWeapon", Cmd_GetStoreWeapon, "RP-ITEM", FCVAR_UNREGISTERED);
	
	HookEvent("weapon_fire", Event_Weapon_Fire);
	
	for (int i = 1; i <= MaxClients; i++)
	if (IsValidClient(i))
		OnClientPostAdminCheck(i);
}
public void OnAllPluginsLoaded() {
	g_hBuyMenu = rp_WeaponMenu_Create();
}
public void OnPluginEnd() {
	if (g_hBuyMenu)
		rp_WeaponMenu_Clear(g_hBuyMenu);
}
public Action Cmd_GetStoreWeapon(int args) {
	Cmd_BuyWeapon(GetCmdArgInt(1), true);
}
public Action Cmd_SendToJail(int args) {
	SendPlayerToJail(GetCmdArgInt(1), GetCmdArgInt(2));
	
	StripWeapons(GetCmdArgInt(1));
}
public void OnMapStart() {
	PrecacheModel(MODEL_PRISONNIER, true);
	PrecacheModel(MODEL_BARRIERE, true);
}
// ----------------------------------------------------------------------------
public void OnClientPostAdminCheck(int client) {
	rp_HookEvent(client, RP_OnPlayerCommand, fwdCommand);
	rp_HookEvent(client, RP_OnPlayerSpawn, fwdSpawn);
	rp_HookEvent(client, RP_OnPlayerBuild, fwdOnPlayerBuild);
	rp_HookEvent(client, RP_PreGiveDamage, fwdDmg);
	rp_HookEvent(client, RP_OnPlayerZoneChange, fwdOnZoneChange);
	rp_HookEvent(client, RP_OnPlayerUse, fwdOnPlayerUse);
	rp_SetClientBool(client, b_IsSearchByTribunal, false);
	
	CreateTimer(0.01, AllowStealing, client);
}
public Action fwdOnZoneChange(int client, int newZone, int oldZone) {
	
	if (rp_GetClientJobID(client) == 1 || rp_GetClientJobID(client) == 101) {
		int oldBIT = rp_GetZoneBit(oldZone);
		int newBIT = rp_GetZoneBit(newZone);
		
		if (GetClientTeam(client) == CS_TEAM_CT) {
			if ((newBIT & BITZONE_PVP) && !(oldBIT & BITZONE_PVP)) {
				EmitSoundToClientAny(client, "UI/arm_bomb.wav", client);
			}
			if (newBIT & BITZONE_EVENT) {
				SetEntProp(client, Prop_Send, "m_bHasHelmet", 0);
			}
		}
		
	}
}
public Action RP_OnPlayerGotPay(int client, int salary, int & topay, bool verbose) {
	int jobID = rp_GetClientJobID(client);
	
	if ((jobID == 1 || jobID == 101) && rp_GetClientInt(client, i_KillJailDuration) > 0) {
		
		if (verbose)
			CPrintToChat(client, "{lightblue}[TSX-RP]{default} La police ne paye pas ses membres tuant la population.");
		
		topay = 0;
		return Plugin_Stop;
	}
	
	int zone = rp_GetZoneBit(rp_GetPlayerZone(client));
	
	if (zone & (BITZONE_JAIL | BITZONE_LACOURS | BITZONE_HAUTESECU) && rp_GetClientInt(client, i_JailTime) > 0) {
		
		if (verbose)
			CPrintToChat(client, "{lightblue}[TSX-RP]{default} Etant en prison, votre employeur vous verse seulement 10% de votre salaire.");
		
		topay = 0;
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}
public Action fwdSpawn(int client) {
	if (rp_GetClientInt(client, i_JailTime) > 0)
		SendPlayerToJail(client, 0);
	
	if (GetClientTeam(client) == CS_TEAM_CT)
		SetEntProp(client, Prop_Send, "m_bHasHelmet", 1);
	else
		SetEntProp(client, Prop_Send, "m_bHasHelmet", 0);
	
	return Plugin_Continue;
}
public Action fwdCommand(int client, char[] command, char[] arg) {
	if (StrEqual(command, "cop") || StrEqual(command, "cops")) {
		return Cmd_Cop(client);
	}
	else if (StrEqual(command, "vis") || StrEqual(command, "invis")) {
		return Cmd_Vis(client);
	}
	else if (StrEqual(command, "tazer") || StrEqual(command, "tazeur") || StrEqual(command, "taser")) {
		return Cmd_Tazer(client);
	}
	else if (StrEqual(command, "enjail") || StrEqual(command, "injail") || StrEqual(command, "jaillist")) {
		return Cmd_InJail(client);
	}
	else if (StrEqual(command, "jail") || StrEqual(command, "prison")) {
		return Cmd_Jail(client);
	}
	else if (StrEqual(command, "push")) {
		return Cmd_Push(client);
	}
	
	return Plugin_Continue;
}
// ----------------------------------------------------------------------------
public Action Cmd_Cop(int client) {
	int job = rp_GetClientInt(client, i_Job);
	
	if (rp_GetClientJobID(client) != 1 && rp_GetClientJobID(client) != 101) {
		ACCESS_DENIED(client);
	}
	int zone = rp_GetPlayerZone(client);
	int bit = rp_GetZoneBit(zone);
	
	if (bit & (BITZONE_BLOCKJAIL | BITZONE_JAIL | BITZONE_HAUTESECU | BITZONE_LACOURS | BITZONE_PVP)) {  // Flic ripoux
		ACCESS_DENIED(client);
	}
	if (rp_GetClientVehiclePassager(client) > 0 || Client_GetVehicle(client) > 0 || rp_GetClientInt(client, i_Sickness)) {  // En voiture, ou très malade
		ACCESS_DENIED(client);
	}
	if ((job == 8 || job == 9) && rp_GetZoneInt(zone, zone_type_type) != 1) {  // Gardien, policier dans le PDP
		ACCESS_DENIED(client);
	}
	if (!rp_GetClientBool(client, b_MaySteal) || rp_GetClientBool(client, b_Stealing)) {  // Pendant un vol
		ACCESS_DENIED(client);
	}
	
	if (GetClientTeam(client) == CS_TEAM_CT) {
		CS_SwitchTeam(client, CS_TEAM_T);
		SetEntityHealth(client, 100);
		
		if (rp_GetClientInt(client, i_PlayerLVL) >= 156)
			SetEntityHealth(client, 200);
		if (rp_GetClientInt(client, i_PlayerLVL) >= 380)
			SetEntityHealth(client, 500);
		if (rp_GetClientInt(client, i_PlayerLVL) >= 272)
			rp_SetClientInt(client, i_Kevlar, 100);
		if (rp_GetClientInt(client, i_PlayerLVL) >= 462)
			rp_SetClientInt(client, i_Kevlar, 250);
		
		SetEntProp(client, Prop_Send, "m_bHasHelmet", 0);
	}
	else if (GetClientTeam(client) == CS_TEAM_T) {
		CS_SwitchTeam(client, CS_TEAM_CT);
		SetEntityHealth(client, 500);
		rp_SetClientInt(client, i_Kevlar, 250);
		SetEntProp(client, Prop_Send, "m_bHasHelmet", 1);
		FakeClientCommand(client, "say /shownote");
	}
	Entity_SetMaxHealth(client, 500);
	rp_ClientResetSkin(client);
	rp_SetClientBool(client, b_MaySteal, false);
	CreateTimer(5.0, AllowStealing, client);
	return Plugin_Handled;
}
public Action Cmd_Vis(int client) {
	int job = rp_GetClientInt(client, i_Job);
	
	if (job != 1 && job != 2 && job != 4 && job != 5 && job != 6) {  // Chef, co chef, gti, cia
		ACCESS_DENIED(client);
	}
	int zone = rp_GetPlayerZone(client);
	int bit = rp_GetZoneBit(zone);
	
	if (bit & (BITZONE_BLOCKJAIL | BITZONE_JAIL | BITZONE_HAUTESECU | BITZONE_LACOURS | BITZONE_PERQUIZ)) {  // Flic ripoux
		ACCESS_DENIED(client);
	}
	if (rp_GetClientVehiclePassager(client) > 0 || Client_GetVehicle(client) > 0 || rp_GetClientInt(client, i_Sickness)) {  // En voiture, ou très malade
		ACCESS_DENIED(client);
	}
	if (!rp_GetClientBool(client, b_MaySteal) || rp_GetClientBool(client, b_Stealing)) {  // Pendant un vol
		ACCESS_DENIED(client);
	}
	if (rp_IsInPVP(client) && GetClientTeam(client) != CS_TEAM_CT) {  // Pas de vis si t'es en terro PVP
		ACCESS_DENIED(client);
	}
	
	if (!rp_GetClientBool(client, b_Invisible)) {
		rp_ClientColorize(client, { 255, 255, 255, 0 } );
		rp_SetClientBool(client, b_Invisible, true);
		rp_SetClientBool(client, b_MaySteal, false);
		
		ClientCommand(client, "r_screenoverlay effects/hsv.vmt");
		
		if (job == 6) {
			rp_SetClientFloat(client, fl_invisibleTime, GetGameTime() + 60.0);
			CreateTimer(120.0, AllowStealing, client);
		}
		else if (job == 5) {
			rp_SetClientFloat(client, fl_invisibleTime, GetGameTime() + 90.0);
			CreateTimer(120.0, AllowStealing, client);
		}
		else if (job == 4) {
			rp_SetClientFloat(client, fl_invisibleTime, GetGameTime() + 90.0);
			rp_SetClientBool(client, b_MaySteal, true);
		}
		else if (job == 1 || job == 2) {
			rp_SetClientFloat(client, fl_invisibleTime, GetGameTime() + 120.0);
			rp_SetClientBool(client, b_MaySteal, true);
		}
		
		CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous êtes maintenant invisible.");
	}
	else {
		rp_ClientReveal(client);
	}
	return Plugin_Handled;
}
public Action Cmd_Tazer(int client) {
	char tmp[128], tmp2[128], szQuery[1024];
	int job = rp_GetClientInt(client, i_Job);
	int Czone = rp_GetPlayerZone(client);
	
	if (rp_GetClientJobID(client) != 1 && rp_GetClientJobID(client) != 101) {
		ACCESS_DENIED(client);
	}
	if (rp_GetZoneBit(Czone) & (BITZONE_BLOCKJAIL | BITZONE_EVENT)) {
		ACCESS_DENIED(client);
	}
	if (rp_GetClientVehiclePassager(client) > 0 || Client_GetVehicle(client) > 0 || rp_GetClientInt(client, i_Sickness)) {  // En voiture, ou très malade
		ACCESS_DENIED(client);
	}
	if (!rp_GetClientBool(client, b_MaySteal)) {
		ACCESS_DENIED(client);
	}
	if (rp_GetClientFloat(client, fl_Invincible) > GetGameTime()) {  //le flic utilise une poupée gonflable
		ACCESS_DENIED(client);
	}
	
	int target = rp_GetClientTarget(client);
	if (target <= 0 || !IsValidEdict(target) || !IsValidEntity(target))
		return Plugin_Handled;
	
	if (GetEntityMoveType(target) == MOVETYPE_NOCLIP)
		return Plugin_Handled;
	
	int Tzone = rp_GetPlayerZone(target);
	
	if (IsValidClient(target)) {
		// Joueur:
		if (GetClientTeam(client) == CS_TEAM_T && job != 1 && job != 2 && job != 4 && job != 5 && job != 101 && job != 102) {
			ACCESS_DENIED(client);
		}
		if (GetClientTeam(target) == CS_TEAM_CT) {
			ACCESS_DENIED(client);
		}
		
		float maxDist = MAX_AREA_DIST * 3.0;
		if (rp_GetZoneBit(rp_GetPlayerZone(client)) & BITZONE_PERQUIZ || rp_GetZoneBit(rp_GetPlayerZone(target)) & BITZONE_PERQUIZ) {
			maxDist = 128.0;
		}
		
		if (Entity_GetDistance(client, target) > maxDist) {
			ACCESS_DENIED(client);
		}
		
		if (!(rp_GetZoneBit(rp_GetPlayerZone(client)) & BITZONE_PERQUIZ || rp_GetZoneBit(rp_GetPlayerZone(target)) & BITZONE_PERQUIZ) && rp_GetClientBool(target, b_Lube) && Math_GetRandomInt(1, 5) != 5) {
			CPrintToChat(client, "{lightblue}[TSX-RP]{default} %N vous glisse entre les mains.", target);
			return Plugin_Handled;
		}
		
		if (!(rp_GetZoneBit(rp_GetPlayerZone(client)) & BITZONE_PERQUIZ || rp_GetZoneBit(rp_GetPlayerZone(target)) & BITZONE_PERQUIZ) && !CanSendToJail(client, target)) {
			CPrintToChat(client, "{lightblue}[TSX-RP]{default} %N vous glisse entre les mains.", target);
			return Plugin_Handled;
		}
		
		float time;
		rp_Effect_Tazer(client, target);
		rp_HookEvent(target, RP_PreHUDColorize, fwdTazerBlue, 9.0);
		rp_HookEvent(target, RP_PrePlayerPhysic, fwdFrozen, 7.5);
		
		rp_SetClientFloat(target, fl_TazerTime, GetTickedTime() + 9.0);
		rp_SetClientFloat(target, fl_FrozenTime, GetGameTime() + 7.5);
		
		FakeClientCommand(target, "use weapon_knife");
		FakeClientCommand(target, "use weapon_knifegg");
		
		
		CPrintToChat(target, "{lightblue}[TSX-RP]{default} Vous avez été tazé par %N", client);
		CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous avez tazé %N", target);
		LogToGame("[TSX-RP] [TAZER] %L a tazé %N dans %d.", client, target, rp_GetPlayerZone(target));
		
		rp_SetClientBool(client, b_MaySteal, false);
		switch (job) {
			case 1:time = 0.001;
			case 101:time = 0.001;
			case 2:time = 0.5;
			case 102:time = 0.5;
			case 4:time = 4.0;
			case 5:time = 6.0;
			case 6:time = 7.0;
			case 7:time = 8.0;
			case 8:time = 9.0;
			case 9:time = 10.0;
			
			default:time = 10.0;
		}
		CreateTimer(time, AllowStealing, client);
	}
	else {
		if (GetClientTeam(client) == CS_TEAM_T && job != 1 && job != 2 && job != 4 && job != 5 && job != 6 && job != 7) {
			ACCESS_DENIED(client);
		}
		int reward = -1;
		int owner = rp_GetBuildingData(target, BD_owner);
		if (!IsValidClient(owner))
			owner = 0;
		
		GetEdictClassname(target, tmp2, sizeof(tmp2));
		
		if (owner != 0 && rp_IsMoveAble(target) && (Tzone == 0 || rp_GetZoneInt(Tzone, zone_type_type) <= 1)) {
			// PROPS
			rp_GetZoneData(Tzone, zone_type_name, tmp, sizeof(tmp));
			
			if (IsValidClient(owner)) {
				CPrintToChat(owner, "{lightblue}[TSX-RP]{default} Un de vos props vient d'être détruit.");
				LogToGame("[TSX-RP] [TAZER] %L a supprimé un props de %L dans %s", client, owner, tmp);
			}
			else {
				LogToGame("[TSX-RP] [TAZER] %L a supprimé un props dans %s", client, tmp);
			}
			
			
			reward = 0;
			if (rp_GetBuildingData(target, BD_started) + 120 < GetTime()) {
				Entity_GetModel(target, tmp, sizeof(tmp));
				if (StrContains(tmp, "popcan01a") == -1) {
					reward = 100;
				}
			}
		}
		else if (StrContains(tmp2, "weapon_") == 0 && GetEntPropEnt(target, Prop_Send, "m_hOwnerEntity") == -1 && GetEntProp(target, Prop_Data, "m_spawnflags") != 1) {
			
			rp_GetZoneData(Tzone, zone_type_name, tmp, sizeof(tmp));
			LogToGame("[TSX-RP] [TAZER] %L a supprimé une arme %s dans %s", client, tmp2, tmp);
			
			if (canWeaponBeAddedInPoliceStore(target))
				rp_WeaponMenu_Add(g_hBuyMenu, target, GetEntProp(target, Prop_Send, "m_OriginalOwnerXuidHigh"));
			int prix = rp_GetWeaponPrice(target);
			
			reward = prix / 10;
			
			if (rp_GetWeaponBallType(target) != ball_type_none) {
				reward += 150;
			}
		}
		else if (StrEqual(tmp2, "rp_cashmachine")) {
			
			rp_GetZoneData(Tzone, zone_type_name, tmp, sizeof(tmp));
			LogToGame("[TSX-RP] [TAZER] %L a supprimé une machine de %L dans %s", client, owner, tmp);
			
			reward = 25;
			if (rp_GetBuildingData(target, BD_started) + 120 < GetTime()) {
				reward = 100;
				if (owner != client)
					ClientTazedItem(client, reward);
			}
			
			if (owner > 0) {
				CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous avez détruit la machine de %N", owner);
				CPrintToChat(owner, "{lightblue}[TSX-RP]{default} Une de vos machines à faux-billets a été détruite par un agent de police.");
			}
			SDKHooks_TakeDamage(target, client, client, 1000.0);
		}
		else if (StrEqual(tmp2, "rp_bigcashmachine")) {
			
			rp_GetZoneData(Tzone, zone_type_name, tmp, sizeof(tmp));
			LogToGame("[TSX-RP] [TAZER] %L a supprimé une photocopieuse de %L dans %s", client, owner, tmp);
			
			reward = 25;
			if (rp_GetBuildingData(target, BD_started) + 120 < GetTime()) {
				reward = 1500;
				if (owner != client)
					ClientTazedItem(client, reward);
			}
			
			if (owner > 0) {
				CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous avez détruit la photocopieuse de %N", owner);
				CPrintToChat(owner, "{lightblue}[TSX-RP]{default} Votre photocopieuse a été détruite par un agent de police.");
			}
		}
		else if (StrEqual(tmp2, "rp_plant")) {
			
			rp_GetZoneData(Tzone, zone_type_name, tmp, sizeof(tmp));
			LogToGame("[TSX-RP] [TAZER] %L a supprimé un plant de %L dans %s", client, owner, tmp);
			
			reward = 100;
			if ((rp_GetBuildingData(target, BD_started) + 120 < GetTime() && rp_GetBuildingData(target, BD_FromBuild) == 0) || 
				(rp_GetBuildingData(target, BD_started) + 300 < GetTime() && rp_GetBuildingData(target, BD_FromBuild) == 1)) {
				
				if (rp_GetBuildingData(target, BD_FromBuild) == 1)
					reward += 50 * rp_GetBuildingData(target, BD_count);
				else
					reward += 200 * rp_GetBuildingData(target, BD_count);
				
				if (owner != client)
					ClientTazedItem(client, reward);
			}
			
			if (owner > 0) {
				CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous avez détruit le plant de drogue de %N", owner);
				CPrintToChat(owner, "{lightblue}[TSX-RP]{default} Un de vos plants de drogue a été détruit par un agent de police.");
			}
			
			if (owner == client)
				reward = 0;
		}
		else if (StrContains(tmp2, "rp_barriere") == 0) {
			rp_GetZoneData(Tzone, zone_type_name, tmp, sizeof(tmp));
			LogToGame("[TSX-RP] [TAZER] %L a retiré une barrière de %L dans %s", client, owner, tmp);
			
			reward = 0;
			
			if (owner > 0) {
				if (client == owner)
					CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous avez retiré votre propre barrière.");
				else {
					CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous avez retiré la barrière de %N.", owner);
					CPrintToChat(owner, "{lightblue}[TSX-RP]{default} Une de vos barrières a été retirée par un agent de police.");
				}
			}
		}
		if (reward >= 0) {
			
			rp_Effect_Tazer(client, target);
			rp_Effect_PropExplode(target, true);
			AcceptEntityInput(target, "Kill");
			
			rp_ClientMoney(client, i_AddToPay, reward);
			rp_SetJobCapital(1, rp_GetJobCapital(1) + reward * 2);
			
			GetClientAuthId(client, AuthId_Engine, tmp, sizeof(tmp), false);
			Format(szQuery, sizeof(szQuery), "INSERT INTO `rp_sell` (`id`, `steamid`, `job_id`, `timestamp`, `item_type`, `item_id`, `item_name`, `amount`) VALUES (NULL, '%s', '%i', '%i', '3', '%i', '%s', '%i');", 
				tmp, rp_GetClientJobID(client), GetTime(), 1, "TAZER", reward);
			
			SQL_TQuery(rp_GetDatabase(), SQL_QueryCallBack, szQuery);
		}
	}
	return Plugin_Handled;
}
public Action Cmd_InJail(int client) {
	char tmp[256];
	
	int zone;
	
	Handle menu = CreateMenu(MenuNothing);
	SetMenuTitle(menu, "Liste des joueurs en prison:");
	
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsValidClient(i))
			continue;
		
		zone = rp_GetZoneBit(rp_GetPlayerZone(i));
		if (zone & (BITZONE_JAIL | BITZONE_LACOURS | BITZONE_HAUTESECU)) {
			
			Format(tmp, sizeof(tmp), "%N  - %.1f heures", i, rp_GetClientInt(i, i_JailTime) / 60.0);
			AddMenuItem(menu, tmp, tmp, ITEMDRAW_DISABLED);
		}
	}
	
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_DURATION);
	
	return Plugin_Handled;
}
public Action Cmd_Jail(int client) {
	int job = rp_GetClientInt(client, i_Job);
	
	if (rp_GetClientJobID(client) != 1 && rp_GetClientJobID(client) != 101) {
		ACCESS_DENIED(client);
	}
	if (GetClientTeam(client) == CS_TEAM_T && ((job == 8 || job == 9) || (job >= 101 && job <= 109))) {
		ACCESS_DENIED(client);
	}
	
	float time = GetGameTime();
	int ct = 0;
	
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsValidClient(i) || IsClientSourceTV(i))
			continue;
		if (rp_GetClientJobID(i) == 1)
			ct++;
		
		if (Entity_GetDistance(client, i) < MAX_AREA_DIST) {
			if (!IsPlayerAlive(i) && rp_GetClientFloat(i, fl_RespawnTime) < time)
				CS_RespawnPlayer(i);
			if (rp_GetClientJobID(i) == 1)
				ct += 10;
		}
	}
	
	int target = rp_GetClientTarget(client);
	if (target <= 0 || !IsValidEdict(target) || !IsValidEntity(target))
		return Plugin_Handled;

	if (rp_GetZoneBit(rp_GetPlayerZone(client)) & BITZONE_PERQUIZ || rp_GetZoneBit(rp_GetPlayerZone(target)) & BITZONE_PERQUIZ) { // Les juges peuvent jail en perqui
		ct = 0;
	}
	
	if (IsValidClient(target) && rp_GetClientFloat(target, fl_Invincible) > GetGameTime()) {  //le target utilise une poupée gonflable
		ACCESS_DENIED(client);
	}
	if (rp_GetClientFloat(client, fl_Invincible) > GetGameTime()) {  //le flic utilise une poupée gonflable
		ACCESS_DENIED(client);
	}
	if (IsValidClient(target) && !rp_IsTutorialOver(target)) {
		ACCESS_DENIED(client);
	}
	
	if( IsValidClient(target) && rp_GetClientJobID(client) == 101 && rp_GetClientBool(target, b_IsSearchByTribunal) == false) {  // Jail dans la rue sur non recherché.
		if (ct >= 3 && rp_GetZoneInt(rp_GetPlayerZone(client), zone_type_type) != 101) {
			ACCESS_DENIED(client);
		}
	}
	
	
	int Czone = rp_GetPlayerZone(client);
	int Cbit = rp_GetZoneBit(Czone);
	
	int Tzone = rp_GetPlayerZone(target);
	int Tbit = rp_GetZoneBit(Tzone);
	
	float maxDist = MAX_AREA_DIST * 2.0;
	
	if (Cbit & BITZONE_PERQUIZ || Tbit & BITZONE_PERQUIZ)
		maxDist = 128.0;
	
	if (Entity_GetDistance(client, target) > maxDist) {
		ACCESS_DENIED(client);
	}
	
	if (Cbit & BITZONE_BLOCKJAIL || Tbit & BITZONE_BLOCKJAIL) {
		ACCESS_DENIED(client);
	}
	
	if (rp_IsValidVehicle(target)) {
		int client2 = GetEntPropEnt(target, Prop_Send, "m_hPlayer");
		
		if (!IsValidClient(client2))
			return Plugin_Handled;
		
		if (!CanSendToJail(client, client2)) {
			CPrintToChat(client, "{lightblue}[TSX-RP]{default} %N ne peut être mis en prison pour le moment à cause d'une quête.", client2);
			return Plugin_Handled;
		}
		if (IsValidClient(client2)) {
			rp_ClientVehicleExit(client2, target, true);
			CPrintToChat(client2, "{lightblue}[TSX-RP]{default} %N vous a sorti de votre voiture.", client);
		}
		return Plugin_Handled;
	}
	else if (!IsValidClient(target)) {
		return Plugin_Handled;
	}
	
	if (Client_GetVehicle(target) > 0) {
		if (IsValidClient(target)) {
			if (!CanSendToJail(client, target)) {
				CPrintToChat(client, "{lightblue}[TSX-RP]{default} %N ne peut être mis en prison pour le moment à cause d'une quête.", target);
				return Plugin_Handled;
			}
			rp_ClientVehicleExit(target, Client_GetVehicle(target), true);
			CPrintToChat(target, "{lightblue}[TSX-RP]{default} %N vous a sorti de votre voiture.", client);
		}
		return Plugin_Handled;
	}
	
	if (GetClientTeam(target) == CS_TEAM_CT) {
		ACCESS_DENIED(client);
	}
	
	if (!CanSendToJail(client, target)) {
		CPrintToChat(client, "{lightblue}[TSX-RP]{default} %N ne peut être mis en prison pour le moment à cause d'une quête.", target);
		return Plugin_Handled;
	}
	
	if (rp_GetClientInt(target, i_JailTime) <= 60)
		rp_SetClientInt(target, i_JailTime, 60);
	
	SendPlayerToJail(target, client);
	// g_iUserMission[target][mission_type] = -1; 
	
	return Plugin_Handled;
}
public Action Cmd_Push(int client) {
	int job = rp_GetClientInt(client, i_Job);
	
	if (rp_GetClientJobID(client) != 1 && rp_GetClientJobID(client) != 101) {
		ACCESS_DENIED(client);
	}
	int Czone = rp_GetPlayerZone(client);
	if (rp_GetZoneBit(Czone) & (BITZONE_BLOCKJAIL | BITZONE_EVENT)) {
		ACCESS_DENIED(client);
	}
	
	if (GetClientTeam(client) == CS_TEAM_T && ((job == 8 || job == 9) || (job >= 103 && job <= 109))) {
		ACCESS_DENIED(client);
	}
	
	int target = rp_GetClientTarget(client);
	if (target <= 0 || !IsValidEdict(target) || !IsValidEntity(target))
		return Plugin_Handled;
	if (!IsValidClient(target)) {
		ACCESS_DENIED(client);
	}
	
	if (Entity_GetDistance(client, target) > MAX_AREA_DIST * 3) {
		ACCESS_DENIED(client);
	}
	
	if (!rp_GetClientBool(client, b_MaySteal)) {
		ACCESS_DENIED(client);
	}
	rp_SetClientBool(client, b_MaySteal, false);
	CreateTimer(7.5, AllowStealing, client);
	
	float cOrigin[3], tOrigin[3];
	GetClientAbsOrigin(client, cOrigin);
	GetClientAbsOrigin(target, tOrigin);
	
	cOrigin[2] -= 100.0;
	
	float f_Velocity[3];
	SubtractVectors(tOrigin, cOrigin, f_Velocity);
	NormalizeVector(f_Velocity, f_Velocity);
	ScaleVector(f_Velocity, 500.0);
	
	TeleportEntity(target, NULL_VECTOR, NULL_VECTOR, f_Velocity);
	
	
	LogToGame("[TSX-RP] [TAZER] %L a tazé %N dans %d.", client, target, rp_GetPlayerZone(target));
	
	return Plugin_Handled;
}
// ----------------------------------------------------------------------------
void SendPlayerToJail(int target, int client = 0) {
	static float fLocation[MAX_LOCATIONS][3];
	char tmp[128];
	
	
	rp_ClientGiveItem(client, 1, -rp_GetClientItem(client, 1));
	rp_ClientGiveItem(client, 2, -rp_GetClientItem(client, 2));
	rp_ClientGiveItem(client, 3, -rp_GetClientItem(client, 3));
	
	int MaxJail = 0;
	
	for (int i = 0; i < MAX_LOCATIONS; i++) {
		rp_GetLocationData(i, location_type_base, tmp, sizeof(tmp));
		if (StrEqual(tmp, "jail", false)) {
			
			fLocation[MaxJail][0] = float(rp_GetLocationInt(i, location_type_origin_x));
			fLocation[MaxJail][1] = float(rp_GetLocationInt(i, location_type_origin_y));
			fLocation[MaxJail][2] = float(rp_GetLocationInt(i, location_type_origin_z)) + 5.0;
			
			MaxJail++;
		}
	}
	
	if (GetClientTeam(target) == CS_TEAM_CT) {
		CS_SwitchTeam(target, CS_TEAM_T);
	}
	
	GetClientAbsOrigin(target, g_flLastPos[target]);
	Entity_GetModel(target, tmp, sizeof(tmp));
	Entity_SetModel(target, MODEL_PRISONNIER);
	rp_ClientColorize(target); // Remet la couleur normale au prisonnier si jamais il est coloré
	if (!StrEqual(tmp, MODEL_PRISONNIER))
		SetEntProp(target, Prop_Send, "m_nSkin", Math_GetRandomInt(0, 14));
	
	if (IsValidClient(client)) {
		if (!IsValidClient(rp_GetClientInt(target, i_JailledBy)))
			rp_SetClientInt(target, i_JailledBy, client);
		
		
		CPrintToChat(target, "{lightblue}[TSX-RP]{default} %N {default}vous a mis en prison.", client);
		CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous avez mis %N {default}en prison.", target);
		
		AskJailTime(client, target);
		LogToGame("[TSX-RP] [JAIL-0] %L (%d) a mis %L (%d) en prison.", client, rp_GetPlayerZone(client, 1.0), target, rp_GetPlayerZone(target, 1.0));
		
	}
	
	
	
	int rand = Math_GetRandomInt(0, (MaxJail - 1));
	rp_ClientTeleport(target, fLocation[rand]);
	
	SDKHook(target, SDKHook_WeaponDrop, OnWeaponDrop);
	CreateTimer(MENU_TIME_DURATION.0, AllowWeaponDrop, target);
	
	Call_StartForward(rp_GetForwardHandle(target, RP_PostClientSendToJail));
	Call_PushCell(target);
	Call_PushCell(client);
	Call_Finish();
}
public Action AllowWeaponDrop(Handle timer, any client) {
	SDKUnhook(client, SDKHook_WeaponDrop, OnWeaponDrop);
}
public Action OnWeaponDrop(int client, int weapon) {
	return Plugin_Handled;
}
// ----------------------------------------------------------------------------
void AskJailTime(int client, int target) {
	char tmp[256], tmp2[12];
	
	GetClientAuthId(target, AuthId_Engine, g_szTribunal[client], sizeof(g_szTribunal[]), false);
	
	Handle menu = CreateMenu(eventSetJailTime);
	Format(tmp, 255, "Combien de temps doit rester %N?\n ", target);
	SetMenuTitle(menu, tmp);
	
	Format(tmp, 255, "%d_-1", target);
	AddMenuItem(menu, tmp, "Annuler la peine / Liberer");
	
	if (rp_GetClientJobID(client) == 101 || rp_GetClientBool(target, b_IsSearchByTribunal)) {
		Format(tmp, 255, "%d_-3", target);
		AddMenuItem(menu, tmp, "Jail Tribunal N°1");
		Format(tmp, 255, "%d_-2", target);
		AddMenuItem(menu, tmp, "Jail Tribunal N°2");
	}
	
	
	
	if (rp_GetClientInt(target, i_JailTime) <= 6 * 60) {
		for (int i = 0; i < sizeof(g_szJailRaison); i++) {
			if (rp_GetClientJobID(client) == 101 && StringToInt(g_szJailRaison[i][jail_simple]) == 0 && rp_GetClientBool(target, b_IsSearchByTribunal) == false && rp_GetZoneInt(rp_GetPlayerZone(client), zone_type_type) != 101)
				continue;
			
			Format(tmp2, sizeof(tmp2), "%d_%d", target, i);
			AddMenuItem(menu, tmp2, g_szJailRaison[i][jail_raison]);
		}
	}
	else {
		Format(tmp2, sizeof(tmp2), "%d_%d", target, sizeof(g_szJailRaison) - 1);
		AddMenuItem(menu, tmp2, g_szJailRaison[sizeof(g_szJailRaison) - 1][jail_raison]);
	}
	
	SetMenuExitButton(menu, true);
	
	DisplayMenu(menu, client, MENU_TIME_DURATION);
}
public int eventAskJail2Time(Handle menu, MenuAction action, int client, int param2) {
	if (action == MenuAction_Select) {
		char options[64];
		GetMenuItem(menu, param2, options, 63);
		
		char data[2][32];
		
		ExplodeString(options, "_", data, sizeof(data), sizeof(data[]));
		
		int iTarget = StringToInt(data[0]);
		int iTime = StringToInt(data[1]);
		
		if (iTime < 0) {
			AskJailTime(client, iTarget);
			
			
			if (rp_GetClientInt(iTarget, i_JailTime) <= 60)
				rp_SetClientInt(iTarget, i_JailTime, 1 * 60);
			
			SendPlayerToJail(iTarget);
		}
		else {
			
			SendPlayerToJail(iTarget);
			rp_SetClientInt(iTarget, i_JailTime, (iTime * 60) + 20);
			rp_SetClientInt(iTarget, i_JailledBy, client);
			rp_ClientOverlays(iTarget, o_Jail_Juge, 20.0);
			
			CPrintToChatAll("{lightblue}[TSX-RP]{default} %N {default}a été condamné à faire %i heures de prison par le juge %N{default}.", iTarget, iTime, client);
			LogToGame("[TSX-RP] [JUGE] %L a été condamné à faire %i heures de prison par le juge %L.", iTarget, iTime, client);
		}
	}
	else if (action == MenuAction_End) {
		CloseHandle(menu);
	}
}
public int eventSetJailTime(Handle menu, MenuAction action, int client, int param2) {
	char options[64], data[2][32], szQuery[1024];
	
	if (action == MenuAction_Select) {
		
		
		GetMenuItem(menu, param2, options, 63);
		ExplodeString(options, "_", data, sizeof(data), sizeof(data[]));
		
		int target = StringToInt(data[0]);
		int type = StringToInt(data[1]);
		int time_to_spend;
		int jobID = rp_GetClientJobID(client);
		//FORCE_Release(iTarget);
		
		if (type == -1) {
			
			rp_SetClientInt(target, i_JailTime, 0);
			rp_SetClientInt(target, i_jailTime_Last, 0);
			rp_SetClientInt(target, i_JailledBy, 0);
			
			CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous avez libéré %N{default}.", target);
			CPrintToChat(target, "{lightblue}[TSX-RP]{default} %N {default}vous a libéré.", client);
			
			LogToGame("[TSX-RP] [JAIL] [LIBERATION] %L a liberé %L", client, target);
			
			int zonec = rp_GetZoneFromPoint(g_flLastPos[target]);
			int bit = rp_GetZoneBit(zonec);
			
			if (bit & (BITZONE_JAIL | BITZONE_HAUTESECU | BITZONE_LACOURS) || rp_GetZoneInt(zonec, zone_type_type) == 101) {
				rp_ClientSendToSpawn(target, true);
			}
			else {
				rp_ClientTeleport(target, g_flLastPos[target]);
			}
			
			rp_ClientResetSkin(target);
			return;
		}
		if (type == -2 || type == -3) {
			
			if (type == -3)
				rp_ClientTeleport(target, view_as<float>( { -966.1, -570.6, -2007.9 } ));
			else
				rp_ClientTeleport(target, view_as<float>( { 473.7, -1979.5, -2007.9 } ));
			
			CPrintToChat(target, "{lightblue}[TSX-RP]{default} Vous avez été mis en prison, en attente de jugement par: %N", client);
			CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous avez mis: %N {default}dans la prison du Tribunal.", target);
			
			LogToGame("[TSX-RP] [TRIBUNAL] %L a mis %L dans la prison du Tribunal.", client, target);
			return;
		}
		
		
		
		if (StrEqual(g_szJailRaison[type][jail_raison], "Agression physique")) {  // Agression physique
			if (rp_GetClientInt(target, i_LastAgression) + 30 < GetTime()) {
				rp_SetClientInt(target, i_JailTime, 0);
				rp_SetClientInt(target, i_jailTime_Last, 0);
				rp_SetClientInt(target, i_JailledBy, 0);
				
				CPrintToChat(client, "{lightblue}[TSX-RP]{default} %N{default} a été libéré car il n'a pas commis d'agression.", target);
				CPrintToChat(target, "{lightblue}[TSX-RP]{default} Vous avez été libéré car vous n'avez pas commis d'agression.", client);
				
				LogToGame("[TSX-RP] [JAIL] %L a été libéré car il n'avait pas commis d'agression", target);
				
				rp_ClientTeleport(target, g_flLastPos[target]);
				rp_ClientResetSkin(target);
				return;
			}
		}
		if (StrEqual(g_szJailRaison[type][jail_raison], "Tir dans la rue")) {  // Tir dans la rue
			if (rp_GetClientInt(target, i_LastDangerousShot) + 30 < GetTime()) {
				rp_SetClientInt(target, i_JailTime, 0);
				rp_SetClientInt(target, i_jailTime_Last, 0);
				rp_SetClientInt(target, i_JailledBy, 0);
				
				CPrintToChat(client, "{lightblue}[TSX-RP]{default} %N{default} a été libéré car il n'a pas effectué de tir dangereux.", target);
				CPrintToChat(target, "{lightblue}[TSX-RP]{default} Vous avez été libéré car vous n'avez pas effectué de tir dangereux.", client);
				
				LogToGame("[TSX-RP] [JAIL] %L a été libéré car il n'avait pas effectué de tir dangereux", target);
				
				rp_ClientTeleport(target, g_flLastPos[target]);
				rp_ClientResetSkin(target);
				return;
			}
		}
		
		
		int amende = StringToInt(g_szJailRaison[type][jail_amende]);
		
		if (amende == -1) {
			amende = rp_GetClientInt(target, i_KillJailDuration) * 50;
			
			if (amende == 0 && rp_GetClientInt(target, i_LastAgression) + 30 > GetTime())
				amende = StringToInt(g_szJailRaison[3][jail_amende]);
		}
		
		if (String_StartsWith(g_szJailRaison[type][jail_raison], "Vol")) {
			if (rp_GetClientInt(target, i_LastVolVehicleTime) + 300 > GetTime()) {
				if (rp_IsValidVehicle(rp_GetClientInt(target, i_LastVolVehicle))) {
					rp_SetClientKeyVehicle(target, rp_GetClientInt(target, i_LastVolVehicle), false);
					CPrintToChat(client, "{lightblue}[TSX-RP]{default} %N{default} a perdu les clés de la voiture qu'il a volé.", target);
					CPrintToChat(target, "{lightblue}[TSX-RP]{default} Vous avez perdu les clés de la voiture que vous avez volé.", client);
				}
			}
			else if (rp_GetClientInt(target, i_LastVolTime) + 30 < GetTime()) {
				rp_SetClientInt(target, i_JailTime, 0);
				rp_SetClientInt(target, i_jailTime_Last, 0);
				rp_SetClientInt(target, i_JailledBy, 0);
				
				CPrintToChat(client, "{lightblue}[TSX-RP]{default} %N{default} a été libéré car il n'a pas commis de vol.", target);
				CPrintToChat(target, "{lightblue}[TSX-RP]{default} Vous avez été libéré car vous n'avez pas commis de vol.", client);
				
				LogToGame("[TSX-RP] [JAIL] %L a été libéré car il n'avait pas commis de vol", target);
				
				rp_ClientResetSkin(target);
				rp_ClientTeleport(target, g_flLastPos[target]);
				return;
			}
			if (IsValidClient(rp_GetClientInt(target, i_LastVolTarget))) {
				int tg = rp_GetClientInt(target, i_LastVolTarget);
				rp_ClientMoney(tg, i_Money, rp_GetClientInt(target, i_LastVolAmount));
				rp_ClientMoney(target, i_AddToPay, -rp_GetClientInt(target, i_LastVolAmount));
				
				CPrintToChat(target, "{lightblue}[TSX-RP]{default} Vous avez remboursé votre victime de %d$.", rp_GetClientInt(target, i_LastVolAmount));
				CPrintToChat(tg, "{lightblue}[TSX-RP]{default} Le voleur a été mis en prison. Vous avez été remboursé de %d$.", rp_GetClientInt(target, i_LastVolAmount));
			}
			else {
				amende += rp_GetClientInt(target, i_LastVolAmount); // Cas tentative de vol ou distrib...
			}
			
			CancelClientMenu(target, true);
		}
		else {
			amendeCalculation(target, amende);
		}
		
		if (rp_GetClientInt(target, i_Money) >= amende || (
				(rp_GetClientInt(target, i_Money) + rp_GetClientInt(target, i_Bank)) >= amende * 250 && amende <= 2500)) {
			
			rp_SetClientStat(target, i_MoneySpent_Fines, rp_GetClientStat(target, i_MoneySpent_Fines) + amende);
			rp_ClientMoney(target, i_Money, -amende);
			
			if (rp_GetClientBool(client, b_GameModePassive)) {
				rp_ClientMoney(client, i_AddToPay, amende / 4);
				rp_SetJobCapital(jobID, rp_GetJobCapital(jobID) + (amende / 4 * 3));
			}
			else {
				rp_ClientMoney(client, i_AddToPay, amende / 2);
				rp_SetJobCapital(jobID, rp_GetJobCapital(jobID) + (amende / 2));
			}
			
			GetClientAuthId(client, AuthId_Engine, options, sizeof(options), false);
			
			Format(szQuery, sizeof(szQuery), "INSERT INTO `rp_sell` (`id`, `steamid`, `job_id`, `timestamp`, `item_type`, `item_id`, `item_name`, `amount`) VALUES (NULL, '%s', '%i', '%i', '4', '%i', '%s', '%i');", 
				options, jobID, GetTime(), 0, "Caution", amende / 4);
			
			SQL_TQuery(rp_GetDatabase(), SQL_QueryCallBack, szQuery);
			
			time_to_spend = StringToInt(g_szJailRaison[type][jail_temps]);
			if (time_to_spend == -1) {
				time_to_spend = rp_GetClientInt(target, i_KillJailDuration);
				if (time_to_spend == 0 && rp_GetClientInt(target, i_LastAgression) + 30 > GetTime())
					time_to_spend = StringToInt(g_szJailRaison[3][jail_temps]);
				
				for (int i = 1; i < MAXPLAYERS + 1; i++) {
					if (!IsValidClient(i))
						continue;
					if (rp_GetClientInt(i, i_LastKilled_Reverse) != target)
						continue;
					CPrintToChat(i, "{lightblue}[TSX-RP]{default} Votre assassin a été mis en prison.");
				}
				time_to_spend /= 2;
			}
			
			
			if (amende > 0) {
				
				if (IsValidClient(target)) {
					CPrintToChat(client, "{lightblue}[TSX-RP]{default} Une amende de %i$ a été prélevée à %N{default}.", amende, target);
					CPrintToChat(target, "{lightblue}[TSX-RP]{default} Une caution de %i$ vous a été prelevée.", amende);
				}
			}
		}
		else {
			time_to_spend = StringToInt(g_szJailRaison[type][jail_temps_nopay]);
			if (time_to_spend == -1) {
				time_to_spend = rp_GetClientInt(target, i_KillJailDuration);
				if (time_to_spend == 0 && rp_GetClientInt(target, i_LastAgression) + 30 > GetTime())
					time_to_spend = StringToInt(g_szJailRaison[3][jail_temps_nopay]);
				
				for (int i = 1; i < MAXPLAYERS + 1; i++) {
					if (!IsValidClient(i))
						continue;
					if (rp_GetClientInt(i, i_LastKilled_Reverse) != target)
						continue;
					CPrintToChat(i, "{lightblue}[TSX-RP]{default} Votre assassin a été mis en prison.");
				}
			}
			
			
			else if (rp_GetClientInt(target, i_Bank) >= amende && time_to_spend != -2) {
				WantPayForLeaving(target, client, type, amende);
			}
		}
		
		if (time_to_spend < 0) {
			int d = 6;
			if (ZoneDeJailSansIntrusion(rp_GetZoneFromPoint(g_flLastPos[target])))
				d = 1;
			
			time_to_spend = rp_GetClientInt(target, i_JailTime) + (d * 60);
		}
		else {
			rp_SetClientInt(target, i_jailTime_Reason, type);
			time_to_spend *= 60;
		}
		
		rp_SetClientInt(target, i_JailTime, time_to_spend);
		rp_SetClientInt(target, i_jailTime_Last, time_to_spend);
		
		if (IsValidClient(client) && IsValidClient(target)) {
			CPrintToChat(client, "{lightblue}[TSX-RP]{default} %N {default}restera en prison %.1f heures pour \"%s\"", target, time_to_spend / 60.0, g_szJailRaison[type][jail_raison]);
			CPrintToChat(target, "{lightblue}[TSX-RP]{default} %N {default}vous a mis %.1f heures de prison pour \"%s\"", client, time_to_spend / 60.0, g_szJailRaison[type][jail_raison]);
			explainJail(target, type);
		}
		else {
			CPrintToChat(client, "{lightblue}[TSX-RP]{default} Le joueur s'est déconnecté mais il fera %.1f heures de prison", time_to_spend / 60.0);
			
			Format(szQuery, sizeof(szQuery), "INSERT INTO `rp_users2` (`id`, `steamid`, `jail` ) VALUES", szQuery);
			Format(szQuery, sizeof(szQuery), "%s (NULL, '%s', '%i' );", szQuery, g_szTribunal[client], time_to_spend);
			
			SQL_TQuery(rp_GetDatabase(), SQL_QueryCallBack, szQuery);
		}
		
		LogToGame("[TSX-RP] [JAIL-1] %L (%d) a mis %L (%d) en prison: Raison %s.", client, rp_GetPlayerZone(client, 1.0), target, rp_GetPlayerZone(target, 1.0), g_szJailRaison[type][jail_raison]);
		
		if (time_to_spend <= 1) {
			rp_ClientResetSkin(target);
			rp_ClientSendToSpawn(target, true);
		}
		StripWeapons(target);
	}
	else if (action == MenuAction_End) {
		CloseHandle(menu);
	}
}
void WantPayForLeaving(int client, int police, int type, int amende) {
	
	// Setup menu
	Handle menu = CreateMenu(eventPayForLeaving);
	char tmp[256];
	Format(tmp, 255, "Vous avez été mis en prison pour \n %s\nUne caution de %i$ vous est demandé\n ", g_szJailRaison[type][jail_raison], amende);
	SetMenuTitle(menu, tmp);
	
	Format(tmp, 255, "%i_%i_%i", police, type, amende);
	AddMenuItem(menu, tmp, "Oui, je souhaite payer ma caution");
	
	Format(tmp, 255, "0_0_0");
	AddMenuItem(menu, tmp, "Non, je veux rester plus longtemps");
	
	
	SetMenuExitButton(menu, false);
	
	DisplayMenu(menu, client, MENU_TIME_DURATION);
}
public int eventPayForLeaving(Handle menu, MenuAction action, int client, int param2) {
	if (action == MenuAction_Select) {
		char options[64], data[3][32], szQuery[2048];
		
		GetMenuItem(menu, param2, options, 63);
		
		ExplodeString(options, "_", data, sizeof(data), sizeof(data[]));
		
		
		int target = StringToInt(data[0]);
		int type = StringToInt(data[1]);
		int amende = StringToInt(data[2]);
		int jobID = rp_GetClientJobID(target);
		
		if (target == 0 && type == 0 && amende == 0)
			return;
		
		int time_to_spend = 0;
		rp_SetClientStat(client, i_MoneySpent_Fines, rp_GetClientStat(client, i_MoneySpent_Fines) + amende);
		rp_ClientMoney(client, i_Money, -amende);
		rp_ClientMoney(target, i_AddToPay, (amende / 4));
		rp_SetJobCapital(jobID, rp_GetJobCapital(jobID) + (amende / 4 * 3));
		
		GetClientAuthId(client, AuthId_Engine, options, sizeof(options), false);
		
		Format(szQuery, sizeof(szQuery), "INSERT INTO `rp_sell` (`id`, `steamid`, `job_id`, `timestamp`, `item_type`, `item_id`, `item_name`, `amount`) VALUES (NULL, '%s', '%i', '%i', '4', '%i', '%s', '%i');", 
			options, jobID, GetTime(), 0, "Caution", amende / 4);
		
		SQL_TQuery(rp_GetDatabase(), SQL_QueryCallBack, szQuery);
		
		time_to_spend = StringToInt(g_szJailRaison[type][jail_temps]);
		if (time_to_spend == -1) {
			time_to_spend = rp_GetClientInt(target, i_KillJailDuration);
			
			time_to_spend /= 2;
		}
		
		
		if (IsValidClient(target)) {
			CPrintToChat(target, "{lightblue}[TSX-RP]{default} Une amende de %i$ a été prélevée à %N.", amende, client);
			CPrintToChat(client, "{lightblue}[TSX-RP]{default} Une caution de %i$ vous a été prelevée.", amende);
		}
		
		time_to_spend *= 60;
		rp_SetClientInt(client, i_JailTime, time_to_spend);
		rp_SetClientInt(client, i_jailTime_Last, time_to_spend);
	}
	else if (action == MenuAction_End) {
		CloseHandle(menu);
	}
}
// ----------------------------------------------------------------------------
void amendeCalculation(int client, int & amende) {
	float ratio = float(rp_GetClientInt(client, i_Kill31Days) + 1) / float(rp_GetClientInt(client, i_Death31Days) + 1);
	if (ratio < 0.25)
		ratio = 0.25;
	
	amende = RoundFloat(float(amende) * ratio);
	
	if (rp_GetServerRules(rules_Amendes, rules_Enabled) == 1) {
		int target = rp_GetServerRules(rules_Amendes, rules_Target);
		
		if (rp_GetClientJobID(client) == target || rp_GetClientGroupID(client) == (target - 1000)) {
			
			if (rp_GetServerRules(rules_Amendes, rules_Arg) == 1)
				amende = RoundFloat(float(amende) * 1.05);
			else
				amende = RoundFloat(float(amende) * 0.90);
		}
	}
}
// ----------------------------------------------------------------------------
public Action AllowStealing(Handle timer, any client) {
	rp_SetClientBool(client, b_MaySteal, true);
}
public int MenuNothing(Handle menu, MenuAction action, int client, int param2) {
	if (action == MenuAction_Select) {
		if (menu != INVALID_HANDLE)
			CloseHandle(menu);
	}
	else if (action == MenuAction_End) {
		if (menu != INVALID_HANDLE)
			CloseHandle(menu);
	}
}
public Action fwdFrozen(int client, float & speed, float & gravity) {
	speed = 0.0;
	
	return Plugin_Stop;
}
public Action fwdTazerBlue(int client, int color[4]) {
	color[0] -= 50;
	color[1] -= 50;
	color[2] += 255;
	color[3] += 50;
	return Plugin_Changed;
}
public bool TraceRayDontHitSelf(int entity, int mask, any data) {
	if (entity == data) {
		return false;
	}
	return true;
}
// ----------------------------------------------------------------------------
public Action fwdOnPlayerBuild(int client, float & cooldown) {
	
	if (rp_GetClientJobID(client) != 1 && rp_GetClientJobID(client) != 101)
		return Plugin_Continue;
	
	if (rp_IsInPVP(client)) {
		CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous ne pouvez pas poser une barrière en PVP.");
		return Plugin_Continue;
	}
	
	int Tzone = rp_GetPlayerZone(client);
	if (Tzone == 24 || Tzone == 25) {
		CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous ne pouvez pas poser une barrière dans les conduits.");
		return Plugin_Continue;
	}
	
	int ent = BuildingBarriere(client);
	
	if (ent > 0) {
		rp_SetClientStat(client, i_TotalBuild, rp_GetClientStat(client, i_TotalBuild) + 1);
		rp_ScheduleEntityInput(ent, 120.0, "Kill");
		cooldown = 7.0;
	}
	else
		cooldown = 3.0;
	
	return Plugin_Stop;
}
int BuildingBarriere(int client) {
	
	if (!rp_IsBuildingAllowed(client))
		return 0;
	
	char classname[64], tmp[64];
	
	Format(classname, sizeof(classname), "rp_barriere");
	
	int count, job = rp_GetClientInt(client, i_Job), max = 0;
	
	switch (job) {
		case 1:max = 7; //Chef
		case 2:max = 6; //Co-chef
		case 4:max = 5; //RAID
		case 5:max = 5; //GTI
		case 6:max = 4; //CIA
		case 7:max = 3; //FBI
		case 8:max = 2; //Policier
		case 9:max = 1; //Gardien
		
		case 101:max = 7; // Président
		case 102:max = 6; // Vice président
		case 103:max = 6; // HJ2
		case 104:max = 5; // HJ1
		case 105:max = 4; // J2
		case 106:max = 3; // J1
		case 107:max = 5; // GOS
		case 108:max = 3; // US
		case 109:max = 1; // gONU
		
		
		default:max = 0;
		
	}
	
	float vecOrigin[3];
	GetClientAbsOrigin(client, vecOrigin);
	for (int i = 1; i <= 2048; i++) {
		if (!IsValidEdict(i))
			continue;
		if (!IsValidEntity(i))
			continue;
		
		GetEdictClassname(i, tmp, sizeof(tmp));
		
		if (StrEqual(classname, tmp) && rp_GetBuildingData(i, BD_owner) == client) {
			count++;
			if (count >= max) {
				CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous avez posé trop de barrières.");
				return 0;
			}
		}
	}
	
	CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous posez une barrière...");
	
	EmitSoundToAllAny("player/ammo_pack_use.wav", client);
	
	int ent = CreateEntityByName("prop_physics_override");
	
	DispatchKeyValue(ent, "classname", classname);
	DispatchKeyValue(ent, "model", MODEL_BARRIERE);
	DispatchSpawn(ent);
	ActivateEntity(ent);
	
	SetEntityModel(ent, MODEL_BARRIERE);
	
	SetEntProp(ent, Prop_Data, "m_iHealth", 1000);
	SetEntProp(ent, Prop_Data, "m_takedamage", 0);
	
	SetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity", client);
	
	float vecAngles[3]; GetClientEyeAngles(client, vecAngles); vecAngles[0] = vecAngles[2] = 0.0;
	TeleportEntity(ent, vecOrigin, vecAngles, NULL_VECTOR);
	
	SetEntityRenderMode(ent, RENDER_NONE);
	ServerCommand("sm_effect_fading \"%i\" \"2.0\" \"0\"", ent);
	
	rp_HookEvent(client, RP_PrePlayerPhysic, fwdFrozen, 3.0);
	SetEntityMoveType(ent, MOVETYPE_NONE);
	
	CreateTimer(2.0, BuildingBarriere_post, ent);
	rp_SetBuildingData(ent, BD_owner, client);
	return ent;
}
public Action BuildingBarriere_post(Handle timer, any entity) {
	int client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	
	rp_Effect_BeamBox(client, entity, NULL_VECTOR, 255, 255, 0);
	
	SetEntProp(entity, Prop_Data, "m_takedamage", 2);
	HookSingleEntityOutput(entity, "OnBreak", BuildingBarriere_break);
	return Plugin_Handled;
}
public void BuildingBarriere_break(const char[] output, int caller, int activator, float delay) {
	
	int owner = GetEntPropEnt(caller, Prop_Send, "m_hOwnerEntity");
	if (IsValidClient(owner)) {
		CPrintToChat(owner, "{lightblue}[TSX-RP]{default} Votre barrière a été détruite.");
	}
}
// ----------------------------------------------------------------------------
public Action Cmd_ItemRatio(int args) {
	char arg1[12];
	GetCmdArg(1, arg1, sizeof(arg1));
	int client = GetCmdArgInt(2);
	
	if (StrEqual(arg1, "own")) {
		char steamid[64];
		GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid), false);
		displayTribunal(client, steamid);
	}
	else if (StrEqual(arg1, "gps")) {
		rp_ClientGiveItem(client, ITEM_GPS);
		CreateTimer(0.25, task_GPS, client);
	}
}
public Action task_GPS(Handle timer, any client) {
	Handle menu = CreateMenu(MenuTribunal_GPS);
	SetMenuTitle(menu, "  GPS\n ");
	char tmp[255], tmp2[255];
	
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsValidClient(i) || i == client)
			continue;
		
		Format(tmp, sizeof(tmp), "%d", i);
		Format(tmp2, sizeof(tmp2), "%N", i);
		
		AddMenuItem(menu, tmp, tmp2);
	}
	
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_DURATION);
}
public int MenuTribunal_GPS(Handle p_hItemMenu, MenuAction p_oAction, int client, int p_iParam2) {
	
	if (p_oAction == MenuAction_Select && client != 0) {
		char option[32];
		GetMenuItem(p_hItemMenu, p_iParam2, option, sizeof(option));
		int target = StringToInt(option);
		
		
		if (rp_GetClientItem(client, ITEM_GPS) <= 0) {
			CPrintToChat(target, "{lightblue}[TSX-RP]{default} Vous n'avez plus de GPS.");
			return;
		}
		
		rp_ClientGiveItem(client, ITEM_GPS, -1);
		
		if (Math_GetRandomInt(1, 100) < rp_GetClientInt(target, i_Cryptage) * 20) {
			
			CPrintToChat(target, "{lightblue}[TSX-RP]{default} Votre pot de vin envers un mercenaire vient de vous sauver.");
			CPrintToChat(client, "{lightblue}[TSX-RP]{default} Un pot de vin envers un mercenaire vient de le sauver...");
			
		}
		else {
			
			if (rp_GetClientInt(client, i_GPS) <= 0)
				CreateTimer(0.1, GPS_LOOP, client);
			rp_SetClientInt(client, i_GPS, target);
		}
	}
	else if (p_oAction == MenuAction_End) {
		CloseHandle(p_hItemMenu);
	}
}
public Action GPS_LOOP(Handle timer, any client) {
	
	if (!IsValidClient(client))
		return Plugin_Handled;
	
	int target = rp_GetClientInt(client, i_GPS);
	float vecOrigin[3], vecOrigin2[3];
	if (target == 0 || !IsValidClient(target)) {
		rp_SetClientInt(client, i_GPS, 0);
		return Plugin_Handled;
	}
	
	GetClientAbsOrigin(client, vecOrigin);
	GetClientAbsOrigin(target, vecOrigin2);
	
	if (GetVectorDistance(vecOrigin, vecOrigin2) <= 200.0) {
		rp_SetClientInt(client, i_GPS, 0);
		return Plugin_Handled;
	}
	
	ServerCommand("sm_effect_gps %d %d", client, target);
	CreateTimer(1.0, GPS_LOOP, client);
	return Plugin_Handled;
}
// ----------------------------------------------------------------------------
void displayTribunal(int client, const char szSteamID[64]) {
	char szURL[1024], szQuery[1024], steamid[64], sso[256];
	GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid), false);
	
	Format(szQuery, sizeof(szQuery), "INSERT INTO `rp_tribunal` (`uniqID`, `timestamp`, `steamid`) VALUES ('%s', '%i', '%s');", steamid, GetTime(), szSteamID);
	
	Handle DB = rp_GetDatabase();
	
	SQL_LockDatabase(DB);
	SQL_Query(DB, szQuery);
	SQL_UnlockDatabase(DB);
	
	rp_GetClientSSO(client, sso, sizeof(sso));
	
	Format(szURL, sizeof(szURL), "https://www.ts-x.eu/index.php?page=roleplay2%s#/tribunal/case/%s", sso, szSteamID);
	PrintToConsole(client, "https://www.ts-x.eu/index.php?page=roleplay2#/tribunal/case/%s", szSteamID);
	
	RP_ShowMOTD(client, szURL);
}
// ----------------------------------------------------------------------------

public Action fwdDmg(int attacker, int victim, float & damage) {
	if (!rp_GetClientBool(attacker, b_Stealing) && !rp_IsInPVP(attacker))
		rp_SetClientInt(attacker, i_LastAgression, GetTime());
	
	return Plugin_Continue;
}
public void Event_Weapon_Fire(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	char weapon[64];
	event.GetString("weapon", weapon, sizeof(weapon));
	if (StrContains(weapon, "weapon_flashbang") == 0 || StrContains(weapon, "weapon_smokegrenade") == 0 || 
		StrContains(weapon, "weapon_hegrenade") == 0 || StrContains(weapon, "weapon_incgrenade") == 0 || 
		StrContains(weapon, "weapon_molotov") == 0) {
		rp_SetClientInt(client, i_LastDangerousShot, GetTime());
	}
}
// ----------------------------------------------------------------------------
void StripWeapons(int client) {
	
	int wepIdx;
	
	for (int i = 0; i < 5; i++) {
		if (i == CS_SLOT_KNIFE)continue;
		
		while ((wepIdx = GetPlayerWeaponSlot(client, i)) != -1) {
			
			if (canWeaponBeAddedInPoliceStore(wepIdx))
				rp_WeaponMenu_Add(g_hBuyMenu, wepIdx, GetEntProp(wepIdx, Prop_Send, "m_OriginalOwnerXuidHigh"));
			
			RemovePlayerItem(client, wepIdx);
			RemoveEdict(wepIdx);
		}
	}
	
	FakeClientCommand(client, "use weapon_knife");
}

public Action fwdOnPlayerUse(int client) {
	float vecOrigin[3];
	
	GetClientAbsOrigin(client, vecOrigin);
	
	if (GetVectorDistance(vecOrigin, ARMU_POLICE) < 40.0) {
		Cmd_BuyWeapon(client, false);
	}
	return Plugin_Continue;
}
void Cmd_BuyWeapon(int client, bool free) {
	DataPackPos max = rp_WeaponMenu_GetMax(g_hBuyMenu);
	DataPackPos position = rp_WeaponMenu_GetPosition(g_hBuyMenu);
	char name[65], tmp[8], tmp2[129];
	int data[BM_Max];
	
	if (position >= max) {
		CPrintToChat(client, "{lightblue}[TSX-RP]{default} Désolé, aucune arme n'est disponible pour le moment.");
		return;
	}
	
	Menu menu = new Menu(Menu_BuyWeapon);
	menu.SetTitle("Armes trouvées par la police\n ");
	
	while (position < max) {
		
		rp_WeaponMenu_Get(g_hBuyMenu, position, name, data);
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
			case ball_type_fire : Format(tmp2, sizeof(tmp2), "%s Incendiaire", tmp2);
			case ball_type_caoutchouc : Format(tmp2, sizeof(tmp2), "%s Caoutchouc", tmp2);
			case ball_type_poison : Format(tmp2, sizeof(tmp2), "%s Poison", tmp2);
			case ball_type_vampire : Format(tmp2, sizeof(tmp2), "%s Vampirique", tmp2);
			case ball_type_paintball : Format(tmp2, sizeof(tmp2), "%s PaintBall", tmp2);
			case ball_type_reflexive : Format(tmp2, sizeof(tmp2), "%s Rebondissante", tmp2);
			case ball_type_explode : Format(tmp2, sizeof(tmp2), "%s Explosive", tmp2);
			case ball_type_revitalisante : Format(tmp2, sizeof(tmp2), "%s Revitalisante", tmp2);
			case ball_type_nosteal : Format(tmp2, sizeof(tmp2), "%s Anti-Vol", tmp2);
			case ball_type_notk : Format(tmp2, sizeof(tmp2), "%s Anti-TK", tmp2);
		}
		
		Format(tmp2, sizeof(tmp2), "%s pour %d$", tmp2, (free ? 0:data[BM_Prix]));
		menu.AddItem(tmp, tmp2);
		
		position = rp_WeaponMenu_GetPosition(g_hBuyMenu);
	}
	
	menu.Display(client, 60);
	return;
}
public int Menu_BuyWeapon(Handle p_hMenu, MenuAction p_oAction, int client, int p_iParam2) {
	if (p_oAction == MenuAction_Select) {
		
		char szMenu[64], buffer[2][32];
		if (GetMenuItem(p_hMenu, p_iParam2, szMenu, sizeof(szMenu))) {
			ExplodeString(szMenu, " ", buffer, sizeof(buffer), sizeof(buffer[]));
			
			char name[65];
			int data[BM_Max];
			DataPackPos position = view_as<DataPackPos>(StringToInt(buffer[0]));
			rp_WeaponMenu_Get(g_hBuyMenu, position, name, data);
			
			float vecOrigin[3];
			GetClientAbsOrigin(client, vecOrigin);
			
			if (GetVectorDistance(vecOrigin, ARMU_POLICE) > 40.0)
				return 0;
			
			if (StringToInt(buffer[1]) == 1) {
				rp_SetClientInt(client, i_LastVolAmount, 100 + data[BM_Prix]);
				data[BM_Prix] = 0;
			}
			
			if (rp_GetClientInt(client, i_Bank) < data[BM_Prix])
				return 0;
			
			Format(name, sizeof(name), "weapon_%s", name);
			int wepid = GivePlayerItem(client, name);
			rp_SetWeaponBallType(wepid, view_as<enum_ball_type>(data[BM_Type]));
			if (data[BM_PvP] > 0)
				rp_SetWeaponGroupID(wepid, rp_GetClientGroupID(client));
			
			if (data[BM_Munition] != -1) {
				Weapon_SetPrimaryClip(wepid, data[BM_Munition]);
				Weapon_SetPrimaryAmmoCount(wepid, data[BM_Chargeur]);
				Client_SetWeaponPlayerAmmoEx(client, wepid, data[BM_Chargeur]);
			}
			
			rp_WeaponMenu_Delete(g_hBuyMenu, position);
			rp_ClientMoney(client, i_Money, -data[BM_Prix]);
			
			int rnd = rp_GetRandomCapital(1);
			rp_SetJobCapital(1, RoundFloat(float(rp_GetJobCapital(1)) + float(data[BM_Prix]) * 0.75));
			rp_SetJobCapital(101, RoundFloat(float(rp_GetJobCapital(101)) + float(data[BM_Prix]) * 0.25));
			
			rp_SetJobCapital(rnd, rp_GetJobCapital(rnd) - data[BM_Prix]);
			LogToGame("[TSX-RP] [ITEM-VENDRE] %L a vendu 1 %s a %L", client, name, client);
			
			Call_StartForward(rp_GetForwardHandle(client, RP_OnBlackMarket));
			Call_PushCell(client);
			Call_PushCell(1);
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

void explainJail(int client, int jailReason) {
	
	if (StrContains(g_szJailRaison[jailReason][jail_raison], "Garde ") == 0) {
		rp_ClientOverlays(client, o_Jail_GAV, 10.0);
	}
	else if (StrContains(g_szJailRaison[jailReason][jail_raison], "Meurtre") == 0) {
		rp_ClientOverlays(client, o_Jail_Meurtre, 10.0);
	}
	else if (StrContains(g_szJailRaison[jailReason][jail_raison], "Agression ") == 0) {
		rp_ClientOverlays(client, o_Jail_Agression, 10.0);
	}
	else if (StrContains(g_szJailRaison[jailReason][jail_raison], "Intrusion ") == 0) {
		rp_ClientOverlays(client, o_Jail_Intrusion, 10.0);
	}
	else if (StrContains(g_szJailRaison[jailReason][jail_raison], "Vol, ") == 0) {
		rp_ClientOverlays(client, o_Jail_Vol, 10.0);
	}
	else if (StrContains(g_szJailRaison[jailReason][jail_raison], "Fuite, ") == 0) {
		rp_ClientOverlays(client, o_Jail_Refus, 10.0);
	}
	else if (StrContains(g_szJailRaison[jailReason][jail_raison], "Insultes, ") == 0) {
		rp_ClientOverlays(client, o_Jail_Insultes, 10.0);
	}
	else if (StrContains(g_szJailRaison[jailReason][jail_raison], "Trafique ") == 0) {
		rp_ClientOverlays(client, o_Jail_Traffic, 10.0);
	}
	else if (StrContains(g_szJailRaison[jailReason][jail_raison], "Nuisance ") == 0) {
		rp_ClientOverlays(client, o_Jail_Nuisance, 10.0);
	}
	else if (StrContains(g_szJailRaison[jailReason][jail_raison], "Tir dans ") == 0) {
		rp_ClientOverlays(client, o_Jail_Tir, 10.0);
	}
	else if (StrContains(g_szJailRaison[jailReason][jail_raison], "Conduite ") == 0) {
		rp_ClientOverlays(client, o_Jail_Conduite, 10.0);
	}
	else if (StrContains(g_szJailRaison[jailReason][jail_raison], "Mutinerie, ") == 0) {
		rp_ClientOverlays(client, o_Jail_Evasion, 10.0);
	}
}
bool canWeaponBeAddedInPoliceStore(int weaponID) {
	
	char classname[64];
	GetEdictClassname(weaponID, classname, sizeof(classname));
	if (StrContains(classname, "default") >= 0 || StrContains(classname, "knife") >= 0)
		return false;
	
	int index = GetEntProp(weaponID, Prop_Send, "m_iItemDefinitionIndex");
	CSGO_GetItemDefinitionNameByIndex(index, classname, sizeof(classname));
	if (StrContains(classname, "default") >= 0 || StrContains(classname, "knife") >= 0)
		return false;
	
	int owner = GetEntPropEnt(weaponID, Prop_Send, "m_hPrevOwner");
	if (IsValidClient(owner) && (rp_GetClientJobID(owner) == 1 || rp_GetClientJobID(owner) == 101))
		return false;
	owner = rp_WeaponMenu_GetOwner(weaponID);
	if (IsValidClient(owner) && (rp_GetClientJobID(owner) == 1 || rp_GetClientJobID(owner) == 101))
		return false;
	
	return true;
}
bool ZoneDeJailSansIntrusion(int zone) {
	if (zone == 13 || zone == 14 || zone == 15 || zone == 158 || zone == 87 || zone == 88 || zone == 89 || zone == 157)
		return true;
	return false;
}
