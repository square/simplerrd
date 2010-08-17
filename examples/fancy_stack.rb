#!/usr/bin/env ruby
#
$:.push("../lib")
require 'simplerrd'
include SimpleRRD

graph = FancyGraph.build do
  title   "Fancy stacked graph"

  width    640
  height   240
  end_at   Time.at(1252107236)
  start_at Time.at(1252107236) - (60*60*60*6)

  buffers = data('data/mem/buffers.rrd') # ds_name and cf implied
  free    = data('data/mem/free.rrd')
  cache   = data('data/mem/cache.rrd')

  stack_plot([buffers, "Used buffers"], 
             [free,    "Free space  "],
             [cache,   "Cache used  "])
end

graph.generate('fancy_stack.png')
