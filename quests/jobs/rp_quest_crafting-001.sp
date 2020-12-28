/*
 * Cette oeuvre, création, site ou texte est sous licence Creative Commons Attribution
 * - Pas d’Utilisation Commerciale
 * - Partage dans les Mêmes Conditions 4.0 International. 
 * Pour accéder à une copie de cette licence, merci de vous rendre à l'adresse suivante
 * http://creativecommons.org/licenses/by-nc-sa/4.0/ .
 *
 * Merci de respecter le travail fourni par le ou les auteurs 
 * https://riplay.fr/ - pasty.bully@gmail.com
 */
#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <colors_csgo>  // https://forums.alliedmods.net/showthread.php?p=2205447#post2205447
#include <smlib>        // https://github.com/bcserv/smlib
#include <emitsoundany> // https://forums.alliedmods.net/showthread.php?t=237045

#pragma newdecls required
#include <roleplay.inc>

#define QUEST_UNIQID    "craft_bois"
#define QUEST_NAME      "De quel bois je me chauffe"
#define QUEST_TYPE      quest_daily
#define QUEST_RESUME1   "Coupez du bois"
#define QUEST_WEAPON	"weapon_axe"

int g_iQuest, g_iStep[MAXPLAYERS + 1];

public Plugin myinfo =  {
	name = "Quête: "...QUEST_NAME, author = "PastyBully", 
	description = "RolePlay - Quête:"...QUEST_NAME, 
	version = __LAST_REV__, url = "https://rpweb.riplay.fr/#/"
};
public void OnPluginStart() {
	RegServerCmd("rp_quest_reload", Cmd_PluginReloadSelf);
}
public void OnAllPluginsLoaded() {
	g_iQuest = rp_RegisterQuest(QUEST_UNIQID, QUEST_NAME, QUEST_TYPE, fwdCanStart);
	
	int i;
	rp_QuestAddStep(g_iQuest, i++, Q1_Start, Q1_Frame, Q1_Abort, Q1_Done);
}
// ----------------------------------------------------------------------------
public bool fwdCanStart(int client) {
	return true;
}

public void Q1_Start(int objectiveID, int client) {
	if( !Client_HasWeapon(client, QUEST_WEAPON) ) {
		ServerCommand("rp_giveitem_melee %s %d 0", QUEST_WEAPON, client);
	}
	
	rp_HookEvent(client, RP_OnPlayerGotRaw, OnPlayerGotRaw);
}
public void Q1_Frame(int objectiveID, int client) {
	PrintHintText(client, "%s: %d/100", QUEST_RESUME1, g_iStep[client]);
	if( g_iStep[client] >= 100 ) {
		rp_QuestStepComplete(client, objectiveID);
	}
}

public Action OnPlayerGotRaw(int client, int type, int itemID, int& amount) {
	if( type == 2 ) {
		amount *= 2;
		g_iStep[client]++;
	}
}
public void Q1_Abort(int objectiveID, int client) {
	rp_UnhookEvent(client, RP_OnPlayerGotRaw, OnPlayerGotRaw);
}
public void Q1_Done(int objectiveID, int client) {
	rp_UnhookEvent(client, RP_OnPlayerGotRaw, OnPlayerGotRaw);
	rp_ClientXPIncrement(client, 1500);
}
