module Newman
  Server = Object.new  
  
  class << Server
    attr_accessor :settings, :mailer

    def test_mode(settings_file)
      self.settings = Newman::Settings.from_file(settings_file)
      self.mailer   = Newman::TestMailer

      mailer.configure(settings)
    end

    def simple(app, settings_file)
      self.settings = Newman::Settings.from_file(settings_file)
      self.mailer   = Newman::Mailer
      
      mailer.configure(settings)

      run(app)
    end

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
