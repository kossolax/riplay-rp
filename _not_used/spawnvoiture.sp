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

 	char arg[4];
 	GetCmdArg(1, arg, sizeof(arg));
 	int type = StringToInt(arg);

	SpawnCar(client, type);

	PrintToChat(client, "debug after");

	return Plugin_Handled;
}

public void SpawnCar(client, int type) {
	LogToFile("vehicules.txt", "%s", MODEL);

	int ent = CreateEntityByName("prop_vehicle_driveable");

	if( ent == -1) { 
		PrintToChatAll("invalid index");
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
	SetEntProp(ent, Prop_Data, "m_nVehicleType", type);

	int test = GetEntProp(ent, Prop_Data, "m_nVehicleType");
	LogToFile("vehicules.txt", "type %i", test);

	LogToFile("vehicules.txt", "before dispatch");

	DispatchSpawn(ent);
	ActivateEntity(ent);

	LogToFile("vehicules.txt", "before tele");

	float origin[3], angle[3];
	GetClientAbsOrigin(client, origin);
	GetClientAbsAngles(client, angle);

	TeleportEntity(ent, origin, angle, NULL_VECTOR);

	LogToFile("vehicules.txt", "after tele");
}