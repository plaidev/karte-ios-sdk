#!/bin/bash

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

if !(type brew); then
  echo 'homebrew command is not installed.'
  exit 1
fi

if !(type bundle); then
  echo 'bundler command is not installed.'
  exit 1
fi

if !(type swiftlint); then
  echo 'swiftlint command is not installed.'
  # swiftlint 0.39.1 from https://github.com/Homebrew/homebrew-core/commit/bbf6c86ae53bd2accf8fd00995903b98c140085b
  brew install https://raw.githubusercontent.com/Homebrew/homebrew-core/bbf6c86ae53bd2accf8fd00995903b98c140085b/Formula/swiftlint.rb
  brew pin swiftlint

fi

bundle install
