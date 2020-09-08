#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#include <colors_csgo>
#include <smlib>
#include <regex>
#include <csgo_items>
#include <emitsoundany>

#include <websocket>
#include <smjansson>
#include <unixtime_sourcemod>

#include <roleplay>

#pragma newdecls required

public Plugin myinfo = {
	name = "nodejs backend", author = "KoSSoLaX",
	description = "nodejs data backend",
	version = "1.0", url = "https://www.ts-x.eu"
};

WebsocketHandle g_hListenSocket = INVALID_WEBSOCKET_HANDLE;

// ----------------------------------------------------------------------------
public Action Cmd_Reload(int args) {
	char name[64];
	GetPluginFilename(INVALID_HANDLE, name, sizeof(name));
	ServerCommand("sm plugins reload %s", name);
	return Plugin_Continue;
}
public void OnPluginStart() {
	RegServerCmd("rp_quest_reload", Cmd_Reload);
	AddGameLogHook(	GameLogHook );
}
public void OnAllPluginsLoaded() {
	if(g_hListenSocket == INVALID_WEBSOCKET_HANDLE)
		g_hListenSocket = Websocket_Open("0.0.0.0", 27020, OnWebsocketIncoming, OnWebsocketMasterError, OnWebsocketMasterClose);
}
public void OnPluginEnd() {
	if(g_hListenSocket != INVALID_WEBSOCKET_HANDLE)
		Websocket_Close(g_hListenSocket);
}

public Action OnWebsocketIncoming(WebsocketHandle websocket, WebsocketHandle newWebsocket, const char[] remoteIP, int remotePort, char protocols[256]) {
	Websocket_HookChild(newWebsocket, OnWebsocketReceive, OnWebsocketDisconnect, OnChildWebsocketError);
	
	return Plugin_Continue;
}

public void OnWebsocketMasterError(WebsocketHandle websocket, const int errorType, const int errorNum) {
	g_hListenSocket = INVALID_WEBSOCKET_HANDLE;
}

public void OnWebsocketMasterClose(WebsocketHandle websocket) {
	g_hListenSocket = INVALID_WEBSOCKET_HANDLE;
}

public void OnChildWebsocketError(WebsocketHandle websocket, const int errorType, const int errorNum) {
}

public void OnWebsocketReceive(WebsocketHandle websocket, WebsocketSendType iType, const char[] url, const int dataSize) {
	if(iType == SendType_Text) {
		
		if( String_StartsWith(url, "/location") ) {
			char buffer[2048];
			Handle hArray = json_array(), tmp = INVALID_HANDLE;
			float pos[3];
			
			for (int i = 1; i <= MaxClients; i++) {
				if( !IsClientInGame(i) || !IsPlayerAlive(i) )
					continue;
				
				tmp = json_array();
				
				Entity_GetAbsOrigin(i, pos);
				for (int j = 0; j < 3; j++) 
					json_array_append_new(tmp, json_integer( RoundFloat(pos[j])) );
				
				json_array_append_new(hArray, tmp);
			}
	
			json_dump(hArray, buffer, sizeof(buffer), 0, false);

			Format(buffer, sizeof(buffer), "{\"req\":\"%s\",\"data\":%s}", url, buffer);
			
			Websocket_Send(websocket, SendType_Text, buffer);
		}
		else if( String_StartsWith(url, "/connected/") ) {
			char arg[128], steamID[32];
			strcopy(arg, sizeof(arg), url);
			ReplaceString(arg, sizeof(arg), "/connected/", "");
			bool found = false;
			
			for (int i = 1; i <= MaxClients; i++) {
				if( !IsClientInGame(i) )
					continue;
				
				GetClientAuthId(i, AUTH_TYPE, steamID, sizeof(steamID));
				if( StrEqual(steamID, arg) ) {
					found = true;
					break;
				}
			}
			
			Format(arg, sizeof(arg), "{\"req\":\"%s\",\"data\":%s}", url, found ? "1" : "0");

			Websocket_Send(websocket, SendType_Text, arg);
		}
		else if( String_StartsWith(url, "/report/") ) {
			char options[4][256], arg[1024];
			ExplodeString(url, "/", options, sizeof(options), sizeof(options[]));
			
			bool found = false;
			for (int i = 1; i <= MaxClients; i++) {
				if( !IsClientInGame(i) )
					continue;
				
				GetClientAuthId(i, AUTH_TYPE, arg, sizeof(arg));
				if( StrEqual(options[2], arg) ) {
					CPrintToChatAll("" ...MOD_TAG... " Un joueur vient de report %N{default} pour %s.", i, options[3]);
					found = true;
					break;
				}
			}
			
			Format(arg, sizeof(arg), "{\"req\":\"%s\",\"data\":%s}", url, found ? "1" : "0");

			Websocket_Send(websocket, SendType_Text, arg);
			
		}
		else if( String_StartsWith(url, "/msgto/") ) {
			char options[4][256], arg[1024];
			ExplodeString(url, "/", options, sizeof(options), sizeof(options[]));
			
			bool found = false;
			for (int i = 1; i <= MaxClients; i++) {
				if( !IsClientInGame(i) )
					continue;
				
				GetClientAuthId(i, AUTH_TYPE, arg, sizeof(arg));
				if( StrEqual(options[2], arg) ) {
					CPrintToChat(i, "" ...MOD_TAG... " %s.", i, options[3]);
					found = true;
					break;
				}
			}
			
			Format(arg, sizeof(arg), "{\"req\":\"%s\",\"data\":%s}", url, found ? "1" : "0");

			Websocket_Send(websocket, SendType_Text, arg);
		}
		else if( String_StartsWith(url, "/msg/") ) {
			char options[3][256], arg[1024];
			ExplodeString(url, "/", options, sizeof(options), sizeof(options[]));
			
			CPrintToChatAll("" ...MOD_TAG... " %s", options[2]);
			
			Format(arg, sizeof(arg), "{\"req\":\"%s\",\"data\":%s}", url, "1");
			Websocket_Send(websocket, SendType_Text, arg);
		}
		else if( String_StartsWith(url, "/time") ) {       
			int hour, minutes, timestamp;
			rp_GetTime(hour, minutes);
			timestamp = GetTime();

			char buffer[255];
			Handle hObj = json_object();
			json_object_set(hObj, "h", json_integer(hour));
			json_object_set(hObj, "m", json_integer(minutes));
			json_object_set(hObj, "t", json_integer(timestamp));
			json_dump(hObj, buffer, sizeof(buffer), 0, false);
			Format(buffer, sizeof(buffer), "{\"req\":\"%s\",\"data\":%s}", url, buffer);
			
			Websocket_Send(websocket, SendType_Text, buffer);

		}
		else {
			Websocket_Send(websocket, SendType_Text, "error");
		}
	}
}

public void OnWebsocketDisconnect(WebsocketHandle websocket) {
}

public Action GameLogHook(const char[] message) {
	if( StrContains(message, "triggered \"clantag\" (value \"") != -1 )
		return Plugin_Handled;
	return Plugin_Continue;
}