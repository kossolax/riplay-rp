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
		if( StrContains(g_szItemList[itemID][item_type_extra_cmd], "rp_item_raw") == 0 )
			continue;
		if( itemID == ITEM_JETONROUGE || itemID == ITEM_JETONBLEU )
			continue;
		if( StrEqual(g_szItemList[itemID][item_type_job_id], "51") || StrEqual(g_szItemList[itemID][item_type_job_id], "31") || StrEqual(g_szItemList[itemID][item_type_job_id], "211") )
			continue;
		
		cost = cost + (StringToInt(g_szItemList[itemID][item_type_prix]) * amount);
	}
	
	g_iUserData[client][i_ItemBankPrice] = cost;
}
