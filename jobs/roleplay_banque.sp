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

#pragma newdecls required
#include <roleplay.inc>	// https://www.ts-x.eu

public Plugin myinfo = {
	name = "Jobs: Banquier", author = "KoSSoLaX",
	description = "RolePlay - Jobs: Banquier",
	version = __LAST_REV__, url = "https://www.ts-x.eu"
};
Handle g_hEVENT;
int g_iSignPermission[2049];
ArrayList g_hSignData[2049];

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
	LoadTranslations("roleplay.banque.phrases");
	
	RegServerCmd("rp_quest_reload", Cmd_Reload);
	RegServerCmd("rp_bankcard",			Cmd_ItemBankCard,		"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_bankkey",			Cmd_ItemBankKey,		"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_bankswap",			Cmd_ItemBankSwap,		"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_assurance",	Cmd_ItemAssurance,		"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_forward",		Cmd_ItemForward,		"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_noAction",	Cmd_ItemNoAction,		"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_primal",		Cmd_ItemForward,		"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_cheque",		Cmd_ItemCheque,			"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_packdebutant",Cmd_ItemPackDebutant, 	"RP-ITEM", 	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_permi",		Cmd_ItemPermi,			"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_distrib",		Cmd_ItemDistrib,		"RP-ITEM", 	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_banksort",	Cmd_ItemBankSort,		"RP-ITEM", 	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_registre",	Cmd_ItemRegistre,		"RP-ITEM", 	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_sign",		Cmd_ItemCraftSign,		"RP-ITEM", 	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_assuVie",		Cmd_ItemAssuVie,		"RP-ITEM", 	FCVAR_UNREGISTERED);
	
	for (int i = 1; i <= MaxClients; i++)
		if( IsValidClient(i) )
			OnClientPostAdminCheck(i);
}
public void OnConfigsExecuted() {
	g_hEVENT =  FindConVar("rp_event");
}
public void OnMapStart() {
	PrecacheModel(MODEL_ATM, true);
}
public void OnClientPostAdminCheck(int client) {
	rp_HookEvent(client, RP_OnPlayerBuild,	fwdOnPlayerBuild);
	rp_HookEvent(client, RP_OnPlayerUse, fwdUse);
	rp_HookEvent(client, RP_OnPlayerHINT, fwdPlayerHINT);
	
	if( rp_GetClientBool(client, b_AssuranceVie) )
		rp_HookEvent(client, RP_OnPlayerDead, OnPlayerDeathFastRespawn);
}

public Action Cmd_ItemCraftSign(int args) {
	int client = GetCmdArgInt(1);
	int item_id = GetCmdArgInt(args);
	
	if( BuidlingSIGN(client) == 0 ) {
		ITEM_CANCEL(client, item_id);
	}
	
	return Plugin_Handled;
}

// ----------------------------------------------------------------------------
public Action Cmd_ItemPermi(int args) {
	
	char Arg1[12];
	GetCmdArg(1, Arg1, 11);
	
	int client = GetCmdArgInt(2);
	
	if( StrEqual(Arg1, "lege") ) {
		rp_SetClientBool(client, b_License1, true);
		rp_SetClientInt(client, i_StartLicense1, GetTime());
	}
	else if( StrEqual(Arg1, "lourd") ) {
		rp_SetClientBool(client, b_License2, true);
		rp_SetClientInt(client, i_StartLicense2, GetTime());
	}
	else if( StrEqual(Arg1, "vente") ) {
		rp_SetClientBool(client, b_LicenseSell, true);
	}
	
	rp_ClientSave(client);
	
	return Plugin_Handled;
}
public Action Cmd_ItemBankCard(int args) {
	
	int item_id = GetCmdArgInt(args);
	int client = GetCmdArgInt(1);

	if(rp_GetClientBool(client, b_HaveCard)){
		ITEM_CANCEL(client, item_id);
		char tmp[128];
		rp_GetItemData(item_id, item_type_name, tmp, sizeof(tmp));
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_ItemAlreadyEnable", client, tmp);
		return Plugin_Handled;
	}
	
	rp_SetClientBool(client, b_HaveCard, true);
	rp_ClientSave(client);
	
	return Plugin_Handled;
}
public Action Cmd_ItemBankSort(int args) {

	int item_id = GetCmdArgInt(args);
	int client = GetCmdArgInt(1);

	if(rp_GetClientBool(client, b_CanSort)){
		ITEM_CANCEL(client, item_id);
		char tmp[128];
		rp_GetItemData(item_id, item_type_name, tmp, sizeof(tmp));
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_ItemAlreadyEnable", client, tmp);
		return Plugin_Handled;
	}

	rp_SetClientBool(client, b_CanSort, true);
	
	return Plugin_Handled;
}
public Action Cmd_ItemBankKey(int args) {
	
	int item_id = GetCmdArgInt(args);
	int client = GetCmdArgInt(1);

	if(rp_GetClientBool(client, b_HaveAccount)){
		ITEM_CANCEL(client, item_id);
		char tmp[128];
		rp_GetItemData(item_id, item_type_name, tmp, sizeof(tmp));
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_ItemAlreadyEnable", client, tmp);
		return Plugin_Handled;
	}

	rp_SetClientBool(client, b_HaveAccount, true);
	rp_ClientSave(client);
	
	return Plugin_Handled;
}
public Action Cmd_ItemBankSwap(int args) {
	
	int item_id = GetCmdArgInt(args);
	int client = GetCmdArgInt(1);

	if(rp_GetClientBool(client, b_PayToBank)){
		ITEM_CANCEL(client, item_id);
		char tmp[128];
		rp_GetItemData(item_id, item_type_name, tmp, sizeof(tmp));
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_ItemAlreadyEnable", client, tmp);
		return Plugin_Handled;
	}

	rp_SetClientBool(client, b_PayToBank, true);
	rp_ClientSave(client);
	
	return Plugin_Handled;
}
// ----------------------------------------------------------------------------
public Action Cmd_ItemAssurance(int args) {
	
	int item_id = GetCmdArgInt(args);
	int client = GetCmdArgInt(1);
	
	if( rp_GetClientBool(client, b_FreeAssurance) ) {
		rp_IncrementSuccess(client, success_list_assurance);
	}
	else if( !rp_GetClientBool(client, b_Assurance) ) {
		rp_IncrementSuccess(client, success_list_assurance);
	}
	else{
		ITEM_CANCEL(client, item_id);
		char tmp[128];
		rp_GetItemData(item_id, item_type_name, tmp, sizeof(tmp));
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_ItemAlreadyEnable", client, tmp);
		return Plugin_Handled;
	}
	
	rp_SetClientBool(client, b_Assurance, true);
	rp_SetClientBool(client, b_FreeAssurance, false);
	
	FakeClientCommand(client, "say /assu");
	
	rp_ClientSave(client);
	
	return Plugin_Handled;
}

public Action Cmd_ItemAssuVie(int args){
	
	int item_id = GetCmdArgInt(args);
	int client = GetCmdArgInt(1);
	
	if( rp_GetClientBool(client, b_AssuranceVie) ) {
		ITEM_CANCEL(client, item_id);
		char tmp[128];
		rp_GetItemData(item_id, item_type_name, tmp, sizeof(tmp));
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Error_ItemAlreadyEnable", client, tmp);
		return Plugin_Handled;
	}
	
	rp_IncrementSuccess(client, success_list_assurance);
	rp_SetClientBool(client, b_AssuranceVie, true);
	rp_HookEvent(client, RP_OnAssurance,	fwdAssurance);
	rp_HookEvent(client, RP_OnPlayerDead, OnPlayerDeathFastRespawn);
	
	return Plugin_Handled;
}
public Action Cmd_ItemRegistre(int args){
	
	int client = GetCmdArgInt(1);
	int item_id = GetCmdArgInt(args);
	
	if( rp_AddSaveSlot(client) ) {
		rp_IncrementSuccess(client, success_list_assurance);
	}
	else{
		ITEM_CANCEL(client, item_id);
		CPrintToChat(client, ""...MOD_TAG..." %T", "Item_Register_TooMany", client);
	}
	
	return Plugin_Handled;
}
public Action OnPlayerDeathFastRespawn(int victim, int attacker, float& respawn, int& tdm) {
	respawn /= 2.0;
	return Plugin_Continue;
}

public Action fwdAssurance(int client, int& amount) {
	amount += 2000;
	return Plugin_Changed;
}

public Action Cmd_ItemNoAction(int args) {
	int client = GetCmdArgInt(args-1);
	int item_id = GetCmdArgInt(args);
	char name[64];
	
	ITEM_CANCEL(client, item_id);
	rp_GetItemData(item_id, item_type_name, name, sizeof(name));

	CPrintToChat(client, "" ...MOD_TAG... " %T", "Item_Count", client, rp_GetClientItem(client, item_id), rp_GetClientItem(client, item_id, true), name);
	return;
}
// ----------------------------------------------------------------------------
int g_iChequeID = -1;
// ----------------------------------------------------------------------------
public Action Cmd_ItemCheque(int args) {
	int client = GetCmdArgInt(1);
	int item_id = GetCmdArgInt(args);
	
	if( g_iChequeID == -1 )
		g_iChequeID = item_id;
	
	ITEM_CANCEL(client, item_id);
	CreateTimer(0.25, task_cheque, client);
}
public Action task_cheque(Handle timer, any client) {
	// Setup menu
	Handle menu = CreateMenu(MenuCheque);
	SetMenuTitle(menu, "%T:\n ", "Jobs_ListAvailable", client);
	char tmp[12], tmp2[64];
	
	bool bJob[MAX_JOBS];
	
	for(int i = 1; i <= MaxClients; i++) {
		
		if( !IsValidClient(i) )
			continue;
		if( !IsClientConnected(i) )
			continue;
		if( rp_GetClientInt(i, i_Job) == 0 )
			continue;
		if( i == client )
			continue;
		
		int job = rp_GetClientJobID(i);
		if( job == 1 || job == 91 || job == 101 || job == 181 ) // Police, mafia, tribunal, 18th
			continue;
		
		bJob[job] = true;
	}
	
	int amount = 0;
	
	for(int i=1; i<MAX_JOBS; i++) {
		if( bJob[i] == false )
			continue;
		
		amount++;
		Format(tmp, sizeof(tmp), "%d", i);
		rp_GetJobData(i, job_type_name, tmp2, sizeof(tmp2));
		
		AddMenuItem(menu, tmp, tmp2);
	}
	
	if( amount == 0 ) {
		CloseHandle(menu);
	}
	else {
		SetMenuExitButton(menu, true);
		DisplayMenu(menu, client, MENU_TIME_DURATION);
	}
}
bool HasHighGrade(int client, int jobID) {
	for(int i = 1; i <= MaxClients; i++) {
		if( !IsValidClient(i) )
			continue;
		if( i == client )
			continue;
		if( rp_GetClientJobID(i) != jobID )
			continue;
		if( (rp_GetClientInt(i, i_Job)-jobID) <= 2 )
			return true;
	}
	
	return false;
}
// ----------------------------------------------------------------------------
public int MenuCheque(Handle p_hItemMenu, MenuAction p_oAction, int client, int p_iParam2) {
	
	if (p_oAction == MenuAction_Select) {
		
		char szMenuItem[64];
		if( GetMenuItem(p_hItemMenu, p_iParam2, szMenuItem, sizeof(szMenuItem)) ) {
			
			char tmp[255], tmp2[255];
			int jobID = StringToInt(szMenuItem);
			
			// Setup menu
			Handle hGiveMenu = CreateMenu(MenuCheque2);
			SetMenuTitle(hGiveMenu, "%T\n ", "Item_Buy", client);
			
			for(int i = 0; i < MAX_ITEMS; i++) {
				
				if( rp_GetItemInt(i, item_type_job_id) != jobID )
					continue;
				
				rp_GetItemData(i, item_type_extra_cmd, tmp, sizeof(tmp));
				
				// Chirurgie
				if( StrContains(tmp, "rp_chirurgie", false) == 0 )
					continue;
				if( StrContains(tmp, "rp_item_contrat", false) == 0 )
					continue;
				if( StrContains(tmp, "rp_item_conprotect", false) == 0 )
					continue;
				
				// les items des haut-gradés
				if( StrContains(tmp, "rp_item_cashbig", false) == 0 && HasHighGrade(client, jobID) )
					continue;
				if( StrContains(tmp, "rp_giveitem_pvp", false) == 0 && HasHighGrade(client, jobID) )
					continue;
				
				rp_GetItemData(i, item_type_name, tmp, sizeof(tmp));
				
				Format(tmp2, sizeof(tmp2), "%s [%d$]", tmp, rp_GetItemInt(i, item_type_prix) );
				Format(tmp, sizeof(tmp), "%d_0_0_%d_0", i, client);
				
				AddMenuItem(hGiveMenu, tmp, tmp2);
			}
			
			SetMenuExitButton(hGiveMenu, true);
			DisplayMenu(hGiveMenu, client, MENU_TIME_DURATION);
		}
	}
	else if ( p_oAction == MenuAction_End ) {
		CloseHandle(p_hItemMenu);
	}
}
public int MenuCheque2(Handle p_hItemMenu, MenuAction p_oAction, int client, int p_iParam2) {
	if (p_oAction == MenuAction_Select) {
		
		char szMenuItem[64];
		if( GetMenuItem(p_hItemMenu, p_iParam2, szMenuItem, sizeof(szMenuItem)) ) {
			
			char data[5][32];
			ExplodeString(szMenuItem, "_", data, sizeof(data), sizeof(data[]));
			
			int item_id = StringToInt(data[0]);
			int price = rp_GetItemInt(item_id, item_type_prix);
			int auto = rp_GetItemInt(item_id, item_type_auto);
			
			char tmp[255], tmp2[255], tmp3[255];
			rp_GetItemData(item_id, item_type_name, tmp3, sizeof(tmp3));
			
			// Setup menu
			Handle hGiveMenu = rp_CreateSellingMenu();			
			
			SetMenuTitle(hGiveMenu, "%T\n ", "Item_BuyCount", client);
			int amount = 0;
			for(int i = 1; i <= 100; i++) {
				
				if( (rp_GetClientInt(client, i_Money)+rp_GetClientInt(client, i_Bank)) <= (price*i) )
					break;
				if( i > 1 && auto )
					continue;
				
				amount++;
				
				
				Format(tmp2, sizeof(tmp2), "%s - %d [%d$]", tmp3, i, price * i );
				Format(tmp, sizeof(tmp), "%d_%d_%s_%s_%s_%s", item_id, i, data[1], data[2], data[3], data[4]); // id,amount,itemTYPE=0,param,ClientFromMenu,reduction

				AddMenuItem(hGiveMenu, tmp, tmp2);
			}
			
			if( amount == 0 ) {
				CloseHandle(hGiveMenu);
				return;
			}
			
			SetMenuExitButton(hGiveMenu, true);
			DisplayMenu(hGiveMenu, client, MENU_TIME_DURATION);
		}
	}
	else if ( p_oAction == MenuAction_End ) {
		CloseHandle(p_hItemMenu);
	}
}
// ----------------------------------------------------------------------------
public Action Cmd_ItemForward(int args) {
	int client = GetCmdArgInt(args-1);
	int item_id = GetCmdArgInt(args);
	char tmp[64];
	int mnt = rp_GetClientItem(client, item_id);
	rp_ClientGiveItem(client, item_id, -mnt, false);
	rp_ClientGiveItem(client, item_id, mnt+1, true);
	
	rp_GetItemData(item_id, item_type_name, tmp, sizeof(tmp));
	
	if( mnt+1 == 1 )
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Item_MoveToBank_Singl", client, mnt+1, tmp);
	else
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Item_MoveToBank_Plural", client, mnt+1, tmp);
	
	return;
}
public Action Cmd_ItemPackDebutant(int args) { //Permet d'avoir la CB, le compte & le RIB
	
	int client = GetCmdArgInt(1);
	rp_SetClientBool(client, b_HaveCard, true);
	rp_SetClientBool(client, b_PayToBank, true);
	rp_SetClientBool(client, b_HaveAccount, true);
	rp_SetClientBool(client, b_License1, true);
 	rp_SetClientBool(client, b_License2, true);
 	rp_SetClientBool(client, b_LicenseSell, true);
 	
 	
	rp_SetClientInt(client, i_StartLicense1, GetTime());
	rp_SetClientInt(client, i_StartLicense2, GetTime());
 	
	CPrintToChat(client, ""...MOD_TAG..." %T", "Item_PackForNew", client);

	rp_ClientSave(client);
}
// ----------------------------------------------------------------------------
public Action fwdOnPlayerBuild(int client, float& cooldown) {
	if( rp_GetClientJobID(client) != 211 )
		return Plugin_Continue;
	
	int ent = BuidlingATM(client);
	rp_SetBuildingData(ent, BD_FromBuild, 1);
	SetEntProp(ent, Prop_Data, "m_iHealth", GetEntProp(ent, Prop_Data, "m_iHealth")/5);
	Entity_SetMaxHealth(ent, Entity_GetHealth(ent));
	
	if( ent > 0 ) {
		rp_SetClientStat(client, i_TotalBuild, rp_GetClientStat(client, i_TotalBuild)+1);
		rp_ScheduleEntityInput(ent, 120.0, "Kill");
		cooldown = 120.0;
	}
	else 
		cooldown = 3.0;
	
	return Plugin_Stop;
}
public Action Cmd_ItemDistrib(int args) {
	int client = GetCmdArgInt(1);
	int item_id = GetCmdArgInt(args);
	
	if( BuidlingATM(client) == 0 ) {
		ITEM_CANCEL(client, item_id);
	}
	
	return Plugin_Handled;
}


int BuidlingATM(int client) {
	
	if( !rp_IsBuildingAllowed(client) )
		return 0;	
	
	char classname[64], tmp[64];
	
	Format(classname, sizeof(classname), "rp_bank");	
	
	float vecOrigin[3];
	GetClientAbsOrigin(client, vecOrigin);
	int count;
	for(int i=1; i<=2048; i++) {
		if( !IsValidEdict(i) )
			continue;
		if( !IsValidEntity(i) )
			continue;
		
		GetEdictClassname(i, tmp, sizeof(tmp));
		
		if( StrEqual(classname, tmp) && rp_GetBuildingData(i, BD_owner) == client ) {
			count++;
			if( count >= 2 ) {
				CPrintToChat(client, ""...MOD_TAG..." %T", "Build_TooMany", client);
				return 0;
			}
		}
	}

	EmitSoundToAllAny("player/ammo_pack_use.wav", client);
	
	int ent = CreateEntityByName("prop_physics_override");
	
	DispatchKeyValue(ent, "classname", classname);
	DispatchKeyValue(ent, "model", MODEL_ATM);
	DispatchSpawn(ent);
	ActivateEntity(ent);
	
	SetEntityModel(ent, MODEL_ATM);
	
	SetEntProp( ent, Prop_Data, "m_iHealth", 50000);
	SetEntProp( ent, Prop_Data, "m_takedamage", 0);
	
	SetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity", client);
	
	float vecAngles[3]; GetClientEyeAngles(client, vecAngles); vecAngles[0] = vecAngles[2] = 0.0;
	TeleportEntity(ent, vecOrigin, vecAngles, NULL_VECTOR);
	
	SetEntityRenderMode(ent, RENDER_NONE);
	ServerCommand("sm_effect_fading \"%i\" \"3.0\" \"0\"", ent);
	
	rp_HookEvent(client, RP_PrePlayerPhysic, fwdFrozen, 3.0);
	SetEntityMoveType(ent, MOVETYPE_NONE);
	
	CreateTimer(3.0, BuildingATM_post, ent);
	rp_SetBuildingData(ent, BD_owner, client);
	rp_SetBuildingData(ent, BD_FromBuild, 0);
	Entity_SetMaxHealth(ent, Entity_GetHealth(ent));
	
	return ent;
}

public Action BuildingATM_post(Handle timer, any entity) {
	int client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	
	rp_Effect_BeamBox(client, entity, NULL_VECTOR, 255, 255, 0);
	
	SetEntProp(entity, Prop_Data, "m_takedamage", 2);
	SDKHook(entity, SDKHook_OnTakeDamage, DamageATM);
	HookSingleEntityOutput(entity, "OnBreak", BuildingATM_break);
	return Plugin_Handled;
}

public void BuildingATM_break(const char[] output, int caller, int activator, float delay) {
	
	int owner = GetEntPropEnt(caller, Prop_Send, "m_hOwnerEntity");
	if( IsValidClient(activator) && IsValidClient(owner) ) {
		rp_ClientAggroIncrement(activator, owner, 1000);
	}
	
	if( IsValidClient(owner) ) {
		char tmp[128];
		GetEdictClassname(caller, tmp, sizeof(tmp));
		CPrintToChat(owner, "" ...MOD_TAG... " %T", "Build_Destroyed", owner, tmp);
	}
}
public Action DamageATM(int victim, int &attacker, int &inflictor, float &damage, int &damagetype) {
	
	if( rp_IsInPVP(victim) ) {
		damage *= 25.0;
		return Plugin_Changed;
	}
	
	return Plugin_Continue;
}


public Action fwdUse(int client) {
	
	if( IsInMetro(client) ) {
		DisplayMetroMenu(client);
	}
	
	int sign = isNearSign(client);
	if( sign > 0 ) { 
		displaySignMenu(client, sign);
	}
}

void DisplayMetroMenu(int client) {
	
	if( !rp_IsTutorialOver(client) )
		return;
	
	char tmp[128];
	int zone = rp_GetPlayerZone(client);
	
	Handle menu = CreateMenu(eventMetroMenu);
	SetMenuTitle(menu, "%T\n ", "Metro_Menu", client);
	
	Format(tmp, sizeof(tmp), "%T", "Metro_Event", client);
	AddMenuItem(menu, "metro_event", tmp, GetConVarInt(g_hEVENT) != 1 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

	rp_GetZoneData(60, zone_type_name, tmp, sizeof(tmp));
	AddMenuItem(menu, "metro_paix", 	tmp, (zone == 57) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	
	rp_GetZoneData(61, zone_type_name, tmp, sizeof(tmp));
	AddMenuItem(menu, "metro_zoning", 	tmp, (zone == 58) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	
	rp_GetZoneData(62, zone_type_name, tmp, sizeof(tmp));
	AddMenuItem(menu, "metro_inno", 	tmp, (zone == 59) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	
	rp_GetZoneData(201, zone_type_name, tmp, sizeof(tmp));
	AddMenuItem(menu, "metro_pvp", 		tmp, (zone == 200) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	
	Format(tmp, sizeof(tmp), "%T", "Metro_Hell", client);
	AddMenuItem(menu, "metro_event", tmp, GetConVarInt(g_hEVENT) != 5? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	
	if( rp_GetClientKeyAppartement(client, 50) ) {
		Format(tmp, sizeof(tmp), "%T", "Metro_Event", client);
		AddMenuItem(menu, "metro_villa", tmp, (zone == 245) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	}
	
	SetMenuPagination(menu, MENU_NO_PAGINATION);
	SetMenuExitBackButton(menu, false);
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, 30);
}

public int eventMetroMenu(Handle menu, MenuAction action, int client, int param2) {
	if( action == MenuAction_Select ) {
		char options[64], tmp[64];
		GetMenuItem(menu, param2, options, sizeof(options));
		
		if( !IsInMetro(client) )
			return;
		
		if( StrContains(options, "metro_event") == 0 && GetConVarInt(g_hEVENT) == 0 ) {
			return;
		}
		
		int Max, i, hours, min, iLocation[MAX_LOCATIONS];
		
		for( i=0; i<150; i++ ) {
			rp_GetLocationData(i, location_type_base, tmp, sizeof(tmp));
			
			if( StrEqual(tmp, options, false) ) {
				iLocation[Max++] = i;
			}
		}
		i = iLocation[Math_GetRandomInt(0, (Max-1))];
		float pos[3];
		
		pos[0] = float(rp_GetLocationInt(i, location_type_origin_x));
		pos[1] = float(rp_GetLocationInt(i, location_type_origin_y));
		pos[2] = float(rp_GetLocationInt(i, location_type_origin_z))+8.0;
		
		rp_GetTime(hours, min);
		min = 5 - (min % 5);
		
		rp_GetZoneData(rp_GetZoneFromPoint(pos), zone_type_name, tmp, sizeof(tmp));
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Metro_Start", client, min);
		rp_SetClientInt(client, i_TeleportTo, i);
		CreateTimer(float(min) + Math_GetRandomFloat(0.01, 0.8), metroTeleport, client);
	}
	else if( action == MenuAction_End ) {
		CloseHandle(menu);
	}
}
public Action metroTeleport(Handle timer, any client) {
	
	char tmp[32];
	rp_GetZoneData(rp_GetPlayerZone(client), zone_type_type, tmp, sizeof(tmp));
	int tp = rp_GetClientInt(client, i_TeleportTo);
	rp_SetClientInt(client, i_TeleportTo, 0);
	
	if( tp == 0 )
		return Plugin_Handled;
	if( !IsInMetro(client) )
			return Plugin_Handled;
	
	bool paid = false;
	
	rp_GetLocationData(tp, location_type_base, tmp, sizeof(tmp));
	
	if( StrContains(tmp, "metro_event") == 0) {
		if( rp_GetClientBool(client, b_IsMuteEvent) == true ) {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Banned_Event", client);
			return Plugin_Handled;
		}
		if( rp_GetClientBool(client, b_IsSearchByTribunal) == true ) {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Banned_Event", client);
			return Plugin_Handled;
		}
		paid = true;
	}
	if( !paid && rp_GetClientJobID(client) == 31 ) {
		paid = true;
	}
	if( !paid && rp_GetClientItem(client, 42) > 0 ) {
		paid = true;
		rp_ClientGiveItem(client, 42, -1);
	}
	if( !paid && rp_GetClientItem(client, 42, true) > 0) { 		
		paid = true;
		rp_ClientGiveItem(client, 42, -1, true);
	}
	if( !paid && (rp_GetClientInt(client, i_Money)+rp_GetClientInt(client, i_Bank)) >= 100 ) {
		int price = 100;
		rp_ClientMoney(client, i_Money, -price);
		rp_SetJobCapital(211, rp_GetJobCapital(211) + price);
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Metro_Paid", client, price);
		paid = true;
	}
	
	if( paid  ) {
		float pos[3];
		pos[0] = float(rp_GetLocationInt(tp, location_type_origin_x));
		pos[1] = float(rp_GetLocationInt(tp, location_type_origin_y));
		pos[2] = float(rp_GetLocationInt(tp, location_type_origin_z))+8.0;
		
		rp_ClientTeleport(client, pos);
	}
	
	
	return Plugin_Continue;
}
bool IsInMetro(int client) {
	char tmp[32];
	rp_GetZoneData(rp_GetPlayerZone(client), zone_type_type, tmp, sizeof(tmp));
	
	if( StrEqual(tmp, "metro") ) {
		return true;
	}
	
	int app = rp_GetPlayerZoneAppart(client);
	if( app == 50 ) {
		if( rp_GetClientKeyAppartement(client, app) ) {
			float min[3] = { -1752.0, -9212.0, -1819.0 };
			float max[3] =  { -1522.0, -8982.0, -1679.0 };
			float origin[3];
			GetClientAbsOrigin(client, origin);
			if( origin[0] > min[0] && origin[0] < max[0] &&
				origin[1] > min[1] && origin[1] < max[1] &&
				origin[2] > min[2] && origin[2] < max[2] ) {
				return true;
			}
		}
	}
	return false;
}



int BuidlingSIGN(int client) {
	
	if( !rp_IsBuildingAllowed(client) )
		return 0;	
	
	char classname[64], tmp[64];
	float vecOrigin[3];
	
	Format(classname, sizeof(classname), "rp_sign");
	GetClientAbsOrigin(client, vecOrigin);
	int count;
	
	bool isAdmin = view_as<bool>(GetUserFlagBits(client) & (ADMFLAG_GENERIC|ADMFLAG_ROOT));
	
	for(int i=1; i<=2048; i++) {
		if( !IsValidEdict(i) )
			continue;
		if( !IsValidEntity(i) )
			continue;
		
		GetEdictClassname(i, tmp, sizeof(tmp));
		
		if( StrEqual(classname, tmp) && rp_GetBuildingData(i, BD_owner) == client ) {
			count++;
			
			if( count >= 1 && !isAdmin ) {
				CPrintToChat(client, ""...MOD_TAG..." %T", "Build_TooMany", client);
				return 0;
			}
		}
	}

	EmitSoundToAllAny("player/ammo_pack_use.wav", client);
	
	int ent = CreateEntityByName("prop_physics_override");
	DispatchKeyValue(ent, "classname", classname);
	DispatchKeyValue(ent, "model", MODEL_PANNEAU);
	DispatchSpawn(ent);
	ActivateEntity(ent);
	
	SetEntProp( ent, Prop_Data, "m_iHealth", 50000);
	SetEntProp( ent, Prop_Data, "m_takedamage", 0);
	
	SetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity", client);
	
	float vecAngles[3]; GetClientEyeAngles(client, vecAngles); vecAngles[0] = vecAngles[2] = 0.0;
	TeleportEntity(ent, vecOrigin, vecAngles, NULL_VECTOR);
	
	SetEntityRenderMode(ent, RENDER_NONE);
	ServerCommand("sm_effect_fading \"%i\" \"3.0\" \"0\"", ent);
	
	rp_HookEvent(client, RP_PrePlayerPhysic, fwdFrozen, 3.0);
	SetEntityMoveType(ent, MOVETYPE_NONE);
	
	CreateTimer(3.0, BuildingSIGN_post, ent);
	rp_SetBuildingData(ent, BD_owner, client);
	rp_SetBuildingData(ent, BD_FromBuild, 0);
	return ent;
}
public Action fwdFrozen(int client, float& speed, float& gravity) {
	speed = 0.0;
	return Plugin_Stop;
}
public Action BuildingSIGN_post(Handle timer, any entity) {
	int client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	
	rp_Effect_BeamBox(client, entity, NULL_VECTOR, 255, 255, 0);
	SDKHook(entity, SDKHook_OnTakeDamage, DamageATM);
	
	SetEntProp(entity, Prop_Data, "m_takedamage", 2);
	HookSingleEntityOutput(entity, "OnBreak", BuildingSIGN_break);
	
	g_iSignPermission[entity] = 1;
	g_hSignData[entity] = new ArrayList(255);
	
	char tmp[128];
	Format(tmp, sizeof(tmp), "%T", "Sign_Press", LANG_SERVER);
	g_hSignData[entity].PushString(tmp);
	
	return Plugin_Handled;
}
public void OnEntityDestroyed(int entity) {
	if( entity > 0 && g_hSignData[entity] ) {
		g_hSignData[entity].Clear();
		delete g_hSignData[entity];
		g_iSignPermission[entity] = 0;
	}
}
public void BuildingSIGN_break(const char[] output, int caller, int activator, float delay) {
	
	int owner = GetEntPropEnt(caller, Prop_Send, "m_hOwnerEntity");
	if( IsValidClient(activator) && IsValidClient(owner) ) {
		rp_ClientAggroIncrement(activator, owner, 1000);
	}
	if( IsValidClient(owner) ) {
		char tmp[128];
		GetEdictClassname(caller, tmp, sizeof(tmp));
		CPrintToChat(owner, "" ...MOD_TAG... " %T", "Build_Destroyed", owner, tmp);
	}
}
public Action fwdPlayerHINT(int client, int entity) {
	static char tmp[255];
	if( g_iSignPermission[entity] > 0 ) {
		g_hSignData[entity].GetString(0, tmp, sizeof(tmp));
		
		String_ColorsToHTML(tmp, sizeof(tmp));
		ReplaceString(tmp, sizeof(tmp), "%", "%%");
		
		PrintHintText(client, tmp);
		return Plugin_Stop;
	}
	return Plugin_Continue;
}
void displaySignMenu(int client, int entity) {
	Menu menu = new Menu(Menu_displayMenu);
	char tmp[128], tmp2[128];
	
	int owner = rp_GetBuildingData(entity, BD_owner);
	GetClientName2(owner, tmp, sizeof(tmp), true);
	menu.SetTitle("%T\n ", "Sign_OwnedBy", client, tmp);
	
	bool hasPerm = false;
	if( owner == client )
		hasPerm = true;
	if( g_iSignPermission[entity] == 2 && rp_GetClientJobID(owner) == rp_GetClientJobID(client) ) {
		int jobID = rp_GetClientJobID(client);
		int job = rp_GetClientInt(client, i_Job);
		if( job == jobID || job-1 == jobID )
			hasPerm = true;
	}
	if( g_iSignPermission[entity] == 3 && rp_GetClientJobID(owner) == rp_GetClientJobID(client) )
		hasPerm = true;
	if( g_iSignPermission[entity] == 4 && rp_GetClientGroupID(owner) == rp_GetClientGroupID(client) )
		hasPerm = true;
	if( g_iSignPermission[entity] == 5 )
		hasPerm = true;
	
	for (int i = 0; i < g_hSignData[entity].Length; i++) {
		g_hSignData[entity].GetString(i, tmp, sizeof(tmp));
		
		Format(tmp2, sizeof(tmp2), "%d %d", i, entity);
		CRemoveTags(tmp, sizeof(tmp));
		
		if( strlen(tmp) > 40 )
			String_WordWrap(tmp, 40);
		
		
		menu.AddItem(tmp2, tmp, hasPerm ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	}
	
	if( hasPerm ) {
		Format(tmp, sizeof(tmp), "%T", "Sign_Add", client);
		Format(tmp2, sizeof(tmp2), "%d %d", -1, entity);
		menu.AddItem(tmp2, tmp);
	}
	
	if( client == rp_GetBuildingData(entity, BD_owner) ) {
		Format(tmp, sizeof(tmp), "%T", "Perm_Edit", client);
		Format(tmp2, sizeof(tmp2), "%d %d", -2, entity);
		menu.AddItem(tmp2, tmp);
	}
	
	
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Menu_displayMenu(Handle menu, MenuAction action, int client, int param2) {
	
	if( action == MenuAction_Select ) {
		char options[64], explo[2][32];
		char tmp[128];
		GetMenuItem(menu, param2, options, sizeof(options));
		ExplodeString(options, " ", explo, sizeof(explo), sizeof(explo[]));
		int i = StringToInt(explo[0]);
		int entity = StringToInt(explo[1]);
		
		if( i <= -100 ) {
			g_iSignPermission[entity] = i + 1000;
		}
		else if( i == -2 ) {
			Menu menu2 = new Menu(Menu_displayMenu);
			menu2.SetTitle("%T\n ", "Sign_PermWho", client);
			
			Format(options, sizeof(options), "%d %d", -1000+1, entity);
			Format(tmp, sizeof(tmp), "%T", "Perm_Self", client);
			menu2.AddItem(options, tmp);
			
			Format(options, sizeof(options), "%d %d", -1000+2, entity);
			Format(tmp, sizeof(tmp), "%T", "Perm_Chef", client);
			menu2.AddItem(options, tmp);
			
			Format(options, sizeof(options), "%d %d", -1000+3, entity);
			Format(tmp, sizeof(tmp), "%T", "Perm_Job", client);
			menu2.AddItem(options, tmp);
			
			Format(options, sizeof(options), "%d %d", -1000+4, entity);
			Format(tmp, sizeof(tmp), "%T", "Perm_Gang", client);
			menu2.AddItem(options, tmp);
			
			Format(options, sizeof(options), "%d %d", -1000+5, entity);
			Format(tmp, sizeof(tmp), "%T", "Perm_Everyone", client);
			menu2.AddItem(options, tmp);
			
			
			menu2.Display(client, MENU_TIME_FOREVER);
		}
		else {
			DataPack dp = new DataPack();
			dp.WriteCell(i);
			dp.WriteCell(entity);
			rp_GetClientNextMessage(client, dp, cbTest);
			
			CPrintToChat(client, ""...MOD_TAG..." %T", "Sign_Adding", client);
		}
	}
	else if( action == MenuAction_End ) {
		CloseHandle(menu);
	}
}
public void cbTest(int client, any data, char[] message) {
	DataPack dp = view_as<DataPack>(data);
	dp.Reset();
	int i = dp.ReadCell();
	int entity = dp.ReadCell();
	
	delete dp;
	
	if( i >= 0 ) {
		if( strlen(message) > 1 ) {
			g_hSignData[entity].SetString(i, message);
		}
		else {
			g_hSignData[entity].Erase(i);
			if( g_hSignData[entity].Length <= 0 ) {
				char tmp[128];
				Format(tmp, sizeof(tmp), "%T", "Sign_Press", LANG_SERVER);
				g_hSignData[entity].PushString(tmp);
			}
		}
	}
	else if( i == -1 ) {
		g_hSignData[entity].PushString(message);
	}
}
int isNearSign(int client) {
	char classname[65];
	int target = rp_GetClientTarget(client);
	if( IsValidEdict(target) && IsValidEntity(target) && g_iSignPermission[target] > 0 ) {
		GetEdictClassname(target, classname, sizeof(classname));
		if( StrContains(classname, "rp_sign") == 0 && rp_IsEntitiesNear(client, target) )
			return target;
	}
	return -1;
}


