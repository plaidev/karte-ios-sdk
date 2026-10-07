require 'fastlane'
Fastlane.load_actions

$diff_files = (git.added_files + git.modified_files + git.deleted_files)
$modules = ["Utilities", "Core", "InAppMessaging", "RemoteNotification", "Variables", "VisualTracking", "CrashReporting", "NotificationServiceExtension"]
$formatted_tags = git.tags.map { |tag| tag.strip }

#
# Swiftlint
#
github.dismiss_out_of_range_messages
swiftlint.config_file = '.swiftlint.yml'
swiftlint.binary_path = '/opt/homebrew/bin/swiftlint'
swiftlint.lint_files inline_mode: true

# 
# Check Version
# 
# gitのtagから最新バージョンを返却する
def get_lastest_release_version(prefix)
    $formatted_tags.select { |tag| tag =~ /^#{prefix}([0-9]+\.){1}[0-9]+(\.[0-9]+)$/ }
            .map { |tag| tag.delete("#{prefix}") }
            .sort_by { |tag| Gem::Version.new(tag) }
            .last
end
# gitのtagから指定モジュールの最新バージョンを返却する
def get_lastest_release_module_version(module_name)
    get_lastest_release_version("#{module_name}-")
end
# gitのtagからspmの最新バージョンを返却する
def get_lastest_release_spm_version()
    get_lastest_release_version("")
end
def next_patch_version(base_version)
    versions = base_version.split('.')
    versions[2] = (versions[2].to_i + 1).to_s
    versions.join('.')
end

$modules.each { |module_name|
    if !$diff_files.any? { |file| file.start_with?("Karte#{module_name}/") }
        next
    end

    last_release_version = get_lastest_release_module_version(module_name)
    if last_release_version.nil?
        warn "#{module_name} release history not found.\nIgnore this warning if you add a new module."
        next
    end

    minimum_required_version = next_patch_version(last_release_version)
    current_version = File.read("Karte#{module_name}/Version.xcconfig")[/^\s*MARKETING_VERSION\s*=\s*(.+)$/, 1].strip
    if Gem::Version.new(minimum_required_version) > Gem::Version.new(current_version)
        warn "Karte#{module_name} version should be greater than the latest release (#{last_release_version})."
    end
}

spm_last_release_version = get_lastest_release_spm_version()
spm_minimum_required_version = next_patch_version(spm_last_release_version)
spm_current_version = File.read(".spm-version")
if Gem::Version.new(spm_minimum_required_version) > Gem::Version.new(spm_current_version)
    warn ".spm-version should be greater than the latest release (#{spm_last_release_version})."
end

if !git.modified_files.include?("CHANGELOG.md")
    warn "Please update CHANGELOG.md"
end
