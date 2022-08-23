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
#include <colors_csgo>	// https://forums.alliedmods.net/showthread.php?p=2205447#post2205447
#include <smlib>		// https://github.com/bcserv/smlib
#include <emitsoundany> // https://forums.alliedmods.net/showthread.php?t=237045
#include <emitsoundany> // https://forums.alliedmods.net/showthread.php?t=237045


#include <roleplay.inc>	// https://www.ts-x.eu
#include <advanced_motd>

#define QUEST_UNIQID	"000-tutorial"
#define	QUEST_NAME		"Tutorial"
#define	QUEST_TYPE		quest_story

public Plugin myinfo = {
	name = "Quête: Tutorial", author = "KoSSoLaX",
	description = "RolePlay - Quête: Tutorial",
	version = __LAST_REV__, url = "https://www.ts-x.eu"
};

int g_iQuest;

char qualif[][] =  	{ "TUTO_Jobs_Recommanded", "TUTO_Jobs_Fun", "TUTO_Jobs_Hard", "TUTO_Jobs_Selling", "TUTO_Jobs_Unrecommanded"};
int g_iJob[] =  			{ 15, 25, 46, 65, 86, 15, 135, 175, 225};
int g_iRecom[MAX_JOBS];
int g_iDefaultJob[MAXPLAYERS];

int g_iDisableAsk[65];
#define FREE_JOB	5
	
// TODO: Déplacer les récompenses dans les fonctions appropriées

int g_iQ9, g_iQ12;
public void OnPluginStart() {
	LoadTranslations("core.phrases");
	LoadTranslations("common.phrases");
	LoadTranslations("roleplay.phrases");
	LoadTranslations("roleplay.items.phrases");
	LoadTranslations("roleplay.quests.story.phrases");
	
	g_iRecom[116] = 0;
	g_iRecom[87] = g_iRecom[96] = g_iRecom[226] = 1;
	g_iRecom[46] = g_iRecom[36] = 2;
	g_iRecom[15] = g_iRecom[26] = g_iRecom[56] = g_iRecom[65] = g_iRecom[76] = g_iRecom[135] = g_iRecom[176] = g_iRecom[216] = 3;
	g_iRecom[195] = 4;
	
	RegServerCmd("rp_quest_reload", Cmd_PluginReloadSelf);
	
	for (int j = 1; j <= MaxClients; j++)
		if( IsValidClient(j) )
			OnClientPostAdminCheck(j);
}
public int Sort_ByJob(int a, int b, const int[] array, Handle hndl) {
	int d1 = rp_GetJobInt((a - (a % 10))+1, job_type_quota) - rp_GetJobInt((a - (a % 10))+1, job_type_current);
	int d2 = rp_GetJobInt((b - (b % 10))+1, job_type_quota) - rp_GetJobInt((b - (b % 10))+1, job_type_current);
	
	return d2 - d1;
}
public void OnAllPluginsLoaded() {
	SortCustom1D(g_iJob, sizeof(g_iJob), Sort_ByJob);
	
	g_iQuest = rp_RegisterQuest(QUEST_UNIQID, QUEST_NAME, QUEST_TYPE, fwdCanStart);
	if( g_iQuest == -1 )
		SetFailState("Erreur lors de la création de la quête %s %s", QUEST_UNIQID, QUEST_NAME);
	
	int i;
	rp_QuestAddStep(g_iQuest, i++, QUEST_NULL,	Q1_Frame,	QUEST_NULL,	QUEST_NULL);
	rp_QuestAddStep(g_iQuest, i++, QUEST_NULL,	Q2_Frame,	QUEST_NULL,	QUEST_NULL);
	rp_QuestAddStep(g_iQuest, i++, QUEST_NULL,	Q3_Frame,	QUEST_NULL,	QUEST_NULL);
	rp_QuestAddStep(g_iQuest, i++, QUEST_NULL,	Q4_Frame,	QUEST_NULL,	QUEST_NULL);
	rp_QuestAddStep(g_iQuest, i++, QUEST_NULL,	Q5_Frame,	QUEST_NULL,	QUEST_NULL);
	rp_QuestAddStep(g_iQuest, i++, QUEST_NULL,	Q6_Frame,	QUEST_NULL,	QUEST_NULL);
	rp_QuestAddStep(g_iQuest, i++, QUEST_NULL,	Q7_Frame,	QUEST_NULL,	QUEST_NULL);
	rp_QuestAddStep(g_iQuest, i++, QUEST_NULL,	Q8_Frame,	QUEST_NULL,	QUEST_NULL);
	rp_QuestAddStep(g_iQuest, i++, Q9_Start,	Q9_Frame,	Q9_Abort,	Q9_Abort);
	rp_QuestAddStep(g_iQuest, i++, Q92_Start,	Q92_Frame,	Q92_Abort,	QUEST_NULL);
	rp_QuestAddStep(g_iQuest, i++, QUEST_NULL,	Q10_Frame,	QUEST_NULL,	QUEST_NULL);
	rp_QuestAddStep(g_iQuest, i++, QUEST_NULL,	Q12_Frame,	QUEST_NULL,	QUEST_NULL);
	rp_QuestAddStep(g_iQuest, i++, QUEST_NULL,	Q13_Frame,	QUEST_NULL,	QUEST_NULL);
	rp_QuestAddStep(g_iQuest, i++, Q14_Start,	Q14_Frame,	QUEST_NULL,	Q14_Done);
}
// ----------------------------------------------------------------------------
public void OnClientPostAdminCheck(int client) {
	rp_HookEvent(client, RP_OnPlayerCommand, fwdCommand);
	rp_HookEvent(client, RP_OnFrameSeconde, fwdFrame);
	g_iDisableAsk[client] = 0;
}
public Action fwdFrame(int client) {
	if( rp_IsClientNew(client) && rp_IsTutorialOver(client) && rp_GetClientInt(client, i_AllowedDismiss) > 0 && rp_GetClientInt(client, i_Job) == 0 && rp_ClientCanDrawPanel(client) && g_iDisableAsk[client] < GetTime() ) {
		drawJobMenu(client);
	}
}
public Action fwdCommand(int client, char[] command, char[] arg) {	
	if( StrEqual(command, "aide") || StrEqual(command, "aides") || StrEqual(command, "help")  ) { // C'est pour nous !
		
		OpenHelpMenu(client, 1, 0);
		
		return Plugin_Handled;
	}
	else if( StrEqual(command, "wiki") ) {
		
		char url[1024], sso[256];
		rp_GetClientSSO(client, sso, sizeof(sso));
		Format(url, sizeof(url), "https://www.ts-x.eu/index.php?page=aide%s", sso);
		
		RP_ShowMOTD(client, url);
		
		return Plugin_Handled;
	}
	return Plugin_Continue;
}
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
public bool fwdCanStart(int client) {
	return true;
}
// ----------------------------------------------------------------------------
public void Q1_Frame(int objectiveID, int client) {
	float origin[3], target[3] = {1372.0, 30.0, -2146.0};
	GetClientAbsOrigin(client, origin);
	
	if( rp_ClientCanDrawPanel(client) ) {
		char title[128], text[2048];
		Handle panel = CreatePanel();
		
		Format(title, sizeof(title), "%T", "TUTO_1_Title", client);
		Format(text, sizeof(text), "%T", "TUTO_1_Text", client);
		
		String_WordWrap(text, 40);
		
		SetPanelTitle(panel, title);
		DrawPanelText(panel, text);
		
		rp_SendPanelToClient(panel, client, 1.1);
		CreateTimer(1.1, PostKillHandle, panel);
	}

	
	if( GetVectorDistance(target, origin) < 128.0 ) {
		rp_QuestStepComplete(client, objectiveID);
	}
	else {
		ServerCommand("sm_effect_gps %d %f %f %f", client, target[0], target[1], target[2]);
	}
}
public void Q2_Frame(int objectiveID, int client) {
	float origin[3], target[3] = {2034.0, 1391.0, -2014.0};
	GetClientAbsOrigin(client, origin);
	
	if( rp_ClientCanDrawPanel(client) ) {
		char title[128], text[2048];
		Handle panel = CreatePanel();
		
		Format(title, sizeof(title), "%T", "TUTO_2_Title", client);
		Format(text, sizeof(text), "%T", "TUTO_2_Text", client);
		
		String_WordWrap(text, 40);
		
		SetPanelTitle(panel, title);
		DrawPanelText(panel, text);
		
		rp_SendPanelToClient(panel, client, 1.1);
		CreateTimer(1.1, PostKillHandle, panel);
	}
	
	if( GetVectorDistance(target, origin) < 64.0 ) {
		rp_QuestStepComplete(client, objectiveID);
	}
	else {
		ServerCommand("sm_effect_gps %d %f %f %f", client, target[0], target[1], target[2]);
	}
}
public void Q3_Frame(int objectiveID, int client) {
	float origin[3], target[3] = {2189.0, -12.0, -2134.0};
	GetClientAbsOrigin(client, origin);
	
	if( rp_ClientCanDrawPanel(client) ) {
		char title[128], text[2048];
		Handle panel = CreatePanel();
		
		Format(title, sizeof(title), "%T", "TUTO_3_Title", client);
		Format(text, sizeof(text), "%T", "TUTO_3_Text", client);
		
		String_WordWrap(text, 40);
		
		SetPanelTitle(panel, title);
		DrawPanelText(panel, text);
		
		rp_SendPanelToClient(panel, client, 1.1);
		CreateTimer(1.1, PostKillHandle, panel);
	}
	
	if( GetVectorDistance(target, origin) < 64.0 ) {		
		if( rp_GetClientInt(client, i_Money)+rp_GetClientInt(client, i_Bank) < 2500 ) {
			rp_ClientMoney(client, i_Money, 2500);
		}
		else {
			rp_ClientMoney(client, i_Bank, -2500);
			rp_ClientMoney(client, i_Money, 2500);
		}
		
		rp_QuestStepComplete(client, objectiveID);
	}
	else {
		ServerCommand("sm_effect_gps %d %f %f %f", client, target[0], target[1], target[2]);
	}
}
public void Q4_Frame(int objectiveID, int client) {
	float origin[3], target[3] = {2288.0, 136.0, -2134.0};
	GetClientAbsOrigin(client, origin);
	
	if( rp_ClientCanDrawPanel(client) ) {
		char title[128], text[2048];
		Handle panel = CreatePanel();
		
		Format(title, sizeof(title), "%T", "TUTO_4_Title", client);
		Format(text, sizeof(text), "%T", "TUTO_4_Text", client);
		
		String_WordWrap(text, 40);
		
		SetPanelTitle(panel, title);
		DrawPanelText(panel, text);
		
		rp_SendPanelToClient(panel, client, 1.1);
		CreateTimer(1.1, PostKillHandle, panel);
	}
	
	if( rp_GetClientInt(client, i_Money) <= 0 ) {
		rp_QuestStepComplete(client, objectiveID);
	}
	else {
		ServerCommand("sm_effect_gps %d %f %f %f", client, target[0], target[1], target[2]);
	}
}
public void Q5_Frame(int objectiveID, int client) {
	float origin[3], target[3] = {156.8, -859.9, -2143.9};
	
	GetClientAbsOrigin(client, origin);
	
	//if( rp_ClientCanDrawPanel(client) ) {
		char title[128], text[2048];
		Handle panel = CreatePanel();
		
		Format(title, sizeof(title), "%T", "TUTO_5_Title", client);
		Format(text, sizeof(text), "%T", "TUTO_5_Text", client);
		
		String_WordWrap(text, 40);
		
		SetPanelTitle(panel, title);
		DrawPanelText(panel, text);
		
		rp_SendPanelToClient(panel, client, 1.1);
		CreateTimer(1.1, PostKillHandle, panel);
	//}


	if( GetVectorDistance(target, origin) < 128.0 ) {
		int itemid = 150;
		char tmp[128];
		rp_GetItemData(itemid, item_type_name, tmp, sizeof(tmp));
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Item_Give", client, 1, tmp);
		
		if( rp_GetClientItem(client, itemid) == 0 && rp_GetClientItem(client, itemid, true) == 0 ) {
			rp_ClientGiveItem(client, itemid);
		}
		else if( rp_GetClientItem(client, itemid, true) ) {
			rp_ClientGiveItem(client, itemid, -1, true);
			rp_ClientGiveItem(client, itemid,  1, false);
		}

		rp_QuestStepComplete(client, objectiveID);
	}
	else {
		ServerCommand("sm_effect_gps %d %f %f %f", client, target[0], target[1], target[2]);
	}
}
public void Q6_Frame(int objectiveID, int client) {
	float origin[3], target[3] = {-1900.0, 604.0, -2134.0};
	GetClientAbsOrigin(client, origin);
	
	if( rp_ClientCanDrawPanel(client) ) {
		char title[128], text[2048];
		Handle panel = CreatePanel();
		
		Format(title, sizeof(title), "%T", "TUTO_6_Title", client);
		Format(text, sizeof(text), "%T", "TUTO_6_Text", client);
		
		String_WordWrap(text, 40);
		
		SetPanelTitle(panel, title);
		DrawPanelText(panel, text);
		
		rp_SendPanelToClient(panel, client, 1.1);
		CreateTimer(1.1, PostKillHandle, panel);
	}
	
	if( rp_GetClientItem(client, 150) <= 0) {
		rp_QuestStepComplete(client, objectiveID);
	}
	else {
		ServerCommand("sm_effect_gps %d %f %f %f", client, target[0], target[1], target[2]);
	}
}
public void Q7_Frame(int objectiveID, int client) {
	float origin[3], target[3] = {-1192.0, -778.0, -2135.0};
	GetClientAbsOrigin(client, origin);
	
	if( rp_ClientCanDrawPanel(client) ) {
		char title[128], text[2048];
		Handle panel = CreatePanel();
		
		Format(title, sizeof(title), "%T", "TUTO_7_Title", client);
		Format(text, sizeof(text), "%T", "TUTO_7_Text", client);
		
		String_WordWrap(text, 40);
		
		SetPanelTitle(panel, title);
		DrawPanelText(panel, text);
		
		rp_SendPanelToClient(panel, client, 1.1);
		CreateTimer(1.1, PostKillHandle, panel);
	}
	
	if( GetVectorDistance(target, origin) < 64.0 ) {
		
		if( rp_GetClientItem(client, 81, false) + rp_GetClientItem(client, 81, true) <= 0 )
			rp_ClientGiveItem(client, 81);
		
		if( rp_GetClientItem(client, 103, false) + rp_GetClientItem(client, 103, true) <= 0 )
			rp_ClientGiveItem(client, 103);
		
		char tmp[128];
		rp_GetItemData(81, item_type_name, tmp, sizeof(tmp));
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Item_Give", client, 1, tmp);
		rp_GetItemData(103, item_type_name, tmp, sizeof(tmp));
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Item_Give", client, 1, tmp);
		
		rp_QuestStepComplete(client, objectiveID);
	}
	else {
		ServerCommand("sm_effect_gps %d %f %f %f", client, target[0], target[1], target[2]);
	}
}
public void Q8_Frame(int objectiveID, int client) {
	float origin[3], target[3] = {-611.0, -1286.0, -2016.0};
	GetClientAbsOrigin(client, origin);
	
	if( rp_ClientCanDrawPanel(client) ) {
		char title[128], text[2048];
		Handle panel = CreatePanel();
		
		Format(title, sizeof(title), "%T", "TUTO_8_Title", client);
		Format(text, sizeof(text), "%T", "TUTO_8_Text", client);
		
		String_WordWrap(text, 40);
		
		SetPanelTitle(panel, title);
		DrawPanelText(panel, text);
		
		rp_SendPanelToClient(panel, client, 1.1);
		CreateTimer(1.1, PostKillHandle, panel);
	}
	
	if( rp_GetClientItem(client, 81) <= 0 && rp_GetClientItem(client, 103) <= 0 ) {
		rp_QuestStepComplete(client, objectiveID);
	}
	else {
		ServerCommand("sm_effect_gps %d %f %f %f", client, target[0], target[1], target[2]);
	}
}
public void Q9_Frame(int objectiveID, int client) {
	if( rp_ClientCanDrawPanel(client) ) {
		char title[128], text[2048];
		Handle panel = CreatePanel();
		
		Format(title, sizeof(title), "%T", "TUTO_9_Title", client);
		Format(text, sizeof(text), "%T", "TUTO_9_Text", client);
		
		String_WordWrap(text, 40);
		
		SetPanelTitle(panel, title);
		DrawPanelText(panel, text);
		
		rp_SendPanelToClient(panel, client, 1.1);
		CreateTimer(1.1, PostKillHandle, panel);
	}
}
public void Q9_Start(int objectiveID, int client) {
	g_iQ9 = objectiveID;
	rp_HookEvent(client, RP_PrePlayerTalk, OnPlayerTalk);
	
	char szQuery[1024], szSteamID[64];
	GetClientAuthId(client, AUTH_TYPE, szSteamID, sizeof(szSteamID), false);
	
	g_iDefaultJob[client] = -1;
	Format(szQuery, sizeof(szQuery), "SELECT `job_id` FROM `rp_users3` WHERE `steamid`='%s';", szSteamID);
	SQL_TQuery(rp_GetDatabase(), SQL_FindDefaultJob, szQuery, client);
}
public void SQL_FindDefaultJob(Handle owner, Handle handle, const char[] error, any client) {

	if( SQL_FetchRow(handle) )
		g_iDefaultJob[client] = SQL_FetchInt(handle, 0);
	
	if(  handle != INVALID_HANDLE )
		CloseHandle(handle);
}
public void Q9_Abort(int objectiveID, int client) {
	rp_UnhookEvent(client, RP_PrePlayerTalk, OnPlayerTalk);
}
public Action OnPlayerTalk(int client, char[] szSayText, int length, bool local) {
	if( local ) {
		char tmp[256];
		Format(tmp, sizeof(tmp), "%s", szSayText);
		TrimString(tmp);
		
		if( StrEqual(tmp, ".") ) {
			LogToGame("[CHEATING-MARK] %L", client);
		}
		rp_QuestStepComplete(client, g_iQ9);
	}
}
// ----------------------------------------------------------------------------
int g_iQ92;
public void Q92_Start(int objectiveID, int client) {
	g_iQ92 = objectiveID;
	rp_HookEvent(client, RP_OnPlayerUse, fwdUsePhone);
}
public void Q92_Abort(int objectiveID, int client) {
	rp_UnhookEvent(client, RP_OnPlayerUse, fwdUsePhone);
}
public Action fwdUsePhone(int client) {
	float origin[3], target[3] = {-452.0, -2065.0, -2000.0};
	GetClientAbsOrigin(client, origin);
	
	if( GetVectorDistance(origin, target) < 40.0 ) {
		ServerCommand("sm_effect_copter2 0 -2364 %d", client);
		rp_UnhookEvent(client, RP_OnPlayerUse, fwdUsePhone);
		rp_QuestStepComplete(client, g_iQ92);
		if( rp_ClientCanDrawPanel(client) ) {
			Handle panel = CreatePanel();
			char title[128], text[2048];
		
		
			Format(title, sizeof(title), "%T", "TUTO_10_Title", client);
			Format(text, sizeof(text), "%T", "TUTO_10b_Text", client);
		
			String_WordWrap(text, 40);
		
			SetPanelTitle(panel, title);
			DrawPanelText(panel, text);
		
			rp_SendPanelToClient(panel, client, 1.1);
			CreateTimer(1.1, PostKillHandle, panel);
		}
	}
}
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
public void Q92_Frame(int objectiveID, int client) {
	float origin[3], target[3] = {-452.0, -2065.0, -2000.0};
	GetClientAbsOrigin(client, origin);
	
	ServerCommand("sm_effect_gps %d %f %f %f", client, target[0], target[1], target[2]);
	
	if( rp_ClientCanDrawPanel(client) ) {
		Handle panel = CreatePanel();
		
		if( GetTime() %3 == 0 ) {
			EmitSoundToClientAny(client, "DeadlyDesire/princeton/ambiant/phone1.mp3", SOUND_FROM_WORLD, _, _, _, _, _, _, target);
		}
		
		char title[128], text[2048];
		
		Format(title, sizeof(title), "%T", "TUTO_10_Title", client);
		Format(text, sizeof(text), "%T", "TUTO_10_Text", client);
		
		String_WordWrap(text, 40);
		
		SetPanelTitle(panel, title);
		DrawPanelText(panel, text);
		
		rp_SendPanelToClient(panel, client, 1.1);
		CreateTimer(1.1, PostKillHandle, panel);
	}
}
// ----------------------------------------------------------------------------
public void Q10_Frame(int objectiveID, int client) {
	float origin[3], target[3] = {763.0,-4748.0, -2014.0};
	GetClientAbsOrigin(client, origin);
	
	if( rp_ClientCanDrawPanel(client) ) {
		char title[128], text[2048];
		Handle panel = CreatePanel();
		
		Format(title, sizeof(title), "%T", "TUTO_11_Title", client);
		Format(text, sizeof(text), "%T", "TUTO_11_Text", client);
		
		String_WordWrap(text, 40);
		
		SetPanelTitle(panel, title);
		DrawPanelText(panel, text);
		
		rp_SendPanelToClient(panel, client, 1.1);
		CreateTimer(1.1, PostKillHandle, panel);
	}
	
	if( GetVectorDistance(target, origin) < 128.0 ) {
		rp_QuestStepComplete(client, objectiveID);
	}
	else {
		ServerCommand("sm_effect_gps %d %f %f %f", client, target[0], target[1], target[2]);
	}
}
// ----------------------------------------------------------------------------
public void Q12_Frame(int objectiveID, int client) {
	float origin[3], target[3] = {677.0, -1109.0, -2135.0};
	GetClientAbsOrigin(client, origin);
	
	if( rp_ClientCanDrawPanel(client) ) {
		char title[128], text[2048];
		Handle panel = CreatePanel();
		
		Format(title, sizeof(title), "%T", "TUTO_12_Title", client);
		Format(text, sizeof(text), "%T", "TUTO_12_Text", client);
		
		String_WordWrap(text, 40);
		
		SetPanelTitle(panel, title);
		DrawPanelText(panel, text);
		
		rp_SendPanelToClient(panel, client, 1.1);
		CreateTimer(1.1, PostKillHandle, panel);
	}
	
	if( GetVectorDistance(target, origin) < 128.0 ) {
		rp_QuestStepComplete(client, objectiveID);
	}
	else {
		ServerCommand("sm_effect_gps %d %f %f %f", client, target[0], target[1], target[2]);
	}
}
public void Q13_Frame(int objectiveID, int client) {
	
	if( rp_ClientCanDrawPanel(client) ) {
		g_iQ12 = objectiveID;
		
		char title[128];
		
		Handle menu = CreateMenu(MenuSelectParrain);
		SetMenuTitle(menu, "%T", "TUTO_13_Title", client);
					
		
		Format(title, sizeof(title), "%T", "TUTO_13_Text", client);
		String_WordWrap(title, 40);
		AddMenuItem(menu, "", title, ITEMDRAW_DISABLED); 
		
		Format(title, sizeof(title), "%T", "TUTO_13b_Text", client);
		AddMenuItem(menu, "none", title);
				
		char szSteamID[64], szName[128];
		for( int i=1;i<=MaxClients; i++) {
			if( !IsValidClient(i) )
				continue;
			if( i == client )
				continue;
			if( rp_IsClientNew(i) )
				continue;
						
			GetClientAuthId(i, AUTH_TYPE, szSteamID, sizeof(szSteamID), false);
			Format(szName, sizeof(szName), "%N", i);
						
			AddMenuItem(menu, szSteamID, szName);
		}
					
		SetMenuExitButton(menu, true);
		DisplayMenu(menu, client, 60);
	}
}
public int MenuSelectParrain(Handle menu, MenuAction action, int client, int param2) {
	if( action == MenuAction_Select ) {
		char options[64];
		GetMenuItem(menu, param2, options, sizeof(options));
		
		
		if( !StrEqual(options, "none") ) {
			char szQuery[1024], szSteamID[64];
			GetClientAuthId(client, AUTH_TYPE, szSteamID, sizeof(szSteamID), false);
			
			Format(szQuery, sizeof(szQuery), "INSERT INTO `rp_parrain` (`steamid`, `parent`, `timestamp`) VALUES ('%s', '%s', UNIX_TIMESTAMP());", szSteamID, options);
			SQL_TQuery(rp_GetDatabase(), SQL_QueryCallBack, szQuery);
		}
		
		rp_QuestStepComplete(client, g_iQ12);
		rp_ClientMoney(client, i_Bank, 7500);
		
		
	}
	else if( action == MenuAction_End ) {
		CloseHandle(menu);
	}
}
public void Q14_Start(int objectiveID, int client) {
	rp_SetClientInt(client, i_AllowedDismiss, FREE_JOB);
}
public void Q14_Frame(int objectiveID, int client) {
	char tmp[128], tmp2[128];
	
	if( g_iDefaultJob[client] > 0 ) {
		int job = g_iDefaultJob[client];
		rp_SetClientInt(client, i_Job, job);
		rp_QuestStepComplete(client, objectiveID);
	}
	else if( rp_GetClientInt(client, i_Job) > 0 ) {
		rp_GetJobData(rp_GetClientInt(client, i_Job), job_type_name, tmp, sizeof(tmp));
		GetClientName2(client, tmp2, sizeof(tmp2), false);
		
		for (int i = 1; i <= MaxClients; i++) {
			if( !IsValidClient(i) )
				continue;
			if( i == client )
				continue;
			
			CPrintToChat(i, "" ...MOD_TAG... " %T", "TUTO_Finish", i, tmp2, tmp);
		}
		rp_QuestStepComplete(client, objectiveID);
	}
	else if( rp_ClientCanDrawPanel(client) ) {
		drawJobMenu(client);
	}
}
public int MenuSelectJob(Handle menu, MenuAction action, int client, int param2) {
	char options[64], tmp[128];
	if( action == MenuAction_Select ) {
		GetMenuItem(menu, param2, options, sizeof(options));
		int job = StringToInt(options);
		
		if( job == -1  ) {
			g_iDisableAsk[client] = GetTime() + 6 * 60;
		}
		else if( job > 1000 ) {
			job -= 1000;
			rp_GetJobData(job, job_type_name, options, sizeof(options));
			
			Handle menu2 = CreateMenu(MenuSelectJob);
			
			Format(options, sizeof(options), "%T: %s", qualif[g_iRecom[job]], client, options);
			SetMenuTitle(menu2, "%T\n%T\n%T", "TUTO_Jobs_Title", client, "TUTO_Jobs_Confirm", client, options, "TUTO_Jobs_Text", client);
			
			Format(options, sizeof(options), "%d", job);
			
			Format(tmp, sizeof(tmp), "%T", "TUTO_Jobs_Confirm_No", client);
			AddMenuItem(menu2, "0", tmp);

			Format(tmp, sizeof(tmp), "%T", "TUTO_Jobs_Confirm_Yes", client);
			AddMenuItem(menu2, options, tmp);
			SetMenuExitButton(menu2, true);
			DisplayMenu(menu2, client, 60);
		}
		else if( job > 0 ) {
			rp_SetClientInt(client, i_Job, job);
			rp_SetClientInt(client, i_AllowedDismiss, rp_GetClientInt(client, i_AllowedDismiss) - 1);
			rp_GetJobData(job, job_type_name, options, sizeof(options));
			
			CPrintToChat(client, "" ...MOD_TAG... " %T", "TUTO_Jobs_Confirm_Done", client, options, rp_GetClientInt(client, i_AllowedDismiss), FREE_JOB);
		}
	}
	else if( action == MenuAction_End ) {
		CloseHandle(menu);
	}
}
public Action PostKillHandle(Handle timer, any data) {
	if( data != INVALID_HANDLE )
		CloseHandle(data);
}
public void Q14_Done(int objectiveID, int client) {
	
	char options[128];
	
	int job = rp_GetClientInt(client, i_Job);
	
	rp_SetClientInt(client, i_JetonRouge, (job - (job % 10))+1);
	ServerCommand("sm_force_discord_group %N", client);
	
	rp_GetJobData(job, job_type_name, options, sizeof(options));
	LogToGame("[TSX-RP] [TUTORIAL] %L a terminé son tutoriel. Il a choisi %s comme job.", client, options);
	FakeClientCommand(client, "say /shownotes");
	
	rp_SetClientInt(client, i_Tutorial, 20);
	
	rp_ClientGiveItem(client, 223);	
	rp_ClientMoney(client, i_Bank, 100000);
	rp_SetClientBool(client, b_GameModePassive, true);
	
	rp_ClientXPIncrement(client, 5000);
	
	char szQuery[1024], szSteamID[64];
	GetClientAuthId(client, AUTH_TYPE, szSteamID, sizeof(szSteamID), false);

	Format(szQuery, sizeof(szQuery), "DELETE FROM `rp_users3` WHERE `steamid`='%s';", szSteamID);
	SQL_TQuery(rp_GetDatabase(), SQL_QueryCallBack, szQuery);
	//CPrintToChat(client, "" ...MOD_TAG... " Voici une invitation pour rejoindre notre discord: {green}https://discord.gg/hw4GSSw{default}");
}
void drawJobMenu(int client) {
	char tmp[128], tmp2[8];
	Handle menu = CreateMenu(MenuSelectJob);
	SetMenuTitle(menu, "%T", "TUTO_Jobs_Title", client);
	
	Format(tmp, sizeof(tmp), "%T", "TUTO_Jobs_Text", client);
	String_WordWrap(tmp, 40);
	
	AddMenuItem(menu, "", tmp, ITEMDRAW_DISABLED);
	
	int limit = 3;
	ArrayList dbl = rp_GetClientDouble(client);
	if( dbl.Length >= 1 )
		limit = 8;
	
	int cpt = 0;
	for( int i=0; i<sizeof(g_iJob) - limit; i++) {
		if( rp_GetClientPlaytimeJob(client, g_iJob[i], true) > 60)
			continue;
		
		rp_GetJobData(g_iJob[i], job_type_name, tmp, sizeof(tmp));
		Format(tmp, sizeof(tmp), "%T: %s", qualif[g_iRecom[g_iJob[i]]], client, tmp);
		Format(tmp2, sizeof(tmp2), "%d", g_iJob[i]+1000);
		AddMenuItem(menu, tmp2, tmp);
		cpt++;
	}
	
	if( rp_IsTutorialOver(client) ) {
		Format(tmp, sizeof(tmp), "%T", "TUTO_Jobs_None", client);
		AddMenuItem(menu, "-1", tmp);
	}
	
	SetMenuExitButton(menu, true);
	
	if( cpt > 0 )
		DisplayMenu(menu, client, 60);
	else
		delete menu;
}
// ------------------------------------------------------------
void OpenHelpMenu(int client, int section, int parent) {
	char query[1024];
	Format(query, sizeof(query), "SELECT `id`, `goto`, `txt`  FROM `rp_shared`.`rp_help_question` WHERE `qid`=%d OR `id`=%d", section, parent);
	
	Handle pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackCell(pack, parent);
	
	SQL_TQuery(rp_GetDatabase(), SQL_OpenHelpMenu, query, pack, DBPrio_High);
}
public void SQL_OpenHelpMenu(Handle owner, Handle hQuery, const char[] error, any pack) {
	ResetPack(pack);
	int client, parent, id, go;
	char txt[255], tmp[16];
	
	client = ReadPackCell(pack);
	parent = ReadPackCell(pack);
	
	Menu menu = CreateMenu(helpMenu);
	menu.SetTitle("Besoin d'aide?\n--------------------\n ");
	
	while( SQL_FetchRow(hQuery) ) {
		id = SQL_FetchInt(hQuery, 0);
		go = SQL_FetchInt(hQuery, 1);
		SQL_FetchString(hQuery, 2, txt, sizeof(txt));
		
		
		if( id == parent )
			menu.SetTitle("%s\n--------------------\n", txt);
		else {
			Format(tmp, sizeof(tmp), "%d %d", id, go);
			
			menu.AddItem(tmp, txt, go > 0 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
		}
	}
	
	if( parent != 0 ) {
		menu.ExitBackButton = true;
		menu.Pagination = 8;
	}
	
	menu.Display(client, MENU_TIME_FOREVER);
}
public int helpMenu(Handle hItem, MenuAction oAction, int client, int param) {
	
	if (oAction == MenuAction_Select) {
		char options[64], tmp[2][16];
		if( GetMenuItem(hItem, param, options, sizeof(options)) ) {
			ExplodeString(options, " ", tmp, sizeof(tmp), sizeof(tmp[]));
			OpenHelpMenu(client, StringToInt(tmp[1]), StringToInt(tmp[0]));
		}
	}
	else if (oAction == MenuAction_Cancel && param == MenuCancel_ExitBack  ) {
		OpenHelpMenu(client, 1, 0);
	}
	else if (oAction == MenuAction_End ) {
		CloseHandle(hItem);
	}
}
