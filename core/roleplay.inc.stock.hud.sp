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
		Format(szReturn, size, "\n%T", "HUD_Energy", client, g_flUserData[client][fl_Energy]);
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
		Format(szHUD, size, "%s%T\n", szHUD, "HUD_Dept", client, szDette);
	}
	else {
		Format(szHUD, size, "%s%T\n", szHUD, "HUD_Money", client, szMoney);
		Format(szHUD, size, "%s%T\n", szHUD, "HUD_Bank", client, szBank);
	}
	
	#if defined EVENT_APRIL
		Format(szHUD, size, "%s%T\n", szHUD, "HUD_Job", client, g_szJobList[ 0 ][job_type_name]);
	#else
		int job = g_iUserData[client][i_Job];
		Format(szHUD, size, "%s%T\n", szHUD, "HUD_Job", client, g_szJobList[ job ][job_type_name]);
	#endif
	
	
	if( group > 0 )
		Format(szHUD, size, "%s%T\n", szHUD, "HUD_Group", client, g_szGroupList[ group ][group_type_name]);
	
	Format(szHUD, size, "%s%T\n", szHUD, "HUD_Rank", client, g_iUserData[client][i_PlayerLVL], g_szLevelList[ g_iUserData[client][i_PlayerRank] ][rank_type_name]);
	
	Format(szHUD, size, "%s%T\n", szHUD, "HUD_Zone", client, g_szZoneList[ GetPlayerZone(client) ][zone_type_name]);
	
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
		if( g_iUserData[client][i_AddToPay] > 0 && g_iUserData[client][i_Dette] <= 0 ) {
			Format(szHUD, size, "%s\n%T", szHUD, "HUD_Salaire_Extra", client, g_szJobList[ job ][job_type_pay], g_iUserData[client][i_AddToPay]);
		}
		else {
			Format(szHUD, size, "%s\n%T", szHUD, "HUD_Salaire", client, g_szJobList[ job ][job_type_pay], g_iUserData[client][i_AddToPay]);
		}
	}
}
void PrintHours( char[] szReturn, int size) {
	static char szMonths[64], szHours[64];
	
	if( g_iHours < 10 ) {
		Format(szHours, sizeof(szHours), "0%d:", g_iHours);
	}
	else {
		Format(szHours, sizeof(szHours), "%d:", g_iHours);
	}
	
	if( g_iMinutes < 10 ) {
		Format(szHours, sizeof(szHours), "%s0", szHours);
	}
	Format(szHours, sizeof(szHours), "%s%d", szHours, g_iMinutes);
	Format(szMonths, sizeof(szMonths), "HUD_Month_%d", g_iMonth);
	
	Format(szReturn, size, "%T", "HUD_Date", LANG_SERVER, szHours, g_iDays, szMonths, g_iYear);
}
void PrintJail(int client, char[] szReturn, int size) {
	
	int min = g_iUserData[client][i_JailTime];
	int hours = 0;
	int jours = 0;
	
	hours = min/60;
	min = min%60;
	
	jours = hours/24;
	hours = hours%24;
	
	Format(szReturn, size, "\n%T", "HUD_Jail_Days", client, jours, hours, min);
	
	if( g_iUserData[client][i_JailTime] <= 0 ) {
		Format(szReturn, size, "");
	}
}

void PrintSick(int client, char[] szReturn, int size) {
	
	
	if( g_iUserData[client][i_Sick] <= 0 ) {
		Format(szReturn, size, "");
	}
	else {
		Format(szReturn, size, "\n%T", "HUD_Sick", client);
	}
}
void PrintAdmin( int client, char[] szAdmin, int size) {	
	int flags = GetUserFlagBits(client);
	if (flags & ADMFLAG_GENERIC || flags & ADMFLAG_KICK || flags & ADMFLAG_ROOT) {
		Format(szAdmin, size, "\n%T", "HUD_Admin", client, g_iEntityCount/float(g_iEntityLimit) * 100.0, GetPlayerZone(client), g_iUserData[client][i_GiveXP]);
	}
	else {
		Format(szAdmin, size, "");
	}
}
void PrintMail( int client, char[] szAdmin, int size) {
	if ( g_bUserData[client][b_HasQuest]) {
		Format(szAdmin, size, "\n%T", "HUD_Quest", client);
		if( g_bUserData[client][b_HasMail]) {
			Format(szAdmin, size, "%s\n%T", szAdmin, "HUD_Mail", client);
		}
	}
	else if ( g_bUserData[client][b_HasMail]) {
		Format(szAdmin, size, "\n%T", "HUD_Mail", client);
	}
	else {
		Format(szAdmin, size, "");
	}
}
	
	