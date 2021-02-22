#if defined _roleplay_base_included
#endinput
#endif
#define _roleplay_base_included

#pragma semicolon 1
#pragma dynamic 262144

#define GAME_CSGO


#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#include <colors_csgo>
#include <smlib>
#include <regex>
#include <eItems>
#include <emitsoundany>
#include <basecomm>
#include <SteamWorks>
#include <dhooks>
#include <rp_version>
#include <unixtime_sourcemod>
#include <tetris>
#include <pong>
#include <snake>

#define USING_VEHICLE
//#define EVENT_APRIL
//#define EVENT_NOEL
//#define EVENT_BIRTHDAY

#if defined GAME_CSGO
#include <cstrike.inc>
#define CS_SLOT_KNIFE 2
#define	MAX_PLAYERS	65
#endif

#include <roleplay.inc>
#include <phun>
#include <advanced_motd>

#pragma newdecls required

int g_cSnow;
bool g_bPreventLoadConfig = false;
Handle g_hTeleport, g_hLookupAttachment, g_hForward_RP_OnPlayerGotPay, g_hOnVoiceTransmit;


#if defined ROLEPLAY_SUB
	#include "../roleplay.inc.const.sp"
#else
	#include "roleplay.inc.const.sp"
#endif

public Plugin myinfo = {
	name = "RolePlay", author = "KoSSoLaX",
	description = "Counter-Strike Global Offensive - RolePlay",
	version = __LAST_REV__, url = "https://riplay.fr"
};

// -----------------------------------------------------------------------------------------------------------------
//
//	PLUGIN START
//
public void OnPluginStart() {	
	SetRandomSeed(GetTime());
	AddNormalSoundHook(sound_hook);

	Format(szGeneralMenu, sizeof(szGeneralMenu), "   RolePlay - %s", __LAST_REV__);
	LoadTranslations("core.phrases");
	LoadTranslations("common.phrases");
	LoadTranslations("funcommands.phrases");
	LoadTranslations("plugin.basecommands");
	LoadTranslations("roleplay.phrases");
	LoadTranslations("roleplay.items.phrases");
	LoadTranslations("roleplay.core.phrases");
	LoadTranslations("roleplay.core.sub.phrases");
	//
	LoadTranslations("roleplay.armurerie.phrases");
	LoadTranslations("roleplay.artificier.phrases");
	LoadTranslations("roleplay.artisan.phrases");
	LoadTranslations("roleplay.banque.phrases");
	LoadTranslations("roleplay.carshop.phrases");
	LoadTranslations("roleplay.coach.phrases");
	LoadTranslations("roleplay.dealer.phrases");
	LoadTranslations("roleplay.hopital.phrases");
	LoadTranslations("roleplay.immo.phrases");
	LoadTranslations("roleplay.justice.phrases");
	LoadTranslations("roleplay.loto.phrases");
	LoadTranslations("roleplay.mafia.phrases");
	LoadTranslations("roleplay.mcdo.phrases");
	LoadTranslations("roleplay.mercenaire.phrases");
	LoadTranslations("roleplay.police.phrases");
	LoadTranslations("roleplay.technicien.phrases");
	
	//
	// Events:
	HookEvent("player_death", 		EventDeath, 		EventHookMode_Pre);
	HookEvent("player_spawn", 		EventSpawn, 		EventHookMode_Post);
	HookEvent("round_start", 		EventRoundStart, 	EventHookMode_Post);
	HookEvent("round_end",			EventRoundEnd,		EventHookMode_Post);
	HookEvent("player_team", 		EventPlayerTeam,	EventHookMode_Pre);
	HookEvent("player_blind", 		EventFlashPlayer,	EventHookMode_Pre);
	HookEvent("bullet_impact",		EventPlayerShot,	EventHookMode_Pre);
	HookEvent("weapon_fire",		EventPlayerFire,	EventHookMode_Post);
	HookEvent("weapon_zoom",		EventZoom,			EventHookMode_Post);
	HookEvent("player_falldamage",	EventPlayerFallDamage,	EventHookMode_Pre);
	HookEvent("player_changename",	EventBlockMessage,	EventHookMode_Pre);
	HookEvent("player_connect", 	EventBlockMessage,	EventHookMode_Pre);
	HookEvent("player_disconnect", 	EventBlockMessage,	EventHookMode_Pre);
	HookEvent("teamplay_broadcast_audio", EventBlockMessage, EventHookMode_Pre);
	//
	//
	// GameLog: Hook
	//
	AddGameLogHook(	GameLogHook );
	HookUserMessage(GetUserMessageId("SayText2"), EventBlockUserMessage, true);
	//
	//
	// Temp Ent Hook
	//
	AddCommandListener(Command_LAW, "+lookatweapon");
	AddCommandListener(Command_LAW2, "-lookatweapon");
	//
	//
	// Commandes
	//
	RegAdminCmd("rp_phone",				cmd_ForcePhone,		ADMFLAG_BAN);
	RegAdminCmd("rp_saveall",			Cmd_SaveDoor,		ADMFLAG_BAN);
	RegAdminCmd("rp_save",				Cmd_Save,			ADMFLAG_BAN);
	RegAdminCmd("rp_blind", 			cmd_SetBlind,		ADMFLAG_BAN);
	RegAdminCmd("rp_unblind", 			cmd_UnBlind,		ADMFLAG_BAN);
	RegAdminCmd("rp_heal", 				cmd_SetHeal,		ADMFLAG_BAN);
	RegAdminCmd("rp_kevlar", 			cmd_SetKevlar,		ADMFLAG_BAN);
	RegAdminCmd("rp_tdm", 				cmd_SetTDM,			ADMFLAG_CHEATS);
	RegAdminCmd("rp_reset", 			cmd_SetClear,		ADMFLAG_BAN);
	RegAdminCmd("rp_color",				cmd_SetColor,		ADMFLAG_BAN);
	RegAdminCmd("rp_cut",				cmd_SetCut,			ADMFLAG_BAN);
	RegAdminCmd("rp_fist",				cmd_SetFist,		ADMFLAG_BAN);
	RegAdminCmd("rp_tir",				cmd_SetTir,			ADMFLAG_BAN);
	RegAdminCmd("rp_beacon",			cmd_Beacon,			ADMFLAG_BAN);
	RegAdminCmd("rp_saveall",			Cmd_SaveDoor,		ADMFLAG_BAN);
	RegAdminCmd("rp_afk",				Cmd_CheckAFK,		ADMFLAG_BAN);
	RegAdminCmd("rp_clean", 			cmd_CleanMap,		ADMFLAG_BAN);
	RegAdminCmd("rp_unmute", 			cmd_SetMute,		ADMFLAG_BAN);
	RegAdminCmd("rp_spawner_reload",	CmdBank_reload,		ADMFLAG_BAN);
	RegAdminCmd("rp_noclip", 			cmd_NoclipVip,		ADMFLAG_BAN);
	RegAdminCmd("rp_giveweapons", 			cmd_GiveWeaponEvent,		ADMFLAG_BAN);
	//
	RegAdminCmd("rp_lock",   			cmd_ForceLock, 		ADMFLAG_ROOT);
	RegAdminCmd("rp_unlock", 			cmd_ForceUnlock, 	ADMFLAG_ROOT);
	RegAdminCmd("rp_givejob",			cmd_ForceJob,		ADMFLAG_ROOT);
	RegAdminCmd("rp_success",			cmd_SuccessTest,	ADMFLAG_ROOT);
	RegAdminCmd("rp_give_assu",			cmd_GiveAssurance,	ADMFLAG_ROOT);
	RegAdminCmd("rp_force_pay",			CmdForcePay,		ADMFLAG_ROOT);
	RegAdminCmd("rp_damage",			cmd_Damage,			ADMFLAG_ROOT);
	RegAdminCmd("rp_rof",				cmd_ROF,			ADMFLAG_ROOT);
	RegAdminCmd("rp_spawner_add",		CmdBank_add,		ADMFLAG_ROOT);
	RegAdminCmd("rp_force_clean", 		cmd_CleanMapForce,	ADMFLAG_ROOT);
	RegAdminCmd("rp_rebuildmap", 		cmd_Rebuild,		ADMFLAG_ROOT);
	RegAdminCmd("rp_deagleweapon", 		cmd_GiveAkDeagle,	ADMFLAG_ROOT);
	RegAdminCmd("rp_restarttuto", 		cmd_RestartTutorial,ADMFLAG_ROOT);
	RegAdminCmd("rp_debug", 			cmd_ToggleDebug,	ADMFLAG_ROOT);
	RegAdminCmd("rp_hideadm",			cmd_ToggleHide,		ADMFLAG_KICK);
	//
	if( GetConVarInt(FindConVar("hostport")) == 27015 ) {
		RegAdminCmd("rp_givemejob",		cmd_ForceMeJob,		ADMFLAG_ROOT);
		RegAdminCmd("rp_givemegroup",	cmd_ForceMeGroup,	ADMFLAG_ROOT);
		RegAdminCmd("rp_giveitems",		cmd_GiveItem,		ADMFLAG_ROOT);
	}
	else {
		RegConsoleCmd("rp_givemejob", 	cmd_ForceMeJob);
		RegConsoleCmd("rp_givemegroup", cmd_ForceMeGroup);
		RegConsoleCmd("rp_giveitems", 	cmd_GiveItem);
		RegConsoleCmd("rp_givecash", 	cmd_GiveCash);
		RegConsoleCmd("rp_givemexp", 	cmd_GiveMeXP);
	}
	//
	RegAdminCmd("rp_create_mapconfig", 	CmdGenMapConfig,	ADMFLAG_ROOT);
	RegAdminCmd("rp_create_point",		CmdSpawn2_Add,		ADMFLAG_ROOT);
	RegAdminCmd("rp_reloadSQL",			Cmd_ReloadSQL,		ADMFLAG_ROOT);
	RegServerCmd("rp_start_quest",		Cmd_StartQuest);
	RegServerCmd("rp_stop_quest",		Cmd_StopQuest);
	RegServerCmd("rp_quest_reload", 	CmdReloadQuest);
	RegServerCmd("rp_zombie_die",		CmdSpawnCadeau);
	RegServerCmd("rp_blackfriday", 		CmdBlackFriday);
	//
	//
	//
	// Cvar:
	//
	g_hAllowItem 		= CreateConVar("rp_allow_item", "1", "Autorise ou non l'utilisation des items.", _, true, 0.0, false, 2.0);
	g_hSick				= CreateConVar("rp_sick", "1");
	g_hMAX_ENT 			= CreateConVar("rp_max_entity",	"1800", "PAS TOUCHE", FCVAR_UNREGISTERED, true, 1000.0, true, 2000.0);
	g_hEVENT			= CreateConVar("rp_event",	"0");
	g_hEVENT_3RD		= CreateConVar("rp_event_3rd",	"1");
	g_hEVENT_HIDE			= CreateConVar("rp_hide",	"0");
	#if defined EVENT_NOEL
	g_hEVENT_NOEL		= CreateConVar("rp_event_noel", "1");
	g_hEVENT_NOEL_SPEED = CreateConVar("rp_event_noel_speed", "40");
	#endif
	g_hItemBackup		= CreateConVar("rp_item_backup", "1");
	g_hAllowSteal		= CreateConVar("rp_allow_steal", "1");
	g_hCapturable 		= CreateConVar("rp_capture", "0");
	g_hAllowDamage		= CreateConVar("rp_car_damages", "20");
	
	SetConVarInt(g_hItemBackup, 1);
	CreateTimer(15.0 * 60.0, SwitchOFF);
	HookConVarChange(g_hMAX_ENT, OnCvarChange);
	HookConVarChange(g_hCapturable, OnCvarChange);
	HookConVarChange(g_hEVENT_HIDE, OnCvarChange);
	HookConVarChange(g_hAllowDamage, OnCvarChange);	
	HookConVarChange(g_hEVENT_3RD, OnCvarChange);	
	//
	RegConsoleCmd("jointeam", 			cmd_Jointeam);
	//
	// Say's
	RegConsoleCmd("say", 				Command_Say);
	RegConsoleCmd("say_team", 			Command_SayTeam);
	//
	// Blocked:
	for(int i; i < sizeof(DeniedCMD); i++) {
		RegConsoleCmd(DeniedCMD[i], 		Cmd_BlockedSilent, "[TSX-RP]: Commande non-autorisee",	FCVAR_UNREGISTERED);
	}
	// DataBASE
	//
	
	char strIP[128];
	Handle hostip = FindConVar("hostip");
	int longip = GetConVarInt(hostip);
	Format(strIP, sizeof(strIP),"%d.%d.%d.%d", (longip >> 24) & 0xFF, (longip >> 16) & 0xFF, (longip >> 8 )	& 0xFF, longip & 0xFF);
	
	if( StrEqual(strIP, "5.196.39.50") ) { 
		Handle KV = CreateKeyValues("sql");
		KvSetString(KV,"driver",	"mysql");
		KvSetString(KV,"host",		"5.196.39.48");
	
		// a modif quand serv test 
		if( GetConVarInt(FindConVar("hostport")) == 27015 ) {
			KvSetString(KV,"user",		"rp_csgo");
			KvSetString(KV,"database",	"rp_csgo");
			KvSetString(KV,"pass",		"DYhpWeEaWvDsMDc9");
		}
		else {
			KvSetString(KV,"user",		"rp_test");
			KvSetString(KV,"database",	"rp_test");
			KvSetString(KV,"pass",		"pI3SzTTd3Ow1Tsjd");
		}

		KvSetString(KV,"port",		"3306");
		g_hBDD = SQL_ConnectCustom(KV, g_szError, sizeof(g_szError), true);
	}
	else {
		g_hBDD = SQL_Connect("roleplay", true, g_szError, sizeof(g_szError));
	}

	if( g_hBDD == INVALID_HANDLE ) {
		SetFailState("ERREUR FATAL: Connexion a la base de donnee impossible: %s", g_szError);
	}
	else {
		PrintToServer("[TSX-RP] Connexion a la base de donnee reussie");
		SQL_LockDatabase(g_hBDD);
		SQL_Query(g_hBDD, "SET NAMES 'utf8mb4'");
		SQL_UnlockDatabase(g_hBDD);
	}

	g_hSynProcessed = new StringMap(); // Ne pas executer une syn / assu plusieures fois
	g_hSynAssuWritten = new StringMap();
	
	for (int i = 1; i <= MaxClients; i++) {
		view_as<Handle>(g_hRPNative[i][RP_PreTakeDamage]) = CreateForward(ET_Hook, Param_Cell, Param_Cell, Param_FloatByRef, Param_Cell);
		view_as<Handle>(g_hRPNative[i][RP_PostTakeDamageWeapon]) = CreateForward(ET_Hook, Param_Cell, Param_Cell, Param_FloatByRef, Param_Cell, Param_Array);
		view_as<Handle>(g_hRPNative[i][RP_PostTakeDamageKnife]) = CreateForward(ET_Hook, Param_Cell, Param_Cell, Param_FloatByRef);
		view_as<Handle>(g_hRPNative[i][RP_PreGiveDamage]) = CreateForward(ET_Hook, Param_Cell, Param_Cell, Param_FloatByRef, Param_Cell);
		view_as<Handle>(g_hRPNative[i][RP_PostGiveDamageWeapon]) = CreateForward(ET_Hook, Param_Cell, Param_Cell, Param_FloatByRef, Param_Cell, Param_Array);
		view_as<Handle>(g_hRPNative[i][RP_PostGiveDamageKnife]) = CreateForward(ET_Hook, Param_Cell, Param_Cell, Param_FloatByRef);
		view_as<Handle>(g_hRPNative[i][RP_PrePlayerPhysic]) = CreateForward(ET_Hook, Param_Cell, Param_FloatByRef, Param_FloatByRef);
		view_as<Handle>(g_hRPNative[i][RP_PostPlayerPhysic]) = CreateForward(ET_Hook, Param_Cell, Param_FloatByRef, Param_FloatByRef);
		view_as<Handle>(g_hRPNative[i][RP_PreHUDColorize]) = CreateForward(ET_Hook, Param_Cell, Param_Array);
		view_as<Handle>(g_hRPNative[i][RP_OnFrameSeconde]) = CreateForward(ET_Hook, Param_Cell);
		view_as<Handle>(g_hRPNative[i][RP_OnAssurance]) = CreateForward(ET_Hook, Param_Cell, Param_CellByRef);
		view_as<Handle>(g_hRPNative[i][RP_OnPlayerSpawn]) = CreateForward(ET_Hook, Param_Cell);
		view_as<Handle>(g_hRPNative[i][RP_OnPlayerDead]) = CreateForward(ET_Hook, Param_Cell, Param_Cell, Param_CellByRef, Param_CellByRef, Param_CellByRef);
		view_as<Handle>(g_hRPNative[i][RP_OnPlayerKill]) = CreateForward(ET_Hook, Param_Cell, Param_Cell, Param_String, Param_CellByRef, Param_CellByRef);
		view_as<Handle>(g_hRPNative[i][RP_OnPlayerBuild]) = CreateForward(ET_Hook, Param_Cell, Param_CellByRef);
		view_as<Handle>(g_hRPNative[i][RP_OnPlayerUse]) = CreateForward(ET_Hook, Param_Cell);
		view_as<Handle>(g_hRPNative[i][RP_OnPlayerCommand]) = CreateForward(ET_Hook, Param_Cell, Param_String, Param_String);
		view_as<Handle>(g_hRPNative[i][RP_PrePlayerTalk]) = CreateForward(ET_Hook, Param_Cell, Param_String, Param_Cell, Param_Cell);
		view_as<Handle>(g_hRPNative[i][RP_OnPlayerDataLoaded]) = CreateForward(ET_Hook, Param_Cell);
		view_as<Handle>(g_hRPNative[i][RP_OnPlayerPreSteal]) = CreateForward(ET_Hook, Param_Cell, Param_Cell, Param_CellByRef);
		view_as<Handle>(g_hRPNative[i][RP_OnPlayerSteal]) = CreateForward(ET_Hook, Param_Cell, Param_Cell, Param_CellByRef);
		view_as<Handle>(g_hRPNative[i][RP_OnPlayerHear]) = CreateForward(ET_Hook, Param_Cell, Param_Cell, Param_FloatByRef);
		view_as<Handle>(g_hRPNative[i][RP_OnPlayerZoneChange]) = CreateForward(ET_Hook, Param_Cell, Param_Cell, Param_Cell);
		view_as<Handle>(g_hRPNative[i][RP_OnPlayerSell]) = CreateForward(ET_Hook, Param_Cell, Param_Cell);
		view_as<Handle>(g_hRPNative[i][RP_OnPlayerHUD]) = CreateForward(ET_Hook, Param_Cell, Param_String, Param_Cell);
		view_as<Handle>(g_hRPNative[i][RP_OnPlayerCheckKey]) = CreateForward(ET_Hook, Param_Cell, Param_Cell, Param_Cell);
		view_as<Handle>(g_hRPNative[i][RP_OnResellWeapon]) = CreateForward(ET_Hook, Param_Cell, Param_Cell, Param_Cell);
		view_as<Handle>(g_hRPNative[i][RP_PreClientCraft]) = CreateForward(ET_Hook, Param_Cell, Param_Cell, Param_CellByRef);
		view_as<Handle>(g_hRPNative[i][RP_PostClientCraft]) = CreateForward(ET_Hook, Param_Cell, Param_Cell);
		view_as<Handle>(g_hRPNative[i][RP_PreBuildingCount]) = CreateForward(ET_Hook, Param_Cell, Param_Cell, Param_CellByRef);
		view_as<Handle>(g_hRPNative[i][RP_PostPickLock]) = CreateForward(ET_Hook, Param_Cell, Param_Cell, Param_Cell, Param_Cell);
		view_as<Handle>(g_hRPNative[i][RP_PostPiedBiche]) = CreateForward(ET_Hook, Param_Cell, Param_Cell);
		view_as<Handle>(g_hRPNative[i][RP_PreClientTeleport]) = CreateForward(ET_Hook, Param_Cell);
		view_as<Handle>(g_hRPNative[i][RP_PostStealWeapon]) = CreateForward(ET_Hook, Param_Cell, Param_Cell, Param_Cell);
		view_as<Handle>(g_hRPNative[i][RP_PreClientStealItem]) = CreateForward(ET_Hook, Param_Cell, Param_Cell);
		view_as<Handle>(g_hRPNative[i][RP_PreClientSendToJail]) = CreateForward(ET_Hook, Param_Cell, Param_Cell);
		view_as<Handle>(g_hRPNative[i][RP_PostClientSendToJail]) = CreateForward(ET_Hook, Param_Cell, Param_Cell);
		view_as<Handle>(g_hRPNative[i][RP_OnClientTazedItem]) = CreateForward(ET_Hook, Param_Cell, Param_Cell);
		view_as<Handle>(g_hRPNative[i][RP_PlayerCanKill]) = CreateForward(ET_Hook, Param_Cell, Param_Cell);
		view_as<Handle>(g_hRPNative[i][RP_PlayerCanUseItem]) = CreateForward(ET_Hook, Param_Cell, Param_Cell);
		view_as<Handle>(g_hRPNative[i][RP_OnBlackMarket]) = CreateForward(ET_Hook, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_CellByRef, Param_Cell);
		view_as<Handle>(g_hRPNative[i][RP_OnPlayerHINT]) = CreateForward(ET_Hook, Param_Cell, Param_Cell);		
		view_as<Handle>(g_hRPNative[i][RP_OnJugementOver]) = CreateForward(ET_Hook, Param_Cell, Param_Array, Param_Array);
		view_as<Handle>(g_hRPNative[i][RP_OnPlayerPay]) = CreateForward(ET_Hook, Param_Cell, Param_Cell, Param_CellByRef, Param_Cell);
		view_as<Handle>(g_hRPNative[i][RP_OnPlayerEmote]) = CreateForward(ET_Hook, Param_Cell, Param_String, Param_Cell);
		view_as<Handle>(g_hRPNative[i][RP_OnPlayerGotRaw]) = CreateForward(ET_Hook, Param_Cell, Param_Cell, Param_Cell, Param_CellByRef);
		
		g_iChatData[i] = new ArrayList(1);
		g_iDoubleCompte[i] = new ArrayList(64);
		g_iParentedParticle[i] = new ArrayList(1);
		g_hAggro[i] = new ArrayList(KillStack_max, 0);
	}
	
	g_hForward_RP_OnPlayerGotPay = CreateGlobalForward("RP_OnPlayerGotPay", ET_Hook, Param_Cell, Param_Cell, Param_CellByRef, Param_Cell);
	
	//
	// FORCE
	//
	RegConsoleCmd("+force", Cmd_grab);
	RegConsoleCmd("-force", Cmd_release);
	RegAdminCmd("sm_force", Cmd_ForceMenu, ADMFLAG_BAN, "Ouvre le menu de gestion du +force");
	RegConsoleCmd("say", Cmd_Force_Rebind);
	Handle hGameData = LoadGameConfigFile("sdktools.games");
	if(hGameData == INVALID_HANDLE)
		return;
	
	int iOffset;
	iOffset = GameConfGetOffset(hGameData, "Teleport");
	
	if(iOffset != -1) {
		g_hTeleport = DHookCreate(iOffset, HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity, DHooks_OnTeleport);
		if(g_hTeleport != INVALID_HANDLE) {
			DHookAddParam(g_hTeleport, HookParamType_VectorPtr);
			DHookAddParam(g_hTeleport, HookParamType_VectorPtr);
			DHookAddParam(g_hTeleport, HookParamType_VectorPtr);
			DHookAddParam(g_hTeleport, HookParamType_Bool);
		}
	}
	
	iOffset = GameConfGetOffset(hGameData, "PlayerRunCmd") + 46;
	
	if(iOffset != -1) {
		g_hOnVoiceTransmit = DHookCreate(iOffset, HookType_Entity, ReturnType_Int, ThisPointer_CBaseEntity, DHooks_OnVoicePost);
	}
	
	CloseHandle(hGameData);

	RegAdminCmd("sm_bf",			Command_DebugBF,			ADMFLAG_ROOT);	
}

public Action Command_DebugBF(int client, int args) {
	char szDate[32];
	FormatDate(g_iBlackFriday[0], szDate, sizeof(szDate));
	
	ReplyToCommand(client, "BF ? %s", g_bIsBlackFriday ? "yes":"no");
	ReplyToCommand(client, "BF DATE : %i (%s)", g_iBlackFriday[0], szDate);
	ReplyToCommand(client, "BF REDUCTION : %i", g_iBlackFriday[1]);
}
public void OnConfigsExecuted() {
	/* Armes*/
	ServerCommand("ammo_grenade_limit_snowballs 1");
	ServerCommand("healthshot_health 250");
	ServerCommand("sv_extract_ammo_from_dropped_weapons 0");
	ServerCommand("sv_infinite_ammo 0");
	ServerCommand("mp_molotovusedelay 0");
	ServerCommand("mp_weapons_allow_map_placed 1");
	ServerCommand("mp_t_default_secondary \"\"");
	ServerCommand("mp_ct_default_secondary \"\"");
	ServerCommand("weapon_accuracy_nospread 0");
	ServerCommand("weapon_recoil_scale 1");
	ServerCommand("weapon_reticle_knife_show 1");
	ServerCommand("weapon_auto_cleanup_time 60");
	ServerCommand("weapon_max_before_cleanup 128");
	/* Config round */
	ServerCommand("mp_ignore_round_win_conditions 0");
	ServerCommand("mp_do_warmup_period 0");
	ServerCommand("mp_warmuptime 0");
	ServerCommand("mp_timelimit 0");
	ServerCommand("mp_fraglimit 0");
	ServerCommand("mp_match_can_clinch 0");
	ServerCommand("mp_freezetime 0");
	ServerCommand("mp_respawn_immunitytime 0");
	ServerCommand("mp_randomspawn 0");
	ServerCommand("mp_match_end_restart 0");
	ServerCommand("mp_roundtime 0");
	ServerCommand("mp_backup_round_file \"\"");
	ServerCommand("mp_backup_round_auto 0");
	ServerCommand("mp_randomspawn 0");
	/* Config caméra */
	ServerCommand("mp_forcecamera 2");
	ServerCommand("mp_radar_showall 2");
	/* Config damage */
	ServerCommand("mp_friendlyfire 1");
	ServerCommand("mp_autokick 0");
	ServerCommand("mp_teammates_are_enemies 1");
	ServerCommand("mp_tkpunish 0");
	ServerCommand("sv_disable_immunity_alpha 1");
	/* Config HUD */		
	ServerCommand("mp_playerid 2");
	ServerCommand("mp_playerid_delay 0");
	ServerCommand("mp_playerid_hold 0");
	/* Config log */	
	ServerCommand("mp_logdetail 3");
	ServerCommand("mp_logdetail_items 1");
	ServerCommand("sv_logflush 1");
	/* Config team */
	ServerCommand("mp_humanteam T");
	ServerCommand("mp_solid_teammates 1");
	ServerCommand("mp_limitteams 0");
	ServerCommand("mp_playercashawards 0");
	ServerCommand("mp_teamcashawards 0");
	ServerCommand("mp_spectators_max 10 ");
	ServerCommand("spec_freeze_deathanim_time 999999");
	ServerCommand("cs_enable_player_physics_box 1");
	/* Config drop */
	ServerCommand("mp_death_drop_breachcharge  1");
	ServerCommand("mp_death_drop_gun 1");
	ServerCommand("mp_death_drop_healthshot  1");
	ServerCommand("mp_death_drop_taser 1");
	ServerCommand("mp_drop_knife_enable 1");
	/* Config message */
	ServerCommand("sv_damage_print_enable 0");
	ServerCommand("sv_ignoregrenaderadio 1");
	ServerCommand("sv_ignoregrenaderadio 1");
	ServerCommand("sv_allow_votes 0");
	ServerCommand("sv_gameinstructor_disable 1");	
	/* Config server */
	ServerCommand("sv_usercmd_custom_random_seed 0");
	ServerCommand("sv_allow_thirdperson 1");
	ServerCommand("sv_cheats 1");
	ServerCommand("sv_dc_friends_reqd 0");
	ServerCommand("sv_kick_players_with_cooldown 0");
	ServerCommand("sv_vote_kick_ban_duration 1");
	ServerCommand("sv_disable_motd 0");
	ServerCommand("sv_force_transmit_players 1");
	ServerCommand("sv_steamauth_enforce 0");
	ServerCommand("sv_quota_stringcmdspersecond 128");
	/* Config all-talk */
	ServerCommand("sv_alltalk 1");
	ServerCommand("sv_full_alltalk 1");
	ServerCommand("sv_talk_enemy_alive 1");
	ServerCommand("sv_talk_enemy_living 1");
	/* Config cash */
	ServerCommand("cash_player_killed_enemy_factor 0");
	ServerCommand("cash_player_killed_enemy_default 0");
	/* Config Steam */
	ServerCommand("host_name_store 1");
	ServerCommand("host_info_show 2");
	ServerCommand("host_players_show 2");
	ServerCommand("sv_tags \"roleplay,rp,ba-jail,ba_jail,bajail,jail\"");
	ServerCommand("sv_steamgroup 1454657");
	/* Config autre plugins */
	ServerCommand("cheatcontrol_enablewarnings 0");
	/* RP Config */
	ServerCommand("rp_max_car 20");
	ServerCommand("rp_fireworks 10");

	/* Restart */
	ServerCommand("mp_restartgame 1");
	ServerCommand("ent_remove_all prop_vehicle_driveable");
	ServerCommand("exec performance.cfg");
	//g_hWeaponScale = FindConVar("weapon_recoil_scale");
}
public Action SwitchOFF(Handle timer, any omg) {
	SetConVarInt(g_hItemBackup, 0);
}
public void OnPluginEnd() {
	OnMapEnd();
}
