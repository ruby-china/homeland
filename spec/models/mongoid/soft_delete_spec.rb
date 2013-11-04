require 'spec_helper'

class WalkingDead
  include Mongoid::Document
  include Mongoid::BaseModel
  include Mongoid::Attributes::Dynamic
  include Mongoid::Timestamps
  include Mongoid::SoftDelete

  field :name
  field :tag
  
  after_destroy do
    self.tag = "after_destroy #{self.name}"
  end
end

describe "Soft Delete" do
  let!(:rick) { WalkingDead.create! :name => "Rick Grimes" }

  it "should affect default count" do
    expect {
      rick.destroy
    }.to change(WalkingDead, :count).by(-1)
  end

  it "should not affect unscoped count" do
    expect {
      rick.destroy
    }.to_not change(WalkingDead.unscoped, :count)
  end

  it "should update the deleted_at field" do
    expect {
      rick.destroy
    }.to change {rick.deleted_at}.from(nil)
  end
  
  it "should use deleted?" do
    expect {
      rick.destroy
    }.to change { rick.deleted? }.from(false).to(true)
  end

  it "should mark as destroyed and get proper query result" do
    rick.destroy
    rick.should be_destroyed

    WalkingDead.where(:name => rick.name).count.should == 0
    WalkingDead.unscoped.where(:name => rick.name).first.should eq(rick)
  end
  
  it 'is run callback after destroy' do
    rick.name = "foo"
    rick.destroy
    rick.tag.should == "after_destroy foo"
  end
end
