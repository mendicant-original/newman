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
        log("REQUEST from #{request.from} to #{request.to}. "+
            "Subject: #{request.subject.inspect}")
        
        response = mailer.new_message(:to   => request.from, 
                                      :from => settings.service.default_sender)

        begin
          app.call(:request  => request, 
                   :response => response, 
                   :settings => settings)
        rescue StandardError => e
          log("ERROR: #{e.inspect}\n"+e.backtrace.join("\n  "))
          next
        end

        response.deliver

        log("RESPONSE from #{response.from} to #{response.to}. "+
           "Subject: #{response.subject.inspect}, "+
           "Bcc: #{response.bcc.inspect}, "+
           "Reply To: #{response.reply_to.inspect}")
      end
    end


    private

    def log(message)
      STDERR.puts("#{message}\n\n") if settings.service.debug_mode
    end
  end
end
