module SimpleRRD
  class Graph
    include OptionsHash
    
    ALLOWED_FORMATS=["SVG", "PNG", "EPS", "PDF"]
    
    attr_writer :no_full_size_mode

    def initialize(opts={})
      @start_at    = nil
      @end_at      = nil
      @title       = nil
      @width       = nil
      @height      = nil
      @format      = nil
      @lower_limit = nil
      @upper_limit = nil
      @exponent    = nil
      @rigid       = nil
      @y_label     = nil
      @y2_scale    = nil
      @y2_shift    = nil
      @y2_label    = nil
      @font        = nil
      @elements    = []
      @no_full_size_mode = nil

      call_hash_methods(opts)
    end

    attr_reader :elements

    def start_at(val=nil)
      return self.start_at=val if val
      return @start_at
    end

    def start_at=(t)
      raise "Expected Time; got " + t.class.to_s unless t.is_a?(Time)
      raise "Start must be before end" if end_at and end_at < t
      @start_at = t
    end

    def end_at(val=nil)
      return self.end_at=val if val
      return @end_at
    end

    def end_at=(t)
      raise "Expected Time; got " + t.class.to_s unless t.is_a?(Time)
      raise "End must be after start" if start_at and start_at > t
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
      w = w.to_i
      raise "Bad width" unless w > 0
      return @width = w
    end

    def height(val=nil)
      return self.height=val if val
      return @height
    end

    def height=(h)
      h=h.to_i
      raise "Bad height" unless h > 0
      return @height = h
    end

    def lower_limit(val=nil)
      return self.lower_limit = val if val
      return @lower_limit
    end

    def lower_limit=(val)
      raise "Lower limit should be a number (or nil); got #{val}" if val && !val.is_a?(Numeric)
      @lower_limit = val
      self.rigid = true if self.rigid.nil?
    end

    def upper_limit(val=nil)
      return self.upper_limit = val if val
      return @upper_limit
    end

    def upper_limit=(val)
      raise "Upper limit should be a number (or nil); got #{val}" if val && !val.is_a?(Numeric)
      @upper_limit = val
      self.rigid = true if self.rigid.nil?
    end

    def rigid(val=nil)
      return self.rigid = val unless (val.nil?)
      return @rigid
    end

    def rigid=(val)
      @rigid = (not (val == false))
    end

    def exponent(val=nil)
      return self.exponent = val if val
      return @exponent
    end

    def exponent=(val)
      raise "Exponent should be a number (or nil); got #{val}" if val && !val.is_a?(Numeric)
      @exponent = val
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

    def font(*vals)
      font = Array(vals)
      return self.font = font unless font.empty?
      return @font
    end

    def font=(f)
      @font = "DEFAULT:#{f.size == 1 ? "0:#{f}" : f.reverse.join(":")}"
    end

    def y_label(val=nil)
      return self.y_label = val if val
      return @y_label
    end

    def y_label=(val)
      return @y_label = val.to_s unless val.nil?
      return @y_label = val
    end

    def y2_scale(val=nil)
      return self.y2_scale = val if val
      return @y2_scale
    end

    def y2_scale=(val)
      raise "Y2 scale should be a number (or nil); got #{val}" if val && !val.is_a?(Numeric)
      @y2_scale = val
    end

    def y2_shift(val=nil)
      return self.y2_shift = val if val
      return @y2_shift
    end

    def y2_shift=(val)
      raise "Y2 shift should be a number (or nil); got #{val}" if val && !val.is_a?(Numeric)
      @y2_shift = val
    end

    def y2_label(val=nil)
      return self.y2_label = val if val
      return @y2_label
    end

    def y2_label=(val)
      return @y2_label = val.to_s unless val.nil?
      return @y2_label = val
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
      flags.concat(['--font', @font.to_s]) unless @font.nil?
      flags.concat(['--lower-limit', @lower_limit.to_s]) unless @lower_limit.nil?
      flags.concat(['--upper-limit', @upper_limit.to_s]) unless @upper_limit.nil?
      flags.concat(['--rigid']) if @rigid
      flags.concat(['--units-exponent', @exponent.to_s]) unless @exponent.nil?
      flags.concat(['--title', @title]) if @title
      flags.concat(['--width', @width.to_s]) if @width
      flags.concat(['--height', @height.to_s]) if @height
      flags.concat(['--vertical-label', @y_label]) if @y_label
      if @y2_scale and @y2_shift
        flags.concat(['--right-axis', "#{y2_scale}:#{y2_shift}"])
        flags.concat(['--right-axis-label', @y2_label.to_s]) if @height
      end
      flags.concat(['--full-size-mode']) if (@width or @height) && !@no_full_size_mode
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
      Runner.run(*rrdtool_command(filename))
    end

    def rrdtool_command(filename)
      cmd = ['rrdtool', 'graph', filename]
      cmd.concat(command_flags)
      cmd.concat(command_expressions)
      cmd
    end

    def self.build(&b)
      ret = self.new
      ret.instance_eval(&b)
      return ret
    end
  end
end
