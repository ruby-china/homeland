# frozen_string_literal: true

require "test_helper"

class ProfileCardComponentTest < ViewComponent::TestCase
  def test_component_renders_something_useful
    user = create(:user)
    component = ProfileCardComponent.new(user: user)
    component.stub(:owner?, true) do
      doc = render_inline(component)
      assert_equal user.name, doc.css(".user-profile-card .fullname").text.strip
      assert_equal "@#{user.login}", doc.css(".user-profile-card .login").text.strip
    end

    assert_equal "", render_inline(ProfileCardComponent.new(user: nil)).to_html
  end
end
