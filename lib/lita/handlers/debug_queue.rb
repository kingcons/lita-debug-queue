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
      route(/^debug next$/, :next, command: true,
        restrict_to: [:instructors, :assistants],
        help: { 'debug next' => 'Notify the next student to be helped.' })
      route(/^debug drop\s+(.+)$/, :drop, command: true,
        restrict_to: [:instructors, :assistants],
        help: { 'debug drop NAME' => 'Remove the student with NAME from the queue.' })
      route(/^debug clear$/, :clear, command: true, restrict_to: [:instructors],
        help: { 'debug clear' => 'Empty the queue.' })

      def add(response)
        return unless check_room!(response)
        student = response.user.mention_name
        if @room.include?(student)
          response.reply("#{student}: Easy there killer. You're already on the list.")
        else
          @room.add(student)
          response.reply("#{student}: Help is coming soon.")
        end
      end

      def cancel(response)
        return unless check_room!(response)
        student = response.user.mention_name
        if @room.include?(student)
          @room.remove(student)
          response.reply("#{student}: Glad you figured it out! :)")
        else
          response.reply("#{student}: You know you're not in the queue, right?")
        end
      end

      def show(response)
        return unless check_room!(response)
        response.reply("Queue for #{@room.name} => #{@room.queue}")
      end

      def count(response)
        return unless check_room!(response)
        response.reply("Hackers seeking fresh eyes: #{@room.count} in #{@room.name}")
      end

      def next(response)
        return unless check_room!(response)
        if @room.count.zero?
          response.reply("The queue is empty. Sounds like you could use a break. :)")
        else
          student = @room.next
          target = target_for(student)
          robot.send_message(target, "@#{student}: You're up. Let's debug :allthethings:!")
          response.reply("#{student} is up next and has been notified.")
        end
      end

      def drop(response)
        return unless check_room!(response)
        student = response.args[1]
        if @room.include?(student)
          @room.remove(student)
          response.reply("#{student} has been removed from the queue.")
        else
          response.reply("#{student} is not in the queue for #{@room}!")
        end
      end

      def clear(response)
        return unless check_room!(response)
        @room.clear!
        response.reply("Sounds like time for :beer: and ping pong!")
      end

      private

      def check_room!(response)
        @room = RoomFinder.for(config.classrooms, response, redis)
        response.reply_privately("You must be in the class channel to send this message.") unless @room
        @room
      end

      def target_for(name)
        Lita::Source.new(user: Lita::User.find_by_mention_name(name))
      end
    end

    Lita.register_handler(DebugQueue)
  end
end
