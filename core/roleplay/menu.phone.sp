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
	
	float f_ClientOrigin[3];
	GetClientAbsOrigin(Client, f_ClientOrigin);
	
	Menu menu = new Menu(Menu_DisplayPhone_Handler);
	menu.SetTitle("Cabine téléphonique\n ");
	
	menu.AddItem("pickup", "Décrocher le téléphone", g_flPhoneStart >= GetTickedTime() && GetVectorDistance(f_ClientOrigin, g_flPhonePosit) <= 50.0 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	menu.AddItem("quest", "Prendre une quête", g_bUserData[Client][b_HasQuest] ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	menu.AddItem("mail", "Lire mes emails");
	menu.AddItem("call", "Appeler un joueur");
	menu.AddItem("report", "Rapporter un mauvais comportement");
	
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
			QueryClientConVar(Client, "cl_disablehtmlmotd", view_as<ConVarQueryFinished>(ClientConVar), Client);
			
			char url[1024], sso[128];
			SSO_Forum(Client, sso, sizeof(sso));
			
			Format(url, sizeof(url), "https://www.ts-x.eu/index.php?page=phone%s", sso);
			RP_ShowMOTD(Client, url);
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
