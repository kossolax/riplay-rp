/*
 * Cette oeuvre, création, site ou texte est sous licence Creative Commons Attribution
 * - Pas d’Utilisation Commerciale
 * - Partage dans les Mêmes Conditions 4.0 International. 
 * Pour accéder à une copie de cette licence, merci de vous rendre à l'adresse suivante
 * http://creativecommons.org/licenses/by-nc-sa/4.0/ .
 *
 * Merci de respecter le travail fourni par le ou les auteurs 
 * https://www.riplay.fr/
 */
#pragma semicolon 1

#include <sourcemod>
#include <cstrike>
#include <sdkhooks>

#include <colors_csgo>	// https://forums.alliedmods.net/showthread.php?p=2205447#post2205447
#include <smlib>		// https://github.com/bcserv/smlib

#pragma newdecls required
#include <roleplay.inc>	// https://www.riplay.fr

public Plugin myinfo = {
	name = "Jobs: SPQR", author = "Messorem & Exodus",
	description = "RolePlay - Jobs: SPQR",
	version = __LAST_REV__, url = "https://www.riplay.fr"
};

int g_bShouldOpen[65];
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
	
	RegServerCmd("rp_quest_reload", Cmd_Reload);
	RegServerCmd("rp_item_abus",		Cmd_Itemabus,		"RP-ITEM",	FCVAR_UNREGISTERED);
	
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
public Action Cmd_Itemabus(int args) {
	
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
	
	g_bBlockDrop[vendeur] = true;
	
	
	if( StrContains(arg1, "bucher") == 0 ) {
		g_iKillerPoint[vendeur][competance_type] = 2001;
	}
	else if( StrContains(arg1, "faucheur") == 0 ) {
		g_iKillerPoint[vendeur][competance_type] = 2002;
	}
	else if( StrContains(arg1, "balisage") == 0 ) {
		g_iKillerPoint[vendeur][competance_type] = 2003;
	}
	else if( StrContains(arg1, "Dardevil") == 0 ) {
		g_iKillerPoint[vendeur][competance_type] = 2004;
		rp_SetClientInt(target, i_ContratTotal, rp_GetClientInt(target, i_ContratTotal) + 10);
	}

}
