require 'spec_helper'

describe "cpanel/comments/index.html.erb" do
  before(:each) do
    assign(:cpanel_comments, [
      stub_model(Cpanel::Comment,
        :commentable => "",
        :user => nil,
        :body => "MyText"
      ),
      stub_model(Cpanel::Comment,
        :commentable => "",
        :user => nil,
        :body => "MyText"
      )
    ])
  end

  it "renders a list of cpanel/comments" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => nil.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
