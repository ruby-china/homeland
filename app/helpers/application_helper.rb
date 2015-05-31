# coding: utf-8
require "redcarpet"



module ApplicationHelper
  ALLOW_TAGS = %w(p br img h1 h2 h3 h4 h5 h6 blockquote pre code b i strong em table tr td tbody th strike del u a ul ol li span hr)
  ALLOW_ATTRIBUTES = %w(href src class id title alt target rel data-floor)
  EMPTY_STRING = ''.freeze
  
  def sanitize_markdown(body)
    # TODO: This method slow, 3.5ms per call in topic body
    sanitize body, tags: ALLOW_TAGS, attributes: ALLOW_ATTRIBUTES
  end

  def notice_message
    flash_messages = []

    flash.each do |type, message|
      type = :success if type.to_sym == :notice
      type = :danger if type.to_sym == :alert
      text = content_tag(:div, link_to("x", "#", :class => "close", 'data-dismiss' => "alert") + message, :class => "alert alert-#{type}")
      flash_messages << text if message
    end

    flash_messages.join("\n").html_safe
  end
  
  def render_page_title
    title = @page_title ? "#{SITE_NAME} | #{@page_title}" : SITE_NAME rescue "SITE_NAME"
    content_tag("title", title, nil, false)
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
    if item.is_a?(User)
      item.id == current_user.id
    else
      item.user_id == current_user.id
    end
  end

  def timeago(time, options = {})
    options[:class] = options[:class].blank? ? "timeago" : [options[:class],"timeago"].join(" ")
    options.merge!(title: time.iso8601)
    content_tag(:abbr, EMPTY_STRING, class: options[:class], title: time.iso8601) if time
  end

  def render_page_title
    site_name = Setting.app_name
    title = @page_title ? "#{@page_title} &raquo; #{site_name}" : site_name rescue "SITE_NAME"
    content_tag("title", title, nil, false)
  end

  # 去除区域里面的内容的换行标记
  def spaceless(&block)
    data = with_output_buffer(&block)
    data = data.gsub(/\n\s+/, EMPTY_STRING)
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
        link_to raw(k), '#', data: { lang: l }
      end
    end
    raw lang_list.join(EMPTY_STRING)
  end

  def birthday_tag
    t = Time.now
    if t.month == 10 && t.day == 28
      age = t.year - 2011
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

  def random_tips
    tips = SiteConfig.tips
    return EMPTY_STRING if tips.blank?
    tips.split("\n").sample
  end

  def icon_tag(name, opts = {})
    label = EMPTY_STRING
    if opts[:label]
      label = %(<span>#{opts[:label]}</span>)
    end
    raw "<i class='fa fa-#{name}'></i> #{label}"
  end
  
  def memory_cache(*keys)
    return yield if !Rails.application.config.cache_classes
    
    $memory_store.fetch(keys) { yield }
  end

  def stylesheet_link_tag_with_cached(name)
    memory_cache("stylesheets_link_tag",name) do
      stylesheet_link_tag(name, 'data-turbolinks-track' => true)
    end
  end
  
  def javascript_include_tag_with_cached(name)
    memory_cache("javascript_include_tag", name) do
      javascript_include_tag(name, 'data-turbolinks-track' => true)
    end
  end
  
  def cached_asset_path(name)
    memory_cache("asset_path", name) do
      asset_path(name)
    end
  end
  
  def render_list(opts = {})
    list = []
    yield(list)
    items = []
    list.each do |link|
      item_class = EMPTY_STRING
      url = link.match(/href=(["'])(.*?)(\1)/)[2] rescue nil
      if url && current_page?(url) || ( @current && @current.include?(url) )
        item_class = "active"
      end
      items << content_tag("li", raw(link), class: item_class)
    end
    content_tag("ul", raw(items.join(EMPTY_STRING)), opts)
  end
end
