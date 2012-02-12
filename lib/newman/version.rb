# Newman::Version is used to determine which version of Newman is currently
# running and is part of Newman's **external api**.

module Newman
  module Version
    MAJOR  = 0
    MINOR  = 3
    TINY   = 0
    STRING = "#{MAJOR}.#{MINOR}.#{TINY}"
  end
end
