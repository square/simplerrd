module SimpleRRD
  class Graph
    include OptionsHash
    
    ALLOWED_FORMATS=["SVG", "PNG", "EPS", "PDF"]

    def initialize(opts={})
      @start_at = nil
      @end_at   = nil
      @title    = nil
      @width    = nil
      @height   = nil
      @format   = nil
      @elements = []

      call_hash_methods(opts)
    end

    attr_reader :start_at, :end_at, :title, :width, :height, :format, :elements

    def start_at(val=nil)
      return self.start_at=val if val
      return @start_at
    end

    def start_at=(t)
      raise "Expected Time; got " + t.class.to_s unless t.is_a?(Time)
      @start_at = t
    end

    def end_at(val=nil)
      return self.end_at=val if val
      return @end_at
    end

    def end_at=(t)
      raise "Expected Time; got " + t.class.to_s unless t.is_a?(Time)
      @end_at = t
    end
    
    def title(val=nil)
      return self.title=val if val
      return @title
    end

    def title=(s)
      @title = s.to_s
    end

    def width(val=nil)
      return self.width=val if val
      return @width
    end

    def width=(w)
      @width = w.to_i
      raise "Bad width" unless w > 0
    end

    def height(val=nil)
      return self.height=val if val
      return @height
    end

    def height=(h)
      @height = h.to_i
      raise "Bad height" unless h > 0
    end

    def format(val=nil)
      return self.format=val if val
      return @format
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
      flags.concat(['--start', @start_at.to_i.to_s]) if @start_at
      if @end_at
        flags.concat(['--end', @end_at.to_i.to_s])
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

    def self.build(&b)
      ret = self.new
      ret.instance_eval(&b)
      return ret
    end
  end
end
