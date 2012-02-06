module Newman
  Mailer = Object.new

  class << Mailer
    RETRIEVER_PROTOCOL = :imap
    SENDER_PROTOCOL    = :smtp
    
    def configure(settings)
      imap = settings.imap
      smtp = settings.smtp

      @retriever_settings = {
           :address    => imap.address,
           :user_name  => imap.user,
           :password   => imap.password,
           :enable_ssl => imap.ssl_enabled || false,
           :port       => imap.port
      }
      
      @delivery_settings = {
           :address              => smtp.address,
           :user_name            => smtp.user,
           :password             => smtp.password,
           :authentication       => :plain,
           :enable_starttls_auto => smtp.starttls_enabled || false,
           :port                 => smtp.port
      }
      
    end
    
    def messages
      retriever.all(:delete_after_find => true)
    end

    def new_message(*a, &b)
      Mail.new(*a, &b).tap do |msg| 
        msg.delivery_method SENDER_PROTOCOL, delivery_settings
      end
    end

    def deliver_message(*a, &b)
      new_message(*a, &b).deliver
    end

    def retriever_class
      @retriever_class ||= 
        Mail::Configuration.instance.lookup_delivery_method(RETRIEVER_PROTOCOL)
    end
    
    def retriever
      retriever_class.new(retriever_settings)
    end
    
    attr_accessor :settings
    
    def delivery_settings;  @delivery_settings  ||= {}; end
    def retriever_settings; @retriever_settings ||= {}; end
    
  end
end
