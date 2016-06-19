require 'rails_helper'

describe LikesController, type: :controller do
  let(:user) { create(:user) }
  let(:user2) { create(:user) }
  let(:topic) { create(:topic) }

  before(:each) do
    allow(controller).to receive(:current_user).and_return(user)
  end

  it 'POST /likes' do
    post :create, params: { type: 'Topic', id: topic.id }
    expect(response.body).to eq('1')
    expect(topic.reload.likes_count).to eq(1)

    post :create, params: { type: 'Topic', id: topic.id }
    expect(response.body).to eq('1')
    expect(topic.reload.likes_count).to eq(1)

    allow(controller).to receive(:current_user).and_return(user2)
    post :create, params: { type: 'Topic', id: topic.id }
    expect(response.body).to eq('2')
    expect(topic.reload.likes_count).to eq(2)

    allow(controller).to receive(:current_user).and_return(user)
    delete :destroy, params: { type: 'Topic', id: topic.id }
    expect(response.body).to eq('1')
    expect(topic.reload.likes_count).to eq(1)

    allow(controller).to receive(:current_user).and_return(user2)
    delete :destroy, params: { type: 'Topic', id: topic.id }
    expect(response.body).to eq('0')
    expect(topic.reload.likes_count).to eq(0)
  end

  it 'require login' do
    allow(controller).to receive(:current_user).and_return(nil)
    post :create
    expect(response.status).to eq(302)

    delete :destroy, params: { id: 1, type: 'a' }
    expect(response.status).to eq(302)
  end

  it 'result -1, -2 when params is wrong' do
    post :create, params: { type: 'Ask', id: 1 }
    expect(response.body).to eq('-1')

    delete :destroy, params: { type: 'Ask', id: 1 }
    expect(response.body).to eq('-1')

    post :create, params: { type: 'Topic', id: -1 }
    expect(response.body).to eq('-2')

    delete :destroy, params: { type: 'Topic', id: -1 }
    expect(response.body).to eq('-2')
  end
end
