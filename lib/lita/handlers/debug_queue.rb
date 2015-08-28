module Lita
  module Handlers
    class DebugQueue < Handler
      config :classrooms # A mapping from instructor names to classroom channels.

      route(/^debug me$/, :add, command: true, help: { })
      route(/^debug nvm$/, :cancel, command: true, help: { })
      route(/^debug queue$/, :show, command: true, help: { })
      route(/^debug count$/, :count, command: true, help: { })
      route(/^debug next$/, :next, command: true, restrict_to: [:instructors],
        help: { })
      route(/^debug drop\s+(.+)$/, :drop, command: true, restrict_to: [:instructors],
        help: { })
      route(/^debug clear$/, :clear, command: true, restrict_to: [:instructors],
        help: { })

      def add(response)
        return unless check_room!(response)
        student = response.user.mention_name
        if room_queue.include?(student)
          response.reply("#{student}: Easy there killer. You're already on the list.")
        else
          redis.set(@room, room_queue.push(student))
          response.reply("#{student}: Help is on the way.")
        end
      end

      def cancel(response)
        return unless check_room!(response)
        student = response.user.mention_name
        if room_queue.include?(student)
          redis.set(@room, room_queue.reject{ |x| x == student })
          response.reply("#{student}: Glad you figured it out! :)")
        else
          response.reply("#{student}: You know you're not in the queue, right?")
        end
      end

      def show(response)
        return unless check_room!(response)
        response.reply("Queue for #{@room} => #{room_queue}")
      end

      def count(response)
        return unless check_room!(response)
        response.reply("Hackers seeking fresh eyes: #{room_queue.count}")
      end

      def next(response)
        @room = config.classrooms[response.user.mention_name]
        student = room_queue.pop
        redis.set(@room, room_queue.reject { |x| x == student })
        robot.send_message(response.user, "@#{student}: You're up! Let's debug :allthethings:")
        response.reply("#{student} is up next and has been notified.")
      end

      def drop(response)
        @room = config.classrooms[response.user.mention_name]
        student = response.matches[0][0] # TODO: We could be safer here.
        redis.set(@room, room_queue.reject { |x| x == student })
        response.reply("#{student} has been removed from the queue.")
      end

      def clear(response)
        @room = config.classrooms[response.user.mention_name]
        redis.del(@room)
        response.reply("Sounds like time for :beer: and ping pong!")
      end

      private
      def check_room!(response)
        # KLUDGE: The following is a gross hack as the current room_object is incorrect.
        # See lita-slack Issue #44
        @room = Lita::Room.find_by_id(response.message.source.room).name
        response.reply_privately("You must be in the class channel to send this message.") unless @room
        @room
      end

      def room_queue
        room = redis.get(@room)
        room ? MultiJson.load(room) : []
      end
    end

    Lita.register_handler(DebugQueue)
  end
end
