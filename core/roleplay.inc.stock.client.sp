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
	float val = float(ITEM_BANK_LIMIT);
	
	if( g_iUserData[client][i_PlayerLVL] >= 240 )
		val *= 2;

	if( g_iUserData[client][i_PlayerPrestige] >= 1 )
		val *= RoundFloat(Pow(2.0, float(g_iUserData[client][i_PlayerPrestige])));
		
	if( g_iUserData[client][i_Donateur] != 0 )
		val *=1.3;
	
	return RoundFloat(val);
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
			CPrintToChat(Client, "" ...MOD_TAG... " %T", "Dead_DropWallet", Client);
			rp_ClientMoney(Client, i_Money, -Math_GetRandomInt(20, 50));
		}
		else if( rand >= 71 && rand < 86 ) {
			if( g_bUserData[Client][b_HaveCard] == 1 ) {
				g_bUserData[Client][b_HaveCard] = 0;
				CPrintToChat(Client, "" ...MOD_TAG... " %T", "Dead_DropCB", Client);
			}
			else {
				CPrintToChat(Client, "" ...MOD_TAG... " %T", "Dead_DropWallet", Client);
				SpawnMoney(vecOrigin, true);
				rp_ClientMoney(Client, i_Money, -Math_GetRandomInt(20, 50));
			}
		}
		else if( rand >= 86 && rand < 101 ) {
			if( strlen(g_szUserData[Client][sz_Skin]) > 2 ) {
				Format(g_szUserData[Client][sz_Skin], sizeof(g_szUserData[][]), "");
				CPrintToChat(Client, "" ...MOD_TAG... " %T", "Dead_DropSkin", Client);
			}
			else {
				
				SpawnMoney(vecOrigin, true);
				CPrintToChat(Client, "" ...MOD_TAG... " %T", "Dead_DropWallet", Client);
				rp_ClientMoney(Client, i_Money, -Math_GetRandomInt(20, 50));
			}
		}
		else {
			
			SpawnMoney(vecOrigin, true);
			CPrintToChat(Client, "" ...MOD_TAG... " %T", "Dead_DropWallet", Client);
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
	char ClanTag[16];
	
	Format(ClanTag, sizeof(ClanTag), "%s", g_szJobList[ g_iUserData[client][i_Job] ][job_type_tag]);
	if( g_iUserData[client][i_Job] >= 1 && g_iUserData[client][i_Job] <= 10 ) {
		if( GetClientTeam(client) != CS_TEAM_CT ) {
			if(g_iUserData[client][i_KillJailDuration] > 1) {
				Format(ClanTag, sizeof(ClanTag), "%T", "ScoreBar_TAG_Criminal", LANG_SERVER);
			} else {
				Format(ClanTag, sizeof(ClanTag), "%T", "ScoreBar_TAG_Police", LANG_SERVER);
			}
		}
	}	
	if( g_iUserData[client][i_Job] >= 101 && g_iUserData[client][i_Job] <= 110 ) {
		if( GetClientTeam(client) != CS_TEAM_CT ) {
			if(g_iUserData[client][i_KillJailDuration] > 1) {
				Format(ClanTag, sizeof(ClanTag), "%T", "ScoreBar_TAG_Criminal", LANG_SERVER);
			} else {
				Format(ClanTag, sizeof(ClanTag), "%T", "ScoreBar_TAG_Juge", LANG_SERVER);
			}
		}
	}
	if( g_iUserData[client][i_JailTime] > 0 ) {
		Format(ClanTag, sizeof(ClanTag), "%T", "ScoreBar_TAG_InJail", LANG_SERVER);
	}
	else if( g_bUserData[client][b_IsAFK] ) {
		Format(ClanTag, sizeof(ClanTag), "%T", "ScoreBar_TAG_AFK", LANG_SERVER);
	}
	else if( !IsTutorialOver(client) ) {
		Format(ClanTag, sizeof(ClanTag), "%T", "ScoreBar_TAG_InTUTO", LANG_SERVER);
	}

	ServerCommand("sm_force_clantag \"%d\" \"%s\"", client, ClanTag);
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
	static char clientname[64], clientname2[128], classname[64];
	
	if( target <= 0 )
		return;
	
	Action a;
	Call_StartForward( view_as<Handle>(g_hRPNative[client][RP_OnPlayerHINT]));
	Call_PushCell(client);
	Call_PushCell(target);
	Call_Finish(a);
		
	if( a == Plugin_Handled || a == Plugin_Stop )
		return;
	
	if( !IsValidEdict(target) )
		return;
	if( !IsValidEntity(target) )
		return;
	
	GetEdictClassname(target, classname, sizeof(classname));
	
	
	if( IsValidClient( target ) ) {
		
		if( IsValidClient( g_iUserData[target][i_FakeClient] ) )
			target = g_iUserData[target][i_FakeClient];
		
		char szJail[128];
		PrintJail(target, szJail, sizeof(szJail));
		
		GetClientName2(target, clientname, sizeof(clientname), false);
		String_ColorsToHTML(clientname, sizeof(clientname));
		
		if( g_bUserData[target][b_CAPSLOCK] )  {
			String_ToLower(clientname, clientname, strlen(clientname));
		}
		
		if( EVENT_HIDE == 1 ) {
			return;
		}
		if( g_iClient_OLD[target] ) {
			PrintHintText(client, "%T", "HINT_Player", client, g_bUserData[target][b_GameModePassive] ? "00cc00" : "cc0000", clientname, (GetClientHealth(target)), szJail, g_szJobList[g_iUserData[target][i_Job]][job_type_name]);
		}
		else {
			
			int flags = GetUserFlagBits(client);
			if (flags & ADMFLAG_GENERIC || flags & ADMFLAG_ROOT ||
				(GetJobPrimaryID(client) == g_iUserData[client][i_Job] && g_iUserData[client][i_Job] > 0 && g_iUserData[target][i_Job] == 0 ) ||
				IsJuge(client) || IsPolice(client) ) {
				PrintHintText(client, "%T", "HINT_NewPlayer", client, g_bUserData[target][b_GameModePassive] ? "00cc00" : "cc0000", clientname, (GetClientHealth(target)), szJail, g_szJobList[g_iUserData[target][i_Job]][job_type_name]);
			}
			else {
				PrintHintText(client, "%T", "HINT_Player", client, g_bUserData[target][b_GameModePassive] ? "00cc00" : "cc0000", clientname, (GetClientHealth(target)), szJail, g_szJobList[g_iUserData[target][i_Job]][job_type_name]);
			}
		}
		
		if(IsJuge(target)) {
			Format(classname, sizeof(classname), "%T", "ScoreBar_TAG_Juge", client);
			
			if( GetClientTeam(target) != CS_TEAM_CT ) {
				if(g_iUserData[target][i_KillJailDuration] > 1) {
					PrintHintText(client, "%T", "HINT_Player", client, g_bUserData[target][b_GameModePassive] ? "00cc00" : "cc0000", clientname, (GetClientHealth(target)), szJail, classname);
				} else {
					PrintHintText(client, "%T", "HINT_Player", client, g_bUserData[target][b_GameModePassive] ? "00cc00" : "cc0000", clientname, (GetClientHealth(target)), szJail, classname);
				}
			}
		}

		if(IsPolice(target)) {
			Format(classname, sizeof(classname), "%T", "ScoreBar_TAG_Police", client);
			
			if( GetClientTeam(target) != CS_TEAM_CT ) {
				if(g_iUserData[target][i_KillJailDuration] > 1) {
					PrintHintText(client, "%T", "HINT_Player", client, g_bUserData[target][b_GameModePassive] ? "00cc00" : "cc0000", clientname, (GetClientHealth(target)), szJail, classname);
				} else {
					PrintHintText(client, "%T", "HINT_Player", client, g_bUserData[target][b_GameModePassive] ? "00cc00" : "cc0000", clientname, (GetClientHealth(target)), szJail, classname);
				}
			}
		}
	}
	else if( IsValidClient(rp_GetBuildingData(target, BD_owner)) || rp_GetBuildingData(target, BD_owner) == -1 ) {
		
		int target2 = rp_GetBuildingData(target, BD_owner);
		
		if( target2 > 0 ) {
			GetClientName2(target2, clientname, sizeof(clientname), false);
			String_ColorsToHTML(clientname, sizeof(clientname));
			
			if( g_bUserData[target2][b_CAPSLOCK] )  {
				String_ToLower(clientname, clientname, strlen(clientname));
			}
		}
		else {
			Format(clientname, sizeof(clientname), "??????");
		}
		
		PrintHintText(client, "%T", "Hint_Props", client, clientname, Entity_GetHealth(target), (float(Entity_GetHealth(target))/float(Entity_GetMaxHealth(target))) * 100.0);
	}
	else if( StrEqual(classname, "prop_vehicle_driveable") && IsValidClient(g_iVehicleData[target][car_owner]) ) {
		
		int target2 = g_iVehicleData[target][car_owner];
		
		GetClientName2(target2, clientname, sizeof(clientname), false);
		String_ColorsToHTML(clientname, sizeof(clientname));
		
		if( g_bUserData[target2][b_CAPSLOCK] )  {
			String_ToLower(clientname, clientname, strlen(clientname));
		}
		
		int target3 = GetEntPropEnt(target, Prop_Send, "m_hPlayer");
		char fmt[128];
		if( IsValidClient(target3) ) {
			GetClientName2(target3, clientname2, sizeof(clientname2), false);
			String_ColorsToHTML(clientname2, sizeof(clientname2));
			
			PrintHintText(client, "%T", "Hint_VehicleDriving", client, clientname, clientname2, rp_GetVehicleInt(target, car_health));
		}
		else {
			PrintHintText(client, "%T", "Hint_Vehicle", client, clientname, rp_GetVehicleInt(target, car_health));
		}
	}
	else if( StrEqual(classname, "prop_vehicle_driveable") && g_iVehicleData[target][car_owner] < 0 ) {
		
		int target3 = GetEntPropEnt(target, Prop_Send, "m_hPlayer");
		char fmt[128];
		if( IsValidClient(target3) ) {
			
			GetClientName2(target3, clientname, sizeof(clientname), false);
			String_ColorsToHTML(clientname, sizeof(clientname));
			
			if( g_bUserData[target3][b_CAPSLOCK] )  {
				String_ToLower(clientname, clientname, strlen(clientname));
			}
			
			PrintHintText(client, "%T", "Hint_VehicleJobDriving", client, clientname, rp_GetVehicleInt(target, car_health));
		}
		else {
			PrintHintText(client, "%T", "Hint_VehicleJob", client, rp_GetVehicleInt(target, car_health));
		}
	}
	else if( StrContains(classname, "door") >= 0 ) {
		int appart = getDoorAppart(target);
		if( appart >= 0 ) {
			int owner = g_iAppartBonus[appart][appart_proprio];
			if( IsValidClient(owner) ) {
				
				GetClientName2(owner, clientname, sizeof(clientname), false);
				String_ColorsToHTML(clientname, sizeof(clientname));
				
				if( g_bUserData[owner][b_CAPSLOCK] )  {
					String_ToLower(clientname, clientname, strlen(clientname));
				}
				
				PrintHintText(client, "%T", (appart < 100 ? "Hint_Appart" : "Hint_Garage"), client, clientname);
			}
			else if( appart == 12 ) {
				PrintHintText(client, "%T", "Hint_Appart", client, "??????");
			}
			else if( appart == 50 ) {
				rp_GetServerString(villaOwnerName, clientname, sizeof(clientname));
				PrintHintText(client, "%T", "Hint_Villa", client, clientname);
			}
			else if( appart == 51 ) {
				PrintHintText(client, "%T", "Hint_Villa", client, g_szGroupList[g_iCapture[cap_villa]][group_type_name]); 
			}
			else {
				PrintHintText(client, "%T", (appart < 100 ? "Hint_Appart_Sell" : "Hint_Garage_Sell"), client, appart > 100 ? appart - 100 : appart, StringToInt(g_szSellingKeys[appart][key_type_prix]));
			}
		}
		else {
			char expl[4][64];
			rp_GetZoneData(rp_GetPlayerZone(target), zone_type_name, clientname, sizeof(clientname));
			ExplodeString(clientname, " - ", expl, sizeof(expl), sizeof(expl[]));
			ExplodeString(expl[0], ":", expl, sizeof(expl), sizeof(expl[]));
			strcopy(clientname, sizeof(clientname), expl[0]);
			
			Format(classname, sizeof(classname), "Empty_String");
			Format(clientname2, sizeof(clientname2), "Empty_String");
			
			if( Entity_GetDistance(client, target) < 512.0 ) {
				Format(clientname2, sizeof(clientname2), "%s", GetEntProp(target, Prop_Data, "m_bLocked") ? "Hint_Door_Close" : "Hint_Door_Open");			
				if( rp_GetDoorID(target) > 0 )
					Format(classname, sizeof(classname), "%s", rp_GetClientKeyDoor(client, rp_GetDoorID(target)) ? "Hint_Door_WithKey" : "Hint_Door_WithoutKey" );
			}
			
			PrintHintText(client, "%T", "Hint_Door", client, clientname, clientname2, classname);
		}
	}
	else if( StrEqual(classname, "rp_bank") ) {
		PrintHintText(client, "\n %T", "Hint_ATM", client);
	}
	else if( StrContains(classname, "rp_mail") >= 0 ) {
		char tmp3[2][64];
		
		ReplaceString(classname, sizeof(classname), "rp_mail_", "");
		int job = StringToInt(classname);
		
		if( job > 0 ) {
			rp_GetJobData(job, job_type_name, classname, sizeof(classname));	
			ExplodeString(classname, " - ", tmp3, sizeof(tmp3), sizeof(tmp3[]));
			Format(classname, sizeof(classname), "%s", tmp3[1]);
		}
		else {
			Format(classname, sizeof(classname), "%T", "Hint_MAIL_Mairie", client);
		}
		
		PrintHintText(client, "%T", "Hint_MAIL", client, classname);

	}
	else if( StrEqual(classname, "rp_phone") ) {
		PrintHintText(client, "%T", "Hint_Phone", client);
	}
	else if( StrEqual(classname, "rp_tree") ) {
		PrintHintText(client, "%T", "Hint_Arbre", client, Entity_GetHealth(target), (float(Entity_GetHealth(target))/float(Entity_GetMaxHealth(target))) * 100.0);
	}
	else if( StrEqual(classname, "rp_wood") ) {
		PrintHintText(client, "%T", "Hint_Bois", client, Entity_GetHealth(target), (float(Entity_GetHealth(target))/float(Entity_GetMaxHealth(target))) * 100.0);
	}
	else if( StrEqual(classname, "rp_stone") ) {
		int to_id = rp_GetBuildingData(target, BD_item_id);
		
		Format(clientname, sizeof(clientname), "%s", to_id > 0 ? g_szItemList[to_id][item_type_name] : "??????");
		
		PrintHintText(client, "%T", "Hint_Stone", client, clientname, Entity_GetHealth(target), (float(Entity_GetHealth(target))/float(Entity_GetMaxHealth(target))) * 100.0);
	}
	else if( StrEqual(classname, "rp_crate") ) {
		PrintHintText(client, "%T", "Hint_Stuff", client, classname, Entity_GetHealth(target), (float(Entity_GetHealth(target))/float(Entity_GetMaxHealth(target))) * 100.0);
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
			CPrintToChat(i, "" ...MOD_TAG... " %T", "Pay_Cannot_Full", i);
			float pc = float(g_iUserData[i][i_ItemBankPrice]) / float(getClientBankLimit(i)) * 100.0;
			LogToGame("[CHEATING] [BANK] %L Coffre de la banque plein: %f%%", i, pc);
			if( pc > 200.0 )
				KickClient(i, "%T", "Pay_Cannot_Full", i);
		}
	}
	else if( g_bUserData[i][b_IsAFK] ) {
		if( !calculator )
			CPrintToChat(i, "" ...MOD_TAG... " %T", "Pay_Cannot_AFK", i);
	}
	else if( g_iUserData[i][i_TimeAFK_today] >= (18*60) ) {
		if( !calculator )
			CPrintToChat(i, "" ...MOD_TAG... " %T", "Pay_Cannot_AFK", i);
	}
	else {
							
		if( IsClientInJail(i) && g_iUserData[i][i_JailTime] > 0 ) {
			
			if( !calculator )
				CPrintToChat(i, "" ...MOD_TAG... " %T", "Pay_Cannot_Jail", i);

			SetJobCapital(1, GetJobCapital(1) + RoundFloat((to_pay/10.0)*6.0) );
			SetJobCapital(101, GetJobCapital(101) + RoundFloat((to_pay/10.0)*3.0) );
			to_pay /= 10;
				
		}
		if( g_iUserData[i][i_SearchLVL] >= 4 ) {
			if( !calculator )
				CPrintToChat(i, "" ...MOD_TAG... " %T", "Pay_Cannot_Tribunal", i);

			SetJobCapital(101, GetJobCapital(101) + RoundFloat((to_pay/10.0)*7.0) );
			SetJobCapital(1, GetJobCapital(1) + RoundFloat((to_pay/10.0)*3.0) );
			to_pay = 0;
		}

		if( !calculator ) {
				
			if( capital > 0 || g_iUserData[i][i_Job] == 0 ) {
				CPrintToChat(i, "" ...MOD_TAG... " %T", "Pay_Give", i, to_pay);
				SetJobCapital( g_iUserData[i][i_Job], (capital-to_pay));
				g_iUserStat[i][i_MoneyEarned_Pay] += to_pay;
				rp_ClientMoney(i, g_bUserData[i][b_PayToBank] ? i_Bank : i_Money, to_pay);
			}
			else {
				CPrintToChat(i, "" ...MOD_TAG... " %T", "Pay_Cannot_Bankrupt", i);
				
				GetClientAuthId(i, AUTH_TYPE, szSteamID, sizeof(szSteamID), false);
				Format(szQuery, sizeof(szQuery), "INSERT INTO `rp_sell` (`id`, `steamid`, `job_id`, `timestamp`, `item_type`, `item_id`, `item_name`, `amount`) VALUES (NULL, '%s', '%i', '%i', '1', '%i', '%s', '%i');",
				szSteamID, rp_GetClientJobID(i), GetTime(), -1, "PAY", to_pay);			
				SQL_TQuery(g_hBDD, SQL_QueryCallBack, szQuery);
			}
		}
	}
	
	if( g_iUserData[i][i_AddToPay] > 0 ) {
		if( !calculator ) {
			
			CPrintToChat(i, "" ...MOD_TAG... " %T", "Pay_Work", i, g_iUserData[i][i_AddToPay]);
			g_iUserStat[i][i_MoneyEarned_Pay] += g_iUserData[i][i_AddToPay];
				
			int tmp = g_iUserData[i][i_AddToPay];
			g_iUserData[i][i_AddToPay] =  0;
			rp_ClientMoney(i, g_bUserData[i][b_PayToBank] ? i_Bank : i_Money, tmp);
				
		}
	}
	
	if( !calculator ) {
		g_iUserData[i][i_Disposed] = 10;
		g_iUserData[i][i_TimeAFK_today] = 0;
	}
	
	
	return to_pay;
}
int ChangePersonnal(int client, SynType type, int to_id, int invoker=0, char szPseudo[64]="le site web", char szSource[64]="SERVER", char szRaison[255]="") {
	int from_id = -1;
	char szLog[1024], name[128];
	static origin[65];
	
	Format(szLog, sizeof(szLog), "[TSX-RP] [SYN]");
	
	if( type == SynType_job ) {
		
		if( !IsTutorialOver(client) ) {
			return;
		}
		
		if( (to_id < 1 || to_id > 10) && (to_id < 101 || to_id > 110) && GetClientTeam(client) == CS_TEAM_CT ) {
				CS_SwitchTeam(client, CS_TEAM_T);
		}

		if( to_id == 0 ){
			g_iUserData[client][i_TimePlayedJob] = 0;
		}
		
		from_id = g_iUserData[client][i_Job];
		g_iUserData[client][i_Job] = to_id;
		ServerCommand("sm_force_discord_group %d", client);
		
		if( to_id > 0 ) {
			if( IsValidClient(invoker) )
				GetClientName2(invoker, szPseudo, sizeof(szPseudo), false);

			if( from_id == 0 || GetJobID(from_id) != GetJobID(to_id) || from_id == to_id )
				CPrintToChat(client, "" ...MOD_TAG... " %T", "Syn_Hire", client, g_szJobList[to_id][job_type_name], szPseudo);
			else if( from_id > to_id )
				CPrintToChat(client, "" ...MOD_TAG... " %T", "Syn_Upgrade", client, g_szJobList[to_id][job_type_name], szPseudo);
			else if( from_id < to_id )
				CPrintToChat(client, "" ...MOD_TAG... " %T", "Syn_Downgrade", client, g_szJobList[to_id][job_type_name], szPseudo);
			
			if( invoker > 0 && !g_iClient_OLD[client] ) {
				IncrementSuccess(invoker, success_list_bon_patron);
				origin[client] = invoker;
			}
		}
		else {
			if( client == invoker ) {
				CPrintToChat(client, "" ...MOD_TAG... " %T", "Syn_Dismiss", client);
				g_bUserData[client][b_LicenseSell] = false;
			}
			else {
				if( IsValidClient(invoker) )
					GetClientName2(invoker, szPseudo, sizeof(szPseudo), false);
				CPrintToChat(client, "" ...MOD_TAG... " %T", "Syn_Fire", client, szPseudo);
			}			
			
			if( origin[client] > 0 && IsBoss(origin[client]) ) {
				if( CanMakeSuccess(origin[client], success_list_bon_patron) )
					IncrementSuccess(origin[client], success_list_bon_patron, -1);
			}
		}
		
		Format(szLog, sizeof(szLog), "%s [JOB] %L était %s et est maintenant %s", szLog, client, g_szJobList[from_id][job_type_name], g_szJobList[to_id][job_type_name]);
	}
	else if( type == SynType_group ) {
		
		from_id = g_iUserData[client][i_Group];
		g_iUserData[client][i_Group] = to_id;
		
		if( to_id > 0 ) {
			if( IsValidClient(invoker) )
				GetClientName2(invoker, szPseudo, sizeof(szPseudo), false);

			if( from_id == 0 || GetGroupID(from_id) != GetGroupID(to_id) || from_id == to_id )
				CPrintToChat(client, "" ...MOD_TAG... " %T", "Syn_Hire", client, g_szGroupList[to_id][group_type_name], szPseudo);
			else if( from_id > to_id )
				CPrintToChat(client, "" ...MOD_TAG... " %T", "Syn_Upgrade", client, g_szGroupList[to_id][group_type_name], szPseudo);
			else
				CPrintToChat(client, "" ...MOD_TAG... " %T", "Syn_Downgrade", client, g_szGroupList[to_id][group_type_name], szPseudo);
		}
		else {
			if( client == invoker ) {
				CPrintToChat(client, "" ...MOD_TAG... " %T", "Syn_Dismiss", client);
				g_bUserData[client][b_LicenseSell] = false;
			}
			else {
				if( IsValidClient(invoker) )
					GetClientName2(invoker, szPseudo, sizeof(szPseudo), false);
				CPrintToChat(client, "" ...MOD_TAG... " %T", "Syn_Fire", client, szPseudo);
			}
		}
		
		Format(szLog, sizeof(szLog), "%s [GROUP] %L était %s et est maintenant %s", szLog, client, g_szGroupList[from_id][group_type_name], g_szGroupList[to_id][group_type_name]);
	}
	else if( type == SynType_money) {
		
		rp_ClientMoney(client, i_Bank, to_id, true);
		
		if( to_id > 0 ) {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Syn_Money_Give", client, to_id, szPseudo);
			Format(szLog, sizeof(szLog), "%s [MONEY] %L à reçu %i$", szLog, client, to_id);
		}
		else {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Syn_Money_Take", client, -to_id, szPseudo);
			Format(szLog, sizeof(szLog), "%s [MONEY] %L à perdu %i$", szLog, client, -(to_id));
		}
	}
	else if( type == SynType_jail) {
		
		if( to_id == 0 )
			g_iUserData[client][i_JailTime] = 0;
		else
			g_iUserData[client][i_JailTime] += to_id;
		
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Syn_Jail", client, to_id/60, szPseudo, szRaison);
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
			ServerCommand("rp_SendToJail %d", client);
		}		
		
		return;
	}
	else if( type == SynType_itemBank ) {
		
		rp_ClientGiveItem(client, to_id, invoker, true);
		updateBankCost(client);
		
		if( invoker > 0 )
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Syn_Item_Give", client, invoker, g_szItemList[to_id][item_type_name], szPseudo);
		else
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Syn_Item_Take", client, invoker, g_szItemList[to_id][item_type_name], szPseudo);
		
		LogToGame("[TSX-RP] [SYN] [ITEM-TRANSFERT] %L %d %s pour %s", client, invoker, g_szItemList[to_id][item_type_name], szPseudo);
	}
	else if( type == SynType_item ) {
		
		rp_ClientGiveItem(client, to_id, invoker);
		updateBankCost(client);
		
		if( invoker > 0 )
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Syn_Item_Give", client, invoker, g_szItemList[to_id][item_type_name], szPseudo);
		else
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Syn_Item_Take", client, invoker, g_szItemList[to_id][item_type_name], szPseudo);
		
		LogToGame("[TSX-RP] [SYN] [ITEM-TRANSFERT] %L %d %s pour %s", client, invoker, g_szItemList[to_id][item_type_name], szPseudo);
	}
	else if( type == SynType_xp ) {
		rp_ClientXPIncrement(client, to_id);
		
		LogToGame("[TSX-RP] [SYN] [XP] %L %d xp par %s", client, to_id, szPseudo);
	}
	
	else if( type == SynType_jetonpass ) {
		rp_ClientJetonpassIncrement(client, to_id);
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Syn_Jetonpass_Give", client, to_id, szPseudo);
		LogToGame("[TSX-RP] [SYN] [XP] %L %d jeton par %s", client, to_id, szPseudo);
	}
	
	if( IsValidClient(invoker) && type != SynType_item ) {		
		char szSteamID2[64];
		GetClientAuthId(invoker, AUTH_TYPE, szSteamID2, sizeof(szSteamID2), false);
		
		Format(szPseudo, sizeof(szPseudo), "%N", invoker);
		Format(szSource, sizeof(szSource), "%s", szSteamID2);
	}
	
	Format(szLog, sizeof(szLog), "%s par %s (%s).", szLog, szPseudo, szSource);
	
	if( type != SynType_item && type != SynType_itemBank && type != SynType_xp && type != SynType_jetonpass ) {
		LogToGame(szLog);
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
				case 4: Format(model, sizeof(model), "models/player/custom_player/legacy/aiden_pearce/aiden_pearce.mdl");
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
			case 2: 	Format(model, sizeof(model), "models/player/custom_player/legacy/ctm_gendarmerie_variante.mdl");
			case 1: 	Format(model, sizeof(model), "models/player/custom_player/legacy/ctm_gendarmerie_variantc.mdl");
			
			case 109:	Format(model, sizeof(model), "models/player/custom_player/legacy/ctm_sas_variantd.mdl");
			case 108:	Format(model, sizeof(model), "models/player/custom_player/legacy/ctm_sas_variantd.mdl");
			case 107:	Format(model, sizeof(model), "models/player/custom_player/legacy/ctm_sas_variantd.mdl");
			
			case 106:	Format(model, sizeof(model), "models/player/custom_player/legacy/ctm_sas_variantc.mdl");
			case 105:	Format(model, sizeof(model), "models/player/custom_player/legacy/ctm_sas_variantc.mdl");
			case 104:	Format(model, sizeof(model), "models/player/custom_player/legacy/ctm_sas_variantc.mdl");
			
			case 103:	Format(model, sizeof(model), "models/player/custom_player/legacy/ctm_sas_variantg.mdl");
			case 102:	Format(model, sizeof(model), "models/player/custom_player/legacy/ctm_sas_variantg.mdl");
			case 101:	Format(model, sizeof(model), "models/player/custom_player/legacy/ctm_sas_variantg.mdl");
		}
	}

	if( strlen(model) < 16 || !FileExists(model, true) || PrecacheModel(model) == 0 ) {
		Format(model, sizeof(model), "models/player/custom_player/legacy/tm_phoenix.mdl");
	}
	
	Format(hands, sizeof(hands), "%s_EOF", model);
	ReplaceString(hands, sizeof(hands), ".mdl_EOF", "_arms.mdl");
	
	if( strlen(model) < 16 || !FileExists(hands, true) || PrecacheModel(hands) == 0 ) {
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
	SetEntProp(client, Prop_Send, "m_ScaleType", 1);
	
	char model[PLATFORM_MAX_PATH], hands[PLATFORM_MAX_PATH], prev[PLATFORM_MAX_PATH];
	getPlayerSkin(client, model, hands);
	Entity_GetModel(client, prev, sizeof(prev));
	
	if( !StrEqual(model, prev) && strlen(model) > 0 ) {
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
	int nextReboot = getNextReboot();
	
	for(int i=1; i<MAX_ENTITIES; i++) {
		if( !IsValidEdict(i) )
			continue;
		if( !IsValidEntity(i) )
			continue;
		if( rp_GetBuildingData(i, BD_FromBuild) == 1 )
			continue;
		
		GetEdictClassname(i, tmp, sizeof(tmp));
		
		if( rp_GetBuildingData(i, BD_owner) == client ) {
			float ratio = (1.0 - float(GetTime() - rp_GetBuildingData(i, BD_started)) / (5.0 * 60.0 * 60.0)) * 0.8;
			float reboot = Math_Clamp((float(nextReboot - rp_GetBuildingData(i, BD_started)) / (2.0 * 60.0 * 60.0)), 0.2, 1.0);
			float artisan = Math_Clamp((1.0 - float(g_iUserData[client][i_ArtisanLevel])*0.75), 0.1, 1.0);
			
			ratio = ratio * reboot;
			ratio = ratio * artisan;
			
			if( g_bUserData[client][b_FreeAssurance] == 1 ) {
				ratio = ratio * 0.66;
				
				if( (nextReboot - rp_GetBuildingData(i, BD_started)) < 60*60 )
					continue;
				
				if( g_iUserData[client][i_TimeAFK] > (1*60*60) ) {
					ratio = ratio * 0.1;
				}
			}
			
			if( ratio <= 0.0 || ratio >= 1.0 )
				continue;
			
			
			if( StrEqual(tmp, "rp_cashmachine") ) {
				amount += RoundFloat(100.0 * ratio);
			}
			else if( StrEqual(tmp, "rp_bigcashmachine") ) {
				amount += RoundFloat((5250.0 - (150.0*14.0)) * ratio);
			}
			else if( StrEqual(tmp, "rp_plant") ) {
				int item_id = rp_GetBuildingData(i, BD_original_id);
				if( item_id > 0 ) {
					amount += RoundFloat( StringToFloat(g_szItemList[item_id][item_type_prix]) * ratio);					
					if( rp_GetBuildingData(i, BD_max) > 3 ) {
						amount += (rp_GetBuildingData(i, BD_max) - 3) * 100;
					}
				}
			}
			else if( StrEqual(tmp, "rp_kevlarbox") ) {
				amount += RoundFloat(1500.0 * ratio);
			}
			else if( StrEqual(tmp, "rp_healbox") ) {
				amount += RoundFloat(100.0 * ratio);
			}
			else if( StrEqual(tmp, "rp_microwave") ) {
				amount += RoundFloat(8000.0 * ratio);
			}
			else if( StrEqual(tmp, "rp_table") ) {
				amount += RoundFloat(2500.0 * ratio);
			}
			else if( StrEqual(tmp, "rp_bank") ) {
				amount += RoundFloat(2500.0 * ratio);
			}
			else if( StrEqual(tmp, "rp_sign") ) {
				amount += RoundFloat(1000.0 * ratio);
			}
			else if( StrEqual(tmp, "rp_discoball") ) {
				amount += RoundFloat(2000.0 * ratio);
			}
			else if( StrEqual(tmp, "rp_discosmoke") ) {
				amount += RoundFloat(1000.0 * ratio);
			}
		}
		else if( !hasCas && StrContains(tmp, "prop_vehicle_") == 0 && g_iVehicleData[i][car_owner] == client ) {
			amount += 2000;
			hasCas = true;
		}
	}
	
	if( g_bUserData[client][b_HasGrave] ) {
		amount += 200;
	}
	
	if( !(g_bUserData[client][b_FreeAssurance] == 1 && (nextReboot - GetTime()) < 30*60) ) {
		int wepIdx;
		
		for( int i = 0; i < 5; i++ ) {
			
			if( i == CS_SLOT_KNIFE )
				continue;
			
			wepIdx = GetPlayerWeaponSlot( client, i );
			
			if( wepIdx <= 0 || !IsValidEdict(wepIdx) || !IsValidEntity(wepIdx) )
				continue;
			
			if( rp_GetWeaponStorage(wepIdx) )
				continue;
			
			amount += RoundFloat( float(rp_GetWeaponPrice(wepIdx)) * 0.5);
		}
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
				
				amount += (g_iAppartBonus[a][appart_bonus_paye] * 6);
			}
			else {
				amount += 600;
			}
		}
	}
	
	return amount;
}
void CopSetVisible(int client) {
	
	ClientCommand(client, "r_screenoverlay 0");
	Colorize(client, 255, 255, 255, 255);
	
	g_bUserData[client][b_Invisible] = 0;
	if( IsPolice(client) ) {
		g_bUserData[client][b_MaySteal] = false;
		CreateTimer(10.0, AllowStealing, client);
	}		
	CPrintToChat(client, "" ...MOD_TAG... " %T", "Visibility_Visible", client);
	g_flUserData[client][fl_invisibleTimeLeft] = GetGameTime() + 5.0;
}
void CopSetInvisible(int client) {
	
	Colorize(client, 255, 255, 255, 0);
	g_bUserData[client][b_Invisible] = true;
	ClientCommand(client, "r_screenoverlay effects/hsv.vmt");
	
	CPrintToChat(client, "" ...MOD_TAG... " %T", "Visibility_Invisible", client);
}
void CheckLiscence(int client) {	
	if(g_bUserData[client][b_License1]) {
		if(GetTime() > g_iUserData[client][i_StartLicense1] + (24*60*60)*14) {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "License_Expire_Secondary", client);
			g_bUserData[client][b_License1] = 0;
		}
	}
 
	if(g_bUserData[client][b_License2]) {
		if(GetTime() > g_iUserData[client][i_StartLicense2] + (24*60*60)*14) {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "License_Expire_Primary", client);
			g_bUserData[client][b_License2] = 0;
		}
	}
}
