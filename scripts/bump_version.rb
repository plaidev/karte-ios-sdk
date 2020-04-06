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

require 'bundler/setup'
require 'fastlane'
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
    opt.version = '0.0.1'
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
    elsif not File.exists?(@project)
      $stderr.puts 'xcodeproj file is not exist.'
      exit 1
    end
  end

  def get_targets
    if @target.nil?
      Xcodeproj::Project.open(@project).targets.map { |target|
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

  def get_podspec_paths(targets)
    path = File.dirname(@project)
    targets.map { |target|
      File.join(path, "#{target}.podspec")
    }.select { |podspec|
      File.exist?(podspec)
    }
  end

  def run(argv = ARGV)
    super(argv)
  end
end

class UpdateVersionCommand < VersionCommand
  def run(argv = ARGV)
    super(argv)
    targets = get_targets
    podspecs = get_podspec_paths(targets)

    if targets.length != podspecs.length
      $stderr.puts "The number of build targets differs from the number of podspec files."
      exit 1
    end

    Fastlane.load_actions
    targets.zip(podspecs).each do |pack|
      version = update_podspec_version(pack[1])
      update_xcode_build_settings_version(pack[0], version)
    end
  end

  def update_xcode_build_settings_version(target_name, version)
    project = Xcodeproj::Project.open(@project)
    project.targets.each do |target|
      if target_name == target.name
        target.build_configurations.each do |config|
          puts "[XCODE_BUILD_SETTINGS] Bump #{@name} version for #{target.name}(#{config.name}): #{version}"
          config.build_settings['MARKETING_VERSION'] = version
        end
      end
    end
    project.save
  end
end

class BumpVersionCommand < UpdateVersionCommand
  def update_podspec_version(podspec)
    version = Fastlane::Actions::VersionBumpPodspecAction.run(path: podspec, bump_type: @name)
    puts "   [COCOAPODS_PODSPEC] Bump #{@name} version for #{File.basename(podspec)}: #{version}"
    version
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

  def update_podspec_version(podspec)
    version = Fastlane::Actions::VersionBumpPodspecAction.run(path: podspec, version_number: @version)
    puts "   [COCOAPODS_PODSPEC] Bump #{@name} version for #{File.basename(podspec)}: #{version}"
    version
  end
end

class CurrentVersionCommand < VersionCommand
  def initialize
    super('current-version')
  end

  def run(argv = ARGV)
    super(argv)
    targets = get_targets
    podspecs = get_podspec_paths(targets)

    if targets.length != podspecs.length
      $stderr.puts "The number of build targets differs from the number of podspec files."
      exit 1
    end

    Fastlane.load_actions
    targets.zip(podspecs).each do |pack|
      current_podspec_version(pack[1])
      current_xcode_build_settings_version(pack[0])
    end
  end

  def current_podspec_version(podspec)
    version = Fastlane::Actions::VersionGetPodspecAction.run(path: podspec)
    puts "   [COCOAPODS_PODSPEC] Current version for #{File.basename(podspec)}: #{version}"
  end

  def current_xcode_build_settings_version(target_name)
    project = Xcodeproj::Project.open(@project)
    project.targets.each do |target|
      if target_name == target.name
        target.build_configurations.each do |config|
          puts "[XCODE_BUILD_SETTINGS] Current version for #{target.name}(#{config.name}): #{config.build_settings['MARKETING_VERSION']}"
        end
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
    targets = get_targets
    podspecs = get_podspec_paths(targets)

    if targets.length != podspecs.length
      $stderr.puts "The number of build targets differs from the number of podspec files."
      exit 1
    end

    Fastlane.load_actions
    targets.zip(podspecs).each do |pack|
      current_podspec_tag(pack[0], pack[1])
    end
  end

  def current_podspec_tag(target_name, podspec)
    version = Fastlane::Actions::VersionGetPodspecAction.run(path: podspec)
    puts "#{target_name.sub(/Karte/, '')}-#{version}"
  end
end

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
