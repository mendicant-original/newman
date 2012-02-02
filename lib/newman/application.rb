module Newman 
  class Application
    include Commands

    def initialize(&block)
      self.callbacks  = []
      self.matchers   = {}
      self.extensions = []

      instance_eval(&block) if block_given?
    end

    def call(params)
      controller = Controller.new(params)      
      extensions.each { |mod| controller.extend(mod) }
      trigger_callbacks(controller)
    end

    private

    attr_accessor :callbacks, :default_callback, :matchers, :extensions
  end
end
