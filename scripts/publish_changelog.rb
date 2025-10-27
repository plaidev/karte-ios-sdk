#!/usr/bin/env ruby

require 'uri'
require 'net/http'
require 'openssl'
require 'json'

request_body = {
    "title" => "[iOS]リリースノート",
    "category" => {
      "uri": "/branches/1.0/categories/guides/KARTE for App"
    }
}

File.open("CHANGELOG.md", "r") do |f|
    request_body["content"] = {
      "body" => f.read
    }
end

puts request_body.to_json

url = URI("https://api.readme.com/v2/branches/1.0/guides/release-notes-ios-sdk-v2")

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true

request = Net::HTTP::Patch.new(url)
request["Accept"] = 'application/json'
request["Content-Type"] = 'application/json'
request["Authorization"] = "Bearer #{ENV["README_API_KEY"]}"
request.body = request_body.to_json

response = http.request(request)

case response
when Net::HTTPSuccess
    puts "Update successfully"
else
    raise "Update failed (code: #{response.code}, body: #{response.body})"
end
