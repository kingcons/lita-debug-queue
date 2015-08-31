module Lita
  module Handlers
    class DebugQueue < Handler
      config :classrooms # A mapping from instructor names to classroom channels.

      route(/^debug me$/, :add, command: true,
        help: { 'debug me' => 'Put your name in the queue for debugging help.' })
      route(/^debug nvm$/, :cancel, command: true,
        help: { 'debug nvm' => 'Remove your name from the queue for debugging help.' })
      route(/^debug queue$/, :show, command: true,
        help: { 'debug queue' => 'Show the current queue for your class.' })
      route(/^debug count$/, :count, command: true,
        help: { 'debug count' => 'Count the number of people waiting for help.' })
      route(/^debug next$/, :next, command: true, restrict_to: [:instructors],
        help: { 'debug next' => 'Notify the next student to be helped.' })
      route(/^debug drop\s+(.+)$/, :drop, command: true, restrict_to: [:instructors],
        help: { 'debug drop NAME' => 'Remove the student with NAME from the queue.' })
      route(/^debug clear$/, :clear, command: true, restrict_to: [:instructors],
        help: { 'debug clear' => 'Empty the queue.' })

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
          redis.set(@room, room_queue.reject { |x| x == student })
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
        return unless check_room!(response)
        student = room_queue.pop
        if student
          redis.set(@room, room_queue.reject { |x| x == student })
          robot.send_message(response.user, "@#{student}: You're up! Let's debug :allthethings:")
          response.reply("#{student} is up next and has been notified.")
        else
          response.reply("The queue is empty. You don't need to see any students!")
        end
      end

      def drop(response)
        return unless check_room!(response)
        student = response.args[1]
        if room_queue.include?(student)
          redis.set(@room, room_queue.reject { |x| x == student })
          response.reply("#{student} has been removed from the queue.")
        else
          response.reply("#{student} is not in the queue for #{@room}!")
        end
      end

      def clear(response)
        return unless check_room!(response)
        redis.del(@room)
        response.reply("Sounds like time for :beer: and ping pong!")
      end

      private

      def check_room!(response)
        speaker = response.user.mention_name
        if config.classrooms.has_key?(speaker)
          @room = config.classrooms[speaker]
        elsif response.message.source.room
          @room = get_room_name(response.message.source.room_object)
        end
        response.reply_privately("You must be in the class channel to send this message.") unless @room
        @room
      end

      # KLUDGE: The following is a hack as the current room_object is incorrect. (lita-slack issue #44)
      def get_room_name(room)
        # KLUDGE: And this conditional is a hack since the test rooms are mocked.
        room.id == room.name ? room.name : Lita::Room.find_by_id(room.id).name(room)
      end

      def room_queue
        data = redis.get(@room)
        data ? MultiJson.load(data) : []
      end
    end

    Lita.register_handler(DebugQueue)
  end
end
