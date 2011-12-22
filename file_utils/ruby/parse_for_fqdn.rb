#!/usr/bin/env ruby

# Parse a file for a FQDN

file = ARGV[0]

if file == nil
  puts "Usage: ./parse_for_fqdn.rb <filename to parse>"
  exit
end

results = []
if File.exists?(file)
  IO.readlines(file).each_with_index do |line, idx|
    scan_data = line.scan(/([\w-]{2,}\.[\w-]{2,}\.[\w-]{2,})/)
    results<<(scan_data) if scan_data != nil || scan_data.empty?
  end 
end 

puts results if results.length > 0