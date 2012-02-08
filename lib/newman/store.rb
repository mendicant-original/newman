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

    # To initialize a `Newman::Store` object, a `filename` string must 
    # be provided, i.e.
    #
    #     store = Newman::Store.new("simple.store")
    #
    # This filename will be used to initialize a `PStore` object after first
    # running `FileUtils.mkdir_p` to create any directories within the path to
    # the filename if they do not already exist. Once that `PStore` object is
    # created, two root keys will be mapped to empty Hash objects if they 
    # are not set already: `:indentifers` and `:columns`.
    #
    # While it's okay to treat the `PStore` object as an implementation detail,
    # we will treat our interactions with it as part of Newman's **external
    # interface**, so that we are more conservative about making backwards
    # incompatible changes to the databases created by `Newman::Store`.

    def initialize(filename)
      FileUtils.mkdir_p(File.dirname(filename))

      self.data = PStore.new(filename)

      write do
        data[:identifiers] ||= {} 
        data[:columns]     ||= {}
      end
    end

    # ---
    
    # `Newman::Store#[]` is syntactic sugar for initializing a
    # `Newman::Recorder` object, and is meant to be used for
    # accessing and manipulating column data by `column_key`, i.e.
    #
    #     store[:subscriptions].create("gregory.t.brown@gmail.com")
    #
    # This method is functionally equivalent to the following code:
    #
    #     recorder = Newman::Recorder.new(:subscriptions, store)
    #     recorder.create("gregory.t.brown@gmail.com")
    #
    # For aesthetic reasons and for forward compatibility, it is
    # preferable to use `Newman::Store#[]` rather than instantiating
    # a `Newman::Recorder` object directly. 

    def [](column_key)
      Recorder.new(column_key, self) 
    end

    # ---
    
    # `Newman::Store#read` initiates a read only transaction and then yields
    # the underlying `PStore` object stored in the `data` field.

    def read
      data.transaction(:read_only) { yield(data) }
    end

    # ---
    
    # `Newman::Store#read` initiates a read/write transaction and then yields
    # the underlying `PStore` object stored in the `data` field.

    def write
      data.transaction { yield(data) }
    end

    # ---

    # **NOTE: Methods below this point in the file are implementation 
    # details, and should not be depended upon**
    
    private

    # ---
    
    # The `data` accessor is kept private because a `Newman::Store` object is
    # meant to wrap a single `PStore` object once created, and because we want
    # to force every interaction with a `Newman::Store` to be transactional in
    # nature. 

    attr_accessor :data
  end
end
