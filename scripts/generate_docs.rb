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

require 'bundler/setup'
require 'fastlane'
require 'optparse'
require 'tmpdir'
require 'fileutils'

class Git
  attr_reader :workspace

  def initialize(repository, workspace)
    @repository = repository
    @workspace = File.join(workspace, 'repository')
    @branch = 'master'
  end

  def clone
    system("git clone #{@repository} #{@workspace}")
  end

  def checkout(branch_name)
    Dir.chdir(@workspace) do |dir|
      system("git checkout -b #{branch_name}")
      @branch = branch_name
    end
  end

  def add
    Dir.chdir(@workspace) do |dir|
      system("git add .")
    end
  end

  def commit(message)
    Dir.chdir(@workspace) do |dir|
      system("git commit -m '#{message}'")
    end
  end

  def push
    Dir.chdir(@workspace) do |dir|
      system("git push origin #{@branch}")
    end
  end
end

class PodSpec
  attr_reader :name, :version

  def initialize(path)
    @spec = Fastlane::Actions::ReadPodspecAction.run(path: path)
    @name = @spec['name']
    @version = @spec['version']
  end
end

class Documents
  attr_reader :podspec, :platform

  def initialize(podspec, platform, workspace)
    @podspec = PodSpec.new(podspec)
    @platform = platform
    @workspace = workspace
  end

  def generate(force)
    force ||= false

    ver_dir = _get_version_dir
    ver_docs_dir = File.join(ver_dir, @podspec.name)
    if Dir.exist?(ver_docs_dir) and !force
      puts "#{@podspec.name} #{@podspec.version} documents already exist."
      return false
    end

    unless system("bundle exec jazzy -o #{_get_tmpdir} --module #{@podspec.name} --module-version #{@podspec.version} --xcodebuild-arguments -workspace,../Karte.xcworkspace,-scheme,#{@podspec.name} --dash_url \"#{_get_module_docs_url}/docsets/#{@podspec.name}.xml\"")
      $stderr.puts 'Failed to generate documents.'
      exit 1
    end

    unless _export_dash_docset_feed
      $stderr.puts 'Failed to generate dash docsets.'
      exit 1
    end

    version_file = File.join(_get_tmpdir, 'version')
    system("echo #{@podspec.version} > #{version_file}")

    _copy_version_docs
    _copy_latest_docs
    return true
  end

  def _export_dash_docset_feed
    feed = File.join(_get_tmpdir, 'docsets', "#{@podspec.name}.xml")
    xml = "<entry><version>#{@podspec.version}</version><url>#{_get_module_docs_url}/docsets/#{@podspec.name}.tgz</url></entry>"
    system("echo \"#{xml}\" > #{feed}")
  end

  def _copy_version_docs
    ver_dir = _get_version_dir
    ver_docs_dir = File.join(ver_dir, @podspec.name)
    if Dir.exist?(ver_docs_dir)
      FileUtils.rm_rf([ver_docs_dir])
    end
    FileUtils.mkdir_p(ver_dir)
    FileUtils.cp_r(_get_tmpdir, ver_dir)
  end

  def _copy_latest_docs
    latest_dir = _get_latest_dir
    latest_docs_dir = File.join(latest_dir, @podspec.name)
    if Dir.exist?(latest_docs_dir)
      version = _get_latest_document_version
      if Gem::Version.new(@podspec.version) >= Gem::Version.new(version)
        FileUtils.rm_rf([latest_docs_dir])
      end
    end
    FileUtils.mkdir_p(latest_dir)
    FileUtils.cp_r(_get_tmpdir, latest_dir)
  end

  def _get_latest_document_version
    path = File.join(_get_latest_dir, @podspec.name, 'version')
    if File.exist?(path)
      `cat #{path}`
    else
      nil
    end
  end

  def _get_latest_dir
    File.join(_get_platform_dir, 'latest')
  end

  def _get_version_dir
    File.join(_get_platform_dir, @podspec.version)
  end

  def _get_platform_dir
    File.join(@workspace, 'repository', 'docs', @platform)
  end

  def _get_tmpdir
    File.join(@workspace, @podspec.name)
  end

  def _get_module_docs_url
    "https://plaidev.github.io/karte-sdk-docs/ios/#{@podspec.version}/#{@podspec.name}"
  end
end

class Command
  attr_reader :force

  def self.release_proc(dir)
    proc { 
      puts "Remove workspace => #{dir}"
      FileUtils.rm_rf([dir]) 
    }
  end

  def initialize
    @parser = OptionParser.new do |opt|
      opt.program_name = 'generate_docs'
      opt.version = '0.0.1'
      opt.banner = "Usage: #{opt.program_name} [options]"
    
      opt.separator ''
      opt.separator 'Examples:'
      opt.separator "    % #{opt.program_name} [-f]"
    
      opt.separator ''
      opt.separator 'Specific options:'
      opt.on('-f', '--force', 'Force override docs') { |v| @force = v }
    
      opt.separator ''
      opt.separator 'Common options:'
      opt.on_tail('-h', '--help', 'Show help message') do
        puts opt
        exit
      end
      opt.on_tail('-v', '--version', 'Show program version number') do
        puts "#{opt.program_name} #{opt.version}"
        exit
      end
    end
    @parser.parse!(ARGV)
    @workspace = Dir.mktmpdir

    ObjectSpace.define_finalizer(self, self.class.release_proc(@workspace))
  end

  def run
    git = Git.new('https://github.com/plaidev/karte-sdk-docs.git', @workspace)
    unless git.clone
      $strerr.puts 'Failed to clone git repository.'
      exit 1
    end
    
    Fastlane.load_actions

    podspecs = ['Core', 'InAppMessaging', 'RemoteNotification', 'Variables', 'VisualTracking', 'InAppFrame', 'CrashReporting', 'Debugger'].map do |name|
        File.join("../Karte#{name}.podspec")
    end
    podspecs.each do |podspec|
      docs = Documents.new(podspec, 'ios', @workspace)
      if docs.generate(@force)
        git.add
        git.commit("[#{docs.platform}] Add #{docs.podspec.name} #{docs.podspec.version} documents")
        git.push
      end
    end
  end
end

command = Command.new
command.run
