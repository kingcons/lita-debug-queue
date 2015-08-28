require "spec_helper"

describe Lita::Handlers::HelpQueue, lita_handler: true do
  ## Routes
  it { is_expected.to route_command("halp me").to(:add) }
  it { is_expected.to route_command("halp nvm").to(:cancel) }
  it { is_expected.to route_command("halp queue").to(:show) }
  it { is_expected.to route_command("halp count").to(:count) }
  it { is_expected.to route_command("halp next").with_authorization_for(:instructors).to(:next) }
  it { is_expected.to route_command("halp drop phteven").with_authorization_for(:instructors).to(:drop) }
  it { is_expected.to route_command("halp clear").with_authorization_for(:instructors).to(:clear) }

  ## General Commands
  context "bot commands" do
    let(:dylan)  { Lita::User.create(123, mention_name: "dylan") }
    let(:rails)  { Lita::Room.new(name: "rails") }
    let(:ocaml)  { Lita::Room.new(name: "ocaml") }
    let(:vedika) { Lita::User.create(456, mention_name: "vedika") }
    let(:brit)   { Lita::User.create(789, mention_name: "brit") }

    it "allows users to queue themselves for help" do
      send_command("halp me", as: dylan, from: rails)
      expect(replies.last).to start_with("dylan: Help is on the way.")
    end

    it "doesn't allow users to queue themselves twice" do
      send_command("halp me", as: dylan, from: rails)
      send_command("halp me", as: dylan, from: rails)
      expect(replies.last).to start_with("dylan: Easy there killer. You're already on the list.")
    end

    it "allows users to remove themselves if they figure it out" do
      send_command("halp me", as: dylan, from: rails)
      send_command("halp nvm", as: dylan, from: rails)
      expect(replies.last).to start_with("dylan: Glad you figured it out! :)")
    end

    it "doesn't allow users to remove themselves if they aren't in the queue" do
      send_command("halp nvm", as: dylan, from: rails)
      expect(replies.last).to start_with("dylan: You know you're not in the queue right?")
    end

    it "allows users to get an up to date count of people in that room's queue" do
      send_command("halp me", as: vedika, from: rails)
      send_command("halp count", from: rails)
      expect(replies.last).to start_with("Hackers seeking fresh eyes: 1")

      send_command("halp count", from: ocaml)
      expect(replies.last).to start_with("Hackers seeking fresh eyes: 0")

      send_comand("halp me", as: dylan, from: rails)
      send_command("halp count", from: rails)
      expect(replies.last).to start_with("Hackers seeking fresh eyes: 2")

      send_command("halp nvm", as: vedika, from: rails)
      send_command("halp count", from: rails)
      expect(replies.last).to start_with("Hackers seeking fresh eyes: 1")
    end

    ## Instructor Commands
    it "allows instructors to notify the next student and pop them from the queue" do
      send_command("halp me", as: vedika, from: rails)
      send_command("halp next", as: brit)
      expect(replies.last).to start_with("Vedika is up next and has been notified.")
      send_command("halp count", from: rails)
      expect(replies.last).to start_with("Hackers seeking fresh eyes: 0")
    end

    it "allows instructors to remove a student from the queue by name" do
      send_command("halp me", as: dylan, from: rails)
      send_command("halp drop dylan", as: brit)
      expect(replies.last).to start_with("Dylan has been removed from the queue.")
      send_command("halp count", from: rails)
      expect(replies.last).to start_with("Hackers seeking fresh eyes: 0")
    end

    it "allows instructors to clear the queue completely" do
      send_command("halp me", as: vedika, from: rails)
      send_command("halp me", as: dylan, from: rails)
      send_command("halp clear", as: brit)
      send_command("halp count", from: rails)
      expect(replies.last).to start_with("Hackers seeking fresh eyes: 0")
    end
  end
end
