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

require 'xcodeproj'
require 'optparse'

class BaseCommand
  attr_reader :name, :parser

  def initialize(name)
    @name = name
    @parser = OptionParser.new do |opt|
      define_program_name(opt)
      define_version(opt)
      define_banner(opt)

      opt.separator ''
      opt.separator 'Examples:'
      define_examples(opt)

      opt.separator ''
      opt.separator 'Specific options:'
      define_specific_options(opt)

      opt.separator ''
      opt.separator 'Common options:'
      define_common_options(opt)
      opt.on_tail('-h', '--help', 'Show help message') do
        show_help
      end
      opt.on_tail('-v', '--version', 'Show program version number') do
        show_version
      end
    end
  end

  def define_program_name(opt)
  end

  def define_version(opt)
  end

  def define_banner(opt)
  end

  def define_examples(opt)
  end

  def define_specific_options(opt)
  end

  def define_common_options(opt)
  end

  def validate()
  end

  def run(argv = ARGV)
    @parser.parse!(argv)
    validate
  end

  def show_help
    puts @parser
    exit
  end

  def show_version
    puts "#{@parser.program_name} #{@parser.version}"
    exit
  end
end

class Command < BaseCommand
  def initialize
    super('bump_version')
    @subcommands = Hash.new do |h, k|
      if k.nil?
        puts @parser
        exit
      else
        @stderr.puts "No such subcommand: #{k}"
        exit 1
      end
    end
  end

  def register_subcommands(subcommands)
    subcommands.each do |subcommand|
      register_subcommand(subcommand)
    end
  end

  def register_subcommand(subcommand)
    subcommand.parser.program_name = @parser.program_name
    subcommand.parser.version = @parser.version
    @subcommands[subcommand.name] = subcommand
  end

  def define_program_name(opt)
    opt.program_name = @name
  end

  def define_version(opt)
    opt.version = '0.0.2'
  end

  def define_examples(opt)
    opt.separator "    % #{opt.program_name} major -p PROJECT -t TARGET"
    opt.separator "    % #{opt.program_name} set-version -p PROJECT -t TARGET -n 1.0.0"
    opt.separator "    % #{opt.program_name} current-version -p PROJECT -t TARGET"
    opt.separator "    % #{opt.program_name} current-tag -p PROJECT -t TARGET"
  end

  def run(argv = ARGV)
    @parser.order!(argv)
    @subcommands[argv.shift].run(argv)
  end
end

class VersionCommand < BaseCommand
  attr_reader :project, :target

  def initialize(name)
    super(name)
  end

  def define_banner(opt)
    opt.banner = "Usage: #{opt.program_name} #{@name} [options]"
  end

  def define_examples(opt)
    opt.separator "    % #{opt.program_name} #{@name} -p PROJECT -t TARGET"
  end

  def define_specific_options(opt)
    opt.on('-p VALUE', '--project=VALUE', 'Xcode project file path') { |v| @project = v }
    opt.on('-t VALUE', '--target=VALUE', 'Xcode build target name') { |v| @target = v }
  end

  def validate
    if @project.nil?
      $stderr.puts '-p or --project options are required.'
      exit 1
    elsif not File.exist?(@project)
      $stderr.puts 'xcodeproj file is not exist.'
      exit 1
    end
  end

  def get_targets
    if @target.nil?
      Xcodeproj::Project.open(@project).targets.reject { |target|
        target.is_a?(Xcodeproj::Project::Object::PBXAggregateTarget)
      }.map { |target|
        target.name
      }.select { |name|
        /Tests$/.match(name).nil?
      }.select { |name|
        /^Karte$/.match(name).nil?
      }
    else
      [@target]
    end
  end

  # Returns the path to a module's Version.xcconfig relative to the project directory
  def xcconfig_path(target_name)
    File.join(File.dirname(@project), target_name, 'Version.xcconfig')
  end

  # Reads MARKETING_VERSION from a module's Version.xcconfig
  def read_xcconfig_version(target_name)
    path = xcconfig_path(target_name)
    unless File.exist?(path)
      $stderr.puts "Version.xcconfig not found: #{path}"
      exit 1
    end
    content = File.read(path)
    match = content.match(/^\s*MARKETING_VERSION\s*=\s*(.+)$/)
    unless match
      $stderr.puts "MARKETING_VERSION not found in #{path}"
      exit 1
    end
    match[1].strip
  end

  # Writes a new MARKETING_VERSION to a module's Version.xcconfig
  def write_xcconfig_version(target_name, new_version)
    path = xcconfig_path(target_name)
    content = File.read(path)
    updated = content.gsub(/^(\s*MARKETING_VERSION\s*=\s*)(.+)$/) { "#{$1}#{new_version}" }
    File.write(path, updated)
  end

  def run(argv = ARGV)
    super(argv)
  end
end

class UpdateVersionCommand < VersionCommand
  def run(argv = ARGV)
    super(argv)
    get_targets.each do |target_name|
      version = compute_new_version(target_name)
      write_xcconfig_version(target_name, version)
      puts "   [VERSION.XCCONFIG] Bump #{@name} version for #{target_name}: #{version}"
    end
  end

  def compute_new_version(target_name)
    raise NotImplementedError
  end
end

class BumpVersionCommand < UpdateVersionCommand
  def compute_new_version(target_name)
    current = read_xcconfig_version(target_name)
    parts = current.split('.').map(&:to_i)
    parts[0] ||= 0
    parts[1] ||= 0
    parts[2] ||= 0
    case @name
    when 'major'
      parts[0] += 1; parts[1] = 0; parts[2] = 0
    when 'minor'
      parts[1] += 1; parts[2] = 0
    when 'patch'
      parts[2] += 1
    end
    parts.join('.')
  end
end

class SetVersionCommand < UpdateVersionCommand
  attr_reader :version

  def initialize
    super('set-version')
  end

  def define_specific_options(opt)
    super(opt)
    opt.on('-n VALUE', '--version-number=VALUE', 'Version number') { |v| @version = v }
  end

  def validate
    super
    if @version.nil?
      $stderr.puts '-n or --version-number options are required.'
      exit 1
    end
  end

  def compute_new_version(target_name)
    @version
  end
end

class CurrentVersionCommand < VersionCommand
  def initialize
    super('current-version')
    @quiet = false
  end

  def define_specific_options(opt)
    super(opt)
    opt.on('-q', '--quiet', 'Output only the version, without labels') { |v| @quiet = true }
  end

  def run(argv = ARGV)
    super(argv)
    get_targets.each do |target_name|
      version = read_xcconfig_version(target_name)
      if @quiet
        puts version
      else
        puts "   [VERSION.XCCONFIG] Current version for #{target_name}: #{version}"
      end
    end
  end
end

class CurrentTagVersionCommand < VersionCommand
  def initialize
    super('current-tag')
  end

  def run(argv = ARGV)
    super(argv)
    get_targets.each do |target_name|
      version = read_xcconfig_version(target_name)
      puts "#{target_name.sub(/Karte/, '')}-#{version}"
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  command = Command.new
  command.register_subcommands [
    BumpVersionCommand.new('major'),
    BumpVersionCommand.new('minor'),
    BumpVersionCommand.new('patch'),
    SetVersionCommand.new,
    CurrentVersionCommand.new,
    CurrentTagVersionCommand.new
  ]
  command.run
end
