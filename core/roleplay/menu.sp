#if defined _roleplay_menu_included
#endinput
#endif
#define _roleplay_menu_included

#if !defined _roleplay_base_included || defined ROLEPLAY_SUB
	#define ROLEPLAY_SUB
	#include "../roleplay.sp"
#endif

#include <roleplay/menu.bank.sp>
#include <roleplay/menu.boss.sp>
#include <roleplay/menu.item.sp>
#include <roleplay/menu.note.sp>
#include <roleplay/menu.passive.sp>
#include <roleplay/menu.police.sp>
#include <roleplay/menu.phone.sp>
#include <roleplay/menu.sell.sp>
#include <roleplay/menu.weapon.sp>

public int eventTombSwitch(Handle p_hItemMenu, MenuAction p_oAction, int client, int p_iParam2) {
	if (p_oAction == MenuAction_Select) {
		
		char szMenuItem[64];
		if( GetMenuItem(p_hItemMenu, p_iParam2, szMenuItem, sizeof(szMenuItem)) ) {
			
			if( StrEqual(szMenuItem, "any") )
				g_bUserData[client][b_SpawnToGrave] = false;
			else
				g_bUserData[client][b_SpawnToGrave] = true;
		}		
	}
	else if (p_oAction == MenuAction_End) {
		CloseHandle(p_hItemMenu);
	}
}
public int eventSetSkin(Handle p_hItemMenu, MenuAction p_oAction, int client, int p_iParam2) {
	if (p_oAction == MenuAction_Select) {
		
		char szMenuItem[64];
		if( GetMenuItem(p_hItemMenu, p_iParam2, szMenuItem, sizeof(szMenuItem)) ) {
			
			ServerCommand("sm_effect_setmodel \"%i\" \"%s\"", client, szMenuItem);
		}		
	}
	else if (p_oAction == MenuAction_End) {
		CloseHandle(p_hItemMenu);
	}
}
public Action AlloMoving(Handle timer, any ent) {
	rp_AcceptEntityInput(ent, "EnableMotion");
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
public Action PostKillHandle(Handle timer, any data) {
	if( data != INVALID_HANDLE )
		CloseHandle(data);
}