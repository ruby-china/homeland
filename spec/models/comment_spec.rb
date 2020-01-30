# frozen_string_literal: true

require "rails_helper"

describe Comment, type: :model do
  let(:monkey) { Monkey.create(name: "Foo") }
  let(:user) { create(:user) }

  describe "base" do
    it "should work" do
      comment = Comment.new
      assert_equal true, comment.respond_to?(:mentioned_user_ids)
      assert_equal true, comment.respond_to?(:extract_mentioned_users)
    end
  end

  describe "create" do
    it "should work" do
      comment = build(:comment, commentable: monkey)
      comment.save!
      monkey.reload
      assert_equal 1, monkey.comments_count
    end

    it "should mention" do
      body = "@#{user.login} 还好"
      comment = build(:comment, commentable: monkey, body: body)
      comment.save!
      note = user.notifications.last
      assert_equal "mention", note.notify_type
      assert_equal "Comment", note.target_type
      assert_equal comment.id, note.target_id
      assert_equal "Monkey", note.second_target_type
      assert_equal monkey.id, note.second_target_id
    end

    describe "Base notify for commentable" do
      let(:monkey_user) { create("user") }
      let(:monkey) { Monkey.create(name: "Bar", user_id: monkey_user.id) }

      it "should notify commentable creator" do
        comment = build(:comment, commentable: monkey, body: "Hello")
        comment.save!
        note = monkey_user.notifications.last
        assert_equal "comment", note.notify_type
        assert_equal "Comment", note.target_type
        assert_equal comment.id, note.target_id
        assert_equal "Monkey", note.second_target_type
        assert_equal monkey.id, note.second_target_id
      end

      it "should only once notify when have mention" do
        comment = build(:comment, commentable: monkey, body: "Hello @#{monkey_user.login}")
        comment.save!
        note = monkey_user.notifications.last
        assert_equal "mention", note.notify_type
        assert_equal "Comment", note.target_type
        assert_equal comment.id, note.target_id
        assert_equal "Monkey", note.second_target_type
        assert_equal monkey.id, note.second_target_id
      end
    end
  end
end
