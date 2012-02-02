module Newman 
  module Commands
    def match(id, pattern)
      matchers[id.to_s] = pattern
    end

    def to(pattern_type, pattern, &callback)
      raise NotImplementedError unless pattern_type == :tag

      pattern = compile_pattern(pattern)

      matcher = lambda do
        request.to.each do |e| 
          md = e.match(/\+#{pattern}@#{Regexp.escape(domain)}/)
          return md if md
        end

        false
      end

      callbacks << { :matcher  => matcher, :callback => callback }
    end

    def subject(pattern_type, pattern, &callback)
      raise NotImplementedError unless pattern_type == :match

      pattern = compile_pattern(pattern)

      matcher = lambda do
        md = request.subject.match(/#{pattern}/)

        md || false
      end

      callbacks << { :matcher => matcher, :callback => callback }
    end

    def default(&callback)
      self.default_callback = callback
    end

    def trigger_callbacks(controller)
      matched_callbacks = callbacks.select do |e| 
        matcher = e[:matcher]
        e[:match_data] = controller.instance_exec(&matcher)
      end

      if matched_callbacks.empty?
        controller.instance_exec(&default_callback) 
      else
        matched_callbacks.each do |e|
          callback = e[:callback]
          controller.params = e[:match_data] || {}
          controller.instance_exec(&callback)
        end
      end
    end

    def compile_pattern(pattern)
      pattern.gsub('.','\.')
             .gsub(/\{(.*?)\}/) { |m| "(?<#{$1}>#{matchers[$1]})" } 
    end
  end
end
