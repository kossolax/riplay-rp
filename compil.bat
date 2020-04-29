rmdir /s /q compiled
mkdir compiled


"scripting/spcomp.exe" -i includes -i core -i scripting "core/roleplay.sp" -o=compiled/roleplay.smx


del compiled\rp_quest_police-001.smx
del compiled\roleplay_pvprecord.smx
del compiled\roleplay_pvp.smx


pause 