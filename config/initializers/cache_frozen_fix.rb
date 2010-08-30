# coding: utf-8  
module CacheFrozenFix
  def self.included(base)
    base.extend ClassMethods  
  end
  
  module ClassMethods
    def cache_frozen_fix
      include CacheFrozenFix::InstanceMethods
    end
  end
  
  module InstanceMethods
    public
    # == 将 frozen 的 hash unfreeze
    # 临时解决 Rails.cache.fetch 后 can't modify frozen hash 的错误
    def dup
      obj = super
      obj.instance_variable_set('@attributes', instance_variable_get('@attributes').dup)
      obj
    end
  end
end

ActiveRecord::Base.send(:include, CacheFrozenFix)
