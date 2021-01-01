#if defined _roleplay_stock_database_included
#endinput
#endif
#define _roleplay_stock_database_included

#if defined ROLEPLAY_SUB
	#include "../roleplay.sp"
#else
	#include "roleplay.sp"
#endif


void loadServerRules(Handle hQuery) {
	char split[2] = ";";	
	int size = (BUFFER_SIZE+SQL_FetchSize(hQuery, 8));
	char[] data = new char[size];
	SQL_FetchString(hQuery, 8, data, size);
		
	char buffer[BUFFER_SIZE], buffer2[BUFFER_SIZE], szData[3][BUFFER_SIZE];
		
	// ------------
	//	Stocker sous le format: type,id,amount;type,id,amount;
	//
	while( SplitString(data, split, buffer, BUFFER_SIZE) != -1 ) {
		
		Format(buffer2, BUFFER_SIZE, "%s%s", buffer, split);
		RemoveString(data, buffer2, false);
		
		ExplodeString(buffer, ",", szData, sizeof(szData), BUFFER_SIZE);		
		g_iServerRules[StringToInt(szData[0])][StringToInt(szData[1])] = StringToInt(szData[2]);
	}
}
void storeServerRules() {
	int size = sizeof(g_iServerRules) * 12 * 3;
	char[] storage = new char[size];
	
	for (int i = 0; i < sizeof(g_iServerRules); i++) {
		if( g_iServerRules[i][rules_Enabled] > 0 ) {
			for (int j = 0; j < sizeof(g_iServerRules[]); j++)
				Format(storage, size, "%s%d,%d,%d;", storage, i, j, g_iServerRules[i][j]);
		}
	}
	
	char query[4096];
	Format(query, sizeof(query), "UPDATE `rp_servers` SET `rules`='%s';", storage);
	SQL_TQuery(g_hBDD, SQL_QueryCallBack, query);
}
void LoadServerDatabase() {
	char query[1024], strIP[64];
	Handle port_cvar = FindConVar("hostport");
	int i=0;

	Handle hostip = FindConVar("hostip");
	int longip = GetConVarInt(hostip);
	
	Format(strIP, sizeof(strIP),"%d.%d.%d.%d", (longip >> 24) & 0xFF, (longip >> 16) & 0xFF, (longip >> 8 )	& 0xFF, longip & 0xFF);
	Format(query, sizeof(query), "SELECT `id`, `alias`, `bunkerCap`, `capVilla`, `capItem`, `villaOwner`, U.`name` as `villaOwnerName`, `pvprow`, S.`rules`, `maire`, `annonces`, U2.`name` as `mairieName` FROM `rp_servers` S LEFT JOIN `rp_users` U ON U.`steamid`=S.`villaOwner` LEFT JOIN `rp_users` U2 ON U2.`steamid`=S.`maire` WHERE S.`ip`='%s' AND `port`='%i' LIMIT 1;", strIP, GetConVarInt(port_cvar));
	
	Handle hQuery;
	g_iSID = -1;

	SQL_LockDatabase(g_hBDD);
	SQL_Query(g_hBDD, "SET NAMES 'utf8'");
	
	if ((hQuery = SQL_Query(g_hBDD, query)) == INVALID_HANDLE) {
		LogToGame(query);
		SetFailState("ERREUR FATAL: Impossible de récuperer le sID: %s [%s:%i]", g_szError, strIP, GetConVarInt(port_cvar));
	} 
	else {
		while( SQL_FetchRow(hQuery) ) {

			g_iSID = SQL_FetchInt(hQuery, 0);
			char tmp[64];
			SQL_FetchString(hQuery, 1, tmp, 63);
			PrintToServer("[TSX-RP] Reçu sID: %i - enregistré en tant que %s", g_iSID, tmp);

			g_iCapture[cap_bunker] = SQL_FetchInt(hQuery, 2);
			g_iCapture[cap_villa] = SQL_FetchInt(hQuery, 3);
			//g_iCapture[cap_disableItem] = SQL_FetchInt(hQuery, 5);
			SQL_FetchString(hQuery, 5, g_szVillaOwner[villaOwnerID], sizeof(g_szVillaOwner[]));
			if( !SQL_IsFieldNull(hQuery, 6) )
				SQL_FetchString(hQuery, 6, g_szVillaOwner[villaOwnerName], sizeof(g_szVillaOwner[]));
			
			g_iCapture[cap_pvpRow] = SQL_FetchInt(hQuery, 7);
			loadServerRules(hQuery);
			SQL_FetchString(hQuery, 9, g_szVillaOwner[mairieID], sizeof(g_szVillaOwner[]));
			SQL_FetchString(hQuery, 10, g_szVillaOwner[annonceID], sizeof(g_szVillaOwner[]));
			
			char path[256];
			Format(path, sizeof(path), "materials/DeadlyDesire/annonces/%s.vmt", g_szVillaOwner[annonceID]);
			
			if( FileExists(path) )
				AddFileToDownloadsTable(path);
			Format(path, sizeof(path), "materials/DeadlyDesire/annonces/%s.vtf", g_szVillaOwner[annonceID]);
			
			if( FileExists(path) )
				AddFileToDownloadsTable(path);
			
			
			if( !SQL_IsFieldNull(hQuery, 11) )
				SQL_FetchString(hQuery, 11, g_szVillaOwner[maireName], sizeof(g_szVillaOwner[]));
		}

		if( g_iSID <= 0 ) {
			LogToGame(query);
			SetFailState("ERREUR FATAL: Impossible de valider le sID: %s [%s:%i]", g_szError, strIP, GetConVarInt(port_cvar));
			return;
		}
	}
	
	Format(query, sizeof(query), "SELECT `bf_date`, `bf_reduction` FROM `rp_servers` WHERE `id` = %i", g_iSID);

	if ((hQuery = SQL_Query(g_hBDD, query)) == INVALID_HANDLE) {
		g_iBlackFriday[0] = g_iBlackFriday[1] = 0;
		g_bIsBlackFriday = false;
	}
	else {
		if( SQL_FetchRow(hQuery) ) {
			g_iBlackFriday[0] = SQL_FetchInt(hQuery, 0);
			g_iBlackFriday[1] = SQL_FetchInt(hQuery, 1);

			// 02/01/2020 00h01 > 01/01/2020  00h00  AND 02/01/2020 00h01 < 03/01/2020 00h00
			if(GetTime() > g_iBlackFriday[0] && GetTime() < g_iBlackFriday[0] + 24*60*60) {
				g_bIsBlackFriday = true;
			}
		} else {
			g_iBlackFriday[0] = g_iBlackFriday[1] = 0;
			g_bIsBlackFriday = false;
		}
	}

	//
	// La première chose à s'occuper, est du précache...
	if ((hQuery = SQL_Query(g_hBDD, "SELECT `path`, `is_precache` FROM `rp_download` ORDER BY `path` ASC;")) == INVALID_HANDLE) {
		SetFailState("ERREUR FATAL: Impossible de récuperer la liste pour le precache: %s", g_szError);
	}
	while( SQL_FetchRow(hQuery) ) {
		char path[128];
		SQL_FetchString(hQuery, 0, path, 127);
		int is_precache = SQL_FetchInt(hQuery, 1);

		AddFileToDownloadsTable(path);
		if( is_precache ) {
			if( StrContains(path, "materials/", false) == 0 || StrContains(path, "models/", false) == 0 ) {
				PrecacheModel(path);
			}
			else if( StrContains(path, "sound/", false) == 0 ) {
				ReplaceString(path, 127, "sound/", "", false);
				PrecacheSoundAny(path);
				
			}
			else {
				PrecacheGeneric(path);
			}
		}
	}
	//
	if ((hQuery = SQL_Query(g_hBDD, "UPDATE `rp_users2` SET `done`='0';")) == INVALID_HANDLE) {
		SetFailState(":(");
	}
	//
	//
	// Chargement des jobs
	if ((hQuery = SQL_Query(g_hBDD, "SELECT `job_id`, `job_name`, `is_boss`, `own_boss`, `pay`, `capital`, `subside`, `quota`, `current`, `tag`, `co_chef` FROM `rp_jobs`")) == INVALID_HANDLE) {
		SetFailState("ERREUR FATAL: Impossible de récuperer la liste des jobs: %s", g_szError);
	}

	while( SQL_FetchRow(hQuery) ) {
		int id = SQL_FetchInt(hQuery, 0);

		SQL_FetchString(hQuery, 1, g_szJobList[id][job_type_name], 127);
		SQL_FetchString(hQuery, 2, g_szJobList[id][job_type_isboss], 127);
		SQL_FetchString(hQuery, 3, g_szJobList[id][job_type_ownboss], 127);
		SQL_FetchString(hQuery, 4, g_szJobList[id][job_type_pay], 127);
		SQL_FetchString(hQuery, 5, g_szJobList[id][job_type_capital], 127);
		SQL_FetchString(hQuery, 6, g_szJobList[id][job_type_subside], 127);
		SQL_FetchString(hQuery, 7, g_szJobList[id][job_type_quota], 127);
		SQL_FetchString(hQuery, 8, g_szJobList[id][job_type_current], 127);
		SQL_FetchString(hQuery, 9, g_szJobList[id][job_type_tag], 127);
		SQL_FetchString(hQuery, 10, g_szJobList[id][job_type_cochef], 127);

	}
	//
	// Chargement des items
	if ((hQuery = SQL_Query(g_hBDD, "SELECT `id`, `nom`, `extra_cmd`, `reuse_delay`, `give_hp`, `job_id`, `prix`, `auto_use`, `dead`, `taxes`, `no_bank` FROM `rp_items` ORDER BY `job_id` ASC, `prix` ASC, `id` ASC;")) == INVALID_HANDLE) {
		SetFailState("ERREUR FATAL: Impossible de recupérer la liste des objects: %s", g_szError);
	}
	i=0;
	while( SQL_FetchRow(hQuery) ) {
		int id = SQL_FetchInt(hQuery, 0);
		i++;

		SQL_FetchString(hQuery, 1, g_szItemList[id][item_type_name], sizeof(g_szItemList[][]));
		SQL_FetchString(hQuery, 2, g_szItemList[id][item_type_extra_cmd], sizeof(g_szItemList[][]));
		SQL_FetchString(hQuery, 3, g_szItemList[id][item_type_reuse_delay], sizeof(g_szItemList[][]));
		SQL_FetchString(hQuery, 4, g_szItemList[id][item_type_give_hp], sizeof(g_szItemList[][]));
		SQL_FetchString(hQuery, 5, g_szItemList[id][item_type_job_id], sizeof(g_szItemList[][]));
		SQL_FetchString(hQuery, 6, g_szItemList[id][item_type_prix], sizeof(g_szItemList[][]));
		SQL_FetchString(hQuery, 7, g_szItemList[id][item_type_auto], sizeof(g_szItemList[][]));
		SQL_FetchString(hQuery, 8, g_szItemList[id][item_type_dead], sizeof(g_szItemList[][]));
		SQL_FetchString(hQuery, 9, g_szItemList[id][item_type_taxes], sizeof(g_szItemList[][]));
		SQL_FetchString(hQuery, 10, g_szItemList[id][item_type_no_bank], sizeof(g_szItemList[][]));
		
		SQL_FetchString(hQuery, 0, g_szItemListOrdered[i][item_type_ordered_id], sizeof(g_szItemListOrdered[][]));
		SQL_FetchString(hQuery, 1, g_szItemListOrdered[i][item_type_name], sizeof(g_szItemListOrdered[][]));
		SQL_FetchString(hQuery, 2, g_szItemListOrdered[i][item_type_extra_cmd], sizeof(g_szItemListOrdered[][]));
		SQL_FetchString(hQuery, 3, g_szItemListOrdered[i][item_type_reuse_delay], sizeof(g_szItemListOrdered[][]));
		SQL_FetchString(hQuery, 4, g_szItemListOrdered[i][item_type_give_hp], sizeof(g_szItemListOrdered[][]));
		SQL_FetchString(hQuery, 5, g_szItemListOrdered[i][item_type_job_id], sizeof(g_szItemListOrdered[][]));
		SQL_FetchString(hQuery, 6, g_szItemListOrdered[i][item_type_prix], sizeof(g_szItemListOrdered[][]));
		SQL_FetchString(hQuery, 7, g_szItemListOrdered[i][item_type_auto], sizeof(g_szItemListOrdered[][]));
		SQL_FetchString(hQuery, 8, g_szItemListOrdered[i][item_type_dead], sizeof(g_szItemListOrdered[][]));
		SQL_FetchString(hQuery, 9, g_szItemListOrdered[i][item_type_taxes], sizeof(g_szItemListOrdered[][]));
		SQL_FetchString(hQuery, 10, g_szItemListOrdered[i][item_type_no_bank], sizeof(g_szItemListOrdered[][]));
	}

	//
	// Chargement du menu d'achat
	if ((hQuery = SQL_Query(g_hBDD, "SELECT `item`, `name`, `slot`, `prix` FROM `rp_weapon_buy` ORDER BY `prix` ASC, `name` ASC")) == INVALID_HANDLE) {
		SetFailState("ERREUR FATAL: Impossible de recupérer la liste d'achat d'arme: %s", g_szError);
	}
	i=0;
	while( SQL_FetchRow(hQuery) ) {
		i++;

		SQL_FetchString(hQuery, 0, g_szBuyWeapons[i][0], 127);
		SQL_FetchString(hQuery, 1, g_szBuyWeapons[i][1], 127);
		SQL_FetchString(hQuery, 2, g_szBuyWeapons[i][2], 127);
		SQL_FetchString(hQuery, 3, g_szBuyWeapons[i][3], 127);

	}

	Format(query, sizeof(query), "SELECT `type`, `message`, `originX`, `originY`, `originZ` FROM `rp_location_points` ORDER BY `id` ASC;");
	//
	// Chargement du systeme de localisation
	if ((hQuery = SQL_Query(g_hBDD, query)) == INVALID_HANDLE) {
		SetFailState("ERREUR FATAL: Impossible de recupérer la liste des positions-points: %s", g_szError);
	}
	i=0;
	while( SQL_FetchRow(hQuery) ) {
		i++;

		SQL_FetchString(hQuery, 0, g_szLocationList[i][location_type_base], 127);
		SQL_FetchString(hQuery, 1, g_szLocationList[i][location_type_message], 127);
		SQL_FetchString(hQuery, 2, g_szLocationList[i][location_type_origin_x], 127);
		SQL_FetchString(hQuery, 3, g_szLocationList[i][location_type_origin_y], 127);
		SQL_FetchString(hQuery, 4, g_szLocationList[i][location_type_origin_z], 127);
		
		g_flPoints[i][0] = StringToFloat(g_szLocationList[i][location_type_origin_x]);
		g_flPoints[i][1] = StringToFloat(g_szLocationList[i][location_type_origin_y]);
		g_flPoints[i][2] = StringToFloat(g_szLocationList[i][location_type_origin_z]);
	}

	Format(query, sizeof(query), "SELECT `id`, `zone_name`, `min_x`-1, `min_y`-1, `min_z`-1, `max_x`+1, `max_y`+1, `max_z`+1, `zone_type`, `bit`, `private` FROM `rp_location_zones` ORDER BY `id` ASC;");
	//
	// Chargement du systeme de zone
	if ((hQuery = SQL_Query(g_hBDD, query)) == INVALID_HANDLE) {
		SetFailState("ERREUR FATAL: Impossible de recupérer la liste des positions-zones: %s", g_szError);
	}
	START_ZONE = 0;
	while( SQL_FetchRow(hQuery) ) {
		int id = START_ZONE;

		SQL_FetchString(hQuery, 1, g_szZoneList[id][zone_type_name], 127);

		SQL_FetchString(hQuery, 2, g_szZoneList[id][zone_type_min_x], 127);
		SQL_FetchString(hQuery, 3, g_szZoneList[id][zone_type_min_y], 127);
		SQL_FetchString(hQuery, 4, g_szZoneList[id][zone_type_min_z], 127);

		SQL_FetchString(hQuery, 5, g_szZoneList[id][zone_type_max_x], 127);
		SQL_FetchString(hQuery, 6, g_szZoneList[id][zone_type_max_y], 127);
		SQL_FetchString(hQuery, 7, g_szZoneList[id][zone_type_max_z], 127);

		SQL_FetchString(hQuery, 8, g_szZoneList[id][zone_type_type], 127);
		SQL_FetchString(hQuery, 9, g_szZoneList[id][zone_type_bit],	127);
		SQL_FetchString(hQuery, 9, g_szZoneList[id][zone_type_private],	127);
		
		g_flZones[id][0][0] = StringToFloat(g_szZoneList[id][zone_type_min_x]);
		g_flZones[id][0][1] = StringToFloat(g_szZoneList[id][zone_type_min_y]);
		g_flZones[id][0][2] = StringToFloat(g_szZoneList[id][zone_type_min_z]);
		g_flZones[id][1][0] = StringToFloat(g_szZoneList[id][zone_type_max_x]);
		g_flZones[id][1][1] = StringToFloat(g_szZoneList[id][zone_type_max_y]);
		g_flZones[id][1][2] = StringToFloat(g_szZoneList[id][zone_type_max_z]);
		

		START_ZONE++;

	}
	START_ZONE = 0;

	Format(query, sizeof(query), "SELECT `job_id`, `door_id` FROM `rp_jobs_doors`;");
	//
	// Chargement des cles pour les jobs
	if ((hQuery = SQL_Query(g_hBDD, query)) == INVALID_HANDLE) {
		SetFailState("ERREUR FATAL: Impossible de recupérer les portes en fonction du job: %s", g_szError);
	}
	while( SQL_FetchRow(hQuery) ) {

		int job_id = SQL_FetchInt(hQuery, 0);
		int door_id = SQL_FetchInt(hQuery, 1);

		g_iDoorJob[ job_id ][ door_id ] = 1;
	}
	Format(query, sizeof(query), "SELECT `id`, `job_id`, `parent`, `prix`, `name` FROM `rp_keys_selling`");
	//
	// Chargement des cles à vendre
	if ((hQuery = SQL_Query(g_hBDD, query)) == INVALID_HANDLE) {
		SetFailState("ERREUR FATAL: Impossible de recupérer les portes pouvant etre vendue: %s", g_szError);
	}
	while( SQL_FetchRow(hQuery) ) {

		int door_id = SQL_FetchInt(hQuery, 4);

		Format(g_szSellingKeys[ door_id ][key_type_id], 255, "%i", door_id);
		Format(g_szSellingKeys[ door_id ][key_type_job_id], 255, "%i", SQL_FetchInt(hQuery, 1));

		SQL_FetchString(hQuery, 2, g_szSellingKeys[ door_id ][key_type_parent], 255);
		SQL_FetchString(hQuery, 3, g_szSellingKeys[ door_id ][key_type_prix], 255);
		SQL_FetchString(hQuery, 4, g_szSellingKeys[ door_id ][key_type_name], 255);
		
		g_iAppartBonus[door_id][appart_price] = StringToInt(g_szSellingKeys[ door_id ][key_type_prix]);
	}
	//
	//
	// Chargement des groupes
	if ((hQuery = SQL_Query(g_hBDD, "SELECT `id`, `name`, `is_chef`, `owner`, `capital`, `color`, `skin`, `tag` FROM `rp_groups`")) == INVALID_HANDLE) {
		SetFailState("ERREUR FATAL: Impossible de récuperer la liste des groupes: %s", g_szError);
	}

	while( SQL_FetchRow(hQuery) ) {
		int id = SQL_FetchInt(hQuery, 0);

		SQL_FetchString(hQuery, 1, g_szGroupList[id][group_type_name], 127);
		SQL_FetchString(hQuery, 2, g_szGroupList[id][group_type_chef], 127);
		SQL_FetchString(hQuery, 3, g_szGroupList[id][group_type_own_chef], 127);
		SQL_FetchString(hQuery, 4, g_szGroupList[id][group_type_capital], 127);
		SQL_FetchString(hQuery, 5, g_szGroupList[id][group_type_color], 127);
		SQL_FetchString(hQuery, 6, g_szGroupList[id][group_type_skin], 127);
		SQL_FetchString(hQuery, 7, g_szGroupList[id][group_type_tag], 127);
		
		if( strlen(g_szGroupList[id][group_type_tag]) > 4 ) {
			char path[256];
			
			Format(path, sizeof(path), "materials/DeadlyDesire/groups/princeton/%s_small.vmt", g_szGroupList[id][group_type_tag]);
			if( FileExists(path) )
				AddFileToDownloadsTable(path);
			
			Format(path, sizeof(path), "materials/DeadlyDesire/groups/princeton/%s.vmt", g_szGroupList[id][group_type_tag]);
			if( FileExists(path) )
				AddFileToDownloadsTable(path);
			
			
			Format(path, sizeof(path), "materials/DeadlyDesire/groups/princeton/%s.vtf", g_szGroupList[id][group_type_tag]);
			if( FileExists(path) )
				AddFileToDownloadsTable(path);
		}
	}
	i = 0;
	
	
	//
	//
	// Chargement des ranks
	if ((hQuery = SQL_Query(g_hBDD, "SELECT `id`, `level`, `rank`, `description` FROM `rp_level`")) == INVALID_HANDLE) {
		SetFailState("ERREUR FATAL: Impossible de récuperer la liste des ranks: %s", g_szError);
	}

	while( SQL_FetchRow(hQuery) ) {
		int id = SQL_FetchInt(hQuery, 0);

		SQL_FetchString(hQuery, 1, g_szLevelList[id][rank_type_level], 255);
		SQL_FetchString(hQuery, 2, g_szLevelList[id][rank_type_name], 255);
		SQL_FetchString(hQuery, 3, g_szLevelList[id][rank_type_description], 255);
	}
	//
	//
	CloseHandle(hQuery);
	SQL_UnlockDatabase(g_hBDD);
	
	ServerCommand("mp_force_pick_time 0");
	ServerCommand("mp_force_assign_teams  0");
}
void updateGroupLeader() {
	SQL_TQuery(g_hBDD, SQL_SetGroupLeader, "SELECT `id` FROM `rp_groups` WHERE `id`<>0 ORDER BY  `stats` DESC LIMIT 1;");
}
void updateLotery() {
	SQL_TQuery(g_hBDD, SQL_SetLoteryAmount, "SELECT COUNT( id ) FROM rp_loto");
}
void updateBlackFriday(int day, int reduction) {
	static char szDaylist[][32] = {"Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"};
	char szDate[32];

	// get the actual day
	FormatTime(szDate, sizeof(szDate), "%A", g_iBlackFriday[0]);

	int index = 0;

	for(int i = 0; i < sizeof(szDaylist); i++) {
		if(StrEqual(szDate, szDaylist[i])) {
			index = i + 1;
			break;
		}
	}

	// if day is Sun, and the next bf is Mon, we force the bf on Tue
	if(index == 7 && day == 1) {
		day = 2;
	}

	// new date = actual_date + (rest_day_on_this_week * 24 hours in seconds) + (24 hours in seconds * numb_days_for_next_bf) + (12 hours in seconds)
	int date = g_iBlackFriday[0] + ((7 - index) * (24*60*60)) + ((24*60*60) * day) + (12*60*60);

	FormatTime(szDate, sizeof(szDate), "%e/%m/%Y/00/00/01", date);
	int timestamp = DateToTimestamp(szDate);

	g_iBlackFriday[0] = timestamp;
	g_iBlackFriday[1] = reduction;

	char query[256];
	Format(query, sizeof(query), "UPDATE `rp_servers` SET `bf_date`= '%i', `bf_reduction`= '%i' WHERE `id` = '%i'", g_iBlackFriday[0], g_iBlackFriday[1], g_iSID);
	SQL_TQuery(g_hBDD, SQL_QueryCallBack, query);
}
public Action StoreData(Handle timer, any client) {
	StoreUserData(client);
}
public void showCagnotteInfo(Handle owner, Handle hQuery, const char[] error, any client) {
	if( SQL_FetchRow(hQuery) ) {
		// g_iLOTO;
		CPrintToChat(client, "" ...MOD_TAG... " %T", "Loterry_Count", client, SQL_FetchInt(hQuery, 0), rp_GetServerInt(lotoCagnotte));
	}
}
public void SQL_SetLoteryAmount(Handle owner, Handle hQuery, const char[] error, any none) {
	if( SQL_FetchRow(hQuery) ) {
		Format(g_szVillaOwner[lotoCagnotte], sizeof(g_szVillaOwner[]), "%d", 100000 + SQL_FetchInt(hQuery, 0) * 350);
		ServerCommand("sm_effect_loto %s", g_szVillaOwner[lotoCagnotte]);
	}
}
public void SQL_SetGroupLeader(Handle owner, Handle hQuery, const char[] error, any none) {
	if( SQL_FetchRow(hQuery) ) {
		
		int ldr = SQL_FetchInt(hQuery, 0);
		if( g_iLDR != ldr ) {
			g_iLDR = ldr;
			ServerCommand("sm_effect_group %i", g_iLDR);
		}
	}
}
void CheckMP(int client) {
	
	char query[1024], szSteamID[64];
	GetClientAuthId(client, AUTH_TYPE, szSteamID, sizeof(szSteamID), false);
	
	Format(query, sizeof(query), "SELECT id FROM `rp_messages_seen` WHERE seen='0' AND `steamid`='%s' LIMIT 1;", szSteamID);
	SQL_TQuery(g_hBDD, CheckMP_2, query, client, DBPrio_Low);
	
	if( g_iClientQuests[client][questID] != -1 ) {
		g_bUserData[client][b_HasQuest] = false;
		return;
	}

	Format(query, sizeof(query), "SELECT `pluginID`, `fctID`, `uniqID`, `name` FROM `rp_quest` Q WHERE (`type`='1' OR `type`='2') AND `uniqID` NOT IN");
	Format(query, sizeof(query), "%s (SELECT Q.`uniqID`FROM`rp_quest`Q INNER JOIN`rp_quest_book`QB ON Q.`uniqID` = QB.`uniqID` WHERE `steamID`='%s' AND `isFinish`=0);", query, szSteamID); 

	SQL_TQuery(g_hBDD, updateQuest_CB, query, client, DBPrio_Low);
}
public void CheckMP_2(Handle owner, Handle handle, const char[] error, any client) {
	if( handle == INVALID_HANDLE ) {
		LogError("[SQL] [ERROR] %s", error);
	}
	
	g_bUserData[client][b_HasMail] = true;
	
	if( !SQL_FetchRow(handle) ) {
		g_bUserData[client][b_HasMail] = false;
	}
	
	if(  handle != INVALID_HANDLE )
		CloseHandle(handle);
}
void StoreUserData(int client) {
	static char SteamID[64], UserName[64], IP[32], nickbuffer[sizeof(UserName) * 2 + 1], MysqlQuery[65535];
	
	if( client == 0)
		return;
	if( g_bUserData[client][b_isConnected] == 0 )
		return;
	if( g_bUserData[client][b_isConnected2] == 0 )
		return;
	
	GetClientAuthId(client, AUTH_TYPE, SteamID, sizeof(SteamID), false);
	GetClientName(client,UserName,63);
	GetClientIP(client, IP, sizeof(IP), true);
	
	// ------------
	//	Sauvegarde des items en banque
	// ------------
	//	Stocker sous le format: id,amount;id,amount;
	//
	int max = g_iUserData[client][i_ItemBankCount], size = max * 18 + 1;
	char[] in_bank = new char[ size ];
	
	for (int i = 0; i < max; i++) {
		int object_id = g_iItems_BANK[client][i][STACK_item_id];
		if( StringToInt(g_szItemList[object_id][item_type_no_bank]) == 1 )
			continue;
		
		Format(in_bank, size, "%s%d,%d;", in_bank, object_id, g_iItems_BANK[client][i][STACK_item_amount]);
	}
	
	max = (g_bUserData[client][b_Assurance] || g_iClient_OLD[client] == 0 || true) ? g_iUserData[client][i_ItemCount] : 0;
	size = max * 18 + 1;
	char[] in_item = new char[ size ];
	
	for (int i = 0; i < max; i++) {
		int object_id = g_iItems[client][i][STACK_item_id];
		if( StringToInt(g_szItemList[object_id][item_type_no_bank]) == 1 )
			continue;
			
		Format(in_item, size, "%s%d,%d;", in_item, object_id, g_iItems[client][i][STACK_item_amount]);
	}

	
	max = MAX_JOBS;
	size = max * 18 + 1;
	char[] jobplaytime = new char[ size ];
	for (int i = 0; i < max; i++)
		if( g_iJobPlayerTime[client][i] > 0 )
			Format(jobplaytime, size, "%s%d,%d;", jobplaytime, i, g_iJobPlayerTime[client][i]);
	
	// ------------	
	SQL_EscapeString(g_hBDD, UserName, nickbuffer, sizeof(nickbuffer));
	
	char[] lname = new char[sizeof(g_szUserData[][]) * 2 + 1];
	char[] fname = new char[sizeof(g_szUserData[][]) * 2 + 1];
	
	SQL_EscapeString(g_hBDD, g_szUserData[client][sz_FirstName], fname, sizeof(g_szUserData[][]) * 2 + 1);
	SQL_EscapeString(g_hBDD, g_szUserData[client][sz_LastName], lname, sizeof(g_szUserData[][]) * 2 + 1);
	
	
	Format(MysqlQuery, sizeof(MysqlQuery), 
		"UPDATE `rp_users` SET `name`='%s', `money`='%i', `bank`='%i', `job_id`='%i', `jailled`='%i', `train`='%i',", 
		nickbuffer, g_iUserData[client][i_Money], g_iUserData[client][i_Bank]+g_iUserData[client][i_AddToPay], g_iUserData[client][i_Job], g_iUserData[client][i_JailTime], g_iUserData[client][i_KnifeTrain]);
	
	Format(MysqlQuery, sizeof(MysqlQuery), 
		"%s `permi_lege`='%i', `permi_lourd`='%i', `permi_vente`='%i', `permi_lege_start`='%i', `permi_lourd_start`='%i', `train_weapon`='%f', `group_id`='%i',",
		MysqlQuery, g_bUserData[client][b_License1], g_bUserData[client][b_License2], g_bUserData[client][b_LicenseSell], g_iUserData[client][i_StartLicense1], g_iUserData[client][i_StartLicense2], g_flUserData[client][fl_WeaponTrain], g_iUserData[client][i_Group]);
	
	Format(MysqlQuery, sizeof(MysqlQuery), 
		"%s `vitality`='%f', `pay_to_bank`='%i', `have_card`='%i', `have_account`='%i', `in_bank`='%s', `in_item`='%s', `ip`='%s',",
		MysqlQuery, g_flUserData[client][fl_Vitality], g_bUserData[client][b_PayToBank], g_bUserData[client][b_HaveCard], g_bUserData[client][b_HaveAccount], in_bank, in_item, IP);
	
	Format(MysqlQuery, sizeof(MysqlQuery), 
		"%s `malus`='%i', `freekill`='%i', `freekiller`='%i', `assurance`='%i', `freeassu`='%i', `train_esquive`='%i', `skin`='%s', `skin_id`='%d', ",
		MysqlQuery, g_iUserData[client][i_Malus], g_iUserData[client][i_KillJailDuration], g_bUserData[client][b_IsFreekiller], GetAssurence(client), g_bUserData[client][b_FreeAssurance], g_iUserData[client][i_Esquive], g_szUserData[client][sz_Skin], g_iUserData[client][i_SkinDonateur]);
	
	Format(MysqlQuery, sizeof(MysqlQuery), 
		"%s `sick`='%i', `tuto`='%i', `TimePlayedJob`='%d', `artisan_xp`='%d', `artisan_lvl`='%d', `artisan_points`='%d', `artisan_fatigue`='%f', `artisan_spe`='%d', ",
		MysqlQuery, g_iUserData[client][i_Sick], g_iUserData[client][i_Tutorial], g_iUserData[client][i_TimePlayedJob],  g_iUserData[client][i_ArtisanXP],  g_iUserData[client][i_ArtisanLevel],  g_iUserData[client][i_ArtisanPoints],  g_flUserData[client][fl_ArtisanFatigue],  g_iUserData[client][i_ArtisanSpeciality]);
	
	Format(MysqlQuery, sizeof(MysqlQuery), 
		"%s `xp`='%i', `level`='%i', `prestige`='%i', `passive`='%d', ",
		MysqlQuery, g_iUserData[client][i_PlayerXP], g_iUserData[client][i_PlayerLVL], g_iUserData[client][i_PlayerPrestige], g_bUserData[client][b_GameModePassive]);
	
	Format(MysqlQuery, sizeof(MysqlQuery), 
		"%s `jrouge`='%i', `jbleu`='%i', `female`='%i', `birthday`='%i', `birthmonth`='%i', ",
		MysqlQuery, g_iUserData[client][i_JetonRouge], g_iUserData[client][i_JetonBleu], g_bUserData[client][b_isFemale], g_iUserData[client][i_BirthDay], g_iUserData[client][i_BirthMonth]);
	
	Format(MysqlQuery, sizeof(MysqlQuery), 
		"%s `firstname`='%s', `lastname`='%s', `rules`='%i', `jobplaytime`='%s', `adminxp`='%d', `dette`='%d', `last_connected`=CURRENT_TIMESTAMP, ",
		MysqlQuery, fname, lname, g_bUserData[client][b_PassedRulesTest], jobplaytime, g_iUserData[client][i_GiveXP], g_iUserData[client][i_Dette]);
	
	Format(MysqlQuery, sizeof(MysqlQuery), 
		"%s `jail_qhs`='%i', `amende_permi_lege`='%i',`amende_permi_lourd`='%i', `points`='%i', `pvp_banned`='%i', `allowed_dismiss`='%i' WHERE `steamid`='%s';",
		MysqlQuery, g_bUserData[client][b_JailQHS], g_iUserData[client][i_AmendeLiscence2], g_iUserData[client][i_AmendeLiscence1], g_iUserData[client][i_ELO], g_iUserData[client][i_PVPBannedUntil], g_iUserData[client][i_AllowedDismiss], SteamID);

	SQL_TQuery(g_hBDD, SQL_QueryCallBack, MysqlQuery);
	
	Format(MysqlQuery, sizeof(MysqlQuery), "UPDATE `rp_success` SET ");
	
	size = success_list_all;
	
	for(int i=0; i < size; i++){
		if( StringToInt(g_szSuccessData[i][success_type_offline]) == 1 )
			continue;
		
		Format(MysqlQuery, sizeof(MysqlQuery), "%s `%s`='%d %d %d',", MysqlQuery, g_szSuccessData[i][success_type_sql], g_iUserSuccess[client][i][sd_count], g_iUserSuccess[client][i][sd_achieved], g_iUserSuccess[client][i][sd_last]);
	}
	Format(MysqlQuery, sizeof(MysqlQuery), "%s `SteamID`=`SteamID` WHERE `SteamID`='%s' LIMIT 1;", MysqlQuery, SteamID);
	
	SQL_TQuery(g_hBDD, SQL_QueryCallBack, MysqlQuery);	
}

void SynFromWeb() {
	static char base[] = "SELECT `money`, `bank`, `job_id`, `group_id`, `steamid`, `pseudo`, `steamid2`, `jail`, `raison`, `id`, UNIX_TIMESTAMP(`timestamp`) as `date`, `itemid`, `itemAmount`, `itemToBank`, `xp` FROM `rp_users2` ";
	static char steamid[128*32];
	static char query[128 * 32 + 1024];
	static char tmp[64];
	
	steamid[0] = 0;
	
	for(int i=0; i<=MaxClients; i++) {
		if( !IsValidClient(i) )
			continue;
		if( !g_bUserData[i][b_isConnected] )
			continue;
		if ( !g_bUserData[i][b_isConnected2] )
			continue;
		if( g_bUserData[i][b_IsFirstSpawn] )
			continue;
		
		
		GetClientAuthId(i, AUTH_TYPE, tmp, sizeof(tmp), false);
		Format(steamid, sizeof(steamid), "%s,'%s'", steamid, tmp);
	}
	
	Format(steamid, sizeof(steamid), "%s,'CAPITAL'", steamid);
	steamid[0] = ' ';
	
	Format(query, sizeof(query), "%s WHERE `steamid` IN (%s)", base, steamid);
	SQL_TQuery(g_hBDD, SynFromWeb_call, query, 0, DBPrio_Low);
}

public void SynFromWeb_call(Handle owner, Handle hQuery, const char[] error, any none) {
	static char query[1024];
	static char szPseudo[64], szSteamID[64], szSteamID2[64], szRaison[256], SteamID[64];
	
	while( SQL_FetchRow(hQuery) ) {
		int money = SQL_FetchInt(hQuery, 0);
		int bank = SQL_FetchInt(hQuery, 1);
		int job_id = SQL_FetchInt(hQuery, 2);
		int group_id = SQL_FetchInt(hQuery, 3);
		
		SQL_FetchString(hQuery, 4, szSteamID, sizeof(szSteamID));
		SQL_FetchString(hQuery, 5, szPseudo, sizeof(szPseudo));
		SQL_FetchString(hQuery, 6, szSteamID2, sizeof(szSteamID2));
		
		int jail = SQL_FetchInt(hQuery, 7);
		SQL_FetchString(hQuery, 8, szRaison, sizeof(szRaison));
		int id = SQL_FetchInt(hQuery, 9);
		//int timestamp = SQL_FetchInt(hQuery, 10);
		int itemID = SQL_FetchInt(hQuery, 11);
		int itemAmount = SQL_FetchInt(hQuery, 12);
		int itemToBank = SQL_FetchInt(hQuery, 13);
		int xp = SQL_FetchInt(hQuery, 14);
		
		char szId[8];
		Format(szId, sizeof(szId), "%d", id);

		if( g_hSynProcessed.GetValue(szId, id) ) continue; // On execute pas 2 fois une syn

		if( StrEqual(szSteamID, "CAPITAL") ) {
			SetJobCapital(job_id, GetJobCapital(job_id)+money+bank);
		}
		else {
			int Client = 0;
			
			for(int i=0; i<=MaxClients; i++) {
				if( !IsValidClient(i) )
					continue;
				if( !g_bUserData[i][b_isConnected] )
					continue;
				if ( !g_bUserData[i][b_isConnected2] )
					continue;
				if( g_bUserData[i][b_IsFirstSpawn] )
					continue;
				
				GetClientAuthId(i, AUTH_TYPE, SteamID, sizeof(SteamID), false);
				
				if( StrEqual(szSteamID, SteamID, true) ) {
					Client = i;
					break;
				}
			}
			
			if( IsValidClient(Client) ) {
				if( (money+bank) != 0 )
					ChangePersonnal(Client, SynType_money, (money+bank), 0, szPseudo, szSteamID2, szRaison);
				if( job_id != -1 )
					ChangePersonnal(Client, SynType_job, job_id, 0, szPseudo, szSteamID2, szRaison);
				if( group_id != -1 )
					ChangePersonnal(Client, SynType_group, group_id, 0, szPseudo, szSteamID2, szRaison);
				if( jail != -1 )
					ChangePersonnal(Client, SynType_jail, jail, 0, szPseudo, szSteamID2, szRaison);
				if( itemID != -1 ) {
					if( itemToBank == 1 )
						ChangePersonnal(Client, SynType_itemBank, itemID, itemAmount, szPseudo, szSteamID2, szRaison);
					else
						ChangePersonnal(Client, SynType_item, itemID, itemAmount, szPseudo, szSteamID2, szRaison);
				}
				if( xp != 0 )
					ChangePersonnal(Client, SynType_xp, xp, 0, szPseudo, szSteamID2, szRaison);

				if( StrEqual(szSteamID2, "SERVER") && StrEqual(szPseudo, "Parrainage") ){
					IncrementSuccess(Client, success_list_w_friends);
					IncrementSuccess(Client, success_list_w_friends2);
					IncrementSuccess(Client, success_list_w_friends3);
				}
				
			}
			
			g_hSynProcessed.SetValue(szId, id, false);

			Format(query, sizeof(query), "DELETE FROM `rp_users2` WHERE `id`='%i';", id);
			SQL_TQuery(g_hBDD, SQL_QueryCallBack, query, 0, DBPrio_High);
		}
	}
}
void ResetUserData(int client) {
	for(int i=0; i<view_as<int>(b_udata_max); i++) {
		g_bUserData[client][i] = false;
	}
	for(int i=0; i<view_as<int>(i_udata_max); i++) {
		g_iUserData[client][i] = 0;
	}
	for(int i=0; i<view_as<int>(fl_udata_max); i++) {
		g_flUserData[client][i] = 0.0;
	}
	for(int i=0; i<view_as<int>(sz_udata_max); i++) {
		Format(g_szUserData[client][i], sizeof(g_szUserData[][]), "");
	}
	
	for(int i=0; i<MAX_PLAYERS+1; i++) {
		g_iBlockedTime[client][i] = g_iBlockedTime[i][client] = 0;
		
		for(int j=0; j<view_as<int>(fd_udata_max); j++) {
			g_iClientFloodValue[i][client][j] = g_iClientFloodValue[client][i][j] = 0;
			g_flClientFloodTime[i][client][j] = g_flClientFloodTime[client][i][j] = 0.0;
		}
		
		if( g_iUserData[i][i_LastVol] == client )
			g_iUserData[i][i_LastVol] = 0;
		if( g_iUserData[i][i_BurnedBy] == client )
			g_iUserData[i][i_BurnedBy] = 0;
		if( g_iUserData[i][i_JailledBy] == client )
			g_iUserData[i][i_JailledBy] = 0;
		
		g_iKillLegitime[i][client] = g_iKillLegitime[client][i] = g_iAggro[i][client] = g_iAggro[client][i] = g_iAggroTimer[i][client] = g_iAggroTimer[client][i] = 0;
		
	}
	
	for (int i = 0; i <= MAX_JOBS; i++) {
		g_iJobPlayerTime[client][i] = 0;
	}
	
	g_iStackCanKill_Count[client] = 0;

	for (int i = 0; i <= MAX_ITEMS; i++) {
		g_iItems[client][i][STACK_item_id] = 0;
		g_iItems[client][i][STACK_item_amount] = 0;
		g_iItems_BANK[client][i][STACK_item_id] = 0;
		g_iItems_BANK[client][i][STACK_item_amount] = 0;
	}

	
	g_flUserData[client][fl_Speed] = DEFAULT_SPEED;
	g_flUserData[client][fl_Gravity] = 1.0;
	g_bUserData[client][b_MayBuild] =g_bUserData[client][b_MaySteal] = g_bUserData[client][b_MayUseUltimate] = g_bUserData[client][b_IsFirstSpawn] = true;

	g_flUserData[client][fl_Size] = 1.0;
	g_iClientQuests[client][questID] = -1;
	g_iClientQuests[client][stepID] = -1;
	g_iCurrentKill[client] = 0;
	
	for(int i=0; i<MAX_KEYSELL; i++) {
		g_iDoorOwner_v2[client][i] = 0;
	}
	
	Format(g_szPlainte[client][0], 128, "");
	Format(g_szPlainte[client][1], 128, "");
	
	
	g_iSuccess_last_touchdown[client] = g_iSuccess_last_burn[client] = 0;
	g_iSuccess_last_lifeshort[client] = g_iSuccess_last_pas_vu_pas_pris[client] = g_iSuccess_last_faster_dead[client] = GetTime();
	
	for(int i=0; i<view_as<int>(success_list_all); i++) {
		g_iUserSuccess[client][i][sd_count] = g_iUserSuccess[client][i][sd_achieved] = g_iUserSuccess[client][i][sd_last] = 0;
	}
	
	for( int i=0; i<10; i++ ) {
		Format(g_szSuccess_last_give[client][i], 31, "");
	}
	
	if( g_iGrabbing[client] > 0 ) {
		SDKUnhook(g_iGrabbing[client], SDKHook_Touch, OnForceTouch);
	}
	g_iGrabbing[client] = 0;
	g_iMayGrabAll[client] = 1;
	
	g_bIsSeeking[client] = g_bMovingTeleport[client] = false;
	g_bGrabNear[client] = g_bToggle[client] = true;
	g_flLubrifian[client] = 0.0;
	
	g_iUserData[client][i_KnifeTrainAdmin] = -1;
	g_iUserData[client][i_FistTrainAdmin] = -1;
	g_flUserData[client][fl_WeaponTrainAdmin] = -1.0;
	
	Format(g_szItems_SAVE[client][0], sizeof(g_szItems_SAVE[][]), "%T", "Item_Register", client, 1);
	for( int i=1; i<sizeof(g_szItems_SAVE[]); i++ )
		Format(g_szItems_SAVE[client][i], sizeof(g_szItems_SAVE[][]), "");
	
	for(int i=1; i<2048; i++) {
		if( !IsValidEdict(i) )
			continue;
		if( !IsValidEntity(i) )
			continue;
		
		g_iCarPassager[i][client] = 0;
		
		char ClassName[64];
		GetEdictClassname(i, ClassName, sizeof(ClassName));
		
		if( StrContains(ClassName, "rp_") != 0 )
			continue;
		
		int owner = GetEntPropEnt(i, Prop_Send, "m_hOwnerEntity");
		if( owner != client )
			continue;
		
		rp_AcceptEntityInput(i, "Kill");
	}
	
	g_Client_AMP[client] = -1.0;
	g_iUserData[client][i_Disposed] = 10;
	g_iUserData[client][i_PlayerLVL] = 1;
	g_bUserData[client][b_GameModePassive] = true;
	g_iUserData[client][i_ELO] = 1500;
	g_iDoubleCompte[client].Clear();
}
void LoadUserData(int Client) {
	
	static char SteamID[64], query[4096];
	
	if(!IsFakeClient(Client)) {
		
		ResetUserData(Client);
		GetClientAuthId(Client, AUTH_TYPE, SteamID, sizeof(SteamID), false);
		
		Format(query, sizeof(query), 
			"SELECT `money`, `bank`, `job_id`, `jailled`, `skin`, `train`, `permi_lege`, `permi_lourd`, `permi_vente`, `passive`, `train_weapon`,");
		Format(query, sizeof(query),
			"%s `group_id`, `vitality`, UNIX_TIMESTAMP(`last_connected`), `pay_to_bank`, `have_card`, `in_bank`, `in_item`, `jail_qhs`, `have_account`,", query);
		Format(query, sizeof(query),
			"%s `malus`, `tuto`, `donateur`, `donateur`, `freekill`, `TimePlayedJob`, `assurance`, `train_esquive`, `sick`, `avocat`, `hasVilla`,", query);
		Format(query, sizeof(query),
			"%s `artisan_xp`, `artisan_lvl`, `artisan_points`, `artisan_fatigue`, `kill`, `death`, `kill2`, `death2`, `jrouge`, `jbleu`, `xp`, ", query);
		Format(query, sizeof(query),
			"%s `level`, `prestige`, `female`, `birthday`, `birthmonth`, `lastname`, `firstname`, `rules`, `jobplaytime`, `adminxp`, `dette`, `time_played`, ", query); 
		Format(query, sizeof(query),
			"%s `permi_lege_start`, `permi_lourd_start`, `freekiller`, `amende_permi_lege`, `amende_permi_lourd`, `skin_id`, `freeassu`, `points`, `pvp_banned`, ", query); 
		Format(query, sizeof(query),
			"%s `allowed_dismiss`, `artisan_spe` FROM `rp_users` WHERE `steamid` = '%s';", query, SteamID); 

		SQL_TQuery(g_hBDD, LoadUserData_2, query, Client, DBPrio_High);
		
		Format(query, sizeof(query), "SELECT");
		
		int size = success_list_all;
		
		for(int i=0; i < size; i++) {
			Format(query, sizeof(query), "%s `%s`,", query, g_szSuccessData[i][success_type_sql]);
		}
		Format(query, sizeof(query), "%s `SteamID` FROM `rp_success` WHERE `SteamID`='%s' LIMIT 1;", query, SteamID);
		
		SQL_TQuery(g_hBDD, LoadUserData_3, query, Client, DBPrio_High);
		
		
		Format(query, sizeof(query), "SELECT `played` FROM `rp_idcard` WHERE `steamid`='%s' AND `played`>'72000' LIMIT 1;", SteamID);
		SQL_TQuery(g_hBDD, Check_2, query, Client);
		
		//ReplaceString(SteamID, sizeof(SteamID), "STEAM_1", "STEAM_0");
		Format(query, sizeof(query), "SELECT `steamid` FROM `rp_users` WHERE `no_pyj`='1' AND `steamid`='%s' LIMIT 1;", SteamID);
		SQL_TQuery(g_hBDD, Check_3, query, Client);

		//
		// Chargement du nbr d'audience
		Format(query, sizeof(query), "SELECT * FROM `rp_audiences` WHERE `avocat-plaignant` = '%s' OR `avocat-suspect` = '%s'", SteamID, SteamID);
		SQL_TQuery(g_hBDD, Check_Audience, query, Client);
	}
}
public void Check_2(Handle owner, Handle handle, const char[] error, any data) {
	if( handle == INVALID_HANDLE ) {
		LogError("[SQL] [ERROR] %s", error);
	}
	
	g_iClient_OLD[data] = 1;
	
	if( !SQL_FetchRow(handle) && GetConVarInt(FindConVar("hostport")) == 27015 ) {
		g_iClient_OLD[data] = 0;
	}
	
	if( g_iUserData[data][i_PlayerLVL] >= 12 )
		g_iClient_OLD[data] = 1;
	if( g_iDoubleCompte[data].Length >= 1 )
		g_iClient_OLD[data] = 1;
	
	if(  handle != INVALID_HANDLE )
		CloseHandle(handle);
}
public void Check_3(Handle owner, Handle handle, const char[] error, any data) {
	
	if( handle == INVALID_HANDLE ) {
		LogError("[SQL] [ERROR] %s", error);
	}

	g_bUserData[data][b_IsNoPyj] = true;
	
	if( !SQL_FetchRow(handle) ) {
		g_bUserData[data][b_IsNoPyj] = false;
	}
	
	if(  handle != INVALID_HANDLE )
		CloseHandle(handle);
}
public void Check_Audience(Handle owner, Handle handle, const char[] error, any data) {
	
	if( handle == INVALID_HANDLE ) {
		LogError("[SQL] [ERROR] %s", error);
	}

	g_iUserData[data][i_LawyerAudience] = SQL_GetRowCount(handle);
	
	if(  handle != INVALID_HANDLE )
		CloseHandle(handle);
}
public void LoadUserData_2(Handle owner, Handle hQuery, const char[] error, any Client) {
	static char SteamID[64], MysqlQuery[1014];
	
	if( !IsValidClient(Client) )
		return;
		
	GetClientAuthId(Client, AUTH_TYPE, SteamID, sizeof(SteamID), false);
	
	if( hQuery == INVALID_HANDLE ) {
		LogError("[SQL] [ERROR] %s", error);
		
		g_iUserData[Client][i_Money] = 0;
		g_iUserData[Client][i_Bank] = 0;
		g_iUserData[Client][i_Tutorial] = 0;
		g_iUserData[Client][i_PlayerLVL] = 1;
		g_bUserData[Client][b_GameModePassive] = true;
		
		Format(MysqlQuery, sizeof(MysqlQuery), "INSERT IGNORE INTO `rp_users` (`steamid`, `name`, `money`, `bank`, `job_id`) VALUES ('%s', 'NOUVEAU', '0', '0', '0');", SteamID);
		SQL_TQuery(g_hBDD, SQL_QueryCallBack, MysqlQuery);
		
		Format(MysqlQuery, sizeof(MysqlQuery), "INSERT IGNORE INTO `rp_success` (`steamid`) VALUES ('%s');", SteamID);
		SQL_TQuery(g_hBDD, SQL_QueryCallBack, MysqlQuery);

		Format(MysqlQuery, sizeof(MysqlQuery), "INSERT IGNORE INTO `rp_itemsaves` (`steamid`, `slot`, `name`, `save`) VALUES ('%s', 0, 'Registre 1', '');", SteamID);
		SQL_TQuery(g_hBDD, SQL_QueryCallBack, MysqlQuery);
		
		LoadUserData(Client);
		return;
	}
	// Si nous avons des données, chargons les
	// Sinon, chargons en :)
	if (SQL_FetchRow(hQuery)) {
		
		int now_time = GetTime();
		
		g_iUserData[Client][i_Money] = SQL_FetchInt(hQuery,0);
		g_iUserData[Client][i_Bank] = SQL_FetchInt(hQuery,1);
		g_iUserData[Client][i_Job] = SQL_FetchInt(hQuery, 2);
		g_iUserData[Client][i_JailTime]  = SQL_FetchInt(hQuery,3);
		SQL_FetchString(hQuery, 4, g_szUserData[Client][sz_Skin], sizeof(g_szUserData[][]));
		g_iUserData[Client][i_KnifeTrain] = SQL_FetchInt(hQuery, 5);
		g_bUserData[Client][b_License1] = SQL_FetchInt(hQuery, 6);
		g_bUserData[Client][b_License2] = SQL_FetchInt(hQuery, 7);
		g_bUserData[Client][b_LicenseSell] = SQL_FetchInt(hQuery, 8);
		g_bUserData[Client][b_GameModePassive] = SQL_FetchInt(hQuery, 9);
		g_flUserData[Client][fl_WeaponTrain] = SQL_FetchFloat(hQuery, 10);
		g_iUserData[Client][i_Group] = SQL_FetchInt(hQuery, 11);
		g_flUserData[Client][fl_Vitality] = SQL_FetchFloat(hQuery, 12);
		g_iUserData[Client][i_LastTime] = SQL_FetchInt(hQuery, 13);
		g_bUserData[Client][b_PayToBank] = SQL_FetchInt(hQuery, 14);
		g_bUserData[Client][b_HaveCard] = SQL_FetchInt(hQuery, 15);
		g_bUserData[Client][b_JailQHS] = SQL_FetchInt(hQuery, 18);
		g_bUserData[Client][b_HaveAccount] = SQL_FetchInt(hQuery, 19);
		g_iUserData[Client][i_Malus] = SQL_FetchInt(hQuery, 20);
		g_iUserData[Client][i_Tutorial] = SQL_FetchInt(hQuery, 21);
		
		g_iUserData[Client][i_Donateur] = SQL_FetchInt(hQuery, 23);
		g_iUserData[Client][i_KillJailDuration] = SQL_FetchInt(hQuery, 24);
		g_iUserData[Client][i_TimePlayedJob] = SQL_FetchInt(hQuery, 25);
		int assurance = SQL_FetchInt(hQuery, 26);
		g_iUserData[Client][i_Esquive] = SQL_FetchInt(hQuery, 27);
		g_iUserData[Client][i_Sick] = SQL_FetchInt(hQuery, 28);
		g_iUserData[Client][i_Avocat] = SQL_FetchInt(hQuery, 29);
		g_bUserData[Client][b_HasVilla] = SQL_FetchInt(hQuery, 30);
		g_iUserData[Client][i_ArtisanXP] = SQL_FetchInt(hQuery, 31);
		g_iUserData[Client][i_ArtisanLevel] = SQL_FetchInt(hQuery, 32);
		g_iUserData[Client][i_ArtisanPoints] = SQL_FetchInt(hQuery, 33);
		g_flUserData[Client][fl_ArtisanFatigue] = SQL_FetchFloat(hQuery, 34);
		g_iUserData[Client][i_ArtisanSpeciality] = SQL_FetchInt(hQuery, 64);
		g_iUserData[Client][i_KillMonth] = SQL_FetchInt(hQuery, 35);
		g_iUserData[Client][i_DeathMonth] = SQL_FetchInt(hQuery, 36);
		g_iUserData[Client][i_Kill31Days] = SQL_FetchInt(hQuery, 37);
		g_iUserData[Client][i_Death31Days] = SQL_FetchInt(hQuery, 38);
		g_iUserData[Client][i_JetonRouge] = SQL_FetchInt(hQuery, 39);
		g_iUserData[Client][i_JetonBleu] = SQL_FetchInt(hQuery, 40);
		g_iUserData[Client][i_PlayerXP] = SQL_FetchInt(hQuery, 41);
		g_iUserData[Client][i_PlayerLVL] = SQL_FetchInt(hQuery, 42);		
		g_iUserData[Client][i_PlayerPrestige] = SQL_FetchInt(hQuery, 43);
		g_bUserData[Client][b_isFemale] = SQL_FetchInt(hQuery, 44);
		g_iUserData[Client][i_BirthDay] = SQL_FetchInt(hQuery, 45);
		g_iUserData[Client][i_BirthMonth] = SQL_FetchInt(hQuery, 46);
		g_bUserData[Client][b_PassedRulesTest] = SQL_FetchInt(hQuery, 49);
		g_iUserData[Client][i_GiveXP] = SQL_FetchInt(hQuery, 51);
		g_iUserData[Client][i_Dette] = SQL_FetchInt(hQuery, 52);
		g_flUserData[Client][fl_MonthTime] = SQL_FetchFloat(hQuery, 53);

		g_iUserData[Client][i_StartLicense1] = SQL_FetchInt(hQuery, 54);
		g_iUserData[Client][i_StartLicense2] = SQL_FetchInt(hQuery, 55);

		g_bUserData[Client][b_IsFreekiller] = SQL_FetchInt(hQuery, 56);
		
		g_iUserData[Client][i_AmendeLiscence2] = SQL_FetchInt(hQuery, 57);
		g_iUserData[Client][i_AmendeLiscence1] = SQL_FetchInt(hQuery, 58);
		g_iUserData[Client][i_SkinDonateur] = SQL_FetchInt(hQuery, 59);
		g_iUserData[Client][i_ELO] = SQL_FetchInt(hQuery, 61);
		g_iUserData[Client][i_PVPBannedUntil] = SQL_FetchInt(hQuery, 62);
		g_iUserData[Client][i_AllowedDismiss] = SQL_FetchInt(hQuery, 63);
		// 64 = artisan spe
		int freeassu = SQL_FetchInt(hQuery, 60);

		SQL_FetchString(hQuery, 47, g_szUserData[Client][sz_LastName], sizeof(g_szUserData[][]));
		SQL_FetchString(hQuery, 48, g_szUserData[Client][sz_FirstName], sizeof(g_szUserData[][]));		
		
		
		g_flUserData[Client][fl_ArtisanFatigue] -= float(now_time-g_iUserData[Client][i_LastTime]) / (12.0 * 60.0 * 60.0);
		if( g_flUserData[Client][fl_ArtisanFatigue] <= 0.0 )
			g_flUserData[Client][fl_ArtisanFatigue] = 0.0;
		
		#if FREEZE_VITALITY != 1
			g_flUserData[Client][fl_Vitality] -= float(now_time - g_iUserData[Client][i_LastTime]) / 45.0;
			if( g_flUserData[Client][fl_Vitality] <= 0.0 )
				g_flUserData[Client][fl_Vitality] = 0.0;
		#endif
		
		if( g_iUserData[Client][i_LastTime]+(1*60*60) < now_time )
			g_iUserData[Client][i_Sick] = 0;
		
		
		g_iUserData[Client][i_LastKillTime] = GetTime();
		g_bIsHidden[Client] = false;

		if( StrEqual(SteamID, "76561197975247242") ) {
			g_bIsHidden[Client] = true;
		}
		
		
		// ------------
		//		Récupération des items mis en banque
		//
		loadItem_Bank(Client, hQuery);
		loadItem_Item(Client, hQuery);
		
		ItemSave_LoadNames(Client);

		updateBankCost(Client);
		
		loadJobPlayTime(Client, hQuery);
		
		
		if( freeassu == 1 && GetGameTime() <= (15.0*60.0) || freeassu == 0 ) {	
			if( assurance >= 0 ) {
				int assuWr;
				if( !g_hSynAssuWritten.GetValue(SteamID, assuWr) ){
					char szQuery[1024];
					Format(szQuery, sizeof(szQuery), 
						"INSERT INTO `rp_users2` (`steamid`, `money`, `bank`, `job_id`, `group_id`, `pseudo`, `steamid2`) VALUES ('%s', '0', '%i', '-1', '-1', 'l\\'assurance', 'SERVER');", 
						SteamID, assurance);
					
					g_hSynAssuWritten.SetValue(SteamID, 0, false);
					SQL_TQuery(g_hBDD, SQL_QueryCallBack, szQuery, 0, DBPrio_Low);
					//SetJobCapital(211, (GetJobCapital(211)-(assurance/2)));
					//int cap = rp_GetRandomCapital(211);
					//SetJobCapital(cap, (GetJobCapital(cap)-(assurance/2)));
				}
			}
		}
	}
	else {
		g_iUserData[Client][i_Money] = 0;
		g_iUserData[Client][i_Bank] = 0;
		g_iUserData[Client][i_Tutorial] = 0;
		g_iUserData[Client][i_PlayerLVL] = 1;
		g_bUserData[Client][b_GameModePassive] = true;
		
		Format(MysqlQuery, sizeof(MysqlQuery), "INSERT IGNORE INTO `rp_users` (`steamid`, `name`, `money`, `bank`, `job_id`) VALUES ('%s', 'NOUVEAU', '0', '0', '0');", SteamID);
		SQL_TQuery(g_hBDD, SQL_QueryCallBack, MysqlQuery);
		
		Format(MysqlQuery, sizeof(MysqlQuery), "INSERT IGNORE INTO `rp_success` (`steamid`) VALUES ('%s');", SteamID);
		SQL_TQuery(g_hBDD, SQL_QueryCallBack, MysqlQuery);
	}
	//
	// Mise par défaut des valeurs sensée etre par défaut.
	
	g_bUserData[Client][b_isConnected] = 1;
#if defined USING_VEHICLE
	g_iMayCarAction[Client] = 1;
#endif
	
	int flags = GetUserFlagBits(Client);
	if( flags & ADMFLAG_ROOT ) {
		g_bGrabNear[Client] = false;
		g_bToggle[Client] = false;
		g_bCheckSphere[Client] = true;
	}
	else {
		g_bGrabNear[Client] = true;
		g_bToggle[Client] = true;
		g_bCheckSphere[Client] = false;
	}
	
	if( g_iUserData[Client][i_Job] <= 5 && g_iUserData[Client][i_Job] >= 1 ) {
		g_bGrabNear[Client] = false;
	}
	
	if( g_iUserData[Client][i_LastTime]+(60*60) <= GetTime() ) {
		g_iSuccess_last_5tokill[Client] = 0;
	}
	else {
		g_iSuccess_last_5tokill[Client] = -1;
	}
	
	g_flUserData[Client][fl_Speed] = DEFAULT_SPEED;
	g_flUserData[Client][fl_Gravity] = 1.0;
	
	updatePlayerRank(Client);
	
	SDKHook(Client, SDKHook_OnTakeDamage,	OnTakeDamage);
	SDKHook(Client, SDKHook_PreThink,		OnPreThink);
	SDKHook(Client, SDKHook_PostThink,		OnPostThink);
	SDKHook(Client, SDKHook_PostThinkPost,	OnPostThinkPost);
	
	//SDKHook(Client, SDKHook_SetTransmit,	OnSetTransmit);
	SDKHook(Client, SDKHook_WeaponCanUse,	OnWeaponCanUse);
	SDKHook(Client, SDKHook_WeaponCanSwitchTo,	OnWeaponCanSwitchTo);
	SDKHook(Client, SDKHook_WeaponEquip,	WeaponEquip);
	
	#if defined USING_VEHICLE
	SDKHook(Client, SDKHook_PreThinkPost,	vehicle_OnPreThinkPost);
	#endif
	DHookEntity(g_hTeleport, false, Client);
	DHookEntity(g_hOnVoiceTransmit, true, Client);
	
	CS_SwitchTeam(Client, CS_TEAM_T);

	char URL[128];
	Format(URL, sizeof(URL), "http://5.196.39.48:8080/user/double/steamid/%s", SteamID);
	
	Handle req = SteamWorks_CreateHTTPRequest(k_EHTTPMethodGET, URL);
	SteamWorks_SetHTTPCallbacks(req, OnSteamWorksHTTPComplete);
	SteamWorks_SetHTTPRequestContextValue(req, Client);
	SteamWorks_SendHTTPRequest(req);
	
	Call_StartForward( view_as<Handle>(g_hRPNative[Client][RP_OnPlayerDataLoaded]));
	Call_PushCell(Client);
	Call_Finish();
}

void loadJobPlayTime(int Client, Handle hQuery) {
	char split[2] = ";";	
	int size = (BUFFER_SIZE+SQL_FetchSize(hQuery, 50));
	char[] data = new char[size];
	SQL_FetchString(hQuery, 50, data, size);
		
	char buffer[BUFFER_SIZE], buffer2[BUFFER_SIZE], szData[2][BUFFER_SIZE];
		
	// ------------
	//	Stocker sous le format: type,id,amount;type,id,amount;
	//
	while( SplitString(data, split, buffer, BUFFER_SIZE) != -1 ) {
		
		Format(buffer2, BUFFER_SIZE, "%s%s", buffer, split);
		RemoveString(data, buffer2, false);
		
		ExplodeString(buffer, ",", szData, sizeof(szData), BUFFER_SIZE);
			
		int job_id = StringToInt(szData[0]);
		int job_amount = StringToInt(szData[1]);
		
		g_iJobPlayerTime[Client][job_id] = job_amount;
	}
}
void loadItem_Bank(int Client, Handle hQuery) {
	int size = (BUFFER_SIZE+SQL_FetchSize(hQuery, 16));
	char[] data = new char[size];
	char buffer[BUFFER_SIZE], buffer2[BUFFER_SIZE], szData[2][BUFFER_SIZE];
	char split[2] = ";";
	SQL_FetchString(hQuery, 16, data, size);
	
	// ------------
	//	Stocker sous le format: id,amount;id,amount;
	//
	while( SplitString(data, split, buffer, BUFFER_SIZE) != -1 ) {
		
		Format(buffer2, BUFFER_SIZE, "%s%s", buffer, split);
		RemoveString(data, buffer2, false);
		ExplodeString(buffer, ",", szData, sizeof(szData), BUFFER_SIZE);
		
		int objet_id = StringToInt(szData[0]);
		int objet_amount = StringToInt(szData[1]);
		
		if( objet_id <= 0 || objet_id > MAX_ITEMS || rp_GetItemInt(objet_id, item_type_auto) == 1 )
			continue;
		if( rp_GetItemInt(objet_id, item_type_no_bank) == 1 )
			continue;
		
		if( StrEqual(g_szItemList[objet_id][item_type_extra_cmd], "UNKNOWN") ) {
			g_iUserData[Client][i_Bank] += StringToInt(g_szItemList[objet_id][item_type_prix]) * objet_amount;
			continue;
		}
		
		rp_ClientGiveItem(Client, objet_id, objet_amount, true);
	}
	
	size = g_iUserData[Client][i_ItemBankCount];
	
	for (int i = 0; i < size; i++) {
		if( g_iItems_BANK[Client][i][STACK_item_amount] < 0 ) {
			rp_ClientMoney(Client, i_Bank, -(rp_GetItemInt(g_iItems_BANK[Client][i][STACK_item_id], item_type_prix) * -g_iItems_BANK[Client][i][STACK_item_amount]), true);
			rp_ClientGiveItem(Client, g_iItems_BANK[Client][i][STACK_item_id], -g_iItems_BANK[Client][i][STACK_item_amount], true);
		}
	}
}

void loadItem_Item(int Client, Handle hQuery) {
	char split[2] = ";";
	char buffer[BUFFER_SIZE], buffer2[BUFFER_SIZE], szData[2][BUFFER_SIZE];
	int size = (BUFFER_SIZE+SQL_FetchSize(hQuery, 17));
	char[] data = new char[size];
	SQL_FetchString(hQuery, 17, data, size);
	
	// ------------
	//	Stocker sous le format: id,amount;id,amount;
	//
	while( SplitString(data, split, buffer, BUFFER_SIZE) != -1 ) {
		
		Format(buffer2, BUFFER_SIZE, "%s%s", buffer, split);
		RemoveString(data, buffer2, false);
		
		ExplodeString(buffer, ",", szData, sizeof(szData), BUFFER_SIZE);
		
		int objet_id = StringToInt(szData[0]);
		int objet_amount = StringToInt(szData[1]);
		
		if( objet_id <= 0 || objet_id > MAX_ITEMS || rp_GetItemInt(objet_id, item_type_auto) == 1 )
			continue;
		if( rp_GetItemInt(objet_id, item_type_no_bank) == 1 )
			continue;
	
		rp_ClientGiveItem(Client, objet_id, objet_amount);
		g_bUserData[Client][b_ItemRecovered] = true;
		LogToGame("[TSX-RP] [ITEM-RECONNECT] %L %d %s", Client, objet_amount, g_szItemList[objet_id][item_type_name]);
	}
}
public int OnSteamWorksHTTPComplete(Handle HTTPRequest, bool fail, bool success, EHTTPStatusCode statusCode, any client) {
	static Handle regex;
	if( regex == INVALID_HANDLE )
		regex = CompileRegex("\"(\\d+)\"");
	
	if (success && statusCode == k_EHTTPStatusCode200OK )  { 
		int size;
		SteamWorks_GetHTTPResponseBodySize(HTTPRequest, size);
		char[] tmp = new char[size + 1];
		char tmp2[32];
		SteamWorks_GetHTTPResponseBodyData(HTTPRequest, tmp, size);
		
		g_iDoubleCompte[client].Clear();
		
		while( MatchRegex(regex, tmp) >= 2 ) {
			
			GetRegexSubString(regex, 1, tmp2, sizeof(tmp2));
			g_iDoubleCompte[client].PushString(tmp2);
			g_iClient_OLD[client] = 1;
			
			ReplaceString(tmp, size, tmp2, "");
		}
		
	}
	
	delete HTTPRequest;
}
public void LoadUserData_3(Handle owner, Handle hQuery, const char[] error, any client) {
	static char MysqlQuery[2048], SteamID[32];
	
	if( !IsValidClient(client) )
		return;
	
	if( hQuery == INVALID_HANDLE ) {
		LogError("[SQL] [ERROR] %s", error);
		
		GetClientAuthId(client, AUTH_TYPE, SteamID, sizeof(SteamID), false);
		
		Format(MysqlQuery, sizeof(MysqlQuery), "INSERT IGNORE INTO `rp_success` (`steamid`) VALUES ('%s');", SteamID);
		SQL_TQuery(g_hBDD, SQL_QueryCallBack, MysqlQuery);
	}
	if( SQL_FetchRow(hQuery) ) {
		int size = success_list_all;
		char tmp[32], explo[3][32];
		
		for(int i=0; i < size; i++) {
			SQL_FetchString(hQuery, i, tmp, sizeof(tmp));
			ExplodeString(tmp, " ", explo, sizeof(explo), sizeof(explo[]));
			
			g_iUserSuccess[client][i][sd_count] = StringToInt(explo[0]);
			g_iUserSuccess[client][i][sd_achieved] = StringToInt(explo[1]);
			g_iUserSuccess[client][i][sd_last] = StringToInt(explo[2]);
		}
	}
	else {
		
		GetClientAuthId(client, AUTH_TYPE, SteamID, sizeof(SteamID), false);
		
		Format(MysqlQuery, sizeof(MysqlQuery), "INSERT IGNORE INTO `rp_success` (`steamid`) VALUES ('%s');", SteamID);
		SQL_TQuery(g_hBDD, SQL_QueryCallBack, MysqlQuery);
		
	}
	g_bUserData[client][b_isConnected2] = 1;
	
	g_iSuccess_last_jail[client] = GetTime();
	g_iSuccess_last_kill[client] = GetTime();
	g_iSuccess_last_chat[client] = GetTime();
}
void CheckMute(int Client) {
	if( !IsFakeClient(Client) ) {
		
		char SteamID[64], szQuery[1024];
		GetClientAuthId(Client, AUTH_TYPE, SteamID, sizeof(SteamID), false);
		//ReplaceString(SteamID, sizeof(SteamID), "STEAM_1", "STEAM_0");
		Format(szQuery, sizeof(szQuery), "SELECT `game` FROM `srv_bans` WHERE `SteamID`='%s' AND (`Length`='0' OR `EndTime`>UNIX_TIMESTAMP()) AND `is_unban`='0' AND (`game` LIKE 'rp-%%');", SteamID);
		
		SQL_TQuery(g_hBDD, CheckMute_2, szQuery, Client);
	}
}
public void CheckMute_2(Handle owner, Handle handle, const char[] error, any data) {
	if( !IsValidClient(data) )
		return;
	
	if( handle == INVALID_HANDLE ) {
		LogError("[SQL] [ERROR] %s", error);
	}
	while( SQL_FetchRow(handle) ) {
		char game[32];
		bool_user_data dest;
		SQL_FetchString(handle, 0, game, sizeof(game));
		
		if( StrEqual(game, "rp-global") ) {
			dest = b_IsMuteGlobal;
		}
		else if( StrEqual(game, "rp-local") ) {
			dest = b_IsMuteLocal;
		}
		else if( StrEqual(game, "rp-vocal") ) {
			dest = b_IsMuteVocal;
		}
		else if( StrEqual(game, "rp-event") ) {
			dest = b_IsMuteEvent;
		}
		else if( StrEqual(game, "rp-give") ) {
			dest = b_IsMuteGive;
		}
		else if( StrEqual(game, "rp-kill") ) {
			dest = b_IsMuteKILL;
		}
		else if( StrEqual(game, "rp-pvp") ) {
			dest = b_IsMutePvP;
		}
		
		g_bUserData[data][dest] = true;
	}
}

void ItemSave_SetItems(int client, int saveid){
	char SteamID[32];
	int max = g_iUserData[client][i_ItemCount];
	int size = max * 18 + 128;
	char[] query = new char[ size ];
	GetClientAuthId(client, AUTH_TYPE, SteamID, sizeof(SteamID), false);

	Format(query, size, "UPDATE rp_itemsaves SET save='");

	for (int i = 0; i < max; i++) {
		int object_id = g_iItems[client][i][STACK_item_id];
		if( StringToInt(g_szItemList[object_id][item_type_no_bank]) == 1 )
			continue;
		
		Format(query, size, "%s%d,%d;", query, object_id, g_iItems[client][i][STACK_item_amount]);
	}

	Format(query, size, "%s' WHERE steamid='%s' AND slot=%d", query, SteamID, saveid);

	SQL_TQuery(g_hBDD, SQL_QueryCallBack, query, client);
}

void ItemSave_SetName(int client, int saveid, char[] name){
	strcopy(g_szItems_SAVE[client][saveid], sizeof(g_szItems_SAVE[][]), name);
	char query[128];
	GetClientAuthId(client, AUTH_TYPE, query, sizeof(query), false);
	Format(query, sizeof(query), "UPDATE rp_itemsaves SET name='%s' WHERE steamid='%s' AND slot=%d", name, query, saveid);

	SQL_TQuery(g_hBDD, SQL_QueryCallBack, query, client);
}

bool ItemSave_AddSave(int client){
	char query[128];
	for(int i=0; i<sizeof(g_szItems_SAVE[]); i++){
		if(StrEqual(g_szItems_SAVE[client][i], "")){
			Format(g_szItems_SAVE[client][i], sizeof(g_szItems_SAVE[][]), "%T", "Item_Register", client, i+1);
			GetClientAuthId(client, AUTH_TYPE, query, sizeof(query), false);
			Format(query, sizeof(query), "INSERT INTO rp_itemsaves (steamid, slot, name, save) VALUES ('%s', %d, '%s', '')", query, i, g_szItems_SAVE[client][i]);

			SQL_TQuery(g_hBDD, SQL_QueryCallBack, query, client);
			
			return true;
		}
	}
	return false;
}

void ItemSave_Withdraw(int client, int saveid){
	char query[128];
	GetClientAuthId(client, AUTH_TYPE, query, sizeof(query), false);
	Format(query, sizeof(query), "SELECT name, save FROM rp_itemsaves WHERE steamid='%s' AND slot=%d", query, saveid);

	SQL_TQuery(g_hBDD, itemSave_Withdraw_2, query, client, DBPrio_High);
}

public void itemSave_Withdraw_2(Handle owner, Handle hQuery, const char[] error, any client){
	SQL_FetchRow(hQuery);
	int amount;
	int inBank;
	char split[2] = ";";
	char buffer[BUFFER_SIZE], buffer2[BUFFER_SIZE], szData[2][BUFFER_SIZE];
	int size = (BUFFER_SIZE+SQL_FetchSize(hQuery, 1));
	char[] data = new char[size];
	char tmp[128];
	
	SQL_FetchString(hQuery, 1, data, size);	
	// ------------
	//	Stocké sous le format: id,amount;id,amount;
	//
	amount = g_iUserData[client][i_ItemCount];
	for (int pos=0; pos < amount ; pos++) {
		int objet_id = g_iItems[client][pos][STACK_item_id];
		
		if( StringToInt(g_szItemList[objet_id][item_type_no_bank]) == 1 )
			continue;
		
		rp_ClientGiveItem(client, objet_id, g_iItems[client][pos][STACK_item_amount], true);
		LogToGame("[TSX-RP] [BANK-ITEM] %L a déposé: %d %s", client, g_iItems[client][pos][STACK_item_amount], g_szItemList[objet_id][item_type_name]);
		g_iItems[client][pos][STACK_item_id] = g_iItems[client][pos][STACK_item_amount] = 0;
	}
	
	g_iUserData[client][i_ItemCount] = 0;

	while( SplitString(data, split, buffer, BUFFER_SIZE) != -1 ) {
		
		Format(buffer2, BUFFER_SIZE, "%s%s", buffer, split);
		RemoveString(data, buffer2, false);
		ExplodeString(buffer, ",", szData, sizeof(szData), BUFFER_SIZE);
			
		int objet_id = StringToInt(szData[0]);
		int objet_amount = StringToInt(szData[1]);
			
		if( objet_id <= 0 || objet_id > MAX_ITEMS)
			continue;
		if( StringToInt(g_szItemList[objet_id][item_type_no_bank]) == 1 )
			continue;
		if( StrEqual(g_szItemList[objet_id][item_type_extra_cmd], "UNKNOWN") )
			continue;
		if( objet_amount <= 0 )
			continue;

		inBank = rp_GetClientItem(client, objet_id, true);
		
		rp_GetItemData(objet_id, item_type_name, tmp, sizeof(tmp));

		if( inBank < objet_amount ){
			if(inBank > 0)
				CPrintToChat(client, ""...MOD_TAG..." %T", "Item_NotEnough", client, objet_amount-inBank, tmp);
			else
				CPrintToChat(client, ""...MOD_TAG..." %T", "Item_NoMore", client, tmp, objet_amount-inBank);
			
			objet_amount = inBank;
		}
		
		rp_ClientGiveItem(client, objet_id, -objet_amount, true);
		rp_ClientGiveItem(client, objet_id, objet_amount, false);
		
		LogToGame("[TSX-RP] [BANK-ITEM] %L a retiré: %d %s", client, objet_amount, g_szItemList[objet_id][item_type_name]);
	}
	SQL_FetchString(hQuery, 0, buffer, BUFFER_SIZE);
	CloseHandle(hQuery);
}

void ItemSave_LoadNames(int client){
	char query[128];
	GetClientAuthId(client, AUTH_TYPE, query, sizeof(query), false);
	Format(query, sizeof(query), "SELECT slot, name FROM rp_itemsaves WHERE steamid='%s'", query);

	SQL_TQuery(g_hBDD, itemSave_LoadNames_2, query, client, DBPrio_High);
}

public void itemSave_LoadNames_2(Handle owner, Handle handle, const char[] error, any client) {
	if( handle == INVALID_HANDLE ) {
		LogError("[SQL] [ERROR] %s", error);
	}
	
	while( SQL_FetchRow(handle) ) {
		SQL_FetchString(handle, 1, g_szItems_SAVE[client][SQL_FetchInt(handle, 0)], sizeof(g_szItems_SAVE[][]));
	}

	CloseHandle(handle);
}
