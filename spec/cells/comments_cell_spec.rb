require "rails_helper"

describe CommentsCell do
  before(:each) do
    @page = Factory :page
    @user = Factory :user
  end

  it "should handle no comment correctly" do
    expect(render_cell(:comments, :index, :commentable => @page)).to have_css("div.no-result")
  end

  it "should render comments" do
    3.times { comment = Factory :comment, :commentable => @page }

    expect(render_cell(:comments, :index, :commentable => @page)).to have_css("div.comment", :count => 3)
  end

  it "should not show new comment box when user not logged in" do
    expect(render_cell(:comments, :index, :commentable => @page)).not_to have_css("div.cell_comments_new")
  end

  it "should show new comment box when user logged in" do
    expect(render_cell(:comments, :index, :commentable => @page, :current_user => @user)).to have_css("div.cell_comments_new")
  end
end
