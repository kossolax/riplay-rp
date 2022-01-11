#if defined _roleplay_menu_item_included
#endinput
#endif
#define _roleplay_menu_item_included

#if !defined _roleplay_base_included || defined ROLEPLAY_SUB
	#define ROLEPLAY_SUB
	#include "../roleplay.sp"
#else
	#include "roleplay.sp"
#endif

public int eventItemMenu(Handle p_hItemMenu, MenuAction p_oAction, int p_iParam1, int p_iParam2) {
	if (p_oAction == MenuAction_Select) {
		
		if( GetConVarInt(g_hAllowItem) == 0 ) {
			CPrintToChat(p_iParam1, "" ...MOD_TAG... " %T", "Error_Command_ForNow", p_iParam1);
			return;
		}
		
		if( IsValidClient(p_iParam1) && IsPlayerAlive(p_iParam1) && IsClientInJail(p_iParam1) && g_iUserData[p_iParam1][i_JailTime] > 0 ) {
			CPrintToChat(p_iParam1, "" ...MOD_TAG... " %T", "Error_CannotUseItemHere", p_iParam1);
			return;
		}
		
		int bit = StringToInt(g_szZoneList[GetPlayerZone(p_iParam1)][zone_type_bit]);
		
		if(	bit & BITZONE_JUSTICEITEM	) {
			if( !IsPolice(p_iParam1) && !IsJuge(p_iParam1) ) {
				CPrintToChat(p_iParam1, "" ...MOD_TAG... " %T", "Error_CannotUseItemHere", p_iParam1);
				return;
			}
		}
		
		if( bit & BITZONE_BLOCKITEM	) {
			if( GetConVarInt(g_hAllowItem) == 2 ) {
				if( !(bit & (BITZONE_EVENT|BITZONE_LACOURS)) ) {
					CPrintToChat(p_iParam1, "" ...MOD_TAG... " %T", "Error_CannotUseItemHere", p_iParam1);
					return;
				}
			}
			else {
				CPrintToChat(p_iParam1, "" ...MOD_TAG... " %T", "Error_CannotUseItemHere", p_iParam1);
				return;
			}
		}
		
		for(int i=1; i<=MaxClients; i++) {
			if( !IsValidClient(i) ) 
				continue;
			if( !IsValidClient(g_iGrabbing[i]) )
				continue;
			
			if( g_iGrabbing[i] == p_iParam1 ) {
				CPrintToChat(p_iParam1, "" ...MOD_TAG... " %T", "Error_Command_ForNow", p_iParam1);
				return;
			}
		}
		
		char szMenuItem[32];
		
		if (GetMenuItem(p_hItemMenu, p_iParam2, szMenuItem, sizeof(szMenuItem))) {
			
			char data[2][32];
			ExplodeString(szMenuItem, "_", data, sizeof(data), sizeof(data[]));
			
			int id = StringToInt(data[0]);
			
			if( g_bIsInCaptureMode && g_iServerRules[rules_ItemsDisabled][rules_Enabled] == 1 && g_iServerRules[rules_ItemsDisabled][rules_Target] == id && GetZoneBit(GetPlayerZone(p_iParam1)) & BITZONE_PVP && GetZoneBit(GetPlayerZone(p_iParam1)) == 200) {
				CPrintToChat(p_iParam1, "" ...MOD_TAG... " %T", "Error_CannotUseItemInPvP", p_iParam1);
				return;
			}
			
			if( g_flUserData[p_iParam1][fl_CoolDown] > GetGameTime() ) {
				CPrintToChat(p_iParam1, "" ...MOD_TAG... " %T", "Error_ItemCooldown", p_iParam1, (g_flUserData[p_iParam1][fl_CoolDown]-GetGameTime())+0.05 );
				OpenItemMenu( p_iParam1);
				return;
			}
			
			if( StringToInt(g_szItemList[id][item_type_dead]) == 0 && !IsPlayerAlive(p_iParam1) ) {
				OpenItemMenu( p_iParam1);
				return;
			}
			
			if( ! Client_CanUseItem(p_iParam1, id) ) {
				CPrintToChat(p_iParam1, "" ...MOD_TAG... " %T", "Error_CannotUseItemNow", p_iParam1);
				return;
			}
			
			
			if( rp_GetClientItem(p_iParam1, id) <= 0 ) {
				OpenItemMenu( p_iParam1);
				return;
			}
			
			
				
			int heal = GetClientHealth(p_iParam1) + StringToInt( g_szItemList[ id ][item_type_give_hp] );
			if( heal > 500 ) {
				heal = 500;
			}
			
			bool used = false;
			
			if( StringToInt( g_szItemList[ id ][item_type_give_hp] ) != 0 && heal > GetClientHealth(p_iParam1) ) {
				SetEntityHealth(p_iParam1, heal);
				used = true;
			}
			
			if( !StrEqual(g_szItemList[ id ][item_type_extra_cmd], "none", false) ) {
				LogToGame("[DEBUG] [ITEM] %s %d %d", g_szItemList[ id ][item_type_extra_cmd], p_iParam1, id);
				ServerCommand("%s %i %i", g_szItemList[ id ][item_type_extra_cmd], p_iParam1, id);
				used = true;
			}
			
			if( !used ) {
				OpenItemMenu( p_iParam1);
				return;
			}
			
			g_flUserData[p_iParam1][fl_CoolDown] = ( GetGameTime() + StringToFloat(g_szItemList[id][item_type_reuse_delay]) );
			g_iUserStat[p_iParam1][i_ItemUsed]++;
			g_iUserStat[p_iParam1][i_ItemUsedPrice] += StringToInt(g_szItemList[id][item_type_prix]);
			rp_ClientGiveItem(p_iParam1, id, -1);
			CPrintToChat(p_iParam1, "" ...MOD_TAG... " %T", "Cmd_Item", p_iParam1, g_szItemList[id][item_type_name] );
			
			LogToGame("[TSX-RP] [ITEM] %L a utilisé: %s", p_iParam1, g_szItemList[id][item_type_name] );
			
			if( g_bUserData[p_iParam1][b_Invisible] ) {
				CopSetVisible(p_iParam1);
			}
			
			OpenItemMenu( p_iParam1, true);
			CreateTimer(0.01, TASK_OpenItemMenu, p_iParam1);
		}
	}
	else if (p_oAction == MenuAction_End) {
		CloseHandle(p_hItemMenu);
	}
}
public Action TASK_OpenItemMenu(Handle timer, any client) {
	OpenItemMenu(client, true);
}

void OpenItemMenu(int client, bool no_message = false) {
	
	static char tmp[12], tmp2[255];
	int id, cpt, amount = g_iUserData[client][i_ItemCount];
	
	if( amount == 0 ) {
		if( !no_message )
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Cmd_Item_None", client);
		
		return;
	}
	
	// Setup menu
	Handle hItemMenu = CreateMenu(eventItemMenu);
	SetMenuTitle(hItemMenu, "%T\n ", "Cmd_Item_Choose", client);
	
	for (int i = 0; i < amount; i++) {
		id = g_iItems[client][i][STACK_item_id];
		cpt = g_iItems[client][i][STACK_item_amount];
		
		Format( tmp, sizeof(tmp), "%d", id);
		Format( tmp2, sizeof(tmp2), "%s [%d]", g_szItemList[id][item_type_name], cpt);
		
		AddMenuItem(hItemMenu, tmp, tmp2);
	}
		
	
	if( amount <= 8 )
		SetMenuPagination(hItemMenu, false); 
	
	SetMenuExitButton(hItemMenu, true);
	DisplayMenu(hItemMenu, client, MENU_TIME_FOREVER);
}
