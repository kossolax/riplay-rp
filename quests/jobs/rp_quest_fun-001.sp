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

#define QUEST_UNIQID    	"granturismo"
#define QUEST_NAME      	"Gran Turismo"
#define QUEST_TYPE      	quest_daily
#define QUEST_RESUME1   	"Faites le tour de la map le plus vite possible en passant par tous les checkpoints"
#define CHECKPOINTS			18


int g_iQuest, g_iDuration[MAXPLAYERS + 1], g_iStep[MAXPLAYERS + 1], g_iVehicle[MAXPLAYERS+1], g_iEssai[MAXPLAYERS + 1], g_iQ2[MAXPLAYERS + 1], g_iSkip[MAXPLAYERS+1];
float g_flTemps[MAXPLAYERS + 1], g_flBestTime[MAXPLAYERS + 1];

bool g_bVerif[MAXPLAYERS + 1], g_bRecompense[MAXPLAYERS + 1];

// Pos, 0 = départ;1 = checkpoint;2 = arrivée; L'angle
float g_fPos[CHECKPOINTS][3][3] =  {
	{  { 269.388702, -2371.697265, -2015.968750 }, 0.0, 0.0 },  // Départ carshop
	{  { -3266.708496, -2047.703369, -2015.968750 }, 1.0, 90.0 },  // Virage vers tech
	{  { -3656.890380, -832.808593, -2143.968750 }, 1.0, 0.0 },  // Virage vers tunnel
	{  { -8960.714843, -1022.735717, -2143.968750 }, 1.0, 90.0 },  // entrée tunnel
	{  { -8757.440429, -10365.387695, -2143.968750 }, 1.0, 0.0 },  // Virage tunnel
	{  { -2621.812988, -10190.366210, -2015.968750 }, 1.0, 90.0 },  //Sortie tunnel
	{  { -2394.633544, -5949.852539, -2015.968750 }, 1.0, 0.0 },  // Virage vers villa
	{  { -1215.869140, -5636.589355, -2015.968750 }, 1.0, 90.0 },  // Virage vers mcdo
	{  { -1024.416015, -3903.707275, -2015.968750 }, 1.0, 0.0 },  // virage vers loto
	{  { 1165.391845, -3902.907958, -2015.968750 }, 1.0, 0.0 },  // Tout droit vers loto
	{  { 2878.780273, -3634.370117, -2015.968750 }, 1.0, 90.0 },  // Virage vers hôpital
	{  { 2760.469970, -833.206176, -2143.968750 }, 1.0, 0.0 },  // Virage face à justice
	{  { 1981.953491, -551.829833, -2143.968750 }, 1.0, 90.0 },  //Virage vers comico
	{  { 1703.259277, 831.081420, -2143.968750 }, 1.0, 0.0 },  // Virage vers mafia
	{  { -200.369964, 190.755477, -2143.968750 }, 1.0, 0.0 },  // Virage vers entraîneur
	{  { -3262.129882, -95.736076, -2143.968750 }, 1.0, 90.0 },  // Virage vers mercenaire
	{  { -2985.893066, -2364.554199, -2015.968750 }, 1.0, 0.0 },  //Virage vers l'arrivée
	{  { 393.868713, -2366.478515, -2015.968750 }, 2.0, 0.0 } // Arrivée 
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

public void OnAllPluginsLoaded() 
{
	g_iQuest = rp_RegisterQuest(QUEST_UNIQID, QUEST_NAME, QUEST_TYPE, fwdCanStart);
	
	if (g_iQuest == -1)
		SetFailState("Erreur lors de la création de la quête %s %s", QUEST_UNIQID, QUEST_NAME);
	
	int i;
	rp_QuestAddStep(g_iQuest, i++, Q1_Start, Q1_Frame, Q1_Abort, QUEST_NULL);
	
	for (int j = 0; j < 3; j++) {
		rp_QuestAddStep(g_iQuest, i++, Q2_Start, Q2_Frame, Q1_Abort, Q2_Done);
		rp_QuestAddStep(g_iQuest, i++, Q3_Start, Q3_Frame, Q1_Abort, Q3_Done);
	}
	
	rp_QuestAddStep(g_iQuest, i++, Q4_Start, Q4_Frame, Q1_Abort, QUEST_NULL);
}

// ----------------------------------------------------------------------------

public bool fwdCanStart(int client)
{
	for (int i = 0; i < MaxClients; i++) {
		if(!IsValidClient(i))
			continue;
			
		if(rp_GetClientJobID(i) == 51)
			return true;
	}
	
	return false; // return false
}

int BeamSpriteCircle;

public void OnMapStart()
{
	PrecacheSound("ui/competitive_accept_beep.wav", true);
	PrecacheSound("ui/beep07.wav", true);
	PrecacheSound("ui/xp_milestone_05.wav", true);
	BeamSpriteCircle = PrecacheModel("materials/sprites/laserbeam.vmt", true);
}

public void Q1_Start(int objectiveID, int client)
{
	char s[512];
	Format(s, sizeof(s), "Fournissez-vous une mustang auprès d'un carshop.");
	if(rp_IsClientNew(client))
	{
		Format(s, sizeof(s), "%s\nAstuce : utilisez /job pour appeller un carshop.", s);
	}
	
	String_WordWrap(s, 40);
	
	g_iEssai[client] = 3;
	g_iSkip[client] = 0; // 0 = course, 1 = en attente d'un choix, 2 = Pas d'autre essai, 3 = déjà reçu la récompense
	g_bRecompense[client] = false;
	
	Menu menu = new Menu(MenuNothing);
	
	menu.SetTitle("Quête: %s", QUEST_NAME);
	menu.AddItem("", s, ITEMDRAW_DISABLED);
	menu.ExitButton = false;
	menu.Display(client, MENU_TIME_FOREVER);
	
	g_iDuration[client] = 10 * 60;
	
	char tmp[64], query[512];
	GetClientAuthId(client, AUTH_TYPE, tmp, sizeof(tmp));
	Format(query, sizeof(query), "SELECT MIN(`duration`) FROM `rp_course` WHERE `steamid`='%s';", tmp);
	SQL_TQuery(rp_GetDatabase(), SQL_GetBestTime, query, client, DBPrio_Low);
}

public void SQL_GetBestTime(Handle owner, Handle hQuery, const char[] error, any client) 
{
	g_flBestTime[client] = 9999999.9;
	
	if( SQL_FetchRow(hQuery) ) {
		g_flBestTime[client] = SQL_FetchFloat(hQuery, 0);
	}
}

public void Q1_Frame(int objectiveID, int client)
{
	g_iDuration[client]--;
	
	if (rp_GetClientVehicle(client) > 0)
	{
		g_iVehicle[client] = rp_GetClientVehicle(client);
		rp_QuestStepComplete(client, objectiveID);
	}
	else if (g_iDuration[client] <= 0)
		rp_QuestStepFail(client, objectiveID);
	else {
		PrintHintText(client, "<b>Quête</b>: %s\n<b>Temps restant</b>: %dsec\n<b>Objectif</b>: %s", QUEST_NAME, g_iDuration[client], QUEST_RESUME1);
	}
}

public void Q1_Abort(int objectiveID, int client)
{
	PrintHintText(client, "<b>Quête</b>: %s\nLa quête est terminée.", QUEST_NAME);
}

// ----------------------------------------------------------------------------

public void Q2_Start(int objectiveID, int client)
{	
	if(g_iSkip[client] != 0)
	{
		rp_QuestStepComplete(client, objectiveID);
	}
	else
	{
		g_iStep[client] = 0;
		
		char s[512];
		
		if(!IsValidEntity(g_iVehicle[client]))
		{
			rp_QuestStepFail(client, objectiveID);
			return;
		}
		
		SDKHook(g_iVehicle[client], SDKHook_Think, OnThink);
		
		if(g_iEssai[client] < 3 && g_iEssai[client] >= 1)
		{	
			Menu menu = new Menu(MenuEssai);
			Format(s, sizeof(s), "Voulez-vous à nouveau tenter de battre le record ? (%d essai%s)", g_iEssai[client], g_iEssai[client] > 1 ? "s" : "");
			menu.SetTitle(s, QUEST_NAME);
			menu.AddItem("0", "Oui");
			menu.AddItem("1", "Non");
			menu.Display(client, MENU_TIME_FOREVER);
			
			g_iQ2[client] = objectiveID;
			g_iSkip[client] = 1;
		}
		else
		{
			Format(s, sizeof(s), "Rendez-vous au départ de la course. Il vous reste %d essai%s.", g_iEssai[client], g_iEssai[client] > 1 ? "s" : "");
			String_WordWrap(s, 40);
			
			Menu menu = new Menu(MenuNothing);
			
			menu.SetTitle("Quête: %s", QUEST_NAME);
			menu.AddItem("", s, ITEMDRAW_DISABLED);
			menu.ExitButton = false;
			menu.Display(client, MENU_TIME_FOREVER);
		}
		
		g_iDuration[client] = 6 * 60;
	
	}
}

public void Q2_Frame(int objectiveID, int client)
{
	g_iDuration[client]--;
	
	float pos[3], origin[3];
	
	pos = g_fPos[0][0];
	
	ServerCommand("sm_effect_gps %d %f %f %f", client, pos[0], pos[1], pos[2]);
	
	if (rp_GetClientVehicle(client) > 0 && g_iEssai[client] != 0)
	{
		if(!IsValidEntity(g_iVehicle[client]))
		{
			rp_QuestStepFail(client, objectiveID);
			return;
		}
		
		Entity_GetAbsOrigin(g_iVehicle[client], origin);
		
		if (GetVectorDistance(g_fPos[0][0], origin) < 256 && g_iSkip[client] != 1)
		{
			rp_QuestStepComplete(client, objectiveID);
		}
	}
	else if (g_iDuration[client] <= 0)
		rp_QuestStepFail(client, objectiveID);
	else {
		PrintHintText(client, "<b>Quête</b>: %s\n<b>Temps restant</b>: %dsec\n<b>Objectif</b>: %s", QUEST_NAME, g_iDuration[client], QUEST_RESUME1);
	}
}

public void Q2_Done(int objectiveID, int client)
{
	if(g_iSkip[client] != 0)
		return;
	
	//Entity_SetCollisionGroup(g_iVehicle[client], COLLISION_GROUP_DEBRIS);
	
	float angle[3];
	
	angle[1] = 90.0;
	
	TeleportEntity(g_iVehicle[client], g_fPos[0][0], angle, NULL_VECTOR);
	AcceptEntityInput(g_iVehicle[client], "TurnOff");
	
	CPrintToChat(client, ""...MOD_TAG..." Départ dans 3 secondes...");
	
	Circle(client, 0, 5.0);

	CreateTimer(1.0, Timer_1, client);
	CreateTimer(2.0, Timer_2, client);
	CreateTimer(3.0, Timer_3, client);

	g_iStep[client] = 1;
	g_flTemps[client] = GetGameTime();
}

// ----------------------------------------------------------------------------

public void Q3_Start(int objectiveID, int client)
{
	if(g_iSkip[client] != 0)
	{
		rp_QuestStepComplete(client, objectiveID);
	}
	else
	{
		char s[512];
		Format(s, sizeof(s), "Passez par tous les checkpoints le plus vite possible pour finir la course.");
		String_WordWrap(s, 40);
		
		Menu menu = new Menu(MenuNothing);
		
		menu.SetTitle("Quête: %s", QUEST_NAME);
		menu.AddItem("", s, ITEMDRAW_DISABLED);
		menu.ExitButton = false;
		menu.Display(client, MENU_TIME_FOREVER);
		
		g_iDuration[client] = 10 * 60;
	}
}

public void Q3_Frame(int objectiveID, int client)
{
	g_iDuration[client]--;
	
	if (g_iStep[client] == CHECKPOINTS)
	{
		rp_QuestStepComplete(client, objectiveID);
	}
	else if (g_iDuration[client] <= 0)
		rp_QuestStepFail(client, objectiveID);
	else {
		Circle(client, g_iStep[client]);
	
		if (g_iStep[client] != CHECKPOINTS - 1)
			Circle(client, g_iStep[client] + 1);

		PrintHintText(client, "<b>Quête</b>: %s\n<b>Temps restant</b>: %dsec\n<b>Objectif</b>: %s", QUEST_NAME, g_iDuration[client], QUEST_RESUME1);
	}
}

public void Q3_Done(int objectiveID, int client)
{	
	if(g_bRecompense[client])
		return;
	
	bool record = false;

	float time = GetGameTime() - g_flTemps[client];
	if( g_flBestTime[client] > time ) {
		g_flBestTime[client] = time;
		record = true;
		CPrintToChat(client, ""...MOD_TAG..." Nouveau record!");
	}
	
	CPrintToChat(client, ""...MOD_TAG..." Temps final = %.1f secondes, meilleur temps: %.1f.", time, g_flBestTime[client]);
	
	char tmp[64], query[512];
	GetClientAuthId(client, AUTH_TYPE, tmp, sizeof(tmp));
	Format(query, sizeof(query), "INSERT INTO `rp_course` (`steamid`, `time`, `duration`) VALUES ('%s', UNIX_TIMESTAMP(), '%f');", tmp, time);
	SQL_TQuery(rp_GetDatabase(), SQL_QueryCallBack, query, 0, DBPrio_Low);
	
	if( record ) 
	{
		giveGain(client);
	}	
	
	g_iEssai[client]--;
}

// ----------------------------------------------------------------------------

public void Q4_Start(int objectiveID, int client)
{
	// On donne 1000 dans tous les cas
	int cap = rp_GetRandomCapital(1);
	rp_SetJobCapital(cap, rp_GetJobCapital(cap) - 1000);
	rp_ClientXPIncrement(client, 250);
	rp_ClientMoney(client, i_AddToPay, 1000);
	CPrintToChat(client, ""...MOD_TAG..." Vous venez de recevoir {lightgreen}%d${default}.", 1000);
	
	Menu menu = new Menu(MenuNothing);
	menu.SetTitle("Quête: %s", QUEST_NAME);
	menu.ExitButton = false;
	menu.Display(client, 1);
	
	g_iDuration[client] = 1 * 60;
}

public void Q4_Frame(int objectiveID, int client)
{
	rp_QuestStepComplete(client, objectiveID);
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

public int MenuEssai(Handle menu, MenuAction action, int client, int param2) {
	if (action == MenuAction_Select) 
	{
		char options[128];
		GetMenuItem(menu, param2, options, sizeof(options));
		
		if(StrEqual(options, "1"))
		{		
			g_iSkip[client] = 2;
			
			SDKUnhook(g_iVehicle[client], SDKHook_Think, OnThink);
			
			g_iEssai[client] = 0;
			g_bRecompense[client] = true;
			
			rp_QuestStepComplete(client, g_iQ2[client]);
		}
		else
		{
			// Le joueur veut re-tenter
			g_iSkip[client] = 0;
		}
	
	}
	else if (action == MenuAction_End) {
		if (menu != INVALID_HANDLE)
			CloseHandle(menu);
	}
}

void Circle(int client, int step, float time = 1.01)
{
	if(!IsValidClient(client))
		return;
	
	float pos[3], ang[3], src[3], dst[3], vector[3];
	pos = g_fPos[step][0];
	ang[1] = g_fPos[step][2][0];
	ang[2] = 270.0;
	
	vector[0] = 0.0;
	vector[1] = 0.0;
	vector[2] = 128.0;
	
	int couleur[4];
	
	float color = g_fPos[step][1][0];
	
	if (color == 1.0)
	{
		couleur =  { 0, 0, 255, 255 };
	}
	else if (color == 2.0)
	{
		couleur =  { 255, 0, 0, 255 };
	}
	else if (color == 0.0)
	{
		couleur =  { 0, 255, 0, 255 };
	}
	
	while (ang[2] <= 450)
	{
		Math_RotateVector(vector, ang, dst);
		AddVectors(dst, pos, dst);
		
		if (ang[2] != 270.0)
		{
			TE_SetupBeamPoints(src, dst, BeamSpriteCircle, 0, 0, 0, time, 32.0, 32.0, 5, 0.0, couleur, 3);
			TE_SendToClient(client);
		}
		
		src = dst;
		
		ang[2] += 180 / 20;
	}
}

public Action Timer_1(Handle timer, any client)
{
	EmitSoundToClient(client, "ui/beep07.wav");
	CPrintToChat(client, ""...MOD_TAG..." Départ dans 2 secondes...");
}

public Action Timer_2(Handle timer, any client)
{
	EmitSoundToClient(client, "ui/beep07.wav");
	CPrintToChat(client, ""...MOD_TAG..." Départ dans 1 secondes...");
}

public Action Timer_3(Handle timer, any client)
{
	AcceptEntityInput(g_iVehicle[client], "TurnOn");
	ActivateEntity(g_iVehicle[client]);
	AcceptEntityInput(g_iVehicle[client], "TurnOn");

	EmitSoundToClient(client, "ui/beep07.wav");
	CPrintToChat(client, ""...MOD_TAG..." GO !!");
}

public void OnThink(int entity)
{
	
	int client = rp_GetVehicleInt(entity, car_owner);
	if(!IsValidEntity(g_iVehicle[client]))
		return;
	
	if(!IsValidClient(client) || g_iStep[client] == CHECKPOINTS)
	{
		SDKUnhook(entity, SDKHook_Think, OnThink);
		return;
	}
	
	float pos[3], origin[3];
	
	pos = g_fPos[g_iStep[client]][0];
	
	Entity_GetAbsOrigin(g_iVehicle[client], origin);

	if (GetVectorDistance(pos, origin) < 128 && !g_bVerif[client])
	{
		EmitSoundToClient(client, "ui/xp_milestone_05.wav");
		g_bVerif[client] = true;
		g_iStep[client]++;
	}
	else
	{
		g_bVerif[client] = false;
	}
}

void giveGain(int client)
{
	int cap = rp_GetRandomCapital(1);
	rp_SetJobCapital(cap, rp_GetJobCapital(cap) - 3000);
	rp_ClientXPIncrement(client, 750);
	rp_ClientMoney(client, i_AddToPay, 3000);
	CPrintToChat(client, ""...MOD_TAG..." Vous venez de recevoir {lightgreen}%d${default}.", 3000);
}