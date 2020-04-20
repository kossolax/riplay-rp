#include <sourcemod>

public void OnMapStart() {
	RegConsoleCmd("sm_myskin", Command_MySkin);
}

public Action Command_MySkin(int client, int args) {
	if(!IsClientInGame(client) || !IsPlayerAlive(client)) {
        return Plugin_Handled;
    }

    char szSkin[256];
    GetClientModel(client, szSkin, sizeof(szSkin));

    PrintToChat(client, "skins: %s", szSkin);

    RenderMode render = GetEntityRenderMode(client);

    PrintToChat(client, "render: %i", render);

    int color[4];
    GetEntityRenderColor(client, color[0], color[1], color[2], color[3]);

    PrintToChat(client, "color: %i %i %i %i", color[0], color[1], color[2], color[3]);

    return Plugin_Handled;
}