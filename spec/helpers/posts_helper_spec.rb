require "spec_helper"

describe PostsHelper do
  before(:each) do
    @post = Factory :post
  end

  describe "post_title_tag" do
    it "should return link" do
      helper.post_title_tag(@post).should == %{<a href="/posts/#{@post.id}" title="#{@post.title}">#{@post.title}</a>}
    end
  end
end
