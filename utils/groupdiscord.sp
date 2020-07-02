#include <sourcemod>
#include <SteamWorks>

public Plugin:myinfo =
{
	name = "Force Discord Group",
	author = "Kriax",
	version = "1.0",
	description = "Change le groupe discord",
};

public void OnPluginStart() {
	RegServerCmd("sm_force_discord_group", cmdForceDiscordGroup);
}

public Action cmdForceDiscordGroup(int args) {
	char arg1[32];
	GetCmdArg(1, arg1, sizeof(arg1));
	int client = StringToInt(arg1, sizeof(arg1));

	if(client <= 0 || !IsClientConnected(client) || !IsClientInGame(client)) {
		return Plugin_Handled;
	}

	char authid[32];
	GetClientAuthId(client, AuthId_SteamID64, authid, sizeof(authid));

	char url[512];
	Format(url, sizeof(url), "http://riplay.fr/discord/synchro.php?password=IAçZ03ns*SAçs_Au1824suXA_&authid=%s", authid);

	Handle HTTPRequest = SteamWorks_CreateHTTPRequest(k_EHTTPMethodGET, url);
	SteamWorks_SetHTTPRequestNetworkActivityTimeout(HTTPRequest, 15);
	SteamWorks_SendHTTPRequest(HTTPRequest);

	delete HTTPRequest;

	return Plugin_Handled;
}