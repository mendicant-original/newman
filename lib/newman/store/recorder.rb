module Newman
  class Store
    Record = Struct.new(:column, :id, :contents)

    class Recorder
      include Enumerable

      def initialize(column, store)
        self.column = column
        self.store  = store

        store.write do |data|
          data[:identifiers][column] ||= 0
          data[:columns][column]     ||= {}
        end
      end

      def each
        store.read do |data|
          data[:columns][column].each do |id, contents| 
            yield(Record.new(column, id,contents)) 
          end
        end
      end

      def create(contents)
        store.write do |data| 
          id = (data[:identifiers][column] += 1)
          
          data[:columns][column][id] = contents 

          Record.new(column, id, contents)
        end
      end

      def read(id)
        store.read do |data|
          Record.new(column, id, data[:columns][column][id])
        end
      end

      def update(id)
        store.write do |data|
          data[:columns][column][id] = yield(data[:columns][column][id])

          Record.new(column, id, data[:columns][column][id])
        end
      end

      def destroy(id)
        store.write do |data|
          data[:columns][column].delete(id)
        end

        true
      end

      private

      attr_accessor :column, :store
    end
  end
end
