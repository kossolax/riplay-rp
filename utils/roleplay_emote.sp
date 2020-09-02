#include <sourcemod>
#include <sdktools>
#include <dhooks>
#include <sdkhooks>
#include <colors_csgo>	// https://forums.alliedmods.net/showthread.php?p=2205447#post2205447
#include <smlib>

#pragma newdecls required
#include <roleplay>

int g_iEmoteEnt[65];
int g_iEmoteClient[2049];

#define EF_BONEMERGE			(1 << 0)
#define EF_NOINTERP				(1 << 3)
#define EF_NOSHADOW 			(1 << 4)
#define	EF_BONEMERGE_FASTCULL	(1 << 7)
#define EF_PARENT_ANIMATES		(1 << 9)
Handle g_hTeleport;

char g_szEmote[][][] = {
	{"Emote_Fonzie_Pistol",	"Fonzie Pistol", 	"0"},
	{"Emote_Bring_It_On",	"Bring it On",		"0"},
	{"Emote_ThumbsDown", 	"Thumbs Down", 		"0"},
	{"Emote_ThumbsUp",		"Thumbs Up", 		"0"},
	{"Emote_BlowKiss", 		"Blow Kiss", 		"0"},
	{"Emote_Calculated", 	"Calculated", 	"0"},
	{"Emote_Confused",		"Confused", "0"},
	{"Emote_Chug", 			"Chug", "0"},
	{"Emote_Cry", 			"Cry", "0"},
	{"Emote_DustingOffHands", "Dusting Off Hands", "0"},
	{"Emote_DustOffShoulders", "Dust Off Shoulders", "0"},
	{"Emote_Facepalm", 		"Facepalm", "0"},
	{"Emote_Fishing", 		"Fishing", "0"},
	{"Emote_Flex", 			"Flex", "0"},
	{"Emote_golfclap", 		"golfclap", "0"},
	{"Emote_HandSignals", 	"Hand Signals", "0"},
	{"Emote_HeelClick", 	"Heel Click", "0"},
	{"Emote_Hotstuff", 		"Hotstuff", "0"},
	{"Emote_IBreakYou", 	"I Break You", "0"},
	{"Emote_IHeartYou", 	"I Heart You", "0"},
	{"Emote_Kung-Fu_Salute", "Kung-Fu Salute", "0"},
	{"Emote_Laugh", 		"Laugh", "0"},
	{"Emote_Luchador", 		"Luchador", "0"},
	{"Emote_Make_It_Rain", 	"Make It Rain", "0"},
	{"Emote_NotToday", 		"Not Today", "0"},
	{"Emote_Salt",			 "Salt", "0"},
	{"Emote_RockPaperScissor_Rock", "Rock", "0"},
	{"Emote_RockPaperScissor_Paper", "Paper", "0"},
	{"Emote_RockPaperScissor_Scissor", "Scissor", "0"},
	{"Emote_Salute", 		"Salute", "0"},
	{"Emote_Snap", 			"Snap", "0"},
	{"Emote_StageBow", 		"Stage Bow", "0"},
	{"Emote_Wave2", 		"Wave", "0"},
	{"Emote_Yeet",			"Yeet", "0"},
	
	{"Emote_Mask_Off_Loop", "Mask Off", "1"},
	{"Emote_Dab", 		"Dab", "0"},
	{"Emote_FlippnSexy", "FlippnSexy", "0"},
	{"Emote_guitar", "Guitar", "0"},
	{"Emote_T-Rex", "T-Rex", "0"},	
	{"Emote_Youre_Awesome", "Youre Awesome", "0"},
	
	
	{"DanceMoves", 			"Dance Moves", "1"},
	{"Emote_SmoothDrive", 	"Smooth Drive", "1"},
	{"Emote_Celebration_Loop", "Celebration", "1"},
	
	{"Emote_Zippy_Dance", "Zippy Dance", "1"},
	
	{"ElectroShuffle", "Electro Shuffle", "1"},
	{"Emote_AerobicChamp", "Aerobic Champ", "1"},
	{"Emote_Bendy", "Bendy", "1"},
	{"Emote_BandOfTheFort", "Band Of The Fort", "1"},
	{"Emote_Boogie_Down", "Boogie Down", "1"},	
	{"Emote_Capoeira", "Capoeira", "1"},
	{"Emote_Charleston", "Charleston", "1"},
	{"Emote_Chicken", "Chicken", "1"},
	{"Emote_Dance_NoBones", "No Bones", "1"},	
	{"Emote_Dance_Shoot", "Shoot", "1"},
	{"Emote_Dance_SwipeIt", "Swipe It", "1"},
	{"Emote_Dance_Disco_T3", "Disco T3", "1"},
	{"Emote_DG_Disco", "DG Disco", "1"},	
	{"Emote_Dance_Worm", "Worm", "1"},
	{"Emote_Dance_Loser", "Loser", "1"},
	{"Emote_Dance_Breakdance", "Breakdance", "1"},
	{"Emote_Dance_Pump", "Pump", "1"},	
	{"Emote_Dance_RideThePony", "Ride The Pony", "1"},
	{"Emote_EasternBloc", "Eastern Bloc", "1"},
	{"Emote_FancyFeet", "Fancy Feet", "1"},	
	{"Emote_FlossDance", "Floss Dance", "1"},
	{"Emote_Fresh", "Fresh", "1"},
	{"Emote_GrooveJam", "Groove Jam", "1"},	
	{"Emote_Hiphop_01", "Hiphop_01", "1"},
	{"Emote_Hula", "Hula", "1"},	
	{"Emote_KoreanEagle", "Korean Eagle", "1"},	
	{"Emote_Kpop_02", "Kpop", "1"},
	{"Emote_LivingLarge", "Living Large", "1"},
	{"Emote_Maracas", "Maracas", "1"},
	{"Emote_PopLock", "Pop Lock", "1"},
	{"Emote_PopRock", "Pop Rock", "1"},
	{"Emote_RobotDance", "Robot Dance", "1"},
	{"Emote_TechnoZombie", "Techno Zombie", "1"},
	{"Emote_Twist", "Twist", "1"},
	{"Emote_WarehouseDance_Loop", "Warehouse", "1"},
	{"Emote_Wiggle", "Wiggle", "1"},
	{"Emote_Hillbilly_Shuffle", "Hillbilly Shuffle", "1"},
	{"Emote_IrishJig", "Irish Jig", "1"},
};

public void OnPluginStart() {
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
	
	for (int i = 1; i <= MaxClients; i++)
		if( IsValidClient(i) )
			OnClientPostAdminCheck(i);
}
public MRESReturn DHooks_OnTeleport(int client, Handle hParams) {
 	
	if( EntRefToEntIndex(g_iEmoteEnt[client]) > 0 ) {
		stopEmote(client);
	}
 
 	return MRES_Ignored;
 }
 
public void OnClientPostAdminCheck(int client) {
	DHookEntity(g_hTeleport, false, client);
	rp_HookEvent(client, RP_OnPlayerCommand, fwdCommand);
}

public Action fwdCommand(int client, char[] command, char[] arg) {
	if( StrEqual(command, "emote") || StrEqual(command, "émote") || StrEqual(command, "emotes") || StrEqual(command, "émotes") ) {
		if( !canAccess(client) ) {
			return Plugin_Handled;
		}
		
		MainEmote(client, 0);
		return Plugin_Handled;
	}
	if( StrEqual(command, "dance") || StrEqual(command, "dances") || StrEqual(command, "danse") || StrEqual(command, "danses") ) {
		if( !canAccess(client) ) {
			return Plugin_Handled;
		}
		
		MainEmote(client, 1);
		return Plugin_Handled;
	}
	return Plugin_Continue;
}
bool isMoving(int buttons) {
	if( buttons & (IN_FORWARD | IN_BACK | IN_LEFT | IN_RIGHT | IN_DUCK | IN_SPEED | IN_JUMP | IN_MOVELEFT | IN_MOVERIGHT) )
		return true;
	return false;
}
bool canAccess(int client) {
	
	if( rp_GetClientInt(client, i_Donateur) >= 1 && rp_GetClientInt(client, i_Donateur) <= 10 )
		return true;
	
	if( GetUserFlagBits(client) & ADMFLAG_KICK )
		return true;
	
	return false;
}
void MainEmote(int client, int type, int id=0) {
	char tmp[64];
	Menu menu = CreateMenu(Handler_MainEmote);
	menu.SetTitle(type == 0 ? "Emotes: \n " : "Dances: \n ");
	
	for (int i = 0; i < sizeof(g_szEmote); i++ ) {
		if( StringToInt(g_szEmote[i][2]) == type ) {
			Format(tmp, sizeof(tmp), "%d@%s", type, g_szEmote[i][0]);
			menu.AddItem(tmp, g_szEmote[i][1]);
		}
	}
	menu.DisplayAt(client, id, MENU_TIME_FOREVER);
}
public int Handler_MainEmote(Handle hItem, MenuAction oAction, int client, int param) {
	if (oAction == MenuAction_Select) {
		char options[64], tmp[2][64];
		GetMenuItem(hItem, param, options, sizeof(options));
		ExplodeString(options, "@", tmp, sizeof(tmp), sizeof(tmp[]));
		
		MainEmote(client, StringToInt(tmp[0]), 6* (param/6) );
		
		if( g_iEmoteEnt[client] == 0 && rp_IsBuildingAllowed(client) && !isMoving(GetClientButtons(client)) ) {
			startEmote(client, tmp[1]);
		}
	}
	else if (oAction == MenuAction_End ) {
		CloseHandle(hItem);
	}
}

public void OnMapStart() {
	PrecacheModel("models/player/custom_player/kodua/fortnite_emotes_v2.mdl");
}
public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float ang[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2]) {

	if( isMoving(buttons) ) {
		if( EntRefToEntIndex(g_iEmoteEnt[client]) > 0 ) {
			stopEmote(client);
		}
	}
}

bool startEmote(int client, const char[] anim) {
	
	float vec[3], ang[3];
	Entity_GetAbsOrigin(client, vec);
	Entity_GetAbsAngles(client, ang);
	
	int ent = CreateEntityByName("prop_dynamic");
	DispatchKeyValue(ent, "classname", "rp_emote");
	DispatchKeyValue(ent, "model", "models/player/custom_player/kodua/fortnite_emotes_v2.mdl");
	DispatchKeyValue(ent, "solid", "0");
	DispatchKeyValue(ent, "rendermode", "10");
	
	ActivateEntity(ent);
	DispatchSpawn(ent);
	
	TeleportEntity(ent, vec, ang, NULL_VECTOR);
	
	SetVariantString("!activator");
	AcceptEntityInput(client, "SetParent", ent);
	
	int iFlags = GetEntProp(client, Prop_Send, "m_fEffects") & (~EF_NODRAW);
	SetEntProp(client, Prop_Send, "m_fEffects", iFlags | EF_BONEMERGE | EF_NOSHADOW | EF_NOINTERP | EF_BONEMERGE_FASTCULL | EF_PARENT_ANIMATES );
	SetEntProp(client, Prop_Send, "m_CollisionGroup", COLLISION_GROUP_NONE);

	SetVariantString(anim);
	AcceptEntityInput(ent, "SetAnimation");
	HookSingleEntityOutput(ent, "OnAnimationDone", EndAnimation, true);
	
	
	g_iEmoteEnt[client] = EntIndexToEntRef(ent);
	g_iEmoteClient[ent] = GetClientUserId(client);
	
	SetEntityMoveType(client, MOVETYPE_NONE);
	ClientCommand(client, "thirdperson");
	
	FakeClientCommand(client, "use weapon_fists");
	CreateTimer(0.0, Frame_Animation, GetClientUserId(client));
}
public Action Frame_Animation(Handle timer, any userid) {
	char classname[64];
	
	int client = GetClientOfUserId(userid);
	int ent = EntRefToEntIndex(g_iEmoteEnt[client]);
	
	if( client > 0 && ent > 0) {
		int wep = Client_GetActiveWeapon(client);
		if( wep > 0 ) {
			GetEdictClassname(wep, classname, sizeof(classname));
			
			if( StrContains(classname, "weapon_fists") != 0 )
				FakeClientCommand(client, "use weapon_fists");
		}
		
		CreateTimer(0.1, Frame_Animation, GetClientUserId(client));
	}	
}
public void EndAnimation(const char[] output, int caller, int activator, float delay)  {
	int client = GetClientOfUserId(g_iEmoteClient[caller]);
	
	if( client > 0 )
		stopEmote(client);
}


void stopEmote(int client) {
	
	int caller = EntRefToEntIndex(g_iEmoteEnt[client]);
	int EntEffects = GetEntProp(client, Prop_Send, "m_fEffects") & (~EF_NODRAW) & (~EF_BONEMERGE) & (~EF_NOSHADOW) & (~EF_NOINTERP) & (~EF_BONEMERGE_FASTCULL) & (~EF_PARENT_ANIMATES);
	SetEntProp(client, Prop_Send, "m_fEffects", EntEffects);
	AcceptEntityInput(client, "ClearParent", caller);
		
	SetEntityMoveType(client, MOVETYPE_WALK);
	if( rp_GetClientInt(client, i_ThirdPerson) == 0 ) {
		ClientCommand(client, "firstperson");
	}
	
	AcceptEntityInput(caller, "Kill");
	
	g_iEmoteEnt[client] = 0;
	g_iEmoteClient[caller] = 0;
}