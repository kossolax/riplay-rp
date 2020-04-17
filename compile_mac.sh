
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

$COMP_PATH -i includes -i core -i scripting "./core/roleplay.sp" -o=compiled/roleplay.smx >> $PATH/compiled/report.txt

for file in `/usr/bin/find . -type f -name "*.sp" | /usr/bin/egrep "^\./(jobs|quests|utils|weapons)/"`
do
	echo "-----------------------------------------------------------------------------------------------\n\n" >> $PATH/compiled/report.txt
	echo "Compiling $file \n\n" >> $PATH/compiled/report.txt

	smxfile="`echo ${file#./} | /usr/bin/sed -e 's/\.sp$/\.smx/'`"
	$COMP_PATH -i includes -i core -i scripting $file -o=$smxfile >> $PATH/compiled/report.txt

	if [ -f $smxfile ]; then
		/usr/bin/rsync -R $smxfile $PATH/compiled/
		/bin/rm $smxfile
	fi
done 

#/bin/rm $PATH/compiled/rp_quest_police-001.smx
#/bin/rm $PATH/compiled/roleplay_pvprecord.smx
#/bin/rm $PATH/compiled/roleplay_pvp.smx

echo "Compilation completed"