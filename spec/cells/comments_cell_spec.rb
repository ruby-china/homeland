require "spec_helper"

describe CommentsCell do
  before(:each) do
    @post = Factory :post
    @user = Factory :user
  end

  it "should handle no comment correctly" do
    render_cell(:comments, :index, :commentable => @post).should have_css("div.no_result")
  end

  it "should render comments" do
    3.times { comment = Factory :comment, :commentable => @post }

    render_cell(:comments, :index, :commentable => @post).should have_css("div.comment", :count => 3)
  end

  it "should not show new comment box when user not logged in" do
    render_cell(:comments, :index, :commentable => @post).should_not have_css("div.cell_comments_new")
  end

  it "should show new comment box when user logged in" do
    render_cell(:comments, :index, :commentable => @post, :current_user => @user).should have_css("div.cell_comments_new")
  end
end
