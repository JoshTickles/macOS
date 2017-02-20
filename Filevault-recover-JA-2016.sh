#!/bin/bash
###############
#
#  Name:  Filevault-recover-JA-2016.sh
#  
#  Original Author:  Elliot Jordan <elliot@lindegroup.com>
#  Created:  2015-01-05
#
#        Heavily modified by Josh.A for wide use, addition of management account encryption.
#        Version: 2.1
#        Last Modified:  2016-07-26
#        Description of changes / modifications: See Confluence or ask Josh.
#        Required:  - Key redirection profile - see the smartgroups in the JSS for details
#                   - A DMG of your logo in the JSS. Add it to this policy if you want to brand HUD Windows.
#
###############
# Your company name.
COMPANY_NAME="College"
LOGO_PNG="/Library/Application Support/College/logo.png"
LOGO_ICNS="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/ErasingIcon.icns"
# The title of the message.
PROMPT_HEADING="STCC IT Dept: FileVault repair"
# The body of the message that will be displayed to the user.
PROMPT_MESSAGE="Your Mac's FileVault encryption key needs to be repaired in order for $COMPANY_NAME IT to be able to recover your hard drive in case of emergency.
Click the Next button below, then enter your computer's password when prompted."
# Path to jamfHelper.
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
# Your management account details (or any other account that you want to add to encryption)
adminU='admin'
adminP='pass'
#################### Validation & info collection
# Suppress errors for the duration of this script.
exec 2>/dev/null
# Make sure the custom logo has been received successfully
if [[ ! -f "$LOGO_ICNS" ]]; then
    echo "[ERROR] Custom icon not present: $LOGO_ICNS"
    exit 1001
fi
# Convert POSIX path of logo icon to Mac path for AppleScript
LOGO_ICNS="$(/usr/bin/osascript -e 'tell application "System Events" to return POSIX file "'"$LOGO_ICNS"'" as text')"
# Most of the code below is based on the JAMF reissueKey.sh script:
# https://github.com/JAMFSupport/FileVault2_Scripts/blob/master/reissueKey.sh
# Check the OS version.
OS_major=$(/usr/bin/sw_vers -productVersion | awk -F . '{print $1}')
OS_minor=$(/usr/bin/sw_vers -productVersion | awk -F . '{print $2}')
if [[ "$OS_major" -ne 10 || "$OS_minor" -lt 9 ]]; then
    echo "[ERROR] OS version not 10.9+ or OS version unrecognized."
    /usr/bin/sw_vers -productVersion
    exit 1003
fi
# Check to see if the encryption process is complete - If not exit the script.
encryptCheck="$(/usr/bin/fdesetup status)"
if [[ "$(echo "${encryptCheck}" | grep -c "Encryption in progress")" -gt 0 ]]; then
    echo "[ERROR] The encryption process is still in progress."
    echo "${encryptCheck}"
    exit 1004
elif [[ "$(echo "${encryptCheck}" | grep -c "FileVault is Off")" -gt 0 ]]; then
    echo "[ERROR] Encryption is not active."
    echo "${encryptCheck}"
    exit 1005
elif [[ "$(echo "${encryptCheck}" | grep -c "FileVault is On")" -eq 0 ]]; then
    echo "[ERROR] Unable to determine encryption status."
    echo "${encryptCheck}"
    exit 1006
fi
# Get the logged in user's name
userName="$(/usr/bin/stat -f%Su /dev/console)"
# This first user check sees if the logged in account is already authorized with FileVault 2
userCheck="$(/usr/bin/fdesetup list)"
echo "$userCheck" | egrep -q "^${userName},"
if [[ $? -ne 0 ]]; then
    echo "[ERROR] $userName is not on the list of FileVault enabled users:"
    echo "$userCheck"
    exit 1002
fi
################################# Getting credentials
# Display a branded prompt explaining the password prompt.
echo "Alerting user ${userName} about incoming password prompt..."
"$jamfHelper" -windowType hud -windowPosition ur -lockHUD -icon "$LOGO_PNG" -heading "$PROMPT_HEADING" -description "$PROMPT_MESSAGE" -button1 "Next" -defaultButton 1 -startlaunchd
# Get the logged in user's password via a prompt
echo "Prompting ${userName} for their Mac password..."
userPass="$(/usr/bin/sudo -u "$userName" /usr/bin/osascript -e 'tell application "System Events"' -e 'with timeout of 86400 seconds' -e 'display dialog "Please enter your computer password:" default answer "" with title "'"${COMPANY_NAME//\"/\\\"}"' IT - Encryption repair" with text buttons {"OK"} default button 1 with hidden answer with icon file "'"${LOGO_ICNS//\"/\\\"}"'"' -e 'return text returned of result' -e 'end timeout' -e 'end tell')"
# Password loop.
TRY=1
until dscl /Search -authonly "$userName" "$userPass" &> /dev/null; do
    (( TRY++ ))
    echo "Prompting ${userName} for their Mac password (attempt $TRY)..."
    userPass="$(/usr/bin/sudo -u "$userName" /usr/bin/osascript -e 'tell application "System Events"' -e 'with timeout of 86400 seconds' -e 'display dialog "Sorry, that password was incorrect. Please try again:" default answer "" with title "'"${COMPANY_NAME//\"/\\\"}"' IT encryption key repair" with text buttons {"OK"} default button 1 with hidden answer with icon file "'"${LOGO_ICNS//\"/\\\"}"'"' -e 'return text returned of result' -e 'end timeout' -e 'end tell')"
    if [[ $TRY -ge 5 ]]; then
        echo "[ERROR] Password prompt unsuccessful after 5 attempts."
        exit 1007
    fi
done
echo "Successfully prompted for Mac password."
################# Start the magic
echo "Unloading FDERecoveryAgent..."
launchctl unload /System/Library/LaunchDaemons/com.apple.security.FDERecoveryAgent.plist
## Now add management account to enabled users list - this means the new recovery key we generate will work on both accounts.
echo "Adding user to FileVault 2 list."
## This "expect" line will enter answers for the fdesetup prompts based on your defined
expect -c "spawn sudo /usr/bin/fdesetup add -usertoadd \"$adminU\"; expect \":\"; send \"$userPass\n\" ; expect \":\"; send \"$adminP\n\"; expect eof"
echo "Issuing new recovery key..."
# Translate XML reserved characters to XML friendly representations.
# Thanks @AggroBoy! - https://gist.github.com/AggroBoy/1242257
userPassXMLFriendly=$(echo "$userPass" | sed -e 's~&~\&amp;~g' -e 's~<~\&lt;~g' -e 's~>~\&gt;~g' -e 's~\"~\&quot;~g' -e "s~\'~\&apos;~g" )
fdesetup changerecovery -norecoverykey -verbose -personal -inputplist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
<key>Username</key>
    <string>$userName</string>
     <key>Password</key>
    <string>$userPassXMLFriendly</string>
</dict>
</plist>
EOF
# Grab the results and log the error if there's a failure.
result=$?
if [[ $result -ne 0 ]]; then
    echo "[WARNING] fdesetup exited with return code: $result."
fi
echo "Loading FDERecoveryAgent..."
# `fdesetup changerecovery` should do this automatically, but just in case...
launchctl load /System/Library/LaunchDaemons/com.apple.security.FDERecoveryAgent.plist &>/dev/null
exit $result
