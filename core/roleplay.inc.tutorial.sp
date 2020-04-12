#if defined _roleplay_tutorial_included	
	#endinput
#endif	
	
#define _roleplay_tutorial_included	
	
#if defined ROLEPLAY_SUB
	#include "../roleplay.sp"
#else
	#include "roleplay.sp"
#endif

void DisplayTutorial(int client) {
	if( !IsValidClient(client) )
		return;
	
	if( !g_bUserData[client][b_isConnected] )
		return;
	if( !g_bUserData[client][b_isConnected2] )
		return;
	
	float vecOrigin[3];
	GetClientAbsOrigin(client, vecOrigin);
	
	if( ! IsTutorialOver(client) ) {
		
		if( g_iUserData[client][i_JailTime] > 2 ) {
			g_iUserData[client][i_JailTime] = 2;
		}
		g_iUserData[client][i_Sickness] = 0;
		g_iUserData[client][i_Job] = 0;
		
		if( g_iClientQuests[client][questID] == -1 && g_iClientQuests[client][stepID] == -1 ) {
			StartQuest(client, "000-tutorial");
		}
	}
}
stock bool IsTutorialOver(int client) {
	if( g_iUserData[client][i_Tutorial] > 11 ) {
		return true;
	}
	return false;
}