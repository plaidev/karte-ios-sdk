#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rexml/document'
require 'time'
require 'digest'

# Parse CHANGELOG.md and extract the latest release information
class ChangelogParser
  def initialize(changelog_path)
    @changelog_path = changelog_path
    @content = File.read(changelog_path, encoding: 'utf-8')
    @lines = @content.split("\n")
  end

  def parse_latest_release
    release_info = {
      date: '',
      version: '',
      modules: []
    }

    in_release = false
    current_module = nil

    @lines.each do |line|
      # Find first release section
      if line.start_with?('# Releases - ')
        if !in_release
          in_release = true
          # Extract date: "# Releases - xxxx.xx.xx"
          release_info[:date] = line.split(' - ')[1]&.strip || ''
          next
        else
          # Found next release, stop parsing
          break
        end
      end

      next unless in_release

      # Extract version
      if line.start_with?('## Version ')
        release_info[:version] = line.sub('## Version ', '').strip
        next
      end

      # Extract module
      if line.start_with?('### ')
        # Save previous module if exists
        release_info[:modules] << current_module if current_module

        # Start new module
        module_line = line.sub('### ', '').strip
        parts = module_line.split(' ', 2)
        current_module = {
          name: parts[0],
          version: parts[1] || '',
          content: []
        }
        next
      end

      # Collect module content (skip empty lines and other headers)
      if current_module && !line.empty? && !line.start_with?('#')
        current_module[:content] << line
      end
    end

    # Add last module
    release_info[:modules] << current_module if current_module

    release_info
  end
end

class AtomFeedGenerator
  def initialize(release_info, feed_url, link_url)
    @release_info = release_info
    @feed_url = feed_url
    @link_url = link_url
    @updated_time = Time.now.utc.strftime('%Y-%m-%dT%H:%M:%SZ')
  end

  def generate
    doc = REXML::Document.new
    doc << REXML::XMLDecl.new('1.0', 'UTF-8')

    # Create feed element
    feed = doc.add_element('feed', 'xmlns' => 'http://www.w3.org/2005/Atom')

    # Feed metadata
    feed.add_element('title').text = 'KARTE for App iOS SDK Release Notes'
    feed.add_element('link', 'href' => @link_url, 'rel' => 'alternate')
    feed.add_element('link', 'href' => @feed_url, 'rel' => 'self')
    feed.add_element('id').text = @feed_url
    feed.add_element('updated').text = @updated_time

    # Add single entry for the entire release
    add_release_entry(feed)

    # Format XML with indentation
    formatter = REXML::Formatters::Pretty.new(2)
    formatter.compact = true
    output = String.new
    formatter.write(doc, output)
    output
  end

  private

  def add_release_entry(feed)
    entry = feed.add_element('entry')

    # Entry title: Release version
    title = "KARTE for App iOS SDK #{@release_info[:version]}"
    entry.add_element('title').text = title
    entry.add_element('link', 'href' => @link_url)

    # Generate content-based hash ID from all modules
    content_for_hash = @release_info[:modules].map do |mod|
      "#{mod[:name]}:#{mod[:version]}:#{mod[:content].join("\n")}"
    end.join("\n")
    content_hash = Digest::SHA256.hexdigest(content_for_hash)
    entry_id = "urn:sha256:#{content_hash}"
    entry.add_element('id').text = entry_id

    # Use feed generation time for both published and updated
    # This ensures RSS readers recognize it as a new entry
    entry.add_element('published').text = @updated_time
    entry.add_element('updated').text = @updated_time

    # Author
    author = entry.add_element('author')
    author.add_element('name').text = 'PLAID'

    # Content: All modules in single entry
    content_html = "<h2>#{escape_html(title)} - #{escape_html(@release_info[:date])}</h2>\n"

    @release_info[:modules].each do |mod|
      module_title = "#{mod[:name]} #{mod[:version]}"
      content_html += "<h3>#{escape_html(module_title)}</h3>\n"
      content_html += "<pre>#{escape_html(mod[:content].join("\n"))}</pre>\n"
    end

    entry.add_element('content', 'type' => 'html').text = content_html

    # Summary: List all updated modules
    module_list = @release_info[:modules].map { |mod| "#{mod[:name]} #{mod[:version]}" }.join(', ')
    summary = "#{title} released on #{@release_info[:date]} - Updated modules: #{module_list}"
    entry.add_element('summary').text = summary
  end

  def escape_html(text)
    text.gsub('&', '&amp;')
        .gsub('<', '&lt;')
        .gsub('>', '&gt;')
        .gsub('"', '&quot;')
        .gsub("'", '&apos;')
  end
end

def main
  if ARGV.length != 3
    warn 'Usage: generate_feed.rb <changelog_path> <feed_url> <link_url>'
    exit 1
  end

  changelog_path = ARGV[0]
  feed_url = ARGV[1]
  link_url = ARGV[2]

  unless File.exist?(changelog_path)
    warn "Error: CHANGELOG file not found: #{changelog_path}"
    exit 1
  end

  parser = ChangelogParser.new(changelog_path)
  release_info = parser.parse_latest_release

  if release_info[:modules].empty?
    warn 'Warning: No modules found in the latest release'
    exit 0
  end

  generator = AtomFeedGenerator.new(release_info, feed_url, link_url)
  feed_xml = generator.generate

  # Output to stdout
  puts feed_xml
end

main if __FILE__ == $PROGRAM_NAME
