#if defined _roleplay_const_included
#endinput
#endif
#define _roleplay_const_included

#include <rp_const>


#define MAX_BUYWEAPONS			40
#define MAX_KEYSELL				200
#define	MAX_RANK				33

#define MAX_INV					(MAX_ITEMS+1)

#define MAX_CHANDLES			5
#define MAX_PHRASE				5
#define MAX_JAILRAISON			20
#define ITEM_TIME				60

#define RANGE					150.0
#define VELOCITY_MULTIPLIER		10.0
#define DISTANCE				100.0

#define DEFAULT_SPEED			0.85

//
// do not edit bellow:

#define PROPTYPE_FAILED			-3
#define PROPTYPE_WRONGPROP		-2
#define PROPTYPE_BADENT			-1
#define PROPTYPE_BOTH			0
#define PROPTYPE_SEND			1
#define PROPTYPE_DATA			2
#define DAMAGE_NO 				0
#define DAMAGE_YES 				2
#define SOLID_VPHYSICS	 		6
#define COLLISION_GROUP_PLAYER 	5

#define EF_BONEMERGE			(1 << 0)
#define EF_NOINTERP				(1 << 3)
#define EF_NOSHADOW 			(1 << 4)
#define	EF_BONEMERGE_FASTCULL	(1 << 7)
#define EF_PARENT_ANIMATES		(1 << 9)



#define BUFFER_SIZE			32

char g_szSuperAdmin[][] = {
	"76561197987342816", // Gozer
	"76561197976095234", // Genesys
	"76561198297704101", // Sheep
	"76561197975247242", // Kosso
	"76561197975262643", // sky
	"76561198086680839", // CBKKK
	"76561198007500554", // Messorem
	"76561198188535251", // Exodus (Il m'a forcé :'( )
	"76561198992350563", // Mimou
	"76561198334900775", // Leethium
	"76561198240487014" // Mamasita
};

int g_iPlayerCount;
float vecNull[3];
bool g_bLoaded = false;

char szGeneralMenu[64];
char DeniedCMD[][] = {"coverme", "takepoint", "holdpos", "regroup", "followme", "takingfire", "go", "fallback", "sticktog",
	"getinpos", "stormfront", "report", "roger", "enemyspot", "needbackup", "sectorclear", "inposition", "reportingin",
	"getout", "negative","enemydown", "radio1", "radio2", "radio3", "cheer", "compliment", "thanks", "explode", "kill", "r_screenoverlay",
	"chooseteam", "chooseclass", "joinclass", "spectate", "spec_mode", "cl_spec_mode", "killvector", "teammenu",
	"chatwheel_ping", "player_ping", "playerchatwheel" };

bool g_bEvent_Kidnapping = false;

enum key_type {
	key_type_id = 0,
	key_type_job_id,
	key_type_parent,
	
	key_type_prix,
	key_type_name,
	
	key_type_max
};


enum SynType {
	SynType_job = 0,
	SynType_group,
	SynType_money,
	SynType_jail,
	SynType_itemBank,
	SynType_item,
	SynType_xp,
	SynType_jetonpass,
	SynType_jetonabo,
	
	
	SynType_max
};
enum KillStack {
	KillStack_target,
	KillStack_damage,
	KillStack_time,
	
	KillStack_max
};

float g_flVehicleDamage = 1.0;
Handle g_hAllowDamage;

//
// Globals
int g_iSID = -1;
Handle g_hRPNative[65][ view_as<int>(RP_EventMax) ];

bool g_bUserData[MAX_PLAYERS+1][ view_as<int>(b_udata_max) ];
int g_iUserData[MAX_PLAYERS+1][ view_as<int>(i_udata_max) ];
float g_flUserData[MAX_PLAYERS+1][ view_as<int>(fl_udata_max) ];
char g_szUserData[MAX_PLAYERS+1][ view_as<int>(sz_udata_max) ][128];

int g_iUserStat[MAX_PLAYERS+1][ view_as<int>(i_uStat_max) ];

int g_iBlockedTime[MAX_PLAYERS+1][MAX_PLAYERS+1];
int g_iHideNextLog[MAX_PLAYERS+1][MAX_PLAYERS+1];

ArrayList g_hAggro[MAX_PLAYERS+1];
int g_iAggro[MAX_PLAYERS+1][MAX_PLAYERS+1];
int g_iAggroTimer[MAX_PLAYERS+1][MAX_PLAYERS+1];
int g_iKillLegitime[MAX_PLAYERS+1][MAX_PLAYERS+1];
int g_iStackCanKill[MAX_PLAYERS+1][MAX_PLAYERS+1];
int g_iStackCanKill_Count[MAX_PLAYERS+1];
int g_iJobPlayerTime[MAXPLAYERS + 1][MAX_JOBS + 1];
int g_iServerRules[server_rules_max][view_as<int>(rules_data_max)];

bool g_bIsHidden[MAXPLAYERS + 1];
ArrayList g_iChatData[MAX_PLAYERS + 1];
ArrayList g_iDoubleCompte[MAXPLAYERS + 1];
ArrayList g_iParentedParticle[MAXPLAYERS + 1];

Handle g_hTIMER[65];

int g_iAlphaChannel[MAX_PLAYERS+1][4];
float g_vecAngles[MAX_PLAYERS+1][3];
char g_szPlainte[MAX_PLAYERS+1][2][128];

int g_iClientFloodValue[MAX_PLAYERS + 1][MAX_PLAYERS + 1][view_as<int>(fd_udata_max)];
float g_flClientFloodTime[MAX_PLAYERS + 1][MAX_PLAYERS + 1][view_as<int>(fd_udata_max)];
Handle g_iClientFloodTimer[MAX_PLAYERS + 1][MAX_PLAYERS + 1][view_as<int>(fd_udata_max)];

float g_flEntityData[MAX_ENTITIES + 1][view_as<int>(building_prop_data_max)];
float g_flWeaponFireRate[MAX_ENTITIES + 1];
bool g_bWeaponFireRate[MAX_ENTITIES + 1];

//
int g_iDoorKnowed[MAX_ENTITIES];
int g_iDoorCannotForce[MAX_ENTITIES];
int g_iDoorDouble[MAX_ENTITIES];
int g_iDoorNouse[MAX_ENTITIES];
//
int g_iDoorJob[MAX_JOBS][MAX_ENTITIES];
int g_iDoorOwner_v2[MAX_PLAYERS+1][MAX_KEYSELL];
int g_iAppartBonus[MAX_KEYSELL][view_as<int>(appart_bonus_max)];
bool g_bIsInCaptureMode = false;
//
char g_szEntityWeapons[MAX_ENTITIES];
//
// Chargé depuis la BDD:
char g_szBuyWeapons[MAX_BUYWEAPONS][4][128];
char g_szJobList[MAX_JOBS][view_as<int>(job_type_max)][64];
char g_szItemList[MAX_ITEMS][view_as<int>(item_type_max)][80];
char g_szItemListOrdered[MAX_ITEMS][view_as<int>(item_type_max)][80];
char g_szLocationList[MAX_LOCATIONS][view_as<int>(location_type_max)][128];
char g_szZoneList[MAX_ZONES][view_as<int>(zone_type_max)][128];
char g_szLevelList[MAX_RANK][view_as<int>(rank_type_max)][255];
float g_flZones[MAX_ZONES][2][3];
float g_flPoints[MAX_LOCATIONS][3];
float g_flLastCheck_ZONE[MAX_ZONES+1] = 0.0;
int g_iLastData_ZONE[MAX_ZONES+1];
char g_szSellingKeys[MAX_ENTITIES][view_as<int>(key_type_max)][256];
char g_szGroupList[MAX_JOBS][view_as<int>(job_type_max)][64];
char g_szVillaOwner[view_as<int>(rp_serv_max)][64];
StringMap g_hSynProcessed;
StringMap g_hSynAssuWritten;
//
char g_szEntityName[MAX_ENTITIES][128];
bool g_bPrethinkBuffer[MAX_PLAYERS+1];
int g_iOriginOwner[MAX_ENTITIES];
DataPack g_iCustomBank[MAX_ENTITIES+1];
//
int g_iMinutes = 0;
int g_iHours = 0;
int g_iDays = 0;
int g_iMonth = 0;
int g_iYear = 0;
//
int g_iPhoneType = -1;
float g_flPhoneStart = -60.0;
float g_flPhonePosit[3];
// 
int g_iBlackFriday[2]; // 0 = DATE - 1 = REDUCTION
bool g_bIsBlackFriday = false;

enum type_ClientQuest {
	questID,
	objectiveID,
	startID,
	frameID,
	abortID,
	overID,
	pluginID,
	stepID,
	clientQuestID
};


int g_iClientQuests[MAX_PLAYERS + 1][view_as<int>(type_ClientQuest)];

enum itemDATAStack {
	STACK_item_id,
	STACK_item_amount,
	
	STACK_itemStack_max
};

int g_iItems[MAX_PLAYERS+1][MAX_ITEMS+1][view_as<int>(STACK_itemStack_max)];
int g_iItems_BANK[MAX_PLAYERS+1][MAX_ITEMS+1][view_as<int>(STACK_itemStack_max)];

char g_szItems_SAVE[MAX_PLAYERS+1][64][32];

char g_szPaintBall[11][3][64] = {
	{	"paintball/pb_babyblue2.vmt",		"0",	"0"	},
	{	"paintball/pb_black2.vmt",			"0",	"0"	},
	{	"paintball/pb_blue2.vmt",			"0",	"0"	},
	{	"paintball/pb_brown2.vmt",			"0",	"0"	},
	{	"paintball/pb_dark_green2.vmt",		"0",	"0"	},
	{	"paintball/pb_medslateblue2.vmt",	"0",	"0"	},
	{	"paintball/pb_olive2.vmt",			"0",	"0"	},
	{	"paintball/pb_red_orange2.vmt",		"0",	"0"	},
	{	"paintball/pb_red2.vmt",			"0",	"0"	},
	{	"paintball/pb_violet2.vmt",			"0",	"0"	},
	{	"paintball/pb_white2.vmt",			"0",	"0"	}
};
//
// Cvar's
Handle g_hSick = INVALID_HANDLE;
Handle g_hCapturable = INVALID_HANDLE;
//Handle g_hWeaponScale = INVALID_HANDLE;
//
// HandleBDD
Handle g_hBDD;
char g_szError[1024];
//
//
//
// Sprites
int g_cShockWave, g_cGlow, g_cBeam, g_cExplode, g_cScorch, g_cHacked;
char g_szLastMessage[MAX_PLAYERS+1][5][256];
char g_szLastLocal[MAX_PLAYERS+1][5][256];

// ------------------------------
// Vehicle
//
#if defined USING_VEHICLE
int g_iVehicleData[MAX_ENTITIES][view_as<int>(car_data_max)];
int g_iMayCarAction[MAX_PLAYERS+1];
int g_iCarPassager[MAX_ENTITIES][MAX_PLAYERS+1];
int g_iCarPassager1[MAX_ENTITIES][8];
int g_iCarPassager2[MAX_PLAYERS+1];
int g_iCar_Key[MAX_PLAYERS + 1][MAX_ENTITIES];
#endif
//
int g_iEntityCount = 0;
//
int g_iGroundEntity[MAX_PLAYERS+1];
// ------------------------------
// Force
//
int g_iGrabbing[MAX_PLAYERS+1];
int g_iGrabbedBy[2049];
int g_iMayGrabAll[MAX_PLAYERS+1];
int g_iCurrentKill[MAX_PLAYERS+1];

float g_fGrabbedLength[MAX_PLAYERS+1];

bool g_bToggle[MAX_PLAYERS+1];
bool g_bIsSeeking[MAX_PLAYERS+1];
bool g_bMovingTeleport[MAX_PLAYERS+1];
bool g_bCheckSphere[MAX_PLAYERS+1];
bool g_bGrabNear[MAX_PLAYERS+1];
int g_iClient_OLD[MAX_PLAYERS+1];
float g_flLubrifian[MAX_PLAYERS+1];
// ------------------------------
// AFK-Manager
//
float g_Position[MAX_PLAYERS+1][3];
Handle g_hClientMicTimers[MAXPLAYERS + 1];
// ------------------------------
// Weapon-Manager
//
int g_iWeaponStolen[MAX_ENTITIES];
int g_iWeapons[MAX_ENTITIES];
int g_iWeaponsGroup[MAX_ENTITIES];
int g_iWeaponFromStore[MAX_ENTITIES];

enum_ball_type g_iWeaponsBallType[MAX_ENTITIES];
float g_Client_AMP[MAX_PLAYERS+1];
// ------------------------------
// Cut-Manager
//
enum_ball_type g_iKnifeType[MAX_PLAYERS+1];

int g_iLDR = 0;
int START_ZONE = MAX_ZONES+1;
int EVENT_HIDE = 0;
int EVENT_3RD = 1;

// ------------------------------
// MUTE ME PLEASE
//
// -----------------------------------------------------------------------------------------------------------------
//
//	ConVar
//
Handle g_hAllowItem = INVALID_HANDLE;
Handle g_hAllowSteal = INVALID_HANDLE;
Handle g_hMAX_ENT = INVALID_HANDLE;
int g_iEntityLimit = 2000;
Handle g_hEVENT = INVALID_HANDLE;
Handle g_hEVENT_3RD = INVALID_HANDLE;
Handle g_hEVENT_HIDE = INVALID_HANDLE;
#if defined EVENT_NOEL
Handle g_hEVENT_NOEL = INVALID_HANDLE;
Handle g_hEVENT_NOEL_SPEED = INVALID_HANDLE;
#endif
Handle g_hItemBackup = INVALID_HANDLE;

#if defined ROLEPLAY_SUB
	#include "../roleplay.inc.weapons.sp"
	#include "../roleplay.inc.weapons.custom.sp"
	
	#if defined USING_VEHICLE
	#include "../roleplay.inc.vehicle.sp"
	#endif
	
	#include "../roleplay.inc.success.sp"
	#include "../roleplay.inc.phone.sp"
	#include "../roleplay.inc.tutorial.sp"
	
	#include "../roleplay.inc.stock.sp"
	
	#include "../roleplay.inc.stock.jobs.sp"
	#include "../roleplay.inc.stock.hud.sp"
	#include "../roleplay.inc.stock.groups.sp"
	#include "../roleplay.inc.stock.effect.sp"
	#include "../roleplay.inc.stock.doors.sp"
	#include "../roleplay.inc.stock.database.sp"
	#include "../roleplay.inc.stock.client.sp"
	#include "../roleplay.inc.stock.builds.sp"
	#include "../roleplay.inc.stock.voice.sp"
	#include "../roleplay.inc.stock.zone.sp"
	
	#include "../roleplay.inc.say.sp"
	#include "../roleplay.inc.natives.sp"
	
	#include <roleplay/menu.sp>
	#include <roleplay/event.sp>
	
	#include "../roleplay.inc.item.sp"
	#include "../roleplay.inc.frames.sp"
	#include "../roleplay.inc.force.sp"
	#include "../roleplay.inc.cmds.sp"
	#include "../roleplay.inc.quests.sp"
	
#else
	#include "roleplay.inc.weapons.sp"
	#include "roleplay.inc.weapons.custom.sp"
	
	#if defined USING_VEHICLE
	#include "roleplay.inc.vehicle.sp"
	#endif
	
	#include "roleplay.inc.success.sp"
	#include "roleplay.inc.phone.sp"
	#include "roleplay.inc.tutorial.sp"
	
	#include "roleplay.inc.stock.sp"
	
	#include "roleplay.inc.stock.jobs.sp"
	#include "roleplay.inc.stock.hud.sp"
	#include "roleplay.inc.stock.groups.sp"
	#include "roleplay.inc.stock.effect.sp"
	#include "roleplay.inc.stock.doors.sp"
	#include "roleplay.inc.stock.database.sp"
	#include "roleplay.inc.stock.client.sp"
	#include "roleplay.inc.stock.builds.sp"
	#include "roleplay.inc.stock.voice.sp"
	#include "roleplay.inc.stock.zone.sp"
	
	#include "roleplay.inc.say.sp"
	#include "roleplay.inc.natives.sp"
	
	#include <roleplay/menu.sp>
	#include <roleplay/event.sp>
	
	#include "roleplay.inc.item.sp"
	#include "roleplay.inc.frames.sp"
	#include "roleplay.inc.force.sp"
	#include "roleplay.inc.cmds.sp"
	#include "roleplay.inc.quests.sp"
	
#endif
