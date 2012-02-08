# `Newman::Store` is a minimal persistence layer for storing non-relational
# data. It is meant to make the task of building small applications with simple
# data storage needs easier.
#
# For an example of how `Newman::Store` can be used in your applications, you
# can take a look at how `Newman::MailingList` is implemented. A similar
# approach could be used to develop arbitrary persistent models.
#
# `Newman::Store` is part of Newman's **external interface**.

module Newman
  class Store 

    # ---
    
    # TODO
    def initialize(filename)
      FileUtils.mkdir_p(File.dirname(filename))

      self.data = PStore.new(filename)

      write do
        data[:identifiers] ||= {} 
        data[:columns]     ||= {}
      end
    end

    # ---
    
    # TODO
    def [](column)
      Recorder.new(column, self) 
    end

    # ---
    
    # TODO
    def read
      data.transaction(:read_only) { yield(data) }
    end

    # ---
    
    # TODO
    def write
      data.transaction { yield(data) }
    end

    # ---
    
    # TODO
    private

    # ---
    
    # TODO
    attr_accessor :data
  end
end
