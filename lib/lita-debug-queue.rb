require "lita"

Lita.load_locales Dir[File.expand_path(
  File.join("..", "..", "locales", "*.yml"), __FILE__
)]

require "lita/handlers/room_finder"
require "lita/handlers/room_queue"
require "lita/handlers/debug_queue"

Lita::Handlers::DebugQueue.template_root File.expand_path(
  File.join("..", "..", "templates"),
 __FILE__
)
