#!/usr/bin/env ruby
#
$:.push("../lib")

require 'simplerrd'
include SimpleRRD

g = FancyGraph.build do

  SCALE = 30 # magic number!

  title        "Ping to Router"
  width        960
  height       360
  end_at       Time.at(1264654320)
  start_at     end_at - (60 * 60 * 24 * 5)
  upper_limit  SCALE
  lower_limit  0
  rigid        true
  exponent     1
  y_label      "ms"
  y2_label     "% loss"
  y2_scale     (100.0/SCALE) # SCALE = 100%
  y2_shift     0

  drops     = Def.new(:rrdfile => 'data/ping/ping_droprate.rrd', :ds_name => 'value', :cf => 'AVERAGE')
  drops_pct = CDef.new(:rpn_expression => [100, drops, '*'])
  timing    = Def.new(:rrdfile => 'data/ping/ping.rrd', :ds_name=>'ping', :cf => 'AVERAGE')
  stddev    = Def.new(:rrdfile => 'data/ping/ping_stddev.rrd', :ds_name => 'value', :cf => 'AVERAGE')

  timing_99pct = VDef.new(:rpn_expression => [timing, 99, "PERCENT"])
  drops_99pct  = VDef.new(:rpn_expression => [drops_pct, 99, "PERCENT"])

  timing_color = color_scheme.next
  timing_line  = Line.new(:data => timing, :text => "Ping RTT (ms)  ", :width => 1,   :color => timing_color)
  timing_area  = Area.new(:data => timing, :color => timing_color, :alpha => '66')

  drops_scaled = CDef.new(:rpn_expression => [drops, SCALE, "*"])

  drops_color = color_scheme.next
  drops_line  = Line.new(:data => drops_scaled, :text => "Packet loss (%)", :width => 1,   :color => drops_color)
  drops_area  = Area.new(:data => drops_scaled, :color => drops_color, :alpha => '66')
  
  add_element(timing_line)
  add_element(timing_area)
  summary_elements(timing).each { |e| add_element(e) }
  timing_99text = GPrint.new(:value => timing_99pct, :text => "99%%: %8.2lf%S")
  add_element(timing_99text)
  add_element(line_break)

  add_element(drops_line)
  add_element(drops_area)
  summary_elements(drops_pct).each { |e| add_element(e) }
  drops_99text = GPrint.new(:value => drops_99pct, :text => "99%%: %8.2lf%S")
  add_element(drops_99text)
  add_element(line_break)
end

g.generate('complicated_ping.png')


