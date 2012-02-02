module Newman
  class Server
    def initialize(settings)
      self.settings = settings

      configure_mailer
    end

    def run(*apps)
      loop do
        tick(*apps)
        sleep settings.service.polling_interval
      end
    end

    def tick(*apps)
      apps = Array(*apps)
           
      inbox.each do |request|
        response = Mail.new(:to   => request.from, 
                            :from => settings.service.default_sender)

        apps.each do |a| 
          a.call(:request  => request, 
                 :response => response, 
                 :settings => settings)
        end

        response.deliver
      end
    end

    private

    attr_accessor :settings

    def inbox
      if settings.service.test_mode 
        deliveries = Marshal.load(Marshal.dump(Mail::TestMailer.deliveries))
        Mail::TestMailer.deliveries.clear
        deliveries
      else
        Mail.all(:delete_after_find => true)
      end
    end

    def configure_mailer
      if settings.service.test_mode
        Mail.defaults do
          retriever_method :test
          delivery_method  :test
        end
      else
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
      end
    end
  end
end
