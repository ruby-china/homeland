class AddIndexToUserGitHub < ActiveRecord::Migration[6.0]
  def change
    # 开源项目排行榜，会根据 github 用户名反查是否是 TesterHome 用户
    add_index :users, :github
  end
end
