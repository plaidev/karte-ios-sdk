github.dismiss_out_of_range_messages
swiftlint.config_file = '.swiftlint.yml'
swiftlint.lint_files inline_mode: true
swiftlint.binary_path = '/usr/local/Cellar/swiftlint/0.39.1/bin/swiftlint'

$diff_files = (git.added_files + git.modified_files + git.deleted_files)
$modules = ["Utilities", "Core", "InAppMessaging", "RemoteNotification", "Variables", "VisualTracking", "CrashReporting"]
$formatted_tags = git.tags.map { |tag| tag.strip }

def vup_check(vup_type)    
    format_str = "Version number should be bumped. Run this command:\n`ruby scripts/bump_version.rb %<type>s -p Karte.xcodeproj -t %<module>s`"
    $modules.each { |module_name|
        if !$diff_files.include?("Karte#{module_name}/**")
            next
        end
        
        version = nil
        File.open("Karte#{module_name}.podspec", mode = "r") do |f|
            version = f.readlines.map { |line| line.strip }
                .select{ |line| line.start_with?("s.version") }
                .map { |line| line.strip }
                .map { |line|
                    regex = Regexp.new('([0-9]+\.){1}[0-9]+(\.[0-9]+)')
                    regex.match(line).to_s
                }
                .first
        end

        if !$formatted_tags.include?("#{module_name}-#{version}")
            next
        end

        warn format(format_str, type: vup_type, module: "Karte#{module_name}")
    }
end

if github.branch_for_base == "develop" && github.branch_for_head.start_with?("feature/")
    vup_check("minor")
elsif github.branch_for_base == "master" && github.branch_for_head.start_with?("hotfix/")
    vup_check("patch")
end

# Sometimes it's a README fix, or something like that - which isn't relevant for
# including in a project's CHANGELOG for example
# declared_trivial = github.pr_title.include? "#trivial"

# Make it more obvious that a PR is a work in progress and shouldn't be merged yet
# warn("PR is classed as Work in Progress") if github.pr_title.include? "[WIP]"

# Warn when there is a big PR
# warn("Big PR") if git.lines_of_code > 500

# Don't let testing shortcuts get into master by accident
# fail("fdescribe left in tests") if `grep -r fdescribe specs/ `.length > 1
# fail("fit left in tests") if `grep -r fit specs/ `.length > 1
