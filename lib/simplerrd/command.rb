module SimpleRRD
  class Command
    include DependencyTracking
  end

  CONSOLIDATION_FUNCTIONS = ["AVERAGE", "MIN", "MAX", "LAST", "HWPREDICT",
                             "MHWPREDICT", "SEASONAL", "DEVSEASONAL",
                             "DEVPREDICT", "FAILURES"]
  
  DS_NAME_REGEX = /\A[a-zA-Z0-9_]{1,19}\Z/
  VNAME_REGEX   = /\A[a-zA-Z0-9\-_]{1,255}\Z/
end

require 'simplerrd/command/def'
