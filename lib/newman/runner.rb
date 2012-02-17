module Newman
  Runner = Object.new
  
  class << Runner
    def start(argv)
      filename, params = parse_options(argv)

      self.basepath = File.dirname(filename)
      self.config   = params.fetch(:config, "#{basepath}/config/environment.rb")

      eval(File.read(filename), binding)
    end

    def run(apps)
      Newman::Server.simple(apps, config)
    end

    def require_relative(path)
      require "#{File.dirname(basepath)}/#{path}"
    end

    private

    def parse_options(argv)
      params = {}

      parser = OptionParser.new
      parser.on("--config CONFIG") { |file| params[:config] = file }

      runner_file = parser.parse(argv).first
      [runner_file, params]
    end

    attr_accessor :config, :basepath
  end
end
