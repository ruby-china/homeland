namespace :markdown_body do
  task refresh: [:environment] do
    [Comment, Reply, Topic].each do |klass|
      klass.find_in_batches do |group|
        group.each do |record|
          if record.body.present?
            html = MarkdownTopicConverter.format(record.body)
            if html != record.body_html
              record.body_html = html
              record.save
            end
          end
        end
      end
    end
  end
end
