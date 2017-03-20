module ApplicationHelper
  EMPTY_STRING = ''.freeze

  def markdown(text)
    return nil if text.blank?
    Rails.cache.fetch(['markdown', Digest::MD5.hexdigest(text)]) do
      sanitize_markdown(Homeland::Markdown.call(text))
    end
  end

  def sanitize_markdown(html)
    raw Sanitize.fragment(html, Homeland::Sanitize::DEFAULT)
  end

  def notice_message
    flash_messages = []

    flash.each do |type, message|
      type = :success if type.to_sym == :notice
      type = :danger  if type.to_sym == :alert
      text = content_tag(:div, link_to(raw('<i class="fa fa-close"></i>'), '#', :class => 'close', 'data-dismiss' => 'alert') + message, class: "alert alert-#{type}")
      flash_messages << text if message
    end

    flash_messages.join("\n").html_safe
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
    return '' if time.blank?
    options[:class] = options[:class].blank? ? 'timeago' : [options[:class], 'timeago'].join(' ')
    options[:title] = time.iso8601
    text = l time.to_date, format: :long
    content_tag(:abbr, text, options)
  end

  def title_tag(str)
    content_for :title, raw("#{str} · #{Setting.app_name}")
  end

  MOBILE_USER_AGENTS = 'palm|blackberry|nokia|phone|midp|mobi|symbian|chtml|ericsson|minimo|' \
                       'audiovox|motorola|samsung|telit|upg1|windows ce|ucweb|astel|plucker|' \
                       'x320|x240|j2me|sgh|portable|sprint|docomo|kddi|softbank|android|mmp|' \
                       'pdxgw|netfront|xiino|vodafone|portalmmm|sagem|mot-|sie-|ipod|up\\.b|' \
                       'webos|amoi|novarra|cdm|alcatel|pocket|iphone|mobileexplorer|mobile'
  def mobile?
    agent_str = request.user_agent.to_s.downcase
    return true if turbolinks_app?
    return false if agent_str.match?(/ipad/)
    agent_str =~ Regexp.new(MOBILE_USER_AGENTS)
  end

  # 可按需修改
  LANGUAGES_LISTS = {
    'Ruby'                         => 'ruby',
    'HTML / ERB'                   => 'erb',
    'CSS / SCSS'                   => 'scss',
    'JavaScript'                   => 'js',
    'YAML</i>'                     => 'yml',
    'CoffeeScript'                 => 'coffee',
    'Nginx / Redis <i>(.conf)</i>' => 'conf',
    'Python'                       => 'python',
    'PHP'                          => 'php',
    'Java'                         => 'java',
    'Erlang'                       => 'erlang',
    'Shell / Bash'                 => 'shell'
  }

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
    return '' if Setting.app_name != 'Ruby China'
    t = Time.now
    return '' unless t.month == 10 && t.day == 28
    age = t.year - 2011
    title = markdown(":tada: :birthday: :cake:  Ruby China 创立 #{age} 周年纪念日 :cake: :birthday: :tada:")
    raw %(<div class="markdown" style="text-align:center; margin-bottom:15px; line-height:100%;">#{title}</div>)
  end

  def random_tips
    tips = Setting.tips
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

  # Override cache helper for support multiple I18n locale
  def cache(name = {}, options = {}, &block)
    options ||= {}
    super([I18n.locale, name], options, &block)
  end

  def render_list(opts = {})
    list = []
    yield(list)
    list_items = render_list_items(list)
    content_tag('ul', list_items, opts)
  end

  def render_list_items(list = [])
    yield(list) if block_given?
    items = []
    list.each do |link|
      item_class = EMPTY_STRING
      urls = link.match(/href=(["'])(.*?)(\1)/) || []
      url = urls.length > 2 ? urls[2] : nil
      if url && current_page?(url) || (@current && @current.include?(url))
        item_class = 'active'
      end
      items << content_tag('li', raw(link), class: item_class)
    end

    raw items.join(EMPTY_STRING)
  end

  def highlight(text)
    text = escape_once(text)
    text.gsub!('[h]', '<em>')
    text.gsub!('[/h]', '</em>')
    text.gsub!(/\\n|\\r/, '')
    raw text
  end
end
