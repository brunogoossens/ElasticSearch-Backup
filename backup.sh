#!/bin/bash  

ES='http://localhost:9200' #address of elasticsearch server
LOCATION='/path/to/backup/folder' #elasticsearch must have writing rights to this folder

# create repository
REPO=$(curl -sS -XGET "$ES/_snapshot/_all")
if ! [[ $REPO == *'"location":"'$LOCATION'"'* ]];
then
 	REPO=$(curl -sS -XPUT "$ES/_snapshot/minerva_es" -d '{ "type": "fs", "settings": { "location": "'$LOCATION'", "compress": true } }')
	if ! [[ $REPO == *'"acknowledged":true'* ]]
	then
		echo "failed creating repo"
	fi
fi

# create snaptshot
DATE=$(date +"%Y-%m-%d_%T")
BACKUP=$(curl -sS -XPUT "$ES/_snapshot/minerva_es/$DATE?wait_for_completion=true")
if ! [[ $BACKUP == *'"state":"SUCCESS"'* ]];  
then 
	echo 'Backup failed'
fi
