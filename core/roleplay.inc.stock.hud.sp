#if defined _roleplay_stock_hud_included
#endinput
#endif
#define _roleplay_stock_hud_included

#if defined ROLEPLAY_SUB
	#include "../roleplay.sp"
#else
	#include "roleplay.sp"
#endif

// -----------------------------------------------------------------------------------------------------------------
//
//	Stocks
//


void PrintEnergy(int client, char[] szReturn, int size) {
	Format(szReturn, size, "");
	
	if( g_flUserData[client][fl_Energy] > 0.0 ) {
		Format(szReturn, size, "\nEnergie: %.2f", g_flUserData[client][fl_Energy]);
	}
}

void PrintHUD(int client, char[] szHUD, int size) {
	static char szMoney[64], szBank[64], szDette[64];
	String_NumberFormat(g_iUserData[client][i_Money],	szMoney,sizeof(szMoney));
	String_NumberFormat(g_iUserData[client][i_Bank],	szBank,	sizeof(szBank));
	String_NumberFormat(g_iUserData[client][i_Dette],	szDette,sizeof(szDette));
	
	
	#if defined EVENT_APRIL
		if( g_iUserData[client][i_Money] != 0 )
			Format(szMoney, sizeof(szMoney), "-%s", szMoney);
		Format(szBank, sizeof(szBank), "-%s", szBank);
	#endif	
	
	int group = g_iUserData[client][i_Group];
	
	Format(szHUD, size, "");
	
	if( g_iUserData[client][i_Dette] > 0 ) {
		Format(szHUD, size, "%sDette     : %s$\n", szHUD, szDette);
	}
	else {
		Format(szHUD, size, "%sArgent   : %s$\n", szHUD, szMoney);
		Format(szHUD, size, "%sBanque  : %s$\n", szHUD, szBank);
	}
	
	#if defined EVENT_APRIL
		Format(szHUD, size, "%sJob        : %s\n", szHUD, g_szJobList[ 0 ][job_type_name]);
	#else
		int job = g_iUserData[client][i_Job];
		Format(szHUD, size, "%sJob        : %s\n", szHUD, g_szJobList[ job ][job_type_name]);
	#endif
	
	
	if( group > 0 )
		Format(szHUD, size, "%sGroupe : %s\n", szHUD, g_szGroupList[ group ][group_type_name]);
	
	Format(szHUD, size, "%sRang     : %d - %s\n", szHUD, g_iUserData[client][i_PlayerLVL], g_szLevelList[ g_iUserData[client][i_PlayerRank] ][rank_type_name]);
	
	Format(szHUD, size, "%sZone     : %s\n", szHUD, g_szZoneList[ GetPlayerZone(client) ][zone_type_name]);
	
	char szBuffer[100];
	#if defined EVENT_APRIL
	#else
	PrintCapital(client,szBuffer, sizeof(szBuffer));	Format(szHUD, size, "%s%s", szHUD, szBuffer);
	#endif
	PrintJail(client,	szBuffer, sizeof(szBuffer));	Format(szHUD, size, "%s%s", szHUD, szBuffer);
	PrintEnergy(client,	szBuffer, sizeof(szBuffer));	Format(szHUD, size, "%s%s", szHUD, szBuffer);
	PrintSick(client,	szBuffer, sizeof(szBuffer));	Format(szHUD, size, "%s%s", szHUD, szBuffer);
	#if defined EVENT_APRIL
	#else
	PrintAdmin(client,	szBuffer, sizeof(szBuffer));	Format(szHUD, size, "%s%s", szHUD, szBuffer);
	#endif
	PrintMail(client,	szBuffer, sizeof(szBuffer));	Format(szHUD, size, "%s%s", szHUD, szBuffer);
	
}
void PrintCapital(int client, char[] szHUD, int size) {
	
	int job = g_iUserData[client][i_Job];	
	Format(szHUD, size, "");
	
	if( g_iUserData[client][i_Job] > 0 ) {
		Format(szHUD, size, "%s\nSalaire  : %s$", szHUD, g_szJobList[ job ][job_type_pay]);
		
		if( g_iUserData[client][i_AddToPay] > 0 && g_iUserData[client][i_Dette] <= 0 ) {
			Format(szHUD, size, "%s + %d$", szHUD, g_iUserData[client][i_AddToPay]);
		}
	}
}
void PrintHours( char[] szReturn, int size) {
	
	char[] szHours = new char[size];
	if( g_iHours < 10 ) {
		Format(szHours, size, "0%d:", g_iHours);
	}
	else {
		Format(szHours, size, "%d:", g_iHours);
	}
	
	if( g_iMinutes < 10 ) {
		Format(szHours, size, "%s0", szHours);
	}
	Format(szHours, size, "%s%d", szHours, g_iMinutes);
	
	Format(szReturn, size, "%s %i %s %i", szHours, g_iDays, g_szMonth[g_iMonth-1], g_iYear);
}
void PrintJail(int client, char[] szReturn, int size) {
	
	int min = g_iUserData[client][i_JailTime];
	int hours = 0;
	int jours = 0;
	
	hours = min/60;
	min = min%60;
	
	jours = hours/24;
	hours = hours%24;
	
	if( jours > 0) {
		Format(szReturn, size, "\nEn prison pour encore: %ij %ih%i", jours, hours, min);
	}
	else {
		Format(szReturn, size, "\nEn prison pour encore: %ih%i",  hours, min);
	}
	
	if( g_iUserData[client][i_JailTime] <= 0 ) {
		Format(szReturn, size, "");
	}
}

void PrintSick(int client, char[] szReturn, int size) {
	
	
	if( g_iUserData[client][i_Sick] <= 0 ) {
		Format(szReturn, size, "");
	}
	else if( HasDoctor(client) ) {
		Format(szReturn, size, "\n /!\\ Maladie /!\\");
	}
	else {
		Format(szReturn, size, "");
	}
}
void PrintAdmin( int i, char[] szAdmin, int size) {	
	int flags = GetUserFlagBits(i);
	if (flags & ADMFLAG_GENERIC || flags & ADMFLAG_KICK) {
		Format(szAdmin, size, "\nLimite  : %.1f%% - Z:%i - XP:%d", g_iEntityCount/float(g_iEntityLimit) * 100.0, GetPlayerZone(i), g_iUserData[i][i_GiveXP]);
	}
	else {
		Format(szAdmin, size, "");
	}
}
void PrintMail( int i, char[] szAdmin, int size) {
	if ( g_bUserData[i][b_HasQuest]) {
		Format(szAdmin, size, "\nUne quête est disponible");
		if( g_bUserData[i][b_HasMail]) {
			Format(szAdmin, size, "%s\nUn nouveau message", szAdmin);
		}
	}
	else if ( g_bUserData[i][b_HasMail]) {
		Format(szAdmin, size, "\nUn nouveau message");
	}
	else {
		Format(szAdmin, size, "");
	}
}
	
	