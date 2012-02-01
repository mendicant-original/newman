require_relative "../lib/postal_service"
require_relative "config"


mailing_list = PostalService::MailingList.new("simple_mailing_list.store")

def sender(mail)
  mail.from.first.to_s
end

PostalService.run(CONFIGURATION_DATA) do |incoming, outgoing|
  from_address = sender(incoming) 

  if incoming.to.any? { |e| e[/\+subscribe@#{CONFIGURATION_DATA[:domain]}/] }
    if mailing_list.subscriber?(from_address)
      outgoing.subject = "ERROR: Already subscribed"
      outgoing.body    = "You are already subscribed, you can't subscribe again"
    else
      mailing_list.subscribe(from_address)
      outgoing.subject = "SUBSCRIBED!"
      outgoing.body    = "Welcome to the club, buddy"
    end
   elsif incoming.to.any? { |e| e[/\+unsubscribe@#{CONFIGURATION_DATA[:domain]}/] }
    if mailing_list.subscriber?(from_address)
      mailing_list.unsubscribe(from_address)
      outgoing.subject = "UNSUBSCRIBED!"
      outgoing.body    = "Sorry to see you go!"
    else
      outgoing.subject = "ERROR: Not on subscriber list"
      outgoing.body    = "You tried to unsubscribe, but you are not on our list!"
    end
  else
    if mailing_list.subscriber?(from_address)
      outgoing.from      = incoming.from
      outgoing.reply_to  = CONFIGURATION_DATA[:default_sender]
      outgoing.bcc       = mailing_list.subscribers.join(", ")
      outgoing.subject   = incoming.subject

      if incoming.multipart?
        outgoing.text_part = incoming.text_part
        outgoing.html_part = incoming.html_part
      else
        outgoing.body = incoming.body.to_s
      end
    else
      outgoing.subject = "You are not subscribed"
      outgoing.body    = "You must be a member to post on this list"
    end
  end
end
