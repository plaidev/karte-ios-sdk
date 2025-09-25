#!/usr/bin/env ruby
require 'uri'
require 'net/http'
require 'openssl'
require 'json'

request_body = {
    "title" => "[iOS]リリースノート",
    "category" => "5b56efc676674700034d9318"
}

File.open("CHANGELOG.md", "r") do |f|
    request_body["body"] = f.read
end

puts request_body.to_json

url = URI("https://dash.readme.com/api/v1/docs/release-notes-ios-sdk-v2")

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true

request = Net::HTTP::Put.new(url)
request["Accept"] = 'application/json'
request["Content-Type"] = 'application/json'
request["Authorization"] = "Basic #{ENV["README_API_KEY"]}"
request.body = request_body.to_json

response = http.request(request)

case response
when Net::HTTPSuccess
    puts "Update successfully"
else
    raise "Update failed"
end
