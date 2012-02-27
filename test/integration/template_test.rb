require 'digest/md5'
require_relative "../helper"

describe "template" do
  let(:app) do
    Newman::Application.new do
      match :list_id, /[^\.]+/
      
      to :tag, "{list_id}.echo" do
        respond(:subject => "RE: #{request.subject}",
                :body    => template('test/echo')
               )
      end
      
      to :tag, "{list_id}.moneyball" do
        pick_4 = [ rand(9), rand(9), rand(9), rand(9) ]
        magic_code = Digest::MD5.hexdigest( 
                      "#{sender}#{params[:list_id]}" 
                     )
        respond(:subject => "Today's Jackpots",
                :body    => template('test/moneyball', :pick_4 => pick_4,
                                                       :magic_code => magic_code)
               )
      end

    end
  end

  let(:server) { 
    Newman.new_test_server([Newman::RequestLogger, app, Newman::ResponseLogger]) 
  }
  
  let(:mailer) { server.mailer }

  # -----
  
  it "renders simple template without passed locals hash" do
    mailer.deliver_message(:from => "me@example.com",
                           :to => "test+fizbiz.echo@test.com")
    server.tick

    msgs = mailer.messages
    assert_equal 1, msgs.count
    
    # assert that list_id is rendered in view
    assert_match /\bfizbiz\b/, msgs.first.decoded
  end
  
  it "renders template with passed locals hash" do
    mailer.deliver_message(:from => "me@example.com",
                           :to => "test+fizbiz.moneyball@test.com")
    server.tick

    msgs = mailer.messages
    assert_equal 1, msgs.count
    
    actual = msgs.first.decoded
    expected_code = Digest::MD5.hexdigest("me@example.comfizbiz")
    
    # assert that pick_4 and magic_code locals are rendered in view
    assert_match(/Pick 4\: \d\d\d\d/, actual)
    assert_match(/Your magic code is\: #{expected_code}/, actual)
  end
  
end