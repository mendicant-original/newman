module Newman  
  class Server
    def self.test_mode(settings_file)
      settings = Settings.from_file(settings_file)
      mailer   = TestMailer.new(settings)

      new(settings, mailer)
    end

    def self.simple(app, settings_file)
      settings = Settings.from_file(settings_file)
      mailer   = Mailer.new(settings)

      server = new(settings, mailer)

      server.run(app)
    end

    def initialize(settings, mailer)
      self.settings = settings
      self.mailer   = mailer
    end

    attr_accessor :settings, :mailer

    def run(app)
      loop do
        tick(app)
        sleep settings.service.polling_interval
      end
    end

    def tick(app)           
      mailer.messages.each do |request|
        response = mailer.new_message(:to   => request.from, 
                                      :from => settings.service.default_sender)

        app.call(:request  => request, 
                 :response => response, 
                 :settings => settings)

        response.deliver
      end
    end
  end
end
