#if defined _roleplay_success_included	
	#endinput
#endif	
	
#define _roleplay_sucess_included	
	
#if defined ROLEPLAY_SUB
	#include "../roleplay.sp"
#else
	#include "roleplay.sp"
#endif	
	
enum rp_type_success {	
	success_type_sql = 0,
	success_type_name,
	success_type_explain,
	success_type_max_objective,
	success_type_offline,
	success_type_all
};
enum type_SuccessData {
	sd_count = 0,
	sd_achieved,
	sd_last,
	sd_max
};
char g_szSuccessData[view_as<int>(success_list_all)][view_as<int>(success_type_all)][256] = {	
	{ "police", "Un casier vierge", "Ne pas se faire arrêter après plus d'une semaine.", "7" , "0" },
	{ "hopital", "L'homme qui vallait 3 milliards", "Se procurer les améliorations de chirurgiens, et les cumuler pendant plus de 48 heures.", "2880" , "0" },
	{ "mcdo", "Inception", "Gagner un happy-meal… dans un happy-meal.", "1" , "0" },
	{ "tueur", "L'assassin anonyme", "Acheter plus de 50 contrats, réussis, à des tueurs à gage.", "50" , "0" },
	{ "coach", "Le sport, c'est la santé", "Cumuler plus de 500 niveaux d'entrainement.", "500" , "0" },
	{ "dealer", "Rasta drogué", "Tomber en overdose.", "1" , "0" },
	{ "mafia", "Cosa Nostra", "Crocheter, voler, et tuer un policier en moins de 60 secondes.", "1" , "0" },
	{ "armurerie", "La gachette facile", "Acheter une arme, tuer l'armurier, ainsi qu'un policier à proximité en moins d'une minute.", "1" , "0" },
	{ "vetement", "Concours de costumes", "Changer plus de 100x son propre skin.", "100" , "0" },
	{ "detective", "L'indiscret", "Se procurer plus de 250 informations sur des joueurs à un détective privé.", "250" , "0" },
	{ "moniteur", "Fan de paintball", "Tirer l'équivalent de 5 000 billes de paintball.", "5000" , "0" },
	{ "loterie", "Ce n'est que le début", "Remporter pour un total de plus de 250 000$ grace à la loterie.", "250000" , "0" },
	{ "sexshop", "Sex-Appeal", "S'envoyer en l'air avec 10 joueurs en même temps, grâce à la sucette duo.", "1" , "0" },
	{ "technicien", "Le trafiquant", "Avoir une machine à faux-billets fonctionnelle pendant plus de 48 heures.", "48" , "0" },
	{ "touch_down", "Toucher le fond...", "Posséder 0$ pendant plus d'une journée, tout en étant sans emploi.", "1" , "0" },
	{ "touch_up", "... Et rebondir", "Avoir plus de 10 000$, un job, après avoir remporté le succès: \"Toucher le fond\".", "1" , "0" },
	{ "life_short", "La vie est courte", "Rester connecté pendant plus de 3 heures d'affilées sur le serveur.", "1" , "0" },
	{ "vengeur", "Le vengeur masqué", "Tuer 7x une personne venant de tuer un policier, dans les 7 secondes précédentes.", "7" , "0" },
	{ "marathon", "Marathonien", "Parcourir plus de 42,195km en courant.", "42195" , "0" },
	{ "brulure", "Brûlure au second degré", "Tuer un joueur enflammé, ainsi que le joueur l'ayant brulé.", "1" , "0" },
	{ "immune", "Réflexe immunitaire", "Utiliser un anti-poison dans la seconde qui suit votre empoisonnement.", "1" , "0" },
	{ "jetumeurs", "Je meurs, tu meurs", "Après avoir été tué par un policier, tuez le à son tour, dans les 60 secondes.", "1" , "0" },
	{ "noviolence", "Non-Violent", "Ne tuer personne pendant plus d'une semaine", "7" , "0" },
	{ "5sectokill", "Cinq secondes pour tuer", "Tuer un joueur en moins de 5 secondes après votre première connexion de la journée.", "1" , "0" },
	{ "no_spy", "Contre-Espionnage", "Tuer un joueur invisible.", "1" , "0" },
	{ "shared_work", "Travail collectif", "Faire partie d'un métier ayant 20 personnes actives.", "1" , "0" },
	{ "worldspawn", "Dans le décor", "Causer une chute fatale à un autre joueur grace à une arme à feu.", "1" , "0" },
	{ "only_one", "Il n'en restera qu'un!", "Se connecter en premier suite à un redémarrage du serveur.", "1" , "0" },
	{ "student", "Bon élève", "Écrire uniquement en utilisant le chat local pendant plus d'un mois.", "31" , "0" },
	{ "robin_wood", "Robin des bois", "Donner plus de 10 000$ à dix personnes différentes, ayant moins de 500$, sans se déconnecter.", "10" , "0" },
	{ "unknown", "Professeur, et volontaire! [BIENTÔT]", "Modifier un article du WiKi.", "1" , "1" },
	{ "in_gang", "La guerre des gangs", "Faire partie d'un groupe, et tuer 100 membres d'un autre groupe en zone PVP.", "100" , "0" },
	{ "pyramid", "BRAAAAAAAAAAHHHHHHH", "Faire partie d'une pyramide de 9 joueurs.", "1" , "0" },
	{ "ikea_fail", "Le briseur du dimanche", "Avoir posé, et détruit plus de 500 de ses propres meubles.", "500" , "0" },
	{ "graffiti", "L'art de la rue", "Poser 250 fois son tag.", "250" , "0" },
	{ "fireworks", "Un beau spectacle", "Exploser plus de 100 feux d'artifice.", "100" , "0" },
	{ "assurance", "L'assurance à vie", "S'assurer 10x contre les crashs.", "10" , "0" },
	{ "no_tech", "Non à la contrebande", "Détruire plus de 250 machines à faux billets.", "250" , "0" },
	{ "no_18th", "Non à la contrebande II", "Tuer plus de 25 membres des Dealer lorsqu'ils volent une arme.", "25" , "0" },
	{ "million", "Le million, le million, le million", "Posséder plus d'un million de $.", "1000000" , "0" },
	{ "pas_vu_pas_pris", "Pas vu, pas pris", "Ne pas se faire voler pendant plus d'une semaine RP.", "7" , "0" },
	{ "pissing", "J'te pisse au cul", "Étant complètement bourré, pisser sur un policier pendant plus de 30 secondes.", "30" , "0" },
	{ "trafiquant", "Trafiquant", "Récolter plus de 100 plants de cannabis.", "100" , "0" },
	{ "faster_dead", "Plus rapide que la mort", "Se faire soigner par un médecin, et le tuer dans la seconde.", "1" , "0" },
	{ "collector", "Le collectionneur", "Posséder 50 items différent sur soi.", "50" , "0" },
	{ "pvpkill", "Stratège", "Participer à une capture PvP, et remporter l'une des bases.", "1" , "0" },
	{ "monopoly", "Monopoly", "Posséder 7 appartements ou plus.", "7" , "0" },
	{ "menotte", "Justicier de l'amour", "Menotter plus de 100 personnes.", "100" , "0" },
	{ "cafeine", "Accro à la caféïne", "Boire plus de 100 cafés.", "100" , "0" },
	{ "to_infini", "Vers l'infini.. Et au-delà!", "Toucher le plafond de la map, s'écraser au sol, et mourir.", "1" , "0" },
	{ "with_succes", "Avec succès", "Réussir 50 succès.", "50" , "0" },
	{ "kidnapping", "Kidnapping", "Enlever un joueur, et obtenir la rancon.", "1" , "0" },
	{ "killpvp2", "Tuerie !", "Tuer 7 membres d'un autre gang en PvP lors d'une capture, sans mourir.", "7" , "0" },
	{ "alcool_abuse", "L'alcoolique anonyme", "Boire plus de 1000 boissons alcoolisées.", "1000" , "0" },
	{ "tel", "Dring dring…", "Atteindre le niveau 5 sur chacune des missions téléphoniques.", "10" , "0" },
	{ "w_friends", "Entre amis", "Parrainer 5 joueurs.", "5" , "0" },
	{ "w_friends2", "Entre amis II", "Parrainer 10 joueurs.", "10" , "0" },
	{ "w_friends3", "Entre amis III", "Parrainer 15 joueurs.", "15" , "0" },
	{ "bon_patron", "Bon patron", "En jeu, engager 50 nouveaux joueurs différents dans son propre job.", "50" , "0" },
	{ "rainbow", "Arc en ciel", "Utiliser 12 crayons de couleurs.", "12" , "0" },
	{ "hdv", "Hôtel des ventes", "Vendre 10 lots d'objets dans l'Hôtel des ventes.", "10" , "1" },
	{ "carkill", "G.T.A.", "Ecraser 100 joueurs sur la route.", "100" , "0" },
	{ "carshop", "Collectionneur de voitures", "Posséder et personnaliser 5 voitures avec des couleurs différentes.", "5" , "0" },
	{ "lotto", "Loto, toujours les mêmes…", "Gagner à la loterie de princeton.", "1" , "1" },
	{ "quota", "Quota", "En tant que chef, dépasser son quota d'au moins 25% pendant 1 ans.", "365" , "0" },
	{ "cpt", "cpt", "cpt", "100" , "2" }
};

int g_iUserSuccess[MAX_PLAYERS+1][view_as<int>(success_list_all)][view_as<int>(sd_max)];

int g_iSuccess_last_jail[MAX_PLAYERS+1];
int g_iSuccess_last_mafia[MAX_PLAYERS+1];
int g_iSuccess_last_touchdown[MAX_PLAYERS+1];
int g_iSuccess_last_lifeshort[MAX_PLAYERS+1];
int g_iSuccess_last_dead[MAX_PLAYERS+1];
int g_iSuccess_last_armu[MAX_PLAYERS+1][3];
float g_fSuccess_last_move[MAX_PLAYERS+1][3];
int g_iSuccess_last_burn[MAX_PLAYERS+1];
int g_iSuccess_last_kill[MAX_PLAYERS+1];
int g_iSuccess_last_5tokill[MAX_PLAYERS+1];
int g_iSuccess_last_shot[MAX_PLAYERS+1][2];
int g_iSuccess_last_1st[MAX_PLAYERS+1];
int g_iSuccess_last_chat[MAX_PLAYERS+1];
int g_iSuccess_last_pas_vu_pas_pris[MAX_PLAYERS+1];
int g_iSuccess_last_faster_dead[MAX_PLAYERS+1];
char g_szSuccess_last_give[MAX_PLAYERS+1][10][32];
int g_iSuccess_last_vengeur[MAX_PLAYERS + 1];

public Action cmd_SuccessTest(int client, int args) {
	CheckNoWonSuccess(client);
	
	return Plugin_Handled;
}


void Draw_Success(int client, int type) {
	char tmp[128];
	Menu menu = new Menu(Handle_Success);
	menu.SetTitle("Vos succès\n ");
	
	if( type == -1 ) {
		menu.AddItem("-2", "Mes succès accompli");
		menu.AddItem("-3", "Les succès à faire");
	}
	else if( type == -2 ) {
		int size = success_list_all;
		
		for(int i=0; i < size; i++) {
			if( CanMakeSuccess(client, i) )
				continue;
			if( i == view_as<int>(success_list_cpt) )
				continue;
			
			Format(tmp, sizeof(tmp), "%d", i);
			menu.AddItem(tmp, g_szSuccessData[i][success_type_name]);
		}
	}
	else if( type == -3 ) {
		int size = success_list_all;
	
		for(int i=0; i < size; i++) {
			if( !CanMakeSuccess(client, i) )
				continue;
			if( i == view_as<int>(success_list_cpt) )
				continue;
			
			Format(tmp, sizeof(tmp), "%d", i);
			menu.AddItem(tmp, g_szSuccessData[i][success_type_name]);
		}
	}
	else if( type >= 0 ) {
		
		String_WordWrap(tmp, 60);
		Format(tmp, sizeof(tmp), "%s", g_szSuccessData[type][success_type_explain]);
		
		menu.AddItem("_", g_szSuccessData[type][success_type_name], ITEMDRAW_DISABLED);
		menu.AddItem("_", tmp, ITEMDRAW_DISABLED);
		
		Format(tmp, sizeof(tmp), "%d/%s", g_iUserSuccess[client][type][sd_count], g_szSuccessData[type][success_type_max_objective]);
		menu.AddItem("_", tmp, ITEMDRAW_DISABLED);
	}
	
	menu.Display(client, MENU_TIME_FOREVER);
}
public int Handle_Success(Handle menu, MenuAction action, int client, int param2) {
	
	if (action == MenuAction_Select) {
		char options[128];
		GetMenuItem(menu, param2, options, sizeof(options));
		Draw_Success(client, StringToInt(options));
	}
	else if (action == MenuAction_End) {
		CloseHandle(menu);
	}
}
void CheckNoWonSuccess(int client) {
	if( !IsValidClient(client) )
		return;
	if( !g_bUserData[client][b_isConnected] )
		return;
	if( !g_bUserData[client][b_isConnected2] )
		return;
	if( !IsTutorialOver(client) )
		return;
	
	int time = GetTime() - (31*24*60*60);
	
	if( g_iUserSuccess[client][success_list_mafia][sd_last] < time ) {
		
		if( g_flUserData[client][fl_LastCrochettage] > 1.0 &&  g_iUserData[client][i_LastVolTime] > 1 &&  g_iSuccess_last_mafia[client] > 1 ) {
			if( g_flUserData[client][fl_LastCrochettage]+60.0 >= GetGameTime() &&
				g_iUserData[client][i_LastVolTime]+60 >= GetTime() &&
				g_iSuccess_last_mafia[client]+60 >= GetTime() ) {
					
				WonSuccess(client, success_list_mafia);
			}
		}
	}
	if( g_iUserSuccess[client][success_list_armurerie][sd_last] < time ) {
		if( g_iSuccess_last_armu[client][0] > 1 &&  g_iSuccess_last_armu[client][1] > 1 &&  g_iSuccess_last_armu[client][2] > 1 ) {
			if( g_iSuccess_last_armu[client][0]+60 >= GetTime() &&
				g_iSuccess_last_armu[client][1]+60 >= GetTime() &&
				g_iSuccess_last_armu[client][2]+60 >= GetTime() ) {
					
				WonSuccess(client, success_list_armurerie);
			}
		}
	}
	if( g_iUserSuccess[client][success_list_touch_down][sd_last] < time ) {
		if( g_iSuccess_last_touchdown[client] > 0 && g_iUserData[client][i_Job] == 0 && (g_iSuccess_last_touchdown[client]+(24*60)) <= GetTime() ) {
			WonSuccess(client, success_list_touch_down);
		}
	}
	if( g_iUserSuccess[client][success_list_touch_up][sd_achieved] == 0 ) {
		if( g_iUserSuccess[client][success_list_touch_down][sd_achieved] >= 1 && g_iUserData[client][i_Job] > 0 && (g_iUserData[client][i_Money]+g_iUserData[client][i_Bank]) >= 10000 ) {
			WonSuccess(client, success_list_touch_up);
		}
	}
	
	if( g_iUserSuccess[client][success_list_life_short][sd_last] < time ) {
		if( g_iSuccess_last_lifeshort[client] >= 1 && (g_iSuccess_last_lifeshort[client]+(3*60*60)) <= GetTime() ) {
			WonSuccess(client, success_list_life_short);
		}
	}
	
	if( g_iUserSuccess[client][success_list_robin_wood][sd_last] < time ) {
		if( strlen(g_szSuccess_last_give[client][9]) > 1 ) {
			WonSuccess(client, success_list_robin_wood);
		}
	}
	if( g_iUserSuccess[client][success_list_million][sd_last] < time ) {
		if( (g_iUserData[client][i_Money]+g_iUserData[client][i_Bank]) >= 1000000 ) {
			WonSuccess(client, success_list_million);
		}
		else {
			g_iUserSuccess[client][success_list_million][sd_count] = (g_iUserData[client][i_Money]+g_iUserData[client][i_Bank]);
		}
	}
	
	if( g_iUserSuccess[client][success_list_collector][sd_last] < time ) {
		
		g_iUserSuccess[client][success_list_collector][sd_count] = g_iUserData[client][i_ItemCount];
		if(  g_iUserData[client][i_ItemCount] >= StringToInt(g_szSuccessData[success_list_collector][success_type_max_objective]) ) {
			WonSuccess(client, success_list_collector);
		}
	}
	
	
	
	if( g_iUserSuccess[client][success_list_monopoly][sd_last] < time ) {
		if( g_iUserData[client][i_AppartCount] >= StringToInt(g_szSuccessData[success_list_monopoly][success_type_max_objective]) ) {
			WonSuccess(client, success_list_monopoly);
		}
	}
	
	if( g_iUserSuccess[client][success_list_hopital][sd_last] < time ) {
		if( g_bUserData[client][ch_Force] && g_bUserData[client][ch_Heal] && g_bUserData[client][ch_Jump] && g_bUserData[client][ch_Regen] && g_bUserData[client][ch_Speed] ) {
			rp_IncrementSuccess(client, success_list_hopital);
		}
	}
	if( Math_GetRandomInt(1, 100) == 42) {
		
		int amount, amount2;
		
		for(int i=0; i<view_as<int>(success_list_all); i++) {
			if( g_iUserSuccess[client][i][sd_achieved] >= 1 ) {
				amount++;
				amount2 += g_iUserSuccess[client][i][sd_achieved];
			}
		}
		
		if( g_iUserSuccess[client][success_list_with_succes][sd_last] < time ) {
			g_iUserSuccess[client][success_list_with_succes][sd_count] = amount;
			if( amount >= StringToInt(g_szSuccessData[success_list_with_succes][success_type_max_objective]) ) {
				WonSuccess(client, success_list_with_succes);
			}
		}
		g_iUserSuccess[client][success_list_cpt][sd_count] = amount2;
	}
	
	if( g_iGroundEntity[client] > 0 && Math_GetRandomInt(1, 7) == 5 ) {
		
		int i=1;
		int tmp;
		int target = client;
		bool mark[MAX_PLAYERS+1];
		
		while(IsValidClient(g_iGroundEntity[target]) ) {
			
			tmp = g_iGroundEntity[target];
			if( !IsValidClient(tmp) )
				break;
			
			target = tmp;
			if( mark[target] )
				break;
			
			mark[target] = true;
			i++;
		}
		if( i>=9 ) {
			
			target = client;
			
			while(IsValidClient(g_iGroundEntity[target]) ) {
				
				tmp = g_iGroundEntity[target];
				if( !IsValidClient(tmp) )
					break;
				
				target = tmp;
				WonSuccess(target, success_list_pyramid);
			}
		}
			
	}
}

void CheckDeadSuccess(int Client, int Attacker) {
	int time = GetTime() - (31*24*60*60);
	
	
	if( Attacker == 0  ) {
		if( g_iSuccess_last_shot[Client][1]+(5) > GetTime() ) {
			WonSuccess(g_iSuccess_last_shot[Client][0], success_list_worldspawn);
		}
	}
	else {
		if( g_iSuccess_last_vengeur[Client] > 1 && g_iSuccess_last_vengeur[Client]+7 >= GetTime() ) {
			IncrementSuccess(Attacker, success_list_vengeur);
		}
		if( g_bUserData[Client][b_Invisible] ) {
			IncrementSuccess(Attacker, success_list_no_spy);
		}
		if( g_bUserData[Client][b_Stealing] ) {
			IncrementSuccess(Attacker, success_list_no_18th);
		}
		if( g_iSuccess_last_faster_dead[Client]+1 >= GetTime() ) {
			WonSuccess(Attacker, success_list_faster_dead);
		}
		if( IsValidClient(g_iUserData[Client][i_BurnedBy]) && g_flUserData[Client][fl_Burning] > GetGameTime() ) {
			g_iSuccess_last_burn[Attacker] = g_iUserData[Client][i_BurnedBy];
		}
		if( g_iSuccess_last_burn[Attacker] == Client ) {
			WonSuccess(Attacker, success_list_brulure);
		}
		if( g_iSuccess_last_5tokill[Attacker] > 1 && g_iSuccess_last_5tokill[Attacker]+(5) >= GetTime() ) {
			WonSuccess(Attacker, success_list_5sectokill);
		}
	
		g_iSuccess_last_kill[Attacker] = GetTime();
		g_iSuccess_last_dead[Client] = GetTime();
		if( g_iSuccess_last_dead[Attacker]+60 >= GetTime() ) {
			if( g_iUserData[Client][i_Job] >= 1 && g_iUserData[Client][i_Job] <= 10 ) {
				WonSuccess(Attacker, success_list_jetumeurs);
			}
		}
		
		if( GetClientTeam(Client) == CS_TEAM_CT ) {
			g_iSuccess_last_mafia[Attacker] = GetTime();
			g_iSuccess_last_armu[Attacker][2] = GetTime();
			g_iSuccess_last_vengeur[Attacker] = GetTime();
			
			for (int i = 1; i <= MaxClients; i++ ) {
				if( IsValidClient(i) && IsPlayerAlive(i) && CanMakeSuccess(i, success_list_vengeur) )
					rp_ClientAggroIncrement(Attacker, i, 1000);
			}
		}
		if( IsArmu(Client) ) {
			g_iSuccess_last_armu[Attacker][1] = GetTime();
		}
	}
}

void WonSuccess(int client, int success) {
	
	if( IsValidClient(client) && CanMakeSuccess(client, success) && g_bUserData[client][b_isConnected] && g_bUserData[client][b_isConnected2] && IsTutorialOver(client) ) {
		
		char szSteamID[64], query[1024];
		GetClientAuthId(client, AUTH_TYPE, szSteamID, sizeof(szSteamID), false);
		
		g_iUserSuccess[client][success][sd_last] = GetTime();
		g_iUserSuccess[client][success][sd_count] = 0;
		g_iUserSuccess[client][success][sd_achieved]++;
		
		CPrintToChatAllEx(client, "" ...MOD_TAG... " %N{default} a remporté le succès {lightblue}%s{default}", client, g_szSuccessData[success][success_type_name]); 
		rp_ClientXPIncrement(client, 500);
		
		LogToGame("[TSX-RP] [SUCCES] %N (%s) a remporté le succès: %s", client, szSteamID, g_szSuccessData[success][success_type_name]);
		
		Format(query, sizeof(query), "UPDATE `rp_success`SET `%s`='%d %d %d' WHERE `SteamID`='%s' LIMIT 1;", g_szSuccessData[success][success_type_sql], g_iUserSuccess[client][success][sd_count], g_iUserSuccess[client][success][sd_achieved], g_iUserSuccess[client][success][sd_last], szSteamID);
		SQL_TQuery(g_hBDD, SQL_QueryCallBack, query);		
	}
}
void IncrementSuccess(int client, int success, int amount =1) {
	if( IsValidClient(client) && CanMakeSuccess(client, success) && g_bUserData[client][b_isConnected] && g_bUserData[client][b_isConnected2] && IsTutorialOver(client) ) {
		g_iUserSuccess[client][success][sd_count] += amount;
		if( g_iUserSuccess[client][success][sd_count] >= StringToInt(g_szSuccessData[success][success_type_max_objective]) ) {
			WonSuccess(client, success);
		}
	}
}
bool CanMakeSuccess(int client, int success) {
	return g_iUserSuccess[client][success][sd_last]+(31*24*60*60) < GetTime();
}