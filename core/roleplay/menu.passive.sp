#if defined _roleplay_menu_passive_included
#endinput
#endif
#define _roleplay_menu_passive_included

#if !defined _roleplay_base_included || defined ROLEPLAY_SUB
	#define ROLEPLAY_SUB
	#include "../roleplay.sp"
#else
	#include "roleplay.sp"
#endif

void Draw_PassiveMenu(int client) {
	
	Menu menu = new Menu(Menu_Passive);
	menu.SetTitle("Quel est votre mode de jeu préféré?\n ");
	
	menu.AddItem("1", "Activer le mode passif:\n- Vous ne pouvez mourir qu'en cas de légitime défense.\n- Ce mode est récommandé.\n ");
	menu.AddItem("2", "Activer le mode actif:\n- Vous autorisez les autres joueurs à vous freekill.\n- Vous avez le droit de freekill.\n ");
	
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Menu_Passive(Handle p_hItemMenu, MenuAction p_oAction, int client, int param) {
	if (p_oAction == MenuAction_Select) {
		
		char szMenuItem[64];
		GetMenuItem(p_hItemMenu, param, szMenuItem, sizeof(szMenuItem));
		
		if( StrEqual(szMenuItem, "1") ) {
			Menu menu = new Menu(Menu_Passive);
			menu.SetTitle("Vous avez choisi le mode passif :\n \n- Vous ne pouvez attaquer qu'en cas de légitime défense.\n- Vous ne pouvez mourir que par légitime défense.\n \n Ce mode s'activera dans 1 minute.\n ");
			menu.AddItem("0", "Je refuse");
			menu.AddItem("3", "Je confirme mon choix.");
			
			menu.Display(client, MENU_TIME_FOREVER);
		}
		else if( StrEqual(szMenuItem, "2") ) {
			Menu menu = new Menu(Menu_Passive);
			
			char tmp[128];
			int jobID = rp_GetClientJobID(client);
			switch(jobID) {
				case 1: Format(tmp, sizeof(tmp), "- Double les gains liés aux amendes.");
				case 11: Format(tmp, sizeof(tmp), "- Immunité à l'overdose et aux poisons.");
				case 21: Format(tmp, sizeof(tmp), "- Double le bonus de la vitalité.");
				case 31: Format(tmp, sizeof(tmp), "- Vous trouvez des M.P. en marchant.");
				case 41: Format(tmp, sizeof(tmp), "- +25%% de vitesse de déplacement en contrat.");
				case 51: Format(tmp, sizeof(tmp), "- Vos meurtres en voiture sont retiré des logs.");
				case 61: Format(tmp, sizeof(tmp), "- Tous les bonus d'appartement sont gratuit.");
				case 71: Format(tmp, sizeof(tmp), "- Votre précision de tir augmente en marchant.");
				case 81: Format(tmp, sizeof(tmp), "- +50%% de vitesse de déplacement après un vol.");
				case 91: Format(tmp, sizeof(tmp), "- +50%% de vitesse de déplacement après un vol.");
				case 101: Format(tmp, sizeof(tmp), "- +5 regénération de vie chaques secondes.");
				case 111: Format(tmp, sizeof(tmp), "- +25%% de dégât supplémentaire via les armes à feux.");
				case 131: Format(tmp, sizeof(tmp), "- +50%% de dégât supplémentaire via les explosifs");
				case 171: Format(tmp, sizeof(tmp), "- Vous trouvez des jetons rouge en marchant.");
				case 191: Format(tmp, sizeof(tmp), "- +50%% de dégât et de portée de la sucette-duo.");
				case 211: Format(tmp, sizeof(tmp), "- L'hôtel des ventes est gratuit.");
				case 221: Format(tmp, sizeof(tmp), "- Vos machines produisent 2x plus rapidement.");
			}
			menu.SetTitle("Vous avez choisi le mode actif :\n \n- Vous pouvez attaquer quand vous le souhaitez.\n- Vous pouvez tuer sans justification.\n- Vous risquez de mourir sans raison.\n- Votre vitalité augmente chaques secondes\n%s\n \n Ce mode s'activera dans 1 minute.\n ", tmp);
			
			menu.AddItem("4", "Je confirme mon choix");
			menu.AddItem("0", "Je refuse");
			
			menu.Display(client, MENU_TIME_FOREVER);
		}
		else if( StrEqual(szMenuItem, "3") || StrEqual(szMenuItem, "4") ) {
			
			
			if( StrEqual(szMenuItem, "3") ) {
				if( g_iUserData[client][i_KillJailDuration] >= 6 ) {
					CPrintToChat(client, "" ...MOD_TAG... " Ayant commis un meurtre récement, vous ne pouvez passer en mode passif tant que vous avez des meurtres à votre actif.");
					g_hTIMER[client] = INVALID_HANDLE;
					Draw_PassiveMenu(client);
					return;
				}
				if( g_iUserData[client][i_LastAgression]+30 >= GetTime() ) {
					CPrintToChat(client, "" ...MOD_TAG... " Ayant commis une agression physique récement, vous ne pourrez activer ce mode que dans %d seconde(s).", g_iUserData[client][i_LastAgression]+30-GetTime() );
					g_hTIMER[client] = INVALID_HANDLE;
					Draw_PassiveMenu(client);
					return;
				}
				if( g_iUserData[client][i_LastDangerousShot]+30 >= GetTime() ) {
					CPrintToChat(client, "" ...MOD_TAG... " Ayant commis un tir dangereux récement, vous ne pourrez activer ce mode que dans %d seconde(s).", g_iUserData[client][i_LastDangerousShot]+30-GetTime() );
					g_hTIMER[client] = INVALID_HANDLE;
					Draw_PassiveMenu(client);
					return;
				}
			}
			
			if( g_hTIMER[client] != INVALID_HANDLE )
				delete g_hTIMER[client];
			
			DataPack dp = CreateDataPack();
			g_hTIMER[client] = CreateDataTimer(60.0, switchToPassive, dp, TIMER_DATA_HNDL_CLOSE);
			dp.WriteCell(client);
			dp.WriteCell(StrEqual(szMenuItem, "3"));
			
			CPrintToChat(client, "" ...MOD_TAG... " Le mode de jeu %s va être activé dans une minute.", StrEqual(szMenuItem, "3") ? "passif" : "actif");
		}
		else {
			Draw_PassiveMenu(client);
		}
	}
	else if (p_oAction == MenuAction_End) {
		CloseHandle(p_hItemMenu);
	}
}
public Action switchToPassive(Handle timer, Handle dp) {
	ResetPack(dp);
	int client = ReadPackCell(dp);
	bool value = ReadPackCell(dp);
	
	if( value ) {
		if( g_iUserData[client][i_KillJailDuration] >= 6 ) {
			CPrintToChat(client, "" ...MOD_TAG... " Ayant commis un meurtre récement, vous ne pouvez passer en mode passif tant que vous avez des meurtres à votre actif.");
			g_hTIMER[client] = INVALID_HANDLE;
			Draw_PassiveMenu(client);
			return Plugin_Handled;
		}
		if( g_iUserData[client][i_LastAgression]+60 >= GetTime() ) {
			CPrintToChat(client, "" ...MOD_TAG... " Ayant commis une agression physique récement, vous ne pourrez activer ce mode que dans %d seconde(s).", g_iUserData[client][i_LastAgression]+60-GetTime() );
			g_hTIMER[client] = INVALID_HANDLE;
			return Plugin_Handled;
		}
		if( g_iUserData[client][i_LastDangerousShot]+60 >= GetTime() ) {
			CPrintToChat(client, "" ...MOD_TAG... " Ayant commis un tir dangereux récement, vous ne pourrez activer ce mode que dans %d seconde(s).", g_iUserData[client][i_LastDangerousShot]+60-GetTime() );
			g_hTIMER[client] = INVALID_HANDLE;
			Draw_PassiveMenu(client);
			return Plugin_Handled;
		}
	}
	
	g_bUserData[client][b_GameModePassive] = value;
	CPrintToChat(client, "" ...MOD_TAG... " Le mode de jeu %s a été activé.", value ? "passif" : "actif");
	
	g_hTIMER[client] = INVALID_HANDLE;
	return Plugin_Handled;
}