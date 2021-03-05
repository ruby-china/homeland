# frozen_string_literal: true

# @class NodeSerializer
# 节点
#
# == attributes
# - *id* [Integer] 编号
# - *name* [String] 节点名称
# - *summary* [String] 简介, Markdown 格式
# - *section_id* [Integer] 大类别编号
# - *section_name* [String] 大类别名称
# - *topics_count* [Integer] 话题数量
# - *sort* {Integer} 排序优先级
# - *updated_at* [DateTime] 更新时间
if node
  json.cache! ["v2", node] do
    json.call(node, :id, :name, :topics_count, :summary, :sort, :updated_at)
    json.section_id 1
    json.section_name "Nodes"
  end
end
