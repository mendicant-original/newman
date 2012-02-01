require_relative "../lib/postal_service"
require_relative "config"

SimpleMailingList = Object.new

class << SimpleMailingList
  include PostalService::Helpers

  def run
    mailing_list = PostalService::MailingList.new("simple_mailing_list.store")

    PostalService.run(CONFIGURATION_DATA) do |incoming, outgoing|
      from_address = sender(incoming) 

      case incoming
      when filter(:sender, /\+subscribe@#{CONFIGURATION_DATA[:domain]}/)
        if mailing_list.subscriber?(from_address)
          outgoing.subject = "ERROR: Already subscribed"
          outgoing.body    = "You are already subscribed, you can't subscribe again"
        else
          mailing_list.subscribe(from_address)
          outgoing.subject = "SUBSCRIBED!"
          outgoing.body    = "Welcome to the club, buddy"
        end
      when filter(:sender, /\+unsubscribe@#{CONFIGURATION_DATA[:domain]}/)
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
          outgoing.bcc = mailing_list.subscribers.join(", ")
          forward(incoming, outgoing)
        else
          outgoing.subject = "You are not subscribed"
          outgoing.body    = "You must be a member to post on this list"
        end
      end
    end
  end
end

SimpleMailingList.run
