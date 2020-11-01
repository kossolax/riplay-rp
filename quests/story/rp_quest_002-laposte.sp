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
#include <colors_csgo>	// https://forums.alliedmods.net/showthread.php?p=2205447#post2205447
#include <smlib>		// https://github.com/bcserv/smlib
#include <emitsoundany> // https://forums.alliedmods.net/showthread.php?t=237045

#pragma newdecls required
#include <roleplay.inc>

#define QUEST_UNIQID	"poste"
#define	QUEST_NAME		"La Poste"
#define	QUEST_TYPE		quest_daily
#define	QUEST_RESUME1	"Allez chercher le courrier à la mairie et livrez le aux citoyens désignés"
#define MAXSTEP 16


public Plugin myinfo =  {
	name = "Quête: "...QUEST_NAME, author = "PastyBully", 
	description = "RolePlay - Quête Joueur: "...QUEST_NAME, 
	version = __LAST_REV__, url = "https://rpweb.riplay.fr/#/"
};

int g_iQuest, g_iDuration[MAXPLAYERS + 1], g_iNbQuest[MAXPLAYERS + 1], g_iCurrentIndex[MAXPLAYERS + 1];
int g_iRandomJob[MAXPLAYERS + 1][MAXSTEP];

// Message
char g_poste[][][256] =  {
	{ "Vous devez déposer la liste des prisonniers. Pour cela, rendez-vous au poste de police.", "1" }, 
	{ "Vous devez déposer à l'hôpital le dernier classement des hôpitaux du pays. Pour cela, rendez-vous à l'hôpital.", "11" }, 
	{ "Vous devez apportez les dernieres recettes des hamburgers au fast food. Pour cela, rendez-vous jusqu'au Mc'Donald.", "21" }, 
	{ "Vous devez ammenez les derniers outils aux artisans. Pour cela, rendez-vous jusqu'au magasin d'artisanat.", "31" }, 
	{ "Vous devez ammenez les derniers contrats signés aux mercenaires. Pour cela, rendez-vous jusqu'à leur planque.", "41" }, 
	{ "Vous devez ammenez les nouveaux seuils de pollution des véhicules au concessionaire. Pour cela, rendez-vous jusqu'au magasin de véhicule.", "51" }, 
	{ "Vous devez ammenez le dernier bilan des ventes aux vendeurs immobiliers. Pour cela, rendez-vous jusqu'à l'agence immobilière.", "61" }, 
	{ "Vous devez apportez les derniers magazines sportifs aux entraineurs sexy. Pour cela, rendez-vous à la salle d'entraînement.", "71" }, 
	{ "Vous devez déposer aux dealers les dernières informations concernant la police. Pour cela, rendez-vous jusqu'à la planque des dealers.", "81" }, 
	{ "Vous devez donner à la mafia les nouveaux ennemis de la famille Cosa Nostra. Pour cela, rendez-vous jusqu'à leur planque.", "91" }, 
	{ "Vous devez donner à la justice le dernier bilan des condamnations. Pour cela, rendez-vous jusqu'au palais de justice.", "101" }, 
	{ "Vous devez apportez aux armuriers les dernières règlementations concernant les armes. Pour cela, rendez-vous à l'armurerie.", "111" }, 
	{ "Vous devez apportez la liste des derniers explosifs aux artificiers. Pour cela, rendez-vous au magasin d'artifice.", "131" }, 
	{ "Vous devez apportez les derniers résultats de vente aux lotos. Pour cela, rendez-vous jusqu'au magasin de loterie.", "171" }, 
	{ "Vous devez apportez les derniers relevés de compte aux banquiers. Pour cela, rendez-vous à la Banque.", "211" }, 
	{ "Vous devez apportez la liste des nouvelles technologies aux techniciens. Pour cela, rendez-vous jusqu'à l'atelier des techniciens.", "221" }, 
};

public void OnPluginStart() {
	RegServerCmd("rp_quest_reload", Cmd_PluginReloadSelf);
}

public void OnAllPluginsLoaded() {
	g_iQuest = rp_RegisterQuest(QUEST_UNIQID, QUEST_NAME, QUEST_TYPE, fwdCanStart);
	
	if (g_iQuest == -1)
		SetFailState("Erreur lors de la création de la quête %s %s", QUEST_UNIQID, QUEST_NAME);
	
	int i;
	rp_QuestAddStep(g_iQuest, i++, Q1_Start, Q1_Frame, Q1_Abort, QUEST_NULL);

	
	for (int j = 0; j < sizeof(g_poste) - 1; j++)
		rp_QuestAddStep(g_iQuest, i++, Q2_Start, Q2_Frame, Q1_Abort, QUEST_NULL);
	
	rp_QuestAddStep(g_iQuest, i++, Q2_Start, Q2_Frame, Q1_Abort, Q2_Done);
}

// ----------------------------------------------------------------------------

public bool fwdCanStart(int client) {
	if (rp_GetClientJobID(client) == 91 || rp_GetClientJobID(client) == 81)
		return false;
	
	return true;
}

public void Q1_Start(int objectiveID, int client) {
	for (int k = 0; k < MAXSTEP; k++) {
		g_iRandomJob[client][k] = k;
	}
	
	SortIntegers(g_iRandomJob[client], sizeof(g_iRandomJob[]), Sort_Random);
	
	g_iNbQuest[client] = -1;
	
	ActualizeCurrentIndex(client, "rp_mail_0");
	
	char s[256];
	Format(s, sizeof(s), "Vous devez allez chercher le nouveau courrier à la mairie.");
	String_WordWrap(s, 40);
	
	Menu menu = new Menu(MenuNothing);
	
	menu.SetTitle("Quête: %s", QUEST_NAME);
	menu.AddItem("", s, ITEMDRAW_DISABLED);
	menu.ExitButton = false;
	menu.Display(client, 60);
	
	g_iDuration[client] = 2 * 60;
}

public void Q1_Frame(int objectiveID, int client) {
	g_iDuration[client]--;
	
	float origin[3], pos[3];
	
	int entityIndex = g_iCurrentIndex[client];	
	Entity_GetAbsOrigin(entityIndex, pos);
	ServerCommand("sm_effect_gps %d %f %f %f", client, pos[0], pos[1], pos[2]);
	
	GetClientAbsOrigin(client, origin);
	
	if (GetVectorDistance(pos, origin) < 64.0) {
		CPrintToChat(client, ""...MOD_TAG..." Vous venez de récupérer le courrier, la distribution commence.");
		rp_QuestStepComplete(client, objectiveID);
	}
	else if (g_iDuration[client] <= 0)
		rp_QuestStepFail(client, objectiveID);
	else {
		PrintHintText(client, "<b>Quête</b>: %s\n<b>Temps restant</b>: %dsec\n<b>Objectif</b>: %s", QUEST_NAME, g_iDuration[client], QUEST_RESUME1);
	}
}

public void Q1_Abort(int objectiveID, int client) {
	PrintHintText(client, "<b>Quête</b>: %s\nLa quête est terminée.", QUEST_NAME);
}

// ----------------------------------------------------------------------------

public void Q2_Start(int objectiveID, int client) {
	
	if( g_iNbQuest[client] > 3 && Math_GetRandomPow(0, 2) == 0 ) {
		rp_QuestStepComplete(client, objectiveID);
	}
	else {
		g_iNbQuest[client]++;
	
		char classname[64];
		Format(classname, sizeof(classname), "rp_mail_%s", g_poste[g_iRandomJob[client][g_iNbQuest[client]]][1]);
		
		ActualizeCurrentIndex(client, classname);
		
		char s[256];
		Format(s, sizeof(s), "%s", g_poste[g_iRandomJob[client][g_iNbQuest[client]]][0]);
		
		String_WordWrap(s, 40);
		
		Menu menu = new Menu(MenuNothing);
		menu.SetTitle("Quête: %s", QUEST_NAME);
		menu.AddItem("", s, ITEMDRAW_DISABLED);
		menu.ExitButton = false;
		menu.Display(client, 60);
		
		g_iDuration[client] = 2 * 60;
	}
}

public void Q2_Frame(int objectiveID, int client) {
	g_iDuration[client]--;
	
	float origin[3], pos[3];
	
	int entityIndex = g_iCurrentIndex[client];
	if( entityIndex == -1 )
		return;
	
	Entity_GetAbsOrigin(entityIndex, pos);
	
	ServerCommand("sm_effect_gps %d %f %f %f", client, pos[0], pos[1], pos[2]);
	
	GetClientAbsOrigin(client, origin);
	
	if (GetVectorDistance(pos, origin) < 64.0)
		rp_QuestStepComplete(client, objectiveID);
	else if (g_iDuration[client] <= 0)
		rp_QuestStepFail(client, objectiveID);
	else
		PrintHintText(client, "<b>Quête</b>: %s\n<b>Temps restant</b>: %dsec\n<b>Objectif</b>: %s", QUEST_NAME, g_iDuration[client], QUEST_RESUME1);
}

public void Q2_Done(int objectiveID, int client) {
	Q1_Abort(objectiveID, client);
	
	int toPay = 160;
	int cap = rp_GetRandomCapital(1);
	rp_SetJobCapital(cap, rp_GetJobCapital(cap) - g_iNbQuest[client] * toPay);
	
	rp_ClientMoney(client, i_AddToPay, g_iNbQuest[client] * toPay);
	CPrintToChat(client, ""...MOD_TAG..." Vous venez de recevoir %d$.", g_iNbQuest[client] * toPay);
	
	rp_ClientXPIncrement(client, g_iNbQuest[client] * 35);
	
	Menu menu = new Menu(MenuNothing);
	menu.SetTitle("Quête: %s", QUEST_NAME);
	menu.ExitButton = false;
	menu.Display(client, 1);
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

public void ActualizeCurrentIndex(int client, char[] classname) {
	char nameEntity[64];
	
	for (int i = 0; i < 2048; i++) {
		if (!IsValidEdict(i) || !IsValidEntity(i))
			continue;
		
		GetEntityClassname(i, nameEntity, sizeof(nameEntity));
		
		if (StrEqual(classname, nameEntity)) {
			g_iCurrentIndex[client] = i;
			break;
		}
	}
} 