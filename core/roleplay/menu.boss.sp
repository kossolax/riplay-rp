#if defined _roleplay_menu_boss_included
#endinput
#endif
#define _roleplay_menu_boss_included

#if !defined _roleplay_base_included || defined ROLEPLAY_SUB
	#define ROLEPLAY_SUB
	#include "../roleplay.sp"
#else
	#include "roleplay.sp"
#endif

public int eventHireMenu(Handle p_hHireMenu, MenuAction p_oAction, int p_iParam1, int p_iParam2) {
	if (p_oAction == MenuAction_Select) {
		char szMenuItem[32];
		int iTarget;
		int iJobID;
		int client = p_iParam1;
		
		if (GetMenuItem(p_hHireMenu, p_iParam2, szMenuItem, sizeof(szMenuItem))) {
			char data[2][32];
			
			ExplodeString(szMenuItem, "_", data, sizeof(data), sizeof(data[]));
			
			iTarget = StringToInt(data[0]);
			iJobID = StringToInt(data[1]);
			
			ChangePersonnal(iTarget, SynType_job, iJobID, client);
		}
	}
	else if (p_oAction == MenuAction_End) {
		CloseHandle(p_hHireMenu);
	}
}

public int eventHireMenu2(Handle p_hHireMenu, MenuAction p_oAction, int p_iParam1, int p_iParam2) {
	if (p_oAction == MenuAction_Select) {
		char szMenuItem[32];
		int iTarget;
		int iJobID;
		int client = p_iParam1;
		
		if (GetMenuItem(p_hHireMenu, p_iParam2, szMenuItem, sizeof(szMenuItem))) {
			char data[2][32];
			
			ExplodeString(szMenuItem, "_", data, sizeof(data), sizeof(data[]));
			
			iTarget = StringToInt(data[0]);
			iJobID = StringToInt(data[1]);
			
			ChangePersonnal(iTarget, SynType_group, iJobID, client);
		}
	}
	else if (p_oAction == MenuAction_End) {
		CloseHandle(p_hHireMenu);
	}
}
public int MenuSelectFire(Handle p_hHireMenu, MenuAction p_oAction, int p_iParam1, int p_iParam2) { 
	if (p_oAction == MenuAction_Select) {
		char szMenuItem[32];
		
		if (GetMenuItem(p_hHireMenu, p_iParam2, szMenuItem, sizeof(szMenuItem))) {
			
			
			int were_in_game = 0;
			for(int i=1; i<=MaxClients; i++) {
				
				if( !IsValidClient(i) ) 
					continue;
				
				char SteamID[64];
				GetClientAuthId(i, AUTH_TYPE, SteamID, sizeof(SteamID), false);
				
				if( StrEqual(SteamID, szMenuItem) ) {
					were_in_game = i;
					ChangePersonnal(i, SynType_job, 0, p_iParam1);
					break;
				}
			}
			
			char tmp[1024];
			Format(tmp, 1023, "UPDATE `rp_users` SET `job_id`='0' WHERE `steamid`='%s'", szMenuItem);
			SQL_TQuery(g_hBDD, SQL_QueryCallBack, tmp);
			
			if( were_in_game == 0 ) {
				
				CPrintToChat(p_iParam1, "" ...MOD_TAG... " Vous avez viré un joueur non-connecté (%s).", szMenuItem);
				
				
				char szLog[1024];
				Format(szLog, sizeof(szLog), "[TSX-RP] [SYN] [JOB] (%s) est maintenant Sans emploi par %L.", szMenuItem, p_iParam1);
				
				LogToGame(szLog);
			}
		}
	}
	else if (p_oAction == MenuAction_End) {
		CloseHandle(p_hHireMenu);
	}
}

public int menuFire_Client(Handle owner, Handle hQuery, const char[] error, any client) {
	// Setup menu
	Handle menu = CreateMenu(MenuSelectFire);
	SetMenuTitle(menu, "Sélectionner qui virer\n ");
	
	char SteamID[64], name[128];
	int job_id;
	
	while( SQL_FetchRow(hQuery) ) {
		
		
		SQL_FetchString(hQuery, 0, SteamID, 63);
		SQL_FetchString(hQuery, 1, name, 127);
		job_id = SQL_FetchInt(hQuery, 2);
		
		if( job_id == g_iUserData[client][i_Job] )
			continue;
		
		if( StringToInt(g_szJobList[ job_id ][2]) != GetJobPrimaryID(client) )
			continue;
		
		if( SQL_FetchInt(hQuery, 3) <= ((GetTime())-(7*24*60*60)) ) {
			Format(name, sizeof(name), "%s - Inactif", name);
		}
		
		AddMenuItem(menu, SteamID, name);
	}
	
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_DURATION);
}
public int eventSetJobMenu(Handle p_hHireMenu, MenuAction p_oAction, int p_iParam1, int p_iParam2) {
	if( !IsBoss(p_iParam1) ) {
		return;
	}
	
	if (p_oAction == MenuAction_Select) {
		char szMenuItem[32];
		int iJobID;
		
		if (GetMenuItem(p_hHireMenu, p_iParam2, szMenuItem, sizeof(szMenuItem))) {
			char data[2][64];
			
			ExplodeString(szMenuItem, " ", data, sizeof(data), sizeof(data[]));
			
			iJobID = StringToInt(data[1]);
			
			for(int i=1; i<=MaxClients; i++) {
				
				if( !IsValidClient(i) )
					continue;
				
				char SteamID[64];
				GetClientAuthId(i, AUTH_TYPE, SteamID, sizeof(SteamID), false);
				
				if( StrEqual(SteamID, data[0]) ) {
					CPrintToChat(i, "" ...MOD_TAG... " %N a modifié votre job. Vous êtes maintenant: %s.", p_iParam1, g_szJobList[iJobID][job_type_name]);
					g_iUserData[i][i_Job] = iJobID;
					break;
				}
			}
			
			char tmp[1024];
			Format(tmp, 1023, "UPDATE `rp_users` SET `job_id`='%i' WHERE `steamid`='%s'", iJobID, data[0]);
			SQL_TQuery(g_hBDD, SQL_QueryCallBack, tmp);
			
			CPrintToChat(p_iParam1, "" ...MOD_TAG... " Sa place a été modifiée.");
			
			LogToGame("[TSX-RP] %N a modifier le job de %s pour %s", p_iParam1, szMenuItem, g_szJobList[iJobID][job_type_name]);
		}
	}
	else if (p_oAction == MenuAction_End) {
		CloseHandle(p_hHireMenu);
	}
}
void OpenBossPayMenu(int client) {
	if( !IsBoss(client) ) {
		return;
	}
	// Setup menu
	Handle menu = CreateMenu(MenuSelectPay);
	SetMenuTitle(menu, "Sélectionner un métier\n ");
	
	for(int i=1; i<MAX_JOBS; i++) {
		
		if( StringToInt(g_szJobList[i][2]) != GetJobPrimaryID(client) ) {
			if( g_iUserData[client][i_Job] != i )
				continue;
		}
		if( StringToInt(  g_szJobList[ i ][job_type_cochef] ) == 1 && StringToInt(  g_szJobList[ g_iUserData[client][i_Job] ][job_type_cochef] ) == 1 )
			continue;
		
		char tmp[11];
		IntToString(i, tmp, 11);
		char tmp2[128];
		Format(tmp2, 127, "%s [%s$]", g_szJobList[i][0], g_szJobList[i][3]);
		AddMenuItem(menu, tmp, tmp2);
	}
	
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_DURATION);
	
	
	return;
}
public int MenuSelectPay(Handle menu, MenuAction action, int client, int param2) {
	if( !IsBoss(client) ) {
		return;
	}
	if( action == MenuAction_Select ) {
		char options[64];
		GetMenuItem(menu, param2, options, 63);
		
		char tmp[64];
		Handle submenu = CreateMenu(MenuSetPay);
		SetMenuTitle(submenu, "Comment souhaitez-vous changer sa paye?\n ");
		
		Format(tmp, 64, "%s_1", options);	AddMenuItem(submenu, tmp, "+1$");
		Format(tmp, 64, "%s_10", options);	AddMenuItem(submenu, tmp, "+10$");
		Format(tmp, 64, "%s_100", options);	AddMenuItem(submenu, tmp, "+100$");
		
		Format(tmp, 64, "%s_-1", options);	AddMenuItem(submenu, tmp, "-1$");
		Format(tmp, 64, "%s_-10", options);	AddMenuItem(submenu, tmp, "-10$");
		Format(tmp, 64, "%s_-100", options);AddMenuItem(submenu, tmp, "-100$");
		
		SetMenuPagination(submenu, MENU_NO_PAGINATION);
		SetMenuExitButton(submenu, true);
		DisplayMenu(submenu, client, MENU_TIME_DURATION);
	}
	else if( action == MenuAction_End ) {
		CloseHandle(menu);
	}
}
public int MenuSetPay(Handle menu, MenuAction action, int client, int param2) {
	if( !IsBoss(client) ) {
		return;
	}
	if( action == MenuAction_Select ) {
		char options[64];
		GetMenuItem(menu, param2, options, 63);
		
		char data[2][32];
		ExplodeString(options, "_", data, sizeof(data), sizeof(data[]));
		
		int job_id = StringToInt(data[0]);
		int diff = StringToInt(data[1]);
		
		int amount = ( StringToInt(g_szJobList[job_id][job_type_pay]) + diff );
		
		int max = 500;
		int min = 0;

		int jobid = rp_GetClientJobID(client);

		if( jobid == 11 || jobid == 21 || jobid == 31 || jobid == 51 || jobid == 61 || jobid == 71 || jobid == 81 || jobid == 111 || jobid == 131 || jobid == 171 || jobid == 211 || jobid == 221) {
			max = 650;
		}
		
		if( jobid == 41 || jobid == 91) {
			min = 150;
		}

		if( amount < min ) {
			amount = min;
		}
		if( amount > max && !IsAdmin(client) ) {
			amount = max;
		}
		
		Format( g_szJobList[job_id][job_type_pay], 127, "%i", amount);
		
		CPrintToChat(client, "" ...MOD_TAG... " Le grade \"%s\" a maintenant %i$ de paye.", g_szJobList[job_id][job_type_name], amount);
		
		OpenBossPayMenu(client);
	}
	else if( action == MenuAction_End ) {
		CloseHandle(menu);
	}
}

void OpenBossConfig(int client) {
	
	if( !IsBoss(client) ) {
		return;
	}
	
	// Setup menu
	Handle menu = CreateMenu(MenuBossConfig);
	SetMenuTitle(menu, "Sélectionner une Action\n ");
	
	AddMenuItem(menu, "pay", "Modification des payes");
	AddMenuItem(menu, "grade", "Modification des grades");
	
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_DURATION);
	
	return;
}
public int MenuBossConfig(Handle menu, MenuAction action, int client, int param2) {
	if( action == MenuAction_Select ) {
		char options[64];
		GetMenuItem(menu, param2, options, 63);
		
		if( !IsBoss(client) ) {
			return;
		}
		
		if( StrEqual( options, "pay", false) ) {
			
			OpenBossPayMenu(client);
		}
		else if( StrEqual( options, "grade", false) ) {
			char query[1024];
			Format(query, sizeof(query), "SELECT `steamid`, `name`, `job_id`, UNIX_TIMESTAMP(`last_connected`) FROM `rp_users` WHERE `job_id`<>'0'");
			
			SQL_TQuery(g_hBDD, MenuBossConfig_grade, query, client, DBPrio_High);
		}
	}
	else if( action == MenuAction_End ) {
		CloseHandle(menu);
	}
}
public int MenuBossConfig_grade(Handle owner, Handle hQuery, const char[] error, any client) {
	
	if( !IsBoss(client) ) {
		return;
	}
	
	// Setup menu
	Handle menu = CreateMenu(MenuBossConfig_gradeMenu);
	SetMenuTitle(menu, "Sélectionner un joueur\n ");
	
	char SteamID[64], name[128];
	int	job_id;
	
	while( SQL_FetchRow(hQuery) ) {
		
		SQL_FetchString(hQuery, 0, SteamID, 63);
		SQL_FetchString(hQuery, 1, name, 127);
		job_id = SQL_FetchInt(hQuery, 2);
		
		if( StringToInt(g_szJobList[ job_id ][2]) != GetJobPrimaryID(client) )
			continue;
		if( g_iUserData[client][i_Job] == job_id )
			continue;
		
		if( SQL_FetchInt(hQuery, 3) <= ((GetTime())-(7*24*60*60)) ) {
			Format(name, sizeof(name), "%s [%s] - Inactif", name, g_szJobList[job_id][job_type_name]);
		}
		else {
			Format(name, sizeof(name), "%s [%s]", name, g_szJobList[job_id][job_type_name]);
		}
		
		AddMenuItem(menu, SteamID, name);
	}
	
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_DURATION);
}
public int MenuBossConfig_gradeMenu(Handle p_hHireMenu, MenuAction p_oAction, int client, int p_iParam2) {
	if (p_oAction == MenuAction_Select) {
		
		
		if( !IsValidClient(client) || !IsBoss(client) ) {
			return;
		}
		
		char szMenuItem[32];
		
		if (GetMenuItem(p_hHireMenu, p_iParam2, szMenuItem, sizeof(szMenuItem))) {
			
			
			char tmp[255];
			
			// Setup menu
			Handle hHireMenu = CreateMenu(eventSetJobMenu);
			SetMenuTitle(hHireMenu, "Selectionner un nouveau grade\n ");
			
			Format(tmp, 254, "%s 0", szMenuItem);
			AddMenuItem(hHireMenu, tmp, g_szJobList[0][0]);
			
			for(int i = 0; i < MAX_JOBS; i++) {
				if( StringToInt(g_szJobList[i][2]) != GetJobPrimaryID(client) )
					continue;
				
				if( StringToInt(  g_szJobList[ i ][job_type_cochef] ) == 1 && StringToInt(  g_szJobList[ g_iUserData[client][i_Job] ][job_type_cochef] ) == 1 )
					continue;
				
				Format(tmp, 254, "%s %d", szMenuItem, i);
				AddMenuItem(hHireMenu, tmp, g_szJobList[i][job_type_name]);
			}
			
			SetMenuExitButton(hHireMenu, true);
			DisplayMenu(hHireMenu, client, MENU_TIME_DURATION);
			
		}
	}
	else if (p_oAction == MenuAction_End) {
		CloseHandle(p_hHireMenu);
	}
}

public int GestionKeyBoss(Handle menu, MenuAction action, int param1, int param2) {
	if( action == MenuAction_Select ) {
		char options[64];
		GetMenuItem(menu, param2, options, 63);
		
		char data[2][32];
		
		ExplodeString(options, "_", data, sizeof(data), sizeof(data[]));
		
		int job = StringToInt(data[0]);
		int door_bdd = StringToInt(data[1]);
		char mapname[32];
		GetCurrentMap(mapname, sizeof(mapname));
		char query[1024];
		
		if( g_iDoorJob[job][door_bdd] ) {
			
			Format(query, 1023, "DELETE FROM `rp_jobs_doors` WHERE `job_id`='%i' AND `map`='%s' AND `door_id`='%i';", job, mapname, door_bdd);
			g_iDoorJob[job][door_bdd] = 0;
			
			CPrintToChat(param1, "" ...MOD_TAG... " Cette clé a été retirée pour les %s.", g_szJobList[job][0]);
		}
		else {
			
			Format(query, 1023, "INSERT INTO `rp_jobs_doors` (`map`, `job_id`, `door_id`) VALUES ('%s', '%i','%i');", mapname, job, door_bdd);
			g_iDoorJob[job][door_bdd] = 1;
			
			CPrintToChat(param1, "" ...MOD_TAG... " Cette clé a été ajoutée pour les %s.", g_szJobList[job][0]);
		}
		
		SQL_TQuery(g_hBDD, SQL_QueryCallBack, query);
	}
	else if (action == MenuAction_End) {
		CloseHandle(menu);
	}
}
public int GestionKeyBoss_2(Handle menu, MenuAction action, int param1, int param2) {
	if( action == MenuAction_Select ) {
		char options[64];
		GetMenuItem(menu, param2, options, 63);
		
		char data[2][32];
		
		ExplodeString(options, "_", data, sizeof(data), sizeof(data[]));
		
		int job_own = StringToInt(data[0]);
		int door_bdd = StringToInt(data[1]);
		char mapname[32];
		GetCurrentMap(mapname, sizeof(mapname));
		char query[1024];
		
		for(int i = 0; i < MAX_JOBS; i++) {
			
			if( strlen(g_szJobList[i][job_type_name]) <= 1 )
				continue;
			
			if( i == job_own || StringToInt(g_szJobList[i][job_type_ownboss]) == job_own || job_own < 0) {
				int job = i;
				
				if( (g_iDoorJob[job][door_bdd] && job_own > 0) || job_own == -1 ) {
					
					Format(query, 1023, "DELETE FROM `rp_jobs_doors` WHERE `job_id`='%i' AND `map`='%s' AND `door_id`='%i';", job, mapname, door_bdd);
					g_iDoorJob[job][door_bdd] = 0;
					SQL_TQuery(g_hBDD, SQL_QueryCallBack, query);
					CPrintToChat(param1, "" ...MOD_TAG... " Cette clé a été retirée pour les %s.", g_szJobList[job][0]);
				}
				else {
					
					Format(query, 1023, "INSERT INTO `rp_jobs_doors` (`map`, `job_id`, `door_id`) VALUES ('%s', '%i','%i');", mapname, job, door_bdd);
					g_iDoorJob[job][door_bdd] = 1;
					
					SQL_TQuery(g_hBDD, SQL_QueryCallBack, query);
					CPrintToChat(param1, "" ...MOD_TAG... " Cette clé a été ajoutée pour les %s.", g_szJobList[job][0]);
				}
			}
		}
		
	}
	else if (action == MenuAction_End) {
		CloseHandle(menu);
	}
}