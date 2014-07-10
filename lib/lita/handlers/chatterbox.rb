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
        reply(user) unless is_in_cooldown?(user)
      end

      def reply(user)
        response.reply("#{random_greet} @#{user.mention_name}!")
        redis.hset(user.jid, GREETINGS_COOLDOWN_KEY, Time.now + config.cooldown.seconds)
      end

      def is_in_cooldown?(user)
        if cooldown = redis.hget(user.jid, GREETINGS_COOLDOWN_KEY)
          cooldown <= Time.now
        else
          false
        end
      end

      def say(response)
        response.reply response.matches
      end

    end

    Lita.register_handler(Chatterbox)
  end
end
