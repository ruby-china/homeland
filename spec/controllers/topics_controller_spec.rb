require 'rails_helper'

describe TopicsController, type: :controller do
  render_views
  let(:topic) { create :topic, user: user }
  let(:user) { create :avatar_user }
  let(:newbie) { create :newbie }
  let(:node) { create :node }
  let(:admin) { create :admin }
  let(:team) { create :team }

  describe ':index' do
    it 'should have an index action' do
      get :index
      expect(response).to be_success
    end

    it 'should work when login' do
      sign_in user
      get :index
      expect(response).to be_success
    end

    it 'should 404 with non integer :page value' do
      get :index, params: { page: '2/*' }
      expect(response.status).to eq(200)
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

  describe ':excellent' do
    it 'should have a excellent action' do
      get :excellent
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

  describe ':no_reply' do
    it 'should have a no_reply action' do
      get :no_reply, params: { id: topic.id }
      expect(response).to be_success
    end
  end

  describe ':popular' do
    it 'should have a popular action' do
      get :popular, params: { id: topic.id }
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

      it 'should render 404 for invalid node id' do
        sign_in user
        get :new, params: { node: (node.id + 1) }
        expect(response).not_to be_success
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

  describe ':create' do
    context 'unauthenticated' do
      it 'should not allow anonymous access' do
        post :create, params: { id: topic.id }
        expect(response).not_to be_success
      end
    end

    context 'authenticated' do
      it 'should allow access from authenticated user' do
        sign_in user
        post :create, params: { format: :js, topic: { title: 'new topic', body: 'new body', node_id: node } }
        expect(response).to be_success
      end
      it 'should allow access from authenticated user with team' do
        sign_in user
        post :create, params: { format: :js, topic: { title: 'new topic', body: 'new body', node_id: node, team_id: team.id } }
        expect(response).to be_success
      end
    end
  end

  describe ':preview' do
    it 'should work' do
      sign_in user
      post :preview, params: { format: :json, body: 'new body' }
      expect(response).to be_success
    end
  end

  describe ':update' do
    it 'should work' do
      sign_in user
      topic = create :topic, user_id: user.id, title: 'new title', body: "new body"
      put :update, params: { format: :js, id: topic.id, topic: { title: 'new topic 2', body: 'new body 2' } }
      expect(response).to be_success
    end

    it 'should update with admin user' do
      # new_node = create(:node)
      sign_in admin
      put :update, params: { format: :js, id: topic.id, topic: { title: 'new topic 2', body: 'new body 2', node_id: node } }
      expect(response.status).to eq 200
      topic.reload
      expect(topic.lock_node).to eq true
    end
  end

  describe ':destroy' do
    it 'should work' do
      sign_in user
      topic = create :topic, user_id: user.id, title: 'new title', body: "new body"
      delete :destroy, params: { id: topic.id }
      expect(response).to redirect_to(topics_path)
    end
  end

  describe ':favorite' do
    it 'should work' do
      sign_in user
      post :favorite, params: { id: topic.id }
      expect(response).to be_success
      expect(response.body).to eq '1'
    end
  end

  describe ':unfavorite' do
    it 'should work' do
      sign_in user
      delete :unfavorite, params: { id: topic.id }
      expect(response).to be_success
      expect(response.body).to eq '1'
    end
  end

  describe ':follow' do
    it 'should work' do
      sign_in user
      post :follow, params: { id: topic.id }
      expect(response).to be_success
      expect(response.body).to eq '1'
    end
  end

  describe ':unfollow' do
    it 'should work' do
      sign_in user
      delete :unfollow, params: { id: topic.id }
      expect(response).to be_success
      expect(response.body).to eq '1'
    end
  end

  describe '#show' do
    it 'should clear user mention notification when show topic' do
      user = create :user
      topic = create :topic, body: "@#{user.login}", node_id: Node.job.id
      create :reply, body: "@#{user.login}", topic: topic, like_by_user_ids: [user.id]
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

  describe '#close' do
    it 'should not allow user close' do
      sign_in user
      post :action, params: { id: topic, type: 'close' }
      expect(topic.reload.node_id).not_to eq(Node.no_point.id)
    end

    it 'should not allow user suggest by admin' do
      sign_in admin
      post :action, params: { id: topic, type: 'close' }
      expect(response.status).to eq(302)
      expect(topic.reload.closed_at).to be_present
    end
  end

  describe '#open' do
    it 'should not allow user close' do
      sign_in user
      post :action, params: { id: topic, type: 'open' }
      expect(topic.reload.node_id).not_to eq(Node.no_point.id)
    end

    it 'should not allow user suggest by admin' do
      sign_in admin
      topic.close!
      post :action, params: { id: topic, type: 'open' }
      expect(response.status).to eq(302)
      expect(topic.reload.closed_at).to be_blank
    end
  end
end
