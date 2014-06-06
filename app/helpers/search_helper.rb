# coding: utf-8
module SearchHelper
  # 高亮搜索结果
  def search_result_highlight(hit, field)
    field = field.to_sym
    if highlight = hit.highlight(field)
      raw highlight.format { |word| "<span class='highlight'>#{word}</span>" }
    else
      hit.result.send(field)
    end
  end
end
