### Structure
* MTA: postifx
* IMAP: dovecot
* spam: postscreen + rspamd
* filters: sieve
* database: mariadb
* GUI mail manager: postfixadmin (pfa)
* webmail: rainloop

## Administration

### Installation du serveur

* Les scripts doivent tourner en root: soit passer en root: `sudo -i`, soit lancer sudo ./install - Dans les 2 cas, les 2 scripts doivent être déployés sous le même user
* `git clone git@git.fdn.fr:adminsys/new_fdn_emails.git`
* Éditer config.json pour l'adapter à notre configuration
* ./install.sh
* Choisir, en fonction de la VM, l'installation serveur email ou du serveur web
* Le serveur email devra être installé avant le serveur web
* le script est fait pour une architecture ayant 2 VM avec chacune leur ip publique: une install de 2 VM derrière un reverse ou même sur une seule machine peut être adapté sans trop de changement dans le code

### Créer une nouvelle adresse mail fdn

* postfixadmin.fdn.fr > Virtual List > Add mailbox
* selectionner le domaine fdn.fr

### Créer un alias fdn

* postfixadmin.fdn.fr > Virtual List > Add Alias 
* selectionner le domaine fdn.fr 

### Créer un MX secondaire
* postfixadmin.fdn.fr > new domaine
* mettre mailbox, alias et quota à 0 puis cocher MX secondaire

### Configurer un nouveau sous-domain ou domaine extérieur:

#### Créer le domaine dans postfix admin
 * postfixadmin.fdn.fr > new domaine
 * Par default: 
  * alias: unlimited
  * Mailboxes: unlimited
  * Mailbox Quota: 5120
  * Domain Quota: 20480

#### Générer les clefs DKIM

#### En automatique avec le script /scripts/rspamd_new_domaine.sh
`sudo chemin_du_repo/scripts/rspamd_new_domaine.sh mon_domaine.fdn.fr`

#### A la main: 
1. Ajouter domaine et selector dans dans /etc/rspamd/dkim_selectors.map
  * Format: "[domaine] [selector]"
  * Par default: mettre "fdn" pour le selector
  * Expl: "mon_domaine.fdn.fr fdn"  
2. Ajouter domaine dans /etc/rspamd/dkim_paths.map
  * Format: "[domaine] [chemin de la clef privé]
  * Expl: "mon_domaine.fdn.fr /var/lib/rspamd/dkim/$selector.mon_domaine.fdn.fr.key"
3. Générer la clef privée en remplaçant mySelector par le selector choisit (fdn recommandé) et my domaine par votre domaine (expl: my_domaine.fdn.fr) "rspamadm dkim_keygen -b 2048 -s mySelector -d myDomaine.fdn.fr -k /var/lib/rspamd/dkim/mySelecftor.myDomaine.fdn.fr.key > /var/lib/rspamd/dkim/mySelector.myDomaine.fdn.fr.pub
4. chmod u=rw,g=r,o= /var/lib/rspamd/dkim/*
5. chown _rspamd /var/lib/rspamd/dkim/*
6. systemctl restart rspamd

#### Entrées DNS à ajouter:

						IN	MX 10	mx.fdn.fr.
						IN  	TXT     "v=spf1 ip4:80.67.169.77 ip6:2001:910:800::77 mx -all"
			_dmarc			IN 	TXT 	"v=DMARC1; p=none; rua=mailto:postmaster@myDomaine.fdn.fr; ruf=mailto:postmaster@myDomaine.fdn.fr"
			mySelector._domainkey 	IN 	TXT 	( "v=DKIM1; k=rsa; "mypublickey_a_retrouver_dans_var_lib_rspamd_dkim") ;

### Mettre en place un relai smtp

Le serveur SMTP est ouvert pour les IP FDN
 * Adhérents DSL
 * Adhérents VPN
 * Adhérents utilisant un sous-domaine pour héberger son serveur mail

* Pour les IP extérieurs, les adhérents devront s'auth
 * La méthode est la même que pour un domaine extérieur avec des quotas arbitrairement très faible car non utilisé
 * Un relay smtp était pour notre infra un domaine extérieur sur lequel ne pointe pas les MX
 * Il faut juste créer dans ce nouveau domaine: un compte email qui servira d'auth smtp

Il est possible en plus de proposer d'ajouter une signature DKIM aux emails des adhérents: il faudra reprendre la procédure du haut: `sudo chemin_du_repo/scripts/rspamd_new_domaine.sh mon_domaine.fdn.fr` 

## API

### postfixadmin

* l'api postfixadmin est accessible depuis la machine webmail en root: ```sudo postfixadmin-cli help```

### dovecot

* L'api dovecot est implémentée, pour l'activer, il suffit de décommenter les lignes suivantes dans la fonction F_mail_fw du script d'installation:
  * iptables -A INPUT -m tcp -p tcp --dport 8080 -j ACCEPT
  * ip6tables -A INPUT -m tcp -p tcp --dport 8080 -j ACCEPT

**Utilisation des API https:**

* doc: https://doc.dovecot.org/admin_manual/doveadm_http_api/
* Télécharger le certificat: ```echo quit | openssl s_client -showcerts -servername mail_domain.tld -connect mail_domain.tld:8080 > cacert.pem```
* Pour afficher le quota de user@domain.tld: ``` curl -u doveadm:secret_password -d '[["quotaGet",{"user":"user@mail_domain.tld"},"c01"]]' https://mail_domain.tld:8080/doveadm/v1 --cacert ./cacert.pem```
  * secret_password est défini dans le fichier de configuration config.json
 
## Qualité

* La configuration de postfix/dovecot + spf/dkim nous donne un ***10/10*** sur https://www.mail-tester.com/
* La configuration apache du script permet d'obtenir un ***A+*** sur https://www.ssllabs.com/ pour postfixadmin.domain.tld et webmail.domain.tld

## Sécu

* Postfixadmin étant crititque dans l'architecture du server, il est recommandé de passer en 2FA et d'y ajouter un .htaccess
* Les connexions à la base de données se font via TLS. C'était déjà une option dans postfixadmin. Dans rainloop, il a fallu par contre réaliser un rapide patch maison.

## Debug

Pour lancer l'installation en mode debug: 

    ./install -d

### Y/N des différents modules

Une confirmation d'installation sera demandée pour le lancement des différents modules

### Afficher les scenarii des certificats

4 scenarii de gestion des certificats a été mis en place:

* cas 1: clef et certificat non fournis + LE=Y dans config.js => Création d'une clef + demande de certificat auprès de Letsencypt
* cas 2: clef et certificat non fournis + LE=N dans config.js => Création d'une clef + certificat auto-signé
* cas 3: clef et certificat déjà signé par une CA
* cas 4: clef et certificat autosigné 

### Versions

Les applications installées proviennent des dépots Buster.

Cependant, pour rainloop un patch a été développé pour ajouter la connexion à une db en TLS:

### Nous retrouver:

* https://www.fdn.fr
* https://git.fdn.fr/adminsys/new_fdn_emails
