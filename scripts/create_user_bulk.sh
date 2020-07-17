#!/bin/bash

ARG1: fichier contenant uniquement le user de chaq adresse
ARG2: domaine

while IFS= read -r login; do
	echo "Création de la boite email de $login" >> ~/create_user_bulk.log
	postfixadmin-cli mailbox add ${login}@${2} --password ${login}123 --password2 ${login}123 --name $login --quota 16 >> ~/create_user_bulk.log
done < $1
echo "log disponibles sur ~/create_user_bulk.log"

