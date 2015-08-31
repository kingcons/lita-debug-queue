module Lita
  module Handlers
    class RoomFinder
      def self.for(rooms, response)
        sender = response.user.mention_name
        room = response.message.source.room_object
        if rooms.has_key?(sender)
          name = rooms[sender]
          RoomQueue.new(name)
        elsif room
          name = self.get_room_name(room)
          RoomQueue.new(name)
        end
      end

      # KLUDGE: The following is a hack as the current room_object is incorrect. (lita-slack issue #44)
      def self.get_room_name(room)
        # KLUDGE: And this conditional is a hack since the test rooms are mocked.
        room.id == room.name ? room.name : Lita::Room.find_by_id(room.id).name(room)
      end
    end
  end
end
