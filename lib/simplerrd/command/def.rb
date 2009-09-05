module SimpleRRD
  class Def < Command
    #  DEF:<vname>=<rrdfile>:<ds-name>:<CF>[:step=<step>][:start=<time>][:end=<time>][:reduce=<CF>]
    #
    #  This command fetches data from an RRD file.  The virtual name vname can
    #  then be used throughout the rest of the script. By default, an RRA
    #  which contains the correct consolidated data at an appropriate
    #  resolution will be chosen.  The resolution can be overridden with the
    #  --step option.  The resolution can again be overridden by specifying
    #  the step size.  The time span of this data is the same as for the graph
    #  by default, you can override this by specifying start and end.
    #  Remember to escape colons in the time specification! 
    #
    #  If the resolution of the data is higher than the resolution of the
    #  graph, the data will be further consolidated. This may result in a
    #  graph that spans slightly more time than requested.  Ideally each point
    #  in the graph should correspond with one CDP from an RRA.  For instance,
    #  if your RRD has an RRA with a resolution of 1800 seconds per CDP, you
    #  should create an image with width 400 and time span 400*1800 seconds
    #  (use appropriate start and end times, such as "--start
    #  end-8days8hours").
    #
    #  If consolidation needs to be done, the CF of the RRA specified in the
    #  DEF itself will be used to reduce the data density. This behaviour can
    #  be changed using ":reduce=<CF>".  This optional parameter specifies the
    #  CF to use during the data reduction phase.
    #
    #  Example:
    #
    #    DEF:ds0=router.rrd:ds0:AVERAGE
    #    DEF:ds0weekly=router.rrd:ds0:AVERAGE:step=7200
    #    DEF:ds0weekly=router.rrd:ds0:AVERAGE:start=end-1h
    #    DEF:ds0weekly=router.rrd:ds0:AVERAGE:start=11\:00:end=start+1h
    
    include VName
    include HashToMethods

    def initialize(opts = {})
      @rrdfile = nil
      @ds_name = nil
      @cf      = nil
      @step    = nil
      @start   = nil
      @end     = nil
      @reduce  = nil
      call_hash_methods(opts)
    end

    attr_reader :rrdfile, :ds_name, :cf, :step, :start, :end, :reduce

    def rrdfile=(f)
      raise "Expected a String; got a " + f.class.to_s unless f.is_a?(String)
      @rrdfile = f
    end

    def ds_name=(n)
      raise "Bad ds name: #{n}" unless n.match(DS_NAME_REGEX)
      @ds_name = n
    end

    def cf=(fn)
      raise "Not a valid consolidation function" unless CONSOLIDATION_FUNCTIONS.include?(fn)
      @cf = fn
    end
    
    def step=(s)
      raise "Step should be a positive number" unless s.to_i > 0
      @step = s.to_i
    end

    def start=(t)
      raise "Expected Time; got " + t.class.to_s unless t.is_a?(Time)
      @start = t
    end

    def end=(t)
      raise "Expected Time; got " + t.class.to_s unless t.is_a?(Time)
      @end = t
    end

    def reduce=(fn)
      raise "Not a valid consolidation function" unless CONSOLIDATION_FUNCTIONS.include?(fn)
      @reduce = fn
    end

    def definition
      raise "Definition incomplete: missing rrdfile" unless @rrdfile
      raise "Definition incomplete: missing ds_name" unless @ds_name
      raise "Definition incomplete: missing cf"      unless @cf

      res = "DEF:#{@vname}=#{@rrdfile}:#{@ds_name}:#{cf}"
      res << ":step=#{@step}"        if @step
      res << ":start=#{@start.to_i}" if @start
      res << ":end=#{@end.to_i}"     if @end
      res << ":reduce=#{@reduce}"    if @reduce
      return res
    end
  end
end
