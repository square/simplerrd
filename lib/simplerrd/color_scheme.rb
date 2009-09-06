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
  DEFAULT_COLORS = ColorScheme.new("377EB8",
                                   "4DAF4A",
                                   "984EA3",
                                   "FF7F00",
                                   "FFFF33",
                                   "E41A1C",
                                   "A65628",
                                   "F781BF",
                                   "999999" )
end
