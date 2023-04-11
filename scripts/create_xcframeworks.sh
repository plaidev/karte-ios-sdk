#!/bin/bash

# Copyright 2021 PLAID, Inc.
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

set -eu

function archive() {
    local scheme=$1
    xcodebuild archive \
        SKIP_INSTALL=NO \
        BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
        -workspace Karte.xcworkspace \
        -scheme $scheme \
        -destination="generic/platform=iOS" \
        -derivedDataPath DerivedData \
        -archivePath "archives/$scheme" \
        -sdk iphoneos

    xcodebuild archive \
        SKIP_INSTALL=NO \
        BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
        -workspace Karte.xcworkspace \
        -scheme $scheme \
        -destination="generic/platform=iOS Simulator" \
        -derivedDataPath DerivedData \
        -archivePath "archives/${scheme}-Simulator" \
        -sdk iphonesimulator
}

function create_xcframework() {
    local target=$1
    
    xcodebuild -create-xcframework \
        -framework $PWD/archives/${target}.xcarchive/Products/Library/Frameworks/${target}.framework \
        -debug-symbols $PWD/archives/${target}.xcarchive/dSYMs/${target}.framework.dSYM \
        -framework $PWD/archives/${target}-Simulator.xcarchive/Products/Library/Frameworks/${target}.framework \
        -debug-symbols $PWD/archives/${target}-Simulator.xcarchive/dSYMs/${target}.framework.dSYM \
        -output $PWD/xcframeworks/${target}.xcframework    
}

function compress() {
    local target=$1

    cd ./xcframeworks
    zip -r ${target}.xcframework.zip ${target}.xcframework
    cd $OLDPWD
}

function modify_manifest_file() {
    local target=$1

    local checksum=$(swift package compute-checksum ./xcframeworks/${target}.xcframework.zip)

    local tag=`ruby scripts/bump_version.rb current-tag -p Karte.xcodeproj -t $target`
    local url="https:\/\/sdk.karte.io\/ios\/swiftpm\/${tag}\/${target}.xcframework.zip"

    local target_params="name: \"${target}\""

    if grep -q -e "$target_params" ./Package.swift; then
      sed -i "" "s/${target_params}, url: .*$/${target_params}, url: \"$url\", checksum: \"$checksum\"/g" "./Package.swift"
    else
      echo "Failed to modify the manifest file."
      exit 1
    fi
}

targets=($@)

for target in ${targets[@]}; do
  archive $target
  create_xcframework $target
  compress $target
  modify_manifest_file $target
done

# verify manifest file
swift package dump-package
