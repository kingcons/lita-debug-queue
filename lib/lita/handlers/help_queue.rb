module Lita
  module Handlers
    class HelpQueue < Handler
      route(/^halp me$/, :add, command: true, help: { })
      route(/^halp nvm$/, :cancel, command: true, help: { })
      route(/^halp queue$/, :show, command: true, help: { })
      route(/^halp count$/, :count, command: true, help: { })
      route(/^halp next$/, :next, command: true, restrict_to: [:instructors],
        help: { })
      route(/^halp drop\s+(.+)$/, :drop, command: true, restrict_to: [:instructors],
        help: { })
      route(/^halp clear$/, :clear, command: true, restrict_to: [:instructors],
        help: { })

      def add(response)
      end

      def cancel(response)
      end

      def show(response)
      end

      def count(response)
      end

      def next(response)
      end

      def drop(response)
      end

      def clear(response)
      end

      Lita.register_handler(self)
    end
  end
end
