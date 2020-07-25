#!/bin/bash
set -eux
set -o pipefail

rm -rf compiled
mkdir compiled

_compile() {
    fileout="${1/\.sp/}"
    fileout="${fileout##*/}"
    scripting/spcomp64 -i includes -i core -i scripting "$1" "-o=compiled/$fileout"
}

files=`find . -type f -name "*.sp" | grep -E "^\./(jobs|quests|utils|weapons|others)/"`

for file in $files; do
    _compile $file 
done

_compile "core/roleplay.sp"
 