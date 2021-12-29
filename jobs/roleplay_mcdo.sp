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
#include <colors_csgo>	// https://forums.alliedmods.net/showthread.php?p=2205447#post2205447
#include <smlib>		// https://github.com/bcserv/smlib
#include <emitsoundany> // https://forums.alliedmods.net/showthread.php?t=237045
#include <givenameditem>

#pragma newdecls required
#include <roleplay.inc>	// https://www.ts-x.eu

public Plugin myinfo = {
	name = "Jobs: Mc'Do", author = "KoSSoLaX",
	description = "RolePlay - Jobs: Mc'Donalds",
	version = __LAST_REV__, url = "https://www.ts-x.eu"
};

int g_cBeam, g_cGlow, g_nbMdItems;
bool g_eMwAct[2048];

char g_szKnife[][] = {
	"weapon_knife",
	"weapon_knife_css",
	"weapon_bayonet",
	"weapon_knife_flip",
	"weapon_knife_gut",
	"weapon_knife_karambit",
	"weapon_knife_m9_bayonet",
	"weapon_knife_tactical",
	"weapon_knife_butterfly",
	"weapon_knife_falchion",
	"weapon_knife_push",
	"weapon_knife_survival_bowie",
	"weapon_knife_ursus",
	"weapon_knife_gypsy_jackknife",
	"weapon_knife_stiletto",
	"weapon_knife_widowmaker",
	"weapon_knife_canis",
	"weapon_knife_cord",
	"weapon_knife_skeleton",
	"weapon_knife_outdoor"
};

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
	LoadTranslations("roleplay.mcdo.phrases");
	
	RegServerCmd("rp_quest_reload", Cmd_Reload);
	RegServerCmd("rp_item_hamburger",	Cmd_ItemHamburger,		"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_banane",		Cmd_ItemBanane,			"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_knife",		Cmd_ItemKnife,			"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_microwaves",	Cmd_ItemMicroWave,		"RP-ITEM",	FCVAR_UNREGISTERED);
	
	g_nbMdItems = -1;
	for (int j = 1; j <= MaxClients; j++)
		if( IsValidClient(j) )
			OnClientPostAdminCheck(j);
	
	
	char classname[64];
	for (int i = MaxClients; i <= 2048; i++) {
		if( !IsValidEdict(i) )
			continue;
		if( !IsValidEntity(i) )
			continue;
		
		GetEdictClassname(i, classname, sizeof(classname));
		if( StrEqual(classname, "rp_microwave") ) {
			
			rp_SetBuildingData(i, BD_started, GetTime());
			rp_SetBuildingData(i, BD_owner, GetEntPropEnt(i, Prop_Send, "m_hOwnerEntity") );
			
			CreateTimer(Math_GetRandomFloat(0.25, 5.0), BuildingMicrowave_post, i);
		}
	}
}
public Action Cmd_ItemMicroWave(int args) {
	int client = GetCmdArgInt(1);
	
	if( BuildingMicrowave(client) == 0 ) {
		int item_id = GetCmdArgInt(args);
		
		ITEM_CANCEL(client, item_id);
	}
}
public Action Cmd_ItemKnife(int args) {
	int client = GetCmdArgInt(1);
	rp_ClientGiveItem(client, ITEM_KNIFE);
	CreateTimer(0.25, task_KNIFE, client);
}

public Action task_KNIFE(Handle timer, any client) {
	Handle menu = CreateMenu(MenuKnife);
	SetMenuTitle(menu, "%T\n ", "Knife_Menu", client);
	
	char tmp[128];
	
	for (int i = 0; i < sizeof(g_szKnife); i++) {
		Format(tmp, sizeof(tmp), "%T", g_szKnife[i], client);
		AddMenuItem(menu, g_szKnife[i], tmp);
	}
	
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_DURATION);
}

int g_iSkinID[65];

public int MenuKnife(Handle p_hItemMenu, MenuAction p_oAction, int client, int p_iParam2) {
	
	if (p_oAction == MenuAction_Select && client != 0) {
		char option[64];
		GetMenuItem(p_hItemMenu, p_iParam2, option, sizeof(option));
		
		if (rp_GetClientItem(client, ITEM_KNIFE) <= 0) {
			char tmp[128];
			rp_GetItemData(ITEM_KNIFE, item_type_name, tmp, sizeof(tmp));
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_ItemMissing", client, tmp);
			return;
		}
		
		if( Client_HasWeapon(client, "weapon_knife") ) {
			Client_RemoveWeapon(client, "weapon_knife");
		}
		
		g_iSkinID[client] = GiveNamedItem_GetItemDefinitionByClassname(option);
		int wpn = GivePlayerItem(client, option);
		
		FakeClientCommand(client, "use weapon_knife; use weapon_bayonet"); 
		rp_ClientGiveItem(client, ITEM_KNIFE, -1);
	}
	else if (p_oAction == MenuAction_End) {
		CloseHandle(p_hItemMenu);
	}
}
public void OnGiveNamedItemEx(int client, const char[] Classname) {
	if(g_iSkinID[client] > 0 && GiveNamedItemEx.IsClassnameKnife(Classname)) {
		GiveNamedItemEx.ItemDefinition = g_iSkinID[client];
		g_iSkinID[client] = 0;
	}
}

public Action RP_OnPlayerGotPay(int client, int salary, int & topay, bool verbose) {
	
	int vit_level = GetLevelFromVita(rp_GetClientFloat(client, fl_Vitality));
	
	if( vit_level > 0 ) {
		float multi = GetVitaFactor(vit_level);
		
		int sum = RoundToCeil(float(salary) * multi) - salary;
		
		if( verbose )
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Pay_Bonus_Vitality", client, vit_level, sum);
		
		topay += sum;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}
public void OnMapStart() {
	PrecacheSoundAny("ambient/tones/equip2.wav");
	PrecacheSoundAny("ambient/machines/lab_loop1.wav");
	g_cBeam = PrecacheModel("materials/sprites/laserbeam.vmt", true);
	g_cGlow = PrecacheModel("materials/sprites/glow01.vmt", true);
}
public void OnClientPostAdminCheck(int client){
	rp_HookEvent(client, RP_OnPlayerBuild,	fwdOnPlayerBuild);
}
// ------------------------------------------------------------------------------
public Action fwdOnPlayerBuild(int client, float& cooldown){
	if( rp_GetClientJobID(client) != 21 )
		return Plugin_Continue;
	
	int ent = BuildingMicrowave(client);
	rp_SetBuildingData(ent, BD_FromBuild, 1);
	SetEntProp(ent, Prop_Data, "m_iHealth", GetEntProp(ent, Prop_Data, "m_iHealth")/5);
	Entity_SetMaxHealth(ent, Entity_GetHealth(ent));
	
	if( ent > 0 )
		rp_SetClientStat(client, i_TotalBuild, rp_GetClientStat(client, i_TotalBuild)+1);

	cooldown = 3.0;
	return Plugin_Stop;
}
int BuildingMicrowave(int client) {
	
	if( !rp_IsBuildingAllowed(client) )
		return 0;
	
	char classname[64], tmp[64];
	Format(classname, sizeof(classname), "rp_microwave");
	
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
	}
	
	float vecOrigin[3];
	GetClientAbsOrigin(client, vecOrigin);
	
	EmitSoundToAllAny("player/ammo_pack_use.wav", client, _, _, _, 0.66);
	
	int ent = CreateEntityByName("prop_physics");
	
	DispatchKeyValue(ent, "classname", classname);
	DispatchKeyValue(ent, "model", "models/props/cs_office/microwave.mdl");
	DispatchSpawn(ent);
	ActivateEntity(ent);
	
	SetEntityModel(ent,"models/props/cs_office/microwave.mdl");
	SetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity", client);
	SetEntProp( ent, Prop_Data, "m_takedamage", 2);
	SetEntProp( ent, Prop_Data, "m_iHealth", 25000);
	
	
	TeleportEntity(ent, vecOrigin, NULL_VECTOR, NULL_VECTOR);
	
	SetEntityRenderMode(ent, RENDER_NONE);
	ServerCommand("sm_effect_fading \"%i\" \"2.5\" \"0\"", ent);
	
	SetEntityMoveType(client, MOVETYPE_NONE);
	SetEntityMoveType(ent, MOVETYPE_NONE);
	
	
	rp_SetBuildingData(ent, BD_started, GetTime());
	rp_SetBuildingData(ent, BD_owner, client );
	rp_SetBuildingData(ent, BD_FromBuild, 0);
	Entity_SetMaxHealth(ent, Entity_GetHealth(ent));
	
	g_eMwAct[ent] = true;
	CreateTimer(3.0, BuildingMicrowave_post, ent);
	return ent;
	
}
public Action BuildingMicrowave_post(Handle timer, any entity) {
	if( !IsValidEdict(entity) && !IsValidEntity(entity) )
		return Plugin_Handled;
	int client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	int time;
	int job = rp_GetClientInt(client, i_Job);
	switch(job){
		case 21: time = 55;
		case 22: time = 60;
		case 23: time = 65;
		case 24: time = 70;
		case 25: time = 75;
		case 26: time = 80;
		default: time = 90;
	}

	if( rp_GetBuildingData(entity, BD_FromBuild) == 1 && rp_GetZoneInt(rp_GetPlayerZone(entity), zone_type_type) != 21 ) {
		time *= 2;
	}
	
	rp_SetBuildingData(entity, BD_max, time);
	rp_SetBuildingData(entity, BD_count, 0);

	SetEntityMoveType(client, MOVETYPE_WALK);
	
	if( rp_IsInPVP(entity) ) {
		rp_ClientColorize(entity);
	}
	
	SetEntProp( entity, Prop_Data, "m_takedamage", 2);
	HookSingleEntityOutput(entity, "OnBreak", BuildingMicrowave_break);
	SDKHook(entity, SDKHook_OnTakeDamage, DamageMachine);
	
	CreateTimer(1.0, Frame_Microwave, entity);
	rp_HookEvent(client, RP_OnPlayerUse, fwdOnPlayerUse);
	
	return Plugin_Handled;
}
public Action DamageMachine(int victim, int &attacker, int &inflictor, float &damage, int &damagetype) {
	if( !Entity_CanBeBreak(victim, attacker) ) {
		damage = 0.0;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}
public void BuildingMicrowave_break(const char[] output, int caller, int activator, float delay) {
	
	int owner = GetEntPropEnt(caller, Prop_Send, "m_hOwnerEntity");
	
	if( IsValidClient(activator) && IsValidClient(owner) ) {
		rp_ClientAggroIncrement(activator, owner, 1000);
	}
	
	if( IsValidClient(owner) ) {
		char tmp[128];
		GetEdictClassname(caller, tmp, sizeof(tmp));
		CPrintToChat(owner, "" ...MOD_TAG... " %T", "Build_Destroyed", owner, tmp);
		rp_UnhookEvent(owner, RP_OnPlayerUse, fwdOnPlayerUse);
	}
	
	float vecOrigin[3];
	Entity_GetAbsOrigin(caller,vecOrigin);
	TE_SetupSparks(vecOrigin, view_as<float>({0.0,0.0,1.0}),120,40);
	TE_SendToAll();
	//rp_Effect_Explode(vecOrigin, 200.0, 600.0, activator, "micro_onde");
}
public Action fwdOnPlayerUse(int client) {
	static char tmp[64], tmp2[64];
	static float vecOrigin[3],vecOrigin2[3];
	GetClientAbsOrigin(client, vecOrigin);


	Format(tmp2, sizeof(tmp2), "rp_microwave");

	for(int i=1; i<=2048; i++) {
		if( !IsValidEdict(i) )
			continue;
		if( !IsValidEntity(i) )
			continue;
		
		GetEdictClassname(i, tmp, sizeof(tmp));
		if(g_eMwAct[i])
			continue;
		
		if( StrEqual(tmp, tmp2) && rp_GetBuildingData(i, BD_owner) == client ) {
			Entity_GetAbsOrigin(i, vecOrigin2);
			if( GetVectorDistance(vecOrigin, vecOrigin2) <= 50 ) {
				int time = rp_GetBuildingData(i, BD_count);
				int maxtime = rp_GetBuildingData(i, BD_max);
				if( time >= maxtime &&  rp_GetBuildingData( i, BD_owner )) {
					rp_SetBuildingData(i, BD_count, 0);
					
					if( rp_GetBuildingData(i, BD_FromBuild) == 1 && rp_GetZoneInt(rp_GetPlayerZone(i), zone_type_type) == 21)
						giveHamburger(client, 2);
					else if( rp_GetPlayerZoneAppart(i) > 0 )
						giveHamburger(client, 1);
					else
						giveHamburger(client, 1);
				}
				g_eMwAct[i] = true;
				CreateTimer(1.0, Frame_Microwave, i);
			}
		}
	}
	return Plugin_Continue;
}
public Action Frame_Microwave(Handle timer, any ent) {
	if(!IsValidEdict(ent) || !IsValidEntity(ent)){
		StopSoundAny(ent, SNDCHAN_AUTO, "ambient/machines/lab_loop1.wav");
		return Plugin_Handled;
	}
	
	int owner = rp_GetBuildingData(ent, BD_owner);
	int time = rp_GetBuildingData(ent, BD_count);
	int maxtime = rp_GetBuildingData(ent, BD_max);
	if(time >= maxtime){
		EmitSoundToAllAny("ambient/tones/equip2.wav", ent);
		CPrintToChat(owner, "" ...MOD_TAG... " %T", "Microwave_Ready", owner);
		g_eMwAct[ent] = false;
		return Plugin_Handled;
	}
	if(time == 0){
		EmitSoundToAllAny("ambient/machines/lab_loop1.wav", ent, _, _, _, 0.33);
		 SDKHooks_TakeDamage(ent, ent, ent, 7.0);
	}
	
	if( rp_GetClientInt(owner, i_TimeAFK) <= 60 ) {
		rp_SetBuildingData(ent, BD_count, ++time);
	}
	CreateTimer(1.0, Frame_Microwave, ent);
	return Plugin_Handled;
}
void giveHamburger(int client, int amount){
	char tmp[128];
	
	if( g_nbMdItems == -1 ) {
		int jobID;
		for(int i = 0; i < MAX_ITEMS; i++){
			if( rp_GetItemInt(i, item_type_prix) <= 0 )
				continue;
			if( rp_GetItemInt(i, item_type_auto) == 1 )
				continue;
			jobID = rp_GetItemInt(i, item_type_job_id);
			if(jobID != 21)
				continue;
			
			rp_GetItemData(i, item_type_extra_cmd, tmp, sizeof(tmp));
			if( StrEqual(tmp, "rp_item_microwaves") )
				continue;
			g_nbMdItems++;
		}
	}
	
	int mci = Math_GetRandomInt(0, g_nbMdItems);
	int j = 0, jobID;	
	for(int i = 0; i < MAX_ITEMS; i++){
		if( rp_GetItemInt(i, item_type_prix) <= 0 )
			continue;
		if( rp_GetItemInt(i, item_type_auto) == 1 )
			continue;
		jobID = rp_GetItemInt(i, item_type_job_id);
		if(jobID != 21)
			continue;
		
		rp_GetItemData(i, item_type_extra_cmd, tmp, sizeof(tmp));
		if( StrEqual(tmp, "rp_item_microwaves") )
			continue;

		if(mci == j){
			rp_GetItemData(i, item_type_name, tmp, sizeof(tmp));
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Item_Take", client, amount, tmp);
			rp_ClientGiveItem(client, i, amount);
			break;
		}
		j++;
	}
}
public Action Cmd_ItemHamburger(int args) {
	char arg1[12], classname[64];
	GetCmdArg(1, arg1, 11);
	
	int client = GetCmdArgInt(2);
	int item_id = GetCmdArgInt(args);
	int itemCount = rp_GetClientItem(client, item_id);
	
	if( StrEqual(arg1, "vital") ) {
	
		if( itemCount >= 9 ) {
			rp_ClientGiveItem(client, item_id, 1);
			
			Handle dp;
			CreateDataTimer(0.1, Delay_MenuVital, dp, TIMER_DATA_HNDL_CLOSE);
			WritePackCell(dp, client);
			WritePackCell(dp, item_id);
		}
		else {
			float vita = rp_GetClientFloat(client, fl_Vitality);
		
			rp_SetClientFloat(client, fl_Vitality, vita + 256.0);
			ServerCommand("sm_effect_particles %d Trail12 5 facemask", client);
			FakeClientCommand(client, "say /vita");
		}
	}
	if( StrEqual(arg1, "energy") ) {
		rp_SetClientFloat(client, fl_Energy, 100.0);
	}
	
	if( StrEqual(arg1, "fat") ) {
		float size = rp_GetClientFloat(client, fl_Size);
		
		if( size >= 1.65 && rp_GetClientInt(client, i_Kevlar) == 100 ) {
			ITEM_CANCEL(client, item_id);
			char item_name[128];
			rp_GetItemData(item_id, item_type_name, item_name, sizeof(item_name));
			
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_ItemCannotBeUsedForNow", client, item_name);
			return Plugin_Handled;
		}
		
		rp_SetClientInt(client, i_Kevlar, 100);
		
		if( size < 1.6 ) {
			rp_SetClientFloat(client, fl_Size, size + 0.05);
			SetEntPropFloat(client, Prop_Send, "m_flModelScale", size + 0.05);
		}
	}
	else if( StrEqual(arg1, "mac") ) {
		
		
		if( item_id > 0 && !rp_GetClientBool(client, b_MayUseUltimate) ) {
			ITEM_CANCEL(client, item_id);
			char item_name[128];
			rp_GetItemData(item_id, item_type_name, item_name, sizeof(item_name));
			
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_ItemCannotBeUsedForNow", client, item_name);
			return Plugin_Handled;
		}
				
		rp_SetClientFloat(client, fl_Reflect, GetGameTime() + 5.0);
		
		float vecTarget[3];
		GetClientAbsOrigin(client, vecTarget);
		
		TE_SetupBeamRingPoint(vecTarget, 10.0, 300.0, g_cBeam, g_cGlow, 0, 15, 0.5, 50.0, 0.0, {255, 255, 0, 50}, 10, 0);
		TE_SendToAll();
		
		ServerCommand("sm_effect_particles %d Trail5 5 footplant_L", client);
		ServerCommand("sm_effect_particles %d Trail5 5 footplant_R", client);
		
		if( item_id > 0 ) {
			rp_SetClientBool(client, b_MayUseUltimate, false);
			if( rp_IsInPVP(client) ) {			
				if( rp_GetClientGroupID(client) == rp_GetCaptureInt(cap_bunker) )
					CreateTimer(10.0, AllowUltimate, client);
				else
					CreateTimer(60.0, AllowUltimate, client);
			}
			else{
				CreateTimer(20.0, AllowUltimate, client);
			}
		}
	}
	else if( StrEqual(arg1, "chicken") ) {
		
		if( Math_GetRandomInt(1, 4) == 4 ) {
			GivePlayerItem(client, "weapon_mac10");
		}
		else {
			int ent = CreateEntityByName("chicken");
			DispatchSpawn(ent);
			float vecOrigin[3];
			GetClientAbsOrigin(client, vecOrigin);
			vecOrigin[2] += 20.0;
			
			TeleportEntity(ent, vecOrigin, NULL_VECTOR, NULL_VECTOR);
		}
	}
	else if( StrContains(arg1, "happy") == 0 ) {
		
		int amount = 0;
		
		int iItemRand[MAX_ITEMS*2];
		
		int jobID;
		char cmd[128];
		bool lucky = rp_IsClientLucky(client);
		
		
		for(int i = 0; i < MAX_ITEMS; i++) {
			
			if( rp_GetItemInt(i, item_type_prix) <= 0 )
				continue;
			if( rp_GetItemInt(i, item_type_auto) == 1 )
				continue;
			
			jobID = rp_GetItemInt(i, item_type_job_id);
			
			if( jobID <= 0 || jobID == 61 || jobID == 91 ) // Aucun, Appart, Mafia
				continue;
			
			rp_GetItemData(i, item_type_extra_cmd, cmd, sizeof(cmd));
			if( StrEqual(cmd, "UNKNOWN")) // UNKNOWN
				continue;
			if( StrContains(cmd, "rp_chirurgie") == 0 )
				continue;
			if( StrContains(cmd, "rp_item_raw") == 0 )
				continue;
			if( rp_GetItemInt(i, item_type_prix) == 0 )
				continue;
			
			rp_GetItemData(i, item_type_name, cmd, sizeof(cmd));
			if( StrContains(cmd, "BETA", false) >= 0 )
				continue;
			if( StrContains(cmd, "sactiv", false) >= 0 )
				continue;
			
			iItemRand[amount] = i;
			amount++;
			
			if( StrContains(cmd, "rp_giveitem weapon_") == 0 ) { // 2x plus de chance d'avoir une arme
				iItemRand[amount] = i;
				amount++;
			}
			if( lucky && rp_GetItemInt(i, item_type_prix) > 2000 ) { // 2x plus de chance... Si on a de la chance grâce aux portes bonheures
				iItemRand[amount] = i;
				amount++;
			}
		}
		
		int rand = iItemRand[ Math_GetRandomInt(0, amount-1) ];
		rp_ClientGiveItem(client, rand, 1, true);
		
		rp_GetItemData(rand, item_type_name, cmd, sizeof(cmd));
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Item_Free", client, 1, cmd);
		
		if( rand == GetCmdArgInt(args) && StrEqual(arg1, "happymeal") )
			rp_IncrementSuccess(client, success_list_mcdo);
	}
	else if( StrEqual(arg1, "box") ) { // TODO: Move to roleplay_armurerie
		
		int amount = 0;
		int iItemRand[MAX_ITEMS];
		bool lucky = rp_IsClientLucky(client);
		
		for(int i = 0; i < MAX_ITEMS; i++) {
			if( rp_GetItemInt(i, item_type_job_id) != 111 )
				continue;			
			
			iItemRand[amount] = i;
			amount++;
			
			if( !lucky && rp_GetItemInt(i, item_type_prix) <= 1000 ) { // 2x plus de chance... Si on a de la chance grâce aux portes bonheures
				iItemRand[amount] = i;
				amount++;
			}
		}
		
		char cmd[128];
		int rand = iItemRand[ Math_GetRandomInt(0, amount-1) ];
		rp_ClientGiveItem(client, rand, 1, true);
		rp_GetItemData(rand, item_type_name, cmd, sizeof(cmd));
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Item_Free", client, 1, cmd);
	}
	else if( StrEqual(arg1, "drugs") ) { // TODO: Move to roleplay_dealer
		
		int amount = 0;		
		int iItemRand[MAX_ITEMS];
		char cmd[128];
		
		for(int i = 0; i < MAX_ITEMS; i++) {
			
			rp_GetItemData(i, item_type_extra_cmd, cmd, sizeof(cmd));
			if( StrContains(cmd, "rp_item_drug") != 0 )
				continue;
			
			iItemRand[amount] = i;
			amount++;
		}
		
		int rand = iItemRand[ Math_GetRandomInt(0, amount-1) ];
		int rnd = 7+Math_GetRandomPow(1, 5);
		rp_ClientGiveItem(client, rand, rnd, true);
		
		rp_GetItemData(rand, item_type_name, cmd, sizeof(cmd));
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Item_Free", client, rnd, cmd);
	}
	else if( StrEqual(arg1, "spacy") ) {
		
		int wepid = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if( !IsValidEntity(wepid) ) {
			ITEM_CANCEL(client, item_id);
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_KnifeInHands");
			return Plugin_Handled;
		}
		
		GetEdictClassname(wepid, classname, sizeof(classname));
		if( !StrEqual(classname, "weapon_knife") ) {
			ITEM_CANCEL(client, item_id);
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_KnifeInHands");
			return Plugin_Handled;
		}
		
		if( !rp_SetClientKnifeType(client, ball_type_fire) ) {
			ITEM_CANCEL(client, item_id);
			char item_name[128];
			rp_GetItemData(item_id, item_type_name, item_name, sizeof(item_name));
			
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_ItemCannotBeUsedForNow", client, item_name);
			return Plugin_Handled;
		}
	}
	return Plugin_Handled;
}
public Action Delay_MenuVital(Handle timer, Handle dp) {
	static int amountType[] =  { 1, 2, 3, 5, 10, 20, 25, 50, 100, 200, 250, 500, 1000 };
	
	ResetPack(dp);
	int client = ReadPackCell(dp);
	int itemID = ReadPackCell(dp);
	int count = rp_GetClientItem(client, itemID);
	
	Menu menu = CreateMenu(MenuVital);
	menu.SetTitle("%T\n ", "Burger_Menu", client, count);
		
	char tmp[64], tmp2[64];
	float vita = rp_GetClientFloat(client, fl_Vitality);
	
	int lvl = GetLevelFromVita(vita);
	float delta = GetVitaFromLevel(lvl + 1) - vita;
	int cpt = RoundToCeil(delta/256.0);	
	
	Format(tmp, sizeof(tmp), "%d %d", itemID, cpt);
	Format(tmp2, sizeof(tmp2), "%T", "Burger_Menu_NextLevel", client, cpt);
	menu.AddItem(tmp, tmp2, cpt <= count ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED );
	
	Format(tmp, sizeof(tmp), "%d %d", itemID, count);
	Format(tmp2, sizeof(tmp2), "%T", "Burger_Menu_All", client, count);
	menu.AddItem(tmp, tmp2);
	
		
	for (int i = 0; i < sizeof(amountType); i++) {
		if( count < amountType[i] )
			continue;
		
		Format(tmp, sizeof(tmp), "%d %d", itemID, amountType[i]);
		Format(tmp2, sizeof(tmp2), "%T", "Burger_Menu_Count", client, amountType[i]);
		
		menu.AddItem(tmp, tmp2);
	}
	
	menu.Display(client, 30);
}
public int MenuVital(Handle menu, MenuAction action, int client, int param2) {
	if( action == MenuAction_Select ) {
		char szMenuItem[64], tmp[2][8];
		GetMenuItem(menu, param2, szMenuItem, sizeof(szMenuItem));
		ExplodeString(szMenuItem, " ", tmp, sizeof(tmp), sizeof(tmp[]));
		
		int itemID = StringToInt(tmp[0]);
		int amount = StringToInt(tmp[1]);
		
		if( rp_GetClientItem(client, itemID) < amount && amount > 0 ) {
			rp_GetItemData(itemID, item_type_name, szMenuItem, sizeof(szMenuItem));
			CPrintToChat(client, ""...MOD_TAG..." %T", "Error_ItemNotEnought", client, szMenuItem);
			return;
		}
		
		rp_ClientGiveItem(client, itemID, -amount);
		
		float vita = rp_GetClientFloat(client, fl_Vitality);
		float n_vita = vita + (float(amount) * 256.0);
		
		rp_SetClientFloat(client, fl_Vitality, n_vita);
		ServerCommand("sm_effect_particles %d Trail12 5 facemask", client);
		FakeClientCommand(client, "say /vita");
	}
	else if( action == MenuAction_End ) {
		if( menu != INVALID_HANDLE )
			CloseHandle(menu);
	}
}
public Action AllowUltimate(Handle timer, any client) {

	rp_SetClientBool(client, b_MayUseUltimate, true);
}
public Action Cmd_ItemBanane(int args) {
	
	int client = GetCmdArgInt(1);
	int itemID = GetCmdArgInt(args);
	int count;
	
	char classname[64], classname2[64];
	Format(classname, sizeof(classname), "rp_banana");
	
	for (int i = MaxClients; i <= 2048; i++) {
		if( !IsValidEdict(i) )
			continue;
		GetEdictClassname(i, classname2, sizeof(classname2));
		if( StrEqual(classname, classname2) && Entity_GetOwner(i) == client) {
			count++;
			if( count >= 10 ) {
				CPrintToChat(client, ""...MOD_TAG..." %T", "Build_TooMany", client);
				ITEM_CANCEL(client, itemID);
				return Plugin_Handled;
			}
		}
	}

	float vecOrigin[3];
	GetClientAbsOrigin(client, vecOrigin);
	
	int ent = CreateEntityByName("prop_physics_override");
	
	DispatchKeyValue(ent, "classname", classname);
	DispatchKeyValue(ent, "model", "models/props/cs_italy/bananna.mdl");
	DispatchSpawn(ent);
	ActivateEntity(ent);
	
	SetEntityModel(ent, "models/props/cs_italy/bananna.mdl");
	
	SetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity", client);
	
	SetEntityRenderMode(ent, RENDER_NONE);
	
	TeleportEntity(ent, vecOrigin, NULL_VECTOR, NULL_VECTOR);
	
	Entity_SetOwner(ent, client);
	SetEntProp(ent, Prop_Data, "m_takedamage", 0);
	
	ServerCommand("sm_effect_fading \"%i\" \"0.5\" \"0\"", ent);
	rp_ScheduleEntityInput(ent, 60.0, "Kill");
	
	SDKHook(ent, SDKHook_Touch, BuildingBanana_touch);
	return Plugin_Handled;
}
public Action BuildingBanana_touch(int index, int client) {
	
	if( rp_IsValidVehicle(client) ) {
		rp_AcceptEntityInput(index, "Kill");
		return Plugin_Handled;
	}
	
	if( !IsValidClient(client) || Client_GetVehicle(client) > 0 || rp_GetClientVehicle(client) > 0 || rp_GetClientVehiclePassager(client) > 0 )
		return Plugin_Continue;
	
	rp_SetClientInt(client, i_LastAgression, GetTime());
	char sound[128];
	Format(sound, sizeof(sound), "hostage/hpain/hpain%i.wav", Math_GetRandomInt(1, 6));
	EmitSoundToAll(sound, client);

	rp_ClientDamage(client, 25, Entity_GetOwner(index));
	
	if(GetEntityFlags(client) & FL_ONGROUND) {
		
		int flags = GetEntityFlags(client);
		SetEntityFlags(client, (flags&~FL_ONGROUND) );
		SetEntPropEnt(client, Prop_Send, "m_hGroundEntity", -1);
	}
	
	float vecVelocity[3];
	vecVelocity[0] = GetRandomFloat(400.0, 500.0);
	vecVelocity[1] = GetRandomFloat(400.0, 500.0);
	vecVelocity[2] = GetRandomFloat(600.0, 800.0);
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vecVelocity);	
	
	rp_AcceptEntityInput(index, "Kill");
	SDKUnhook(index, SDKHook_Touch, BuildingBanana_touch);
	return Plugin_Continue;
}
int GetLevelFromVita(float vita) {
	if( vita <= 64.0 )
		return 0;
	
	int vit_level = RoundToFloor(Logarithm(vita, 2.0) / 2.0 - 3.0);
	if( vit_level < 0 )
		vit_level = 0;
		
	return vit_level;
}
float GetVitaFromLevel(int lvl) {
	return Pow(2.0, (float(lvl)+3.0)*2.0);
}
float GetVitaFactor(int level) {
	if( level == 0 )
		return 1.0;
	
	float vit_factor = 1.1;
	float acc = 0.0;
	
	for (int i = 0; i < level; i++) {
		vit_factor += acc;
		acc += 0.1;
	}
	
	return vit_factor;
}
