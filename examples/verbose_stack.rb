#!/usr/bin/env ruby
#

$:.push("../lib")

require 'simplerrd'

# before you say it -- yeah, this graph doesn't
# make a lot of sense.  that's not the point.

buffers = SimpleRRD::Def.new(:rrdfile => 'data/mem/buffers.rrd', :ds_name => 'value', :cf => 'AVERAGE')
cache   = SimpleRRD::Def.new(:rrdfile => 'data/mem/cache.rrd',   :ds_name => 'value', :cf => 'AVERAGE')
free    = SimpleRRD::Def.new(:rrdfile => 'data/mem/free.rrd',    :ds_name => 'value', :cf => 'AVERAGE')

buffer_max = SimpleRRD::VDef.new(:rpn_expression => [buffers, 'MAXIMUM'])
buffer_avg = SimpleRRD::VDef.new(:rpn_expression => [buffers, 'AVERAGE'])
buffer_min = SimpleRRD::VDef.new(:rpn_expression => [buffers, 'MINIMUM'])

buffer_line = SimpleRRD::Line.new(:data => buffers, :text => "Used buffers", :width => 2, :color => '6A3D9A')
buffer_area = SimpleRRD::Area.new(:data => buffers, :color => 'CAB2D6', :alpha => 'CC')

buffer_max_text = SimpleRRD::GPrint.new(:value => buffer_max, :text => "Maximum: %8.2lf%s")
buffer_avg_text = SimpleRRD::GPrint.new(:value => buffer_avg, :text => "Average: %8.2lf%s")
buffer_min_text = SimpleRRD::GPrint.new(:value => buffer_min, :text => "Minimum: %8.2lf%s")

free_max = SimpleRRD::VDef.new(:rpn_expression => [free, 'MAXIMUM'])
free_avg = SimpleRRD::VDef.new(:rpn_expression => [free, 'AVERAGE'])
free_min = SimpleRRD::VDef.new(:rpn_expression => [free, 'MINIMUM'])

stacked_free = SimpleRRD::CDef.new(:rpn_expression => [buffers,free,'+'])
free_line = SimpleRRD::Line.new(:data => stacked_free, :text => "Free memory ", :width => 2, :color => '33A02C')
free_area = SimpleRRD::Area.new(:data => free, :color => 'B2DF8A', :alpha => 'CC', :stack => true)

free_max_text = SimpleRRD::GPrint.new(:value => free_max, :text => "Maximum: %8.2lf%s")
free_avg_text = SimpleRRD::GPrint.new(:value => free_avg, :text => "Average: %8.2lf%s")
free_min_text = SimpleRRD::GPrint.new(:value => free_min, :text => "Minimum: %8.2lf%s")

cache_max = SimpleRRD::VDef.new(:rpn_expression => [cache, 'MAXIMUM'])
cache_avg = SimpleRRD::VDef.new(:rpn_expression => [cache, 'AVERAGE'])
cache_min = SimpleRRD::VDef.new(:rpn_expression => [cache, 'MINIMUM'])

stacked_cache = SimpleRRD::CDef.new(:rpn_expression => [stacked_free,cache,'+'])
cache_line = SimpleRRD::Line.new(:data => stacked_cache, :text => "Used cache  ", :width => 2, :color => '1F78B4')
cache_area = SimpleRRD::Area.new(:data => cache, :color => 'A6CEE3', :alpha => 'CC', :stack => true)

cache_max_text = SimpleRRD::GPrint.new(:value => cache_max, :text => "Maximum: %8.2lf%s")
cache_avg_text = SimpleRRD::GPrint.new(:value => cache_avg, :text => "Average: %8.2lf%s")
cache_min_text = SimpleRRD::GPrint.new(:value => cache_min, :text => "Minimum: %8.2lf%s")

line_break = SimpleRRD::Comment.new(:text => '\n')

graph = SimpleRRD::Graph.new

graph.width = 640
graph.height = 240

graph.end_at = Time.at(1252107236) # => Fri Sep 05 16:33:56 -0700 2009

graph.add_element(buffer_area)
graph.add_element(free_area)
graph.add_element(cache_area)

graph.add_element(buffer_line)
graph.add_element(buffer_max_text)
graph.add_element(buffer_min_text)
graph.add_element(buffer_avg_text)
graph.add_element(line_break)

graph.add_element(free_line)
graph.add_element(free_max_text)
graph.add_element(free_min_text)
graph.add_element(free_avg_text)
graph.add_element(line_break)

graph.add_element(cache_line)
graph.add_element(cache_max_text)
graph.add_element(cache_min_text)
graph.add_element(cache_avg_text)
graph.add_element(line_break)

graph.generate("verbose_stack.png")
