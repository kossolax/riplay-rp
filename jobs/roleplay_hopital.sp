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
#include <cstrike>
#include <colors_csgo>	// https://forums.alliedmods.net/showthread.php?p=2205447#post2205447
#include <smlib>		// https://github.com/bcserv/smlib
#include <emitsoundany> // https://forums.alliedmods.net/showthread.php?t=237045

#pragma newdecls required
#include <roleplay.inc>	// https://www.ts-x.eu

public Plugin myinfo = {
	name = "Jobs: HOPITAL", author = "KoSSoLaX",
	description = "RolePlay - Jobs: Hôpital",
	version = __LAST_REV__, url = "https://www.ts-x.eu"
};

int g_cBeam;
int g_iSuccess_last_faster_dead[65];
// ----------------------------------------------------------------------------
public Action Cmd_Reload(int args) {
	char name[64];
	GetPluginFilename(INVALID_HANDLE, name, sizeof(name));
	ServerCommand("sm plugins reload %s", name);
	return Plugin_Continue;
}
public void OnPluginStart() {
	RegServerCmd("rp_quest_reload", Cmd_Reload);
	RegServerCmd("rp_chirurgie",		Cmd_ItemChirurgie,		"RP-ITEM",	FCVAR_UNREGISTERED);
	
	RegServerCmd("rp_item_adrenaline",	Cmd_ItemAdrenaline,		"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_poison",		Cmd_ItemPoison,			"RP-ITEM",	FCVAR_UNREGISTERED);	
	RegServerCmd("rp_item_antipoison",	Cmd_ItemAntiPoison,		"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_fullheal",	Cmd_ItemFullHeal,		"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_respawn",		Cmd_ItemRespawn,		"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_sick",		Cmd_ItemSick,			"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_curedesintox",	Cmd_ItemCureDesintox,		"RP-ITEM",		FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_protimmu",	Cmd_ItemProtImmu,		"RP-ITEM",		FCVAR_UNREGISTERED);
	
	RegServerCmd("rp_item_healbox",		Cmd_ItemHealBox,		"RP-ITEM", 	FCVAR_UNREGISTERED);
	
	for (int i = 1; i <= MaxClients; i++) 
		if( IsValidClient(i) )
			OnClientPostAdminCheck(i);
}
public void OnMapStart() {
	g_cBeam = PrecacheModel("materials/sprites/laserbeam.vmt", true);
	PrecacheModel(MODEL_HEALBOX, true);
}
public void OnConfigsExecuted() {
	CreateTimer(1.0, PostConfigExecuted);
}
public Action PostConfigExecuted(Handle timer, any none) {
	ServerCommand("healthshot_health 250");
}
// ----------------------------------------------------------------------------
public void OnClientPostAdminCheck(int client) {
	rp_HookEvent(client, RP_OnAssurance,	fwdAssurance);
	rp_HookEvent(client, RP_OnPlayerDead,	fwdDeath);
	rp_HookEvent(client, RP_OnPlayerBuild,	fwdOnPlayerBuild);
	
	if( rp_GetClientBool(client, ch_Force) )
		rp_HookEvent(client, RP_PreGiveDamage, fwdChiruForce); 
	if( rp_GetClientBool(client, ch_Speed) )
		rp_HookEvent(client, RP_PrePlayerPhysic, fwdChiruSpeed); 
	if( rp_GetClientBool(client, ch_Jump) )
		rp_HookEvent(client, RP_PrePlayerPhysic, fwdChiruJump);
	if( rp_GetClientBool(client, ch_Regen))
		rp_HookEvent(client, RP_OnFrameSeconde, fwdChiruHealing);
	if( rp_GetClientBool(client, ch_Heal))
		rp_HookEvent(client, RP_OnPlayerSpawn, fwdSpawn);
}
public Action fwdDeath(int victim, int attacker, float& respawn, int& tdm) {
	if( g_iSuccess_last_faster_dead[attacker] +1 >= GetTime() ) {
		rp_IncrementSuccess(attacker, success_list_faster_dead);
		return Plugin_Handled;
	}
	return Plugin_Continue;
}
// ----------------------------------------------------------------------------
public Action Cmd_ItemChirurgie(int args) {
		
	char arg1[12];
	GetCmdArg(1, arg1, sizeof(arg1));
	
	int client = GetCmdArgInt(2);
	int vendeur = GetCmdArgInt(3);
	float time = rp_GetClientInt(vendeur, i_Job) == 13 ? 30.0 : 5.0;


	for (float i = 0.0; i < time; i+= 5.0) {
		Handle dp = CreateDataPack();
		CreateDataTimer(i, ChiruEffect, dp);
		WritePackCell(dp, client);
		WritePackCell(dp, vendeur);
	}
	
	CPrintToChat(client, "" ...MOD_TAG... " %N vous fait une opération chirurgicale.", vendeur);
	CPrintToChat(vendeur, "" ...MOD_TAG... " Vous commencez à opérer %N.", client);
	
	rp_HookEvent(client, RP_PrePlayerPhysic, fwdFrozen, time);
	rp_HookEvent(vendeur, RP_PrePlayerPhysic, fwdFrozen, time);
	
	rp_SetClientFloat(client, fl_TazerTime, GetGameTime() + time);
	rp_SetClientFloat(vendeur, fl_TazerTime, GetGameTime() + time);
	
	g_iSuccess_last_faster_dead[client] = GetTime() - RoundToCeil(time);
	
	ServerCommand("sm_effect_panel %d %f \"Chirurgie en cours...\"", client, time);
	ServerCommand("sm_effect_panel %d %f \"Chirurgie en cours...\"", vendeur, time);
	
	rp_Effect_Particle(client, "blood_pool");
	
	if( StrEqual(arg1, "force") || StrEqual(arg1, "full") ) {
		if( !rp_GetClientBool(client, ch_Force) )
			rp_HookEvent(client, RP_PreGiveDamage, fwdChiruForce); 
		rp_SetClientBool(client, ch_Force, true);
	}
	if( StrEqual(arg1, "speed") || StrEqual(arg1, "full") ) {
		if( !rp_GetClientBool(client, ch_Speed) )
			rp_HookEvent(client, RP_PrePlayerPhysic, fwdChiruSpeed); 
		rp_SetClientBool(client, ch_Speed, true);
	}
	if( StrEqual(arg1, "jump") || StrEqual(arg1, "full") ) {
		if( !rp_GetClientBool(client, ch_Jump) )
			rp_HookEvent(client, RP_PrePlayerPhysic, fwdChiruJump);
		rp_SetClientBool(client, ch_Jump, true);
	}
	if( StrEqual(arg1, "regen") || StrEqual(arg1, "full") ) {
		if( !rp_GetClientBool(client, ch_Regen))
			rp_HookEvent(client, RP_OnFrameSeconde, fwdChiruHealing);
		rp_SetClientBool(client, ch_Regen, true);
	}
	if( StrEqual(arg1, "heal") || StrEqual(arg1, "full") ) {
		
		SetEntityHealth(client, 500);
		if( !rp_GetClientBool(client, ch_Heal))
			rp_HookEvent(client, RP_OnPlayerSpawn, fwdSpawn);
		
		rp_SetClientBool(client, ch_Heal, true);
	}
	
	return Plugin_Handled;
}
public Action ChiruEffect(Handle timer, Handle dp) {
	ResetPack(dp);
	int client = ReadPackCell(dp);
	int vendeur = ReadPackCell(dp);
	
	float vecOrigin[3], vecOrigin2[3];
	GetClientEyePosition(client, vecOrigin);
	GetClientEyePosition(vendeur, vecOrigin2);
	
	vecOrigin[2] -= 20.0; vecOrigin2[2] -= 20.0;
	
	
	TE_SetupBeamPoints(vecOrigin, vecOrigin2, g_cBeam, 0, 0, 0, 5.001, 20.0, 20.0, 0, 0.0, {250, 50, 20, 250}, 20);
	TE_SendToAll();
	
	return Plugin_Handled;
}
public Action fwdFrozen(int client, float& speed, float& gravity) {
	speed = 0.0;
	gravity = 0.0; 
	return Plugin_Stop;
}
// ----------------------------------------------------------------------------
public Action fwdChiruForce(int attacker, int victim, float &damage, int damagetype) {
	
	if( !(damagetype & (DMG_BLAST|DMG_CRUSH)) ) {
		damage *= 1.75;
		return Plugin_Changed;
	}
	
	return Plugin_Continue;
}
public Action fwdChiruSpeed(int client, float& speed, float& gravity) {
	speed += 0.30;
	
	return Plugin_Changed;
}
public Action fwdChiruJump(int client, float& speed, float& gravity) {
	gravity -= 0.33;
	
	return Plugin_Changed;
}
public Action fwdChiruHealing(int client) {
	if( GetClientHealth(client) < Entity_GetMaxHealth(client) ) {
		SetEntityHealth(client, GetClientHealth(client)+1);
	}
}
public Action fwdAssurance(int client, int& amount) {
	
	if( rp_GetClientBool(client, ch_Force) ) {
		amount += 500;
	}
	if( rp_GetClientBool(client, ch_Heal) ) {
		amount += 1000;
	}
	if( rp_GetClientBool(client, ch_Jump) ) {
		amount += 750;
	}
	if( rp_GetClientBool(client, ch_Regen) ) {
		amount += 500;
	}
	if( rp_GetClientBool(client, ch_Speed) ) {
		amount += 1000;
	}	
	
	return Plugin_Changed; // N'a pas d'impact, pour le moment.
}
public Action fwdSpawn(int client) {
	if( GetClientTeam(client) == CS_TEAM_T ) {
		if( GetClientHealth(client) < 200 )
			SetEntityHealth(client, 200);
	}
}
// ----------------------------------------------------------------------------
public Action Cmd_ItemSick(int args) {
	static bool bDiag[65];
	
	int type = GetCmdArgInt(1);
	int client = GetCmdArgInt(2);	
	
	if( type == view_as<int>(sick_type_none) ) {
		bDiag[client] = true;
		
		switch(rp_GetClientInt(client, i_Sick)) {
			case sick_type_fievre:
				CPrintToChat(client, "" ...MOD_TAG... " Vous êtes atteint d'une forte fièvre. Prenez des Cachets d'aspirine.");
			case sick_type_grippe:
				CPrintToChat(client, "" ...MOD_TAG... " Vous êtes atteint de la Grippe. Prenez des Cachets d'amantadine.");
			case sick_type_tourista:
				CPrintToChat(client, "" ...MOD_TAG... " Vous êtes atteint de la Tourista. Prenez des Cachets de norfloxacine.");
			case sick_type_hemoragie:
				CPrintToChat(client, "" ...MOD_TAG... " Vous êtes atteint d'hémorragie. Prenez une Poche de sang et priez.");
			default: {
				if( rp_GetClientInt(client, i_Sickness) )
					CPrintToChat(client, "" ...MOD_TAG... " Vous êtes empoisonné, prenez donc un antipoison...");
				else
					CPrintToChat(client, "" ...MOD_TAG... " Paix à votre âme. Je ne connais pas cette maladie.");
			}
				
		}
		g_iSuccess_last_faster_dead[client] = GetTime();
	}
	else if( bDiag[client] && rp_GetClientInt(client, i_Sick) == type ) {
		rp_SetClientInt(client, i_Sick, view_as<int>(sick_type_none));
		bDiag[client] = false;
		CPrintToChat(client, "" ...MOD_TAG... " Vous vous sentez mieux.");
		g_iSuccess_last_faster_dead[client] = GetTime();
	}
	else {
		CPrintToChat(client, "" ...MOD_TAG... " Ça n'a eut aucun effet.");
	}
}
public Action Cmd_ItemPoison(int args) {
	
	int client = GetCmdArgInt(1);
	int target = rp_GetClientTarget(client);
	int item_id = GetCmdArgInt(args);
	
	if( rp_GetZoneBit( rp_GetPlayerZone(client) ) & BITZONE_PEACEFULL ) {
		ITEM_CANCEL(client, item_id);
		CPrintToChat(client, "" ...MOD_TAG... " Cet objet est interdit où vous êtes.");
		return Plugin_Handled;
	}
	
	if( !IsValidClient(target) || !rp_IsEntitiesNear(client, target) ) {
		ITEM_CANCEL(client, item_id);
		return Plugin_Handled;
	}
	if( !rp_IsTutorialOver(target) ) {
		ITEM_CANCEL(client, item_id);
		return Plugin_Handled;
	}
	if( rp_GetClientFloat(client, fl_LastPoison) > GetGameTime() ) {
		ITEM_CANCEL(client, item_id);
		CPrintToChat(client, "" ...MOD_TAG... " Cette personne semble être temporairement immunisé.");
		return Plugin_Handled;
	}
	
	rp_SetClientInt(client, i_LastAgression, GetTime());
	ServerCommand("sm_effect_particles %d Trail7 11 weapon_bone", client);
	CPrintToChat(client, "" ...MOD_TAG... " Vous avez empoisonné %N.", target);
	CPrintToChat(target, "" ...MOD_TAG... " Vous avez été empoisonné.");
	rp_ClientPoison(target, 120.0, client);
	rp_ClientAggroIncrement(client, target, 1000);
	rp_ClientOverlays(target, o_Action_Poison, 10.0);
	
	return Plugin_Handled;
}
public Action Cmd_ItemAntiPoison(int args) {
	
	int client = GetCmdArgInt(1);
	
	if( rp_GetClientInt(client, i_Sickness) ) {
		CPrintToChat(client, "" ...MOD_TAG... " Vous êtes maintenant guéri et immunisé pour 24 minutes.");
		
		if( rp_GetClientFloat(client, fl_LastPoison) > 0 && rp_GetClientFloat(client, fl_LastPoison)+1.0 >= GetGameTime() ) {
			rp_IncrementSuccess(client, success_list_immune);
		}
		
		rp_SetClientFloat(client, fl_LastPoison, GetGameTime() + 24.0 * 60.0);
	}
	else {
		ITEM_CANCEL(client, GetCmdArgInt(args));
	}
	rp_SetClientInt(client, i_Sickness, 0);
}
public Action Cmd_ItemFullHeal(int args) {
	int client = GetCmdArgInt(1);
	int heal = GetClientHealth(client);
	int max_heal = Entity_GetMaxHealth(client);
	int diff = (max_heal-heal);
	if( diff > 0 ) {
		SetEntityHealth(client, Entity_GetMaxHealth(client));
		CPrintToChat(client, "" ...MOD_TAG... " Vous avez récupéré %i HP.", diff);
	}
	
	g_iSuccess_last_faster_dead[client] = GetTime();
	
}
public Action Cmd_ItemProtImmu(int args) {
	
	int client = GetCmdArgInt(1);
	
	rp_SetClientBool(client, b_HasProtImmu, true);
	CPrintToChat(client, "" ...MOD_TAG... " Vous bénéficiez maintenant d'une protection immunitaire.");
	rp_HookEvent(client, RP_OnAssurance,	fwdAssurance2);
	return Plugin_Handled;
}
public Action fwdAssurance2(int client, int& amount) {
	amount += 250;
	return Plugin_Changed;
}
public Action Cmd_ItemRespawn(int args) {
	
	int client = GetCmdArgInt(1);
	int vendeur = GetCmdArgInt(2);
	int item_id = GetCmdArgInt(args);
	
	if( IsPlayerAlive(client) ) {
		return Plugin_Handled;
	}
	if( IsClientSourceTV(client) )
		return Plugin_Handled;
		
	if( !rp_GetClientBool(client, b_MayUseUltimate) ) {
		
		float prix = float(rp_GetItemInt(item_id, item_type_prix));
		float reduc = prix / 100.0 * float(rp_GetClientInt(vendeur, i_Reduction));
		float taxe = rp_GetItemFloat(item_id, item_type_taxes);
		
		rp_ClientMoney(vendeur, i_AddToPay, -RoundFloat((prix * taxe) - reduc));
		rp_ClientMoney(client, i_Bank, RoundFloat(prix - reduc));
		
		rp_SetJobCapital(11, rp_GetJobCapital(11) - RoundFloat(prix * (1.0 - taxe)));
		
		rp_SetClientStat(vendeur, i_MoneyEarned_Sales, rp_GetClientStat(vendeur, i_MoneyEarned_Sales) - RoundFloat((prix * taxe) - reduc));
		
		CPrintToChat(client, "" ...MOD_TAG... " Vous ne pouvez pas utiliser cet objet pour le moment.");
		return Plugin_Handled;
	}
	
	int ragdoll = GetEntPropEnt(client, Prop_Send, "m_hRagdoll");
	
	if( !IsValidEdict(ragdoll) )
		return Plugin_Handled;
	if( !IsValidEntity(ragdoll) )
		return Plugin_Handled;
	
	float vecOrigin[3];
	GetEntPropVector(ragdoll, Prop_Send, "m_vecOrigin", vecOrigin);
	
	
	CS_RespawnPlayer(client);
	SetEntityHealth(client, 500);
	rp_SetClientInt(client, i_Kevlar, 250);
	
	g_iSuccess_last_faster_dead[client] = GetTime();
	
	rp_ClientTeleport(client, vecOrigin);
	
	rp_SetClientBool(client, b_MayUseUltimate, false);
	CreateTimer(15.0, AllowUltimate, client);
	
	return Plugin_Handled;
}
public Action Cmd_ItemCureDesintox(int args) { //Permet de devenir sobre si on est saoul
	
	int client = GetCmdArgInt(1);

	if( rp_GetClientFloat(client, fl_Alcool) ) { //Si le taux d'alcool n'est pas nul
		CPrintToChat(client, "" ...MOD_TAG... " Vous êtes maintenant sobre.");
		rp_SetClientFloat(client, fl_Alcool, 0.0001);
	}
	else {
		CPrintToChat(client, "" ...MOD_TAG... " Vous n'êtes pas saoul.");
		ITEM_CANCEL(client, GetCmdArgInt(args));
	}
}
// ----------------------------------------------------------------------------
public Action Cmd_ItemAdrenaline(int args) {
	
	int client = GetCmdArgInt(1);
	int item_id = GetCmdArgInt(args);
	
	if( !rp_GetClientBool(client, b_MayUseUltimate) ) {
		if( item_id > 0 ) {
			ITEM_CANCEL(client, item_id);
		}
		CPrintToChat(client, "" ...MOD_TAG... " Vous ne pouvez pas utiliser cet objet pour le moment.");
		return Plugin_Handled;
	}
	
	if( rp_GetClientBool(client, b_Drugged) ) {
		if( item_id > 0 ) {
			ITEM_CANCEL(client, item_id);
		}
		CPrintToChat(client, "" ...MOD_TAG... " Vous êtes déjà drogué.");
		return Plugin_Handled;
	}
	
	for (float i = 0.0; i <= 10.0; i+= 0.2) {
		rp_HookEvent(client, RP_PostPlayerPhysic, fwdAdrenalineSpeed, i);
		rp_HookEvent(client, RP_PostGiveDamageWeapon, fwdBerserk, i);
		rp_HookEvent(client, RP_PostTakeDamageWeapon, fwdBerserk2, i);
	}
	
	ServerCommand("sm_effect_particles %d Trail8 11 weapon_hand_R", client);
	
	rp_SetClientBool(client, b_Drugged, true);	
	CreateTimer(10.5, ItemDrugStop, client);
	rp_SetClientBool(client, b_MayUseUltimate, false);
	
	
	if( rp_IsInPVP(client) || GetClientTeam(client) == CS_TEAM_CT) {
		CreateTimer(45.0, AllowUltimate, client);
	}
	else{
		CreateTimer(30.0, AllowUltimate, client);
	}
	
	return Plugin_Handled;
}
public Action AllowUltimate(Handle timer, any client) {
	rp_SetClientBool(client, b_MayUseUltimate, true);
}
public Action fwdAdrenalineSpeed(int client, float& speed, float& gravity) {
	speed -= 0.02;
	gravity += 0.02;
	
	if( speed <= 0.25 ) {
		speed = 0.25;
		return Plugin_Stop;
	}
	
	return Plugin_Changed;
}
public Action fwdAdrenalineColor(int client, int color[4]) {
	
	color[0] += 40;
	color[1] -= 10;
	color[2] -= 10;
	color[3] += 3;
	
	return Plugin_Changed;
}
public Action ItemDrugStop(Handle time, any client) {
	rp_SetClientBool(client, b_Drugged, false);
}
public Action fwdBerserk(int attacker, int victim, float &damage, int wepID, float pos[3]) {
	damage *= 1.05;
	
	return Plugin_Changed;
}
public Action fwdBerserk2(int attacker, int victim, float &damage, int wepID, float pos[3]) {
	
	damage *= 1.0125;
	
	return Plugin_Changed;
}
// ----------------------------------------------------------------------------
public Action Cmd_ItemHealBox(int args) {
	int client = GetCmdArgInt(1);
	
	if( BuildingHealBox(client) == 0 ) {
		int item_id = GetCmdArgInt(args);
		
		ITEM_CANCEL(client, item_id);
	}
}
public Action fwdOnPlayerBuild(int client, float& cooldown) {
	if( rp_GetClientJobID(client) != 11 )
		return Plugin_Continue;
	
	int ent = BuildingHealBox(client);
	rp_SetBuildingData(ent, BD_FromBuild, 1);
	
	if( ent > 0 ) {
		rp_SetClientStat(client, i_TotalBuild, rp_GetClientStat(client, i_TotalBuild)+1);
		rp_ScheduleEntityInput(ent, 300.0, "Kill");
		cooldown = 30.0;
	}
	else {
		cooldown = 3.0;
	}
	return Plugin_Stop;
}

int BuildingHealBox(int client) {
	
	if( !rp_IsBuildingAllowed(client) )
		return 0;
	
	char classname[64], tmp[64];
	Format(classname, sizeof(classname), "rp_healbox");
	
	float vecOrigin[3], vecOrigin2[3];
	GetClientAbsOrigin(client, vecOrigin);
	
	for(int i=1; i<=2048; i++) {
		if( !IsValidEdict(i) )
			continue;
		if( !IsValidEntity(i) )
			continue;
			
		GetEdictClassname(i, tmp, 63);
		
		if( StrEqual(classname, tmp) && rp_GetBuildingData(i, BD_owner) == client ) {
			CPrintToChat(client, "" ...MOD_TAG... " Vous avez déjà une healbox.");
			return 0;
		}
		if( StrEqual(tmp, "rp_healbox") ) {
			Entity_GetAbsOrigin(i, vecOrigin2);
			if( GetVectorDistance(vecOrigin, vecOrigin2) < 600 ) {
				CPrintToChat(client, "" ...MOD_TAG... " Il existe une autre healbox à proximité.");
				return 0;
			}
		}
	}
	
	CPrintToChat(client, "" ...MOD_TAG... " Construction en cours...");
	
	EmitSoundToAllAny("player/ammo_pack_use.wav", client, _, _, _, 0.66);
	
	int ent = CreateEntityByName("prop_physics");
	
	DispatchKeyValue(ent, "classname", classname);
	DispatchKeyValue(ent, "model", MODEL_HEALBOX);
	DispatchSpawn(ent);
	ActivateEntity(ent);
	
	SetEntityModel(ent,MODEL_HEALBOX);
	SetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity", client);
	SetEntProp( ent, Prop_Data, "m_takedamage", 2);
	SetEntProp( ent, Prop_Data, "m_iHealth", 1000);
	
	
	TeleportEntity(ent, vecOrigin, NULL_VECTOR, NULL_VECTOR);
	
	SetEntityRenderMode(ent, RENDER_NONE);
	ServerCommand("sm_effect_fading \"%i\" \"2.5\" \"0\"", ent);
	
	rp_HookEvent(client, RP_PrePlayerPhysic, fwdFrozen, 3.0);
	SetEntityMoveType(ent, MOVETYPE_NONE);
	
	
	rp_SetBuildingData(ent, BD_started, GetTime());
	rp_SetBuildingData(ent, BD_owner, client );
	rp_SetBuildingData(ent, BD_FromBuild, 0);
	
	CreateTimer(3.0, BuildingHealBox_post, ent);
	return ent;
	
}
public Action BuildingHealBox_post(Handle timer, any entity) {
	
	if( !IsValidEdict(entity) && !IsValidEntity(entity) )
		return Plugin_Handled;
	
	if( rp_IsInPVP(entity) ) {
		rp_ClientColorize(entity);
	}
	
	SetEntProp( entity, Prop_Data, "m_takedamage", 2);
	SetEntProp( entity, Prop_Data, "m_iHealth", 1000);
	HookSingleEntityOutput(entity, "OnBreak", BuildingHealBox_break);
	
	CreateTimer(1.0, Frame_HealBox, EntIndexToEntRef(entity));
	
	return Plugin_Handled;
}
public void BuildingHealBox_break(const char[] output, int caller, int activator, float delay) {
		
	int owner = GetEntPropEnt(caller, Prop_Send, "m_hOwnerEntity");
	
	if( IsValidClient(activator) && IsValidClient(owner) ) {
		rp_ClientAggroIncrement(activator, owner, 1000);
	}
	
	CPrintToChat(owner,"" ...MOD_TAG... " Votre HealBox a été détruite");
	
	float vecOrigin[3];
	Entity_GetAbsOrigin(caller,vecOrigin);
	TE_SetupSparks(vecOrigin, view_as<float>({0.0,0.0,1.0}),120,40);
	TE_SendToAll();
	
	//rp_Effect_Explode(vecOrigin, 100.0, 400.0, client);
}
public Action Frame_HealBox(Handle timer, any ent) {
	ent = EntRefToEntIndex(ent); if( ent == -1 ) { return Plugin_Handled; }
	
	float vecOrigin[3], vecOrigin2[3];
	Entity_GetAbsOrigin(ent, vecOrigin);
	vecOrigin[2] += 12.0;
	
	bool inPvP = rp_IsInPVP(ent);
	float maxDist = 240.0;
	if( inPvP )
		maxDist = 180.0;
	
	float fallOff = (25.0 / maxDist), dist;
	int boxHeal = GetEntProp(ent, Prop_Data, "m_iHealth");
	int toHeal, heal;
	
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
		
		toHeal = RoundFloat((maxDist - dist) * fallOff);
		heal = GetClientHealth(client);
		if( heal >= 500 )
			continue;
		
		Handle trace = TR_TraceRayFilterEx(vecOrigin, vecOrigin2, MASK_SHOT, RayType_EndPoint, FilterToOne, ent);
		
		if( TR_DidHit(trace) ) {
			if( TR_GetEntityIndex(trace) != client ) {
				CloseHandle(trace);
				continue;
			}
		}
		
		CloseHandle(trace);
		
		if( inPvP || rp_IsInPVP(client) )
			heal += (toHeal/2);
		else
			heal += toHeal;
		
		boxHeal -= toHeal;
		
		if( heal > 500 )
			heal = 500;
		
		rp_Effect_Particle(client, "blood_pool");		
		SetEntityHealth(client, heal);
	}
	boxHeal += 10;
	if( boxHeal > 2500 )
		boxHeal = 2500;
	if( !inPvP )
		boxHeal += Math_GetRandomInt(10, 30);
	
	SetEntProp(ent, Prop_Data, "m_iHealth", boxHeal);
	
	rp_Effect_Particle(ent, "beamring_heal", 0.5);
	
	CreateTimer(1.0, Frame_HealBox, EntIndexToEntRef(ent));
	return Plugin_Handled;
}
