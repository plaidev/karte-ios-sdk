#!/bin/bash -e

# Copyright 2020 PLAID, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

##################################################
# Functions (Sub command functions)
##################################################

function set_tag() {
  local TAG=$1
  EXIST_REMOTE_REPO=`git remote | grep sync_repo | echo $?`
  if [[ $EXIST_REMOTE_REPO == 0 ]]; then
    git remote add sync_repo ${GITHUB_REMOTE_ADDRESS}
  fi
  git tag $TAG
  git push sync_repo $TAG
}

function publish() {
  local TARGETS_PODSPECS=$@
  if [ -z $TARGETS_PODSPECS ]; then
    echo "Podspec is not updated"
    exit 1
  fi

  for PODSPEC in $TARGETS_PODSPECS; do
    local TARGET=`echo $PODSPEC | sed -e "s/.podspec//"`
    TAG_VERSION=`ruby scripts/bump_version.rb current-tag -p Karte.xcodeproj -t $TARGET`

    git tag --contains $TAG_VERSION > /dev/null 2>&1
    if [ $? -eq 0 ]; then
      echo "This tag is already exist: $TAG_VERSION"
      exit 1
    else
      set_tag $TAG_VERSION
      # pod trunk push $PODSPEC --allow-warnings
    fi
  done
}

##################################################
# Checkout
##################################################

cd `dirname $0`
cd ../

##################################################
# Commands
##################################################

if [[ $EXEC_ENV == public ]]; then
  echo "This execution environment is public"
  exit 0
fi

git config --global user.name "${GITHUB_USER_NAME}"
git config --global user.email "${GITHUB_USER_EMAIL}"

DIFF_TARGETS=(`git diff --name-only origin/develop | grep podspec`)

publish $DIFF_TARGETS
