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
#include <sdktools> 
#include <cstrike>
#include <colors_csgo>   // https://forums.alliedmods.net/showthread.php?p=2205447#post2205447
#include <smlib>      // https://github.com/bcserv/smlib
#include <emitsoundany> // https://forums.alliedmods.net/showthread.php?t=237045

#pragma newdecls required
#include <roleplay.inc>   // https://www.ts-x.eu

#define		USING_VEHICLE
#define		QUEST_UNIQID   	"braquage"
#define		QUEST_NAME      "Braquage"
#define		QUEST_TYPE     	quest_group
#define		QUEST_TEAMS			5

#define		TEAM_NAME1			"Braqueur"
#define 	REQUIRED_T			4
#define 	REQUIRED_CT			5
#define		SUPPLEMENT_T		12

#define		BRAQUAGE_WEAPON		"weapon_p90"

#define		TEAM_NONE			0
#define		TEAM_INVITATION		1
#define		TEAM_BRAQUEUR		2
#define		TEAM_BRAQUEUR_DEAD	3
#define		TEAM_POLICE			4
#define		TEAM_HOSTAGE		5


public Plugin myinfo =  {
	name = "Quête: "...QUEST_NAME, author = "KoSSoLaX", 
	description = "RolePlay - Quête "...QUEST_NAME, 
	version = __LAST_REV__, url = "https://www.ts-x.eu"
};

Handle g_hActive;
int g_iQuest;
bool g_bDoingQuest, g_bByPassDoor, g_bHasHelmet, g_bCanMakeQuest;
#if defined USING_VEHICLE
int g_iVehicle;
#endif

int g_iPlanque, g_iPlanqueZone, g_iQuestGain, g_iLastPlanque[4];
int g_iPlayerTeam[2049], g_stkTeam[QUEST_TEAMS + 1][MAXPLAYERS + 1], g_stkTeamCount[QUEST_TEAMS + 1], g_iJobs[MAX_JOBS], g_iMask[MAXPLAYERS + 1];

public void OnPluginStart() {
	g_iLastPlanque[0] = 71;
	g_iLastPlanque[1] = 111;
	g_iLastPlanque[2] = 131;
	g_iLastPlanque[3] = 221;
	
	RegServerCmd("rp_quest_reload", Cmd_PluginReloadSelf);
	
	HookEvent("hostage_follows", EV_PickupHostage, EventHookMode_Post);
	HookEvent("hostage_rescued", EV_RescuseHostage, EventHookMode_Post);
	
	g_hActive 		= CreateConVar("rp_braquage", "0");
}
public void OnAllPluginsLoaded() {
	g_iQuest = rp_RegisterQuest(QUEST_UNIQID, QUEST_NAME, QUEST_TYPE, fwdCanStart);
	if (g_iQuest == -1)
		SetFailState("Erreur lors de la création de la quête %s %s", QUEST_UNIQID, QUEST_NAME);
		
	int i;
	rp_QuestAddStep(g_iQuest, i++, Q1_Start,	Q1_Frame,	Q_Abort, QUEST_NULL);
#if defined USING_VEHICLE
	rp_QuestAddStep(g_iQuest, i++, Q2_Start,	Q2_Frame,	Q_Abort, QUEST_NULL);
#endif
	rp_QuestAddStep(g_iQuest, i++, QUEST_NULL,	Q3_Frame,	Q_Abort, QUEST_NULL);
	rp_QuestAddStep(g_iQuest, i++, Q4_Start,	Q4_Frame,	Q_Abort, QUEST_NULL);
	rp_QuestAddStep(g_iQuest, i++, Q5_Start,	Q5_Frame,	Q_Abort, QUEST_NULL);

#if defined USING_VEHICLE
	rp_QuestAddStep(g_iQuest, i++, Q6_Start,	Q6_Frame,	Q_Abort, QUEST_NULL);
	rp_QuestAddStep(g_iQuest, i++, QUEST_NULL,	Q7_Frame,	Q_Abort, Q_Complete);
#else
	rp_QuestAddStep(g_iQuest, i++, Q6_Start,	Q6_Frame,	Q_Abort, Q_Complete);
#endif

	g_bCanMakeQuest = true;
}
public void OnMapStart() {
	PrecacheSoundAny("ui/beep22.wav");
}
public Action RP_OnSentryAttack(int entity, int target) {
	int client = Entity_GetOwner(entity);
	
	if( g_bDoingQuest ) {
		if( rp_GetZoneInt(rp_GetPlayerZone(entity), zone_type_type) == g_iPlanque ) {
			if( (g_iPlayerTeam[client] == TEAM_BRAQUEUR || g_iPlayerTeam[client] == TEAM_BRAQUEUR_DEAD) && !(g_iPlayerTeam[target] == TEAM_POLICE) ) {
				return Plugin_Stop;
			}
			
			if( (g_iPlayerTeam[client] == TEAM_POLICE) && !(g_iPlayerTeam[target] == TEAM_BRAQUEUR || g_iPlayerTeam[target] == TEAM_BRAQUEUR_DEAD) ) {
				return Plugin_Stop;
			}
		}
	}
	
	return Plugin_Continue;
}

// ----------------------------------------------------------------------------
public bool fwdCanStart(int client) {
	if( g_bDoingQuest == true )
		return false;
	if( g_bCanMakeQuest == false )
		return false;
	
	if( GetClientCount() < REQUIRED_T+REQUIRED_CT && GetConVarInt(FindConVar("hostport")) != 27025 )
		return false;
	if( rp_GetClientJobID(client) == 1 || rp_GetClientJobID(client) == 101 )
		return false;
	if( rp_GetClientInt(client, i_PlayerLVL) < 210 )
		return false;
	if( GetGameTime() < 60.0*30.0 && GetConVarInt(FindConVar("hostport")) != 27025 )
		return false;
	/*
	char szDayOfWeek[12], szHours[12];
	FormatTime(szDayOfWeek, 11, "%w");
	FormatTime(szHours, 11, "%H");
	if( StringToInt(szDayOfWeek) == 3 ) { // Mercredi
		if( StringToInt(szHours) >= 17 && StringToInt(szHours) < 19  ) {	// 18h00m00s
			return false;
		}
	}
	if( StringToInt(szDayOfWeek) == 5 ) { // Vendredi
		if( StringToInt(szHours) >= 20 && StringToInt(szHours) < 22) {	// 21h00m00s
			return false;
		}
	}
	*/
	int ct = 0;
	int t = 0;
	for (int i = 1; i <= MaxClients; i++) {
		if( !IsValidClient(i) )
			continue;
		if( i == client )
			continue;
		if( rp_GetClientBool(i, b_IsAFK) )
			continue;
		if( policeMatch(i) )
			ct++;
		if( rp_GetClientInt(i, i_PlayerLVL) >= 132 )
			t++;
	}
	
	if( ct < REQUIRED_CT )
		return false;
	if( t < REQUIRED_T )
		return false;
	
	return true;
}
// ----------------------------------------------------------------------------
public void Q_Abort(int objectiveID, int client) {
	
	for (int i = 0; i < g_stkTeamCount[TEAM_BRAQUEUR]; i++) {
		if( client != g_stkTeam[TEAM_BRAQUEUR][i] )
			rp_QuestComplete(g_stkTeam[TEAM_BRAQUEUR][i], QUEST_UNIQID, false);
	}
	
	for (int i = 0; i < g_stkTeamCount[TEAM_BRAQUEUR_DEAD]; i++) {		
		if( client != g_stkTeam[TEAM_BRAQUEUR_DEAD][i] )
			rp_QuestComplete(g_stkTeam[TEAM_BRAQUEUR_DEAD][i], QUEST_UNIQID, false);
	}
	
	for (int i = 0; i < g_stkTeamCount[TEAM_POLICE]; i++) {
		if( client != g_stkTeam[TEAM_POLICE][i] )
			rp_QuestComplete(g_stkTeam[TEAM_POLICE][i], QUEST_UNIQID, true);
	}
	
	Q_Clean();
}
void Q_Clean() {
	for (int i = 0; i < g_stkTeamCount[TEAM_HOSTAGE]; i++) {
		rp_ScheduleEntityInput(g_stkTeam[TEAM_HOSTAGE][i], 0.1, "Kill");
	}
	
	if( g_bHasHelmet ) {
		for (int i = 1; i <= MaxClients; i++) {
			if( !IsValidClient(i) )
				continue;
			rp_UnhookEvent(i, RP_OnPlayerDead, fwdDead);
			rp_UnhookEvent(i, RP_PreGiveDamage, fwdDamage);
			rp_UnhookEvent(i, RP_PreClientTeleport, fwdTeleport);
			rp_UnhookEvent(i, RP_PreClientSendToJail, fwdSendToJail);
			rp_UnhookEvent(i, RP_OnPlayerZoneChange, fwdZoneChangeTUTO);
			rp_UnhookEvent(i, RP_PlayerCanKill, fwdCanKill);
			rp_UnhookEvent(i, RP_OnPlayerHear, fwdHear);
			
			
			if( g_iPlayerTeam[i] == TEAM_BRAQUEUR ) {
				LogToGame("[BRAQUAGE] [FIN] %L est un braqueur et a été clean.", i);
				
				SetEntProp(i, Prop_Send, "m_bHasHelmet", 0);
				rp_UnhookEvent(i, RP_OnPlayerUse, fwdPressUse);
				rp_ClientResetSkin(i);
			}
		}
	}
	if( g_bByPassDoor ) {
		for (int i = 1; i <= MaxClients; i++) {
			if( !IsValidClient(i) )
				continue;
			rp_UnhookEvent(i, RP_OnPlayerCheckKey, fwdGotKey);
		}
	}
	
	g_bByPassDoor = false;
	g_bHasHelmet = false;
	g_bDoingQuest = false;
	g_stkTeamCount[TEAM_HOSTAGE] = 0;
	for (int i = 1; i <= MaxClients; i++) {
		if( IsValidClient(i) ) {
			SetEntProp(i, Prop_Send, "m_bIsGrabbingHostage", 0);
			removeClientTeam(i);
		}
	}
	CreateTimer(60.0 * 60.0, braquageNewAttempt);
	SetConVarInt(g_hActive, 0);
	
	changeZoneState(g_iPlanque, false);
	
	g_iLastPlanque[0] = g_iLastPlanque[1];
	g_iLastPlanque[1] = g_iLastPlanque[2];
	g_iLastPlanque[2] = g_iLastPlanque[3];
	g_iLastPlanque[3] = g_iPlanque;
	g_iPlanque = 0;
}
public Action braquageNewAttempt(Handle timer, any attempt) {
	g_bCanMakeQuest = true;
}
public void Q1_Start(int objectiveID, int client) {
	g_bDoingQuest = true;
	g_bCanMakeQuest = false;
	g_iVehicle = 0;
	addClientToTeam(client, TEAM_BRAQUEUR);
	LogToGame("[BRAQUAGE] %L a lancé un braquage", client);
}
public void Q1_Frame(int objectiveID, int client) {
	if( g_stkTeamCount[TEAM_BRAQUEUR] >= requiredTForCT() ) {
		rp_QuestStepComplete(client, objectiveID);
		return;
	}
	for (int i = 0; i < g_stkTeamCount[TEAM_INVITATION]; i++) {
		DrawMenu_Invitation(client, g_stkTeam[TEAM_INVITATION][i]);
	}
	PrintHintText(client, "Quête: %s\nObjectif: Inviter des collègues.", QUEST_NAME);
	
	if( rp_ClientCanDrawPanel(client) ) {
		char tmp[64], tmp2[64];		
		Menu menu = new Menu(MenuInviterBraqueur);
		menu.SetTitle("Quète: %s", QUEST_NAME);
		menu.AddItem("refresh", "Actualiser le menu");
		menu.AddItem("", "Braqueur confirmé:", ITEMDRAW_DISABLED);
		for (int i = 0; i < g_stkTeamCount[TEAM_BRAQUEUR]; i++) {
			Format(tmp, sizeof(tmp), "%N", g_stkTeam[TEAM_BRAQUEUR][i]);
			menu.AddItem("", tmp, ITEMDRAW_DISABLED);
		}
		
		menu.AddItem("", "Braqueur en attente:", ITEMDRAW_DISABLED);
		for (int i = 0; i < g_stkTeamCount[TEAM_INVITATION]; i++) {
			Format(tmp, sizeof(tmp), "%d", g_stkTeam[TEAM_INVITATION][i]);
			Format(tmp2, sizeof(tmp2), "%N", g_stkTeam[TEAM_INVITATION][i]);
			menu.AddItem(tmp, tmp2);
		}
		
		if( g_stkTeamCount[TEAM_BRAQUEUR]+g_stkTeamCount[TEAM_INVITATION] < requiredTForCT() ) {
			menu.AddItem("", "Envoyer invitation:", ITEMDRAW_DISABLED);
			for (int i = 1; i <= MaxClients; i++) {
				if( !IsValidClient(i) )
					continue;
				if( g_iPlayerTeam[i] != TEAM_POLICE && (rp_GetClientJobID(i) == 1 || rp_GetClientJobID(i) == 101) ) {
					addClientToTeam(i, TEAM_POLICE);
					continue;
				}
				if( g_iPlayerTeam[i] == TEAM_POLICE && rp_GetClientJobID(i) != 1 && rp_GetClientJobID(i) != 101 ) {
					removeClientTeam(i);
				}
				if( g_iPlayerTeam[i] != TEAM_NONE )
					continue;
				if( rp_GetClientBool(i, b_IsMuteEvent) == true )
					continue;
				if( rp_GetClientInt(i, i_JailTime) > 0 )
					continue;
				if( rp_GetClientInt(i, i_PlayerLVL) < 132 )
					continue;
				
				Format(tmp, sizeof(tmp), "%d", i);
				Format(tmp2, sizeof(tmp2), "%N", i);
				menu.AddItem(tmp, tmp2);
			}
		}
		menu.ExitButton = false;
		menu.Display(client, 30);
	}
}
#if defined USING_VEHICLE
public void Q2_Start(int objectiveID, int client) {
	g_iVehicle = spawnVehicle(client);
	
	int seed = GetRandomInt(0, 7);
	for (int i = 0; i < g_stkTeamCount[TEAM_BRAQUEUR]; i++) {
		g_iMask[g_stkTeam[TEAM_BRAQUEUR][i]] = ((seed + i) % 8) + 1;
		attachMask(client, false);
	}
}
public void Q2_Frame(int objectiveID, int client) {
	if( !rp_IsValidVehicle(g_iVehicle) ) { g_iVehicle = spawnVehicle(client); }
	
	bool allIn = true;
	
	for (int i = 0; i < g_stkTeamCount[TEAM_BRAQUEUR]; i++) {
		if( allIn ) allIn = isInVehicle(g_stkTeam[TEAM_BRAQUEUR][i]);
		ServerCommand("sm_effect_gps %d %d", g_stkTeam[TEAM_BRAQUEUR][i], g_iVehicle);
		PrintHintText(g_stkTeam[TEAM_BRAQUEUR][i], "Quête: %s\nObjectif: Récupérer la voiture blindée.", QUEST_NAME);
	}
	
	if( allIn )
		rp_QuestStepComplete(client, objectiveID);
}
#endif
int g_iQ3 = -1;
public void Q3_Frame(int objectiveID, int client) {
	
	PrintHintText(client, "Quête: %s\nObjectif: Choisir le lieu du braquage.", QUEST_NAME);
	
	if( rp_ClientCanDrawPanel(client) ) {
		char tmp[64], tmp2[2][64];
		Menu menu = new Menu(MenuSelectPlanque);
		menu.SetTitle("Quète: %s", QUEST_NAME);
		
		if( g_iJobs[31] == 0 ) {
			g_iQ3 = objectiveID;
			for (int i = 1; i < MAX_ZONES; i++) {
				int job = rp_GetZoneInt(i, zone_type_type);
				if( job <= 0 || job >= MAX_JOBS || job == 1 || job == 14 || job == 101 )
					continue;
				if( g_iJobs[job] > 0 )
					continue;
				g_iJobs[job] = i;
			}
		}
		
		int jobToDeny = -1;
		if( rp_GetServerRules(rules_Braquages, rules_Enabled) == 1 ) {
			jobToDeny = rp_GetServerRules(rules_Braquages, rules_Target);
		}
		
		for (int i = 1; i < MAX_JOBS; i+=10) {
			if( g_iJobs[i] == 0 )
				continue;
			if( i == g_iLastPlanque[0] || i == g_iLastPlanque[1] || i == g_iLastPlanque[2] || i == g_iLastPlanque[3] )
				continue;
			if( i == jobToDeny )
				continue;
			
			rp_GetZoneData(g_iJobs[i], zone_type_name, tmp, sizeof(tmp));
			ExplodeString(tmp, ": ", tmp2, sizeof(tmp2), sizeof(tmp2[]));
			Format(tmp, sizeof(tmp), "%d", g_iJobs[i]);
			Format(tmp2[0], sizeof(tmp2[]), "%s %d$", tmp2[0], (rp_GetJobCapital(i) / 1000) + (g_stkTeamCount[TEAM_POLICE] * 2500));
			menu.AddItem(tmp, tmp2[0]);
		}
		
		menu.ExitButton = false;
		menu.Display(client, 30);
	}
}
public void Q4_Start(int objectiveID, int client) {
	for (int i = 1; i<=MaxClients; i++)
		if( IsValidClient(i) )
			rp_HookEvent(i, RP_OnPlayerCheckKey, fwdGotKey);
	
	changeZoneState(g_iPlanque, true);
	g_bByPassDoor = true;
}
public void Q4_Frame(int objectiveID, int client) {
	bool allIn = true;
	float min[3], max[3], pos[3];
	char tmp[64], tmp2[2][64];
	min[0] = rp_GetZoneFloat(g_iPlanqueZone, zone_type_min_x);
	min[1] = rp_GetZoneFloat(g_iPlanqueZone, zone_type_min_y);
	min[2] = rp_GetZoneFloat(g_iPlanqueZone, zone_type_min_z);
	max[0] = rp_GetZoneFloat(g_iPlanqueZone, zone_type_max_x);
	max[1] = rp_GetZoneFloat(g_iPlanqueZone, zone_type_max_y);
	max[2] = rp_GetZoneFloat(g_iPlanqueZone, zone_type_max_z);
	rp_GetZoneData(g_iPlanqueZone, zone_type_name, tmp, sizeof(tmp));
	ExplodeString(tmp, ": ", tmp2, sizeof(tmp2), sizeof(tmp2[]));
	
	for (int i = 0; i <= 2; i++)
		pos[i] = (min[i] + max[i]) / 2.0;
		
	for (int i = 0; i < g_stkTeamCount[TEAM_BRAQUEUR]; i++) {
		bool inside = (rp_GetZoneInt(rp_GetPlayerZone(g_stkTeam[TEAM_BRAQUEUR][i]), zone_type_type) == g_iPlanque);
		if (allIn) allIn = inside;
		if( !inside ) ServerCommand("sm_effect_gps %d %f %f %f", g_stkTeam[TEAM_BRAQUEUR][i], pos[0], pos[1], pos[2]);
		
		PrintHintText(g_stkTeam[TEAM_BRAQUEUR][i], "Quête: %s\nObjectif: Entrez tous dans: %s.", QUEST_NAME, tmp2[0]);
	}
	
	if( allIn )
		rp_QuestStepComplete(client, objectiveID);
}
public void Q5_Start(int objectiveID, int client) {
	updateTeamPolice();
	g_bHasHelmet = true;
	g_iQuestGain = 0;
	
	for (int i = 0; i < g_stkTeamCount[TEAM_BRAQUEUR]; i++) {
		if( Client_GetWeaponBySlot(g_stkTeam[TEAM_BRAQUEUR][i], CS_SLOT_PRIMARY) < 0 ) {
			int wepid = GivePlayerItem(g_stkTeam[TEAM_BRAQUEUR][i], BRAQUAGE_WEAPON);
			FakeClientCommand(g_stkTeam[TEAM_BRAQUEUR][i], "use " ... BRAQUAGE_WEAPON);
			Weapon_SetPrimaryClip(wepid, 5000);
			rp_SetWeaponBallType(wepid, ball_type_braquage);
		}
		if( Client_GetWeaponBySlot(g_stkTeam[TEAM_BRAQUEUR][i], CS_SLOT_SECONDARY) < 0 ) {
			int wepid = GivePlayerItem(g_stkTeam[TEAM_BRAQUEUR][i], "weapon_revolver");
			rp_SetWeaponBallType(wepid, ball_type_braquage);
		}
		
		LogToGame("[BRAQUAGE] [DEBUT] %L est dans l'équipe des braqueurs.", g_stkTeam[TEAM_BRAQUEUR][i]);
		
		SetEntityHealth(g_stkTeam[TEAM_BRAQUEUR][i], 500);
		rp_SetClientInt(g_stkTeam[TEAM_BRAQUEUR][i], i_Kevlar, 250);
		SetEntProp(g_stkTeam[TEAM_BRAQUEUR][i], Prop_Send, "m_bHasHelmet", 1);
		rp_HookEvent(g_stkTeam[TEAM_BRAQUEUR][i], RP_OnPlayerUse, fwdPressUse);
		attachMask(g_stkTeam[TEAM_BRAQUEUR][i], true);
	}
	for (int i = 0; i < g_stkTeamCount[TEAM_POLICE]; i++) {
		LogToGame("[BRAQUAGE] [DEBUT] %L est dans l'équipe de la police.", g_stkTeam[TEAM_POLICE][i]);
	}
	
	for (int i = 1; i <= MaxClients; i++) {
		if( !IsValidClient(i) )
			continue;
		rp_HookEvent(i, RP_OnPlayerDead, fwdDead);
		rp_HookEvent(i, RP_PreGiveDamage, fwdDamage);
		rp_HookEvent(i, RP_PreClientTeleport, fwdTeleport);
		rp_HookEvent(i, RP_PreClientSendToJail, fwdSendToJail);
		rp_HookEvent(i, RP_OnPlayerZoneChange, fwdZoneChangeTUTO);
		rp_HookEvent(i, RP_PlayerCanKill, fwdCanKill);
		rp_HookEvent(i, RP_OnPlayerHear, fwdHear);
	}
}
public Action fwdHear(int client, int target, float& dist) {
	
	bool clientB = (g_iPlayerTeam[client] == TEAM_BRAQUEUR || g_iPlayerTeam[client] == TEAM_BRAQUEUR_DEAD);
	bool targetB = (g_iPlayerTeam[target] == TEAM_BRAQUEUR || g_iPlayerTeam[target] == TEAM_BRAQUEUR_DEAD);
	
	if( clientB && targetB ) {
		dist = 1.0;
		return Plugin_Continue;
	}
	if( g_iPlayerTeam[client] == TEAM_POLICE && g_iPlayerTeam[target] == TEAM_POLICE ) {
		dist = 1.0;
		return Plugin_Continue;
	}
	
	return Plugin_Continue;
}
public Action fwdCanKill(int attacker, int victim) {
	if( g_iPlayerTeam[attacker] == TEAM_BRAQUEUR && rp_GetZoneInt(rp_GetPlayerZone(victim), zone_type_type) == g_iPlanque )
		return Plugin_Handled;
	if( g_iPlayerTeam[attacker] == TEAM_BRAQUEUR && g_iPlayerTeam[victim] == TEAM_POLICE )
		return Plugin_Handled;
	if( g_iPlayerTeam[attacker] == TEAM_POLICE && g_iPlayerTeam[victim] == TEAM_BRAQUEUR )
		return Plugin_Handled;
	
	return Plugin_Continue;
}
public void Q5_Frame(int objectiveID, int client) {
	char tmp[64], tmp2[2][64];
	rp_GetZoneData(g_iPlanqueZone, zone_type_name, tmp, sizeof(tmp));
	ExplodeString(tmp, ": ", tmp2, sizeof(tmp2), sizeof(tmp2[]));
	
	int cpt = countPlayerInZone(g_iPlanque);
	if( cpt == 0 ) {
		rp_QuestStepComplete(client, objectiveID);
	}
	else {
		for (int i = 0; i < g_stkTeamCount[TEAM_BRAQUEUR]; i++) {
			PrintHintText(g_stkTeam[TEAM_BRAQUEUR][i], "Quête: %s\nObjectif: Soyez seul dans %s.\n Il reste %d personne%s.", QUEST_NAME, tmp2[0], cpt, (cpt>1?"s":""));
		}
	}
}
public void Q6_Start(int objectiveID, int client) {
	
	updateTeamPolice();
	g_iQuestGain = 1000;
	g_stkTeamCount[TEAM_HOSTAGE] = 0;
	
	for (float i = 0.0; i <= 30.0; i += 1.5) {
		CreateTimer(i, tskAlarm);
	}
}
public void Q6_Frame(int objectiveID, int client) {
	int GainMax = (rp_GetJobCapital(g_iPlanque) / 1000) + (g_stkTeamCount[TEAM_POLICE] * 2500) + (g_stkTeamCount[TEAM_HOSTAGE] * 2500);
	char tmp[64], tmp2[2][64];
	rp_GetZoneData(g_iPlanqueZone, zone_type_name, tmp, sizeof(tmp));
	ExplodeString(tmp, ": ", tmp2, sizeof(tmp2), sizeof(tmp2[]));
	
	if( Math_GetRandomInt(0, 4) == 0 )
		updateTeamPolice();
	
#if defined USING_VEHICLE
	if( !rp_IsValidVehicle(g_iVehicle) ) { g_iVehicle = spawnVehicle(client); }
#endif
	
	if( g_stkTeamCount[TEAM_BRAQUEUR] == 0 ) {
		if( g_stkTeamCount[TEAM_POLICE] > 0 ) {
			int amendePolice = (g_iQuestGain / 4) / g_stkTeamCount[TEAM_POLICE];
			amendePolice = amendePolice < 1000 ? amendePolice : 1000;
			int gainPolice = ((GainMax-(g_iQuestGain / 4)) / g_stkTeamCount[TEAM_POLICE]) - amendePolice;
			
			for (int j = 0; j < g_stkTeamCount[TEAM_POLICE]; j++) { 
				CPrintToChat(g_stkTeam[TEAM_POLICE][j], "" ...MOD_TAG... " Vous avez gagné %d$ pour avoir tué tous les braqueurs de %s", gainPolice, tmp2[0]);
				rp_ClientMoney(g_stkTeam[TEAM_POLICE][j], i_AddToPay, gainPolice);
				
				rp_ClientXPIncrement(g_stkTeam[TEAM_POLICE][j], gainPolice / 10);
			}
		}
		for (int i = 0; i < g_stkTeamCount[TEAM_BRAQUEUR_DEAD]; i++) {
			CPrintToChat(g_stkTeam[TEAM_BRAQUEUR_DEAD][i], "" ...MOD_TAG... " Le braquage a été perdu.");
		}
		rp_QuestStepFail(client, objectiveID);
		LogToGame("[BRAQUAGE] [END] Le braquage est terminé, perdu: %d$", g_iQuestGain);
		return;
	}

#if defined USING_VEHICLE
	bool allInVehicle = true;
#else
	bool allInMetro = true;
#endif
	bool allInPlanque = true;
	
	for (int i = 0; i < g_stkTeamCount[TEAM_BRAQUEUR]; i++) {
		int heal = GetClientHealth(g_stkTeam[TEAM_BRAQUEUR][i]) + Math_GetRandomInt(5, 10);
		int kevlar = rp_GetClientInt(g_stkTeam[TEAM_BRAQUEUR][i], i_Kevlar) + Math_GetRandomInt(2, 5);
#if defined USING_VEHICLE
		if( allInVehicle ) allInVehicle = isInVehicle(g_stkTeam[TEAM_BRAQUEUR][i]);
#else
		if( allInMetro ) allInMetro = isInMetro(g_stkTeam[TEAM_BRAQUEUR][i]);
#endif
		if( heal > 500 ) heal = 500;
		if( kevlar > 250 ) kevlar = 250;
		if (rp_GetZoneInt(rp_GetPlayerZone(g_stkTeam[TEAM_BRAQUEUR][i]), zone_type_type) != g_iPlanque) allInPlanque = false;
#if defined USING_VEHICLE
		if (rp_GetZoneBit(rp_GetPlayerZone(g_stkTeam[TEAM_BRAQUEUR][i])) & BITZONE_PEACEFULL) ForcePlayerSuicide(g_stkTeam[TEAM_BRAQUEUR][i]);
#endif		
		SetEntityHealth(g_stkTeam[TEAM_BRAQUEUR][i], heal);
		rp_SetClientInt(g_stkTeam[TEAM_BRAQUEUR][i], i_Kevlar, kevlar);
#if defined USING_VEHICLE
		PrintHintText(g_stkTeam[TEAM_BRAQUEUR][i], "Objectif: Restez vivant. Prenez la fuite avec votre voiture quand vous le souhaitez. Gain<: %d$", g_iQuestGain);
#else
		PrintHintText(g_stkTeam[TEAM_BRAQUEUR][i], "Objectif: Restez vivant. Prenez la fuite dans un métro quand vous le souhaitez. Gain: %d$", g_iQuestGain);
#endif
		for (int j = 0; j < g_stkTeamCount[TEAM_HOSTAGE]; j++) {
			if( Math_GetRandomInt(0, 4)  == 0 ) {
				rp_Effect_BeamBox(g_stkTeam[TEAM_BRAQUEUR][i], g_stkTeam[TEAM_HOSTAGE][j], NULL_VECTOR, 0, 255, 0);
			}
		}

#if defined USING_VEHICLE
		if( Math_GetRandomInt(0, 2)  == 0 )
			rp_Effect_BeamBox(g_stkTeam[TEAM_BRAQUEUR][i], g_iVehicle, NULL_VECTOR, 255, 255, 255);
#endif
	}
	
	if( allInPlanque ) {
		g_iQuestGain += Math_GetRandomInt(0, 50) * g_stkTeamCount[TEAM_BRAQUEUR];
		if( g_iQuestGain >= GainMax ) g_iQuestGain = GainMax;
	}
#if defined USING_VEHICLE
	if( allInVehicle ) 
		rp_QuestStepComplete(client, objectiveID);
#else
	if( allInMetro )
		rp_QuestStepComplete(client, objectiveID);
#endif

	if( g_stkTeamCount[TEAM_POLICE] > 0 ) {
		int amendePolice = (g_iQuestGain / 4) / g_stkTeamCount[TEAM_POLICE];
		amendePolice = amendePolice < 1000 ? amendePolice : 1000;
		
		int gainPolice = ((GainMax-(g_iQuestGain / 4)) / g_stkTeamCount[TEAM_POLICE]) - amendePolice;
		
		for (int j = 0; j < g_stkTeamCount[TEAM_POLICE]; j++) {
			
			PrintHintText(g_stkTeam[TEAM_POLICE][j], "Alerte: Un braquage est en cours dans %s, tuez les braqueurs. Gain: %d$, Amende: %d$.", tmp2[0], gainPolice, amendePolice);
			
			for (int i = 0; i < g_stkTeamCount[TEAM_BRAQUEUR]; i++) {
				if( Math_GetRandomInt(0, 4)  == 0 )
					rp_Effect_BeamBox(g_stkTeam[TEAM_POLICE][j], g_stkTeam[TEAM_BRAQUEUR][i], NULL_VECTOR, 255, 0, 0);
			}
			for (int i = 0; i < g_stkTeamCount[TEAM_HOSTAGE]; i++) {
				if( Math_GetRandomInt(0, 4)  == 0 )
					rp_Effect_BeamBox(g_stkTeam[TEAM_POLICE][j], g_stkTeam[TEAM_HOSTAGE][i], NULL_VECTOR, 0, 255, 0);
			}
#if defined USING_VEHICLE
			if( Math_GetRandomInt(0, 4)  == 0 )
				rp_Effect_BeamBox(g_stkTeam[TEAM_POLICE][j], g_iVehicle, NULL_VECTOR, 0, 0, 255);
#endif
		}
	}
}
public void Q7_Frame(int objectiveID, int client) {
	int GainMax = (rp_GetJobCapital(g_iPlanque) / 1000) + (g_stkTeamCount[TEAM_POLICE] * 2500) + (g_stkTeamCount[TEAM_HOSTAGE] * 2500);
	char tmp[64], tmp2[2][64];
	rp_GetZoneData(g_iPlanqueZone, zone_type_name, tmp, sizeof(tmp));
	ExplodeString(tmp, ": ", tmp2, sizeof(tmp2), sizeof(tmp2[]));
#if defined USING_VEHICLE
	float pos[3], dst[3] = { -8956.0, -5483.0, -2350.0 };
	Entity_GetAbsOrigin(g_iVehicle, pos);

	if( GetVectorDistance(pos, dst) <= 200.0 ) {
		rp_QuestStepComplete(client, objectiveID);
		return;
	}
#endif
	
	for (int i = 0; i < g_stkTeamCount[TEAM_BRAQUEUR]; i++) {

#if defined USING_VEHICLE
		if (rp_GetZoneBit(rp_GetPlayerZone(g_stkTeam[TEAM_BRAQUEUR][i])) & BITZONE_PEACEFULL) ForcePlayerSuicide(g_stkTeam[TEAM_BRAQUEUR][i]);		
		ServerCommand("sm_effect_gps %d %f %f %f", g_stkTeam[TEAM_BRAQUEUR][i], dst[0], dst[1], dst[2]);
#endif

		PrintHintText(g_stkTeam[TEAM_BRAQUEUR][i], "Quête: %s\nObjectif: Prenez la fuite avec le véhicule.", QUEST_NAME);
	}
	
	if( g_stkTeamCount[TEAM_BRAQUEUR] == 0 ) {
		if( g_stkTeamCount[TEAM_POLICE] > 0 ) {
			int amendePolice = (g_iQuestGain / 4) / g_stkTeamCount[TEAM_POLICE];
			amendePolice = amendePolice < 1000 ? amendePolice : 1000;
			int gainPolice = ((GainMax-(g_iQuestGain / 4)) / g_stkTeamCount[TEAM_POLICE]) - amendePolice;
			
			for (int j = 0; j < g_stkTeamCount[TEAM_POLICE]; j++) {
				
				CPrintToChat(g_stkTeam[TEAM_POLICE][j], "" ...MOD_TAG... " Vous avez gagné %d$ pour avoir tué tous les braqueurs de %s", gainPolice, tmp2[0]);
				rp_ClientMoney(g_stkTeam[TEAM_POLICE][j], i_AddToPay, gainPolice);
				
				rp_ClientXPIncrement(g_stkTeam[TEAM_POLICE][j], gainPolice / 10);
			}
		}
		for (int i = 0; i < g_stkTeamCount[TEAM_BRAQUEUR_DEAD]; i++) {
			CPrintToChat(g_stkTeam[TEAM_BRAQUEUR_DEAD][i], "" ...MOD_TAG... " Le braquage a été perdu.");
		}		
		
		rp_QuestStepFail(client, objectiveID);
		LogToGame("[BRAQUAGE] [END] Le braquage est terminé, perdu: %d$", g_iQuestGain);
		return;
	}
	if( g_stkTeamCount[TEAM_POLICE] > 0 ) {
		int amendePolice = (g_iQuestGain / 4) / g_stkTeamCount[TEAM_POLICE];
		amendePolice = amendePolice < 1000 ? amendePolice : 1000;
		
		int gainPolice = ((GainMax-(g_iQuestGain / 4)) / g_stkTeamCount[TEAM_POLICE]) - amendePolice;
		
		for (int j = 0; j < g_stkTeamCount[TEAM_POLICE]; j++) {
			
			PrintHintText(g_stkTeam[TEAM_POLICE][j], "Alerte: Un braquage est en cours dans %s, tuez les braqueurs. Gain: %d$, Amende: %d$.", tmp2[0], gainPolice, amendePolice);
			
			for (int i = 0; i < g_stkTeamCount[TEAM_BRAQUEUR]; i++) {
				if( Math_GetRandomInt(0, 4)  == 0 )
					rp_Effect_BeamBox(g_stkTeam[TEAM_POLICE][j], g_stkTeam[TEAM_BRAQUEUR][i], NULL_VECTOR, 255, 0, 0);
			}
			for (int i = 0; i < g_stkTeamCount[TEAM_HOSTAGE]; i++) {
				if( Math_GetRandomInt(0, 4)  == 0 )
					rp_Effect_BeamBox(g_stkTeam[TEAM_POLICE][j], g_stkTeam[TEAM_HOSTAGE][i], NULL_VECTOR, 0, 255, 0);
			}
#if defined USING_VEHICLE
			if( Math_GetRandomInt(0, 4)  == 0 )
				rp_Effect_BeamBox(g_stkTeam[TEAM_POLICE][j], g_iVehicle, NULL_VECTOR, 0, 0, 255);
#endif
		}
	}
}
public void Q_Complete(int objectiveID, int client) {
	char tmp[64], tmp2[2][64];
	rp_GetZoneData(g_iPlanqueZone, zone_type_name, tmp, sizeof(tmp));
	ExplodeString(tmp, ": ", tmp2, sizeof(tmp2), sizeof(tmp2[]));
	int gain = g_iQuestGain / (g_stkTeamCount[TEAM_BRAQUEUR]+g_stkTeamCount[TEAM_BRAQUEUR_DEAD]);
	
	for (int i = 0; i < g_stkTeamCount[TEAM_BRAQUEUR]; i++) {
		CPrintToChat(g_stkTeam[TEAM_BRAQUEUR][i], "" ...MOD_TAG... " Vous avez gagné %d$ pour votre braquage de %s.", gain, tmp2[0]);
		rp_ClientMoney(g_stkTeam[TEAM_BRAQUEUR][i], i_AddToPay, gain);
		
		rp_ClientXPIncrement(g_stkTeam[TEAM_BRAQUEUR][i], gain / 10);
		
		if( client != g_stkTeam[TEAM_BRAQUEUR][i] )
			rp_QuestComplete(g_stkTeam[TEAM_BRAQUEUR][i], QUEST_UNIQID, true);
	}
	
	for (int i = 0; i < g_stkTeamCount[TEAM_BRAQUEUR_DEAD]; i++) {
		CPrintToChat(g_stkTeam[TEAM_BRAQUEUR_DEAD][i], "" ...MOD_TAG... " Vous avez gagné %d$ pour votre braquage de %s.", gain, tmp2[0]);
		rp_ClientMoney(g_stkTeam[TEAM_BRAQUEUR_DEAD][i], i_AddToPay, gain);
		
		rp_ClientXPIncrement(g_stkTeam[TEAM_BRAQUEUR_DEAD][i], gain / 10);
		
		if( client != g_stkTeam[TEAM_BRAQUEUR_DEAD][i] )
			rp_QuestComplete(g_stkTeam[TEAM_BRAQUEUR_DEAD][i], QUEST_UNIQID, true);
	}
	for (int i = 0; i < g_stkTeamCount[TEAM_POLICE]; i++) {
		
		if( client != g_stkTeam[TEAM_POLICE][i] )
			rp_QuestComplete(g_stkTeam[TEAM_POLICE][i], QUEST_UNIQID, false);
	}
	
	rp_SetJobCapital(g_iPlanque, rp_GetJobCapital(g_iPlanque) - gain*3/4);
	
	LogToGame("[BRAQUAGE] [END] Le braquage est terminé, gagné: %d$", g_iQuestGain);
	
	if( g_stkTeamCount[TEAM_POLICE] > 0 ) {
		int amendePolice = (g_iQuestGain / 4) / g_stkTeamCount[TEAM_POLICE];
		amendePolice = amendePolice < 1000 ? amendePolice : 1000;
		
		for (int i = 0; i < g_stkTeamCount[TEAM_POLICE]; i++) {
			CPrintToChat(g_stkTeam[TEAM_POLICE][i], "" ...MOD_TAG... " Vous avez payé une amende de %d$ à cause du braquage de %s.", amendePolice, tmp2[0]);
			rp_ClientMoney(g_stkTeam[TEAM_POLICE][i], i_Money, -amendePolice);
		}
	}
	Q_Clean();
}
// ----------------------------------------------------------------------------
public Action EV_PickupHostage(Handle ev, const char[] name, bool broadcast) {
	int client = GetClientOfUserId(GetEventInt(ev, "userid"));
	int hostage = GetEventInt(ev, "hostage");
	
	if( g_iPlayerTeam[client] == TEAM_POLICE && g_iPlayerTeam[hostage] == TEAM_HOSTAGE) {
		rp_HookEvent(client, RP_OnPlayerDead, fwdHostageCarryDead);
		rp_HookEvent(client, RP_OnPlayerZoneChange, fwdZoneChange);
	}
}
public Action EV_RescuseHostage(Handle ev, const char[] name, bool broadcast) {
	int client = GetClientOfUserId(GetEventInt(ev, "userid"));
	int hostage = GetEventInt(ev, "hostage");
	rp_ScheduleEntityInput(hostage, 5.0, "Kill");
	
	if( g_iPlayerTeam[hostage] == TEAM_HOSTAGE) {
		char tmp[64], tmp2[2][64];
		rp_GetZoneData(g_iPlanqueZone, zone_type_name, tmp, sizeof(tmp));
		ExplodeString(tmp, ": ", tmp2, sizeof(tmp2), sizeof(tmp2[]));
		
		CPrintToChat(client, "" ...MOD_TAG... " Vous avez gagné %d$ pour avoir libéré un otage de %s.", 1000, tmp2[0]);
		rp_ClientMoney(client, i_AddToPay, 1000);
		
		rp_ClientXPIncrement(client, 100);
		
		removeClientTeam(hostage);
	}
}
// ----------------------------------------------------------------------------
public void OnClientPostAdminCheck(int client) {
	g_iPlayerTeam[client] = TEAM_NONE;
	if( g_bDoingQuest )
		rp_HookEvent(client, RP_OnPlayerDataLoaded, fwdLoaded);
	
	if( g_bHasHelmet ) {
		rp_HookEvent(client, RP_OnPlayerDead, fwdDead);
		rp_HookEvent(client, RP_PreGiveDamage, fwdDamage);
		rp_HookEvent(client, RP_PreClientTeleport, fwdTeleport);
		rp_HookEvent(client, RP_PreClientSendToJail, fwdSendToJail);
		rp_HookEvent(client, RP_OnPlayerZoneChange, fwdZoneChangeTUTO);
		rp_HookEvent(client, RP_PlayerCanKill, fwdCanKill);
		rp_HookEvent(client, RP_OnPlayerHear, fwdHear);
	}
	
	if( g_bByPassDoor ) {
		rp_HookEvent(client, RP_OnPlayerCheckKey, fwdGotKey);
	}
	
	rp_HookEvent(client, RP_OnPlayerCommand, fwdCommand);
}
public Action fwdCommand(int client, char[] command, char[] arg) {
	static char name[64];
	
	if( StrEqual(command, "q") || StrEqual(command, "quest") ) {
		
		if( !(g_iPlayerTeam[client] == TEAM_BRAQUEUR || g_iPlayerTeam[client] == TEAM_BRAQUEUR_DEAD) )
			return Plugin_Continue;
		
		GetClientName2(client, name, sizeof(name), false);
		
		for (int i = 1; i <= MaxClients; i++) {
			if( !IsValidClient(i) )
				continue;
			if( !(g_iPlayerTeam[i] == TEAM_BRAQUEUR || g_iPlayerTeam[i] == TEAM_BRAQUEUR_DEAD) )
				continue;
			
			CPrintToChat(i, "{lightblue}%s{default} ({lime}QUÊTES{default}): %s", name, arg);
		}
		return Plugin_Handled;
	}
	return Plugin_Continue;
}
public Action fwdLoaded(int client) {
	if( g_iPlayerTeam[client] != TEAM_POLICE && (rp_GetClientJobID(client) == 1 || rp_GetClientJobID(client) == 101) ) {
		addClientToTeam(client, TEAM_POLICE);
	}
}
public void OnClientDisconnect(int client) {
	if( g_iPlayerTeam[client] == TEAM_BRAQUEUR )
		OnBraqueurKilled(client);
	
	if( g_iPlayerTeam[client] == TEAM_POLICE && g_iQuestGain > 0 ) {
		
		char szQuery[512], szSteamID[64];
		GetClientAuthId(client, AUTH_TYPE, szSteamID, sizeof(szSteamID));
		
		Format(szQuery, sizeof(szQuery), "INSERT INTO `rp_users2` (`id`, `steamid`, `bank`, `pseudo` ) VALUES (NULL, '%s', '%i', 'braquage' );", szSteamID, -1000);
		SQL_TQuery(rp_GetDatabase(), SQL_QueryCallBack, szQuery);	
	}
		
	removeClientTeam(client);
}
public Action fwdHostageCarryDead(int client, int attacker, float& respawn, int& tdm, float& ctx) {
	rp_UnhookEvent(client, RP_OnPlayerDead, fwdHostageCarryDead);
	rp_UnhookEvent(client, RP_OnPlayerZoneChange, fwdZoneChange);
}
public Action fwdZoneChange(int client, int newZone, int oldZone) {
	if( rp_GetZoneInt(newZone, zone_type_type) != g_iPlanque ) {
		detachHostage(client);
	}
}
public Action fwdZoneChangeTUTO(int client, int newZone, int oldZone) {
	if( !rp_IsTutorialOver(client) && rp_GetZoneInt(newZone, zone_type_type) == g_iPlanque ) {
		rp_ClientSendToSpawn(client, true);
	}
}
public Action fwdGotKey(int client, int doorID, int lockType) {
	if( lockType == 2 && (g_iPlayerTeam[client] == TEAM_POLICE || g_iPlayerTeam[client] == TEAM_BRAQUEUR) ) {
		float pos[3];
		Entity_GetAbsOrigin(doorID, pos);
		
		int zone = rp_GetZoneInt(rp_GetZoneFromPoint(pos), zone_type_type);
		if( zone == g_iPlanque )
			return Plugin_Changed;
		if( zone == 0 && rp_GetZoneInt(rp_GetPlayerZone(client), zone_type_type) == g_iPlanque && rp_IsEntitiesNear(client, doorID) )
			return Plugin_Changed;
	}
	
	return Plugin_Continue;
}
public Action fwdPressUse(int client) {
	if( g_stkTeamCount[TEAM_BRAQUEUR_DEAD] > 0 && g_iPlayerTeam[client] == TEAM_BRAQUEUR ) {
		int target = rp_GetClientTarget(client);
		if( target > 0 && IsValidEdict(target) && IsValidEntity(target) ) {
			char classname[64], tmp2[64];
			GetEdictClassname(target, classname, sizeof(classname));
			if( StrEqual(classname, "hostage_entity") ) {
				Menu menu = new Menu(MenuRespawnBraqueur);
				menu.SetTitle("Relâcher l'otage pour récupérer un co-équipier?");
				
				for (int i = 0; i < g_stkTeamCount[TEAM_BRAQUEUR_DEAD]; i++) {
					Format(classname, sizeof(classname), "%d %d", target, g_stkTeam[TEAM_BRAQUEUR_DEAD][i]);
					Format(tmp2, sizeof(tmp2), "%N", g_stkTeam[TEAM_BRAQUEUR_DEAD][i]);
					menu.AddItem(classname, tmp2);
				}
				menu.ExitButton = true;
				
				menu.Display(client, 10);
			}
		}
	}
}
public Action fwdDead(int client, int attacker, float& respawn, int& tdm, float& ctx) {
		
	if( g_iQuestGain > 0 && g_iPlayerTeam[client] == TEAM_BRAQUEUR ) {
		if (g_iPlayerTeam[attacker] == TEAM_POLICE) {
			rp_ClientXPIncrement(attacker, 500);
			LogToGame("[BRAQUAGE] [MORT] %L est un braqueur et a été tué par %L.", client, attacker);
		}
		OnBraqueurKilled(client);
		return Plugin_Handled;
	}
	if( g_iPlayerTeam[attacker] == TEAM_BRAQUEUR && g_bHasHelmet ) {
		return Plugin_Handled;
	}
	if( g_iPlayerTeam[attacker] == TEAM_POLICE && g_bHasHelmet ) {
		if( rp_GetZoneInt(rp_GetPlayerZone(client), zone_type_type) == g_iPlanque ) {
			return Plugin_Handled;
		}
		tdm = 0;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}
public Action fwdDamage(int attacker, int victim, float& damage, int damagetype) {
	
	if( g_iPlayerTeam[attacker] == TEAM_BRAQUEUR && g_iPlayerTeam[victim] != TEAM_POLICE && rp_GetZoneInt(rp_GetPlayerZone(victim), zone_type_type) != g_iPlanque ) {
		return Plugin_Handled;
	}
	if( g_iPlayerTeam[attacker] != TEAM_BRAQUEUR && g_iPlayerTeam[victim] == TEAM_POLICE && rp_GetZoneInt(rp_GetPlayerZone(victim), zone_type_type) == g_iPlanque ) {
		return Plugin_Handled;
	}
	if( g_iPlayerTeam[attacker] != TEAM_POLICE && g_iPlayerTeam[victim] == TEAM_BRAQUEUR ) {
		return Plugin_Handled;
	}
	
	if( damagetype & DMG_BULLET ) {
		int wpnid = Client_GetActiveWeapon(attacker);
		if( wpnid > 0 && rp_GetWeaponBallType(wpnid) == ball_type_braquage )
			damage *= 2.0;
	}
	
	return Plugin_Continue;
}
public Action fwdTeleport(int client) {
	if( IsValidClient(client) && g_iPlayerTeam[client] == TEAM_BRAQUEUR ) {
		return Plugin_Handled;
	}
	return Plugin_Continue;
}
public Action fwdSendToJail(int client, int target) {
	if( IsValidClient(target) && g_iPlayerTeam[target] == TEAM_BRAQUEUR ) {
#if defined USING_VEHICLE
		if( isInVehicle(target) )
			return Plugin_Handled;
#else
		if( isInStation(target) )
			return Plugin_Handled;
		if( isInMetro(target) )
			return Plugin_Handled;
#endif
		if( rp_GetZoneInt(rp_GetPlayerZone(target), zone_type_type) == g_iPlanque )
			return Plugin_Handled;
	}
	return Plugin_Continue;
}
// ----------------------------------------------------------------------------
void DrawMenu_Invitation(int client, int target) {
	Menu menu = new Menu(MenuInviterBraqueur);
	menu.SetTitle("%N souhaite participer\nà la quète %s\n avec vous dans l'équipe: %s.\n \n Acceptez-vous son invitation?", client, QUEST_NAME, TEAM_NAME1);
	menu.AddItem("oui", "Oui");
	menu.AddItem("non", "Non");
	menu.ExitButton = false;
	
	menu.Display(target, 10);
}
public int MenuRespawnBraqueur(Handle menu, MenuAction action, int client, int param2) {
	if( action == MenuAction_Select ) {
		char options[64], tmp[2][12];
		GetMenuItem(menu, param2, options, sizeof(options));
		ExplodeString(options, " ", tmp, sizeof(tmp), sizeof(tmp[]));
		
		
		int hostage = StringToInt(tmp[0]);
		int target = StringToInt(tmp[1]);
		
		if( IsValidClient(target) && IsValidEdict(hostage) && IsValidEntity(hostage) && g_iPlayerTeam[target] != TEAM_BRAQUEUR ) {			
			float pos[3];
			Entity_GetAbsOrigin(hostage, pos);
			removeClientTeam(hostage);
			rp_AcceptEntityInput(hostage, "Kill");
			
			if( !IsPlayerAlive(target) )
				CS_RespawnPlayer(target);
			
			OnBraqueurRespawn(target);
			
			rp_ClientTeleport(target, pos);			
			
			SetEntityHealth(target, 500);
			rp_SetClientInt(target, i_Kevlar, 250);
			
			if( Client_GetWeaponBySlot(target, CS_SLOT_PRIMARY) < 0 ) {
				int wepid = GivePlayerItem(target, BRAQUAGE_WEAPON);
				FakeClientCommand(target, "use " ... BRAQUAGE_WEAPON);
				Weapon_SetPrimaryClip(wepid, 5000);
				rp_SetWeaponBallType(wepid, ball_type_braquage);
			}
			if( Client_GetWeaponBySlot(target, CS_SLOT_SECONDARY) < 0 ) {
				int wepid = GivePlayerItem(target, "weapon_revolver");
				rp_SetWeaponBallType(wepid, ball_type_braquage);
			}
			
			FakeClientCommand(target, "sm_stuck");
		}
	}
	else if( action == MenuAction_End ) {
		CloseHandle(menu);
	}
}
public int MenuInviterBraqueur(Handle menu, MenuAction action, int client, int param2) {
	if( action == MenuAction_Select ) {
		char options[64];
		GetMenuItem(menu, param2, options, sizeof(options));
		
		if( StrEqual(options, "refresh") )
			return;
		if( g_iVehicle > 0 )
			return;
		
		else if( StrEqual(options, "oui") ) {
			if( g_stkTeamCount[TEAM_BRAQUEUR] < requiredTForCT() && g_iPlayerTeam[client] == TEAM_INVITATION ) {
				addClientToTeam(client, TEAM_BRAQUEUR);
				LogToGame("[BRAQUAGE] %L a accepté l'invitation", client);
			}
			else {
				removeClientTeam(client);
				LogToGame("[BRAQUAGE] %L a été dégagé du braquage", client);
			}
		}
		else if( StrEqual(options, "non") ) {
			removeClientTeam(client);
		}
		else {
			int target = StringToInt(options);
			if( IsValidClient(target) ) {
				if( g_iPlayerTeam[target] == TEAM_INVITATION )
					removeClientTeam(target);
				else
					addClientToTeam(target, TEAM_INVITATION);
			}
		}
	}
	else if( action == MenuAction_End ) {
		CloseHandle(menu);
	}
}
public int MenuSelectPlanque(Handle menu, MenuAction action, int client, int param2) {
	if( action == MenuAction_Select ) {
		char options[64];
		GetMenuItem(menu, param2, options, sizeof(options));
		
		int target = StringToInt(options);
		if( target > 0 && target < 10000 ) {
			g_iPlanque = rp_GetZoneInt(target, zone_type_type);
			g_iPlanqueZone = target;
			
			Menu menu2 = new Menu(MenuSelectPlanque);
			menu2.SetTitle("Quète: %s", QUEST_NAME);
			menu2.AddItem("10001", "Sans négociateur:\nLes policiers peuvent\n utiliser des sucette duo mais\nvous avez 2 otages en moins.");
			menu2.AddItem("10002", "Avec négociateur:\nLes policiers ne peuvent pas\nutiliser sucette duo mais\npossèdent des M4-braquages.");
			menu2.Display(client, MENU_TIME_FOREVER);
		}
		else {
			SetConVarInt(g_hActive, target - 10000);
			rp_QuestStepComplete(client, g_iQ3);
		}
	}
	else if( action == MenuAction_End ) {
		CloseHandle(menu);
	}
}
// ----------------------------------------------------------------------------
void addClientToTeam(int client, int team) {
	removeClientTeam(client);
	
	if( team != TEAM_NONE )
		g_stkTeam[team][ g_stkTeamCount[team]++ ] = client;
	
	g_iPlayerTeam[client] = team;
	
	if( client <= MaxClients )
		LogToGame("[DEBUG] [BRAQUAGE] %L was added to team: %d", client, team);
}
void removeClientTeam(int client) {
	if( g_iPlayerTeam[client] != TEAM_NONE ) {
		for (int i = 0; i < g_stkTeamCount[g_iPlayerTeam[client]]; i++) {
			if( g_stkTeam[ g_iPlayerTeam[client] ][ i ] == client ) {
				for (; i < g_stkTeamCount[g_iPlayerTeam[client]]; i++) {
					g_stkTeam[g_iPlayerTeam[client]][i] = g_stkTeam[g_iPlayerTeam[client]][i + 1];
				}
				g_stkTeamCount[g_iPlayerTeam[client]]--;
				break;
			}
		}
		
		if( client <= MaxClients )
			LogToGame("[DEBUG] [BRAQUAGE] %L was removed from team %d", client, g_iPlayerTeam[client]);
		g_iPlayerTeam[client] = TEAM_NONE;
	}
}
// ----------------------------------------------------------------------------
int requiredTForCT() {
#if defined USING_VEHICLE
	return REQUIRED_T;
#else
	int minimum = REQUIRED_T;
	int ct = 0;
	
	for (int i = 1; i <= MaxClients; i++) {
		if( !IsValidClient(i) )
			continue;
		if( policeMatch(i) )
			ct++;
	}
	
	if( ct > SUPPLEMENT_T )
		minimum++;
	return minimum;
#endif
}
int countPlayerInZone(int jobID) {
	int ret;
	for (int i = 1; i <= MaxClients; i++) {
		if( !IsValidClient(i) )
			continue;
		if( g_iPlayerTeam[i] != TEAM_NONE )
			continue;
		if( !IsPlayerAlive(i) )
			continue;
		if( rp_GetZoneInt(rp_GetPlayerZone(i), zone_type_type) == jobID )
			ret++;
	}
	return ret;
}
#if defined USING_VEHICLE
int spawnVehicle(int client) {
	static float g_flStartPos[][3] = {
		{672.0, -4410.0, -2000.0},
		{822.0, -4410.0, -2000.0},
		{977.0, -4410.0, -2000.0},
		{1160.0, -4410.0, -2000.0},
		{1860.0, -4410.0, -2000.0},
		{1990.0, -4410.0, -2000.0},
		{-2440.0, 1000.0, -2440.0},
		{-2440.0, 1200.0, -2440.0},
		{-2440.0, 1400.0, -2440.0},
		{-2440.0, 1600.0, -2440.0},
		{-2945.0, 1600.0, -2440.0},
		{-2945.0, 1400.0, -2440.0},
		{-2945.0, 1200.0, -2440.0},
		{-2945.0, 1000.0, -2440.0}
	};
	int[] rnd = new int[sizeof(g_flStartPos)];
	int ent = 0;
	for (int i = 0; i < sizeof(g_flStartPos); i++)
		rnd[i] = i;
	SortIntegers(rnd, sizeof(g_flStartPos), Sort_Random);
	
	for (int i = 0; i < sizeof(g_flStartPos); i++) {
		
		float ang[3] = { 0.0, 0.0, 0.0 };
		if( g_flStartPos[rnd[i]][2] < -2200.0 ) 
			ang[1] = 90.0;
		
		ent = rp_CreateVehicle(g_flStartPos[rnd[i]], ang, "models/natalya/vehicles/natalya_mustang_csgo_2016.mdl", 1, 0);
		if( ent > 0 && rp_IsValidVehicle(ent) ) {
			break;
		}
	}
	if( ent > 0 && rp_IsValidVehicle(ent) ) {
		
		SetEntProp(ent, Prop_Data, "m_bLocked", 1);
		rp_SetVehicleInt(ent, car_owner, client);
		rp_SetVehicleInt(ent, car_maxPassager, 3);
		rp_SetVehicleInt(ent, car_health, 10000);
		rp_SetClientKeyVehicle(client, ent, true);
		ServerCommand("sm_effect_colorize %d 0 0 0 255", ent);
		
		for (int i = 0; i < g_stkTeamCount[TEAM_BRAQUEUR]; i++) {
			rp_SetClientKeyVehicle(g_stkTeam[TEAM_BRAQUEUR][i], ent, true);
		}
		
		return ent;
	}
	
	return 0;
}
bool isInVehicle(int client) {
	return (rp_GetClientVehicle(client) == g_iVehicle || rp_GetClientVehiclePassager(client) == g_iVehicle);
}
#else
bool isInMetro(int client) {
	static char tmp[128];
	int zoneID = rp_GetPlayerZone(client);
	
	rp_GetZoneData(zoneID, zone_type_type, tmp, sizeof(tmp));
	
	if( StrEqual(tmp, "metro") ) {
		return true;
	}
	
	return false;
}
bool isInStation(int client) {
	static char tmp[128];
	int zoneID = rp_GetPlayerZone(client);
	
	rp_GetZoneData(zoneID, zone_type_type, tmp, sizeof(tmp));
	
	if( StrEqual(tmp, "station") ) {
		return true;
	}
	
	return false;
}
#endif
bool findAreaInRoom(int jobID, float pos[3]) {
	static int stkZones[MAX_JOBS][MAX_ZONES];
	static float zoneMin[MAX_ZONES][3], zoneMax[MAX_ZONES][3];
	static int iZonesCount[MAX_JOBS];
	static bool loaded = false;
	static char tmp[128];
	
	if( !loaded ) {
		for (int i = 1; i < MAX_ZONES; i++) {
			if (i == 181)
				continue;
			
			rp_GetZoneData(i, zone_type_name, tmp, sizeof(tmp));
			if( StrContains(tmp, "ascenseur", false) >= 0 )
				continue;
			
			int job = rp_GetZoneInt(i, zone_type_type);
			if( job <= 0 || job >= MAX_JOBS || job == 14 || job == 101 )
				continue;
			
			zoneMin[i][0] = rp_GetZoneFloat(i, zone_type_min_x);
			zoneMin[i][1] = rp_GetZoneFloat(i, zone_type_min_y);
			zoneMin[i][2] = rp_GetZoneFloat(i, zone_type_min_z);
			zoneMax[i][0] = rp_GetZoneFloat(i, zone_type_max_x);
			zoneMax[i][1] = rp_GetZoneFloat(i, zone_type_max_y);
			zoneMax[i][2] = rp_GetZoneFloat(i, zone_type_max_z);
			stkZones[job][ iZonesCount[job]++ ] = i;
			
		}
		loaded = true;
	}
	
	if( iZonesCount[jobID] == 0 )
		return false;
	
	int p;
	for (int i = 0; i < 16; i++) {
		p = stkZones[jobID][Math_GetRandomInt(0, iZonesCount[jobID] - 1)];
		pos[0] = Math_GetRandomFloat(zoneMin[p][0] + 32.0, zoneMax[p][0] - 32.0);
		pos[1] = Math_GetRandomFloat(zoneMin[p][1] + 32.0, zoneMax[p][1] - 32.0);
		pos[2] = Math_GetRandomFloat(zoneMin[p][2] + 32.0, zoneMax[p][2] - 32.0);
		
		if( rp_GetZoneFromPoint(pos) != p ) 
			continue;
		float pos2[3]; pos2 = pos;
		Handle tr = TR_TraceRayEx(pos, view_as<float>({ 90.0, 0.0, 0.0 }), MASK_PLAYERSOLID, RayType_Infinite);
		TR_GetEndPosition(pos, tr);
		if( TR_GetEntityIndex(tr) >= 1) {
			delete tr;
			continue;
		}
			
		pos[2] += 4.0;
		delete tr;
		
		tr = TR_TraceHullEx(pos, pos, view_as<float>({-32.0, -32.0, 0.0}), view_as<float>({32.0, 32.0, 64.0}), MASK_PLAYERSOLID);
		if( !TR_DidHit(tr) ) {
			delete tr;
			return true;
		}
		delete tr;
	}
	return false;
}
void OnBraqueurKilled(int client) {
	rp_SetClientBool(client, b_SpawnToGrave, false);
	rp_SetClientKeyVehicle(client, g_iVehicle, false);
	
	addClientToTeam(client, TEAM_BRAQUEUR_DEAD);
	
	if( g_bHasHelmet ) {
		LogToGame("[BRAQUAGE] [MORT] %L est un braqueur et a été tué.", client);
		
		SetEntProp(client, Prop_Send, "m_bHasHelmet", 0);
		rp_UnhookEvent(client, RP_OnPlayerUse, fwdPressUse);
		rp_ClientResetSkin(client);
	}
}
void OnBraqueurRespawn(int client) {
	addClientToTeam(client, TEAM_BRAQUEUR);
	rp_SetClientKeyVehicle(client, g_iVehicle, true);
	
	if( g_bHasHelmet ) {
		LogToGame("[BRAQUAGE] [MORT] %L est un braqueur et a été respawn.", client);
		
		SetEntProp(client, Prop_Send, "m_bHasHelmet", 1);
		rp_HookEvent(client, RP_OnPlayerUse, fwdPressUse);
		attachMask(client, true);
	}
}
void attachMask(int client, bool mask) {
	SetEntityModel(client, "models/player/custom_player/legacy/hoxton/hoxton.mdl");
	SetEntProp(client, Prop_Send, "m_nBody", mask ? 1 : 0);
	SetEntProp(client, Prop_Send, "m_nSkin", g_iMask[client]-1);
}
void detachHostage(int client) {
	int ent = CreateEntityByName("func_hostage_rescue");
	DispatchKeyValue(ent, "spawnflags", "4097");
	DispatchSpawn(ent);
	ActivateEntity(ent);
	SetEntPropVector(ent, Prop_Send, "m_vecMins", view_as<float>({-4.0, -4.0, -4.0}));
	SetEntPropVector(ent, Prop_Send, "m_vecMaxs", view_as<float>({4.0, 4.0, 4.0}));
	SetEntProp(ent, Prop_Send, "m_nSolidType", 2);
	
	float pos[3];
	Entity_GetAbsOrigin(client, pos);
	pos[2] += 8.0;
	
	TeleportEntity(ent, pos, NULL_VECTOR, NULL_VECTOR);
	rp_ScheduleEntityInput(ent, 0.001, "Kill");
}
public Action tskAlarm(Handle timer, any client) {
	float pos[3], cur[3];
	for (int i = 0; i < g_stkTeamCount[TEAM_BRAQUEUR]; i++) {
		GetClientEyePosition(g_stkTeam[TEAM_BRAQUEUR][i], cur);
		for (int j = 0; j < 3; j++)
			pos[j] = (pos[j] * i + cur[j]) / (i+1);
	}
	
	EmitSoundToAllRangedAny("ui/beep22.wav", pos);
	
	int sup = GetConVarInt(g_hActive) * 2;
	
	if( g_stkTeamCount[TEAM_HOSTAGE] < sup+(g_stkTeamCount[TEAM_POLICE]/2) && findAreaInRoom(g_iPlanque, pos) ) {
		int ent = CreateEntityByName("hostage_entity");
		DispatchSpawn(ent);
		TeleportEntity(ent, pos, NULL_VECTOR, NULL_VECTOR);
		addClientToTeam(ent, TEAM_HOSTAGE);
	}
}
void updateTeamPolice() {
	for (int i = 1; i <= MaxClients; i++) {
		if( !IsValidClient(i) )
			continue;
		
		if( g_iPlayerTeam[i] != TEAM_POLICE && policeMatch(i) ) {
			addClientToTeam(i, TEAM_POLICE);
		}
		else if( g_iPlayerTeam[i] == TEAM_POLICE && !policeMatch(i) ) {
			removeClientTeam(i);
		}
		
		if( g_iPlayerTeam[i] == TEAM_POLICE && GetClientTeam(i) == CS_TEAM_T ) {
			CS_SwitchTeam(i, CS_TEAM_CT);
			SetEntityHealth(i, 500);
			rp_SetClientInt(i, i_Kevlar, 250);
			SetEntProp(i, Prop_Send, "m_bHasHelmet", 1);
			rp_ClientResetSkin(i);
		}
	}
}
bool policeMatch(int client) {
	int jobID = rp_GetClientJobID(client);
	
	
	if( jobID == 101 && rp_GetClientBool(client, b_IsInAudiance) && rp_GetZoneInt(rp_GetPlayerZone(client), zone_type_type) == 101 ) {
		return false;
	}
	
	if( jobID == 1 || jobID == 101 ) {
		if(rp_GetClientInt(client, i_KillJailDuration) > 1) {
			return false;
		}
		
		return true;
	}

	return false;
}
void EmitSoundToAllRangedAny(const char[] sound, float origin[3]) {
	float pos[3], angle;
	int maxI = 3, maxJ = 4, distJ = 400;
	
	pos[2] = origin[2];
	
	for (int i = 0; i < maxI; i++) {
		angle = DegToRad(360.0 / maxI * i);
		
		for (int j = 1; j <= maxJ; j++) {
			pos[0] = origin[0] + Sine(angle) * distJ * j;
			pos[1] = origin[1] + Cosine(angle) * distJ * j;
		
			EmitSoundToAllAny(sound, SOUND_FROM_WORLD, 6, _, _, _, _, _, pos);
		}
	}
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
		
		if( enabled && !(bits & BITZONE_BLOCKOUT) ) {
			bits |= BITZONE_BLOCKOUT;
			changed = true;
		}
		else if( !enabled && (bits & BITZONE_BLOCKOUT) ) {
			bits &= ~BITZONE_BLOCKOUT;
			changed = true;
		}
		
		if( changed )
			rp_SetZoneBit(i, bits);
	}
	
}