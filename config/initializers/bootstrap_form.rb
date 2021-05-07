def add_class(old_class, class_name)
  classes = []
  classes << class_name
  if old_class.present?
    classes << old_class.strip
  end
  classes.uniq.join(" ")
end

module BoostrapLabel # :nodoc:
  def initialize(*)
    super

    @options[:class] = add_class(@options[:class], "form-label")
  end
end

module BoostrapTextField # :nodoc:
  def initialize(*)
    super

    @options[:class] = add_class(@options[:class], "form-control")
  end
end

module BoostrapSelect # :nodoc:
  def initialize(*)
    super

    @options[:class] = add_class(@options[:class], "form-select")
  end
end

ActionView::Helpers::Tags::Label.send(:include, BoostrapLabel)
ActionView::Helpers::Tags::TextField.send(:include, BoostrapTextField)
ActionView::Helpers::Tags::TextArea.send(:include, BoostrapTextField)
ActionView::Helpers::Tags::Select.send(:include, BoostrapSelect)
