require "spec_helper"

describe Lita::Handlers::DebugQueue, lita_handler: true do
  let(:vedika) { Lita::User.create(456, mention_name: "vedika") }
  let(:brit)   { Lita::User.create(789, mention_name: "brit") }
  let(:dylan)  { Lita::User.create(123, mention_name: "dylan") }
  let(:rails)  { Lita::Room.new("rails") }

  before(:each) do
    allow(Lita::Handlers::RoomFinder).to receive(:get_room_name) do |room|
      room.name
    end
    registry.config.handlers.debug_queue.classrooms = {
      'brit' => 'rails'
    }
    @auth = Lita::Authorization.new(registry.config)
    @auth.add_user_to_group!(brit, :instructors)
  end

  ## Routes
  it { is_expected.to route_command("debug me").to(:add) }
  it { is_expected.to route_command("debug nvm").to(:cancel) }
  it { is_expected.to route_command("debug queue").to(:show) }
  it { is_expected.to route_command("debug count").to(:count) }
  it { is_expected.to route_command("debug next").with_authorization_for(:instructors).to(:next) }
  it { is_expected.to route_command("debug drop phteven").with_authorization_for(:instructors).to(:drop) }
  it { is_expected.to route_command("debug clear").with_authorization_for(:instructors).to(:clear) }

  context "a general user" do
    let(:ocaml)  { Lita::Room.new("ocaml") }

    it "can't send messages outside the class channel" do
      ["debug me", "debug nvm", "debug queue", "debug count"].each do |cmd|
        send_command(cmd, as: dylan)
        expect(replies.last).to start_with("You must be in the class channel")
      end
    end

    it "can queue themselves for help" do
      send_command("debug me", as: dylan, from: rails)
      expect(replies.last).to start_with("dylan: Help is ")
    end

    it "can't queue themselves twice" do
      send_command("debug me", as: dylan, from: rails)
      send_command("debug me", as: dylan, from: rails)
      expect(replies.last).to start_with("dylan: Easy there killer. You're already on the list.")
    end

    it "can remove themselves if they figure it out" do
      send_command("debug me", as: dylan, from: rails)
      send_command("debug nvm", as: dylan, from: rails)
      expect(replies.last).to start_with("dylan: Glad you figured it out! :)")
    end

    it "can't remove themselves if they aren't in the queue" do
      send_command("debug nvm", as: dylan, from: rails)
      expect(replies.last).to start_with("dylan: You know you're not in the queue, right?")
    end

    it "can get an up to date count of people in that room's queue" do
      send_command("debug me", as: vedika, from: rails)
      send_command("debug count", from: rails)
      expect(replies.last).to start_with("Hackers seeking fresh eyes: 1")

      send_command("debug count", from: ocaml)
      expect(replies.last).to start_with("Hackers seeking fresh eyes: 0")

      send_command("debug me", as: dylan, from: rails)
      send_command("debug count", from: rails)
      expect(replies.last).to start_with("Hackers seeking fresh eyes: 2")

      send_command("debug nvm", as: vedika, from: rails)
      send_command("debug count", from: rails)
      expect(replies.last).to start_with("Hackers seeking fresh eyes: 1")
    end
  end

  context "an instructor" do
    it "doesn't need to say messages in channel since their classroom is known" do
      send_command("debug count", as: brit)
      expect(replies.last).to start_with("Hackers seeking fresh eyes: 0")
    end

    it "can notify the next student and pop them from the queue" do
      send_command("debug me", as: vedika, from: rails)
      send_command("debug me", as: dylan, from: rails)
      send_command("debug next", as: brit)
      expect(replies.last).to start_with("vedika is up next and has been notified.")
      send_command("debug count", from: rails)
      expect(replies.last).to start_with("Hackers seeking fresh eyes: 1")
    end

    it "can remove a student from the queue by name" do
      send_command("debug me", as: dylan, from: rails)
      send_command("debug drop dylan", as: brit)
      expect(replies.last).to start_with("dylan has been removed from the queue.")
      send_command("debug count", from: rails)
      expect(replies.last).to start_with("Hackers seeking fresh eyes: 0")
    end

    it "can clear the queue completely" do
      send_command("debug me", as: vedika, from: rails)
      send_command("debug me", as: dylan, from: rails)
      send_command("debug clear", as: brit)
      expect(replies.last).to start_with("Sounds like time for :beer: and ping pong!")
      send_command("debug count", from: rails)
      expect(replies.last).to start_with("Hackers seeking fresh eyes: 0")
    end
  end
end
