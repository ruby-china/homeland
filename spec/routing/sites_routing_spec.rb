require 'rails_helper'

describe SitesController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get('/sites')).to route_to('sites#index')
    end

    it 'routes to #new' do
      expect(get('/sites/new')).to route_to('sites#new')
    end

    it 'routes to #edit' do
      expect(get('/sites/1/edit')).to route_to('sites#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post('/sites')).to route_to('sites#create')
    end
  end
end
