# frozen_string_literal: true

require "rails_helper"

describe LikesHelper, type: :helper do
  describe "likeable_tag" do
    let(:user) { create :user }
    let(:topic) { create :topic }
    let(:reply) { create :reply }

    it "should run with nil param" do
      allow(helper).to receive(:current_user).and_return(nil)
      assert_equal "", helper.likeable_tag(nil)
    end

    it "should result when logined user liked" do
      allow(helper).to receive(:current_user).and_return(user)
      allow(user).to receive(:like_topic_ids).and_return([topic.id])
      assert_equal %(<a title="取消赞" data-count="0" data-state="active" data-type="Topic" data-id="1" class="likeable active" href="#"><i class='fa fa-heart'></i> <span></span></a>), helper.likeable_tag(topic)
      allow(topic).to receive(:likes_count).and_return(3)
      assert_equal %(<a title="取消赞" data-count="3" data-state="active" data-type="Topic" data-id="1" class="likeable active" href="#"><i class='fa fa-heart'></i> <span>3 个赞</span></a>), helper.likeable_tag(topic)
    end

    it "should result when unlogin user" do
      allow(helper).to receive(:current_user).and_return(nil)
      assert_equal %(<a title="赞" data-count="0" data-state="deactive" data-type="Topic" data-id="1" class="likeable deactive" href="#"><i class='fa fa-heart'></i> <span></span></a>), helper.likeable_tag(topic)
    end

    it "should result with no_cache params" do
      str = %(<a title="赞" data-count="0" data-state="deactive" data-type="Topic" data-id="1" class="likeable deactive" href="#"><i class='fa fa-heart'></i> <span></span></a>)
      allow(helper).to receive(:current_user).and_return(user)
      assert_equal str, helper.likeable_tag(topic, cache: true)
    end

    it "should allow addition class" do
      allow(helper).to receive(:current_user).and_return(user)
      assert_equal %(<a title="赞" data-count="0" data-state="deactive" data-type="Reply" data-id="1" class="likeable deactive btn btn-default" href="#"><i class='fa fa-heart'></i> <span></span></a>), helper.likeable_tag(reply, class: "btn btn-default")
    end
  end
end
