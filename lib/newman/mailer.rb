module Newman
  class Mailer
    def initialize(settings)
      imap = settings.imap
      smtp = settings.smtp

      self.retriever_settings = {
           :address    => imap.address,
           :user_name  => imap.user,
           :password   => imap.password,
           :enable_ssl => imap.ssl_enabled || false,
           :port       => imap.port
      }
      
      self.delivery_settings = {
           :address              => smtp.address,
           :user_name            => smtp.user,
           :password             => smtp.password,
           :authentication       => :plain,
           :enable_starttls_auto => smtp.starttls_enabled || false,
           :port                 => smtp.port
      }
    end
    
    def messages
      Mail::IMAP.new(retriever_settings).all(:delete_after_find => true)
    end

    def new_message(*a, &b)
      msg = Mail.new(*a, &b)
      msg.delivery_method(:smtp, delivery_settings)

      msg
    end

    def deliver_message(*a, &b)
      new_message(*a, &b).deliver
    end

    private

    attr_accessor :retriever_settings, :delivery_settings
  end
end
