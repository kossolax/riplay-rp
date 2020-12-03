#if defined _roleplay_menu_phone_included
#endinput
#endif
#define _roleplay_menu_phone_included

#if !defined _roleplay_base_included || defined ROLEPLAY_SUB
	#define ROLEPLAY_SUB
	#include "../roleplay.sp"
#else
	#include "roleplay.sp"
#endif

void Menu_DisplayPhone(int Client) {
	
	if( !IsTutorialOver(Client) )
		return;

	char tmp[128];
	float f_ClientOrigin[3];
	GetClientAbsOrigin(Client, f_ClientOrigin);
	
	Menu menu = new Menu(Menu_DisplayPhone_Handler);
	menu.SetTitle("%T\n ", "Menu_DisplayPhone", Client);
	
	Format(tmp, sizeof(tmp), "%T", "Menu_DisplayPhone_pickup", Client);		menu.AddItem("pickup", tmp, g_flPhoneStart >= GetTickedTime() && GetVectorDistance(f_ClientOrigin, g_flPhonePosit) <= 50.0 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	Format(tmp, sizeof(tmp), "%T", "Menu_DisplayPhone_quest", Client);		menu.AddItem("quest", tmp, g_bUserData[Client][b_HasQuest] ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	Format(tmp, sizeof(tmp), "%T", "Menu_DisplayPhone_mail", Client);		menu.AddItem("mail", tmp);
	Format(tmp, sizeof(tmp), "%T", "Menu_DisplayPhone_call", Client);		menu.AddItem("call", tmp);
	Format(tmp, sizeof(tmp), "%T", "Menu_DisplayPhone_report", Client);		menu.AddItem("report", tmp);
	
	menu.Display(Client, MENU_TIME_FOREVER);
}

public int Menu_DisplayPhone_Handler(Handle p_hItemMenu, MenuAction p_oAction, int Client, int param) {
	if (p_oAction == MenuAction_Select) {
		
		char szMenuItem[64];
		GetMenuItem(p_hItemMenu, param, szMenuItem, sizeof(szMenuItem));
		
		if( StrEqual(szMenuItem, "pickup") ) {
			float f_ClientOrigin[3];
			GetClientAbsOrigin(Client, f_ClientOrigin);
			if( g_flPhoneStart >= GetTickedTime() && IsTutorialOver(Client) && GetVectorDistance(f_ClientOrigin, g_flPhonePosit) <= 50.0 ) {
				DisplayPhoneMenu(Client);
			}
		}
		if( StrEqual(szMenuItem, "quest") ) {
			Cmd_QuestMenu(Client);
		}
		if( StrEqual(szMenuItem, "mail") ) {			
			RP_ShowMOTD(Client, MOD_URL ... "index.php#/tribunal/mine");
		}
		if( StrEqual(szMenuItem, "call") ) {
			FakeClientCommand(Client, "say /job");
		}
		if( StrEqual(szMenuItem, "report") ) {
			FakeClientCommand(Client, "say /report");
		}		
	}
	else if (p_oAction == MenuAction_End) {
		CloseHandle(p_hItemMenu);
	}
}
