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

#pragma newdecls required
#include <roleplay.inc>	// https://www.ts-x.eu

float g_flPressUse[MAXPLAYERS + 1];
bool g_bPressedUse[MAXPLAYERS + 1];
bool g_bClosed[MAXPLAYERS + 1];
bool g_bInsideMenu[MAXPLAYERS + 1];

public Plugin myinfo = {
	name = "Utils: Menu", author = "KoSSoLaX",
	description = "RolePlay - Utils: Menu",
	version = __LAST_REV__, url = "https://www.ts-x.eu"
};
public void OnPluginStart() {
	LoadTranslations("core.phrases");
	LoadTranslations("common.phrases");
	LoadTranslations("roleplay.phrases");
	LoadTranslations("roleplay.core.phrases");
	LoadTranslations("roleplay.utils.phrases");
	
	for (int i = 1; i <= MaxClients; i++)
		if( IsValidClient(i) )
			OnClientPostAdminCheck(i);
}
public void OnClientPostAdminCheck(int client) {
	g_flPressUse[client] = -1.0;
	g_bPressedUse[client] = false;
	g_bClosed[client] = false;
	
	rp_HookEvent(client, RP_OnPlayerCommand, fwdCommand);
}
public Action fwdCommand(int client, char[] command, char[] arg) {
	if( StrEqual(command, "menu") ) {
		
		openMenuGeneral(client);
		
		if( g_bClosed[client] == true )	
			g_bClosed[client] = false;
		
		openMenuInteractif(client);
		return Plugin_Handled;
	}
	if( StrEqual(command, "rp") || StrEqual(command, "rpmenu") ) {
		openMenuGeneral(client);
		return Plugin_Handled;
	}
	if( StrEqual(command, "steam") || StrEqual(command, "steamid") ) {
		return showSteamID(client);
	}
	if( StrEqual(command, "discord") || StrEqual(command, "invite") ) {
		return showDiscord(client);
	}
	return Plugin_Continue;
}
public Action showDiscord(int client) {
	CPrintToChatAll("" ...MOD_TAG..." %T", "Ads_JoinDiscord", LANG_SERVER);
	CPrintToChatAll("" ...MOD_TAG... " " ... MOD_DISCORD ..."");
	return Plugin_Continue;
}
public Action showSteamID(int client) {
	char tmp[64], tmp2[64];
	
	PrintToConsole(client, "============================================================ ");
	PrintToConsole(client, "============================================================ ");
	PrintToConsole(client, "============================================================ ");
	
	for (int i = 1; i <= 64; i++) {
		if( !IsValidClient(i) )
			continue;
		
		GetClientAuthId(i, AuthId_Engine, tmp, sizeof(tmp));
		GetClientAuthId(i, AuthId_SteamID64, tmp2, sizeof(tmp2));
		
		PrintToConsole(client, "%N %s (%s)", i, tmp2, tmp);
		if( i == client )
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Cmd_SteamID", client, tmp2, tmp);
	}
	
	PrintToConsole(client, "============================================================ ");
	PrintToConsole(client, "============================================================ ");
	PrintToConsole(client, "============================================================ ");
	
	return Plugin_Handled;
}
public Action OnPlayerRunCmd(int client, int &button) {
	if( button & IN_USE && g_bPressedUse[client] == false ) {
		g_bPressedUse[client] = true;
		g_flPressUse[client] = GetGameTime();
	}
	if( !(button & IN_USE) && g_bPressedUse[client] == true ) {
		g_bPressedUse[client] = false;
		if( (GetGameTime() - g_flPressUse[client]) < 0.2 && !g_bClosed[client] && rp_GetClientVehicle(client) <= 0 && rp_IsTutorialOver(client) ) {
			if( rp_ClientCanDrawPanel(client) || g_bInsideMenu[client] )
				CreateTimer(0.1, taskOpenMenu, client);
		}
	}
}
public Action taskOpenMenu(Handle timer, any client) {
	if( rp_ClientCanDrawPanel(client) || g_bInsideMenu[client] )
		 openMenuInteractif(client);
}
void openMenuInteractif(int client) {
	int target = rp_GetClientTarget(client);
	bool veryNear = rp_IsEntitiesNear(client, target, true);
	bool near = rp_IsEntitiesNear(client, target, false);
	
	
	int jobID = rp_GetClientJobID(client);
	int optionCount = 0;
	
	char tmp[128];
	
	Menu menu = CreateMenu(menuOpenMenu);
	menu.SetTitle("RolePlay\n ");
	
	if( IsValidClient(target) ) {
		bool hear = rp_IsTargetHear(client, target);
		
		GetClientName2(target, tmp, sizeof(tmp), true);
		menu.SetTitle("RolePlay: %s\n ", tmp);
		
		if( near && ((jobID >= 11 && jobID <= 81) || jobID >= 111) ) {
			Format(tmp, sizeof(tmp), "%T", "Menu_Sell", client);
			menu.AddItem("vendre", tmp);
			optionCount++;
		}
		
		
		if( veryNear && rp_GetClientBool(client, b_MaySteal) && (jobID == 81 || jobID == 91) ) {
			Format(tmp, sizeof(tmp), "%T", "Menu_Steal", client);
			menu.AddItem("vol", tmp);
			optionCount++;
		}
		
		if( near && jobID == 71 ) {
			Format(tmp, sizeof(tmp), "%T", "Menu_Train", client);
			menu.AddItem("cutinfo", tmp);
			optionCount++;
		}
		
		if( near && jobID == 11 ) {
			Format(tmp, sizeof(tmp), "%T", "Menu_Heal", client);
			menu.AddItem("heal", tmp);
			optionCount++;
		}
		
		
		if( hear && (jobID == 1 || jobID == 101) ) {
			Format(tmp, sizeof(tmp), "%T", "Menu_Search", client);
			menu.AddItem("search", tmp);
			
			Format(tmp, sizeof(tmp), "%T", "Menu_Jail", client);
			menu.AddItem("jail", tmp);
			
			Format(tmp, sizeof(tmp), "%T", "Menu_Tazer", client);
			menu.AddItem("tazer", tmp);
			optionCount++;
		}
		
		
		
		if( hear && jobID > 0 && rp_GetPlayerZone(target) == rp_GetPlayerZone(client) && rp_GetZoneInt(client, zone_type_type) == jobID ) {
			Format(tmp, sizeof(tmp), "%T", "Menu_Out", client);
			menu.AddItem("out", tmp);
		}
		
		
		if( near && rp_GetClientInt(client, i_Money) > 0 && !rp_IsClientNew(client) ) {
			Format(tmp, sizeof(tmp), "%T", "Menu_Give", client);
			menu.AddItem("give", tmp);
			optionCount++;
		}
	}
	else if( rp_IsValidDoor(target) ) {
		menu.SetTitle("RolePlay: %T\n ", "Menu_Door", client);
		
		int doorID = rp_GetDoorID(target);
		if( doorID > 0 && rp_GetClientKeyDoor(client, doorID) ) {
			if( GetEntProp(target, Prop_Data, "m_bLocked") ) 
				Format(tmp, sizeof(tmp), "%T", "Menu_Door_Unlock", client);
			else
				Format(tmp, sizeof(tmp), "%T", "Menu_Door_Lock", client);
			
			if( GetEntProp(target, Prop_Data, "m_bLocked") ) 
				menu.AddItem("unlock", tmp);
			else
				menu.AddItem("lock", tmp);
			
			optionCount++;
		}
		
		if( jobID == 1 && rp_GetClientInt(client, i_Job) <= 7 ) {
			Format(tmp, sizeof(tmp), "%T", "Menu_Door_Perquiz", client);
			menu.AddItem("perquiz", tmp);
		}
		if( jobID == 101 ) {
			Format(tmp, sizeof(tmp), "%T", "Menu_Door_Perquiz", client);
			menu.AddItem("perquiz", tmp);
		}Menu_Door_Oppe
		if( jobID == 91 ) {
			Format(tmp, sizeof(tmp), "%T", "Menu_Door_Oppe", client);
			menu.AddItem("oppe", tmp);
		}
	}
	
	if( optionCount == 0 ) {
		delete menu;
		return;
	}
	
	Format(tmp, sizeof(tmp), "%T", "Menu_DoNotReOpen", client);
	menu.AddItem("exit", tmp);
	menu.Pagination = 8;
	menu.Display(client, 30);
	
	g_bInsideMenu[client] = true;
}
void openMenuGeneral(int client) {
	int jobID = rp_GetClientJobID(client);
	
	Menu menu = CreateMenu(menuOpenMenu);
	menu.SetTitle("RolePlay\n ");
	
	
	char tmp[128];
	Format(tmp, sizeof(tmp), "%T", "Menu_Item", client);
	menu.AddItem("item", tmp);

	Format(tmp, sizeof(tmp), "%T", "Menu_Passif", client);
	menu.AddItem("passif", tmp);
	
	if( jobID == 101 && rp_GetZoneInt(rp_GetPlayerZone(client), zone_type_type) == 101 ) {
		Format(tmp, sizeof(tmp), "%T", "Menu_Tb", client);
		menu.AddItem("tb", tmp);
	}

	
	if( jobID == 11 ) {
		Format(tmp, sizeof(tmp), "%T", "Menu_Mort", client);
		menu.AddItem("mort", tmp);
	}
	
	Format(tmp, sizeof(tmp), "%T", "Menu_Build", client);
	menu.AddItem("build", tmp);
	
	Format(tmp, sizeof(tmp), "%T", "Menu_Shownote", client);
	menu.AddItem("shownote", tmp);
	
	Format(tmp, sizeof(tmp), "%T", "Menu_Job", client);
	menu.AddItem("job", tmp);
	
	Format(tmp, sizeof(tmp), "%T", "Menu_GPS", client);
	menu.AddItem("gps", tmp);
	
	Format(tmp, sizeof(tmp), "%T", "Menu_Aide", client);
	menu.AddItem("aide", tmp);
	
	Format(tmp, sizeof(tmp), "%T", "Menu_Stats", client);
	menu.AddItem("stats", tmp);
	
	Format(tmp, sizeof(tmp), "%T", "Menu_Report", client);
	menu.AddItem("report", tmp);
	
	menu.Display(client, 30);
	
	g_bInsideMenu[client] = true;
}
public int menuOpenMenu(Handle hItem, MenuAction oAction, int client, int param) {
	if (oAction == MenuAction_Select) {
		char options[64];
		if( GetMenuItem(hItem, param, options, sizeof(options)) ) {
			if( StrEqual(options, "give") ) {
				if( rp_GetClientInt(client, i_Money) < 1 )
					return;
				
				Menu menu = CreateMenu(menuOpenMenu);
				menu.SetTitle("RolePlay: %T\n ", "Menu_Give", client);
				if( rp_GetClientInt(client, i_Money) >= 1 ) menu.AddItem("give 1", "1$");
				if( rp_GetClientInt(client, i_Money) >= 10 ) menu.AddItem("give 10", "10$");
				if( rp_GetClientInt(client, i_Money) >= 100 ) menu.AddItem("give 100", "100$");
				if( rp_GetClientInt(client, i_Money) >= 1000 ) menu.AddItem("give 1000", "1.000$");
				if( rp_GetClientInt(client, i_Money) >= 10000 ) menu.AddItem("give 10000", "10.000$");
				if( rp_GetClientInt(client, i_Money) >= 100000 ) menu.AddItem("give 100000", "100.000$");
				
				menu.Display(client, 10);
				return;
			}
			if( StrEqual(options, "exit") ) {
				CPrintToChat(client, "" ...MOD_TAG... " %T", "Menu_DoNotReOpen_Confirm", client);
				g_bClosed[client] = true;
				return;
			}
			FakeClientCommand(client, "say /%s", options);
		}		
	}
	else if (oAction == MenuAction_End ) {
		CloseHandle(hItem);
	}
	else if (oAction == MenuAction_Cancel ) {
		g_bInsideMenu[client] = false;
	}
}

