# `Newman::ResponseLogger` supports rudimentary response logging functionality, which is
# enabled by default when `Newman::Server.simple` is used to execute your
# applications. 
#
# If you are only interested in making use of this logging functionality and not
# extending it or changing it in some way, you do not need to be familiar with
# the code in this file. Just be sure to note that if you add
# `service.debug_mode = true` to your configuration file, or set the Ruby 
# `$DEBUG` global variable, you will get much more verbose output from 
# Newman's logging system.
#
# `Newman::ResponseLogger` is part of Newman's **internal interface**.

# ---

module Newman  

  # `Newman::ResponseLogger` is implemented as a singleton object and is 
  # completely stateless in nature. It can be added directly as an app to 
  # any `Newman::Server` instance. The `Newman::Server.simple` helper method 
  # automatically places a `ResponseLogger` at the end of the call chain, but 
  # it can be inserted at any point and will output the response email object
  # at that point in the call chain.

  ResponseLogger = Object.new

  class << ResponseLogger
    include EmailLogger

    # ---

    # `Newman::ResponseLogger#call` simply delegates to 
    # `EmailLogger#log_email`, passing it a logger instance, the 
    # `"RESPONSE"` prefix for the log line, and an instance of an email 
    # object. See `Newman::Server.tick` and `Newman::EmailLogger#log_email`
    # for details.

    def call(params)
      log_email(params[:logger], "RESPONSE", params[:response])
    end
  end
end
