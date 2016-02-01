require 'rails_helper'

describe User::OmniauthCallbacks, type: :model do
  let(:callback) { Class.new.extend(User::OmniauthCallbacks) }
  let(:data) { { 'email' => 'email@example.com', 'nickname' => '_why', 'name' => 'why' } }
  let(:uid) { '42' }

  describe 'new_from_provider_data' do
    it 'should respond to :new_from_provider_data' do
      expect(callback).to respond_to(:new_from_provider_data)
    end

    it 'should create a new user' do
      expect(callback.new_from_provider_data(nil, nil, data)).to be_a(User)
    end

    it 'should handle provider twitter properly' do
      result = callback.new_from_provider_data('twitter', uid, data)
      expect(result.email).to eq('email@example.com')
    end

    it 'should handle provider douban properly' do
      expect(callback.new_from_provider_data('douban', uid, data).email).to eq('email@example.com')
    end

    it 'should handle provider google properly' do
      data['name'] = 'the_lucky_stiff'
      expect(callback.new_from_provider_data('google', uid, data).login).to eq('the_lucky_stiff')
    end

    it 'should escape illegal characters in nicknames properly' do
      data['nickname'] = 'I <3 Rails'
      expect(callback.new_from_provider_data(nil, nil, data).login).to eq('I__3_Rails')
    end

    it 'should generate random login if login is empty' do
      data['nickname'] = ''
      time = Time.now
      allow(Time).to receive(:now).and_return(time)
      expect(callback.new_from_provider_data(nil, nil, data).login).to eq("u#{time.to_i}")
    end

    it 'should generate random login if login is duplicated' do
      callback.new_from_provider_data(nil, nil, data).save # create a new user first
      time = Time.now
      allow(Time).to receive(:now).and_return(time)
      expect(callback.new_from_provider_data(nil, nil, data).login).to eq("u#{time.to_i}")
    end

    it 'should generate some random password' do
      expect(callback.new_from_provider_data(nil, nil, data).password).not_to be_blank
    end

    it 'should set user location' do
      data['location'] = 'Shanghai'
      expect(callback.new_from_provider_data(nil, nil, data).location).to eq('Shanghai')
    end

    it 'should set user tagline' do
      description = data['description'] = 'A newbie Ruby developer'
      expect(callback.new_from_provider_data(nil, nil, data).tagline).to eq(description)
    end
  end
end
