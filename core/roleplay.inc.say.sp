#if defined _roleplay_say_included
#endinput
#endif
#define _roleplay_say_included

#if defined ROLEPLAY_SUB
	#include "../roleplay.sp"
#else
	#include "roleplay.sp"
#endif

// -----------------------------------------------------------------------------------------------------------------
//
//	say & say_team
//
// say

public Action Command_Say(int client, int args) {
	if( !IsValidClient(client) ) {
		return Plugin_Handled;
	}
	if( !IsPlayerAlive(client) ) {
		CPrintToChat(client, "" ...MOD_TAG... " Vous devez être en vie pour parler.");
		return Plugin_Handled;
	}

	int target = rp_GetClientTarget(client);

	char szSayText[256], szSayTrig[33], name[128], cmd[32];

	GetCmdArgString(szSayText, sizeof(szSayText));

	StripQuotes(szSayText);
	BreakString(szSayText, szSayTrig, sizeof(szSayTrig));
	
	GetClientName2(client, name, sizeof(name), false);
	
	String_Trim(szSayTrig, cmd, sizeof(szSayTrig), "/! \t\r\n");
	String_ToLower(cmd, cmd, sizeof(cmd));
	
	if( !g_bUserData[client][b_Crayon] )
		CRemoveTags(szSayText, sizeof(szSayText));
	
	Action act = Plugin_Continue;
	Call_StartForward( view_as<Handle>(g_hRPNative[client][RP_PrePlayerTalk]) );
	Call_PushCell(client);
	Call_PushStringEx(szSayText, sizeof(szSayText), SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_PushCell(sizeof(szSayText));
	Call_PushCell(false);
	Call_Finish(act);
	
	if( act == Plugin_Handled || act == Plugin_Stop )
		return Plugin_Handled;

	if( strlen(szSayText) == 0 )
		return Plugin_Continue;

	bool removed = RemoveString(szSayText, szSayTrig);

	if(strcmp(szSayTrig, "!plainte", false) == 0 || strcmp(szSayTrig, "/plainte", false) == 0) {

		if( !IsClientInJail(client) ) {
			ACCESS_DENIED(client);
		}
		
		// Setup menu
		Handle menu = CreateMenu(MenuTribunal_plainte);
		char steamID[32], nickname[65];
		
		SetMenuTitle(menu, "Porter plainte contre un policier\n ");

		for(int i=1; i<=MaxClients; i++) {
			if( !IsValidClient(i) )
				continue;
			if( i == client )
				continue;
			if( !IsPolice(i) && !IsJuge(i) )
				continue;

			GetClientAuthId(i, AUTH_TYPE, steamID, sizeof(steamID), false);
			GetClientName(i, nickname, sizeof(nickname));
			
			AddMenuItem(menu, steamID, nickname);
		}

		SetMenuExitButton(menu, true);
		DisplayMenu(menu, client, MENU_TIME_DURATION);

		return Plugin_Handled;
	}
	if(strcmp(szSayTrig, "!peine", false) == 0 || strcmp(szSayTrig, "/peine", false) == 0) {

		if( !IsClientInJail(client) ) {
			ACCESS_DENIED(client);
		}
		
		g_bUserData[client][b_ExitJailMenu] = false;

		return Plugin_Handled;
	}
	else if( strcmp(szSayTrig, "!site", false) == 0 || strcmp(szSayTrig, "/site", false) == 0 ) {		
		RP_ShowMOTD(client, "https://www.riplay.fr/");

		return Plugin_Handled;
	}
	else if( strcmp(szSayTrig, "!craft", false) == 0 || strcmp(szSayTrig, "/craft", false) == 0 ) {
			
		RP_ShowMOTD(client, "https://rpweb.riplay.fr/craft.php");

		return Plugin_Handled;
	}
	else if(strcmp(szSayTrig, "!success", false) == 0 || strcmp(szSayTrig, "/success", false) == 0 ||
			strcmp(szSayTrig, "!sucess", false) == 0 || strcmp(szSayTrig, "/sucess", false) == 0 ||
			strcmp(szSayTrig, "!succes", false) == 0 || strcmp(szSayTrig, "/succes", false) == 0 ||
			strcmp(szSayTrig, "!succès", false) == 0 || strcmp(szSayTrig, "/succès", false) == 0
			
		) {
		
		Draw_Success(client, -1);
		
		return Plugin_Handled;
	}
	else if( strcmp(szSayTrig, "!a", false) == 0		|| strcmp(szSayTrig, "/a", false) == 0
	) {
		int flags = GetUserFlagBits(client);
		if (!(flags & ADMFLAG_GENERIC || flags & ADMFLAG_ROOT)) {
			ACCESS_DENIED(client);
		}

		CPrintToChatAll("{red} =================================={default} ");
		CPrintToChatAll("{lightblue}%s{default} ({red}ADMIN{default}): %s", name, szSayText);
		CPrintToChatAll("{red} =================================={default} ");

		return Plugin_Handled;
	}
	
	if( GetZoneBit( GetPlayerZone(client) ) & BITZONE_BLOCKTALK ) {
		ACCESS_DENIED(client);
	}
	if(	strcmp(szSayTrig, "!screen", false) == 0	|| strcmp(szSayTrig, "/screen", false) == 0 ) {

		int val = GetEntProp(client, Prop_Send, "m_bDrawViewmodel");
		int hud = GetEntProp(client, Prop_Send, "m_iHideHUD");

		if( val == 1 ) {
			FakeClientCommand(client, "use weapon_fists");
			
			SetEntProp(client, Prop_Send, "m_bDrawViewmodel", 0);
			SendConVarValue(client, FindConVar("sv_max_allowed_net_graph"), "0");

			for(int i=4; i<=10; i++) {
				hud |= (1<<i);
			}
			SetEntProp(client, Prop_Send, "m_iHideHUD", hud);
		}
		else {
			SetEntProp(client, Prop_Send, "m_bDrawViewmodel", 1);
			SendConVarValue(client, FindConVar("sv_max_allowed_net_graph"), "1");
			
			for(int i=4; i<=10; i++) {
				hud &= ~(1<<i);
			}
			SetEntProp(client, Prop_Send, "m_iHideHUD", hud);
		}
		return Plugin_Handled;
	}
	if(	strcmp(szSayTrig, "!money", false) == 0	|| strcmp(szSayTrig, "/money", false) == 0	||
		strcmp(szSayTrig, "!statut", false) == 0	|| strcmp(szSayTrig, "/statut", false) == 0	||
		strcmp(szSayTrig, "!hud", false) == 0	|| strcmp(szSayTrig, "/hud", false) == 0	||
		strcmp(szSayTrig, "!s", false) == 0	|| strcmp(szSayTrig, "/s", false) == 0	||
		strcmp(szSayTrig, "!status", false) == 0	|| strcmp(szSayTrig, "/status", false) == 0
	) {

		char szHours[64];
		PrintHours(szHours, 63);
		int i = client;
		CPrintToChat(client, "" ...MOD_TAG... " Argent: %d$ - En Banque: %d$ - Job: %s", g_iUserData[i][i_Money], g_iUserData[i][i_Bank], g_szJobList[g_iUserData[i][i_Job]][0]);

		return Plugin_Handled;
	}
	else if(	strcmp(szSayTrig, "!passive", false) == 0 || strcmp(szSayTrig, "/passive", false) == 0 ||
				strcmp(szSayTrig, "!passif", false) == 0 || strcmp(szSayTrig, "/passif", false) == 0 ||
				strcmp(szSayTrig, "!active", false) == 0 || strcmp(szSayTrig, "/active", false) == 0 ||
				strcmp(szSayTrig, "!actif", false) == 0 || strcmp(szSayTrig, "/actif", false) == 0) {
		
		if( g_iUserData[client][i_PlayerLVL] < 2 ) {
			CPrintToChat(client, "" ...MOD_TAG... " Vous devez être au moins de niveau 2, afin d'utiliser cette commande.");
			return Plugin_Handled;
		}
		
		Draw_PassiveMenu(client);
		return Plugin_Handled;
	}
	else if(	strcmp(szSayTrig, "!vita", false) == 0 || strcmp(szSayTrig, "/vita", false) == 0 ) {

		CPrintToChat(client, "" ...MOD_TAG... " %.2f points de vitalité, niveau: %d", g_flUserData[client][fl_Vitality], GetVitaLevel(client));
		return Plugin_Handled;
	}
	else if(
		strcmp(szSayTrig, "!rules", false) == 0 || strcmp(szSayTrig, "/rules", false) == 0 ||
		strcmp(szSayTrig, "!regles", false) == 0 || strcmp(szSayTrig, "/regles", false) == 0 ||
		strcmp(szSayTrig, "!code", false) == 0 || strcmp(szSayTrig, "/code", false) == 0
	) {			
		char url[1024], sso[128];
		SSO_Forum(client, sso, sizeof(sso));
			
		Format(url, sizeof(url), "https://forum.riplay.fr/index.php?/forum/60-r%C3%A8glements-roleplay/", sso);
		RP_ShowMOTD(client, url);

		return Plugin_Handled;
	}
	else if(strcmp(szSayTrig, "!rev", false) == 0 || strcmp(szSayTrig, "/rev", false) == 0) {

		CPrintToChat(client, "" ...MOD_TAG... " Derniere revision: %s %s TAG: %s", __TIME__, __DATE__, __LAST_REV__);

		return Plugin_Handled;
	}
	else if(strcmp(szSayTrig, "!use", false) == 0 || strcmp(szSayTrig, "/use", false) == 0) {
		
		if( IsValidDoor(target) && Entity_GetDistance(client, target) < MAX_AREA_DIST ) {
			
			int door_bdd = g_iDoorDouble[target - MaxClients ];
			int wasLocked = GetEntProp(target, Prop_Data, "m_bLocked");
			bool canUnlock = IsPlayerHaveKey(client, target, 2);
			bool canLock = IsPlayerHaveKey(client, target, 1);

			if( wasLocked && canUnlock ) {
				SetEntProp(target, Prop_Data, "m_bLocked", 0);
				if( door_bdd > 0 )
					SetEntProp(door_bdd+MaxClients, Prop_Data, "m_bLocked", 0);
			}
			
			if( canUnlock || !wasLocked ) {
				rp_AcceptEntityInput(target, "Toggle", client);
				if( door_bdd > 0 )
					rp_AcceptEntityInput(door_bdd+MaxClients, "Toggle", client);
			}

			if( wasLocked && canLock ) {
				ScheduleEntityInput(target, 0.001, "Lock");
				if( door_bdd > 0 )
					ScheduleEntityInput(door_bdd+MaxClients, 0.001, "Lock");
			}
		}
		else if( rp_GetBuildingData(target, BD_owner) == client ) {
			float vecAngles[3];
			Entity_GetAbsAngles(target, vecAngles);
			vecAngles[1] += 45.0;
			if( vecAngles[1] > 360.0 )
				vecAngles[1] -= 360.0;
			
			TeleportEntity(target, NULL_VECTOR, vecAngles, NULL_VECTOR);
		}

		return Plugin_Handled;
	}
	else if(strcmp(szSayTrig, "!forceuse", false) == 0 || strcmp(szSayTrig, "/forceuse", false) == 0) {

		if( !IsAdmin(client) ) {
			ACCESS_DENIED(client);
		}

		//Open:
		rp_AcceptEntityInput(target, "Toggle", client);

		return Plugin_Handled;
	}
	else if(strcmp(szSayTrig, "!forcelock", false) == 0 || strcmp(szSayTrig, "/forcelock", false) == 0) {

		if( !IsAdmin(client) ) {
			ACCESS_DENIED(client);
		}

		g_iDoorNouse[ (target - MaxClients) ] = 1;


		return Plugin_Handled;
	}
	else if(strcmp(szSayTrig, "!forceunlock", false) == 0 || strcmp(szSayTrig, "/forceunlock", false) == 0) {


		if( !IsAdmin(client) ) {
			ACCESS_DENIED(client);
		}

		g_iDoorNouse[ (target - MaxClients) ] = 0;

		return Plugin_Handled;
	}
	else if(strcmp(szSayTrig, "!lock", false) == 0 || strcmp(szSayTrig, "/lock", false) == 0) {

		target = GetClientAimTarget(client, false);
		if( !IsValidDoor(target) && IsValidEdict(target) && IsValidDoor(Entity_GetParent(target)) )
			target = Entity_GetParent(target);

		ToggleDoorLock(client, target, 1);

		return Plugin_Handled;
	}
	else if(strcmp(szSayTrig, "!unlock", false) == 0 || strcmp(szSayTrig, "/unlock", false) == 0) {

		target = GetClientAimTarget(client, false);
		if( !IsValidDoor(target) && IsValidEdict(target) && IsValidDoor(Entity_GetParent(target)) )
			target = Entity_GetParent(target);

		ToggleDoorLock(client, target, 2);

		return Plugin_Handled;
	}
	else if( strcmp(szSayTrig, "!leave", false) == 0 || strcmp(szSayTrig, "/leave", false) == 0 ||
	strcmp(szSayTrig, "!quitter", false) == 0 || strcmp(szSayTrig, "/quitter", false) == 0
	) {

		int door = target;
		int door_bdd = (door-MaxClients);

		if( !IsValidDoor(door) || !g_iDoorKnowed[door_bdd] ) {
			CPrintToChat(client, "" ...MOD_TAG... " Vous devez viser une porte.");
			return Plugin_Handled;
		}
		int can = -1;
		for(int a=0; a<MAX_KEYSELL; a++) {
			if( can != -1 )
				break;

			char ParentList[11][12];
			ExplodeString(g_szSellingKeys[a][key_type_parent], "-", ParentList, 10, 12);

			for(int b=0; b<=10; b++) {
				if( StringToInt(ParentList[b]) <= 0 )
					continue;
				if( StringToInt(ParentList[b]) == door_bdd ) {
					can = a;
					break;
				}
			}
		}
		if( can == -1 ) {
			CPrintToChat(client, "" ...MOD_TAG... " Vous devez viser un appartement.");
			return Plugin_Handled;
		}
		if( !g_iDoorOwner_v2[client][can] ) {
			CPrintToChat(client, "" ...MOD_TAG... " Vous n'êtes pas propriétaire de cet appartement.");
			return Plugin_Handled;
		}
		
		g_iDoorOwner_v2[client][can] = 0;
		g_iUserData[client][i_AppartCount]--;
		
		if( g_iAppartBonus[can][appart_proprio] == client ) {
			int rand[MAX_PLAYERS+1], mnt=0;
			for(int i=1; i<=MAX_PLAYERS; i++) {
				if( !IsValidClient(i) )
					continue;
				if( client == i )
					continue;
					
				if( g_iDoorOwner_v2[i][can] )
					rand[mnt++] = i;
			}
			g_iAppartBonus[can][appart_proprio] = mnt > 0 ? rand[GetRandomInt(0, mnt - 1)] : 0;
		}
		CPrintToChat(client, "" ...MOD_TAG... " Vous avez quitté votre appartement.");
		return Plugin_Handled;
	}
	else if( strcmp(szSayTrig, "!appart", false) == 0 || strcmp(szSayTrig, "/appart", false) == 0 ||
			strcmp(szSayTrig, "!appart", false) == 0 || strcmp(szSayTrig, "/appart", false) == 0
	) {
		
		// Setup menu
		Handle menu = CreateMenu(MenuNothing);
		SetMenuTitle(menu, "Liste des appartements\n ");
		char tmp[256];
		
		int count;
		for(int i=0; i<MAX_KEYSELL; i++) {
			
			if( strlen(g_szSellingKeys[i][key_type_name]) <= 1 )
				continue;
			
			if( g_iAppartBonus[i][appart_proprio] > 0 ) {
				Format(tmp, sizeof(tmp), "Appart %s: %N", g_szSellingKeys[i][key_type_name], g_iAppartBonus[i][appart_proprio]);
			}
			else {
				Format(tmp, sizeof(tmp), "Appart %s: Disponible", g_szSellingKeys[i][key_type_name]);
				count++;
			}
			
			AddMenuItem(menu, tmp, tmp,		ITEMDRAW_DISABLED);
		}
		
		CPrintToChat(client, "" ...MOD_TAG... " Il y a %d appartement(s) disponible", count);
		
		SetMenuExitButton(menu, true);
		DisplayMenu(menu, client, MENU_TIME_DURATION);
		
		return Plugin_Handled;
	}
	else if( strcmp(szSayTrig, "!tuto", false) == 0 || strcmp(szSayTrig, "/tuto", false) == 0 ||
			strcmp(szSayTrig, "!tuto", false) == 0 || strcmp(szSayTrig, "/tuto", false) == 0
	) {
		
		// Setup menu
		Handle menu = CreateMenu(MenuNothing);
		SetMenuTitle(menu, "Liste des nouveaux joueurs\n ");
		char tmp[256];
		
		bool canSeeint = false;
		
		int flags = GetUserFlagBits(client);
		if (flags & ADMFLAG_GENERIC || flags & ADMFLAG_ROOT ||
			(GetJobPrimaryID(client) == g_iUserData[client][i_Job] && g_iUserData[client][i_Job] > 0 && g_iUserData[target][i_Job] == 0 ) ||
			IsJuge(client) || IsPolice(client) ) {
			canSeeint = true;
		}
		int count;
		for(int i=1; i<=MaxClients; i++) {
			if( !IsValidClient(i) )
				continue;
			
			if( !IsTutorialOver(i) ) {
				Format(tmp, sizeof(tmp), "TUTORIAL: %N - %s", i, g_szZoneList[ GetPlayerZone(i) ][zone_type_name]);
				count++;
				AddMenuItem(menu, tmp, tmp,		ITEMDRAW_DISABLED);
			}
			else if( canSeeint && g_iUserData[i][i_Job] > 0 && !g_iClient_OLD[i] ) {
				Format(tmp, sizeof(tmp), "DEBUTANT: %N - %s", i, g_szZoneList[ GetPlayerZone(i) ][zone_type_name]);
				count++;
				AddMenuItem(menu, tmp, tmp,		ITEMDRAW_DISABLED);
			}
			else if( canSeeint && g_iUserData[i][i_Job] == 0 && !g_iClient_OLD[i] ) {
				Format(tmp, sizeof(tmp), "SANS EMPLOI: %N - %s", i, g_szZoneList[ GetPlayerZone(i) ][zone_type_name]);
				count++;
				AddMenuItem(menu, tmp, tmp,		ITEMDRAW_DISABLED);
			}
			
			
		}
		
		CPrintToChat(client, "" ...MOD_TAG... " Il y a %d nouveau(x) joueur(s)", count);
		
		SetMenuExitButton(menu, true);
		DisplayMenu(menu, client, MENU_TIME_DURATION);
		
		return Plugin_Handled;
	}
	else if(	strcmp(szSayTrig, "!vol", false) == 0		|| strcmp(szSayTrig, "/vol", false) == 0	) {

		if( GetZoneBit( GetPlayerZone(client) ) & BITZONE_BLOCKSTEAL ) {
			ACCESS_DENIED(client);
		}
		if( g_bUserData[client][b_MaySteal] == 0 || g_iUserData[client][i_LastVolCashFlowTime] > GetTime() ) {
			CPrintToChat(client, "" ...MOD_TAG... " Vous ne pouvez pas voler pour le moment.");
			return Plugin_Handled;
		}
		if( GetConVarInt(g_hAllowSteal) == 0 ) {
			CPrintToChat(client, "" ...MOD_TAG... " Vous ne pouvez pas voler pour le moment.");
			return Plugin_Handled;
		}
		
		if( !IsValidClient(target))
			return Plugin_Handled;

		if( !IsPlayerAlive(target) )
			return Plugin_Handled;
			
		if( g_flUserData[target][fl_Invincible] >= GetGameTime() ) {
			CPrintToChat(client, "" ...MOD_TAG... " Vous ne pouvez pas voler cette personne.");
			return Plugin_Handled;
		}
		if( (g_flUserData[target][fl_LastVente]+8.0) >= GetGameTime() ) {
			CPrintToChat(client, "" ...MOD_TAG... " Vous ne pouvez pas voler cette personne.");
			return Plugin_Handled;
		}
		if( !IsTutorialOver(target) ) {
			CPrintToChat(target, "" ...MOD_TAG... " %N{default} n'a pas terminé le tutorial.", target);
			return Plugin_Handled;
		}
		
		if( !IsEntitiesNear(client, target) ) {
			CPrintToChat(client, "" ...MOD_TAG... " Ce joueur est trop éloigné.");
			return Plugin_Handled;
		}
		
		Action a;
		float cd = STEAL_TIME;
		
		Call_StartForward( view_as<Handle>(g_hRPNative[client][RP_OnPlayerSteal]));
		Call_PushCell(client);
		Call_PushCell(target);
		
		Call_PushCellRef(cd);
		Call_Finish(a);
		
		if( a != Plugin_Stop ) {
			ACCESS_DENIED(client);
		}
		
		g_bUserData[client][b_MaySteal] = 0;
		CreateTimer(cd, AllowStealing, client);

		return Plugin_Handled;
	}
	if(	strcmp(szSayTrig, "!report", false) == 0		|| strcmp(szSayTrig, "/report", false) == 0 ) {

		// Setup menu
		Handle menu = CreateMenu(MenuTribunal_report);
		char steamID[32], nickname[65];
		
		SetMenuTitle(menu, "Rapporter un joueur Tribunal forum\n ");

		for(int i=1; i<=MaxClients; i++) {
			if( !IsValidClient(i) )
				continue;
			if( i == client )
				continue;

			GetClientAuthId(i, AUTH_TYPE, steamID, sizeof(steamID), false);
			GetClientName(i, nickname, sizeof(nickname));
			
			AddMenuItem(menu, steamID, nickname);
		}

		SetMenuExitButton(menu, true);
		DisplayMenu(menu, client, MENU_TIME_DURATION);

		return Plugin_Handled;
	}
	else if(	strcmp(szSayTrig, "!boss", false) == 0		|| strcmp(szSayTrig, "/boss", false) == 0 ) {

		if( !IsBoss(client) ) {
			ACCESS_DENIED(client);
		}

		OpenBossConfig(client);

		return Plugin_Handled;
	}
	else if(strcmp(szSayTrig, "!map", false) == 0	|| strcmp(szSayTrig, "/map", false) == 0 ) {
		if( GetConVarInt(FindConVar("hostport")) == 27025 ) {
			char mapname[64];
			GetCurrentMap(mapname, sizeof(mapname));
			if( StrContains(mapname, "906681141") >= 0 )
				ServerCommand("crash");
			else
				ServerCommand("host_workshop_map 906681141");
		}
		return Plugin_Continue;
	}
	else if( strcmp(szSayTrig, "!build", false) == 0		|| strcmp(szSayTrig, "/build", false) == 0	||
			strcmp(szSayTrig, "!b", false) == 0		|| strcmp(szSayTrig, "/b", false) == 0
		) {

		if( GetZoneBit( GetPlayerZone(client) ) & BITZONE_BLOCKBUILD ) {
			ACCESS_DENIED(client);
		}
		if( g_bUserData[client][b_MayBuild] == 0 || g_iUserData[client][i_KidnappedBy] > 0 ) {
			CPrintToChat(client, "" ...MOD_TAG... " Vous ne pouvez pas construire pour le moment.");
			return Plugin_Handled;
		}
		
		
		
		Action a;
		float cd = 33.0;
		
		Call_StartForward( view_as<Handle>(g_hRPNative[client][RP_OnPlayerBuild]));
		Call_PushCell(client);
		Call_PushCellRef(cd);
		Call_Finish(a);
		
		if( a != Plugin_Stop ) {
			ACCESS_DENIED(client);
		}
		
		g_bUserData[client][b_MayBuild] = 0;
		CreateTimer(cd, AllowBuild, client);

		return Plugin_Handled;
	}
	else if(	strcmp(szSayTrig, "!skin", false) == 0		|| strcmp(szSayTrig, "/skin", false) == 0 ||
	strcmp(szSayTrig, "!skins", false) == 0		|| strcmp(szSayTrig, "/skins", false) == 0
	) {

		CPrintToChat(client, "" ...MOD_TAG... " Vous devez vous rendre dans une cabine d'essage." );
		return Plugin_Handled;
	}
	else if(
		strcmp(szSayTrig, "!cle", false) == 0		|| strcmp(szSayTrig, "/cle", false) == 0 ||
		strcmp(szSayTrig, "!key", false) == 0		|| strcmp(szSayTrig, "/key", false) == 0
	) {


		if( !IsBoss(client) ) {
			ACCESS_DENIED(client);
		}

		OpenBossGestionCle(client);

		return Plugin_Handled;
	}
	else if(
		strcmp(szSayTrig, "!cles", false) == 0		|| strcmp(szSayTrig, "/cles", false) == 0 ||
		strcmp(szSayTrig, "!keys", false) == 0		|| strcmp(szSayTrig, "/keys", false) == 0
	) {


		if( !IsBoss(client) ) {
			ACCESS_DENIED(client);
		}

		if( IsAdmin(client) ) {
			OpenBossGestionCle(client, true);
		}
		else {
			OpenBossGestionCle(client);
		}


		return Plugin_Handled;
	}
	else if( strcmp(szSayTrig, "!out", false) == 0		|| strcmp(szSayTrig, "/out", false) == 0 ) {

	#if defined USING_VEHICLE
		if( IsValidVehicle(target) ) {
			int car = GetEntPropEnt(client, Prop_Send, "m_hVehicle");
			int driver = GetEntPropEnt(target, Prop_Send, "m_hPlayer");
			if( IsEntitiesNear(client, target)) {
				if( car == -1 ) {
					if( IsValidClient(driver) ) {
						if( g_iVehicleData[target][car_owner] == client && driver != client ) {
							ExitVehicle(driver, target, true);
							CPrintToChat(driver, "" ...MOD_TAG... " %N{default} vous a sorti de votre voiture.", client);
						}
						
						if( g_iUserData[client][i_ToKill] == driver && driver != client ) {
							ExitVehicle(driver, target, true);
							CPrintToChat(driver, "" ...MOD_TAG... " %N{default} vous a sorti de votre voiture.", client);
						}
						
						for(int i=1; i<=MaxClients; i++) {
							if( !IsValidClient(i) )
								continue;
							if( g_iCarPassager[target][i] && g_iUserData[client][i_ToKill] == i && i != client ) {
								LeaveVehiclePassager(i, target);
							}
						}
						
					}
				}
			}
			return Plugin_Handled;
		}
	#endif
		
		
		int appart = getZoneAppart(client);
		bool in_appart = false;
		
		if( appart > 0 && g_iDoorOwner_v2[client][appart] ) {
			in_appart = true;
		}
		
		if( g_iUserData[client][i_Job] == 0 && !in_appart ) {
			ACCESS_DENIED(client);
		}

		if( !IsValidClient(target) )
			return Plugin_Handled;

		if( !IsPlayerAlive(target) )
			return Plugin_Handled;
		
		if( Client_GetVehicle(target) > 0 || rp_GetClientVehiclePassager(target) > 0 )
			return Plugin_Handled;

		if( (GetZoneBit( GetPlayerZone(client) ) & BITZONE_BLOCKOUT) || (GetZoneBit( GetPlayerZone(target) ) & BITZONE_BLOCKOUT) ) {
			ACCESS_DENIED(client);
		}

		if( g_bUserData[client][b_MaySteal] == 0) {
			CPrintToChat(client, "" ...MOD_TAG... " Vous ne pouvez pas /out pour le moment.");
			return Plugin_Handled;
		}
		
		if( g_iUserData[target][i_KidnappedBy] > 0 ) {
			CPrintToChat(client, "" ...MOD_TAG... " Vous ne pouvez pas /out un joueur kidnappé.");
			return Plugin_Handled;
		}

		int job_tree = g_iUserData[client][i_Job];

		if( StringToInt( g_szJobList[ job_tree ][job_type_isboss] ) != 1 ) {
			job_tree = StringToInt( g_szJobList[ job_tree ][job_type_ownboss] );
		}

		int ClientZone = GetPlayerZone(client);
		int ClientZoneJob = StringToInt( g_szZoneList[ClientZone][zone_type_type] );

		if( StringToInt( g_szJobList[ ClientZoneJob ][job_type_isboss] ) != 1 ) {
			ClientZoneJob = StringToInt( g_szJobList[ ClientZoneJob ][job_type_ownboss] );
		}

		int TargetZone = GetPlayerZone(target);
		int TargetZoneJob = StringToInt( g_szZoneList[TargetZone][zone_type_type] );

		if( StringToInt( g_szJobList[ TargetZoneJob ][job_type_isboss] ) != 1 ) {
			TargetZoneJob = StringToInt( g_szJobList[ TargetZoneJob ][job_type_ownboss] );
		}
		
		if( ClientZone == 0 || ClientZoneJob <= 0 || ClientZoneJob != job_tree ) {
			if( !in_appart ) {
				CPrintToChat(client, "" ...MOD_TAG... " Vous ne pouvez pas utiliser le /out ici.");
				return Plugin_Handled;
			}
		}

		if( ClientZoneJob != TargetZoneJob ) {
			if( !in_appart ) {
				CPrintToChat(client, "" ...MOD_TAG... " %N{default} n'est pas dans votre zone.", target);
				return Plugin_Handled;
			}
		}
		if( ClientZone != TargetZone ) {
			if( in_appart ) {
				CPrintToChat(client, "" ...MOD_TAG... " %N{default} n'est pas dans votre zone.", target);
				return Plugin_Handled;
			}
		}
		
		if( in_appart ) {
			if( g_iDoorOwner_v2[target][appart] ) {
				CPrintToChat(client, "" ...MOD_TAG... " %N{default} est un de vos collocataires.", target);
				return Plugin_Handled;
			}
			
		}

		if( StringToInt( g_szZoneList[ClientZone][zone_type_bit] ) & BITZONE_PERQUIZ ) {
			if( !IsPolice(client) && !IsJuge(client) ) {
				CPrintToChat(client, "" ...MOD_TAG... " Vous ne pouvez pas utiliser le /out ici pour le moment.");
				return Plugin_Handled;
			}
		}
		
		CPrintToChat(client, "" ...MOD_TAG... " %N{default} a été mis dehors.", target);
		CPrintToChat(target, "" ...MOD_TAG... " %N{default} vous a mis dehors.", client);
		LogToGame("[OUT] %L a sorti %L", client, target);
		
		SendPlayerToSpawn(target, true);
		Colorize(target, 255, 255, 255, 255);
		g_bUserData[client][b_MaySteal] = false;
		if( GetClientTeam(target) == CS_TEAM_CT )
			CreateTimer(10.0, AllowStealing, client);
		else
			CreateTimer(0.01, AllowStealing, client);

		return Plugin_Handled;
	}
	else if(	strcmp(szSayTrig, "!engage", false) == 0		|| strcmp(szSayTrig, "/engage", false) == 0	||
	strcmp(szSayTrig, "!engager", false) == 0		|| strcmp(szSayTrig, "/engager", false) == 0||
	strcmp(szSayTrig, "!hire", false) == 0			|| strcmp(szSayTrig, "/hire", false) == 0
	) {

		if( !IsBoss(client) ) {
			ACCESS_DENIED(client);
		}

		if( !IsValidClient(target) ) {
			CPrintToChat(client, "" ...MOD_TAG... " Vous devez viser un joueur n'ayant pas d'emploi.");
			return Plugin_Handled;
		}

		if( !IsPlayerAlive(target) )
			return Plugin_Handled;

		if( g_iUserData[target][i_Job] != 0 || GetJobPrimaryID(client) != GetJobPrimaryID(target) || IsBoss(target) ) {
			if( g_iUserData[target][i_Job] != 0 ) {
				CPrintToChat(client, "" ...MOD_TAG... " Ce joueur a déjà un emploi.");
				return Plugin_Handled;
			}
		}

		char tmp[255];

		Format(tmp, 254, "Sélectionner un job pour: %N\n ", target);

		// Setup menu
		Handle hHireMenu = CreateMenu(eventHireMenu);
		SetMenuTitle(hHireMenu, tmp);

		for(int i = 0; i < MAX_JOBS; i++) {
			if( StringToInt(g_szJobList[i][2]) != GetJobPrimaryID(client) )
				continue;

			if( StringToInt(  g_szJobList[ i ][job_type_cochef] ) == 1 && StringToInt(  g_szJobList[ g_iUserData[client][i_Job] ][job_type_cochef] ) == 1 )
				continue;

			Format(tmp, 254, "%d_%d", target, i);
			AddMenuItem(hHireMenu, tmp, g_szJobList[i][0]);
		}

		SetMenuExitButton(hHireMenu, true);
		DisplayMenu(hHireMenu, client, MENU_TIME_DURATION);

		return Plugin_Handled;
	}
	else if(	strcmp(szSayTrig, "!vire", false) == 0		|| strcmp(szSayTrig, "/vire", false) == 0	||
	strcmp(szSayTrig, "!virer", false) == 0		|| strcmp(szSayTrig, "/virer", false) == 0	||
	strcmp(szSayTrig, "!fire", false) == 0		|| strcmp(szSayTrig, "/fire", false) == 0
	) {

		if( !IsBoss(client) ) {
			ACCESS_DENIED(client);
		}

		char query[1024];
		Format(query, sizeof(query), "SELECT `steamid`, `name`, `job_id`, UNIX_TIMESTAMP(`last_connected`) FROM `rp_users` WHERE `job_id`<>'0'");

		SQL_TQuery(g_hBDD, menuFire_Client, query, client, DBPrio_High);

		return Plugin_Handled;
	}
	else if(	strcmp(szSayTrig, "!demission", false) == 0		|| strcmp(szSayTrig, "/demission", false) == 0		||
	strcmp(szSayTrig, "!demissionner", false) == 0	|| strcmp(szSayTrig, "/demissionner", false) == 0	||
	strcmp(szSayTrig, "!demissionne", false) == 0	|| strcmp(szSayTrig, "/demissionne", false) == 0
	) {

		if( StringToInt(  g_szJobList[ g_iUserData[client][i_Job] ][job_type_isboss] ) == 1) {
			CPrintToChat(client, "" ...MOD_TAG... " Pour demissionner, vous devez envoyer un message ici: https://forum.riplay.fr/index.php?/topic/847-demission/");
			return Plugin_Handled;
		}
		if( g_iClientQuests[client][questID] != -1 ) {		
  			CPrintToChat(client, "" ...MOD_TAG... " Pour demissionner, il faut d'abord finir sa quête !");		
 			return Plugin_Handled;		
 		}
		if( strlen(g_szPlainte[client][1]) <= 1 ) {

			char pwd[12];
			GetRandomString(pwd, 5);

			Format(g_szPlainte[client][1], 128, "%s", pwd);
			
			if( !g_iClient_OLD[client] ) {
				CPrintToChat(client, "{red}STOP!{default}  Soyez certain d'avoir un nouvel emploi avant de démissionner.");
				CPrintToChat(client, "Il faut {red}OBLIGATOIREMENT{default} contacter un {red}CHEF DE METIER{default} pour en récupérer un.");
				CPrintToChat(client, "Sans quoi, vous resterez sans emploi pour un long moment...");
			}
			
			CPrintToChat(client, "" ...MOD_TAG... " Confirmez en tapant: /demission %s", g_szPlainte[client][1]);
			

		}
		else {

			if( StrContains(szSayText, g_szPlainte[client][1], false) == 1 ) {

				
				ChangePersonnal(client, SynType_job, 0, client);
			}
			else {
				CPrintToChat(client, "" ...MOD_TAG... " Le mot de passe est érroné, votre demission n'a pas été confirmée.");
			}

			Format(g_szPlainte[client][0], 128, "");
			Format(g_szPlainte[client][1], 128, "");
		}

		return Plugin_Handled;
	}
	else if(	strcmp(szSayTrig, "!afk", false) == 0 || strcmp(szSayTrig, "/afk", false) == 0 ) {

		if( !IsPolice(client) && !IsJuge(client) ) {
			ACCESS_DENIED(client);
		}
		
		int braquage = GetConVarInt(FindConVar("rp_braquage"));
		
		if( braquage > 0 ) {
			CPrintToChat(client, "" ...MOD_TAG... " Attention, un braquage est en cours. Le fait de passer AFK diminue");
			CPrintToChat(client, "" ...MOD_TAG... " les chances de win pour vos collègues. Si vous utilisez le /afk");
			CPrintToChat(client, "" ...MOD_TAG... " avant le début du braquage, celui-ci restera équilibré. Pensez-y, merci.");
			LogToGame("[CHEATING] [AFK-BRAQUAGE] %L.", client);
		}
		
		if( g_bUserData[client][b_Stealing] ) {
			CPrintToChat(client, "" ...MOD_TAG... " Vous ne pouvez temporairement pas utiliser le /afk.");
			return Plugin_Handled;
		}
		GetClientEyeAngles(client, g_Position[client]);
		
		g_iUserData[client][i_TimeAFK] += 180;
		return Plugin_Handled;
	}
	else if(	strcmp(szSayTrig, "!assu", false) == 0		|| strcmp(szSayTrig, "/assu", false) == 0 ||
	strcmp(szSayTrig, "!assurance", false) == 0	|| strcmp(szSayTrig, "/assurance", false) == 0
	) {

		CPrintToChat(client, "" ...MOD_TAG... " Votre assurance vous couvre pour %i$.", GetAssurence(client));
		return Plugin_Handled;
	}
	else if(	strcmp(szSayTrig, "!heal", false) == 0		|| strcmp(szSayTrig, "/heal", false) == 0	) {

		if( !IsMedic(client) ) {
			ACCESS_DENIED(client);
		}

		if( !IsValidClient(target) )
			return Plugin_Handled;

		if( (GetZoneBit( GetPlayerZone(client) ) & BITZONE_BLOCKSELL)
		) {
			ACCESS_DENIED(client);
		}

		if( IsInPVP(client) ) {
			ACCESS_DENIED(client);
		}

		float vecOrigin[3], vecOrigin2[3];
		GetClientAbsOrigin(client, vecOrigin);
		
		// Setup menu
		Handle menu = CreateMenu(eventGiveMenu_2Bis); // _2
		SetMenuTitle(menu, "Liste des joueurs a cet endroit\n ");
		
		int amount = 0;
		
		char tmp[24], tmp2[64];
		for(int i=1; i<=MaxClients; i++) {
			if( !IsValidClient(i) )
				continue;
			if( !IsPlayerAlive(i) )
				continue;

			GetEntPropVector(i, Prop_Send, "m_vecOrigin", vecOrigin2);
			if( GetVectorDistance(vecOrigin, vecOrigin2) >= MAX_AREA_DIST/2 )
				continue;
			
			if( (GetZoneBit( GetPlayerZone(i) ) & BITZONE_BLOCKSELL) || IsInPVP(i)  ) {
				continue;
			}
			
			int heal = GetClientHealth(target);
			int max_heal = GetClientMaxHealth(target);
			int diff = (max_heal-heal);
			if( diff <= 0 )
				continue;
			
			
			Format(tmp, sizeof(tmp), "7_1_0_0_%i", i);
			
			GetClientName(i, tmp2, 63);
			AddMenuItem(menu, tmp, tmp2);
			amount++;
		}

		if( amount > 0 ) {
			SetMenuExitButton(menu, true);
			DisplayMenu(menu, client, MENU_TIME_DURATION);
		}
		else {
			CPrintToChat(client, "" ...MOD_TAG... " Il n'y a personne dans les environs.");
			CloseHandle(menu);
		}
		
		return Plugin_Handled;
	}
	else if(	strcmp(szSayTrig, "!mort", false) == 0		|| strcmp(szSayTrig, "/mort", false) == 0
	) {

		if( !IsPlayerAlive(client) )
			return Plugin_Handled;

		if( !IsMedic(client) ) {
			ACCESS_DENIED(client);
		}

		float vecOrigin[3], vecOrigin2[3];
		GetClientAbsOrigin(client, vecOrigin);

		// Setup menu
		Handle menu = CreateMenu(eventGiveMenu_2Bis); // _2
		SetMenuTitle(menu, "Liste des joueurs mort a cet endroit\n ");

		int amount = 0;
		char tmp[24], tmp2[64];
		for(int i=1; i<=MaxClients; i++) {
			if( !IsValidClient(i) )
				continue;
			if( IsPlayerAlive(i) )
				continue;
			if( !g_bUserData[i][b_MayUseUltimate] )
				continue;
			
			int ragdoll = GetEntPropEnt(i, Prop_Send, "m_hRagdoll");

			if( !IsValidEdict(ragdoll) )
				continue;
			if( !IsValidEntity(ragdoll) )
				continue;
			
			
			GetEntPropVector(ragdoll, Prop_Send, "m_vecOrigin", vecOrigin2);
			if( GetVectorDistance(vecOrigin, vecOrigin2) >= MAX_AREA_DIST*4 )
				continue;
			
			Format(tmp, sizeof(tmp), "5_1_0_0_%i", i);
			
			GetClientName(i, tmp2, 63);
			AddMenuItem(menu, tmp, tmp2);
			amount++;
		}

		if( amount > 0 ) {
			SetMenuExitButton(menu, true);
			DisplayMenu(menu, client, MENU_TIME_DURATION);
		}
		else {
			CPrintToChat(client, "" ...MOD_TAG... " Il n'y a personne a faire revivre dans les environs.");
			CloseHandle(menu);
		}
		return Plugin_Handled;

	}
	else if(
	strcmp(szSayTrig, "!vendre", false) == 0	|| strcmp(szSayTrig, "/vendre", false) == 0	||
	strcmp(szSayTrig, "!v", false) == 0		|| strcmp(szSayTrig, "/v", false) == 0
	) {


		DrawVendreMenu(client);


		return Plugin_Handled;
	}
	else if(
		strcmp(szSayTrig, "!objet", false) == 0		|| strcmp(szSayTrig, "/objet", false) == 0	||
		strcmp(szSayTrig, "!objets", false) == 0	|| strcmp(szSayTrig, "/objets", false) == 0	||
		strcmp(szSayTrig, "!item", false) == 0		|| strcmp(szSayTrig, "/item", false) == 0	||
		strcmp(szSayTrig, "!items", false) == 0		|| strcmp(szSayTrig, "/items", false) == 0	||
		strcmp(szSayTrig, "!inbag", false) == 0		|| strcmp(szSayTrig, "/inbag", false) == 0	||
		strcmp(szSayTrig, "!sac", false) == 0		|| strcmp(szSayTrig, "/sac", false) == 0	||
		strcmp(szSayTrig, "!inventaire", false) == 0|| strcmp(szSayTrig, "/inventaire", false) == 0 ||
		strcmp(szSayTrig, "!i", false) == 0			|| strcmp(szSayTrig, "/i", false) == 0
	) {

		OpenItemMenu(client);

		return Plugin_Handled;
	}
	else if(	strcmp(szSayTrig, "!give", false) == 0		|| strcmp(szSayTrig, "/give", false) == 0	||
				strcmp(szSayTrig, "!donner", false) == 0	|| strcmp(szSayTrig, "/donner", false) == 0
	) {

		if( !IsTutorialOver(client) ) {
			CPrintToChat(client, "" ...MOD_TAG... " Vous n'avez pas terminé le tutorial.");
			return Plugin_Handled;
		}
		
		if( g_iUserData[client][i_SearchLVL] >= 1 ) {
			CPrintToChat(client, "" ...MOD_TAG... " Vous ne pouvez pas donner de l'argnet quand vous êtes recherché par le Tribunal.");
			return Plugin_Handled;
		}		
		
		if( g_iUserData[client][i_PlayerLVL] < 12 ) {
			CPrintToChat(client, "" ...MOD_TAG... " Vous devez être au moins de niveau 12 \"Simple Citoyen\", afin d'utiliser cette commande.");
			return Plugin_Handled;
		}
		
		if( g_bUserData[client][b_IsSearchByTribunal] ) {
			PrintToChat(client, "" ...MOD_TAG... " Vous ne pouvez pas donner de l'argnet quand vous êtes recherché par le Tribunal.");
			return Plugin_Handled;
		}
		
		if( g_bUserData[client][b_IsMuteGive] ) {
			PrintToChat(client, "\x04[\x02MUTE\x01]\x01: Vous avez été interdit d'utiliser le /give.");
			return Plugin_Handled;
		}
		
		if( !IsValidClient(target) )
			return Plugin_Handled;

		if( !IsPlayerAlive(target) )
			return Plugin_Handled;

		int amount = StringToInt(szSayText);

		if( g_iUserData[client][i_Money] < amount ) {
			CPrintToChat(client, "" ...MOD_TAG... " Vous n'avez pas assez d'argent.");
			return Plugin_Handled;
		}
		if( amount <= 0 ) {
			CPrintToChat(client, "" ...MOD_TAG... " Vous devez donner plus de 0$.");
			return Plugin_Handled;
		}
		if( amount > 100000 ) {
			CPrintToChat(client, "" ...MOD_TAG... " Vous devez donner moins de 100 000$.");
			return Plugin_Handled;
		}
		
		if( g_iUserData[client][i_GiveAmountTime]+amount > 100000 ) {
			CPrintToChat(client, "" ...MOD_TAG... " Vous ne pouvez pas donner autant d'argent en aussi peu de temps.");
			return Plugin_Handled;
		}
		char targetSteamID[64];
		GetClientAuthId(target, AUTH_TYPE, targetSteamID, sizeof(targetSteamID), false);
		
		if( g_iDoubleCompte[client].FindString(targetSteamID) >= 0 ) {
			CPrintToChat(client, "" ...MOD_TAG... " Vous ne pouvez pas donner d'argnet à l'un de vos double compte. S'il ne s'agit pas d'un double compte, vous pouvez contester cette déicision sur ce lien:");
			GetClientAuthId(client, AUTH_TYPE, targetSteamID, sizeof(targetSteamID), false);
			CPrintToChat(client, "" ...MOD_TAG... " https://rpweb.riplay.fr/index.php#/pilori/double/%s", targetSteamID);
			return Plugin_Handled;
		}
		
		

		g_iUserStat[client][i_MoneySpent_Give] += amount;
		g_iUserStat[target][i_MoneyEarned_Give] += amount;
		rp_ClientMoney(client, i_Money, -amount);
		rp_ClientMoney(target, i_Money, amount);
		g_iUserData[client][i_GiveAmountTime] += amount;
		Handle dp;
		CreateDataTimer(60.0, TIMER_ReduceGiveAmount, dp, TIMER_DATA_HNDL_CLOSE);
		WritePackCell(dp, client);
		WritePackCell(dp, amount);
		
		

		CPrintToChat(client, "" ...MOD_TAG... " Vous avez donné %i$ à %N.", amount, target);
		CPrintToChat(target, "" ...MOD_TAG... " %N{default} vous a donné %i$.", client, amount);
		
		LogToGame("[TSX-RP] [GIVE-MONEY] %L a donné %i$ à %L.", client, amount, target);
		
		StoreUserData(client);
		StoreUserData(target);		
		if( CanMakeSuccess(client, success_list_robin_wood) ) {
			if( (g_iUserData[target][i_Money]+g_iUserData[target][i_Bank]-amount) <= 500 && amount >= 10000 ) {
				for( int i=0; i<10; i++ ) {
					if( StrEqual(g_szSuccess_last_give[client][i], targetSteamID) )
						break;
					if( strlen(g_szSuccess_last_give[client][i]) < 1 ) {
						Format(g_szSuccess_last_give[client][i], 31, "%s", targetSteamID);
						g_iUserSuccess[client][success_list_robin_wood][sd_count] = (i+1);
						break;
					}
				}
			}
		}
		return Plugin_Handled;
	}
	else if(	strcmp(szSayTrig, "!givexp", false) == 0		|| strcmp(szSayTrig, "/givexp", false) == 0 ) {

		if( !IsTutorialOver(client) ) {
			CPrintToChat(client, "" ...MOD_TAG... " Vous n'avez pas terminé le tutorial.");
			return Plugin_Handled;
		}
		
		if( !IsValidClient(target) )
			return Plugin_Handled;

		if( !IsPlayerAlive(target) )
			return Plugin_Handled;

		int amount = StringToInt(szSayText);

		if( g_iUserData[client][i_GiveXP] < amount ) {
			CPrintToChat(client, "" ...MOD_TAG... " Vous n'avez pas assez d'XP à donner.");
			return Plugin_Handled;
		}
		if( amount < 100 ) {
			CPrintToChat(client, "" ...MOD_TAG... " Vous devez donner plus de 100XP.");
			return Plugin_Handled;
		}
		
		g_iUserData[client][i_GiveXP] -= amount;
		rp_ClientXPIncrement(target, amount);

		CPrintToChat(client, "" ...MOD_TAG... " Vous avez donné %iXP à %N.", amount, target);
		CPrintToChat(target, "" ...MOD_TAG... " %N{default} vous a donné %iXP.", client, amount);
		
		LogToGame("[TSX-RP] [GIVE-XP] %L a donné %iXP à %L.", client, amount, target);
		
		StoreUserData(client);
		StoreUserData(target);
		
		return Plugin_Handled;
	}
	else if(	strcmp(szSayTrig, "!givecb", false) == 0		|| strcmp(szSayTrig, "/givecb", false) == 0	||
		strcmp(szSayTrig, "!donnercb", false) == 0	|| strcmp(szSayTrig, "/donnercb", false) == 0
	) {
		if( !IsAdmin(client) ) {
			ACCESS_DENIED(client);
		}
		if( !IsValidClient(target) )
			return Plugin_Handled;

		if( !IsPlayerAlive(target) )
			return Plugin_Handled;

		int amount = StringToInt(szSayText);

		if( g_iUserData[client][i_Bank] < amount ) {
			CPrintToChat(client, "" ...MOD_TAG... " Vous n'avez pas assez d'argent en banque.");
			return Plugin_Handled;
		}
		if( amount <= 0 ) {
			CPrintToChat(client, "" ...MOD_TAG... " Vous devez donner plus de 0$.");
			return Plugin_Handled;
		}
		
		rp_ClientMoney(client, i_Bank, -amount);
		rp_ClientMoney(target, i_Money, amount);

		CPrintToChat(client, "" ...MOD_TAG... " Vous avez donné %i$ a %N.", amount, target);
		CPrintToChat(target, "" ...MOD_TAG... " %N{default} vous a donné %i$.", client, amount);
		
		LogToGame("[TSX-RP] [GIVE-MONEY] %L a donné %i$ à %L.", client, amount, target);

		return Plugin_Handled;
	}
	else if(	strcmp(szSayTrig, "!thirdperson", false) == 0		|| strcmp(szSayTrig, "/thirdperson", false) == 0 ||
				strcmp(szSayTrig, "!firstperson", false) == 0		|| strcmp(szSayTrig, "/firstperson", false) == 0 ||
				strcmp(szSayTrig, "!3rd", false) == 0				|| strcmp(szSayTrig, "/3rd", false) == 0 ||
				strcmp(szSayTrig, "!1st", false) == 0			|| strcmp(szSayTrig, "/1st", false) == 0
	) {
		
		if( g_bIsInCaptureMode && rp_GetClientGroupID(client) > 0 ) {
			ACCESS_DENIED(client);
		}
			
		if( g_iUserData[client][i_ThirdPerson] == 0 ) {
			ClientCommand(client, "thirdperson");
			g_iUserData[client][i_ThirdPerson] = 1;
		}
		else {
			ClientCommand(client, "firstperson");
			g_iUserData[client][i_ThirdPerson] = 0;
		}
		return Plugin_Handled;
	}
	else if(	strcmp(szSayTrig, "!enquete", false) == 0		|| strcmp(szSayTrig, "/enquete", false) == 0
	) {
		if( !IsPolice(client) && !IsJuge(client) && !IsTueur(client) ) {
			ACCESS_DENIED(client);
		}

		if( (g_iUserData[client][i_Money]+g_iUserData[client][i_Bank]) < 100 ) {
			ACCESS_DENIED(client);
		}

		if( g_bUserData[client][b_MaySteal] == 0 ) {
			CPrintToChat(client, "" ...MOD_TAG... " Vous ne pouvez pas utiliser cette commande pour le moment.");
			return Plugin_Handled;
		}

		if( !IsValidClient(target) )
			return Plugin_Handled;

		if( !IsPlayerAlive(target) )
			return Plugin_Handled;

		if( !IsTueur(client) ) {
			for(int i=1; i<=MaxClients; i++) {
				if( !IsValidClient(i) )
					continue;
				if( g_bUserData[i][b_IsAFK] )
					continue;
				if( !IsTueur(i) )
					continue;
				if( IsClientInJail(i) )
					continue;
				if( IsInPVP(i) )
					continue;
				
				CPrintToChat(client, "" ...MOD_TAG... " Au moins un tueur est connecté (%N), impossible d'utiliser le /enquete.", i);
				CPrintToChat(i, "" ...MOD_TAG... " %N{default} veut faire une enquête sur %N{default} (%s).", client, target, g_szZoneList[GetPlayerZone(client)][zone_type_name]);
				TargetBeamBox(i, target);
				ClientCommand(i, "play buttons/blip1.wav");
				return Plugin_Handled;
			}
		}

		g_bUserData[client][b_MaySteal] = 0;
		switch( g_iUserData[client][i_Job] ) {
			case 1: CreateTimer(0.1, AllowStealing, client);
			case 5: CreateTimer(5.0, AllowStealing, client);
			case 6: CreateTimer(10.0, AllowStealing, client);
			case 7: CreateTimer(15.0, AllowStealing, client);
			case 8: CreateTimer(20.0, AllowStealing, client);
			case 9: CreateTimer(25.0, AllowStealing, client);
			default: CreateTimer(10.0, AllowStealing, client);
		}
		
		rp_ClientMoney(client, i_Money, -100);
		SetJobCapital(141,	(GetJobCapital(41)+50) );
		SetJobCapital(1,	(GetJobCapital(1)+50) );


		CPrintToChat(target, "" ...MOD_TAG... " %N{default} vient de vérifier vos informations", client);

		LogToGame("[TSX-RP] [ENQUETE] %L a regardé %L", client, target);

		ServerCommand("rp_item_enquete \"%i\" \"%i\"", client, target);

		return Plugin_Handled;
	}
	else if(	strcmp(szSayTrig, "!win", false) == 0		|| strcmp(szSayTrig, "/win", false) == 0	||
	strcmp(szSayTrig, "!gagnant", false) == 0		|| strcmp(szSayTrig, "/gagnant", false) == 0
	) {

		char query[1024];
		Format(query, sizeof(query), "SELECT CONCAT(`name`, ' Il y a ', CEIL((UNIX_TIMESTAMP()-`timestamp`)/(60*60)), 'heures') as txt FROM `rp_sell` INNER JOIN `rp_users` ON `rp_users`.`steamid`=`rp_sell`.`steamid` WHERE `rp_sell`.`item_type`='4' AND `rp_sell`.`job_id`='171' ORDER BY `id` DESC LIMIT 10;");

		SQL_TQuery(g_hBDD, menuShowNote_Client, query, client, DBPrio_Low);

		return Plugin_Handled;
	}
	else if(	strcmp(szSayTrig, "!shownote", false) == 0		|| strcmp(szSayTrig, "/shownote", false) == 0	||
				strcmp(szSayTrig, "!shownotes", false) == 0		|| strcmp(szSayTrig, "/shownotes", false) == 0
	) {

		if( g_iUserData[client][i_Job] == 0 ) {
			ACCESS_DENIED(client);
		}

		int job_id = GetJobPrimaryID(client);

		char query[1024];
		Format(query, sizeof(query), "SELECT `txt` FROM `rp_notes` WHERE `job_id`='%i' ORDER BY `id` ASC;", job_id);

		SQL_TQuery(g_hBDD, menuShowNote_Client, query, client, DBPrio_Low);

		return Plugin_Handled;
	}
	else if(	strcmp(szSayTrig, "!cagnotte", false) == 0		|| strcmp(szSayTrig, "/cagnotte", false) == 0	) {

		char szSteamID[64];
		GetClientAuthId(client, AUTH_TYPE, szSteamID, sizeof(szSteamID), false);
		
		char query[1024];
		Format(query, sizeof(query), "SELECT COUNT(*) FROM `rp_loto` WHERE `steamid`='%s';", szSteamID);

		SQL_TQuery(g_hBDD, showCagnotteInfo, query, client);

		return Plugin_Handled;
	}
	else if(	strcmp(szSayTrig, "!addnote", false) == 0		|| strcmp(szSayTrig, "/addnote", false) == 0 ||
				strcmp(szSayTrig, "!an", false) == 0		|| strcmp(szSayTrig, "/an", false) == 0
		) {
		if( g_iUserData[client][i_Job] == 0 || (!IsBoss(client) && !IsPolice(client) && !IsJuge(client)) ) {
			ACCESS_DENIED(client);
		}

		int job_id = GetJobPrimaryID(client);

		char buffer[ sizeof(szSayText)*2+1 ];
		SQL_EscapeString(g_hBDD, szSayText, buffer, sizeof(buffer));

		char query[1024];
		Format(query, 1023, "INSERT INTO `rp_notes` (`id`, `job_id`, `txt` ) VALUES (NULL , '%i', '%s');", job_id, buffer);
		SQL_TQuery(g_hBDD, SQL_QueryCallBack, query);
		

		for(int i=1; i <= MaxClients; i++) {

			if( !IsValidClient(i) )
				continue;
			
			if( GetJobPrimaryID(i) == job_id ) {
				CPrintToChat(i, "" ...MOD_TAG... " %s a ajouté la note: %s", name, szSayText);
			}
		}
		return Plugin_Handled;
	}
	else if(	strcmp(szSayTrig, "!deletenote", false) == 0		|| strcmp(szSayTrig, "/deletenote", false) == 0 ||
				strcmp(szSayTrig, "!deletenotes", false) == 0			|| strcmp(szSayTrig, "/deletenotes", false) == 0
	) {

		if( g_iUserData[client][i_Job] == 0 || (!IsBoss(client) && !IsPolice(client) && !IsJuge(client)) ) {
			ACCESS_DENIED(client);
		}

		int job_id = GetJobPrimaryID(client);

		char query[1024];
		Format(query, 1023, "SELECT `id`, `txt` FROM `rp_notes` WHERE `job_id`='%i' ORDER BY `id` ASC;;", job_id);

		SQL_TQuery(g_hBDD, menuDeleteNote_Client, query, client, DBPrio_High);

		return Plugin_Handled;
	}
	
	
	if( String_StartsWith(szSayTrig, "/") || String_StartsWith(szSayTrig, "!")  ) {

		Action a;
		Call_StartForward( view_as<Handle>(g_hRPNative[client][RP_OnPlayerCommand]) );
		Call_PushCell(client);
		Call_PushString(cmd);	
		Call_PushString(szSayText);
		Call_Finish(a);
		if( a == Plugin_Handled || a == Plugin_Stop )
			return Plugin_Handled;
	}
	else {
		if( g_iChatData[client].Length > 0 ) {
			DataPack data = g_iChatData[client].Get(0);
			g_iChatData[client].Erase(0);
			data.Reset();
			
			any arg = data.ReadCell();
			Function fct = data.ReadFunction();
			Handle plugin = data.ReadCell();
			
			Call_StartFunction(plugin, fct);
			Call_PushCell(client);
			Call_PushCell(arg);
			Call_PushString(szSayText);
			Call_Finish();
			
			delete data;
			
			return Plugin_Handled;
		}
	}
	
	// -----------------------------------------------------------------------------------
	if( g_iUserData[client][i_PlayerLVL] < 72 && !IsAdmin(client) ) {
		
		int time = GetClientCount() / 6;
		
		if( g_iSuccess_last_chat[client]+time > GetTime() ) {
			CPrintToChat(client, "" ...MOD_TAG... " Vous devez attendre encore %i seconde(s), avant d'utiliser à nouveau le chat général.", g_iSuccess_last_chat[client]+time-GetTime());
			return Plugin_Handled;
		}
	}
	
	if( !IsAdmin(client) ) {
		if( strlen(szSayText) > 0 ) {
			if( StrEqual(g_szLastMessage[client][0], szSayText, false) ||
				StrEqual(g_szLastMessage[client][1], szSayText, false) ||
				StrEqual(g_szLastMessage[client][2], szSayText, false) ||
				StrEqual(g_szLastMessage[client][3], szSayText, false) ||
				StrEqual(g_szLastMessage[client][4], szSayText, false)
			) {
				CPrintToChat(client, "" ...MOD_TAG... " Votre message a été bloqué afin d'éviter d'éventuel spam.");
				return Plugin_Handled;
			}
			
			for (int i = sizeof(g_szLastMessage[])-1; i >= 1; i--) {
				strcopy(g_szLastMessage[client][i], sizeof(g_szLastMessage[][]), g_szLastMessage[client][i-1]);
			}
			strcopy(g_szLastMessage[client][0], sizeof(g_szLastMessage[][]), szSayText);
		}
	}

	g_iSuccess_last_chat[client] = GetTime();

	int flags = GetUserFlagBits(client);
	if (flags & ADMFLAG_GENERIC || flags & ADMFLAG_ROOT) {
		if( StrContains(szSayTrig, "@") == 0 || StrContains(szSayTrig, "/") == 0 ) {
			return Plugin_Continue;
		}
	}
	
	
	if( BaseComm_IsClientGagged(client) || g_bUserData[client][b_IsMuteGlobal] ) {
		PrintToChat(client, "\x04[\x02MUTE\x01]\x01: Vous avez été interdit d'utiliser le chat global.");
		return Plugin_Handled;
	}

	if( removed ) {
		Format(szSayText, sizeof(szSayText), "%s %s", szSayTrig, szSayText);
	}
	
	char tag[32];
	if( g_bIsHidden[client] == false ) {
		if( flags & ADMFLAG_ROOT || flags & ADMFLAG_CHEATS ) {
			Format(tag, sizeof(tag), "{green}ADMIN{default} ");
		}
		else if( flags & ADMFLAG_KICK ) {
			Format(tag, sizeof(tag), "{green}VIP{default} ");
		}
	}
	
	CPrintToChatAllEx(client, "%s{teamcolor}%s{default}: %s", tag, name, szSayText);

	if( GetClientTeam(client) == CS_TEAM_CT ) {
		LogToGame("\"%L<CT>\" say \"%s\"", client, szSayText);
	}
	else {
		LogToGame("\"%L<TERRORIST>\" say \"%s\"", client, szSayText);
	}

	return Plugin_Handled;
}
public Action Command_SayTeam(int client, int args) {
	if( !IsPlayerAlive(client) ) {
		CPrintToChat(client, "" ...MOD_TAG... " Vous devez être en vie pour parler.");
		return Plugin_Handled;
	}
	
	char szSayText[256];
	GetCmdArgString(szSayText, sizeof(szSayText) );
	StripQuotes(szSayText);

	if( !g_bUserData[client][b_Crayon] )
		CRemoveTags(szSayText, sizeof(szSayText));
	
	Action act = Plugin_Continue;
	Call_StartForward( view_as<Handle>(g_hRPNative[client][RP_PrePlayerTalk]) );
	Call_PushCell(client);
	Call_PushStringEx(szSayText, sizeof(szSayText), SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_PushCell(sizeof(szSayText));
	Call_PushCell(true);
	Call_Finish(act);
	if( act == Plugin_Handled || act == Plugin_Stop )
		return Plugin_Handled;
	
	for (int i = sizeof(g_szLastLocal[])-1; i >= 1; i--) {
		strcopy(g_szLastLocal[client][i], sizeof(g_szLastLocal[][]), g_szLastLocal[client][i-1]);
	}
	strcopy(g_szLastLocal[client][0], sizeof(g_szLastLocal[][]), szSayText);

	bool same = true;
	for (int i = 0; i < sizeof(g_szLastLocal[])-1; i++) {
		if( !StrEqual(g_szLastLocal[client][i], g_szLastLocal[client][i+1]) ) {
			same = false;
			break;
		}
	}
	
	if( !same ) {
		g_Position[client][0] = GetRandomFloat(0.000, 360.000);
		g_Position[client][1] = GetRandomFloat(0.000, 360.000);
	}
	else {
		LogToGame("[CHEAT] [AFK] %L: %s", client, szSayText);
	}
	
	int flags = GetUserFlagBits(client);
	if (flags & ADMFLAG_GENERIC || flags & ADMFLAG_ROOT) {
		if( StrContains(szSayText, "@") == 0 || StrContains(szSayText, "/") == 0 || StrContains(szSayText, "!") == 0 ) {
			return Plugin_Handled;
		}
	}
	if( StrContains(szSayText, "@") == 0 ) {
		return Plugin_Handled;
	}
	
	if( BaseComm_IsClientGagged(client) || g_bUserData[client][b_IsMuteLocal] ) {
		PrintToChat(client, "\x04[\x02MUTE\x01]\x01: Vous avez été interdit d'utiliser le chat local.");
		return Plugin_Handled;
	}
	
	
	float ClientOrigin[3], TargetOrigin[3];
	int tmp = Client_GetVehicle(client);
	if( tmp > 0 )
		Entity_GetAbsOrigin(tmp, ClientOrigin);
	else
		GetClientAbsOrigin(client, ClientOrigin);
	
	char str[128];
	GetClientName2(client, str, sizeof(str), false);
	
	for(int i=1; i<=MaxClients; i++) {
		if( !IsValidClient(i) || !IsPlayerAlive(i) )
			continue;
		
		tmp = Client_GetVehicle(i);
		if( tmp > 0 )
			Entity_GetAbsOrigin(tmp, TargetOrigin);
		else
			GetClientAbsOrigin(i, TargetOrigin);
		
		if( GetVectorDistance(ClientOrigin, TargetOrigin) <= MAX_AREA_DIST ) {
			CPrintToChatEx(i, client, "{teamcolor}%s{default} (LOCAL): %s", str, szSayText);
		}
	}

	LogToGame("[TSX-RP] [CHAT-LOCAL] %L: %s.", client, szSayText);

	return Plugin_Handled;
}
