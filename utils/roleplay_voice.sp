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
#include <sdkhooks>
#include <smlib>
#include <colors_csgo>
#include <basecomm>

#pragma newdecls required
#include <roleplay.inc>	// https://www.ts-x.eu


Handle g_vAllTalk;
bool g_bAllTalk = false;
int g_iMayTalk[65];

public Plugin myinfo = {
	name = "Utils: VoiceProximity", author = "KoSSoLaX",
	description = "RolePlay - Utils: VoiceProximity",
	version = __LAST_REV__, url = "https://www.ts-x.eu"
};
public Action Cmd_Reload(int args) {
	char name[64];
	GetPluginFilename(INVALID_HANDLE, name, sizeof(name));
	ServerCommand("sm plugins reload %s", name);
	return Plugin_Continue;
}
public void OnPluginStart() {
	LoadTranslations("core.phrases");
	LoadTranslations("common.phrases");
	LoadTranslations("plugin.basecommands");
	LoadTranslations("roleplay.phrases");
	LoadTranslations("roleplay.core.phrases");
	LoadTranslations("roleplay.utils.phrases");

	RegServerCmd("rp_quest_reload", Cmd_Reload);	
	for (int i = 1; i <= MaxClients; i++)
		if( IsValidClient(i) )
			OnClientPostAdminCheck(i);
	
	g_vAllTalk = CreateConVar("rp_alltalk", "0", "alltalk en zone event", 0, true, 0.0, true, 1.0);
	HookConVarChange(g_vAllTalk, OnCvarChange);
}
public void OnCvarChange(Handle cvar, const char[] oldVal, const char[] newVal) {
	
	if( cvar == g_vAllTalk ) {
		if( StrEqual(newVal, "1") )
			g_bAllTalk = true;
		else 
			g_bAllTalk = false;
	}
}
public void OnClientPostAdminCheck(int client) {
	g_iMayTalk[client] = GetTime();
	
	rp_HookEvent(client, RP_OnPlayerHear, fwdHear);
	rp_HookEvent(client, RP_OnPlayerCommand, fwdCommand);
}
public Action fwdCommand(int client, char[] command, char[] arg) {
	static char name[64];
	#if defined DEBUG
	PrintToServer("fwdCommand");
	#endif
	
	GetClientName2(client, name, sizeof(name), false);
	
	if( StrEqual(command, "job") || StrEqual(command, "jobs") ) {
		Cmd_job(client);
		return Plugin_Handled;
	}
	else if( StrEqual(command, "me") || StrEqual(command, "annonce") ) {
		
		if( !rp_GetClientBool(client, b_IsNoPyj) ) {
			ACCESS_DENIED(client);
		}
		if( BaseComm_IsClientGagged(client) || rp_GetClientBool(client, b_IsMuteGlobal) ) {
			CPrintToChat(client, "" ...MOD_TAG... "%T", "Banned_GlobalTalk", client);
			return Plugin_Handled;
		}
		if( rp_GetClientJobID(client) != 1 && rp_GetClientJobID(client) != 101 ) {
			if( g_iMayTalk[client] > GetTime() ) {
				CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_YouMustWaitToTalk", client, g_iMayTalk[client] - GetTime());
				return Plugin_Handled;
			}
			
			g_iMayTalk[client] = GetTime() + 10;
		}
		
		CPrintToChatAll("%T", "Chat_Talk", LANG_SERVER, name, "Chat_TAG_EMOTE", arg);
		LogToGame("[TSX-RP] [ANNONCES] %L: %s", client, arg);

		return Plugin_Handled;
	}
	else if( StrEqual(command, "c") || StrEqual(command, "coloc") || StrEqual(command, "colloc") ) {
		if( rp_GetClientInt(client, i_AppartCount) == 0 ) {
			ACCESS_DENIED(client);
		}
		if( BaseComm_IsClientGagged(client) || rp_GetClientBool(client, b_IsMuteLocal) ) {
			CPrintToChat(client, "" ...MOD_TAG... "%T", "Banned_LocalTalk", client);
			return Plugin_Handled;
		}

		bool clientChat[MAXPLAYERS+1];
		
		for (int i = 1; i < 200; i++) {
			if( !rp_GetClientKeyAppartement(client, i) )
				continue;
			
			for(int j=1; j<=MAXPLAYERS; j++) {
				if( !IsValidClient(j) )
					continue;
				if( !rp_GetClientKeyAppartement(j, i) )
					continue;
					
				clientChat[j] = true;
			}
		}
		for( int i = 0; i<sizeof(clientChat); i++ ){
			if(clientChat[i])
				CPrintToChatEx(i, client, "%T", "Chat_Talk", LANG_SERVER, name, "Chat_TAG_COLOC", arg);
		}
		
		LogToGame("[TSX-RP] [CHAT-COLLOC] %L: %s", client, arg);
		return Plugin_Handled;
	}
	else if( StrEqual(command, "t") || StrEqual(command, "team") ) {
		
		if( rp_GetClientJobID(client) == 0 ) {
			ACCESS_DENIED(client);
		}

		if( BaseComm_IsClientGagged(client) || rp_GetClientBool(client, b_IsMuteLocal) ) {
			CPrintToChat(client, "" ...MOD_TAG... "%T", "Banned_LocalTalk", client);
			return Plugin_Handled;
		}

		int j = rp_GetClientJobID(client);
		if( j == 101 )
			j = 1;

		for(int i=1; i<=MaxClients; i++) {
			if( !IsValidClient(i) )
				continue;

			int j2 = rp_GetClientJobID(i);
			if( j2 == 101 )
				j2 = 1;

			if( j == j2 ) {
				CPrintToChatEx(i, client, "%T", "Chat_Talk", LANG_SERVER, name, "Chat_TAG_TEAM", arg);
			}
		}
		
		LogToGame("[TSX-RP] [CHAT-TEAM] %L: %s", client, arg);
		return Plugin_Handled;
	}
	else if( StrEqual(command, "m") || StrEqual(command, "marie") ) {
		
		int mari = rp_GetClientInt(client, i_MarriedTo);
		if( mari == 0 ) {
			ACCESS_DENIED(client);
		}
		
		CPrintToChatEx(mari, client, "%T", "Chat_Talk", LANG_SERVER, name, "Chat_TAG_WEDDING", arg);
		CPrintToChatEx(client, client, "%T", "Chat_Talk", LANG_SERVER, name, "Chat_TAG_WEDDING", arg);
		
		LogToGame("[TSX-RP] [CHAT-MARIE] %L: %s", client, arg);
		return Plugin_Handled;
	}
	else if( StrEqual(command, "g") || StrEqual(command, "group") ) {
		if( rp_GetClientGroupID(client) == 0 ) {
			ACCESS_DENIED(client);
		}

		for(int i=1; i<=MaxClients; i++) {
			if( !IsValidClient(i) )
				continue;

			if( rp_GetClientGroupID(i) == rp_GetClientGroupID(client) ) {
				CPrintToChatEx(i, client, "%T", "Chat_Talk", LANG_SERVER, name, "Chat_TAG_GROUP", arg);
			}
		}
		
		LogToGame("[TSX-RP] [CHAT-GROUP] %L: %s", client, arg);
		return Plugin_Handled;
	}
	else if( StrEqual(command, "stopsound") ) {
		ClientCommand(client, "stopsound");
		FakeClientCommand(client, "stopsound");
		return Plugin_Handled;
	}
	return Plugin_Continue;
}
public Action fwdHear(int client, int target, float& dist) {
	
	char Ctype[64], Ttype[64];
	int Czone = rp_GetPlayerZone(client);
	int Tzone = rp_GetPlayerZone(target), Tbit = rp_GetZoneBit(Tzone);
	rp_GetZoneData(Czone, zone_type_type, Ctype, sizeof(Ctype));
	rp_GetZoneData(Tzone, zone_type_type, Ttype, sizeof(Ttype));
	
	if( IsValidClient(target) ) {
		if( rp_GetClientBool(target, b_IsMuteVocal) )
			return Plugin_Stop;
	}
	else if( rp_IsValidVehicle(target) ) {
		if( rp_GetClientBool(Vehicle_GetDriver(target), b_IsMuteVocal) )
			return Plugin_Stop;
	}
	
	if( g_bAllTalk && Tbit & BITZONE_EVENT && Czone == Tzone ) {
		dist = 1.0;
		return Plugin_Continue;
	}
	if( (Czone==290 && Tzone==290) || (Czone==289&&Tzone==289) ) {
		dist = 1.0;
		return Plugin_Continue;
	}
	
	if( (Tbit & BITZONE_JAIL || Tbit & BITZONE_HAUTESECU) ) {
		return Plugin_Stop;
	}
	
	if( !StrEqual(Ctype, Ttype) ) {
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}
public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs){
	if((strcmp(sArgs, "thetime", false) == 0) || (strcmp(sArgs, "timeleft", false) == 0) || (strcmp(sArgs, "/ff", false) == 0) || (strcmp(sArgs, "ff", false) == 0) || (strcmp(sArgs, "currentmap", false) == 0) || (strcmp(sArgs, "nextmap", false) == 0)){
		if( BaseComm_IsClientGagged(client) || rp_GetClientBool(client, b_IsMuteGlobal) ) {
			CPrintToChat(client, "" ...MOD_TAG... "%T", "Banned_GlobalTalk", client);
			return Plugin_Handled;
		}
		
		if( g_iMayTalk[client] > GetTime() ) {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_YouMustWaitToTalk", client, g_iMayTalk[client] - GetTime());
			return Plugin_Handled;
		}
		
		g_iMayTalk[client] = GetTime() + 10;
	}
	return Plugin_Continue;
}
void Cmd_job(int client) {
	char tmp[128];
	Handle jobmenu = CreateMenu(MenuJobs);
	SetMenuTitle(jobmenu, "%T\n ", "Jobs_ListAvailable", client);
	
	Format(tmp, sizeof(tmp), "%T", "Jobs_All", client);
	AddMenuItem(jobmenu, "-1", tmp);
	
	char tmp2[64];
	bool bJob[MAX_JOBS];
	bool hasAvocat;

	for(int i = 1; i <= MaxClients; i++) {

		if( !IsValidClient(i) )
			continue;
		if( !IsClientConnected(i) )
			continue;
		if( rp_GetClientInt(i, i_Job) == 0 )
			continue;
		if( i == client )
			continue;

		int job = rp_GetClientJobID(i);

		if( job == 1 )
			continue;

		bJob[job] = true;
		
		if (!hasAvocat) hasAvocat = ( rp_GetClientInt(i, i_Avocat) > 0 );
	}
	
	if( hasAvocat ) {
		Format(tmp, sizeof(tmp), "%T", "Job_Advocat", client);
		AddMenuItem(jobmenu, "-2", tmp);
	}
	
	char tmp3[2][64];

	for(int i=1; i<MAX_JOBS; i++) {
		if( bJob[i] == false )
			continue;
		Format(tmp, sizeof(tmp), "%d", i);
		rp_GetJobData(i, job_type_name, tmp2, sizeof(tmp2));
		
		ExplodeString(tmp2, " - ", tmp3, sizeof(tmp3), sizeof(tmp3[]));

		AddMenuItem(jobmenu, tmp, tmp3[1]);
	}

	SetMenuExitButton(jobmenu, true);
	DisplayMenu(jobmenu, client, 60);
	return;
}

public int MenuJobs(Handle p_hItemMenu, MenuAction p_oAction, int client, int p_iParam2) {
	if (p_oAction == MenuAction_Select) {
		char szMenuItem[8];
		if (GetMenuItem(p_hItemMenu, p_iParam2, szMenuItem, sizeof(szMenuItem))){
			Handle menu = CreateMenu(MenuJobs2);

			SetMenuTitle(menu, "%T\n ", "Cmd_ListOfPlayer", client);
			int jobid = StringToInt(szMenuItem);
			int amount = 0;
			char tmp[128], tmp2[128];

			for(int i=1; i<=MAXPLAYERS;i++){
				if(!IsValidClient(i))
					continue;

				if(jobid == -2 && rp_GetClientInt(i, i_Avocat) <= 0)
					continue;

				if(jobid >= 0 && (i == client || rp_GetClientJobID(i) != jobid))
					continue;

				Format(tmp2, sizeof(tmp2), "%i", i);
				int ijob = rp_GetClientInt(i, i_Job);
				rp_GetJobData(ijob, job_type_name, tmp, sizeof(tmp));
				
				if( rp_GetClientJobID(i) == 1 ) {
					if( rp_GetClientInt(client, i_KillJailDuration) >= 1) {
						Format(tmp, sizeof(tmp), "%T", "ScoreBar_TAG_Criminal", client);
					} else {
						Format(tmp, sizeof(tmp), "%T", "ScoreBar_TAG_Police", client);
					}
				}

				if(rp_GetClientBool(i, b_IsAFK))
					Format(tmp, sizeof(tmp), "[AFK] %N - %s", i, tmp);
				else if(rp_GetClientInt(i, i_JailTime) > 0)
					Format(tmp, sizeof(tmp), "[JAIL] %N - %s", i, tmp);
				else if(rp_GetZoneBit(rp_GetPlayerZone(i)) & BITZONE_EVENT)
					Format(tmp, sizeof(tmp), "[EVENT] %N - %s", i, tmp);
				else
					Format(tmp, sizeof(tmp), "%N - %s", i, tmp);

				if(jobid == -2){
					Format(tmp, sizeof(tmp), "%s (%d$)", tmp, rp_GetClientInt(i, i_Avocat));
				}

					
				AddMenuItem(menu, tmp2, tmp);
				amount++;
			}

			if( amount == 0 ) {
				CloseHandle(menu);
			}
			else {
				SetMenuExitButton(menu, true);
				DisplayMenu(menu, client, 60);
			}
		}
	}
	else if (p_oAction == MenuAction_End) {
		CloseHandle(p_hItemMenu);
	}
}

public int MenuJobs2(Handle p_hItemMenu, MenuAction p_oAction, int client, int p_iParam2) {
	if (p_oAction == MenuAction_Select) {
		char szMenuItem[8];
		if (GetMenuItem(p_hItemMenu, p_iParam2, szMenuItem, sizeof(szMenuItem))){
			Handle menu = CreateMenu(MenuJobs3);
			SetMenuTitle(menu, "%T\n ", "Ask_What", client);
			
			int target = StringToInt(szMenuItem);
			int jobid = rp_GetClientJobID(target);
			int amount = 0;
			char tmp[128], tmp2[128];

			if(rp_GetClientInt(target, i_Job)%10 == 1 || rp_GetClientInt(target, i_Job)%10 == 2 && jobid !=1 && jobid != 101){
				Format(tmp2, sizeof(tmp2), "%i_-1", target);
				AddMenuItem(menu, tmp2, "%T", "Ask_Recrut", client);
				amount++;
			}
			if(jobid == 91){
				Format(tmp2, sizeof(tmp2), "%i_-2", target);
				AddMenuItem(menu, tmp2, "%T", "Ask_Picklock", client);
				amount++;
			}
			if(jobid == 181){
				Format(tmp2, sizeof(tmp2), "%i_-3", target);
				AddMenuItem(menu, tmp2, "%T", "Ask_Weapon", client);
				amount++;
			}
			if(rp_GetClientInt(target, i_Avocat) > 0) {
				Format(tmp2, sizeof(tmp2), "%i_-5", target);
				AddMenuItem(menu, tmp2, "%T", "Ask_Avocat", client);
				amount++;
			}
			if(jobid == 101) {
				Format(tmp2, sizeof(tmp2), "%i_-4", target);
				AddMenuItem(menu, tmp2, "%T", "Ask_Judge", client);
				amount++;
			}
			if(jobid == 61) {
				Format(tmp2, sizeof(tmp2), "%i_-6", target);
				AddMenuItem(menu, tmp2, "%T", "Ask_Appart", client);
				amount++;
				
				Format(tmp2, sizeof(tmp2), "%i_-7", target);
				AddMenuItem(menu, tmp2, "%T", "Ask_Clean", client);
				amount++;
			}
			else{
				for(int i=1;i<MAX_ITEMS;i++){
					rp_GetItemData(i, item_type_job_id, tmp, sizeof(tmp));
					if(StringToInt(tmp) != jobid || StringToInt(tmp)==0)
						continue;

					rp_GetItemData(i, item_type_name, tmp, sizeof(tmp));
					Format(tmp2, sizeof(tmp2), "%i_%i", target, i);
					AddMenuItem(menu, tmp2, tmp);
					amount++;
				}
			}

			if( amount == 0 ) {
				CloseHandle(menu);
			}
			else {
				SetMenuExitButton(menu, true);
				DisplayMenu(menu, client, 60);
			}
		}
	}
	else if (p_oAction == MenuAction_End) {
		CloseHandle(p_hItemMenu);
	}
}

public int MenuJobs3(Handle p_hItemMenu, MenuAction p_oAction, int client, int p_iParam2) {
	if (p_oAction == MenuAction_Select) {
		char szMenuItem[16];
		if (GetMenuItem(p_hItemMenu, p_iParam2, szMenuItem, sizeof(szMenuItem))){
						
			char data[2][32], tmp[128], tmp2[128];
			ExplodeString(szMenuItem, "_", data, sizeof(data), sizeof(data[]));
			int target = StringToInt(data[0]);
			int item_id = StringToInt(data[1]);
			
			if( rp_ClientFloodTriggered(client, target, fd_job) ) {
				GetClientName2(target, tmp, sizeof(tmp), false);
				CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_ItemCannotBeUsedForNow", client, tmp);
				return;
			}
			rp_ClientFloodIncrement(client, target, fd_job, 10.0);
			
			char zoneName[64];
			rp_GetZoneData(rp_GetPlayerZone(client), zone_type_name, zoneName, sizeof(zoneName));
	
			GetClientName2(client, tmp, sizeof(tmp), false);
			
			switch(item_id){
				case -1: Format(tmp2, sizeof(tmp2), "%T", "Ask_Recrut", client);
				case -2: Format(tmp2, sizeof(tmp2), "%T", "Ask_Picklock", client);
				case -3: Format(tmp2, sizeof(tmp2), "%T", "Ask_Weapon", client);
				case -4: Format(tmp2, sizeof(tmp2), "%T", "Ask_Judge", client);
				case -5: Format(tmp2, sizeof(tmp2), "%T", "Ask_Avocat", client);
				case -6: Format(tmp2, sizeof(tmp2), "%T", "Ask_Appart", client);
				case -7: Format(tmp2, sizeof(tmp2), "%T", "Ask_Clean", client);
				case -8: Format(tmp2, sizeof(tmp2), "%T", "Ask_Craft", client);
				default: {
					rp_GetItemData(item_id, item_type_name, tmp2, sizeof(tmp2));
				}
			}
			
			CPrintToChat(target, "" ...MOD_TAG... " %T", "Ask_Done", client, tmp, zoneName, tmp2);
			
			GetClientName2(target, tmp, sizeof(tmp), false);
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Ask_Send", client, tmp);
			
			ClientCommand(target, "play buttons/blip1.wav");
			rp_Effect_BeamBox(target, client, NULL_VECTOR, 122, 122, 0);
			Handle dp;
			CreateDataTimer(1.0, ClientTargetTracer, dp, TIMER_DATA_HNDL_CLOSE|TIMER_REPEAT);
			WritePackCell(dp, 0);
			WritePackCell(dp, client);
			WritePackCell(dp, target);
		}
	}
	else if (p_oAction == MenuAction_End) {
		CloseHandle(p_hItemMenu);
	}
}

public Action ClientTargetTracer(Handle timer, Handle dp) {
	ResetPack(dp);
	int count = view_as<int>(ReadPackCell(dp));
	int client = view_as<int>(ReadPackCell(dp));
	int target = view_as<int>(ReadPackCell(dp));
	
	
	if(!IsValidClient(client) || !IsValidClient(target)) {
		return Plugin_Stop;
	}
	
	rp_Effect_BeamBox(target, client, NULL_VECTOR, 122, 122, 0);
	
	if( count >= 5 ){
		return Plugin_Stop;
	}
	
	ResetPack(dp);
	WritePackCell(dp, count + 1);
	
	return Plugin_Continue;
}
