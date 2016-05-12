require 'rails_helper'

describe UsersController, type: :routing do
  describe 'routing' do
    it 'can use dot in params' do
      expect(get('/user.name')).to route_to('users#show')
      controller.params[:id].should eql 'user.name'
    end
  end
end
