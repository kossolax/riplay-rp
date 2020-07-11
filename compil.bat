rmdir /s /q compiled
mkdir compiled


"scripting/spcomp.exe" -i includes -i core -i scripting "core/roleplay.sp" -o=compiled/roleplay.smx


pause 