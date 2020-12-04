#pragma semicolon 1

#include <sourcemod>
#include <regex>
#include <sdktools>
#include <sdkhooks>


#include <cstrike>
#include <colors_csgo>
#include <roleplay>
#include <rp_tools>


#include <phun>
#include <smlib>
#include <basecomm>

#pragma newdecls required

public Plugin myinfo = 
{
	name = "Anti-Insultes", 
	author = "KoSSoLaX`", 
	description = "Ban les joueurs insultant", 
	version = "1.0", 
	url = "http://www.ts-x.eu/"
}


int g_iScore[65];
int g_iMaxInsultes = 5;

Handle g_hRegex;

char g_szInsultes[][32] =  {
	"de pute", "da pute", "la pute", "fdp", "f d p" , "fd p" , "f dp", "efdépé",
	"encul" , "ancul" , "enkul", "ankul", "fuck you", "sodomite", 
	"connar", "conar", "konnar", "batar", "sale con", "petit con", "pti con", "gros con",
	"salope", "salau", "catin", "catain",
	"a pas de vie", "signer ton arret de mort",
	"bounioul", "bougnoul", "bougnool", "salle noir", "sale noir",
	"enfoir", "tarba", "batar", "ducon", "trou du cul", "trou du q", "du gland",
	"conas", "connas", "fils de ", "fille de ", "neny pory",
	
	"niquez vos", "niquer vos", "nikez vos", "niker vos",
	"nique ta ",  "nike ta", 	"niquer ta", "niquez ta", "nikez ta ", "niker ta ", "nikez ta ",
	"nique ton ", "nike ton ", "niquer ton ", "niquez ton", "nikez ton ", "niker ton ", "nikez ton ",
	"nique tes ", "nike tes ", "niquer tes ", "niquez tes", "nikez tes ", "niker tes ", "nikez tes ",
	"de gamin", "gamain", "gros gamin", "un gamin", " l'enfant", "enfant de", "petit enfant", "comme un enfant", "t'es un enfant", "t un enfant",
	
	"gros pd", "petit pd", "sale pd", "salle pd",
	"ntm", "n t m", "nique bien ta", "nique bien ton",
	"putain d", " pute ", "putin d",
	"re la chienne", "mange ma queue",
	"gros merdeu", "gros mongol", "gros bouf", "gros batar", "grosse pédal", "gros gitan", "gros pd",
	" lopette", "puceau",
	" en pls",
	
	"ftg", "ferme ta gueule", "ta gueule", "ta gueulle",
	"salle juif", "sale juif", "salle feuj", "sale feuj", "nazi",
	"jbaise t", "j'baise t", "je baise t",
	"suce ma bite", "smb", "suce des bite", "suces des bite",
	"serv de merde", "serveur de merde", 
	"EZfrags", "aimware", "unityhacks", "UNIVERSALCHEATS"
};
public void OnPluginStart() {
	g_hRegex = CompileRegex("(?:[0-9]+){1,3}\\.(?:[0-9]+){1,3}\\.(?:[0-9]+){1,3}\\.(?:[0-9]+){1,3}");

#if defined TF2
	RegConsoleCmd("say", 			Command_Say);
	RegConsoleCmd("say_team", 		Command_Say);
	ServerCommand("sm plugins reload colorednames");
#endif

	for (int i = 1; i <= MaxClients; i++)
		if( IsValidClient(i) )
			OnClientPostAdminCheck(i);
}
public void OnClientPostAdminCheck(int client) {
	g_iScore[client] = 0;
#if defined TF2
#else
	rp_HookEvent(client, RP_PrePlayerTalk, fwdTalkCrayon);
#endif
}
#if defined TF2
public void OnAllPluginsLoaded() {
	ServerCommand("sm plugins reload colorednames");
}
public Action Command_Say(int client, int args) {
	char szSayText[256];
	GetCmdArgString(szSayText, sizeof(szSayText));
	String_Trim(szSayText, szSayText, sizeof(szSayText), " \t\r\n\"");
	
	Action a = fwdTalkCrayon(client, szSayText, sizeof(szSayText), false);
	
	if( a == Plugin_Changed ) {
		CPrintToChatAllEx(client, "{teamcolor}%N{default}: %s", client, szSayText);
		return Plugin_Stop;
	}
	return a;
}
#endif
public Action fwdTalkCrayon(int client, char[] szSayText, int length, bool local) {
	int size = sizeof(g_szInsultes);
	int a, b;
	bool changed = false;
	
	ReplaceString(szSayText, length, "en plsu", "en plus");
	
	
	char[] oldText = new char[length];
	strcopy(oldText, length, szSayText);
	
	for (int i = 0; i < length; i++) {
		a = IsCharMB(oldText[i]);
		if( a != 0 )
			i += (a - 1);
		else {
			if( oldText[i] >= 33 && szSayText[i] <= 64 )
				oldText[i] = ' ';
			if( oldText[i] >= 91 && szSayText[i] <= 96 )
				oldText[i] = ' ';
			if( oldText[i] >= 123 )
				oldText[i] = ' ';
		}
		
	}
	while( (a = ReplaceString(oldText, length, "  ", " "))&& a > 0) { b += a; }
	
	for (int i = 0; i < size; i++) {
		if (strlen(g_szInsultes[i]) > 1) {
			int pos = StrContains(oldText, g_szInsultes[i], false);
			if ( pos != -1) {
				
				LogToGame("[ANTI-INSULTES] [%s] %L: %s", g_szInsultes[i], client, szSayText);
				ServerCommand("sm_irc [ANTI-INSULTES] [%s] %N: %s", g_szInsultes[i], client, szSayText);
				
				if( IncrementInsulte(client, 1) ) {
					return Plugin_Stop;
				}
				else {
					if( !changed )
						CPrintToChat(client, "" ...MOD_TAG... " {red}Les insultes ne sont pas tolérées{default} sur ce serveur, continuez et vous serez sanctionné.");
					
					for (int j = 0; j < strlen(g_szInsultes[i])+b; j++)
						if (pos + j < length)
							szSayText[pos + j] = '*';
					
					szSayText[length] = 0;
					changed = true;
				}
			}
		}
	}
	
	
	
	int amount = MatchRegex(g_hRegex, szSayText);
	if (amount > 0) {
		
		char buffer[64];
		GetRegexSubString(g_hRegex, 0, buffer, sizeof(buffer));
		
		if (StrContains(buffer, "5.196.39.") == -1) {
			LogToGame("[ANTI-INSULTES] [%s] %N: %s", buffer, client, szSayText);
			IncrementInsulte(client, 5);
			KickClient(client);
			return Plugin_Stop;
		}
	}
	
	if( StrContains(szSayText, "goudercourt", false) >= 0 || StrContains(szSayText, "vayssade", false) >= 0 ) {
		IncrementInsulte(client, 5);
		ServerCommand("sm_ban \"#%d\" 0 Cancer", GetClientUserId(client));
	}
	if( StrContains(szSayText, "gouder court", false) >= 0 || StrContains(szSayText, "sousse", false) >= 0 ) {
		IncrementInsulte(client, 5);
		ServerCommand("sm_ban \"#%d\" 0 Cancer", GetClientUserId(client));
	}
	if( StrContains(szSayText, "aristide", false) >= 0 || StrContains(szSayText, "bures sur yvette", false) >= 0 ) {
		IncrementInsulte(client, 5);
		ServerCommand("sm_ban \"#%d\" 0 Cancer", GetClientUserId(client));
	}
	if( StrContains(szSayText, "boissière", false) >= 0 || StrContains(szSayText, "boissiere", false) >= 0 ) {
		IncrementInsulte(client, 5);
		ServerCommand("sm_ban \"#%d\" 0 Cancer", GetClientUserId(client));
	}

#if defined TF2
#else
	if( StrContains(szSayText, "freekill") >= 0 ) {
		CPrintToChat(client, "" ...MOD_TAG... " En cas de freekill, nous vous conseillions d'entrer la commande {green}/passif{default}.");
	}
#endif

	if( changed )
		return Plugin_Changed;
	return Plugin_Continue;
}

Handle g_hTimer[65];
bool IncrementInsulte(int client, int score) {
	g_iScore[client] += score;
	
	if (g_iScore[client] > g_iMaxInsultes)
		g_iScore[client] = g_iMaxInsultes;
	
	float time = Pow(2.0, float(g_iScore[client] - 1)) * 2;
#if defined TF2
#else
	rp_ClientOverlays(client, o_Action_Insultes, 10.0);
#endif
	if( score >= 3 ) {
		
		CPrintToChat(client, "" ...MOD_TAG... " {red}Les insultes ne sont pas tolérées{default} sur ce serveur, vous avez été interdit d'utiliser le chat pour %d minute(s).", RoundFloat(time));
		
		BaseComm_SetClientGag(client, true);
		if( g_hTimer[client] == INVALID_HANDLE ) {
			CloseHandle(g_hTimer[client]);
			g_hTimer[client] = INVALID_HANDLE;
		}
		g_hTimer[client] = CreateTimer(time * 60.0, Ungag, client);
		return true;
	}
	return false;
}
public Action Ungag(Handle timer, any client) {
	CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous pouvez à nouveau utiliser le chat.");
	BaseComm_SetClientGag(client, false);
	g_hTimer[client] = INVALID_HANDLE;
}
