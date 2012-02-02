require_relative "example_helper"

list = PostalService::MailingList.new("db/lists/simple_mailing_list.store")

app = PostalService::Application.new do
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


settings = PostalService::Settings.from_file("config/config.rb")

PostalService::Server.run(:settings => settings, :apps => [app])
