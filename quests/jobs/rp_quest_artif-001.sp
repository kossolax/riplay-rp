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

#define QUEST_UNIQID    	"14juillet"
#define QUEST_NAME      	"14 Juillet"
#define QUEST_TYPE      	quest_story
#define QUEST_RESUME1   	"Effectuez un feu d'artifice"
#define PLANQUE_ARTIFICIER	222
#define MAX_POS 			6
#define LAUNCHER_MODEL "models/shells/shell_57.mdl"
#define LAUNCHER_SCALE    25.0


int g_iQuest, g_iDuration[MAXPLAYERS + 1], g_iStep[MAXPLAYERS + 1], g_iObjective[MAXPLAYERS + 1], g_iQ6, g_iEnt[MAX_POS][MAXPLAYERS+1];

float[][3] g_fPos =  {
	{ 2230.914062, 1495.746337, -1135.968750 }, // Comico
	{ 1389.837402, -2243.317626, -1119.968750 }, // Hôpital
	{ 2568.508789, -4702.079589, -991.968750 }, //Loto
	{ -2498.041748, -3107.023193, -1439.968750 }, //Artisan
	{ -2783.780517, 658.963928, -1559.968750 }, // Armu
	{ -2204.935546, -253.964401, -1590.968750 } //Immo
};

public Plugin myinfo =  {
	name = "Quête: "...QUEST_NAME, author = "PastyBully", 
	description = "RolePlay - Quête Joueur: "...QUEST_NAME, 
	version = __LAST_REV__, url = "https://rpweb.riplay.fr/#/"
};

public void OnPluginStart()
{
	RegServerCmd("rp_quest_reload", Cmd_PluginReloadSelf);
}

public void OnAllPluginsLoaded() {
	g_iQuest = rp_RegisterQuest(QUEST_UNIQID, QUEST_NAME, QUEST_TYPE, fwdCanStart);
	
	if (g_iQuest == -1)
		SetFailState("Erreur lors de la création de la quête %s %s", QUEST_UNIQID, QUEST_NAME);
	
	int i;
	rp_QuestAddStep(g_iQuest, i++, Q1_Start, Q1_Frame, Q1_Abort, Q1_Done);
	rp_QuestAddStep(g_iQuest, i++, Q2_Start, Q2_Frame, Q1_Abort, Q2_Done);
	
	for (int j = 0; j < MAX_POS; j++)
	{
		rp_QuestAddStep(g_iQuest, i++, Q3_Start, Q3_Frame, Q1_Abort, QUEST_NULL);
		rp_QuestAddStep(g_iQuest, i++, Q4_Start, Q4_Frame, Q1_Abort, Q4_Done);
	}
	
	rp_QuestAddStep(g_iQuest, i++, Q5_Start, Q5_Frame, Q1_Abort, QUEST_NULL);
	rp_QuestAddStep(g_iQuest, i++, Q6_Start, Q6_Frame, Q1_Abort, Q6_Done);
}

// ----------------------------------------------------------------------------

public bool fwdCanStart(int client)
{
	if (rp_GetClientJobID(client) != 131)
		return false;
	
	return true;
}

public void Q1_Start(int objectiveID, int client)
{
	g_iStep[client] = 0;
	
	char s[512];
	Format(s, sizeof(s), "Votre mission, si toutefois vous l'acceptez est de faire un feu d'artifice. Pour cela, vous devez d'abord aller vous renseigner à la mairie sur les lieux d'explosion.");
	String_WordWrap(s, 40);
	
	Menu menu = new Menu(MenuNothing);
	
	menu.SetTitle("Quête: %s", QUEST_NAME);
	menu.AddItem("", s, ITEMDRAW_DISABLED);
	menu.ExitButton = false;
	menu.Display(client, MENU_TIME_FOREVER);
	
	g_iDuration[client] = 2 * 60;
}

public void Q1_Frame(int objectiveID, int client)
{
	g_iDuration[client]--;
	
	float pos[3] = MAIRIE_POS, origin[3];
	
	ServerCommand("sm_effect_gps %d %f %f %f", client, pos[0], pos[1], pos[2]);
	
	GetClientAbsOrigin(client, origin);
	
	if (GetVectorDistance(origin, pos) < 64)
	{
		rp_QuestStepComplete(client, objectiveID);
	}
	else if (g_iDuration[client] <= 0)
		rp_QuestStepFail(client, objectiveID);
	else {
		PrintHintText(client, "<b>Quête</b>: %s\n<b>Temps restant</b>: %dsec\n<b>Objectif</b>: %s", QUEST_NAME, g_iDuration[client], QUEST_RESUME1);
	}
}

public void Q1_Abort(int objectiveID, int client)
{
	PrintHintText(client, "<b>Quête</b>: %s\nLa quête est terminée.", QUEST_NAME);
}

public void Q1_Done(int objectiveID, int client)
{
	CPrintToChat(client, ""...MOD_TAG..." Vous avez maintenant la liste de tous les lieux d'explosion.");
}

// ----------------------------------------------------------------------------

public void Q2_Start(int objectiveID, int client)
{
	char s[512];
	Format(s, sizeof(s), "Maintenant, vous devez aller récupérer les explosifs nécessaires au feu d'artifice dans votre planque.");
	String_WordWrap(s, 40);
	
	Menu menu = new Menu(MenuNothing);
	
	menu.SetTitle("Quête: %s", QUEST_NAME);
	menu.AddItem("", s, ITEMDRAW_DISABLED);
	menu.ExitButton = false;
	menu.Display(client, MENU_TIME_FOREVER);
	
	g_iDuration[client] = 2 * 60;
}

public void Q2_Frame(int objectiveID, int client)
{
	g_iDuration[client]--;
	
	float pos[3], origin[3];
	
	pos[0] = (rp_GetZoneFloat(PLANQUE_ARTIFICIER, zone_type_min_x) + rp_GetZoneFloat(PLANQUE_ARTIFICIER, zone_type_max_x)) / 2;
	pos[1] = (rp_GetZoneFloat(PLANQUE_ARTIFICIER, zone_type_min_y) + rp_GetZoneFloat(PLANQUE_ARTIFICIER, zone_type_max_y)) / 2;
	pos[2] = rp_GetZoneFloat(PLANQUE_ARTIFICIER, zone_type_min_z);
	
	ServerCommand("sm_effect_gps %d %f %f %f", client, pos[0], pos[1], pos[2]);
	
	GetClientAbsOrigin(client, origin);
	
	if (GetVectorDistance(origin, pos) < 64)
	{
		rp_QuestStepComplete(client, objectiveID);
	}
	else if (g_iDuration[client] <= 0)
		rp_QuestStepFail(client, objectiveID);
	else {
		PrintHintText(client, "<b>Quête</b>: %s\n<b>Temps restant</b>: %dsec\n<b>Objectif</b>: %s", QUEST_NAME, g_iDuration[client], QUEST_RESUME1);
	}
}

public void Q2_Done(int objectiveID, int client)
{
	CPrintToChat(client, ""...MOD_TAG..." Vous possédez désormais les explosifs et leurs détonateurs. Nous allons maintenant les placer.");
}

// ----------------------------------------------------------------------------

public void Q3_Start(int objectiveID, int client)
{
	char s[512];
	Format(s, sizeof(s), "Rendez-vous au prochain lieu afin de placer un explosif.");
	String_WordWrap(s, 40);
	
	Menu menu = new Menu(MenuNothing);
	
	menu.SetTitle("Quête: %s", QUEST_NAME);
	menu.AddItem("", s, ITEMDRAW_DISABLED);
	menu.ExitButton = false;
	menu.Display(client, MENU_TIME_FOREVER);
	
	g_iDuration[client] = 2 * 60;
}

public void Q3_Frame(int objectiveID, int client)
{
	g_iDuration[client]--;
	
	float pos[3], origin[3];
	pos[0] = g_fPos[g_iStep[client]][0];
	pos[1] = g_fPos[g_iStep[client]][1];
	pos[2] = g_fPos[g_iStep[client]][2];
	
	rp_Effect_BeamBox(client, -1, pos);
	
	GetClientAbsOrigin(client, origin);
	
	if (GetVectorDistance(origin, pos) < 128)
	{
		rp_QuestStepComplete(client, objectiveID);
	}
	else if (g_iDuration[client] <= 0)
		rp_QuestStepFail(client, objectiveID);
	else {
		PrintHintText(client, "<b>Quête</b>: %s\n<b>Temps restant</b>: %dsec\n<b>Objectif</b>: %s", QUEST_NAME, g_iDuration[client], QUEST_RESUME1);
	}
}

// ----------------------------------------------------------------------------

public void Q4_Start(int objectiveID, int client)
{
	char s[512];
	Format(s, sizeof(s), "Maintenant placer un explosif en apputant la touche E.");
	String_WordWrap(s, 40);
	
	g_iObjective[client] = objectiveID;
	
	rp_HookEvent(client, RP_OnPlayerUse, fwdPlayerUse);
	
	Menu menu = new Menu(MenuNothing);
	
	menu.SetTitle("Quête: %s", QUEST_NAME);
	menu.AddItem("", s, ITEMDRAW_DISABLED);
	menu.ExitButton = false;
	menu.Display(client, MENU_TIME_FOREVER);
	
	g_iDuration[client] = 2 * 60;
}

public void Q4_Frame(int objectiveID, int client)
{
	g_iDuration[client]--;
	
	if (g_iDuration[client] <= 0)
		rp_QuestStepFail(client, objectiveID);
	else {
		PrintHintText(client, "<b>Quête</b>: %s\n<b>Temps restant</b>: %dsec\n<b>Objectif</b>: %s", QUEST_NAME, g_iDuration[client], QUEST_RESUME1);
	}
}

public void Q4_Done(int objectiveID, int client)
{
	rp_UnhookEvent(client, RP_OnPlayerUse, fwdPlayerUse);
	g_iStep[client]++;
}

// ----------------------------------------------------------------------------

public void Q5_Start(int objectiveID, int client)
{
	char s[512];
	Format(s, sizeof(s), "Rendez-vous à un point stratégique pour observer le feu d'artifice.");
	String_WordWrap(s, 40);
	
	Menu menu = new Menu(MenuNothing);
	
	menu.SetTitle("Quête: %s", QUEST_NAME);
	menu.AddItem("", s, ITEMDRAW_DISABLED);
	menu.ExitButton = false;
	menu.Display(client, MENU_TIME_FOREVER);
	
	g_iDuration[client] = 2 * 60;
}

public void Q5_Frame(int objectiveID, int client)
{
	g_iDuration[client]--;
	
	float pos[3] = {-720.883239, -1664.011840, -1455.968750}, origin[3];  
	
	ServerCommand("sm_effect_gps %d %f %f %f", client, pos[0], pos[1], pos[2]);
	
	GetClientAbsOrigin(client, origin);
	
	if (GetVectorDistance(origin, pos) < 64)
	{
		rp_QuestStepComplete(client, objectiveID);
	}
	else if (g_iDuration[client] <= 0)
		rp_QuestStepFail(client, objectiveID);
	else {
		PrintHintText(client, "<b>Quête</b>: %s\n<b>Temps restant</b>: %dsec\n<b>Objectif</b>: %s", QUEST_NAME, g_iDuration[client], QUEST_RESUME1);
	}
}

// ----------------------------------------------------------------------------

public void Q6_Start(int objectiveID, int client)
{
	g_iQ6 = objectiveID;
	
	Menu menu = new Menu(MenuArtifice);
	
	menu.SetTitle("Etes-vous prêt à faire exploser le feu d'artifice ?", QUEST_NAME);
	menu.AddItem("0", "Oui");
	menu.ExitButton = false;
	menu.Display(client, MENU_TIME_FOREVER);
	
	g_iDuration[client] = 2 * 60;
}

public void Q6_Frame(int objectiveID, int client)
{
	g_iDuration[client]--;

	if (g_iDuration[client] <= 0)
		rp_QuestStepFail(client, objectiveID);
	else {
		PrintHintText(client, "<b>Quête</b>: %s\n<b>Temps restant</b>: %dsec\n<b>Objectif</b>: %s", QUEST_NAME, g_iDuration[client], QUEST_RESUME1);
	}
}

public void Q6_Done(int objectiveID, int client)
{
	int cap = rp_GetRandomCapital(1);
	
	if (rp_GetClientInt(client, i_Abonne) > 0){
		rp_SetJobCapital(cap, rp_GetJobCapital(cap) - 5000);
		CPrintToChat(client, ""...MOD_TAG..." Vous venez de recevoir %d$.", 2500);
		CPrintToChat(client, ""...MOD_TAG..." Votre Abonnement vous rapporte un bonus de %d$.", 2500);
		rp_ClientXPIncrement(client, 750);
		rp_ClientJetonpassIncrement(client, 10);
	}
	
	else {
		rp_SetJobCapital(cap, rp_GetJobCapital(cap) - 2500);
		rp_ClientMoney(client, i_AddToPay, 2500);
		rp_ClientXPIncrement(client, 500);
		rp_ClientJetonpassIncrement(client, 10);
	}
	
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

public int MenuArtifice(Handle menu, MenuAction action, int client, int param2) {
	if (action == MenuAction_End) {
		if (menu != INVALID_HANDLE)
			CloseHandle(menu);
	}
	else if (action == MenuAction_Select) {
		char options[128];
		GetMenuItem(menu, param2, options, sizeof(options));
		
		if(StrEqual(options, "0"))
		{
			CPrintToChat(client, ""...MOD_TAG..." L'explosion va avoir lieu dans le sens des aiguilles d'une montre en partant du commissariat.");
			CPrintToChat(client, ""...MOD_TAG..." ========FEU========");
			float pos[3];
			
			float timePlus = 0.0;
			for (int j = 0; j < MAX_POS; j++)
			{	
				pos[0] = g_fPos[j][0];
				pos[1] = g_fPos[j][1];
				pos[2] = g_fPos[j][2];
				
				for (int k = 0; k < 2; k++) 
					ServerCommand("sm_effect_fireworks %f %d %f %f %f", 1.0 + timePlus, 0, pos[0], pos[1], pos[2]);
					
				AcceptEntityInput(g_iEnt[j][client], "Kill");
				
				timePlus += 2.5;
			}
			
			rp_QuestStepComplete(client, g_iQ6);
		}
		
		if (menu != INVALID_HANDLE)
			CloseHandle(menu);
	}
}

public Action fwdPlayerUse(int client)
{
	float origin[3];
	
	GetClientAbsOrigin(client, origin);
	
	if (GetVectorDistance(origin, g_fPos[g_iStep[client]]) < 128)
	{
		g_iEnt[g_iStep[client]][client] = CreateEntityByName("hegrenade_projectile");
	
		DispatchKeyValue(g_iEnt[g_iStep[client]][client], "classname", "fireworks");
		DispatchSpawn(g_iEnt[g_iStep[client]][client]);
		
		Entity_SetModel(g_iEnt[g_iStep[client]][client], LAUNCHER_MODEL);
		Entity_SetOwner(g_iEnt[g_iStep[client]][client], client);
		Entity_SetAbsOrigin(g_iEnt[g_iStep[client]][client], g_fPos[g_iStep[client]]);
		
		SetEntityGravity(g_iEnt[g_iStep[client]][client], 0.1);
		SetEntProp(g_iEnt[g_iStep[client]][client], Prop_Send, "m_CollisionGroup", COLLISION_GROUP_WEAPON);
		SetEntPropEnt(g_iEnt[g_iStep[client]][client], Prop_Send, "m_hOwnerEntity", client);
		SetEntPropFloat(g_iEnt[g_iStep[client]][client], Prop_Send, "m_flModelScale", LAUNCHER_SCALE);
		
		rp_QuestStepComplete(client, g_iObjective[client]);
	}
	else
	{
		CPrintToChat(client, ""...MOD_TAG..." Vous êtes trop loin du lieu d'explosion.");
	}
} 
