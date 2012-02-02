module Newman
  TestMailer = Object.new

  class << TestMailer
    def configure(settings)
      Mail.defaults do
        retriever_method :test
        delivery_method  :test      
      end
    end

    def messages
      msgs = Marshal.load(Marshal.dump(Mail::TestMailer.deliveries))
      Mail::TestMailer.deliveries.clear

      msgs
    end

    def new_message(*a, &b)
      Mail.new(*a, &b)
    end

    def deliver_message(*a, &b)
      new_message(*a, &b).deliver
    end
  end
end
