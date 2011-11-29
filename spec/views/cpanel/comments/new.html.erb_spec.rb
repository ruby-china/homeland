require 'spec_helper'

describe "cpanel/comments/new.html.erb" do
  before(:each) do
    assign(:cpanel_comment, stub_model(Cpanel::Comment,
      :commentable => "",
      :user => nil,
      :body => "MyText"
    ).as_new_record)
  end

  it "renders new cpanel_comment form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => cpanel_comments_path, :method => "post" do
      assert_select "input#cpanel_comment_commentable", :name => "cpanel_comment[commentable]"
      assert_select "input#cpanel_comment_user", :name => "cpanel_comment[user]"
      assert_select "textarea#cpanel_comment_body", :name => "cpanel_comment[body]"
    end
  end
end
