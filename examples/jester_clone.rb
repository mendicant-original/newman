require_relative "example_helper"

app = Newman::Application.new do
  match :genre, '\S+'
  match :title, '.*'
  match :email, '[\w\d\._-]+@[\w\d\._-]+' #not legit, I'm sure

  subject(:match, "a {genre} story '{title}'") do
    respond :subject => "No one would consider '#{params[:title]}' to be #{params[:genre]}"
  end

  subject(:match, "what stories do you know?") do
    respond :subject => "What stories do YOU know?"
  end

  subject(:match, "tell something {genre} to {email}") do
    respond :subject => "Why don't you tell something #{params[:genre]} to #{params[:email]}?"
  end

  subject(:match, "tell me something {genre}") do
    respond :subject => "Your face is #{params[:genre]}"
  end

  subject(:match, "tell me '{title}'") do
    respond :subject => "Once upon a time there was a #{params[:title]}. THE END."
  end

  subject(:match, "help") do
    respond :subject => "Please deposit $10, and then try again"
  end

  default do
    respond :subject => "FAIL"
  end
end

settings = Newman::Settings.from_file("config/config.rb")

Newman::Server.run(:settings => settings, :apps => [app])
