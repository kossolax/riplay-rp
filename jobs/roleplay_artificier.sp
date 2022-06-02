/*
 * Cette oeuvre, création, site ou texte est sous licence Creative Commons Attribution
 * - Pas d’Utilisation Commerciale
 * - Partage dans les Mêmes Conditions 4.0 International. 
 * Pour accéder à une copie de cette licence, merci de vous rendre à l'adresse suivante
 * http://creativecommons.org/licenses/by-nc-sa/4.0/ .
 *
 * Merci de respecter le travail fourni par le ou les auteurs 
 * https://www.ts-x.eu/ - kossolax@ts-x.eu
 */
#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>
#include <colors_csgo>	// https://forums.alliedmods.net/showthread.php?p=2205447#post2205447
#include <smlib>		// https://github.com/bcserv/smlib
#include <emitsoundany> // https://forums.alliedmods.net/showthread.php?t=237045

#pragma newdecls required
#include <roleplay.inc>	// https://www.ts-x.eu
#include <roleplay_armurerie.sp>

public Plugin myinfo = {
	name = "Jobs: Artificier", author = "KoSSoLaX",
	description = "RolePlay - Jobs: Artificier",
	version = __LAST_REV__, url = "https://www.ts-x.eu"
};
int g_cBeam, g_cGlow, g_cShockWave, g_cShockWave2, g_cExplode;
int g_iClientColor[65][4];

#define LAUNCHER_MODEL "models/shells/shell_57.mdl"
#define LAUNCHER_SCALE	25.0
#define	FIREWOKRS_SPEED	1000.0

char g_szParticles[][] =  {
	"Trail",
	"Trail2",
	"Trail_01",
	"Trail3",
	"Trail4",
	"Trail_03",
	"Trail7",
	"Trail5",
	"Trail8",
	"Trail10",
	"Trail13",
	"Trail11",
	"Trail12",
	"Trail_02",
	"Trail15",
	"Trail_04",
	"trail_money",
	"trail_heart",
	"confetti_balloons",
};
char g_szTirs[][32] =  { "Firework_Shot_Instant", "Firework_Shot_Fast", "Firework_Shot_Long", "Firework_Shot_Trigger" };
char g_szPropultion[][32] =  { "Firework_Fuel_Up", "Firework_Fuel_Realistic", "Firework_Fuel_Random", "Firework_Fuel_FollowAim", "Firework_Fuel_FollowPlayer"};

int g_iTirsIndex[2049], g_iParticleIndex[2049], g_iPropultionIndex[2049], g_iFireworkOwner[2049];
float g_flStart[2049], g_flLastDir[2049][3];
int g_iFireworksCount[65];
int g_iMaxFireworks;
int g_iFreeFirework[65];

// ----------------------------------------------------------------------------
public Action Cmd_Reload(int args) {
	char name[64];
	GetPluginFilename(INVALID_HANDLE, name, sizeof(name));
	ServerCommand("sm plugins reload %s", name);
	return Plugin_Continue;
}
public void OnPluginStart() {
	LoadTranslations("core.phrases");
	LoadTranslations("common.phrases");
	LoadTranslations("roleplay.phrases");
	LoadTranslations("roleplay.items.phrases");
	LoadTranslations("roleplay.artificier.phrases");
	LoadTranslations("roleplay.armurerie.phrases");
	
	Handle cvar = CreateConVar("rp_fireworks", "10", "Nombre maximum de feu d'artifice autorisé", 0, true, 0.0, true, 100.0);
	HookConVarChange(cvar, OnCvarChange);
	g_iMaxFireworks = GetConVarInt(cvar);
	
	RegServerCmd("rp_quest_reload", 	Cmd_Reload);
	RegServerCmd("rp_item_firework",	Cmd_ItemFireWork,		"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_highjump",	Cmd_ItemHighJump,		"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_bomb",		Cmd_ItemBomb,			"RP-ITEM",  FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_nade",		Cmd_ItemNade,			"RP-ITEM",  FCVAR_UNREGISTERED);
	
	RegAdminCmd("sm_effect_fireworks", Cmd_Fireworks, 			ADMFLAG_RCON);
	
	for (int i = 1; i <= MaxClients; i++) 
		if( IsValidClient(i) )
			OnClientPostAdminCheck(i);
}
public Action Cmd_Fireworks(int client, int args) {
	float delay = GetCmdArgFloat(1);
	
	Handle dp;
	CreateDataTimer(delay, Delay_Fireworks, dp, TIMER_DATA_HNDL_CLOSE);
	WritePackCell(dp, GetCmdArgInt(2));
	WritePackCell(dp, GetCmdArgFloat(3));
	WritePackCell(dp, GetCmdArgFloat(4));
	WritePackCell(dp, GetCmdArgFloat(5));
}
public Action Delay_Fireworks(Handle timer, Handle dp) {
	float pos[3];

	ResetPack(dp);
	int id = ReadPackCell(dp);
	pos[0] = ReadPackCell(dp);
	pos[1] = ReadPackCell(dp);
	pos[2] = ReadPackCell(dp);
	
	FW_SpawnAtPosition(0, pos, id, 0, 0);
}
public void OnCvarChange(Handle cvar, const char[] oldVal, const char[] newVal) {
	g_iMaxFireworks = StringToInt(newVal);
}
public void OnEntityCreated(int ent, const char[] classname) {
	if( ent > 0 )
		g_iFireworkOwner[ent] = 0;
}
public void OnClientDisconnect(int client) {
	FW_EXPL(client);
}

public void OnClientPostAdminCheck(int client) {
	rp_HookEvent(client, RP_PostTakeDamageWeapon, fwdWeapon);
	rp_HookEvent(client, RP_OnPlayerBuild, fwdOnPlayerBuild);
}
public Action fwdOnPlayerBuild(int client, float& cooldown){
	if( rp_GetClientJobID(client) != 131 )
		return Plugin_Continue;

	int wep_id = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	
	char tmp1[64], tmp2[64];
	Handle menu = CreateMenu(ModifyWeapon);
	SetMenuTitle(menu, "%T\n ", "edit_weapon", client);
	
	char szMenu[][][] = {
		{"fire",			"750",	"add_ball_type_fire"},
		{"paintball",		"125",	"add_ball_type_paintball"},
		{"explode", 		"1400",	"add_ball_type_explode"},
		{"sanandreas",		"250",	"add_bullet_sanAndreas"},
		{"pvp",				"400",	"add_bullet_pvp"},
		{"caoutchouc",		"750",	"add_ball_type_caoutchouc"},
		{"poison",			"750",	"add_ball_type_poison"},
		{"vampire",			"750",	"add_ball_type_vampire"},
		{"reflexive",		"500",	"add_ball_type_reflexive"},
		{"revitalisante",	"250",	"add_ball_type_revitalisante"},
		{"nosteal", 		"100",	"add_ball_type_nosteal"},
		{"notk", 			"50",	"add_ball_type_notk"},
		{"flashbang", 		"25",	"add_weapon_flashbang"},
		{"smokegrenade", 		"125",	"add_weapon_smokegrenade"},
		{"tagrenade", 		"150",	"add_weapon_tagrenade"},
		{"molotov", 		"250",	"add_weapon_molotov"}
	};
	
	for (int i = 0; i < sizeof(szMenu); i++) {
		Format(tmp1, sizeof(tmp1), "%s_%s", szMenu[i][0], szMenu[i][1]);
		Format(tmp2, sizeof(tmp2), "%T - %s$", szMenu[i][2], client, szMenu[i][1]);
		AddMenuItem(menu, tmp1, tmp2);
	}
	
	DisplayMenu(menu, client, 60);
	cooldown = 0.1;
	
	return Plugin_Stop;
}

public int ModifyWeapon(Handle p_hItemMenu, MenuAction p_oAction, int client, int p_iParam2) {

	if (p_oAction == MenuAction_Select) {
		char szMenuItem[32];
		if (GetMenuItem(p_hItemMenu, p_iParam2, szMenuItem, sizeof(szMenuItem))){

			char data[2][32];
			ExplodeString(szMenuItem, "_", data, sizeof(data), sizeof(data[]));

			char type[32];
			strcopy(type, 31, data[0]);
			int price = StringToInt(data[1]);
			int wep_id = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

			if((rp_GetClientInt(client, i_Bank)+rp_GetClientInt(client, i_Money)) < price){
					CPrintToChat(client, ""...MOD_TAG..." %T", "Error_NotEnoughtMoney", client);
					return;
			}

				if(StrEqual(type, "fire") || StrEqual(type, "explode") || StrEqual(type, "paintball") || StrEqual(type, "sanandreas") || StrEqual(type, "pvp") || StrEqual(type, "coutchouc") || StrEqual(type, "poison") || StrEqual(type, "vampire") || StrEqual(type, "reflexive") || StrEqual(type, "revitalisante") || StrEqual(type, "nosteal") || StrEqual(type, "notk")){
					if( wep_id <= 0 || Weapon_IsMelee(wep_id) ) {
						CPrintToChat(client, "" ...MOD_TAG... " %T", "Armu_WeaponInHands", client);
						return;
					}
					else {
						rp_SetWeaponBallType(wep_id, ball_type_fire);
						CPrintToChat(client, "" ...MOD_TAG... " %T", "edit_weapon_done", client);
					}
				}
				else if(StrEqual(type, "flashbang")){
					GivePlayerItem(client, "weapon_flashbang");
				}
				else if(StrEqual(type, "smokegrenade")){
					GivePlayerItem(client, "weapon_smokegrenade");
				}
				else if(StrEqual(type, "tagrenade")){
					GivePlayerItem(client, "weapon_tagrenade");
				}
				else if(StrEqual(type, "molotov")){
					GivePlayerItem(client, "weapon_molotov");
				}
				
				
				rp_ClientMoney(client, i_Money, -price);
				rp_SetClientStat(client, i_TotalBuild, rp_GetClientStat(client, i_TotalBuild)+1);
				rp_SetJobCapital( 131, rp_GetJobCapital(131)+price );
				FakeClientCommand(client, "say /build");

			}
		}
	else if (p_oAction == MenuAction_End) {
		CloseHandle(p_hItemMenu);
	}
}
public Action fwdWeapon(int victim, int attacker, float &damage, int wepID, float pos[3]) {
	bool changed = true;
	enum_ball_type wepType = rp_GetWeaponBallType(wepID);
	
	switch( wepType ) {
		case ball_type_fire: {
			rp_ClientIgnite(victim, 10.0, attacker);
			changed = false;
		}
		case ball_type_paintball: {
			damage *= 1.0;
			
			g_iClientColor[victim][0] = Math_GetRandomInt(50, 255);
			g_iClientColor[victim][1] = Math_GetRandomInt(50, 255);
			g_iClientColor[victim][2] = Math_GetRandomInt(50, 255);
			g_iClientColor[victim][3] = Math_GetRandomInt(100, 240);

			rp_HookEvent(victim, RP_PreHUDColorize, fwdColorize, 5.0);
		}
		case ball_type_explode: {
			damage *= 0.8;
		}
	}
	
	if( changed )
		return Plugin_Changed;
	return Plugin_Continue;
}
// ----------------------------------------------------------------------------
public Action fwdColorize(int client, int color[4]) {
	for (int i = 0; i < 4; i++)
		color[i] += g_iClientColor[client][i];
	return Plugin_Changed;
}
public Action Cmd_ItemRedraw(int args) {
	int client = GetCmdArgInt(1);
	
	int wep_id = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	int item_id = GetCmdArgInt(args);
	char classname[64];
	
	if( IsValidEntity(wep_id) ) {
		GetEdictClassname(wep_id, classname, sizeof(classname));
		if( StrContains(classname, "weapon_bayonet") == 0 || StrContains(classname, "weapon_knife") == 0 ) {
			ITEM_CANCEL(client, item_id);
			return Plugin_Handled;
		}
	}
}

// ----------------------------------------------------------------------------
public void OnMapStart() {
	g_cBeam = PrecacheModel("materials/sprites/laserbeam.vmt", true);
	g_cGlow = PrecacheModel("materials/sprites/glow01.vmt", true);
	g_cShockWave = PrecacheModel("materials/effects/concrefract.vmt", true);
	g_cShockWave2 = PrecacheModel("materials/sprites/rollermine_shock.vmt", true);
	g_cExplode = PrecacheModel("materials/sprites/muzzleflash4.vmt", true);
	PrecacheModel("models/weapons/w_c4_planted.mdl", true);
	
	
	PrecacheModel(LAUNCHER_MODEL);
	PrecacheSoundAny("weapons/hegrenade/explode3.wav");
	PrecacheSoundAny("weapons/hegrenade/explode4.wav");
	PrecacheSoundAny("weapons/hegrenade/explode5.wav");
	
	for (int i = 0; i < sizeof(g_szParticles); i++ ) {
		PrecacheEffect("ParticleEffect");
		PrecacheParticleEffect(g_szParticles[i]);
	}
	
	
	PrecacheEffect("ParticleEffect");
	PrecacheParticleEffect("firework_crate_explosion_01");
	PrecacheEffect("ParticleEffect");
	PrecacheParticleEffect("firework_crate_explosion_02");
}
// ------------------------------------------------------------------------------
public Action Cmd_ItemNade(int args) {
	char arg1[12];	
	GetCmdArg(1, arg1, sizeof(arg1));
	
	int client = GetCmdArgInt(2);
	rp_SetClientInt(client, i_LastAgression, GetTime());
	
	for (int i = 1; i <= MaxClients; i++) {
		if( !IsValidClient(i) || i == client )
			continue;
		
		rp_ClientAggroIncrement(client, i, 1000);
	}
	
	if( StrEqual(arg1, "conc") ) {
		rp_CreateGrenade(client, "ctf_nade_conc", "models/grenades/conc/conc.mdl", throwClassic, concExplode, 3.0);
	}
	else if( StrEqual(arg1, "caltrop") ) {
		for (int i = 0; i <= 10; i++) {
			rp_CreateGrenade(client, "ctf_nade_caltrop", "models/grenades/caltrop/caltrop.mdl", throwCaltrop, caltropExplode, 0.1);
		}
	}
	else if( StrEqual(arg1, "nail") ) {
		rp_CreateGrenade(client, "ctf_nade_nail", "models/grenades/nailgren/nailgren.mdl", throwClassic, nailExplode, 3.0);
	}
	else if( StrEqual(arg1, "mirv") ) {
		rp_CreateGrenade(client, "ctf_nade_mirv", "models/grenades/mirv/mirv.mdl", throwClassic, mirvExplode, 3.0);
	}
	else if( StrEqual(arg1, "gas") ) {
		rp_CreateGrenade(client, "ctf_nade_gas", "models/grenades/gas/gas.mdl", throwClassic, gasExplode, 3.0);
	}
	else if( StrEqual(arg1, "emp") ) {
		rp_CreateGrenade(client, "ctf_nade_emp", "models/grenades/emp/emp.mdl", throwClassic, EMPExplode, 3.0);
	}
	else if( StrEqual(arg1, "emp2") ) {
		rp_CreateGrenade(client, "ctf_nade_emp", "models/grenades/emp/emp.mdl", throwClassic, EMPExplode2, 3.0);
	}
}
// ------------------------------------------------------------------------------
public void throwMirvlet(int client, int ent) {
	float vecOrigin[3], vecPush[3];
	
	Entity_GetAbsOrigin(client, vecOrigin);
	vecOrigin[2] += 25.0;

	vecPush[0] = GetRandomFloat(-250.0, 250.0);
	vecPush[1] = GetRandomFloat(-250.0, 250.0);
	vecPush[2] = GetRandomFloat(10.0, 50.0);
	
	TeleportEntity(ent, vecOrigin, NULL_VECTOR, vecPush);
}
public void throwCaltrop(int client, int ent) {
	float vecOrigin[3],  vecPush[3];
	
	GetClientEyePosition(client, vecOrigin);
	vecOrigin[2] -= 25.0;

	vecPush[0] = GetRandomFloat(-120.0, 120.0);
	vecPush[1] = GetRandomFloat(-120.0, 120.0);
	vecPush[2] = GetRandomFloat(10.0, 50.0);
	
	TeleportEntity(ent, vecOrigin, NULL_VECTOR, vecPush);
}
public void throwClassic(int client, int ent) {
	float vecOrigin[3], vecAngles[3], vecPush[3];
	
	GetClientEyePosition(client, vecOrigin);
	GetClientEyeAngles(client,vecAngles);
	vecOrigin[2] -= 25.0;
	
	GetAngleVectors(vecAngles, vecPush, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(vecPush, 800.0);
	
	TeleportEntity(ent, vecOrigin, NULL_VECTOR, vecPush);
}
// ------------------------------------------------------------------------------
public void concExplode(int client, int ent) {
	
	float vecOrigin[3], vecCenter[3];
	char sound[128];
	
	Entity_GetAbsOrigin(ent, vecCenter);
	rp_Effect_Push(vecCenter, 280.0, 1000.0);
	
	for (int i=1; i<=MaxClients; i++) {
		if( !IsValidClient(i) )
			continue;
		if( rp_GetZoneBit(rp_GetPlayerZone(i)) & BITZONE_PEACEFULL )
			continue;
		
		GetClientAbsOrigin(i, vecOrigin);
		
		if( GetVectorDistance(vecOrigin, vecCenter) > 280.0 )
			continue;
		
		float vecAngles[3];
		vecAngles[0] = 50.0;
		vecAngles[1] = 50.0;
		vecAngles[2] = 50.0;
		
		SetEntPropVector(i, Prop_Send, "m_viewPunchAngle", vecAngles);
		ServerCommand("sm_effect_flash %d 2.5 50", i);
	}
	
	vecCenter[2] += 25.0;
	
	TE_SetupBeamRingPoint(vecCenter, 1.0, 285.0, g_cShockWave, 0, 0, 10, 0.25, 50.0, 0.0, {255, 255, 255, 255}, 1, 0);
	TE_SendToAll();
	TE_SetupBeamRingPoint(vecCenter, 0.1, 288.0, g_cShockWave2, 0, 0, 10, 0.25, 50.0, 0.0, {255, 255, 255, 200}, 1, 0);
	TE_SendToAll();
	
	
	Format(sound, sizeof(sound), "grenades/conc%i.mp3", Math_GetRandomInt(1, 2));
	EmitSoundToAllAny(sound, ent);
	
	rp_ScheduleEntityInput(ent, 0.25, "KillHierarchy");
}
// ------------------------------------------------------------------------------
public void caltropExplode(int client, int ent) {
	rp_ScheduleEntityInput(ent, 12.25, "KillHierarchy");
	CreateTimer(0.01, caltropShot, EntIndexToEntRef(ent));
}
public Action fwdSlow(int client, float& speed, float& gravity) {
	speed -= 0.0666;
	return Plugin_Changed;
}
public Action caltropShot(Handle timer, any ent) {
	ent = EntRefToEntIndex(ent);
	if( !IsValidEdict(ent) || !IsValidEntity(ent) )
		return Plugin_Handled;
	
	int attacker = GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity");
	float vecCenter[3], vecOrigin[3];
	Entity_GetAbsOrigin(ent, vecCenter);
	
	for(int i=1; i<=MaxClients; i++) {
		if( !IsValidClient(i) )
			continue;
		if( i == attacker )
			continue;
		
		GetClientAbsOrigin(i, vecOrigin);
		if( GetVectorDistance(vecOrigin, vecCenter) >= 20.0 )
			continue;
		
		rp_HookEvent(i, RP_PrePlayerPhysic, fwdSlow, 2.5);
		if( Math_GetRandomInt(0, 1) )
			rp_ClientDamage(i, 1, attacker, "nade_caltrop");
	}
	
	CreateTimer(0.01, caltropShot, EntIndexToEntRef(ent));
	return Plugin_Handled;
}
// ------------------------------------------------------------------------------
public void nailExplode(int client, int ent) {	
	float vecOrigin[3];
	GetEntPropVector(ent, Prop_Send, "m_vecOrigin", vecOrigin);
	vecOrigin[2] += 25.0;
	TeleportEntity(ent, vecOrigin, NULL_VECTOR, NULL_VECTOR);
	SetEntityMoveType(ent, MOVETYPE_NONE);
	
	CreateTimer(0.00001, nailShot, EntIndexToEntRef(ent));
	CreateTimer(5.0, nailExplode_Task, EntIndexToEntRef(ent));
	
}
public Action nailExplode_Task(Handle timer, any ent) {
	ent = EntRefToEntIndex(ent);
	if( !IsValidEdict(ent) || !IsValidEntity(ent) )
		return Plugin_Handled;
		
	float vecOrigin[3];	
	char sound[128];
	int attacker = GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity");
	Entity_GetAbsOrigin(ent, vecOrigin);
	
	rp_Effect_Explode(vecOrigin, 500.0, 400.0, attacker, "nade_nail");
	
	TE_SetupExplosion(vecOrigin, g_cExplode, 1.0, 0, 0, 100, 100);
	TE_SendToAll();
	
	Format(sound, sizeof(sound), "weapons/hegrenade/explode%i.wav", Math_GetRandomInt(3, 5));
	EmitSoundToAllAny(sound, ent);
	
	rp_ScheduleEntityInput(ent, 0.01, "KillHierarchy");
	
	return Plugin_Handled;
}
public Action nailShot(Handle timer, any ent) {
	static float lastAngle[2049];
	ent = EntRefToEntIndex(ent);
	if( !IsValidEdict(ent) || !IsValidEntity(ent) )
		return Plugin_Handled;
	
	int attacker = GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity");
	float vecAngles[3], vecOrigin[3], vecDest[3];
	
	GetEntPropVector(ent, Prop_Send, "m_vecOrigin", vecOrigin);
	
	vecAngles[1] = lastAngle[ent] + Math_GetRandomFloat(4.0, 6.0);
	if ( vecAngles[1] >= 360.0 ) {
		vecAngles[1] -= 360.0;
	}
	
	TeleportEntity(ent, NULL_VECTOR, vecAngles, NULL_VECTOR);
	
	for(int i=1; i<=3; i++) {
		
		vecAngles[1] += 120.0;
		
		GetEntPropVector(ent, Prop_Send, "m_vecOrigin", vecOrigin);
		vecOrigin[0] = (vecOrigin[0] + (5.0 * Cosine( DegToRad(vecAngles[1]) )) );
		vecOrigin[1] = (vecOrigin[1] + (5.0 * Sine( DegToRad(vecAngles[1]))));
		
		TE_SetupMuzzleFlash(vecOrigin, vecAngles, 1.0, 1);
		TE_SendToAll();
		
		float vecTarget[3], vecAnglesTarget[3];
		GetFrontLocationData(vecOrigin, vecAngles, vecTarget, vecAnglesTarget, MAX_AREA_DIST*1.25);
		
		Handle trace = TR_TraceRayFilterEx(vecOrigin, vecTarget, MASK_SHOT, RayType_EndPoint, FilterToOne, ent);
		int victim = 0;
		
		if( !TR_DidHit(trace) ) {
			vecDest[0] = vecTarget[0];
			vecDest[1] = vecTarget[1];
			vecDest[2] = vecTarget[2];
		}
		else {
			victim = TR_GetEntityIndex(trace);
			TR_GetEndPosition(vecDest, trace);
		}
		
		CloseHandle(trace);
		
		TE_SetupBeamPoints( vecOrigin, vecDest, g_cBeam, 0, 0, 0, 0.1, 3.0, 3.0, 1, 0.0, {200, 200, 200, 20}, 0);
		TE_SendToAll();
		
		if( IsValidClient(victim) ) {
			rp_ClientDamage(victim, Math_GetRandomInt(30, 60), attacker);
		}
	}
	
	lastAngle[ent] = vecAngles[1];
	CreateTimer(0.00001, nailShot, EntIndexToEntRef(ent));
	return Plugin_Handled;
}
void GetFrontLocationData( float _origin[3], float _angles[3], float position[3], float angles[3], float distance = 50.0 ) {
	float direction[3];
	GetAngleVectors( _angles, direction, NULL_VECTOR, NULL_VECTOR );
	
	position[0] = _origin[0] + direction[0] * distance;
	position[1] = _origin[1] + direction[1] * distance;
	position[2] = _origin[2];
	
	angles[0] = 0.0;
	angles[1] = _angles[1];
	angles[2] = 0.0;
}
// ------------------------------------------------------------------------------
public void mirvExplode(int client, int ent) {
	float vecOrigin[3];
	char sound[128];
	Entity_GetAbsOrigin(ent, vecOrigin);
	
	rp_Effect_Explode(vecOrigin, 500.0, 400.0, client, "nade_mirv");
	
	TE_SetupExplosion(vecOrigin, g_cExplode, 1.0, 0, 0, 200, 200);
	TE_SendToAll();
	
	Format(sound, sizeof(sound), "weapons/hegrenade/explode%i.wav", Math_GetRandomInt(3, 5));
	EmitSoundToAllAny(sound, ent);
	
	for(int i=0; i<Math_GetRandomInt(7, 8); i++) {
		
		rp_CreateGrenade(ent, "ctf_nade_mirvlet", "models/grenades/mirv/mirvlet.mdl", throwMirvlet, mirvletExplode, 3.0);
	}
	SetEntityRenderMode(ent, RENDER_NONE);
	rp_ScheduleEntityInput(ent, 3.25, "KillHierarchy");
}
public void mirvletExplode(int client, int ent) {
	
	float vecOrigin[3];
	char sound[128];
	Entity_GetAbsOrigin(ent, vecOrigin);
	
	int attacker = GetEntPropEnt(client, Prop_Send, "m_hOwnerEntity");
	
	rp_Effect_Explode(vecOrigin, 250.0, 200.0, attacker, "nade_mirvlet");
	
	TE_SetupExplosion(vecOrigin, g_cExplode, 1.0, 0, 0, 100, 100);
	TE_SendToAll();
	
	Format(sound, sizeof(sound), "weapons/hegrenade/explode%i.wav", Math_GetRandomInt(3, 5));
	EmitSoundToAllAny(sound, ent);
	
	rp_ScheduleEntityInput(ent, 0.25, "KillHierarchy");
}
// ------------------------------------------------------------------------------
public void gasExplode(int client, int ent) {
	float vecOrigin[3];
	Entity_GetAbsOrigin(ent, vecOrigin);
	
	int ent1 = CreateEntityByName("env_particlesmokegrenade");	
	ActivateEntity(ent1);
	DispatchSpawn(ent1);
	SetEntProp(ent1, Prop_Send, "m_CurrentStage", 1); 
	SetEntPropEnt(ent1, Prop_Send, "m_hOwnerEntity", client);
		
	TeleportEntity(ent1, vecOrigin, NULL_VECTOR, NULL_VECTOR);
		
	SetVariantString("!activator");
	rp_AcceptEntityInput(ent1, "SetParent", ent);
	
	SetEntPropFloat(ent1, Prop_Send, "m_FadeStartTime", 8.0);
	SetEntPropFloat(ent1, Prop_Send, "m_FadeEndTime", 16.0);
	
	CreateTimer(0.01, gasShot, EntIndexToEntRef(ent));
	rp_ScheduleEntityInput(ent, 15.25, "KillHierarchy");
}
public Action gasShot(Handle timer, any ent) {
	ent = EntRefToEntIndex(ent);
	if( !IsValidEdict(ent) || !IsValidEntity(ent) )
		return Plugin_Handled;
	
	int attacker = GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity");
	float vecCenter[3], vecOrigin[3], time = GetGameTime() + 20.0;
	Entity_GetAbsOrigin(ent, vecCenter);
	
	for(int i=1; i<=MaxClients; i++) {
		if( !IsValidClient(i) )
			continue;
		
		GetClientEyePosition(i, vecOrigin);
		if( GetVectorDistance(vecOrigin, vecCenter) >= 200.0 )
			continue;
		if( rp_GetZoneBit(rp_GetPlayerZone(i)) & BITZONE_PEACEFULL )
			continue;
		
		rp_ClientDamage(i, Math_GetRandomInt(2, 6), attacker, "ctf_nade_gas");
		rp_SetClientFloat(i, fl_HallucinationTime, time);				
	}
	
	CreateTimer(0.2, gasShot, EntIndexToEntRef(ent));
	return Plugin_Handled;
}
// ------------------------------------------------------------------------------
bool boosted[2048];
public void EMPExplode(int client, int ent) {
	
	EmitSoundToAllAny("grenades/emp_explosion.mp3", ent);
	EmitSoundToAllAny("grenades/emp_explosion.mp3", ent);
	
	boosted[ent] = false;
	CreateTimer(0.75, EMPExplode_Task, ent);
}
public void EMPExplode2(int client, int ent) {
	
	EMPExplode(client, ent);
	boosted[ent] = true;
	
	// plus bruyant:
	EmitSoundToAllAny("grenades/emp_explosion.mp3", ent);
	EmitSoundToAllAny("grenades/emp_explosion.mp3", ent);
}
public Action EMPExplode_Task(Handle timer, any ent) {
	
	int kev, client = GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity");	
	float vecOrigin[3],  damage = 0.0, vecOrigin2[3];
	char classname[64];
	int attacker = GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity");
	Entity_GetAbsOrigin(ent, vecOrigin);
	
	for(int i=1; i<=2048; i++) {
		if( !IsValidEdict(i) )
			continue;
		if( !IsValidEntity(i) )
			continue;
		
		
		GetEdictClassname(i, classname, sizeof(classname));
		
		if( StrEqual(classname, "player") || StrContains(classname, "weapon_") == 0 ||
			StrEqual(classname, "rp_cashmachine")  || StrEqual(classname, "rp_bigcashmachine") ||
			StrEqual(classname, "rp_mine") || StrEqual(classname, "rp_sentry") ) {
			
			if( StrContains(classname, "weapon_knife") == 0 )
				continue;
			if( rp_GetZoneBit(rp_GetPlayerZone(i)) & BITZONE_PEACEFULL )
				continue;
			
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", vecOrigin2);
			
			if( GetVectorDistance(vecOrigin, vecOrigin2) > 400.0 )
				continue;
			
			damage += 52.5;
			
			TE_SetupExplosion(vecOrigin2, g_cExplode, 1.0, 0, 0, 25, 25);
			TE_SendToAll();
			
			TE_SetupBeamRingPoint(vecOrigin, 1.0, 26.0, g_cShockWave, 0, 0, 20, 0.20, 50.0, 0.0, {255, 255, 255, 255}, 1, 0);
			TE_SendToAll();
			
			TE_SetupBeamRingPoint(vecOrigin, 0.1, 25.0, g_cBeam, 0, 0, 10, 0.20, 50.0, 0.0, {255, 200, 50, 200}, 1, 0);
			TE_SendToAll();
			
			if( StrContains(classname, "weapon_") == 0 && GetEntPropEnt(i, Prop_Send, "m_hOwnerEntity") <= 0 ) {
				rp_AcceptEntityInput(i, "Kill");
			}
			else if( StrEqual(classname, "rp_mine")  ) {
				rp_AcceptEntityInput(i, "Kill");
			}
			else if( StrEqual(classname, "rp_sentry") && boosted[ent]  ) {
				int owner = rp_GetBuildingData(i, BD_owner);

				if( !IsValidClient(owner) || (rp_ClientCanAttack(client, owner) && client != owner) )
					rp_SetBuildingData(i, BD_HackedTime, GetTime() + 20);
			}
			else {
				if( IsValidClient(i) && !(rp_GetZoneBit(rp_GetPlayerZone(i)) & BITZONE_PEACEFULL) ) {
					
					if( boosted[ent] )
						kev = rp_GetClientInt(i, i_Kevlar);
					else
						kev = rp_GetClientInt(i, i_Kevlar) / 2;

					damage += float(kev);
					kev -= 50;
					if( kev < 0 )
						kev = 0;
					
					if( boosted[ent] )
						kev = 0;
					
					rp_SetClientInt(i, i_Kevlar, kev);
					FakeClientCommand(i, "use weapon_fists"); 
					rp_SetClientFloat(i, fl_TazerTime, GetGameTime() + 0.5);
				}
				else {
					rp_ClientDamage(i, 50, client, "ctf_nade_emp");
				}
			}
		}
	}
	
	vecOrigin[2] += 1.0;
	
	rp_Effect_Explode(vecOrigin, damage, 400.0, attacker, "ctf_nade_emp");
	
	
	TE_SetupExplosion(vecOrigin, g_cExplode, 1.0, 0, 0, 100, 400);
	TE_SendToAll();
	
	TE_SetupBeamRingPoint(vecOrigin, 1.0, 401.0, g_cShockWave, 0, 0, 20, 0.20, 50.0, 0.0, {255, 255, 255, 255}, 1, 0);
	TE_SendToAll();
	
	if( boosted[ent] )
		TE_SetupBeamRingPoint(vecOrigin, 0.1, 400.0, g_cBeam, 0, 0, 10, 0.20, 50.0, 0.0, {50, 255, 200, 200}, 1, 0);
	else
		TE_SetupBeamRingPoint(vecOrigin, 0.1, 400.0, g_cBeam, 0, 0, 10, 0.20, 50.0, 0.0, {255, 200, 50, 200}, 1, 0);

	TE_SendToAll();
	
	rp_ScheduleEntityInput(ent, 0.25, "KillHierarchy");
}
// ------------------------------------------------------------------------------
public Action Cmd_ItemFireWork(int args) {
	int client = GetCmdArgInt(1);
	int item_id = GetCmdArgInt(args);
	rp_ClientGiveItem(client, item_id, 1);
	
	CreateTimer(0.1, task_OpenFirework, client);
}
public Action Cmd_ItemHighJump(int args) {
	
	int client = GetCmdArgInt(1);
	
	float velocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", velocity);
	velocity[0] += GetRandomFloat(-100.0, 100.0);
	velocity[1] += GetRandomFloat(-100.0, 100.0);
	velocity[2] += GetRandomFloat(500.0, 750.0);
	
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
	
	ServerCommand("sm_effect_particles %d Trail5 1 footplant_L", client);
	ServerCommand("sm_effect_particles %d Trail5 1 footplant_R", client);
	
	return Plugin_Handled;
}
// ------------------------------------------------------------------------------
public Action Cmd_ItemBomb(int args) {
	
	int client = GetCmdArgInt(1);
	int target = rp_GetClientTarget(client);
	int item_id = GetCmdArgInt(args);
	
	if( rp_GetZoneBit( rp_GetPlayerZone(client) ) & BITZONE_PEACEFULL ) {
		ITEM_CANCEL(client, item_id);
		CPrintToChat(client, "" ...MOD_TAG... " Cet objet est interdit où vous êtes.");
		return Plugin_Handled;
	}
	
	char classname[64];
	GetEdictClassname(target, classname, sizeof(classname));
	if( StrContains("prop_door_rotating|func_door|chicken|player|rp_cashmachine|rp_bigcashmachine|rp_plant|weapon|prop_physics|", classname) == -1 ) {
		ITEM_CANCEL(client, item_id);
		return Plugin_Handled;
	}
	if( !rp_IsEntitiesNear(client, target) ) {
		ITEM_CANCEL(client, item_id);
		return Plugin_Handled;
	}

	rp_SetClientInt(client, i_LastAgression, GetTime());

	Handle dp;
	CreateDataTimer(15.0, ItemBombOver, dp, TIMER_DATA_HNDL_CLOSE);
	WritePackCell(dp, EntIndexToEntRef(target) );
	WritePackCell(dp, client);
	
	CPrintToChat(client, "" ...MOD_TAG... " %T", "Bomb_WillExplodeIn", client, 15.0);
	rp_Effect_BeamBox(client, target);
	
	float vecTarget[3];
	GetClientAbsOrigin(client, vecTarget);
	TE_SetupBeamRingPoint(vecTarget, 10.0, 500.0, g_cBeam, g_cGlow, 0, 15, 0.5, 50.0, 0.0, {100, 100, 100,100}, 10, 0);
	TE_SendToAll();
	
	TE_SetupBeamFollow(client, g_cBeam, g_cGlow, 15.0, 5.0, 0.1, 0, {100, 100, 100, 100});
	TE_SendToAll();
	
	return Plugin_Handled;
}
public Action ItemBombOver(Handle timer, Handle dp) {
	
	if( dp == INVALID_HANDLE ) {
		return Plugin_Handled;
	}
	ResetPack(dp);
	
	int target 	= EntRefToEntIndex( ReadPackCell(dp) );
	int client	= ReadPackCell(dp);
	
	float vecOrigin[3];
	if( IsValidClient(target) )
		GetClientEyePosition(target, vecOrigin);
	else if( IsValidEdict(target) )
		Entity_GetAbsOrigin(target, vecOrigin);
	else
		return Plugin_Handled;
	
	rp_Effect_Explode(vecOrigin, 100.0, 128.0, client, "weapon_c4");
	
	return Plugin_Handled;
}

// ----------------------------------------------------------------------------
bool IsAdmin(int client) {
	return view_as<bool>(GetUserFlagBits(client) & (ADMFLAG_ROOT));
}
public Action task_OpenFirework(Handle timer, any client) {
	Menu_Main(client);
}
void Menu_Main(int client) {
	
	char tmp[128];
	rp_GetItemData(ITEM_FEUARTIFICE, item_type_name, tmp, sizeof(tmp));
	Menu menu = new Menu(hdlMenu);
	menu.SetTitle("%s:\n ", tmp);
	
	int cpt = rp_GetClientItem(client, ITEM_FEUARTIFICE) + g_iFreeFirework[client];
	if( cpt > g_iMaxFireworks )
		cpt = g_iMaxFireworks;
	
	Format(tmp, sizeof(tmp), "%T\n ", "Firework_Build", client, g_iFireworksCount[client], cpt);
	menu.AddItem("0", tmp);	
	Format(tmp, sizeof(tmp), "%T", "Firework_Trail", client, g_szParticles[g_iParticleIndex[client]]);
	menu.AddItem("1", tmp);
	Format(tmp, sizeof(tmp), "%T", "Firework_Shot", client, g_szTirs[g_iTirsIndex[client]]);
	menu.AddItem("2", tmp);
	Format(tmp, sizeof(tmp), "%T\n ", "Firework_Fuel", client, g_szPropultion[g_iPropultionIndex[client]]);
	menu.AddItem("3", tmp);
	
	Format(tmp, sizeof(tmp), "%T", "Firework_Start", client);
	menu.AddItem("6", tmp);
	
	Format(tmp, sizeof(tmp), "%T", "Firework_Stop", client);
	menu.AddItem("7", tmp);
	
	menu.Display(client, MENU_TIME_FOREVER);
}
// ----------------------------------------------------------------------------
public int hdlMenu(Handle menu, MenuAction action, int client, int param2) {
	if( action == MenuAction_Select ) {
		char options[64], expl[4][32];
		GetMenuItem(menu, param2, options, sizeof(options));
		
		ExplodeString(options, " ", expl, sizeof(expl), sizeof(expl[]));
		
		int a = StringToInt(expl[0]);
		
		Menu subMenu = null;
		switch( a ) {
			case 0:	FW_Spawn(client);
			
			case 1: g_iParticleIndex[client] = (g_iParticleIndex[client] + 1) % sizeof(g_szParticles);
			case 2:	g_iTirsIndex[client] = (g_iTirsIndex[client] + 1) % sizeof(g_szTirs);
			case 3: g_iPropultionIndex[client] = (g_iPropultionIndex[client] + 1) % sizeof(g_szPropultion);			
			
			case 6:	FW_FIRE(client);
			case 7:	FW_EXPL(client);
		}
		
		if( subMenu == null )
			Menu_Main(client);
		else
			subMenu.Display(client, MENU_TIME_FOREVER);
		
	}
	else if( action == MenuAction_End ) {
		CloseHandle(menu);
	}
	return 0;
}
// ----------------------------------------------------------------------------
void FW_Spawn(int client) {
	if( g_iFireworksCount[client] >= g_iMaxFireworks && !IsAdmin(client) )
		return;
	if( !rp_IsBuildingAllowed(client) )
		return;
	
	if( rp_GetClientItem(client, ITEM_FEUARTIFICE) == 0 && !(IsAdmin(client) || g_iFreeFirework[client]>g_iFireworksCount[client]) ) {
		char tmp[128];
		rp_GetItemData(ITEM_FEUARTIFICE, item_type_name, tmp, sizeof(tmp));
		CPrintToChat(client, ""...MOD_TAG..." %T", "Error_ItemMissing", client, tmp);
		return;
	}
	
	if( rp_GetClientItem(client, ITEM_FEUARTIFICE) > 0 ) {
		rp_ClientGiveItem(client, ITEM_FEUARTIFICE, -1);
	}
	
	float pos[3];
	GetClientAbsOrigin(client, pos);
	
	FW_SpawnAtPosition(client, pos, g_iParticleIndex[client], g_iTirsIndex[client], g_iPropultionIndex[client]);
	g_iFireworksCount[client]++;
	
}
void FW_SpawnAtPosition(int client, float pos[3], int particle, int tir, int propultion) {
	int ent = CreateEntityByName("hegrenade_projectile");
	DispatchKeyValue(ent, "classname", "fireworks");
	DispatchSpawn(ent);
	Entity_SetModel(ent, LAUNCHER_MODEL);
	Entity_SetOwner(ent, client);
	Entity_SetAbsOrigin(ent, pos);
	SetEntityGravity(ent, 0.1);
	SetEntProp(ent, Prop_Send, "m_CollisionGroup", COLLISION_GROUP_WEAPON);
	SetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity", client);
	SetEntPropFloat(ent,  Prop_Send, "m_flModelScale", LAUNCHER_SCALE);
	
	g_iFireworkOwner[ent] = client;
	g_iParticleIndex[ent] = particle;
	g_iTirsIndex[ent] = tir;
	g_iPropultionIndex[ent] = propultion;
	g_flLastDir[ent][0] = g_flLastDir[ent][1] = 0.0;
	g_flLastDir[ent][1] = 1.0;
	
	if( g_iTirsIndex[ent]  == 0 )
		CreateTimer(0.0, FW_Launch, ent);
	if( g_iTirsIndex[ent]  == 1 )
		CreateTimer(3.0, FW_Launch, ent);
	if( g_iTirsIndex[ent]  == 2 )
		CreateTimer(10.0, FW_Launch, ent);
}
public Action FW_Launch(Handle timer, any ent) {
	if( !IsValidEdict(ent) || !IsValidEntity(ent) )
		return Plugin_Handled;
	
	float dir[3];
	dir[2] = 1.0;
	ScaleVector(dir, FIREWOKRS_SPEED);
	
	TeleportEntity(ent, NULL_VECTOR, NULL_VECTOR, dir);
	TE_SetupParticle(g_szParticles[g_iParticleIndex[ent]][0], ent, 0);
	TE_SendToAll(-1.0);
	g_flStart[ent] = GetTickedTime();
	
	SDKHook(ent, SDKHook_Touch, FW_Touch);
	CreateTimer(0.0, FW_Think, ent, TIMER_REPEAT);
	
	return Plugin_Continue;
}
public Action FW_Think(Handle timer, any ent) {	
	if( !IsValidEdict(ent) || !IsValidEntity(ent) )
		return Plugin_Stop;
	
	float dir[3], ang[3], src[3], dst[3];
	
	switch( g_iPropultionIndex[ent] ) {
		case 0: {
			dir[0] = 0.0;
			dir[1] = 0.0;
			dir[2] = 1.0;
		}
		case 1: {
			dir[0] = g_flLastDir[ent][0] + Math_GetRandomFloat(-0.1, 0.1);
			dir[1] = g_flLastDir[ent][1] + Math_GetRandomFloat(-0.1, 0.1);
			dir[2] = 1.0;
		}
		case 2: {
			dir[0] = g_flLastDir[ent][0] + Math_GetRandomFloat(-1.0, 1.0);
			dir[1] = g_flLastDir[ent][1] + Math_GetRandomFloat(-1.0, 1.0);			
			dir[2] = 1.0 + (g_flLastDir[ent][2] + Math_GetRandomFloat(-1.0, 1.0)) * (GetTickedTime() - g_flStart[ent]) / 10.0;
		}
		case 3: {
			
			if( g_iFireworkOwner[ent] > 0 ) {
				Entity_GetAbsOrigin(ent, src); 
				rp_GetClientTarget(g_iFireworkOwner[ent], dst);
				
				for (int i = 0; i <= 2; i++)
					dir[i] = dst[i] - src[i];
				
				
				if( GetVectorDistance(src, dst, true) <= 64.0*64.0 )
					FW_Touch(ent, 0);
			}
			else {
				dir[0] = g_flLastDir[ent][0] + Math_GetRandomFloat(-0.1, 0.1);
				dir[1] = g_flLastDir[ent][1] + Math_GetRandomFloat(-0.1, 0.1);
				dir[2] = 1.0;
			}
		}
		case 4: {
			float length = FLT_MAX, tmp;
			int target;
			
			Entity_GetAbsOrigin(ent, src);
	
			for (int i = 1; i <= MaxClients; i++) {
				if( !IsValidClient(i) || !IsPlayerAlive(i) || g_iFireworkOwner[ent] == i)
					continue;
						
				GetClientEyePosition(i, dst);
				tmp = GetVectorDistance(src, dst, true);
				
				if( tmp < length && IsPointVisible(src, dst) ) {
					length = tmp;
					target = i;
				}
			}
			
			if( target > 0 ) {
				if( length <= (64.0*64.0) )
					FW_Touch(ent, target);
				
				GetClientEyePosition(target, dst);				
				for (int i = 0; i <= 2; i++)
					dir[i] = dst[i] - src[i];
			}
			else
				dir[2] = 1.0;
		}
	}
	
	NormalizeVector(dir, dir);
	g_flLastDir[ent] = dir;
	
	ScaleVector(dir, FIREWOKRS_SPEED);
	GetVectorAngles(dir, ang);
	
	TeleportEntity(ent, NULL_VECTOR, ang, dir);
	
	return Plugin_Continue;
}
public Action FW_Touch(int ent, int touched) {
	if( g_flStart[ent]+0.25 < GetTickedTime() ) {
		SDKUnhook(ent, SDKHook_Touch, FW_Touch);		
		FW_Explode(ent);
	}
}
void FW_Explode(int ent) {
	float pos[3];
	Entity_GetAbsOrigin(ent, pos);
	pos[2] -= 100.0;
	char sound[128];
	Format(sound, sizeof(sound), "weapons/hegrenade/explode%i.wav", Math_GetRandomInt(3, 5));
	EmitSoundToAllAny(sound, SOUND_FROM_WORLD, _, _, _, _, _, _, pos);
	
	TE_SetupParticle("firework_crate_explosion_01", ent, -1);
	TE_SendToAll(-1.0);
	TE_SetupParticle("firework_crate_explosion_02", ent, -1);
	TE_SendToAll(-1.0);
	
	SetEntityRenderMode(ent, RENDER_NONE);
	SetEntityMoveType(ent, MOVETYPE_NONE);
	
	if( g_iFireworkOwner[ent] > 0 ) {
		g_iFireworksCount[g_iFireworkOwner[ent]]--;
		Menu_Main(g_iFireworkOwner[ent]);
	
		rp_IncrementSuccess(g_iFireworkOwner[ent], success_list_fireworks);
		g_iFireworkOwner[ent] = 0;
	}
	AcceptEntityInput(ent, "Kill");
}
void FW_FIRE(int client) {
	float timer = 0.0;
	
	for (int i = MaxClients; i <= 2048; i++) {
		if( g_iFireworkOwner[i] == client && g_iTirsIndex[i] == 3 ) {
			g_iTirsIndex[i] = 0;
			CreateTimer(timer, FW_Launch, i);
			timer += 0.1;
		}
	}
}
void FW_EXPL(int client) {
	for (int i = MaxClients; i <= 2048; i++) {
		if( g_iFireworkOwner[i] == client ) {
			FW_Explode(i);
		}
	}
}
// ----------------------------------------------------------------------------
bool IsPointVisible(const float start[3], const float end[3]) {
	TR_TraceRayFilter(start, end, MASK_OPAQUE, RayType_EndPoint, TraceEntityFilterStuff);
	return TR_GetFraction() >= 0.75;
}
public bool TraceEntityFilterStuff(int entity, int mask) {
	return (entity < 0);
}
// ----------------------------------------------------------------------------
void TE_SetupParticle(const char[] name, int entity, int attachmentID) {
	static int table = INVALID_STRING_TABLE;
	static int effectIndex = -1;
	if (table == INVALID_STRING_TABLE)
		table = FindStringTable("ParticleEffectNames");	
	if( effectIndex < 0 )
		effectIndex = GetEffectIndex("ParticleEffect");
	
	float dst[3];
	GetEntPropVector(entity, Prop_Data, "m_vecOrigin", dst);
	
	TE_Start("EffectDispatch");
	TE_WriteNum("m_nHitBox", FindStringIndex(table, name));
	TE_WriteFloatArray("m_vOrigin.x", dst, 3);
	TE_WriteFloatArray("m_vStart.x", dst, 3);
	TE_WriteNum("m_nAttachmentIndex", attachmentID >= 0 ? attachmentID : 0 );
	TE_WriteNum("entindex", entity);
	TE_WriteNum("m_fFlags", attachmentID >= 0 ? (1<<0) : 0 );
	TE_WriteNum("m_nDamageType", attachmentID >= 0 ? 1 : 0);
	TE_WriteNum("m_iEffectName", effectIndex);
}
int GetEffectIndex(const char[] sEffectName) {
	static int table = INVALID_STRING_TABLE;

	if (table == INVALID_STRING_TABLE)
		table = FindStringTable("EffectDispatch");
	
	int iIndex = FindStringIndex(table, sEffectName);
	if(iIndex != INVALID_STRING_INDEX)
		return iIndex;
	
	return 0;
}
void PrecacheParticleEffect(const char[] sEffectName) {
	static int table = INVALID_STRING_TABLE;
	if (table == INVALID_STRING_TABLE)
		table = FindStringTable("ParticleEffectNames");
	
	bool save = LockStringTables(false);
	AddToStringTable(table, sEffectName);
	LockStringTables(save);
}
void PrecacheEffect(const char[] sEffectName) {
	static int table = INVALID_STRING_TABLE;
	if (table == INVALID_STRING_TABLE)
		table = FindStringTable("EffectDispatch");
	
	bool save = LockStringTables(false);
	AddToStringTable(table, sEffectName);
	LockStringTables(save);
}
