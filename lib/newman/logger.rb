require "logger"

module Newman
  module EmailLogger
    def log(logger, prefix, email)
      logger.debug(prefix) { "\n#{email}" }
      logger.info(prefix) { summary(email) }
    end

    private
    
    def summary(email)
      { :from     => email.from,
        :to       => email.to,
        :bcc      => email.bcc,
        :subject  => email.subject,
        :reply_to => email.reply_to }
    end
  end

  class RequestLogger 
    include EmailLogger

    def call(params)
      log(params[:logger], "REQUEST", params[:request])
    end
  end

  class ResponseLogger
    include EmailLogger

    def call(params)
      log(params[:logger], "RESPONSE", params[:response])
    end
  end
end
