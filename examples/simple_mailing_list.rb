require_relative "../lib/postal_service"

list = PostalService::MailingList.new("db/lists/simple_mailing_list.store")

app = PostalService::Application.new do
  to(:tag, "subscribe") do
    if list.subscriber?(sender)
      response.subject = "ERROR: Already subscribed"
      response.body    = "You are already subscribed, you can't subscribe again"
    else
      list.subscribe(sender)
      response.subject = "SUBSCRIBED!"
      response.body    = "Welcome to the club, buddy"
    end
  end

  to(:tag, "unsubscribe") do
    if list.subscriber?(sender)
      list.unsubscribe(sender)
      response.subject = "UNSUBSCRIBED!"
      response.body    = "Sorry to see you go!"
    else
      response.subject = "ERROR: Not on subscriber list"
      response.body    = "You tried to unsubscribe, but you are not on our list!"
    end
  end

  default do
    if list.subscriber?(sender)
      response.bcc = list.subscribers.join(", ")
      forward_message
    else
      response.subject = "You are not subscribed"
      response.body    = "You must be a member to post on this list"
    end
  end
end

PostalService::Server.run(:config => eval(File.read("config.rb")), 
                          :apps   => [app])
