require 'rails_helper'

describe Setting, type: :model do
  describe '#protocol' do
    it 'should work' do
      expect(Setting.protocol).to eq "http"
      allow(Setting).to receive(:https).and_return(true)
      expect(Setting.protocol).to eq "https"
    end
  end

  describe '#host' do
    it 'should work' do
      allow(Setting).to receive(:domain).and_return("homeland.io")
      allow(Setting).to receive(:https).and_return(true)
      expect(Setting.host).to eq "https://homeland.io"
    end
  end

  describe '#has_admin?' do
    it 'should work' do
      allow(Setting).to receive(:admin_emails).and_return("a0@foo.com\na1@foo.com\r\na2@foo.com a3@foo.com,a4@foo.com")
      expect(Setting.has_admin?('huacnlee@gmail.com')).to eq false
      expect(Setting.has_admin?('a0@foo.com')).to eq true
      expect(Setting.has_admin?('a1@foo.com')).to eq true
      expect(Setting.has_admin?('a2@foo.com')).to eq true
      expect(Setting.has_admin?('a3@foo.com')).to eq true
      expect(Setting.has_admin?('a4@foo.com')).to eq true
      expect(Setting.has_admin?('a5@foo.com')).to eq false
    end
  end

  describe '#has_module?' do
    it 'should work' do
      allow(Setting).to receive(:modules).and_return("all")
      expect(Setting.has_module?("foo")).to eq true
      allow(Setting).to receive(:modules).and_return("home,topic\nnote\r\nsite team")
      expect(Setting.has_module?('home')).to eq true
      expect(Setting.has_module?('topic')).to eq true
      expect(Setting.has_module?('note')).to eq true
      expect(Setting.has_module?('site')).to eq true
      expect(Setting.has_module?('team')).to eq true
      expect(Setting.has_module?('bbb')).to eq false
    end
  end

  describe '#has_profile_field?' do
    it 'should work' do
      allow(Setting).to receive(:profile_fields).and_return("all")
      expect(Setting.has_profile_field?("foo")).to eq true
      allow(Setting).to receive(:profile_fields).and_return("weibo,facebook\ndouban\nqq")
      expect(Setting.has_profile_field?('weibo')).to eq true
      expect(Setting.has_profile_field?('facebook')).to eq true
      expect(Setting.has_profile_field?('douban')).to eq true
      expect(Setting.has_profile_field?('qq')).to eq true
      expect(Setting.has_profile_field?('ccc')).to eq false
    end
  end
end