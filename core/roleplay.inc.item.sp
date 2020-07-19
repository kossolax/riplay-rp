#if defined _roleplay_item_included
#endinput
#endif
#define _roleplay_item_included

#if defined ROLEPLAY_SUB
	#include "../roleplay.sp"
#else
	#include "roleplay.sp"
#endif

// -----------------------------------------------------------------------------------------------------------------
//
//	Items
//
public Action Cmd_ItemMine(int args) {
	char arg1[12];
	GetCmdArg(1, arg1, sizeof(arg1));
	int client = StringToInt(arg1);

	int item_id = GetCmdArgInt(args);
	
	
	float vecOrigin[3];
	GetClientAbsOrigin(client, vecOrigin);
	
	char classname[64];
	
	for(int i=1; i<=2048; i++) {
		if( !IsValidEdict(i) )
			continue;
		if( !IsValidEntity(i) )
			continue;
		
		GetEdictClassname(i, classname, sizeof(classname));
		
		if( StrEqual(classname, "rp_mine") ) {
			float vecOrigin2[3];
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", vecOrigin2);
			
			if( GetVectorDistance(vecOrigin, vecOrigin2) >= 16.0 )
				continue;			
			
			ITEM_CANCEL(client, item_id);
			return Plugin_Handled;
		}
	}
	
	int ent = CreateEntityByName("prop_physics");
	if( !IsValidEdict(ent) )
		return Plugin_Handled;
	
	#if defined GAME_CSGO
	if( !IsModelPrecached("models/grenades/mirv/mirvlet.mdl") )
		PrecacheModel("models/grenades/mirv/mirvlet.mdl");
	#endif
	
	SetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity", client);
	
	#if defined GAME_CSGO
	DispatchKeyValue(ent, "model", "models/grenades/mirv/mirvlet.mdl");
	#endif
	
	DispatchKeyValue(ent, "classname", "rp_mine");
	strcopy(g_szEntityName[ent], sizeof(g_szEntityName[]), "rp_mine");
	ActivateEntity(ent);
	DispatchSpawn(ent);
	SetEntPropFloat(ent, Prop_Send, "m_fadeMinDist", 0.0);
	SetEntPropFloat(ent, Prop_Send, "m_fadeMaxDist", 80.0);
	
	SetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity", client);
	
	rp_AcceptEntityInput(ent, "DisableMotion");
	
	TeleportEntity(ent, vecOrigin, NULL_VECTOR, NULL_VECTOR);
	
	return Plugin_Handled;
}





int findItem(int client, int itemID, bool fromBank = false) {
	int max;
	
	if( fromBank ) {
		
		max = g_iUserData[client][i_ItemBankCount];
		
		for (int i = 0; i < max; i++)
			if( g_iItems_BANK[client][i][STACK_item_id] == itemID )
				return i;
	}
	else {
		
		max = g_iUserData[client][i_ItemCount];
		
		for (int i = 0; i < max; i++)
			if( g_iItems[client][i][STACK_item_id] == itemID )
				return i;
		
		
	}
	
	return -1;
}



public int Native_rp_GetclientItem(Handle plugin, int numParams) {
	int client = GetNativeCell(1);
	int itemID = GetNativeCell(2);
	bool bank = view_as<bool>(GetNativeCell(3));
	int pos = findItem(client, itemID, bank);
	
	if( pos == -1 )
		return 0;
	
	if( bank ) {
		return g_iItems_BANK[client][pos][STACK_item_amount];
	}
	
	return g_iItems[client][pos][STACK_item_amount];	
}
public int Native_rp_giveClientItem(Handle plugin, int numParam) {
	int client = GetNativeCell(1);
	int itemID = GetNativeCell(2);
	int amount = GetNativeCell(3);
	if( amount == 0 )
		return 1;
	bool bank = view_as<bool>(GetNativeCell(4));
	int pos = findItem(client, itemID, bank);
	
	if( pos == -1 ) {
		
		if( bank ) {
			pos = g_iUserData[client][i_ItemBankCount];
			g_iUserData[client][i_ItemBankCount]++;
			g_iItems_BANK[client][pos][STACK_item_id] = itemID;
		}
		else {
			pos = g_iUserData[client][i_ItemCount];
			g_iUserData[client][i_ItemCount]++;
			g_iItems[client][pos][STACK_item_id] = itemID;
		}
	}	
	
	if( bank ) {
		g_iItems_BANK[client][pos][STACK_item_amount] += amount;
		
		if( g_iItems_BANK[client][pos][STACK_item_amount] == 0 ) {
			
			
			int max = g_iUserData[client][i_ItemBankCount] - 1;
			for (; pos <= max ; pos++) {
				g_iItems_BANK[client][pos][STACK_item_amount] = g_iItems_BANK[client][pos + 1][STACK_item_amount];
				g_iItems_BANK[client][pos][STACK_item_id] = g_iItems_BANK[client][pos + 1][STACK_item_id];
			}
			
			g_iUserData[client][i_ItemBankCount] = max;
		}
	}
	else {
		g_iItems[client][pos][STACK_item_amount] += amount;
		
		if( g_iItems[client][pos][STACK_item_amount] == 0 ) {
			
			int max = g_iUserData[client][i_ItemCount] - 1;
			
			for (; pos <= max; pos++) {				
				g_iItems[client][pos][STACK_item_amount] = g_iItems[client][pos + 1][STACK_item_amount];
				g_iItems[client][pos][STACK_item_id] = g_iItems[client][pos + 1][STACK_item_id];
			}
			
			g_iUserData[client][i_ItemCount] = max;
		}
	}
	
	return 1;
}
void updateBankCost(int client) {
	int cost = 0;
	int max = g_iUserData[client][i_ItemBankCount];
	int itemID, amount;
	
	
	for (int i = 0; i < max; i++) {
		
		itemID = g_iItems_BANK[client][i][STACK_item_id];
		amount = g_iItems_BANK[client][i][STACK_item_amount];
		
		if( StrContains(g_szItemList[itemID][item_type_extra_cmd], "rp_item_primal") == 0 )
			continue;
		if( itemID == ITEM_JETONROUGE || itemID == ITEM_JETONBLEU )
			continue;
		
		cost = cost + (StringToInt(g_szItemList[itemID][item_type_prix]) * amount);
	}
	
	g_iUserData[client][i_ItemBankPrice] = cost;
}
