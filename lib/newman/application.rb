# `Newman::Application` provides the main entry point for Newman application
# developers, and exists to tie together various Newman objects in a convenient
# way.
#
# For an fairly complete example of a `Newman::Application` object in use, be
# sure to check out [Jester](https://github.com/mendicant-university/jester).
#
# `Newman::Application` is part of Newman's **external interface**.

module Newman 
  class Application

    include Filters
    # ---
    
    # A `Newman::Application` object is a blank slate upon creation, with fields
    # set to hold `callbacks`, `matchers`, and `extensions`. A block may
    # optionally be provided, which then gets executed within the context of the
    # newly created `Newman::Application` instance. This is the common way of
    # building applications, and is demonstrated by the example below:
    #  
    #     ping_pong = Newman::Application.new do
    #       subject("ping") do
    #         respond(:subject => "pong")
    #       end
    #     end
    # 
    # Any method that can be called on a `Newman::Application` instance can be
    # called within the provided block, including those methods mixed in by
    # `Newman::Filters`.

    def initialize(&block)
      self.callbacks  = []
      self.matchers   = {}
      self.extensions = []

      instance_eval(&block) if block_given?
    end
    
    # ---
    
    # `Newman::Application#call` accepts a hash of parameters which gets used to
    # create a new `Newman::Controller` object. The controller is then extended
    # by all of the modules stored in the `extensions` field on the application
    # object, and is finally passed along to
    # `Newman::Application#trigger_callbacks`, which does the
    # magical work of figuring out which callbacks to run, if any.
    #
    # This method is meant to be run by a `Newman::Server` object, and isn't
    # especially useful on its own.

    def call(params)
      controller = Controller.new(params)      
      extensions.each { |mod| controller.extend(mod) }
      trigger_callbacks(controller)
    end

    # ---
   
    # `Newman::Application#default` is used to define a default callback
    # which will run when no other callbacks match the incoming request.
    # For example, you can define a callback such as the one below:
    #
    #     default do
    #       respond(:subject => "REQUEST NOT UNDERSTOOD")
    #     end
    #
    # Unless you are building an application that will never fail to 
    # match at least one of its filters, you MUST set up a default callback 
    # if you want to avoid a possible application error. We know this is
    # not exactly the most desireable behavior, and will try to fix this
    # in a future version of Newman.

    def default(&callback)
      self.default_callback = callback
    end

    # ---
    
    # `Newman:::Application#use` is used to register the extension 
    # modules that get mixed in to the controller 
    # objects created by `Newman::Application#call`. This allows 
    # an application object to provide extensions for use within its 
    # callbacks, as in the example shown below.
    #
    #     module ListLoader
    #       def load_list(name)
    #         store = Newman::Store.new(settings.application.list_db)
    #         Newman::MailingList.new(name, store)
    #       end
    #     end
    #
    #     list_app = Newman::Application.new do
    #       use ListLoader
    #       
    #       match :list_id, "[^.]+"
    #
    #       to(:tag, "{list_id}.subscribe") do
    #         list = load_list(params[:list_id])
    #
    #         if list.subscriber?(sender)
    #           # send a failure message
    #         else
    #           # susbcribe the user and send a welcome message
    #         end
    #       end
    #     end
    #
    # This method is mainly meant to be used with pre-packaged extensions or
    # more complicated forms of callback helpers. This example was just shown
    # for the sake of its simplicity, but for similar use cases it would
    # actually be better to use `Newman::Application#helpers`

    def use(extension)
      extensions << extension
    end

    # ---
    
    # `Newman::Application#helpers` is used to build simple controller
    # extensions, and is mostly just syntactic sugar. For example, 
    # rather than using an explicit
    # module, the example shown in the `Newman::Application#use` documentation
    # can be rewritten as follows:
    #
    #     list_app = Newman::Application.new do
    #       helpers do
    #         def load_list(name)
    #           store = Newman::Store.new(settings.application.list_db)
    #           Newman::MailingList.new(name, store)
    #         end
    #       end
    #       
    #       match :list_id, "[^.]+"
    #
    #       to(:tag, "{list_id}.subscribe") do
    #         list = load_list(params[:list_id])
    #
    #         if list.subscriber?(sender)
    #           # send a failure message
    #         else
    #           # susbcribe the user and send a welcome message
    #         end
    #       end
    #     end
    #
    # It's important to note that for any controller extensions that might be
    # reusable, or for more complicated logic, `Newman::Application#use` is
    # probably a better tool to use.

    def helpers(&block)
      use Module.new(&block)
    end

    # ---
    
    # `Newman::Application#match` is used to define patterns which are used for
    # extracting callback parameters. An example is shown below:
    #
    #     jester = Newman::Application.new do
    #       match :genre, '\S+'
    #       match :title, '.*'
    #
    #       subject(:match, "a {genre} story '{title}'") do
    #         story_library.add_story(:genre => params[:genre],
    #                                 :title => params[:title],
    #                                 :body => request.body.to_s)
    #
    #         respond :subject => "Jester saved '#{params[:title]}'"
    #       end
    #     end
    #
    # Because Newman's built in filters are designed to escape regular
    # expression syntax by default, `Newman::Application#match` provides the
    # only high-level mechanism for dynamic filter matches. Low level matching
    # is possible via `Newman::Application#callback`, but would
    # be an exercise in tedium for most application developers.
    #
    # NOTE: `Newman::Application#match` converts the provided `name` to a
    # string using `to_s` to make life easier for the internals. Because
    # `Newman::Application#matchers` is an implementation detail, you probably
    # don't need to worry about this unless you're hacking on Newman itself.
    def match(name, pattern)
      matchers[name.to_s] = pattern
    end

    # ---
    
    # `Newman::Application#callback` is a low level feature for defining custom
    # callbacks. For ideas on how to roll your own filters with it, see the
    # implementation of the `Newman::Filters` module.

    def callback(action, filter)
      callbacks << { :filter   => filter, 
                     :action   => action }
    end

    # ---
    
    # `Newman::Application#compile_regex` is used for converting pattern strings
    # into a regular expression string suitable for use in filters. This method is a
    # low-level feature, and is not meant for use by application developers. See
    # the `Newman::Filters` module for how to use it to build your own callback
    # filters.

    def compile_regex(pattern)
      Regexp.escape(pattern)
            .gsub(/\\{(.*?)\\}/) { |m| "(?<#{$1}>#{matchers[$1]})" } 
    end

    # ---
    
    # **NOTE: Methods below this point in the file are implementation 
    # details, and should not be depended upon.**

    private

    # ---
    
    # `Newman::Application#trigger_callbacks` runs a two step process:
    # 
    # 1) It grabs the `filter` Proc for each callback and executes it, passing in
    # the provided `controller`. Any `filter` proc that returns a logically true
    # value is selected to be run.
    #
    # 2) If the selection of `matched_callbacks` is empty, it executes the default
    # callback in the context of a controller object. Otherwise, it runs each 
    # callback in sequence, in the context of a controller object.
    #
    # This method may have some weird side effects because it relies on
    # awkward state mutations that could be either done in a better way or 
    # replaced with a mostly stateless approach. We will look at fixing 
    # this in a future Newman release.

    def trigger_callbacks(controller)
      matched_callbacks = callbacks.select do |e| 
        filter = e[:filter]
        e[:match_data] = filter.call(controller)
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

    # ---
    
    # These accessors have been made private to reflect the fact that
    # `Newman::Application` is meant to be customized via its high level methods
    # such as `use`, `helpers`, `match`, and `callback`. Any extensions of
    # `Newman::Application` should rely on those methods and not directly
    # reference these fields at all. If there is some functionality missing
    # that needs to be added to the public API for you to build your
    # extension, just let us know.

    attr_accessor :callbacks, :default_callback, :matchers, :extensions
  end
end
