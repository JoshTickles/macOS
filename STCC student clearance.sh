#!/bin/sh
#
# STCC student clearance script
#
# Created 12/2015 - Josh A
# Borrowed some parts from Laura's old script, added heaps more.
# -----
# This will do a few bits of housekeeping and preferance removal before removing the computers framework and MDM profiles. When this script is run the computer is put into another smart group
# in Casper that shows cleared laptops so you can delte them from the JSS.
# -----
# Remove applications and leftovers if not done already.
rm -rfd ‘/Applications/Aurelia\ 4\ Cloud.app’
rm -rfd ‘/Applications/Inspiration\ 9.app’
rm -rfd ‘/Applications/Logger\ Pro\ 3’
rm -rfd ‘/Applications/PCClient.app’
rm -rfd ‘/Applications/Kidspiration\ 3\ IE’
rm -rfd ‘/Applications/Inspiration\ 9\ IE’
rm -rfd ‘/Applications/Kid\ Pix\ Deluxe\ 3X.app’
rm -rfd ‘/Applications/Musition\ 4\ Cloud.app’
rm -rfd ‘/Applications/Comic\ Life.app’
rm -rfd ‘/Applications/Adobe\ Premiere\ Pro\ CS6/’
# Restore write permissions to System Preferences
security authorizationdb write system.preferences allow
security authorizationdb write system.preferences.datetime allow
security authorizationdb write system.preferences.networktime allow
security authorizationdb write system.preferences.network allow
security authorizationdb write system.services.systemconfiguration.network allow
# Remove Managed Preferences
killall cfprefsd
#Remove prefs folder
rm -rfd /Library/Managed\ Preferences
# Get all computer users - list to variable
userNames=`/usr/local/jamf/bin/jamf listUsers | /usr/bin/grep \<name\> | /usr/bin/cut -d'<' -f 2 | /usr/bin/cut -d'>' -f 2`
# Remove Computer level
dscl . -mcxdelete /Computers/localhost
# Remove user level.
for activeUser in $userNames; do
echo "Removing preferences for user $activeUser"
dscl . -mcxdelete /Users/$activeUser
done
# Create success receipt. If you've reached this point the rest of the script can not fail.
if [ -d /Library/Application\ Support/JAMF/Receipts/ ];
  then
  touch /Library/Application\ Support/JAMF/Receipts/ClearanceRan
  else
  mkdir /Library/Application\ Support/JAMF/Receipts/
  touch /Library/Application\ Support/JAMF/Receipts/ClearanceRan
fi
# Recon to get into smartgroup before wireless removal.
jamf recon
# Time for recon to complete before next steps.
delay 15
# -----
# Next section removes wireless networks and removes the computer Framework and MDM profile.
# -----
# Get a list of all services
proxyAutoDiscovery=`/usr/sbin/networksetup -getproxyautodiscovery "$i" | head -1 |cut -c 23-`
# Set autoproxy off
networksetup -setproxyautodiscovery Wi-Fi off
networksetup -setautoproxystate Wi-Fi off
# Remove College networks.
ssid="SCC Campus"
wservice=`networksetup -listallnetworkservices | grep -Ei '(Wi-Fi|AirPort)'`
device=`networksetup -listallhardwareports | awk "/$wservice/,/Ethernet Address/" | awk 'NR==2' | cut -d " " -f 2`
current=`networksetup -getairportnetwork "$device" | sed -e 's/^.*: //'`
networksetup -removepreferredwirelessnetwork "$device" "$ssid"
ssid="SCC WIFI"
wservice=`networksetup -listallnetworkservices | grep -Ei '(Wi-Fi|AirPort)'`
device=`networksetup -listallhardwareports | awk "/$wservice/,/Ethernet Address/" | awk 'NR==2' | cut -d " " -f 2`
current=`networksetup -getairportnetwork "$device" | sed -e 's/^.*: //'`
networksetup -removepreferredwirelessnetwork "$device" "$ssid"
ssid="SCC Wifi"
wservice=`networksetup -listallnetworkservices | grep -Ei '(Wi-Fi|AirPort)'`
device=`networksetup -listallhardwareports | awk "/$wservice/,/Ethernet Address/" | awk 'NR==2' | cut -d " " -f 2`
current=`networksetup -getairportnetwork "$device" | sed -e 's/^.*: //'`
networksetup -removepreferredwirelessnetwork "$device" "$ssid"
echo "SSIDs removed"
# Add completion file to desktop.
for activeUser in $userNames; do
touch /Users/$activeUser/Desktop/ClearanceComplete.log
done
# Un-enrol device from the JSS + removed profiles.
jamf removeMDMprofile
errorCode=$?
if [ "$errorCode" -eq 0 ];
then
  jamf removeFramework
  delay 45
  reboot
else
  echo "Things went terribly wrong!";
  exit 1
fi
# The computer will reboot and be unmanaged.
# End
