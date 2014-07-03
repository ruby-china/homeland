# coding: utf-8
require 'rails_helper'

describe LikesController, :type => :controller do
  let(:user) { Factory(:user) }
  let(:user2) { Factory(:user) }
  let(:topic) { Factory(:topic) }

  before(:each) do
    allow(controller).to receive(:current_user).and_return(user)
  end

  it "POST /likes" do
    post :create, :type => "Topic", :id => topic.id
    expect(response.body).to eq("1")
    expect(topic.reload.likes_count).to eq(1)

    post :create, :type => "Topic", :id => topic.id
    expect(response.body).to eq("1")
    expect(topic.reload.likes_count).to eq(1)

    allow(controller).to receive(:current_user).and_return(user2)
    post :create, :type => "Topic", :id => topic.id
    expect(response.body).to eq("2")
    expect(topic.reload.likes_count).to eq(2)

    allow(controller).to receive(:current_user).and_return(user)
    delete :destroy, :type => "Topic", :id => topic.id
    expect(response.body).to eq("1")
    expect(topic.reload.likes_count).to eq(1)

    allow(controller).to receive(:current_user).and_return(user2)
    delete :destroy, :type => "Topic", :id => topic.id
    expect(response.body).to eq("0")
    expect(topic.reload.likes_count).to eq(0)
  end

  it "require login" do
    allow(controller).to receive(:current_user).and_return(nil)
    post :create
    expect(response.status).to eq(302)

    delete :destroy, :id => 1, :type => "a"
    expect(response.status).to eq(302)
  end

  it "result -1, -2 when params is wrong" do
    post :create, :type => "Ask", :id => 1
    expect(response.body).to eq("-1")

    delete :destroy, :type => "Ask", :id => 1
    expect(response.body).to eq("-1")

    post :create, :type => "Topic", :id => -1
    expect(response.body).to eq("-2")

    delete :destroy, :type => "Topic", :id => -1
    expect(response.body).to eq("-2")
  end
end
