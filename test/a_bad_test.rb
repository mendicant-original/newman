require "mail"

config_data = eval(File.read("config.rb"))

pid = fork do
  Dir.chdir("../examples") do
    system("ruby ping_pong.rb")
  end
end

Mail.defaults do
  retriever_method :imap, 
    :address    => config_data[:imap_address],
    :user_name  => config_data[:imap_user],
    :password   => config_data[:imap_password]

  delivery_method :smtp,
    :address              => config_data[:smtp_address], 
    :user_name            => config_data[:smtp_user],
    :password             => config_data[:smtp_password],
    :authentication       => :plain,
    :enable_starttls_auto => false
end


Mail.deliver(:to      => config_data[:ping_address],
             :from    => config_data[:smtp_user],
             :subject => "ping")

attempts = 0

loop do
  attempts += 1
  abort "Did not succeed!" if attempts == 5

  all = Mail.all(:delete_after_find => true)

  case
  when all.empty?
    sleep config_data[:polling_interval]
    next
  when all.length > 1
    abort "Too many emails!"
  when all.first.subject == "pong"
    puts "OK"
    exit
  else
    abort "Expected pong, got #{all.first.subject}"
  end
end

Process.kill(pid)
