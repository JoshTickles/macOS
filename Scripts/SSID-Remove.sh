#!/bin/sh
##################################################################################
#
# HISTORY
# Version: 1.0
#
# Removes SSID from computers, and disconnects if they are connected
#
# See https://jamfnation.jamfsoftware.com/discussion.html?id=5698 for basis of this
#
# For more info see:
# http://developer.apple.com/library/mac/#documentation/Darwin/Reference/ManPages/man8/networksetup.8.html
#
###################################################################################

ssid="SCC Campus"
wservice=`networksetup -listallnetworkservices | grep -Ei '(Wi-Fi|AirPort)'`
device=`networksetup -listallhardwareports | awk "/$wservice/,/Ethernet Address/" | awk 'NR==2' | cut -d " " -f 2`
current=`networksetup -getairportnetwork "$device" | sed -e 's/^.*: //'`

networksetup -removepreferredwirelessnetwork "$device" "$ssid"
