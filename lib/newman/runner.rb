module Newman
  Runner = Object.new
  
  class << Runner
    def start(argv)
      filename, params = parse_options(argv)

      self.basepath    = File.dirname(filename)
      self.config      = params.fetch(:config, "#{basepath}/config/environment.rb")
      self.server_mode = params.fetch(:server_mode, :poll)

      eval(File.read(filename), binding)
    end

    def run(apps)
      case server_mode
      when :poll
        Newman::Server.simple(apps, config)
      when :tick
        server = Newman::Server.simple!(apps, config)
        server.tick
      end
    end

    def require_relative(path)
      require "#{File.dirname(basepath)}/#{path}"
    end

    private

    def parse_options(argv)
      params = {}

      parser = OptionParser.new
      parser.on("--config CONFIG") { |file| params[:config] = file }
      parser.on("--tick") { params[:server_mode] = :tick }

      runner_file = parser.parse(argv).first
      [runner_file, params]
    end

    attr_accessor :config, :basepath, :server_mode
  end
end