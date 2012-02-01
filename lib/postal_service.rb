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

  require "pstore"

  class MailingList
    def initialize(filename)
      self.store = PStore.new(filename)
      db { store[:subscribers] ||= [] }
    end

    def subscribe(email)
      db { store[:subscribers] |= [email] }
    end

    def unsubscribe(email)
      db { store[:subscribers].delete(email) }
    end

    def subscriber?(email)
      db(:readonly) { store[:subscribers].include?(email) }
    end

    def subscribers
      db(:readonly) { store[:subscribers] }
    end

    private

    attr_accessor :store

    def db(read_only=false)
      store.transaction(read_only) { yield }
    end
  end
end
