require "mail"
require "eventmachine"
require "pstore"

module PostalService
  class << self
    attr_accessor :application_dir 

    def run(config_file="config.rb", &callback)
      self.application_dir ||= "#{File.dirname(caller[0][/(.*\.rb)/, 1])}"

      load "#{application_dir}/#{config_file}"
      params = CONFIGURATION_DATA

      application = Object.new
      application.extend(Helpers)

      configure_mailer(params)
      interval = params.fetch(:polling_interval, 10)

      EventMachine.run do
        EventMachine::PeriodicTimer.new(interval) do
          Mail.all(:delete_after_find => true).each do |incoming|
            outgoing = Mail.new(:to   => incoming.from, 
                                :from => params[:default_sender])
            application.instance_exec(incoming, outgoing, &callback)
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

  module Helpers
    def sender(mail)
      mail.from.first.to_s
    end

    def forward(incoming, outgoing)
      outgoing.from      = incoming.from
      outgoing.reply_to  = CONFIGURATION_DATA[:default_sender]
      outgoing.subject   = incoming.subject

      if incoming.multipart?
        outgoing.text_part = incoming.text_part
        outgoing.html_part = incoming.html_part
      else
        outgoing.body = incoming.body.to_s
      end
    end

    def filter(type, pattern)
      case type
      when :to
        ->(mail) { mail.to.any? { |e| e[pattern] } }
      else
        ->(mail) { false }
      end
    end

    def mailing_list(name)
      lists_dir = "#{PostalService.application_dir}/db/lists"
      FileUtils.mkdir_p(lists_dir)
      MailingList.new("#{lists_dir}/#{name}.store")
    end
  end

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
