#if defined _roleplay_event_players_included
#endinput
#endif
#define _roleplay_event_players_included

#if !defined _roleplay_base_included || defined ROLEPLAY_SUB
	#define ROLEPLAY_SUB
	#include "../roleplay.sp"
#else
	#include "roleplay.sp"
#endif 

public MRESReturn DHooks_OnVoicePost(int client, Handle hReturn, Handle hParams) {
	if( g_hClientMicTimers[client] != INVALID_HANDLE ) {
		delete g_hClientMicTimers[client];
	}
	
	g_hClientMicTimers[client] = CreateTimer(0.5, Timer_ClientMicUsage, client);
	return MRES_Ignored;
}  
public Action Timer_ClientMicUsage(Handle hTimer, int client) {	
	if( g_hClientMicTimers[client] != hTimer ) {
		return Plugin_Handled;
	}
	
	g_hClientMicTimers[client] = INVALID_HANDLE;
	return Plugin_Handled;
}

public Action EventFlashPlayer(Handle event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if( rp_GetZoneBit(rp_GetPlayerZone(client)) & BITZONE_PEACEFULL ) {
		SetEntPropFloat(client, Prop_Send, "m_flFlashMaxAlpha", 0.1);
	}
}

public void EventFirstSpawn(int client) {
	if( g_iSuccess_last_5tokill[client] == 0 && GetClientTeam(client) == CS_TEAM_T ) {
		g_iSuccess_last_5tokill[client] = GetTime();
	}
	
	CheckMP(client);
	if( g_iUserData[client][i_PlayerLVL] < 12 )
		g_bUserData[client][b_GameModePassive] = true;
	
	if( g_bUserData[client][b_ItemRecovered] && g_iClient_OLD[client] == 0 && g_iUserData[client][i_JailTime] == 0 && IsTutorialOver(client) )
		CreateTimer(1.0, HUD_WarnDisconnect, client);

	ServerCommand("sm_force_discord_group %d", client);
}
public Action HUD_WarnDisconnect(Handle timer, any client) {
	if( !g_bUserData[client][b_ItemRecovered] )
		return;
	char tmp[128];
	
	
	
	if( rp_ClientCanDrawPanel(client) ) {
		Menu menu = new Menu(HUD_WarnDisconnect_Handler);
		menu.SetTitle("%T", "HUD_WarnDisconnect", client);
		Format(tmp, sizeof(tmp), "%T", "Understand", client); menu.AddItem("yes", tmp);
		menu.Display(client, 2);
	}
	
	if( g_bUserData[client][b_ItemRecovered] )
		CreateTimer(1.0, HUD_WarnDisconnect, client);
}
public int HUD_WarnDisconnect_Handler(Handle menu, MenuAction action, int client, int param2) {
	if( action == MenuAction_Select ) {
		char options[64];
		GetMenuItem(menu, param2, options, 63);
		
		if( StrEqual(options, "yes") )
			g_bUserData[client][b_ItemRecovered] = false;
	}
	else if( action == MenuAction_End ) {
		CloseHandle(menu);
	}
}
public Action EventZoom(Handle ev, const char[] name, bool dontBroadcast) {
	int Client = GetClientOfUserId(GetEventInt(ev, "userid"));

	int wep = GetEntPropEnt(Client, Prop_Send, "m_hActiveWeapon");
	if( wep > 0 && IsValidEdict(wep) && IsValidEntity(wep) ) {
		int zoom = GetEntProp(wep, Prop_Send, "m_zoomLevel");
		if( zoom == 0 ) {
			if( g_iUserData[Client][i_ThirdPerson] == 1 ) {
				ClientCommand(Client, "thirdperson");
			}
		}
		else {
			if( g_iUserData[Client][i_ThirdPerson] == 1 ) {
				ClientCommand(Client, "firstperson");
			}
		}
	}
}
public Action OnWeaponCanSwitchTo(int Client, int weapon) {
	static char szWeapon[32];
	GetEdictClassname(weapon, szWeapon, sizeof(szWeapon));
	
	if( g_flUserData[Client][fl_TazerTime] > GetGameTime() || Client_GetVehicle(Client) > 0 ) {
		if( StrContains(szWeapon, "weapon_fists") != 0 ) {
			return Plugin_Handled;
		}
	}
	
	g_bUserData[Client][b_WeaponIsKnife] = (StrContains(szWeapon, "weapon_knife") == 0 || StrContains(szWeapon, "weapon_bayonet") == 0);
	g_bUserData[Client][b_WeaponIsHands] = (StrContains(szWeapon, "weapon_fists") == 0);
	g_bUserData[Client][b_WeaponIsMelee] = (StrContains(szWeapon, "weapon_melee") == 0);
	
	return Plugin_Continue;
}
public Action OnWeaponCanUse(int client, int weapon) {

	if( g_iWeaponsGroup[weapon] > 0 && g_iWeaponsGroup[weapon] != GetGroupPrimaryID(client) ) {
		return Plugin_Handled;
	}
	if( g_bUserData[client][b_IsAFK] ) {
		char classname[64];
		GetEdictClassname(weapon, classname, sizeof(classname));

		if( StrContains(classname, "weapon_knife") == 0 ||
			StrContains(classname, "weapon_bayonet") == 0 ||
			(GetEntProp(weapon, Prop_Data, "m_spawnflags") != 0 && GetEntProp(weapon, Prop_Data, "m_spawnflags") != 1 ) ) {
			return Plugin_Continue;
		}
		return Plugin_Handled;
	}
	else if( GetEntProp(weapon, Prop_Data, "m_spawnflags") == 1 ) {
		int job_tree = g_iUserData[client][i_Job];
		if( StringToInt( g_szJobList[ job_tree ][job_type_isboss] ) != 1 ) {
			job_tree = StringToInt( g_szJobList[ job_tree ][job_type_ownboss] );
		}

		int ClientZone = GetPlayerZone(client);
		int ClientZoneJob = StringToInt( g_szZoneList[ClientZone][zone_type_type] );

		if( ClientZoneJob > 0 && StringToInt( g_szJobList[ ClientZoneJob ][job_type_isboss] ) != 1 ) {
			ClientZoneJob = StringToInt( g_szJobList[ ClientZoneJob ][job_type_ownboss] );
		}

		int TargetZone = GetPlayerZone(weapon);
		int TargetZoneJob = StringToInt( g_szZoneList[TargetZone][zone_type_type] );

		if( StringToInt( g_szJobList[ TargetZoneJob ][job_type_isboss] ) != 1 ) {
			TargetZoneJob = StringToInt( g_szJobList[ TargetZoneJob ][job_type_ownboss] );
		}

		if( TargetZoneJob > 0 ) {

			if( ClientZoneJob != TargetZoneJob )
				return Plugin_Handled;

			if( job_tree != TargetZoneJob )
				return Plugin_Handled;
		}
		else  {
			int appart = getZoneAppart(client);
			if( !(appart > 0 && g_iDoorOwner_v2[client][appart]) ) {
				return Plugin_Handled;
			}
		}
		
		g_iWeaponFromStore[weapon] = 1;
	}

	if( (g_iWeaponStolen[weapon]+30) > GetTime() ) {
		g_flUserData[client][fl_LastStolen] = GetGameTime();
	}
	
	char classname[64];
	GetEntityClassname(weapon, classname, sizeof(classname));
	if( StrEqual(classname, "weapon_knife") ) {
		if( !Client_HasWeapon(client, classname) ) {
			EquipPlayerWeapon(client, weapon);
			return Plugin_Continue;
		}
	}

	return Plugin_Continue;
}

public Action CS_OnCSWeaponDrop(int client, int weapon) {
	if( !IsValidClient(client) )
		return Plugin_Continue;
	
	if( weapon >= 0 && IsValidEdict(weapon) &&  IsValidEntity(weapon) ) {
		int job = g_iUserData[client][i_Job];
		
		if( (job > 1 && job <= 9) || (job > 101 && job <= 109) ) {
			if( g_iWeaponFromStore[weapon] == 1 || g_bUserData[client][b_Stealing] ) {
				return Plugin_Handled;
			}
		}
		
		char classname[64];
		GetEdictClassname(weapon, classname, sizeof(classname));
		if( StrEqual(classname, "weapon_taser") ) {
			return Plugin_Handled;
		}
		
		g_iWeaponStolen[weapon] = GetTime();
	}

	return Plugin_Continue;
}

public Action OnClientCommandKeyValues(int client, KeyValues kv)  { 
	char sCmd[64];
	
	if ( kv.GetSectionName(sCmd, sizeof(sCmd)) && StrEqual(sCmd, "ClanTagChanged", false) ) {
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

public void CommandUse(int Client) {
	
	int target = IsAtBankPoint(Client);
	if( target ) {
		DisplayBankMenu(Client, target);
	}
	float f_ClientOrigin[3];
	GetClientAbsOrigin(Client, f_ClientOrigin);
		
	if( rp_GetPlayerZone(Client) == 181 ) {
		Cmd_QuestMenu(Client);
	}
	
	if( IsAtPhonePoint(Client) ) {
		Menu_DisplayPhone(Client);
	}
		
	if( g_iGrabbing[Client] > 0  ) {
		if( Client == rp_GetBuildingData(g_iGrabbing[Client], BD_owner) ) {
			float vecAngle[3];
			Entity_GetAbsAngles(g_iGrabbing[Client], vecAngle);
			vecAngle[0] = vecAngle[2] = 0.0;
			TeleportEntity(g_iGrabbing[Client], NULL_VECTOR, vecAngle, vecNull);
			rp_AcceptEntityInput(g_iGrabbing[Client], "Sleep");
			ScheduleEntityInput(g_iGrabbing[Client], 0.25, "Wake");
		}
	}

	Call_StartForward( view_as<Handle>(g_hRPNative[Client][RP_OnPlayerUse]) );
	Call_PushCell(Client);
	Call_Finish();
	
	int Ent = GetClientAimTarget(Client, false);

	if( Ent > MaxClients) {
		char classname[64];
		GetEdictClassname(Ent, classname, 63);

		if( StrEqual(classname, "money_entity", false) ) {

			float f_EntityOrigin[3];
			GetClientAbsOrigin(Client, f_ClientOrigin);
			GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", f_EntityOrigin);

			if( GetVectorDistance(f_ClientOrigin, f_EntityOrigin, false) <= 50.0 ) {
				MoneyEntityGotTouch(Ent, Client);
			}
		}

	}
	//Valid:
	if(IsValidDoor(Ent)) {
		ToggleDoor(Client, Ent);
	}
	else if( IsAmmunition(Ent) && IsEntitiesNear(Client, Ent, true) ) {
		SelectingAmmunition(Client, Ent);
	}

	return;
}

public Action Command_LAW(int client, const char[] command, int argc) {
	if( g_bUserData[client][b_LampePoche] == 1 ) {
		SetEntProp(client, Prop_Send, "m_bNightVisionOn", !GetEntProp(client, Prop_Send, "m_bNightVisionOn"));
	}
	if( g_bUserData[client][b_Jumelle] == 1 ) {
		int fov = Client_GetFOV(client);
		if( fov == 30 || (rp_GetZoneBit(rp_GetPlayerZone(client)) & BITZONE_EVENT) )
			Client_SetFOV(client, 90);
		else {
			Client_SetFOV(client, 30);
		}
	}

	g_bUserData[client][b_Pissing] = true;
}
public Action Command_LAW2(int client, const char[] command, int argc) {
	g_bUserData[client][b_Pissing] = false;
}


public Action EventPlayerTeam(Handle ev, const char[] name, bool broadcast) {	
	SetEventBool(ev, "silent", true);

	return Plugin_Changed;
}
public Action EventSpawn(Handle ev, const char[] name, bool broadcast) {
	int Client = GetClientOfUserId(GetEventInt(ev, "userid"));

	if( IsFakeClient(Client) )
		return Plugin_Continue;
	
	g_iCarPassager2[Client] = 0;
	SetClientViewEntity(Client, Client);
	
	int old = EntRefToEntIndex(g_iUserData[Client][i_FPD]);
	if( old > 0 ) {	
		rp_AcceptEntityInput(old, "Kill");
		g_iUserData[Client][i_FPD] = 0;
	}
	
	GetClientEyeAngles(Client, g_Position[Client]);
	Client_SetMoney(Client, 0);
	FakeClientCommand(Client, "use weapon_fists");
	g_bUserData[Client][b_WeaponIsKnife] = false;
	g_bUserData[Client][b_WeaponIsHands] = true;
	g_bUserData[Client][b_WeaponIsMelee] = false;
	
	if( g_iUserData[Client][i_ThirdPerson] == 1 )
		ClientCommand(Client, "thirdperson");
	else
		ClientCommand(Client, "firstperson");
	
	if( g_flUserData[Client][fl_Alcool] > 0.0 ) {
		g_flUserData[Client][fl_Alcool] -= 2.0;
		if( g_flUserData[Client][fl_Alcool] <= 0.0 ) {
			g_flUserData[Client][fl_Alcool] = 0.0;
			SendConVarValue(Client, FindConVar("host_timescale"), "1.0000");
		}
	}

	g_iUserData[Client][i_Kevlar] = 0;
	if( g_iUserData[Client][i_PlayerLVL] >= 156 )
		SetEntityHealth(Client, 200);
	if( g_iUserData[Client][i_PlayerLVL] >= 380 )
		SetEntityHealth(Client, 500);
	if( g_iUserData[Client][i_PlayerLVL] >= 272 )
		 g_iUserData[Client][i_Kevlar] = 100;
	if( g_iUserData[Client][i_PlayerLVL] >= 462 )
		 g_iUserData[Client][i_Kevlar] = 250;
	if( g_iUserData[Client][i_KnifeTrain] <= 4 )
		g_iUserData[Client][i_KnifeTrain] = 5;

	g_iGrabbing[Client] = 0;
	g_bIsSeeking[Client] = false;
	g_iKnifeType[Client] = ball_type_none;
	g_flUserData[Client][fl_Speed] = DEFAULT_SPEED;
	g_flUserData[Client][fl_Gravity] = 1.0;

	PerformFade(Client, 1, {0, 0, 0, 0});
	RP_PerformFade(Client);
	g_bUserData[Client][b_Drugged] = g_bUserData[Client][b_KeyReverse] = g_bUserData[Client][b_AdminHeal] = false;

	if( g_iUserData[Client][i_Cryptage] > 0 && Math_GetRandomInt(1, 4) == 1 ) {
		g_iUserData[Client][i_Cryptage]--;
	}

	
	Entity_SetMaxHealth(Client, 500);
	
	if( GetClientTeam(Client) == CS_TEAM_CT ) {	
		SetEntityHealth(Client, 500);
		g_iUserData[Client][i_Kevlar] = 250;
	}

	StripWeapons(Client);	

	CreateTimer(0.1, OnPlayerSpawnPost, GetClientUserId(Client));

	Call_StartForward( view_as<Handle>(g_hRPNative[Client][RP_OnPlayerSpawn]));
	Call_PushCell(Client);
	Call_Finish();

	Colorize(Client, 0, 0, 0, 0);
	
	if( g_bUserData[Client][b_isConnected] && g_bUserData[Client][b_isConnected2] )
		ServerCommand("sm_effect_fading %i 1.0", Client);

	if( g_iUserData[Client][i_Malus] < GetTime() ) {
		g_iUserData[Client][i_Malus] = 0;
	}

	g_iUserData[Client][i_Sickness] = 0;

	QueryClientConVar(Client, "cl_downloadfilter", view_as<ConVarQueryFinished>(ClientConVar), Client);
	QueryClientConVar(Client, "cl_join_advertise", view_as<ConVarQueryFinished>(ClientConVar), Client);
	ClientCommand(Client, "cam_idealpitch 0");
	

	if( g_iUserData[Client][i_JailTime] > 0 ) {
		return Plugin_Continue;
	}

	if( g_iSuccess_last_1st[Client] == 1 ) {
		WonSuccess(Client, success_list_only_one);
	}

	SetClientViewEntity(Client, Client);
	
	if( g_iUserData[Client][i_KnifeTrainAdmin] >= 0 ) {
		g_iUserData[Client][i_KnifeTrainAdmin] = -1;
	}
	if( g_iUserData[Client][i_FistTrainAdmin] >= 0 ) {
		g_iUserData[Client][i_FistTrainAdmin] = -1;
	}
	if( g_flUserData[Client][fl_WeaponTrainAdmin] >= 0.0 ) {
		g_flUserData[Client][fl_WeaponTrainAdmin] = -1.0;
	}
	
	if( GetClientTeam(Client) == CS_TEAM_CT && rp_GetClientJobID(Client) == 101 ) {
		float pos[3][3] =  {  { -321.1, -1650.4, -2007.9 }, { -328.3, -1845.0, -2007.9 }, { -319.2, -1444.5, -2007.9 } };
		TeleportClient(Client, pos[Math_GetRandomInt(0, 2)], NULL_VECTOR, NULL_VECTOR);
	}
	
	if( g_bUserData[Client][b_SpawnToGrave] &&
		!g_bUserData[Client][b_SpawnToMetro] && !g_bUserData[Client][b_SpawnToTribunal] && !g_bUserData[Client][b_SpawnToTueur] &&
		g_bUserData[Client][b_HasGrave] && !g_bIsInCaptureMode ) {
		CreateTimer(0.01, SendToGrave, Client);
	}
	else if( g_bUserData[Client][b_SpawnToMetro] &&
		!g_bUserData[Client][b_SpawnToTribunal] && !g_bUserData[Client][b_SpawnToTueur] ) {
		CreateTimer(0.01, SendToMetro, Client);
	}
	
	detectCapsLock(Client);
	updateBankCost(Client);
	rp_ClientOverlays(Client, o_OverlayNone);

	if( GetConVarInt(g_hSick) == 0 ) {
		g_iUserData[Client][i_Sick] = 0;
	}

	return Plugin_Continue;
}
public Action OnPlayerSpawnPost(Handle timer, any userid) {
	char classname[128];
	
	int client = GetClientOfUserId(userid);
	if( IsValidClient(client) ) {
		SetPersonalSkin(client);
		
		int ragdoll = GetEntPropEnt(client, Prop_Send, "m_hRagdoll");
		if( IsValidEdict(ragdoll) && IsValidEntity(ragdoll) )
			rp_AcceptEntityInput(ragdoll, "Kill", 0.1);
		
		for(int i=1; i<2048; i++) {
			if( !IsValidEdict(i) )
				continue;
			if( !IsValidEdict(i) )
				continue;
			if( i == ragdoll )
				continue;
			
			GetEntityClassname(i, classname, sizeof(classname));
			if( StrEqual(classname, "cs_ragdoll") ) {
				int player = GetEntPropEnt(i, Prop_Send, "m_hPlayer");
				
				if( player <= 0 || player == client )
					rp_AcceptEntityInput(i, "Kill", 0.1);
			}
		}
	}
}
public void ClientConVar(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue) {
	if( StrEqual(cvarName, "cl_downloadfilter", false) ) {
		if( StrEqual(cvarValue, "all") == false ) {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "cl_downloadfilter", client);
		}
	}
	if( StrEqual(cvarName, "cl_join_advertise", false) ) {
		if( StrEqual(cvarValue, "2") == false && Math_GetRandomInt(0, 4) ) {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "cl_join_advertise", client);
		}
	}
	
}
public Action EventDeath(Handle ev, const char[] name, bool broadcast) {
	static char weapon[64], client_name[128], target_name[128];
	int Client = GetClientOfUserId(GetEventInt(ev, "userid"));
	int Attacker = GetClientOfUserId(GetEventInt(ev, "attacker"));
	GetEventString(ev, "weapon", weapon, sizeof(weapon));
	
	float time = GetGameTime();
	float respawn = float(g_iUserData[Client][i_KillJailDuration]) + 5.0;
	
	killSpect(Client);
	respawn = Math_Clamp(respawn, 10.0, 40.0);
	
	if( GotPvPvPBonus(Client, cap_bunker) )
		respawn *= 0.75;
	if( g_iUserData[Client][i_PlayerLVL] >= 650 )
		respawn *= 0.75;
	
	
	float killAcceleration = getKillAcceleration(Attacker, Client, g_iUserData[Client][i_LastInflictor], weapon);
	int killDuration = 5;
	if( g_iKillLegitime[Attacker][Client] >= GetTime() || rp_GetZoneBit(rp_GetPlayerZone(Client)) & BITZONE_LEGIT ) {
		killDuration = 0;
	}
	
	if( Client_GetVehicle(Client) > 0 ) {
		int vehicleID = Client_GetVehicle(Client);
		
		for(int i=1; i<=MaxClients; i++) {
			if( !IsValidClient(i) )
				continue;
			if( g_iCarPassager[vehicleID][i] )
				LeaveVehiclePassager(i, vehicleID);
		}
	}
	
	g_iUserStat[Client][i_Deaths]++;
	showGraveMenu(Client);
	
	
	
	GetClientName2(Client, client_name, sizeof(client_name), false);
	if( IsValidClient(Attacker) )
		GetClientName2(Attacker, target_name, sizeof(target_name), false);

	g_iCarPassager2[Client] = 0;

	SetEventBroadcast(ev, true);
	
	int zone_victim = GetPlayerZone(Client);

	if( GetZoneBit( zone_victim ) & BITZONE_EVENT || GetConVarInt(g_hEVENT) == 2 ) {
		if( IsValidClient(Attacker) )
			g_iHideNextLog[Attacker][Client] = 1;

		g_flUserData[Client][fl_RespawnTime] = time + 1.0 + Math_GetRandomFloat(-0.33, 0.33);
		
		for(int i=1; i<=MaxClients; i++) {
			if( !IsValidClient(i) )
				continue;
			if( zone_victim != GetPlayerZone(i) )
				continue;

			CPrintToChat(i, "" ...MOD_TAG... " %T", ( Attacker <= 0 || Attacker == Client ) ? "Kill_Self" : "Kill_Target", i, client_name, target_name);
		}
		return Plugin_Continue;
	}
	
	if( GetZoneBit( zone_victim ) & BITZONE_EVENT && GetConVarInt(g_hEVENT) == 3 ) {
		g_flUserData[Client][fl_RespawnTime] = time + 1.0 + Math_GetRandomFloat(-0.33, 0.33);
		rp_ClientTeleport(Client, view_as<float>({4682.0, 11182.0, -2311.0}));
	}

	if( IsValidClient(g_iUserData[Client][i_BurnedBy]) && g_flUserData[Client][fl_Burning] > GetGameTime() && !IsValidClient(Attacker) ) {
		Attacker = g_iUserData[Client][i_BurnedBy];
		LogToGame("\"%L\" killed \%L\" with \"flame\"", Attacker, Client);
	}
	
	Action a, b = Plugin_Continue;
	
	Call_StartForward( view_as<Handle>(g_hRPNative[Client][RP_OnPlayerDead]));
	Call_PushCell(Client);
	Call_PushCell(Attacker);
	Call_PushCellRef(respawn);
	Call_PushCellRef(killDuration);
	Call_PushCellRef(killAcceleration);
	Call_Finish(a);
	
	if( IsValidClient(Attacker) ) {
		Call_StartForward( view_as<Handle>(g_hRPNative[Attacker][RP_OnPlayerKill]));
		Call_PushCell(Attacker);
		Call_PushCell(Client);
		Call_PushString(weapon);
		Call_PushCellRef(killDuration);
		Call_PushCellRef(killAcceleration);
		Call_Finish(b);
	}
	
	if( a >= Plugin_Handled || b >= Plugin_Handled ) {
		g_iHideNextLog[Attacker][Client] = 1;
	}
	
	if( Attacker ) {
		if( Attacker != Client) {
			g_iUserStat[Attacker][i_Kills]++;
			
			bool carkill = false;
			if( rp_GetZoneBit(rp_GetPlayerZone(Client)) & BITZONE_PERQUIZ || rp_GetZoneBit(rp_GetPlayerZone(Attacker)) & BITZONE_PERQUIZ ) {
				g_iHideNextLog[Attacker][Client] = 1;
			}
			
			if( (rp_GetZoneBit(rp_GetPlayerZone(Client)) & BITZONE_ROAD) && StrEqual(weapon, "prop_vehicle_driveable") ) {
				g_iHideNextLog[Attacker][Client] = 1;
				carkill = true;
			}
			
			
			if( IsInPVP(Attacker) && IsInPVP(Client) && GetGroupPrimaryID(Attacker) != GetGroupPrimaryID(Client) && GetGroupPrimaryID(Attacker) != 0 && GetGroupPrimaryID(Client) != 0 ) {

				char query[1024], szSteamID[32], szSteamID2[32];

				GetClientAuthId(Attacker, AUTH_TYPE, szSteamID, sizeof(szSteamID), false);
				GetClientAuthId(Client, AUTH_TYPE, szSteamID2, sizeof(szSteamID2), false);

				Format(query, sizeof(query), "INSERT INTO `rp_pvp` (`id`, `group_id`, `steamid`, `steamid2`, `time`, `time2`) VALUES (NULL, '%i', '%s', '%s', '%i', '%i');",
					GetGroupPrimaryID(Attacker),
					szSteamID, szSteamID2, g_iUserData[Attacker][i_PVP], g_iUserData[Client][i_PVP]
				);

				SQL_TQuery(g_hBDD, SQL_QueryCallBack, query, 0, DBPrio_Low);

				IncrementSuccess(Attacker, success_list_in_gang);
			}

			g_iUserData[Client][i_LastKilled] = Attacker;
			g_iUserData[Attacker][i_LastKilled_Reverse] = Client;

			if( g_iHideNextLog[Attacker][Client] == 0 ) {
				if( !(GetZoneBit( GetPlayerZone(Client) ) & BITZONE_EVENT || GetZoneBit( GetPlayerZone(Client) ) & BITZONE_PVP) ) {
					
					if( killDuration > 1 ) {
						if( killAcceleration >= 0.75 ) {
							if( rp_ClientFloodTriggered(Attacker, Client, fd_freekill1) )
								rp_ClientFloodIncrement(Attacker, Client, fd_freekill2, float(FREEKILL_TIME));
							rp_ClientFloodIncrement(Attacker, Client, fd_freekill1, float(FREEKILL_TIME));
						}
						g_iUserData[Attacker][i_KillingSpread]++;
					}
					
					g_iUserData[Attacker][i_KillJailDuration] += RoundToCeil(Pow(float(g_iUserData[Attacker][i_KillingSpread]*killDuration), killAcceleration));
					g_iUserData[Attacker][i_LastKillTime_ReduceTDM] = GetTime();
					g_iUserData[Attacker][i_LastKillTime_ReduceFK] = GetTime();
					g_iUserData[Attacker][i_LastKillTime] = GetTime();
				}


				if( (StrContains(weapon, "knife") == 0 || StrContains(weapon, "bayonet") == 0) ) {
					g_iUserData[Attacker][i_KnifeTrain]--;
					if( g_iUserData[Attacker][i_KnifeTrain] < 5 )
						g_iUserData[Attacker][i_KnifeTrain] = 5;
				}
				else if( StrContains(weapon, "prop_vehicle_driveable") == -1 && StrContains(weapon, "point_hurt") == -1 ) {
					g_flUserData[Attacker][fl_WeaponTrain] -= 0.1;
					if( g_flUserData[Attacker][fl_WeaponTrain] < 0.0 )
						g_flUserData[Attacker][fl_WeaponTrain] = 0.0;
				}


				if( rp_GetClientJobID(Attacker) == 51 && StrEqual(weapon, "prop_vehicle_driveable") && !g_bUserData[Attacker][b_GameModePassive] ) {
					g_iHideNextLog[Attacker][Client] = 1;
					carkill = true;
				}
				
				if( g_iHideNextLog[Attacker][Client] == 0 )
					DeathDrop(Client);
				else
					SetEntProp(Attacker, Prop_Send, "m_iNumRoundKills",  0);
			}
			
			if( g_iHideNextLog[Attacker][Client] == 0 ) {
				
				if( g_iUserData[Attacker][i_KillJailDuration] >= AUTOKICK_TDM ) {
					g_bUserData[Attacker][b_IsFreekiller] = true;
					ServerCommand("rp_SendToJail %d 0", Attacker);
					
					if( rp_GetClientInt(Attacker, i_JailTime) < g_iUserData[Attacker][i_KillJailDuration] * 60 )
						rp_SetClientInt(Attacker, i_JailTime, g_iUserData[Attacker][i_KillJailDuration] * 60);
				}
			}
			
			displayDeathOverlay(Client, Attacker, carkill);
			CheckDeadSuccess(Client, Attacker);			
		}
	}
	if( Client ) {

		if( g_bUserData[Client][b_Beacon] == 1 ) {
			CPrintToChatAll("" ...MOD_TAG... " %T", ( Attacker <= 0 || Attacker == Client ) ? "Kill_Self" : "Kill_Target", LANG_SERVER, client_name, target_name);
			g_bUserData[Client][b_Beacon] = 0;
		}
		
		if( StrEqual(weapon, "worldspawn", false) ) {
			displayDeathOverlay(Client, 0);
			CheckDeadSuccess(Client, 0);
		}

		if( g_bUserData[Client][b_Invisible] )
			CopSetVisible(Client);
	}


	for(int i=1; i<MaxClients; i++) {
		if( IsValidClient(i) ) {

			int flags = GetUserFlagBits(i);
			if ( flags & ADMFLAG_ROOT || flags & ADMFLAG_CHEATS ) {
				CPrintToChat(i, "" ...MOD_TAG... " %T", ( Attacker <= 0 || Attacker == Client ) ? "Kill_Self" : "Kill_Target", i, client_name, target_name);
			}
		}
	}

	FORCE_STOP(Client);

	if( Attacker > 0 && Attacker <= MaxClients ) {
		if( g_iGrabbing[Attacker] == Client ) {
			IncrementForceKill(Attacker, Client);

			FORCE_STOP(Attacker);
		}
	}
	
	if( IsInPVP(Client) || IsInPVP(Attacker) ) {
		
		if( g_bIsInCaptureMode && Client != Attacker && rp_GetClientGroupID(Attacker) > 0 && rp_GetClientGroupID(Client) > 0 ) {
			SetEventBroadcast(ev, false);
		}
		
		if( g_flUserData[Client][fl_RespawnTime] < time && respawn > 0.25 ) {
			respawn = 1.0;
			
			if( g_bIsInCaptureMode ) {
				g_bUserData[Client][b_SpawnToMetro] = true;
			}
		}
	}
	else if( g_bIsInCaptureMode && GetGroupPrimaryID(Client) > 0 ) {
		respawn = 1.0;
	}
	
	g_flUserData[Client][fl_RespawnTime] = time + respawn + Math_GetRandomFloat(-0.33, 0.33);

	return Plugin_Continue;
}
public Action EventBlockUserMessage(UserMsg msg_id, Handle bf, int[] players, int playersNum, bool reliable, bool init) {
	char buffer[25];
	PbReadString(bf, "msg_name", buffer, sizeof(buffer));
	if(StrEqual(buffer, "#Cstrike_Name_Change")) {
		return Plugin_Handled;
	}
	return Plugin_Continue;
}
public Action EventBlockMessage(Handle ev, const char[] name, bool  bd) {
	SetEventBroadcast(ev, true);

	if( StrEqual(name, "player_changename") ) {
		int client = GetClientOfUserId(GetEventInt(ev, "userid"));
		CreateTimer(0.001, BashCheckName, client);
	}
	if( StrEqual(name, "player_disconnect") ) {
		int client = GetClientOfUserId(GetEventInt(ev, "userid"));
		
		char tmp[128];
		GetEventString(ev, "reason", tmp, sizeof(tmp));
		if( StrContains(tmp, "DeltaEntMessage") != -1  ) {
			g_bUserData[client][b_Assurance] = true;
		}
	}

	return Plugin_Continue;
}
public Action EventPlayerFire(Handle ev, const char[] name, bool  bd) {
	int client = GetClientOfUserId(GetEventInt(ev, "userid"));
	char weapon[64];
	GetEventString(ev, "weapon", weapon, sizeof(weapon));
	
	if( !IsPlayerAlive(client) )
		return Plugin_Continue;
	
	if( g_bUserData[client][b_WeaponIsMelee] ) {
		if( StrContains(weapon, "weapon_hammer") == 0 || StrContains(weapon, "weapon_spanner") == 0 || StrContains(weapon, "weapon_axe") == 0 ) {
			float hit[3];
			if( rp_GetTargetHull(client, hit, 56.0) >= 0 ) {
				// TBD
			}
		}
	}
	
	return Plugin_Continue;	
}
public Action EventPlayerShot(Handle ev, const char[] name, bool  bd) {

	int client = GetClientOfUserId(GetEventInt(ev, "userid"));
	if( !IsPlayerAlive(client) )
		return Plugin_Continue;
	
	float vecOrigin[3];
	
	vecOrigin[0] = GetEventFloat(ev, "x");
	vecOrigin[1] = GetEventFloat(ev, "y");
	vecOrigin[2] = GetEventFloat(ev, "z");
	
	int entity = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	char weapon[32];
	float vecAngles[3], delta;
	
	GetClientWeapon(client, weapon, sizeof(weapon));
	
	if( IsValidEntity(entity) ) {
		if( g_iWeaponsBallType[entity] != ball_type_revitalisante )
			DetectionTirDangereux(client, vecOrigin);
		
		switch( g_iWeaponsBallType[entity] ) {
			case ball_type_paintball: {
				int rand = Math_GetRandomInt(0, 10);
		
				TE_SetupWorldDecal(vecOrigin, StringToInt(g_szPaintBall[rand][1]));
				TE_SendToAll();
			
				IncrementSuccess(client, success_list_moniteur);
			}
			case ball_type_explode: {
				float time = GetEntPropFloat(entity, Prop_Send, "m_flNextPrimaryAttack")-GetGameTime();
				float vecStart[3];
				GetClientEyePosition(client, vecStart);
		
				TE_SetupBeamPoints(vecStart, vecOrigin, g_cBeam, 0, 0, 30, 0.5, 4.0, 4.0, 1, 1.0, {250, 250, 250, 10}, 100);
				TE_SendToAll();
		
				if( StrEqual(weapon, "weapon_nova") || StrEqual(weapon, "weapon_sawedoff") || StrEqual(weapon, "weapon_mag7") ) {
					time = 0.10;
				}
				time *= 1.5;
				ExplosionDamage(vecOrigin, time * 50.0, 64.0, client, entity);
			}
			case ball_type_reflexive: {
				DoReflexive(client);
			}
		}
		
		if( HasEntProp(entity, Prop_Send, "m_zoomLevel") && GetEntProp(entity, Prop_Send, "m_zoomLevel") > 0 ) {
			if(	StrEqual(weapon, "weapon_scout") || StrEqual(weapon, "weapon_sg550") ||
				StrEqual(weapon, "weapon_ssg08") || StrEqual(weapon, "weapon_awp") ||
				StrEqual(weapon, "weapon_g3sg1") ) {
		
				
				GetClientEyeAngles(client, vecAngles);
				vecAngles[0] += delta;
				vecAngles[1] += delta;
				
				TeleportEntity(client, NULL_VECTOR, vecAngles, NULL_VECTOR);
			}
		}
	}
	
	if( g_bUserData[client][b_Debuging] ) {
		
		float vecDestination[3];
		GetClientEyePosition(client, vecDestination);
		
		TE_SetupBeamPoints(vecOrigin, vecDestination, g_cBeam, g_cBeam, 0, 0, 10.0, 1.0, 1.0, 0, 0.0, { 255, 0, 0, 255 }, 0);
		TE_SendToClient(client);
		
		PrintToChat(client, "%.1f %.1f %.1f", vecOrigin[0], vecOrigin[1], vecOrigin[2]);
	}
	
	return Plugin_Continue;
}
