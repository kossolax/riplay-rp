#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>
#include <smlib>
#include <colors_csgo>
#include <basecomm>
#include <SteamWorks>

#pragma newdecls required
#include <roleplay.inc>	// https://www.ts-x.eu
#include <audio>

#pragma newdecls required

public Plugin myinfo = {
	name = "Les test de kosso",
	author = "KoSSoLaX`",
	description = "",
	version = "1.0",
	url = "zaretti.be"
};


AudioPlayer api;
int g_cBeam;
bool g_bHasBag[65];

public void OnPluginStart() {
	RegConsoleCmd("sm_audio2", 		Cmd_Audio);
	RegConsoleCmd("player_ping", block);
	RegConsoleCmd("chatwheel_ping", block);
	RegConsoleCmd("drop", Drop);
	HookUserMessage(GetUserMessageId("RadioText"), BlockRadio, true);
	
	AddNormalSoundHook(sound_hook);
	AddAmbientSoundHook(sound_hook2);
	
	char model[PLATFORM_MAX_PATH];
	for (int i = 1; i <= 2048; i++) {
		if( !IsValidEdict(i) || !IsValidEntity(i) )
			continue;
		
		if( IsFourgon(i) ) {
			rp_SetVehicleInt(i, car_health, -1);
		}
		
		GetEdictClassname(i, model, sizeof(model));
		if( StrContains(model, "rp_moneybag") == 0 ) {
			AcceptEntityInput(i, "Kill");
		}
	}
	
	CreateTimer(5.0, test);
}
public void OnMapStart() {
	PrecacheModel("models/props_survival/cash/dufflebag.mdl");
	g_cBeam = PrecacheModel("materials/sprites/laserbeam.vmt");
}

int CreateBag(float pos[3], float ang[3], float vel[3]) {
	int bag = CreateEntityByName("prop_physics");
	DispatchKeyValue(bag, "classname", "rp_moneybag");
	DispatchKeyValue(bag, "solid", "6");
	DispatchKeyValue(bag, "model", "models/props_survival/cash/dufflebag.mdl");
	DispatchSpawn(bag);
	TeleportEntity(bag, pos, ang, vel);
	
	SDKHook(bag, SDKHook_Touch, Touch);
}
public void Touch(int entity, int target) {
	if( IsFourgon(target) ) {
		float src[3], dst[3], ang[3], min[3], max[3];
		Entity_GetMinSize(target, min);
		Entity_GetMaxSize(target, max);
		Entity_GetAbsOrigin(target, src);
		Entity_GetAbsAngles(target, ang);
		
		Entity_GetAbsOrigin(entity, dst);
		
		SubtractVectors(dst, src, dst);
		NegateVector(ang);
		Math_RotateVector(dst, ang, dst);
		
		max[1] = 0.0;
		if( min[0]+16.0 < dst[0] && dst[0] < max[0]-32.0 && 
			min[1]+16.0 < dst[1] && dst[1] < max[1]-16.0 && 
			min[2]+16.0 < dst[2] && dst[2] < max[2]-32.0 ) {
			
			AcceptEntityInput(entity, "Kill");
			rp_SetBuildingData(target, BD_count, rp_GetBuildingData(target, BD_count) + 1);
		}
	}
}
public Action test(Handle timer, any none) {
	float vecOrigin[3] =  { 3478.0, 832.0, -2000.0 };
	float vecAngles[3];
	
	int car = rp_CreateVehicle(vecOrigin, vecAngles, "models/props/crates/csgo_drop_crate_spectrum_v7.mdl", 7);
	SetEntProp(car, Prop_Send, "m_nBody", 1);
	rp_SetVehicleInt(car, car_owner, -221);
	rp_SetBuildingData(car, BD_count, 0);
	SetEntProp(car, Prop_Data, "m_bLocked", 1);
	
	SDKHook(car, SDKHook_Think, think);
	
	for (int i = 0; i < 25; i++) {
		vecOrigin[0] = 3600.0 + (i % 5) * 32.0;
		vecOrigin[1] = 830 + (i / 5) * 32.0;
		CreateBag(vecOrigin, NULL_VECTOR, NULL_VECTOR);
	}
}
bool IsFourgon(int car) {
	char model[PLATFORM_MAX_PATH];
	if( rp_IsValidVehicle(car) ) {
		Entity_GetModel(car, model, sizeof(model));
		if( StrEqual(model, "models/props/crates/csgo_drop_crate_spectrum_v7.mdl") && GetEntProp(car, Prop_Send, "m_nBody") == 1 ) {
			return true;
		}
	}
	return false;
}
public void OnClientPostAdminCheck(int client) {
	g_bHasBag[client] = false;
}
public Action Drop(int client, int args) {
	char classname[PLATFORM_MAX_PATH];
	
	if( g_bHasBag[client] == true ) {
		for (int i = 1; i <= 2048; i++) {
			if( !IsValidEdict(i) || !IsValidEntity(i) )
				continue;
			
			GetEdictClassname(i, classname, sizeof(classname));
			if( StrEqual(classname, "rp_moneybag_player") && Entity_GetParent(i) == client ) {
				g_bHasBag[client] = false;
				AcceptEntityInput(i, "Kill");
				
				float src[3], ang[3], vel[3], tmp[3];
				GetClientEyePosition(client, src);
				GetClientEyeAngles(client, ang);
				GetAngleVectors(ang, vel, NULL_VECTOR, NULL_VECTOR);
				NormalizeVector(vel, vel);
				
				ScaleVector(vel, 32.0);
				AddVectors(src, vel, src);
				ang[0] = 0.0;
				ang[1] += 90.0;
				ang[2] = 0.0;
				src[2] -= 16.0;
				
				Entity_GetAbsVelocity(client, tmp);
				NormalizeVector(vel, vel);
				ScaleVector(vel, 256.0);
				AddVectors(vel, tmp, vel);
				vel[2] += 128.0;
				
				CreateBag(src, ang, vel);
			}
		}
	}
	
	return Plugin_Continue;
}
void SetProgressBarTime(int client, float duration=0.0, int icon=0) {
	float time = GetGameTime();
	
	SetEntData(client, FindSendPropInfo("CCSPlayer", "m_iProgressBarDuration"), RoundToCeil(duration), 4, true);
	SetEntDataFloat(client, FindSendPropInfo("CCSPlayer", "m_flProgressBarStartTime"), time - (float(RoundToCeil(duration)) - duration), true);
	
	if( duration > 0.0 ) {
		SetEntDataFloat(client, FindSendPropInfo("CBaseEntity", "m_flSimulationTime"), time + duration, true);
		// 8: mission cible prioritaire, 11: traitement du paiement, 15: récupération d'un objet
		SetEntData(client, FindSendPropInfo("CCSPlayer", "m_iBlockingUseActionInProgress"), icon, 4, true);
	}
}

bool IsBehind(int client, int car) {
	float src[3], dst[3], ang[3], min[3], max[3];
	Entity_GetMinSize(car, min);
	Entity_GetMaxSize(car, max);
	Entity_GetAbsOrigin(car, src);
	Entity_GetAbsAngles(car, ang);
	
	Entity_GetAbsOrigin(client, dst);
	SubtractVectors(dst, src, dst);
	
	src[0] = min[0] * 0.5 + max[0] * 0.5;
	src[1] = min[1];
	src[2] = min[2] + 8.0;
	
	return GetVectorDistance(src, dst) < 32.0;
}

public Action OnPlayerRunCmd(int client, int& buttons) {
	static int oldButtons[65];
	static float start[65];
	
	char classname[128];
	float time = 5.0;
	
	if( g_bHasBag[client] == false ) {
		bool found = false;
		int target = rp_GetClientTarget(client);
		if( target > 0 && IsValidEdict(target) && IsValidEntity(target) ) {
			GetEdictClassname(target, classname, sizeof(classname));
			if( StrEqual(classname, "rp_moneybag") && rp_IsEntitiesNear(client, target, true)  ) {
				found = true;
				time = 1.0;
			}
			if( rp_GetBuildingData(target, BD_count)>0 && IsFourgon(target) && Vehicle_HasDriver(target)==false && IsBehind(client, target) ) {
				found = true;
				time = 5.0;
			}
		}
		
		if( found ) {
			if( (buttons & IN_USE) && !(oldButtons[client] & IN_USE) ) {
				start[client] = GetGameTime();
				SetProgressBarTime(client, time, 15);
			}
		}
		
		if( start[client] > 0.0 ) {
			if( !(buttons & IN_USE) && (oldButtons[client] & IN_USE) || !found ) {
				start[client] = 0.0;
				SetProgressBarTime(client);
			}
			else if( start[client] + time < GetGameTime() && found ) {
				start[client] = 0.0;
				SetProgressBarTime(client);
				
				if( StrEqual(classname, "rp_moneybag") ) {
					AcceptEntityInput(target, "Kill");
				}
				if( IsFourgon(target) ) {
					rp_SetBuildingData(target, BD_count, rp_GetBuildingData(target, BD_count) - 1);
				}
				
				g_bHasBag[client] = true;
				int bag = CreateEntityByName("prop_dynamic");
				DispatchKeyValue(bag, "classname", "rp_moneybag_player");
				DispatchKeyValue(bag, "model", "models/props_survival/cash/dufflebag.mdl");
				DispatchSpawn(bag);
				
				SetVariantString("!activator");
				rp_AcceptEntityInput(bag, "SetParent", client, bag, 0);
				
				SetVariantString("c4");
				AcceptEntityInput(bag, "SetParentAttachment", bag, bag, 0);
				TeleportEntity(bag, view_as<float>({-4.0, 0.0, -4.0}), NULL_VECTOR, NULL_VECTOR);
			}
		}
	}
	
	oldButtons[client] = buttons;
}

public void think(int car) {
	static int old[2049] = -1;
	static float lastDriver[2049];
	static float lastEmpty[2049];
	
	float time = GetGameTime();
	if( Vehicle_GetDriver(car) > 0 )
		lastDriver[car] = time;
	else
		lastEmpty[car] = time;

	float animOpen =  0.0 + (time - lastDriver[car]) / 2.0;
	float animClose = 1.0 - (time - lastEmpty[car]) / 2.0;
	
	float anim = (Vehicle_GetDriver(car) > 0 ) ? animClose : animOpen;
	
	if( anim < 0.0 )
		anim = 0.0;
	if( anim > 0.99 )
		anim = 0.99;
	
	SetEntPropFloat(car, Prop_Send, "m_flPoseParameter", anim + GetRandomFloat(0.0, 0.001), 6);
	
	int count = rp_GetBuildingData(car, BD_count);
	if( count != old[car] ) {
		char classname[PLATFORM_MAX_PATH];
		for (int i = 1; i <= 2048; i++) {
			if( !IsValidEdict(i) || !IsValidEntity(i) )
				continue;
			
			GetEdictClassname(i, classname, sizeof(classname));
			if( StrEqual(classname, "rp_moneybag_car") && Entity_GetParent(i) == car ) {
				AcceptEntityInput(i, "Kill");
			}
		}
	
		float src[3] =  { -32.0, -32.0, -36.0 };
		
		for (int i = 0; i < count; i ++) {
			int col = (i%6)/2;
			int row = i%2;
			int dep = i/6;
			
			float dst[3];
			dst[0] = src[0] + float(col) * 32.0;
			dst[1] = src[1] + float(row) * 32.0;
			dst[2] = src[2] + float(dep) * 16.0;
			
			
			int bag = CreateEntityByName("prop_dynamic");
			DispatchKeyValue(bag, "classname", "rp_moneybag_car");
			DispatchKeyValue(bag, "model", "models/props_survival/cash/dufflebag.mdl");
			DispatchSpawn(bag);
			
			SetVariantString("!activator");
			AcceptEntityInput(bag, "SetParent", car, bag, 0);
			
			SetVariantString("vehicle_feet_passenger2");
			AcceptEntityInput(bag, "SetParentAttachment", bag, bag, 0);
			
			TeleportEntity(bag, dst, NULL_VECTOR, NULL_VECTOR);
		}
	}

	old[car] = count;
}

public Action Cmd_Audio(int client, int args) {
	
	api = new AudioPlayer();
	char url[256];
	GetCmdArgString(url, sizeof(url));
	ReplyToCommand(client, url);
	TrimString(url);
	
	if( strlen(url) < 10 )
		Format(url, sizeof(url), "https://www.youtube.com/watch?v=NnhLfHNcB-o");
	
	int bot = CreateFakeClient("bot");
	CS_SwitchTeam(bot, GetClientTeam(client));
	CS_RespawnPlayer(bot);
	
	float pos[3];
	Entity_GetAbsOrigin(client, pos);
	TeleportEntity(bot, pos, NULL_VECTOR, NULL_VECTOR);
	
	//api.AddArg("-filter:a 'volume=0.2'");
	//api.SetFrom(5.0);
	api.PlayAsClient(bot, url);
	
	return Plugin_Handled;
}

public Action block(int client, int args) {
	return Plugin_Handled;
}
public Action BlockRadio(UserMsg msg_id, Protobuf bf, const int[] players, int playersNum, bool reliable, bool init)
{
	char buffer[64];
	PbReadString(bf, "params", buffer, sizeof(buffer), 0);

	if (StrContains(buffer, "#Chatwheel_"))
	{
		return Plugin_Handled;
	}
	return Plugin_Continue;
}
public Action sound_hook(int clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags) {
	if( StrContains(sample, "v8/vehicle", false) >= 0 ) {
		return Plugin_Handled;
	}
	if( StrContains(sample, "chicken_fly_long") >= 0 ) {
		return Plugin_Handled;
	}
	
	//PrintToChat(38, sample);
	
/*	
	if (StrContains(sample, "knife_slash") >= 0) {
		volume = 0.1;
		return Plugin_Changed;
	}
*/	
	return Plugin_Continue;
}
public Action sound_hook2(char sample[PLATFORM_MAX_PATH], int &entity, float & volume, int &level, int &pitch, float pos[3], int &flags, float & delay) {
	if( StrContains(sample, "v8/vehicle", false) >= 0 ) {
		return Plugin_Handled;
	}
	return Plugin_Continue;
}
