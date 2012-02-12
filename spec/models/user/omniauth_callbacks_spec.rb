require "spec_helper"

describe User::OmniauthCallbacks do
  let(:callback) { Class.new.extend(User::OmniauthCallbacks) }
  let(:data) { { "email" => "email@example.com", "nickname" => "_why" } }
  let(:uid) { "42" }

  describe "new_from_provider_data" do
    it "should respond to :new_from_provider_data" do
      callback.should respond_to(:new_from_provider_data)
    end

    it "should create a new user" do
      callback.new_from_provider_data(nil, nil, data).should be_a(User)
    end

    it "should handle provider twitter properly" do
      user = callback.new_from_provider_data("twitter", uid, data).email.should == "twitter+42@example.com"
    end

    it "should handle provider douban properly" do
      callback.new_from_provider_data("douban", uid, data).email.should == "douban+42@example.com"
    end

    it "should handle provider google properly" do
      data["name"] = "the_lucky_stiff"
      callback.new_from_provider_data("google", uid, data).login.should == "the_lucky_stiff"
    end

    it "should escape illegal characters in nicknames properly" do
      data["nickname"] = "I <3 Rails"
      callback.new_from_provider_data(nil, nil, data).login.should == "I__3_Rails"
    end

    it "should generate random login if login is empty" do
      data["nickname"] = ""
      time = Time.now
      Time.stub(:now).and_return(time)
      callback.new_from_provider_data(nil, nil, data).login.should == "u#{time.to_i}"
    end

    it "should generate random login if login is duplicated" do
      callback.new_from_provider_data(nil, nil, data).save # create a new user first
      time = Time.now
      Time.stub(:now).and_return(time)
      callback.new_from_provider_data(nil, nil, data).login.should == "u#{time.to_i}"
    end

    it "should generate some random password" do
      callback.new_from_provider_data(nil, nil, data).password.should_not be_blank
    end

    it "should set user location" do
      data["location"] = "Shanghai"
      callback.new_from_provider_data(nil, nil, data).location.should == "Shanghai"
    end

    it "should set user tagline" do
      description = data["description"] = "A newbie Ruby developer"
      callback.new_from_provider_data(nil, nil, data).tagline.should == description
    end
  end
end
