require 'spec_helper'

USING_PARANOIA = false

class WalkingDead
  include Mongoid::Document
  include Mongoid::BaseModel

  if USING_PARANOIA
    include Mongoid::Paranoia
  else
    include Mongoid::SoftDelete
  end

  field :name
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

  it "should mark as destroyed and get proper query result" do
    rick.destroy
    rick.should be_destroyed

    WalkingDead.exists?(:conditions => { :name => rick.name }).should be_false
    WalkingDead.unscoped.where(:name => rick.name).first.should eq(rick)
  end
end
