require 'rails_helper'

describe JobsController, type: :controller do
  describe 'index' do
    it 'should work' do
      get :index
      expect(response).to be_success
      expect(response.body).to match(/招聘/)
    end
  end
end
