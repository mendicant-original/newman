# `Newman::Server` takes incoming mesages from a mailer object and passes them
# to applications as a request, and then delivers a response email after the
# applications have modified it.
#
# A `Newman::Server` object can be used in four distinct ways:
#
# 1) Instantiated via `Newman::Server.test_mode` and then run tick by tick
# in integration tests.
# 
# 2) Instantiated via `Newman::Server.simple` which immediately executes
# an infinite polling loop.
#
# 3) Instantiated via `Newman::Server.simple!`, and then run manually (either
# in a loop or by tick), using the same defaults used by `Newman::Server.simple`
#
# 4) Instantiated explicitly and manually configured, for maximum control.
#
# All of these different workflows are supported, but if you are simply looking
# to build applications with `Newman`, you are most likely going to end up using
# either `simple()` or `simple!()` because they care of most of the setup work 
# for you.
#
# `Newman::Server` is part of Newman's **external interface**.

module Newman  
  class Server
    # ---
     
    # `Newman::Server.simple!` automatically generates a `Newman::Mailer` object
    # and `Newman::Settings` object from the provided `settings_file`. These
    # objects are then passed on to `Newman::Server.new` and a server instance
    # is created. 
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
    #     s = Newman::Server.simple!(ping_pong, "config/environment.rb")
    #     # call s.tick or s.run at some later point.
    #
    # Given a proper configuration file, this will make it possible to easily
    # get your applications up and running with simple request and response
    # logging enabled.
    def self.simple!(app, settings_file)
      settings     = Settings.from_file(settings_file)
      mailer       = Mailer.new(settings)
      server       = new(settings, mailer)
      server.apps  = [RequestLogger, app, ResponseLogger]

      server
    end
    
    # ---
     
    # `Newman::Server#simple` is the same as `Newman::Server#simple!`, but
    # automatically starts an infinite polling loop.

    def self.simple(app, settings_file)
      server = simple!(app, settings_file)
      server.run
    end

    # ---
     
    # `Newman::Server.test_mode` automatically generates a `Newman::TestMailer` object
    # and `Newman::Settings` object from the provided `settings_file`. These
    # objects are then passed on to `Newman::Server.new` and a server instance
    # which is preconfigured for use in integration testing is returned.
    #
    # Using the application from the `Newman::Server.simple!` documentation
    # above, it'd be possible to write a simple integration test using this
    # method in the following way:
    #
    #     server = Newman::Server.test_mode("config/environment.rb")
    #     server.apps << ping_pong
    #
    #     mailer = server.mailer
    #     mailer.deliver_message(:to      => "test@test.com",
    #                            :subject => "ping)
    #
    #     server.tick
    #
    #     mailer.messages.first.subject.must_equal("pong")
    #
    # It's worth mentioning that although `Newman::Server.test_mode` is part of
    # Newman's external interface, the `Newman::TestMailer` object is considered part
    # of its internals. This is due to some ugly issues with global state and
    # the overall brittleness of the current implementation. Expect a bit of
    # weirdness if you plan to use this feature, at least until we improve upon
    # it.

    def self.test_mode(settings_file)
      settings = Settings.from_file(settings_file)
      mailer   = TestMailer.new(settings)

      new(settings, mailer)
    end

    # ---
    
    # To initialize a `Newman::Server` object, a settings object and mailer object must
    # be provided.
    # 
    # Instantiating a server object directly can be useful for building live
    # integration tests, or for building cron jobs which process email
    # periodically rather than in a busy-wait loop. See one of Newman's [live
    # tests](https://github.com/mendicant-university/newman/blob/master/examples/live_test.rb)
    # for an example of how this approach works.

    def initialize(settings, mailer)
      self.settings = settings
      self.mailer   = mailer
      self.apps     = []
    end

    # ---
    
    # These accessors are mostly meant for use with server objects under test
    # mode, or server objects that have been explicitly instantiated. If you are
    # using `Newman::Server.simple` to run your apps, it's safe to treat these
    # as an implementation detail; all important data will get passed down
    # into your apps on each `tick`.

    attr_accessor :settings, :mailer, :apps
    attr_writer   :logger

    # ---

    # Returns the logger object that was set via `Newman::Server#logger=`, 
    # or delegates to `default_logger` if no custom logger was provided.
    #
    def logger
      @logger || default_logger
    end

    # ---

    # `Newman::Server.run` kicks off a busy wait loop, alternating between
    # calling `Newman::Server.tick` and sleeping for the amount of time
    # specified by `settings.service.polling_interval`. We originally planned to
    # use an EventMachine periodic timer here to potentially make running
    # several servers within a single process easier, but had trouble coming up
    # with a use case that made the extra dependency worth it.

    def run
      loop do
        tick
        sleep settings.service.polling_interval
      end
    end

    # ---
    
    # `Newman::Server.tick` runs the following sequence for each incoming
    # request. 
    #
    # 1) A response is generated with the TO field set to the FROM field of the
    # request, and the FROM field set to `settings.service.default_sender`.
    # Applications can change these values later, but these are sensible
    # defaults that work for most common needs.
    #
    # 2) The list of `apps` is iterated over sequentially, and each
    # application's `call` method is invoked with a parameters hash which
    # include the `request` email, the `response` email, the `settings` object
    # being used by the server, and the `logger` object being used by the
    # server.
    #
    # 2a) If any application raises an exception, that exception is caught and
    # the processing of the current request is halted. Details about the failure
    # are logged and if `settings.service.raise_exceptions` is enabled, the
    # exception is re-raised, typically taking the server down with it. This
    # setting is off by default.
    #
    # 2b) If there are any server errors (such as an error retrieving messages
    # via IMAP), those  errors are logged and re-raised, taking the server 
    # down. Currently, you should use a process watcher to restart
    # Newman to protect against such failures, but be careful about restarting
    # without knowing what went wrong!
    #
    # 3) Assuming an exception is not encountered, the response is delivered.

    def tick         
      mailer.messages.each do |request| 
        response = mailer.new_message(:to   => request.from, 
                                      :from => settings.service.default_sender)

        process_request(request, response) && response.deliver
      end
    rescue Exception => e
      logger.fatal("SERVER ERROR") { "#{e.inspect}\n" + e.backtrace.join("\n  ") }
      raise
    end

    # ---

    # **NOTE: Methods below this point in the file are implementation 
    # details, and should not be depended upon**

    private

    # ---
   
    # Implementation details for `Newman::Server#tick`. Check its documentation
    # for details.
   
    def process_request(request, response)
      apps.each do |app|
        app.call(:request  => request, 
                 :response => response, 
                 :settings => settings,
                 :logger   => logger)
      end

      return true
    rescue StandardError => e
      if settings.service.raise_exceptions
        raise
      else
        logger.info("APP ERROR")  { e.inspect }
        logger.debug("APP ERROR") { "#{e.inspect}\n" + e.backtrace.join("\n  ") }

        return false
      end
    end
    
    # ---

    # `Newman::Server#default_logger` generates a logger object using 
    # Ruby's standard library. This object outputs to `STDERR`, and
    # runs at info level by default, but will run at debug level if 
    # either `settings.service.debug_mode` or the Ruby `$DEBUG`
    # variable is set.

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
