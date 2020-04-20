#include <sourcemod>

public Plugin:myinfo = 
{
	name = "CSS-RP SlowLoad",
	author = "KoSSoLaX`",
	description = "Relai le redémarage du serveur RP",
	version = "1.0",
	url = "http://www.ts-x.eu/"
}

public OnMapStart() {
	ServerCommand("sv_password \"blablaploplololol\"");
	CreateTimer(10.0, Reboot);
}
public Action:Reboot(Handle:timer, any:zomg) {
	ServerCommand("exit");
}