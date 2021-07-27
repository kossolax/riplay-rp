#include <sourcemod>
#include <sdktools>
#include <dhooks>
#include <sdkhooks>
#include <colors_csgo>	// https://forums.alliedmods.net/showthread.php?p=2205447#post2205447
#include <smlib>

#pragma newdecls required
#include <roleplay>

#define AIM_ANGLE_CHANGE	5.0
#define AIM_MIN_DISTANCE	128.0
#define AIM_DETECTIONS		50
#define TRIGGER_DETECTIONS	5
#define CMD_DETECTIONS		10
#define TICK_DETECTIONS		128
#define SPEED_DETECTIONS 	10
#define TIME_TO_TICK(%1)	(RoundToNearest((%1) / GetTickInterval()))
#define TICK_TO_TIME(%1)	((%1) * GetTickInterval())
#define PREFIX				"[CHEATING]"

float g_fEyeAngles[MAXPLAYERS+1][255][3];
int g_iEyeIndex[MAXPLAYERS + 1];
int g_iMaxAngleHistory, g_iAttackMax;
int g_iTriggerDetections[MAXPLAYERS + 1], g_iAimDetections[MAXPLAYERS + 1], g_iTickDetections[MAXPLAYERS + 1], g_iCmdDetections[MAXPLAYERS + 1], g_iSpeedDetections[MAXPLAYERS + 1], g_iFileDetections[MAXPLAYERS + 1], g_ClientChanges[MAXPLAYERS + 1];
int g_iPrevCmdNum[MAXPLAYERS + 1], g_iPrevTickCount[MAXPLAYERS + 1];
float g_fDetectedTime[MAXPLAYERS+1], g_fPrevLatency[MAXPLAYERS+1];
int g_iTicksLeft[MAXPLAYERS+1], g_iMaxTicks;

public Plugin myinfo = {
	name = "Anti-Cheat", author = "KoSSoLaX",
	description = "Prévention et détection de cheater",
	version = "1.1", url = "https://www.ts-x.eu"
}

Handle g_cVarCheat, g_hTeleport, g_cVarEnable;
bool g_bAntiWallhack = false;
bool g_bInPVP[65], g_bCanSee[65][65];
int g_iLastZone[65], g_iLastGang[65];
float g__flLastCheck[65][65];
float g_vMins[65][3], g_vMaxs[65][3], g_vAbsCentre[65][3], g_vEyePos[65][3];

int g_iTickCount;
float g_flGameTime;
float g_flSpawnOrigin[65][3];

public void OnPluginStart() {
	
	char strIP[128];
	Handle hostip = FindConVar("hostip");
	int longip = GetConVarInt(hostip);
	Format(strIP, sizeof(strIP),"%d.%d.%d.%d", (longip >> 24) & 0xFF, (longip >> 16) & 0xFF, (longip >> 8 )	& 0xFF, longip & 0xFF);
	
	if( StrEqual(strIP, "5.196.39.50") ) { 
		if( GetConVarInt(FindConVar("hostport")) != 27015 ) {
			SetFailState("test serv");
			return;
		}
	}
	
	AddCommandListener(OnCommand);
	AddCommandListener(OnCheatCommand, "noclip");
	AddCommandListener(OnCheatCommand, "god");
	AddCommandListener(OnCheatCommand, "give");
	AddCommandListener(OnCheatCommand, "ent_create");
	AddCommandListener(OnCheatCommand, "ent_remove");
	AddCommandListener(OnCrashCommand, "survival_equip");
	
	char name[128];
	int flags;
	bool isCommand;
	Handle cvar = FindFirstConCommand(name, sizeof(name), isCommand, flags);
	do {
		if ( isCommand && (flags & FCVAR_CHEAT)) {
			AddCommandListener(OnCheatCommand, name);
			LogToGame("[CHEAT-CMD] Hooked %s", name);
		}
	} while( FindNextConCommand(cvar, name, sizeof(name), isCommand, flags) );
	
	g_cVarCheat = FindConVar("sv_cheats");
	
	if( (g_iMaxAngleHistory = TIME_TO_TICK(0.5)) > sizeof(g_fEyeAngles[]) ) {
		g_iMaxAngleHistory = sizeof(g_fEyeAngles[]);
	}
	g_iAttackMax = RoundToNearest(1.0 / GetTickInterval() / 3.0);
	g_iMaxTicks = RoundToCeil(1.0 / GetTickInterval() * 2.0);
	for( int i = 0; i < sizeof(g_iTicksLeft); i++) {
		g_iTicksLeft[i] = g_iMaxTicks;
	}
	
	CreateTimer(60.0, Timer_DecreaseCount, _, TIMER_REPEAT);
	
	Handle hGameData = LoadGameConfigFile("sdktools.games");
	int iOffset = GameConfGetOffset(hGameData, "Teleport");
	
	if(iOffset != -1) {
		g_hTeleport = DHookCreate(iOffset, HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity, DHooks_OnTeleport);
		DHookAddParam(g_hTeleport, HookParamType_VectorPtr);
		DHookAddParam(g_hTeleport, HookParamType_VectorPtr);
		DHookAddParam(g_hTeleport, HookParamType_VectorPtr);
		DHookAddParam(g_hTeleport, HookParamType_Bool);
	}
	HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post);
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Post);
	
	g_cVarEnable = CreateConVar("rp_wallhack", "1");
	HookConVarChange(g_cVarEnable, OnCvarChange);
	if( GetConVarInt(g_cVarEnable) == 1 ) {
		g_bAntiWallhack = true;
		for(int i=1; i<=MaxClients; i++) {
			if( !IsValidClient(i) )
				continue;
			
			rp_HookEvent(i, RP_OnPlayerZoneChange, fwdZoneChange);
			if( rp_GetZoneBit( rp_GetPlayerZone(i) ) & BITZONE_PVP || rp_GetZoneBit( rp_GetPlayerZone(i) ) & BITZONE_EVENT ) {
				g_bInPVP[i] = true;
				SDKHook(i, SDKHook_SetTransmit, Hook_Transmit);
			}
		}
	}
	
	for(int i=1; i<=MaxClients; i++) {
		if( !IsValidClient(i) || IsClientSourceTV(i) || IsFakeClient(i) )
			continue;
		OnClientPostAdminCheck(i)
	}
	
	int flag = GetConVarFlags(FindConVar("weapon_recoil_scale"));
	flag &= ~FCVAR_CHEAT;
	SetConVarFlags(FindConVar("weapon_recoil_scale"), flag);
}

public void OnCvarChange(Handle cvar, const char[] oldVal, const char[] newVal) {
	if( cvar == g_cVarEnable ) {
		if( !g_bAntiWallhack && StrEqual(newVal, "1") ) {
			g_bAntiWallhack = true;
			for(int i=1; i<=MaxClients; i++) {
				if( !IsValidClient(i) )
					continue;
				rp_HookEvent(i, RP_OnPlayerZoneChange, fwdZoneChange);
				if( rp_GetZoneBit( rp_GetPlayerZone(i) ) & BITZONE_PVP || rp_GetZoneBit( rp_GetPlayerZone(i) ) & BITZONE_EVENT ) {
					g_bInPVP[i] = true;
					SDKHook(i, SDKHook_SetTransmit, Hook_Transmit);
				}
			}
		}
		else if( g_bAntiWallhack && StrEqual(newVal, "0") ) {
			g_bAntiWallhack = false;
			
			for(int i=1; i<=MaxClients; i++) {
				if( !IsValidClient(i) )
					continue;
				rp_UnhookEvent(i, RP_OnPlayerZoneChange, fwdZoneChange);
				
				if( g_bInPVP[i] )
					SDKUnhook(i, SDKHook_SetTransmit, Hook_Transmit);
			}
		}
	}
}
public void OnClientPostAdminCheck(int client) {
	int flags = GetUserFlagBits(client);
	
	if ( !(flags & ADMFLAG_ROOT) && GetConVarInt(FindConVar("hostport")) == 27015 ) {
		SendConVarValue(client, g_cVarCheat, "0");
		CreateTimer(60.0, task_ClientCheckConVar, GetClientUserId(client));
	}
	
	g_iAimDetections[client] = g_iTriggerDetections[client] = g_iCmdDetections[client] = g_iSpeedDetections[client] = 0;
	g_iPrevCmdNum[client] = g_iPrevTickCount[client] = 0;
	g_iTicksLeft[client] = g_iMaxTicks;
	g_fDetectedTime[client] = g_fPrevLatency[client] = 0.0;
	
	Aimbot_ClearAngles(client);
	
	if( g_bAntiWallhack ) {
		rp_HookEvent(client, RP_OnPlayerZoneChange, fwdZoneChange);
	}
}
public void OnGameFrame() {	
	g_iTickCount = GetGameTickCount();
	g_flGameTime = GetGameTime();
}
// ------------------------------------------------- WALLHACK --------------------
public Action fwdZoneChange(int client, int newZone, int oldZone) {
	int bit = rp_GetZoneBit(newZone);
	bool IsInPvP = (bit & BITZONE_PVP) || (bit & BITZONE_EVENT);
	
	g_iLastGang[client] = rp_GetClientGroupID(client);
	g_iLastZone[client] = newZone;
	
	if( IsInPvP && !g_bInPVP[client] ) {
		SDKHook(client, SDKHook_SetTransmit, Hook_Transmit);
	}
	else if( !IsInPvP && g_bInPVP[client] ) {
		SDKUnhook(client, SDKHook_SetTransmit, Hook_Transmit);
	}
	g_bInPVP[client] = IsInPvP;
}
public Action Hook_Transmit(int client, int target) {
	if( client == target ) 
		return Plugin_Continue;
	
	if( g_bInPVP[client] && g_bInPVP[target] ) {
		
		if( g_iLastGang[client] == g_iLastGang[target] && g_iLastGang[client] != 0 ) {
			return Plugin_Continue;
		}
		if( g_bCanSee[client][target] || g_bCanSee[target][client] ) {
			if( g__flLastCheck[client][target]+1.0 > g_flGameTime ) {
				return Plugin_Continue;
			}
		}
		else {
			if( g__flLastCheck[client][target]+0.1 > g_flGameTime ) {
				return Plugin_Handled;
			}
		}
		
		UpdateClientData(client);
		UpdateClientData(target);
		
		bool seeAble = IsAbleToSee(client, target);
		g_bCanSee[client][target] = g_bCanSee[target][client] = seeAble;
		g__flLastCheck[client][target] = g__flLastCheck[target][client] = g_flGameTime;
		if( !seeAble ) {
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}
// ------------------------------------------------- CHEAT-CMD --------------------
public Action OnCheatCommand(int client, const char[] command, int argc) {
	LogToGame("[CHEAT-CMD] %L used command: %s", client, command);
	
	int flags = GetUserFlagBits(client);
	if( !(flags & ADMFLAG_ROOT) ) {
		return Plugin_Handled;
	}

	return Plugin_Continue;
}
public Action OnCommand(int client, const char[] command, int argc) {
	if(StrEqual(command, "survival_equip")) {
		ServerCommand("amx_ban \"#%i\" \"0\" \"%s\"", GetClientUserId(client), "CRASH SERVEUR (banned cmd)");
		return Plugin_Handled;
	}

	return Plugin_Continue;
}
public Action OnCrashCommand(int client, const char[] command, int argc) {
	ServerCommand("amx_ban \"#%i\" \"0\" \"%s\"", GetClientUserId(client), "CRASH SERVEUR (banned cmd)");

	return Plugin_Handled;
}
public Action OnFileSend(int client, const char[] sFile) {
	g_iFileDetections[client]++;
	
	if( g_iFileDetections[client] >= 64 ) {
		ServerCommand("amx_ban \"#%i\" \"0\" \"%s\"", GetClientUserId(client), "CRASH SERVEUR (spam download)");
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}
public Action OnFileReceive(int client, const char[] sFile) {
	g_iFileDetections[client]++;
	
	if( g_iFileDetections[client] >= 64 ) {
		ServerCommand("amx_ban \"#%i\" \"0\" \"%s\"", GetClientUserId(client), "CRASH SERVEUR (spam upload)");
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}
public void OnClientSettingsChanged(int client) {
	g_ClientChanges[client]++;
	
	if( g_ClientChanges[client] >= 4096 ) {
		ServerCommand("amx_ban \"#%i\" \"0\" \"%s\"", GetClientUserId(client), "CRASH SERVEUR (spam cvar)");
		return;
	}
}
public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2]) {
	static int iAttackAmt[MAXPLAYERS + 1], iPrevButtons[MAXPLAYERS + 1];
	static bool bResetNext[MAXPLAYERS+1];
	
	if( IsFakeClient(client) )
		return Plugin_Continue;
	
	int wep_id = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if( !IsValidEdict(wep_id) ) {
		wep_id = Client_GetWeapon(client, "weapon_fists");
		if( IsValidEdict(wep_id) ) {
			Client_SetActiveWeapon(client, wep_id);
		}
		else {
			wep_id = GivePlayerItem(client, "weapon_fists");
			EquipPlayerWeapon(client, wep_id);
		}
		return Plugin_Handled;
	}
	
	if( tickcount == 2147483647 && g_iPrevTickCount[client] == 2147483647 ) {
		LogToGame(PREFIX ... " [AIR-STUCK] %L", client);
		PrintToChatAll("[ANTI-CHEAT] %L est tellement mauvais qu'il utilise un %s... et s'est fait grillé.", client, "speedhack");
		ServerCommand("amx_ban \"#%i\" \"0\" \"%s\"", GetClientUserId(client), "CRASH SERVEUR (tickcount)");
		return Plugin_Handled;
	}
	
	if( impulse != 0 ) {
		LogToGame(PREFIX ... " [CHEAT] %L impulse %d", client, impulse);
		impulse = 0;
		return Plugin_Handled;
	}
	
	if( IsBadCoordLong(vel[0]) || IsBadCoordLong(vel[1]) || IsBadCoordLong(vel[2]) ) {
		LogToGame(PREFIX ... " [CRASH-VELOCITY] %L %.1f %.1f %.1f", client, vel[0], vel[1], vel[2]);
		return Plugin_Handled;
	}
	if( IsBadAngleLong(angles[0]) || IsBadAngleLong(angles[1]) || IsBadAngleLong(angles[2]) ) {
		LogToGame(PREFIX ... " [CRASH-ANGLES] %L %.1f %.1f %.1f", client, angles[0], angles[1], angles[2]);
		PrintToChatAll("[ANTI-CHEAT] %L est tellement mauvais qu'il utilise un %s... et s'est fait grillé.", client, "aimbot");
		ServerCommand("amx_ban \"#%i\" \"0\" \"%s\"", GetClientUserId(client), "CRASH SERVEUR (inf angle)");
		return Plugin_Handled;
	}
	
	if( g_iPrevCmdNum[client] > cmdnum ) {
		g_iCmdDetections[client]++;
		if( g_iCmdDetections[client] > CMD_DETECTIONS )
			LogToGame(PREFIX ... " [BAD-CMD-NUM] %L %d~%d", client, g_iPrevCmdNum[client], cmdnum);
	}
	if( g_iPrevTickCount[client] > tickcount && g_iPrevTickCount[client]-16 > cmdnum ) {
		g_iTickDetections[client]++;
		if( g_iTickDetections[client] > TICK_DETECTIONS ) {
			LogToGame(PREFIX ... " [BAD-TICK-NUM] %L %d~%d", client, g_iPrevTickCount[client], tickcount);
			g_iTickDetections[client] = 0;
		}
	}
	
	g_iPrevCmdNum[client] = cmdnum;
	g_iPrevTickCount[client] = tickcount;
	g_fEyeAngles[client][g_iEyeIndex[client]] = angles;
	
	if (++g_iEyeIndex[client] == g_iMaxAngleHistory) {
		g_iEyeIndex[client] = 0;
	}
		
	if( g_iTicksLeft[client] )
		g_iTicksLeft[client]--;
	
	if (((buttons & IN_ATTACK) && !(iPrevButtons[client] & IN_ATTACK)) ||  (!(buttons & IN_ATTACK) && (iPrevButtons[client] & IN_ATTACK))) {
		if (++iAttackAmt[client] >= g_iAttackMax) {
			AutoTrigger_Detected(client);
			iAttackAmt[client] = 0;
		}
		
		bResetNext[client] = false;
	}
	else if (bResetNext[client]) {
		iAttackAmt[client] = 0;
		bResetNext[client] = false;
	}
	else {
		bResetNext[client] = true;
	}

	iPrevButtons[client] = buttons;
	return Plugin_Continue;
}
// ------------------------------------------------- CON-VAR --------------------
public Action task_ClientCheckConVar(Handle timer, any client) {
	client = GetClientOfUserId(client);
	if( client == 0 )
		return Plugin_Handled;
	
	
	QueryClientConVar(client, "sv_cheats", ClientConVar, 0);
	QueryClientConVar(client, "r_drawothermodels",ClientConVar, 1);
	QueryClientConVar(client, "mat_wireframe", ClientConVar, 0);
	QueryClientConVar(client, "r_drawrenderboxes", ClientConVar, 0);
	
	CreateTimer(GetRandomFloat(60.0, 120.0), task_ClientCheckConVar, GetClientUserId(client));
	return Plugin_Continue;
}
public void ClientConVar(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue, any value) {
	char tmp[12];
	Format(tmp, sizeof(tmp), "%d", value);
	
	if( !StrEqual(cvarValue, tmp) || result == ConVarQuery_Protected ) {
		LogToGame(PREFIX ... " [CONVAR] %L %s %s", client, cvarName, cvarValue);
		SendConVarValue(client, FindConVar(cvarName), tmp);
	}
} 
// ------------------------------------------------- AIM-BOT --------------------
public MRESReturn DHooks_OnTeleport(int client, Handle hParams) {
 	Aimbot_ClearAngles(client);
 	return MRES_Ignored;
 }
void Aimbot_ClearAngles(int client) {
	g_iEyeIndex[client] = 0;
	
	for (int i = 0; i < g_iMaxAngleHistory; i++) {
		ZeroVector(g_fEyeAngles[client][i]);
	}
}
public Action Aimbot_ClearAnglesTimer(Handle timer, any client) {
	client = GetClientOfUserId(client);
	if( client != 0 )
		Aimbot_ClearAngles(client);
}
public Action Event_PlayerSpawn(Handle ev, const char[] name, bool broadcast) {
	int client = GetClientOfUserId(GetEventInt(ev, "userid"));
	Aimbot_ClearAngles(client);
	CreateTimer(0.1, Aimbot_ClearAnglesTimer, GetClientUserId(client));
}
public Action Event_PlayerDeath(Handle event, const char[] name, int dontBroadcast) {
	
	int victim = GetClientOfUserId(GetEventInt(event, "userid"));
	char sWeapon[32];
	GetEventString(event, "weapon", sWeapon, sizeof(sWeapon));
	
	if( StrContains(sWeapon, "weapon_") == 0 && StrContains(sWeapon, "weapon_knife") == -1 &&  StrContains(sWeapon, "weapon_bayonet") == -1 ) {
		
		int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
		
		if( IsValidClient(attacker) && victim != attacker ) {
			float vOrigin[3], aOrigin[3];
			GetClientAbsOrigin(victim, vOrigin);
			GetClientAbsOrigin(attacker, aOrigin);
			
			if( GetVectorDistance(vOrigin, aOrigin) >= AIM_MIN_DISTANCE ) {
				Aimbot_AnalyzeAngles(attacker);
			}
		}
	}
	GetClientAbsOrigin(victim, g_flSpawnOrigin[victim]);
}
void Aimbot_AnalyzeAngles(int client) {
	float vLastAngles[3], vAngles[3], fAngleDiff;
	int idx = g_iEyeIndex[client];
	
	for (int i = 0; i < g_iMaxAngleHistory; i++) {
		if (idx == g_iMaxAngleHistory) {
			idx = 0;
		}
			
		if( IsVectorZero(g_fEyeAngles[client][idx]) ) {
			break;
		}
		
		if (i == 0) {
			vLastAngles = g_fEyeAngles[client][idx];
			idx++;
			continue;
		}
		
		vAngles = g_fEyeAngles[client][idx];
		fAngleDiff = GetVectorDistance(vLastAngles, vAngles);
		
		if (fAngleDiff > 180) {
			fAngleDiff = FloatAbs(fAngleDiff - 360);
		}

		if (fAngleDiff > AIM_ANGLE_CHANGE) {
			Aimbot_Detected(client, fAngleDiff);
			break;
		}
		
		vLastAngles = vAngles;
		idx++;
	}
}
// ------------------------------------------------- REPORTS --------------------
void Aimbot_Detected(int client, float deviation) {
	if (IsFakeClient(client) || !IsPlayerAlive(client))
		return;
	
	g_iAimDetections[client]++;
	LogToGame(PREFIX ... " [AIMBOT?] %L %f", client, deviation);
	if( g_iAimDetections[client] >= AIM_DETECTIONS ) {
		LogToGame(PREFIX ... " [AIMBOT] %L %f", client, deviation);
	}
}
void AutoTrigger_Detected(int client) {
	g_iTriggerDetections[client]++;
	LogToGame(PREFIX ... " [TRIGGER?] %L %d", client, g_iTriggerDetections[client]);
	if( g_iTriggerDetections[client] >= TRIGGER_DETECTIONS ) {
		LogToGame(PREFIX ... " [TRIGGER] %L %d", client, g_iTriggerDetections[client]);
		PrintToChatAll("[ANTI-CHEAT] %L est tellement mauvais qu'il utilise un %s... et s'est fait grillé.", client, "trigger");
		KickClient(client, "cheater");
	}
}
// ------------------------------------------------- UTILS --------------------
public Action Timer_DecreaseCount(Handle timer) {
	for (int i = 1; i <= MaxClients; i++) {
		if( g_iAimDetections[i] > 0 )
			g_iAimDetections[i]--;
		if( g_iTriggerDetections[i] > 0 )
			g_iTriggerDetections[i]--;
		if( g_iCmdDetections[i] > 0 )
			g_iCmdDetections[i]--;
		if( g_iTickDetections[i] >= 32 )
			g_iTickDetections[i] -= 32;
		if( g_iFileDetections[i] >= 32 )
			g_iFileDetections[i] -= 32;
		if( g_ClientChanges[i] >= 0 )
			g_ClientChanges[i] -= 128;
	}
}
bool IsBadCoordLong(float vel) {
	return vel > 131072.0 || vel < -131072.0;
}
bool IsBadAngleLong(float angle) {
    return angle > 360.0 || angle < -360.0;
}
void ZeroVector(float vec[3]) {
	vec[0] = vec[1] = vec[2] = 0.0;
}
bool IsVectorZero(float vec[3]) {
	return vec[0] == 0.0 && vec[1] == 0.0 && vec[2] == 0.0;
}

bool IsAbleToSee(int entity, int client) {
	
	// Check if centre is visible.
	if (IsPointVisible(g_vEyePos[client], g_vAbsCentre[entity]))
		return true;
		
	// Check outer 4 corners of player.
	if (IsRectangleVisible(g_vEyePos[client], g_vAbsCentre[entity], g_vMins[entity], g_vMaxs[entity], 1.10))
		return true;
	
	// Check inner 4 corners of player.
	if (IsRectangleVisible(g_vEyePos[client], g_vAbsCentre[entity], g_vMins[entity], g_vMaxs[entity], 0.9))
		return true;
	
	return false;
}
bool IsRectangleVisible(const float start[3], const float end[3], const float mins[3], const float maxs[3], float scale=1.0) {
	static float angles[3], fwd[3], right[3];
	static float vRectangle[4][3], vTemp[3];
	static float ZpozOffset, ZnegOffset, WideOffset;
	
	ZnegOffset = mins[2];
	ZpozOffset = maxs[2];
	WideOffset = ((maxs[0] - mins[0]) + (maxs[1] - mins[1])) / 4.0;
	
	// This rectangle is just a point!
	if (ZpozOffset == 0.0 && ZnegOffset == 0.0 && WideOffset == 0.0) {
		return IsPointVisible(start, end);
	}

	// Adjust to scale.
	ZpozOffset *= scale;
	ZnegOffset *= scale;
	WideOffset *= scale;
	
	// Prepare rotation matrix.
	SubtractVectors(start, end, fwd);
	NormalizeVector(fwd, fwd);

	GetVectorAngles(fwd, angles);
	GetAngleVectors(angles, fwd, right, NULL_VECTOR);
	
	// If the player is on the same level as us, we can optimize by only rotating on the z-axis.
	if (FloatAbs(fwd[2]) <= 0.7071) {
		ScaleVector(right, WideOffset);
		
		// Corner 1, 2
		vTemp = end;
		vTemp[2] += ZpozOffset;
		AddVectors(vTemp, right, vRectangle[0]);
		SubtractVectors(vTemp, right, vRectangle[1]);
		
		// Corner 3, 4
		vTemp = end;
		vTemp[2] += ZnegOffset;
		AddVectors(vTemp, right, vRectangle[2]);
		SubtractVectors(vTemp, right, vRectangle[3]);
	}
	else if (fwd[2] > 0.0) {
		fwd[2] = 0.0;
		NormalizeVector(fwd, fwd);
		
		ScaleVector(fwd, scale);
		ScaleVector(fwd, WideOffset);
		ScaleVector(right, WideOffset);
		
		// Corner 1
		vTemp = end;
		vTemp[2] += ZpozOffset;
		AddVectors(vTemp, right, vTemp);
		SubtractVectors(vTemp, fwd, vRectangle[0]);
		
		// Corner 2
		vTemp = end;
		vTemp[2] += ZpozOffset;
		SubtractVectors(vTemp, right, vTemp);
		SubtractVectors(vTemp, fwd, vRectangle[1]);
		
		// Corner 3
		vTemp = end;
		vTemp[2] += ZnegOffset;
		AddVectors(vTemp, right, vTemp);
		AddVectors(vTemp, fwd, vRectangle[2]);
		
		// Corner 4
		vTemp = end;
		vTemp[2] += ZnegOffset;
		SubtractVectors(vTemp, right, vTemp);
		AddVectors(vTemp, fwd, vRectangle[3]);
	}
	else {
		fwd[2] = 0.0;
		NormalizeVector(fwd, fwd);
		
		ScaleVector(fwd, scale);
		ScaleVector(fwd, WideOffset);
		ScaleVector(right, WideOffset);

		// Corner 1
		vTemp = end;
		vTemp[2] += ZpozOffset;
		AddVectors(vTemp, right, vTemp);
		AddVectors(vTemp, fwd, vRectangle[0]);
		
		// Corner 2
		vTemp = end;
		vTemp[2] += ZpozOffset;
		SubtractVectors(vTemp, right, vTemp);
		AddVectors(vTemp, fwd, vRectangle[1]);
		
		// Corner 3
		vTemp = end;
		vTemp[2] += ZnegOffset;
		AddVectors(vTemp, right, vTemp);
		SubtractVectors(vTemp, fwd, vRectangle[2]);
		
		// Corner 4
		vTemp = end;
		vTemp[2] += ZnegOffset;
		SubtractVectors(vTemp, right, vTemp);
		SubtractVectors(vTemp, fwd, vRectangle[3]);
	}

	// Run traces on all corners.
	for (int i = 0; i < 4; i++) {
		if (IsPointVisible(start, vRectangle[i])) {
			return true;
		}
	}

	return false;
}
bool IsPointVisible(const float start[3], const float end[3]) {
	TR_TraceRayFilter(start, end, MASK_VISIBLE, RayType_EndPoint, Filter_NoPlayers);
	
	return (TR_GetFraction() == 1.0);
}
public bool Filter_NoPlayers(int entity, int mask) {
	return entity > MaxClients;
}
public bool Filter_WorldOnly(int entity, int mask) {
	return false;
}
void UpdateClientData(int client) {
	static iLastCached[MAXPLAYERS+1];
	if (iLastCached[client] == g_iTickCount)
		return;
	
	iLastCached[client] = g_iTickCount;
	
	GetClientMins(client, g_vMins[client]);
	GetClientMaxs(client, g_vMaxs[client]);
	GetClientAbsOrigin(client, g_vAbsCentre[client]);
	GetClientEyePosition(client, g_vEyePos[client]);
	
	// Adjust vectors relative to the model's absolute centre.
	g_vMaxs[client][2] /= 2.0;
	g_vMins[client][2] -= g_vMaxs[client][2];
	g_vAbsCentre[client][2] += g_vMaxs[client][2];

	// Adjust vectors based on the clients velocity.
	float vVelocity[3];
	Entity_GetAbsVelocity(client, vVelocity);
	
	if (!IsVectorZero(vVelocity)) {
		// Lag compensation.
		int iTargetTick;
		
		// Based on CLagCompensationManager::StartLagCompensation.
		float fCorrect = GetClientLatency(client, NetFlow_Outgoing);
		int iLerpTicks = TIME_TO_TICK(GetEntPropFloat(client, Prop_Data, "m_fLerpTime"));
		
		// Assume sv_maxunlag == 1.0f seconds.
		fCorrect += TICK_TO_TIME(iLerpTicks);
		fCorrect = Math_Clamp(fCorrect, 0.0, 1.0);
		iTargetTick = g_iPrevTickCount[client] - iLerpTicks;
			
		if (FloatAbs(fCorrect - TICK_TO_TIME(g_iTickCount - iTargetTick)) > 0.2) {
			// Difference between cmd time and latency is too big > 200ms.
			// Use time correction based on latency.
			iTargetTick = g_iTickCount - TIME_TO_TICK(fCorrect);
		}
		
		// Use velocity before it's modified.
		float vTemp[3];
		vTemp[0] = FloatAbs(vVelocity[0]) * 0.01;
		vTemp[1] = FloatAbs(vVelocity[1]) * 0.01;
		vTemp[2] = FloatAbs(vVelocity[2]) * 0.01;
		
		// Calculate predicted positions for the next frame.
		float vPredicted[3];
		ScaleVector(vVelocity, TICK_TO_TIME((g_iTickCount - iTargetTick) * 1));
		AddVectors(g_vAbsCentre[client], vVelocity, vPredicted);
		
		// Make sure the predicted position is still inside the world.
		TR_TraceHullFilter(vPredicted, vPredicted, view_as<float>({-5.0, -5.0, -5.0}), view_as<float>({5.0, 5.0, 5.0}), MASK_PLAYERSOLID_BRUSHONLY, Filter_WorldOnly);
		
		if (!TR_DidHit()) {
			g_vAbsCentre[client] = vPredicted;
			AddVectors(g_vEyePos[client], vVelocity, g_vEyePos[client]);
		}
		
		// Expand the mins/maxs to help smooth during fast movement.
		if (vTemp[0] > 1.0) {
			g_vMins[client][0] *= vTemp[0];
			g_vMaxs[client][0] *= vTemp[0];
		}
		if (vTemp[1] > 1.0) {
			g_vMins[client][1] *= vTemp[1];
			g_vMaxs[client][1] *= vTemp[1];
		}
		if (vTemp[2] > 1.0) {
			g_vMins[client][2] *= vTemp[2];
			g_vMaxs[client][2] *= vTemp[2];
		}
	}
}