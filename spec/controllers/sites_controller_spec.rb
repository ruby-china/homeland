require 'rails_helper'

describe SitesController, type: :controller do
  let(:user) { create :user, replies_count: 100 }
  let(:user1) { create :user }
  describe ':index' do
    it 'should have an index action' do
      get :index
      expect(response).to be_success
    end
  end

  describe ':new' do
    it 'should not allow anonymous access' do
      get :new
      expect(response).not_to be_success
    end

    it 'should allow access from authenticated user' do
      sign_in user
      get :new
      expect(response).to be_success
    end

    it 'should not allow access without use has replies_count less than 100' do
      sign_in user1
      get :new
      expect(response).not_to be_success
    end
  end

  describe ':create' do
    let(:site_node) { create :site_node }
    it 'should not allow anonymous access' do
      params = attributes_for(:site, site_node_id: site_node.id)
      post :create, params: { site: params } # avoids ActionController::ParameterMissing
      expect(response).not_to be_success
    end

    describe 'authenticated' do
      before(:each) do
        sign_in user
      end

      it 'should create new site if all is well' do
        params = attributes_for(:site, site_node_id: site_node.id)
        post :create, params: { site: params }
        expect(response).to redirect_to(sites_path)
      end

      it 'should not create new site if url is blank' do
        params = attributes_for(:site)
        params[:url] = ''
        expect do
          post :create, params: { site: params }
        end.to change(Site, :count).by(0)
        expect(response).to be_success
      end
    end
  end
end
