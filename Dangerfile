require 'fastlane'
Fastlane.load_actions

$diff_files = (git.added_files + git.modified_files + git.deleted_files)
$modules = ["Utilities", "Core", "InAppMessaging", "RemoteNotification", "Variables", "VisualTracking", "CrashReporting"]
$formatted_tags = git.tags.map { |tag| tag.strip }

$is_develop_pr = github.branch_for_base == "develop" && github.branch_for_head.start_with?("feature/")
$is_hotfix_pr = (github.branch_for_base == "master" || github.branch_for_base == "develop") && github.branch_for_head.start_with?("hotfix/")

#
# Swiftlint
#
github.dismiss_out_of_range_messages
swiftlint.config_file = '.swiftlint.yml'
swiftlint.lint_files inline_mode: true
swiftlint.binary_path = '/usr/local/Cellar/swiftlint/0.39.1/bin/swiftlint'

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
# バージョン文字列をバンプアップする
def bump_version(base_version)
    versions = base_version.split('.')
    if $is_develop_pr
        versions[1] = (versions[1].to_i + 1).to_s
        versions[2] = "0"
    elsif $is_hotfix_pr
        versions[2] = (versions[2].to_i + 1).to_s
    end
    versions.join('.')
end

if ($is_develop_pr || $is_hotfix_pr)
    $modules.each { |module_name|
        if !$diff_files.include?("Karte#{module_name}/**")
            next
        end
    
        last_release_version = get_lastest_release_module_version(module_name)
        next_version = bump_version(last_release_version)
        current_version = Fastlane::Actions::VersionGetPodspecAction.run(path: "Karte#{module_name}.podspec")
        if Gem::Version.new(next_version) > Gem::Version.new(current_version)
            warn format(
                "Version number should be bumped. Run this command:\n`ruby scripts/bump_version.rb set-version -p Karte.xcodeproj -t %<module>s -n %<version>s`", 
                module: "Karte#{module_name}",
                version: next_version
            )
        end
    }
    
    spm_last_release_version = get_lastest_release_spm_version()
    spm_next_version = bump_version(spm_last_release_version)
    spm_current_version = File.read(".spm-version")
    if Gem::Version.new(spm_next_version) > Gem::Version.new(spm_current_version)
        warn "Version number should be bumped. Run this command:\n`echo -n #{spm_next_version} > .spm-version`"
    end
end

if ($is_develop_pr || $is_hotfix_pr)
    if git.modified_files.include?("CHANGELOG.md")
        return
    end
    warn "Please update CHANGELOG.md"
end
