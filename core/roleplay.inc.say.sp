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
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_YouMustBeAliveToTalk", client);
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

	if(	strcmp(szSayTrig, "!plainte", false) == 0 || strcmp(szSayTrig, "/plainte", false) == 0 ||
		strcmp(szSayTrig, "!complaint", false) == 0 || strcmp(szSayTrig, "/complaint", false) == 0
		) {

		if( !IsClientInJail(client) ) {
			ACCESS_DENIED(client);
		}
		
		// Setup menu
		Handle menu = CreateMenu(MenuTribunal_plainte);
		char steamID[32], nickname[64];
		
		SetMenuTitle(menu, "%T\n ", "Cmd_Plainte", client);

		for(int i=1; i<=MaxClients; i++) {
			if( !IsValidClient(i) )
				continue;
			if( i == client )
				continue;
			if( !IsPolice(i) && !IsJuge(i) )
				continue;

			GetClientAuthId(i, AUTH_TYPE, steamID, sizeof(steamID), false);
			GetClientName2(i, nickname, sizeof(nickname), true);
			
			AddMenuItem(menu, steamID, nickname);
		}

		SetMenuExitButton(menu, true);
		DisplayMenu(menu, client, MENU_TIME_DURATION);

		return Plugin_Handled;
	}
	else if(
		strcmp(szSayTrig, "!peine", false) == 0 || strcmp(szSayTrig, "/peine", false) == 0 ||
		strcmp(szSayTrig, "!penalty", false) == 0 || strcmp(szSayTrig, "/penalty", false) == 0
		
		) {

		if( !IsClientInJail(client) ) {
			ACCESS_DENIED(client);
		}
		
		g_bUserData[client][b_ExitJailMenu] = false;

		return Plugin_Handled;
	}
	else if(
		strcmp(szSayTrig, "!site", false) == 0 || strcmp(szSayTrig, "/site", false) == 0 ||
		strcmp(szSayTrig, "!web", false) == 0 || strcmp(szSayTrig, "/web", false) == 0
		) {		
		RP_ShowMOTD(client, MOD_URL);

		return Plugin_Handled;
	}
	else if(
		strcmp(szSayTrig, "!recycl", false) == 0 || strcmp(szSayTrig, "/recycl", false) == 0 ||
		strcmp(szSayTrig, "!recycler", false) == 0 || strcmp(szSayTrig, "/recycler", false) == 0 ||
		strcmp(szSayTrig, "!recyclage", false) == 0 || strcmp(szSayTrig, "/recyclage", false) == 0
		) {
		RP_ShowMOTD(client, MOD_URL ... "craft.php");

		return Plugin_Handled;
	}
	else if(
		strcmp(szSayTrig, "!craft", false) == 0 || strcmp(szSayTrig, "/craft", false) == 0
		) {
		RP_ShowMOTD(client, MOD_URL ... "/#/craft/0");

		return Plugin_Handled;
	}
	else if(
		strcmp(szSayTrig, "!success", false) == 0 || strcmp(szSayTrig, "/success", false) == 0 ||
		strcmp(szSayTrig, "!sucess", false) == 0 || strcmp(szSayTrig, "/sucess", false) == 0 ||
		strcmp(szSayTrig, "!succes", false) == 0 || strcmp(szSayTrig, "/succes", false) == 0 ||
		strcmp(szSayTrig, "!achievement", false) == 0 || strcmp(szSayTrig, "/achievement ", false) == 0 ||
		strcmp(szSayTrig, "!succès", false) == 0 || strcmp(szSayTrig, "/succès", false) == 0	
		) {
		
		Draw_Success(client, -1);
		
		return Plugin_Handled;
	}
	else if(
		strcmp(szSayTrig, "!a", false) == 0		|| strcmp(szSayTrig, "/a", false) == 0
		) {
		int flags = GetUserFlagBits(client);
		if (!(flags & ADMFLAG_GENERIC || flags & ADMFLAG_ROOT)) {
			ACCESS_DENIED(client);
		}

		CPrintToChatAll("{red} =================================={default} ");
		CPrintToChatAll("%T", "Chat_Talk", LANG_SERVER, name, "Chat_TAG_Admin", szSayText);
		CPrintToChatAll("{red} =================================={default} ");

		return Plugin_Handled;
	}
	else if(
		strcmp(szSayTrig, "!screen", false) == 0	|| strcmp(szSayTrig, "/screen", false) == 0
		) {

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
	else if(
		strcmp(szSayTrig, "!money", false) == 0	|| strcmp(szSayTrig, "/money", false) == 0	||
		strcmp(szSayTrig, "!statut", false) == 0	|| strcmp(szSayTrig, "/statut", false) == 0	||
		strcmp(szSayTrig, "!hud", false) == 0	|| strcmp(szSayTrig, "/hud", false) == 0	||
		strcmp(szSayTrig, "!s", false) == 0	|| strcmp(szSayTrig, "/s", false) == 0	||
		strcmp(szSayTrig, "!status", false) == 0	|| strcmp(szSayTrig, "/status", false) == 0
		) {

		CPrintToChat(client, "" ...MOD_TAG... " %T", "Cmd_Money", client, g_iUserData[client][i_Money], g_iUserData[client][i_Bank], g_szJobList[g_iUserData[client][i_Job]][job_type_name]);

		return Plugin_Handled;
	}
	else if(
		strcmp(szSayTrig, "!passive", false) == 0 || strcmp(szSayTrig, "/passive", false) == 0 ||
		strcmp(szSayTrig, "!passif", false) == 0 || strcmp(szSayTrig, "/passif", false) == 0 ||
		strcmp(szSayTrig, "!active", false) == 0 || strcmp(szSayTrig, "/active", false) == 0 ||
		strcmp(szSayTrig, "!actif", false) == 0 || strcmp(szSayTrig, "/actif", false) == 0
		) {
		
		if( g_iUserData[client][i_PlayerLVL] < 2 ) {
			char tmp[128];
			rp_GetLevelData(level_2, rank_type_name, tmp, sizeof(tmp));
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_Level", client, 2, tmp);
			return Plugin_Handled;
		}
		
		Draw_PassiveMenu(client);
		return Plugin_Handled;
	}
	else if(
		strcmp(szSayTrig, "!vita", false) == 0 || strcmp(szSayTrig, "/vita", false) == 0 ||
		strcmp(szSayTrig, "!vitality", false) == 0 || strcmp(szSayTrig, "/vitality", false) == 0
		) {

		CPrintToChat(client, "" ...MOD_TAG... " %T", "Cmd_Vita", client, g_flUserData[client][fl_Vitality], GetVitaLevel(client));
		return Plugin_Handled;
	}
	else if(
		strcmp(szSayTrig, "!rules", false) == 0 || strcmp(szSayTrig, "/rules", false) == 0 ||
		strcmp(szSayTrig, "!regles", false) == 0 || strcmp(szSayTrig, "/regles", false) == 0 ||
		strcmp(szSayTrig, "!code", false) == 0 || strcmp(szSayTrig, "/code", false) == 0
	) {
		RP_ShowMOTD(client, MOD_URL ... "rules.php");

		return Plugin_Handled;
	}
	else if(
		strcmp(szSayTrig, "!rev", false) == 0 || strcmp(szSayTrig, "/rev", false) == 0
		) {

		CPrintToChat(client, "" ...MOD_TAG... " %T", "Cmd_REV", client, __TIME__, __DATE__, __LAST_REV__);

		return Plugin_Handled;
	}	
	else if(
		strcmp(szSayTrig, "!leave", false) == 0 || strcmp(szSayTrig, "/leave", false) == 0 ||
		strcmp(szSayTrig, "!quitter", false) == 0 || strcmp(szSayTrig, "/quitter", false) == 0
		) {

		int door = target;
		int door_bdd = (door-MaxClients);

		if( !IsValidDoor(door) || !g_iDoorKnowed[door_bdd] ) {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_YouMustAim", "prop_door_rotating");
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
			CPrintToChat(client, ""...MOD_TAG..." %T", "Error_OnlyInsideAppart", client);
			return Plugin_Handled;
		}
		if( !g_iDoorOwner_v2[client][can] ) {
			CPrintToChat(client, ""...MOD_TAG..." %T", "Appart_MustHaveKey", client);
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
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Appart_KeyRemovedSelf", client, can);
		return Plugin_Handled;
	}
	else if(
		strcmp(szSayTrig, "!appart", false) == 0 || strcmp(szSayTrig, "/appart", false) == 0 ||
		strcmp(szSayTrig, "!garage", false) == 0 || strcmp(szSayTrig, "/garage", false) == 0
		) {
		
		// Setup menu
		Handle menu = CreateMenu(MenuNothing);
		SetMenuTitle(menu, "%T\n ", "Cmd_Appart", client);
		char tmp[256];
		
		int appart, garage;
		for(int i=0; i<MAX_KEYSELL; i++) {
			
			if( strlen(g_szSellingKeys[i][key_type_name]) <= 1 )
				continue;
			
			if( i < 100 ) {
				Format(tmp, sizeof(tmp), "%T", g_iAppartBonus[i][appart_proprio] > 0 ? "Cmd_Appart_Occupied" : "Cmd_Appart_Free", client, i);
			}
			else {
				Format(tmp, sizeof(tmp), "%T", g_iAppartBonus[i][appart_proprio] > 0 ? "Cmd_Garage_Occupied" : "Cmd_Garage_Free", client, i-100);
			}
			
			AddMenuItem(menu, tmp, tmp,		ITEMDRAW_DISABLED);
		}
		
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Cmd_Appart_Count", client, appart, garage);
		
		SetMenuExitButton(menu, true);
		DisplayMenu(menu, client, MENU_TIME_DURATION);
		
		return Plugin_Handled;
	}
	else if(
		strcmp(szSayTrig, "!tuto", false) == 0 || strcmp(szSayTrig, "/tuto", false) == 0 ||
		strcmp(szSayTrig, "!tutorial", false) == 0 || strcmp(szSayTrig, "/tutorial", false) == 0
	) {
		
		// Setup menu
		Handle menu = CreateMenu(MenuNothing);
		SetMenuTitle(menu, "%T\n ", "Cmd_ListOfPlayer", client);
		char tmp[256];
		
		int count;
		for(int i=1; i<=MaxClients; i++) {
			if( !IsValidClient(i) )
				continue;
			
			GetClientName2(i, tmp, sizeof(tmp), true);
			if( !IsTutorialOver(i) ) {
				Format(tmp, sizeof(tmp), "%T", "Cmd_Tuto_InTutorial", client, tmp);
				AddMenuItem(menu, tmp, tmp,		ITEMDRAW_DISABLED);
				count++;
			}
			else if( g_iUserData[i][i_Job] > 0 && !g_iClient_OLD[i] ) {
				Format(tmp, sizeof(tmp), "%T", "Cmd_Tuto_WithJob", client, tmp);
				AddMenuItem(menu, tmp, tmp,		ITEMDRAW_DISABLED);
				count++;
			}
			else if(  g_iUserData[i][i_Job] == 0 && !g_iClient_OLD[i] ) {
				Format(tmp, sizeof(tmp), "%T", "Cmd_Tuto_WithoutJob", client, tmp);
				AddMenuItem(menu, tmp, tmp,		ITEMDRAW_DISABLED);
				count++;
			}
		}
		
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Cmd_Tuto_Count", client, count);
		
		SetMenuExitButton(menu, true);
		DisplayMenu(menu, client, MENU_TIME_DURATION);
		
		return Plugin_Handled;
	}
	else if(
		strcmp(szSayTrig, "!vol", false) == 0		|| strcmp(szSayTrig, "/vol", false) == 0 ||
		strcmp(szSayTrig, "!voler", false) == 0		|| strcmp(szSayTrig, "/voler", false) == 0 ||
		strcmp(szSayTrig, "!voller", false) == 0		|| strcmp(szSayTrig, "/voller", false) == 0 ||
		strcmp(szSayTrig, "!steal", false) == 0		|| strcmp(szSayTrig, "/steal", false) == 0
		) {

		if( GetZoneBit( GetPlayerZone(client) ) & BITZONE_BLOCKSTEAL ) {
			ACCESS_DENIED(client);
		}
		if( g_bUserData[client][b_MaySteal] == 0 || g_iUserData[client][i_LastVolCashFlowTime] > GetTime() ) {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_CannotSteal_ForNow", client);
			return Plugin_Handled;
		}
		if( GetConVarInt(g_hAllowSteal) == 0 ) {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_CannotSteal_ForNow", client);
			return Plugin_Handled;
		}
		
		
		if( !IsValidClient(target))
			return Plugin_Handled;

		if( !IsPlayerAlive(target) )
			return Plugin_Handled;
			
		if( !IsEntitiesNear(client, target) )
			return Plugin_Handled;
			
		if( g_flUserData[target][fl_Invincible] >= GetGameTime() ) {
			CPrintToChat(client, ""...MOD_TAG..." %T", "Error_CannotSteal_Target_ForNow", client);
			return Plugin_Handled;
		}
		if( (g_flUserData[target][fl_LastVente]+8.0) >= GetGameTime() ) {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_CannotSteal_Target_ForNow", client);
			return Plugin_Handled;
		}
		if( !IsTutorialOver(target) ) {
			CPrintToChat(target, "" ...MOD_TAG... " %T", "Error_CannotSteal_Target_ForNow", client);
			return Plugin_Handled;
		}
		
		Action a, b;
		float cd = STEAL_TIME;
		
		Call_StartForward( view_as<Handle>(g_hRPNative[client][RP_OnPlayerPreSteal]));
		Call_PushCell(client);
		Call_PushCell(target);
		Call_PushCellRef(cd);
		Call_Finish(a);
		
		if( a != Plugin_Stop ) {
			Call_StartForward( view_as<Handle>(g_hRPNative[client][RP_OnPlayerSteal]));
			Call_PushCell(client);
			Call_PushCell(target);
			Call_PushCellRef(cd);
			Call_Finish(b);
			
			if( b != Plugin_Stop ) {
				ACCESS_DENIED(client);
			}
		}
		
		g_bUserData[client][b_MaySteal] = 0;
		CreateTimer(cd, AllowStealing, client);
		

		return Plugin_Handled;
	}
	if(
		strcmp(szSayTrig, "!report", false) == 0		|| strcmp(szSayTrig, "/report", false) == 0
		) {

		// Setup menu
		Handle menu = CreateMenu(MenuTribunal_report);
		char steamID[32], nickname[65];
		
		SetMenuTitle(menu, "%T\n ", "Cmd_Report", client);

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
	else if(
		strcmp(szSayTrig, "!boss", false) == 0		|| strcmp(szSayTrig, "/boss", false) == 0 ||
		strcmp(szSayTrig, "!virer", false) == 0		|| strcmp(szSayTrig, "/virer", false) == 0 || 
		strcmp(szSayTrig, "!fire", false) == 0		|| strcmp(szSayTrig, "/fire", false) == 0
		) {

		if( !IsBoss(client) ) {
			ACCESS_DENIED(client);
		}

		OpenBossConfig(client);

		return Plugin_Handled;
	}
	else if(
		strcmp(szSayTrig, "!build", false) == 0		|| strcmp(szSayTrig, "/build", false) == 0	||
		strcmp(szSayTrig, "!b", false) == 0		|| strcmp(szSayTrig, "/b", false) == 0
		) {

		if( GetZoneBit( GetPlayerZone(client) ) & BITZONE_BLOCKBUILD ) {
			ACCESS_DENIED(client);
		}
		if( g_bUserData[client][b_MayBuild] == 0 || g_iUserData[client][i_KidnappedBy] > 0 ) {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Build_Cannot_ForNow", client);
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
	else if(
		strcmp(szSayTrig, "!skin", false) == 0		|| strcmp(szSayTrig, "/skin", false) == 0 ||
		strcmp(szSayTrig, "!skins", false) == 0		|| strcmp(szSayTrig, "/skins", false) == 0
		) {

		CPrintToChat(client, "" ...MOD_TAG... " %T", "Cmd_Skin", client);
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
	else if(
		strcmp(szSayTrig, "!engage", false) == 0		|| strcmp(szSayTrig, "/engage", false) == 0	||
		strcmp(szSayTrig, "!engager", false) == 0		|| strcmp(szSayTrig, "/engager", false) == 0||
		strcmp(szSayTrig, "!hire", false) == 0			|| strcmp(szSayTrig, "/hire", false) == 0
		) {

		if( !IsBoss(client) ) {
			ACCESS_DENIED(client);
		}

		if( !IsValidClient(target) ) {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_CannotFindTarget", client);
			return Plugin_Handled;
		}

		if( !IsPlayerAlive(target) )
			return Plugin_Handled;

		if( g_iUserData[target][i_Job] != 0 || GetJobPrimaryID(client) != GetJobPrimaryID(target) || IsBoss(target) ) {
			if( g_iUserData[target][i_Job] != 0 ) {
				CPrintToChat(client, "" ...MOD_TAG... " %T", "Cmd_Hire_Unemployed", client);
				return Plugin_Handled;
			}
		}

		char tmp[256], targetname[64];
		GetClientName2(target, targetname, sizeof(targetname), true);
		Format(tmp, sizeof(tmp), "%T\n ", "Cmd_Hire", client, targetname);

		// Setup menu
		Handle hHireMenu = CreateMenu(eventHireMenu);
		SetMenuTitle(hHireMenu, tmp);

		for(int i = 0; i < MAX_JOBS; i++) {
			if( StringToInt(g_szJobList[i][2]) != GetJobPrimaryID(client) )
				continue;

			if( StringToInt(  g_szJobList[ i ][job_type_cochef] ) == 1 && StringToInt(  g_szJobList[ g_iUserData[client][i_Job] ][job_type_cochef] ) == 1 )
				continue;

			Format(tmp, 254, "%d_%d", target, i);
			AddMenuItem(hHireMenu, tmp, g_szJobList[i][job_type_name]);
		}

		SetMenuExitButton(hHireMenu, true);
		DisplayMenu(hHireMenu, client, MENU_TIME_DURATION);

		return Plugin_Handled;
	}
	else if(
		strcmp(szSayTrig, "!demission", false) == 0		|| strcmp(szSayTrig, "/demission", false) == 0		||
		strcmp(szSayTrig, "!demissionner", false) == 0	|| strcmp(szSayTrig, "/demissionner", false) == 0	||
		strcmp(szSayTrig, "!demissionne", false) == 0	|| strcmp(szSayTrig, "/demissionne", false) == 0    ||
		strcmp(szSayTrig, "!dismiss", false) == 0	|| strcmp(szSayTrig, "/dismiss", false) == 0
		) {

		if( StringToInt(  g_szJobList[ g_iUserData[client][i_Job] ][job_type_isboss] ) == 1) {
			CPrintToChat(client, "" ...MOD_TAG... "%T", "Cmd_Dismiss_Cannot_Chef", client);
			return Plugin_Handled;
		}
		if( g_iClientQuests[client][questID] != -1 ) {		
  			CPrintToChat(client, "" ...MOD_TAG... " %T", "Cmd_Dismiss_Cannot_Quest", client);		
 			return Plugin_Handled;		
 		}
		if( strlen(g_szPlainte[client][1]) <= 1 ) {

			String_GetRandom(g_szPlainte[client][1], sizeof(g_szPlainte[][]), 4, "23456789abcdefgpqrstuvxyz");
			
			if( g_iUserData[client][i_AllowedDismiss] < 0 ) {
				char tmp[1024], expl[8][256];
				Format(tmp, sizeof(tmp), "%T", "Cmd_Dismiss_Warning", client);
				int len = ExplodeString(tmp, "\n", expl, sizeof(expl), sizeof(expl[]));
				for (int i = 0; i < len; i++) {
					CPrintToChat(client, "" ...MOD_TAG... " %s", expl[i]);
				}
			}
			
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Cmd_Dismiss_Confirm", client, g_szPlainte[client][1]);
		}
		else {
			if( StrContains(szSayText, g_szPlainte[client][1], false) == 1 ) {
				ChangePersonnal(client, SynType_job, 0, client);
				
				Format(g_szPlainte[client][1], sizeof(g_szPlainte[][]), "");
			}
			else {
				CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_WrongCode", client);
				CPrintToChat(client, "" ...MOD_TAG... " %T", "Cmd_Dismiss_Confirm", client, g_szPlainte[client][1]);
			}
		}

		return Plugin_Handled;
	}
	
	else if(
		strcmp(szSayTrig, "!givexp", false) == 0		|| strcmp(szSayTrig, "/givexp", false) == 0
		) {
		
		int flags = GetUserFlagBits(client);
		if( !(flags & ADMFLAG_GENERIC || flags & ADMFLAG_ROOT) ) {
			ACCESS_DENIED(client);
		}
		
		if( !IsValidClient(target) )
			return Plugin_Handled;

		if( !IsPlayerAlive(target) )
			return Plugin_Handled;

		int amount = StringToInt(szSayText);

		if( g_iUserData[client][i_GiveXP] < amount ) {
			CPrintToChat(client, ""...MOD_TAG..." %T", "Cmd_GiveXP_NotEnought", client);
			return Plugin_Handled;
		}
		if( amount < 100 ) {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Cmd_GiveXP_MoreThan", client);
			return Plugin_Handled;
		}
		
		g_iUserData[client][i_GiveXP] -= amount;
		rp_ClientXPIncrement(target, amount);
		
		char clientname[64], targetname[64];
		GetClientName2(client, clientname, sizeof(clientname), false);
		GetClientName2(target, targetname, sizeof(targetname), false);

		CPrintToChat(client, "" ...MOD_TAG... " %T", "Cmd_GiveXP_Target", client, amount, targetname);
		CPrintToChat(target, "" ...MOD_TAG... " %T", "Cmd_GiveXP_Self", target, amount, clientname);
		
		LogToGame("[TSX-RP] [GIVE-XP] %L a donné %iXP à %L.", client, amount, target);
		
		StoreUserData(client);
		StoreUserData(target);
		
		return Plugin_Handled;
	}
	else if(
		strcmp(szSayTrig, "!givecb", false) == 0		|| strcmp(szSayTrig, "/givecb", false) == 0	||
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
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Cmd_Give_NotEnought", client);
			return Plugin_Handled;
		}
		if( amount <= 0 ) {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Cmd_Give_MoreThan", client);
			return Plugin_Handled;
		}
		
		rp_ClientMoney(client, i_Bank, -amount);
		rp_ClientMoney(target, i_Money, amount);

		char clientname[64], targetname[64];
		GetClientName2(client, clientname, sizeof(clientname), false);
		GetClientName2(target, targetname, sizeof(targetname), false);

		CPrintToChat(client, "" ...MOD_TAG... " %T", "Cmd_Give_Target", client, amount, targetname);
		CPrintToChat(target, "" ...MOD_TAG... " %T", "Cmd_Give_Self", target, amount, clientname);
		
		LogToGame("[TSX-RP] [GIVE-MONEY] %L a donné %i$ à %L.", client, amount, target);

		return Plugin_Handled;
	}
	else if(
		strcmp(szSayTrig, "!thirdperson", false) == 0		|| strcmp(szSayTrig, "/thirdperson", false) == 0 ||
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
	else if(
		strcmp(szSayTrig, "!enquete", false) == 0		|| strcmp(szSayTrig, "/enquete", false) == 0 ||
		strcmp(szSayTrig, "!investigation", false) == 0	|| strcmp(szSayTrig, "/investigation", false) == 0
		) {
		if( !IsPolice(client) && !IsJuge(client) && !IsTueur(client) ) {
			ACCESS_DENIED(client);
		}

		if( (g_iUserData[client][i_Money]+g_iUserData[client][i_Bank]) < 100 ) {
			ACCESS_DENIED(client);
		}		

		if( g_bUserData[client][b_MaySteal] == 0 ) {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_Command_ForNow", client);
			return Plugin_Handled;
		}

		if( !IsValidClient(target) )
			return Plugin_Handled;

		if( !IsPlayerAlive(target) )
			return Plugin_Handled;
		
		
		if( g_iUserData[client][i_KillJailDuration] >= 1 || g_iUserData[target][i_KillJailDuration] >= 1 ) {
			ACCESS_DENIED(client);
		}

		if( !IsTueur(client) ) {
			char clientname[64], targetname[64];
			GetClientName2(client, clientname, sizeof(clientname), false);
			GetClientName2(target, targetname, sizeof(targetname), false);
			
			bool fail = false;
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
				
				fail = true;
				CPrintToChat(i, "" ...MOD_TAG... " %T", "Cmd_Enquete_Call", i, clientname, targetname, g_szZoneList[GetPlayerZone(client)][zone_type_name]);
				TargetBeamBox(i, target);
				ClientCommand(i, "play buttons/blip1.wav");
			}
			
			if( fail ) {
				CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_Command_ForNow", client);
				return Plugin_Handled;
			}
		}

		g_bUserData[client][b_MaySteal] = 0;
		switch( g_iUserData[client][i_Job] ) {
			case 1:		CreateTimer(0.1, AllowStealing, client);
			case 5:		CreateTimer(5.0, AllowStealing, client);
			case 6:		CreateTimer(10.0, AllowStealing, client);
			case 7:		CreateTimer(15.0, AllowStealing, client);
			case 8:		CreateTimer(20.0, AllowStealing, client);
			case 9:		CreateTimer(25.0, AllowStealing, client);
			default:	CreateTimer(10.0, AllowStealing, client);
		}
		
		rp_ClientMoney(client, i_Money, -100);
		SetJobCapital(41,	(GetJobCapital(41)+50) );
		SetJobCapital(1,	(GetJobCapital(1)+50) );

		LogToGame("[TSX-RP] [ENQUETE] %L a regardé %L", client, target);
		ServerCommand("rp_item_enquete \"%i\" \"%i\"", client, target);

		return Plugin_Handled;
	}
	else if(
		strcmp(szSayTrig, "!win", false) == 0		|| strcmp(szSayTrig, "/win", false) == 0	||
		strcmp(szSayTrig, "!gagnant", false) == 0		|| strcmp(szSayTrig, "/gagnant", false) == 0
		) {

		char query[1024];
		Format(query, sizeof(query), "SELECT `name`, CEIL((UNIX_TIMESTAMP()-`timestamp`)/(60*60)) as txt FROM `rp_sell` INNER JOIN `rp_users` ON `rp_users`.`steamid`=`rp_sell`.`steamid` WHERE `rp_sell`.`item_type`='4' AND `rp_sell`.`job_id`='171' ORDER BY `id` DESC LIMIT 10;");

		SQL_TQuery(g_hBDD, menuShowNote_Client, query, client, DBPrio_Low);

		return Plugin_Handled;
	}
	else if(
		strcmp(szSayTrig, "!cagnotte", false) == 0		|| strcmp(szSayTrig, "/cagnotte", false) == 0 ||
		strcmp(szSayTrig, "!jackpot", false) == 0		|| strcmp(szSayTrig, "/jackpot", false) == 0
		) {

		char szSteamID[64];
		GetClientAuthId(client, AUTH_TYPE, szSteamID, sizeof(szSteamID), false);
		
		char query[1024];
		Format(query, sizeof(query), "SELECT COUNT(*) FROM `rp_loto` WHERE `steamid`='%s';", szSteamID);

		SQL_TQuery(g_hBDD, showCagnotteInfo, query, client);

		return Plugin_Handled;
	}
	else if(
		strcmp(szSayTrig, "!shownote", false) == 0		|| strcmp(szSayTrig, "/shownote", false) == 0	||
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
	else if(
		strcmp(szSayTrig, "!addnote", false) == 0		|| strcmp(szSayTrig, "/addnote", false) == 0 ||
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
				CPrintToChat(i, "" ...MOD_TAG... " %T", "Cmd_AddNote", i, name, szSayText);
			}
		}
		return Plugin_Handled;
	}
	else if(
		strcmp(szSayTrig, "!deletenote", false) == 0		|| strcmp(szSayTrig, "/deletenote", false) == 0 ||
		strcmp(szSayTrig, "!delnote", false) == 0		|| strcmp(szSayTrig, "/delnote", false) == 0 ||
		strcmp(szSayTrig, "!delnotes", false) == 0		|| strcmp(szSayTrig, "/delnotes", false) == 0 ||
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
	else if(
		strcmp(szSayTrig, "!afk", false) == 0 || strcmp(szSayTrig, "/afk", false) == 0
		) {

		if( !IsPolice(client) && !IsJuge(client) ) {
			ACCESS_DENIED(client);
		}
		
		int braquage = GetConVarInt(FindConVar("rp_braquage"));
		
		if( braquage > 0 ) {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "AFK_Braquage", client);
			LogToGame("[CHEATING] [AFK-BRAQUAGE] %L.", client);
		}
		
		if( g_bUserData[client][b_Stealing] ) {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_Command_ForNow", client);
			return Plugin_Handled;
		}
		GetClientEyeAngles(client, g_Position[client]);
		
		g_iUserData[client][i_TimeAFK] += 180;
		return Plugin_Handled;
	}
	else if(
		strcmp(szSayTrig, "!assu", false) == 0		|| strcmp(szSayTrig, "/assu", false) == 0 ||
		strcmp(szSayTrig, "!assurance", false) == 0	|| strcmp(szSayTrig, "/assurance", false) == 0 ||
		strcmp(szSayTrig, "!insurance", false) == 0	|| strcmp(szSayTrig, "/insurance", false) == 0
		) {

		CPrintToChat(client, "" ...MOD_TAG... " %T", "Cmd_Assu", client, GetAssurence(client));
		return Plugin_Handled;
	}
	else if(
		strcmp(szSayTrig, "!heal", false) == 0		|| strcmp(szSayTrig, "/heal", false) == 0	||
		strcmp(szSayTrig, "!soin", false) == 0		|| strcmp(szSayTrig, "/soin", false) == 0 	||
		strcmp(szSayTrig, "!mort", false) == 0		|| strcmp(szSayTrig, "/mort", false) == 0 	||
		strcmp(szSayTrig, "!dead", false) == 0		|| strcmp(szSayTrig, "/dead", false) == 0 
		) {

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
		SetMenuTitle(menu, "%T\n ", "Cmd_ListOfPlayer", client);
		
		int amount = 0;
		
		char tmp[24], tmp2[64];
		for(int i=1; i<=MaxClients; i++) {
			if( !IsValidClient(i) )
				continue;
			if( IsPlayerAlive(i) ) {

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
				
				GetClientName2(i, tmp2, sizeof(tmp2), true);
				AddMenuItem(menu, tmp, tmp2);
				amount++;
			}
			else {
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
				GetClientName2(i, tmp2, sizeof(tmp2), true);
				AddMenuItem(menu, tmp, tmp2);
				amount++;
			}
		}

		if( amount > 0 ) {
			SetMenuExitButton(menu, true);
			DisplayMenu(menu, client, MENU_TIME_DURATION);
		}
		else {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Cmd_ListOfPlayer_None", client);
			CloseHandle(menu);
		}
		
		return Plugin_Handled;
	}
	// ----------------------------------------------------------------------------------------------------------------------------------
	// ----------------------------------------------------------------------------------------------------------------------------------
	// ----------------------------------------------------------------------------------------------------------------------------------
	if( GetZoneBit( GetPlayerZone(client) ) & BITZONE_BLOCKTALK ) {
		ACCESS_DENIED(client);
	}
	if(
		strcmp(szSayTrig, "!use", false) == 0 || strcmp(szSayTrig, "/use", false) == 0
		) {
		
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
	else if(
		strcmp(szSayTrig, "!forceuse", false) == 0 || strcmp(szSayTrig, "/forceuse", false) == 0
		) {

		if( !IsAdmin(client) ) {
			ACCESS_DENIED(client);
		}

		//Open:
		rp_AcceptEntityInput(target, "Toggle", client);

		return Plugin_Handled;
	}
	else if(
		strcmp(szSayTrig, "!forcelock", false) == 0 || strcmp(szSayTrig, "/forcelock", false) == 0
		) {

		if( !IsAdmin(client) ) {
			ACCESS_DENIED(client);
		}

		g_iDoorNouse[ (target - MaxClients) ] = 1;


		return Plugin_Handled;
	}
	else if(
		strcmp(szSayTrig, "!forceunlock", false) == 0 || strcmp(szSayTrig, "/forceunlock", false) == 0
		) {


		if( !IsAdmin(client) ) {
			ACCESS_DENIED(client);
		}

		g_iDoorNouse[ (target - MaxClients) ] = 0;

		return Plugin_Handled;
	}
	else if(
		strcmp(szSayTrig, "!lock", false) == 0 || strcmp(szSayTrig, "/lock", false) == 0
		) {

		target = GetClientAimTarget(client, false);
		if( !IsValidDoor(target) && IsValidEdict(target) && IsValidDoor(Entity_GetParent(target)) )
			target = Entity_GetParent(target);

		ToggleDoorLock(client, target, 1);

		return Plugin_Handled;
	}
	else if(
		strcmp(szSayTrig, "!unlock", false) == 0 || strcmp(szSayTrig, "/unlock", false) == 0
		) {

		target = GetClientAimTarget(client, false);
		if( !IsValidDoor(target) && IsValidEdict(target) && IsValidDoor(Entity_GetParent(target)) )
			target = Entity_GetParent(target);

		ToggleDoorLock(client, target, 2);

		return Plugin_Handled;
	}
	else if(
		strcmp(szSayTrig, "!out", false) == 0		|| strcmp(szSayTrig, "/out", false) == 0
		) {

		#if defined USING_VEHICLE
		if( IsValidVehicle(target) ) {
			int car = GetEntPropEnt(client, Prop_Send, "m_hVehicle");
			int driver = GetEntPropEnt(target, Prop_Send, "m_hPlayer");
			if( IsEntitiesNear(client, target)) {
				if( car == -1 ) {
					if( IsValidClient(driver) ) {
						char client_name[128];
						GetClientName2(client, client_name, sizeof(client_name), false);
						if( g_iVehicleData[target][car_owner] == client && driver != client ) {
							ExitVehicle(driver, target, true);
							CPrintToChat(driver, ""...MOD_TAG..." %T", "Cmd_OutOf_Car_By", driver, client_name);
						}
						
						if( g_iUserData[client][i_ToKill] == driver && driver != client ) {
							ExitVehicle(driver, target, true);
							CPrintToChat(driver, ""...MOD_TAG..." %T", "Cmd_OutOf_Car_By", driver, client_name);
						}
						
						for(int i=1; i<=MaxClients; i++) {
							if( !IsValidClient(i) )
								continue;
							if( g_iCarPassager[target][i] && g_iUserData[client][i_ToKill] == i && i != client ) {
								LeaveVehiclePassager(i, target);
								CPrintToChat(i, ""...MOD_TAG..." %T", "Cmd_OutOf_Car_By", i, client_name);
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
		
		if( g_bUserData[client][b_GameModePassive] == true ) {
			ACCESS_DENIED(client);
		}

		if( g_bUserData[client][b_MaySteal] == 0) {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_Command_ForNow", client);
			return Plugin_Handled;
		}
		
		if( Entity_GetDistance(client, target) > MAX_AREA_DIST/2 ) {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Cmd_TargetIsToFar", client);
			return Plugin_Handled;
		}
		
		if( g_iUserData[target][i_KidnappedBy] > 0 ) {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Cmd_Out_Cannot_Kidnap", client);
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
		
		if( (ClientZone == 0 || ClientZoneJob <= 0 || ClientZoneJob != job_tree) && !in_appart ) {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_Command_Here", client);
			return Plugin_Handled;
		}
		if( (ClientZoneJob != TargetZoneJob) && !in_appart ) {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Cmd_Out_Cannot_Zone", client);
			return Plugin_Handled;
		}
		if( (ClientZone != TargetZone) && in_appart ) {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Cmd_Out_Cannot_Zone", client);
			return Plugin_Handled;
		}
		if( in_appart && g_iDoorOwner_v2[target][appart] ) {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Cmd_Out_Cannot_Coloc", client);
			return Plugin_Handled;
		}

		if( StringToInt( g_szZoneList[ClientZone][zone_type_bit] ) & BITZONE_PERQUIZ ) {
			if( !IsPolice(client) && !IsJuge(client) ) {
				CPrintToChat(client, "" ...MOD_TAG... " %T", "Cmd_Out_Cannot_Perquiz", client);
				return Plugin_Handled;
			}
		}
		
		if( rp_GetClientBool(target, b_Lube) && Math_GetRandomInt(1, 5) != 5) {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Cmd_TargetIsSlippy", client);
			return Plugin_Handled;
		}
		
		char clientname[64], targetname[64];
		GetClientName2(client, clientname, sizeof(clientname), false);
		GetClientName2(target, targetname, sizeof(targetname), false);
		
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Cmd_Out_Target", client, targetname);
		CPrintToChat(target, ""...MOD_TAG..." %T", "Cmd_Out_Self", target, clientname);
		LogToGame("[OUT] %L a sorti %L", client, target);
		
		SendPlayerToSpawn(target, true);
		rp_ClientColorize(target);
		
		g_bUserData[client][b_MaySteal] = false;
		CreateTimer(GetClientTeam(target) == CS_TEAM_CT ? 10.0 : 5.0, AllowStealing, client);

		return Plugin_Handled;
	}
	

	else if(
		strcmp(szSayTrig, "!vendre", false) == 0	|| strcmp(szSayTrig, "/vendre", false) == 0	||
		strcmp(szSayTrig, "!sell", false) == 0	|| strcmp(szSayTrig, "/sell", false) == 0	||
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
	else if(
		strcmp(szSayTrig, "!give", false) == 0		|| strcmp(szSayTrig, "/give", false) == 0	||
		strcmp(szSayTrig, "!donner", false) == 0	|| strcmp(szSayTrig, "/donner", false) == 0
		) {
		if( !IsTutorialOver(client) ) {
			return Plugin_Handled;
		}		
		
		if( g_iUserData[client][i_PlayerLVL] < 12 ) {
			char tmp[128];
			rp_GetLevelData(level_simple_citizen, rank_type_name, tmp, sizeof(tmp));
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_Level", 12, tmp);
			return Plugin_Handled;
		}
		
		if( g_bUserData[client][b_IsSearchByTribunal] && rp_GetClientJobID(target) != 101 ) {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Cmd_Give_Tribunal", client);
			return Plugin_Handled;
		}
		if( g_iUserData[client][i_SearchLVL] >= 1 && rp_GetClientJobID(target) != 101 ) {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Cmd_Give_Tribunal", client);
			return Plugin_Handled;
		}	
		
		if( g_bUserData[client][b_IsMuteGive] ) {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Banned_Give", client);
			return Plugin_Handled;
		}
		
		if( !IsValidClient(target) )
			return Plugin_Handled;

		if( !IsPlayerAlive(target) )
			return Plugin_Handled;

		int amount = StringToInt(szSayText);

		if( g_iUserData[client][i_Money] < amount ) {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Cmd_Give_NotEnought", client);
			return Plugin_Handled;
		}
		if( amount <= 0 ) {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Cmd_Give_MoreThan", client);
			return Plugin_Handled;
		}
		if( amount > 100000 ) {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Cmd_Give_LessThan", client);
			return Plugin_Handled;
		}
		
		if( g_iUserData[client][i_GiveAmountTime]+amount > 100000 ) {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Cmd_Give_TooFast", client);
			return Plugin_Handled;
		}
		char targetSteamID[64];
		GetClientAuthId(target, AUTH_TYPE, targetSteamID, sizeof(targetSteamID), false);
		
		if( g_iDoubleCompte[client].FindString(targetSteamID) >= 0 ) {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Cmd_Give_Double", client);
			
			GetClientAuthId(client, AUTH_TYPE, targetSteamID, sizeof(targetSteamID), false);
			CPrintToChat(client, "" ...MOD_URL... " /index.php#/pilori/double/%s", targetSteamID);
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
		
		char clientname[64], targetname[64];
		GetClientName2(client, clientname, sizeof(clientname), false);
		GetClientName2(target, targetname, sizeof(targetname), false);

		CPrintToChat(client, "" ...MOD_TAG... " %T", "Cmd_Give_Target", client, amount, targetname);
		CPrintToChat(target, "" ...MOD_TAG... " %T", "Cmd_Give_Self", target, amount, clientname);
		
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
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_YouMustWaitToTalk", client, g_iSuccess_last_chat[client]+time-GetTime());
			return Plugin_Handled;
		}
	}
	
	if( !IsAdmin(client) ) {
		if( strlen(szSayText) > 0 ) {
			
			bool block = false;
			for (int i = 0; i < sizeof(g_szLastMessage[]); i++) {
				if( StrEqual(g_szLastMessage[client][i], szSayText, false) ) {
					block = true;
					break;
				}
			}
			
			if( block ) {
				CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_YouMustNotSpam", client);
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
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Banned_GlobalTalk", client);
		return Plugin_Handled;
	}

	if( removed ) {
		Format(szSayText, sizeof(szSayText), "%s %s", szSayTrig, szSayText);
	}
	
	char tag[32];
	Format(tag, sizeof(tag), "Empty_String");
	if( g_bIsHidden[client] == false ) {
		if( flags & ADMFLAG_ROOT || flags & ADMFLAG_CONFIG ) {
			Format(tag, sizeof(tag), "Chat_TAG_Admin"); 
		}
		else if( flags & ADMFLAG_KICK ) {
			Format(tag, sizeof(tag), "Chat_TAG_VIP");
		}
	}
	
	CPrintToChatAllEx(client, "%T", "Chat_Talk", LANG_SERVER, name, tag, szSayText);

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
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_YouMustBeAliveToTalk", client);
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
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Banned_LocalTalk", client);
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
			CPrintToChatEx(i, client, "%T", "Chat_Talk", LANG_SERVER, str, "Chat_TAG_LOCAL", szSayText);
		}
	}

	LogToGame("[TSX-RP] [CHAT-LOCAL] %L: %s.", client, szSayText);

	return Plugin_Handled;
}
