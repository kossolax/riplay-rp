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
#include <smlib>
#include <colors_csgo>

#pragma newdecls required
#include <roleplay.inc>	// https://www.ts-x.eu

StringMap g_hOpperation;
enum perquiz_data { PQ_client, PQ_zone, PQ_target, PQ_resp, PQ_type, PQ_timeout, PQ_Max};
int g_cBeam;
float g_flLastPos[65][3];
bool g_bCanOppe[65];
Handle g_hActive;

public Plugin myinfo = {
	name = "Utils: Perquisition", author = "KoSSoLaX",
	description = "RolePlay - Utils: Perquisition",
	version = __LAST_REV__, url = "https://www.ts-x.eu"
};
public void OnPluginStart() {
	LoadTranslations("core.phrases");
	LoadTranslations("roleplay.phrases");
	
	g_hActive 		= CreateConVar("rp_opperation", "0");
	g_hOpperation = new StringMap();
	
	for (int i = 1; i <= MaxClients; i++)
		if( IsValidClient(i) )
			OnClientPostAdminCheck(i);
}
public void OnMapStart() {
	g_cBeam = PrecacheModel("materials/effects/policeline.vmt"); // bandeau à changer 
}
public void OnClientPostAdminCheck(int client) {
	g_bCanOppe[client] = true;
	rp_HookEvent(client, RP_OnPlayerCommand, fwdCommand);
	rp_HookEvent(client, RP_OnPlayerZoneChange, fwdOnZoneChange);
}
// ----------------------------------------------------------------------------
public Action fwdOnZoneChange(int client, int newZone, int oldZone) {
	
	if( !g_bCanOppe[client] && (rp_GetClientJobID(client) == 91) ) {
		if( GetClientTeam(client) == CS_TEAM_T && rp_GetZoneInt(newZone, zone_type_type) == rp_GetClientJobID(client) ) {
			g_bCanOppe[client] = true;
			if( rp_GetClientInt(client, i_Job) >= 93)
				CPrintToChat(client, "" ...MOD_TAG... " Vous pouvez maintenant effectuer une oppération");
		}
	}
}
public Action fwdCommand(int client, char[] command, char[] arg) {
	if( StrContains(command, "oppe") == 0 || StrContains(command, "op") == 0 ) {
		return Cmd_Perquiz(client);
	}
	return Plugin_Continue;
}
public Action Cmd_Perquiz(int client) {
	
	if( rp_GetClientJobID(client) != 91) {
		ACCESS_DENIED(client);
	}
	if( rp_GetClientInt(client, i_Job) == 94 || rp_GetClientInt(client, i_Job) == 95 || rp_GetClientInt(client, i_Job) == 96) {
		ACCESS_DENIED(client);
	}
	if( GetClientTeam(client) != CS_TEAM_T ) {
		ACCESS_DENIED(client);
	}

	int[] array = new int[PQ_Max];
	float dst[3];
	char tmp[64], tmp2[64];
	rp_GetClientTarget(client, dst);
	rp_GetZoneData(rp_GetZoneFromPoint(dst), zone_type_type, tmp, sizeof(tmp));
	if( strlen(tmp) == 0 )
		return Plugin_Handled;
	
	if( !g_bCanOppe[client] && !g_hOpperation.GetArray(tmp, array, PQ_Max)) {
		CPrintToChat(client, "" ...MOD_TAG... " Vous devez retourner aux QG, avant de pouvoir planifier une autre oppétion.");
		return Plugin_Handled;
	}
	
	Menu menu = new Menu(MenuPerquiz);
	menu.SetTitle("Quel est le motif de perquisition?\n ");
	
	
	if( g_hOpperation.GetArray(tmp, array, PQ_Max) ) {
		Format(tmp2, sizeof(tmp2), "cancel %s", tmp);	menu.AddItem(tmp2, "Annuler la perquisition");
	}
	else {
		Format(tmp2, sizeof(tmp2), "trafic %s", tmp);	menu.AddItem(tmp2, "Taxe de protection impayé");
		Format(tmp2, sizeof(tmp2), "kidnap %s", tmp);	menu.AddItem(tmp2, "Un kidnappé");
	}
	menu.Display(client, MENU_TIME_FOREVER);
	
	return Plugin_Handled;
}
public int MenuPerquiz(Handle menu, MenuAction action, int client, int param2) {
	if( action == MenuAction_Select ) {
		char options[64], expl[4][32], tmp[64];
		GetMenuItem(menu, param2, options, sizeof(options));
		
		ExplodeString(options, " ", expl, sizeof(expl), sizeof(expl[]));
		
		float dst[3];
		rp_GetClientTarget(client, dst);
		int zone = rp_GetZoneFromPoint(dst);
		int nbRecherche = 0;
		rp_GetZoneData(zone, zone_type_type, tmp, sizeof(tmp));
		if( !StrEqual(tmp, expl[1]) )
			return 0;
		
		if(StrEqual(expl[0], "kidnap") ) {
			
			if( StringToInt(expl[2]) == 0 ) {
				Menu subMenu = new Menu(MenuPerquiz);
				
				for (int i = 1; i <= MaxClients; i++) {
					if( StrEqual(expl[0], "kidnap") && rp_GetClientInt(i, i_KidnappedBy) == 0 )
						continue;
					
					rp_GetZoneData(rp_GetPlayerZone(i), zone_type_type, options, sizeof(options));
					if( !StrEqual(options, expl[1]) )
						continue;
					
					Format(options, sizeof(options), "%s %s %d", expl[0], expl[1], i);
					Format(tmp, sizeof(tmp), "%N", i);
					
					int vehicle = Client_GetVehicle(i);
					Entity_GetAbsOrigin(vehicle > 0 ? vehicle : i, g_flLastPos[i]);
					
					subMenu.AddItem(options, tmp);
					nbRecherche++;
				}
					
				subMenu.Display(client, MENU_TIME_FOREVER);// a tester
				g_bCanOppe[client] = false;
			}
		}
		else if( StrEqual(expl[0], "trafic") ) {
			int weapon, machine, plant;
			
			countBadThing(expl[1], weapon, plant, machine);
			
			g_bCanOppe[client] = false;
			
			if( weapon > 3 || machine > 1 || plant > 1)
				INIT_OPPE(client, zone, 0, 0);
			else
				CPrintToChat(client, "" ...MOD_TAG... " Cette planque est sous la protection de la police, mieux vaut éviter.");
				
		}
		else if( StrEqual(expl[0], "cancel") ) {
			END_OPPE(zone, true);
		}
	}
	else if( action == MenuAction_End ) {
		CloseHandle(menu);
	}
	return 0;
}
// ----------------------------------------------------------------------------
void INIT_OPPE(int client, int zone, int target, int type) {	
	
	char tmp[64], query[512];
	int resp = 0;
	rp_GetZoneData(zone, zone_type_type, tmp, sizeof(tmp));
	int[] array = new int[PQ_Max];
	
	if( g_hOpperation.GetArray(tmp, array, PQ_Max) )
		return;
	if( isZoneInOppe(zone) )
		return;

	if( type == 0) {
		resp = GetPerquizResp(zone, true);
		if( resp == 0 )
			GetPerquizResp(zone, false);
	}

	setPerquizData(client, zone, target, resp, type, 0);
	
	Format(query, sizeof(query), "SELECT `time` FROM `rp_oppe` WHERE `type`='%s' AND `job_id`='%d' AND `zone`='%s' ORDER BY `time` DESC;", target > 0 ? "search" : "trafic", rp_GetClientJobID(client), tmp);
	
	SQL_TQuery(rp_GetDatabase(), VERIF_OPPE, query, zone);
}
public void VERIF_OPPE(Handle owner, Handle row, const char[] error, any zone) {
	
	char tmp[64];
	rp_GetZoneData(zone, zone_type_type, tmp, sizeof(tmp));
	int[] array = new int[PQ_Max];
	
	if( !g_hOpperation.GetArray(tmp, array, PQ_Max) )
		return;
	if( isZoneInOppe(zone) )
		return;
	
	int cd = getCooldown(array[PQ_client], zone);
	if( row != INVALID_HANDLE && SQL_FetchRow(row) ) {
		
		if( SQL_FetchInt(row, 0) + cd > GetTime() ) {
			g_bCanOppe[array[PQ_client]] = true;
			
			CPrintToChat(array[PQ_client], "" ...MOD_TAG... " Impossible programmer une oppération ici avant %d minutes.", ((SQL_FetchInt(row, 0) + cd - GetTime())/60) + 1);
			g_hOpperation.Remove(tmp);
			return;
		}
	}
	
	SetConVarInt(g_hActive, GetConVarInt(g_hActive) + 1);
	changeZoneState(zone, true);
	
	if( array[PQ_target] == 0 ) {
		CreateTimer(1.0, TIMER_OPPE_LOOKUP, zone, TIMER_REPEAT);
	}
	else {	
		START_OPPE(zone);
	}
}
void START_OPPE(int zone) {
	int[] array = new int[PQ_Max];
	char tmp[64];
	rp_GetZoneData(zone, zone_type_type, tmp, sizeof(tmp));
	
	if( !g_hOpperation.GetArray(tmp, array, PQ_Max) ) {
		return;
	}
	
	if( array[PQ_resp] == 0 && IsValidClient(array[PQ_target]) )
		array[PQ_resp] = array[PQ_target];
		
	array[PQ_timeout] = 0;
	updateOppeData(zone, array);
	
	
	rp_GetZoneData(zone, zone_type_name, tmp, sizeof(tmp));
	LogToGame("[OPPE] Une oppération est lancée dans %s.", tmp);
	
	PrintToChatPoliceZone(zone, "{red} =================================={default} ");
	if( array[PQ_target] == 0 )
		PrintToChatPoliceZone(zone, ""... MOD_TAG ..." {red}[MAFIA]{default} %s est maintenant sous notre contrôle, fuyez ou payez si vous voulez vivre.", tmp, array[PQ_resp]);
	PrintToChatPoliceZone(zone, "{red} =================================={default} ");	
	
	if( IsValidClient(array[PQ_target]) ) {
		rp_HookEvent(array[PQ_target], RP_OnPlayerDead, fwdHookDead);
		rp_HookEvent(array[PQ_target], RP_PreClientSendToJail, fwdHookJail);
	}
	CreateTimer(1.0, TIMER_OPPE, zone, TIMER_REPEAT);
	
	ServerCommand("rp_sick 0"); // Pas de maladie en oppe
}
public Action ChangeZoneSafe(Handle timer, any zone) {
	changeZoneState(zone, false);
}
void END_OPPE(int zone, bool abort) {
	int[] array = new int[PQ_Max];
	char tmp[64], date[64], query[512];
	rp_GetZoneData(zone, zone_type_type, tmp, sizeof(tmp));
	
	if( !g_hOpperation.GetArray(tmp, array, PQ_Max) ) {
		return;
	}
	g_hOpperation.Remove(tmp);
	CreateTimer(10.0, ChangeZoneSafe, zone);
	TeleportCT(zone);
	DoorLock(zone);
	SetConVarInt(g_hActive, GetConVarInt(g_hActive) - 1);
	
	if( IsValidClient(array[PQ_target]) ) {
		rp_UnhookEvent(array[PQ_target], RP_OnPlayerDead, fwdHookDead);
		rp_UnhookEvent(array[PQ_target], RP_PreClientSendToJail, fwdHookJail);
	}
	
	rp_GetDate(date, sizeof(date));
	
	rp_GetZoneData(zone, zone_type_name, tmp, sizeof(tmp));
	LogToGame("[OPPE] Une oppération c'est terminée dans %s.", tmp);
	PrintToChatPoliceZone(zone, "{red} =================================={default} ");
	PrintToChatPoliceZone(zone, "{red}"... MOD_TAG ..." [MAFIA]{default} On à eu ce qu'on voulait, à plus les loosers !");
	PrintToChatPoliceZone(zone, "{red} =================================={default} ");
	
	if( !abort ) {
		rp_GetZoneData(zone, zone_type_type, tmp, sizeof(tmp));
		GetClientAuthId(array[PQ_client], AUTH_TYPE, date, sizeof(date));
		Format(query, sizeof(query), "INSERT INTO `rp_oppe` (`id`, `zone`, `time`, `steamid`, `type`, `job_id`) VALUES (NULL, '%s', UNIX_TIMESTAMP(), '%s', '%s', '%d');", tmp, date, array[PQ_target] > 0 ? "search" : "trafic", rp_GetClientJobID(array[PQ_client]));
		SQL_TQuery(rp_GetDatabase(), SQL_QueryCallBack, query);
		
		rp_ClientMoney(array[PQ_client], i_AddToPay, 500);
	}
	else if( abort ) {
		rp_GetZoneData(zone, zone_type_type, tmp, sizeof(tmp));
		GetClientAuthId(array[PQ_client], AUTH_TYPE, date, sizeof(date));
		Format(query, sizeof(query), "INSERT INTO `rp_oppe` (`id`, `zone`, `time`, `steamid`, `type`, `job_id`) VALUES (NULL, '%s', UNIX_TIMESTAMP()-%d, '%s', '%s', '%d');", tmp, getCooldown(array[PQ_client], zone)*60+6*60, date, array[PQ_target] > 0 ? "search" : "trafic", rp_GetClientJobID(array[PQ_client]));
		SQL_TQuery(rp_GetDatabase(), SQL_QueryCallBack, query);
	}
	
	ServerCommand("rp_sick 1"); // On remet la maladie à la fin
}
// ----------------------------------------------------------------------------
public Action fwdHookJail(int attacker, int victim) {
	char tmp[64];
	int zone = rp_GetZoneFromPoint(g_flLastPos[victim]);
	int[] array = new int[PQ_Max];
	rp_GetZoneData( zone, zone_type_type, tmp, sizeof(tmp));
	
	if( !g_hOpperation.GetArray(tmp, array, PQ_Max) ) {
		rp_UnhookEvent(victim, RP_PreClientSendToJail, fwdHookJail);
	}
	
	END_OPPE(zone, false);
	
	return Plugin_Continue;
}
public Action fwdHookDead(int victim, int attacker, float& respawn, int& tdm, float& ctx) {
	char tmp[64];
	int zone = rp_GetZoneFromPoint(g_flLastPos[victim]);
	int[] array = new int[PQ_Max];
	rp_GetZoneData( zone, zone_type_type, tmp, sizeof(tmp));
	
	if( !g_hOpperation.GetArray(tmp, array, PQ_Max) ) {
		rp_UnhookEvent(victim, RP_OnPlayerDead, fwdHookDead);
	}
	
	if( array[PQ_type] != 2 ) {
		ServerCommand("rp_SendToJail %d %d", victim, array[PQ_client]);
		rp_SetClientInt(victim, i_JailTime, (rp_GetClientInt(victim, i_JailTime) + 6 * 60));
		END_OPPE(zone, false);
	}
	else
		END_OPPE(zone, true);
	
	CreateTimer(0.1, task_respawn, victim);
	
	
	
	return Plugin_Continue;
}
public Action task_respawn(Handle timer, any client) {
	rp_ClientRespawn(client);
}
public Action TIMER_OPPE(Handle timer, any zone) {
	int[] array = new int[PQ_Max];
	char tmp[64], tmp2[64];
	rp_GetZoneData(zone, zone_type_type, tmp, sizeof(tmp));
	
	if( !g_hOpperation.GetArray(tmp, array, PQ_Max) ) {
		return Plugin_Stop;
	}
	
	changeZoneState(zone, true);
	
	if( array[PQ_target] > 0 ) {
		if( !IsValidClient(array[PQ_target]) ) {
			END_OPPE(zone, true);
			return Plugin_Stop;
		}
		
		if( array[PQ_type] == 2 && rp_GetClientInt(array[PQ_target], i_KidnappedBy) == 0 ) {
			END_OPPE(zone, false);
			return Plugin_Stop;
		}
		
		rp_GetZoneData( rp_GetPlayerZone(array[PQ_target]) , zone_type_type, tmp2, sizeof(tmp2));
		if( !StrEqual(tmp, tmp2) ) {		
			rp_ClientTeleport(array[PQ_target], g_flLastPos[array[PQ_target]]);
		}
		else {
			int vehicle = Client_GetVehicle(array[PQ_target]);
			Entity_GetAbsOrigin(vehicle > 0 ? vehicle : array[PQ_target], g_flLastPos[array[PQ_target]]);
		}
	}
	else {
		int weapon, machine, plant;
			
		countBadThing(tmp, weapon, plant, machine);
		if( (weapon + plant + machine) == 0 ) {
			END_OPPE(zone, false);
			return Plugin_Stop;
		}
	}
	
	if( !hasCopInZone(zone) ) {
		array[PQ_timeout] = 0;
	}
	else {
		array[PQ_timeout]++;
		
		if( array[PQ_timeout] == 30 ) {
			rp_GetZoneData(zone, zone_type_name, tmp, sizeof(tmp));
			PrintToChatPoliceZone(zone, "{red} =================================={default} ");
			PrintToChatPoliceZone(zone, "{red}"... MOD_TAG ..." [MAFIA]{default} Les poulets prennent du terrain, BOUGEZ-VOUS !", tmp);
			PrintToChatPoliceZone(zone, "{red} =================================={default} ");
		}
		else if( array[PQ_timeout] >= 40 ) {
			END_OPPE(zone, true);
			return Plugin_Stop;
		}
	}
	
	updateOppeData(zone, array);
	Effect_DrawPerqui(zone);
	
	return Plugin_Continue;
}
public Action TIMER_OPPE_LOOKUP(Handle timer, any zone) {
	int[] array = new int[PQ_Max];
	char tmp[64], tmp2[64];
	rp_GetZoneData(zone, zone_type_type, tmp, sizeof(tmp));
	
	if( !g_hOpperation.GetArray(tmp, array, PQ_Max) ) {
		return Plugin_Stop;
	}
	
	if ( !IsValidClient(array[PQ_resp]) ) {
		array[PQ_resp] = GetPerquizResp(zone, true);
		if( array[PQ_resp] == 0 )
			GetPerquizResp(zone, false);
	}

	bool canStart = (array[PQ_timeout] >= 60 || !IsValidClient(array[PQ_resp]));
	
	if( IsValidClient(array[PQ_resp]) ) {
		
		rp_GetZoneData(zone, zone_type_type, tmp, sizeof(tmp));
		rp_GetZoneData(rp_GetPlayerZone(array[PQ_resp]), zone_type_type, tmp2, sizeof(tmp2));
		
		if( StrEqual(tmp, tmp2) )
			canStart = true;
	}
	
	
	if( canStart ) {
		START_OPPE(zone);
		return Plugin_Stop;
	}
	array[PQ_timeout]++;
	
	updateOppeData(zone, array);
	Effect_DrawPerqui(zone);
	return Plugin_Continue;
}
// ----------------------------------------------------------------------------
int GetPerquizResp(int zone, bool afkCheck) {
	char tmp[64];
	rp_GetZoneData(zone, zone_type_type, tmp, sizeof(tmp));
	
	if( StrEqual(tmp, "bunker") )
		return GetPerquizRespByGroup( rp_GetCaptureInt(cap_bunker), afkCheck);
	else if( StrEqual(tmp, "villa") )
		return GetPerquizRespByGroup( rp_GetCaptureInt(cap_villa), afkCheck);
	else if( StrEqual(tmp, "mairie") )
		return GetPerquizRespMaire(); 
	else if( StrContains(tmp, "appart_") == 0 ) {
		ReplaceString(tmp, sizeof(tmp), "appart_", "");
		return GetPerquizRespByAppart(StringToInt(tmp), afkCheck);
	}
	else
		return GetPerquizRespByJob(StringToInt(tmp), afkCheck);
}
int GetPerquizRespByAppart(int appartID, bool afkCheck) {
	int zone;
	int res = 0;
	int owner = rp_GetAppartementInt(appartID, appart_proprio);
	
	for(int i=1; i<=MaxClients; i++) {
		if( !IsValidClient(i) )
			continue;
		if( afkCheck && rp_GetClientBool(i, b_IsAFK) )
			continue;
		zone = rp_GetZoneBit(rp_GetPlayerZone(i));
		
		if( owner == i )
			return i;
		
		if( zone & (BITZONE_JAIL|BITZONE_LACOURS|BITZONE_HAUTESECU) )
			continue;
		
		if( rp_GetClientKeyAppartement(i, appartID)  )
			res = i;
	}
	return res;
}
int GetPerquizRespByJob(int job_id, bool afkCheck) {
	int zone;	
	int min = 9999;
	int res = 0;
	
	for(int i=1; i<=MaxClients; i++) {
		if( !IsValidClient(i) )
			continue;
		if( afkCheck && rp_GetClientBool(i, b_IsAFK) )
			continue;
		zone = rp_GetZoneBit(rp_GetPlayerZone(i));
		
		if( zone & (BITZONE_JAIL|BITZONE_LACOURS|BITZONE_HAUTESECU) )
			continue;
		
		if( job_id == rp_GetClientJobID(i) && min > rp_GetClientInt(i, i_Job) ) {
			min = rp_GetClientInt(i, i_Job);
			res = i;
		}
	}
	
	
	return res;
}
int GetPerquizRespByGroup(int gang_id, bool afkCheck) {
	int zone;	
	int min = 9999;
	int res = 0;
	
	for(int i=1; i<=MaxClients; i++) {
		if( !IsValidClient(i) )
			continue;
		if( afkCheck && rp_GetClientBool(i, b_IsAFK) )
			continue;
		zone = rp_GetZoneBit(rp_GetPlayerZone(i));
		
		if( zone & (BITZONE_JAIL|BITZONE_LACOURS|BITZONE_HAUTESECU) )
			continue;
		
		if( gang_id == rp_GetClientGroupID(i) && min > rp_GetClientInt(i, i_Group) ) {
			min = rp_GetClientInt(i, i_Job);
			res = i;
		}
	}
	
	
	return res;
}
int GetPerquizRespMaire() {
	char tmp[32], tmp2[32];
	rp_GetServerString(mairieID, tmp, sizeof(tmp));
	
	for(int i=1; i<=MaxClients; i++) {
		if( !IsValidClient(i) )
			continue;
		
		GetClientAuthId(i, AUTH_TYPE, tmp2, sizeof(tmp2));
		if( StrEqual(tmp, tmp2) )
			return i;
	}
	
	return 0;
}
// ----------------------------------------------------------------------------
void Effect_DrawPerqui(int zone) {
	float min[3], max[3];
	char tmp[64], tmp2[64];
	rp_GetZoneData(zone, zone_type_type, tmp, sizeof(tmp));
	
	for (int i = 0; i < MAX_ZONES; i++) {
		
		rp_GetZoneData(i, zone_type_type, tmp2, sizeof(tmp2));
		if( !StrEqual(tmp, tmp2) )
			continue;
		
		min[0] = rp_GetZoneFloat(i, zone_type_min_x) - 16.0;
		min[1] = rp_GetZoneFloat(i, zone_type_min_y) - 16.0;
		min[2] = rp_GetZoneFloat(i, zone_type_min_z) - 16.0;
		
		max[0] = rp_GetZoneFloat(i, zone_type_max_x) + 16.0;
		max[1] = rp_GetZoneFloat(i, zone_type_max_y) + 16.0;
		max[2] = rp_GetZoneFloat(i, zone_type_max_z) + 16.0;
		
		Effect_DrawPane(min, max, RoundFloat((max[2] - min[2]) / 128.0), tmp);
	}
}
void Effect_DrawPane(float bottomCorner[3], float upperCorner[3], int subDivision, char tmp[64]) {
	float corners[8][3], start[3], end[3], median[3];
	char tmp2[64];
	
	for (int i=0; i < 4; i++) {
		Array_Copy(bottomCorner,	corners[i],		3);
		Array_Copy(upperCorner,		corners[i+4],	3);
	}

	corners[1][0] = upperCorner[0];
	corners[2][0] = upperCorner[0]; 
	corners[2][1] = upperCorner[1];
	corners[3][1] = upperCorner[1];
	corners[4][0] = bottomCorner[0]; 
	corners[4][1] = bottomCorner[1];
	corners[5][1] = bottomCorner[1];
	corners[7][0] = bottomCorner[0];

    // Draw all the edges
	// Horizontal Lines
	// Bottom
	for (int i=0; i < 4; i++) {
		int j = ( i == 3 ? 0 : i+1 );
		
		for (int k = 0; k <= 2; k++) {
			start[k] = corners[i][k];
			end[k] = corners[j][k];
		}
		
		for (int k = 0; k < subDivision; k++) {
			start[2] = end[2] = bottomCorner[2] + (  (upperCorner[2] - bottomCorner[2]) / (subDivision+1) * (k+1) );
			
			for (int h = 0; h <= 2; h++)
				median[h] = (start[h] + end[h]) / 2.0;
			
			rp_GetZoneData(rp_GetZoneFromPoint(median), zone_type_type, tmp2, sizeof(tmp2));
			
			if( StrEqual(tmp, tmp2) )
				continue;
			
			TE_SetupBeamPoints(end, start, g_cBeam, 0, 0, 0, 1.0, 8.0, 8.0, 0, 0.0, {255, 255, 0, 128}, 0);
			TE_SendToAll();
		}
	}
}
// ----------------------------------------------------------------------------
void DoorLock(int zone) {
	char tmp[64], tmp2[64];
	rp_GetZoneData(zone, zone_type_type, tmp, sizeof(tmp));
	
	for (int i = MaxClients; i <= MAX_ENTITIES; i++) {
		if( !rp_IsValidDoor(i) )
			continue;
		
		rp_GetZoneData(rp_GetPlayerZone(i), zone_type_type, tmp2, sizeof(tmp2));
		
		if( StrEqual(tmp, tmp2) ) {
			rp_AcceptEntityInput(i, "Close");
			rp_AcceptEntityInput(i, "Lock");
		}
	}
}
bool isZoneInOppe(int zone) {
	char tmp[64], tmp2[64];
	rp_GetZoneData(zone, zone_type_type, tmp, sizeof(tmp));
	
	for (int i = 0; i < MAX_ZONES; i++) {
		
		rp_GetZoneData(i, zone_type_type, tmp2, sizeof(tmp2));
		if( !StrEqual(tmp, tmp2) )
			continue;
		
		if( rp_GetZoneBit(i) & BITZONE_PERQUIZ )
			return true;
		return false;
	}
	
	return false;
}
void changeZoneState(int zone, bool enabled) {
	int bits;
	bool changed = false;
	char tmp[64], tmp2[64];
	rp_GetZoneData(zone, zone_type_type, tmp, sizeof(tmp));
	
	for (int i = 0; i < MAX_ZONES; i++) {
		
		rp_GetZoneData(i, zone_type_type, tmp2, sizeof(tmp2));
		if( !StrEqual(tmp, tmp2) )
			continue;
		
		bits = rp_GetZoneBit(i);
		changed = false;
		
		if( enabled && !(bits & BITZONE_PERQUIZ) ) {
			bits |= BITZONE_PERQUIZ;
			changed = true;
		}
		else if( !enabled && (bits & BITZONE_PERQUIZ) ) {
			bits &= ~BITZONE_PERQUIZ;
			changed = true;
		}
		
		if( changed )
			rp_SetZoneBit(i, bits);
	}
	
	float vecOrigin[3];
	
	for (int i = 1; i <= 2048; i++) {
		if( !IsValidEdict(i) )
			continue;
		if( !IsValidEntity(i) )
			continue;
		
		GetEdictClassname(i, tmp, sizeof(tmp));
		
		if( StrEqual(tmp, "rp_plant") || StrEqual(tmp, "rp_cashmachine") || StrEqual(tmp, "rp_bigcashmachine") ) {
			
			Entity_GetAbsOrigin(i, vecOrigin);
			vecOrigin[2] += 16.0;
			
			rp_GetZoneData(rp_GetZoneFromPoint(vecOrigin), zone_type_type, tmp2, sizeof(tmp2));
			if( !StrEqual(tmp, tmp2) )
				continue;
			
			SetEntProp(i, Prop_Data, "m_takedamage", enabled ? 0 : 2);
		}
	}
}
// ----------------------------------------------------------------------------
void setPerquizData(int client, int zone, int target, int resp, int type, int timeout) {
	char tmp[64];
	rp_GetZoneData(zone, zone_type_type, tmp, sizeof(tmp));
	
	int[] array = new int[PQ_Max];
	
	array[PQ_client] = client;
	array[PQ_zone] = zone;
	array[PQ_target] = target;
	array[PQ_resp] = resp;
	array[PQ_type] = type;
	array[PQ_timeout] = timeout;
	
	g_hOpperation.SetArray(tmp, array, PQ_Max);
}
void updateOppeData(int zone, int[] array) {
	char tmp[64];
	rp_GetZoneData(zone, zone_type_type, tmp, sizeof(tmp));
	
	g_hOpperation.SetArray(tmp, array, PQ_Max);
}
// ----------------------------------------------------------------------------
void countBadThing(char[] zone, int& weapon, int& plant, int& machine) {
	char tmp[64], tmp2[64];
	
	float vecOrigin[3];
	
	for (int i = MaxClients; i <= MAX_ENTITIES; i++) {
		if( !IsValidEdict(i) || !IsValidEntity(i) )
			continue;
		
		GetEdictClassname(i, tmp, sizeof(tmp));
		if( StrContains(tmp, "weapon_") == -1 && StrContains(tmp, "rp_") == -1 )
			continue;
		if( StrContains(tmp, "snowball") >= 0 )
			continue;
		
		Entity_GetAbsOrigin(i, vecOrigin);
		vecOrigin[2] += 16.0;
		
		rp_GetZoneData(rp_GetZoneFromPoint(vecOrigin), zone_type_type, tmp2, sizeof(tmp2));
		if( StrEqual(tmp2, "14") )
			tmp2[1] = '1';
		
		if( !StrEqual(tmp2, zone) )
			continue;
		
		if( StrContains(tmp, "weapon_") == 0 && StrContains(tmp, "knife") == -1 &&  Weapon_GetOwner(i) <= 0 )
			weapon++;
		if( StrContains(tmp, "rp_plant") == 0 )
			plant++;
		if( StrContains(tmp, "rp_cash") == 0 )
			machine++;
		if( StrContains(tmp, "rp_bigcash") == 0 )
			machine+=15;
	}
	
}
void TeleportCT(int zone) {
	char tmp[64], tmp2[64];
	rp_GetZoneData(zone, zone_type_type, tmp, sizeof(tmp));
	
	for (int i = 1; i <= MaxClients; i++) {
		if( !IsValidClient(i) || !IsPlayerAlive(i) )
			continue;
		if( GetClientTeam(i) == CS_TEAM_T )
			continue;
		rp_GetZoneData(rp_GetPlayerZone(i), zone_type_type, tmp2, sizeof(tmp2));
		
		if( StrEqual(tmp, tmp2) ) {
			rp_ClientSendToSpawn(i, true);
			rp_ClientColorize(i);
		}
	}
}
int getCooldown(int client, int zone) {
	char tmp[64];
	rp_GetZoneData(zone, zone_type_type, tmp, sizeof(tmp));
	
	if( rp_GetClientJobID(client) == 1 && (StrEqual(tmp, "bunker") || StrEqual(tmp, "villa") || StrEqual(tmp, "appart_50") || StrEqual(tmp, "appart_51") ) )
		//return 6 * 60 * 60;
		return 1 * 60;
	else if( rp_GetClientJobID(client) == 101 && (StrEqual(tmp, "bunker") || StrEqual(tmp, "villa") || StrEqual(tmp, "appart_50") || StrEqual(tmp, "appart_51") ) )
		//return 1 * 60 * 60;
		return 1 * 60;
	else
		//return 24 * 60;
		return 1 * 60;
}
bool hasCopInZone(int zone) {
	char tmp[64], tmp2[64];
	rp_GetZoneData(zone, zone_type_type, tmp, sizeof(tmp));
	
	for (int i = 1; i <= MaxClients; i++) {
		if( !IsValidClient(i) || !IsPlayerAlive(i) )
			continue;
		if( GetClientTeam(i) == CS_TEAM_T )
			continue;
		if( rp_GetClientInt(i, i_KidnappedBy) > 0 )
			continue;
		if( GetPlayerWeaponSlot(i, CS_SLOT_PRIMARY) <= 0 &&  GetPlayerWeaponSlot(i, CS_SLOT_SECONDARY) <= 0 )
			continue;
		
		rp_GetZoneData(rp_GetPlayerZone(i), zone_type_type, tmp2, sizeof(tmp2));
		if( StrEqual(tmp, tmp2) )
			return true;
	}
	return false;
}