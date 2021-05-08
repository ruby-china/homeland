# frozen_string_literal: true

require "test_helper"

class AlertComponentTest < ViewComponent::TestCase
  def test_component
    component = AlertComponent.new
    doc = render_inline(component)
    assert_nil doc.css(".alert").first

    controller.flash[:notice] = "hello"
    doc = render_inline(component)
    assert_equal "hello", doc.css(".alert.alert-success .alert-message").text.strip

    controller.flash[:alert] = "hello"
    doc = render_inline(component)
    assert_equal "hello", doc.css(".alert.alert-danger .alert-message").text.strip
  end
end
