#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <phun>

// Handle:BDD
new Handle:g_hBDD;
new String:g_szError[1024];
new String:g_szQuery[1024];

public Plugin:myinfo =  {
	name = "I know who you are",
	author = "KoSSoLaX",
	description = "Recherche des anciens pseudos dans la BDD.",
	version = "2.0",
	url = "http://www.ts-x.eu"
}

public OnPluginStart() {
	LoadTranslations("common.phrases");
	
	RegAdminCmd("amx_whois",	Command_Whois,	ADMFLAG_KICK,	"Recherche des anciens pseudos dans la BDD.");
	
	OnMapStart();
	for(new i=1; i<=MaxClients; i++) {
		if( !IsValidClient(i) )
			continue;
		UpdateUserInfo(i);
	}
}
public SQL_QueryCallBack(Handle:owner, Handle:handle, const String:error[], any:data) {
	if( handle == INVALID_HANDLE ) {
		LogError("[SQL] [ERROR] %s", error);
	}
}
public OnMapStart() {
	
	g_hBDD = SQL_Connect("default", true, g_szError, sizeof(g_szError));
	if (g_hBDD == INVALID_HANDLE) {
		SetFailState("Connexion impossible: %s", g_szError);
	}
}
public OnMapEnd() {
	
	CloseHandle(g_hBDD);
}
public OnClientPostAdminCheck( Client ) {
	
	UpdateUserInfo( Client );
}
public OnClientDisconnect(Client) {
	
	UpdateUserInfo( Client );
}
public UpdateUserInfo( Client ) {
	
	if( IsFakeClient(Client) ) {
		return;
	}
	
	decl String:SteamID[64];
	decl String:Username[64];
	decl String:Safename[ sizeof(Username)*2+1 ];
	
	GetClientAuthId(Client, AuthId_SteamID64, SteamID, sizeof(SteamID));
	GetClientName(Client,Username,63);
	
	SQL_EscapeString(g_hBDD, Username, Safename, sizeof(Safename));
	
	Format(g_szQuery, sizeof(g_szQuery), "INSERT INTO `srv_nicks` (`steamid`,`uname`,`uname2`) VALUES ('%s', '%s', '%s') ON DUPLICATE KEY UPDATE uname2='%s';", SteamID, Safename, Safename, Safename);
	SQL_TQuery(g_hBDD, SQL_QueryCallBack, g_szQuery);
	
	ReplaceString(SteamID, sizeof(SteamID), "STEAM_1", "STEAM_0");
	
	Format(g_szQuery, sizeof(g_szQuery), "INSERT INTO `srv_nicks` (`steamid`,`uname`,`uname2`) VALUES ('%s', '%s', '%s') ON DUPLICATE KEY UPDATE uname2='%s';", SteamID, Safename, Safename, Safename);
	SQL_TQuery(g_hBDD, SQL_QueryCallBack, g_szQuery);
}
public Action:Command_Whois(client, args) {
	
	if (args < 1) {
		ReplyToCommand(client, "[SM] Usage: amx_whois <#userid|name>");
		return Plugin_Handled;
	}

	decl String:arg[65];
	GetCmdArg(1, arg, sizeof(arg));
	
	decl String:target_name[MAX_TARGET_LENGTH];
	decl target_list[MAXPLAYERS], target_count, bool:tn_is_ml;
	
	if ((target_count = ProcessTargetString(
			arg,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_CONNECTED|COMMAND_FILTER_NO_IMMUNITY|COMMAND_FILTER_NO_BOTS,
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	for (new i = 0; i < target_count; i++)
	{
		AskingWhois(client, target_list[i]);
	}
	
	return Plugin_Handled;
}
public AskingWhois(client, target) {
	
	
	new String:SteamID[65];
	GetClientAuthId(target, AuthId_SteamID64, SteamID, sizeof(SteamID));
	
	Format(g_szQuery, sizeof(g_szQuery), "SELECT uname,uname2 FROM srv_nicks WHERE `steamid` = '%s'", SteamID);

	PrintToConsole(client, "Donnee pour : %N - %s:", target, SteamID);
	SQL_TQuery(g_hBDD, AskingWhois_2, g_szQuery, client);
	
	return;
}
public AskingWhois_2(Handle:owner, Handle:hQuery, const String:error[], any:client) {
	
	if( hQuery == INVALID_HANDLE ) {
		LogError("[SQL] [ERROR] %s", error);
	}
	if( SQL_FetchRow(hQuery) ) {
		new String:Oldname[255];
		new String:Newname[255];
		
		SQL_FetchString(hQuery, 0, Oldname, 255);
		SQL_FetchString(hQuery, 1, Newname, 255);
		
		
		PrintToConsole(client, "Plus ancien pseudo : %s", Oldname);
		PrintToConsole(client, "Recent pseudo      : %s", Newname);
	}
}
