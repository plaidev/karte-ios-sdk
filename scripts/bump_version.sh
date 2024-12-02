#!/bin/bash

##################################################
# Constants
##################################################

MODULES=(
  "KarteCore"
  "KarteInAppMessaging"
  "KarteRemoteNotification"
  "KarteCrashReporting"
  "KarteVariables"
  "KarteVisualTracking"
  "KarteUtilities"
  "KarteNotificationServiceExtension"
)

##################################################
# Functions
##################################################

function usage() {
  cat << EOS
Usage:
  $ bash ./scripts/bump_version.sh

Options:
  -h   Show help
EOS
}

function check_released_version() {
  PODNAME=$1
  PODSPEC=`curl -s https://raw.githubusercontent.com/plaidev/karte-ios-sdk/master/${PODNAME}.podspec | grep -E "\.version.+="`
  VERSION=`echo ${PODSPEC##*=} | tr -d "'" | tr -d '"'`

  echo " "
  echo "#########################"
  echo "# RELEASED VERSION"
  echo "#########################"
  echo $VERSION
}

function bump_version() {
  PODNAME=$1

  echo " "
  echo "#########################"
  echo "# LOCAL PODSPEC VERSION"
  echo "#########################"
  ruby scripts/bump_version.rb current-version -p Karte.xcodeproj -t $PODNAME
  echo " "

  PS3="Please select a number for the update method: "
  select METHOD in major minor patch
  do
    ruby scripts/bump_version.rb $METHOD -p Karte.xcodeproj -t $PODNAME
    break
  done
}

##################################################
# Command
##################################################

while getopts h OPT; do
  case "$OPT" in
    h)
      usage
      exit 0
      ;;
  esac
done

cd `dirname $0`
cd ../

PS3="Please select a number of the module you want to update: "
select MODULE in ${MODULES[@]}
do
  check_released_version $MODULE
  bump_version $MODULE
  break
done
