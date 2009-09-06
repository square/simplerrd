module SimpleRRD
  class ColorScheme
    def initialize(*colors)
      @colors = colors
      @num    = colors.length
      @index  = 0
    end

    def next
      index = @index % @num
      @index += 1
      return @colors[index]
    end
  end

  # a selection of colors from http://colorbrewer2.org/
  DEFAULT_COLORS = ColorScheme.new("1F78B4", # blue
                                   "33A02C", # green
                                   "FF7F00", # orange
                                   "6A3D9A", # purple
                                   "E31A1C", # red
                                   "B15928") # brown
end
