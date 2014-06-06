# coding: utf-8
require "redcarpet"
module ApplicationHelper
  def sanitize_topic(body)
    sanitize body, :tags => %w(p br img h1 h2 h3 h4 blockquote pre code b i strong em strike del u a ul ol li span), :attributes => %w(href src class title alt target rel)
  end

  def sanitize_reply(body)
    sanitize body, :tags => %w(p br img h1 h2 h3 h4 blockquote pre code b i strong em strike del u a ul ol li span), :attributes => %w(href src class title alt target rel data-floor)
  end

  def notice_message
    flash_messages = []

    flash.each do |type, message|
      type = :success if type.to_sym == :notice
      text = content_tag(:div, link_to("x", "#", :class => "close", 'data-dismiss' => "alert") + message, :class => "alert alert-#{type}")
      flash_messages << text if message
    end

    flash_messages.join("\n").html_safe
  end

  def controller_stylesheet_link_tag
    fname = ""
    case controller_name
    when "users", "home", "topics", "pages", "notes"
      fname = "#{controller_name}.css"
    when "replies"
      fname = "topics.css"
    end
    return "" if fname.blank?
    raw %(<link href="#{asset_path(fname)}" rel="stylesheet" data-turbolinks-track />)
  end

  def controller_javascript_include_tag
    fname = ""
    case controller_name
    when "pages","topics","notes"
      fname = "#{controller_name}.js"
    when "replies"
      fname = "topics.js"
    end
    return "" if fname.blank?
    raw %(<script src="#{asset_path(fname)}" data-turbolinks-track></script>)
  end

  def markdown(str, options = {})
    # XXX: the renderer instance should be a class variable

    options[:hard_wrap] ||= false
    options[:class] ||= ''
    assembler = Redcarpet::Render::HTML.new(:hard_wrap => options[:hard_wrap]) # auto <br> in <p>

    renderer = Redcarpet::Markdown.new(assembler, {
      :autolink => true,
      :fenced_code_blocks => true
    })
    content_tag(:div, sanitize(MarkdownConverter.convert(str)), :class => options[:class])
  end

  def admin?(user = nil)
    user ||= current_user
    user.try(:admin?)
  end

  def wiki_editor?(user = nil)
    user ||= current_user
    user.try(:wiki_editor?)
  end

  def owner?(item)
    return false if item.blank? || current_user.blank?
    item.user_id == current_user.id
  end

  def timeago(time, options = {})
    options[:class]
    options[:class] = options[:class].blank? ? "timeago" : [options[:class],"timeago"].join(" ")
    content_tag(:abbr, "", options.merge(:title => time.iso8601)) if time
  end

  def render_page_title
    site_name = Setting.app_name
    title = @page_title ? "#{site_name} | #{@page_title}" : site_name rescue "SITE_NAME"
    content_tag("title", title, nil, false)
  end

  # 去除区域里面的内容的换行标记
  def spaceless(&block)
    data = with_output_buffer(&block)
    data = data.gsub(/\n\s+/,"")
    data = data.gsub(/>\s+</,"><")
    sanitize data
  end

  MOBILE_USER_AGENTS =  'palm|blackberry|nokia|phone|midp|mobi|symbian|chtml|ericsson|minimo|' +
                        'audiovox|motorola|samsung|telit|upg1|windows ce|ucweb|astel|plucker|' +
                        'x320|x240|j2me|sgh|portable|sprint|docomo|kddi|softbank|android|mmp|' +
                        'pdxgw|netfront|xiino|vodafone|portalmmm|sagem|mot-|sie-|ipod|up\\.b|' +
                        'webos|amoi|novarra|cdm|alcatel|pocket|iphone|mobileexplorer|mobile'
  def mobile?
    agent_str = request.user_agent.to_s.downcase
    return false if agent_str =~ /ipad/
    agent_str =~ Regexp.new(MOBILE_USER_AGENTS)
  end

  # 可按需修改
  LANGUAGES_LISTS = { "Ruby" => "ruby", "HTML / ERB" => "erb", "CSS / SCSS" => "scss", "JavaScript" => "js",
                      "YAML <i>(.yml)</i>" => "yml", "CoffeeScript" => "coffee", "Nginx / Redis <i>(.conf)</i>" => "conf",
                      "Python" => "python", "PHP" => "php", "Java" => "java", "Erlang" => "erlang", "Shell / Bash" => "shell" }

  def insert_code_menu_items_tag
    lang_list = []
    LANGUAGES_LISTS.each do |k, l|
      lang_list << content_tag(:li) do
        content_tag(:a, raw(k), id: l, class: 'insert_code', data: { content: l })
      end
    end
    raw lang_list.join("")
  end

  def birthday_tag
    if Time.now.month == 10 && Time.now.day == 28
      age = Time.now.year - 2011 + 1
      title = "Ruby China 创立 #{age} 周年纪念日"
      html = []
      html << "<div style='text-align:center;margin-bottom:20px; line-height:200%;'>"
      %W(dancers beers cake birthday crown gift crown birthday cake beers dancers).each do |name|
        html << image_tag(asset_path("assets/emojis/#{name}.png"), class: "emoji", title: title)
      end
      html << "<br />"
      html << title
      html << "</div>"
      raw html.join(" ")
    end
  end
  
  # Issue #299
  # 导航高亮是用的bootstrap-helperrender_list这个方法，
  # 而这个方法是根据匹配当前controller和action来自动高亮的。
  # 招聘的节点ID是写死的，需要做特殊处理
  def hacked_render_list(list=[], options={}, &block)
    rendered_list = render_list(list, options, &block)
    if @topic && @topic.jobs? || @node && @node.jobs?
      rendered_html = Nokogiri::HTML(rendered_list)
      active_li = rendered_html.css("li.active")[0]
      active_li.try(:[]=, 'class', '')
      jobs_a = rendered_html.css("a[href='#{jobs_path}']")[0]
      jobs_a.try(:parent).try(:[]=, 'class', 'active')
      rendered_list = rendered_html.to_s.html_safe
    end
    rendered_list
  end
end
