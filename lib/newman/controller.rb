# `Newman::Controller` provides a context for application callbacks to run in,
# and provides most of the core functionality for preparing a response email.
#
# For a full example of `Newman::Controller` in action, be sure to check out
# [Jester](https://github.com/mendicant-university/jester).
#
# `Newman::Controller` is part of Newman's **external interface**.

module Newman
  class Controller

    #---
    
    # A `Newman::Controller` object is initialized with parameters that match
    # what is provided by the low level `Newman::Server` object. Generally
    # speaking, you won't instantiate controller objects yourself, but instead
    # will rely on `Newman::Application` to instantiate them for you.

    def initialize(params)
      self.settings = params.fetch(:settings)
      self.request  = params.fetch(:request)
      self.response = params.fetch(:response)
      self.logger   = params.fetch(:logger)
    end

    # ---

    # All of the fields on `Newman::Controller` are public, so that they can
    # freely be manipulated by callbacks. We may lock this down a bit more
    # in a future version of Newman once we figure out what data actually needs
    # to be exposed in callbacks, but for now you can feel free to depend on
    # any of these fields.
 
    attr_accessor :settings, :request, :response, :logger, :params


    # ---
    
    # `Newman::Controller#respond` is used to modify the response email object,
    # and is used in the manner shown below:
    #
    #     respond :subject => "Hello There", 
    #             :body    => "It's nice to meet you, pal!"
    # 
    # Because this method simply provides syntactic sugar on top of the
    # `Mail::Message` object's interface, you should be sure to take a look at
    # the documentation for the [mail gem](http://github.com/mikel/mail) to
    # discover what options are available.

    def respond(params)
      params.each { |k,v| response.send("#{k}=", v) }
    end

    # ---
    
    # `Newman::Controller#template` is used to invoke a template file within the
    # context of the current controller object using Tilt. A name for the template is
    # provided and then looked up in the directory referenced by
    # `settings.service.templates_dir`. While an example of using templates is 
    # included in Newman's source, this feature hasn't really been tested 
    # adequately. Please report any problems with this method in our 
    # [issue tracker](https://github.com/mendicant-university/newman/issues).

    def template(name)
      Tilt.new(Dir.glob("#{settings.service.templates_dir}/#{name}.*").first)
          .render(self)
    end

    # --- 

    # `Newman::Controller#skip_response` is used for disabling the delivery of
    # the response email. Use this for situations where no response is required,
    # such as when a spam email or a bounce has been detected, or if you are
    # building an application which simply passively monitors incoming email
    # rather than replying to it.

    def skip_response
      response.perform_deliveries = false
    end

    # ---
    
    # `Newman::Controller#forward_message` works in a similar fashion to
    # `Newman::Controller#response`, but copies the request FROM, SUBJECT
    # and BODY fields and sets the REPLY TO field to be equal to
    # `settings.service.default_sender`. This feature is convenient for
    # implementing mailing-list style functionality, such as in the 
    # following example:
    #
    #     if list.subscriber?(sender)
    #       forward_message :bcc => list.subscribers.join(", ")
    #     else
    #       respond :subject => "You are not subscribed",
    #               :body    => template("non-subscriber-error")
    #     end

    def forward_message(params={})
      response.from      = request.from
      response.reply_to  = settings.service.default_sender 
      response.subject   = request.subject

      params.each do |k,v|
        response.send("#{k}=", v)
      end

      if request.multipart?
        response.text_part = request.text_part
        response.html_part = request.html_part
      else
        response.body = request.body.to_s
      end
    end

    # ---
    
    # `Newman::Controller#sender` is used as a convenient shortcut for
    # retrieving the sender's email address from the request object.

    def sender
      request.from.first.to_s
    end

    # ---
    
    # `Newman::Controller#domain` is used as a convenient shortcut for
    # referencing `settings.service.domain`.

    def domain
      settings.service.domain 
    end


  end
end
