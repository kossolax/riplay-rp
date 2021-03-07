#if defined _roleplay_natives_included
#endinput
#endif
#define _roleplay_natives_included

#if defined ROLEPLAY_SUB
	#include "../roleplay.sp"
#else
	#include "roleplay.sp"
#endif


public APLRes AskPluginLoad2(Handle hPlugin, bool isAfterMapLoaded, char[] error, int err_max) {
	
	CreateNative("rp_HookEvent", 		Native_rp_HookEvent);
	CreateNative("rp_UnhookEvent", 		Native_rp_UnhookEvent);
	
	CreateNative("rp_GetClientFloat",	Native_rp_getClientFloat);
	CreateNative("rp_SetClientFloat",	Native_rp_setClientFloat);
	CreateNative("rp_GetClientInt",		Native_rp_getClientInt);
	CreateNative("rp_SetClientInt",		Native_rp_setClientInt);
	
	CreateNative("rp_GetClientBool",	Native_rp_getClientBool);
	CreateNative("rp_SetClientBool",	Native_rp_setClientBool);
	CreateNative("rp_SetClientString",	Native_rp_SetClientString);
	CreateNative("rp_GetClientString",	Native_rp_GetClientString);
	CreateNative("rp_GetClientSSO",		Native_rp_GetClientSSO);
	CreateNative("rp_GetClientDouble",	Native_rp_GetClientDouble);
	CreateNative("rp_ClientMoney",		Native_rp_ClientMoney);
	
	
	CreateNative("rp_GetClientStat",		Native_rp_getClientStat);
	CreateNative("rp_SetClientStat",		Native_rp_setClientStat);
	CreateNative("rp_GetClientPlaytimeJob",		Native_rp_GetClientPlaytimeJob);
	
	CreateNative("rp_ClientGiveItem",	Native_rp_giveClientItem);
	CreateNative("rp_ClientUpdateBank", Native_rp_ClientUpdateBank);
	
	CreateNative("rp_IsEntitiesNear", 	Native_rp_IsEntitiesNear);
	CreateNative("rp_IsTutorialOver", 	Native_rp_IsTutorialOver);
	CreateNative("rp_IsClientNew", Native_rp_IsClientNew);	
	
	CreateNative("rp_IsTargetSeen", Native_rp_IsTargetSeen);
	CreateNative("rp_IsTargetHear", Native_rp_IsTargetHear);	
	
	CreateNative("rp_Effect_Smoke", 		Native_rp_Effect_Smoke);
	CreateNative("rp_Effect_VisionTrouble", Native_rp_Effect_VisionTrouble);
	CreateNative("rp_Effect_ShakingVision", Native_rp_Effect_ShakingVision);
	CreateNative("rp_Effect_Particle", 		Native_rp_Effect_Particle);
	CreateNative("rp_Effect_ParticlePath", 	Native_rp_Effect_ParticlePath);
	CreateNative("rp_Effect_ParticleTE", 	Native_rp_Effect_ParticleTE);
	
	CreateNative("rp_Effect_Tazer", 		Native_rp_Effect_Tazer);
	CreateNative("rp_Effect_Explode", Native_rp_Effect_Explode);
	CreateNative("rp_Effect_SpawnMoney", Native_rp_Effect_SpawnMoney);
	CreateNative("rp_Effect_BeamBox", Native_rp_Effect_BeamBox);
	CreateNative("rp_Effect_Cashflow", Native_rp_Effect_Cashflow);
	
	CreateNative("rp_CanMakeSuccess",	Native_rp_CanMakeSuccess);
	CreateNative("rp_IncrementSuccess",	Native_rp_IncrementSuccess);
	
	CreateNative("rp_ClientRespawn",	Native_rp_ClientRespawn);
	CreateNative("rp_ClientIgnite", 	Native_rp_ClientIgnite);
	CreateNative("rp_ClientPoison", 	Native_rp_ClientPoison);
	CreateNative("rp_ClientDamage", 	Native_rp_ClientDamage);
	CreateNative("rp_ClientGetName", 	Native_rp_ClientGetName);
	CreateNative("rp_ClientSave", 		Native_rp_ClientSave);
	CreateNative("rp_ClientColorize", Native_rpClientColorize);
	CreateNative("rp_GetPlayerZone",	Native_rp_GetPlayerZone);
	CreateNative("rp_GetZoneBit",		Native_rp_GetZoneBit);
	CreateNative("rp_SetZoneBit",		Native_rp_SetZoneBit);
	
	CreateNative("rp_IsInPVP",			Native_rp_IsInPVP);
	CreateNative("rp_IsBuildingAllowed", Native_rp_IsBuildingAllowed);
	
	CreateNative("rp_SetWeaponFireRate",		Native_rp_SetWeaponFireRate);
	CreateNative("rp_GetWeaponFireRate",		Native_rp_GetWeaponFireRate);
	
	CreateNative("rp_GetWeaponGroupID",		Native_rp_GetWeaponGroupID);
	CreateNative("rp_SetWeaponGroupID",		Native_rp_SetWeaponGroupID);
	
	CreateNative("rp_SetWeaponBallType",	Native_rp_SetWeaponBallType);
	CreateNative("rp_GetWeaponBallType",	Native_rp_GetWeaponBallType);
	CreateNative("rp_SetClientKnifeType",	Native_rp_SetClientKnifeType);
	CreateNative("rp_GetClientKnifeType",	Native_rp_GetClientKnifeType);
	
	CreateNative("rp_GetClientGroupID",		Native_rp_GetClientGroupID);
	CreateNative("rp_GetClientJobID",		Native_rp_GetClientJobID);
	CreateNative("rp_GetClientItem", Native_rp_GetclientItem);
	
	CreateNative("rp_GetPlayerZoneAppart", Native_rp_GetPlayerZoneAppart);
	
	CreateNative("rp_GetRandomCapital", Native_rp_GetRandomCapital);
	CreateNative("rp_Effect_Push", 	Native_rp_MakeRadiusPush);
	
	CreateNative("rp_GetItemData", 		Native_rp_GetItemData);
	CreateNative("rp_GetJobData", 		Native_rp_GetJobData);
	CreateNative("rp_GetGroupData", 		Native_rp_GetGroupData);
	
	CreateNative("rp_GetZoneData", 		Native_rp_GetZoneData);
	CreateNative("rp_GetLocationData", 		Native_rp_GetLocationData);
	
	CreateNative("rp_ClientReveal", Native_rp_ClientReveal);
	
	CreateNative("rp_IsClientLucky", 	Native_rp_IsClientLucky);
	CreateNative("rp_IncrementLuck", 	Native_rp_IsClientLucky);

	CreateNative("rp_AddSaveSlot", 	Native_rp_AddSaveSlot);
	
	CreateNative("rp_GetJobCapital", Native_rp_GetJobCapital);
	CreateNative("rp_SetJobCapital", Native_rp_SetJobCapital);
	CreateNative("rp_GetClientPvPBonus", Native_rp_GotPvPvPBonus);
	CreateNative("rp_ScheduleEntityInput", Native_rp_ScheduleEntityInput);
	
	
	CreateNative("rp_GetDatabase", Native_rp_GetDatabase);
	CreateNative("rp_CreateSellingMenu", Native_CreateSellingMenu);
	
	CreateNative("rp_SetBuildingData", Native_SetBuildingData);
	CreateNative("rp_GetBuildingData", Native_GetBuildingData);
	
	CreateNative("rp_ClientSendToSpawn", Native_rp_ClientSendToSpawn);
	
	CreateNative("rp_IsValidVehicle", Native_rp_IsValidVehicle);
	CreateNative("rp_GetVehicleInt", Native_rp_GetVehicleInt);
	CreateNative("rp_SetVehicleInt", Native_rp_SetVehicleInt);
	CreateNative("rp_SetClientKeyVehicle", Native_rp_SetKeyCar);
	CreateNative("rp_GetClientKeyVehicle", Native_rp_GetKeyCar);
	CreateNative("rp_GetClientVehiclePassager", Native_rp_GetClientVehiclePassager);
	CreateNative("rp_SetClientVehiclePassager", Native_rp_SetClientVehiclePassager);
	
	CreateNative("rp_ClientVehicleExit", Native_rp_ClientVehicleExit);
	CreateNative("rp_ClientVehiclePassagerExit", Native_rp_ClientVehiclePassagerExit);
	
	CreateNative("rp_ClientGiveHands", Native_rp_ClientGiveHands);
	CreateNative("rp_SetClientVehicle", Native_rp_SetClientVehicle);
	
	CreateNative("rp_GetWeaponStorage", Native_rp_GetWeaponStorage);
	CreateNative("rp_SetWeaponStorage", Native_rp_SetWeaponStorage);
	
	CreateNative("rp_IsNight", Native_IsNight);
	CreateNative("rp_IsValidDoor", Native_rp_IsValidDoor);
	CreateNative("rp_GetDoorID", Native_rp_GetDoorID);
	CreateNative("rp_SetDoorLock", Native_rp_SetDoorLock);
	CreateNative("rp_GetClientKeyDoor", Native_rp_GetClientKeyDoor);
	CreateNative("rp_ClientOpenDoor", Native_rp_SetDoorOpen);
	CreateNative("rp_ClientDrawWeaponMenu", Native_rp_ClientDrawWeaponMenu);
	
	CreateNative("rp_SetAppartementInt", Native_rp_SetAppartementInt);
	CreateNative("rp_GetAppartementInt", Native_rp_GetAppartementInt);
	CreateNative("rp_SetClientKeyAppartement", Native_rp_SetClientKeyAppartement );
	CreateNative("rp_GetClientKeyAppartement", Native_rp_GetClientKeyAppartement );
	CreateNative("rp_Effect_PropExplode", Native_rp_Effect_PropExplode);
	
	CreateNative("rp_ClientResetSkin", Native_rp_ClientResetSkin);
	CreateNative("rp_CreateGrenade", Native_rp_CreateGrenade);
	CreateNative("rp_IsGrabbed", Native_rp_IsGrabbed);
	CreateNative("rp_ClientForceRelease", Native_GrabRelease);
	
	CreateNative("rp_GetDate", Native_rp_GetDate);
	CreateNative("rp_GetTime", Native_rp_GetTime);
	
	CreateNative("rp_RegisterQuest", Native_rp_RegisterQuest);
	CreateNative("rp_QuestAddStep", Native_rp_QuestAddStep);
	CreateNative("rp_QuestStepComplete", Native_rp_QuestStepComplete);
	CreateNative("rp_QuestStepFail", Native_rp_QuestStepFail);
	CreateNative("rp_QuestCreateInstance", Native_rp_QuestCreateInstance);
	CreateNative("rp_QuestComplete", Native_rp_QuestComplete);
	
	CreateNative("rp_GetServerString", Native_rp_GetServerString);
	CreateNative("rp_SetServerString", Native_rp_SetServerString);
	CreateNative("rp_GetServerRules", Native_rp_GetServerRules);
	CreateNative("rp_SetServerRules", Native_rp_SetServerRules);
	CreateNative("rp_StoreServerRules", Native_rp_StoreServerRules);
	
	CreateNative("rp_ClientCanDrawPanel", Native_rp_ClientCanDrawPanel);
	CreateNative("rp_SendPanelToClient", Native_rp_SendPanelToClient);
	CreateNative("rp_GetZoneFromPoint", Native_rp_GetZoneFromPoint);
	
	CreateNative("rp_GetEntityCount", Native_RP_GetEntityCount);
	CreateNative("rp_GetCaptureInt", Native_rp_GetCaptureInt);
	CreateNative("rp_SetCaptureInt", Native_rp_SetCaptureInt);
	
	CreateNative("rp_Effect_LoadingBar", Native_rp_GetLoadingBar);
	
	CreateNative("rp_GetClientTarget", Native_GetClientTarget);

	CreateNative("rp_ClientAggroIncrement", Native_rp_ClientAgroIncrement);
	CreateNative("rp_ClientCanAttack", Native_rp_ClientCanAttack);
	CreateNative("rp_ClientFloodIncrement", Native_rp_ClientFloodIncrement);
	CreateNative("rp_ClientXPIncrement", Native_rp_ClientXPIncrement);
	
	
	CreateNative("rp_ClientFloodTriggered", Native_rp_ClientFloodTriggered);
	CreateNative("rp_ClientOverlays", Native_rp_ClientOverlays);
	CreateNative("rp_ClientTeleport", Native_ClientTeleport);
	
	
	CreateNative("rp_WeaponMenu_GetOwner", Native_rp_WeaponMenu_GetOwner);
	CreateNative("rp_WeaponMenu_Create", Native_rp_WeaponMenu_Create);
	CreateNative("rp_WeaponMenu_Clear", Native_rp_WeaponMenu_Clear);
	
	CreateNative("rp_WeaponMenu_Reset", Native_rp_WeaponMenu_Reset);
	CreateNative("rp_WeaponMenu_SetPosition", Native_rp_WeaponMenu_SetPosition);
	CreateNative("rp_WeaponMenu_GetPosition", Native_rp_WeaponMenu_GetPosition);
	CreateNative("rp_WeaponMenu_GetMax", Native_rp_WeaponMenu_GetMax);
	CreateNative("rp_WeaponMenu_Add", Native_rp_WeaponMenu_Add);
	CreateNative("rp_WeaponMenu_Delete", Native_rp_WeaponMenu_Delete);
	CreateNative("rp_WeaponMenu_Get", Native_rp_WeaponMenu_Get);
	CreateNative("rp_WeaponMenu_Give", Native_rp_WeaponMenu_Give);
	
	CreateNative("rp_GetForwardHandle", Native_GetForwardHandle);
	CreateNative("rp_GetClientNextMessage", Native_rp_GetClientNextMessage);
	
	CreateNative("rp_GetLevelData",	Native_rp_GetLevelData);
	
	RegPluginLibrary("roleplay");
	
	return APLRes_Success;
}
public int Native_rp_GetLevelData(Handle plugin, int numParams) {
	SetNativeString(3, g_szLevelList[GetNativeCell(1)][GetNativeCell(2)], GetNativeCell(4));
}
public int Native_rp_ClientCanAttack(Handle plugin, int numParams) {
	return Client_CanAttack(GetNativeCell(1), GetNativeCell(2));
}
public int Native_rp_ClientMoney(Handle plugin, int numParams) {
	int client = GetNativeCell(1);
	int type = GetNativeCell(2);
	int amount = GetNativeCell(3);
	bool unsafe = view_as<bool>(GetNativeCell(4));

	if(amount > 1000000 || amount < -1000000){
		if(!unsafe){
			LogToGame("[CHEATING] [CLIENT-MONEY] %L aurait du recevoir %d.", client, amount);
			LogStackTrace("[CHEATING] [CLIENT-MONEY] %L aurait du recevoir %d.", client, amount);
			CPrintToChat(client, "%T", "Error_FromServer", client);
			return 0;
		}
	}
	
	int dette = g_iUserData[client][i_Dette];
	if( dette > 0 && amount > 0 ) {
		
		if( amount > 10 )
			CPrintToChat(client, "" ...MOD_TAG... " %T", "Ban_Refund", client, (amount < dette ? amount : dette), dette);
		
		dette -= amount;
		if (dette < 0) {
			amount = -dette;
			dette = 0;
		}
		else
			amount = 0;
		
		g_iUserData[client][i_Dette] = dette;
	}
	
	int give = g_iUserData[client][type] + amount;
	g_iUserData[client][type] = give;
	
	if( give < 0 ) {
		g_iUserData[client][type] = 0;
		
		int money = g_iUserData[client][i_Money];
		int bank = g_iUserData[client][i_Bank];
		int pay = g_iUserData[client][i_AddToPay];
		dette = g_iUserData[client][i_Dette];
		
		money += give;
		if( money < 0 ) {
			give = money;
			money = 0;
		}
		else
			give = 0;
		
		pay += give;
		if( pay < 0 ) {	
			give = pay;	
			pay = 0;
		}
		else
			give = 0;
		
		bank += give;
		if( bank < 0 ) {
			give = bank;
			bank = 0;
		}
		else
			give = 0;
		
		if( give < 0 ) {
			dette -= give;
			give = 0;
		}
		
		g_iUserData[client][i_Money] = money;
		g_iUserData[client][i_Bank] = bank;
		g_iUserData[client][i_AddToPay] = pay;
		g_iUserData[client][i_Dette] = dette;
	}
	
	return 1;
}
public int Native_GrabRelease(Handle plugin, int numParams) {
	int client = GetNativeCell(1);
	FORCE_STOP(client);
	FORCE_Release(client);
}
void TeleportClient(int client, float vecOrigin[3], float angle[3], float vel[3]) {
	static float MinHull[3] = { -16.0, -16.0,  0.0 };
	static float g_size[][3] = {
		{0.0, 0.0, 1.0}, {0.0, 1.0, 0.0}, {0.0, -1.0, 0.0}, {1.0, 0.0, 0.0}, {-1.0, 0.0, 0.0}, {-1.0, 1.0, 1.0}, {1.0, 1.0, 1.0}, {1.0, -1.0, 1.0}, {-1.0, -1.0, 1.0},
		{0.0, 0.0, 2.0}, {0.0, 2.0, 0.0}, {0.0, -2.0, 0.0}, {2.0, 0.0, 0.0}, {-2.0, 0.0, 0.0}, {-2.0, 2.0, 2.0}, {2.0, 2.0, 2.0}, {2.0, -2.0, 2.0}, {-2.0, -2.0, 2.0},
		{0.0, 0.0, 3.0}, {0.0, 3.0, 0.0}, {0.0, -3.0, 0.0}, {3.0, 0.0, 0.0}, {-3.0, 0.0, 0.0}, {-3.0, 3.0, 3.0}, {3.0, 3.0, 3.0}, {3.0, -3.0, 3.0}, {-3.0, -3.0, 3.0},
		{0.0, 0.0, 4.0}, {0.0, 4.0, 0.0}, {0.0, -4.0, 0.0}, {4.0, 0.0, 0.0}, {-4.0, 0.0, 0.0}, {-4.0, 4.0, 4.0}, {4.0, 4.0, 4.0}, {4.0, -4.0, 4.0}, {-4.0, -4.0, 4.0},
		{0.0, 0.0, 5.0}, {0.0, 5.0, 0.0}, {0.0, -5.0, 0.0}, {5.0, 0.0, 0.0}, {-5.0, 0.0, 0.0}, {-5.0, 5.0, 5.0}, {5.0, 5.0, 5.0}, {5.0, -5.0, 5.0}, {-5.0, -5.0, 5.0}
	};
	static float vec[3], vecTarget[3];
	
	if( !IsPlayerAlive(client) )
		return;
	
	for(int i=1; i<=MaxClients; i++) {
		if( i == client || !IsValidClient(i) || !IsPlayerAlive(i) )
			continue;
		
		GetClientAbsOrigin(i, vecTarget);
		if( GetVectorDistance(vecTarget, vecOrigin) > 128.0 )
			continue;
		
		if( GetVectorDistance(vecTarget, vecOrigin) > 24.0 ) {
			GetClientAbsOrigin(i, vecTarget);
			if( FloatAbs(vecTarget[2]-vecOrigin[2]) <= 72.0 ) {
				vecTarget[2] = vecOrigin[2];
				if( GetVectorDistance(vecOrigin, vecTarget) > 32.0 )
					continue;
			}
			else {
				continue;
			}
		}
		
		if( rp_GetClientBool(i, b_IsAFK) ) {
			SDKHooks_TakeDamage(i, i, i, 10000.0);
			continue;
		}
		
		for(int j=0; j<sizeof(g_size); j++) {
			vec[0] = vecOrigin[0] - (MinHull[0] * g_size[j][0] * 2.1);
			vec[1] = vecOrigin[1] - (MinHull[1] * g_size[j][1] * 2.1);
			vec[2] = vecOrigin[2] - (MinHull[2] * g_size[j][2] * 2.1);
			
			if( isHullVacant(vec, client) ) {
				vecOrigin = vec;
				break;
			}
		}
		break;
	}
	
	TeleportEntity(client, vecOrigin, angle, vel);
}
bool isHullVacant(const float origin[3], int target) {
	static float MinHull[3] = { -16.0, -16.0,  0.0 };
	static float MaxHull[3] = {  16.0,  16.0, 72.0 };
	
	Handle tr = TR_TraceHullFilterEx(origin, origin, MinHull, MaxHull, MASK_PLAYERSOLID, TraceRayDontHitSelf, target);
	if( TR_DidHit(tr) ) {
		CloseHandle(tr);
		return false;
	}
	CloseHandle(tr);
	return true;
}
public int Native_ClientTeleport(Handle plugin, int numParams) {
	float dst[3];
	GetNativeArray(2, dst, sizeof(dst));
	
	TeleportClient(GetNativeCell(1), dst, NULL_VECTOR, NULL_VECTOR);
}
public int Native_rp_ClientUpdateBank(Handle plugin, int numParams) {
	updateBankCost(GetNativeCell(1));
}
public int Native_rp_Effect_Cashflow(Handle plugin, int numParams) {
	int client = GetNativeCell(1);
	int amount = GetNativeCell(2);
	
	if( amount <= 10 ) {
		g_iUserData[client][i_LastVolCashFlowTime] = GetTime() + amount;
		ServerCommand("sm_effect_particles %d trail_money %d knife", client, amount);
	}
	else {
		g_iUserData[client][i_LastVolCashFlowTime] = GetTime() + RoundToFloor(10.0 + (amount / 100.0));
		
		for (int i = 0; i <= amount; i+=100) {
			g_iParentedParticle[client].Push(CreateTimer( i / 100.0, CashFlow_TASK, client));
			rp_HookEvent(client, RP_OnPlayerDead, fwdPlayerDead);
			rp_HookEvent(client, RP_PostClientSendToJail, fwdPlayerJail);
		}
	}
}
public Action CashFlow_TASK(Handle timer, any client) {
	if( timer && IsValidHandle(timer) ) {
		ServerCommand("sm_effect_particles %d trail_money 10 knife", client);
	}
}
public Action fwdPlayerJail(int client, int attacker) {
	Handle timer;
	for (int i = 0; i < g_iParentedParticle[client].Length; i++) {
		timer = view_as<Handle>(g_iParentedParticle[client].Get(i));
		if( timer && IsValidHandle(timer) ) {
			delete timer;
		}
	}
	g_iParentedParticle[client].Clear();
	rp_UnhookEvent(client, RP_OnPlayerDead, fwdPlayerDead);
	rp_UnhookEvent(client, RP_PostClientSendToJail, fwdPlayerDead);
}
public Action fwdPlayerDead(int client, int attacker, float& respawn, int& tdm, float& ctx) {
	Handle timer;
	for (int i = 0; i < g_iParentedParticle[client].Length; i++) {
		timer = view_as<Handle>(g_iParentedParticle[client].Get(i));
		if( timer && IsValidHandle(timer) ) {
			delete timer;
		}
	}
	g_iParentedParticle[client].Clear();
	g_iUserData[client][i_LastVolCashFlowTime] = 0;
	rp_UnhookEvent(client, RP_OnPlayerDead, fwdPlayerDead);
	rp_UnhookEvent(client, RP_PostClientSendToJail, fwdPlayerDead);
}

public int Native_rp_GetServerRules(Handle plugin, int numParams) {
	return g_iServerRules[GetNativeCell(1)][GetNativeCell(2)];
}
public int Native_rp_SetServerRules(Handle plugin, int numParams) {
	g_iServerRules[GetNativeCell(1)][GetNativeCell(2)] = GetNativeCell(3);
}
public int Native_rp_StoreServerRules(Handle plugin, int numParams) {
	storeServerRules();
	return 1;
}
public int Native_rp_ClientGetName(Handle plugin, int numParams) {
	int client = GetNativeCell(1);
	int length = GetNativeCell(2);
	char[] data = new char[length];
	
	if( g_iUserData[client][i_BirthDay] > 0 )
		Format(data, length, "%s, %s", g_szUserData[client][sz_FirstName], g_szUserData[client][sz_LastName]);
	else
		GetClientName2(client, data, length, true);
}
public int Native_rp_GetClientDouble(Handle plugin, int numParams) {
	return view_as<int>(g_iDoubleCompte[GetNativeCell(1)]);
}
public int Native_rp_GetClientNextMessage(Handle plugin, int numParams) {
	int client = GetNativeCell(1);
	
	DataPack dp = new DataPack();
	dp.WriteCell(GetNativeCell(2));
	dp.WriteFunction(GetNativeFunction(3));
	dp.WriteCell(plugin);
	
	g_iChatData[client].Push(dp);
}

public int Native_GetForwardHandle(Handle plugin, int numParams) {
	return view_as<int>(g_hRPNative[GetNativeCell(1)][GetNativeCell(2)]);
}
public int Native_rp_GetClientSSO(Handle plugin, int numParams) {
	char tmp[256];
	SSO_Forum(GetNativeCell(1), tmp, sizeof(tmp));
	SetNativeString(2, tmp, GetNativeCell(3));
}
public int Native_rp_ClientXPIncrement(Handle plugin, int numParams) {
	char tmp[128];
	int client = view_as<int>(GetNativeCell(1));
	int xp = view_as<int>(GetNativeCell(2));
	bool verbose = view_as<bool>(GetNativeCell(3));
	
	if( !IsTutorialOver(client) )
		return 0;
	if( g_iUserData[client][i_PlayerLVL] >= 1000 ) {
		g_iUserData[client][i_PlayerLVL] = 1000;
		return 0;
	}
	
	if( g_iUserData[client][i_Job] > 0 && GetJobPrimaryID(client) == g_iUserData[client][i_Job] && g_iUserData[client][i_TimePlayedJob] >= (60*60*100) ) {
		float factor = (float(g_iUserData[client][i_TimePlayedJob]) / (60.0 * 60.0 * 1000.0));
		xp += RoundFloat( float(xp) * factor);
	}
#if defined EVENT_BIRTHDAY
	xp = xp * 2;
#endif

	g_iUserData[client][i_PlayerXP] += xp;

	if( xp >= 100 || verbose )
		CPrintToChat(client, "" ...MOD_TAG... " %T", "LEVEL_XP", client, xp);
	
	while( g_iUserData[client][i_PlayerXP] >= (g_iUserData[client][i_PlayerLVL] * 3600) ) {
		g_iUserData[client][i_PlayerLVL]++;
		
		int a = RoundToFloor(SquareRoot(float(g_iUserData[client][i_PlayerLVL])));
		int b = a * (a + 1);
		if( b >= 992 )
			b = 1000;
		
		if( g_iUserData[client][i_PlayerLVL] == b ) {
			// Nouveau grade?
			g_iUserData[client][i_PlayerRank] = a + 1;
			
			if( b == 702 ) {
				CPrintToChat(client, "" ...MOD_TAG... " %T", "Item_Give", client, 50, g_szItemList[ITEM_CADEAU][item_type_name]);
				rp_ClientGiveItem(client, ITEM_CADEAU, 50);
			}
			if( b == 600 ) {
				CPrintToChat(client, "" ...MOD_TAG... " %T", "Item_Give", client, 25, g_szItemList[ITEM_CADEAU][item_type_name]);
				rp_ClientGiveItem(client, ITEM_CADEAU, 25);
			}
			
			if( !g_bUserData[client][b_IsFirstSpawn] && IsPlayerAlive(client) )
				ServerCommand("sm_effect_particles %d levelup 10", client);
			CPrintToChat(client, "" ...MOD_TAG... " %T", "LEVEL_RANK", client, g_iUserData[client][i_PlayerLVL], g_szLevelList[ g_iUserData[client][i_PlayerRank] ][rank_type_name]);
		}
		else {
			CPrintToChat(client, "" ...MOD_TAG... " %T", "LEVEL_UP", client, g_iUserData[client][i_PlayerLVL]);
		}
	}
	return 1;
}
void updatePlayerRank(int client) {
	int c = 1;
	int d = g_iUserData[client][i_PlayerXP];
	
	while( d >= (c * 3600) ) {
		c++;
		
		int a = RoundToFloor(SquareRoot(float(c)));
		int b = a * (a + 1);
		if( b >= 992 )
			b = 1000;
		
		if( c == b )
			g_iUserData[client][i_PlayerRank] = a + 1;
	}
}
public int Native_rp_ClientAgroIncrement(Handle plugin, int numParams) {
	int client = view_as<int>(GetNativeCell(1));
	int target = view_as<int>(GetNativeCell(2));
	int damage = view_as<int>(GetNativeCell(3));
	int time = GetTime();
	
	if( client == target )
		return 1;
	
	if( IsInPVP(client) && IsInPVP(target) )
		return 1;
	
	if( !IsValidClient(client) ) {
		client = Entity_GetOwner(client);
		if( !IsValidClient(client) )
			return 1;
	}
	if( !IsValidClient(target) ) {
		target = Entity_GetOwner(target);
		if( !IsValidClient(target) )
			return 1;
	}
	
	if( g_iKillLegitime[client][target] > time ) {
		// J'ai attaqué target il y a moins de 30 secondes.
		return 1;
	}
	
	g_iAggro[client][target] += damage;
		
	if( (g_iAggro[client][target]*4) > GetClientHealth(target) && g_iAggroTimer[target][client] <= time ) {
		KillStack_Add(target, client);		
		
		g_iKillLegitime[target][client] = time + LEGIT_KILL_TIME;
		g_iAggroTimer[client][target] = time + LEGIT_KILL_TIME*2;
	}
	
	int tmp[KillStack_max];
	tmp[KillStack_target] = target;
	tmp[KillStack_time] = time + LEGIT_KILL_TIME;
	tmp[KillStack_damage] = damage;
	
	g_hAggro[client].PushArray(tmp, sizeof(tmp));	
	return 1;
}
void ClientAgroDecrement(int client) {
	
	while( g_hAggro[client].Length > 0 ) {
		int tmp[KillStack_max];
		g_hAggro[client].GetArray(0, tmp, sizeof(tmp));	
		
		if( tmp[KillStack_time] < GetTime() ) {
			g_hAggro[client].Erase(0);
			g_iAggro[client][ tmp[KillStack_target] ] -= tmp[KillStack_damage];
		}
		else {
			break;
		}
	}
	
}
public int Native_rp_ClientFloodIncrement(Handle plugin, int numParams) {
	int client = view_as<int>(GetNativeCell(1));
	int target = view_as<int>(GetNativeCell(2));
	int type = view_as<int>(GetNativeCell(3));
	float cd = view_as<float>(GetNativeCell(4));
	
	
	g_iClientFloodValue[client][target][type]++;
	g_flClientFloodTime[client][target][type] = GetTickedTime() + (g_iClientFloodValue[client][target][type] * cd);
	
	if( g_iClientFloodTimer[client][target][type] != null )
		delete g_iClientFloodTimer[client][target][type];
	
	Handle dp;
	g_iClientFloodTimer[client][target][type] = CreateDataTimer(g_iClientFloodValue[client][target][type] * cd * 2.0, ClientFloodDecrement, dp, TIMER_DATA_HNDL_CLOSE);
	WritePackCell(dp, client);
	WritePackCell(dp, target);
	WritePackCell(dp, type);
	WritePackCell(dp, cd);
}
public int Native_rp_ClientFloodTriggered(Handle plugin, int numParams) {
	int client = view_as<int>(GetNativeCell(1));
	int target = view_as<int>(GetNativeCell(2));
	int type = view_as<int>(GetNativeCell(3));
	
	if( g_flClientFloodTime[client][target][type] >= GetTickedTime() ) {
		return view_as<int>(true);
	}
	return view_as<int>(false);
}
public Action ClientFloodDecrement(Handle timer, Handle dp) {
	ResetPack(dp);
	int client = ReadPackCell(dp);
	int target = ReadPackCell(dp);
	int type = ReadPackCell(dp);
	float cd = view_as<float>(ReadPackCell(dp));
	g_iClientFloodTimer[client][target][type] = null;
	
	if( g_iClientFloodValue[client][target][type] >= 1 ) {
		g_iClientFloodValue[client][target][type]--;
		
		if( g_iClientFloodValue[client][target][type] >= 1 ) {
			Handle dp2;
			g_iClientFloodTimer[client][target][type] = CreateDataTimer(cd, ClientFloodDecrement, dp2, TIMER_DATA_HNDL_CLOSE);
			WritePackCell(dp2, client);
			WritePackCell(dp2, target);
			WritePackCell(dp2, type);
			WritePackCell(dp2, cd);
		}
	}
	
	
}
public int Native_rp_GetLoadingBar(Handle plugin, int numParams) {
	int length = view_as<int>(GetNativeCell(2));
	char[] str = new char[length];
	float percent = view_as<float>(GetNativeCell(3));
	int usable = length - GetCharBytes("[") - GetCharBytes("]") - 1;
	usable -= (usable % GetCharBytes("█"));
	char tmp[12];
	int full = RoundToFloor(usable * percent / GetCharBytes("█"));
	float left = (usable * percent / GetCharBytes("█")) - float(full);
	
	if( full > usable )
		full = usable;
	
	for (int i = 0; i < full; i++)
		Format(str, length, "%s█", str);
	
	
	if( full < length ) {
		if( left > 0.75 ) 
			Format(str, length, "%s▓", str);
		else if( left > 0.5 )
			Format(str, length, "%s░", str);
		else if( left > 0.25 )
			Format(str, length, "%s▒", str);
	}
	
	Format(tmp, sizeof(tmp), "[%%%ds]", usable);
	Format(str, length, tmp, str);
	
	SetNativeString(1, str, length);
}
public int Native_rp_SetCaptureInt(Handle plugin, int numParams) {
	g_iCapture[GetNativeCell(1)] = GetNativeCell(2);
}
public int Native_rp_GetCaptureInt(Handle plugin, int numParams) {
	return view_as<int>(g_iCapture[GetNativeCell(1)]);
}
public int Native_rp_IsGrabbed(Handle plugin, int numParams) {
	return view_as<int>(g_iGrabbedBy[GetNativeCell(1)]);
}
public int Native_rp_GetServerString(Handle plugin, int numParams) {
	SetNativeString(2, g_szVillaOwner[GetNativeCell(1)], GetNativeCell(3));
}
public int Native_rp_SetServerString(Handle plugin, int numParams) {
	GetNativeString(2, g_szVillaOwner[GetNativeCell(1)], GetNativeCell(3));
}

public int Native_RP_GetEntityCount(Handle plugin, int numParams) {
	return g_iEntityCount;
}
public int Native_rp_GetZoneFromPoint(Handle plugin, int numParams) {
	float pos[3];
	GetNativeArray(1, pos, sizeof(pos));
	
	return view_as<int>(GetPointZone(pos));
}
public int Native_rp_ClientCanDrawPanel(Handle plugin, int numParams) {
	int client = view_as<int>(GetNativeCell(1));
	bool res = false;
	
	if( GetClientMenu(client) == MenuSource_None || GetClientMenu(client) == MenuSource_RawPanel ) {
		res = true;
	}
	
	return view_as<int>(res);
}
public int Native_rp_CreatePanel(Handle plugin, int numParams) {
	int client = view_as<int>(GetNativeCell(1));
	Handle panel = INVALID_HANDLE;
	
	if( GetClientMenu(client) == MenuSource_None || GetClientMenu(client) == MenuSource_RawPanel ) {
		panel = CreatePanel();
	}
	
	return view_as<int>(panel);
}
public int Native_rp_SendPanelToClient(Handle plugin, int numParams) {
	Handle panel = view_as<Handle>( GetNativeCellRef(1) );
	int client = view_as<int>(GetNativeCell(2));
	float time = view_as<float>(GetNativeCell(3));
	
	SendPanelToClient(panel, client, MenuNothing, RoundToCeil(time));
	return 1;
}
public int Native_rp_GetDate(Handle plugin, int numParams) {
	char tmp[64];
	PrintHours(tmp, sizeof(tmp));
	SetNativeString(1, tmp, GetNativeCell(2));
}
public int Native_rp_GetTime(Handle plugin, int numParams) {
	SetNativeCellRef(1, g_iHours);
	SetNativeCellRef(2, g_iMinutes);
}
public int Native_rp_GetClientKeyDoor(Handle plugin, int numParams) {
	return view_as<int>(IsPlayerHaveKey(GetNativeCell(1), GetNativeCell(2)+MaxClients));
}
public int Native_rp_CreateGrenade(Handle plugin, int numParams ) {
	char name[64], model[128];
	
	int client = view_as<int>(GetNativeCell(1));
	GetNativeString(2, name, sizeof(name));
	GetNativeString(3, model, sizeof(model));
	Function fct1 = GetNativeFunction(4);
	Function fct2 = GetNativeFunction(5);
	float duration = view_as<float>(GetNativeCell(6));
	
	int ent = CTF_NADE_BASE(client, name);
	SetEntityModel(ent, model);
	
	Call_StartFunction(plugin, fct1);
	Call_PushCell(client);
	Call_PushCell(ent);
	Call_Finish();
	
	Handle dp;
	CreateDataTimer(duration, Native_rp_CreateGrenade_Explode, dp, TIMER_DATA_HNDL_CLOSE);
	WritePackCell(dp, plugin);
	WritePackCell(dp, client);
	WritePackCell(dp, ent);
	WritePackFunction(dp, fct2);
	
	rp_ScheduleEntityInput(ent, duration + 31.0, "Kill");
	return ent;
}
public Action Native_rp_CreateGrenade_Explode(Handle timer, Handle dp) {
	
	ResetPack(dp);
	
	Handle plugin = view_as<Handle>(ReadPackCell(dp));
	int client = view_as<int>(ReadPackCell(dp));
	int ent = view_as<int>(ReadPackCell(dp));
	Function fct = ReadPackFunction(dp);
	
	if( rp_GetZoneBit(rp_GetPlayerZone(ent)) & BITZONE_PEACEFULL ) {
		rp_AcceptEntityInput(ent, "Kill");
		return;
	}
	
	Call_StartFunction(plugin, fct);
	Call_PushCell(client);
	Call_PushCell(ent);
	Call_Finish();
}
public int Native_rp_ClientResetSkin(Handle plugin, int numParams ) {
	SetPersonalSkin(GetNativeCell(1));
}
public int Native_rp_Effect_PropExplode(Handle plugin, int numParams) {

	
	int ent = GetNativeCell(1);
	int attacker = GetNativeCell(2);
	bool tazer = view_as<bool>(GetNativeCell(3));
	
	if( rp_GetBuildingData(ent, BD_Trapped) == 0 )
		return;
	if( rp_GetBuildingData(ent, BD_owner) == attacker )
		return;
	if( rp_IsValidDoor(ent) && rp_GetClientKeyDoor(attacker, rp_GetDoorID(ent)) )
		return;
	if( rp_GetClientBool(attacker, b_GameModePassive) && rp_ClientCanAttack(rp_GetBuildingData(ent, BD_Trapped), attacker) == false )
		return;
	
	float vecOrigin[3], min[3], max[3];
	Entity_GetAbsOrigin(ent, vecOrigin);
	Entity_GetMinSize(ent, min);
	Entity_GetMaxSize(ent, max);
	vecOrigin[0] += (min[0] + max[0]) / 2.0;
	vecOrigin[1] += (min[1] + max[1]) / 2.0;
	vecOrigin[2] += (min[2] + max[2]) / 2.0;
	
	float dmg = 300.0 * (tazer ? 4.0 : 1.0);
	
	ExplosionDamage(vecOrigin, dmg, 256.0, rp_GetBuildingData(ent, BD_Trapped), ent, "rp_trap");
	rp_SetBuildingData(ent, BD_Trapped, 0);
	
	TE_SetupExplosion(vecOrigin, g_cExplode, 1.0, 0, 0, 200, 200);
	TE_SendToAll();
	
	SDKHooks_TakeDamage(ent, ent, attacker, dmg);
}
public int Native_rp_SetClientKeyAppartement(Handle plugin, int numParams ) {
	g_iDoorOwner_v2[GetNativeCell(1)][GetNativeCell(2)] = GetNativeCell(3);
	return 1;
}
public int Native_rp_GetClientKeyAppartement(Handle plugin, int numParams ) {
	return g_iDoorOwner_v2[GetNativeCell(1)][GetNativeCell(2)];
}
public int Native_rp_SetAppartementInt(Handle plugin, int numParams) {
	g_iAppartBonus[GetNativeCell(1)][GetNativeCell(2)] = GetNativeCell(3);
	return 1;
}
public int Native_rp_GetAppartementInt(Handle plugin, int numParams) {
	return g_iAppartBonus[GetNativeCell(1)][GetNativeCell(2)];
}
public int Native_rp_ClientDrawWeaponMenu(Handle plugin, int numParams) {
	SelectingAmmunition(GetNativeCell(1), GetNativeCell(2), GetNativeCell(3));
	return 1;
}
public int Native_rp_SetDoorOpen(Handle plugin, int numParams) {
	
	int client = GetNativeCell(1);
	int door_bdd = GetNativeCell(2);
	int door = (door_bdd + MaxClients);
	bool status = view_as<bool>(GetNativeCell(3));
	
	if( status )
		rp_AcceptEntityInput(door, "Open", client);
	else
		rp_AcceptEntityInput(door, "Close", client);
	
	door_bdd = g_iDoorDouble[door_bdd];
	
	if( door_bdd > 0 ) {
		door = (door_bdd + MaxClients);
		
		if( status )
			rp_AcceptEntityInput(door, "Open", client);
		else
			rp_AcceptEntityInput(door, "Close", client);
	}
	
	
	return 1;
}
public int Native_rp_SetDoorLock(Handle plugin, int numParams) {
	LockSomeDoor(GetNativeCell(1), GetNativeCell(2));
	return 1;
}
public int Native_rp_GetDoorID(Handle plugin, int numParams) {
	int door_bdd = (GetNativeCell(1)-MaxClients);
	if( g_iDoorDouble[door_bdd] < door_bdd && g_iDoorDouble[door_bdd] != 0 ) {
		door_bdd = g_iDoorDouble[door_bdd];
	}
	return door_bdd;
}
public int Native_rp_IsValidDoor(Handle plugin, int numParams) {
	return IsValidDoor(GetNativeCell(1));
}
public int Native_IsNight(Handle plugin, int numParams) {
	return IsNight();
}
public int Native_rp_ClientReveal(Handle plugin, int numParams) {
	int client = GetNativeCell(1);
	
	if( rp_GetClientBool(client, b_Invisible) ) {
		CopSetVisible(client);
	}
	
	return 1;
}
public int Native_rp_SetWeaponStorage(Handle plugin, int numParams) {
	g_iWeaponFromStore[GetNativeCell(1)] = view_as<int>(GetNativeCell(2));
	return 1;
}
public int Native_rp_GetWeaponStorage(Handle plugin, int numParams) {
	return g_iWeaponFromStore[GetNativeCell(1)];
}
public int Native_rp_IsClientNew(Handle plugin, int numParams) {
	int client = GetNativeCell(1);
	if( IsFakeClient(client) )
		return view_as<int>(false);
	return (g_iClient_OLD[client]!=1);
}
public int Native_rp_ClientVehiclePassagerExit(Handle plugin, int numParams) {
	LeaveVehiclePassager(GetNativeCell(1), GetNativeCell(2) );
	return 1;
}
public int Native_rp_SetClientVehicle(Handle plugin, int numParams) {
	rp__SetClientVehicle(GetNativeCell(1), GetNativeCell(2), GetNativeCell(3));
}
public int Native_rp_ClientGiveHands(Handle plugin, int numParams) {
	int client = GetNativeCell(1);
	
	Client_RemoveWeapon(client, "weapon_fists");
	
	int tmp = GivePlayerItem(client, "weapon_fists");
	EquipPlayerWeapon(client, tmp);
	FakeClientCommand(client, "use weapon_fists");
	
}
public int Native_rp_ClientVehicleExit(Handle plugin, int numParams ) {
	int client = GetNativeCell(1);
	int vehicle = GetNativeCell(2);
	
	int driver = GetEntPropEnt(vehicle, Prop_Send, "m_hPlayer");
	
	LogToGame("[DEBUG] [VEHICLE] %L left %d car of %L", client, vehicle, driver);
	
	if( client == driver ) {
		ExitVehicle(client, vehicle, view_as<bool>(GetNativeCell(3)) );
	}
	else if( g_iCarPassager[vehicle][client] ) {
		LeaveVehiclePassager(client, vehicle);
	}
	
	return 1;
}
public int Native_rp_SetClientVehiclePassager(Handle plugin, int numParams ) {
	
	int client = GetNativeCell(1);
	int car = GetNativeCell(2);
	
	int offset = GetNativeCell(3);
	int version = GetNativeCell(4);
	
	bool found = offset != 0;
	char tmp[32], model[128];
	
	while( !found && offset < g_iVehicleData[car][car_maxPassager] ) {
		offset++;
		Format(tmp, sizeof(tmp), "vehicle_feet_passenger%d", offset);
		
		if( LookupAttachment(car, tmp) == -1 )
			continue;
		if( g_iCarPassager1[car][offset] > 0 )
			continue;
		
		found = true;
	}
	
	if( !found )
		return view_as<int>(false);
	

	g_iCarPassager1[car][offset] = client;
	g_iCarPassager2[client] = car;
	Format(tmp, sizeof(tmp), "vehicle_feet_passenger%d", offset);
	
	int ent = CreateEntityByName("prop_dynamic");	
	if( version == 2 )
		Format(model, sizeof(model), "models/props/crates/csgo_drop_crate_spectrum_v8.mdl");
	else
		Format(model, sizeof(model), "models/natalya/vehicles/csgo_car_seat_00.mdl");

	DispatchKeyValue(ent, "model", model);				
	SetEntityModel(ent, model);
	DispatchKeyValue(ent, "solid", "0");
	
	if( LookupAttachment(client, "legacy_weapon_bone") <= 0 ) {
		Entity_SetModel(client, "models/player/custom_player/legacy/tm_phoenix.mdl");
	}
	
	rp_ClientGiveHands(client);
	
	SetVariantString("!activator");
	rp_AcceptEntityInput(ent, "SetParent", car, car);
	SetVariantString(tmp);
	rp_AcceptEntityInput(ent, "SetParentAttachmentMaintainOffset");
	float vecOrigin[3];
	Entity_GetAbsOrigin(car, vecOrigin);
	
	TeleportEntity(ent, view_as<float>({ 0.0, 0.0, -8.0 }), view_as<float>({ 0.0, -90.0, 0.0 }), NULL_VECTOR);
	TeleportEntity(client, vecOrigin, NULL_VECTOR, view_as<float>({ 0.0, 0.0, 0.0 }));
	
	SetVariantString("!activator");
	rp_AcceptEntityInput(client, "SetParent", ent, ent);
	
	int iFlags = GetEntProp(client, Prop_Send, "m_fEffects");
	SetEntProp(client, Prop_Send, "m_fEffects", iFlags | EF_BONEMERGE | EF_NOSHADOW | EF_NOINTERP | EF_BONEMERGE_FASTCULL | EF_PARENT_ANIMATES );
//	SetEntProp(client, Prop_Send, "m_fEffects", iFlags | EF_BONEMERGE | EF_NOSHADOW | EF_NOINTERP);
	SetEntProp(client, Prop_Send, "m_CollisionGroup", COLLISION_GROUP_NONE);
	SetEntityMoveType(client, MOVETYPE_NONE);
	
	int hud = GetEntProp(client, Prop_Send, "m_iHideHUD");
	hud |= HIDEHUD_WEAPONSELECTION|HIDEHUD_INVEHICLE;
	SetEntProp(client, Prop_Send, "m_iHideHUD", hud);
	
	ClientCommand(client, "cam_idealpitch 65");	
	ClientCommand(client, "thirdperson");
	
	g_iCarPassager[GetNativeCell(2)][GetNativeCell(1)] = ent;
	
	LogToGame("[DEBUG] [VEHICLE] %L passager of %d", client, car);
	
	return view_as<int>(true);
}
public int Native_rp_GetClientVehiclePassager(Handle plugin, int numParams ) {
	return g_iCarPassager2[GetNativeCell(1)];
}
public int Native_rp_SetKeyCar(Handle plugin, int numParams ) {
	bool val = view_as<bool>(GetNativeCell(3));
	
	if( val )
		g_iCar_Key[GetNativeCell(1)][GetNativeCell(2)] = 1;
	else
		g_iCar_Key[GetNativeCell(1)][GetNativeCell(2)] = 0;
		
	return 1;
}
public int Native_rp_GetKeyCar(Handle plugin, int numParams ) {
	if( g_iVehicleData[GetNativeCell(2)][car_owner] == 0 )
		return true;	
	return g_iCar_Key[GetNativeCell(1)][GetNativeCell(2)];
}
public int Native_rp_GetVehicleInt(Handle plugin, int numParams ) {
	return g_iVehicleData[GetNativeCell(1)][GetNativeCell(2)];
}
public int Native_rp_SetVehicleInt(Handle plugin, int numParams ) {
	g_iVehicleData[GetNativeCell(1)][GetNativeCell(2)] = GetNativeCell(3);
	return 1;
}
public int Native_rp_IsValidVehicle(Handle plugin, int numParams) {
	return view_as<int>(IsValidVehicle(GetNativeCell(1)));
}
public int Native_rp_IsTargetHear(Handle plugin, int numParams) {
	return view_as<int>(_Entity_GetDistance(GetNativeCell(1), GetNativeCell(2)) <= MAX_AREA_DIST);
}
public int Native_rp_IsTargetSeen(Handle plugin, int numParams) {
	return view_as<int>(ClientViews(GetNativeCell(1), GetNativeCell(2)));
}
public int Native_rp_ClientSendToSpawn(Handle plugin, int numParams) {
	SendPlayerToSpawn(GetNativeCell(1), view_as<bool>(GetNativeCell(2)));
	return 1;
}
public int Native_CreateSellingMenu(Handle plugin, int numParams) {
	return view_as<int>(CreateMenu(eventGiveMenu_2Bis));
}
public int Native_rp_Effect_BeamBox(Handle plugin, int numParams) {
	float origin[3];
	GetNativeArray(3, origin, sizeof(origin));
	
	TargetBeamBox(GetNativeCell(1), GetNativeCell(2), origin, GetNativeCell(4), GetNativeCell(5), GetNativeCell(6));
	return 1;
}
public int Native_rp_Effect_SpawnMoney(Handle plugin, int numParams) {
	float origin[3];
	GetNativeArray(1, origin, sizeof(origin));
	return SpawnMoney(origin, view_as<bool>(GetNativeCell(2)), view_as<bool>(GetNativeCell(3)));
}
public int Native_rp_Effect_Explode(Handle plugin, int numParams) {
	float origin[3];
	char weapon[32];
	GetNativeArray(1, origin, sizeof(origin));
	GetNativeString(5, weapon, sizeof(weapon));
	
	return ExplosionDamage(origin, view_as<float>(GetNativeCell(2)), view_as<float>(GetNativeCell(3)), GetNativeCell(4), 0, weapon);
}
public int Native_rp_GotPvPvPBonus(Handle plugin, int numParams) {
	return GotPvPvPBonus(GetNativeCell(1), GetNativeCell(2));
}
public int Native_SetBuildingData(Handle plugin, int numParams) {
	g_flEntityData[GetNativeCell(1)][GetNativeCell(2)] = view_as<float>(GetNativeCell(3));
	return 1;
}
public int Native_GetBuildingData(Handle plugin, int numParams) {
	return view_as<int>(g_flEntityData[GetNativeCell(1)][GetNativeCell(2)]);
}
public int Native_rp_GetRandomCapital(Handle plugin, int numParams) {
	int capit = GetNativeCell(1);
	int order = GetNativeCell(2);
	if(order < 0 || order > 1) {
		order = 0;
	}

	int capital_id, capitalList[MAX_JOBS][2], min = 0, rnd;
	for(int i=1; i<MAX_JOBS; i++) {
		if( !StrEqual(g_szJobList[i][job_type_isboss], "1" ) )
			continue;
		if( StrEqual(g_szJobList[i][job_type_current], "0" ) )
			continue;
		if( GetJobCapital(i) < 5000 )
			continue;
		if( capit == i )
			continue;
			
		capitalList[min][0] = GetJobCapital(i);
		capitalList[min][1] = i;	
		min++;
	}
		
		
	rnd = Math_GetRandomPow(1, min) - 1;

	if(order == 0) {
		SortCustom2D(capitalList, min, SortMachineItemsH2L);
	} else {
		SortCustom2D(capitalList, min, SortMachineItemsL2H);
	}

	capital_id = capitalList[rnd][1];
	
	if( capital_id == 0 || capital_id < 0 || capital_id > 221 ) {
		do {
			capital_id = Math_GetRandomInt(1, 23);
			capital_id = (capital_id * 10)-9;
		}
		while(
			capital_id == 141 ||
			capit == capital_id ||
			capital_id > 221
		);
	}
	
	return capital_id;
}
public int Native_rp_GetPlayerZoneAppart(Handle plugin, int numParams) {
	return getZoneAppart(GetNativeCell(1));
}
public int Native_rp_IsBuildingAllowed(Handle plugin, int numParams) {
	return CheckBuild(GetNativeCell(1), !(view_as<bool>(GetNativeCell(2))));
}
public int Native_rpClientColorize(Handle plugin, int numParams) {
	int client = GetNativeCell(1);
	int color[4];
	GetNativeArray(2, color, sizeof(color));
	
	if( color[0] == -1 ) {
		if( client > MaxClients || g_bUserData[client][b_Invisible] == false ) {
			Colorize(client, 255, 255, 255, 255);
		}
	}
	else {
		Colorize(client, color[0], color[1], color[2], color[3]);
	}
}
public int Native_rp_Effect_Tazer(Handle plugin, int numParams) {
	TazerEffect(GetNativeCell(1), GetNativeCell(2));
	return 1;
}
public int Native_rp_ClientSave(Handle plugin, int numParams) {
	StoreUserData(GetNativeCell(1));
	return 1;
}
public int Native_rp_GetDatabase(Handle plugin, int numParams) {
	return view_as<int>(g_hBDD);
}
public int Native_rp_SetJobCapital(Handle plugin, int numParams) {
	SetJobCapital(GetNativeCell(1), GetNativeCell(2));
}
public int Native_rp_GetJobCapital(Handle plugin, int numParams) {
	return GetJobCapital(GetNativeCell(1));
}
public int Native_rp_ScheduleEntityInput(Handle plugin, int numParams) {
	char tmp[64];
	GetNativeString(3, tmp, sizeof(tmp));
	int ent = GetNativeCell(1);
	float time = view_as<float>(GetNativeCell(2));
	ScheduleEntityInput(ent, time, tmp);
	
	return 1;
}
public int Native_rp_IsClientLucky(Handle plugin, int numParams) {
	return 0;
}
public int Native_rp_AddSaveSlot(Handle plugin, int numParams) {
	return view_as<int>(ItemSave_AddSave(GetNativeCell(1)));
}
public int Native_rp_GetItemData(Handle plugin, int numParams) {
	
	SetNativeString(3, g_szItemList[GetNativeCell(1)][GetNativeCell(2)], GetNativeCell(4));
	
	return 1;
}
public int Native_rp_GetZoneData(Handle plugin, int numParams) {
	SetNativeString(3, g_szZoneList[GetNativeCell(1)][GetNativeCell(2)], GetNativeCell(4));
	return 1;
}
public int Native_rp_GetLocationData(Handle plugin, int numParams) {
	SetNativeString(3, g_szLocationList[GetNativeCell(1)][GetNativeCell(2)], GetNativeCell(4));
	return 1;
}
public int Native_rp_GetGroupData(Handle plugin, int numParams) {
	
	SetNativeString(3, g_szGroupList[GetNativeCell(1)][GetNativeCell(2)], GetNativeCell(4));
	
	return 1;
}
public int Native_rp_GetJobData(Handle plugin, int numParams) {
	
	SetNativeString(3, g_szJobList[GetNativeCell(1)][GetNativeCell(2)], GetNativeCell(4));
	
	return 1;
}
public int Native_rp_Effect_Particle(Handle plugin, int numParams) {
	static char str[128];
	GetNativeString(2, str, sizeof(str));
	
	return AttachParticle(GetNativeCell(1), str, GetNativeCell(3));
}
public int Native_rp_Effect_ParticleTE(Handle plugin, int numParams) {
	static char name[128], attachment[128];
	
	int entity = GetNativeCell(1);
	GetNativeString(2, name, sizeof(name));
	GetNativeString(3, attachment, sizeof(attachment));
	
	TE_SetupParticle(name, entity, attachment);
	return 1;
}
public int Native_rp_Effect_ParticlePath(Handle plugin, int numParams) {
	static char str[128];
	float src[3], ang[3], dst[3];
	GetNativeString(2, str, sizeof(str));
	
	GetNativeArray(3, src, sizeof(src));
	GetNativeArray(4, ang, sizeof(ang));
	GetNativeArray(5, dst, sizeof(dst));
	
	return ShowTrack(GetNativeCell(1), str, src, ang, dst);
}
public int Native_rp_ClientDamage(Handle plugin, int numParams) {
	static char str[128];
	GetNativeString(4, str, sizeof(str));
	int client = GetNativeCell(1);
	int damage = GetNativeCell(2);
	int target = GetNativeCell(3);
	bool legit = view_as<bool>(GetNativeCell(6));
	
	if( legit )
		rp_ClientAggroIncrement(client, target, damage*5);
	
	DealDamage(client, damage, target, GetNativeCell(5), str);
	
	if( !legit )
		rp_ClientAggroIncrement(target, client, damage);
	
	return 1;
}
public int Native_rp_ClientPoison(Handle plugin, int numParams) {
	PoisonPlayer(GetNativeCell(1), view_as<float>(GetNativeCell(2)), GetNativeCell(3));
	return 1;
}
public int Native_rp_ClientIgnite(Handle plugin, int numParams) {
	IgnitePlayer(GetNativeCell(1), view_as<float>(GetNativeCell(2)), GetNativeCell(3));
	return 1;
}
public int Native_rp_SetClientKnifeType(Handle plugin, int numParams) {
	int client = GetNativeCell(1);
	int wepid = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if( !IsValidEntity(wepid) ) {
		return view_as<int>(false);
	}
	
	char classname[64];
	GetEdictClassname(wepid, classname, sizeof(classname));
	if( !StrEqual(classname, "weapon_knife") ) {
		return view_as<int>(false);
	}
	
	int type = GetNativeCell(2);
	if( g_iWeaponsBallType[wepid] == type )
		return view_as<int>(false);
	
	g_iWeaponsBallType[wepid] = type;
	
	return view_as<int>(true);
}
public int Native_rp_GetClientKnifeType(Handle plugin, int numParams) {
	int client = GetNativeCell(1);
	int wepid = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if( !IsValidEntity(wepid) ) {
		return 0;
	}
	
	char classname[64];
	GetEdictClassname(wepid, classname, sizeof(classname));
	if( !StrEqual(classname, "weapon_knife") ) {
		return 0;
	}
	
	return g_iWeaponsBallType[wepid];
}
public int Native_rp_GetWeaponBallType(Handle plugin, int numParams) {
	return g_iWeaponsBallType[GetNativeCell(1)];
}
public int Native_rp_SetWeaponBallType(Handle plugin, int numParams) {
	g_iWeaponsBallType[GetNativeCell(1)] = GetNativeCell(2);
	return 1;
}
public int Native_rp_GetWeaponFireRate(Handle plugin, int numParams) {
	return view_as<int>(g_flWeaponFireRate[GetNativeCell(1)]);
}
public int Native_rp_SetWeaponFireRate(Handle plugin, int numParams) {
	g_flWeaponFireRate[GetNativeCell(1)] = view_as<float>(GetNativeCell(2));
	return 1;
}
public int Native_rp_GetWeaponGroupID(Handle plugin, int numParams) {
	return g_iWeaponsGroup[GetNativeCell(1)];
}
public int Native_rp_SetWeaponGroupID(Handle plugin, int numParams) {
	g_iWeaponsGroup[GetNativeCell(1)] = GetNativeCell(2);
	return 1;
}
public int Native_rp_GetClientGroupID(Handle plugin, int numParams) {
	return GetGroupPrimaryID(GetNativeCell(1));
}
public int Native_rp_GetClientJobID(Handle plugin, int numParams) {
	int client = GetNativeCell(1);
	if( client > 0 )
		return GetJobPrimaryID(client);
	return -1;
}
public int Native_rp_IsInPVP(Handle plugin, int numParams) {
	return IsInPVP(GetNativeCell(1));
}
public int Native_rp_MakeRadiusPush(Handle plugin, int numParams) {
	float center[3];
	GetNativeArray(1, center, sizeof(center));
	MakeRadiusPush2(center, view_as<float>(GetNativeCell(2)), view_as<float>(GetNativeCell(3)), GetNativeCell(4));
}
public int Native_rp_GetPlayerZone(Handle plugin, int numParams) {
	return GetPlayerZone(GetNativeCell(1), view_as<float>(GetNativeCell(2)));
}
public int Native_rp_GetZoneBit(Handle plugin, int numParams) {
	return GetZoneBit(GetNativeCell(1), view_as<float>(GetNativeCell(2)));
}
public int Native_rp_SetZoneBit(Handle plugin, int numParams) {
	SetZoneBit(GetNativeCell(1), GetNativeCell(2));
	return 1;
}
public int Native_rp_ClientRespawn(Handle plugin, int numParams) {
	int client = GetNativeCell(1);
	float duration = view_as<float>(GetNativeCell(2));

	g_flUserData[client][fl_RespawnTime] = GetGameTime() + duration + Math_GetRandomFloat(-0.33, 0.33);
	
}
public int Native_rp_CanMakeSuccess(Handle plugin, int numParams) {
	return view_as<int>(CanMakeSuccess(GetNativeCell(1), GetNativeCell(2)));
}
public int Native_rp_IncrementSuccess(Handle plugin, int numParams) {
	IncrementSuccess(GetNativeCell(1), GetNativeCell(2), GetNativeCell(3));
}
public int Native_rp_Effect_VisionTrouble(Handle plugin, int numParams) {
	VisionTrouble(GetNativeCell(1), view_as<float>(GetNativeCell(2)));
	return 1;
}
public int Native_rp_Effect_ShakingVision(Handle plugin, int numParams) {
	ShakingVision(GetNativeCell(1), view_as<float>(GetNativeCell(2)));
	return 1;
}
public int Native_rp_Effect_Smoke(Handle plugin, int numParams) {
	SmokingEffet(GetNativeCell(1), view_as<float>(GetNativeCell(2)));
	return 1;
}
public int Native_rp_IsTutorialOver(Handle plugin, int numParams) {
	return IsTutorialOver(GetNativeCell(1));
}
public int Native_rp_IsEntitiesNear(Handle plugin, int numParams) {
	return IsEntitiesNear(GetNativeCell(1), GetNativeCell(2), GetNativeCell(3), GetNativeCell(4));
}
public int Native_rp_HookEvent(Handle plugin, int numParams) {
	int client = view_as<int>(GetNativeCell(1));
	rp_event ev = view_as<rp_event>(GetNativeCell(2));
	Function fc = GetNativeFunction(3);
	float duration = view_as<float>(GetNativeCell(4));

	if( duration > -0.5 ) {
		Handle dp;
		CreateDataTimer(duration, Native_rp_HookEvent_Remove, dp, TIMER_DATA_HNDL_CLOSE);
		WritePackCell(dp, client);
		WritePackCell(dp, ev);
		WritePackFunction(dp, fc);
		WritePackCell(dp, plugin);
	}
	
	return AddToForward(g_hRPNative[client][ev], plugin, fc);
}
public Action Native_rp_HookEvent_Remove(Handle timer, Handle dp) {
	ResetPack(dp);
	int client = view_as<int>(ReadPackCell(dp));
	rp_event ev = view_as<rp_event>(ReadPackCell(dp));
	Function fc = ReadPackFunction(dp);
	Handle plugin = view_as<Handle>(ReadPackCell(dp));
	RemoveFromForward(g_hRPNative[client][ev], plugin, fc);
}
public int Native_rp_UnhookEvent(Handle plugin, int numParams) {
	
	int client = view_as<int>(GetNativeCell(1));
	rp_event ev = view_as<rp_event>(GetNativeCell(2));
	
	return RemoveFromForward(g_hRPNative[client][ev], plugin, GetNativeFunction(3));
}
public int Native_rp_getClientFloat(Handle plugin, int numParams) {
	return view_as<int>(g_flUserData[GetNativeCell(1)][GetNativeCell(2)]);
}
public int Native_rp_setClientFloat(Handle plugin, int numParams) {
	g_flUserData[GetNativeCell(1)][GetNativeCell(2)] = view_as<float>(GetNativeCell(3));
	return 1;
}
public int Native_rp_getClientInt(Handle plugin, int numParams) {
	return g_iUserData[GetNativeCell(1)][GetNativeCell(2)];
}
public int Native_rp_setClientInt(Handle plugin, int numParams) {
	g_iUserData[GetNativeCell(1)][GetNativeCell(2)] = view_as<int>(GetNativeCell(3));
	return 1;
}
public int Native_rp_IncrementClientInt(Handle plugin, int numParams) {
	g_iUserData[GetNativeCell(1)][GetNativeCell(2)] += view_as<int>(GetNativeCell(3));
	return 1;
}
public int Native_rp_getClientBool(Handle plugin, int numParams) {
	return g_bUserData[GetNativeCell(1)][GetNativeCell(2)];
}
public int Native_rp_GetClientString(Handle plugin, int numParams) {	
	SetNativeString(3, g_szUserData[GetNativeCell(1)][GetNativeCell(2)], GetNativeCell(4));

	return 1;
}
public int Native_rp_SetClientString(Handle plugin, int numParams) {
	GetNativeString(3, g_szUserData[GetNativeCell(1)][GetNativeCell(2)], GetNativeCell(4));

	return 1;
}
public int Native_rp_setClientBool(Handle plugin, int numParams) {
	g_bUserData[GetNativeCell(1)][GetNativeCell(2)] = view_as<bool>(GetNativeCell(3));
	return 1;
}
public int Native_rp_getClientStat(Handle plugin, int numParams) {
	return g_iUserStat[GetNativeCell(1)][GetNativeCell(2)];
}
public int Native_rp_GetClientPlaytimeJob(Handle plugin, int numParams) {
	if( !GetNativeCell(3) )
		return g_iJobPlayerTime[GetNativeCell(1)][GetNativeCell(2)];
	else
		return g_iJobPlayerTime[GetNativeCell(1)][GetNativeCell(2)-1];
}
public int Native_rp_setClientStat(Handle plugin, int numParams) {
	g_iUserStat[GetNativeCell(1)][GetNativeCell(2)] = view_as<int>(GetNativeCell(3));
	return 1;
}

public int Native_GetClientTarget(Handle plugin, int numParams) {
	int client;
	float dst[3];
	static float cacheTime[65];
	static float cacheDataDst[65][3];
	static int cacheDataTarget[65];

	client = GetNativeCell(1);
	GetNativeArray(2, dst, sizeof(dst));

	if( cacheTime[client] > GetTickedTime() ) {
		dst = cacheDataDst[client];
		SetNativeArray(2, dst, sizeof(dst));
		return cacheDataTarget[client];
	}
	
	float vecStart[3], vecAngles[3];
	GetClientEyePosition(client, vecStart);
	GetClientEyeAngles(client, vecAngles);
	
	Handle trace = TR_TraceRayFilterEx(vecStart, vecAngles, MASK_SOLID, RayType_Infinite, FilterToOne, client);
	if( !TR_DidHit(trace) ) {
		CloseHandle(trace);
		return 0;
	}
	
	cacheDataTarget[client] = TR_GetEntityIndex(trace);
	TR_GetEndPosition(cacheDataDst[client], trace);
	cacheTime[client] = GetTickedTime() + 0.025;
	dst = cacheDataDst[client];
	SetNativeArray(2, dst, sizeof(dst));
	CloseHandle(trace);
	
	return cacheDataTarget[client];
}
public int Native_rp_ClientOverlays(Handle plugin, int numParams) {
	int client = GetNativeCell(1);
	int img = GetNativeCell(2);
	float dur = view_as<float>(GetNativeCell(3));
	
	if( g_iUserData[client][i_PlayerLVL] <= 50 || img < 40 ) {
		if( img != 0 ) {
			ClientCommand(client, "r_screenoverlay DeadlyDesire/adv/v1/%d", img);
			
			if( dur > 0.0 )
				CreateTimer(dur, rp_ClientOverlays_HIDE, client);
		}
		else {
			ClientCommand(client, "r_screenoverlay \"\"");
		}
	}
}
public Action rp_ClientOverlays_HIDE(Handle timer, any client) {
	ClientCommand(client, "r_screenoverlay \"\"");
}
