require_relative "example_helper"

module Newman
  module Examples
    store = Newman::Store.new("db/lists/simple_mailing_list.store")
    list  = Newman::MailingList.new("simple_list", store)

    SimpleList = Newman::Application.new do
      to(:tag, "subscribe") do
        if list.subscriber?(sender)
          respond :subject => "ERROR: Already subscribed",
                  :body    => template("subscribe-error")
        else
          list.subscribe(sender)

          respond :subject => "SUBSCRIBED!",
                  :body    => template("subscribe-success")
        end
      end

      to(:tag, "unsubscribe") do
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
