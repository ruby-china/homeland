require 'rails_helper'

describe UsersController, type: :controller do
  let(:user) { create :user, location: 'Shanghai' }
  let(:deleted_user) { create :user, state: User.states[:deleted] }

  describe 'Visit deleted user' do
    it 'should 404 with deleted user' do
      get :show, params: { id: deleted_user.login }
      expect(response.status).to eq(404)
      get :topics, params: { id: deleted_user.login }
      expect(response.status).to eq(404)
      get :notes, params: { id: deleted_user.login }
      expect(response.status).to eq(404)
    end
  end

  describe ':index' do
    it 'should have an index action' do
      get :index
      expect(response).to be_success
    end
  end

  describe ':show' do
    it 'should show user' do
      get :show, params: { id: user.login }
      expect(response).to be_success
    end
  end

  describe ':topics' do
    it 'should show user topics' do
      get :topics, params: { id: user.login }
      expect(response).to be_success
    end

    it 'should redirect to right spell login' do
      get :topics, params: { id: user.login.upcase }
      expect(response.status).to eq(301)
    end
  end

  describe ':replies' do
    it 'should show user replies' do
      get :replies, params: { id: user.login }
      expect(response).to be_success
    end
  end

  describe ':favorites' do
    it 'should show user liked stuffs' do
      get :favorites, params: { id: user.login }
      expect(response).to be_success
    end
  end

  describe ':notes' do
    it 'should show user notes' do
      get :notes, params: { id: user.login }
      expect(response).to be_success
    end
  end

  describe ':city' do
    it 'should render 404 if there is no user in that city' do
      get :city, params: { id: 'Mars' }
      expect(response).not_to be_success
      expect(response.status).to eq(404)
    end

    it 'should show user associated with that city' do
      get :city, params: { id: user.location }
      expect(response.status).to eq(200)
    end
  end

  describe ':calendar' do
    it 'should work' do
      get :calendar, params: { id: user.login }
      expect(response.status).to eq(200)
    end
  end
end
