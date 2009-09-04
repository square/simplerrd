module SimpleRRD
  class VDef < Command
    # VDEF:vname=RPN expression
    #  
    # This command returns a value and/or a time according to the RPN
    # statements used. The resulting vname will, depending on the functions
    # used, have a value and a time component.  When you use this vname in
    # another RPN expression, you are effectively inserting its value just as
    # if you had put a number at that place.  The variable can also be used in
    # the various graph and print elements.
    #
    #    Example: "VDEF:avg=mydata,AVERAGE"
    #
    # Note that currently only aggregation functions work in VDEF rpn
    # expressions.  Patches to change this are welcome.
    
    def initialize(opts={})
      @vname          = "obj#{self.object_id}"
      @rpn_expression = nil
    end

    attr_reader :vname, :rpn_expression

    def vname=(n)
      raise "Bad vname: #{n}" unless n.match(VNAME_REGEX)
      @vname = n
    end

    def rpn_expression=(ary)
      raise "Expected Array of RPN terms; got " + ary.class.to_s unless ary.is_a? Array
      clear_dependencies
      ary.each do |term|
        case term
        when Numeric: 
          next
        when Def:     
          add_dependency(term)
        when CDef:
          add_dependency(term)
        when String:
          next if VDEF_FUNCTIONS.include?(term)
          raise "Not a valid VDEF function: #{term}"
        else
          raise "Not sure what to do with a " + term.class.to_s
        end
      end
      @rpn_expression = ary
    end

    def expression_string
      terms = []
      @rpn_expression.each do |t|
        case t
        when Numeric: terms << t
        when Def:     terms << t.vname
        when CDef:    terms << t.vname 
        when String:  terms << t
        else raise "Unexpected term in RPN expression: #{t.inspect}"
        end
      end
      return terms.join(",")
    end

    def definition
      raise "No expression defined" unless @rpn_expression
      return "VDEF:#{vname}=#{expression_string}"
    end
  end
end
