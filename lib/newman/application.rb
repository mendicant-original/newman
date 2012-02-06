module Newman 
  class Application
    include Filters

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

    def default(&callback)
      self.default_callback = callback
    end

    def use(extension)
      extensions << extension
    end

    def helpers(&block)
      extensions << Module.new(&block)
    end

    def match(id, pattern)
      matchers[id.to_s] = pattern
    end

    def callback(action, filter)
      callbacks << { :filter   => filter, 
                     :action   => action }
    end

    private

    attr_accessor :callbacks, :default_callback, :matchers, :extensions

    def compile_regex(pattern)
      regex = Regexp.escape(pattern)
                    .gsub(/\\{(.*?)\\}/) { |m| "(?<#{$1}>#{matchers[$1]})" } 
    end

    def trigger_callbacks(controller)
      matched_callbacks = callbacks.select do |e| 
        filter = e[:filter]
        e[:match_data] = controller.instance_exec(&filter)
      end

      if matched_callbacks.empty?
        controller.instance_exec(&default_callback) 
      else
        matched_callbacks.each do |e|
          action = e[:action]
          controller.params = e[:match_data] || {}
          controller.instance_exec(&action)
        end
      end
    end
  end
end
