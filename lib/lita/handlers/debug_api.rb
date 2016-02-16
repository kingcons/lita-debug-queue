module Lita
  module Handlers
    class DebugApi
      extend Lita::Handler::HTTPRouter

      config :passphrase # The worst auth strategy.

      http.get    "api/:classroom/queue", :show
      http.put    "api/:classroom/next",  :next
      http.delete "api/:classroom/drop",  :drop
      http.delete "api/:classroom/clear", :clear

      def show(request, response)
        return unless validate!(request, response)
        result = { queue: @room.queue }
        response.write(MultiJson.dump(result))
      end

      def next(request, response)
        return unless validate!(request, response)
        if @room.count.zero?
          result = {
            queue: @room.queue,
            message: "The queue is empty. :beer:?"
          }
        else
          student = @room.next
          send_message(student, "@#{student}: You're up. Let's debug :allthethings:!")
          result = {
            queue: @room.queue,
            message: "#{student} is up next and has been notified."
          }
        end
        response.write(MultiJson.dump(result))
      end

      def clear(request, response)
        return unless validate!(request, response)
        @room.clear!
        result = { queue: @room.queue }
        response.write(MultiJson.dump(result))
      end

      def drop(request, response)
        return unless validate!(request, response)
        params = request.env["router.params"]
        student = request.params["student"]

        if @room.include?(student)
          @room.remove(student)
          result = { queue: @room.queue }
        else
          result = { error: "#{student} isn't in the queue!" }
        end
        response.write(MultiJson.dump(result))
      end

      private

      ## NOTES: These private methods are a tangle of stateful filth.
      ## This is out of an attempt at DRYness since we need to return
      ## JSON everywhere and I lack a nice error handling mechanism
      ## like rescue_from. (See: response.headers, response.write)

      def validate!(request, response)
        response.headers["Content-Type"] = "application/json"
        passphrase_check!(request.params, response)
        room_check!(request.env, response)
        @room
      end

      def passphrase_check!(params, response)
        authenticated = params["passphrase"] == config.passphrase
        result = { error: "Passphrase must be supplied correctly to use API." }
        response.write(MultiJson.dump(result)) unless authenticated
      end

      def room_check!(env, response)
        name = env["router.params"][:classroom]
        if valid_room?(name)
          redis.namespace = "handlers:debug_queue"
          @room = RoomQueue.new(name, redis)
        else
          result = { error: "Couldn't find Slack channel '#{name}'" }
          response.write(MultiJson.dump(result))
        end
      end

      def valid_room?(name)
        rooms = robot.config.handlers.debug_queue.classrooms
        rooms.has_value?(name)
      end

      def send_message(username, message)
        user = Lita::User.find_by_mention_name(username)
        robot.send_message(user, message)
      end
    end

    Lita.register_handler(DebugApi)
  end
end
