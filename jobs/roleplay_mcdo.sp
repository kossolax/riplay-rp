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

public Plugin myinfo = {
	name = "Jobs: Mc'Do", author = "KoSSoLaX",
	description = "RolePlay - Jobs: Mc'Donalds",
	version = __LAST_REV__, url = "https://www.ts-x.eu"
};

int g_cBeam, g_cGlow, g_nbMdItems;
bool g_eMwAct[2048];
// ----------------------------------------------------------------------------
public Action Cmd_Reload(int args) {
	char name[64];
	GetPluginFilename(INVALID_HANDLE, name, sizeof(name));
	ServerCommand("sm plugins reload %s", name);
	return Plugin_Continue;
}
public void OnPluginStart() {
	RegServerCmd("rp_quest_reload", Cmd_Reload);
	RegServerCmd("rp_item_hamburger",	Cmd_ItemHamburger,		"RP-ITEM",	FCVAR_UNREGISTERED);
	RegServerCmd("rp_item_banane",		Cmd_ItemBanane,			"RP-ITEM",	FCVAR_UNREGISTERED);
	g_nbMdItems = -1;
	for (int j = 1; j <= MaxClients; j++)
		if( IsValidClient(j) )
			OnClientPostAdminCheck(j);
}

public Action RP_OnPlayerGotPay(int client, int salary, int & topay, bool verbose) {
	
	int vit_level = GetLevelFromVita(rp_GetClientFloat(client, fl_Vitality));
	
	if( vit_level > 0 ) {
		float multi = GetVitaFactor(vit_level);
		
		int sum = RoundToCeil(float(salary) * multi) - salary;
		
		if( verbose )
			CPrintToChat(client, "{lightblue}[TSX-RP]{default} Votre vitalité de niveau %d vous fait remporté %d$ supplémentaire.", vit_level, sum);
		
		topay += sum;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}
public void OnMapStart() {
	PrecacheSoundAny("ambient/tones/equip2.wav");
	PrecacheSoundAny("ambient/machines/lab_loop1.wav");
	g_cBeam = PrecacheModel("materials/sprites/laserbeam.vmt", true);
	g_cGlow = PrecacheModel("materials/sprites/glow01.vmt", true);
}
public void OnClientPostAdminCheck(int client){
	if(g_nbMdItems == -1){
		int jobID;
		for(int i = 0; i < MAX_ITEMS; i++){
			if( rp_GetItemInt(i, item_type_prix) <= 0 )
				continue;
			if( rp_GetItemInt(i, item_type_auto) == 1 )
				continue;
			jobID = rp_GetItemInt(i, item_type_job_id);
			if(jobID != 21)
				continue;

			g_nbMdItems++;
		}
	}
	rp_HookEvent(client, RP_OnPlayerBuild,	fwdOnPlayerBuild);
}
// ------------------------------------------------------------------------------
public Action fwdOnPlayerBuild(int client, float& cooldown){
	if( rp_GetClientJobID(client) != 21 )
		return Plugin_Continue;
	
	int ent = BuildingMicrowave(client);
	
	if( ent > 0 )
		rp_SetClientStat(client, i_TotalBuild, rp_GetClientStat(client, i_TotalBuild)+1);

	cooldown = 3.0;
	return Plugin_Stop;
}
int BuildingMicrowave(int client) {
	
	if( !rp_IsBuildingAllowed(client) )
		return 0;
	
	char classname[64], tmp[64];
	Format(classname, sizeof(classname), "rp_microwave");
	
	for(int i=1; i<=2048; i++) {
		if( !IsValidEdict(i) )
			continue;
		if( !IsValidEntity(i) )
			continue;
			
		GetEdictClassname(i, tmp, 63);
		
		if( StrEqual(classname, tmp) && rp_GetBuildingData(i, BD_owner) == client ) {
			CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous avez déjà un micro-ondes de branché.");
			return 0;
		}
	}
	
	float vecOrigin[3];
	GetClientAbsOrigin(client, vecOrigin);

	CPrintToChat(client, "{lightblue}[TSX-RP]{default} Construction en cours...");
	
	EmitSoundToAllAny("player/ammo_pack_use.wav", client, _, _, _, 0.66);
	
	int ent = CreateEntityByName("prop_physics");
	
	DispatchKeyValue(ent, "classname", classname);
	DispatchKeyValue(ent, "model", "models/props/cs_office/microwave.mdl");
	DispatchSpawn(ent);
	ActivateEntity(ent);
	
	SetEntityModel(ent,"models/props/cs_office/microwave.mdl");
	SetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity", client);
	SetEntProp( ent, Prop_Data, "m_takedamage", 2);
	SetEntProp( ent, Prop_Data, "m_iHealth", 2000);
	
	
	TeleportEntity(ent, vecOrigin, NULL_VECTOR, NULL_VECTOR);
	
	SetEntityRenderMode(ent, RENDER_NONE);
	ServerCommand("sm_effect_fading \"%i\" \"2.5\" \"0\"", ent);
	
	SetEntityMoveType(client, MOVETYPE_NONE);
	SetEntityMoveType(ent, MOVETYPE_NONE);
	
	
	rp_SetBuildingData(ent, BD_started, GetTime());
	rp_SetBuildingData(ent, BD_owner, client );
	g_eMwAct[ent] = true;
	CreateTimer(3.0, BuildingMicrowave_post, ent);
	return ent;
	
}
public Action BuildingMicrowave_post(Handle timer, any entity) {
	if( !IsValidEdict(entity) && !IsValidEntity(entity) )
		return Plugin_Handled;
	int client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	int time;
	int job = rp_GetClientInt(client, i_Job);
	switch(job){
		case 21: time = 20;
		case 22: time = 25;
		case 23: time = 30;
		case 24: time = 35;
		case 25: time = 40;
		default: time = 40;
	}
	
	rp_SetBuildingData(entity, BD_max, time);
	rp_SetBuildingData(entity, BD_count, 0);

	SetEntityMoveType(client, MOVETYPE_WALK);
	
	if( rp_IsInPVP(entity) ) {
		rp_ClientColorize(entity);
	}
	
	SetEntProp( entity, Prop_Data, "m_takedamage", 2);
	SetEntProp( entity, Prop_Data, "m_iHealth", 2000);
	HookSingleEntityOutput(entity, "OnBreak", BuildingMicrowave_break);
	
	CreateTimer(1.0, Frame_Microwave, entity);
	rp_HookEvent(client, RP_OnPlayerUse, fwdOnPlayerUse);
	
	return Plugin_Handled;
}
public void BuildingMicrowave_break(const char[] output, int caller, int activator, float delay) {
	
	int client = GetEntPropEnt(caller, Prop_Send, "m_hOwnerEntity");
	CPrintToChat(client,"{lightblue}[TSX-RP]{default} Votre micro-ondes vient d'être détruit");
	
	float vecOrigin[3];
	Entity_GetAbsOrigin(caller,vecOrigin);
	TE_SetupSparks(vecOrigin, view_as<float>({0.0,0.0,1.0}),120,40);
	TE_SendToAll();
	rp_UnhookEvent(client, RP_OnPlayerUse, fwdOnPlayerUse);
	//rp_Effect_Explode(vecOrigin, 200.0, 600.0, activator, "micro_onde");
}
public Action fwdOnPlayerUse(int client) {
	static char tmp[64], tmp2[64];
	static float vecOrigin[3],vecOrigin2[3];
	GetClientAbsOrigin(client, vecOrigin);

	if( rp_GetClientJobID(client) != 21 )
		return Plugin_Continue;

	Format(tmp2, sizeof(tmp2), "rp_microwave");

	for(int i=1; i<=2048; i++) {
		if( !IsValidEdict(i) )
			continue;
		if( !IsValidEntity(i) )
			continue;
		
		GetEdictClassname(i, tmp, 63);
		if(g_eMwAct[i])
			continue;
		
		if( StrEqual(tmp, tmp2) && rp_GetBuildingData(i, BD_owner) == client ) {
			Entity_GetAbsOrigin(i, vecOrigin2);
			if( GetVectorDistance(vecOrigin, vecOrigin2) <= 50 ) {
				int time = rp_GetBuildingData(i, BD_count);
				int maxtime = rp_GetBuildingData(i, BD_max);
				if( time >= maxtime &&  rp_GetBuildingData( i, BD_owner )) {
					rp_SetBuildingData(i, BD_count, 0);
					giveHamburger(client);
				}
				g_eMwAct[i] = true;
				CreateTimer(1.0, Frame_Microwave, i);
			}
		}
	}
	return Plugin_Continue;
}
public Action Frame_Microwave(Handle timer, any ent) {
	if(!IsValidEdict(ent) || !IsValidEntity(ent)){
		StopSoundAny(ent, SNDCHAN_AUTO, "ambient/machines/lab_loop1.wav");
		return Plugin_Handled;
	}
	int time = rp_GetBuildingData(ent, BD_count);
	int maxtime = rp_GetBuildingData(ent, BD_max);
	if(time >= maxtime){
		EmitSoundToAllAny("ambient/tones/equip2.wav", ent);
		g_eMwAct[ent] = false;
		return Plugin_Handled;
	}
	if(time == 0){
		EmitSoundToAllAny("ambient/machines/lab_loop1.wav", ent, _, _, _, 0.33);
	}
	if( rp_GetClientBool(rp_GetBuildingData(ent, BD_owner), b_IsAFK) == false )
		rp_SetBuildingData(ent, BD_count, ++time);
	CreateTimer(1.0, Frame_Microwave, ent);
	return Plugin_Handled;
}
public void giveHamburger(int client){
	int mci = Math_GetRandomInt(0, g_nbMdItems);
	int j = 0, jobID;	
	for(int i = 0; i < MAX_ITEMS; i++){
		if( rp_GetItemInt(i, item_type_prix) <= 0 )
			continue;
		if( rp_GetItemInt(i, item_type_auto) == 1 )
			continue;
		jobID = rp_GetItemInt(i, item_type_job_id);
		if(jobID != 21)
			continue;

		if(mci == j){
			rp_ClientGiveItem(client, i, 2);
			break;
		}
		j++;
	}
}
public Action Cmd_ItemHamburger(int args) {
	
	char arg1[12];
	GetCmdArg(1, arg1, 11);
	
	int client = GetCmdArgInt(2);
	int item_id = GetCmdArgInt(args);
	int itemCount = rp_GetClientItem(client, item_id);
	
	if( StrEqual(arg1, "vital") ) {
	
		if( itemCount >= 9 ) {
			rp_ClientGiveItem(client, item_id, 1);
			
			Handle dp;
			CreateDataTimer(0.1, Delay_MenuVital, dp, TIMER_DATA_HNDL_CLOSE);
			WritePackCell(dp, client);
			WritePackCell(dp, item_id);
		}
		else {
			float vita = rp_GetClientFloat(client, fl_Vitality);
		
			rp_SetClientFloat(client, fl_Vitality, vita + 256.0);
			ServerCommand("sm_effect_particles %d Trail12 5 facemask", client);
			CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous ressentez votre vitalité s'augmenter (%.1f -> %.1f).", vita, vita+256.0);
		}
	}
	if( StrEqual(arg1, "energy") ) {
		rp_SetClientFloat(client, fl_Energy, 100.0);
		
		CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous ressentez votre énergie s'augmenter.");
	}
	
	if( StrEqual(arg1, "fat") ) {
		float size = rp_GetClientFloat(client, fl_Size);
		
		rp_SetClientInt(client, i_Kevlar, 100);
		
		if( size < 1.6 ) {
			rp_SetClientFloat(client, fl_Size, size + 0.05);
			SetEntPropFloat(client, Prop_Send, "m_flModelScale", size + 0.05);
		}
	}
	else if( StrEqual(arg1, "mac") ) {
		
		if( !rp_GetClientBool(client, b_MayUseUltimate) ) {
			ITEM_CANCEL(client, item_id);
			CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous ne pouvez pas utiliser cet item pour le moment.");
			return Plugin_Handled;
		}
		rp_SetClientBool(client, b_MayUseUltimate, false);
		
		rp_SetClientFloat(client, fl_Reflect, GetGameTime() + 5.0);
		
		float vecTarget[3];
		GetClientAbsOrigin(client, vecTarget);
		
		TE_SetupBeamRingPoint(vecTarget, 10.0, 300.0, g_cBeam, g_cGlow, 0, 15, 0.5, 50.0, 0.0, {255, 255, 0, 50}, 10, 0);
		TE_SendToAll();
		
		ServerCommand("sm_effect_particles %d Trail11 5 facemask", client);
		
		if( rp_IsInPVP(client) ) {			
			if( rp_GetClientGroupID(client) == rp_GetCaptureInt(cap_bunker) )
				CreateTimer(10.0, AllowUltimate, client);
			else
				CreateTimer(60.0, AllowUltimate, client);
		}
		else{
			CreateTimer(20.0, AllowUltimate, client);
		}
	}
	else if( StrEqual(arg1, "chicken") ) {
		
		if( Math_GetRandomInt(1, 4) == 4 ) {
			GivePlayerItem(client, "weapon_mac10");
		}
		else {
			int ent = CreateEntityByName("chicken");
			DispatchSpawn(ent);
			float vecOrigin[3];
			GetClientAbsOrigin(client, vecOrigin);
			vecOrigin[2] += 20.0;
			
			TeleportEntity(ent, vecOrigin, NULL_VECTOR, NULL_VECTOR);
		}
	}
	else if( StrContains(arg1, "happy") == 0 ) {
		
		int amount = 0;
		
		int iItemRand[MAX_ITEMS*2];
		
		int jobID;
		char cmd[128];
		bool lucky = rp_IsClientLucky(client);
		
		
		for(int i = 0; i < MAX_ITEMS; i++) {
			
			if( rp_GetItemInt(i, item_type_prix) <= 0 )
				continue;
			if( rp_GetItemInt(i, item_type_auto) == 1 )
				continue;
			
			jobID = rp_GetItemInt(i, item_type_job_id);
			
			if( jobID <= 0 || jobID == 61 || jobID == 91 ) // Aucun, Appart, Mafia
				continue;
			
			rp_GetItemData(i, item_type_extra_cmd, cmd, sizeof(cmd));
			if( strlen(cmd) <= 1 ) // UNKNOWN
				continue;
			if( StrContains(cmd, "rp_chirurgie") == 0 )
				continue;
			
			iItemRand[amount] = i;
			amount++;
			
			if( StrContains(cmd, "rp_giveitem weapon_") == 0 ) { // 2x plus de chance d'avoir une arme
				iItemRand[amount] = i;
				amount++;
			}
			if( lucky && rp_GetItemInt(i, item_type_prix) > 2000 ) { // 2x plus de chance... Si on a de la chance grâce aux portes bonheures
				iItemRand[amount] = i;
				amount++;
			}
		}
		
		int rand = iItemRand[ Math_GetRandomInt(0, amount-1) ];
		rp_ClientGiveItem(client, rand, 1, StrEqual(arg1, "happy"));
		
		rp_GetItemData(rand, item_type_name, cmd, sizeof(cmd));
		CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous avez reçu comme cadeau: %s", cmd);
		
		if( rand == GetCmdArgInt(args) )
			rp_IncrementSuccess(client, success_list_mcdo);
	}
	else if( StrEqual(arg1, "box") ) { // TODO: Move to roleplay_armurerie
		
		int amount = 0;
		int iItemRand[MAX_ITEMS];
		bool lucky = rp_IsClientLucky(client);
		
		for(int i = 0; i < MAX_ITEMS; i++) {
			if( rp_GetItemInt(i, item_type_job_id) != 111 )
				continue;			
			
			iItemRand[amount] = i;
			amount++;
			
			if( !lucky && rp_GetItemInt(i, item_type_prix) <= 1000 ) { // 2x plus de chance... Si on a de la chance grâce aux portes bonheures
				iItemRand[amount] = i;
				amount++;
			}
		}
		
		char cmd[128];
		int rand = iItemRand[ Math_GetRandomInt(0, amount-1) ];
		rp_ClientGiveItem(client, rand, 1, true);
		rp_GetItemData(rand, item_type_name, cmd, sizeof(cmd));
		CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous avez reçu comme cadeau: %s", cmd);
	}
	else if( StrEqual(arg1, "drugs") ) { // TODO: Move to roleplay_dealer
		
		int amount = 0;		
		int iItemRand[MAX_ITEMS];
		char cmd[128];
		
		for(int i = 0; i < MAX_ITEMS; i++) {
			
			rp_GetItemData(i, item_type_extra_cmd, cmd, sizeof(cmd));
			if( StrContains(cmd, "rp_item_drug") != 0 )
				continue;
			
			iItemRand[amount] = i;
			amount++;
		}
		
		int rand = iItemRand[ Math_GetRandomInt(0, amount-1) ];
		int rnd = 7+Math_GetRandomPow(1, 5);
		rp_ClientGiveItem(client, rand, rnd, true);
		
		rp_GetItemData(rand, item_type_name, cmd, sizeof(cmd));
		CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous avez reçu comme cadeau: %dx %s", rnd, cmd);
	}
	else if( StrEqual(arg1, "spacy") ) {
		rp_SetClientKnifeType(client, ball_type_fire);
	}
	return Plugin_Handled;
}
public Action Delay_MenuVital(Handle timer, Handle dp) {
	static int amountType[] =  { 1, 2, 3, 5, 10, 20, 25, 50, 100, 200, 250, 500, 1000 };
	
	ResetPack(dp);
	int client = ReadPackCell(dp);
	int itemID = ReadPackCell(dp);
	int count = rp_GetClientItem(client, itemID);
	
	Menu menu = CreateMenu(MenuVital);
	menu.SetTitle("Vous avez %d Hamburger vitaux.\nCombien voulez-vous en manger?\n ", count);
		
	char tmp[64], tmp2[64];
	float vita = rp_GetClientFloat(client, fl_Vitality);
	
	int lvl = GetLevelFromVita(vita);
	float delta = GetVitaFromLevel(lvl + 1) - vita;
	int cpt = RoundToCeil(delta/256.0);	
	
	Format(tmp, sizeof(tmp), "%d %d", itemID, cpt);
	Format(tmp2, sizeof(tmp2), "Manger %d burgers pour atteindre le niveau suivant", cpt);
	menu.AddItem(tmp, tmp2, cpt <= count ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED );
	
	Format(tmp, sizeof(tmp), "%d %d", itemID, count);
	Format(tmp2, sizeof(tmp2), "Manger tout mes %d burgers", count);
	menu.AddItem(tmp, tmp2);
	
		
	for (int i = 0; i < sizeof(amountType); i++) {
		if( count < amountType[i] )
			continue;
		
		Format(tmp, sizeof(tmp), "%d %d", itemID, amountType[i]);
		Format(tmp2, sizeof(tmp2), "Manger %d burgers", amountType[i]);
		
		menu.AddItem(tmp, tmp2);
	}
	
	menu.Display(client, 30);
}
public int MenuVital(Handle menu, MenuAction action, int client, int param2) {
	if( action == MenuAction_Select ) {
		char szMenuItem[64], tmp[2][8];
		GetMenuItem(menu, param2, szMenuItem, sizeof(szMenuItem));
		ExplodeString(szMenuItem, " ", tmp, sizeof(tmp), sizeof(tmp[]));
		
		int itemID = StringToInt(tmp[0]);
		int amount = StringToInt(tmp[1]);
		
		if( rp_GetClientItem(client, itemID) < amount && amount > 0 ) {
			CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous n'avez pas autant d'hamburger.");
			return;
		}
		
		rp_ClientGiveItem(client, itemID, -amount);
		
		float vita = rp_GetClientFloat(client, fl_Vitality);
		float n_vita = vita + (float(amount) * 256.0);
		
		rp_SetClientFloat(client, fl_Vitality, n_vita);
		ServerCommand("sm_effect_particles %d Trail12 5 facemask", client);
		CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous ressentez votre vitalité s'augmenter (%.1f -> %.1f).", vita, n_vita);
	}
	else if( action == MenuAction_End ) {
		if( menu != INVALID_HANDLE )
			CloseHandle(menu);
	}
}
public Action AllowUltimate(Handle timer, any client) {

	rp_SetClientBool(client, b_MayUseUltimate, true);
}
public Action Cmd_ItemBanane(int args) {
	
	int client = GetCmdArgInt(1);
	int itemID = GetCmdArgInt(args);
	int count;
	
	char classname[64], classname2[64];
	Format(classname, sizeof(classname), "rp_banana_%i", client);
	
	for (int i = MaxClients; i <= 2048; i++) {
		if( !IsValidEdict(i) )
			continue;
		GetEdictClassname(i, classname2, sizeof(classname2));
		if( StrEqual(classname, classname2) ) {
			count++;
			if( count >= 10 ) {
				CPrintToChat(client, "{lightblue}[TSX-RP]{default} Vous avez posé trop de bananes.");
				ITEM_CANCEL(client, itemID);
				return Plugin_Handled;
			}
		}
	}

	float vecOrigin[3];
	GetClientAbsOrigin(client, vecOrigin);
	
	int ent = CreateEntityByName("prop_physics_override");
	
	DispatchKeyValue(ent, "classname", classname);
	DispatchKeyValue(ent, "model", "models/props/cs_italy/bananna.mdl");
	DispatchSpawn(ent);
	ActivateEntity(ent);
	
	SetEntityModel(ent, "models/props/cs_italy/bananna.mdl");
	
	SetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity", client);
	
	SetEntityRenderMode(ent, RENDER_NONE);
	
	TeleportEntity(ent, vecOrigin, NULL_VECTOR, NULL_VECTOR);
	
	Entity_SetOwner(ent, client);
	SetEntProp(ent, Prop_Data, "m_takedamage", 0);
	
	ServerCommand("sm_effect_fading \"%i\" \"0.5\" \"0\"", ent);
	rp_ScheduleEntityInput(ent, 60.0, "Kill");
	
	SDKHook(ent, SDKHook_Touch, BuildingBanana_touch);
	return Plugin_Handled;
}
public Action BuildingBanana_touch(int index, int client) {
	if( !IsValidClient(client) )
		return Plugin_Continue;
	
	rp_SetClientInt(client, i_LastAgression, GetTime());
	char sound[128];
	Format(sound, sizeof(sound), "hostage/hpain/hpain%i.wav", Math_GetRandomInt(1, 6));
	EmitSoundToAll(sound, client);

	rp_ClientDamage(client, 25, Entity_GetOwner(index));
	
	if(GetEntityFlags(client) & FL_ONGROUND) {
		
		int flags = GetEntityFlags(client);
		SetEntityFlags(client, (flags&~FL_ONGROUND) );
		SetEntPropEnt(client, Prop_Send, "m_hGroundEntity", -1);
	}
	
	float vecVelocity[3];
	vecVelocity[0] = GetRandomFloat(400.0, 500.0);
	vecVelocity[1] = GetRandomFloat(400.0, 500.0);
	vecVelocity[2] = GetRandomFloat(600.0, 800.0);
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vecVelocity);	
	
	AcceptEntityInput(index, "Kill");
	SDKUnhook(index, SDKHook_Touch, BuildingBanana_touch);
	
	return Plugin_Continue;
}
int GetLevelFromVita(float vita) {
	if( vita <= 64.0 )
		return 0;
	
	int vit_level = RoundToFloor(Logarithm(vita, 2.0) / 2.0 - 3.0);
	if( vit_level < 0 )
		vit_level = 0;
		
	return vit_level;
}
float GetVitaFromLevel(int lvl) {
	return Pow(2.0, (float(lvl)+3.0)*2.0);
}
float GetVitaFactor(int level) {
	float vit_factor = 1.0;
	float prev = 0.2;
	float factor = 0.1;
		
	while( level > 0 ) {
		vit_factor += prev;
		prev += factor;
		level--;
	}
	
	return vit_factor;
}