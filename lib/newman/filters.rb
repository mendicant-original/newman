module Newman 
  module Filters
    def to(filter_type, pattern, &action)
      raise NotImplementedError unless filter_type == :tag

      regex = compile_regex(pattern)

      callback action, ->(controller) {
        controller.request.to.each do |e| 
          md = e.match(/\+#{regex}@#{Regexp.escape(controller.domain)}/)
          return md if md
        end

        false
      }
    end

    def subject(filter_type, pattern, &action)
      raise NotImplementedError unless filter_type == :match

      regex = compile_regex(pattern)

      callback action, ->(controller) {
        subject = controller.request.subject

        return false unless subject

        subject.match(/#{regex}/) || false
      }
    end
  end
end
