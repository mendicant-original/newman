module Newman 
  class Application
    include Commands

    def initialize(&block)
      self.callbacks  = []
      self.matchers   = {}

      instance_eval(&block) if block_given?
    end

    def call(params)
      controller = Controller.new(params)      
      trigger_callbacks(controller)
    end

    private

    attr_accessor :callbacks, :default_callback, :matchers
  end
end
