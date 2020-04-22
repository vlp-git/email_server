#!/bin/sh
exec /usr/bin/rspamc -h /var/run/rspamd/rspamd.sock learn_ham
