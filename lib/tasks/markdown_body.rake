namespace :markdown_body do
  task refresh: [:environment] do
    include ActionView::Helpers::SanitizeHelper
    include ApplicationHelper
    
    [Comment, Reply, Topic].each do |klass|
      klass.find_in_batches do |group|
        group.each do |record|
          if record.body.present?
            html = sanitize_markdown(MarkdownTopicConverter.format(record.body))
            if html != record.body_html
              record.update_attribute(:body_html, html)
              puts "#{klass.name} #{record.id}"
            end
          end
        end
      end
    end
  end
end
