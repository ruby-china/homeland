# frozen_string_literal: true

require "rails_helper"

describe User::Omniauthable, type: :model do
  class Monkey
    include User::Omniauthable
  end

  let(:data) { { "email" => "email@example.com", "nickname" => "_why", "name" => "why" } }
  let(:uid) { "42" }

  describe "new_from_provider_data" do
    it "should respond to :new_from_provider_data" do
      expect(Monkey).to respond_to(:new_from_provider_data)
    end

    it "should create a new user" do
      expect(Monkey.new_from_provider_data(nil, nil, data)).to be_a(User)
    end

    it "should handle provider twitter properly" do
      result = Monkey.new_from_provider_data("twitter", uid, data)
      expect(result.email).to eq("email@example.com")
    end

    it "should handle provider github properly" do
      result = Monkey.new_from_provider_data("github", uid, data)
      expect(result.email).to eq("email@example.com")
    end

    it "should escape illegal characters in nicknames properly" do
      data["nickname"] = "I <3 Rails"
      expect(Monkey.new_from_provider_data(nil, nil, data).login).to eq("I__3_Rails")
    end

    it "should generate random login if login is empty" do
      data["nickname"] = ""
      time = Time.now
      allow(Time).to receive(:now).and_return(time)
      expect(Monkey.new_from_provider_data(nil, nil, data).login).to eq("u#{time.to_i}")
    end

    it "should generate random login if login is duplicated" do
      Monkey.new_from_provider_data("github", nil, data).save # create a new user first
      time = Time.now
      allow(Time).to receive(:now).and_return(time)
      expect(Monkey.new_from_provider_data("github", nil, data).login).to eq("#{data['nickname']}-github")
    end

    it "should generate some random password" do
      expect(Monkey.new_from_provider_data(nil, nil, data).password).not_to be_blank
    end

    it "should set user location" do
      data["location"] = "Shanghai"
      expect(Monkey.new_from_provider_data(nil, nil, data).location).to eq("Shanghai")
    end

    it "should set user tagline" do
      description = data["description"] = "A newbie Ruby developer"
      expect(Monkey.new_from_provider_data(nil, nil, data).tagline).to eq(description)
    end
  end
end
