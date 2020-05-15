<?php
$CONF['configured'] = true;
$CONF['fetchmail'] = 'NO';
$CONF['default_aliases'] = array();
$CONF['show_footer_text'] = 'NO';
$CONF['quota'] = 'YES';
$CONF['domain_quota'] = 'YES';
$CONF['quota_multiplier'] = '1024000';
$CONF['used_quotas'] = 'YES';
$CONF['new_quota_table'] = 'YES';
$CONF['aliases'] = '0';
$CONF['mailboxes'] = '0';
$CONF['maxquota'] = '0';
$CONF['domain_quota_default'] = '0';
$CONF['encrypt'] = 'dovecot:SHA512';
$CONF['dovecotpw'] = '/usr/bin/doveadm pw';
$CONF['database_type'] = 'mysqli';
$CONF['database_host'] = 'ip_host';
$CONF['database_user'] = 'postfix';
$CONF['database_password'] = 'changeme';
$CONF['database_name'] = 'postfix';
$CONF['database_port'] = '3306';
$CONF['database_use_ssl'] = true;
$CONF['database_ssl_key'] = '/etc/ssl/sql_client/client-key.pem';
$CONF['database_ssl_cert'] = '/etc/ssl/sql_client/client-cert.pem';
$CONF['database_ssl_ca'] = '/etc/ssl/sql_client/ca-cert.pem';
$CONF['database_ssl_ca_path'] = '/etc/ssl/sql_client/';
$CONF['database_ssl_cipher'] = 'DHE-RSA-AES256-SHA';
$CONF['admin_email'] = 'postmaster@domain.tld';
$CONF['admin_smtp_password'] = 'changeme';
$CONF['admin_name'] = 'pm';
$CONF['smtp_server'] = 'smtp_server';
$CONF['smtp_client'] = 'smtp_client';
$CONF['smtp_port'] = '587';
$CONF['smtp_sendmail_tls'] = 'YES';
$CONF['forgotten_user_password_reset'] = true;
$CONF['welcome_text'] = <<<EOM
Hi,
Welcome to your new account.
Please, go to https://postfixadmin.domain.tld/users/ to change your password.
For any help, send an email to postmaster_email.
---
Your beloved Postmaster
EOM;
?>
