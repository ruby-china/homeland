require 'rails_helper'

describe NodesController, type: :controller do
  it 'should have an index action' do
    get :index
    expect(response).to be_success
  end
end
