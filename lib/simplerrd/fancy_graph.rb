module SimpleRRD
  class FancyGraph < Graph
    def data(filename, opts={})
      defaults = {:rrdfile => filename, :ds_name => 'value', :cf => 'AVERAGE'}
      return Def.new(defaults.merge(opts))
    end

    def color_scheme(val = nil)
      return @color_scheme = val if val
      return @color_scheme ||= DEFAULT_COLORS
    end

    def color_scheme=(c)
      @color_scheme = c
    end

    def line_break
      return Comment.new(:text => "\\n")
    end

    def spacer
      return Comment.new(:text => "\\s")
    end

    def compact
      return !(height && height > 200)
    end

    def summary_elements(data)
      max_val = VDef.new(:rpn_expression => [data, 'MAXIMUM'])
      min_val = VDef.new(:rpn_expression => [data, 'MINIMUM'])
      avg_val = VDef.new(:rpn_expression => [data, 'AVERAGE'])

      max_text = GPrint.new(:value => max_val, :text => "Maximum: %8.2lf%S")
      min_text = GPrint.new(:value => min_val, :text => "Minimum: %8.2lf%S")
      avg_text = GPrint.new(:value => avg_val, :text => "Average: %8.2lf%S")

      return [min_text, max_text, avg_text]
    end

    def plot(data, text = "")
      color = color_scheme.next
      line = Line.new(:data => data, :text => text,
                      :width => 2,   :color => color)
      area = Area.new(:data => data, :color => color,
                      :alpha => '66')

      add_element(area)
      add_element(line)
      unless compact
        summary_elements(data).each { |e| add_element(e) } unless compact
        add_element(line_break)
      end
    end

    def stack_plot(*elements)
      stack_height = nil
      elements.each do |ary|
        (data, text) = ary
        color = color_scheme.next
        if stack_height
          stack_height = CDef.new(:rpn_expression => [stack_height,data,'+'])
        else
          stack_height = data
        end
        area = Area.new(:data => data, :color => color,
                        :alpha => '66', :stack => true)
        line = Line.new(:data => stack_height, :text => text,
                        :width => 2,   :color => color)
        add_element(area)
        add_element(line)
        unless compact
          summary_elements(data).each { |e| add_element(e) } unless compact
          add_element(line_break)
        end
      end
      add_element(line_break)
    end
  end
end
