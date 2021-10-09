# frozen_string_literal: true

require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  def current_page?(url)
    false
  end

  test "markdown" do
    assert_equal "<p>foo <strong>bar</strong>alert()</p>", markdown("foo **bar**<script>alert()</script>")
    assert_equal "<p>Hello world alert()</p>", markdown("Hello world <script>alert()</script>")
  end

  test "sanitize_markdown" do
    assert_equal "<p>Hello world alert()</p>", sanitize_markdown("<p>Hello world <script>alert()</script></p>")
  end

  test "sanitize_markdown sup and sub" do
    assert_equal "<p>L<sup>A</sup>T<sub>E</sub>X 结构化的路径覆盖（C<sub>i</sub>(k)-覆盖）</p>", sanitize_markdown("<p>L<sup>A</sup>T<sub>E</sub>X 结构化的路径覆盖（C<sub>i</sub>(k)-覆盖）</p>")
  end

  test "admin?" do
    user = create :user
    admin = create :admin

    # knows you are not an admin
    assert_equal false, admin?(user)

    # knows who is the boss
    assert_equal true, admin?(admin)

    # use current_user if user not given
    sign_in admin
    assert_equal true, admin?(nil)

    # use current_user if user not given a user
    sign_in user
    assert_equal false, admin?(nil)

    # know you are not an admin if current_user not present and user param is not given
    sign_out
    assert_equal false, admin?(nil)
  end

  test "wiki_editor?" do
    non_editor = create :user
    editor = create :vip

    # knows non editor is not wiki editor
    assert_equal false, wiki_editor?(non_editor)

    # knows wiki editor is wiki editor
    assert_equal true, wiki_editor?(editor)

    # use current_user if user not given
    sign_in editor
    assert_equal true, wiki_editor?(nil)

    # know you are not an wiki editor if current_user not present and user param is not given
    sign_out
    assert_equal false, wiki_editor?(nil)
  end

  test "owner?" do
    require "ostruct"

    user = create :user
    user2 = create :user
    item = OpenStruct.new(user_id: user.id)

    assert_equal false, owner?(nil)

    sign_out
    assert_equal false, owner?(item)

    sign_in user
    assert_equal true, owner?(item)

    sign_in user2
    assert_equal false, owner?(item)
  end

  test "timeago" do
    t = Time.now
    text = l t.to_date, format: :long
    assert_equal "<abbr class=\"foo timeago\" title=\"#{t.iso8601}\">#{text}</abbr>", timeago(t, class: "foo")
  end

  test "insert_code_menu_items_tag" do
    Setting.stubs(:editor_languages).returns(%w[go rb 123 js])
    html = <<~HTML
      <a class="dropdown-item" data-lang="go" href="#">Go</a>
      <a class="dropdown-item" data-lang="rb" href="#">Ruby</a>
      <a class="dropdown-item" data-lang="js" href="#">JavaScript</a>
    HTML

    assert_html_equal html, insert_code_menu_items_tag
  end

  test "render_list" do
    html = render_list class: "nav navbar" do |li|
      li << link_to("foo", "/foo", class: "nav-link")
      li << link_to("bar", "/bar", class: "nav-link hide-ios")
    end
    assert_equal %(<ul class="nav navbar"><li class="nav-item"><a class="nav-link" href="/foo">foo</a></li><li class="nav-item"><a class="nav-link hide-ios" href="/bar">bar</a></li></ul>), html
  end

  test "render_list_items" do
    html = render_list_items do |li|
      li << link_to("bar", "/bar")
      li << link_to("foo", "/foo")
    end
    assert_equal %(<li class="nav-item"><a href="/bar">bar</a></li><li class="nav-item"><a href="/foo">foo</a></li>), html
  end

  test "user_theme" do
    assert_equal "auto", user_theme

    user = create :user
    sign_in user
    assert_equal "auto", user_theme
    user.update_theme("dark")
    assert_equal "dark", user_theme
  end
end
