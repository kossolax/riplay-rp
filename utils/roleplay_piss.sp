#include <sourcemod>
#include <sdktools>
#include <smlib>

#define PLUGIN_VERSION "1.0"

new bool:g_bPiss[MAXPLAYERS + 1] = { false, ... }

new g_TickCounter = 0;

new BeamSprite;
new HaloSprite;

public Plugin:myinfo =
{
	name = "Piss",
	author = "Zephyrus",
	description = "Privately coded plugin for -[FF]- Fire.",
	version = PLUGIN_VERSION,
	url = ""
}

public OnPluginStart()
{	
	RegConsoleCmd("+piss", Piss_In);
	RegConsoleCmd("-piss", Piss_Out);
}

public OnMapStart()
{
	BeamSprite = PrecacheModel("materials/sprites/laserbeam.vmt");
	HaloSprite = PrecacheModel("materials/sprites/glow01.vmt");
}

//////////////////////////
//		  EVENTS	    //
//////////////////////////

public OnGameFrame()
{
	if(g_TickCounter == 4)
	{
		new Float:pos[3];
		new Float:end[3];
		new Float:ang[3];
		for(new i = 1; i <=MaxClients; ++i)
		{
			if(IsClientConnected(i))
			{
				if(g_bPiss[i])
				{
					GetClientEyePosition(i, pos);
					GetClientEyeAngles(i, ang);
					pos[2] -= 23.0; 
					ang[0] = 60.0;
					
					TR_TraceRayFilter(pos, ang, MASK_PLAYERSOLID, RayType_Infinite, DontHitSelf, i);
					
					TR_GetEndPosition(end);
					
					TE_SetupBeamRingPoint(end, 5.0, 10.0, BeamSprite, HaloSprite, 0, 15, 0.5, 5.0, 1.0, {255, 255, 0, 255}, 10, 0);
					TE_SendToAll();
					
					new Float:ppos[3];
					
					GetClientEyePosition(i, ppos);
					
					ppos[2]-=30.0;
					
					new Float:aang[3];
					
					GetClientEyeAngles(i, aang);
					
					if(aang[1] > 0)
					{
						ppos[0]+=FloatSub(10.0, FloatMul(FloatDiv(10.0, 90.0), aang[1]));
						ppos[1]+=FloatSub(10.0, FloatMul(FloatDiv(10.0, 90.0), FloatAbs(FloatSub(aang[1], 90.0))));
					}
					else
					{
						ppos[0]+=FloatSub(10.0, FloatMul(FloatDiv(10.0, 90.0), FloatAbs(aang[1])));
						ppos[1]-=FloatSub(10.0, FloatMul(FloatDiv(10.0, 90.0), FloatAbs(FloatSub(FloatAbs(aang[1]), 90.0))));
					}
					
					
					aang[0]=0.0;
					aang[1]+=180.0;
					aang[2]=0.0;
					
					TE_SetupBeamPoints(end, ppos, BeamSprite, HaloSprite, 1, 30, 0.1, 1.0, 1.0, 0, 10.0, {255, 255, 0, 255}, 10);
					TE_SendToAll();
				}
			}
		}
		g_TickCounter=0;
	}
	else
	{
		g_TickCounter++;
	}
}

public Action:Piss_In(client, args)
{
	new flags = GetUserFlagBits(client);
	if(!(flags & ADMFLAG_GENERIC || flags & ADMFLAG_ROOT)) {
		return Plugin_Continue;
	}
	
	g_bPiss[client] = true;
	
	return Plugin_Handled;
}

public Action:Piss_Out(client, args)
{
	
	g_bPiss[client] = false;
	
	return Plugin_Handled;
}
public OnClientAuthorized(client) {
	g_bPiss[client] = false;
}
public OnClientDisconnect(client) {
	g_bPiss[client] = false;
}

public Action:CanPiss(Handle:timer, any:client) {
	
	return Plugin_Continue;
}

public bool:DontHitSelf(entity, mask, any:data)
{
	if(entity == data)
		return false;
	return true;
}
