require 'spec_helper'

describe Node do

  describe 'Validates' do
    it 'should fail saving without specifing a section' do
      node = Node.new
      node.name = "Cersei"
      node.summary = "the Queue"
      node.save == false
    end
  end

end
