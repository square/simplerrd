module SimpleRRD
  class RRDFile
    def initialize(filename)
      @filename = filename
    end
    attr_reader :filename
  end
end
