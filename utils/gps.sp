#pragma semicolon 1

#include <sourcemod>
#include <smlib>
#include <colors_csgo>
#include <socket>
#include <roleplay>

#pragma newdecls required

public Plugin myinfo = {
	name = "gps backend", author = "KoSSoLaX",
	description = "gps data backend",
	version = "1.0", url = "https://www.ts-x.eu"
};

#define	MAX_NODE	1024
#define MAX_ARC		MAX_NODE*2
#define SERV_IP		"5.196.39.48"
//#define SERV_IP		"109.88.12.57"

Handle g_hBDD, g_Socket, g_hShow[65];
char g_szQuery[1024];
float g_flNode[MAX_NODE][3];
int g_iArc[MAX_ARC][4], g_cLaser, g_cBeam, g_iMarked[65];
int g_iTarget[65];
Handle g_hTimer[65];
char loadNode[] = "SELECT `id`, `x`, `y`, `z` FROM `fireblue`.`rp_gps_node`;";
char loadArc[] = "SELECT A.`id`, `src`, `dst`, `length`, length(`zone_type`) as `private` FROM `fireblue`.`rp_gps_arc` A INNER JOIN `rp_csgo`.`rp_location_zones` Z ON Z.`id`=A.`zoneID`;";

public void OnPluginStart() {
	
	RegAdminCmd("rp_gps_edit",	CmdGpsMenu, ADMFLAG_ROOT);
	RegServerCmd("sm_effect_gps", 		CmdGps);	
	
	CreateTimer(0.1, SocketInit);
	
	for (int i = 1; i <= MaxClients; i++)
		if( IsValidClient(i) )
			OnClientPostAdminCheck(i);
}
public Action SocketInit(Handle timer, any omg) {
	g_Socket = SocketCreate(SOCKET_TCP, view_as<SocketErrorCB>(OnSocketError));
	SocketConnect(g_Socket, view_as<SocketConnectCB>(OnSocketConnected), view_as<SocketReceiveCB>(OnSocketReceive), view_as<SocketDisconnectCB>(OnSocketDisconnected), SERV_IP, 9090);
}
public void OnClientPostAdminCheck(int client) {
	rp_HookEvent(client, RP_OnPlayerCommand, fwdCommand);
}
public Action fwdCommand(int client, char[] command, char[] arg) {
	
	if( StrEqual(command, "gps") ) {
		CmdGps2(client);
		return Plugin_Handled;
	}
	return Plugin_Continue;
}
// ----------------------------------------- DATABASE
public void OnMapStart() {
	g_cLaser = PrecacheModel("materials/vgui/hud/icon_arrow_up.vmt");
	g_cBeam = PrecacheModel("materials/sprites/laserbeam.vmt");
	
	
	g_hBDD = SQL_Connect("rp_gps", true, g_szQuery, sizeof(g_szQuery));
	if (g_hBDD == INVALID_HANDLE) {
		SetFailState("Connexion impossible: %s", g_szQuery);
	}
	SQL_TQuery(g_hBDD, SQL_LoadNode, loadNode);
	SQL_TQuery(g_hBDD, SQL_LoadArc, loadArc);
}
public void SQL_LoadNode(Handle owner, Handle hQuery, const char[] error, any none) {
	int i;
	while( SQL_FetchRow(hQuery) ) {
		i = SQL_FetchInt(hQuery, 0);
		
		g_flNode[i][0] = SQL_FetchFloat(hQuery, 1);
		g_flNode[i][1] = SQL_FetchFloat(hQuery, 2);
		g_flNode[i][2] = SQL_FetchFloat(hQuery, 3);
	}
}
public void SQL_LoadArc(Handle owner, Handle hQuery, const char[] error, any none) {
	int i;
	while( SQL_FetchRow(hQuery) ) {
		i = SQL_FetchInt(hQuery, 0);
		
		g_iArc[i][0] = SQL_FetchInt(hQuery, 1);
		g_iArc[i][1] = SQL_FetchInt(hQuery, 2);
		g_iArc[i][2] = SQL_FetchInt(hQuery, 3);
		g_iArc[i][3] = SQL_FetchInt(hQuery, 4);
	}
}
// ----------------------------------------- EVENT
public void OnMapEnd() {
	CloseHandle(g_hBDD);
}
public void OnSocketConnected(Handle hSock, any blah) {
	SocketSetOption(hSock, SocketKeepAlive, true);
}
public void OnSocketDisconnected(Handle hSock, any blah) {
	CloseHandle(hSock);
	CreateTimer(1.0, SocketInit);
}
public void OnSocketError(Handle hSock, const int errorType, const int errorNum, any blah) {
	CloseHandle(hSock);
	CreateTimer(1.0, SocketInit);
}
// ----------------------------------------- EDITION
public Action CmdGpsMenu(int client, int args) {
	Menu menu = new Menu(MenuGps);
	menu.SetTitle("Gestion du GPS");
	
	menu.AddItem("addNode", "Ajouter un noeud");
	menu.AddItem("delNode", "Supprimer un noeud");
	
	menu.AddItem("markNode", "Marquer ce noeud");
	menu.AddItem("addArc", "Ajouter un arc");
	menu.AddItem("delArc", "Supprimer un arc");
	
	menu.AddItem("fermer", "Fermer");
	menu.ExitButton = false;
	menu.Display(client, MENU_TIME_FOREVER);
	
	if( !g_hShow[client] )
		g_hShow[client] = CreateTimer(0.25, frameShowGraph, client, TIMER_REPEAT);
	return Plugin_Handled;
}
public Action frameShowGraph(Handle timer, any client) {
	if( timer != g_hShow[client] )
		return Plugin_Handled;
	
	float myself[3], start[3], stop[3];
	GetClientAbsOrigin(client, myself);
	int nearest = findNearestNode(myself);
	
	for (int i = 1; i < MAX_NODE; i++) {
		if( g_flNode[i][0] == 0.0 && g_flNode[i][1] == 0.0 && g_flNode[i][2] == 0.0 )
			continue;
					
		start = g_flNode[i];
		stop = g_flNode[i];
		start[2] -= 32.0;
		stop[2] += 32.0;
		
		if( GetVectorDistance(myself, start) > 2048.0 )
			continue;
		
		if( g_iMarked[client] == i ) 
			tracePath(client, start, stop, { 255, 0, 0, 128}, 0.26, 8.0);
		else if( nearest == i )
			tracePath(client, start, stop, { 255, 255, 0, 128}, 0.26, 8.0);
		else
			tracePath(client, start, stop, { 0, 255, 0, 128}, 0.26, 8.0);
	}
	for (int i = 1; i < MAX_ARC; i++) {
		if( g_iArc[i][0] == 0 && g_iArc[i][1] == 0 && g_iArc[i][2] == 0 )
			continue;
				
		start = g_flNode[g_iArc[i][0]];
		stop = g_flNode[g_iArc[i][1]];
		
		if( GetVectorDistance(myself, start) > 1024.0 && GetVectorDistance(myself, stop) > 1024.0 )
			continue;
			
		start[2] += 32.0;
		stop[2] += 32.0;
		
		if( g_iArc[i][3] > 0 )
			tracePath(client, start, stop, { 128, 0, 255, 128}, 0.26, 4.0);
		else
			tracePath(client, start, stop, { 0, 0, 255, 128}, 0.26, 4.0);
	}
	return Plugin_Handled;
}
public int MenuGps(Handle menu, MenuAction action, int client, int param2) {
	if (action == MenuAction_Select) {
		char szMenu[64];
		
		char steamID[64];
		GetClientAuthId(client, AuthId_Engine, steamID, sizeof(steamID));
			
		if( GetMenuItem(menu, param2, szMenu, sizeof(szMenu)) ) {
			
			if( StrEqual(szMenu, "addNode") ) {
				float vec[3];
				GetClientAbsOrigin(client, vec);
				vec[2] += 32.0;
				
				Format(g_szQuery, sizeof(g_szQuery), "INSERT INTO `fireblue`.`rp_gps_node` (`id`, `x`, `y`, `z`, `zoneID`) VALUES (NULL, '%d', '%d', '%d', '%d');", 
				RoundFloat(vec[0]), RoundFloat(vec[1]), RoundFloat(vec[2]), rp_GetZoneFromPoint(vec));
				
				SQL_TQuery(g_hBDD, SQL_QueryCallBack, g_szQuery, 0);
				SQL_TQuery(g_hBDD, SQL_LoadNode, loadNode);
			}
			else if( StrEqual(szMenu, "markNode") ) {
				
				float pos[3];
				GetClientAbsOrigin(client, pos);
				
				g_iMarked[client] = findNearestNode(pos);
				PrintToChat(client, "%d", g_iMarked[client]);
			}
			else if( StrEqual(szMenu, "addArc") ) {
				
				float pos[3];
				GetClientAbsOrigin(client, pos);
				
				int start = g_iMarked[client];
				int end = findNearestNode(pos);
				int dst = RoundFloat( GetVectorDistance(g_flNode[start], g_flNode[end]) );
				
				Format(g_szQuery, sizeof(g_szQuery), "INSERT INTO `fireblue`.`rp_gps_arc` (`id`, `src`, `dst`, `length`, `zoneID`) VALUES (NULL, '%d', '%d', '%d', '%d');", 
				start, end, dst, rp_GetZoneFromPoint(g_flNode[start]));
				
				SQL_TQuery(g_hBDD, SQL_QueryCallBack, g_szQuery, 0);
				SQL_TQuery(g_hBDD, SQL_LoadArc, loadArc);
			}
			else if( StrEqual(szMenu, "fermer") ) {
				delete g_hShow[client];
				return 0;
			}
			ClientCommand(client, "rp_gps_edit");
		}
	}
	else if (action == MenuAction_End) {
		CloseHandle(menu);
	}
	return 0;
}
// ----------------------------------------- SEND
public Action CmdGps(int args) {
	char tmp[64];
	int client = GetCmdArgInt(1);
	int target = 0;
	float src[3], dst[3];
	GetClientAbsOrigin(client, src);
		
	
	if( args == 2 ) {
		target = GetCmdArgInt(2);
		
		client = (client <= MaxClients && rp_GetClientVehicle(client) > 0 ? rp_GetClientVehicle(client) : client);
		client = (client <= MaxClients && rp_GetClientVehiclePassager(client) > 0 ? rp_GetClientVehiclePassager(client) : client);
		
		target = (target <= MaxClients && rp_GetClientVehicle(target) > 0 ? rp_GetClientVehicle(target) : target);
		target = (target <= MaxClients && rp_GetClientVehiclePassager(target) > 0 ? rp_GetClientVehiclePassager(target) : target);
		
		Entity_GetAbsOrigin(target, dst);
		
	}
	else if( args == 4 ) {
		dst[0] = GetCmdArgFloat(2);
		dst[1] = GetCmdArgFloat(3);
		dst[2] = GetCmdArgFloat(4);
	}
	else {
		return Plugin_Handled;
	}
	
	Format(tmp, sizeof(tmp), "%d;%d,%d,%d;%d,%d,%d\n", client,
			RoundFloat(src[0]), RoundFloat(src[1]), RoundFloat(src[2]),
			RoundFloat(dst[0]), RoundFloat(dst[1]), RoundFloat(dst[2]));
	SocketSend(g_Socket, tmp);
	
	return Plugin_Handled;
}
public Action CmdGps2(int client) {
	
	Menu menu = CreateMenu(handleMenu);
	menu.SetTitle("Ou souhaitez-vous allez?");
	
	if( g_hTimer[client] ) {
		menu.AddItem("0", "Arrêter le guidage");
	}
	
	menu.AddItem("12", "Le commissariat");
	menu.AddItem("121", "L'hôpital");
	menu.AddItem("289", "Le tribunal");
	menu.AddItem("118", "La banque");
	menu.AddItem("247", "La villa de la mafia");
	
	menu.AddItem("100", "L'armurerie");
	menu.AddItem("90", "Les coachs");
	menu.AddItem("101", "La planque technicien");
	
	menu.AddItem("272", "La planque des artisans");
	menu.AddItem("266", "L'agence immobilière");
	menu.AddItem("298", "Le concessionaire");
	
	menu.AddItem("226", "La planque des mercenaires");
	menu.AddItem("95", "La planque des dealers");
	menu.AddItem("222", "La planque des artificiers");
	//menu.AddItem("236", "Le sexshop");
	
	menu.AddItem("69", "Le mcdonald");
	menu.AddItem("299", "Le casino");
	menu.AddItem("172", "La planque des vendeurs de skin");
	
	menu.AddItem("6", "Le bar Le-Requin");
	menu.AddItem("3", "La discothèque");
	
	menu.Display(client, MENU_TIME_FOREVER);
	
	return Plugin_Handled;

}
public int handleMenu(Handle p_hItemMenu, MenuAction p_oAction, int client, int p_iParam2) {
	if (p_oAction == MenuAction_Select) {
		
		char szMenuItem[64];
		if( GetMenuItem(p_hItemMenu, p_iParam2, szMenuItem, sizeof(szMenuItem)) ) {
			
			g_iTarget[client] = StringToInt(szMenuItem);
			if( g_hTimer[client] )
				delete g_hTimer[client];
			
			if( g_iTarget[client] > 0 ) {
				CreateTimer(0.1, BASH_GPS, client);
				g_hTimer[client] = CreateTimer(1.0, BASH_GPS, client, TIMER_REPEAT);
			}
		}		
	}
	else if (p_oAction == MenuAction_End) {
		CloseHandle(p_hItemMenu);
	}
}
public Action BASH_GPS(Handle timer, any client) {
	if (g_iTarget[client] == 0) { g_hTimer[client] = null; return Plugin_Stop; }
	if( !IsValidClient(client) ) { g_hTimer[client] = null; return Plugin_Stop; }
	if( rp_GetPlayerZone(client) == g_iTarget[client] ) { g_hTimer[client] = null; return Plugin_Stop; }
	
	float min[3], max[3], src[3], dst[3];
	GetClientAbsOrigin(client, src);
	min[0] = rp_GetZoneFloat(g_iTarget[client], zone_type_min_x);
	min[1] = rp_GetZoneFloat(g_iTarget[client], zone_type_min_y);
	min[2] = rp_GetZoneFloat(g_iTarget[client], zone_type_min_z);
	max[0] = rp_GetZoneFloat(g_iTarget[client], zone_type_max_x);
	max[1] = rp_GetZoneFloat(g_iTarget[client], zone_type_max_y);
	max[2] = rp_GetZoneFloat(g_iTarget[client], zone_type_max_z);
	dst[0] = (min[0] + max[0]) / 2.0;
	dst[1] = (min[1] + max[1]) / 2.0;
	dst[2] = (min[2] + max[2]) / 2.0;
	
	
	char tmp[64];
	Format(tmp, sizeof(tmp), "%d;%d,%d,%d;%d,%d,%d\n", client,
		RoundFloat(src[0]), RoundFloat(src[1]), RoundFloat(src[2]),
		RoundFloat(dst[0]), RoundFloat(dst[1]), RoundFloat(dst[2]));
	SocketSend(g_Socket, tmp);
	return Plugin_Continue;
}
// ----------------------------------------- GET
public void OnSocketReceive(Handle hSock, char[] receiveData, const int dataSize, any blah) {
	static char data[64][256], split[5][128], buff[MAX_NODE][12];
	static int client, lineCount, length, color[4];
	static float src[3], dst[3];
	
	// Data = X\nY\nZ
	// split = X;Y;Z
	// split[0] = client
	// split[1] = src intersection	X,Y,Z
	// split[2] = chemin			a,b,c,d,e,f
	// split[3] = dst intersection	X,Y,Z
	// split[4] = dst 				X,Y,Z
	// buff = X,Y,Z
	
	lineCount = ExplodeString(receiveData, "\n", data, sizeof(data), sizeof(data[]));
	for(int i=0;i<lineCount;i++) {
		if( strlen(data[i]) < 8 )
			continue;
		
		ExplodeString(data[i], ";", split, sizeof(split), sizeof(split[]));
		ExplodeStringToVector(split[1], buff, sizeof(buff), sizeof(buff[]), dst);
			
		client = StringToInt(split[0]);
		if( !IsValidClient(client) )
			continue;
		GetClientAbsOrigin(client, src);		
		src[2] += 32.0;
		//Math_GetRandomVector(color, sizeof(color)-1);
		color[0] = color[1] = color[2] = color[3] = 255;
		
		if( strlen(split[2]) > 0 ) {
			
			traceBeam(client, src, dst, color); // src = dst;
			length = ExplodeString(split[2], ",", buff, sizeof(buff), sizeof(buff[]));
			
			for(int j = 0; j <= length-1; j++) {
				dst = g_flNode[StringToInt(buff[j])];
				traceBeam(client, src, dst, color); // src = dst;
			}
			
			ExplodeStringToVector(split[3], buff, sizeof(buff), sizeof(buff[]), dst);
			traceBeam(client, src, dst, color); // src = dst;
		}
		else {
			
			traceBeam(client, src, dst, color); // src = dst;
			ExplodeStringToVector(split[3], buff, sizeof(buff), sizeof(buff[]), dst);
			traceBeam(client, src, dst, color); // src = dst;
		}
		ExplodeStringToVector(split[4], buff, sizeof(buff), sizeof(buff[]), dst);
		traceBeam(client, src, dst, color);
	}
}
void ExplodeStringToVector(char[] str, char[][] buff, int size, int size2, float res[3]) {
	ExplodeString(str, ",", buff, size, size2);
	res[0] = StringToFloat(buff[0]);
	res[1] = StringToFloat(buff[1]);
	res[2] = StringToFloat(buff[2]) + 32.0;
}
void traceBeam(int client, float src[3], float dst[3], int color[4]) {
	TE_SetupBeamPoints(dst, src, g_cLaser, g_cLaser, 0, 10, 1.0, 12.0, 12.0, 0, 0.0, color, 10);
	TE_SendToClient(client);
	src = dst;
}
void tracePath(int client, float src[3], float dst[3], int color[4], float duration=1.0, float size=16.0) {
	TE_SetupBeamPoints(dst, src, g_cBeam, g_cBeam, 0, 0, duration, size, size, 0, 0.0, color, 0);
	TE_SendToClient(client);
	src = dst;
}	
// ----------------------------------------- UTILS
void Math_GetRandomVector(int[] vec, int size) {
	for (int i = 0; i < size; i++) {
		vec[i] = Math_GetRandomInt(0, 255);
	}
}
int findNearestNode(float pos[3]) {
	float min = 9999999.9, tmp;
	int id = -1;
	
	for (int i = 0; i < MAX_NODE; i++) {
		if( g_flNode[i][0] == 0.0 && g_flNode[i][1] == 0.0 && g_flNode[i][2] == 0.0 )
			continue;
		
		tmp = GetVectorDistance(g_flNode[i], pos);
		if( tmp < min ) {
			min = tmp;
			id = i;
		}
	}
	return id;
}
