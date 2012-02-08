# `Newman::TestMailer` is a drop-in replacement for `Newman::Mailer` meant for
# use in automated testing. It is a thin wrapper on top of the built in testing
# functionality provided by the mail gem.

module Newman
  class TestMailer
    # ---
      
    # To initialize a `Newman::TestMailer` object, a settings object must be
    # provided, i.e.
    #
    #     settings = Newman::Settings.from_file('config/environment.rb')
    #     mailer   = Newman::TestMailer.new(settings)
    #
    # However, there are handful of caveats worth knowing about this
    # constructing an instance of this particular object.
    #
    # 1) Most unit tests won't need a `Newman::TestMailer` object present, and most
    # integration tests can make use of `Newman::Server.test_mode`, preventing
    # the need to ever explicitly instantiate a `Newman::TestMailer` object.
    #
    # 2) Because there isn't an obvious way to work with test objects in the
    # underlying mail gem without relying on global state,
    # `Newman::TestMailer` actually implements the singleton pattern and
    # returns references to a single instance rather than creating new
    # instances. The constructor interface is simply preserved so that it
    # can be a drop-in replacement for a `Newman::Mailer` object.
    #  
    # 3) The settings object is not actually used, and is only part of the
    # signature for API compatibility reasons.
    #
    # With these caveats in mind, be sure to think long and hard about whether
    # you actually need to explicitly build instances of this object before
    # doing so :)

    class << self
      def new(settings)
        return self.instance if instance

        Mail.defaults do
          retriever_method :test
          delivery_method  :test      
        end

        self.instance = allocate
      end

      attr_accessor :instance
    end

    # ---

    # Use the `messages` method to retrieve all messages currently in the inbox
    # and then delete them from the underlying `Mail::TestMailer` object so that
    # the inbox gets cleared. This method returns an array of
    # `Mail::Message` objects if any messages were found, and returns
    # an empty array otherwise.
    #
    # Keep in mind that because only a single `Newman::TestMailer` ever gets
    # instantiated no matter how many times you call `Newman::TestMailer.new`,
    # you only get one test inbox per process.

    def messages
      msgs = Marshal.load(Marshal.dump(Mail::TestMailer.deliveries))
      Mail::TestMailer.deliveries.clear

      msgs
    end

    # ---
    
    # Use the `new_message` method to construct a new `Mail::Message` object,
    # with the delivery settings set to test mode. 
    # This method passes all its arguments on to `Mail.new`, so be sure 
    # to refer to the [mail gem's documentation](http://github.com/mikel/mail)
    # for details.

    def new_message(*a, &b)
      Mail.new(*a, &b)
    end

    # ---

    # Use the `deliver_message` method to construct and immediately deliver a
    # message with the delivery settings set to test mode.

    def deliver_message(*a, &b)
      new_message(*a, &b).deliver
    end
  end
end
