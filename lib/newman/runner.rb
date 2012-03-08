module Newman
  Runner = Object.new
  
  class << Runner
    def start(argv)
      filename, params = parse_options(argv)

      self.basepath      = File.dirname(filename)
      default_settings   = "#{basepath}/config/environment.rb"

      self.server_mode   = params.fetch(:server_mode, :poll)
      self.settings_file = params.fetch(:settings_file, default_settings)
      self.debug_mode    = params.fetch(:debug_mode, false)   

      eval(File.read(filename), binding)
    end

    def run(app)
      server = Newman::Server.simple!(app, settings_file) 
      server.settings.service.debug_mode = true if debug_mode

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

    attr_accessor :basepath, :server_mode, :settings_file, :debug_mode
  end
end
