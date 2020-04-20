#include <sourcemod>
#include <smlib>

public void OnMapStart() {
	RegServerCmd("sm_findsun", Command_FindSun);
}

public Action Command_FindSun(int args) {
	int id = FindEntityByClassname(0, "env_cascade_light");

	LogToGame("%i", id);
}