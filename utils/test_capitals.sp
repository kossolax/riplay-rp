#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <colors_csgo>
#include <rp_version>
#include <roleplay.inc>
#include <smlib>

public void OnPluginStart() {
	RegServerCmd("sm_debugcapitals", Command_DebugCapitals)
}

public Action Command_DebugCapitals(int args) {
	debugJob();
}

void debugJob() {
	int capitalList[MAX_JOBS][2];
	int numb = -1;
	char szTemps[32];

	for(int i = 1; i < MAX_JOBS; i++) {
		if(rp_GetJobInt(i, job_type_isboss) == 0) {
			continue;
		}

		if(rp_GetJobInt(i, job_type_current) == 0) {
			continue;
		}

		rp_GetJobData(i, job_type_name, szTemps, sizeof(szTemps));

		numb++;
		capitalList[numb][0] = rp_GetJobCapital(i);
		capitalList[numb][1] = i;	

		PrintToServer("[%i] add %s : %i$", i, szTemps, rp_GetJobCapital(i));
	}

	SortCustom2D(capitalList, 5, SortMachineItemsL2H);

	PrintToServer("-------- result --------");

	for(int i = 0; i < numb; i++) {
		rp_GetJobData(capitalList[i][1], job_type_name, szTemps, sizeof(szTemps));
		PrintToServer("[%i] %s -> %i$", capitalList[i][1], szTemps, capitalList[i][0]);
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