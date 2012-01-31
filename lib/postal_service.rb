require "mail"
require "eventmachine"

module PostalService
  class << self
    def run(params)
      configure_mailer(params)
      interval = params.fetch(:polling_interval, 10)

      EventMachine.run do
        EventMachine::PeriodicTimer.new(interval) do
          Mail.all(:delete_after_find => true).each do |incoming|
            outgoing = Mail.new(:to   => incoming.from, 
                                :from => params[:default_sender])
            yield(incoming, outgoing)
            outgoing.deliver
          end
        end
      end
    end

    def configure_mailer(params)
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
end
