#if defined _roleplay_phone_included	
#endinput
#endif	

#define _roleplay_phone_included	

#if defined ROLEPLAY_SUB
	#include "../roleplay.sp"
#else
	#include "roleplay.sp"
#endif

public Action Copter_Post(Handle timer, Handle dp ) {
	float vecDest[2];
	
	ResetPack(dp);
	vecDest[0] = ReadPackFloat(dp);
	vecDest[1] = ReadPackFloat(dp);
	
	ServerCommand("sm_effect_copter %f %f", vecDest[0], vecDest[1]);
	
	return Plugin_Stop;
}
void DisplayPhoneMenu(int client) {
	if( g_flPhoneStart < GetTickedTime() )
		return;
	
	float vecDir[3];
	vecDir[0] = Math_GetRandomFloat(-3250.0, 2000.0);
	vecDir[1] = Math_GetRandomFloat(-5000.0, 900.0);
	
	float tmp[3]; GetClientAbsOrigin(client, tmp);
	TE_SetupBeamPoints(vecDir, tmp, g_cBeam, 0, 0, 0, 17.5, 1.0, 10.0, 0, 0.0, {255, 255, 255, 100}, 20);
	TE_SendToClient(client);
	
	TE_SetupBeamRingPoint(vecDir, 50.0, 250.0, g_cBeam, 0, 0, 30, 17.5, 20.0, 0.0, { 255, 255, 255, 100 }, 10, 0);
	TE_SendToClient(client);
	
	vecDir[2] -= 2000.0;
	
	Handle dp;
	CreateDataTimer(7.5, Copter_Post, dp);
	WritePackFloat(dp, vecDir[0]);
	WritePackFloat(dp, vecDir[1]);
	
	Handle menu = CreateMenu(MenuNothing);
	SetMenuTitle(menu, "%T\n ", "Phone_Mission", client);
	
	char msg[256], expl[32][64];
	Format(msg, sizeof(msg), "%T", "Phone_Mission_Send", client, g_szZoneList[GetPointZone(vecDir)][zone_type_name]);
	String_WordWrap(msg, 40);
	int len = ExplodeString(msg, "\n", expl, sizeof(expl), sizeof(expl[]));
	for (int i = 0; i < len; i++) {
		AddMenuItem(menu, "_", expl[i], ITEMDRAW_DISABLED);
	}
	
	
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_DURATION);	
			
	g_flPhoneStart = -60.0;
	return;
}
