#!/bin/sh
PATH=/Users/mac/Desktop/DEV/Gozer/riplay-rp

if [ ! -d $PATH ]; then
	echo "$PATH not exist"
	exit 1
fi 	

COMP_PATH="$PATH/scripting/spcomp_mac"

if [ ! -d $PATH ]; then
	echo "$COMP_PATH not exist"
	exit 1
fi 	

cd $PATH 

/bin/rm -r compiled
/bin/mkdir compiled

echo "Compiling core/roleplay.sp \n\n" >> $PATH/compiled/report.txt
echo "Compiling core/roleplay.sp"

$COMP_PATH -i includes -i core -i scripting "./core/roleplay.sp" -o=compiled/roleplay.smx >> $PATH/compiled/report.txt

NUMB_SP=0
NUMB_SMX=0

for file in `/usr/bin/find . -type f -name "*.sp" | /usr/bin/egrep "^\./(jobs|quests|utils|weapons)/"`
do
	NUMB_SP=$(($NUMB_SP + 1))

	echo "-----------------------------------------------------------------------------------------------\n\n" >> $PATH/compiled/report.txt
	echo "Compiling $file \n\n" >> $PATH/compiled/report.txt
	echo "Compiling $file"
	
	smxfile="`echo ${file#./} | /usr/bin/sed -e 's/\.sp$/\.smx/'`"
	$COMP_PATH -i includes -i core -i scripting $file -o=$smxfile >> $PATH/compiled/report.txt

	if [ -f $smxfile ]; then
		NUMB_SMX=$(($NUMB_SMX + 1))

		/usr/bin/rsync -R $smxfile $PATH/compiled/
		/bin/rm $smxfile
	else
		echo "Error on $file"
	fi
done

/bin/rm $PATH/compiled/quests/groups/rp_quest_pve_duo.smx
/bin/rm $PATH/compiled/quests/groups/rp_quest_pve_solo.smx

echo "Compilation completed $NUMB_SMX/$NUMB_SP"