require 'rails_helper'

describe NotificationsController, type: :controller do
  let(:user) { create :user }
  describe '#index' do
    it 'should show notifications' do
      sign_in user
      create :notification_mention, user: user, mentionable: create(:reply)
      create :notification_topic_reply, user: user
      get :index
      expect(response).to render_template(:index)
    end
  end

  describe '#destroy' do
    it 'should destroy notification' do
      sign_in user
      notification = create :notification_mention, user: user, mentionable: create(:reply)

      expect do
        delete :destroy, id: notification
      end.to change(user.notifications, :count)
    end
  end

  describe '#clear' do
    it 'should clear all' do
      sign_in user
      3.times { create :notification_mention, user: user, mentionable: create(:reply) }

      post :clear
      expect(user.notifications.unread.count).to eq(0)
    end
  end
end
