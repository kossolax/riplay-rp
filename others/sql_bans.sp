#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <phun>

public Plugin myinfo = 
{
	name = "Global Ban",
	author = "KoSSoLaX",
	description = "Gestion de ban sur les serveurs ts-X",
	version = "2.1",
	url = "http://www.ts-x.eu"
}

// Handle BDD
Handle g_hBDD;
char g_szError[1024];
char g_szQuery[1024];


public OnPluginStart() {
	
	RegAdminCmd("amx_ban",		Cmd_Ban,	ADMFLAG_BAN,	"Bannir un joueur par pseudo.");
	RegAdminCmd("amx_addban",	Cmd_AddBan,	ADMFLAG_BAN,	"Bannir un joueur par SteamID.");
	RegAdminCmd("amx_unban",	Cmd_Unban,	ADMFLAG_BAN,	"Debannir un joueur.");
	RegAdminCmd("sm_ban",		Cmd_Ban,	ADMFLAG_BAN,	"Bannir un joueur par pseudo.");
	
	RegAdminCmd("srv_ban",		Cmd_Ban,	ADMFLAG_BAN,	"Bannir un joueur par pseudo.");
	RegAdminCmd("srv_addban",	Cmd_AddBan,	ADMFLAG_BAN,	"Bannir un joueur par SteamID.");
	RegAdminCmd("srv_unban",	Cmd_Unban,	ADMFLAG_BAN,	"Debannir un joueur.");
}
public OnMapStart() {
	
	g_hBDD = SQL_Connect("default", true, g_szError, sizeof(g_szError));
	if (g_hBDD == INVALID_HANDLE) {
		SetFailState("Connexion impossible: %s", g_szError);
	}
	
	ServerCommand("sm plugins unload basebans");
}
public OnMapEnd() {
	CloseHandle(g_hBDD);
}
public SQL_QueryCallBack(Handle owner, Handle handle, const char[] error, any data) {
	if( handle == INVALID_HANDLE ) {
		LogError("[SQL] [ERROR] %s", error);
	}
}
public OnClientPostAdminCheck(client) {
	if( !IsFakeClient(client) ) {
		CreateTimer(30.0, CheckBanned, GetClientUserId(client));
	}
}

// ----------------------------------------------------------------------------------------------------------------------------------
//
// Admin commands
//
public Action Cmd_Ban(client, args) {
	if( args < 3 || args > 3) {
		if( client != 0 )
			ReplyToCommand(client, "Utilisation: amx_ban \"joueur\" \"temps\" \"raison\"");
		else
			PrintToServer("Utilisation: amx_ban \"joueur\" \"temps\" \"raison\"");
		
		return Plugin_Handled;
	}
	
	char arg1[64];
	char arg2[12];
	char arg3[256];
	
	GetCmdArg(1, arg1, sizeof( arg1 ) );
	GetCmdArg(2, arg2, sizeof( arg2 ) );
	GetCmdArg(3, arg3, sizeof( arg3 ) );
	
	int time = StringToInt(arg2);
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	
	if ((target_count = ProcessTargetString(
			arg1,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_CONNECTED|COMMAND_FILTER_NO_BOTS|COMMAND_FILTER_NO_MULTI,
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	for (int i = 0; i < target_count; i++)
	{
		char targetSteamID[64];
		GetClientAuthId(target_list[i], AuthId_SteamID64, targetSteamID, sizeof(targetSteamID));
		
		InsertBan(client, target_list[i], targetSteamID, time, arg3);
		
		if( client != 0 )
			ReplyToCommand(client, "%N a ete bannis pour %s.", target_list[i], arg3);
		else
			PrintToServer("%N a ete bannis pour %s.", target_list[i], arg3);
	}
	
	return Plugin_Handled;
}
public Action Cmd_AddBan(client, args) {
	if( args < 3 || args > 3) {
		
		if( client != 0 )
			ReplyToCommand(client, "Utilisation: amx_addban \"SteamID\" \"temps\" \"raison\"");
		else
			PrintToServer("Utilisation: amx_addban \"SteamID\" \"temps\" \"raison\"");
		
		return Plugin_Handled;
	}
	
	char arg1[64];
	char arg2[12];
	char arg3[256];
	
	GetCmdArg(1, arg1, sizeof( arg1 ) );
	GetCmdArg(2, arg2, sizeof( arg2 ) );
	GetCmdArg(3, arg3, sizeof( arg3 ) );
	
	int time = StringToInt(arg2);
	
	InsertBan(client, 0, arg1, time, arg3);
	
	if( client != 0 )
		ReplyToCommand(client, "%s a ete bannis pour %s.", arg1, arg3);
	else
		PrintToServer("%s a ete bannis pour %s.", arg1, arg3);
		
	return Plugin_Handled;
}
public Action Cmd_Unban(client, args) {
	if( args < 2 || args > 2) {
		if( client != 0 )
			ReplyToCommand(client, "Utilisation: amx_unban \"SteamID\" \"raison\"");
		else
			PrintToServer("Utilisation: amx_unban \"SteamID\" \"raison\"");
		
		return Plugin_Handled;
	}
	
	char arg1[64];
	char arg2[256];
	
	GetCmdArg(1, arg1, sizeof( arg1 ) );
	GetCmdArg(2, arg2, sizeof( arg2 ) );

	char clientSteamID[64];
	GetClientAuthId(client, AuthId_SteamID64, clientSteamID, sizeof(clientSteamID));

	char safe_reason[512];
	SQL_EscapeString(g_hBDD, arg2, safe_reason, sizeof(safe_reason));
	
	Format(g_szQuery, sizeof(g_szQuery), 
	"UPDATE `srv_bans` SET `DebanSteamID`='%s', `DebanReason`='%s', `is_unban`='1' WHERE `SteamID`='%s' AND (`Length`='0' OR `EndTime`>UNIX_TIMESTAMP()) AND `is_unban`='0';", 
	clientSteamID, safe_reason, arg1);
	
	SQL_TQuery(g_hBDD, SQL_QueryCallBack, g_szQuery);
	
	if( client != 0 )
		ReplyToCommand(client, "%s a ete debannis.", arg1);
	else 
		PrintToServer("%s a ete debannis.", arg1);
	
	return Plugin_Handled;
}
stock InsertBan(client, target, char targetSteamID[64], int time, const char reason[256]) {
	
	char safe_reason[512];
	SQL_EscapeString(g_hBDD, reason, safe_reason, sizeof(safe_reason));
	
	char clientSteamID[64];
	if( client == 0 ) {
		Format(clientSteamID, 63, "SERVER");
	}
	else if( IsClientInGame(client) ) {
		GetClientAuthId(client, AuthId_SteamID64, clientSteamID, sizeof(clientSteamID));
	}
	else {
		Format(clientSteamID, 63, "SERVER");
	}
	
	char game[32];
	GetGameFolderName(game, sizeof(game));
	
	ReplaceString(targetSteamID, sizeof(targetSteamID), "STEAM_1", "STEAM_0");
	Format(g_szQuery, sizeof(g_szQuery), 
	"INSERT INTO `srv_bans` (`id`, `SteamID`, `StartTime`, `EndTime`, `Length`, `adminSteamID`, `BanReason`, `game`) VALUES (NULL, '%s', UNIX_TIMESTAMP(), (UNIX_TIMESTAMP()+'%i'), '%i', '%s', '%s', '%s'); ", 
	targetSteamID, (time*60), (time*60), clientSteamID, reason, game);
	
	SQL_TQuery(g_hBDD, SQL_QueryCallBack, g_szQuery);
	
	char szSteamID[64];
	for(int i=1; i<MaxClients; i++) {
		if( !IsValidClient(i) )
			continue;
		
		GetClientAuthId(i, AuthId_Engine, szSteamID, sizeof(szSteamID));
		ReplaceString(szSteamID, sizeof(szSteamID), "STEAM_1", "STEAM_0");
		
		if( StrEqual(szSteamID, targetSteamID) ) {
			KickClient(i, "banned");
		}
		
		GetClientAuthId(i, AuthId_Engine, szSteamID, sizeof(szSteamID));
		
		if( StrEqual(szSteamID, targetSteamID) ) {
			KickClient(i, "banned");
		}
		
		GetClientAuthId(i, AuthId_SteamID64, szSteamID, sizeof(szSteamID));
		ReplaceString(szSteamID, sizeof(szSteamID), "STEAM_1", "STEAM_0");
		
		if( StrEqual(szSteamID, targetSteamID) ) {
			KickClient(i, "banned");
		}
	}
}
public Action CheckBanned(Handle timer, any userid) {
	int client = GetClientOfUserId(userid);
	
	if( !IsFakeClient(client) ) {
		
		char SteamID64[64];
		char SteamID1[64];
		char SteamID0[64];
		GetClientAuthId(client, AuthId_SteamID64, SteamID64, sizeof(SteamID64));
		GetClientAuthId(client, AuthId_Engine, SteamID1, sizeof(SteamID0));
		GetClientAuthId(client, AuthId_Engine, SteamID0, sizeof(SteamID0));
		ReplaceString(SteamID0, sizeof(SteamID0), "STEAM_1", "STEAM_0");
		
		char game[32];
		GetGameFolderName(game, sizeof(game));
		
		char IP[64];
		GetClientIP(client, IP, sizeof(IP));
		
		Format(g_szQuery, sizeof(g_szQuery), "SELECT `BanReason` FROM `srv_bans` WHERE `SteamID`='%s' AND (`Length`='0' OR `EndTime`>UNIX_TIMESTAMP()) AND `is_unban`='0' AND (`game`='%s' OR `game`='ALL');", SteamID64, game);
		SQL_TQuery(g_hBDD, CheckBanned_2, g_szQuery, userid);
		
		Format(g_szQuery, sizeof(g_szQuery), "SELECT `BanReason` FROM `srv_bans` WHERE `SteamID`='%s' AND (`Length`='0' OR `EndTime`>UNIX_TIMESTAMP()) AND `is_unban`='0' AND (`game`='%s' OR `game`='ALL');", SteamID1, game);
		SQL_TQuery(g_hBDD, CheckBanned_2, g_szQuery, userid);
		
		Format(g_szQuery, sizeof(g_szQuery), "SELECT `BanReason` FROM `srv_bans` WHERE `SteamID`='%s' AND (`Length`='0' OR `EndTime`>UNIX_TIMESTAMP()) AND `is_unban`='0' AND (`game`='%s' OR `game`='ALL');", SteamID0, game);
		SQL_TQuery(g_hBDD, CheckBanned_2, g_szQuery, userid);
		
		Format(g_szQuery, sizeof(g_szQuery), "SELECT `banReason` FROM `srv_bans` A WHERE ( A.`SteamID`='%s' AND (A.`Length`='0' OR A.`EndTime`>UNIX_TIMESTAMP()) AND A.`is_unban`='0' AND (A.`game`='%s' OR A.`game`='ALL') ) AND NOT EXISTS ( SELECT B.`id` FROM `srv_bans` B WHERE B.`SteamID`='%s' AND (B.`Length`='0' OR B.`EndTime`>UNIX_TIMESTAMP()) AND B.`is_unban`='0' AND (B.`game`='whitelist') ) AND NOT EXISTS ( SELECT C.`id` FROM `srv_bans` C WHERE C.`SteamID`='%s' AND (C.`Length`='0' OR C.`EndTime`>UNIX_TIMESTAMP()) AND C.`is_unban`='0' AND (C.`game`='%s' OR C.`game`='ALL') ) ", IP, game, SteamID64, SteamID64, game);
		SQL_TQuery(g_hBDD, CheckBanned_3, g_szQuery, userid);
	}
}
public CheckBanned_2(Handle owner, Handle handle, const char[] error, any userid) {
	int client = GetClientOfUserId(userid);
	
	if( handle == INVALID_HANDLE ) {
		LogError("[SQL] [ERROR] %s", error);
	}
	if( SQL_FetchRow(handle) ) {
		char sql_row[128], szReason[256];
		SQL_FetchString(handle, 0, sql_row, sizeof(sql_row));
		Format(szReason, 255, "Vous avez ete bannis pour: %s.\n Plus d info sur http://riplay.fr/", sql_row);
		
		KickClient(client, szReason);
	}
}
public CheckBanned_3(Handle owner, Handle handle, const char[] error, any data) {
	if( handle == INVALID_HANDLE ) {
		LogError("[SQL] [ERROR] %s", error);
	}
	if( SQL_FetchRow(handle) ) {
		char SteamID[64];
		
		GetClientAuthId(data, AuthId_SteamID64, SteamID, sizeof(SteamID));
		ReplaceString(SteamID, sizeof(SteamID), "STEAM_1", "STEAM_0");
		
		char sql_row[256];
		SQL_FetchString(handle, 0, sql_row, sizeof(sql_row));
		
		InsertBan(0, data, SteamID, 0, sql_row);
	}
}
