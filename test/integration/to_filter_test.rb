require_relative "../helper"

describe "subject filter" do
  let(:app) do
    Newman::Application.new do
     match :list_id, /[^.]+/

     to :tag, "{list_id}.subscribe" do
        respond(:subject => "Subscribing you to [#{params[:list_id]}]")
      end

      default do
        respond(:subject => "Didn't understand you!")
      end
    end
  end

  let(:server) { Newman.new_test_server(app) }
  let(:mailer) { server.mailer }

  it "should automatically not match emails without subjects" do
    mailer.deliver_message(:to => "test+foo.subscribe@test.com")
    server.tick

    mailer.messages.first.subject.must_equal("Subscribing you to [foo]")
  end
end

