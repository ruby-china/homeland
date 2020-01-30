# frozen_string_literal: true

require "spec_helper"

class SoftDeleteTest < ActiveSupport::TestCase
  ActiveRecord::Base.connection.create_table(:walking_deads, force: true) do |t|
    t.string :name
    t.string :tag
    t.datetime :deleted_at
    t.timestamps null: false
  end

  class WalkingDead < ApplicationRecord
    include SoftDelete

    after_destroy do
      self.tag = "after_destroy #{name}"
    end

    before_validation :check_name_not_exist
    def check_name_not_exist
      if WalkingDead.unscoped.where(name: self.name).count > 0
        errors.add("name", "已经存在")
      end
    end
  end

  test "should work" do
    rick = WalkingDead.create!(name: "Rick Grimes")

    assert_changes -> { WalkingDead.count }, -1 do
      rick.destroy
    end
    assert_equal "after_destroy Rick Grimes", rick.tag
    rick.reload
    assert_equal true, rick.deleted_at.present?
    rick.deleted?

    assert_no_changes -> { WalkingDead.unscoped.count } do
      rick.destroy
    end

    assert_equal 0, WalkingDead.where(name: rick.name).count
    assert_equal rick, WalkingDead.unscoped.where(name: rick.name).first
  end
end
