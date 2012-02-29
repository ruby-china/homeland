require "spec_helper"

describe SiteConfig do
  let!(:config) { Factory :site_config }

  describe "#update_cache" do
    it "should update cache" do
      Rails.cache.should_receive(:write).with("site_config:#{config.key}", config.value)
      config.update_cache
    end

    it "should update cache after config is saved" do
      Rails.cache.should_receive(:write).with("site_config:#{config.key}", config.value)
      config.save
    end
  end

  describe "find_by_key" do
    it "should be able to find_by_key" do
      SiteConfig.find_by_key(config.key).value.should == config.value
    end
  end

  describe "save_default" do
    it "should create config if not exist" do
      attributes = Factory.attributes_for :site_config
      SiteConfig.should_receive(:create).with(:key => attributes[:key], :value => attributes[:value])
      SiteConfig.save_default(attributes[:key], attributes[:value])
    end

    it "should not change value if key presents" do
      SiteConfig.should_not_receive(:create)
      SiteConfig.save_default(config.key, "new value")
      SiteConfig.find_by_key(config.key).value.should_not == "new value"
      SiteConfig.find_by_key(config.key).value.should == config.value
    end
  end

  describe "method_missing" do
    describe "setter" do
      it "should create new config if key not present" do
        SiteConfig.should_receive(:create).with(:key => "not_exists_yet", :value => "some value")
        SiteConfig.not_exists_yet = "some value"
      end

      it "should update config if key present" do
        SiteConfig.send "#{config.key}=", "new value"
        SiteConfig.find_by_key(config.key).value.should == "new value"
      end
    end

    describe "getter" do
      it "should read cache if presents" do
        SiteConfig.should_not_receive(:where)
        Rails.cache.write("site_config:#{config.key}", config.value)
        SiteConfig.send(config.key).should == config.value
      end

      it "should fetch value and update cache" do
        Rails.cache.clear
        SiteConfig.send(config.key).should == config.value
        Rails.cache.read("site_config:#{config.key}").should == config.value
      end

      it "should return nil if key not present" do
        SiteConfig.not_exists_yet.should be_nil
      end
    end
  end
end