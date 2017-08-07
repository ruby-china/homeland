require 'rails_helper'

describe UsersController, type: :routing do
  describe 'routing' do
    it 'can use dot in params' do
      expect(get('/foo')).to route_to('users#show', id: 'foo')
      expect(get('/foo1')).to route_to('users#show', id: 'foo1')
      expect(get('/1234')).to route_to('users#show', id: '1234')
      expect(get('/foo-bar')).to route_to('users#show', id: 'foo-bar')
      expect(get('/foo_bar')).to route_to('users#show', id: 'foo_bar')
      expect(get('/foo_')).to route_to('users#show', id: 'foo_')
      expect(get('/foo.bar')).to route_to('users#show', id: 'foo.bar')
      expect(put('/admin/users/foo.bar')).to route_to('admin/users#update', id: 'foo.bar')
    end
  end
end
