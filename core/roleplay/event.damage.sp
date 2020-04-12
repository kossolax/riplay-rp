#if defined _roleplay_event_damage_included
#endinput
#endif
#define _roleplay_event_damage_included

#if !defined _roleplay_base_included || defined ROLEPLAY_SUB
	#define ROLEPLAY_SUB
	#include "../roleplay.sp"
#else
	#include "roleplay.sp"
#endif


public Action OnTakeDamage(int victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3]) {
	bool changed = false;
	int victim_zone = GetPlayerZone(victim);
	int attacker_zone = GetPlayerZone(attacker);
	
	
	if( IsValidClient(victim) ) {
		if( attacker == inflictor && inflictor > MaxClients && damagetype == 1 ) {
			float pos[3], min[3], max[3];
			Entity_GetMinSize(victim, min);
			Entity_GetMaxSize(victim, max);
			Entity_GetAbsOrigin(victim, pos);
			ScaleVector(min, 1.05);
			ScaleVector(max, 1.05);
			
			if (inflictor >= MaxClients && IsValidClient(g_iGrabbedBy[inflictor]) ) {
				g_iUserData[g_iGrabbedBy[inflictor]][i_LastAgression] = GetTime();
				if( g_bUserData[g_iGrabbedBy[inflictor]][b_IsMuteKILL] ) { return Plugin_Handled; }
				attacker = g_iGrabbedBy[inflictor];
				changed = true;
			}
		}
	}
	
#if defined USING_VEHICLE
	if( damagetype == 1 && inflictor == 0 && attacker == 0 && weapon == -1 && damageForce[0] == 0.0 && damageForce[1] == 0.0 && damageForce[2] <= -8192.0 ) {
		// Bug relou des voitures.
		return Plugin_Stop;
	}
	if( g_flVehicleDamage > 0.001 && victim == attacker && IsValidClient(victim) && IsValidVehicle(inflictor) && damagetype == 17 ) {
		
		if( g_bUserData[victim][b_GameModePassive] && !(rp_GetZoneBit(rp_GetPlayerZone(victim)) & BITZONE_ROAD) ) {
			damage = 0.0;
			return Plugin_Changed;
		}
		
		float min[3] =  { -16.0, -16.0, -16.0 };
		float max[3] =  { 16.0, 16.0, 16.0 };
		
		
		Handle tr = TR_TraceHullFilterEx(damagePosition, damagePosition, min, max, MASK_ALL, FilterToVehicle, inflictor);
		if( TR_DidHit(tr) ) {
				
			int InVehicle = TR_GetEntityIndex(tr);
			if( IsValidVehicle(InVehicle) ) {
				
				float delta = (SquareRoot(float(GetEntProp(inflictor, Prop_Send, "m_nSpeed"))) + 1.0) / (SquareRoot(float(GetEntProp(InVehicle, Prop_Send, "m_nSpeed"))) + 1.0);
				
				int heal = RoundToCeil(damage * g_flVehicleDamage * delta);
				
				if( heal > 0 ) {
					rp_SetVehicleInt(InVehicle, car_health, rp_GetVehicleInt(InVehicle, car_health) - heal);
				}
				
				heal = RoundToCeil(damage * g_flVehicleDamage * (1.0-delta));
				
				if( heal > 0 ) {
					rp_SetVehicleInt(inflictor, car_health, rp_GetVehicleInt(inflictor, car_health) - heal);
				}
			}
		}
		CloseHandle(tr);
		
		return Plugin_Continue;
	}
	if( IsValidVehicle(attacker) && IsValidVehicle(inflictor) ) {
		
		if( g_flVehicleDamage > 0.001 ) {
			
			if( g_bUserData[victim][b_GameModePassive] && !(rp_GetZoneBit(rp_GetPlayerZone(victim)) & BITZONE_ROAD) ) {
				damage = 0.0;
				return Plugin_Changed;
			}
			
			float min[3] =  { -16.0, -16.0, -16.0 };
			float max[3] =  { 16.0, 16.0, 16.0 };
			
			
			Handle tr = TR_TraceHullFilterEx(damagePosition, damagePosition, min, max, MASK_ALL, FilterToVehicle, inflictor);
			if( TR_DidHit(tr) ) {
					
				int InVehicle = TR_GetEntityIndex(tr);
				if( IsValidVehicle(InVehicle) ) {
					
					float delta = (SquareRoot(float(GetEntProp(inflictor, Prop_Send, "m_nSpeed"))) + 1.0) / (SquareRoot(float(GetEntProp(InVehicle, Prop_Send, "m_nSpeed"))) + 1.0);
					
					int heal = RoundToCeil(damage * g_flVehicleDamage * delta);
					
					if( heal > 0 ) {
						rp_SetVehicleInt(InVehicle, car_health, rp_GetVehicleInt(InVehicle, car_health) - heal);
					}
					
					heal = RoundToCeil(damage * g_flVehicleDamage * (1.0-delta));
					
					if( heal > 0 ) {
						rp_SetVehicleInt(inflictor, car_health, rp_GetVehicleInt(inflictor, car_health) - heal);
					}
				}
			}
			CloseHandle(tr);
		}
		
		if( GetEntPropEnt(inflictor, Prop_Send, "m_hPlayer") > 0 ) {
			attacker = GetEntPropEnt(inflictor, Prop_Send, "m_hPlayer");
			
			if( IsValidClient(attacker ) ) {
				if( g_bUserData[attacker][b_IsMuteKILL] ) { return Plugin_Handled; }
				
				g_iUserData[attacker][i_LastAgression] = GetTime();
				IncrementSuccess(attacker, success_list_carkill);
			}
		}
		return Plugin_Changed;
	}
	
	
	
#endif
	if( attacker == 0 && inflictor == 0 && damagetype == DMG_FALL ) {
		if( g_flUserData[victim][fl_Alcool] >= 1.0 ) {
			damage *= 0.0;
			changed = true;
		}
		if( damagetype & DMG_FALL && g_flUserData[victim][fl_ProtectWorldSpawn] >= GetGameTime() ) {
			damage *= 0.0;
			changed = true;
		}
	}
	if( IsValidClient(attacker) ) {
		
		if( !Client_CanAttack(attacker, victim) ) { g_iUserData[attacker][i_LastAgression] = GetTime(); return Plugin_Handled; }
		if( g_bUserData[attacker][b_IsMuteKILL] ) { g_iUserData[attacker][i_LastAgression] = GetTime(); return Plugin_Handled; }
		if( !IsTutorialOver(attacker) || !IsTutorialOver(victim) ) return Plugin_Handled;
		if( g_flUserData[victim][fl_Invincible] >= GetGameTime() ) return Plugin_Handled;
		if( g_iGrabbing[victim] == attacker ) return Plugin_Handled;
		
		
		
		if( GetZoneBit( attacker_zone ) & BITZONE_PEACEFULL ||  GetZoneBit( victim_zone ) & BITZONE_PEACEFULL ) {
			damage *= 0.0;
			changed = true;
			return Plugin_Handled;
		}
		
		if( g_flUserData[victim][fl_Alcool] >= 0.0 ) {
			float dmg = damage * FloatAbs((2.0 - g_flUserData[victim][fl_Alcool] ) / 2.0);
			if( dmg*10.0 < damage ) {
				dmg = damage / 10.0;
			}
			
			if( dmg < damage ) {
				g_flUserData[victim][fl_Alcool] -= (( damage - dmg ) * 0.01);
				if( g_flUserData[victim][fl_Alcool] <= 0.0 ) {
					g_flUserData[victim][fl_Alcool] = 0.0;
					SendConVarValue(victim, FindConVar("host_timescale"), "1.0000");
				}
			}
			
			damage = dmg;
			changed = true;
		}
		
		if( g_Client_AMP[attacker] >= 0.0 ) {
			damage *= g_Client_AMP[attacker];
			changed = true;
		}

		char sWeapon[32], sInflictor[32];
		int wep_id = GetEntPropEnt(attacker, Prop_Send, "m_hActiveWeapon");
		if(!IsValidEdict(inflictor) )
			inflictor = attacker;

		GetEdictClassname(inflictor, sInflictor, sizeof(sInflictor));
		if( wep_id > 0 )
			GetEdictClassname(wep_id, sWeapon, sizeof(sWeapon));

		
		if( IsValidClient(victim) ) {
			if( IsValidClient(g_iUserData[victim][i_Protect_From]) ) {
				damage *= 0.5;
				changed = true;
				
				TargetBeamBox(g_iUserData[victim][i_Protect_From], attacker);
				g_iUserData[g_iUserData[victim][i_Protect_From]][i_Protect_Last] = attacker;
			}
			if( IsValidClient(g_iUserData[victim][i_Protect_Him]) ) {
				damage *= 0.5;
				changed = true;
			}
			
			if( !(GetZoneBit(victim_zone) & BITZONE_EVENT) ) {
				
				Action a;
				Call_StartForward( view_as<Handle>(g_hRPNative[victim][RP_PreTakeDamage]));
				Call_PushCell(victim);
				Call_PushCell(attacker);
				Call_PushFloatRef(damage);
				Call_PushCell(damagetype);
				Call_Finish(a);
				
				if( a == Plugin_Handled || a == Plugin_Stop )
					return Plugin_Handled;
				if( a == Plugin_Changed )
					changed = true;
				
				Call_StartForward( view_as<Handle>(g_hRPNative[attacker][RP_PreGiveDamage]));
				Call_PushCell(attacker);
				Call_PushCell(victim);
				Call_PushFloatRef(damage);
				Call_PushCell(damagetype);
				Call_Finish(a);
				
				if( a == Plugin_Handled || a == Plugin_Stop )
					return Plugin_Handled;
				if( a == Plugin_Changed )
					changed = true;
				
				
				if( g_iUserData[victim][i_PlayerLVL] <= 20 && g_iKillLegitime[attacker][victim] < GetTime() ) {
					damage = damage / SquareRoot(21.0 - float(g_iUserData[victim][i_PlayerLVL]));
					changed = true;
				}
			}
		}
		
		if( g_bUserData[attacker][b_WeaponIsKnife]	&& inflictor > 0 && inflictor < MaxClients ) {


			damage = float(g_iUserData[attacker][i_KnifeTrain]);
			if( g_iUserData[attacker][i_KnifeTrainAdmin] >= 0 ) {
				damage = float(g_iUserData[attacker][i_KnifeTrainAdmin]);
			}
			changed = true;

			if( !(GetZoneBit( victim_zone ) & BITZONE_BLOCKCHIRU) ) {
				if( g_iUserData[victim][i_Esquive] > 0 && Math_GetRandomInt(1, 100) <= g_iUserData[victim][i_Esquive] ) {
					damage = 0.0;
					g_iUserData[victim][i_Esquive]--;
					return Plugin_Handled;
				}
			}
			if( IsClientInJail(victim) || IsClientInJail(attacker) ) {
				return Plugin_Handled;
			}

			if( !(GetZoneBit( victim_zone ) & BITZONE_EVENT) ) {
				
				Action a;
				Call_StartForward( view_as<Handle>(g_hRPNative[victim][RP_PostTakeDamageKnife]));
				Call_PushCell(victim);
				Call_PushCell(attacker);
				Call_PushFloatRef(damage);
				Call_Finish(a);
				
				if( a == Plugin_Handled || a == Plugin_Stop )
					return Plugin_Handled;
				if( a == Plugin_Changed )
					changed = true;
				
				Call_StartForward( view_as<Handle>(g_hRPNative[attacker][RP_PostGiveDamageKnife]));
				Call_PushCell(attacker);
				Call_PushCell(victim);
				Call_PushFloatRef(damage);
				Call_Finish(a);
				
				if( a == Plugin_Handled || a == Plugin_Stop )
					return Plugin_Handled;
				if( a == Plugin_Changed )
					changed = true;
				
				if( g_iUserData[victim][i_Kevlar] > 0 ) {
					g_iUserData[victim][i_Kevlar] -= RoundFloat(damage);
					if( g_iUserData[victim][i_Kevlar] < 0 )
						g_iUserData[victim][i_Kevlar] = 0;

					damage *= 0.5;
				}
				
				if( g_iUserData[victim][i_PlayerLVL] <= 20 && g_iKillLegitime[attacker][victim] < GetTime() ) {
					damage = damage / SquareRoot(21.0 - float(g_iUserData[victim][i_PlayerLVL]));
					changed = true;
				}
			}			

			if( !g_iClient_OLD[victim] && g_iClient_OLD[attacker] && !(GetZoneBit( victim_zone ) & BITZONE_EVENT) && !IsInPVP(victim) ) {
				damage /= 6.0;
				changed = true;
			}
			
			if( damage > 0.00 ) {
				int heal = GetClientHealth(victim);
				heal -= RoundFloat(damage);
				SetEntityHealth(victim, heal);

				if( heal <= 0 ) {
					SetEntityHealth(victim, 1);
					SDKHooks_TakeDamage(victim, attacker, attacker, damage*10.0);
				}
				else {
					SetEntityHealth(victim, heal);
				}
			}
			
			//
			// Le clique gauche
			if( GetEntPropFloat(wep_id, Prop_Send, "m_flNextPrimaryAttack")-GetGameTime() < 1.0 ) {
				return Plugin_Handled;
			}

			damage *= 0.0;
			if( IsValidClient(victim) 	)
				TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, vecNull);
			//
			// Le clique droit
			return Plugin_Changed;
		}

		if( StrEqual(sInflictor, "inferno") && IsValidClient(attacker) ) {
			if( !(GetZoneBit( victim_zone ) & BITZONE_PEACEFULL))
				IgnitePlayer(victim, 10.0, attacker);
		}

		if( StrEqual(sInflictor, "player") && StrContains(sWeapon, "weapon_") == 0 && !g_bUserData[attacker][b_WeaponIsKnife] && attacker == inflictor ) {
			if( g_iWeaponsGroup[wep_id] > 0 ) {
				if( IsInPVP(victim) || IsInPVP(attacker) ) {
					damage *= 1.5;
					if( StrEqual(sWeapon, "weapon_awp", false) ) {
						int fov = GetEntProp(attacker, Prop_Send, "m_iFOV");
						if( fov == 40 || fov == 10 ) {
							damage *= 5.0;
						}
					}
					if( StrEqual(sWeapon, "weapon_m4a1", false) || StrEqual(sWeapon, "weapon_ak47", false) ) {
						damage *= 1.5;
					}
					
					changed = true;
				}
			}

			if( !(GetZoneBit( victim_zone ) & BITZONE_EVENT) ) {
				
				Action a;
				Call_StartForward( view_as<Handle>(g_hRPNative[victim][RP_PostTakeDamageWeapon]));
				Call_PushCell(victim);
				Call_PushCell(attacker);
				Call_PushFloatRef(damage);
				Call_PushCell(wep_id);
				Call_PushArray(damagePosition, sizeof(damagePosition));
				Call_Finish(a);
				
				if( a == Plugin_Handled || a == Plugin_Stop )
					return Plugin_Handled;
				if( a == Plugin_Changed )
					changed = true;
				
				Call_StartForward( view_as<Handle>(g_hRPNative[attacker][RP_PostGiveDamageWeapon]));
				Call_PushCell(attacker);
				Call_PushCell(victim);
				Call_PushFloatRef(damage);
				Call_PushCell(wep_id);
				Call_PushArray(damagePosition, sizeof(damagePosition));
				Call_Finish(a);
				
				if( a == Plugin_Handled || a == Plugin_Stop )
					return Plugin_Handled;
				if( a == Plugin_Changed )
					changed = true;
				
				if( !(GetZoneBit( victim_zone ) & BITZONE_PVP) && rp_GetClientJobID(attacker) == 111 && !g_bUserData[attacker][b_GameModePassive]) {			
					damage *= 1.25;
					changed = true;
				}
			}

			if( g_flUserData[victim][fl_Reflect] >= GetGameTime() && !(g_flUserData[attacker][fl_Reflect] >= GetGameTime() ) ) {
				if( IsInPVP(attacker) || IsInPVP(victim) ) {
					damage *= 0.5;
					rp_ClientDamage(attacker, RoundFloat(damage*0.5), victim, "bigmac");
				}
				else {
					rp_ClientDamage(attacker, RoundFloat(damage * 0.9), victim, "bigmac");
					damage *= 0.1;
				}
				
				TE_SetupBeamRingPoint(damagePosition, 4.0, 32.0, g_cBeam, g_cGlow, 0, 15, 0.25, 10.0, 8.0, {255, 255, 0, 50}, 10, 0);
				TE_SendToAll();
				
				float tmp[3];
				GetClientAbsOrigin(attacker, tmp);
				tmp[2] += 16.0;
				TE_SetupBeamPoints(tmp, damagePosition, g_cBeam, g_cGlow, 0, 15, 0.25, 10.0, 0.0, 0, 8.0, {255, 255, 0, 50}, 10);
				TE_SendToAll();
				
				changed = true;
			}

			if( g_iUserData[victim][i_Kevlar] >= 1 ) {
				damage *= 0.5;

				int health = GetClientHealth(victim);

				g_iUserData[victim][i_Kevlar] = (g_iUserData[victim][i_Kevlar] - RoundToFloor(damage / 10.0 * 6.0));
				health = (health - RoundToFloor( damage / 10.0 * 2.0 ));

				while( g_iUserData[victim][i_Kevlar] < 0 ) {
					health -= Math_GetRandomInt(1, 2);
					g_iUserData[victim][i_Kevlar]++;
					
					if( g_iUserData[victim][i_Kevlar] >= 0 )
						break;
				}
				
				if( health >= 1 ) {
					damage *= 0.0;
					changed = true;
					SDKHooks_TakeDamage(victim, attacker, attacker, float((GetClientHealth(victim)-health)), damagetype);
				}
			}

			if( g_flUserData[attacker][fl_WeaponTrain] > 2.0 || g_flUserData[attacker][fl_WeaponTrainAdmin] > 2.0 ) {
				float vecStart[3], vecEnd[3], vecPush[3];

				GetClientEyePosition(attacker, vecStart);
				GetClientEyePosition(victim, vecEnd);

				SubtractVectors(vecStart, vecEnd, vecPush);
				NormalizeVector(vecPush, vecPush);

				ScaleVector(vecPush, (damage*-5.0) );
				int flags = GetEntityFlags(victim);
				if( vecPush[2] > 0.0 && (flags & FL_ONGROUND) ) {
					SetEntityFlags(victim, (flags&~FL_ONGROUND) );
					SetEntPropEnt(victim, Prop_Send, "m_hGroundEntity", -1);
				}
				TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, vecPush);

				g_iSuccess_last_shot[victim][0] = attacker;
				g_iSuccess_last_shot[victim][1] = GetTime();
			}
		}
		
		// ------------------------------------
		//
		// ------------------------------------
		if( GetClientHealth(victim) <= damage ) {

			int wepIdx = 0;
			if( Math_GetRandomInt(0, 100) > 75 ) {
				while( ( wepIdx = GetPlayerWeaponSlot( victim, CS_SLOT_SECONDARY ) ) != -1 ) {
					RemovePlayerItem( victim, wepIdx );
					RemoveEdict( wepIdx);
				}
			}
			wepIdx = 0;
			if( Math_GetRandomInt(0, 100) > 25 ) {
				while( ( wepIdx = GetPlayerWeaponSlot( victim, CS_SLOT_PRIMARY ) ) != -1 ) {
					RemovePlayerItem( victim, wepIdx );
					RemoveEdict( wepIdx);
				}
			}
			wepIdx = 0;
			if( Math_GetRandomInt(0, 100) > 50 ) {
				while( ( wepIdx = GetPlayerWeaponSlot( victim, CS_SLOT_GRENADE) ) != -1 ) {
					RemovePlayerItem( victim, wepIdx );
					RemoveEdict( wepIdx);
				}
			}

			damage *= 5.0;
			changed = true;
		}
		
	}




	if( changed ) {
		return Plugin_Changed;
	}

	return Plugin_Continue;
}

public Action EventPlayerFallDamage(Handle ev, const char[] name, bool broadcast) {
	int client = GetClientOfUserId(GetEventInt(ev, "userid"));
	
	if( CanMadeSuccess(client, success_list_to_infini) ) {
		float damage = GetEventFloat(ev, "damage");

		int heal = GetClientHealth(client);

		if( damage >= 204.0 && heal < RoundFloat(damage) ) {
			WonSuccess(client, success_list_to_infini);

			SDKHooks_TakeDamage(client, client, client, 5000.0);
		}
	}
}
