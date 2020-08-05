#if defined _roleplay_event_game_included
#endinput
#endif
#define _roleplay_event_game_included

#if !defined _roleplay_base_included || defined ROLEPLAY_SUB
	#define ROLEPLAY_SUB
	#include "../roleplay.sp"
#else
	#include "roleplay.sp"
#endif


//
// On map started
public void OnMapStart() {

	CPrintToChatAll("" ...MOD_TAG... " Chargement de la config RP.");
	PrintToServer("[TSX-RP] Chargement...");

	char mapname[64];
	GetCurrentMap(mapname, sizeof(mapname));

	//
	AddDownloadsTable();
	//
	LoadServerDatabase();
	//
	PrecacheSoundAny("hostage/hpain/hpain1.wav");
	PrecacheSoundAny("hostage/hpain/hpain2.wav");
	PrecacheSoundAny("hostage/hpain/hpain3.wav");
	PrecacheSoundAny("hostage/hpain/hpain4.wav");
	PrecacheSoundAny("hostage/hpain/hpain5.wav");
	PrecacheSoundAny("hostage/hpain/hpain6.wav");
	PrecacheSoundAny("buttons/button17.wav");
	PrecacheSoundAny("weapons/hegrenade/explode3.wav");
	PrecacheSoundAny("weapons/hegrenade/explode4.wav");
	PrecacheSoundAny("weapons/hegrenade/explode5.wav");
	PrecacheSoundAny("physics/glass/glass_impact_bullet4.wav");
	PrecacheSoundAny("buttons/blip1.wav");
	g_cSnow = PrecacheDecal("DeadlyDesire/maps/snow.vmt");

	char tmp[128];
	for(int rand=0; rand<11; rand++) {
		
		Format(tmp, sizeof(tmp), "%s", g_szPaintBall[rand][0]);

		int cache = PrecacheDecal(tmp);

		ReplaceString(tmp, sizeof(tmp), "vmt", "vtf", false);
		PrecacheDecal(tmp);

		Format(g_szPaintBall[rand][1], sizeof(g_szPaintBall[][]), "%i", cache);

		cache = PrecacheMaterial(tmp);
		Format(g_szPaintBall[rand][2], sizeof(g_szPaintBall[][]), "%i", cache);
	}

	
	g_cBeam = PrecacheModel("materials/sprites/laserbeam.vmt");
	g_cGlow = PrecacheModel("materials/sprites/glow01.vmt");
	g_cScorch = PrecacheDecal("decals/scorch1.vtf");
	g_cHacked = PrecacheModel("materials/sprites/bomb_planted_ring.vmt");
	g_cShockWave = PrecacheModel("materials/effects/concrefract.vmt");
	//
	PrecacheModel(MODEL_CASH);
	PrecacheModel(MODEL_KNIFE);
	PrecacheModel(MODEL_GRAVE);
	PrecacheModel("models/props/cs_office/plant01_gib1.mdl");
	//
	ServerCommand("mp_teamname_1 \"Police\"");
	ServerCommand("mp_teamname_2 \"Civil\"");

	CPrintToChatAll("" ...MOD_TAG... " Config chargée avec succès.");
	PrintToServer("--------------------------------------------------------------");
	PrintToServer("");
	PrintToServer("			Counter-Strike Source: RolePlay");
	PrintToServer("			chargée avec succès");
	PrintToServer("			VERSION: %s %s %s", __TIME__, __DATE__, __LAST_REV__);
	PrintToServer("");
	PrintToServer("--------------------------------------------------------------");


	OnRoundStart();
}
//
// On map Ended
public void OnMapEnd() {
	
	OnRoundEnd();
	SaveDoors();
	
	for(int i=1; i<= MaxClients; i++) {
		if( !IsValidClient(i) )
			continue;
		OnClientDisconnect(i);
	}
}
//
// On Round Started
public void OnRoundStart() {
	PrintToServer("[TSX-RP] OnRoundStart...");

	ServerCommand("mp_ignore_round_win_conditions \"1\"");
	ServerCommand("mp_c4timer \"10\"");
	ServerCommand("rp_force_clean 311");
	ServerCommand("rp_force_clean 310");

	LoadDoors();

	for(int i=1; i < MAX_ENTITIES; i++) {
		g_szEntityWeapons[i] = 0;
		rp_SetBuildingData(i, BD_owner, 0);
	}

	CreateTimer(1.0, PostLoading, _);
}
public Action PostLoading(Handle timer, any zomg) {
	RP_SpawnBank();

	if( g_iHours >= 18 || g_iHours < 6 ) {
		ServerCommand("sm_effect_time night 1.0");
	}
	
	AddServerTag("roleplay");
	AddServerTag("rp");
	AddServerTag("role-play");
	AddServerTag("bajail");
	AddServerTag("ba-jail");

	//CleanUp();
	SteamWorks_SetGameDescription("ROLEPLAY CSGO");
	ServerCommand("rp_quest_reload");
	g_bLoaded = true;

	updateGroupLeader();

	for(int i=1; i <= MaxClients; i++) {
		if( IsClientInGame(i) ) {
			if( IsClientConnected(i) ) {
				if( !g_bUserData[i][b_isConnected2] ) {
					OnClientPostAdminCheck(i);
				}
			}
		}
	}

	return Plugin_Handled;
}
//
// On Round Ended
public void OnRoundEnd() {
	for(int i=1; i <= MaxClients; i++) {
		if( IsClientInGame(i) ) {
			if( IsClientConnected(i) ) {
				if( !IsFakeClient(i) ) {
					OnClientDisconnect(i);
					OnClientPostAdminCheck(i);
				}
			}
		}
	}
}
public void OnEntityDestroyed(int entity) {

	if( IsValidEdict(entity) && IsValidEntity(entity) ) {
		char ClassName[64];
		GetEdictClassname(entity, ClassName, sizeof(ClassName));
		
		if( StrEqual(ClassName, "rp_bank") && rp_GetBuildingData(entity, BD_owner) > 0 ) {
			if( g_iCustomBank[entity] ) {
				int player = -1;
				
				for (int i = 1; i <= MaxClients; i++) {
					if( !IsValidClient(i) )
						continue;
					player = i;
					break;
				}
				
				if( player > 0 ) {
					int active = Client_GetActiveWeapon(player);
					
					float vec[3], rnd[3];
					char name[65];
					int[] data = new int[view_as<int>(BM_Max)];
					DataPackPos max = rp_WeaponMenu_GetMax(g_iCustomBank[entity]);
					DataPackPos position = rp_WeaponMenu_GetPosition(g_iCustomBank[entity]);
					Entity_GetAbsOrigin(entity, vec);
					vec[2] += 32.0;
					
					while( position < max ) {
						rp_WeaponMenu_Get(g_iCustomBank[entity], position, name, data);
						
						if( g_iEntityCount < 2000 ) {
							Format(name, sizeof(name), "weapon_%s", name);
							
							rnd[0] = Math_GetRandomFloat(-250.0, 250.0);
							rnd[1] = Math_GetRandomFloat(-250.0, 250.0);
							rnd[2] = Math_GetRandomFloat(0.0, 100.0);
							
							
							int wepid1 = GivePlayerItem(player, name);
							int wepid = GivePlayerItem(player, name);
							RemovePlayerItem(player, wepid);
							TeleportEntity(wepid, vec, NULL_VECTOR, rnd);
							RemovePlayerItem(player, wepid1);
							RemoveEdict(wepid1);
							
							rp_SetWeaponBallType(wepid, view_as<enum_ball_type>(data[BM_Type]));
							
							if( data[BM_Munition] != -1 ) {
								Weapon_SetPrimaryClip(wepid, data[BM_Munition]);
								Weapon_SetPrimaryAmmoCount(wepid, data[BM_Chargeur]);
							}
						}
						position = rp_WeaponMenu_GetPosition(g_iCustomBank[entity]);
					}
					
					Client_SetActiveWeapon(player, active);
				}
				rp_WeaponMenu_Clear(g_iCustomBank[entity]);
			}
		}
#if defined USING_VEHICLE
		if( StrContains(ClassName, "prop_vehicle_", false) == 0 ) {
			int Driver = GetEntPropEnt(entity, Prop_Send, "m_hPlayer");
			if( Driver != -1 )
				ExitVehicle(Driver, entity, true);
		}
#endif

	}
	
	if( entity > 0 ) {
		g_iEntityCount--;
		g_iWeaponsGroup[entity] = 0;
		rp_SetBuildingData(entity, BD_owner, 0);
		g_iWeapons[entity] = 0;
		g_iWeaponStolen[entity] = 0;
		g_iWeaponFromStore[entity] = 0;
	}
}
public void OnEntityCreated(int entity, const char[] classname)  {
	if( entity <= 0 )
		return;
	
	g_iOriginOwner[entity] = -1;
	g_iEntityCount++;
	
	if( StrEqual(classname, "smokegrenade_projectile") || StrEqual(classname, "flashbang_projectile") ) {
		SDKHook(entity, SDKHook_Think, THINK_Grenade);
	}
	
	strcopy(g_szEntityName[entity], sizeof(g_szEntityName[]), classname);
	
	g_iWeaponsBallType[entity] = ball_type_none;
	g_iWeaponFromStore[entity] = 0;
	rp_SetBuildingData(entity, BD_Trapped, 0);
	//g_iWeaponsBallType
}
public void THINK_Grenade(int entity) {
	if( StrEqual(g_szEntityName[entity], "smokegrenade_projectile") || StrEqual(g_szEntityName[entity], "flashbang_projectile") ) {
		if( rp_GetZoneBit(rp_GetPlayerZone(entity)) & BITZONE_PEACEFULL ) 
			rp_AcceptEntityInput(entity, "Kill");
	}
	else {
		SDKUnhook(entity, SDKHook_Think, THINK_Grenade);
	}
}
public Action EventRoundEnd(Handle ev, const char[] name, bool  bd) {
	OnRoundEnd();

	return Plugin_Continue;
}
public Action EventRoundStart(Handle ev, const char[] name, bool  bd) {
	OnRoundStart();

	return Plugin_Continue;
}

public Action GameLogHook(const char[] message) {
	static char log[2048], arg[64];
	
	static Handle regex;
	if( regex == INVALID_HANDLE )
 		regex = CompileRegex("\".*<([0-9]{1,5})><(?:STEAM_1:[0-1]:[0-9]{1,14})><(?:TERRORIST|CT)>\" \\[(-?[0-9]* -?[0-9]* -?[0-9]*)\\] killed \".*<([0-9]{1,5})><(?:STEAM_1:[0-1]:[0-9]{1,14})><(?:TERRORIST|CT)>\" \\[(-?[0-9]* -?[0-9]* -?[0-9]*)\\] with .*\"");
	
	int amount = MatchRegex(regex, message);
		
	if( amount > 0 ) {
		strcopy(log, sizeof(log), message);
		
		GetRegexSubString(regex, 1, arg, sizeof(arg));
		int client = GetClientOfUserId(StringToInt(arg));
				
		GetRegexSubString(regex, 3, arg, sizeof(arg));
		int target = GetClientOfUserId(StringToInt(arg));
		
		if( IsValidClient(client) && IsValidClient(target) ) {
			GetRegexSubString(regex, 2, arg, sizeof(arg));
			ReplaceStringEx(log, sizeof(log), arg, g_szZoneList[GetPlayerZone(client)][zone_type_name]);
			
			GetRegexSubString(regex, 4, arg, sizeof(arg));
			ReplaceStringEx(log, sizeof(log), arg, g_szZoneList[GetPlayerZone(target)][zone_type_name]);

			if( IsInPVP(client) || IsInPVP(target) || g_iHideNextLog[client][target] == 1 ) {
				g_iHideNextLog[client][target] = 0;
				PrintToConsole(client, "Votre meurtre sur %L a été retiré des logs", target);
				LogToGame("[HIDDEN] %L -> %L", client, target);
				return Plugin_Handled;
			}
			
			if( g_iKillLegitime[client][target] >= GetTime() ) {
				log[strlen(log) - 1] = ' ';
				Format(log, sizeof(log), "%s (légitime)", log);
			}
			
			LogToGame(log);
			return Plugin_Handled;

		}
	}
	else if( StrContains(message, ">\" triggered \"clantag\" (value \"") > 0 ) {
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}
public void OnCvarChange(Handle cvar, const char[] oldVal, const char[] newVal) {
	
	if( cvar == g_hMAX_ENT ) {
		g_iEntityLimit = StringToInt(newVal);
	}
	else if( cvar == g_hCapturable ) {
		if( StrEqual(oldVal, "none") && StrEqual(newVal, "active") )
			g_bIsInCaptureMode = true;
		else if( StrEqual(oldVal, "active") && StrEqual(newVal, "none") )
			g_bIsInCaptureMode = false;
	}
	else if( cvar == g_hAllowDamage ) {
		g_flVehicleDamage = StringToFloat(newVal);
	}
	else if( cvar == g_hEVENT_HIDE ) {
		if( StrEqual(oldVal, "0") && StrEqual(newVal, "1") ) {
			EVENT_HIDE = 1;
		}
		else if( StrEqual(oldVal, "1") && StrEqual(newVal, "0") ){
			EVENT_HIDE = 0;
		}
	}
}

public Action sound_hook(int clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags) {

	if( StrContains(sample, "he_bounce") != -1 ) {
		volume = 0.1;
		return Plugin_Changed;
	}

	return Plugin_Continue;
}
