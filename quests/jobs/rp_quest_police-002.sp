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
#include <colors_csgo>	// https://forums.alliedmods.net/showthread.php?p=2205447#post2205447
#include <smlib>		// https://github.com/bcserv/smlib
#include <emitsoundany> // https://forums.alliedmods.net/showthread.php?t=237045



#pragma newdecls required
#include <roleplay.inc>	// https://www.ts-x.eu


#define QUEST_UNIQID	"police-002"
#define	QUEST_NAME		"Surveillance renforcée"
#define	QUEST_TYPE		quest_daily
#define	QUEST_JOBID		1
#define	QUEST_RESUME1	"Surveillez la prison"

public Plugin myinfo = {
	name = "Quête: "...QUEST_NAME, author = "KoSSoLaX",
	description = "RolePlay - Quête Police: "...QUEST_NAME,
	version = __LAST_REV__, url = "https://www.ts-x.eu"
};

int g_iQuest, g_iDuration[MAXPLAYERS + 1];
int g_iTickXp[65];


public void OnPluginStart() {
	RegServerCmd("rp_quest_reload", Cmd_PluginReloadSelf);
}
public void OnAllPluginsLoaded() {
	g_iQuest = rp_RegisterQuest(QUEST_UNIQID, QUEST_NAME, QUEST_TYPE, fwdCanStart);
	if( g_iQuest == -1 )
		SetFailState("Erreur lors de la création de la quête %s %s", QUEST_UNIQID, QUEST_NAME);
	
	int i;
	rp_QuestAddStep(g_iQuest, i++,	Q1_Start,	Q1_Frame,	Q1_Abort,	Q1_Abort);	
}
// ----------------------------------------------------------------------------
public bool fwdCanStart(int client) {
	if( rp_GetClientJobID(client) != QUEST_JOBID )
		return false;
	
	for (int i = 1; i <= MaxClients; i++) {
		if( !IsValidClient(i) )
			continue;
		if( rp_GetClientJobID(i) != QUEST_JOBID )
			continue;
		if( zoneJail(i) )
			return false;
	}
	return true;
}
public void Q1_Start(int objectiveID, int client) {
	Menu menu = new Menu(MenuNothing);
	
	menu.SetTitle("Quète: %s", QUEST_NAME);
	menu.AddItem("", "Interlocuteur anonyme :", ITEMDRAW_DISABLED);
	menu.AddItem("", "Collègue, nous avons besoin que vous", ITEMDRAW_DISABLED);
	menu.AddItem("", "surveillez la prison. Pendant les prochaines 24h.", ITEMDRAW_DISABLED);
	menu.AddItem("", "Nous t'offrons 20$ toutes les 10 minutes", ITEMDRAW_DISABLED);
	menu.AddItem("", "passées à surveiller les prisonniers.", ITEMDRAW_DISABLED);
	menu.AddItem("", "-----------------", ITEMDRAW_DISABLED);
	menu.AddItem("", "Attention, si tu t'absentes nous t'infligerons", ITEMDRAW_DISABLED);
	menu.AddItem("", "une retenue sur ton salaire !", ITEMDRAW_DISABLED); 
	
	menu.ExitButton = false;
	menu.Display(client, 60);
	
	g_iTickXp[client] = 0;
	g_iDuration[client] = 24 * 60;
}
public void Q1_Frame(int objectiveID, int client) {
	
	static bool wasAFK[65];

	g_iDuration[client]--;
	
	if( zoneJail(client) ) {
		
		if( wasAFK[client] == false && rp_GetClientBool(client, b_IsAFK) ) {
			int mnt = RoundToFloor(1.5 * 3.0 * 60.0);
			rp_SetJobCapital(1, rp_GetJobCapital(1) + mnt);
			rp_ClientMoney(client, i_AddToPay, - mnt);
			g_iTickXp[client]-=(3*60);
		}
		
		wasAFK[client] = rp_GetClientBool(client, b_IsAFK);
		if( !wasAFK[client] ) {
			int cap = rp_GetRandomCapital(1);
			int mnt = Math_GetRandomInt(1,2);
			rp_SetJobCapital(cap, rp_GetJobCapital(cap) - mnt);
			rp_ClientMoney(client, i_AddToPay, mnt);
			g_iTickXp[client]++;
		}
	}
	
	if( g_iDuration[client] <= 0 ) {
		rp_QuestStepComplete(client, objectiveID);
	}
	else {
		PrintHintText(client, "<b>Quête</b>: %s\n<b>Temps restant</b>: %dsec\n<b>Objectif</b>: %s", QUEST_NAME, g_iDuration[client], QUEST_RESUME1);
	}
}
public void Q1_Abort(int objectiveID, int client) {
	if(g_iTickXp[client] > 0){
		int xp = RoundToFloor( g_iTickXp[client] * ( (24*60) / 1500 ) );
		rp_ClientXPIncrement(client, xp);
	}
	PrintHintText(client, "<b>Quête</b>: %s\nLa quête est terminée.", QUEST_NAME);
}
// ----------------------------------------------------------------------------
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
bool zoneJail(int client) {
	int zone = rp_GetPlayerZone(client);
	if( zone == 13 || zone == 16 || zone == 17 || zone == 18 || zone == 93 || zone == 158 || zone == 180 || zone == 199)
		return true;
	return false;
}
/* 
Zone 13 : Jail
Zone 16 : escalier
Zone 17 : conduit
Zone 18 : conduit
Zone 93 : cours
Zone 158 : QHS
Zone 180 : couloir cour
Zone 199 : conduit
*/
