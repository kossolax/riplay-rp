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
#include <cstrike>
#include <sdkhooks>

#include <colors_csgo>	// https://forums.alliedmods.net/showthread.php?p=2205447#post2205447
#include <smlib>		// https://github.com/bcserv/smlib

#pragma newdecls required
#include <roleplay.inc>	// https://www.ts-x.eu

public Plugin myinfo = {
	name = "Jobs: Mercenaire", author = "KoSSoLaX",
	description = "RolePlay - Jobs: Mercenaire",
	version = __LAST_REV__, url = "https://www.ts-x.eu"
};

enum competance {
	competance_left = 0,
	competance_cut,
	competance_tir,
	competance_usp,
	competance_awp,
	competance_pompe,
	competance_invis,
	competance_hp,
	competance_vitesse,
	competance_cryo,
	competance_berserk,
	competance_bigmac,
	competance_cut_given,
	competance_type,
	competance_start,
	
	competance_max
};

bool g_bBlockDrop[65], g_bCanTP[65];
int g_iKillerPoint[65][view_as<int>(competance_max)];
int g_iKillerPoint_stored[65][view_as<int>(competance_max)];
int g_bShouldOpen[65];
float g_vecOriginTP[65][3];
int g_cBeam, g_cGlow;

Handle g_vCapture = INVALID_HANDLE;
Handle g_vConfigTueur = INVALID_HANDLE;
Handle g_hTimer[65];
Handle g_hActive;

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
	LoadTranslations("roleplay.mercenaire.phrases");
	LoadTranslations("roleplay.dealer.phrases");
	
	RegServerCmd("rp_quest_reload", Cmd_Reload);
	RegServerCmd("rp_item_contrat",		Cmd_ItemContrat,		"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_conprotect",	Cmd_ItemConProtect,		"RP-ITEM",	FCVAR_UNREGISTERED);
	
	RegServerCmd("rp_item_cryptage",	Cmd_ItemCryptage,		"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_map",			Cmd_ItemMaps,			"RP-ITEM",	FCVAR_UNREGISTERED);
	
	g_vConfigTueur = CreateConVar("rp_config_kidnapping", "208,209,210,211,219,220-221");
	g_hActive 		= CreateConVar("rp_kidnapping", "0");
	
	for (int i = 1; i <= MaxClients; i++)
		if( IsValidClient(i) )
			OnClientPostAdminCheck(i);
}
public void OnConfigsExecuted() {
	g_vCapture =  FindConVar("rp_capture");
	HookConVarChange(g_vCapture, OnCvarChange);
}
public void OnCvarChange(Handle cvar, const char[] oldVal, const char[] newVal) {
	if( cvar == g_vCapture ) {
		if( StrEqual(oldVal, "none") && StrEqual(newVal, "active") ) {
			for (int i = 1; i <= MaxClients; i++) {
				if( !IsValidClient(i) )
					continue;
				if( rp_GetClientInt(i, i_ToKill) > 0 ) {
					SetContratFail(i, true);
				}
			}
		}
	}
}
// ----------------------------------------------------------------------------
public void OnClientPostAdminCheck(int client) {
	rp_HookEvent(client, RP_OnPlayerBuild, fwdOnPlayerBuild);
	rp_HookEvent(client, RP_OnPlayerCommand, fwfCommand);
	rp_HookEvent(client, RP_OnFrameSeconde, fwdOnFrame);
	rp_HookEvent(client, RP_PostTakeDamageWeapon, fwdWeapon);
	
	g_bBlockDrop[client] = false;
	g_bCanTP[client] = false;
}
public void OnMapStart() {
	g_cBeam = PrecacheModel("materials/sprites/laserbeam.vmt", true);
	g_cGlow = PrecacheModel("materials/sprites/glow01.vmt", true);
}

public Action fwdOnFrame(int client) {
	if( g_bCanTP[client] ) {
		TE_SetupBeamRingPoint(g_vecOriginTP[client], 32.0, 33.0, g_cBeam, g_cGlow, 0, 0, 1.0, 8.0, 0.0, {200, 32, 32, 50}, 0, 0);
		TE_SendToClient(client);
	}
}

public Action fwdOnPlayerBuild(int client, float& cooldown) {
	if( rp_GetClientJobID(client) != 41 )
		return Plugin_Continue;
	if( g_bCanTP[client] ) {
		TeleportEntity(client, g_vecOriginTP[client], NULL_VECTOR, NULL_VECTOR);
		g_bCanTP[client] = false;
		
		cooldown = 30.0;
		return Plugin_Stop;
	}
	
	GetClientAbsOrigin(client, g_vecOriginTP[client]);
	g_bCanTP[client] = true;
	
	cooldown = 1.0;
	return Plugin_Stop;
}
public void OnClientDisconnect(int client) {
	if( rp_GetClientInt(client, i_ToKill) > 0 && rp_GetClientJobID(client) == 41 ) {
		SetContratFail(client);
	}
	
	g_bShouldOpen[client] = false;
	
	for(int i=1; i<=MaxClients; i++) {
		if( !IsValidClient(i) )
			continue;
			
		if( rp_GetClientInt(i, i_ToKill) == client  ) {
			if( rp_GetClientInt(client, i_KidnappedBy) == i ) {
				CPrintToChat(i, "" ...MOD_TAG... " %T", "Tueur_TargetLeft", i);
				RestoreAssassinNormal(i);
			}
			else {
				CPrintToChat(i, "" ...MOD_TAG... " %T", "Tueur_TargetLeft", i);
				SetContratFail(i, true);
			}
		}
	}
	
	clearKidnapping(client);
}
// ----------------------------------------------------------------------------
public Action Cmd_ItemContrat(int args) {
	
	char arg1[32];
	GetCmdArg(1, arg1, sizeof(arg1));
	
	int client = GetCmdArgInt(2);
	int target = GetCmdArgInt(3);
	int vendeur = GetCmdArgInt(4);
	int item_id = GetCmdArgInt(args);
	
	if( StrContains(arg1, "justice") == 0 ) {
		if( rp_GetClientJobID(client) != 101 && client != vendeur) {
			ITEM_CANCEL(client, item_id);
			return Plugin_Handled;
		}
	}
	
	rp_SetClientInt(target, i_ContratTotal, rp_GetClientInt(target, i_ContratTotal) + 1);
	if( rp_GetClientJobID(client) == 41 && rp_GetClientJobID(vendeur) )
		rp_SetClientInt(target, i_ContratTotal, rp_GetClientInt(target, i_ContratTotal) + 1);
	if( rp_GetClientBool(target, b_GameModePassive) )
		rp_SetClientInt(target, i_ContratTotal, rp_GetClientInt(target, i_ContratTotal) + 2);
	if( rp_IsClientNew(target) )
		rp_SetClientInt(target, i_ContratTotal, rp_GetClientInt(target, i_ContratTotal) + 2);
	
	switch( rp_GetClientInt(vendeur, i_Job) ) {
		case 41: g_iKillerPoint[vendeur][competance_left] = 6;
		case 42: g_iKillerPoint[vendeur][competance_left] = 6;
		case 43: g_iKillerPoint[vendeur][competance_left] = 5;
		case 44: g_iKillerPoint[vendeur][competance_left] = 5;
		case 45: g_iKillerPoint[vendeur][competance_left] = 4;
		case 46: g_iKillerPoint[vendeur][competance_left] = 4;
		case 47: g_iKillerPoint[vendeur][competance_left] = 3;					
		default: g_iKillerPoint[vendeur][competance_left] = 0;
	}
	
	rp_SetClientInt(vendeur, i_ToKill, target);
	rp_SetClientInt(vendeur, i_ContratFor, client);

	rp_HookEvent(vendeur, RP_OnPlayerDead, fwdTueurDead);
	rp_HookEvent(vendeur, RP_PlayerCanKill, fwdTueurCanKill);
	rp_HookEvent(target, RP_PlayerCanKill, fwdTueurCanKill);
	rp_HookEvent(target, RP_OnPlayerDead, fwdTueurKill);
	rp_HookEvent(vendeur, RP_OnFrameSeconde, fwdFrame);
	rp_HookEvent(vendeur, RP_PreGiveDamage, fwdDamage);
	rp_HookEvent(vendeur, RP_OnPlayerCheckKey, fwdOnKey);
	
	rp_SetClientStat(vendeur, i_JobFails, rp_GetClientStat(client, i_JobFails) - 1);
	g_bBlockDrop[vendeur] = true;
	
	
	if( StrContains(arg1, "classic") == 0 ) {
		g_iKillerPoint[vendeur][competance_type] = 1001;
	}
	else if( StrContains(arg1, "sick") == 0 ) {
		g_iKillerPoint[vendeur][competance_type] = 1002;
	}
	else if( StrContains(arg1, "pvp") == 0 ) {
		g_iKillerPoint[vendeur][competance_type] = 1003;
	}
	else if( StrContains(arg1, "justice") == 0 ) {
		g_iKillerPoint[vendeur][competance_type] = 1004;
	}
	else if( StrContains(arg1, "kidnapping") == 0 ) {
		g_iKillerPoint[vendeur][competance_type] = 1005;
		rp_SetClientInt(target, i_ContratTotal, rp_GetClientInt(target, i_ContratTotal) + 10);
	}
	else if( StrContains(arg1, "lupin") == 0 ) {
		g_iKillerPoint[vendeur][competance_type] = 1006;
		rp_SetClientInt(target, i_ContratTotal, rp_GetClientInt(target, i_ContratTotal) + 10);
	}
	else if( StrContains(arg1, "freekill") == 0 ) {
		g_iKillerPoint[vendeur][competance_type] = 1007;
	}
	else if( StrContains(arg1, "alzheimer") == 0 ) {
		g_iKillerPoint[vendeur][competance_type] = 1008;
		rp_SetClientInt(target, i_ContratTotal, rp_GetClientInt(target, i_ContratTotal) + 10);
	}
	else if( StrContains(arg1, "vengance") == 0 ) {
		g_iKillerPoint[vendeur][competance_type] = 1009;
	}
	
	rp_SetClientInt(vendeur, i_ContratType, g_iKillerPoint[vendeur][competance_type]);
	g_iKillerPoint[vendeur][competance_start] = GetTime();
	
	OpenSelectSkill(vendeur);
	
	if( !IsValidClient(target) ) {
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Tueur_TargetLeft", client);
		SetContratFail(client);
	}
	return Plugin_Handled;
}
// ----------------------------------------------------------------------------
public Action fwdOnKey(int client, int doorID, int lockType) {
	if( lockType == 2 && g_iKillerPoint[client][competance_type] == 1004 && g_iKillerPoint[client][competance_start]+(6*60) < GetTime() ) {
		int victim = rp_GetClientInt(client, i_ToKill);
		
		float pos[3];
		Entity_GetAbsOrigin(doorID, pos);		
		
		char clientZone[64], targetZone[64];
		rp_GetZoneData(rp_GetZoneFromPoint(pos), zone_type_type, clientZone, sizeof(clientZone));
		rp_GetZoneData(rp_GetPlayerZone(victim), zone_type_type, targetZone, sizeof(targetZone));
		
		if( StrEqual(targetZone, "bunker") || StrEqual(targetZone, "villa") || StrEqual(targetZone, "mairie") ) {
			if( StrEqual(clientZone, targetZone) ) 
				return Plugin_Changed;
		}
		else if( StrContains(clientZone, "appart_") == 0 && StrContains(targetZone, "appart_") == 0 ) {
			ReplaceString(clientZone, sizeof(clientZone), "appart_", "");
			ReplaceString(targetZone, sizeof(targetZone), "appart_", "");
			if( StringToInt(clientZone) == StringToInt(targetZone) )
				return Plugin_Changed;
		}
		else if( StringToInt(clientZone) == StringToInt(targetZone) ) {
			return Plugin_Changed;
		}
		
	}
	
	return Plugin_Continue;
}
public Action fwdTueurCanKill(int attacker, int victim) {
	if( victim == rp_GetClientInt(attacker, i_ToKill) || attacker == rp_GetClientInt(victim, i_ToKill) )
		return Plugin_Handled;

	if( rp_GetClientJobID(attacker) == 41 && rp_GetZoneInt(rp_GetPlayerZone(victim), zone_type_type) == 41 )
		return Plugin_Handled;
	
	return Plugin_Continue;
}
public Action fwdFrame(int client) {
	int target = rp_GetClientInt(client, i_ToKill);
	char tmp[128];
	
	if( !IsValidClient(target) ) {
		SetContratFail(client);
	}
	else if(rp_GetClientJobID(client) != 41) {
		SetContratFail(client);
	}
	else {
		rp_GetZoneData(rp_GetPlayerZone(target), zone_type_name, tmp, sizeof(tmp));
		rp_Effect_BeamBox(client, target, NULL_VECTOR, 255, 0, 0);
		
		char target_name[128];
		GetClientName2(target, target_name, sizeof(target_name), false);
		PrintHintText(client, "%T", "Tueur_TargetHint", client, target_name, tmp);
	}
	
	return Plugin_Continue;
}
public Action TaskResetAttacker(Handle timer, any attacker) {
	if( IsValidClient(attacker) )
		rp_SetClientInt(attacker, i_LastKilled_Reverse, 0);
}
public Action TaskResetVictim(Handle timer, any client) {
	if( IsValidClient(client) )
		rp_SetClientInt(client, i_LastKilled, 0);
}
public Action fwdTueurKill(int client, int attacker, float& respawn, int& tdm, float& ctx) {
	if( rp_GetClientInt(attacker, i_ToKill) == client && rp_GetClientInt(client, i_KidnappedBy) != attacker ) {
		rp_SetClientStat(attacker, i_JobSucess, rp_GetClientStat(client, i_JobSucess) + 1);
		rp_SetClientStat(attacker, i_JobFails, rp_GetClientStat(client, i_JobFails) - 1);
		
		char client_name[128], target_name[128];
		GetClientName2(client, client_name, sizeof(client_name), false);
		GetClientName2(attacker, target_name, sizeof(target_name), false);
		

		CPrintToChat(attacker, "" ...MOD_TAG... " %T", "Tueur_ContratDone_Self", attacker, client_name);
		
		int from = rp_GetClientInt(attacker, i_ContratFor);
		bool kidnapping = false;
		
		CreateTimer(0.1, TaskResetAttacker, attacker);
		CreateTimer(0.1, TaskResetVictim, client);		
		
		if( IsValidClient(from) ) {
			
			if( rp_GetClientJobID(from) != 41 ) {
				rp_ClientXPIncrement(attacker, 100);
				
				int rnd = rp_GetRandomCapital(41);
				rp_SetJobCapital(rnd, rp_GetJobCapital(rnd) - 200);
				rp_SetJobCapital(41, rp_GetJobCapital(41) + 200);
			}
			
			CPrintToChat(from, "" ...MOD_TAG... " %T", "Tueur_ContratDone_Target", from, target_name, client_name);
			rp_IncrementSuccess(from, success_list_tueur);
			
			
			if( g_iKillerPoint[attacker][competance_type] == 1002 ) {
				if( !rp_GetClientBool(client, b_HasProtImmu) ) {
					if( !(rp_GetClientJobID(client) == 11 && rp_GetClientBool(client, b_GameModePassive) == false) && rp_GetClientInt(client, i_Sick) == 0 ) {
						CPrintToChat(client, ""...MOD_TAG..." %T", "Drug_Fatal", client);
						rp_SetClientInt(client, i_Sick, Math_GetRandomInt((view_as<int>(sick_type_none))+1, (view_as<int>(sick_type_max))-1));
					}
				}
			}
			if( g_iKillerPoint[attacker][competance_type] == 1003 ) {
				int gFrom = rp_GetClientGroupID(from);
				int gVictim = rp_GetClientGroupID(client);
				
				if( gFrom != 0 && gVictim != 0 && gVictim != gFrom ) {
					char query[1024], szSteamID[32], szSteamID2[32];

					GetClientAuthId(from, AUTH_TYPE, szSteamID, sizeof(szSteamID), false);
					GetClientAuthId(client, AUTH_TYPE, szSteamID2, sizeof(szSteamID2), false);

					Format(query, sizeof(query), "INSERT INTO `rp_pvp` (`id`, `group_id`, `steamid`, `steamid2`, `time`, `time2`) VALUES (NULL, '%i', '%s', '%s', '%i', '%i');",
						gFrom, szSteamID, szSteamID2, 1, 1 );

					SQL_TQuery(rp_GetDatabase(), SQL_QueryCallBack, query, 0, DBPrio_Low);

					rp_IncrementSuccess(from, success_list_in_gang);
				}
			}
			else if( g_iKillerPoint[attacker][competance_type] == 1004 ) {
				respawn = 0.05;
				if( rp_GetClientBool(client, b_IsSearchByTribunal) ) {
					rp_SetClientBool(client, b_SpawnToTribunal, true);
					rp_HookEvent(client, RP_OnPlayerSpawn, fwdOnRespawn);
				}
			}
			else if( g_iKillerPoint[attacker][competance_type] == 1005 ) {
				rp_SetClientInt(client, i_ToPay, from);
				rp_SetClientInt(client, i_KidnappedBy, attacker);
				rp_SetClientBool(client, b_SpawnToTueur, true);
				rp_HookEvent(client, RP_OnPlayerSpawn, fwdOnRespawn);
				respawn = 0.05;				
				kidnapping = true;
				SetConVarInt(g_hActive, 1);
				changeZoneState(41, true);
				
				rp_ClientFloodIncrement(0, client, fd_kidnapping, 6.0*60.0);
			}
			else if( g_iKillerPoint[attacker][competance_type] == 1006 ) {
				if( rp_GetClientBool(client, b_HaveCard) == true ){
					rp_SetClientBool(client, b_HaveCard, false);
					CPrintToChat(client, "" ...MOD_TAG... " %T", "Tueur_Lupin", client);
				}
				respawn *= 1.25;			
			}
			else if( g_iKillerPoint[attacker][competance_type] == 1007 ) {
				int mnt;
				
				for(int i=0; i<MAX_ITEMS; i++) {
					mnt = rp_GetClientItem(client, i);
					
					if( mnt ) {
						rp_ClientGiveItem(client, i, mnt, true);
						rp_ClientGiveItem(client, i, -mnt, false);
					}
				}
				respawn *= 4.0;			
			}
			else if( g_iKillerPoint[attacker][competance_type] == 1008 ) {
				CPrintToChat(client, "" ...MOD_TAG... " %T", "Tueur_Alzheimer", client);
				rp_SetClientInt(client, i_AlzheimerTime, GetTime() + (4*60));
				respawn *= 2.0;
			}
			else {
				respawn *= 1.25;
			}
		}
		
		if( !kidnapping )
			RestoreAssassinNormal(attacker);
		
		return Plugin_Handled; // On retire des logs
	}
	return Plugin_Continue;
}
public Action fwdOnRespawn(int client) {
	if( rp_GetClientBool(client, b_SpawnToTueur) ) {
		CreateTimer(0.01, SendToTueur, client);
	}
	if( rp_GetClientBool(client, b_SpawnToTribunal) ) {
		CreateTimer(0.01, SendToTribunal, client);
	}
}
public Action fwdTueurDead(int client, int attacker, float& respawn, int& tdm, float& ctx) {
	int target = rp_GetClientInt(client, i_ToKill);
	if( target > 0  && attacker == target) { // Double check.
		SetContratFail(client);
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}
public Action CS_OnCSWeaponDrop(int client, int weapon) {
	
	if( rp_GetClientJobID(client) == 41 && g_bBlockDrop[client] && (g_iKillerPoint[client][competance_usp] || g_iKillerPoint[client][competance_awp] || g_iKillerPoint[client][competance_pompe]) ) {
		return Plugin_Handled;
	}

	return Plugin_Continue;
}
public Action fwdDamage(int client, int victim, float& damage, int damagetype) {
	
	int target = rp_GetClientInt(client, i_ToKill);
	
	if( target > 0 && target == victim ) {
		if( !rp_IsTargetSeen(victim, client) )
			damage *= 2.0;
		if( !rp_IsClientNew(victim) )
			damage *= 2.0;
		
		return Plugin_Changed;
	}
	/*else if( target > 0 && target != victim ) {
		if( rp_GetClientJobID(client) == 41 && rp_GetZoneInt(rp_GetPlayerZone(victim), zone_type_type) == 41 )
			return Plugin_Continue;
			
			damage /= 3.0;
			return Plugin_Changed;
		}
	}*/
		
	return Plugin_Continue;
}
public Action fwdSpeed(int client, float& speed, float& gravity) {
	speed += 0.5;
	return Plugin_Changed;
}
// ----------------------------------------------------------------------------
public Action Cmd_ItemConProtect(int args) {
	
	int client = GetCmdArgInt(1);
	int vendeur = GetCmdArgInt(2);
	
	rp_SetClientInt(client, i_Protect_From, vendeur);
	rp_SetClientInt(vendeur, i_Protect_Him, client);
	
	GivePlayerItem(client, "weapon_taser");
	GivePlayerItem(vendeur, "weapon_taser");
	
	CreateTimer(6*60.0, TimerEndProtect, client);
}
public Action TimerEndProtect(Handle timer, any client) {
	
	int vendeur = rp_GetClientInt(client, i_Protect_From);
	
	CPrintToChat(client, "" ...MOD_TAG... " %T", "Tueur_ProtectOver", client); // Félicitations si réussi ? Votre client est mort,dommage. si raté ?
	CPrintToChat(vendeur, "" ...MOD_TAG... " %T", "Tueur_ProtectOver", vendeur);
	
	rp_SetClientInt(client, i_Protect_From, 0);
	rp_SetClientInt(vendeur, i_Protect_Him, 0);
	
}
// ----------------------------------------------------------------------------
public Action fwfCommand(int client, char[] command, char[] arg) {	
	if( StrEqual(command, "tueur") || StrEqual(command, "skill") ) { // C'est pour nous !
		if( rp_GetClientJobID(client) == 41 ) {
			OpenSelectSkill(client);
		}
		return Plugin_Stop;
	}
	return Plugin_Continue;
}
void OpenSelectSkill(int client) {
	
	char tmp[256];
	int target = rp_GetClientInt(client, i_ToKill);

	if( target == 0 ) return;
	
	Format(tmp, sizeof(tmp), "%T", "Tueur_Menu", client, g_iKillerPoint[client][competance_left]);
	
	Handle menu = CreateMenu(AddCompetanceToAssassin);
	SetMenuTitle(menu, tmp);

	if( IsValidClient(target) && g_iKillerPoint[client][competance_left] > 0 ) {
		Format(tmp, sizeof(tmp), "%T", "Tueur_Menu_Knife", client);					AddMenuItem(menu, "cut", tmp, g_iKillerPoint[client][competance_cut] ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		Format(tmp, sizeof(tmp), "%T", "Tueur_Menu_Weapon", client);				AddMenuItem(menu, "tir", tmp, g_iKillerPoint[client][competance_tir]);
		Format(tmp, sizeof(tmp), "%T", "Tueur_Menu_Weapon_M4_USP", client);			AddMenuItem(menu, "usp", tmp, (g_iKillerPoint[client][competance_usp] || g_iKillerPoint[client][competance_pompe] || g_iKillerPoint[client][competance_awp]) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		Format(tmp, sizeof(tmp), "%T", "Tueur_Menu_Weapon_AWP_CZ75", client);		AddMenuItem(menu, "awp", tmp, (g_iKillerPoint[client][competance_usp] || g_iKillerPoint[client][competance_pompe] || g_iKillerPoint[client][competance_awp]) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		Format(tmp, sizeof(tmp), "%T", "Tueur_Menu_Weapon_NOVA_DEAGLE", client);	AddMenuItem(menu, "pompe", tmp, (g_iKillerPoint[client][competance_usp] || g_iKillerPoint[client][competance_pompe] || g_iKillerPoint[client][competance_awp]) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		Format(tmp, sizeof(tmp), "%T", "Tueur_Menu_Invisible", client);				AddMenuItem(menu, "inv", tmp, g_iKillerPoint[client][competance_invis] ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		Format(tmp, sizeof(tmp), "%T", "Tueur_Menu_Vie", client);					AddMenuItem(menu, "vie", tmp, g_iKillerPoint[client][competance_hp] ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		Format(tmp, sizeof(tmp), "%T", "Tueur_Menu_Vitesse", client);				AddMenuItem(menu, "vit", tmp, g_iKillerPoint[client][competance_vitesse] ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		
		
		rp_GetItemData(ITEM_BERSERK, item_type_name, tmp, sizeof(tmp));
		AddMenuItem(menu, "berserk", tmp, g_iKillerPoint[client][competance_berserk] ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		
		rp_GetItemData(ITEM_BIGMAC, item_type_name, tmp, sizeof(tmp));
		AddMenuItem(menu, "bigmac", tmp, g_iKillerPoint[client][competance_bigmac] ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		
		if(g_iKillerPoint[client][competance_type] == 1005) {
			rp_GetItemData(ITEM_NANO_CRYO, item_type_name, tmp, sizeof(tmp));
			AddMenuItem(menu, "nano", tmp, g_iKillerPoint[client][competance_cryo] ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		}
	}
	
	Format(tmp, sizeof(tmp), "%T", "Tueur_Menu_Cancel", client);
	AddMenuItem(menu, "annule", tmp);
	
	DisplayMenu(menu, client, MENU_TIME_DURATION);
}
public int AddCompetanceToAssassin(Handle menu, MenuAction action, int client, int param2) {
	if( action == MenuAction_Select ) {
		char options[64];
		GetMenuItem(menu, param2, options, 63);
		
		if( !IsPlayerAlive(client) ) {
			OpenSelectSkill(client);
			return;
		}
		
		if( StrEqual(options, "annule", false) ) {
			LogToGame("[CONTRAT] %L a annulé son contrat.", client);
			SetContratFail(client, false, true);
		}
		else if( g_iKillerPoint[client][competance_left] <= 0 ) {
			return;
		}
		else if( StrEqual(options, "cut", false) ) {
			g_iKillerPoint[client][competance_cut] = 1;
			g_iKillerPoint_stored[client][competance_cut] = rp_GetClientInt(client, i_KnifeTrain);
			int knife = GivePlayerItem(client, "weapon_knife");
			EquipPlayerWeapon(client, knife);
			rp_SetClientInt(client, i_KnifeTrain, 100);
		}
		else if( StrEqual(options, "tir", false) ) {
			g_iKillerPoint[client][competance_tir] = 1;
			g_iKillerPoint_stored[client][competance_tir] = RoundToCeil( rp_GetClientFloat(client, fl_WeaponTrain) );
			rp_SetClientFloat(client, fl_WeaponTrain, 10.0);
		}
		else if( StrEqual(options, "usp", false) || StrEqual(options, "awp", false) || StrEqual(options, "pompe", false) ) {
			
			if( rp_GetZoneBit( rp_GetPlayerZone(client) ) & BITZONE_JAIL || rp_GetZoneBit( rp_GetPlayerZone(client) ) & BITZONE_LACOURS || rp_GetZoneBit( rp_GetPlayerZone(client) ) & BITZONE_HAUTESECU )
				return;
			
			int wepIdx;
			
			for( int i = 0; i < 5; i++ ){
				if( i == CS_SLOT_KNIFE ) continue; 
				if( i == CS_SLOT_GRENADE ) continue;
				
				while( ( wepIdx = GetPlayerWeaponSlot( client, i ) ) != -1 ){
					RemovePlayerItem( client, wepIdx );
					RemoveEdict( wepIdx );
				}
			}
			if( StrEqual(options, "usp", false) ){
				g_iKillerPoint[client][competance_usp] = 1;
				
				GivePlayerItem(client, "weapon_usp_silencer");
				GivePlayerItem(client, "weapon_m4a1_silencer");
			}
			else if( StrEqual(options, "awp", false) ){
				g_iKillerPoint[client][competance_awp] = 1;
				
				GivePlayerItem(client, "weapon_cz75a");
				GivePlayerItem(client, "weapon_awp");
			}
			else if( StrEqual(options, "pompe", false) ){
				g_iKillerPoint[client][competance_pompe] = 1;
				
				GivePlayerItem(client, "weapon_deagle");
				GivePlayerItem(client, "weapon_nova");
			}
		}
		else if( StrEqual(options, "inv", false) ) {
			g_iKillerPoint[client][competance_invis] = 1;
			SetEntPropFloat(client, Prop_Send, "m_fadeMinDist", 0.0);
			SetEntPropFloat(client, Prop_Send, "m_fadeMaxDist", 300.0);
			SDKHook(client, SDKHook_PostThinkPost, OnPostThinkPost);
			
		}
		else if( StrEqual(options, "vie", false) ) {
			g_iKillerPoint[client][competance_hp] = 1;
			g_iKillerPoint_stored[client][competance_hp] = GetClientHealth(client);
			SetEntityHealth(client, 500);
			rp_SetClientInt(client, i_Kevlar, 250);
		}
		else if( StrEqual(options, "vit", false) ) {
			g_iKillerPoint[client][competance_vitesse] = 1;
			rp_HookEvent(client, RP_PrePlayerPhysic, fwdSpeed);
		}
		else if( StrEqual(options, "nano", false) ) {
			g_iKillerPoint[client][competance_cryo] = 1;
			ServerCommand("rp_item_nano cryo %d 0", client);
		}
		else if( StrEqual(options, "berserk", false) ) {
			g_iKillerPoint[client][competance_berserk] = 1;
			ServerCommand("rp_item_adrenaline %d 0", client);
		}
		else if( StrEqual(options, "bigmac", false) ) {
			g_iKillerPoint[client][competance_bigmac] = 1;
			ServerCommand("rp_item_hamburger mac %d 0", client);
		}
		
		g_iKillerPoint[client][competance_left]--;
		
		if( rp_GetClientInt(client, i_ToKill) > 0 )
			OpenSelectSkill(client);
	}
	else if (action == MenuAction_End) {
		CloseHandle(menu);
	}
}
public void OnPostThinkPost(int client) {
	if( IsPlayerAlive(client) )
		SetEntProp(client, Prop_Send, "m_iAddonBits", 0);
}
// ----------------------------------------------------------------------------
void RestoreAssassinNormal(int client) {
	
	LogToGame("[CONTRAT] RestoreAssassinNormal: %L", client);
	
	g_iKillerPoint[client][competance_left] = 0;
	rp_SetClientInt(client, i_ContratType, 0);
	
	if( g_iKillerPoint[client][competance_cut] ) {
		rp_SetClientInt(client, i_KnifeTrain, g_iKillerPoint_stored[client][competance_cut]);
		if( Client_RemoveWeapon(client, "weapon_knife") )
			rp_SetClientBool(client, b_WeaponIsKnife, false);
	}
	if( g_iKillerPoint[client][competance_tir] ) {
		rp_SetClientFloat(client, fl_WeaponTrain, float(g_iKillerPoint_stored[client][competance_tir]));
	}
	if( g_iKillerPoint[client][competance_invis] ) {
		SetEntPropFloat(client, Prop_Send, "m_fadeMinDist", 0.0);
		SetEntPropFloat(client, Prop_Send, "m_fadeMaxDist", -1.0);
		SDKUnhook(client, SDKHook_PostThinkPost, OnPostThinkPost);
	}
	if( g_iKillerPoint[client][competance_usp] || g_iKillerPoint[client][competance_awp] || g_iKillerPoint[client][competance_pompe] ) {
		
		int wepIdx;
		
		for( int i = 0; i < 5; i++ ){
			if( i == CS_SLOT_KNIFE ) continue; 
			if( i == CS_SLOT_GRENADE ) continue;
			
			while( ( wepIdx = GetPlayerWeaponSlot( client, i ) ) != -1 ){
				RemovePlayerItem( client, wepIdx );
				RemoveEdict( wepIdx );
			}
		}
		
		FakeClientCommand(client, "use weapon_fists");
	}
	if( g_iKillerPoint[client][competance_vitesse] ) {
		rp_UnhookEvent(client, RP_PrePlayerPhysic, fwdSpeed);
	}
	
	g_iKillerPoint[client][competance_cut] = 0;
	g_iKillerPoint[client][competance_tir] = 0;
	g_iKillerPoint[client][competance_usp] = 0;
	g_iKillerPoint[client][competance_awp] = 0;
	g_iKillerPoint[client][competance_pompe] = 0;
	g_iKillerPoint[client][competance_invis] = 0;
	g_iKillerPoint[client][competance_hp] = 0;
	g_iKillerPoint[client][competance_vitesse] = 0;
	g_iKillerPoint[client][competance_cryo] = 0;
	g_iKillerPoint[client][competance_berserk] = 0;
	g_bBlockDrop[client] = false;

	rp_UnhookEvent(client, RP_OnPlayerDead, fwdTueurDead);
	rp_UnhookEvent(client, RP_PlayerCanKill, fwdTueurCanKill);
	rp_UnhookEvent(rp_GetClientInt(client, i_ToKill), RP_PlayerCanKill, fwdTueurCanKill);
	
	rp_UnhookEvent(client, RP_OnFrameSeconde, fwdFrame);
	rp_UnhookEvent(client, RP_PreGiveDamage, fwdDamage);
	rp_UnhookEvent(client, RP_OnPlayerCheckKey, fwdOnKey);
	
	rp_UnhookEvent( rp_GetClientInt(client, i_ToKill), RP_OnPlayerDead, fwdTueurKill);
	
	rp_SetClientInt(client, i_ToKill, 0);
	rp_SetClientInt(client, i_ContratFor, 0);
	
	rp_ClientColorize(client);
}
void SetContratFail(int client, bool time = false, bool annule = false) { // time = retro-compatibilité. 
	
	int target = rp_GetClientInt(client, i_ContratFor);
	int victim = rp_GetClientInt(client, i_ToKill);
	int jobClient = rp_GetClientJobID(client);
	
	LogToGame("[CONTRAT] SetContratFail: %L %d %d.", client, time, annule);
	if( IsValidClient(target) )
		LogToGame("[CONTRAT] SetContratFail-target: %L.", target);
	if( IsValidClient(victim) )
		LogToGame("[CONTRAT] SetContratFail-victim: %L.", victim);
	
	
	if( time )
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Tueur_Fail_Time", client);
	else if( jobClient != 41 ) // si le tueur a démissionné entre temps
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Tueur_Fail_Cancel", client);
	else if(annule)
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Tueur_Fail_Cancel", client);
	else
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Tueur_Fail_Lost", client);
	
	
	if(target != client){
		if( IsValidClient(target) ) {		
			char client_name[128];
			GetClientName2(client, client_name, sizeof(client_name), false);
			
			if( time )
				CPrintToChat(target, "" ...MOD_TAG... " %T", "Tueur_Fail_Time_Target", target, client_name);
			else if( jobClient != 41 ) // si le tueur a démissionné entre temps
				CPrintToChat(target, "" ...MOD_TAG... " %T", "Tueur_Fail_Cancel_Target", target, client_name);
			else if(annule)
				CPrintToChat(target, "" ...MOD_TAG... " %T", "Tueur_Fail_Cancel_Target", target, client_name);
			else
				CPrintToChat(target, "" ...MOD_TAG... " %T", "Tueur_Fail_Lost_Target", target, client_name);
			
			
			int prix = rp_GetClientInt(client, i_ContratPay);
			float reduc = float(prix) / 100.0 * float(rp_GetClientInt(client, i_Reduction));

			int partmercenaire = RoundFloat(((float(prix) * 0.2) - reduc));
			int partcapital = RoundFloat(float(prix) * 0.8);
			
			rp_ClientMoney(target, i_Bank, prix-RoundFloat(reduc));
			rp_ClientMoney(client, i_AddToPay, -partmercenaire);
			
			rp_SetJobCapital(41, rp_GetJobCapital(41) - partcapital);
			
			Call_StartForward(rp_GetForwardHandle(client, RP_OnPlayerSell));
			Call_PushCell(client);
			Call_PushCell(-prix);
			Call_Finish();
		}
		else {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Tueur_Client_Disconnect", client);
		}
	}
	
	
	RestoreAssassinNormal(client);
	rp_SetClientInt(victim, i_ContratTotal, rp_GetClientInt(victim, i_ContratTotal) - 1);
}
// ----------------------------------------------------------------------------
public Action SendToTribunal(Handle timer, any client) {
	
	rp_SetClientBool(client, b_SpawnToTribunal, false);
	
	if( Math_GetRandomInt(0, 1) )
		rp_ClientTeleport(client, view_as<float>({473.0, -1979.0, -1950.0}));
	else
		rp_ClientTeleport(client, view_as<float>({-966.0, -570.0, -1950.0}));
}
// ----------------------------------------------------------------------------
public Action SendToTueur(Handle timer, any client) {
	
	rp_SetClientBool(client, b_SpawnToTueur, false);
	rp_ClientTeleport(client,  view_as<float>({-5553.0, -2818.0, -1958.0}));
	
	char classname[64];
	for(int i=MaxClients; i<=2048; i++) {
		if( !IsValidEdict(i) )
			continue;
		if( !IsValidEntity(i) )
			continue;
			
		
		GetEdictClassname(i, classname, sizeof(classname));
		
		if( StrContains(classname, "door") != -1 &&
			rp_GetZoneInt(rp_GetPlayerZone(i, 60.0) , zone_type_type) == 41
			) {
			rp_AcceptEntityInput(i, "Close");
			rp_ScheduleEntityInput(i, 0.01, "Lock");
		}
	}
	int mnt;
	
	for(int i=0; i<MAX_ITEMS; i++) {
		mnt = rp_GetClientItem(client, i);
		
		if( mnt ) {
			rp_ClientGiveItem(client, i, mnt, true);
			rp_ClientGiveItem(client, i, -mnt, false);
		}
	}
	
	CPrintToChat(client, "" ...MOD_TAG... " %T", "Tueur_Kidnapping", client);
	
	g_hTimer[client] = CreateTimer(6*60.0, FreeKidnapping, client);
	rp_HookEvent(client, RP_OnPlayerZoneChange, fwdZoneChange);
	rp_HookEvent(client, RP_OnPlayerDead, fwdDead);
	rp_HookEvent(client, RP_OnFrameSeconde, fwdFrameKidnap);
	g_bShouldOpen[client] = true;
	
	OpenKidnappingMenu(client);
}
void clearKidnapping(int client) {
	LogToGame("[CONTRAT] clearKidnapping: %L", client);
	
	if( rp_GetClientInt(client, i_KidnappedBy) > 0 ) {		
		SetConVarInt(g_hActive, 0);
		changeZoneState(41, false);
		
		rp_UnhookEvent(client, RP_OnPlayerZoneChange, fwdZoneChange);
		rp_UnhookEvent(client, RP_OnPlayerDead, fwdDead);
		rp_UnhookEvent(client, RP_OnFrameSeconde, fwdFrame);
	
		rp_SetClientInt(client, i_KidnappedBy, 0);
		KillTimer(g_hTimer[client]);
		g_hTimer[client] = null;
		g_bShouldOpen[client] = false;
	}
}
public Action fwdZoneChange(int client, int newZone, int oldZone) {
	int newType = rp_GetZoneInt(newZone, zone_type_type);
	int oldType = rp_GetZoneInt(oldZone, zone_type_type);
	
	if( oldType == 41 && newType != 41 ) {
		float vecDest[3] =  { -3876.0, -2550.7, -2007.9 };
		float vecOrigin[3];
		GetClientAbsOrigin(client, vecOrigin);
		
		if( GetVectorDistance(vecDest, vecOrigin) < 128.0 ) {
			int target = rp_GetClientInt(client, i_KidnappedBy);
			clearKidnapping(client);
			
			rp_SetClientInt( target, i_ContratFor, rp_GetClientInt(client, i_ToPay) );
			SetContratFail( target , true);
			
			char client_name[128];
			GetClientName2(client, client_name, sizeof(client_name), false);
			
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Tueur_Kidnapping_Free", client);
			CPrintToChat(target, "" ...MOD_TAG... " %T", "Tueur_Kidnapping_Free_Target", target, client_name);
		}
		else {
			rp_ClientTeleport(client,  view_as<float>({-5553.9, -2838.9, -1959.9}));
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_FromServer", client);			
		}
	}
}
public Action fwdDead(int client, int attacker, float& respawn, int& tdm, float& ctx) {
	int target = rp_GetClientInt(client, i_KidnappedBy);
	clearKidnapping(client);
	
	rp_SetClientInt(target, i_ContratFor, rp_GetClientInt(client, i_ToPay) );
	SetContratFail( target , true);
	
	char client_name[128];
	GetClientName2(client, client_name, sizeof(client_name), false);
	CPrintToChat(client, "" ...MOD_TAG... " %T", "Tueur_Kidnapping_Free", client);
	CPrintToChat(target, "" ...MOD_TAG... " %T", "Tueur_Kidnapping_Free_Target", target, client_name);
	
	return Plugin_Continue;
}
public Action FreeKidnapping(Handle timer, any client) {
	if( g_hTimer[client] == null )
		return Plugin_Handled;
	
	int target = rp_GetClientInt(client, i_KidnappedBy);
	clearKidnapping(client);
	RestoreAssassinNormal(target);
	rp_ClientTeleport(client,  view_as<float>({2911.0, 868.0, -1853.0}));
	rp_ClientSendToSpawn(client, true); // C'est proche du comico. 
	
	char client_name[128];
	GetClientName2(client, client_name, sizeof(client_name), false);
	CPrintToChat(client, "" ...MOD_TAG... " %T", "Tueur_Kidnapping_End", client);
	CPrintToChat(target, "" ...MOD_TAG... " %T", "Tueur_Kidnapping_End_Target", target, client_name);
	
	return Plugin_Continue;
}
public int eventKidnapping(Handle p_hItemMenu, MenuAction p_oAction, int client, int p_iParam2) {
	if (p_oAction == MenuAction_Select) {
		
		if( rp_GetClientInt(client, i_KidnappedBy) <= 0 )
			return;
		
		char options[64];
		GetMenuItem(p_hItemMenu, p_iParam2, options, 63);
		
		if( StrEqual( options, "pay", false) ) {
			
			int pay = 2500;
			
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Tueur_Kidnapping_Pay", client, pay);
			
			int from = rp_GetClientInt(client, i_ToPay);
			int target = rp_GetClientInt(client, i_KidnappedBy);
			
			rp_ClientMoney(client, i_Bank, -pay);
			rp_ClientMoney(from, i_Bank, pay);
			
			char client_name[128];
			GetClientName2(client, client_name, sizeof(client_name), false);
			
			CPrintToChat(from, "" ...MOD_TAG... " %T", "Tueur_Kidnapping_Pay_Target", from, client_name, pay);
			CPrintToChat(target, "" ...MOD_TAG... " %T", "Tueur_Kidnapping_Pay_Target", target, client_name, pay);
			
			rp_IncrementSuccess(from, success_list_kidnapping);
			
			clearKidnapping(client);
			RestoreAssassinNormal(target);
			
			rp_ClientTeleport(client,  view_as<float>({2911.0, 868.0, -1853.0}));
			rp_ClientSendToSpawn(client, true);
		}
		else if( StrEqual( options, "free", false) ) {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Tueur_Kidnapping_Door", client);
			float delay = 20.0;
			float time = 0.0;
			
			GivePlayerItem(client, "weapon_revolver");
			
			char door[128], doors[12][12], tmp[2][12];
			GetConVarString(g_vConfigTueur, door, sizeof(door));
			int amount = ExplodeString(door, ",", doors, sizeof(doors), sizeof(doors[]) );
			
			for (int i = 0; i <= amount; i++) {
				
				int dble = ExplodeString(doors[i], "-", tmp, sizeof(tmp), sizeof(tmp[]));
				int entity = StringToInt(tmp[0]) + MaxClients;
				
				for (float delta = 0.1; delta <= 1.0; delta+=0.1) {
					rp_ScheduleEntityInput(entity, time+delta, "Unlock");
					rp_ScheduleEntityInput(entity, time+delta+0.1, "Open");
				}
				
				if( dble == 2 ) {
					entity = StringToInt(tmp[1]) + MaxClients;
					for (float delta = 0.1; delta <= 1.0; delta+=0.1) {
						rp_ScheduleEntityInput(entity, time+delta, "Unlock");
						rp_ScheduleEntityInput(entity, time+delta+0.1, "Open");
					}
					rp_ScheduleEntityInput(entity, time+30.0, "Close");
					rp_ScheduleEntityInput(entity, time+30.1, "Lock");
				}
				
				time += delay;
			}
			
			g_bShouldOpen[client] = false;
		}
		else if( StrEqual( options, "cops", false) ) {
			char dest[128];
			rp_GetZoneData(rp_GetPlayerZone(client), zone_type_name, dest, sizeof(dest));
			
			char client_name[128];
			GetClientName2(client, client_name, sizeof(client_name), false);
			
			for(int i=1; i<=MaxClients; i++) {
				if( !IsValidClient(i) )
					continue;
				if( rp_GetClientJobID(i) != 1 && rp_GetClientJobID(i) != 101 )
					continue;
				
				CPrintToChat(i, "" ...MOD_TAG... " %T", "Tueur_Kidnapping_Call", i, client_name, dest);
				rp_Effect_BeamBox(i, client);
				ClientCommand(i, "play buttons/blip1.wav");
			}
			
		}
		else if( StrEqual( options, "mafia", false) ) {
			
			char dest[128];
			rp_GetZoneData(rp_GetPlayerZone(client), zone_type_name, dest, sizeof(dest));
			
			char client_name[128];
			GetClientName2(client, client_name, sizeof(client_name), false);
			
			for(int i=1; i<=MaxClients; i++) {
				if( !IsValidClient(i) )
					continue;
				if( rp_GetClientJobID(i) != 91 )
					continue;
				
				CPrintToChat(i, "" ...MOD_TAG... " %T", "Tueur_Kidnapping_Call", i, client_name, dest);
				rp_Effect_BeamBox(i, client);
				ClientCommand(i, "play buttons/blip1.wav");
			}
			
		}
		else if( StrEqual( options, "crier", false) ) {
			FakeClientCommand(client, "say \"%T\"", "Tueur_Kidnapping_Cry", client);
			
			OpenKidnappingMenu(client);
		}
		
	}
	else if (p_oAction == MenuAction_End ) {
		CloseHandle(p_hItemMenu);
	}
}
void OpenKidnappingMenu(int client) {
		
	if( g_bShouldOpen[client] && rp_GetZoneInt( rp_GetPlayerZone(client), zone_type_type) == 41 && rp_ClientCanDrawPanel(client) ) {
		
		char tmp[128];
		Handle menu = CreateMenu(eventKidnapping);
		SetMenuTitle(menu, "%T\n ", "Tueur_Kidnapping_Menu", client);
			
		Format(tmp, sizeof(tmp), "%T", "Tueur_Kidnapping_Menu_Pay", client); 		AddMenuItem(menu, "pay", tmp);
		Format(tmp, sizeof(tmp), "%T", "Tueur_Kidnapping_Menu_Evade", client); 		AddMenuItem(menu, "free", tmp);
		Format(tmp, sizeof(tmp), "%T", "Tueur_Kidnapping_Menu_CallPolice", client); AddMenuItem(menu, "cops", tmp);
		Format(tmp, sizeof(tmp), "%T", "Tueur_Kidnapping_Menu_CallMafia", client); 	AddMenuItem(menu, "mafia", tmp);
		Format(tmp, sizeof(tmp), "%T", "Tueur_Kidnapping_Menu_Cry", client); 		AddMenuItem(menu, "crier", tmp);	
		
		SetMenuExitButton(menu, false);
		DisplayMenu(menu, client, 180);
	}
}
public Action fwdFrameKidnap(int client) {
	OpenKidnappingMenu(client);
}
// ----------------------------------------------------------------------------
public Action Cmd_ItemCryptage(int args) {
	
	int client = GetCmdArgInt(1);
	int item_id = GetCmdArgInt(args);
	
	if( rp_GetClientInt(client, i_SearchLVL) >= 3 ) {
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Crypto_Blocked", client);
		ITEM_CANCEL(client, item_id);
		return Plugin_Handled;
	}
	
	if( rp_GetClientJobID(client) == 1 || rp_GetClientJobID(client) == 101 ){
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_CannotUseItemPolice", client);
		ITEM_CANCEL(client, item_id);
		return Plugin_Handled;
	}
	
	int level = rp_GetClientInt(client, i_Cryptage) + 1;
	
	if( level > 5 )
		level = 5;
		
	rp_SetClientInt(client, i_Cryptage, level);
	CPrintToChat(client, "" ...MOD_TAG... " %T", "Crypto_Done", client, level*20);
	return Plugin_Handled;
}
public Action fwdWeapon(int victim, int attacker, float &damage, int wepID, float pos[3]) {
	bool changed = true;
	char sWeapon[32];
	GetEdictClassname(wepID, sWeapon, sizeof(sWeapon));
	
	if( StrContains(sWeapon, "taser") != -1 ) {
		
		int him = rp_GetClientInt(attacker, i_Protect_Him);
		int from = rp_GetClientInt(attacker, i_Protect_From);
		
			
		if( IsValidClient(him) || IsValidClient(from) ) {
			SetEntProp(attacker, Prop_Data, "m_iAmmo", 100, _, 19);
			
			if( victim != him && victim != from ) {
				
				rp_SetClientFloat(victim, fl_FrozenTime, GetGameTime() + 1.5);
				rp_SetClientFloat(victim, fl_TazerTime, GetGameTime() + 7.5);
				
				if(!rp_GetClientBool(victim, ch_Yeux))
					ServerCommand("sm_effect_flash %d 1.5 180", victim);
						
				if( rp_GetClientInt(attacker,i_Protect_Last) == victim ) {
					int heal = GetClientHealth(him);
					heal += 25;
					if( heal > 500 )
						heal = 500;
					SetEntityHealth(him, heal);
					
					heal = GetClientHealth(attacker);
					heal += 25;
					if( heal > 500 )
						heal = 500;
					SetEntityHealth(attacker, heal);
				}
			}
		}
		else {
			if(GetEntityFlags(victim) & FL_ONGROUND) {
				int flags = GetEntityFlags(victim);
				SetEntityFlags(victim, (flags&~FL_ONGROUND) );
				SetEntPropEnt(victim, Prop_Send, "m_hGroundEntity", -1);
			}
			TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, view_as<float>({0.0, 0.0, 0.0}));
			SlapPlayer(victim, 0, true);
		}
		damage *= 0.0;
		return Plugin_Handled;
	}
	
	if( changed )
		return Plugin_Changed;
	return Plugin_Continue;
}
public Action Cmd_ItemMaps(int args) {
	
	int client = GetCmdArgInt(1);
	rp_SetClientBool(client, b_Map, true);
	rp_HookEvent(client, RP_OnAssurance,	fwdAssurance2);
}
public Action fwdAssurance2(int client, int& amount) {
		amount += 1000;
}

void changeZoneState(int zone, bool enabled) {
	int bits;
	char tmp[64], tmp2[64];
	rp_GetZoneData(zone, zone_type_type, tmp, sizeof(tmp));
	
	for (int i = 0; i < MAX_ZONES; i++) {
		
		rp_GetZoneData(i, zone_type_type, tmp2, sizeof(tmp2));
		if( !StrEqual(tmp, tmp2) )
			continue;
		
		bits = rp_GetZoneBit(i);
		
		if( enabled && !(bits & BITZONE_LEGIT) ) {
			bits |= BITZONE_LEGIT;
		}
		else if( !enabled && (bits & BITZONE_LEGIT) ) {
			bits &= ~BITZONE_LEGIT;
		}
		
		rp_SetZoneBit(i, bits);
	}
}
