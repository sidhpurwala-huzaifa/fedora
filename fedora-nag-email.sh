#!/bin/bash
# This is a quick and dirty script to send nag emails to fedora
# maintainers to fix security issues in pkg they maintain
#
# Author: Huzaifa Sidhpurwala <huzaifas@redhat.com>
#



# Get all list of all open fedora trackers

bugfile="/home/huzaifas/Downloads/bugs-2021-02-07.csv"
EMAIL_HEADER="Dear Fedora Package Maintainer\n\nThis is an automated email from Fedora Security Team. One or more packages you maintain in Fedora seem to be affected by security issue(s). Your urgent attention is required to address them.\nDetails as follows:\n"

EMAIL_FOOTER="\nReference: https://fedoraproject.org/wiki/Security_Bugs\n\n\nYours Securely,\nFedora Security Team"


echo "Script to send nag emails to Fedora Pkg maintainers to fix security issues in their pkgs"
echo "WARNING: This script sends lots of email to people, so unless you know what you are doing, quit now!!!"
echo "Press any key to continue ^C to quit"
echo
echo

read

sed -i '1d' "$bugfile"
MAINTAINERS=`cut -f4 -d"," $bugfile | sort | uniq | sed 's/"//g'`

for email in $MAINTAINERS
do
        bugs=`grep -ri $email $bugfile  | cut -f1 -d","`
        tmpfile=$(mktemp /tmp/fedora-nag-script.XXXXXX)

        echo -e $EMAIL_HEADER > "$tmpfile"
        for bug in $bugs
        do
                echo "https://bugzilla.redhat.com/show_bug.cgi?id=$bug" >> "$tmpfile"
        done                        
        
        echo -e $EMAIL_FOOTER >> "$tmpfile"
        read
        mail -s "Your fedora packages has security bugs!" $email <<< `cat "$tmpfile"`
        rm $tmpfile
done


