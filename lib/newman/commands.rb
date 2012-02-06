module Newman 
  module Commands
    def to(pattern_type, pattern, &action)
      raise NotImplementedError unless pattern_type == :tag

      regex = compile_regex(pattern)

      callback action, ->(controller) {
        controller.request.to.each do |e| 
          md = e.match(/\+#{regex}@#{Regexp.escape(controller.domain)}/)
          return md if md
        end

        false
      }

    end

    def subject(pattern_type, pattern, &action)
      raise NotImplementedError unless pattern_type == :match

      regex = compile_regex(pattern)

      callback action, ->(controller) {
        md = controller.request.subject.match(/#{regex}/)

        md || false
      }
    end
  end
end
