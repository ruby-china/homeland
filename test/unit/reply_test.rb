require 'test_helper'

class ReplyTest < ActiveSupport::TestCase
  test "should extract mentioned user ids" do
    user = Factory :user
    reply = Factory :reply, :body => "@#{user.login}"
    assert_equal [user.id], reply.mentioned_user_ids
    assert_equal [user], reply.mentioned_users

    # 5 mentioned limit
    logins = ""
    6.times do
      logins << " @#{Factory(:user).login}"
    end
    reply = Factory :reply, :body => logins
    assert_equal 5, reply.mentioned_users.count

    # except self
    reply = Factory :reply, :body => "@#{user.login}", :user => user
    assert_equal [], reply.mentioned_users
  end
end
