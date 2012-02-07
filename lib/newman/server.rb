module Newman  
  class Server
    def self.test_mode(settings_file)
      settings = Settings.from_file(settings_file)
      mailer   = TestMailer.new(settings)

      new(settings, mailer)
    end

    def self.simple(app, settings_file)
      settings     = Settings.from_file(settings_file)
      mailer       = Mailer.new(settings)
      server       = new(settings, mailer)
      server.apps = [RequestLogger.new, app, ResponseLogger.new]

      server.run
    end

    def initialize(settings, mailer, logger=nil)
      self.settings = settings
      self.mailer   = mailer
      self.logger   = logger || default_logger
      self.apps     = []
    end

    attr_accessor :settings, :mailer, :apps,  :logger

    def run
      loop do
        tick
        sleep settings.service.polling_interval
      end
    end

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

    private

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
