require "test_helper"

class AlertComponentTest < ViewComponent::TestCase
  def test_component
    component = AlertComponent.new
    doc = render_inline(component)
    assert_nil doc.css(".alert").first

    vc_test_controller.flash[:notice] = "hello"
    doc = render_inline(component)
    assert_equal "hello", doc.css(".alert.alert-success .alert-message").text.strip

    vc_test_controller.flash[:alert] = "hello"
    doc = render_inline(component)
    assert_equal "hello", doc.css(".alert.alert-danger .alert-message").text.strip
  end
end
