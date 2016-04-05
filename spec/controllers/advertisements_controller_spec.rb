require 'rails_helper'

describe AdvertisementsController, type: :controller do
  describe ':show' do
    it 'redirects to adv link' do
      get :show
      expect(response).to redirect_to 'https://jinshuju.net/f/uYwnaM'
    end
  end
end
