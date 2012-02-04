module Newman
  class MailingList
    def initialize(name, store)
      self.name  = name
      self.store = store
    end

    # returns true if the subscription is new,
    # false if the subscription already exists
    def subscribe(email)
      return false if subscriber?(email)

      store[name].create(email)

      true
    end

    # returns true if the user is sucessfully unsubscribed,
    # false if the email does not match anyone on the 
    # subscriber list
    def unsubscribe(email)
      return false unless subscriber?(email)

      record = store[name].find { |e| e.contents == email } 
      store[name].destroy(record.id)
    end

    def subscriber?(email)
      store[name].any? { |r| r.contents == email }
    end

    def subscribers
      store[name].map { |r| r.contents } 
    end

    private

    attr_accessor :name, :store
  end
end
