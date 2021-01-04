# frozen_string_literal: true

module ApplicationHelper
  def markdown(text)
    return nil if text.blank?
    Rails.cache.fetch(["markdown", "v1.1", Digest::MD5.hexdigest(text)]) do
      sanitize_markdown(Homeland::Markdown.call(text))
    end
  end

  # plugins/jobs required this method
  def sanitize_markdown(html)
    sanitize(html, scrubber: Homeland::Sanitize::TOPIC_SCRUBBER)
  end

  def notice_message
    flash_messages = []

    close_html = %(<button name="button" type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span></button>)

    flash.each do |type, message|
      type = :success if type.to_sym == :notice
      type = :danger  if type.to_sym == :alert
      text = content_tag(:div, raw(close_html) + message, class: "alert alert-#{type}")
      flash_messages << text if message
    end

    flash_messages.join("\n").html_safe
  end

  # used in Plugin
  def admin?(user = nil)
    user ||= current_user
    return false if user.blank?
    user.admin?
  end

  def wiki_editor?(user = nil)
    user ||= current_user
    return false if user.blank?
    user.wiki_editor?
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
    return "" if time.blank?
    options[:class] = options[:class].blank? ? "timeago" : [options[:class], "timeago"].join(" ")
    options[:title] = time.iso8601
    text = l time.to_date, format: :long
    content_tag(:abbr, text, options)
  end

  def title_tag(str, description: nil)
    @content_title = str
    @content_description = description
    content_for :title, h("#{str} · #{Setting.app_name}")
  end

  MOBILE_USER_AGENTS = "palm|blackberry|nokia|phone|midp|mobi|symbian|chtml|ericsson|minimo|" \
                       "audiovox|motorola|samsung|telit|upg1|windows ce|ucweb|astel|plucker|" \
                       "x320|x240|j2me|sgh|portable|sprint|docomo|kddi|softbank|android|mmp|" \
                       'pdxgw|netfront|xiino|vodafone|portalmmm|sagem|mot-|sie-|ipod|up\\.b|' \
                       "webos|amoi|novarra|cdm|alcatel|pocket|iphone|mobileexplorer|mobile"
  def mobile?
    agent_str = request.user_agent.to_s.downcase
    return true if turbolinks_app?
    return false if agent_str.match?(/ipad/)
    agent_str =~ Regexp.new(MOBILE_USER_AGENTS)
  end

  def insert_code_menu_items_tag
    dropdown_items = []
    Setting.editor_languages.each do |lang|
      lexer = Rouge::Lexer.find(lang)
      if lexer
        dropdown_items << link_to(lexer.title, "#", class: "dropdown-item", data: { lang: lang })
      end
    end
    raw dropdown_items.join("")
  end

  def random_tips
    Setting.tips.sample
  end

  def icon_tag(name, opts = {})
    label = ""
    if opts[:label]
      label = %(<span>#{opts[:label]}</span>)
    end
    icon = "<i class='icon fa fa-#{name}'></i>"
    icon = "#{icon} #{label}" if label.present?
    raw icon
  end

  def icon_bold_tag(name, opts = {})
    label = ""
    if opts[:label]
      label = %(<span>#{opts[:label]}</span>)
    end
    raw "<i class='icon fab fa-#{name}'></i> #{label}"
  end

  def render_list(opts = {})
    list = []
    yield list
    list_items = render_list_items(list)
    content_tag("ul", list_items, opts)
  end

  def render_list_items(list = [])
    yield list if block_given?
    items = []
    list.each do |link|
      urls = link.match(/href=(["'])(.*?)(\1)/) || []
      url = urls.length > 2 ? urls[2] : nil
      if url && current_page?(url) || (@current&.include?(url))
        link = link.gsub("nav-link", "nav-link active")
      end
      items << content_tag("li", raw(link), class: "nav-item")
    end
    raw items.join("")
  end

  def highlight(text, terms: [])
    text = text.gsub(/<.+?>/, "")
    text = escape_once(text)
    terms.each do |term|
      text = text.gsub(term, "<b>" + term + "</b>").gsub(/\\n|\\r/, "")
    end
    raw text
  end

  def social_share_button_tag(title)
    super(title, allow_sites: Setting.share_allow_sites)
  end


  # Render div.form-group with a block, it including validation error below input
  #
  # form_group(f, :email) do
  #   f.email_field :email, class: "form-control"
  # end
  def form_group(form, field, opts = {}, &block)
    has_errors = form.object.errors[field].present?
    opts[:class] ||= "form-group"
    opts[:class] += " has-error" if has_errors

    content_tag :div, class: opts[:class] do
      concat form.label field, class: "control-label" if opts[:label] != false
      concat capture(&block)
      concat errors_for(form, field)
    end
  end

  def errors_for(form, field)
    message = form.object.errors.full_messages_for(field)&.first
    return nil if message.blank?
    content_tag(:div, message, class: "form-error")
  end

  def user_theme
    current_user&.theme || "auto"
  end
end
