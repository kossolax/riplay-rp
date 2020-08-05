#!/bin/bash
set -e
set -o pipefail

rm -rf compiled
mkdir compiled

_compile() {
    fileout="${1/\.sp/}"
    fileout="${fileout##*/}"
    echo "$1"
    scripting/spcomp64 -i includes -i core -i scripting "$1" "-o=compiled/$fileout"
}

files=`find . -type f -name "*.sp" | grep -E "^\./(jobs|quests|utils|weapons|others)/"`
files="$files
./core/roleplay.sp" 

for file in $files; do
    if [[ -n "$1" ]]; then
        if [[ "$file" != *"$1"* ]]; then
            continue
        fi
    fi
    _compile $file 
done
 
