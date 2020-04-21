#include <sourcemod>

public void OnMapStart() {
	CreateTimer(10.0, NotPlayerShowed);
}

public Action NotPlayerShowed(Handle timer) {
	ServerCommand("host_players_show 1");
}