#!/bin/bash

while IFS= read -r line; do
	echo "Traitement du fichier d'alias" >> ~/create_alias_bulk.log
	from=$( echo "$line" | awk '{print $1}' )
	to=$( echo "$line" | awk '{print $2}' )
	postfixadmin-cli alias add ${from}@fdn.fr --goto ${to} >> ~/create_alias_bulk.log
done < $1
echo "log disponibles sur ~/create_alias_bulk.log"

