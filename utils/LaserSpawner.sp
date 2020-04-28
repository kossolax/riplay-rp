#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <phun>

#define MAX_LASER		50
#define MAX_CUBES		10
#define	MAX_CUBES_SUP	50
#define TICK_RATE		1.0

new Float:g_fLaserStarts[MAX_LASER][3];
new Float:g_fLaserEnds[MAX_LASER][3];
new g_iHaveStart[MAX_LASER];
new g_iHaveEnd[MAX_LASER];
new g_iLaserSpawned[MAX_LASER];

new Float:g_fLaserCubeMins[MAX_CUBES][MAX_CUBES];
new Float:g_fLaserCubeMaxs[MAX_CUBES][MAX_CUBES];
new Float:g_fLaserCubeCenter[MAX_CUBES][MAX_CUBES];
new Float:g_flLaserCubeTick[MAX_CUBES][2];

new g_iLaserCubeSpawned[MAX_CUBES];
new g_iLaserCubeSuppLine[MAX_CUBES];
new g_iLaserCubeXray[MAX_CUBES];
new g_iLaserCubeNODamage[MAX_CUBES];
new g_iLaserCubePeaceFULL[MAX_CUBES];
new Float:g_flLaserCubeEDIT_SIZE[MAX_CUBES];

new Float:g_flLastDamage[2049];


new g_sprite = -1;
new g_sprite2 = -1;
new g_cLaser = -1;
new g_MaxClients = 64;

new g_iClientCubeID[65];
bool g_iClientBeam[65];


public Plugin:myinfo = 
{
	name = "Laser Spawner",
	author = "KoSSoLaX",
	description = "Spawn a dommaging laser",
	version = "1.2",
	url = "http://www.ts-x.eu"
}

#define PROPTYPE_FAILED -3
#define PROPTYPE_WRONGPROP -2
#define PROPTYPE_BADENT -1
#define PROPTYPE_BOTH 0
#define PROPTYPE_SEND 1
#define PROPTYPE_DATA 2

public OnPluginStart() {
	
	RegAdminCmd("sm_laser_cube", Cmd_LaserMenu, ADMFLAG_BAN);
	RegAdminCmd("sm_laser_cube_size", Cmd_LaserCube_size, ADMFLAG_BAN);
	RegAdminCmd("sm_laser_beacon", Cmd_LaserBeacon, ADMFLAG_BAN);
	
	g_MaxClients = GetMaxClients();
	
	for(new i=1;i<=g_MaxClients; i++) {
		if( !IsValidClient(i) )
			continue;
		
		SDKHook(i, SDKHook_OnTakeDamage,	OnTakeDamage);
	}
}
public Action Cmd_LaserBeacon(int client, int args) {
	char arg1[64];
	
	GetCmdArg(1, arg1, sizeof( arg1 ) );
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count; bool tn_is_ml;
	
	if ((target_count = ProcessTargetString(
	arg1,
	client,
	target_list,
	MAXPLAYERS,
	COMMAND_FILTER_CONNECTED,
	target_name,
	sizeof(target_name),
	tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	for (int i = 0; i < target_count; i++) {
		int target = target_list[i];
		
		g_iClientBeam[target] = !g_iClientBeam[target];
	}
	return Plugin_Handled;
}
public OnClientPutInServer(client) {
	SDKHook(client, SDKHook_OnTakeDamage,	OnTakeDamage);
	g_iClientBeam[client] = false;
}
public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype) {
	
	new bool:changed = false;
	
	for(new id=0; id<MAX_CUBES; id++) {
		if( g_iLaserCubeSpawned[id] && g_iLaserCubePeaceFULL[id] ) {
			//
			// Calcule des l'origine des pointes du cube
			new Float:fMin[3], Float:fMax[3];
			for(new i=0; i<=2; i++) {
				fMin[i] = g_fLaserCubeCenter[id][i] + g_fLaserCubeMins[id][i];
				fMax[i] = g_fLaserCubeCenter[id][i] + g_fLaserCubeMaxs[id][i];
			}
			
			new Float:vecOrigin[3];
			GetClientAbsOrigin(victim, vecOrigin);
			if( PointInArea(vecOrigin, fMin, fMax) )
				changed = true;
			GetClientAbsOrigin(attacker, vecOrigin);
			if( PointInArea(vecOrigin, fMin, fMax) )
				changed = true;
			
			
			GetClientEyePosition(victim, vecOrigin);
			if( PointInArea(vecOrigin, fMin, fMax) )
				changed = true;
			GetClientEyePosition(attacker, vecOrigin);
			if( PointInArea(vecOrigin, fMin, fMax) )
				changed = true;
			
		}
	}
	
	if( changed ) {
		damage *= 0.0;
		return Plugin_Changed;
	}
	
	return Plugin_Continue;
	
}
public Action:Cmd_LaserCube_size(client, args) {
	new String:arg1[12];
	GetCmdArg(1, arg1, sizeof(arg1));
	
	g_flLaserCubeEDIT_SIZE[ g_iClientCubeID[client] ] = StringToFloat(arg1);
	return Plugin_Handled;
}
public OnMapStart() {
	
	for(new i=0; i<MAX_LASER; i++) {
		g_iHaveStart[i] = 0;
		g_iHaveEnd[i] = 0;
		g_iLaserSpawned[i] = 0;
		
	}
	
	if( GetUserMessageType() == UM_Protobuf ) {
		// CSGO
		g_sprite = g_sprite2 = PrecacheModel("materials/sprites/laserbeam.vmt");
		g_cLaser = PrecacheModel("materials/vgui/hud/icon_arrow_up.vmt");
	}
	else {
		// CSS
		g_sprite = PrecacheModel("materials/sprites/xbeam2.vmt");
		g_sprite2 = PrecacheModel("materials/sprites/white.vmt");
	}
}

public OnGameFrame() {	
	
	for(new id=0; id<MAX_CUBES; id++) {
		if( g_iLaserCubeSpawned[id] ) {
			
			//
			// Calcule des l'origine des pointes du cube
			new Float:f_points[8][3];
			
			f_points[0][0] = g_fLaserCubeCenter[id][0] + g_fLaserCubeMaxs[id][0];
			f_points[0][1] = g_fLaserCubeCenter[id][1] + g_fLaserCubeMaxs[id][1];
			f_points[0][2] = g_fLaserCubeCenter[id][2] + g_fLaserCubeMaxs[id][2];
			
			f_points[1][0] = g_fLaserCubeCenter[id][0] + g_fLaserCubeMins[id][0];
			f_points[1][1] = g_fLaserCubeCenter[id][1] + g_fLaserCubeMaxs[id][1];
			f_points[1][2] = g_fLaserCubeCenter[id][2] + g_fLaserCubeMaxs[id][2];
			
			f_points[2][0] = g_fLaserCubeCenter[id][0] + g_fLaserCubeMins[id][0];
			f_points[2][1] = g_fLaserCubeCenter[id][1] + g_fLaserCubeMins[id][1];
			f_points[2][2] = g_fLaserCubeCenter[id][2] + g_fLaserCubeMaxs[id][2];
			
			f_points[3][0] = g_fLaserCubeCenter[id][0] + g_fLaserCubeMaxs[id][0];
			f_points[3][1] = g_fLaserCubeCenter[id][1] + g_fLaserCubeMins[id][1];
			f_points[3][2] = g_fLaserCubeCenter[id][2] + g_fLaserCubeMaxs[id][2];
			
			
			f_points[4][0] = g_fLaserCubeCenter[id][0] + g_fLaserCubeMaxs[id][0];
			f_points[4][1] = g_fLaserCubeCenter[id][1] + g_fLaserCubeMaxs[id][1];
			f_points[4][2] = g_fLaserCubeCenter[id][2] + g_fLaserCubeMins[id][2];
			
			f_points[5][0] = g_fLaserCubeCenter[id][0] + g_fLaserCubeMins[id][0];
			f_points[5][1] = g_fLaserCubeCenter[id][1] + g_fLaserCubeMaxs[id][1];
			f_points[5][2] = g_fLaserCubeCenter[id][2] + g_fLaserCubeMins[id][2];
			
			f_points[6][0] = g_fLaserCubeCenter[id][0] + g_fLaserCubeMins[id][0];
			f_points[6][1] = g_fLaserCubeCenter[id][1] + g_fLaserCubeMins[id][1];
			f_points[6][2] = g_fLaserCubeCenter[id][2] + g_fLaserCubeMins[id][2];
			
			f_points[7][0] = g_fLaserCubeCenter[id][0] + g_fLaserCubeMaxs[id][0];
			f_points[7][1] = g_fLaserCubeCenter[id][1] + g_fLaserCubeMins[id][1];
			f_points[7][2] = g_fLaserCubeCenter[id][2] + g_fLaserCubeMins[id][2];
			
			//
			// Maintenant qu'on a tout les points, nous pouvons tracer les 12 arretes
			TraceKillingBeam( id, f_points[0], f_points[1], true);
			TraceKillingBeam( id, f_points[1], f_points[2], true);
			TraceKillingBeam( id, f_points[2], f_points[3], true);
			TraceKillingBeam( id, f_points[3], f_points[0], true);
			
			TraceKillingBeam( id, f_points[4], f_points[5], true);
			TraceKillingBeam( id, f_points[5], f_points[6], true);
			TraceKillingBeam( id, f_points[6], f_points[7], true);
			TraceKillingBeam( id, f_points[7], f_points[4], true);
			
			TraceKillingBeam( id, f_points[0], f_points[4], true);
			TraceKillingBeam( id, f_points[1], f_points[5], true);
			TraceKillingBeam( id, f_points[2], f_points[6], true);
			TraceKillingBeam( id, f_points[3], f_points[7], true);
			
			if( g_iLaserCubeSuppLine[id] > 0 ) {
				new amount = g_iLaserCubeSuppLine[id];
				
				for(new i=0; i<amount; i++) {
					
					new Float:starts[3];
					new Float:ends[3];
					
					starts[0] = f_points[4][0];
					starts[1] = f_points[4][1];
					starts[2] = f_points[4][2] + ((g_fLaserCubeMaxs[id][2]-g_fLaserCubeMins[id][2])/(amount+1)*(i+1));
					
					ends[0] = f_points[5][0];
					ends[1] = f_points[5][1];
					ends[2] = starts[2];
					
					TraceKillingBeam( id, starts, ends, true);
				}
				for(new i=0; i<amount; i++) {
					
					new Float:starts[3];
					new Float:ends[3];
					
					starts[0] = f_points[5][0];
					starts[1] = f_points[5][1];
					starts[2] = f_points[5][2] + ((g_fLaserCubeMaxs[id][2]-g_fLaserCubeMins[id][2])/(amount+1)*(i+1));
					
					ends[0] = f_points[6][0];
					ends[1] = f_points[6][1];
					ends[2] = starts[2];
					
					TraceKillingBeam( id, starts, ends, true);
				}
				for(new i=0; i<amount; i++) {
					
					new Float:starts[3];
					new Float:ends[3];
					
					starts[0] = f_points[6][0];
					starts[1] = f_points[6][1];
					starts[2] = f_points[6][2] + ((g_fLaserCubeMaxs[id][2]-g_fLaserCubeMins[id][2])/(amount+1)*(i+1));
					
					ends[0] = f_points[7][0];
					ends[1] = f_points[7][1];
					ends[2] = starts[2];
					
					TraceKillingBeam( id, starts, ends, true);
				}
				for(new i=0; i<amount; i++) {
					
					new Float:starts[3];
					new Float:ends[3];
					
					starts[0] = f_points[7][0];
					starts[1] = f_points[7][1];
					starts[2] = f_points[7][2] + ((g_fLaserCubeMaxs[id][2]-g_fLaserCubeMins[id][2])/(amount+1)*(i+1));
					
					ends[0] = f_points[4][0];
					ends[1] = f_points[4][1];
					ends[2] = starts[2];
					
					TraceKillingBeam( id, starts, ends, true);
				}
				
				for(new i=0; i<amount; i++) {
					
					new Float:starts[3];
					new Float:ends[3];
					
					starts[0] = f_points[1][0] + ((g_fLaserCubeMaxs[id][0]-g_fLaserCubeMins[id][0])/(amount+1)*(i+1));
					starts[1] = f_points[1][1];
					starts[2] = f_points[1][2];
					
					ends[0] = starts[0];
					ends[1] = f_points[2][1];
					ends[2] = f_points[1][2];
					
					TraceKillingBeam( id, starts, ends, true);
				}
				for(new i=0; i<amount; i++) {
					
					new Float:starts[3];
					new Float:ends[3];
					
					starts[0] = f_points[5][0] + ((g_fLaserCubeMaxs[id][0]-g_fLaserCubeMins[id][0])/(amount+1)*(i+1));
					starts[1] = f_points[5][1];
					starts[2] = f_points[5][2];
					
					ends[0] = starts[0];
					ends[1] = f_points[6][1];
					ends[2] = f_points[6][2];
					
					TraceKillingBeam( id, starts, ends, true);
				}
			}
			
			if( g_flLaserCubeTick[id][0] < GetGameTime() ) 
				g_flLaserCubeTick[id][0] = GetGameTime() + TICK_RATE;
		}
	}
	for(new i=0; i<MAX_LASER; i++) {
		if( g_iLaserSpawned[i] ) {
			
			TraceKillingBeam( i, g_fLaserStarts[i], g_fLaserEnds[i] );
			
			if( g_flLaserCubeTick[i][1] < GetGameTime() ) 
				g_flLaserCubeTick[i][1] = GetGameTime() + TICK_RATE;
		}
	}
	
	static int offset;
	static float last;
	
	int color[4];
	float start[3], end[3];
	
	if( last < GetTickedTime() ) {
		last = GetTickedTime() + 1.0;
		for (int i = 1; i < MaxClients; i++) {
			if( !g_iClientBeam[i] )
				continue;
			if( !IsValidClient(i) )
				continue;
			
			GetClientEyePosition(i, start);
			GetClientEyePosition(i, end);
			start[2] -= 16.0;
			end[2] = 510.0;
			if( offset == 0 )
				offset = GetEntSendPropOffs(i, "m_clrRender", true);
			for(int j=0; j<=3; j++)
				color[j] = GetEntData(i, offset+j, 1);
			
			
			TE_SetupBeamPoints(start, end, g_cLaser, 0, 0, 0, 1.0, 8.0, 128.0, 32, 0.0, color, 10);
			TE_SendToAllInRange(start, RangeType_Audibility);
		}
	}
}

stock TraceKillingBeam( id, Float:start[3], Float:end[3], bool:IsCube=false) {
	
	if( GetVectorDistance(start, end) <= 2.5 ) {
		return;
	}
	
	if(  IsCube && g_flLaserCubeTick[id][0] < GetGameTime() ||
		!IsCube && g_flLaserCubeTick[id][1] < GetGameTime()
	) {
		
		if(  IsCube && g_flLaserCubeTick[id][0] < 1.0 ||
			!IsCube && g_flLaserCubeTick[id][1] < 1.0
		) {
			
			if( g_iLaserCubeXray[id] ) {
				TE_SetupBeamPoints( start, end, g_sprite2, 0, 0, 10, TICK_RATE, 1.0, 1.0, 0, 0.0, {10, 255, 10, 250}, 10);
			}
			else {
				TE_SetupBeamPoints( start, end, g_sprite, 0, 0, 10, TICK_RATE, 1.0, 1.0, 0, 0.0, {10, 255, 10, 250}, 10);
			}
			
			TE_SendToAll();
		}
		else {
			
			if( g_iLaserCubeXray[id] ) {
				TE_SetupBeamPoints( start, end, g_sprite2, 0, 0, 10, TICK_RATE, 1.0, 1.0, 0, 0.0, {255, 10, 10, 250}, 10);
			}
			else {
				TE_SetupBeamPoints( start, end, g_sprite, 0, 0, 10, TICK_RATE, 1.0, 1.0, 0, 0.0, {255, 10, 10, 250}, 10);
			}
			TE_SendToAll();
		}
	}
	
	if( g_iLaserCubeNODamage[id] ) {
		new Handle:trace = TR_TraceRayFilterEx( start, end, MASK_ALL, RayType_EndPoint, TraceFilter, id);
		
		if( TR_DidHit( trace ) ) {
			
			new index = TR_GetEntityIndex( trace );
			
			if( index > 0 ) {				
				SDKHooks_TakeDamage(index, index, index, 10000.0, DMG_ENERGYBEAM);
				g_flLastDamage[index] = GetGameTime();
			}
		}
		
		CloseHandle( trace );
	}
	
	return;
}
public bool:TraceFilter(entity, contentmask, any:id) {
	if( entity == 0 )
		return false;
	
	if( !IsValidEdict(entity) )
		return false;
	
	if( g_flLastDamage[entity]+0.25 > GetGameTime() )
		return false;
		
	if( IsValidClient(entity) )
		return true;
	if( IsMoveAble(entity) )
		return true;
	
	return false;
}
public Action:Cmd_LaserMenu(client, args) {
	
	new String:arg1[12];
	GetCmdArg(1, arg1, sizeof(arg1));
	
	g_iClientCubeID[client] = StringToInt(arg1);
	EditingLaser(client);
	
	return Plugin_Handled;
}
public EditingLaser(client) {
	
	new Handle:menu = CreateMenu(EditingLaserHandler);
	SetMenuTitle(menu, "Modifier un laser-cube:");
	
	AddMenuItem(menu, "spawn", 		"Spawn");
	
	AddMenuItem(menu, "add_line", 	"Ajouter une ligne");
	AddMenuItem(menu, "del_line", 	"Enlever une ligne");
	
	AddMenuItem(menu, "edit_orig", 	"Deplacer la position");
	AddMenuItem(menu, "edit_size",	"Changer la taille");
	
	AddMenuItem(menu, "delete",	"Retirer le cube");
	
	if( g_iLaserCubeXray[g_iClientCubeID[client]] ) {
		AddMenuItem(menu, "xray",	"Xray ON");
	}
	else {
		AddMenuItem(menu, "xray",	"Xray OFF");
	}
	
	if( g_iLaserCubeNODamage[g_iClientCubeID[client]] ) {
		AddMenuItem(menu, "damage",	"Degat ON");
	}
	else {
		AddMenuItem(menu, "damage",	"Degat OFF");
	}
	
	AddMenuItem(menu, "pos",	"Positions");
	AddMenuItem(menu, "ins",	"Insider");
	
	
	if( g_iLaserCubePeaceFULL[g_iClientCubeID[client]] ) {
		AddMenuItem(menu, "peacefull",	"PeaceFULL ON");
	}
	else {
		AddMenuItem(menu, "peacefull",	"PeaceFULL OFF");
	}
	
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	
	g_flLaserCubeTick[ g_iClientCubeID[client] ][0] = 0.0;
}
public EditingLaserHandler(Handle:menu, MenuAction:action, client, param2) {
	if( action == MenuAction_Select ) {
		new String:options[64];
		GetMenuItem(menu, param2, options, 63);
		
		if( StrEqual( options, "spawn", false) ) {
			
			new Float:f_origin[3];
			GetClientAbsOrigin(client, f_origin);
			
			g_fLaserCubeMins[g_iClientCubeID[client]][0] = 0.0;
			g_fLaserCubeMins[g_iClientCubeID[client]][1] = 0.0;
			g_fLaserCubeMins[g_iClientCubeID[client]][2] = 0.0;
			
			g_fLaserCubeMaxs[g_iClientCubeID[client]][0] = 10.0;
			g_fLaserCubeMaxs[g_iClientCubeID[client]][1] = 10.0;
			g_fLaserCubeMaxs[g_iClientCubeID[client]][2] = 10.0;
			
			g_fLaserCubeCenter[g_iClientCubeID[client]][0] = f_origin[0] + 100.0;
			g_fLaserCubeCenter[g_iClientCubeID[client]][1] = f_origin[1] + 100.0;
			g_fLaserCubeCenter[g_iClientCubeID[client]][2] = f_origin[2] + 10.0;
			
			g_iLaserCubeSpawned[g_iClientCubeID[client]] = 1;
			
			g_flLaserCubeEDIT_SIZE[g_iClientCubeID[client]] = 10.0;
			
			EditingLaser(client);
		}
		else if( StrEqual( options, "delete", false) ) {
			
			g_iLaserCubeSpawned[g_iClientCubeID[client]] = 0;
			EditingLaser(client);
		}
		else if( StrEqual( options, "xray", false) ) {
			
			if( g_iLaserCubeXray[g_iClientCubeID[client]] == 0 ) {
				g_iLaserCubeXray[g_iClientCubeID[client]] = 1;
			}
			else {
				g_iLaserCubeXray[g_iClientCubeID[client]] = 0;
			}
			EditingLaser(client);
		}
		else if( StrEqual( options, "damage", false) ) {
			
			if( g_iLaserCubeNODamage[g_iClientCubeID[client]] == 0 ) {
				g_iLaserCubeNODamage[g_iClientCubeID[client]] = 1;
			}
			else {
				g_iLaserCubeNODamage[g_iClientCubeID[client]] = 0;
			}
			EditingLaser(client);
		}
		else if( StrEqual( options, "peacefull", false) ) {
			
			if( g_iLaserCubePeaceFULL[g_iClientCubeID[client]] == 0 ) {
				g_iLaserCubePeaceFULL[g_iClientCubeID[client]] = 1;
			}
			else {
				g_iLaserCubePeaceFULL[g_iClientCubeID[client]] = 0;
			}
			EditingLaser(client);
		}
		else if( StrEqual( options, "add_line", false) ) {
			
			g_iLaserCubeSuppLine[g_iClientCubeID[client]]++;
			
			if(g_iLaserCubeSuppLine[g_iClientCubeID[client]] > MAX_CUBES_SUP)
				g_iLaserCubeSuppLine[g_iClientCubeID[client]] = MAX_CUBES_SUP;
			
			EditingLaser(client);
		}
		else if( StrEqual( options, "del_line", false) ) {
			
			g_iLaserCubeSuppLine[g_iClientCubeID[client]]--;
			
			if(g_iLaserCubeSuppLine[g_iClientCubeID[client]] < 0)
				g_iLaserCubeSuppLine[g_iClientCubeID[client]] = 0;
			
			EditingLaser(client);
		}
		else if( StrEqual( options, "edit_orig", false) ) {
			
			EditingLaserOrigin(client);
		}
		else if( StrEqual( options, "edit_size", false) ) {
			
			EditingLaserSize(client);
		}
		else if( StrEqual( options, "ins", false) ) {
			
			new Float:fMin[3], Float:fMax[3];
			for(new i=0; i<=2; i++) {
				fMin[i] = g_fLaserCubeCenter[g_iClientCubeID[client]][i] + g_fLaserCubeMins[g_iClientCubeID[client]][i];
				fMax[i] = g_fLaserCubeCenter[g_iClientCubeID[client]][i] + g_fLaserCubeMaxs[g_iClientCubeID[client]][i];
			}
			
			for( new i=1; i<= 2049; i++) {
				if( !IsValidEdict(i) )
					continue;
				if( !IsValidEntity(i) )
					continue;
				
				new prop_type = FindPropType(i, "m_vecOrigin");
				if( prop_type == PROPTYPE_SEND ) {
					new Float:vecPos[3];
					GetEntPropVector(i, Prop_Send, "m_vecOrigin", vecPos);
					if( PointInArea(vecPos, fMin, fMax) ) {
						decl String:classname[128];
						GetEdictClassname(i, classname, 127);
						PrintToConsole(client, "%d %s", i, classname);
					}
				}
			}
		}
		else if( StrEqual( options, "pos", false) ) {
			
			
			
			for(new i=0; i<3; i++ ) {
				if( g_fLaserCubeMins[g_iClientCubeID[client]][i] > g_fLaserCubeMaxs[g_iClientCubeID[client]][i] ) {
					new Float:vecTemp = g_fLaserCubeMins[g_iClientCubeID[client]][i];
					g_fLaserCubeMins[g_iClientCubeID[client]][i] = g_fLaserCubeMaxs[g_iClientCubeID[client]][i];
					g_fLaserCubeMaxs[g_iClientCubeID[client]][i] = vecTemp;
				}
			}
			
			new String:query[1024];
			Format(query, 1023, "INSERT INTO `rp_location_zones` (`id`, `zone_name`, `min_x`, `min_y`, `min_z`, `max_x`, `max_y`, `max_z` )");
			Format(query, 1023, "%s VALUES ( NULL, 'NOM_ZONE', '%i', '%i', '%i', '%i', '%i', '%i' );", 
			query, 
			RoundFloat(g_fLaserCubeCenter[g_iClientCubeID[client]][0] + g_fLaserCubeMins[g_iClientCubeID[client]][0]),
			RoundFloat(g_fLaserCubeCenter[g_iClientCubeID[client]][1] + g_fLaserCubeMins[g_iClientCubeID[client]][1]),
			RoundFloat(g_fLaserCubeCenter[g_iClientCubeID[client]][2] + g_fLaserCubeMins[g_iClientCubeID[client]][2]),
			
			RoundFloat(g_fLaserCubeCenter[g_iClientCubeID[client]][0] + g_fLaserCubeMaxs[g_iClientCubeID[client]][0]),
			RoundFloat(g_fLaserCubeCenter[g_iClientCubeID[client]][1] + g_fLaserCubeMaxs[g_iClientCubeID[client]][1]),
			RoundFloat(g_fLaserCubeCenter[g_iClientCubeID[client]][2] + g_fLaserCubeMaxs[g_iClientCubeID[client]][2])
			
			);
			
			PrintToConsole(client, "Requete pour la sauvegarde:");
			PrintToConsole(client, "--------------------------------------------------\n");
			PrintToConsole(client, "%s", query);
			PrintToConsole(client, "--------------------------------------------------\n");
			
			PrintToChat(client, "Mins: %i %i %i", RoundFloat(g_fLaserCubeCenter[g_iClientCubeID[client]][0] + g_fLaserCubeMins[g_iClientCubeID[client]][0]), RoundFloat(g_fLaserCubeCenter[g_iClientCubeID[client]][1]
			+ g_fLaserCubeMins[g_iClientCubeID[client]][1]), RoundFloat(g_fLaserCubeCenter[g_iClientCubeID[client]][2] + g_fLaserCubeMins[g_iClientCubeID[client]][2]) );
			PrintToChat(client, "Maxs: %i %i %i", RoundFloat(g_fLaserCubeCenter[g_iClientCubeID[client]][0] + g_fLaserCubeMaxs[g_iClientCubeID[client]][0]), RoundFloat(g_fLaserCubeCenter[g_iClientCubeID[client]][1]
			+ g_fLaserCubeMaxs[g_iClientCubeID[client]][1]), RoundFloat(g_fLaserCubeCenter[g_iClientCubeID[client]][2] + g_fLaserCubeMaxs[g_iClientCubeID[client]][2]) );
			EditingLaser(client);
		}
	}
	else if( action == MenuAction_End ) {
		CloseHandle(menu);
	}	
}
stock FindPropType(entity,const String:prop[]) {
	if(!IsValidEntity(entity))
		return PROPTYPE_BADENT;
	
	new bool:NetClsName;
	new PropSend = -1;
	
	decl String:NetClass[50]="empty";
	NetClsName=GetEntityNetClass(entity,NetClass,sizeof(NetClass));
	
	if(NetClsName) {
		PropSend=FindSendPropOffs(NetClass,prop);
		if(PropSend !=- 1)
			return PROPTYPE_SEND;
	}
		
	return PROPTYPE_FAILED;
}
stock bool:PointInArea(Float:f_Points[3], Float:f_Mins[3], Float:f_Maxs[3]) {
	
	if(	f_Points[0] <= f_Maxs[0] && f_Points[1] <= f_Maxs[1] && f_Points[2] <= f_Maxs[2] &&
		f_Points[0] >= f_Mins[0] && f_Points[1] >= f_Mins[1] && f_Points[2] >= f_Mins[2] ) {
		return true;
	}
	
	return false;
}
public EditingLaserOrigin(client) {
	new Handle:menu = CreateMenu(EditingLaserOriginHandler);
	SetMenuTitle(menu, "Modifier un laser-cube:");
	
	AddMenuItem(menu, "monter", 	"Monter");
	AddMenuItem(menu, "dessendre", 	"Dessendre");
	AddMenuItem(menu, "gauche",		"A gauche");
	AddMenuItem(menu, "droite",		"A droite");
	AddMenuItem(menu, "avancer",	"Avancer");
	AddMenuItem(menu, "reculer",	"Reculer");
	
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	
	g_flLaserCubeTick[ g_iClientCubeID[client] ][0] = 0.0;
}
public EditingLaserOriginHandler(Handle:menu, MenuAction:action, client, param2) {
	if( action == MenuAction_Select ) {
		new String:options[64];
		GetMenuItem(menu, param2, options, 63);
		
		if( StrEqual( options, "monter", false) ) {
			
			g_fLaserCubeCenter[g_iClientCubeID[client]][2] += g_flLaserCubeEDIT_SIZE[g_iClientCubeID[client]];
			EditingLaserOrigin(client);
			
		}
		else if( StrEqual( options, "dessendre", false) ) {
			
			g_fLaserCubeCenter[g_iClientCubeID[client]][2] -= g_flLaserCubeEDIT_SIZE[g_iClientCubeID[client]];
			EditingLaserOrigin(client);
		}
		else if( StrEqual( options, "gauche", false) ) {
			
			g_fLaserCubeCenter[g_iClientCubeID[client]][1] += g_flLaserCubeEDIT_SIZE[g_iClientCubeID[client]];
			EditingLaserOrigin(client);
		}
		else if( StrEqual( options, "droite", false) ) {
			
			g_fLaserCubeCenter[g_iClientCubeID[client]][1] -= g_flLaserCubeEDIT_SIZE[g_iClientCubeID[client]];
			EditingLaserOrigin(client);
		}
		else if( StrEqual( options, "avancer", false) ) {
			
			g_fLaserCubeCenter[g_iClientCubeID[client]][0] += g_flLaserCubeEDIT_SIZE[g_iClientCubeID[client]];
			EditingLaserOrigin(client);
		}
		else if( StrEqual( options, "reculer", false) ) {
			
			g_fLaserCubeCenter[g_iClientCubeID[client]][0] -= g_flLaserCubeEDIT_SIZE[g_iClientCubeID[client]];
			EditingLaserOrigin(client);
		}
		
	}
	else if( action == MenuAction_End ) {
		CloseHandle(menu);
	}	
}
public EditingLaserSize(client) {
	new Handle:menu = CreateMenu(EditingLaserSizeHandler);
	SetMenuTitle(menu, "Modifier un laser-cube:");
	
	AddMenuItem(menu, "grandir", 	"Grandir");
	AddMenuItem(menu, "retrecir", 	"Retrecir");
	AddMenuItem(menu, "p_large",	"Plus large");
	AddMenuItem(menu, "m_large",	"Moin large");
	AddMenuItem(menu, "p_profo",	"Plus profond");
	AddMenuItem(menu, "m_profo",	"Moin profond");
	
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	
	g_flLaserCubeTick[ g_iClientCubeID[client] ][0] = 0.0;
}
public EditingLaserSizeHandler(Handle:menu, MenuAction:action, client, param2) {
	if( action == MenuAction_Select ) {
		new String:options[64];
		GetMenuItem(menu, param2, options, 63);
		
		if( StrEqual( options, "grandir", false) ) {
			
			g_fLaserCubeMaxs[g_iClientCubeID[client]][2] += g_flLaserCubeEDIT_SIZE[g_iClientCubeID[client]];
			EditingLaserSize(client);
		}
		else if( StrEqual( options, "retrecir", false) ) {
			
			g_fLaserCubeMaxs[g_iClientCubeID[client]][2] -= g_flLaserCubeEDIT_SIZE[g_iClientCubeID[client]];
			EditingLaserSize(client);
		}
		else if( StrEqual( options, "p_large", false) ) {
			
			g_fLaserCubeMaxs[g_iClientCubeID[client]][1] += g_flLaserCubeEDIT_SIZE[g_iClientCubeID[client]];
			EditingLaserSize(client);
		}
		else if( StrEqual( options, "m_large", false) ) {
			
			g_fLaserCubeMaxs[g_iClientCubeID[client]][1] -= g_flLaserCubeEDIT_SIZE[g_iClientCubeID[client]];
			EditingLaserSize(client);
		}
		else if( StrEqual( options, "p_profo", false) ) {
			
			g_fLaserCubeMaxs[g_iClientCubeID[client]][0] += g_flLaserCubeEDIT_SIZE[g_iClientCubeID[client]];
			EditingLaserSize(client);
		}
		else if( StrEqual( options, "m_profo", false) ) {
			
			g_fLaserCubeMaxs[g_iClientCubeID[client]][0] -= g_flLaserCubeEDIT_SIZE[g_iClientCubeID[client]];
			EditingLaserSize(client);
		}
	}
	else if( action == MenuAction_End ) {
		CloseHandle(menu);
	}	
}
