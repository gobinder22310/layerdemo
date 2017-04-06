#!/usr/bin/env bash
#    ___   __  __              __  ___                                         
#   /   | / /_/ /___ ______   /  |/  /__  _____________  ____  ____ ____  _____
#  / /| |/ __/ / __ `/ ___/  / /|_/ / _ \/ ___/ ___/ _ \/ __ \/ __ `/ _ \/ ___/
# / ___ / /_/ / /_/ (__  )  / /  / /  __(__  |__  )  __/ / / / /_/ /  __/ /    
#/_/  |_\__/_/\__,_/____/  /_/  /_/\___/____/____/\___/_/ /_/\__, /\___/_/     
#                                                           /____/             
#
# This is the Layer Atlas Messenger install script for iOS
#
#
# Version 1.0.0
#
# Authors:
#  - Abir Majumdar (http://github.com/maju6406)

#    Install the Atlas Messenger project by running this command:
#    curl -L atlas.layer.com/install-script | bash -s "<YOUR_APP_ID>"
#
# Files will be installed in ~/Downloads/ folder.
# 
# This script requires that 'git' and 'cocoapods' are already installed.

# Checking for pre-reqs before starting script
hash git >/dev/null 2>&1 || {		
  echo "You need to install git to continue: http://git-scm.com/download/mac"		
  exit 1		
}	

hash pod >/dev/null  || {
      echo "You need to install cocoapods to continue: http://cocoapods.org"
      exit 1
}

echo "Welcome to the Layer Atlas Messenger install script for iOS"
echo "This script will:"
echo "1. Download the latest Atlas Messenger project from Github"
echo "2. Inject your app id (if provided)"
echo "3. Grab the latest LayerKit and Atlas SDKs (via cocoapods)"
echo "4. Launch Xcode"

# Check to see if the script is running on OS X

UNAME=$(uname)
if [ "$UNAME" != "Darwin" ] ; then
    echo "Sorry, this OS is not supported."
    exit 1
fi

current_time=$(date "+%Y.%m.%d-%H.%M.%S")		
INSTALL_DIR="$HOME/Downloads/Atlas-Messenger-iOS".$current_time		
mkdir -p "$INSTALL_DIR"
cd $INSTALL_DIR
# Download the latest Atlas Messenger project from Github
echo "##########################################"		
echo "1. Downloading Latest Atlas Messenger code (This may take a few minutes)."		
git clone https://github.com/layerhq/Atlas-Messenger-iOS.git $INSTALL_DIR
echo "Atlas Messenger has been installed in your Downloads directory ($INSTALL_DIR)."

# Update the generic XCode project with your App ID
if [[ "$1" =~ [0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12} ]]; then
	echo "2. Injecting App ID: $1 in the project"	
	sed -i '' -e "s#ATLMLayerAppID \= nil#ATLMLayerAppID = \@\"$1\"#" $INSTALL_DIR/Code/ATLMAppDelegate.m	
else
	echo "2: Skipping Step - No Valid App ID provided."	
fi

# Install the latest LayerKit using Cocoapods
echo "3: Running 'pod install' to download latest LayerKit via cocoapods (This may take a few minutes)."
pod install

# Launch XCode

echo "4. Congrats, you're finished! Now opening Xcode. Press CMD-R to run the Project"
open $INSTALL_DIR/Atlas\ Messenger.xcworkspace

echo "Opening Atlas Messenger homepage on Github"
open "https://github.com/layerhq/Atlas-Messenger-iOS"

