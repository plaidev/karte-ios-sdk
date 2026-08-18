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
  "KarteInbox"
  "KarteInAppFrame"
  "KarteUtilities"
  "KarteNotificationServiceExtension"
  "KarteDebugger"
)

##################################################
# Functions
##################################################

function usage() {
  cat << EOS
Usage:
  $ bash ./scripts/bump_version.sh [options]

Description:
  This script updates version numbers for KARTE iOS SDK modules and the SPM version.

Workflow:
  1. Select a module to update from the list
  2. View the released version from the master branch
  3. Select version update method (major/minor/patch) for the module
  4. Update .spm-version (automatic):
     - Displays master branch and current branch versions
     - If current version > master: prompts for confirmation (default: No)
     - If current version == master: proceeds to version update
     - Select version update method (major/minor/patch)

Options:
  -h    Show help
  -s    Run only SPM version update flow (skip module version update)
  -v    Display version comparison for all modules (master/develop/current)
        Color coding: Yellow = differs from master, Red = current differs from develop
EOS
}

function check_released_version() {
  MODULENAME=$1
  VERSION=`curl -s https://raw.githubusercontent.com/plaidev/karte-ios-sdk/master/${MODULENAME}/Version.xcconfig | grep -E '^[[:space:]]*MARKETING_VERSION[[:space:]]*=' | head -1 | sed -E 's/^[^=]*=[[:space:]]*//' | tr -d '[:space:]'`

  echo " "
  echo "#########################"
  echo "# RELEASED VERSION"
  echo "#########################"
  echo $VERSION
}

function compare_versions() {
  local VERSION1=$1
  local VERSION2=$2

  IFS='.' read -r -a V1_PARTS <<< "$VERSION1"
  IFS='.' read -r -a V2_PARTS <<< "$VERSION2"

  for i in 0 1 2; do
    local V1_NUM=${V1_PARTS[$i]:-0}
    local V2_NUM=${V2_PARTS[$i]:-0}

    if [ "$V1_NUM" -gt "$V2_NUM" ]; then
      echo "1"
      return
    elif [ "$V1_NUM" -lt "$V2_NUM" ]; then
      echo "-1"
      return
    fi
  done

  echo "0"
}

function bump_version() {
  MODULENAME=$1
  echo " "
  echo "#########################"
  echo "# LOCAL VERSION"
  echo "#########################"
  ruby scripts/bump_version.rb current-version -p Karte.xcodeproj -t $MODULENAME
  echo " "

  PS3="Please select a number for the update method: "
  select METHOD in major minor patch
  do
    ruby scripts/bump_version.rb $METHOD -p Karte.xcodeproj -t $MODULENAME
    break
  done
  echo ""
  echo "The module version update has been completed."
  echo ""
}

# TODO: This is a fallback for master/develop branches that predate the
# Version.xcconfig migration. Remove this function and its call sites in
# display_versions() once Version.xcconfig has landed on both master and develop.
function get_pbxproj_marketing_version() {
  local PBXPROJ_CONTENT=$1
  local MODULE=$2

  [ -z "$PBXPROJ_CONTENT" ] && return

  # Pass 1: resolve the module's Debug XCBuildConfiguration UUID from its
  # XCConfigurationList definition (this appears after the XCBuildConfiguration
  # blocks in the file, so it must be resolved before we can locate them).
  local TARGET_UUID=$(printf '%s\n' "$PBXPROJ_CONTENT" | awk -v mod="$MODULE" '
    !found && /\{$/ && index($0, "Build configuration list for PBXNativeTarget \"" mod "\"") { in_list = 1; next }
    in_list && $2 == "/*" && $3 == "Debug" { print $1; found = 1; exit }
  ')

  [ -z "$TARGET_UUID" ] && return

  # Pass 2: locate that UUID's XCBuildConfiguration block and read MARKETING_VERSION.
  printf '%s\n' "$PBXPROJ_CONTENT" | awk -v uuid="$TARGET_UUID" '
    !in_config && $1 == uuid && $3 == "Debug" && $5 == "=" { in_config = 1; next }
    in_config && $1 == "MARKETING_VERSION" && $2 == "=" {
      val = $3
      gsub(/;/, "", val)
      print val
      exit
    }
    in_config && /^\t\t\};/ { exit }
  '
}

function pad_field() {
  # printf's %-Ns pads by byte length, which under-pads values containing
  # multi-byte characters (e.g. the emoji fallback marker). Pad manually
  # using character count instead so columns stay aligned with the header.
  local STR="$1"
  local WIDTH="$2"
  local PAD=$((WIDTH - ${#STR}))
  [ "$PAD" -lt 0 ] && PAD=0
  printf '%s%*s' "$STR" "$PAD" ""
}

function display_versions() {
  local SPM_ONLY_MODE=$1
  local YELLOW='\033[33m'
  local RED='\033[31m'
  local RESET='\033[0m'

  echo " "

  if [ "$SPM_ONLY_MODE" = "true" ]; then
    # Display only SPM version
    echo "SPM Version Comparison:"
  else
    # Display module versions
    echo "Module Versions and SPM Version Comparison:"
  fi

  if [ "$SPM_ONLY_MODE" != "true" ]; then
    # Version.xcconfig may not exist yet on master/develop (pre-migration).
    # Cache each branch's project.pbxproj once so we can fall back to its
    # directly-configured MARKETING_VERSION for those branches.
    local MASTER_PBXPROJ=$(git show origin/master:Karte.xcodeproj/project.pbxproj 2>/dev/null)
    local DEVELOP_PBXPROJ=$(git show origin/develop:Karte.xcodeproj/project.pbxproj 2>/dev/null)

    local PROJECT_FALLBACK_FLAG="⚠️"
    local ANY_PROJECT_FALLBACK=false

    echo "============================================================================="
    printf "%-36s %-14s %-14s %-10s\n" "Module" "Master" "Develop" "Current"
    echo "-----------------------------------------------------------------------------"

    for MODULE in "${MODULES[@]}"; do
      # Get versions from each branch
      local MASTER_VER=$(git show origin/master:${MODULE}/Version.xcconfig 2>/dev/null | grep -E '^[[:space:]]*MARKETING_VERSION[[:space:]]*=' | head -1 | sed -E 's/^[^=]*=[[:space:]]*//' | tr -d '[:space:]')
      local MASTER_DISPLAY="$MASTER_VER"
      if [ -z "$MASTER_VER" ]; then
        MASTER_VER=$(get_pbxproj_marketing_version "$MASTER_PBXPROJ" "$MODULE")
        if [ -n "$MASTER_VER" ]; then
          MASTER_DISPLAY="${MASTER_VER} ${PROJECT_FALLBACK_FLAG}"
          ANY_PROJECT_FALLBACK=true
        else
          MASTER_VER="N/A"
          MASTER_DISPLAY="N/A"
        fi
      fi

      local DEVELOP_VER=$(git show origin/develop:${MODULE}/Version.xcconfig 2>/dev/null | grep -E '^[[:space:]]*MARKETING_VERSION[[:space:]]*=' | head -1 | sed -E 's/^[^=]*=[[:space:]]*//' | tr -d '[:space:]')
      local DEVELOP_DISPLAY="$DEVELOP_VER"
      if [ -z "$DEVELOP_VER" ]; then
        DEVELOP_VER=$(get_pbxproj_marketing_version "$DEVELOP_PBXPROJ" "$MODULE")
        if [ -n "$DEVELOP_VER" ]; then
          DEVELOP_DISPLAY="${DEVELOP_VER} ${PROJECT_FALLBACK_FLAG}"
          ANY_PROJECT_FALLBACK=true
        else
          DEVELOP_VER="N/A"
          DEVELOP_DISPLAY="N/A"
        fi
      fi

      local CURRENT_VER=$(grep -E '^[[:space:]]*MARKETING_VERSION[[:space:]]*=' ${MODULE}/Version.xcconfig 2>/dev/null | head -1 | sed -E 's/^[^=]*=[[:space:]]*//' | tr -d '[:space:]' || echo "N/A")

      # Determine colors (based on the plain version numbers, not the display strings)
      local DEVELOP_COLOR=""
      local CURRENT_COLOR=""

      if [ "$MASTER_VER" = "$DEVELOP_VER" ] && [ "$DEVELOP_VER" = "$CURRENT_VER" ]; then
        # All same - no color
        DEVELOP_COLOR=""
        CURRENT_COLOR=""
      elif [ "$DEVELOP_VER" != "$CURRENT_VER" ]; then
        # develop != current - develop is yellow, current is red
        DEVELOP_COLOR="$YELLOW"
        CURRENT_COLOR="$RED"
      else
        # develop == current but different from master - both yellow
        DEVELOP_COLOR="$YELLOW"
        CURRENT_COLOR="$YELLOW"
      fi

      local MASTER_PADDED=$(pad_field "$MASTER_DISPLAY" 14)
      local DEVELOP_PADDED=$(pad_field "$DEVELOP_DISPLAY" 14)

      printf "%-36s %s ${DEVELOP_COLOR}%s${RESET} ${CURRENT_COLOR}%-10s${RESET}\n" \
        "$MODULE" "$MASTER_PADDED" "$DEVELOP_PADDED" "$CURRENT_VER"
    done

    if [ "$ANY_PROJECT_FALLBACK" = true ]; then
      echo " "
      echo "${PROJECT_FALLBACK_FLAG} Version.xcconfig not found on that branch yet; showing the MARKETING_VERSION configured directly in the project instead."
    fi
  fi

  echo "============================================================================="
  printf "%-36s %-14s %-14s %-10s\n" "SPM Version" "Master" "Develop" "Current"
  echo "-----------------------------------------------------------------------------"
  # Display .spm-version
  local SPM_MASTER=$(git show origin/master:.spm-version 2>/dev/null | tr -d '[:space:]' || echo "N/A")
  local SPM_DEVELOP=$(git show origin/develop:.spm-version 2>/dev/null | tr -d '[:space:]' || echo "N/A")
  local SPM_CURRENT=$(cat .spm-version 2>/dev/null | tr -d '[:space:]' || echo "N/A")

  local SPM_DEVELOP_COLOR=""
  local SPM_CURRENT_COLOR=""

  if [ "$SPM_MASTER" = "$SPM_DEVELOP" ] && [ "$SPM_DEVELOP" = "$SPM_CURRENT" ]; then
    SPM_DEVELOP_COLOR=""
    SPM_CURRENT_COLOR=""
  elif [ "$SPM_DEVELOP" != "$SPM_CURRENT" ]; then
    SPM_DEVELOP_COLOR="$YELLOW"
    SPM_CURRENT_COLOR="$RED"
  else
    SPM_DEVELOP_COLOR="$YELLOW"
    SPM_CURRENT_COLOR="$YELLOW"
  fi

  printf "%-36s %-14s ${SPM_DEVELOP_COLOR}%-14s${RESET} ${SPM_CURRENT_COLOR}%-10s${RESET}\n" \
    ".spm-version" "$SPM_MASTER" "$SPM_DEVELOP" "$SPM_CURRENT"

  echo " "
}

function bump_spm_version() {
  echo "=================================================="
  echo "Bump spm version"
  echo "=================================================="

  local SPM_VERSION_FILE=".spm-version"
  local YELLOW='\033[33m'
  local RED='\033[31m'
  local RESET='\033[0m'

  # Get versions from all branches
  local MASTER_VERSION=$(git show origin/master:${SPM_VERSION_FILE} 2>/dev/null | tr -d '[:space:]')
  local CURRENT_VERSION=$(cat ${SPM_VERSION_FILE} 2>/dev/null | tr -d '[:space:]')

  if [ -z "$MASTER_VERSION" ]; then
    echo "Error: Could not fetch .spm-version from master branch"
    return 1
  fi

  if [ -z "$CURRENT_VERSION" ]; then
    echo "Error: Could not read .spm-version from current branch"
    return 1
  fi

  # Compare versions
  local COMPARISON=$(compare_versions "$CURRENT_VERSION" "$MASTER_VERSION")

  if [ "$COMPARISON" = "1" ]; then
    # Current version is already higher than master
    echo ".spm-version of current branch version is already higher than master."
    read -p "Do you want to update it anyway? [y/N]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      echo "Skipping .spm-version update."
      return 0
    fi
  fi

  # Proceed with version update
  PS3="Please select a number for the update method: "
  select METHOD in major minor patch
  do
    case $METHOD in
      major|minor|patch)
        IFS='.' read -r -a VERSION_PARTS <<< "$CURRENT_VERSION"
        local MAJOR=${VERSION_PARTS[0]:-0}
        local MINOR=${VERSION_PARTS[1]:-0}
        local PATCH=${VERSION_PARTS[2]:-0}

        case $METHOD in
          major)
            MAJOR=$((MAJOR + 1))
            MINOR=0
            PATCH=0
            ;;
          minor)
            MINOR=$((MINOR + 1))
            PATCH=0
            ;;
          patch)
            PATCH=$((PATCH + 1))
            ;;
        esac

        local NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"
        echo "${NEW_VERSION}" > ${SPM_VERSION_FILE}
        echo ""
        echo ".spm version has been updated from" $CURRENT_VERSION "to" $NEW_VERSION
        break
        ;;
      *)
        echo "Invalid selection. Please try again."
        ;;
    esac
  done
}

##################################################
# Command
##################################################

SPM_ONLY=false
DISPLAY_VERSIONS=false

while getopts hsv OPT; do
  case "$OPT" in
    h)
      usage
      exit 0
      ;;
    s)
      SPM_ONLY=true
      ;;
    v)
      DISPLAY_VERSIONS=true
      ;;
  esac
done

cd `dirname $0`
cd ../

# Fetch latest from remote
echo "Fetching latest from remote..."
git fetch origin

if [ "$DISPLAY_VERSIONS" = true ]; then
  # Display version comparison and exit
  display_versions "false"
  exit 0
elif [ "$SPM_ONLY" = true ]; then
  display_versions "true"

  # Run only SPM version update
  bump_spm_version

  display_versions "true"
else
  display_versions "false"

  echo "=================================================="
  echo "Bump module version"
  echo "=================================================="

  # Run full workflow
  PS3="Please select a number of the module you want to update: "
  select MODULE in ${MODULES[@]}
  do
    check_released_version $MODULE
    bump_version $MODULE
    break
  done

  bump_spm_version

  display_versions "false"
fi