# frozen_string_literal: true

require "digest/md5"
module ColumnsHelper
  def follow_column_tag(column, opts = {})
    return "" if current_user.blank?
    return "" if column.blank?
    return "" if owner?(column)
    followed = current_user.follow_column?(column)
    opts[:class] ||= "btn btn-primary btn-block"

    class_names = "button-follow-column #{opts[:class]}"
    icon        = '<i class="fa fa-eye"></i>'

    if followed
      link_to raw("#{icon} <span>取消关注</span>"), "#", "data-id" => column.slug, class: "#{class_names} active"
    else
      link_to raw("#{icon} <span>关注</span>"), "#", title: "", "data-id" => column.slug, class: class_names
    end
  end

  def block_column_tag(column, opts = {})
    return "" if current_user.blank?
    return "" if column.blank?
    return "" if owner?(column)

    blocked     = current_user.block_column?(column)
    class_names = "button-block-column btn btn-default btn-block"
    icon        = '<i class="fa fa-eye-slash"></i>'

    if blocked
      link_to raw("#{icon} <span>取消屏蔽</span>"), "#", title: "忽略后，社区首页列表将不会显示此用户发布的内容。", "data-id" => column.slug, class: "#{class_names} active"
    else
      link_to raw("#{icon} <span>屏蔽</span>"), "#", title: "", "data-id" => column.slug, class: class_names
    end
  end

  def article_title_tag(article, opts = {})
    return t("topics.topic_was_deleted") if article.blank?
    if opts[:reply]
      index = article.floor_of_reply(opts[:reply])
      path = main_app.article_path(article, anchor: "reply#{index}")
    else
      path = main_app.article_path(article)
    end
    link_to(article.title, path, title: article.title)
  end

  def render_column_name(name, slug)
    link_to(name, main_app.column_path(slug), title: "#{name}", class: "node column-node")
  end
end
