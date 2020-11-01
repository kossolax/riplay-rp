/*
 * Cette oeuvre, création, site ou texte est sous licence Creative Commons Attribution
 * - Pas d’Utilisation Commerciale
 * - Partage dans les Mêmes Conditions 4.0 International. 
 * Pour accéder à une copie de cette licence, merci de vous rendre à l'adresse suivante
 * http://creativecommons.org/licenses/by-nc-sa/4.0/ .
 *
 * Merci de respecter le travail fourni par le ou les auteurs 
 * https://www.ts-x.eu/ - kossolax@ts-x.eu
 */
#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>
#include <smlib>		// https://github.com/bcserv/smlib
#include <colors_csgo>	// https://forums.alliedmods.net/showthread.php?p=2205447#post2205447

#include <roleplay.inc>	// https://www.ts-x.eu
#include <advanced_motd>// https://forums.alliedmods.net/showthread.php?t=232476

public Plugin myinfo = {
	
	name = "Jobs: Tribunal", author = "KoSSoLaX",
	description = "RolePlay - Jobs: Tribunal",
	version = __LAST_REV__, url = "https://www.ts-x.eu"
};

enum TribunalData {
	td_Plaignant,
	td_Suspect,
	td_Time,
	td_Owner,
	td_ArticlesCount,
	td_AvocatPlaignant,
	td_AvocatSuspect,
	td_TimeMercenaire,
	td_EnquetePlaignant,
	td_EnqueteSuspect,
	td_DoneDedommagement,
	td_Dedommagement,
	td_Dedommagement2,
	td_SuspectArrive,
	
	td_Max
};
int g_cBeam;

// Numéro, Résumé, Heures, Amende, Dédo, Détails
char g_szArticles[][][512] = {
	{"221-1-a-12",	"Act_KillAtt",		"12",	"500",		"1000",	"Act_KillAttDesc" },
	{"221-1-a-24",	"Act_Kill",			"24",	"1250",		"2500",	"Act_KillDesc" },
	{"221-1-a-48",	"Act_KillAggr",		"48",	"2500",		"5000",	"Act_KillAggrDesc" },

	{"221-1-b",		"Act_KillCT",		"12",	"2000",		"1500",	"Act_KillCTDesc" },
	{"221-1-d",		"Act_Aggr",			"6",	"250",		"100",	"Act_AggrDesc" },

	{"221-2",		"Act_Vol",			"6",	"450",		"-1",	"Act_VolDesc" },
	{"221-3",		"Act_MqConvoc",		"18",	"4000",		"0",	"Act_MqConvocDesc" },
	{"221-4",		"Act_Fake",			"6",	"1500",		"300",	"Act_FakeDesc" },
	{"221-5-a",		"Act_NuisaSono", 	"6",	"1500", 	"0",	"Act_NuisaSonoDesc" },
	{"221-5-b",		"Act_Insult", 		"6",	"1000", 	"1250",	"Act_InsultDesc" },
	{"221-5-c",		"Act_HarcMen", 		"6",	"800",		"300",	"Act_HarcMenDesc" },
	{"221-7",		"Act_Obstru",		"6",	"650",		"0",	"Act_ObstruDesc" },
	{"221-8",		"Act_BavuPol",		"24",	"3000",		"2000",	"Act_BavuPolDesc" },
	{"221-10-b",	"Act_AssocMalf",	"6",	"500",		"0",	"Act_AssocMalfDesc" },
	{"221-12",		"Act_ProfitVulne",	"18",	"3000",		"1500",	"Act_ProfitVulneDesc" },
	{"221-13-a",	"Act_Destruct",		"6",	"1500",		"1000",	"Act_DestructDesc" },
	{"221-13-b",	"Act_ViePrv",		"6",	"950",		"500",	"Act_ViePrvDesc" },
	{"221-13-c",	"Act_IntrusiPrv",	"6",	"800",		"500",	"Act_IntrusiPrvDesc" },
	{"221-13-d",	"Act_IntrusiFede",	"18",	"5000",		"500",	"Act_IntrusiFedeDesc" },
	{"221-14-a",	"Act_UseDrug",		"6",	"1000",		"250",	"Act_UseDrugDesc" },
	{"221-14-b",	"Act_IllegTrafc",	"6",	"1000",		"250",	"Act_IllegTrafcDesc" },
	{"221-15-a",	"Act_TCorrup",		"24",	"10000",	"0",	"Act_TCorrupDesc" },
	{"221-15-b",	"Act_Escroq",		"18",	"5000",		"-1",	"Act_EscroqDesc" },
	{"221-16",		"Act_Seq",			"6",	"800",		"500",	"Act_SeqDesc" },
	{"221-17",		"Act_Pute",			"6",	"450",		"0",	"Act_PuteDesc" }
};
char g_szAcquittement[6][64] = { "Justice_Acquittement_NonCoupable", "Justice_Acquittement_Conciliation", "Justice_Acquittement_Impossible", "Justice_Acquittement_DejaVu", "Justice_Acquittement_Cancel", "Justice_Acquittement_Newbie"};
char g_szCondamnation[6][64] = { "Justice_Condamnation_VerySmall", "Justice_Condamnation_Small", "Justice_Condamnation_Average", "Justice_Condamnation_Hard", "Justice_Condamnation_VeryHard", "Justice_Condamnation_Disconnect"};
float g_flCondamnation[6] = {0.2, 0.4, 0.6, 0.8, 1.0, 1.5};
float g_flCoords[3][2][3];

int g_iArticles[3][ sizeof(g_szArticles) ];
int g_iTribunalData[3][view_as<int>(td_Max)];
char g_szJugementDATA[65][3][32];
bool g_bClientDisconnected[65];

int g_iXpAudience[] = { 10, 20, 30, 40, 50, 60, 80, 100, 120, 150, 180, 220, 250, 300 };

#define isTribunalDisponible(%1) (g_iTribunalData[%1][td_Owner]<=0?true:false)
#define GetTribunalZone(%1) (%1==1?TRIBUNAL_1:TRIBUNAL_2)
#define GetTribunalJail(%1) (%1==1?TRIBUJAIL_1:TRIBUJAIL_2)

public void OnPluginStart() {
	LoadTranslations("core.phrases");
	LoadTranslations("common.phrases");
	LoadTranslations("roleplay.phrases");
	LoadTranslations("roleplay.items.phrases");
	LoadTranslations("roleplay.justice.phrases");
	
	g_flCoords[1][0] = view_as<float>( { -508.0, -818.0, -1870.0 } );
	g_flCoords[1][1] = view_as<float>( { -508.0, -712.0, -1870.0 } );
	
	g_flCoords[2][0] = view_as<float>( { 308.0, -1530.0, -1870.0 } );
	g_flCoords[2][1] = view_as<float>( { 200.0, -1530.0, -1870.0 } );
	
	RegServerCmd("rp_item_enquete_menu",Cmd_ItemEnqueteMenu,	"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_enquete",		Cmd_ItemEnquete,		"RP-ITEM",	FCVAR_UNREGISTERED);
	CreateTimer(1.0, Timer_Light, _, TIMER_REPEAT);
	
	for (int i = 1; i <= MaxClients; i++)
		if( IsValidClient(i) )
			OnClientPostAdminCheck(i);
}

public void OnMapStart() {
	g_cBeam = PrecacheModel("materials/sprites/laserbeam.vmt");
}
public void OnClientPostAdminCheck(int client) {
	g_bClientDisconnected[client] = false;
	rp_HookEvent(client, RP_OnPlayerCommand, fwdCommand);
	
	for (int i = 1; i <= 2; i++) {
		if( !isTribunalDisponible(i) )
			rp_HookEvent(client, RP_OnPlayerHUD, fwdHUD);
	}
}
// ----------------------------------------------------------------------------
public Action RP_OnPlayerGotPay(int client, int salary, int& topay, bool verbose) {
	int jobID = rp_GetClientJobID(client);
	
	if( jobID == 101 && rp_GetClientInt(client, i_KillJailDuration) > 0 ) {
		
		if( verbose )
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Justice_NoPay", client);
		
		topay = 0;
		return Plugin_Stop;
	}
	return Plugin_Continue;
}
public void OnClientDisconnect(int client) {
	g_bClientDisconnected[client] = true;
	
	for (int type = 1; type <= 2; type++) {
		
		if( g_iTribunalData[type][td_AvocatPlaignant] == client )
			g_iTribunalData[type][td_AvocatPlaignant] = 0;
		if( g_iTribunalData[type][td_AvocatSuspect] == client )
			g_iTribunalData[type][td_AvocatSuspect] = 0;
		
		if( g_iTribunalData[type][td_Owner] == client || g_iTribunalData[type][td_Plaignant] == client )
			AUDIENCE_Stop(type);
		
		if( g_iTribunalData[type][td_Suspect] == client ) {
			AUDIENCE_Condamner(type, 5);
		}
	}
}
public Action Timer_Light(Handle timer, any none) {
	
	for (int i = 1; i <= 2; i++) {
		TE_SetupBeamPoints(g_flCoords[i][0], g_flCoords[i][1], g_cBeam, g_cBeam, 0, 0, 1.1, 4.0, 4.0, 0, 0.0, tribunalColor(i), 0);
		TE_SendToAll();
		
		
		if( g_iTribunalData[i][td_Suspect] > 0 && g_iTribunalData[i][td_SuspectArrive] == 1 ) {
			int zone = rp_GetPlayerZone(g_iTribunalData[i][td_Suspect]);
			if( GetTribunalType(zone) != i ) {
				float pos[3];
				pos = getZoneMiddle(GetTribunalJail(i));
				rp_ClientTeleport(g_iTribunalData[i][td_Suspect], pos);
			}
		}
	}
	
}
// ----------------------------------------------------------------------------
public Action fwdCommand(int client, char[] command, char[] arg) {
	if( StrContains(command, "tb") == 0 || StrEqual(command, "tribunal") ) {
		return Draw_Menu(client);
	}
	else if( StrContains(command, "jgmt") == 0 ) {
		return Cmd_Jugement(client, arg);
	}
	return Plugin_Continue;
}
public Action Cmd_Jugement(int client, char[] arg) {
	
	int size, heure, amende, p;
	int id = StringToInt(g_szJugementDATA[client][1]);
	int type = StringToInt(g_szJugementDATA[client][2]);
	int length = strlen(arg);
	char buffers[4][32], nick[64], pseudo[sizeof(nick) * 2 + 1];
	
	if( type == 1 )
		size = 4;
	if( type == 2 || type == 3 )
		size = 2;
	
	if( size == 0 ) {
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Tribunal_Error_SelectFirst", client);
		return Plugin_Handled;
	}
	
	for (int i = 0; i < size; i++) {
		p = SplitString(arg, " ", buffers[i], sizeof(buffers[]));
		if( p > 0 ) {
			for (int j = 0; j <= (length - p); j++)
				arg[j] = arg[j + p];
		}
	}
	
	heure = StringToInt(buffers[2]);
	amende = StringToInt(buffers[3]);
	
	if( !StrEqual(buffers[1], g_szJugementDATA[client][0]) ) {
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Tribunal_Error_WrongCode", client);
		return Plugin_Handled;
	}
	
	char query[1024], szSteamID[32];
	char[] escape = new char[length * 2 + 1];
	GetClientAuthId(client, AUTH_TYPE, szSteamID, sizeof(szSteamID));
	SQL_EscapeString(rp_GetDatabase(), arg, escape, length*2 + 1);
	
	Format(query, sizeof(query), "UPDATE `rp_report`.`site_report` SET `jail`='%d', `amende`='%d', `juge`='%s', `reason`='%s' WHERE `id`='%d' LIMIT 1;", heure, amende, szSteamID, escape, id);
	SQL_TQuery(rp_GetDatabase(), SQL_QueryCallBack, query);
	
	if( type != 3 ) {
		Format(query, sizeof(query), "INSERT INTO `rp_csgo`.`rp_users2` (`steamid`, `xp`, `pseudo`) (SELECT `steamid`, '100', 'Tribunal Forum' FROM `rp_report`.`site_report_votes` WHERE `reportid`=%d AND `vote`=%d GROUP BY `steamid`)", id, type == 1 ? 1 : 0);
		SQL_TQuery(rp_GetDatabase(), SQL_QueryCallBack, query);
	}
	
	if( type == 1 ) {
		GetClientName(client, nick, sizeof(nick));
		SQL_EscapeString(rp_GetDatabase(), nick, pseudo, sizeof(pseudo));
		
		Format(query, sizeof(query), "INSERT INTO `rp_csgo`.`rp_users2` (`steamid`, `money`, `jail`, `pseudo`, `steamid2`, `raison`) ( SELECT `report_steamid`, '%d', '%d', '%s', '%s', '%s' FROM `rp_report`.`site_report` WHERE `id`='%d' )", -amende, heure*60, pseudo, szSteamID, escape, id); 
		SQL_TQuery(rp_GetDatabase(), SQL_QueryCallBack, query);
	}
	
	switch(type) {
		case 1: CPrintToChat(client, "" ...MOD_TAG... " %T", "Tribunal_Forum_Condamn", client);
		case 2: CPrintToChat(client, "" ...MOD_TAG... " %T", "Tribunal_Forum_Acquit", client);
		case 3: CPrintToChat(client, "" ...MOD_TAG... " %T", "Tribunal_Forum_Cancel", client);
		
	}
	
	return Plugin_Handled;
}
Action Draw_Menu(int client) {
	char tmp[128];
	int type = GetTribunalType(rp_GetPlayerZone(client));
	
	if( type == 0 )
		return Plugin_Stop;
	if( rp_GetClientJobID(client) != 101 )
		return Plugin_Stop;
	if( rp_GetClientInt(client, i_Job) == 107 && !FormationCanBeMade(type) )
		return Plugin_Stop;
	
	
	if( isTribunalDisponible(type) ) {
		
		Menu menu = new Menu(MenuTribunal);
		menu.SetTitle("%T\n ", "Tribunal_Menu", client);
		
		Format(tmp, sizeof(tmp), "%T", "Tribunal_Menu_Start", client);		menu.AddItem("start -1", tmp);
		Format(tmp, sizeof(tmp), "%T", "Tribunal_Menu_Wedding", client);	menu.AddItem("mariage", tmp);
		Format(tmp, sizeof(tmp), "%T", "Tribunal_Menu_Forum", client);		menu.AddItem("forum", tmp, (rp_GetClientInt(client, i_Job) <= 104 && GetConVarInt(FindConVar("hostport")) == 27015) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
		Format(tmp, sizeof(tmp), "%T", "Tribunal_Menu_Genre", client);		menu.AddItem("identity", tmp);
		
		menu.Display(client, MENU_TIME_FOREVER);
	}
	else {
		
		char title[512];
		Menu menu = new Menu(MenuTribunal);
		g_iTribunalData[type][td_Dedommagement] = calculerDedo(type);
		
		fwdHUD(client, title, sizeof(title));		
		menu.SetTitle(title);
		
		int admin = (g_iTribunalData[type][td_Owner] == client) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED;
		bool injail = (g_iTribunalData[type][td_SuspectArrive] == 1 ? true:false);
		
		if( admin == ITEMDRAW_DEFAULT ) {
						
			Format(tmp, sizeof(tmp), "%T", "Tribunal_Menu_Articles", client);	menu.AddItem("articles", tmp); 
			Format(tmp, sizeof(tmp), "%T", "Tribunal_Menu_Avocats", client);	menu.AddItem("avocat", tmp);
			Format(tmp, sizeof(tmp), "%T", "Tribunal_Menu_Enquete", client);	menu.AddItem("enquete", tmp, (injail) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
			
			Format(tmp, sizeof(tmp), "%T", "Tribunal_Menu_Condamner", client);	menu.AddItem("condamner -1", tmp, (injail) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED );
			Format(tmp, sizeof(tmp), "%T", "Tribunal_Menu_Dedo", client);		menu.AddItem("dedomager -1", tmp, (g_iTribunalData[type][td_DoneDedommagement] == 0 && injail && (g_iTribunalData[type][td_AvocatPlaignant] > 0 || g_iTribunalData[type][td_AvocatSuspect] > 0)) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED );
			Format(tmp, sizeof(tmp), "%T", "Tribunal_Menu_Acquitter", client);	menu.AddItem("acquitter -1", tmp, (injail) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED );
			Format(tmp, sizeof(tmp), "%T", "Tribunal_Menu_Cancel", client);		menu.AddItem("stop 1", tmp, (!injail) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
			Format(tmp, sizeof(tmp), "%T", "Tribunal_Menu_Switch", client);		menu.AddItem("inverser", tmp, (injail) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
			Format(tmp, sizeof(tmp), "%T", "Tribunal_Menu_Juge", client);		menu.AddItem("forward", tmp);
		}
		menu.Display(client, MENU_TIME_FOREVER);
	}
	
	return Plugin_Handled;
}
// ----------------------------------------------------------------------------
Menu AUDIENCE_Start(int client, int type, int plaignant, int suspect) {
	Menu subMenu = null;
	char tmp[64], tmp2[64];
	
	if( plaignant <= 0 ) {
		subMenu = new Menu(MenuTribunal);
		subMenu.SetTitle("%T\n ", "Tribunal_Menu_Plaignant", client);
		
		for (int i = 1; i<=MaxClients; i++) {
			if( !IsValidClient(i) )
				continue;
			
			if( GetTribunalZone(type) != rp_GetPlayerZone(i) )
				continue;
			
			Format(tmp, sizeof(tmp), "start %d", i);
			GetClientName2(i, tmp2, sizeof(tmp2), true);
			
			subMenu.AddItem(tmp, tmp2);
		}
	}
	else if( suspect <= 0 ) {
		subMenu = new Menu(MenuTribunal);
		subMenu.SetTitle("%T\n ", "Tribunal_Menu_Suspect", client);
		
		for (int i = 1; i<=MaxClients; i++) {
			if( !IsValidClient(i) )
				continue;
#if !defined DEBUG
			if( i == client )
				continue;
			if( i == plaignant )
				continue;
#endif
			Format(tmp, sizeof(tmp), "start %d %d", plaignant, i);
			GetClientName2(i, tmp2, sizeof(tmp2), true);
			
			subMenu.AddItem(tmp, tmp2);
		}
	}
	else if( g_iTribunalData[type][td_Owner] <= 0 ) {
		g_iTribunalData[type][td_Suspect] = suspect;
		g_iTribunalData[type][td_Plaignant] = plaignant;		
		g_iTribunalData[type][td_Owner] = client;
		rp_SetClientBool(client, b_IsInAudiance, true);
		
		if( GetClientTeam(client) == CS_TEAM_T ) {
			FakeClientCommand(client, "say /cop");
		}
		
		LogToGame("[TRIBUNAL] [AUDIENCE] Le juge %L convoque %L dans l'affaire l'opposant à %L.", client, suspect, plaignant);
		
		CreateTimer(1.0, Timer_AUDIENCE, type, TIMER_REPEAT);
		
		for (int i = 1; i <= MaxClients; i++) {
			if( !IsValidClient(i) )
				continue;
			rp_HookEvent(i, RP_OnPlayerHUD, fwdHUD);
		}
	}
	
	return subMenu;
}
Menu AUDIENCE_Stop(int type, int needConfirmation = 0) {
	
	if( needConfirmation == 1 ) {
		
		bool injail = (g_iTribunalData[type][td_SuspectArrive] == 1 ? true:false);
		int client = g_iTribunalData[type][td_Owner];
		
		Menu subMenu = new Menu(MenuTribunal);
		subMenu.SetTitle("%T\n ", "Tribunal_Menu_Cancel_Confirm", client); 
		
		char tmp[64];
		
		Format(tmp, sizeof(tmp), "%T", "No", client);	subMenu.AddItem("tb", tmp);
		Format(tmp, sizeof(tmp), "%T", "Yes", client);	subMenu.AddItem("stop 0", tmp, (!injail) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
		
		return subMenu;
	}
	
	if( IsValidClient(g_iTribunalData[type][td_Owner]) ) {
		rp_SetClientBool(g_iTribunalData[type][td_Owner], b_IsInAudiance, false);
	}
	
	if( IsValidClient(g_iTribunalData[type][td_Suspect]) ) {
		rp_SetClientInt(g_iTribunalData[type][td_Suspect], i_SearchLVL, 0);
		rp_SetClientBool(g_iTribunalData[type][td_Suspect], b_IsSearchByTribunal, false);
	}
	
	for (int i = 0; i < view_as<int>(td_Max); i++)
		g_iTribunalData[type][i] = 0;
	
	for (int i = 0; i < sizeof(g_iArticles[]); i++)
		g_iArticles[type][i] = 0;
	
	
	for (int i = 1; i <= MaxClients; i++) {
		if( !IsValidClient(i) )
			continue;
		rp_UnhookEvent(i, RP_OnPlayerHUD, fwdHUD);
	}
	return null;
}
Menu AUDIENCE_Articles(int type, int a, int b, int c) {
	Menu subMenu = null;
	char tmp[64], tmp2[64];
	
	int client = g_iTribunalData[type][td_Owner];
	
	if( a == 0 ) {
		subMenu = new Menu(MenuTribunal);
		subMenu.SetTitle("%T \n ", "Tribunal_Menu_Articles", client);
		Format(tmp, sizeof(tmp), "%T", "Tribunal_Menu_Articles_Add", client);		subMenu.AddItem("articles 1 -1", tmp, getMaxArticles(g_iTribunalData[type][td_Owner]) > g_iTribunalData[type][td_ArticlesCount] ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED );
		Format(tmp, sizeof(tmp), "%T", "Tribunal_Menu_Articles_Remove", client);	subMenu.AddItem("articles 2 -1", tmp, g_iTribunalData[type][td_ArticlesCount] > 0 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED );
		
	}
	else if( a == 1 && b == -1 ) {
		subMenu = new Menu(MenuTribunal);
		subMenu.SetTitle("%T\n ", "Tribunal_Menu_Articles_List", client);
		for (int i = 0; i < sizeof(g_szArticles); i++) {
			Format(tmp, sizeof(tmp), "articles 1 %d", i);
			Format(tmp2, sizeof(tmp2), "%T", g_szArticles[i][1], client);
			
			subMenu.AddItem(tmp, tmp2);
		}
	}
	else if( a == 2 && b == -1 ) {
		subMenu = new Menu(MenuTribunal);
		subMenu.SetTitle("%T\n ", "Tribunal_Menu_Articles_List", client);
		for (int i = 0; i < sizeof(g_szArticles); i++) {
			if( g_iArticles[type][i] <= 0 )
				continue;
			Format(tmp, sizeof(tmp), "articles 2 %d", i);
			Format(tmp2, sizeof(tmp2), "%T", g_szArticles[i][1], client);
			
			subMenu.AddItem(tmp, tmp2);
		}
	}
	else if( a == 1 && b >= 0 ) {
		
		if( StringToInt(g_szArticles[b][4]) == -1 && c != 42 ) {
			
			g_iTribunalData[type][td_Dedommagement2] += c;
			if( g_iTribunalData[type][td_Dedommagement2] < 0 )
				g_iTribunalData[type][td_Dedommagement2] = 0;
			
			subMenu = new Menu(MenuTribunal);
			subMenu.SetTitle("%T\n ", "Tribunal_Menu_Dedo_Amount", client, g_szArticles[b][1], g_iTribunalData[type][td_Dedommagement2]);
			
			Format(tmp, sizeof(tmp), "articles 1 %d %d", b, 5);		Format(tmp2, sizeof(tmp2), "%T", "Tribunal_Menu_Dedo_Add", client, 5);		subMenu.AddItem(tmp, tmp2);
			Format(tmp, sizeof(tmp), "articles 1 %d %d", b, 50);	Format(tmp2, sizeof(tmp2), "%T", "Tribunal_Menu_Dedo_Add", client, 50);		subMenu.AddItem(tmp, tmp2);
			Format(tmp, sizeof(tmp), "articles 1 %d %d", b, 500);	Format(tmp2, sizeof(tmp2), "%T", "Tribunal_Menu_Dedo_Add", client, 500);		subMenu.AddItem(tmp, tmp2);
			
			Format(tmp, sizeof(tmp), "articles 1 %d %d", b, -5);	Format(tmp2, sizeof(tmp2), "%T", "Tribunal_Menu_Dedo_Remove", client, 5);		subMenu.AddItem(tmp, tmp2);
			Format(tmp, sizeof(tmp), "articles 1 %d %d", b, -50);	Format(tmp2, sizeof(tmp2), "%T", "Tribunal_Menu_Dedo_Remove", client, 50);	subMenu.AddItem(tmp, tmp2);
			Format(tmp, sizeof(tmp), "articles 1 %d %d", b, -500);	Format(tmp2, sizeof(tmp2), "%T", "Tribunal_Menu_Dedo_Remove", client, 500);	subMenu.AddItem(tmp, tmp2);
			
			Format(tmp, sizeof(tmp), "articles 1 %d %d", b, 42);	Format(tmp2, sizeof(tmp2), "%T", "Tribunal_Menu_Dedo_Confirm", client);		subMenu.AddItem(tmp, tmp2);
		}
		else {
			g_iArticles[type][b]++;
			g_iTribunalData[type][td_ArticlesCount]++;
		}
	}
	else if( a == 2 && b >= 0 ) {
		g_iArticles[type][b]--;
		g_iTribunalData[type][td_ArticlesCount]--;
	}
	
	return subMenu;
}
Menu AUDIENCE_Condamner(int type, int articles) {
	Menu subMenu = null;
	char tmp[64], tmp2[64];
	
	int client = g_iTribunalData[type][td_Owner];
	
	if( articles == -1 ) {
		int severity = timeToSeverity(g_iTribunalData[type][td_Time]) - g_iTribunalData[type][td_DoneDedommagement];
		
		subMenu = new Menu(MenuTribunal);
		subMenu.SetTitle("%T\n ", "Tribunal_Menu_Condamner_Confirm", client);
		
		int heure, amende;
		calculerJail(type, heure, amende);
		
		for (int i = 0; i < sizeof(g_szCondamnation); i++) {
			Format(tmp, sizeof(tmp), "condamner %d", i);
			Format(tmp2, sizeof(tmp2), "%T %dh %d$", g_szCondamnation[i], client, RoundFloat(float(heure) * g_flCondamnation[i]),  RoundFloat(float(amende) * g_flCondamnation[i]));
			
			subMenu.AddItem(tmp, tmp2, (i>=severity-1&&i<=severity+1) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED );
		}
	}
	else {
		
		int heure, amende;
		calculerJail(type, heure, amende);
		
		heure = RoundFloat(float(heure) * g_flCondamnation[articles]);
		amende = RoundFloat(float(amende) * g_flCondamnation[articles]);
		
		char target_name[128];
		GetClientName2(g_iTribunalData[type][td_Suspect], target_name, sizeof(target_name), false);
		
		CPrintToChatSearch(type, "{lightblue}================================");
		CPrintToChatSearch(type, ""...MOD_TAG..." %T", "Tribunal_Menu_Condamner_Doing", LANG_SERVER, target_name);
		for (int i = 0; i < sizeof(g_szArticles); i++) {
			if( g_iArticles[type][i] <= 0 )
				continue;
			
			CPrintToChatSearch(type, "- %T", g_szArticles[i][5], LANG_SERVER, heure, amende);
		}		
		CPrintToChatSearch(type, "" ...MOD_TAG... " %T", "Tribunal_Menu_Condamner_Given", LANG_SERVER, target_name, heure, amende, g_szCondamnation[articles]);
		CPrintToChatSearch(type, "{lightblue}================================");

		SQL_Insert(type, 1, articles, heure, amende);
		
		AUDIENCE_Stop(type);
	}
	
	return subMenu;
}
Menu AUDIENCE_Acquitter(int type, int articles) {
	Menu subMenu = null;
	char tmp[64], tmp2[64];
	
	int client = g_iTribunalData[type][td_Owner];
	
	
	if( articles == -1 ) {
		subMenu = new Menu(MenuTribunal);
		subMenu.SetTitle("%T\n ", "Tribunal_Menu_Acquitter_Confirm", client);
		for (int i = 0; i < sizeof(g_szAcquittement); i++) {
			Format(tmp, sizeof(tmp), "acquitter %d", i);
			Format(tmp2, sizeof(tmp2), "%T", g_szAcquittement[i], client);
			
			subMenu.AddItem(tmp, tmp2);
		}
	}
	else {
		
		SQL_Insert(type, 0, articles, 0, 0);
		
		char target_name[128];
		GetClientName2(g_iTribunalData[type][td_Suspect], target_name, sizeof(target_name), false);
		CPrintToChatSearch(type, "" ...MOD_TAG... " %T", "Tribunal_Menu_Acquitter_Given", LANG_SERVER, target_name, g_szAcquittement[articles]);
		AUDIENCE_Stop(type);
	}
	
	return subMenu;
}
Menu AUDIENCE_Avocat(int type, int a, int b) {
	Menu subMenu = null;
	char tmp[64], tmp2[64];
	
	int client = g_iTribunalData[type][td_Owner];
	
	if( a == 0 ) {
		subMenu = new Menu(MenuTribunal);
		subMenu.SetTitle("%T\n ", "Tribunal_Menu_Avocats", client);
		
		Format(tmp, sizeof(tmp), "%T", "Tribunal_Menu_Avocats_Victim", client);		subMenu.AddItem("avocat 1 -1", tmp);
		Format(tmp, sizeof(tmp), "%T", "Tribunal_Menu_Avocats_Defense", client);	subMenu.AddItem("avocat 2 -1", tmp);
	}
	else if( b == -1 ) {
		subMenu = new Menu(MenuTribunal);
		subMenu.SetTitle("%T\n ", "Tribunal_Menu_Avocats", client);
		
		Format(tmp, sizeof(tmp), "avocat %d 0", a);
		Format(tmp2, sizeof(tmp2), "%T", "Jobs_Noone", client);
		subMenu.AddItem(tmp, tmp2);
		
		for (int i = 1; i <= MaxClients; i++) {
			if( !IsValidClient(i) )
				continue;
			if( rp_GetClientInt(i, i_Avocat) <= 0 )
				continue;
			if( g_iTribunalData[type][td_Plaignant] == i )
				continue;
			if( g_iTribunalData[type][td_Suspect] == i )
				continue;
			if( g_iTribunalData[type][td_AvocatPlaignant] == i )
				continue;
			if( g_iTribunalData[type][td_AvocatSuspect] == i )
				continue;
			
			Format(tmp, sizeof(tmp), "avocat %d %d", a, i);
			GetClientName2(i, tmp2, sizeof(tmp2), true);
			subMenu.AddItem(tmp, tmp2);
		}
	}
	else {
		g_iTribunalData[type][a == 1 ? td_AvocatPlaignant : td_AvocatSuspect] = b;
	}
	
	return subMenu;
}
Menu AUDIENCE_Dedommagement(int type) {
	
	if( g_iTribunalData[type][td_DoneDedommagement] == 0 ) {
		
		g_iTribunalData[type][td_DoneDedommagement] = 1;
		
		int money = calculerDedo(type);
		int client = g_iTribunalData[type][td_Plaignant];
		int target = g_iTribunalData[type][td_Suspect];
		
		rp_ClientMoney(target, i_Money, -money);
		rp_ClientMoney(client, i_Money, money);
		
		char client_name[128], target_name[128];
		GetClientName2(client, client_name, sizeof(client_name), false);
		GetClientName2(target, target_name, sizeof(target_name), false);
		
		CPrintToChatSearch(type, "" ...MOD_TAG... " %T", "Tribunal_Menu_Dedo_Given", LANG_SERVER, target_name, client_name, money);
	}
	
	return null;
	
}
Menu AUDIENCE_Enquete(int type, int a, int b) {
	Menu subMenu = null;
	char tmp[64], tmp2[64];
	
	int client = g_iTribunalData[type][td_Owner];
	
	if( a == 0 ) {
		
		if( g_iTribunalData[type][td_TimeMercenaire] == 0 && !hasMercenaire() )
			g_iTribunalData[type][td_TimeMercenaire] = 60;
		
		subMenu = new Menu(MenuTribunal);
		subMenu.SetTitle("%T\n ", "Tribunal_Menu_Enquete", client);
		
		Format(tmp, sizeof(tmp), "%T", "Tribunal_Menu_Enquete_Merco", client);		subMenu.AddItem("enquete 1", tmp, g_iTribunalData[type][td_TimeMercenaire] < 60 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
		Format(tmp, sizeof(tmp), "%T", "Tribunal_Menu_Enquete_Self", client, 100);	subMenu.AddItem("enquete 2", tmp, g_iTribunalData[type][td_TimeMercenaire] >= 60 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
		Format(tmp, sizeof(tmp), "%T", "Tribunal_Menu_Enquete_Log", client);		subMenu.AddItem("enquete 3", tmp, (g_iTribunalData[type][td_EnquetePlaignant] + g_iTribunalData[type][td_EnqueteSuspect]) >= 2 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED );
		
	}
	else if( a == 1 ) {
		if( g_iTribunalData[type][td_TimeMercenaire] < 60 ) {
			CreateTimer(1.0, Timer_MERCENAIRE, type, TIMER_REPEAT);
		}
		
		CPrintToChatSearch(type, "" ...MOD_TAG... " %T", "Tribunal_Menu_Enquete_Merco_Confirm", LANG_SERVER, type);
	}
	else if( a == 2 || a == 3 ) {
		if( a == 2 &&  b > 0 ) {
			ServerCommand("rp_item_enquete \"%i\" \"%i\"", g_iTribunalData[type][td_Owner], b);
			
			if( b == g_iTribunalData[type][td_Plaignant] )
				g_iTribunalData[type][td_EnquetePlaignant] = 1;
			if( b == g_iTribunalData[type][td_Suspect] )
				g_iTribunalData[type][td_EnqueteSuspect] = 1;
			
			rp_ClientMoney(g_iTribunalData[type][td_Owner], i_Money, -100);
		}
		else if( a == 3 &&  b > 0 ) {
			
			char szURL[1024];
			GetClientAuthId(b, AUTH_TYPE, tmp2, sizeof(tmp2));

			Format(szURL, sizeof(szURL), ""...MOD_URL..."#/tribunal/case/%s", tmp2);
			PrintToConsole(g_iTribunalData[type][td_Owner], ""...MOD_URL..."#/tribunal/case/%s", tmp2);
			
			RP_ShowMOTD(g_iTribunalData[type][td_Owner], szURL);
		}
		else {
			subMenu = new Menu(MenuTribunal);
			subMenu.SetTitle("%T\n ", "Tribunal_Menu_Enquete", client);
			
			int zone;
			int tribu = GetTribunalZone(type);
			int jail = GetTribunalJail(type);
			
			
			for (int i = 1; i <= MaxClients; i++) {
				if( !IsValidClient(i) )
					continue;
				zone = rp_GetPlayerZone(i);
				if( zone == tribu || zone == jail ) {
					Format(tmp, sizeof(tmp), "enquete %d %d", a, i);
					GetClientName2(i, tmp2, sizeof(tmp2), true);
					subMenu.AddItem(tmp, tmp2);
				}
			}
		}
	}
	
	return subMenu;
}
Menu AUDIENCE_Inverser(int type) {
	int p = g_iTribunalData[type][td_Plaignant];
	int q = g_iTribunalData[type][td_Suspect];
	int r = g_iTribunalData[type][td_AvocatPlaignant];
	int s = g_iTribunalData[type][td_AvocatSuspect];
	
	g_iTribunalData[type][td_Plaignant] = q;
	g_iTribunalData[type][td_Suspect] = p;
	g_iTribunalData[type][td_AvocatPlaignant] = s;
	g_iTribunalData[type][td_AvocatSuspect] = r;

	rp_SetClientInt(q, i_SearchLVL, rp_GetClientInt(p, i_SearchLVL));
	rp_SetClientInt(p, i_SearchLVL, 0);
	rp_SetClientBool(q, b_IsSearchByTribunal, rp_GetClientBool(p, b_IsSearchByTribunal));
	rp_SetClientBool(p, b_IsSearchByTribunal, false);
	
	return null;
}
Menu AUDIENCE_Forward(int type, int a) {
	Menu subMenu;
	char tmp[64], tmp2[64];
	
	int client = g_iTribunalData[type][td_Owner];
	
	if( a == 0 ) {
		subMenu = new Menu(MenuTribunal);
		subMenu.SetTitle("%T\n ", "Tribunal_Menu_Juge", client);
		
		for (int i = 1; i <= MaxClients; i++) {
			if( !IsValidClient(i) )
				continue;
			if( rp_GetClientJobID(i) != 101 )
				continue;
			if( i == g_iTribunalData[type][td_Owner] )
				continue;
			
			Format(tmp, sizeof(tmp), "forward %d", i);
			GetClientName2(i, tmp2, sizeof(tmp2), true);
			subMenu.AddItem(tmp, tmp2);
		}
	}
	else {
		GetClientName2(g_iTribunalData[type][td_Owner], tmp, sizeof(tmp), true);
		GetClientName2(a, tmp2, sizeof(tmp2), true);
		CPrintToChatSearch(type, "" ...MOD_TAG... " %T", "Tribunal_Menu_Switch_Confirm", LANG_SERVER, tmp, tmp2);
		
		rp_SetClientBool(g_iTribunalData[type][td_Owner], b_IsInAudiance, false);
		g_iTribunalData[type][td_Owner] = a;
		rp_SetClientBool(g_iTribunalData[type][td_Owner], b_IsInAudiance, true);
		
	}
	return subMenu;
}
Menu AUDIENCE_Forum(int client, int a, int b) {
	char query[1024], tmp[64], tmp2[64];
	Menu subMenu;
	
	if( a == 0 ) {
		GetClientAuthId(client, AUTH_TYPE, tmp, sizeof(tmp));
		
		Format(query, sizeof(query), "SELECT R.`id`, `report_steamid`, COUNT(`vote`) cpt, `name`, SUM(IF(`vote`=1,1,0)) as cpt2 FROM `rp_report`.`site_report` R INNER JOIN `rp_report`.`site_report_votes` V ON V.`reportid`=R.`id` INNER JOIN `rp_csgo`.`rp_users` U ON U.`steamid`=R.`report_steamid` WHERE V.`vote`<>'2' AND R.`jail`=-1 AND R.`own_steamid`<>'%s' AND R.`report_steamid`<>'%s' GROUP BY R.`id` HAVING cpt>=5 ORDER BY cpt DESC;", tmp, tmp);
		SQL_TQuery(rp_GetDatabase(), SQL_AUDIENCE_Forum, query, client);
	}
	else if( b == 0 ) {
			
		Format(query, sizeof(query), ""...MOD_URL..."#/tribunal/case/%d", a);
		PrintToConsole(client, ""...MOD_URL..."#/tribunal/case/%d", a);
		RP_ShowMOTD(client, query);
		
	 	subMenu = new Menu(MenuTribunal);
		subMenu.SetTitle("%T\n ", "Tribunal_Menu_Condamner_Confirm", client);
		
		Format(tmp, sizeof(tmp), "forum %d 1", a); Format(tmp2, sizeof(tmp2), "%T", "Tribunal_Menu_Condamner", client); subMenu.AddItem(tmp, tmp2);
		Format(tmp, sizeof(tmp), "forum %d 2", a); Format(tmp2, sizeof(tmp2), "%T", "Tribunal_Menu_Acquitter", client); subMenu.AddItem(tmp, tmp2);
		Format(tmp, sizeof(tmp), "forum %d 3", a); Format(tmp2, sizeof(tmp2), "%T", "Tribunal_Menu_Supprimer", client); subMenu.AddItem(tmp, tmp2);
		
	}
	else {
		
		String_GetRandom(g_szJugementDATA[client][0], sizeof(g_szJugementDATA[][]), 4, "23456789abcdefgpqrstuvxyz");
		Format(g_szJugementDATA[client][1], sizeof(g_szJugementDATA[][]), "%d", a);
		Format(g_szJugementDATA[client][2], sizeof(g_szJugementDATA[][]), "%d", b);
		
		CPrintToChat(client, "" ...MOD_TAG... " %T", b == 1 ? "Tribunal_Forum_Confirm_Condamn" : "Tribunal_Forum_Confirm_Acquitter", client, g_szJugementDATA[client][0]);
	}
	
	return subMenu;
}
Menu AUDIENCE_Identity(int& client, int a, int b, int c) {
	Menu subMenu = null;
	char tmp[64], tmp2[64];
	
	if( a == 0 && b == 0 ) {
		a = client;
		subMenu = new Menu(MenuTribunal);
		subMenu.SetTitle("%T\n ", "Tribunal_Menu_Sexe", client);
		
		for (int i = 1; i<=MaxClients; i++) {
			if( !IsValidClient(i) )
				continue;
			
			if( rp_GetPlayerZone(a) != rp_GetPlayerZone(i) )
				continue;
			
			Format(tmp, sizeof(tmp), "identity %d %d", a, i);
			GetClientName2(i, tmp2, sizeof(tmp2), true);
			
			subMenu.AddItem(tmp, tmp2);
		}
	}
	else if( c == 0 ) {
		client = b;
		
		subMenu = new Menu(MenuTribunal);
		subMenu.SetTitle("%T", "Tribunal_Menu_Sexe_Confirm", client);
		Format(tmp, sizeof(tmp), "identity %d %d 1", a, b); Format(tmp2, sizeof(tmp2), "%T", "No", client); subMenu.AddItem(tmp, tmp2);
		Format(tmp, sizeof(tmp), "identity %d %d 2", a, b); Format(tmp2, sizeof(tmp2), "%T", "Yes", client); subMenu.AddItem(tmp, tmp2);
		
	}
	else {
		char client_name[128];
		GetClientName2(client, client_name, sizeof(client_name), false);


		if( c == 2 ) {
			rp_ClientMoney(client, i_Money, -2500);
			rp_ClientMoney(a, i_Money, 1250);
			rp_SetJobCapital(101, rp_GetJobCapital(101) + 1250);
			
			rp_SetClientBool(client, b_isFemale, !rp_GetClientBool(client, b_isFemale));
			
			PrintToChatZone( rp_GetPlayerZone(client) , "%T", "Tribunal_Menu_Sexe_Given", client_name, rp_GetClientBool(client, b_isFemale) ? "a_female" : "a_male");
		}
		else {
			CPrintToChat(a, "" ...MOD_TAG... " %T", "Tribunal_Menu_Sexe_Deny", client_name);			
		}
	}
	
	return subMenu;
}
public void SQL_AUDIENCE_Forum(Handle owner, Handle handle, const char[] error, any client) {
	
	
	if( SQL_GetRowCount(handle) == 0 ) {
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Tribunal_Forum_None");
		return;
	}
	
	Menu subMenu = new Menu(MenuTribunal);
	subMenu.SetTitle("%T\n ", "Tribunal_Menu_Forum", client);
	int id, vote, cond;
	char tmp[4][64];
	
	while( SQL_FetchRow(handle) ) {
		id = SQL_FetchInt(handle, 0);
		vote = SQL_FetchInt(handle, 2);
		cond = SQL_FetchInt(handle, 4);
		SQL_FetchString(handle, 1, tmp[0], sizeof(tmp[]));
		SQL_FetchString(handle, 3, tmp[1], sizeof(tmp[]));
		
		Format(tmp[2], sizeof(tmp[]), "forum %d", id);
		Format(tmp[3], sizeof(tmp[]), "%s - %d/%d", tmp[1], cond, vote);
		
		subMenu.AddItem(tmp[2], tmp[3]);
	}
	
	subMenu.Display(client, MENU_TIME_FOREVER);
	
	return;
}
// ----------------------------------------------------------------------------
public int MenuTribunal(Handle menu, MenuAction action, int client, int param2) {
	if( action == MenuAction_Select ) {
		char options[64], expl[4][32];
		GetMenuItem(menu, param2, options, sizeof(options));
		
		ExplodeString(options, " ", expl, sizeof(expl), sizeof(expl[]));
		int a = StringToInt(expl[1]);
		int b = StringToInt(expl[2]);
		int c = StringToInt(expl[3]);
		
		int type = GetTribunalType(rp_GetPlayerZone(client));
		Menu subMenu = null;
		bool subCommand = false;
		
		if( StrEqual(expl[0], "start") )
			subMenu = AUDIENCE_Start(client, type, a, b);
		else if( StrEqual(expl[0], "forum") )
			subMenu = AUDIENCE_Forum(client, a, b);
		else if( StrEqual(expl[0], "stop") )
			subMenu = AUDIENCE_Stop(type, a);
		else if( StrEqual(expl[0], "articles") )
			subMenu = AUDIENCE_Articles(type, a, b, c);
		else if( StrEqual(expl[0], "acquitter") )
			subMenu = AUDIENCE_Acquitter(type, a);
		else if( StrEqual(expl[0], "condamner") )
			subMenu = AUDIENCE_Condamner(type, a);
		else if( StrEqual(expl[0], "avocat") )
			subMenu = AUDIENCE_Avocat(type, a, b);
		else if( StrEqual(expl[0], "enquete") )
			subMenu = AUDIENCE_Enquete(type, a, b);
		else if( StrEqual(expl[0], "dedomager") )
			subMenu = AUDIENCE_Dedommagement(type);
		else if( StrEqual(expl[0], "inverser") )
			subMenu = AUDIENCE_Inverser(type);
		else if( StrEqual(expl[0], "forward") )
			subMenu = AUDIENCE_Forward(type, a);
		else if( StrEqual(expl[0], "identity") )
			subMenu = AUDIENCE_Identity(client, a, b, c);
		else
			subCommand = true;
		
		if( subCommand )
			FakeClientCommand(client, "say /%s", expl[0]);
		else if( subMenu == null )
			Draw_Menu(client);
		else
			subMenu.Display(client, MENU_TIME_FOREVER);
	}
	else if( action == MenuAction_End ) {
		CloseHandle(menu);
	}
	return 0;
}
public Action Timer_MERCENAIRE(Handle timer, any type) {
	if( g_iTribunalData[type][td_TimeMercenaire] > 60 )
		return Plugin_Stop;
	
	int client = g_iTribunalData[type][td_Owner];
	
	for (int i = 1; i <= MaxClients; i++) {
		if( !IsValidClient(i) )
			continue;
		if( rp_GetClientJobID(i) == 41 ) {
			if( rp_GetPlayerZone(i) == GetTribunalZone(type) )
				return Plugin_Stop;
			
			PrintHintText(i, "%T", "Tribunal_Menu_Enquete_Merco_Confirm", client, type);
		}
	}
	
	g_iTribunalData[type][td_TimeMercenaire]++;
	return Plugin_Continue;
}
public Action Timer_AUDIENCE(Handle timer, any type) {
	
	int target = g_iTribunalData[type][td_Suspect];
	int time = g_iTribunalData[type][td_Time];
	int zone = rp_GetPlayerZone(target);
	int jail = GetTribunalJail(type);
	
	if( !IsValidClient(target) ) {
		AUDIENCE_Stop(type);
		return Plugin_Stop;
	}
	
	char target_name[128];
	GetClientName2(target, target_name, sizeof(target_name), false);
	
	if( g_iTribunalData[type][td_ArticlesCount] == 0 ) {
		PrintHintText(g_iTribunalData[type][td_Owner], "%T", "Tribunal_Menu_Audiance_Starting", g_iTribunalData[type][td_Owner]);
		return Plugin_Continue;
	}
	
	if( rp_GetClientInt(target, i_TimeAFK) > 15*60 ) {
		float pos[3];
		pos = getZoneMiddle(GetTribunalJail(type));
		if( !IsPlayerAlive(target) ) {
			CS_RespawnPlayer(target);
		}
		rp_ClientTeleport(target, pos);
		CPrintToChatSearch(type, "" ...MOD_TAG... " %T", "Tribunal_Menu_Audiance_AFK", LANG_SERVER, target_name);
	}
		
	if( time < 60 && time % 20 == 0 ) {
		CPrintToChatSearch(type, "{lightblue}================================");
		CPrintToChatSearch(type, "" ...MOD_TAG... " %T", "Tribunal_Menu_Audiance_Call", LANG_SERVER, target_name, type, time/20 + 1);
		CPrintToChatSearch(type, "{lightblue}================================");
		LogToGame("[TRIBUNAL] [AUDIENCE] Le juge %L a convoque %L [%d/3].", g_iTribunalData[type][td_Owner], target, time/20 + 1);
	}
	else if( time % 60 == 0 ) {
		CPrintToChatSearch(type, "{lightblue}================================");
		CPrintToChatSearch(type, "" ...MOD_TAG... " %T", "Tribunal_Menu_Audiance_Search", LANG_SERVER, target_name, type, time/60);
		CPrintToChatSearch(type, "{lightblue}================================");
		LogToGame("[TRIBUNAL] [AUDIENCE] Le juge %L recherche %L depuis %d minutes.", g_iTribunalData[type][td_Owner], target, time/60);
		
		if( time >= 24*60 )
			rp_SetClientInt(target, i_SearchLVL, 5);
		else
			rp_SetClientInt(target, i_SearchLVL, timeToSeverity(time));
		
		rp_SetClientBool(target, b_IsSearchByTribunal, true);
	}
	
	if( zone == jail ) {
	
		if( time < 60 )
			CPrintToChatSearch(type, "" ...MOD_TAG... " %T", "Tribunal_Menu_Audiance_Came_Fast", LANG_SERVER, target_name);
		else if (time < 300 )
			CPrintToChatSearch(type, "" ...MOD_TAG... " %T", "Tribunal_Menu_Audiance_Came_Normal", LANG_SERVER, target_name, time/60);
		else
			CPrintToChatSearch(type, "" ...MOD_TAG... " %T", "Tribunal_Menu_Audiance_Came_Slow", LANG_SERVER, target_name,time/60);
		
		LogToGame("[TRIBUNAL] [AUDIENCE] Le juge %L termine la convocation de %L après %d minute%s.", g_iTribunalData[type][td_Owner], target, time/60, time/60 >= 2 ? "s":"");
		g_iTribunalData[type][td_SuspectArrive] = 1;
		rp_SetClientBool(target, b_IsSearchByTribunal, false);
		Draw_Menu(g_iTribunalData[type][td_Owner]);
		return Plugin_Stop;
	}
	
	float mid[3];
	mid = getZoneMiddle(jail);
	
	ServerCommand("sm_effect_gps %d %f %f %f", target, mid[0], mid[1], mid[2]);
	PrintHintText(target, "Tribunal_Menu_Audiance_Target", target, type, g_szCondamnation[timeToSeverity(time)]);
	
	g_iTribunalData[type][td_Time]++;
	return Plugin_Continue;
}
public Action fwdHUD(int client, char[] szHUD, const int size) {
	char tmp1[64], tmp2[64];
	int type = GetTribunalType( rp_GetPlayerZone(client) );
	
	if( type > 0 && !isTribunalDisponible(type) ) {
		int heure, amende;
		GetClientName2(g_iTribunalData[type][td_Plaignant], tmp1, sizeof(tmp1), true);
		GetClientName2(g_iTribunalData[type][td_Suspect]  , tmp2, sizeof(tmp2), true);
		
		if( g_iTribunalData[type][td_ArticlesCount] <= 10 ) {
			Format(szHUD, size, "%T", "Tribunal_Menu_Audiance_Main", client);
		}
		else {
			Format(szHUD, size, "");
		}
		
		if( g_iTribunalData[type][td_ArticlesCount] <= 9 ) {
			Format(szHUD, size, "%s\n%T", szHUD, "Tribunal_Menu_Audiance_Main_Players", client, tmp1, tmp2);
		}
		
		if( g_iTribunalData[type][td_ArticlesCount] <= 8 ) {
			GetClientName2(g_iTribunalData[type][td_Owner]    , tmp1, sizeof(tmp1), true);
			Format(szHUD, size, "%s\n%T", szHUD, "Tribunal_Menu_Audiance_Main_Juge", client, tmp1);
		}
		
		if( g_iTribunalData[type][td_AvocatPlaignant] && g_iTribunalData[type][td_ArticlesCount] <= 7 ) {
			GetClientName2(g_iTribunalData[type][td_AvocatPlaignant], tmp1, sizeof(tmp1), true);
			Format(szHUD, size, "%s\n%T", szHUD, "Tribunal_Menu_Audiance_Main_Avocat_Victime", client, tmp1);
		}
		if( g_iTribunalData[type][td_AvocatSuspect] && g_iTribunalData[type][td_ArticlesCount] <= 6 ) {
			GetClientName2(g_iTribunalData[type][td_AvocatSuspect], tmp1, sizeof(tmp1), true);
			Format(szHUD, size, "%s\n%T", szHUD, "Tribunal_Menu_Audiance_Main_Avocat_Defense", client, tmp1);
		}
		
		Format(szHUD, size, "%s\n ", szHUD);
		
		if( g_iTribunalData[type][td_ArticlesCount] > 0 ) {
			Format(szHUD, size, "%s\%T\n ", szHUD, "Tribunal_Menu_Audiance_Main_Charges", client);
			for (int i = 0; i < sizeof(g_szArticles); i++) {
				if( g_iArticles[type][i] <= 0 )
					continue;
				
				Format(tmp1, sizeof(tmp1), "%T", g_szArticles[i][1], client);
				Format(szHUD, size, "%s %2dx   %s\n ", szHUD, g_iArticles[type][i], tmp1);
				
				heure += (g_iArticles[type][i] * StringToInt(g_szArticles[i][2]));
				amende += (g_iArticles[type][i] * StringToInt(g_szArticles[i][3]));
			}
			Format(szHUD, size, "%s\n%T", szHUD, "Tribunal_Menu_Audiance_Main_TOTAL", client, heure, amende);
			if( g_iTribunalData[type][td_Dedommagement] > 0 )
				Format(szHUD, size, "%s\n%T", szHUD, "Tribunal_Menu_Audiance_Main_Dedo", client, g_iTribunalData[type][td_Dedommagement]);
		}
		else {
			Format(szHUD, size, "%s\n%T", szHUD, "Tribunal_Menu_Audiance_Starting", client, heure, amende);
		}
		
		Format(szHUD, size, "%s\n ", szHUD);
		return Plugin_Changed;
	}
	else if( rp_GetClientInt(client, i_Avocat) > 0 ) {
		for (int i = 1; i <= 2; i++) {
			if( g_iTribunalData[i][td_AvocatPlaignant] == client || g_iTribunalData[i][td_AvocatSuspect] == client )
				PrintHintText(client, "%T", "Tribunal_Menu_Audiance_Avocat", client, i);
		}
	}
	return Plugin_Continue;
}
// ----------------------------------------------------------------------------
int[] tribunalColor(int type) {
	int color[4];
	color[3] = 128;
	
	for (int i = 1; i <= MaxClients; i++) {
		if( !IsValidClient(i) )
			continue;
		
		if( rp_GetClientJobID(i) == 101 && !rp_GetClientBool(i, b_IsAFK) ) {
			if( type == 1 && rp_GetPlayerZone(i) == TRIBUNAL_1 )
				color[1] = 255;
			else if( type == 2 && rp_GetPlayerZone(i) == TRIBUNAL_2 )
				color[1] = 255;
		}
	}
	if( color[1] == 0 ) {
		color[0] = 255;
		color[1] = 255;
	}
	
	if( !isTribunalDisponible(type) ) {
		color[0] = 255;
		color[1] = 0;
	}
	
	return color;
}
stock void CPrintToChatSearch(int type, const char[] message, any...) {
	char buffer[MAX_MESSAGE_LENGTH];
	VFormat(buffer, sizeof(buffer), message, 3);
	
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsValidClient(i))
			continue;
		
		if( i == g_iTribunalData[type][td_Suspect] || GetTribunalType(rp_GetPlayerZone(i)) == type || rp_GetClientJobID(i) == 1 || rp_GetClientJobID(i) == 101 ) {
			CPrintToChat(i, buffer);
		}
	}
}
float[] getZoneMiddle(int zone) {
	float middle[3];
	middle[0] = (rp_GetZoneFloat(zone, zone_type_min_x) + rp_GetZoneFloat(zone, zone_type_max_x)) / 2.0;
	middle[1] = (rp_GetZoneFloat(zone, zone_type_min_y) + rp_GetZoneFloat(zone, zone_type_max_y)) / 2.0;
	middle[2] = (rp_GetZoneFloat(zone, zone_type_min_z) + rp_GetZoneFloat(zone, zone_type_max_z)) / 2.0 - 64.0;
	return middle;
}
int timeToSeverity(int time) {
	if( time < (1*60) )	return 0;
	if( time < (4*60) )	return 1;
	if( time < (8*60) )	return 2;
	if( time < (12*60))	return 3;
	return 4;
}
int getMaxArticles(int client) {
	int job = rp_GetClientInt(client, i_Job);
	switch (job) {
		case 101: return 20;
		case 102: return 20;
		case 103: return 15;
		case 104: return 10;
		case 105: return 7;
		case 106: return 5;
		case 107: return 3;		
	}
	return 0;
}
int GetTribunalType(int zone) {
	if( zone == TRIBUNAL_1 || zone == TRIBUJAIL_1 || zone == BUREAU_1 )
		return 1;
	if( zone == TRIBUNAL_2 || zone == TRIBUJAIL_2 || zone == BUREAU_2 || zone == JURRY_2 )
		return 2;
	
	return 0;
}
bool FormationCanBeMade(int type) {
	
	for (int i = 1; i <= MaxClients; i++) {
		if( !IsValidClient(i) )
			continue;
		if( rp_GetClientJobID(i) != 101 )
			continue;
		if( rp_GetClientInt(i, i_Job) == 107 )
			continue;
		if( rp_GetClientBool(i, b_IsAFK) == true )
			continue;
		if( GetTribunalType(rp_GetPlayerZone(i)) != type )
			continue;
		
		return true;
	}
	return false;
}
void SQL_Insert(int type, int condamne, int condamnation, int heure, int amende) {
	char query[1024], szSteamID[5][32], charges[128], nick[64], pseudo[ sizeof(nick)*2+1 ];
	
	
	
	int dedommage = 0;
	if( g_iTribunalData[type][td_DoneDedommagement] == 1 )
		dedommage = calculerDedo(type);
	
	for (int i = 0; i < sizeof(g_szArticles); i++) {
		if( g_iArticles[type][i] <= 0 )
			continue;
		
		Format(charges, sizeof(charges), "%s%dX %s, ", charges, g_iArticles[type][i], g_szArticles[i][0]);
	}
	
	int data[6];
	data[0] = g_iTribunalData[type][td_Plaignant];
	data[1] = g_iTribunalData[type][td_Suspect];
	data[2] = heure;
	data[3] = amende;
	data[4] = dedommage;
	data[5] = g_iTribunalData[type][td_Time];	
	
	Action a;
	Call_StartForward(rp_GetForwardHandle(g_iTribunalData[type][td_Owner], RP_OnJugementOver));
	Call_PushCell(g_iTribunalData[type][td_Owner]);
	Call_PushArray(data, sizeof(data) );
	Call_PushArray(g_iArticles[type], sizeof(g_iArticles[]) );
	Call_Finish(a);
	
	
	charges[strlen(charges) - 2] = 0;
	
	rp_SetJobCapital(101, rp_GetJobCapital(101) + amende);

	
	int suspectJob = condamne ? rp_GetClientJobID(g_iTribunalData[type][td_Suspect]) : 101;
	int takeFromCapital = 500;
	
	if( g_iTribunalData[type][td_EnquetePlaignant] ) {
		takeFromCapital += 100;
	}
	if( g_iTribunalData[type][td_EnqueteSuspect] ) {
		takeFromCapital += 100;
	}


	rp_ClientMoney(g_iTribunalData[type][td_Owner], i_AddToPay, takeFromCapital);
	rp_SetJobCapital(suspectJob, rp_GetJobCapital(suspectJob) - takeFromCapital);
	
	rp_ClientXPIncrement(g_iTribunalData[type][td_Owner], 250);
	
	GetClientAuthId(g_iTribunalData[type][td_Owner], AUTH_TYPE, szSteamID[0], sizeof(szSteamID[]));
	GetClientAuthId(g_iTribunalData[type][td_Plaignant], AUTH_TYPE, szSteamID[1], sizeof(szSteamID[]));
	GetClientAuthId(g_iTribunalData[type][td_Suspect], AUTH_TYPE, szSteamID[2], sizeof(szSteamID[]));
	
	if( IsValidClient(g_iTribunalData[type][td_AvocatPlaignant]) ) {
		GetClientAuthId(g_iTribunalData[type][td_AvocatPlaignant], AUTH_TYPE, szSteamID[3], sizeof(szSteamID[]));
		//rp_ClientXPIncrement(g_iTribunalData[type][td_AvocatPlaignant], rp_GetClientInt(g_iTribunalData[type][td_AvocatPlaignant], i_Avocat));

		if(rp_GetClientInt(g_iTribunalData[type][td_AvocatPlaignant], i_LawyerAudience) < 300) {
			rp_SetClientInt(g_iTribunalData[type][td_AvocatPlaignant], i_LawyerAudience, rp_GetClientInt(g_iTribunalData[type][td_AvocatPlaignant], i_LawyerAudience) + 1);
			int xp = calculAudienceXp(rp_GetClientInt(g_iTribunalData[type][td_AvocatPlaignant], i_LawyerAudience));
			rp_ClientXPIncrement(g_iTribunalData[type][td_AvocatPlaignant], xp);
		}
	}
	if( IsValidClient(g_iTribunalData[type][td_AvocatSuspect]) ) {
		GetClientAuthId(g_iTribunalData[type][td_AvocatSuspect], AUTH_TYPE, szSteamID[4], sizeof(szSteamID[]));
		//rp_ClientXPIncrement(g_iTribunalData[type][td_AvocatSuspect], rp_GetClientInt(g_iTribunalData[type][td_AvocatSuspect], i_Avocat));

		if(rp_GetClientInt(g_iTribunalData[type][td_AvocatSuspect], i_LawyerAudience) < 300) {
			rp_SetClientInt(g_iTribunalData[type][td_AvocatSuspect], i_LawyerAudience, rp_GetClientInt(g_iTribunalData[type][td_AvocatSuspect], i_LawyerAudience) + 1);
			int xp = calculAudienceXp(rp_GetClientInt(g_iTribunalData[type][td_AvocatSuspect], i_LawyerAudience));
			rp_ClientXPIncrement(g_iTribunalData[type][td_AvocatSuspect], xp);
		}
	}
	
	Format(query, sizeof(query), "INSERT INTO `rp_audiences` (`id`, `juge`, `plaignant`, `suspect`, `avocat-plaignant`, `avocat-suspect`, `temps`, `condamne`, `charges`, `condamnation`, `heure`, `amende`, `dedommage`) VALUES(NULL,");
	Format(query, sizeof(query), "%s '%s', '%s', '%s', '%s', '%s', '%d', '%d', '%s', '%d', '%d', '%d', '%d');", query, szSteamID[0], szSteamID[1], szSteamID[2], szSteamID[3], szSteamID[4],
	g_iTribunalData[type][td_Time], condamne, charges, condamnation, heure, amende, dedommage);	
	SQL_TQuery(rp_GetDatabase(), SQL_QueryCallBack, query);
	
	if( condamne ) {
		
		if( IsValidClient(g_iTribunalData[type][td_Suspect]) && !g_bClientDisconnected[ g_iTribunalData[type][td_Suspect] ] ) {
			rp_ClientMoney(g_iTribunalData[type][td_Suspect], i_Bank, -amende);
			rp_SetClientInt(g_iTribunalData[type][td_Suspect], i_JailTime, rp_GetClientInt(g_iTribunalData[type][td_Suspect], i_JailTime) + (heure * 60));
			
			rp_SetClientInt(g_iTribunalData[type][td_Suspect], i_JailledBy, g_iTribunalData[type][td_Owner]);
			
			ServerCommand("rp_SendToJail %d", g_iTribunalData[type][td_Suspect]);
		}
		else {
		
			GetClientName(g_iTribunalData[type][td_Owner], nick, sizeof(nick));
			SQL_EscapeString(rp_GetDatabase(), nick, pseudo, sizeof(pseudo));
			
			int dedo = calculerDedo(type);
			
			Format(query, sizeof(query), "INSERT INTO `rp_users2` (`id`, `steamid`, `money`, `jail`, `pseudo`, `steamid2`, `raison`) VALUES (NULL,");
			Format(query, sizeof(query), "%s '%s', '%d', '%d', '%s', '%s', '%s');", query, szSteamID[2], - amende - dedo, heure * 60, pseudo, szSteamID[0], "condamné par le Tribunal"); 
			SQL_TQuery(rp_GetDatabase(), SQL_QueryCallBack, query);
			
			Format(query, sizeof(query), "INSERT INTO `rp_users2` (`id`, `steamid`, `money`, `pseudo`, `steamid2`, `raison`) VALUES (NULL,");
			Format(query, sizeof(query), "%s '%s', '%d', '%s', '%s', '%s');", query, szSteamID[1], dedo, pseudo, szSteamID[2], "dédommagement"); 
			SQL_TQuery(rp_GetDatabase(), SQL_QueryCallBack, query);
			
		}
	}
}
bool hasMercenaire() {
	for (int i = 1; i <= MaxClients; i++) {
		if( !IsValidClient(i) )
			continue;
		if( rp_GetClientJobID(i) == 41 ){
			if(rp_GetClientBool(i, b_IsAFK))
				continue;
			if(rp_GetClientInt(i, i_JailTime) > 0)
				continue;
			if(rp_GetZoneBit(rp_GetPlayerZone(i)) & BITZONE_EVENT)
				continue;
			return true;
		}
	}
	return false;
}
int calculerDedo(int type) {
	
	int amende;
	for (int i = 0; i < sizeof(g_szArticles); i++) {
		if( g_iArticles[type][i] <= 0 )
			continue;
		
		amende += (g_iArticles[type][i] * StringToInt(g_szArticles[i][4]));
	}
	return RoundToCeil(float(amende) * getAvocatRatio(g_iTribunalData[type][td_AvocatPlaignant])) + g_iTribunalData[type][td_Dedommagement2];
}
void calculerJail(int type, int& heure, int& amende) {
	for (int i = 0; i < sizeof(g_szArticles); i++) {
		if( g_iArticles[type][i] <= 0 )
			continue;
		heure += (g_iArticles[type][i] * StringToInt(g_szArticles[i][2]));
		amende += (g_iArticles[type][i] * StringToInt(g_szArticles[i][3]));
	}
}
float getAvocatRatio(int client) {
	int pay = rp_GetClientInt(client, i_Avocat);
	if (pay <= 0)	return 0.0;
	if (pay < 175)	return 0.5;
	if (pay < 300)	return 0.75;
	return 1.0;
	
}
int calculAudienceXp(int numb) {
	int value = 0;

	for(int i = 0; i < sizeof(g_iXpAudience); i++) {
		if(g_iXpAudience[i] <= numb)
			value = i;
	}

	if(value > 0) {
		value = g_iXpAudience[value] / 2;
	}

	return value;
}
// ----------------------------------------------------------------------------
public Action Cmd_ItemEnquete(int args) {
	
	int client = GetCmdArgInt(1);
	int target = GetCmdArgInt(2);
	char tmp[256];
	
	if( rp_GetClientJobID(client) == 101 ) {
		int type = GetTribunalType( rp_GetPlayerZone(client) );
		if( type > 0 ) {
			if( target == g_iTribunalData[type][td_Plaignant] )
				g_iTribunalData[type][td_EnquetePlaignant] = 1;
			if( target == g_iTribunalData[type][td_Suspect] )
				g_iTribunalData[type][td_EnqueteSuspect] = 1;
		}
	}
	
	
	
	rp_IncrementSuccess(client, success_list_detective);
	
	Handle menu = CreateMenu(MenuNothing);
	
	GetClientName2(target, tmp, sizeof(tmp), true);
	SetMenuTitle(menu, "%T\n ", "Enquete_MenuTarget", client, tmp); 
	
	PrintToConsole(client, "\n\n\n\n\n -------------------------------------------------------------------------------------------- ");
	
	rp_GetZoneData(rp_GetPlayerZone(target), zone_type_name, tmp, sizeof(tmp));
	
	AddMenu_Blank(client, menu, "%T", "Enquete_Localisation", client, tmp);
	
	int killedBy = rp_GetClientInt(target, i_LastKilled_Reverse);
	if( IsValidClient(killedBy) ) {
		
		if( rp_GetClientInt(target, i_SearchLVL) >= 4 ) {
			rp_SetClientInt(target, i_Cryptage, 0);
		}
		
		if( Math_GetRandomInt(1, 100) < rp_GetClientInt(target, i_Cryptage)*20 ) {
			
			String_GetRandom(tmp, sizeof(tmp), 24);
			
			AddMenu_Blank(client, menu, "%T", "Enquete_Killed", client, tmp);
			CPrintToChat(target, "" ...MOD_TAG... " %T", "PotDeVin_OwnKill", target);
			LogToGame("[TSX-RP] [ENQUETE] Une enquête effectuée sur %L n'a pas montré qui l'a tué pour cause de pot de vin.", target);
		}
		else {	
			GetClientName2(killedBy, tmp, sizeof(tmp), true);
			AddMenu_Blank(client, menu, "%T", "Enquete_Killed", client, tmp);
			LogToGame("[TSX-RP] [ENQUETE] Une enquête effectuée sur %L a montré qu'il a tué %L.", target, killedBy);
		}
	}
	else{
		LogToGame("[TSX-RP] [ENQUETE] Une enquête effectuée sur %L a révélé qu'il n'a tué personne", target, killedBy);
	}
	
	if( rp_GetClientInt(target, i_KillingSpread) > 0 )
		AddMenu_Blank(client, menu, "%T", "Enquete_KillingSpread", client, rp_GetClientInt(target, i_KillingSpread) );
	
	int killed = rp_GetClientInt(target, i_LastKilled);
	if( IsValidClient(killed) ) {
		
		if( rp_GetClientInt(killed, i_SearchLVL) >= 4 ) {
			rp_SetClientInt(killed, i_Cryptage, 0);
		}
		
		if( Math_GetRandomInt(1, 100) < rp_GetClientInt(killed, i_Cryptage)*20 ) {	
			
			String_GetRandom(tmp, sizeof(tmp), 24);
			
			AddMenu_Blank(client, menu, "%T", "Enquete_KilledBy", client, tmp);
			CPrintToChat(killed, "" ...MOD_TAG... " %T", "PotDeVin_OwnKill", target);
			LogToGame("[TSX-RP] [ENQUETE] Une enquête effectuée sur %L n'a pas montré qui l'a tué pour cause de pot de vin.", target);
		}
		else {
			GetClientName2(killed, tmp, sizeof(tmp), true);
			AddMenu_Blank(client, menu, "%T", "Enquete_KilledBy", client, tmp);
			LogToGame("[TSX-RP] [ENQUETE] Une enquête effectuée sur %L a montré que %L l'a tué.", target, killed);
		}
	}
	else{
		LogToGame("[TSX-RP] [ENQUETE] Une enquête effectuée sur %L a révélé qu'il n'a été tué par personne.", target, killed);
	}
	
	if( IsValidClient(rp_GetClientInt(target, i_LastVol)) && rp_GetClientInt(rp_GetClientInt(target, i_LastVol), i_LastVolAmount) > 25 ) {
		GetClientName2(rp_GetClientInt(target, i_LastVol), tmp, sizeof(tmp), true);
		if( rp_GetClientInt(rp_GetClientInt(target, i_LastVol), i_LastVolTarget) == client ) {
			AddMenu_Blank(client, menu, "%T", "Enquete_StealAmount", client, tmp, rp_GetClientInt(rp_GetClientInt(target, i_LastVol), i_LastVolAmount) );
		}
		else {
			AddMenu_Blank(client, menu, "%T", "Enquete_Steal", client, tmp);
		}
	}
	
	AddMenu_Blank(client, menu, "--------------------------------");
	
	AddMenu_Blank(client, menu, "%T", "Enquete_Knife", client, rp_GetClientInt(target, i_KnifeTrain));
	AddMenu_Blank(client, menu, "%T", "Enquete_Weapon", client, RoundToFloor(rp_GetClientFloat(target, fl_WeaponTrain)/8.0*100.0));
	AddMenu_Blank(client, menu, "%T", "Enquete_Money", client, rp_GetClientInt(target, i_Money)+rp_GetClientInt(target, i_Bank));	
	AddMenu_Blank(client, menu, "%T", "Enquete_Alcool", client, rp_GetClientFloat(client, fl_Alcool));
	
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_DURATION);
}

// ----------------------------------------------------------------------------
public Action Cmd_ItemEnqueteMenu(int args) {
	char arg1[12];
	GetCmdArg(1, arg1, 11);
	
	int client = StringToInt(arg1);
	
	Handle menu = CreateMenu(Cmd_ItemEnqueteMenu_2);
	SetMenuTitle(menu, "%T\n ", "Enquete_Menu", client);
	
	char name[128], tmp[64];
	GetClientName(client, name, 127);
	Format(tmp, 64, "%i", client);
	
	AddMenuItem(menu, tmp, name);
	
	for(int i = 1; i <= MaxClients; i++) {
		
		if( !IsValidClient(i) )
			continue;
		if( !IsClientConnected(i) )
			continue;
		if( i == client )
			continue;
		
		GetClientName(i, name, 127);
		Format(tmp, 64, "%i", i);
		
		AddMenuItem(menu, tmp, name);		
	}
	
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_DURATION);
}
public int Cmd_ItemEnqueteMenu_2(Handle p_hItemMenu, MenuAction p_oAction, int client, int p_iParam2) {
	if (p_oAction == MenuAction_Select) {
		
		char szMenuItem[64];
		if( GetMenuItem(p_hItemMenu, p_iParam2, szMenuItem, sizeof(szMenuItem)) ) {
			
			int target = StringToInt(szMenuItem);
			ServerCommand("rp_item_enquete \"%i\" \"%i\"", client, target);
		}		
	}
	else if (p_oAction == MenuAction_End) {
		CloseHandle(p_hItemMenu);
	}
}
public int MenuNothing(Handle menu, MenuAction action, int client, int param2) {
	
	if( action == MenuAction_Select ) {
		if( menu != INVALID_HANDLE )
			CloseHandle(menu);
	}
	else if( action == MenuAction_End ) {
		if( menu != INVALID_HANDLE )
			CloseHandle(menu);
	}
}
// ----------------------------------------------------------------------------
void AddMenu_Blank(int client, Handle menu, const char[] myString , any ...) {
	char[] str = new char[ strlen(myString)+255 ];
	VFormat(str, (strlen(myString)+255), myString, 4);
	
	AddMenuItem(menu, "none", str, ITEMDRAW_DISABLED);
	PrintToConsole(client, str);
}
