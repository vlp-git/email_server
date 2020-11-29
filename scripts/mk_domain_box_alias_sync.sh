#!/usr/bin/env bash

################################################ FUNCTIONS
F_var () {
    ### box / alias
    ndd="osteo04.fr"
    descri="Ce que tu veux"
    yuser="mlrx"
    workdir="/home/$yuser/pfa_cli/$ndd/"
    selector="fdn" # dkim
    fichbox="${workdir}address" #  (1/ligne)
    fichalias="${workdir}alias" # (alias@domain.tld,user@domain.tld 1/ligne)
    today=$(date +%Y%m%d)
    fichlog="${workdir}${today}_mail_import.log"
    nbbox="$(cat $fichbox | wc -l)"
    maxquo="5120" # volume max / boite en Mo
    maxdomain="$(( ($maxquo * $nbbox) + ($nbbox % 3) ))" # quota max du domaine
    maxalias="0" # nb max alias / domaine
    maxbox="0" # nb max boites / domaine
    pwbox="xxxxxxxxxxxxxxxxxxxxxxxx" # si tous les mdp sont identiques (beuark)
    ### import IMAP
    # origine                               # destination
    srvorig="imap.phpnet.org";              srvdest="new-mail.fdn.fr"
    username[0]="$(sed -n 1p $fichbox)@${ndd}"; dest_user[0]="${username[0]}"
    password[0]="";     dest_pass[0]="${password[0]}"
    username[1]="$(sed -n 2p $fichbox)@${ndd}"; dest_user[1]="${username[1]}"
    password[1]="";     dest_pass[1]="${password[1]}"
#     username[2]="sms@${ndd}";  dest_user[2]="${username[2]}"
#     password[2]="${pwbox}";    dest_pass[2]="${password[2]}"
#     username[3]="smtp@${ndd}"; dest_user[3]="${username[3]}"
#     password[3]="${pwbox}";    dest_pass[3]="${password[3]}"
}

F_add_domain () {
    test $(postfixadmin-cli domain view "$ndd") || \
        postfixadmin-cli domain add "$ndd" --quota "$maxdomain" --maxquota "$maxquo" --mailboxes "$maxbox" --aliases "$maxalias" --description "$descri"
}
F_add_mailboxes () {
    if [[ -f "$fichbox" ]]
    z=0
    then
        while read -r login;
        do
            postfixadmin-cli mailbox view "$login@${ndd}" || \
            postfixadmin-cli mailbox add "$login@${ndd}" --name "$login" --password "${password[$z]}" --password2 "${password[$z]}" --active 1 --quota "$maxquo" >> ${fichlog}
            let z++
        done < "$fichbox"
    fi
    # 
}
F_add_aliases () {
    if [[ -f "$fichalias" ]]
    then
        ifsbck="$IFS"
        IFS=","
        while read -r alias dest;
        do
            postfixadmin-cli alias view "$alias" || \
            postfixadmin-cli alias add "$alias" --goto "$dest" >> ${fichlog}
        done < "$fichalias"
        IFS="$ifsbck"
    fi
}
F_import_imap () {
    for i in "${!dest_user[@]}"
    do
        imapsync    --ssl1 --host1 ${srvorig} --port1 993 --user1 ${username[$i]} --password1 ${password[$i]} \
                    --ssl2 --host2 ${srvdest} --port1 993 --user2 ${dest_user[$i]} --password2 ${dest_pass[$i]} \
                    --noerrorsdump --logfile ${today}_imapsync_${username[$i]}.log
    done
}
F_add_dkim_keys () {
    #rspamadm dkim_keygen -s "$selector" -d "$ndd" -t ed25519 -k /var/lib/rspamd/dkim/"$selector"-ed25519.key > /var/lib/rspamd/dkim/"$selector"-ed25519.pub
    rspamadm dkim_keygen -s "$selector" -d "$ndd" -b 2048 -k /var/lib/rspamd/dkim/"$selector"."$ndd".key > /var/lib/rspamd/dkim/"$selector"."$ndd".pub
}
F_rainloop_grant_use () {
    test -f /etc/rainloop/domains/${ndd}.ini || \
        cp -vf /etc/rainloop/domains/new-mail.fdn.fr.ini /etc/rainloop/domains/${ndd}.ini
    chown www-data:www-data /etc/rainloop/domains/${ndd}.ini
    chmod 644 /etc/rainloop/domains/${ndd}.ini
}
F_logs_rights () {
    chown -Rfv ${yuser}:users ${fichlog} ${workdir}LOG_imapsync
}
F_unset () {
    unset ndd workdir fichbox fichalias today fichlog maxdomain maxquo \
        maxalias maxbox srv dest_user dest_pass username password rep \
        i yuser
}

################################################ EXECUTION
F_var

F_add_domain
F_add_mailboxes
F_add_aliases
F_import_imap

#F_add_dkim_keys
F_rainloop_grant_use
F_logs_rights

F_unset

