require "spec_helper"

describe Lita::Handlers::Chatterbox, lita_handler: true do
  describe "#greet" do
    let(:user)     { Lita::User.create(123, name: "Carl") }
    let(:greeting) { described_class.greetings.first }

    before do
      allow(subject).to receive(:random_greet).and_return(greeting)
    end

    it "replies to a greeting" do
      send_message(greeting, as: user)
      expect(replies.last).to eq("#{greeting} @#{user.mention_name}!")
    end

    it "sets a cooldown for the user" do
      now = Time.now; allow(Time).to receive(:now).and_return(now)
      expect(subject.redis).to receive(:hset).with(user.id, described_class::GREETINGS_COOLDOWN_KEY, Time.now + subject.config.cooldown.seconds)
      send_message(greeting, as: user)
    end

    it "doesn't reply twice to the same user because of cooldown" do
      send_message(greeting, as: user)
      send_message(greeting, as: user)
      expect(replies.size).to eq 1
    end

  end
end
