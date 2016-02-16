require "pry"

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
        return unless set_room!(request, response)
        result = { queue: @room.queue }
        response.write(MultiJson.dump(result))
      end

      def next(request, response)
        return unless set_room!(request, response)
        if @room.count.zero?
          result = { message: "The queue is empty. :beer:?" }
        else
          student = @room.next
          send_message(student, "@#{student}: You're up. Let's debug :allthethings:!")
          result = { message: "#{student} is up next and has been notified." }
        end
        response.write(MultiJson.dump(result))
      end

      def clear(request, response)
        return unless set_room!(request, response)
        @room.clear!
        result = { queue: @room.queue }
        response.write(MultiJson.dump(result))
      end

      def drop(request, response)
        return unless set_room!(request, response)
        params = request.env["router.params"]
        student = params[:student]

        if @room.include?(student)
          @room.remove(student)
          result = { queue: @room.queue }
        else
          result = { error: "#{student} isn't in the queue!" }
        end
        response.write(MultiJson.dump(result))
      end

      private

      def set_room!(request, response)
        response.headers["Content-Type"] = "application/json"
        name = request.env["router.params"][:classroom]
        if valid_room?(name)
          @room = RoomQueue.new(name, redis)
        else
          result = { error: "Couldn't find Slack channel '#{name}'" }
          response.write(MultiJson.dump(result))
        end
        @room
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
