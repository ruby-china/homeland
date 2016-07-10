require 'rails_helper'

describe JobsController, type: :controller do
  describe 'index' do
    let(:node) { create(:node) }
    it 'should work' do
      expect(Node).to receive(:jobs_id).and_return(node.id)
      get :index
      expect(response).to be_success
      expect(response.body).to match(/招聘/)
    end
  end
end
