require_relative "../lib/postal_service"

PostalService.run do |incoming, outgoing|
  list         = mailing_list("simple_mailing_list")
  from_address = sender(incoming) 

  case incoming
  when filter(:to, /\+subscribe@#{CONFIGURATION_DATA[:domain]}/)
    if list.subscriber?(from_address)
      outgoing.subject = "ERROR: Already subscribed"
      outgoing.body    = "You are already subscribed, you can't subscribe again"
    else
      list.subscribe(from_address)
      outgoing.subject = "SUBSCRIBED!"
      outgoing.body    = "Welcome to the club, buddy"
    end
  when filter(:to, /\+unsubscribe@#{CONFIGURATION_DATA[:domain]}/)
    if list.subscriber?(from_address)
      list.unsubscribe(from_address)
      outgoing.subject = "UNSUBSCRIBED!"
      outgoing.body    = "Sorry to see you go!"
    else
      outgoing.subject = "ERROR: Not on subscriber list"
      outgoing.body    = "You tried to unsubscribe, but you are not on our list!"
    end
  else
    if list.subscriber?(from_address)
      outgoing.bcc = list.subscribers.join(", ")
      forward(incoming, outgoing)
    else
      outgoing.subject = "You are not subscribed"
      outgoing.body    = "You must be a member to post on this list"
    end
  end
end

