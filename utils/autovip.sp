#include <sourcemod>
#include <colors_csgo>
#include <sdkhooks>
#include <smlib>
#include <sdktools> 

#include <roleplay.inc>	

#define VIP_GROUP_ID 29

Handle g_hForumDatabase = null;

public Plugin:myinfo =
{
	name = "Force VIP Group",
	author = "Kriax",
	version = "1.0",
	description = "Change le groupe vip",
};

public void OnPluginStart() {
	char szError[64];
	g_hForumDatabase = SQL_Connect("forum", true, szError, sizeof(szError));

	if(g_hForumDatabase == INVALID_HANDLE) {
		SetFailState("Connexion Database Failed %s", szError);
	}
}

public void OnPluginEnd() {
	delete g_hForumDatabase;
}

public void OnClientPutInServer(int client) {
	if(IsFakeClient(client) || g_hForumDatabase == null) {
		return;
	}

	GetClientForum(client);
}

/** Called to making the request in order to get the client from the forum */
public void GetClientForum(int client) {
	char steamid[32];
	GetClientAuthId(client, AuthId_SteamID64, steamid, sizeof(steamid));

	char query[256];
	Handle hQuery;
	
	/** Get client from forum */

	Format(query, sizeof(query), "SELECT `member_group_id`, `name` FROM `ipb_core_members` WHERE `steamid` = '%s'", steamid);
	hQuery = SQL_Query(g_hForumDatabase, query);

	if(hQuery == INVALID_HANDLE) {
		return;
	}

	if(!SQL_FetchRow(hQuery)) {
		return;
	}

	char name[32];
	SQL_FetchString(hQuery, 1, name, sizeof(name));

	bool isVip = SQL_FetchInt(hQuery, 0) == VIP_GROUP_ID ? true:false;

	/* Get client from sm_admins */

	Format(query, sizeof(query), "SELECT `id` FROM `sm_admins` WHERE `identity` = '%s'", steamid);
	hQuery = SQL_Query(rp_GetDatabase(), query);

	if(hQuery == INVALID_HANDLE) {
		return;
	}

	// client db fetched
	if(SQL_GetRowCount(hQuery) == 1) {
		// client is not vip, delete him
		if(!isVip) {
			SQL_FetchRow(hQuery);
			int id = SQL_FetchInt(hQuery, 0);

			Format(query, sizeof(query), "DELETE FROM `sm_admins_groups` WHERE `admin_id` = '%i'", id);
			SQL_Query(rp_GetDatabase(), query);

			Format(query, sizeof(query), "DELETE FROM `sm_admins` WHERE `id` = '%i'", id);
			SQL_Query(rp_GetDatabase(), query);
		}

		return;
	} 

	// client is not on db
	if(SQL_GetRowCount(hQuery) == 0) {
		// client is vip, insert him
		if(isVip) {
			Format(query, sizeof(query), "INSERT INTO `sm_admins`(`identity`, `name`) VALUES ('%s', '%s')", steamid, name);
			hQuery = SQL_Query(rp_GetDatabase(), query);

			int id = SQL_GetInsertId(hQuery);

			if(id == 0) {
				return;
			}

			Format(query, sizeof(query), "INSERT INTO `sm_admins_groups`(`admin_id`, `group_id`, `inherit_order`) VALUES (%i, 4, 1)", id);
			hQuery = SQL_Query(rp_GetDatabase(), query);
		}
	}
}