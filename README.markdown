# simplerrd

SimpleRRD is intended to be a simple way to create pretty, usable graphs
with [RRDTool][rrd] in Ruby. It has a simple DSL that provides a simple
interface to some predefined graph styles, and also models RRDTool's command
syntax with Ruby objects for those who want more control.

[rrd]: http://oss.oetiker.ch/rrdtool/

## Synopsis:

    require 'simplerrd'
    include SimpleRRD
    
    graph = FancyGraph.build do
      title   "Fancy line graph"
    
      width    640
      height   240
      end_at   Time.at(1252107236)
      start_at Time.at(1252107236) - (60*60*60*6)
    
      buffers = data('data/mem/buffers.rrd') # ds_name and cf implied
      free    = data('data/mem/free.rrd')
      cache   = data('data/mem/cache.rrd')
    
      plot buffers, "Used buffers" # pick color by default, set opacity to 50-80%
      plot free,    "Free space  "
      plot cache,   "Cache used  "
    end
    
    graph.generate('fancy_lines.png')

Will produce:

![fancy_lines.png](http://www.emerose.com/files/simplerrd/fancy_lines.png)

and

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

![fancy_stacked.png](http://www.emerose.com/files/simplerrd/fancy_stack.png)

A real-world example:
![complicated_ping.png](http://www.emerose.com/files/simplerrd/complicated_ping.png)

## More information

For more examples, see the `examples/` directory.  The `create_rrds.rb`
script will create the RRD data files that the examples use.

Unfortunately, beyond the examples, there's not a lot of documetation yet.
The code and specs should be pretty readable, though.

Patches and such are welcome.

## Copyright

Copyright (c) 2009 Sam Quigley. See LICENSE for details.
