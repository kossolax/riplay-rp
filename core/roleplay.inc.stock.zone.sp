#if defined _roleplay_stock_zone_included
#endinput
#endif
#define _roleplay_stock_zone_included

#if defined ROLEPLAY_SUB
	#include "../roleplay.sp"
#else
	#include "roleplay.sp"
#endif

int getZoneAppart(int client) {
	
	static float g_flLastCheck[65] = 0.0;
	static g_iLastData[65];
	
	if( g_flLastCheck[client] > GetGameTime() ) {
		return g_iLastData[client];
	}
	
	char ZoneName[32];
	Format(ZoneName, sizeof(ZoneName), "%s", g_szZoneList[GetPlayerZone(client)][zone_type_type]);
	int res = -1;
	
	if( g_iUserData[client][i_AppartCount] > 0 && StrContains(ZoneName, "appart_", false) == 0 ) {
		ReplaceString(ZoneName, sizeof(ZoneName), "appart_", "");
		res = StringToInt(ZoneName);
	}
	
	g_iLastData[client] = res;
	g_flLastCheck[client] = GetGameTime() + 1.0;
	
	return res;
}
	
int GetZoneBit(int zoneID, float cache=300.0) {
	
	if( g_flLastCheck_ZONE[zoneID] > GetGameTime() ) {
		return g_iLastData_ZONE[zoneID];
	}
	
	
	g_iLastData_ZONE[zoneID] = StringToInt(g_szZoneList[ zoneID ][zone_type_bit]);
	g_flLastCheck_ZONE[zoneID] = GetGameTime() + cache;
	
	return g_iLastData_ZONE[zoneID];
}
void SetZoneBit(int zoneID, int bit) {
	
	Format(g_szZoneList[zoneID][zone_type_bit], sizeof(g_szZoneList[]), "%d", bit);
	
	g_iLastData_ZONE[zoneID] = bit;
	g_flLastCheck_ZONE[zoneID] = GetGameTime() + 1.0;
}
bool IsClientInJail(int client) {
	
	if( GetClientTeam(client) == CS_TEAM_CT ) {
		return false;
	}
	if( GetZoneBit(GetPlayerZone(client)) & (BITZONE_JAIL|BITZONE_HAUTESECU|BITZONE_LACOURS) ) {
		return true;
	}
	
	return false;
}
bool IsInPVP(int client, float cache_time = 0.2) {
	static float g_flLastCheck[MAX_ENTITIES+1] = 0.0;
	static bool g_bLastData[MAX_ENTITIES+1];
	
	if( g_flLastCheck[client] > GetGameTime() ) {
		return g_bLastData[client];
	}
	
	
	g_flLastCheck[client] = GetGameTime() + cache_time;
	g_bLastData[client] = false;
	
	if( GetZoneBit(GetPlayerZone(client)) & BITZONE_PVP ) {
		g_bLastData[client] = true;
	}
	
	return g_bLastData[client];
}


int IsAtBankPoint(int client) {
	int ent = rp_GetClientTarget(client);
	if( IsValidBank(ent) && IsEntitiesNear(client, ent, true) )
		return ent;
	return 0;
}
bool IsValidBank(int ent) {
	if( ent <= 0 )
		return false;
	
	char classname[64];
	GetEdictClassname(ent, classname, sizeof(classname));
	
	if( StrEqual(classname, "rp_bank") ) {
		return true;
	}
	return false;
}
bool IsAtPhonePoint(int client) {
	if( !IsPlayerAlive(client) )
		return false;
	
	float f_Origin[3];
	GetClientAbsOrigin(client, f_Origin);
	
	for( int i=0; i<MAX_ENTITIES; i++) {
		
		if( !IsValidEdict(i) )
			continue;
		if( !IsValidEntity(i) )
			continue;
		
		char classname[64];
		GetEdictClassname(i, classname, 63);
		
		if( StrContains(classname, "rp_phone") == 0 ) {
			
			float vecOrigin[3];
			Entity_GetAbsOrigin(i, vecOrigin);
			
			if( GetVectorDistance(f_Origin, vecOrigin) < 50 )
				return true;
		}
	}
	
	return false;
}
int GetPlayerZone(int client, float cacheTime = 0.15) {
	if( !IsValidEdict(client) )
		return 0;
	
	static float g_flLastCheck[MAX_ENTITIES+1];
	static g_bLastData[MAX_ENTITIES+1];
	
	if( g_flLastCheck[client] > GetGameTime() ) {
		return g_bLastData[client];
	}
	
	g_flLastCheck[client] = GetGameTime() + cacheTime;
	
	float f_ClientOrigin[3];
	
	if( IsValidClient(client) && IsInVehicle(client) ) {
		int vehicle = GetEntPropEnt(client, Prop_Send, "m_hVehicle");
		if( vehicle >= 0 )
			GetEntPropVector(vehicle, Prop_Send, "m_vecOrigin", f_ClientOrigin);
		else
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", f_ClientOrigin);
	}
	else {
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", f_ClientOrigin);
	}
	
	g_bLastData[client] = GetPointZone(f_ClientOrigin);
	
	return g_bLastData[client];
}
int GetPointZone(float origin[3]) {
	
	for(int i=1; i<MAX_ZONES; i++) {
		if(	origin[0] <= g_flZones[i][1][0] && origin[1] <= g_flZones[i][1][1] && origin[2] <= g_flZones[i][1][2] &&
			origin[0] >= g_flZones[i][0][0] && origin[1] >= g_flZones[i][0][1] && origin[2] >= g_flZones[i][0][2] ) {
			if( strlen(g_szZoneList[i][zone_type_name]) <= 1 )
				continue;
			return i;
		}
	}
	return 0;
}
