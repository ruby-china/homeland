# frozen_string_literal: true

require "rails_helper"

describe ApplicationHelper, type: :helper do
  describe "markdown" do
    context "bad html" do
      it "filter script" do
        assert_equal "<p> foo</p>", helper.markdown("<script>alert()</script> foo")
      end

      it "filter style" do
        assert_equal "<p> foo</p>", helper.markdown("<style>.body {}</style> foo")
      end
    end
  end

  it "formats the flash messages" do
    assert_equal "", helper.notice_message
    assert_equal true, helper.notice_message.html_safe?

    close_html = %(<button name="button" type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span></button>)

    controller.flash[:notice] = "hello"
    assert_equal %{<div class="alert alert-success">#{close_html}hello</div>}, helper.notice_message
    controller.flash[:notice] = nil

    controller.flash[:warning] = "hello"
    assert_equal %{<div class="alert alert-warning">#{close_html}hello</div>}, helper.notice_message
    controller.flash[:warning] = nil

    controller.flash[:alert] = "hello"
    assert_equal %{<div class="alert alert-danger">#{close_html}hello</div>}, helper.notice_message
  end

  describe "admin?" do
    let(:user) { create :user }
    let(:admin) { create :admin }

    it "knows you are not an admin" do
      assert_equal false, helper.admin?(user)
    end

    it "knows who is the boss" do
      assert_equal true, helper.admin?(admin)
    end

    it "use current_user if user not given" do
      allow(helper).to receive(:current_user).and_return(admin)
      assert_equal true, helper.admin?(nil)
    end

    it "use current_user if user not given a user" do
      allow(helper).to receive(:current_user).and_return(user)
      assert_equal false, helper.admin?(nil)
    end

    it "know you are not an admin if current_user not present and user param is not given" do
      allow(helper).to receive(:current_user).and_return(nil)
      assert_equal false, helper.admin?(nil)
    end
  end

  describe "wiki_editor?" do
    let(:non_editor) { create :non_wiki_editor }
    let(:editor) { create :wiki_editor }

    it "knows non editor is not wiki editor" do
      assert_equal false, helper.wiki_editor?(non_editor)
    end

    it "knows wiki editor is wiki editor" do
      assert_equal true, helper.wiki_editor?(editor)
    end

    it "use current_user if user not given" do
      allow(helper).to receive(:current_user).and_return(editor)
      assert_equal true, helper.wiki_editor?(nil)
    end

    it "know you are not an wiki editor if current_user not present and user param is not given" do
      allow(helper).to receive(:current_user).and_return(nil)
      assert_equal false, helper.wiki_editor?(nil)
    end
  end

  describe "owner?" do
    require "ostruct"
    let(:user) { create :user }
    let(:user2) { create :user }
    let(:item) { OpenStruct.new user_id: user.id }

    it "knows who is owner" do
      assert_equal false, helper.owner?(nil)

      allow(helper).to receive(:current_user).and_return(nil)
      assert_equal false, helper.owner?(item)

      allow(helper).to receive(:current_user).and_return(user)
      assert_equal true, helper.owner?(item)

      allow(helper).to receive(:current_user).and_return(user2)
      assert_equal false, helper.owner?(item)
    end
  end

  describe "timeago" do
    it "should work" do
      t = Time.now
      text = l t.to_date, format: :long
      assert_equal "<abbr class=\"foo timeago\" title=\"#{t.iso8601}\">#{text}</abbr>", helper.timeago(t, class: "foo")
    end
  end

  describe "insert_code_menu_items_tag" do
    it "should work" do
      assert_includes helper.insert_code_menu_items_tag, 'data-lang="ruby"'
    end
  end

  describe "render_list" do
    it "should work" do
      html = helper.render_list class: "nav navbar" do |li|
        li << helper.link_to("foo", "/foo", class: "nav-link")
        li << helper.link_to("bar", "/bar", class: "nav-link hide-ios")
      end
      assert_equal %(<ul class="nav navbar"><li class="nav-item"><a class="nav-link" href="/foo">foo</a></li><li class="nav-item"><a class="nav-link hide-ios" href="/bar">bar</a></li></ul>), html
    end

    describe "render_list_items" do
      it "should work" do
        html = helper.render_list_items do |li|
          li << helper.link_to("bar", "/bar")
          li << helper.link_to("foo", "/foo")
        end
        assert_equal %(<li class="nav-item"><a href="/bar">bar</a></li><li class="nav-item"><a href="/foo">foo</a></li>), html
      end
    end
  end
end
