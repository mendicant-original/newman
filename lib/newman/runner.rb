module Newman
  Runner = Object.new
  
  class << Runner
    def start(argv)
      filename, params = parse_options(argv)

      self.basepath    = File.dirname(filename)

      self.server_mode = params.fetch(:server_mode, :poll)
      
      settings_file    = params.fetch(:settings_file, "#{basepath}/config/environment.rb")
      self.settings    = Newman::Settings.from_file(settings_file)

      settings.service.debug_mode = true if params[:debug_mode]

      eval(File.read(filename), binding)
    end

    def run(apps)
      server = Newman::Server.new(settings, Newman::Mailer.new(settings)) 
      server.apps << Newman::RequestLogger
      server.apps += Array(apps)
      server.apps << Newman::ResponseLogger

      case server_mode
      when :poll
        server.run
      when :tick
        server.tick
      end
    end

    def require_relative(path)
      require "./#{basepath}/#{path}"
    end

    private

    def parse_options(argv)
      params = {}

      parser = OptionParser.new
      parser.on("--config CONFIG") { |file| params[:settings_file] = file }
      parser.on("--tick") { params[:server_mode] = :tick }
      parser.on("--debug") { params[:debug_mode] = true }

      runner_file = parser.parse(argv).first
      [runner_file, params]
    end

    attr_accessor :settings, :basepath, :server_mode
  end
end
