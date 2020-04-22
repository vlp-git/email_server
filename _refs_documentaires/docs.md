# FDN - Serveur e-mail
## La documentation technique
### SECU
* SYSTEM
	* ANSSI : [Recommandations de sécurité relatives à un système GNU/Linux](https://www.ssi.gouv.fr/guide/recommandations-de-securite-relatives-a-un-systeme-gnulinux) ([PDF ->](https://www.ssi.gouv.fr/uploads/2016/01/linux_configuration-fr-v1.2.pdf))
	* CISecurity [Securing Debian Linux](https://www.cisecurity.org/benchmark/debian_linux "compte obligatoire pour l'accès aux documents")
	* CISecurity [Securing Distribution Independent Linux](https://www.cisecurity.org/benchmark/distribution_independent_linux "compte obligatoire pour l'accès aux documents")
* openSSH
	* ANSSI [Usage sécurisé d’(Open)SSH](https://www.ssi.gouv.fr/guide/recommandations-pour-un-usage-securise-dopenssh) ([PDF ->](https://www.ssi.gouv.fr/uploads/2014/01/NT_OpenSSH_en.pdf))
* SSL/TLS
	* ANSSI [Recommandations de sécurité relatives à TLS](https://www.ssi.gouv.fr/guide/recommandations-de-securite-relatives-a-tls/) ([PDF ->](https://www.ssi.gouv.fr/uploads/2016/09/guide_tls_v1.1.pdf))
	* QUALYS Labs [SSL and TLS Deployment Best Practices](https://github.com/ssllabs/research/wiki/SSL-and-TLS-Deployment-Best-Practices)
* CISecurity [Apache HTTP Server 2.4 Benchmark](https://www.cisecurity.org/benchmark/apache_http_server "compte obligatoire pour l'accès aux documents") (v.1.5 - 12.06.2019)
* Apache HTTP server [Conseils sur la sécurité](https://httpd.apache.org/docs/current/misc/security_tips.html)
* mod_security2
	* [Reference manual](https://github.com/SpiderLabs/ModSecurity/wiki)
	* [OWASP ModSecurity Core Rule Set](https://owasp.org/www-project-modsecurity-core-rule-set)


### openDKIM
* [Ubuntu, Postfix + DKIM](https://help.ubuntu.com/community/Postfix/DKIM)

### Apache 2.4
* [Sections de configuration](https://httpd.apache.org/docs/current/sections.html)
* [Les serveurs virtuels](https://httpd.apache.org/docs/current/vhosts)
* [Guide HTTP/2](https://httpd.apache.org/docs/current/fr/howto/http2.html) (ne pas louper "Configuration du MPM")
* [mod_headers](https://httpd.apache.org/docs/current/mod/mod_headers.html)
* [mod_md](https://httpd.apache.org/docs/current/mod/mod_md.html) (OCSP stapling + monitoring des certificats)
* [mod_http2](https://httpd.apache.org/docs/current/mod/mod_http2.html) ([+ Guide HTTP/2](https://httpd.apache.org/docs/current/howto/http2.html))
* [mod_rewrite](https://httpd.apache.org/docs/current/mod/mod_rewrite.html)
* [mod_socache_shmcb](https://httpd.apache.org/docs/current/mod/mod_socache_shmcb.html)
* [mod_watchdog](https://httpd.apache.org/docs/current/mod/mod_watchdog.html) (pseudo cron)

### TLS
* [crypto.stackexchange - about RSA SignatureAlgorithms difference](https://crypto.stackexchange.com/questions/58680/whats-the-difference-between-rsa-pss-pss-and-rsa-pss-rsae-schemes)

### RFC
* DKIM
	* [rfc6376 - DomainKeys Identified Mail (DKIM) Signatures](https://www.rfc-editor.org/rfc/rfc6376.txt)
		* Updated by:
			* [rfc8301 - DKIM Crypto Usage Update](https://www.rfc-editor.org/rfc/rfc8301.txt)
			* [rfc8463 - DKIM Crypto Update](https://www.rfc-editor.org/rfc/rfc8463.txt)
			* [rfc8553 - DNS AttrLeaf Fix](https://www.rfc-editor.org/rfc/rfc8553.txt)
			* [rfc8616 - EAI Authentication](https://www.rfc-editor.org/rfc/rfc8616.txt) (5. - p.3)

* TLS
	* [Recommendations for Secure Use of TLS and DTLS draft-ietf-uta-tls-bcp-00](https://tools.ietf.org/html/draft-ietf-uta-tls-bcp-00)
	* [rfc5289 - TLS Elliptic Curve Cipher Suites with SHA-256/384 and AES Galois Counter Mode (GCM)](https://tools.ietf.org/rfc/rfc5289.txt)
	* [rfc5116 - An Interface and Algorithms for Authenticated Encryption](https://tools.ietf.org/rfc/rfc5116.txt)
	* [rfc8446 - TLS 1.3](https://www.rfc-editor.org/rfc/rfc8446.txt)
	* [rfc8448 - TLS 1.3 Traces](https://www.rfc-editor.org/rfc/rfc8448.txt)

