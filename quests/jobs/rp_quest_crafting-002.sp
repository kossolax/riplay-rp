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
#include <cstrike>
#include <colors_csgo>  // https://forums.alliedmods.net/showthread.php?p=2205447#post2205447
#include <smlib>        // https://github.com/bcserv/smlib
#include <emitsoundany> // https://forums.alliedmods.net/showthread.php?t=237045

#pragma newdecls required
#include <roleplay.inc>

#define QUEST_UNIQID    "craft_minerai"
#define QUEST_NAME      "Couvrez moi d'or et de platine"
#define QUEST_TYPE      quest_daily
#define QUEST_RESUME1   "Récoltez des minerais"
#define QUEST_WEAPON	"weapon_hammer"
#define QUEST_MAX		250

int g_iQuest, g_iStep[MAXPLAYERS + 1];

public Plugin myinfo =  {
	name = "Quête: "...QUEST_NAME, author = "KoSSoLaX`", 
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
	char model1[PLATFORM_MAX_PATH], model2[PLATFORM_MAX_PATH], tmp[32];
	
	if( Client_HasWeapon(client, "weapon_knife") )
		return false;
	
	int wpnid = Client_GetWeapon(client, "weapon_melee");
	if( wpnid > 0 ) {
		Entity_GetModel(wpnid, model1, sizeof(model1));
		
		Format(tmp, sizeof(tmp), "%s", QUEST_WEAPON);
		ReplaceString(tmp, sizeof(tmp), "weapon_", "v_");
		Format(model2, sizeof(model2), "models/weapons/%s.mdl", tmp);
		
		return StrEqual(model1, model2);
	}
	return true;
}

public void Q1_Start(int objectiveID, int client) {

	g_iStep[client] = 0;

	if( ( !Client_HasWeapon(client, "weapon_melee") && rp_IsClientNew(client) ) ||
	    ( !Client_HasWeapon(client, "weapon_melee" ) && rp_GetClientInt(client, i_Job) == 0 ) ) {
		ServerCommand("rp_giveitem_melee %s 0 %d 0", QUEST_WEAPON, client);
	}
	else if( ( !rp_IsClientNew(client) ) || ( !rp_GetClientInt(client, i_Job) == 0 ) ) {
		CPrintToChat(client, "" ...MOD_TAG... " %T", "No_News_hammer", client);
	}
	
	rp_HookEvent(client, RP_OnPlayerGotRaw, OnPlayerGotRaw);
}
public void Q1_Frame(int objectiveID, int client) {
	PrintHintText(client, "%s: %d/%d", QUEST_RESUME1, g_iStep[client], QUEST_MAX);
	if( g_iStep[client] >= QUEST_MAX ) {
		rp_QuestStepComplete(client, objectiveID);
	}
}

public Action OnPlayerGotRaw(int client, int type, int itemID, int& amount) {
	if( type == 1 ) {
		amount *= 2;
		g_iStep[client] += amount;
	}
}
public void Q1_Abort(int objectiveID, int client) {
	rp_UnhookEvent(client, RP_OnPlayerGotRaw, OnPlayerGotRaw);
}
public void Q1_Done(int objectiveID, int client) {
	Q1_Abort(objectiveID, client);
	rp_ClientXPIncrement(client, 2500);
}
