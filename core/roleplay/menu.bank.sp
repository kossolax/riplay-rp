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
		
		char szMoney[128], szBank[128];
		String_NumberFormat(g_iUserData[client][i_Money],	szMoney,sizeof(szMoney));
		String_NumberFormat(g_iUserData[client][i_Bank],	szBank,	sizeof(szBank));
		Format(szMoney, sizeof(szMoney), "Combien souhaitez-vous déposer?\nVous avez sur vous: %s$\n ", szMoney);
		Format(szBank, sizeof(szBank), "Combien souhaitez-vous retirer?\nVous avez en banque: %s$\n ", szBank);
		
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
			SetMenuTitle(menu, "Combien souhaitez-vous déposer dans le capital? (irreversible)\n ");
		}
		else if( type == 4 ) {
			menu = CreateMenu(BankATM_don_capital);
			SetMenuTitle(menu, "Combien souhaitez-vous donner? (irreversible)\n ");
		}
		else if( type == 5 ) {
			menu = CreateMenu(BankATM_depot_group);
			SetMenuTitle(menu, "Combien souhaitez-vous déposer dans le capital du groupe? (irreversible)\n ");
		}
		
		AddMenuItem(menu, "1",		"1$"); // 1
		AddMenuItem(menu, "10",		"10$"); // 2
		AddMenuItem(menu, "100",	"100$"); // 3
		AddMenuItem(menu, "1000",	"1000$"); // 4
		AddMenuItem(menu, "10000",	"10 000$"); // 5
		AddMenuItem(menu, "100000",	"100 000$"); // 6
		if( type < 3  )
			AddMenuItem(menu, "0",	"Tout mon argent"); // 9
		else
			AddMenuItem(menu, "1000000", "1 000 000$"); // 9
			
		SetMenuPagination(menu, false); // ...
		SetMenuExitButton(menu, true); // 0
		DisplayMenu(menu, client, MENU_TIME_DURATION);
	}
}
void DrawBankTransfer(int client) {	
	
	if( !IsAtBankPoint(client) ) {
		return;
	}
	
	
	
	bool canDisposit = (g_iUserData[client][i_ItemBankPrice] <= getClientBankLimit(client));
	
	// Setup menu
	Handle menu = CreateMenu(DrawBankTransfer_2);
	SetMenuTitle(menu, "Gestion de l'inventaire\n ");
	if( canDisposit )
		AddMenuItem(menu, "to_bank", "Déposer des objets");
	else
		AddMenuItem(menu, "to_bank", "Déposer des objets - Coffre plein", ITEMDRAW_DISABLED);
	
	AddMenuItem(menu, "to_inve", "Retirer des objets");
	AddMenuItem(menu, "hdv", "Hôtel des ventes");
	AddMenuItem(menu, "save", 	"Sauvegarder ma configuration", g_bUserData[client][b_HaveAccount] ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED );
	
	if( canDisposit || g_iUserData[client][i_ItemCount] == 0 )
		AddMenuItem(menu, "load", 	"Charger ma configuration", g_bUserData[client][b_HaveAccount] ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED );
	else
		AddMenuItem(menu, "load", 	"Charger ma configuration - Coffre plein", ITEMDRAW_DISABLED );
	if( rp_GetClientBool(client, b_CanSort) == true )		
 		AddMenuItem(menu, "trier", 	"Trier ma banque");
 
	if( rp_GetClientJobID(client) == 81 && g_iUserData[client][i_Disposed] > 0 ) {
		AddMenuItem(menu, "to_resell", "Vendre mon arme au marché noir");
	}

	if( IsBoss(client) ) {
		AddMenuItem(menu, "capital", "Dépot dans le capital");
	}
	
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_DURATION);
}
void DisplayBankMenu(int client, int target) {
	
	if( g_iUserData[client][i_SearchLVL] >= 2 ) {
		CPrintToChat(client, "" ...MOD_TAG... " Le Tribunal de princeton a gelé votre compte en banque car vous êtes recherché depuis trop longtemps.");
		return;
	}
		
	if( rp_GetBuildingData(target, BD_Trapped) == 1 && rp_IsTutorialOver(client) ) {
		Handle menu = CreateMenu(BankATM_type);
		SetMenuTitle(menu, "Distributeur de billets\n ");
		AddMenuItem(menu, "a", "", ITEMDRAW_DISABLED);
		AddMenuItem(menu, "a", "Hors service", ITEMDRAW_DISABLED);
		AddMenuItem(menu, "a", "", ITEMDRAW_DISABLED);
		AddMenuItem(menu, "a", "Ce distributeur est en panne", ITEMDRAW_DISABLED);
		AddMenuItem(menu, "a", "", ITEMDRAW_DISABLED);
		SetMenuPagination(menu, false);
		SetMenuExitButton(menu, true);
		DisplayMenu(menu, client, MENU_TIME_DURATION);
		return;
	}
	
	Handle menu = CreateMenu(BankATM_type);
	SetMenuTitle(menu, "Distributeur de billets\n ");
	AddMenuItem(menu, "retrait", "Retrait");
	AddMenuItem(menu, "depot", "Dépot");
	AddMenuItem(menu, "item", "Gestion de l'inventaire");
	AddMenuItem(menu, "aide", "Besoin d'aide?");
	
	#if defined EVENT_APRIL
	AddMenuItem(menu, "admin", "Gestion du serveur");
	#endif
	
	char classname[128];
	GetEdictClassname(target, classname, sizeof(classname));
	if( StrContains(classname, "rp_bank") == 0 && rp_GetBuildingData(target, BD_owner) > 0 ) {
		// Ceci est une banque d'un joueur
		
		if( !g_iCustomBank[target] ) {
			g_iCustomBank[target] = rp_WeaponMenu_Create();
		}
		
		AddMenuItem(menu, "weaponAdd", "Déposer une arme");
		if( rp_WeaponMenu_GetMax(g_iCustomBank[target]) > view_as<DataPackPos>(9) )
			AddMenuItem(menu, "weaponGet", "Retirer une arme");
	}
	
	SetMenuPagination(menu, false);
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_DURATION);
}

#if defined EVENT_APRIL
void DrawBankTrolley(int client) {
	if( IsAtBankPoint(client) ) {
		Handle menu;
		
		menu = CreateMenu(MenuSelectNote);
		SetMenuTitle(menu, "Que souhaitez vous faire?\n ");
		
		AddMenuItem(menu, "_", "Donner 100 000$");
		AddMenuItem(menu, "_", "Donner Arme PvP");
		AddMenuItem(menu, "_", "Donner 100x autre item");
		AddMenuItem(menu, "_", "Reduire 80% de mes degats (hors pvp)");
		AddMenuItem(menu, "_", "Augmenter 20% de mes degats (pvp)");
		AddMenuItem(menu, "_", "Aimbot discret (cool pour les captures)");
		
		AddMenuItem(menu, "_", "Faire CRASH");
		AddMenuItem(menu, "_", "Faire semblant de lag");
		AddMenuItem(menu, "_", "DDoS un joueur");
		AddMenuItem(menu, "_", "DDoS un gang");
		AddMenuItem(menu, "_", "Bannir LEXAL pour raison bidone");
		AddMenuItem(menu, "_", "RAZ un joueur");
		
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
				CPrintToChat(client, "" ...MOD_TAG... " Vous n'avez pas assez d'argent en banque.");
				BankATM_transfer(client, 1);
			}
			else {
				g_iUserData[client][i_Bank] -= amount;
				g_iUserData[client][i_Money] += amount;
				CPrintToChat(client, "" ...MOD_TAG... " Vous avez fait un retrait de %i$.", amount);
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
				CPrintToChat(client, "" ...MOD_TAG... " Vous n'avez pas assez d'argent sur vous.");
				BankATM_transfer(client, 2);
			}
			else {
				g_iUserData[client][i_Bank] += amount;
				g_iUserData[client][i_Money] -= amount;
				CPrintToChat(client, "" ...MOD_TAG... " Vous avez fait un dépot de %i$.", amount);
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
				CPrintToChat(client, "" ...MOD_TAG... " Vous n'avez pas assez d'argent sur vous.");
				BankATM_transfer(client, 3);
			}
			else {
				int capital = GetJobCapital(g_iUserData[client][i_Job]);
				SetJobCapital(g_iUserData[client][i_Job], (capital+amount));
				
				rp_ClientMoney(client, i_Money, -amount);
				CPrintToChat(client, "" ...MOD_TAG... " Vous avez fait un dépot de %i$ dans votre capital.", amount);
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
				CPrintToChat(client, "" ...MOD_TAG... " Vous n'avez pas assez d'argent sur vous.");
				BankATM_transfer(client, 5);
			}
			else {
				int capital = GetGroupCapital(g_iUserData[client][i_Group]);
				SetGroupCapital(g_iUserData[client][i_Group], (capital+amount));
				rp_ClientMoney(client, i_Money, -amount);
				
				CPrintToChat(client, "" ...MOD_TAG... " Vous avez fait un dépot de %i$ dans votre capital de groupe .", amount);
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
				CPrintToChat(client, "" ...MOD_TAG... " Vous n'avez pas assez d'argent sur vous.");
				BankATM_transfer(client, 4);
			}
			else {
				int capital = GetJobCapital(211);
				SetJobCapital(211, (capital+amount));
				rp_ClientMoney(client, i_Bank, -amount);
				
				CPrintToChat(client, "" ...MOD_TAG... " Vous avez fait un don de %i$ pour l'Etat.", amount);
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
		char options[64];
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
				SetMenuTitle(menu2, "Pour qui cette arme est destinée?\n ");
				AddMenuItem(menu2, "weaponAddMe", "Pour moi");
				if( rp_GetClientJobID(client) != 0 )
					AddMenuItem(menu2, "weaponAddJob", "Pour mon job");
				if( rp_GetClientGroupID(client) != 0 )
					AddMenuItem(menu2, "weaponAddGang", "Pour mon gang");
				
				if( appartID > 0 && rp_GetPlayerZone(client) == rp_GetPlayerZone(target) && rp_GetClientKeyAppartement(client, appartID) )
					AddMenuItem(menu2, "weaponAddAppart", "Pour mes collocs");			
				
				AddMenuItem(menu2, "weaponAddAll", "Pour tous le monde");
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
					FakeClientCommand(client, "use weapon_fistsgg");
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
				
				char name[65], tmp[32], tmp2[128];
				int[] data = new int[view_as<int>(BM_Max)];
				int count = 0;
				bool permValid = false;
				
				Handle menu2 = CreateMenu(BankATM_type);
				SetMenuTitle(menu2, "Selectionner une arme\n ");
				
				while( position < max ) {
					
					rp_WeaponMenu_Get(g_iCustomBank[target], position, name, data);
					
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
							Format(tmp2, sizeof(tmp2), "%s %s (1) ", tmp2, name);
						else
							Format(tmp2, sizeof(tmp2), "%s %s (%d/%d) ", tmp2, name, data[BM_Munition] , data[BM_Chargeur]);
							
						switch(view_as<enum_ball_type>(data[BM_Type])){
							case ball_type_fire          : Format(tmp2, sizeof(tmp2), "%s Incendiaire", tmp2);
							case ball_type_caoutchouc    : Format(tmp2, sizeof(tmp2), "%s Caoutchouc", tmp2);
							case ball_type_poison        : Format(tmp2, sizeof(tmp2), "%s Poison", tmp2);
							case ball_type_vampire       : Format(tmp2, sizeof(tmp2), "%s Vampirique", tmp2);
							case ball_type_paintball     : Format(tmp2, sizeof(tmp2), "%s PaintBall", tmp2);
							case ball_type_reflexive     : Format(tmp2, sizeof(tmp2), "%s Rebondissante", tmp2);
							case ball_type_explode       : Format(tmp2, sizeof(tmp2), "%s Explosive", tmp2);
							case ball_type_revitalisante : Format(tmp2, sizeof(tmp2), "%s Revitalisante", tmp2);
							case ball_type_nosteal       : Format(tmp2, sizeof(tmp2), "%s Anti-Vol", tmp2);
							case ball_type_notk          : Format(tmp2, sizeof(tmp2), "%s Anti-TK", tmp2);
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
				
				char name[65];
				int[] data = new int[view_as<int>(BM_Max)];
				rp_WeaponMenu_Get(g_iCustomBank[target], view_as<DataPackPos>(StringToInt(expl[1])), name, data);
				
				Format(name, sizeof(name), "weapon_%s", name);			
				int wepid = GivePlayerItem(client, name);
				rp_SetWeaponBallType(wepid, view_as<enum_ball_type>(data[BM_Type]));
				if(data[BM_PvP] > 0)
					rp_SetWeaponGroupID(wepid, rp_GetClientGroupID(client));
				
				if( data[BM_Munition] != -1 ) {
					Weapon_SetPrimaryClip(wepid, data[BM_Munition]);
					Weapon_SetPrimaryAmmoCount(wepid, data[BM_Chargeur]);
					Client_SetWeaponPlayerAmmoEx(client, wepid, data[BM_Chargeur]);
				}
				
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
					CPrintToChat(client, "" ...MOD_TAG... " Vous n'avez pas d'objet à déposer en banque.");
					DrawBankTransfer(client);
					return;
				}
				
				menu = CreateMenu(DrawBankTransfer_3);
				SetMenuTitle(menu, "Que souhaitez-vous déposer?\nVotre coffre est rempli à %d%%.\n ", RoundToFloor(float(g_iUserData[client][i_ItemBankPrice]) / float(getClientBankLimit(client)) * 100.0));
				
			}
			else if( StrEqual(szMenuItem, "to_inve", false) ) {
				type = 2;
				
				amount = g_iUserData[client][i_ItemBankCount];
				if( amount == 0 ) {
					CPrintToChat(client, "" ...MOD_TAG... " Vous n'avez pas d'objet à récuperer en banque.");
					DrawBankTransfer(client);
					return;
				}
				
				menu = CreateMenu(DrawBankTransfer_3);
				SetMenuTitle(menu, "Que souhaitez-vous récuperer?\nVotre coffre est rempli à %d%%.\n ", RoundToFloor(float(g_iUserData[client][i_ItemBankPrice]) / float(getClientBankLimit(client)) * 100.0));
			}
			else if( StrEqual(szMenuItem, "save", false) ) {
				
				amount = g_iUserData[client][i_ItemCount];
				if( amount == 0 ) {
					CPrintToChat(client, "" ...MOD_TAG... " Vous n'avez pas d'objet à sauvegarder.");
					DrawBankTransfer(client);
					return;
				}
				
				for (int pos=0; pos < amount ; pos++) {
					g_iItems_SAVE[client][pos][STACK_item_amount] = g_iItems[client][pos][STACK_item_amount];
					g_iItems_SAVE[client][pos][STACK_item_id] = g_iItems[client][pos][STACK_item_id];
					CPrintToChat(client, "" ...MOD_TAG... " %i %s ont été sauvegardé.", g_iItems[client][pos][STACK_item_amount], g_szItemList[g_iItems[client][pos][STACK_item_id]][item_type_name]);
				}
				
				g_iUserData[client][i_ItemCountSaved] = amount;
				
				DrawBankTransfer(client);
				CPrintToChat(client, "" ...MOD_TAG... " Vos items préféré ont été sauvegardé.");
				return;
			}
			else if( StrEqual(szMenuItem, "load", false) ) {
				if( g_iUserData[client][i_ItemCountSaved] == 0 ) {
					CPrintToChat(client, "" ...MOD_TAG... " Vous n'avez pas d'objet sauvegardé.");
					DrawBankTransfer(client);
					return;
				}
				
				amount = g_iUserData[client][i_ItemCount];
				for (int pos=0; pos < amount ; pos++) {
					rp_ClientGiveItem(client, g_iItems[client][pos][STACK_item_id], g_iItems[client][pos][STACK_item_amount], true);
					CPrintToChat(client, "" ...MOD_TAG... " %i %s ont été déposé.", g_iItems[client][pos][STACK_item_amount], g_szItemList[g_iItems[client][pos][STACK_item_id]][item_type_name]);
					LogToGame("[TSX-RP] [BANK-ITEM] %L a déposé: %d %s", client, g_iItems[client][pos][STACK_item_amount], g_szItemList[g_iItems[client][pos][STACK_item_id]][item_type_name]);
					g_iItems[client][pos][STACK_item_id] = g_iItems[client][pos][STACK_item_amount] = 0;
				}
				
				g_iUserData[client][i_ItemCount] = 0;
				
				amount = g_iUserData[client][i_ItemCountSaved];
				int inBank;
				for (int pos=0; pos < amount ; pos++) {
					inBank = rp_GetClientItem(client, g_iItems_SAVE[client][pos][STACK_item_id], true);
					if( inBank > g_iItems_SAVE[client][pos][STACK_item_amount] )
						inBank = g_iItems_SAVE[client][pos][STACK_item_amount];
					
					rp_ClientGiveItem(client, g_iItems_SAVE[client][pos][STACK_item_id], -inBank, true);
					rp_ClientGiveItem(client, g_iItems_SAVE[client][pos][STACK_item_id], inBank, false);
					CPrintToChat(client, "" ...MOD_TAG... " %i %s ont été retiré.", inBank, g_szItemList[g_iItems_SAVE[client][pos][STACK_item_id]][item_type_name]);
					
					LogToGame("[TSX-RP] [BANK-ITEM] %L a retiré: %d %s", client,inBank, g_szItemList[g_iItems_SAVE[client][pos][STACK_item_id]][item_type_name]);
				}
				FakeClientCommand(client, "say /item");
				CPrintToChat(client, "" ...MOD_TAG... " Vos items préféré ont été retirés de la banque.");
				
				if( g_iUserData[client][i_LastForcedSave] < GetTime() ) {
					StoreUserData(client);
					g_iUserData[client][i_LastForcedSave] = (GetTime()+5);
				}
				
				updateBankCost(client);
				
				return;
			}
			else if( StrEqual(szMenuItem, "to_resell", false) ) {
				
				char szWeapon[64];
				int id = WeaponsGetDeployedWeaponIndex(client);
				if( id > 0 ) {
					int price = rp_GetWeaponPrice(id);
					GetEdictClassname(id, szWeapon, sizeof(szWeapon));
					
					if( g_iUserData[client][i_Disposed] > 0 && StrContains(szWeapon, "weapon_knife") == -1 && StrContains(szWeapon, "weapon_bayonet") == -1 ) {
						
						Call_StartForward( view_as<Handle>(g_hRPNative[client][RP_OnResellWeapon]) );
						Call_PushCell(client);
						Call_PushCell(id);
						Call_PushCell(price/4);
						Call_Finish();
						
						RemovePlayerItem(client, id );
						RemoveEdict( id );
						
						FakeClientCommand(client, "use weapon_fists");
						
						g_iUserData[client][i_Disposed]--;
						
						SetJobCapital(81, (GetJobCapital(81) + (price/4)));
						
						rp_ClientMoney(client, i_AddToPay, (price/4));
						
						
						LogToGame("[TSX-RP] [RESELL-ARMES] %L a déposé: %s", client, szWeapon);
						ReplaceString(szWeapon, sizeof(szWeapon), "weapon_", "");
						CPrintToChat(client, "" ...MOD_TAG... " Vous avez revendu %s pour %d$.", szWeapon, price);
						
						
						
						DrawBankTransfer(client);
						return;
					}
					else {
						CPrintToChat(client, "" ...MOD_TAG... " Impossible de stocker cette arme.");
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
					SetMenuTitle(menu2, "Trier la banque\n ");
					
					AddMenuItem(menu2, "trier 1", "Par ordre alphabétique");
					AddMenuItem(menu2, "trier 2", "Par ordre alphabétique inversé");
					
					AddMenuItem(menu2, "trier 3", "Par prix croissant");
					AddMenuItem(menu2, "trier 4", "Par prix décroissant");
					
					AddMenuItem(menu2, "trier 5", "Par type");
					AddMenuItem(menu2, "trier 6", "Par type inversé");
					
					AddMenuItem(menu2, "trier 7", "Par job");
					AddMenuItem(menu2, "trier 8", "Par job inversé");
					
					SetMenuPagination(menu2, false); 
					SetMenuExitButton(menu2, true);
					DisplayMenu(menu2, client, MENU_TIME_DURATION);
					return;
				}
				
				ServerCommand("sm_effect_panel %d 2 \"Tri de l'inventaire en cours\"", client);
				
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
					
				
				Format( tmp, sizeof(tmp), "%i_%i", id, type);
				Format( tmp2, sizeof(tmp2), "%s [%i]", g_szItemList[id][item_type_name], cpt);
				
				AddMenuItem(menu, tmp, tmp2);
			}
			
			DisplayMenu(menu, client, MENU_TIME_DURATION);
			
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
		char options[64], tmp[255], tmp2[255], data[2][32];
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
		SetMenuTitle(menu, "Combien souhaitez-vous en transférer?\n ");
		
		Format(tmp, sizeof(tmp), "%i_%i_%i", id, transfer_type, max);
		Format(tmp2, sizeof(tmp2), "Tous %s (%i)", g_szItemList[id][item_type_name], max);
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

		
		if( amount == 1 )
			CPrintToChat(p_iParam1, "" ...MOD_TAG... " %i %s a été transféré.", amount, g_szItemList[id][item_type_name]);
		else
			CPrintToChat(p_iParam1, "" ...MOD_TAG... " %i %s ont été transférés.", amount, g_szItemList[id][item_type_name]);
		
		if( transfer_type == 1 )
			LogToGame("[TSX-RP] [BANK-ITEM] %L a déposé: %d %s", p_iParam1, amount, g_szItemList[id][item_type_name]);
		else
			LogToGame("[TSX-RP] [BANK-ITEM] %L a retiré: %d %s", p_iParam1, amount, g_szItemList[id][item_type_name]);
	
		StoreUserData(p_iParam1);
		DrawBankTransfer(p_iParam1);
	}
	else if (p_oAction == MenuAction_End) {
		CloseHandle(p_hItemMenu);
	}
}