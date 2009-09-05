module SimpleRRD
  class Graph
    include OptionsHash
    
    ALLOWED_FORMATS=["SVG", "PNG", "EPS", "PDF"]

    def initialize(opts={})
      @start_time    = nil
      @end_time      = nil
      @title    = nil
      @width    = nil
      @height   = nil
      @format   = nil
      @elements = []

      call_hash_methods(opts)
    end

    attr_reader :start_time, :end_time, :title, :width, :height, :format, :elements

    def start_time=(t)
      raise "Expected Time; got " + t.class.to_s unless t.is_a?(Time)
      @start_time = t
    end

    def end_time=(t)
      raise "Expected Time; got " + t.class.to_s unless t.is_a?(Time)
      @end_time = t
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

    def add_element(elt)
      raise "Expected a Command; got " + elt.class.to_s unless elt.is_a?(Command)
      @elements << elt
    end

    def dependencies
      deps = []
      @elements.each do |elt|
        deps.concat(elt.all_dependencies)
        deps << elt
      end
      return deps.uniq
    end

    def command_flags
      flags = []
      flags.concat(['--start', @start_time.to_i.to_s]) if @start_time
      if @end_time
        flags.concat(['--end', @end_time.to_i.to_s])
      else
        flags.concat(['--end', 'now'])
      end
      flags.concat(['--title', @title]) if @title
      flags.concat(['--width', @width.to_s]) if @width
      flags.concat(['--height', @height.to_s]) if @height
      flags.concat(['--imgformat', @format]) if @format
      return flags
    end

    def command_expressions
      exprs = []
      dependencies.each do |dep|
        exprs << dep.definition
      end
      return exprs
    end

    def generate(filename = '-')
      cmd = ['rrdtool', 'graph', filename]
      cmd.concat(command_flags)
      cmd.concat(command_expressions)
      Runner.run(*cmd)
    end
  end
end
