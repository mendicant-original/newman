require_relative "../lib/postal_service"
require_relative "config"

PostalService.run(CONFIGURATION_DATA) do |incoming, outgoing|
  if incoming.to.any? { |e| e[/\+ping@#{CONFIGURATION_DATA[:domain]}/] }
    outgoing.subject = "PONG"
  else
    outgoing.subject = "UNKNOWN"
  end
end
