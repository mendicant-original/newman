require_relative "store/recorder"

module Newman
  class Store 
    def initialize(filename)
      self.data = PStore.new(filename)

      write do
        data[:identifiers] ||= {} 
        data[:columns]     ||= {}
      end
    end

    attr_reader :identifiers

    def [](column)
      Recorder.new(column, self) 
    end

    def read
      data.transaction(:read_only) { yield(data) }
    end

    def write
      data.transaction { yield(data) }
    end

    private

    attr_accessor :data
  end
end
