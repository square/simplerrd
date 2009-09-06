module SimpleRRD
  class FancyGraph < Graph
    def data(filename, opts={})
      defaults = {:rrdfile => filename, :ds_name => 'value', :cf => 'AVERAGE'}
      return Def.new(defaults.merge(opts))
    end

    def plot(data, text = "")
      max_val = VDef.new(:rpn_expression => [data, 'MAXIMUM'])
      min_val = VDef.new(:rpn_expression => [data, 'MINIMUM'])
      avg_val = VDef.new(:rpn_expression => [data, 'AVERAGE'])

      max_text = GPrint.new(:value => max_val, :text => "Maximum: %8.2lf%s")
      min_text = GPrint.new(:value => max_val, :text => "Minimum: %8.2lf%s")
      avg_text = GPrint.new(:value => max_val, :text => "Average: %8.2lf%s")

      spacer = Comment.new(:text => "\\s")

      color = color_scheme.next
      line = Line.new(:data => data, :text => text,
                      :width => 2,   :color => color)
      area = Area.new(:data => data, :color => color,
                      :alpha => '66')

      add_element(area)
      add_element(line)
      add_element(min_text)
      add_element(avg_text)
      add_element(max_text)
      add_element(spacer)
    end

    def color_scheme(val = nil)
      return @color_scheme = val if val
      return @color_scheme ||= DEFAULT_COLORS
    end

    def color_scheme=(c)
      @color_scheme = c
    end
  end
end
