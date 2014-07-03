require "rails_helper"

describe SiteConfig, :type => :model do
  let!(:config) { Factory :site_config }

  describe "#update_cache" do
    it "should update cache" do
      expect(Rails.cache).to receive(:write).with("site_config:#{config.key}", config.value)
      config.update_cache
    end

    it "should update cache after config is saved" do
      expect(Rails.cache).to receive(:write).with("site_config:#{config.key}", config.value)
      config.save
    end
  end

  describe "find_by_key" do
    it "should be able to find_by_key" do
      expect(SiteConfig.find_by_key(config.key).value).to eq(config.value)
    end
  end

  describe "save_default" do
    it "should create config if not exist" do
      attributes = Factory.attributes_for :site_config
      expect(SiteConfig).to receive(:create).with(:key => attributes[:key], :value => attributes[:value])
      SiteConfig.save_default(attributes[:key], attributes[:value])
    end

    it "should not change value if key presents" do
      expect(SiteConfig).not_to receive(:create)
      SiteConfig.save_default(config.key, "new value")
      expect(SiteConfig.find_by_key(config.key).value).not_to eq("new value")
      expect(SiteConfig.find_by_key(config.key).value).to eq(config.value)
    end
  end

  describe "method_missing" do
    describe "setter" do
      it "should create new config if key not present" do
        expect(SiteConfig).to receive(:create).with(:key => "not_exists_yet", :value => "some value")
        SiteConfig.not_exists_yet = "some value"
      end

      it "should update config if key present" do
        SiteConfig.send "#{config.key}=", "new value"
        expect(SiteConfig.find_by_key(config.key).value).to eq("new value")
      end
    end

    describe "getter" do
      it "should read cache if presents" do
        expect(SiteConfig).not_to receive(:where)
        Rails.cache.write("site_config:#{config.key}", config.value)
        expect(SiteConfig.send(config.key)).to eq(config.value)
      end

      it "should fetch value and update cache" do
        Rails.cache.clear
        expect(SiteConfig.send(config.key)).to eq(config.value)
        expect(Rails.cache.read("site_config:#{config.key}")).to eq(config.value)
      end

      it "should return nil if key not present" do
        expect(SiteConfig.not_exists_yet).to be_nil
      end
    end
  end
end