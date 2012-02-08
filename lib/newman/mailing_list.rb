# `Newman::MailingList` implements a simple mechanism for storing lists of email
# addresses keyed by a mailing list name. 
#
# This object is meant to be used in conjunction with a
# `Newman::Store` object which is `PStore` backed, but would fairly easily map to
# arbitrary data stores via adapter objects. 
#
# `Newman::MailingList` is part of Newman's **external interface**.

module Newman
  class MailingList

    # ---
     
    # To initialize a `Newman::MailingList` object, a list name and a store object must
    # be provided, i.e:
    #
    #     store        = Newman::Store.new('simple.store')
    #     mailing_list = Newman::MailingList.new("simple_list", store)

    def initialize(name, store)
      self.name  = name
      self.store = store
    end

    # ---
    
    # `Newman::MailingList#subscribe` is used to add subscribers to 
    # the mailing list, i.e.
    #
    #     mailing_list.subscribe('gregory.t.brown@gmail.com')
    #
    # If the provided email address is for a new subscriber, a new record gets
    # created for that subscriber, adding them to the list. Otherwise, this 
    # method does not modify the mailing list.
    # 
    # Returns true if list was modified, returns false otherwise.

    def subscribe(email)
      return false if subscriber?(email)

      store[name].create(email)

      true
    end

    # ---
    
    # `Newman::MailingList#unsubscribe` is used to remove subscribers from 
    # the mailing list, i.e.
    #
    #     mailing_list.unsubscribe('gregory.t.brown@gmail.com')
    #
    # If the provided email address is for an existing subscriber, the record
    # for that subscriber is destroyed, removing them from the list. 
    # Otherwise, this method does not modify the mailing list.
    #
    # Returns true if list was modified, returns false otherwise.

    def unsubscribe(email)
      return false unless subscriber?(email)

      record = store[name].find { |e| e.contents == email } 
      store[name].destroy(record.id)

      true
    end


    # ---

    # `Newman::MailingList#subscriber?` is used to check if a given email address 
    # is on the list, i.e.
    #
    #     mailing_list.subscriber?('gregory.t.brown@gmail.com')
    #
    # Returns true if a record is found which matches the given email address,
    # returns false otherwise.

    def subscriber?(email)
      store[name].any? { |r| r.contents == email }
    end

    # ---

    # `Newman::MailingList#subscribers` is used to access all email addresses for 
    # the mailing list's subscribers, i.e:
    #
    #     members = mailing_list.subscribers
    #
    # Returns an array of email addresses.

    def subscribers
      store[name].map { |r| r.contents } 
    end

    # ---

    # **NOTE: Methods below this point in the file are implementation 
    # details, and should not be depended upon.**

    private

    # ---

    # These accessors have been made private to reflect the fact that
    # `Newman::MailingList` objects are meant to point to a single
    # named list within a single data store once they are created.
    
    attr_accessor :name, :store
  end
end
