require 'rails_helper'

describe TopicsController, type: :controller do
  render_views
  let(:topic) { create :topic, user: user }
  let(:user) { create :avatar_user }
  let(:newbie) { create :newbie }
  let(:admin) { create :admin }

  describe ':index' do
    it 'should have an index action' do
      get :index
      expect(response).to be_success
    end
  end

  describe ':feed' do
    it 'should have a feed action' do
      get :feed
      expect(response.headers['Content-Type']).to eq('application/xml; charset=utf-8')
      expect(response).to be_success
    end
  end

  describe ':recent' do
    it 'should have a recent action' do
      get :recent
      expect(response).to be_success
    end
  end

  describe ':favorites' do
    it 'should have a recent action' do
      sign_in user
      get :favorites
      expect(response).to be_success
    end
  end

  describe ':node' do
    it 'should have a node action' do
      get :node, params: { id: topic.id }
      expect(response).to be_success
    end
  end

  describe ':node_feed' do
    it 'should have a node_feed action' do
      get :node_feed, params: { id: topic.id }
      expect(response).to be_success
    end
  end

  describe ':new' do
    describe 'unauthenticated' do
      it 'should not allow anonymous access' do
        get :new
        expect(response).not_to be_success
      end
    end

    describe 'authenticated' do
      it 'should allow access from authenticated user' do
        sign_in user
        get :new
        expect(response).to be_success
      end

      it 'should not allow access from newbie user' do
        sign_in newbie
        get :new
        expect(response).not_to be_success
      end
    end
  end

  describe ':edit' do
    context 'unauthenticated' do
      it 'should not allow anonymous access' do
        get :edit, params: { id: topic.id }
        expect(response).not_to be_success
      end
    end

    context 'authenticated' do
      context 'own topic' do
        it 'should allow access from authenticated user' do
          sign_in user
          get :edit, params: { id: topic.id }
          expect(response).to be_success
        end
      end

      context "other's topic" do
        it "should not allow edit other's topic" do
          other_user = create :user
          topic_of_other_user = create(:topic, user: other_user)
          sign_in user
          get :edit, params: { id: topic_of_other_user.id }
          expect(response).not_to be_success
        end
      end
    end
  end

  describe '#show' do
    it 'should clear user mention notification when show topic' do
      user = create :user
      topic = create :topic, body: "@#{user.login}"
      create :reply, body: "@#{user.login}", topic: topic
      sign_in user
      expect do
        get :show, params: { id: topic.id }
      end.to change(user.notifications.unread, :count).by(-2)
    end
  end

  describe '#suggest' do
    it 'should not allow user suggest' do
      sign_in user
      post :action, params: { id: topic, type: 'excellent' }
      expect(topic.reload.excellent).to eq(0)
    end

    it 'should not allow user suggest by admin' do
      sign_in admin
      post :action, params: { id: topic, type: 'excellent' }
      expect(topic.reload.excellent).to eq(1)
    end
  end

  describe '#unsuggest' do
    context 'suggested topic' do
      let!(:topic) { create(:topic, excellent: 1) }

      it 'should not allow user suggest' do
        sign_in user
        post :action, params: { id: topic, type: 'unexcellent' }
        expect(topic.reload.excellent).to eq(1)
      end

      it 'should not allow user suggest by admin' do
        sign_in admin
        post :action, params: { id: topic, type: 'unexcellent' }
        expect(topic.reload.excellent).to eq(0)
      end
    end
  end

  describe '#ban' do
    it 'should not allow user ban' do
      sign_in user
      post :action, params: { id: topic, type: 'ban' }
      expect(topic.reload.node_id).not_to eq(Node.no_point.id)
    end

    it 'should not allow user suggest by admin' do
      sign_in admin
      post :action, params: { id: topic, type: 'ban' }
      expect(response.status).to eq(302)
      expect(topic.reload.node_id).to eq(Node.no_point.id)
    end
  end
end
