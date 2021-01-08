#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>
#include <smlib>
#include <colors_csgo>
#include <basecomm>
#include <SteamWorks>

#pragma newdecls required
#include <roleplay.inc>	// https://www.ts-x.eu
#include <audio>

#pragma newdecls required

public Plugin myinfo = {
	name = "Les test de kosso",
	author = "KoSSoLaX`",
	description = "",
	version = "1.0",
	url = "zaretti.be"
};


AudioPlayer api;

public void OnPluginStart() {
	RegConsoleCmd("sm_audio2", 		Cmd_Audio);
	RegConsoleCmd("player_ping", block);
	RegConsoleCmd("chatwheel_ping", block);
	HookUserMessage(GetUserMessageId("RadioText"), BlockRadio, true);
	
	AddNormalSoundHook(sound_hook);
}

public Action Cmd_Audio(int client, int args) {
	
	api = new AudioPlayer();
	char url[256];
	GetCmdArgString(url, sizeof(url));
	ReplyToCommand(client, url);
	TrimString(url);
	
	if( strlen(url) < 10 )
		Format(url, sizeof(url), "https://www.youtube.com/watch?v=NnhLfHNcB-o");
	
	int bot = CreateFakeClient("bot");
	CS_SwitchTeam(bot, GetClientTeam(client));
	CS_RespawnPlayer(bot);
	
	float pos[3];
	Entity_GetAbsOrigin(client, pos);
	TeleportEntity(bot, pos, NULL_VECTOR, NULL_VECTOR);
	
	//api.AddArg("-filter:a 'volume=0.2'");
	//api.SetFrom(5.0);
	api.PlayAsClient(bot, url);
	
	return Plugin_Handled;
}

public Action block(int client, int args) {
	return Plugin_Handled;
}
public Action BlockRadio(UserMsg msg_id, Protobuf bf, const int[] players, int playersNum, bool reliable, bool init)
{
	char buffer[64];
	PbReadString(bf, "params", buffer, sizeof(buffer), 0);

	if (StrContains(buffer, "#Chatwheel_"))
	{
		return Plugin_Handled;
	}
	return Plugin_Continue;
}
public Action sound_hook(int clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags) {
	if( StrContains(sample, "v8/vehicle") > 0 ) {
		return Plugin_Handled;
	}
/*	
	if (StrContains(sample, "knife_slash") >= 0) {
		volume = 0.1;
		return Plugin_Changed;
	}
*/	
	return Plugin_Continue;
}