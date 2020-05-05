  #include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <colors_csgo>
#include <rp_version>
#include <roleplay.inc>
#include <smlib>

int g_TEST = 0;

public void OnPluginStart() {
	RegServerCmd("sm_debugcapitals", Command_DebugCapitals)
}

public Action Command_DebugCapitals(int args) {
	char test[32];
	GetCmdArg(1, test, 32);
	g_TEST = StringToInt(test);

	if(g_TEST == 0) {
		g_TEST = 100;
	}

	PrintToServer("Test avec %i$", g_TEST);

	debugJob();
}

void debugJob() {
	int capitalList[MAX_JOBS][2];
	int numb = -1;
	int capital = 0;

	for(int i = 1; i < MAX_JOBS; i++) {
		if(rp_GetJobInt(i, job_type_isboss) == 0) {
			continue;
		}

		if(rp_GetJobInt(i, job_type_current) == 0) {
			continue;
		}

		capital = rp_GetJobCapital(i);

		numb++;
		capitalList[numb][0] = capital;
		capitalList[numb][1] = i;	
	}

	SortCustom2D(capitalList, numb, SortMachineItemsL2H);

	float min = FloatAbs(float(capitalList[0][0]));

	PrintToServer("-------- result --------");

	int totalcapital = 0;
	
	for(int i = 0; i < 5; i++) {
		totalcapital = totalcapital + capitalList[i][0] + RoundToFloor(min);
	}

	PrintToServer("• Total Capital: %i$ \n", totalcapital);

	int percent[5];

	for(int i = 0; i < 5; i++) {
		percent[i] = Math_GetPercentage(capitalList[i][0] + RoundToFloor(min), totalcapital);
	}

	int add = 0;

	char szTemps[32];

	for(int i = 0; i < 5; i++) {
		add = (g_TEST * percent[4-i]) / 100;
		rp_GetJobData(capitalList[i][1], job_type_name, szTemps, sizeof(szTemps));
		PrintToServer("[%i] %s -> %i$ = %i\% donc auras %i = %i$", capitalList[i][1], szTemps, capitalList[i][0], percent[i], percent[4-i], add);
	}
}

public int SortMachineItemsL2H(int[] a, int[] b, const int[][] array, Handle hndl)  {
	if( b[0] == a[0] )
		return 0;
	else if( b[0] < a[0] )
		return 1;
	else
		return -1;
}