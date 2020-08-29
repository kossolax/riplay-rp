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

char g_szEmote[][][] = {
	{"Emote_Fonzie_Pistol", "", "0"},
	{"Emote_Bring_It_On", "", "0"},
	{"Emote_ThumbsDown", "", "0"},
	{"Emote_ThumbsUp", "", "0"},
//	{"Emote_Celebration_Loop", "", "1"},
	{"Emote_BlowKiss", "", "0"},
	{"Emote_Calculated", "", "0"},
	{"Emote_Confused", "", "0"},
//	{"Emote_Chug", "", "1"},
	{"Emote_Cry", "", "0"},
	{"Emote_DustingOffHands", "", "0"},
	{"Emote_DustOffShoulders", "", "0"},
	{"Emote_Facepalm", "", "0"},
	{"Emote_Fishing", "", "0"},
	{"Emote_Flex", "", "0"},
//	{"Emote_golfclap", "", "1"},
	{"Emote_HandSignals", "", "0"},
	{"Emote_HeelClick", "", "0"},
	{"Emote_Hotstuff", "", "0"},
	{"Emote_IBreakYou", "", "0"},
	{"Emote_IHeartYou", "", "0"},
	{"Emote_Kung-Fu_Salute", "", "0"},
	{"Emote_Laugh", "", "0"},
	{"Emote_Luchador", "", "0"},
	{"Emote_Make_It_Rain", "", "0"},
	{"Emote_NotToday", "", "0"},
	{"Emote_RockPaperScissor_Paper", "", "0"},
	{"Emote_RockPaperScissor_Rock", "", "0"},
	{"Emote_RockPaperScissor_Scissor", "", "0"},
	{"Emote_Salt", "", "0"},
	{"Emote_Salute", "", "0"},
//	{"Emote_SmoothDrive", "", "1"},
	{"Emote_Snap", "", "0"},
	{"Emote_StageBow", "", "0"},
	{"Emote_Wave2", "", "0"},
	{"Emote_Yeet", "", "0"}
};

public void OnPluginStart() {
	RegAdminCmd("sm_emote",	Cmd_Hdv, ADMFLAG_ROOT);
}
public Action Cmd_Hdv(int client, int args) {
	
	Menu menu = CreateMenu(Handler_MainEmote);
	menu.SetTitle("Emote\n ");
	
	for (int i = 0; i < sizeof(g_szEmote); i++ ) {
		menu.AddItem(g_szEmote[i][0], g_szEmote[i][0]);
	}
	menu.Display(client, MENU_TIME_FOREVER);
}
public int Handler_MainEmote(Handle hItem, MenuAction oAction, int client, int param) {
	if (oAction == MenuAction_Select) {
		char options[64];
		GetMenuItem(hItem, param, options, sizeof(options));
		
		if( g_iEmoteEnt[client] == 0 )
			startEmote(client, options);
	}
	else if (oAction == MenuAction_End ) {
		CloseHandle(hItem);
	}
}

public void OnMapStart() {
	PrecacheModel("models/player/custom_player/kodua/fortnite_emotes_v2.mdl");
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
	
	if( client > 0 ) {
		int EntEffects = GetEntProp(client, Prop_Send, "m_fEffects") & (~EF_NODRAW) & (~EF_BONEMERGE) & (~EF_NOSHADOW) & (~EF_NOINTERP) & (~EF_BONEMERGE_FASTCULL) & (~EF_PARENT_ANIMATES);
		SetEntProp(client, Prop_Send, "m_fEffects", EntEffects);
		AcceptEntityInput(client, "ClearParent", caller);
		
		SetEntityMoveType(client, MOVETYPE_WALK);
		if( rp_GetClientInt(client, i_ThirdPerson) == 0 ) {
			ClientCommand(client, "firstperson");
		}
		
		
	}
	
	AcceptEntityInput(caller, "Kill");
	
	g_iEmoteEnt[client] = 0;
	g_iEmoteClient[caller] = 0;
	
	
}