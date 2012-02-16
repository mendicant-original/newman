module Newman
  Runner = Object.new
  
  class << Runner
    def from_file(filename, config)
      self.basepath = File.dirname(filename)
      self.config   = config

      eval(File.read(filename), binding)
    end

    def run(apps)
      Newman::Server.simple(apps, config)
    end

    def require_relative(path)
      require "#{File.dirname(basepath)}/#{path}"
    end

    private

    attr_accessor :config, :basepath
  end
end
