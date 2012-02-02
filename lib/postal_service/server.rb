module PostalService
  Server = Object.new

  class << Server
    def run(params)
      config = params[:config]
      apps   = params[:apps]

      configure_mailer(config)

      loop do
        Mail.all(:delete_after_find => true).each do |request|
          response = Mail.new(:to   => request.from, 
                              :from => config[:default_address])

          apps.each do |a| 
            a.call(:request  => request, 
                   :response => response, 
                   :config   => config)
          end

          response.deliver
        end

        sleep config[:polling_interval]
      end
    end

    private

    def configure_mailer(config_data)
      Mail.defaults do
        retriever_method :imap, 
          :address    => config_data[:imap_address],
          :user_name  => config_data[:imap_user],
          :password   => config_data[:imap_password],
          :enable_ssl => config_data.fetch(:imap_enable_ssl, false),
          :port       => config_data.fetch(:imap_port, nil)

        delivery_method :smtp,
          :address              => config_data[:smtp_address],
          :user_name            => config_data[:smtp_user],
          :password             => config_data[:smtp_password],
          :authentication       => :plain,
          :enable_starttls_auto => config_data.fetch(:smtp_starttls, false),
          :port                 => config_data.fetch(:smtp_port, nil)
      end
    end
  end
end
