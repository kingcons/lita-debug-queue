module Lita
  module Handlers
    class RoomFinder
      def self.for(rooms, response, redis)
        sender = response.user.mention_name
        room = response.message.source.room_object
        if rooms.has_key?(sender)
          name = rooms[sender]
          RoomQueue.new(name, redis)
        elsif room
          name = self.get_room_name(room)
          RoomQueue.new(name, redis)
        end
      end

      # KLUDGE: The following is a hack as the current room_object is incorrect. (lita-slack issue #44)
      def self.get_room_name(room)
        Lita::Room.find_by_id(room.id).name
      end
    end
  end
end
