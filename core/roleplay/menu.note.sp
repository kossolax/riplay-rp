#if defined _roleplay_menu_note_included
#endinput
#endif
#define _roleplay_menu_note_included

#if !defined _roleplay_base_included || defined ROLEPLAY_SUB
	#define ROLEPLAY_SUB
	#include "../roleplay.sp"
#else
	#include "roleplay.sp"
#endif

public int menuShowNote_Client(Handle owner, Handle req, const char[] error, any client) {
	
	if( IsPolice(client) && StrEqual(g_szZoneList[GetPlayerZone(client)][zone_type_type], "41") ) {
		return;
	}
	// Setup menu
	Handle menu = CreateMenu(MenuSelectNote);
	SetMenuTitle(menu, "%T\n ", "Cmd_Note", client);
	
	char tmp1[256], tmp2[256];
	while( SQL_FetchRow(req) ) {
		
		SQL_FetchString(req, 0, tmp1, sizeof(tmp1));

		if( SQL_GetFieldCount(req) == 2 ) {
			SQL_FetchString(req, 1, tmp2, sizeof(tmp2));
			Format(tmp1, sizeof(tmp1), "%T", "Cmd_Note_time", client, tmp1, tmp2);
		}
		AddMenuItem(menu, tmp1, tmp1, ITEMDRAW_DISABLED);
	}
	
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_DURATION);
}
public int menuDeleteNote_Client(Handle owner, Handle req, const char[] error, any client) {
	// Setup menu
	Handle menu = CreateMenu(MenuSelectNote);
	SetMenuTitle(menu, "%T\n ", "Cmd_Note_remove", client);
	
	char tmp[256];
	char tmp2[256];
	while( SQL_FetchRow(req) ) {
		
		int id = SQL_FetchInt(req, 0);
		SQL_FetchString(req, 1, tmp, 255);
		
		Format(tmp2, 255, "%i", id);
		
		AddMenuItem(menu, tmp2, tmp);
	}
	
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_DURATION);	
}


public int MenuSelectNote(Handle p_hHireMenu, MenuAction p_oAction, int p_iParam1, int p_iParam2) {
	if (p_oAction == MenuAction_Select) {
		char szMenuItem[32];
		
		if (GetMenuItem(p_hHireMenu, p_iParam2, szMenuItem, sizeof(szMenuItem))) {
			
			
			char query[1024];
			Format(query, 1023, "DELETE FROM `rp_notes` WHERE `id`='%s';", szMenuItem);
			SQL_TQuery(g_hBDD, SQL_QueryCallBack, query);
		}
	}
	else if (p_oAction == MenuAction_End) {
		CloseHandle(p_hHireMenu);
	}
}