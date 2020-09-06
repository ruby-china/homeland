class CreateGitHubStatistics < ActiveRecord::Migration[6.0]
  def change
    create_table :github_statistics do |t|
      t.string :github_user # github用户名
      t.string :testerhome_user # 对应社区用户 id 。默认值为 nil
      t.integer :ttf_contribution # TTF榜单贡献指数
      t.integer :monthly_contribution # 月度榜单贡献指数
      t.integer :discovery_contribution # 潜力榜单贡献指数
      # 此字段用于表示数据对应月份，如2019年5月的数据，此字段值应为2019-05-01
      t.date :data_of_month, null: true

      t.timestamps
    end

    add_index :github_statistics, :github_user # 根据 github 用户名反查时用到
    add_index :github_statistics, :testerhome_user # 根据社区用户名反查时用到
    add_index :github_statistics, :data_of_month # 添加索引便于通过此字段获取指定月份数据
  end
end
