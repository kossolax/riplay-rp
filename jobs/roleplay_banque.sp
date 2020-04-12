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
	rp_HookEvent(client, RP_OnPlayerCommand, fwdCommand);
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
public Action fwdCommand(int client, char[] command, char[] arg) {	
	if( StrEqual(command, "search") || StrEqual(command, "lookup")) {
		if( rp_GetClientJobID(client) != 1 &&  rp_GetClientJobID(client) != 41 && rp_GetClientJobID(client) != 211 && rp_GetClientJobID(client) != 101 ) { // Police, mercenaire, banquier, tribunal
			ACCESS_DENIED(client);
		}
		int target = rp_GetClientTarget(client);
		
		if( !IsValidClient(target) )
			return Plugin_Handled;

		if( !IsPlayerAlive(target) )
			return Plugin_Handled;

		int wepIdx;
		char classname[32], msg[128];
		Format(msg, 127, "Ce joueur possède: ");

		if( (wepIdx = GetPlayerWeaponSlot( target, 1 )) != -1 ){
			GetEdictClassname(wepIdx, classname, 31);
			ReplaceString(classname, 31, "weapon_", "", false);

			Format(msg, 127, "%s %s", msg, classname);
		}
		if( (wepIdx = GetPlayerWeaponSlot( target, 0 )) != -1 ){
			GetEdictClassname(wepIdx, classname, 31);
			ReplaceString(classname, 31, "weapon_", "", false);

			Format(msg, 127, "%s %s", msg, classname);
		}
			
		
		if( rp_GetClientBool(target, b_License1) || rp_GetClientBool(target, b_License2) || rp_GetClientBool(target, b_LicenseSell) ) {
			Format(msg, 127, "%s permis", msg);

			if( rp_GetClientBool(target, b_License1) ) {
				Format(msg, 127, "%s léger", msg);
			}
			if( rp_GetClientBool(target, b_License2) ) {
				Format(msg, 127, "%s lourd", msg);
			}
			if(  rp_GetClientBool(target, b_LicenseSell) ) {
				Format(msg, 127, "%s vente", msg);
			}
		}

		CPrintToChat(client, "{lightblue}[TSX-RP]{default} %s.", msg);

		return Plugin_Handled;
	}
	return Plugin_Continue;
}
// ----------------------------------------------------------------------------
public Action Cmd_ItemPermi(int args) {
	
	char Arg1[12];
	GetCmdArg(1, Arg1, 11);
	
	int client = GetCmdArgInt(2);
	
	if( StrEqual(Arg1, "lege") ) {
		rp_SetClientBool(client, b_License1, true);
		CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous avez maintenant un permis de port d'arme légère.");
	}
	else if( StrEqual(Arg1, "lourd") ) {
		rp_SetClientBool(client, b_License2, true);
		CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous avez maintenant un permis de port d'arme lourde.");
	}
	else if( StrEqual(Arg1, "vente") ) {
		rp_SetClientBool(client, b_LicenseSell, true);
		CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous avez maintenant un permis de vente.");
	}
	
	rp_ClientSave(client);
}
public Action Cmd_ItemBankCard(int args) {
	
	int item_id = GetCmdArgInt(args);
	int client = GetCmdArgInt(1);

	if(rp_GetClientBool(client, b_HaveCard)){
		ITEM_CANCEL(client, item_id);
		CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous disposez déjà d'une carte bancaire.");
		return Plugin_Handled;
	}
	rp_SetClientBool(client, b_HaveCard, true);
	
	CPrintToChat(client, "{lightblue}[TSX-RP]{default} Votre carte bancaire est maintenant activée.");
	rp_ClientSave(client);
}
public Action Cmd_ItemBankSort(int args) {

	int item_id = GetCmdArgInt(args);
	int client = GetCmdArgInt(1);

	if(rp_GetClientBool(client, b_CanSort)){
		ITEM_CANCEL(client, item_id);
		CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous pouvez déjà trier votre inventaire.");
		return Plugin_Handled;
	}

	rp_SetClientBool(client, b_CanSort, true);
	CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous pouvez maintenant trier votre inventaire jusqu'à votre déconnexion.");
}
public Action Cmd_ItemBankKey(int args) {
	
	int item_id = GetCmdArgInt(args);
	int client = GetCmdArgInt(1);

	if(rp_GetClientBool(client, b_HaveAccount)){
		ITEM_CANCEL(client, item_id);
		CPrintToChat(client, "{lightblue}[TSX-RP]{default} Votre compte bancaire est déjà actif.");
		return Plugin_Handled;
	}

	rp_SetClientBool(client, b_HaveAccount, true);
	CPrintToChat(client, "{lightblue}[TSX-RP]{default} Votre compte bancaire est maintenant actif.");
	rp_ClientSave(client);
}
public Action Cmd_ItemBankSwap(int args) {
	
	int item_id = GetCmdArgInt(args);
	int client = GetCmdArgInt(1);

	if(rp_GetClientBool(client, b_PayToBank)){
		ITEM_CANCEL(client, item_id);
		CPrintToChat(client, "{lightblue}[TSX-RP]{default} Votre paye va déjà en banque.");
		return Plugin_Handled;
	}

	rp_SetClientBool(client, b_PayToBank, true);
	CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous recevrez maintenant votre paye en banque.");
	rp_ClientSave(client);
}
// ----------------------------------------------------------------------------
public Action Cmd_ItemAssurance(int args) {
	
	int item_id = GetCmdArgInt(args);
	int client = GetCmdArgInt(1);
	
	if( !rp_GetClientBool(client, b_Assurance) ) {
		rp_IncrementSuccess(client, success_list_assurance);
	}
	else{
		ITEM_CANCEL(client, item_id);
		CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous êtes déjà assuré.");
		return Plugin_Handled;
	}
	
	rp_SetClientBool(client, b_Assurance, true);
	FakeClientCommand(client, "say /assu");
	
	rp_ClientSave(client);
	
	return Plugin_Handled;
}

public Action Cmd_ItemAssuVie(int args){
	
	int item_id = GetCmdArgInt(args);
	int client = GetCmdArgInt(1);
	
	if( !rp_GetClientBool(client, b_AssuranceVie) ) {
		CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous etes maintenant couvert par l'assurance vie.");
		rp_IncrementSuccess(client, success_list_assurance);
	}
	else{
		ITEM_CANCEL(client, item_id);
		CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous êtes déjà assuré.");
		return Plugin_Handled;
	}
	
	rp_SetClientBool(client, b_AssuranceVie, true);
	rp_HookEvent(client, RP_OnAssurance,	fwdAssurance);
	rp_HookEvent(client, RP_OnPlayerDead, OnPlayerDeathFastRespawn);
	
	return Plugin_Handled;
}
public Action OnPlayerDeathFastRespawn(int victim, int attacker, float& respawn) {
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
	
	CPrintToChat(client, "{lightblue}[TSX-RP]{default} Ceci est un %s, vous en avez %d sur vous et %d en banque.", name, rp_GetClientItem(client, item_id), rp_GetClientItem(client, item_id, true));
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
	SetMenuTitle(menu, "Liste des jobs disponible:");
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
// ----------------------------------------------------------------------------
public int MenuCheque(Handle p_hItemMenu, MenuAction p_oAction, int client, int p_iParam2) {
	
	if (p_oAction == MenuAction_Select) {
		
		char szMenuItem[64];
		if( GetMenuItem(p_hItemMenu, p_iParam2, szMenuItem, sizeof(szMenuItem)) ) {
			
			char tmp[255], tmp2[255];
			int jobID = StringToInt(szMenuItem);
			
			// Setup menu
			Handle hGiveMenu = CreateMenu(MenuCheque2);
			SetMenuTitle(hGiveMenu, "Sélectionnez un objet à acheter\n ");
			
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
			
			SetMenuTitle(hGiveMenu, "Sélectionnez combien en acheter\n ");
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
		CPrintToChat(client, "{lightblue}[TSX-RP]{default} %d %s a été transféré en banque.", mnt+1, tmp);
	else
		CPrintToChat(client, "{lightblue}[TSX-RP]{default} %d %s ont été transférés en banque.", mnt+1, tmp);
	
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
 	
	CPrintToChat(client, "{lightblue}[TSX-RP]{default} Votre carte bancaire, votre coffre, votre RIB et vos permis sont maintenant actifs.");

	rp_ClientSave(client);
}
// ----------------------------------------------------------------------------
public Action fwdOnPlayerBuild(int client, float& cooldown) {
	if( rp_GetClientJobID(client) != 211 )
		return Plugin_Continue;
	
	int ent = BuidlingATM(client);
	
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
				CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous avez déjà deux distributeurs portables de placés.");
				return 0;
			}
		}
	}
	
	CPrintToChat(client, "{lightblue}[TSX-RP]{default} Construction en cours...");

	EmitSoundToAllAny("player/ammo_pack_use.wav", client);
	
	int ent = CreateEntityByName("prop_physics_override");
	
	DispatchKeyValue(ent, "classname", classname);
	DispatchKeyValue(ent, "model", MODEL_ATM);
	DispatchSpawn(ent);
	ActivateEntity(ent);
	
	SetEntityModel(ent, MODEL_ATM);
	
	SetEntProp( ent, Prop_Data, "m_iHealth", 10000);
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
	if( IsValidClient(owner) ) {
		CPrintToChat(owner, "{lightblue}[TSX-RP]{default} Votre distributeur portable a été détruit.");
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
	
	Handle menu = CreateMenu(eventMetroMenu);
	SetMenuTitle(menu, "== Station de métro ==\n ");
	
	if( GetConVarInt(g_hEVENT) == 1 )
		AddMenuItem(menu, "metro_event", "Métro: Station événementiel");
	
	AddMenuItem(menu, "metro_paix", 	"Métro: Station de la paix");
	AddMenuItem(menu, "metro_zoning", 	"Métro: Station Place Station");
	AddMenuItem(menu, "metro_inno", 	"Métro: Station de l'innovation");
	AddMenuItem(menu, "metro_pvp", 		"Métro: Station Belmont");
	if( rp_GetClientKeyAppartement(client, 50) ) {
		AddMenuItem(menu, "metro_villa", 	"Métro: Villa");
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
		
		if( StrEqual(options, "metro_event") && GetConVarInt(g_hEVENT) == 0 ) {
			return;
		}
		
		int Max, i, hours, min, iLocation[150];
		
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
		CPrintToChat(client, "{lightblue}[TSX-RP]{default} Restez assis à l'intérieur du métro, le prochain départ pour %s est dans %d seconde%s.", tmp, min, min >= 2 ? "s" : "");
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
	
	if( StrEqual(tmp, "metro_event") ) {
		if( rp_GetClientBool(client, b_IsMuteEvent) == true ) {
			CPrintToChat(client, "{lightblue}[TSX-RP]{default} En raison de votre mauvais comportement, il vous est temporairement interdit de participer à un event.");
			return Plugin_Handled;
		}
		if( rp_GetClientBool(client, b_IsSearchByTribunal) == true ) {
			CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous êtes recherché par le Tribunal, impossible de participer à un event.");
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
		rp_ClientMoney(client, i_Money, -100);
		rp_SetJobCapital(31, rp_GetJobCapital(31) + 100);
		CPrintToChat(client, "{lightblue}[TSX-RP]{default} Le métro vous a couté 100$. Pensez à acheter des tickets à un banquier pour que le trajet vous coûte moins chère.");
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
				CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous avez placé un panneau indicateur.");
				return 0;
			}
		}
	}
	
	CPrintToChat(client, "{lightblue}[TSX-RP]{default} Construction en cours...");

	EmitSoundToAllAny("player/ammo_pack_use.wav", client);
	
	int ent = CreateEntityByName("prop_physics_override");
	DispatchKeyValue(ent, "classname", classname);
	DispatchKeyValue(ent, "model", MODEL_PANNEAU);
	DispatchSpawn(ent);
	ActivateEntity(ent);
	
	SetEntProp( ent, Prop_Data, "m_iHealth", 2500);
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
	g_hSignData[entity].PushString("Appuyez sur E pour modifier le panneau");
	
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
	if( IsValidClient(owner) ) {
		CPrintToChat(owner, "{lightblue}[TSX-RP]{default} Votre panneau a été détruit.");
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
	char tmp[128], tmp2[32];
	
	int owner = rp_GetBuildingData(entity, BD_owner);
	menu.SetTitle("Panneau de %N\n ", owner);
	
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
		Format(tmp2, sizeof(tmp2), "%d %d", -1, entity);
		menu.AddItem(tmp2, "Ajouter une ligne");
	}
	
	if( client == rp_GetBuildingData(entity, BD_owner) ) {
		Format(tmp2, sizeof(tmp2), "%d %d", -2, entity);
		menu.AddItem(tmp2, "Modifier les permissions");
	}
	
	
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Menu_displayMenu(Handle menu, MenuAction action, int client, int param2) {
	
	if( action == MenuAction_Select ) {
		char options[64], explo[2][32];
		GetMenuItem(menu, param2, options, sizeof(options));
		ExplodeString(options, " ", explo, sizeof(explo), sizeof(explo[]));
		int i = StringToInt(explo[0]);
		int entity = StringToInt(explo[1]);
		
		if( i <= -100 ) {
			g_iSignPermission[entity] = i + 1000;
		}
		else if( i == -2 ) {
			Menu menu2 = new Menu(Menu_displayMenu);
			menu2.SetTitle("Qui peut modifier ce panneau?\n ");
			Format(options, sizeof(options), "%d %d", -1000+1, entity);	menu2.AddItem(options, "Uniquement moi");
			Format(options, sizeof(options), "%d %d", -1000+2, entity);	menu2.AddItem(options, "Tous les chefs de mon job");
			Format(options, sizeof(options), "%d %d", -1000+3, entity);	menu2.AddItem(options, "Toutes les personnes de mon job");
			Format(options, sizeof(options), "%d %d", -1000+4, entity); menu2.AddItem(options, "Toutes les personnes de mon gang");
			Format(options, sizeof(options), "%d %d", -1000+5, entity); menu2.AddItem(options, "Tout le monde");
			
			menu2.Display(client, MENU_TIME_FOREVER);
		}
		else {
			DataPack dp = new DataPack();
			dp.WriteCell(i);
			dp.WriteCell(entity);
			rp_GetClientNextMessage(client, dp, cbTest);
			
			CPrintToChat(client, "{lightblue}[TSX-RP]{default} Entrez une phrase dans le chat pour remplacer cette ligne. Entrez \".\" pour la supprimer. ");
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
			if( g_hSignData[entity].Length <= 0 ) 
				g_hSignData[entity].PushString("Appuyez sur E pour modifier le panneau");
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


