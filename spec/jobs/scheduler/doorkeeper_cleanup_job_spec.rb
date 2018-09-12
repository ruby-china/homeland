# frozen_string_literal: true

require "rails_helper"

describe Scheduler::DoorkeeperCleanupJob, type: :job do
  describe ".perform" do
    it "should work" do
      create_list(:access_token, 3, revoked_at: nil)
      create_list(:access_grant, 1, revoked_at: nil)

      create_list(:access_token, 2, revoked_at: 1.days.ago)
      create_list(:access_grant, 1, revoked_at: 1.days.ago)

      assert_equal 5, Doorkeeper::AccessToken.count
      assert_equal 2, Doorkeeper::AccessToken.where("revoked_at IS NOT NULL").where("revoked_at < NOW()").count
      assert_equal 2, Doorkeeper::AccessGrant.count
      assert_equal 1, Doorkeeper::AccessGrant.where("revoked_at IS NOT NULL").where("revoked_at < NOW()").count

      Scheduler::DoorkeeperCleanupJob.perform_later

      assert_equal 3, Doorkeeper::AccessToken.count
      assert_equal 1, Doorkeeper::AccessGrant.count
    end
  end
end
