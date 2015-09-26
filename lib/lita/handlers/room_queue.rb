module Lita
  module Handlers
    class RoomQueue
      attr_reader :name

      def initialize(name, redis)
        @name = name
        @redis = redis
      end

      def to_s
        self.queue.join('\n')
      end

      def queue
        data = @redis.get(@name)
        data ? MultiJson.load(data) : []
      end

      def count
        self.queue.length
      end

      def include?(student)
        self.queue.include?(student)
      end

      def add(student)
        @redis.set(@name, self.queue.push(student))
      end

      def remove(student)
        @redis.set(@name, self.queue.reject { |x| x == student })
      end

      def next
        student = self.queue.shift
        @redis.set(@name, self.queue.reject { |x| x == student })
        student
      end

      def clear!
        @redis.del(@name)
      end
    end
  end
end
