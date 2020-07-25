#pragma semicolon 1

#include <sourcemod>
#include <SteamWorks>

#pragma newdecls required

public Plugin myinfo = {
	name = "nodejs backend", author = "KoSSoLaX",
	description = "nodejs data backend",
	version = "1.0", url = "https://www.ts-x.eu"
};


public void OnPluginStart() {
	RegConsoleCmd("say", 				Command_Say);
}

public Action Command_Say(int client, int args) {
	static char tmp[256], tmp2[256];

	GetCmdArgString(tmp, sizeof(tmp));
	StripQuotes(tmp);
	ReplaceString(tmp, sizeof(tmp), "@here", "");
	ReplaceString(tmp, sizeof(tmp), "@everyone", "");
	TrimString(tmp);
	
	
	if( tmp[0] != '/' && tmp[0] != '!' && tmp[0] != 0 ) {
		
		Format(tmp2, sizeof(tmp2), "%N: %s", client, tmp);
		Handle HTTPRequest = SteamWorks_CreateHTTPRequest(k_EHTTPMethodGET, "http://5.196.39.48:54321");
		SteamWorks_SetHTTPRequestGetOrPostParameter(HTTPRequest, "msg", tmp2);
		SteamWorks_SetHTTPRequestNetworkActivityTimeout(HTTPRequest, 1);
		SteamWorks_SendHTTPRequest(HTTPRequest);
		delete HTTPRequest;
	}
	return Plugin_Continue;
}
