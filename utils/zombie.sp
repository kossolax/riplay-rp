#pragma semicolon 1
#pragma dynamic 131072

#define GAME_CSGO

#include <sourcemod.inc>
#include <sdktools.inc>
#include <sdkhooks.inc>
#include <smlib.inc>
#include <eItems>
#include <colors_csgo>
#include <roleplay>

#pragma newdecls required

#define ZOMBIE_XP 200
#define ZOMBIE_HP 1000
#define ZOMBIE_SCALE 1.0
#define ZOMBIE_DAMAGE 80

Handle g_hBDD = INVALID_HANDLE;
char g_szError[1024];
int last[2049];

public Plugin myinfo = 
{
	name = "ZOMBIE", author = "KoSSoLaX",
	description = "ZZZZZOMMMBIEZ", version = "0.1",
	url = "http://www.ts-x.eu"
}

public void OnPluginStart() {
	RegAdminCmd("sm_zombie", Cmd_SpawnZombie, ADMFLAG_ROOT);
	AddNormalSoundHook(sound_hook);
	
	for (int j = 1; j <= MaxClients; j++)
		if( IsValidClient(j) )
			OnClientPostAdminCheck(j);
}

public void OnClientPostAdminCheck(int client) {
	rp_HookEvent(client, RP_OnPlayerHINT,	fwdFrame);
}
public Action fwdFrame(int client, int target) {
	char classname[65];
	
	if( target > 0 ) {
		GetEdictClassname(target, classname, sizeof(classname));
		if( StrEqual(classname, "zombie") ) {
			PrintHintText(client, "<font color='#ff0000'>Zombie:</font> <b>%d</b>HP.\n Tuez le pour gagner <font color='#00ff00'>%dXP</font>!", Entity_GetHealth(target), ZOMBIE_XP);
		}
	}
}
public void BashSpawn(Handle owner, Handle hQuery, const char[] error, any none) {
	while( SQL_FetchRow(hQuery) ) {
		float vecOrigin[3];
		vecOrigin[0] = SQL_FetchFloat(hQuery, 0);
		vecOrigin[1] = SQL_FetchFloat(hQuery, 1);
		vecOrigin[2] = SQL_FetchFloat(hQuery, 2) + 10.0;
		
		float vecAngles[3];
		vecAngles[1] = GetRandomFloat(0.0, 360.0);
		
		if( none == 0 ) {
			ZombieSpawn(vecOrigin, vecAngles);
		}
	}
}
public Action sound_hook(int clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int& entity, int& channel, float& volume, int& level, int& pitch, int& flags) {
	
	if( StrContains(sample, "chicken") != -1 ) {
		if( Entity_ClassNameMatches(entity, "zombie") ) {
			return Plugin_Handled;
		}
	}
	
	return Plugin_Continue;
}
public void OnMapEnd() {
	CloseHandle(g_hBDD);
}
public void OnMapStart() {
	g_hBDD = SQL_Connect("default", true, g_szError, sizeof( g_szError ));
	if( g_hBDD == INVALID_HANDLE ) {
		SetFailState("Connexion impossible: %s", g_szError);
	}
	
	PrecacheModel("models/player/zombie.mdl");
	PrecacheSound("player/heartbeat1.wav");
	PrecacheSound("hostage/huse/hostage_breath.wav");	
	
	AddFileToDownloadsTable("sound/DeadlyDesire/halloween/zombie/claw_strike1.mp3");
	AddFileToDownloadsTable("sound/DeadlyDesire/halloween/zombie/claw_strike2.mp3");
	AddFileToDownloadsTable("sound/DeadlyDesire/halloween/zombie/claw_strike3.mp3");
	AddFileToDownloadsTable("sound/DeadlyDesire/halloween/zombie/die1.mp3");
	AddFileToDownloadsTable("sound/DeadlyDesire/halloween/zombie/die2.mp3");
	AddFileToDownloadsTable("sound/DeadlyDesire/halloween/zombie/die3.mp3");
	AddFileToDownloadsTable("sound/DeadlyDesire/halloween/zombie/foot1.mp3");
	AddFileToDownloadsTable("sound/DeadlyDesire/halloween/zombie/foot2.mp3");
	AddFileToDownloadsTable("sound/DeadlyDesire/halloween/zombie/foot3.mp3");
	AddFileToDownloadsTable("sound/DeadlyDesire/halloween/zombie/moan1.mp3");
	AddFileToDownloadsTable("sound/DeadlyDesire/halloween/zombie/moan2.mp3");
	AddFileToDownloadsTable("sound/DeadlyDesire/halloween/zombie/moan3.mp3");
	AddFileToDownloadsTable("sound/DeadlyDesire/halloween/zombie/mumbling1.mp3");
	AddFileToDownloadsTable("sound/DeadlyDesire/halloween/zombie/mumbling2.mp3");
	AddFileToDownloadsTable("sound/DeadlyDesire/halloween/zombie/mumbling3.mp3");
	AddFileToDownloadsTable("sound/DeadlyDesire/halloween/zombie/spawn1.mp3");
	AddFileToDownloadsTable("sound/DeadlyDesire/halloween/zombie/spawn2.mp3");
	AddFileToDownloadsTable("sound/DeadlyDesire/halloween/zombie/spawn3.mp3");

	
	PrecacheSound("DeadlyDesire/halloween/zombie/claw_strike1.mp3");
	PrecacheSound("DeadlyDesire/halloween/zombie/claw_strike2.mp3");
	PrecacheSound("DeadlyDesire/halloween/zombie/claw_strike3.mp3");
	PrecacheSound("DeadlyDesire/halloween/zombie/die1.mp3");
	PrecacheSound("DeadlyDesire/halloween/zombie/die2.mp3");
	PrecacheSound("DeadlyDesire/halloween/zombie/die3.mp3");
	PrecacheSound("DeadlyDesire/halloween/zombie/foot1.mp3");
	PrecacheSound("DeadlyDesire/halloween/zombie/foot2.mp3");
	PrecacheSound("DeadlyDesire/halloween/zombie/foot3.mp3");
	PrecacheSound("DeadlyDesire/halloween/zombie/moan1.mp3");
	PrecacheSound("DeadlyDesire/halloween/zombie/moan2.mp3");
	PrecacheSound("DeadlyDesire/halloween/zombie/moan3.mp3");
	PrecacheSound("DeadlyDesire/halloween/zombie/mumbling1.mp3");
	PrecacheSound("DeadlyDesire/halloween/zombie/mumbling2.mp3");
	PrecacheSound("DeadlyDesire/halloween/zombie/mumbling3.mp3");
	PrecacheSound("DeadlyDesire/halloween/zombie/spawn1.mp3");
	PrecacheSound("DeadlyDesire/halloween/zombie/spawn2.mp3");
	PrecacheSound("DeadlyDesire/halloween/zombie/spawn3.mp3");
	
	
	AddToStringTable( FindStringTable( "soundprecache" ), "*DeadlyDesire/halloween/zombie/claw_strike1.mp3");
	AddToStringTable( FindStringTable( "soundprecache" ), "*DeadlyDesire/halloween/zombie/claw_strike2.mp3");
	AddToStringTable( FindStringTable( "soundprecache" ), "*DeadlyDesire/halloween/zombie/claw_strike3.mp3");
	AddToStringTable( FindStringTable( "soundprecache" ), "*DeadlyDesire/halloween/zombie/die1.mp3");
	AddToStringTable( FindStringTable( "soundprecache" ), "*DeadlyDesire/halloween/zombie/die2.mp3");
	AddToStringTable( FindStringTable( "soundprecache" ), "*DeadlyDesire/halloween/zombie/die3.mp3");
	AddToStringTable( FindStringTable( "soundprecache" ), "*DeadlyDesire/halloween/zombie/foot1.mp3");
	AddToStringTable( FindStringTable( "soundprecache" ), "*DeadlyDesire/halloween/zombie/foot2.mp3");
	AddToStringTable( FindStringTable( "soundprecache" ), "*DeadlyDesire/halloween/zombie/foot3.mp3");
	AddToStringTable( FindStringTable( "soundprecache" ), "*DeadlyDesire/halloween/zombie/moan1.mp3");
	AddToStringTable( FindStringTable( "soundprecache" ), "*DeadlyDesire/halloween/zombie/moan2.mp3");
	AddToStringTable( FindStringTable( "soundprecache" ), "*DeadlyDesire/halloween/zombie/moan3.mp3");
	AddToStringTable( FindStringTable( "soundprecache" ), "*DeadlyDesire/halloween/zombie/mumbling1.mp3");
	AddToStringTable( FindStringTable( "soundprecache" ), "*DeadlyDesire/halloween/zombie/mumbling2.mp3");
	AddToStringTable( FindStringTable( "soundprecache" ), "*DeadlyDesire/halloween/zombie/mumbling3.mp3");
	AddToStringTable( FindStringTable( "soundprecache" ), "*DeadlyDesire/halloween/zombie/spawn1.mp3");
	AddToStringTable( FindStringTable( "soundprecache" ), "*DeadlyDesire/halloween/zombie/spawn2.mp3");
	AddToStringTable( FindStringTable( "soundprecache" ), "*DeadlyDesire/halloween/zombie/spawn3.mp3");

}
public Action Cmd_SpawnZombie(int client, int args) {
	
	char query[1024];
	if( args == 0 ) {
		float vecPosition[3], vecAngles[3], vecNormal[3];
		GetClientAimedLocationData(client, vecPosition, vecAngles, vecNormal);
		vecAngles[1] *= 1.0;
		int cpt = ZombieSpawn(vecPosition, vecAngles);
		PrintToChat(client, "%d", cpt);
	}
	else {
		int amount = GetCmdArgInt(1);
		Format(query, sizeof(query), "SELECT `x`, `y`, `z` FROM `fireblue`.`rp_gps_node` N INNER JOIN `rp_csgo`.`rp_location_zones` Z ON N.zoneID=Z.id WHERE bit='65536' ORDER BY RAND() LIMIT %d;", amount);
		SQL_TQuery(g_hBDD, BashSpawn, query, 0);
	}
	
	return Plugin_Handled;
}
public int ZombieSpawn(float vecPosition[3], float vecAngles[3]) {
	int amount = 0;
	char classname[64];
	
	for(int i=1; i<=2049; i++) {
		if( !IsValidEdict(i) )
			continue;
		if( !IsValidEntity(i) )
			continue;
		Entity_GetClassName(i, classname, sizeof(classname));
		if( StrEqual(classname, "zombie") ) {
			amount++;
		}
	}
	
	if( amount >= 150 ) {
		return amount;
	}
	
	int ent = CreateEntityByName("chicken");
	DispatchKeyValue(ent, "spawnflags", "2");
	DispatchSpawn(ent);
	
	Entity_SetModel(ent, "models/player/zombie.mdl");
	Entity_SetClassName(ent, "zombie");
	Entity_SetHealth(ent, 100000, true);
	
	vecAngles[0] = 0.0;
	vecAngles[1] += 180;
	vecAngles[2] = 0.0;	
	
	TeleportEntity(ent, vecPosition, vecAngles, NULL_VECTOR);
	CreateTimer(0.1, frame2, ent);
	
	SDKHook(ent, SDKHook_Think, think);
	SetEntPropFloat(ent, Prop_Data, "m_flModelScale", 0.001);
	return amount+1;
}
public Action frame2(Handle timer, any ent) {
	Entity_SetModel(ent, "models/player/zombie.mdl");
	Entity_SetHealth(ent, ZOMBIE_HP, true);
	ServerCommand("sm_effect_resize %d %f 1.0", ent, ZOMBIE_SCALE);
	
	char path[255];
	Format(path, sizeof(path), "*DeadlyDesire/halloween/zombie/spawn%d.mp3", GetRandomInt(1, 3));
	EmitSoundToAll(path, ent);
	last[ent] = 0;
	HookSingleEntityOutput(ent, "OnBreak", ZombieDie);
}
public void ZombieDie(const char[] output, int caller, int activator, float delay) {
	float vecOrigin[3];
	Entity_GetAbsOrigin(caller, vecOrigin);
	vecOrigin[2] += 0.0;
	
//	ServerCommand("rp_zombie_die %f %f %f", vecOrigin[0], vecOrigin[1], vecOrigin[2]);
	char path[255];
	Format(path, sizeof(path), "*DeadlyDesire/halloween/zombie/die%d.mp3", GetRandomInt(1, 3));
	EmitSoundToAll(path, SOUND_FROM_WORLD, _, _, _, _, _, _, vecOrigin);
	
	int ent = CreateEntityByName("info_target");
	DispatchSpawn(ent);
	TeleportEntity(ent, vecOrigin, NULL_VECTOR, NULL_VECTOR);
	rp_Effect_Particle(ent, "blood_pool", 0.1);
	rp_ScheduleEntityInput(ent, 0.2, "Kill");
	
	if( IsValidClient(activator) ) {
		rp_ClientXPIncrement(activator, ZOMBIE_XP);
	}
}
public void think(int ent) {
	static int tick[2049];
	static float lastPos[2049][3], aggroDistance = 80.0;
	
	tick[ent]++;
	
	SetEntPropFloat(ent, Prop_Send, "m_flPoseParameter", 0.5, 3);
	SetEntPropFloat(ent, Prop_Send, "m_flPoseParameter", 1.0, 4);
	
	char path[255]; float pos[3];
	
	int action = tick[ent] % 66;
	switch(action) {
		case 5, 25, 45: {
			for(int i=1; i<=MaxClients; i++) {
				if( !IsValidClient(i) || !IsPlayerAlive(i) )
					continue;
				if( Entity_GetDistance(ent, i) < aggroDistance ) {
					ZombieAttack(ent, i);
				}
			}
		}
		case 10: {
			if( GetRandomInt(0, 100) >= 95 || (Entity_GetHealth(ent) < 50 && GetRandomInt(1, 100) >= 60) ) {
				rp_Effect_Particle(ent, "blood_pool", 0.1);
			}
		}
		case 15, 35: {
			FollowSomeone(ent);
		}
		case 11, 41: {
			Entity_GetAbsOrigin(ent, pos);
			if( GetVectorDistance(pos, lastPos[ent]) > 20.0 ) {
				Format(path, sizeof(path), "*DeadlyDesire/halloween/zombie/foot%d.mp3", GetRandomInt(1, 3));
				EmitSoundToAll(path, ent, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.5);
			}
			Entity_GetAbsOrigin(ent, lastPos[ent]);
		}
		
		
		case 20: {
			if( GetRandomInt(0, 100) >= 90 ) {
				rp_Effect_Particle(ent, "blood_impact_medium", 0.01);
			}
		}
		case 30: {
			if( GetRandomInt(0, 100) >= 75 ) {
				Format(path, sizeof(path), "*DeadlyDesire/halloween/zombie/moan%d.mp3", GetRandomInt(1, 3));
				EmitSoundToAll(path, ent);
			}
		}
		case 40: {
			if( GetRandomInt(0, 100) >= 90 ) {
				rp_Effect_Particle(ent, "blood_impact_heavy", 0.01);
			}
		}
		case 50: {
			if( GetRandomInt(0, 100) >= 75 ) {
				Format(path, sizeof(path), "*DeadlyDesire/halloween/zombie/mumbling%d.mp3", GetRandomInt(1, 3));
				EmitSoundToAll(path, ent);
			}
		}
		case 60: {
			if( GetRandomInt(0, 100) >= 90 ) {
				rp_Effect_Particle(ent, "blood_impact_light", 0.01);
			}
		}
		default: {
		}
	}
}
public void ZombieAttack(int ent, int target) {
	
	if( rp_IsTargetSeen(ent, target) ) {
		SDKHooks_TakeDamage(target, ent, ent, GetRandomFloat(ZOMBIE_DAMAGE-20.0, ZOMBIE_DAMAGE+20.0));
		SlapPlayer(target, 0, false);
		
		rp_Effect_Particle(target, "blood_pool", 0.01);
		rp_Effect_Particle(ent, "blood_impact_headshot", 0.01);
		
		char path[255];
		Format(path, sizeof(path), "*DeadlyDesire/halloween/zombie/claw_strike%d.mp3", GetRandomInt(1, 3));
		EmitSoundToAll(path, ent);
	}
}

void AimTo(int entity, int target) {
	float vecOrigin[3], vecOrigin2[3];
	Entity_GetAbsOrigin(entity, vecOrigin);
	GetClientAbsOrigin(target, vecOrigin2);
	
	float diff[3];
	diff[0] = vecOrigin2[0] - vecOrigin[0];
	diff[1] = vecOrigin2[1] - vecOrigin[1];
	diff[2] = vecOrigin2[2] - vecOrigin[2];
	
	float lenght = SquareRoot( Pow(diff[0], 2.0) + Pow(diff[1], 2.0) + Pow(diff[2], 2.0) );
	
	float vecVelocity[3];
	
	vecVelocity[0] = diff[0] * (800.0 / lenght);
	vecVelocity[1] = diff[1] * (800.0 / lenght);
	vecVelocity[2] = diff[2] * (800.0 / lenght);
	
	float vecAngles[3];
	GetVectorAngles(vecVelocity, vecAngles);
	
	vecAngles[0] = vecAngles[2] = 0.0;
	
	TeleportEntity(entity, NULL_VECTOR, vecAngles, NULL_VECTOR);
}
bool FollowSomeone(int entity, int target = -1) {
	
	if( last[entity] > 0 && IsValidClient(last[entity]) && (rp_IsTargetSeen(entity, last[entity]) || rp_IsTargetSeen(last[entity], entity)) ) {
		AimTo(entity, last[entity]);
		return true;
	}
	
	float vecOrigin[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", vecOrigin);
	
	float NearestDistance = 1250.0; int NearestEntity = -1;
	
	if( target < 0 ) {
		for(int i=1; i<= MaxClients; i++) {
			if( !IsValidClient(i) || !IsPlayerAlive(i) )
				continue;
			if( GetEntityMoveType(i) == MOVETYPE_NOCLIP )
				continue;
			
			float vecOrigin2[3];
			GetClientEyePosition(i, vecOrigin2);
			
			float dist = GetVectorDistance(vecOrigin, vecOrigin2);
			
			if( !rp_IsTargetSeen(entity, i) )
				dist *= 2.0;
			
		
			if( dist < NearestDistance ) {
				NearestDistance = dist;
				NearestEntity = i;
			}
		}
	}
	else {
		NearestEntity = target;
	}
	last[entity] = NearestEntity;
	
	if( IsValidClient(NearestEntity) ) {
		AcceptEntityInput(entity, "Use", NearestEntity);
		AimTo(entity, NearestEntity);
		return true;
	}
	
	return false;
}
int GetClientAimedLocationData( int client, float position[3], float angles[3], float normal[3] ) {
	int index = -1;
	int player = client;
	
	float _origin[3], _angles[3];
	GetClientEyePosition( player, _origin );
	GetClientEyeAngles( player, _angles );
	
	Handle trace = TR_TraceRayFilterEx( _origin, _angles, MASK_SOLID_BRUSHONLY, RayType_Infinite, TraceEntityFilterPlayers );
	if( !TR_DidHit( trace ) ) { 
		index = -1;
	}
	else {
		TR_GetEndPosition( position, trace );
		TR_GetPlaneNormal( trace, normal );
		angles[0] = _angles[0];
		angles[1] = _angles[1];
		angles[2] = _angles[2];
		
		index = TR_GetEntityIndex( trace );
	}
	CloseHandle( trace );
	
	return index;
}
public bool TraceEntityFilterPlayers( int entity, int contentsMask, any data ) {
	return entity > MaxClients && entity != data;
}
