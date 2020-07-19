#pragma semicolon 1

#define GAME_CSGO

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <colors_csgo>
#include <smlib>
#include <voiceware>
#include <cstrike>
#include <emitsoundany.inc>

#include <roleplay>

public Plugin:myinfo = 
{
	name = "TESTING", 
	author = "KoSSoLaX", 
	description = "<- Description ->", 
	version = "0.1", 
	url = "<- URL ->"
}

new OCCclient;
new LaserCache;

public Action sound_hook2(char sample[PLATFORM_MAX_PATH], int &entity, float & volume, int &level, int &pitch, float pos[3], int &flags, float & delay) {
	//PrintToChat(3, "AMBIANT: %s", sample);
	return Plugin_Continue;
}
public Action sound_hook(int clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags) {
	//PrintToChat(3, "NORMAL: %s", sample);
	
	if (StrContains(sample, "knife_slash") >= 0) {
		volume = 0.1;
		return Plugin_Changed;
	}
	
	return Plugin_Continue;
}
public OnPluginStart() {
	
	RegAdminCmd("sm_effect_copter", Cmd_Copter, ADMFLAG_ROOT);
	RegAdminCmd("sm_effect_copter2", Cmd_Copter, ADMFLAG_ROOT);
	
	for (new i = 1; i <= MaxClients; i++) {
		if (!IsValidClient(i))
			continue;
		
	//	SDKHook(i, SDKHook_PostThinkPost, think);
	}
	
	AddMultiTargetFilter("@near", JoueurProche, "a proximite", false);
	AddMultiTargetFilter("@zone", JoueurZone, "zone", false);
	AddMultiTargetFilter("@admin", LesAdmins, "admin", false);
	AddMultiTargetFilter("@bot", LesBots, "bots", false);
	AddMultiTargetFilter("@afk", LesAFK, "afk", false);	
	
	
	RegAdminCmd("sm_effect_voice", Cmd_VoiceToAll, ADMFLAG_ROOT);
	RegAdminCmd("sm_effect_instructor", Cmd_Instructor, ADMFLAG_ROOT);
	RegAdminCmd("sm_bot_add", Cmd_AddBot, ADMFLAG_ROOT);
	
	
	RegAdminCmd("sm_test", Cmd_Test2, ADMFLAG_ROOT);
	RegAdminCmd("sm_effect_mask", Cmd_SetMask, ADMFLAG_ROOT);
	
	AddTempEntHook("EffectDispatch", Hook);
	
	AddNormalSoundHook(sound_hook);
	AddAmbientSoundHook(sound_hook2);
	
	for (int i = 1; i <= MaxClients; i++) {
		if (rp_GetClientBool(i, b_isConnected) && !IsClientInGame(i))
			rp_SetClientBool(i, b_isConnected, false);
		
	}
}
public Action Cmd_AddBot(int client, int args) {
	char name[32], skin[128];
	
	GetCmdArg(1, name, sizeof(name));
	
	int entity = CreateFakeClient(name);
	CS_SwitchTeam(entity, GetClientTeam(client));
	CS_RespawnPlayer(entity);
	SetEntProp(entity, Prop_Data, "m_takedamage", 2);
	SetEntPropFloat(entity, Prop_Data, "m_flLaggedMovementValue", 1.75);
	
	float pos[3];
	Entity_GetAbsOrigin(client, pos);
	Entity_GetModel(client, skin, sizeof(skin));
	Entity_SetModel(entity, skin);
	TeleportEntity(entity, pos, NULL_VECTOR, NULL_VECTOR);
	FakeClientCommand(client, "sm_setpuppet #%d", GetClientUserId(entity));
	return Plugin_Handled;
}
public Action Cmd_Instructor(int client, int args) {
	char text[255], tip[32];
	GetCmdArg(1, tip, sizeof(tip));
	GetCmdArg(2, text, sizeof(text));
	L4D2_CreateInstructorHint(tip, client, text, { 255, 255, 255 }, tip, tip, tip, 0.0, 0.0, 5);
	return Plugin_Handled;
}
public void OnEntityCreated(int entity, const char[] classname) {
	if (!StrEqual(classname, "tagrenade_projectile"))
		return;
	
	SDKHook(entity, SDKHook_Spawn, OnTagrenadeProjectileSpawned);
}

public Action OnTagrenadeProjectileSpawned(int entity)
{
	static int g_offCollisionGroup;
	if (g_offCollisionGroup == -1) {
		g_offCollisionGroup = FindSendPropInfo("CBaseEntity", "m_CollisionGroup");
		if (g_offCollisionGroup == -1)
			return Plugin_Continue;
	}
	SetEntData(entity, g_offCollisionGroup, 2, 4, true);
	return Plugin_Continue;
}

#define L4D2_IHFLAG_STATIC              (1 << 8)

bool L4D2_CreateInstructorHint(const char[] name, int target = 0, const char[] caption, color[3] =  { 255, 255, 255 }, const char[] iconOnScreen = "icon_tip", const char[] iconOffScreen = "icon_tip", const char[] binding = "", float iconOffset = 0.0, float range = 0.0, int timeout = 0, 	bool allowNoDrawTarget = true, 	bool noOffScreen = false, 	bool forceCaption = false, 
	int flags = L4D2_IHFLAG_STATIC) {
	Handle event = CreateEvent("instructor_server_hint_create", true);
	if (event == INVALID_HANDLE) {
		return false;
	}
	
	char finalizedColor[16];
	Format(finalizedColor, 16, "%d,%d,%d", color[0], color[1], color[2]);
	
	SetEventString(event, "hint_name", name);
	SetEventInt(event, "hint_target", target);
	SetEventString(event, "hint_caption", caption);
	SetEventString(event, "hint_color", finalizedColor);
	SetEventString(event, "hint_icon_onscreen", iconOnScreen);
	SetEventString(event, "hint_icon_offscreen", iconOffScreen);
	SetEventString(event, "hint_binding", binding);
	SetEventFloat(event, "hint_icon_offset", iconOffset);
	SetEventFloat(event, "hint_range", range);
	SetEventInt(event, "hint_timeout", timeout);
	SetEventBool(event, "hint_allow_nodraw_target", allowNoDrawTarget);
	SetEventBool(event, "hint_nooffscreen", noOffScreen);
	SetEventBool(event, "hint_forcecaption", forceCaption);
	SetEventInt(event, "hint_flags", flags);
	FireEvent(event);
	
	return true;
}
bool L4D2_StopInstructorHint(const char[] name) {
	Handle event = CreateEvent("instructor_server_hint_stop", true);
	if (event == INVALID_HANDLE) {
		return false;
	}
	
	SetEventString(event, "hint_name", name);
	FireEvent(event);
	return true;
}
public Action Cmd_Copter(client, args) {
	float vecStart[3], vecEnd[3], vecDest[3], vecAngles[3], vecDir[3];
	vecDir[0] = (args == 0 ? Math_GetRandomFloat(-3250.0, 2000.0) : GetCmdArgFloat(1));
	vecDir[1] = (args == 0 ? Math_GetRandomFloat(-5000.0, 900.0) : GetCmdArgFloat(2));
	
	char cmd[32];
	GetCmdArg(0, cmd, sizeof(cmd));
	if( StrEqual(cmd, "sm_effect_copter2") ) {
		client = GetCmdArgInt(3);
	}
	else if (args > 2) {
		vecDir[0] += Math_GetRandomFloat(-GetCmdArgFloat(3), GetCmdArgFloat(3));
		vecDir[1] += Math_GetRandomFloat(-GetCmdArgFloat(3), GetCmdArgFloat(3));
	}
	
	vecStart[0] = vecDir[0];
	vecStart[1] = vecDir[1];
	vecStart[2] = vecEnd[2] = -1000.0;
	
	vecAngles[1] = Math_GetRandomFloat(0.0, 360.0);
	Handle tr = TR_TraceRayEx(vecStart, vecAngles, MASK_SHOT, RayType_Infinite);
	if (!TR_DidHit(tr)) {
		CloseHandle(tr);
		return Plugin_Handled;
	}
	TR_GetEndPosition(vecStart, tr);
	CloseHandle(tr);
	
	vecAngles[1] += 180.0;
	if (vecAngles[1] > 360.0)
		vecAngles[1] -= 360.0;
	tr = TR_TraceRayEx(vecStart, vecAngles, MASK_SHOT, RayType_Infinite);
	if (!TR_DidHit(tr)) {
		CloseHandle(tr);
		return Plugin_Handled;
	}
	TR_GetEndPosition(vecEnd, tr);
	CloseHandle(tr);
	
	vecDest[0] = vecDir[0];
	vecDest[1] = vecDir[1];
	vecDest[2] = vecEnd[2];
	if (client > 0) {
		
		float tmp[3]; GetClientAbsOrigin(client, tmp);
		TE_SetupBeamPoints(vecDest, tmp, LaserCache, 0, 0, 0, 7.5, 1.0, 10.0, 0, 0.0, { 250, 0, 0, 250 }, 20);
		TE_SendToClient(client);
		
		TE_SetupBeamRingPoint(vecDest, 50.0, 250.0, LaserCache, 0, 0, 30, 7.5, 20.0, 0.0, { 255, 0, 0, 100 }, 10, 0);
		TE_SendToClient(client);
	}
	
	
	GetAngleVectors(vecAngles, vecDir, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(vecDir, 800.0);
	
	int ent = CreateEntityByName("hegrenade_projectile");
	int ent2 = CreateEntityByName("prop_dynamic");
//	int ent3 = CreateEntityByName("env_projectedtexture");
	
	DispatchKeyValue(ent, "classname", "rp_copter");
	DispatchKeyValue(ent2, "model", "models/props_vehicles/helicopter_rescue.mdl");
	DispatchKeyValue(ent2, "DefaultAnim", "3ready");
/*	DispatchKeyValue(ent3, "farz", "5000");
	DispatchKeyValue(ent3, "texturename", "effects/flashlight001_intro");
	DispatchKeyValue(ent3, "lightcolor", "255 0 0 2000");
	DispatchKeyValue(ent3, "spawnflags", "3");
	DispatchKeyValue(ent3, "lightfov", "10");
	DispatchKeyValue(ent3, "brightnessscale", "50");
*/	
	DispatchSpawn(ent);
	DispatchSpawn(ent2);
//	DispatchSpawn(ent3);
	
	SetEntityMoveType(ent, MOVETYPE_NOCLIP);
	
	SetVariantString("!activator");
	rp_AcceptEntityInput(ent2, "SetParent", ent);
//	SetVariantString("!activator");
//	rp_AcceptEntityInput(ent3, "SetParent", ent);
	
	TeleportEntity(ent, vecStart, vecAngles, vecDir);
	TeleportEntity(ent2, view_as<float>( { 0.0, 0.0, 1250.0 } ), NULL_VECTOR, NULL_VECTOR);
//	TeleportEntity(ent3, view_as<float>( { -200.0, 0.0, 800.0 } ), view_as<float>( { 90.0, 0.0, 0.0 } ), NULL_VECTOR);
	
	EmitSoundToAll("vehicles/loud_helicopter_lp_01.wav", ent, SNDCHAN_AUTO, _, _, _, _, ent, _, _, true);
	EmitSoundToAll("vehicles/loud_helicopter_lp_01.wav", ent2, SNDCHAN_AUTO, _, _, _, _, ent2, _, _, true);
	
	Handle dp;
	CreateDataTimer(0.1, FrameCopter, dp, TIMER_REPEAT);
	
	WritePackCell(dp, ent);
	WritePackFloat(dp, vecDest[0]);
	WritePackFloat(dp, vecDest[1]);
	if( StrEqual(cmd, "sm_effect_copter2") )
		WritePackCell(dp, client);
	else
		WritePackCell(dp, 0);
	
	CreateTimer(18.0, schStopSound, ent2);
	return Plugin_Handled;
}
public Action FrameCopter(Handle timer, Handle dp) {
	float vecDest[3], vecPos[3];
	
	ResetPack(dp);
	int ent = ReadPackCell(dp);
	vecDest[0] = ReadPackFloat(dp);
	vecDest[1] = ReadPackFloat(dp);
	int client = ReadPackCell(dp);
	
	if (!IsValidEntity(ent)) {
		return Plugin_Stop;
	}
	Entity_GetAbsOrigin(ent, vecPos);
	vecDest[2] = vecPos[2];
	
	if (GetVectorDistance(vecDest, vecPos) < 120.0) {
		vecPos[2] += 800.0;
		ServerCommand("rp_zombie_die %f %f %f %d", vecPos[0], vecPos[1], vecPos[2], client);
	}
	
	return Plugin_Continue;
}
public Action:schStopSound(Handle:timer, any:ent) {
	StopSound(Entity_GetParent(ent), SNDCHAN_AUTO, "vehicles/loud_helicopter_lp_01.wav");
	StopSound(ent, SNDCHAN_AUTO, "vehicles/loud_helicopter_lp_01.wav");
	
	for (new i = 1; i <= MaxClients; i++) {
		if (!IsValidClient(i))
			continue;
		
		StopSound(i, SNDCHAN_AUTO, "vehicles/loud_helicopter_lp_01.wav");
	}
	
	rp_ScheduleEntityInput(Entity_GetParent(ent), 0.1, "KillHierarchy");
}

public Action:Cmd_SetMask(client, args) {
	new String:model[128];
	Format(model, sizeof(model), "models/player/holiday/facemasks/facemask_skull.mdl");
	if (!IsModelPrecached(model))
		PrecacheModel(model);
	
	
	new target = GetCmdArgInt(1);
	if (target != 0)
		client = target;
	
	new ent = CreateEntityByName("prop_dynamic");
	DispatchKeyValue(ent, "model", model);
	
	DispatchSpawn(ent);
	
	if (GetClientTeam(client) == CS_TEAM_T) {
		SetEntityModel(client, "models/player/custom_player/legacy/tm_separatist.mdl");
	}
	
	
	SetVariantString("!activator");
	rp_AcceptEntityInput(ent, "SetParent", client, client);
	
	SetVariantString("facemask");
	rp_AcceptEntityInput(ent, "SetParentAttachmentMaintainOffset");
	
	new Float:offset[3];
	offset[0] = GetCmdArgFloat(1);
	offset[1] = GetCmdArgFloat(2);
	offset[2] = GetCmdArgFloat(3);
	new Float:nullVect[3];
	
	TeleportEntity(ent, nullVect, offset, NULL_VECTOR);
	
	PrintToChat(client, "done: %d", ent);
	rp_ScheduleEntityInput(ent, 10.0, "Kill");
	return Plugin_Handled;
}

public Action Hook(const char[] te_name, const int[] Players, int numClients, float delay) {
	new data = TE_ReadNum("m_iEffectName");
	new num = TE_ReadNum("m_nHitBox");
	new ent = TE_ReadNum("entindex");

	if( data == 5 && (IsValidClient(ent) || delay < 0.0) ) {
		return Plugin_Continue;
	}
	
	return Plugin_Continue;
}
public OnMapStart() {
	LaserCache = PrecacheModel("materials/sprites/laserbeam.vmt", true);
	PrecacheModel("models/props_vehicles/helicopter_rescue.mdl", true);
	PrecacheSound("vehicles/loud_helicopter_lp_01.wav", true);
}
public Action:Cmd_Test2(client, args) {
	new color[4];
	color[0] = GetCmdArgInt(2);
	color[1] = GetCmdArgInt(3);
	color[2] = GetCmdArgInt(4);
	color[3] = 255;
	
	TE_SetupBeamFollow(GetCmdArgInt(1), LaserCache, 0, 180.0, 8.0, 0.1, 250, color);
	TE_SendToAll();
}
public Action:Cmd_VoiceToAll(client, args) {
	new String:text[2048];
	GetCmdArgString(text, sizeof(text));
	
	VoiceWareToAll("fr", text);
	return Plugin_Handled;
}
public OnPluginEnd() {
	RemoveMultiTargetFilter("@near", JoueurProche);
}
public Action:OnClientCommand(client, args) {
	OCCclient = client;
}
public bool:JoueurProche(const String:pattern[], Handle:clients) {
	new client = OCCclient;
	for (new i = 1; i <= MaxClients; i++) {
		if (!IsValidClient(i))
			continue;
		if (Entity_GetDistance(client, i) < 500.0) {
			PushArrayCell(clients, i);
		}
	}
	return true;
}
public bool:JoueurZone(const String:pattern[], Handle:clients) {
	new client = OCCclient;
	new cliZone = rp_GetPlayerZone(client);
	if (cliZone == 0) {
		return true;
	}
	
	for (new i = 1; i <= MaxClients; i++) {
		if (!IsValidClient(i))
			continue;
		if (cliZone == rp_GetPlayerZone(i)) {
			PushArrayCell(clients, i);
		}
	}
	return true;
}
public bool:LesAdmins(const String:pattern[], Handle:clients) {
	for (new i = 1; i <= MaxClients; i++) {
		if (!IsValidClient(i))
			continue;
		
		new flags = GetUserFlagBits(i);
		if (flags & ADMFLAG_GENERIC || flags & ADMFLAG_ROOT)
			PushArrayCell(clients, i);
	}
	return true;
}
public bool:LesBots(const String:pattern[], Handle:clients) {
	for (new i = 1; i <= MaxClients; i++) {
		if (!IsValidClient(i))
			continue;
		
		if( !IsFakeClient(i) )
			continue;
		PushArrayCell(clients, i);
	}
	return true;
}
public bool:LesAFK(const String:pattern[], Handle:clients) {
	for (new i = 1; i <= MaxClients; i++) {
		if (!IsValidClient(i))
			continue;
		
		if( !rp_GetClientBool(i, b_IsAFK) )
			continue;
		
		PushArrayCell(clients, i);
	}
	return true;
}
public OnClientPutInServer(i) {
	if (IsFakeClient(i))
		return;
//	SDKHook(i, SDKHook_PostThinkPost, think);
//	SDKHook(i, SDKHook_PreThink, think);
}
public think(i) {
	static tick[65];
	static float lastAngle[65][3];
	tick[i]++;
	
	float vecAngle[3];
	GetClientEyeAngles(i, vecAngle);
	
	if ((vecAngle[0] == 0.0 && vecAngle[1] == 0.0 || vecAngle[2] != 0.0) && Client_GetVehicle(i) <= 0 && rp_GetClientVehiclePassager(i) <= 0) {
		TeleportEntity(i, NULL_VECTOR, lastAngle[i], NULL_VECTOR);
	}
	else {
		lastAngle[i][0] = vecAngle[0];
		lastAngle[i][1] = vecAngle[1];
		lastAngle[i][2] = 0.0;
	}
	
}