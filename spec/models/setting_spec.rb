# frozen_string_literal: true

require "rails_helper"

describe Setting, type: :model do
  describe "navbar_brand_html" do
    it "should work" do
      expect(Setting.navbar_brand_html).to eq %(<a href="/" class="navbar-brand"><b>#{Setting.app_name}</b></a>)
    end
  end

  describe "reject_newbie_reply_in_the_evening" do
    it "should work" do
      expect(Setting.reject_newbie_reply_in_the_evening).to eq false
      expect(Setting.reject_newbie_reply_in_the_evening?).to eq false
    end
  end

  describe "topic_create_rate_limit" do
    it "should work" do
      expect(Setting.topic_create_rate_limit).to eq false
      expect(Setting.topic_create_rate_limit?).to eq false
    end
  end

  describe "default_locale" do
    it "should work" do
      expect(Setting.default_locale).to eq "zh-CN"
    end
  end

  describe "auto_locale" do
    it "should work" do
      expect(Setting.auto_locale).to eq false
    end
  end

  describe "ban_reasons" do
    it "should work" do
      expect(Setting.ban_reasons).to eq ["标题或正文描述不清楚"]
    end
  end

  describe "ban_reason_html" do
    it "should work" do
      expect(Setting.ban_reason_html).to eq "此贴因内容原因不符合要求，被管理员屏蔽，请根据管理员给出的原因进行调整"
    end
  end

  describe "protocol" do
    it "should work" do
      expect(Setting.protocol).to eq "http"
      allow(Setting).to receive(:https).and_return(true)
      expect(Setting.protocol).to eq "https"
    end
  end

  describe "host" do
    it "should work" do
      allow(Setting).to receive(:domain).and_return("homeland.io")
      allow(Setting).to receive(:https).and_return(true)
      expect(Setting.base_url).to eq "https://homeland.io"
    end
  end

  describe "admin_emails" do
    it "should work" do
      expect(Setting.admin_emails).to eq ["admin@admin.com"]
      Setting.admin_emails = "admin@admin.com a0@foo.com\r\na1@foo.com\na2@foo.com\ra3@foo.com,a4@foo.com"
      expect(Setting.has_admin?("huacnlee@gmail.com")).to eq false
      expect(Setting.has_admin?("admin@admin.com")).to eq true
      expect(Setting.has_admin?("a0@foo.com")).to eq true
      expect(Setting.has_admin?("a1@foo.com")).to eq true
      expect(Setting.has_admin?("a2@foo.com")).to eq true
      expect(Setting.has_admin?("a3@foo.com")).to eq true
      expect(Setting.has_admin?("a4@foo.com")).to eq true
      expect(Setting.has_admin?("a5@foo.com")).to eq false
      allow(Setting).to receive(:admin_emails).and_return(["foo@bar.com\n", "foo1@bar.com "])
      expect(Setting.has_admin?("foo@bar.com")).to eq true
      expect(Setting.has_admin?("foo1@bar.com")).to eq true
    end
  end

  describe "modules" do
    it "should work" do
      allow(Setting).to receive(:modules).and_return("all")
      expect(Setting.has_module?("foo")).to eq true
      expect(Setting.has_module?("home")).to eq true
      expect(Setting.has_module?("topic")).to eq true
      allow(Setting).to receive(:modules).and_return(["home", "topic\n", "note", "site", "team "])
      expect(Setting.has_module?("home")).to eq true
      expect(Setting.has_module?("topic")).to eq true
      expect(Setting.has_module?("note")).to eq true
      expect(Setting.has_module?("site")).to eq true
      expect(Setting.has_module?("team")).to eq true
      expect(Setting.has_module?("bbb")).to eq false
    end
  end

  describe "profile_fields" do
    it "should work" do
      allow(Setting).to receive(:profile_fields).and_return("all")
      expect(Setting.has_profile_field?("foo")).to eq true
      expect(Setting.has_profile_field?("weibo")).to eq true
      expect(Setting.has_profile_field?("douban")).to eq true
      allow(Setting).to receive(:profile_fields).and_return(["weibo", "facebook\n", "douban ", "qq"])
      expect(Setting.has_profile_field?("weibo")).to eq true
      expect(Setting.has_profile_field?("facebook")).to eq true
      expect(Setting.has_profile_field?("douban")).to eq true
      expect(Setting.has_profile_field?("qq")).to eq true
      expect(Setting.has_profile_field?("ccc")).to eq false
    end
  end

  describe "sso_provider_enabled" do
    it "should work" do
      expect(Setting.sso_provider_enabled?).to eq false
    end
  end

  describe "sso_enabled" do
    it "should work" do
      expect(Setting.sso_enabled?).to eq false
    end
  end

  describe "allow_change_login" do
    it "should work" do
      expect(Setting.allow_change_login?).to eq false
      Setting.allow_change_login = "true"
      expect(Setting.allow_change_login?).to eq true
    end
  end

  describe "twitter_id" do
    it "should work" do
      Setting.twitter_id = "ruby_china"
      expect(Setting.twitter_id).to eq "ruby_china"
    end
  end

  describe "node_ids_hide_in_topics_index" do
    it "should work" do
      Setting.node_ids_hide_in_topics_index = <<~LINES
      100
      101,102,103
      LINES
      expect(Setting.node_ids_hide_in_topics_index).to eq %w[100 101 102 103]
    end
  end

  describe "blacklist_ips" do
    it "should work" do
      Setting.blacklist_ips = <<~LINES
      10.10.10.10
      11.11.11.11,12.12.12.12
      LINES
      expect(Setting.blacklist_ips).to eq ["10.10.10.10", "11.11.11.11", "12.12.12.12"]
    end
  end

  describe "ban_words_on_reply" do
    it "should work" do
      Setting.ban_words_on_reply = <<~LINES
      This is first line.
      And, this is second line.
      LINES
      expect(Setting.ban_words_on_reply).to eq ["This is first line.", "And, this is second line."]
    end
  end

  describe "tips" do
    it "should work" do
      Setting.tips = <<~LINES
      This is first line.
      And, this is second line.
      LINES
      expect(Setting.tips).to eq ["This is first line.", "And, this is second line."]
    end
  end
end
