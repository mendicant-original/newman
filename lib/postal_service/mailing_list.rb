module PostalService
  class MailingList
    def initialize(filename)
      self.store = PStore.new(filename)
      db { store[:subscribers] ||= [] }
    end

    def subscribe(email)
      db { store[:subscribers] |= [email] }
    end

    def unsubscribe(email)
      db { store[:subscribers].delete(email) }
    end

    def subscriber?(email)
      db(:readonly) { store[:subscribers].include?(email) }
    end

    def subscribers
      db(:readonly) { store[:subscribers] }
    end

    private

    attr_accessor :store

    def db(read_only=false)
      store.transaction(read_only) { yield }
    end
  end
end
