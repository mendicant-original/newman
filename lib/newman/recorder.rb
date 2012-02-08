# `Newman::Recorder` provides a simple mechanism for storing non-relational
# records within a `Newman::Store` with autoincrementing identifiers. It
# supports basic CRUD operations, and also acts as an `Enumerable` object.
#
# For an example of how to make use of `Newman::Recorder` to implement arbitrary
# persistent models, be sure to check out the implementation of the
# `Newman::MailingList` object.
#
# `Newman::Recorder` is part of Newman's **external interface**.

module Newman
  Record = Struct.new(:column, :id, :contents)

  class Recorder
    include Enumerable

    # ---
    
    # To initialize a `Newman::Recorder` object, a `column` key 
    # and `store` object must be provided, i.e.
    #
    #     store     = Newman::Store.new("sample.store")
    #     recorder  = Newman::Recorder.new(:subscribers, store)
    #
    # However, in most cases you should not instantiate a
    # `Newman::Recorder` directly, and instead should make use of
    # `Newman::Store#[]` which is syntactic sugar for the same operation.
    #
    # The first time a particular `column` key is referenced, two mapping
    # is created for the column in the underlying data store: one which
    # keeps track of the autoincrementing ids, and one that keeps track
    # of the data stored within the column. It's fine to treat these
    # mappings as implementation details, but we treat them as part of Newman's
    # external interface because backwards-incompatible changes to them will
    # result in possible data store corruption.

    def initialize(column, store)
      self.column = column
      self.store  = store

      store.write do |data|
        data[:identifiers][column] ||= 0
        data[:columns][column]     ||= {}
      end
    end

    # ---
    
    # `Newman::Recorder#each` iterates over all records stored in the column,
    # yielding a `Newman::Record` object for each one. Because `Enumerable` is
    # mixed into `Newman::Recorder`, all enumerable methods that get called on a
    # recorder object end up making calls to this method.
    def each
      store.read do |data|
        data[:columns][column].each do |id, contents| 
          yield(Record.new(column, id, contents)) 
        end
      end
    end

    # ---
     
    # `Newman::Recorder#create` store an arbitrary Ruby object in the data
    # store and returns a `Newman::Record` object which has fields for the
    # `column` key, record `id`, and record `contents`. This method
    # automatically generates new ids, starting with `id=1` for the 
    # first record and then incrementing sequentially.

    def create(contents)
      store.write do |data| 
        id = (data[:identifiers][column] += 1)
        
        data[:columns][column][id] = contents 

        Record.new(column, id, contents)
      end
    end

    # ---
     
    # `Newman::Recorder#read` looks up a record by `id` and returns a
    # `Newman::Record` object.

    def read(id)
      store.read do |data|
        Record.new(column, id, data[:columns][column][id])
      end
    end

    # ---

    # `Newman::Recorder#update` looks up a record by `id` and yields its
    # contents. The record contents are then replaced with the 
    # return value of the provided block.

    def update(id)
      store.write do |data|
        data[:columns][column][id] = yield(data[:columns][column][id])

        Record.new(column, id, data[:columns][column][id])
      end
    end

    # ---

    # `Newman::Recorder#destroy` looks up a record by `id` and then removes it
    # from the data store. This method returns `true` whether or not a record
    # was actually destroyed, which is a somewhat useless behavior and may
    # need to be fixed in a future version of Newman. Patches welcome!

    def destroy(id)
      store.write do |data|
        data[:columns][column].delete(id)
      end

      true
    end

    # ---

    # **NOTE: Methods below this point in the file are implementation 
    # details, and should not be depended upon**
    private

    # ---

    # These accessors have been made private to reflect the fac that
    # `Newman::Recorder` objects are meant to point to a single column within a
    # single data store once created.
    attr_accessor :column, :store
  end
end
