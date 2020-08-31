#if defined _roleplay_menu_weapon_included
#endinput
#endif
#define _roleplay_menu_weapon_included

#if !defined _roleplay_base_included || defined ROLEPLAY_SUB
	#define ROLEPLAY_SUB
	#include "../roleplay.sp"
#else
	#include "roleplay.sp"
#endif

void SelectingAmmunition(int client, int ent, bool crochettage = false) {
	if( !IsEntitiesNear(client, ent, true) ) {
		return;
	}
	
	if( crochettage ) {
		int count = 0;
		for(int i=1; i<MaxClients; i++) {
			if( !IsValidClient(i) )
				continue;
			if( g_bUserData[i][b_IsAFK] )
				continue;
			
			if((GetClientTeam(i) == CS_TEAM_CT && g_iUserData[i][i_Job] >= 1 && g_iUserData[i][i_Job] <= 10 ) || (g_iUserData[i][i_Job] >= 1 && g_iUserData[i][i_Job] <= 7) )
				count++;
		}
		
		if( count <= 0 ) {
			CPrintToChat(client, "" ...MOD_TAG... " Il n'y a pas de policier connecté.");
			return;
		}
	}
	
	int job_tree = g_iUserData[client][i_Job];
	
	if( StringToInt( g_szJobList[ job_tree ][job_type_isboss] ) != 1 ) {
		job_tree = StringToInt( g_szJobList[ job_tree ][job_type_ownboss] );
	}
	
	if( job_tree == 1 && StringToInt(g_szZoneList[GetPlayerZone(client)][zone_type_type]) == 1 ||	/* Un policier dans le commico */
		job_tree == 101 && StringToInt(g_szZoneList[GetPlayerZone(client)][zone_type_type]) == 1 || /* Un GONU dans le commico */
		job_tree == 101 && StringToInt(g_szZoneList[GetPlayerZone(client)][zone_type_type]) == 101 || /* Un gONU dans le Tribunal */
		job_tree == 91 && StringToInt(g_szZoneList[GetPlayerZone(client)][zone_type_type]) == 1 && crochettage  /* Un Mafieu dans le commico */
		) {
		Handle hBuyMenu = CreateMenu(eventAmmunitionPickup);
		SetMenuTitle(hBuyMenu, "Selectionner une arme\n ");
		AddMenuItem(hBuyMenu, "remove", "Supprimer mes armes");
		
		int braquage = GetConVarInt(FindConVar("rp_braquage"));
		int kidnapping = GetConVarInt(FindConVar("rp_kidnapping"));
		
		if( braquage >= 1 || kidnapping >= 1 ) {
			char tmp[128];
			int cpt = 0;
			int owner;
			
			int max = (braquage == 1) ? 3 : 10;
			
			for(int i=MaxClients; i<=2048; i++) {
				if( IsValidEdict(i) && IsValidEntity(i) && rp_GetWeaponBallType(i) == ball_type_braquage && g_iWeaponFromStore[i] ) {
					
					owner = Weapon_GetOwner(i);
					if( IsValidClient(owner) ) {
						if( rp_GetClientJobID(owner)==1 || rp_GetClientJobID(owner)==101 ) {
							cpt++;
						}
					}
					else {
						cpt++;
					}
				}
			}
			if( !crochettage ){
				Format(tmp, sizeof(tmp), "M4A1: Braquage (%d/%d)", cpt, max);
				AddMenuItem(hBuyMenu, "braquage", tmp, cpt>=max? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
			}
		}
		
		for(int lp; lp < MAX_BUYWEAPONS; lp++) {
			if( strlen( g_szBuyWeapons[lp][0] ) == 0 )
				continue;
			
			if( crochettage ) {
				if( Math_GetRandomInt(1, 6000) > StringToInt(g_szBuyWeapons[lp][3]) )
					AddMenuItem(hBuyMenu, g_szBuyWeapons[lp][0], g_szBuyWeapons[lp][1]);
				continue;
			}
			
			if( StrEqual(g_szBuyWeapons[lp][0], "reload") ) {
				AddMenuItem(hBuyMenu, g_szBuyWeapons[lp][0], g_szBuyWeapons[lp][1]);
				continue;
			}
			
			
			
			//
			// S'il est gardien, ou plus:
			if( (rp_GetClientJobID(client) == 1 && g_iUserData[client][i_Job] <= 9) || (rp_GetClientJobID(client) == 101 && g_iUserData[client][i_Job] <= 109) || braquage ) {
				
				if( StrContains(g_szBuyWeapons[lp][0], "weapon_usp") == 0 ||
					StrEqual(g_szBuyWeapons[lp][0], "weapon_m3") ||
					StrEqual(g_szBuyWeapons[lp][0], "weapon_nova")
				) {
					AddMenuItem(hBuyMenu, g_szBuyWeapons[lp][0], g_szBuyWeapons[lp][1]);
					continue;
				}
			}
			// S'il est policier ou plus:
			if( (rp_GetClientJobID(client) == 1 && g_iUserData[client][i_Job] <= 8) || (rp_GetClientJobID(client) == 101 && g_iUserData[client][i_Job] <= 108) || braquage) {
				if( StrEqual(g_szBuyWeapons[lp][0], "weapon_famas" ) ||
					StrEqual(g_szBuyWeapons[lp][0], "weapon_mp5sd" )					
				) {
					AddMenuItem(hBuyMenu, g_szBuyWeapons[lp][0], g_szBuyWeapons[lp][1]);
					continue;
				}
			}
			// S'il est FBI ou plus:
			if( (rp_GetClientJobID(client) == 1 && g_iUserData[client][i_Job] <= 7) || (rp_GetClientJobID(client) == 101 && g_iUserData[client][i_Job] <= 107) || braquage) {
				if( StrContains(g_szBuyWeapons[lp][0], "weapon_m4a1" ) == 0 ||
					StrEqual(g_szBuyWeapons[lp][0], "weapon_ssg08")
				) {
					AddMenuItem(hBuyMenu, g_szBuyWeapons[lp][0], g_szBuyWeapons[lp][1]);
					continue;
				}
			}
			// S'il est CIA ou plus:
			if( g_iUserData[client][i_Job] <= 6 || g_iUserData[client][i_Job] == 101  || g_iUserData[client][i_Job] == 102 || braquage) {
				if( StrEqual(g_szBuyWeapons[lp][0], "weapon_awp")  ||
					StrEqual(g_szBuyWeapons[lp][0], "weapon_aug") ||
					StrEqual(g_szBuyWeapons[lp][0], "weapon_sg556")
				) {
					AddMenuItem(hBuyMenu, g_szBuyWeapons[lp][0], g_szBuyWeapons[lp][1]);
					continue;
				}
			}
			// S'il est GTI ou plus:
			if( g_iUserData[client][i_Job] <= 5 || g_iUserData[client][i_Job] == 101  || g_iUserData[client][i_Job] == 102 || braquage) {
				AddMenuItem(hBuyMenu, g_szBuyWeapons[lp][0], g_szBuyWeapons[lp][1]);
				continue;
			}
			
		}	
		
		SetMenuExitButton(hBuyMenu, true);
		DisplayMenu(hBuyMenu, client, MENU_TIME_DURATION);
	}
	
	return;
}

public int eventAmmunitionPickup(Handle p_hBuyMenu, MenuAction p_oAction, int client, int p_iParam2) {
	if (p_oAction == MenuAction_Select) {
		char szMenuItem[32];
		char explo[2][32];

		if (GetMenuItem(p_hBuyMenu, p_iParam2, szMenuItem, sizeof(szMenuItem))) {
			
			ExplodeString(szMenuItem, " ", explo, sizeof(explo), sizeof(explo[]));
			
			int ent = GetClientAimTarget(client, false);
			if( !IsAmmunition(ent) )
				return;
			if( !IsPlayerAlive(client) )
				return;
			
			int iWeaponSlot;
			
			for(int lp; lp < MAX_BUYWEAPONS; lp++) {
				if (strcmp(g_szBuyWeapons[lp][0], szMenuItem) == 0) {
					iWeaponSlot = StringToInt(g_szBuyWeapons[lp][2]);
					break;
				}
			}
			
			if( StrEqual(explo[0], "reload", false) ) {
				RedrawWeapon(client);
			}
			else if( StrEqual(explo[0], "braquage", false) ) {
				
				int wepid = GivePlayerItem(client, "weapon_m4a1");
				FakeClientCommand(client, "use weapon_m4a1");
				Weapon_SetPrimaryClip(wepid, 5000);
				rp_SetWeaponBallType(wepid, ball_type_braquage);
				g_iWeaponFromStore[wepid] = 1;
				
			}
			else if( StrEqual(explo[0], "remove", false) ) {
				int id = WeaponsGetDeployedWeaponIndex(client);
				if( id > 0 ) {
					RemovePlayerItem(client, id );
					RemoveEdict( id );
					
					FakeClientCommand(client, "use weapon_fists");
					g_bUserData[client][b_WeaponIsKnife] = false;
					g_bUserData[client][b_WeaponIsHands] = true;
				}
			}
			else {
				
				if( GetPlayerWeaponSlot( client, iWeaponSlot) != -1 ) {
					CPrintToChat(client, "" ...MOD_TAG... " Vous avez déjà une arme de ce type");
					return;
				}
				
				int id = GivePlayerItem(client, explo[0]);
				g_iWeaponFromStore[id] = 1;
				if( StrContains(explo[1], "caouchouc", false) >= 0) {
					g_iWeaponsBallType[id] = ball_type_caoutchouc;
				}
			}
		}
	}
	else if (p_oAction == MenuAction_End) {
		CloseHandle(p_hBuyMenu);
	}
}
