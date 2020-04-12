#if defined _roleplay_stock_jobs_included
#endinput
#endif
#define _roleplay_stock_jobs_included

#if defined ROLEPLAY_SUB
	#include "../roleplay.sp"
#else
	#include "roleplay.sp"
#endif

bool HasDoctor(int client) {	
	
	static float g_flLastCheck = 0.0;
	static bool g_bLastData = false;
	
	if( g_flLastCheck > GetGameTime() ) {
		return g_bLastData;
	}
	g_flLastCheck = GetGameTime() + 5.0;
	g_bLastData = false;
	
	if( !(rp_GetZoneBit( rp_GetPlayerZone(client) ) & BITZONE_PVP) && !(rp_GetZoneBit( rp_GetPlayerZone(client) ) & BITZONE_EVENT) )
		return g_bLastData;
	if( GetConVarInt(g_hSick) == 0 )
		return g_bLastData;
	
	for(int i=1;i<=MaxClients;i++) {
		if( !IsValidClient(i) )
			continue;
		if( i == client )
			continue;
		if( g_bUserData[i][b_IsAFK] ) 
			continue;
		if( IsClientInJail(i) )
			continue;
		
		if( IsMedic(i) ) {
			if( g_iUserData[i][i_Job] == 14 )
				continue;
			
			g_bLastData = true;
		}
	}
	return g_bLastData;
}
//
// Jobs:
bool IsPolice(int client) {
	if( g_iUserData[client][i_Job] == 1 || StringToInt(g_szJobList[ g_iUserData[client][i_Job] ][job_type_ownboss]) == 1)
		return true;
	
	return false;
}
public bool IsFBI(int client) {
	
	if( g_iUserData[client][i_Job] == 7)
		return true;
	
	return false;
}
bool IsMedic(int client) {
	if( g_iUserData[client][i_Job] == 11 || StringToInt(g_szJobList[ g_iUserData[client][i_Job] ][job_type_ownboss]) == 11)
		return true;
	
	return false;
}
bool IsMcDo(int client) {
	if( g_iUserData[client][i_Job] == 21 || StringToInt(g_szJobList[ g_iUserData[client][i_Job] ][job_type_ownboss]) == 21)
		return true;
	
	return false;
}
bool IsArtisan(int client) {
	if( g_iUserData[client][i_Job] == 31 || StringToInt(g_szJobList[ g_iUserData[client][i_Job] ][job_type_ownboss]) == 31)
		return true;
	
	return false;
}
bool IsTueur(int client) {
	if( g_iUserData[client][i_Job] == 41 || StringToInt(g_szJobList[ g_iUserData[client][i_Job] ][job_type_ownboss]) == 41)
		return true;
	
	return false;
}/*
bool IsVendeurVoiture(int client) {
	if( g_iUserData[client][i_Job] == 51 || StringToInt(g_szJobList[ g_iUserData[client][i_Job] ][job_type_ownboss]) == 51)
		return true;
	
	return false;
}*/
bool IsAppartVendeur(int client) {
	if( g_iUserData[client][i_Job] == 61 || StringToInt(g_szJobList[ g_iUserData[client][i_Job] ][job_type_ownboss]) == 61)
		return true;
	
	return false;
}
bool IsCoach(int client) {
	if( g_iUserData[client][i_Job] == 71 || StringToInt(g_szJobList[ g_iUserData[client][i_Job] ][job_type_ownboss]) == 71)
		return true;
	
	return false;
}
bool IsDealer(int client) {
	if( g_iUserData[client][i_Job] == 81 || StringToInt(g_szJobList[ g_iUserData[client][i_Job] ][job_type_ownboss]) == 81)
		return true;
	
	return false;
}
bool IsGangMaffia(int client) {
	if( g_iUserData[client][i_Job] == 91 || StringToInt(g_szJobList[ g_iUserData[client][i_Job] ][job_type_ownboss]) == 91)
		return true;
	
	return false;
}
bool IsJuge(int client) {
	if( g_iUserData[client][i_Job] == 101 || StringToInt(g_szJobList[ g_iUserData[client][i_Job] ][job_type_ownboss]) == 101)
		return true;
	
	return false;
}
bool IsArmu(int client) {
	if( g_iUserData[client][i_Job] == 111 || StringToInt(g_szJobList[ g_iUserData[client][i_Job] ][job_type_ownboss]) == 111)
		return true;
	
	return false;
}/*
bool IsVendeurSkins(int client) {
	if( g_iUserData[client][i_Job] == 121 || StringToInt(g_szJobList[ g_iUserData[client][i_Job] ][job_type_ownboss]) == 121)
		return true;
	
	return false;
}
bool IsArtificier(int client) {
	if( g_iUserData[client][i_Job] == 131 || StringToInt(g_szJobList[ g_iUserData[client][i_Job] ][job_type_ownboss]) == 131)
		return true;
	
	return false;
}
bool IsDetective(int client) {
	if( g_iUserData[client][i_Job] == 141 || StringToInt(g_szJobList[ g_iUserData[client][i_Job] ][job_type_ownboss]) == 141)
		return true;
	
	return false;
}*/
/*
bool IsLoto(int client) {
	if( g_iUserData[client][i_Job] == 171 || StringToInt(g_szJobList[ g_iUserData[client][i_Job] ][job_type_ownboss]) == 171)
		return true;
	
	return false;
	
}*/
bool IsGang18th(int client) {
	if( g_iUserData[client][i_Job] == 181 || StringToInt(g_szJobList[ g_iUserData[client][i_Job] ][job_type_ownboss]) == 181)
		return true;
	
	return false;
}
bool IsSexShop(int client) {
	if( g_iUserData[client][i_Job] == 191 || StringToInt(g_szJobList[ g_iUserData[client][i_Job] ][job_type_ownboss]) == 191)
		return true;
	
	return false;
}/*
bool IsBanquier(int client) {
	if( g_iUserData[client][i_Job] == 211 || StringToInt(g_szJobList[ g_iUserData[client][i_Job] ][job_type_ownboss]) == 211)
		return true;
	
	return false;
}*/
bool IsTech(int client) {
	if( g_iUserData[client][i_Job] == 221 || StringToInt(g_szJobList[ g_iUserData[client][i_Job] ][job_type_ownboss]) == 221)
		return true;
	
	return false;
}
bool IsBoss(int client) {
	if( !IsValidClient(client) )
		return false;
	
	if( StringToInt(  g_szJobList[ g_iUserData[client][i_Job] ][job_type_isboss]) == 1)
		return true;
	if( StringToInt(  g_szJobList[ g_iUserData[client][i_Job] ][job_type_cochef] ) == 1)
		return true;
	
	return false;
}
void SaveJob(int job_id) {
	if( g_bPreventLoadConfig ) 
		return;
	
	if( strlen(g_szJobList[job_id][job_type_name]) <= 1 ) 
		return;
	
	char query[1024];
	Format(query, 1023, "UPDATE `rp_jobs` SET `pay`='%i', `capital`='%i' WHERE `job_id`='%i';", 
		StringToInt(g_szJobList[job_id][job_type_pay]),
		StringToInt(g_szJobList[job_id][job_type_capital]),
		job_id
	);
	SQL_TQuery(g_hBDD, SQL_QueryCallBack, query);
}

void SetJobCapital(int job_id, int amount) {
	if( job_id <= 0 ) {
		return;
	}
	
	if( StringToInt( g_szJobList[ job_id ][job_type_isboss] ) != 1 ) {
		job_id = StringToInt( g_szJobList[ job_id ][job_type_ownboss] );
	}
	
	Format(g_szJobList[ job_id ][job_type_capital], 127, "%i", amount);
}
int GetJobCapital(int job_id) {
	if( StringToInt( g_szJobList[ job_id ][job_type_isboss] ) != 1 ) {
		job_id = StringToInt( g_szJobList[ job_id ][job_type_ownboss] );
	}
	
	return StringToInt( g_szJobList[ job_id ][job_type_capital] );
}
int GetJobPrimaryID(int client) {
	int job_id = g_iUserData[client][i_Job];
	
	if( StringToInt( g_szJobList[ job_id ][job_type_isboss] ) != 1 ) {
		job_id = StringToInt( g_szJobList[ job_id ][job_type_ownboss] );
	}
	
	return job_id;
}
