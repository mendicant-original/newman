require "mail"

module PostalService
  def self.run(params)
    configure_mailer(params)

    loop do
      sleep params.fetch(:polling_interval, 10)
      Mail.all(:delete_after_find => true).each do |incoming|
        outgoing = Mail.new(:to => incoming.from, :from => params[:default_sender])
        yield(incoming, outgoing)
        outgoing.deliver
      end
    end
  end

  def self.configure_mailer(params)
    Mail.defaults do
      retriever_method :imap, 
        :address    => params[:imap_address],
        :user_name  => params[:imap_user],
        :password   => params[:imap_password]

      delivery_method :smtp,
        :address              => params[:smtp_address], 
        :user_name            => params[:smtp_user],
        :password             => params[:smtp_password],
        :authentication       => :plain,
        :enable_starttls_auto => false
    end
  end
end
