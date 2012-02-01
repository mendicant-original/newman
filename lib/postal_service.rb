require "mail"
require "tilt"

module PostalService
  Server = Object.new

  class << Server
    def run(params)
      config = params[:config]
      apps   = params[:apps]

      configure_mailer(config)

      loop do
        sleep config[:polling_interval]

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
      end
    end

    private

    def configure_mailer(config_data)
      Mail.defaults do
        retriever_method :imap, 
          :address    => config_data[:imap_address],
          :user_name  => config_data[:imap_user],
          :password   => config_data[:imap_password]

        delivery_method :smtp,
          :address              => config_data[:smtp_address], 
          :user_name            => config_data[:smtp_user],
          :password             => config_data[:smtp_password],
          :authentication       => :plain,
          :enable_starttls_auto => false
      end
    end
  end

  module Commands
    def to(pattern_type, pattern, &callback)
      raise NotImplementedError unless pattern_type == :tag

      matcher = lambda do
        request.to.any? { |e| e[/\+#{pattern}@#{Regexp.escape(domain)}/] } 
      end

      callbacks << { :matcher  => matcher, :callback => callback }
    end

    def default(&callback)
      self.default_callback = callback
    end

    def trigger_callbacks(controller)
      matched_callbacks = callbacks.select do |e| 
        matcher = e[:matcher]
        controller.instance_exec(&matcher)
      end

      if matched_callbacks.empty?
        controller.instance_exec(&default_callback)
      else
        matched_callbacks.each do |e|
          callback = e[:callback]
          controller.instance_exec(&callback)
        end
      end
    end
  end

  class Application
    include Commands

    def initialize(&block)
      self.callbacks  = []

      instance_eval(&block) if block_given?
    end

    def call(params)
      controller = Controller.new(params)      
      trigger_callbacks(controller)
    end

    private

    attr_accessor :callbacks, :default_callback
  end

  class Controller
    def initialize(params)
      self.config   = params.fetch(:config)
      self.request  = params.fetch(:request)
      self.response = params.fetch(:response)
    end

    def respond(params)
      params.each { |k,v| response.send("#{k}=", v) }
    end

    def template(name)
      Tilt.new(Dir.glob("#{config[:templates_dir]}/#{name}.*").first)
          .render(self)
    end

    def sender
      request.from.first.to_s
    end

    def domain
      config[:domain]
    end

    def forward_message(params={})
      response.from      = request.from
      response.reply_to  = config[:default_address]
      response.subject   = request.subject

      response.bcc = params[:bcc] if params[:bcc]

      if request.multipart?
        response.text_part = request.text_part
        response.html_part = request.html_part
      else
        response.body = request.body.to_s
      end
    end

    private

    attr_accessor :config, :request, :response
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
