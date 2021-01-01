#if defined _roleplay_menu_bank_included
#endinput
#endif
#define _roleplay_menu_bank_included

#if !defined _roleplay_base_included || defined ROLEPLAY_SUB
	#define ROLEPLAY_SUB
	#include "../roleplay.sp"
#else
	#include "roleplay.sp"
#endif


void BankATM_transfer(int client, int type) {
	if( IsAtBankPoint(client) ) {
		Handle menu;
		
		char szMoney[256], szBank[256], tmp1[128], tmp2[128];
		String_NumberFormat(g_iUserData[client][i_Money],	tmp1,sizeof(tmp1));
		String_NumberFormat(g_iUserData[client][i_Bank],	tmp2,	sizeof(tmp2));
		
		Format(szMoney, sizeof(szMoney), "%T\n ", "BankATM_transfer_disposite", client, tmp1, tmp2);
		Format(szBank, sizeof(szBank), "%T\n ", "BankATM_transfer_withdraw", client, tmp1, tmp2);
		
		if( type == 1) {
			menu = CreateMenu(BankATM_retrait);
			SetMenuTitle(menu, szBank);
		}
		else if( type == 2 ) {
			menu = CreateMenu(BankATM_depot);
			SetMenuTitle(menu, szMoney);
		}
		else if( type == 3 ) {
			menu = CreateMenu(BankATM_depot_capital);
			SetMenuTitle(menu, szMoney);
		}
		else if( type == 4 ) {
			menu = CreateMenu(BankATM_don_capital);
			SetMenuTitle(menu, szMoney);
		}
		else if( type == 5 ) {
			menu = CreateMenu(BankATM_depot_group);
			SetMenuTitle(menu, szMoney);
		}
		
		AddMenuItem(menu, "1",		"1$"); 	// 1
		AddMenuItem(menu, "10",		"10$"); 	// 2
		AddMenuItem(menu, "100",	"100$"); 	// 3
		AddMenuItem(menu, "1000",	"1 000$");	// 4
		AddMenuItem(menu, "10000",	"10 000$"); 	// 5
		AddMenuItem(menu, "100000",	"100 000$"); 	// 6
		if( type < 3  ) {
			Format(tmp1, sizeof(tmp1), "%T", "BankATM_transfer_all", client); AddMenuItem(menu, "0", "Tout mon argent"); // 9 
		}
		
		SetMenuPagination(menu, false); // ...
		SetMenuExitButton(menu, true); // 0
		DisplayMenu(menu, client, MENU_TIME_DURATION);
	}
}
void DrawBankTransfer(int client) {	
	
	if( !IsAtBankPoint(client) ) {
		return;
	}
	
	char tmp[128];
	
	bool canDisposit = (g_iUserData[client][i_ItemBankPrice] <= getClientBankLimit(client));
	
	// Setup menu
	Handle menu = CreateMenu(DrawBankTransfer_2);
	SetMenuTitle(menu, "%T\n ", "DrawBankTransfer", client);
	
	Format(tmp, sizeof(tmp), "%T", "DrawBankTransfer_to_bank", client, canDisposit ? "Empty_String" : "DrawBankTransfer_full");
	AddMenuItem(menu, "to_bank", tmp, (g_iUserData[client][i_ItemCount] > 0 && canDisposit) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	
	Format(tmp, sizeof(tmp), "%T", "DrawBankTransfer_to_inve", client);
	AddMenuItem(menu, "to_inve", tmp, g_iUserData[client][i_ItemBankCount] > 0 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	
	Format(tmp, sizeof(tmp), "%T", "DrawBankTransfer_hdv", client);
	AddMenuItem(menu, "hdv", tmp, g_bUserData[client][b_HaveAccount] ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	
	Format(tmp, sizeof(tmp), "%T", "DrawBankTransfer_save", client);
	AddMenuItem(menu, "save", tmp, g_bUserData[client][b_HaveAccount] ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED );
	
	Format(tmp, sizeof(tmp), "%T", "DrawBankTransfer_load", client, canDisposit ? "Empty_String" : "DrawBankTransfer_full");
	AddMenuItem(menu, "load", tmp, (g_bUserData[client][b_HaveAccount] && canDisposit) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED );

	Format(tmp, sizeof(tmp), "%T", "DrawBankTransfer_trier", client);
	AddMenuItem(menu, "trier", tmp,  g_bUserData[client][b_CanSort] ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
 
	if( rp_GetClientJobID(client) == 81 && g_iUserData[client][i_Disposed] > 0 ) {
		Format(tmp, sizeof(tmp), "%T", "DrawBankTransfer_to_resell", client);
		AddMenuItem(menu, "to_resell", tmp);
	}
	
	SetMenuPagination(menu, MENU_NO_PAGINATION);
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_DURATION);
}
void DisplayBankMenu(int client, int target) {
	
	if( g_iUserData[client][i_SearchLVL] >= 2 ) {
		CPrintToChat(client, ""...MOD_TAG..." %T", "DrawBankTransfer_Tribunal", client);
		return;
	}

	char tmp[256];
	Handle menu = CreateMenu(BankATM_type);
	SetMenuTitle(menu, "%T\n ", "BankATM", client);
	
	if( rp_GetBuildingData(target, BD_Trapped) == 1 && rp_IsTutorialOver(client) ) {
		
		Format(tmp, sizeof(tmp), "%T", "BankATM_Disabled", client);
		
		AddMenuItem(menu, "a", "", ITEMDRAW_DISABLED);
		AddMenuItem(menu, "a", tmp, ITEMDRAW_DISABLED);
		SetMenuPagination(menu, false);
		SetMenuExitButton(menu, true);
		DisplayMenu(menu, client, MENU_TIME_DURATION);
		return;
	}
	
	Format(tmp, sizeof(tmp), "%T", "BankATM_withdraw", client); 	AddMenuItem(menu, "retrait", tmp);
	Format(tmp, sizeof(tmp), "%T", "BankATM_disposite", client); 	AddMenuItem(menu, "depot", tmp);
	Format(tmp, sizeof(tmp), "%T", "DrawBankTransfer", client); 	AddMenuItem(menu, "item", tmp);
	Format(tmp, sizeof(tmp), "%T", "Menu_Help", client); 			AddMenuItem(menu, "aide", tmp);
	
	if( target > 0 && rp_GetBuildingData(target, BD_owner) > 0 ) {
		// Ceci est une banque d'un joueur
		if( !g_iCustomBank[target] ) {
			g_iCustomBank[target] = rp_WeaponMenu_Create();
		}
		
		Format(tmp, sizeof(tmp), "%T", "DrawBankTransfer_weaponAdd", client); 	AddMenuItem(menu, "weaponAdd", tmp);
		Format(tmp, sizeof(tmp), "%T", "DrawBankTransfer_weaponGet", client); 	AddMenuItem(menu, "weaponGet", tmp, rp_WeaponMenu_GetMax(g_iCustomBank[target]) > view_as<DataPackPos>(1) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	}
	
	#if defined EVENT_APRIL
	Format(tmp, sizeof(tmp), "%T", "DrawBankTransfer_AprilFool", client); 	AddMenuItem(menu, "admin", tmp);
	#endif

	
	SetMenuPagination(menu, false);
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_DURATION);
}

#if defined EVENT_APRIL
void DrawBankTrolley(int client) {
	if( IsAtBankPoint(client) ) {
		Handle menu;
		
		menu = CreateMenu(MenuSelectNote);
		SetMenuTitle(menu, "%T", "DrawBankTransfer_AprilFool", client);
		
		char tmp[1024], expl[32][128];
		Format(tmp, sizeof(tmp), "%T", "DrawBankTransfer_AprilFool_Sub", client);
		int l = ExplodeString(tmp, "\n", expl, sizeof(expl), sizeof(expl[]));
		
		for (int i = 0; i < l; i++) {
			AddMenuItem(menu, "_", expl[i]);
		}
		
		SetMenuExitButton(menu, true); // 0
		DisplayMenu(menu, client, MENU_TIME_DURATION);
	}
}
#endif

public int BankATM_retrait(Handle menu, MenuAction action, int client, int param2) {
	if( action == MenuAction_Select ) {
		char options[64];
		GetMenuItem(menu, param2, options, 63);
		
		if( IsAtBankPoint(client) ) {
			int amount = StringToInt(options);
			
			if( amount == 0 ) {
				amount = g_iUserData[client][i_Bank];
			}
			if( amount > g_iUserData[client][i_Bank] ) {
				CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_NotEnoughtMoney", client);
				BankATM_transfer(client, 1);
			}
			else {
				g_iUserData[client][i_Bank] -= amount;
				g_iUserData[client][i_Money] += amount;
				LogToGame("[TSX-RP] [BANK-MONEY] %L a retiré: %d$", client, amount);
				StoreUserData(client);
				BankATM_transfer(client, 1);
			}
		}
	}
	else if( action == MenuAction_End ) {
		CloseHandle(menu);
	}
}
public int BankATM_depot(Handle menu, MenuAction action, int client, int param2) {
	if( action == MenuAction_Select ) {
		char options[64];
		GetMenuItem(menu, param2, options, 63);
		
		if( IsAtBankPoint(client) ) {
			int amount = StringToInt(options);
			
			if( amount == 0 ) {
				amount = g_iUserData[client][i_Money];
			}
			if( amount > g_iUserData[client][i_Money] ) {
				CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_NotEnoughtMoney", client);
				BankATM_transfer(client, 2);
			}
			else {
				g_iUserData[client][i_Bank] += amount;
				g_iUserData[client][i_Money] -= amount;
				LogToGame("[TSX-RP] [BANK-MONEY] %L a déposé: %d$", client, amount);
				StoreUserData(client);
				BankATM_transfer(client, 2);
			}
		}
	}
	else if( action == MenuAction_End ) {
		CloseHandle(menu);
	}
}
public int BankATM_depot_capital(Handle menu, MenuAction action, int client, int param2) {
	if( action == MenuAction_Select ) {
		char options[64];
		GetMenuItem(menu, param2, options, 63);
		
		if( IsAtBankPoint(client) ) {
			int amount = StringToInt(options);
			
			if( amount == 0 ) {
				amount = g_iUserData[client][i_Money];
			}
			if( amount > g_iUserData[client][i_Money] || g_iUserData[client][i_Money] <= 0 ) {
				CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_NotEnoughtMoney", client);
				BankATM_transfer(client, 3);
			}
			else {
				int capital = GetJobCapital(g_iUserData[client][i_Job]);
				SetJobCapital(g_iUserData[client][i_Job], (capital+amount));
				
				rp_ClientMoney(client, i_Money, -amount, true);
				BankATM_transfer(client, 3);
			}
		}
	}
	else if( action == MenuAction_End ) {
		CloseHandle(menu);
	}
}
public int BankATM_depot_group(Handle menu, MenuAction action, int client, int param2) {
	if( action == MenuAction_Select ) {
		char options[64];
		GetMenuItem(menu, param2, options, 63);
		
		if( IsAtBankPoint(client) ) {
			int amount = StringToInt(options);
			
			if( amount == 0 ) {
				amount = g_iUserData[client][i_Money];
			}
			if( amount > g_iUserData[client][i_Money] || g_iUserData[client][i_Money] <= 0 ) {
				CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_NotEnoughtMoney", client);
				BankATM_transfer(client, 5);
			}
			else {
				int capital = GetGroupCapital(g_iUserData[client][i_Group]);
				SetGroupCapital(g_iUserData[client][i_Group], (capital+amount));
				rp_ClientMoney(client, i_Money, -amount, true);
				
				BankATM_transfer(client, 5);
			}
		}
	}
	else if( action == MenuAction_End ) {
		CloseHandle(menu);
	}
}
public int BankATM_don_capital(Handle menu, MenuAction action, int client, int param2) {
	if( action == MenuAction_Select ) {
		char options[64];
		GetMenuItem(menu, param2, options, 63);
		
		if( IsAtBankPoint(client) ) {
			int amount = StringToInt(options);
			
			if( amount == 0 ) {
				amount = g_iUserData[client][i_Bank];
			}
			if( amount > g_iUserData[client][i_Bank] || g_iUserData[client][i_Bank] <= 0 ) {
				CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_NotEnoughtMoney", client);
				BankATM_transfer(client, 4);
			}
			else {
				int capital = GetJobCapital(211);
				SetJobCapital(211, (capital+amount));
				rp_ClientMoney(client, i_Bank, -amount, true);
				
				BankATM_transfer(client, 4);
			}
		}
	}
	else if( action == MenuAction_End ) {
		CloseHandle(menu);
	}
}

public int BankATM_type(Handle menu, MenuAction action, int client, int param2) {
	if( action == MenuAction_Select ) {
		char options[64], tmp[128];
		GetMenuItem(menu, param2, options, 63);
		
		int target = IsAtBankPoint(client);
		if( target ) {
			if( StrEqual( options, "retrait") ) {
				BankATM_transfer(client, 1);
			}
			else if( StrEqual( options, "depot") ) {
				BankATM_transfer(client, 2);
			}
			else if( StrEqual( options, "item") ) {
				DrawBankTransfer(client);
			}
			else if( StrEqual( options, "aide") ) {
				FakeClientCommand(client, "say /aide");
			}
			else if( StrEqual( options, "weaponAdd") ) {
				int appartID = rp_GetPlayerZoneAppart(client);
				
				Handle menu2 = CreateMenu(BankATM_type);
				SetMenuTitle(menu2, "%T\n ", "Perm_Edit", client);
				
				Format(tmp, sizeof(tmp), "%T", "Perm_Self", client);
				AddMenuItem(menu2, "weaponAddMe", tmp);
				
				if( rp_GetClientJobID(client) != 0 ) {
					Format(tmp, sizeof(tmp), "%T", "Perm_Job", client);
					AddMenuItem(menu2, "weaponAddJob", tmp);
				}
				
				if (rp_GetClientGroupID(client) != 0 && rp_WeaponMenu_CanBeAdded(client) ) {
					Format(tmp, sizeof(tmp), "%T", "Perm_Gang", client);
					AddMenuItem(menu2, "weaponAddGang", tmp);
				}
				
				if( appartID > 0 && rp_GetPlayerZone(client) == rp_GetPlayerZone(target) && rp_GetClientKeyAppartement(client, appartID) && rp_WeaponMenu_CanBeAdded(client) ) {
					Format(tmp, sizeof(tmp), "%T", "Perm_Colloc", client);
					AddMenuItem(menu2, "weaponAddAppart", tmp);		
				}
				
				if( rp_WeaponMenu_CanBeAdded(client) ) {
					Format(tmp, sizeof(tmp), "%T", "Perm_Everyone", client);
					AddMenuItem(menu2, "weaponAddAll", tmp);
				}
				
				SetMenuExitButton(menu2, true);
				DisplayMenu(menu2, client, MENU_TIME_DURATION);
			}
			else if( StrContains( options, "weaponAdd") == 0 ) {
				char classname[65];
				int wep = WeaponsGetDeployedWeaponIndex(client);
				if( wep <= 0 ) 
					return;
				GetEdictClassname(wep, classname, sizeof(classname));
				if( StrContains(classname, "weapon_fists") == 0 )
					return;
				
				if( !g_iCustomBank[target] )
					g_iCustomBank[target] = rp_WeaponMenu_Create();
				
				int owner = client;
				int appartID = rp_GetPlayerZoneAppart(client);
				
				if( StrEqual( options, "weaponAddJob") && rp_GetClientJobID(client) != 0 )
					owner = rp_GetClientJobID(client) + 1000;
				if( StrEqual( options, "weaponAddGang") && rp_GetClientGroupID(client) != 0 )
					owner = rp_GetClientGroupID(client) + 2000;
				if( StrEqual( options, "weaponAddAppart") && appartID > 0 && rp_GetPlayerZone(client) == rp_GetPlayerZone(target) && rp_GetClientKeyAppartement(client, appartID) )
					owner = appartID + 3000;
				if( StrEqual( options, "weaponAddAll") )
					owner = 0;
				
				bool success = rp_WeaponMenu_Add(g_iCustomBank[target], wep, owner);
				if( success ) {
					RemovePlayerItem(client, wep);
					RemoveEdict(wep);
					FakeClientCommand(client, "use weapon_fists");
				}
			}
			else if( StrEqual( options, "weaponGet") ) {
				if( !g_iCustomBank[target] )
					g_iCustomBank[target] = rp_WeaponMenu_Create();
				
				int appartID = rp_GetPlayerZoneAppart(client);
				if( !(appartID > 0 && rp_GetPlayerZone(client) == rp_GetPlayerZone(target) && rp_GetClientKeyAppartement(client, appartID)) )
					appartID = -1;
				
				DataPackPos max = rp_WeaponMenu_GetMax(g_iCustomBank[target]);
				DataPackPos position = rp_WeaponMenu_GetPosition(g_iCustomBank[target]);
				if( position >= max )
					return;
				
				char name[BM_WeaponNameSize], tmp2[128];
				int[] data = new int[view_as<int>(BM_Max)];
				int count = 0;
				bool permValid = false;
				
				Handle menu2 = CreateMenu(BankATM_type);
				SetMenuTitle(menu2, "%T\n ", "DrawBankTransfer", client);
				
				while( position < max ) {
					
					rp_WeaponMenu_Get(g_iCustomBank[target], position, name, data);
					permValid = false;
					
					if( data[BM_Owner] == 0 )
						permValid = true;
					else if( data[BM_Owner] < 1000 && data[BM_Owner] == client )
						permValid = true;
					else if( data[BM_Owner] < 2000 && data[BM_Owner]-1000 == rp_GetClientJobID(client) )
						permValid = true;
					else if( data[BM_Owner] < 3000 && data[BM_Owner]-2000 == rp_GetClientGroupID(client) )
						permValid = true;
					else if( data[BM_Owner] < 4000 && data[BM_Owner]-3000 == appartID )
						permValid = true;
					
					if( permValid ) {
						Format(tmp, sizeof(tmp), "weaponGet %d %d", target, position);
						if(data[BM_PvP] > 0)
							Format(tmp2, sizeof(tmp2), "[PvP] ");
						else
							Format(tmp2, sizeof(tmp2), "");
						
						if( data[BM_Munition] == -1 )
							Format(tmp2, sizeof(tmp2), "%s %s", tmp2, name);
						else
							Format(tmp2, sizeof(tmp2), "%s %s (%d/%d) ", tmp2, name, data[BM_Munition] , data[BM_Chargeur]);
							
						switch (view_as<enum_ball_type>(data[BM_Type])) {
							case ball_type_fire: 			Format(tmp2, sizeof(tmp2), "%T", "wpn_ball_type_fire", client, tmp2);
							case ball_type_caoutchouc:		Format(tmp2, sizeof(tmp2), "%T", "wpn_ball_type_caoutchouc", client, tmp2);
							case ball_type_poison:			Format(tmp2, sizeof(tmp2), "%T", "wpn_ball_type_poison", client, tmp2);
							case ball_type_vampire:			Format(tmp2, sizeof(tmp2), "%T", "wpn_ball_type_vampire", client, tmp2);
							case ball_type_paintball:		Format(tmp2, sizeof(tmp2), "%T", "wpn_ball_type_paintball", client, tmp2);
							case ball_type_reflexive:		Format(tmp2, sizeof(tmp2), "%T", "wpn_ball_type_reflexive", client, tmp2);
							case ball_type_explode:			Format(tmp2, sizeof(tmp2), "%T", "wpn_ball_type_explode", client, tmp2);
							case ball_type_revitalisante:	Format(tmp2, sizeof(tmp2), "%T", "wpn_ball_type_revitalisante", client, tmp2);
							case ball_type_nosteal:			Format(tmp2, sizeof(tmp2), "%T", "wpn_ball_type_nosteal", client, tmp2);
							case ball_type_notk:			Format(tmp2, sizeof(tmp2), "%T", "wpn_ball_type_notk", client, tmp2);
							case ball_type_braquage:		Format(tmp2, sizeof(tmp2), "%T", "wpn_ball_type_braquage", client, tmp2);
						}
						
						AddMenuItem(menu2, tmp, tmp2);
						count++;
					}
					position = rp_WeaponMenu_GetPosition(g_iCustomBank[target]);
				}
				if( count == 0 ) {
					delete menu2;
					return;
				}
				SetMenuExitButton(menu2, true);
				DisplayMenu(menu2, client, MENU_TIME_DURATION);
			}
			else if( StrContains( options, "weaponGet") == 0 ) {
				char expl[2][8];
				ReplaceString(options, sizeof(options), "weaponGet ", "");
				ExplodeString(options, " ", expl, sizeof(expl), sizeof(expl[]));
				if( StringToInt(expl[0]) != target ) {
					return;
				}
				if( !g_iCustomBank[target] ){
					return;
				}
				
				char name[BM_WeaponNameSize];
				int[] data = new int[view_as<int>(BM_Max)];
				rp_WeaponMenu_Get(g_iCustomBank[target], view_as<DataPackPos>(StringToInt(expl[1])), name, data);
				
				Format(name, sizeof(name), "weapon_%s", name);
				
				int iWeaponSlot = -1;
			
				for(int lp; lp < MAX_BUYWEAPONS; lp++) {
					if (strcmp(g_szBuyWeapons[lp][0], name) == 0) {
						iWeaponSlot = StringToInt(g_szBuyWeapons[lp][2]);
						break;
					}
				}
					
				int wepid = GivePlayerItem(client, name);
				
				if( Weapon_ShouldBeEquip(name) )
					EquipPlayerWeapon(client, wepid);
				
				
				rp_SetWeaponBallType(wepid, view_as<enum_ball_type>(data[BM_Type]));
				if(data[BM_PvP] > 0)
					rp_SetWeaponGroupID(wepid, rp_GetClientGroupID(client));
				
				if( data[BM_Munition] != -1 ) {
					SetEntProp(wepid, Prop_Send, "m_iClip1", data[BM_Munition]);
					SetEntProp(wepid, Prop_Send, "m_iPrimaryReserveAmmoCount", data[BM_Chargeur]);
				}
				
				g_iWeaponFromStore[wepid] = data[BM_Store];
				
				rp_WeaponMenu_Delete(g_iCustomBank[target], view_as<DataPackPos>(StringToInt(expl[1])));
					
			}
			#if defined EVENT_APRIL
			else if( StrEqual( options, "admin") ) {
				DrawBankTrolley(client);
			}
			#endif
		}
	}
	else if( action == MenuAction_End ) {
		CloseHandle(menu);
	}
}
public int DrawBankTransfer_2(Handle p_hItemMenu, MenuAction p_oAction, int p_iParam1, int p_iParam2) {

	
	if (p_oAction == MenuAction_Select) {
		char szMenuItem[32];
		int client = p_iParam1;
		if( !IsAtBankPoint(client) ) {
			return;
		}
		if (GetMenuItem(p_hItemMenu, p_iParam2, szMenuItem, sizeof(szMenuItem))) {
			
			Handle menu = INVALID_HANDLE;
			
			char tmp[255], tmp2[255];
			int type, amount;
			
			if( StrEqual(szMenuItem, "to_bank", false) ) {
				type = 1;
				
				amount = g_iUserData[client][i_ItemCount];
				if( amount == 0 ) {
					DrawBankTransfer(client);
					return;
				}
				
				menu = CreateMenu(DrawBankTransfer_3);
				SetMenuTitle(menu, "%T\n%T\n ", "DrawBankTransfer", client, "DrawBankTransfer_coffre", client, RoundToFloor(float(g_iUserData[client][i_ItemBankPrice]) / float(getClientBankLimit(client)) * 100.0));
				
			}
			else if( StrEqual(szMenuItem, "to_inve", false) ) {
				type = 2;
				
				amount = g_iUserData[client][i_ItemBankCount];
				if( amount == 0 ) {
					DrawBankTransfer(client);
					return;
				}
				
				menu = CreateMenu(DrawBankTransfer_3);
				SetMenuTitle(menu, "%T\n%T\n ", "DrawBankTransfer", client, "DrawBankTransfer_coffre", client, RoundToFloor(float(g_iUserData[client][i_ItemBankPrice]) / float(getClientBankLimit(client)) * 100.0));
			}
			else if( StrContains(szMenuItem, "save", false) == 0 ) {
				char buff[3][12];
				ExplodeString(szMenuItem, " ", buff, sizeof(buff), sizeof(buff[]));

				if( StrEqual(szMenuItem, "save", false) ){
					menu = CreateMenu(DrawBankTransfer_2);
					SetMenuTitle(menu, "%T\n ", "DrawBankTransfer_save", client);


					for( int i=0; i<sizeof(g_szItems_SAVE[]); i++ ){
						if(StrEqual(g_szItems_SAVE[client][i], "")){
							break;
						}

						Format(tmp, sizeof(tmp), "save %d", i);			
						AddMenuItem(menu, tmp, g_szItems_SAVE[client][i]);
					}
				}
				else if( StringToInt(buff[2]) == 0 ){
					int config = StringToInt(buff[1]);
					menu = CreateMenu(DrawBankTransfer_2);

					SetMenuTitle(menu, "%T\n%s\n ", "DrawBankTransfer_save", client, g_szItems_SAVE[client][config]);
					
					Format(tmp, sizeof(tmp), "save %d 1", config);
					Format(tmp2, sizeof(tmp2), "%T", "DrawBankTransfer_rename", client);
					AddMenuItem(menu, tmp, tmp2);
					
					Format(tmp, sizeof(tmp), "save %d 2", config);	
					Format(tmp2, sizeof(tmp2), "%T", "DrawBankTransfer_save_items", client);
					AddMenuItem(menu, tmp, tmp2);
				}
				else {
					int config = StringToInt(buff[1]);
					if( StringToInt(buff[2]) == 1 ){
						menu = CreateMenu(MenuNothing);
						SetMenuTitle(menu, "%T\n%s\n ", "DrawBankTransfer_save", client, g_szItems_SAVE[client][config]);
						
						Format(tmp, sizeof(tmp), "%T", "DrawBankTransfer_rename_chat", client);
						AddMenuItem(menu, "_", tmp, ITEMDRAW_DISABLED);
						
						rp_GetClientNextMessage(client, config, fwdBankSetSaveName);
					} else if( StringToInt(buff[2]) == 2 ){
						ItemSave_SetItems(client, config);
						return;
					}
				}
			}
			else if( StrContains(szMenuItem, "load", false) == 0 ) {
				char buff[2][12];
				ExplodeString(szMenuItem, " ", buff, sizeof(buff), sizeof(buff[]));

				if( StrEqual(szMenuItem, "load", false) ){
					menu = CreateMenu(DrawBankTransfer_2);
					SetMenuTitle(menu, "%T\n ", "DrawBankTransfer_load", client, "Empty_String");


					for( int i=0; i<sizeof(g_szItems_SAVE[]); i++ ){
						if(StrEqual(g_szItems_SAVE[client][i], "")){
							break;
						}

						Format(tmp, sizeof(tmp), "load %d", i);	
						AddMenuItem(menu, tmp, g_szItems_SAVE[client][i]);
					}
				} else {
					int config = StringToInt(buff[1]);
					ItemSave_Withdraw(client, config);
					return;
				}
			}
			else if( StrEqual(szMenuItem, "to_resell", false) ) {
				
				char szWeapon[64];
				int id = WeaponsGetDeployedWeaponIndex(client);
				if( id > 0 ) {
					int price = rp_GetWeaponPrice(id);
					price /= 4;
					GetEdictClassname(id, szWeapon, sizeof(szWeapon));
					
					if( g_iUserData[client][i_Disposed] > 0 &&
						StrContains(szWeapon, "weapon_knife") == -1 && StrContains(szWeapon, "weapon_bayonet") == -1 && StrContains(szWeapon, "weapon_fists") == -1 &&
						StrContains(szWeapon, "weapon_bumpmine") == -1 && StrContains(szWeapon, "weapon_snowball") == -1 ) {
						
						Call_StartForward( view_as<Handle>(g_hRPNative[client][RP_OnResellWeapon]) );
						Call_PushCell(client);
						Call_PushCell(id);
						Call_PushCell(price);
						Call_Finish();
						
						RemovePlayerItem(client, id );
						RemoveEdict( id );
						
						g_bUserData[client][b_WeaponIsKnife] = false;
						g_bUserData[client][b_WeaponIsHands] = true;
						g_bUserData[client][b_WeaponIsMelee] = false;
						FakeClientCommand(client, "use weapon_fists");
						
						g_iUserData[client][i_Disposed]--;
						
						SetJobCapital(81, (GetJobCapital(81) + (price)));
						rp_ClientMoney(client, i_AddToPay, (price));
						rp_SetClientStat(client, i_MoneyEarned_Sales, rp_GetClientStat(client, i_MoneyEarned_Sales) + price);
						
						char SteamID[64], szQuery[1024];
	
						GetClientAuthId(client, AUTH_TYPE, SteamID, sizeof(SteamID), false);
						Format(szQuery, sizeof(szQuery), "INSERT INTO `rp_sell` (`id`, `steamid`, `job_id`, `timestamp`, `item_type`, `item_id`, `item_name`, `amount`) VALUES (NULL, '%s', '%i', '%i', '4', '%i', '%s', '%i');",
						SteamID, rp_GetClientJobID(client), GetTime(), 0, "Revente: Arme", price/4);
				
						
						LogToGame("[TSX-RP] [RESELL-ARMES] %L a déposé: %s", client, szWeapon);
						ReplaceString(szWeapon, sizeof(szWeapon), "weapon_", "");
						
						DrawBankTransfer(client);
						return;
					}
					else {
						DrawBankTransfer(client);
						return;
					}
				}
			}
			else if( StrContains(szMenuItem, "trier", false) == 0 ) {
				
				char buff[2][12];
				ExplodeString(szMenuItem, " ", buff, sizeof(buff), sizeof(buff[]));
				
				if( StringToInt(buff[1]) == 0 ) {
					Handle menu2 = CreateMenu(DrawBankTransfer_2);
					SetMenuTitle(menu2, "%T\n ", "DrawBankTransfer_trier", client);
					
					Format(tmp, sizeof(tmp), "%T", "DrawBankTransfer_trier_AZ_ASC", client);	AddMenuItem(menu2, "trier 1", tmp);
					Format(tmp, sizeof(tmp), "%T\n ", "DrawBankTransfer_trier_AZ_DESC", client); 	AddMenuItem(menu2, "trier 2", tmp);
					
					Format(tmp, sizeof(tmp), "%T", "DrawBankTransfer_trier_PX_ASC", client); 	AddMenuItem(menu2, "trier 3", tmp);
					Format(tmp, sizeof(tmp), "%T\n ", "DrawBankTransfer_trier_PX_DESC", client); 	AddMenuItem(menu2, "trier 4", tmp);
					
					Format(tmp, sizeof(tmp), "%T", "DrawBankTransfer_trier_TY_ASC", client); 	AddMenuItem(menu2, "trier 5", tmp);
					Format(tmp, sizeof(tmp), "%T\n ", "DrawBankTransfer_trier_TY_DESC", client); 	AddMenuItem(menu2, "trier 6", tmp);
					
					Format(tmp, sizeof(tmp), "%T", "DrawBankTransfer_trier_JB_ASC", client); 	AddMenuItem(menu2, "trier 7", tmp);
					Format(tmp, sizeof(tmp), "%T\n ", "DrawBankTransfer_trier_JB_DESC", client); 	AddMenuItem(menu2, "trier 8", tmp);
					
					SetMenuPagination(menu2, false); 
					SetMenuExitButton(menu2, true);
					DisplayMenu(menu2, client, MENU_TIME_DURATION);
					return;
				}
				
				switch( StringToInt(buff[1]) ) {
					case 1:	{ SortCustom2D(g_iItems_BANK[client], g_iUserData[client][i_ItemBankCount], SortItemAlpha);			}
					case 2: { SortCustom2D(g_iItems_BANK[client], g_iUserData[client][i_ItemBankCount], SortItemAlphaReverse); 	}
					case 3:	{ SortCustom2D(g_iItems_BANK[client], g_iUserData[client][i_ItemBankCount], SortItemPrix); 		 	} 
					case 4:	{ SortCustom2D(g_iItems_BANK[client], g_iUserData[client][i_ItemBankCount], SortItemPrixReverse);  	}
					case 5:	{ SortCustom2D(g_iItems_BANK[client], g_iUserData[client][i_ItemBankCount], SortItemType); 		 	}
					case 6:	{ SortCustom2D(g_iItems_BANK[client], g_iUserData[client][i_ItemBankCount], SortItemTypeReverse);  	}
					case 7:	{ SortCustom2D(g_iItems_BANK[client], g_iUserData[client][i_ItemBankCount], SortItemJob); 		 	}
					case 8:	{ SortCustom2D(g_iItems_BANK[client], g_iUserData[client][i_ItemBankCount], SortItemJobReverse); 	}
				}
				
				StoreUserData(client);
				DrawBankTransfer(client);
				
				return;
			}
			else if( StrEqual(szMenuItem, "hdv", false) ) {
				FakeClientCommand(client, "rp_hdv");
				return;
			}
			else if( StrEqual( szMenuItem, "capital", false) ) {
				BankATM_transfer(client, 3);
				return;
			}
			else if( StrEqual( szMenuItem, "etat", false) ) {
				BankATM_transfer(client, 4);
				return;
			}
			else if( StrEqual( szMenuItem, "group", false) ) {
				BankATM_transfer(client, 5);
				return;
			}
			
			
			int id, cpt;
			
			for (int i = 0; i < amount; i++) {
				
				if( type == 1 ) {				
					id = g_iItems[client][i][STACK_item_id];
					cpt = g_iItems[client][i][STACK_item_amount];
					
					if( cpt <= 0 )
						continue;
				}
				else {
					id = g_iItems_BANK[client][i][STACK_item_id];
					cpt = g_iItems_BANK[client][i][STACK_item_amount];
					
					if( cpt <= 0 )
						continue;
					
					if( StrContains(g_szItemList[id][item_type_extra_cmd], "rp_item_vehicle") == 0 )
						continue;
				}
				
				if( StringToInt( g_szItemList[id][item_type_job_id] ) == 101 )
					continue;
				if( StringToInt(g_szItemList[id][item_type_no_bank]) == 1 )
					continue;
					
				
				Format( tmp, sizeof(tmp), "%i_%i", id, type);
				Format( tmp2, sizeof(tmp2), "%s [%i]", g_szItemList[id][item_type_name], cpt);
				
				AddMenuItem(menu, tmp, tmp2);
			}
			
			DisplayMenu(menu, client, MENU_TIME_DURATION*5);
			
		}
	}
	else if (p_oAction == MenuAction_End) {
		CloseHandle(p_hItemMenu);
	}
}
public int DrawBankTransfer_3(Handle p_hItemMenu, MenuAction p_oAction, int p_iParam1, int p_iParam2) {
	
	if (p_oAction == MenuAction_Select) {
		if( !IsAtBankPoint(p_iParam1) ) {
			return;
		}
		char options[64], tmp[256], tmp2[256], data[2][32];
		GetMenuItem(p_hItemMenu, p_iParam2, options, sizeof(options));
		ExplodeString(options, "_", data, sizeof(data), sizeof(data[]));
		
		int id = StringToInt(data[0]);
		int transfer_type = StringToInt(data[1]);
		
		int max;
		if( transfer_type == 1 ) {
			max = rp_GetClientItem(p_iParam1, id);
		}
		else {
			max = rp_GetClientItem(p_iParam1, id, true);
		}
		
		Handle menu = CreateMenu(DrawBankTransfer_4);
		SetMenuTitle(menu, "%T\n ", "DrawBankTransfer_account", p_iParam1);
		
		Format(tmp, sizeof(tmp), "%i_%i_%i", id, transfer_type, max);
		Format(tmp2, sizeof(tmp2), "%T", "DrawBankTransfer_account_all", p_iParam1, g_szItemList[id][item_type_name], max);
		AddMenuItem(menu, tmp, tmp2);
		
		if( max > 100 )
			max = 100;
		
		for(int i=1; i<=max; i++) {
			Format(tmp, sizeof(tmp), "%i_%i_%i", id, transfer_type, i);
			Format(tmp2, sizeof(tmp2), "%s - %i/%i", g_szItemList[id][item_type_name], i, max);
			AddMenuItem(menu, tmp, tmp2);
		}
		
		DisplayMenu(menu, p_iParam1, MENU_TIME_DURATION);
	}
	else if (p_oAction == MenuAction_End) {
		CloseHandle(p_hItemMenu);
	}
}
public int DrawBankTransfer_4(Handle p_hItemMenu, MenuAction p_oAction, int p_iParam1, int p_iParam2) {
	if (p_oAction == MenuAction_Select) {
		if( !IsAtBankPoint(p_iParam1) ) {
			return;
		}
		char options[64], data[3][32];
		GetMenuItem(p_hItemMenu, p_iParam2, options, sizeof(options) );
		ExplodeString(options, "_", data, sizeof(data), sizeof(data[]));
		
		int id = StringToInt(data[0]);
		int transfer_type = StringToInt(data[1]);
		int amount = StringToInt(data[2]);
		int itemCount = rp_GetClientItem(p_iParam1, id, (transfer_type == 2));
		
		if( itemCount < amount )
			amount = itemCount;
		
		rp_ClientGiveItem(p_iParam1, id, -amount, (transfer_type == 2));
		rp_ClientGiveItem(p_iParam1, id, amount, (transfer_type == 1));
		
		updateBankCost(p_iParam1);
		
		if( g_iUserData[p_iParam1][i_LastForcedSave] < GetTime() ) {
			StoreUserData(p_iParam1);
			g_iUserData[p_iParam1][i_LastForcedSave] = (GetTime()+5);
		}
		
		if( transfer_type == 1 ) {
			CPrintToChat(p_iParam1, ""...MOD_TAG..." %T", "Item_Disposite", p_iParam1, amount, g_szItemList[id][item_type_name]);
			LogToGame("[TSX-RP] [BANK-ITEM] %L a déposé: %d %s", p_iParam1, amount, g_szItemList[id][item_type_name]);
		}
		else {
			CPrintToChat(p_iParam1, ""...MOD_TAG..." %T", "Item_Take", p_iParam1, amount, g_szItemList[id][item_type_name]);
			LogToGame("[TSX-RP] [BANK-ITEM] %L a retiré: %d %s", p_iParam1, amount, g_szItemList[id][item_type_name]);
		}
	
		StoreUserData(p_iParam1);
		DrawBankTransfer(p_iParam1);
	}
	else if (p_oAction == MenuAction_End) {
		CloseHandle(p_hItemMenu);
	}
}

public void fwdBankSetSaveName(int client, int save, char[] message) {
	char tmp[32];
	SQL_EscapeString(g_hBDD, message, tmp, sizeof(tmp));
	
	if( strlen(message) >= 3 ) {
		ItemSave_SetName(client, save, tmp);
		CPrintToChat(client, "" ...MOD_TAG... " %T", "DrawBankTransfer_rename_done", client);
		DrawBankTransfer(client);
	}
	else {
		CPrintToChat(client, "" ...MOD_TAG... " %T", "DrawBankTransfer_rename_fail", client);
	}
}
