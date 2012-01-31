require_relative "../lib/postal_service"
require_relative "config"

list_members = []

PostalService.run(CONFIGURATION_DATA) do |incoming, outgoing|
  if incoming.to.any? { |e| e[/\+subscribe@#{CONFIGURATION_DATA[:domain]}/] }
    if list_members.include?(incoming.from)
      outgoing.subject = "ERROR: Already subscribed"
      outgoing.body    = "You are already subscribed, you can't subscribe again"
    else
      outgoing.subject = "SUBSCRIBED!"
      list_members << incoming.from
    end
   elsif incoming.to.any? { |e| e[/\+unsubscribe@#{CONFIGURATION_DATA[:domain]}/] }
    if list_members.delete(incoming.from)
      outgoing.subject = "UNSUBSCRIBED!"
      outgoing.body    = "Sorry to see you go!"
    else
      outgoing.subject = "ERROR: Not on subscriber list"
      outgoing.body    = "You tried to unsubscribe, but you are not on our list!"
    end
  else
    outgoing.reply_to = CONFIGURATION_DATA[:default_sender]
    outgoing.bcc      = list_members.join(", ")
    outgoing.subject  = incoming.subject
    outgoing.body     = incoming.body.to_s
  end
end
