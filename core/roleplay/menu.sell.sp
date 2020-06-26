#if defined _roleplay_menu_sell_included
#endinput
#endif
#define _roleplay_menu_sell_included

#if !defined _roleplay_base_included || defined ROLEPLAY_SUB
	#define ROLEPLAY_SUB
	#include "../roleplay.sp"
#else
	#include "roleplay.sp"
#endif

void DrawVendreMenu(int client) {
	
	int jobID = rp_GetClientJobID(client);
	
	if( jobID == 0 || jobID == 1 || jobID == 101 || jobID == 181 ) {
		CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous ne pouvez rien vendre.");
		return;
	}
	
	if( g_iUserData[client][i_SearchLVL] >= 4 ) {
		CPrintToChat(client, "{lightblue}[TSX-RP]{default} Le Tribunal de princeton a gelé vos ventes car vous êtes recherché depuis trop longtemps.");
		return;
	}
	
	int target = rp_GetClientTarget(client);
	if( (jobID == 51 || jobID == 61) && IsValidDoor(target) ) {
		
		int door = target;
		int door_bdd = (door-MaxClients);
		
		int can = -1;
		
		for(int a=0; a<MAX_KEYSELL; a++) {
			if( can != -1 )
				break;
			
			char ParentList[11][12];
			ExplodeString(g_szSellingKeys[a][key_type_parent], "-", ParentList, 10, 12);
			
			
			for(int b=0; b<=10; b++) {
				
				if( StringToInt(ParentList[b]) <= 0 )
					continue;
				
				if( StringToInt(ParentList[b]) == door_bdd && StringToInt(g_szSellingKeys[a][key_type_job_id]) == GetJobPrimaryID(client) ) {
					can = a;
					break;
				}
			}
		}
		
		if( can == -1 ) {
			CPrintToChat(client, "{lightblue}[TSX-RP]{default} Cette porte n'est pas une porte d'un appartement.");
			return;
		}
		
		for(int i=1; i<=MaxClients; i++) {
			if( !IsValidClient(i) )
				continue;
			
			if( g_iDoorOwner_v2[i][can] ) {
				CPrintToChat(client, "{lightblue}[TSX-RP]{default} %N est déjà proprietaire de cet appartement.", i);
				return;
			}
		}
		
		int item_id = -1;
		
		switch( StringToInt(g_szSellingKeys[can][key_type_prix]) ) {
			case 300: item_id = 130;
			case 450: item_id = 131;
			case 600: item_id = 72;
			case 500: item_id = 37;
			case 750: item_id = 226;
			case 50000: item_id = 225;
		}
		
		if( item_id == -1 ) {
			CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous ne pouvez pas louer cet appartement.");
			return;
		}
		
		int playercount = 0;
		char title[256];

		Handle menu = CreateMenu(eventGiveMenu_2Bis); // _2

		Format(title, sizeof(title), "Sélectionner a qui louer cet appartement\n");

		if(g_bIsBlackFriday) {
			Format(title, sizeof(title), "%sBLACKFRIDAY: -%iPCT de réduction \n", title, g_iBlackFriday[1]);
			ReplaceString(title, sizeof(title), "PCT", "%%", true);
		}

		SetMenuTitle(menu, title);

		char name[128];
		for(int i = 1; i <= MaxClients; i++) {
			if( !IsValidClient(i) )
				continue;
			if( !IsClientConnected(i) )
				continue;
			if( !(Entity_GetDistance(client, i) < MAX_AREA_DIST.0) )
				continue;
			if(client == i) 
				continue;
			
			GetClientName2(i, name, 127);
			char tmp[64];
			Format(tmp, 64, "%i_1_0_%i_%i", item_id, can, i);
			AddMenuItem(menu, tmp, name);

			playercount++;	
		}
		
		if(playercount > 0) {
			SetMenuExitButton(menu, true);
			DisplayMenu(menu, client, MENU_TIME_DURATION);
		} else {
			CPrintToChat(client, "{lightblue}[TSX-RP]{default} Il n'y a pas de joueurs éligibles à l'achat de cet appartement.");
		}
	}
	else {
		char tmp[255];
		char tmp2[255];
		char title[256];

		// Setup menu
		Handle hGiveMenu = CreateMenu(eventGiveMenu_1);

		Format(title, sizeof(title), "Sélectionner un objet à vendre\n");

		if(g_bIsBlackFriday) {
			Format(title, sizeof(title), "%sBLACKFRIDAY: -%iPCT de réduction \n", title, g_iBlackFriday[1]);
			ReplaceString(title, sizeof(title), "PCT", "%%", true);
		}

		SetMenuTitle(hGiveMenu, title);
		
		char szJobID[12];
		Format(szJobID, sizeof(szJobID), "%d", jobID);
		
		for(int i = 0; i < MAX_ITEMS; i++) {
			
			if( strlen( g_szItemListOrdered[i][item_type_name] ) == 0 )
				continue;
			if( StringToInt( g_szItemListOrdered[i][item_type_prix] ) == 0 )
				continue;
				
			if( !StrEqual(g_szItemListOrdered[i][item_type_job_id], szJobID) && StringToInt( g_szItemListOrdered[i][item_type_job_id] ) != g_iUserData[client][i_Job] ) 
				continue;
			
			// Chirurgie
			if( g_iUserData[client][i_Job] == 13) {
				if( StrContains(g_szItemListOrdered[i][item_type_extra_cmd], "rp_chirurgie full", false) == 0 )
					continue;
			}
			if( g_iUserData[client][i_Job] == 15 || g_iUserData[client][i_Job] == 16 ) {
				if( StrContains(g_szItemListOrdered[i][item_type_extra_cmd], "rp_chirurgie", false) == 0 )
					continue;
			}
			// Armu & pvp
			if( g_iUserData[client][i_Job] == 114 || g_iUserData[client][i_Job] == 115 || g_iUserData[client][i_Job] == 116  ) {
				if( StrContains(g_szItemListOrdered[i][item_type_extra_cmd], "rp_giveitem_pvp", false) == 0 )
					continue;
			}
			// Tueur & PvP
			if( g_iUserData[client][i_Job] == 46 || g_iUserData[client][i_Job] == 45 || g_iUserData[client][i_Job] == 44 ) {
				if( StrContains(g_szItemListOrdered[i][item_type_extra_cmd], "rp_giveitem_pvp", false) == 0 )
					continue;
			}
			// Technicien & Photocopieuse
			if( g_iUserData[client][i_Job] == 226 || g_iUserData[client][i_Job] == 225 || g_iUserData[client][i_Job] == 224 ) {
				if( StrContains(g_szItemListOrdered[i][item_type_extra_cmd], "rp_item_cashbig", false) == 0 )
					continue;
			}
			// Immo & props
			if( IsAppartVendeur(client) ) {
				if( StrContains(g_szZoneList[GetPlayerZone(client)][zone_type_type], "appart_") == 0 ) {
					if( StrContains(g_szItemListOrdered[i][item_type_extra_cmd], "rp_item_appart", false) != 0 )
						continue;
				}
				else if( StrContains(g_szItemListOrdered[i][item_type_extra_cmd], "rp_item_appart", false) == 0 )
					continue;
			}
			
			Format( tmp, 254, "%s_%i", g_szItemListOrdered[i][item_type_ordered_id], 0);
			Format(tmp2, 254, "%s [%s$]", g_szItemListOrdered[i][item_type_name], g_szItemListOrdered[i][item_type_prix]);
			
			AddMenuItem(hGiveMenu, tmp, tmp2);
		}
		
		SetMenuExitButton(hGiveMenu, true);
		DisplayMenu(hGiveMenu, client, MENU_TIME_DURATION);
	}
	
	return;
}


public int eventGiveMenu_1(Handle p_hItemMenu, MenuAction p_oAction, int client, int p_iParam2) {
	if (p_oAction == MenuAction_Select) {
		
		char szMenuItem[32];
		
		if (GetMenuItem(p_hItemMenu, p_iParam2, szMenuItem, sizeof(szMenuItem))) {
			
			char data[2][32];
			ExplodeString(szMenuItem, "_", data, sizeof(data), sizeof(data[]));
			
			int i = StringToInt(data[0]);
			int type = StringToInt(data[1]);
			
			if( StrContains(g_szItemList[i][item_type_extra_cmd], "rp_chirurgie", false) == 0 ) {
				if( g_iUserData[client][i_Job] == 11 || g_iUserData[client][i_Job] == 12  || g_iUserData[client][i_Job] == 13 || g_iUserData[client][i_Job] == 14 ) {
					int target = rp_GetClientTarget(client);
					
					if( !IsValidClient(target) || StringToInt(g_szZoneList[GetPlayerZone(target)][zone_type_type]) != 14 ) {
						CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous devez viser un joueur sur la table d'operation.");
						return;
					}
					if( StringToInt(g_szZoneList[GetPlayerZone(client)][zone_type_type]) != 14 ) {
						CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous devez être sur la table d'operation.");
						return;
					}

					if(g_iUserData[client][i_Job] == 13 && g_flUserData[target][fl_TazerTime] > GetGameTime()) {
						CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous ne pouvez pas bénéficier de plusieurs chirurgies en même temps, merci de patienter.");
						CPrintToChat(target, "{lightblue}[TSX-RP]{default} %N ne peux pas bénéficier de plusieurs chirurgies en même temps, merci de patienter.", target);
						
						return;
					}
				}
				else {
					CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous n'êtes pas chirurgien..");
					return;
				}
			}
			
			if( StringToInt(g_szItemList[i][item_type_auto]) == 1 && type == 0) {
				// Setup menu
				Handle hGiveMenu;

				/* utile ? franchement à voir */
				if( StrContains(g_szItemList[i][item_type_extra_cmd], "rp_item_contrat") == 0 ) {
					hGiveMenu = CreateMenu(eventGiveMenu_2Ter);
				} else {
					hGiveMenu = CreateMenu(eventGiveMenu_2Bis);
				}
				
				SetMenuTitle(hGiveMenu, "Etes vous sur de vouloir vendre %s?\n ", g_szItemList[i][item_type_name]);
				
				char tmp[64];
				Format( tmp, 63, "%i_1_%i_0_0", i, type);
				
				AddMenuItem(hGiveMenu, tmp, "Je confirme");
				
				SetMenuPagination(hGiveMenu, MENU_NO_PAGINATION);
				SetMenuExitButton(hGiveMenu, true);
				DisplayMenu(hGiveMenu, client, MENU_TIME_DURATION);
			}
			else {
				// Setup menu
				Handle hGiveMenu;
				
				/* utile ? franchement à voir */
				if( StrContains(g_szItemList[i][item_type_extra_cmd], "rp_item_contrat") == 0 ) {
					hGiveMenu = CreateMenu(eventGiveMenu_2Ter);
				} else {
					hGiveMenu = CreateMenu(eventGiveMenu_2Bis);
				}
				
				SetMenuTitle(hGiveMenu, "Sélectionner combien en vendre\n ");
				
				AddItemForVending(hGiveMenu, i, type, 1, client);		// 1
				AddItemForVending(hGiveMenu, i, type, 2, client);		// 2
				AddItemForVending(hGiveMenu, i, type, 5, client);		// 3
				AddItemForVending(hGiveMenu, i, type, 10, client);		// 4
				AddItemForVending(hGiveMenu, i, type, 25, client);		// 5
				AddItemForVending(hGiveMenu, i, type, 50, client);		// 6
				AddItemForVending(hGiveMenu, i, type, 75, client);		// 7
				AddItemForVending(hGiveMenu, i, type, 100, client);		// 8
				
				
				SetMenuPagination(hGiveMenu, MENU_NO_PAGINATION);
				SetMenuExitButton(hGiveMenu, true);
				DisplayMenu(hGiveMenu, client, MENU_TIME_DURATION);
			}
		}
	}
	else if (p_oAction == MenuAction_End) {
		CloseHandle(p_hItemMenu);
	}
}
public void AddItemForVending(Handle hGiveMenu, int item_id, int type, int amount, int client) {
	
	char tmp[64], tmp2[64];
	Format( tmp, 63, "%i_%i_%i_0_0", item_id, amount, type);
	Format(tmp2, 63, "%s - %i [%i$]", g_szItemList[item_id][item_type_name], amount, (StringToInt(g_szItemList[item_id][item_type_prix])*amount) );
	
	AddMenuItem(hGiveMenu, tmp, tmp2);
}
/*public int eventGiveMenu_2(Handle p_hItemMenu, MenuAction p_oAction, int p_iParam1, int p_iParam2) {
	static const reduction[] = { 5, 10, 20, 30, 40, 50 };
	
	if (p_oAction == MenuAction_Select) {
		char szMenuItem[32];
		int client = p_iParam1;
		
		if (GetMenuItem(p_hItemMenu, p_iParam2, szMenuItem, sizeof(szMenuItem))) {
			
			char data[5][32];
			ExplodeString(szMenuItem, "_", data, sizeof(data), sizeof(data[]));
			
			char tmp[255], tmp2[255];
			Handle hGiveMenu;			
			
			if( StrContains(g_szItemList[StringToInt(data[0])][item_type_extra_cmd], "rp_item_contrat") == 0 ) {
				hGiveMenu = CreateMenu(eventGiveMenu_2Ter); // CONTRAT
			}
			else {
				hGiveMenu = CreateMenu(eventGiveMenu_2Bis);
			}
		
			SetMenuTitle(hGiveMenu, "Sélectionner la réduction\n ");
			
			Format(tmp, sizeof(tmp), "%s_%s_%s_%s_%s_%d", data[0], data[1], data[2], data[3], data[4], 0);
			Format(tmp2, sizeof(tmp2), "Pas de réduction");
			AddMenuItem(hGiveMenu, tmp, tmp2);
			
			
			if( g_bUserData[client][b_LicenseSell] || GetConVarInt(g_hAllowSteal)==0 ) {
				int rank = sizeof(reduction);
				rank -= g_iUserData[client][i_Job] - GetJobPrimaryID(client);
				// 
				for(int i=0; i<=rank; i++) {
					
					if( i >= sizeof(reduction) )
						continue;
					if( float(reduction[i]) > StringToFloat(g_szItemList[StringToInt(data[0])][item_type_taxes])*100.0 )
						continue;
					
					Format(tmp, sizeof(tmp), "%s_%s_%s_%s_%s_%d", data[0], data[1], data[2], data[3], data[4], reduction[i]);
					Format(tmp2, sizeof(tmp2), "%d %% de réduction", reduction[i]);
					
					AddMenuItem(hGiveMenu, tmp, tmp2);
				}
			}
			
			SetMenuExitBackButton(hGiveMenu, false);
			DisplayMenu(hGiveMenu, client, MENU_TIME_DURATION/4);
		}
	}
	else if (p_oAction == MenuAction_End) {
		CloseHandle(p_hItemMenu);
	}
}*/
public int eventGiveMenu_2Ter(Handle p_hItemMenu, MenuAction p_oAction, int client, int p_iParam2) {
	if (p_oAction == MenuAction_Select) {
		char szMenuItem[32];
		
		if (GetMenuItem(p_hItemMenu, p_iParam2, szMenuItem, sizeof(szMenuItem))) {
			int target = rp_GetClientTarget(client);
			if( !IsValidClient(target) ) {
				CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous devez viser un joueur.");
				return;
			}
			if( g_iBlockedTime[target][client] != 0 ) {
				if( (g_iBlockedTime[target][client]+(6*60)) >= GetTime() ) {
					CPrintToChat(client, "{lightblue}[TSX-RP]{default} Ce client ne vous répondra pas.");
					return;
				}
			}
			if( client != target && (IsAtBankPoint(client) || IsAtBankPoint(target)) ) {
				CPrintToChat(client, "{lightblue}[TSX-RP]{default} Ce joueur est trop proche d'un distributeur pour effectuer une transaction.");
				return;
			}
			
			if( g_iUserData[target][i_SearchLVL] >= 4 ) {
				CPrintToChat(client, "{lightblue}[TSX-RP]{default} Le Tribunal de princeton a gelé vos achats car vous êtes recherché depuis trop longtemps.");
				return;
			}
			
			if( (GetZoneBit(GetPlayerZone(client))  & BITZONE_BLOCKSELL) ||
				(StringToInt(g_szZoneList[ GetPlayerZone(target) ][zone_type_bit]) & BITZONE_BLOCKSELL)
				) {
				CPrintToChat(client, "{lightblue}[TSX-RP]{default} Il n'est pas possible de vendre dans cette zone.");
				return;
			}
			
			if( GetClientMenu(target) != MenuSource_None && GetClientMenu(target) != MenuSource_RawPanel ) {
				CPrintToChat(client, "{lightblue}[TSX-RP]{default} Ce joueur semble occupé.");
				return;
			}
			if( !IsTutorialOver(target) ) {
				CPrintToChat(client, "{lightblue}[TSX-RP]{default} %N n'a pas terminé le tutorial.", target);
				return;
			}
			
			char data[6][32];
			ExplodeString(szMenuItem, "_", data, sizeof(data), sizeof(data[]));
			char buffer[32], tmp[128], name[128];
			strcopy(buffer, sizeof(buffer), g_szItemList[StringToInt(data[0])][item_type_extra_cmd]);
			ReplaceString(buffer, sizeof(buffer), "rp_item_contrat ", "");
			
			int count = 0;
			int type = 0;
			if( StrContains(buffer, "classic") == 0 ) {
				type = 1001;
			}
			else if( StrContains(buffer, "police") == 0 ) {
				type = 1002;
			}
			else if( StrContains(buffer, "pvp") == 0 ) {
				type = 1003;
			}
			else if( StrContains(buffer, "justice") == 0 ) {
				type = 1004;
			}
			else if( StrContains(buffer, "kidnapping") == 0 ) {
				if( g_bEvent_Kidnapping == true ) {
					CPrintToChat(client, "{lightblue}[TSX-RP]{default} Impossible d'effectuer un autre kidnapping avant 6h, midi, 18h ou minuit.");
					return;
				}
				if( g_iUserData[target][i_PlayerLVL] < 306 ) {
					CPrintToChat(client, "{lightblue}[TSX-RP]{default} %N doit être au moins de niveau 306 \"Haut conseillé\", afin d'effectuer un contrat kidnapping.");
					return;
				}
				type = 1005;
			}
			else if( StrContains(buffer, "lupin") == 0 ) {
				type = 1006;
			}
			else if( StrContains(buffer, "freekill") == 0 ) {
				type = 1007;
			}
			else {
				CPrintToChat(client, "{lightblue}[TSX-RP]{default} ERR. Type de contrat inconnu.");
				return;
			}
			
			Handle hGiveMenu = CreateMenu(eventGiveMenu_2Bis);
			Format(tmp, sizeof(tmp), "%N vous propose un %s\nQui souhaitez-vous assassiner ?\n ", client, g_szItemList[StringToInt(data[0])][item_type_name]);
			SetMenuTitle(hGiveMenu, tmp);
			
			
			for(int i=1; i<=MaxClients; i++) {
				if( !IsValidClient(i) )
					continue;
				if( GetConVarInt(FindConVar("hostport")) == 27015 ) {
					if( i == target || i == client )
						continue;
				}
				if( !IsTutorialOver(i) )
					continue;
				
				if( type == 1001 && (IsPolice(i) || IsJuge(i))  )
					continue;
				if( type == 1002 && !IsPolice(i) && !IsJuge(i) )
					continue;
				if( type == 1003 && GetGroupPrimaryID(i) == 0 )
					continue;
				if( type == 1005 && g_iUserData[i][i_Bank] < 1 )
					continue;
				if( type == 1005 && rp_IsClientNew(i) )
					continue;
				if( type != 1004 && IsTueur(i) )
					continue;
				if( type == 1004 && !g_bUserData[i][b_IsSearchByTribunal] )
					continue;
				if( type == 1006 && g_iUserData[i][i_Bank] < 100000 )
					continue;
				if( type == 1006 && !g_bUserData[i][b_HaveCard] )
					continue;
				if( type == 1006 && rp_IsClientNew(i) )
					continue;
				if( type == 1007 && g_iUserData[i][i_KillJailDuration] < 30 )
					continue;
				
				if( type == 1005 && rp_ClientFloodTriggered(0, i, fd_kidnapping) ) {
					Format(name, sizeof(name), "%N - Trop de kidnapping", i);
					AddMenuItem(hGiveMenu, "_", name, ITEMDRAW_DISABLED);
					count++;
					continue;
				}
				
				if( g_iUserData[i][i_ContratTotal] >= 2 && type != 1004 ) {
					Format(name, sizeof(name), "%N - Trop de contrat", i);
					AddMenuItem(hGiveMenu, "_", name, ITEMDRAW_DISABLED);
					count++;
					continue;
				}
				if( IsClientInJail(i) && type != 1004 ) {
					Format(name, sizeof(name), "%N - En jail", i);
					AddMenuItem(hGiveMenu, "_", name, ITEMDRAW_DISABLED);
					count++;
					continue;
				}
				if( g_bUserData[i][b_IsAFK] && type != 1004  ) {
					Format(name, sizeof(name), "%N - AFK", i);
					AddMenuItem(hGiveMenu, "_", name, ITEMDRAW_DISABLED);
					count++;
					continue;
				}
				
				if( GetGroupPrimaryID(i) > 0 && g_bIsInCaptureMode ) {
					Format(name, sizeof(name), "%N - Capture en cours", i);
					AddMenuItem(hGiveMenu, "_", name, ITEMDRAW_DISABLED);
					count++;
					continue;
				}
				
				count++;
				Format(name, sizeof(name), "%N", i);
				Format(tmp, sizeof(tmp), "%s_%s_%s_%d_%d_%s", data[0], data[1], data[2], i, client+1000, data[5]);
				AddMenuItem(hGiveMenu, tmp, name);
			}
			
			SetMenuExitButton(hGiveMenu, true);
			DisplayMenu(hGiveMenu, target, MENU_TIME_DURATION);
		}
	}
	else if (p_oAction == MenuAction_End) {
		CloseHandle(p_hItemMenu);
	}
}
public int eventGiveMenu_2Bis(Handle p_hItemMenu, MenuAction p_oAction, int p_iParam1, int p_iParam2) {
	if (p_oAction == MenuAction_Select) {
		char szMenuItem[32];
		int client = p_iParam1;
		
		if (GetMenuItem(p_hItemMenu, p_iParam2, szMenuItem, sizeof(szMenuItem))) {
			
			char data[6][32];
			ExplodeString(szMenuItem, "_", data, sizeof(data), sizeof(data[]));
			
			int id = StringToInt(data[0]);
			int amount = StringToInt(data[1]);
			int item_type = StringToInt(data[2]);
			int day = StringToInt(data[3]);
			int client_from_menu = StringToInt(data[4]);
			int reduction = StringToInt(data[5]);
			//int reduction = g_bIsBlackFriday ? g_iBlackFriday[1]:0;
			int target;
			
			if( IsValidClient(client_from_menu) ) {
				target = client_from_menu;
			}
			else if( IsValidClient(client_from_menu-1000) ) {
				target = client;
				client = client_from_menu - 1000;
			}
			else {
				target = rp_GetClientTarget(client);
			}
			
			if( !IsValidClient(target) ) {
				DrawVendreMenu(client);
				CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous devez viser un joueur.");
				return;
			}
			
			
			if( g_iBlockedTime[target][client] != 0 ) {
				if( (g_iBlockedTime[target][client]+(6*60)) >= GetTime() ) {
					CPrintToChat(client, "{lightblue}[TSX-RP]{default} Ce client ne vous répondra pas.");
					return;
				}
			}
			if( client != target && (IsAtBankPoint(client) || IsAtBankPoint(target)) ) {
				CPrintToChat(client, "{lightblue}[TSX-RP]{default} Ce joueur est trop proche d'un distributeur pour effectuer une transaction.");
				return;
			}
			
			if( (GetZoneBit(GetPlayerZone(client))  & BITZONE_BLOCKSELL) ||
				(StringToInt(g_szZoneList[ GetPlayerZone(target) ][zone_type_bit]) & BITZONE_BLOCKSELL)
				) {
				CPrintToChat(client, "{lightblue}[TSX-RP]{default} Il n'est pas possible de vendre dans cette zone.");
				return;
			}
			
			if( GetClientMenu(target) != MenuSource_None && GetClientMenu(target) != MenuSource_RawPanel ) {
				CPrintToChat(client, "{lightblue}[TSX-RP]{default} Ce joueur semble occupé.");
				return;
			}
			if( !IsTutorialOver(target) ) {
				CPrintToChat(client, "{lightblue}[TSX-RP]{default} %N n'a pas terminé le tutorial.", target);
				return;
			}
			
			
			
			int prix = StringToInt(g_szItemList[id][item_type_prix]) * amount;
			if( g_iServerRules[rules_ItemsPrice][rules_Enabled] == 1 ) {
				
				if( rp_GetClientJobID(target) == g_iServerRules[rules_ItemsPrice][rules_Target] || rp_GetClientGroupID(target) == (g_iServerRules[rules_ItemsPrice][rules_Target]-1000) ) {
					
					if( g_iServerRules[rules_ItemsPrice][rules_Arg] == 1 )
						prix = RoundFloat(float(prix) * 1.10);
					else
						prix = RoundFloat(float(prix) * 0.95);
				}
			}
			if( g_iServerRules[rules_reductions][rules_Enabled] == 1 ) {
				if( rp_GetClientJobID(target) == g_iServerRules[rules_reductions][rules_Target] || rp_GetClientGroupID(target) == (g_iServerRules[rules_reductions][rules_Target]-1000) ) {
					reduction = 0;
				}
			}

			/* add blackfriday */
			if(g_bIsBlackFriday) {
				prix = prix - ((prix * g_iBlackFriday[1]) / 100);
			}
			
			char tmp[512];
			
			if( StrContains(g_szItemList[id][item_type_extra_cmd], "rp_give_appart_door") == 0 ) {
				Format(tmp, sizeof(tmp), "%N vous propose d'acheter\n%i %s (n°%s) pour %i$\n", 
				client, amount, g_szItemList[id][item_type_name], g_szSellingKeys[day][key_type_name], prix );
			}
			if( StrContains(g_szItemList[id][item_type_extra_cmd], "rp_item_contrat") == 0 ) {
				Format(tmp, sizeof(tmp), "%N vous propose d'acheter\n%s contre %N pour %d$\n", 
				client, g_szItemList[id][item_type_name], day, prix);
			}
			else {
				Format(tmp, sizeof(tmp), "%N vous propose d'acheter\n%i %s pour %i$\n", 
				client, amount, g_szItemList[id][item_type_name], prix);
			}
			
			if( reduction > 0 ) {
				Format(tmp, sizeof(tmp), "%s Réduction de %dPCT !\n", tmp, reduction);
				ReplaceString(tmp, sizeof(tmp), "PCT", "%%", true);
			}

			if(g_bIsBlackFriday) {
				Format(tmp, sizeof(tmp), "%sBLACKFRIDAY: -%iPCT de réduction\n", tmp, g_iBlackFriday[1]);
				ReplaceString(tmp, sizeof(tmp), "PCT", "%%", true);
			}
			
			Format(tmp, sizeof(tmp), "%s\nConfirmez-vous l'achat?\n ", tmp);

			char szMoney[128], szBank[128];
			String_NumberFormat(g_iUserData[target][i_Money],	szMoney,sizeof(szMoney));
			String_NumberFormat(g_iUserData[target][i_Bank],	szBank,	sizeof(szBank));
			Format(tmp, sizeof(tmp), "%s\nArgent sur vous: %s$, en banque: %s$\n ", tmp, szMoney, szBank);
			
			// Setup menu
			Handle hGiveMenu = CreateMenu(eventGiveMenu_3);
			SetMenuTitle(hGiveMenu, tmp);
			
			
			Format(tmp, sizeof(tmp), "%i_%i_%i_%i_1_%i_%d", client, id, amount, item_type, day, reduction);
			
			AddMenuItem(hGiveMenu, tmp, "Je confirme l'achat");
			
			if( g_bUserData[target][b_HaveCard] == 1 ) {
				Format(tmp, sizeof(tmp), "%i_%i_%i_%i_5_%i_%d", client, id, amount, item_type, day, reduction);
				AddMenuItem(hGiveMenu, tmp, "Je souhaite payer via ma carte bancaire.");
			}
			else {
				Format(tmp, sizeof(tmp), "%i_%i_%i_%i_5_%i_%d", client, id, amount, item_type, day, reduction);
				AddMenuItem(hGiveMenu, tmp, "Je souhaite payer via ma carte bancaire.", ITEMDRAW_DISABLED);
			}
			
			if( target != client ) {
				Format(tmp, sizeof(tmp), "%i_%i_%i_%i_2_%i_%d", client, id, amount, item_type, day, reduction);
				AddMenuItem(hGiveMenu, tmp, "Je refuse l'achat");
				
				
				AddMenuItem(hGiveMenu, "vide", "-----------------", ITEMDRAW_DISABLED);
				
				Format(tmp, sizeof(tmp), "%i_-1_-1_%i_3_%i_%d", client, item_type, day, reduction);
				AddMenuItem(hGiveMenu, tmp, "Ignorer ce joueur");
			}
			SetMenuExitButton(hGiveMenu, true);
			DisplayMenu(hGiveMenu, target, MENU_TIME_DURATION/2);
			
		}
	}
	else if (p_oAction == MenuAction_End) {
		CloseHandle(p_hItemMenu);
	}
}
public int eventGiveMenu_3(Handle p_hItemMenu, MenuAction p_oAction, int p_iParam1, int p_iParam2) {
	if (p_oAction == MenuAction_Select) {
		char szMenuItem[32];
		int client = p_iParam1;
		
		if (GetMenuItem(p_hItemMenu, p_iParam2, szMenuItem, sizeof(szMenuItem))) {
			
			char data[7][32];
			ExplodeString(szMenuItem, "_", data, sizeof(data), sizeof(data[]));
			
			int vendeur = StringToInt(data[0]);
			int item_id = StringToInt(data[1]);
			int amount = StringToInt(data[2]);
			int item_type = StringToInt(data[3]);
			int type = StringToInt(data[4]);
			int day = StringToInt(data[5]);
			int reduction = StringToInt(data[6]);
			
			
			if( type == 3 ) {
				g_iBlockedTime[client][vendeur] = GetTime();
				CPrintToChat(vendeur, "{lightblue}[TSX-RP]{default} Le client a refusé l'achat et vous ignorera pour 6 heures.");
				CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous ignorerez les demandes d'achat de %N pour 6 heures.", vendeur);
				return;
			}
			if( type == 2 ) {
				CPrintToChat(vendeur, "{lightblue}[TSX-RP]{default} Le client a refusé l'achat.");
				return;
			}
			if( IsTueur(vendeur) && g_iUserData[vendeur][i_ToKill] != 0 && IsValidClient(g_iUserData[vendeur][i_ToKill]) && StrContains(g_szItemList[ item_id ][item_type_extra_cmd], "rp_item_contrat") == 0) {
				CPrintToChat(vendeur, "{lightblue}[TSX-RP]{default} Vous êtes déjà en contrat.");
				return;
			}
			
			int prix = (StringToInt(g_szItemList[item_id][item_type_prix])*amount);
			if( g_iServerRules[rules_ItemsPrice][rules_Enabled] == 1 ) {
				
				if( rp_GetClientJobID(client) == g_iServerRules[rules_ItemsPrice][rules_Target] || rp_GetClientGroupID(client) == (g_iServerRules[rules_ItemsPrice][rules_Target]-1000) ) {
					
					if( g_iServerRules[rules_ItemsPrice][rules_Arg] == 1 )
						prix = RoundFloat(float(prix) * 1.10);
					else
						prix = RoundFloat(float(prix) * 0.95);
				}
			}

			/* add blackfriday */
			if(g_bIsBlackFriday) {
				prix = prix - ((prix * g_iBlackFriday[1]) / 100);
			}

			if( item_type == 0 && StrContains(g_szItemList[item_id][item_type_extra_cmd], "rp_item_respawn") == 0 && IsPlayerAlive(client) ) {
				CPrintToChat(vendeur, "{lightblue}[TSX-RP]{default} Le joueur est en vie.");
				return;
			}
			bool hidden = false;
			
			if( client == vendeur ) {
				int jobList[65], mnt=0;
				int jobID = StringToInt(g_szItemList[item_id][item_type_job_id]);
				
				for(int i=1; i<=MaxClients; i++) {
					if( !IsValidClient(i) )
						continue;
					if( g_iUserData[i][i_Job] == 0 )
						continue;
					if( GetJobPrimaryID(i) != jobID)
						continue;
					if( i == client )
						continue;
					
					jobList[mnt] = i;
					mnt++;
				}
				if( mnt == 0 ) {
					vendeur = -1;
				}
				else {
					vendeur = jobList[ Math_GetRandomInt(0, mnt-1) ];
					hidden = true;
					
					if( rp_GetClientItem(client, ITEM_CHEQUE) <= 0 ) {
						CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous n'avez plus de chèque.");
						return;
					}
					
					rp_ClientGiveItem(client, ITEM_CHEQUE, -1);
				}
			}
			
			if( !IsValidClient(vendeur) ) {
				CPrintToChat(client, "{lightblue}[TSX-RP]{default} Votre vendeur s'est déconnecté.");
				return;
			}
			
			
			float prixItem = float(prix);
			float reduc = prixItem / 100.0 * float(reduction);
			
			if( type == 5 ) {
				if( g_iUserData[client][i_Bank] < RoundFloat(prixItem - reduc) ) {
					CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous n'avez pas assez d'argent.");
					CPrintToChat(vendeur, "{lightblue}[TSX-RP]{default} Le client n'a pas assez d'argent.");
					
					if( hidden ) {
						rp_GetClientItem(client, ITEM_CHEQUE);
					}
					
					return;
				}
			}
			else {
				if( g_iUserData[client][i_Money] < RoundFloat(prixItem - reduc) ) {
					CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous n'avez pas assez d'argent.");
					CPrintToChat(vendeur, "{lightblue}[TSX-RP]{default} Le client n'a pas assez d'argent.");
					
					if( hidden ) {
						rp_ClientGiveItem(client, ITEM_CHEQUE);
					}
					return;
				}
			}
			
			
			rp_ClientGiveItem(client, item_id, amount);
			
			float taxe = StringToFloat(g_szItemList[item_id][item_type_taxes]);
			
			g_iUserStat[vendeur][i_MoneyEarned_Sales] += RoundFloat(((prixItem * taxe) - reduc) * 1.0);
			g_iUserData[vendeur][i_Reduction] = reduction;
			g_iUserStat[client][i_MoneySpent_Shop] += RoundFloat(prixItem - reduc);
			
			rp_ClientMoney(client, type == 5 ? i_Bank : i_Money, -RoundFloat(prixItem - reduc));
			rp_ClientMoney(vendeur, i_Money, RoundToFloor(((prixItem * taxe) - reduc) * 0.5));
			rp_ClientMoney(vendeur, i_AddToPay, RoundToCeil(((prixItem * taxe) - reduc) * 0.5));

			// 0.1 = taxe pour les low capitals 

			int capital =  RoundToFloor(prixItem - ((prixItem * taxe) - reduc));
			int rest = RoundToFloor(capital * 0.1); // prend 10% du capital
			int addcapital = capital - rest; // prend le reste du capital

			/*int addcapital = RoundToCeil(prixItem*(1.0 - (taxe + 0.1))); 
			int rest = RoundToFloor(prixItem*(1.0 - (1.0 - 0.1)));*/

			RestToLowCapital(rest);
			// rest = pour calc les low capitals

			SetJobCapital(g_iUserData[vendeur][i_Job], (GetJobCapital(g_iUserData[vendeur][i_Job]) + addcapital));
			addToGroup(vendeur, RoundFloat(float(prix)/(2.0)));
			
			Call_StartForward( view_as<Handle>(g_hRPNative[vendeur][RP_OnPlayerSell]));
			Call_PushCell(vendeur);
			Call_PushCell(prix);
			Call_Finish();
			
			char SteamID[64], targetSteamID[64];
			GetClientAuthId(vendeur, AUTH_TYPE, SteamID, sizeof(SteamID), false);
			GetClientAuthId(client, AUTH_TYPE, targetSteamID, sizeof(targetSteamID), false);
			
			if( g_iUserData[client][i_LastForcedSave] < GetTime() ) {
				StoreUserData(client);
				g_iUserData[client][i_LastForcedSave] = (GetTime()+5);
			}
			if( g_iUserData[vendeur][i_LastForcedSave] < GetTime() ) {
				StoreUserData(vendeur);
				g_iUserData[vendeur][i_LastForcedSave] = (GetTime()+5);
			}
			
			if( item_type == 0 ) {
				CPrintToChat(vendeur, "{lightblue}[TSX-RP]{default} Vous avez vendu %i %s à %N.", amount, g_szItemList[ item_id ][item_type_name], client);
				CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous avez acheté %i %s de %N.", amount, g_szItemList[ item_id ][item_type_name], vendeur);
				
				if( g_iClient_OLD[vendeur] && !g_bUserData[vendeur][b_LicenseSell] ) {
					int z = StringToInt(g_szZoneList[GetPlayerZone(vendeur)][zone_type_type]);
					if( z == 14 )
						z = 11; // fixe pour les chiru
					if( z != GetJobPrimaryID(vendeur) && !(GetZoneBit(GetPlayerZone(client)) & BITZONE_VENTE) && !hidden )  {
						float vecOrigin[3];
						GetClientAbsOrigin(vendeur, vecOrigin);
						TE_SetupBeamRingPoint(vecOrigin, 10.0, 500.0, g_cBeam, g_cGlow, 0, 15, 0.5, 50.0, 0.0, {255, 128, 255, 200}, 10, 0);
						TE_SendToAll();
					}
				}
				char buffer[ (sizeof(g_szItemList[][])*2+1) ];
				SQL_EscapeString(g_hBDD, g_szItemList[ item_id ][item_type_name], buffer, sizeof(buffer));
				
				char szQuery[1024];
				Format(szQuery, sizeof(szQuery), "INSERT INTO `rp_sell` (`id`, `steamid`, `job_id`, `timestamp`, `item_type`, `item_id`, `item_name`, `amount`, `to_steamid`) VALUES (NULL, '%s', '%i', '%i', '0', '%i', '%s', '%i', '%s');",
				SteamID, GetJobPrimaryID(vendeur), GetTime(), item_id, buffer, amount, targetSteamID);
				SQL_TQuery(g_hBDD, SQL_QueryCallBack, szQuery);
				
				
				char ToLog[1024];
				Format(ToLog, sizeof(ToLog), "[TSX-RP] [ITEM-VENDRE] %L a vendu %i %s a %L", vendeur, amount, g_szItemList[ item_id ][item_type_name], client);
				if( reduction > 0 ) {
					Format(ToLog, sizeof(ToLog), "%s avec une réduction de %d%%", ToLog, reduction);
				}
				LogToGame(ToLog);
			}
			
			if( IsArmu(vendeur) ) {
				g_iSuccess_last_armu[client][0] = GetTime();
			}
			
			if( IsGangMaffia(client) || IsGang18th(client)) {
				g_flUserData[vendeur][fl_LastVente] = GetGameTime();
			}
			
			if( item_type == 0 ) {
				if( StringToInt(g_szItemList[ item_id ][item_type_auto]) ) {
					
					if( StrContains(g_szItemList[ item_id ][item_type_extra_cmd], "rp_item_contrat kidnapping") == 0 ) {
						g_bEvent_Kidnapping = true;
					}
					
					rp_ClientGiveItem(client, item_id, -amount);
					if( g_bUserData[client][b_Invisible] ) {
						CopSetVisible(client);
					}
					
					if( day > 0 ) {
						ServerCommand("%s %i %i %i %d", g_szItemList[ item_id ][item_type_extra_cmd], client, day, vendeur, item_id);
					}
					else {
						ServerCommand("%s %i %i %d", g_szItemList[ item_id ][item_type_extra_cmd], client, vendeur, item_id);
					}
				}
			}
		}
	}
	else if (p_oAction == MenuAction_End) {
		CloseHandle(p_hItemMenu);
	}
}

void RestToLowCapital(int rest) {
	int capitalList[MAX_JOBS][2];
	int numb = -1;
	int capital = 0;

	for(int i = 1; i < MAX_JOBS; i++) {
		if(rp_GetJobInt(i, job_type_isboss) == 0) {
			continue;
		}

		if(rp_GetJobInt(i, job_type_current) == 0) {
			continue;
		}

		capital = rp_GetJobCapital(i);

		numb++;
		capitalList[numb][0] = capital;
		capitalList[numb][1] = i;	
	}

	SortCustom2D(capitalList, numb, SortMachineItemsL2H);

	int totalcapital = 0;
	
	for(int i = 0; i < 5; i++) {
		totalcapital = totalcapital + capitalList[i][0];
	}

	if(totalcapital == 0) {
		return;
	}

	int percent[5];

	for(int i = 0; i < 5; i++) {
		percent[i] = Math_GetPercentage(capitalList[i][0], totalcapital);
	}

	int add = 0;

	for(int i = 0; i < 5; i++) {
		add = (rest * percent[4-i]) / 100;
		SetJobCapital(capitalList[i][1], (GetJobCapital(capitalList[i][1]) + add));
	}
}