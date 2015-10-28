require 'rails_helper'
require 'active_support/core_ext'

describe 'API', type: :request do
  let(:json) { JSON.parse(response.body) }

  describe 'Not found routes' do
    it 'should return status 404' do
      get '/api/v3/foo-bar.json'
      expect(response.status).to eq 404
      expect(json['error']).to eq 'Page not found.'
    end
  end

  describe 'GET /api/v3/hello.json' do
    context 'without oauth2' do
      it 'should faild with 401' do
        get '/api/v3/hello.json'
        expect(response.status).to eq(401)
        expect(json['error']).to eq 'The access token is invalid'
      end
    end

    context 'Simple test with oauth2' do
      it 'should work' do
        login_user!
        get '/api/v3/hello.json'
        expect(response.status).to eq 200
        expect(json['user']).to include(*%w(id name login avatar_url))
        expect(json['meta']).to include(*%w(time))
        expect(json['user']['login']).to eq current_user.login
        expect(json['user']['name']).to eq current_user.name
        expect(json['user']['avatar_url']).not_to be_nil
      end
    end

    describe 'Grape validation' do
      it 'should status 400 and give Grape validation errors' do
        login_user!
        get '/api/v3/hello.json', limit: 2000
        expect(response.status).to eq 400
        expect(json['validation_errors'].size).to eq 1
        expect(json['validation_errors']).to include(*%w(limit))
        expect(json['validation_errors']['limit'][0]).to include('valid value')
      end
    end
  end

  describe 'POST /api/v3/photos.json' do
    context 'without login' do
      it 'should response 401' do
        post '/api/v3/photos.json'
        expect(response.status).to eq 401
      end
    end

    context 'with login' do
      it 'should work' do
        login_user!
        f = File.open(Rails.root.join('spec/factories/foo.png'))
        post '/api/v3/photos.json', file: f
        @photo = Photo.last
        expect(@photo.user_id).to eq current_user.id
        expect(response.status).to eq 201
        expect(json['image_url']).not_to eq nil
        expect(json['image_url']).not_to eq ''
      end
    end
  end
end
