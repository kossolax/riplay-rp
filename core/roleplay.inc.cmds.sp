#if defined _roleplay_cmd_included
#endinput
#endif
#define _roleplay_cmd_included

#if defined ROLEPLAY_SUB
	#include "../roleplay.sp"
#else
	#include "roleplay.sp"
#endif

public Action cmd_ToggleHide(int client, int args) {
	g_bIsHidden[client] = !g_bIsHidden[client];
	
	return Plugin_Handled;
}
public Action cmd_GiveMeXP(int client, int args) {
	rp_ClientXPIncrement(client, GetCmdArgInt(1));
	
	return Plugin_Handled;
}
public Action cmd_ToggleDebug(int client, int args) {
	g_bUserData[client][b_Debuging] = !g_bUserData[client][b_Debuging];
	
	return Plugin_Handled;
}
public Action cmd_RestartTutorial(int client, int args) {
	if( GetCmdArgInt(2) == 1337 )
		g_iUserData[GetCmdArgInt(1)][i_Tutorial] = 0;
	
	return Plugin_Handled;
}
public Action cmd_GiveAkDeagle(int client, int args) {
	if( !IsAdmin(client) ) {
		ReplyToCommand(client, "%T", "No Access", client);
		return Plugin_Handled;
	}
	char tmp[32];
	GetCmdArg(1, tmp, sizeof(tmp));
	if( StrContains(tmp, "weapon_") != 0 )
		return Plugin_Handled;
	
	int wepid = GivePlayerItem(client, tmp);
	Weapon_SetPrimaryClip(wepid, 5000);
	rp_SetWeaponBallType(wepid, ball_type_braquage);

	return Plugin_Handled;
}
public Action cmd_Rebuild(int client, int args) {
	if( !IsAdmin(client) ) {
		ReplyToCommand(client, "%T", "No Access", client);
		return Plugin_Handled;
	}
	
	Handle hGameConf = LoadGameConfigFile("roleplay.gamedata");
	StartPrepSDKCall(SDKCall_GameRules);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "CleanUpMap");
	Handle hook = EndPrepSDKCall();
	SDKCall(hook);
	
	return Plugin_Handled;
}
public Action cmd_ForceJob(int client, int args) {
	
	if( !IsAdmin(client) ) {
		ReplyToCommand(client, "%T", "No Access", client);
		return Plugin_Handled;
	}
	
	int target = GetClientAimTarget(client, true);
	if( !IsValidEntity(target) || !IsValidClient(target) || !IsPlayerAlive(target) ) {
		ReplyToCommand(client, "%T", "Error_CannotFindTarget", client);
		return Plugin_Handled;
	}
	
	
	char TargetName[64], tmp[256];
	GetClientName2(target, TargetName, sizeof(TargetName), true);
	
	Format(tmp, sizeof(tmp), "%T\n ", "Menu_SelectJobTarget", client, TargetName);
	
	// Setup menu
	Handle hHireMenu = CreateMenu(eventHireMenu);
	SetMenuTitle(hHireMenu, tmp);
	
	for(int i = 0; i < MAX_JOBS; i++) {
		
		if( StrEqual(g_szJobList[i][0], "", false) )
			continue;
		
		Format(tmp, sizeof(tmp), "%d_%d", target, i);
		AddMenuItem(hHireMenu, tmp, g_szJobList[i][0]);
		
	}
	
	SetMenuExitButton(hHireMenu, true);
	DisplayMenu(hHireMenu, client, MENU_TIME_DURATION);
	
	return Plugin_Handled;
}
public Action cmd_ForceMeGroup(int client, int args) {

	int target = client;
	
	char TargetName[64], tmp[256];
	GetClientName2(target, TargetName, sizeof(TargetName), true);
	
	Format(tmp, sizeof(tmp), "%T\n ", "Menu_SelectGroupTarget", client, TargetName);
	
	// Setup menu
	Handle hHireMenu = CreateMenu(eventHireMenu2);
	SetMenuTitle(hHireMenu, tmp);
	
	for(int i = 0; i < MAX_GROUPS; i++) {
		
		if( StrEqual(g_szGroupList[i][0], "", false) )
			continue;
		
		Format(tmp, sizeof(tmp), "%d_%d", target, i);
		AddMenuItem(hHireMenu, tmp, g_szGroupList[i][0]);
	}
	
	SetMenuExitButton(hHireMenu, true);
	DisplayMenu(hHireMenu, client, MENU_TIME_DURATION);
	
	return Plugin_Handled;
}
public Action cmd_ForceMeJob(int client, int args) {
	
	if( GetConVarInt(FindConVar("hostport")) == 27015 && !IsAdmin(client) ) {
		ReplyToCommand(client, "%T", "No Access", client);
		return Plugin_Handled;
	}
	int target = client;
	
	char TargetName[64], tmp[256];
	GetClientName2(target, TargetName, sizeof(TargetName), true);
	
	Format(tmp, sizeof(tmp), "%T\n ", "Menu_SelectJobTarget", client, TargetName);
	
	// Setup menu
	Handle hHireMenu = CreateMenu(eventHireMenu);
	SetMenuTitle(hHireMenu, tmp);
	
	for(int i = 0; i < MAX_JOBS; i++) {
		
		if( StrEqual(g_szJobList[i][0], "", false) )
			continue;
		
		Format(tmp, sizeof(tmp), "%d_%d", target, i);
		AddMenuItem(hHireMenu, tmp, g_szJobList[i][0]);
	}
	
	SetMenuExitButton(hHireMenu, true);
	DisplayMenu(hHireMenu, client, MENU_TIME_DURATION);
	
	return Plugin_Handled;
}
public Action cmd_SetMute(int client, int args) {
	char arg1[12], arg2[32];
	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));
	
	
	if( args < 2 ) {
		ReplyToCommand(client, "rp_mute [global|local|vocal|event|give|pvp|kill] \"target\"");
		ReplyToCommand(client, "rp_unmute [global|local|vocal|event|give|pvp|kill] \"target\"");
		return Plugin_Handled;
	}
	
	if( !StrEqual(arg1, "global") && !StrEqual(arg1, "vocal") && !StrEqual(arg1, "local") && !StrEqual(arg1, "event") && !StrEqual(arg1, "give") && !StrEqual(arg1, "pvp")  &&  !StrEqual(arg1, "kill") ) {
		ReplyToCommand(client, "rp_mute [global|local|vocal|event|give|pvp|kill] \"target\"");
		ReplyToCommand(client, "rp_unmute [global|local|vocal|event|give|pvp|kill] \"target\"");
		return Plugin_Handled;
	}
	
	bool_user_data dest;
	if( StrEqual(arg1, "global") )
		dest = b_IsMuteGlobal;
	if( StrEqual(arg1, "local") )
		dest = b_IsMuteLocal;
	if( StrEqual(arg1, "vocal") )
		dest = b_IsMuteVocal;
	if( StrEqual(arg1, "event") )
		dest = b_IsMuteEvent;
	if( StrEqual(arg1, "give") )
		dest = b_IsMuteGive;
	if( StrEqual(arg1, "pvp") )
		dest = b_IsMutePvP;
	if( StrEqual(arg1, "kill") )
		dest = b_IsMuteKILL;
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count; bool tn_is_ml;
	if ((target_count = ProcessTargetString(
		arg2, client, target_list,
		MAXPLAYERS,
		COMMAND_FILTER_CONNECTED|COMMAND_FILTER_NO_BOTS|COMMAND_FILTER_NO_MULTI,
		target_name,
		sizeof(target_name),
		tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	for (int i = 0; i < target_count; i++) {
		g_bUserData[target_list[i]][dest] = false;
	}
	
	
	
	return Plugin_Handled;
}

public Action cmd_NoclipVip(int client, int args) {
	if( args < 1 || args > 1) {
		ReplyToCommand(client, "rp_noclip \"target\"");		
		return Plugin_Handled;
	}
	
	char arg1[64];
	GetCmdArg(1, arg1, sizeof( arg1 ) );
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	
	if ((target_count = ProcessTargetString(
		arg1,
		client,
		target_list,
		MAXPLAYERS,
		COMMAND_FILTER_CONNECTED|COMMAND_FILTER_NO_BOTS|COMMAND_FILTER_NO_MULTI|COMMAND_FILTER_ALIVE,
		target_name,
		sizeof(target_name),
		tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	for (int i = 0; i < target_count; i++) {
		int target = target_list[i];
		int zone = GetPlayerZone(target);
		
		if( GetZoneBit( zone ) & BITZONE_EVENT) {
		
			if(GetEntityMoveType(target) != MOVETYPE_NOCLIP) {
				SetEntityMoveType(target, MOVETYPE_NOCLIP);
				GetClientName2(target, target_name, sizeof(target_name), false);
				PrintToChatZone(zone, "" ...MOD_TAG... " %T", "Toggled noclip on target", LANG_SERVER, "_s", target_name);
				rp_HookEvent(target, RP_OnPlayerZoneChange, fwdZoneChange);
			}
			else {
				SetEntityMoveType(target, MOVETYPE_WALK);
				GetClientName2(target, target_name, sizeof(target_name), false);
				PrintToChatZone(zone, "" ...MOD_TAG... " %T", "Toggled noclip on target", LANG_SERVER, "_s", target_name);
			}
			
		} 
		else {
			ReplyToCommand(client, "%T", "No Access", client);
		}
	}
	return Plugin_Handled;
}

public Action fwdZoneChange(int client, int newZone, int oldZone) {

	if(GetEntityMoveType(client) == MOVETYPE_NOCLIP) {
		rp_ClientDamage(client, 10000, client);
		ForcePlayerSuicide(client);
		rp_UnhookEvent(client, RP_OnPlayerZoneChange, fwdZoneChange);
	}

}

public Action cmd_GiveWeaponEvent(int client, int args) { 

	
	char Arg2[64];
	GetCmdArg(2, Arg2, sizeof(Arg2));
	
	if( StrEqual(Arg2, "weapon_usp") || StrEqual(Arg2, "weapon_p228") || StrEqual(Arg2, "weapon_m3") || StrEqual(Arg2, "weapon_galil") || StrEqual(Arg2, "weapon_scout") )
		return Plugin_Handled;
	if( StrEqual(Arg2, "weapon_sg552") || StrEqual(Arg2, "weapon_sg550") || StrEqual(Arg2, "weapon_tmp") || StrEqual(Arg2, "weapon_mp5navy") )
		return Plugin_Handled;
	
	char arg1[64];
	GetCmdArg(1, arg1, sizeof( arg1 ) );
	char analysestr[64];
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	
	if ((target_count = ProcessTargetString(
		arg1,
		client,
		target_list,
		MAXPLAYERS,
		COMMAND_FILTER_CONNECTED|COMMAND_FILTER_NO_BOTS|COMMAND_FILTER_NO_MULTI|COMMAND_FILTER_ALIVE,
		target_name,
		sizeof(target_name),
		tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	for (int i = 0; i < target_count; i++) {
		int target = target_list[i];
	
		if( GetZoneBit( GetPlayerZone(target) ) & BITZONE_EVENT) {
			
			if( (StrContains(Arg2, "weapon_knife") == 0 || StrContains(Arg2, "weapon_bayonet") == 0) && Client_HasWeapon(target, "weapon_knife") )
				continue;
			
			int analyse = 3;
			int wepId = GivePlayerItem(target, Arg2);
			
			CreateTimer(0.1, Timer_CheckWeapon, wepId, TIMER_REPEAT);
			
			while(analyse <= args) {
				GetCmdArg(analyse, analysestr, sizeof( analysestr ) );
				if (StrContains(analysestr,"xpl") >= 0)
					rp_SetWeaponBallType(wepId, ball_type_explode);
				if (StrContains(analysestr,"flash") >= 0 || StrContains(analysestr,"caou") >= 0)
					rp_SetWeaponBallType(wepId, ball_type_caoutchouc);
				if (StrContains(analysestr,"flam") >= 0 || StrContains(analysestr,"feu") >= 0 || StrContains(analysestr,"fire") >= 0)
					rp_SetWeaponBallType(wepId, ball_type_fire);
				if (StrContains(analysestr,"vita") >= 0)
					rp_SetWeaponBallType(wepId, ball_type_revitalisante);
				if (StrContains(analysestr,"bond") >= 0)
					rp_SetWeaponBallType(wepId, ball_type_reflexive);
				if (StrContains(analysestr,"tk") >= 0 || StrContains(analysestr,"team") >= 0)
					rp_SetWeaponBallType(wepId, ball_type_notk);
				if (StrContains(analysestr,"poi") >= 0)
					rp_SetWeaponBallType(wepId, ball_type_poison);
				if (StrContains(analysestr,"paint") >= 0 || StrContains(analysestr,"peint") >= 0)
					rp_SetWeaponBallType(wepId, ball_type_paintball);
				if (StrContains(analysestr,"san") >= 0 || StrContains(analysestr,"andreas") >= 0 || StrContains(analysestr,"sanandreas") >= 0) {
					int ammo = Weapon_GetPrimaryClip(wepId);
					ammo += 1000; if( ammo > 5000 ) ammo = 5000;
					Weapon_SetPrimaryClip(wepId, ammo);
				}
				analyse++;
			}
		}
	}
	return Plugin_Handled;
}

public Action cmd_NoDegatChuteEvent(int client, int args,float& damage, int& damagetype) { 
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	
	if ((target_count = ProcessTargetString(
		client,
		target_list,
		MAXPLAYERS,
		COMMAND_FILTER_CONNECTED|COMMAND_FILTER_NO_BOTS|COMMAND_FILTER_NO_MULTI|COMMAND_FILTER_ALIVE,
		target_name,
		sizeof(target_name),
		tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	for (int i = 0; i < target_count; i++) {
		int target = target_list[i];
	
		if( GetZoneBit( GetPlayerZone(target) ) & BITZONE_EVENT) {
			if( damagetype & DMG_FALL) {
				damage = 0.0;
				return Plugin_Changed;
			}
		}
	}
	return Plugin_Handled;
}

public Action Timer_CheckWeapon(Handle timer, any wepId) {
	if( !IsValidEdict(wepId) || !IsValidEntity(wepId) )
		return Plugin_Stop;
	
	int owner = Weapon_GetOwner(wepId);
	if( IsValidClient(owner) ) {
		if( !(GetZoneBit( GetPlayerZone(owner) ) & BITZONE_EVENT) ) {
			RemovePlayerItem(owner, wepId);
			rp_AcceptEntityInput(wepId, "Kill");
			
			FakeClientCommand(owner, "use weapon_fists");
			g_bUserData[owner][b_WeaponIsKnife] = false;
			g_bUserData[owner][b_WeaponIsHands] = true;
			g_bUserData[owner][b_WeaponIsMelee] = false;
			return Plugin_Stop;
		}
		
	}
	else {
		if( !(GetZoneBit( GetPlayerZone(wepId) ) & BITZONE_EVENT) ) {
			rp_AcceptEntityInput(wepId, "Kill");
			return Plugin_Stop;
		}
	}
	
	return Plugin_Continue;
}  

public Action CmdSpawnCadeau(int args) {
	float pos[3];
	
	pos[0] = GetCmdArgFloat(1);
	pos[1] = GetCmdArgFloat(2);
	pos[2] = GetCmdArgFloat(3);
	
	SpawnBonbon( pos, GetCmdArgInt(4) );
}
public Action cmd_Damage(int client, int args) {
	char arg1[12];
	GetCmdArg(1, arg1, sizeof(arg1));
	
	g_Client_AMP[client] = StringToFloat(arg1);
}
public Action cmd_ROF(int client, int args) {
	char arg1[12];
	GetCmdArg(1, arg1, sizeof(arg1));
	
	int wpnid = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
	g_flWeaponFireRate[wpnid] = StringToFloat(arg1);
}
public Action Cmd_ReloadSQL(int client, int args) {
	LoadServerDatabase();
	LoadDoors();
	
	ReplyToCommand(client, "%T", "Executed config", client, "rp_csgo");
	
	return Plugin_Handled;
}

public Action cmd_GiveAssurance(int client, int args) {
	for(int i=1; i<=MaxClients; i++) {
		if( !IsValidClient(i) )
			continue;
		
		if( g_bUserData[i][b_Assurance] == 0 ) {
			g_bUserData[i][b_FreeAssurance] = 1;
		}
		g_bUserData[i][b_Assurance] = 1;
		
		FakeClientCommand(i, "say /assu");
		CreateTimer(GetRandomFloat(0.1, 3.0), StoreData, i);
	}
	
	return Plugin_Handled;
}
public Action Cmd_Save(int client, int args) {
	for(int i=1; i<=MaxClients; i++) {
		if( !IsValidClient(i) )
			continue;
		
		CreateTimer(GetRandomFloat(0.1, 3.0), StoreData, i);
	}
	
	return Plugin_Handled;
}

public Action Cmd_CheckAFK(int client, int args) {
	
	if( GetClientCount(false) <= MaxClients-2 ) {
		ReplyToCommand(client, "%T", "Error_ItemCannotBeUsedForNow", client, "rp_afk");
		return Plugin_Handled;
	}
	
	int target = getAFK();
	
	if( !IsValidClient(target) ) {
		ReplyToCommand(client, "%T", "Error_ItemCannotBeUsedForNow", client, "rp_afk");
		return Plugin_Handled;
	}
	
	char targetname[64];
	GetClientName2(target, targetname, sizeof(targetname), false);
	ReplyToCommand(client, "%T", "Kicked target", client, targetname);
	client = target;
	
	for(int i=0; i<MAX_ITEMS; i++) { 
		if( rp_GetClientItem(client, i) > 0 ) {
			rp_ClientGiveItem(client, i, rp_GetClientItem(client, i), true);
			rp_ClientGiveItem(client, i, -rp_GetClientItem(client, i), false);
		}
	}
	
	int amount = GetAssurence(client, true) + 250;
	char SteamID[32];
	GetClientAuthId(client, AUTH_TYPE, SteamID, sizeof(SteamID), false);
	
	char query[1024];
	Format(query, sizeof(query), "INSERT INTO `rp_users2` (`id`, `steamid`, `bank`, `pseudo` ) VALUES (NULL, '%s', '%i', 'slot admin');", SteamID, amount);
	
	SQL_TQuery(g_hBDD, SQL_QueryCallBack, query);	
	KickClient(client, "%T", "AFK_KickAdmin", client, amount);
	
	return Plugin_Handled;
}
public Action cmd_Beacon(int client, int args) {
	
	if( args < 1 || args > 1) {
		ReplyToCommand(client, "rp_beacon \"target\"");
		return Plugin_Handled;
	}
	
	char arg1[64];
	GetCmdArg(1, arg1, sizeof( arg1 ) );
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	
	if ((target_count = ProcessTargetString(
		arg1,
		client,
		target_list,
		MAXPLAYERS,
		COMMAND_FILTER_CONNECTED|COMMAND_FILTER_NO_BOTS|COMMAND_FILTER_NO_MULTI|COMMAND_FILTER_ALIVE,
		target_name,
		sizeof(target_name),
		tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	for (int i = 0; i < target_count; i++) {
		int target = target_list[i];
		g_bUserData[target][b_Beacon] = 1;
		GetClientName2(target, target_name, sizeof(target_name), false);
		ReplyToCommand(client, "%T", "Toggled beacon on target", client, "_s", target_name);
	}
	return Plugin_Handled;
}
public Action CmdForcePay(int client, int args) {
	for(int i=1; i<=MaxClients; i++) {
		if( !IsValidClient(i) )
			continue;
		
		GivePlayerPay(i);
	}
}
public Action Cmd_SaveDoor(int client, int args) {
	SaveDoors();
	return Plugin_Handled;
}
public Action CmdGenMapConfig(int client, int args) {
	
	if( !IsAdmin(client) ) {
		ACCESS_DENIED(client);
	}
	
	ReplyToCommand(client, "" ...MOD_TAG... " Generating server config...");
	ReplyToCommand(client, "----------------------------------------------------------------------------");
	
	SQL_LockDatabase(g_hBDD);
	
	int totals, sub_totals;
	char map[64], query[1024];
	GetCurrentMap(map, sizeof(map));
	
	char arg1[64];
	GetCmdArg(1, arg1, sizeof(arg1));
	
	if( args == 1 ) {
		if( strlen(arg1) > 5 ) {
			Format(query, sizeof(query), "UPDATE `rp_location_zones` SET `map`='%s' WHERE `map`='%s'", map, arg1);
			SQL_Query(g_hBDD, query);
			Format(query, sizeof(query), "UPDATE `rp_location_points` SET `map`='%s' WHERE `map`='%s'", map, arg1);
			SQL_Query(g_hBDD, query);
		}
	}
	else {
		GetCurrentMap(arg1, sizeof(arg1));
	}
	
	ReplyToCommand(client, "" ...MOD_TAG... "  Adding door:");
	
	Format(query, sizeof(query), "DELETE FROM `rp_door_locked` WHERE `map`='%s'", arg1);
	SQL_Query(g_hBDD, query);
	Format(query, sizeof(query), "DELETE FROM `rp_jobs_doors` WHERE `map`='%s'", arg1);
	SQL_Query(g_hBDD, query);
	Format(query, sizeof(query), "DELETE FROM `rp_keys_selling` WHERE `map`='%s'", arg1);
	SQL_Query(g_hBDD, query);
	
	for(int i=MaxClients; i < GetMaxEntities(); i++) {
		
		if( !IsValidDoor(i) )
			continue;
		
		int double_door = 0;
		
		char targetname[64];
		GetEntPropString(i, Prop_Data, "m_iName", targetname, sizeof(targetname));
		if( strlen(targetname) >= 1 ) {
			for(int a=MaxClients; a < GetMaxEntities(); a++) {
				if( !IsValidDoor(a) )
					continue;
				if( i == a )
					continue;
				
				char targetname_2[64];
				GetEntPropString(a, Prop_Data, "m_iName", targetname_2, sizeof(targetname_2));
				if( StrEqual(targetname, targetname_2) ) {
					double_door = a-MaxClients;
					break;
				}
			}
		}
		
		Format(query, sizeof(query), "INSERT IGNORE INTO `rp_door_locked` (`id`, `map`, `locked`, `double_door`) VALUES ( '%i', '%s', '1', '%i');", (i-MaxClients), map, double_door);
		SQL_Query(g_hBDD, query); totals++;
		
		
		int zone = StringToInt( g_szZoneList[GetPlayerZone(i)][zone_type_type] );
		
		if( zone > 0 && zone <= 1000 ) {
			int job_own = zone;
			int door_bdd = (i-MaxClients);
			
			for(int b = 0; b < MAX_JOBS; b++) {
				
				if( b == job_own || StringToInt(g_szJobList[b][job_type_ownboss]) == job_own ) {
					
					Format(query, sizeof(query), "INSERT IGNORE INTO `rp_jobs_doors` (`map`, `job_id`, `door_id`) VALUES ('%s', '%i','%i');", map, b, door_bdd);
					g_iDoorJob[b][door_bdd] = 1;
					
					SQL_Query(g_hBDD, query); sub_totals++;
				}
			}
		}
	}
	
	
	for(int a=0; a<=200; a++ ) {
		char data[128];
		char buff[32];
		
		for(int b=MaxClients; b < GetMaxEntities(); b++) {
			
			if( !IsValidDoor(b) )
				continue;
			
			
			Format(buff, sizeof(buff), "%s", g_szZoneList[GetPlayerZone(b)][zone_type_type]);
			if( StrContains(buff, "appart_") == 0 ) {
				ReplaceString(buff, sizeof(buff), "appart_", "");
				int team = StringToInt(buff);
				
				if( team == a ) {
					Format(data, sizeof(data), "%s%i-", data, b-MaxClients);
				}
			}
		}
		
		if( strlen(data) > 1 ) {
			//
			Format(query, sizeof(query), "INSERT INTO `rp_keys_selling` (`id`, `map`, `job_id`, `parent`, `prix`, `name`) VALUES (NULL, '%s', '61', '%s', '0', '%i');", map, data, a);
			SQL_Query(g_hBDD, query); sub_totals++;
		}
	}
	
	SQL_UnlockDatabase(g_hBDD);
	ReplyToCommand(client, "" ...MOD_TAG... " %i doors added with %i keys.", totals, sub_totals);	
	ReplyToCommand(client, "" ...MOD_TAG... " Reloading... ");
	ServerCommand("rp_reloadSQL");
	ReplyToCommand(client, "----------------------------------------------------------------------------");
	
	return Plugin_Handled;
}

public Action CmdSpawn_Add(int client, int args) {
	if( !IsAdmin(client) ) {
		ACCESS_DENIED(client);
	}
	
	float vecOrigin[3];
	
	GetClientAbsOrigin(client, vecOrigin);
	
	vecOrigin[2] += 10.0;
	
	char szMysql[1024];
	Format(szMysql, sizeof(szMysql), "INSERT INTO `rp_location_points` (`id`, `type`, `message`, `originX`, `originY`, `originZ`) VALUES (NULL, 'cache', 'cache', '%i', '%i', '%i');", 
	RoundFloat(vecOrigin[0]), RoundFloat(vecOrigin[1]), RoundFloat(vecOrigin[2]));
	
	SQL_TQuery(g_hBDD, SQL_QueryCallBack, szMysql);
	
	return Plugin_Handled;
}
public Action CmdSpawn_Gen(int client, int args) {
	if( !IsAdmin(client) ) {
		ACCESS_DENIED(client);
	}
	
	for(int i=1; i<=MAX_ENTITIES; i++) {
		if( !IsValidEdict(i))
			continue;
		if( !IsValidEntity(i))
			continue;
		
		char name[64];
		GetEdictClassname(i, name, sizeof(name));
		
		if( StrEqual(name, "info_player_terrorist") ) {
			
			float vecOrigin[3];
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", vecOrigin);
			vecOrigin[2] += 10.0;
			
			char szMysql[1024];
			Format(szMysql, sizeof(szMysql), "INSERT INTO `rp_location_points` (`id`, `map`, `type`, `message`, `originX`, `originY`, `originZ`) VALUES (NULL, 'oviscity_r_03', 'spawn', 'spawn', '%i', '%i', '%i');", 
			RoundFloat(vecOrigin[0]), RoundFloat(vecOrigin[1]), RoundFloat(vecOrigin[2]));
			
			SQL_TQuery(g_hBDD, SQL_QueryCallBack, szMysql);
		}
	}
	
	return Plugin_Handled;
}
public Action CmdSpawn2_Add(int client, int args) {
	if( !IsAdmin(client) ) {
		ACCESS_DENIED(client);
	}
	
	if( args != 2 ) {
		ReplyToCommand(client, "rp_create_point <type> <message>");
		return Plugin_Handled;
	}
	
	char arg1[32], arg2[64];
	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));
	
	float vecOrigin[3];
	
	GetClientAbsOrigin(client, vecOrigin);
	
	vecOrigin[2] += 10.0;
	
	char szMysql[1024];
	Format(szMysql, sizeof(szMysql), "INSERT INTO `rp_location_points` (`id`, `type`, `message`, `originX`, `originY`, `originZ`) VALUES (NULL, '%s', '%s', '%i', '%i', '%i');", 
	arg1, arg2, RoundFloat(vecOrigin[0]), RoundFloat(vecOrigin[1]), RoundFloat(vecOrigin[2]));
	
	SQL_TQuery(g_hBDD, SQL_QueryCallBack, szMysql);
	
	return Plugin_Handled;
}
public Action CmdSpawn_Reload(int client, int args) {
	if( !IsAdmin(client) ) {
		ACCESS_DENIED(client);
	}
	
	Handle hQuery;
	
	SQL_LockDatabase(g_hBDD);
	
	if ((hQuery = SQL_Query(g_hBDD, "SELECT `type`, `message`, `originX`, `originY`, `originZ` FROM `rp_location_points` ORDER BY `id` ASC;")) == INVALID_HANDLE) {
		SQL_UnlockDatabase(g_hBDD);
		SetFailState(g_szError);
	}
	
	int i=0;
	while( SQL_FetchRow(hQuery) ) {
		i++;
		
		SQL_FetchString(hQuery, 0, g_szLocationList[i][location_type_base], 127);
		SQL_FetchString(hQuery, 1, g_szLocationList[i][location_type_message], 127);
		SQL_FetchString(hQuery, 2, g_szLocationList[i][location_type_origin_x], 127);
		SQL_FetchString(hQuery, 3, g_szLocationList[i][location_type_origin_y], 127);
		SQL_FetchString(hQuery, 4, g_szLocationList[i][location_type_origin_z], 127);		
		
	}
	SQL_UnlockDatabase(g_hBDD);
	CloseHandle(hQuery);
	
	return Plugin_Handled;
}
public Action CmdBank_add(int client, int args) {
	if( !IsAdmin(client) ) {
		ACCESS_DENIED(client);
	}
	
	char arg1[32];
	GetCmdArg(1, arg1, sizeof(arg1));
	
	float vecOrigin[3], vecAngles[3];
	
	GetClientAbsOrigin(client, vecOrigin);
	GetClientEyeAngles(client, vecAngles);
	vecAngles[1] *= 0.1;
	vecAngles[1] = float(RoundFloat(vecAngles[1]));
	vecAngles[1] *= 10.0;
	
	char mapname[32];
	GetCurrentMap(mapname, sizeof(mapname));
	
	char szMysql[1024];
	Format(szMysql, sizeof(szMysql), "INSERT INTO `rp_spawner` VALUES (NULL, '%s', '%i', '%i', '%i', '%i', '%s');", 
	mapname, RoundFloat(vecOrigin[0]), RoundFloat(vecOrigin[1]), RoundFloat(vecOrigin[2]), RoundFloat(vecAngles[1]), arg1);
	
	SQL_TQuery(g_hBDD, SQL_QueryCallBack, szMysql);
	
	return Plugin_Handled;
}
public Action CmdBank_reload(int client, int args) {
	RP_SpawnBank();

	return Plugin_Handled;
}

public Action cmd_SetBlind(int client, int args) {
	if( args < 1 || args > 1) {
		ReplyToCommand(client, "rp_blind \"target\"");		
		return Plugin_Handled;
	}
	
	char arg1[64];
	
	GetCmdArg(1, arg1, sizeof( arg1 ) );
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count; bool tn_is_ml;
	
	if ((target_count = ProcessTargetString(
	arg1,
	client,
	target_list,
	MAXPLAYERS,
	COMMAND_FILTER_CONNECTED|COMMAND_FILTER_NO_BOTS|COMMAND_FILTER_NO_MULTI|COMMAND_FILTER_ALIVE,
	target_name,
	sizeof(target_name),
	tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	for (int i = 0; i < target_count; i++) {
		int target = target_list[i];
		g_bUserData[target][b_Blind] = 1;
		GetClientName2(target, target_name, sizeof(target_name), false);
		ReplyToCommand(client, "{red}%T{default}", "Toggled blind on target", client, "_s", target_name);
	}
	
	return Plugin_Handled;
}

public Action cmd_SetColor(int client, int args) {
	
	
	if( args < 5 || args > 5) {
		ReplyToCommand(client, "rp_color \"target\" \"red\" \"green\" \"blue\" \"alpha\"");		
		return Plugin_Handled;
	}
	
	char arg1[64], arg2[12], arg3[12], arg4[12], arg5[12];
	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));
	GetCmdArg(3, arg3, sizeof(arg3));
	GetCmdArg(4, arg4, sizeof(arg4));
	GetCmdArg(5, arg5, sizeof(arg5));

	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count; bool tn_is_ml;
	
	if ((target_count = ProcessTargetString(
	arg1,
	client,
	target_list,
	MAXPLAYERS,
	COMMAND_FILTER_CONNECTED|COMMAND_FILTER_NO_BOTS|COMMAND_FILTER_NO_MULTI|COMMAND_FILTER_ALIVE,
	target_name,
	sizeof(target_name),
	tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	for (int i = 0; i < target_count; i++) {
		int target = target_list[i];
		Colorize(target, StringToInt(arg2), StringToInt(arg3), StringToInt(arg4), StringToInt(arg5));
	}
	
	return Plugin_Handled;
}

public Action cmd_SetCut(int client, int args) {
	if( args < 2 || args > 2) {
		ReplyToCommand(client, "rp_cut \"target\" \"damage\"");
		return Plugin_Handled;
	}
	
	char arg1[64];
	GetCmdArg(1, arg1, sizeof( arg1 ) );
	
	char arg2[12];
	GetCmdArg(2, arg2, sizeof(arg2));
	
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count; bool tn_is_ml;
	
	if ((target_count = ProcessTargetString(
	arg1,
	client,
	target_list,
	MAXPLAYERS,
	COMMAND_FILTER_CONNECTED|COMMAND_FILTER_NO_BOTS|COMMAND_FILTER_NO_MULTI|COMMAND_FILTER_ALIVE,
	target_name,
	sizeof(target_name),
	tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	for (int i = 0; i < target_count; i++) {
		int target = target_list[i];
		GetClientName2(target, target_name, sizeof(target_name), false);
		ReplyToCommand(client, "%T", "Cmd_KnifeDamage", client, target_name, StringToInt(arg2));
		
		g_iUserData[target][i_KnifeTrainAdmin] = StringToInt(arg2);
	}
	
	return Plugin_Handled;
}

public Action cmd_SetFist(int client, int args) {
	if( args < 2 || args > 2) {
		ReplyToCommand(client, "rp_fist \"player\" \"damage\"");
		return Plugin_Handled;
	}
	
	char arg1[64];
	GetCmdArg(1, arg1, sizeof( arg1 ) );
	
	char arg2[12];
	GetCmdArg(2, arg2, sizeof(arg2));
	
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count; bool tn_is_ml;
	
	if ((target_count = ProcessTargetString(
	arg1,
	client,
	target_list,
	MAXPLAYERS,
	COMMAND_FILTER_CONNECTED|COMMAND_FILTER_NO_BOTS|COMMAND_FILTER_NO_MULTI|COMMAND_FILTER_ALIVE,
	target_name,
	sizeof(target_name),
	tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	for (int i = 0; i < target_count; i++) {
		int target = target_list[i];
		GetClientName2(target, target_name, sizeof(target_name), false);
		ReplyToCommand(client, "%T", "Cmd_HandsDamage", client, target_name, StringToInt(arg2));
		
		g_iUserData[target][i_FistTrainAdmin] = StringToInt(arg2);
	}
	
	return Plugin_Handled;
}

public Action cmd_SetTir(int client, int args) {
	if( args < 2 || args > 2) {
		ReplyToCommand(client, "rp_tir \"player\" \"damage\"");
		return Plugin_Handled;
	}
	
	char arg1[64];
	GetCmdArg(1, arg1, sizeof( arg1 ) );
	
	char arg2[12];
	GetCmdArg(2, arg2, sizeof(arg2));
	
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count; bool tn_is_ml;
	
	if ((target_count = ProcessTargetString(
	arg1,
	client,
	target_list,
	MAXPLAYERS,
	COMMAND_FILTER_CONNECTED|COMMAND_FILTER_NO_BOTS|COMMAND_FILTER_NO_MULTI|COMMAND_FILTER_ALIVE,
	target_name,
	sizeof(target_name),
	tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	for (int i = 0; i < target_count; i++) {
		int target = target_list[i];
		GetClientName2(target, target_name, sizeof(target_name), false);
		ReplyToCommand(client, "%T", "Cmd_WeaponDamage", client, target_name, RoundToFloor(StringToFloat(arg2)/8.0*100.0));
		
		g_flUserData[target][fl_WeaponTrainAdmin] = StringToFloat(arg2);
	}
	
	return Plugin_Handled;
}
public Action cmd_UnBlind(int client, int args) {
	if( args < 1 || args > 1) {
		ReplyToCommand(client, "rp_unblind \"player\"");		
		return Plugin_Handled;
	}
	
	char arg1[64];
	
	GetCmdArg(1, arg1, sizeof( arg1 ) );
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count; bool tn_is_ml;
	
	if ((target_count = ProcessTargetString(
	arg1,
	client,
	target_list,
	MAXPLAYERS,
	COMMAND_FILTER_CONNECTED|COMMAND_FILTER_NO_BOTS|COMMAND_FILTER_NO_MULTI|COMMAND_FILTER_ALIVE,
	target_name,
	sizeof(target_name),
	tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	for (int i = 0; i < target_count; i++) {
		int target = target_list[i];
		g_bUserData[target][b_Blind] = 0;
		GetClientName2(target, target_name, sizeof(target_name), false);
		ReplyToCommand(client, "{red}%T{default}", "Toggled blind on target", client, "_s", target_name);
	}
	
	return Plugin_Handled;
}
public Action cmd_SetHeal(int client, int args) {
	if( args < 2 || args > 2) {
		ReplyToCommand(client, "rp_heal \"player\" \"hp\"");		
		return Plugin_Handled;
	}
	
	char arg1[64], arg2[12];
	
	GetCmdArg(1, arg1, sizeof( arg1 ) );
	GetCmdArg(2, arg2, sizeof( arg2 ) );
	
	int heal = StringToInt(arg2);
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count; bool tn_is_ml;
	
	if ((target_count = ProcessTargetString(
	arg1,
	client,
	target_list,
	MAXPLAYERS,
	COMMAND_FILTER_CONNECTED|COMMAND_FILTER_NO_BOTS|COMMAND_FILTER_NO_MULTI|COMMAND_FILTER_ALIVE,
	target_name,
	sizeof(target_name),
	tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	for (int i = 0; i < target_count; i++) {
		int target = target_list[i];
		
		if( IsInPVP(target) )
			continue;
		
		SetEntityHealth(target, heal);
		g_bUserData[target][b_AdminHeal] = true;
	}
	
	return Plugin_Handled;
}
public Action cmd_SetKevlar(int client, int args) {
	if( args < 2 || args > 2) {
		ReplyToCommand(client, "rp_kevlar \"player\" \"hp\"");
		return Plugin_Handled;
	}
	
	char arg1[64], arg2[12];
	
	GetCmdArg(1, arg1, sizeof( arg1 ) );
	GetCmdArg(2, arg2, sizeof( arg2 ) );
	
	int kevlar = StringToInt(arg2);
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count; bool tn_is_ml;
	
	if ((target_count = ProcessTargetString(
	arg1,
	client,
	target_list,
	MAXPLAYERS,
	COMMAND_FILTER_CONNECTED|COMMAND_FILTER_NO_BOTS|COMMAND_FILTER_NO_MULTI|COMMAND_FILTER_ALIVE,
	target_name,
	sizeof(target_name),
	tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	for (int i = 0; i < target_count; i++) {
		int target = target_list[i];
		
		if( IsInPVP(target) )
			continue;
		
		g_iUserData[target][i_Kevlar] = kevlar;
	}
	
	return Plugin_Handled;
}
public Action cmd_SetTDM(int client, int args) {
	if( args < 2 || args > 2) {
		ReplyToCommand(client, "Utilisation: rp_tdm \"joueur\" \"nbr\"");		
		return Plugin_Handled;
	}
	
	char arg1[64], arg2[12];
	
	GetCmdArg(1, arg1, sizeof( arg1 ) );
	GetCmdArg(2, arg2, sizeof( arg2 ) );
	
	int nbr = StringToInt(arg2);
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count; bool tn_is_ml;
	
	if ((target_count = ProcessTargetString(
	arg1,
	client,
	target_list,
	MAXPLAYERS,
	COMMAND_FILTER_CONNECTED|COMMAND_FILTER_NO_BOTS|COMMAND_FILTER_NO_MULTI|COMMAND_FILTER_ALIVE,
	target_name,
	sizeof(target_name),
	tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	for (int i = 0; i < target_count; i++) {
		int target = target_list[i];
		
		g_iUserData[target][i_KillJailDuration] = nbr;
	}
	
	return Plugin_Handled;
}
public Action cmd_CleanMap(int client, int args) {
	
	int total = 0;
	for(int i=0;i<MAX_ZONES;i++){
		if(rp_GetZoneBit(i) & BITZONE_EVENT) {
			total += RunMapCleaner(true, true,i);
		}
	}
	
	ReplyToCommand(client, "%T", "Cmd_Clean", client, total);
	return Plugin_Handled;
}
public Action cmd_CleanMapForce(int client, int args) {
	
	int total = RunMapCleaner(true, true, GetCmdArgInt(1) );
	ReplyToCommand(client, "%T", "Cmd_Clean", client, total);
	return Plugin_Handled;
}
public Action cmd_SetClear(int client, int args) {
	if( args < 1 || args > 1) {
		ReplyToCommand(client, "rp_clear \"target\"");
		return Plugin_Handled;
	}
	
	char arg1[64];
	
	GetCmdArg(1, arg1, sizeof( arg1 ) );
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count; bool tn_is_ml;
	
	if ((target_count = ProcessTargetString(
	arg1,
	client,
	target_list,
	MAXPLAYERS,
	COMMAND_FILTER_CONNECTED|COMMAND_FILTER_NO_BOTS|COMMAND_FILTER_NO_MULTI|COMMAND_FILTER_ALIVE,
	target_name,
	sizeof(target_name),
	tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	for (int i = 0; i < target_count; i++) {
		int target = target_list[i];
		
		OnClientDisconnect(target);
		OnClientPostAdminCheck(target);
		
		SetEntPropFloat(client, Prop_Send, "m_flModelScale", 1.0);
		
		GetClientName2(target, target_name, sizeof(target_name), false);
		ReplyToCommand(client, "%T", "Cmd_Clear", client, target_name);
	}
	
	return Plugin_Handled;
}

public Action cmd_ForceUnlock(int client, int args) {
	int ent = GetClientAimTarget(client, false);
	
	if( IsValidDoor(ent) ) {
		
		if( GetEntProp(ent, Prop_Data, "m_bLocked") ) {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Door_Unlock", client);
			EmitSoundToAllAny("doors/latchunlocked1.wav", ent, _, _, _, 0.25);
		}
		
		SetEntProp(ent, Prop_Data, "m_bLocked", 0);
		int door_bdd = g_iDoorDouble[ent - MaxClients ] + MaxClients;
		if( door_bdd > MaxClients )
			SetEntProp(door_bdd, Prop_Data, "m_bLocked", 0);
	}
	
	return Plugin_Handled;
}
public Action cmd_ForceLock(int client, int args) {
	int ent = GetClientAimTarget(client, false);
	
	if( IsValidDoor(ent) ) {
		
		if( !GetEntProp(ent, Prop_Data, "m_bLocked") ) {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Door_Lock", client);
			EmitSoundToAllAny("doors/default_locked.wav", ent, _, _, _, 0.25);
		}
		
		SetEntProp(ent, Prop_Data, "m_bLocked", 1);
		int door_bdd = g_iDoorDouble[ent - MaxClients ] + MaxClients;
		if( door_bdd > MaxClients )
			SetEntProp(door_bdd, Prop_Data, "m_bLocked", 1);
	}
	
	return Plugin_Handled;
}
public Action cmd_ForcePhone(int client, int args) {
	MakePhoneRing();
	
	return Plugin_Handled;
}
public Action cmd_GiveCash(int client, int args) {
	
	g_iUserData[client][i_Money] = 1000000;
	g_iUserData[client][i_Bank] = 1000000;
	
	return Plugin_Handled;
}
public Action cmd_GiveItem(int client, int args) {
	
	if( GetConVarInt(FindConVar("hostport")) == 27015 && !IsAdmin(client) ) {
		ReplyToCommand(client, "%T", "No Access", client);
		return Plugin_Handled;
	}
	
	char arg1[32];
	GetCmdArg(1, arg1, 31);	
	
	for(int i=0; i<MAX_ITEMS; i++) {
		if( strlen(g_szItemList[i][item_type_name]) >= 1 ) {
			if( StrContains(g_szItemList[i][item_type_name], arg1, false) != -1 ) {
				rp_ClientGiveItem(client, i);
			}
		}
	}
	return Plugin_Handled;
}
//
// Quand un joueur choisis une ÃƒÂ©quipe
public Action cmd_Jointeam(int client, int args) {
	char buffer[10];
	GetCmdArg(1,buffer,sizeof(buffer));
	StripQuotes(buffer);
	TrimString(buffer);
	
	// To prevent an exploit, for exampel: jointeam "      3"
	// Player will join team 3 but the StringToInt would return 0, due to buffer being empty
	// So buffer empty, block the command
	if(strlen(buffer) == 0) { 
		return Plugin_Handled; 
	}
	
	int team = StringToInt(buffer);
	
	if( team != CS_TEAM_T ) {
		return Plugin_Handled;
	}
	
	if( GetClientTeam(client) == CS_TEAM_T || GetClientTeam(client) == CS_TEAM_CT ) {
		return Plugin_Handled;
	}
	return Plugin_Continue;
}
public Action Cmd_BlockedSilent(int client, int args) {
	return Plugin_Handled;
}
/* Commande qui change le blackfriday */
public Action CmdBlackFriday(int args) {
	int day = Math_GetRandomInt(2, 7);
	int reduction = 5 * Math_GetRandomInt(1, 3);

	updateBlackFriday(day, reduction);

	char szDate[32];
	FormatDate(g_iBlackFriday[0], szDate, sizeof(szDate));

	//CPrintToChatAll("DEBUG: DAY = %i  REDUCTION = %i", day, reduction);
	//CPrintToChatAll("NEW BLACK FRIDAY DATE (%s) REDUCTION (%i)", szDate, g_iBlackFriday[1]);
	//PrintToServer("NEW BLACK FRIDAY DATE (%s) REDUCTION (%i)", szDate, g_iBlackFriday[1]);
}
