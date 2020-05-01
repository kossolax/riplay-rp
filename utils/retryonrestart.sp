#include <sourcemod>

new String:Logfile[PLATFORM_MAX_PATH];

public Plugin:myinfo =
{
	name = "Retry On Restart",
	author = "Franc1sco steam: franug",
	version = "1.0",
	description = "Force retry on restart",
	url = "www.uea-clan.com"
};

public OnPluginStart()
{
	CreateConVar("sm_retryonrestart", "v2.0", _, FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	
	RegServerCmd("quit", OnDown);
	RegServerCmd("_restart", OnDown);
	BuildPath(Path_SM, Logfile, sizeof(Logfile), "logs/restarts.log");
	
	RegAdminCmd("srv_restart", cmdRestart, ADMFLAG_ROOT);
}
public Action:cmdRestart(client, args) {
	for(new i = 1; i <= MaxClients; i++)
		if (IsClientInGame(i) && !IsFakeClient(i))
			ClientCommand(i, "retry");
	
	CreateTimer(0.0001, srvRestart);
}
public Action:srvRestart(Handle:timer, any:zomg) {
	ServerCommand("_restart");
}

public Action:OnDown(args)
{
	for(new i = 1; i <= MaxClients; i++)
		if (IsClientInGame(i) && !IsFakeClient(i))
			ClientCommand(i, "retry"); // force retry
		
	LogToFile(Logfile,"Server restarted");
}

