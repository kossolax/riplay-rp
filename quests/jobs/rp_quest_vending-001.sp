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
#include <colors_csgo>   // https://forums.alliedmods.net/showthread.php?p=2205447#post2205447
#include <smlib>      // https://github.com/bcserv/smlib
#include <emitsoundany> // https://forums.alliedmods.net/showthread.php?t=237045

#pragma newdecls required
#include <roleplay.inc>   // https://www.ts-x.eu


#define QUEST_UNIQID   "vending-001"
#define   QUEST_NAME      "Collecte des matières premières"
#define   QUEST_TYPE      quest_daily
#define   QUEST_RESUME1   "Récupérez le colis"
#define   QUEST_RESUME2   "Apportez les colis à votre planque"
#define QUEST_ITEM      236

public Plugin myinfo =  {
	name = "Quête: "...QUEST_NAME, author = "KoSSoLaX", 
	description = "RolePlay - Quête Vente: "...QUEST_NAME, 
	version = __LAST_REV__, url = "https://www.ts-x.eu"
};

int g_iQuest, g_iDuration[MAXPLAYERS + 1], g_iGoing[MAXPLAYERS + 1], g_iCurrent[MAXPLAYERS + 1];

float g_flLocation[5][3] =  {
	{ -130.6, 1330.9, -2096.4 }, 
	{ -1097.0, 848.2, -2091.1 }, 
	{ -7707.3, 2030.2, -2335.9 }, 
	{ -8712.8, -7291.5, -1207.9 }, 
	{ 2058.3, -2652.2, -979.7 }
};

public void OnPluginStart() {
	RegServerCmd("rp_quest_reload", Cmd_PluginReloadSelf);
}
public void OnAllPluginsLoaded() {
	g_iQuest = rp_RegisterQuest(QUEST_UNIQID, QUEST_NAME, QUEST_TYPE, fwdCanStart);
	if (g_iQuest == -1)
		SetFailState("Erreur lors de la création de la quête %s %s", QUEST_UNIQID, QUEST_NAME);
	
	int i;
	rp_QuestAddStep(g_iQuest, i++, Q1_Start, Q1_Frame, Q1_Abort, Q1_Abort);
	
	rp_QuestAddStep(g_iQuest, i++, Q2_Start, Q1_Frame, Q1_Abort, Q1_Abort);
	rp_QuestAddStep(g_iQuest, i++, Q2_Start, Q1_Frame, Q1_Abort, Q1_Abort);
	rp_QuestAddStep(g_iQuest, i++, Q2_Start, Q1_Frame, Q1_Abort, Q1_Abort);
	rp_QuestAddStep(g_iQuest, i++, Q2_Start, Q1_Frame, Q1_Abort, Q1_Abort);
	
	rp_QuestAddStep(g_iQuest, i++, Q3_Start, Q3_Frame, QUEST_NULL, Q3_End);
}
// ----------------------------------------------------------------------------
public bool fwdCanStart(int client) {
	int jobList[] =  { 11, 21, 31, 51, 61, 71, 81, 111, 121, 131, 171, 181, 191, 211, 221 };
	int job = rp_GetClientJobID(client);
	
	for (int i = 0; i < sizeof(jobList); i++) {
		if( jobList[i] == job )
			return true;
	}
	
	char steamid[32];
	GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));
	if( StrEqual(steamid, "STEAM_1:1:1756644") )
		return true;
	
	return false;
}
public void Q1_Start(int objectiveID, int client) {
	Menu menu = new Menu(MenuNothing);
	
	menu.SetTitle("Quète: %s", QUEST_NAME);
	menu.AddItem("", "Interlocuteur anonyme :", ITEMDRAW_DISABLED);
	menu.AddItem("", "Bonjour citoyen,", ITEMDRAW_DISABLED);
	menu.AddItem("", "j'ai une nouvelle mission à te confier.", ITEMDRAW_DISABLED);
	menu.AddItem("", "il y a 5 colis pour toi à récupérer en ville. ", ITEMDRAW_DISABLED);
	menu.AddItem("", "Vas les récupérer !", ITEMDRAW_DISABLED);
	
	menu.ExitButton = false;
	menu.Display(client, 60);
	
	g_iDuration[client] = 6 * 60;
	g_iCurrent[client] = 0;
	g_iGoing[client] = rp_QuestCreateInstance(client, "models/props/cs_office/box_office_indoor_32.mdl", g_flLocation[g_iCurrent[client]]);
	
}
public void Q1_Abort(int objectiveID, int client) {
	char classname[65];
	if (g_iGoing[client] > 0 && IsValidEdict(g_iGoing[client]) && IsValidEntity(g_iGoing[client])) {
		GetEdictClassname(g_iGoing[client], classname, sizeof(classname));
		if (StrContains(classname, "prop_dynamic_glow") == 0) {
			AcceptEntityInput(g_iGoing[client], "Kill");
			g_iGoing[client] = 0;
		}
	}
}
public void Q1_Frame(int objectiveID, int client) {
	
	g_iDuration[client]--;
	
	if (Entity_GetDistance(client, g_iGoing[client]) < 32.0) {
		AcceptEntityInput(g_iGoing[client], "Kill");
		g_iGoing[client] = 0;
		rp_QuestStepComplete(client, objectiveID);
		
		int cap = rp_GetRandomCapital(181);
		rp_SetJobCapital(cap, rp_GetJobCapital(cap) - 500);
		rp_ClientMoney(client, i_AddToPay, 500);
		
		rp_ClientXPIncrement(client, 250);
		
		int MP[] =  { 128, 129, 234, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255, 256, 257 };
		int rnd = Math_GetRandomInt(0, sizeof(MP) - 1);
		char tmp[128];
		rp_GetItemData(MP[rnd], item_type_name, tmp, sizeof(tmp));
		CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous avez trouvé 10x%s", tmp);
		rp_ClientGiveItem(client, MP[rnd], 10);
		
	}
	else if (g_iDuration[client] <= 0) {
		rp_QuestStepFail(client, objectiveID);
	}
	else {
		PrintHintText(client, "<b>Quête</b>: %s\n<b>Temps restant</b>: %dsec\n<b>Objectif</b>: %s", QUEST_NAME, g_iDuration[client], QUEST_RESUME1);
		rp_Effect_BeamBox(client, g_iGoing[client], NULL_VECTOR, 255, 0, 0);
	}
}
public void Q2_Start(int objectiveID, int client) {
	Menu menu = new Menu(MenuNothing);
	
	menu.SetTitle("Quète: %s", QUEST_NAME);
	menu.AddItem("", "Interlocuteur anonyme :", ITEMDRAW_DISABLED);
	menu.AddItem("", "Tu l'as ! Va me chercher le colis suivant.", ITEMDRAW_DISABLED);
	
	menu.ExitButton = false;
	menu.Display(client, 30);
	
	g_iDuration[client] = 6 * 60;
	g_iCurrent[client]++;
	g_iGoing[client] = rp_QuestCreateInstance(client, "models/props/cs_office/box_office_indoor_32.mdl", g_flLocation[g_iCurrent[client]]);
}
public void Q3_Start(int objectiveID, int client) {
	Menu menu = new Menu(MenuNothing);
	
	menu.SetTitle("Quète: %s", QUEST_NAME);
	menu.AddItem("", "Interlocuteur anonyme :", ITEMDRAW_DISABLED);
	menu.AddItem("", "Bien joué !", ITEMDRAW_DISABLED);
	menu.AddItem("", "Va déposer tout ces colis dans ta", ITEMDRAW_DISABLED);
	menu.AddItem("", "planque, tu y recevras une récompense.", ITEMDRAW_DISABLED);
	
	menu.ExitButton = false;
	menu.Display(client, 30);
	
	g_iDuration[client] = 6 * 60;
}
public void Q3_Frame(int objectiveID, int client) {
	float vec[3];
	GetClientAbsOrigin(client, vec);
	
	g_iDuration[client]--;
	if ( rp_GetZoneInt(rp_GetPlayerZone(client), zone_type_type) == rp_GetClientJobID(client) ) {
		rp_QuestStepComplete(client, objectiveID);
	}
	else if (g_iDuration[client] <= 0) {
		rp_QuestStepFail(client, objectiveID);
	}
	else {
		PrintHintText(client, "<b>Quête</b>: %s\n<b>Temps restant</b>: %dsec\n<b>Objectif</b>: %s", QUEST_NAME, g_iDuration[client], QUEST_RESUME2);
	}
}
public void Q3_End(int objectiveID, int client) {
	
	Q1_Abort(objectiveID, client);
	
	Menu menu = new Menu(MenuNothing);
	
	menu.SetTitle("Quète: %s", QUEST_NAME);
	menu.AddItem("", "Interlocuteur anonyme :", ITEMDRAW_DISABLED);
	menu.AddItem("", "Je te remercie pour ta rapidité d'action", ITEMDRAW_DISABLED);
	menu.AddItem("", "voila un petit cadeaux : [PvP] AK-47.", ITEMDRAW_DISABLED);
	
	menu.ExitButton = false;
	menu.Display(client, 30);
	
	char item[64]; rp_GetItemData(QUEST_ITEM, item_type_name, item, sizeof(item)); rp_ClientGiveItem(client, QUEST_ITEM); // [PvP] AK-47
	CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous avez reçu: %s", item);
}
// ----------------------------------------------------------------------------
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
