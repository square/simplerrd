module SimpleRRD
  class Command
    include DependencyTracking
    include OptionsHash
  end

  CONSOLIDATION_FUNCTIONS = ["AVERAGE", "MIN", "MAX", "LAST", "HWPREDICT",
                             "MHWPREDICT", "SEASONAL", "DEVSEASONAL",
                             "DEVPREDICT", "FAILURES"]
  
  DS_NAME_REGEX = /\A[a-zA-Z0-9_]{1,19}\Z/
  VNAME_REGEX   = /\A[a-zA-Z0-9\-_]{1,255}\Z/
  VDEF_FUNCTIONS = ["MAXIMUM", "MINIMUM", "AVERAGE", "STDEV", "LAST", 
                    "FIRST", "TOTAL", "PERCENT", "LSLSLOPE", "LSLINT",
                    "LSLCORREL"]
  CDEF_FUNCTIONS = ["LT", "LE", "GT", "GE", "EQ", "NE", "UN", "ISINF", "IF",
    "MIN", "MAX", "LIMIT", "+", "-", "*", "/", "%", "ADDNAN", "SIN", "COS",
    "LOG", "EXP", "SQRT", "ATAN", "ATAN2", "FLOOR", "CEIL", "DEG2RAD",
    "RAD2DEG", "ABS", "SORT", "REV", "AVG", "TREND", "TRENDNAN", "UNKN",
    "INF", "NEGINF", "PREV", "COUNT", "NOW", "TIME", "LTIME", "DUP", "POP",
    "EXC"]
end

require 'simplerrd/command/def'
require 'simplerrd/command/vdef'
require 'simplerrd/command/cdef'
require 'simplerrd/command/graph'
