module Lita
  module Handlers
    class Chatterbox < Handler
      # Constants
      GREETINGS_COOLDOWN_KEY = "greetings_cooldown"

      # Default Configuration
      def self.default_config(config)
        config.enabled  = true
        config.cooldown = 60
      end

      def self.greetings
        t("greetings")
      end

      route /(#{greetings.join('|')})\s+/, :greet
      route /^(#{greetings.join('|')})$/,  :greet

      route /^say\s+(.+)/, :say, :command => true

      def random_greet
        self.class.greetings.shuffle.first
      end

      def greet(response)
        return unless config.enabled
        user = response.user
        if !is_in_cooldown?(user)
          response.reply("#{random_greet} @#{user.mention_name}!")
          set_cooldown(user)
        end
      end

      def set_cooldown(user)
        redis.set(cache_key(user), true)
        redis.expire(cache_key(user), config.cooldown)
      end

      def is_in_cooldown?(user)
        !!redis.get(cache_key(user))
      end

      def cache_key(user)
        "#{user.id}_#{GREETINGS_COOLDOWN_KEY}"
      end

      def say(response)
        response.reply response.matches
      end

    end

    Lita.register_handler(Chatterbox)
  end
end
