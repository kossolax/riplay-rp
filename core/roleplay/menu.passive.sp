#if defined _roleplay_menu_passive_included
#endinput
#endif
#define _roleplay_menu_passive_included

#if !defined _roleplay_base_included || defined ROLEPLAY_SUB
	#define ROLEPLAY_SUB
	#include "../roleplay.sp"
#else
	#include "roleplay.sp"
#endif

void Draw_PassiveMenu(int client) {
	
	char tmp[128];
	
	Menu menu = new Menu(Menu_Passive);
	menu.SetTitle("%T\n ", "Cmd_Passive", client);
	
	Format(tmp, sizeof(tmp), "%T\n ", "Cmd_Passive_Enable", client); menu.AddItem("1", tmp);
	Format(tmp, sizeof(tmp), "%T", "Cmd_Passive_Disable", client); menu.AddItem("2", tmp);
	
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Menu_Passive(Handle p_hItemMenu, MenuAction p_oAction, int client, int param) {
	char tmp[128];
	
	if (p_oAction == MenuAction_Select) {
		
		char szMenuItem[64];
		GetMenuItem(p_hItemMenu, param, szMenuItem, sizeof(szMenuItem));
		
		if( StrEqual(szMenuItem, "1") ) {
			Menu menu = new Menu(Menu_Passive);
			menu.SetTitle("%T\n ", "Cmd_Passive_Enable_Confirm", client);
			
			Format(tmp, sizeof(tmp), "%T", "No", client);	menu.AddItem("0", tmp);
			Format(tmp, sizeof(tmp), "%T", "Yes", client);	menu.AddItem("3", tmp);
			
			menu.Display(client, MENU_TIME_FOREVER);
		}
		else if( StrEqual(szMenuItem, "2") ) {
			Menu menu = new Menu(Menu_Passive);
			
			char tmp[128];
			int jobID = rp_GetClientJobID(client);
			Format(tmp, sizeof(tmp), "Cmd_Passive_Disable_Confirm_%d", jobID);

			menu.SetTitle("%T\n", "Cmd_Passive_Disable_Confirm", client, tmp);
			
			Format(tmp, sizeof(tmp), "%T", "Yes", client);	menu.AddItem("4", tmp);
			Format(tmp, sizeof(tmp), "%T", "No", client);	menu.AddItem("0", tmp);
			
			menu.Display(client, MENU_TIME_FOREVER);
		}
		else if( StrEqual(szMenuItem, "3") || StrEqual(szMenuItem, "4") ) {
			
			
			if( StrEqual(szMenuItem, "3") ) {
				if( g_iUserData[client][i_KillJailDuration] >= 6 ) {
					CPrintToChat(client, "" ...MOD_TAG... " %T", "Cmd_Passive_Kill", client);
					g_hTIMER[client] = INVALID_HANDLE;
					Draw_PassiveMenu(client);
					return;
				}
				if( g_iUserData[client][i_LastAgression]+30 >= GetTime() ) {
					CPrintToChat(client, "" ...MOD_TAG... " %T", "Cmd_Passive_Aggress", client);
					g_hTIMER[client] = INVALID_HANDLE;
					Draw_PassiveMenu(client);
					return;
				}
				if( g_iUserData[client][i_LastDangerousShot]+30 >= GetTime() ) {
					CPrintToChat(client, "" ...MOD_TAG... " %T", "Cmd_Passive_Aggress", client);
					g_hTIMER[client] = INVALID_HANDLE;
					Draw_PassiveMenu(client);
					return;
				}
			}
			
			if( g_hTIMER[client] != INVALID_HANDLE )
				delete g_hTIMER[client];
			
			DataPack dp = CreateDataPack();
			g_hTIMER[client] = CreateDataTimer(60.0, switchToPassive, dp, TIMER_DATA_HNDL_CLOSE);
			dp.WriteCell(client);
			dp.WriteCell(StrEqual(szMenuItem, "3"));
			
			CPrintToChat(client, "" ...MOD_TAG... " %T", StrEqual(szMenuItem, "3") ? "Cmd_Passive_Enabling" : "Cmd_Passive_Disabling", client);
		}
		else {
			Draw_PassiveMenu(client);
		}
	}
	else if (p_oAction == MenuAction_End) {
		CloseHandle(p_hItemMenu);
	}
}
public Action switchToPassive(Handle timer, Handle dp) {
	ResetPack(dp);
	int client = ReadPackCell(dp);
	bool value = ReadPackCell(dp);
	
	if( value ) {
		if( g_iUserData[client][i_KillJailDuration] >= 6 ) {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Cmd_Passive_Kill", client);
			g_hTIMER[client] = INVALID_HANDLE;
			Draw_PassiveMenu(client);
			return Plugin_Handled;
		}
		if( g_iUserData[client][i_LastAgression]+60 >= GetTime() ) {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Cmd_Passive_Aggress", client);
			g_hTIMER[client] = INVALID_HANDLE;
			return Plugin_Handled;
		}
		if( g_iUserData[client][i_LastDangerousShot]+60 >= GetTime() ) {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Cmd_Passive_Aggress", client);
			g_hTIMER[client] = INVALID_HANDLE;
			Draw_PassiveMenu(client);
			return Plugin_Handled;
		}
	}
	
	g_bUserData[client][b_GameModePassive] = value;
	CPrintToChat(client, "" ...MOD_TAG... " %T", value ? "Cmd_Passive_Enabled" : "Cmd_Passive_Disabled", client);
	
	g_hTIMER[client] = INVALID_HANDLE;
	return Plugin_Handled;
}