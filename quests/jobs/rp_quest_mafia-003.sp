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


#define QUEST_UNIQID	"mafia-003"
#define	QUEST_NAME		"Documents secrets"
#define	QUEST_TYPE		quest_daily
#define	QUEST_JOBID		91
#define	QUEST_RESUME	"Récupérer les documents"

public Plugin myinfo = {
	name = "Quête: "...QUEST_NAME, author = "KoSSoLaX",
	description = "RolePlay - Quête Mafia: "...QUEST_NAME,
	version = __LAST_REV__, url = "https://www.ts-x.eu"
};

int g_iQuest, g_iDuration[MAXPLAYERS + 1], g_iGoing[MAXPLAYERS + 1];

public void OnPluginStart() {
	RegServerCmd("rp_quest_reload", Cmd_PluginReloadSelf);
}
public void OnAllPluginsLoaded() {
	g_iQuest = rp_RegisterQuest(QUEST_UNIQID, QUEST_NAME, QUEST_TYPE, fwdCanStart);
	if( g_iQuest == -1 )
		SetFailState("Erreur lors de la création de la quête %s %s", QUEST_UNIQID, QUEST_NAME);
	
	int i;
	rp_QuestAddStep(g_iQuest, i++,	Q1_Start,	Q1_Frame,	Q1_Abort,	QUEST_NULL);
	rp_QuestAddStep(g_iQuest, i++,	Q2_Start,	Q2_Frame,	Q1_Abort,	Q2_End);
}
// ----------------------------------------------------------------------------
public bool fwdCanStart(int client) {
	if( rp_GetClientJobID(client) != QUEST_JOBID )
		return false;
		
	return true;
}
public void Q1_Start(int objectiveID, int client) {
	Menu menu = new Menu(MenuNothing);
	
	menu.SetTitle("Quète: %s", QUEST_NAME);
	menu.AddItem("", "Interlocuteur anonyme :", ITEMDRAW_DISABLED);
	menu.AddItem("", "Mon frère, Nous avons besoin de toi.", ITEMDRAW_DISABLED);
	menu.AddItem("", "Des documents très important se trouvent", ITEMDRAW_DISABLED);
	menu.AddItem("", "dans la villa du maire. Vole-les.", ITEMDRAW_DISABLED);
	menu.AddItem("", "-----------------", ITEMDRAW_DISABLED);
	menu.AddItem("", "Pendant toute la durée de ta mission, ", ITEMDRAW_DISABLED);
	menu.AddItem("", "nous t'enverrons du matériel nécessaire à ta réussite.", ITEMDRAW_DISABLED);
	menu.AddItem("", "Tu as 12 heures.", ITEMDRAW_DISABLED);
	
	menu.ExitButton = false;
	menu.Display(client, 60);
	
	g_iDuration[client] = 12 * 60;
	g_iGoing[client] = rp_QuestCreateInstance(client, "models/props/cs_office/box_office_indoor_32.mdl", view_as<float>({-6656.8, 4317.7, -2423.9}));
}
public void Q1_Frame(int objectiveID, int client) {
	
	g_iDuration[client]--;
	if( Entity_GetDistance(client, g_iGoing[client]) < 32.0 ) {
		AcceptEntityInput(g_iGoing[client], "Kill");
		rp_QuestStepComplete(client, objectiveID);
	}
	else if( g_iDuration[client] <= 0 ) {
		rp_QuestStepFail(client, objectiveID);
	}
	else {
		PrintHintText(client, "<b>Quête</b>: %s\n<b>Temps restant</b>: %dsec\n<b>Objectif</b>: %s", QUEST_NAME, g_iDuration[client], QUEST_RESUME);
		rp_Effect_BeamBox(client, g_iGoing[client], NULL_VECTOR, 255, 0, 0);
		
		if( rp_GetPlayerZone(client) == 155 || rp_GetPlayerZone(client) == 156 ) {
			if( rp_GetClientItem(client, 3) == 0 ) {
				char item[64];
				rp_GetItemData(3, item_type_name, item, sizeof(item));
				rp_ClientGiveItem(client, 3);
				CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous avez reçu: %s", item);
			}
		}
	}
}
public void Q2_Start(int objectiveID, int client) {
	Menu menu = new Menu(MenuNothing);
	
	menu.SetTitle("Quète: %s", QUEST_NAME);
	menu.AddItem("", "Interlocuteur anonyme :", ITEMDRAW_DISABLED);
	menu.AddItem("", "Tu as les documents !", ITEMDRAW_DISABLED);
	menu.AddItem("", "Rapporte les nous au plus vite à la planque !", ITEMDRAW_DISABLED);
	
	menu.ExitButton = false;
	menu.Display(client, 30);
	
	g_iDuration[client] = 6 * 60;
}
public void Q2_Frame(int objectiveID, int client) {
	static float dst[3] =  { -316.2, 3204.1, -2119.9 };
	float vec[3];
	GetClientAbsOrigin(client, vec);
	
	g_iDuration[client]--;
	if( rp_GetPlayerZone(client) == rp_GetZoneFromPoint(dst) ) {
		rp_QuestStepComplete(client, objectiveID);
	}
	else if( g_iDuration[client] <= 0 ) {
		rp_QuestStepFail(client, objectiveID);
	}
	else {
		PrintHintText(client, "<b>Quête</b>: %s\n<b>Temps restant</b>: %dsec\n<b>Objectif</b>: %s", QUEST_NAME, g_iDuration[client], QUEST_RESUME);
		rp_Effect_BeamBox(client, -1, dst, 255, 255, 255);
		
		if( rp_GetPlayerZone(client) == 155 || rp_GetPlayerZone(client) == 156 ) {
			if( rp_GetClientItem(client, 3) == 0 ) {
				char item[64];
				rp_GetItemData(3, item_type_name, item, sizeof(item));
				rp_ClientGiveItem(client, 3);
				CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous avez reçu: %s", item);
			}
		}
	}
}
public void Q2_End(int objectiveID, int client) {
	
	Q1_Abort(objectiveID, client);
	
	int cap = rp_GetRandomCapital(91);
	rp_SetJobCapital(cap, rp_GetJobCapital(cap) - 2500);
	rp_ClientMoney(client, i_AddToPay, 2500);
	rp_SetJobCapital(91, rp_GetJobCapital(91) + 250);
	
	rp_ClientXPIncrement(client, 1250);
}


public void Q1_Abort(int objectiveID, int client) {
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
