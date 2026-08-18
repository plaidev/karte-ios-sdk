#!/usr/bin/env ruby
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

require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'
require_relative '../bump_version'

# Exercises the pure xcconfig read/write/bump logic and the CLI commands that
# only need an explicit -t/--target, without touching a real Xcodeproj file.
# `get_targets`'s no-target branch (which enumerates all Xcodeproj targets via
# the `xcodeproj` gem) is intentionally left uncovered here.
class BumpVersionTest < Minitest::Test
  def setup
    @dir = Dir.mktmpdir
    @project_path = File.join(@dir, 'Fake.xcodeproj')
    File.write(@project_path, '')
  end

  def teardown
    FileUtils.remove_entry(@dir)
  end

  def write_xcconfig(target_name, content)
    module_dir = File.join(@dir, target_name)
    FileUtils.mkdir_p(module_dir)
    File.write(File.join(module_dir, 'Version.xcconfig'), content)
  end

  def read_xcconfig(target_name)
    File.read(File.join(@dir, target_name, 'Version.xcconfig'))
  end

  def version_command
    cmd = VersionCommand.new('test')
    cmd.instance_variable_set(:@project, @project_path)
    cmd
  end

  def test_xcconfig_path_joins_project_dir_target_and_filename
    cmd = version_command
    expected = File.join(@dir, 'KarteFoo', 'Version.xcconfig')
    assert_equal expected, cmd.xcconfig_path('KarteFoo')
  end

  def test_get_targets_returns_explicit_target_without_touching_xcodeproj
    cmd = version_command
    cmd.instance_variable_set(:@target, 'KarteFoo')
    assert_equal ['KarteFoo'], cmd.get_targets
  end

  def test_read_xcconfig_version_returns_marketing_version
    write_xcconfig('KarteFoo', "// comment\nMARKETING_VERSION = 1.2.3\n")
    assert_equal '1.2.3', version_command.read_xcconfig_version('KarteFoo')
  end

  def test_read_xcconfig_version_strips_surrounding_whitespace
    write_xcconfig('KarteFoo', "MARKETING_VERSION =   1.2.3   \n")
    assert_equal '1.2.3', version_command.read_xcconfig_version('KarteFoo')
  end

  def test_read_xcconfig_version_exits_when_file_missing
    cmd = version_command
    _out, err = capture_io do
      assert_raises(SystemExit) { cmd.read_xcconfig_version('NoSuchModule') }
    end
    assert_match(/Version\.xcconfig not found/, err)
  end

  def test_read_xcconfig_version_exits_when_marketing_version_missing
    write_xcconfig('KarteFoo', "// no version here\n")
    cmd = version_command
    _out, err = capture_io do
      assert_raises(SystemExit) { cmd.read_xcconfig_version('KarteFoo') }
    end
    assert_match(/MARKETING_VERSION not found/, err)
  end

  def test_write_xcconfig_version_replaces_only_the_version_line
    write_xcconfig('KarteFoo', "// keep me\nMARKETING_VERSION = 1.2.3\n")
    version_command.write_xcconfig_version('KarteFoo', '9.9.9')
    assert_equal "// keep me\nMARKETING_VERSION = 9.9.9\n", read_xcconfig('KarteFoo')
  end

  def test_bump_major_resets_minor_and_patch
    write_xcconfig('KarteFoo', "MARKETING_VERSION = 1.2.3\n")
    cmd = BumpVersionCommand.new('major')
    cmd.instance_variable_set(:@project, @project_path)
    assert_equal '2.0.0', cmd.compute_new_version('KarteFoo')
  end

  def test_bump_minor_resets_patch
    write_xcconfig('KarteFoo', "MARKETING_VERSION = 1.2.3\n")
    cmd = BumpVersionCommand.new('minor')
    cmd.instance_variable_set(:@project, @project_path)
    assert_equal '1.3.0', cmd.compute_new_version('KarteFoo')
  end

  def test_bump_patch_increments_last_component_only
    write_xcconfig('KarteFoo', "MARKETING_VERSION = 1.2.3\n")
    cmd = BumpVersionCommand.new('patch')
    cmd.instance_variable_set(:@project, @project_path)
    assert_equal '1.2.4', cmd.compute_new_version('KarteFoo')
  end

  def test_bump_handles_missing_version_components
    write_xcconfig('KarteFoo', "MARKETING_VERSION = 0.7\n")
    cmd = BumpVersionCommand.new('major')
    cmd.instance_variable_set(:@project, @project_path)
    assert_equal '1.0.0', cmd.compute_new_version('KarteFoo')
  end

  def test_bump_command_run_writes_new_version_to_xcconfig
    write_xcconfig('KarteFoo', "MARKETING_VERSION = 1.2.3\n")
    cmd = BumpVersionCommand.new('minor')
    capture_io { cmd.run(['-p', @project_path, '-t', 'KarteFoo']) }
    assert_equal "MARKETING_VERSION = 1.3.0\n", read_xcconfig('KarteFoo')
  end

  def test_set_version_command_writes_given_version
    write_xcconfig('KarteFoo', "MARKETING_VERSION = 1.2.3\n")
    cmd = SetVersionCommand.new
    capture_io { cmd.run(['-p', @project_path, '-t', 'KarteFoo', '-n', '5.0.0']) }
    assert_equal "MARKETING_VERSION = 5.0.0\n", read_xcconfig('KarteFoo')
  end

  def test_current_version_labeled_output
    write_xcconfig('KarteFoo', "MARKETING_VERSION = 1.2.3\n")
    out, _err = capture_io { CurrentVersionCommand.new.run(['-p', @project_path, '-t', 'KarteFoo']) }
    assert_equal "   [VERSION.XCCONFIG] Current version for KarteFoo: 1.2.3\n", out
  end

  def test_current_version_quiet_output
    write_xcconfig('KarteFoo', "MARKETING_VERSION = 1.2.3\n")
    out, _err = capture_io { CurrentVersionCommand.new.run(['-p', @project_path, '-t', 'KarteFoo', '-q']) }
    assert_equal "1.2.3\n", out
  end

  def test_current_tag_strips_karte_prefix
    write_xcconfig('KarteFoo', "MARKETING_VERSION = 1.2.3\n")
    out, _err = capture_io { CurrentTagVersionCommand.new.run(['-p', @project_path, '-t', 'KarteFoo']) }
    assert_equal "Foo-1.2.3\n", out
  end
end
