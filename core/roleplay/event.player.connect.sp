#if defined _roleplay_event_players_connect_included
#endinput
#endif
#define _roleplay_event_players_connect_included

#if !defined _roleplay_base_included || defined ROLEPLAY_SUB
	#define ROLEPLAY_SUB
	#include "../roleplay.sp"
#else
	#include "roleplay.sp"
#endif

public void OnClientPutInServer(int Client) {
	check_dead(Client);
	g_iEntityLimit = GetConVarInt(g_hMAX_ENT);
	g_hAggro[Client] = new ArrayList(KillStack_max, 0);
}
public void OnClientPostAdminCheck(int Client) {
	if(!IsFakeClient(Client)) {

		char strIP[64], strIP2[64];
		GetClientIP(Client, strIP, sizeof(strIP));
		LogToGame("[TSX-RP] Loading userdata %L %s", Client, strIP);

		int found = false;
		for(int i=0; i<MAX_PLAYERS; i++) {
			if( !IsValidClient(i) )
				continue;
			if( i == Client )
				continue;

			GetClientIP(i, strIP2, sizeof(strIP2));
			if( StrEqual(strIP, strIP2) ) {
				found = true;
				LogToGame("Double compte: %L", Client);
			}
		}
		if( found ) {
			LogToGame("Double compte: %s %L", strIP, Client);
		}

		LoadUserData(Client);
		CheckMute(Client);
		

		int amount = 0;
		for(int i=1; i<=MaxClients; i++) {
			if( !IsValidClient(i) )
				continue;
			if( IsFakeClient(i) )
				continue;
			if( i == Client)
				continue;

			amount++;
		}

		if( amount == 0 ) {
			g_iSuccess_last_1st[Client] = 1;
		}
		else {
			g_iSuccess_last_1st[Client] = 0;
		}
	}
}
public void OnClientDisconnect(int Client) {
	static Handle cvar;
	if( cvar == INVALID_HANDLE )
		cvar = FindConVar("host_timescale");
	
	Handle iterator = GetPluginIterator();
	while( MorePlugins(iterator) ) {
		Handle plugin = ReadPlugin(iterator);
		for (int i = 0; i < view_as<int>(RP_EventMax); i++)
			RemoveAllFromForward(g_hRPNative[Client][i], plugin);
	}
	
	delete g_hAggro[Client];
	
	int old = EntRefToEntIndex(g_iUserData[Client][i_FPD]);
	if( old > 0 ) {
		SetClientViewEntity(Client, Client);
		rp_AcceptEntityInput(old, "Kill");
		g_iUserData[Client][i_FPD] = 0;
	}
	
	if( g_hTIMER[Client] )
		delete g_hTIMER[Client];
	
	ClientCommand(Client, "r_screenoverlay \"\"");
	
	if(!IsFakeClient(Client) && g_bUserData[Client][b_isConnected]) {
		
		SendConVarValue(Client, cvar, "1.0");
		FORCE_STOP(Client);
		FORCE_Release(Client);
		
		
		
		for(int i=1; i<=MAX_PLAYERS; i++) {
			if( !IsValidClient(i) )
				continue;
				
			if( g_iUserData[i][i_LastKilled] == Client )
				g_iUserData[i][i_LastKilled] = 0;
		}
		
		QuestClean(Client);
		rp_ClientMoney(Client, i_Money, g_iUserData[Client][i_AddToPay]);
		g_iUserData[Client][i_AddToPay] = 0;
		StoreUserData(Client);

		g_bUserData[Client][b_isConnected]  = 0;
		g_bUserData[Client][b_isConnected2]  = 0;
		
		for(int a=1; a<MAX_KEYSELL; a++) {
			
			if( g_iAppartBonus[a][appart_proprio] <= 0 )
				continue;
			
			if( g_iAppartBonus[a][appart_proprio] != Client )
				continue;
				
			int rand[MAX_PLAYERS+1], mnt=0;
			for(int i=1; i<=MAX_PLAYERS; i++) {
				if( !IsValidClient(i) )
					continue;
				if( Client == i )
					continue;
				
				if( g_iDoorOwner_v2[i][a] ) {
					rand[mnt] = i;
					mnt++;
				}
			}
			
			if( mnt > 0 ) {
				g_iAppartBonus[a][appart_proprio] = rand[GetRandomInt(0, mnt-1)];
			}
			else {
				g_iAppartBonus[a][appart_proprio] = 0;
			}
		}
		
		char classname[64];
		for(int i=MaxClients-1; i < MAX_ENTITIES; i++) {
			
			if( !IsValidEdict(i) )
				continue;
			if( !IsValidEntity(i) )
				continue;
			
			if( rp_GetBuildingData(i, BD_owner) == Client ) {
				
				GetEdictClassname(i, classname, 63);
				if( StrContains(classname, "prop_physic") == 0 ||
					StrContains(classname, "rp_grave") == 0 ||
					StrContains(classname, "rp_microwave") == 0 ||
					StrContains(classname, "rp_table") == 0 ||
					StrContains(classname, "rp_sign") == 0 ||
					StrContains(classname, "rp_bank") == 0
					) {
					rp_AcceptEntityInput(i, "Kill");
				}
			}
		}
	}
	
	return;
}
