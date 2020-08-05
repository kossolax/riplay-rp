#include <sourcemod>
#include <SteamWorks>

ArrayList g_hQueue;

public Plugin:myinfo =
{
	name = "Force Discord Group",
	author = "Kriax",
	version = "1.0",
	description = "Change le groupe discord",
};

public void OnPluginEnd() {
	delete g_hQueue;
}

public void OnPluginStart() {
	RegServerCmd("sm_force_discord_group", cmdForceDiscordGroup);
	
	g_hQueue = new ArrayList(64);
	CreateTimer(10.0, Timer_Process, _, TIMER_REPEAT);
}

public void OnClientPutInServer(int client) {
	if(IsFakeClient(client)) {
		return;
	}

	AddAuthToQueue(client);
}

public Action cmdForceDiscordGroup(int args) {
	char arg1[32];
	GetCmdArg(1, arg1, sizeof(arg1));
	int client = StringToInt(arg1, sizeof(arg1));

	if(!IsValidClient(client)) {
		return Plugin_Handled;
	}

	AddAuthToQueue(client);

	return Plugin_Handled;
}

public void AddAuthToQueue(int client) {
	char authid[32];
	GetClientAuthId(client, AuthId_SteamID64, authid, sizeof(authid));
	if(g_hQueue.FindString(authid) > -1) return;

	g_hQueue.PushString(authid);
}

public Action Timer_Process(Handle timer) {
	static char authid[64];

	if(g_hQueue.Length > 0) {
		g_hQueue.GetString(0, authid, sizeof(authid));
		g_hQueue.Erase(0);

		SetDiscordGroup(authid);
	}
}

public void SetDiscordGroup(char[] authid) {
	char url[512];
	Format(url, sizeof(url), "http://riplay.fr/discord/synchro.php?password=IAçZ03ns*SAçs_Au1824suXA_&authid=%s", authid);

	Handle HTTPRequest = SteamWorks_CreateHTTPRequest(k_EHTTPMethodGET, url);
	SteamWorks_SetHTTPRequestNetworkActivityTimeout(HTTPRequest, 15);
	SteamWorks_SendHTTPRequest(HTTPRequest);

	delete HTTPRequest;
}

stock bool IsValidClient(int client) {
	if (client <= 0 || client > MaxClients)
		return false;
	
	if (!IsValidEdict(client) || !IsClientConnected(client))
		return false;
	
	return true;
}