#!/usr/bin/env ruby
#

puts "Creating RRD files from XML dumps..."
Dir.glob(File.join(File.dirname(__FILE__), "data", "*", "*.xml.gz")).each do |f|
  rrdname = f.gsub(/\.xml\.gz\Z/, '') + '.rrd'
  puts "\t#{f} => #{rrdname}"
  system("gunzip -c #{f} | rrdtool restore - #{rrdname}")
end
