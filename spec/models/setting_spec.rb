# frozen_string_literal: true

require "rails_helper"

describe Setting, type: :model do
  describe "navbar_brand_html" do
    it "should work" do
      assert_equal %(<a href="/" class="navbar-brand"><b>#{Setting.app_name}</b></a>), Setting.navbar_brand_html
    end
  end

  describe "reject_newbie_reply_in_the_evening" do
    it "should work" do
      assert_equal false, Setting.reject_newbie_reply_in_the_evening
      assert_equal false, Setting.reject_newbie_reply_in_the_evening?
    end
  end

  describe "topic_create_rate_limit" do
    it "should work" do
      assert_equal false, Setting.topic_create_rate_limit
      assert_equal false, Setting.topic_create_rate_limit?
    end
  end

  describe "default_locale" do
    it "should work" do
      assert_equal "zh-CN", Setting.default_locale
    end
  end

  describe "auto_locale" do
    it "should work" do
      assert_equal false, Setting.auto_locale
    end
  end

  describe "ban_reasons" do
    it "should work" do
      assert_equal ["标题或正文描述不清楚"], Setting.ban_reasons
    end
  end

  describe "ban_reason_html" do
    it "should work" do
      assert_equal "此贴因内容原因不符合要求，被管理员屏蔽，请根据管理员给出的原因进行调整", Setting.ban_reason_html
    end
  end

  describe "protocol" do
    it "should work" do
      assert_equal "http", Setting.protocol
      allow(Setting).to receive(:https).and_return(true)
      assert_equal "https", Setting.protocol
    end
  end

  describe "host" do
    it "should work" do
      allow(Setting).to receive(:domain).and_return("homeland.io")
      allow(Setting).to receive(:https).and_return(true)
      assert_equal "https://homeland.io", Setting.base_url
    end
  end

  describe "admin_emails" do
    it "should work" do
      assert_equal ["admin@admin.com"], Setting.admin_emails
      Setting.admin_emails = "admin@admin.com a0@foo.com\r\na1@foo.com\na2@foo.com\ra3@foo.com,a4@foo.com"
      assert_equal false, Setting.has_admin?("huacnlee@gmail.com")
      assert_equal true, Setting.has_admin?("admin@admin.com")
      assert_equal true, Setting.has_admin?("a0@foo.com")
      assert_equal true, Setting.has_admin?("a1@foo.com")
      assert_equal true, Setting.has_admin?("a2@foo.com")
      assert_equal true, Setting.has_admin?("a3@foo.com")
      assert_equal true, Setting.has_admin?("a4@foo.com")
      assert_equal false, Setting.has_admin?("a5@foo.com")
      allow(Setting).to receive(:admin_emails).and_return(["foo@bar.com\n", "foo1@bar.com "])
      assert_equal true, Setting.has_admin?("foo@bar.com")
      assert_equal true, Setting.has_admin?("foo1@bar.com")
    end
  end

  describe "modules" do
    it "should work" do
      allow(Setting).to receive(:modules).and_return("all")
      assert_equal true, Setting.has_module?("foo")
      assert_equal true, Setting.has_module?("home")
      assert_equal true, Setting.has_module?("topic")
      allow(Setting).to receive(:modules).and_return(["home", "topic\n", "note", "site", "team "])
      assert_equal true, Setting.has_module?("home")
      assert_equal true, Setting.has_module?("topic")
      assert_equal true, Setting.has_module?("note")
      assert_equal true, Setting.has_module?("site")
      assert_equal true, Setting.has_module?("team")
      assert_equal false, Setting.has_module?("bbb")
    end
  end

  describe "profile_fields" do
    it "should work" do
      allow(Setting).to receive(:profile_fields).and_return("all")
      assert_equal true, Setting.has_profile_field?("foo")
      assert_equal true, Setting.has_profile_field?("weibo")
      assert_equal true, Setting.has_profile_field?("douban")
      allow(Setting).to receive(:profile_fields).and_return(["weibo", "facebook\n", "douban ", "qq"])
      assert_equal true, Setting.has_profile_field?("weibo")
      assert_equal true, Setting.has_profile_field?("facebook")
      assert_equal true, Setting.has_profile_field?("douban")
      assert_equal true, Setting.has_profile_field?("qq")
      assert_equal false, Setting.has_profile_field?("ccc")
    end
  end

  describe "sso_provider_enabled" do
    it "should work" do
      assert_equal false, Setting.sso_provider_enabled?
    end
  end

  describe "sso_enabled" do
    it "should work" do
      assert_equal false, Setting.sso_enabled?
    end
  end

  describe "allow_change_login" do
    it "should work" do
      assert_equal false, Setting.allow_change_login?
      Setting.allow_change_login = "true"
      assert_equal true, Setting.allow_change_login?
    end
  end

  describe "twitter_id" do
    it "should work" do
      Setting.twitter_id = "ruby_china"
      assert_equal "ruby_china", Setting.twitter_id
    end
  end

  describe "node_ids_hide_in_topics_index" do
    it "should work" do
      Setting.node_ids_hide_in_topics_index = <<~LINES
      100
      101,102,103
      LINES
      assert_equal %w[100 101 102 103], Setting.node_ids_hide_in_topics_index
    end
  end

  describe "blacklist_ips" do
    it "should work" do
      Setting.blacklist_ips = <<~LINES
      10.10.10.10
      11.11.11.11,12.12.12.12
      LINES
      assert_equal ["10.10.10.10", "11.11.11.11", "12.12.12.12"], Setting.blacklist_ips
    end
  end

  describe "ban_words_on_reply" do
    it "should work" do
      Setting.ban_words_on_reply = <<~LINES
      This is first line.
      And, this is second line.
      LINES
      assert_equal ["This is first line.", "And, this is second line."], Setting.ban_words_on_reply
    end
  end

  describe "tips" do
    it "should work" do
      Setting.tips = <<~LINES
      This is first line.
      And, this is second line.
      LINES
      assert_equal ["This is first line.", "And, this is second line."], Setting.tips
    end
  end

  describe "share_allow_sites" do
    it "should work" do
      Setting.share_allow_sites, = <<~LINES
      weibo
      facebook
      twitter
      LINES
      assert_equal ["weibo", "facebook", "twitter"], Setting.share_allow_sites
    end
  end
end
