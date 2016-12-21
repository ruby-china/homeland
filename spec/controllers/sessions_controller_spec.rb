require 'rails_helper'

describe SessionsController, type: :controller do
  describe ':new' do
    before { request.env['devise.mapping'] = Devise.mappings[:user] }
    it 'should render new tempalte' do
      get :new
      expect(response).to be_success
    end

    context 'cache referrer' do
      it "should store referrer if it's from self site" do
        session['return_to'] = "/account/edit?id=123"
        old_return_to = session['return_to']
        get :new
        expect(session['return_to']).to eq(old_return_to)
      end
    end
  end
end
