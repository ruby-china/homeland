require 'rails_helper'

describe NotesController, type: :controller do
  describe 'unauthenticated' do
    it 'should not allow anonymous access' do
      get :index
      expect(response).not_to be_success
    end
  end

  describe 'authenticated' do
    let(:user) { create :user }
    let(:note) { create :note, user: user }

    before(:each) { sign_in user }

    describe ':index' do
      it 'should have an index action' do
        get :index
        expect(response).to be_success
      end
    end

    describe ':new' do
      it 'should have a new action' do
        get :new
        expect(response).to be_success
      end
    end

    describe ':edit' do
      it 'should have an edit action' do
        get :edit, params: { id: note.id }
        expect(response).to be_success
      end
    end

    describe ':show' do
      it 'should have a show action' do
        get :show, params: { id: note.id }
        expect(response).to be_success
      end
    end
  end
end
