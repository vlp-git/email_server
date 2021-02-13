# Serveur email FDN 2020

### Structure
* MTA: postifx
* IMAP: dovecot
* spam: postscreen + rspamd
* filters: sieve
* database: mariadb
* GUI mail manager: postfixadmin (pfa)
* webmail: rainloop

## **Utilisation par les membres**

### Création de boites email

#### mail @fdn.fr

Les utilisateurs souhaitant une adresse email devront écrire à service@fdn.fr en fournissant:

* pseudo: utilisé pour pseudo@fdn.fr
* (facultatif) email de secours pour mot de passe oublié

Vous recevrez alors
* le mot de passe temporaire sera communiqué par les adminsys
* un accès à https://postfixadmin.fdn.fr/users/
  * Vous pourrez changer votre mot de passe
  * Mettre en place un forward de votre email sur un autre email

#### mail @sous_domaine.fdn.fr ou @domaine_extérieur.fr

* Les utilisateurs peuvent avoir accès à un sous domaine ou domaine extérieur, il faudra fournir le sous-domaine souhaité ou le domaine extérieur à gérer
* Vous recevrez ensuite un accès à l'interface https://postfixadmin.fdn.fr pour gérer les emails/alias de votre domaine.
* Il faudra de votre côté mettre à jour les champs DNS: MX + SPF + DKIM + DMARC qui seront fourni par un adminsys

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

### Fonctionnement en relay smtp

Il est possible d'utiliser notre serveur en relay smtp:

Les utilisateurs envoie à services@fdn.fr avec:
* le domaine extérieur ou sous domaine fdn du mail
* le login de votre choix pour l'auth

 Vous recevrez alors:
* un mot de pass temporaire
* un accès à https://postfixadmin.fdn.fr/users/ pour changer votre pass
* Il faudra de votre côté mettre à jour les champs DNS: SPF + DKIM + DMARC qui seront fourni par un adminsys (ce sera important pour la bonne réception de votre email et pour la réputation du server FDN)

**La nouvelle infra ne fait plus OPEN Relay pour des raisons de sécurité et de réputation de server. L'ancienne infra smtp-old.fdn.fr peut continuer temporairement à faire de l'open relay mais il est conseillé de passer en auth relay**

### Filtres niveau serveur

* Sieve a été activé sur le serveur pour permettre la mise en place de filtres directement au niveau du server. Accessible en TLS à travers le port 4190 sur mail_domain.tld
* Il est possible de gérer les filtres via l'interface web: webmail.fdn.fr
* Pour les version de Thunderbird < 68, il existe un addon
* Pour les version de Thunderbird >= 68, le projet évolue ici: https://github.com/thsmi/sieve
* Il existe aussi des applications standalon pour la création des filtres

### Nous retrouver:

* https://www.fdn.fr
* https://git.fdn.fr/adminsys/new_fdn_emails
