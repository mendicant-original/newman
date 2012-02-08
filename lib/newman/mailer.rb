# `Newman::Mailer` allows you to easily receive mail via IMAP and send mail via
# SMTP, and is the default mailing strategy used by `Newman::Server.simple`.
# This class mostly exists to serve as an adapter that bridges the gap between
# the mail gem and Newman's configuration system. 
#
# `Newman::Mailer`'s interface minimal by design so that other objects
# can easily stand in for it as long as they respond to the same set of
# messages. Be sure to see `Newman::TestMailer` for an example of how to build a
# custom object that can be used in place of a `Newman::Mailer` object.

module Newman
  class Mailer
    
    # ---
    
    # To initialize a `Newman::Mailer` object, a settings object must be
    # provided, i.e:
    #
    #     settings = Newman::Settings.from_file('config/environment.rb')
    #     mailer   = Newman::Mailer.new(settings)
    #
    # This is done automatically for you by `Newman::Server.simple`, but must be
    # done manually if you are creating a `Newman::Server` instance from
    # scratch.
    #
    # Currently, not all of the settings supported by the mail gem are mapped by
    # Newman. This is by design, to limit the amount of configuration options
    # need to think about. However, if this is causing you a problem, 
    # please [file an issue](https://github.com/mendicant-university/newman/issues).

    def initialize(settings)
      imap = settings.imap
      smtp = settings.smtp

      self.retriever_settings = {
         :address    => imap.address,
         :user_name  => imap.user,
         :password   => imap.password,
         :enable_ssl => imap.ssl_enabled || false,
         :port       => imap.port
      }
      
      self.delivery_settings = {
         :address              => smtp.address,
         :user_name            => smtp.user,
         :password             => smtp.password,
         :authentication       => :plain,
         :enable_starttls_auto => smtp.starttls_enabled || false,
         :port                 => smtp.port
      }
    end

    # ---

    # Use the `messages` method to retrieve all messages currently in the inbox
    # and then delete them from the server. This method returns an array of
    # `Mail::Message` objects if any messages were found, and returns
    # an empty array otherwise.

    def messages
      Mail::IMAP.new(retriever_settings).all(:delete_after_find => true)
    end

    # ---
    
    # Use the `new_message` method to construct a new `Mail::Message` object,
    # with the delivery settings that were set up at initialization time. 
    # This method passes all its arguments on to `Mail.new`, so be sure 
    # to refer to the [mail gem's documentation](http://github.com/mikel/mail)
    # for details.
    #
    def new_message(*a, &b)
      msg = Mail.new(*a, &b)
      msg.delivery_method(:smtp, delivery_settings)

      msg
    end

    # ---
    
    # Use the `deliver_message` method to construct and immediately deliver a
    # message using the delivery settings that were set up at initialization
    # time.

    def deliver_message(*a, &b)
      new_message(*a, &b).deliver
    end

    # ---

    private

    # These accessors are private because they are an implementation detail 
    # and should not be depended upon. `Newman::Mailer` objects should be
    # treated as immutable constructs.

    attr_accessor :retriever_settings, :delivery_settings
  end
end
