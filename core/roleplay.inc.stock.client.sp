#if defined _roleplay_stock_client_included
#endinput
#endif
#define _roleplay_stock_client_included

#if defined ROLEPLAY_SUB
	#include "../roleplay.sp"
#else
	#include "roleplay.sp"
#endif

int getClientBankLimit(int client) {
	int val = ITEM_BANK_LIMIT;
	
	if( g_iUserData[client][i_PlayerLVL] >= 240 )
		val *= 2;
	
	if( g_iUserData[client][i_PlayerPrestige] >= 1 )
		val *= RoundFloat(Pow(2.0, float(g_iUserData[client][i_PlayerPrestige])));
	
	return val;
}
public Action TIMER_ReduceGiveAmount(Handle timer, Handle dp) {
	ResetPack(dp);
	int client = ReadPackCell(dp);
	int amount = ReadPackCell(dp);
	g_iUserData[client][i_GiveAmountTime] -= amount;
	if( g_iUserData[client][i_GiveAmountTime] < 0 )
		g_iUserData[client][i_GiveAmountTime] = 0;
	
}
void DeathDrop(int Client) {
	if( Math_GetRandomInt(1, 100) == 17 ) {
		float vecOrigin[3];
		GetClientAbsOrigin(Client, vecOrigin);
		vecOrigin[2] += 10.0;
		
		int rand = Math_GetRandomInt(1, 100);
		if( rand >= 1 && rand < 70 ) {
			
			SpawnMoney(vecOrigin, true);
			CPrintToChat(Client, "" ...MOD_TAG... " Vous avez fait tomber votre porte-feuille.");
			rp_ClientMoney(Client, i_Money, -Math_GetRandomInt(20, 50));
		}
		else if( rand >= 71 && rand < 86 ) {
			
			SpawnMoney(vecOrigin, true);
			rp_ClientMoney(Client, i_Money, -Math_GetRandomInt(20, 50));

			if( g_bUserData[Client][b_HaveCard] == 1 ) {
				g_bUserData[Client][b_HaveCard] = 0;
				CPrintToChat(Client, "" ...MOD_TAG... " Vous avez fait tomber votre porte-feuille, et vous avez perdu votre carte bancaire...");
			}
			else {
				CPrintToChat(Client, "" ...MOD_TAG... " Vous avez fait tomber votre porte-feuille.");
			}
		}
		else if( rand >= 86 && rand < 101 ) {
			if( strlen(g_szUserData[Client][sz_Skin]) > 2 ) {
				Format(g_szUserData[Client][sz_Skin], sizeof(g_szUserData[][]), "");
				CPrintToChat(Client, "" ...MOD_TAG... " Vos vêtements sont devenus inutilisable...");
			}
			else {
				
				SpawnMoney(vecOrigin, true);
				CPrintToChat(Client, "" ...MOD_TAG... " Vous avez fait tomber votre porte-feuille.");
				rp_ClientMoney(Client, i_Money, -Math_GetRandomInt(20, 50));
			}
		}
		else {
			
			SpawnMoney(vecOrigin, true);
			CPrintToChat(Client, "" ...MOD_TAG... " Vous avez fait tomber votre porte-feuille.");
			rp_ClientMoney(Client, i_Money, -Math_GetRandomInt(20, 50));
		}
	}
}

void KillStack_Add(int client, int target) {
	for (int i = 0; i < g_iStackCanKill_Count[client]; i++)
		if( g_iStackCanKill[client][i] == target )
			return;
	
	g_iStackCanKill[client][g_iStackCanKill_Count[client]++] = target;
}
void KillStack_Remove(int client, int target) {
	int pos = -1;
	int max = g_iStackCanKill_Count[client];
	
	for (int i = 0; i < max; i++) {
		if( g_iStackCanKill[client][i] == target ) {
			pos = i;
			break;
		}
	}
	
	if( pos == -1 )
		return;
	
	for (; pos < max ; pos++) {
		g_iStackCanKill[client][pos] = g_iStackCanKill[client][pos + 1];
	}
	
	g_iStackCanKill_Count[client]--;
}
void KillStack_Timer(int client, int time) {
	for (int i = 0; i < g_iStackCanKill_Count[client]; i++) {
		if( g_iKillLegitime[client][ g_iStackCanKill[client][i] ] > time && IsValidClient(g_iStackCanKill[client][i]) ) {
			TE_SetupParticle("headskull", g_iStackCanKill[client][i], "facemask");
			TE_SendToClient(client, float(i)/10.0);
		}
		else {
			KillStack_Remove(client, g_iStackCanKill[client][i]);
			i--;
		}
	}
}

void updateClanTag(int client) {
	static char ClanTag[16];
	
	Format(ClanTag, sizeof(ClanTag), "%s", g_szJobList[ g_iUserData[client][i_Job] ][job_type_tag]);
	if( g_iUserData[client][i_Job] >= 1 && g_iUserData[client][i_Job] <= 10 ) {
		if( GetClientTeam(client) != CS_TEAM_CT ) {
			if(g_iUserData[client][i_KillJailDuration] > 1) {
				Format(ClanTag, sizeof(ClanTag), "Criminel");
			} else {
				Format(ClanTag, sizeof(ClanTag), "Gendarmerie");
			}
		}
	}	
	if( g_iUserData[client][i_JailTime] > 0 ) {
		Format(ClanTag, sizeof(ClanTag), "En prison");
	}
	else if( g_bUserData[client][b_IsAFK] ) {
		Format(ClanTag, sizeof(ClanTag), "AFK");
	}
	else if( !IsTutorialOver(client) ) {
		Format(ClanTag, sizeof(ClanTag), "TUTORIAL");
	}

	ServerCommand("sm_force_clantag %i \"%s\"", client, ClanTag);
}

public Action SendToGrave(Handle timer, any client) {
	if( !g_bUserData[client][b_SpawnToGrave] )
		return;
	if( !g_bUserData[client][b_HasGrave] )
		return;
	if( g_iUserData[client][i_JailTime] > 0 )
		return;
	
	
	char classname[64];
	Format(classname, sizeof(classname), "rp_grave");
	char tmp[64];
	
	float vecOrigin[3], vecAngles[3];
	
	for(int i=1; i<=2048; i++) {
		if( !IsValidEdict(i) )
			continue;
		if( !IsValidEntity(i) )
			continue;
		
		GetEdictClassname(i, tmp, sizeof(tmp));
	
		if( StrEqual(classname, tmp) && rp_GetBuildingData(i, BD_owner) == client  ) {
			Entity_GetAbsOrigin(i, vecOrigin);
			Entity_GetAbsAngles(i, vecAngles);
			vecOrigin[2] += 5.0;
			TeleportClient(client, vecOrigin, vecAngles, NULL_VECTOR);			
			
			if( IsInPVP(i) )
				GroupColor(client);
			else
				Colorize(client, 255, 255, 255, 255);
			return;
		}
	}
	g_bUserData[client][b_HasGrave] = false;
}
public Action SendToMetro(Handle timer, any client) {
	
	int Max = 0;
	int iLocation[MAX_LOCATIONS];
	int i = 0;
		
	for( i=0; i<MAX_LOCATIONS; i++ ) {
		if( StrContains(g_szLocationList[i][location_type_base], "metro", false) == -1 )
			continue;
		if( StrContains(g_szLocationList[i][location_type_base], "metro_event", false) == 0 )
			continue;
		if( StrContains(g_szLocationList[i][location_type_base], "metro_tour", false) == 0 )
			continue;
		if( StrContains(g_szLocationList[i][location_type_base], "metro_villa", false) == 0 )
			continue;
		
		iLocation[Max] = i;
		Max++;
		
	}
	i = iLocation[ Math_GetRandomInt(0, (Max-1))];
	
	
	TeleportClient(client, g_flPoints[i], NULL_VECTOR, NULL_VECTOR);
	g_bUserData[client][b_SpawnToMetro] = false;
}
public Action AllowUltimate(Handle timer, any client) {

	g_bUserData[client][b_MayUseUltimate] = true;
}
public Action AllowBuild(Handle timer, any client) {

	g_bUserData[client][b_MayBuild] = true;
}
void showPlayerHintBox(int client, int target) {
	static char clientname[64], clientname2[64], classname[64];
	
	if( target <= 0 )
		return;
	
	Action a;
	Call_StartForward( view_as<Handle>(g_hRPNative[client][RP_OnPlayerHINT]));
	Call_PushCell(client);
	Call_PushCell(target);
	Call_Finish(a);
		
	if( a == Plugin_Handled || a == Plugin_Stop )
		return;
	
	GetEdictClassname(target, classname, sizeof(classname));
	
	
	if( IsValidClient( target ) ) {
		
		if( IsValidClient( g_iUserData[target][i_FakeClient] ) )
			target = g_iUserData[target][i_FakeClient];
		
		char szJail[128];
		PrintJail(target, szJail, sizeof(szJail));
		
		GetClientName(target, clientname2, sizeof(clientname2));
		strcopy(clientname, 20, clientname2);
		
		if( g_bUserData[target][b_CAPSLOCK] )  {
			String_ToLower(clientname, clientname, strlen(clientname));
		}
		
		ReplaceString(clientname, sizeof(clientname), "<3", "");
		ReplaceString(clientname, sizeof(clientname), "<", "");
		ReplaceString(clientname, sizeof(clientname), ">", "");
		
		if( EVENT_HIDE == 1 ) {
			return;
		}
		if( g_iClient_OLD[target] ) {
			PrintHintText(client, "%s%s</font>[HP: %i]%s\nJob: %s", g_bUserData[target][b_GameModePassive] ? "<font color='#00cc00'>" : "<font color='#cc0000'>", clientname, (GetClientHealth(target)), szJail, g_szJobList[g_iUserData[target][i_Job]][job_type_name]);
		}
		else {
			
			int flags = GetUserFlagBits(client);
			if (flags & ADMFLAG_GENERIC || flags & ADMFLAG_ROOT ||
				(GetJobPrimaryID(client) == g_iUserData[client][i_Job] && g_iUserData[client][i_Job] > 0 && g_iUserData[target][i_Job] == 0 ) ||
				IsJuge(client) || IsPolice(client) ) {
				PrintHintText(client, "%s%s</font>[HP: %i]%s\n*NEW*Job: %s", g_bUserData[target][b_GameModePassive] ? "<font color='#00cc00'>" : "<font color='#cc0000'>", clientname, (GetClientHealth(target)), szJail, g_szJobList[g_iUserData[target][i_Job]][job_type_name]);
			}
			else {
				PrintHintText(client, "%s%s</font>[HP: %i]%s\nJob: %s", g_bUserData[target][b_GameModePassive] ? "<font color='#00cc00'>" : "<font color='#cc0000'>", clientname, (GetClientHealth(target)), szJail, g_szJobList[g_iUserData[target][i_Job]][job_type_name]);
			}
		}
		
		if( IsJuge(target)) {
			if( GetClientTeam(target) != CS_TEAM_CT ) {
				PrintHintText(client, "%s%s</font>[HP: %i]%s\nJob: %s", g_bUserData[target][b_GameModePassive] ? "<font color='#00cc00'>" : "<font color='#cc0000'>", clientname, (GetClientHealth(target)), szJail, g_szJobList[0][job_type_name]);
			}
		}

		if(IsPolice(target)) {
			if( GetClientTeam(target) != CS_TEAM_CT ) {
				if(g_iUserData[target][i_KillJailDuration] > 1) {
					PrintHintText(client, "%s%s</font>[HP: %i]%s\nJob: Criminel", g_bUserData[target][b_GameModePassive] ? "<font color='#00cc00'>" : "<font color='#cc0000'>", clientname, (GetClientHealth(target)), szJail);
				} else {
					PrintHintText(client, "%s%s</font>[HP: %i]%s\nJob: Gendarmerie", g_bUserData[target][b_GameModePassive] ? "<font color='#00cc00'>" : "<font color='#cc0000'>", clientname, (GetClientHealth(target)), szJail);
				}
			}
		}
	}
	else if( IsValidClient(rp_GetBuildingData(target, BD_owner)) ) {
		
		int target2 = rp_GetBuildingData(target, BD_owner);
		
		GetClientName(target2, clientname2, sizeof(clientname2));
		strcopy(clientname, 20, clientname2);
		
		if( g_bUserData[target2][b_CAPSLOCK] )  {
			String_ToLower(clientname, clientname, strlen(clientname));
		}
		
		ReplaceString(clientname, sizeof(clientname), "<3", "");
		ReplaceString(clientname, sizeof(clientname), "<", "");
		ReplaceString(clientname, sizeof(clientname), ">", "");
		
		PrintHintText(client, "Props de %s\nHP: %d", clientname, Entity_GetHealth(target));
	}
	else if( StrContains(classname, "vehicle") >= 0 && IsValidClient(g_iVehicleData[target][car_owner]) ) {
		
		int target2 = g_iVehicleData[target][car_owner];
		
		GetClientName(target2, clientname2, sizeof(clientname2));
		strcopy(clientname, 20, clientname2);
		
		if( g_bUserData[target2][b_CAPSLOCK] )  {
			String_ToLower(clientname, clientname, strlen(clientname));
		}
		
		ReplaceString(clientname, sizeof(clientname), "<3", "");
		ReplaceString(clientname, sizeof(clientname), "<", "");
		ReplaceString(clientname, sizeof(clientname), ">", "");
		
		int target3 = GetEntPropEnt(target, Prop_Send, "m_hPlayer");
		char fmt[128];
		if( IsValidClient(target3) ) {
			Format(fmt, sizeof(fmt), "\n%N conduit.", target3);
		}
		
		PrintHintText(client, "Voiture de %s\nHP: %d%s", clientname, rp_GetVehicleInt(target, car_health), fmt);
	}
	else if( StrContains(classname, "door") >= 0 ) {
		int appart = getDoorAppart(target);
		if( appart >= 0 ) {
			int owner = g_iAppartBonus[appart][appart_proprio];
			if( IsValidClient(owner) ) {
				
				GetClientName(owner, clientname2, sizeof(clientname2));
				strcopy(clientname, 20, clientname2);
				
				if( g_bUserData[owner][b_CAPSLOCK] )  {
					String_ToLower(clientname, clientname, strlen(clientname));
				}
				
				ReplaceString(clientname, sizeof(clientname), "<3", "");
				ReplaceString(clientname, sizeof(clientname), "<", "");
				ReplaceString(clientname, sizeof(clientname), ">", "");
				
				PrintHintText(client, "%s de:\n %s", (appart<100?"Appartement":"Garage"), clientname);
			}
			else if( appart == 50 ) {
				rp_GetServerString(villaOwnerName, clientname, sizeof(clientname));
				PrintHintText(client, "Villa de: %s", clientname);
			}
			else if( appart == 51 ) {
				rp_GetServerString(maireName, clientname, sizeof(clientname));
				PrintHintText(client, "Villa de: %s", clientname);
			}
			else {
				PrintHintText(client, "%s %d à louer\nPrix: %s$", (appart<100?"Appartement":"Garage"), appart, g_szSellingKeys[appart][key_type_prix]);
			}
		}
		else {
			char expl[4][64];
			rp_GetZoneData(rp_GetPlayerZone(target), zone_type_name, clientname, sizeof(clientname));
			ExplodeString(clientname, " - ", expl, sizeof(expl), sizeof(expl[]));
			ExplodeString(expl[0], ":", expl, sizeof(expl), sizeof(expl[]));
			strcopy(clientname, sizeof(clientname), expl[0]);
			
			classname[0] = clientname2[0] = 0;			
			if( Entity_GetDistance(client, target) < 512.0 ) {
				Format(clientname2, sizeof(clientname2), "<font color='#%s</font>,", GetEntProp(target, Prop_Data, "m_bLocked") ? "FF0000'>Fermée" : "00FF00'>Ouverte");			
				if( rp_GetDoorID(target) > 0 )
					Format(classname, sizeof(classname), "<font color='#%s</font>.", rp_GetClientKeyDoor(client, rp_GetDoorID(target)) ? "00FF00'> vous avez les clés" : "FF0000'> vous n'avez pas les clés" );
			}
				
			PrintHintText(client, "Porte: %s\n %s%s", clientname, clientname2, classname);
		}
	}
	else if( StrContains(classname, "bank") >= 0 ) {
		PrintHintText(client, "\n Distributeur de billet");
	}
	else if( StrContains(classname, "phone") >= 0 ) {
		PrintHintText(client, "\n Téléphone public");
	}
}

public Action StopFreeze(Handle timer, any client) {
	if( IsValidClient(client) ) {
		if( GetEntityMoveType(client) != MOVETYPE_NOCLIP )
			SetEntityMoveType(client, MOVETYPE_WALK);
	}
}
int SendPlayerToSpawn(int Client, bool near = false) {
	if( !near && GetClientTeam(Client) != CS_TEAM_T )
		return;
	
	float MinHull[3], MaxHull[3], PlayerOrigin[3];
	float fDist = FLT_MAX;
	bool found = false;
	GetEntPropVector(Client, Prop_Send, "m_vecMins", MinHull);
	GetEntPropVector(Client, Prop_Send, "m_vecMaxs", MaxHull);
	GetClientAbsOrigin(Client, PlayerOrigin);
	
	int Max = 0;
	float fLocation[MAX_LOCATIONS][3];
	int i = 0;
	
	if( near ) {
		Max = 1;
		for( i=0; i<MAX_LOCATIONS; i++ ) {
			if( StrEqual(g_szLocationList[i][location_type_base], "spawn", false) ) {
				
				Handle tr = TR_TraceHullFilterEx(g_flPoints[i], g_flPoints[i], MinHull, MaxHull, MASK_PLAYERSOLID, RayDontHitClient, Client);
				if( TR_DidHit(tr) ) {
					CloseHandle(tr);
					continue;
				}
				
				CloseHandle(tr);
				
				if( fDist > GetVectorDistance(g_flPoints[i], PlayerOrigin) ) {
					found = true;
					fDist = GetVectorDistance(g_flPoints[i], PlayerOrigin);
					
					fLocation[0] = g_flPoints[i];
				}
			}
		}
		
		if( !found ) 
			Max = 0;
	}
	else {
		for( i=0; i<MAX_LOCATIONS; i++ ) {
			if( StrEqual(g_szLocationList[i][location_type_base], "spawn", false) ) {
				
				fLocation[Max] = g_flPoints[i];
				
				Max++;
				
				Handle tr = TR_TraceHullFilterEx(fLocation[Max], fLocation[Max], MinHull, MaxHull, MASK_PLAYERSOLID, TraceRayDontHitSelf, Client);
				if( TR_DidHit(tr) ) {
					CloseHandle(tr);
					Max--;
					continue;
				}
				CloseHandle(tr);
			}
		}
	}
	
	if( Max > 0 ) {
		i = Math_GetRandomInt(0, (Max-1));
	}
	else {
		PrintToConsole(Client, "DEBUG: Aucun point de respawn disponible trouvé");
		Max = 0;
		
		for( i=0; i<MAX_LOCATIONS; i++ ) {
			if( StrEqual(g_szLocationList[i][location_type_base], "spawn", false) ) {
				fLocation[Max] = g_flPoints[i];
				Max++;
			}
		}
		i = Math_GetRandomInt(0, (Max-1));
	}
	
	TeleportClient(Client, fLocation[i], NULL_VECTOR, NULL_VECTOR);
}
int GetVitaLevel(int i) {
	if( g_flUserData[i][fl_Vitality] <= 64.0 )
		return 0;
	
	int vit_level = RoundToFloor(Logarithm(g_flUserData[i][fl_Vitality], 2.0) / 2.0 - 3.0);
	if( vit_level < 0 )
		vit_level = 0;
		
	return vit_level;
}
int GivePlayerPay(int i, bool calculator = false) {
	static char szQuery[1024], szSteamID[64];
	
	int client = i;
	int to_pay = StringToInt( g_szJobList[ g_iUserData[client][i_Job] ][job_type_pay] );
	int got_pay = to_pay;
 	
 	Call_StartForward( view_as<Handle>(g_hForward_RP_OnPlayerGotPay));
	Call_PushCell(client);
	Call_PushCell(to_pay);
	Call_PushCellRef(got_pay);
	Call_PushCell(!calculator);
	Call_Finish();
	
	Call_StartForward( view_as<Handle>(g_hRPNative[client][RP_OnPlayerPay]));
	Call_PushCell(client);
	Call_PushCell(to_pay);
	Call_PushCellRef(got_pay);
	Call_PushCell(!calculator);
	Call_Finish();
	
	to_pay = got_pay;
	
	int capital = GetJobCapital( g_iUserData[i][i_Job] );
	
	if( !calculator ) {
		
		if( (g_iSuccess_last_jail[i]+(23*60)) <= GetTime() )
			IncrementSuccess(i, success_list_police);
		if( (g_iSuccess_last_kill[i]+(23*60)) <= GetTime() )
			IncrementSuccess(i, success_list_noviolence);
		if( (g_iSuccess_last_chat[i]+(23*60)) <= GetTime() )
			IncrementSuccess(i, success_list_student);		
		if( (g_iSuccess_last_pas_vu_pas_pris[i]+(23*60)) <= GetTime() )
			IncrementSuccess(i, success_list_pas_vu_pas_pris);
		if( StringToInt(g_szJobList[ GetJobPrimaryID(i) ][job_type_current]) >= 20 )
			WonSuccess(i, success_list_shared_work);
		if( IsBoss(i) && StringToFloat(g_szJobList[ GetJobPrimaryID(i) ][job_type_current]) > StringToFloat(g_szJobList[ GetJobPrimaryID(i) ][job_type_quota])*1.25 )
			IncrementSuccess(i, success_list_quota);
	}
	
	if( g_iUserData[i][i_ItemBankPrice] > getClientBankLimit(i) ) {
		if( !calculator ) {
			CPrintToChat(i, "" ...MOD_TAG... " Votre coffre en banque est plein, impossible de vous payer.");
			float pc = float(g_iUserData[i][i_ItemBankPrice]) / float(getClientBankLimit(i)) * 100.0;
			LogToGame("[CHEATING] [BANK] %L Coffre de la banque plein: %f%%", i, pc);
			if( pc > 200.0 )
				KickClient(i);
		}
	}
	else if( g_bUserData[i][b_IsAFK] ) {
		if( !calculator )
			CPrintToChat(i, "" ...MOD_TAG... " Etant AFK, vous n'avez pas le droit de toucher votre paye.");
	}
	else if( g_iUserData[i][i_TimeAFK_today] >= (18*60) ) {
		if( !calculator )
			CPrintToChat(i, "" ...MOD_TAG... " Vous avez passé plus de 18 heures AFK sur cette journée. Vous ne serez donc pas payé.");
	}
	else {
							
		if( IsClientInJail(i) && g_iUserData[i][i_JailTime] > 0 ) {
			
			if( !calculator )
				CPrintToChat(i, "" ...MOD_TAG... " Étant en prison, vous n'avez reçu que 10%% de votre paye.");

			SetJobCapital(1, GetJobCapital(1) + RoundFloat((to_pay/10.0)*6.0) );
			SetJobCapital(101, GetJobCapital(101) + RoundFloat((to_pay/10.0)*3.0) );
			to_pay /= 10;
				
		}
		if( g_iUserData[i][i_SearchLVL] >= 4 ) {
			if( !calculator )
				CPrintToChat(i, "" ...MOD_TAG... " Etant recherché par le Tribunal, vous n'avez pas le droit de toucher votre paye.");

			SetJobCapital(101, GetJobCapital(101) + RoundFloat((to_pay/10.0)*7.0) );
			SetJobCapital(1, GetJobCapital(1) + RoundFloat((to_pay/10.0)*3.0) );
			to_pay = 0;
		}

		if( !calculator ) {
				
			if( capital > 0 || g_iUserData[i][i_Job] == 0 ) {
				CPrintToChat(i, "" ...MOD_TAG... " Vous avez reçu votre paye de %i$.", to_pay);
				SetJobCapital( g_iUserData[i][i_Job], (capital-to_pay));
				g_iUserStat[i][i_MoneyEarned_Pay] += to_pay;
				rp_ClientMoney(i, g_bUserData[i][b_PayToBank] ? i_Bank : i_Money, to_pay);
			}
			else {
				CPrintToChat(i, "" ...MOD_TAG... " L'entreprise pour laquel vous travaillez est en faillite. Vous n'avez pas de paye.");
				
				GetClientAuthId(i, AUTH_TYPE, szSteamID, sizeof(szSteamID), false);
				Format(szQuery, sizeof(szQuery), "INSERT INTO `rp_sell` (`id`, `steamid`, `job_id`, `timestamp`, `item_type`, `item_id`, `item_name`, `amount`) VALUES (NULL, '%s', '%i', '%i', '1', '%i', '%s', '%i');",
				szSteamID, rp_GetClientJobID(i), GetTime(), -1, "PAY", to_pay);			
				SQL_TQuery(g_hBDD, SQL_QueryCallBack, szQuery);
			}
		}
	}
	
	if( g_iUserData[i][i_AddToPay] > 0 ) {
		to_pay += g_iUserData[i][i_AddToPay];
				
		if( !calculator ) {
			CPrintToChat(i, "" ...MOD_TAG... " Vous avez reçu: %d$ pour votre travail d'aujourd'hui.", g_iUserData[i][i_AddToPay]);
			g_iUserStat[i][i_MoneyEarned_Pay] += g_iUserData[i][i_AddToPay];
				
			int tmp = g_iUserData[i][i_AddToPay];
			g_iUserData[i][i_AddToPay] =  0;
			rp_ClientMoney(i, i_Bank, tmp);
				
		}
	}
	
	if( !calculator ) {
		addToGroup(i, to_pay/100);
		g_iUserData[i][i_Disposed] = 10;
		g_iUserData[i][i_TimeAFK_today] = 0;
	}
	
	
	return to_pay;
}
int ChangePersonnal(int client, SynType type, int to_id, int invoker=0, char szPseudo[64]="le site web", char szSource[64]="SERVER", char szRaison[255]="") {
	int from_id = -1;
	char szMessage[1024];
	char szLog[1024];
	static origin[65];
	
	Format(szMessage, sizeof(szMessage), "" ...MOD_TAG... " Vous avez");
	Format(szLog, sizeof(szLog), "[TSX-RP] [SYN]");
	
	if( type == SynType_job ) {
		
		if( !IsTutorialOver(client) ) {
			return;
		}
		
		if( to_id == 0 ) {
			if( GetClientTeam(client) == CS_TEAM_CT && (IsPolice(client) || IsJuge(client)) ) {
				CS_SwitchTeam(client, CS_TEAM_T);
			}
			
			g_iUserData[client][i_TimePlayedJob] = 0;
		}
		
		from_id = g_iUserData[client][i_Job];
		g_iUserData[client][i_Job] = to_id;
		
		
		
		if( to_id > 0 ) {
			Format(szMessage, sizeof(szMessage), "%s été promu comme %s", szMessage, g_szJobList[to_id][job_type_name]);
			
			if( invoker > 0 && !g_iClient_OLD[client] ) {
				IncrementSuccess(invoker, success_list_bon_patron);
				origin[client] = invoker;
			}
		}
		else {
			if( client == invoker ) {
				Format(szMessage, sizeof(szMessage), "%s démissioné de votre job", szMessage);
				g_bUserData[client][b_LicenseSell] = false;
				ServerCommand("sm_force_discord_group %N", client);
			}
			else {
				Format(szMessage, sizeof(szMessage), "%s été viré de votre job", szMessage);
				ServerCommand("sm_force_discord_group %N", client);
			}			
			
			if( origin[client] > 0 && IsBoss(origin[client]) ) {
				if( CanMadeSuccess(origin[client], success_list_bon_patron) )
					IncrementSuccess(origin[client], success_list_bon_patron, -1);
			}
		}
		
		Format(szLog, sizeof(szLog), "%s [JOB] %L était %s et est maintenant %s", szLog, client, g_szJobList[from_id][job_type_name], g_szJobList[to_id][job_type_name]);
	}
	else if( type == SynType_group ) {
		
		from_id = g_iUserData[client][i_Group];
		g_iUserData[client][i_Group] = to_id;
		
		if( to_id > 0 ) {
			Format(szMessage, sizeof(szMessage), "%s été promu comme %s", szMessage, g_szGroupList[to_id][group_type_name]);
		}
		else {
			Format(szMessage, sizeof(szMessage), "%s été viré de votre groupe", szMessage);
		}
		
		Format(szLog, sizeof(szLog), "%s [GROUP] %L était %s et est maintenant %s", szLog, client, g_szGroupList[from_id][group_type_name], g_szGroupList[to_id][group_type_name]);
	}
	else if( type == SynType_money) {
		
		rp_ClientMoney(client, i_Bank, to_id);
		
		if( to_id > 0 ) {
			Format(szMessage, sizeof(szMessage), "%s reçu %i$", szMessage, to_id);
			
			Format(szLog, sizeof(szLog), "%s [MONEY] %L à reçu %i$", szLog, client, to_id);
		}
		else {
			Format(szMessage, sizeof(szMessage), "%s perdu %i$", szMessage, -(to_id));
			
			Format(szLog, sizeof(szLog), "%s [MONEY] %L à perdu %i$", szLog, client, -(to_id));
		}
	}
	else if( type == SynType_jail) {
		
		if( to_id == 0 )
			g_iUserData[client][i_JailTime] = 0;
		else
			g_iUserData[client][i_JailTime] += to_id;
		
		CPrintToChat(client, "" ...MOD_TAG... " Vous avez été condamné à faire %i heure de prison par le juge %s", to_id/60, szPseudo);
		CPrintToChat(client, "" ...MOD_TAG... " La raison de cette condamnation est %s", szRaison);
		
		rp_ClientOverlays(client, o_Jail_Juge, 10.0);
		
		LogToGame("[TSX-RP] [SYN] [JAIL] %L %d heures pour %s par %s", client, to_id/60, szRaison, szPseudo);		
		
		if( g_iUserData[client][i_JailTime] > 0 ) {
			int car = GetEntPropEnt(client, Prop_Send, "m_hVehicle");
			if( car > 0 ) {
				ExitVehicle(client, car, true);
			}
			else {
				LeaveVehiclePassager(client);
			}
			//SendPlayerToJail(client);
			ServerCommand("rp_SendToJail %d", client);
		}		
		
		return;
	}
	else if( type == SynType_itemBank ) {
		
		updateBankCost(client);
		rp_ClientGiveItem(client, to_id, invoker, true);
		
		if( invoker > 0 )
			CPrintToChat(client, "" ...MOD_TAG... " Vous avez reçu: %d %s par %s.", invoker, g_szItemList[to_id][item_type_name], szPseudo);
		else
			CPrintToChat(client, "" ...MOD_TAG... " Vous avez donné: %d %s pour %s.", -invoker, g_szItemList[to_id][item_type_name], szPseudo);
		
		LogToGame("[TSX-RP] [SYN] [ITEM-TRANSFERT] %L %d %s pour %s", client, invoker, g_szItemList[to_id][item_type_name], szPseudo);
	}
	else if( type == SynType_item ) {
		
		rp_ClientGiveItem(client, to_id, invoker);
		
		if( invoker > 0 )
			CPrintToChat(client, "" ...MOD_TAG... " Vous avez reçu: %d %s par %s.", invoker, g_szItemList[to_id][item_type_name], szPseudo);
		else
			CPrintToChat(client, "" ...MOD_TAG... " Vous avez donné: %d %s pour %s.", -invoker, g_szItemList[to_id][item_type_name], szPseudo);
		
		LogToGame("[TSX-RP] [SYN] [ITEM-TRANSFERT] %L %d %s pour %s", client, invoker, g_szItemList[to_id][item_type_name], szPseudo);
	}
	else if( type == SynType_xp ) {
		
		rp_ClientXPIncrement(client, to_id);
		
		LogToGame("[TSX-RP] [SYN] [XP] %L %d xp par %s", client, to_id, szPseudo);
	}
	
	
	if( IsValidClient(invoker) && type != SynType_item ) {		
		
		char szSteamID2[64];
		GetClientAuthId(invoker, AUTH_TYPE, szSteamID2, sizeof(szSteamID2), false);
		
		Format(szPseudo, sizeof(szPseudo), "%N", invoker);
		Format(szSource, sizeof(szSource), "%s", szSteamID2);
	}
	
	if( !(type == SynType_job && client == invoker ) )
		Format(szMessage, sizeof(szMessage), "%s par %s.", szMessage, szPseudo);
	
	Format(szLog, sizeof(szLog), "%s par %s (%s).", szLog, szPseudo, szSource);
	
	
	if( type != SynType_item && type != SynType_itemBank && type != SynType_xp ) {
		LogToGame(szLog);
		CPrintToChat(client, szMessage);
	}
	
	StoreUserData(client);
}
// Bools:

void getPlayerSkin(int client, char model[PLATFORM_MAX_PATH], char hands[PLATFORM_MAX_PATH]) {
	Format(model, sizeof(model), "%s", g_szUserData[client][sz_Skin]);

	if( GetClientTeam(client) == CS_TEAM_T ) {
		if( strlen(g_szUserData[client][sz_Skin]) <= 5  ) {
			Format(model, sizeof(model), "models/player/custom_player/legacy/tm_phoenix.mdl");
		}
		
		if( g_iUserData[client][i_Donateur] >= 1 && g_iUserData[client][i_Donateur] <= 10 && g_iUserData[client][i_SkinDonateur] > 0 ) {
			
			switch( g_iUserData[client][i_SkinDonateur] ) {
				case 1: Format(model, sizeof(model), "models/player/custom_player/riplay/momiji/momiji.mdl");
				case 2: Format(model, sizeof(model), "models/player/custom_player/riplay/nathandrake/nathandrake.mdl");
				case 3: Format(model, sizeof(model), "models/player/custom_player/riplay/wick/wick.mdl");
			}
		}
		
	}
	else if( GetClientTeam(client) == CS_TEAM_CT ) {

		int job = g_iUserData[client][i_Job];
		switch( job ) {
			case 9:		Format(model, sizeof(model), "models/player/custom_player/riplay/brigadier/brigadier.mdl");
			case 8: 	Format(model, sizeof(model), "models/player/custom_player/riplay/gendarme/gendarme.mdl");
			case 7: 	Format(model, sizeof(model), "models/player/custom_player/riplay/pisg/pisg.mdl");
			case 6: 	Format(model, sizeof(model), "models/player/custom_player/riplay/bri/bri.mdl");
			case 5: 	Format(model, sizeof(model), "models/player/custom_player/riplay/gign/gign.mdl");
			case 4: 	Format(model, sizeof(model), "models/player/custom_player/riplay/capitaine/capitaine.mdl");
			case 2: 	Format(model, sizeof(model), "models/player/custom_player/riplay/colonel/colonel.mdl");
			case 1: 	Format(model, sizeof(model), "models/player/custom_player/riplay/colonel/colonel.mdl");
			
			case 109:	Format(model, sizeof(model), "models/player/custom_player/legacy/ctm_gign_variantd.mdl");
			case 108:	Format(model, sizeof(model), "models/player/custom_player/legacy/ctm_gign_variantd.mdl");
			case 107:	Format(model, sizeof(model), "models/player/custom_player/legacy/ctm_gign_variantd.mdl");
			
			case 106:	Format(model, sizeof(model), "models/player/custom_player/legacy/ctm_gign_variantb.mdl");
			case 105:	Format(model, sizeof(model), "models/player/custom_player/legacy/ctm_gign_variantb.mdl");
			case 104:	Format(model, sizeof(model), "models/player/custom_player/legacy/ctm_gign_variantb.mdl");
			case 103:	Format(model, sizeof(model), "models/player/custom_player/legacy/ctm_gign_variantb.mdl");
			case 102:	Format(model, sizeof(model), "models/player/custom_player/legacy/ctm_sas.mdl");
			case 101:	Format(model, sizeof(model), "models/player/custom_player/legacy/ctm_sas_variante.mdl");
		}
	}

	if( !FileExists(model) || !IsModelPrecached(model) || PrecacheModel(model) == 0 ) {
		Format(model, sizeof(model), "models/player/custom_player/legacy/tm_phoenix.mdl");
	}
	
	Format(hands, sizeof(hands), "%s_EOF", model);
	ReplaceString(hands, sizeof(hands), ".mdl_EOF", "_arms.mdl");
	
	if( !FileExists(hands) || !IsModelPrecached(hands) || PrecacheModel(hands) == 0 ) {
		switch(GetClientTeam(client)) {
			case CS_TEAM_CT: 	Format(hands, sizeof(hands), "models/weapons/ct_arms.mdl");
			default: 			Format(hands, sizeof(hands), "models/weapons/t_arms.mdl");
		}
	}
}
void SetPersonalSkin(int client) {
	
	if( Client_GetVehicle(client) > 0 )
		return;
	
	if( GetEntPropFloat(client, Prop_Send, "m_flModelScale") != g_flUserData[client][fl_Size] ) {
		SetEntPropFloat(client, Prop_Send, "m_flModelScale", g_flUserData[client][fl_Size]);
	}
	
	char model[PLATFORM_MAX_PATH], hands[PLATFORM_MAX_PATH], prev[PLATFORM_MAX_PATH];
	getPlayerSkin(client, model, hands);
	Entity_GetModel(client, prev, sizeof(prev));
	
	if( !StrEqual(model, prev) ) {
		SetEntityModel(client, model);
	}	
}
int GetAssurence(int client, bool forced = false) {
	char tmp[64];
    
	if( !g_bUserData[client][b_Assurance] && !forced ) {
		return 0;
	}
    
	int amount = 0;
	if( g_bUserData[client][b_Map] )
		amount += 1000;
   
	Call_StartForward( view_as<Handle>(g_hRPNative[client][RP_OnAssurance]));
	Call_PushCell(client);
	Call_PushCellRef(amount);
	Call_Finish();
    
	bool hasCas = false;
	
	for(int i=1; i<MAX_ENTITIES; i++) {
		if( !IsValidEdict(i) )
			continue;
		if( !IsValidEntity(i) )
			continue;
		
		GetEdictClassname(i, tmp, 63);
		if( rp_GetBuildingData(i, BD_owner) == client ) {
			if( StrEqual(tmp, "rp_cashmachine") ) {
				if( IsTech(client) )
					amount += 10;
				else
					amount += 100;
			}
			else if( StrEqual(tmp, "rp_bigcashmachine") ) {
				if( IsTech(client) )
					amount += 525;
				else
					amount += 5250;
			}
			else if( StrEqual(tmp, "rp_plant") ) {
				if( IsDealer(client) )
					amount += 100;
				else
					amount += 1000;
			}
			else if( StrEqual(tmp, "rp_kevlarbox") ) {
				if( IsSexShop(client) )
					amount += 200;
				else
					amount += 2000;
			}
			else if( StrEqual(tmp, "rp_healbox") ) {
				if( IsMedic(client) )
					amount += 200;
				else
					amount += 2000;
			}
			else if( StrEqual(tmp, "rp_microwave") ) {
				if( IsMcDo(client) )
					amount += 200;
				else
					amount += 2000;
			}
			else if( StrEqual(tmp, "rp_table") ) {
				if( IsArtisan(client) )
					amount += 250;
				else
					amount += 2500;
			}
			else if( StrEqual(tmp, "rp_bank") ) {
				amount += 2500;
			}
		}
		else if( !hasCas && StrContains(tmp, "prop_vehicle_") == 0 && g_iVehicleData[i][car_owner] == client ) {
			amount += 2000;
			hasCas = true;
		}
	}
	
	if( g_bUserData[client][b_HasGrave] ) {
		amount += 250;
	}
	
	char wepname[64];
	int wepIdx;
	
	for( int i = 0; i < 5; i++ ) {
		
		if( i == CS_SLOT_KNIFE )
			continue;
		
		wepIdx = GetPlayerWeaponSlot( client, i );
		
		if( wepIdx <= 0 || !IsValidEdict(wepIdx) || !IsValidEntity(wepIdx) )
			continue;
		
		if( IsPolice(client) && rp_GetWeaponStorage(wepIdx) )
			continue;
		GetEdictClassname(wepIdx, wepname, sizeof(wepname));
		
		char wepdata[64];
		Format(wepdata, sizeof(wepdata), "%s", wepname);
		ReplaceString(wepdata, sizeof(wepdata), "weapon_", "");
		ReplaceString(wepdata, sizeof(wepdata), "item_", "");
		
		int price = CS_GetWeaponPrice2(client, CS_AliasToWeaponID(wepdata), true);
		
		amount += RoundFloat( (float(price)/100.0) * (50.0) );
	}
	
	amount += GivePlayerPay(client, true);
	
	for(int a=0; a<MAX_KEYSELL; a++) {
		if( g_iDoorOwner_v2[client][a] ) {
			if( g_iAppartBonus[a][appart_proprio] == client ) {
				amount += StringToInt(g_szSellingKeys[a][key_type_prix]);
				
				if( g_iAppartBonus[a][appart_bonus_heal] )
					amount += 250;
				if( g_iAppartBonus[a][appart_bonus_armor] )
					amount += 250;
				if( g_iAppartBonus[a][appart_bonus_energy] )
					amount += 200;
				if( g_iAppartBonus[a][appart_bonus_garage] )
					amount += 200;
				if( g_iAppartBonus[a][appart_bonus_vitality] )
					amount += 400;
				if( g_iAppartBonus[a][appart_bonus_coffre] )
					amount += 200;
				
				amount += g_iAppartBonus[a][appart_bonus_paye] * 6;
			}
			amount += 600;
		}
	}
	
	return amount;
}
void CopSetVisible(int client) {
	
	ClientCommand(client, "r_screenoverlay 0");
	
	if( IsInPVP(client) )
		GroupColor(client);
	Colorize(client, 255, 255, 255, 255);
	
	g_bUserData[client][b_Invisible] = 0;
	if( IsPolice(client) ) {
		g_bUserData[client][b_MaySteal] = false;
		CreateTimer(10.0, AllowStealing, client);
	}		
	CPrintToChat(client, "" ...MOD_TAG... " Vous êtes maintenant visible.");
	g_flUserData[client][fl_invisibleTimeLeft] = GetGameTime() + 5.0;
}
void CopSetInvisible(int client) {
	
	Colorize(client, 255, 255, 255, 0);
	g_bUserData[client][b_Invisible] = true;
	ClientCommand(client, "r_screenoverlay effects/hsv.vmt");
	
	CPrintToChat(client, "" ...MOD_TAG... " Vous êtes maintenant invisible.");
}
void CheckLiscence(int client) {
	int time = GetTime();
	
	if(g_bUserData[client][b_License1]) {
		if(GetTime() > g_iUserData[client][i_StartLicense1] + (24*60*60)*14) {
			CPrintToChat(client, "" ...MOD_TAG... " Attention, ton permis de port d'arme léger vient d'expirer. Pense à racheter tes permis auprès d'un banquier.");
			g_bUserData[client][b_License1] = 0;
		}
	}
 
	if(g_bUserData[client][b_License2]) {
		if(GetTime() > g_iUserData[client][i_StartLicense2] + (24*60*60)*14) {
			CPrintToChat(client, "" ...MOD_TAG... " Attention, ton permis de port d'arme lourd vient d'expirer. Pense à racheter tes permis auprès d'un banquier..");
			g_bUserData[client][b_License2] = 0;
		}
	}
}