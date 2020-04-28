rmdir /s /q compiled
mkdir compiled


"scripting/spcomp.exe" -i includes -i core -i scripting "core/roleplay.sp" -o=compiled/roleplay.smx

for /R "jobs" %%i in (*.sp) do "scripting/spcomp.exe" -i includes -i core -i scripting %%i -o=compiled\%%~ni
for /R "quests" %%i in (*.sp) do "scripting/spcomp.exe" -i includes -i core -i scripting %%i -o=compiled\%%~ni
for /R "utils" %%i in (*.sp) do "scripting/spcomp.exe" -i includes -i core -i scripting %%i -o=compiled\%%~ni
for /R "weapons" %%i in (*.sp) do "scripting/spcomp.exe" -i includes -i core -i scripting %%i -o=compiled\%%~ni

del compiled\rp_quest_police-001.smx
del compiled\roleplay_pvprecord.smx
del compiled\roleplay_pvp.smx


pause 