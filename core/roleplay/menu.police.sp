#if defined _roleplay_menu_police_included
#endinput
#endif
#define _roleplay_menu_police_included

#if !defined _roleplay_base_included || defined ROLEPLAY_SUB
	#define ROLEPLAY_SUB
	#include "../roleplay.sp"
#else
	#include "roleplay.sp"
#endif

public int MenuTribunal_plainte(Handle p_hItemMenu, MenuAction p_oAction, int client, int p_iParam2) {
	if( p_oAction == MenuAction_Select && client != 0) {
		char targetSteamID[64], url[256];
		GetMenuItem(p_hItemMenu, p_iParam2, targetSteamID, 64);
			
		Format(url, sizeof(url), "https://rpweb.riplay.fr/index.php#/tribunal/report?%s", targetSteamID);
		RP_ShowMOTD(client, url);
	}
	else if( p_oAction == MenuAction_End ) {		
		CloseHandle(p_hItemMenu);
	}
}
public int MenuTribunal_report(Handle p_hItemMenu, MenuAction p_oAction, int client, int p_iParam2) {
	if( p_oAction == MenuAction_Select && client != 0) {
		char targetSteamID[64], url[256];
		GetMenuItem(p_hItemMenu, p_iParam2, targetSteamID, 64);
			
		Format(url, sizeof(url), "https://rpweb.riplay.fr/index.php#/tribunal/report?%s", targetSteamID);
		RP_ShowMOTD(client, url);
	}
	else if( p_oAction == MenuAction_End ) {		
		CloseHandle(p_hItemMenu);
	}
}
void ReduceJailTime(int client) {
	if(g_bUserData[client][b_ExitJailMenu]) {
		return;
	}

	int amende = 2500, reduction = 12;
	if (g_iUserData[client][i_JailTime] < (18 * 60)) { amende /= 2; reduction /= 2; }
				
	amendeCalculation(client, amende);
	
	int zone = GetPlayerZone(client);
	
	if( g_iUserData[client][i_JailTime] <= (12*60) )
		return;
	if( !(GetZoneBit(zone) & BITZONE_JAIL) )
		return;
	if( (GetZoneBit(zone) & BITZONE_LACOURS) )
		return;

	// Setup menu
	Handle menu = CreateMenu(eventPayForLeaving_2);
	char tmp[256];

	if(g_bUserData[client][b_IsFreekiller] == true) {
		Format(tmp, 255, "%sVotre comportement est inapproprié sur le serveur suite à vos récentes actions.\nVous devez OBLIGATOIREMENT purger votre peine\n\n ", tmp);
	}

	Format(tmp, 255, "%sVous êtes en prison pour encore %.1f heures\n\n ", tmp, (float(g_iUserData[client][i_JailTime])/60.0));
	// Format(tmp, 255, "%sVous pouvez réduire ce temps de %d heures\nà tout moment pour %i$\n\n ", tmp, reduction, amende);

	SetMenuTitle(menu, tmp);

	AddMenuItem(menu, "", "Vous pouvez réouvrir ce menu avec /peine", ITEMDRAW_DISABLED);
	AddMenuItem(menu, "", "En QHS votre temps passe 2x plus vite mais vous ne pouvez pas y afk", ITEMDRAW_DISABLED);

	AddMenuItem(menu, "cours", "Envoyez moi dans la cour");

	int qhsPrice = 50 * rp_GetClientInt(client, i_KillJailDuration);

	if( g_iUserData[client][i_Money]+g_iUserData[client][i_Bank] >= qhsPrice ) {
		Format(tmp, 255, "Envoyer moi au QHS (%i$)", qhsPrice);
		AddMenuItem(menu, "qhs", tmp);
	}

	AddMenuItem(menu, "exit", "Ne rien faire");
	
	SetMenuExitButton(menu, false);
	
	DisplayMenu(menu, client, 1);
}
public int eventPayForLeaving_2(Handle menu, MenuAction action, int iTarget, int param2) {
	if( action == MenuAction_Select ) {
		char options[64];
		GetMenuItem(menu, param2, options, 63);
		
		if( StrEqual(options, "yes", false) ) {
			
			if( g_iUserData[iTarget][i_JailTime] > (12*60) ) {
				
				int amende = 2500, reduction = 12;
				if (g_iUserData[iTarget][i_JailTime] < (18 * 60)) { amende /= 2; reduction /= 2; }
				
				amendeCalculation(iTarget, amende);
				
				if( g_iUserData[iTarget][i_Money]+g_iUserData[iTarget][i_Bank] < amende ) {
					return;
				}
				rp_ClientMoney(iTarget, i_Money, -amende);
				
				if( IsValidClient(g_iUserData[iTarget][i_JailledBy]) ) {
					rp_ClientMoney(g_iUserData[iTarget][i_JailledBy], i_AddToPay, amende / 4);
					
					int client = g_iUserData[iTarget][i_JailledBy];
					if( IsValidClient(client) ) {
						char SteamID[64], SteamID2[64];
						GetClientAuthId(client, AUTH_TYPE, SteamID, sizeof(SteamID), false);
						GetClientAuthId(iTarget, AUTH_TYPE, SteamID2, sizeof(SteamID2), false);
						
						char szQuery[1024];
						Format(szQuery, sizeof(szQuery), "INSERT INTO `rp_sell` (`id`, `steamid`, `job_id`, `timestamp`, `item_type`, `item_id`, `item_name`, `amount`, `to_steamid`) VALUES (NULL, '%s', '%i', '%i', '4', '%i', '%s', '%i', '%s');",
						SteamID, GetJobPrimaryID(client), GetTime(), 0, "Caution", amende/4, SteamID2);
						SQL_TQuery(g_hBDD, SQL_QueryCallBack, szQuery);
						addToGroup(client, amende/4);
						SetJobCapital(g_iUserData[iTarget][i_JailledBy], GetJobCapital(g_iUserData[iTarget][i_JailledBy]) + (amende/4)*3 );
						
						rp_ClientMoney(client, i_AddToPay, amende / 4);
					}
					
					LogToGame("[JAIL] [CAUTION] %L a payé %d$ pour réduire sa jail de %d heures", iTarget, amende, reduction);
					
					if( IsPolice(g_iUserData[iTarget][i_JailledBy]) ) {
						SetJobCapital(1, GetJobCapital(1) + (amende/4)*3 );
					}
					if( IsJuge(g_iUserData[iTarget][i_JailledBy]) ) {
						SetJobCapital(101, GetJobCapital(101) + (amende/4)*3 );
					}
					else if( Math_GetRandomInt(1, 2) == 1 ) {
						SetJobCapital(1, GetJobCapital(1) + (amende/4)*3 );
					}
					else {
						SetJobCapital(101, GetJobCapital(101) + (amende/4)*3 );
					}
				}
				else {
					
					if( Math_GetRandomInt(1, 2) == 1 ) {
						SetJobCapital(1, GetJobCapital(1) + amende );
					}
					else {
						SetJobCapital(101, GetJobCapital(101) + amende );
					}
				}
				
				g_iUserData[iTarget][i_JailTime] -= (reduction*60);
			}
		}
		if( StrEqual(options, "exit", false) ) {
			g_bUserData[iTarget][b_ExitJailMenu] = true;
		}
		if( StrEqual(options, "cours", false) ) {
			if( g_iUserData[iTarget][i_JailTime] > (12*60) ) {
				int MaxJail = 0;
				float fLocation[MAX_LOCATIONS][3];
				
				int i = 0;
				for( i=1; i<MAX_LOCATIONS; i++ ) {
					if( StrEqual(g_szLocationList[i][location_type_base], "cours", false) ) {
						fLocation[MaxJail] = g_flPoints[i];
						MaxJail++;
					}
				}
				int rand = Math_GetRandomInt(0, (MaxJail-1));
				
				fLocation[rand][2] += 10.0;
				FORCE_Release(iTarget);
				TeleportClient(iTarget, fLocation[rand], NULL_VECTOR, NULL_VECTOR);
			}
		}
		if( StrEqual(options, "qhs", false) ) {
			int qhsPrice = 100 * rp_GetClientInt(iTarget, i_KillJailDuration);

			if( g_iUserData[iTarget][i_JailTime] > (12*60) && (g_iUserData[iTarget][i_Money]+g_iUserData[iTarget][i_Bank] >= qhsPrice) ) {
				
				bool bLocation[MAX_ZONES+1];
				
				for( int i=1; i<=MaxClients; i++ ) {
					if( !IsValidClient(i) )
						continue;
					
					int zone = GetPlayerZone(i);
					if( StringToInt(g_szZoneList[zone][zone_type_bit]) & BITZONE_HAUTESECU ) {
						bLocation[zone] = true;
					}
				}
				int i = 0;
				for( i=1; i<MAX_ZONES; i++ ) {
					if( strlen(g_szZoneList[i][zone_type_name]) <= 1 )
						continue;
					if( bLocation[i] )
						continue;
					
					if( StringToInt(g_szZoneList[i][zone_type_bit]) & BITZONE_HAUTESECU ) {
						float fLocation[2][3];
						
						fLocation[0][0] = StringToFloat(g_szZoneList[i][zone_type_min_x]);
						fLocation[0][1] = StringToFloat(g_szZoneList[i][zone_type_min_y]);
						fLocation[0][2] = StringToFloat(g_szZoneList[i][zone_type_min_z]);
						
						fLocation[1][0] = StringToFloat(g_szZoneList[i][zone_type_max_x]);
						fLocation[1][1] = StringToFloat(g_szZoneList[i][zone_type_max_y]);
						fLocation[1][2] = StringToFloat(g_szZoneList[i][zone_type_min_z]);
						
						fLocation[0][0] = (fLocation[0][0]+fLocation[1][0])/2.0;
						fLocation[0][1] = (fLocation[0][1]+fLocation[1][1])/2.0;
						fLocation[0][2] += 20.0;
						
						
						FORCE_Release(iTarget);
						TeleportClient(iTarget, fLocation[0], NULL_VECTOR, NULL_VECTOR);
						
						for(int j=MaxClients; j<MAX_ENTITIES; j++ ) {
							if( !IsValidDoor(j) )
								continue;
							if( GetPlayerZone(j) != i )
								continue;
							rp_AcceptEntityInput(j, "Close");
							ScheduleEntityInput(j, 0.1, "Lock");
							
						}
						
						rp_ClientMoney(iTarget, i_Money, -qhsPrice);
						SetJobCapital(1, (GetJobCapital(1) + qhsPrice));
						return;
					}
				}
				CPrintToChat(iTarget, "" ...MOD_TAG... " Il n'y a plus de place disponible en QHS.");
			}
		}
	}
	else if( action == MenuAction_End ) {
		CloseHandle(menu);
	}
}

void amendeCalculation(int client, int& amende) {
	float ratio = float(g_iUserData[client][i_Kill31Days]+1) / float(g_iUserData[client][i_Death31Days]+1);
	if( ratio < 0.25 )
		ratio = 0.25;
	
	amende =  RoundFloat(float(amende) * ratio);
}
