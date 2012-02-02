module Newman
  Server = Object.new  
  
  class << Server
    attr_accessor :settings, :mailer

    def test_mode(settings_file)
      self.settings = Newman::Settings.from_file(settings_file)
      self.mailer   = Newman::TestMailer

      mailer.configure(settings)
    end

    # loads settings from a file and configures mailer
    def simple(apps, settings_file)
      self.settings = Newman::Settings.from_file(settings_file)
      self.mailer   = Newman::Mailer
      
      mailer.configure(settings)

      run(apps)
    end

    def run(apps)
      loop do
        tick(apps)
        sleep settings.service.polling_interval
      end
    end

    def tick(apps)           
      mailer.messages.each do |request|
        response = mailer.new_message(:to   => request.from, 
                                      :from => settings.service.default_sender)

        Array(apps).each do |a| 
          a.call(:request  => request, 
                 :response => response, 
                 :settings => settings)
        end

        response.deliver
      end
    end
  end
end
