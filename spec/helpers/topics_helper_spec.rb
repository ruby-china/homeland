require "spec_helper"

describe TopicsHelper do
  describe "format_topic_body" do
    it "should bold text " do
      helper.format_topic_body("**bold**").should  == '<p><strong>bold</strong></p>'
    end

    it "should italic text " do
      helper.format_topic_body("*italic*").should  == '<p><em>italic</em></p>'
    end

  end
end
