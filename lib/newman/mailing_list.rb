module Newman
  class MailingList
    def initialize(name, store)
      self.name  = name
      self.store = store
    end

    def subscribe(email)
      store[name].create(email)
    end

    def unsubscribe(email)
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
