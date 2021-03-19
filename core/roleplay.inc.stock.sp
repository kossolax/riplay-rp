#if defined _roleplay_stock_included
#endinput
#endif
#define _roleplay_stock_included

#if defined ROLEPLAY_SUB
	#include "../roleplay.sp"
#else
	#include "roleplay.sp"
#endif

// -----------------------------------------------------------------------------------------------------------------
//
//	Stocks
//
int getNextReboot() {
	static char szDate05[64], szDate16[64];
	
	int now = GetTime();
	FormatTime(szDate05, sizeof(szDate05), "%e/%m/%Y/6/00/05", now);
//	FormatTime(szDate16, sizeof(szDate16), "%e/%m/%Y/16/30/05", now);
	
	int iDate05 = DateToTimestamp(szDate05);
	if( iDate05 < now )
		iDate05 += (24 * 60 * 60);
	
//	int iDate16 = DateToTimestamp(szDate16);
//	if( iDate16 < now )
//		iDate16 += (24 * 60 * 60);
	
//	int next = iDate05 > iDate16 ? iDate16 : iDate05;
	int next = iDate05;
	
	return next;
}
float getKillAcceleration(int attack, int victim, int inflictor, const char[] weapon) {
	int zoneID, attackID, victimID;
	
	int src = victim;
	if( StrEqual(weapon, "rp_sentry") ) {
		src = inflictor;
	}
	
	// ---- dans les planques
	zoneID = rp_GetZoneInt(rp_GetPlayerZone(src), zone_type_type);
	if( zoneID > 0 ) {
		if( rp_GetClientJobID(victim) == 1 )
			return 0.7;
		return 0.5;
	}
	
	// ---- dans les appart
	zoneID = rp_GetPlayerZoneAppart(src);
	if( zoneID > 0 ) {
		if( GetClientTeam(victim) == CS_TEAM_CT || (rp_ClientFloodTriggered(attack, victim, fd_freekill1) && rp_ClientFloodTriggered(attack, victim, fd_freekill2)) )
			return 1.0;
		return 0.8;
	}
	
	if( rp_ClientFloodTriggered(attack, victim, fd_freekill1) && rp_ClientFloodTriggered(attack, victim, fd_freekill2) )
		return 1.45;
	if( GetClientTeam(victim) == CS_TEAM_CT )
		return 1.3;
	return 1.1;
}


bool Client_CanUseItem(int client, int itemID) {
	
	Action a; // Quête, merco, ...
	Call_StartForward( view_as<Handle>(g_hRPNative[client][RP_PlayerCanUseItem]));
	Call_PushCell(client);
	Call_PushCell(itemID);
	Call_Finish(a);
		
	if( a == Plugin_Handled || a == Plugin_Stop )
		return false;
	
	return true;
}
bool Client_CanAttack(int attacker, int victim) {

	if( attacker == victim )
		return true;
	if( !g_bUserData[attacker][b_GameModePassive] && !g_bUserData[victim][b_GameModePassive] )
		return true;
	else if( g_iKillLegitime[attacker][victim] >= GetTime() )
		return true;
	else if( rp_IsInPVP(attacker) && rp_IsInPVP(victim) )
		return true;
	else if( g_bIsInCaptureMode && (rp_IsInPVP(attacker) || rp_IsInPVP(victim)) )
		return true;
	else if( rp_GetZoneBit( rp_GetPlayerZone(attacker) ) & (BITZONE_EVENT|BITZONE_PERQUIZ|BITZONE_LEGIT) )
		return true;
	
	Action a; // Quête, merco, ...
	Call_StartForward( view_as<Handle>(g_hRPNative[attacker][RP_PlayerCanKill]));
	Call_PushCell(attacker);
	Call_PushCell(victim);
	Call_Finish(a);
		
	if( a == Plugin_Handled || a == Plugin_Stop )
		return true;
	
	return false;
}
public int SortItemAlpha(int[] a, int[] b, const int[][] array, Handle hndl)  {
	return strcmp(g_szItemList[a[STACK_item_id]][item_type_name], g_szItemList[b[STACK_item_id]][item_type_name]);
}
public int SortItemAlphaReverse(int[] a, int[] b, const int[][] array, Handle hndl)  {
	return strcmp(g_szItemList[b[STACK_item_id]][item_type_name], g_szItemList[a[STACK_item_id]][item_type_name]);
}
public int SortItemType(int[] a, int[] b, const int[][] array, Handle hndl)  {
	return strcmp(g_szItemList[a[STACK_item_id]][item_type_extra_cmd], g_szItemList[b[STACK_item_id]][item_type_extra_cmd]);
}
public int SortItemTypeReverse(int[] a, int[] b, const int[][] array, Handle hndl)  {
	return strcmp(g_szItemList[b[STACK_item_id]][item_type_extra_cmd], g_szItemList[a[STACK_item_id]][item_type_extra_cmd]);
}
public int SortItemJob(int[] a, int[] b, const int[][] array, Handle hndl)  {
	int prix1 = StringToInt(g_szItemList[a[STACK_item_id]][item_type_job_id]);
	int prix2 = StringToInt(g_szItemList[b[STACK_item_id]][item_type_job_id]);
	
	if( prix1 == prix2 )
		return 0;
	else if( prix1 > prix2 )
		return 1;
	else
		return -1;
}
public int SortItemJobReverse(int[] a, int[] b, const int[][] array, Handle hndl)  {
	int prix1 = StringToInt(g_szItemList[b[STACK_item_id]][item_type_job_id]);
	int prix2 = StringToInt(g_szItemList[a[STACK_item_id]][item_type_job_id]);
	
	if( prix1 == prix2 )
		return 0;
	else if( prix1 > prix2 )
		return 1;
	else
		return -1;
}
public int SortItemPrix(int[] a, int[] b, const int[][] array, Handle hndl)  {
	int prix1 = StringToInt(g_szItemList[a[STACK_item_id]][item_type_prix]);
	int prix2 = StringToInt(g_szItemList[b[STACK_item_id]][item_type_prix]);
	
	if( prix1 == prix2 )
		return 0;
	else if( prix1 > prix2 )
		return 1;
	else
		return -1;
}
public int SortItemPrixReverse(int[] a, int[] b, const int[][] array, Handle hndl)  {
	int prix1 = StringToInt(g_szItemList[b[STACK_item_id]][item_type_prix]);
	int prix2 = StringToInt(g_szItemList[a[STACK_item_id]][item_type_prix]);
	
	if( prix1 == prix2 )
		return 0;
	else if( prix1 > prix2 )
		return 1;
	else
		return -1;
}
// HIGHT TO LOW
public int SortMachineItemsH2L(int[] a, int[] b, const int[][] array, Handle hndl)  {
	if( b[0] == a[0] )
		return 0;
	else if( b[0] > a[0] )
		return 1;
	else
		return -1;
}
// LOW TO HIGHT
public int SortMachineItemsL2H(int[] a, int[] b, const int[][] array, Handle hndl)  {
	if( b[0] == a[0] )
		return 0;
	else if( b[0] < a[0] )
		return 1;
	else
		return -1;
}

//We could use strlen, but that could be busted too.
int CountString(const char[] str) {
	int i = 0;
	for( ; str[i] != '\0'; i++) {
	}
	if(str[i] != '\0') {
		return -1;
	}
	return i;
}
void StringExcluder(char[] Buffer,const char[] Source, int StartPoint, int LengthEnd) {
	int X = 0, Y = 0;
	do {
		if(Y == StartPoint) {
			//Jump the position of the source coping;
			Y = Y + LengthEnd;
		}
	}
	while( (Buffer[X++] = Source[Y++]) );
	return;
}
bool RemoveString(char[] Buffer, const char[] SubString, bool onlyCmd = true) {
	if( strlen(SubString) <= 1 )
		return false;
		
	if( onlyCmd && SubString[0] != '/' &&  SubString[0] != '!' )
		return false;

	int X = StrContains(Buffer,SubString,false);
	if(X == -1) {
		return false;
	}

	int Y = CountString(SubString);
	StringExcluder(Buffer,Buffer,X,Y);
	return true; //Removed
}
void SSO_Forum(int client, char[] str, int size) {
	char szCrypted[256], szSteamID[64];
	
	GetClientAuthId(client, AUTH_TYPE, szSteamID, sizeof(szSteamID), false);
	Crypt_RC4Encode(szSteamID, "Cm3VjQ8fpTaMNTYdrMK3Gw4M", szCrypted, sizeof(szCrypted));
	Format(str, size, "&SSOid=%s", szCrypted);
	
}
void detectCapsLock(int client) {
	char message[128];
	GetClientName(client, message, sizeof(message));
	int letters, uppercase, length = strlen(message);
	for(int i = 0; i < length; i++) {
		if(message[i] >= 'A' && message[i] <= 'Z') {
			uppercase++;
			letters++;
		} else if(message[i] >= 'a' && message[i] <= 'z') {
			letters++;
		}
	}
	
	if( letters > 10 && float(uppercase) / float(letters) > 0.9 ) {
		g_bUserData[client][b_CAPSLOCK] = true;
	}
	else {
		g_bUserData[client][b_CAPSLOCK] = false;
	}
}
void incrementJobPlayTime(int client, int time) {
	if( g_iUserData[client][i_Job] > 0 ) {
		int primaryjob = GetJobPrimaryID(client) - 1; // index out of bound ici ?

		if(primaryjob > -1)
			g_iJobPlayerTime[client][ primaryjob ] += time;
		
		g_iJobPlayerTime[client][g_iUserData[client][i_Job]] += time;
	}
}
void AFK_Check(int client) {
	static bool wasTalking[MAX_PLAYERS + 1];
	static int lastBatterie[MAX_ENTITIES+1];
	
	float vecAngles[3];
	GetClientEyeAngles(client, vecAngles);
	
	bool same = true;
	for(int i=0; i<1; i++) {
		if( FloatAbs(vecAngles[i] - g_Position[client][i]) > 2.0 )
			same = false;
	}

	int vehicle = rp_GetClientVehicle(client);
	if( vehicle > 0 ) {
		same = true;
		
		if( lastBatterie[vehicle] != g_iVehicleData[vehicle][car_battery] ) {
			same = false;
		}
		lastBatterie[vehicle] = g_iVehicleData[vehicle][car_battery];
	}
	int passager = rp_GetClientVehiclePassager(client);
	if( passager > 0 ) {
		same = true;
	}
	
// Anti-afk OnTalk
/*
	if( !wasTalking[client] && g_hClientMicTimers[client] != INVALID_HANDLE ) {
		same = false;
		wasTalking[client] = true;
	}
	if( wasTalking[client] && g_hClientMicTimers[client] == INVALID_HANDLE ) {
		same = false;
		wasTalking[client] = false;	
	}
	
 */
	if( !g_bUserData[client][b_IsAFK] && g_iUserData[client][i_Job] != 0 ) {
		g_iUserData[client][i_TimePlayedJob]++;
		incrementJobPlayTime(client, 1);
	}
	if( !g_bUserData[client][b_IsAFK] ) {
		g_iUserData[client][i_TimePlays]++;
	}
	
	if( g_bUserData[client][b_IsAFK] ) {
		g_iUserData[client][i_TimeAFK_total]++;
		g_iUserData[client][i_TimeAFK_today]++;
	}
	
	if( same ) {
		
		g_iUserData[client][i_TimeAFK]++;
		
		if( g_iUserData[client][i_TimeAFK] > 180 ) {
			
			if( !g_bUserData[client][b_IsAFK] ) {
				g_bUserData[client][b_IsAFK] = true;
				CPrintToChat(client, "" ...MOD_TAG... " %T", "AFK_Start", client);
				LogToGame("[TSX-RP] [AFK] %L est maintenant AFK.", client);
				
				g_iUserData[client][i_TimeAFK_total] += 60;
				g_iUserData[client][i_TimeAFK_today] += 180;
				g_iUserData[client][i_TimePlayedJob] -= 180;
				incrementJobPlayTime(client, -180);
				g_iUserData[client][i_TimePlays] -= 180;
				if( g_iUserData[client][i_PlayerXP] >= 180 )
					g_iUserData[client][i_PlayerXP] -= 180;
				
			}
			else {				
				if( !IsClientInJail(client) ) {
					if( g_iUserData[client][i_TimeAFK] > (4*60*60) ||
						(g_iUserData[client][i_TimeAFK] > (1*60*60) && g_iUserData[client][i_TimeAFK_total] > (8*60*60)) ) {
						
						for(int i=0; i<MAX_ITEMS; i++) { 
							if( rp_GetClientItem(client, i) > 0 ) {
								rp_ClientGiveItem(client, i, rp_GetClientItem(client, i), true);
								rp_ClientGiveItem(client, i, -rp_GetClientItem(client, i), false);
							}
						}
						KickClient(client, "%T", "AFK_Kick", client);
					}
				}
			}
		}
	}
	else {
		if( g_bUserData[client][b_IsAFK] ) {
			g_bUserData[client][b_IsAFK] = false;
			CPrintToChat(client, "" ...MOD_TAG... " %T", "AFK_End", client, g_iUserData[client][i_TimeAFK]/60);
			LogToGame("[TSX-RP] [AFK] %L n'est plus AFK.", client);
		}
		g_iUserData[client][i_TimeAFK] = 0;
		if( g_iUserData[client][i_PlayerLVL] < 100 )
			rp_ClientXPIncrement(client);
		
		if( g_bUserData[client][b_IsFirstSpawn] ) {
			EventFirstSpawn(client);
			
			g_bUserData[client][b_IsFirstSpawn] = false;
		}
	}
	
	g_Position[client] = vecAngles;
}

void SQL_Reconnect() {
	
	if( GetRandomInt(0, 300) )
		SQL_TQuery(g_hBDD, SQL_QueryCallBack, "SET NAMES 'utf8mb4'");


	if( g_hBDD == INVALID_HANDLE ) {
		PrintToChatAll("%T", "Error_FromServer", LANG_SERVER);
		LogToGame("ERREUR FATAL, Perte de la connexion à la base de donnée.");
		LogToFile("roleplay.txt", "ERREUR FATAL, Perte de la connexion à la base de donnée.");
		g_hBDD = SQL_Connect("default", true, g_szError, sizeof(g_szError));
	}
}

int ExplosionDamage(float origin[3], float damage, float lenght, int activator=0, int inflictor=0, char weapon[] = "") {
	static float lastExpl[3];
	
	int zone = GetPointZone(origin);
	int zoneBIT = GetZoneBit(zone);
	
	if( zoneBIT & BITZONE_PEACEFULL )
		return 0;
	origin[2] += 25.0;
	if( GetZoneBit(GetPointZone(origin)) & BITZONE_PEACEFULL )
		return 0;
	origin[2] -= 25.0;
	
	if( !(zoneBIT & BITZONE_EVENT) && !(zoneBIT & BITZONE_PVP) && IsValidClient(activator) && rp_GetClientJobID(activator) == 131 && !g_bUserData[activator][b_GameModePassive] ) { 
		damage *= 1.5;
	}
	
	if( lenght < 1.0 && lenght > -1.0 )
		lenght = 1.0;
	
	float PlayerVec[3], distance, falloff = (damage/lenght);
	
	float min[3] = { -8.0, -8.0, -8.0};
	float max[3] = {  8.0,  8.0,  8.0};
	float origin2[3], normal[3];
	
	if( GetVectorDistance(origin, lastExpl) >= 8.0 ) {
		
		
		Handle tr = TR_TraceHullFilterEx(origin, origin, min, max, MASK_SHOT, TraceEntityFilterStuff2, inflictor);
		
		TR_GetPlaneNormal(tr, normal);
		TR_GetEndPosition(origin2, tr);
		CloseHandle(tr);
		
		if( GetVectorDistance(origin, origin2) <= 32.0 ) {
			origin[0] = origin2[0];
			origin[1] = origin2[1];
			origin[2] = origin2[2];
		}
		
		TE_SetupExplosion(origin, g_cExplode, 1.0, 1, 0, RoundFloat(lenght), RoundFloat(damage), normal);
		TE_SendToAll();
		
		TE_Start("World Decal");
		TE_WriteVector("m_vecOrigin", origin);
		TE_WriteNum("m_nIndex", g_cScorch);
		TE_SendToAll();
	}
	
	lastExpl[0] = origin[0];
	lastExpl[1] = origin[1];
	lastExpl[2] = origin[2];
	
	damage *= 1.25;
	
	bool minimal = false;
	if( StrEqual(weapon, "weapon_sucetteduo") ) {
		if( !IsInPVP(activator) ) {
			minimal = true;
		}
		
		if( !(zoneBIT & BITZONE_EVENT) && !(zoneBIT & BITZONE_PVP) && IsValidClient(activator) && rp_GetClientJobID(activator) == 191 && !g_bUserData[activator][b_GameModePassive] ) {
			damage *= 1.5;
			lenght *= 2.0;
		}
	}
	
	int res = 0;
	
	for(int i=1; i<=GetMaxEntities(); i++) {
		if( !IsValidEdict(i) )
			continue;
		if( !IsValidEntity(i) )
			continue;
		if( !IsMoveAble(i) )
			continue;
		if( IsValidClient(i) ) {
			if( !IsPlayerAlive(i) || IsInVehicle(i) ) {
				continue;
			}
			
			GetClientEyePosition(i, PlayerVec);
			GetClientAbsOrigin(i, origin2);
			PlayerVec[2] = (origin2[2]+PlayerVec[2])/2.0;
		}
		else {
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", PlayerVec);
		}
		
		distance = view_as<float>(Math_Min(1.0, GetVectorDistance(origin, PlayerVec))) * falloff;
		
		if( distance > lenght )
			continue;
		
		float dmg = (damage - distance);
		
		if( minimal && IsInPVP(i) ) {
			dmg *= 0.33;
		}
		
		if( dmg < 0.0 )
			continue;
		
		TR_TraceRayFilter(origin, PlayerVec, MASK_SHOT, RayType_EndPoint, TraceEntityFilterStuff2, inflictor);
		float fraction = (TR_GetFraction()) * 1.25;
		
		if( fraction > 1.0 )
			fraction = 1.0;
		if( fraction < 0.0 )
			fraction = 0.0;
		
		dmg *= fraction;
		
		if( dmg <= 0.0 )
			continue;
		
		g_iUserData[activator][i_LastAgression] = GetTime();
		DealDamage(i, RoundFloat(dmg), activator, DMG_BLAST, weapon);

		if( IsValidClient(i) ) {
			rp_ClientAggroIncrement(activator, i, RoundFloat(dmg));
			res++;
		}
	}
	
	MakeRadiusPush2(origin, lenght, (damage * 2.0));
	return res;
}
public bool TraceEntityFilterStuff2(int entity, int mask, int data) {

	if( IsValidClient(entity) || IsMoveAble(entity) )
		return false;
	
	if( entity > 0 && IsValidEdict(entity) && IsValidEntity(entity) ) {
		char classname[64];
		GetEdictClassname(entity, classname, sizeof(classname));
		if( StrContains(classname, "rp_") == 0 || StrContains(classname, "ctf_") == 0 ) {
			return false;
		}
	}
	
	if( data > 0 && entity == data )
		return false;
	
	return true;
}
void MakeRadiusPush2( float center[3], float lenght, float damage, int ignore = -1) {
	if( lenght < 1.0 && lenght > -1.0 )
		lenght = 1.0;
	
	if( GetZoneBit(GetPointZone(center)) & BITZONE_PEACEFULL )
		return;

	static float lastExpl[3];
	float vecPushDir[3], vecOrigin[3], vecVelo[3], FallOff = (damage/lenght);
	
	char classname[64];
	
	if( GetVectorDistance(center, lastExpl) >= 4.0 ) {
		
		for(int i=1; i<=2048; i++) {
			if( !IsValidEdict(i) || !IsValidEntity(i) )
				continue;
			
			GetEdictClassname(i, classname, sizeof(classname));
			
			if( !IsMoveAble(i) && !StrEqual(classname, "monster_generic") )
				continue;
			
			if( i == ignore )
				continue;
			
			if( IsValidClient(i) ) {
				if( !IsPlayerAlive(i) ) {
					continue;
				}
				
				GetClientEyePosition(i, vecOrigin);
			}
			else {
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", vecOrigin);
			}
			
			if( GetVectorDistance(vecOrigin, center) > lenght )
				continue;
			
			GetEntPropVector(i, Prop_Data, "m_vecVelocity", vecVelo);
			
			vecPushDir[0] = vecOrigin[0] - center[0];
			vecPushDir[1] = vecOrigin[1] - center[1];
			vecPushDir[2] = vecOrigin[2] - center[2];
			
			NormalizeVector(vecPushDir, vecPushDir);
			float dist = view_as<float>(Math_Min(1.0, (lenght - GetVectorDistance(vecOrigin, center)))) * FallOff;
			
			TR_TraceRayFilter(center, vecOrigin, MASK_SHOT, RayType_EndPoint, TraceEntityFilterStuff2, ignore);
			float fraction = (TR_GetFraction()) * 1.5;
			
			if( fraction >= 1.0 )
				fraction = 1.0;
				
			dist *= fraction;
			if( dist <= 0.1 )
				continue;
			
			float vecPush[3];
			vecPush[0] = (dist * vecPushDir[0]) + vecVelo[0];
			vecPush[1] = (dist * vecPushDir[1]) + vecVelo[1];
			vecPush[2] = (dist * vecPushDir[2]) + vecVelo[2];
			
			int flags = GetEntityFlags(i);
			if( vecPush[2] > 0.0 && (flags & FL_ONGROUND) && HasEntProp(i, Prop_Send, "m_hGroundEntity") ) {
				SetEntityFlags(i, (flags&~FL_ONGROUND) );
				SetEntPropEnt(i, Prop_Send, "m_hGroundEntity", -1);
			}
			TeleportEntity(i, NULL_VECTOR, NULL_VECTOR, vecPush);
		}
	}
	lastExpl[0] = center[0];
	lastExpl[1] = center[1];
	lastExpl[2] = center[2];
}
int SpawnMoney( float origin[3], bool away = false, bool high = false) {
	int id = CreateEntityByName("item_cash");
	if(id == -1)
		return -1;
	
	DispatchKeyValue(id, "classname", 	"money_entity");
	DispatchKeyValueVector(id, "Origin", origin);
	
	DispatchSpawn(id);
	
	rp_AcceptEntityInput( id, "DisableCollision" );
	rp_AcceptEntityInput( id, "EnableCollision" );
	
	float vecVelocity[3];
	
	if( !away ) {
		TeleportEntity(id, origin, NULL_VECTOR, vecVelocity);
	}
	
	if( high )
		Entity_SetTargetName(id, "rp_money_high");
	else
		Entity_SetTargetName(id, "rp_money_low");
	
	SDKHook(id, SDKHook_Touch, MoneyEntityGotTouch);
	rp_ScheduleEntityInput(id, 60.0, "Kill");
	
	return id;
}
public void MoneyEntityGotTouch(int touched, int toucher) {
	if( !IsValidEdict(touched) || !IsValidEdict(toucher) )
		return;
	if( !IsValidEntity(touched) || !IsValidEntity(toucher) )
		return;
	
	if( !IsValidClient(toucher))
		return;
	
	if( !IsPlayerAlive(toucher) )
		return;
	
	char ClassName[64];
	GetEdictClassname(touched, ClassName, 63);
	
	if( !StrEqual(ClassName, "money_entity") )
		return;
	
	Entity_GetTargetName(touched, ClassName, 63);
	
	int amount = Math_GetRandomInt(2, 5);
	
	if( StrEqual(ClassName, "rp_money_high") ) {
		amount *= 100;
	}
	else {
		amount *= 10;
	}
	
	g_iUserStat[toucher][i_MoneyEarned_Pickup] += amount;
	
	rp_ClientMoney(toucher, i_AddToPay, amount);
	
	CPrintToChat(toucher, "" ...MOD_TAG... " %T", "Money_Take", toucher, amount);
	
	SDKUnhook(touched, SDKHook_Touch, MoneyEntityGotTouch);
	rp_AcceptEntityInput(touched, "Kill");
	
	return;
}
void MakePhoneRing() {
	int MaxPhone = 0;
	float fLocation[MAX_LOCATIONS][3];
	
	int i=0;
	for( i=0; i<MAX_ENTITIES; i++) {
		
		if( !IsValidEdict(i) )
			continue;
		if( !IsValidEntity(i) )
			continue;
		
		char classname[64];
		GetEdictClassname(i, classname, 63);
		
		if( StrContains(classname, "rp_phone") == 0 ) {
			
			float vecOrigin[3];
			Entity_GetAbsOrigin(i, vecOrigin);
			fLocation[MaxPhone][0] = vecOrigin[0];
			fLocation[MaxPhone][1] = vecOrigin[1];
			fLocation[MaxPhone][2] = vecOrigin[2];
			MaxPhone++;
		}
	}
	
	if( MaxPhone == 0 )
		return;
	
	i = Math_GetRandomInt(0, (MaxPhone-1));
	
	g_flPhoneStart = (GetTickedTime() + 30.0);
	g_flPhonePosit[0] = fLocation[i][0];
	g_flPhonePosit[1] = fLocation[i][1];
	g_flPhonePosit[2] = fLocation[i][2];
	g_iPhoneType = Math_GetRandomInt(1, 2);
	
}
float degrees_to_radians(float degreesGiven) {
	return degreesGiven*(3.141592653/180.0);
}
bool IsAdmin(int client) {
	char szSteamID[64];
	
	if( GetConVarInt(FindConVar("hostport")) != 27015 ){
		if( GetUserFlagBits(client) & ADMFLAG_ROOT){
			return true;
		}
	}

	if( GetUserFlagBits(client) & ADMFLAG_ROOT){
		GetClientAuthId(client, AUTH_TYPE, szSteamID, sizeof(szSteamID), false);
		for(int i = 0; i < sizeof(g_szSuperAdmin); i++) {
			if(!StrEqual(g_szSuperAdmin[i], szSteamID)) {
				continue;
			}
			
			return true;
		}
	}

	return false;
}
bool IsNight() {
	if( g_iHours >= 19 || g_iHours <= 5 ) {
		return true;
	}
	return false;
}

bool IsEntitiesNear(int ent1, int ent2, bool tres_proche = false, float cache = 0.25) {
	static float g_flLastCheck[MAX_PLAYERS+1][MAX_ENTITIES];
	static bool g_bLastData[MAX_PLAYERS+1][MAX_ENTITIES];
	
	float f_Origin_1[3], f_Origin_2[3];
	
	float distance = rp_GetDistance(ent1, ent2);
	
	if( tres_proche ) {
		if( (distance*0.5) <= CONTACT_DIST) {
			if( distance <= 38.0 ) {
				g_bLastData[ent1][ent2] = true;
			}
			else if( IsValidClient(ent1) ) {
				if( g_flLastCheck[ent1][ent2] > GetGameTime() ) {
					return g_bLastData[ent1][ent2];
				}
				
				g_flLastCheck[ent1][ent2] = GetGameTime() + cache;
				g_bLastData[ent1][ent2] = false;
				GetClientEyePosition(ent1, f_Origin_1);
				GetClientEyeAngles(ent1, f_Origin_2);
				
				Handle tr = TR_TraceRayFilterEx(f_Origin_1, f_Origin_2, MASK_SOLID, RayType_Infinite, FilterToOne, ent1);
				if( TR_DidHit(tr) ) {
					if( ent2 == TR_GetEntityIndex(tr) ) {
						TR_GetEndPosition(f_Origin_2, tr);
						distance = GetVectorDistance(f_Origin_1, f_Origin_2);
						
						if( distance <= 52.0 ) {
							g_bLastData[ent1][ent2] = true;
						}
					}
					else if( IsValidEdict(TR_GetEntityIndex(tr)) && Entity_GetParent(TR_GetEntityIndex(tr)) == ent2) {
						TR_GetEndPosition(f_Origin_2, tr);
						distance = GetVectorDistance(f_Origin_1, f_Origin_2);
						
						if( distance <= 52.0 ) {
							g_bLastData[ent1][ent2] = true;
						}
					}
				}
				CloseHandle(tr);
			}
			else {
				g_bLastData[ent1][ent2] = false;
			}
		}
		else {
			g_bLastData[ent1][ent2] = false;
		}
	}
	else {
		if( distance <= CONTACT_DIST) {
			g_bLastData[ent1][ent2] = true;
		}
		else {
			g_bLastData[ent1][ent2] = false;
		}
	}
	
	return g_bLastData[ent1][ent2];
}
void RP_SpawnBank() {
	char szMysql[1024], type[32], tmp[256], mapname[32];
	GetCurrentMap(mapname, sizeof(mapname));

	Format(szMysql, sizeof(szMysql), "SELECT `id`, `origin_x`, `origin_y`, `origin_z`, `angle_y`, `type`, `physics` FROM `rp_spawner` WHERE `map`='%s';", mapname);
	
	SQL_LockDatabase(g_hBDD);
	Handle req = SQL_Query(g_hBDD, szMysql);
	
	if( req != INVALID_HANDLE ) {
		for(int i=0; i<MAX_ENTITIES; i++) {
			if( !IsValidEdict(i) )
				continue;
			if( !IsValidEntity(i) )
				continue;
			
			GetEdictClassname(i, tmp, sizeof(tmp));
			
			if( StrContains(tmp, "rp_phone") == 0 || StrContains(tmp, "rp_bank") == 0 || StrContains(tmp, "rp_mail_") == 0  || StrContains(tmp, "rp_weaponbox") == 0 ) {
				if( StrContains(tmp, "rp_bank") == 0 && rp_GetBuildingData(i, BD_owner) != 0 )
					continue;
				rp_AcceptEntityInput(i, "Kill");
			}
		}
		
		int i = 0;
		while( SQL_FetchRow(req) ) {
			i++;
			
			float vecOrigin[3], vecAngles[3];
			vecOrigin[0] = float(SQL_FetchInt(req, 1));
			vecOrigin[1] = float(SQL_FetchInt(req, 2));
			vecOrigin[2] = float(SQL_FetchInt(req, 3));
			vecAngles[1] = float(SQL_FetchInt(req, 4));
			
			SQL_FetchString(req, 5, type, sizeof(type));
			
			int ent = CreateEntityByName(SQL_FetchInt(req, 6) == 0 ? "prop_dynamic" : "prop_physics");
			
			if( StrEqual(type, "bank") ) {
				Format(tmp, sizeof(tmp), "rp_bank");
				
				DispatchKeyValue(ent, "model", "models/DeadlyDesire/props/atm01.mdl");				
				SetEntityModel(ent, "models/DeadlyDesire/props/atm01.mdl");
				DispatchKeyValue(ent, "solid", "0");
				
				vecAngles[1] -= 90.0;
				
			}
			else if( StrEqual(type, "phone") ) {
				Format(tmp, sizeof(tmp), "rp_phone");
				
				DispatchKeyValue(ent, "model", "models/props_unique/airport/phone_booth_airport.mdl");
				DispatchKeyValue(ent, "solid", "6");
				
				SetEntityModel(ent, "models/props_unique/airport/phone_booth_airport.mdl");
				
				vecAngles[1] -= 90.0;
			
				vecOrigin[0] += Sine( degrees_to_radians(vecAngles[1]) ) * -5.0;
				vecOrigin[1] += Cosine( degrees_to_radians(vecAngles[1]) ) * -5.0;
				vecOrigin[2] += 0.0;
				
				vecAngles[1] += 90.0;
			}
			else if( StrContains(type, "mail_") == 0 ) {
				Format(tmp, sizeof(tmp), "rp_%s", type);
				
				DispatchKeyValue(ent, "model", "models/props_street/mail_dropbox.mdl");
				DispatchKeyValue(ent, "solid", "6");
				
				SetEntityModel(ent, "models/props_street/mail_dropbox.mdl");
			}
			else if( StrEqual(type, "weapon") ) {
				Format(tmp, sizeof(tmp), "rp_weaponbox");
				
				
				DispatchKeyValue(ent, "model", "models/DeadlyDesire/props/atm01.mdl");				
				SetEntityModel(ent, "models/DeadlyDesire/props/atm01.mdl");
				DispatchKeyValue(ent, "solid", "0");
				
				vecAngles[1] -= 90.0;
			}
			
			DispatchKeyValue(ent, "classname", tmp);
			
			DispatchSpawn(ent);
			ActivateEntity(ent);
			
			rp_SetBuildingData(ent, BD_owner, 0);
			rp_SetBuildingData(ent, BD_item_id, i);
			
			if( StrEqual(type, "bank") ) {
				float mins[3] = { -8.0, -8.0, 0.0 };
				float maxs[3] = { 8.0, 8.0, 80.0 };
				
				SetEntProp( ent, Prop_Send, "m_nSolidType", 2 );
				SetEntPropVector( ent, Prop_Send, "m_vecMins", mins);
				SetEntPropVector( ent, Prop_Send, "m_vecMaxs", maxs);
			}
			else if( StrEqual(type, "weapon") ) {
				
				float mins[3] = { -8.0, -8.0, 0.0 };
				float maxs[3] = { 8.0, 8.0, 80.0 };
				
				SetEntProp( ent, Prop_Send, "m_nSolidType", 2 );
				SetEntPropVector( ent, Prop_Send, "m_vecMins", mins);
				SetEntPropVector( ent, Prop_Send, "m_vecMaxs", maxs);
			}
			
			TeleportEntity(ent, vecOrigin, vecAngles, NULL_VECTOR);
			rp_AcceptEntityInput( ent, "DisableCollision" );
			rp_AcceptEntityInput( ent, "EnableCollision" );
			
			#if defined EVENT_NOEL
			if( StrEqual(type, "tree2") ) {
				if( GetConVarInt(g_hEVENT_NOEL) != 1 )
					rp_AcceptEntityInput(ent, "Kill");
			}
			#endif
		}
	}
	
	SQL_UnlockDatabase(g_hBDD);
	
	CloseHandle(req);
}
#if defined EVENT_NOEL
void SpawnRandomBonbon() {
	
	ServerCommand("sm_effect_weather snow 100");
	
	return;
	// Deprecated?
	
	for( int i=MaxClients; i<=GetMaxEntities(); i++ ) {
		if( !IsValidEdict(i) )
			continue;
		if( !IsValidEntity(i) )
			continue;
		
		char ClassName[64];
		GetEdictClassname(i, ClassName, 63);
		
		if( StrContains(ClassName, "rp_tree") == -1 )
			continue;
		
		if( Math_GetRandomInt(0, 16) != 0 )
			continue;
		
		float vecOrigin[3];
		GetEntPropVector(i, Prop_Send, "m_vecOrigin", vecOrigin);
		TE_Start("World Decal");
		TE_WriteVector("m_vecOrigin", vecOrigin);
		TE_WriteNum("m_nIndex", g_cSnow);
		TE_SendToAll();
		
		int cpt = 6;
		if( StrEqual(ClassName, "rp_tree2") )
			cpt = 18;
		
		for(int a=0; a<Math_GetRandomInt(3, cpt); a++) {
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", vecOrigin);
			
			
			float Angle = GetRandomFloat(0.0, 359.9);
			
			vecOrigin[0] = (vecOrigin[0] + (100 * Cosine(DegToRad(Angle))));
			vecOrigin[1] = (vecOrigin[1] + (100 * Sine(DegToRad(Angle))));
			vecOrigin[2] = (vecOrigin[2] + 100);
			
			SpawnBonbon( vecOrigin );
			
		}
	}
}
#endif

stock void SpawnBonbon( float origin[3], int owner = 0) {
	int id = CreateEntityByName("prop_physics");
	if(id == -1)
		return;
	
	char path[128], szSkin[12];
	Format(path, 127, "models/effects/bday_gib0%i.mdl", Math_GetRandomInt(1, 4) );
	Format(szSkin, 11, "%i", Math_GetRandomInt(0, 1));
	
	if( !IsModelPrecached( path ) ) {
		PrecacheModel( path );
	}
	
	SetEntityModel(id, path);
	SetEntityMoveType( id, MOVETYPE_VPHYSICS);
	
	DispatchKeyValue(id, "classname", 	"bonbon_entity");
	DispatchKeyValueVector(id, "Origin", origin);
	DispatchKeyValue(id, "skin", szSkin);
	
	DispatchSpawn(id);
	
	rp_AcceptEntityInput( id, "DisableCollision" );
	rp_AcceptEntityInput( id, "EnableCollision" );
	
	TeleportEntity(id, origin, NULL_VECTOR, NULL_VECTOR);
	SDKHook(id, SDKHook_Touch, 	BonbonEntityGotTouch);
	
	ScheduleEntityInput(id, 60.0, "Kill");
	
	ServerCommand("sm_effect_particles %d Trail5 10", id);
	return;
}
public void BonbonEntityGotTouch(int touched, int toucher) {
	
	if( !IsValidEdict(touched) || !IsValidEdict(toucher) )
		return;
	if( !IsValidEntity(touched) || !IsValidEntity(toucher) )
		return;
	
	if( !IsValidClient(toucher))
		return;
	
	if( !IsPlayerAlive(toucher) )
		return;
	
	char ClassName[64];
	GetEdictClassname(touched, ClassName, 63);
	
	if( !StrEqual(ClassName, "bonbon_entity") )
		return;
	
	if( g_iOriginOwner[touched] > 0 && g_iOriginOwner[touched] != toucher )
		return;
	
	if( !g_bUserData[toucher][b_IsAFK] ) {
		
		if( Math_GetRandomInt(1, 100) > 20 && IsTutorialOver(toucher) ) {
			int rand = Math_GetRandomPow(10, 15) * 10;
			rp_ClientXPIncrement(toucher, rand);
		}
		else {
			ServerCommand("rp_item_hamburger happy %d", toucher);
		}
	}
	
	rp_AcceptEntityInput(touched, "Kill");
	
	return;
}

int RunMapCleaner(bool full = false, bool admin = false, int zone = 0) {
	
	const int max = 100;
	char classname[64], path[128];
	
	int amount = CleanUp(false, zone);
	if( amount < max && !admin )
		amount += CleanUp(true, zone);
	
	if( amount <= max || full ) {
		
		for (int i=MaxClients;i<=MAX_ENTITIES;i++) {
			if( !IsValidEdict(i) || !IsValidEntity(i) )
				continue;
			
			GetEdictClassname(i, classname, sizeof(classname));
			
			
			if( StrContains(classname, "prop_dynamic") == 0 || StrContains(classname, "prop_physics") == 0 ||
				StrContains(classname, "point_tesla") == 0 || StrContains(classname, "entity_blocker") == 0 ||
				StrContains(classname, "cfe_player_decal") == 0) {
					
				if( Entity_GetParent(i) > 0 )
					continue;
				
				if( StrContains(classname, "prop_dynamic_glow") == 0 || StrContains(classname, "rp_weaponbox_") == 0 )
					continue;
					
				if( StrContains(classname, "prop_dynamic") == 0 ) {
					Entity_GetModel(i, path, sizeof(path));
					if( StrContains(path, "door01_left.mdl") != -1 || StrContains(path, "door_airlock") != -1 )
						continue;
				}
				
				if( StrContains(classname, "cfe_player_decal") == 0 ) {
				}
				
				if( zone == 0 || GetPlayerZone(i) == zone ) {
					PrintToServer("[CLEANER-1] Supprimé: [%d] %s (full=%b admin=%b zone=%d) %s", i, classname, full, admin, zone, path);
					rp_AcceptEntityInput(i, "Kill");	amount++;
				}
			}
			
			if( !full && amount >= max )
				break;
		}
		
	}
	
	if( amount <= max || full ) {
		
		for (int i=MaxClients;i<=MAX_ENTITIES;i++) {
			if( !IsValidEdict(i) || !IsValidEntity(i) )
				continue;
			
			GetEdictClassname(i, classname, sizeof(classname));
			
			if( StrContains(classname, "rp_block") == 0 || StrContains(classname, "chicken") == 0 || 
				StrContains(classname, "zombie") == 0 || StrContains(classname, "bonbon_entity") == 0 ||
				StrContains(classname, "rp_banan") == 0 ) {
				
				
				if( zone == 0 || GetPlayerZone(i) == zone ) {
					PrintToServer("[CLEANER-2] Supprimé: [%d] %s (full=%b admin=%b zone=%d)", i, classname, full, admin, zone);
					rp_AcceptEntityInput(i, "Kill"); amount++;
					if( !full && amount >= max )
						break;
				}
			}
		}
	}
	
	if( amount <= 0 && ( (!admin && zone == 0) || (admin && zone != 0) ) ) { // Comment est-ce possible??
		
		
		for (int i=MaxClients;i<=MAX_ENTITIES;i++) {
			if( !IsValidEdict(i) || !IsValidEntity(i) )
				continue;
			
			GetEdictClassname(i, classname, sizeof(classname));
			if( StrContains(classname, "rp_mine") == 0 || StrContains(classname, "rp_plant") == 0 ||
				StrContains(classname, "rp_cash") == 0 || StrContains(classname, "rp_bigcash") == 0 ) {
				
				if( ( zone == 0 || GetPlayerZone(i) == zone ) ) {
					PrintToServer("[CLEANER-3] Supprimé: [%d] %s (full=%b admin=%b zone=%d)", i, classname, full, admin, zone);
					rp_AcceptEntityInput(i, "Kill");	amount++;
				}
			}
			
			if( !full && amount >= max )
				break;
		}
		
	}
	
	
	LogToGame("[TSX-RP] [DEBUG] %i prop ont ete supprime.", amount);
	
	return amount;
}
int CleanUp(bool full = false, int zone = 0) {
	int amount = 0;
	char name[64];
	
	
	for (int i=MaxClients;i<=MAX_ENTITIES;i++) {
		if( !IsValidEdict(i) )
			continue;
		if( !IsValidEntity(i) )
			continue;
			
		GetEdictClassname(i, name, sizeof(name));
		
		if( (StrContains(name, "weapon_") == -1 && StrContains(name, "item_") == -1) && StrContains(name, "bumpmine_projectile") == -1 || StrContains(name, "weapon_c4") == 0)
			continue;
		if( StrContains(name, "weapon_") == 0 && Weapon_GetOwner(i) > 0 )
			continue;
		
		if( full ) {
			rp_AcceptEntityInput(i, "Kill"); amount++;
		}
		else if( GetPlayerZone(i) == zone ) {
			rp_AcceptEntityInput(i, "Kill"); amount++;
		}
	}
	
	return amount;
}
//
//
void AddDownloadsTable() {
	//
	AddFileToDownloadsTable("materials/models/cloud/santahat/kn_santahat.vmt");
	AddFileToDownloadsTable("materials/models/cloud/santahat/kn_santahat.vtf");
	AddFileToDownloadsTable("models/cloud/kn_santahat.dx90.vtx");
	AddFileToDownloadsTable("models/cloud/kn_santahat.mdl");
	AddFileToDownloadsTable("models/cloud/kn_santahat.phy");
	AddFileToDownloadsTable("models/cloud/kn_santahat.sw.vtx");
	AddFileToDownloadsTable("models/cloud/kn_santahat.vvd");
	AddFileToDownloadsTable("models/cloud/kn_santahat.xbox.vtx");
	
	AddFileToDownloadsTable("materials/models/effects/bday_gift01.vmt");
	AddFileToDownloadsTable("materials/models/effects/bday_gift01.vtf");
	AddFileToDownloadsTable("materials/models/effects/bday_gift01_blue.vmt");
	AddFileToDownloadsTable("materials/models/effects/bday_gift01_blue.vtf");
	AddFileToDownloadsTable("materials/models/effects/flat_normal.vtf");
	
	AddFileToDownloadsTable("models/effects/bday_gib01.dx90.vtx");
	AddFileToDownloadsTable("models/effects/bday_gib01.mdl");
	AddFileToDownloadsTable("models/effects/bday_gib01.phy");
	AddFileToDownloadsTable("models/effects/bday_gib01.sw.vtx");
	AddFileToDownloadsTable("models/effects/bday_gib01.vvd");
	AddFileToDownloadsTable("models/effects/bday_gib02.dx90.vtx");
	AddFileToDownloadsTable("models/effects/bday_gib02.mdl");
	AddFileToDownloadsTable("models/effects/bday_gib02.phy");
	AddFileToDownloadsTable("models/effects/bday_gib02.sw.vtx");
	AddFileToDownloadsTable("models/effects/bday_gib02.vvd");
	AddFileToDownloadsTable("models/effects/bday_gib03.dx90.vtx");
	AddFileToDownloadsTable("models/effects/bday_gib03.mdl");
	AddFileToDownloadsTable("models/effects/bday_gib03.phy");
	AddFileToDownloadsTable("models/effects/bday_gib03.sw.vtx");
	AddFileToDownloadsTable("models/effects/bday_gib03.vvd");
	AddFileToDownloadsTable("models/effects/bday_gib04.dx90.vtx");
	AddFileToDownloadsTable("models/effects/bday_gib04.mdl");
	AddFileToDownloadsTable("models/effects/bday_gib04.phy");
	AddFileToDownloadsTable("models/effects/bday_gib04.sw.vtx");
	AddFileToDownloadsTable("models/effects/bday_gib04.vvd");	
}
//
// Autoriser le vol d'un joueur
public Action AllowStealing(Handle timer, any client) {
	g_bUserData[client][b_MaySteal] = true;
}
int _GetTime(float time) {
	static float last;
	static int ret;
	
	if( last > time )
		return ret;
	
	last = time + 0.1;
	ret = GetTime();
	
	return ret;
}
void SynchronizeTime(float time) {
	static int last_sec = 0;
	static float last_sec_tick = 0.0;
	static char szMinutes[32], szHours[32], szDays[32], szMonth[32], szYear[32], szSec[32], args[64];
	
	int stamp = _GetTime(time) * 60;	

	FormatTime(szMinutes, 31, "%M", stamp);
	FormatTime(szHours, 31, "%H", stamp);
	FormatTime(szDays, 31, "%d", stamp);
	FormatTime(szMonth, 31, "%m", stamp);
	FormatTime(szYear, 31, "%Y", stamp);
	FormatTime(szSec, 31, "%S", stamp);
	
	g_iMinutes = StringToInt(szMinutes);
	g_iHours = StringToInt(szHours);
	g_iDays = StringToInt(szDays);
	g_iMonth = StringToInt(szMonth);
	g_iYear = StringToInt(szYear);
	g_iYear += 110;
	
	if( g_iMinutes != last_sec ) {
		last_sec = g_iMinutes;
		last_sec_tick = time;
	}
	
	Format(args, sizeof(args), "sm_effect_sun %d %d %.3f", g_iHours, g_iMinutes, (time-last_sec_tick)*60.0);
	ServerCommand(args);
}
public bool RayDontHitClient(int entity, int contentsMask, any data) {
	return (entity != data);
}
int getAFK() {
	int client, max;
	max = 0;
	//
	// 1. Le plus AFK
	max = 0;
	for(int i=1; i<=MaxClients; i++) {
		if( !IsValidClient(i) )
			continue;
		if( IsClientSourceTV(i) )
			continue;
		if( IsFakeClient(i) )
			continue;
		if( !g_bUserData[i][b_IsAFK] )
			continue;
		if( g_iUserData[i][i_TimeAFK] < 240 )
			continue;
		
		int flags = GetUserFlagBits(i);
		if (flags & ADMFLAG_GENERIC || flags & ADMFLAG_ROOT)
			continue;
		
		if( max < g_iUserData[i][i_TimeAFK_total] ) {
			client = i;
			max = g_iUserData[i][i_TimeAFK_total];
		}
	}
	if( IsValidClient(client) )
		return client;
	
	
	return 0;
}

void DoReflexive(int client) {
	float vecSrc[3], vecDest[3], angle[3], vNormal[3];
	
	GetClientEyePosition(client, vecSrc);
	GetClientEyeAngles(client, angle);
	
	int entity_to_ignore = client;
    
	for(int hit = 0; hit<3; hit++) {
		
		
		Handle trace = TR_TraceRayFilterEx(vecSrc, angle, MASK_SHOT, RayType_Infinite, TEF_ExcludeEntity, entity_to_ignore);
		if( !TR_DidHit(trace) ) {
			break;
		}
		
		TR_GetEndPosition(vecDest, trace);
		TR_GetPlaneNormal(trace, vNormal);
		entity_to_ignore = TR_GetEntityIndex(trace);
		CloseHandle(trace);
		
		if( hit != 0 ) {
			Handle dp;
			
			CreateDataTimer(float(hit)*0.01, BatchLaserSpawn, dp, TIMER_DATA_HNDL_CLOSE);
			WritePackFloat(dp, vecSrc[0]);
			WritePackFloat(dp, vecSrc[1]);
			WritePackFloat(dp, vecSrc[2]);
			
			WritePackFloat(dp, vecDest[0]);
			WritePackFloat(dp, vecDest[1]);
			WritePackFloat(dp, vecDest[2]);
			
			WritePackCell(dp, entity_to_ignore);
			WritePackCell(dp, client);
		}
		
		float vecDir[3];
		GetAngleVectors(angle, vecDir, NULL_VECTOR, NULL_VECTOR);
		
		float dotProduct = GetVectorDotProduct(vNormal, vecDir);
		ScaleVector(vNormal, dotProduct);
		ScaleVector(vNormal, 2.0);
		
		float vBounceVec[3];
		SubtractVectors(vecDir, vNormal, vBounceVec);
		GetVectorAngles(vBounceVec, angle);
		vecSrc[0] = vecDest[0];
		vecSrc[1] = vecDest[1];
		vecSrc[2] = vecDest[2];
	}
	return;
}
public bool TEF_ExcludeEntity(int entity, int contentsMask, any data) {
	return (entity != data);
}
public Action BatchLaserSpawn(Handle timer, Handle dp) {
	float vecSrc[3], vecDest[3];
	
	ResetPack(dp);
	
	vecSrc[0] = ReadPackFloat(dp);
	vecSrc[1] = ReadPackFloat(dp);
	vecSrc[2] = ReadPackFloat(dp);
	
	vecDest[0] = ReadPackFloat(dp);
	vecDest[1] = ReadPackFloat(dp);
	vecDest[2] = ReadPackFloat(dp);
	
	int ent = ReadPackCell(dp);
	int client = ReadPackCell(dp);
	
	SlatchEffect(client, vecSrc, vecDest, ent);
}
void SlatchEffect(int client, float start[3], float end[3], int entity) {
	TE_SetupBeamPoints( start, end, g_cBeam, 0, 0, 0, 0.2, 1.0, 1.0, 0, 0.0, {200, 200, 200, 50}, 0);
	TE_SendToAll();
	
	if( entity >= 0 && IsValidEntity(entity) && IsMoveAble(entity) ) {
		
		SubtractVectors(end, start, start);
		ScaleVector(start, 500.0);
		
		while( GetVectorLength(start) > 500.0 ) {
			ScaleVector(start, 0.5);
		}
		
		TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, start);
		DealDamage(entity, Math_GetRandomInt(10, 15), client);
		
		if( IsValidClient(entity) )
			rp_ClientAggroIncrement(client, entity, 12);
	}
	
	start[0] = 0.0;
	start[1] = 0.0;
	start[2] = 0.0;
	
	TE_SetupArmorRicochet(end, start);
	TE_SendToAll();
	
	TE_SetupDust(end, start, 10.0, 0.5);
	TE_SendToAll();
	
	TE_SetupMetalSparks(end, start);
	TE_SendToAll();	
}
public bool TraceRayDontHitSelf(int entity, int mask, any data) {
	if(entity == data) {
		return false; // Don't let the entity be hit
	}
	return true; // It didn't hit itself
}

void DetectionTirDangereux(int client, float B[3]) {
	
	float A[3], C[3], D[3], E, F[3], G, H;
	GetClientEyePosition(client, A);
	D[0] = B[0] - A[0];
	D[1] = B[1] - A[1];
	D[2] = B[2] - A[2];
	NormalizeVector(D, D);
	
	for (int i = 1; i <= MaxClients; i++) {
		if( !IsValidClient(i) )
			continue;
		if( i == client )
			continue;
		
		GetClientEyePosition(i, C);
		E = (D[0] * (C[0] - A[0])) + (D[1] * (C[1] - A[1])) + (D[2] * (C[2] - A[2]));
		F[0] = D[0] * E + A[0];
		F[1] = D[1] * E + A[1];
		F[2] = D[2] * E + A[2];
		G = GetVectorDistance(C, F);
		
		if( G > 64.0 && G <= 256.0 ) {
			
			GetClientAbsOrigin(i, C);
			E = (D[0] * (C[0] - A[0])) + (D[1] * (C[1] - A[1])) + (D[2] * (C[2] - A[2]));
			F[0] = D[0] * E + A[0];
			F[1] = D[1] * E + A[1];
			F[2] = D[2] * E + A[2];
			
			H = GetVectorDistance(C, F);
			
			if( H < G )
				G = H;
		}
		
		if( G <= 64.0 ) {
			g_iUserData[client][i_LastDangerousShot] = GetTime();
			break;
		}
	}
}
