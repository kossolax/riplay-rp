/*
 * Cette oeuvre, création, site ou texte est sous licence Creative Commons Attribution
 * - Pas d’Utilisation Commerciale
 * - Partage dans les Mêmes Conditions 4.0 International. 
 * Pour accéder à une copie de cette licence, merci de vous rendre à l'adresse suivante
 * http://creativecommons.org/licenses/by-nc-sa/4.0/ .
 *
 * Merci de respecter le travail fourni par le ou les auteurs 
 * https://riplay.fr/ - pasty.bully@gmail.com
 */
#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <colors_csgo>  // https://forums.alliedmods.net/showthread.php?p=2205447#post2205447
#include <smlib>        // https://github.com/bcserv/smlib
#include <emitsoundany> // https://forums.alliedmods.net/showthread.php?t=237045

#pragma newdecls required
#include <roleplay.inc>

#define QUEST_UNIQID    "joeletaxi"
#define QUEST_NAME      "Joe le taxi"
#define QUEST_TYPE      quest_daily
#define QUEST_RESUME1   "Faites le tour de la ville et inviter les gens à monter dans votre taxi"

int g_iQuest, g_iDuration[MAXPLAYERS + 1], g_iTaxi[MAXPLAYERS + 1], g_iCurrentClient[MAXPLAYERS + 1], g_iNbClient[MAXPLAYERS + 1], g_iPastClient[MAXPLAYERS + 1][3];

char g_CurrentDestination[MAXPLAYERS + 1][256];

char g_destination[][][256] =  {
	{ "Commisariat", "1" }, 
	{ "Hôpital", "11" }, 
	{ "Mc'Donald", "21" }, 
	{ "Artisan", "31" }, 
	{ "Concessionaire", "51" }, 
	{ "Agence immobilière", "61" }, 
	{ "Salle de sport", "71" }, 
	{ "Planque des mafieux", "91" }, 
	{ "Palais de justice", "101" }, 
	{ "Armurerie", "111" }, 
	{ "Magasin de loterie", "171" }, 
	{ "Banque", "211" }, 
	{ "Atelier des techniciens", "221" }, 
	{ "Villa immobilière", "appart_50" }, 
};

public Plugin myinfo =  {
	name = "Quête: "...QUEST_NAME, author = "PastyBully", 
	description = "RolePlay - Quête Joueur: "...QUEST_NAME, 
	version = __LAST_REV__, url = "https://rpweb.riplay.fr/#/"
};

public void OnPluginStart()
{
	RegServerCmd("rp_quest_reload", Cmd_PluginReloadSelf);
}

public void OnAllPluginsLoaded() {
	g_iQuest = rp_RegisterQuest(QUEST_UNIQID, QUEST_NAME, QUEST_TYPE, fwdCanStart);
	
	if (g_iQuest == -1)
		SetFailState("Erreur lors de la création de la quête %s %s", QUEST_UNIQID, QUEST_NAME);
	
	int i;
	rp_QuestAddStep(g_iQuest, i++, Q1_Start, Q1_Frame, Q1_Abort, QUEST_NULL);
	
	for (int k = 0; k < 3; k++)
	{
		rp_QuestAddStep(g_iQuest, i++, Q2_Start, Q2_Frame, Q1_Abort, Q2_Done);
		rp_QuestAddStep(g_iQuest, i++, Q3_Start, Q3_Frame, Q1_Abort, QUEST_NULL);
		rp_QuestAddStep(g_iQuest, i++, Q4_Start, Q4_Frame, Q1_Abort, Q4_Done);
	}
}

// ----------------------------------------------------------------------------

public bool fwdCanStart(int client)
{
	if (rp_GetClientJobID(client) == 91 || rp_GetClientJobID(client) == 81) 
		return false;
		
	if(GetClientCount() < 4) // 3 clients + 1 chauffeur
		return false;
	
	return true;
}

public void Q1_Start(int objectiveID, int client)
{
	g_iTaxi[client] = spawnVehicle(client);
	Format(g_CurrentDestination[client], sizeof(g_CurrentDestination), "");
	g_iNbClient[client] = 0;
	
	float pos[3];
	
	Entity_GetAbsOrigin(g_iTaxi[client], pos);
	
	char s[256];
	Format(s, sizeof(s), "Aller récupérer votre taxi afin d'effectuer le tour de la ville.");
	String_WordWrap(s, 40);
	
	Menu menu = new Menu(MenuNothing);
	
	menu.SetTitle("Quête: %s", QUEST_NAME);
	menu.AddItem("", s, ITEMDRAW_DISABLED);
	menu.ExitButton = false;
	menu.Display(client, 60);
	
	g_iDuration[client] = 2 * 60;
}

public void Q1_Frame(int objectiveID, int client)
{
	g_iDuration[client]--;
	
	float pos[3], origin[3];
	
	Entity_GetAbsOrigin(g_iTaxi[client], pos);
	
	ServerCommand("sm_effect_gps %d %f %f %f", client, pos[0], pos[1], pos[2]);
	
	GetClientAbsOrigin(client, origin);
	
	if (GetVectorDistance(pos, origin) < 64)
		rp_QuestStepComplete(client, objectiveID);
	else if (g_iDuration[client] <= 0)
		rp_QuestStepFail(client, objectiveID);
	else {
		PrintHintText(client, "<b>Quête</b>: %s\n<b>Temps restant</b>: %dsec\n<b>Objectif</b>: %s", QUEST_NAME, g_iDuration[client], QUEST_RESUME1);
	}
}

public void Q1_Abort(int objectiveID, int client) {
	PrintHintText(client, "<b>Quête</b>: %s\nLa quête est terminée.", QUEST_NAME);
}

// ----------------------------------------------------------------------------

public void Q2_Start(int objectiveID, int client)
{
	char s[256];
	Format(s, sizeof(s), "Faites le tour de la ville avec votre taxi et récupérer un maximum de client.");
	String_WordWrap(s, 40);
	
	Menu menu = new Menu(MenuNothing);
	
	menu.SetTitle("Quête: %s", QUEST_NAME);
	menu.AddItem("", s, ITEMDRAW_DISABLED);
	menu.ExitButton = false;
	menu.Display(client, MENU_TIME_FOREVER);
	
	g_iDuration[client] = 10 * 60;
}

public void Q2_Frame(int objectiveID, int client)
{
	g_iDuration[client]--;
	bool isAlreadyClient = false;
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if(!IsValidClient(i))
			continue;
			
		for (int k = 0; k < 3; k++)
		{
			if (g_iPastClient[client][k] == i)
			{
				isAlreadyClient = true;
				break;
			}
		}
		
		if (rp_GetClientVehiclePassager(i) > 0)
		{
			if(isAlreadyClient)
			{
				rp_ClientVehiclePassagerExit(i, g_iTaxi[client]);
			}
			else
			{		
				g_iCurrentClient[client] = i;
				rp_QuestStepComplete(client, objectiveID);
			}

		}
	}
	
	int nearest = getNearestEligible(client);

	if (IsValidClient(nearest))
	{
		rp_Effect_BeamBox(nearest, g_iTaxi[client], NULL_VECTOR, 230, 150, 0);	
	}
	
	if (g_iDuration[client] <= 0)
		rp_QuestStepFail(client, objectiveID);
	else {
		PrintHintText(client, "<b>Quête</b>: %s\n<b>Temps restant</b>: %dsec\n<b>Objectif</b>: %s", QUEST_NAME, g_iDuration[client], QUEST_RESUME1);
	}
}

public void Q2_Done(int objectiveID, int client) {
	int newClient = g_iCurrentClient[client];
	
	CPrintToChat(client, ""...MOD_TAG..."%N est votre nouveau client.", newClient);
	CPrintToChat(newClient, ""...MOD_TAG..." Vous venez de monter dans le taxi de %N.", client);
}

// ----------------------------------------------------------------------------

public void Q3_Start(int objectiveID, int client)
{
	char s[256];
	Format(s, sizeof(s), "Veuillez attendre que votre client fasse un choix de destination.");
	String_WordWrap(s, 40);
	
	Menu menu = new Menu(MenuNothing);
	
	menu.SetTitle("Quête: %s", QUEST_NAME);
	menu.AddItem("", s, ITEMDRAW_DISABLED);
	menu.ExitButton = false;
	menu.Display(client, 60);
	
	Menu menuClient = new Menu(MenuDestination);
	menuClient.SetTitle("Choix d'une destination :");
	
	for (int j = 0; j < sizeof(g_destination); j++)
	{
		char data[256];
		Format(data, sizeof(data), "%s_%d_%s", g_destination[j][1], client, g_destination[j][0]);
		menuClient.AddItem(data, g_destination[j][0]);
	}
	
	menuClient.ExitButton = true;
	menuClient.Display(g_iCurrentClient[client], 60);
	
	g_iDuration[client] = 10 * 60;
}

public void Q3_Frame(int objectiveID, int client)
{
	g_iDuration[client]--;
	
	if (!StrEqual(g_CurrentDestination[client], ""))
		rp_QuestStepComplete(client, objectiveID);
	else if (g_iDuration[client] <= 0)
		rp_QuestStepFail(client, objectiveID);
	else {
		PrintHintText(client, "<b>Quête</b>: %s\n<b>Temps restant</b>: %dsec\n<b>Objectif</b>: %s", QUEST_NAME, g_iDuration[client], QUEST_RESUME1);
	}
}

// ----------------------------------------------------------------------------

public void Q4_Start(int objectiveID, int client)
{
	char s[256];
	Format(s, sizeof(s), "Veuillez vous rendre jusqu'à la destination choisie par le client.");
	String_WordWrap(s, 40);
	
	Menu menu = new Menu(MenuNothing);
	
	menu.SetTitle("Quête: %s", QUEST_NAME);
	menu.AddItem("", s, ITEMDRAW_DISABLED);
	menu.ExitButton = false;
	menu.Display(client, 60);
	
	g_iDuration[client] = 10 * 60;
}

public void Q4_Frame(int objectiveID, int client)
{
	g_iDuration[client]--;
	
	float pos[3];
	
	Entity_GetAbsOrigin(g_iTaxi[client], pos);
	
	if (isNearBy(pos, g_CurrentDestination[client]))
	{
		rp_QuestStepComplete(client, objectiveID);
	}
	if (g_iDuration[client] <= 0)
		rp_QuestStepFail(client, objectiveID);
	else {
		PrintHintText(client, "<b>Quête</b>: %s\n<b>Temps restant</b>: %dsec\n<b>Objectif</b>: %s", QUEST_NAME, g_iDuration[client], QUEST_RESUME1);
	}
}

public void Q4_Done(int objectiveID, int client)
{
	int newClient = g_iCurrentClient[client];
	
	g_iPastClient[client][g_iNbClient[client]] = newClient;
	
	g_iNbClient[client]++;
	
	char tmp[64];
	Format(tmp, sizeof(tmp), "Il vous reste %d client%s à trouver.", 3 - g_iNbClient[client], 3 - g_iNbClient[client] > 1 ? "s" : "");
	
	CPrintToChat(client, ""...MOD_TAG..." Vous êtes arrivé à destination. %s", g_iNbClient[client] < 3 ? tmp : "Vous avez terminé toutes vos courses.");
	CPrintToChat(newClient, ""...MOD_TAG..." Vous êtes arrivé à destination.");
	
	rp_ClientVehiclePassagerExit(newClient, g_iTaxi[client]);
	
	rp_ClientXPIncrement(newClient, 250);
	rp_ClientXPIncrement(client, 100);
	
	rp_ClientMoney(client, i_AddToPay, 200);
	CPrintToChat(client, ""...MOD_TAG..." Vous venez de recevoir %d$.", 200);
	
	Format(g_CurrentDestination[client], sizeof(g_CurrentDestination), "");
	
	if (g_iNbClient[client] == 3)
	{
		int cap = rp_GetRandomCapital(1);
   		rp_SetJobCapital(cap, rp_GetJobCapital(cap) - 1600); // 3 * 200 + 1000
		rp_ClientMoney(client, i_AddToPay, 1000);
		rp_ClientXPIncrement(client, 500);
		CPrintToChat(client, ""...MOD_TAG..." Bravo, vous avez conduit tous vos clients à bon port ! Vous venez de recevoir %d$.", 1000);
		
		rp_ClientVehiclePassagerExit(client, g_iTaxi[client]);
		rp_SetVehicleInt(g_iTaxi[client], car_health, -1);
		
		Menu menu = new Menu(MenuNothing);
		menu.SetTitle("Quête: %s", QUEST_NAME);
		menu.ExitButton = false;
		menu.Display(client, 1);
	}
}

// ----------------------------------------------------------------------------

public int MenuNothing(Handle menu, MenuAction action, int client, int param2) {
	if (action == MenuAction_Select) {
		if (menu != INVALID_HANDLE)
			CloseHandle(menu);
	}
	else if (action == MenuAction_End) {
		if (menu != INVALID_HANDLE)
			CloseHandle(menu);
	}
}

public int MenuDestination(Handle menu, MenuAction action, int client, int param2) {
	if (action == MenuAction_End) {
		if (menu != INVALID_HANDLE)
			CloseHandle(menu);
	}
	else if (action == MenuAction_Select)
	{
		char options[128], expl[3][128];
		GetMenuItem(menu, param2, options, sizeof(options));
		ExplodeString(options, "_", expl, sizeof(expl), sizeof(expl[]));
		
		int conducteur = StringToInt(expl[1]);
		
		Format(g_CurrentDestination[conducteur], sizeof(g_CurrentDestination), "%s", expl[0]);
		
		CPrintToChat(conducteur, ""...MOD_TAG..." %N veut se rendre à la destination suivante : %s.", client, expl[2]);
		CPrintToChat(client, ""...MOD_TAG..." Votre chauffeur va vous conduire à la destination suivante : %s.", expl[2]);
	}
	
	return 0;
}

int spawnVehicle(int client)
{
	static float g_flStartPos[][3] =  {
		{ 672.0, -4410.0, -2000.0 }, 
		{ 822.0, -4410.0, -2000.0 }, 
		{ 977.0, -4410.0, -2000.0 }, 
		{ 1160.0, -4410.0, -2000.0 }, 
		{ 1860.0, -4410.0, -2000.0 }, 
		{ 1990.0, -4410.0, -2000.0 }, 
		{ -2440.0, 1000.0, -2440.0 }, 
		{ -2440.0, 1200.0, -2440.0 }, 
		{ -2440.0, 1400.0, -2440.0 }, 
		{ -2440.0, 1600.0, -2440.0 }, 
		{ -2945.0, 1600.0, -2440.0 }, 
		{ -2945.0, 1400.0, -2440.0 }, 
		{ -2945.0, 1200.0, -2440.0 }, 
		{ -2945.0, 1000.0, -2440.0 }
	};
	
	int[] rnd = new int[sizeof(g_flStartPos)];
	int ent = 0;
	for (int i = 0; i < sizeof(g_flStartPos); i++)
	rnd[i] = i;
	SortIntegers(rnd, sizeof(g_flStartPos), Sort_Random);
	
	for (int i = 0; i < sizeof(g_flStartPos); i++) {
		
		float ang[3] =  { 0.0, 0.0, 0.0 };
		if (g_flStartPos[rnd[i]][2] < -2200.0)
			ang[1] = 90.0;
		
		ent = rp_CreateVehicle(g_flStartPos[rnd[i]], ang, "models/natalya/vehicles/police_crown_victoria_csgo_v2.mdl", 0, 0);
		if (ent > 0 && rp_IsValidVehicle(ent)) {
			break;
		}
	}
	if (ent > 0 && rp_IsValidVehicle(ent)) {
		
		SetEntProp(ent, Prop_Data, "m_bLocked", 1);
		SetEntProp(ent, Prop_Send, "m_nBody", 1);
		rp_SetVehicleInt(ent, car_owner, client);
		rp_SetVehicleInt(ent, car_maxPassager, 1);
		rp_SetVehicleInt(ent, car_health, 10000);
		rp_SetClientKeyVehicle(client, ent, true);
		ServerCommand("sm_effect_colorize %d 230 150 0 255", ent);
		
		return ent;
	}
	
	return 0;
}

int getNearestEligible(int client)
{
	int target = -1;
	float src[3], dst[3], tmp, delta = 9999999.9;
	bool isAlreadyClient = false;
	Entity_GetAbsOrigin(g_iTaxi[client], src);
	
	for (int i = 1; i <= MaxClients; i++) {
		if (IsValidClient(i) && IsPlayerAlive(i) && i != client) {
			
			Entity_GetAbsOrigin(i, dst);
			
			tmp = GetVectorDistance(src, dst);
			
			
			if (tmp < delta && tmp < 1000.0) 
			{
				for (int k = 0; k < 3; k++)
				{
					if (g_iPastClient[client][k] == i)
					{
						isAlreadyClient = true;
						break;
					}
				}
				
				if(isAlreadyClient)
					continue;
				
				delta = tmp;
				target = i;
			}
		}
	}
	
	return target;
}

bool isNearBy(float src[3], char[] zone, float threshold = 200000.0)
{
	float min[3], max[3], center[3], size[3], delta[3];
	
	for (int i = 1; i < MAX_ZONES; i++) {
		char villa[64];
		rp_GetZoneData(i, zone_type_type, villa, sizeof(villa));
		
		if (!StrEqual(villa, zone))
			continue;
		
		min[0] = rp_GetZoneFloat(i, zone_type_min_x);
		min[1] = rp_GetZoneFloat(i, zone_type_min_y);
		min[2] = rp_GetZoneFloat(i, zone_type_min_z);
		
		max[0] = rp_GetZoneFloat(i, zone_type_max_x);
		max[1] = rp_GetZoneFloat(i, zone_type_max_y);
		max[2] = rp_GetZoneFloat(i, zone_type_max_z);
		
		// https://gamedev.stackexchange.com/questions/44483/how-do-i-calculate-distance-between-a-point-and-an-axis-aligned-rectangle
		for (int j = 0; j <= 2; j++) {
			center[j] = (min[j] + max[j]) / 2.0;
			size[j] = (max[j] - min[j]);
			
			float tmp = FloatAbs(src[j] - center[j]) - size[j] / 2.0;
			
			delta[j] = (tmp > 0.0) ? tmp : 0.0;
		}
		
		float distance = GetVectorLength(delta, true);
		
		if (distance < threshold)
			return true;
	}
	return false;
}