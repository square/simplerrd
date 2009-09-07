module SimpleRRD
  class Graph
    include OptionsHash
    
    ALLOWED_FORMATS=["SVG", "PNG", "EPS", "PDF"]

    def initialize(opts={})
      @start_at    = nil
      @end_at      = nil
      @title       = nil
      @width       = nil
      @height      = nil
      @format      = nil
      @lower_limit = 0
      @upper_limit = nil
      @elements    = []

      call_hash_methods(opts)
    end

    attr_reader :elements

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

    def lower_limit(val=nil)
      return @lower_limit = val if val
      return @lower_limit
    end

    def lower_limit=(val)
      raise "Lower limit should be a number (or nil); got #{val}" if val && !val.is_a?(Numeric)
      @lower_limit = val
    end

    def upper_limit(val=nil)
      return @upper_limit = val if val
      return @upper_limit
    end

    def upper_limit=(val)
      raise "Upper limit should be a number (or nil); got #{val}" if val && !val.is_a?(Numeric)
      @upper_limit = val
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
      flags.concat(['--lower-limit', @lower_limit.to_s]) unless @lower_limit.nil?
      flags.concat(['--upper-limit', @lower_limit.to_s]) unless @upper_limit.nil?
      flags.concat(['--title', @title]) if @title
      flags.concat(['--width', @width.to_s]) if @width
      flags.concat(['--height', @height.to_s]) if @height
      flags.concat(['--full-size-mode']) if @width or @height
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
