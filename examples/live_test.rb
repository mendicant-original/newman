require_relative "ping_pong"

server = Newman::Server.simple!(Newman::Examples::PingPong,
                               "config/environment.rb")

mailer   = server.mailer
settings = server.settings

mailer.deliver_message(:to   => settings.application.ping_email,
                       :from => settings.service.default_sender)

puts "Checking in..."
settings.application.live_test_delay.downto(1) do |i|
  print "#{i}. "
  sleep(1)
end
puts

server.tick

remaining_attempts = 3
loop do
  if remaining_attempts == 0
    abort "FAIL: Did not receive mail yet"
  else
    incoming = mailer.messages
    case
    when incoming.empty?
      sleep settings.service.polling_interval
    when incoming.length > 1
      abort "FAIL: More than one message in inbox"
    else
      if incoming.first.subject == "pong"
        puts "OK"
        exit
      else
        abort "FAIL: Expected 'pong', got #{incoming.first.subject}"
      end
    end

    remaining_attempts -= 1
  end
end
