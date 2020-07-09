#pragma semicolon 1

#include <sourcemod>
#include <smlib>
#include <webcon>
#include <smjansson>
#include <colors_csgo>
#include <roleplay>

#pragma newdecls required

public Plugin myinfo = {
	name = "nodejs backend", author = "KoSSoLaX",
	description = "nodejs data backend",
	version = "1.0", url = "https://www.ts-x.eu"
};

WebResponse defaultResponse;
public void OnPluginStart() {
	AddGameLogHook(	GameLogHook );
	
	if (!Web_RegisterRequestHandler("njs", OnWebRequest, "nodejs", "nodejs backend")) {
		SetFailState("Failed to register request handler.");
	}	
	defaultResponse = new WebStringResponse("<!DOCTYPE html>\n<html><body><h1>404 Not Found</h1></body></html>");

	RegConsoleCmd("sm_testtime", cmd_time);
}

public Action cmd_time(int client, int args) {
	int hour, minutes, timestamp;
	rp_GetTime(hour, minutes);
  	timestamp = GetTime();

  	PrintToServer("%i %i %i", hour, minutes, timestamp);
}

public Action GameLogHook(const char[] message) {
	if( StrContains(message, "triggered \"clantag\" (value \"") != -1 )
		return Plugin_Handled;
	return Plugin_Continue;
}
public bool OnWebRequest(WebConnection connection, const char[] method, const char[] url) {
	
	if( StrEqual(url, "/location") ) {
		char buffer[65 * 3 * 8];
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

		WebResponse response = new WebStringResponse(buffer);
		bool success = connection.QueueResponse(WebStatus_OK, response);
		delete response;
		delete hArray;
		return success;
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
		WebResponse response;
		
		if( found )
			response = new WebStringResponse("1");
		else
			response = new WebStringResponse("0");
		
		bool success = connection.QueueResponse(WebStatus_OK, response);
		delete response;
		return success;
	}
	else if( String_StartsWith(url, "/report/") ) {
		char options[4][256], arg[32];
		ExplodeString(url, "/", options, sizeof(options), sizeof(options[]));
		
		bool found = false;
		for (int i = 1; i <= MaxClients; i++) {
			if( !IsClientInGame(i) )
				continue;
			
			GetClientAuthId(i, AUTH_TYPE, arg, sizeof(arg));
			if( StrEqual(options[2], arg) ) {
				CPrintToChatAll("{lightblue}[TSX-RP]{default} Un joueur vient de report %N pour %s.", i, options[3]);
				found = true;
				break;
			}
		}
		WebResponse response;
		
		if( found )
			response = new WebStringResponse("1");
		else
			response = new WebStringResponse("0");
		
		bool success = connection.QueueResponse(WebStatus_OK, response);
		delete response;
		return success;
	}
	else if( String_StartsWith(url, "/msgto/") ) {
		char options[4][256], arg[32];
		ExplodeString(url, "/", options, sizeof(options), sizeof(options[]));
		
		bool found = false;
		for (int i = 1; i <= MaxClients; i++) {
			if( !IsClientInGame(i) )
				continue;
			
			GetClientAuthId(i, AUTH_TYPE, arg, sizeof(arg));
			if( StrEqual(options[2], arg) ) {
				CPrintToChat(i, "{lightblue}[TSX-RP]{default} %s.", i, options[3]);
				found = true;
				break;
			}
		}
		WebResponse response;
		
		if( found )
			response = new WebStringResponse("1");
		else
			response = new WebStringResponse("0");
		
		bool success = connection.QueueResponse(WebStatus_OK, response);
		delete response;
		return success;
	}
	else if( String_StartsWith(url, "/msg/") ) {
		char options[3][256];
		ExplodeString(url, "/", options, sizeof(options), sizeof(options[]));
		
		CPrintToChatAll("{lightblue}[TSX-RP]{default} %s.", options[2]);
		
		WebResponse response = new WebStringResponse("1");
		bool success = connection.QueueResponse(WebStatus_OK, response);
		delete response;
		return success;
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
        
        WebResponse response = new WebStringResponse(buffer);        
        bool success = connection.QueueResponse(WebStatus_OK, response);
        delete response;
        delete hObj;
        return success;
    }
	return connection.QueueResponse(WebStatus_NotFound, defaultResponse);
}