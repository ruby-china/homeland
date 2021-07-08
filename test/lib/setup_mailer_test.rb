# frozen_string_literal: true

require "test_helper"

class Homeland::SetupMailerTest < ActiveSupport::TestCase
  test "delivery_method" do
    Rails.stub(:env, "production") do
      assert_equal Setting.mailer_provider.to_sym, ActionMailer::Base.delivery_method
      Setting.stub(:mailer_provider, :foo) do
        assert_equal :foo, ActionMailer::Base.delivery_method
      end
      Setting.stub(:mailer_provider, "postmark") do
        assert_equal :postmark, ActionMailer::Base.delivery_method
      end
    end

    Rails.stub(:env, "development") do
      Setting.stub(:mailer_provider, :foo) do
        assert_equal :foo, ActionMailer::Base.delivery_method
      end
    end

    Rails.stub(:env, "test") do
      assert_equal :test, ActionMailer::Base.delivery_method
    end
  end

  test "Devise.mailer_sender" do
    assert_equal true, Devise.mailer_sender.is_a?(Proc)
    assert_equal Setting.mailer_sender, Devise.mailer_sender.call(:user)
    Setting.stub(:mailer_sender, "foo@bar.com") do
      assert_equal "foo@bar.com", Devise.mailer_sender.call(:user)
    end
  end

  test "default_options" do
    assert_equal({from: Setting.mailer_sender, charset: "utf-8", content_type: "text/html"}, ActionMailer::Base.default_options)
    Setting.stub(:mailer_sender, "foo@bar.com") do
      assert_equal({from: "foo@bar.com", charset: "utf-8", content_type: "text/html"}, ActionMailer::Base.default_options)
    end
  end

  test "default_url_options" do
    assert_equal({host: Setting.domain, protocol: Setting.protocol}, ActionMailer::Base.default_url_options)
    Setting.stub(:domain, "foo.com") do
      Setting.stub(:protocol, "http") do
        assert_equal({host: "foo.com", protocol: "http"}, ActionMailer::Base.default_url_options)
      end
    end
  end

  test "postmark_settings" do
    assert_equal %i[api_key], ActionMailer::Base.postmark_settings.keys
    Setting.stub(:mailer_options, {api_key: "12345aaa", foo: 123, bar: "foo"}) do
      assert_equal({api_key: "12345aaa"}, ActionMailer::Base.postmark_settings)
    end
  end

  test "smtp_settings" do
    assert_equal %i[address port domain user_name password authentication enable_starttls_auto], ActionMailer::Base.smtp_settings.keys
    Setting.stub(:mailer_options, {address: "foobar.com", password: "aaa", foo: 123}) do
      assert_equal({address: "foobar.com", password: "aaa"}, ActionMailer::Base.smtp_settings)
    end
  end
end
