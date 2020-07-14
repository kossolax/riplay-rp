#if defined _advmotd_enabled
#endinput
#endif
#define _advmotd_enabled

#include <SteamWorks>

#define URL_PATH "https://riplay.fr/api/redirect/%s"


stock void RP_ShowMOTD(int client, char[] url) {	
	char tmp[128], szSteamID[32];
	GetClientAuthId(client, AuthId_SteamID64, szSteamID, sizeof(szSteamID));
	Format(tmp, sizeof(tmp), URL_PATH, szSteamID);
	
	Handle req = SteamWorks_CreateHTTPRequest(k_EHTTPMethodPOST, tmp);
	SteamWorks_SetHTTPCallbacks(req, MOTD_OnSteamWorksHTTPComplete);
	SteamWorks_SetHTTPRequestContextValue(req, client);
	SteamWorks_SetHTTPRequestGetOrPostParameter(req, "url", url);
	SteamWorks_SendHTTPRequest(req);
}

public int MOTD_OnSteamWorksHTTPComplete(Handle HTTPRequest, bool fail, bool success, EHTTPStatusCode statusCode, any client) {
	if (success && statusCode == k_EHTTPStatusCode200OK )  { 
		char tmp[128], szSteamID[32];
		GetClientAuthId(client, AuthId_SteamID64, szSteamID, sizeof(szSteamID));
		Format(tmp, sizeof(tmp), URL_PATH, szSteamID);
		
		CPrintToChat(client, "{lightblue}[TSX-RP]{default} Pour afficher cette page, appuyez sur [TAB] puis sur le bouton [SITE-WEB] en bas à gauche du tableau des scores.");
	}
	
	delete HTTPRequest;
}
