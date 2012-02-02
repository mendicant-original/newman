module Newman
  Mailer = Object.new

  class << Mailer
    def configure(settings)
      imap = settings.imap
      smtp = settings.smtp

      Mail.defaults do
         retriever_method :imap, 
           :address    => imap.address,
           :user_name  => imap.user,
           :password   => imap.password,
           :enable_ssl => imap.ssl_enabled || false,
           :port       => imap.port

         delivery_method :smtp,
           :address              => smtp.address,
           :user_name            => smtp.user,
           :password             => smtp.password,
           :authentication       => :plain,
           :enable_starttls_auto => smtp.starttls_enabled || false,
           :port                 => smtp.port
      end

      def messages
        Mail.all(:delete_after_find => true)
      end

      def new_message(*a, &b)
        Mail.new(*a, &b)
      end

      def deliver_message(*a, &b)
        new_message(*a, &b).deliver
      end
    end

    attr_accessor :settings
  end
end
