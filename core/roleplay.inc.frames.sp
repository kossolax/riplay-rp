#if defined _roleplay_frames_included
#endinput
#endif
#define _roleplay_frames_included

#if defined ROLEPLAY_SUB
	#include "../roleplay.sp"
#else
	#include "roleplay.sp"
#endif

public void OnGameFrame() {
	static float g_flFrame_01 = 0.0;
	static float time = 0.0;
	time = GetGameTime();
	
	for(int Client = 1; Client <= MaxClients; Client++) {
		if( !g_bUserData[Client][b_isConnected] )
			continue;
		if( !IsPlayerAlive(Client) )
			continue;
		FORCE_FRAME(Client);
	}
	SynchronizeTime(time);
	// -----------------------------------------------------------------------------------------------
	//		0.1 SECOND
	//
	if( g_flFrame_01 > time ) {
		return;
	}
	g_flFrame_01 = time + 0.1;
	OnGameFrame_01(time);
	// -----------------------------------------------------------------------------------------------
	//		1.0 SECOND
	//
	OnGameFrame_10(time);
}
void OnGameFrame_01(float time) {
	static int wasInPVP[65], oldZone[65];
	float pos[3];
	g_iEntityCount = MaxClients;
	
	if(g_bIsBlackFriday) {
		if(GetTime() >= g_iBlackFriday[0] + 24*60*60) { // 03/01/2020 00h01 > 03/01/2020
			g_bIsBlackFriday = false;
			ServerCommand("rp_blackfriday");
		}
	}

	if(!g_bIsBlackFriday) {
		if(GetTime() > g_iBlackFriday[0] && GetTime() < g_iBlackFriday[0] + 24*60*60) {
			g_bIsBlackFriday = true;
		}
	}

	for(int i=MaxClients; i<2048; i++) {
		if( !IsValidEdict(i) || !IsValidEntity(i) )
			continue;
		g_iEntityCount++;
		if( !IsMoveAble(i) )
			continue;
		
		Entity_GetAbsOrigin(i, pos);
		
		if( pos[2] <= -10000.0 ) {
			PrintToChatAll("Un props est tombe hors map... %d - %s", i, g_szEntityName[i]);
			rp_AcceptEntityInput(i, "Kill");
		}
	}
	if( g_bLoaded ) {
		if( g_iEntityCount >= g_iEntityLimit ) {
			RunMapCleaner();
		}
	}
	//
	//Loop:
	g_iPlayerCount = 0;
	bool blockShot = false;
	for(int Client = 1; Client <= MaxClients; Client++) {
		//
		//Connected:
		if( !IsValidEdict(Client) || !IsValidEntity(Client) )
			continue;
		if( !g_bUserData[Client][b_isConnected] )
			continue;
		
		
		blockShot = false;
		g_iPlayerCount++;
		
		if( !IsPlayerAlive(Client) ) {
			if( g_flUserData[Client][fl_RespawnTime] > time ) {
				PrintHintText(Client, "<font color='#ff0000'>Vous êtes mort.</font>\nVous allez revivre dans:\n      %.1f seconde%c", g_flUserData[Client][fl_RespawnTime]-time, (g_flUserData[Client][fl_RespawnTime]-time>=2.0?'s':' ') );
			}
			else {
				PrintHintText(Client, "\nAppuyez sur une touche pour revivre.");
			}
			
			check_dead(Client);
			continue;
		}
		
		check_area(Client);
		
		wasInPVP[Client] = IsInPVP(Client);
		int nowZone = GetPlayerZone(Client);
		if( nowZone != oldZone[Client] ) {
			Call_StartForward( view_as<Handle>(g_hRPNative[Client][RP_OnPlayerZoneChange]));
			Call_PushCell(Client);
			Call_PushCell(nowZone);
			Call_PushCell(oldZone[Client]);
			Call_Finish();
			oldZone[Client] = nowZone;
		}
		if( g_bUserData[Client][b_Debuging] ) {
			Effect_DrawBeamBoxToClient(Client, g_flZones[nowZone][0], g_flZones[nowZone][1], g_cHacked, g_cHacked, 0, 30, 0.2, 5.0, 5.0, 1, 0.0, view_as<int>({ 255, 0, 0, 255 }), 0);
			float origin[3];
			rp_GetClientTarget(Client, origin);
			Effect_DrawAxisOfRotationToClient(Client, origin, view_as<float>({0.0, 0.0, 0.0}) , view_as<float>({10.0, 10.0, 10.0}), g_cBeam, g_cBeam, 0, 30, 0.2, 1.0, 1.0); 
		}
		
		EffectHallucination(Client, time);
		EffectPissing(Client);
		
		float speed = g_flUserData[Client][fl_Speed];
		float gravity = g_flUserData[Client][fl_Gravity];
		
		if( g_flUserData[Client][fl_ForwardStates] > time ) {
			if( g_flUserData[Client][fl_Energy] > 0.0 ) {
				speed += 0.40;
				g_flUserData[Client][fl_Energy] -= 0.0075;
			}
		}
		
		if( g_iUserData[Client][i_Malus] > GetTime() )
			speed -= 0.3;
		
		if( IsNight() ) {
			if( IsTueur(Client) )
				speed += 0.1;
		}
		
		if( g_bUserData[Client][b_GameModePassive] == true && g_iUserData[Client][i_Job] >= 1 && g_iUserData[Client][i_Job] <= 8 ) {
			g_bUserData[Client][b_GameModePassive] = false;
			CPrintToChat(Client, "" ...MOD_TAG... " Le mode de jeu passif a été désactivé.");
		}
		
		if( !(rp_GetZoneBit( rp_GetPlayerZone(Client) ) & BITZONE_PVP) && !(rp_GetZoneBit( rp_GetPlayerZone(Client) ) & BITZONE_EVENT)	) {
			if( !g_bUserData[Client][b_GameModePassive] && rp_GetClientJobID(Client) == 41 && g_iUserData[Client][i_ToKill] > 0 )
				speed += 0.25;

			if( HasDoctor(Client) ) {
				if( g_iUserData[Client][i_Sick] == view_as<int>(sick_type_grippe) )
					speed = 0.66;
				else if( g_iUserData[Client][i_Sick] == view_as<int>(sick_type_tourista) )
					gravity = 1.5;
			}
		}
		
		Call_StartForward( view_as<Handle>(g_hRPNative[Client][RP_PrePlayerPhysic]));
		Call_PushCell(Client);
		Call_PushFloatRef(speed);
		Call_PushFloatRef(gravity);
		Call_Finish();
		
		if( g_flUserData[Client][fl_FrozenTime] > time && GetEntityMoveType(Client) != MOVETYPE_NOCLIP ) {
			
			float vecVelocity[3];
			
			if( GetEntityMoveType(Client) == MOVETYPE_LADDER ) {
				vecVelocity[0] = Math_GetRandomFloat(-250.0, 250.0);
				vecVelocity[1] = Math_GetRandomFloat(-250.0, 250.0);
				
				SetEntityMoveType(Client, MOVETYPE_WALK);
			}
			
			if(! (GetEntityFlags(Client) & FL_ONGROUND) ) {
				speed = 1.0;
				vecVelocity[2] = -400.0;
			}
			else {
				speed = 0.00001;
			}
			TeleportEntity(Client, NULL_VECTOR, NULL_VECTOR, vecVelocity);
			gravity = 0.9;
		}
		
		if( speed >= 2.5 )
			speed = 2.5;
		if( speed <= 0.0001 )
			speed = 0.0001;
		
		if( gravity < 0.05 )
			gravity = 0.05;
		
		if( GetZoneBit( nowZone )  & BITZONE_BLOCKCHIRU ) {
			speed = DEFAULT_SPEED;
			gravity = 1.0;
		}
		
		Call_StartForward( view_as<Handle>(g_hRPNative[Client][RP_PostPlayerPhysic]));
		Call_PushCell(Client);
		Call_PushFloatRef(speed);
		Call_PushFloatRef(gravity);
		Call_Finish();
		
		if( g_flUserData[Client][fl_Invincible] >= time ) {
			gravity = speed = 0.0000001;			
			blockShot = true;
		}
		
		if( g_bIsInCaptureMode && GetZoneBit( nowZone )  & BITZONE_PVP ) {
			if( speed > 2.0 )
				speed = 2.0;
			if( gravity < 0.5 )
				gravity = 0.5;
		}
		
		
		speed = SquareRoot(speed);
		gravity = SquareRoot(gravity);
		
		if( g_bUserData[Client][b_Debuging] ) {
			float velo[3];
			Entity_GetAbsVelocity(Client, velo);	
			PrintHintText(Client, "%f\n%f", GetVectorLength(velo) * speed, gravity);
		}
		
		if( GetEntPropFloat(Client, Prop_Data, "m_flLaggedMovementValue") != speed )
			SetEntPropFloat(Client, Prop_Data, "m_flLaggedMovementValue", speed);
		if( GetEntityGravity(Client) != gravity )
			SetEntityGravity(Client, gravity);
		
		RP_PerformFade(Client);
		
		/*
		if( g_bUserData[Client][b_Invisible] ) {
			float ppos[3];
			GetClientAbsOrigin(Client, ppos);
			ppos[2] += 32.0;
			
			TE_SetupBeamRingPoint(ppos, 4.0, 8.0, g_cShockWave, g_cShockWave, 0, 33, 0.5, 32.0, 16.0, { 255, 255, 255, 10 }, 10, 0);
			TE_SendToAll();
		}*/
		
		if( g_flUserData[Client][fl_PaintBall] >= 1.0 && g_flUserData[Client][fl_PaintBall] <= time ) {
			
			ClientCommand(Client, "r_screenoverlay \"\"");
			g_flUserData[Client][fl_PaintBall] = 0.0;
		}
		
#if defined USING_VEHICLE
		int car = GetEntPropEnt(Client, Prop_Send, "m_hVehicle");	
		if( car != -1 && g_iMayCarAction[Client] ) {
			if( GetClientButtons(Client) & IN_ATTACK ) {
				
				char tmp[255];
				Format(tmp, sizeof(tmp), "vehicles/v8/beep_%i.mp3", g_iVehicleData[car][car_klaxon]);
				EmitSoundToAllAny(tmp, car, 6, SNDLEVEL_CAR, SND_NOFLAGS, SNDVOL_NORMAL);

				g_iMayCarAction[Client] = 0;
				CreateTimer(2.0, AllowCarAction, Client);
			}
			g_iGrabbing[Client] = 0;
		}
#endif
		//
		//E Key:
		if(GetClientButtons(Client) & IN_USE) {
			//Overflow:
			if(!g_bPrethinkBuffer[Client]) {
				//Action 
				CommandUse(Client);
				//UnHook:
				g_bPrethinkBuffer[Client] = true;
			}
		}
		//
		//Nothing:
		else {
			//Hook:
			g_bPrethinkBuffer[Client] = false;
		}
		
		int buttons = GetClientButtons(Client);
		
		if( (buttons & IN_USE) && (buttons & IN_FORWARD|IN_BACK|IN_LEFT|IN_RIGHT) ) {
			g_flUserData[Client][fl_ForwardStates] = time + 0.25;
		}		
		GetClientEyeAngles(Client, g_vecAngles[Client]);
		
		
		if( GetZoneBit( nowZone ) & BITZONE_PEACEFULL ) {
			blockShot = true;
		}
		
		if( blockShot ) {
			int wep = GetEntPropEnt(Client, Prop_Send, "m_hActiveWeapon");
			if( wep > 0 && IsValidEdict(wep) && IsValidEntity(wep) ) {
				SetEntPropFloat(wep, Prop_Send, "m_flNextPrimaryAttack", time + 0.25);
				SetEntPropFloat(wep, Prop_Send, "m_flNextSecondaryAttack", time + 0.25);
			}
		}
		
		
		
		if( g_bUserData[Client][b_Blind] == 1  )
			continue;
		
		if( car > 0 ) {
			PrintHintText(Client, "Voiture: %dHP\nVitesse: %.1fkm/h", rp_GetVehicleInt(car, car_health), float(GetEntProp(car, Prop_Data, "m_nSpeed"))* 1.609);
		}
		else {
			showPlayerHintBox(Client, rp_GetClientTarget(Client));
		}
	}
	
	// -----------------------------------------------------------------------------------------------
	//
}
void OnGameFrame_10(float time) {
	static int last_minutes = -1;
	static int infoPeineTime = -1;

	static char model[255], szHUD[1024], sound[128], szDates[64], bfAnnoucement[256];
	
	if( last_minutes == g_iMinutes ) 
		return;
	
	last_minutes = g_iMinutes;

	SQL_Reconnect();
	
	if( g_iLDR > 0 && g_iMinutes%12 == 0 ) {
		ServerCommand("sm_effect_group %i", g_iLDR);		
	}
	if( g_iMinutes%10 == 5 ) {
		SynFromWeb();
		updateLotery();
	}
	if( g_iMinutes == 0 ) {
		CleanUp();
	}
	
	CRON_TIMER();
	if( g_iMinutes%30 == 0 ) {
		PrintTag();
	}
	
	if( g_iMinutes == 0 && g_iHours%12 == 0 ) {
		updateGroupLeader();
		
		for(int i=0; i < MAX_JOBS; i++) {
			rp_SetJobCapital(i, rp_GetJobCapital(i) + rp_GetJobInt(i, job_type_subside));
			SaveJob(i);
		}
		
		for(int i=1; i < MAX_GROUPS; i+=10) {
			SaveGroup(i);
		}
	}
	
	if( g_iMinutes % 3 == 0 ) {
		if( g_flPhoneStart >= GetTickedTime() ) {
			Format(sound, sizeof(sound), "DeadlyDesire/princeton/ambiant/phone%d.mp3", g_iPhoneType);
			EmitSoundToAllAny(sound, SOUND_FROM_WORLD, _, _, _, _, _, _, g_flPhonePosit);
		}
	}
	
	if( g_iMinutes == 0 && g_iHours == 18 ) {
		ServerCommand("sm_effect_time night 60.0");
	}
	else if( g_iMinutes == 0 && g_iHours == 6 ) {
		ServerCommand("sm_effect_time day 60.0");
	}
	if( g_iMinutes == 0 && (g_iHours%6) == 0 ) {
		g_bEvent_Kidnapping = false;
	}
	
	if( g_flPhoneStart < GetTickedTime() ) {
		if( Math_GetRandomInt(0, 80) == 10 ) {
			MakePhoneRing();
		}
	}

	if( g_iHours == 1 && g_iMinutes == 1 ) {
		if(g_bIsBlackFriday) {
			Format(bfAnnoucement, sizeof(bfAnnoucement), "" ...MOD_TAG... " Journée exceptionnelle du Black Friday ! Profitez d'une réduction de {lightblue}-%iPCT{default} sur tous vos achats !", g_iBlackFriday[1]);
			ReplaceString(bfAnnoucement, sizeof(bfAnnoucement), "PCT", "%%", true);
			CPrintToChatAll(bfAnnoucement);
		}
	}

	#if defined EVENT_NOEL
	if( Math_GetRandomInt(0, GetConVarInt(g_hEVENT_NOEL_SPEED) ) == 0 ) {
		SpawnRandomBonbon();
	}
	#endif

	infoPeineTime++;

	if(infoPeineTime > 180) {
		infoPeineTime = 0;
	}

	int jobID;
	int iTime = GetTime();
	int tmpKillDuration;

	bool changed = false;
	float fNow[3];
	PrintHours(szDates, sizeof(szDates));
	
	for (int i = 1; i <= MaxClients; i++) {
		if ( g_bUserData[i][b_isConnected] ) {
			
			jobID = rp_GetClientJobID(i);
			changed = false;
			
			if( Math_GetRandomInt(1, 65) == i ) {
				StoreUserData(i);
			}
			if( Math_GetRandomInt(1, 20) == 10 ) {
				CheckMP(i);
			}
			
			if( g_iUserData[i][i_LastKillTime]+(60) < iTime ) {
				g_iUserData[i][i_KillJailDuration]--;
				changed = true;
				SetEntProp(i, Prop_Send, "m_iNumRoundKills",  0);
				g_iUserData[i][i_LastKillTime] = iTime;
				
			}
			if( g_iUserData[i][i_KillJailDuration] < 0 ) {
				g_iUserData[i][i_KillJailDuration] = 0;
			}
			// TODO: Déplacer ça dans SexShop.
			if( g_flUserData[i][fl_Alcool] > 0.0 ) {
				g_flUserData[i][fl_Alcool] -= (0.15/60.0);
				if( g_flUserData[i][fl_Alcool] <= 0.0 ) {
					g_flUserData[i][fl_Alcool] = 0.0;
					SendConVarValue(i, FindConVar("host_timescale"), "1.0000");
				}
			}
			
			AFK_Check(i);
			if( !g_bUserData[i][b_IsAFK] ) {
				rp_ClientXPIncrement(i);
				
				if( rp_IsClientNew(i) && Math_GetRandomInt(0, 1) )
					rp_ClientXPIncrement(i);
				
				if( g_bUserData[i][b_ShouldGoToMairie] ) {
					PrintHintText(i, " \n Vous êtes attendu à la mairie.");
				}
			}
			
			
			// TODO: Déplacer ça dans PvP
			if( g_bIsInCaptureMode ) {
				if( g_flUserData[i][fl_Alcool] > 0.0 ) {
					g_flUserData[i][fl_Alcool] = 0.0;
					SendConVarValue(i, FindConVar("host_timescale"), "1.0000");
				}
			}
			// TODO: Déplacer ça dans PvP
			if( rp_GetZoneBit( GetPlayerZone(i)) & BITZONE_PVP ) {
				g_iUserData[i][i_PVP]++;
			}
			else {
				g_iUserData[i][i_PVP] = 0;
			}
			
			
			ClientAgroDecrement(i);
			DoBeacon(i);
			
			if( g_iMinutes == 0 ) {
				if( g_iHours == 23 && g_iUserData[i][i_AppartCount] > 0 ) {
					ClientCommand(i, "play common/warning");
				}
				
				if( g_iHours % 6 == 0 ) {
					g_iUserData[i][i_ContratTotal] -= 1;
					if( g_iUserData[i][i_ContratTotal] < 0 )
						g_iUserData[i][i_ContratTotal] = 0;
					
					if( g_iUserData[i][i_MaskCount] < 5 )
						g_iUserData[i][i_MaskCount]++;
				}
			}
			
			
			if( !g_bUserData[i][b_IsAFK] ) {
				
				if( rp_IsClientNew(i) || !g_bUserData[i][b_GameModePassive] )
					g_flUserData[i][fl_Vitality] += 0.15;
				if( jobID == 21 && !g_bUserData[i][b_GameModePassive] )
					g_flUserData[i][fl_Vitality] += 0.15;
			}
			else {
				g_flUserData[i][fl_Vitality] -= 0.015;
			}
			
			g_flUserData[i][fl_ArtisanFatigue] -= 1.0 / (60.0 * 60.0);
			if( g_flUserData[i][fl_ArtisanFatigue] < 0.0 )
				g_flUserData[i][fl_ArtisanFatigue] = 0.0;
			if( g_flUserData[i][fl_Vitality] < 0.0 )
				g_flUserData[i][fl_Vitality] = 0.0;
			
			if( IsPlayerAlive(i) ) {

				if(infoPeineTime == 180) {
					if( g_bUserData[i][b_ExitJailMenu] && g_iUserData[i][i_JailTime] > 0 ) {
						CPrintToChat(i, "" ...MOD_TAG... "{default} Tu peux modifier la durée/zone de ton emprisonnement en tapant /peine");
					}
				}

				KillStack_Timer(i, iTime);
				
				CheckLiscence(i);
				
				if( IsPolice(i) || IsJuge(i) ) {
					if( GetClientTeam(i) != CS_TEAM_T && g_iUserData[i][i_KillJailDuration] > 1) {
						tmpKillDuration = g_iUserData[i][i_KillJailDuration];
						g_iUserData[i][i_KillJailDuration] = 0;

						CS_SwitchTeam(i, CS_TEAM_T);
						SetEntProp(i, Prop_Send, "m_bHasHelmet", 0);
						rp_ClientResetSkin(i);
						
						g_iUserData[i][i_KillJailDuration] = tmpKillDuration;
					}
				}	

				GetClientAbsOrigin(i, fNow);
				if( GetVectorDistance(fNow, g_fSuccess_last_move[i]) > 50 && Math_GetRandomInt(0, 1) ) {
					g_iUserStat[i][i_RunDistance]++;
					IncrementSuccess(i, success_list_marathon);
					GetClientAbsOrigin(i, g_fSuccess_last_move[i]);
					
					if( !g_bUserData[i][b_GameModePassive] && jobID == 31 && Math_GetRandomInt(1, 200) == 42 ) {
						int MP[] =  { 128, 129, 234, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255, 256, 257 };
						int rnd = Math_GetRandomInt(0, sizeof(MP) - 1);
						int qt = (200/rp_GetItemInt(MP[rnd], item_type_prix));
						CPrintToChat(i, "" ...MOD_TAG... " Vous avez trouvé %d %s", qt, g_szItemList[MP[rnd]][item_type_name]);
						rp_ClientGiveItem(i, MP[rnd], qt);
					}
					if( !g_bUserData[i][b_GameModePassive] && jobID == 171 && Math_GetRandomInt(0, 250) == 42 ) {
						CPrintToChat(i, "" ...MOD_TAG... " Vous avez trouvé %s", g_szItemList[276][item_type_name]);
						rp_ClientGiveItem(i, 276);
					}
					
					if( jobID == 71 && !g_bUserData[i][b_GameModePassive] && g_flUserData[i][fl_WeaponTrain] < 6.0 ) {
						g_flUserData[i][fl_WeaponTrain] += 0.025;
					}
				}
				
				if( g_iUserData[i][i_Job] == 0 && (g_iUserData[i][i_Money]+g_iUserData[i][i_Bank]) <= 1000 ) {
					if( g_iSuccess_last_touchdown[i] < 1 ) {
						g_iSuccess_last_touchdown[i] = GetTime();
					}
				}
				if (g_bUserData[i][b_IsMutePvP] && g_iUserData[i][i_Group] != 0) { g_iUserData[i][i_Group] = 0; }
				
				if( GetZoneBit( GetPlayerZone(i) ) & BITZONE_DENY ) {
					SDKHooks_TakeDamage(i, i, i, 5000.0);
				}
				
				if(jobID == 101 && !g_bUserData[i][b_GameModePassive] && !(GetZoneBit(GetPlayerZone(i)) & (BITZONE_PVP|BITZONE_EVENT)) ) {			
					int heal = GetClientHealth(i) + Math_GetRandomInt(1, 5);
					if( heal > 500 )
						heal = 500;
					SetEntityHealth(i, heal);
				}
				
				if( g_iUserData[i][i_PlayerLVL] >= 756 && !(GetZoneBit(GetPlayerZone(i)) & (BITZONE_PVP|BITZONE_EVENT)) ) {
					
					int heal = GetClientHealth(i) + Math_GetRandomInt(1, 5);
					if( heal > 500 )
						heal = 500;
						
					SetEntityHealth(i, heal);
					
					heal = g_iUserData[i][i_Kevlar] + Math_GetRandomInt(1, 3);
					if( heal > 250 )
						heal = 250;
					
					g_iUserData[i][i_Kevlar] = heal;
				}
				
				int appart = getZoneAppart(i);
				// TODO: Déplacer ça dans le job immo.
				if( appart > 0 && g_iDoorOwner_v2[i][appart] ) {
					
					if( g_iAppartBonus[appart][appart_bonus_heal] == 1 || (jobID == 61 && !g_bUserData[i][b_GameModePassive]) ) {
						int heal = GetClientHealth(i) + Math_GetRandomInt(2, 7);
						
						if( heal > 500 )
							heal = 500;
						
						SetEntityHealth(i, heal);
					}
					if( g_iAppartBonus[appart][appart_bonus_armor] == 1 || (jobID == 61 && !g_bUserData[i][b_GameModePassive])) {
						
						int heal = g_iUserData[i][i_Kevlar] + Math_GetRandomInt(2, 7);
						
						if( heal > 250 )
							heal = 250;
						
						g_iUserData[i][i_Kevlar] = heal;
					}
					if( g_iAppartBonus[appart][appart_bonus_energy] == 1 || (jobID == 61 && !g_bUserData[i][b_GameModePassive])) {
						
						if( g_flUserData[i][fl_Energy] < 50.0 ) {
							float heal = g_flUserData[i][fl_Energy] + 1.0;
							
							if( heal > 50.0 )
								heal = 50.0;
							
							g_flUserData[i][fl_Energy] = heal;
						}
						
						
					}
					if( g_iAppartBonus[appart][appart_bonus_vitality] == 1 || (jobID == 61 && !g_bUserData[i][b_GameModePassive])) {
						
						if( !g_bUserData[i][b_IsAFK] )
							g_flUserData[i][fl_Vitality] = g_flUserData[i][fl_Vitality] + 0.5;
					}
				}
				if( g_iUserData[i][i_AddToPay] < 0 ) {
					LogToGame("[DEBUG-PAY] %L has negative pay", i);
					g_iUserData[i][i_Money] += g_iUserData[i][i_AddToPay];
					g_iUserData[i][i_AddToPay] = 0;
				}
				
				if( g_iUserData[i][i_Money] < 0 ) {
					LogToGame("[DEBUG-PAY] %L has negative money", i);
					g_iUserData[i][i_Bank] += g_iUserData[i][i_Money];
					g_iUserData[i][i_Money] = 0;
				}
				
				int wepid = GetPlayerWeaponSlot( i, 2 );
				if( !IsValidEdict(wepid) && !IsValidEntity(wepid) ) {
					int tmp = GivePlayerItem(i, "weapon_fists");
					EquipPlayerWeapon(i, tmp);
				}
				
				wepid = GetEntPropEnt(i, Prop_Send, "m_hActiveWeapon");
				if( !IsValidEdict(wepid) && !IsValidEntity(wepid) ) {
					FakeClientCommand(i, "use weapon_fists");
				}
				#if defined EVENT_HALLOWEEN
				if( g_iZombified[Client] == 1 ) {
					if( GetClientHealth(i) > 5000 ) {
						SetEntityHealth(i, 5000);
					}
				}
				else
				#endif
				if( !g_bUserData[i][b_AdminHeal] ) {
					if( GetClientHealth(i) > 500 ) {
						SetEntityHealth(i, 500);
					}
				}
				
				if( !(GetZoneBit( GetPlayerZone(i) ) & BITZONE_EVENT) ) {
					Call_StartForward( view_as<Handle>(g_hRPNative[i][RP_OnFrameSeconde]));
					Call_PushCell(i);
					Call_Finish();
				}
				// TODO: Déplacer ça dans le job hopital
				if( !(GetZoneBit(GetPlayerZone(i)) & (BITZONE_PVP|BITZONE_EVENT)) && !(g_iMinutes % 5) ) {
					if( HasDoctor(i) 
						&& !(rp_GetZoneBit( rp_GetPlayerZone(i) ) & BITZONE_PVP)
						&& !(rp_GetZoneBit( rp_GetPlayerZone(i) ) & BITZONE_EVENT) ) {
						if( g_iUserData[i][i_Sick] == view_as<int>(sick_type_hemoragie) ) {
							int heal = GetClientHealth(i) - 5;
							if( heal <= 0 )
								heal = 1;
							SetEntityHealth(i, heal);
							
							Format(sound, sizeof(sound), "hostage/hpain/hpain%i.wav", Math_GetRandomInt(1, 6));
							EmitSoundToAllAny(sound, i);
							
							for(float f=0.0; f<=5.0; f+=Math_GetRandomFloat(0.5, 1.0) )
								CreateTimer(f, bleeding, i);
							
							if( Math_GetRandomInt(1, 100) == 100 ) {
								g_iUserData[i][i_Sick] = 0;
							}
						}
						if( IsMedic(i) ) {
							g_iUserData[i][i_Sick] = view_as<int>(sick_type_none);
						}
					}
				}
				
				if( !(GetZoneBit(GetPlayerZone(i)) & (BITZONE_PVP|BITZONE_EVENT)) && g_iUserData[i][i_Sickness] && (g_iMinutes % 5) == 0 ) {
					
					int health = GetClientHealth(i);

					if(health == 1 || !IsPlayerAlive(i)) {
						g_iUserData[i][i_Sickness] = 0;
						g_flUserData[i][fl_LastPoison] = GetGameTime() + 12.0 * 60.0;
					} else {
						Format(sound, sizeof(sound), "hostage/hpain/hpain%i.wav", Math_GetRandomInt(1, 6));
						EmitSoundToAllAny(sound, i);
						
						int heal = health - Math_GetRandomInt(3, 7);

						if( heal >= 1 )
							SetEntityHealth(i, heal);
						else
							SetEntityHealth(i, 1);
						
						float vecAngles[3];
						vecAngles[0] = vecAngles[1] = vecAngles[2] = 10.0;
						
						SetEntPropVector(i, Prop_Send, "m_viewPunchAngle", vecAngles);
						
						vecAngles[0] = Math_GetRandomFloat(10.0, 20.0);
						vecAngles[1] = Math_GetRandomFloat(10.0, 20.0);
						vecAngles[2] = Math_GetRandomFloat(5.0, 10.0);
						
						TeleportEntity(i, NULL_VECTOR, NULL_VECTOR, vecAngles);
					}
				}
				
				if( g_iUserData[i][i_JailTime] > 0 ) {
					g_iUserData[i][i_JailTime]--;
					
					if( StringToInt(g_szZoneList[GetPlayerZone(i)][zone_type_bit]) & BITZONE_HAUTESECU && !g_bUserData[i][b_IsAFK] ) {
						g_iUserData[i][i_JailTime]--;
					}
					if( g_iUserData[i][i_JailTime] <= 0 ){
						g_bUserData[i][b_JailQHS] = false;
					}
					
					g_iSuccess_last_jail[i] = GetTime();
					
					if( GetClientTeam(i) == CS_TEAM_T ) {
						
						Entity_GetModel(i, model, sizeof(model)); 
						
						if( StrContains(model, "sprisioner", false) == -1 ) {
							Entity_SetModel(i, "models/player/custom_player/legacy/sprisioner/sprisioner.mdl");
						}
					}
				}
				
				if( g_iUserData[i][i_JailTime] >= 730 && IsClientInJail(i)) {
					ReduceJailTime(i);
				}
				if( g_iUserData[i][i_JailTime] <= 0 && IsClientInJail(i) ) {
					
					Entity_GetModel(i, model, sizeof(model));
					
					if( StrContains(model, "sprisioner", false) != -1 ) {
						g_iUserData[i][i_JailTime] = 0;
						g_iUserData[i][i_jailTime_Last] = 0;
						g_iUserData[i][i_JailledBy] = 0;
						if( g_iUserData[i][i_jailTime_Reason] == 1 ) {
							g_iUserData[i][i_KillJailDuration] = 0;
						}

						g_bUserData[i][b_IsFreekiller] = false;
						g_bUserData[i][b_JailQHS] = false;
							
						rp_ClientResetSkin(i);
						rp_ClientSendToSpawn(i, true);
						CPrintToChat(i, "" ...MOD_TAG... " Vous avez été liberé de prison.");
					}
				}
				
				if( g_bUserData[i][b_Invisible] ) {
					
					ClientCommand(i, "r_screenoverlay effects/hsv.vmt");
					
					if( g_iUserData[i][i_Job] != 1 && g_iUserData[i][i_Job] != 2 && g_iUserData[i][i_Job] != 4 && g_iUserData[i][i_Job] != 5 ) {	
						if( GetClientSpeed(i) > 200 || g_flUserData[i][fl_invisibleTime] < time ) {
							CopSetVisible(i);
						}
					}
				}				
				else if( g_flUserData[i][fl_invisibleTime] > time && g_flUserData[i][fl_invisibleTimeLeft] < time ) {
					if( GetClientSpeed(i) < 200  && (GetClientButtons(i) & IN_DUCK) && CheckBuild(i, false) ) {
						CopSetInvisible(i);
					}
				}
			}
			else {
				showGraveMenu(i);
			}
			
			if( g_iHours == 0 && g_iMinutes == 0 ) {
				GivePlayerPay(i);
			}
			
			if( CS_GetClientContributionScore(i) != 0 )
				CS_SetClientContributionScore(i, 0);
			if( CS_GetClientAssists(i) != 0 )
				CS_SetClientAssists(i, 0);
			if( CS_GetMVPCount(i) != 0 )
				CS_SetMVPCount(i, 0);

			if( GetEntProp(i, Prop_Data, "m_iFrags") != 0 ) 
				SetEntProp(i, Prop_Data, "m_iFrags", 0);
			if( GetEntProp(i, Prop_Data, "m_iDeaths") != 0 ) 
				SetEntProp(i, Prop_Data, "m_iDeaths", 0);
			if( !changed )
				SetEntProp(i, Prop_Send, "m_iNumRoundKills",  Math_Abs(g_iUserData[i][i_KillJailDuration]));
			if( Client_GetArmor(i) != g_iUserData[i][i_Kevlar] )
				Client_SetArmor(i, g_iUserData[i][i_Kevlar]);
			
			updateClanTag(i);

			if( GetClientMenu(i) == MenuSource_None || GetClientMenu(i) == MenuSource_RawPanel ) {
				
				if( ! IsTutorialOver(i) ) {
					DisplayTutorial(i);
				}
				else if( IsClientInTetrisGame(i) || IsClientInSnakeGame(i) || IsClientInPongGame(i) ) {
					
				}
				else {
					
					PrintHUD(i, szHUD, sizeof(szHUD));
					
					Call_StartForward( view_as<Handle>(g_hRPNative[i][RP_OnPlayerHUD]));
					Call_PushCell(i);
					Call_PushStringEx(szHUD, sizeof(szHUD), SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
					Call_PushCell(sizeof(szHUD));
					Call_Finish();
					
					Handle mSayPanel = CreatePanel();
					SetPanelTitle(mSayPanel, szGeneralMenu);
					DrawPanelItem(mSayPanel, "", ITEMDRAW_SPACER);
					
					DrawPanelText(mSayPanel, szHUD);
					
					SendPanelToClient(mSayPanel, i, MenuNothing, 2);
					CreateTimer(1.1, PostKillHandle, mSayPanel);
				}
			}
			
			if( GetEntProp(i, Prop_Send, "m_bDrawViewmodel") == 1 ) {
				Handle hud = CreateHudSynchronizer();
				SetHudTextParams(-1.0, 1.0, 1.1, 19, 213, 45, 255, 2, 0.0, 0.0, 0.0);
				ShowSyncHudText(i, hud, szDates);
				CloseHandle(hud);
			}
			
			CheckNoWonSuccess(i);
			
			if( (g_iUserData[i][i_Money] + g_iUserData[i][i_Bank]) <= -100 ) {
				
				if( (g_iUserData[i][i_Money] + g_iUserData[i][i_Bank]) <= -5000 ) {
					ServerCommand("amx_ban \"#%i\" \"0\" \"limite -5000$\"", GetClientUserId(i));
				}
				else {
					ServerCommand("amx_ban \"#%i\" \"60\" \"limite -100$\"", GetClientUserId(i));
				}
				
				g_iUserData[i][i_Money] = 0;
				g_iUserData[i][i_Bank] = 0;
			}
			if( g_iUserData[i][i_Dette] >= 25000 ) {
				ServerCommand("amx_ban \"#%i\" \"0\" \"limite -25000$\"", GetClientUserId(i));
			}
		}
		else if( IsValidClient(i) && !IsFakeClient(i) ) {
			Handle mSayPanel = CreatePanel();
			SetPanelTitle(mSayPanel, szGeneralMenu);
			DrawPanelText(mSayPanel, " ");
			DrawPanelText(mSayPanel, "Chargement de vos informations...");
			DrawPanelText(mSayPanel, "Ceci peut prendre jusqu'à une minute.");
			DrawPanelText(mSayPanel, " ");
			DrawPanelText(mSayPanel, " ");
			DrawPanelText(mSayPanel, " ");
			DrawPanelText(mSayPanel, "Les serveurs Steam sont peut-être saturé.");
			DrawPanelText(mSayPanel, "Dans ce cas les délais peuvent être plus long.");
			
			SendPanelToClient(mSayPanel, i, MenuNothing, 2);
			CreateTimer(1.1, PostKillHandle, mSayPanel);
		}
	}
}
public void CRON_TIMER() {
	char szDayOfWeek[12], szHours[12], szMinutes[12], szSecondes[12];
	
	FormatTime(szDayOfWeek, 11, "%w");
	FormatTime(szHours, 11, "%H");
	FormatTime(szMinutes, 11, "%M");
	FormatTime(szSecondes, 11, "%S");

	if( StringToInt(szDayOfWeek) == 2 || StringToInt(szDayOfWeek) == 6 ) {	// Mardi & Samedi
		if( StringToInt(szHours) == 21 && StringToInt(szMinutes) == 0 && StringToInt(szSecondes) == 0 ) {	// 21h00m00s
			ServerCommand("rp_force_loto");
		}
	}
	if( StringToInt(szDayOfWeek) == 0  ) {	// Dimanche
		if( StringToInt(szHours) == 21 && StringToInt(szMinutes) == 0 && StringToInt(szSecondes) == 0 ) {	// 21h00m00s
			ServerCommand("rp_force_appart");
		}
	}
	if( StringToInt(szDayOfWeek) == 1  ) {	// Lundi
		if( StringToInt(szHours) == 21 && StringToInt(szMinutes) == 0 && StringToInt(szSecondes) == 0 ) {	// 21h00m00s
			ServerCommand("rp_force_maire");
		}
	}
	
	
	if( (StringToInt(szHours) ==  4 && StringToInt(szMinutes) == 59 && StringToInt(szSecondes) == 30) ||
		(StringToInt(szHours) == 16 && StringToInt(szMinutes) == 29 && StringToInt(szSecondes) == 30) 
		) {	
		CPrintToChatAll("" ...MOD_TAG... " Le serveur vas {red}redémarrer{default} dans 30 secondes.");
		CPrintToChatAll("" ...MOD_TAG... " Le serveur vas {red}redémarrer{default} dans 30 secondes.");
		CPrintToChatAll("" ...MOD_TAG... " Le serveur vas {red}redémarrer{default} dans 30 secondes.");
		ServerCommand("rp_give_assu");
	}
	if( (StringToInt(szHours) ==  4 && StringToInt(szMinutes) == 59 && StringToInt(szSecondes) == 59) ||
		(StringToInt(szHours) == 16 && StringToInt(szMinutes) == 29 && StringToInt(szSecondes) == 59) ) {
		CPrintToChatAll("" ...MOD_TAG... " Le serveur vas {red}redémarrer{default} MAINTENANT.");
	}
	if( (StringToInt(szHours) ==  5 && StringToInt(szMinutes) ==  0 && StringToInt(szSecondes) == 0) ||
		(StringToInt(szHours) == 16 && StringToInt(szMinutes) == 30 && StringToInt(szSecondes) == 0) ) {
		CPrintToChatAll("" ...MOD_TAG... " Le serveur vas {red}redémarrer{default} MAINTENANT.");
		
		for(int i = 1; i <= MaxClients; i++)
			if( IsValidClient(i) )
				ClientCommand(i, "retry"); // force retry
		
		CreateTimer(0.1, RebootServer);
	}
	
	
	if( StringToInt(szDayOfWeek) == 3 ) { // Mercredi
		if( StringToInt(szHours) == 18 && StringToInt(szMinutes) == 0 && StringToInt(szSecondes) == 0 ) {	// 18h00m00s
			ServerCommand("rp_capture active");
		}
		if( StringToInt(szHours) == 18 && StringToInt(szMinutes) == 30 && StringToInt(szSecondes) == 0 ) {	// 18h30m00s
			ServerCommand("rp_capture none");
		}
	}
	if( StringToInt(szDayOfWeek) == 5 ) { // Vendredi
		if( StringToInt(szHours) == 21 && StringToInt(szMinutes) == 0 && StringToInt(szSecondes) == 0 ) {	// 21h00m00s
			ServerCommand("rp_capture active");
		}
		if( StringToInt(szHours) == 21 && StringToInt(szMinutes) == 30 && StringToInt(szSecondes) == 0 ) {	// 21h30m00s
			ServerCommand("rp_capture none");
		}
	}
}
public Action RebootServer(Handle timer, any none) {
	ServerCommand("quit");
	ServerCommand("sv_cheats 1");
	ServerCommand("crash");
}