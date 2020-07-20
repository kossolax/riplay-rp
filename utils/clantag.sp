#include <sourcemod>
#include <cstrike>

public Plugin:myinfo =
{
	name = "Force clan tag",
	author = "Kriax",
	version = "1.0",
	description = "Change clan tag",
};

public void OnPluginStart() {
	RegServerCmd("sm_force_clantag", cmdForceClangtag);
}

public Action cmdForceClangtag(int args) {
	char arg1[32], arg2[16], tmp[16];
	
	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));
	
	int client = StringToInt(arg1);
	if(client <= 0 || !IsClientConnected(client) || !IsClientInGame(client)) {
		return Plugin_Handled;
	}
	
	CS_GetClientClanTag(client, tmp, sizeof(tmp));
	if( !StrEqual(tmp, arg2) || GetRandomInt(1, 10) == 5 )
		CS_SetClientClanTag(client, arg2);
	return Plugin_Handled;
}