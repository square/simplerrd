#!/usr/bin/env ruby
#
$:.push("../lib")
require 'simplerrd'
include SimpleRRD

graph = FancyGraph.build do
  title   "Fancy graph"

  width   640
  height  240
  end_at  Time.at(1252107236)

  buffers = data('data/mem/buffers.rrd') # ds_name and cf implied
  free    = data('data/mem/free.rrd')
  cache   = data('data/mem/cache.rrd')

  plot buffers, "Used buffers" # pick color by default, set opacity to 50-80%
  plot free,    "Free space  "
  plot cache,   "Cache used  "
end

graph.generate('dsl_mem.png')
