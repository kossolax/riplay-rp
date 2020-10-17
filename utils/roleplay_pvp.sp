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
#include <basecomm>
#include <topmenus>
#include <smlib>		// https://github.com/bcserv/smlib
#include <colors_csgo>	// https://forums.alliedmods.net/showthread.php?p=2205447#post2205447
#include <emitsoundany> // https://forums.alliedmods.net/showthread.php?t=237045

#pragma newdecls required
#include <roleplay.inc>	// https://www.ts-x.eu

enum quest_teams {
	TEAM_NONE,
	TEAM_RED,
	TEAM_BLUE,
	TEAM_PENDING,
	TEAM_BANNED,
	
	TEAM_MAX
};
#define		ACCELERATION_FACTOR	4
#define		LEAVING_TIME		(30/ACCELERATION_FACTOR)

// -----------------------------------------------------------------------------------------------------------------
enum flag_data { data_group, data_skin, data_red, data_green, data_blue, data_time, data_owner, data_lastOwner, flag_data_max };
int g_iClientFlag[65];
float g_fLastDrop[65], g_flClientLastScore[65];
int g_iFlagData[MAX_ENTITIES+1][view_as<int>(flag_data_max)];
// -----------------------------------------------------------------------------------------------------------------
Handle g_hCapturable = INVALID_HANDLE;
Handle g_hGodTimer[65], g_hKillTimer[65];
bool g_bIsInCaptureMode = false;
int g_cBeam;
StringMap g_hGlobalDamage, g_hGlobalSteamID;
enum damage_data { gdm_shot, gdm_touch, gdm_damage, gdm_hitbox, gdm_elo, gdm_flag, gdm_kill, gdm_team, gdm_score, gdm_area, gdm_max };
TopMenu g_hStatsMenu;
TopMenuObject g_hStatsMenu_Shoot, g_hStatsMenu_Head, g_hStatsMenu_Damage, g_hStatsMenu_Flag, g_hStatsMenu_ELO, g_hStatsMenu_SCORE, g_hStatsMenu_KILL;
int g_iPlayerTeam[2049], g_stkTeam[view_as<int>(TEAM_MAX)][MAXPLAYERS + 1], g_stkTeamCount[view_as<int>(TEAM_MAX)], g_iTeamScore[view_as<int>(TEAM_MAX)];
int g_iScores[MAX_GROUPS];
int g_iLeaving[65];

// -----------------------------------------------------------------------------------------------------------------
enum pvp_state {
	ps_none,
	ps_begin,
	ps_team,
	ps_warmup1, ps_match1, ps_end_of_round1,
	ps_switch,
	ps_warmup2, ps_match2, ps_end_of_round2,
	ps_reward,
	ps_end,
	ps_max
};
int g_iRoundTime[view_as<int>(ps_max)] =  {
	0,
	5,
	0,
	3, 12, 0,
	0,
	3, 12, 0,
	0
};
char g_szRoundName[view_as<int>(ps_max)][128] = {
	"Aucun",
	"Invitation des joueurs",
	"TEAM",
	"ROUND - 1 (WARMUP)", "ROUND - 1", "ROUND - 1 (FIN)",
	"SWITCH",
	"ROUND - 2 (WARMUP)", "ROUND - 2", "ROUND - 2 (FIN)",
	"Distribution",
	"FIN"
};
int g_iCurrentState = ps_none;
int g_iCurrentTimer;
int g_iCurrentStart;

// -----------------------------------------------------------------------------------------------------------------
enum soundList {
	snd_YouHaveTheFlag,
	snd_YouAreOnBlue, snd_YouAreOnRed,
	snd_30SecondsRemain, snd_1MinuteRemain, snd_5MinutesRemain,
	snd_NewRoundIn, snd_EndOfRound, snd_FinalRound, snd_Play,
	snd_Congratulations, snd_YouHaveLostTheMatch, snd_FlawlessVictory, snd_HumiliatingDefeat,
	snd_YouAreLeavingTheBattlefield,
	snd_FirstBlood,
	snd_DoubleKill, snd_MultiKill, snd_MegaKill, snd_UltraKill, snd_MonsterKill,
	snd_KillingSpree, snd_Unstopppable, snd_Dominating, snd_Godlike,
	
	snd_CountDown10, snd_CountDown09, snd_CountDown08, snd_CountDown07, snd_CountDown06,
	snd_CountDown05, snd_CountDown04, snd_CountDown03, snd_CountDown02, snd_CountDown01,
	
	snd_TenKillsRemain, snd_FiveKillsRemain, snd_OneKillRemains,
	
	snd_RedCoreIsUnderAttack, 
	snd_BarricadeDestroyed, snd_InnerBarricadeDestroyed, snd_OuterBarricadeDestroyed,
	
};
enum announcerData {
	ann_Client,
	ann_SoundID,
	ann_Time,
	ann_max
};
char g_szSoundList[soundList][] = {
	"DeadlyDesire/announce/YouHaveTheFlag.mp3",
	"DeadlyDesire/announce/YouAreOnBlue.mp3",
	"DeadlyDesire/announce/YouAreOnRed.mp3",

	"DeadlyDesire/announce/30SecondsLeft.mp3",
	"DeadlyDesire/announce/1MinutesRemain.mp3",
	"DeadlyDesire/announce/5MinutesRemain.mp3",
	
	"DeadlyDesire/announce/NewRoundIn.mp3",
	"DeadlyDesire/announce/EndOfRound.mp3",
	"DeadlyDesire/announce/FinalRound.mp3",
	"DeadlyDesire/announce/Play.mp3",
	
	"DeadlyDesire/announce/Congratulations.mp3",
	"DeadlyDesire/announce/YouHaveLostTheMatch.mp3",
	"DeadlyDesire/announce/FlawlessVictory.mp3",
	"DeadlyDesire/announce/HumiliatingDefeat.mp3",
	
	"DeadlyDesire/announce/YouAreLeavingTheBattlefield.mp3",
	
	"DeadlyDesire/announce/FristBlood.mp3",
	
	"DeadlyDesire/announce/DoubleKill.mp3",
	"DeadlyDesire/announce/MultiKill.mp3",
	"DeadlyDesire/announce/MegaKill.mp3",
	"DeadlyDesire/announce/UltraKill.mp3",
	"DeadlyDesire/announce/MonsterKill.mp3",
	
	"DeadlyDesire/announce/KillingSpree.mp3",
	"DeadlyDesire/announce/Unstopppable.mp3",
	"DeadlyDesire/announce/Dominating.mp3",
	"DeadlyDesire/announce/Godlike.mp3",
	
	"DeadlyDesire/announce/Countdown_10.mp3",
	"DeadlyDesire/announce/Countdown_09.mp3",
	"DeadlyDesire/announce/Countdown_08.mp3",
	"DeadlyDesire/announce/Countdown_07.mp3",
	"DeadlyDesire/announce/Countdown_06.mp3",
	"DeadlyDesire/announce/Countdown_05.mp3",
	"DeadlyDesire/announce/Countdown_04.mp3",
	"DeadlyDesire/announce/Countdown_03.mp3",
	"DeadlyDesire/announce/Countdown_02.mp3",
	"DeadlyDesire/announce/Countdown_01.mp3",
	
	"DeadlyDesire/announce/TenKillsRemain.mp3",
	"DeadlyDesire/announce/FiveKillsRemain.mp3",
	"DeadlyDesire/announce/OneKillRemains.mp3",
	
	"DeadlyDesire/announce/RedCoreIsUnderAttack.mp3",
	
	"DeadlyDesire/announce/BarricadeDestroyed.mp3",
	"DeadlyDesire/announce/InnerBarricadeDestroyed.mp3",
	"DeadlyDesire/announce/OuterBarricadeDestroyed.mp3"	
};
int g_CyclAnnouncer[MAX_ANNOUNCES][view_as<int>(announcerData)], g_CyclAnnouncer_start, g_CyclAnnouncer_end;
int g_iKillingSpree[65], g_iKilling[65];
bool g_bStopSound[65];
bool g_bFirstBlood, g_b5MinutesLeft, g_b30SecondsLeft, g_b1MinuteLeft, g_bCountDown[11];
// -----------------------------------------------------------------------------------------------------------------
public Plugin myinfo = {
	name = "Utils: PvP", author = "KoSSoLaX",
	description = "RolePlay - Utils: PvP",
	version = __LAST_REV__, url = "https://www.ts-x.eu"
};
public void OnPluginStart() {
	LoadTranslations("core.phrases");
	LoadTranslations("roleplay.phrases");
	
	RegConsoleCmd("drop", FlagDrop);
	RegServerCmd("rp_item_spawnflag", 	Cmd_ItemFlag,			"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_spawntag",	Cmd_SpawnTag,			"RP-ITEM",	FCVAR_UNREGISTERED);
	
	g_hGlobalDamage = new StringMap();
	g_hGlobalSteamID = new StringMap();
	
	for (int i = 1; i <= MaxClients; i++)
		if( IsValidClient(i) )
			OnClientPostAdminCheck(i);
	
	//char szDayOfWeek[12];
	//FormatTime(szDayOfWeek, 11, "%w");
	//if( StringToInt(szDayOfWeek) == 3 || StringToInt(szDayOfWeek) == 5 ) { // Mercredi & Vendredi
	//	ServerCommand("tv_enable 1");
	//}
	
}
public void OnConfigsExecuted() {
	if( g_hCapturable == INVALID_HANDLE ) {
		g_hCapturable = FindConVar("rp_capture");
		HookConVarChange(g_hCapturable, OnCvarChange);
	}
	char szDayOfWeek[12];
	FormatTime(szDayOfWeek, 11, "%w");
	if( StringToInt(szDayOfWeek) == 3 || StringToInt(szDayOfWeek) == 5 ) { // Mercredi & Vendredi
		//ServerCommand("tv_enable 1");
		//ServerCommand("mp_restartgame 1");
		//ServerCommand("spec_replay_enable 1");
		//ServerCommand("tv_snapshotrate 64");
		//ServerCommand("rp_wallhack 0");
	}
}
public void OnMapStart() {
	g_cBeam = PrecacheModel("materials/sprites/laserbeam.vmt");
	
	char tmp[PLATFORM_MAX_PATH];
	for (int i = 0; i < sizeof(g_szSoundList); i++) {
		PrecacheSoundAny(g_szSoundList[i]);
		Format(tmp, sizeof(tmp), "sound/%s", g_szSoundList[i]);
		AddFileToDownloadsTable(tmp);
	}
}
public void OnCvarChange(Handle cvar, const char[] oldVal, const char[] newVal) {
	if( cvar == g_hCapturable ) {
		if( !g_bIsInCaptureMode && StrEqual(oldVal, "0") && StrEqual(newVal, "1") ) {
			CAPTURE_Start();
		}
		if( g_bIsInCaptureMode && StrEqual(oldVal, "1") && StrEqual(newVal, "0") ) {
			CAPTURE_Stop();
		}
	}
}
public void OnClientPostAdminCheck(int client) {
	rp_HookEvent(client, RP_OnPlayerCommand, fwdCommand);
	g_bStopSound[client] = false;
			
	if( g_bIsInCaptureMode ) {
		GDM_Init(client);
		rp_HookEvent(client, RP_OnPlayerDead, fwdDead);
		rp_HookEvent(client, RP_OnPlayerHUD, fwdHUD);
		rp_HookEvent(client, RP_OnPlayerSpawn, fwdSpawn);
		rp_HookEvent(client, RP_OnFrameSeconde, fwdFrame);
		rp_HookEvent(client, RP_PreTakeDamage, fwdTakeDamage);
		rp_HookEvent(client, RP_OnPlayerZoneChange, fwdZoneChange);
		rp_HookEvent(client, RP_PreClientStealItem, fwdStealItem);
	}
}
public void OnClientDisconnect(int client) {
	removeClientTeam(client);
}
// -----------------------------------------------------------------------------------------------------------------
public Action Cmd_SpawnTag(int args) {
	static iPrecached[MAX_GROUPS];
	
	char gang[64], path[128];	
	int client = GetCmdArgInt(1);
	int item_id = GetCmdArgInt(args);
	int groupID = rp_GetClientGroupID(client);
	
	if( groupID == 0 ) {
		ITEM_CANCEL(client, item_id);
		return Plugin_Handled;
	}
	rp_GetGroupData(groupID, group_type_tag, gang, sizeof(gang));
	
	Format(path, sizeof(path), "deadlydesire/groups/princeton/%s_small.vmt", gang);
	
	if( !IsDecalPrecached(path) || iPrecached[groupID] < 0 ) {
		iPrecached[groupID] = PrecacheDecal(path);
	}
	
	float origin[3], origin2[3], angles[3];
	GetClientEyeAngles(client, angles);
	GetClientEyePosition(client, origin);
	
	Handle tr = TR_TraceRayFilterEx(origin, angles, MASK_SOLID, RayType_Infinite, FilterToOne, client);
	if( tr && TR_DidHit(tr) ) {
		TR_GetEndPosition(origin2, tr);
		if( GetVectorDistance(origin, origin2) <= 128.0 ) {
			
			TE_Start("World Decal");
			TE_WriteVector("m_vecOrigin",origin2);
			TE_WriteNum("m_nIndex", iPrecached[groupID]);
			TE_SendToAll();
			
			rp_IncrementSuccess(client, success_list_graffiti);
		}
		else {
			CloseHandle(tr);
			ITEM_CANCEL(client, item_id);
		}
	}
	else {
		CloseHandle(tr);
		ITEM_CANCEL(client, item_id);
	}
	CloseHandle(tr);
	return Plugin_Handled;
}
public Action Cmd_ItemFlag(int args) {
	
	int client = GetCmdArgInt(1);
	int item_id = GetCmdArgInt(args);
	int gID = g_iPlayerTeam[client];
	
	if( rp_GetClientGroupID(client) == 0 ) {
		ITEM_CANCEL(client, item_id);
		CPrintToChat(client, "" ...MOD_TAG... " Vous n'avez pas de groupe.");
		return;
	}
	if( g_iCurrentState != view_as<int>(ps_none) && gID == view_as<int>(TEAM_NONE) ) {
		ITEM_CANCEL(client, item_id);
		CPrintToChat(client, "" ...MOD_TAG... " Vous n'avez pas d'équipe.");
		return;
	}
	if( gID == view_as<int>(TEAM_RED) ) {
		ITEM_CANCEL(client, item_id);
		CPrintToChat(client, "" ...MOD_TAG... " Le gang défenseur ne peut pas utiliser de drapeau.");
		return;
	}
	if( rp_GetZoneBit(rp_GetPlayerZone(client)) & BITZONE_PVP ) {
		ITEM_CANCEL(client, item_id);
		CPrintToChat(client, "" ...MOD_TAG... " Vous devez être en dehors du bunker.");
		return;
	}
	
	if( g_iClientFlag[client] > 0 && IsValidEdict(g_iClientFlag[client]) && IsValidEntity(g_iClientFlag[client]) ) {
		ITEM_CANCEL(client, item_id);
		CPrintToChat(client, "" ...MOD_TAG... " Vous avez déjà un drapeau.");
		return;
	}
	
	if( GDM_GetFlagCount(client) >= FLAG_MAX ) {
		ITEM_CANCEL(client, item_id);
		CPrintToChat(client, "" ...MOD_TAG... " Vous avez déjà planté %d drapeaux.", FLAG_MAX);
		return;
	}
	
	char classname[64];
	int stackDrapeau[MAX_ENTITIES], stackCount;

	for(int i=MaxClients; i<MAX_ENTITIES; i++) {
		if( !IsValidEdict(i) )
			continue;
		if( !IsValidEntity(i) )
			continue;
		
		GetEdictClassname(i, classname, sizeof(classname));
		if( !StrEqual(classname, "ctf_flag") )
			continue;
		
		if( g_iFlagData[i][data_group] == gID ) {
			stackDrapeau[stackCount++] = i;
		}
	}
	if( stackCount >= 2 ) {
		bool can = false;
		for (int i = 0; i < stackCount; i++) {
			if( IsValidClient(g_iFlagData[ stackDrapeau[i] ][data_owner]) )
				continue;
			rp_AcceptEntityInput(stackDrapeau[i], "KillHierarchy");
			can = true;
			break;
		}
		
		if( !can ) {
			CPrintToChat(client, "" ...MOD_TAG... " Il y a déjà 2 drapeaux pour votre équipe sur le terrain.");
			ITEM_CANCEL(client, item_id);
			return;
		}
	}
	
	float vecOrigin[3];
	GetClientAbsOrigin(client, vecOrigin); vecOrigin[2] += 10.0;
	
	int flag = CTF_SpawnFlag(vecOrigin, Math_GetRandomInt(0, 1), {0, 0, 255});
	g_iFlagData[flag][data_group] = rp_GetClientGroupID(client);
	g_iPlayerTeam[flag] = gID;
}
public Action FlagDrop(int client, int args) {
	if( g_iClientFlag[client] > 0 ) {
		
		CTF_DropFlag(client, true);
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}
public Action FlagThink(Handle timer, any data) {
	int entity = EntRefToEntIndex(data);
	
	if( !IsValidEdict(entity) )
		return Plugin_Handled;
	
	float vecOrigin[3];
	int color[4];
	color[0] = g_iFlagData[entity][data_red];
	color[1] = g_iFlagData[entity][data_green];
	color[2] = g_iFlagData[entity][data_blue];
	color[3] = 200;
	
	if( IsValidClient(g_iFlagData[entity][data_owner]) ) {
		return Plugin_Handled;
	}
	
	if( g_bIsInCaptureMode ) {
		if( rp_GetPlayerZone(entity) == ZONE_BUNKER ) {
			
			if( g_iPlayerTeam[ entity ] == view_as<int>(TEAM_BLUE) ) {
				int point = RoundFloat(FLAG_POINT_MAX - ((FLAG_POINT_MAX - FLAG_POINT_MIN) * float(GetTime() - g_iCurrentStart) / float(g_iCurrentTimer)));
				
				g_iTeamScore[TEAM_BLUE] += point;
				
				GDM_RegisterFlag(g_iFlagData[entity][data_lastOwner], point);
				
				PrintHintText(g_iFlagData[entity][data_lastOwner], "Drapeau posé !\n <font color='#33ff33'>+%d</span> points !", point);
				g_flClientLastScore[g_iFlagData[entity][data_lastOwner]] = GetGameTime();
			}
			
			Entity_GetAbsOrigin(entity, vecOrigin);
			
			TE_SetupBeamRingPoint(vecOrigin, 1.0, 50.0, g_cBeam, g_cBeam, 0, 30, 2.0, 5.0, 1.0, color, 10, 0);
			TE_SendToAll();
			
			rp_AcceptEntityInput(entity, "KillHierarchy");
			return Plugin_Handled;
		}
	}
	
	if( g_iFlagData[entity][data_time]+60 < GetTime() ) {
		int gID = g_iPlayerTeam[entity];
		for(int i=1; i<=MaxClients; i++) {
			if( !IsValidClient(i) )
				continue;
			if( gID == g_iPlayerTeam[i] )
				ClientCommand(i, "play common/warning");
		}
		rp_AcceptEntityInput(entity, "KillHierarchy");
		return Plugin_Handled;
	}
	
	CreateTimer(0.25, FlagThink, data);
	return Plugin_Handled;
}
public Action SDKHideFlag(int from, int to ) {
	if( g_iFlagData[from][data_owner] == to && rp_GetClientInt(to, i_ThirdPerson) == 0) {
		return Plugin_Handled;
	}
	return Plugin_Continue;
}
// -----------------------------------------------------------------------------------------------------------------
void CAPTURE_Start() {
	CAPTURE_CHANGE_STATE(ps_begin);
	CreateTimer(1.0, CAPTURE_STATE_TICK);
}
void CAPTURE_Stop() {
	CAPTURE_CHANGE_STATE(ps_end);
}

public Action CAPTURE_STATE_TICK(Handle timer, any none) {
	
	if( GetTime() % 3 == 0 ) {
		int time, soundID, target;
		int NowTime = RoundToCeil(GetGameTime());
		bool found = CyclAnnouncer_Empty();
		
		while( !found  ) {
			time = g_CyclAnnouncer[g_CyclAnnouncer_end][ann_Time];
			soundID = g_CyclAnnouncer[g_CyclAnnouncer_end][ann_SoundID];
			target = g_CyclAnnouncer[g_CyclAnnouncer_end][ann_Client];
			
			g_CyclAnnouncer_end = (g_CyclAnnouncer_end+1) % MAX_ANNOUNCES;
			
			if( (time+ANNONCES_DELAY) >= NowTime && IsValidClient(target) ) {
				announceSound(target, soundID);
				found = true;
			}
			else {
				found = CyclAnnouncer_Empty();
			}
		}
	}
	
	int timeLeft = g_iCurrentStart + (g_iCurrentTimer) - GetTime();

	switch(g_iCurrentState) {
		case ps_begin: {
			STATE_TICK_BEGIN(timeLeft);
		}
		case ps_warmup1, ps_warmup2: {
			STATE_TICK_WARMUP(timeLeft);
		}
		case ps_match1, ps_match2: {
			STATE_TICK_MATCH(timeLeft);
		}
	}
	
	if( g_iCurrentState != view_as<int>(ps_none) )
		CreateTimer(1.0, CAPTURE_STATE_TICK);
}
void STATE_TICK_BEGIN(int timeLeft) {	
	if( timeLeft <= 0 ) {
		CAPTURE_CHANGE_STATE(ps_team);
	}
}
void warnLeaving(int client) {
	Menu menu = new Menu(MenuLeft);
	menu.SetTitle("=== Event PvP===\n\n ");
	
	// Page 1:
	menu.AddItem("", " Vous êtes entrain de quitter le champ de", ITEMDRAW_DISABLED);
	menu.AddItem("", "de bataille, alors que vous vous êtes engagé", ITEMDRAW_DISABLED);
	menu.AddItem("", "pour celui-ci.\n ", ITEMDRAW_DISABLED);
	
	menu.AddItem("", "Si vous n'y retournez pas rapidement, vous", ITEMDRAW_DISABLED);
	menu.AddItem("", "n'aurez pas de récompenses et vous ne pourrez pas", ITEMDRAW_DISABLED);
	menu.AddItem("", "participer à ce genre d'évènement pendant 7 jours\n ", ITEMDRAW_DISABLED);
	
	menu.AddItem("oui", "Je souhaite y retourner");
	menu.AddItem("non", "J'accepte d'être pénalisé.");
	menu.ExitButton = true;
	
	menu.Display(client, MENU_TIME_FOREVER);	
}
public int MenuLeft(Handle menu, MenuAction action, int client, int param2) {
	if( action == MenuAction_Select ) {
		char options[64];
		GetMenuItem(menu, param2, options, sizeof(options));
		
		if( !(g_iPlayerTeam[client] == view_as<int>(TEAM_RED) || g_iPlayerTeam[client] == view_as<int>(TEAM_BLUE)) ) {
			return;
		}
		
		if( StrEqual(options, "oui") ) {
			teleportToZone(client, g_iPlayerTeam[client] == view_as<int>(TEAM_RED) ? ZONE_RESPAWN : METRO_BELMON);
		}
		else if( StrEqual(options, "non") ) {
			g_iLeaving[client] = 99999;
		}
	}
	else if( action == MenuAction_End ) {
		CloseHandle(menu);
	}
}
void inviteToTeam(int client) {
	if( rp_GetClientInt(client, i_PVPBannedUntil) > GetTime() )
		return;
	
	Menu menu = new Menu(MenuInvite);
	menu.SetTitle("=== Event PvP===\n\n ");
	
	// Page 1:
	menu.AddItem("", " L'évènement se déroule en deux phases,", ITEMDRAW_DISABLED);
	menu.AddItem("", "de 15 minutes chacune. Il faudra", ITEMDRAW_DISABLED);
	menu.AddItem("", "collaborer avec vos coéquipiers pour", ITEMDRAW_DISABLED);
	menu.AddItem("", "remporter la victoire.\n ", ITEMDRAW_DISABLED);
	
	menu.AddItem("", "Vous serez amenés à utiliser de nombreux", ITEMDRAW_DISABLED);
	menu.AddItem("", "objets couteux pour être efficace.\n ", ITEMDRAW_DISABLED);
	
	// Page 2:
	menu.AddItem("", " Si vous acceptez l'invitation, vous ", ITEMDRAW_DISABLED);
	menu.AddItem("", "serrez assigné dans l'une des deux", ITEMDRAW_DISABLED);
	menu.AddItem("", "équipes où vous devrez défendre ou", ITEMDRAW_DISABLED);
	menu.AddItem("", "attaquer la base.\n ", ITEMDRAW_DISABLED);
	
	menu.AddItem("", " Si vous désertez, vous ne pourrez", ITEMDRAW_DISABLED);
	menu.AddItem("", "pas participer à la partie suivante.\n ", ITEMDRAW_DISABLED);
	
	// Page 3:
	menu.AddItem("", "A la fin de la partie, vous obtiendrez", ITEMDRAW_DISABLED);
	menu.AddItem("", "une récompense en fonction de vos.", ITEMDRAW_DISABLED);
	menu.AddItem("", "contributions personnelles.\n ", ITEMDRAW_DISABLED);
	
	menu.AddItem("", "Le gang ayant le plus de contributions", ITEMDRAW_DISABLED);
	menu.AddItem("", "remporte également des bonus exclusif", ITEMDRAW_DISABLED);
	menu.AddItem("", "pour la semaine.\n ", ITEMDRAW_DISABLED);

	// Page 4:
	
	menu.AddItem("oui", "J'accepte l'invitation");
	menu.AddItem("non", "Je refuse");
	menu.ExitButton = true;
	
	menu.Display(client, MENU_TIME_FOREVER);
}
public int MenuInvite(Handle menu, MenuAction action, int client, int param2) {
	if( action == MenuAction_Select ) {
		char options[64];
		GetMenuItem(menu, param2, options, sizeof(options));
		
		if( g_iPlayerTeam[client] != view_as<int>(TEAM_NONE) ) {
			return;
		}
		
		if( StrEqual(options, "oui") ) {
			addClientToTeam(client, TEAM_PENDING);
		}
		else if( StrEqual(options, "non") ) {
			rp_ClientSendToSpawn(client, true);
		}
	}
	else if( action == MenuAction_End ) {
		CloseHandle(menu);
	}
}
void STATE_TICK_WARMUP(int timeLeft) {
	if( timeLeft % 5 == 0 ) {
		
		if( g_stkTeamCount[TEAM_PENDING] > 0 ) {
			addClientToTeam(g_stkTeam[TEAM_PENDING][0], getWorstTeam());
		}
	}
	
	if( !g_b30SecondsLeft && timeLeft <= 30 ) {
		announceSound(0, snd_30SecondsRemain);
		g_b30SecondsLeft = true;
	}
	
	if( timeLeft <= 10 && timeLeft > 0 ) {
		if( !g_bCountDown[timeLeft] ) {
			int tmp = view_as<int>(snd_CountDown01) - timeLeft + 1;
			
			announceSound(0, tmp);
			g_bCountDown[timeLeft] = true;
		}
	}
	if( timeLeft <= 0 ) {
		CAPTURE_CHANGE_STATE(g_iCurrentState == view_as<int>(ps_warmup1) ? ps_match1 : ps_match2);
	}
}
void STATE_TICK_MATCH(int timeLeft) {
	if( timeLeft % 5 == 0 ) {
		
		for (int i = 0; i < g_stkTeamCount[TEAM_BLUE]; i++) {
			int client = g_stkTeam[TEAM_BLUE][i];
			
			if( rp_GetPlayerZone(client) == ZONE_BUNKER ) {
				GDM_RegisterArea(client);
				g_iTeamScore[TEAM_BLUE]++;
			}
		}
		
		if( g_stkTeamCount[TEAM_PENDING] > 0 ) {
			addClientToTeam(g_stkTeam[TEAM_PENDING][0], getWorstTeam());
		}
	}

	if( !g_b5MinutesLeft && timeLeft <= 5*60 ) {
		announceSound(0, snd_5MinutesRemain);
		g_b5MinutesLeft = true;
	}
	if( !g_b1MinuteLeft && timeLeft <= 1*60 ) {
		announceSound(0, snd_1MinuteRemain);
		g_b1MinuteLeft = true;
	}
	if( !g_b30SecondsLeft && timeLeft <= 30 ) {
		announceSound(0, snd_30SecondsRemain);
		g_b30SecondsLeft = true;
	}
		
	if( timeLeft <= 10 && timeLeft > 0 ) {
		if( !g_bCountDown[timeLeft] ) {
			int tmp = view_as<int>(snd_CountDown01) - timeLeft + 1;
			
			announceSound(0, tmp);
			g_bCountDown[timeLeft] = true;
		}
	}
	if( timeLeft <= 0 ) {
		CAPTURE_CHANGE_STATE(g_iCurrentState == view_as<int>(ps_match1) ? ps_end_of_round1 : ps_end_of_round2);
	}
}

void CAPTURE_CHANGE_STATE(int state) {
	g_iCurrentState = state;
	g_iCurrentTimer = g_iRoundTime[state] * 60 / ACCELERATION_FACTOR;
	g_iCurrentStart = GetTime();
	
	CAPTURE_STATE_ENTER();
}
void CAPTURE_STATE_ENTER() {
	switch(g_iCurrentState) {
		case ps_begin: {
			STATE_ENTER_BEGIN();
		}
		case ps_team: {
			STATE_ENTER_TEAM();
		}
		case ps_warmup1, ps_warmup2: {
			STATE_ENTER_WARMUP();
		}
		case ps_match1, ps_match2: {
			STATE_ENTER_MATCH();
		}
		case ps_end_of_round1, ps_end_of_round2: {
			STATE_ENTER_END_OF_ROUND();
		}
		case ps_switch: {
			STATE_ENTER_SWITCH();
		}
		case ps_reward: {
			STATE_ENTER_REWARD();
		}
		case ps_end: {
			STATE_ENTER_END();
		}
	}
}
void STATE_ENTER_BEGIN() {
	CPrintToChatAll("{lightblue} =================================={default} ");
	CPrintToChatAll("{lightblue} La capture du bunker est sur le point de commencer!{default} ");
	
	int wall = Entity_FindByName("job=201__-pvp_wall", "func_brush");
	if( wall > 0 )
		rp_AcceptEntityInput(wall, "Disable");
	
	
	g_bIsInCaptureMode = true;
	bool botFound = false;
	
	for(int i=0; i<MAX_GROUPS; i++)
		g_iScores[i] = 0;
	
	g_iTeamScore[TEAM_RED] = g_iTeamScore[TEAM_BLUE] = 0;

	for(int i=1; i<=MaxClients; i++) {
		if( !IsValidClient(i) )
			continue;
		
		if( IsClientSourceTV(i) ) {
			botFound = true;
			continue;
		}
		
		GDM_Init(i);
		rp_HookEvent(i, RP_OnPlayerDead, fwdDead);
		rp_HookEvent(i, RP_OnPlayerHUD, fwdHUD);
		rp_HookEvent(i, RP_OnPlayerSpawn, fwdSpawn);
		rp_HookEvent(i, RP_OnFrameSeconde, fwdFrame);
		rp_HookEvent(i, RP_PreTakeDamage, fwdTakeDamage);
		rp_HookEvent(i, RP_OnPlayerZoneChange, fwdZoneChange);
		rp_HookEvent(i, RP_PreClientStealItem, fwdStealItem);
		
		if( g_iPlayerTeam[i] == view_as<int>(TEAM_BLUE) ) {
			EmitSoundToClientAny(i, g_szSoundList[snd_YouAreOnBlue], _, 6, _, _, 1.0);
		}
		else if( g_iPlayerTeam[i] == view_as<int>(TEAM_RED) ) {
			EmitSoundToClientAny(i, g_szSoundList[snd_YouAreOnRed], _, 6, _, _, 1.0);
		}

	}
	for(int i=MaxClients; i<=2048; i++) {
		if( rp_IsValidVehicle(i) && rp_GetVehicleInt(i, car_health) >= 2500 )
			rp_SetVehicleInt(i, car_health, 2500);
		if( IsValidEdict(i) && IsValidEntity(i) && rp_GetWeaponBallType(i) == ball_type_braquage ) {
			
			if( Weapon_GetOwner(i) > 0 )
				RemovePlayerItem(Weapon_GetOwner(i), i);
			rp_AcceptEntityInput(i, "Kill");
		}
	}
	
	HookEvent("player_hurt", Event_PlayerHurt, EventHookMode_Post);
	HookEvent("weapon_fire", Event_PlayerShoot, EventHookMode_Post);
	HookEvent("player_hurt", fwdGod_PlayerHurt, EventHookMode_Pre);
	HookEvent("weapon_fire", fwdGod_PlayerShoot, EventHookMode_Pre);
	
	char szDayOfWeek[64];
	FormatTime(szDayOfWeek, sizeof(szDayOfWeek), "tv/pvp_%d-%m-%y");
	ServerCommand("tv_record %s", szDayOfWeek);
	ServerCommand("rp_wallhack 1");
	if( botFound ) {
		CPrintToChatAll("{lightblue} Cette capture est enregistrée à cette adresse: https://riplay.fr/tv/%s.dem", szDayOfWeek);
	}
	CPrintToChatAll("{lightblue} =================================={default} ");
}
void STATE_ENTER_TEAM() {
	shuffleTeams();
	CAPTURE_CHANGE_STATE(ps_warmup1);
}
void STATE_ENTER_WARMUP() {	
	for (int i = 1; i <= MaxClients; i++) {
		if( !IsValidClient(i) )
			continue;
		if( !IsPlayerAlive(i) )
			continue;
		
		if( rp_GetZoneBit(rp_GetPlayerZone(i)) & BITZONE_PVP ) {
			teleportToZone(i, g_iPlayerTeam[i] == view_as<int>(TEAM_RED) ? ZONE_RESPAWN : METRO_BELMON);
		}
	}
	
	g_b30SecondsLeft = false;
	for (int i = 0; i < sizeof(g_bCountDown); i++)
		g_bCountDown[i] = false;
}
void STATE_ENTER_MATCH() {
	CPrintToChatAll("{lightblue} =================================={default} ");
	CPrintToChatAll("{lightblue} Début du round!{default} ");
	CPrintToChatAll("{lightblue} =================================={default} ");
	g_bFirstBlood = g_b5MinutesLeft = g_b1MinuteLeft = g_b30SecondsLeft = false;
	for (int i = 0; i < sizeof(g_bCountDown); i++)
		g_bCountDown[i] = false;
	
	char classname[64];
	for(int i=MaxClients; i<MAX_ENTITIES; i++) {
		if( !IsValidEdict(i) )
			continue;
		if( !IsValidEntity(i) )
			continue;
		
		GetEdictClassname(i, classname, sizeof(classname));
		if( !StrEqual(classname, "ctf_flag") )
			continue;

		int owner = g_iFlagData[i][data_owner];

		if( owner == 0 || !IsValidClient(owner) ) {
			rp_AcceptEntityInput(i, "KillHierarchy");
			continue;
		}
		if( owner > 0 && g_iPlayerTeam[i] != view_as<int>(TEAM_BLUE) ) {
			rp_AcceptEntityInput(i, "KillHierarchy");
			continue;
		}		
	}
	
	if( g_iCurrentState == view_as<int>(ps_match1) ) {
		announceSound(0, snd_Play);
	}
	else {
		announceSound(0, snd_FinalRound);
	}
}
void STATE_ENTER_SWITCH() {
	StringMapSnapshot KeyList = g_hGlobalDamage.Snapshot();
	int[] array = new int[gdm_max];
	int nbrParticipant = KeyList.Length;
	char szSteamID[32];
	
	for (int i = 0; i < nbrParticipant; i++) {
		KeyList.GetKey(i, szSteamID, sizeof(szSteamID));
		g_hGlobalDamage.GetArray(szSteamID, array, gdm_max);
		
		if( array[gdm_team] == view_as<int>(TEAM_RED) ) {
			array[gdm_team] = view_as<int>(TEAM_BLUE);
		}
		else if( array[gdm_team] == view_as<int>(TEAM_BLUE) ) {
			array[gdm_team] = view_as<int>(TEAM_RED);
		}
		g_hGlobalDamage.SetArray(szSteamID, array, gdm_max);
	}
	
	for (int i = 1; i <= MaxClients; i++) {
		if( !IsValidClient(i) )
			continue;
		
		GetClientAuthId(i, AUTH_TYPE, szSteamID, sizeof(szSteamID));
		g_hGlobalDamage.GetArray(szSteamID, array, gdm_max);
		addClientToTeam(i, array[gdm_team]);
	}
	
	int tmp = g_iTeamScore[TEAM_BLUE];
	g_iTeamScore[TEAM_BLUE] = g_iTeamScore[TEAM_RED];
	g_iTeamScore[TEAM_RED] = tmp;
	
	announceSound(0, snd_EndOfRound);
	
	CAPTURE_CHANGE_STATE(ps_warmup2);
}
void STATE_ENTER_END_OF_ROUND() {
	
	CPrintToChatAll("{lightblue} =================================={default} ");
	CPrintToChatAll("{lightblue} Fin du round!{default} ");
	CPrintToChatAll("{lightblue} =================================={default} ");
	
	if( g_iCurrentState == view_as<int>(ps_end_of_round1) ) {
		CAPTURE_CHANGE_STATE(ps_switch);
	}
	else {
		CAPTURE_CHANGE_STATE(ps_reward);
	}
}
void STATE_ENTER_REWARD() {
	char tmp[64], optionsBuff[2][64];
	int winner, maxPoint, totalPoints;
	for(int i=1; i<MAX_GROUPS; i++) {
		if( maxPoint > g_iScores[i] )
			continue;

		winner = i;
		maxPoint = g_iScores[i];
		totalPoints += g_iScores[i];
	}
			
	rp_GetGroupData(winner, group_type_name, tmp, sizeof(tmp));
	ExplodeString(tmp, " - ", optionsBuff, sizeof(optionsBuff), sizeof(optionsBuff[]));
	
	if( rp_GetCaptureInt(cap_bunker) != winner ) {
		rp_SetCaptureInt(cap_pvpRow, 1);
	}
	else {
		rp_SetCaptureInt(cap_pvpRow, rp_GetCaptureInt(cap_pvpRow)+1);
	}
	
	char fmt[1024];
	Format(fmt, sizeof(fmt), "UPDATE `rp_servers` SET `bunkerCap`='%i', `capVilla`='%i', `pvpRow`='%i';", winner, winner, rp_GetCaptureInt(cap_pvpRow));
	SQL_TQuery( rp_GetDatabase(), SQL_QueryCallBack, fmt);
	rp_SetCaptureInt(cap_bunker, winner);
	rp_SetCaptureInt(cap_villa, winner);
	
	CPrintToChatAll("{lightblue} =================================={default} ");
	CPrintToChatAll("{lightblue} Le bunker appartient maintenant à... %s !", optionsBuff[1]);
	CPrintToChatAll("{lightblue} =================================={default} ");
	
	CAPTURE_Reward();
	GDM_Resume();
	
	CAPTURE_CHANGE_STATE(ps_end);
}
void STATE_ENTER_END() {
	
	int wall = Entity_FindByName("job=201__-pvp_wall", "func_brush");
	if( wall > 0 )
		rp_AcceptEntityInput(wall, "Enable");
	
	if( g_bIsInCaptureMode ) {
		for(int i=1; i<=MaxClients; i++) {
			if( !IsValidClient(i) )
				continue;
			rp_UnhookEvent(i, RP_OnPlayerDead, fwdDead);
			rp_UnhookEvent(i, RP_OnPlayerHUD, fwdHUD);
			rp_UnhookEvent(i, RP_OnPlayerSpawn, fwdSpawn);
			rp_UnhookEvent(i, RP_OnFrameSeconde, fwdFrame);
			rp_UnhookEvent(i, RP_PreTakeDamage, fwdTakeDamage);
			rp_UnhookEvent(i, RP_OnPlayerZoneChange, fwdZoneChange);
			rp_UnhookEvent(i, RP_PreClientStealItem, fwdStealItem);
	
			if( IsPlayerAlive(i) )
				rp_ClientColorize(i);
	
			removeClientTeam(i);
		}
		
		
		UnhookEvent("player_hurt", Event_PlayerHurt, EventHookMode_Post);
		UnhookEvent("weapon_fire", Event_PlayerShoot, EventHookMode_Post);
		UnhookEvent("player_hurt", fwdGod_PlayerHurt, EventHookMode_Pre);
		UnhookEvent("weapon_fire", fwdGod_PlayerShoot, EventHookMode_Pre);
	}
	g_bIsInCaptureMode = false;
	
	CAPTURE_UpdateLight();
	
	ServerCommand("tv_stoprecord");
	ServerCommand("rp_capture 0");
	//ServerCommand("rp_wallhack 0");
	
	CAPTURE_CHANGE_STATE(ps_none);
}
//
public Action fwdCommand(int client, char[] command, char[] arg) {
	if( StrEqual(command, "pvp") ) {
		if( g_hStatsMenu != INVALID_HANDLE )
			g_hStatsMenu.Display(client, TopMenuPosition_Start);
		return Plugin_Handled;
	}
	if( StrEqual(command, "stopsound") ) {
		g_bStopSound[client] = !g_bStopSound[client];
		return Plugin_Handled;
	}
	return Plugin_Continue;
}
void CAPTURE_UpdateLight() {
	char strBuffer[4][32], tmp[64], tmp2[64];
	int color[4],  defense = rp_GetCaptureInt(cap_bunker);
	
	rp_GetGroupData(defense, group_type_color, tmp, sizeof(tmp));
	ExplodeString(tmp, ",", strBuffer, sizeof(strBuffer), sizeof(strBuffer[]));
	color[0] = StringToInt(strBuffer[0]);
	color[1] = StringToInt(strBuffer[1]);
	color[2] = StringToInt(strBuffer[2]);
	color[3] = 255;
	
	Format(tmp2, sizeof(tmp2), "%d %d %d", color[0], color[1], color[2]);
	
	for (int i = MaxClients; i <= MAX_ENTITIES; i++) {
		if( !IsValidEdict(i) || !IsValidEntity(i) )
			continue;
		
		GetEdictClassname(i, tmp, sizeof(tmp));
		if( StrEqual(tmp, "point_spotlight") && rp_IsInPVP(i) ) {
			SetVariantString(tmp2);
			rp_AcceptEntityInput(i, "SetColor");
		}
	}
}
void CAPTURE_Reward() {
	int amount;
	char szSteamID[32];
	
	int bestTeam = g_iTeamScore[TEAM_RED] > g_iTeamScore[TEAM_BLUE] ? TEAM_RED : TEAM_BLUE;
	
	for(int client=1; client<=MaxClients; client++) {
		if( !IsValidClient(client) )
			continue;
		
		if( g_iPlayerTeam[client] == view_as<int>(TEAM_RED) || g_iPlayerTeam[client] == view_as<int>(TEAM_BLUE) ) {
			int gID = rp_GetClientGroupID(client);
			
			GetClientAuthId(client, AUTH_TYPE, szSteamID, sizeof(szSteamID));
			int[] array = new int[gdm_max];
			g_hGlobalDamage.GetArray(szSteamID, array, gdm_max);
			
			if( gID == rp_GetCaptureInt(cap_bunker) && g_iPlayerTeam[client] == bestTeam ) {
				amount = 10;
				rp_IncrementSuccess(client, success_list_pvpkill, 50);
				EmitSoundToClientAny(client, g_szSoundList[snd_FlawlessVictory], _, 6, _, _, 1.0);
			}
			else if( gID == rp_GetCaptureInt(cap_bunker) || g_iPlayerTeam[client] == bestTeam ) {
				amount = 5;
				rp_IncrementSuccess(client, success_list_pvpkill, 25);
				EmitSoundToClientAny(client, g_szSoundList[snd_Congratulations], _, 6, _, _, 1.0);
			}
			else {
				if( array[gdm_score] >= 100 && (array[gdm_flag] >= 1 || array[gdm_kill] >= 1) ) {
					amount = 1;
					EmitSoundToClientAny(client, g_szSoundList[snd_YouHaveLostTheMatch], _, 6, _, _, 1.0);
				}
				else {
					amount = 0;
					EmitSoundToClientAny(client, g_szSoundList[snd_HumiliatingDefeat], _, 6, _, _, 1.0);
				}
			}
			
			if( amount > 0 ) {
				char tmp[128];
				rp_ClientGiveItem(client, 215, amount, true);
				rp_GetItemData(215, item_type_name, tmp, sizeof(tmp));
				CPrintToChat(client, "" ...MOD_TAG... " Vous avez reçu %d %s, en récompense de la capture.", amount, tmp);
			}
			
			rp_ClientXPIncrement(client, array[gdm_score]);
		}
	}
}
// -----------------------------------------------------------------------------------------------------------------
public Action fwdSpawn(int client) {
	Client_SetSpawnProtect(client, true);
	SetEntityHealth(client, 500);
	rp_SetClientInt(client, i_Kevlar, 250);
	rp_SetClientFloat(client, fl_CoolDown, 0.0);
	
	if( g_iPlayerTeam[client] == view_as<int>(TEAM_RED) )
		CreateTimer(0.01, fwdSpawn_ToRespawn, client);
	if( g_iPlayerTeam[client] == view_as<int>(TEAM_BLUE) )
		CreateTimer(0.01, fwdSpawn_ToMetro, client);
	
	return Plugin_Continue;
}
public Action fwdSpawn_ToMetro(Handle timer, any client) {
	if( IsValidClient(client) ) {
		teleportToZone(client, METRO_BELMON);
	}
}
public Action fwdSpawn_ToRespawn(Handle timer, any client) {
	if( g_iPlayerTeam[client] == view_as<int>(TEAM_RED) && IsValidClient(client) ) {
		teleportToZone(client, ZONE_RESPAWN);
	}
}
bool CanTP(float pos[3], int client) {
	static float mins[3], maxs[3];
	static bool init = false;
	bool ret;
	
	if( !init ) {
		GetClientMins(client, mins);
		GetClientMaxs(client, maxs);
		init = true;
	}
	
	Handle tr;
	tr = TR_TraceHullEx(pos, pos, mins, maxs, MASK_PLAYERSOLID);
	ret = !TR_DidHit(tr);
	CloseHandle(tr);
	return ret;
}
public Action fwdDead(int victim, int attacker, float& respawn, int& tdm) {
	bool dropped = false;
	if( g_iClientFlag[victim] > 0 ) {
		CTF_DropFlag(victim, false);
		dropped = true;
	}
	
	if( g_iPlayerTeam[attacker] == view_as<int>(TEAM_NONE) || g_iPlayerTeam[victim] == view_as<int>(TEAM_NONE) )
		return Plugin_Continue;
	
	g_iKillingSpree[victim] = 0;

	if( victim != attacker && (rp_GetZoneBit(rp_GetPlayerZone(victim)) & BITZONE_PVP || rp_GetZoneBit(rp_GetPlayerZone(attacker)) & BITZONE_PVP) ) {
		GDM_RegisterKill(attacker);
		
		int points = GDM_ELOKill(attacker, victim, dropped);
		if( dropped )
			points += RoundFloat(float(points)*0.25);
			
		PrintHintText(attacker, "Kill !\n <font color='#33ff33'>+%d</span> points !", points);
		g_flClientLastScore[attacker] = GetGameTime();
		rp_IncrementSuccess(attacker, success_list_killpvp2);
		
		if( g_bFirstBlood == false ) {
			g_bFirstBlood = true;
			CyclAnnouncer_Push(attacker, snd_FirstBlood);
		}
		g_iKillingSpree[attacker]++;
		g_iKilling[attacker]++;
		if( g_hKillTimer[attacker] != INVALID_HANDLE )
			delete g_hKillTimer[attacker];
		g_hKillTimer[attacker] = CreateTimer(10.0, ResetKillCount, attacker);
		CyclAnnouncer(attacker);
	}
	if( victim == attacker ) {
		GDM_ELOSuicide(victim);
	}
	
	respawn = 1.0;
	return Plugin_Handled;
}
public Action fwdHUD(int client, char[] szHUD, const int size) {
	int gID = g_iPlayerTeam[client];
	static char loading[128], cache[512];
	static float lastGen;
	
	if( g_bIsInCaptureMode && gID != view_as<int>(TEAM_NONE) && gID != view_as<int>(TEAM_BANNED) ) {
		if( lastGen > GetGameTime() ) {
			strcopy(szHUD, size, cache);
		}
		else {	
			int timeLeft = g_iCurrentStart + g_iCurrentTimer - GetTime();
			String_TimeFormat(timeLeft, loading, sizeof(loading), true);
			
			Format(szHUD, size, "PvP: Capture du Bunker\n%s\n%s%s\n \n", g_szRoundName[g_iCurrentState], timeLeft > 0 ? "Il reste " : " ", loading);
				
			Format(szHUD, size, "%s - Attaque: %d\n", szHUD, g_iTeamScore[TEAM_BLUE]);
			Format(szHUD, size, "%s - Défense: %d\n", szHUD, g_iTeamScore[TEAM_RED]);
			
			lastGen = GetGameTime() + 0.66;
			strcopy(cache, sizeof(cache), szHUD);
		}
		return Plugin_Changed;
	}
	return Plugin_Continue;
}
public Action fwdStealItem(int client, int target) {
	if( g_iPlayerTeam[client] != view_as<int>(TEAM_NONE) && rp_GetZoneBit(rp_GetPlayerZone(target)) & BITZONE_PVP )
		return Plugin_Handled;
	return Plugin_Continue;
}
public Action fwdFrame(int client) {
	
	if( g_iCurrentState == view_as<int>(ps_begin) ) {
		
		int timeLeft = g_iCurrentStart + (g_iCurrentTimer) - GetTime();
		char tmp[128];
		String_TimeFormat(timeLeft, tmp, sizeof(tmp), false);
		
		if( g_iPlayerTeam[client] == view_as<int>(TEAM_NONE) ) {
			PrintHintText(client, "Un event PVP va commencer dans <font color='#bbffbb'>%s</font>.\nRendez-vous au métro Belmont pour y participer.", tmp);
			
			if( IsInEventArea(client) == true && rp_ClientCanDrawPanel(client) ) {
				inviteToTeam(client);
			}
		}
		else {
			
			if( IsInEventArea(client) == false ) {
				removeClientTeam(client);
			}
			
			PrintHintText(client, "Un event PVP va commencer dans <font color='#bbffbb'>%s</font>.\nEn attente des autres participants.", tmp);
		}
	}
	else if( g_iPlayerTeam[client] == view_as<int>(TEAM_RED) || g_iPlayerTeam[client] == view_as<int>(TEAM_BLUE) ) {
		if( IsInEventArea(client) ) {
			g_iLeaving[client] = 0;
		}
		else if( IsPlayerAlive(client) ) {
			g_iLeaving[client]++;
			
			if( g_iLeaving[client] >= LEAVING_TIME+30 ) {
				addClientToTeam(client, TEAM_BANNED);
				rp_SetClientInt(client, i_PVPBannedUntil, GetTime() + 8 * 24 * 60 * 60);
			}
			else if( g_iLeaving[client] == LEAVING_TIME ) {
				EmitSoundToClientAny(client, g_szSoundList[snd_YouAreLeavingTheBattlefield], _, _, _, _, ANNONCES_VOLUME);
				warnLeaving(client);
			}
			else if( g_iLeaving[client] >= LEAVING_TIME && rp_ClientCanDrawPanel(client) ) {
				warnLeaving(client);
			}
		}
		
		if( rp_GetClientVehicle(client) <= 0 ) {
			ClientCommand(client, "firstperson");
			rp_SetClientInt(client, i_ThirdPerson, 0);
		}
		
		if( g_flClientLastScore[client]+3.0 > GetGameTime() ) {
			//
		}
		else if( g_hGodTimer[client] != INVALID_HANDLE ) {
			PrintHintText(client, "Vous êtes en spawn-protection");
		}
		else if( g_iPlayerTeam[client] == view_as<int>(TEAM_RED) ) {
			rp_ClientColorize(client, { 255, 64, 0, 255 } );
			if( g_iCurrentState == view_as<int>(ps_warmup1) || g_iCurrentState == view_as<int>(ps_warmup2) ) {
				PrintHintText(client, "Vous êtes en <font color='#ff3333'>défense</font>.\n     <font color='#33ff33'>Préparez-vous à l'assaut</font>");
			}
			else {
				PrintHintText(client, "Vous êtes en <font color='#ff3333'>défense</font>.\n     Tuez les BLEUS</font>");
			}
		}
		else {
			rp_ClientColorize(client, { 0, 64, 255, 255 } );
			if( g_iCurrentState == view_as<int>(ps_warmup1) || g_iCurrentState == view_as<int>(ps_warmup2) ) {
				PrintHintText(client, "Vous êtes en <font color='#3333ff'>attaque</font>.\n     <font color='#33ff33'>Préparez-vous à l'assaut</font>");
			}
			else {
				PrintHintText(client, "Vous êtes en <font color='#3333ff'>attaque</font>.\n     Tuez les ROUGES</font>");
			}
		}
	}
	else if ( g_iPlayerTeam[client] == view_as<int>(TEAM_PENDING) ) {
		if( IsInEventArea(client) == false ) {
			removeClientTeam(client);
		}
		
		
		PrintHintText(client, "Un event PVP est en cours.\nVous êtes en attente d'une équipe.");
	}
	else if ( g_iPlayerTeam[client] == view_as<int>(TEAM_NONE) ) {
		PrintHintText(client, "Un event PVP est en cours.\nRendez-vous au métro Belmont pour y participer.");
		
		if( IsInEventArea(client) == true && rp_ClientCanDrawPanel(client) ) {
			inviteToTeam(client);
		}
	}
	
	int vehicle = Client_GetVehicle(client);
	if( rp_IsValidVehicle(vehicle) ) {
		
		if( rp_GetZoneBit(rp_GetPlayerZone(vehicle)) & BITZONE_PVP ) {
			teleportVehicle(vehicle);
			CPrintToChat(client, "" ...MOD_TAG... " Les voitures ne sont pas autorisées en zone PvP lors d'une capture.");
		}
	}
		
	return Plugin_Continue;
}

void teleportToZone(int client, int zone) {
	float mins[3], maxs[3], rand[3];
	bool found = false;
	mins[0] = rp_GetZoneFloat(zone, zone_type_min_x);
	mins[1] = rp_GetZoneFloat(zone, zone_type_min_y);
	mins[2] = rp_GetZoneFloat(zone, zone_type_min_z);
	maxs[0] = rp_GetZoneFloat(zone, zone_type_max_x);
	maxs[1] = rp_GetZoneFloat(zone, zone_type_max_y);
	maxs[2] = rp_GetZoneFloat(zone, zone_type_max_z);
	
	for(int i=0; i<16; i++){
		
		rand[0] = Math_GetRandomFloat(mins[0] + 64.0, maxs[0] - 64.0);
		rand[1] = Math_GetRandomFloat(mins[1] + 64.0, maxs[1] - 64.0);
		rand[2] = Math_GetRandomFloat(mins[2] + 32.0, maxs[2] - 64.0);
		
		if( !CanTP(rand, client) )
			continue;
		
		found = true;
		break;
	}
	if( !found ) {
		mins[0] = rp_GetZoneFloat(zone-1, zone_type_min_x);
		mins[1] = rp_GetZoneFloat(zone-1, zone_type_min_y);
		mins[2] = rp_GetZoneFloat(zone-1, zone_type_min_z);
		maxs[0] = rp_GetZoneFloat(zone-1, zone_type_max_x);
		maxs[1] = rp_GetZoneFloat(zone-1, zone_type_max_y);
		maxs[2] = rp_GetZoneFloat(zone-1, zone_type_max_z);
		
		rand[0] = Math_GetRandomFloat(mins[0] + 64.0, maxs[0] - 64.0);
		rand[1] = Math_GetRandomFloat(mins[1] + 64.0, maxs[1] - 64.0);
		rand[2] = mins[2] + 32.0;
	}
	
	rp_ClientTeleport(client, rand);
}
int teleportVehicle(int ent) {
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
	float MinHull[3], MaxHull[3];
	Entity_GetMinSize(ent, MinHull);
	Entity_GetMaxSize(ent, MaxHull);
	bool found = false;
	
	for (int i = 0; i < sizeof(g_flStartPos); i++)
		rnd[i] = i;
	SortIntegers(rnd, sizeof(g_flStartPos), Sort_Random);
	
	for (int i = 0; i < sizeof(g_flStartPos); i++) {
		
		float ang[3] = { 0.0, 0.0, 0.0 };
		if( g_flStartPos[rnd[i]][2] < -2200.0 ) 
			ang[1] = 90.0;
		
		
		Handle trace = TR_TraceHullEx(g_flStartPos[rnd[i]], g_flStartPos[rnd[i]], MinHull, MaxHull, MASK_SOLID);
		if( TR_DidHit(trace) ) {
			delete trace;
			continue;
		}
		delete trace;
		
		TeleportEntity(ent, g_flStartPos[rnd[i]], ang, NULL_VECTOR);
		found = true;
		break;
	}
	
	if( !found ) {
		TeleportEntity(ent, view_as<float>({ 0.0, 0.0, 0.0}), view_as<float>({ 0.0, 0.0, 0.0}), NULL_VECTOR);
	}
}
public Action Event_PlayerShoot(Handle event, char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	GDM_RegisterShoot(client);
	
	return Plugin_Continue;
}
public Action Event_PlayerHurt(Handle event, char[] name, bool dontBroadcast) {
	char weapon[64];
	int attacker, damage, hitgroup;
	
	attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	damage = GetEventInt(event, "dmg_health");	
	hitgroup = GetEventInt(event, "hitgroup");
	
	GetEventString(event, "weapon", weapon, sizeof(weapon));
	
	if( hitgroup > 0 )
		GDM_RegisterHit(attacker, damage, hitgroup);
	
	return Plugin_Continue;
}
public Action fwdTakeDamage(int victim, int attacker, float& damage, int damagetype) {
	if( g_iPlayerTeam[attacker] > 0 && g_iPlayerTeam[victim] > 0 ) {
		
		if( g_iCurrentState == view_as<int>(ps_warmup1) || g_iCurrentState == view_as<int>(ps_warmup2) ) {
			return Plugin_Handled;
		}
			
		if( g_iPlayerTeam[attacker] == view_as<int>(TEAM_BLUE) && g_iPlayerTeam[victim] == view_as<int>(TEAM_BLUE) ) {
			return Plugin_Handled;
		}
		if( g_iPlayerTeam[attacker] == view_as<int>(TEAM_RED) && g_iPlayerTeam[victim] == view_as<int>(TEAM_RED) ) {
			return Plugin_Handled;
		}
		if( !(rp_GetZoneBit(rp_GetPlayerZone(victim)) & BITZONE_PVP || rp_GetZoneBit(rp_GetPlayerZone(attacker)) & BITZONE_PVP) ) {
			return Plugin_Handled;
		}
	}
	
	return Plugin_Continue;
}
public Action fwdZoneChange(int client, int newZone, int oldZone) {
	if( newZone == ZONE_RESPAWN &&  g_iPlayerTeam[client] == view_as<int>(TEAM_BLUE) ) {
		rp_ClientDamage(client, 10000, client);
		ForcePlayerSuicide(client);
	}
	if (rp_IsTutorialOver(client) == false && (rp_GetZoneBit(newZone) & BITZONE_PVP) ) {
		ForcePlayerSuicide(client);
	}
	if( newZone == ZONE_VILLA && !rp_GetClientKeyAppartement(client, 50) ) {
		rp_ClientSendToSpawn(client, true);
	}
	if( newZone == ZONE_VILLA2 && g_iPlayerTeam[client] == view_as<int>(TEAM_NONE) ) {
		rp_ClientSendToSpawn(client, true);
	}
	if( g_iPlayerTeam[client] == view_as<int>(TEAM_NONE) && (rp_GetZoneBit(newZone) & BITZONE_PVP) ) {
		rp_ClientSendToSpawn(client, true);
	}
	
	if( g_iPlayerTeam[client] == view_as<int>(TEAM_BLUE) && (g_iCurrentState == view_as<int>(ps_warmup1)||g_iCurrentState == view_as<int>(ps_warmup2)) && (rp_GetZoneBit(newZone) & BITZONE_PVP) ) {
		teleportToZone(client, METRO_BELMON);
	}
	
	return Plugin_Continue;
}
// -----------------------------------------------------------------------------------------------------------------
public Action SwitchToFirst(Handle timer, any client) {
	if( rp_GetClientInt(client, i_ThirdPerson) == 0 )
		ClientCommand(client, "firstperson");
}
// -----------------------------------------------------------------------------------------------------------------
int CTF_SpawnFlag(float vecOrigin[3], int skin, int color[3]) {
	char szSkin[12], szColor[32];
	Format(szSkin, sizeof(szSkin), "%d", skin);
	Format(szColor, sizeof(szColor), "%d %d %d", color[0], color[1], color[2]);
	
	int ent1 = CreateEntityByName("hegrenade_projectile");
	if( !IsValidEdict(ent1) )
		return -1;
	int ent2 = CreateEntityByName("prop_dynamic_override");
	if( !IsValidEdict(ent2) )
		return -1;
	int ent3 = CreateEntityByName("light_dynamic");
	if( !IsValidEdict(ent3) )
		return -1;
	
	//
	DispatchKeyValue(ent1, "classname", "ctf_flag");
	//
	DispatchKeyValue(ent3, "brightness", "3");
	DispatchKeyValue(ent3, "distance", "128");
	
	DispatchKeyValue(ent2, "Skin", szSkin);
	DispatchKeyValue(ent2, "model", "models/flag/briefcase.mdl");
	DispatchKeyValue(ent3, "_light", szColor);
	
	DispatchSpawn(ent1);
	DispatchSpawn(ent2);
	DispatchSpawn(ent3);
	
	SetEntityMoveType(ent1, MOVETYPE_FLYGRAVITY);
	
	
	SetEntProp(ent1, Prop_Send, "m_CollisionGroup", COLLISION_GROUP_DEBRIS);
	SetEntProp(ent1, Prop_Send, "m_usSolidFlags", FSOLID_TRIGGER);
	SetEntProp(ent2, Prop_Send, "m_CollisionGroup", COLLISION_GROUP_DEBRIS);
	SetEntProp(ent2, Prop_Send, "m_usSolidFlags", FSOLID_NOT_SOLID);
	
	
	SetEntPropFloat(ent1, Prop_Send, "m_flElasticity", 0.1);
	
	vecOrigin[2] += 10.0;
	TeleportEntity(ent1, vecOrigin, NULL_VECTOR, NULL_VECTOR);
	TeleportEntity(ent3, vecOrigin, NULL_VECTOR, NULL_VECTOR);
	//
	SetVariantString("!activator");
	rp_AcceptEntityInput(ent2, "SetParent", ent1);
	//
	SetVariantString("!activator");
	rp_AcceptEntityInput(ent3, "SetParent", ent1);
	
	SetEntityRenderMode(ent1, RENDER_TRANSALPHA);
	SetEntityRenderMode(ent2, RENDER_TRANSALPHA);
	SetEntityRenderColor(ent1, 0, 0, 0, 0);
	SetEntityRenderColor(ent2, color[0], color[1], color[2],  255);
	CreateTimer(0.01, CTF_SpawnFlag_Delay, ent2);
	
	g_iFlagData[ent1][data_skin] = skin;
	g_iFlagData[ent1][data_red] = color[0];
	g_iFlagData[ent1][data_green] = color[1];
	g_iFlagData[ent1][data_blue] = color[2];
	g_iFlagData[ent1][data_time] = GetTime();
	g_iFlagData[ent1][data_owner] = 0;
	
	SDKHook(ent1, SDKHook_Touch, SDKTouch);
	
	CreateTimer(0.01, FlagThink, EntIndexToEntRef(ent1));
	
	return ent1;
}
public Action SDKTouch(int entity, int client) {
	if( !IsValidClient(client) )
		return Plugin_Continue;
	if( g_iClientFlag[client] > 0 )
		return Plugin_Continue;
	if( g_iCurrentState != view_as<int>(ps_none) && g_iPlayerTeam[client] != view_as<int>(TEAM_BLUE) )
		return Plugin_Continue;
	if( g_iCurrentState == view_as<int>(ps_none) && g_iFlagData[entity][data_group] != rp_GetClientGroupID(client) )
		return Plugin_Continue;
	
	CTF_FlagTouched(client, entity);
	return Plugin_Continue;
}
void CTF_DropFlag(int client, int thrown) {
	
	int flag, color[3], gID, skin;
	float vecOrigin[3], vecAngles[3], vecPush[3];
	
	flag = g_iClientFlag[client];
	g_iClientFlag[client] = 0;
	g_fLastDrop[client] = GetGameTime();
	skin = g_iFlagData[flag][data_skin];
	color[0] = g_iFlagData[flag][data_red];
	color[1] = g_iFlagData[flag][data_green];
	color[2] = g_iFlagData[flag][data_blue];
	gID = g_iFlagData[flag][data_group];
	
	rp_AcceptEntityInput(flag, "KillHierarchy");
	
	GetClientEyeAngles(client, vecAngles);
	GetClientEyePosition(client, vecOrigin);
	vecAngles[0] += 10.0;
	
	flag = CTF_SpawnFlag(vecOrigin, skin, color);
	g_iFlagData[flag][data_group] = gID;
	g_iFlagData[flag][data_lastOwner] = client;
	g_iPlayerTeam[flag] = TEAM_BLUE;
	
	if( thrown ) {		
		Entity_GetAbsVelocity(client, vecPush);
		
		
		vecPush[0] = vecPush[0]*0.5 + ( FLAG_SPEED * Cosine( DegToRad(vecAngles[1]) ) );
		vecPush[1] = vecPush[1]*0.5 + ( FLAG_SPEED * Sine( DegToRad(vecAngles[1]) ) );
		vecPush[2] = vecPush[2]*0.5 + ( (FLAG_SPEED/2.0) * Cosine( DegToRad( vecAngles[0] ) ) );
	}
	else {
		
		vecOrigin[2] = (vecOrigin[2] - 20.0);
		vecPush[2] = 20.0;
	}
	
	vecPush[2] += 50.0;
	TeleportEntity(flag, vecOrigin, vecAngles, vecPush);
}
void CTF_FlagTouched(int client, int flag) {	
	
	if( (g_fLastDrop[client]+3.0) >= GetGameTime() ) {
		return;
	}
	if( GDM_GetFlagCount(client) >= FLAG_MAX ) {
		g_fLastDrop[client] = GetGameTime() + 10.0;
		return;
	}
	
	SDKUnhook(flag, SDKHook_Touch, SDKTouch);
	
	g_iFlagData[flag][data_owner] = client;
	g_iClientFlag[client] = flag;
	
	ClientCommand(client, "play common/wpn_hudoff");
	
	SetVariantString("!activator");
	rp_AcceptEntityInput(flag, "SetParent", client);
	
	SetVariantString("grenade2");
	rp_AcceptEntityInput(flag, "SetParentAttachment");
	
	float vecOrigin[3], ang[3], pos[3];
	Entity_GetAbsOrigin(flag, vecOrigin);
	
	
	ang[0] = -90.0;
	ang[1] = 180.0;
	ang[2] = 90.0;
	
	
	pos[0] = 20.0;
	pos[1] = 5.0;
	pos[2] = 0.0;
	
	TeleportEntity(flag, pos, ang, NULL_VECTOR);
	ClientCommand(client, "thirdperson");
	CreateTimer(0.5, SwitchToFirst, client);
	
	EmitSoundToClientAny(client, g_szSoundList[snd_YouHaveTheFlag], _, _, _, _, ANNONCES_VOLUME);
	
	//SDKHook(flag, SDKHook_SetTransmit, SDKHideFlag);
}
public Action CTF_SpawnFlag_Delay(Handle timer, any ent2) {
	TeleportEntity(ent2, view_as<float>({30.0, 0.0, 0.0}), view_as<float>({0.0, 90.0, 0.0}), NULL_VECTOR);
}
// -----------------------------------------------------------------------------------------------------------------
void GDM_Init(int client) {
	char szSteamID[32], tmp[65];
	GetClientAuthId(client, AUTH_TYPE, szSteamID, sizeof(szSteamID));
	GetClientName(client, tmp, sizeof(tmp));
	
	int[] array = new int[gdm_max];
	
	if( !g_hGlobalDamage.GetArray(szSteamID, array, gdm_max) ) {
		array[gdm_elo] = rp_GetClientInt(client, i_ELO);
		array[gdm_team] = g_iPlayerTeam[client];
		
		g_hGlobalDamage.SetArray(szSteamID, array, gdm_max);
	}
	else {
		if( g_iPlayerTeam[client] == view_as<int>(TEAM_NONE) ) {
			addClientToTeam(client, array[gdm_team]);
		}
	}
	
	g_hGlobalSteamID.SetString(szSteamID, tmp, true);
}
void GDM_RegisterHit(int client, int damage=0, int hitbox=0) {
	char szSteamID[32];
	GetClientAuthId(client, AUTH_TYPE, szSteamID, sizeof(szSteamID));
	
	int[] array = new int[gdm_max];
	g_hGlobalDamage.GetArray(szSteamID, array, gdm_max);
	array[gdm_touch]++;
	array[gdm_damage] += damage;
	array[gdm_hitbox] += (hitbox == 1 ? 1:0);
	
	g_hGlobalDamage.SetArray(szSteamID, array, gdm_max);
}
void GDM_RegisterFlag(int client, int score) {
	char szSteamID[32];
	GetClientAuthId(client, AUTH_TYPE, szSteamID, sizeof(szSteamID));
	
	int[] array = new int[gdm_max];
	g_hGlobalDamage.GetArray(szSteamID, array, gdm_max);
	array[gdm_flag]++;
	array[gdm_score] += score;
	g_iScores[rp_GetClientGroupID(client)] += score;
	
	g_hGlobalDamage.SetArray(szSteamID, array, gdm_max);
}
void GDM_RegisterArea(int client) {
	char szSteamID[32];
	GetClientAuthId(client, AUTH_TYPE, szSteamID, sizeof(szSteamID));
	
	int[] array = new int[gdm_max];
	g_hGlobalDamage.GetArray(szSteamID, array, gdm_max);
	array[gdm_area]++;
	array[gdm_score]++;
	g_iScores[rp_GetClientGroupID(client)]++;
	
	g_hGlobalDamage.SetArray(szSteamID, array, gdm_max);
}
void GDM_RegisterKill(int client) {
	char szSteamID[32];
	GetClientAuthId(client, AUTH_TYPE, szSteamID, sizeof(szSteamID));
	
	int[] array = new int[gdm_max];
	g_hGlobalDamage.GetArray(szSteamID, array, gdm_max);
	array[gdm_kill]++;
	g_hGlobalDamage.SetArray(szSteamID, array, gdm_max);
}
int GDM_GetFlagCount(int client) {
	char szSteamID[32];
	GetClientAuthId(client, AUTH_TYPE, szSteamID, sizeof(szSteamID));
	
	int[] array = new int[gdm_max];
	g_hGlobalDamage.GetArray(szSteamID, array, gdm_max);
	return array[gdm_flag];
}
void GDM_RegisterShoot(int client) {
	char szSteamID[32];
	GetClientAuthId(client, AUTH_TYPE, szSteamID, sizeof(szSteamID));
	
	int[] array = new int[gdm_max];
	g_hGlobalDamage.GetArray(szSteamID, array, gdm_max);
	array[gdm_shot]++;
	g_hGlobalDamage.SetArray(szSteamID, array, gdm_max);
}
stock int GDM_ELOKill(int client, int target, bool flag = false) {
	
	char szSteamID[32], szSteamID2[32];
	int[] attacker = new int[gdm_max];
	int[] victim = new int[gdm_max];
	int cElo, tElo;
	
	float cDelta, tDelta;
	
	GetClientAuthId(client, AUTH_TYPE, szSteamID, sizeof(szSteamID));
	GetClientAuthId(target, AUTH_TYPE, szSteamID2, sizeof(szSteamID2));
	
	g_hGlobalDamage.GetArray(szSteamID, attacker, gdm_max);
	g_hGlobalDamage.GetArray(szSteamID2, victim, gdm_max);
	
	cDelta = 1.0/((Pow(10.0, - (attacker[gdm_elo] - victim[gdm_elo]) / 400.0)) + 1.0);
	tDelta = 1.0/((Pow(10.0, - (victim[gdm_elo] - attacker[gdm_elo]) / 400.0)) + 1.0);
	cElo = RoundFloat(float(attacker[gdm_elo]) + ELO_FACTEUR_K * (1.0 - cDelta));
	tElo = RoundFloat(float(victim[gdm_elo]) + ELO_FACTEUR_K * (0.0 - tDelta));
	
	int tmp = cElo - attacker[gdm_elo];
	g_iTeamScore[ g_iPlayerTeam[client] ] += tmp;
	attacker[gdm_score] += tmp;
	attacker[gdm_elo] = cElo;
	victim[gdm_elo] = tElo;
	
	g_iScores[rp_GetClientGroupID(client)] += tmp;
	rp_SetClientInt(client, i_ELO, cElo);
	rp_SetClientInt(target, i_ELO, tElo);
	
	g_hGlobalDamage.SetArray(szSteamID, attacker, gdm_max);
	g_hGlobalDamage.SetArray(szSteamID2, victim, gdm_max);
	
	return tmp;
}
int GDM_ELOSuicide(int client) {
	
	char szSteamID[32];
	int[] attacker = new int[gdm_max];
	int cElo;
	float cDelta;
	
	GetClientAuthId(client, AUTH_TYPE, szSteamID, sizeof(szSteamID));
	g_hGlobalDamage.GetArray(szSteamID, attacker, gdm_max);
	
	cDelta = 1.0/((Pow(10.0, - (1500 - attacker[gdm_elo]) / 400.0)) + 1.0);
	cElo = RoundFloat(float(attacker[gdm_elo]) + ELO_FACTEUR_K * (0.0 - cDelta));
	
	int tmp = cElo - attacker[gdm_elo];
	
	attacker[gdm_elo] = cElo;
	rp_SetClientInt(client, i_ELO, cElo);
	g_hGlobalDamage.SetArray(szSteamID, attacker, gdm_max);
	
	return tmp;
}
void GDM_Resume() {
	StringMapSnapshot KeyList = g_hGlobalDamage.Snapshot();
	int[] array = new int[gdm_max];
	int delta, nbrParticipant = KeyList.Length;
	char szSteamID[32], tmp[64], key[64], name[64];
	
	if( g_hStatsMenu != INVALID_HANDLE )
		delete g_hStatsMenu;
	g_hStatsMenu = new TopMenu (MenuPvPResume);
	g_hStatsMenu.CacheTitles = true;
	
	g_hStatsMenu_Shoot = g_hStatsMenu.AddCategory("shoot", MenuPvPResume);
	g_hStatsMenu_Head = g_hStatsMenu.AddCategory("head", MenuPvPResume);
	g_hStatsMenu_Damage = g_hStatsMenu.AddCategory("damage", MenuPvPResume);
	g_hStatsMenu_Flag = g_hStatsMenu.AddCategory("flag", MenuPvPResume);
	g_hStatsMenu_ELO = g_hStatsMenu.AddCategory("elo", MenuPvPResume);
	g_hStatsMenu_SCORE = g_hStatsMenu.AddCategory("score", MenuPvPResume);
	g_hStatsMenu_KILL = g_hStatsMenu.AddCategory("kill", MenuPvPResume);
	
	for (int i = 0; i < nbrParticipant; i++) {
		KeyList.GetKey(i, szSteamID, sizeof(szSteamID));
		g_hGlobalDamage.GetArray(szSteamID, array, gdm_max);
		g_hGlobalSteamID.GetString(szSteamID, name, sizeof(name));
		
		if( array[gdm_touch] != 0 && array[gdm_shot] != 0  ) {
			delta = RoundFloat(float(array[gdm_touch]) / float(array[gdm_shot]+1) * 1000.0);
			Format(key, sizeof(key), "s%08d_%s", GetRandomInt(1, 100), szSteamID); 
			Format(tmp, sizeof(tmp), "%4.1f - %s", float(delta)/10.0, name);
			g_hStatsMenu.AddItem(key, MenuPvPResume, g_hStatsMenu_Shoot, "", 0, tmp);
			
			delta = RoundFloat(float(array[gdm_hitbox]) / float(array[gdm_touch]+1) * 1000.0);
			Format(key, sizeof(key), "h%08d_%s", GetRandomInt(1, 100), szSteamID); 
			Format(tmp, sizeof(tmp), "%4.1f - %s", float(delta)/10.0, name);
			g_hStatsMenu.AddItem(key, MenuPvPResume, g_hStatsMenu_Head, "", 0, tmp);
			
			delta = array[gdm_elo];
			Format(key, sizeof(key), "e%08d_%s", GetRandomInt(1, 100), szSteamID); 
			Format(tmp, sizeof(tmp), "%6d - %s", delta, name);
			g_hStatsMenu.AddItem(key, MenuPvPResume, g_hStatsMenu_ELO, "", 0, tmp);
			
		}
		if( array[gdm_touch] != 0 ) {
			delta = array[gdm_damage];
			Format(key, sizeof(key), "d%06d_%s", 1000000 + delta, szSteamID); 
			Format(tmp, sizeof(tmp), "%6d - %s", delta, name);
			g_hStatsMenu.AddItem(key, MenuPvPResume, g_hStatsMenu_Damage, "", 0, tmp);
			
		}		
		if( array[gdm_flag] != 0 ) {
			delta = array[gdm_flag];
			Format(key, sizeof(key), "f%06d_%s", 1000000 + delta, szSteamID); 
			Format(tmp, sizeof(tmp), "%6d - %s", delta, name);
			g_hStatsMenu.AddItem(key, MenuPvPResume, g_hStatsMenu_Flag, "", 0, tmp);
		}
		if( array[gdm_kill] != 0 ) {
			delta = array[gdm_kill];
			Format(key, sizeof(key), "k%06d_%s", 1000000 + delta, szSteamID); 
			Format(tmp, sizeof(tmp), "%6d - %s", delta, name);
			g_hStatsMenu.AddItem(key, MenuPvPResume, g_hStatsMenu_KILL, "", 0, tmp);
		}
		
		if( array[gdm_score] != 0 ) {
			delta = array[gdm_score];
			Format(key, sizeof(key), "s%06d_%s", 1000000 + delta, szSteamID); 
			Format(tmp, sizeof(tmp), "%6d - %s", delta, name);
			g_hStatsMenu.AddItem(key, MenuPvPResume, g_hStatsMenu_SCORE, "", 0, tmp);
		}		
	}
	
	for (int client = 1; client <= MaxClients; client++) {
		if( !IsValidClient(client) )
			continue;
		
		if( g_iPlayerTeam[client] != view_as<int>(TEAM_NONE) )
			g_hStatsMenu.Display(client, TopMenuPosition_Start);
	}
}
// -----------------------------------------------------------------------------------------------------------------
void Client_SetSpawnProtect(int client, bool status) {
	if( status == true ) {
		rp_HookEvent(client, RP_OnPlayerDead, fwdGodPlayerDead);
		SDKHook(client, SDKHook_SetTransmit, fwdGodHideMe);
		SDKHook(client, SDKHook_PreThink, fwdGodThink);
		float duration = 10.0;
		if( g_iPlayerTeam[client] == view_as<int>(TEAM_RED) )
			duration = 15.0;
		if( g_hGodTimer[client] != INVALID_HANDLE )
			delete g_hGodTimer[client];
		g_hGodTimer[client] = CreateTimer(duration, GOD_Expire, client);
		SetEntProp(client, Prop_Data, "m_takedamage", 0);
		CPrintToChat(client, "" ...MOD_TAG... " Vous avez %d secondes de spawn-protection.", RoundFloat(duration));
	}
	else {
		rp_UnhookEvent(client, RP_OnPlayerDead, fwdGodPlayerDead);
		SDKUnhook(client, SDKHook_SetTransmit, fwdGodHideMe);
		SDKUnhook(client, SDKHook_PreThink, fwdGodThink);
		if( g_hGodTimer[client] != INVALID_HANDLE )
			delete g_hGodTimer[client];
		g_hGodTimer[client] = INVALID_HANDLE; 
		SetEntProp(client, Prop_Data, "m_takedamage", 2);
		CPrintToChat(client, "" ...MOD_TAG... " Votre spawn-protection a expirée.");
		
		if( g_iPlayerTeam[client] == view_as<int>(TEAM_RED) )
			rp_ClientColorize(client, { 255, 64, 64, 255 } );
		else if( g_iPlayerTeam[client] == view_as<int>(TEAM_BLUE) )
			rp_ClientColorize(client, { 64, 64, 255, 255 } );
		else
			rp_ClientColorize(client);
	}
}
public Action fwdGodThink(int client) {
	int wep = Client_GetWeapon(client, "weapon_knife");
	if( wep > 0 && IsValidEdict(wep) && IsValidEntity(wep) ) {
		SetEntPropFloat(wep, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + 0.25);
		SetEntPropFloat(wep, Prop_Send, "m_flNextSecondaryAttack", GetGameTime() + 0.25);
	}
}
public Action fwdGodHideMe(int client, int target) {
	if( client != target )
		return Plugin_Handled;
	return Plugin_Continue;
}
public Action fwdGodPlayerDead(int client, int attacker, float& respawn, int& tdm) {
	Client_SetSpawnProtect(client, false);
}
public Action fwdGod_PlayerHurt(Handle event, char[] name, bool dontBroadcast) {
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	if(  g_hGodTimer[attacker] != INVALID_HANDLE ) {
		Client_SetSpawnProtect(attacker, false);
	}
}
public Action fwdGod_PlayerShoot(Handle event, char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(  g_hGodTimer[client] != INVALID_HANDLE ) {
		Client_SetSpawnProtect(client, false);
	}
	return Plugin_Continue;
}
public Action GOD_Expire(Handle timer, any client) {
	if( g_hGodTimer[client] != INVALID_HANDLE && IsValidHandle(g_hGodTimer[client]) )
		Client_SetSpawnProtect(client, false);
	g_hGodTimer[client] = INVALID_HANDLE;
}
// -----------------------------------------------------------------------------------------------------------------
public void MenuPvPResume(Handle topmenu, TopMenuAction action, TopMenuObject topobj_id, int param, char[] buffer, int maxlength) {
	if (action == TopMenuAction_DisplayTitle || action == TopMenuAction_DisplayOption) {
		if( topobj_id == INVALID_TOPMENUOBJECT ) 
			Format(buffer, maxlength, "Statistiques PvP:");
		else if( topobj_id == g_hStatsMenu_Shoot )
			Format(buffer, maxlength, "Meilleur précisions de tir");
		else if( topobj_id == g_hStatsMenu_Head )
			Format(buffer, maxlength, "Le plus de tir dans la tête");
		else if( topobj_id == g_hStatsMenu_Damage )
			Format(buffer, maxlength, "Le plus de dégâts");
		else if( topobj_id == g_hStatsMenu_KILL )
			Format(buffer, maxlength, "Le plus de meurtre");
		else if( topobj_id == g_hStatsMenu_Flag )
			Format(buffer, maxlength, "Le plus de drapeaux posés");
		else if( topobj_id == g_hStatsMenu_ELO )
			Format(buffer, maxlength, "Le plus fort aux armes");
		else if( topobj_id == g_hStatsMenu_SCORE )
			Format(buffer, maxlength, "Le plus de contribution");
		else 
			GetTopMenuInfoString(topmenu, topobj_id, buffer, maxlength);
	}
	else if (action == TopMenuAction_SelectOption) {
		g_hStatsMenu.Display(param, TopMenuPosition_Start);
	}
}
// -----------------------------------------------------------------------------------------------------------------
void announceSound(int client, int sound) {
	int clients[65], clientCount = 0;
	char msg[128];
	
	switch( sound ) {
		case snd_FirstBlood: Format(msg, sizeof(msg), 	"%N\n<font color='#33ff33'>a versé le premier sang !</font>", client);
		case snd_DoubleKill: Format(msg, sizeof(msg), 	"%N\n<font color='#33ff33'>   Double kill</font>", client);
		case snd_MultiKill: Format(msg, sizeof(msg), 	"%N\n<font color='#33ff33'>   MULTI kill</font>", client);
		case snd_MegaKill: Format(msg, sizeof(msg), 	"%N\n<font color='#33ff33'>   MEGA KILL</font>", client);
		case snd_UltraKill: Format(msg, sizeof(msg), 	"%N\n<font color='#33ff33'>   ULTRAAA-KILL !</font>", client);
		case snd_MonsterKill: Format(msg, sizeof(msg), 	"%N\n<font color='#33ff33'>MOOOONSTER KILL !</font>", client);
		case snd_KillingSpree: Format(msg, sizeof(msg),	"%N\n<font color='#33ff33'>fait une série meurtrière</font>", client);
		case snd_Unstopppable: Format(msg, sizeof(msg),	"%N\n<font color='#33ff33'> est inarrêtable!</font>", client);
		case snd_Dominating: Format(msg, sizeof(msg),	"%N\n<font color='#33ff33'>   DOMINE !</font>", client);
		case snd_Godlike: Format(msg, sizeof(msg),		"%N\n<font color='#33ff33'> EST DIVIN !</font>", client);
	}
	for (int i = 1; i <= MaxClients; i++) {
		if( !IsValidClient(i) )
			continue;
		if( g_iPlayerTeam[i] == view_as<int>(TEAM_NONE) )
			continue;
		
		g_flClientLastScore[i] = GetGameTime();
		PrintHintText(i, msg);
		
		if( !g_bStopSound[i] )
			clients[clientCount++] = i;
	}
	EmitSoundAny(clients, clientCount, g_szSoundList[sound], _, _, _, _, ANNONCES_VOLUME);
}
void CyclAnnouncer(int client) {
	bool sound = false;
	
	switch( g_iKilling[client] ) {
		case 2: sound = CyclAnnouncer_Push(client, snd_DoubleKill);
		case 3: sound = CyclAnnouncer_Push(client, snd_MultiKill);
		case 4: sound = CyclAnnouncer_Push(client, snd_MegaKill);
		case 5: sound = CyclAnnouncer_Push(client, snd_UltraKill);
		case 6: sound = CyclAnnouncer_Push(client, snd_MonsterKill);
		default: {
			if( g_iKilling[client] >= 6 && g_iKilling[client] % 2)
				sound = CyclAnnouncer_Push(client, snd_MonsterKill);
		}
	}
	
	if( !sound ) {
		switch( g_iKillingSpree[client] ) {
			case 4: sound = CyclAnnouncer_Push(client, snd_KillingSpree);
			case 6: sound = CyclAnnouncer_Push(client, snd_Dominating);
			case 8: sound = CyclAnnouncer_Push(client, snd_Unstopppable);
			case 10: sound = CyclAnnouncer_Push(client, snd_Godlike);
			default: {
				if( g_iKillingSpree[client] >= 12 && g_iKillingSpree[client] % 2 )
					sound = CyclAnnouncer_Push(client, snd_Godlike);
			}
		}
	}
}
bool CyclAnnouncer_Push(int client, int soundID) {
	
	if( !CyclAnnouncer_Empty() ) {
		int i = g_CyclAnnouncer_end;
		
		while( i != g_CyclAnnouncer_start ) {
			if( g_CyclAnnouncer[i][ann_Client] == client ) {
				g_CyclAnnouncer[i][ann_SoundID] = soundID;
				g_CyclAnnouncer[i][ann_Time] = RoundToCeil(GetGameTime());
				return true;
			}
			
			i = (i + 1) % MAX_ANNOUNCES;
		}
	}
	if( CyclAnnouncer_Full() )
		return false;
	
	g_CyclAnnouncer[g_CyclAnnouncer_start][ann_Client] = client;
	g_CyclAnnouncer[g_CyclAnnouncer_start][ann_SoundID] = soundID;
	g_CyclAnnouncer[g_CyclAnnouncer_start][ann_Time] = RoundToCeil(GetGameTime());
	
	g_CyclAnnouncer_start = (g_CyclAnnouncer_start+1) % MAX_ANNOUNCES;
	
	return true;
}
bool CyclAnnouncer_Full() {
	return ((g_CyclAnnouncer_end + 1) % MAX_ANNOUNCES == g_CyclAnnouncer_start);
}
bool CyclAnnouncer_Empty() {
	return (g_CyclAnnouncer_end == g_CyclAnnouncer_start);
}
public Action ResetKillCount(Handle timer, any client) {
	if( g_hKillTimer[client] != INVALID_HANDLE )
		g_iKilling[client] = 0;
	g_hKillTimer[client] = INVALID_HANDLE;
}
// -----------------------------------------------------------------------------------------------------------------
bool IsInEventArea(int client) {
	if( rp_GetClientBool(client, b_IsAFK) )
		return false;
	
	int zone = rp_GetPlayerZone(client);
	if( zone >= BUNKER_ZONE_MIN && zone <= BUNKER_ZONE_MAX )
		return true;
	if( zone == METRO_BELMON || zone == METRO_BELMON-1 )
		return true;	
	if( zone == 261 )
		return true;
	
	return false;
}
// ----------------------------------------------------------------------------
void addClientToTeam(int client, int team) {
	removeClientTeam(client);
	
	if( team != view_as<int>(TEAM_NONE) )
		g_stkTeam[team][ g_stkTeamCount[team]++ ] = client;
	
	g_iPlayerTeam[client] = team;
}
void removeClientTeam(int client) {
	if( g_iPlayerTeam[client] != view_as<int>(TEAM_NONE) ) {
		for (int i = 0; i < g_stkTeamCount[g_iPlayerTeam[client]]; i++) {
			if( g_stkTeam[ g_iPlayerTeam[client] ][ i ] == client ) {
				for (; i < g_stkTeamCount[g_iPlayerTeam[client]]; i++) {
					g_stkTeam[g_iPlayerTeam[client]][i] = g_stkTeam[g_iPlayerTeam[client]][i + 1];
				}
				g_stkTeamCount[g_iPlayerTeam[client]]--;
				break;
			}
		}

		g_iPlayerTeam[client] = TEAM_NONE;
	}
}
void shuffleTeams() {
	int teams[] =  { TEAM_RED, view_as<int>(TEAM_BLUE) };
	int lastTeam = GetRandomInt(0, sizeof(teams));
	
	int sPlayers[MAXPLAYERS][2];
	int pCount = 0;
	
	for (int i = 1; i <= MaxClients; i++) {
		if( !IsValidClient(i) )
			continue;
		
		if ( g_iPlayerTeam[i] != view_as<int>(TEAM_PENDING) )
			continue;
		
		sPlayers[pCount][0] = i;
		sPlayers[pCount][1] = rp_GetClientInt(i, i_ELO) + GetRandomInt(-50, 50);
		pCount++;
	}
	
	SortCustom2D(sPlayers, pCount, Sort_ByELO);
	
	for (int i = 0; i < pCount; i++) {
		addClientToTeam(sPlayers[i][0], teams[lastTeam++ % sizeof(teams)]);
	}
}
int getWorstTeam() {
	int[] teamForce = new int[view_as<int>(TEAM_MAX)];
	
	for (int i = 1; i <= MaxClients; i++) {
		if( !IsValidClient(i) )
			continue;
		
		teamForce[g_iPlayerTeam[i]] += rp_GetClientInt(i, i_ELO);
	}
	
	return teamForce[view_as<int>(TEAM_RED)] >= teamForce[view_as<int>(TEAM_BLUE)] ? view_as<int>(TEAM_BLUE) : view_as<int>(TEAM_RED);
}
public int Sort_ByELO(int[] a, int[] b, const int[][] array, Handle hndl) {
	return b[1] - a[1];
}
