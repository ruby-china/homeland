module ChatsHelper
  def script_template(name, id = nil)
    id ||= name
    id += "_template"
    id = id.camelize(:lower)
    content_tag(:script, :type => "text/template", :id => id) do
      render :partial => name
    end
  end

  def meta_tag(name, value)
    raw %(<meta name="#{name}" content="#{Rack::Utils.escape_html(value)}"/>).html_safe    
  end
end