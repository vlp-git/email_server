# Serveur email FDN 2020

## Structure
* MTA: postifx
* IMAP: dovecot
* spam: postscreen + rspamd
* filters: sieve
* database: mariadb
* GUI mail manager: postfixadmin (pa)
* webmail: rainloop

## Specs VM

1. mail_domain.tld:
  * Core: 2
  * RAM 4GB
  * Hard Drive: 500GB
2. webmail_domain.tld:
  * Core: 2
  * RAM: 4GB
  * Hard Drive: 15GB

## Préparation

* Soit ipV4 mail: A.B.C.D
* Soit ipV4 webmail: W.X.Y.Z

```
D.C.B.A.in-addr.arpa	IN	PTR		mail_domain.tld.
Z.Y.X.W.in-addr.arpa	IN	PTR		webmail_domain.tld.
mail			IN	A		ipV4_vm_mail
			IN	AAAA		ipV6_vm_mail
			IN	MX	10	mail
			IN 	TXT 		"v=spf1 ip4:ipV4_vm_mail ip6:ipV6_vm_mail mx -all"
[selector]._domainkey 	IN 	TXT 		"v=DKIM1; k=rsa; p=public_key_generated_by_rspamd"
## L'entrée dkim est générée par rspamd dans: /var/lib/rspamd/dkim/dkim.mail_domain.tld.pub
_dmarc.domain.tld. 	IN 	TXT 		"v=DMARC1; p=none; rua=mailto:postmaster@domain.tld; ruf=mailto:postmaster@domain.tld"
webmail			IN	A		ipV4_vm_webmail
			IN	AAAA		ipV6_vm_webmail
postfixadmin		IN	A		ipV4_vm_webmail
			IN	AAAA		ipV6_vm_webmail
```

## Firewall

Par default, bloquer tous les ports et préciser dans config.json le port ssh en place.

## Installation

* Les scripts doivent tourner en root: soit passer en root: `sudo -i`, soit lancer sudo ./install - Dans les 2 cas, les 2 scripts doivent être déployés sous le même user
* `git clone git@git.fdn.fr:adminsys/new_fdn_emails.git`
* Éditer config.json pour l'adapter à notre configuration
* ./install.sh
* Choisir, en fonction de la VM, l'installation serveur email ou du serveur web
* Le serveur email devra être installé avant le serveur web

## Utilisation

* L'interface d'administration se trouve sur postfixadmin.domain.tld
* Par default, le compte postmaster est crée avec son login:password configurés dans config.js
* les users ont accès à leur page d'admin pour gérer leurs pass: https://postfixadmin.domain.tld/users/login.php

## Création de boite email

les utilisateurs souhaitant une adresse email devront écrire à postmaster@domain.tld en fournissant:

* pseudo
* (facultatif) email de secours pour mot de passe oublié
* le mot de passe temporaire sera: pseudo123 et le lien pour changer le mot de passe sera indiqué dans le welcome email envoyé lors de la création du compte

## Créations des boites mails par liste

Lancer le script create_user_bulk.sh avec en arguments:
1. le fichier ou se trouve la liste des users: un login par ligne
2. le domaine des emails: domain.tld

Les comptes sont alors tous créé avec le mot de passe temporaire: login123

Le lien pour changer de mot de passe se trouve dans le welcome email.

## Filtres niveau serveur

* Sieve a été activé sur le serveur pour permettre la mise en place de filtres directement au niveau du server. Accessible en TLS à travers le port 4190 sur mail_domain.tld
* Il est possible de gérer les filtres via l'interface web: webmail_domain.tld
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
* https://framagit.org/thomascriscione/mail-server-installation-script
* https://github.com/vlp-git/mail-server-installation-script