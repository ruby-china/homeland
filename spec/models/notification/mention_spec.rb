require 'spec_helper'

describe Notification::Mention do
  it "should be create after reply with mention" do
    lambda do
      Factory :reply, :mentioned_user_ids => [Factory(:user).id]
    end.should change(Notification::Mention, :count)
  end
end
