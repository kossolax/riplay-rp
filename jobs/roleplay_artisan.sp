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

enum craft_type {
	craft_raw,
	craft_amount,
	craft_rate,
	craft_type_max
}
enum craft_book {
	Float:book_xp,
	Float:book_sleep,
	Float:book_focus,
	Float:book_speed,
	Float:book_steal,
	Float:book_luck,
	book_max
}

StringMap g_hReceipe;
int g_iItemCraftType[MAX_ITEMS];
int g_iItemCraftGoal[MAX_ITEMS];

bool g_bCanCraft[65][MAX_ITEMS];
bool g_bInCraft[65];
float g_flClientBook[65][view_as<int>(book_max)];

#define MENU_POS			view_as<float>({-1592.0, -2942.0, -2008.0})

int lstJOB[] =  { 11, 21, 31, 41, 51, 61, 71, 81, 111, 131, 171, 211, 221 };

public Plugin myinfo = {
	name = "Jobs: ARTISAN", author = "KoSSoLaX",
	description = "RolePlay - Jobs: Artisan",
	version = __LAST_REV__, url = "https://www.ts-x.eu"
};
int doRP_CanClientCraftForFree(int client, int itemID) {
	int a = 0;
	if( g_iItemCraftType[itemID] == -2 && g_iItemCraftGoal[itemID] == 0 ) {
		Call_StartForward(rp_GetForwardHandle(client, RP_PreClientCraft));
		Call_PushCell(client);
		Call_PushCell(itemID);
		Call_PushCellRef(a);
		Call_Finish();
	}
	return a;
}
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
	LoadTranslations("roleplay.artisan.phrases");
	
	RegServerCmd("rp_quest_reload", 		Cmd_Reload);	
	RegServerCmd("rp_item_crafttable",		Cmd_ItemCraftTable,		"RP-ITEM", 	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_craftbook",		Cmd_ItemCraftBook,		"RP-ITEM", 	FCVAR_UNREGISTERED);
	
	RegAdminCmd("rp_fatigue", CmdSetFatigue, ADMFLAG_ROOT);
	
	for (int i = 1; i <= MaxClients; i++)
		if( IsValidClient(i) )
			OnClientPostAdminCheck(i);
}
public void OnAllPluginsLoaded() {
	SQL_TQuery(rp_GetDatabase(), SQL_LoadReceipe, "SELECT `itemid`, `raw`, `amount`, CAST(SUBSTRING_INDEX(`extra_cmd`, 'rp_item_primal ', -1) AS INT) `rate` FROM `rp_craft` C INNER JOIN `rp_items` I ON C.`raw`=I.`id` ORDER BY `C`.`itemid` ASC", 0, DBPrio_Low);
	
	SQL_TQuery(rp_GetDatabase(), SQL_LoadReceipe2, "\
		SELECT * FROM ( \
			SELECT DISTINCT \
				I.id, I.nom, I.`extra_cmd`, I.description  \
				FROM `rp_craft` A INNER JOIN `rp_items` I ON A.`itemid`=I.`id`  \
				WHERE A.itemid NOT IN (  \
					SELECT raw FROM rp_craft  \
				)  \
				AND A.itemid IN (SELECT itemid FROM rp_craft C INNER JOIN rp_items I ON I.id=C.raw WHERE I.extra_cmd LIKE 'rp_item_raw%')  \
			) A WHERE `extra_cmd`<>'UNKNOWN'", 0, DBPrio_Low);
}
public Action CmdSetFatigue(int client, int args) {
	float f = GetCmdArgFloat(2);
	if( f >= 100.0 )
		f = 100.0;
	else if ( f <= 0.0 )
		f = 0.0;
	
	rp_SetClientFloat(GetCmdArgInt(1), fl_ArtisanFatigue, f / 100.0);
}
public void OnMapStart() {
	PrecacheModel(MODEL_TABLE1);
	PrecacheModel(MODEL_TABLE2);
	
	PrecacheModel(MODEL_TABLE_METAL);
	PrecacheModel(MODEL_TABLE_INGE);
	PrecacheModel(MODEL_TABLE_ALCH);
	
	PrecacheModel(MODEL_PANNEAU);
}
public Action Cmd_ItemCraftTable(int args) {
	int type = GetCmdArgInt(1);
	int client = GetCmdArgInt(2);
	int item_id = GetCmdArgInt(args);
	
	if( BuidlingTABLE(client, type) == 0 ) {
		ITEM_CANCEL(client, item_id);
	}
	
	return Plugin_Handled;
}
public Action Cmd_ItemCraftBook(int args) {
	char arg[32];
	GetCmdArg(1, arg, sizeof(arg));
	int client = GetCmdArgInt(2);
	
	craft_book type;
	
	if( StrEqual(arg, "level") ) {
		ClientGiveXP(client, 2500);
		displayStatsMenu(client);
		return Plugin_Handled;
	}
	else if( StrEqual(arg, "point") ) {
		rp_SetClientInt(client, i_ArtisanPoints, rp_GetClientInt(client, i_ArtisanPoints) + 1);
		displayStatsMenu(client);
		return Plugin_Handled;
	}
	else if( StrEqual(arg, "xp") )
		type = book_xp;
	else if( StrEqual(arg, "sleep") )
		type = book_sleep;
	else if( StrEqual(arg, "focus") )
		type = book_focus;
	else if( StrEqual(arg, "speed") )
		type = book_speed;
	else if( StrEqual(arg, "steal") )
		type = book_steal;
	else if( StrEqual(arg, "luck") )
		type = book_luck;
	
	if( g_flClientBook[client][type] > GetTickedTime() )
		g_flClientBook[client][type] += (60.0 * 6.0);
	else
		g_flClientBook[client][type] = GetTickedTime() + (60.0 * 6.0);
	
	displayStatsMenu(client);
	return Plugin_Handled;
}
public void SQL_LoadReceipe2(Handle owner, Handle hQuery, const char[] error, any client) {
	for (int i = 0; i < MAX_ITEMS; i++) {
		g_iItemCraftGoal[i] = 0;
	}
	while( SQL_FetchRow(hQuery) ) {
		int itemID = SQL_FetchInt(hQuery, 0);
		g_iItemCraftGoal[itemID] = 1;
	}
}
public void SQL_LoadReceipe(Handle owner, Handle hQuery, const char[] error, any client) {
	PrintToChatAll(error);
	if( g_hReceipe ) {
		g_hReceipe.Clear();
		delete g_hReceipe;
	}
	g_hReceipe = new StringMap();
	
	int[] data = new int[craft_type_max];
	char itemID[12];
	ArrayList magic;
	
	while( SQL_FetchRow(hQuery) ) {
		SQL_FetchString(hQuery, 0, itemID, sizeof(itemID));
		data[craft_raw] = SQL_FetchInt(hQuery, 1);
		data[craft_amount] = SQL_FetchInt(hQuery, 2);
		data[craft_rate] = SQL_FetchInt(hQuery, 3);
		
		if( !g_hReceipe.GetValue(itemID, magic) ) {
			magic = new ArrayList(craft_type_max, 0);
			g_hReceipe.SetValue(itemID, magic);
		}
		magic.PushArray(data, craft_type_max);
	}
	
	char tmp[128], tmp2[2][64];
	for (int i = 0; i < MAX_ITEMS; i++) {
		rp_GetItemData(i, item_type_extra_cmd, tmp, sizeof(tmp));
		ExplodeString(tmp, " ", tmp2, sizeof(tmp2), sizeof(tmp2[]));
		
		if( StrContains(tmp, "rp_item_primal") == 0 )
			g_iItemCraftType[i] = -1;
		else if( StrContains(tmp, "rp_item_raw") == 0 )
			g_iItemCraftType[i] = StringToInt(tmp2[1]);
		else
			g_iItemCraftType[i] = -2;
	}
	return;
}
public void OnClientPostAdminCheck(int client) {
	
	rp_HookEvent(client, RP_OnPlayerUse, 	fwdUse);
	rp_HookEvent(client, RP_OnPlayerBuild,	fwdOnPlayerBuild);
	rp_HookEvent(client, RP_PreClientStealItem, fwdCanStealItem);
	
	
	for(int i = 0; i < view_as<int>(book_max); i++)
		g_flClientBook[client][i] = 0.0;
	for(int i = 0; i < MAX_ITEMS; i++)
		g_bCanCraft[client][i] = false;
	g_bInCraft[client] = false;
	
	char szSteamID[65], query[1024];
	GetClientAuthId(client, AUTH_TYPE, szSteamID, sizeof(szSteamID));
	Format(query, sizeof(query), "SELECT `itemid` FROM `rp_craft_book` WHERE `steamid`='%s' AND `itemid`>0 AND `itemid`<%d;", szSteamID, MAX_ITEMS);
	SQL_TQuery(rp_GetDatabase(), SQL_LoadCraftbook, query, client);
	
	float f = rp_GetClientFloat(client, fl_ArtisanFatigue);
	if( f >= 1.0 )
		f = 1.0;
	else if( f<= 0.0  || IsNaN(f) )
		f = 0.0;
	rp_SetClientFloat(client, fl_ArtisanFatigue, f);
}
public void SQL_LoadCraftbook(Handle owner, Handle hQuery, const char[] error, any client) {
	while( SQL_FetchRow(hQuery) ) {
		g_bCanCraft[client][SQL_FetchInt(hQuery, 0)] = true;
	}
}
// ----------------------------------------------------------------------------
public Action fwdFrozen(int client, float& speed, float& gravity) {
	speed = 0.0;
	gravity = 0.0; 
	return Plugin_Stop;
}
public Action fwdUse(int client) {
	if( isNearTable(client) > 0 && !g_bInCraft[client] ) {
		displayArtisanMenu(client);
		return Plugin_Handled;
	}
	
	float vecOrigin[3];
	GetClientAbsOrigin(client, vecOrigin);
	
	if( rp_GetClientInt(client, i_ArtisanSpeciality) == 0 && GetVectorDistance(vecOrigin, MENU_POS) < 150.0) {
		Cmd_ChooseSpec(client, 0);
	}
	
	return Plugin_Continue;
}
public Action Cmd_ChooseSpec(int client, int confirm) {
	char tmp1[512], tmp2[256];
	
	if( confirm == 0 ) {
		Format(tmp1, sizeof(tmp1), "%T", "Artisan_SpecA", client);
		Format(tmp2, sizeof(tmp2), "%T", "Artisan_SpecB", client);
		String_WordWrap(tmp1, 50);
		String_WordWrap(tmp2, 50);
		
		Format(tmp1, sizeof(tmp1), "%T\n \n%s\n \n%s\n ", "Artisan_Menu", client, "Empty_String", tmp1, tmp2);
		
		Handle menu = CreateMenu(eventChooseSpec);
		SetMenuTitle(menu, tmp1);
		
		Format(tmp1, sizeof(tmp1), "%T", "Artisan_Spec_1", client); AddMenuItem(menu, "-1", tmp1);
		Format(tmp1, sizeof(tmp1), "%T", "Artisan_Spec_2", client); AddMenuItem(menu, "-2", tmp1);
		Format(tmp1, sizeof(tmp1), "%T", "Artisan_Spec_3", client); AddMenuItem(menu, "-3", tmp1);
		
		DisplayMenu(menu, client, MENU_TIME_DURATION);
	}
	else if( confirm < 0 ) {
		confirm = -confirm;
		
		Format(tmp1, sizeof(tmp1), "Artisan_Spec_%d", confirm);
		Format(tmp1, sizeof(tmp1), "%T", "Artisan_Confirm", client, tmp1);
		
		
		Handle menu = CreateMenu(eventChooseSpec);
		SetMenuTitle(menu, tmp1);
		
		Format(tmp1, sizeof(tmp1), "%d", confirm); 
		Format(tmp2, sizeof(tmp2), "%T", "Yes", client);
		AddMenuItem(menu, tmp1, tmp2);
		
		Format(tmp1, sizeof(tmp1), "0", confirm); 
		Format(tmp2, sizeof(tmp2), "%T", "No", client);
		AddMenuItem(menu, tmp1, tmp2);
		
		DisplayMenu(menu, client, MENU_TIME_DURATION);
	}
	else if( confirm > 0 ) {
		rp_SetClientInt(client, i_ArtisanSpeciality, confirm);
		rp_ClientSave(client);
		
		Format(tmp1, sizeof(tmp1), "Artisan_Spec_%d", confirm);
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Artisan_Change", client, tmp1);
	}
}
public int eventChooseSpec(Handle menu, MenuAction action, int client, int param2) {
	
	if( action == MenuAction_Select ) {
		char options[64];
		GetMenuItem(menu, param2, options, sizeof(options));
		
		Cmd_ChooseSpec(client, StringToInt(options));
	}
	else if( action == MenuAction_End ) {
		CloseHandle(menu);
	}
}
public Action fwdOnPlayerBuild(int client, float& cooldown) {
	if( rp_GetClientJobID(client) != 31 )
		return Plugin_Continue;
	
	bool recyc, spec;

	char classname[64], tmp[64];
	
	Format(classname, sizeof(classname), "rp_table");	
	int count;
	for(int i=1; i<=2048; i++) {
		if( !IsValidEdict(i) )
			continue;
		if( !IsValidEntity(i) )
			continue;
		
		GetEdictClassname(i, tmp, sizeof(tmp));
		
		if( StrEqual(classname, tmp) && rp_GetBuildingData(i, BD_owner) == client ) {
			count++;
			
			if( rp_GetBuildingData(i, BD_item_id) == 0 )
				recyc = true;
			if( rp_GetBuildingData(i, BD_item_id) != 0 )
				spec = true;
		}
	}
	
	int ent = 0;
	
	if( !recyc )
		ent = BuidlingTABLE(client, 0);
	else if( !spec && rp_GetClientInt(client, i_ArtisanSpeciality) > 0  )
		ent = BuidlingTABLE(client, rp_GetClientInt(client, i_ArtisanSpeciality));

	
	if( ent > 0 ) {
		rp_SetBuildingData(ent, BD_FromBuild, 1);
		SetEntProp(ent, Prop_Data, "m_iHealth", GetEntProp(ent, Prop_Data, "m_iHealth")/5);
		Entity_SetMaxHealth(ent, Entity_GetHealth(ent));
		
		rp_SetClientStat(client, i_TotalBuild, rp_GetClientStat(client, i_TotalBuild)+1);
		rp_ScheduleEntityInput(ent, 300.0, "Kill");
		cooldown = 120.0;
	}
	else 
		cooldown = 3.0;
	
	return Plugin_Stop;
}
public Action fwdCanStealItem(int client, int target) {
	if( g_flClientBook[target][book_steal] > GetTickedTime() && isNearTable(target) > 0 )
		return Plugin_Handled;
	return Plugin_Continue;
}
// ----------------------------------------------------------------------------
void displayArtisanMenu(int client) {
	if( isNearTable(client) == 0 )
		return;
	
	if( rp_GetClientInt(client, i_ArtisanLevel) == 0 ) {
		rp_SetClientInt(client, i_ArtisanLevel, 1);
	}
	
	
	int type = rp_GetBuildingData(isNearTable(client), BD_item_id);
	
	char tmp[128];
	Handle menu = CreateMenu(eventArtisanMenu);
	SetMenuTitle(menu, "%T\n ", "Artisan_Menu", client, "Empty_String");
	
	if( type == 0 ) {
		Format(tmp, sizeof(tmp), "%T", "Artisan_Build", client);
		AddMenuItem(menu, "build", tmp);
	
		Format(tmp, sizeof(tmp), "%T", "Artisan_Recycl", client);
		AddMenuItem(menu, "recycl", tmp);
		
		Format(tmp, sizeof(tmp), "%T", "Artisan_Learn", client);
		AddMenuItem(menu, "learn", tmp);
		
		Format(tmp, sizeof(tmp), "%T", "Artisan_Books", client);
		AddMenuItem(menu, "book", tmp);
	}
	else {
		
		Format(tmp, sizeof(tmp), "%T", "Artisan_Build", client);
		AddMenuItem(menu, "build -1", tmp, rp_GetClientInt(client, i_ArtisanSpeciality) == type ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED );

		Format(tmp, sizeof(tmp), "%T", "Artisan_Ask", client);
		AddMenuItem(menu, "ask -1", tmp);
	}	
	
	Format(tmp, sizeof(tmp), "%T", "Artisan_Infos", client);
	AddMenuItem(menu, "stats", tmp);
	
	DisplayMenu(menu, client, 30);
}
int getNumberOfCraftInJob(int client, int jobID) {
	static char tmp[32];
	ArrayList magic;
	
	int cpt = 0;
	for(int i = 0; i < MAX_ITEMS; i++) {
		if( !g_bCanCraft[client][i] && !doRP_CanClientCraftForFree(client, i) )
			continue;
		if( rp_GetItemInt(i, item_type_job_id) != jobID && jobID != -1 )
			continue;
		Format(tmp, sizeof(tmp), "%d", i);
		if( !g_hReceipe.GetValue(tmp, magic) )
			continue;
		
		cpt++;
	}
	return cpt;
}
void displayBuild2Menu(int client, int jobID, int target, int itemID, int amount, int pay, int confirm) {
	if( isNearTable(client) == 0 )
		return;
	
	int type = rp_GetBuildingData(isNearTable(client), BD_item_id);
	int clientItem[MAX_ITEMS];
	int[] data = new int[craft_type_max];
	for(int i = 0; i < MAX_ITEMS; i++)
		clientItem[i] = rp_GetClientItem(client, i);
	
	char tmp[64], tmp2[64];
	bool can;
	ArrayList magic;
	
	Handle menu = CreateMenu(eventArtisanMenu);
	if( target == 0 ) {
		SetMenuTitle(menu, "%T\n ", "Artisan_Menu", client, "Artisan_Ask");
		
		int cpt = 0;
		for (int i = 1; i < MaxClients; i++) {
			if( !IsValidClient(i) )
				continue;
			if( rp_GetClientInt(i, i_ArtisanSpeciality) != type )
				continue;
			if( !isNearTable(i) )
				continue;
			if( g_bInCraft[i] )
				continue;
			if( i == client )
				continue;
			
			Format(tmp, sizeof(tmp), "ask %d %d", jobID, i);
			
			GetClientName2(i, tmp2, sizeof(tmp2), true);
			Format(tmp2, sizeof(tmp2), "%T", "Artisan_Ask_Line", client, tmp2, rp_GetClientInt(i, i_ArtisanLevel), rp_GetClientFloat(i, fl_ArtisanFatigue) * 100.0);
			AddMenuItem(menu, tmp, tmp2);
			cpt++;
		}
		
		if( cpt == 0 ) {
			CPrintToChat(client, ""...MOD_TAG..." %T", "Artisan_Ask_None", client);
			delete menu;
			return;
		}
	}
	else if( itemID == 0 ) {
		SetMenuTitle(menu, "%T\n ", "Artisan_Menu", client, "Artisan_Build");
		
		for(int i = 0; i < MAX_ITEMS; i++) {
			if( type != g_iItemCraftType[i] )
				continue;
			
			Format(tmp, sizeof(tmp), "%d", i);
			if( !g_hReceipe.GetValue(tmp, magic) )
				continue;
						
			can = true;
			for (int j = 0; j < magic.Length; j++) {
				magic.GetArray(j, data);
				
				if( clientItem[data[craft_raw]] < data[craft_amount] ) {
					can = false;
					break;
				}
			}
			
			rp_GetItemData(i, item_type_name, tmp2, sizeof(tmp2)); 
			if( can ) {
				Format(tmp, sizeof(tmp), "ask %d %d %d", jobID, target, i);
				Format(tmp2, sizeof(tmp2), "[> %s <]", tmp2);
			}
			else {
				Format(tmp, sizeof(tmp), "book %d %d", jobID, i);
				Format(tmp2, sizeof(tmp2), "%s", tmp2);
			}
			
			AddMenuItem(menu, tmp, tmp2);
		}
	}
	else if( amount == 0 ) {
		
		rp_GetItemData(itemID, item_type_name, tmp2, sizeof(tmp2));
		SetMenuTitle(menu, "%T: %s\n ", "Artisan_Menu", client, "Artisan_Build", tmp2);
		
		Format(tmp, sizeof(tmp), "%d", itemID);
		if( !g_hReceipe.GetValue(tmp, magic) )
			return;
		
		int min = 999999999, delta;
		float duration = getDuration(target, itemID);
		
		for (int j = 0; j < magic.Length; j++) { // Pour chaque items de la recette:
			magic.GetArray(j, data);
			
			delta = clientItem[data[craft_raw]] / data[craft_amount];
			if( delta < min )
				min = delta;
		}
		
		Format(tmp, sizeof(tmp), "ask %d %d %d %d", jobID, target, itemID, min);
		Format(tmp2, sizeof(tmp2), "%T", "Artisan_Build_All", client, min, duration*min + (min*GetTickInterval()));
		AddMenuItem(menu, tmp, tmp2);
			
		for (int i = 1; i <= min; i++) {
			Format(tmp, sizeof(tmp), "ask %d %d %d %d", jobID, target, itemID, i);
			Format(tmp2, sizeof(tmp2), "%T", "Artisan_Build_Count", client, i, duration*i + (i*GetTickInterval()));
			AddMenuItem(menu, tmp, tmp2);
		}
	}
	else if( pay == 0 ) {
		char title[256];
		Format(title, sizeof(title), "%T\n%T\n ", "Artisan_Menu", client, "Artisan_Ask", "Artisan_Ask_Money", client, rp_GetClientInt(client, i_Money));
		
		SetMenuTitle(menu, title);
		
		int toPay[] = {-1, 1, 5, 10, 25, 50, 100, 250, 500, 1000};
		
		for (int i = 0; i < sizeof(toPay); i++) {			
			Format(tmp, sizeof(tmp), "ask %d %d %d %d %d", jobID, target, itemID, amount, toPay[i]);
			Format(tmp2, sizeof(tmp2), "%dx%d$ = %d$", amount, toPay[i] > 0 ? toPay[i] : 0, amount * (toPay[i] > 0 ? toPay[i] : 0));
			AddMenuItem(menu, tmp, tmp2, (rp_GetClientInt(client, i_Money) >= (amount * toPay[i])) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
		}
	}
	else if( confirm == 0 ) {
		char client_name[128], item_name[128];
		GetClientName2(client, client_name, sizeof(client_name), true);
		rp_GetItemData(itemID, item_type_name, item_name, sizeof(item_name));
		
		
		SetMenuTitle(menu, "%T\n ", "Artisan_Menu", target, "Artisan_Ask_Confirm", client_name, pay > 0 ? pay : 0, amount, item_name);
		
		Format(tmp, sizeof(tmp), "ask %d %d %d %d %d 1", jobID, client, itemID, amount, pay);
		Format(tmp2, sizeof(tmp2), "%T", "Yes", target);
		AddMenuItem(menu, tmp, tmp2);
		
		Format(tmp2, sizeof(tmp2), "%T", "No", target);
		AddMenuItem(menu, "", tmp2);
		
		DisplayMenu(menu, target, 30);
		return;
	}
	else {
		delete menu;
		startBuilding(client, target, itemID, amount, amount, 1, pay > 0 ? pay : 0);
		return;
	}
	
	DisplayMenu(menu, client, 30);
}
void displayBuildMenu(int client, int jobID, int itemID) {
	int type = rp_GetBuildingData(isNearTable(client), BD_item_id);
	int clientItem[MAX_ITEMS];
	int[] data = new int[craft_type_max];
	for(int i = 0; i < MAX_ITEMS; i++)
		clientItem[i] = rp_GetClientItem(client, i);
	
	char tmp[64], tmp2[64], prettyJob[2][64];
	bool can;
	ArrayList magic;
	
	Handle menu = CreateMenu(eventArtisanMenu);
	if( jobID == 0 ) {
		SetMenuTitle(menu, "%T\n ", "Artisan_Menu", client, "Artisan_Build");
		Format(tmp, sizeof(tmp), "%T", "Jobs_All", client);
		AddMenuItem(menu, "build -1", tmp);
		
		for (int i = 0; i < sizeof(lstJOB); i++) {
			int count = getNumberOfCraftInJob(client, lstJOB[i]);
			
			if( count > 0 ) {
				rp_GetJobData(lstJOB[i], job_type_name, tmp, sizeof(tmp));
				ExplodeString(tmp, " - ", prettyJob, sizeof(prettyJob), sizeof(prettyJob[]));
			
				Format(tmp, sizeof(tmp), "build %d", lstJOB[i]);
				Format(tmp2, sizeof(tmp2), "%s (%d)", prettyJob[1], count);
				AddMenuItem(menu, tmp, tmp2);
			}
		}
	}
	else if( itemID == 0 ) {
		SetMenuTitle(menu, "%T\n ", "Artisan_Menu", client, "Artisan_Build");
		
		for(int i = 0; i < MAX_ITEMS; i++) {
	
			if( type == 0 ) {
				if( g_iItemCraftType[i] == -2 && g_iItemCraftGoal[i] == 1 )
					continue;
				if( g_iItemCraftType[i] >= 0 )
					continue;
				if( !g_bCanCraft[client][i] && !doRP_CanClientCraftForFree(client, i) )
					continue;
				if( rp_GetItemInt(i, item_type_job_id) != jobID && jobID != -1 )
					continue;
			}
			else {
				if( g_iItemCraftType[i] == -1 )
					continue;
				if( g_iItemCraftType[i] >= 0 && type != g_iItemCraftType[i] )
					continue;
				if( g_iItemCraftType[i] == -2 && g_iItemCraftGoal[i] != 1 )
					continue;
			}
			
			Format(tmp, sizeof(tmp), "%d", i);
			if( !g_hReceipe.GetValue(tmp, magic) )
				continue;
						
			can = true;
			for (int j = 0; j < magic.Length; j++) {
				magic.GetArray(j, data);
				
				if( clientItem[data[craft_raw]] < data[craft_amount] ) {
					can = false;
					break;
				}
			}
			
			rp_GetItemData(i, item_type_name, tmp2, sizeof(tmp2)); 
			if( can || (type == 0 && doRP_CanClientCraftForFree(client, i)) ) {
				Format(tmp, sizeof(tmp), "build %d %d", jobID, i);
				Format(tmp2, sizeof(tmp2), "[> %s <]", tmp2);
			}
			else {
				Format(tmp, sizeof(tmp), "book %d %d", jobID, i);
				Format(tmp2, sizeof(tmp2), "%s", tmp2);
			}
			
			AddMenuItem(menu, tmp, tmp2);
		}
	}
	else {
		
		rp_GetItemData(itemID, item_type_name, tmp2, sizeof(tmp2));
		SetMenuTitle(menu, "%T: %s\n ", "Artisan_Menu", client, "Artisan_Build", tmp2);
		
		Format(tmp, sizeof(tmp), "%d", itemID);
		if( !g_hReceipe.GetValue(tmp, magic) )
			return;
		
		int min = 999999999, delta;
		float duration = getDuration(client, itemID);
		
		for (int j = 0; j < magic.Length; j++) { // Pour chaque items de la recette:
			magic.GetArray(j, data);
			
			delta = clientItem[data[craft_raw]] / data[craft_amount];
			if( delta < min )
				min = delta;
		}
		
		min += doRP_CanClientCraftForFree(client, itemID);
		
		Format(tmp, sizeof(tmp), "build %d %d %d", jobID, itemID, min);
		Format(tmp2, sizeof(tmp2), "%T", "Artisan_Build_All", client, min, duration*min + (min*GetTickInterval()));
		AddMenuItem(menu, tmp, tmp2);
			
		for (int i = 1; i <= min; i++) {
			Format(tmp, sizeof(tmp), "build %d %d %d", jobID, itemID, i);
			Format(tmp2, sizeof(tmp2), "%T", "Artisan_Build_Count", client, i, duration*i + (i*GetTickInterval()));
			AddMenuItem(menu, tmp, tmp2);
		}
	}
	
	DisplayMenu(menu, client, 30);
}
void displayRecyclingMenu(int client, int itemID) {
	
	if( rp_GetClientInt(client, i_ItemCount) == 0 ) {
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Artisan_Recycl_None", client);
		return;
	}
	
	Handle menu = CreateMenu(eventArtisanMenu);
	char tmp[64], tmp2[64];
	
	if( itemID == 0 ) {
		SetMenuTitle(menu, "%T\n ", "Artisan_Menu", client, "Artisan_Recycl");
		
		for(int i = 0; i < MAX_ITEMS; i++) {
			if( rp_GetClientItem(client, i) <= 0 )
				continue;
			if( getDuration(client, i) <= -0.1 )
				continue;
			
			rp_GetItemData(i, item_type_name, tmp2, sizeof(tmp2));
			Format(tmp, sizeof(tmp), "recycle %d", i);
			Format(tmp2, sizeof(tmp2), "%s (%i)",tmp2,rp_GetClientItem(client, i));
			AddMenuItem(menu, tmp, tmp2);
		}
	}
	else {
		rp_GetItemData(itemID, item_type_name, tmp2, sizeof(tmp2));
		SetMenuTitle(menu, "%T: %s\n ", "Artisan_Menu", client, "Artisan_Recycl", tmp2);
		
		float duration = getDuration(client, itemID);
		Format(tmp, sizeof(tmp), "recycle %d %d", itemID, rp_GetClientItem(client, itemID));
		Format(tmp2, sizeof(tmp2), "%T", "Artisan_Recycl_All", client, rp_GetClientItem(client, itemID), duration*rp_GetClientItem(client, itemID) + (rp_GetClientItem(client, itemID)*GetTickInterval()));
		AddMenuItem(menu, tmp, tmp2);
		
		for(int i = 1; i <= rp_GetClientItem(client, itemID); i++) {
			Format(tmp, sizeof(tmp), "recycle %d %d", itemID, i);
			Format(tmp2, sizeof(tmp2), "%T", "Artisan_Recycl_Count", client, i, duration*i + (i*GetTickInterval()));
			
			AddMenuItem(menu, tmp, tmp2);
		}
	}
	

	DisplayMenu(menu, client, 30);
}
void displayLearngMenu(char[] type, int client, int jobID, int itemID) {
	
	char tmp[64], tmp2[64], prettyJob[2][64];
	ArrayList magic;
	Handle menu = CreateMenu(eventArtisanMenu);
	int count = rp_GetClientInt(client, i_ArtisanPoints);
	int[] data = new int[craft_type_max];
	bool can, skip = StrEqual(type, "learn") ? false : true;
	if( !skip && count == 0 ) {
		CPrintToChat(client, ""...MOD_TAG..." %T", "Artisan_Learn_None", client);
		return;
	}
	
	SetMenuTitle(menu, "%T\n", "Artisan_Menu", client, skip ? "Artisan_Books" : "Artisan_Learn");
	
	if( jobID == 0 ) {
		for (int i = 0; i < sizeof(lstJOB); i++) {
			
			rp_GetJobData(lstJOB[i], job_type_name, tmp, sizeof(tmp));
			ExplodeString(tmp, " - ", prettyJob, sizeof(prettyJob), sizeof(prettyJob[]));
			Format(tmp, sizeof(tmp), "%s %d", type, lstJOB[i]);
			AddMenuItem(menu, tmp, prettyJob[1]);
		}
	}
	else if( itemID == 0 ) {
		for(int i = 0; i < MAX_ITEMS; i++) {
			if( g_bCanCraft[client][i]  && !skip )
				continue;
//			if( !g_bCanCraft[client][i]  && skip )
//				continue;
			if( rp_GetItemInt(i, item_type_job_id) != jobID )
				continue;
			Format(tmp, sizeof(tmp), "%d", i);
			if( !g_hReceipe.GetValue(tmp, magic) )
				continue;
			can = true;
			if( count*250 < rp_GetItemInt(i, item_type_prix) && !skip )
				can = false;
			
			rp_GetItemData(i, item_type_name, tmp2, sizeof(tmp2));
			if( StrContains(tmp2, "MISSING") == 0 )
				continue;
			Format(tmp, sizeof(tmp), "%s %d %d", type, jobID, i);
			Format(tmp2, sizeof(tmp2), "%s (%i)",tmp2, RoundToCeil(float(rp_GetItemInt(i, item_type_prix)) / 250.0));
			
			AddMenuItem(menu, tmp, tmp2, (can?ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED));
		}
	}
	else {
		rp_GetItemData(itemID, item_type_name, tmp, sizeof(tmp));
		SetMenuTitle(menu, "%T: %s\n ", "Artisan_Menu", client, "Artisan_Books", tmp);
		
		Format(tmp, sizeof(tmp), "%d", itemID);
		g_hReceipe.GetValue(tmp, magic);
		
		for (int j = 0; j < magic.Length; j++) { // Pour chaque items de la recette:
			magic.GetArray(j, data);
			
			rp_GetItemData(data[craft_raw], item_type_name, tmp, sizeof(tmp));
			Format(tmp2, sizeof(tmp2), "%3dx %s (%d%%)", data[craft_amount], tmp, data[craft_rate]);
			AddMenuItem(menu, tmp2, tmp2, ITEMDRAW_DISABLED);
		}
		if( !skip )  {
			Format(tmp, sizeof(tmp), "%s %d %d 1", type, jobID, itemID);
			Format(tmp2, sizeof(tmp2), "%T", "Artisan_Learn", client);
			AddMenuItem(menu, tmp, tmp2);
		}
	}
	
	DisplayMenu(menu, client, 30);
}
void displayStatsMenu(int client) {
	Handle menu = CreateMenu(eventArtisanMenu);
	SetMenuTitle(menu, "%T:\n ", "Artisan_Menu", client, "Artisan_Infos");
	
	addStatsToMenu(client, client, menu);
	
	char tmp[64];
	
	if( g_flClientBook[client][book_xp] > GetTickedTime() ) {
		Format(tmp, sizeof(tmp), "%T", "Artisan_Infos_Bonus_XP", (g_flClientBook[client][book_xp] - GetTickedTime())/60.0);
		AddMenuItem(menu, tmp, tmp, ITEMDRAW_DISABLED);
	}
	if( g_flClientBook[client][book_sleep] > GetTickedTime() ) {
		Format(tmp, sizeof(tmp), "%T", "Artisan_Infos_Bonus_SLEEP", (g_flClientBook[client][book_sleep] - GetTickedTime()) / 60.0);
		AddMenuItem(menu, tmp, tmp, ITEMDRAW_DISABLED);
	}
	if( g_flClientBook[client][book_focus] > GetTickedTime() ) {
		Format(tmp, sizeof(tmp), "%T", "Artisan_Infos_Bonus_FOCUS", (g_flClientBook[client][book_focus] - GetTickedTime()) / 60.0);
		AddMenuItem(menu, tmp, tmp, ITEMDRAW_DISABLED);
	}
	if( g_flClientBook[client][book_speed] > GetTickedTime() ) {
		Format(tmp, sizeof(tmp), "%T", "Artisan_Infos_Bonus_SPEED", (g_flClientBook[client][book_speed] - GetTickedTime()) / 60.0);
		AddMenuItem(menu, tmp, tmp, ITEMDRAW_DISABLED);
	}
	if( g_flClientBook[client][book_luck] > GetTickedTime() ) {
		Format(tmp, sizeof(tmp), "%T", "Artisan_Infos_Bonus_LUCK", (g_flClientBook[client][book_luck] - GetTickedTime()) / 60.0);
		AddMenuItem(menu, tmp, tmp, ITEMDRAW_DISABLED);
	}
	if( g_flClientBook[client][book_steal] > GetTickedTime() ) {
		Format(tmp, sizeof(tmp), "%T", "Artisan_Infos_Bonus_STEAL", (g_flClientBook[client][book_steal] - GetTickedTime()) / 60.0);
		AddMenuItem(menu, tmp, tmp, ITEMDRAW_DISABLED);
	}
	
	
	DisplayMenu(menu, client, 30);
}
public int eventArtisanMenu(Handle menu, MenuAction action, int client, int param2) {
	
	if( action == MenuAction_Select ) {
		char options[64], buffer[7][16];
		ArrayList magic;
		
		GetMenuItem(menu, param2, options, sizeof(options));
		ExplodeString(options, " ", buffer, sizeof(buffer), sizeof(buffer[]));
		
		if( StrContains(options, "build", false) == 0 ) {
			if( StringToInt(buffer[3]) == 0 )
				displayBuildMenu(client, StringToInt(buffer[1]), StringToInt(buffer[2]));
			else if( g_hReceipe.GetValue(buffer[2], magic) )		
				startBuilding(client, client, StringToInt(buffer[2]), StringToInt(buffer[3]), StringToInt(buffer[3]), 1, 0);
		}
		else if( StrContains(options, "recycl", false) == 0 ) {
			if( StringToInt(buffer[2]) == 0 )
				displayRecyclingMenu(client, StringToInt(buffer[1]));
			else if( g_hReceipe.GetValue(buffer[1], magic) )
				startBuilding(client, client, StringToInt(buffer[1]), StringToInt(buffer[2]), StringToInt(buffer[2]), -1, 0);
		}
		else if( StrContains(options, "learn", false) == 0 ) {
			if( StringToInt(buffer[3]) == 0 )
				displayLearngMenu("learn", client, StringToInt(buffer[1]), StringToInt(buffer[2]));
			else {
				int itemID = StringToInt(buffer[2]);
				int count = rp_GetClientInt(client, i_ArtisanPoints);
				if( count*250 < rp_GetItemInt(itemID, item_type_prix) ) {
					return;
				}
				
				g_bCanCraft[client][itemID] = true;
				rp_SetClientInt(client, i_ArtisanPoints, count - RoundToCeil(float(rp_GetItemInt(itemID, item_type_prix)) / 250.0));
				char query[1024], szSteamID[32];
				GetClientAuthId(client, AUTH_TYPE, szSteamID, sizeof(szSteamID));
				Format(query, sizeof(query), "INSERT INTO `rp_craft_book` (`steamid`, `itemid`) VALUES ('%s', '%d');", szSteamID, itemID);
				SQL_TQuery(rp_GetDatabase(), SQL_QueryCallBack, query);
			}
		}
		else if( StrContains(options, "book", false) == 0 ) {
			if( StringToInt(buffer[3]) == 0 )
				displayLearngMenu("book", client, StringToInt(buffer[1]), StringToInt(buffer[2]));
		}
		else if( StrContains(options, "stats", false) == 0 ) {
			displayStatsMenu(client);
		}
		else if( StrContains(options, "ask", false) == 0 ) {
			displayBuild2Menu(client, StringToInt(buffer[1]), StringToInt(buffer[2]), StringToInt(buffer[3]), StringToInt(buffer[4]), StringToInt(buffer[5]), StringToInt(buffer[6]));
		}
	}
	else if( action == MenuAction_End ) {
		CloseHandle(menu);
	}
}
// ----------------------------------------------------------------------------
void startBuilding(int client, int target, int itemID, int total, int amount, int positive, int price) {
	
	float duration = getDuration(client, itemID);
	g_bInCraft[client] = g_bInCraft[target] = true;
	
//	ServerCommand("sm_effect_particles %d dust_embers %f facemask", client, duration);
	
	MENU_ShowCraftin(client, client, total, amount, positive, 0, RoundToCeil(duration));
	if( client != target )
		MENU_ShowCraftin(target, client, total, amount, positive, 0, RoundToCeil(duration));
	
	if( amount > 0 && duration >= -0.0001 ) {
		Handle dp;
		CreateDataTimer(duration, stopBuilding, dp, TIMER_DATA_HNDL_CLOSE|TIMER_REPEAT);
		WritePackCell(dp, client);
		WritePackCell(dp, target);
		WritePackCell(dp, itemID);
		WritePackCell(dp, total);
		WritePackCell(dp, amount);
		WritePackCell(dp, positive);
		WritePackCell(dp, price);
		WritePackCell(dp, 0);
	}
}
public Action stopBuilding(Handle timer, Handle dp) {
	ResetPack(dp);
	int client = ReadPackCell(dp);
	int target = ReadPackCell(dp);
	int itemID = ReadPackCell(dp);
	int total = ReadPackCell(dp);
	int amount = ReadPackCell(dp);
	int positive = ReadPackCell(dp);
	int price = ReadPackCell(dp);
	int fatigue = ReadPackCell(dp);
	bool failed = false;
	bool free = (doRP_CanClientCraftForFree(client, itemID) > 0);
	
	if( !IsValidClient(client) || !IsValidClient(target) ) {
		g_bInCraft[client] = g_bInCraft[target] = false;
		return Plugin_Stop;
	}
	if( isNearTable(client) == 0 ) {
		CPrintToChat(client, ""...MOD_TAG..." %T", "Build_CannotHere", client);
		g_bInCraft[client] = g_bInCraft[target] = false;
		return Plugin_Stop;
	}
	if( isNearTable(target) == 0 ) {
		CPrintToChat(target, ""...MOD_TAG..." %T", "Build_CannotHere", target);
		g_bInCraft[client] = g_bInCraft[target] = false;
		return Plugin_Stop;
	}
	if( client != target && price > 0 ) {
		if( rp_GetClientInt(target, i_Money) < price ) {
			CPrintToChat(target, ""...MOD_TAG..." %T", "Error_NotEnoughtMoney", client);
			g_bInCraft[client] = g_bInCraft[target] = false;
			return Plugin_Stop;
		}
	}
	
	int pc = RoundFloat(rp_GetClientFloat(client, fl_ArtisanFatigue) * 100.0) * RoundFloat(rp_GetClientFloat(client, fl_ArtisanFatigue) * 100.0);
	if( Math_GetRandomInt(1, 100*100) <= pc ) {
		
		fatigue++;
		failed = true;
		
		if( g_flClientBook[client][book_focus] > GetTickedTime() && Math_GetRandomInt(1, 4) == 4 ) {
			fatigue--;
			failed = false;
		}
	}
	
	ArrayList magic;
	int[] data = new int[craft_type_max];
	char tmp[64];
	Format(tmp, sizeof(tmp), "%d", itemID);
	
	if( !g_hReceipe.GetValue(tmp, magic) ) {
		g_bInCraft[client] = g_bInCraft[target] = false;
		return Plugin_Stop;
	}
		
	if( positive > 0 ) {
		if( !free ) {
			for (int j = 0; j < magic.Length; j++) { // Pour chaque items de la recette:
				magic.GetArray(j, data);
				
				if( data[craft_amount] > rp_GetClientItem(target, data[craft_raw]) ) {
					g_bInCraft[client] = g_bInCraft[target] = false;
					return Plugin_Stop;
				}
			}
		}
	}
	else {
		if( rp_GetClientItem(target, itemID) <= 0 ) {
			g_bInCraft[client] = g_bInCraft[target] = false;
			return Plugin_Stop;
		}
	}
	int level = rp_GetClientInt(client, i_ArtisanLevel);
	float flFatigue = rp_GetClientFloat(client, fl_ArtisanFatigue);
	float f = float(rp_GetItemInt(itemID, item_type_prix)) / 41100.0 / Logarithm(float(level+1), 1.33);
	if( g_flClientBook[client][book_sleep] > GetTickedTime() )
		f -= (f / 2.0);
	
	flFatigue += f;
	
	if( flFatigue >= 1.0 )
		flFatigue = 1.0;
	if( flFatigue <= 0.0 || IsNaN(f) )
		flFatigue = 0.0;
	rp_SetClientFloat(client, fl_ArtisanFatigue, flFatigue);
	
	if( positive > 0 ) { // Craft
		if( !failed ) { // Si on échoue pas on give l'item
			rp_ClientGiveItem(target, itemID, positive);
			if( client != target && price > 0 ) {
				rp_ClientMoney(target, i_Money, -price);
				rp_ClientMoney(client, i_Money, price);
			}

			Call_StartForward(rp_GetForwardHandle(client, RP_PostClientCraft));
			Call_PushCell(client);
			Call_PushCell(itemID);
			Call_Finish();
		}
		
		if( g_flClientBook[client][book_luck] > GetTickedTime() && Math_GetRandomInt(0, 1000) < 50 )
			rp_ClientGiveItem(target, itemID, positive);

		int xp = 0;
		for (int i = 0; i < magic.Length; i++) {  // Pour chaque items de la recette:
			magic.GetArray(i, data);
			
			int prix = rp_GetItemInt(data[craft_raw], item_type_prix);
			if( prix <= 0 )
				prix = 25;
			
			if( !failed )
				xp = xp + (prix * data[craft_amount]);
			
			if( !free )
				rp_ClientGiveItem(target, data[craft_raw], -data[craft_amount]);		
		}
		
		if( xp > 0 ) {
			ClientGiveXP(client, xp);
		}
	}
	else if( !failed ) { // Recyclage, si on le rate pas on prend l'item.
		rp_ClientGiveItem(target, itemID, positive);
		if( g_flClientBook[client][book_luck] > GetTickedTime() && Math_GetRandomInt(0, 1000) < 50 )
			rp_ClientGiveItem(target, itemID, -positive);
		
		int focus = 0;
		if( g_flClientBook[client][book_focus] > GetTickedTime() )
			focus += 25;
		
		for (int i = 0; i < magic.Length; i++) {  // Pour chaque items de la recette:
			magic.GetArray(i, data);
				
			for (int j = 0; j < data[craft_amount]; j++) { // Pour chaque quantité nécessaire de la recette
			
				if( (float(data[craft_rate]) + (float(level) / 100.0 * float(data[craft_rate])) + float(focus)) >= Math_GetRandomFloat(0.0, 100.0) ) { // De facon aléatoire
					//ClientGiveXP(client, rp_GetItemInt(data[craft_raw], item_type_prix));
					rp_ClientGiveItem(target, data[craft_raw]);
				}
			}	
		}
	}
	
	ResetPack(dp);
	WritePackCell(dp, client);
	WritePackCell(dp, target);
	WritePackCell(dp, itemID);
	WritePackCell(dp, total);
	WritePackCell(dp, --amount);
	WritePackCell(dp, positive);
	WritePackCell(dp, price);
	WritePackCell(dp, fatigue);
	
	float duration = getDuration(client, itemID);
	MENU_ShowCraftin(client, client, total, amount, positive, fatigue, RoundToCeil(duration));
	if( client != target )
		MENU_ShowCraftin(target, client, total, amount, positive, fatigue, RoundToCeil(duration));
	
	
	if( amount <= 0 ) {
		g_bInCraft[client] = g_bInCraft[target] = false;
		return Plugin_Stop;
	}
//	ServerCommand("sm_effect_particles %d dust_embers %f facemask", client, getDuration(client, itemID));
	
	return Plugin_Continue;
}
// ----------------------------------------------------------------------------
void MENU_ShowCraftin(int client, int target, int total, int amount, int positive, int fatigue, int time) {
	char tmp[64];
	Handle menu = CreateMenu(eventArtisanMenu);
	
	SetMenuTitle(menu, "%T:\n ", "Artisan_Menu", client, positive > 0 ? "Artisan_Build" : "Artisan_Recycl");
	
	float percent = (float(total) - float(amount)) / float(total);
	
	rp_Effect_LoadingBar(tmp, sizeof(tmp), percent );
	AddMenuItem(menu, tmp, tmp, ITEMDRAW_DISABLED);
	
	Format(tmp, sizeof(tmp), "%T", "Artisan_Status", client, total-amount-fatigue, total, fatigue);
	AddMenuItem(menu, tmp, tmp, ITEMDRAW_DISABLED);
	
	addStatsToMenu(client, target, menu);
	
	DisplayMenu(menu, client, time+1);
}
float getDuration(int client, int itemID) {
	if( rp_GetItemInt(itemID, item_type_job_id) == 91 )
		return -1.0;
	
	char tmp[12];
	int[] data = new int[craft_type_max];
	Format(tmp, sizeof(tmp), "%d", itemID);
	
	ArrayList magic;
	if( !g_hReceipe.GetValue(tmp, magic) )
		return -1.0;
	
	
	float duration = 0.0;
	for (int i = 0; i < magic.Length; i++) {
		magic.GetArray(i, data);
		
		if( g_iItemCraftType[itemID] == -2 && g_iItemCraftGoal[itemID] == 0 )
			duration += 0.02 * data[craft_amount];
		else
			duration += 1.0 * data[craft_amount];
	}
	
	if( g_iItemCraftType[itemID] == -2 && g_iItemCraftGoal[itemID] == 0 ) {
		if( g_flClientBook[client][book_speed] > GetTickedTime() )
			duration -= (duration / 2.0);
	}
	else {
		if( g_flClientBook[client][book_speed] > GetTickedTime() )
			duration -= (duration / 4.0);
		
		duration = duration / ((float(rp_GetClientInt(client, i_ArtisanLevel)) / 25.0) + 1.0);
	}
	
	if( duration < 0.01 )
		duration = 0.01;
	return duration;
}
int getNextLevel(int level) {
	return RoundToFloor(Pow(float(level), 1.750) * 750.0);
}
int ClientGiveXP(int client, int xp) {
	if( g_flClientBook[client][book_xp] > GetTickedTime() )
		xp += (xp / 2);
	
	int baseXP = rp_GetClientInt(client, i_ArtisanXP) + xp;
	int baseLVL = rp_GetClientInt(client, i_ArtisanLevel);
	int basePoint = rp_GetClientInt(client, i_ArtisanPoints);
	
	while( baseXP >= getNextLevel(baseLVL) ) {
		baseXP -= getNextLevel(baseLVL);
		baseLVL++;
		basePoint += Math_GetRandomInt(1, 3);
	}
	
	rp_SetClientInt(client, i_ArtisanXP, baseXP);
	rp_SetClientInt(client, i_ArtisanLevel, baseLVL);
	rp_SetClientInt(client, i_ArtisanPoints, basePoint);
	
}
int isNearTable(int client) {
	char classname[65];
	int target = rp_GetClientTarget(client);
	if( IsValidEdict(target) && IsValidEntity(target) ) {
		GetEdictClassname(target, classname, sizeof(classname));
		if( StrContains(classname, "rp_table") == 0 && rp_IsEntitiesNear(client, target, true) )
			return target;
	}
	return 0;
}

void addStatsToMenu(int client, int target, Handle menu) {
	char tmp[128], tmp2[32];
	Format(tmp, sizeof(tmp), "Niveau: %d", rp_GetClientInt(target, i_ArtisanLevel));
	AddMenuItem(menu, tmp, tmp, ITEMDRAW_DISABLED);
	
	float pc = rp_GetClientInt(target, i_ArtisanXP) / float(getNextLevel(rp_GetClientInt(target, i_ArtisanLevel)));
	if( pc != pc )
		pc = 0.0;
	
	rp_Effect_LoadingBar(tmp2, sizeof(tmp2),  pc );
	Format(tmp, sizeof(tmp), "%T", "Artisan_XP", client, tmp2, pc*100.0 );
	AddMenuItem(menu, tmp, tmp, ITEMDRAW_DISABLED);
	
	tmp2[0] = 0; pc = rp_GetClientFloat(target, fl_ArtisanFatigue);
	rp_Effect_LoadingBar(tmp2, sizeof(tmp2),  pc );
	Format(tmp, sizeof(tmp), "%T", "Artisan_SLEEP", client, tmp2, pc*100.0 );
	AddMenuItem(menu, tmp, tmp, ITEMDRAW_DISABLED);
	
	Format(tmp, sizeof(tmp), "%T", "Artisan_POINTS", client, rp_GetClientInt(target, i_ArtisanPoints));
	AddMenuItem(menu, tmp, tmp, ITEMDRAW_DISABLED);
}
// ----------------------------------------------------------------------------
int BuidlingTABLE(int client, int type) {
	
	if( !rp_IsBuildingAllowed(client) )
		return 0;	
	
	char classname[64], tmp[64];
	
	Format(classname, sizeof(classname), "rp_table", client);	
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
			if( count >= 4 ) {
				CPrintToChat(client, ""...MOD_TAG..." %T", "Build_TooMany", client);
				return 0;
			}
		}
	}

	EmitSoundToAllAny("player/ammo_pack_use.wav", client);
	
	int ent = CreateEntityByName("prop_physics_override");
	DispatchKeyValue(ent, "classname", classname);
	
	switch(type) {
		case 0: {
			if( Math_GetRandomInt(0, 1) )
				DispatchKeyValue(ent, "model", MODEL_TABLE1);
			else
				DispatchKeyValue(ent, "model", MODEL_TABLE2);
		}
		case 1: {
			DispatchKeyValue(ent, "model", MODEL_TABLE_METAL);
		}
		case 2: {
			DispatchKeyValue(ent, "model", MODEL_TABLE_INGE);
		}
		case 3: {
			DispatchKeyValue(ent, "model", MODEL_TABLE_ALCH);
		}
	}
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
	
	CreateTimer(3.0, BuildingTABLE_post, ent);
	rp_SetBuildingData(ent, BD_owner, client);
	rp_SetBuildingData(ent, BD_FromBuild, 0);
	rp_SetBuildingData(ent, BD_item_id, type);
	Entity_SetMaxHealth(ent, Entity_GetHealth(ent));
	
	return ent;
}
public Action BuildingTABLE_post(Handle timer, any entity) {
	int client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	
	rp_Effect_BeamBox(client, entity, NULL_VECTOR, 255, 255, 0);
	SetEntProp(entity, Prop_Data, "m_takedamage", 2);
	HookSingleEntityOutput(entity, "OnBreak", BuildingTABLE_break);
	SDKHook(entity, SDKHook_OnTakeDamage, DamageMachine);
	return Plugin_Handled;
}
public Action DamageMachine(int victim, int &attacker, int &inflictor, float &damage, int &damagetype) {
	if( IsBadGuy(attacker) ) {
		damage = 0.0;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}
public void BuildingTABLE_break(const char[] output, int caller, int activator, float delay) {
	
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
