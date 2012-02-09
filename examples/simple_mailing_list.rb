require_relative "example_helper"

# The simplest possible mailing list app
#
# Settings:
#
# - `application.simplelist_db`<br>
#     path to mailing list pstore file, relative to application root
#
module Newman
  module Examples

    SimpleList = Newman::Application.new do
      helpers do
        def list
          store = Newman::Store.new(settings.application.simplelist_db)
          
          Newman::MailingList.new("simple_list", store)
        end
      end

      subject(:match, "subscribe") do
        if list.subscriber?(sender)
          respond :subject => "ERROR: Already subscribed",
                  :body    => template("subscribe-error")
        else
          list.subscribe(sender)

          respond :subject => "SUBSCRIBED!",
                  :body    => template("subscribe-success")
        end
      end

      subject(:match, "unsubscribe") do
        if list.subscriber?(sender)
          list.unsubscribe(sender)

          respond :subject => "UNSUBSCRIBED!",
                  :body    => template("unsubscribe-success")
        else
          respond :subject => "ERROR: Not on subscriber list",
                  :body    => template("unsubscribe-error")
        end
      end

      default do
        if list.subscriber?(sender)
          forward_message :bcc => list.subscribers.join(", ")
        else
          respond :subject => "You are not subscribed",
                  :body    => template("non-subscriber-error")
        end
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  Newman::Server.simple(Newman::Examples::SimpleList, "config/environment.rb")
end
