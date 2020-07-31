#pragma semicolon 1

#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>
#include <smlib>
#include <colors_csgo>
#include <basecomm>
#include <SteamWorks>

#pragma newdecls required
#include <roleplay.inc>	// https://www.ts-x.eu

#pragma newdecls required

#define SERVICE_URL	"http://check.getipintel.net/check.php?ip=%s&contact=kossolax@gmail.com&flags=f"
#define	BAN_TIME	1
#define	QUEUE_SPEED	10.0

public Plugin myinfo = {
	name = "VPN Blocker",
	author = "KoSSoLaX`",
	description = "Help to remove useless players",
	version = "1.0",
	url = "zaretti.be"
};

StringMap g_hScoring;
StringMap g_hWhitelist;

ArrayList g_hQueue;
bool g_bProcessing;

Handle g_hCvarScore;

public Action Cmd_Reload(int args) {
	char name[64];
	GetPluginFilename(INVALID_HANDLE, name, sizeof(name));
	ServerCommand("sm plugins reload %s", name);
	return Plugin_Continue;
}
public void OnPluginEnd() {
	delete g_hQueue;
}
public void OnPluginStart() {
	
	g_hScoring = new StringMap();
	g_hWhitelist = new StringMap();
	g_hQueue = new ArrayList(16, 0);
	g_bProcessing = false;
	
	CreateTimer(QUEUE_SPEED, Timer_TICK, _, TIMER_REPEAT);
	
	g_hCvarScore = CreateConVar("sv_autoban_vpn_score", "0.991");
	
	RegAdminCmd("sm_vpn_reload", Cmd_ReloadWhiteList, ADMFLAG_BAN);
	RegServerCmd("rp_quest_reload", Cmd_Reload);
	SQL_TQuery(rp_GetDatabase(), SQL_WhiteList, "SELECT `steamid` FROM `srv_vpn`");
	
	for (int i = 1; i < MaxClients; i++)
		if( IsClientInGame(i) )
			OnClientPostAdminCheck(i);
}
public Action Cmd_ReloadWhiteList(int client, int args) {
	SQL_TQuery(rp_GetDatabase(), SQL_WhiteList, "SELECT `steamid` FROM `srv_vpn`");
	return Plugin_Handled;
}
public void SQL_WhiteList(Handle owner, Handle row, const char[] error, any none) {
	char tmp[64];
	
	g_hWhitelist.Clear();
	while( SQL_FetchRow(row) ) {
		SQL_FetchString(row, 0, tmp, sizeof(tmp));
		g_hWhitelist.SetValue(tmp, 1);	
	}
}
public void OnClientPostAdminCheck(int client) {
	char tmp[16], steamid[64];
	float score;
	int thrust;
	
	GetClientAuthId(client, AUTH_TYPE, steamid, sizeof(steamid));
	GetClientIP(client, tmp, sizeof(tmp));
	
	if( g_hScoring.GetValue(tmp, score) && !g_hWhitelist.GetValue(steamid, thrust) ) {
		if( score >= GetConVarFloat(g_hCvarScore) ) {
			CreateTimer(30.0, Ban_Task, GetClientUserId(client));
		}
	}
	else {
		g_hQueue.PushString(tmp);
	}	
}
public Action Ban_Task(Handle timer, any userid) {
	int client = GetClientOfUserId(userid);
	if( IsValidClient(client) )
		BanClient(client, BAN_TIME, BANFLAG_IP, "VPN", "VPN are not allowed on this server");
}
public Action Timer_TICK(Handle timer, any none) {
	static char tmp[16], URL[128];
	
	if( !g_bProcessing && g_hQueue.Length > 0 ) {
		g_hQueue.GetString(0, tmp, sizeof(tmp));
		g_hQueue.Erase(0);
		
		float score;
		if( !g_hScoring.GetValue(tmp, score) ) {
			Format(URL, sizeof(URL), SERVICE_URL, tmp);
			
			Handle dp = CreateDataPack();
			WritePackString(dp, tmp);
			
			g_bProcessing = true;		
			Handle req = SteamWorks_CreateHTTPRequest(k_EHTTPMethodGET, URL);
			SteamWorks_SetHTTPCallbacks(req, OnSteamWorksHTTPComplete);
			SteamWorks_SetHTTPRequestContextValue(req, dp);
			SteamWorks_SendHTTPRequest(req);
		}
	}
}

public int OnSteamWorksHTTPComplete(Handle req, bool fail, bool success, EHTTPStatusCode statusCode, any dp) {
	
	if( success && statusCode == k_EHTTPStatusCode200OK ) {
		SteamWorks_GetHTTPResponseBodyCallback(req, HttpRequestData, dp);
	}
	else {
		LogToGame("[VPN Blocker] Something went wrong with.");
	}
	
	CloseHandle(req);
	g_bProcessing = false;
}

public int HttpRequestData(const char[] body, any dp) {
	char IP[16], tmp[16], steamid[64];
	
	ResetPack(dp);
	ReadPackString(dp, IP, sizeof(IP));
	CloseHandle(dp);
		
	float score = StringToFloat(body);
	
	if( score <= -1.0 ) {
		LogToGame("[VPN Blocker] Something went wrong with: %s --> %f", IP, score);
	}
	else {
		LogToGame("[VPN Blocker] IP Result: %s = %f.", IP, score);
		g_hScoring.SetValue(IP, score);	
		
		if( score >= GetConVarFloat(g_hCvarScore) ) {
			for (int i = 1; i <= MaxClients; i++) {
				if( !IsClientInGame(i) )
					continue;
				
				GetClientIP(i, tmp, sizeof(tmp));
				int thrust;
				GetClientAuthId(i, AUTH_TYPE, steamid, sizeof(steamid));
				
				if( StrEqual(IP, tmp) && !g_hWhitelist.GetValue(steamid, thrust) ) {
					CreateTimer(30.0, Ban_Task, GetClientUserId(i));
				}
			}
		}
	}
}
