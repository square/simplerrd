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
    
    include VName
    include RPNExpressionAttribute
    include HashToMethods

    def initialize(opts={})
      call_hash_methods(opts)
    end

    def allowed_functions 
      VDEF_FUNCTIONS
    end

    def definition
      raise "No expression defined" unless @rpn_expression
      return "VDEF:#{vname}=#{expression_string}"
    end
  end
end
