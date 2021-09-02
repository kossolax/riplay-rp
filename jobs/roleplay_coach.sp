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
#include <cstrike>
#include <colors_csgo>	// https://forums.alliedmods.net/showthread.php?p=2205447#post2205447
#include <smlib>		// https://github.com/bcserv/smlib
#include <emitsoundany> // https://forums.alliedmods.net/showthread.php?t=237045

#pragma newdecls required
#include <roleplay.inc>	// https://www.ts-x.eu

public Plugin myinfo = {
	name = "Jobs: Coach", author = "KoSSoLaX",
	description = "RolePlay - Jobs: Coach",
	version = __LAST_REV__, url = "https://www.ts-x.eu"
};

char g_szSkinsList[][][] = {
	{"models/player/custom_player/riplay/momiji/momiji.mdl", 			"(Donateur) Momijo", 	"2", "0", "1"},
	{"models/player/custom_player/riplay/nathandrake/nathandrake.mdl", 	"(Donateur) Nathan",	"2", "0", "2"},
	{"models/player/custom_player/riplay/wick/wick.mdl", 				"(Donateur) Wick",		"2", "0", "3"},
	{"models/player/custom_player/legacy/aiden_pearce/aiden_pearce.mdl","(Donateur) Aiden",		"2", "0", "4"},
	
	{"models/player/custom_player/legacy/tm_professional_varg.mdl", 	"Punky's", 			"1", "3", "0"},
	{"models/player/custom_player/legacy/tm_professional_varj.mdl", 	"Natacha", 			"1", "3", "0"},
	
	{"models/player/custom_player/legacy/tm_professional_varh.mdl", 	"Franck", 			"0", "3", "0"},
	
	{"models/player/custom_player/legacy/tm_balkan_variantg.mdl", 		"Matt - A", 		"0", "3", "0"},
	{"models/player/custom_player/legacy/tm_balkan_variantk.mdl", 		"Matt - B", 		"0", "3", "0"},
	
	{"models/player/custom_player/legacy/tm_balkan_varianth.mdl", 		"Robotnik", 		"0", "3", "0"},
	{"models/player/custom_player/legacy/tm_balkan_varianti.mdl", 		"Yvan", 			"0", "3", "0"},
	{"models/player/custom_player/legacy/tm_balkan_variantj.mdl", 		"Ronon", 			"0", "3", "0"},
	{"models/player/custom_player/legacy/tm_balkan_variantl.mdl", 		"Anatoli", 			"0", "3", "0"},
	
	{"models/player/custom_player/legacy/tm_leet_variantf.mdl", 		"Red Scarf", 		"0", "3", "0"},
	
	{"models/player/custom_player/legacy/lara/lara.mdl", 				"Lara", 			"1", "6", "0"},
	//{"models/player/custom_player/legacy/eva/eva.mdl", 				"Eva", 				"1", "5", "0"},
	{"models/player/custom_player/legacy/misty/misty.mdl", 				"Misty", 			"1", "5", "0"},
	{"models/player/custom_player/legacy/swagirl/swagirl.mdl", 			"Désirée",			"1", "4", "0"},
	{"models/player/custom_player/legacy/zoey/zoey.mdl", 				"Zoey", 			"1", "3", "0"},
	
	
	{"models/player/custom_player/legacy/don_vito/don_vito.mdl", 		"Don Vito", 		"0", "7", "0"},
	{"models/player/custom_player/legacy/redfield/redfield.mdl",		"Redfield",			"0", "6", "0"},
	//{"models/player/custom_player/legacy/hitman/hitman.mdl", 			"Hitman", 			"0", "6", "0"},
	{"models/player/custom_player/legacy/50cent/50cent.mdl", 			"50cent", 			"0", "6", "0"},
	//{"models/player/custom_player/legacy/wuzimu/wuzimu.mdl", 			"Pong", 			"0", "5", "0"},
	//{"models/player/custom_player/legacy/lloyd/lloyd.mdl", 			"Loyd", 			"0", "5", "0"},
	{"models/player/custom_player/legacy/bzsoap/bzsoap.mdl", 			"BZ-Soap", 			"0", "5", "0"},
	//{"models/player/custom_player/legacy/leon/leon.mdl", 				"Leon", 			"0", "5", "0"},

	{"models/player/custom_player/legacy/nick/nick.mdl", 				"Nick", 			"0", "5", "0"},
	//{"models/player/custom_player/legacy/vmaff/vmaff.mdl", 			"Marco", 			"0", "4", "0"},
	//{"models/player/custom_player/legacy/duke2/duke2.mdl", 			"Duke Nukem", 		"0", "3", "0"},
	
/*
	{"models/player/custom_player/legacy/tm_anarchist.mdl", 			"Anarchist", 		"0", "1", "0"},
	{"models/player/custom_player/legacy/tm_anarchist_varianta.mdl", 	"Anarchist - A", 	"0", "1", "0"},
	{"models/player/custom_player/legacy/tm_anarchist_variantb.mdl", 	"Anarchist - B", 	"0", "1", "0"},
	{"models/player/custom_player/legacy/tm_anarchist_variantc.mdl", 	"Anarchist - C", 	"0", "1", "0"},
	{"models/player/custom_player/legacy/tm_anarchist_variantd.mdl", 	"Anarchist - D", 	"0", "1", "0"},
*/
	{"models/player/custom_player/legacy/tm_balkan_varianta.mdl", 		"Balkan", 			"0", "1", "0"},
	{"models/player/custom_player/legacy/tm_balkan_variantb.mdl", 		"Balkan - A", 		"0", "1", "0"},
	{"models/player/custom_player/legacy/tm_balkan_variantc.mdl", 		"Balkan - B", 		"0", "1", "0"},
	{"models/player/custom_player/legacy/tm_balkan_variantd.mdl", 		"Balkan - C", 		"0", "1", "0"},
	{"models/player/custom_player/legacy/tm_balkan_variante.mdl", 		"Balkan - D", 		"0", "1", "0"},
	{"models/player/custom_player/legacy/tm_balkan_variantf.mdl", 		"Balkan - E", 		"0", "1", "0"},
	
	{"models/player/custom_player/legacy/tm_leet_varianta.mdl", 		"Leet", 			"0", "1", "0"},
	{"models/player/custom_player/legacy/tm_leet_variantb.mdl", 		"Leet - A", 		"0", "1", "0"},
	{"models/player/custom_player/legacy/tm_leet_variantc.mdl", 		"Leet - B1", 		"0", "1", "0"},
	{"models/player/custom_player/legacy/tm_leet_varianti.mdl", 		"Leet - B2", 		"0", "1", "0"},
	{"models/player/custom_player/legacy/tm_leet_variantd.mdl", 		"Leet - C1", 		"0", "1", "0"},
	{"models/player/custom_player/legacy/tm_leet_variante.mdl", 		"Leet - C2", 		"0", "1", "0"},
	{"models/player/custom_player/legacy/tm_leet_variantg.mdl", 		"Leet - D", 		"0", "1", "0"},
	{"models/player/custom_player/legacy/tm_leet_varianth.mdl", 		"Leet - E", 		"0", "1", "0"},
	
	{"models/player/custom_player/legacy/tm_phoenix.mdl",				"Phoenix", 			"0", "1", "0"},
	{"models/player/custom_player/legacy/tm_phoenix_varianta.mdl", 		"Phoenix - A", 		"0", "1", "0"},
	{"models/player/custom_player/legacy/tm_phoenix_variantb.mdl", 		"Phoenix - B", 		"0", "1", "0"},
	{"models/player/custom_player/legacy/tm_phoenix_variantc.mdl", 		"Phoenix - C", 		"0", "1", "0"},
	{"models/player/custom_player/legacy/tm_phoenix_variantd.mdl", 		"Phoenix - D", 		"0", "1", "0"},
/*
	{"models/player/custom_player/legacy/tm_pirate.mdl", 				"Pirate", 			"0", "1", "0"},
	{"models/player/custom_player/legacy/tm_pirate_varianta.mdl", 		"Pirate - A", 		"0", "1", "0"},
	{"models/player/custom_player/legacy/tm_pirate_variantb.mdl", 		"Pirate - B", 		"0", "1", "0"},
	{"models/player/custom_player/legacy/tm_pirate_variantc.mdl", 		"Pirate - C", 		"0", "1", "0"},
	{"models/player/custom_player/legacy/tm_pirate_variantd.mdl", 		"Pirate - D", 		"0", "1", "0"},
*/
	{"models/player/custom_player/legacy/tm_professional.mdl", 			"Professional", 	"0", "1", "0"},
	{"models/player/custom_player/legacy/tm_professional_var1.mdl", 	"Professional - A", "0", "1", "0"},
	{"models/player/custom_player/legacy/tm_professional_var2.mdl", 	"Professional - B", "0", "1", "0"},
	{"models/player/custom_player/legacy/tm_professional_var3.mdl", 	"Professional - C", "0", "1", "0"},
	{"models/player/custom_player/legacy/tm_professional_var4.mdl", 	"Professional - D", "0", "1", "0"},
	
	{"models/player/custom_player/legacy/tm_separatist.mdl", 			"Séparatist", 		"0", "1", "0"},
	{"models/player/custom_player/legacy/tm_separatist_varianta.mdl", 	"Séparatist - A", 	"0", "1", "0"},
	{"models/player/custom_player/legacy/tm_separatist_variantb.mdl", 	"Séparatist - B", 	"0", "1", "0"},
	{"models/player/custom_player/legacy/tm_separatist_variantc.mdl", 	"Séparatist - C", 	"0", "1", "0"},
	{"models/player/custom_player/legacy/tm_separatist_variantd.mdl", 	"Séparatist - D", 	"0", "1", "0"}
};
char g_szColor[][] = {
	"128 0 0",
	"255 0 0",
	"255 128 0",
	"255 255 0",
	"128 255 0",
	
	"0 255 0",
	"0 128 0",
	"0 255 128",
	"0 255 255",
	"0 128 255",
	
	"0 0 255",
	"0 0 128",
	"128 0 255",
	"255 0 255",
	"255 0 128",
	
	"255 255 255",
	"128 128 128"
};
int g_cBeam, g_cGlow, g_cExplode;
Handle g_hCigarette[65];

// ----------------------------------------------------------------------------
public Action Cmd_Reload(int args) {
	char name[64];
	GetPluginFilename(INVALID_HANDLE, name, sizeof(name));
	ServerCommand("sm plugins reload %s", name);
	return Plugin_Continue;
}
public void OnPluginStart() {
	LoadTranslations("core.phrases");
	LoadTranslations("common.phrases");
	LoadTranslations("roleplay.phrases");
	LoadTranslations("roleplay.items.phrases");
	LoadTranslations("roleplay.coach.phrases");
	
	RegServerCmd("rp_quest_reload", Cmd_Reload);
	RegServerCmd("rp_item_cut",			Cmd_ItemCut,			"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_lancercut",	Cmd_ItemCutThrow,		"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_cutnone",		Cmd_ItemCutRemove,		"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_esquive",		Cmd_ItemCut_Esquive,	"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_knifetype",	Cmd_ItemKnifeType,		"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_permi_tir",	Cmd_ItemPermiTir,		"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_shoes", 		Cmd_ItemShoes, 			"RP-ITEM", 	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_packequipement", Cmd_ItemPackEquipement, "RP-ITEM", FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_needforspeed",Cmd_ItemNeedForSpeed,	"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_lessive",		Cmd_ItemLessive,		"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_cafe",		Cmd_ItemCafe,			"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_crayons",		Cmd_ItemCrayons,		"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_mask", 		CmdItemMask, 			"RP-ITEM", FCVAR_UNREGISTERED);
	RegServerCmd("rp_giveskin", 		Cmd_ItemGiveSkin, 		"RP-ITEM", FCVAR_UNREGISTERED);	
	RegServerCmd("rp_item_preserv",		Cmd_ItemPreserv,		"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_poupee",		Cmd_ItemPoupee,			"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_menottes",	Cmd_ItemMenottes,		"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_sucette",		Cmd_ItemSucette,		"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_sucetteduo",	Cmd_ItemSucette2,		"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_fouet",		Cmd_ItemFouet,			"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_alcool",		Cmd_ItemAlcool,			"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_lube",		Cmd_ItemLube,			"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_kevlarbox",	Cmd_ItemKevlarBox,		"RP-ITEM", 	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_cig", 		Cmd_ItemCigarette,		"RP-ITEM",	FCVAR_UNREGISTERED);	
	RegServerCmd("rp_item_ruban",		Cmd_ItemRuban,			"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_disco",		Cmd_ItemDisco,			"RP-ITEM",	FCVAR_UNREGISTERED);
	
	for (int i = 1; i <= MaxClients; i++) 
		if( IsValidClient(i) )
			OnClientPostAdminCheck(i); 
	
	
	char classname[64];
	for (int i = MaxClients; i <= 2048; i++) {
		if( !IsValidEdict(i) )
			continue;
		if( !IsValidEntity(i) )
			continue;
		
		GetEdictClassname(i, classname, sizeof(classname));
		if( StrEqual(classname, "rp_kevlarbox") ) {
			
			rp_SetBuildingData(i, BD_started, GetTime());
			rp_SetBuildingData(i, BD_owner, GetEntPropEnt(i, Prop_Send, "m_hOwnerEntity") );
			
			CreateTimer(Math_GetRandomFloat(0.0, 1.0), BuildingKevlarBox_post, i);
		}
	}

}
public void OnMapStart() {
	g_cBeam = PrecacheModel("materials/sprites/laserbeam.vmt", true);
	g_cGlow = PrecacheModel("materials/sprites/glow01.vmt", true);
	g_cExplode = PrecacheModel("materials/sprites/muzzleflash4.vmt", true);
	PrecacheModel(MODEL_KEVLARBOX, true);
	PrecacheSoundAny("tsx/roleplay/fouet.mp3");

	PrecacheModel(MODEL_KNIFE, true);
}
public void OnClientPostAdminCheck(int client) {
	rp_HookEvent(client, RP_PostTakeDamageKnife, fwdWeapon);
	rp_HookEvent(client, RP_OnPlayerBuild, fwdOnPlayerBuild);
	rp_HookEvent(client, RP_OnPlayerUse, fwdUse);
	rp_HookEvent(client, RP_OnPlayerCommand, fwdCommand);
	
	if( rp_GetClientBool(client, b_Crayon) )
		rp_HookEvent(client, RP_PrePlayerTalk, fwdTalkCrayon);
	if( rp_GetClientBool(client, b_HasShoes) ) {
		SDKHook(client, SDKHook_OnTakeDamage, fwdNoFallDamage);
		rp_HookEvent(client, RP_OnAssurance,	fwdAssuranceShoes);
		rp_HookEvent(client, RP_OnFrameSeconde, fwdVitalite);
	}
}
public Action fwdCommand(int client, char[] command, char[] arg) {
	if( StrEqual(command, "cutinfo") || StrEqual(command, "infocut") ) {
		return Cmd_CutInfo(client);
	}
	return Plugin_Continue;
}
public Action Cmd_CutInfo(int client) {
	int target = -1;
	if( rp_GetClientJobID(client) == 71 ) {
		target = rp_GetClientTarget(client);
	}
	if( !IsValidClient(target) )
		target = client;

	if( !IsPlayerAlive(target) )
		return Plugin_Handled;
	
	char target_name[128];
	GetClientName2(target, target_name, sizeof(target_name), false);
	
	if( client == target ) {
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Info_TrainSelf", client,
			rp_GetClientInt(target, i_KnifeTrain), rp_GetClientInt(target, i_Esquive), RoundToFloor(rp_GetClientFloat(target, fl_WeaponTrain)/8.0*100.0));
	}
	else {
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Info_TrainTarget", client, target_name,
			rp_GetClientInt(target, i_KnifeTrain), rp_GetClientInt(target, i_Esquive), RoundToFloor(rp_GetClientFloat(target, fl_WeaponTrain)/8.0*100.0));
	}
	return Plugin_Handled;
}
// ----------------------------------------------------------------------------
public Action Cmd_ItemPackEquipement(int args){

	int client = GetCmdArgInt(1);

	rp_SetClientInt(client, i_KnifeTrain, 100);
	rp_SetClientInt(client, i_Esquive, 100);
	rp_SetClientFloat(client, fl_WeaponTrain, 5.0);

	FakeClientCommand(client, "say /item");

	return Plugin_Handled;
}
// ----------------------------------------------------------------------------
public Action Cmd_ItemCut(int args) {

	int amount = GetCmdArgInt(1);
	int client = GetCmdArgInt(2);
	int item_id = GetCmdArgInt(args);
	int item_id_1, item_id_10;
	
	switch(amount){
		case 1: {
			item_id_10= item_id+1;
			item_id_1= item_id;
		}
		case 10: {
			item_id_10= item_id;
			item_id_1= item_id-1;
		}
		case 100: {
			item_id_10= item_id-1;
			item_id_1= item_id-2;
		}
		default: {
			return Plugin_Handled;
		}
	}

	rp_SetClientInt(client, i_KnifeTrain, rp_GetClientInt(client, i_KnifeTrain) + amount);

	if( rp_GetClientInt(client, i_KnifeTrain) > 100 ) {	

		int add = rp_GetClientInt(client, i_KnifeTrain) - 100;

		int add10 = RoundToFloor(float(add) / 10.0);
		int add1 = add % 10;

		if(add10 > 0)
			rp_ClientGiveItem(client, item_id_10 , add10);

		rp_ClientGiveItem(client, item_id_1 , add1);
		
		rp_IncrementSuccess(client, success_list_coach, amount-add);
		rp_SetClientInt(client, i_KnifeTrain, 100);
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Train_Knife", client, rp_GetClientInt(client, i_KnifeTrain));
		return Plugin_Handled;
	}

	rp_IncrementSuccess(client, success_list_coach, amount);
	CPrintToChat(client, "" ...MOD_TAG... " %T", "Train_Knife", client, rp_GetClientInt(client, i_KnifeTrain));
	return Plugin_Handled;
}
// ----------------------------------------------------------------------------
public Action Cmd_ItemCut_Esquive(int args) {
	
	int amount = GetCmdArgInt(1);
	int client = GetCmdArgInt(2);
	int item_id = GetCmdArgInt(args);
	
	rp_SetClientInt(client, i_Esquive, rp_GetClientInt(client, i_Esquive) + amount);
	
	if( rp_GetClientInt(client, i_Esquive) > 100 ) {
		int add = rp_GetClientInt(client, i_Esquive) - 100;
		if( amount == 1 ) 
			rp_ClientGiveItem(client, item_id, add);
		else
			rp_ClientGiveItem(client, item_id - 1, add);
			
		rp_SetClientInt(client, i_Esquive, 100);
		
		CPrintToChat(client, ""...MOD_TAG..." %T", "Train_Max", client);
		return Plugin_Handled;
	}
	
	CPrintToChat(client, "" ...MOD_TAG... " %T", "Train_Esquive", client, rp_GetClientInt(client, i_Esquive));
	return Plugin_Handled;
}
public Action Cmd_ItemPermiTir(int args) {

	int client = GetCmdArgInt(1);
	int item_id = GetCmdArgInt(args);
	
	float train = rp_GetClientFloat(client, fl_WeaponTrain);
	if( train >= 8.0 ) {
		CPrintToChat(client, ""...MOD_TAG..." %T", "Train_Max", client);
		ITEM_CANCEL(client, item_id);
		return Plugin_Handled;
	}
	
	train += 4.0;
	rp_SetClientFloat(client, fl_WeaponTrain, train < 8.0 ? train : 8.0);
	
	
	CPrintToChat(client, "" ...MOD_TAG... " %T", "Train_Weapon", client, RoundFloat(rp_GetClientFloat(client, fl_WeaponTrain)/8.0*100.0));
	return Plugin_Handled;
}
public Action Cmd_ItemCutRemove(int args) {

	int client = GetCmdArgInt(1);
	rp_SetClientInt(client, i_KnifeTrain, 5);
	CPrintToChat(client, "" ...MOD_TAG... " %T", "Train_Knife", client, rp_GetClientInt(client, i_KnifeTrain));
}

public Action Cmd_ItemCutThrow(int args) {	
	
	
	int client = GetCmdArgInt(1);
	rp_SetClientInt(client, i_LastDangerousShot, GetTime());
	
	rp_SetClientInt(client, i_LastAgression, GetTime());
	
	float fPos[3], fAng[3], fVel[3], fPVel[3];
	GetClientEyePosition(client, fPos);
	GetClientEyeAngles(client, fAng);
	GetAngleVectors(fAng, fVel, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(fVel, 2000.0);
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", fPVel);
	AddVectors(fVel, fPVel, fVel);
	
	
	int entity = CreateEntityByName("hegrenade_projectile");
	DispatchSpawn(entity);
	RequestFrame(CB_Nade, EntIndexToEntRef(entity));
	
	SetEntityModel(entity, MODEL_KNIFE);
	SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
	SetEntPropFloat(entity, Prop_Send, "m_flElasticity", 0.2);
	rp_SetBuildingData(entity, BD_item_id, GetCmdArgInt(args));
	
	TeleportEntity(entity, fPos, fAng, fVel);
	
	TE_SetupBeamFollow(entity, g_cBeam, 0, 0.7, 7.7, 7.7, 3, {177, 177, 177, 117});
	TE_SendToAll();
	
	SDKHook(entity, SDKHook_Touch, Cmd_ItemCutThrow_TOUCH);
	
}
public void CB_Nade(any ref) {
	int entity = EntRefToEntIndex(ref);
	if( IsValidEdict(entity) && IsValidEntity(entity) ) {
		Entity_SetSolidType(entity, SOLID_VPHYSICS);
		Entity_SetSolidFlags(entity, FSOLID_TRIGGER );
		Entity_SetCollisionGroup(entity, COLLISION_GROUP_PLAYER);
	}
}
public void Cmd_ItemCutThrow_TOUCH(int rocket, int entity) {
	
	char classname[64];
	int attacker = GetEntPropEnt(rocket, Prop_Send, "m_hOwnerEntity");
	bool touched = false;
	
	if( entity > 0 && IsValidEdict(entity) && IsValidEntity(entity) && entity != attacker ) {
		
		GetEdictClassname(entity, classname, sizeof(classname));
		
		if( StrContains(classname, "trigger_") == 0 )
			return;
		
		if( IsValidClient(entity) && rp_IsTutorialOver(entity) ) {
			float dmg = float(rp_GetClientInt(attacker, i_KnifeTrain));
			wpnCutDamage(entity, attacker, dmg);
			rp_ClientDamage(entity, RoundFloat(dmg), attacker, "weapon_knife_throw");
			touched = true;
		}
	}
	
	int knife = rp_GetBuildingData(rocket, BD_item_id);
	if( !touched && knife > 0 ) {
		rp_ClientGiveItem(attacker, knife);
		CPrintToChat(attacker, ""...MOD_TAG..." %T", "Coach_KnifeGet", attacker);
	}
	
	SDKUnhook(rocket, SDKHook_Touch, Cmd_ItemCutThrow_TOUCH);	// Prevent TWICE touch.
	rp_AcceptEntityInput(rocket, "Kill");
}

// ----------------------------------------------------------------------------
public Action Cmd_ItemKnifeType(int args) {
	char arg1[12], classname[64];
	
	GetCmdArg(1, arg1, sizeof(arg1));
	int client = GetCmdArgInt(2);
	int item_id = GetCmdArgInt(args);
	
	int wepid = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if( !IsValidEntity(wepid) ) {
		ITEM_CANCEL(client, item_id);
		CPrintToChat(client, ""...MOD_TAG..." %T", "Error_KnifeInHands", client);
		return Plugin_Handled;
	}
	
	GetEdictClassname(wepid, classname, sizeof(classname));
	if( !StrEqual(classname, "weapon_knife") ) {
		ITEM_CANCEL(client, item_id);
		CPrintToChat(client, ""...MOD_TAG..." %T", "Error_KnifeInHands", client);
		return Plugin_Handled;
	}
	
	
	enum_ball_type ball_type_type = ball_type_none;

	if( StrEqual(arg1, "fire") ) {
		ball_type_type = ball_type_fire;
	}
	else if( StrEqual(arg1, "caoutchouc") ) {
		ball_type_type = ball_type_caoutchouc;
	}
	else if( StrEqual(arg1, "poison") ) {
		ball_type_type = ball_type_poison;
	}
	else if( StrEqual(arg1, "vampire") ) {
		ball_type_type = ball_type_vampire;
	}
	else if (StrEqual(arg1, "anti-kevlar") ){
		ball_type_type = ball_type_antikevlar;
	}
	if( rp_GetClientKnifeType(client) == ball_type_type ) {
		ITEM_CANCEL(client, item_id);
		CPrintToChat(client, "" ...MOD_TAG... " %T", "edit_knife_already", client);
		return Plugin_Handled;
	}
	
	if( !rp_SetClientKnifeType(client, ball_type_type) ) {
		ITEM_CANCEL(client, item_id);
		CPrintToChat(client, ""...MOD_TAG..." %T", "Error_KnifeInHands", client);
		return Plugin_Handled;
	}
	else {
		CPrintToChat(client, ""...MOD_TAG..." %T", "edit_knife_done", client);
	}
	
	
	return Plugin_Handled;
}
public Action fwdWeapon(int victim, int attacker, float &damage) {
	
	bool changed;
	
	if( rp_GetClientBool(attacker, b_GameModePassive) == false)
		changed = wpnCutDamage(victim, attacker, damage);
	
	if( changed )
		return Plugin_Changed;
	return Plugin_Continue;
}
bool wpnCutDamage(int victim, int attacker, float &damage) {
	bool changed = true;
	
	switch( rp_GetClientKnifeType(attacker) ) {
		case ball_type_fire: {
			rp_ClientIgnite(victim, 10.0, attacker);
			changed = false;
		}
		case ball_type_caoutchouc: {
			damage *= 0.0;
			
			if( rp_IsInPVP(victim) ) {
				rp_SetClientFloat(victim, fl_FrozenTime, GetGameTime() + 1.5);
				if( !rp_GetClientBool(victim, ch_Yeux) )
					ServerCommand("sm_effect_flash %d 1.5 180", victim);
			}
			else {
				if( !rp_ClientFloodTriggered(attacker, victim, fd_flash) ) {
					rp_ClientFloodIncrement(attacker, victim, fd_flash, 0.75);
					rp_SetClientFloat(victim, fl_FrozenTime, GetGameTime() + 1.5);
					if( !rp_GetClientBool(victim, ch_Yeux) )
						ServerCommand("sm_effect_flash %d 1.5 180", victim);
				}
			}
		}
		case ball_type_antikevlar: {
			int kevlar = rp_GetClientInt(victim, i_Kevlar);
			if (kevlar > 0){
				damage *= 0.50;
				kevlar *= 0.7;
				kevlar -= 20;
				
				kevlar = kevlar>0 ? kevlar : 0;
				rp_SetClientInt(victim, i_Kevlar, kevlar);
			}
		}
		case ball_type_poison: {
			damage *= 0.40;
			rp_ClientPoison(victim, 20.0, attacker);
		}
		case ball_type_vampire: {
			damage *= 0.75;
			int current = GetClientHealth(attacker);
			if( current < 500 ) {
				current += RoundToFloor(damage*0.2);

				if( current > 500 )
					current = 500;

				SetEntityHealth(attacker, current);
				float vecOrigin[3], vecOrigin2[3];
				GetClientEyePosition(attacker, vecOrigin);
				GetClientEyePosition(victim, vecOrigin2);
				
				vecOrigin[2] -= 20.0; vecOrigin2[2] -= 20.0;
				
				TE_SetupBeamPoints(vecOrigin, vecOrigin2, g_cBeam, 0, 0, 0, 0.1, 10.0, 10.0, 0, 10.0, {250, 50, 50, 250}, 10);
				TE_SendToAll();
			}
		}
		default: {
			rp_ClientAggroIncrement(attacker, victim, RoundFloat(damage));
			changed = false;
		}
	}
	return changed;
}
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
public Action Hook_SetTransmit(int entity, int client) {
	if( Entity_GetOwner(entity) == client && rp_GetClientInt(client, i_ThirdPerson) == 0 ) 
		return Plugin_Handled;
	return Plugin_Continue;
}
// ----------------------------------------------------------------------------
public Action Cmd_ItemShoes(int args) {
	
	int client = GetCmdArgInt(1);
	int item_id = GetCmdArgInt(args);


	if(	rp_GetClientBool(client, b_HasShoes) ){
		char tmp[128];
		rp_GetItemData(item_id, item_type_name, tmp, sizeof(tmp));
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_ItemAlreadyEnable", client, tmp);
		ITEM_CANCEL(client, item_id);
		return Plugin_Handled;
	}
	
	rp_SetClientBool(client, b_HasShoes, true);
	
	rp_HookEvent(client, RP_OnAssurance,	fwdAssuranceShoes);
	rp_HookEvent(client, RP_OnFrameSeconde, fwdVitalite);
	SDKHook(client, SDKHook_OnTakeDamage, fwdNoFallDamage);
	
	return Plugin_Handled;
}
public Action fwdAssuranceShoes(int client, int& amount) {
	if( rp_GetClientBool(client, b_HasShoes) )
		amount += 250;
}
public Action fwdVitalite(int client) {
	static float fLast[65][3];
	static count[65];
	static wear[4100];
	
	float fNow[3];
	GetClientAbsOrigin(client, fNow);	
	
	
	if( GetVectorDistance(fNow, fLast[client]) > 50.0 && !rp_GetClientBool(client, b_IsAFK) ) { // Si le joueur marche
		count[client]++;
		wear[client]++;
		if( count[client] > 60 ) {
			count[client] = 0;
		
			float vita = rp_GetClientFloat(client, fl_Vitality);
			rp_SetClientFloat(client, fl_Vitality, vita + 5.0);
			
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Coach_BasketVitality", client);
		}
		if( wear[client] > 4000 ) {
			wear[client] = 0;
			rp_SetClientBool(client, b_HasShoes, false);
				rp_UnhookEvent(client, RP_OnAssurance,	fwdAssuranceShoes);
				rp_UnhookEvent(client, RP_OnFrameSeconde, fwdVitalite);
				SDKUnhook(client, SDKHook_OnTakeDamage, fwdNoFallDamage);
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Coach_BasketWear", client);
			return Plugin_Handled;
		}
	}
	
	for (int i = 0; i < 3; i++)
		fLast[client][i] = fNow[i];
}
public Action fwdNoFallDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype) {
	
	if( damagetype & DMG_FALL && !(rp_GetZoneBit(rp_GetPlayerZone(victim)) & BITZONE_EVENT)) {
		damage = 0.0;
		return Plugin_Changed;
	}
	
	return Plugin_Continue;
}
// ----------------------------------------------------------------------------
public Action fwdOnPlayerBuild(int client, float& cooldown){
	if( rp_GetClientJobID(client) != 71 )
		return Plugin_Continue;

	int ent = BuildingKevlarBox(client);
	rp_SetBuildingData(ent, BD_FromBuild, 1);
	SetEntProp(ent, Prop_Data, "m_iHealth", GetEntProp(ent, Prop_Data, "m_iHealth")/5);
	Entity_SetMaxHealth(ent, Entity_GetHealth(ent));
	
	if( ent > 0 ) {
		rp_SetClientStat(client, i_TotalBuild, rp_GetClientStat(client, i_TotalBuild)+1);
		rp_ScheduleEntityInput(ent, 300.0, "Kill");
		cooldown = 30.0;
	}
	else {
		cooldown = 3.0;
	}

	return Plugin_Stop;
	
	int wep_id = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	char wep_name[32];
	GetEdictClassname(wep_id, wep_name, 31);
	if( StrContains(wep_name, "weapon_bayonet") != 0 && StrContains(wep_name, "weapon_knife") != 0 ) {
		CPrintToChat(client, "" ...MOD_TAG... " Vous devez prendre votre couteau en main pour le modifier.");
		return Plugin_Handled;
	}

	Handle menu = CreateMenu(ModifyWeapon);
	SetMenuTitle(menu, "Modifier le couteau");

	if(rp_GetClientKnifeType(client) == ball_type_fire)
		AddMenuItem(menu, "fire", "Changer pour un couteau incendiaire (50$)", ITEMDRAW_DISABLED);
	else
		AddMenuItem(menu, "fire", "Changer pour un couteau incendiaire (50$)");

	if(rp_GetClientKnifeType(client) == ball_type_caoutchouc)
		AddMenuItem(menu, "caoutchouc", "Changer pour un couteau en caoutchouc (50$)", ITEMDRAW_DISABLED);
	else
		AddMenuItem(menu, "caoutchouc", "Changer pour un couteau en caoutchouc (50$)");

	if(rp_GetClientKnifeType(client) == ball_type_poison)
		AddMenuItem(menu, "poison", "Changer pour un couteau empoisonné (50$)", ITEMDRAW_DISABLED);
	else
		AddMenuItem(menu, "poison", "Changer pour un couteau empoisonné (50$)");

	if(rp_GetClientKnifeType(client) == ball_type_vampire)
		AddMenuItem(menu, "vampire", "Changer pour un couteau vampirique (50$)", ITEMDRAW_DISABLED);
	else
		AddMenuItem(menu, "vampire", "Changer pour un couteau vampirique (50$)");

	if(rp_GetClientKnifeType(client) == ball_type_antikevlar)
		AddMenuItem(menu, "kevlar", "Changer pour un couteau anti kevlar (50$)", ITEMDRAW_DISABLED);
	else
		AddMenuItem(menu, "kevlar", "Changer pour un couteau anti kevlar (50$)");
			
	if(rp_GetClientFloat(client, fl_WeaponTrain) >= 8)
		AddMenuItem(menu, "precision", "Ajouter une précision de tir (50$)", ITEMDRAW_DISABLED);
	else 
		AddMenuItem(menu, "precision", "Ajouter une précision de tir (50$)");


	if(rp_GetClientInt(client, i_KnifeTrain) == 100)
		AddMenuItem(menu, "full", "Me mettre à 100 niveaux d'entrainement (0$)", ITEMDRAW_DISABLED);
	else{
		char tmp[64];
		Format(tmp, sizeof(tmp), "Me mettre à 100 niveaux d'entrainement (%i$)", (100 - rp_GetClientInt(client, i_KnifeTrain))*10 );
		AddMenuItem(menu, "full", tmp);
	}	

	if(rp_GetClientInt(client, i_Esquive) == 100)
		AddMenuItem(menu, "esquive", "Me mettre à 100 niveaux d'esquive (0$)", ITEMDRAW_DISABLED);
	else{
		char tmp[64];
		Format(tmp, sizeof(tmp), "Me mettre à 100 niveaux d'esquive (%i$)", (100 - rp_GetClientInt(client, i_Esquive))*10 );
		AddMenuItem(menu, "esquive", tmp);
	}
	DisplayMenu(menu, client, 60);
	return Plugin_Handled;
}
public int ModifyWeapon(Handle p_hItemMenu, MenuAction p_oAction, int client, int p_iParam2) {

	if (p_oAction == MenuAction_Select) {
		char szMenuItem[32];
		if (GetMenuItem(p_hItemMenu, p_iParam2, szMenuItem, sizeof(szMenuItem))){

			int wep_id = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
			char wep_name[32];
			int price = 50;
			GetEdictClassname(wep_id, wep_name, 31);

			if( StrContains(wep_name, "weapon_bayonet") != 0 && StrContains(wep_name, "weapon_knife") != 0 ) {
				CPrintToChat(client, "" ...MOD_TAG... " Vous devez prendre une arme en main pour la modifier.");
				return;
			}

			if(StrEqual(szMenuItem, "full")){
				price = (100 - rp_GetClientInt(client, i_KnifeTrain))*10;
				if((rp_GetClientInt(client, i_Bank)+rp_GetClientInt(client, i_Money)) >= price){
					rp_ClientMoney(client, i_Money, -price);
					CPrintToChat(client, "" ...MOD_TAG... " Votre entraînement au couteau est maintenant maximal.");
					rp_SetClientInt(client, i_KnifeTrain, 100);
				}
				else{
					CPrintToChat(client, "" ...MOD_TAG... " Vous n'avez pas assez d'argent.");
					return;
				}
			}			
			else if(StrEqual(szMenuItem, "esquive")){
				price = (100 - rp_GetClientInt(client, i_Esquive))*10;
				if((rp_GetClientInt(client, i_Bank)+rp_GetClientInt(client, i_Money)) >= price){
					rp_ClientMoney(client, i_Money, -price);
					CPrintToChat(client, "" ...MOD_TAG... " Votre esquive est maintenant maximale.");
					rp_SetClientInt(client, i_Esquive, 100);
				}
				else{
					CPrintToChat(client, "" ...MOD_TAG... " Vous n'avez pas assez d'argent.");
					return;
				}
			}
			else if((rp_GetClientInt(client, i_Bank)+rp_GetClientInt(client, i_Money)) >= price){
				rp_ClientMoney(client, i_Money, -price);
				CPrintToChat(client, "" ...MOD_TAG... " La modification à été appliquée à votre couteau.");
				if(StrEqual(szMenuItem, "fire")){
					rp_SetClientKnifeType(client, ball_type_fire);
				}
				else if(StrEqual(szMenuItem, "caoutchouc")){
					rp_SetClientKnifeType(client, ball_type_caoutchouc);
				}
				else if(StrEqual(szMenuItem, "poison")){
					rp_SetClientKnifeType(client, ball_type_poison);
				}
				else if(StrEqual(szMenuItem, "vampire")){
					rp_SetClientKnifeType(client, ball_type_vampire);
				}
				else if(StrEqual(szMenuItem, "kevlar")){
					rp_SetClientKnifeType(client, ball_type_antikevlar);
				}
				else if(StrEqual(szMenuItem, "precision")) {
	
					float train = rp_GetClientFloat(client, fl_WeaponTrain) + 4.0;
					rp_SetClientFloat(client, fl_WeaponTrain, train < 8.0 ? train : 8.0);
					
					CPrintToChat(client, "" ...MOD_TAG... " Votre entraînement est maintenant de %.2f%%", (train/5.0*100.0));
				}
			}
			else{
				CPrintToChat(client, "" ...MOD_TAG... " Vous n'avez pas assez d'argent.");
				return;
			}
			rp_SetClientStat(client, i_TotalBuild, rp_GetClientStat(client, i_TotalBuild)+1);
			rp_SetJobCapital( 71, rp_GetJobCapital(71)+price );
			FakeClientCommand(client, "say /build");
		}
	}
	else if (p_oAction == MenuAction_End) {
		CloseHandle(p_hItemMenu);
	}

}

public Action Cmd_ItemNeedForSpeed(int args) {
	
	int client = GetCmdArgInt(1);
	
	rp_HookEvent(client, RP_PrePlayerPhysic, fwdCigSpeed, 60.0);
	rp_HookEvent(client, RP_PrePlayerPhysic, fwdCigSpeed, 10.0);
}
public Action fwdCigSpeed(int client, float& speed, float& gravity) {
	speed += 0.15;
	
	return Plugin_Changed;
}

public Action Cmd_ItemLessive(int args) {
	
	int client = GetCmdArgInt(1);
	int item_id = GetCmdArgInt(args);
	
	if( rp_IsInPVP(client) ) {
		ITEM_CANCEL(client, item_id);
		CPrintToChat(client, ""...MOD_TAG..." %T", "Error_CannotUseItemInPvP", client);
		return Plugin_Handled;
	}
	
	if( rp_GetZoneBit(rp_GetPlayerZone(client)) & BITZONE_PERQUIZ ) {
		CPrintToChat(client, ""...MOD_TAG..." %T", "Error_CannotUseItemInPerquiz", client);
		ITEM_CANCEL(client, item_id);
		return Plugin_Handled;
	}
	
	SDKHooks_TakeDamage(client, client, client, 5000.0);
	rp_ClientDamage(client, 5000, client);
	
	rp_ClientRespawn(client);
	return Plugin_Handled;
}
public Action Cmd_ItemCafe(int args) {
	
	int client = GetCmdArgInt(1);
	
	rp_HookEvent(client, RP_PrePlayerPhysic, fwdCigSpeed, 10.0);
	rp_HookEvent(client, RP_PrePlayerPhysic, fwdCigSpeed, 10.0);
	
	rp_IncrementSuccess(client, success_list_cafeine);
}
public Action Cmd_ItemCrayons(int args) {
	
	int client = GetCmdArgInt(1);
	int item_id = GetCmdArgInt(args);
	
	bool crayon = rp_GetClientBool(client, b_Crayon);
	
	if( crayon ) {
		ITEM_CANCEL(client, item_id);
		return Plugin_Handled;
	}
	
	rp_IncrementSuccess(client, success_list_rainbow);
	rp_HookEvent(client, RP_PrePlayerTalk,	fwdTalkCrayon);	
	rp_HookEvent(client, RP_OnAssurance,	fwdAssuranceCrayon);
	
	rp_SetClientBool(client, b_Crayon, true);
	return Plugin_Handled;
}
public Action fwdAssuranceCrayon(int client, int& amount) {
	amount += 900;
}
public Action fwdTalkCrayon(int client, char[] szSayText, int length, bool local) {
	
	char tmp[64];
	int hours, minutes;
	rp_GetTime(hours, minutes);
	
	IntToString( GetClientHealth(client), tmp, sizeof(tmp));
	ReplaceString(szSayText, length, "{hp}", tmp);
	
	IntToString( rp_GetClientInt(client, i_Kevlar), tmp, sizeof(tmp));
	ReplaceString(szSayText, length, "{ap}", tmp);
	
	IntToString( hours, tmp, sizeof(tmp));
	ReplaceString(szSayText, length, "{heure}", tmp);

	if(hours != 23)
		IntToString( hours+1, tmp, sizeof(tmp));
	else
		tmp="0";

	ReplaceString(szSayText, length, "{h+1}", tmp);

	IntToString( minutes, tmp, sizeof(tmp));
	ReplaceString(szSayText, length, "{minute}", tmp);
	
	rp_GetDate(tmp, length);
	ReplaceString(szSayText, length, "{date}", tmp);
	GetClientName(client, tmp, sizeof(tmp));							ReplaceString(szSayText, length, "{me}", tmp);
	
	int target = rp_GetClientTarget(client);
	if( IsValidClient(target) ) {
		GetClientName(target, tmp, sizeof(tmp));
		ReplaceString(szSayText, length, "{target}", tmp);
	}
	else {
		Format(tmp, sizeof(tmp), "%T", "Jobs_Noone", LANG_SERVER);
		ReplaceString(szSayText, length, "{target}", tmp);
	}
	
	rp_GetZoneData(rp_GetPlayerZone( rp_IsValidDoor(target) ? target : client ), zone_type_name, tmp, sizeof(tmp));
	ReplaceString(szSayText, length, "{door}", tmp);
	
	rp_GetJobData(rp_GetClientInt(client, i_Job), job_type_name, tmp, sizeof(tmp));
	ReplaceString(szSayText, length, "{job}", tmp);
	
	rp_GetGroupData(rp_GetClientInt(client, i_Group), group_type_name, tmp, sizeof(tmp));
	ReplaceString(szSayText, length, "{gang}", tmp);
	ReplaceString(szSayText, length, "{group}", tmp);
	
	rp_GetZoneData(rp_GetPlayerZone( client ), zone_type_name, tmp, sizeof(tmp));
	ReplaceString(szSayText, length, "{zone}", tmp);
	
	String_NumberFormat( rp_GetServerInt(lotoCagnotte), tmp, sizeof(tmp));
	ReplaceString(szSayText, length, "{cagnotte}", tmp);
	
	ReplaceString(szSayText, length, "[TSX-RP]", "");	
	ReplaceString(szSayText, length, "{white}", "{default}");
	
	return Plugin_Changed;
}

public Action CmdItemMask(int args) {
	char arg1[12];
	
	GetCmdArg(1, arg1, sizeof(arg1)); int client = StringToInt(arg1);
	int item_id = GetCmdArgInt(args);
	
	if( rp_GetClientInt(client, i_MaskCount) <= 0 ) {
		char item_name[64];
		rp_GetItemData(item_id, item_type_name, item_name, sizeof(item_name));
		CPrintToChat(client, ""...MOD_TAG..." %T", "Error_ItemCannotBeUsedForNow", client, item_name);
		ITEM_CANCEL(client, item_id);
		return Plugin_Handled;
	}
	
	if (rp_GetClientInt(client, i_Mask) != 0) {
		char item_name[64];
		rp_GetItemData(item_id, item_type_name, item_name, sizeof(item_name));
		CPrintToChat(client, ""...MOD_TAG..." %T", "Error_ItemAlreadyEnable", client, item_name);
		ITEM_CANCEL(client, item_id);
		return Plugin_Handled;
	}
	if (rp_GetClientJobID(client) == 1 || rp_GetClientJobID(client) == 101) {
		CPrintToChat(client, ""...MOD_TAG..." %T", "Error_CannotUseItemPolice", client);
		ITEM_CANCEL(client, item_id);
		return Plugin_Handled;
	}
	int rand = Math_GetRandomInt(1, 7);
	char model[128];
	switch (rand) {
		case 1:Format(model, sizeof(model), "models/player/holiday/facemasks/facemask_skull.mdl");
		case 2:Format(model, sizeof(model), "models/player/holiday/facemasks/facemask_wolf.mdl");
		case 3:Format(model, sizeof(model), "models/player/holiday/facemasks/facemask_tiki.mdl");
		case 4:Format(model, sizeof(model), "models/player/holiday/facemasks/facemask_samurai.mdl");
		case 5:Format(model, sizeof(model), "models/player/holiday/facemasks/facemask_hoxton.mdl");
		case 6:Format(model, sizeof(model), "models/player/holiday/facemasks/facemask_dallas.mdl");
		case 7:Format(model, sizeof(model), "models/player/holiday/facemasks/facemask_chains.mdl");
	}
	
	rp_SetClientInt(client, i_MaskCount, rp_GetClientInt(client, i_MaskCount) - 1);
	int ent = CreateEntityByName("prop_dynamic");
	DispatchKeyValue(ent, "classname", "notsolid");
	DispatchKeyValue(ent, "model", model);
	DispatchSpawn(ent);
	
	Entity_SetModel(ent, model);
	Entity_SetOwner(ent, client);
	
	SetVariantString("!activator");
	rp_AcceptEntityInput(ent, "SetParent", client, client);
	
	SetVariantString("facemask");
	rp_AcceptEntityInput(ent, "SetParentAttachment");
	
	SDKHook(ent, SDKHook_SetTransmit, Hook_SetTransmit);
	rp_HookEvent(client, RP_OnAssurance, fwdAssuranceMask);
	rp_HookEvent(client, RP_OnPlayerKill, fwdKill);
	rp_SetClientInt(client, i_Mask, ent);
	
	return Plugin_Handled;
}
public Action fwdKill(int client, int victim, char weapon[64], int& tdm, float& ctx) {
	int maskID = rp_GetClientInt(client, i_Mask);
	
	if( client != victim && maskID > 0 ) {
		if( IsValidEdict(maskID) && IsValidEntity(maskID) && Entity_GetParent(maskID) == client )
			rp_AcceptEntityInput(maskID, "Kill");
		
		rp_SetClientInt(client, i_Mask, 0); 
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Coach_MaskDisapear", client);
		
		rp_ClientResetSkin(client);
		
		rp_UnhookEvent(client, RP_OnAssurance, fwdAssuranceMask);
		rp_UnhookEvent(client, RP_OnPlayerKill, fwdKill);
		
		
		int jobZone = rp_GetZoneInt(rp_GetPlayerZone(victim), zone_type_type);
		int appart = rp_GetPlayerZoneAppart(victim);
		if( jobZone == 0 && appart == 0 ) {
			tdm /= 2;
			return Plugin_Changed;
		}
			
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}
public Action fwdAssuranceMask(int client, int& amount) {
	amount += 500;
}

public int MenuSetSkin(Handle menu, MenuAction action, int client, int param2) {
	if (action == MenuAction_Select) {
		char options[128];
		GetMenuItem(menu, param2, options, sizeof(options));
		ServerCommand("rp_giveskin %s %d", options, client);
		rp_SetClientString(client, sz_Skin, options, strlen(options) + 1);
		rp_IncrementSuccess(client, success_list_vetement);
	}
	else if (action == MenuAction_End) {
		CloseHandle(menu);
	}
}
// ----------------------------------------------------------------------------
public Action Cmd_ItemGiveSkin(int args) {
	
	char arg1[128];
	GetCmdArg(1, arg1, sizeof(arg1));
	int client = GetCmdArgInt(2);
	int item = GetCmdArgInt(3); // WHAT? Ca sert à quoi déjà ça?
	int item_id = GetCmdArgInt(args);
	
	if (!IsModelPrecached(arg1)) {
		if (PrecacheModel(arg1) == 0) {
			return;
		}
	}
	
	if (item_id > 0) {
		char tmp[128];
		rp_GetItemData(item_id, item_type_extra_cmd, tmp, sizeof(tmp));
		
		if (StrContains(tmp, "rp_giveskin models") == 0) {
			// Skin is valid applying permanantly.	
			rp_SetClientString(client, sz_Skin, arg1, strlen(arg1) + 1);
			rp_IncrementSuccess(client, success_list_vetement);
		}
	}
	
	if (GetClientTeam(client) == CS_TEAM_T) {
		if (item > 0) {
			ServerCommand("sm_effect_setmodel \"%i\" \"%s\"", client, arg1);
			rp_HookEvent(client, RP_PrePlayerPhysic, fwdFrozen, 1.1);
		}
		else {
			SetEntityModel(client, arg1);
		}
	}
	
}
// ----------------------------------------------------------------------------
public Action Cmd_ItemPreserv(int args) {
	int client = GetCmdArgInt(1);
	int item_id = GetCmdArgInt(args);
	
	int kevlar = rp_GetClientInt(client, i_Kevlar);
	if( kevlar >= 250 ) {
		ITEM_CANCEL(client, item_id);
		return Plugin_Handled;
	}
	
	kevlar += 5;
	if( kevlar > 250 )
		kevlar = 250;
	
	rp_SetClientInt(client, i_Kevlar, kevlar);
	return Plugin_Handled;
}
public Action Cmd_ItemDisco(int args) {
	char type[32], classname[64], tmp[64];
	float src[3], dst[3];
	
	GetCmdArg(1, type, sizeof(type));
	
	int client = GetCmdArgInt(2);
	int item_id = GetCmdArgInt(args);
	
	if( !rp_IsBuildingAllowed(client) ) {
		CPrintToChat(client, ""...MOD_TAG..." %T", "Build_CannotHere", client);
		ITEM_CANCEL(client, item_id);
		return;
	}
	
	int cpt = 0;
	Entity_GetAbsOrigin(client, src);
	Format(classname, sizeof(classname), "rp_disco%s", type);
	
	for (int i = MaxClients; i <= 2048; i++) {
		if( !IsValidEdict(i) || !IsValidEntity(i) )
			continue;
		
		GetEdictClassname(i, tmp, sizeof(tmp));
		if( StrEqual(tmp, classname) ) {
			cpt++;
			Entity_GetAbsOrigin(i, dst);
			if( GetVectorDistance(src, dst) < 256.0 ) {
				CPrintToChat(client, ""...MOD_TAG..." %T", "Build_CannotHere", client);
				ITEM_CANCEL(client, item_id);
				return;
			}
			if( rp_GetBuildingData(i, BD_owner) == client) {
				CPrintToChat(client, ""...MOD_TAG..." %T", "Build_TooMany", client);
				ITEM_CANCEL(client, item_id);
				return;
			}
		}
	}
	
	if( cpt >= 5 ) {
		CPrintToChat(client, ""...MOD_TAG..." %T", "Build_TooMany", client);
		ITEM_CANCEL(client, item_id);
		return;
	}
	
	ServerCommand("sm_effect_%s %d", type, client);
	
}
public Action fwdInvincible(int client, int attacker, float& damage, int damagetype) {
	damage = 0.0;
	return Plugin_Stop;
}
public Action fwdFrozen(int client, float& speed, float& gravity) {
	speed = 0.0;
	return Plugin_Stop;
}
public Action fwdSlowTime(int client, float& speed, float& gravity) {
	speed -= 5.0;
	return Plugin_Changed;
}
public Action Cmd_ItemPoupee(int args) {
	
	int client = GetCmdArgInt(1);
	int item_id = GetCmdArgInt(args);
	
	if( !rp_GetClientBool(client, b_MayUseUltimate) ) {
		char item_name[64];
		rp_GetItemData(item_id, item_type_name, item_name, sizeof(item_name));
		CPrintToChat(client, ""...MOD_TAG..." %T", "Error_ItemCannotBeUsedForNow", client, item_name);
		ITEM_CANCEL(client, item_id);
		return Plugin_Handled;
	}
	
	rp_HookEvent(client, RP_PreTakeDamage, fwdInvincible, 5.0);
	rp_HookEvent(client, RP_PrePlayerPhysic, fwdFrozen, 5.0);
	rp_SetClientFloat(client, fl_Invincible, GetGameTime() + 5.0);
	
	int heal = GetClientHealth(client) + 100;
	int kevlar = rp_GetClientInt(client, i_Kevlar) + 25;
	
	if( kevlar > 250 )
		kevlar = 250;
	if( heal > 500 )
		heal = 500;
		
	SetEntityHealth(client, heal);
	rp_SetClientInt(client, i_Kevlar, kevlar);	
	
	float vecTarget[3];
	GetClientAbsOrigin(client, vecTarget);
	vecTarget[2] += 10.0;
	
	TE_SetupBeamRingPoint(vecTarget, 30.0, 40.0, g_cBeam, g_cGlow, 0, 0, 5.0, 80.0, 0.0, {250, 250, 50, 250}, 0, 0);
	TE_SendToAll();

	rp_SetClientBool(client, b_MayUseUltimate, false);

	CreateTimer(30.0, AllowUltimate, client);
	return Plugin_Handled;
}

public Action AllowUltimate(Handle timer, any client) {

	rp_SetClientBool(client, b_MayUseUltimate, true);
}
public Action fwdTazerRose(int client, int color[4]) {
	color[0] += 255;
	color[1] -= 50;
	color[2] += 50;
	color[3] += 50;
	return Plugin_Changed;
}
public Action Cmd_ItemMenottes(int args){
	
	int client = GetCmdArgInt(1);
	int item_id = GetCmdArgInt(args);
	if( GetClientTeam(client) == CS_TEAM_CT ) {
		CPrintToChat(client, ""...MOD_TAG..." %T", "Error_CannotUseItemPolice", client);
		ITEM_CANCEL(client, item_id);
		return;
	}
	
	int target = rp_GetClientTarget(client);
	if( !IsValidClient(target) || !rp_IsTutorialOver(target) ) {
		ITEM_CANCEL(client, item_id);
		return;
	}
	if( rp_GetZoneBit( rp_GetPlayerZone(target) ) & BITZONE_PEACEFULL || rp_GetZoneBit( rp_GetPlayerZone(client) ) & BITZONE_PEACEFULL) {
		CPrintToChat(client, ""...MOD_TAG..." %T", "Build_CannotHere", client);
		ITEM_CANCEL(client, item_id);
		return;
	}
	if( GetEntityMoveType(target) == MOVETYPE_NOCLIP ) {
		ITEM_CANCEL(client, item_id);
		return;
	}
	if( rp_GetClientBool(target, b_Lube) ) {
		CPrintToChat(client, ""...MOD_TAG..." %T", "Cmd_TargetIsSlippy", client);
		ITEM_CANCEL(client, item_id);
		return;
	}
	
	if( rp_ClientFloodTriggered(client, target, fd_menotte) ) {
		ITEM_CANCEL(client, item_id);
		CPrintToChat(client, ""...MOD_TAG..." %T", "Cmd_TargetIsSlippy", client);
		return;
	}
	rp_ClientFloodIncrement(client, target, fd_menotte, 11.0);
	rp_ClientAggroIncrement(client, target, 250);
					
	rp_SetClientInt(client, i_LastAgression, GetTime());
	rp_IncrementSuccess(client, success_list_menotte);
	rp_Effect_Tazer(client, target);
	rp_ClientColorize(target, { 255, 175, 200, 255 } );
	
	rp_HookEvent(target, RP_PrePlayerPhysic, fwdFrozen, 5.0);
	rp_HookEvent(target, RP_PreHUDColorize, fwdTazerRose, 5.0);
	
	LogToGame("[TSX-RP] [MENOTTES] %L a attaché %L.", client, target); // Ajout dans les logs
	CreateTimer(5.0, Cmd_ItemMenottes_Over, target); // TODO: Laisser rose après 5 secondes.
}
public Action Cmd_ItemMenottes_Over(Handle timer, any client) {
	
	rp_ClientColorize(client);
}
public Action Cmd_ItemSucette(int args) {
	
	int client = GetCmdArgInt(1);
		
	if( Client_IsInVehicle(client) || rp_GetClientVehiclePassager(client) ) {
		CPrintToChat(client, ""...MOD_TAG..." %T", "Error_CannotUseItemInCar", client);
		int item_id = GetCmdArgInt(args);
		ITEM_CANCEL(client, item_id);
		return Plugin_Handled;
	}
	
	if( rp_GetZoneBit(rp_GetPlayerZone(client)) & BITZONE_PERQUIZ ) {
		CPrintToChat(client, ""...MOD_TAG..." %T", "Error_CannotUseItemInPerquiz", client);
		int item_id = GetCmdArgInt(args);
		ITEM_CANCEL(client, item_id);
		return Plugin_Handled;
	}

	float Origin[3];	
	GetClientAbsOrigin(client, Origin);
	
	TE_SetupExplosion(Origin, g_cExplode, GetRandomFloat(0.5, 2.0), 2, 1, Math_GetRandomInt(25, 100) , Math_GetRandomInt(25, 100) );
	TE_SendToAll();
	
	SDKHooks_TakeDamage(client, client, client, 5000.0);
	return Plugin_Handled;
}
public Action Cmd_ItemSucette2(int args) {
	
	int client = GetCmdArgInt(1);
	int item_id = GetCmdArgInt(args);
	
	if( !rp_GetClientBool(client, b_MayUseUltimate) ) {
		char item_name[64];
		rp_GetItemData(item_id, item_type_name, item_name, sizeof(item_name));
		CPrintToChat(client, ""...MOD_TAG..." %T", "Error_ItemCannotBeUsedForNow", client, item_name);
		ITEM_CANCEL(client, item_id);
		return Plugin_Handled;
	}
	
	if( Client_IsInVehicle(client) || rp_GetClientVehiclePassager(client) ) {
		CPrintToChat(client, ""...MOD_TAG..." %T", "Error_CannotUseItemInCar", client);
		ITEM_CANCEL(client, item_id);
		return Plugin_Handled;
	}
	
	
	rp_SetClientBool(client, b_MayUseUltimate, false);
	
	float duration = 1.0;
	if( rp_IsInPVP(client) ) {
		CreateTimer(45.0, AllowUltimate, client);
		duration += 0.5;
		
		rp_HookEvent(client, RP_PreTakeDamage, fwdDamage, duration);
	}
	else if( GetClientTeam(client) == CS_TEAM_CT ) {
		
		
		if( GetConVarInt(FindConVar("rp_braquage")) == 2 ) {
			CreateTimer(0.1, AllowUltimate, client);
			CPrintToChat(client, ""...MOD_TAG..." %T", "Error_CannotUseItemInBraquage", client);
			ITEM_CANCEL(client, item_id);
			return Plugin_Handled;
		}
		CreateTimer(60.0, AllowUltimate, client);
		duration += 1.0;
		
		rp_HookEvent(client, RP_PreTakeDamage, fwdDamage, duration);
	}
	else{
		CreateTimer(30.0, AllowUltimate, client);
	}

	rp_SetClientInt(client, i_LastAgression, GetTime());
	EmitSoundToAll("UI/arm_bomb.wav", client);
	
	CreateTimer((duration / 4.0) * 1.0, Beep, client);
	CreateTimer((duration / 4.0) * 2.0, Beep, client);
	CreateTimer((duration / 4.0) * 3.0, Beep, client);
	CreateTimer(duration, 				Cmd_ItemSucette2_task, client);
	
	return Plugin_Handled;
}
public Action fwdDamage(int attacker, int victim, float& damage, int damagetype) {
	damage *= 1.10;
	return Plugin_Changed;
}
public Action Beep(Handle timer, any client) {
	
	EmitSoundToAll("UI/arm_bomb.wav", client);
}
public Action Cmd_ItemSucette2_task(Handle timer, any client) {
	
	if( !IsValidClient(client) )
		return Plugin_Handled;
	if( !IsPlayerAlive(client) )
		return Plugin_Handled;
	
	int lenght = (GetClientHealth(client)*2);
	
	if( lenght > 1000 )
		lenght = 1000;
	
	if( rp_IsInPVP(client) )
		lenght = RoundToFloor(float(lenght) / 2.0);
	
	float Origin[3];
	GetClientAbsOrigin(client, Origin);
	TE_SetupExplosion(Origin, g_cExplode, GetRandomFloat(0.5, 2.0), 2, 1, Math_GetRandomInt(25, 100) , Math_GetRandomInt(25, 100) );
	TE_SendToAll();
	
	int amount = rp_Effect_Explode(Origin, float(lenght)*2.0, float(lenght), client, "weapon_sucetteduo");
	rp_Effect_Push(Origin, float(lenght), float(lenght));
	
	SDKHooks_TakeDamage(client, client, client, 5000.0);
	
	if( amount >= 10 )
		rp_IncrementSuccess(client, success_list_sexshop, 10);
	
	return Plugin_Handled;
}

public Action Cmd_ItemFouet(int args) {
	
	int client = GetCmdArgInt(1);
	int item_id = GetCmdArgInt(args);
	int target = rp_GetClientTarget(client);
	
	if( !IsValidClient(target) ) {
		ITEM_CANCEL(client, item_id);
		return Plugin_Handled;
	}
	if( rp_GetDistance(client, target) > MAX_AREA_DIST ) {
		ITEM_CANCEL(client, item_id);
		return Plugin_Handled;
	}
	if( !rp_IsTutorialOver(target) ) {
		ITEM_CANCEL(client, item_id);
		return Plugin_Handled;
	}
	if( rp_GetZoneBit( rp_GetPlayerZone(target) ) & BITZONE_PEACEFULL ) {
		ITEM_CANCEL(client, item_id);
		return Plugin_Handled;
	}
	
	if( rp_ClientFloodTriggered(client, target, fd_fouet) ) {
		CPrintToChat(client, ""...MOD_TAG..." %T", "Cmd_TargetIsSlippy", client);
		ITEM_CANCEL(client, item_id);
		return Plugin_Handled;
	}
	rp_ClientFloodIncrement(client, target, fd_fouet, 5.0);
	
	rp_SetClientInt(client, i_LastAgression, GetTime());
	rp_Effect_Tazer(client, target);
	rp_ClientDamage(target, rp_GetClientInt(client, i_KnifeTrain), client);
	rp_ClientAggroIncrement(client, target, 100);
	
	SlapPlayer(target, 0, true);
	SlapPlayer(target, 0, true);
	EmitSoundToAllAny("tsx/roleplay/fouet.mp3", target);
	
	rp_HookEvent(target, RP_PreHUDColorize, fwdSlowTime, 5.0);
	
	return Plugin_Handled;
}
public Action Cmd_ItemAlcool(int args) {
	char arg[16];
	int client, target, item_id;
	client = GetCmdArgInt(3);
	item_id = GetCmdArgInt(args);
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg,"me")){
		target = client;
	}
	else if (StrEqual(arg,"aim")){
		target = rp_GetClientTarget(client);
		if(target == -1 || !rp_IsEntitiesNear(client, target, true)){
			ITEM_CANCEL(client,item_id);
			return Plugin_Handled;
		}
		if( rp_GetZoneBit( rp_GetPlayerZone(target) ) & BITZONE_PEACEFULL ) {
			CPrintToChat(client, ""...MOD_TAG..." %T", "Error_CannotUseItemInPeace", client);
			ITEM_CANCEL(client, item_id);
			return Plugin_Handled;
		}
		if( rp_GetClientFloat(target, fl_Alcool) > 0.0 ) {
			CPrintToChat(client, ""...MOD_TAG..." %T", "Drink_TooMuchTarget", client);
			ITEM_CANCEL(client, item_id);
			return Plugin_Handled;
		}
		float vecTarget[3];
		GetClientAbsOrigin(client, vecTarget);
		TE_SetupBeamRingPoint(vecTarget, 10.0, 500.0, g_cBeam, g_cGlow, 0, 15, 0.5, 50.0, 0.0, { 255, 0, 191, 200}, 10, 0);
		rp_SetClientInt(client, i_LastAgression, GetTime());
		LogToGame("[TSX-RP] [DROGUE] %L a alcoolisé %L.", client, target);
		rp_ClientAggroIncrement(client, target, 1000);
	}

	float level = rp_GetClientFloat(target, fl_Alcool) + GetCmdArgFloat(2);
	rp_SetClientFloat(target, fl_Alcool, level);
	rp_IncrementSuccess(target, success_list_alcool_abuse);	
	if( level > 4.0 ) {
		SDKHooks_TakeDamage(target, target, target, (25 + GetClientHealth(target))/2.0);
	}
	return Plugin_Handled;
}
// ----------------------------------------------------------------------------
public Action Cmd_ItemKevlarBox(int args) {
	int client = GetCmdArgInt(1);
	
	if( BuildingKevlarBox(client) == 0 ) {
		int item_id = GetCmdArgInt(args);
		
		ITEM_CANCEL(client, item_id);
	}
}
int BuildingKevlarBox(int client) {
	
	if( !rp_IsBuildingAllowed(client) ) {
		CPrintToChat(client, ""...MOD_TAG..." %T", "Build_CannotHere", client);
		return 0;
	}
	
	char classname[64], tmp[64];
	Format(classname, sizeof(classname), "rp_kevlarbox");
	
	float vecOrigin[3], vecOrigin2[3];
	GetClientAbsOrigin(client, vecOrigin);
	
	for(int i=1; i<=2048; i++) {
		if( !IsValidEdict(i) )
			continue;
		if( !IsValidEntity(i) )
			continue;
			
		GetEdictClassname(i, tmp, 63);
		
		if( StrEqual(classname, tmp) && rp_GetBuildingData(i, BD_owner) == client ) {
			CPrintToChat(client, ""...MOD_TAG..." %T", "Build_TooMany", client);
			return 0;
		}
		if( StrEqual(tmp, "rp_kevlarbox") ) {
			Entity_GetAbsOrigin(i, vecOrigin2);
			if( GetVectorDistance(vecOrigin, vecOrigin2) < 600 ) {
				CPrintToChat(client, ""...MOD_TAG..." %T", "Build_CannotHere", client);
				return 0;
			}
		}
	}
	
	EmitSoundToAllAny("player/ammo_pack_use.wav", client, _, _, _, 0.66);
	
	int ent = CreateEntityByName("prop_physics");
	
	DispatchKeyValue(ent, "classname", classname);
	DispatchKeyValue(ent, "model", MODEL_KEVLARBOX);
	DispatchSpawn(ent);
	ActivateEntity(ent);
	
	SetEntityModel(ent, MODEL_KEVLARBOX);
	SetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity", client);
	SetEntProp( ent, Prop_Data, "m_takedamage", 2);
	SetEntProp( ent, Prop_Data, "m_iHealth", 50000);
	
	TeleportEntity(ent, vecOrigin, NULL_VECTOR, NULL_VECTOR);
	
	SetEntityRenderMode(ent, RENDER_NONE);
	ServerCommand("sm_effect_fading \"%i\" \"2.5\" \"0\"", ent);
	
	rp_HookEvent(client, RP_PrePlayerPhysic, fwdFrozen, 3.0);
	SetEntityMoveType(ent, MOVETYPE_NONE);
	
	rp_SetBuildingData(ent, BD_started, GetTime());
	rp_SetBuildingData(ent, BD_owner, client );
	rp_SetBuildingData(ent, BD_FromBuild, 0);
	Entity_SetMaxHealth(ent, Entity_GetHealth(ent));
	
	CreateTimer(3.0, BuildingKevlarBox_post, ent);

	return ent;
	
}
public Action BuildingKevlarBox_post(Handle timer, any entity) {
	
	if( !IsValidEdict(entity) && !IsValidEntity(entity) )
		return Plugin_Handled;
	
	if( rp_IsInPVP(entity) ) {
		rp_ClientColorize(entity);
	}
	
	SetEntProp( entity, Prop_Data, "m_takedamage", 2);
	HookSingleEntityOutput(entity, "OnBreak", BuildingKevlarBox_break);
	SDKHook(entity, SDKHook_OnTakeDamage, DamageMachine);
	
	CreateTimer(1.0, Frame_KevlarBox, EntIndexToEntRef(entity));
	
	return Plugin_Handled;
}
public Action DamageMachine(int victim, int &attacker, int &inflictor, float &damage, int &damagetype) {
	if( !Entity_CanBeBreak(victim, attacker) ) {
		damage = 0.0;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}
public void BuildingKevlarBox_break(const char[] output, int caller, int activator, float delay) {
	
	int owner = GetEntPropEnt(caller, Prop_Send, "m_hOwnerEntity");
	
	if( IsValidClient(activator) && IsValidClient(owner) ) {
		rp_ClientAggroIncrement(activator, owner, 1000);
	}
	
	if( IsValidClient(owner) ) {
		char tmp[128];
		GetEdictClassname(caller, tmp, sizeof(tmp));
		CPrintToChat(owner, "" ...MOD_TAG... " %T", "Build_Destroyed", owner, tmp);
	}
	
	float vecOrigin[3];
	Entity_GetAbsOrigin(caller,vecOrigin);
	TE_SetupSparks(vecOrigin, view_as<float>({0.0,0.0,1.0}),120,40);
	TE_SendToAll();
	
	//rp_Effect_Explode(vecOrigin, 100.0, 400.0, client);
}
public Action Frame_KevlarBox(Handle timer, any ent) {
	ent = EntRefToEntIndex(ent); if( ent == -1 ) { return Plugin_Handled; }
	
	float vecOrigin[3], vecOrigin2[3];
	Entity_GetAbsOrigin(ent, vecOrigin);
	vecOrigin[2] += 12.0;
	
	bool inPvP = rp_IsInPVP(ent);
	float maxDist = 240.0;
	if( inPvP )
		maxDist = 180.0;
	
	int boxHeal = GetEntProp(ent, Prop_Data, "m_iHealth"), kevlar, toKevlar;
	float dist;
	
	int owner = GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity");	
	if( !IsValidClient(owner) ) {
		rp_ScheduleEntityInput(ent, 60.0, "Kill");
		return Plugin_Handled;
	}
	int gOWNER = rp_GetClientGroupID(owner);
	
	for(int client=1; client<=MaxClients; client++) {
		
		if( !IsValidClient(client) )
			continue;
		if( boxHeal < 100 )
			break;
		if( inPvP && rp_GetClientGroupID(client) != gOWNER )
			continue;
		
		GetClientAbsOrigin(client, vecOrigin2);
		vecOrigin2[2] += 24.0;
		
		dist = GetVectorDistance(vecOrigin, vecOrigin2);
		if( dist > maxDist )
			continue;
		
		kevlar = rp_GetClientInt(client, i_Kevlar);
		if( kevlar >= 250 ){
			SetEntProp(client, Prop_Send, "m_bHasHelmet", 1);
			continue;
			}
		
		Handle trace = TR_TraceRayFilterEx(vecOrigin, vecOrigin2, MASK_SHOT, RayType_EndPoint, FilterToOne, ent);
		
		if( TR_DidHit(trace) ) {
			if( TR_GetEntityIndex(trace) != client ) {
				CloseHandle(trace);
				continue;
			}
		}
		
		CloseHandle(trace);
		
		if( inPvP || rp_IsInPVP(client) ) {
			toKevlar = 3;
			kevlar += 3;
		}
		else {
			toKevlar = 6;
			kevlar += 6;
		}
		
		if( kevlar > 250 )
			kevlar = 250;
			
		boxHeal -= toKevlar;
		rp_SetClientInt(client, i_Kevlar, kevlar);
	}
	boxHeal += 5;
	if( !inPvP )
		boxHeal += Math_GetRandomInt(5, 20);
	if( boxHeal > 50000 )
		boxHeal = 50000;
	
	SetEntProp(ent, Prop_Data, "m_iHealth", boxHeal);
	
	rp_Effect_Particle(ent, "beamring_shield", 0.5);
	
	CreateTimer(1.0, Frame_KevlarBox, EntIndexToEntRef(ent));
	return Plugin_Handled;
}
public Action Cmd_ItemLube(int args){
	int client = GetCmdArgInt(1);

	rp_SetClientBool(client, b_Lube, true);
	rp_HookEvent(client, RP_PreHUDColorize, fwdLube, 30.0);
	rp_HookEvent(client, RP_OnAssurance,	fwdAssuranceLube);
	
	return Plugin_Handled;
}
public Action fwdAssuranceLube(int client, int& amount) {
	if( rp_GetClientBool(client, b_Lube) )
		amount += 1000;
}

public Action fwdLube(int client, int color[4]){
	
	color[0] += 255;
	color[1] += 191;
	color[2] += 255;
	color[3] += 50;
	return Plugin_Changed;
}

// ----------------------------------------------------------------------------
public Action Cmd_ItemCigarette(int args) {
	
	char Arg1[32];
	GetCmdArg(1, Arg1, 31);
	int client = GetCmdArgInt(2);
	int item_id = GetCmdArgInt(args);
	
	
	if( StrEqual(Arg1, "deg") ) {
		if( !rp_GetClientBool(client, b_MayUseUltimate) ) {
			char item_name[128];
			rp_GetItemData(item_id, item_type_name, item_name, sizeof(item_name));
			CPrintToChat(client, ""...MOD_TAG..." %T", "Error_ItemCannotBeUsedForNow", client, item_name);
			ITEM_CANCEL(client, item_id);
			return Plugin_Handled;
		}
		rp_SetClientBool(client, b_MayUseUltimate, false);
		CreateTimer(10.0, AllowUltimate, client);
		rp_SetClientInt(client, i_LastAgression, GetTime());
		float origin[3];
		GetClientAbsOrigin(client, origin);
		origin[2] -= 1.0;
		rp_Effect_Push(origin, 500.0, 1000.0, client);
	}
	else if( StrEqual(Arg1, "flame") ) {
		UningiteEntity(client);
		for(float i=0.1; i<=30.0; i+= 0.50) {
			CreateTimer(i, Task_UningiteEntity, client);
		}
	}
	else if( StrEqual(Arg1, "light") ) {
		rp_HookEvent(client, RP_PrePlayerPhysic, fwdCigGravity, 30.0);
	}
	else if( StrEqual(Arg1, "choco") ) {
		// Ne fait absolument rien.
	}
	else { // WHAT IS THAT KIND OF SORCELERY?
		rp_HookEvent(client, RP_PrePlayerPhysic, fwdCigSpeed, 30.0);
	}
	
	if( StrEqual(Arg1, "flame") )
		ServerCommand("sm_effect_particles %d shacks_exhaust 30 c4", client);
	else
		ServerCommand("sm_effect_particles %d shacks_exhaust 30 facemask", client);
	
	if( g_hCigarette[client] != INVALID_HANDLE )
		delete g_hCigarette[client];
	
	g_hCigarette[client] = CreateTimer( 30.0, ItemStopCig, client);
	rp_SetClientBool(client, b_Smoking, true);
	
	return Plugin_Handled;
}
public Action Task_UningiteEntity(Handle timer, any client) {
	UningiteEntity(client);
}
public Action ItemStopCig(Handle timer, any client) {
	g_hCigarette[client] = INVALID_HANDLE;
	rp_SetClientBool(client, b_Smoking, false);
}
public Action fwdCigGravity(int client, float& speed, float& gravity) {
	gravity -= 0.15;
	
	return Plugin_Changed;
}


public Action Cmd_ItemRuban(int args) {

	int client = GetCmdArgInt(1);
	int item_id = GetCmdArgInt(args);
	rp_ClientGiveItem(client, item_id);
	
	Handle dp;
	CreateDataTimer(0.25, Cmd_ItemRuban_Task, dp);
	WritePackCell(dp, client);
	WritePackCell(dp, item_id);
	
	
	return Plugin_Handled;
}
public Action Cmd_ItemRuban_Task(Handle timer, any dp) {
	ResetPack(dp);
	int client = ReadPackCell(dp);
	int item_id = ReadPackCell(dp);
	
	char tmp[32], tmp2[64];
	Handle menu = CreateMenu(MenuRubanWho);
	SetMenuTitle(menu, "%T\n ", "Ruban", client);
	
	Format(tmp, sizeof(tmp), "%i_target", item_id);
	Format(tmp2, sizeof(tmp2), "%T", "Ruban_Target", client);
	AddMenuItem(menu, tmp, tmp2);
	
	Format(tmp, sizeof(tmp), "%i_client", item_id);
	Format(tmp2, sizeof(tmp2), "%T", "Ruban_Myself", client);
	AddMenuItem(menu, tmp, tmp2);
	
	DisplayMenu(menu, client, 60);
	
	CloseHandle(dp);
	return Plugin_Handled;
}
public int MenuRubanWho(Handle menu, MenuAction action, int client, int param2) {
	if( action == MenuAction_Select ) {
		int target;
		char options[64], data[2][32];
		GetMenuItem(menu, param2, options, 63);
		ExplodeString(options, "_", data, sizeof(data), sizeof(data[]));
		if(StrEqual(data[1],"client")){
			target = client;
		}
		else{
			target = GetClientAimTarget(client, false);
			if( target == 0 || !IsValidEdict(target) || !IsValidEntity(target) ) {
				return;
			}
			char classname[64];
			GetEdictClassname(target, classname, sizeof(classname));

			if( StrContains("chicken|player|weapon|prop_physics|", classname) == -1 ){
				return;
			}

			if( !rp_IsEntitiesNear(client, target) ){
				return;
			}
		}
		char tmp[64], tmp2[64], expl[3][12];
		Handle menucolor = CreateMenu(MenuRubanColor);
		SetMenuTitle(menucolor, "%T\n ", "Ruban_Color", client);
		
		for (int i = 0; i < sizeof(g_szColor); i++) {
			ExplodeString(g_szColor[i], " ", expl, sizeof(expl), sizeof(expl[]));
			
			Format(tmp, sizeof(tmp),"%s_%i_%i_%i_%i_%i", data[0], target, StringToInt(expl[0]), StringToInt(expl[1]), StringToInt(expl[2]), 200);
			Format(tmp2, sizeof(tmp2), "%T", g_szColor[i], client);
			AddMenuItem(menucolor, tmp, tmp2);
		}
		
		DisplayMenu(menucolor, client, 20);
	}
	else if( action == MenuAction_End ) {
		CloseHandle(menu);
	}
}
public int MenuRubanColor(Handle menu, MenuAction action, int client, int param2) {
	if( action == MenuAction_Select ) {
		char options[64], data[6][32];
		int color[4];
		GetMenuItem(menu, param2, options, 63);
		ExplodeString(options, "_", data, sizeof(data), sizeof(data[]));
		int item_id = StringToInt(data[0]);
		int target = StringToInt(data[1]);
		color[0] = StringToInt(data[2]);
		color[1] = StringToInt(data[3]);
		color[2] = StringToInt(data[4]);
		color[3] = StringToInt(data[5]);
		
		if( target == 0 || !IsValidEdict(target) || !IsValidEntity(target) ) {
			return;
		}
		
		if( rp_ClientFloodTriggered(client, target, fd_ruban) ) {
			CPrintToChat(client, ""...MOD_TAG..." %T", "Cmd_TargetIsSlippy", client);
			return;
		}
		rp_ClientFloodIncrement(client, target, fd_ruban, 31.0);
		
		if(rp_GetClientItem(client, item_id)==0){
			char item_name[128];
			rp_GetItemData(item_id, item_type_name, item_name, sizeof(item_name));
			CPrintToChat(client, ""...MOD_TAG..." %T", "Error_ItemMissing", client, item_name);
			return;
		}
		else{
			rp_ClientGiveItem(client, item_id, -1);
		}

		TE_SetupBeamFollow(target, g_cBeam, 0, 180.0, 4.0, 0.1, 5, color);
		TE_SendToAll();
	}
	else if( action == MenuAction_End ) {
		CloseHandle(menu);
	}
}
void UningiteEntity(int entity) {
	
	int ent = GetEntPropEnt(entity, Prop_Data, "m_hEffectEntity");
	if( IsValidEdict(ent) )
		SetEntPropFloat(ent, Prop_Data, "m_flLifetime", 0.0); 
}
// ----------------------------------------------------------------------------
public Action fwdUse(int client) {
	int zoneid = rp_GetPlayerZone(client);
	if (zoneid != ZONE_CABINE)
		return Plugin_Continue;
	
	Draw_SkinList(client, -1, -1);
	
	return Plugin_Handled;
}
void Draw_SkinList(int client, int test, int skinID) {
	int female, prix;
	bool isfemale = rp_GetClientBool(client, b_isFemale);
	char tmp[128], tmp2[128];
	
	if (rp_GetPlayerZone(client) != ZONE_CABINE) {
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Cabine_Error_Left", client);
		return;
	}
	if (GetClientTeam(client) == CS_TEAM_CT) {
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Cabine_Error_CT", client);
		return;
	}
	GetClientModel(client, tmp, sizeof(tmp));
	if( StrEqual(tmp, "models/player/custom_player/legacy/sprisioner/sprisioner.mdl") ) {
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Cabine_Error_Prisonner", client);
		return;
	}
	
	
	
	if( test == -1 ) {
		Menu menu = new Menu(MenuTrySkin);
		menu.SetTitle("%T\n ", "Cabine", client);
		
		Format(tmp, sizeof(tmp), "%T", "Cabine_Try", client);	menu.AddItem("1 -1", tmp);
		Format(tmp, sizeof(tmp), "%T", "Cabine_Buy", client);	menu.AddItem("0 -1", tmp);
		
		menu.Display(client, 60);
		return;
	}
	if( skinID == -1 ) {
		Menu menu = new Menu(MenuTrySkin);
		menu.SetTitle("%T\n ", "Cabine_Choose", client);
		
		char item_name[128];
		rp_GetItemData(ITEM_FITNESS, item_type_name, item_name, sizeof(item_name));
		
		for (int i = 0; i < sizeof(g_szSkinsList); i++) {
			female = StringToInt(g_szSkinsList[i][2]);
			
			Format(tmp, sizeof(tmp), "%d %d", test, i);
			if( test )
				Format(tmp2, sizeof(tmp2), "%T", "_s", client, g_szSkinsList[i][1]);
			else if( StringToInt(g_szSkinsList[i][3]) == 0 )
				Format(tmp2, sizeof(tmp2), "%T", "Cabine_Line_Free", client, g_szSkinsList[i][1]);
			else
				Format(tmp2, sizeof(tmp2), "%T", "Cabine_Line_Pass", client, g_szSkinsList[i][1], StringToInt(g_szSkinsList[i][3]), item_name);
			
			if( (female==2) && ((rp_GetClientInt(client, i_Donateur) >= 1&&rp_GetClientInt(client, i_Donateur) <=10)||test) ) 
				menu.AddItem(tmp, tmp2);			
			if( (female==1) && isfemale )
				menu.AddItem(tmp, tmp2);
			if( (female==0) && !isfemale )
				menu.AddItem(tmp, tmp2);
		}
		menu.Display(client, 60);
		return;
	}
	else {
		
		if( !IsModelPrecached(g_szSkinsList[skinID][0]) )  {
			if( !PrecacheModel(g_szSkinsList[skinID][0]) ) {
				PrintToChat(client, "" ...MOD_TAG... " %T", "Error_FromServer", client);
				return;
			}
		}
		
		if( test ) {
			rp_HookEvent(client, RP_OnPlayerZoneChange, fwdOnZoneChange);
			
			if( rp_GetPlayerZone(client) != ZONE_CABINE) {
				CPrintToChat(client, ""...MOD_TAG..." %T", "Cabine_Error_Left", client);
				return;
			}
		}
		else {
			prix = StringToInt(g_szSkinsList[skinID][3]);
			
			if( rp_GetClientItem(client, ITEM_FITNESS ) < prix ) {
				char item_name[128];
				rp_GetItemData(ITEM_FITNESS, item_type_name, item_name, sizeof(item_name));
				CPrintToChat(client, ""...MOD_TAG..." %T", "Error_ItemNotEnought", client, item_name);
				return;
			}
			
			rp_ClientGiveItem(client, ITEM_FITNESS, -prix);
			rp_SetClientInt(client, i_SkinDonateur, StringToInt(g_szSkinsList[skinID][4]));
			
			if( StringToInt(g_szSkinsList[skinID][2]) != 2 ) {
				rp_SetClientString(client, sz_Skin, g_szSkinsList[skinID][0], strlen(g_szSkinsList[skinID][0])+1);
				rp_IncrementSuccess(client, success_list_vetement);
			}
		}
		
		ServerCommand("sm_effect_setmodel \"%i\" \"%s\"", client, g_szSkinsList[skinID][0]);
		
		
	}
}
public int MenuTrySkin(Handle menu, MenuAction action, int client, int param2) {
	
	if (action == MenuAction_Select) {
		char szMenuItem[128], explo[2][32];
		
		GetMenuItem(menu, param2, szMenuItem, sizeof(szMenuItem));
		ExplodeString(szMenuItem, " ", explo, sizeof(explo), sizeof(explo[]));
		Draw_SkinList(client, StringToInt(explo[0]), StringToInt(explo[1]));
	}
	else if (action == MenuAction_End) {
		CloseHandle(menu);
	}
}
public Action fwdOnZoneChange(int client, int newZone, int oldZone) {
	rp_ClientResetSkin(client);
	CreateTimer(1.0, POST_Reset, client);
	rp_UnhookEvent(client, RP_OnPlayerZoneChange, fwdOnZoneChange);
}
public Action POST_Reset(Handle timer, any client) {
	rp_ClientResetSkin(client);
}
