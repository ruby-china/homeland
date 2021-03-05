# frozen_string_literal: true

require "test_helper"

class CommentTest < ActiveSupport::TestCase
  setup do
    @monkey = Monkey.create(name: "Foo")
    @user = create(:user)
  end

  test "base" do
    comment = Comment.new
    assert_equal true, comment.respond_to?(:mentioned_user_ids)
    assert_equal true, comment.respond_to?(:extract_mentioned_users)
  end

  test "create" do
    comment = build(:comment, commentable: @monkey)
    comment.save!
    @monkey.reload
    assert_equal 1, @monkey.comments_count
  end

  test "mention" do
    body = "@#{@user.login} 还好"
    comment = build(:comment, commentable: @monkey, body: body)
    comment.save!
    note = @user.notifications.last
    assert_equal "mention", note.notify_type
    assert_equal "Comment", note.target_type
    assert_equal comment.id, note.target_id
    assert_equal "Monkey", note.second_target_type
    assert_equal @monkey.id, note.second_target_id
  end

  test "Base notify for commentable should notify commentable creator" do
    monkey_user = create("user")
    monkey = Monkey.create(name: "Bar", user_id: monkey_user.id)
    comment = build(:comment, commentable: monkey, body: "Hello")
    comment.save!
    note = monkey_user.notifications.last

    assert_equal "comment", note.notify_type
    assert_equal "Comment", note.target_type
    assert_equal comment.id, note.target_id
    assert_equal "Monkey", note.second_target_type
    assert_equal monkey.id, note.second_target_id

    # should only once notify when have mention
    comment = build(:comment, commentable: @monkey, body: "Hello @#{monkey_user.login}")
    comment.save!

    note = monkey_user.notifications.last
    assert_equal "mention", note.notify_type
    assert_equal "Comment", note.target_type
    assert_equal comment.id, note.target_id
    assert_equal "Monkey", note.second_target_type
    assert_equal @monkey.id, note.second_target_id
  end
end
