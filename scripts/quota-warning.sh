#!/bin/sh
PERCENT=$1
USER=$2
cat << EOF | /usr/lib/dovecot/dovecot-lda -d $USER -o "plugin/quota=dict:User quota::noenforcing:proxy::sqlquota"
From: postmaster@$(hostname -f)
Subject: Quota warning

Your mailbox is $PERCENT% full. Don't forget to make a backup of old messages to remain able to receive mails.
EOF
