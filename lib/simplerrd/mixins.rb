# miscellaneous mixins
module SimpleRRD
  # useful for setting options in a hash passed to the constructor
  module HashToMethods
    def call_hash_methods(hsh)
      hsh.keys.each do |k|
        self.send("#{k}=", hsh[k])
      end
    end
  end

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
  end
end
