# coding: utf-8
# 在数据库中的配置信息
# 这里有存放首页,Wiki 等页面 HTML
# 使用方法
# SiteConfig.foo
# SiteConfig.foo = "asdkglaksdg"
class SiteConfig
  include Mongoid::Document

  field :key
  field :value

  index :key

  validates_presence_of :key
  validates_uniqueness_of :key

  def self.method_missing(method, *args)
    method_name = method.to_s
    super(method, *args)
  rescue NoMethodError
    if method_name =~ /=$/
      var_name = method_name.gsub('=', '')
      value = args.first.to_s
      # save
      if item = find_by_key(var_name)
        item.update_attribute(:value, value)
      else
        SiteConfig.create(:key => var_name, :value => value)
      end
    else
      Rails.cache.fetch("site_config:#{method}") do
        if item = where(:key => method).first
          item.value
        else
          nil
        end
      end
    end
  end

  after_save :expire_cache
  def expire_cache
    Rails.cache.write("site_config:#{self.key}", self.value)
  end

  def self.find_by_key(key)
    where(:key => key.to_s).first
  end

  def self.save_default(key, value)
    if not find_by_key(key)
      create(:key => key, :value => value.to_s)
    end
  end
end
