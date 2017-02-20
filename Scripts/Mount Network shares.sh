#!/bin/sh
#
# Josh - May 2016
# Why do things manually when we can get a script to do it for us?
# 
# This script will mount a network share if the user is on a college network.
#
# Update - 17-05-2016

# Either hardcode these values or use the parameters function in JSS to change.

protocol="" #This is the connection protocol, in most cases SMB
server="" #This is the name of the server, used for mounting and ping.
share="" #This is the name of the share on the server you wish to mount.

# Variable checks 

# Checks if a value was passed in argment 4 and, if so, assign to "protocol"
if [[ "$4" != "" ]] && [[ "${protocol}" = "" ]]; then
    protocol=$4
else
	printf %b "A file-sharing protocol must be supplied in the fourth argument or hardcoded in the script\n"
	exit 1
fi
# Checks if a value was passed in argment 5 and, if so, assign to "server"
if [[ "$5" != "" ]] && [[ "${server}" == "" ]]; then
    server=$5
else
	printf %b "A server address must be supplied in the fifth argument or hardcoded in the script\n"
	exit 1
fi
# Checks if a value was passed in argment 6 and, if so, assign to "share"
if [[ "$6" != "" ]] && [[ "${share}" = "" ]]; then
    share=$6
else
	printf %b "A share path must be supplied in the sixth argument or hardcoded in the script\n"
	exit 1
fi

#Defaults (not working yet)
#echo ${protocol:-smb}
#echo ${server:-fileshare.domain.local}
#echo ${share:-staff shared}

# Check File server avalibility...
if [[ $(ping -c 1 $server | grep -c "1 packets received") = "1" ]] ; then
	echo "File Share $server is avalible, mounting now."
	# Mount Staff Shared Volume...
	$(/usr/bin/osascript > /dev/null << EOT
	Tell application "Finder"
	mount Volume "${protocol}://${server}/${share}"
	end tell
	
	# Now add Alias...
	tell application "Finder"
    make alias to disk "${share}" at desktop
    end tell
EOT)
else
	# Display message to user as they are not on a college network
	echo "File Share not avalible, not attempting mount..."
	jamf -displayMessage -message "You are not currently on the College network. Unfortunately you will not be able to access shared drives."
fi
exit 0
