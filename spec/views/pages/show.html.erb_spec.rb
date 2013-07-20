require 'spec_helper'

describe "pages/show.html.erb" do
  let(:user) { FactoryGirl.create(:user) }
  let(:page) { FactoryGirl.create(:page) }
  before { controller.stub(:current_user => user) }

  it 'escapes title in social share button' do
    page.title = 'f\'></div><button id="danger" onclick="javascript:alert(\'ooh\')">share</button><div style="display:none"'
    assign(:page, page)

    render

    doc = Nokogiri::HTML.fragment(rendered)
    expect(doc.at('button#danger')).to be_nil
  end
end
