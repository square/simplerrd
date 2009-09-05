# miscellaneous mixins
module SimpleRRD
  # useful for setting options in a hash passed to the constructor
  module HashToMethods
		def initialize(opts = {})
			call_hash_methods(opts)
		end

    def call_hash_methods(hsh)
      hsh.keys.each do |k|
        self.send("#{k}=", hsh[k])
      end
    end
  end

	# contains the structures necessary to track dependencies
	# (eg, between RRD commands)
  module DependencyTracking
    def dependencies
      @dependencies ||= []
    end

    def add_dependency(other)
      dependencies << other
    end

    def all_dependencies
      all_deps = []
      dependencies.each do |dep|
        all_deps.concat(dep.all_dependencies)
        all_deps << dep
      end
      return all_deps.uniq # horribly ineffecient. sigh.
    end
		
		def clear_dependencies
			@dependencies = []
		end
  end

	# common stuff to setting and getting RPN expression vnames
	module VName
		def vname
			@vname ||= "obj#{self.object_id}"
		end

    def vname=(n)
      raise "Bad vname: #{n}" unless n.match(VNAME_REGEX)
      @vname = n
    end
	end

	# handles getting and setting RPN expressions
	# note that almost no sanity checks are performed: it's 
	# up to you to make sensible expressions...
	module RPNExpressionAttribute 
		def rpn_expression 
			@rpn_expression ||= nil
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
        when VDef:
          add_dependency(term)
        when CDef:
          add_dependency(term)
        when String:
          next if allowed_functions.include?(term)
          raise "Not an allowed function: #{term}"
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
        when VDef:    terms << t.vname 
        when CDef:    terms << t.vname 
        when String:  terms << t
        else raise "Unexpected term in RPN expression: #{t.inspect}"
        end
      end
      return terms.join(",")
    end
	end

	module TextAttribute
		def text
			@text ||= nil
		end

		def text=(t)
			raise "Strings containing \\: are not supported" if t.include?('\:')
			@text = t.gsub(':', '\:')
		end
	end

	module ValueAttribute
		def value
			@value ||= nil
		end

		def value=(v)
			raise "Expected a VDef; got " + v.class.to_s unless v.is_a?(VDef)
			@value = v
			add_dependency(v)
		end
	end

	module DataAttribute
		def data
			@data ||= nil
		end

		def data=(v)
			raise "Expected a Def or CDef; got " + v.class.to_s unless v.is_a?(CDef) or v.is_a?(Def)
			@data = v
			add_dependency(v)
		end
	end

	module ColorAttribute
		def color
			@color ||= "FFFFFF"
		end

		def color=(c)
			if c == :invisible or c.to_s.match(/\A[0-9a-fA-F]{6,6}\Z/)
				@color = c 
			else
				raise "Bad color specification: #{c}" 
			end
		end
	end
end
