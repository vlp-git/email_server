#!/bin/bash

dn=$1

echo "$dn fdn" >> /etc/rspamd/dkim_selectors.map
echo "$dn /var/lib/rspamd/dkim/\$selector.$dn.key" >> /etc/rspamd/dkim_paths.map
rspamadm dkim_keygen -b 2048 -s fdn -d $dn -k /var/lib/rspamd/dkim/fdn.$dn.key > /var/lib/rspamd/dkim/fdn.$dn.fr.pub
chmod u=rw,g=r,o= /var/lib/rspamd/dkim/*
chown _rspamd /var/lib/rspamd/dkim/*
systemctl reload rspamd
