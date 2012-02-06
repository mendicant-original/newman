module Newman
  class TestMailer
    class << self
      def new(settings)
        return self.instance if instance

        # FIXME: It'd be nice to find a non-singleton way to do this
        # and if it can be found, then Newman::TestMailer needn't 
        # be a singleton.
        Mail.defaults do
          retriever_method :test
          delivery_method  :test      
        end

        self.instance = allocate
      end

      attr_accessor :instance
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
