module SimpleRRD
  class Graph
    include SimpleRRD::HashToMethods
    
    ALLOWED_FORMATS=["SVG", "PNG", "EPS", "PDF"]

    def initialize(opts={})
      @start    = nil
      @end      = nil
      @title    = nil
      @width    = nil
      @height   = nil
      @format   = nil
      @elements = []

      call_hash_methods(opts)
    end

    attr_reader :start, :end, :title, :width, :height, :format, :elements

    def start=(t)
      raise "Expected Time; got " + t.class.to_s unless t.is_a?(Time)
      @start = t
    end

    def end=(t)
      raise "Expected Time; got " + t.class.to_s unless t.is_a?(Time)
      @end = t
    end
    
    def title=(s)
      @title = s.to_s
    end

    def width=(w)
      @width = w.to_i
      raise "Bad width" unless w > 0
    end

    def height=(h)
      @height = h.to_i
      raise "Bad height" unless h > 0
    end

    def format=(f)
      fmt = f.to_s.upcase
      if ALLOWED_FORMATS.include?(fmt)
        @format = fmt
      else
        raise "Unknown format: #{f}"
      end
    end

    def command_flags
      flags = []
      flags.concat(['--start', @start.to_i.to_s]) if @start
      if @end
        flags.concat(['--end', @end.to_i.to_s])
      else
        flags.concat(['--end', 'now'])
      end
      flags.concat(['--title', @title]) if @title
      flags.concat(['--width', @width.to_s]) if @width
      flags.concat(['--height', @height.to_s]) if @height
      flags.concat(['--imgformat', @format]) if @format
      return flags
    end
  end
end
