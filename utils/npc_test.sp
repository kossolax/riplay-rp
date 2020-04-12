#include <sourcemod>
#include <sdktools>
#include <npc_generator>

public OnPluginStart()
{
	RegAdminCmd("sm_zombie", Command_Zombie, ADMFLAG_GENERIC);
	RegServerCmd("rp_loc_zombie",	CmdZombie);
}

public Action:CmdZombie(args) {
	new Float:pos[3];
	new String:arg1[12], String:arg2[12], String:arg3[12];
	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));
	GetCmdArg(3, arg3, sizeof(arg3));
	
	pos[0] = StringToFloat(arg1);
	pos[1] = StringToFloat(arg2);
	pos[2] = StringToFloat(arg3);
	
	NPC_CreateZombie(pos);
	
	
	return Plugin_Handled;
	
}
public Action:Command_Zombie(client, args)
{
	
	decl Float:position[3];
    	
	if(GetPlayerEye(client, position))
		NPC_CreateZombie(position);
	else
		PrintHintText(client, "Wrong Position"); 

	return (Plugin_Handled);
}
stock bool:GetPlayerEye(client, Float:pos[3])
{
	new Float:vAngles[3], Float:vOrigin[3];

	GetClientEyePosition(client, vOrigin);
	GetClientEyeAngles(client, vAngles);

	new Handle:trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);

	if(TR_DidHit(trace))
	{
	 	//This is the first function i ever saw that anything comes before the handle
		TR_GetEndPosition(pos, trace);
		CloseHandle(trace);
		return (true);
	}

	CloseHandle(trace);
	return (false);
}

public bool:TraceEntityFilterPlayer(entity, contentsMask)
{
	return (entity > GetMaxClients() || !entity);
}