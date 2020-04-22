#include <sourcemod>
#include <sdktools>

#define MODEL "models/natalya/vehicles/natalya_mustang_csgo_2016.mdl"
#define SCRIPT "scripts/vehicles/natalya_mustang_csgo_2016.txt"

public void OnMapStart() {
	PrecacheModel(MODEL);
}

public void OnPluginStart() {
	RegConsoleCmd("sm_kriaxvoiture", Command_KriaxVoiture);
}

public Action Command_KriaxVoiture(int client, int args) {
	if(!IsClientInGame(client)) {
		return Plugin_Handled;
	}

 	PrintToChat(client, "debug before");

	SpawnCar(client);

	PrintToChat(client, "debug after");

	return Plugin_Handled;
}

public void SpawnCar(client) {
	LogToFile("vehicules.txt", "%s", MODEL);

	int ent = CreateEntityByName("prop_vehicle_driveable");

	if( ent == -1) { 
		LogToFile("vehicules.txt", "end invalid");
		return;
	}

	LogToFile("vehicules.txt", "new ent index %i", ent);

	DispatchKeyValue(ent, "vehiclescript", 		SCRIPT);
	DispatchKeyValue(ent, "model", 				MODEL);
	DispatchKeyValueFloat (ent, "MaxPitch", 360.00);
	DispatchKeyValueFloat (ent, "MinPitch", -360.00);
	DispatchKeyValueFloat (ent, "MaxYaw", 90.00);
	DispatchKeyValue(ent, "targetname", "car_test");
	DispatchKeyValue(ent, "solid","6");
	DispatchKeyValue(ent, "skin", "0");
	DispatchKeyValue(ent, "actionScale","1");
	DispatchKeyValue(ent, "EnableGun","0");
	DispatchKeyValue(ent, "ignorenormals","0");
	DispatchKeyValue(ent, "fadescale","1");
	DispatchKeyValue(ent, "fademindist","-1");
	DispatchKeyValue(ent, "VehicleLocked","0");
	DispatchKeyValue(ent, "screenspacefade","0");
	DispatchKeyValue(ent, "spawnflags", "256" );
	DispatchKeyValue(ent, "setbodygroup", "511" );
	SetEntProp(ent, Prop_Send, "m_nSolidType", 2);
	SetEntProp(ent, Prop_Data, "m_nVehicleType", 8);

	LogToFile("vehicules.txt", "before dispatch");

	Handle pack = CreateDataPack();
	CreateTimer(3.0, test, pack);
	WritePackCell(pack, ent);
	WritePackCell(pack, client);

	LogToFile("vehicules.txt", "create timer");
}

public Action test(Handle timer, Handle pack) {
	ResetPack(pack);
	int ent = ReadPackCell(pack);
	int client = ReadPackCell(pack);

	LogToFile("vehicules.txt", "timer callback");

	//AcceptEntityInput(ent, "TurnOff");

	LogToFile("vehicules.txt", "before dispatch");

	DispatchSpawn(ent);

	LogToFile("vehicules.txt", "after dispatch");

	LogToFile("vehicules.txt", "before activate");

	ActivateEntity(ent);

	LogToFile("vehicules.txt", "after activate");

	LogToFile("vehicules.txt", "before teleport");

	float origin[3], angle[3];
	GetClientAbsOrigin(client, origin);
	GetClientAbsAngles(client, angle);

	TeleportEntity(ent, origin, angle, NULL_VECTOR);

	LogToFile("vehicules.txt", "after teleport");

	LogToFile("vehicules.txt", "end");
}