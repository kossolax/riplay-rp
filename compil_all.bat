rmdir /s /q compiled
mkdir compiled


"scripting/spcomp.exe" -i includes -i core -i scripting "core/roleplay.sp" -o=compiled/roleplay.smx

for /R "jobs" %%i in (*.sp) do "scripting/spcomp.exe" -i includes -i core -i scripting %%i -o=compiled\%%~ni
for /R "quests" %%i in (*.sp) do "scripting/spcomp.exe" -i includes -i core -i scripting %%i -o=compiled\%%~ni
for /R "utils" %%i in (*.sp) do "scripting/spcomp.exe" -i includes -i core -i scripting %%i -o=compiled\%%~ni
for /R "weapons" %%i in (*.sp) do "scripting/spcomp.exe" -i includes -i core -i scripting %%i -o=compiled\%%~ni

pause 