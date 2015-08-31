module Lita
  module Handlers
    class RoomQueue
      def initialize(name)
        @name = name
        @redis = Redis::Namespace.new(:debug_queue)
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
        student = self.queue.pop
        @redis.set(@name, self.queue.reject { |x| x == student })
        student
      end

      def clear!
        @redis.del(@name)
      end
    end
  end
end
