#if defined _roleplay_quest_included
#endinput
#endif
#define _roleplay_quest_included

#if defined ROLEPLAY_SUB
	#include "../roleplay.sp"
#else
	#include "roleplay.sp"
#endif

DataPack g_hQuest;

public int Native_rp_QuestCreateInstance(Handle plugin, int numParams) {
	int client = GetNativeCell(1);
	char model[PLATFORM_MAX_PATH];
	float position[3];
	GetNativeString(2, model, sizeof(model));
	GetNativeArray(3, position, sizeof(position));
	
	if( !IsModelPrecached(model) )
		if( !PrecacheModel(model) )
			return -1;
	
	int ent = CreateEntityByName("prop_dynamic_glow");
	DispatchKeyValue(ent, "model", model);
	DispatchSpawn(ent);
	TeleportEntity(ent, position, NULL_VECTOR, NULL_VECTOR);
	g_iOriginOwner[ent] = client;
	
	SetEntProp(ent, Prop_Send, "m_bShouldGlow", 1);
	SetEntProp(ent, Prop_Send, "m_clrGlow", 255);
	
	SDKHook(ent, SDKHook_SetTransmit, Hook_Transmit);
	
	return ent;
}
public Action Hook_Transmit(int entity, int client) {
	if( g_iOriginOwner[entity] != client )
		return Plugin_Handled;
	return Plugin_Continue;
}
public Action Cmd_StartQuest(int args) {
	int client = GetCmdArgInt(1);
	char arg[32]; GetCmdArg(2, arg, sizeof(arg));
	StartQuest(client, arg);
	return Plugin_Handled;
}
public void StartQuest(int client, char uniqID[32]) {
	
	char query[1024];
	Format(query, sizeof(query), "SELECT `pluginID`, `fctID`, `fctStartID`, `fctFrameID`, `fctAbortID`, `fctDoneID`, QO.`id`, `stepID` FROM `rp_quest` Q INNER JOIN `rp_quest_objectives` QO ON Q.`uniqID`=QO.`uniqID` WHERE Q.`uniqID`='%s' ORDER BY QO.id LIMIT 1;", uniqID);
	
	SQL_TQuery(g_hBDD, SQL_StartQuest_CB, query, client, DBPrio_High);
}
public void SQL_StartQuest_CB(Handle owner, Handle hQuery, const char[] error, any client) {
	
	if( g_iClientQuests[client][questID] != -1 ) {
		return;
	}
	
	if( SQL_FetchRow(hQuery) ) {
		Handle plugin = view_as<Handle>(SQL_FetchInt(hQuery, 0));
		int id0 = SQL_FetchInt(hQuery, 1);
		
		g_hQuest.Reset();
		g_hQuest.Position = view_as<DataPackPos>(id0);
	
		Function fct1 = g_hQuest.ReadFunction();
		
		bool can = false;
		if( fct1 != INVALID_FUNCTION ) {
			Call_StartFunction(plugin, fct1);
			Call_PushCell(client);
			Call_Finish(can);
		}
		if( can == true || SQL_FetchInt(hQuery, 7) != 0 ) {
			
			g_iClientQuests[client][pluginID] = view_as<int>(plugin);
			g_iClientQuests[client][questID] = id0;
			g_iClientQuests[client][startID] = SQL_FetchInt(hQuery, 2);
			g_iClientQuests[client][frameID] = SQL_FetchInt(hQuery, 3);
			g_iClientQuests[client][abortID] = SQL_FetchInt(hQuery, 4);
			g_iClientQuests[client][overID] = SQL_FetchInt(hQuery, 5);
			g_iClientQuests[client][objectiveID] = SQL_FetchInt(hQuery, 6);
			g_iClientQuests[client][stepID] = SQL_FetchInt(hQuery, 7);
			
			
			Function fct2 = QuestGetFunction(g_iClientQuests[client][startID]);
			if( fct2 != INVALID_FUNCTION ) {
				Call_StartFunction(plugin, fct2);
				Call_PushCell(g_iClientQuests[client][objectiveID]);
				Call_PushCell(client);
				Call_Finish();
			}
			
			rp_HookEvent(client, RP_OnFrameSeconde, QuestFrame);
		}
	}
	else if( g_iClientQuests[client][stepID] == -1 ) {
		// introuvable
	}
	else {
		g_iClientQuests[client][stepID] = -1;
		g_iClientQuests[client][questID] = -1;
		
		char query[1024], szSteamID[32];
		GetClientAuthId(client, AUTH_TYPE, szSteamID, sizeof(szSteamID), false);
		
		Format(query, sizeof(query), "UPDATE `rp_quest_book` SET `completed`='1' WHERE `uniqID`=(SELECT `uniqID` FROM `rp_quest_objectives` WHERE `id`='%d') AND `completed`='0' AND `steamid`='%s' ORDER BY `id` DESC LIMIT 1;", g_iClientQuests[client][objectiveID], szSteamID);
		SQL_TQuery(g_hBDD, SQL_QueryCallBack, query, client, DBPrio_High);
	}
}
public Action QuestFrame(int client) {
	Function fct = QuestGetFunction(g_iClientQuests[client][frameID]);
	if( fct != INVALID_FUNCTION ) {
		Call_StartFunction(view_as<Handle>(g_iClientQuests[client][pluginID]), fct);
		Call_PushCell(g_iClientQuests[client][objectiveID]);
		Call_PushCell(client);
		Call_Finish();
	}
}
public void QuestClean(int client) {
	if( g_iClientQuests[client][questID] > 0 ) {
		rp_QuestStepFail(client, g_iClientQuests[client][objectiveID]);
	}
}
public Function QuestGetFunction(int id) {
	g_hQuest.Reset();
	g_hQuest.Position = view_as<DataPackPos>(id);
	return g_hQuest.ReadFunction();
}
public Action CmdReloadQuest(int args) {
	delete g_hQuest;
	g_hQuest = null;
	
	return Plugin_Continue;
}
public int Native_rp_RegisterQuest(Handle plugin, int numParams) {
	char uniqID[32], name[64], name2[sizeof(name)*2+1], query[1024];
	
	if( !g_hQuest ) {

		g_hQuest = new DataPack();
		g_hQuest.WriteCell(0);
		g_hQuest.Reset();
		g_hQuest.ReadCell();
		DataPackPos tmp = g_hQuest.Position;
		g_hQuest.Reset();
		g_hQuest.WriteCell(tmp);
		
		SQL_LockDatabase(g_hBDD);
		Format(query, sizeof(query), "TRUNCATE `rp_quest`;");
		SQL_Query(g_hBDD, query);
		Format(query, sizeof(query), "TRUNCATE `rp_quest_objectives`;");
		SQL_Query(g_hBDD, query);
		SQL_UnlockDatabase(g_hBDD);
	}

	GetNativeString(1, uniqID, sizeof(uniqID));
	GetNativeString(2, name, sizeof(name));
	
	SQL_EscapeString(g_hBDD, name, name2, sizeof(name2));
	
	int type = GetNativeCell(3);
	Function fct = GetNativeFunction(4);
	
	g_hQuest.Reset();
	DataPackPos oldSize = g_hQuest.ReadCell();
	g_hQuest.Position = oldSize;
	
	g_hQuest.WriteFunction(fct);
	DataPackPos newSize = g_hQuest.Position;
	g_hQuest.Reset();
	g_hQuest.WriteCell(newSize);
	
	SQL_LockDatabase(g_hBDD);
	
	Format(query, sizeof(query), "INSERT INTO `rp_quest` (`uniqID`, `name`, `type`, `pluginID`, `fctID`) VALUES ('%s','%s', '%d', '%d', '%d')", uniqID, name2, type, plugin, oldSize);
	Format(query, sizeof(query), "%s ON DUPLICATE KEY UPDATE `pluginID`='%d', `name`='%s', `type`='%d', `fctID`='%d';", query, view_as<int>(plugin), name2, type, oldSize);
	SQL_Query(g_hBDD, query);
	Format(query, sizeof(query), "DELETE FROM `rp_quest_objectives` WHERE `uniqID`='%s';", uniqID);
	SQL_Query(g_hBDD, query);
	
	SQL_UnlockDatabase(g_hBDD);
	
	return view_as<int>(oldSize);
}
public int Native_rp_QuestAddStep(Handle plugin, int numParams) {
	char query[1024];
	
	int id = view_as<int>(GetNativeCell(1));
	int step = view_as<int>(GetNativeCell(2));
	Function fct1 = GetNativeFunction(3);
	Function fct2 = GetNativeFunction(4);
	Function fct3 = GetNativeFunction(5);	
	Function fct4 = GetNativeFunction(6);	
	
	
	g_hQuest.Reset();
	DataPackPos oldSize = g_hQuest.ReadCell();
	g_hQuest.Position = oldSize;
	
	g_hQuest.WriteFunction(fct1);
	DataPackPos id2 = g_hQuest.Position;
	g_hQuest.WriteFunction(fct2);
	DataPackPos id3 = g_hQuest.Position;
	g_hQuest.WriteFunction(fct3);
	DataPackPos id4 = g_hQuest.Position;
	g_hQuest.WriteFunction(fct4);
	
	DataPackPos newSize = g_hQuest.Position;
	g_hQuest.Reset();
	g_hQuest.WriteCell(newSize);
	
	SQL_LockDatabase(g_hBDD);
	Format(query, sizeof(query), "INSERT INTO `rp_quest_objectives` (`uniqID`, `stepID`, `fctStartID`, `fctFrameID`, `fctAbortID`, `fctDoneID`) VALUES ((SELECT uniqID  FROM `rp_quest` WHERE fctID='%d'), '%d', '%d', '%d', '%d', '%d');", id, step, oldSize, id2, id3, id4);
	SQL_Query(g_hBDD, query);
	SQL_UnlockDatabase(g_hBDD);
	
}
public int Native_rp_QuestComplete(Handle plugin, int numParams) {
	char uniqID[32], query[1024], szSteamID[64];
	
	int client = GetNativeCell(1);
	int status = GetNativeCell(3);
	GetClientAuthId(client, AUTH_TYPE, szSteamID, sizeof(szSteamID));
	GetNativeString(2, uniqID, sizeof(uniqID));
	
	Format(query, sizeof(query), "INSERT INTO `rp_quest_book` (`steamID`, `uniqID`, `step`, `completed`, `time`) VALUES ('%s', '%s', (SELECT MAX(`StepID`) FROM `rp_quest_objectives` WHERE `uniqID`='%s'), '%d', UNIX_TIMESTAMP());", szSteamID, uniqID, uniqID, status);
	SQL_TQuery(g_hBDD, SQL_QueryCallBack, query, client, DBPrio_High);
}
public int Native_rp_QuestStepComplete(Handle plugin, int numParams) {
	int client = GetNativeCell(1);
	int objective = GetNativeCell(2);
	
	
	if( g_iClientQuests[client][questID] > 0 ) {
		rp_UnhookEvent(client, RP_OnFrameSeconde, QuestFrame);
		
		Function fct = QuestGetFunction(g_iClientQuests[client][overID]);
		if( fct != INVALID_FUNCTION ) {
			Call_StartFunction(view_as<Handle>(g_iClientQuests[client][pluginID]), fct);
			Call_PushCell(g_iClientQuests[client][objectiveID]);
			Call_PushCell(client);
			Call_Finish();
		}
		g_iClientQuests[client][questID] = -1;
	
		char query[1024], szSteamID[32];
		GetClientAuthId(client, AUTH_TYPE, szSteamID, sizeof(szSteamID), false);
		
		Format(query, sizeof(query), "SELECT `pluginID`, `fctID`, `fctStartID`, `fctFrameID`, `fctAbortID`, `fctDoneID`, QO.`id`, `stepID` FROM `rp_quest` Q INNER JOIN `rp_quest_objectives` QO ON Q.`uniqID`=QO.`uniqID` WHERE QO.`id`>%d AND QO.`uniqID`=(SELECT QOB.`uniqID` FROM `rp_quest_objectives` QOB WHERE `id`='%d') LIMIT 1;", objective, objective );
		SQL_TQuery(g_hBDD, SQL_StartQuest_CB, query, client, DBPrio_High);
		
		if( g_iClientQuests[client][stepID] == 0 ) {
			Format(query, sizeof(query), "INSERT INTO `rp_quest_book` (`steamID`, `uniqID`, `step`, `completed`, `time`) VALUES ('%s', (SELECT `uniqID` FROM `rp_quest_objectives` WHERE `id`='%d'), '0', '0', UNIX_TIMESTAMP())", szSteamID, objective);
		}
		else {
			Format(query, sizeof(query), "UPDATE `rp_quest_book` SET `step`='%d' WHERE `uniqID`=(SELECT `uniqID` FROM `rp_quest_objectives` WHERE `id`='%d') AND `completed`='0' AND `steamid`='%s' ORDER BY `id` DESC LIMIT 1;", g_iClientQuests[client][stepID], objective, szSteamID);
		}
		
		SQL_TQuery(g_hBDD, SQL_QueryCallBack, query, client, DBPrio_High);
	}
}
public int Native_rp_QuestStepFail(Handle plugin, int numParams) {
	int client = GetNativeCell(1);
	int objective = GetNativeCell(2);
	
	
	if( g_iClientQuests[client][questID] > 0 ) {
		rp_UnhookEvent(client, RP_OnFrameSeconde, QuestFrame);
		
		Function fct = QuestGetFunction(g_iClientQuests[client][abortID]);
		if( fct != INVALID_FUNCTION ) {
			Call_StartFunction(view_as<Handle>(g_iClientQuests[client][pluginID]), fct);
			Call_PushCell(g_iClientQuests[client][objectiveID]);
			Call_PushCell(client);
			Call_Finish();
		}
		g_iClientQuests[client][questID] = -1;
	
		char query[1024], szSteamID[32];
		GetClientAuthId(client, AUTH_TYPE, szSteamID, sizeof(szSteamID), false);
		
		if( g_iClientQuests[client][stepID] == 0 ) {
			Format(query, sizeof(query), "INSERT INTO `rp_quest_book` (`steamID`, `uniqID`, `step`, `completed`, `time`) VALUES ('%s', (SELECT `uniqID` FROM `rp_quest_objectives` WHERE `id`='%d'), '0', '2', UNIX_TIMESTAMP())", szSteamID, objective);
		}
		else {
			Format(query, sizeof(query), "UPDATE `rp_quest_book` SET `step`='%d', `completed`='2' WHERE `uniqID`=(SELECT `uniqID` FROM `rp_quest_objectives` WHERE `id`='%d') AND `completed`='0' AND `steamid`='%s' ORDER BY `id` DESC LIMIT 1;", g_iClientQuests[client][stepID], objective, szSteamID);
		}

		SQL_TQuery(g_hBDD, SQL_QueryCallBack, query, client, DBPrio_High);
	}
}
public void Cmd_QuestMenu(int client) {
	
	if( g_iClientQuests[client][questID] != -1 ) {
		Menu menu = new Menu(Cmd_QuestMenu_Choose);
		menu.SetTitle("Menu des quêtes\n ");
		menu.AddItem("", "Vous avez déjà une quête en cours,", ITEMDRAW_DISABLED);
		menu.AddItem("", "si vous abandonnez, vous ne pourrez", ITEMDRAW_DISABLED);
		menu.AddItem("", "pas reprendre cette quête pendant", ITEMDRAW_DISABLED);
		menu.AddItem("", "au moins 24 heures.", ITEMDRAW_DISABLED);
		menu.AddItem("", "Souhaitez-vous l'interrompre?", ITEMDRAW_DISABLED);
		menu.AddItem("continue", "Non, je veux continuer");
		menu.AddItem("stop", "Oui, je veux l'arrêter");
		menu.ExitButton = false;
		menu.Display(client, MENU_TIME_FOREVER);
		return;
	}
	
	if( g_bUserData[client][b_IsMuteEvent] ) {
		CPrintToChat(client, "{lightblue}[TSX-RP]{default} En raison de votre mauvais comportement, il vous est temporairement interdit de participer aux quêtes.");
		return;
	}
	
	char query[1024], szSteamID[64];
	GetClientAuthId(client, AUTH_TYPE, szSteamID, sizeof(szSteamID));
	
	Format(query, sizeof(query), "SELECT `pluginID`, `fctID`, `uniqID`, `name` FROM `rp_quest` Q WHERE (`type`='1' OR `type`='2') AND `uniqID` NOT IN");
	Format(query, sizeof(query), "%s (SELECT Q.`uniqID`FROM`rp_quest`Q INNER JOIN`rp_quest_book`QB ON Q.`uniqID` = QB.`uniqID` WHERE `steamID`='%s' AND `isFinish`=0);", query, szSteamID); 
	
	SQL_TQuery(g_hBDD, Cmd_QuestMenu_CB, query, client, DBPrio_High);
	g_bUserData[client][b_HasQuest] = false;
}
public void updateQuest_CB(Handle owner, Handle hQuery, const char[] error, any client) {
	bool has = false;
	
	while( SQL_FetchRow(hQuery) ) {
		
		Handle plugin = view_as<Handle>(SQL_FetchInt(hQuery, 0));
		DataPackPos id0 = view_as<DataPackPos>(SQL_FetchInt(hQuery, 1));
		
		g_hQuest.Reset();
		g_hQuest.Position = id0;
		Function fct1 = g_hQuest.ReadFunction();
		
		bool can = false;
		if( fct1 != INVALID_FUNCTION ) {
			Call_StartFunction(plugin, fct1);
			Call_PushCell(client);
			Call_Finish(can);
		}
		
		if( can ) {
			has = true;
		}
	}
	
	g_bUserData[client][b_HasQuest] = has;
}
public void Cmd_QuestMenu_CB(Handle owner, Handle hQuery, const char[] error, any client) {
	
	char uniqID[32], name[128];
	Menu menu = new Menu(Cmd_QuestMenu_Choose);
	menu.SetTitle("Menu des quêtes\n ");
	
	int i = 0;
	while( SQL_FetchRow(hQuery) ) {
		
		Handle plugin = view_as<Handle>(SQL_FetchInt(hQuery, 0));
		DataPackPos id0 = view_as<DataPackPos>(SQL_FetchInt(hQuery, 1));
		
		g_hQuest.Reset();
		g_hQuest.Position = id0;
		Function fct1 = g_hQuest.ReadFunction();
		
		bool can = false;
		if( fct1 != INVALID_FUNCTION ) {
			Call_StartFunction(plugin, fct1);
			Call_PushCell(client);
			Call_Finish(can);
		}
		
		if( can ) {
			i++;
			SQL_FetchString(hQuery, 2, uniqID, sizeof(uniqID));
			SQL_FetchString(hQuery, 3, name, sizeof(name));
			
			menu.AddItem(uniqID, name);
		}
	}
	
	CheckMP(client);
	
	if( i == 0 ) {	
		CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous n'avez aucune quête disponible pour le moment.");
		delete menu;
		return;
	}
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}
public int Cmd_QuestMenu_Choose(Handle p_hItemMenu, MenuAction p_oAction, int client, int p_iParam2) {
	
	if (p_oAction == MenuAction_Select) {
		
		char szMenuItem[32];
		if( GetMenuItem(p_hItemMenu, p_iParam2, szMenuItem, sizeof(szMenuItem)) ) {
			
			if( StrEqual(szMenuItem, "stop") ) {
				QuestClean(client);
			}
			else if( StrEqual(szMenuItem, "continue") ) {
			}
			else {
				g_bUserData[client][b_HasQuest] = false;
				StartQuest(client, szMenuItem);
			}
		}		
	}
	else if (p_oAction == MenuAction_End) {
		CloseHandle(p_hItemMenu);
	}
}
