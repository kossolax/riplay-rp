#if defined _roleplay_stock_groups_included
#endinput
#endif
#define _roleplay_stock_groups_included

#if defined ROLEPLAY_SUB
	#include "../roleplay.sp"
#else
	#include "roleplay.sp"
#endif

int g_iCapture[view_as<int>(capture_max)];

bool GotPvPvPBonus(int client, rp_capture_zone cap) {
	int group = GetGroupPrimaryID(client);
	if( group == 0 )
		return false;
	
	if( group == g_iCapture[ cap ] )
		return true;

	return false;	
}
bool GotPvPKey(int client, int target) {
	int group = GetGroupPrimaryID(client);
	if( group == 0 )
		return false;
	
	int zone = GetPlayerZone(target);
	
	if( group == g_iCapture[cap_bunker] || g_bIsInCaptureMode ) {
		if( StrContains(g_szZoneList[zone][zone_type_type], "bunker") != -1 )
			return true;
	}
	if( group == g_iCapture[cap_villa]  ) {
		if( StrContains(g_szZoneList[zone][zone_type_type], "appart_51") != -1 )
			return true;
	}
	
	return false;
}
void PrintTag() {
	PrintTagPosition(g_iCapture[cap_villa], view_as<float>( { -6616.0, 2076.0, -2169.0} ));
	PrintTagPosition(g_iCapture[cap_villa], view_as<float>( { -6984.0, 3828.0, -2228.0} ));
	PrintTagPosition(g_iCapture[cap_bunker], view_as<float>( { -4223.9, -8635.9, -1624.8} ));
	PrintTagPosition(g_iCapture[cap_bunker], view_as<float>( { -6271.9, -7316.8, -1694.1} ));
	PrintTagPosition(g_iCapture[cap_bunker], view_as<float>( { -5504.0, -7292.3, -1618.0} ));
	PrintTagPosition(g_iCapture[cap_bunker], view_as<float>( { -3321.6, -8831.9, -1888.3} ));
	PrintTagPosition(0, view_as<float>( {-127.9, 740.5, -2070.0} ));
	
	
}
void PrintTagPosition(int groupID, float vec[3]) {
	static int iPrecached[MAX_GROUPS];
	
	char path[255], gang[128];
	if( groupID == 0 ) {
		Format(path, sizeof(path), "deadlydesire/annonces/%s.vmt", g_szVillaOwner[annonceID]);
	}
	else {
		rp_GetGroupData(groupID, group_type_tag, gang, sizeof(gang));	
		Format(path, sizeof(path), "deadlydesire/groups/princeton/%s.vmt", gang);
	}
	
	if( !IsDecalPrecached(path) || iPrecached[groupID] < 0 ) {
		iPrecached[groupID] = PrecacheDecal(path);
	}
	
	TE_Start("World Decal");
	TE_WriteVector("m_vecOrigin", vec);
	TE_WriteNum("m_nIndex", iPrecached[groupID]);
	TE_SendToAll();
}
void SaveGroup(int job_id) {
	if( g_bPreventLoadConfig ) 
		return;
	
	char query[1024];
	Format(query, 1023, "UPDATE `rp_groups` SET `capital`='%i' WHERE `id`='%i';", 
		StringToInt(g_szGroupList[job_id][group_type_capital]),
		job_id
	);
	SQL_TQuery(g_hBDD, SQL_QueryCallBack, query);
}
void addToGroup(int client, int amount) {
	int group = GetGroupPrimaryID(client);
	int job = GetGroupPrimaryID(client);
	
	if( group <= 0 )
		return;
	if( job <= 0 )
		return;
	if( amount <= 0 )
		return;
	
	int count = 0, todo=0;
	
	for(int i=1; i<=MaxClients; i++) {
		if( !IsValidClient(i) )
			continue;
		
		if( g_iUserData[i][i_Group] == 0 )
			continue;
		if( g_iUserData[i][i_Job] == 0 )
			continue;
		
		if( GetGroupPrimaryID(i) != group )
			continue;
		
		if( StringToInt(g_szGroupList[ g_iUserData[i][i_Group] ][group_type_chef]) == 1 ) {
			count++;
			
			if( job == GetJobPrimaryID(i) )
				todo = 1;
		}
	}
	
	int res = 0;
	if( count > 2 ) {
		res = -(amount/100) * 2;
		
	}
	else {
		res = (amount/100) * 2;
		if( todo ) {
			res *= 10;
		}
	}
	
	if( res <= 0 ) {
		return;
	}
	
	SetGroupCapital(group, GetGroupCapital(group) );
}
int GetGroupPrimaryID(int client) {
	int group_id = g_iUserData[client][i_Group];
	
	if( StringToInt( g_szGroupList[ group_id ][job_type_isboss] ) != 1 ) {
		group_id = StringToInt( g_szGroupList[ group_id ][job_type_ownboss] );
	}
	
	return group_id;
}
int GetGroupID(int group_id) {
	
	if( StringToInt( g_szGroupList[ group_id ][job_type_isboss] ) != 1 ) {
		group_id = StringToInt( g_szGroupList[ group_id ][job_type_ownboss] );
	}
	
	return group_id;
}
void SetGroupCapital(int group_id, int amount) {
	if( group_id <= 0 ) {
		return;
	}
	
	if( StringToInt( g_szGroupList[ group_id ][ group_type_chef] ) != 1 ) {
		group_id = StringToInt( g_szGroupList[ group_id ][group_type_own_chef] );
	}
	
	Format(g_szGroupList[ group_id ][group_type_capital], 127, "%i", amount);
}
int GetGroupCapital(int group_id) {
	if( StringToInt( g_szGroupList[ group_id ][ group_type_chef] ) != 1 ) {
		group_id = StringToInt( g_szGroupList[ group_id ][group_type_own_chef] );
	}
	
	return StringToInt( g_szGroupList[ group_id ][group_type_capital] );
}