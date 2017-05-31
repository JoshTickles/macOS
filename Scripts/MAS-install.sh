#!/bin/bash
#
# This will install all your favorite apps fromt the macOS appstore. It's designed for fresh installs / new computers to get you up and 
# running quickly. 
#
# Checks for Brew, then installs MAS, then installs your Apps. :) 
#
# Version 0.6
# Josh - 1/06/2017
#

#Colours for outputs. 
RED=`tput setaf 1`
GREEN=`tput setaf 2`
NOCOLOR=`tput sgr0`

############ START #############
echo ""
echo "Welcome, this will install Brew, MAS, then your favorite apps!"'!'
sleep 1

## Setup and sudo check
echo ""
echo "Checking permissions..."
sleep 1

if (( $EUID != 0 )); then
	echo ""
	echo "${GREEN}Not running as root. Continuing...${NOCOLOR}"
else
	echo "${RED}You ran this as sudo, please quit and run without root.${NOCOLOR}"
	exit
fi

sleep 3

## Lets see if Brew is Installed. 
echo ""
echo "Lets see if Brew is Installed."
which -s brew
if [[ $? != 0 ]] ; then
    # Install Homebrew
    echo ""
    echo "${RED}Brew is not installed.${NOCOLOR} Installing now..."
    sleep 1
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
	echo ""
	echo "${GREEN}Brew is installed!${NOCOLOR} Lets update..."
	echo ""
    brew update
fi
sleep 2

echo ""
echo "Brew is ready, now lets install MAS and get our Apps."

## Now lets install MAS ##

if brew ls MAS > /dev/null; then
	echo ""
	echo "${GREEN}The MAS package is installed, nice work!${NOCOLOR}"
else
	echo ""
	echo "${RED}The MAS package is not installed. Installing now...${NOCOLOR}"
		brew install MAS
fi

#Lets signin to MAS
echo ""
echo "Please enter your AppleID to sign in." 
echo "If you have signed in already just press a key then hit Enter:" 
read ID
#try sign in...
mas signin --dialog $ID
echo ""
echo "Time to install all your Apps! Give us a few moments..."
# List of applications to install

mas install 883878097	# Server.app
mas install 1176895641	# Spark email client
mas install 412448059	# Forklift ftp
mas install 803453959	# Slack
mas install 404010395	# TextWrangler
mas install 715768417	# MS Remote Desktop
mas install 585829637	# ToDoList
mas install 885120167   # Particulars 

sleep 2

echo""
echo "${GREEN}All of your Applications are now installed... Enjoy!${NOCOLOR}"
sleep 2
exit 0

