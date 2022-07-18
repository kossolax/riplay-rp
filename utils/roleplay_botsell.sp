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
#include <basecomm>

#pragma newdecls required
#include <roleplay.inc>	// https://www.ts-x.eu

public Plugin myinfo = {
	name = "Utils: Bot Sell", author = "KoSSoLaX, Messorem",
	description = "RolePlay - Utils: Bot sell",
	version = __LAST_REV__, url = "https://riplay.fr"
};
public Action Cmd_Reload(int args) {
	char name[64];
	GetPluginFilename(INVALID_HANDLE, name, sizeof(name));
	ServerCommand("sm plugins reload %s", name);
	return Plugin_Continue;
}
public void OnPluginStart() {	
	LoadTranslations("core.phrases");
	LoadTranslations("roleplay.phrases");
	
	RegServerCmd("rp_quest_reload", Cmd_Reload);
	
	for (int i = 1; i <= MaxClients; i++)
		if( IsValidClient(i) )
			OnClientPostAdminCheck(i);
}
public void OnClientPostAdminCheck(int client) {
	rp_HookEvent(client, RP_OnPlayerUse, fwdPlayerUse);
}
public Action fwdPlayerUse(int client) {
	
	if( IsInValidZone(client) && IsNearBot(client) ) {
		openSellMenu(client);
	}
	
	return Plugin_Continue;
}

bool IsNearBot(int client) {
	char name[128];
	static bool WasNear[MAXPLAYERS];
	static float NextCheck[MAXPLAYERS];
	
	if( NextCheck[client] > GetGameTime() )
		return WasNear[client];
	
	for(int i=0; i<MAX_ENTITIES; i++) {
		if( !IsValidEdict(i) || !IsValidEntity(i) )
			continue; 
		
		GetEdictClassname(i, name, sizeof(name));
		if( StrEqual(name, "rp_bot") && Entity_GetDistance(client, i) < 128.0 ) {
			
			WasNear[client] = true;
			NextCheck[client] = GetGameTime() + 0.5;
			return WasNear[client];
		}
	}
	
	WasNear[client] = false;
	NextCheck[client] = GetGameTime() + 0.5;
	return WasNear[client];
}

bool IsInValidZone(int client) {
	int validZone[] = { 31, 51, 81, 211, 11, 14, 111, 114, 115 };
	int jobZone = rp_GetZoneInt(rp_GetPlayerZone(client), zone_type_type);
	
	for(int i=0; i<sizeof(validZone); i++) {
		if( validZone[i] == jobZone ) {
			return true;
		}
	}
	
	return false;
}

void openSellMenu(int client) {
	if( !IsInValidZone(client) )
		return;
	
	int jobZone = rp_GetZoneInt(rp_GetPlayerZone(client), zone_type_type);
	char name[128], key[8], price[64];
	
	Menu menu = CreateMenu(onMenuOpen);
	menu.SetTitle("Bienvenue!\n ");
	
	if (validZone != 81){
		for(int i=0; i<MAX_ITEMS; i++) {
			//if( jobZone == rp_GetItemInt(i, item_type_job_id) && rp_GetItemInt(i, item_type_auto) == 0 ) {
			if( jobZone == rp_GetItemInt(i, item_type_job_id) && rp_GetItemInt(i, item_type_prix) ) {

				IntToString(i, key, sizeof(key));
				rp_GetItemData(i, item_type_name, name, sizeof(name));
				rp_GetItemData(i, item_type_prix, price, sizeof(price));
				menu.AddItem(key, name);
			}
		}
	}
	else if (validZone == 81){
	
		if( rp_GetClientJobID(client) == 81 && g_iUserData[client][i_Disposed] > 0 ) {
		Format(tmp, sizeof(tmp), "%T", "DrawBankTransfer_to_resell", client);
		AddMenuItem(menu, "to_resell", tmp);
	}
	
	}
	
	menu.Display(client, MENU_TIME_FOREVER);
}
public int onMenuOpen(Handle hItem, MenuAction oAction, int client, int param) {
	if (oAction == MenuAction_Select) {
		char options[128];
		GetMenuItem(hItem, param, options, sizeof(options));
		int item_id = StringToInt(options);
		int price = rp_GetItemInt(item_id, item_type_prix);
		
		
		
		if( !IsInValidZone(client) || !IsNearBot(client) ) {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Cmd_TargetIsToFar", client);
			return;
		}
		
		if( (rp_GetClientBool(client, b_HaveCard) == true  && rp_GetClientInt(client, i_Bank)  > price) ||
			(rp_GetClientBool(client, b_HaveCard) == false && rp_GetClientInt(client, i_Money) > price)	) {
			
			rp_ClientMoney(client, i_Money, -price);
			rp_ClientGiveItem(client, item_id, 1, false);
			
			char name[128];
			rp_GetItemData(item_id, item_type_name, name, sizeof(name));
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Item_Give", client, 1, name);
			
			openSellMenu(client);
		}
		else {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_NotEnoughtMoney", client);
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
	else if (oAction == MenuAction_End ) {
		CloseHandle(hItem);
	}
}
