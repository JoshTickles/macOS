#!/bin/bash
#
# Managed preferance removal script for computer and all users.
# 
# Josh - 2015
#

killall cfprefsd
#Remove prefs folder
rm -Rfd /Library/Managed\ Preferences

#Remove computer level 
dscl . -mcxdelete /Computers/localhost

#Get all computer users - list to variable
userNames=`/usr/local/jamf/bin/jamf listUsers | /usr/bin/grep \<name\> | /usr/bin/cut -d'<' -f 2 | /usr/bin/cut -d'>' -f 2`
#Remove user level
for activeUser in $userNames; do
echo "Removing preferances for user $activeUser"
dscl . -mcxdelete /Users/$activeUser
done

exit 0
