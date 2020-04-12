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


#define QUEST_UNIQID	"kill-008"
#define QUEST_NAME      "Fine lame"
#define QUEST_TYPE      quest_daily
#define QUEST_ITEM      236
#define QUEST_RATIO		128

public Plugin myinfo =  {
	name = "Quête: "...QUEST_NAME, author = "KoSSoLaX", 
	description = "RolePlay - Quête Meurtre:"...QUEST_NAME, 
	version = __LAST_REV__, url = "https://www.ts-x.eu"
};

int g_iQuest, g_iDuration[MAXPLAYERS + 1], g_iCurrent[MAXPLAYERS + 1], g_iKilled[MAXPLAYERS + 1][MAXPLAYERS + 1];
bool g_bRunning = false;

public void OnPluginStart() {
	RegServerCmd("rp_quest_reload", Cmd_PluginReloadSelf);
}
public void OnAllPluginsLoaded() {
	g_iQuest = rp_RegisterQuest(QUEST_UNIQID, QUEST_NAME, QUEST_TYPE, fwdCanStart);
	if (g_iQuest == -1)
		SetFailState("Erreur lors de la création de la quête %s %s", QUEST_UNIQID, QUEST_NAME);
	
	int i;
	rp_QuestAddStep(g_iQuest, i++, Q1_Start, Q1_Frame, Q1_Abort, Q1_End);
}
public void OnClientPostAdminCheck(int client) {
	for (int i = 1; i <= MaxClients; i++)
		g_iKilled[i][client] = 0;
}
// ----------------------------------------------------------------------------
public bool fwdCanStart(int client) {
	if( g_bRunning )
		return false;
	if( GetClientCount(true) < 30 )
		return false;
	if( rp_GetClientInt(client, i_PlayerLVL) < 342 )
		return false;
	int job = rp_GetClientJobID(client);
	
	if( job == 1 || job == 101 )
		return false;
	
	return true;
}
public void Q1_Start(int objectiveID, int client) {
	Menu menu = new Menu(MenuNothing);
	
	menu.SetTitle("Quète: %s", QUEST_NAME);
	menu.AddItem("", "Interlocuteur anonyme :", ITEMDRAW_DISABLED);
	menu.AddItem("", "Bonjour collègue, on a de nouveaux projets pour toi.", ITEMDRAW_DISABLED);
	menu.AddItem("", "----------------", ITEMDRAW_DISABLED);
	menu.AddItem("", "Tuer des citoyens à l'aide de votre couteau.", ITEMDRAW_DISABLED);
	menu.AddItem("", "----------------", ITEMDRAW_DISABLED);
	menu.AddItem("", "Si tu arrives à le faire en moins de 24 heures", ITEMDRAW_DISABLED);
	menu.AddItem("", "nous t'offrons 250$ par meurtre et une arme.", ITEMDRAW_DISABLED);
	
	menu.ExitButton = false;
	menu.Display(client, 60);
	g_bRunning = true;
	
	g_iDuration[client] = 24 * 60;
	g_iCurrent[client] = 0;
	for (int i = 1; i <= MaxClients; i++)
		g_iKilled[client][i] = 0;
	
	rp_HookEvent(client, RP_OnPlayerKill, fwdOnPlayerKill);
	rp_HookEvent(client, RP_PlayerCanKill, fwdOnPlayerCanKill);
}
public Action fwdOnPlayerCanKill(int attacker, int victim) {
	if( IsKillEligible(attacker, victim, "weapon_knife") )
		return Plugin_Handled;
	return Plugin_Continue;
}
public Action fwdOnPlayerKill(int attacker, int victim, char weapon[64]) {
	if( IsKillEligible(attacker, victim, weapon) ) {
		g_iCurrent[attacker]++;
		g_iKilled[attacker][victim] = 1;
		return Plugin_Handled;
	}
	return Plugin_Continue;
}
public void Q1_Abort(int objectiveID, int client) {
	CreateTimer(60.0 * 60.0, task_NewMission);
	rp_UnhookEvent(client, RP_OnPlayerKill, fwdOnPlayerKill);
	rp_UnhookEvent(client, RP_PlayerCanKill, fwdOnPlayerCanKill);
	PrintHintText(client, "<b>Quête</b>: %s\nLa quête est terminée.", QUEST_NAME);
	for (int i = 1; i <= MaxClients; i++)
		g_iKilled[client][i] = 0;
}
public void Q1_Frame(int objectiveID, int client) {
	g_iDuration[client]--;
	
	if( g_iCurrent[client] >= 20 ) {
		rp_QuestStepComplete(client, objectiveID);
	}
	else if (g_iDuration[client] <= 0) {
		if( g_iCurrent[client] >= 1 )
			rp_QuestStepComplete(client, objectiveID);
		else
			rp_QuestStepFail(client, objectiveID);
	}
	else {
		PrintHintText(client, "<b>Quête</b>: %s\n<b>Temps restant</b>: %dsec\n<b>Tué</b>: %d", QUEST_NAME, g_iDuration[client], g_iCurrent[client]);
		
		int target = getNearestEligible(client);
		if( IsValidClient(target) ) {
			rp_Effect_BeamBox(client, target, NULL_VECTOR, 255, 0, 0);
		}
	}
}
public void Q1_End(int objectiveID, int client) {
	Q1_Abort(objectiveID, client);
	
	Menu menu = new Menu(MenuNothing);
	
	menu.SetTitle("Quète: %s", QUEST_NAME);
	menu.AddItem("", "Interlocuteur anonyme :", ITEMDRAW_DISABLED);
	menu.AddItem("", "Votre chef vous remercie !", ITEMDRAW_DISABLED);
	
	menu.ExitButton = false;
	menu.Display(client, 10);
	
	int cap = rp_GetClientJobID(client);
	int win = g_iCurrent[client] * QUEST_RATIO;
	rp_SetJobCapital(cap, rp_GetJobCapital(cap) - win);
	rp_ClientMoney(client, i_AddToPay, win); 
	rp_ClientGiveItem(client, QUEST_ITEM);
	rp_ClientXPIncrement(client, win / 2);
}
public Action task_NewMission(Handle timer, any none) {
	g_bRunning = false;
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
// ----------------------------------------------------------------------------
public bool IsKillEligible(int attacker, int victim, const char weapon[64]) {
	if( g_iKilled[attacker][victim] )
		return false;
	if( attacker == victim )
		return false;
	if( rp_IsClientNew(victim) || !rp_IsTutorialOver(victim) )
		return false;
	if( rp_GetClientBool(victim, b_GameModePassive) )
		return false;
	int bit = rp_GetZoneBit(rp_GetPlayerZone(victim));
	if( bit & BITZONE_EVENT || bit & BITZONE_PEACEFULL || bit & BITZONE_PVP )
		return false;
	if( rp_GetClientInt(victim, i_JailTime) >= 10 && ( bit & BITZONE_JAIL || bit & BITZONE_HAUTESECU || bit & BITZONE_LACOURS ) )
		return false;
	
	if( StrContains(weapon, "weapon_knife") == 0 || StrContains(weapon, "weapon_bayonet") == 0 )
		return true;
	
	return true;
}
int getNearestEligible(int client) {
	
	int target = -1;
	float src[3], dst[3], tmp, delta = 9999999.9;
	GetClientAbsOrigin(client, src);
	
	
	for (int i = 1; i <= MaxClients; i++) {
		if( IsValidClient(i) && IsPlayerAlive(i) && IsKillEligible(client, i, "weapon_knife") ) {
			
			GetClientAbsOrigin(client, dst);
			tmp = GetVectorDistance(src, dst);
			if( tmp < delta ) {
				delta = tmp;
				target = i;
			}
		}
	}
	return target;
}
