#!/bin/bash

F_var_init () {
	####################### chargement des variables globales
	#######################
	############ Liste des paquets à installer
	mail_paquets="mariadb-server postfix postfix-mysql libsasl2-modules libapache2-mod-security2 dovecot-mysql dovecot-pop3d dovecot-imapd dovecot-lmtpd dovecot-managesieved sasl2-bin dovecot-core rspamd redis-server"
	webmail_paquets="apache2 php7.3 rainloop libapache2-mod-security2 dovecot-core mariadb-client php7.3-mysql php7.3-mbstring php7.3-imap php7.3-fpm curl"
	############ Variables d'infra globales
	email=$(                cat "./config.json" | jq '.infra.email'  	     | tr --delete '"')
	domaine=$(              cat "./config.json" | jq '.infra.domaine'            | tr --delete '"')
	admin_pa_user=$(        cat "./config.json" | jq '.infra.admin_pa_user'      | tr --delete '"')
	admin_pa_passwd=$(      cat "./config.json" | jq '.infra.admin_pa_passwd'    | tr --delete '"')
	selector=$(             cat "./config.json" | jq '.mail.selector'            | tr --delete '"')
	le_sign=$(              cat "./config.json" | jq '.infra.le_sign'            | tr --delete '"')
	db_pa_user=$(           cat "./config.json" | jq '.infra.db_pa_user'         | tr --delete '"')
	db_pa_passwd=$(         cat "./config.json" | jq '.infra.db_pa_passwd'       | tr --delete '"')
	db_p_user=$(            cat "./config.json" | jq '.infra.db_p_user'          | tr --delete '"')
	db_p_passwd=$(          cat "./config.json" | jq '.infra.db_p_passwd'        | tr --delete '"')
	db_rainloop_user=$(     cat "./config.json" | jq '.infra.db_rainloop_user'   | tr --delete '"')
	db_rainloop_passwd=$(   cat "./config.json" | jq '.infra.db_rainloop_passwd' | tr --delete '"')
	ssh=$(   		cat "./config.json" | jq '.infra.ssh'		     | tr --delete '"')
	############ Variables email server
	description_mail=$(     cat "./config.json" | jq '.mail.description'         | tr --delete '"')
	ip_mail=$(              cat "./config.json" | jq '.mail.ip'                  | tr --delete '"')
	ip6_mail=$(             cat "./config.json" | jq '.mail.ip6'                 | tr --delete '"')
	sous_domaine_mail=$(    cat "./config.json" | jq '.mail.sous_domaine_mail'   | tr --delete '"')
	url_mail=$sous_domaine_mail"."$domaine
	mail_dh=$(              cat "./config.json" | jq '.mail.mail_dh'             | tr --delete '"')
	mail_cert=$(            cat "./config.json" | jq '.mail.mail_cert'           | tr --delete '"')
	mail_key=$(             cat "./config.json" | jq '.mail.mail_key'            | tr --delete '"')
	mail_chain=$(           cat "./config.json" | jq '.mail.mail_chain'          | tr --delete '"')
	mail_fullchain=$(       cat "./config.json" | jq '.mail.mail_fullchain'      | tr --delete '"')
	mail_csr=""
	doveadm_passwd=$(       cat "./config.json" | jq '.mail.doveadm_passwd'      | tr --delete '"')
	rspamd_passwd=$(        cat "./config.json" | jq '.mail.rspamd_passwd'       | tr --delete '"')
	rspamd_root_passwd=$(   cat "./config.json" | jq '.mail.rspamd_root_passwd'  | tr --delete '"')
	############ Variable web server
	description_web=$(      cat "./config.json" | jq '.web.description'          | tr --delete '"')
	ip_web=$(               cat "./config.json" | jq '.web.ip'                   | tr --delete '"')
	ip6_web=$(              cat "./config.json" | jq '.web.ip6'                  | tr --delete '"')
	sous_domaine_spam=$(    cat "./config.json" | jq '.web.sous_domaine_spam'    | tr --delete '"')
	url_spam=$sous_domaine_spam"."$domaine
	sous_domaine_webmail=$( cat "./config.json" | jq '.web.sous_domaine_webmail' | tr --delete '"')
	url_webmail=$sous_domaine_webmail"."$domaine
	sous_domaine_pfa=$(     cat "./config.json" | jq '.web.sous_domaine_pfa'     | tr --delete '"')
	url_postfixadmin=$sous_domaine_pfa"."$domaine
	web_pub_key=$(          cat "./config.json" | jq '.web.pub_key'              | tr --delete '"')
	web_dh=$(               cat "./config.json" | jq '.web.web_dh'               | tr --delete '"')
	pa_cert=$(              cat "./config.json" | jq '.web.pa_cert'              | tr --delete '"')
	pa_key=$(               cat "./config.json" | jq '.web.pa_key'               | tr --delete '"')
	pa_chain=$(             cat "./config.json" | jq '.web.pa_chain'             | tr --delete '"')
	pa_fullchain=$(         cat "./config.json" | jq '.web.pa_fullchain'         | tr --delete '"')
	pa_csr=""
	rl_cert=$(              cat "./config.json" | jq '.web.rl_cert'              | tr --delete '"')
	rl_key=$(               cat "./config.json" | jq '.web.rl_key'               | tr --delete '"')
	rl_chain=$(             cat "./config.json" | jq '.web.rl_chain'             | tr --delete '"')
	rl_fullchain=$(         cat "./config.json" | jq '.web.rl_fullchain'         | tr --delete '"')
	rl_csr=""
	spam_cert=$(            cat "./config.json" | jq '.web.spam_cert'            | tr --delete '"')
	spam_key=$(             cat "./config.json" | jq '.web.spam_key'             | tr --delete '"')
	spam_chain=$(           cat "./config.json" | jq '.web.spam_chain'           | tr --delete '"')
	spam_fullchain=$(       cat "./config.json" | jq '.web.spam_fullchain'       | tr --delete '"')
	spam_csr=""
}

##########################
### Fonctions supports

F_appconf() {
	####################### Remplace un paramètre dans un fichier - Args: $file, $parametre, $value, $option: -f = force
	#######################
	if [ "$4" == "-f" ]; then
		grep --quiet "^$2" "$1" && sed -i "s@^$2.*@$2 = $3@g" "$1" || echo "$2 = $3" >> "$1"
	else
		grep --quiet "^$2" "$1" && sed -i "s@^$2.*@$2 = $3@g" "$1"
	fi
}

F_uncomment() {
	####################### Décommente une ligne - Args: #$file, $line
	#######################
	sed -i "s@#$2.*@$2@g" "$1"
}

F_comment() {
	####################### Commente une ligne - Args: #$file, $line
	#######################
	sed -i "s@$2@#$2@g" "$1"
}

F_qax (){
	####################### Pose la question de lancer la fonction $2 avec l'invit $1
	#######################
	echo
	echo $1
	if [ "$debug" == "true" ]; then
		read -p "[y/n]" -n 1 -r
		if [ "$REPLY" == "y" ]
		then
			echo
			$2 $3 $4 $5 $6 $7 $8
		else
			echo
			echo "Module suivant"
		fi
	else
		$2 $3 $4 $5 $6 $7 $8 > /dev/null 2>&1
	fi
}

F_recreate_file (){
	####################### Si le fichier ou répertoire $1 existe: le supprime et le recrée vide
	#######################
	if [ -f "$1" ]; then
		rm --force "$1"
		touch "$1"
	else
		touch "$1"
	fi
}

F_recreate_folder (){
	####################### Si le fichier ou répertoire $1 existe: le supprime et le recrée vide
	#######################
	if [ -d "$1" ]; then
		rm --force --recursive "$1"
		mkdir --parents "$1"
	else
		mkdir --parents "$1"
	fi
}

### fin fonctions supports
##########################

F_system_init () {
	####################### Update du system et install des paquets nécessaires au démarrage du script
	#######################
	echo " * Mise à jour du système"
	# Installation silencieuse
	export DEBIAN_FRONTEND=noninteractive
	############ en attendant que Sebian nous pousse rspamd 2.4 dans le repo buster
	apt-get install -y lsb-release wget # optional
	CODENAME=`lsb_release -c -s`
	wget -O- https://rspamd.com/apt-stable/gpg.key | apt-key add -
	echo "deb [arch=amd64] http://rspamd.com/apt-stable/ $CODENAME main" > /etc/apt/sources.list.d/rspamd.list
	echo "deb-src [arch=amd64] http://rspamd.com/apt-stable/ $CODENAME main" >> /etc/apt/sources.list.d/rspamd.list
	############
	apt update
	apt upgrade -y 
	# jq permet de parser le fichier de config json
	[ "$(dpkg -s jq)" ] || apt install -y jq
	[ "$(dpkg -s build-essential)" ] || apt install -y build-essential
	# Augmente l'entropie pour la génération de .dh
	[ "$(dpkg -s haveged)" ] || apt install -y haveged
	apt-get purge -y --auto-remove rpcbind
}

F_vm_mail_init () {
	####################### Installation des paquets nécessaires à la VM mail
	#######################
	for paquet2install in $mail_paquets
	do
		echo "Check install $paquet2install ..."
		echo $(dpkg -s "$paquet2install")
		[ "$(dpkg -s $paquet2install)" ] || apt install -y "$paquet2install"
	done
}

F_vm_web_init () {
	####################### Installation des paquets nécessaires à la VM mail
	#######################
	for paquet2install in $webmail_paquets
	do
		echo "Check install $paquet2install ..."
		echo $(dpkg -s "$paquet2install")
		[ "$(dpkg -s $paquet2install)" ] || apt install -y "$paquet2install"
	done
}

F_mail_mariadb_config (){
	####################### Sécurisation de mariadb côté server
	#######################
	# Equivalent de mysql_secure_installation mais en manuel
	serverdbconf="/etc/mysql/mariadb.conf.d/50-server.cnf"
	cleanuser="DELETE FROM mysql.user WHERE User='';"
	cleanroot="DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
	cleantest="DROP DATABASE IF EXISTS test;DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
	flush="FLUSH PRIVILEGES;"
	conf_mdb_req=$cleanuser$cleanroot$cleantest$flush
	mariadb --execute "$conf_mdb_req"
	F_sql_cert_gen
	# Active l'accès a la db depuis l exterieur
	F_appconf "$serverdbconf" "bind-address" "0.0.0.0"
	# Met en place l'accès securisée à la db
	F_uncomment "$serverdbconf" "ssl-ca ="
	F_uncomment "$serverdbconf" "ssl-cert ="
	F_uncomment "$serverdbconf" "ssl-key ="
	F_appconf "$serverdbconf" "ssl-ca" " /etc/mysql/ssl/ca-cert.pem"
	F_appconf "$serverdbconf" "ssl-cert" "/etc/mysql/ssl/server-cert.pem"
	F_appconf "$serverdbconf" "ssl-key" "/etc/mysql/ssl/server-key.pem"
	echo $web_pub_key >> ~/.ssh/authorized_keys
	systemctl restart mariadb
}

F_mail_mariadb_init (){
	####################### Création de la db de la vm mail
	#######################
	create_p_db="CREATE DATABASE postfix;"
	create_rl_db="CREATE DATABASE rainloop;"
	create_pa_user="CREATE USER '$db_pa_user'@'$ip_web' IDENTIFIED BY '$db_pa_passwd' REQUIRE SSL;"
	grant_pa_user="GRANT ALL PRIVILEGES ON postfix.* TO '$db_pa_user'@'$ip_web';"
	create_rainloop_user="CREATE USER '$db_rainloop_user'@'$ip_web' IDENTIFIED BY '$db_rainloop_passwd' REQUIRE SSL;"
	grant_rainloop_user="GRANT ALL PRIVILEGES ON rainloop.* TO '$db_rainloop_user'@'$ip_web';"
	create_p_user="CREATE USER '$db_p_user'@'localhost' IDENTIFIED BY '$db_p_passwd';"
	grant_p_user="GRANT ALL PRIVILEGES ON postfix.* TO '$db_p_user'@'localhost';"
	flush="FLUSH PRIVILEGES;"
	init_mdb_req=$create_p_db$create_rl_db$create_pa_user$grant_pa_user$create_rainloop_user$grant_rainloop_user$create_p_user$grant_p_user$flush
	mariadb --execute "$init_mdb_req"
}

F_mail_fw (){
	####################### Configure le fw pour la VM mail
	#######################
	# smtp
	/sbin/iptables   -A INPUT  -m tcp -p tcp --dport 25                    -j ACCEPT
	/sbin/iptables   -A OUTPUT -m tcp -p tcp --dport 25                    -j ACCEPT
	# apache pour rspamd gui
	/sbin/iptables   -A INPUT  -m tcp -p tcp --dport 80   		       -j ACCEPT
	/sbin/iptables   -A OUTPUT -m tcp -p tcp --dport 80   		       -j ACCEPT
	# smtpd
	/sbin/iptables   -A INPUT  -m tcp -p tcp --dport 143                   -j ACCEPT
	# imap
	/sbin/iptables   -A INPUT  -m tcp -p tcp --dport 587                   -j ACCEPT
	# mariadb
	/sbin/iptables   -A INPUT  -m tcp -p tcp --dport 3306  -s "$ip_web"    -j ACCEPT
	# sieve
	/sbin/iptables   -A INPUT  -m tcp -p tcp --dport 4190                  -j ACCEPT
	# api dovecot
	#/sbin/iptables  -A INPUT  -m tcp -p tcp --dport 8080                  -j ACCEPT
	# rspamd
	/sbin/iptables   -A INPUT  -m tcp -p tcp --dport 11334                  -j ACCEPT
	/sbin/iptables   -A INPUT  -m udp -p udp --dport 11335                  -j ACCEPT
	# save
	iptables-save -f /etc/iptables/rules.v4
}

F_web_fw (){
	####################### Configure le fw pour la VM web
	#######################
	# ssh out pour accéder à la vm mail
	/sbin/iptables   -A OUTPUT  -p tcp        --dport $ssh""		-j ACCEPT
	# postfixadmin
	/sbin/iptables   -A OUTPUT  -m tcp -p tcp --dport 25                    -j ACCEPT
	# imap
	/sbin/iptables   -A OUTPUT  -m tcp -p tcp --dport 587                   -j ACCEPT
	# smtpd
	/sbin/iptables   -A OUTPUT  -m tcp -p tcp --dport 143                   -j ACCEPT
	# sieve
	/sbin/iptables   -A OUTPUT  -m tcp -p tcp --dport 4190 			-j ACCEPT
	# mariadb
	/sbin/iptables   -A OUTPUT  -p tcp        --dport 3306                  -j ACCEPT
	/sbin/iptables-save -f /etc/iptables/rules.v4
}

F_dh_init () {
	####################### Crée le fichier .dh
	#######################
	openssl dhparam -5 -rand /dev/urandom -check -out "$1" 4096
}

F_build_key_scenario() {
	####################### Définition des scenarii de chiffrements
	#######################
	# cas 1: clefs à générer + certificat LE
	# cas 2: clefs à générer sans LE - autosign
	# cas 3: clefs + certificat renseignés dans config.js
	# cas 4: clefs renseignés dans config.js pas de cerficat LE - autosign
	# CAS 1 & 3 => CA LE | CAS 2 & 4 => self-signed
	# $1 = key $2 = cert $3 = chain $4 = url $5 = dh
	key="$1"
	cert="$2"
	chain="$3"
	url="$4"
	dh="$5"
	fullchain="$6"
	# Check si dh présent sinon création
	if [ ! -f "$dh" ]; then F_qax "Aucun fichier dh détecté - Création du fichier. ATTENTION: Peut prendre du temps" F_dh_init "$dh"; fi
	# Check si le chemin de $key et $cert pointent sur des fichiers présents dans la VM
	if [ ! -f "$key" ] || [ ! -f "$cert" ]; then
		# s'il n'existe pas, les chemins sont donc des repertoires à créer pour générer clefs et certifs
		# nous sommes donc dans les ca 1 ou 2
		if [ "${cert: -1}" != "/" ]; then cert="$cert/"; fi
		if [ ! -d "$cert" ]; then mkdir -p "$cert"; fi
		if [ "${key: -1}" != "/" ]; then key="$key/"; fi
		if [ ! -d "$key" ]; then mkdir -p "$key"; fi
		# Si LE: scenario 1
		if [ "$le_sign" == "Y" ]; then
			cert_scenario=1
			if [ "${chain: -1}" != "/" ]; then chain="$chain/"; fi
			if [ ! -d "$chain" ]; then mkdir -p "$chain"; fi
			if [ "${fullchain: -1}" != "/" ]; then fullchain="$fullchain/"; fi
			if [ ! -d "$fullchain" ]; then mkdir -p "$fullchain"; fi
			csr="$cert$url.csr"
			chain=$cert$url"_chain.pem"
			fullchain=$cert$url"_fullchain.pem"
		else
		# Pas de LE donc scenario2
			cert_scenario=2
		fi
		cert=$cert$url".crt"
		key=$key$url".pem"
	else
		# $key et $cert pointent sur des fichiers présents dans la VM
		# Si certificat signé par LE (ou autre CA): scenario 3
		if [ -f "$chain" ]; then
			cert_scenario=3
			# Génère un full chain
			if [ ! -f "$fullchain" ]; then
				fullchain="${chain/"chain"/"fullchain"}"
				cat "$cert" >> "$fullchain"
				cat "$chain" >> "$fullchain"
			fi
		else
		# Si certificat non signé: scenario 4
			cert_scenario=4
		fi
	fi
	if [ "$debug" == "true" ]; then echo "Scenario de certificats: $cert_scenario"; fi
	if [ "$4" == "$url_postfixadmin" ]; then pa_key="$key" pa_cert="$cert" pa_cert_scenario="$cert_scenario" pa_csr="$csr" pa_chain="$chain" pa_fullchain="$fullchain"; fi
	if [ "$4" == "$url_webmail" ]; then rl_key="$key" rl_cert="$cert" rl_cert_scenario="$cert_scenario" rl_csr="$csr" rl_chain="$chain" rl_fullchain="$fullchain"; fi
	if [ "$4" == "$url_spam" ]; then spam_key="$key" spam_cert="$cert" spam_cert_scenario="$cert_scenario" spam_csr="$csr" spam_chain="$chain" spam_fullchain="$fullchain";  fi
	if [ "$4" == "$url_mail" ]; then mail_key="$key" mail_cert="$cert" mail_cert_scenario="$cert_scenario" mail_csr="$csr" mail_chain="$chain" mail_fullchain="$fullchain"; fi
	if [ "$cert_scenario" == "1"  ] || [ "$cert_scenario" == "2" ]; then
		F_qax "Création clef/certif pour le serveur email" F_gen_key "$4" "$cert_scenario"
	fi
}

F_gen_key() {
	####################### Génère les clefs [scenario 1 ou 2]
	#######################
	if [ "$1" == "$url_postfixadmin" ]; then key="$pa_key" cert="$pa_cert" scenario="$pa_cert_scenario"; fi
	if [ "$1" == "$url_webmail" ]; then key="$rl_key" cert="$rl_cert" scenario="$rl_cert_scenario"; fi
	if [ "$1" == "$url_spam" ]; then key="$spam_key" cert="$spam_cert" scenario="$spam_cert_scenario"; fi
	if [ "$1" == "$url_mail" ]; then key="$mail_key" cert="$mail_cert" scenario="$mail_cert_scenario"; fi
	openssl ecparam -genkey -rand /dev/urandom -name secp384r1 | openssl ec -no_public -out "$key"
	# Si scenario 1: on fait signer la clef par LE sinon autosign
	if [ "$2" == "1" ]
	then
		F_cert_LE "$1"
	else
		openssl req -x509 -nodes -days 1095 -key "$key" -out "$cert" -subj "/C=WW/ST=WW/L=WW/O=$1/OU=$1/CN=$1"
	fi
} 

F_cert_LE () {
	####################### Signe le certificat [scenario 1]
	#######################
	[ "$(dpkg -s certbot)" ] || apt install -y certbot
	if [ "$1" == "$url_postfixadmin" ]; then key="$pa_key" cert="$pa_cert" csr="$pa_csr" chain="$pa_chain" fullchain="$pa_fullchain"; fi
	if [ "$1" == "$url_webmail" ]; then key="$rl_key" cert="$rl_cert" csr="$rl_csr" chain="$rl_chain" fullchain="$rl_fullchain"; fi
	if [ "$1" == "$url_spam" ]; then key="$spam_key" cert="$spam_cert" csr="$spam_csr" chain="$spam_chain" fullchain="$spam_fullchain"; fi
	if [ "$1" == "$url_mail" ]; then key="$mail_key" cert="$mail_cert" csr="$mail_csr" chain="$mail_chain" fullchain="$mail_fullchain"; fi
	openssl ecparam -genkey -rand /dev/urandom -name secp384r1 | openssl ec -no_public -out "$key"
	openssl req -new -sha512 -rand /dev/urandom -key "$key" -out "$csr" -subj "/C=WW/ST=WW/L=WW/O=$1/OU=$1/CN=$1"
	F_recreate_folder "/var/lib/letsencrypt/$1/"
	if [ $testLE == "true" ]; then	
		certbot certonly --test-cert --standalone --domain "$1" --csr "$csr" --cert-name "$1" --must-staple --agree-tos --register-unsafely-without-email --cert-path "/var/lib/letsencrypt/$1/$1".crt --fullchain-path "/var/lib/letsencrypt/$1/$1_fullchain".pem --chain-path "/var/lib/letsencrypt/$1/$1_chain".pem --work-dir "/var/lib/letsencrypt/"
	else
		echo 
		echo $csr
		echo
		certbot certonly --standalone --domain "$1" --csr "$csr" --cert-name "$1" --must-staple --agree-tos --register-unsafely-without-email --cert-path "/var/lib/letsencrypt/$1/$1".crt --fullchain-path "/var/lib/letsencrypt/$1/$1_fullchain".pem --chain-path "/var/lib/letsencrypt/$1/$1_chain".pem --work-dir "/var/lib/letsencrypt/"
	fi
	ln --symbolic "/var/lib/letsencrypt/$1/$1.crt" "$cert"
	ln --symbolic "/var/lib/letsencrypt/$1/$1_chain.pem" "$chain"
	ln --symbolic "/var/lib/letsencrypt/$1/$1_fullchain.pem" "$fullchain"
	# Gestion des renew LE
	if [ "$1" != "$url_mail" ]; then
		[[ -d "/etc/letsencrypt/renewal-hooks/post" ]] || mkdir -p /etc/letsencrypt/renewal-hooks/post
		echo -e '#!/bin/bash\n\n/usr/bin/systemctl restart apache2.service\n' > /etc/letsencrypt/renewal-hooks/post/restart-apache2.sh
		echo -e "SHELL=/bin/bash\n#0 0,12 * * * /usr/bin/sleep \$((RANDOM\\%3600)) && certbot renew -q --non-interactive --webroot --reuse-key --post-hook /etc/letsencrypt/renewal-hooks/post/restart-apache2.sh" >> cronTMP
	else
		echo -e "SHELL=/bin/bash\n#0 0,12 * * * /usr/bin/sleep \$((RANDOM\\%3600)) && certbot renew -q --non-interactive --webroot --reuse-key" >> cronTMP

	fi
	crontab cronTMP && rm --force cronTMP
}

F_sql_cert_gen (){
	####################### Génère des clefs pour sécuriser la communication à la db 
	#######################
	sslsql="/etc/mysql/ssl/"
	mkdir --parents $sslsql
	if [ ! -f  "$sslsql"ca-cert.pem ] && [ ! -f "$sslsql"server-key.pem ] && [ ! -f "$sslsql"server-cert.pem ]; then
		##### server side
		openssl genrsa 4096 > "$sslsql"ca-key.pem
		openssl req -new -x509 -nodes -days 365000 -key "$sslsql"ca-key.pem -out "$sslsql"ca-cert.pem -subj "/C=WW/ST=WW/L=WW/O=/OU=/CN=adminDB"
		openssl req -newkey rsa:2048 -days 365000 -nodes -keyout "$sslsql"server-key.pem -out "$sslsql"server-req.pem -subj "/C=WW/ST=WW/L=WW/O=/OU=/CN=$ip_mail"
		openssl rsa -in "$sslsql"server-key.pem -out "$sslsql"server-key.pem
		openssl x509 -req -in "$sslsql"server-req.pem -days 365000 -CA "$sslsql"ca-cert.pem -CAkey "$sslsql"ca-key.pem -set_serial 01 -out "$sslsql"server-cert.pem
		##### client side
		openssl req -newkey rsa:2048 -days 365000 -nodes -keyout "$sslsql"client-key.pem -out "$sslsql"client-req.pem -subj "/C=WW/ST=WW/L=WW/O=/OU=/CN=$ip_web"
		openssl rsa -in "$sslsql"client-key.pem -out "$sslsql"client-key.pem
		openssl x509 -req -in "$sslsql"client-req.pem -days 365000 -CA "$sslsql"ca-cert.pem -CAkey "$sslsql"ca-key.pem -set_serial 01 -out "$sslsql"client-cert.pem
		chown mysql:root /etc/mysql/ssl/*
		chmod 644 /etc/mysql/ssl/client-key.pem
	else
		echo
		echo "Certificats mariadb présents"
	fi
}

F_sql_secure() {
	####################### Sécurise la connexion à la db côté client
	#######################
	sqlsslfolder="/etc/ssl/sql_client"
	clientdbconf="/etc/mysql/mariadb.conf.d/50-client.cnf"
	F_uncomment "$clientdbconf" " ssl-cert="
	F_uncomment "$clientdbconf" " ssl-key="
	F_appconf "$clientdbconf" " ssl-cert" "/etc/ssl/sql_client/client-cert.pem"
	F_appconf "$clientdbconf" " ssl-key" "/etc/ssl/sql_client/client-key.pem\n ssl-ca = /etc/ssl/sql_client/ca-cert.pem "
	F_recreate_folder "$sqlsslfolder"
	scp -P $ssh -o "StrictHostKeyChecking no" $ip_mail:/etc/mysql/ssl/client-key.pem $sqlsslfolder
	scp -P $ssh -o "StrictHostKeyChecking no" $ip_mail:/etc/mysql/ssl/client-cert.pem $sqlsslfolder
	scp -P $ssh -o "StrictHostKeyChecking no" $ip_mail:/etc/mysql/ssl/ca-cert.pem $sqlsslfolder
}

F_mail_postfix() {
	####################### Configuration de postfix
	#######################
	############ main.cf
	##### Configuration globale
	postconf -e "myhostname = $email"
	postconf -e "mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128"
	postconf -e "mydestination = localhost.$domaine, localhost"
	postconf -e "disable_vrfy_command = yes"
	postconf -e "message_size_limit = 20240000"
	postconf -e "tls_random_source = dev:/dev/urandom"
	#### SMTP global
	postconf -e "smtp_tls_loglevel = 1"
	#### SMTP Niveau de sécurité
	postconf -e "smtp_tls_session_cache_database = btree:${data_directory}/smtpd_scache")
	postconf -e "smtp_tls_auth_only = yes"
	postconf -e "smtp_tls_security_level = may"
	postconf -e "smtp_tls_protocols = TLSv1.3, TLSv1.2, TLSv1.1, !TLSv1, !SSLv2, !SSLv3"
	postconf -e "smtp_tls_ciphers = high"
	postconf -e "smtp_tls_mandatory_ciphers = high"
	postconf -e "smtp_tls_mandatory_protocols = TLSv1.3, TLSv1.2, !SSLv2, !SSLv3, !TLSv1, !TLSv1.1"
	#### SMTPD global
	postconf -e "smtpd_tls_loglevel = 1"
	postconf -e "recipient_delimiter = +"
	#### SMTPD Confie l auth a dovecot
	postconf -e "smtpd_sasl_type = dovecot"
	postconf -e "smtpd_sasl_path = private/auth"
	postconf -e "smtpd_sasl_auth_enable = yes"
	postconf -e "smtpd_sasl_local_domain = \$mydomain"
	postconf -e "broken_sasl_auth_clients = yes"
	#### SMTPD Niveau de sécurité
	postconf -e "smtpd_tls_auth_only = yes"
	postconf -e "smtpd_tls_security_level = may"
	postconf -e "smtpd_tls_protocols = TLSv1.3, TLSv1.2, TLSv1.1, !TLSv1, !SSLv2, !SSLv3"
	postconf -e "smtpd_tls_ciphers = high"
	postconf -e "smtpd_tls_mandatory_ciphers = high"
	postconf -e "smtpd_tls_exclude_ciphers = MD5, DES, ADH, RC4, PSD, SRP, 3DES, eNULL, aNULL"
	postconf -e "smtpd_tls_mandatory_protocols = TLSv1.3, TLSv1.2, !SSLv2, !SSLv3, !TLSv1, !TLSv1.1"
	postconf -e "smtpd_tls_received_header = yes"
	#### Autre config de sécurité
	postconf -e "tls_eecdh_strong_curve = secp384r1"
	postconf -e "tls_ssl_options = NO_COMPRESSION"
	#### SMTPD Mise en place des clefs et certificats
	if [ "$mail_cert_scenario" == "1" ] || [ "$mail_cert_scenario" == "3" ]; then
		postconf -e "smtpd_tls_cert_file = $mail_fullchain"
	else
		postconf -e "smtpd_tls_cert_file = $mail_cert"
	fi
	postconf -e "smtpd_tls_key_file = $mail_key"
	postconf -e "smtpd_tls_dh1024_param_file = $mail_dh"
	#### Cipher list 
	postconf -e "tls_preempt_cipherlist = yes"
	postconf -e "tls_high_cipherlist = ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!DSS:!RC4:!SEED:!SHA1"
	#### Activer config virtuelles
	postconf -e "virtual_mailbox_domains = mysql:/etc/postfix/mysql-virtual-mailbox-domains.cf"
	postconf -e "virtual_mailbox_maps = mysql:/etc/postfix/mysql-virtual-mailbox-maps.cf"
	postconf -e "virtual_alias_maps = mysql:/etc/postfix/mysql-virtual-alias-maps.cf"
	postconf -e "relay_domains = proxy:mysql:/etc/postfix/mysql_relay_domains_maps.cf"
	postconf -e "virtual_transport = lmtp:unix:private/dovecot-lmtp"
	#### Configuration des restriction
	# ALL COMMAND
	postconf -e "smtpd_client_restrictions = permit_mynetworks, permit_sasl_authenticated, reject_unknown_reverse_client_hostname, reject_unauth_pipelining"
	# HELO
	postconf -e "smtpd_helo_restrictions = permit_mynetworks, permit_sasl_authenticated, reject_invalid_helo_hostname, reject_non_fqdn_helo_hostname, reject_unauth_pipelining"
	# MAIL FROM
	postconf -e "smtpd_sender_restrictions = permit_mynetworks, permit_sasl_authenticated, reject_non_fqdn_sender,reject_unknown_sender_domain, reject_unauth_pipelining"
	# RCPT TO
	postconf -e "smtpd_relay_restrictions =  permit_mynetworks, permit_sasl_authenticated, reject_unauth_destination"
	postconf -e "smtpd_recipient_restrictions = permit_mynetworks, permit_sasl_authenticated, reject_non_fqdn_recipient, reject_unauth_destination, reject_unknown_recipient_domain, reject_unauth_pipelining"
	# DATA
	postconf -e "smtpd_data_restrictions = permit_mynetworks, permit_sasl_authenticated, reject_multi_recipient_bounce, reject_unauth_pipelining"
	postconf -e "strict_rfc821_envelopes = yes"
	#### Configuration de postscreen
	postconf -e "postscreen_access_list = permit_mynetworks, cidr:/etc/postfix/postscreen_access.cidr"
	postconf -e "postscreen_blacklist_action = drop"
	postconf -e "postscreen_dnsbl_sites = zen.spamhaus.org*2, bl.spameatingmonkey.net, bl.spamcop.net"
	postconf -e "postscreen_dnsbl_threshold = 3"
	postconf -e "postscreen_dnsbl_action = drop"
	postconf -e "postscreen_greet_wait = 3s"
	postconf -e "maximal_queue_lifetime = 21d"
	postconf -e "postscreen_greet_banner = wait, wait, wait !"
	postconf -e "postscreen_greet_action = enforce"
	postconf -e "postscreen_pipelining_enable = yes"
	postconf -e "postscreen_pipelining_action = enforce"
	postconf -e "postscreen_non_smtp_command_enable = yes"
	postconf -e "postscreen_non_smtp_command_action = enforce"
	postconf -e "postscreen_bare_newline_enable = yes"
	postconf -e "postscreen_bare_newline_action = enforce"
	cp ./postfix/postscreen_access.cidr /etc/postfix/
	#### Clean header: possibilité de clean tous les headers des emails: non activé sur infra fdn
	cleanheader="/etc/postfix/header_checks"
	if [ -f "$cleanheader" ]; then rm -f "$cleanheader"; fi
	touch "$cleanheader"
	echo "/^Received:/            IGNORE" >> "$cleanheader"
	echo "/^X-Originating-IP:/    IGNORE" >> "$cleanheader"
	echo "/^X-Mailer:/            IGNORE" >> "$cleanheader"
	echo "/^User-Agent:/          IGNORE" >> "$cleanheader"
	echo "/Message-Id:\s+<(.*?)@.*?>/ REPLACE Message-Id: <\$1@"$email">" >> "$cleanheader"
	postconf -e "header_checks = regexp:$cleanheader"
	postconf -e "mime_header_checks = regexp:$cleanheader"
	#### Configuration rspamd
	postconf -e "milter_protocol = 6"
	postconf -e "milter_default_action = accept"
	postconf -e "smtpd_milters = inet:localhost:11332"
	postconf -e "non_smtpd_milters = inet:localhost:11332"
	postconf -e "milter_mail_macros = i {mail_addr} {client_addr} {client_name} {auth_authen}"
	#### Initialisation des accès à la base SQL
	F_recreate_file "/etc/postfix/mysql-virtual-mailbox-domains.cf"
	echo -e "user = $db_p_user\npassword = $db_p_passwd\nhosts = 127.0.0.1\ndbname = postfix\nquery = SELECT 1 FROM domain WHERE domain='%s' AND backupmx = '0' AND active = '1'" >> /etc/postfix/mysql-virtual-mailbox-domains.cf
	F_recreate_file "/etc/postfix/mysql-virtual-mailbox-maps.cf"
	echo -e "user = $db_p_user\npassword = $db_p_passwd\nhosts = 127.0.0.1\ndbname = postfix\nquery = SELECT 1 FROM mailbox WHERE username='%s'" >> /etc/postfix/mysql-virtual-mailbox-maps.cf
	F_recreate_file "/etc/postfix/mysql-virtual-alias-maps.cf"
	echo -e "user = $db_p_user\npassword = $db_p_passwd\nhosts = 127.0.0.1\ndbname = postfix\nquery = SELECT goto FROM alias WHERE address='%s'" >> /etc/postfix/mysql-virtual-alias-maps.cf
	F_recreate_file "/etc/postfix/mysql_relay_domains_maps.cf"
	echo -e "user = $db_p_user\npassword = $db_p_passwd\nhosts = 127.0.0.1\ndbname = postfix\nquery = SELECT domain FROM domain WHERE domain='%s' AND backupmx ='1'" >> /etc/postfix/mysql-virtual-alias-maps.cf chgrp postfix /etc/postfix/mysql-*.cf
	chmod 640 /etc/postfix/mysql-*.cf
	############ saslauthd
	sed -i "s@^START=.*@START=yes@g" "/etc/default/saslauthd"
	############ master.cf
	postconf -M "submission/inet=submission   inet   n   -   -   -   -   smtpd"
	postconf -P "submission/inet/syslog_name=postfix/submission"
	postconf -P "submission/inet/smtpd_tls_security_level=encrypt"
	postconf -P "submission/inet/smtpd_proxy_options=speed_adjust"
	postconf -P "submission/inet/smtpd_enforce_tls=yes"
	postconf -P "submission/inet/smtpd_tls_auth_only=yes"
	postconf -P "submission/inet/smtpd_tls_mandatory_ciphers=high"
	postconf -P "submission/inet/smtpd_client_restrictions=permit_mynetworks,permit_sasl_authenticated,reject"
	postconf -M "smtp/inet=smtp  inet   n   -   y   -   1   postscreen"
	postconf -P "smtp/inet/strict_rfc821_envelopes=yes"
	postconf -P "smtp/inet/smtpd_proxy_options=speed_adjust"
	postconf -P "smtp/inet/smtpd_sasl_auth_enable=no"
	postconf -M "smtpd/pass=smtpd pass   -   -   y   -   -   smtpd"
	postconf -M "dnsblog/unix=dnsblog  unix   -   -   y   -   0   dnsblog"
	postconf -M "tlsproxi/unix=tlsproxy unix   -   -   y   -   0   tlsproxy"
	############ ENV
	#### création du user et group qui sera utilisé par postfix
	groupadd --gid 5000 vmail
	useradd --gid vmail --uid 5000 --shell /usr/sbin/nologin --home-dir /var/mail/vmail --create-home vmail
	systemctl restart postfix
}

F_mail_dovecot() {
	####################### Configuration de dovecot
	#######################
	############ dovecot.conf - password pour monitoring
	dovecotconf="/etc/dovecot/dovecot.conf"
	F_appconf "$dovecotconf" "doveadm_password" "$doveadm_passwd" -f
	############ dovecot-sql.conf - donnc les accès sql à dovecot
	dovecotsqlconf="/etc/dovecot/dovecot-sql.conf.ext"
	F_recreate_file "$dovecotsqlconf"
	echo -e "driver = mysql" >> "$dovecotsqlconf"
	echo -e "connect = host=127.0.0.1 dbname=postfix user=$db_p_user password=$db_p_passwd" >> "$dovecotsqlconf"
	echo -e "iterate_query = SELECT username AS user FROM mailbox" >> "$dovecotsqlconf"
	echo -e "default_pass_scheme = SHA512-CRYPT" >> "$dovecotsqlconf"
	echo -e "user_query = SELECT CONCAT('/var/mail/vmail/',maildir) as home, CONCAT('maildir:/var/mail/vmail/',maildir) as mail, CONCAT('*:bytes=', IF(mailbox.quota = 0, domain.maxquota*1024000, mailbox.quota)) as quota_rule FROM mailbox, domain WHERE username = '%u' AND mailbox.active = '1' AND domain.domain = '%d' AND domain.active = '1'"  >> "$dovecotsqlconf"
	echo -e "password_query = SELECT username as user, password, CONCAT('/var/mail/vmail/',maildir) AS userdb_home, CONCAT('maildir:/var/mail/vmail/',maildir) AS userdb_mail FROM mailbox WHERE username = '%u' AND active = '1'" >> "$dovecotsqlconf"
	############ dovecot-dict-sql-users.conf - conf pour les quota users
	dovecotdictsqluserconf="/etc/dovecot/dovecot-dict-sql-users.conf.ext"
	F_recreate_file "$dovecotdictsqluserconf"
	echo -e "connect = host=127.0.0.1 dbname=postfix user=$db_p_user password=$db_p_passwd" >> "$dovecotdictsqluserconf"
	echo -e "map {\npattern = priv/quota/storage\ntable = quota2\nusername_field = username\nvalue_field = bytes\n}" >> "$dovecotdictsqluserconf"
	echo -e "map {\npattern = priv/quota/messages\ntable = quota2\nusername_field = username\nvalue_field = messages\n}" >> "$dovecotdictsqluserconf"
	############ auth-sql.conf.ext - configure le lien entre la methode d'authentification de 10-auth.conf et le paramétrage sql de dovecot-sql.conf
	authsqlconfext="/etc/dovecot/conf.d/auth-sql.conf.ext"
	if [ -f "$authsqlconfext" ]; then rm --force "$authsqlconfext"; fi
	touch "$authsqlconfext"
	echo -e "passdb {\ndriver = sql\nargs = /etc/dovecot/dovecot-sql.conf.ext\n}" >> "$authsqlconfext"
	echo -e "userdb {\ndriver = sql\nargs = /etc/dovecot/dovecot-sql.conf.ext\n}" >> "$authsqlconfext"
	############ 10-auth.conf - configure l'authentification dovecot
	authconf="/etc/dovecot/conf.d/10-auth.conf"
	F_appconf "$authconf" "auth_mechanisms" "plain login" -f
	F_uncomment "$authconf" "disable_plaintext_auth = no"
	F_appconf "$authconf" "disable_plaintext_auth" "yes" -f
	F_uncomment "$authconf" "!include auth-sql.conf.ext"
	F_comment "$authconf" "!include auth-system.conf.ext" 
	############ 10-mail.conf
	mailconf="/etc/dovecot/conf.d/10-mail.conf"
	F_uncomment "$mailconf" "mail_plugins ="
	F_appconf "$mailconf" "mail_plugins" "quota virtual" -f
	F_uncomment "$mailconf" "mail_uid ="
	F_appconf "$mailconf" "mail_uid" "vmail" -f
	F_uncomment "$mailconf" "mail_gid ="
	F_appconf "$mailconf" "mail_gid" "vmail" -f
	F_uncomment "$mailconf" "first_valid_uid = 500"
	F_appconf "$mailconf" "first_valid_uid" "5000" -f
	F_uncomment "$mailconf" "last_valid_uid = 0"
	F_appconf "$mailconf" "last_valid_uid" "5000" -f
	############ auth-sql.conf.ext - configure le lien entre la methode d'authentification de 10-auth.conf et le paramétrage sql de dovecot-sql.conf
	authsqlconfext="/etc/dovecot/conf.d/auth-sql.conf.ext"
	F_recreate_file "$authsqlconfext"
	echo -e "passdb {\ndriver = sql\nargs = /etc/dovecot/dovecot-sql.conf.ext\n}" >> "$authsqlconfext"
	echo -e "userdb {\ndriver = sql\nargs = /etc/dovecot/dovecot-sql.conf.ext\n}" >> "$authsqlconfext"
	############ 10-master.conf - autorise Postfix à se connecter à Dovecot via LMTP
	masterconf="/etc/dovecot/conf.d/10-master.conf"
	F_recreate_file "$masterconf"
	echo -e "service lmtp {\nunix_listener /var/spool/postfix/private/dovecot-lmtp {\nmode = 0600\nuser = postfix\ngroup = postfix\n}\n}" >> "$masterconf"
	echo -e "service auth {\nunix_listener auth-userdb {\nmode = 0600\nuser = vmail\ngroup = vmail\n}\nunix_listener /var/spool/postfix/private/auth {\nmode = 0660\nuser = postfix\ngroup = postfix\n}\nuser = dovecot\n}" >> "$masterconf"
	echo -e "service auth-worker {\nuser = vmail\n}" >> "$masterconf"
	echo -e "service stats {\nunix_listener stats-reader {\nuser = vmail\ngroup = vmail\nmode = 0660\n}\nunix_listener stats-writer {\nuser = vmail\ngroup = vmail\nmode = 0660\n}\n}" >> "$masterconf"
	echo -e "service dict {\nunix_listener dict {\nmode = 0660\nuser = vmail\ngroup = vmail\n}\n}" >> "$masterconf"
	echo -e "service imap-login {\ninet_listener imap {\nport = 143\n}\nservice_count = 0\n}" >> "$masterconf"
	echo -e "service doveadm {\nunix_listener doveadm-server {\nuser = vmail\n}\ninet_listener http {\nport = 8080\nssl = yes\n}\n}"  >> "$masterconf"
	echo -e "service stats {\nunix_listener stats-reader {\ngroup = dovecot\nmode = 0660\n}\nunix_listener stats-writer {\ngroup = dovecot\nmode = 0666\n}\n}" >> "$masterconf"
	############ 10-ssl.conf - configuration des clefs
	sslconf="/etc/dovecot/conf.d/10-ssl.conf"
	F_appconf "$sslconf" "ssl_key" "<$mail_key" -f
	if [ "$mail_cert_scenario" == "1" ] || [ "$mail_cert_scenario" == "3" ]; then
		F_appconf "$sslconf" "ssl_cert" "<$mail_fullchain" -f
	else
		F_appconf "$sslconf" "ssl_cert" "<$mail_cert" -f
	fi
	F_appconf "$sslconf" "ssl_dh" "<$mail_dh" -f
	F_appconf "$sslconf" "ssl_cipher_list" "ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-RSA-AES256-GCM-SHA384" -f
	F_appconf "$sslconf" "ssl_prefer_server_ciphers" "yes" -f
	F_appconf "$sslconf" "ssl_min_protocol" "TLSv1.2" -f
	############ 15-mailboxes.conf - gestion des repertoires
	mbconf="/etc/dovecot/conf.d/15-mailboxes.conf"
	F_recreate_file "$mbconf"
	echo -e "namespace inbox {" >> "$mbconf"
	echo -e "location = maildir:/var/mail/vmail/%d/%n/" >> "$mbconf"
	echo -e "inbox = yes" >> "$mbconf"
	echo -e "separator = /" >> "$mbconf"
	echo -e "subscriptions = yes" >> "$mbconf"
	echo -e "mailbox Drafts {\nauto = subscribe\nspecial_use = \\Drafts\n}" >> "$mbconf"
	echo -e "mailbox Junk {\nauto = subscribe\nspecial_use = \\Junk\n}" >> "$mbconf"
	echo -e "mailbox Trash {\nauto = subscribe\nspecial_use = \\Trash\n}" >> "$mbconf"
	echo -e "mailbox Sent {\nauto = subscribe\nspecial_use = \\Sent\n}" >> "$mbconf"
	echo -e "mailbox Archive {\nauto = subscribe\nspecial_use = \\Archive\n}" >> "$mbconf"
	echo -e "}" >> "$mbconf"
	############ 20-imap.conf - le quota des boites mails
	imapconf="/etc/dovecot/conf.d/20-imap.conf"
	F_recreate_file "$imapconf"
	echo -e "protocol imap {\nmail_plugins = \$mail_plugins imap_quota imap_sieve\n}" >> "$imapconf"
	############ 20-lmtp.conf - active sieve
	lmtpconf="/etc/dovecot/conf.d/20-lmtp.conf"
	F_recreate_file "$lmtpconf"
	echo -e "protocol lmtp {\npostmaster_address = postmaster@$email\nmail_plugins = \$mail_plugins quota sieve\n}" >> "$lmtpconf"
	############ 90-quota.conf - parametrage des quotas
	quotaconf="/etc/dovecot/conf.d/90-quota.conf"
	F_recreate_file "$quotaconf"
	echo -e "plugin {\nquota = dict:User quota::proxy::sqluserquota\nquota_rule = *:storage=5GB\nquota_rule2 = Trash:storage=+100M\nquota_grace = 10%%\nquota_exceeded_message = Quota exceeded, please contact vlp.\n}" >> "$quotaconf"
	echo -e "plugin {\nquota_warning = storage=100%% quota-warning 100 %u\nquota_warning2 = storage=95%% quota-warning 95 %u\nquota_warning3 = storage=90%% quota-warning 90 %u\nquota_warning4 = storage=85%% quota-warning 85 %u\n}" >> "$quotaconf"
	echo -e "service quota-warning {\nexecutable = script /usr/local/bin/quota-warning.sh\nuser = vmail\nunix_listener quota-warning {\ngroup = vmail\nmode = 0660\nuser = vmail\n}\n}" >> "$quotaconf"
	echo -e "dict {\nsqluserquota = mysql:/etc/dovecot/dovecot-dict-sql-users.conf.ext\n}" >> "$quotaconf"
	############ 20-managesieve.conf - parametrage de sieve
	managesieveconf="/etc/dovecot/conf.d/20-managesieve.conf"
	F_recreate_file "managesieveconf"
	echo -e "service managesieve-login {\ninet_listener sieve {\nport = 4190\n}\n}\nservice managesieve {\nprocess_limit = 1024\n}" >> $managesieveconf
	############ 90-sieve.conf - parametrage de sieve
	sieveconf="/etc/dovecot/conf.d/90-sieve.conf"
	F_recreate_file "$sieveconf"
	echo -e "plugin {" >> $sieveconf
	echo -e "sieve_plugins = sieve_imapsieve sieve_extprograms\nsieve_before = /var/mail/vmail/sieve/global/spam-global.sieve\nsieve = file:/var/mail/vmail/sieve/%d/%n/scripts;active=/var/mail/vmail/sieve/%d/%n/active-script.sieve" >> $sieveconf
	echo -e "sieve_dir = /var/mail/vmail/sieve" >> $sieveconf
	echo -e "sieve_global_dir = /var/mail/vmail/sieve/global" >> $sieveconf
	echo -e "imapsieve_mailbox1_name = Junk\nimapsieve_mailbox1_causes = COPY\nimapsieve_mailbox1_before = file:/var/mail/vmail/sieve/global/report-spam.sieve" >> $sieveconf
	echo -e "imapsieve_mailbox2_name = *\nimapsieve_mailbox2_from = Junk\nimapsieve_mailbox2_causes = COPY\nimapsieve_mailbox2_before = file:/var/mail/vmail/sieve/global/report-ham.sieve" >> $sieveconf
	echo -e "sieve_pipe_bin_dir = /var/mail/vmail/sieve/global\nsieve_global_extensions = +vnd.dovecot.pipe +vnd.dovecot.environment" >> $sieveconf
	echo -e "}" >> $sieveconf
	systemctl restart dovecot
	############ ENV
	if [ -f /usr/share/dovecot/protocols.d/pop3d.protocol ]; then rm --force /usr/share/dovecot/protocols.d/pop3d.protocol; fi
	cp ./scripts/quota-warning.sh /usr/local/bin/
	chown root:root /etc/dovecot/dovecot-sql.conf.ext
	mkdir -p /var/mail/vmail/sieve/global
	cp ./sieve/* /var/mail/vmail/sieve/global/
	sievec /var/mail/vmail/sieve/global/spam-global.sieve
	sievec /var/mail/vmail/sieve/global/report-spam.sieve
	sievec /var/mail/vmail/sieve/global/report-ham.sieve
	chown -R vmail:vmail /var/mail/vmail/sieve/
	chmod +x /var/mail/vmail/sieve/global/train-*
	chmod 700 /etc/dovecot/dovecot-sql.conf.ext
	chown root:dovecot /etc/dovecot/dovecot-dict-sql-users.conf.ext
	chmod 640 /etc/dovecot/dovecot-dict-sql-users.conf.ext
	chgrp vmail /etc/dovecot/dovecot.conf
	chmod 640 /etc/dovecot/dovecot.conf
	chown root:vmail /usr/local/bin/quota-warning.sh
	chmod +x /usr/local/bin/quota-warning.sh
	systemctl restart dovecot
}

F_web_postfixadmin_config() {
	####################### configuration postfixadmin
	#######################
	git clone https://github.com/postfixadmin/postfixadmin.git /srv/postfixadmin/
	find /srv/postfixadmin/ -type f -print0 | xargs -0 chmod 640
	find /srv/postfixadmin/ -type f -print0 | xargs -0 chown root:www-data
	if ! [ -d  "/srv/postfixadmin/templates_c" ]; then
		mkdir /srv/postfixadmin/templates_c && chmod 750 /srv/postfixadmin/templates_c && chown -R www-data /srv/postfixadmin/templates_c
	fi
	# Personnalise le fichier de config postfixadmin
	pfaconf="/srv/postfixadmin/config.local.php" 
	cp ./postfixadmin/config.local.php /srv/postfixadmin/
	F_appconf "$pfaconf" "\$CONF\['database_host'\]" "'$ip_mail';"
	F_appconf "$pfaconf" "\$CONF\['database_user'\]" "'$db_pa_user';"
	F_appconf "$pfaconf" "\$CONF\['database_password'\]" "'$db_pa_passwd';"
	F_appconf "$pfaconf" "\$CONF\['admin_email'\]" "'$admin_pa_user\@$email';"
	F_appconf "$pfaconf" "\$CONF\['admin_smtp_password'\]" "'$admin_pa_passwd';"
	F_appconf "$pfaconf" "\$CONF\['admin_name'\]" "'$admin_pa_user';"
	F_appconf "$pfaconf" "\$CONF\['smtp_server'\]" "'$url_mail';"
	F_appconf "$pfaconf" "\$CONF\['smtp_client'\]" "'$HOSTNAME';"
	sed -i "s@postfixadmin.domain.tld@"$url_postfixadmin"@g" $pfaconf
	sed -i "s/postmaster_email/"$admin_pa_user@""$email"/g" $pfaconf
	chmod +x /srv/postfixadmin/scripts/postfixadmin-cli
	ln -s /srv/postfixadmin/scripts/postfixadmin-cli /usr/bin/postfixadmin-cli
}

F_web_postfixadmin_ini() {
#	# PFA doit initialiser sa db, celà se fait en se connectant sur /setup.php du coup curl génère cet appel
	curl -s -L https://$url_postfixadmin/setup.php > /dev/null 2>&1
	pa_status="ERROR:"
	echo -e "Inititialisation postfixadmin en cours...\c"
	# Dans le cas de coupure connexion ou server check que la page de setup a bien fini de se charger
	while [ "$pa_status" != "<!--" ]; do
		sleep 1
		echo -e ".\c"
		pa_status=$(echo $( curl -s -L https://$url_postfixadmin/login.php ) | cut -f 1 -d ' ')
	done
	# Création CLI du profile de superadmin, du domaine, de la boite postmaster et de son alias abuse@
	echo "Création du superadmin: $admin_pa_user@$email"
	postfixadmin-cli admin add $admin_pa_user@$email --password $admin_pa_passwd --password2 $admin_pa_passwd --superadmin > /dev/null 2>&1
	echo "Création du domaine: $email"
	postfixadmin-cli domain add $email --description $description_web > /dev/null 2>&1
	echo "Création de la boite mail: $admin_pa_user@$email"
	postfixadmin-cli mailbox add $admin_pa_user@$email --password $admin_pa_passwd --password2 $admin_pa_passwd --name $admin_pa_user --quota 1024 > /dev/null 2>&1
	echo "Création de la redirection de abuse@$email vers $admin_pa_user@$email"
	postfixadmin-cli alias add abuse@$email add --goto $admin_pa_user@$email > /dev/null 2>&1
	# copie du script de post creation de mailbox
	cp ./postfixadmin/postfixadmin-mailbox-postcreation.sh /usr/local/bin/
	chown www-data:www-data /usr/local/bin/postfixadmin-mailbox-postcreation.sh
	chmod +x /usr/local/bin/postfixadmin-mailbox-postcreation.sh
}

F_web_apache_config() {
	####################### configuration d'apache
	#######################
	if [ "$proxy" == "false" ]; then
		F_recreate_file "/etc/apache2/conf-available/charset.conf"
		echo -e "AddDefaultCharset UTF-8" >> "/etc/apache2/conf-available/charset.conf"
		cp ./apache/security.conf /etc/apache2/conf-available/
		cp ./apache/ssl.conf /etc/apache2/mods-available/
		find /etc/apache2/sites-enabled/ -type l -exec rm -f "{}" \;
		rm /etc/php/7.3/fpm/pool.d/www.conf
		sed -i -E "s@SSLOpenSSLConfCmd DHParameters.*@SSLOpenSSLConfCmd DHParameters	$web_dh@g" /etc/apache2/mods-available/ssl.conf
	fi	
	cp ./apache/webmail.conf /etc/php/7.3/fpm/pool.d/
	cp ./apache/postfixadmin.conf /etc/php/7.3/fpm/pool.d/
	# Activation de tous les modules apache
	a2enconf charset
	a2enconf security
	a2enmod dir
	a2enmod headers
	a2enmod http2
	a2enmod proxy_html
	a2enmod proxy_http
	a2enmod md
	a2enmod rewrite
	a2enmod security2
	a2enmod socache_shmcb
	a2enmod ssl
	a2enmod alias 
	a2enmod proxy
	a2enmod proxy_fcgi
	systemctl restart apache2
}

F_web_vhost_config() {
	####################### configuration des v_hosts
	#######################
	# config vhost postfixadmin
	pavhost="/etc/apache2/sites-available/postfixadmin_vhost.conf"
	cp ./apache/postfixadmin_vhost.conf /etc/apache2/sites-available/
	sed -i "s@<VirtualHost.*.80>@<VirtualHost $url_postfixadmin:80>@g" $pavhost
	sed -i "s@<VirtualHost.*.443>@<VirtualHost $url_postfixadmin:443>@g" $pavhost
	sed -i "s@ServerName.*@ServerName	$url_postfixadmin@g" $pavhost
	sed -i "s@ServerAlias.*@ServerAlias     www.$url_postfixadmin@g" $pavhost
	sed -i "s@ServerAdmin.*@ServerAdmin     postmaster\@$domaine@g" $pavhost
	sed -i "s@SSLCertificateFile.*@SSLCertificateFile $pa_cert@g" $pavhost
	sed -i "s@SSLCertificateKeyFile.*@SSLCertificateKeyFile $pa_key@g" $pavhost
	# config vhost rainloop
	webmailvhost="/etc/apache2/sites-available/rainloop_vhost.conf"
	cp ./apache/rainloop_vhost.conf /etc/apache2/sites-available/
	sed -i "s@<VirtualHost.*.80>@<VirtualHost $url_webmail:80>@g" $webmailvhost
	sed -i "s@<VirtualHost.*.443>@<VirtualHost $url_webmail:443>@g" $webmailvhost
	sed -i "s@ServerName.*@ServerName	$url_webmail@g" $webmailvhost
	sed -i "s@ServerAlias.*@ServerAlias	www.$url_webmail@g" $webmailvhost
	sed -i "s@ServerAdmin.*@ServerAdmin     postmaster\@$domaine@g" $webmailvhost
	sed -i "s@SSLCertificateFile.*@SSLCertificateFile $rl_cert@g" $webmailvhost
	sed -i "s@SSLCertificateKeyFile.*@SSLCertificateKeyFile $rl_key@g" $webmailvhost
	# config vhost spam GUI
	spamvhost="/etc/apache2/sites-available/spam_vhost.conf"
	cp ./apache/spam_vhost.conf /etc/apache2/sites-available/
	sed -i "s@<VirtualHost.*.80>@<VirtualHost $url_spam:80>@g" $spamvhost
	sed -i "s@<VirtualHost.*.443>@<VirtualHost $url_spam:443>@g" $spamvhost
	sed -i "s@ServerName.*@ServerName       $url_spam@g" $spamvhost
	sed -i "s@ServerAlias.*@ServerAlias     www.$url_spam@g" $spamvhost
	sed -i "s@ServerAdmin.*@ServerAdmin     postmaster\@$domaine@g" $spamvhost
	sed -i "s@SSLCertificateFile.*@SSLCertificateFile $spam_cert@g" $spamvhost
	sed -i "s@SSLCertificateKeyFile.*@SSLCertificateKeyFile $spam_key@g" $spamvhost
	sed -i "s@ip_mail@$ip_mail@g" $spamvhost
	if [ "$pa_cert_scenario" == "2" ] || [ "$pa_cert_scenario" == "4" ]; then F_comment "$pavhost" "Header always set Strict-Transport-Security \"max-age=31536000; includeSubDomains; preload\""; fi
	if [ "$rl_cert_scenario" == "2" ] || [ "$rl_cert_scenario" == "4" ]; then F_comment "$webmailvhost" "Header always set Strict-Transport-Security \"max-age=31536000; includeSubDomains; preload\""; fi
	if [ "$spam_cert_scenario" == "2" ] || [ "$spam_cert_scenario" == "4" ]; then F_comment "$spamvhost" "Header always set Strict-Transport-Security \"max-age=31536000; includeSubDomains; preload\""; fi
	# Activation vhosts
	a2ensite postfixadmin_vhost.conf
	a2ensite rainloop_vhost.conf
	a2ensite spam_vhost.conf
	systemctl restart apache2
	systemctl restart php7.3-fpm
}

F_web_rainloop_config() {
	####################### configuration de rainloop
	#######################
	find /usr/share/rainloop -type d -exec chmod 755 {} \;
	find /usr/share/rainloop -type f -exec chmod 644 {} \;
	chown --recursive www-data:www-data /usr/share/rainloop
	rm /var/lib/rainloop/_data_/_default_/configs/domains/*
	cp ./rainloop/application.ini /var/lib/rainloop/_data_/_default_/configs/
	webdomain="/var/lib/rainloop/_data_/_default_/configs/domains/$email.ini"
	appiniconf="/var/lib/rainloop/_data_/_default_/configs/application.ini"
	touch "$webdomain"
	touch /var/lib/rainloop/_data_/_default_/configs/domains/disabled
	echo -e "imap_host = \"$url_mail\"" >> "$webdomain"
	echo -e "imap_port = 143" >> "$webdomain"
	echo -e "imap_secure = \"TLS\"" >> "$webdomain"
	echo -e "imap_short_login = Off" >> "$webdomain"
	echo -e "sieve_use = On" >> "$webdomain"
	echo -e "sieve_allow_raw = On" >> "$webdomain"
	echo -e "sieve_host = \"$url_mail\"" >> "$webdomain"
	echo -e "sieve_port = 4190" >> "$webdomain"
	echo -e "sieve_secure = \"TLS\"" >> "$webdomain"
	echo -e "smtp_host = \"$url_mail\"" >> "$webdomain"
	echo -e "smtp_port = 587" >> "$webdomain"
	echo -e "smtp_secure = \"TLS\"" >> "$webdomain"
	echo -e "smtp_short_login = Off" >> "$webdomain"
	echo -e "smtp_auth = On" >> "$webdomain"
	echo -e "smtp_php_mail = Off" >> "$webdomain"
	echo -e "white_list = \"\"" >> "$webdomain"
	### fonction fixed issue de la dernière release non inclu dans debian
	cp ./rainloop/PdoAbstract.php /usr/share/rainloop/app/libraries/RainLoop/Common/
	#####
	F_appconf "$appiniconf" "title" "\"$description_mail\""
	F_appconf "$appiniconf" "pdo_dsn" "\"mysql:host=$ip_mail;port=3306;dbname=rainloop\""
	F_appconf "$appiniconf" "pdo_user" "\"$db_rainloop_user\""
	F_appconf "$appiniconf" "pdo_password" "\"$db_rainloop_passwd\""
	F_appconf "$appiniconf" "default_domain" "\"$email\""
	F_appconf "$appiniconf" "allow_admin_panel" "no"
	chown --recursive www-data:www-data /etc/rainloop/*
}

F_mail_rspamd() {
	####################### configuration de rspamd
	#######################
	hash_passwd=$(rspamadm pw --encrypt -p "$rspamd_passwd")
	hash_passwd_clean=$(echo $hash_passwd | sed 's@\$@\\\$@g')
	hash_root_passwd=$(rspamadm pw --encrypt -p "$rspamd_root_passwd")
	hash_root_passwd_clean=$(echo $hash_root_passwd | sed 's@\$@\\\$@g')
	echo -e "password = \""$hash_passwd"\";\nenable_password = \""$hash_root_passwd"\";\nbind_socket = \""$ip_mail":11334\";\nbind_socket = \"/var/run/rspamd/rspamd.sock mode=0666 owner=nobody\";" > /etc/rspamd/local.d/worker-controller.inc
	echo -e "autolearn = true;\nservers = \"127.0.0.1\";\nbackend = \"redis\";\nnew_schema = true;\nexpire = 8640000;" > /etc/rspamd/local.d/classifier-bayes.conf
	echo -e "extended_spam_headers = true;" > /etc/rspamd/local.d/milter_headers.conf
	echo -e "enabled = true;" > /etc/rspamd/local.d/rspamd_update.conf
	echo -e "actions {\nadd_header = 5;\ngreylist = 25;\nreject = 50;\n}" > /etc/rspamd/local.d/metrics.conf
	systemctl restart rspamd
	mkdir -p /var/lib/rspamd/dkim
	touch /etc/rspamd/local.d/dkim_signing.conf
	echo -e "selector_map = \"/etc/rspamd/dkim_selectors.map\";\npath_map = \"/etc/rspamd/dkim_paths.map\";\nuse_esld = false;" > /etc/rspamd/local.d/dkim_signing.conf
	echo -e "$email $selector" > /etc/rspamd/dkim_selectors.map
	echo -e "$email /var/lib/rspamd/dkim/\$selector.$email.key" > /etc/rspamd/dkim_paths.map
	rspamadm dkim_keygen -b 2048 -s $selector -d $email -k /var/lib/rspamd/dkim/$selector.$email.key > /var/lib/rspamd/dkim/$selector.$email.pub
	chmod 640 /var/lib/rspamd/dkim/*
	chown _rspamd /var/lib/rspamd/dkim/*
}

F_mail_server_install() {
	####################### menu d'install du serveur email
	#######################
	F_qax "1/8 - Installation des paquets nécessaires au server mail" F_vm_mail_init
	F_qax "2/8 - Configuration de mariadb" F_mail_mariadb_config
	F_qax "3/8 - Initialisation de la base de donées" F_mail_mariadb_init
	F_qax "4/8 - Paramétrage du firewall" F_mail_fw
	F_qax "5/8 - Mise en place des clefs du server mails" F_build_key_scenario "$mail_key" "$mail_cert" "$mail_chain" "$url_mail" "$mail_dh" "$mail_fullchain"
	F_qax "6/8 - Configuration de Postfix" F_mail_postfix
	F_qax "7/8 - Configuration de Dovecot" F_mail_dovecot
	F_qax "8/8 - Configuration de rspamd" F_mail_rspamd
}

F_web_server_install() {
	####################### menu d'install du serveur web
	#######################
	F_qax "1/10 - Installation des paquets nécessaires au server web" F_vm_web_init
	F_qax "2/10 - Paramétrage du firewall" F_web_fw
	if [ "$proxy" == "false" ]; then
		F_qax "3/10 - Mise en place des clefs pour postfixadmin" F_build_key_scenario "$pa_key" "$pa_cert" "$pa_chain" "$url_postfixadmin" "$web_dh" "$pa_fullchain"
		F_qax "4/10 - Mise en place des clefs pour interface rspam" F_build_key_scenario "$spam_key" "$spam_cert" "$spam_chain" "$url_spam" "$web_dh" "$spam_fullchain"
		F_qax "5/10 - Mise en place des clefs pour webmail" F_build_key_scenario "$rl_key" "$rl_cert" "$rl_chain" "$url_webmail" "$web_dh" "$rl_fullchain"
	fi
	F_qax "6/10 - Sécurisation de la connexion SQL" F_sql_secure 	
	F_qax "7/10 - Configuration du server Apache" F_web_apache_config 
	F_qax "8/10 - Mise en place des vhosts" F_web_vhost_config
	F_qax "9/10 - Configuration de Postfixadmin" F_web_postfixadmin_config
	F_qax "10/10 - Initialisation de Postfixadmin" F_web_postfixadmin_ini
	F_qax "11/10 - Configuration de Rainloop" F_web_rainloop_config
}

echo
echo "Bienvenue dans le programme d'installation de votre serveur mail"
echo "                      *-__fdn 2020__-*"
echo
echo "Retrouvez toutes les informations sur le script et son installation:"
echo "https://git.fdn.fr/adminsys/new_mail_server"
echo
echo ">>>>  1- Installation du serveur email - étape #1"
echo ">>>>  2- Installation du serveur web - étape #2"
echo ">>>>  Q- Sortie"
echo
read -p "Choix [1/2/Q]? " -n 1 choice
echo

proxy=false
debug=false
testLE=false

for var in "$@"
do
	if [ "$var" == "-d" ]; then debug=true; fi
	if [ "$var" == "-t" ]; then testLE=true; fi
	if [ "$var" == "-p" ]; then proxy=true; fi

done

F_qax "   > Update & upgrade du système" F_system_init
F_var_init
if [[ "$choice" =~ ^[1]$ ]]
	then
		F_mail_server_install
elif [[ "$choice" =~ ^[2]$ ]]
	then
		F_web_server_install
else
	echo "bye"
fi
echo "Installation terminée"
echo
