# Serveur email FDN 2020

### Structure
* MTA: postifx
* IMAP: dovecot
* spam: postscreen + rspamd
* filters: sieve
* database: mariadb
* GUI mail manager: postfixadmin (pfa)
* webmail: rainloop

## Administration

### Installation

* Les scripts doivent tourner en root: soit passer en root: `sudo -i`, soit lancer sudo ./install - Dans les 2 cas, les 2 scripts doivent être déployés sous le même user
* `git clone git@git.fdn.fr:adminsys/new_fdn_emails.git`
* Éditer config.json pour l'adapter à notre configuration
* ./install.sh
* Choisir, en fonction de la VM, l'installation serveur email ou du serveur web
* Le serveur email devra être installé avant le serveur web

### Configurer un nouveau domaine un nouveau sous-domain ou domaine extérieur:

#### Créer le domaine dans postfix admin
 * postfixadmin.fdn.fr > new domaine
 * Par default: 
  * alias: unlimited
  * Mailboxes: unlimited
  * Mailbox Quota: 5120
  * Domain Quota: 20480

#### Générer les clefs DKIM
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


### Créer une nouvelle adresse mail

* postfixadmin.fdn.fr > Virtual List > Add mailbox
* Vous ne pouvez intervenir que sur les domaines où vous êtes configurés comme administrateur

### Créer un alias

* postfixadmin.fdn.fr > Virtual List > Add Alias 
* Vous ne pouvez intervenir que sur les domaines où vous êtes configurés comme administrateur

## **Utilisation par les membres**

### Création de boites email

les utilisateurs souhaitant une adresse email devront écrire à service@fdn.fr en fournissant:

* pseudo
* (facultatif) email de secours pour mot de passe oublié
* le mot de passe temporaire sera: pseudo123 et le lien pour changer le mot de passe sera indiqué dans le welcome email envoyé lors de la création du compte

### Configuration des boites emails

#### Utilisation via le webmail:

* https://webmail.fdn.fr (actif au 2021-03-01)

#### Utilisation via logiciel de messagerie:

* serveur IMAP : imap.fdn.fr
* port IMAP: 143 STARTTLS
* serveur SMTP (envoi) : smtp.fdn.fr
* port SMTP 587 STARTTLS

Si sous-domaine ou domaine extérieur:
* Enregistrement MX: mx.fdn.fr

### Création d'un MX secondaire

Il est possible de configurer le serveur comme serveur MX secondaire.

Les utilisateurs envoie à services@fdn.fr avec:
* le domaine du mail

Il faudra faire pointer le MX secondaire sur:
* mx.fdn.fr

### Filtres niveau serveur

* Sieve a été activé sur le serveur pour permettre la mise en place de filtres directement au niveau du server. Accessible en TLS à travers le port 4190 sur mail_domain.tld
* Il est possible de gérer les filtres via l'interface web: webmail.fdn.fr
* Pour les version de Thunderbird < 68, il existe un addon
* Pour les version de Thunderbird >= 68, le projet évolue ici: https://github.com/thsmi/sieve
* Il existe aussi des applications standalon pour la création des filtres

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

Cependant, pour rainloop des bugs sont présents et patch a été développé:

* Rainloop: connexion TLS aux bases de données

### Nous retrouver:

* https://www.fdn.fr
* https://git.fdn.fr/adminsys/new_fdn_emails
