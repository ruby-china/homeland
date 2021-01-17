namespace :grade do
  desc "初始化规则"
  task init_rule: :environment do
    Grade::Rule.create(action: "register", message: "注册", score: 5, change_type: :increase)
    Grade::Rule.create(action: "followed", message: "被关注", score: 3, change_type: :increase)
    Grade::Rule.create(action: "unfollowed", message: "被取消关注", score: 3, change_type: :decrease)
    Grade::Rule.create(action: "signin", message: "签到", score: 2, change_type: :increase)
    Grade::Rule.create(action: "create_topic", message: "发帖", score: 10, change_type: :increase)
    Grade::Rule.create(action: "delete_topic", message: "删帖", score: 10, change_type: :decrease)
    Grade::Rule.create(action: "add_precision", message: "加精", score: 4, change_type: :increase)
    Grade::Rule.create(action: "remove_precision", message: "取消加精", score: 4, change_type: :decrease)
    Grade::Rule.create(action: "topic_break_rule", message: "帖子违规", score: 20, change_type: :decrease)
    Grade::Rule.create(action: "creat_comment", message: "发布评论", score: 2, change_type: :increase)
    Grade::Rule.create(action: "delete_comment", message: "删除评论", score: 2, change_type: :decrease)
    Grade::Rule.create(action: "comment_break_rule", message: "评论违规", score: 10, change_type: :decrease)
  end

  desc "初始化积分"
  task init_grade: :environment do
    User.where("created_at < ?", Date.parse("2021-1-4")).find_each do |user|
      user.change_score(:register)
    end
    Topic.where("created_at < ?", Date.parse("2021-1-4")).find_each do |topic|
      next if topic.user.blank?
      topic.user.change_score(:create_topic)
      reply_users_ids = topic.replies.pluck(:user_id).uniq
      User.where(id: reply_users_ids).find_each do |u|
        u.change_score(:creat_comment)
      end
    end
  end
end
