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

    describe ':create' do
      it 'should have an create action' do
        post :create, params: { note: { title: 'new note', body: 'new body', publish: 1 } }
        expect(response).to redirect_to(note_path(Note.find_by_title('new body')))
      end

      it 'should render new when save failure' do
        allow_any_instance_of(Note).to receive(:save).and_return(false)
        post :create, params: { note: { title: 'new note', body: 'new body', publish: 1 } }
        expect(response).to be_success
      end
    end

    describe ':update' do
      it 'should have an update action' do
        post :update, params: { id: note, note: { title: 'new note', body: 'new body', publish: 1 } }
        expect(response).to redirect_to(note_path(note))
      end

      it 'should render new when save failure' do
        allow_any_instance_of(Note).to receive(:update_attributes).and_return(false)
        post :update, params: { id: note, note: { title: 'new note', body: 'new body', publish: 1 } }
        expect(response).to be_success
      end
    end

    describe ':destroy' do
      it 'should have an update action' do
        post :destroy, params: { id: note }
        expect(response).to redirect_to(notes_path)
      end
    end

    describe ':show' do
      it 'should have a show action' do
        get :show, params: { id: note.id }
        expect(response).to be_success
      end
    end

    describe ':preview' do
      it 'should have a preview action' do
        get :preview, params: { body: '# markdown' }
        expect(response).to be_success
        expect(response.body).to eq('<h2 id="markdown">markdown</h2>')
      end
    end
  end
end
