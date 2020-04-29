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
	char arg1[8];
	GetCmdArg(1, arg1, sizeof(arg1));
	int client = StringToInt(arg1, sizeof(arg1));

	if(client <= 0 || !IsClientConnected(client) || !IsClientInGame(client)) {
		return Plugin_Handled;
	}

	char arg2[32]
	GetCmdArg(2, arg2, sizeof(arg2));

	char szClanTag[32];
	CS_GetClientClanTag(client, szClanTag, sizeof(szClanTag));
	
	if(!StrEqual(arg2, szClanTag)) {
		CS_SetClientClanTag(client, arg2);
	}
}