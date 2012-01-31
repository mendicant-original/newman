require_relative "../lib/postal_service"
require_relative "config"
require "pstore"


store = PStore.new("simple_mailing_list.store")
store.transaction { store["members"] ||= [] }

def sender(mail)
  mail.from.first.to_s
end

PostalService.run(CONFIGURATION_DATA) do |incoming, outgoing|
  list_members = store.transaction(true) { store["members"] }

  if incoming.to.any? { |e| e[/\+subscribe@#{CONFIGURATION_DATA[:domain]}/] }
    if list_members.include?(sender(incoming))
      outgoing.subject = "ERROR: Already subscribed"
      outgoing.body    = "You are already subscribed, you can't subscribe again"
    else
      outgoing.subject = "SUBSCRIBED!"
      store.transaction { store["members"] << sender(incoming) }
    end
   elsif incoming.to.any? { |e| e[/\+unsubscribe@#{CONFIGURATION_DATA[:domain]}/] }
    if store.transaction { store["members"].delete(sender(incoming)) }
      outgoing.subject = "UNSUBSCRIBED!"
      outgoing.body    = "Sorry to see you go!"
    else
      outgoing.subject = "ERROR: Not on subscriber list"
      outgoing.body    = "You tried to unsubscribe, but you are not on our list!"
    end
  else
    if list_members.include?(sender(incoming))
      outgoing.from      = incoming.from
      outgoing.reply_to  = CONFIGURATION_DATA[:default_sender]
      outgoing.bcc       = list_members.join(", ")
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
