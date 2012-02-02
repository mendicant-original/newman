module Newman
  Server = Object.new

  class << Server
    def run(params)
      settings = params[:settings]
      apps     = params[:apps]

      configure_mailer(settings)

      loop do
        Mail.all(:delete_after_find => true).each do |request|
          response = Mail.new(:to   => request.from, 
                              :from => settings.service.default_sender)

          apps.each do |a| 
            a.call(:request  => request, 
                   :response => response, 
                   :settings => settings)
          end

          response.deliver
        end

        sleep settings.service.polling_interval
      end
    end

    private

    def configure_mailer(settings)
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
