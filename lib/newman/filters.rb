# The `Newman::Filters` module provides the standard filtering mechanisms for 
# Newman applications. Unless you are building a server-side extension for
# Newman, you probably only need to be familiar with how these filter methods
# are used and can treat their implementation details as a black box.

module Newman 
  module Filters

    # ---

    # The `to` method takes a `filter_type`, a `pattern`, and an `action` and
    # then registers a callback which gets run for each new request the
    # application handles. If the filter matches the incoming message, the
    # `action` block gets run in the context of a `Newman::Controller` object.
    # Otherwise, the `action` block does not get run at all.
    #
    # Currently, the only supported `filter_type` is `:tag`, which leverages the
    # `+` extension syntax for email addresses to filter out emails with certain
    # tags in their TO field. For example, we could build a filter that responds
    # to messages sent to `USERNAME+ping@HOST` using the following filter
    # setup:
    #
    #     to(:tag, "ping") do
    #       respond(:subject => "pong")
    #     end
    #
    # Because this method runs the `pattern` through 
    # `Newman::Application#compile_regex`, it can also be used in 
    # combination with `Newman::Application#match` to do more
    # complex matching. For example, the code below could be used to support
    # complex TO field mappings, such as `USERNAME+somelist.subscribe@HOST`:
    #
    #     match :list_id, "[^.]+"
    #
    #     to(:tag, "{list_id}.subscribe") do
    #       list = load_list(params[:list_id]) 
    # 
    #       if list.subscriber?(sender)
    #         # send failure email, already subscribed
    #       else
    #         # add user to list and send success email
    #       end
    #     end
    #
    # Note that currently everything before the `+` in the email address is 
    # ignored, and that the domain is hardcoded to match the
    # `Controller#domain`, which currently directly references the
    # `service.domain` setting. It'd be nice to make this a bit more 
    # flexible and also support other filter types such as a match against the
    # whole email address at some point in the future.
    
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

    # ---

    # The `subject` method takes a `filter_type`, a `pattern`, and an `action` and
    # then registers a callback which gets run for each new request the
    # application handles. If the filter matches the incoming message, the
    # `action` block gets run in the context of a `Newman::Controller` object.
    # Otherwise, the `action` block does not get run at all.
    #
    # Currently, the only supported `filter_type` is `:match`, which matches the
    # pattern against the full SUBJECT field. This can be used for simple
    # subject based filtering, such as the code shown below:
    #
    #     subject(:match, "what stories do you know?") do
    #       respond :subject => "All of Jester's stories",
    #              :body => story_library.map { |e| e.title }.join("\n")
    #     end
    # 
    # Because this method runs the `pattern` through 
    # `Newman::Application#compile_regex`, it can also be used in 
    # combination with `Newman::Application#match` to do more
    # complex matching, such as in the following example:
    #
    #     match :genre, '\S+'
    #     match :title, '.*'
    #
    #     subject(:match, "a {genre} story '{title}'") do
    #       story_library.add_story(:genre => params[:genre],
    #                               :title => params[:title],
    #                               :body => request.body.to_s)
    #
    #       respond :subject => "Jester saved '#{params[:title]}'"
    #     end
    #
    # It'd be nice to support more kinds of matching strategies at some point in
    # the future, so be sure to let us know if you have ideas.

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
