#!/bin/bash

rm -rf compiled
mkdir compiled

_compile() {
    echo "COMP"
    echo $1 $2
    echo "COMP"
    scripting/spcomp64 -i includes -i core -i scripting "$1" "-o=compiled/$2"
    let "i=i+1"
    echo -ne "$i/$all "
}

files=`/usr/bin/find . -type f -name "*.sp" | /usr/bin/egrep "^\./(jobs|quests|utils|weapons|others)/"`

for file in $files; do
    _compile $file ${file/\.sp/}
    let "i=i+1"
done

_compile "core/roleplay.sp" roleplay.smx
 