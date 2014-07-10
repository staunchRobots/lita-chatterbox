require "lita"
require 'active_support'
require 'active_support/core_ext'

Lita.load_locales Dir[File.expand_path(
  File.join("..", "..", "locales", "*.yml"), __FILE__
)]

require "lita/handlers/chatterbox"
