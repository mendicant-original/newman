# `Newman::EmailLogger` provides rudimentary logging support for email objects,
# and primarily exists to support the `Newman::RequestLogger` and
# `Newman::ResponseLogger` objects.
#
# If you are only interested in making use of this logging functionality and not
# extending it or changing it in some way, you do not need to be familiar with
# the code in this file. Just be sure to note that if you add
# `service.debug_mode = true` to your configuration file, or set the Ruby 
# `$DEBUG` global variable, you will get much more verbose output from 
# Newman's logging system.
#
# `Newman::EmailLogger` is part of Newman's **internal interface**.

module Newman
  module EmailLogger

    # ---
    
    # `Newman::EmailLogger#log_email` takes a logger object, a prefix, and a `Mail` object and 
    # then outputs relevant debugging details. 
    #
    # This method always at least provides a summary of the provided `email`
    # at the `INFO` level When in debugging mode, the full contents of 
    # the `email` will also gets logged.
    #
    # The main purpose of this method is to be used by `Newman::RequestLogger`
    # and `Newman::ResponseLogger`, but may also optionally be used as a helper
    # for those who are rolling their own logging functionality.

    def log_email(logger, prefix, email)
      logger.debug(prefix) { "\n#{email}" }
      logger.info(prefix) { email_summary(email) }
    end

    # ---
    
    # **NOTE: Methods below this point in the file are implementation details, 
    # and should not be depended upon**
    
    private

    # ---
    
    # `Newman::EmailLogger#email_summary` returns a hash with a summary of the provided `email` object. 

    def email_summary(email)
      { :from     => email.from,
        :to       => email.to,
        :bcc      => email.bcc,
        :subject  => email.subject,
        :reply_to => email.reply_to }
    end
  end
end
