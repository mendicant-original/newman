# `Newman::Server` takes incoming mesages from a mailer object and passes them
# to applications as a request, and then delivers a response email after the
# applications have had a chance to modify it.
#
# A `Newman::Server` object can be used in a three distinct ways:
#
# 1) Instantiated via `Newman::Server.test_mode` and then run tick by tick
# in integration tests.
# 
# 2) Instantiated via `Newman::Server.simple` which immediately executes
# an infinite polling loop.
# 
# 3) Instantiated explicitly and manually configured, for maximum control.
#
# All of these different workflows are supported, but if you are simply looking
# to build applications with `Newman`, you are most likely going to end up using
# `Newman::Server.simple` because it takes care of most of the setup work for
# you and is the easiest way to run a single Newman application.
#
# `Newman::Server` is part of Newman's **external interface**.

module Newman  
  class Server
    # ---
    
    # `Newman::Server.simple` automatically generates a `Newman::Mailer` object
    # and `Newman::Settings` object from the privded `settings_file`. These
    # objects are then passed on to `Newman::Server.new` and a server instance
    # is created. The server object is set up to run the specified `app`, with
    # request and response logging support enabled. Calling this method puts
    # the server in an infinite polling loop, because its final action is to
    # call `Newman::Server.run`.
    #
    # The following example demonstrates how to use this method:
    #
    #     ping_pong = Newman::Application.new do
    #       subject(:match, "ping") do
    #         respond(:subject => "pong")
    #       end
    #
    #       default do
    #         respond(:subject => "You missed the ball!")
    #       end
    #     end 
    #
    #     Newman::Server.simple(ping_pong, "config/environment.rb")
    #
    # Given a properly configured settings file, this code will launch a polling
    # server and run the simple `ping_pong` application.
    
    def self.simple(app, settings_file)
      settings     = Settings.from_file(settings_file)
      mailer       = Mailer.new(settings)
      server       = new(settings, mailer)
      server.apps = [RequestLogger, app, ResponseLogger]

      server.run
    end

    # ---
    
    # `Newman::Server.test_mode` automatically generates a `Newman::TestMailer` object
    # and `Newman::Settings` object from the provided `settings_file`. These
    # objects are then passed on to `Newman::Server.new` and a server instance
    # which is preconfigured for use in integration testing is returned.
    #
    # Using the application from the `Newman::Server.simple` documentation
    # above, it'd be possible to write a simple integration test using this
    # method in the following way:
    #
    #    server = Newman::Server.test_mode("config/environment.rb")
    #    server.apps << ping_pong
    #
    #    mailer = server.mailer
    #
    #    mailer.deliver_message(:to      => "test@test.com",
    #                           :subject => "ping)
    #
    #    server.tick
    #
    #    mailer.messages.first.subject.must_equal("pong")
    
    def self.test_mode(settings_file)
      settings = Settings.from_file(settings_file)
      mailer   = TestMailer.new(settings)

      new(settings, mailer)
    end

    # ---
    
    # TODO
    
    def initialize(settings, mailer, logger=nil)
      self.settings = settings
      self.mailer   = mailer
      self.logger   = logger || default_logger
      self.apps     = []
    end

    # ---
    
    # TODO

    attr_accessor :settings, :mailer, :apps,  :logger

    # ---
    
    # TODO

    def run
      loop do
        tick
        sleep settings.service.polling_interval
      end
    end

    # ---
    
    # TODO

    def tick         
      mailer.messages.each do |request|        
        response = mailer.new_message(:to   => request.from, 
                                      :from => settings.service.default_sender)
        
        begin
          apps.each do |app|
            app.call(:request  => request, 
                     :response => response, 
                     :settings => settings,
                     :logger   => logger)
          end
        rescue StandardError => e
          logger.info("FAIL") { e.to_s }
          logger.debug("FAIL") { "#{e.inspect}\n"+e.backtrace.join("\n  ") }

          if settings.service.raise_exceptions
            raise
          else
            next
          end
        end

        response.deliver
      end
    end

    # ---
    
    # TODO

    private

    # ---
    
    # TODO

    def default_logger
      self.logger = Logger.new(STDERR)

      if settings.service.debug_mode || $DEBUG
        logger.level = Logger::DEBUG
      else
        logger.level = Logger::INFO
      end

      logger
    end
  end
end
