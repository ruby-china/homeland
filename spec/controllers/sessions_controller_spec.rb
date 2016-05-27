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
        referrer = "#{request.base_url}/account/edit"
        request.env['HTTP_REFERER'] = referrer
        get :new
        expect(session['user_return_to']).to eq referrer
      end

      it "should skip referrer if it's from other site" do
        referrer = "http://#{SecureRandom.hex(4)}.com"
        request.env['HTTP_REFERER'] = referrer
        get :new
        expect(session['user_return_to']).to eq nil
      end

      it 'should skip referrer if it is user sign in page' do
        referrer = "#{request.base_url}/account/sign_in"
        request.env['HTTP_REFERER'] = referrer
        get :new
        expect(session['user_return_to']).to eq nil
      end
    end
  end
end
